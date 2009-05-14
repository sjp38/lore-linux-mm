Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id EFB8B6B0160
	for <linux-mm@kvack.org>; Wed, 13 May 2009 22:05:34 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n4E25bx7027333
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 14 May 2009 11:05:37 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id BAAE345DE51
	for <linux-mm@kvack.org>; Thu, 14 May 2009 11:05:36 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 9EDFB45DE4F
	for <linux-mm@kvack.org>; Thu, 14 May 2009 11:05:36 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 795051DB8040
	for <linux-mm@kvack.org>; Thu, 14 May 2009 11:05:36 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 1FBF7E18002
	for <linux-mm@kvack.org>; Thu, 14 May 2009 11:05:36 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: =?ISO-2022-JP?B?W1BBVENIGyRCISEbKEIxLzJd?=
 remove CONFIG_UNEVICTABLE_LRU config option
Message-Id: <20090514110357.9B54.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Date: Thu, 14 May 2009 11:05:35 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Andi Kleen <andi@firstfloor.org>, Minchan Kim <minchan.kim@gmail.com>, David Woodhouse <dwmw2@infradead.org>, Matt Mackall <mpm@selenic.com>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

Subject: [PATCH] remove CONFIG_UNEVICTABLE_LRU config option

Currently, nobody want to turn UNEVICTABLE_LRU off. Thus
this configurability is unnecessary.


Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andi Kleen <andi@firstfloor.org>
Cc: Minchan Kim <minchan.kim@gmail.com>
Cc: David Woodhouse <dwmw2@infradead.org>
Cc: Matt Mackall <mpm@selenic.com>
---
 drivers/base/node.c        |    4 ----
 fs/proc/meminfo.c          |    4 ----
 fs/proc/page.c             |    2 --
 include/linux/mmzone.h     |   13 -------------
 include/linux/page-flags.h |   16 +---------------
 include/linux/pagemap.h    |   12 ------------
 include/linux/rmap.h       |    7 -------
 include/linux/swap.h       |   19 -------------------
 include/linux/vmstat.h     |    2 --
 kernel/sysctl.c            |    2 --
 mm/Kconfig                 |   14 +-------------
 mm/internal.h              |    6 ------
 mm/mlock.c                 |   22 ----------------------
 mm/page_alloc.c            |    9 ---------
 mm/rmap.c                  |    3 +--
 mm/vmscan.c                |   17 -----------------
 mm/vmstat.c                |    4 ----
 17 files changed, 3 insertions(+), 153 deletions(-)

