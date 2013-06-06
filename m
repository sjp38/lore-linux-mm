Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id A89F26B0062
	for <linux-mm@kvack.org>; Thu,  6 Jun 2013 16:35:06 -0400 (EDT)
From: Glauber Costa <glommer@openvz.org>
Subject: [PATCH v11 15/25] fs: convert inode and dentry shrinking to be node aware
Date: Fri,  7 Jun 2013 00:34:48 +0400
Message-Id: <1370550898-26711-16-git-send-email-glommer@openvz.org>
In-Reply-To: <1370550898-26711-1-git-send-email-glommer@openvz.org>
References: <1370550898-26711-1-git-send-email-glommer@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-fsdevel@vger.kernel.org, mgorman@suse.de, david@fromorbit.com, linux-mm@kvack.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, mhocko@suze.cz, hannes@cmpxchg.org, hughd@google.com, gthelen@google.com, Dave Chinner <dchinner@redhat.com>, Glauber Costa <glommer@parallels.com>

From: Dave Chinner <dchinner@redhat.com>

Now that the shrinker is passing a node in the scan control
structure, we can pass this to the the generic LRU list code to
isolate reclaim to the lists on matching nodes.

v7: refactoring of the LRU list API in a separate patch
Signed-off-by: Dave Chinner <dchinner@redhat.com>
Signed-off-by: Glauber Costa <glommer@parallels.com>
Acked-by: Mel Gorman <mgorman@suse.de>
---
 fs/dcache.c        |  8 +++++---
 fs/inode.c         |  7 ++++---
 fs/internal.h      |  6 ++++--
 fs/super.c         | 23 ++++++++++++++---------
 fs/xfs/xfs_super.c |  6 ++++--
 include/linux/fs.h |  4 ++--
 6 files changed, 33 insertions(+), 21 deletions(-)

diff --git a/fs/dcache.c b/fs/dcache.c
index 00722b3..d3feea1 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -891,6 +891,7 @@ dentry_lru_isolate(struct list_head *item, spinlock_t *lru_lock, void *arg)
  * prune_dcache_sb - shrink the dcache
  * @sb: superblock
  * @nr_to_scan : number of entries to try to free
+ * @nid: which node to scan for freeable entities
  *
  * Attempt to shrink the superblock dcache LRU by @nr_to_scan entries. This is
  * done when we need more memory an called from the superblock shrinker
@@ -899,13 +900,14 @@ dentry_lru_isolate(struct list_head *item, spinlock_t *lru_lock, void *arg)
  * This function may fail to free any resources if all the dentries are in
  * use.
  */
-long prune_dcache_sb(struct super_block *sb, unsigned long nr_to_scan)
+long prune_dcache_sb(struct super_block *sb, unsigned long nr_to_scan,
+		     int nid)
 {
 	LIST_HEAD(dispose);
 	long freed;
 
-	freed = list_lru_walk(&sb->s_dentry_lru, dentry_lru_isolate,
-			      &dispose, nr_to_scan);
+	freed = list_lru_walk_node(&sb->s_dentry_lru, nid, dentry_lru_isolate,
+				       &dispose, &nr_to_scan);
 	shrink_dentry_list(&dispose);
 	return freed;
 }
diff --git a/fs/inode.c b/fs/inode.c
index 5d85521..00b804e 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -746,13 +746,14 @@ inode_lru_isolate(struct list_head *item, spinlock_t *lru_lock, void *arg)
  * to trim from the LRU. Inodes to be freed are moved to a temporary list and
  * then are freed outside inode_lock by dispose_list().
  */
-long prune_icache_sb(struct super_block *sb, unsigned long nr_to_scan)
+long prune_icache_sb(struct super_block *sb, unsigned long nr_to_scan,
+		     int nid)
 {
 	LIST_HEAD(freeable);
 	long freed;
 
-	freed = list_lru_walk(&sb->s_inode_lru, inode_lru_isolate,
-						&freeable, nr_to_scan);
+	freed = list_lru_walk_node(&sb->s_inode_lru, nid, inode_lru_isolate,
+				       &freeable, &nr_to_scan);
 	dispose_list(&freeable);
 	return freed;
 }
diff --git a/fs/internal.h b/fs/internal.h
index ea43c89..8902d56 100644
--- a/fs/internal.h
+++ b/fs/internal.h
@@ -110,7 +110,8 @@ extern int open_check_o_direct(struct file *f);
  * inode.c
  */
 extern spinlock_t inode_sb_list_lock;
-extern long prune_icache_sb(struct super_block *sb, unsigned long nr_to_scan);
+extern long prune_icache_sb(struct super_block *sb, unsigned long nr_to_scan,
+			    int nid);
 extern void inode_add_lru(struct inode *inode);
 
 /*
@@ -126,7 +127,8 @@ extern int invalidate_inodes(struct super_block *, bool);
  * dcache.c
  */
 extern struct dentry *__d_alloc(struct super_block *, const struct qstr *);
