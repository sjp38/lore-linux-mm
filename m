Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id D64156B0037
	for <linux-mm@kvack.org>; Thu, 11 Jul 2013 22:04:15 -0400 (EDT)
From: Robin Holt <holt@sgi.com>
Subject: [RFC 4/4] Sparse initialization of struct page array.
Date: Thu, 11 Jul 2013 21:03:55 -0500
Message-Id: <1373594635-131067-5-git-send-email-holt@sgi.com>
In-Reply-To: <1373594635-131067-1-git-send-email-holt@sgi.com>
References: <1373594635-131067-1-git-send-email-holt@sgi.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>
Cc: Robin Holt <holt@sgi.com>, Nate Zimmer <nzimmer@sgi.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Rob Landley <rob@landley.net>, Mike Travis <travis@sgi.com>, Daniel J Blueman <daniel@numascale-asia.com>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, Yinghai Lu <yinghai@kernel.org>, Mel Gorman <mgorman@suse.de>

During boot of large memory machines, a significant portion of boot
is spent initializing the struct page array.  The vast majority of
those pages are not referenced during boot.

Change this over to only initializing the pages when they are
actually allocated.

Besides the advantage of boot speed, this allows us the chance to
use normal performance monitoring tools to determine where the bulk
of time is spent during page initialization.

Signed-off-by: Robin Holt <holt@sgi.com>
Signed-off-by: Nate Zimmer <nzimmer@sgi.com>
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
 include/linux/mm.h         |  11 +++++
 include/linux/page-flags.h |   5 +-
 mm/nobootmem.c             |   5 ++
 mm/page_alloc.c            | 117 +++++++++++++++++++++++++++++++++++++++++++--
 4 files changed, 132 insertions(+), 6 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index e0c8528..3de08b5 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1330,8 +1330,19 @@ static inline void __free_reserved_page(struct page *page)
 	__free_page(page);
 }
 
+extern void __reserve_bootmem_region(phys_addr_t start, phys_addr_t end);
+
+static inline void __reserve_bootmem_page(struct page *page)
+{
+	phys_addr_t start = page_to_pfn(page) << PAGE_SHIFT;
+	phys_addr_t end = start + PAGE_SIZE;
+
+	__reserve_bootmem_region(start, end);
+}
+
 static inline void free_reserved_page(struct page *page)
 {
+	__reserve_bootmem_page(page);
 	__free_reserved_page(page);
 	adjust_managed_page_count(page, 1);
 }
diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index 6d53675..79e8eb7 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -83,6 +83,7 @@ enum pageflags {
 	PG_owner_priv_1,	/* Owner use. If pagecache, fs may use*/
 	PG_arch_1,
 	PG_reserved,
+	PG_uninitialized2mib,	/* Is this the right spot? ntz - Yes - rmh */
 	PG_private,		/* If pagecache, has fs-private data */
 	PG_private_2,		/* If pagecache, has fs aux data */
 	PG_writeback,		/* Page is under writeback */
@@ -211,6 +212,8 @@ PAGEFLAG(SwapBacked, swapbacked) __CLEARPAGEFLAG(SwapBacked, swapbacked)
 
 __PAGEFLAG(SlobFree, slob_free)
 
+PAGEFLAG(Uninitialized2Mib, uninitialized2mib)
+
 /*
  * Private page markings that may be used by the filesystem that owns the page
  * for its own purposes.
@@ -499,7 +502,7 @@ static inline void ClearPageSlabPfmemalloc(struct page *page)
 #define PAGE_FLAGS_CHECK_AT_FREE \
 	(1 << PG_lru	 | 1 << PG_locked    | \
 	 1 << PG_private | 1 << PG_private_2 | \
-	 1 << PG_writeback | 1 << PG_reserved | \
+	 1 << PG_writeback | 1 << PG_reserved | 1 << PG_uninitialized2mib | \
 	 1 << PG_slab	 | 1 << PG_swapcache | 1 << PG_active | \
 	 1 << PG_unevictable | __PG_MLOCKED | __PG_HWPOISON | \
 	 __PG_COMPOUND_LOCK)
diff --git a/mm/nobootmem.c b/mm/nobootmem.c
index 3b512ca..e3a386d 100644
--- a/mm/nobootmem.c
+++ b/mm/nobootmem.c
@@ -126,6 +126,9 @@ static unsigned long __init free_low_memory_core_early(void)
 	phys_addr_t start, end, size;
 	u64 i;
 
+	for_each_reserved_mem_region(i, &start, &end)
+		__reserve_bootmem_region(start, end);
+
 	for_each_free_mem_range(i, MAX_NUMNODES, &start, &end, NULL)
 		count += __free_memory_core(start, end);
 
@@ -162,6 +165,8 @@ unsigned long __init free_all_bootmem(void)
 {
 	struct pglist_data *pgdat;
 
+	memblock_dump_all();
+
 	for_each_online_pgdat(pgdat)
 		reset_node_lowmem_managed_pages(pgdat);
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 635b131..fe51eb9 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -740,6 +740,54 @@ static void __init_single_page(struct page *page, unsigned long zone, int nid, i
 #endif
 }
 
+static void expand_page_initialization(struct page *basepage)
+{
+	unsigned long pfn = page_to_pfn(basepage);
+	unsigned long end_pfn = pfn + PTRS_PER_PMD;
+	unsigned long zone = page_zonenum(basepage);
+	int reserved = PageReserved(basepage);
+	int nid = page_to_nid(basepage);
+
+	ClearPageUninitialized2Mib(basepage);
+
+	for( pfn++; pfn < end_pfn; pfn++ )
+		__init_single_page(pfn_to_page(pfn), zone, nid, reserved);
+}
+
+void ensure_pages_are_initialized(unsigned long start_pfn,
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
+			if(PageUninitialized2Mib(page))
+				expand_page_initialization(page);
+		}
+
+		aligned_start_pfn += PTRS_PER_PMD;
+	}
+}
+
+void __reserve_bootmem_region(phys_addr_t start, phys_addr_t end)
+{
+	unsigned long start_pfn = PFN_DOWN(start);
+	unsigned long end_pfn = PFN_UP(end);
+
+	ensure_pages_are_initialized(start_pfn, end_pfn);
+}
+
+static inline void ensure_page_is_initialized(struct page *page)
+{
+	__reserve_bootmem_page(page);
+}
+
 static bool free_pages_prepare(struct page *page, unsigned int order)
 {
 	int i;
@@ -751,7 +799,10 @@ static bool free_pages_prepare(struct page *page, unsigned int order)
 	if (PageAnon(page))
 		page->mapping = NULL;
 	for (i = 0; i < (1 << order); i++)
-		bad += free_pages_check(page + i);
+		if (PageUninitialized2Mib(page + i))
+			i += PTRS_PER_PMD - 1;
+		else
+			bad += free_pages_check(page + i);
 	if (bad)
 		return false;
 
@@ -795,13 +846,22 @@ void __meminit __free_pages_bootmem(struct page *page, unsigned int order)
 	unsigned int loop;
 
 	prefetchw(page);
-	for (loop = 0; loop < nr_pages; loop++) {
+	for (loop = 0; loop < nr_pages; ) {
 		struct page *p = &page[loop];
 
 		if (loop + 1 < nr_pages)
 			prefetchw(p + 1);
+
+		if ((PageUninitialized2Mib(p)) &&
+		    ((loop + PTRS_PER_PMD) > nr_pages))
+			ensure_page_is_initialized(p);
+
 		__ClearPageReserved(p);
 		set_page_count(p, 0);
+		if (PageUninitialized2Mib(p))
+			loop += PTRS_PER_PMD;
+		else
+			loop += 1;
 	}
 
 	page_zone(page)->managed_pages += 1 << order;
@@ -856,6 +916,7 @@ static inline void expand(struct zone *zone, struct page *page,
 		area--;
 		high--;
 		size >>= 1;
+		ensure_page_is_initialized(page);
 		VM_BUG_ON(bad_range(zone, &page[size]));
 
 #ifdef CONFIG_DEBUG_PAGEALLOC
@@ -903,6 +964,10 @@ static int prep_new_page(struct page *page, int order, gfp_t gfp_flags)
 
 	for (i = 0; i < (1 << order); i++) {
 		struct page *p = page + i;
+
+		if (PageUninitialized2Mib(p))
+			expand_page_initialization(page);
+
 		if (unlikely(check_new_page(p)))
 			return 1;
 	}
@@ -985,6 +1050,7 @@ int move_freepages(struct zone *zone,
 	unsigned long order;
 	int pages_moved = 0;
 
+	ensure_pages_are_initialized(page_to_pfn(start_page), page_to_pfn(end_page));
 #ifndef CONFIG_HOLES_IN_ZONE
 	/*
 	 * page_zone is not safe to call in this context when
@@ -3859,6 +3925,9 @@ static int pageblock_is_reserved(unsigned long start_pfn, unsigned long end_pfn)
 	for (pfn = start_pfn; pfn < end_pfn; pfn++) {
 		if (!pfn_valid_within(pfn) || PageReserved(pfn_to_page(pfn)))
 			return 1;
+
+		if (PageUninitialized2Mib(pfn_to_page(pfn)))
+			pfn += PTRS_PER_PMD;
 	}
 	return 0;
 }
@@ -3947,6 +4016,29 @@ static void setup_zone_migrate_reserve(struct zone *zone)
 	}
 }
 
+int __meminit pfn_range_init_avail(unsigned long pfn, unsigned long end_pfn,
+				   unsigned long size, int nid)
+{
+	unsigned long validate_end_pfn = pfn + size;
+
+	if (pfn & (size - 1))
+		return 1;
+
+	if (pfn + size >= end_pfn)
+		return 1;
+
+	while (pfn < validate_end_pfn)
+	{
+		if (!early_pfn_valid(pfn))
+			return 1;
+		if (!early_pfn_in_nid(pfn, nid))
+			return 1;
+		pfn++;
+ 	}
+
+	return size;
+}
+
 /*
  * Initially all pages are reserved - free ones are freed
  * up by free_all_bootmem() once the early boot process is
@@ -3964,20 +4056,34 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
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
 		page = pfn_to_page(pfn);
 		__init_single_page(page, zone, nid, 1);
+
+		if (pfns > 1)
+			SetPageUninitialized2Mib(page);
+
+		pfn += pfns;
 	}
 }
 
@@ -6196,6 +6302,7 @@ static const struct trace_print_flags pageflag_names[] = {
 	{1UL << PG_owner_priv_1,	"owner_priv_1"	},
 	{1UL << PG_arch_1,		"arch_1"	},
 	{1UL << PG_reserved,		"reserved"	},
+	{1UL << PG_uninitialized2mib,	"Uninit_2MiB"	},
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
