Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f170.google.com (mail-ig0-f170.google.com [209.85.213.170])
	by kanga.kvack.org (Postfix) with ESMTP id 23A476B0260
	for <linux-mm@kvack.org>; Fri, 20 Nov 2015 03:03:12 -0500 (EST)
Received: by igcto18 with SMTP id to18so6580487igc.0
        for <linux-mm@kvack.org>; Fri, 20 Nov 2015 00:03:12 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTPS id x9si2144226igl.12.2015.11.20.00.02.58
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 20 Nov 2015 00:02:59 -0800 (PST)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v4 14/16] mm: introduce lazyfree LRU list
Date: Fri, 20 Nov 2015 17:02:46 +0900
Message-Id: <1448006568-16031-15-git-send-email-minchan@kernel.org>
In-Reply-To: <1448006568-16031-1-git-send-email-minchan@kernel.org>
References: <1448006568-16031-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael Kerrisk <mtk.manpages@gmail.com>, linux-api@vger.kernel.org, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Jason Evans <je@fb.com>, Daniel Micay <danielmicay@gmail.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Shaohua Li <shli@kernel.org>, Michal Hocko <mhocko@suse.cz>, yalin.wang2010@gmail.com, Andy Lutomirski <luto@amacapital.net>, Minchan Kim <minchan@kernel.org>

There are issues to support MADV_FREE.

* MADV_FREE pages's hotness

It's really arguable. Someone think it's cold while others are not.
It's matter of workload dependent so I think no one could have
a one way. IOW, we need tunable knob.

* MADV_FREE on swapless system

Now, we instantly free MADV_FREEed pages on swapless system
because we don't have aged anonymous LRU list on swapless system
so there is no chance to discard them.

I tried to solve it with inactive anonymous LRU list without
introducing new LRU list but it needs a few hooks in reclaim
path to fix old behavior witch was not good to me. Moreover,
it makes implement tuning konb hard.

For addressing issues, this patch adds new LazyFree LRU list and
functions for the stat. Pages on the list have PG_lazyfree flag
which overrides PG_mappedtodisk(It should be safe because
no anonymous page can have the flag).

If user calls madvise(start, len, MADV_FREE), pages in the range
moves to lazyfree LRU from anonymous LRU. When memory pressure
happens, they can be discarded since there is no more store
opeartion since then. If there is store operation, they can move
to active anonymous LRU list.

In this patch, how to age lazyfree pages is very basic, which just
discards all pages in the list whenever memory pressure happens.
It's enough to prove working. Later patch will implement the policy.

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 drivers/base/node.c                       |  2 +
 drivers/staging/android/lowmemorykiller.c |  3 +-
 fs/proc/meminfo.c                         |  2 +
 include/linux/huge_mm.h                   |  5 +-
 include/linux/mm_inline.h                 | 25 +++++++--
 include/linux/mmzone.h                    | 11 ++--
 include/linux/page-flags.h                |  5 ++
 include/linux/rmap.h                      |  2 +-
 include/linux/swap.h                      |  5 +-
 include/linux/vm_event_item.h             |  4 +-
 include/trace/events/vmscan.h             | 18 ++++---
 mm/compaction.c                           | 12 +++--
 mm/huge_memory.c                          | 11 ++--
 mm/madvise.c                              | 40 ++++++++------
 mm/memcontrol.c                           | 14 ++++-
 mm/migrate.c                              |  2 +
 mm/page_alloc.c                           |  7 +++
 mm/rmap.c                                 | 15 ++++--
 mm/swap.c                                 | 87 ++++++++++++++++++-------------
 mm/vmscan.c                               | 78 +++++++++++++++++++--------
 mm/vmstat.c                               |  3 ++
 21 files changed, 244 insertions(+), 107 deletions(-)

