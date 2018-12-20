Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id AF4A78E0003
	for <linux-mm@kvack.org>; Thu, 20 Dec 2018 01:03:16 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id r145so693599qke.20
        for <linux-mm@kvack.org>; Wed, 19 Dec 2018 22:03:16 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r41sor6132055qtj.20.2018.12.19.22.03.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 19 Dec 2018 22:03:15 -0800 (PST)
From: Qian Cai <cai@lca.pw>
Subject: [PATCH] mm/page_owner: fix for deferred struct page init
Date: Thu, 20 Dec 2018 01:03:03 -0500
Message-Id: <20181220060303.38686-1-cai@lca.pw>
In-Reply-To: <cbfacb4b-dbfd-f68f-3d1e-05e137feca18@lca.pw>
References: <cbfacb4b-dbfd-f68f-3d1e-05e137feca18@lca.pw>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Pavel.Tatashin@microsoft.com, mingo@kernel.org, mhocko@suse.com, hpa@zytor.com, mgorman@techsingularity.net, tglx@linutronix.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Qian Cai <cai@lca.pw>

When booting a system with "page_owner=on",

start_kernel
  page_ext_init
    invoke_init_callbacks
      init_section_page_ext
        init_page_owner
          init_early_allocated_pages
            init_zones_in_node
              init_pages_in_zone
                lookup_page_ext
                  page_to_nid

The issue here is that page_to_nid() will not work since some page
flags have no node information until later in page_alloc_init_late() due
to DEFERRED_STRUCT_PAGE_INIT. Hence, it could trigger an out-of-bounds
access with an invalid nid.

[    8.666047] UBSAN: Undefined behaviour in ./include/linux/mm.h:1104:50
[    8.672603] index 7 is out of range for type 'zone [5]'

Also, kernel will panic since flags were poisoned earlier with,

CONFIG_DEBUG_VM_PGFLAGS=y
CONFIG_NODE_NOT_IN_PAGE_FLAGS=n

start_kernel
  setup_arch
    pagetable_init
      paging_init
        sparse_init
          sparse_init_nid
            memblock_alloc_try_nid_raw

Although later it tries to set page flags for pages in reserved bootmem
regions,

mm_init
  mem_init
    memblock_free_all
      free_low_memory_core_early
        reserve_bootmem_region

there could still have some freed pages from the page allocator but yet
to be initialized due to DEFERRED_STRUCT_PAGE_INIT. It have already been
dealt with a bit in page_ext_init().

* Take into account DEFERRED_STRUCT_PAGE_INIT.
*/
if (early_pfn_to_nid(pfn) != nid)
	continue;

However it did not handle it well in init_pages_in_zone() which end up
calling page_to_nid().

[   11.917212] page:ffffea0004200000 is uninitialized and poisoned
[   11.917220] raw: ffffffffffffffff ffffffffffffffff ffffffffffffffff
ffffffffffffffff
[   11.921745] raw: ffffffffffffffff ffffffffffffffff ffffffffffffffff
ffffffffffffffff
[   11.924523] page dumped because: VM_BUG_ON_PAGE(PagePoisoned(p))
[   11.926498] page_owner info is not active (free page?)
[   12.329560] kernel BUG at include/linux/mm.h:990!
[   12.337632] RIP: 0010:init_page_owner+0x486/0x520

Since init_pages_in_zone() has already had the node information, there
is no need to call page_to_nid() at all during the page ext lookup, and
also replace calls that could incorrectly checked for poisoned page
structs.

It ends up wasting some memory to allocate page ext for those already
freed pages, but there is no sane ways to tell those freed pages apart
from uninitialized valid pages due to DEFERRED_STRUCT_PAGE_INIT. It
looks quite reasonable on an arm64 server though.

allocated 83230720 bytes of page_ext
Node 0, zone    DMA32: page owner found early allocated 0 pages
Node 0, zone   Normal: page owner found early allocated 2048214 pages
Node 1, zone   Normal: page owner found early allocated 2080641 pages

Used more memory on a x86_64 server.

allocated 334233600 bytes of page_ext
Node 0, zone      DMA: page owner found early allocated 2 pages
Node 0, zone    DMA32: page owner found early allocated 24303 pages
Node 0, zone   Normal: page owner found early allocated 7545357 pages
Node 1, zone   Normal: page owner found early allocated 8331279 pages

Finally, rename get_entry() to get_ext_entry(), so it can be exported
without a naming collision.

Signed-off-by: Qian Cai <cai@lca.pw>
---
 include/linux/page_ext.h |  6 ++++++
 mm/page_ext.c            |  8 ++++----
 mm/page_owner.c          | 39 ++++++++++++++++++++++++++++++++-------
 3 files changed, 42 insertions(+), 11 deletions(-)

diff --git a/include/linux/page_ext.h b/include/linux/page_ext.h
index f84f167ec04c..e95cb6198014 100644
--- a/include/linux/page_ext.h
+++ b/include/linux/page_ext.h
@@ -51,6 +51,7 @@ static inline void page_ext_init(void)
 #endif
 
 struct page_ext *lookup_page_ext(const struct page *page);
