Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 199DF90010B
	for <linux-mm@kvack.org>; Thu,  2 Jun 2011 03:01:49 -0400 (EDT)
From: Dave Chinner <david@fromorbit.com>
Subject: =?UTF-8?q?=5BPATCH=2008/12=5D=20superblock=3A=20introduce=20per-sb=20cache=20shrinker=20infrastructure?=
Date: Thu,  2 Jun 2011 17:01:03 +1000
Message-Id: <1306998067-27659-9-git-send-email-david@fromorbit.com>
In-Reply-To: <1306998067-27659-1-git-send-email-david@fromorbit.com>
References: <1306998067-27659-1-git-send-email-david@fromorbit.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, xfs@oss.sgi.com

From: Dave Chinner <dchinner@redhat.com>

With context based shrinkers, we can implement a per-superblock
shrinker that shrinks the caches attached to the superblock. We
currently have global shrinkers for the inode and dentry caches that
split up into per-superblock operations via a coarse proportioning
method that does not batch very well.  The global shrinkers also
have a dependency - dentries pin inodes - so we have to be very
careful about how we register the global shrinkers so that the
implicit call order is always correct.

With a per-sb shrinker callout, we can encode this dependency
directly into the per-sb shrinker, hence avoiding the need for
strictly ordering shrinker registrations. We also have no need for
any proportioning code for the shrinker subsystem already provides
this functionality across all shrinkers. Allowing the shrinker to
operate on a single superblock at a time means that we do less
superblock list traversals and locking and reclaim should batch more
effectively. This should result in less CPU overhead for reclaim and
potentially faster reclaim of items from each filesystem.

Signed-off-by: Dave Chinner <dchinner@redhat.com>
---
 fs/dcache.c        |  121 +++++----------------------------------------------
 fs/inode.c         |  117 ++++----------------------------------------------
 fs/super.c         |   55 +++++++++++++++++++++++-
 include/linux/fs.h |    7 +++
 4 files changed, 82 insertions(+), 218 deletions(-)

diff --git a/fs/dcache.c b/fs/dcache.c
index 37f72ee..f73ef23 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -720,13 +720,11 @@ static void shrink_dentry_list(struct list_head *list)
  *
  * If flags contains DCACHE_REFERENCED reference dentries will not be pruned.
  */
-static void __shrink_dcache_sb(struct super_block *sb, int *count, int flags)
+static void __shrink_dcache_sb(struct super_block *sb, int count, int flags)
 {
-	/* called from prune_dcache() and shrink_dcache_parent() */
 	struct dentry *dentry;
 	LIST_HEAD(referenced);
 	LIST_HEAD(tmp);
-	int cnt = *count;
 
 relock:
 	spin_lock(&dcache_lru_lock);
@@ -754,7 +752,7 @@ relock:
 		} else {
 			list_move_tail(&dentry->d_lru, &tmp);
 			spin_unlock(&dentry->d_lock);
-			if (!--cnt)
+			if (!--count)
 				break;
 		}
 		cond_resched_lock(&dcache_lru_lock);
@@ -764,83 +762,22 @@ relock:
 	spin_unlock(&dcache_lru_lock);
 
 	shrink_dentry_list(&tmp);
-
-	*count = cnt;
 }
 
 /**
- * prune_dcache - shrink the dcache
- * @count: number of entries to try to free
+ * prune_dcache_sb - shrink the dcache
+ * @nr_to_scan: number of entries to try to free
  *
- * Shrink the dcache. This is done when we need more memory, or simply when we
- * need to unmount something (at which point we need to unuse all dentries).
+ * Attempt to shrink the superblock dcache LRU by @nr_to_scan entries. This is
+ * done when we need more memory an called from the superblock shrinker
+ * function.
  *
- * This function may fail to free any resources if all the dentries are in use.
+ * This function may fail to free any resources if all the dentries are in
+ * use.
  */
