Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f177.google.com (mail-ig0-f177.google.com [209.85.213.177])
	by kanga.kvack.org (Postfix) with ESMTP id 43D5B6B0186
	for <linux-mm@kvack.org>; Tue,  6 Jan 2015 17:32:23 -0500 (EST)
Received: by mail-ig0-f177.google.com with SMTP id z20so388447igj.4
        for <linux-mm@kvack.org>; Tue, 06 Jan 2015 14:32:23 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id j5si194445icy.59.2015.01.06.14.32.21
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Jan 2015 14:32:21 -0800 (PST)
Date: Tue, 6 Jan 2015 14:32:19 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [cgroup:review-cgroup-writeback-20150106 63/265]
 mm/page_alloc.c:654:27: error: 'struct free_area' has no member named
 'cma_nr_free'
Message-Id: <20150106143219.95b93a972af13766b88947bb@linux-foundation.org>
In-Reply-To: <201501070358.qiFdxmfv%fengguang.wu@intel.com>
References: <201501070358.qiFdxmfv%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: Hui Zhu <zhuhui@xiaomi.com>, kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, Weixing Liu <liuweixing@xiaomi.com>, Linux Memory Management List <linux-mm@kvack.org>

On Wed, 7 Jan 2015 03:15:00 +0800 kbuild test robot <fengguang.wu@intel.com> wrote:

> tree:   git://git.kernel.org/pub/scm/linux/kernel/git/tj/cgroup.git review-cgroup-writeback-20150106
> head:   393b71c00e25227a020f9dbf8ffdddebac4fdf1e
> commit: c2b42c0f94035f23cd0524c2cece2f3e05d28255 [63/265] CMA: fix CMA's page number is substructed twice in __zone_watermark_ok
> config: parisc-c3000_defconfig (attached as .config)
> reproduce:
>   wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
>   chmod +x ~/bin/make.cross
>   git checkout c2b42c0f94035f23cd0524c2cece2f3e05d28255
>   # save the attached .config to linux build tree
>   make.cross ARCH=parisc 

Yeah, that was pretty sloppy.

Like this?

--- a/mm/page_alloc.c~cma-fix-cmas-page-number-is-substructed-twice-in-__zone_watermark_ok-fix-2
+++ a/mm/page_alloc.c
@@ -32,6 +32,8 @@
 #include <linux/slab.h>
 #include <linux/ratelimit.h>
 #include <linux/oom.h>
+#include <linux/mmzone.h>
+#include <linux/cma.h>
 #include <linux/notifier.h>
 #include <linux/topology.h>
 #include <linux/sysctl.h>
@@ -650,8 +652,7 @@ static inline void __free_one_page(struc
 		} else {
 			list_del(&buddy->lru);
 			zone->free_area[order].nr_free--;
-			if (is_migrate_cma(migratetype))
-				zone->free_area[order].cma_nr_free--;
+			cma_nr_free_dec(migratetype, &zone->free_area[order]);
 			rmv_page_order(buddy);
 		}
 		combined_idx = buddy_idx & page_idx;
@@ -685,8 +686,7 @@ static inline void __free_one_page(struc
 	list_add(&page->lru, &zone->free_area[order].free_list[migratetype]);
 out:
 	zone->free_area[order].nr_free++;
-	if (is_migrate_cma(migratetype))
-		zone->free_area[order].cma_nr_free++;
+	cma_nr_free_inc(migratetype, &zone->free_area[order]);
 }
 
 static inline int free_pages_check(struct page *page)
@@ -941,8 +941,7 @@ static inline void expand(struct zone *z
 		}
 		list_add(&page[size].lru, &area->free_list[migratetype]);
 		area->nr_free++;
-		if (is_migrate_cma(migratetype))
-			area->cma_nr_free++;
+		cma_nr_free_inc(migratetype, area);
 		set_page_order(&page[size], high);
 	}
 }
