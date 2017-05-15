Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 51D916B0372
	for <linux-mm@kvack.org>; Mon, 15 May 2017 09:35:02 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id x53so46525317qtx.14
        for <linux-mm@kvack.org>; Mon, 15 May 2017 06:35:02 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k9si4925023qtk.235.2017.05.15.06.35.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 May 2017 06:35:00 -0700 (PDT)
From: Waiman Long <longman@redhat.com>
Subject: [RFC PATCH v2 13/17] cgroup: Allow fine-grained controllers control in cgroup v2
Date: Mon, 15 May 2017 09:34:12 -0400
Message-Id: <1494855256-12558-14-git-send-email-longman@redhat.com>
In-Reply-To: <1494855256-12558-1-git-send-email-longman@redhat.com>
References: <1494855256-12558-1-git-send-email-longman@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>
Cc: cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com, pjt@google.com, luto@amacapital.net, efault@gmx.de, longman@redhat.com

For cgroup v1, different controllers can be binded to different cgroup
hierarchies optimized for their own use cases. That is not currently
the case for cgroup v2 where combining all these controllers into
the same hierarchy will probably require more levels than is needed
by each individual controller.

By not enabling a controller in a cgroup and its descendants, we can
effectively trim the hierarchy as seen by a controller from the leafs
up. However, there is currently no way to compress the hierarchy in
the intermediate levels.

This patch implements a fine-grained mechanism to allow a controller to
skip some intermediate levels in a hierarchy and effectively flatten
the hierarchy as seen by that controller.

Controllers can now be directly enabled or disabled in a cgroup
by writing to the "cgroup.controllers" file.  The special prefix
'#' with the controller name is used to set that controller in
pass-through mode.  In that mode, the controller is disabled for that
cgroup but it allows its children to have that controller enabled or
in pass-through mode again.

With this change, each controller can now have a unique view of their
virtual process hierarchy that can be quite different from other
controllers.  We now have the freedom and flexibility to create the
right hierarchy for each controller to suit their own needs without
performance loss when compared with cgroup v1.

Signed-off-by: Waiman Long <longman@redhat.com>
---
 Documentation/cgroup-v2.txt | 125 ++++++++++++++++++---
 include/linux/cgroup-defs.h |  11 ++
 kernel/cgroup/cgroup.c      | 263 ++++++++++++++++++++++++++++++++++++++------
 kernel/cgroup/debug.c       |   8 +-
 4 files changed, 359 insertions(+), 48 deletions(-)

diff --git a/Documentation/cgroup-v2.txt b/Documentation/cgroup-v2.txt
index 0f41282..bb27491 100644
--- a/Documentation/cgroup-v2.txt
+++ b/Documentation/cgroup-v2.txt
@@ -308,25 +308,28 @@ both cgroups.
 2-4-1. Enabling and Disabling
 
 Each cgroup has a "cgroup.controllers" file which lists all
-controllers available for the cgroup to enable.
+controllers available for the cgroup to enable for its children.
 
   # cat cgroup.controllers
   cpu io memory
 
-No controller is enabled by default.  Controllers can be enabled and
-disabled by writing to the "cgroup.subtree_control" file.
+No controller is enabled by default.  Controllers can be
+enabled and disabled on the child cgroups by writing to the
+"cgroup.subtree_control" file. A '+' prefix enables the controller,
+and a '-' prefix disables it.
 
   # echo "+cpu +memory -io" > cgroup.subtree_control
 
-Only controllers which are listed in "cgroup.controllers" can be
-enabled.  When multiple operations are specified as above, either they
-all succeed or fail.  If multiple operations on the same controller
-are specified, the last one is effective.
+Only controllers which are listed in "cgroup.controllers" can
+be enabled in the "cgroup.subtree_control" file.  When multiple
+operations are specified as above, either they all succeed or fail.
+If multiple operations on the same controller are specified, the last
+one is effective.
 
 Enabling a controller in a cgroup indicates that the distribution of
 the target resource across its immediate children will be controlled.
-Consider the following sub-hierarchy.  The enabled controllers are
-listed in parentheses.
+Consider the following sub-hierarchy.  The enabled controllers in the
+"cgroup.subtree_control" file are listed in parentheses.
 
   A(cpu,memory) - B(memory) - C()
                             \ D()
