Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id AB4896B0069
	for <linux-mm@kvack.org>; Thu, 27 Nov 2014 05:46:50 -0500 (EST)
Received: by mail-pd0-f175.google.com with SMTP id y10so4728203pdj.20
        for <linux-mm@kvack.org>; Thu, 27 Nov 2014 02:46:49 -0800 (PST)
Received: from mail-pa0-x232.google.com (mail-pa0-x232.google.com. [2607:f8b0:400e:c03::232])
        by mx.google.com with ESMTPS id qd7si11070485pbb.22.2014.11.27.02.46.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 27 Nov 2014 02:46:48 -0800 (PST)
Received: by mail-pa0-f50.google.com with SMTP id bj1so4845598pad.9
        for <linux-mm@kvack.org>; Thu, 27 Nov 2014 02:46:47 -0800 (PST)
From: Hongbo Zhong <bocui107@gmail.com>
Subject: [PATCH] mm: Remove the highmem zones' memmap in the highmem zone
Date: Thu, 27 Nov 2014 18:46:34 +0800
Message-Id: <1417085194-17042-1-git-send-email-bocui107@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org

From: Zhong Hongbo <bocui107@gmail.com>

Since the commit 01cefaef40c4 ("mm: provide more accurate estimation
of pages occupied by memmap") allocate the pages from lowmem for the
highmem zones' memmap. So It is not need to reserver the memmap's for
the highmem.

A 2G DDR3 for the arm platform:
On node 0 totalpages: 524288
free_area_init_node: node 0, pgdat 80ccd380, node_mem_map 80d38000
  DMA zone: 3568 pages used for memmap
  DMA zone: 0 pages reserved
  DMA zone: 456704 pages, LIFO batch:31
  HighMem zone: 528 pages used for memmap
  HighMem zone: 67584 pages, LIFO batch:15

On node 0 totalpages: 524288
free_area_init_node: node 0, pgdat 80cd6f40, node_mem_map 80d42000
  DMA zone: 3568 pages used for memmap
  DMA zone: 0 pages reserved
  DMA zone: 456704 pages, LIFO batch:31
  HighMem zone: 67584 pages, LIFO batch:15


Signed-off-by: Hongbo Zhong <hongbo.zhong@gmail.com>
---
 mm/page_alloc.c |   22 ++++++++++++----------
 1 file changed, 12 insertions(+), 10 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 616a2c9..d2f723c 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4851,16 +4851,18 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat,
 		 * and per-cpu initialisations
 		 */
 		memmap_pages = calc_memmap_size(size, realsize);
-		if (freesize >= memmap_pages) {
-			freesize -= memmap_pages;
-			if (memmap_pages)
-				printk(KERN_DEBUG
-				       "  %s zone: %lu pages used for memmap\n",
-				       zone_names[j], memmap_pages);
-		} else
-			printk(KERN_WARNING
-				"  %s zone: %lu pages exceeds freesize %lu\n",
-				zone_names[j], memmap_pages, freesize);
+		if (!is_highmem_idx(j)) {
+			if (freesize >= memmap_pages) {
+				freesize -= memmap_pages;
+				if (memmap_pages)
+					printk(KERN_DEBUG
+					       "  %s zone: %lu pages used for memmap\n",
+					       zone_names[j], memmap_pages);
+			} else
+				printk(KERN_WARNING
+					"  %s zone: %lu pages exceeds freesize %lu\n",
+					zone_names[j], memmap_pages, freesize);
+		}
 
 		/* Account for reserved pages */
 		if (j == 0 && freesize > dma_reserve) {
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
