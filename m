Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 6F67F6200BD
	for <linux-mm@kvack.org>; Sat,  8 May 2010 20:12:18 -0400 (EDT)
Received: by fg-out-1718.google.com with SMTP id 19so217031fgg.8
        for <linux-mm@kvack.org>; Sat, 08 May 2010 17:12:15 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: [RFC] [PATCH] memcg: cleanup memory thresholds
Date: Sun,  9 May 2010 03:11:12 +0300
Message-Id: <1273363872-8031-1-git-send-email-kirill@shutemov.name>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, containers@lists.linux-foundation.org
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, Phil Carmody <ext-phil.2.carmody@nokia.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Introduce struct mem_cgroup_thresholds. It helps to reduce number of
checks of thresholds type (memory or mem+swap).

Signed-off-by: Kirill A. Shutemov <kirill@shutemov.name>
---
 mm/memcontrol.c |  151 ++++++++++++++++++++++++-------------------------------
 1 files changed, 66 insertions(+), 85 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index a6d2a4c..a6c6268 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -158,6 +158,18 @@ struct mem_cgroup_threshold_ary {
 	/* Array of thresholds */
 	struct mem_cgroup_threshold entries[0];
 };
+
+struct mem_cgroup_thresholds {
+	/* Primary thresholds array */
+	struct mem_cgroup_threshold_ary *primary;
+	/*
+	 * Spare threshold array.
+	 * It needed to make mem_cgroup_unregister_event() "never fail".
+	 * It must be able to store at least primary->size - 1 entires.
+	 */
+	struct mem_cgroup_threshold_ary *spare;
+};
+
 /* for OOM */
 struct mem_cgroup_eventfd_list {
 	struct list_head list;
@@ -224,20 +236,10 @@ struct mem_cgroup {
 	struct mutex thresholds_lock;
 
 	/* thresholds for memory usage. RCU-protected */
-	struct mem_cgroup_threshold_ary *thresholds;
-
-	/*
-	 * Preallocated buffer to be used in mem_cgroup_unregister_event()
-	 * to make it "never fail".
-	 * It must be able to store at least thresholds->size - 1 entries.
-	 */
-	struct mem_cgroup_threshold_ary *__thresholds;
+	struct mem_cgroup_thresholds thresholds;
 
 	/* thresholds for mem+swap usage. RCU-protected */
-	struct mem_cgroup_threshold_ary *memsw_thresholds;
-
-	/* the same as __thresholds, but for memsw_thresholds */
-	struct mem_cgroup_threshold_ary *__memsw_thresholds;
+	struct mem_cgroup_thresholds memsw_thresholds;
 
 	/* For oom notifier event fd */
 	struct list_head oom_notify;
@@ -3438,9 +3440,9 @@ static void __mem_cgroup_threshold(struct mem_cgroup *memcg, bool swap)
 
 	rcu_read_lock();
 	if (!swap)
-		t = rcu_dereference(memcg->thresholds);
+		t = rcu_dereference(memcg->thresholds.primary);
 	else
-		t = rcu_dereference(memcg->memsw_thresholds);
+		t = rcu_dereference(memcg->memsw_thresholds.primary);
 
 	if (!t)
 		goto unlock;
@@ -3514,91 +3516,78 @@ static int mem_cgroup_usage_register_event(struct cgroup *cgrp,
 	struct cftype *cft, struct eventfd_ctx *eventfd, const char *args)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
-	struct mem_cgroup_threshold_ary *thresholds, *thresholds_new;
+	struct mem_cgroup_thresholds *thresholds;
+	struct mem_cgroup_threshold_ary *new;
 	int type = MEMFILE_TYPE(cft->private);
 	u64 threshold, usage;
-	int size;
-	int i, ret;
+	int i, size, ret;
 
 	ret = res_counter_memparse_write_strategy(args, &threshold);
 	if (ret)
 		return ret;
 
 	mutex_lock(&memcg->thresholds_lock);
+
 	if (type == _MEM)
-		thresholds = memcg->thresholds;
+		thresholds = &memcg->thresholds;
 	else if (type == _MEMSWAP)
-		thresholds = memcg->memsw_thresholds;
+		thresholds = &memcg->memsw_thresholds;
 	else
 		BUG();
 
 	usage = mem_cgroup_usage(memcg, type == _MEMSWAP);
 
 	/* Check if a threshold crossed before adding a new one */
-	if (thresholds)
+	if (thresholds->primary)
 		__mem_cgroup_threshold(memcg, type == _MEMSWAP);
 
-	if (thresholds)
-		size = thresholds->size + 1;
-	else
-		size = 1;
+	size = thresholds->primary ? thresholds->primary->size + 1 : 1;
 
 	/* Allocate memory for new array of thresholds */
-	thresholds_new = kmalloc(sizeof(*thresholds_new) +
-			size * sizeof(struct mem_cgroup_threshold),
+	new = kmalloc(sizeof(*new) + size * sizeof(struct mem_cgroup_threshold),
 			GFP_KERNEL);
-	if (!thresholds_new) {
+	if (!new) {
 		ret = -ENOMEM;
 		goto unlock;
 	}
-	thresholds_new->size = size;
+	new->size = size;
 
 	/* Copy thresholds (if any) to new array */
-	if (thresholds)
-		memcpy(thresholds_new->entries, thresholds->entries,
-				thresholds->size *
+	if (thresholds->primary) {
+		memcpy(new->entries, thresholds->primary->entries, (size - 1) *
 				sizeof(struct mem_cgroup_threshold));
+	}
+
 	/* Add new threshold */
-	thresholds_new->entries[size - 1].eventfd = eventfd;
-	thresholds_new->entries[size - 1].threshold = threshold;
+	new->entries[size - 1].eventfd = eventfd;
+	new->entries[size - 1].threshold = threshold;
 
 	/* Sort thresholds. Registering of new threshold isn't time-critical */
-	sort(thresholds_new->entries, size,
-			sizeof(struct mem_cgroup_threshold),
+	sort(new->entries, size, sizeof(struct mem_cgroup_threshold),
 			compare_thresholds, NULL);
 
 	/* Find current threshold */
-	thresholds_new->current_threshold = -1;
+	new->current_threshold = -1;
 	for (i = 0; i < size; i++) {
-		if (thresholds_new->entries[i].threshold < usage) {
+		if (new->entries[i].threshold < usage) {
 			/*
-			 * thresholds_new->current_threshold will not be used
-			 * until rcu_assign_pointer(), so it's safe to increment
+			 * new->current_threshold will not be used until
+			 * rcu_assign_pointer(), so it's safe to increment
 			 * it here.
 			 */
-			++thresholds_new->current_threshold;
+			++new->current_threshold;
 		}
 	}
 
-	if (type == _MEM)
-		rcu_assign_pointer(memcg->thresholds, thresholds_new);
-	else
-		rcu_assign_pointer(memcg->memsw_thresholds, thresholds_new);
+	/* Free old spare buffer and save old primary buffer as spare */
+	kfree(thresholds->spare);
+	thresholds->spare = thresholds->primary;
+
+	rcu_assign_pointer(thresholds->primary, new);
 
 	/* To be sure that nobody uses thresholds */
 	synchronize_rcu();
 
-	/*
-	 * Free old preallocated buffer and use thresholds as new
-	 * preallocated buffer.
-	 */
-	if (type == _MEM) {
-		kfree(memcg->__thresholds);
-		memcg->__thresholds = thresholds;
-	} else {
-		kfree(memcg->__memsw_thresholds);
-		memcg->__memsw_thresholds = thresholds;
-	}
 unlock:
 	mutex_unlock(&memcg->thresholds_lock);
 
@@ -3609,17 +3598,17 @@ static void mem_cgroup_usage_unregister_event(struct cgroup *cgrp,
 	struct cftype *cft, struct eventfd_ctx *eventfd)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
-	struct mem_cgroup_threshold_ary *thresholds, *thresholds_new;
+	struct mem_cgroup_thresholds *thresholds;
+	struct mem_cgroup_threshold_ary *new;
 	int type = MEMFILE_TYPE(cft->private);
 	u64 usage;
-	int size = 0;
-	int i, j;
+	int i, j, size;
 
 	mutex_lock(&memcg->thresholds_lock);
 	if (type == _MEM)
-		thresholds = memcg->thresholds;
+		thresholds = &memcg->thresholds;
 	else if (type == _MEMSWAP)
-		thresholds = memcg->memsw_thresholds;
+		thresholds = &memcg->memsw_thresholds;
 	else
 		BUG();
 
@@ -3635,53 +3624,45 @@ static void mem_cgroup_usage_unregister_event(struct cgroup *cgrp,
 	__mem_cgroup_threshold(memcg, type == _MEMSWAP);
 
 	/* Calculate new number of threshold */
-	for (i = 0; i < thresholds->size; i++) {
-		if (thresholds->entries[i].eventfd != eventfd)
+	size = 0;
+	for (i = 0; i < thresholds->primary->size; i++) {
+		if (thresholds->primary->entries[i].eventfd != eventfd)
 			size++;
 	}
 
-	/* Use preallocated buffer for new array of thresholds */
-	if (type == _MEM)
-		thresholds_new = memcg->__thresholds;
-	else
-		thresholds_new = memcg->__memsw_thresholds;
+	new = thresholds->spare;
 
 	/* Set thresholds array to NULL if we don't have thresholds */
 	if (!size) {
-		kfree(thresholds_new);
-		thresholds_new = NULL;
+		kfree(new);
+		new = NULL;
 		goto swap_buffers;
 	}
 
-	thresholds_new->size = size;
+	new->size = size;
 
 	/* Copy thresholds and find current threshold */
-	thresholds_new->current_threshold = -1;
-	for (i = 0, j = 0; i < thresholds->size; i++) {
-		if (thresholds->entries[i].eventfd == eventfd)
+	new->current_threshold = -1;
+	for (i = 0, j = 0; i < thresholds->primary->size; i++) {
+		if (thresholds->primary->entries[i].eventfd == eventfd)
 			continue;
 
-		thresholds_new->entries[j] = thresholds->entries[i];
-		if (thresholds_new->entries[j].threshold < usage) {
+		new->entries[j] = thresholds->primary->entries[i];
+		if (new->entries[j].threshold < usage) {
 			/*
-			 * thresholds_new->current_threshold will not be used
+			 * new->current_threshold will not be used
 			 * until rcu_assign_pointer(), so it's safe to increment
 			 * it here.
 			 */
-			++thresholds_new->current_threshold;
+			++new->current_threshold;
 		}
 		j++;
 	}
 
 swap_buffers:
-	/* Swap thresholds array and preallocated buffer */
-	if (type == _MEM) {
-		memcg->__thresholds = thresholds;
-		rcu_assign_pointer(memcg->thresholds, thresholds_new);
-	} else {
-		memcg->__memsw_thresholds = thresholds;
-		rcu_assign_pointer(memcg->memsw_thresholds, thresholds_new);
-	}
+	/* Swap primary and spare array */
+	thresholds->spare = thresholds->primary;
+	rcu_assign_pointer(thresholds->primary, new);
 
 	/* To be sure that nobody uses thresholds */
 	synchronize_rcu();
-- 
1.7.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
