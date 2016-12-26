Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id DA4846B0038
	for <linux-mm@kvack.org>; Sun, 25 Dec 2016 19:39:42 -0500 (EST)
Received: by mail-lf0-f69.google.com with SMTP id x140so31010461lfa.2
        for <linux-mm@kvack.org>; Sun, 25 Dec 2016 16:39:42 -0800 (PST)
Received: from mail-lf0-x243.google.com (mail-lf0-x243.google.com. [2a00:1450:4010:c07::243])
        by mx.google.com with ESMTPS id z11si23854553lfj.146.2016.12.25.16.39.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 25 Dec 2016 16:39:41 -0800 (PST)
Received: by mail-lf0-x243.google.com with SMTP id d16so11930932lfb.1
        for <linux-mm@kvack.org>; Sun, 25 Dec 2016 16:39:41 -0800 (PST)
Date: Mon, 26 Dec 2016 01:39:17 +0100
From: Vitaly Wool <vitalywool@gmail.com>
Subject: [PATCH/RESEND 4/5] z3fold: fix header size related issues
Message-Id: <20161226013917.4a11608c97ce01a540b898f6@gmail.com>
In-Reply-To: <20161226013016.968004f3db024ef2111dc458@gmail.com>
References: <20161226013016.968004f3db024ef2111dc458@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: linux-kernel@vger.kernel.org, Dan Streetman <ddstreet@ieee.org>, Andrew Morton <akpm@linux-foundation.org>

Currently the whole kernel build will be stopped if the size of struct
z3fold_header is greater than the size of one chunk, which is 64 bytes by
default. This patch instead defines the offset for z3fold objects as the
size of the z3fold header in chunks.

Fixed also are the calculation of num_free_chunks() and the address to
move the middle chunk to in case of in-page compaction in
z3fold_compact_page().

Signed-off-by: Vitaly Wool <vitalywool@gmail.com>
---
 mm/z3fold.c | 161 ++++++++++++++++++++++++++++++++----------------------------
 1 file changed, 87 insertions(+), 74 deletions(-)

diff --git a/mm/z3fold.c b/mm/z3fold.c
index 28c0a2d..729a2da 100644
--- a/mm/z3fold.c
+++ b/mm/z3fold.c
@@ -34,29 +34,60 @@
 /*****************
  * Structures
 *****************/
+struct z3fold_pool;
+struct z3fold_ops {
+	int (*evict)(struct z3fold_pool *pool, unsigned long handle);
+};
+
+enum buddy {
+	HEADLESS = 0,
+	FIRST,
+	MIDDLE,
+	LAST,
+	BUDDIES_MAX
+};
+
+/*
+ * struct z3fold_header - z3fold page metadata occupying the first chunk of each
+ *			z3fold page, except for HEADLESS pages
+ * @buddy:	links the z3fold page into the relevant list in the pool
+ * @page_lock:		per-page lock
+ * @first_chunks:	the size of the first buddy in chunks, 0 if free
+ * @middle_chunks:	the size of the middle buddy in chunks, 0 if free
+ * @last_chunks:	the size of the last buddy in chunks, 0 if free
+ * @first_num:		the starting number (for the first handle)
+ */
+struct z3fold_header {
+	struct list_head buddy;
+	raw_spinlock_t page_lock;
+	unsigned short first_chunks;
+	unsigned short middle_chunks;
+	unsigned short last_chunks;
+	unsigned short start_middle;
+	unsigned short first_num:2;
+};
+
 /*
  * NCHUNKS_ORDER determines the internal allocation granularity, effectively
  * adjusting internal fragmentation.  It also determines the number of
  * freelists maintained in each pool. NCHUNKS_ORDER of 6 means that the
- * allocation granularity will be in chunks of size PAGE_SIZE/64. As one chunk
- * in allocated page is occupied by z3fold header, NCHUNKS will be calculated
- * to 63 which shows the max number of free chunks in z3fold page, also there
- * will be 63 freelists per pool.
+ * allocation granularity will be in chunks of size PAGE_SIZE/64. Some chunks
+ * in the beginning of an allocated page are occupied by z3fold header, so
+ * NCHUNKS will be calculated to 63 (or 62 in case CONFIG_DEBUG_SPINLOCK=y),
+ * which shows the max number of free chunks in z3fold page, also there will
+ * be 63, or 62, respectively, freelists per pool.
  */
 #define NCHUNKS_ORDER	6
 
 #define CHUNK_SHIFT	(PAGE_SHIFT - NCHUNKS_ORDER)
 #define CHUNK_SIZE	(1 << CHUNK_SHIFT)
