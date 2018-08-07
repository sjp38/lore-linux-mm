Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id C0AFE6B0008
	for <linux-mm@kvack.org>; Tue,  7 Aug 2018 12:46:21 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id 17-v6so17276387qkz.15
        for <linux-mm@kvack.org>; Tue, 07 Aug 2018 09:46:21 -0700 (PDT)
Received: from mail.cybernetics.com (mail.cybernetics.com. [173.71.130.66])
        by mx.google.com with ESMTPS id 9-v6si1848731qkv.364.2018.08.07.09.46.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Aug 2018 09:46:20 -0700 (PDT)
From: Tony Battersby <tonyb@cybernetics.com>
Subject: [PATCH v3 03/10] dmapool: cleanup dma_pool_destroy
Message-ID: <9fb39095-4dd8-877a-b857-649e76fedd59@cybernetics.com>
Date: Tue, 7 Aug 2018 12:46:18 -0400
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, Christoph Hellwig <hch@lst.de>, Marek Szyprowski <m.szyprowski@samsung.com>, Sathya Prakash <sathya.prakash@broadcom.com>, Chaitra P B <chaitra.basappa@broadcom.com>, Suganath Prabu Subramani <suganath-prabu.subramani@broadcom.com>, "iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>, "MPT-FusionLinux.pdl@broadcom.com" <MPT-FusionLinux.pdl@broadcom.com>

Remove a small amount of code duplication between dma_pool_destroy() and
pool_free_page() in preparation for adding more code without having to
duplicate it.  No functional changes.

Signed-off-by: Tony Battersby <tonyb@cybernetics.com>
---

No changes since v2.

--- linux/mm/dmapool.c.orig	2018-08-02 09:59:15.000000000 -0400
+++ linux/mm/dmapool.c	2018-08-02 10:01:26.000000000 -0400
@@ -249,13 +249,22 @@ static inline bool is_page_busy(struct d
 
 static void pool_free_page(struct dma_pool *pool, struct dma_page *page)
 {
+	void *vaddr = page->vaddr;
 	dma_addr_t dma = page->dma;
 
+	list_del(&page->page_list);
+
+	if (is_page_busy(page)) {
+		dev_err(pool->dev,
+			"dma_pool_destroy %s, %p busy\n",
+			pool->name, vaddr);
+		/* leak the still-in-use consistent memory */
+	} else {
 #ifdef	DMAPOOL_DEBUG
-	memset(page->vaddr, POOL_POISON_FREED, pool->allocation);
+		memset(vaddr, POOL_POISON_FREED, pool->allocation);
 #endif
-	dma_free_coherent(pool->dev, pool->allocation, page->vaddr, dma);
-	list_del(&page->page_list);
+		dma_free_coherent(pool->dev, pool->allocation, vaddr, dma);
+	}
 	kfree(page);
 }
 
@@ -269,6 +278,7 @@ static void pool_free_page(struct dma_po
  */
 void dma_pool_destroy(struct dma_pool *pool)
 {
+	struct dma_page *page;
 	bool empty = false;
 
 	if (unlikely(!pool))
@@ -284,19 +294,10 @@ void dma_pool_destroy(struct dma_pool *p
 		device_remove_file(pool->dev, &dev_attr_pools);
 	mutex_unlock(&pools_reg_lock);
 
-	while (!list_empty(&pool->page_list)) {
-		struct dma_page *page;
-		page = list_entry(pool->page_list.next,
-				  struct dma_page, page_list);
-		if (is_page_busy(page)) {
-			dev_err(pool->dev,
-				"dma_pool_destroy %s, %p busy\n",
-				pool->name, page->vaddr);
-			/* leak the still-in-use consistent memory */
-			list_del(&page->page_list);
-			kfree(page);
-		} else
-			pool_free_page(pool, page);
+	while ((page = list_first_entry_or_null(&pool->page_list,
+						struct dma_page,
+						page_list))) {
+		pool_free_page(pool, page);
 	}
 
 	kfree(pool);
