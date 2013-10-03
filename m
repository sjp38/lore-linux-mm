Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 2FA926B005C
	for <linux-mm@kvack.org>; Wed,  2 Oct 2013 20:52:23 -0400 (EDT)
Received: by mail-pd0-f169.google.com with SMTP id r10so1686607pdi.28
        for <linux-mm@kvack.org>; Wed, 02 Oct 2013 17:52:22 -0700 (PDT)
Received: by mail-pd0-f177.google.com with SMTP id y10so1663541pdj.36
        for <linux-mm@kvack.org>; Wed, 02 Oct 2013 17:52:20 -0700 (PDT)
From: John Stultz <john.stultz@linaro.org>
Subject: [PATCH 09/14] vrange: Add vrange LRU list for purging
Date: Wed,  2 Oct 2013 17:51:38 -0700
Message-Id: <1380761503-14509-10-git-send-email-john.stultz@linaro.org>
In-Reply-To: <1380761503-14509-1-git-send-email-john.stultz@linaro.org>
References: <1380761503-14509-1-git-send-email-john.stultz@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Andrea Righi <andrea@betterlinux.com>, Andrea Arcangeli <aarcange@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Dhaval Giani <dhaval.giani@gmail.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Rob Clark <robdclark@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, John Stultz <john.stultz@linaro.org>

From: Minchan Kim <minchan@kernel.org>

This patch adds vrange LRU list for managing vranges to purge by
something (In this implementation, I will use slab shrinker introduced
by upcoming patches).

This is necessary to purge vranges on swapless system because currently
the VM only ages anonymous pages if the system has a swap device.

In this case, because we would otherwise be duplicating the page LRUs
tracking of hot/cold pages, we utilize a vrange LRU, to manage the
shrinking order. Thus the shrinker will discard the entire vrange at
once, and vranges are purged in the order they are marked volatile.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Android Kernel Team <kernel-team@android.com>
Cc: Robert Love <rlove@google.com>
Cc: Mel Gorman <mel@csn.ul.ie>
Cc: Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Dmitry Adamushko <dmitry.adamushko@gmail.com>
Cc: Dave Chinner <david@fromorbit.com>
Cc: Neil Brown <neilb@suse.de>
Cc: Andrea Righi <andrea@betterlinux.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
Cc: Mike Hommey <mh@glandium.org>
Cc: Taras Glek <tglek@mozilla.com>
Cc: Dhaval Giani <dhaval.giani@gmail.com>
Cc: Jan Kara <jack@suse.cz>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Michel Lespinasse <walken@google.com>
Cc: Rob Clark <robdclark@gmail.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org <linux-mm@kvack.org>
Signed-off-by: Minchan Kim <minchan@kernel.org>
Signed-off-by: John Stultz <john.stultz@linaro.org>
---
 include/linux/vrange_types.h |  2 ++
 mm/vrange.c                  | 61 ++++++++++++++++++++++++++++++++++++++++----
 2 files changed, 58 insertions(+), 5 deletions(-)

diff --git a/include/linux/vrange_types.h b/include/linux/vrange_types.h
index 0d48b42..d7d451c 100644
--- a/include/linux/vrange_types.h
+++ b/include/linux/vrange_types.h
@@ -20,6 +20,8 @@ struct vrange {
 	struct interval_tree_node node;
 	struct vrange_root *owner;
 	int purged;
+	struct list_head lru;
+	atomic_t refcount;
 };
 #endif
 
diff --git a/mm/vrange.c b/mm/vrange.c
index c19a966..33e3ac1 100644
--- a/mm/vrange.c
+++ b/mm/vrange.c
@@ -14,8 +14,21 @@
 
 static struct kmem_cache *vrange_cachep;
 
+static struct vrange_list {
+	struct list_head list;
+	unsigned long size;
+	struct mutex lock;
+} vrange_list;
+
+static inline unsigned int vrange_size(struct vrange *range)
+{
+	return range->node.last + 1 - range->node.start;
+}
+
 static int __init vrange_init(void)
 {
+	INIT_LIST_HEAD(&vrange_list.list);
+	mutex_init(&vrange_list.lock);
 	vrange_cachep = KMEM_CACHE(vrange, SLAB_PANIC);
 	return 0;
 }
