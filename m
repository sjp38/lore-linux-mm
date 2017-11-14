Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6C8606B0253
	for <linux-mm@kvack.org>; Tue, 14 Nov 2017 03:42:39 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id p9so19732764pgc.6
        for <linux-mm@kvack.org>; Tue, 14 Nov 2017 00:42:39 -0800 (PST)
Received: from mailout2.samsung.com (mailout2.samsung.com. [203.254.224.25])
        by mx.google.com with ESMTPS id g2si12950729pli.628.2017.11.14.00.42.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Nov 2017 00:42:38 -0800 (PST)
From: Jaewon Kim <jaewon31.kim@samsung.com>
Subject: [RFC PATCH] drivers: base: dma-coherent: find free region without
 alignment
Date: Tue, 14 Nov 2017 17:42:29 +0900
Message-id: <20171114084229.13512-1-jaewon31.kim@samsung.com>
References: <CGME20171114084234epcas2p44ac00494b49aa798f709c5bbdf92127a@epcas2p4.samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hch@lst.de, m.szyprowski@samsung.com, robin.murphy@arm.com, gregkh@linuxfoundation.org, iommu@lists.linux-foundation.org
Cc: akpm@linux-foundation.org, mhocko@suse.com, vbabka@suse.cz, linux-mm@kvack.org, linux-kernel@vger.kernel.org, jaewon31.kim@gmail.com, Jaewon Kim <jaewon31.kim@samsung.com>

dma-coherent uses bitmap API which internally consider align based on the
requested size. Depending on some usage pattern, using align, I think, may
be good for fast search and anti-fragmentation. But with the align, an
allocation may be failed.

This is a example, total size is 30MB, only few memory at front is being
used, and 9MB is being requsted. Then 9MB will be aligned to 16MB. The
first try on offset 0MB will be failed because of others already using. The
second try on offset 16MB will be failed because of ouf of bound.

So if the align is not necessary on dma-coherent, this patch removes the
align policy to allow allocation without increasing the total size.

Signed-off-by: Jaewon Kim <jaewon31.kim@samsung.com>
---
 drivers/base/dma-coherent.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/base/dma-coherent.c b/drivers/base/dma-coherent.c
index 744f64f43454..b86a96d0cd07 100644
--- a/drivers/base/dma-coherent.c
+++ b/drivers/base/dma-coherent.c
@@ -162,7 +162,7 @@ EXPORT_SYMBOL(dma_mark_declared_memory_occupied);
 static void *__dma_alloc_from_coherent(struct dma_coherent_mem *mem,
 		ssize_t size, dma_addr_t *dma_handle)
 {
-	int order = get_order(size);
+	int nr_page = PAGE_ALIGN(size) >> PAGE_SHIFT;
 	unsigned long flags;
 	int pageno;
 	void *ret;
@@ -172,9 +172,11 @@ static void *__dma_alloc_from_coherent(struct dma_coherent_mem *mem,
 	if (unlikely(size > (mem->size << PAGE_SHIFT)))
 		goto err;
 
-	pageno = bitmap_find_free_region(mem->bitmap, mem->size, order);
-	if (unlikely(pageno < 0))
+	pageno = bitmap_find_next_zero_area(mem->bitmap, mem->size, 0,
+					    nr_page, 0);
+	if (unlikely(pageno >= mem->size)) {
 		goto err;
+	bitmap_set(mem->bitmap, pageno, nr_page);
 
 	/*
 	 * Memory was found in the coherent area.
-- 
2.13.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
