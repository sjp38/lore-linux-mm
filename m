Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e4.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id k0PLb4JX030584
	for <linux-mm@kvack.org>; Wed, 25 Jan 2006 16:37:04 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.12.10/NCO/VERS6.8) with ESMTP id k0PLb0vN150628
	for <linux-mm@kvack.org>; Wed, 25 Jan 2006 16:37:04 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11/8.13.3) with ESMTP id k0PLb0p5006120
	for <linux-mm@kvack.org>; Wed, 25 Jan 2006 16:37:00 -0500
Subject: [patch 2/9] mempool - Use common mempool page allocator
From: Matthew Dobson <colpatch@us.ibm.com>
Reply-To: colpatch@us.ibm.com
References: <20060125161321.647368000@localhost.localdomain>
Content-Type: text/plain
Date: Wed, 25 Jan 2006 11:39:57 -0800
Message-Id: <1138217998.2092.2.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: sri@us.ibm.com, andrea@suse.de, pavel@suse.cz, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

plain text document attachment (critical_mempools)
Convert two mempool users that currently use their own mempool-backed page
allocators to use the generic mempool page allocator.

Also included are 2 trivial whitespace fixes.

Signed-off-by: Matthew Dobson <colpatch@us.ibm.com>

 drivers/md/dm-crypt.c |   17 ++---------------
 mm/highmem.c          |   23 ++++++++---------------
 2 files changed, 10 insertions(+), 30 deletions(-)

Index: linux-2.6.16-rc1+critical_mempools/drivers/md/dm-crypt.c
===================================================================
--- linux-2.6.16-rc1+critical_mempools.orig/drivers/md/dm-crypt.c
+++ linux-2.6.16-rc1+critical_mempools/drivers/md/dm-crypt.c
@@ -93,19 +93,6 @@ struct crypt_config {
 
 static kmem_cache_t *_crypt_io_pool;
 
-/*
- * Mempool alloc and free functions for the page
- */
-static void *mempool_alloc_page(gfp_t gfp_mask, void *data)
-{
-	return alloc_page(gfp_mask);
-}
-
-static void mempool_free_page(void *page, void *data)
-{
-	__free_page(page);
-}
-
 
 /*
  * Different IV generation algorithms:
@@ -637,8 +624,8 @@ static int crypt_ctr(struct dm_target *t
 		goto bad3;
 	}
 
-	cc->page_pool = mempool_create(MIN_POOL_PAGES, mempool_alloc_page,
-				       mempool_free_page, NULL);
+	cc->page_pool = mempool_create(MIN_POOL_PAGES, mempool_alloc_pages,
+				       mempool_free_pages, 0);
 	if (!cc->page_pool) {
 		ti->error = PFX "Cannot allocate page mempool";
 		goto bad4;
Index: linux-2.6.16-rc1+critical_mempools/mm/highmem.c
===================================================================
--- linux-2.6.16-rc1+critical_mempools.orig/mm/highmem.c
+++ linux-2.6.16-rc1+critical_mempools/mm/highmem.c
@@ -30,15 +30,11 @@
 
 static mempool_t *page_pool, *isa_page_pool;
 
-static void *page_pool_alloc_isa(gfp_t gfp_mask, void *data)
+static void *mempool_alloc_pages_isa(gfp_t gfp_mask, void *data)
 {
-	return alloc_page(gfp_mask | GFP_DMA);
+	return mempool_alloc_pages(gfp_mask | GFP_DMA, data);
 }
 
-static void page_pool_free(void *page, void *data)
-{
-	__free_page(page);
-}
 
 /*
  * Virtual_count is not a pure "count".
@@ -50,11 +46,6 @@ static void page_pool_free(void *page, v
  */
 #ifdef CONFIG_HIGHMEM
 
-static void *page_pool_alloc(gfp_t gfp_mask, void *data)
-{
-	return alloc_page(gfp_mask);
-}
-
 static int pkmap_count[LAST_PKMAP];
 static unsigned int last_pkmap_nr;
 static  __cacheline_aligned_in_smp DEFINE_SPINLOCK(kmap_lock);
@@ -228,7 +219,8 @@ static __init int init_emergency_pool(vo
 	if (!i.totalhigh)
 		return 0;
 
-	page_pool = mempool_create(POOL_SIZE, page_pool_alloc, page_pool_free, NULL);
+	page_pool = mempool_create(POOL_SIZE, mempool_alloc_pages,
+				   mempool_free_pages, 0);
 	if (!page_pool)
 		BUG();
 	printk("highmem bounce pool size: %d pages\n", POOL_SIZE);
@@ -271,7 +263,8 @@ int init_emergency_isa_pool(void)
 	if (isa_page_pool)
 		return 0;
 
-	isa_page_pool = mempool_create(ISA_POOL_SIZE, page_pool_alloc_isa, page_pool_free, NULL);
+	isa_page_pool = mempool_create(ISA_POOL_SIZE, mempool_alloc_pages_isa,
+				       mempool_free_pages, 0);
 	if (!isa_page_pool)
 		BUG();
 
@@ -336,7 +329,7 @@ static void bounce_end_io(struct bio *bi
 	bio_put(bio);
 }
 
-static int bounce_end_io_write(struct bio *bio, unsigned int bytes_done,int err)
+static int bounce_end_io_write(struct bio *bio, unsigned int bytes_done, int err)
 {
 	if (bio->bi_size)
 		return 1;
@@ -383,7 +376,7 @@ static int bounce_end_io_read_isa(struct
 }
 
 static void __blk_queue_bounce(request_queue_t *q, struct bio **bio_orig,
-			mempool_t *pool)
+			       mempool_t *pool)
 {
 	struct page *page;
 	struct bio *bio = NULL;

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
