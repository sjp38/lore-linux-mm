Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id 841696B0009
	for <linux-mm@kvack.org>; Wed, 23 Jan 2013 16:46:48 -0500 (EST)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: [PATCH 2/2] staging: zcache: optional support for zsmalloc as alternate allocator
Date: Wed, 23 Jan 2013 13:46:31 -0800
Message-Id: <1358977591-24485-2-git-send-email-dan.magenheimer@oracle.com>
In-Reply-To: <1358977591-24485-1-git-send-email-dan.magenheimer@oracle.com>
References: <1358977591-24485-1-git-send-email-dan.magenheimer@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: devel@linuxdriverproject.org, linux-kernel@vger.kernel.org, gregkh@linuxfoundation.org, linux-mm@kvack.org, ngupta@vflare.org, konrad.wilk@oracle.com, sjenning@linux.vnet.ibm.com, minchan@kernel.org, dan.magenheimer@oracle.com

"New" zcache uses zbud for all sub-page allocation which is more flexible but
results in lower density.  "Old" zcache supported zsmalloc for frontswap
pages.  Add zsmalloc to "new" zcache as a compile-time and run-time option
for backwards compatibility in case any users wants to use zcache with
highest possible density.

Note that most of the zsmalloc stats in old zcache are not included here
because old zcache used sysfs and new zcache has converted to debugfs.
These stats may be added later.

Note also that ramster is incompatible with zsmalloc as the two use
the least significant bits in a pampd differently.

Signed-off-by: Dan Magenheimer <dan.magenheimer@oracle.com>
---
 drivers/staging/zcache/Kconfig       |   11 ++
 drivers/staging/zcache/zcache-main.c |  210 ++++++++++++++++++++++++++++++++--
 drivers/staging/zcache/zcache.h      |    3 +
 3 files changed, 215 insertions(+), 9 deletions(-)

diff --git a/drivers/staging/zcache/Kconfig b/drivers/staging/zcache/Kconfig
index c1dbd04..116f8d5 100644
--- a/drivers/staging/zcache/Kconfig
+++ b/drivers/staging/zcache/Kconfig
@@ -10,6 +10,17 @@ config ZCACHE
 	  memory to store clean page cache pages and swap in RAM,
 	  providing a noticeable reduction in disk I/O.
 
+config ZCACHE_ZSMALLOC
+	bool "Allow use of zsmalloc allocator for compression of swap pages"
+	depends on ZSMALLOC=y && !RAMSTER
+	default n
+	help
+	  Zsmalloc is a much more efficient allocator for compresssed
+	  pages but currently has some design deficiencies in that it
+	  does not support reclaim nor compaction.  Select this if
+	  you are certain your workload will fit or has mostly short
+	  running processes.  Zsmalloc is incompatible with RAMster.
+
 config RAMSTER
 	bool "Cross-machine RAM capacity sharing, aka peer-to-peer tmem"
 	depends on CONFIGFS_FS=y && SYSFS=y && !HIGHMEM && ZCACHE=y
diff --git a/drivers/staging/zcache/zcache-main.c b/drivers/staging/zcache/zcache-main.c
index 6ab13e1..0212bae 100644
--- a/drivers/staging/zcache/zcache-main.c
+++ b/drivers/staging/zcache/zcache-main.c
@@ -26,6 +26,12 @@
 #include <linux/cleancache.h>
 #include <linux/frontswap.h>
 #include "tmem.h"
+#ifdef CONFIG_ZCACHE_ZSMALLOC
+#include "../zsmalloc/zsmalloc.h"
+static int zsmalloc_enabled;
+#else
+#define zsmalloc_enabled 0
+#endif
 #include "zcache.h"
 #include "zbud.h"
 #include "ramster.h"
@@ -182,6 +188,35 @@ static unsigned long zcache_last_inactive_anon_pageframes;
 static unsigned long zcache_eph_nonactive_puts_ignored;
 static unsigned long zcache_pers_nonactive_puts_ignored;
 
