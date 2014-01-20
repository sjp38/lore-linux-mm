Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f48.google.com (mail-pb0-f48.google.com [209.85.160.48])
	by kanga.kvack.org (Postfix) with ESMTP id 89C056B0035
	for <linux-mm@kvack.org>; Mon, 20 Jan 2014 02:51:24 -0500 (EST)
Received: by mail-pb0-f48.google.com with SMTP id rr13so6637764pbb.7
        for <linux-mm@kvack.org>; Sun, 19 Jan 2014 23:51:24 -0800 (PST)
Received: from mailout4.samsung.com (mailout4.samsung.com. [203.254.224.34])
        by mx.google.com with ESMTPS id ad3si325921pad.90.2014.01.19.23.51.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Sun, 19 Jan 2014 23:51:23 -0800 (PST)
Received: from epcpsbgm2.samsung.com (epcpsbgm2 [203.254.230.27])
 by mailout4.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0MZO00826WHK0Q80@mailout4.samsung.com> for
 linux-mm@kvack.org; Mon, 20 Jan 2014 16:51:20 +0900 (KST)
From: Cai Liu <cai.liu@samsung.com>
Subject: [PATCH v2]  mm/zswap: Check all pool pages instead of one pool pages
Date: Mon, 20 Jan 2014 15:50:18 +0800
Message-id: <000701cf15b4$6822c740$386855c0$@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii
Content-transfer-encoding: 7bit
Content-language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Minchan Kim' <minchan@kernel.org>, 'Andrew Morton' <akpm@linux-foundation.org>, 'Seth Jennings' <sjenning@linux.vnet.ibm.com>, 'Bob Liu' <bob.liu@oracle.com>
Cc: 'Linux-MM' <linux-mm@kvack.org>, 'Linux-Kernel' <linux-kernel@vger.kernel.org>, liucai.lfn@gmail.com, cai.liu@samsung.com

zswap can support multiple swapfiles. So we need to check
all zbud pool pages in zswap.

Version 2:
  * add *total_zbud_pages* in zbud to record all the pages in pools
  * move the updating of pool pages statistics to
    alloc_zbud_page/free_zbud_page to hide the details

Signed-off-by: Cai Liu <cai.liu@samsung.com>
---
 include/linux/zbud.h |    2 +-
 mm/zbud.c            |   44 ++++++++++++++++++++++++++++++++------------
 mm/zswap.c           |    4 ++--
 3 files changed, 35 insertions(+), 15 deletions(-)

diff --git a/include/linux/zbud.h b/include/linux/zbud.h
index 2571a5c..1dbc13e 100644
--- a/include/linux/zbud.h
+++ b/include/linux/zbud.h
@@ -17,6 +17,6 @@ void zbud_free(struct zbud_pool *pool, unsigned long handle);
 int zbud_reclaim_page(struct zbud_pool *pool, unsigned int retries);
 void *zbud_map(struct zbud_pool *pool, unsigned long handle);
 void zbud_unmap(struct zbud_pool *pool, unsigned long handle);
-u64 zbud_get_pool_size(struct zbud_pool *pool);
+u64 zbud_get_pool_size(void);
 
 #endif /* _ZBUD_H_ */
diff --git a/mm/zbud.c b/mm/zbud.c
index 9451361..711aaf4 100644
--- a/mm/zbud.c
+++ b/mm/zbud.c
@@ -52,6 +52,13 @@
 #include <linux/spinlock.h>
 #include <linux/zbud.h>
 
+/*********************************
+* statistics
+**********************************/
+
+/* zbud pages in all pools */
+static u64 total_zbud_pages;
+
 /*****************
  * Structures
 *****************/
@@ -142,10 +149,28 @@ static struct zbud_header *init_zbud_page(struct page *page)
 	return zhdr;
 }
 
+static struct page *alloc_zbud_page(struct zbud_pool *pool, gfp_t gfp)
+{
+	struct page *page;
+
+	page = alloc_page(gfp);
+
+	if (page) {
+		pool->pages_nr++;
+		total_zbud_pages++;
+	}
+
+	return page;
+}
+
+
 /* Resets the struct page fields and frees the page */
-static void free_zbud_page(struct zbud_header *zhdr)
+static void free_zbud_page(struct zbud_pool *pool, struct zbud_header *zhdr)
 {
 	__free_page(virt_to_page(zhdr));
+
+	pool->pages_nr--;
+	total_zbud_pages--;
 }
 
 /*
@@ -279,11 +304,10 @@ int zbud_alloc(struct zbud_pool *pool, int size, gfp_t gfp,
 
 	/* Couldn't find unbuddied zbud page, create new one */
 	spin_unlock(&pool->lock);
-	page = alloc_page(gfp);
+	page = alloc_zbud_page(pool, gfp);
 	if (!page)
 		return -ENOMEM;
 	spin_lock(&pool->lock);
-	pool->pages_nr++;
 	zhdr = init_zbud_page(page);
 	bud = FIRST;
 
@@ -349,8 +373,7 @@ void zbud_free(struct zbud_pool *pool, unsigned long handle)
 	if (zhdr->first_chunks == 0 && zhdr->last_chunks == 0) {
 		/* zbud page is empty, free */
 		list_del(&zhdr->lru);
-		free_zbud_page(zhdr);
-		pool->pages_nr--;
+		free_zbud_page(pool, zhdr);
 	} else {
 		/* Add to unbuddied list */
 		freechunks = num_free_chunks(zhdr);
@@ -447,8 +470,7 @@ next:
 			 * Both buddies are now free, free the zbud page and
 			 * return success.
 			 */
-			free_zbud_page(zhdr);
-			pool->pages_nr--;
+			free_zbud_page(pool, zhdr);
 			spin_unlock(&pool->lock);
 			return 0;
 		} else if (zhdr->first_chunks == 0 ||
@@ -496,14 +518,12 @@ void zbud_unmap(struct zbud_pool *pool, unsigned long handle)
 
 /**
  * zbud_get_pool_size() - gets the zbud pool size in pages
- * @pool:	pool whose size is being queried
  *
- * Returns: size in pages of the given pool.  The pool lock need not be
- * taken to access pages_nr.
+ * Returns: size in pages of all the zbud pools.
  */
-u64 zbud_get_pool_size(struct zbud_pool *pool)
+u64 zbud_get_pool_size(void)
 {
-	return pool->pages_nr;
+	return total_zbud_pages;
 }
 
 static int __init init_zbud(void)
diff --git a/mm/zswap.c b/mm/zswap.c
index 5a63f78..ef44d9d 100644
--- a/mm/zswap.c
+++ b/mm/zswap.c
@@ -291,7 +291,7 @@ static void zswap_free_entry(struct zswap_tree *tree,
 	zbud_free(tree->pool, entry->handle);
 	zswap_entry_cache_free(entry);
 	atomic_dec(&zswap_stored_pages);
-	zswap_pool_pages = zbud_get_pool_size(tree->pool);
+	zswap_pool_pages = zbud_get_pool_size();
 }
 
 /* caller must hold the tree lock */
@@ -716,7 +716,7 @@ static int zswap_frontswap_store(unsigned type, pgoff_t offset,
 
 	/* update stats */
 	atomic_inc(&zswap_stored_pages);
-	zswap_pool_pages = zbud_get_pool_size(tree->pool);
+	zswap_pool_pages = zbud_get_pool_size();
 
 	return 0;
 
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
