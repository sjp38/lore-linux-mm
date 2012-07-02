Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id C29876B0070
	for <linux-mm@kvack.org>; Mon,  2 Jul 2012 17:16:24 -0400 (EDT)
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Mon, 2 Jul 2012 15:16:24 -0600
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 2DC52C9005C
	for <linux-mm@kvack.org>; Mon,  2 Jul 2012 17:16:14 -0400 (EDT)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q62LGDQf1901042
	for <linux-mm@kvack.org>; Mon, 2 Jul 2012 17:16:13 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q632l6hf031799
	for <linux-mm@kvack.org>; Mon, 2 Jul 2012 22:47:06 -0400
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: [PATCH 4/4] zsmalloc: add mapping modes
Date: Mon,  2 Jul 2012 16:15:52 -0500
Message-Id: <1341263752-10210-5-git-send-email-sjenning@linux.vnet.ibm.com>
In-Reply-To: <1341263752-10210-1-git-send-email-sjenning@linux.vnet.ibm.com>
References: <1341263752-10210-1-git-send-email-sjenning@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, linux-mm@kvack.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

This patch improves mapping performance in zsmalloc by getting
usage information from the user in the form of a "mapping mode"
and using it to avoid unnecessary copying for objects that span
pages.

Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
---
 drivers/staging/zcache/zcache-main.c     |    6 +++---
 drivers/staging/zram/zram_drv.c          |    7 ++++---
 drivers/staging/zsmalloc/zsmalloc-main.c |   29 ++++++++++++++++++-----------
 drivers/staging/zsmalloc/zsmalloc.h      |   14 +++++++++++++-
 drivers/staging/zsmalloc/zsmalloc_int.h  |    1 +
 5 files changed, 39 insertions(+), 18 deletions(-)

