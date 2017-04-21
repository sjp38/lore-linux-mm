Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4B9AD6B03A2
	for <linux-mm@kvack.org>; Fri, 21 Apr 2017 10:05:02 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id d132so5360041qkg.23
        for <linux-mm@kvack.org>; Fri, 21 Apr 2017 07:05:02 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x45si9619496qtb.149.2017.04.21.07.05.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Apr 2017 07:05:01 -0700 (PDT)
From: Waiman Long <longman@redhat.com>
Subject: [RFC PATCH 07/14] cgroup: Move debug cgroup to its own file
Date: Fri, 21 Apr 2017 10:04:05 -0400
Message-Id: <1492783452-12267-8-git-send-email-longman@redhat.com>
In-Reply-To: <1492783452-12267-1-git-send-email-longman@redhat.com>
References: <1492783452-12267-1-git-send-email-longman@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>
Cc: cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com, pjt@google.com, luto@amacapital.net, efault@gmx.de, Waiman Long <longman@redhat.com>

The debug cgroup currently resides within cgroup-v1.c and is enabled
only for v1 cgroup. To enable the debug cgroup also for v2, it
makes sense to put the code into its own file as it will no longer
be v1 specific. The only change in this patch is the expansion of
cgroup_task_count() within the debug_taskcount_read() function.

Signed-off-by: Waiman Long <longman@redhat.com>
---
 kernel/cgroup/Makefile    |   1 +
 kernel/cgroup/cgroup-v1.c | 147 -----------------------------------------
 kernel/cgroup/debug.c     | 165 ++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 166 insertions(+), 147 deletions(-)
 create mode 100644 kernel/cgroup/debug.c

diff --git a/kernel/cgroup/Makefile b/kernel/cgroup/Makefile
index 387348a..ce693cc 100644
--- a/kernel/cgroup/Makefile
+++ b/kernel/cgroup/Makefile
@@ -4,3 +4,4 @@ obj-$(CONFIG_CGROUP_FREEZER) += freezer.o
 obj-$(CONFIG_CGROUP_PIDS) += pids.o
 obj-$(CONFIG_CGROUP_RDMA) += rdma.o
 obj-$(CONFIG_CPUSETS) += cpuset.o
+obj-$(CONFIG_CGROUP_DEBUG) += debug.o
diff --git a/kernel/cgroup/cgroup-v1.c b/kernel/cgroup/cgroup-v1.c
index e80bc8e..6757a50 100644
--- a/kernel/cgroup/cgroup-v1.c
+++ b/kernel/cgroup/cgroup-v1.c
@@ -1297,150 +1297,3 @@ static int __init cgroup_no_v1(char *str)
 	return 1;
 }
 __setup("cgroup_no_v1=", cgroup_no_v1);