@@ -1026,8 +1025,7 @@ struct page *__rmqueue_smallest(struct z
 		list_del(&page->lru);
 		rmv_page_order(page);
 		area->nr_free--;
-		if (is_migrate_cma(migratetype))
-			area->cma_nr_free--;
+		cma_nr_free_dec(migratetype, area);
 		expand(zone, page, order, current_order, area, migratetype);
 		set_freepage_migratetype(page, migratetype);
 		return page;
@@ -1216,8 +1214,7 @@ __rmqueue_fallback(struct zone *zone, un
 			page = list_entry(area->free_list[migratetype].next,
 					struct page, lru);
 			area->nr_free--;
-			if (is_migrate_cma(migratetype))
-				area->cma_nr_free--;
+			cma_nr_free_dec(migratetype, area);
 
 			new_type = try_to_steal_freepages(zone, page,
 							  start_migratetype,
@@ -1607,8 +1604,7 @@ int __isolate_free_page(struct page *pag
 	/* Remove page from free list */
 	list_del(&page->lru);
 	zone->free_area[order].nr_free--;
-	if (is_migrate_cma(mt))
-		zone->free_area[order].cma_nr_free--;
+	cma_nr_free_dec(mt, &zone->free_area[order]);
 	rmv_page_order(page);
 
 	/* Set the pageblock if the isolated page is at least a pageblock */
@@ -1845,9 +1841,10 @@ static bool __zone_watermark_ok(struct z
 		 * "z->free_area[o].nr_free << o" subtracted CMA's page number
 		 * of this order again.  So add it back.
 		 */
-		if (IS_ENABLED(CONFIG_CMA) && free_cma)
+#ifdef COFNIG_CMA
+		if (free_cma)
 			free_pages += z->free_area[o].cma_nr_free << o;
-
+#endif
 		/* Require fewer higher order pages to be free */
 		min >>= 1;
 
@@ -4249,7 +4246,9 @@ static void __meminit zone_init_free_lis
 	for_each_migratetype_order(order, t) {
 		INIT_LIST_HEAD(&zone->free_area[order].free_list[t]);
 		zone->free_area[order].nr_free = 0;
+#ifdef CONFIG_CMA
 		zone->free_area[order].cma_nr_free = 0;
+#endif
 	}
 }
 
@@ -6622,8 +6621,8 @@ __offline_isolated_pages(unsigned long s
 		list_del(&page->lru);
 		rmv_page_order(page);
 		zone->free_area[order].nr_free--;
-		if (is_migrate_cma(get_pageblock_migratetype(page)))
-			zone->free_area[order].cma_nr_free--;
+		cma_nr_free_dec(get_pageblock_migratetype(page),
+				&zone->free_area[order]);
 		for (i = 0; i < (1 << order); i++)
 			SetPageReserved((page+i));
 		pfn += (1 << order);
diff -puN include/linux/cma.h~cma-fix-cmas-page-number-is-substructed-twice-in-__zone_watermark_ok-fix-2 include/linux/cma.h
--- a/include/linux/cma.h~cma-fix-cmas-page-number-is-substructed-twice-in-__zone_watermark_ok-fix-2
+++ a/include/linux/cma.h
@@ -1,6 +1,8 @@
 #ifndef __CMA_H__
 #define __CMA_H__
 
+#include <linux/mmzone.h>
+
 /*
  * There is always at least global CMA area and a few optional
  * areas configured in kernel .config.
@@ -28,4 +30,38 @@ extern int cma_init_reserved_mem(phys_ad
 					struct cma **res_cma);
 extern struct page *cma_alloc(struct cma *cma, int count, unsigned int align);
 extern bool cma_release(struct cma *cma, struct page *pages, int count);
+
+#ifdef CONFIG_CMA
+static inline void cma_nr_free_add(int migratetype, struct free_area *area,
+				   int delta)
+{
+	if (is_migrate_cma(migratetype))
+		area->cma_nr_free += delta;
+}
+
+static inline void cma_nr_free_inc(int migratetype, struct free_area *area)
+{
+	cma_nr_free_add(migratetype, area, 1);
+}
+
+static inline void cma_nr_free_dec(int migratetype, struct free_area *area)
+{
+	cma_nr_free_add(migratetype, area, -1);
+}
+#else
+static inline void cma_nr_free_add(int migratetype, struct free_area *area,
+				   int delta)
+{
+}
+
+static inline void cma_nr_free_inc(int migratetype, struct free_area *area)
+{
+}
+
+static inline void cma_nr_free_dec(int migratetype, struct free_area *area)
+{
+}
+#endif		/* CONFIG_CMA */
+
+
 #endif
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
