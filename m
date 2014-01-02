Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f46.google.com (mail-pb0-f46.google.com [209.85.160.46])
	by kanga.kvack.org (Postfix) with ESMTP id DC5526B006C
	for <linux-mm@kvack.org>; Thu,  2 Jan 2014 02:13:22 -0500 (EST)
Received: by mail-pb0-f46.google.com with SMTP id md12so14229048pbc.33
        for <linux-mm@kvack.org>; Wed, 01 Jan 2014 23:13:22 -0800 (PST)
Received: from LGEMRELSE7Q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id wm3si41543615pab.194.2014.01.01.23.13.19
        for <linux-mm@kvack.org>;
        Wed, 01 Jan 2014 23:13:20 -0800 (PST)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v10 14/16] vrange: Change purged with hint
Date: Thu,  2 Jan 2014 16:12:22 +0900
Message-Id: <1388646744-15608-15-git-send-email-minchan@kernel.org>
In-Reply-To: <1388646744-15608-1-git-send-email-minchan@kernel.org>
References: <1388646744-15608-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Michel Lespinasse <walken@google.com>, Johannes Weiner <hannes@cmpxchg.org>, John Stultz <john.stultz@linaro.org>, Dhaval Giani <dhaval.giani@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Andrea Righi <andrea@betterlinux.com>, Andrea Arcangeli <aarcange@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Rob Clark <robdclark@gmail.com>, Jason Evans <je@fb.com>, Minchan Kim <minchan@kernel.org>

struct vrange has a purged field which is just flag to express
the range was purged or not so what we need is just a bit.
It means it's too bloated.

This patch changes the name with hint so upcoming patch will use
other extra bitfield for other purpose.

Cc: Mel Gorman <mel@csn.ul.ie>
Cc: Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Michel Lespinasse <walken@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: John Stultz <john.stultz@linaro.org>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 include/linux/vrange_types.h |    3 ++-
 mm/vrange.c                  |   39 ++++++++++++++++++++++++++++++---------
 2 files changed, 32 insertions(+), 10 deletions(-)

diff --git a/include/linux/vrange_types.h b/include/linux/vrange_types.h
index c4ef8b69a0a1..d42b0e7d7343 100644
--- a/include/linux/vrange_types.h
+++ b/include/linux/vrange_types.h
@@ -20,7 +20,8 @@ struct vrange_root {
 struct vrange {
 	struct interval_tree_node node;
 	struct vrange_root *owner;
-	int purged;
+	/* purged */
+	unsigned long hint;
 	struct list_head lru;
 	atomic_t refcount;
 };
diff --git a/mm/vrange.c b/mm/vrange.c
index 4e0775b722af..df01c6b084bf 100644
--- a/mm/vrange.c
+++ b/mm/vrange.c
@@ -29,6 +29,24 @@ struct vrange_walker {
 	struct list_head *pagelist;
 };
 
+#define VRANGE_PURGED_MARK	0
+
+void mark_purge(struct vrange *range)
+{
+	range->hint |= (1 << VRANGE_PURGED_MARK);
+}
+
+void clear_purge(struct vrange *range)
+{
+	range->hint &= ~(1 << VRANGE_PURGED_MARK);
+}
+
+bool vrange_purged(struct vrange *range)
+{
+	bool purged = range->hint & (1 << VRANGE_PURGED_MARK);
+	return purged;
+}
+
 static inline unsigned long vrange_size(struct vrange *range)
 {
 	return range->node.last + 1 - range->node.start;
@@ -217,7 +235,7 @@ static struct vrange *__vrange_alloc(gfp_t flags)
 		return vrange;
 
 	vrange->owner = NULL;
-	vrange->purged = 0;
+	vrange->hint = 0;
 	INIT_LIST_HEAD(&vrange->lru);
 	atomic_set(&vrange->refcount, 1);
 
@@ -288,14 +306,17 @@ static inline void __vrange_set(struct vrange *range,
 {
 	range->node.start = start_idx;
 	range->node.last = end_idx;
-	range->purged = purged;
+	if (purged)
+		mark_purge(range);
+	else
+		clear_purge(range);
 }
 
 static inline void __vrange_resize(struct vrange *range,
 		unsigned long start_idx, unsigned long end_idx)
 {
 	struct vrange_root *vroot = range->owner;
-	bool purged = range->purged;
+	bool purged = vrange_purged(range);
 
 	__vrange_remove(range);
 	__vrange_lru_del(range);
@@ -341,7 +362,7 @@ static int vrange_add(struct vrange_root *vroot,
 
 		start_idx = min_t(unsigned long, start_idx, node->start);
 		end_idx = max_t(unsigned long, end_idx, node->last);
-		purged |= range->purged;
+		purged |= vrange_purged(range);
 
 		__vrange_remove(range);
 		__vrange_put(range);
@@ -383,7 +404,7 @@ static int vrange_remove(struct vrange_root *vroot,
 		next = interval_tree_iter_next(node, start_idx, end_idx);
 		range = vrange_from_node(node);
 
-		*purged |= range->purged;
+		*purged |= vrange_purged(range);
 
 		if (start_idx <= node->start && end_idx >= node->last) {
 			/* argumented range covers the range fully */
@@ -409,7 +430,7 @@ static int vrange_remove(struct vrange_root *vroot,
 			used_new = true;
 			__vrange_resize(range, node->start, start_idx - 1);
 			__vrange_set(new_range, end_idx + 1, last,
-					range->purged);
+					vrange_purged(range));
 			__vrange_add(new_range, vroot);
 			break;
 		}
@@ -492,7 +513,7 @@ int vrange_fork(struct mm_struct *new_mm, struct mm_struct *old_mm)
 		if (!new_range)
 			goto fail;
 		__vrange_set(new_range, range->node.start,
-					range->node.last, range->purged);
+				range->node.last, vrange_purged(range));
 		__vrange_add(new_range, new);
 
 	}
@@ -736,7 +757,7 @@ bool vrange_addr_purged(struct vm_area_struct *vma, unsigned long addr)
 
 	vrange_lock(vroot);
 	range = __vrange_find(vroot, vstart_idx, vstart_idx);
-	if (range && range->purged)
+	if (range && vrange_purged(range))
 		ret = true;
 
 	vrange_unlock(vroot);
@@ -753,7 +774,7 @@ static void do_purge(struct vrange_root *vroot,
 	node = interval_tree_iter_first(&vroot->v_rb, start_idx, end_idx);
 	while (node) {
 		range = container_of(node, struct vrange, node);
-		range->purged = true;
+		mark_purge(range);
 		node = interval_tree_iter_next(node, start_idx, end_idx);
 	}
 }
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