+#ifdef CONFIG_ZCACHE_ZSMALLOC
+#define ZS_CHUNK_SHIFT	6
+#define ZS_CHUNK_SIZE	(1 << ZS_CHUNK_SHIFT)
+#define ZS_CHUNK_MASK	(~(ZS_CHUNK_SIZE-1))
+#define ZS_NCHUNKS	(((PAGE_SIZE - sizeof(struct tmem_handle)) & \
+				ZS_CHUNK_MASK) >> ZS_CHUNK_SHIFT)
+#define ZS_MAX_CHUNK	(ZS_NCHUNKS-1)
+
+/* total number of persistent pages may not exceed this percentage */
+static unsigned int zv_page_count_policy_percent = 75;
+/*
+ * byte count defining poor compression; pages with greater zsize will be
+ * rejected
+ */
+static unsigned int zv_max_zsize = (PAGE_SIZE / 8) * 7;
+/*
+ * byte count defining poor *mean* compression; pages with greater zsize
+ * will be rejected until sufficient better-compressed pages are accepted
+ * driving the mean below this threshold
+ */
+static unsigned int zv_max_mean_zsize = (PAGE_SIZE / 8) * 5;
+
+static atomic_t zv_curr_dist_counts[ZS_NCHUNKS];
+static atomic_t zv_cumul_dist_counts[ZS_NCHUNKS];
+static atomic_t zcache_curr_pers_pampd_count = ATOMIC_INIT(0);
+static unsigned long zcache_curr_pers_pampd_count_max;
+
+#endif
+
 #ifdef CONFIG_DEBUG_FS
 #include <linux/debugfs.h>
 #define	zdfs	debugfs_create_size_t
@@ -370,6 +405,13 @@ int zcache_new_client(uint16_t cli_id)
 	if (cli->allocated)
 		goto out;
 	cli->allocated = 1;
+#ifdef CONFIG_ZCACHE_ZSMALLOC
+	if (zsmalloc_enabled) {
+		cli->zspool = zs_create_pool("zcache", ZCACHE_GFP_MASK);
+		if (cli->zspool == NULL)
+			goto out;
+	}
+#endif
 	ret = 0;
 out:
 	return ret;
@@ -632,6 +674,105 @@ out:
 	return pampd;
 }
 
+#ifdef CONFIG_ZCACHE_ZSMALLOC
+struct zv_hdr {
+	uint32_t pool_id;
+	struct tmem_oid oid;
+	uint32_t index;
+	size_t size;
+};
+
+static unsigned long zv_create(struct zcache_client *cli, uint32_t pool_id,
+				struct tmem_oid *oid, uint32_t index,
+				struct page *page)
+{
+	struct zv_hdr *zv;
+	int chunks;
+	unsigned long curr_pers_pampd_count, total_zsize, zv_mean_zsize;
+	unsigned long handle = 0;
+	void *cdata;
+	unsigned clen;
+
+	curr_pers_pampd_count = atomic_read(&zcache_curr_pers_pampd_count);
+	if (curr_pers_pampd_count >
+	    (zv_page_count_policy_percent * totalram_pages) / 100)
+		goto out;
+	zcache_compress(page, &cdata, &clen);
+	/* reject if compression is too poor */
+	if (clen > zv_max_zsize) {
+		zcache_compress_poor++;
+		goto out;
+	}
+	/* reject if mean compression is too poor */
+	if ((clen > zv_max_mean_zsize) && (curr_pers_pampd_count > 0)) {
+		total_zsize = zs_get_total_size_bytes(cli->zspool);
+		zv_mean_zsize = div_u64(total_zsize, curr_pers_pampd_count);
+		if (zv_mean_zsize > zv_max_mean_zsize) {
+			zcache_mean_compress_poor++;
+			goto out;
+		}
+	}
+	handle = zs_malloc(cli->zspool, clen + sizeof(struct zv_hdr));
+	if (!handle)
+		goto out;
+	zv = zs_map_object(cli->zspool, handle, ZS_MM_WO);
+	zv->index = index;
+	zv->oid = *oid;
+	zv->pool_id = pool_id;
+	zv->size = clen;
+	memcpy((char *)zv + sizeof(struct zv_hdr), cdata, clen);
+	zs_unmap_object(cli->zspool, handle);
+	chunks = (clen + (ZS_CHUNK_SIZE - 1)) >> ZS_CHUNK_SHIFT;
+	atomic_inc(&zv_curr_dist_counts[chunks]);
+	atomic_inc(&zv_cumul_dist_counts[chunks]);
+	curr_pers_pampd_count =
+		atomic_inc_return(&zcache_curr_pers_pampd_count);
+	if (curr_pers_pampd_count > zcache_curr_pers_pampd_count_max)
+		zcache_curr_pers_pampd_count_max = curr_pers_pampd_count;
+out:
+	return handle;
+}
+
+static void zv_free(struct zs_pool *pool, unsigned long handle)
+{
+	unsigned long flags;
+	struct zv_hdr *zv;
+	uint16_t size;
+	int chunks;
+
+	zv = zs_map_object(pool, handle, ZS_MM_RW);
+	size = zv->size + sizeof(struct zv_hdr);
+	zs_unmap_object(pool, handle);
+
+	chunks = (size + (ZS_CHUNK_SIZE - 1)) >> ZS_CHUNK_SHIFT;
+	BUG_ON(chunks >= ZS_NCHUNKS);
+	atomic_dec(&zv_curr_dist_counts[chunks]);
+
+	local_irq_save(flags);
+	zs_free(pool, handle);
+	local_irq_restore(flags);
+}
+
+static void zv_decompress(struct page *page, unsigned long handle)
+{
+	unsigned int clen = PAGE_SIZE;
+	char *to_va;
+	int ret;
+	struct zv_hdr *zv;
+
+	zv = zs_map_object(zcache_host.zspool, handle, ZS_MM_RO);
+	BUG_ON(zv->size == 0);
+	to_va = kmap_atomic(page);
+	ret = zcache_comp_op(ZCACHE_COMPOP_DECOMPRESS, (char *)zv + sizeof(*zv),
+				zv->size, to_va, &clen);
+	kunmap_atomic(to_va);
+	zs_unmap_object(zcache_host.zspool, handle);
+	BUG_ON(ret);
+	BUG_ON(clen != PAGE_SIZE);
+}
+#endif
+
+
 /*
  * This is called directly from zcache_put_page to pre-allocate space
  * to store a zpage.
@@ -677,6 +818,16 @@ void *zcache_pampd_create(char *data, unsigned int size, bool raw,
 	 */
 	if (eph)
 		pampd = zcache_pampd_eph_create(data, size, raw, th);
