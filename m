Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 049246B03A5
	for <linux-mm@kvack.org>; Fri, 21 Apr 2017 10:05:08 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id g27so21929516qte.12
        for <linux-mm@kvack.org>; Fri, 21 Apr 2017 07:05:08 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g27si9628705qtg.133.2017.04.21.07.05.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Apr 2017 07:05:07 -0700 (PDT)
From: Waiman Long <longman@redhat.com>
Subject: [RFC PATCH 09/14] cgroup: Make debug cgroup support v2 and thread mode
Date: Fri, 21 Apr 2017 10:04:07 -0400
Message-Id: <1492783452-12267-10-git-send-email-longman@redhat.com>
In-Reply-To: <1492783452-12267-1-git-send-email-longman@redhat.com>
References: <1492783452-12267-1-git-send-email-longman@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>
Cc: cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com, pjt@google.com, luto@amacapital.net, efault@gmx.de, Waiman Long <longman@redhat.com>

Besides supporting cgroup v2 and thread mode, the following changes
are also made:
 1) current_* cgroup files now resides only at the root as we don't
    need duplicated files of the same function all over the cgroup
    hierarchy.
 2) The cgroup_css_links_read() function is modified to report
    the number of tasks that are skipped because of overflow.
 3) The relationship between proc_cset and threaded_csets are displayed.
 4) The number of extra unaccounted references are displayed.
 5) The status of being a thread root or threaded cgroup is displayed.
 6) The current_css_set_read() function now prints out the addresses of
    the css'es associated with the current css_set.
 7) A new cgroup_subsys_states file is added to display the css objects
    associated with a cgroup.

Signed-off-by: Waiman Long <longman@redhat.com>
---
 kernel/cgroup/debug.c | 151 ++++++++++++++++++++++++++++++++++++++++++++------
 1 file changed, 134 insertions(+), 17 deletions(-)

diff --git a/kernel/cgroup/debug.c b/kernel/cgroup/debug.c
index c8f7590..4d74458 100644
--- a/kernel/cgroup/debug.c
+++ b/kernel/cgroup/debug.c
@@ -38,10 +38,37 @@ static u64 debug_taskcount_read(struct cgroup_subsys_state *css,
 	return count;
 }
 
