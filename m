Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id AD5306B01F9
	for <linux-mm@kvack.org>; Fri, 14 May 2010 03:24:33 -0400 (EDT)
From: Dave Chinner <david@fromorbit.com>
Subject: [PATCH 3/5] superblock: introduce per-sb cache shrinker infrastructure
Date: Fri, 14 May 2010 17:24:21 +1000
Message-Id: <1273821863-29524-4-git-send-email-david@fromorbit.com>
In-Reply-To: <1273821863-29524-1-git-send-email-david@fromorbit.com>
References: <1273821863-29524-1-git-send-email-david@fromorbit.com>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: xfs@oss.sgi.com, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

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
 fs/dcache.c        |  137 ++++++++--------------------------------------------
 fs/inode.c         |  111 +++---------------------------------------
 fs/super.c         |   48 ++++++++++++++++++
 include/linux/fs.h |    7 +++
 4 files changed, 84 insertions(+), 219 deletions(-)

diff --git a/fs/dcache.c b/fs/dcache.c
index 41c35c1..2d619d3 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -456,21 +456,16 @@ static void prune_one_dentry(struct dentry * dentry)
  * which flags are set. This means we don't need to maintain multiple
  * similar copies of this loop.
  */
-static void __shrink_dcache_sb(struct super_block *sb, int *count, int flags)
+static void __shrink_dcache_sb(struct super_block *sb, int count, int flags)
 {
 	LIST_HEAD(referenced);
 	LIST_HEAD(tmp);
 	struct dentry *dentry;
-	int cnt = 0;
 
 	BUG_ON(!sb);
-	BUG_ON((flags & DCACHE_REFERENCED) && count == NULL);
+	BUG_ON((flags & DCACHE_REFERENCED) && count == -1);
 	spin_lock(&dcache_lock);
-	if (count != NULL)
-		/* called from prune_dcache() and shrink_dcache_parent() */
-		cnt = *count;
-restart:
-	if (count == NULL)
+	if (count == -1)
 		list_splice_init(&sb->s_dentry_lru, &tmp);
 	else {
 		while (!list_empty(&sb->s_dentry_lru)) {
@@ -492,13 +487,13 @@ restart:
 			} else {
 				list_move_tail(&dentry->d_lru, &tmp);
 				spin_unlock(&dentry->d_lock);
-				cnt--;
-				if (!cnt)
+				if (--count == 0)
 					break;
 			}
 			cond_resched_lock(&dcache_lock);
 		}
 	}
+prune_more:
 	while (!list_empty(&tmp)) {
 		dentry = list_entry(tmp.prev, struct dentry, d_lru);
 		dentry_lru_del_init(dentry);
@@ -516,91 +511,30 @@ restart:
 		/* dentry->d_lock was dropped in prune_one_dentry() */
 		cond_resched_lock(&dcache_lock);
 	}
-	if (count == NULL && !list_empty(&sb->s_dentry_lru))
-		goto restart;
-	if (count != NULL)
-		*count = cnt;
+	if (count == -1 && !list_empty(&sb->s_dentry_lru)) {
+		list_splice_init(&sb->s_dentry_lru, &tmp);
+		goto prune_more;
+	}
 	if (!list_empty(&referenced))
 		list_splice(&referenced, &sb->s_dentry_lru);
 	spin_unlock(&dcache_lock);
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
-{
-	struct super_block *sb;
-	int w_count;
-	int unused = dentry_stat.nr_unused;
-	int prune_ratio;
-	int pruned;
 
-	if (unused == 0 || count == 0)
-		return;
-	spin_lock(&dcache_lock);
-restart:
-	if (count >= unused)
-		prune_ratio = 1;
-	else
-		prune_ratio = unused / count;
-	spin_lock(&sb_lock);
-	list_for_each_entry(sb, &super_blocks, s_list) {
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
-				spin_unlock(&dcache_lock);
-				__shrink_dcache_sb(sb, &w_count,
-						DCACHE_REFERENCED);
-				pruned -= w_count;
-				spin_lock(&dcache_lock);
-			}
-			up_read(&sb->s_umount);
-		}
-		spin_lock(&sb_lock);
-		count -= pruned;
-		/*
-		 * restart only when sb is no longer on the list and
-		 * we have more work to do.
-		 */
-		if (__put_super_and_need_restart(sb) && count > 0) {
-			spin_unlock(&sb_lock);
-			goto restart;
-		}
-	}
-	spin_unlock(&sb_lock);
-	spin_unlock(&dcache_lock);
+void prune_dcache_sb(struct super_block *sb, int nr_to_scan)
+{
+	__shrink_dcache_sb(sb, nr_to_scan, DCACHE_REFERENCED);
 }
 
 /**
@@ -613,7 +547,7 @@ restart:
  */
 void shrink_dcache_sb(struct super_block * sb)
 {
-	__shrink_dcache_sb(sb, NULL, 0);
+	__shrink_dcache_sb(sb, -1, 0);
 }
 EXPORT_SYMBOL(shrink_dcache_sb);
 
