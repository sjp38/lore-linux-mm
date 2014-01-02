Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 6A3426B0055
	for <linux-mm@kvack.org>; Thu,  2 Jan 2014 02:13:22 -0500 (EST)
Received: by mail-pd0-f180.google.com with SMTP id q10so13806324pdj.25
        for <linux-mm@kvack.org>; Wed, 01 Jan 2014 23:13:22 -0800 (PST)
Received: from LGEMRELSE7Q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id ll1si23308157pab.57.2014.01.01.23.13.19
        for <linux-mm@kvack.org>;
        Wed, 01 Jan 2014 23:13:21 -0800 (PST)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v10 15/16] vrange: Prevent unnecessary scanning
Date: Thu,  2 Jan 2014 16:12:23 +0900
Message-Id: <1388646744-15608-16-git-send-email-minchan@kernel.org>
In-Reply-To: <1388646744-15608-1-git-send-email-minchan@kernel.org>
References: <1388646744-15608-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Michel Lespinasse <walken@google.com>, Johannes Weiner <hannes@cmpxchg.org>, John Stultz <john.stultz@linaro.org>, Dhaval Giani <dhaval.giani@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Andrea Righi <andrea@betterlinux.com>, Andrea Arcangeli <aarcange@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Rob Clark <robdclark@gmail.com>, Jason Evans <je@fb.com>, Minchan Kim <minchan@kernel.org>

Now, we scan and discard volatile pages per vrange size but vrange
size is virtual address so we couldn't imagine how many of rss be
there. It could make too excessive scanning in reclaim path if
the range is too big but doesn't have rss so that CPU burns out.

Another problem is we always start from vrange's starting address
everytime although many of pages are already purged in previous
iteration so that it ends up CPU buring, too.

This patch keeps previous scan address in vrange's hint variable
so that we could avoid unnecessary scanning in next round.
Even, if we purge all of pages in the range, we could skip the
vrange.

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
 mm/vrange.c |  107 ++++++++++++++++++++++++++++++++++++++++++++++++++---------
 1 file changed, 91 insertions(+), 16 deletions(-)

diff --git a/mm/vrange.c b/mm/vrange.c
index df01c6b084bf..6cdbf6feed26 100644
--- a/mm/vrange.c
+++ b/mm/vrange.c
@@ -31,6 +31,11 @@ struct vrange_walker {
 
 #define VRANGE_PURGED_MARK	0
 
+/*
+ * [mark|clear]_purge could invalidate cached address but it's rare
+ * and at the worst case, some address range would be rescan or skip
+ * so it isn't critical for integrity point of view.
+ */
 void mark_purge(struct vrange *range)
 {
 	range->hint |= (1 << VRANGE_PURGED_MARK);
@@ -47,9 +52,36 @@ bool vrange_purged(struct vrange *range)
 	return purged;
 }
 
-static inline unsigned long vrange_size(struct vrange *range)
+void record_scan_addr(struct vrange *range, unsigned long addr)
 {
-	return range->node.last + 1 - range->node.start;
+	unsigned long old, new, ret;
+
+	BUG_ON(addr & ~PAGE_MASK);
+
+	/*
+	 * hint variable is shared by cache address and purged flag.
+	 * purged flag is modified while we hold vrange_lock but
+	 * cache address is modified without any lock so that it
+	 * could invalidate purged flag by racing do_purge, which
+	 * is critical. The cmpxchg should prevent it.
+	 */
+	do {
+		old = range->hint;
+		new = old | addr;
+		ret = cmpxchg(&range->hint, old, new);
+	} while (ret != old);
+
+	BUG_ON(addr && addr > range->node.last + 1);
+	BUG_ON(addr && addr < range->node.start);
+}
+
+unsigned long load_scan_addr(struct vrange *range)
+{
+	unsigned long cached_addr = range->hint & PAGE_MASK;
+	BUG_ON(cached_addr && cached_addr > range->node.last + 1);
+	BUG_ON(cached_addr && cached_addr < range->node.start);
+
+	return cached_addr;
 }
 
 static void vroot_ctor(void *data)
@@ -259,6 +291,14 @@ static inline void __vrange_lru_add(struct vrange *range)
 	spin_unlock(&vrange_list.lock);
 }
 
