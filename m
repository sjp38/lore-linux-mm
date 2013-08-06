Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id 2A21D6B0036
	for <linux-mm@kvack.org>; Tue,  6 Aug 2013 07:37:20 -0400 (EDT)
Received: by mail-pb0-f42.google.com with SMTP id un15so296787pbc.29
        for <linux-mm@kvack.org>; Tue, 06 Aug 2013 04:37:19 -0700 (PDT)
From: Bob Liu <lliubbo@gmail.com>
Subject: [PATCH v2 3/4] mm: zcache: add evict zpages supporting
Date: Tue,  6 Aug 2013 19:36:16 +0800
Message-Id: <1375788977-12105-4-git-send-email-bob.liu@oracle.com>
In-Reply-To: <1375788977-12105-1-git-send-email-bob.liu@oracle.com>
References: <1375788977-12105-1-git-send-email-bob.liu@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: gregkh@linuxfoundation.org, ngupta@vflare.org, akpm@linux-foundation.org, konrad.wilk@oracle.com, sjenning@linux.vnet.ibm.com, riel@redhat.com, mgorman@suse.de, kyungmin.park@samsung.com, p.sarna@partner.samsung.com, barry.song@csr.com, penberg@kernel.org, Bob Liu <bob.liu@oracle.com>

Implemented zbud_ops->evict, so that compressed zpages can be evicted from zbud
memory pool in the case that the compressed pool is full.

zbud already managered the compressed pool based on LRU. The evict was
implemented just by dropping the compressed file page data directly, if the data
is required again then no more disk reading can be saved.

Signed-off-by: Bob Liu <bob.liu@oracle.com>
---
 mm/zcache.c |   53 +++++++++++++++++++++++++++++++++++++++++++++++------
 1 file changed, 47 insertions(+), 6 deletions(-)

diff --git a/mm/zcache.c b/mm/zcache.c
index ec1a0eb..8c3222e 100644
--- a/mm/zcache.c
+++ b/mm/zcache.c
@@ -65,6 +65,9 @@ static u64 zcache_pool_limit_hit;
 static u64 zcache_dup_entry;
 static u64 zcache_zbud_alloc_fail;
 static u64 zcache_pool_pages;
+static u64 zcache_evict_zpages;
+static u64 zcache_evict_filepages;
+static u64 zcache_reclaim_fail;
 static atomic_t zcache_stored_pages = ATOMIC_INIT(0);
 
 /*
@@ -129,6 +132,7 @@ struct zcache_ra_handle {
 	int rb_index;			/* Redblack tree index */
 	int ra_index;			/* Radix tree index */
 	int zlen;			/* Compressed page size */
+	struct zcache_pool *zpool;	/* Finding zcache_pool during evict */
 };
 
 static struct kmem_cache *zcache_rbnode_cache;
@@ -493,7 +497,16 @@ static void zcache_store_page(int pool_id, struct cleancache_filekey key,
 
 	if (zcache_is_full()) {
 		zcache_pool_limit_hit++;
-		return;
+		if (zbud_reclaim_page(zpool->pool, 8)) {
+			zcache_reclaim_fail++;
+			return;
+		} else {
+			/*
+			 * Continue if eclaimed a page frame succ.
+			 */
+			zcache_evict_filepages++;
+			zcache_pool_pages = zbud_get_pool_size(zpool->pool);
+		}
 	}
 
 	/* compress */
@@ -521,6 +534,8 @@ static void zcache_store_page(int pool_id, struct cleancache_filekey key,
 	zhandle->ra_index = index;
 	zhandle->rb_index = key.u.ino;
 	zhandle->zlen = zlen;
+	zhandle->zpool = zpool;
+
 	/* Compressed page data stored at the end of zcache_ra_handle */
 	zpage = (u8 *)(zhandle + 1);
 	memcpy(zpage, dst, zlen);
@@ -692,16 +707,36 @@ static void zcache_flush_fs(int pool_id)
 }
 
 /*
- * Evict pages from zcache pool on an LRU basis after the compressed pool is
- * full.
+ * Evict compressed pages from zcache pool on an LRU basis after the compressed
+ * pool is full.
  */
-static int zcache_evict_entry(struct zbud_pool *pool, unsigned long zaddr)
+static int zcache_evict_zpage(struct zbud_pool *pool, unsigned long zaddr)
 {
-	return -1;
+	struct zcache_pool *zpool;
+	struct zcache_ra_handle *zhandle;
+	void *zaddr_intree;
+
+	zhandle = (struct zcache_ra_handle *)zbud_map(pool, zaddr);
+
+	zpool = zhandle->zpool;
+	BUG_ON(!zpool);
+	BUG_ON(pool != zpool->pool);
+
+	zaddr_intree = zcache_load_delete_zaddr(zpool, zhandle->rb_index,
+			zhandle->ra_index);
+	if (zaddr_intree) {
+		BUG_ON((unsigned long)zaddr_intree != zaddr);
+		zbud_unmap(pool, zaddr);
+		zbud_free(pool, zaddr);
+		atomic_dec(&zcache_stored_pages);
+		zcache_pool_pages = zbud_get_pool_size(pool);
+		zcache_evict_zpages++;
+	}
+	return 0;
 }
 
 static struct zbud_ops zcache_zbud_ops = {
-	.evict = zcache_evict_entry
+	.evict = zcache_evict_zpage
 };
 
 /* Return pool id */
@@ -832,6 +867,12 @@ static int __init zcache_debugfs_init(void)
 			&zcache_pool_pages);
 	debugfs_create_atomic_t("stored_pages", S_IRUGO, zcache_debugfs_root,
 			&zcache_stored_pages);
+	debugfs_create_u64("evicted_zpages", S_IRUGO, zcache_debugfs_root,
+			&zcache_evict_zpages);
+	debugfs_create_u64("evicted_filepages", S_IRUGO, zcache_debugfs_root,
+			&zcache_evict_filepages);
+	debugfs_create_u64("reclaim_fail", S_IRUGO, zcache_debugfs_root,
+			&zcache_reclaim_fail);
 	return 0;
 }
 
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
