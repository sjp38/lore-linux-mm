Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx101.postini.com [74.125.245.101])
	by kanga.kvack.org (Postfix) with SMTP id 6CCD56B0073
	for <linux-mm@kvack.org>; Mon,  9 Jan 2012 17:53:39 -0500 (EST)
Received: from /spool/local
	by e6.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Mon, 9 Jan 2012 17:53:38 -0500
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q09MqTMa177148
	for <linux-mm@kvack.org>; Mon, 9 Jan 2012 17:52:34 -0500
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q09MqRF8005915
	for <linux-mm@kvack.org>; Mon, 9 Jan 2012 17:52:28 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: [PATCH 3/5] staging: zcache: replace xvmalloc with zsmalloc
Date: Mon,  9 Jan 2012 16:51:58 -0600
Message-Id: <1326149520-31720-4-git-send-email-sjenning@linux.vnet.ibm.com>
In-Reply-To: <1326149520-31720-1-git-send-email-sjenning@linux.vnet.ibm.com>
References: <1326149520-31720-1-git-send-email-sjenning@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@suse.de>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Brian King <brking@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>, Konrad Wilk <konrad.wilk@oracle.com>, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

Replaces xvmalloc with zsmalloc as the persistent memory allocator
for zcache

Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
---
 drivers/staging/zcache/Kconfig       |    2 +-
 drivers/staging/zcache/zcache-main.c |   83 +++++++++++++++++----------------
 2 files changed, 44 insertions(+), 41 deletions(-)

diff --git a/drivers/staging/zcache/Kconfig b/drivers/staging/zcache/Kconfig
index 1b7bba7..94e48aa 100644
--- a/drivers/staging/zcache/Kconfig
+++ b/drivers/staging/zcache/Kconfig
@@ -1,7 +1,7 @@
 config ZCACHE
 	tristate "Dynamic compression of swap pages and clean pagecache pages"
 	depends on (CLEANCACHE || FRONTSWAP) && CRYPTO
-	select XVMALLOC
+	select ZSMALLOC
 	select CRYPTO_LZO
 	default n
 	help
diff --git a/drivers/staging/zcache/zcache-main.c b/drivers/staging/zcache/zcache-main.c
index 2faa9a7..bcc8440 100644
--- a/drivers/staging/zcache/zcache-main.c
+++ b/drivers/staging/zcache/zcache-main.c
@@ -9,7 +9,7 @@
  * page-accessible memory [1] interfaces, both utilizing the crypto compression
  * API:
  * 1) "compression buddies" ("zbud") is used for ephemeral pages
- * 2) xvmalloc is used for persistent pages.
+ * 2) zsmalloc is used for persistent pages.
  * Xvmalloc (based on the TLSF allocator) has very low fragmentation
  * so maximizes space efficiency, while zbud allows pairs (and potentially,
  * in the future, more than a pair of) compressed pages to be closely linked
@@ -33,7 +33,7 @@
 #include <linux/string.h>
 #include "tmem.h"
 
-#include "../zram/xvmalloc.h" /* if built in drivers/staging */
+#include "../zsmalloc/zsmalloc.h"
 
 #if (!defined(CONFIG_CLEANCACHE) && !defined(CONFIG_FRONTSWAP))
 #error "zcache is useless without CONFIG_CLEANCACHE or CONFIG_FRONTSWAP"
@@ -62,7 +62,7 @@ MODULE_LICENSE("GPL");
 
 struct zcache_client {
 	struct tmem_pool *tmem_pools[MAX_POOLS_PER_CLIENT];
-	struct xv_pool *xvpool;
+	struct zs_pool *zspool;
 	bool allocated;
 	atomic_t refcount;
 };