-#define ZHDR_SIZE_ALIGNED CHUNK_SIZE
+#define ZHDR_SIZE_ALIGNED round_up(sizeof(struct z3fold_header), CHUNK_SIZE)
+#define ZHDR_CHUNKS	(ZHDR_SIZE_ALIGNED >> CHUNK_SHIFT)
+#define TOTAL_CHUNKS	(PAGE_SIZE >> CHUNK_SHIFT)
 #define NCHUNKS		((PAGE_SIZE - ZHDR_SIZE_ALIGNED) >> CHUNK_SHIFT)
 
 #define BUDDY_MASK	(0x3)
 
-struct z3fold_pool;
-struct z3fold_ops {
-	int (*evict)(struct z3fold_pool *pool, unsigned long handle);
-};
-
 /**
  * struct z3fold_pool - stores metadata for each z3fold pool
  * @lock:	protects all pool fields and first|last_chunk fields of any
@@ -86,33 +117,6 @@ struct z3fold_pool {
 	const struct zpool_ops *zpool_ops;
 };
 
-enum buddy {
-	HEADLESS = 0,
-	FIRST,
-	MIDDLE,
-	LAST,
-	BUDDIES_MAX
-};
-
-/*
- * struct z3fold_header - z3fold page metadata occupying the first chunk of each
- *			z3fold page, except for HEADLESS pages
- * @buddy:	links the z3fold page into the relevant list in the pool
- * @page_lock:		per-page lock
- * @first_chunks:	the size of the first buddy in chunks, 0 if free
- * @middle_chunks:	the size of the middle buddy in chunks, 0 if free
- * @last_chunks:	the size of the last buddy in chunks, 0 if free
- * @first_num:		the starting number (for the first handle)
- */
-struct z3fold_header {
-	struct list_head buddy;
-	raw_spinlock_t page_lock;
-	unsigned short first_chunks;
-	unsigned short middle_chunks;
-	unsigned short last_chunks;
-	unsigned short start_middle;
-	unsigned short first_num:2;
-};
 
 /*
  * Internal z3fold page flags
@@ -123,6 +127,7 @@ enum z3fold_page_flags {
 	MIDDLE_CHUNK_MAPPED,
 };
 
+
 /*****************
  * Helpers
 *****************/
@@ -220,9 +225,10 @@ static int num_free_chunks(struct z3fold_header *zhdr)
 	 */
 	if (zhdr->middle_chunks != 0) {
 		int nfree_before = zhdr->first_chunks ?
-			0 : zhdr->start_middle - 1;
+			0 : zhdr->start_middle - ZHDR_CHUNKS;
 		int nfree_after = zhdr->last_chunks ?
-			0 : NCHUNKS - zhdr->start_middle - zhdr->middle_chunks;
+			0 : TOTAL_CHUNKS -
+				(zhdr->start_middle + zhdr->middle_chunks);
 		nfree = max(nfree_before, nfree_after);
 	} else
 		nfree = NCHUNKS - zhdr->first_chunks - zhdr->last_chunks;
@@ -287,40 +293,47 @@ static int z3fold_compact_page(struct z3fold_header *zhdr)
 	int ret = 0;
 
 	if (test_bit(MIDDLE_CHUNK_MAPPED, &page->private))
+		goto out; /* can't move middle chunk, it's used */
+
+	if (zhdr->middle_chunks == 0)
+		goto out; /* nothing to compact */
+
+	if (zhdr->first_chunks == 0 && zhdr->last_chunks == 0) {
+		/* move to the beginning */
+		mchunk_memmove(zhdr, ZHDR_CHUNKS);
+		zhdr->first_chunks = zhdr->middle_chunks;
+		zhdr->middle_chunks = 0;
+		zhdr->start_middle = 0;
+		zhdr->first_num++;
+		ret = 1;
 		goto out;
+	}
 
