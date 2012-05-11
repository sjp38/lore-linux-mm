Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 861158D0001
	for <linux-mm@kvack.org>; Fri, 11 May 2012 17:50:02 -0400 (EDT)
Received: from /spool/local
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Fri, 11 May 2012 15:50:01 -0600
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 944AC3E40055
	for <linux-mm@kvack.org>; Fri, 11 May 2012 15:49:58 -0600 (MDT)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q4BLnxTc204186
	for <linux-mm@kvack.org>; Fri, 11 May 2012 15:49:59 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q4BLnw0o023710
	for <linux-mm@kvack.org>; Fri, 11 May 2012 15:49:58 -0600
Message-ID: <4FAD8984.2050201@linux.vnet.ibm.com>
Date: Fri, 11 May 2012 16:49:56 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/4] zsmalloc use zs_handle instead of void *
References: <4FABD503.4030808@vflare.org> <4FABDA9F.1000105@linux.vnet.ibm.com> <20120510151941.GA18302@kroah.com> <4FABECF5.8040602@vflare.org> <20120510164418.GC13964@kroah.com> <4FABF9D4.8080303@vflare.org> <20120510173322.GA30481@phenom.dumpdata.com> <4FAC4E3B.3030909@kernel.org> <8473859b-42f3-4354-b5ba-fd5b8cbac22f@default> <4FAC59F6.4080503@kernel.org> <20120511192915.GD3785@phenom.dumpdata.com>
In-Reply-To: <20120511192915.GD3785@phenom.dumpdata.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: Minchan Kim <minchan@kernel.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Nitin Gupta <ngupta@vflare.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 05/11/2012 02:29 PM, Konrad Rzeszutek Wilk wrote:

>> At least, zram is also primary user and it also has such mess
>> although it's not severe than zcache. zram->table[index].handle
>> sometime has real (void*) handle, sometime (struct page*).
> 
> Yikes. Yeah that needs to be fixed.
> 


How about this (untested)?  Changes to zram_bvec_write() are a little
hard to make out in this format.  There are a couple of checkpatch fixes
(two split line strings) and an unused variable store_offset removal mixed
in too. If this patch is good, I'll break them up for official submission
after I test.

diff --git a/drivers/staging/zram/zram_drv.h b/drivers/staging/zram/zram_drv.h
index fbe8ac9..10dcd99 100644
--- a/drivers/staging/zram/zram_drv.h
+++ b/drivers/staging/zram/zram_drv.h
@@ -81,7 +81,10 @@ enum zram_pageflags {
 
 /* Allocated for each disk page */
 struct table {
-	void *handle;
+	union {
+		void *handle; /* compressible */
+		struct page *page; /* incompressible */
+	};
 	u16 size;	/* object size (excluding header) */
 	u8 count;	/* object ref count (not yet used) */
 	u8 flags;
diff --git a/drivers/staging/zram/zram_drv.c b/drivers/staging/zram/zram_drv.c
index 685d612..d49deca 100644
--- a/drivers/staging/zram/zram_drv.c
+++ b/drivers/staging/zram/zram_drv.c
@@ -150,7 +150,7 @@ static void zram_free_page(struct zram *zram, size_t index)
 	}
 
 	if (unlikely(zram_test_flag(zram, index, ZRAM_UNCOMPRESSED))) {
-		__free_page(handle);
+		__free_page(zram->table[index].page);
 		zram_clear_flag(zram, index, ZRAM_UNCOMPRESSED);
 		zram_stat_dec(&zram->stats.pages_expand);
 		goto out;
@@ -189,7 +189,7 @@ static void handle_uncompressed_page(struct zram *zram, struct bio_vec *bvec,
 	unsigned char *user_mem, *cmem;
 
 	user_mem = kmap_atomic(page);
-	cmem = kmap_atomic(zram->table[index].handle);
+	cmem = kmap_atomic(zram->table[index].page);
 
 	memcpy(user_mem + bvec->bv_offset, cmem + offset, bvec->bv_len);
 	kunmap_atomic(cmem);
@@ -315,7 +315,6 @@ static int zram_bvec_write(struct zram *zram, struct bio_vec *bvec, u32 index,
 			   int offset)
 {
 	int ret;
-	u32 store_offset;
 	size_t clen;
 	void *handle;
 	struct zobj_header *zheader;
@@ -390,31 +389,38 @@ static int zram_bvec_write(struct zram *zram, struct bio_vec *bvec, u32 index,
 		clen = PAGE_SIZE;
 		page_store = alloc_page(GFP_NOIO | __GFP_HIGHMEM);
 		if (unlikely(!page_store)) {
-			pr_info("Error allocating memory for "
-				"incompressible page: %u\n", index);
+			pr_info("Error allocating memory for incompressible page: %u\n", index);
 			ret = -ENOMEM;
 			goto out;
 		}
 
-		store_offset = 0;
-		zram_set_flag(zram, index, ZRAM_UNCOMPRESSED);
-		zram_stat_inc(&zram->stats.pages_expand);
-		handle = page_store;
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
+		zram->table[index].page = page_store;
+		zram->table[index].size = PAGE_SIZE;
+
+		zram_set_flag(zram, index, ZRAM_UNCOMPRESSED);
+		zram_stat_inc(&zram->stats.pages_expand);
+	} else {
+		handle = zs_malloc(zram->mem_pool, clen + sizeof(*zheader));
+		if (!handle) {
+			pr_info("Error allocating memory for compressed page: %u, size=%zu\n", index, clen);
+			ret = -ENOMEM;
+			goto out;
+		}
+
+		zram->table[index].handle = handle;
+		zram->table[index].size = clen;
+
+		cmem = zs_map_object(zram->mem_pool, handle);
+		memcpy(cmem, src, clen);
+		zs_unmap_object(zram->mem_pool, handle);
 	}
-	cmem = zs_map_object(zram->mem_pool, handle);
 
-memstore:
 #if 0
 	/* Back-reference needed for memory defragmentation */
 	if (!zram_test_flag(zram, index, ZRAM_UNCOMPRESSED)) {
@@ -424,18 +430,6 @@ memstore:
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
@@ -580,6 +574,8 @@ error:
 void __zram_reset_device(struct zram *zram)
 {
 	size_t index;
+	void *handle;
+	struct page *page;
 
 	zram->init_done = 0;
 
@@ -592,14 +588,17 @@ void __zram_reset_device(struct zram *zram)
 
 	/* Free all pages that are still in this zram device */
 	for (index = 0; index < zram->disksize >> PAGE_SHIFT; index++) {
-		void *handle = zram->table[index].handle;
-		if (!handle)
-			continue;
-
-		if (unlikely(zram_test_flag(zram, index, ZRAM_UNCOMPRESSED)))
-			__free_page(handle);
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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
