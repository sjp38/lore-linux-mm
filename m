Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5CBF86B0038
	for <linux-mm@kvack.org>; Fri,  3 Feb 2017 03:41:40 -0500 (EST)
Received: by mail-ot0-f197.google.com with SMTP id 65so11691605otq.2
        for <linux-mm@kvack.org>; Fri, 03 Feb 2017 00:41:40 -0800 (PST)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id x75si10583151oix.221.2017.02.03.00.41.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 03 Feb 2017 00:41:39 -0800 (PST)
From: <zhouxianrong@huawei.com>
Subject: [PATCH] mm: extend zero pages to same element pages for zram
Date: Fri, 3 Feb 2017 16:34:19 +0800
Message-ID: <1486110859-95209-1-git-send-email-zhouxianrong@huawei.com>
In-Reply-To: <1483692145-75357-1-git-send-email-zhouxianrong@huawei.com>
References: <1483692145-75357-1-git-send-email-zhouxianrong@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, sergey.senozhatsky@gmail.com, minchan@kernel.org, willy@infradead.org, iamjoonsoo.kim@lge.com, ngupta@vflare.org, Mi.Sophia.Wang@huawei.com, zhouxianrong@huawei.com, zhouxiyu@huawei.com, weidu.du@huawei.com, zhangshiming5@huawei.com, won.ho.park@huawei.com

From: zhouxianrong <zhouxianrong@huawei.com>

test result as listed below:

zero   pattern_char pattern_short pattern_int pattern_long total   (unit)
162989 14454        3534          23516       2769         3294399 (page)

statistics for the result:

        zero  pattern_char  pattern_short  pattern_int  pattern_long
AVERAGE 0.745696298 0.085937175 0.015957701 0.131874915 0.020533911
STDEV   0.035623777 0.016892402 0.004454534 0.021657123 0.019420072
MAX     0.973813421 0.222222222 0.021409518 0.211812245 0.176512625
MIN     0.645431905 0.004634398 0           0           0

Signed-off-by: zhouxianrong <zhouxianrong@huawei.com>
---
 drivers/block/zram/zram_drv.c |  122 ++++++++++++++++++++++++++++++++---------
 drivers/block/zram/zram_drv.h |   11 ++--
 2 files changed, 102 insertions(+), 31 deletions(-)

diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
index e5ab7d9..e826d0d 100644
--- a/drivers/block/zram/zram_drv.c
+++ b/drivers/block/zram/zram_drv.c
@@ -95,6 +95,17 @@ static void zram_clear_flag(struct zram_meta *meta, u32 index,
 	meta->table[index].value &= ~BIT(flag);
 }
 
+static inline void zram_set_element(struct zram_meta *meta, u32 index,
+			unsigned long element)
+{
+	meta->table[index].element = element;
+}
+
+static inline void zram_clear_element(struct zram_meta *meta, u32 index)
+{
+	meta->table[index].element = 0;
+}
+
 static size_t zram_get_obj_size(struct zram_meta *meta, u32 index)
 {
 	return meta->table[index].value & (BIT(ZRAM_FLAG_SHIFT) - 1);
@@ -167,31 +178,78 @@ static inline void update_used_max(struct zram *zram,
 	} while (old_max != cur_max);
 }
 
