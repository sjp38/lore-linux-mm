Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 698D76B026A
	for <linux-mm@kvack.org>; Tue,  7 Aug 2018 12:48:41 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id l15-v6so17061394qki.18
        for <linux-mm@kvack.org>; Tue, 07 Aug 2018 09:48:41 -0700 (PDT)
Received: from mail.cybernetics.com (mail.cybernetics.com. [173.71.130.66])
        by mx.google.com with ESMTPS id d20-v6si276777qvf.180.2018.08.07.09.48.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Aug 2018 09:48:40 -0700 (PDT)
From: Tony Battersby <tonyb@cybernetics.com>
Subject: [PATCH v3 07/10] dmapool: cleanup integer types
Message-ID: <5d0aec14-73e0-280d-62fb-2b0fe6c01418@cybernetics.com>
Date: Tue, 7 Aug 2018 12:48:38 -0400
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, Christoph Hellwig <hch@lst.de>, Marek Szyprowski <m.szyprowski@samsung.com>, Sathya Prakash <sathya.prakash@broadcom.com>, Chaitra P B <chaitra.basappa@broadcom.com>, Suganath Prabu Subramani <suganath-prabu.subramani@broadcom.com>, "iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>, "MPT-FusionLinux.pdl@broadcom.com" <MPT-FusionLinux.pdl@broadcom.com>

To represent the size of a single allocation, dmapool currently uses
'unsigned int' in some places and 'size_t' in other places.  Standardize
on 'unsigned int' to reduce overhead, but use 'size_t' when counting all
the blocks in the entire pool.

Signed-off-by: Tony Battersby <tonyb@cybernetics.com>
---

This was split off from "dmapool: reduce footprint in struct page" in v2.

This puts an upper bound on 'size' of INT_MAX to avoid overflowing the
following comparison in pool_initialize_free_block_list():

unsigned int offset = 0;
unsigned int next = offset + pool->size;
if (unlikely((next + pool->size) > ...

The actual maximum allocation size is probably lower anyway, probably
KMALLOC_MAX_SIZE, but that gets into the implementation details of other
subsystems which don't export a predefined maximum, so I didn't want to
hardcode it here.  The purpose of the added bounds check is to avoid
overflowing integers, not to check the actual
(platform/device/config-specific?) maximum allocation size.

'boundary' is passed in as a size_t but gets stored as an unsigned int. 
'boundary' values >= 'allocation' do not have any effect, so clipping
'boundary' to 'allocation' keeps it within the range of unsigned int
without affecting anything else.  A few lines above (not in the diff)
you can see that if 'boundary' is passed in as 0 then it is set to
'allocation', so it is nothing new.  For reference, here is the
relevant code after being patched:

	if (!boundary)
		boundary = allocation;
	else if ((boundary < size) || (boundary & (boundary - 1)))
		return NULL;

	boundary = min(boundary, allocation);

--- linux/mm/dmapool.c.orig	2018-08-06 17:48:19.000000000 -0400
+++ linux/mm/dmapool.c	2018-08-06 17:48:54.000000000 -0400
@@ -57,10 +57,10 @@ struct dma_pool {		/* the pool */
 #define POOL_MAX_IDX    2
 	struct list_head page_list[POOL_MAX_IDX];
 	spinlock_t lock;
-	size_t size;
+	unsigned int size;
 	struct device *dev;
-	size_t allocation;
-	size_t boundary;
+	unsigned int allocation;
+	unsigned int boundary;
 	char name[32];
 	struct list_head pools;
 };
@@ -86,7 +86,7 @@ show_pools(struct device *dev, struct de
 	mutex_lock(&pools_lock);
 	list_for_each_entry(pool, &dev->dma_pools, pools) {
 		unsigned pages = 0;
-		unsigned blocks = 0;
+		size_t blocks = 0;
 		int list_idx;
 
 		spin_lock_irq(&pool->lock);
@@ -103,9 +103,10 @@ show_pools(struct device *dev, struct de
 		spin_unlock_irq(&pool->lock);
 
 		/* per-pool info, no real statistics yet */
-		temp = scnprintf(next, size, "%-16s %4u %4zu %4zu %2u\n",
+		temp = scnprintf(next, size, "%-16s %4zu %4zu %4u %2u\n",
 				 pool->name, blocks,
-				 pages * (pool->allocation / pool->size),
+				 (size_t) pages *
+				 (pool->allocation / pool->size),
 				 pool->size, pages);
 		size -= temp;
 		next += temp;
@@ -150,7 +151,7 @@ struct dma_pool *dma_pool_create(const c
 	else if (align & (align - 1))
 		return NULL;
 
-	if (size == 0)
+	if (size == 0 || size > INT_MAX)
 		return NULL;
 	else if (size < 4)
 		size = 4;
@@ -165,6 +166,8 @@ struct dma_pool *dma_pool_create(const c
 	else if ((boundary < size) || (boundary & (boundary - 1)))
 		return NULL;
 
+	boundary = min(boundary, allocation);
+
 	retval = kmalloc_node(sizeof(*retval), GFP_KERNEL, dev_to_node(dev));
 	if (!retval)
 		return retval;
@@ -344,7 +347,7 @@ void *dma_pool_alloc(struct dma_pool *po
 {
 	unsigned long flags;
 	struct page *page;
-	size_t offset;
+	unsigned int offset;
 	void *retval;
 	void *vaddr;
 
