Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f47.google.com (mail-qg0-f47.google.com [209.85.192.47])
	by kanga.kvack.org (Postfix) with ESMTP id 66CE06B0035
	for <linux-mm@kvack.org>; Sat, 19 Apr 2014 11:53:22 -0400 (EDT)
Received: by mail-qg0-f47.google.com with SMTP id i50so2620286qgf.20
        for <linux-mm@kvack.org>; Sat, 19 Apr 2014 08:53:22 -0700 (PDT)
Received: from mail-qa0-x235.google.com (mail-qa0-x235.google.com [2607:f8b0:400d:c00::235])
        by mx.google.com with ESMTPS id l5si13230154qai.215.2014.04.19.08.53.21
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 19 Apr 2014 08:53:21 -0700 (PDT)
Received: by mail-qa0-f53.google.com with SMTP id w8so2466339qac.40
        for <linux-mm@kvack.org>; Sat, 19 Apr 2014 08:53:21 -0700 (PDT)
From: Dan Streetman <ddstreet@ieee.org>
Subject: [PATCH 1/4] mm: zpool: zbud_alloc() minor param change
Date: Sat, 19 Apr 2014 11:52:41 -0400
Message-Id: <1397922764-1512-2-git-send-email-ddstreet@ieee.org>
In-Reply-To: <1397922764-1512-1-git-send-email-ddstreet@ieee.org>
References: <1397922764-1512-1-git-send-email-ddstreet@ieee.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjennings@variantweb.net>, Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>
Cc: Dan Streetman <ddstreet@ieee.org>, Andrew Morton <akpm@linux-foundation.org>, Bob Liu <bob.liu@oracle.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Weijie Yang <weijie.yang@samsung.com>, Johannes Weiner <hannes@cmpxchg.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

Change zbud to store gfp_t flags passed at pool creation to use for
each alloc; this allows the api to be closer to the existing zsmalloc
interface, and the only current zbud user (zswap) uses the same gfp
flags for all allocs.  Update zswap to use changed interface.

Signed-off-by: Dan Streetman <ddstreet@ieee.org>

---
 include/linux/zbud.h |  3 +--
 mm/zbud.c            | 28 +++++++++++++++-------------
 mm/zswap.c           |  6 +++---
 3 files changed, 19 insertions(+), 18 deletions(-)

diff --git a/include/linux/zbud.h b/include/linux/zbud.h
index 2571a5c..50563b6 100644
--- a/include/linux/zbud.h
+++ b/include/linux/zbud.h
@@ -11,8 +11,7 @@ struct zbud_ops {
 
 struct zbud_pool *zbud_create_pool(gfp_t gfp, struct zbud_ops *ops);
 void zbud_destroy_pool(struct zbud_pool *pool);
-int zbud_alloc(struct zbud_pool *pool, int size, gfp_t gfp,
-	unsigned long *handle);
+int zbud_alloc(struct zbud_pool *pool, int size, unsigned long *handle);
 void zbud_free(struct zbud_pool *pool, unsigned long handle);
 int zbud_reclaim_page(struct zbud_pool *pool, unsigned int retries);
 void *zbud_map(struct zbud_pool *pool, unsigned long handle);
diff --git a/mm/zbud.c b/mm/zbud.c
index 9451361..e02f53f 100644
--- a/mm/zbud.c
+++ b/mm/zbud.c
@@ -94,6 +94,7 @@ struct zbud_pool {
 	struct list_head lru;
 	u64 pages_nr;
 	struct zbud_ops *ops;
+	gfp_t gfp;
 };
 
 /*
@@ -193,9 +194,12 @@ static int num_free_chunks(struct zbud_header *zhdr)
 *****************/
 /**
  * zbud_create_pool() - create a new zbud pool
- * @gfp:	gfp flags when allocating the zbud pool structure
+ * @gfp:	gfp flags when growing the pool
  * @ops:	user-defined operations for the zbud pool
  *
+ * gfp should not set __GFP_HIGHMEM as highmem pages cannot be used
+ * as zbud pool pages.
+ *
  * Return: pointer to the new zbud pool or NULL if the metadata allocation
  * failed.
  */
@@ -204,7 +208,9 @@ struct zbud_pool *zbud_create_pool(gfp_t gfp, struct zbud_ops *ops)
 	struct zbud_pool *pool;
 	int i;
 
-	pool = kmalloc(sizeof(struct zbud_pool), gfp);
+	if (gfp & __GFP_HIGHMEM)
+		return NULL;
+	pool = kmalloc(sizeof(struct zbud_pool), GFP_KERNEL);
 	if (!pool)
 		return NULL;
 	spin_lock_init(&pool->lock);
@@ -214,6 +220,7 @@ struct zbud_pool *zbud_create_pool(gfp_t gfp, struct zbud_ops *ops)
 	INIT_LIST_HEAD(&pool->lru);
 	pool->pages_nr = 0;
 	pool->ops = ops;
+	pool->gfp = gfp;
 	return pool;
 }
 