diff --git a/drivers/base/node.c b/drivers/base/node.c
index 560751bad294..f7a1f2107b43 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -70,6 +70,7 @@ static ssize_t node_read_meminfo(struct device *dev,
 		       "Node %d Active(file):   %8lu kB\n"
 		       "Node %d Inactive(file): %8lu kB\n"
 		       "Node %d Unevictable:    %8lu kB\n"
+		       "Node %d LazyFree:	%8lu kB\n"
 		       "Node %d Mlocked:        %8lu kB\n",
 		       nid, K(i.totalram),
 		       nid, K(i.freeram),
@@ -83,6 +84,7 @@ static ssize_t node_read_meminfo(struct device *dev,
 		       nid, K(node_page_state(nid, NR_ACTIVE_FILE)),
 		       nid, K(node_page_state(nid, NR_INACTIVE_FILE)),
 		       nid, K(node_page_state(nid, NR_UNEVICTABLE)),
+		       nid, K(node_page_state(nid, NR_LZFREE)),
 		       nid, K(node_page_state(nid, NR_MLOCK)));
 
 #ifdef CONFIG_HIGHMEM
diff --git a/drivers/staging/android/lowmemorykiller.c b/drivers/staging/android/lowmemorykiller.c
index 872bd603fd0d..658c16a653c2 100644
--- a/drivers/staging/android/lowmemorykiller.c
+++ b/drivers/staging/android/lowmemorykiller.c
@@ -72,7 +72,8 @@ static unsigned long lowmem_count(struct shrinker *s,
 	return global_page_state(NR_ACTIVE_ANON) +
 		global_page_state(NR_ACTIVE_FILE) +
 		global_page_state(NR_INACTIVE_ANON) +
-		global_page_state(NR_INACTIVE_FILE);
+		global_page_state(NR_INACTIVE_FILE) +
+		global_page_state(NR_LZFREE);
 }
 
 static unsigned long lowmem_scan(struct shrinker *s, struct shrink_control *sc)
diff --git a/fs/proc/meminfo.c b/fs/proc/meminfo.c
index d3ebf2e61853..3444f7c4e0b6 100644
--- a/fs/proc/meminfo.c
+++ b/fs/proc/meminfo.c
@@ -102,6 +102,7 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
 		"Active(file):   %8lu kB\n"
 		"Inactive(file): %8lu kB\n"
 		"Unevictable:    %8lu kB\n"
+		"LazyFree:	 %8lu kB\n"
 		"Mlocked:        %8lu kB\n"
 #ifdef CONFIG_HIGHMEM
 		"HighTotal:      %8lu kB\n"
@@ -159,6 +160,7 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
 		K(pages[LRU_ACTIVE_FILE]),
 		K(pages[LRU_INACTIVE_FILE]),
 		K(pages[LRU_UNEVICTABLE]),
+		K(pages[LRU_LZFREE]),
 		K(global_page_state(NR_MLOCK)),
 #ifdef CONFIG_HIGHMEM
 		K(i.totalhigh),
diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index e9db238a75c1..6eb54a6ed5d0 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -1,6 +1,8 @@
 #ifndef _LINUX_HUGE_MM_H
 #define _LINUX_HUGE_MM_H
 
+struct pagevec;
+
 extern int do_huge_pmd_anonymous_page(struct mm_struct *mm,
 				      struct vm_area_struct *vma,
 				      unsigned long address, pmd_t *pmd,
@@ -21,7 +23,8 @@ extern struct page *follow_trans_huge_pmd(struct vm_area_struct *vma,
 					  unsigned int flags);
 extern int madvise_free_huge_pmd(struct mmu_gather *tlb,
 			struct vm_area_struct *vma,
-			pmd_t *pmd, unsigned long addr);
+			pmd_t *pmd, unsigned long addr,
+			struct pagevec *pvec);
 extern int zap_huge_pmd(struct mmu_gather *tlb,
 			struct vm_area_struct *vma,
 			pmd_t *pmd, unsigned long addr);
diff --git a/include/linux/mm_inline.h b/include/linux/mm_inline.h
index 5e08a354f936..b34e511e90ae 100644
--- a/include/linux/mm_inline.h
+++ b/include/linux/mm_inline.h
@@ -26,6 +26,10 @@ static __always_inline void add_page_to_lru_list(struct page *page,
 				struct lruvec *lruvec, enum lru_list lru)
 {
 	int nr_pages = hpage_nr_pages(page);
+
+	if (lru == LRU_LZFREE)
+		VM_BUG_ON_PAGE(PageActive(page), page);
+
 	mem_cgroup_update_lru_size(lruvec, lru, nr_pages);
 	list_add(&page->lru, &lruvec->lists[lru]);
 	__mod_zone_page_state(lruvec_zone(lruvec), NR_LRU_BASE + lru, nr_pages);
@@ -35,6 +39,10 @@ static __always_inline void del_page_from_lru_list(struct page *page,
 				struct lruvec *lruvec, enum lru_list lru)
 {
 	int nr_pages = hpage_nr_pages(page);
+
+	if (lru == LRU_LZFREE)
+		VM_BUG_ON_PAGE(!PageLazyFree(page), page);
+
 	mem_cgroup_update_lru_size(lruvec, lru, -nr_pages);
 	list_del(&page->lru);
 	__mod_zone_page_state(lruvec_zone(lruvec), NR_LRU_BASE + lru, -nr_pages);
@@ -46,12 +54,14 @@ static __always_inline void del_page_from_lru_list(struct page *page,
  *
  * Used for LRU list index arithmetic.
  *
- * Returns the base LRU type - file or anon - @page should be on.
+ * Returns the base LRU type - file or anon or lazyfree - @page should be on.
  */
 static inline enum lru_list page_lru_base_type(struct page *page)
 {
 	if (page_is_file_cache(page))
 		return LRU_INACTIVE_FILE;
+	if (PageLazyFree(page))
+		return LRU_LZFREE;
 	return LRU_INACTIVE_ANON;
 }
 
@@ -60,7 +70,7 @@ static inline enum lru_list page_lru_base_type(struct page *page)
  *
  * Used for LRU list index arithmetic.
  *
- * Returns 0 if @lru is anon, 1 if it is file.
+ * Returns 0 if @lru is anon, 1 if it is file, 2 if it is lazyfree
  */
 static inline int lru_index(enum lru_list lru)
 {
@@ -75,6 +85,9 @@ static inline int lru_index(enum lru_list lru)
 	case LRU_ACTIVE_FILE:
 		base = 1;
 		break;
+	case LRU_LZFREE:
+		base = 2;
+		break;
 	default:
 		BUG();
 	}
@@ -94,6 +107,8 @@ static inline int page_off_isolate(struct page *page)
 
 	if (!PageSwapBacked(page))
 		lru = NR_ISOLATED_FILE;
+	else if (PageLazyFree(page))
+		lru = NR_ISOLATED_LZFREE;
 	return lru;
 }
 
@@ -106,10 +121,12 @@ static inline int page_off_isolate(struct page *page)
  */
 static inline int lru_off_isolate(enum lru_list lru)
 {
-	int base = NR_ISOLATED_FILE;
+	int base = NR_ISOLATED_LZFREE;
 
 	if (lru <= LRU_ACTIVE_ANON)
 		base = NR_ISOLATED_ANON;
+	else if (lru <= LRU_ACTIVE_FILE)
+		base = NR_ISOLATED_FILE;
 	return base;
 }
 
@@ -154,6 +171,8 @@ static __always_inline enum lru_list page_lru(struct page *page)
 		lru = page_lru_base_type(page);
 		if (PageActive(page))
 			lru += LRU_ACTIVE;
+		if (lru == LRU_LZFREE + LRU_ACTIVE)
+			lru = LRU_ACTIVE_ANON;
 	}
 	return lru;
 }
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index d94347737292..1aaa436da0d5 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -121,6 +121,7 @@ enum zone_stat_item {
 	NR_INACTIVE_FILE,	/*  "     "     "   "       "         */
 	NR_ACTIVE_FILE,		/*  "     "     "   "       "         */
 	NR_UNEVICTABLE,		/*  "     "     "   "       "         */
+	NR_LZFREE,		/*  "     "     "   "       "         */
 	NR_MLOCK,		/* mlock()ed pages found and moved off LRU */
 	NR_ANON_PAGES,	/* Mapped anonymous pages */
 	NR_FILE_MAPPED,	/* pagecache pages mapped into pagetables.
@@ -140,6 +141,7 @@ enum zone_stat_item {
 	NR_WRITEBACK_TEMP,	/* Writeback using temporary buffers */
 	NR_ISOLATED_ANON,	/* Temporary isolated pages from anon lru */
 	NR_ISOLATED_FILE,	/* Temporary isolated pages from file lru */
+	NR_ISOLATED_LZFREE,	/* Temporary isolated pages from lzfree lru */
 	NR_SHMEM,		/* shmem pages (included tmpfs/GEM pages) */
 	NR_DIRTIED,		/* page dirtyings since bootup */
 	NR_WRITTEN,		/* page writings since bootup */
@@ -178,6 +180,7 @@ enum lru_list {
 	LRU_INACTIVE_FILE = LRU_BASE + LRU_FILE,
 	LRU_ACTIVE_FILE = LRU_BASE + LRU_FILE + LRU_ACTIVE,
 	LRU_UNEVICTABLE,
+	LRU_LZFREE,
 	NR_LRU_LISTS
 };
 
@@ -207,10 +210,11 @@ struct zone_reclaim_stat {
 	 * The higher the rotated/scanned ratio, the more valuable
 	 * that cache is.
 	 *
-	 * The anon LRU stats live in [0], file LRU stats in [1]
+	 * The anon LRU stats live in [0], file LRU stats in [1],
+	 * lazyfree LRU stats in [2]
 	 */
-	unsigned long		recent_rotated[2];
-	unsigned long		recent_scanned[2];
+	unsigned long		recent_rotated[3];
+	unsigned long		recent_scanned[3];
 };
 
 struct lruvec {
@@ -224,6 +228,7 @@ struct lruvec {
 /* Mask used at gathering information at once (see memcontrol.c) */
 #define LRU_ALL_FILE (BIT(LRU_INACTIVE_FILE) | BIT(LRU_ACTIVE_FILE))
 #define LRU_ALL_ANON (BIT(LRU_INACTIVE_ANON) | BIT(LRU_ACTIVE_ANON))
+#define LRU_ALL_LZFREE (BIT(LRU_LZFREE))
 #define LRU_ALL	     ((1 << NR_LRU_LISTS) - 1)
 
 /* Isolate clean file */
diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index 416509e26d6d..14f0643af5c4 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -115,6 +115,9 @@ enum pageflags {
 #endif
 	__NR_PAGEFLAGS,
 
+	/* MADV_FREE */
+	PG_lazyfree = PG_mappedtodisk,
+
 	/* Filesystems */
 	PG_checked = PG_owner_priv_1,
 
@@ -343,6 +346,8 @@ TESTPAGEFLAG_FALSE(Ksm)
 
 u64 stable_page_flags(struct page *page);
 
+PAGEFLAG(LazyFree, lazyfree);
+
 static inline int PageUptodate(struct page *page)
 {
 	int ret = test_bit(PG_uptodate, &(page)->flags);
diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index f4c992826242..edace84b45d5 100644
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -85,7 +85,7 @@ enum ttu_flags {
 	TTU_UNMAP = 1,			/* unmap mode */
 	TTU_MIGRATION = 2,		/* migration mode */
 	TTU_MUNLOCK = 4,		/* munlock mode */
-	TTU_FREE = 8,			/* free mode */
+	TTU_LZFREE = 8,			/* lazyfree mode */
 
 	TTU_IGNORE_MLOCK = (1 << 8),	/* ignore mlock */
 	TTU_IGNORE_ACCESS = (1 << 9),	/* don't age */
diff --git a/include/linux/swap.h b/include/linux/swap.h
index f629df4cc13d..c484339b46b6 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -14,8 +14,8 @@
 #include <asm/page.h>
 
 struct notifier_block;
-
 struct bio;
+struct pagevec;
 
 #define SWAP_FLAG_PREFER	0x8000	/* set if swap priority specified */
 #define SWAP_FLAG_PRIO_MASK	0x7fff
@@ -308,7 +308,8 @@ extern void lru_add_drain_cpu(int cpu);
 extern void lru_add_drain_all(void);
 extern void rotate_reclaimable_page(struct page *page);
 extern void deactivate_file_page(struct page *page);
-extern void deactivate_page(struct page *page);
+extern void drain_lazyfree_pagevec(struct pagevec *pvec);
+extern int add_page_to_lazyfree_list(struct page *page, struct pagevec *pvec);
 extern void swap_setup(void);
 
 extern void add_page_to_unevictable_list(struct page *page);
diff --git a/include/linux/vm_event_item.h b/include/linux/vm_event_item.h
index 2b1cef88b827..7ebfd7ca992d 100644
--- a/include/linux/vm_event_item.h
+++ b/include/linux/vm_event_item.h
@@ -23,9 +23,9 @@
 
 enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
 		FOR_ALL_ZONES(PGALLOC),
-		PGFREE, PGACTIVATE, PGDEACTIVATE,
+		PGFREE, PGACTIVATE, PGDEACTIVATE, PGLZFREE,
 		PGFAULT, PGMAJFAULT,
-		PGLAZYFREED,
+		PGLZFREED,
 		FOR_ALL_ZONES(PGREFILL),
 		FOR_ALL_ZONES(PGSTEAL_KSWAPD),
 		FOR_ALL_ZONES(PGSTEAL_DIRECT),
diff --git a/include/trace/events/vmscan.h b/include/trace/events/vmscan.h
index 4e9e86733849..a7ce9169b0fa 100644
--- a/include/trace/events/vmscan.h
+++ b/include/trace/events/vmscan.h
@@ -12,28 +12,32 @@
 
 #define RECLAIM_WB_ANON		0x0001u
 #define RECLAIM_WB_FILE		0x0002u
+#define RECLAIM_WB_LZFREE	0x0004u
 #define RECLAIM_WB_MIXED	0x0010u
-#define RECLAIM_WB_SYNC		0x0004u /* Unused, all reclaim async */
-#define RECLAIM_WB_ASYNC	0x0008u
+#define RECLAIM_WB_SYNC		0x0040u /* Unused, all reclaim async */
+#define RECLAIM_WB_ASYNC	0x0080u
 
 #define show_reclaim_flags(flags)				\
 	(flags) ? __print_flags(flags, "|",			\
 		{RECLAIM_WB_ANON,	"RECLAIM_WB_ANON"},	\
 		{RECLAIM_WB_FILE,	"RECLAIM_WB_FILE"},	\
+		{RECLAIM_WB_LZFREE,	"RECLAIM_WB_LZFREE"},	\
 		{RECLAIM_WB_MIXED,	"RECLAIM_WB_MIXED"},	\
 		{RECLAIM_WB_SYNC,	"RECLAIM_WB_SYNC"},	\
 		{RECLAIM_WB_ASYNC,	"RECLAIM_WB_ASYNC"}	\
 		) : "RECLAIM_WB_NONE"
 
 #define trace_reclaim_flags(page) ( \
-	(page_is_file_cache(page) ? RECLAIM_WB_FILE : RECLAIM_WB_ANON) | \
-	(RECLAIM_WB_ASYNC) \
+	(page_is_file_cache(page) ? RECLAIM_WB_FILE : \
+		(PageLazyFree(page) ? RECLAIM_WB_LZFREE : \
+		RECLAIM_WB_ANON)) | (RECLAIM_WB_ASYNC) \
 	)
 
-#define trace_shrink_flags(lru) \
+#define trace_shrink_flags(lru_idx) \
 	( \
-		(lru ? RECLAIM_WB_FILE : RECLAIM_WB_ANON) | \
-		(RECLAIM_WB_ASYNC) \
+		(lru_idx == 1 ? RECLAIM_WB_FILE : (lru_idx == 0 ? \
+			RECLAIM_WB_ANON : RECLAIM_WB_LZFREE)) | \
+			(RECLAIM_WB_ASYNC) \
 	)
 
 TRACE_EVENT(mm_vmscan_kswapd_sleep,
diff --git a/mm/compaction.c b/mm/compaction.c
index d888fa248ebb..cc40c766de38 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -626,7 +626,7 @@ isolate_freepages_range(struct compact_control *cc,
 static void acct_isolated(struct zone *zone, struct compact_control *cc)
 {
 	struct page *page;
-	unsigned int count[2] = { 0, };
+	unsigned int count[3] = { 0, };
 
 	if (list_empty(&cc->migratepages))
 		return;
@@ -636,21 +636,25 @@ static void acct_isolated(struct zone *zone, struct compact_control *cc)
 
 	mod_zone_page_state(zone, NR_ISOLATED_ANON, count[0]);
 	mod_zone_page_state(zone, NR_ISOLATED_FILE, count[1]);
+	mod_zone_page_state(zone, NR_ISOLATED_LZFREE, count[2]);
 }
 
 /* Similar to reclaim, but different enough that they don't share logic */
 static bool too_many_isolated(struct zone *zone)
 {
-	unsigned long active, inactive, isolated;
+	unsigned long active, inactive, lzfree, isolated;
 
 	inactive = zone_page_state(zone, NR_INACTIVE_FILE) +
 					zone_page_state(zone, NR_INACTIVE_ANON);
 	active = zone_page_state(zone, NR_ACTIVE_FILE) +
 					zone_page_state(zone, NR_ACTIVE_ANON);
+	lzfree = zone_page_state(zone, NR_LZFREE);
+
 	isolated = zone_page_state(zone, NR_ISOLATED_FILE) +
-					zone_page_state(zone, NR_ISOLATED_ANON);
+			zone_page_state(zone, NR_ISOLATED_ANON) +
+			zone_page_state(zone, NR_ISOLATED_LZFREE);
 
-	return isolated > (inactive + active) / 2;
+	return isolated > (inactive + active + lzfree) / 2;
 }
 
 /**
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 7a48c3d4f92e..4277740494a0 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1454,7 +1454,7 @@ int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 }
 
 int madvise_free_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
-		pmd_t *pmd, unsigned long addr)
+		pmd_t *pmd, unsigned long addr, struct pagevec *pvec)
 
 {
 	spinlock_t *ptl;
@@ -1478,18 +1478,18 @@ int madvise_free_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
 		ClearPageDirty(page);
 	unlock_page(page);
 
-	if (PageActive(page))
-		deactivate_page(page);
-
 	if (pmd_young(orig_pmd) || pmd_dirty(orig_pmd)) {
 		orig_pmd = pmdp_huge_get_and_clear_full(tlb->mm, addr, pmd,
 			tlb->fullmm);
 		orig_pmd = pmd_mkold(orig_pmd);
 		orig_pmd = pmd_mkclean(orig_pmd);
-
+		SetPageDirty(page);
 		set_pmd_at(mm, addr, pmd, orig_pmd);
 		tlb_remove_pmd_tlb_entry(tlb, pmd, addr);
 	}
+
+	add_page_to_lazyfree_list(page, pvec);
+	drain_lazyfree_pagevec(pvec);
 out:
 	spin_unlock(ptl);
 
@@ -1795,6 +1795,7 @@ static void __split_huge_page_refcount(struct page *page,
 				      (1L << PG_mlocked) |
 				      (1L << PG_uptodate) |
 				      (1L << PG_active) |
+				      (1L << PG_lazyfree) |
 				      (1L << PG_unevictable) |
 				      (1L << PG_dirty)));
 
diff --git a/mm/madvise.c b/mm/madvise.c
index 982484fb44ca..e0836c870980 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -21,6 +21,7 @@
 #include <linux/swap.h>
 #include <linux/swapops.h>
 #include <linux/mmu_notifier.h>
+#include <linux/pagevec.h>
 
 #include <asm/tlb.h>
 
@@ -272,12 +273,15 @@ static int madvise_free_pte_range(pmd_t *pmd, unsigned long addr,
 	struct page *page;
 	int nr_swap = 0;
 	unsigned long next;
+	struct pagevec pvec;
+
+	pagevec_init(&pvec, 0);
 
 	next = pmd_addr_end(addr, end);
 	if (pmd_trans_huge(*pmd)) {
 		if (next - addr != HPAGE_PMD_SIZE)
 			split_huge_page_pmd(vma, addr, pmd);
-		else if (!madvise_free_huge_pmd(tlb, vma, pmd, addr))
+		else if (!madvise_free_huge_pmd(tlb, vma, pmd, addr, &pvec))
 			goto next;
 		/* fall through */
 	}
@@ -315,24 +319,17 @@ static int madvise_free_pte_range(pmd_t *pmd, unsigned long addr,
 
 		VM_BUG_ON_PAGE(PageTransCompound(page), page);
 
-		if (PageSwapCache(page) || PageDirty(page)) {
+		if (page_mapcount(page) != 1)
+			continue;
+
+		if (PageSwapCache(page)) {
 			if (!trylock_page(page))
 				continue;
-			/*
-			 * If page is shared with others, we couldn't clear
-			 * PG_dirty of the page.
-			 */
-			if (page_mapcount(page) != 1) {
+			if (PageSwapCache(page) &&
+					!try_to_free_swap(page)) {
 				unlock_page(page);
 				continue;
 			}
-
-			if (PageSwapCache(page) && !try_to_free_swap(page)) {
-				unlock_page(page);
-				continue;
-			}
-
-			ClearPageDirty(page);
 			unlock_page(page);
 		}
 
@@ -348,11 +345,21 @@ static int madvise_free_pte_range(pmd_t *pmd, unsigned long addr,
 
 			ptent = pte_mkold(ptent);
 			ptent = pte_mkclean(ptent);
+			/*
+			 * Page could lost dirty bit without moving
+			 * lazyfree LRU list so the result causes
+			 * freeing the page without paging out.
+			 * So let's move the dirtiness to page->flags.
+			 * If it is moved to lazyfree successfully,
+			 * lru_lazyfree_fn will clear it.
+			 */
+			SetPageDirty(page);
 			set_pte_at(mm, addr, pte, ptent);
-			if (PageActive(page))
-				deactivate_page(page);
 			tlb_remove_tlb_entry(tlb, pte, addr);
 		}
+
+		if (add_page_to_lazyfree_list(page, &pvec) == 0)
+			drain_lazyfree_pagevec(&pvec);
 	}
 
 	if (nr_swap) {
@@ -362,6 +369,7 @@ static int madvise_free_pte_range(pmd_t *pmd, unsigned long addr,
 		add_mm_counter(mm, MM_SWAPENTS, nr_swap);
 	}
 
+	drain_lazyfree_pagevec(&pvec);
 	arch_leave_lazy_mmu_mode();
 	pte_unmap_unlock(pte - 1, ptl);
 	cond_resched();
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index c57c4423c688..1dc599ce1bcb 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -109,6 +109,7 @@ static const char * const mem_cgroup_lru_names[] = {
 	"inactive_file",
 	"active_file",
 	"unevictable",
+	"lazyfree",
 };
 
 #define THRESHOLDS_EVENTS_TARGET 128
@@ -1402,6 +1403,8 @@ static void mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
 static bool test_mem_cgroup_node_reclaimable(struct mem_cgroup *memcg,
 		int nid, bool noswap)
 {
+	if (mem_cgroup_node_nr_lru_pages(memcg, nid, LRU_ALL_LZFREE))
+		return true;
 	if (mem_cgroup_node_nr_lru_pages(memcg, nid, LRU_ALL_FILE))
 		return true;
 	if (noswap || !total_swap_pages)
@@ -3120,6 +3123,7 @@ static int memcg_numa_stat_show(struct seq_file *m, void *v)
 		{ "total", LRU_ALL },
 		{ "file", LRU_ALL_FILE },
 		{ "anon", LRU_ALL_ANON },
+		{ "lazyfree", LRU_ALL_LZFREE },
 		{ "unevictable", BIT(LRU_UNEVICTABLE) },
 	};
 	const struct numa_stat *stat;
@@ -3231,8 +3235,8 @@ static int memcg_stat_show(struct seq_file *m, void *v)
 		int nid, zid;
 		struct mem_cgroup_per_zone *mz;
 		struct zone_reclaim_stat *rstat;
-		unsigned long recent_rotated[2] = {0, 0};
-		unsigned long recent_scanned[2] = {0, 0};
+		unsigned long recent_rotated[3] = {0, 0};
+		unsigned long recent_scanned[3] = {0, 0};
 
 		for_each_online_node(nid)
 			for (zid = 0; zid < MAX_NR_ZONES; zid++) {
@@ -3241,13 +3245,19 @@ static int memcg_stat_show(struct seq_file *m, void *v)
 
 				recent_rotated[0] += rstat->recent_rotated[0];
 				recent_rotated[1] += rstat->recent_rotated[1];
+				recent_rotated[2] += rstat->recent_rotated[2];
 				recent_scanned[0] += rstat->recent_scanned[0];
 				recent_scanned[1] += rstat->recent_scanned[1];
+				recent_scanned[2] += rstat->recent_scanned[2];
 			}
 		seq_printf(m, "recent_rotated_anon %lu\n", recent_rotated[0]);
 		seq_printf(m, "recent_rotated_file %lu\n", recent_rotated[1]);
+		seq_printf(m, "recent_rotated_lzfree %lu\n",
+						recent_rotated[2]);
 		seq_printf(m, "recent_scanned_anon %lu\n", recent_scanned[0]);
 		seq_printf(m, "recent_scanned_file %lu\n", recent_scanned[1]);
+		seq_printf(m, "recent_scanned_lzfree %lu\n",
+						recent_scanned[2]);
 	}
 #endif
 
diff --git a/mm/migrate.c b/mm/migrate.c
index 87ebf0833b84..945e5655cd69 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -508,6 +508,8 @@ void migrate_page_copy(struct page *newpage, struct page *page)
 		SetPageChecked(newpage);
 	if (PageMappedToDisk(page))
 		SetPageMappedToDisk(newpage);
+	if (PageLazyFree(page))
+		SetPageLazyFree(newpage);
 
 	if (PageDirty(page)) {
 		clear_page_dirty_for_io(page);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 48aaf7b9f253..d6a42c905b0b 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3712,6 +3712,7 @@ void show_free_areas(unsigned int filter)
 
 	printk("active_anon:%lu inactive_anon:%lu isolated_anon:%lu\n"
 		" active_file:%lu inactive_file:%lu isolated_file:%lu\n"
+		" lazy_free:%lu isolated_lazyfree:%lu\n"
 		" unevictable:%lu dirty:%lu writeback:%lu unstable:%lu\n"
 		" slab_reclaimable:%lu slab_unreclaimable:%lu\n"
 		" mapped:%lu shmem:%lu pagetables:%lu bounce:%lu\n"
@@ -3722,6 +3723,8 @@ void show_free_areas(unsigned int filter)
 		global_page_state(NR_ACTIVE_FILE),
 		global_page_state(NR_INACTIVE_FILE),
 		global_page_state(NR_ISOLATED_FILE),
+		global_page_state(NR_LZFREE),
+		global_page_state(NR_ISOLATED_LZFREE),
 		global_page_state(NR_UNEVICTABLE),
 		global_page_state(NR_FILE_DIRTY),
 		global_page_state(NR_WRITEBACK),
@@ -3756,9 +3759,11 @@ void show_free_areas(unsigned int filter)
 			" inactive_anon:%lukB"
 			" active_file:%lukB"
 			" inactive_file:%lukB"
+			" lazyfree:%lukB"
 			" unevictable:%lukB"
 			" isolated(anon):%lukB"
 			" isolated(file):%lukB"
+			" isolated(lazy):%lukB"
 			" present:%lukB"
 			" managed:%lukB"
 			" mlocked:%lukB"
@@ -3788,9 +3793,11 @@ void show_free_areas(unsigned int filter)
 			K(zone_page_state(zone, NR_INACTIVE_ANON)),
 			K(zone_page_state(zone, NR_ACTIVE_FILE)),
 			K(zone_page_state(zone, NR_INACTIVE_FILE)),
+			K(zone_page_state(zone, NR_LZFREE)),
 			K(zone_page_state(zone, NR_UNEVICTABLE)),
 			K(zone_page_state(zone, NR_ISOLATED_ANON)),
 			K(zone_page_state(zone, NR_ISOLATED_FILE)),
+			K(zone_page_state(zone, NR_ISOLATED_LZFREE)),
 			K(zone->present_pages),
 			K(zone->managed_pages),
 			K(zone_page_state(zone, NR_MLOCK)),
diff --git a/mm/rmap.c b/mm/rmap.c
index 9449e91839ab..75bd68bc8abc 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1374,10 +1374,17 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 		swp_entry_t entry = { .val = page_private(page) };
 		pte_t swp_pte;
 
-		if (!PageDirty(page) && (flags & TTU_FREE)) {
-			/* It's a freeable page by MADV_FREE */
-			dec_mm_counter(mm, MM_ANONPAGES);
-			goto discard;
+		if ((flags & TTU_LZFREE)) {
+			VM_BUG_ON_PAGE(!PageLazyFree(page), page);
+			if (!PageDirty(page)) {
+				/* It's a freeable page by MADV_FREE */
+				dec_mm_counter(mm, MM_ANONPAGES);
+				goto discard;
+			} else {
+				set_pte_at(mm, address, pte, pteval);
+				ret = SWAP_FAIL;
+				goto out_unmap;
+			}
 		}
 
 		if (PageSwapCache(page)) {
diff --git a/mm/swap.c b/mm/swap.c
index ac1c6be4381f..b88c59c2f1e8 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -45,7 +45,6 @@ int page_cluster;
 static DEFINE_PER_CPU(struct pagevec, lru_add_pvec);
 static DEFINE_PER_CPU(struct pagevec, lru_rotate_pvecs);
 static DEFINE_PER_CPU(struct pagevec, lru_deactivate_file_pvecs);
-static DEFINE_PER_CPU(struct pagevec, lru_deactivate_pvecs);
 
 /*
  * This path almost never happens for VM activity - pages are normally
@@ -508,6 +507,10 @@ static void __activate_page(struct page *page, struct lruvec *lruvec,
 
 		del_page_from_lru_list(page, lruvec, lru);
 		SetPageActive(page);
+		if (lru == LRU_LZFREE) {
+			ClearPageLazyFree(page);
+			lru = LRU_INACTIVE_ANON;
+		}
 		lru += LRU_ACTIVE;
 		add_page_to_lru_list(page, lruvec, lru);
 		trace_mm_lru_activate(page);
@@ -799,20 +802,41 @@ static void lru_deactivate_file_fn(struct page *page, struct lruvec *lruvec,
 	update_page_reclaim_stat(lruvec, lru_index(lru), 0);
 }
 
-
-static void lru_deactivate_fn(struct page *page, struct lruvec *lruvec,
-			    void *arg)
+static void lru_lazyfree_fn(struct page *page, struct lruvec *lruvec,
+		void *arg)
 {
-	if (PageLRU(page) && PageActive(page) && !PageUnevictable(page)) {
-		enum lru_list lru = page_lru_base_type(page);
+	VM_BUG_ON_PAGE(!PageAnon(page), page);
+
+	if (PageLRU(page) && !PageLazyFree(page) &&
+				!PageUnevictable(page)) {
+		unsigned int nr_pages = PageTransHuge(page) ? HPAGE_PMD_NR : 1;
+		bool active = PageActive(page);
 
-		del_page_from_lru_list(page, lruvec, lru + LRU_ACTIVE);
+		if (!trylock_page(page))
+			return;
+		if (PageSwapCache(page))
+			return;
+		if (PageDirty(page)) {
+			/*
+			 * If page is shared with others, we couldn't clear
+			 * PG_dirty of the page.
+			 */
+			if (page_count(page) != 2) {
+				unlock_page(page);
+				return;
+			}
+			ClearPageDirty(page);
+		}
+
+		del_page_from_lru_list(page, lruvec,
+			       LRU_INACTIVE_ANON + active);
 		ClearPageActive(page);
-		ClearPageReferenced(page);
-		add_page_to_lru_list(page, lruvec, lru);
+		SetPageLazyFree(page);
+		add_page_to_lru_list(page, lruvec, LRU_LZFREE);
+		unlock_page(page);
 
-		__count_vm_event(PGDEACTIVATE);
-		update_page_reclaim_stat(lruvec, lru_index(lru), 0);
+		count_vm_events(PGLZFREE, nr_pages);
+		update_page_reclaim_stat(lruvec, 2, 0);
 	}
 }
 
@@ -842,11 +866,25 @@ void lru_add_drain_cpu(int cpu)
 	if (pagevec_count(pvec))
 		pagevec_lru_move_fn(pvec, lru_deactivate_file_fn, NULL);
 
-	pvec = &per_cpu(lru_deactivate_pvecs, cpu);
+	activate_page_drain(cpu);
+}
+
+/*
+ * Drain lazyfree pages out of the cpu's pagevec before release pte lock
+ */
+void drain_lazyfree_pagevec(struct pagevec *pvec)
+{
 	if (pagevec_count(pvec))
-		pagevec_lru_move_fn(pvec, lru_deactivate_fn, NULL);
+		pagevec_lru_move_fn(pvec, lru_lazyfree_fn, NULL);
+}
 
-	activate_page_drain(cpu);
+int add_page_to_lazyfree_list(struct page *page, struct pagevec *pvec)
+{
+	if (PageLRU(page) && !PageLazyFree(page) && !PageUnevictable(page)) {
+		page_cache_get(page);
+		pagevec_add(pvec, page);
+	}
+	return pagevec_space(pvec);
 }
 
 /**
@@ -875,26 +913,6 @@ void deactivate_file_page(struct page *page)
 	}
 }
 
-/**
- * deactivate_page - deactivate a page
- * @page: page to deactivate
- *
- * deactivate_page() moves @page to the inactive list if @page was on the active
- * list and was not an unevictable page.  This is done to accelerate the reclaim
- * of @page.
- */
-void deactivate_page(struct page *page)
-{
-	if (PageLRU(page) && PageActive(page) && !PageUnevictable(page)) {
-		struct pagevec *pvec = &get_cpu_var(lru_deactivate_pvecs);
-
-		page_cache_get(page);
-		if (!pagevec_add(pvec, page))
-			pagevec_lru_move_fn(pvec, lru_deactivate_fn, NULL);
-		put_cpu_var(lru_deactivate_pvecs);
-	}
-}
-
 void lru_add_drain(void)
 {
 	lru_add_drain_cpu(get_cpu());
@@ -924,7 +942,6 @@ void lru_add_drain_all(void)
 		if (pagevec_count(&per_cpu(lru_add_pvec, cpu)) ||
 		    pagevec_count(&per_cpu(lru_rotate_pvecs, cpu)) ||
 		    pagevec_count(&per_cpu(lru_deactivate_file_pvecs, cpu)) ||
-		    pagevec_count(&per_cpu(lru_deactivate_pvecs, cpu)) ||
 		    need_activate_page_drain(cpu)) {
 			INIT_WORK(work, lru_add_drain_per_cpu);
 			schedule_work_on(cpu, work);
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 80dff84ba673..8efe30ceec3a 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -197,7 +197,8 @@ static unsigned long zone_reclaimable_pages(struct zone *zone)
 	int nr;
 
 	nr = zone_page_state(zone, NR_ACTIVE_FILE) +
-	     zone_page_state(zone, NR_INACTIVE_FILE);
+		zone_page_state(zone, NR_INACTIVE_FILE) +
+		zone_page_state(zone, NR_LZFREE);
 
 	if (get_nr_swap_pages() > 0)
 		nr += zone_page_state(zone, NR_ACTIVE_ANON) +
@@ -918,6 +919,8 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 
 		VM_BUG_ON_PAGE(PageActive(page), page);
 		VM_BUG_ON_PAGE(page_zone(page) != zone, page);
+		VM_BUG_ON_PAGE((ttu_flags & TTU_LZFREE) &&
+				!PageLazyFree(page), page);
 
 		sc->nr_scanned++;
 
@@ -1050,7 +1053,8 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 				goto keep_locked;
 			if (!add_to_swap(page, page_list))
 				goto activate_locked;
-			freeable = true;
+			if (ttu_flags & TTU_LZFREE)
+				freeable = true;
 			may_enter_fs = 1;
 
 			/* Adding to swap updated mapping */
@@ -1063,8 +1067,9 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		 */
 		if (page_mapped(page) && mapping) {
 			switch (try_to_unmap(page, freeable ?
-				(ttu_flags | TTU_BATCH_FLUSH | TTU_FREE) :
-				(ttu_flags | TTU_BATCH_FLUSH))) {
+				(ttu_flags | TTU_BATCH_FLUSH) :
+				((ttu_flags & ~TTU_LZFREE) |
+						TTU_BATCH_FLUSH))) {
 			case SWAP_FAIL:
 				goto activate_locked;
 			case SWAP_AGAIN:
@@ -1190,7 +1195,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		__clear_page_locked(page);
 free_it:
 		if (freeable && !PageDirty(page))
-			count_vm_event(PGLAZYFREED);
+			count_vm_event(PGLZFREED);
 
 		nr_reclaimed++;
 
@@ -1458,7 +1463,7 @@ int isolate_lru_page(struct page *page)
  * the LRU list will go small and be scanned faster than necessary, leading to
  * unnecessary swapping, thrashing and OOM.
  */
-static int too_many_isolated(struct zone *zone, int file,
+static int too_many_isolated(struct zone *zone, int lru_index,
 		struct scan_control *sc)
 {
 	unsigned long inactive, isolated;
@@ -1469,12 +1474,21 @@ static int too_many_isolated(struct zone *zone, int file,
 	if (!sane_reclaim(sc))
 		return 0;
 
-	if (file) {
-		inactive = zone_page_state(zone, NR_INACTIVE_FILE);
-		isolated = zone_page_state(zone, NR_ISOLATED_FILE);
-	} else {
+	switch (lru_index) {
+	case 0:
 		inactive = zone_page_state(zone, NR_INACTIVE_ANON);
 		isolated = zone_page_state(zone, NR_ISOLATED_ANON);
+		break;
+	case 1:
+		inactive = zone_page_state(zone, NR_INACTIVE_FILE);
+		isolated = zone_page_state(zone, NR_ISOLATED_FILE);
+		break;
+	case 2:
+		inactive = zone_page_state(zone, NR_LZFREE);
+		isolated = zone_page_state(zone, NR_ISOLATED_LZFREE);
+		break;
+	default:
+		BUG_ON(lru_index);
 	}
 
 	/*
@@ -1489,7 +1503,8 @@ static int too_many_isolated(struct zone *zone, int file,
 }
 
 static noinline_for_stack void
-putback_inactive_pages(struct lruvec *lruvec, struct list_head *page_list)
+putback_inactive_pages(struct lruvec *lruvec, enum lru_list old_lru,
+			struct list_head *page_list)
 {
 	struct zone_reclaim_stat *reclaim_stat = &lruvec->reclaim_stat;
 	struct zone *zone = lruvec_zone(lruvec);
@@ -1500,7 +1515,7 @@ putback_inactive_pages(struct lruvec *lruvec, struct list_head *page_list)
 	 */
 	while (!list_empty(page_list)) {
 		struct page *page = lru_to_page(page_list);
-		int lru;
+		int new_lru;
 
 		VM_BUG_ON_PAGE(PageLRU(page), page);
 		list_del(&page->lru);
@@ -1514,18 +1529,20 @@ putback_inactive_pages(struct lruvec *lruvec, struct list_head *page_list)
 		lruvec = mem_cgroup_page_lruvec(page, zone);
 
 		SetPageLRU(page);
-		lru = page_lru(page);
-		add_page_to_lru_list(page, lruvec, lru);
+		new_lru = page_lru(page);
+		if (old_lru == LRU_LZFREE && new_lru == LRU_ACTIVE_ANON)
+			ClearPageLazyFree(page);
 
-		if (is_active_lru(lru)) {
+		add_page_to_lru_list(page, lruvec, new_lru);
+		if (PageActive(page)) {
 			int numpages = hpage_nr_pages(page);
-			reclaim_stat->recent_rotated[lru_index(lru)]
+			reclaim_stat->recent_rotated[lru_index(old_lru)]
 				+= numpages;
 		}
 		if (put_page_testzero(page)) {
 			__ClearPageLRU(page);
 			__ClearPageActive(page);
-			del_page_from_lru_list(page, lruvec, lru);
+			del_page_from_lru_list(page, lruvec, new_lru);
 
 			if (unlikely(PageCompound(page))) {
 				spin_unlock_irq(&zone->lru_lock);
@@ -1578,7 +1595,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 	struct zone *zone = lruvec_zone(lruvec);
 	struct zone_reclaim_stat *reclaim_stat = &lruvec->reclaim_stat;
 
-	while (unlikely(too_many_isolated(zone, file, sc))) {
+	while (unlikely(too_many_isolated(zone, lru_index(lru), sc))) {
 		congestion_wait(BLK_RW_ASYNC, HZ/10);
 
 		/* We are about to die and free our memory. Return now. */
@@ -1613,7 +1630,10 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 	if (nr_taken == 0)
 		return 0;
 
-	nr_reclaimed = shrink_page_list(&page_list, zone, sc, TTU_UNMAP,
+	nr_reclaimed = shrink_page_list(&page_list, zone, sc,
+				(lru != LRU_LZFREE) ?
+				TTU_UNMAP :
+				TTU_UNMAP|TTU_LZFREE,
 				&nr_dirty, &nr_unqueued_dirty, &nr_congested,
 				&nr_writeback, &nr_immediate,
 				false);
@@ -1631,7 +1651,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 					       nr_reclaimed);
 	}
 
-	putback_inactive_pages(lruvec, &page_list);
+	putback_inactive_pages(lruvec, lru, &page_list);
 
 	__mod_zone_page_state(zone, lru_off_isolate(lru), -nr_taken);
 
@@ -1701,7 +1721,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 		zone_idx(zone),
 		nr_scanned, nr_reclaimed,
 		sc->priority,
-		trace_shrink_flags(lru));
+		trace_shrink_flags(lru_index(lru)));
 	return nr_reclaimed;
 }
 
@@ -2194,6 +2214,7 @@ static void shrink_lruvec(struct lruvec *lruvec, int swappiness,
 	unsigned long nr[NR_LRU_LISTS];
 	unsigned long targets[NR_LRU_LISTS];
 	unsigned long nr_to_scan;
+	unsigned long nr_to_scan_lzfree;
 	enum lru_list lru;
 	unsigned long nr_reclaimed = 0;
 	unsigned long nr_to_reclaim = sc->nr_to_reclaim;
@@ -2204,6 +2225,7 @@ static void shrink_lruvec(struct lruvec *lruvec, int swappiness,
 
 	/* Record the original scan target for proportional adjustments later */
 	memcpy(targets, nr, sizeof(nr));
+	nr_to_scan_lzfree = get_lru_size(lruvec, LRU_LZFREE);
 
 	/*
 	 * Global reclaiming within direct reclaim at DEF_PRIORITY is a normal
@@ -2221,6 +2243,19 @@ static void shrink_lruvec(struct lruvec *lruvec, int swappiness,
 
 	init_tlb_ubc();
 
+	while (nr_to_scan_lzfree) {
+		nr_to_scan = min(nr_to_scan_lzfree, SWAP_CLUSTER_MAX);
+		nr_to_scan_lzfree -= nr_to_scan;
+
+		nr_reclaimed += shrink_inactive_list(nr_to_scan, lruvec,
+						sc, LRU_LZFREE);
+	}
+
+	if (nr_reclaimed >= nr_to_reclaim) {
+		sc->nr_reclaimed += nr_reclaimed;
+		return;
+	}
+
 	blk_start_plug(&plug);
 	while (nr[LRU_INACTIVE_ANON] || nr[LRU_ACTIVE_FILE] ||
 					nr[LRU_INACTIVE_FILE]) {
@@ -2364,6 +2399,7 @@ static inline bool should_continue_reclaim(struct zone *zone,
 	 */
 	pages_for_compaction = (2UL << sc->order);
 	inactive_lru_pages = zone_page_state(zone, NR_INACTIVE_FILE);
+	inactive_lru_pages += zone_page_state(zone, NR_LZFREE);
 	if (get_nr_swap_pages() > 0)
 		inactive_lru_pages += zone_page_state(zone, NR_INACTIVE_ANON);
 	if (sc->nr_reclaimed < pages_for_compaction &&
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 59d45b22355f..df95d9473bba 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -704,6 +704,7 @@ const char * const vmstat_text[] = {
 	"nr_inactive_file",
 	"nr_active_file",
 	"nr_unevictable",
+	"nr_lazyfree",
 	"nr_mlock",
 	"nr_anon_pages",
 	"nr_mapped",
@@ -721,6 +722,7 @@ const char * const vmstat_text[] = {
 	"nr_writeback_temp",
 	"nr_isolated_anon",
 	"nr_isolated_file",
+	"nr_isolated_lazyfree",
 	"nr_shmem",
 	"nr_dirtied",
 	"nr_written",
@@ -756,6 +758,7 @@ const char * const vmstat_text[] = {
 	"pgfree",
 	"pgactivate",
 	"pgdeactivate",
+	"pglazyfree",
 
 	"pgfault",
 	"pgmajfault",
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