@@ -27,19 +40,56 @@ static struct vrange *__vrange_alloc(gfp_t flags)
 	if (!vrange)
 		return vrange;
 	vrange->owner = NULL;
+	INIT_LIST_HEAD(&vrange->lru);
+	atomic_set(&vrange->refcount, 1);
+
 	return vrange;
 }
 
 static void __vrange_free(struct vrange *range)
 {
 	WARN_ON(range->owner);
+	WARN_ON(atomic_read(&range->refcount) != 0);
+	WARN_ON(!list_empty(&range->lru));
+
 	kmem_cache_free(vrange_cachep, range);
 }
 
+static inline void __vrange_lru_add(struct vrange *range)
+{
+	mutex_lock(&vrange_list.lock);
+	WARN_ON(!list_empty(&range->lru));
+	list_add(&range->lru, &vrange_list.list);
+	vrange_list.size += vrange_size(range);
+	mutex_unlock(&vrange_list.lock);
+}
+
+static inline void __vrange_lru_del(struct vrange *range)
+{
+	mutex_lock(&vrange_list.lock);
+	if (!list_empty(&range->lru)) {
+		list_del_init(&range->lru);
+		vrange_list.size -= vrange_size(range);
+		WARN_ON(range->owner);
+	}
+	mutex_unlock(&vrange_list.lock);
+}
+
 static void __vrange_add(struct vrange *range, struct vrange_root *vroot)
 {
 	range->owner = vroot;
 	interval_tree_insert(&range->node, &vroot->v_rb);
+
+	WARN_ON(atomic_read(&range->refcount) <= 0);
+	__vrange_lru_add(range);
+}
+
+static inline void __vrange_put(struct vrange *range)
+{
+	if (atomic_dec_and_test(&range->refcount)) {
+		__vrange_lru_del(range);
+		__vrange_free(range);
+	}
 }
 
 static void __vrange_remove(struct vrange *range)
@@ -64,6 +114,7 @@ static inline void __vrange_resize(struct vrange *range,
 	bool purged = range->purged;
 
 	__vrange_remove(range);
+	__vrange_lru_del(range);
 	__vrange_set(range, start_idx, end_idx, purged);
 	__vrange_add(range, vroot);
 }
@@ -100,7 +151,7 @@ static int vrange_add(struct vrange_root *vroot,
 		range = vrange_from_node(node);
 		/* old range covers new range fully */
 		if (node->start <= start_idx && node->last >= end_idx) {
-			__vrange_free(new_range);
+			__vrange_put(new_range);
 			goto out;
 		}
 
@@ -109,7 +160,7 @@ static int vrange_add(struct vrange_root *vroot,
 		purged |= range->purged;
 
 		__vrange_remove(range);
-		__vrange_free(range);
+		__vrange_put(range);
 
 		node = next;
 	}
@@ -150,7 +201,7 @@ static int vrange_remove(struct vrange_root *vroot,
 		if (start_idx <= node->start && end_idx >= node->last) {
 			/* argumented range covers the range fully */
 			__vrange_remove(range);
-			__vrange_free(range);
+			__vrange_put(range);
 		} else if (node->start >= start_idx) {
 			/*
 			 * Argumented range covers over the left of the
@@ -181,7 +232,7 @@ static int vrange_remove(struct vrange_root *vroot,
 	vrange_unlock(vroot);
 
 	if (!used_new)
-		__vrange_free(new_range);
+		__vrange_put(new_range);
 
 	return 0;
 }
@@ -204,7 +255,7 @@ void vrange_root_cleanup(struct vrange_root *vroot)
 	while ((node = rb_first(&vroot->v_rb))) {
 		range = vrange_entry(node);
 		__vrange_remove(range);
-		__vrange_free(range);
+		__vrange_put(range);
 	}
 	vrange_unlock(vroot);
 }
-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
