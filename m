Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 6BD3F6B016B
	for <linux-mm@kvack.org>; Wed,  7 Sep 2011 10:12:45 -0400 (EDT)
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by e9.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p87Da3dK018329
	for <linux-mm@kvack.org>; Wed, 7 Sep 2011 09:36:03 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p87EAWmK250266
	for <linux-mm@kvack.org>; Wed, 7 Sep 2011 10:10:32 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p87E9MMl010085
	for <linux-mm@kvack.org>; Wed, 7 Sep 2011 10:09:22 -0400
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: [PATCH v2 2/3] staging: zcache: replace xvmalloc with xcfmalloc
Date: Wed,  7 Sep 2011 09:09:06 -0500
Message-Id: <1315404547-20075-3-git-send-email-sjenning@linux.vnet.ibm.com>
In-Reply-To: <1315404547-20075-1-git-send-email-sjenning@linux.vnet.ibm.com>
References: <1315404547-20075-1-git-send-email-sjenning@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: gregkh@suse.de
Cc: dan.magenheimer@oracle.com, ngupta@vflare.org, cascardo@holoscopio.com, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, rdunlap@xenotime.net, linux-mm@kvack.org, rcj@linux.vnet.ibm.com, dave@linux.vnet.ibm.com, brking@linux.vnet.ibm.com, Seth Jennings <sjenning@linux.vnet.ibm.com>

This patch replaces xvmalloc with xcfmalloc as the persistent page
allocator for zcache.

Because the API is not the same between xvmalloc and xcfmalloc, the
changes are not a simple find/replace on the function names.

Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
---
 drivers/staging/zcache/zcache-main.c |  130 ++++++++++++++++++++++------------
 1 files changed, 84 insertions(+), 46 deletions(-)

diff --git a/drivers/staging/zcache/zcache-main.c b/drivers/staging/zcache/zcache-main.c
index a3f5162..b07377b 100644
--- a/drivers/staging/zcache/zcache-main.c
+++ b/drivers/staging/zcache/zcache-main.c
@@ -8,7 +8,7 @@
  * and, thus indirectly, for cleancache and frontswap.  Zcache includes two
  * page-accessible memory [1] interfaces, both utilizing lzo1x compression:
  * 1) "compression buddies" ("zbud") is used for ephemeral pages
- * 2) xvmalloc is used for persistent pages.
+ * 2) xcfmalloc is used for persistent pages.
  * Xvmalloc (based on the TLSF allocator) has very low fragmentation
  * so maximizes space efficiency, while zbud allows pairs (and potentially,
  * in the future, more than a pair of) compressed pages to be closely linked
@@ -31,7 +31,7 @@
 #include <linux/math64.h>
 #include "tmem.h"
 
-#include "../zram/xvmalloc.h" /* if built in drivers/staging */
+#include "xcfmalloc.h"
 
 #if (!defined(CONFIG_CLEANCACHE) && !defined(CONFIG_FRONTSWAP))
 #error "zcache is useless without CONFIG_CLEANCACHE or CONFIG_FRONTSWAP"
@@ -60,7 +60,7 @@ MODULE_LICENSE("GPL");
 
 struct zcache_client {
 	struct tmem_pool *tmem_pools[MAX_POOLS_PER_CLIENT];
-	struct xv_pool *xvpool;
+	struct xcf_pool *xcfmpool;
 	bool allocated;
 	atomic_t refcount;
 };
