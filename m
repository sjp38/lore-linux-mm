Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 13F2E6B0039
	for <linux-mm@kvack.org>; Thu,  6 Jun 2013 16:34:40 -0400 (EDT)
From: Glauber Costa <glommer@openvz.org>
Subject: [PATCH v11 07/25] shrinker: convert superblock shrinkers to new API
Date: Fri,  7 Jun 2013 00:34:40 +0400
Message-Id: <1370550898-26711-8-git-send-email-glommer@openvz.org>
In-Reply-To: <1370550898-26711-1-git-send-email-glommer@openvz.org>
References: <1370550898-26711-1-git-send-email-glommer@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-fsdevel@vger.kernel.org, mgorman@suse.de, david@fromorbit.com, linux-mm@kvack.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, mhocko@suze.cz, hannes@cmpxchg.org, hughd@google.com, gthelen@google.com, Dave Chinner <dchinner@redhat.com>, Glauber Costa <glommer@openvz.org>

From: Dave Chinner <dchinner@redhat.com>

Convert superblock shrinker to use the new count/scan API, and
propagate the API changes through to the filesystem callouts. The
filesystem callouts already use a count/scan API, so it's just
changing counters to longs to match the VM API.

This requires the dentry and inode shrinker callouts to be converted
to the count/scan API. This is mainly a mechanical change.

[ v8: fix super_cache_count() return value ]
[ glommer: use mult_frac for fractional proportions, build fixes ]
Signed-off-by: Dave Chinner <dchinner@redhat.com>
Signed-off-by: Glauber Costa <glommer@openvz.org>
Acked-by: Mel Gorman <mgorman@suse.de>
---
 fs/dcache.c         | 10 ++++---
 fs/inode.c          |  7 +++--
 fs/internal.h       |  2 ++
 fs/super.c          | 78 ++++++++++++++++++++++++++++++++---------------------
 fs/xfs/xfs_icache.c |  4 +--
 fs/xfs/xfs_icache.h |  2 +-
 fs/xfs/xfs_super.c  |  8 +++---
 include/linux/fs.h  |  8 ++----
 8 files changed, 69 insertions(+), 50 deletions(-)

diff --git a/fs/dcache.c b/fs/dcache.c
index 16b599e..d7609a0 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -868,11 +868,12 @@ static void shrink_dentry_list(struct list_head *list)
  * This function may fail to free any resources if all the dentries are in
  * use.
  */
-void prune_dcache_sb(struct super_block *sb, int count)
+long prune_dcache_sb(struct super_block *sb, unsigned long nr_to_scan)
 {
 	struct dentry *dentry;
 	LIST_HEAD(referenced);
 	LIST_HEAD(tmp);
+	long freed = 0;
 
 relock:
 	spin_lock(&sb->s_dentry_lru_lock);
@@ -897,7 +898,8 @@ relock:
 			this_cpu_dec(nr_dentry_unused);
 			sb->s_nr_dentry_unused--;
 			spin_unlock(&dentry->d_lock);
-			if (!--count)
+			freed++;
+			if (!--nr_to_scan)
 				break;
 		}
 		cond_resched_lock(&sb->s_dentry_lru_lock);
@@ -907,6 +909,7 @@ relock:
 	spin_unlock(&sb->s_dentry_lru_lock);
 
 	shrink_dentry_list(&tmp);
+	return freed;
 }
 
 /*
@@ -1294,9 +1297,8 @@ rename_retry:
 void shrink_dcache_parent(struct dentry * parent)
 {
 	LIST_HEAD(dispose);
-	int found;
 
-	while ((found = select_parent(parent, &dispose)) != 0) {
+	while (select_parent(parent, &dispose)) {
 		shrink_dentry_list(&dispose);
 		cond_resched();
 	}
diff --git a/fs/inode.c b/fs/inode.c
index ff29765..1ddaa2e 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -704,10 +704,11 @@ static int can_unuse(struct inode *inode)
  * LRU does not have strict ordering. Hence we don't want to reclaim inodes
  * with this flag set because they are the inodes that are out of order.
  */
-void prune_icache_sb(struct super_block *sb, int nr_to_scan)
+long prune_icache_sb(struct super_block *sb, unsigned long nr_to_scan)
 {
 	LIST_HEAD(freeable);
-	int nr_scanned;
+	long nr_scanned;
+	long freed = 0;
 	unsigned long reap = 0;
 
 	spin_lock(&sb->s_inode_lru_lock);
@@ -777,6 +778,7 @@ void prune_icache_sb(struct super_block *sb, int nr_to_scan)
 		list_move(&inode->i_lru, &freeable);
 		sb->s_nr_inodes_unused--;
 		this_cpu_dec(nr_unused);
+		freed++;
 	}
 	if (current_is_kswapd())
 		__count_vm_events(KSWAPD_INODESTEAL, reap);