@@ -336,6 +339,17 @@ of CPU cycles and memory to its children, in this case, B.  As B has
 "memory" enabled but not "CPU", C and D will compete freely on CPU
 cycles but their division of memory available to B will be controlled.
 
+By not enabling a controller in a cgroup and its descendants, we can
+effectively trim the hierarchy as seen by a controller from the leafs
+up. From the perspective of the cpu controller, the hierarchy is:
+
+  A - B|C|D
+
+From the perspective of the memory controller, the hierarchy becomes:
+
+  A - B - C
+        \ D
+
 As a controller regulates the distribution of the target resource to
 the cgroup's children, enabling it creates the controller's interface
 files in the child cgroups.  In the above example, enabling "cpu" on B
@@ -343,7 +357,81 @@ would create the "cpu." prefixed controller interface files in C and
 D.  Likewise, disabling "memory" from B would remove the "memory."
 prefixed controller interface files from C and D.  This means that the
 controller interface files - anything which doesn't start with
-"cgroup." are owned by the parent rather than the cgroup itself.
+"cgroup." can be considered to be owned by the parent under this
+control scheme.
+
+Enabling controllers via the "cgroup.subtree_control" file is
+relatively coarse-grained.  Fine-grained control of the controllers in
+a non-root cgroup can be done by writing to its "cgroup.controllers"
+file directly. A '+' prefix enables an controller as long as that
+controller is also enabled on its parent. Similarly, the '-' prefix
+disables a controller as long that controller isn't enabled in its
+parent's subtree_control file.
+
+The special prefix '#' is used to mark a controller in pass-through
+mode. In this mode, the controller is disabled in the cgroup
+effectively collapsing it with its parent from the perspective of
+that controller. However, it allows its child cgroups to enable the
+controller or have it in pass-through mode again. For example,
+
+   +   #   #   #   +
+   A - B - C - D - E
+         \ F
+	   +
+In this case, the effective hiearchy is:
+
+	A|B|C|D - E
+	        \ F
+
+Under this control scheme, the interface files can be considered to be
+owned by the cgroup itself. The use of the special '#' prefix allows
+the users to trim away layers in the middle of the hierarchy, thus
+flattening the tree from the perspective of that particular controller.
+As a result, different controllers can have quite different views of
+their virtual process hierarchy that can best fit their own needs.
+
+In the diagram below, the controller name in the parenthesis represents
+controller enabled by writing to the "cgroup.controllers" file.
+
+  A(cpu,memory) - B(cpu,#memory) - C()
+                                 \ D(memory)
+
+From the memory controller's perspective, the hierarchy looks like:
+
+   A|B|C - D
+
+For the CPU controller, the hierarchy is:
+
+   A - B|C|D
+
+Both control schemes can be used together with some limitations
+as shown in the following table about the interaction between
+subtree_control file of the parent of a cgroup and its controllers
+file.
+
+  ++: enable a controller in parent's subtree_control
+  --: disable a controller in parent's subtree_control
+   +: enable a controller in controllers
+   -: disable a controller in controllers
+   #: skip a controller in controllers
+
+  Old State  New Desired State  Result
+  ---------  -----------------  ------
+    ++               +          Ignored
+    ++               #          Accepted
+    ++               -          Rejected*
+    --             + or #       Accepted
+    --               -          Ignored
+     +               ++         Accepted
+     +               --         Rejected
+     -             ++ or --     Accepted
+     #             ++ or --     Rejected
+
+In the special case that the cgroup is in both '++' & '#' states
+('++' followed by '#'), the '-' prefix can be used to turn off the
+'#' leading to an effective '++' state.  A cgroup in '+' or '#' state
+cannot be changed back to '-' or switched to each other as long as
+its children have that controller in a non-'-' state.
 
 
 2-4-2. Top-down Constraint
@@ -353,8 +441,8 @@ a resource only if the resource has been distributed to it from the
 parent.  This means that all non-root "cgroup.subtree_control" files
 can only contain controllers which are enabled in the parent's
 "cgroup.subtree_control" file.  A controller can be enabled only if
-the parent has the controller enabled and a controller can't be
-disabled if one or more children have it enabled.
+the parent has the controller enabled ('+' or '#') and a controller
+can't be disabled if one or more children have it enabled.
 
 
 2-4-3. Managing Internal Process Competition
@@ -704,11 +792,18 @@ All cgroup core files are prefixed with "cgroup."
 
   cgroup.controllers
 
-	A read-only space separated values file which exists on all
+	A read-write space separated values file which exists on all
 	cgroups.
 
-	It shows space separated list of all controllers available to
-	the cgroup.  The controllers are not ordered.
+	When read, it shows space separated list of all controllers
+	available to the cgroup.  The controllers are not ordered.
+
+	Space separated list of controllers prefixed with '+', '-' or
+	'#' can be written to enable, disable or set the controllers
+	in pass-through mode. If a controller appears more than once
+	on the list, the last one is effective.  When multiple enable
+	and disable operations are specified, either all succeed or
+	all fail.
 
   cgroup.subtree_control
 
diff --git a/include/linux/cgroup-defs.h b/include/linux/cgroup-defs.h
index 67ab326..5d30182 100644
--- a/include/linux/cgroup-defs.h
+++ b/include/linux/cgroup-defs.h
@@ -305,6 +305,17 @@ struct cgroup {
 	 */
 	u16 resource_control;
 
+	/*
+	 * The bitmasks of subsystems enabled and in pass-through mode in
+	 * the current cgroup. The parent's subtree_ss_mask has priority.
+	 * A bit set in subtree_ss_mask will suppress the setting of the
+	 * corresponding bit in enable_ss_mask and passthru_ss_mask.
+	 */
+	u16 enable_ss_mask;
+	u16 passthru_ss_mask;
+	u16 old_enable_ss_mask;
+	u16 old_passthru_ss_mask;
+
 	/* Private pointers for each registered subsystem */
 	struct cgroup_subsys_state __rcu *subsys[CGROUP_SUBSYS_COUNT];
 
diff --git a/kernel/cgroup/cgroup.c b/kernel/cgroup/cgroup.c
index c3be7e2..6e77ebe 100644
--- a/kernel/cgroup/cgroup.c
+++ b/kernel/cgroup/cgroup.c
@@ -341,7 +341,7 @@ static u16 cgroup_control(struct cgroup *cgrp)
 	u16 root_ss_mask = cgrp->root->subsys_mask;
 
 	if (parent) {
-		u16 ss_mask = parent->subtree_control;
+		u16 ss_mask = parent->subtree_control|cgrp->enable_ss_mask;
 
 		if (test_bit(CGRP_RESOURCE_DOMAIN, &cgrp->flags))
 			return parent->resource_control;
@@ -363,7 +363,7 @@ static u16 cgroup_ss_mask(struct cgroup *cgrp)
 	struct cgroup *parent = cgroup_parent(cgrp);
 
 	if (parent) {
-		u16 ss_mask = parent->subtree_ss_mask;
+		u16 ss_mask = parent->subtree_ss_mask|cgrp->enable_ss_mask;
 
 		if (test_bit(CGRP_RESOURCE_DOMAIN, &cgrp->flags))
 			return parent->resource_control;
@@ -2540,15 +2540,18 @@ void cgroup_procs_write_finish(struct task_struct *task)
 			ss->post_attach();
 }
 
-static void cgroup_print_ss_mask(struct seq_file *seq, u16 ss_mask)
+static void cgroup_print_ss_mask(struct seq_file *seq, u16 ss_mask,
+				 u16 passthru_mask)
 {
 	struct cgroup_subsys *ss;
 	bool printed = false;
 	int ssid;
 
-	do_each_subsys_mask(ss, ssid, ss_mask) {
+	do_each_subsys_mask(ss, ssid, ss_mask|passthru_mask) {
 		if (printed)
 			seq_putc(seq, ' ');
+		if (passthru_mask & (1 << ssid))
+			seq_putc(seq, '#');
 		seq_printf(seq, "%s", ss->name);
 		printed = true;
 	} while_each_subsys_mask();
@@ -2561,7 +2564,7 @@ static int cgroup_controllers_show(struct seq_file *seq, void *v)
 {
 	struct cgroup *cgrp = seq_css(seq)->cgroup;
 
-	cgroup_print_ss_mask(seq, cgroup_control(cgrp));
+	cgroup_print_ss_mask(seq, cgroup_control(cgrp), cgrp->passthru_ss_mask);
 	return 0;
 }
 
@@ -2570,7 +2573,7 @@ static int cgroup_subtree_control_show(struct seq_file *seq, void *v)
 {
 	struct cgroup *cgrp = seq_css(seq)->cgroup;
 
-	cgroup_print_ss_mask(seq, cgrp->subtree_control);
+	cgroup_print_ss_mask(seq, cgrp->subtree_control, 0);
 	return 0;
 }
 
@@ -2579,7 +2582,7 @@ static int cgroup_resource_control_show(struct seq_file *seq, void *v)
 {
 	struct cgroup *cgrp = seq_css(seq)->cgroup;
 
-	cgroup_print_ss_mask(seq, cgrp->resource_control);
+	cgroup_print_ss_mask(seq, cgrp->resource_control, 0);
 	return 0;
 }
 
@@ -2692,6 +2695,8 @@ static void cgroup_save_control(struct cgroup *cgrp)
 	cgroup_for_each_live_descendant_pre(dsct, d_css, cgrp) {
 		dsct->old_subtree_control = dsct->subtree_control;
 		dsct->old_subtree_ss_mask = dsct->subtree_ss_mask;
+		dsct->old_enable_ss_mask = dsct->enable_ss_mask;
+		dsct->old_passthru_ss_mask = dsct->passthru_ss_mask;
 	}
 }
 
@@ -2709,10 +2714,11 @@ static void cgroup_propagate_control(struct cgroup *cgrp)
 	struct cgroup_subsys_state *d_css;
 
 	cgroup_for_each_live_descendant_pre(dsct, d_css, cgrp) {
-		dsct->subtree_control &= cgroup_control(dsct);
+		dsct->subtree_control &= cgroup_control(dsct)|
+					 dsct->passthru_ss_mask;
 		dsct->subtree_ss_mask =
 			cgroup_calc_subtree_ss_mask(dsct->subtree_control,
-						    cgroup_ss_mask(dsct));
+				cgroup_ss_mask(dsct)|dsct->passthru_ss_mask);
 	}
 }
 
@@ -2731,6 +2737,8 @@ static void cgroup_restore_control(struct cgroup *cgrp)
 	cgroup_for_each_live_descendant_post(dsct, d_css, cgrp) {
 		dsct->subtree_control = dsct->old_subtree_control;
 		dsct->subtree_ss_mask = dsct->old_subtree_ss_mask;
+		dsct->enable_ss_mask = dsct->old_enable_ss_mask;
+		dsct->passthru_ss_mask = dsct->old_passthru_ss_mask;
 	}
 }
 
@@ -2772,7 +2780,8 @@ static int cgroup_apply_control_enable(struct cgroup *cgrp)
 
 			WARN_ON_ONCE(css && percpu_ref_is_dying(&css->refcnt));
 
-			if (!(cgroup_ss_mask(dsct) & (1 << ss->id)))
+			if (!(cgroup_ss_mask(dsct) & (1 << ss->id)) ||
+			    (dsct->passthru_ss_mask & (1 << ss->id)))
 				continue;
 
 			if (!css) {
@@ -2822,7 +2831,8 @@ static void cgroup_apply_control_disable(struct cgroup *cgrp)
 				continue;
 
 			if (css->parent &&
-			    !(cgroup_ss_mask(dsct) & (1 << ss->id))) {
+			    (!(cgroup_ss_mask(dsct) & (1 << ss->id)) ||
+			    (dsct->passthru_ss_mask & (1 << ss->id)))) {
 				kill_css(css);
 			} else if (!css_visible(css)) {
 				css_clear_dir(css);
@@ -2895,7 +2905,8 @@ static ssize_t cgroup_subtree_control_write(struct kernfs_open_file *of,
 					    loff_t off)
 {
 	u16 enable = 0, disable = 0;
-	struct cgroup *cgrp, *child;
+	u16 child_enable, child_passthru = 0;
+	struct cgroup *cgrp, *child, *grandchild;
 	struct cgroup_subsys *ss;
 	char *tok;
 	int ssid, ret;
@@ -2933,22 +2944,36 @@ static ssize_t cgroup_subtree_control_write(struct kernfs_open_file *of,
 		return -ENODEV;
 
 	/*
-	 * We cannot disable controllers that are enabled in a child
-	 * cgroup.
+	 * Because a controller can be enabled on a grandchild if it is
+	 * enabled in subtree_control, we need to look at all the children
+	 * and grandchildren for what are enabled.
 	 */
-	if (disable) {
-		u16 child_enable = cgrp->resource_control;
+	child_enable = cgrp->resource_control;
+	cgroup_for_each_live_child(child, cgrp) {
+		child_enable |= child->subtree_control|
+				child->resource_control|
+				child->enable_ss_mask;
+		child_passthru |= child->passthru_ss_mask;
+
+		cgroup_for_each_live_child(grandchild, child)
+			child_enable |= grandchild->subtree_control|
+					grandchild->resource_control|
+					grandchild->enable_ss_mask|
+					grandchild->passthru_ss_mask;
+	}
 
-		cgroup_for_each_live_child(child, cgrp)
-			child_enable |= child->subtree_control|
-					child->resource_control;
-		if (disable & child_enable) {
-			ret = -EBUSY;
-			goto out_unlock;
-		}
+	/*
+	 * We cannot disable controllers that are enabled or in pass-through
+	 * mode in a child or grandchild cgroup. We also cannot enable
+	 * controllers that are in pass-through mode in a child cgroup.
+	 */
+	if ((disable & (child_enable|child_passthru)) ||
+	    (enable  & child_passthru)) {
+		ret = -EBUSY;
+		goto out_unlock;
 	}
 
-	if (enable & ~cgroup_control(cgrp)) {
+	if (enable & ~(cgroup_control(cgrp)|cgrp->passthru_ss_mask)) {
 		ret = -ENOENT;
 		goto out_unlock;
 	}
@@ -2963,7 +2988,7 @@ static ssize_t cgroup_subtree_control_write(struct kernfs_open_file *of,
 
 	/* can't enable !threaded controllers on a threaded cgroup */
 	if (cgroup_is_threaded(cgrp) && (enable & ~cgrp_dfl_threaded_ss_mask)) {
-		ret = -EBUSY;
+		ret = -EINVAL;
 		goto out_unlock;
 	}
 
@@ -2973,6 +2998,164 @@ static ssize_t cgroup_subtree_control_write(struct kernfs_open_file *of,
 	cgrp->subtree_control |= enable;
 	cgrp->subtree_control &= ~disable;
 
+	/*
+	 * Clear the child's enable_ss_mask for those bits that are enabled
+	 * in subtree_control.
+	 */
+	if (child_enable & enable) {
+		cgroup_for_each_live_child(child, cgrp)
+			child->enable_ss_mask &= ~enable;
+	}
+
+	ret = cgroup_apply_control(cgrp);
+
+	cgroup_finalize_control(cgrp, ret);
+
+	kernfs_activate(cgrp->kn);
+	ret = 0;
+out_unlock:
+	cgroup_kn_unlock(of->kn);
+	return ret ?: nbytes;
+}
+
+/*
+ * Change the enabled and pass-through controllers for a cgroup in the
+ * default hierarchy
+ */
+static ssize_t cgroup_controllers_write(struct kernfs_open_file *of,
+					char *buf, size_t nbytes,
+					loff_t off)
+{
+	u16 enable = 0, disable = 0, passthru = 0;
+	u16 child_enable, parent_subtree;
+	struct cgroup *cgrp, *child, *parent;
+	struct cgroup_subsys *ss;
+	char *tok;
+	int ssid, ret;
+
+	/*
+	 * Parse input - space separated list of subsystem names prefixed
+	 * with either +, - or #.
+	 */
+	buf = strstrip(buf);
+	while ((tok = strsep(&buf, " "))) {
+		if (tok[0] == '\0')
+			continue;
+		do_each_subsys_mask(ss, ssid, ~cgrp_dfl_inhibit_ss_mask) {
+			if (!cgroup_ssid_enabled(ssid) ||
+			    strcmp(tok + 1, ss->name))
+				continue;
+
+			if (*tok == '+') {
+				enable |= 1 << ssid;
+				disable &= ~(1 << ssid);
+				passthru &= ~(1 << ssid);
+			} else if (*tok == '-') {
+				disable |= 1 << ssid;
+				enable &= ~(1 << ssid);
+				passthru &= ~(1 << ssid);
+			} else if (*tok == '#') {
+				passthru |= 1 << ssid;
+				enable &= ~(1 << ssid);
+				disable &= ~(1 << ssid);
+			} else {
+				return -EINVAL;
+			}
+			break;
+		} while_each_subsys_mask();
+		if (ssid == CGROUP_SUBSYS_COUNT)
+			return -EINVAL;
+	}
+
+	cgrp = cgroup_kn_lock_live(of->kn, true);
+	if (!cgrp)
+		return -ENODEV;
+
+	/*
+	 * Write to root cgroup's controllers file is not allowed.
+	 */
+	parent = cgroup_parent(cgrp);
+	if (!parent) {
+		ret = -EINVAL;
+		goto out_unlock;
+	}
+
+	/*
+	 * We only looks at parent's subtree_control that are not in
+	 * passthru_ss_mask.
+	 */
+	parent_subtree = parent->subtree_control & ~cgrp->passthru_ss_mask;
+
+	/*
+	 * Reject disable bits that are in parent's subtree_control except
+	 * when they are also in passthru_ss_mask.
+	 */
+	if (disable & parent_subtree) {
+		ret = -EINVAL;
+		goto out_unlock;
+	}
+
+	child_enable = cgrp->resource_control|cgrp->subtree_control;
+	cgroup_for_each_live_child(child, cgrp)
+		child_enable |= child->subtree_control|child->resource_control|
+				child->enable_ss_mask|child->passthru_ss_mask;
+
+	/*
+	 * Mask off bits that have been set as well as enable bits set
+	 * in parent's subtree_control, but not in passthru_ss_mask.
+	 */
+	passthru &= ~cgrp->passthru_ss_mask;
+	enable   &= ~(cgrp->enable_ss_mask|parent_subtree);
+
+	/*
+	 * We cannot enable, disable or pass-through controllers that
+	 * are enabled in children's passthru_ss_mask, enable_ss_mask,
+	 * resource_control or subtree_control as well as its own
+	 * resource_control and subtree_control.
+	 */
+	if ((disable|passthru|enable) & child_enable) {
+		ret = -EBUSY;
+		goto out_unlock;
+	}
+
+	/*
+	 * We also cannot enable or pass through controllers that are not
+	 * enabled in its parent's passthru_ss_mask or controllers.
+	 */
+	if (((enable|passthru) & (parent->passthru_ss_mask|
+				  cgroup_control(parent)))
+				  != (enable|passthru)) {
+		ret = -ENOENT;
+		goto out_unlock;
+	}
+
+	disable &= cgrp->enable_ss_mask|cgrp->passthru_ss_mask;
+	if (!enable && !disable && !passthru) {
+		ret = 0;
+		goto out_unlock;
+	}
+
+	/*
+	 * Can't enable or pass through !threaded controllers on a
+	 * threaded cgroup
+	 */
+	if (cgroup_is_threaded(cgrp) &&
+	   ((enable|passthru) & ~cgrp_dfl_threaded_ss_mask)) {
+		ret = -EINVAL;
+		goto out_unlock;
+	}
+
+	/* Save and update control masks and prepare csses */
+	cgroup_save_control(cgrp);
+
+	cgrp->passthru_ss_mask |= passthru;
+	cgrp->passthru_ss_mask &= ~(disable|enable);
+
+	/* Mask off enable bits set in parent's subtree_control */
+	enable &= ~parent->subtree_control;
+	cgrp->enable_ss_mask |= enable;
+	cgrp->enable_ss_mask &= ~(disable|passthru);
+
 	ret = cgroup_apply_control(cgrp);
 
 	cgroup_finalize_control(cgrp, ret);
@@ -3102,7 +3285,8 @@ static int cgroup_enable_threaded(struct cgroup *cgrp)
 	/*
 	 * Allow only if it is not the root and there are:
 	 * 1) no children,
-	 * 2) no non-threaded controllers are enabled, and
+	 * 2) no non-threaded controllers are enabled or in pass-through
+	 *    mode, and
 	 * 3) no attached tasks.
 	 *
 	 * With no attached tasks, it is assumed that no css_sets will be
@@ -3110,7 +3294,8 @@ static int cgroup_enable_threaded(struct cgroup *cgrp)
 	 * css_sets linger around due to task_struct leakage, for example.
 	 */
 	if (css_has_online_children(&cgrp->self) ||
-	   (cgroup_control(cgrp) & ~cgrp_dfl_threaded_ss_mask) ||
+	   ((cgroup_control(cgrp)|cgrp->passthru_ss_mask)
+		& ~cgrp_dfl_threaded_ss_mask) ||
 	   !cgroup_parent(cgrp) || cgroup_is_populated(cgrp))
 		return -EBUSY;
 
@@ -4375,6 +4560,7 @@ static ssize_t cgroup_threads_write(struct kernfs_open_file *of,
 	{
 		.name = "cgroup.controllers",
 		.seq_show = cgroup_controllers_show,
+		.write = cgroup_controllers_write,
 	},
 	{
 		.name = "cgroup.subtree_control",
@@ -4526,7 +4712,8 @@ static void css_release(struct percpu_ref *ref)
 }
 
 static void init_and_link_css(struct cgroup_subsys_state *css,
-			      struct cgroup_subsys *ss, struct cgroup *cgrp)
+			      struct cgroup_subsys *ss, struct cgroup *cgrp,
+			      struct cgroup_subsys_state *parent_css)
 {
 	lockdep_assert_held(&cgroup_mutex);
 
@@ -4542,7 +4729,7 @@ static void init_and_link_css(struct cgroup_subsys_state *css,
 	atomic_set(&css->online_cnt, 0);
 
 	if (cgroup_parent(cgrp)) {
-		css->parent = cgroup_css(cgroup_parent(cgrp), ss);
+		css->parent = parent_css;
 		css_get(css->parent);
 	}
 
@@ -4605,19 +4792,31 @@ static struct cgroup_subsys_state *css_create(struct cgroup *cgrp,
 					      struct cgroup_subsys *ss)
 {
 	struct cgroup *parent = cgroup_parent(cgrp);
-	struct cgroup_subsys_state *parent_css = cgroup_css(parent, ss);
+	struct cgroup_subsys_state *parent_css;
 	struct cgroup_subsys_state *css;
 	int err;
 
 	lockdep_assert_held(&cgroup_mutex);
 
+	/*
+	 * Need to skip over ancestor cgroups with skip flag set.
+	 */
+	while (parent && (parent->passthru_ss_mask & (1 << ss->id)))
+		parent = cgroup_parent(parent);
+
+	if (!parent) {
+		WARN_ON_ONCE(1);
+		return ERR_PTR(-EINVAL);
+	}
+	parent_css = cgroup_css(parent, ss);
+
 	css = ss->css_alloc(parent_css);
 	if (!css)
 		css = ERR_PTR(-ENOMEM);
 	if (IS_ERR(css))
 		return css;
 
-	init_and_link_css(css, ss, cgrp);
+	init_and_link_css(css, ss, cgrp, parent_css);
 
 	err = percpu_ref_init(&css->refcnt, css_release, 0, GFP_KERNEL);
 	if (err)
@@ -5044,7 +5243,7 @@ static void __init cgroup_init_subsys(struct cgroup_subsys *ss, bool early)
 	css = ss->css_alloc(cgroup_css(&cgrp_dfl_root.cgrp, ss));
 	/* We don't handle early failures gracefully */
 	BUG_ON(IS_ERR(css));
-	init_and_link_css(css, ss, &cgrp_dfl_root.cgrp);
+	init_and_link_css(css, ss, &cgrp_dfl_root.cgrp, NULL);
 
 	/*
 	 * Root csses are never destroyed and we can't initialize
diff --git a/kernel/cgroup/debug.c b/kernel/cgroup/debug.c
index b565951..a2dbf77 100644
--- a/kernel/cgroup/debug.c
+++ b/kernel/cgroup/debug.c
@@ -212,8 +212,12 @@ static int cgroup_subsys_states_read(struct seq_file *seq, void *v)
 	mutex_lock(&cgroup_mutex);
 	for_each_subsys(ss, i) {
 		css = rcu_dereference_check(cgrp->subsys[ss->id], true);
-		if (!css)
+		if (!css) {
+			if (cgrp->passthru_ss_mask & (1 << ss->id))
+				seq_printf(seq, "%2d: %-4s\t- [Pass-through]\n",
+					   ss->id, ss->name);
 			continue;
+		}
 		pbuf[0] = '\0';
 
 		/* Show the parent CSS if applicable*/
@@ -240,6 +244,8 @@ static int cgroup_masks_read(struct seq_file *seq, void *v)
 		{ &cgrp->subtree_control,  "subtree_control"  },
 		{ &cgrp->subtree_ss_mask,  "subtree_ss_mask"  },
 		{ &cgrp->resource_control, "resource_control" },
+		{ &cgrp->enable_ss_mask,   "enable_ss_mask"   },
+		{ &cgrp->passthru_ss_mask, "passthru_ss_mask" },
 	};
 
 	mutex_lock(&cgroup_mutex);
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