-static void prune_dcache(int count)
+void prune_dcache_sb(struct super_block *sb, int nr_to_scan)
 {
-	struct super_block *sb, *p = NULL;
-	int w_count;
-	int unused = dentry_stat.nr_unused;
-	int prune_ratio;
-	int pruned;
-
-	if (unused == 0 || count == 0)
-		return;
-	if (count >= unused)
-		prune_ratio = 1;
-	else
-		prune_ratio = unused / count;
-	spin_lock(&sb_lock);
-	list_for_each_entry(sb, &super_blocks, s_list) {
-		if (list_empty(&sb->s_instances))
-			continue;
-		if (sb->s_nr_dentry_unused == 0)
-			continue;
-		sb->s_count++;
-		/* Now, we reclaim unused dentrins with fairness.
-		 * We reclaim them same percentage from each superblock.
-		 * We calculate number of dentries to scan on this sb
-		 * as follows, but the implementation is arranged to avoid
-		 * overflows:
-		 * number of dentries to scan on this sb =
-		 * count * (number of dentries on this sb /
-		 * number of dentries in the machine)
-		 */
-		spin_unlock(&sb_lock);
-		if (prune_ratio != 1)
-			w_count = (sb->s_nr_dentry_unused / prune_ratio) + 1;
-		else
-			w_count = sb->s_nr_dentry_unused;
-		pruned = w_count;
-		/*
-		 * We need to be sure this filesystem isn't being unmounted,
-		 * otherwise we could race with generic_shutdown_super(), and
-		 * end up holding a reference to an inode while the filesystem
-		 * is unmounted.  So we try to get s_umount, and make sure
-		 * s_root isn't NULL.
-		 */
-		if (down_read_trylock(&sb->s_umount)) {
-			if ((sb->s_root != NULL) &&
-			    (!list_empty(&sb->s_dentry_lru))) {
-				__shrink_dcache_sb(sb, &w_count,
-						DCACHE_REFERENCED);
-				pruned -= w_count;
-			}
-			up_read(&sb->s_umount);
-		}
-		spin_lock(&sb_lock);
-		if (p)
-			__put_super(p);
-		count -= pruned;
-		p = sb;
-		/* more work left to do? */
-		if (count <= 0)
-			break;
-	}
-	if (p)
-		__put_super(p);
-	spin_unlock(&sb_lock);
+	__shrink_dcache_sb(sb, nr_to_scan, DCACHE_REFERENCED);
 }
 
 /**
@@ -1215,42 +1152,10 @@ void shrink_dcache_parent(struct dentry * parent)
 	int found;
 
 	while ((found = select_parent(parent)) != 0)
-		__shrink_dcache_sb(sb, &found, 0);
+		__shrink_dcache_sb(sb, found, 0);
 }
 EXPORT_SYMBOL(shrink_dcache_parent);
 
-/*
- * Scan `sc->nr_slab_to_reclaim' dentries and return the number which remain.
- *
- * We need to avoid reentering the filesystem if the caller is performing a
- * GFP_NOFS allocation attempt.  One example deadlock is:
- *
- * ext2_new_block->getblk->GFP->shrink_dcache_memory->prune_dcache->
- * prune_one_dentry->dput->dentry_iput->iput->inode->i_sb->s_op->put_inode->
- * ext2_discard_prealloc->ext2_free_blocks->lock_super->DEADLOCK.
- *
- * In this case we return -1 to tell the caller that we baled.
- */
-static int shrink_dcache_memory(struct shrinker *shrink,
-				struct shrink_control *sc)
-{
-	int nr = sc->nr_to_scan;
-	gfp_t gfp_mask = sc->gfp_mask;
-
-	if (nr) {
-		if (!(gfp_mask & __GFP_FS))
-			return -1;
-		prune_dcache(nr);
-	}
-
-	return (dentry_stat.nr_unused / 100) * sysctl_vfs_cache_pressure;
-}
-
-static struct shrinker dcache_shrinker = {
-	.shrink = shrink_dcache_memory,
-	.seeks = DEFAULT_SEEKS,
-};
-
 /**
  * d_alloc	-	allocate a dcache entry
  * @parent: parent of entry to allocate
@@ -3030,8 +2935,6 @@ static void __init dcache_init(void)
 	 */
 	dentry_cache = KMEM_CACHE(dentry,
 		SLAB_RECLAIM_ACCOUNT|SLAB_PANIC|SLAB_MEM_SPREAD);
-	
-	register_shrinker(&dcache_shrinker);
 
 	/* Hash may have been set up in dcache_init_early */
 	if (!hashdist)
diff --git a/fs/inode.c b/fs/inode.c
index 667a29c..890d95e 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -73,7 +73,7 @@ __cacheline_aligned_in_smp DEFINE_SPINLOCK(inode_wb_list_lock);
  *
  * We don't actually need it to protect anything in the umount path,
  * but only need to cycle through it to make sure any inode that
- * prune_icache took off the LRU list has been fully torn down by the
+ * prune_icache_sb took off the LRU list has been fully torn down by the
  * time we are past evict_inodes.
  */
 static DECLARE_RWSEM(iprune_sem);
@@ -537,7 +537,7 @@ void evict_inodes(struct super_block *sb)
 	dispose_list(&dispose);
 
 	/*
-	 * Cycle through iprune_sem to make sure any inode that prune_icache
+	 * Cycle through iprune_sem to make sure any inode that prune_icache_sb
 	 * moved off the list before we took the lock has been fully torn
 	 * down.
 	 */