@@ -787,6 +789,7 @@ void prune_icache_sb(struct super_block *sb, int nr_to_scan)
 		current->reclaim_state->reclaimed_slab += reap;
 
 	dispose_list(&freeable);
+	return freed;
 }
 
 static void __wait_on_freeing_inode(struct inode *inode);
diff --git a/fs/internal.h b/fs/internal.h
index cd5009f..ea43c89 100644
--- a/fs/internal.h
+++ b/fs/internal.h
@@ -110,6 +110,7 @@ extern int open_check_o_direct(struct file *f);
  * inode.c
  */
 extern spinlock_t inode_sb_list_lock;
+extern long prune_icache_sb(struct super_block *sb, unsigned long nr_to_scan);
 extern void inode_add_lru(struct inode *inode);
 
 /*
@@ -125,6 +126,7 @@ extern int invalidate_inodes(struct super_block *, bool);
  * dcache.c
  */
 extern struct dentry *__d_alloc(struct super_block *, const struct qstr *);
+extern long prune_dcache_sb(struct super_block *sb, unsigned long nr_to_scan);
 
 /*
  * read_write.c
diff --git a/fs/super.c b/fs/super.c
index 0be75fb..86801eb 100644
--- a/fs/super.c
+++ b/fs/super.c
@@ -53,11 +53,14 @@ static char *sb_writers_name[SB_FREEZE_LEVELS] = {
  * shrinker path and that leads to deadlock on the shrinker_rwsem. Hence we
  * take a passive reference to the superblock to avoid this from occurring.
  */