diff --git a/drivers/staging/zcache/zcache-main.c b/drivers/staging/zcache/zcache-main.c
index c9e08bb..a8aabbe 100644
--- a/drivers/staging/zcache/zcache-main.c
+++ b/drivers/staging/zcache/zcache-main.c
@@ -708,7 +708,7 @@ static unsigned long zv_create(struct zs_pool *pool, uint32_t pool_id,
 		goto out;
 	atomic_inc(&zv_curr_dist_counts[chunks]);
 	atomic_inc(&zv_cumul_dist_counts[chunks]);
-	zv = zs_map_object(pool, handle);
+	zv = zs_map_object(pool, handle, ZS_MM_WO);
 	zv->index = index;
 	zv->oid = *oid;
 	zv->pool_id = pool_id;
@@ -727,7 +727,7 @@ static void zv_free(struct zs_pool *pool, unsigned long handle)
 	uint16_t size;
 	int chunks;
 
-	zv = zs_map_object(pool, handle);
+	zv = zs_map_object(pool, handle, ZS_MM_RW);
 	ASSERT_SENTINEL(zv, ZVH);
 	size = zv->size + sizeof(struct zv_hdr);
 	INVERT_SENTINEL(zv, ZVH);
@@ -749,7 +749,7 @@ static void zv_decompress(struct page *page, unsigned long handle)
 	int ret;
 	struct zv_hdr *zv;
 
-	zv = zs_map_object(zcache_host.zspool, handle);
+	zv = zs_map_object(zcache_host.zspool, handle, ZS_MM_RO);
 	BUG_ON(zv->size == 0);
 	ASSERT_SENTINEL(zv, ZVH);
 	to_va = kmap_atomic(page);
diff --git a/drivers/staging/zram/zram_drv.c b/drivers/staging/zram/zram_drv.c
index 706cb62..653b074 100644
--- a/drivers/staging/zram/zram_drv.c
+++ b/drivers/staging/zram/zram_drv.c
@@ -220,7 +220,8 @@ static int zram_bvec_read(struct zram *zram, struct bio_vec *bvec,
 		uncmem = user_mem;
 	clen = PAGE_SIZE;
 
-	cmem = zs_map_object(zram->mem_pool, zram->table[index].handle);
+	cmem = zs_map_object(zram->mem_pool, zram->table[index].handle,
+				ZS_MM_RO);
 
 	ret = lzo1x_decompress_safe(cmem, zram->table[index].size,
 				    uncmem, &clen);
@@ -258,7 +259,7 @@ static int zram_read_before_write(struct zram *zram, char *mem, u32 index)
 		return 0;
 	}
 
-	cmem = zs_map_object(zram->mem_pool, handle);
+	cmem = zs_map_object(zram->mem_pool, handle, ZS_MM_RO);
 	ret = lzo1x_decompress_safe(cmem, zram->table[index].size,
 				    mem, &clen);
 	zs_unmap_object(zram->mem_pool, handle);
@@ -351,7 +352,7 @@ static int zram_bvec_write(struct zram *zram, struct bio_vec *bvec, u32 index,
 		ret = -ENOMEM;
 		goto out;
 	}
-	cmem = zs_map_object(zram->mem_pool, handle);
+	cmem = zs_map_object(zram->mem_pool, handle, ZS_MM_WO);
 
 	memcpy(cmem, src, clen);
 
diff --git a/drivers/staging/zsmalloc/zsmalloc-main.c b/drivers/staging/zsmalloc/zsmalloc-main.c
index abf7c13..8b0bcb6 100644
--- a/drivers/staging/zsmalloc/zsmalloc-main.c
+++ b/drivers/staging/zsmalloc/zsmalloc-main.c
@@ -484,9 +484,6 @@ static void zs_copy_map_object(char *buf, struct page *firstpage,
 	sizes[0] = PAGE_SIZE - off;
 	sizes[1] = size - sizes[0];
 
-	/* disable page faults to match kmap_atomic() return conditions */
-	pagefault_disable();
-
 	/* copy object to per-cpu buffer */
 	addr = kmap_atomic(pages[0]);
 	memcpy(buf, addr + off, sizes[0]);
@@ -517,9 +514,6 @@ static void zs_copy_unmap_object(char *buf, struct page *firstpage,
 	addr = kmap_atomic(pages[1]);
 	memcpy(addr, buf + sizes[0], sizes[1]);
 	kunmap_atomic(addr);
-
-	/* enable page faults to match kunmap_atomic() return conditions */
-	pagefault_enable();
 }
 
 static int zs_cpu_notifier(struct notifier_block *nb, unsigned long action,
@@ -754,7 +748,8 @@ EXPORT_SYMBOL_GPL(zs_free);
  *
  * This function returns with preemption and page faults disabled.
 */
-void *zs_map_object(struct zs_pool *pool, unsigned long handle)
+void *zs_map_object(struct zs_pool *pool, unsigned long handle,
+			enum zs_mapmode mm)
 {
 	struct page *page;
 	unsigned long obj_idx, off;
@@ -778,7 +773,11 @@ void *zs_map_object(struct zs_pool *pool, unsigned long handle)
 		return area->vm_addr + off;
 	}
 
-	zs_copy_map_object(area->vm_buf, page, off, class->size);
+	/* disable page faults to match kmap_atomic() return conditions */
+	pagefault_disable();
+
+	if (mm != ZS_MM_WO)
+		zs_copy_map_object(area->vm_buf, page, off, class->size);
 	area->vm_addr = NULL;
 	return area->vm_buf;
 }
@@ -795,13 +794,16 @@ void zs_unmap_object(struct zs_pool *pool, unsigned long handle)
 	struct mapping_area *area;
 
 	area = &__get_cpu_var(zs_map_area);
+	/* single-page object fastpath */
 	if (area->vm_addr) {
-		/* single-page object fastpath */
 		kunmap_atomic(area->vm_addr);
-		put_cpu_var(zs_map_area);
-		return;
+		goto out;
 	}
 
+	/* no write fastpath */
+	if (area->vm_mm == ZS_MM_RO)
+		goto pfenable;
+
 	BUG_ON(!handle);
 
 	obj_handle_to_location(handle, &page, &obj_idx);
@@ -810,6 +812,11 @@ void zs_unmap_object(struct zs_pool *pool, unsigned long handle)
 	off = obj_idx_to_offset(page, obj_idx, class->size);
 
 	zs_copy_unmap_object(area->vm_buf, page, off, class->size);
+
+pfenable:
+	/* enable page faults to match kunmap_atomic() return conditions */
+	pagefault_enable();
+out:
 	put_cpu_var(zs_map_area);
 }
 EXPORT_SYMBOL_GPL(zs_unmap_object);
diff --git a/drivers/staging/zsmalloc/zsmalloc.h b/drivers/staging/zsmalloc/zsmalloc.h
index 485cbb1..de2e8bf 100644
--- a/drivers/staging/zsmalloc/zsmalloc.h
+++ b/drivers/staging/zsmalloc/zsmalloc.h
@@ -15,6 +15,17 @@
 
 #include <linux/types.h>
 
+/*
+ * zsmalloc mapping modes
+ *
+ * NOTE: These only make a difference when a mapped object spans pages
+*/
+enum zs_mapmode {
+	ZS_MM_RW, /* normal read-write mapping */
+	ZS_MM_RO, /* read-only (no copy-out at unmap time) */
+	ZS_MM_WO /* write-only (no copy-in at map time) */
+};
+
 struct zs_pool;
 
 struct zs_pool *zs_create_pool(const char *name, gfp_t flags);
@@ -23,7 +34,8 @@ void zs_destroy_pool(struct zs_pool *pool);
 unsigned long zs_malloc(struct zs_pool *pool, size_t size);
 void zs_free(struct zs_pool *pool, unsigned long obj);
 
-void *zs_map_object(struct zs_pool *pool, unsigned long handle);
+void *zs_map_object(struct zs_pool *pool, unsigned long handle,
+			enum zs_mapmode mm);
 void zs_unmap_object(struct zs_pool *pool, unsigned long handle);
 
 u64 zs_get_total_size_bytes(struct zs_pool *pool);
diff --git a/drivers/staging/zsmalloc/zsmalloc_int.h b/drivers/staging/zsmalloc/zsmalloc_int.h
index f760dae..52805176 100644
--- a/drivers/staging/zsmalloc/zsmalloc_int.h
+++ b/drivers/staging/zsmalloc/zsmalloc_int.h
@@ -112,6 +112,7 @@ static const int fullness_threshold_frac = 4;
 struct mapping_area {
 	char *vm_buf; /* copy buffer for objects that span pages */
 	char *vm_addr; /* address of kmap_atomic()'ed pages */
+	enum zs_mapmode vm_mm; /* mapping mode */
 };
 
 struct size_class {
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