Index: b/drivers/base/node.c
===================================================================
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -72,10 +72,8 @@ static ssize_t node_read_meminfo(struct 
 		       "Node %d Inactive(anon): %8lu kB\n"
 		       "Node %d Active(file):   %8lu kB\n"
 		       "Node %d Inactive(file): %8lu kB\n"
-#ifdef CONFIG_UNEVICTABLE_LRU
 		       "Node %d Unevictable:    %8lu kB\n"
 		       "Node %d Mlocked:        %8lu kB\n"
-#endif
 #ifdef CONFIG_HIGHMEM
 		       "Node %d HighTotal:      %8lu kB\n"
 		       "Node %d HighFree:       %8lu kB\n"
@@ -105,10 +103,8 @@ static ssize_t node_read_meminfo(struct 
 		       nid, K(node_page_state(nid, NR_INACTIVE_ANON)),
 		       nid, K(node_page_state(nid, NR_ACTIVE_FILE)),
 		       nid, K(node_page_state(nid, NR_INACTIVE_FILE)),
-#ifdef CONFIG_UNEVICTABLE_LRU
 		       nid, K(node_page_state(nid, NR_UNEVICTABLE)),
 		       nid, K(node_page_state(nid, NR_MLOCK)),
-#endif
 #ifdef CONFIG_HIGHMEM
 		       nid, K(i.totalhigh),
 		       nid, K(i.freehigh),
Index: b/fs/proc/meminfo.c
===================================================================
--- a/fs/proc/meminfo.c
+++ b/fs/proc/meminfo.c
@@ -64,10 +64,8 @@ static int meminfo_proc_show(struct seq_
 		"Inactive(anon): %8lu kB\n"
 		"Active(file):   %8lu kB\n"
 		"Inactive(file): %8lu kB\n"
-#ifdef CONFIG_UNEVICTABLE_LRU
 		"Unevictable:    %8lu kB\n"
 		"Mlocked:        %8lu kB\n"
-#endif
 #ifdef CONFIG_HIGHMEM
 		"HighTotal:      %8lu kB\n"
 		"HighFree:       %8lu kB\n"
@@ -109,10 +107,8 @@ static int meminfo_proc_show(struct seq_
 		K(pages[LRU_INACTIVE_ANON]),
 		K(pages[LRU_ACTIVE_FILE]),
 		K(pages[LRU_INACTIVE_FILE]),
-#ifdef CONFIG_UNEVICTABLE_LRU
 		K(pages[LRU_UNEVICTABLE]),
 		K(global_page_state(NR_MLOCK)),
-#endif
 #ifdef CONFIG_HIGHMEM
 		K(i.totalhigh),
 		K(i.freehigh),
Index: b/fs/proc/page.c
===================================================================
--- a/fs/proc/page.c
+++ b/fs/proc/page.c
@@ -176,10 +176,8 @@ static u64 get_uflags(struct page *page)
 	u |= kpf_copy_bit(k, KPF_HWPOISON,	PG_hwpoison);
 #endif
 
-#ifdef CONFIG_UNEVICTABLE_LRU
 	u |= kpf_copy_bit(k, KPF_UNEVICTABLE,	PG_unevictable);
 	u |= kpf_copy_bit(k, KPF_MLOCKED,	PG_mlocked);
-#endif
 
 #ifdef CONFIG_IA64_UNCACHED_ALLOCATOR
 	u |= kpf_copy_bit(k, KPF_UNCACHED,	PG_uncached);
Index: b/include/linux/mmzone.h
===================================================================
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -83,13 +83,8 @@ enum zone_stat_item {
 	NR_ACTIVE_ANON,		/*  "     "     "   "       "         */
 	NR_INACTIVE_FILE,	/*  "     "     "   "       "         */
 	NR_ACTIVE_FILE,		/*  "     "     "   "       "         */
-#ifdef CONFIG_UNEVICTABLE_LRU
 	NR_UNEVICTABLE,		/*  "     "     "   "       "         */
 	NR_MLOCK,		/* mlock()ed pages found and moved off LRU */
-#else
-	NR_UNEVICTABLE = NR_ACTIVE_FILE, /* avoid compiler errors in dead code */
-	NR_MLOCK = NR_ACTIVE_FILE,
-#endif
 	NR_ANON_PAGES,	/* Mapped anonymous pages */
 	NR_FILE_MAPPED,	/* pagecache pages mapped into pagetables.
 			   only modified from process context */
@@ -132,11 +127,7 @@ enum lru_list {
 	LRU_ACTIVE_ANON = LRU_BASE + LRU_ACTIVE,
 	LRU_INACTIVE_FILE = LRU_BASE + LRU_FILE,
 	LRU_ACTIVE_FILE = LRU_BASE + LRU_FILE + LRU_ACTIVE,
-#ifdef CONFIG_UNEVICTABLE_LRU
 	LRU_UNEVICTABLE,
-#else
-	LRU_UNEVICTABLE = LRU_ACTIVE_FILE, /* avoid compiler errors in dead code */
-#endif
 	NR_LRU_LISTS
 };
 
@@ -156,11 +147,7 @@ static inline int is_active_lru(enum lru
 
 static inline int is_unevictable_lru(enum lru_list l)
 {
-#ifdef CONFIG_UNEVICTABLE_LRU
 	return (l == LRU_UNEVICTABLE);
-#else
-	return 0;
-#endif
 }
 
 struct per_cpu_pages {
Index: b/include/linux/page-flags.h
===================================================================
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -95,9 +95,7 @@ enum pageflags {
 	PG_reclaim,		/* To be reclaimed asap */
 	PG_buddy,		/* Page is free, on buddy lists */
 	PG_swapbacked,		/* Page is backed by RAM/swap */
-#ifdef CONFIG_UNEVICTABLE_LRU
 	PG_unevictable,		/* Page is "unevictable"  */
-#endif
 #ifdef CONFIG_HAVE_MLOCKED_PAGE_BIT
 	PG_mlocked,		/* Page is vma mlocked */
 #endif
@@ -246,14 +244,8 @@ PAGEFLAG_FALSE(SwapCache)
 	SETPAGEFLAG_NOOP(SwapCache) CLEARPAGEFLAG_NOOP(SwapCache)
 #endif
 
-#ifdef CONFIG_UNEVICTABLE_LRU
 PAGEFLAG(Unevictable, unevictable) __CLEARPAGEFLAG(Unevictable, unevictable)
 	TESTCLEARFLAG(Unevictable, unevictable)
-#else
-PAGEFLAG_FALSE(Unevictable) TESTCLEARFLAG_FALSE(Unevictable)
-	SETPAGEFLAG_NOOP(Unevictable) CLEARPAGEFLAG_NOOP(Unevictable)
-	__CLEARPAGEFLAG_NOOP(Unevictable)
-#endif
 
 #ifdef CONFIG_HAVE_MLOCKED_PAGE_BIT
 #define MLOCK_PAGES 1
@@ -380,12 +372,6 @@ static inline void __ClearPageTail(struc
 
 #endif /* !PAGEFLAGS_EXTENDED */
 
-#ifdef CONFIG_UNEVICTABLE_LRU
-#define __PG_UNEVICTABLE	(1 << PG_unevictable)
-#else
-#define __PG_UNEVICTABLE	0
-#endif
-
 #ifdef CONFIG_HAVE_MLOCKED_PAGE_BIT
 #define __PG_MLOCKED		(1 << PG_mlocked)
 #else
@@ -401,7 +387,7 @@ static inline void __ClearPageTail(struc
 	 1 << PG_private | 1 << PG_private_2 | \
 	 1 << PG_buddy	 | 1 << PG_writeback | 1 << PG_reserved | \
 	 1 << PG_slab	 | 1 << PG_swapcache | 1 << PG_active | \
-	 __PG_UNEVICTABLE | __PG_MLOCKED)
+	 1 << PG_unevictable | __PG_MLOCKED)
 
 /*
  * Flags checked when a page is prepped for return by the page allocator.
Index: b/include/linux/pagemap.h
===================================================================
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -22,9 +22,7 @@ enum mapping_flags {
 	AS_EIO		= __GFP_BITS_SHIFT + 0,	/* IO error on async write */
 	AS_ENOSPC	= __GFP_BITS_SHIFT + 1,	/* ENOSPC on async write */
 	AS_MM_ALL_LOCKS	= __GFP_BITS_SHIFT + 2,	/* under mm_take_all_locks() */
-#ifdef CONFIG_UNEVICTABLE_LRU
 	AS_UNEVICTABLE	= __GFP_BITS_SHIFT + 3,	/* e.g., ramdisk, SHM_LOCK */
-#endif
 	AS_EXEC		= __GFP_BITS_SHIFT + 4,	/* mapped PROT_EXEC somewhere */
 };
 
@@ -38,8 +36,6 @@ static inline void mapping_set_error(str
 	}
 }
 
-#ifdef CONFIG_UNEVICTABLE_LRU
-
 static inline void mapping_set_unevictable(struct address_space *mapping)
 {
 	set_bit(AS_UNEVICTABLE, &mapping->flags);
@@ -56,14 +52,6 @@ static inline int mapping_unevictable(st
 		return test_bit(AS_UNEVICTABLE, &mapping->flags);
 	return !!mapping;
 }
-#else
-static inline void mapping_set_unevictable(struct address_space *mapping) { }
-static inline void mapping_clear_unevictable(struct address_space *mapping) { }
-static inline int mapping_unevictable(struct address_space *mapping)
-{
-	return 0;
-}
-#endif
 
 static inline gfp_t mapping_gfp_mask(struct address_space * mapping)
 {
Index: b/include/linux/rmap.h
===================================================================
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -105,18 +105,11 @@ unsigned long page_address_in_vma(struct
  */
 int page_mkclean(struct page *);
 
-#ifdef CONFIG_UNEVICTABLE_LRU
 /*
  * called in munlock()/munmap() path to check for other vmas holding
  * the page mlocked.
  */
 int try_to_munlock(struct page *);
-#else
-static inline int try_to_munlock(struct page *page)
-{
-	return 0;	/* a.k.a. SWAP_SUCCESS */
-}
-#endif
 
 #if defined(CONFIG_KSM) || defined(CONFIG_KSM_MODULE)
 int page_wrprotect(struct page *page, int *odirect_sync, int count_offset);
Index: b/include/linux/swap.h
===================================================================
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -235,7 +235,6 @@ static inline int zone_reclaim(struct zo
 }
 #endif
 
-#ifdef CONFIG_UNEVICTABLE_LRU
 extern int page_evictable(struct page *page, struct vm_area_struct *vma);
 extern void scan_mapping_unevictable_pages(struct address_space *);
 
@@ -244,24 +243,6 @@ extern int scan_unevictable_handler(stru
 					void __user *, size_t *, loff_t *);
 extern int scan_unevictable_register_node(struct node *node);
 extern void scan_unevictable_unregister_node(struct node *node);
-#else
-static inline int page_evictable(struct page *page,
-						struct vm_area_struct *vma)
-{
-	return 1;
-}
-
-static inline void scan_mapping_unevictable_pages(struct address_space *mapping)
-{
-}
-
-static inline int scan_unevictable_register_node(struct node *node)
-{
-	return 0;
-}
-
-static inline void scan_unevictable_unregister_node(struct node *node) { }
-#endif
 
 extern int kswapd_run(int nid);
 
Index: b/include/linux/vmstat.h
===================================================================
--- a/include/linux/vmstat.h
+++ b/include/linux/vmstat.h
@@ -41,7 +41,6 @@ enum vm_event_item { PGPGIN, PGPGOUT, PS
 #ifdef CONFIG_HUGETLB_PAGE
 		HTLB_BUDDY_PGALLOC, HTLB_BUDDY_PGALLOC_FAIL,
 #endif
-#ifdef CONFIG_UNEVICTABLE_LRU
 		UNEVICTABLE_PGCULLED,	/* culled to noreclaim list */
 		UNEVICTABLE_PGSCANNED,	/* scanned for reclaimability */
 		UNEVICTABLE_PGRESCUED,	/* rescued from noreclaim list */
@@ -50,7 +49,6 @@ enum vm_event_item { PGPGIN, PGPGOUT, PS
 		UNEVICTABLE_PGCLEARED,	/* on COW, page truncate */
 		UNEVICTABLE_PGSTRANDED,	/* unable to isolate on unlock */
 		UNEVICTABLE_MLOCKFREED,
-#endif
 		NR_VM_EVENT_ITEMS
 };
 
Index: b/mm/Kconfig
===================================================================
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -203,25 +203,13 @@ config VIRT_TO_BUS
 	def_bool y
 	depends on !ARCH_NO_VIRT_TO_BUS
 
-config UNEVICTABLE_LRU
-	bool "Add LRU list to track non-evictable pages"
-	default y
-	help
-	  Keeps unevictable pages off of the active and inactive pageout
-	  lists, so kswapd will not waste CPU time or have its balancing
-	  algorithms thrown off by scanning these pages.  Selecting this
-	  will use one page flag and increase the code size a little,
-	  say Y unless you know what you are doing.
-
-	  See Documentation/vm/unevictable-lru.txt for more information.
-
 config HAVE_MLOCK
 	bool
 	default y if MMU=y
 
 config HAVE_MLOCKED_PAGE_BIT
 	bool
-	default y if HAVE_MLOCK=y && UNEVICTABLE_LRU=y
+	default y if HAVE_MLOCK=y
 
 config MMU_NOTIFIER
 	bool
Index: b/mm/internal.h
===================================================================
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -74,7 +74,6 @@ static inline void munlock_vma_pages_all
 }
 #endif
 
-#ifdef CONFIG_UNEVICTABLE_LRU
 /*
  * unevictable_migrate_page() called only from migrate_page_copy() to
  * migrate unevictable flag to new page.
@@ -86,11 +85,6 @@ static inline void unevictable_migrate_p
 	if (TestClearPageUnevictable(old))
 		SetPageUnevictable(new);
 }
-#else
-static inline void unevictable_migrate_page(struct page *new, struct page *old)
-{
-}
-#endif
 
 #ifdef CONFIG_HAVE_MLOCKED_PAGE_BIT
 /*
Index: b/mm/mlock.c
===================================================================
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -31,7 +31,6 @@ int can_do_mlock(void)
 }
 EXPORT_SYMBOL(can_do_mlock);
 
-#ifdef CONFIG_UNEVICTABLE_LRU
 /*
  * Mlocked pages are marked with PageMlocked() flag for efficient testing
  * in vmscan and, possibly, the fault path; and to support semi-accurate
@@ -261,27 +260,6 @@ static int __mlock_posix_error_return(lo
 	return retval;
 }
 
-#else /* CONFIG_UNEVICTABLE_LRU */
-
-/*
- * Just make pages present if VM_LOCKED.  No-op if unlocking.
- */
-static long __mlock_vma_pages_range(struct vm_area_struct *vma,
-				   unsigned long start, unsigned long end,
-				   int mlock)
-{
-	if (mlock && (vma->vm_flags & VM_LOCKED))
-		return make_pages_present(start, end);
-	return 0;
-}
-
-static inline int __mlock_posix_error_return(long retval)
-{
-	return 0;
-}
-
-#endif /* CONFIG_UNEVICTABLE_LRU */
-
 /**
  * mlock_vma_pages_range() - mlock pages in specified vma range.
  * @vma - the vma containing the specfied address range
Index: b/mm/page_alloc.c
===================================================================
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2061,19 +2061,14 @@ void show_free_areas(void)
 
 	printk("Active_anon:%lu active_file:%lu inactive_anon:%lu\n"
 		" inactive_file:%lu"
-//TODO:  check/adjust line lengths
-#ifdef CONFIG_UNEVICTABLE_LRU
 		" unevictable:%lu"
-#endif
 		" dirty:%lu writeback:%lu unstable:%lu\n"
 		" free:%lu slab:%lu mapped:%lu pagetables:%lu bounce:%lu\n",
 		global_page_state(NR_ACTIVE_ANON),
 		global_page_state(NR_ACTIVE_FILE),
 		global_page_state(NR_INACTIVE_ANON),
 		global_page_state(NR_INACTIVE_FILE),
-#ifdef CONFIG_UNEVICTABLE_LRU
 		global_page_state(NR_UNEVICTABLE),
-#endif
 		global_page_state(NR_FILE_DIRTY),
 		global_page_state(NR_WRITEBACK),
 		global_page_state(NR_UNSTABLE_NFS),
@@ -2097,9 +2092,7 @@ void show_free_areas(void)
 			" inactive_anon:%lukB"
 			" active_file:%lukB"
 			" inactive_file:%lukB"
-#ifdef CONFIG_UNEVICTABLE_LRU
 			" unevictable:%lukB"
-#endif
 			" present:%lukB"
 			" pages_scanned:%lu"
 			" all_unreclaimable? %s"
@@ -2113,9 +2106,7 @@ void show_free_areas(void)
 			K(zone_page_state(zone, NR_INACTIVE_ANON)),
 			K(zone_page_state(zone, NR_ACTIVE_FILE)),
 			K(zone_page_state(zone, NR_INACTIVE_FILE)),
-#ifdef CONFIG_UNEVICTABLE_LRU
 			K(zone_page_state(zone, NR_UNEVICTABLE)),
-#endif
 			K(zone->present_pages),
 			zone->pages_scanned,
 			(zone_is_all_unreclaimable(zone) ? "yes" : "no")
Index: b/mm/rmap.c
===================================================================
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1344,7 +1344,6 @@ int try_to_unmap(struct page *page, int 
 	return ret;
 }
 
-#ifdef CONFIG_UNEVICTABLE_LRU
 /**
  * try_to_munlock - try to munlock a page
  * @page: the page to be munlocked
@@ -1368,4 +1367,4 @@ int try_to_munlock(struct page *page)
 	else
 		return try_to_unmap_file(page, 1, 0);
 }
-#endif
+
Index: b/mm/vmscan.c
===================================================================
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -519,7 +519,6 @@ int remove_mapping(struct address_space 
  *
  * lru_lock must not be held, interrupts must be enabled.
  */
-#ifdef CONFIG_UNEVICTABLE_LRU
 void putback_lru_page(struct page *page)
 {
 	int lru;
@@ -573,20 +572,6 @@ redo:
 	put_page(page);		/* drop ref from isolate */
 }
 
-#else /* CONFIG_UNEVICTABLE_LRU */
-
-void putback_lru_page(struct page *page)
-{
-	int lru;
-	VM_BUG_ON(PageLRU(page));
-
-	lru = !!TestClearPageActive(page) + page_is_file_cache(page);
-	lru_cache_add_lru(page, lru);
-	put_page(page);
-}
-#endif /* CONFIG_UNEVICTABLE_LRU */
-
-
 /*
  * shrink_page_list() returns the number of reclaimed pages
  */
@@ -2510,7 +2495,6 @@ int zone_reclaim(struct zone *zone, gfp_
 }
 #endif
 
-#ifdef CONFIG_UNEVICTABLE_LRU
 /*
  * page_evictable - test whether a page is evictable
  * @page: the page to test
@@ -2757,4 +2741,3 @@ void scan_unevictable_unregister_node(st
 	sysdev_remove_file(&node->sysdev, &attr_scan_unevictable_pages);
 }
 
-#endif
Index: b/kernel/sysctl.c
===================================================================
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -1307,7 +1307,6 @@ static struct ctl_table vm_table[] = {
 		.extra2		= &one,
 	},
 #endif
-#ifdef CONFIG_UNEVICTABLE_LRU
 	{
 		.ctl_name	= CTL_UNNUMBERED,
 		.procname	= "scan_unevictable_pages",
@@ -1316,7 +1315,6 @@ static struct ctl_table vm_table[] = {
 		.mode		= 0644,
 		.proc_handler	= &scan_unevictable_handler,
 	},
-#endif
 /*
  * NOTE: do not add new entries to this table unless you have read
  * Documentation/sysctl/ctl_unnumbered.txt
Index: b/mm/vmstat.c
===================================================================
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -640,10 +640,8 @@ static const char * const vmstat_text[] 
 	"nr_active_anon",
 	"nr_inactive_file",
 	"nr_active_file",
-#ifdef CONFIG_UNEVICTABLE_LRU
 	"nr_unevictable",
 	"nr_mlock",
-#endif
 	"nr_anon_pages",
 	"nr_mapped",
 	"nr_file_pages",
@@ -698,7 +696,6 @@ static const char * const vmstat_text[] 
 	"htlb_buddy_alloc_success",
 	"htlb_buddy_alloc_fail",
 #endif
-#ifdef CONFIG_UNEVICTABLE_LRU
 	"unevictable_pgs_culled",
 	"unevictable_pgs_scanned",
 	"unevictable_pgs_rescued",
@@ -708,7 +705,6 @@ static const char * const vmstat_text[] 
 	"unevictable_pgs_stranded",
 	"unevictable_pgs_mlockfreed",
 #endif
-#endif
 };
 
 static void zoneinfo_show_print(struct seq_file *m, pg_data_t *pgdat,


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
