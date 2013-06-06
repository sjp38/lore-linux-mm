Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 3F8376B003C
	for <linux-mm@kvack.org>; Thu,  6 Jun 2013 16:34:49 -0400 (EDT)
From: Glauber Costa <glommer@openvz.org>
Subject: [PATCH v11 10/25] dcache: convert to use new lru list infrastructure
Date: Fri,  7 Jun 2013 00:34:43 +0400
Message-Id: <1370550898-26711-11-git-send-email-glommer@openvz.org>
In-Reply-To: <1370550898-26711-1-git-send-email-glommer@openvz.org>
References: <1370550898-26711-1-git-send-email-glommer@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-fsdevel@vger.kernel.org, mgorman@suse.de, david@fromorbit.com, linux-mm@kvack.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, mhocko@suze.cz, hannes@cmpxchg.org, hughd@google.com, gthelen@google.com, Dave Chinner <dchinner@redhat.com>, Glauber Costa <glommer@openvz.org>

From: Dave Chinner <dchinner@redhat.com>

[ glommer: don't reintroduce double decrement of nr_unused_dentries,
  adapted for new LRU return codes ]
Signed-off-by: Dave Chinner <dchinner@redhat.com>
Signed-off-by: Glauber Costa <glommer@openvz.org>
---
 fs/dcache.c        | 165 ++++++++++++++++++++++++-----------------------------
 fs/super.c         |  11 ++--
 include/linux/fs.h |  15 +++--
 3 files changed, 87 insertions(+), 104 deletions(-)

diff --git a/fs/dcache.c b/fs/dcache.c
index d7609a0..00722b3 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -37,6 +37,7 @@
 #include <linux/rculist_bl.h>
 #include <linux/prefetch.h>
 #include <linux/ratelimit.h>
+#include <linux/list_lru.h>
 #include "internal.h"
 #include "mount.h"
 