-static int prune_super(struct shrinker *shrink, struct shrink_control *sc)
+static long super_cache_scan(struct shrinker *shrink, struct shrink_control *sc)
 {
 	struct super_block *sb;
-	int	fs_objects = 0;
-	int	total_objects;
+	long	fs_objects = 0;
+	long	total_objects;
+	long	freed = 0;
+	long	dentries;
+	long	inodes;
 
 	sb = container_of(shrink, struct super_block, s_shrink);
 
@@ -65,11 +68,11 @@ static int prune_super(struct shrinker *shrink, struct shrink_control *sc)
 	 * Deadlock avoidance.  We may hold various FS locks, and we don't want
 	 * to recurse into the FS that called us in clear_inode() and friends..
 	 */
-	if (sc->nr_to_scan && !(sc->gfp_mask & __GFP_FS))
-		return -1;
+	if (!(sc->gfp_mask & __GFP_FS))
+		return SHRINK_STOP;
 
 	if (!grab_super_passive(sb))
-		return -1;
+		return SHRINK_STOP;
 
 	if (sb->s_op && sb->s_op->nr_cached_objects)
 		fs_objects = sb->s_op->nr_cached_objects(sb);
@@ -77,33 +80,45 @@ static int prune_super(struct shrinker *shrink, struct shrink_control *sc)
 	total_objects = sb->s_nr_dentry_unused +
 			sb->s_nr_inodes_unused + fs_objects + 1;
 
-	if (sc->nr_to_scan) {
-		int	dentries;
-		int	inodes;
-
-		/* proportion the scan between the caches */
-		dentries = mult_frac(sc->nr_to_scan, sb->s_nr_dentry_unused,
-							total_objects);
-		inodes = mult_frac(sc->nr_to_scan, sb->s_nr_inodes_unused,
-							total_objects);
-		if (fs_objects)
-			fs_objects = mult_frac(sc->nr_to_scan, fs_objects,
-							total_objects);
-		/*
-		 * prune the dcache first as the icache is pinned by it, then
-		 * prune the icache, followed by the filesystem specific caches
-		 */
-		prune_dcache_sb(sb, dentries);
-		prune_icache_sb(sb, inodes);
+	/* proportion the scan between the caches */
+	dentries = mult_frac(sc->nr_to_scan, sb->s_nr_dentry_unused,
+								total_objects);
+	inodes = mult_frac(sc->nr_to_scan, sb->s_nr_inodes_unused,
+								total_objects);
 
-		if (fs_objects && sb->s_op->free_cached_objects) {
-			sb->s_op->free_cached_objects(sb, fs_objects);
-			fs_objects = sb->s_op->nr_cached_objects(sb);
-		}
-		total_objects = sb->s_nr_dentry_unused +
-				sb->s_nr_inodes_unused + fs_objects;
+	/*
+	 * prune the dcache first as the icache is pinned by it, then
+	 * prune the icache, followed by the filesystem specific caches
+	 */
+	freed = prune_dcache_sb(sb, dentries);
+	freed += prune_icache_sb(sb, inodes);
+
+	if (fs_objects) {
+		fs_objects = mult_frac(sc->nr_to_scan, fs_objects,
+								total_objects);
+		freed += sb->s_op->free_cached_objects(sb, fs_objects);
 	}
 
+	drop_super(sb);
+	return freed;
+}
+
+static long super_cache_count(struct shrinker *shrink, struct shrink_control *sc)
+{
+	struct super_block *sb;
+	long	total_objects = 0;
+
+	sb = container_of(shrink, struct super_block, s_shrink);
+
+	if (!grab_super_passive(sb))
+		return 0;
+
+	if (sb->s_op && sb->s_op->nr_cached_objects)
+		total_objects = sb->s_op->nr_cached_objects(sb);
+
+	total_objects += sb->s_nr_dentry_unused;
+	total_objects += sb->s_nr_inodes_unused;
+
 	total_objects = vfs_pressure_ratio(total_objects);
 	drop_super(sb);
 	return total_objects;
@@ -217,7 +232,8 @@ static struct super_block *alloc_super(struct file_system_type *type, int flags)
 		s->cleancache_poolid = -1;
 
 		s->s_shrink.seeks = DEFAULT_SEEKS;
-		s->s_shrink.shrink = prune_super;
+		s->s_shrink.scan_objects = super_cache_scan;
+		s->s_shrink.count_objects = super_cache_count;
 		s->s_shrink.batch = 1024;
 	}
 out:
diff --git a/fs/xfs/xfs_icache.c b/fs/xfs/xfs_icache.c
index 96e344e..b35c311 100644
--- a/fs/xfs/xfs_icache.c
+++ b/fs/xfs/xfs_icache.c
@@ -1164,7 +1164,7 @@ xfs_reclaim_inodes(
  * them to be cleaned, which we hope will not be very long due to the
  * background walker having already kicked the IO off on those dirty inodes.
  */
-void
+long
 xfs_reclaim_inodes_nr(
 	struct xfs_mount	*mp,
 	int			nr_to_scan)
@@ -1173,7 +1173,7 @@ xfs_reclaim_inodes_nr(
 	xfs_reclaim_work_queue(mp);
 	xfs_ail_push_all(mp->m_ail);
 
-	xfs_reclaim_inodes_ag(mp, SYNC_TRYLOCK | SYNC_WAIT, &nr_to_scan);
+	return xfs_reclaim_inodes_ag(mp, SYNC_TRYLOCK | SYNC_WAIT, &nr_to_scan);
 }
 
 /*
diff --git a/fs/xfs/xfs_icache.h b/fs/xfs/xfs_icache.h
index e0f138c..2d6d2d3 100644
--- a/fs/xfs/xfs_icache.h
+++ b/fs/xfs/xfs_icache.h
@@ -31,7 +31,7 @@ void xfs_reclaim_worker(struct work_struct *work);
 
 int xfs_reclaim_inodes(struct xfs_mount *mp, int mode);
 int xfs_reclaim_inodes_count(struct xfs_mount *mp);
-void xfs_reclaim_inodes_nr(struct xfs_mount *mp, int nr_to_scan);
+long xfs_reclaim_inodes_nr(struct xfs_mount *mp, int nr_to_scan);
 
 void xfs_inode_set_reclaim_tag(struct xfs_inode *ip);
 
diff --git a/fs/xfs/xfs_super.c b/fs/xfs/xfs_super.c
index 3033ba5..443a8bc 100644
--- a/fs/xfs/xfs_super.c
+++ b/fs/xfs/xfs_super.c
@@ -1534,19 +1534,19 @@ xfs_fs_mount(
 	return mount_bdev(fs_type, flags, dev_name, data, xfs_fs_fill_super);
 }
 
-static int
+static long
 xfs_fs_nr_cached_objects(
 	struct super_block	*sb)
 {
 	return xfs_reclaim_inodes_count(XFS_M(sb));
 }
 
-static void
+static long
 xfs_fs_free_cached_objects(
 	struct super_block	*sb,
-	int			nr_to_scan)
+	long			nr_to_scan)
 {
-	xfs_reclaim_inodes_nr(XFS_M(sb), nr_to_scan);
+	return xfs_reclaim_inodes_nr(XFS_M(sb), nr_to_scan);
 }
 
 static const struct super_operations xfs_super_operations = {
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 41cbe7a..2913d3b 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1327,10 +1327,6 @@ struct super_block {
 	int s_readonly_remount;
 };
 
-/* superblock cache pruning functions */
-extern void prune_icache_sb(struct super_block *sb, int nr_to_scan);
-extern void prune_dcache_sb(struct super_block *sb, int nr_to_scan);
-
 extern struct timespec current_fs_time(struct super_block *sb);
 
 /*
@@ -1617,8 +1613,8 @@ struct super_operations {
 	ssize_t (*quota_write)(struct super_block *, int, const char *, size_t, loff_t);
 #endif
 	int (*bdev_try_to_free_page)(struct super_block*, struct page*, gfp_t);
-	int (*nr_cached_objects)(struct super_block *);
-	void (*free_cached_objects)(struct super_block *, int);
+	long (*nr_cached_objects)(struct super_block *);
+	long (*free_cached_objects)(struct super_block *, long);
 };
 
 /*
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