@@ -232,7 +239,6 @@ void zbud_destroy_pool(struct zbud_pool *pool)
  * zbud_alloc() - allocates a region of a given size
  * @pool:	zbud pool from which to allocate
  * @size:	size in bytes of the desired allocation
- * @gfp:	gfp flags used if the pool needs to grow
  * @handle:	handle of the new allocation
  *
  * This function will attempt to find a free region in the pool large enough to
@@ -240,22 +246,18 @@ void zbud_destroy_pool(struct zbud_pool *pool)
  * performed first. If no suitable free region is found, then a new page is
  * allocated and added to the pool to satisfy the request.
  *
- * gfp should not set __GFP_HIGHMEM as highmem pages cannot be used
- * as zbud pool pages.
- *
- * Return: 0 if success and handle is set, otherwise -EINVAL if the size or
- * gfp arguments are invalid or -ENOMEM if the pool was unable to allocate
- * a new page.
+ * Return: 0 if success and @handle is set, -ENOSPC if the @size is too large,
+ * -EINVAL if the @size is 0 or less, or -ENOMEM if the pool was unable to
+ * allocate a new page.
  */
-int zbud_alloc(struct zbud_pool *pool, int size, gfp_t gfp,
-			unsigned long *handle)
+int zbud_alloc(struct zbud_pool *pool, int size, unsigned long *handle)
 {
 	int chunks, i, freechunks;
 	struct zbud_header *zhdr = NULL;
 	enum buddy bud;
 	struct page *page;
 
-	if (size <= 0 || gfp & __GFP_HIGHMEM)
+	if (size <= 0)
 		return -EINVAL;
 	if (size > PAGE_SIZE - ZHDR_SIZE_ALIGNED - CHUNK_SIZE)
 		return -ENOSPC;
@@ -279,7 +281,7 @@ int zbud_alloc(struct zbud_pool *pool, int size, gfp_t gfp,
 
 	/* Couldn't find unbuddied zbud page, create new one */
 	spin_unlock(&pool->lock);
-	page = alloc_page(gfp);
+	page = alloc_page(pool->gfp);
 	if (!page)
 		return -ENOMEM;
 	spin_lock(&pool->lock);
diff --git a/mm/zswap.c b/mm/zswap.c
index aeaef0f..1cc6770 100644
--- a/mm/zswap.c
+++ b/mm/zswap.c
@@ -679,8 +679,7 @@ static int zswap_frontswap_store(unsigned type, pgoff_t offset,
 
 	/* store */
 	len = dlen + sizeof(struct zswap_header);
-	ret = zbud_alloc(zswap_pool, len, __GFP_NORETRY | __GFP_NOWARN,
-		&handle);
+	ret = zbud_alloc(zswap_pool, len, &handle);
 	if (ret == -ENOSPC) {
 		zswap_reject_compress_poor++;
 		goto freepage;
@@ -900,7 +899,8 @@ static int __init init_zswap(void)
 
 	pr_info("loading zswap\n");
 
-	zswap_pool = zbud_create_pool(GFP_KERNEL, &zswap_zbud_ops);
+	zswap_pool = zbud_create_pool(__GFP_NORETRY | __GFP_NOWARN,
+			&zswap_zbud_ops);
 	if (!zswap_pool) {
 		pr_err("zbud pool creation failed\n");
 		goto error;
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
