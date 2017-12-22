Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id D31DD6B0038
	for <linux-mm@kvack.org>; Fri, 22 Dec 2017 05:34:48 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id f64so20019685pfd.6
        for <linux-mm@kvack.org>; Fri, 22 Dec 2017 02:34:48 -0800 (PST)
Received: from mailout1.samsung.com (mailout1.samsung.com. [203.254.224.24])
        by mx.google.com with ESMTPS id l5si14908302pgp.421.2017.12.22.02.34.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Dec 2017 02:34:47 -0800 (PST)
Received: from epcas5p3.samsung.com (unknown [182.195.41.41])
	by mailout1.samsung.com (KnoxPortal) with ESMTP id 20171222103444epoutp01d88d92ff29322396a577c9c1348b7727~Cl2T9bpAY2102321023epoutp01i
	for <linux-mm@kvack.org>; Fri, 22 Dec 2017 10:34:44 +0000 (GMT)
From: Gopi Sai Teja <gopi.st@samsung.com>
Subject: [PATCH v2] zram: better utilization of zram swap space
Date: Fri, 22 Dec 2017 16:00:06 +0530
Message-Id: <1513938606-17735-1-git-send-email-gopi.st@samsung.com>
Content-Type: text/plain; charset="utf-8"
References: <CGME20171222103443epcas5p41f45e1a99146aac89edd63f76a3eb62a@epcas5p4.samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: minchan@kernel.org, ngupta@vflare.org, sergey.senozhatsky.work@gmail.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, v.narang@samsung.com, pankaj.m@samsung.com, a.sahrawat@samsung.com, prakash.a@samsung.com, himanshu.sh@samsung.com, lalit.mohan@samsung.com, Gopi Sai Teja <gopi.st@samsung.com>

75% of the PAGE_SIZE is not a correct threshold to store uncompressed
pages in zs_page as this must be changed if the maximum pages stored
in zspage changes. Instead using zs classes, we can set the correct
threshold irrespective of the maximum pages stored in zspage.

Tested on ARM:

Before Patch:
class  size  obj_allocated   obj_used pages_used
....
  190  3072           6744       6724       5058
  202  3264             90         87         72
  254  4096          11886      11886      11886

Total               123251     120511      55076

After Patch:
class  size  obj_allocated   obj_used pages_used
...
  190  3072           6368       6326       4776
  202  3264           2205       2197       1764
  254  4096          12624      12624      12624

Total               125655     122045      56541

Signed-off-by: Gopi Sai Teja <gopi.st@samsung.com>
---
v1 -> v2: Earlier, threshold to store uncompressed page is set
to 80% of PAGE_SIZE and now zsmalloc classes is used to set the
threshold.

 drivers/block/zram/zram_drv.c |  2 +-
 include/linux/zsmalloc.h      |  1 +
 mm/zsmalloc.c                 | 13 +++++++++++++
 3 files changed, 15 insertions(+), 1 deletion(-)

diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
index d70eba3..dda0ef8 100644
--- a/drivers/block/zram/zram_drv.c
+++ b/drivers/block/zram/zram_drv.c
@@ -965,7 +965,7 @@ static int __zram_bvec_write(struct zram *zram, struct bio_vec *bvec,
 		return ret;
 	}
 
-	if (unlikely(comp_len > max_zpage_size)) {
+	if (unlikely(comp_len > zs_max_zpage_size(zram->mem_pool))) {
 		if (zram_wb_enabled(zram) && allow_wb) {
 			zcomp_stream_put(zram->comp);
 			ret = write_to_bdev(zram, bvec, index, bio, &element);
diff --git a/include/linux/zsmalloc.h b/include/linux/zsmalloc.h
index 57a8e98..0b09aa5 100644
--- a/include/linux/zsmalloc.h
+++ b/include/linux/zsmalloc.h
@@ -54,5 +54,6 @@ void *zs_map_object(struct zs_pool *pool, unsigned long handle,
 unsigned long zs_get_total_pages(struct zs_pool *pool);
 unsigned long zs_compact(struct zs_pool *pool);
 
+unsigned int zs_max_zpage_size(struct zs_pool *pool);
 void zs_pool_stats(struct zs_pool *pool, struct zs_pool_stats *stats);
 #endif
diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 685049a..5b434ab 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -261,6 +261,7 @@ struct zs_pool {
 	 * and unregister_shrinker() will not Oops.
 	 */
 	bool shrinker_enabled;
+	unsigned short max_zpage_size;
 #ifdef CONFIG_ZSMALLOC_STAT
 	struct dentry *stat_dentry;
 #endif
@@ -318,6 +319,11 @@ static void init_deferred_free(struct zs_pool *pool) {}
 static void SetZsPageMovable(struct zs_pool *pool, struct zspage *zspage) {}
 #endif
 
+unsigned int zs_max_zpage_size(struct zs_pool *pool)
+{
+	return pool->max_zpage_size;
+}
+
 static int create_cache(struct zs_pool *pool)
 {
 	pool->handle_cachep = kmem_cache_create("zs_handle", ZS_HANDLE_SIZE,
@@ -2368,6 +2374,8 @@ struct zs_pool *zs_create_pool(const char *name)
 	if (create_cache(pool))
 		goto err;
 
+	pool->max_zpage_size = 0;
+
 	/*
 	 * Iterate reversely, because, size of size_class that we want to use
 	 * for merging should be larger or equal to current size.
@@ -2411,6 +2419,11 @@ struct zs_pool *zs_create_pool(const char *name)
 		class->objs_per_zspage = objs_per_zspage;
 		spin_lock_init(&class->lock);
 		pool->size_class[i] = class;
+
+		if (!pool->max_zpage_size &&
+				pages_per_zspage < objs_per_zspage)
+			pool->max_zpage_size = class->size - ZS_HANDLE_SIZE;
+
 		for (fullness = ZS_EMPTY; fullness < NR_ZS_FULLNESS;
 							fullness++)
 			INIT_LIST_HEAD(&class->fullness_list[fullness]);
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
