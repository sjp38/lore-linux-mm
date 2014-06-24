Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f48.google.com (mail-wg0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 2A7446B0031
	for <linux-mm@kvack.org>; Tue, 24 Jun 2014 18:48:11 -0400 (EDT)
Received: by mail-wg0-f48.google.com with SMTP id n12so1081783wgh.7
        for <linux-mm@kvack.org>; Tue, 24 Jun 2014 15:48:10 -0700 (PDT)
Received: from mail-wg0-f74.google.com (mail-wg0-f74.google.com [74.125.82.74])
        by mx.google.com with ESMTPS id ek10si3491276wid.60.2014.06.24.15.48.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 24 Jun 2014 15:48:09 -0700 (PDT)
Received: by mail-wg0-f74.google.com with SMTP id x13so120667wgg.5
        for <linux-mm@kvack.org>; Tue, 24 Jun 2014 15:48:09 -0700 (PDT)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: [RFC] mm: cma: move init_cma_reserved_pageblock to cma.c
Date: Wed, 25 Jun 2014 00:48:02 +0200
Message-Id: <1403650082-10056-1-git-send-email-mina86@mina86.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Salter <msalter@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, Michal Nazarewicz <mina86@mina86.com>

With [f495d26: a??generalize CMA reserved area management
functionalitya??] patch CMA has its place under mm directory now so
there is no need to shoehorn a highly CMA specific functions inside of
page_alloc.c.

As such move init_cma_reserved_pageblock from mm/page_alloc.c to
mm/cma.c, rename it to cma_init_reserved_pageblock and refactor
a little.

Most importantly, if a !pfn_valid(pfn) is encountered, just
return -EINVAL instead of warning and trying to continue the
initialisation of the area.  It's not clear, to me at least, what good
is continuing the work on a PFN that is known to be invalid.

Signed-off-by: Michal Nazarewicz <mina86@mina86.com>
---
 include/linux/gfp.h |  3 --
 mm/cma.c            | 85 +++++++++++++++++++++++++++++++++++++++++------------
 mm/page_alloc.c     | 31 -------------------
 3 files changed, 66 insertions(+), 53 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 5e7219d..107793e9 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -415,9 +415,6 @@ extern int alloc_contig_range(unsigned long start, unsigned long end,
 			      unsigned migratetype);
 extern void free_contig_range(unsigned long pfn, unsigned nr_pages);
 
-/* CMA stuff */
-extern void init_cma_reserved_pageblock(struct page *page);
-
 #endif
 
 #endif /* __LINUX_GFP_H */
diff --git a/mm/cma.c b/mm/cma.c
index c17751c..843b2b6 100644
--- a/mm/cma.c
+++ b/mm/cma.c
@@ -28,11 +28,14 @@
 #include <linux/err.h>
 #include <linux/mm.h>
 #include <linux/mutex.h>
+#include <linux/page-isolation.h>
 #include <linux/sizes.h>
 #include <linux/slab.h>
 #include <linux/log2.h>
 #include <linux/cma.h>
 
+#include "internal.h"
+
 struct cma {
 	unsigned long	base_pfn;
 	unsigned long	count;
@@ -83,37 +86,81 @@ static void cma_clear_bitmap(struct cma *cma, unsigned long pfn, int count)
 	mutex_unlock(&cma->lock);
 }
 
+/* Free whole pageblock and set its migration type to MIGRATE_CMA. */
+static int __init cma_init_reserved_pageblock(struct zone *zone,
+					      unsigned long pageblock_pfn)
+{
+	unsigned long pfn, nr_pages, i;
+	struct page *page, *p;
+	unsigned order;
+
+	pfn = pageblock_pfn;
+	if (!pfn_valid(pfn))
+		goto invalid_pfn;
+	page = pfn_to_page(pfn);
+
+	p = page;
+	i = pageblock_nr_pages;
+	do {
+		if (!pfn_valid(pfn))
+			goto invalid_pfn;
+
+		/*
+		 * alloc_contig_range requires the pfn range specified to be
+		 * in the same zone. Make this simple by forcing the entire
+		 * CMA resv range to be in the same zone.
+		 */
+		if (page_zone(p) != zone) {
+			pr_err("pfn %lu belongs to %s, expecting %s\n",
+			       pfn, page_zone(p)->name, zone->name);
+			return -EINVAL;
+		}
+
+		__ClearPageReserved(p);
+		set_page_count(p, 0);
+	} while (++p, ++pfn, --i);
+
+	/* Return all the pages to buddy allocator as MIGRATE_CMA. */
+	set_pageblock_migratetype(page, MIGRATE_CMA);
+
+	order = min_t(unsigned, pageblock_order, MAX_ORDER - 1);
+	nr_pages = min_t(unsigned long, pageblock_nr_pages, MAX_ORDER_NR_PAGES);
+
+	p = page;
+	i = pageblock_nr_pages;
+	do {
+		set_page_refcounted(p);
+		__free_pages(p, order);
+		p += nr_pages;
+	} while (i -= nr_pages);
+
+	adjust_managed_page_count(page, pageblock_nr_pages);
+	return 0;
+
+invalid_pfn:
+	pr_err("invalid pfn: %lu\n", pfn);
+	return -EINVAL;
+}
+
 static int __init cma_activate_area(struct cma *cma)
 {
 	int bitmap_size = BITS_TO_LONGS(cma_bitmap_maxno(cma)) * sizeof(long);
-	unsigned long base_pfn = cma->base_pfn, pfn = base_pfn;
 	unsigned i = cma->count >> pageblock_order;
+	unsigned long pfn = cma->base_pfn;
 	struct zone *zone;
 
-	cma->bitmap = kzalloc(bitmap_size, GFP_KERNEL);
+	if (WARN_ON(!pfn_valid(pfn)))
+		return -EINVAL;
 
+	cma->bitmap = kzalloc(bitmap_size, GFP_KERNEL);
 	if (!cma->bitmap)
 		return -ENOMEM;
 
-	WARN_ON_ONCE(!pfn_valid(pfn));
 	zone = page_zone(pfn_to_page(pfn));
-
 	do {
-		unsigned j;
-
-		base_pfn = pfn;
-		for (j = pageblock_nr_pages; j; --j, pfn++) {
-			WARN_ON_ONCE(!pfn_valid(pfn));
-			/*
-			 * alloc_contig_range requires the pfn range
-			 * specified to be in the same zone. Make this
-			 * simple by forcing the entire CMA resv range
-			 * to be in the same zone.
-			 */
-			if (page_zone(pfn_to_page(pfn)) != zone)
-				goto err;
-		}
-		init_cma_reserved_pageblock(pfn_to_page(base_pfn));
+		if (cma_init_reserved_pageblock(zone, pfn) < 0)
+			goto err;
+		pfn += pageblock_nr_pages;
 	} while (--i);
 
 	mutex_init(&cma->lock);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index fef9614..d47f83f 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -804,37 +804,6 @@ void __init __free_pages_bootmem(struct page *page, unsigned int order)
 	__free_pages(page, order);
 }
 
-#ifdef CONFIG_CMA
-/* Free whole pageblock and set its migration type to MIGRATE_CMA. */
-void __init init_cma_reserved_pageblock(struct page *page)
-{
-	unsigned i = pageblock_nr_pages;
-	struct page *p = page;
-
-	do {
-		__ClearPageReserved(p);
-		set_page_count(p, 0);
-	} while (++p, --i);
-
-	set_pageblock_migratetype(page, MIGRATE_CMA);
-
-	if (pageblock_order >= MAX_ORDER) {
-		i = pageblock_nr_pages;
-		p = page;
-		do {
-			set_page_refcounted(p);
-			__free_pages(p, MAX_ORDER - 1);
-			p += MAX_ORDER_NR_PAGES;
-		} while (i -= MAX_ORDER_NR_PAGES);
-	} else {
-		set_page_refcounted(page);
-		__free_pages(page, pageblock_order);
-	}
-
-	adjust_managed_page_count(page, pageblock_nr_pages);
-}
-#endif
-
 /*
  * The order of subdivision here is critical for the IO subsystem.
  * Please do not alter this order without good reasons and regression
-- 
2.0.0.526.g5318336

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