-
-
-#ifdef CONFIG_CGROUP_DEBUG
-static struct cgroup_subsys_state *
-debug_css_alloc(struct cgroup_subsys_state *parent_css)
-{
-	struct cgroup_subsys_state *css = kzalloc(sizeof(*css), GFP_KERNEL);
-
-	if (!css)
-		return ERR_PTR(-ENOMEM);
-
-	return css;
-}
-
-static void debug_css_free(struct cgroup_subsys_state *css)
-{
-	kfree(css);
-}
-
-static u64 debug_taskcount_read(struct cgroup_subsys_state *css,
-				struct cftype *cft)
-{
-	return cgroup_task_count(css->cgroup);
-}
-
-static u64 current_css_set_read(struct cgroup_subsys_state *css,
-				struct cftype *cft)
-{
-	return (u64)(unsigned long)current->cgroups;
-}
-
-static u64 current_css_set_refcount_read(struct cgroup_subsys_state *css,
-					 struct cftype *cft)
-{
-	u64 count;
-
-	rcu_read_lock();
-	count = atomic_read(&task_css_set(current)->refcount);
-	rcu_read_unlock();
-	return count;
-}
-
-static int current_css_set_cg_links_read(struct seq_file *seq, void *v)
-{
-	struct cgrp_cset_link *link;
-	struct css_set *cset;
-	char *name_buf;
-
-	name_buf = kmalloc(NAME_MAX + 1, GFP_KERNEL);
-	if (!name_buf)
-		return -ENOMEM;
-
-	spin_lock_irq(&css_set_lock);
-	rcu_read_lock();
-	cset = rcu_dereference(current->cgroups);
-	list_for_each_entry(link, &cset->cgrp_links, cgrp_link) {
-		struct cgroup *c = link->cgrp;
-
-		cgroup_name(c, name_buf, NAME_MAX + 1);
-		seq_printf(seq, "Root %d group %s\n",
-			   c->root->hierarchy_id, name_buf);
-	}
-	rcu_read_unlock();
-	spin_unlock_irq(&css_set_lock);
-	kfree(name_buf);
-	return 0;
-}
-
-#define MAX_TASKS_SHOWN_PER_CSS 25
-static int cgroup_css_links_read(struct seq_file *seq, void *v)
-{
-	struct cgroup_subsys_state *css = seq_css(seq);
-	struct cgrp_cset_link *link;
-
-	spin_lock_irq(&css_set_lock);
-	list_for_each_entry(link, &css->cgroup->cset_links, cset_link) {
-		struct css_set *cset = link->cset;
-		struct task_struct *task;
-		int count = 0;
-
-		seq_printf(seq, "css_set %pK\n", cset);
-
-		list_for_each_entry(task, &cset->tasks, cg_list) {
-			if (count++ > MAX_TASKS_SHOWN_PER_CSS)
-				goto overflow;
-			seq_printf(seq, "  task %d\n", task_pid_vnr(task));
-		}
-
-		list_for_each_entry(task, &cset->mg_tasks, cg_list) {
-			if (count++ > MAX_TASKS_SHOWN_PER_CSS)
-				goto overflow;
-			seq_printf(seq, "  task %d\n", task_pid_vnr(task));
-		}
-		continue;
-	overflow:
-		seq_puts(seq, "  ...\n");
-	}
-	spin_unlock_irq(&css_set_lock);
-	return 0;
-}
-
-static u64 releasable_read(struct cgroup_subsys_state *css, struct cftype *cft)
-{
-	return (!cgroup_is_populated(css->cgroup) &&
-		!css_has_online_children(&css->cgroup->self));
-}
-
-static struct cftype debug_files[] =  {
-	{
-		.name = "taskcount",
-		.read_u64 = debug_taskcount_read,
-	},
-
-	{
-		.name = "current_css_set",
-		.read_u64 = current_css_set_read,
-	},
-
-	{
-		.name = "current_css_set_refcount",
-		.read_u64 = current_css_set_refcount_read,
-	},
-
-	{
-		.name = "current_css_set_cg_links",
-		.seq_show = current_css_set_cg_links_read,
-	},
-
-	{
-		.name = "cgroup_css_links",
-		.seq_show = cgroup_css_links_read,
-	},
-
-	{
-		.name = "releasable",
-		.read_u64 = releasable_read,
-	},
-
-	{ }	/* terminate */
-};
-
-struct cgroup_subsys debug_cgrp_subsys = {
-	.css_alloc = debug_css_alloc,
-	.css_free = debug_css_free,
-	.legacy_cftypes = debug_files,
-};
-#endif /* CONFIG_CGROUP_DEBUG */
diff --git a/kernel/cgroup/debug.c b/kernel/cgroup/debug.c
new file mode 100644
index 0000000..9146461
--- /dev/null
+++ b/kernel/cgroup/debug.c
@@ -0,0 +1,165 @@
+#include <linux/ctype.h>
+#include <linux/mm.h>
+#include <linux/slab.h>
+
+#include "cgroup-internal.h"
+
+static struct cgroup_subsys_state *
+debug_css_alloc(struct cgroup_subsys_state *parent_css)
+{
+	struct cgroup_subsys_state *css = kzalloc(sizeof(*css), GFP_KERNEL);
+
+	if (!css)
+		return ERR_PTR(-ENOMEM);
+
+	return css;
+}
+
+static void debug_css_free(struct cgroup_subsys_state *css)
+{
+	kfree(css);
+}
+
+/*
+ * debug_taskcount_read - return the number of tasks in a cgroup.
+ * @cgrp: the cgroup in question
+ *
+ * Return the number of tasks in the cgroup.  The returned number can be
+ * higher than the actual number of tasks due to css_set references from
+ * namespace roots and temporary usages.
+ */
+static u64 debug_taskcount_read(struct cgroup_subsys_state *css,
+				struct cftype *cft)
+{
+	struct cgroup *cgrp = css->cgroup;
+	u64 count = 0;
+	struct cgrp_cset_link *link;
+
+	spin_lock_irq(&css_set_lock);
+	list_for_each_entry(link, &cgrp->cset_links, cset_link)
+		count += atomic_read(&link->cset->refcount);
+	spin_unlock_irq(&css_set_lock);
+	return count;
+}
+
+static u64 current_css_set_read(struct cgroup_subsys_state *css,
+				struct cftype *cft)
+{
+	return (u64)(unsigned long)current->cgroups;
+}
+
+static u64 current_css_set_refcount_read(struct cgroup_subsys_state *css,
+					 struct cftype *cft)
+{
+	u64 count;
+
+	rcu_read_lock();
+	count = atomic_read(&task_css_set(current)->refcount);
+	rcu_read_unlock();
+	return count;
+}
+
+static int current_css_set_cg_links_read(struct seq_file *seq, void *v)
+{
+	struct cgrp_cset_link *link;
+	struct css_set *cset;
+	char *name_buf;
+
+	name_buf = kmalloc(NAME_MAX + 1, GFP_KERNEL);
+	if (!name_buf)
+		return -ENOMEM;
+
+	spin_lock_irq(&css_set_lock);
+	rcu_read_lock();
+	cset = rcu_dereference(current->cgroups);
+	list_for_each_entry(link, &cset->cgrp_links, cgrp_link) {
+		struct cgroup *c = link->cgrp;
+
+		cgroup_name(c, name_buf, NAME_MAX + 1);
+		seq_printf(seq, "Root %d group %s\n",
+			   c->root->hierarchy_id, name_buf);
+	}
+	rcu_read_unlock();
+	spin_unlock_irq(&css_set_lock);
+	kfree(name_buf);
+	return 0;
+}
+
+#define MAX_TASKS_SHOWN_PER_CSS 25
+static int cgroup_css_links_read(struct seq_file *seq, void *v)
+{
+	struct cgroup_subsys_state *css = seq_css(seq);
+	struct cgrp_cset_link *link;
+
+	spin_lock_irq(&css_set_lock);
+	list_for_each_entry(link, &css->cgroup->cset_links, cset_link) {
+		struct css_set *cset = link->cset;
+		struct task_struct *task;
+		int count = 0;
+
+		seq_printf(seq, "css_set %pK\n", cset);
+
+		list_for_each_entry(task, &cset->tasks, cg_list) {
+			if (count++ > MAX_TASKS_SHOWN_PER_CSS)
+				goto overflow;
+			seq_printf(seq, "  task %d\n", task_pid_vnr(task));
+		}
+
+		list_for_each_entry(task, &cset->mg_tasks, cg_list) {
+			if (count++ > MAX_TASKS_SHOWN_PER_CSS)
+				goto overflow;
+			seq_printf(seq, "  task %d\n", task_pid_vnr(task));
+		}
+		continue;
+	overflow:
+		seq_puts(seq, "  ...\n");
+	}
+	spin_unlock_irq(&css_set_lock);
+	return 0;
+}
+
+static u64 releasable_read(struct cgroup_subsys_state *css, struct cftype *cft)
+{
+	return (!cgroup_is_populated(css->cgroup) &&
+		!css_has_online_children(&css->cgroup->self));
+}
+
+static struct cftype debug_files[] =  {
+	{
+		.name = "taskcount",
+		.read_u64 = debug_taskcount_read,
+	},
+
+	{
+		.name = "current_css_set",
+		.read_u64 = current_css_set_read,
+	},
+
+	{
+		.name = "current_css_set_refcount",
+		.read_u64 = current_css_set_refcount_read,
+	},
+
+	{
+		.name = "current_css_set_cg_links",
+		.seq_show = current_css_set_cg_links_read,
+	},
+
+	{
+		.name = "cgroup_css_links",
+		.seq_show = cgroup_css_links_read,
+	},
+
+	{
+		.name = "releasable",
+		.read_u64 = releasable_read,
+	},
+
+	{ }	/* terminate */
+};
+
+struct cgroup_subsys debug_cgrp_subsys = {
+	.css_alloc = debug_css_alloc,
+	.css_free = debug_css_free,
+	.legacy_cftypes = debug_files,
+};
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
