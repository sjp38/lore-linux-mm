Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id ABA266B00E8
	for <linux-mm@kvack.org>; Tue, 22 May 2012 21:43:45 -0400 (EDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH 2/2 v2] zram: clean up handle
Date: Wed, 23 May 2012 10:43:22 +0900
Message-Id: <1337737402-16543-2-git-send-email-minchan@kernel.org>
In-Reply-To: <1337737402-16543-1-git-send-email-minchan@kernel.org>
References: <1337737402-16543-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>

zram's handle variable can store handle of zsmalloc in case of
compressing efficiently. Otherwise, it stores point of page descriptor.
This patch clean up the mess by union struct.

changelog
  * from v1
	- none(new add in v2)

Cc: Nitin Gupta <ngupta@vflare.org>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 drivers/staging/zram/zram_drv.c |   77 ++++++++++++++++++++-------------------
 drivers/staging/zram/zram_drv.h |    5 ++-
 2 files changed, 44 insertions(+), 38 deletions(-)

diff --git a/drivers/staging/zram/zram_drv.c b/drivers/staging/zram/zram_drv.c
index abd69d1..ceab5ca 100644
--- a/drivers/staging/zram/zram_drv.c
+++ b/drivers/staging/zram/zram_drv.c
@@ -150,7 +150,7 @@ static void zram_free_page(struct zram *zram, size_t index)
 	}
 
 	if (unlikely(zram_test_flag(zram, index, ZRAM_UNCOMPRESSED))) {
-		__free_page((struct page *)handle);
+		__free_page(zram->table[index].page);
 		zram_clear_flag(zram, index, ZRAM_UNCOMPRESSED);
 		zram_stat_dec(&zram->stats.pages_expand);
 		goto out;
@@ -189,7 +189,7 @@ static void handle_uncompressed_page(struct zram *zram, struct bio_vec *bvec,
 	unsigned char *user_mem, *cmem;
 
 	user_mem = kmap_atomic(page);
-	cmem = kmap_atomic((struct page *)zram->table[index].handle);
+	cmem = kmap_atomic(zram->table[index].page);
 
 	memcpy(user_mem + bvec->bv_offset, cmem + offset, bvec->bv_len);
 	kunmap_atomic(cmem);
@@ -315,7 +315,6 @@ static int zram_bvec_write(struct zram *zram, struct bio_vec *bvec, u32 index,
 			   int offset)
 {
 	int ret;
-	u32 store_offset;
 	size_t clen;
 	unsigned long handle;
 	struct zobj_header *zheader;
@@ -396,25 +395,33 @@ static int zram_bvec_write(struct zram *zram, struct bio_vec *bvec, u32 index,
 			goto out;
 		}
 
-		store_offset = 0;
-		zram_set_flag(zram, index, ZRAM_UNCOMPRESSED);
-		zram_stat_inc(&zram->stats.pages_expand);
-		handle = (unsigned long)page_store;
 		src = kmap_atomic(page);
 		cmem = kmap_atomic(page_store);
-		goto memstore;
-	}
+		memcpy(cmem, src, clen);
+		kunmap_atomic(cmem);
+		kunmap_atomic(src);
 
-	handle = zs_malloc(zram->mem_pool, clen + sizeof(*zheader));
-	if (!handle) {
-		pr_info("Error allocating memory for compressed "
-			"page: %u, size=%zu\n", index, clen);
-		ret = -ENOMEM;
-		goto out;
-	}
-	cmem = zs_map_object(zram->mem_pool, handle);
+		zram->table[index].page = page_store;
+		zram->table[index].size = PAGE_SIZE;
+
+		zram_set_flag(zram, index, ZRAM_UNCOMPRESSED);
+		zram_stat_inc(&zram->stats.pages_expand);
+	} else {
+		handle = zs_malloc(zram->mem_pool, clen + sizeof(*zheader));
+		if (!handle) {
+			pr_info("Error allocating memory for "
+				"compressed page: %u, size=%zu\n", index, clen);
+			ret = -ENOMEM;
+			goto out;
+		}
+
+		zram->table[index].handle = handle;
+		zram->table[index].size = clen;
 
-memstore:
+		cmem = zs_map_object(zram->mem_pool, handle);
+		memcpy(cmem, src, clen);
+		zs_unmap_object(zram->mem_pool, handle);
+	}
 #if 0
 	/* Back-reference needed for memory defragmentation */
 	if (!zram_test_flag(zram, index, ZRAM_UNCOMPRESSED)) {
@@ -424,18 +431,6 @@ memstore:
 	}
 #endif
 
-	memcpy(cmem, src, clen);
-
-	if (unlikely(zram_test_flag(zram, index, ZRAM_UNCOMPRESSED))) {
-		kunmap_atomic(cmem);
-		kunmap_atomic(src);
-	} else {
-		zs_unmap_object(zram->mem_pool, handle);
-	}
-
-	zram->table[index].handle = handle;
-	zram->table[index].size = clen;
-
 	/* Update stats */
 	zram_stat64_add(zram, &zram->stats.compr_size, clen);
 	zram_stat_inc(&zram->stats.pages_stored);
@@ -580,6 +575,8 @@ error:
 void __zram_reset_device(struct zram *zram)
 {
 	size_t index;
+	unsigned long handle;
+	struct page *page;
 
 	zram->init_done = 0;
 
@@ -592,14 +589,17 @@ void __zram_reset_device(struct zram *zram)
 
 	/* Free all pages that are still in this zram device */
 	for (index = 0; index < zram->disksize >> PAGE_SHIFT; index++) {
-		unsigned long handle = zram->table[index].handle;
-		if (!handle)
-			continue;
-
-		if (unlikely(zram_test_flag(zram, index, ZRAM_UNCOMPRESSED)))
-			__free_page((struct page *)handle);
-		else
+		if (unlikely(zram_test_flag(zram, index, ZRAM_UNCOMPRESSED))) {
+			page = zram->table[index].page;
+			if (!page)
+				continue;
+			__free_page(page);
+		} else {
+			handle = zram->table[index].handle;
+			if (!handle)
+				continue;
 			zs_free(zram->mem_pool, handle);
+		}
 	}
 
 	vfree(zram->table);
@@ -788,6 +788,9 @@ static int __init zram_init(void)
 {
 	int ret, dev_id;
 
+	BUILD_BUG_ON(sizeof(((struct table *)0)->page) !=
+		sizeof(((struct table *)0)->handle));
+
 	if (num_devices > max_num_devices) {
 		pr_warning("Invalid value for num_devices: %u\n",
 				num_devices);
diff --git a/drivers/staging/zram/zram_drv.h b/drivers/staging/zram/zram_drv.h
index 7a7e256..54d082f 100644
--- a/drivers/staging/zram/zram_drv.h
+++ b/drivers/staging/zram/zram_drv.h
@@ -81,7 +81,10 @@ enum zram_pageflags {
 
 /* Allocated for each disk page */
 struct table {
-	unsigned long handle;
+	union {
+		unsigned long handle; /* compressible */
+		struct page *page; /* incompressible */
+	};
 	u16 size;	/* object size (excluding header) */
 	u8 count;	/* object ref count (not yet used) */
 	u8 flags;
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