-static bool page_zero_filled(void *ptr)
+static inline void zram_fill_page(char *ptr, unsigned long value)
+{
+	int i;
+	unsigned long *page = (unsigned long *)ptr;
+
+	if (likely(value == 0)) {
+		clear_page(ptr);
+	} else {
+		for (i = 0; i < PAGE_SIZE / sizeof(*page); i++)
+			page[i] = value;
+	}
+}
+
+static inline void zram_fill_page_partial(char *ptr, unsigned int size,
+		unsigned long value)
+{
+	int i;
+	unsigned long *page;
+
+	if (likely(value == 0)) {
+		memset(ptr, 0, size);
+		return;
+	}
+
+	i = ((unsigned long)ptr) % sizeof(*page);
+	if (i) {
+		while (i < sizeof(*page)) {
+			*ptr++ = (value >> (i * 8)) & 0xff;
+			--size;
+			++i;
+		}
+	}
+
+	for (i = size / sizeof(*page); i > 0; --i) {
+		page = (unsigned long *)ptr;
+		*page = value;
+		ptr += sizeof(*page);
+		size -= sizeof(*page);
+	}
+
+	for (i = 0; i < size; ++i)
+		*ptr++ = (value >> (i * 8)) & 0xff;
+}
+
+static bool page_same_filled(void *ptr, unsigned long *element)
 {
 	unsigned int pos;
 	unsigned long *page;
 
 	page = (unsigned long *)ptr;
 
-	for (pos = 0; pos != PAGE_SIZE / sizeof(*page); pos++) {
-		if (page[pos])
+	for (pos = 0; pos < PAGE_SIZE / sizeof(*page) - 1; pos++) {
+		if (page[pos] != page[pos + 1])
 			return false;
 	}
 
+	*element = page[pos];
+
 	return true;
 }
 
-static void handle_zero_page(struct bio_vec *bvec)
+static void handle_same_page(struct bio_vec *bvec, unsigned long element)
 {
 	struct page *page = bvec->bv_page;
 	void *user_mem;
 
 	user_mem = kmap_atomic(page);
 	if (is_partial_io(bvec))
-		memset(user_mem + bvec->bv_offset, 0, bvec->bv_len);
+		zram_fill_page_partial(user_mem + bvec->bv_offset, bvec->bv_len,
+			element);
 	else
-		clear_page(user_mem);
+		zram_fill_page(user_mem, element);
 	kunmap_atomic(user_mem);
 
 	flush_dcache_page(page);
@@ -440,7 +498,7 @@ static ssize_t mm_stat_show(struct device *dev,
 			mem_used << PAGE_SHIFT,
 			zram->limit_pages << PAGE_SHIFT,
 			max_used << PAGE_SHIFT,
-			(u64)atomic64_read(&zram->stats.zero_pages),
+			(u64)atomic64_read(&zram->stats.same_pages),
 			pool_stats.pages_compacted);
 	up_read(&zram->init_lock);
 
@@ -473,7 +531,7 @@ static ssize_t debug_stat_show(struct device *dev,
 ZRAM_ATTR_RO(failed_writes);
 ZRAM_ATTR_RO(invalid_io);
 ZRAM_ATTR_RO(notify_free);
-ZRAM_ATTR_RO(zero_pages);
+ZRAM_ATTR_RO(same_pages);
 ZRAM_ATTR_RO(compr_data_size);
 
 static inline bool zram_meta_get(struct zram *zram)
@@ -495,11 +553,17 @@ static void zram_meta_free(struct zram_meta *meta, u64 disksize)
 
 	/* Free all pages that are still in this zram device */
 	for (index = 0; index < num_pages; index++) {
-		unsigned long handle = meta->table[index].handle;
+		unsigned long handle;
+
+		bit_spin_lock(ZRAM_ACCESS, &meta->table[index].value);
+		handle = meta->table[index].handle;
 
-		if (!handle)
+		if (!handle || zram_test_flag(meta, index, ZRAM_SAME)) {
+			bit_spin_unlock(ZRAM_ACCESS, &meta->table[index].value);
 			continue;
+		}
 
+		bit_spin_unlock(ZRAM_ACCESS, &meta->table[index].value);
 		zs_free(meta->mem_pool, handle);
 	}
 
@@ -547,18 +611,20 @@ static void zram_free_page(struct zram *zram, size_t index)
 	struct zram_meta *meta = zram->meta;
 	unsigned long handle = meta->table[index].handle;
 
-	if (unlikely(!handle)) {
-		/*
-		 * No memory is allocated for zero filled pages.
-		 * Simply clear zero page flag.
-		 */
-		if (zram_test_flag(meta, index, ZRAM_ZERO)) {
-			zram_clear_flag(meta, index, ZRAM_ZERO);
-			atomic64_dec(&zram->stats.zero_pages);
-		}
+	/*
+	 * No memory is allocated for same element filled pages.
+	 * Simply clear same page flag.
+	 */
+	if (zram_test_flag(meta, index, ZRAM_SAME)) {
+		zram_clear_flag(meta, index, ZRAM_SAME);
+		zram_clear_element(meta, index);
+		atomic64_dec(&zram->stats.same_pages);
 		return;
 	}
 
+	if (unlikely(!handle))
+		return;
+
 	zs_free(meta->mem_pool, handle);
 
 	atomic64_sub(zram_get_obj_size(meta, index),
@@ -581,9 +647,9 @@ static int zram_decompress_page(struct zram *zram, char *mem, u32 index)
 	handle = meta->table[index].handle;
 	size = zram_get_obj_size(meta, index);
 
-	if (!handle || zram_test_flag(meta, index, ZRAM_ZERO)) {
+	if (!handle || zram_test_flag(meta, index, ZRAM_SAME)) {
 		bit_spin_unlock(ZRAM_ACCESS, &meta->table[index].value);
-		clear_page(mem);
+		zram_fill_page(mem, meta->table[index].element);
 		return 0;
 	}
 
@@ -619,9 +685,9 @@ static int zram_bvec_read(struct zram *zram, struct bio_vec *bvec,
 
 	bit_spin_lock(ZRAM_ACCESS, &meta->table[index].value);
 	if (unlikely(!meta->table[index].handle) ||
-			zram_test_flag(meta, index, ZRAM_ZERO)) {
+			zram_test_flag(meta, index, ZRAM_SAME)) {
 		bit_spin_unlock(ZRAM_ACCESS, &meta->table[index].value);
-		handle_zero_page(bvec);
+		handle_same_page(bvec, meta->table[index].element);
 		return 0;
 	}
 	bit_spin_unlock(ZRAM_ACCESS, &meta->table[index].value);
@@ -669,6 +735,7 @@ static int zram_bvec_write(struct zram *zram, struct bio_vec *bvec, u32 index,
 	struct zram_meta *meta = zram->meta;
 	struct zcomp_strm *zstrm = NULL;
 	unsigned long alloced_pages;
+	unsigned long element;
 
 	page = bvec->bv_page;
 	if (is_partial_io(bvec)) {
@@ -697,16 +764,17 @@ static int zram_bvec_write(struct zram *zram, struct bio_vec *bvec, u32 index,
 		uncmem = user_mem;
 	}
 
-	if (page_zero_filled(uncmem)) {
+	if (page_same_filled(uncmem, &element)) {
 		if (user_mem)
 			kunmap_atomic(user_mem);
 		/* Free memory associated with this sector now. */
 		bit_spin_lock(ZRAM_ACCESS, &meta->table[index].value);
 		zram_free_page(zram, index);
-		zram_set_flag(meta, index, ZRAM_ZERO);
+		zram_set_flag(meta, index, ZRAM_SAME);
+		zram_set_element(meta, index, element);
 		bit_spin_unlock(ZRAM_ACCESS, &meta->table[index].value);
 
-		atomic64_inc(&zram->stats.zero_pages);
+		atomic64_inc(&zram->stats.same_pages);
 		ret = 0;
 		goto out;
 	}
@@ -1206,7 +1274,7 @@ static int zram_open(struct block_device *bdev, fmode_t mode)
 	&dev_attr_compact.attr,
 	&dev_attr_invalid_io.attr,
 	&dev_attr_notify_free.attr,
-	&dev_attr_zero_pages.attr,
+	&dev_attr_same_pages.attr,
 	&dev_attr_orig_data_size.attr,
 	&dev_attr_compr_data_size.attr,
 	&dev_attr_mem_used_total.attr,
diff --git a/drivers/block/zram/zram_drv.h b/drivers/block/zram/zram_drv.h
index 74fcf10..4bb92e1 100644
--- a/drivers/block/zram/zram_drv.h
+++ b/drivers/block/zram/zram_drv.h
@@ -60,8 +60,8 @@
 
 /* Flags for zram pages (table[page_no].value) */
 enum zram_pageflags {
-	/* Page consists entirely of zeros */
-	ZRAM_ZERO = ZRAM_FLAG_SHIFT,
+	/* Page consists entirely of same elements */
+	ZRAM_SAME = ZRAM_FLAG_SHIFT,
 	ZRAM_ACCESS,	/* page is now accessed */
 
 	__NR_ZRAM_PAGEFLAGS,
@@ -71,7 +71,10 @@ enum zram_pageflags {
 
 /* Allocated for each disk page */
 struct zram_table_entry {
-	unsigned long handle;
+	union {
+		unsigned long handle;
+		unsigned long element;
+	};
 	unsigned long value;
 };
 
@@ -83,7 +86,7 @@ struct zram_stats {
 	atomic64_t failed_writes;	/* can happen when memory is too low */
 	atomic64_t invalid_io;	/* non-page-aligned I/O requests */
 	atomic64_t notify_free;	/* no. of swap slot free notifications */
-	atomic64_t zero_pages;		/* no. of zero filled pages */
+	atomic64_t same_pages;		/* no. of same element filled pages */
 	atomic64_t pages_stored;	/* no. of pages currently stored */
 	atomic_long_t max_used_pages;	/* no. of maximum pages stored */
 	atomic64_t writestall;		/* no. of write slow paths */
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