+#ifdef CONFIG_ZCACHE_ZSMALLOC
+	else if (zsmalloc_enabled) {
+		struct zcache_client *cli =
+				zcache_get_client_by_id(th->client_id);
+		struct page *page = (struct page *)(data);
+		BUG_ON(size != PAGE_SIZE);
+		pampd = (void *)zv_create(cli, th->pool_id, &th->oid,
+						th->index, page);
+	}
+#endif
 	else
 		pampd = zcache_pampd_pers_create(data, size, raw, th);
 out:
@@ -689,7 +840,8 @@ out:
  */
 void zcache_pampd_create_finish(void *pampd, bool eph)
 {
-	zbud_create_finish((struct zbudref *)pampd, eph);
+	if (eph || !zsmalloc_enabled)
+		zbud_create_finish((struct zbudref *)pampd, eph);
 }
 
 /*
@@ -728,7 +880,7 @@ static int zcache_pampd_get_data(char *data, size_t *sizep, bool raw,
 					void *pampd, struct tmem_pool *pool,
 					struct tmem_oid *oid, uint32_t index)
 {
-	int ret;
+	int ret = 0;
 	bool eph = !is_persistent(pool);
 
 	BUG_ON(preemptible());
@@ -738,7 +890,13 @@ static int zcache_pampd_get_data(char *data, size_t *sizep, bool raw,
 		ret = zbud_copy_from_zbud(data, (struct zbudref *)pampd,
 						sizep, eph);
 	else {
-		ret = zbud_decompress((struct page *)(data),
+#ifdef CONFIG_ZCACHE_ZSMALLOC
+		if (zsmalloc_enabled && is_persistent(pool))
+			zv_decompress((struct page *)(data),
+					(unsigned long)pampd);
+		else
+#endif
+			ret = zbud_decompress((struct page *)(data),
 					(struct zbudref *)pampd, false,
 					zcache_decompress);
 		*sizep = PAGE_SIZE;
@@ -754,10 +912,10 @@ static int zcache_pampd_get_data_and_free(char *data, size_t *sizep, bool raw,
 					void *pampd, struct tmem_pool *pool,
 					struct tmem_oid *oid, uint32_t index)
 {
-	int ret;
+	int ret = 0;
 	bool eph = !is_persistent(pool);
 	struct page *page = NULL;
-	unsigned int zsize, zpages;
+	unsigned int zsize = 0, zpages = 0;
 
 	BUG_ON(preemptible());
 	BUG_ON(pampd_is_remote(pampd));
@@ -765,13 +923,23 @@ static int zcache_pampd_get_data_and_free(char *data, size_t *sizep, bool raw,
 		ret = zbud_copy_from_zbud(data, (struct zbudref *)pampd,
 						sizep, eph);
 	else {
-		ret = zbud_decompress((struct page *)(data),
+#ifdef CONFIG_ZCACHE_ZSMALLOC
+		if (zsmalloc_enabled && is_persistent(pool)) {
+			struct zcache_client *cli = pool->client;
+			zv_decompress((struct page *)(data),
+					(unsigned long)pampd);
+			zv_free(cli->zspool, (unsigned long)pampd);
+		} else
+#endif
+		{
+			ret = zbud_decompress((struct page *)(data),
 					(struct zbudref *)pampd, eph,
 					zcache_decompress);
+			page = zbud_free_and_delist((struct zbudref *)pampd,
+					eph, &zsize, &zpages);
+		}
 		*sizep = PAGE_SIZE;
 	}
-	page = zbud_free_and_delist((struct zbudref *)pampd, eph,
-					&zsize, &zpages);
 	if (eph) {
 		if (page)
 			zcache_eph_pageframes =
@@ -824,6 +992,13 @@ static void zcache_pampd_free(void *pampd, struct tmem_pool *pool,
 		zcache_eph_zbytes =
 		    atomic_long_sub_return(zsize, &zcache_eph_zbytes_atomic);
 		/* FIXME CONFIG_RAMSTER... check acct parameter? */