@@ -658,7 +658,7 @@ static int zbud_show_cumul_chunk_counts(char *buf)
 #endif
 
 /**********
- * This "zv" PAM implementation combines the TLSF-based xvMalloc
+ * This "zv" PAM implementation combines the slab-based zsmalloc
  * with the crypto compression API to maximize the amount of data that can
  * be packed into a physical page.
  *
@@ -672,6 +672,7 @@ struct zv_hdr {
 	uint32_t pool_id;
 	struct tmem_oid oid;
 	uint32_t index;
+	size_t size;
 	DECL_SENTINEL
 };
 
@@ -693,71 +694,73 @@ static unsigned int zv_max_mean_zsize = (PAGE_SIZE / 8) * 5;
 static atomic_t zv_curr_dist_counts[NCHUNKS];
 static atomic_t zv_cumul_dist_counts[NCHUNKS];
 
-static struct zv_hdr *zv_create(struct xv_pool *xvpool, uint32_t pool_id,
+static struct zv_hdr *zv_create(struct zs_pool *pool, uint32_t pool_id,
 				struct tmem_oid *oid, uint32_t index,
 				void *cdata, unsigned clen)
 {
-	struct page *page;
-	struct zv_hdr *zv = NULL;
-	uint32_t offset;
-	int alloc_size = clen + sizeof(struct zv_hdr);
-	int chunks = (alloc_size + (CHUNK_SIZE - 1)) >> CHUNK_SHIFT;
-	int ret;
+	struct zv_hdr *zv;
+	u32 size = clen + sizeof(struct zv_hdr);
+	int chunks = (size + (CHUNK_SIZE - 1)) >> CHUNK_SHIFT;
+	void *handle = NULL;
+	char *buf;
 
 	BUG_ON(!irqs_disabled());
 	BUG_ON(chunks >= NCHUNKS);
-	ret = xv_malloc(xvpool, alloc_size,
-			&page, &offset, ZCACHE_GFP_MASK);
-	if (unlikely(ret))
+	handle = zs_malloc(pool, size);
+	if (!handle)
 		goto out;
 	atomic_inc(&zv_curr_dist_counts[chunks]);
 	atomic_inc(&zv_cumul_dist_counts[chunks]);
-	zv = kmap_atomic(page, KM_USER0) + offset;
+	zv = (struct zv_hdr *)((char *)cdata - sizeof(*zv));
 	zv->index = index;
 	zv->oid = *oid;
 	zv->pool_id = pool_id;
+	zv->size = clen;
 	SET_SENTINEL(zv, ZVH);
-	memcpy((char *)zv + sizeof(struct zv_hdr), cdata, clen);
-	kunmap_atomic(zv, KM_USER0);
+	buf = zs_map_object(pool, handle);
+	memcpy(buf, zv, clen + sizeof(*zv));
+	zs_unmap_object(pool, handle);
 out:
-	return zv;
+	return handle;
 }
 
-static void zv_free(struct xv_pool *xvpool, struct zv_hdr *zv)
+static void zv_free(struct zs_pool *pool, void *handle)
 {
 	unsigned long flags;
-	struct page *page;
-	uint32_t offset;
-	uint16_t size = xv_get_object_size(zv);
-	int chunks = (size + (CHUNK_SIZE - 1)) >> CHUNK_SHIFT;
+	struct zv_hdr *zv;
+	uint16_t size;
+	int chunks;
 
+	zv = zs_map_object(pool, handle);
 	ASSERT_SENTINEL(zv, ZVH);
+	size = zv->size + sizeof(struct zv_hdr);
+	INVERT_SENTINEL(zv, ZVH);
+	zs_unmap_object(pool, handle);
+
+	chunks = (size + (CHUNK_SIZE - 1)) >> CHUNK_SHIFT;
 	BUG_ON(chunks >= NCHUNKS);
 	atomic_dec(&zv_curr_dist_counts[chunks]);
-	size -= sizeof(*zv);
-	BUG_ON(size == 0);
-	INVERT_SENTINEL(zv, ZVH);
-	page = virt_to_page(zv);
-	offset = (unsigned long)zv & ~PAGE_MASK;
+
 	local_irq_save(flags);
-	xv_free(xvpool, page, offset);
+	zs_free(pool, handle);
 	local_irq_restore(flags);
 }
 
-static void zv_decompress(struct page *page, struct zv_hdr *zv)
+static void zv_decompress(struct page *page, void *handle)
 {
 	unsigned int clen = PAGE_SIZE;
 	char *to_va;
-	unsigned size;
 	int ret;
+	struct zv_hdr *zv;
 
+	zv = zs_map_object(zcache_host.zspool, handle);
+	BUG_ON(zv->size == 0);
 	ASSERT_SENTINEL(zv, ZVH);
-	size = xv_get_object_size(zv) - sizeof(*zv);
-	BUG_ON(size == 0);
 	to_va = kmap_atomic(page, KM_USER0);
 	ret = zcache_comp_op(ZCACHE_COMPOP_DECOMPRESS, (char *)zv + sizeof(*zv),
-				size, to_va, &clen);
+				zv->size, to_va, &clen);
 	kunmap_atomic(to_va, KM_USER0);
+	zs_unmap_object(zcache_host.zspool, handle);
 	BUG_ON(ret);
 	BUG_ON(clen != PAGE_SIZE);
 }
@@ -984,8 +987,8 @@ int zcache_new_client(uint16_t cli_id)
 		goto out;
 	cli->allocated = 1;
 #ifdef CONFIG_FRONTSWAP
-	cli->xvpool = xv_create_pool();
-	if (cli->xvpool == NULL)
+	cli->zspool = zs_create_pool("zcache", ZCACHE_GFP_MASK);
+	if (cli->zspool == NULL)
 		goto out;
 #endif
 	ret = 0;
@@ -1216,7 +1219,7 @@ static void *zcache_pampd_create(char *data, size_t size, bool raw, int eph,
 		}
 		/* reject if mean compression is too poor */
 		if ((clen > zv_max_mean_zsize) && (curr_pers_pampd_count > 0)) {
-			total_zsize = xv_get_total_size_bytes(cli->xvpool);
+			total_zsize = zs_get_total_size_bytes(cli->zspool);
 			zv_mean_zsize = div_u64(total_zsize,
 						curr_pers_pampd_count);
 			if (zv_mean_zsize > zv_max_mean_zsize) {
@@ -1224,7 +1227,7 @@ static void *zcache_pampd_create(char *data, size_t size, bool raw, int eph,
 				goto out;
 			}
 		}
-		pampd = (void *)zv_create(cli->xvpool, pool->pool_id,
+		pampd = (void *)zv_create(cli->zspool, pool->pool_id,
 						oid, index, cdata, clen);
 		if (pampd == NULL)
 			goto out;
@@ -1282,7 +1285,7 @@ static void zcache_pampd_free(void *pampd, struct tmem_pool *pool,
 		atomic_dec(&zcache_curr_eph_pampd_count);
 		BUG_ON(atomic_read(&zcache_curr_eph_pampd_count) < 0);
 	} else {
-		zv_free(cli->xvpool, (struct zv_hdr *)pampd);
+		zv_free(cli->zspool, pampd);
 		atomic_dec(&zcache_curr_pers_pampd_count);
 		BUG_ON(atomic_read(&zcache_curr_pers_pampd_count) < 0);
 	}
@@ -2072,7 +2075,7 @@ static int __init zcache_init(void)
 
 		old_ops = zcache_frontswap_register_ops();
 		pr_info("zcache: frontswap enabled using kernel "
-			"transcendent memory and xvmalloc\n");
+			"transcendent memory and zsmalloc\n");
 		if (old_ops.init != NULL)
 			pr_warning("zcache: frontswap_ops overridden");
 	}
-- 
1.7.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