+struct page_ext *get_ext_entry(void *base, unsigned long index);
 
 #else /* !CONFIG_PAGE_EXTENSION */
 struct page_ext;
@@ -64,6 +65,11 @@ static inline struct page_ext *lookup_page_ext(const struct page *page)
 	return NULL;
 }
 
+static inline struct page_ext *get_ext_entry(void *base, unsigned long index)
+{
+	return NULL;
+}
+
 static inline void page_ext_init(void)
 {
 }
diff --git a/mm/page_ext.c b/mm/page_ext.c
index ae44f7adbe07..3cd8f0c13057 100644
--- a/mm/page_ext.c
+++ b/mm/page_ext.c
@@ -107,7 +107,7 @@ static unsigned long get_entry_size(void)
 	return sizeof(struct page_ext) + extra_mem;
 }
 
-static inline struct page_ext *get_entry(void *base, unsigned long index)
+struct page_ext *get_ext_entry(void *base, unsigned long index)
 {
 	return base + get_entry_size() * index;
 }
@@ -137,7 +137,7 @@ struct page_ext *lookup_page_ext(const struct page *page)
 		return NULL;
 	index = pfn - round_down(node_start_pfn(page_to_nid(page)),
 					MAX_ORDER_NR_PAGES);
-	return get_entry(base, index);
+	return get_ext_entry(base, index);
 }
 
 static int __init alloc_node_page_ext(int nid)
@@ -207,7 +207,7 @@ struct page_ext *lookup_page_ext(const struct page *page)
 	 */
 	if (!section->page_ext)
 		return NULL;
-	return get_entry(section->page_ext, pfn);
+	return get_ext_entry(section->page_ext, pfn);
 }
 
 static void *__meminit alloc_page_ext(size_t size, int nid)
@@ -285,7 +285,7 @@ static void __free_page_ext(unsigned long pfn)
 	ms = __pfn_to_section(pfn);
 	if (!ms || !ms->page_ext)
 		return;
-	base = get_entry(ms->page_ext, pfn);
+	base = get_ext_entry(ms->page_ext, pfn);
 	free_page_ext(base);
 	ms->page_ext = NULL;
 }
diff --git a/mm/page_owner.c b/mm/page_owner.c
index 87bc0dfdb52b..c27712c9a764 100644
--- a/mm/page_owner.c
+++ b/mm/page_owner.c
@@ -531,6 +531,7 @@ static void init_pages_in_zone(pg_data_t *pgdat, struct zone *zone)
 	unsigned long pfn = zone->zone_start_pfn;
 	unsigned long end_pfn = zone_end_pfn(zone);
 	unsigned long count = 0;
+	struct page_ext *base;
 
 	/*
 	 * Walk the zone in pageblock_nr_pages steps. If a page block spans
@@ -555,11 +556,11 @@ static void init_pages_in_zone(pg_data_t *pgdat, struct zone *zone)
 			if (!pfn_valid_within(pfn))
 				continue;
 
-			page = pfn_to_page(pfn);
-
-			if (page_zone(page) != zone)
+			if (pfn < zone->zone_start_pfn || pfn >= end_pfn)
 				continue;
 
+			page = pfn_to_page(pfn);
+
 			/*
 			 * To avoid having to grab zone->lock, be a little
 			 * careful when reading buddy page order. The only
@@ -575,13 +576,37 @@ static void init_pages_in_zone(pg_data_t *pgdat, struct zone *zone)
 				continue;
 			}
 
-			if (PageReserved(page))
+#ifdef CONFIG_SPARSEMEM
+			base = __pfn_to_section(pfn)->page_ext;
+#else
+			base = pgdat->node_page_ext;
+#endif
+			/*
+			 * The sanity checks the page allocator does upon
+			 * freeing a page can reach here before the page_ext
+			 * arrays are allocated when feeding a range of pages to
+			 * the allocator for the first time during bootup or
+			 * memory hotplug.
+			 */
+			if (unlikely(!base))
 				continue;
 
-			page_ext = lookup_page_ext(page);
-			if (unlikely(!page_ext))
+			/*
+			 * Those pages reached here might had already been freed
+			 * due to the deferred struct page init.
+			 */
+#ifdef CONFIG_DEFERRED_STRUCT_PAGE_INIT
+			if (pfn < pgdat->first_deferred_pfn)
+#endif
+			if (PageReserved(page))
 				continue;
-
+#ifdef CONFIG_SPARSEMEM
+			page_ext = get_ext_entry(base, pfn);
+#else
+			page_ext = get_ext_entry(base, pfn -
+						 round_down(pgdat->node_start_pfn,
+							    MAX_ORDER_NR_PAGES));
+#endif
 			/* Maybe overlapping zone */
 			if (test_bit(PAGE_EXT_OWNER, &page_ext->flags))
 				continue;
-- 
2.17.2 (Apple Git-113)
