Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f169.google.com (mail-pf0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 0C99F6B007E
	for <linux-mm@kvack.org>; Fri, 25 Mar 2016 12:05:50 -0400 (EDT)
Received: by mail-pf0-f169.google.com with SMTP id x3so85428929pfb.1
        for <linux-mm@kvack.org>; Fri, 25 Mar 2016 09:05:50 -0700 (PDT)
Received: from e28smtp07.in.ibm.com (e28smtp07.in.ibm.com. [125.16.236.7])
        by mx.google.com with ESMTPS id d3si9743235pas.116.2016.03.25.09.05.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Fri, 25 Mar 2016 09:05:49 -0700 (PDT)
Received: from localhost
	by e28smtp07.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <gwshan@linux.vnet.ibm.com>;
	Fri, 25 Mar 2016 21:35:45 +0530
Received: from d28av08.in.ibm.com (d28av08.in.ibm.com [9.184.220.148])
	by d28relay02.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u2PG57Bl19333506
	for <linux-mm@kvack.org>; Fri, 25 Mar 2016 21:35:08 +0530
Received: from d28av08.in.ibm.com (localhost [127.0.0.1])
	by d28av08.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u2PG56NX022146
	for <linux-mm@kvack.org>; Fri, 25 Mar 2016 21:35:07 +0530
From: Gavin Shan <gwshan@linux.vnet.ibm.com>
Subject: [PATCH RFC] mm: Fix memory corruption caused by deferred page initialization
Date: Sat, 26 Mar 2016 03:05:29 +1100
Message-Id: <1458921929-15264-1-git-send-email-gwshan@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linuxppc-dev@lists.ozlabs.org, zhlcindy@linux.vnet.ibm.com, mpe@ellerman.id.au, mgorman@suse.de, Gavin Shan <gwshan@linux.vnet.ibm.com>

During deferred page initialization, the pages are moved from memblock
or bootmem to buddy allocator without checking they were reserved. Those
reserved pages can be reallocated to somebody else by buddy/slab allocator.
It leads to memory corruption and potential kernel crash eventually.

This fixes above issue by:

   * Deferred releasing bootmem bitmap until the completion of deferred
     page initialization.
   * Implements __reserved_bootmem_region() to check if the specified
     page is reserved by memblock or bootmem during the deferred
     page initialization. The pages won't be released to buddy allocator
     if they are reserved.
   * In free_all_bootmem_core(), @cur is set to node's starting PFN and
     that's incorrect. It's fixed as well.

With this applied, the IBM's Power8 box boots up without reserved issues
with all possible combinations of NO_BOOTMEM and DEFERRED_STRUCT_PAGE_INIT.

Signed-off-by: Gavin Shan <gwshan@linux.vnet.ibm.com>
---
 include/linux/bootmem.h |  2 ++
 mm/bootmem.c            | 45 +++++++++++++++++++++++++++++++++-----
 mm/nobootmem.c          |  6 +++++
 mm/page_alloc.c         | 58 ++++++++++++++++++++++++++++++++++++++++++++++++-
 4 files changed, 104 insertions(+), 7 deletions(-)

diff --git a/include/linux/bootmem.h b/include/linux/bootmem.h
index 35b22f9..a64f378 100644
--- a/include/linux/bootmem.h
+++ b/include/linux/bootmem.h
@@ -78,6 +78,8 @@ extern int reserve_bootmem_node(pg_data_t *pgdat,
 				unsigned long size,
 				int flags);
 
+extern bool __reserved_bootmem_region(unsigned long base,
+				      unsigned long size);
 extern void *__alloc_bootmem(unsigned long size,
 			     unsigned long align,
 			     unsigned long goal);
diff --git a/mm/bootmem.c b/mm/bootmem.c
index 0aa7dda..eaf13b0 100644
--- a/mm/bootmem.c
+++ b/mm/bootmem.c
@@ -172,7 +172,7 @@ void __init free_bootmem_late(unsigned long physaddr, unsigned long size)
 static unsigned long __init free_all_bootmem_core(bootmem_data_t *bdata)
 {
 	struct page *page;
-	unsigned long *map, start, end, pages, cur, count = 0;
+	unsigned long *map, start, end, cur, count = 0;
 
 	if (!bdata->node_bootmem_map)
 		return 0;
@@ -229,14 +229,21 @@ static unsigned long __init free_all_bootmem_core(bootmem_data_t *bdata)
 		}
 	}
 
-	cur = bdata->node_min_pfn;
+	/*
+	 * The information tracked by bootmem bitmap can be released when
+	 * deferred page initialization is disabled. Otherwise, we have
+	 * to release it right after deferred page initialization
+	 */
+#ifndef CONFIG_DEFERRED_STRUCT_PAGE_INIT
+	cur = PFN_DOWN(virt_to_phys(bdata->node_bootmem_map));
 	page = virt_to_page(bdata->node_bootmem_map);
-	pages = bdata->node_low_pfn - bdata->node_min_pfn;
-	pages = bootmem_bootmap_pages(pages);
-	count += pages;
-	while (pages--)
+	end = bdata->node_low_pfn - bdata->node_min_pfn;
+	end = bootmem_bootmap_pages(end);
+	count += end;
+	while (end--)
 		__free_pages_bootmem(page++, cur++, 0);
 	bdata->node_bootmem_map = NULL;