@@ -623,9 +623,8 @@ static int zbud_show_cumul_chunk_counts(char *buf)
 #endif
 
 /**********
- * This "zv" PAM implementation combines the TLSF-based xvMalloc
- * with lzo1x compression to maximize the amount of data that can
- * be packed into a physical page.
+ * This "zv" PAM implementation combines xcfmalloc with lzo1x compression
+ * to maximize the amount of data that can be packed into a physical page.
  *
  * Zv represents a PAM page with the index and object (plus a "size" value
  * necessary for decompression) immediately preceding the compressed data.
@@ -658,71 +657,97 @@ static unsigned int zv_max_mean_zsize = (PAGE_SIZE / 8) * 5;
 static unsigned long zv_curr_dist_counts[NCHUNKS];
 static unsigned long zv_cumul_dist_counts[NCHUNKS];
 
-static struct zv_hdr *zv_create(struct xv_pool *xvpool, uint32_t pool_id,
+static DEFINE_PER_CPU(unsigned char *, zv_cbuf); /* zv create buffer */
+static DEFINE_PER_CPU(unsigned char *, zv_dbuf); /* zv decompress buffer */
+
+static int zv_cpu_notifier(struct notifier_block *nb,
+				unsigned long action, void *pcpu)
+{
+	int cpu = (long)pcpu;
+
+	switch (action) {
+	case CPU_UP_PREPARE:
+		per_cpu(zv_cbuf, cpu) = (void *)__get_free_page(
+			GFP_KERNEL | __GFP_REPEAT);
+		per_cpu(zv_dbuf, cpu) = (void *)__get_free_page(
+			GFP_KERNEL | __GFP_REPEAT);
+		break;
+	case CPU_DEAD:
+	case CPU_UP_CANCELED:
+		free_page((unsigned long)per_cpu(zv_cbuf, cpu));
+		per_cpu(zv_cbuf, cpu) = NULL;
+		free_page((unsigned long)per_cpu(zv_dbuf, cpu));
+		per_cpu(zv_dbuf, cpu) = NULL;
+		break;
+	default:
+		break;
+	}
+
+	return NOTIFY_OK;
+}
+
+
+static void **zv_create(struct xcf_pool *xcfmpool, uint32_t pool_id,
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
+	void *handle;
 
 	BUG_ON(!irqs_disabled());
 	BUG_ON(chunks >= NCHUNKS);
-	ret = xv_malloc(xvpool, alloc_size,
-			&page, &offset, ZCACHE_GFP_MASK);
-	if (unlikely(ret))
-		goto out;
+
+	handle = xcf_malloc(xcfmpool, size, ZCACHE_GFP_MASK);
+	if (!handle)
+		return NULL;
+
 	zv_curr_dist_counts[chunks]++;
 	zv_cumul_dist_counts[chunks]++;
-	zv = kmap_atomic(page, KM_USER0) + offset;
+
+	zv = (struct zv_hdr *)((char *)cdata - sizeof(*zv));
 	zv->index = index;
 	zv->oid = *oid;
 	zv->pool_id = pool_id;
 	SET_SENTINEL(zv, ZVH);
-	memcpy((char *)zv + sizeof(struct zv_hdr), cdata, clen);
-	kunmap_atomic(zv, KM_USER0);
-out:
-	return zv;
+	xcf_write(handle, zv);
+
+	return handle;
 }
 
-static void zv_free(struct xv_pool *xvpool, struct zv_hdr *zv)
+static void zv_free(struct xcf_pool *xcfmpool, void *handle)
 {
 	unsigned long flags;
-	struct page *page;
-	uint32_t offset;
-	uint16_t size = xv_get_object_size(zv);
+	u32 size = xcf_get_alloc_size(handle);
 	int chunks = (size + (CHUNK_SIZE - 1)) >> CHUNK_SHIFT;
 
-	ASSERT_SENTINEL(zv, ZVH);
 	BUG_ON(chunks >= NCHUNKS);
 	zv_curr_dist_counts[chunks]--;
-	size -= sizeof(*zv);
-	BUG_ON(size == 0);
-	INVERT_SENTINEL(zv, ZVH);
-	page = virt_to_page(zv);
-	offset = (unsigned long)zv & ~PAGE_MASK;
+
 	local_irq_save(flags);
-	xv_free(xvpool, page, offset);
+	xcf_free(xcfmpool, handle);
 	local_irq_restore(flags);
 }
 
-static void zv_decompress(struct page *page, struct zv_hdr *zv)
+static void zv_decompress(struct page *page, void *handle)
 {
 	size_t clen = PAGE_SIZE;
 	char *to_va;
 	unsigned size;
 	int ret;
+	struct zv_hdr *zv;
 
-	ASSERT_SENTINEL(zv, ZVH);
-	size = xv_get_object_size(zv) - sizeof(*zv);
+	size = xcf_get_alloc_size(handle) - sizeof(*zv);
 	BUG_ON(size == 0);
+	zv = (struct zv_hdr *)(get_cpu_var(zv_dbuf));
+	xcf_read(handle, zv);
+	ASSERT_SENTINEL(zv, ZVH);
 	to_va = kmap_atomic(page, KM_USER0);
 	ret = lzo1x_decompress_safe((char *)zv + sizeof(*zv),
 					size, to_va, &clen);
 	kunmap_atomic(to_va, KM_USER0);
+	put_cpu_var(zv_dbuf);
 	BUG_ON(ret != LZO_E_OK);
 	BUG_ON(clen != PAGE_SIZE);
 }
@@ -949,8 +974,9 @@ int zcache_new_client(uint16_t cli_id)
 		goto out;
 	cli->allocated = 1;
 #ifdef CONFIG_FRONTSWAP
-	cli->xvpool = xv_create_pool();
-	if (cli->xvpool == NULL)
+	cli->xcfmpool =
+		xcf_create_pool(ZCACHE_GFP_MASK);
+	if (cli->xcfmpool == NULL)
 		goto out;
 #endif
 	ret = 0;