@@ -881,37 +815,10 @@ void shrink_dcache_parent(struct dentry * parent)
 	int found;
 
 	while ((found = select_parent(parent)) != 0)
-		__shrink_dcache_sb(sb, &found, 0);
+		__shrink_dcache_sb(sb, found, 0);
 }
 EXPORT_SYMBOL(shrink_dcache_parent);
 
-/*
- * Scan `nr' dentries and return the number which remain.
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
-static int shrink_dcache_memory(struct shrinker *shrink, int nr, gfp_t gfp_mask)
-{
-	if (nr) {
-		if (!(gfp_mask & __GFP_FS))
-			return -1;
-		prune_dcache(nr);
-	}
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
@@ -2318,8 +2225,6 @@ static void __init dcache_init(void)
 	 */
 	dentry_cache = KMEM_CACHE(dentry,
 		SLAB_RECLAIM_ACCOUNT|SLAB_PANIC|SLAB_MEM_SPREAD);
-	
-	register_shrinker(&dcache_shrinker);
 
 	/* Hash may have been set up in dcache_init_early */
 	if (!hashdist)
diff --git a/fs/inode.c b/fs/inode.c
index b292e41..ab8ce3a 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -442,8 +442,10 @@ static int can_unuse(struct inode *inode)
 }
 
 /*
- * Scan `goal' inodes on the unused list for freeable ones. They are moved to
- * a temporary list and then are freed outside inode_lock by dispose_list().
+ * Walk the superblock inode LRU for freeable inodes and attempt to free them.
+ * This is called from the superblock shrinker function with a number of inodes
+ * to trim from the LRU. Inodes to be freed are moved to a temporary list and
+ * then are freed outside inode_lock by dispose_list().
  *
  * Any inodes which are pinned purely because of attached pagecache have their
  * pagecache removed.  We expect the final iput() on that inode to add it to
@@ -451,10 +453,10 @@ static int can_unuse(struct inode *inode)
  * inode is still freeable, proceed.  The right inode is found 99.9% of the
  * time in testing on a 4-way.
  *
- * If the inode has metadata buffers attached to mapping->private_list then
- * try to remove them.
+ * If the inode has metadata buffers attached to mapping->private_list then try
+ * to remove them.
  */