@@ -331,20 +332,8 @@ static void dentry_unlink_inode(struct dentry * dentry)
  */
 static void dentry_lru_add(struct dentry *dentry)
 {
-	if (list_empty(&dentry->d_lru)) {
-		spin_lock(&dentry->d_sb->s_dentry_lru_lock);
-		list_add(&dentry->d_lru, &dentry->d_sb->s_dentry_lru);
-		dentry->d_sb->s_nr_dentry_unused++;
+	if (list_lru_add(&dentry->d_sb->s_dentry_lru, &dentry->d_lru))
 		this_cpu_inc(nr_dentry_unused);
-		spin_unlock(&dentry->d_sb->s_dentry_lru_lock);
-	}
-}
-
-static void __dentry_lru_del(struct dentry *dentry)
-{
-	list_del_init(&dentry->d_lru);
-	dentry->d_sb->s_nr_dentry_unused--;
-	this_cpu_dec(nr_dentry_unused);
 }
 
 /*
@@ -362,26 +351,8 @@ static void dentry_lru_del(struct dentry *dentry)
 		return;
 	}
 
-	if (!list_empty(&dentry->d_lru)) {
-		spin_lock(&dentry->d_sb->s_dentry_lru_lock);
-		__dentry_lru_del(dentry);
-		spin_unlock(&dentry->d_sb->s_dentry_lru_lock);
-	}
-}
-
-static void dentry_lru_move_list(struct dentry *dentry, struct list_head *list)
-{
-	BUG_ON(dentry->d_flags & DCACHE_SHRINK_LIST);
-
-	spin_lock(&dentry->d_sb->s_dentry_lru_lock);
-	if (list_empty(&dentry->d_lru)) {
-		list_add_tail(&dentry->d_lru, list);
-	} else {
-		list_move_tail(&dentry->d_lru, list);
-		dentry->d_sb->s_nr_dentry_unused--;
+	if (list_lru_del(&dentry->d_sb->s_dentry_lru, &dentry->d_lru))
 		this_cpu_dec(nr_dentry_unused);
-	}
-	spin_unlock(&dentry->d_sb->s_dentry_lru_lock);
 }
 
 /**
@@ -856,12 +827,72 @@ static void shrink_dentry_list(struct list_head *list)
 	rcu_read_unlock();
 }
 
+static enum lru_status
+dentry_lru_isolate(struct list_head *item, spinlock_t *lru_lock, void *arg)
+{
+	struct list_head *freeable = arg;
+	struct dentry	*dentry = container_of(item, struct dentry, d_lru);
+
+
+	/*
+	 * we are inverting the lru lock/dentry->d_lock here,
+	 * so use a trylock. If we fail to get the lock, just skip
+	 * it
+	 */
+	if (!spin_trylock(&dentry->d_lock))
+		return LRU_SKIP;
+
+	/*
+	 * Referenced dentries are still in use. If they have active
+	 * counts, just remove them from the LRU. Otherwise give them
+	 * another pass through the LRU.
+	 */
+	if (dentry->d_count) {
+		list_del_init(&dentry->d_lru);
+		spin_unlock(&dentry->d_lock);
+		return LRU_REMOVED;
+	}
+
+	if (dentry->d_flags & DCACHE_REFERENCED) {
+		dentry->d_flags &= ~DCACHE_REFERENCED;
+		spin_unlock(&dentry->d_lock);
+
+		/*
+		 * The list move itself will be made by the common LRU code. At
+		 * this point, we've dropped the dentry->d_lock but keep the
+		 * lru lock. This is safe to do, since every list movement is
+		 * protected by the lru lock even if both locks are held.
+		 *
+		 * This is guaranteed by the fact that all LRU management
+		 * functions are intermediated by the LRU API calls like
+		 * list_lru_add and list_lru_del. List movement in this file
+		 * only ever occur through this functions or through callbacks
+		 * like this one, that are called from the LRU API.
+		 *
+		 * The only exceptions to this are functions like
+		 * shrink_dentry_list, and code that first checks for the
+		 * DCACHE_SHRINK_LIST flag.  Those are guaranteed to be
+		 * operating only with stack provided lists after they are
+		 * properly isolated from the main list.  It is thus, always a
+		 * local access.
+		 */
+		return LRU_ROTATE;
+	}
+
+	dentry->d_flags |= DCACHE_SHRINK_LIST;
+	list_move_tail(&dentry->d_lru, freeable);
+	this_cpu_dec(nr_dentry_unused);
+	spin_unlock(&dentry->d_lock);
+
+	return LRU_REMOVED;
+}
+
 /**
  * prune_dcache_sb - shrink the dcache
  * @sb: superblock
- * @count: number of entries to try to free
+ * @nr_to_scan : number of entries to try to free
  *
- * Attempt to shrink the superblock dcache LRU by @count entries. This is
+ * Attempt to shrink the superblock dcache LRU by @nr_to_scan entries. This is
  * done when we need more memory an called from the superblock shrinker
  * function.
  *
@@ -870,45 +901,12 @@ static void shrink_dentry_list(struct list_head *list)
  */
 long prune_dcache_sb(struct super_block *sb, unsigned long nr_to_scan)
 {
-	struct dentry *dentry;
-	LIST_HEAD(referenced);
-	LIST_HEAD(tmp);
-	long freed = 0;
-
-relock:
-	spin_lock(&sb->s_dentry_lru_lock);
-	while (!list_empty(&sb->s_dentry_lru)) {
-		dentry = list_entry(sb->s_dentry_lru.prev,
-				struct dentry, d_lru);
-		BUG_ON(dentry->d_sb != sb);
-
-		if (!spin_trylock(&dentry->d_lock)) {
-			spin_unlock(&sb->s_dentry_lru_lock);
-			cpu_relax();
-			goto relock;
-		}
-
-		if (dentry->d_flags & DCACHE_REFERENCED) {
-			dentry->d_flags &= ~DCACHE_REFERENCED;
-			list_move(&dentry->d_lru, &referenced);
-			spin_unlock(&dentry->d_lock);
-		} else {
-			list_move(&dentry->d_lru, &tmp);
-			dentry->d_flags |= DCACHE_SHRINK_LIST;
-			this_cpu_dec(nr_dentry_unused);
-			sb->s_nr_dentry_unused--;
-			spin_unlock(&dentry->d_lock);
-			freed++;
-			if (!--nr_to_scan)
-				break;
-		}
-		cond_resched_lock(&sb->s_dentry_lru_lock);
-	}
-	if (!list_empty(&referenced))
-		list_splice(&referenced, &sb->s_dentry_lru);
-	spin_unlock(&sb->s_dentry_lru_lock);
+	LIST_HEAD(dispose);
+	long freed;
 
-	shrink_dentry_list(&tmp);
+	freed = list_lru_walk(&sb->s_dentry_lru, dentry_lru_isolate,
+			      &dispose, nr_to_scan);
+	shrink_dentry_list(&dispose);
 	return freed;
 }
 
