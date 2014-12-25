Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 685736B006C
	for <linux-mm@kvack.org>; Thu, 25 Dec 2014 04:55:43 -0500 (EST)
Received: by mail-pa0-f43.google.com with SMTP id kx10so11617829pab.2
        for <linux-mm@kvack.org>; Thu, 25 Dec 2014 01:55:43 -0800 (PST)
Received: from mx1.mxmail.xiaomi.com ([58.68.235.87])
        by mx.google.com with ESMTP id fr15si37504934pdb.245.2014.12.25.01.55.40
        for <linux-mm@kvack.org>;
        Thu, 25 Dec 2014 01:55:42 -0800 (PST)
From: Hui Zhu <zhuhui@xiaomi.com>
Subject: [PATCH 3/3] CMA: Add cma_alloc_counter to make cma_alloc work better if it meet busy range
Date: Thu, 25 Dec 2014 17:43:28 +0800
Message-ID: <1419500608-11656-4-git-send-email-zhuhui@xiaomi.com>
In-Reply-To: <1419500608-11656-1-git-send-email-zhuhui@xiaomi.com>
References: <1419500608-11656-1-git-send-email-zhuhui@xiaomi.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: m.szyprowski@samsung.com, mina86@mina86.com, akpm@linux-foundation.org, iamjoonsoo.kim@lge.com, aneesh.kumar@linux.vnet.ibm.com, pintu.k@samsung.com, weijie.yang@samsung.com, mgorman@suse.de, hannes@cmpxchg.org, riel@redhat.com, vbabka@suse.cz, laurent.pinchart+renesas@ideasonboard.com, rientjes@google.com, sasha.levin@oracle.com, liuweixing@xiaomi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: teawater@gmail.com, Hui Zhu <zhuhui@xiaomi.com>

In [1], Joonsoo said that cma_alloc_counter is useless because pageblock
is isolated.
But if alloc_contig_range meet a busy range, it will undo_isolate_page_range
before goto try next range. At this time, __rmqueue_cma can begin allocd
CMA memory from the range.

So I add cma_alloc_counter let __rmqueue doesn't call __rmqueue_cma when
cma_alloc works.

[1] https://lkml.org/lkml/2014/10/24/26

Signed-off-by: Hui Zhu <zhuhui@xiaomi.com>
---
 include/linux/cma.h | 2 ++
 mm/cma.c            | 6 ++++++
 mm/page_alloc.c     | 8 +++++++-
 3 files changed, 15 insertions(+), 1 deletion(-)

diff --git a/include/linux/cma.h b/include/linux/cma.h
index 9384ba6..155158f 100644
--- a/include/linux/cma.h
+++ b/include/linux/cma.h
@@ -26,6 +26,8 @@ extern int __init cma_declare_contiguous(phys_addr_t base,
 extern int cma_init_reserved_mem(phys_addr_t base,
 					phys_addr_t size, int order_per_bit,
 					struct cma **res_cma);
+
+extern atomic_t cma_alloc_counter;
 extern struct page *cma_alloc(struct cma *cma, int count, unsigned int align);
 extern bool cma_release(struct cma *cma, struct page *pages, int count);
 #endif
diff --git a/mm/cma.c b/mm/cma.c
index 6707b5d..b63f6be 100644
--- a/mm/cma.c
+++ b/mm/cma.c
@@ -348,6 +348,8 @@ err:
 	return ret;
 }
 
+atomic_t cma_alloc_counter = ATOMIC_INIT(0);
+
 /**
  * cma_alloc() - allocate pages from contiguous area
  * @cma:   Contiguous memory region for which the allocation is performed.
@@ -378,6 +380,8 @@ struct page *cma_alloc(struct cma *cma, int count, unsigned int align)
 	bitmap_maxno = cma_bitmap_maxno(cma);
 	bitmap_count = cma_bitmap_pages_to_bits(cma, count);
 
+	atomic_inc(&cma_alloc_counter);
+
 	for (;;) {
 		mutex_lock(&cma->lock);
 		bitmap_no = bitmap_find_next_zero_area_off(cma->bitmap,
@@ -415,6 +419,8 @@ struct page *cma_alloc(struct cma *cma, int count, unsigned int align)
 		start = bitmap_no + mask + 1;
 	}
 
+	atomic_dec(&cma_alloc_counter);
+
 	pr_debug("%s(): returned %p\n", __func__, page);
 	return page;
 }
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index a5bbc38..0622c4c 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -66,6 +66,10 @@
 #include <asm/div64.h>
 #include "internal.h"
 
+#ifdef CONFIG_CMA
+#include <linux/cma.h>
+#endif
+
 /* prevent >1 _updater_ of zone percpu pageset ->high and ->batch fields */
 static DEFINE_MUTEX(pcp_batch_high_lock);
 #define MIN_PERCPU_PAGELIST_FRACTION	(8)
@@ -1330,7 +1334,9 @@ static struct page *__rmqueue(struct zone *zone, unsigned int order,
 {
 	struct page *page = NULL;
 
-	if (IS_ENABLED(CONFIG_CMA) && zone->managed_cma_pages) {
+	if (IS_ENABLED(CONFIG_CMA)
+	    && zone->managed_cma_pages
+	    && atomic_read(&cma_alloc_counter) == 0) {
 		if (migratetype == MIGRATE_MOVABLE
 		    && zone->nr_try_movable <= 0)
 			page = __rmqueue_cma(zone, order);
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
