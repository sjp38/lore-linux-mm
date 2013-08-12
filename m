Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id E52BC6B003B
	for <linux-mm@kvack.org>; Mon, 12 Aug 2013 17:54:44 -0400 (EDT)
From: Nathan Zimmer <nzimmer@sgi.com>
Subject: [RFC v3 5/5] Sparse initialization of struct page array.
Date: Mon, 12 Aug 2013 16:54:40 -0500
Message-Id: <1376344480-156708-6-git-send-email-nzimmer@sgi.com>
In-Reply-To: <1376344480-156708-1-git-send-email-nzimmer@sgi.com>
References: <1375465467-40488-1-git-send-email-nzimmer@sgi.com>
 <1376344480-156708-1-git-send-email-nzimmer@sgi.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hpa@zytor.com, mingo@kernel.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, holt@sgi.com, nzimmer@sgi.com, rob@landley.net, travis@sgi.com, daniel@numascale-asia.com, akpm@linux-foundation.org, gregkh@linuxfoundation.org, yinghai@kernel.org, mgorman@suse.de

From: Robin Holt <holt@sgi.com>

During boot of large memory machines, a significant portion of boot
is spent initializing the struct page array.  The vast majority of
those pages are not referenced during boot.

Change this over to only initializing the pages when they are
actually allocated.

Besides the advantage of boot speed, this allows us the chance to
use normal performance monitoring tools to determine where the bulk
of time is spent during page initialization.

Signed-off-by: Robin Holt <holt@sgi.com>
Signed-off-by: Nathan Zimmer <nzimmer@sgi.com>
To: "H. Peter Anvin" <hpa@zytor.com>
To: Ingo Molnar <mingo@kernel.org>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>
Cc: Linux MM <linux-mm@kvack.org>
Cc: Rob Landley <rob@landley.net>
Cc: Mike Travis <travis@sgi.com>
Cc: Daniel J Blueman <daniel@numascale-asia.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Greg KH <gregkh@linuxfoundation.org>
Cc: Yinghai Lu <yinghai@kernel.org>
Cc: Mel Gorman <mgorman@suse.de>
---
 include/linux/page-flags.h |   5 +-
 mm/page_alloc.c            | 116 +++++++++++++++++++++++++++++++++++++++++++--
 2 files changed, 115 insertions(+), 6 deletions(-)

diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index 6d53675..d592065 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -83,6 +83,7 @@ enum pageflags {
 	PG_owner_priv_1,	/* Owner use. If pagecache, fs may use*/
 	PG_arch_1,
 	PG_reserved,
+	PG_uninitialized_2m,
 	PG_private,		/* If pagecache, has fs-private data */
 	PG_private_2,		/* If pagecache, has fs aux data */
 	PG_writeback,		/* Page is under writeback */
@@ -211,6 +212,8 @@ PAGEFLAG(SwapBacked, swapbacked) __CLEARPAGEFLAG(SwapBacked, swapbacked)
 
 __PAGEFLAG(SlobFree, slob_free)
 
+PAGEFLAG(Uninitialized2m, uninitialized_2m)
+
 /*
  * Private page markings that may be used by the filesystem that owns the page
  * for its own purposes.
@@ -499,7 +502,7 @@ static inline void ClearPageSlabPfmemalloc(struct page *page)
 #define PAGE_FLAGS_CHECK_AT_FREE \
 	(1 << PG_lru	 | 1 << PG_locked    | \
 	 1 << PG_private | 1 << PG_private_2 | \
-	 1 << PG_writeback | 1 << PG_reserved | \
+	 1 << PG_writeback | 1 << PG_reserved | 1 << PG_uninitialized_2m | \
 	 1 << PG_slab	 | 1 << PG_swapcache | 1 << PG_active | \
 	 1 << PG_unevictable | __PG_MLOCKED | __PG_HWPOISON | \
 	 __PG_COMPOUND_LOCK)
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 227bd39..6c35a58 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -737,11 +737,53 @@ static void __init_single_page(unsigned long pfn, unsigned long zone,
 #endif
 }
 
+static void __expand_page_initialization(struct page *basepage)
+{
+	unsigned long pfn = page_to_pfn(basepage);
+	unsigned long end_pfn = pfn + PTRS_PER_PMD;
+	unsigned long zone = page_zonenum(basepage);
+	int count = page_count(basepage);
+	int nid = page_to_nid(basepage);
+
+	ClearPageUninitialized2m(basepage);
+
+	for (pfn++; pfn < end_pfn; pfn++)
+		__init_single_page(pfn, zone, nid, count);
+}
+
+static void ensure_pages_are_initialized(unsigned long start_pfn,
+				  unsigned long end_pfn)
+{
+	unsigned long aligned_start_pfn = start_pfn & ~(PTRS_PER_PMD - 1);
+	unsigned long aligned_end_pfn;
+	struct page *page;
+
+	aligned_end_pfn = end_pfn & ~(PTRS_PER_PMD - 1);
+	aligned_end_pfn += PTRS_PER_PMD;
+	while (aligned_start_pfn < aligned_end_pfn) {
+		if (pfn_valid(aligned_start_pfn)) {
+			page = pfn_to_page(aligned_start_pfn);
+
+			if (PageUninitialized2m(page))
+				__expand_page_initialization(page);
+		}
+
+		aligned_start_pfn += PTRS_PER_PMD;
+	}
+}
+
+static inline void ensure_page_is_initialized(struct page *page)
+{
+	ensure_pages_are_initialized(page_to_pfn(page), page_to_pfn(page));
+}
+
 void reserve_bootmem_region(unsigned long start, unsigned long end)
 {
 	unsigned long start_pfn = PFN_DOWN(start);
 	unsigned long end_pfn = PFN_UP(end);
 
+	ensure_pages_are_initialized(start_pfn, end_pfn);
+
 	for (; start_pfn < end_pfn; start_pfn++)
 		if (pfn_valid(start_pfn))
 			SetPageReserved(pfn_to_page(start_pfn));
@@ -758,7 +800,10 @@ static bool free_pages_prepare(struct page *page, unsigned int order)
 	if (PageAnon(page))
 		page->mapping = NULL;
 	for (i = 0; i < (1 << order); i++)
-		bad += free_pages_check(page + i);
+		if (PageUninitialized2m(page + i))
+			i += PTRS_PER_PMD - 1;
+		else
+			bad += free_pages_check(page + i);
 	if (bad)
 		return false;
 
@@ -802,13 +847,22 @@ void __meminit __free_pages_bootmem(struct page *page, unsigned int order)
 	unsigned int loop;
 
 	prefetchw(page);
-	for (loop = 0; loop < nr_pages; loop++) {
+	for (loop = 0; loop < nr_pages; ) {
 		struct page *p = &page[loop];
 
 		if (loop + 1 < nr_pages)
 			prefetchw(p + 1);
+
+		if ((PageUninitialized2m(p)) &&
+		    ((loop + PTRS_PER_PMD) > nr_pages))
+			ensure_page_is_initialized(p);
+
 		__ClearPageReserved(p);
 		set_page_count(p, 0);
+		if (PageUninitialized2m(p))
+			loop += PTRS_PER_PMD;
+		else
+			loop += 1;
 	}
 
 	page_zone(page)->managed_pages += 1 << order;
@@ -863,6 +917,7 @@ static inline void expand(struct zone *zone, struct page *page,
 		area--;
 		high--;
 		size >>= 1;
+		ensure_page_is_initialized(&page[size]);
 		VM_BUG_ON(bad_range(zone, &page[size]));
 
 #ifdef CONFIG_DEBUG_PAGEALLOC
@@ -908,8 +963,11 @@ static int prep_new_page(struct page *page, int order, gfp_t gfp_flags)
 {
 	int i;
 
+	ensure_pages_are_initialized(page_to_pfn(page),
+				     page_to_pfn(page+(1<<order)-1));
 	for (i = 0; i < (1 << order); i++) {
 		struct page *p = page + i;
+
 		if (unlikely(check_new_page(p)))
 			return 1;
 	}
@@ -992,6 +1050,8 @@ int move_freepages(struct zone *zone,
 	unsigned long order;
 	int pages_moved = 0;
 
+	ensure_pages_are_initialized(page_to_pfn(start_page),
+				     page_to_pfn(end_page));
 #ifndef CONFIG_HOLES_IN_ZONE
 	/*
 	 * page_zone is not safe to call in this context when
@@ -3905,6 +3965,9 @@ static int pageblock_is_reserved(unsigned long start_pfn, unsigned long end_pfn)
 	for (pfn = start_pfn; pfn < end_pfn; pfn++) {
 		if (!pfn_valid_within(pfn) || PageReserved(pfn_to_page(pfn)))
 			return 1;
+
+		if (PageUninitialized2m(pfn_to_page(pfn)))
+			pfn += PTRS_PER_PMD;
 	}
 	return 0;
 }
@@ -3994,6 +4057,34 @@ static void setup_zone_migrate_reserve(struct zone *zone)
 }
 
 /*
+ * This function tells us if we have many pfns we have available.
+ * Available meaning valid and on the specified node.
+ * It return either size if that many pfns are available, 1 otherwise
+ */
+static int __meminit pfn_range_init_avail(unsigned long pfn,
+				unsigned long end_pfn,
+				unsigned long size, int nid)
+{
+	unsigned long validate_end_pfn = pfn + size;
+
+	if (pfn & (size - 1))
+		return 1;
+
+	if (pfn + size >= end_pfn)
+		return 1;
+
+	while (pfn < validate_end_pfn) {
+		if (!early_pfn_valid(pfn))
+			return 1;
+		if (!early_pfn_in_nid(pfn, nid))
+			return 1;
+		pfn++;
+	}
+
+	return size;
+}
+
+/*
  * Initially all pages are reserved - free ones are freed
  * up by free_all_bootmem() once the early boot process is
  * done. Non-atomic initialization, single-pass.
@@ -4009,19 +4100,33 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
 		highest_memmap_pfn = end_pfn - 1;
 
 	z = &NODE_DATA(nid)->node_zones[zone];
-	for (pfn = start_pfn; pfn < end_pfn; pfn++) {
+	for (pfn = start_pfn; pfn < end_pfn; ) {
 		/*
 		 * There can be holes in boot-time mem_map[]s
 		 * handed to this function.  They do not
 		 * exist on hotplugged memory.
 		 */
+		int pfns = 1;
 		if (context == MEMMAP_EARLY) {
-			if (!early_pfn_valid(pfn))
+			if (!early_pfn_valid(pfn)) {
+				pfn++;
 				continue;
-			if (!early_pfn_in_nid(pfn, nid))
+			}
+			if (!early_pfn_in_nid(pfn, nid)) {
+				pfn++;
 				continue;
+			}
+
+			pfns = pfn_range_init_avail(pfn, end_pfn,
+						    PTRS_PER_PMD, nid);
 		}
+
 		__init_single_page(pfn, zone, nid, 1);
+
+		if (pfns > 1)
+			SetPageUninitialized2m(pfn_to_page(pfn));
+
+		pfn += pfns;
 	}
 }
 
@@ -6240,6 +6345,7 @@ static const struct trace_print_flags pageflag_names[] = {
 	{1UL << PG_owner_priv_1,	"owner_priv_1"	},
 	{1UL << PG_arch_1,		"arch_1"	},
 	{1UL << PG_reserved,		"reserved"	},
+	{1UL << PG_uninitialized_2m,	"uninitialized_2m"	},
 	{1UL << PG_private,		"private"	},
 	{1UL << PG_private_2,		"private_2"	},
 	{1UL << PG_writeback,		"writeback"	},
-- 
1.8.2.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
