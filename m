Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id 7B9B86B00B0
	for <linux-mm@kvack.org>; Wed, 21 Nov 2012 10:10:10 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id bj3so1134249pad.14
        for <linux-mm@kvack.org>; Wed, 21 Nov 2012 07:10:09 -0800 (PST)
From: Jiang Liu <liuj97@gmail.com>
Subject: [RFT PATCH v2 4/5] mm: provide more accurate estimation of pages occupied by memmap
Date: Wed, 21 Nov 2012 23:09:46 +0800
Message-Id: <1353510586-6393-1-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <20121120111942.c9596d3f.akpm@linux-foundation.org>
References: <20121120111942.c9596d3f.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Wen Congyang <wency@cn.fujitsu.com>, David Rientjes <rientjes@google.com>
Cc: Jiang Liu <jiang.liu@huawei.com>, Maciej Rutecki <maciej.rutecki@gmail.com>, Chris Clayton <chris2553@googlemail.com>, "Rafael J . Wysocki" <rjw@sisk.pl>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

If SPARSEMEM is enabled, it won't build page structures for
non-existing pages (holes) within a zone, so provide a more accurate
estimation of pages occupied by memmap if there are bigger holes within
the zone.

And pages for highmem zones' memmap will be allocated from lowmem, so
charge nr_kernel_pages for that.

Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
---
 mm/page_alloc.c |   26 ++++++++++++++++++++++++--
 1 file changed, 24 insertions(+), 2 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index fc10071..9bbac97 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4442,6 +4442,26 @@ void __init set_pageblock_order(void)
 
 #endif /* CONFIG_HUGETLB_PAGE_SIZE_VARIABLE */
 
+static unsigned long calc_memmap_size(unsigned long spanned_pages,
+				      unsigned long present_pages)
+{
+	unsigned long pages = spanned_pages;
+
+	/*
+	 * Provide a more accurate estimation if there are holes within
+	 * the zone and SPARSEMEM is in use. If there are holes within the
+	 * zone, each populated memory region may cost us one or two extra
+	 * memmap pages due to alignment because memmap pages for each
+	 * populated regions may not naturally algined on page boundary.
+	 * So the (present_pages >> 4) heuristic is a tradeoff for that.
+	 */
+	if (spanned_pages > present_pages + (present_pages >> 4) &&
+	    IS_ENABLED(CONFIG_SPARSEMEM))
+		pages = present_pages;
+
+	return PAGE_ALIGN(pages * sizeof(struct page)) >> PAGE_SHIFT;
+}
+
 /*
  * Set up the zone data structures:
  *   - mark all pages reserved
@@ -4476,8 +4496,7 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat,
 		 * is used by this zone for memmap. This affects the watermark
 		 * and per-cpu initialisations
 		 */
-		memmap_pages =
-			PAGE_ALIGN(size * sizeof(struct page)) >> PAGE_SHIFT;
+		memmap_pages = calc_memmap_size(size, realsize);
 		if (freesize >= memmap_pages) {
 			freesize -= memmap_pages;
 			if (memmap_pages)
@@ -4498,6 +4517,9 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat,
 
 		if (!is_highmem_idx(j))
 			nr_kernel_pages += freesize;
+		/* Charge for highmem memmap if there are enough kernel pages */
+		else if (nr_kernel_pages > memmap_pages * 2)
+			nr_kernel_pages -= memmap_pages;
 		nr_all_pages += freesize;
 
 		zone->spanned_pages = size;
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