-static void shrink_icache_sb(struct super_block *sb, int *nr_to_scan)
+void prune_icache_sb(struct super_block *sb, int nr_to_scan)
 {
 	LIST_HEAD(freeable);
 	int nr_pruned = 0;
@@ -462,7 +464,7 @@ static void shrink_icache_sb(struct super_block *sb, int *nr_to_scan)
 	unsigned long reap = 0;
 
 	spin_lock(&inode_lock);
-	for (nr_scanned = *nr_to_scan; nr_scanned >= 0; nr_scanned--) {
+	for (nr_scanned = nr_to_scan; nr_scanned >= 0; nr_scanned--) {
 		struct inode *inode;
 
 		if (list_empty(&sb->s_inode_lru))
@@ -501,106 +503,10 @@ static void shrink_icache_sb(struct super_block *sb, int *nr_to_scan)
 	else
 		__count_vm_events(PGINODESTEAL, reap);
 	spin_unlock(&inode_lock);
-	*nr_to_scan = nr_scanned;
 
 	dispose_list(&freeable);
 }
 
-static void prune_icache(int count)
-{
-	struct super_block *sb;
-	int w_count;
-	int unused = inodes_stat.nr_unused;
-	int prune_ratio;
-	int pruned;
-
-	if (unused == 0 || count == 0)
-		return;
-	down_read(&iprune_sem);
-restart:
-	if (count >= unused)
-		prune_ratio = 1;
-	else
-		prune_ratio = unused / count;
-	spin_lock(&sb_lock);
-	list_for_each_entry(sb, &super_blocks, s_list) {
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
-		count -= pruned;
-		/*
-		 * restart only when sb is no longer on the list and
-		 * we have more work to do.
-		 */
-		if (__put_super_and_need_restart(sb) && count > 0) {
-			spin_unlock(&sb_lock);
-			goto restart;
-		}
-	}
-	spin_unlock(&sb_lock);
-	up_read(&iprune_sem);
-}
-
-/*
- * shrink_icache_memory() will attempt to reclaim some unused inodes.  Here,
- * "unused" means that no dentries are referring to the inodes: the files are
- * not open and the dcache references to those inodes have already been
- * reclaimed.
- *
- * This function is passed the number of inodes to scan, and it returns the
- * total number of remaining possibly-reclaimable inodes.
- */
-static int shrink_icache_memory(struct shrinker *shrink, int nr, gfp_t gfp_mask)
-{
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
-	return (inodes_stat.nr_unused / 100) * sysctl_vfs_cache_pressure;
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
@@ -1640,7 +1546,6 @@ void __init inode_init(void)
 					 (SLAB_RECLAIM_ACCOUNT|SLAB_PANIC|
 					 SLAB_MEM_SPREAD),
 					 init_once);
-	register_shrinker(&icache_shrinker);
 
 	/* Hash may have been set up in inode_init_early */
 	if (!hashdist)
diff --git a/fs/super.c b/fs/super.c
index 18655e6..339b590 100644
--- a/fs/super.c
+++ b/fs/super.c
@@ -45,6 +45,50 @@
 LIST_HEAD(super_blocks);
 DEFINE_SPINLOCK(sb_lock);
 
+static int prune_super(struct shrinker *shrink, int nr_to_scan, gfp_t gfp_mask)
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
+	if (!(gfp_mask & __GFP_FS))
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
+	if (nr_to_scan) {
+		/* proportion the scan between the two cacheN? */
+		int total;
+
+		total = sb->s_nr_dentry_unused + sb->s_nr_inodes_unused + 1;
+		count = (nr_to_scan * sb->s_nr_dentry_unused) / total;
+
+		/* prune dcache first as icache is pinned by it */
+		prune_dcache_sb(sb, count);
+		prune_icache_sb(sb, nr_to_scan - count);
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
@@ -106,6 +150,9 @@ static struct super_block *alloc_super(struct file_system_type *type)
 		s->s_qcop = sb_quotactl_ops;
 		s->s_op = &default_op;
 		s->s_time_gran = 1000000000;
+		s->s_shrink.shrink = prune_super;
+		s->s_shrink.seeks = DEFAULT_SEEKS;
+		register_shrinker(&s->s_shrink);
 	}
 out:
 	return s;
@@ -119,6 +166,7 @@ out:
  */
 static inline void destroy_super(struct super_block *s)
 {
+	unregister_shrinker(&s->s_shrink);
 	security_sb_free(s);
 	kfree(s->s_subtype);
 	kfree(s->s_options);
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 41132e3..6ba3739 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -382,6 +382,7 @@ struct inodes_stat_t {
 #include <linux/capability.h>
 #include <linux/semaphore.h>
 #include <linux/fiemap.h>
+#include <linux/mm.h>
 
 #include <asm/atomic.h>
 #include <asm/byteorder.h>
@@ -1387,8 +1388,14 @@ struct super_block {
 	 * generic_show_options()
 	 */
 	char *s_options;
+
+	struct shrinker s_shrink;	/* per-sb shrinker handle */
 };
 
+/* superblock cache pruning functions */
+void prune_icache_sb(struct super_block *sb, int nr_to_scan);
+void prune_dcache_sb(struct super_block *sb, int nr_to_scan);
+
 extern struct timespec current_fs_time(struct super_block *sb);
 
 /*
-- 
1.5.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