-static u64 current_css_set_read(struct cgroup_subsys_state *css,
-				struct cftype *cft)
+static int current_css_set_read(struct seq_file *seq, void *v)
 {
-	return (u64)(unsigned long)current->cgroups;
+	struct css_set *cset;
+	struct cgroup_subsys *ss;
+	struct cgroup_subsys_state *css;
+	int i, refcnt;
+
+	mutex_lock(&cgroup_mutex);
+	spin_lock_irq(&css_set_lock);
+	rcu_read_lock();
+	cset = rcu_dereference(current->cgroups);
+	refcnt = atomic_read(&cset->refcount);
+	seq_printf(seq, "css_set %pK %d", cset, refcnt);
+	if (refcnt > cset->task_count)
+		seq_printf(seq, " +%d", refcnt - cset->task_count);
+	seq_puts(seq, "\n");
+
+	/*
+	 * Print the css'es stored in the current css_set.
+	 */
+	for_each_subsys(ss, i) {
+		css = cset->subsys[ss->id];
+		if (!css)
+			continue;
+		seq_printf(seq, "%2d: %-4s\t- %lx[%d]\n", ss->id, ss->name,
+			  (unsigned long)css, css->id);
+	}
+	rcu_read_unlock();
+	spin_unlock_irq(&css_set_lock);
+	mutex_unlock(&cgroup_mutex);
+	return 0;
 }
 
 static u64 current_css_set_refcount_read(struct cgroup_subsys_state *css,
@@ -86,31 +113,111 @@ static int cgroup_css_links_read(struct seq_file *seq, void *v)
 {
 	struct cgroup_subsys_state *css = seq_css(seq);
 	struct cgrp_cset_link *link;
+	int dead_cnt = 0, extra_refs = 0, threaded_csets = 0;
 
 	spin_lock_irq(&css_set_lock);
+	if (css->cgroup->proc_cgrp)
+		seq_puts(seq, (css->cgroup->proc_cgrp == css->cgroup)
+			      ? "[thread root]\n" : "[threaded]\n");
+
 	list_for_each_entry(link, &css->cgroup->cset_links, cset_link) {
 		struct css_set *cset = link->cset;
 		struct task_struct *task;
 		int count = 0;
+		int refcnt = atomic_read(&cset->refcount);
 
-		seq_printf(seq, "css_set %pK\n", cset);
+		/*
+		 * Print out the proc_cset and threaded_cset relationship
+		 * and highlight difference between refcount and task_count.
+		 */
+		seq_printf(seq, "css_set %pK", cset);
+		if (cset->proc_cset != cset) {
+			threaded_csets++;
+			seq_printf(seq, "=>%pK", cset->proc_cset);
+		}
+		if (!list_empty(&cset->threaded_csets)) {
+			struct css_set *tcset;
+			int idx = 0;
+
+			list_for_each_entry(tcset, &cset->threaded_csets,
+					    threaded_csets_node) {
+				seq_puts(seq, idx ? "," : "<=");
+				seq_printf(seq, "%pK", tcset);
+				idx++;
+			}
+		} else {
+			seq_printf(seq, " %d", refcnt);
+			if (refcnt - cset->task_count > 0) {
+				int extra = refcnt - cset->task_count;
+
+				seq_printf(seq, " +%d", extra);
+				/*
+				 * Take out the one additional reference in
+				 * init_css_set.
+				 */
+				if (cset == &init_css_set)
+					extra--;
+				extra_refs += extra;
+			}
+		}
+		seq_puts(seq, "\n");
 
 		list_for_each_entry(task, &cset->tasks, cg_list) {
-			if (count++ > MAX_TASKS_SHOWN_PER_CSS)
-				goto overflow;
-			seq_printf(seq, "  task %d\n", task_pid_vnr(task));
+			if (count++ <= MAX_TASKS_SHOWN_PER_CSS)
+				seq_printf(seq, "  task %d\n",
+					   task_pid_vnr(task));
 		}
 
 		list_for_each_entry(task, &cset->mg_tasks, cg_list) {
-			if (count++ > MAX_TASKS_SHOWN_PER_CSS)
-				goto overflow;
-			seq_printf(seq, "  task %d\n", task_pid_vnr(task));
+			if (count++ <= MAX_TASKS_SHOWN_PER_CSS)
+				seq_printf(seq, "  task %d\n",
+					   task_pid_vnr(task));
 		}
-		continue;
-	overflow:
-		seq_puts(seq, "  ...\n");
+		/* show # of overflowed tasks */
+		if (count > MAX_TASKS_SHOWN_PER_CSS)
+			seq_printf(seq, "  ... (%d)\n",
+				   count - MAX_TASKS_SHOWN_PER_CSS);
+
+		if (cset->dead) {
+			seq_puts(seq, "    [dead]\n");
+			dead_cnt++;
+		}
+
+		WARN_ON(count != cset->task_count);
 	}
 	spin_unlock_irq(&css_set_lock);
+
+	if (!dead_cnt && !extra_refs && !threaded_csets)
+		return 0;
+
+	seq_puts(seq, "\n");
+	if (threaded_csets)
+		seq_printf(seq, "threaded css_sets = %d\n", threaded_csets);
+	if (extra_refs)
+		seq_printf(seq, "extra references = %d\n", extra_refs);
+	if (dead_cnt)
+		seq_printf(seq, "dead css_sets = %d\n", dead_cnt);
+
+	return 0;
+}
+
+static int cgroup_subsys_states_read(struct seq_file *seq, void *v)
+{
+	struct cgroup *cgrp = seq_css(seq)->cgroup;
+	struct cgroup_subsys *ss;
+	struct cgroup_subsys_state *css;
+	int i;
+
+	mutex_lock(&cgroup_mutex);
+	for_each_subsys(ss, i) {
+		css = rcu_dereference_check(cgrp->subsys[ss->id], true);
+		if (!css)
+			continue;
+		seq_printf(seq, "%2d: %-4s\t- %lx[%d] %d\n", ss->id, ss->name,
+			  (unsigned long)css, css->id,
+			  atomic_read(&css->online_cnt));
+	}
+	mutex_unlock(&cgroup_mutex);
 	return 0;
 }
 
@@ -128,17 +235,20 @@ static u64 releasable_read(struct cgroup_subsys_state *css, struct cftype *cft)
 
 	{
 		.name = "current_css_set",
-		.read_u64 = current_css_set_read,
+		.seq_show = current_css_set_read,
+		.flags = CFTYPE_ONLY_ON_ROOT,
 	},
 
 	{
 		.name = "current_css_set_refcount",
 		.read_u64 = current_css_set_refcount_read,
+		.flags = CFTYPE_ONLY_ON_ROOT,
 	},
 
 	{
 		.name = "current_css_set_cg_links",
 		.seq_show = current_css_set_cg_links_read,
+		.flags = CFTYPE_ONLY_ON_ROOT,
 	},
 
 	{
@@ -147,6 +257,11 @@ static u64 releasable_read(struct cgroup_subsys_state *css, struct cftype *cft)
 	},
 
 	{
+		.name = "cgroup_subsys_states",
+		.seq_show = cgroup_subsys_states_read,
+	},
+
+	{
 		.name = "releasable",
 		.read_u64 = releasable_read,
 	},
@@ -155,7 +270,9 @@ static u64 releasable_read(struct cgroup_subsys_state *css, struct cftype *cft)
 };
 
 struct cgroup_subsys debug_cgrp_subsys = {
-	.css_alloc = debug_css_alloc,
-	.css_free = debug_css_free,
-	.legacy_cftypes = debug_files,
+	.css_alloc	= debug_css_alloc,
+	.css_free	= debug_css_free,
+	.legacy_cftypes	= debug_files,
+	.dfl_cftypes	= debug_files,
+	.threaded	= true,
 };
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