+static inline void __vrange_lru_add_tail(struct vrange *range)
+{
+	spin_lock(&vrange_list.lock);
+	WARN_ON(!list_empty(&range->lru));
+	list_add_tail(&range->lru, &vrange_list.list);
+	spin_unlock(&vrange_list.lock);
+}
+
 static inline void __vrange_lru_del(struct vrange *range)
 {
 	spin_lock(&vrange_list.lock);
@@ -306,6 +346,9 @@ static inline void __vrange_set(struct vrange *range,
 {
 	range->node.start = start_idx;
 	range->node.last = end_idx;
+
+	/* If resize happens, invalidate cache addr */
+	range->hint = 0;
 	if (purged)
 		mark_purge(range);
 	else
@@ -1069,12 +1112,13 @@ static unsigned long discard_vma_pages(struct mm_struct *mm,
  * so avoid touching vrange->owner.
  */
 static int __discard_vrange_anon(struct mm_struct *mm, struct vrange *vrange,
-		unsigned long *ret_discard)
+			unsigned long *ret_discard, unsigned long *scan)
 {
 	struct vm_area_struct *vma;
 	unsigned long nr_discard = 0;
 	unsigned long start = vrange->node.start;
 	unsigned long end = vrange->node.last + 1;
+	unsigned long cached_addr;
 	int ret = 0;
 
 	/* It prevent to destroy vma when the process exist */
@@ -1087,6 +1131,10 @@ static int __discard_vrange_anon(struct mm_struct *mm, struct vrange *vrange,
 		goto out; /* this vrange could be retried */
 	}
 
+	cached_addr = load_scan_addr(vrange);
+	if (cached_addr)
+		start = cached_addr;
+
 	vma = find_vma(mm, start);
 	if (!vma || (vma->vm_start >= end))
 		goto out_unlock;
@@ -1097,10 +1145,18 @@ static int __discard_vrange_anon(struct mm_struct *mm, struct vrange *vrange,
 		BUG_ON(vma->vm_flags & (VM_SPECIAL|VM_LOCKED|VM_MIXEDMAP|
 					VM_HUGETLB));
 		cond_resched();
-		nr_discard += discard_vma_pages(mm, vma,
-				max_t(unsigned long, start, vma->vm_start),
-				min_t(unsigned long, end, vma->vm_end));
+
+		start = max(start, vma->vm_start);
+		end = min(end, vma->vm_end);
+		end = min(start + *scan, end);
+
+		nr_discard += discard_vma_pages(mm, vma, start, end);
+		*scan -= (end - start);
+		if (!*scan)
+			break;
 	}
+
+	record_scan_addr(vrange, end);
 out_unlock:
 	up_read(&mm->mmap_sem);
 	mmput(mm);
@@ -1110,18 +1166,27 @@ out:
 }
 
 static int __discard_vrange_file(struct address_space *mapping,
-			struct vrange *vrange, unsigned long *ret_discard)
+		struct vrange *vrange, unsigned long *ret_discard,
+		unsigned long *scan)
 {
 	struct pagevec pvec;
 	pgoff_t index;
 	int i, ret = 0;
+	unsigned long cached_addr;
 	unsigned long nr_discard = 0;
 	unsigned long start_idx = vrange->node.start;
 	unsigned long end_idx = vrange->node.last;
 	const pgoff_t start = start_idx >> PAGE_CACHE_SHIFT;
-	pgoff_t end = end_idx >> PAGE_CACHE_SHIFT;
+	pgoff_t end;
 	LIST_HEAD(pagelist);
 
+	cached_addr = load_scan_addr(vrange);
+	if (cached_addr)
+		start_idx = cached_addr;
+
+	end_idx = min(start_idx + *scan, end_idx);
+	end = end_idx >> PAGE_CACHE_SHIFT;
+
 	pagevec_init(&pvec, 0);
 	index = start;
 	while (index <= end && pagevec_lookup(&pvec, mapping, index,
@@ -1141,16 +1206,20 @@ static int __discard_vrange_file(struct address_space *mapping,
 		index++;
 	}
 
+	*scan -= (end_idx + 1 - start_idx);
+
 	if (!list_empty(&pagelist))
 		nr_discard = discard_vrange_pagelist(&pagelist);
 
+	record_scan_addr(vrange, end_idx + 1);
 	*ret_discard = nr_discard;
 	putback_lru_pages(&pagelist);
 
 	return ret;
 }
 
-static int discard_vrange(struct vrange *vrange, unsigned long *nr_discard)
+static int discard_vrange(struct vrange *vrange, unsigned long *nr_discard,
+				unsigned long *scan)
 {
 	int ret = 0;
 	struct vrange_root *vroot;
@@ -1169,10 +1238,10 @@ static int discard_vrange(struct vrange *vrange, unsigned long *nr_discard)
 
 	if (vroot->type == VRANGE_MM) {
 		struct mm_struct *mm = vroot->object;
-		ret = __discard_vrange_anon(mm, vrange, nr_discard);
+		ret = __discard_vrange_anon(mm, vrange, nr_discard, scan);
 	} else if (vroot->type == VRANGE_FILE) {
 		struct address_space *mapping = vroot->object;
-		ret = __discard_vrange_file(mapping, vrange, nr_discard);
+		ret = __discard_vrange_file(mapping, vrange, nr_discard, scan);
 	}
 
 out:
@@ -1188,7 +1257,7 @@ unsigned long shrink_vrange(enum lru_list lru, struct lruvec *lruvec,
 	int retry = 10;
 	struct vrange *range;
 	unsigned long nr_to_reclaim, total_reclaimed = 0;
-	unsigned long long scan_threshold = VRANGE_SCAN_THRESHOLD;
+	unsigned long remained_scan = VRANGE_SCAN_THRESHOLD;
 
 	if (!(sc->gfp_mask & __GFP_IO))
 		return 0;
@@ -1209,7 +1278,7 @@ unsigned long shrink_vrange(enum lru_list lru, struct lruvec *lruvec,
 
 	nr_to_reclaim = sc->nr_to_reclaim;
 
-	while (nr_to_reclaim > 0 && scan_threshold > 0 && retry) {
+	while (nr_to_reclaim > 0 && remained_scan > 0 && retry) {
 		unsigned long nr_reclaimed = 0;
 		int ret;
 
@@ -1224,9 +1293,7 @@ unsigned long shrink_vrange(enum lru_list lru, struct lruvec *lruvec,
 			continue;
 		}
 
-		ret = discard_vrange(range, &nr_reclaimed);
-		scan_threshold -= vrange_size(range);
-
+		ret = discard_vrange(range, &nr_reclaimed, &remained_scan);
 		/* If it's EAGAIN, retry it after a little */
 		if (ret == -EAGAIN) {
 			retry--;
@@ -1235,6 +1302,14 @@ unsigned long shrink_vrange(enum lru_list lru, struct lruvec *lruvec,
 			continue;
 		}
 
+		if (load_scan_addr(range) < range->node.last) {
+			/*
+			 * We like full range purging of a range rather than
+			 * partial range purging of all ranges for fairness.
+			 */
+			__vrange_lru_add_tail(range);
+		}
+
 		__vrange_put(range);
 		retry = 10;
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