-	if (zhdr->middle_chunks != 0) {
-		if (zhdr->first_chunks == 0 && zhdr->last_chunks == 0) {
-			mchunk_memmove(zhdr, 1); /* move to the beginning */
-			zhdr->first_chunks = zhdr->middle_chunks;
-			zhdr->middle_chunks = 0;
-			zhdr->start_middle = 0;
-			zhdr->first_num++;
-			ret = 1;
-			goto out;
-		}
-
-		/*
-		 * moving data is expensive, so let's only do that if
-		 * there's substantial gain (at least BIG_CHUNK_GAP chunks)
-		 */
-		if (zhdr->first_chunks != 0 && zhdr->last_chunks == 0 &&
-		    zhdr->start_middle > zhdr->first_chunks + BIG_CHUNK_GAP) {
-			mchunk_memmove(zhdr, zhdr->first_chunks + 1);
-			zhdr->start_middle = zhdr->first_chunks + 1;
-			ret = 1;
-			goto out;
-		}
-		if (zhdr->last_chunks != 0 && zhdr->first_chunks == 0 &&
-		    zhdr->middle_chunks + zhdr->last_chunks <=
-		    NCHUNKS - zhdr->start_middle - BIG_CHUNK_GAP) {
-			unsigned short new_start = NCHUNKS - zhdr->last_chunks -
-				zhdr->middle_chunks;
-			mchunk_memmove(zhdr, new_start);
-			zhdr->start_middle = new_start;
-			ret = 1;
-			goto out;
-		}
+	/*
+	 * moving data is expensive, so let's only do that if
+	 * there's substantial gain (at least BIG_CHUNK_GAP chunks)
+	 */
+	if (zhdr->first_chunks != 0 && zhdr->last_chunks == 0 &&
+	    zhdr->start_middle - (zhdr->first_chunks + ZHDR_CHUNKS) >=
+	    BIG_CHUNK_GAP) {
+		/* new_start: right after 1st chunk */
+		unsigned short new_start = zhdr->first_chunks + ZHDR_CHUNKS;
+		mchunk_memmove(zhdr, new_start);
+		zhdr->start_middle = new_start;
+		ret = 1;
+		goto out;
+	}
+	if (zhdr->last_chunks != 0 && zhdr->first_chunks == 0 &&
+	    TOTAL_CHUNKS -
+	    (zhdr->last_chunks + zhdr->start_middle + zhdr->middle_chunks) >=
+	    BIG_CHUNK_GAP) {
+		/* new_start: right before last chunk */
+		unsigned short new_start = TOTAL_CHUNKS -
+			(zhdr->last_chunks + zhdr->middle_chunks);
+		mchunk_memmove(zhdr, new_start);
+		zhdr->start_middle = new_start;
+		ret = 1;
+		goto out;
 	}
 out:
 	return ret;
@@ -425,7 +438,7 @@ static int z3fold_alloc(struct z3fold_pool *pool, size_t size, gfp_t gfp,
 		zhdr->last_chunks = chunks;
 	else {
 		zhdr->middle_chunks = chunks;
-		zhdr->start_middle = zhdr->first_chunks + 1;
+		zhdr->start_middle = zhdr->first_chunks + ZHDR_CHUNKS;
 	}
 
 	spin_lock(&pool->lock);
@@ -876,8 +889,8 @@ MODULE_ALIAS("zpool-z3fold");
 
 static int __init init_z3fold(void)
 {
-	/* Make sure the z3fold header will fit in one chunk */
-	BUILD_BUG_ON(sizeof(struct z3fold_header) > ZHDR_SIZE_ALIGNED);
+	/* Make sure the z3fold header is not larger than the page size */
+	BUILD_BUG_ON(ZHDR_SIZE_ALIGNED > PAGE_SIZE);
 	zpool_register_driver(&z3fold_zpool_driver);
 
 	return 0;
-- 
2.4.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