+#endif
 
 	bdebug("nid=%td released=%lx\n", bdata - bootmem_node_data, count);
 
@@ -497,6 +504,32 @@ static unsigned long __init align_off(struct bootmem_data *bdata,
 	return ALIGN(base + off, align) - base;
 }
 
+bool __init __reserved_bootmem_region(unsigned long base, unsigned long size)
+{
+	struct pglist_data *pgdat;
+	struct bootmem_data *bdata;
+	unsigned long pfn, start, end, idx;
+	int nid;
+
+	start = PFN_DOWN(base);
+	end = PFN_UP(base + size);
+	for (pfn = start; pfn < end; pfn++) {
+		nid = early_pfn_to_nid(pfn);
+		pgdat = NODE_DATA(nid);
+		bdata = pgdat ? pgdat->bdata : NULL;
+		if (!bdata ||
+		    pfn < bdata->node_min_pfn ||
+		    pfn > bdata->node_low_pfn)
+			continue;
+
+		idx = pfn - bdata->node_min_pfn;
+		if (test_bit(idx, bdata->node_bootmem_map))
+			return true;
+	}
+
+	return false;
+}
+
 static void * __init alloc_bootmem_bdata(struct bootmem_data *bdata,
 					unsigned long size, unsigned long align,
 					unsigned long goal, unsigned long limit)
diff --git a/mm/nobootmem.c b/mm/nobootmem.c
index bd05a70..70bca8d2 100644
--- a/mm/nobootmem.c
+++ b/mm/nobootmem.c
@@ -33,6 +33,12 @@ unsigned long min_low_pfn;
 unsigned long max_pfn;
 unsigned long long max_possible_pfn;
 
+bool __init __reserved_bootmem_region(unsigned long base,
+				      unsigned long size)
+{
+	return memblock_is_region_reserved(base, size);
+}
+
 static void * __init __alloc_memory_core_early(int nid, u64 size, u64 align,
 					u64 goal, u64 limit)
 {
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index a762be5..9ca9546 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1227,6 +1227,57 @@ static void __init deferred_free_range(struct page *page,
 		__free_pages_boot_core(page, pfn, 0);
 }
 
+#ifndef CONFIG_NO_BOOTMEM
+static unsigned long __init deferred_free_bootmem_bitmap(int nid)
+{
+	struct pglist_data *pgdat = NODE_DATA(nid);
+	struct bootmem_data *bdata = pgdat->bdata;
+	struct zone *zone;
+	struct page *page;
+	unsigned long pfn, cur, pages, count;
+	int zid;
+
+	if (!bdata || !bdata->node_bootmem_map)
+		return 0UL;
+
+	pfn = PFN_DOWN(virt_to_phys(bdata->node_bootmem_map));
+	page = virt_to_page(bdata->node_bootmem_map);
+	bdata->node_bootmem_map = NULL;
+	pages = bdata->node_low_pfn - bdata->node_min_pfn;
+	pages = bootmem_bootmap_pages(pages);
+
+	/*
+	 * We won't lose much performance to release pages one by one
+	 * as the amount of reserved memory for bootmem bitmap is usually
+	 * very small
+	 */
+	for (count = 0UL, cur = 0UL; cur < pages; cur++) {
+		for (zid = 0; zid < MAX_NR_ZONES; zid++) {
+			zone = &pgdat->node_zones[zid];
+			if (!zone->spanned_pages)
+				continue;
+
+			if (pfn >= zone->zone_start_pfn &&
+			    pfn < zone->zone_start_pfn + zone->spanned_pages)
+				break;
+		}
+
+		if (zid < MAX_NR_ZONES) {
+			pr_info("%s: nid#%d, %s, 0x%lx\n",
+				__func__, nid, zone_names[zid], pfn);
+			__init_single_page(page, pfn, zid, nid);
+			__free_pages_boot_core(page, pfn, 0);
+			count++;
+		}
+
+		page++;
+		pfn++;
+	}
+
+	return count;
+}
+#endif /* !CONFIG_NO_BOOTMEM */
+
 /* Completion tracking for deferred_init_memmap() threads */
 static atomic_t pgdat_init_n_undone __initdata;
 static __initdata DECLARE_COMPLETION(pgdat_init_all_done_comp);
@@ -1301,7 +1352,9 @@ static int __init deferred_init_memmap(void *data)
 				}
 			}
 
-			if (!meminit_pfn_in_nid(pfn, nid, &nid_init_state)) {
+			if (!meminit_pfn_in_nid(pfn, nid, &nid_init_state) ||
+			    __reserved_bootmem_region(PFN_PHYS(pfn),
+						      PAGE_SIZE)) {
 				page = NULL;
 				goto free_range;
 			}
@@ -1350,6 +1403,9 @@ free_range:
 	/* Sanity check that the next zone really is unpopulated */
 	WARN_ON(++zid < MAX_NR_ZONES && populated_zone(++zone));
 
+#ifndef CONFIG_NO_BOOTMEM
+	nr_pages += deferred_free_bootmem_bitmap(nid);
+#endif
 	pr_info("node %d initialised, %lu pages in %ums\n", nid, nr_pages,
 					jiffies_to_msecs(jiffies - start));
 
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
