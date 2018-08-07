Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 714836B000E
	for <linux-mm@kvack.org>; Tue,  7 Aug 2018 12:47:31 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id e14-v6so13745466qtp.17
        for <linux-mm@kvack.org>; Tue, 07 Aug 2018 09:47:31 -0700 (PDT)
Received: from mail.cybernetics.com (mail.cybernetics.com. [173.71.130.66])
        by mx.google.com with ESMTPS id f20-v6si1334366qtp.48.2018.08.07.09.47.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Aug 2018 09:47:30 -0700 (PDT)
From: Tony Battersby <tonyb@cybernetics.com>
Subject: [PATCH v3 05/10] dmapool: rename fields in dma_page
Message-ID: <bfaae864-548f-3d1e-6a4b-d987b49ff537@cybernetics.com>
Date: Tue, 7 Aug 2018 12:47:28 -0400
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, Christoph Hellwig <hch@lst.de>, Marek Szyprowski <m.szyprowski@samsung.com>, Sathya Prakash <sathya.prakash@broadcom.com>, Chaitra P B <chaitra.basappa@broadcom.com>, Suganath Prabu Subramani <suganath-prabu.subramani@broadcom.com>, "iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>, "MPT-FusionLinux.pdl@broadcom.com" <MPT-FusionLinux.pdl@broadcom.com>

Rename fields in 'struct dma_page' in preparation for moving them into
'struct page'.  No functional changes.

in_use -> dma_in_use
offset -> dma_free_off

Signed-off-by: Tony Battersby <tonyb@cybernetics.com>
---

Changes since v2:
Use dma_free_off instead of dma_free_o.

--- linux/mm/dmapool.c.orig	2018-08-03 17:46:13.000000000 -0400
+++ linux/mm/dmapool.c	2018-08-03 17:46:24.000000000 -0400
@@ -65,8 +65,8 @@ struct dma_page {		/* cacheable header f
 	struct list_head dma_list;
 	void *vaddr;
 	dma_addr_t dma;
-	unsigned int in_use;
-	unsigned int offset;
+	unsigned int dma_in_use;
+	unsigned int dma_free_off;
 };
 
 static DEFINE_MUTEX(pools_lock);
@@ -101,7 +101,7 @@ show_pools(struct device *dev, struct de
 					    &pool->page_list[list_idx],
 					    dma_list) {
 				pages++;
-				blocks += page->in_use;
+				blocks += page->dma_in_use;
 			}
 		}
 		spin_unlock_irq(&pool->lock);
@@ -248,8 +248,8 @@ static struct dma_page *pool_alloc_page(
 		memset(page->vaddr, POOL_POISON_FREED, pool->allocation);
 #endif
 		pool_initialise_page(pool, page);
-		page->in_use = 0;
-		page->offset = 0;
+		page->dma_in_use = 0;
+		page->dma_free_off = 0;
 	} else {
 		kfree(page);
 		page = NULL;
@@ -259,7 +259,7 @@ static struct dma_page *pool_alloc_page(
 
 static inline bool is_page_busy(struct dma_page *page)
 {
-	return page->in_use != 0;
+	return page->dma_in_use != 0;
 }
 
 static void pool_free_page(struct dma_pool *pool, struct dma_page *page)
@@ -362,10 +362,10 @@ void *dma_pool_alloc(struct dma_pool *po
 
 	list_add(&page->dma_list, &pool->page_list[POOL_AVAIL_IDX]);
  ready:
-	page->in_use++;
-	offset = page->offset;
-	page->offset = *(int *)(page->vaddr + offset);
-	if (page->offset >= pool->allocation)
+	page->dma_in_use++;
+	offset = page->dma_free_off;
+	page->dma_free_off = *(int *)(page->vaddr + offset);
+	if (page->dma_free_off >= pool->allocation)
 		/* Move page from the "available" list to the "full" list. */
 		list_move_tail(&page->dma_list,
 			       &pool->page_list[POOL_FULL_IDX]);
@@ -375,8 +375,8 @@ void *dma_pool_alloc(struct dma_pool *po
 	{
 		int i;
 		u8 *data = retval;
-		/* page->offset is stored in first 4 bytes */
-		for (i = sizeof(page->offset); i < pool->size; i++) {
+		/* page->dma_free_off is stored in first 4 bytes */
+		for (i = sizeof(page->dma_free_off); i < pool->size; i++) {
 			if (data[i] == POOL_POISON_FREED)
 				continue;
 			dev_err(pool->dev,
@@ -458,7 +458,7 @@ void dma_pool_free(struct dma_pool *pool
 		return;
 	}
 	{
-		unsigned int chain = page->offset;
+		unsigned int chain = page->dma_free_off;
 		while (chain < pool->allocation) {
 			if (chain != offset) {
 				chain = *(int *)(page->vaddr + chain);
@@ -474,12 +474,12 @@ void dma_pool_free(struct dma_pool *pool
 	memset(vaddr, POOL_POISON_FREED, pool->size);
 #endif
 
-	page->in_use--;
-	if (page->offset >= pool->allocation)
+	page->dma_in_use--;
+	if (page->dma_free_off >= pool->allocation)
 		/* Move page from the "full" list to the "available" list. */
 		list_move(&page->dma_list, &pool->page_list[POOL_AVAIL_IDX]);
-	*(int *)vaddr = page->offset;
-	page->offset = offset;
+	*(int *)vaddr = page->dma_free_off;
+	page->dma_free_off = offset;
 	/*
 	 * Resist a temptation to do
 	 *    if (!is_page_busy(page)) pool_free_page(pool, page);
