Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 729046B0279
	for <linux-mm@kvack.org>; Sun,  2 Jul 2017 10:20:04 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id j79so172449392pfj.9
        for <linux-mm@kvack.org>; Sun, 02 Jul 2017 07:20:04 -0700 (PDT)
Received: from mailout4.samsung.com (mailout4.samsung.com. [203.254.224.34])
        by mx.google.com with ESMTPS id s23si4120216plk.186.2017.07.02.07.20.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 02 Jul 2017 07:20:03 -0700 (PDT)
Received: from epcas5p4.samsung.com (unknown [182.195.41.42])
	by mailout4.samsung.com (KnoxPortal) with ESMTP id 20170702142000epoutp048489742259cdcc7a041671dcc3fcb717~NiUnE1DHF2216222162epoutp04U
	for <linux-mm@kvack.org>; Sun,  2 Jul 2017 14:20:00 +0000 (GMT)
Mime-Version: 1.0
Subject: [PATCH v2] zswap: Zero-filled pages handling
Reply-To: srividya.dr@samsung.com
From: Srividya Desireddy <srividya.dr@samsung.com>
Message-ID: <20170702141959epcms5p32119c772b960e942da3a92e5a79d8c41@epcms5p3>
Date: Sun, 02 Jul 2017 14:19:59 +0000
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset="utf-8"
References: <CGME20170702141959epcms5p32119c772b960e942da3a92e5a79d8c41@epcms5p3>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "sjenning@redhat.com" <sjenning@redhat.com>, "ddstreet@ieee.org" <ddstreet@ieee.org>, "penberg@kernel.org" <penberg@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Cc: Dinakar Reddy Pathireddy <dinakar.p@samsung.com>, SHARAN ALLUR <sharan.allur@samsung.com>, SUNEEL KUMAR SURIMANI <suneel@samsung.com>, JUHUN KIM <juhunkim@samsung.com>, "srividya.desireddy@gmail.com" <srividya.desireddy@gmail.com>

From: Srividya Desireddy <srividya.dr@samsung.com>
Date: Sun, 2 Jul 2017 19:15:37 +0530
Subject: [PATCH v2] zswap: Zero-filled pages handling

Zswap is a cache which compresses the pages that are being swapped out
and stores them into a dynamically allocated RAM-based memory pool.
Experiments have shown that around 10-20% of pages stored in zswap
are zero-filled pages (i.e. contents of the page are all zeros), but
these pages are handled as normal pages by compressing and allocating
memory in the pool.

This patch adds a check in zswap_frontswap_store() to identify zero-filled
page before compression of the page. If the page is a zero-filled page, set
zswap_entry.zeroflag and skip the compression of the page and alloction
of memory in zpool. In zswap_frontswap_load(), check if the zeroflag is
set for the page in zswap_entry. If the flag is set, memset the page with
zero. This saves the decompression time during load.

On Ubuntu PC with 2GB RAM, while executing kernel build and other test
scripts ~15% of pages in zswap were zero pages. With multimedia workload
more than 20% of zswap pages were found to be zero pages.

On a ARM Quad Core 32-bit device with 1.5GB RAM an average 10% of zero
pages were found in zswap (an average of 5000 zero pages found out of
~50000 pages stored in zswap) on launching and relaunching 15 applications.
The launch time of the applications improved by ~3%.

Test Parameters		Baseline    With patch  Improvement
-----------------------------------------------------------
Total RAM               1343MB      1343MB
Available RAM           451MB       445MB         -6MB
Avg. Memfree            69MB        70MB          1MB
Avg. Swap Used          226MB       215MB         -11MB
Avg. App entry time     644msec     623msec       3%

With patch, every page swapped to zswap is checked if it is a zero
page or not and for all the zero pages compression and memory allocation
operations are skipped. Overall there is an improvement of 30% in zswap
store time.

In case of non-zero pages there is no overhead during zswap page load. For
zero pages there is a improvement of more than 60% in the zswap load time
as the zero page decompression is avoided.
The below table shows the execution time profiling of the patch.

Zswap Store Operation     Baseline    With patch  % Improvement
--------------------------------------------------------------
* Zero page check            --         22.5ms
 (for non-zero pages)
* Zero page check            --         24ms
 (for zero pages)
* Compression time          55ms         --
 (of zero pages)
* Allocation time           14ms         --
 (to store compressed
  zero pages)
-------------------------------------------------------------
Total                       69ms        46.5ms         32%

Zswap Load Operation     Baseline    With patch  % Improvement
-------------------------------------------------------------
* Decompression time      30.4ms        --
 (of zero pages)
* Zero page check +        --         10.04ms
 memset operation
 (of zero pages)
-------------------------------------------------------------
Total                     30.4ms      10.04ms       66%

*The execution times may vary with test device used.

Signed-off-by: Srividya Desireddy <srividya.dr@samsung.com>
---
 mm/zswap.c |   46 ++++++++++++++++++++++++++++++++++++++++++----
 1 file changed, 42 insertions(+), 4 deletions(-)

