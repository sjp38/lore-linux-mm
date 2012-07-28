Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id 42C456B005D
	for <linux-mm@kvack.org>; Fri, 27 Jul 2012 23:58:53 -0400 (EDT)
Received: from /spool/local
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <john.stultz@linaro.org>;
	Fri, 27 Jul 2012 21:58:52 -0600
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 0A9863E4003C
	for <linux-mm@kvack.org>; Sat, 28 Jul 2012 03:58:02 +0000 (WET)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q6S3w2sa169870
	for <linux-mm@kvack.org>; Fri, 27 Jul 2012 21:58:03 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q6S3w0VR002499
	for <linux-mm@kvack.org>; Fri, 27 Jul 2012 21:58:02 -0600
From: John Stultz <john.stultz@linaro.org>
Subject: [PATCH 4/5] [RFC][HACK] Add LRU_VOLATILE support to the VM
Date: Fri, 27 Jul 2012 23:57:11 -0400
Message-Id: <1343447832-7182-5-git-send-email-john.stultz@linaro.org>
In-Reply-To: <1343447832-7182-1-git-send-email-john.stultz@linaro.org>
References: <1343447832-7182-1-git-send-email-john.stultz@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: John Stultz <john.stultz@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Andrea Righi <andrea@betterlinux.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Mike Hommey <mh@glandium.org>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

In an attempt to push the volatile range managment even
deeper into the VM code, this is my first attempt at
implementing Minchan's idea of a LRU_VOLATILE list in
the mm core.

This list sits along side the LRU_ACTIVE_ANON, _INACTIVE_ANON,
_ACTIVE_FILE, _INACTIVE_FILE and _UNEVICTABLE lru lists.

When a range is marked volatile, the pages in that range
are moved to the LRU_VOLATILE list. Since volatile pages
can be quickly purged, this list is the first list we
shrink when we need to free memory.

When a page is marked non-volatile, it is moved from the
LRU_VOLATILE list to the appropriate LRU_ACTIVE_ list.

This patch introduces the LRU_VOLATILE list, an isvolatile
page flag, functions to mark and unmark a single page
as volatile, and shrinker functions to purge volatile
pages.

This is a very raw first pass, and is neither performant
or likely bugfree. It works in my trivial testing, but
I've not pushed it very hard yet.

I wanted to send it out just to get some inital thoughts
on the approach and any suggestions should I be going too
far in the wrong direction.

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
 include/linux/fs.h         |    1 +
 include/linux/mm_inline.h  |    2 ++
 include/linux/mmzone.h     |    1 +
 include/linux/page-flags.h |    3 ++
 include/linux/swap.h       |    3 ++
 mm/memcontrol.c            |    1 +
 mm/page_alloc.c            |    1 +
 mm/swap.c                  |   71 +++++++++++++++++++++++++++++++++++++++++
 mm/vmscan.c                |   76 +++++++++++++++++++++++++++++++++++++++++---
 9 files changed, 155 insertions(+), 4 deletions(-)

diff --git a/include/linux/fs.h b/include/linux/fs.h
index 8fabb03..c6f3415 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -636,6 +636,7 @@ struct address_space_operations {
 	int (*is_partially_uptodate) (struct page *, read_descriptor_t *,
 					unsigned long);
 	int (*error_remove_page)(struct address_space *, struct page *);
+	int (*purgepage)(struct page *page, struct writeback_control *wbc);
 };
 
 extern const struct address_space_operations empty_aops;
diff --git a/include/linux/mm_inline.h b/include/linux/mm_inline.h
index 1397ccf..f78806c 100644
--- a/include/linux/mm_inline.h
+++ b/include/linux/mm_inline.h
@@ -91,6 +91,8 @@ static __always_inline enum lru_list page_lru(struct page *page)
 
 	if (PageUnevictable(page))
 		lru = LRU_UNEVICTABLE;