+#ifdef CONFIG_ZCACHE_ZSMALLOC
+	} else if (zsmalloc_enabled) {
+		struct zcache_client *cli = pool->client;
+		zv_free(cli->zspool, (unsigned long)pampd);
+		atomic_dec(&zcache_curr_pers_pampd_count);
+		BUG_ON(atomic_read(&zcache_curr_pers_pampd_count) < 0);
+#endif
 	} else {
 		page = zbud_free_and_delist((struct zbudref *)pampd,
 						false, &zsize, &zpages);
@@ -837,7 +1012,7 @@ static void zcache_pampd_free(void *pampd, struct tmem_pool *pool,
 	}
 	if (!is_local_client(pool->client))
 		ramster_count_foreign_pages(is_ephemeral(pool), -1);
-	if (page)
+	if (page && !zsmalloc_enabled)
 		zcache_free_page(page);
 }
 
@@ -1657,6 +1832,17 @@ static int __init enable_ramster(char *s)
 }
 __setup("ramster", enable_ramster);
 
+#ifdef CONFIG_ZCACHE_ZSMALLOC
+static int __init enable_zsmalloc(char *s)
+{
+	zcache_enabled = 1;
+	zsmalloc_enabled = 1;
+	return 1;
+}
+__setup("zcache-zsmalloc", enable_zsmalloc);
+
+#endif
+
 /* allow independent dynamic disabling of cleancache and frontswap */
 
 static int __init no_cleancache(char *s)
@@ -1800,6 +1986,12 @@ static int __init zcache_init(void)
 		old_ops = zcache_frontswap_register_ops();
 		if (frontswap_has_exclusive_gets)
 			frontswap_tmem_exclusive_gets(true);
+#ifdef CONFIG_ZCACHE_ZSMALLOC
+		if (zsmalloc_enabled)
+			pr_info("%s: frontswap enabled using kernel"
+				"transcendent memory and zsmalloc\n", namestr);
+		else
+#endif
 		pr_info("%s: frontswap enabled using kernel transcendent "
 			"memory and compression buddies\n", namestr);
 #ifdef ZCACHE_DEBUG
diff --git a/drivers/staging/zcache/zcache.h b/drivers/staging/zcache/zcache.h
index 81722b3..34d63b1 100644
--- a/drivers/staging/zcache/zcache.h
+++ b/drivers/staging/zcache/zcache.h
@@ -22,6 +22,9 @@ struct tmem_pool;
 
 struct zcache_client {
 	struct tmem_pool *tmem_pools[MAX_POOLS_PER_CLIENT];
+#ifdef CONFIG_ZCACHE_ZSMALLOC
+	struct zs_pool *zspool;
+#endif
 	bool allocated;
 	atomic_t refcount;
 };
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