@@ -942,24 +940,10 @@ shrink_dcache_list(
  */
 void shrink_dcache_sb(struct super_block *sb)
 {
-	LIST_HEAD(tmp);
-
-	spin_lock(&sb->s_dentry_lru_lock);
-	while (!list_empty(&sb->s_dentry_lru)) {
-		/*
-		 * account for removal here so we don't need to handle it later
-		 * even though the dentry is no longer on the lru list.
-		 */
-		list_splice_init(&sb->s_dentry_lru, &tmp);
-		this_cpu_sub(nr_dentry_unused, sb->s_nr_dentry_unused);
-		sb->s_nr_dentry_unused = 0;
-		spin_unlock(&sb->s_dentry_lru_lock);
+	long disposed;
 
-		shrink_dcache_list(&tmp);
-
-		spin_lock(&sb->s_dentry_lru_lock);
-	}
-	spin_unlock(&sb->s_dentry_lru_lock);
+	disposed = list_lru_dispose_all(&sb->s_dentry_lru, shrink_dcache_list);
+	this_cpu_sub(nr_dentry_unused, disposed);
 }
 EXPORT_SYMBOL(shrink_dcache_sb);
 
@@ -1232,7 +1216,8 @@ resume:
 		if (dentry->d_count) {
 			dentry_lru_del(dentry);
 		} else if (!(dentry->d_flags & DCACHE_SHRINK_LIST)) {
-			dentry_lru_move_list(dentry, dispose);
+			dentry_lru_del(dentry);
+			list_add_tail(&dentry->d_lru, dispose);
 			dentry->d_flags |= DCACHE_SHRINK_LIST;
 			found++;
 		}
diff --git a/fs/super.c b/fs/super.c
index fea5c44..7fe934d 100644
--- a/fs/super.c
+++ b/fs/super.c
@@ -78,11 +78,11 @@ static long super_cache_scan(struct shrinker *shrink, struct shrink_control *sc)
 		fs_objects = sb->s_op->nr_cached_objects(sb);
 
 	inodes = list_lru_count(&sb->s_inode_lru);
-	total_objects = sb->s_nr_dentry_unused + inodes + fs_objects + 1;
+	dentries = list_lru_count(&sb->s_dentry_lru);
+	total_objects = dentries + inodes + fs_objects + 1;
 
 	/* proportion the scan between the caches */
-	dentries = mult_frac(sc->nr_to_scan, sb->s_nr_dentry_unused,
-								total_objects);
+	dentries = mult_frac(sc->nr_to_scan, dentries, total_objects);
 	inodes = mult_frac(sc->nr_to_scan, inodes, total_objects);
 
 	/*
@@ -115,7 +115,7 @@ static long super_cache_count(struct shrinker *shrink, struct shrink_control *sc
 	if (sb->s_op && sb->s_op->nr_cached_objects)
 		total_objects = sb->s_op->nr_cached_objects(sb);
 
-	total_objects += sb->s_nr_dentry_unused;
+	total_objects += list_lru_count(&sb->s_dentry_lru);
 	total_objects += list_lru_count(&sb->s_inode_lru);
 
 	total_objects = vfs_pressure_ratio(total_objects);
@@ -195,8 +195,7 @@ static struct super_block *alloc_super(struct file_system_type *type, int flags)
 		INIT_HLIST_NODE(&s->s_instances);
 		INIT_HLIST_BL_HEAD(&s->s_anon);
 		INIT_LIST_HEAD(&s->s_inodes);
-		INIT_LIST_HEAD(&s->s_dentry_lru);
-		spin_lock_init(&s->s_dentry_lru_lock);
+		list_lru_init(&s->s_dentry_lru);
 		list_lru_init(&s->s_inode_lru);
 		INIT_LIST_HEAD(&s->s_mounts);
 		init_rwsem(&s->s_umount);
diff --git a/include/linux/fs.h b/include/linux/fs.h
index a50f175..976258f 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1265,14 +1265,6 @@ struct super_block {
 	struct list_head	s_files;
 #endif
 	struct list_head	s_mounts;	/* list of mounts; _not_ for fs use */
-
-	/* s_dentry_lru_lock protects s_dentry_lru and s_nr_dentry_unused */
-	spinlock_t		s_dentry_lru_lock ____cacheline_aligned_in_smp;
-	struct list_head	s_dentry_lru;	/* unused dentry lru */
-	long			s_nr_dentry_unused;	/* # of dentry on lru */
-
-	struct list_lru		s_inode_lru ____cacheline_aligned_in_smp;
-
 	struct block_device	*s_bdev;
 	struct backing_dev_info *s_bdi;
 	struct mtd_info		*s_mtd;
@@ -1323,6 +1315,13 @@ struct super_block {
 
 	/* Being remounted read-only */
 	int s_readonly_remount;
+
+	/*
+	 * Keep the lru lists last in the structure so they always sit on their
+	 * own individual cachelines.
+	 */
+	struct list_lru		s_dentry_lru ____cacheline_aligned_in_smp;
+	struct list_lru		s_inode_lru ____cacheline_aligned_in_smp;
 };
 
 extern struct timespec current_fs_time(struct super_block *sb);
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