-extern long prune_dcache_sb(struct super_block *sb, unsigned long nr_to_scan);
+extern long prune_dcache_sb(struct super_block *sb, unsigned long nr_to_scan,
+			    int nid);
 
 /*
  * read_write.c
diff --git a/fs/super.c b/fs/super.c
index 7fe934d..85a6104 100644
--- a/fs/super.c
+++ b/fs/super.c
@@ -75,10 +75,10 @@ static long super_cache_scan(struct shrinker *shrink, struct shrink_control *sc)
 		return SHRINK_STOP;
 
 	if (sb->s_op && sb->s_op->nr_cached_objects)
-		fs_objects = sb->s_op->nr_cached_objects(sb);
+		fs_objects = sb->s_op->nr_cached_objects(sb, sc->nid);
 
-	inodes = list_lru_count(&sb->s_inode_lru);
-	dentries = list_lru_count(&sb->s_dentry_lru);
+	inodes = list_lru_count_node(&sb->s_inode_lru, sc->nid);
+	dentries = list_lru_count_node(&sb->s_dentry_lru, sc->nid);
 	total_objects = dentries + inodes + fs_objects + 1;
 
 	/* proportion the scan between the caches */
@@ -89,13 +89,14 @@ static long super_cache_scan(struct shrinker *shrink, struct shrink_control *sc)
 	 * prune the dcache first as the icache is pinned by it, then
 	 * prune the icache, followed by the filesystem specific caches
 	 */
-	freed = prune_dcache_sb(sb, dentries);
-	freed += prune_icache_sb(sb, inodes);
+	freed = prune_dcache_sb(sb, dentries, sc->nid);
+	freed += prune_icache_sb(sb, inodes, sc->nid);
 
 	if (fs_objects) {
 		fs_objects = mult_frac(sc->nr_to_scan, fs_objects,
 								total_objects);
-		freed += sb->s_op->free_cached_objects(sb, fs_objects);
+		freed += sb->s_op->free_cached_objects(sb, fs_objects,
+						       sc->nid);
 	}
 
 	drop_super(sb);
@@ -113,10 +114,13 @@ static long super_cache_count(struct shrinker *shrink, struct shrink_control *sc
 		return 0;
 
 	if (sb->s_op && sb->s_op->nr_cached_objects)
-		total_objects = sb->s_op->nr_cached_objects(sb);
+		total_objects = sb->s_op->nr_cached_objects(sb,
+						 sc->nid);
 
-	total_objects += list_lru_count(&sb->s_dentry_lru);
-	total_objects += list_lru_count(&sb->s_inode_lru);
+	total_objects += list_lru_count_node(&sb->s_dentry_lru,
+						 sc->nid);
+	total_objects += list_lru_count_node(&sb->s_inode_lru,
+						 sc->nid);
 
 	total_objects = vfs_pressure_ratio(total_objects);
 	drop_super(sb);
@@ -232,6 +236,7 @@ static struct super_block *alloc_super(struct file_system_type *type, int flags)
 		s->s_shrink.scan_objects = super_cache_scan;
 		s->s_shrink.count_objects = super_cache_count;
 		s->s_shrink.batch = 1024;
+		s->s_shrink.flags = SHRINKER_NUMA_AWARE;
 	}
 out:
 	return s;
diff --git a/fs/xfs/xfs_super.c b/fs/xfs/xfs_super.c
index 443a8bc..ec2b267 100644
--- a/fs/xfs/xfs_super.c
+++ b/fs/xfs/xfs_super.c
@@ -1536,7 +1536,8 @@ xfs_fs_mount(
 
 static long
 xfs_fs_nr_cached_objects(
-	struct super_block	*sb)
+	struct super_block	*sb,
+	int			nid)
 {
 	return xfs_reclaim_inodes_count(XFS_M(sb));
 }
@@ -1544,7 +1545,8 @@ xfs_fs_nr_cached_objects(
 static long
 xfs_fs_free_cached_objects(
 	struct super_block	*sb,
-	long			nr_to_scan)
+	long			nr_to_scan,
+	int			nid)
 {
 	return xfs_reclaim_inodes_nr(XFS_M(sb), nr_to_scan);
 }
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 976258f..610955f 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1610,8 +1610,8 @@ struct super_operations {
 	ssize_t (*quota_write)(struct super_block *, int, const char *, size_t, loff_t);
 #endif
 	int (*bdev_try_to_free_page)(struct super_block*, struct page*, gfp_t);
-	long (*nr_cached_objects)(struct super_block *);
-	long (*free_cached_objects)(struct super_block *, long);
+	long (*nr_cached_objects)(struct super_block *, int);
+	long (*free_cached_objects)(struct super_block *, long, int);
 };
 
 /*
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