+	else if (PageIsVolatile(page))
+		lru = LRU_VOLATILE;
 	else {
 		lru = page_lru_base_type(page);
 		if (PageActive(page))
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 458988b..4bfa6c4 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -162,6 +162,7 @@ enum lru_list {
 	LRU_ACTIVE_ANON = LRU_BASE + LRU_ACTIVE,
 	LRU_INACTIVE_FILE = LRU_BASE + LRU_FILE,
 	LRU_ACTIVE_FILE = LRU_BASE + LRU_FILE + LRU_ACTIVE,
+	LRU_VOLATILE,
 	LRU_UNEVICTABLE,
 	NR_LRU_LISTS
 };
diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index c88d2a9..57800c8 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -108,6 +108,7 @@ enum pageflags {
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 	PG_compound_lock,
 #endif
+	PG_isvolatile,
 	__NR_PAGEFLAGS,
 
 	/* Filesystems */
@@ -201,6 +202,8 @@ PAGEFLAG(Dirty, dirty) TESTSCFLAG(Dirty, dirty) __CLEARPAGEFLAG(Dirty, dirty)
 PAGEFLAG(LRU, lru) __CLEARPAGEFLAG(LRU, lru)
 PAGEFLAG(Active, active) __CLEARPAGEFLAG(Active, active)
 	TESTCLEARFLAG(Active, active)
+PAGEFLAG(IsVolatile, isvolatile) __CLEARPAGEFLAG(IsVolatile, isvolatile)
+	TESTCLEARFLAG(IsVolatile, isvolatile)
 __PAGEFLAG(Slab, slab)
 PAGEFLAG(Checked, checked)		/* Used by some filesystems */
 PAGEFLAG(Pinned, pinned) TESTSCFLAG(Pinned, pinned)	/* Xen */
diff --git a/include/linux/swap.h b/include/linux/swap.h
index c84ec68..eb12d53 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -236,6 +236,9 @@ extern void rotate_reclaimable_page(struct page *page);
 extern void deactivate_page(struct page *page);
 extern void swap_setup(void);
 
+extern void mark_volatile_page(struct page *page);
+extern void mark_nonvolatile_page(struct page *page);
+
 extern void add_page_to_unevictable_list(struct page *page);
 
 /**
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index f72b5e5..98e1303 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4066,6 +4066,7 @@ static const char * const mem_cgroup_lru_names[] = {
 	"active_anon",
 	"inactive_file",
 	"active_file",
+	"volatile",
 	"unevictable",
 };
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 4a4f921..cffe1b6 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5975,6 +5975,7 @@ static const struct trace_print_flags pageflag_names[] = {
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 	{1UL << PG_compound_lock,	"compound_lock"	},
 #endif
+	{1UL << PG_isvolatile,		"volatile"	},
 };
 
 static void dump_page_flags(unsigned long flags)
diff --git a/mm/swap.c b/mm/swap.c
index 4e7e2ec..24bf1f8 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -574,6 +574,77 @@ void deactivate_page(struct page *page)
 	}
 }
 
+/**
+ * mark_volatile_page - Sets a page as volatile
+ * @page: page to mark volatile
+ *
+ * This function moves a page to the volatile lru.
+ */
+void mark_volatile_page(struct page *page)
+{
+	int lru;
+	bool active;
+	struct zone *zone = page_zone(page);
+	struct lruvec *lruvec;
+
+	if (!PageLRU(page))
+		return;
+
+	if (PageUnevictable(page))
+		return;
+
+	active = PageActive(page);
+	lru = page_lru_base_type(page);
+
+	/*
+	 * XXX - Doing this page by page is terrible for performance.
+	 * Rework w/ pagevec_lru_move_fn.
+	 */
+	spin_lock_irq(&zone->lru_lock);
+	lruvec = mem_cgroup_page_lruvec(page, zone);
+	del_page_from_lru_list(page, lruvec, lru + active);
+	add_page_to_lru_list(page, lruvec, LRU_VOLATILE);
+	SetPageIsVolatile(page);
+	ClearPageActive(page);
+	spin_unlock_irq(&zone->lru_lock);
+
+
+}
+
+/**
+ * mark_nonvolatile_page - Sets a page as non-volatile
+ * @page: page to mark non-volatile
+ *
+ * This function moves a page from the volatile lru
+ * to the appropriate active list.
+ */
+void mark_nonvolatile_page(struct page *page)
+{
+	int lru;
+	struct zone *zone = page_zone(page);
+	struct lruvec *lruvec;
+
+	if (!PageLRU(page))
+		return;
+
+	if (!PageIsVolatile(page))
+		return;
+
+	lru = page_lru_base_type(page);
+
+	/*
+	 * XXX - Doing this page by page is terrible for performance.
+	 * Rework w/ pagevec_lru_move_fn
+	 */
+	spin_lock_irq(&zone->lru_lock);
+	lruvec = mem_cgroup_page_lruvec(page, zone);
+	del_page_from_lru_list(page, lruvec, LRU_VOLATILE);
+	ClearPageIsVolatile(page);
+	SetPageActive(page);
+	add_page_to_lru_list(page, lruvec,  lru + LRU_ACTIVE);
+	spin_unlock_irq(&zone->lru_lock);
+}
+
 void lru_add_drain(void)
 {
 	lru_add_drain_cpu(get_cpu());
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 347b3ff..c15d604 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -409,6 +409,11 @@ static pageout_t pageout(struct page *page, struct address_space *mapping,
 		}
 		return PAGE_KEEP;
 	}
+
+
+	if (PageIsVolatile(page))
+		return PAGE_CLEAN;
+
 	if (mapping->a_ops->writepage == NULL)
 		return PAGE_ACTIVATE;
 	if (!may_write_to_queue(mapping->backing_dev_info, sc))
@@ -483,7 +488,7 @@ static int __remove_mapping(struct address_space *mapping, struct page *page)
 	if (!page_freeze_refs(page, 2))
 		goto cannot_free;
 	/* note: atomic_cmpxchg in page_freeze_refs provides the smp_rmb */
-	if (unlikely(PageDirty(page))) {
+	if (unlikely(PageDirty(page)) && !PageIsVolatile(page)) {
 		page_unfreeze_refs(page, 2);
 		goto cannot_free;
 	}
@@ -869,6 +874,21 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		if (!mapping || !__remove_mapping(mapping, page))
 			goto keep_locked;
 
+
+		/* If the page is volatile, call purgepage on it */
+		if (PageIsVolatile(page)) {
+			struct writeback_control wbc = {
+				.sync_mode = WB_SYNC_NONE,
+				.nr_to_write = SWAP_CLUSTER_MAX,
+				.range_start = 0,
+				.range_end = LLONG_MAX,
+				.for_reclaim = 1,
+			};
+
+			if (mapping && mapping->a_ops && mapping->a_ops->purgepage)
+				mapping->a_ops->purgepage(page, &wbc);
+		}
+
 		/*
 		 * At this point, we have no other references and there is
 		 * no way to pick any more up (removed from LRU, removed
@@ -898,9 +918,11 @@ activate_locked:
 		/* Not a candidate for swapping, so reclaim swap space. */
 		if (PageSwapCache(page) && vm_swap_full())
 			try_to_free_swap(page);
-		VM_BUG_ON(PageActive(page));
-		SetPageActive(page);
-		pgactivate++;
+		if (!PageIsVolatile(page)) {
+			VM_BUG_ON(PageActive(page));
+			SetPageActive(page);
+			pgactivate++;
+		}
 keep_locked:
 		unlock_page(page);
 keep:
@@ -1190,6 +1212,45 @@ putback_inactive_pages(struct lruvec *lruvec, struct list_head *page_list)
 	list_splice(&pages_to_free, page_list);
 }
 
+static noinline_for_stack unsigned long
+shrink_volatile_list(unsigned long nr_to_scan, struct lruvec *lruvec,
+		     struct scan_control *sc)
+{
+	LIST_HEAD(page_list);
+	unsigned long nr_scanned;
+	unsigned long nr_reclaimed = 0;
+	unsigned long nr_taken;
+	unsigned long nr_dirty = 0;
+	unsigned long nr_writeback = 0;
+
+	isolate_mode_t isolate_mode = 0;
+	struct zone *zone = lruvec_zone(lruvec);
+
+
+	lru_add_drain();
+
+	if (!sc->may_unmap)
+		isolate_mode |= ISOLATE_UNMAPPED;
+	if (!sc->may_writepage)
+		isolate_mode |= ISOLATE_CLEAN;
+
+	spin_lock_irq(&zone->lru_lock);
+	nr_taken = isolate_lru_pages(nr_to_scan, lruvec, &page_list,
+				     &nr_scanned, sc, isolate_mode, LRU_VOLATILE);
+	spin_unlock_irq(&zone->lru_lock);
+
+	if (nr_taken == 0)
+		goto done;
+
+	nr_reclaimed = shrink_page_list(&page_list, zone, sc,
+						&nr_dirty, &nr_writeback);
+	spin_lock_irq(&zone->lru_lock);
+	putback_inactive_pages(lruvec, &page_list);
+	spin_unlock_irq(&zone->lru_lock);
+done:
+	return nr_reclaimed;
+}
+
 /*
  * shrink_inactive_list() is a helper for shrink_zone().  It returns the number
  * of reclaimed pages
@@ -1777,6 +1838,13 @@ restart:
 	get_scan_count(lruvec, sc, nr);
 
 	blk_start_plug(&plug);
+
+
+	nr_to_scan = min_t(unsigned long, get_lru_size(lruvec, LRU_VOLATILE), SWAP_CLUSTER_MAX);
+	if (nr_to_scan)
+		shrink_volatile_list(nr_to_scan, lruvec, sc);
+
+
 	while (nr[LRU_INACTIVE_ANON] || nr[LRU_ACTIVE_FILE] ||
 					nr[LRU_INACTIVE_FILE]) {
 		for_each_evictable_lru(lru) {
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
