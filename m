Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id EFE6F6B0008
	for <linux-mm@kvack.org>; Thu, 26 Jul 2018 14:54:24 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id x9-v6so1984774qto.18
        for <linux-mm@kvack.org>; Thu, 26 Jul 2018 11:54:24 -0700 (PDT)
Received: from mail.cybernetics.com (mail.cybernetics.com. [173.71.130.66])
        by mx.google.com with ESMTPS id s31-v6si2129460qtj.26.2018.07.26.11.54.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Jul 2018 11:54:24 -0700 (PDT)
From: Tony Battersby <tonyb@cybernetics.com>
Subject: [PATCH 1/3] dmapool: improve scalability of dma_pool_alloc
Message-ID: <15ff502d-d840-1003-6c45-bc17f0d81262@cybernetics.com>
Date: Thu, 26 Jul 2018 14:54:21 -0400
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>, Marek Szyprowski <m.szyprowski@samsung.com>, Matthew Wilcox <willy@infradead.org>, Sathya Prakash <sathya.prakash@broadcom.com>, Chaitra P B <chaitra.basappa@broadcom.com>, Suganath Prabu Subramani <suganath-prabu.subramani@broadcom.com>, iommu@lists.linux-foundation.org, linux-mm@kvack.org, linux-scsi@vger.kernel.org, MPT-FusionLinux.pdl@broadcom.com

dma_pool_alloc() scales poorly when allocating a large number of pages
because it does a linear scan of all previously-allocated pages before
allocating a new one.  Improve its scalability by maintaining a separate
list of pages that have free blocks ready to (re)allocate.  In big O
notation, this improves the algorithm from O(n^2) to O(n).

Signed-off-by: Tony Battersby <tonyb@cybernetics.com>
---

Using list_del_init() in dma_pool_alloc() makes it safe to call
list_del() unconditionally when freeing the page.

In dma_pool_free(), the check for being already in avail_page_list could
be written several different ways.  The most obvious way is:

if (page->offset >= pool->allocation)
	list_add(&page->avail_page_link, &pool->avail_page_list);

Another way would be to check page->in_use.  But since it is already
using list_del_init(), checking the list pointers directly is safest to
prevent any possible list corruption in case the caller misuses the API
(e.g. double-dma_pool_free()) with DMAPOOL_DEBUG disabled.

--- a/mm/dmapool.c
+++ b/mm/dmapool.c
@@ -20,6 +20,10 @@
  * least 'size' bytes.  Free blocks are tracked in an unsorted singly-linked
  * list of free blocks within the page.  Used blocks aren't tracked, but we
  * keep a count of how many are currently allocated from each page.
+ *
+ * The avail_page_list keeps track of pages that have one or more free blocks
+ * available to (re)allocate.  Pages are moved in and out of avail_page_list
+ * as their blocks are allocated and freed.
  */
 
 #include <linux/device.h>
@@ -44,6 +48,7 @@
 
 struct dma_pool {		/* the pool */
 	struct list_head page_list;
+	struct list_head avail_page_list;
 	spinlock_t lock;
 	size_t size;
 	struct device *dev;
@@ -55,6 +60,7 @@ struct dma_pool {		/* the pool */
 
 struct dma_page {		/* cacheable header for 'allocation' bytes */
 	struct list_head page_list;
+	struct list_head avail_page_link;
 	void *vaddr;
 	dma_addr_t dma;
 	unsigned int in_use;
@@ -164,6 +170,7 @@ struct dma_pool *dma_pool_create(const c
 	retval->dev = dev;
 
 	INIT_LIST_HEAD(&retval->page_list);
+	INIT_LIST_HEAD(&retval->avail_page_list);
 	spin_lock_init(&retval->lock);
 	retval->size = size;
 	retval->boundary = boundary;
@@ -256,6 +263,7 @@ static void pool_free_page(struct dma_po
 #endif
 	dma_free_coherent(pool->dev, pool->allocation, page->vaddr, dma);
 	list_del(&page->page_list);
+	list_del(&page->avail_page_link);
 	kfree(page);
 }
 
@@ -298,6 +306,7 @@ void dma_pool_destroy(struct dma_pool *p
 				       pool->name, page->vaddr);
 			/* leak the still-in-use consistent memory */
 			list_del(&page->page_list);
+			list_del(&page->avail_page_link);
 			kfree(page);
 		} else
 			pool_free_page(pool, page);
@@ -328,9 +337,11 @@ void *dma_pool_alloc(struct dma_pool *po
 	might_sleep_if(gfpflags_allow_blocking(mem_flags));
 
 	spin_lock_irqsave(&pool->lock, flags);
-	list_for_each_entry(page, &pool->page_list, page_list) {
-		if (page->offset < pool->allocation)
-			goto ready;
+	if (!list_empty(&pool->avail_page_list)) {
+		page = list_first_entry(&pool->avail_page_list,
+					struct dma_page,
+					avail_page_link);
+		goto ready;
 	}
 
 	/* pool_alloc_page() might sleep, so temporarily drop &pool->lock */
@@ -343,10 +354,13 @@ void *dma_pool_alloc(struct dma_pool *po
 	spin_lock_irqsave(&pool->lock, flags);
 
 	list_add(&page->page_list, &pool->page_list);
+	list_add(&page->avail_page_link, &pool->avail_page_list);
  ready:
 	page->in_use++;
 	offset = page->offset;
 	page->offset = *(int *)(page->vaddr + offset);
+	if (page->offset >= pool->allocation)
+		list_del_init(&page->avail_page_link);
 	retval = offset + page->vaddr;
 	*handle = offset + page->dma;
 #ifdef	DMAPOOL_DEBUG
@@ -461,6 +475,10 @@ void dma_pool_free(struct dma_pool *pool
 	memset(vaddr, POOL_POISON_FREED, pool->size);
 #endif
 
+	/* This test checks if the page is already in avail_page_list. */
+	if (list_empty(&page->avail_page_link))
+		list_add(&page->avail_page_link, &pool->avail_page_list);
+
 	page->in_use--;
 	*(int *)vaddr = page->offset;
 	page->offset = offset;
