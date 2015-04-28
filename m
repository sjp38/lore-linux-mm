Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f43.google.com (mail-wg0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 991AB6B0074
	for <linux-mm@kvack.org>; Tue, 28 Apr 2015 10:37:22 -0400 (EDT)
Received: by wgen6 with SMTP id n6so153702427wge.3
        for <linux-mm@kvack.org>; Tue, 28 Apr 2015 07:37:22 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id cm14si38777958wjb.116.2015.04.28.07.37.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 28 Apr 2015 07:37:15 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 03/13] mm: meminit: Only set page reserved in the memblock region
Date: Tue, 28 Apr 2015 15:37:00 +0100
Message-Id: <1430231830-7702-4-git-send-email-mgorman@suse.de>
In-Reply-To: <1430231830-7702-1-git-send-email-mgorman@suse.de>
References: <1430231830-7702-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Nathan Zimmer <nzimmer@sgi.com>, Dave Hansen <dave.hansen@intel.com>, Waiman Long <waiman.long@hp.com>, Scott Norton <scott.norton@hp.com>, Daniel J Blueman <daniel@numascale.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

From: Nathan Zimmer <nzimmer@sgi.com>

Currently each page struct is set as reserved upon initialization.
This patch leaves the reserved bit clear and only sets the reserved bit
when it is known the memory was allocated by the bootmem allocator. This
makes it easier to distinguish between uninitialised struct pages and
reserved struct pages in later patches.

Signed-off-by: Robin Holt <holt@sgi.com>
Signed-off-by: Nathan Zimmer <nzimmer@sgi.com>
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/mm.h |  2 ++
 mm/nobootmem.c     |  3 +++
 mm/page_alloc.c    | 17 ++++++++++++++++-
 3 files changed, 21 insertions(+), 1 deletion(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 47a93928b90f..b6f82a31028a 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1711,6 +1711,8 @@ extern void free_highmem_page(struct page *page);
 extern void adjust_managed_page_count(struct page *page, long count);
 extern void mem_init_print_info(const char *str);
 
+extern void reserve_bootmem_region(unsigned long start, unsigned long end);
+
 /* Free the reserved page into the buddy system, so it gets managed. */
 static inline void __free_reserved_page(struct page *page)
 {
diff --git a/mm/nobootmem.c b/mm/nobootmem.c
index 90b50468333e..396f9e450dc1 100644
--- a/mm/nobootmem.c
+++ b/mm/nobootmem.c
@@ -121,6 +121,9 @@ static unsigned long __init free_low_memory_core_early(void)
 
 	memblock_clear_hotplug(0, -1);
 
+	for_each_reserved_mem_region(i, &start, &end)
+		reserve_bootmem_region(start, end);
+
 	for_each_free_mem_range(i, NUMA_NO_NODE, &start, &end, NULL)
 		count += __free_memory_core(start, end);
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index fd7a6d09062d..13c88177d3c6 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -788,7 +788,6 @@ static void __meminit __init_single_page(struct page *page, unsigned long pfn,
 	init_page_count(page);
 	page_mapcount_reset(page);
 	page_cpupid_reset_last(page);
-	SetPageReserved(page);
 
 	/*
 	 * Mark the block movable so that blocks are reserved for
@@ -823,6 +822,22 @@ static void __meminit __init_single_pfn(unsigned long pfn, unsigned long zone,
 	return __init_single_page(pfn_to_page(pfn), pfn, zone, nid);
 }
 
+/*
+ * Initialised pages do not have PageReserved set. This function is
+ * called for each range allocated by the bootmem allocator and
+ * marks the pages PageReserved. The remaining valid pages are later
+ * sent to the buddy page allocator.
+ */
+void reserve_bootmem_region(unsigned long start, unsigned long end)
+{
+	unsigned long start_pfn = PFN_DOWN(start);
+	unsigned long end_pfn = PFN_UP(end);
+
+	for (; start_pfn < end_pfn; start_pfn++)
+		if (pfn_valid(start_pfn))
+			SetPageReserved(pfn_to_page(start_pfn));
+}
+
 static bool free_pages_prepare(struct page *page, unsigned int order)
 {
 	bool compound = PageCompound(page);
-- 
2.3.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