diff --git a/mm/zswap.c b/mm/zswap.c
index eedc278..edc584b 100644
--- a/mm/zswap.c
+++ b/mm/zswap.c
@@ -49,6 +49,8 @@
 static u64 zswap_pool_total_size;
 /* The number of compressed pages currently stored in zswap */
 static atomic_t zswap_stored_pages = ATOMIC_INIT(0);
+/* The number of zero filled pages swapped out to zswap */
+static atomic_t zswap_zero_pages = ATOMIC_INIT(0);
 
 /*
  * The statistics below are not protected from concurrent access for
@@ -145,7 +147,7 @@ struct zswap_pool {
  *            be held while changing the refcount.  Since the lock must
  *            be held, there is no reason to also make refcount atomic.
  * length - the length in bytes of the compressed page data.  Needed during
- *          decompression
+ *          decompression. For a zero page length is 0.
  * pool - the zswap_pool the entry's data is in
  * handle - zpool allocation handle that stores the compressed page data
  */
@@ -320,8 +322,12 @@ static void zswap_rb_erase(struct rb_root *root, struct zswap_entry *entry)
  */
 static void zswap_free_entry(struct zswap_entry *entry)
 {
-	zpool_free(entry->pool->zpool, entry->handle);
-	zswap_pool_put(entry->pool);
+	if (!entry->length)
+		atomic_dec(&zswap_zero_pages);
+	else {
+		zpool_free(entry->pool->zpool, entry->handle);
+		zswap_pool_put(entry->pool);
+	}
 	zswap_entry_cache_free(entry);
 	atomic_dec(&zswap_stored_pages);
 	zswap_update_total_size();
@@ -956,6 +962,19 @@ static int zswap_shrink(void)
 	return ret;
 }
 
+static int zswap_is_page_zero_filled(void *ptr)
+{
+	unsigned int pos;
+	unsigned long *page;
+
+	page = (unsigned long *)ptr;
+	for (pos = 0; pos != PAGE_SIZE / sizeof(*page); pos++) {
+		if (page[pos])
+			return 0;
+	}
+	return 1;
+}
+
 /*********************************
 * frontswap hooks
 **********************************/
@@ -996,6 +1015,15 @@ static int zswap_frontswap_store(unsigned type, pgoff_t offset,
 		goto reject;
 	}
 
+	src = kmap_atomic(page);
+	if (zswap_is_page_zero_filled(src)) {
+		kunmap_atomic(src);
+		entry->offset = offset;
+		entry->length = 0;
+		atomic_inc(&zswap_zero_pages);
+		goto insert_entry;
+	}
+
 	/* if entry is successfully added, it keeps the reference */
 	entry->pool = zswap_pool_current_get();
 	if (!entry->pool) {
@@ -1006,7 +1034,6 @@ static int zswap_frontswap_store(unsigned type, pgoff_t offset,
 	/* compress */
 	dst = get_cpu_var(zswap_dstmem);
 	tfm = *get_cpu_ptr(entry->pool->tfm);
-	src = kmap_atomic(page);
 	ret = crypto_comp_compress(tfm, src, PAGE_SIZE, dst, &dlen);
 	kunmap_atomic(src);
 	put_cpu_ptr(entry->pool->tfm);
@@ -1040,6 +1067,7 @@ static int zswap_frontswap_store(unsigned type, pgoff_t offset,
 	entry->handle = handle;
 	entry->length = dlen;
 
+insert_entry:
 	/* map */
 	spin_lock(&tree->lock);
 	do {
@@ -1092,6 +1120,13 @@ static int zswap_frontswap_load(unsigned type, pgoff_t offset,
 	}
 	spin_unlock(&tree->lock);
 
+	if (!entry->length) {
+		dst = kmap_atomic(page);
+		memset(dst, 0, PAGE_SIZE);
+		kunmap_atomic(dst);
+		goto freeentry;
+	}
+
 	/* decompress */
 	dlen = PAGE_SIZE;
 	src = (u8 *)zpool_map_handle(entry->pool->zpool, entry->handle,
@@ -1104,6 +1139,7 @@ static int zswap_frontswap_load(unsigned type, pgoff_t offset,
 	zpool_unmap_handle(entry->pool->zpool, entry->handle);
 	BUG_ON(ret);
 
+freeentry:
 	spin_lock(&tree->lock);
 	zswap_entry_put(tree, entry);
 	spin_unlock(&tree->lock);
@@ -1212,6 +1248,8 @@ static int __init zswap_debugfs_init(void)
 			zswap_debugfs_root, &zswap_pool_total_size);
 	debugfs_create_atomic_t("stored_pages", S_IRUGO,
 			zswap_debugfs_root, &zswap_stored_pages);
+	debugfs_create_atomic_t("zero_pages", 0444,
+			zswap_debugfs_root, &zswap_zero_pages);
 
 	return 0;
 }
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
