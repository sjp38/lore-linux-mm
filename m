Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id D6E416B004D
	for <linux-mm@kvack.org>; Fri, 27 Jul 2012 23:58:37 -0400 (EDT)
Received: from /spool/local
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <john.stultz@linaro.org>;
	Fri, 27 Jul 2012 21:58:36 -0600
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 7A57E19D8040
	for <linux-mm@kvack.org>; Sat, 28 Jul 2012 03:57:57 +0000 (WET)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q6S3w0mS108354
	for <linux-mm@kvack.org>; Fri, 27 Jul 2012 21:58:00 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q6S3vx7O002402
	for <linux-mm@kvack.org>; Fri, 27 Jul 2012 21:58:00 -0600
From: John Stultz <john.stultz@linaro.org>
Subject: [PATCH 3/5] [RFC] ashmem: Convert ashmem to use volatile ranges
Date: Fri, 27 Jul 2012 23:57:10 -0400
Message-Id: <1343447832-7182-4-git-send-email-john.stultz@linaro.org>
In-Reply-To: <1343447832-7182-1-git-send-email-john.stultz@linaro.org>
References: <1343447832-7182-1-git-send-email-john.stultz@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: John Stultz <john.stultz@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Andrea Righi <andrea@betterlinux.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Mike Hommey <mh@glandium.org>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

Rework of my first pass attempt at getting ashmem to utilize
the volatile range code, now using the fallocate interface.

In this implementaiton GET_PIN_STATUS is unimplemented, due to
the fact that adding a ISVOLATILE check wasn't considered
terribly useful in earlier reviews. It would be trivial to
re-add that functionality, but I wanted to check w/ the
Android developers to see how often GET_PIN_STATUS is actually
used?

Similarly the ashmem PURGE_ALL_CACHES ioctl does not function,
as the volatile range purging is no longer directly under its
control.

CC: Andrew Morton <akpm@linux-foundation.org>
CC: Android Kernel Team <kernel-team@android.com>
CC: Robert Love <rlove@google.com>
CC: Mel Gorman <mel@csn.ul.ie>
CC: Hugh Dickins <hughd@google.com>
CC: Dave Hansen <dave@linux.vnet.ibm.com>
CC: Rik van Riel <riel@redhat.com>
CC: Dmitry Adamushko <dmitry.adamushko@gmail.com>
CC: Dave Chinner <david@fromorbit.com>
CC: Neil Brown <neilb@suse.de>
CC: Andrea Righi <andrea@betterlinux.com>
CC: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
CC: Mike Hommey <mh@glandium.org>
CC: Jan Kara <jack@suse.cz>
CC: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
CC: Michel Lespinasse <walken@google.com>
CC: Minchan Kim <minchan@kernel.org>
CC: linux-mm@kvack.org <linux-mm@kvack.org>
Signed-off-by: John Stultz <john.stultz@linaro.org>
---
 drivers/staging/android/ashmem.c |  331 ++------------------------------------
 1 file changed, 10 insertions(+), 321 deletions(-)

