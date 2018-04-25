Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8F6666B0003
	for <linux-mm@kvack.org>; Wed, 25 Apr 2018 00:47:54 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id q15so14831363pff.15
        for <linux-mm@kvack.org>; Tue, 24 Apr 2018 21:47:54 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id f7si12421512pgs.556.2018.04.24.21.47.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 24 Apr 2018 21:47:53 -0700 (PDT)
Date: Tue, 24 Apr 2018 21:47:52 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: [RFC] Scale slub page allocations with memory size
Message-ID: <20180425044752.GB15974@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Christopher Lameter <cl@linux.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

With larger memory sizes, it's more important to avoid external
fragmentation than reduce memory usage.
    
Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>

diff --git a/mm/internal.h b/mm/internal.h
index 62d8c34e63d5..fe0e60b8db11 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -167,6 +167,7 @@ extern void prep_compound_page(struct page *page, unsigned int order);
 extern void post_alloc_hook(struct page *page, unsigned int order,
 					gfp_t gfp_flags);
 extern int user_min_free_kbytes;
+extern unsigned long __meminitdata nr_kernel_pages;
 
 extern void set_zone_contiguous(struct zone *zone);
 extern void clear_zone_contiguous(struct zone *zone);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 905db9d7962f..7db8945bc915 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -265,7 +265,7 @@ int min_free_kbytes = 1024;
 int user_min_free_kbytes = -1;
 int watermark_scale_factor = 10;
 
-static unsigned long nr_kernel_pages __meminitdata;
+unsigned long nr_kernel_pages __meminitdata;
 static unsigned long nr_all_pages __meminitdata;
 static unsigned long dma_reserve __meminitdata;
 
diff --git a/mm/slub.c b/mm/slub.c
index 44aa7847324a..61a423e38dcf 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -3195,7 +3195,7 @@ EXPORT_SYMBOL(kmem_cache_alloc_bulk);
  * and increases the number of allocations possible without having to
  * take the list_lock.
  */
-static unsigned int slub_min_order;
+static unsigned int slub_min_order = ~0U;
 static unsigned int slub_max_order = PAGE_ALLOC_COSTLY_ORDER;
 static unsigned int slub_min_objects;
 
@@ -4221,6 +4221,23 @@ void __init kmem_cache_init(void)
 
 	if (debug_guardpage_minorder())
 		slub_max_order = 0;
+	if (slub_min_order == ~0) {
+		unsigned long numpages = nr_kernel_pages;
+
+		/*
+		 * Above a million pages, we start to care more about
+		 * fragmentation than about using the minimum amount of
+		 * memory.  Scale the slub page size at half the rate of
+		 * the memory size; at 4GB we double the page size to 8k,
+		 * 16GB to 16k, 64GB to 32k, 256GB to 64k.
+		 */
+		do {
+			slub_min_order++;
+			if (slub_min_order == slub_max_order)
+				break;
+			numpages /= 4;
+		} while (numpages > (1UL << 20));
+	}
 
 	kmem_cache_node = &boot_kmem_cache_node;
 	kmem_cache = &boot_kmem_cache;
