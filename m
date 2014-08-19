From: Seth Jennings <sjennings@variantweb.net>
Subject: Re: [PATCH v2 2/4] zsmalloc: change return value unit of
 zs_get_total_size_bytes
Date: Tue, 19 Aug 2014 10:11:57 -0500
Message-ID: <20140819151157.GB26403@cerebellum.variantweb.net>
References: <1408434887-16387-1-git-send-email-minchan@kernel.org>
 <1408434887-16387-3-git-send-email-minchan@kernel.org>
 <20140819144628.GA26403@cerebellum.variantweb.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140819144628.GA26403@cerebellum.variantweb.net>
Sender: linux-kernel-owner@vger.kernel.org
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Jerome Marchand <jmarchan@redhat.com>, juno.choi@lge.com, seungho1.park@lge.com, Luigi Semenzato <semenzato@google.com>, Nitin Gupta <ngupta@vflare.org>, Dan Streetman <ddstreet@ieee.org>, ds2horner@gmail.com
List-Id: linux-mm.kvack.org

On Tue, Aug 19, 2014 at 09:46:28AM -0500, Seth Jennings wrote:
> On Tue, Aug 19, 2014 at 04:54:45PM +0900, Minchan Kim wrote:
> > zs_get_total_size_bytes returns a amount of memory zsmalloc
> > consumed with *byte unit* but zsmalloc operates *page unit*
> > rather than byte unit so let's change the API so benefit
> > we could get is that reduce unnecessary overhead
> > (ie, change page unit with byte unit) in zsmalloc.
> > 
> > Now, zswap can rollback to zswap_pool_pages.
> > Over to zswap guys ;-)
> 
> I don't think that's how is it done :-/  Changing the API for a
> component that has two users, changing one, then saying "hope you guys
> change your newly broken stuff".

However, I'll bite on this one :)  Just squash this in so that
zpool/zswap aren't broken at any point.

Dan, care to make sure I didn't miss something?

Thanks,
Seth

diff --git a/mm/zbud.c b/mm/zbud.c
index a05790b..27a3701 100644
--- a/mm/zbud.c
+++ b/mm/zbud.c
@@ -179,7 +179,7 @@ static void zbud_zpool_unmap(void *pool, unsigned long handle)
 
 static u64 zbud_zpool_total_size(void *pool)
 {
-	return zbud_get_pool_size(pool) * PAGE_SIZE;
+	return zbud_get_pool_size(pool);
 }
 
 static struct zpool_driver zbud_zpool_driver = {
diff --git a/mm/zpool.c b/mm/zpool.c
index e40612a..d126ebc 100644
--- a/mm/zpool.c
+++ b/mm/zpool.c
@@ -336,9 +336,9 @@ void zpool_unmap_handle(struct zpool *zpool, unsigned long handle)
  * zpool_get_total_size() - The total size of the pool
  * @pool	The zpool to check
  *
- * This returns the total size in bytes of the pool.
+ * This returns the total size in pages of the pool.
  *
- * Returns: Total size of the zpool in bytes.
+ * Returns: Total size of the zpool in pages.
  */
 u64 zpool_get_total_size(struct zpool *zpool)
 {
diff --git a/mm/zswap.c b/mm/zswap.c
index ea064c1..124f750 100644
--- a/mm/zswap.c
+++ b/mm/zswap.c
@@ -45,8 +45,8 @@
 /*********************************
 * statistics
 **********************************/
-/* Total bytes used by the compressed storage */
-static u64 zswap_pool_total_size;
+/* Total pages used by the compressed storage */
+static u64 zswap_pool_pages;
 /* The number of compressed pages currently stored in zswap */
 static atomic_t zswap_stored_pages = ATOMIC_INIT(0);
 
@@ -297,7 +297,7 @@ static void zswap_free_entry(struct zswap_entry *entry)
 	zpool_free(zswap_pool, entry->handle);
 	zswap_entry_cache_free(entry);
 	atomic_dec(&zswap_stored_pages);
-	zswap_pool_total_size = zpool_get_total_size(zswap_pool);
+	zswap_pool_pages = zpool_get_total_size(zswap_pool);
 }
 
 /* caller must hold the tree lock */
@@ -414,7 +414,7 @@ cleanup:
 static bool zswap_is_full(void)
 {
 	return totalram_pages * zswap_max_pool_percent / 100 <
-		DIV_ROUND_UP(zswap_pool_total_size, PAGE_SIZE);
+		zswap_pool_pages;
 }
 
 /*********************************
@@ -721,7 +721,7 @@ static int zswap_frontswap_store(unsigned type, pgoff_t offset,
 
 	/* update stats */
 	atomic_inc(&zswap_stored_pages);
-	zswap_pool_total_size = zpool_get_total_size(zswap_pool);
+	zswap_pool_pages = zpool_get_total_size(zswap_pool);
 
 	return 0;
 
@@ -874,8 +874,8 @@ static int __init zswap_debugfs_init(void)
 			zswap_debugfs_root, &zswap_written_back_pages);
 	debugfs_create_u64("duplicate_entry", S_IRUGO,
 			zswap_debugfs_root, &zswap_duplicate_entry);
-	debugfs_create_u64("pool_total_size", S_IRUGO,
-			zswap_debugfs_root, &zswap_pool_total_size);
+	debugfs_create_u64("pool_pages", S_IRUGO,
+			zswap_debugfs_root, &zswap_pool_pages);
 	debugfs_create_atomic_t("stored_pages", S_IRUGO,
 			zswap_debugfs_root, &zswap_stored_pages);
 
