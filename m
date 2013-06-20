Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id 5A6516B0033
	for <linux-mm@kvack.org>; Thu, 20 Jun 2013 10:38:35 -0400 (EDT)
Received: by mail-pd0-f180.google.com with SMTP id 10so6313765pdi.11
        for <linux-mm@kvack.org>; Thu, 20 Jun 2013 07:38:34 -0700 (PDT)
From: Bob Liu <lliubbo@gmail.com>
Subject: [PATCH 1/2] zswap: limit pool fragment
Date: Thu, 20 Jun 2013 22:38:22 +0800
Message-Id: <1371739102-11436-1-git-send-email-bob.liu@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: sjenning@linux.vnet.ibm.com, linux-mm@kvack.org, konrad.wilk@oracle.com, Bob Liu <bob.liu@oracle.com>

If zswap pool fragment is heavy, it's meanless to store more pages to zswap.
So refuse allocate page to zswap pool to limit the fragmentation.

Signed-off-by: Bob Liu <bob.liu@oracle.com>
---
 include/linux/zbud.h |    2 +-
 mm/zbud.c            |    4 +++-
 mm/zswap.c           |   15 +++++++++++++--
 3 files changed, 17 insertions(+), 4 deletions(-)

diff --git a/include/linux/zbud.h b/include/linux/zbud.h
index 2571a5c..71a61be 100644
--- a/include/linux/zbud.h
+++ b/include/linux/zbud.h
@@ -12,7 +12,7 @@ struct zbud_ops {
 struct zbud_pool *zbud_create_pool(gfp_t gfp, struct zbud_ops *ops);
 void zbud_destroy_pool(struct zbud_pool *pool);
 int zbud_alloc(struct zbud_pool *pool, int size, gfp_t gfp,
-	unsigned long *handle);
+	unsigned long *handle, bool dis_pagealloc);
 void zbud_free(struct zbud_pool *pool, unsigned long handle);
 int zbud_reclaim_page(struct zbud_pool *pool, unsigned int retries);
 void *zbud_map(struct zbud_pool *pool, unsigned long handle);
diff --git a/mm/zbud.c b/mm/zbud.c
index 9bb4710..5ace447 100644
--- a/mm/zbud.c
+++ b/mm/zbud.c
@@ -248,7 +248,7 @@ void zbud_destroy_pool(struct zbud_pool *pool)
  * a new page.
  */
 int zbud_alloc(struct zbud_pool *pool, int size, gfp_t gfp,
-			unsigned long *handle)
+			unsigned long *handle, bool dis_pagealloc)
 {
 	int chunks, i, freechunks;
 	struct zbud_header *zhdr = NULL;
@@ -279,6 +279,8 @@ int zbud_alloc(struct zbud_pool *pool, int size, gfp_t gfp,
 
 	/* Couldn't find unbuddied zbud page, create new one */
 	spin_unlock(&pool->lock);
+	if (dis_pagealloc)
+		return -ENOSPC;
 	page = alloc_page(gfp);
 	if (!page)
 		return -ENOMEM;
diff --git a/mm/zswap.c b/mm/zswap.c
index deda2b6..7fe2b1b 100644
--- a/mm/zswap.c
+++ b/mm/zswap.c
@@ -607,10 +607,12 @@ static int zswap_frontswap_store(unsigned type, pgoff_t offset,
 	struct zswap_entry *entry, *dupentry;
 	int ret;
 	unsigned int dlen = PAGE_SIZE, len;
-	unsigned long handle;
+	unsigned long handle, stored_pages;
 	char *buf;
 	u8 *src, *dst;
 	struct zswap_header *zhdr;
+	u64 tmp;
+	bool dis_pagealloc = false;
 
 	if (!tree) {
 		ret = -ENODEV;
@@ -645,10 +647,19 @@ static int zswap_frontswap_store(unsigned type, pgoff_t offset,
 		goto freepage;
 	}
 
+	/* If the fragment of zswap pool is heavy, don't alloc new page to
+	 * zswap pool anymore. The limitation of fragment is 70% percent currently
+	 */
+	stored_pages = atomic_read(&zswap_stored_pages);
+	tmp = zswap_pool_pages * 100;
+	do_div(tmp, stored_pages + 1);
+	if (tmp > 70)
+		dis_pagealloc = true;
+
 	/* store */
 	len = dlen + sizeof(struct zswap_header);
 	ret = zbud_alloc(tree->pool, len, __GFP_NORETRY | __GFP_NOWARN,
-		&handle);
+		&handle, dis_pagealloc);
 	if (ret == -ENOSPC) {
 		zswap_reject_compress_poor++;
 		goto freepage;
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