@@ -1154,7 +1180,7 @@ static void *zcache_pampd_create(char *data, size_t size, bool raw, int eph,
 				struct tmem_pool *pool, struct tmem_oid *oid,
 				 uint32_t index)
 {
-	void *pampd = NULL, *cdata;
+	void *pampd = NULL, *cdata = NULL;
 	size_t clen;
 	int ret;
 	unsigned long count;
@@ -1186,26 +1212,30 @@ static void *zcache_pampd_create(char *data, size_t size, bool raw, int eph,
 		if (curr_pers_pampd_count >
 		    (zv_page_count_policy_percent * totalram_pages) / 100)
 			goto out;
+		cdata = get_cpu_var(zv_cbuf) + sizeof(struct zv_hdr);
 		ret = zcache_compress(page, &cdata, &clen);
 		if (ret == 0)
 			goto out;
 		/* reject if compression is too poor */
 		if (clen > zv_max_zsize) {
 			zcache_compress_poor++;
+			put_cpu_var(zv_cbuf);
 			goto out;
 		}
 		/* reject if mean compression is too poor */
 		if ((clen > zv_max_mean_zsize) && (curr_pers_pampd_count > 0)) {
-			total_zsize = xv_get_total_size_bytes(cli->xvpool);
+			total_zsize = xcf_get_total_size_bytes(cli->xcfmpool);
 			zv_mean_zsize = div_u64(total_zsize,
 						curr_pers_pampd_count);
 			if (zv_mean_zsize > zv_max_mean_zsize) {
 				zcache_mean_compress_poor++;
+				put_cpu_var(zv_cbuf);
 				goto out;
 			}
 		}
-		pampd = (void *)zv_create(cli->xvpool, pool->pool_id,
+		pampd = (void *)zv_create(cli->xcfmpool, pool->pool_id,
 						oid, index, cdata, clen);
+		put_cpu_var(zv_cbuf);
 		if (pampd == NULL)
 			goto out;
 		count = atomic_inc_return(&zcache_curr_pers_pampd_count);
@@ -1262,7 +1292,7 @@ static void zcache_pampd_free(void *pampd, struct tmem_pool *pool,
 		atomic_dec(&zcache_curr_eph_pampd_count);
 		BUG_ON(atomic_read(&zcache_curr_eph_pampd_count) < 0);
 	} else {
-		zv_free(cli->xvpool, (struct zv_hdr *)pampd);
+		zv_free(cli->xcfmpool, pampd);
 		atomic_dec(&zcache_curr_pers_pampd_count);
 		BUG_ON(atomic_read(&zcache_curr_pers_pampd_count) < 0);
 	}
@@ -1309,11 +1339,16 @@ static DEFINE_PER_CPU(unsigned char *, zcache_dstmem);
 static int zcache_compress(struct page *from, void **out_va, size_t *out_len)
 {
 	int ret = 0;
-	unsigned char *dmem = __get_cpu_var(zcache_dstmem);
+	unsigned char *dmem;
 	unsigned char *wmem = __get_cpu_var(zcache_workmem);
 	char *from_va;
 
 	BUG_ON(!irqs_disabled());
+	if (out_va && *out_va)
+		dmem = *out_va;
+	else
+		dmem = __get_cpu_var(zcache_dstmem);
+
 	if (unlikely(dmem == NULL || wmem == NULL))
 		goto out;  /* no buffer, so can't compress */
 	from_va = kmap_atomic(from, KM_USER0);
@@ -1331,7 +1366,7 @@ out:
 static int zcache_cpu_notifier(struct notifier_block *nb,
 				unsigned long action, void *pcpu)
 {
-	int cpu = (long)pcpu;
+	int ret, cpu = (long)pcpu;
 	struct zcache_preload *kp;
 
 	switch (action) {
@@ -1363,7 +1398,10 @@ static int zcache_cpu_notifier(struct notifier_block *nb,
 	default:
 		break;
 	}
-	return NOTIFY_OK;
+
+	ret = zv_cpu_notifier(nb, action, pcpu);
+
+	return ret;
 }
 
 static struct notifier_block zcache_cpu_notifier_block = {
@@ -1991,7 +2029,7 @@ static int __init zcache_init(void)
 
 		old_ops = zcache_frontswap_register_ops();
 		pr_info("zcache: frontswap enabled using kernel "
-			"transcendent memory and xvmalloc\n");
+			"transcendent memory and xcfmalloc\n");
 		if (old_ops.init != NULL)
 			pr_warning("ktmem: frontswap_ops overridden");
 	}
-- 
1.7.4.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
