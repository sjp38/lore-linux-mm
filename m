Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id 5D3CD6B0037
	for <linux-mm@kvack.org>; Fri,  2 Aug 2013 13:44:41 -0400 (EDT)
From: Nathan Zimmer <nzimmer@sgi.com>
Subject: [RFC v2 4/5] Only set page reserved in the memblock region
Date: Fri,  2 Aug 2013 12:44:26 -0500
Message-Id: <1375465467-40488-5-git-send-email-nzimmer@sgi.com>
In-Reply-To: <1375465467-40488-1-git-send-email-nzimmer@sgi.com>
References: <1373594635-131067-1-git-send-email-holt@sgi.com>
 <1375465467-40488-1-git-send-email-nzimmer@sgi.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hpa@zytor.com, mingo@kernel.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, holt@sgi.com, nzimmer@sgi.com, rob@landley.net, travis@sgi.com, daniel@numascale-asia.com, akpm@linux-foundation.org, gregkh@linuxfoundation.org, yinghai@kernel.org, mgorman@suse.de

Currently we when we initialze each page struct is set as reserved upon
initialization.  This changes to starting with the reserved bit clear and
then only setting the bit in the reserved region.

I could restruture a bit to eliminate the perform hit.  But I wanted to make
sure I am on track first.

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
 include/linux/mm.h |  2 ++
 mm/nobootmem.c     |  3 +++
 mm/page_alloc.c    | 16 ++++++++++++----
 3 files changed, 17 insertions(+), 4 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index e0c8528..b264a26 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1322,6 +1322,8 @@ static inline void adjust_managed_page_count(struct page *page, long count)
 	totalram_pages += count;
 }
 
+extern void reserve_bootmem_region(unsigned long start, unsigned long end);
+
 /* Free the reserved page into the buddy system, so it gets managed. */
 static inline void __free_reserved_page(struct page *page)
 {
diff --git a/mm/nobootmem.c b/mm/nobootmem.c
index 2159e68..0840af2 100644
--- a/mm/nobootmem.c
+++ b/mm/nobootmem.c
@@ -117,6 +117,9 @@ static unsigned long __init free_low_memory_core_early(void)
 	phys_addr_t start, end, size;
 	u64 i;
 
+	for_each_reserved_mem_region(i, &start, &end)
+		reserve_bootmem_region(start, end);
+
 	for_each_free_mem_range(i, MAX_NUMNODES, &start, &end, NULL)
 		count += __free_memory_core(start, end);
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index df3ec13..382223e 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -697,17 +697,18 @@ static void free_one_page(struct zone *zone, struct page *page, int order,
 	spin_unlock(&zone->lock);
 }
 
-static void __init_single_page(unsigned long pfn, unsigned long zone, int nid)
+static void __init_single_page(unsigned long pfn, unsigned long zone,
+			       int nid, int page_count)
 {
 	struct page *page = pfn_to_page(pfn);
 	struct zone *z = &NODE_DATA(nid)->node_zones[zone];
 
 	set_page_links(page, zone, nid, pfn);
 	mminit_verify_page_links(page, zone, nid, pfn);
-	init_page_count(page);
 	page_mapcount_reset(page);
 	page_nid_reset_last(page);
-	SetPageReserved(page);
+	set_page_count(page, page_count);
+	ClearPageReserved(page);
 
 	/*
 	 * Mark the block movable so that blocks are reserved for
@@ -736,6 +737,13 @@ static void __init_single_page(unsigned long pfn, unsigned long zone, int nid)
 #endif
 }
 
+void reserve_bootmem_region(unsigned long start, unsigned long end)
+{
+	for (; start < end; start++)
+		if (pfn_valid(start))
+			SetPageReserved(pfn_to_page(start));
+}
+
 static bool free_pages_prepare(struct page *page, unsigned int order)
 {
 	int i;
@@ -4010,7 +4018,7 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
 			if (!early_pfn_in_nid(pfn, nid))
 				continue;
 		}
-		__init_single_page(pfn, zone, nid);
+		__init_single_page(pfn, zone, nid, 1);
 	}
 }
 
-- 
1.8.2.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