diff --git a/drivers/staging/android/ashmem.c b/drivers/staging/android/ashmem.c
index 69cf2db..6ce73e1 100644
--- a/drivers/staging/android/ashmem.c
+++ b/drivers/staging/android/ashmem.c
@@ -52,26 +52,6 @@ struct ashmem_area {
 };
 
 /*
- * ashmem_range - represents an interval of unpinned (evictable) pages
- * Lifecycle: From unpin to pin
- * Locking: Protected by `ashmem_mutex'
- */
-struct ashmem_range {
-	struct list_head lru;		/* entry in LRU list */
-	struct list_head unpinned;	/* entry in its area's unpinned list */
-	struct ashmem_area *asma;	/* associated area */
-	size_t pgstart;			/* starting page, inclusive */
-	size_t pgend;			/* ending page, inclusive */
-	unsigned int purged;		/* ASHMEM_NOT or ASHMEM_WAS_PURGED */
-};
-
-/* LRU list of unpinned pages, protected by ashmem_mutex */
-static LIST_HEAD(ashmem_lru_list);
-
-/* Count of pages on our LRU list, protected by ashmem_mutex */
-static unsigned long lru_count;
-
-/*
  * ashmem_mutex - protects the list of and each individual ashmem_area
  *
  * Lock Ordering: ashmex_mutex -> i_mutex -> i_alloc_sem
@@ -79,102 +59,9 @@ static unsigned long lru_count;
 static DEFINE_MUTEX(ashmem_mutex);
 
 static struct kmem_cache *ashmem_area_cachep __read_mostly;
-static struct kmem_cache *ashmem_range_cachep __read_mostly;
-
-#define range_size(range) \
-	((range)->pgend - (range)->pgstart + 1)
-
-#define range_on_lru(range) \
-	((range)->purged == ASHMEM_NOT_PURGED)
-
-#define page_range_subsumes_range(range, start, end) \
-	(((range)->pgstart >= (start)) && ((range)->pgend <= (end)))
-
-#define page_range_subsumed_by_range(range, start, end) \
-	(((range)->pgstart <= (start)) && ((range)->pgend >= (end)))
-
-#define page_in_range(range, page) \
-	(((range)->pgstart <= (page)) && ((range)->pgend >= (page)))
-
-#define page_range_in_range(range, start, end) \
-	(page_in_range(range, start) || page_in_range(range, end) || \
-		page_range_subsumes_range(range, start, end))
-
-#define range_before_page(range, page) \
-	((range)->pgend < (page))
 
 #define PROT_MASK		(PROT_EXEC | PROT_READ | PROT_WRITE)
 
-static inline void lru_add(struct ashmem_range *range)
-{
-	list_add_tail(&range->lru, &ashmem_lru_list);
-	lru_count += range_size(range);
-}
-
-static inline void lru_del(struct ashmem_range *range)
-{
-	list_del(&range->lru);
-	lru_count -= range_size(range);
-}
-
-/*
- * range_alloc - allocate and initialize a new ashmem_range structure
- *
- * 'asma' - associated ashmem_area
- * 'prev_range' - the previous ashmem_range in the sorted asma->unpinned list
- * 'purged' - initial purge value (ASMEM_NOT_PURGED or ASHMEM_WAS_PURGED)
- * 'start' - starting page, inclusive
- * 'end' - ending page, inclusive
- *
- * Caller must hold ashmem_mutex.
- */
-static int range_alloc(struct ashmem_area *asma,
-		       struct ashmem_range *prev_range, unsigned int purged,
-		       size_t start, size_t end)
-{
-	struct ashmem_range *range;
-
-	range = kmem_cache_zalloc(ashmem_range_cachep, GFP_KERNEL);
-	if (unlikely(!range))
-		return -ENOMEM;
-
-	range->asma = asma;
-	range->pgstart = start;
-	range->pgend = end;
-	range->purged = purged;
-
-	list_add_tail(&range->unpinned, &prev_range->unpinned);
-
-	if (range_on_lru(range))
-		lru_add(range);
-
-	return 0;
-}
-
-static void range_del(struct ashmem_range *range)
-{
-	list_del(&range->unpinned);
-	if (range_on_lru(range))
-		lru_del(range);
-	kmem_cache_free(ashmem_range_cachep, range);
-}
-
-/*
- * range_shrink - shrinks a range
- *
- * Caller must hold ashmem_mutex.
- */
-static inline void range_shrink(struct ashmem_range *range,
-				size_t start, size_t end)
-{
-	size_t pre = range_size(range);
-
-	range->pgstart = start;
-	range->pgend = end;
-
-	if (range_on_lru(range))
-		lru_count -= pre - range_size(range);
-}
 
 static int ashmem_open(struct inode *inode, struct file *file)
 {
@@ -200,12 +87,6 @@ static int ashmem_open(struct inode *inode, struct file *file)
 static int ashmem_release(struct inode *ignored, struct file *file)
 {
 	struct ashmem_area *asma = file->private_data;
-	struct ashmem_range *range, *next;
-
-	mutex_lock(&ashmem_mutex);
-	list_for_each_entry_safe(range, next, &asma->unpinned_list, unpinned)
-		range_del(range);
-	mutex_unlock(&ashmem_mutex);
 
 	if (asma->file)
 		fput(asma->file);
@@ -339,56 +220,6 @@ out:
 	return ret;
 }
 
-/*
- * ashmem_shrink - our cache shrinker, called from mm/vmscan.c :: shrink_slab
- *
- * 'nr_to_scan' is the number of objects (pages) to prune, or 0 to query how
- * many objects (pages) we have in total.
- *
- * 'gfp_mask' is the mask of the allocation that got us into this mess.
- *
- * Return value is the number of objects (pages) remaining, or -1 if we cannot
- * proceed without risk of deadlock (due to gfp_mask).
- *
- * We approximate LRU via least-recently-unpinned, jettisoning unpinned partial
- * chunks of ashmem regions LRU-wise one-at-a-time until we hit 'nr_to_scan'
- * pages freed.
- */
-static int ashmem_shrink(struct shrinker *s, struct shrink_control *sc)
-{
-	struct ashmem_range *range, *next;
-
-	/* We might recurse into filesystem code, so bail out if necessary */
-	if (sc->nr_to_scan && !(sc->gfp_mask & __GFP_FS))
-		return -1;
-	if (!sc->nr_to_scan)
-		return lru_count;
-
-	mutex_lock(&ashmem_mutex);
-	list_for_each_entry_safe(range, next, &ashmem_lru_list, lru) {
-		loff_t start = range->pgstart * PAGE_SIZE;
-		loff_t end = (range->pgend + 1) * PAGE_SIZE;
-
-		do_fallocate(range->asma->file,
-				FALLOC_FL_PUNCH_HOLE | FALLOC_FL_KEEP_SIZE,
-				start, end - start);
-		range->purged = ASHMEM_WAS_PURGED;
-		lru_del(range);
-
-		sc->nr_to_scan -= range_size(range);
-		if (sc->nr_to_scan <= 0)
-			break;
-	}
-	mutex_unlock(&ashmem_mutex);
-
-	return lru_count;
-}
-
-static struct shrinker ashmem_shrinker = {
-	.shrink = ashmem_shrink,
-	.seeks = DEFAULT_SEEKS * 4,
-};
-
 static int set_prot_mask(struct ashmem_area *asma, unsigned long prot)
 {
 	int ret = 0;
@@ -461,136 +292,10 @@ static int get_name(struct ashmem_area *asma, void __user *name)
 	return ret;
 }
 
-/*
- * ashmem_pin - pin the given ashmem region, returning whether it was
- * previously purged (ASHMEM_WAS_PURGED) or not (ASHMEM_NOT_PURGED).
- *
- * Caller must hold ashmem_mutex.
- */
-static int ashmem_pin(struct ashmem_area *asma, size_t pgstart, size_t pgend)
-{
-	struct ashmem_range *range, *next;
-	int ret = ASHMEM_NOT_PURGED;
-
-	list_for_each_entry_safe(range, next, &asma->unpinned_list, unpinned) {
-		/* moved past last applicable page; we can short circuit */
-		if (range_before_page(range, pgstart))
-			break;
-
-		/*
-		 * The user can ask us to pin pages that span multiple ranges,
-		 * or to pin pages that aren't even unpinned, so this is messy.
-		 *
-		 * Four cases:
-		 * 1. The requested range subsumes an existing range, so we
-		 *    just remove the entire matching range.
-		 * 2. The requested range overlaps the start of an existing
-		 *    range, so we just update that range.
-		 * 3. The requested range overlaps the end of an existing
-		 *    range, so we just update that range.
-		 * 4. The requested range punches a hole in an existing range,
-		 *    so we have to update one side of the range and then
-		 *    create a new range for the other side.
-		 */
-		if (page_range_in_range(range, pgstart, pgend)) {
-			ret |= range->purged;
-
-			/* Case #1: Easy. Just nuke the whole thing. */
-			if (page_range_subsumes_range(range, pgstart, pgend)) {
-				range_del(range);
-				continue;
-			}
-
-			/* Case #2: We overlap from the start, so adjust it */
-			if (range->pgstart >= pgstart) {
-				range_shrink(range, pgend + 1, range->pgend);
-				continue;
-			}
-
-			/* Case #3: We overlap from the rear, so adjust it */
-			if (range->pgend <= pgend) {
-				range_shrink(range, range->pgstart, pgstart-1);
-				continue;
-			}
-
-			/*
-			 * Case #4: We eat a chunk out of the middle. A bit
-			 * more complicated, we allocate a new range for the
-			 * second half and adjust the first chunk's endpoint.
-			 */
-			range_alloc(asma, range, range->purged,
-				    pgend + 1, range->pgend);
-			range_shrink(range, range->pgstart, pgstart - 1);
-			break;
-		}
-	}
-
-	return ret;
-}
-
-/*
- * ashmem_unpin - unpin the given range of pages. Returns zero on success.
- *
- * Caller must hold ashmem_mutex.
- */
-static int ashmem_unpin(struct ashmem_area *asma, size_t pgstart, size_t pgend)
-{
-	struct ashmem_range *range, *next;
-	unsigned int purged = ASHMEM_NOT_PURGED;
-
-restart:
-	list_for_each_entry_safe(range, next, &asma->unpinned_list, unpinned) {
-		/* short circuit: this is our insertion point */
-		if (range_before_page(range, pgstart))
-			break;
-
-		/*
-		 * The user can ask us to unpin pages that are already entirely
-		 * or partially pinned. We handle those two cases here.
-		 */
-		if (page_range_subsumed_by_range(range, pgstart, pgend))
-			return 0;
-		if (page_range_in_range(range, pgstart, pgend)) {
-			pgstart = min_t(size_t, range->pgstart, pgstart),
-			pgend = max_t(size_t, range->pgend, pgend);
-			purged |= range->purged;
-			range_del(range);
-			goto restart;
-		}
-	}
-
-	return range_alloc(asma, range, purged, pgstart, pgend);
-}
-
-/*
- * ashmem_get_pin_status - Returns ASHMEM_IS_UNPINNED if _any_ pages in the
- * given interval are unpinned and ASHMEM_IS_PINNED otherwise.
- *
- * Caller must hold ashmem_mutex.
- */
-static int ashmem_get_pin_status(struct ashmem_area *asma, size_t pgstart,
-				 size_t pgend)
-{
-	struct ashmem_range *range;
-	int ret = ASHMEM_IS_PINNED;
-
-	list_for_each_entry(range, &asma->unpinned_list, unpinned) {
-		if (range_before_page(range, pgstart))
-			break;
-		if (page_range_in_range(range, pgstart, pgend)) {
-			ret = ASHMEM_IS_UNPINNED;
-			break;
-		}
-	}
-
-	return ret;
-}
-
 static int ashmem_pin_unpin(struct ashmem_area *asma, unsigned long cmd,
 			    void __user *p)
 {
 	struct ashmem_pin pin;
-	size_t pgstart, pgend;
 	int ret = -EINVAL;
 
 	if (unlikely(!asma->file))
@@ -612,20 +317,24 @@ static int ashmem_pin_unpin(struct ashmem_area *asma, unsigned long cmd,
 	if (unlikely(PAGE_ALIGN(asma->size) < pin.offset + pin.len))
 		return -EINVAL;
 
-	pgstart = pin.offset / PAGE_SIZE;
-	pgend = pgstart + (pin.len / PAGE_SIZE) - 1;
 
 	mutex_lock(&ashmem_mutex);
 
 	switch (cmd) {
 	case ASHMEM_PIN:
-		ret = ashmem_pin(asma, pgstart, pgend);
+		ret = do_fallocate(asma->file, FALLOC_FL_MARK_VOLATILE,
+					pin.offset, pin.len);
 		break;
 	case ASHMEM_UNPIN:
-		ret = ashmem_unpin(asma, pgstart, pgend);
+		ret = do_fallocate(asma->file, FALLOC_FL_UNMARK_VOLATILE,
+					pin.offset, pin.len);
 		break;
 	case ASHMEM_GET_PIN_STATUS:
-		ret = ashmem_get_pin_status(asma, pgstart, pgend);
+		/*
+		 * XXX - volatile ranges currently don't provide status,
+		 * due to questionable utility
+		 */
+		ret = -EINVAL;
 		break;
 	}
 
@@ -669,15 +378,6 @@ static long ashmem_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 		break;
 	case ASHMEM_PURGE_ALL_CACHES:
 		ret = -EPERM;
-		if (capable(CAP_SYS_ADMIN)) {
-			struct shrink_control sc = {
-				.gfp_mask = GFP_KERNEL,
-				.nr_to_scan = 0,
-			};
-			ret = ashmem_shrink(&ashmem_shrinker, &sc);
-			sc.nr_to_scan = ret;
-			ashmem_shrink(&ashmem_shrinker, &sc);
-		}
 		break;
 	}
 
@@ -713,21 +413,13 @@ static int __init ashmem_init(void)
 		return -ENOMEM;
 	}
 
-	ashmem_range_cachep = kmem_cache_create("ashmem_range_cache",
-					  sizeof(struct ashmem_range),
-					  0, 0, NULL);
-	if (unlikely(!ashmem_range_cachep)) {
-		pr_err("failed to create slab cache\n");
-		return -ENOMEM;
-	}
-
 	ret = misc_register(&ashmem_misc);
 	if (unlikely(ret)) {
 		pr_err("failed to register misc device!\n");
 		return ret;
 	}
 
-	register_shrinker(&ashmem_shrinker);
+
 
 	pr_info("initialized\n");
 
@@ -738,13 +430,10 @@ static void __exit ashmem_exit(void)
 {
 	int ret;
 
-	unregister_shrinker(&ashmem_shrinker);
-
 	ret = misc_deregister(&ashmem_misc);
 	if (unlikely(ret))
 		pr_err("failed to unregister misc device!\n");
 
-	kmem_cache_destroy(ashmem_range_cachep);
 	kmem_cache_destroy(ashmem_area_cachep);
 
 	pr_info("unloaded\n");
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
