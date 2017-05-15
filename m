Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 31E776B0374
	for <linux-mm@kvack.org>; Mon, 15 May 2017 09:35:03 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id d14so52144068qkb.0
        for <linux-mm@kvack.org>; Mon, 15 May 2017 06:35:03 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q46si10727566qtb.158.2017.05.15.06.35.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 May 2017 06:35:02 -0700 (PDT)
From: Waiman Long <longman@redhat.com>
Subject: [RFC PATCH v2 14/17] cgroup: Enable printing of v2 controllers' cgroup hierarchy
Date: Mon, 15 May 2017 09:34:13 -0400
Message-Id: <1494855256-12558-15-git-send-email-longman@redhat.com>
In-Reply-To: <1494855256-12558-1-git-send-email-longman@redhat.com>
References: <1494855256-12558-1-git-send-email-longman@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>
Cc: cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com, pjt@google.com, luto@amacapital.net, efault@gmx.de, longman@redhat.com

This patch add a new debug control file on the cgroup v2 root directory
to print out the cgroup hierarchy for each of the v2 controllers.

Signed-off-by: Waiman Long <longman@redhat.com>
---
 kernel/cgroup/debug.c | 141 ++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 141 insertions(+)

diff --git a/kernel/cgroup/debug.c b/kernel/cgroup/debug.c
index a2dbf77..3adb26a 100644
--- a/kernel/cgroup/debug.c
+++ b/kernel/cgroup/debug.c
@@ -268,6 +268,141 @@ static int cgroup_masks_read(struct seq_file *seq, void *v)
 	return 0;
 }
 
+/*
+ * Print out all the child cgroup names that doesn't have a css for the
+ * corresponding cgroup_subsys. If a child cgroup has a css, put that into
+ * the given cglist to be processed in the next iteration.
+ */
+#define CGLIST_MAX	16
+static void print_hierarchy(struct seq_file *seq,
+			    struct cgroup *cgrp,
+			    struct cgroup_subsys *ss,
+			    struct cgroup_subsys_state *css,
+			    struct cgroup **cglist,
+			    int *cgcnt)
+{
+	struct cgroup *child;
+	struct cgroup_subsys_state *child_css;
+	char cgname[64];
+
+	cgname[sizeof(cgname) - 1] = '\0';
+	/*
+	 * Iterate all live children of the given cgroup.
+	 */
+	list_for_each_entry(child, &cgrp->self.children, self.sibling) {
+		if (cgroup_is_dead(child))
+			continue;
+
+		child_css = rcu_dereference_check(child->subsys[ss->id], true);
+		if (child_css) {
+			WARN_ON(child_css->parent != css);
+			if (*cgcnt < CGLIST_MAX) {
+				cglist[*cgcnt] = child;
+				(*cgcnt)++;
+			}
+			continue;
+		}
+
+		/*
+		 * Skip resource domain cgroup
+		 */
+		if (test_bit(CGRP_RESOURCE_DOMAIN, &child->flags))
+			continue;
+
+		cgroup_name(child, cgname, sizeof(cgname)-1);
+		seq_putc(seq, ',');
+		seq_puts(seq, cgname);
+		print_hierarchy(seq, child, ss, css, cglist, cgcnt);
+	}
+}
+
+/*
+ * Print the hierachies with respect to each controller for the default
+ * hierarchy.
+ *
+ * Each child level is printed on a separate line. Set of cgroups that
+ * have the same css will be grouped together and separated by comma.
+ * Process in those cgroups will be in the same node (css) in the
+ * controller's hierarchy. There is an exception that for resource
+ * domain cgroup, the processes associated with its parent and its
+ * affiliates will be mapped to the css of that resource domain cgroup
+ * instead.
+ *
+ * If there are more than CGLIST_MAX sets of cgroups in each level,
+ * the extra ones will be skipped.
+ */
+static int controller_hierachies_read(struct seq_file *seq, void *v)
+{
+	struct cgroup *root = seq_css(seq)->cgroup;
+	struct cgroup_subsys *ss;
+	struct cgroup_subsys_state *css;
+	struct cgroup *cgrp;
+	struct cgroup *cglist[CGLIST_MAX];
+	struct cgroup *cg2list[CGLIST_MAX];
+	int i, idx, cgnum, cg2num;
+	char cgname[64];
+
+	cgname[sizeof(cgname) - 1] = '\0';
+	mutex_lock(&cgroup_mutex);
+	for_each_subsys(ss, i) {
+		if (!(root->root->subsys_mask & (1 << ss->id)))
+			continue;
+		seq_puts(seq, ss->name);
+		seq_puts(seq, ":\n");
+
+		cgnum = 1;
+		cg2num = 0;
+		cglist[0] = root;
+		idx = 0;
+		while (cgnum) {
+			if (idx)
+				seq_putc(seq, ' ');
+			cgrp = cglist[idx];
+			if (test_bit(CGRP_RESOURCE_DOMAIN, &cgrp->flags)) {
+				struct cgroup *parent;
+
+				parent = container_of(cgrp->self.parent,
+						      struct cgroup, self);
+				cgroup_name(parent, cgname, sizeof(cgname)-1);
+				seq_printf(seq, "%s.rd", cgname);
+			} else {
+				cgroup_name(cgrp, cgname, sizeof(cgname)-1);
+				seq_puts(seq, cgname);
+			}
+			css = rcu_dereference_check(cgrp->subsys[ss->id], true);
+			WARN_ON(!css);
+
+			if (cgrp == root)
+				seq_printf(seq, "[%d]", css->id);
+			else
+				seq_printf(seq, "[%d:P=%d]", css->id,
+					   css->parent->id);
+
+			/*
+			 * List all the cgroups that use the current
+			 * css.
+			 */
+			print_hierarchy(seq, cgrp, ss, css, cg2list, &cg2num);
+
+			if (++idx < cgnum)
+				continue;
+
+			/*
+			 * Move cg2list to cglist.
+			 */
+			cgnum = cg2num;
+			idx = cg2num = 0;
+			if (cgnum)
+				memcpy(cglist, cg2list,
+				       cgnum * sizeof(cglist[0]));
+			seq_putc(seq, '\n');
+		}
+		seq_putc(seq, '\n');
+	}
+	mutex_unlock(&cgroup_mutex);
+	return 0;
+}
+
 static u64 releasable_read(struct cgroup_subsys_state *css, struct cftype *cft)
 {
 	return (!cgroup_is_populated(css->cgroup) &&
@@ -314,6 +449,12 @@ static u64 releasable_read(struct cgroup_subsys_state *css, struct cftype *cft)
 	},
 
 	{
+		.name = "controller_hierachies",
+		.seq_show = controller_hierachies_read,
+		.flags = CFTYPE_ONLY_ON_ROOT|__CFTYPE_ONLY_ON_DFL,
+	},
+
+	{
 		.name = "releasable",
 		.read_u64 = releasable_read,
 	},
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
