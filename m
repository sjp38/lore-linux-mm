Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id B177C6B009C
	for <linux-mm@kvack.org>; Mon, 18 Oct 2010 23:56:09 -0400 (EDT)
Message-Id: <20101019034655.866685321@kernel.dk>
Date: Tue, 19 Oct 2010 14:42:20 +1100
From: npiggin@kernel.dk
Subject: [patch 04/35] vfs: convert inode and dentry caches to per-zone shrinker
References: <20101019034216.319085068@kernel.dk>
Content-Disposition: inline; filename=vfs-zone-shrinker.patch
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Convert inode and dentry caches to per-zone shrinker API in preparation
for doing proper per-zone cache LRU lists. These two caches tend to be
the most important in the system after the pagecache lrus, so making these
per-zone will help to fix up the funny quirks in vmscan code that tries
to reconcile the whole zone-driven scanning with the global slab reclaim.

Cc: linux-mm@kvack.org
Signed-off-by: Nick Piggin <npiggin@kernel.dk>

---
 fs/dcache.c |   31 ++++++++++++++++++++-----------
 fs/inode.c  |   39 ++++++++++++++++++++++++---------------
 2 files changed, 44 insertions(+), 26 deletions(-)

Index: linux-2.6/fs/dcache.c
===================================================================
--- linux-2.6.orig/fs/dcache.c	2010-10-19 14:35:42.000000000 +1100
+++ linux-2.6/fs/dcache.c	2010-10-19 14:36:53.000000000 +1100
@@ -534,7 +534,7 @@
  *
  * This function may fail to free any resources if all the dentries are in use.
  */
-static void prune_dcache(int count)
+static void prune_dcache(unsigned long count)
 {
 	struct super_block *sb, *p = NULL;
 	int w_count;
@@ -887,7 +887,8 @@
 EXPORT_SYMBOL(shrink_dcache_parent);
 
 /*
- * Scan `nr' dentries and return the number which remain.
+ * shrink_dcache_memory scans and reclaims unused dentries. This function
+ * is defined according to the shrinker API described in linux/mm.h.
  *
  * We need to avoid reentering the filesystem if the caller is performing a
  * GFP_NOFS allocation attempt.  One example deadlock is:
@@ -895,22 +896,30 @@
  * ext2_new_block->getblk->GFP->shrink_dcache_memory->prune_dcache->
  * prune_one_dentry->dput->dentry_iput->iput->inode->i_sb->s_op->put_inode->
  * ext2_discard_prealloc->ext2_free_blocks->lock_super->DEADLOCK.
- *
- * In this case we return -1 to tell the caller that we baled.
  */
-static int shrink_dcache_memory(struct shrinker *shrink, int nr, gfp_t gfp_mask)
+static void shrink_dcache_memory(struct shrinker *shrink,
+		struct zone *zone, unsigned long scanned,
+		unsigned long total, unsigned long global,
+		unsigned long flags, gfp_t gfp_mask)
 {
-	if (nr) {
-		if (!(gfp_mask & __GFP_FS))
-			return -1;
+	static unsigned long nr_to_scan;
+	unsigned long nr;
+
+	shrinker_add_scan(&nr_to_scan, scanned, global,
+			dentry_stat.nr_unused,
+			SHRINK_DEFAULT_SEEKS * 100 / sysctl_vfs_cache_pressure);
+	if (!(gfp_mask & __GFP_FS))
+	       return;
+
+	while ((nr = shrinker_do_scan(&nr_to_scan, SHRINK_BATCH))) {
 		prune_dcache(nr);
+		count_vm_events(SLABS_SCANNED, nr);
+		cond_resched();
 	}
-	return (dentry_stat.nr_unused / 100) * sysctl_vfs_cache_pressure;
 }
 
 static struct shrinker dcache_shrinker = {
-	.shrink = shrink_dcache_memory,
-	.seeks = DEFAULT_SEEKS,
+	.shrink_zone = shrink_dcache_memory,
 };
 
 /**
Index: linux-2.6/fs/inode.c
===================================================================
--- linux-2.6.orig/fs/inode.c	2010-10-19 14:35:42.000000000 +1100
+++ linux-2.6/fs/inode.c	2010-10-19 14:37:05.000000000 +1100
@@ -445,7 +445,7 @@
  * If the inode has metadata buffers attached to mapping->private_list then
  * try to remove them.
  */
-static void prune_icache(int nr_to_scan)
+static void prune_icache(unsigned long nr_to_scan)
 {
 	LIST_HEAD(freeable);
 	int nr_pruned = 0;
@@ -503,27 +503,36 @@
  * not open and the dcache references to those inodes have already been
  * reclaimed.
  *
- * This function is passed the number of inodes to scan, and it returns the
- * total number of remaining possibly-reclaimable inodes.
+ * This function is defined according to shrinker API described in linux/mm.h.
  */
-static int shrink_icache_memory(struct shrinker *shrink, int nr, gfp_t gfp_mask)
+static void shrink_icache_memory(struct shrinker *shrink,
+		struct zone *zone, unsigned long scanned,
+		unsigned long total, unsigned long global,
+		unsigned long flags, gfp_t gfp_mask)
 {
-	if (nr) {
-		/*
-		 * Nasty deadlock avoidance.  We may hold various FS locks,
-		 * and we don't want to recurse into the FS that called us
-		 * in clear_inode() and friends..
-		 */
-		if (!(gfp_mask & __GFP_FS))
-			return -1;
+	static unsigned long nr_to_scan;
+	unsigned long nr;
+
+	shrinker_add_scan(&nr_to_scan, scanned, global,
+			inodes_stat.nr_unused,
+			SHRINK_DEFAULT_SEEKS * 100 / sysctl_vfs_cache_pressure);
+	/*
+	 * Nasty deadlock avoidance.  We may hold various FS locks,
+	 * and we don't want to recurse into the FS that called us
+	 * in clear_inode() and friends..
+	 */
+	if (!(gfp_mask & __GFP_FS))
+	       return;
+
+	while ((nr = shrinker_do_scan(&nr_to_scan, SHRINK_BATCH))) {
 		prune_icache(nr);
+		count_vm_events(SLABS_SCANNED, nr);
+		cond_resched();
 	}
-	return (inodes_stat.nr_unused / 100) * sysctl_vfs_cache_pressure;
 }
 
 static struct shrinker icache_shrinker = {
-	.shrink = shrink_icache_memory,
-	.seeks = DEFAULT_SEEKS,
+	.shrink_zone = shrink_icache_memory,
 };
 
 static void __wait_on_freeing_inode(struct inode *inode);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