@@ -605,9 +605,10 @@ static int can_unuse(struct inode *inode)
 }
 
 /*
- * Scan `goal' inodes on the unused list for freeable ones. They are moved to a
- * temporary list and then are freed outside sb->s_inode_lru_lock by
- * dispose_list().
+ * Walk the superblock inode LRU for freeable inodes and attempt to free them.
+ * This is called from the superblock shrinker function with a number of inodes
+ * to trim from the LRU. Inodes to be freed are moved to a temporary list and
+ * then are freed outside inode_lock by dispose_list().
  *
  * Any inodes which are pinned purely because of attached pagecache have their
  * pagecache removed.  If the inode has metadata buffers attached to
@@ -621,14 +622,15 @@ static int can_unuse(struct inode *inode)
  * LRU does not have strict ordering. Hence we don't want to reclaim inodes
  * with this flag set because they are the inodes that are out of order.
  */
-static void shrink_icache_sb(struct super_block *sb, int *nr_to_scan)
+void prune_icache_sb(struct super_block *sb, int nr_to_scan)
 {
 	LIST_HEAD(freeable);
 	int nr_scanned;
 	unsigned long reap = 0;
 
+	down_read(&iprune_sem);
 	spin_lock(&sb->s_inode_lru_lock);
-	for (nr_scanned = *nr_to_scan; nr_scanned >= 0; nr_scanned--) {
+	for (nr_scanned = nr_to_scan; nr_scanned >= 0; nr_scanned--) {
 		struct inode *inode;
 
 		if (list_empty(&sb->s_inode_lru))
@@ -700,111 +702,11 @@ static void shrink_icache_sb(struct super_block *sb, int *nr_to_scan)
 	else
 		__count_vm_events(PGINODESTEAL, reap);
 	spin_unlock(&sb->s_inode_lru_lock);
-	*nr_to_scan = nr_scanned;
 
 	dispose_list(&freeable);
-}
-
-static void prune_icache(int count)
-{
-	struct super_block *sb, *p = NULL;
-	int w_count;
-	int unused = inodes_stat.nr_unused;
-	int prune_ratio;
-	int pruned;
-
-	if (unused == 0 || count == 0)
-		return;
-	down_read(&iprune_sem);
-	if (count >= unused)
-		prune_ratio = 1;
-	else
-		prune_ratio = unused / count;
-	spin_lock(&sb_lock);
-	list_for_each_entry(sb, &super_blocks, s_list) {
-		if (list_empty(&sb->s_instances))
-			continue;
-		if (sb->s_nr_inodes_unused == 0)
-			continue;
-		sb->s_count++;
-		/* Now, we reclaim unused dentrins with fairness.
-		 * We reclaim them same percentage from each superblock.
-		 * We calculate number of dentries to scan on this sb
-		 * as follows, but the implementation is arranged to avoid
-		 * overflows:
-		 * number of dentries to scan on this sb =
-		 * count * (number of dentries on this sb /
-		 * number of dentries in the machine)
-		 */
-		spin_unlock(&sb_lock);
-		if (prune_ratio != 1)
-			w_count = (sb->s_nr_inodes_unused / prune_ratio) + 1;
-		else
-			w_count = sb->s_nr_inodes_unused;
-		pruned = w_count;
-		/*
-		 * We need to be sure this filesystem isn't being unmounted,
-		 * otherwise we could race with generic_shutdown_super(), and
-		 * end up holding a reference to an inode while the filesystem
-		 * is unmounted.  So we try to get s_umount, and make sure
-		 * s_root isn't NULL.
-		 */
-		if (down_read_trylock(&sb->s_umount)) {
-			if ((sb->s_root != NULL) &&
-			    (!list_empty(&sb->s_dentry_lru))) {
-				shrink_icache_sb(sb, &w_count);
-				pruned -= w_count;
-			}
-			up_read(&sb->s_umount);
-		}
-		spin_lock(&sb_lock);
-		if (p)
-			__put_super(p);
-		count -= pruned;
-		p = sb;
-		/* more work left to do? */
-		if (count <= 0)
-			break;
-	}
-	if (p)
-		__put_super(p);
-	spin_unlock(&sb_lock);
 	up_read(&iprune_sem);
 }
 
-/*
- * shrink_icache_memory() will attempt to reclaim some unused inodes.  Here,
- * "unused" means that no dentries are referring to the inodes: the files are
- * not open and the dcache references to those inodes have already been
- * reclaimed.
- *
- * This function is passed the number of inodes to scan, and it returns the
- * total number of remaining possibly-reclaimable inodes.
- */
-static int shrink_icache_memory(struct shrinker *shrink,
-				struct shrink_control *sc)
-{
-	int nr = sc->nr_to_scan;
-	gfp_t gfp_mask = sc->gfp_mask;
-
-	if (nr) {
-		/*
-		 * Nasty deadlock avoidance.  We may hold various FS locks,
-		 * and we don't want to recurse into the FS that called us
-		 * in clear_inode() and friends..
-		 */
-		if (!(gfp_mask & __GFP_FS))
-			return -1;
-		prune_icache(nr);
-	}
-	return (get_nr_inodes_unused() / 100) * sysctl_vfs_cache_pressure;
-}
-
-static struct shrinker icache_shrinker = {
-	.shrink = shrink_icache_memory,
-	.seeks = DEFAULT_SEEKS,
-};
-
 static void __wait_on_freeing_inode(struct inode *inode);
 /*
  * Called with the inode lock held.
@@ -1684,7 +1586,6 @@ void __init inode_init(void)
 					 (SLAB_RECLAIM_ACCOUNT|SLAB_PANIC|
 					 SLAB_MEM_SPREAD),
 					 init_once);
-	register_shrinker(&icache_shrinker);
 
 	/* Hash may have been set up in inode_init_early */
 	if (!hashdist)
diff --git a/fs/super.c b/fs/super.c
index 9c3fa1f..f4630d9 100644
--- a/fs/super.c
+++ b/fs/super.c
@@ -38,6 +38,50 @@
 LIST_HEAD(super_blocks);
 DEFINE_SPINLOCK(sb_lock);
 
+static int prune_super(struct shrinker *shrink, struct shrink_control *sc)
+{
+	struct super_block *sb;
+	int count;
+
+	sb = container_of(shrink, struct super_block, s_shrink);
+
+	/*
+	 * Deadlock avoidance.  We may hold various FS locks, and we don't want
+	 * to recurse into the FS that called us in clear_inode() and friends..
+	 */
+	if (sc->nr_to_scan && !(sc->gfp_mask & __GFP_FS))
+		return -1;
+
+	/*
+	 * if we can't get the umount lock, then there's no point having the
+	 * shrinker try again because the sb is being torn down.
+	 */
+	if (!down_read_trylock(&sb->s_umount))
+		return -1;
+
+	if (!sb->s_root) {
+		up_read(&sb->s_umount);
+		return -1;
+	}
+
+	if (sc->nr_to_scan) {
+		/* proportion the scan between the two cacheN? */
+		int total;
+
+		total = sb->s_nr_dentry_unused + sb->s_nr_inodes_unused + 1;
+		count = (sc->nr_to_scan * sb->s_nr_dentry_unused) / total;
+
+		/* prune dcache first as icache is pinned by it */
+		prune_dcache_sb(sb, count);
+		prune_icache_sb(sb, sc->nr_to_scan - count);
+	}
+
+	count = ((sb->s_nr_dentry_unused + sb->s_nr_inodes_unused) / 100)
+						* sysctl_vfs_cache_pressure;
+	up_read(&sb->s_umount);
+	return count;
+}
+
 /**
  *	alloc_super	-	create new superblock
  *	@type:	filesystem type superblock should belong to
@@ -116,6 +160,9 @@ static struct super_block *alloc_super(struct file_system_type *type)
 		s->s_op = &default_op;
 		s->s_time_gran = 1000000000;
 		s->cleancache_poolid = -1;
+
+		s->s_shrink.seeks = DEFAULT_SEEKS;
+		s->s_shrink.shrink = prune_super;
 	}
 out:
 	return s;
@@ -278,7 +325,12 @@ void generic_shutdown_super(struct super_block *sb)
 {
 	const struct super_operations *sop = sb->s_op;
 
-
+	/*
+	 * shut down the shrinker first so we know that there are no possible
+	 * races when shrinking the dcache or icache. Removes the need for
+	 * external locking to prevent such races.
+	 */
+	unregister_shrinker(&sb->s_shrink);
 	if (sb->s_root) {
 		shrink_dcache_for_umount(sb);
 		sync_filesystem(sb);
@@ -366,6 +418,7 @@ retry:
 	list_add(&s->s_instances, &type->fs_supers);
 	spin_unlock(&sb_lock);
 	get_filesystem(type);
+	register_shrinker(&s->s_shrink);
 	return s;
 }
 
diff --git a/include/linux/fs.h b/include/linux/fs.h
index bbd478e..c3b3462 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -391,6 +391,7 @@ struct inodes_stat_t {
 #include <linux/semaphore.h>
 #include <linux/fiemap.h>
 #include <linux/rculist_bl.h>
+#include <linux/mm.h>
 
 #include <asm/atomic.h>
 #include <asm/byteorder.h>
@@ -1440,8 +1441,14 @@ struct super_block {
 	 * Saved pool identifier for cleancache (-1 means none)
 	 */
 	int cleancache_poolid;
+
+	struct shrinker s_shrink;	/* per-sb shrinker handle */
 };
 
+/* superblock cache pruning functions */
+extern void prune_icache_sb(struct super_block *sb, int nr_to_scan);
+extern void prune_dcache_sb(struct super_block *sb, int nr_to_scan);
+
 extern struct timespec current_fs_time(struct super_block *sb);
 
 /*
-- 
1.7.5.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
