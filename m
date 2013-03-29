Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id CC3226B0006
	for <linux-mm@kvack.org>; Fri, 29 Mar 2013 05:14:18 -0400 (EDT)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH v2 10/28] dcache: convert to use new lru list infrastructure
Date: Fri, 29 Mar 2013 13:13:52 +0400
Message-Id: <1364548450-28254-11-git-send-email-glommer@parallels.com>
In-Reply-To: <1364548450-28254-1-git-send-email-glommer@parallels.com>
References: <1364548450-28254-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-fsdevel@vger.kernel.org, containers@lists.linux-foundation.org, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, kamezawa.hiroyu@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Dave Shrinnker <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, hughd@google.com, yinghan@google.com, Dave Chinner <dchinner@redhat.com>

From: Dave Chinner <dchinner@redhat.com>

Signed-off-by: Dave Chinner <dchinner@redhat.com>
---
 fs/dcache.c        | 171 ++++++++++++++++++++++-------------------------------
 fs/super.c         |  11 ++--
 include/linux/fs.h |  15 +++--
 3 files changed, 82 insertions(+), 115 deletions(-)

diff --git a/fs/dcache.c b/fs/dcache.c
index 2c9fcd6..b59d341 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -37,6 +37,7 @@
 #include <linux/rculist_bl.h>
 #include <linux/prefetch.h>
 #include <linux/ratelimit.h>
+#include <linux/list_lru.h>
 #include "internal.h"
 #include "mount.h"
 
@@ -318,20 +319,8 @@ static void dentry_unlink_inode(struct dentry * dentry)
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
@@ -341,11 +330,8 @@ static void dentry_lru_del(struct dentry *dentry)
 {
 	BUG_ON(dentry->d_flags & DCACHE_SHRINK_LIST);
 
-	if (!list_empty(&dentry->d_lru)) {
-		spin_lock(&dentry->d_sb->s_dentry_lru_lock);
-		__dentry_lru_del(dentry);
-		spin_unlock(&dentry->d_sb->s_dentry_lru_lock);
-	}
+	if (list_lru_del(&dentry->d_sb->s_dentry_lru, &dentry->d_lru))
+		this_cpu_dec(nr_dentry_unused);
 }
 
 /*
@@ -361,35 +347,19 @@ static void dentry_lru_del(struct dentry *dentry)
  */
 static void dentry_lru_prune(struct dentry *dentry)
 {
-	if (!list_empty(&dentry->d_lru)) {
+	int prune = dentry->d_flags & DCACHE_OP_PRUNE;
 
-		if (dentry->d_flags & DCACHE_OP_PRUNE)
-			dentry->d_op->d_prune(dentry);
-
-		if ((dentry->d_flags & DCACHE_SHRINK_LIST))
-			list_del_init(&dentry->d_lru);
-		else {
-			spin_lock(&dentry->d_sb->s_dentry_lru_lock);
-			__dentry_lru_del(dentry);
-			spin_unlock(&dentry->d_sb->s_dentry_lru_lock);
-		}
-		dentry->d_flags &= ~DCACHE_SHRINK_LIST;
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
+	if (!list_empty(&dentry->d_lru) &&
+	    (dentry->d_flags & DCACHE_SHRINK_LIST))
+		list_del_init(&dentry->d_lru);
+	else if (list_lru_del(&dentry->d_sb->s_dentry_lru, &dentry->d_lru))
 		this_cpu_dec(nr_dentry_unused);
-	}
-	spin_unlock(&dentry->d_sb->s_dentry_lru_lock);
+	else
+		prune = 0;
+
+	dentry->d_flags &= ~DCACHE_SHRINK_LIST;
+	if (prune)
+		dentry->d_op->d_prune(dentry);
 }
 
 /**
@@ -854,6 +824,51 @@ static void shrink_dentry_list(struct list_head *list)
 	rcu_read_unlock();
 }
 
+static int dentry_lru_isolate(struct list_head *item, spinlock_t *lru_lock,
+				void *arg)
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
+		return 2;
+
+	/*
+	 * Referenced dentries are still in use. If they have active
+	 * counts, just remove them from the LRU. Otherwise give them
+	 * another pass through the LRU.
+	 */
+	if (dentry->d_count) {
+		list_del_init(&dentry->d_lru);
+		spin_unlock(&dentry->d_lock);
+		return 0;
+	}
+
+	if (dentry->d_flags & DCACHE_REFERENCED) {
+		dentry->d_flags &= ~DCACHE_REFERENCED;
+		spin_unlock(&dentry->d_lock);
+
+		/*
+		 * XXX: this list move should be be done under d_lock. Need to
+		 * determine if it is safe just to do it under the lru lock.
+		 */
+		return 1;
+	}
+
+	dentry->d_flags |= DCACHE_SHRINK_LIST;
+	list_move_tail(&dentry->d_lru, freeable);
+	this_cpu_dec(nr_dentry_unused);
+	spin_unlock(&dentry->d_lock);
+
+	return 0;
+}
+
 /**
  * prune_dcache_sb - shrink the dcache
  * @sb: superblock
@@ -868,45 +883,12 @@ static void shrink_dentry_list(struct list_head *list)
  */
 long prune_dcache_sb(struct super_block *sb, long nr_to_scan)
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
-			list_move_tail(&dentry->d_lru, &tmp);
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
 
@@ -941,24 +923,10 @@ shrink_dcache_list(
  */
 void shrink_dcache_sb(struct super_block *sb)
 {
-	LIST_HEAD(tmp);
-
-	spin_lock(&sb->s_dentry_lru_lock);
-	while (!list_empty(&sb->s_dentry_lru)) {
-		list_splice_init(&sb->s_dentry_lru, &tmp);
-
-		/*
-		 * account for removal here so we don't need to handle it later
-		 * even though the dentry is no longer on the lru list.
-		 */
-		this_cpu_sub(nr_dentry_unused, sb->s_nr_dentry_unused);
-		sb->s_nr_dentry_unused = 0;
+	long freed;
 
-		spin_unlock(&sb->s_dentry_lru_lock);
-		shrink_dcache_list(&tmp);
-		spin_lock(&sb->s_dentry_lru_lock);
-	}
-	spin_unlock(&sb->s_dentry_lru_lock);
+	freed = list_lru_dispose_all(&sb->s_dentry_lru, shrink_dcache_list);
+	this_cpu_sub(nr_dentry_unused, freed);
 }
 EXPORT_SYMBOL(shrink_dcache_sb);
 
@@ -1229,7 +1197,8 @@ resume:
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
index 9049110..66f5cde 100644
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
index fdeaca1..8b25de0 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1262,14 +1262,6 @@ struct super_block {
 	struct list_head	s_files;
 #endif
 	struct list_head	s_mounts;	/* list of mounts; _not_ for fs use */
-
-	/* s_dentry_lru_lock protects s_dentry_lru and s_nr_dentry_unused */
-	spinlock_t		s_dentry_lru_lock ____cacheline_aligned_in_smp;
-	struct list_head	s_dentry_lru;	/* unused dentry lru */
-	int			s_nr_dentry_unused;	/* # of dentry on lru */
-
-	struct list_lru		s_inode_lru ____cacheline_aligned_in_smp;
-
 	struct block_device	*s_bdev;
 	struct backing_dev_info *s_bdi;
 	struct mtd_info		*s_mtd;
@@ -1320,6 +1312,13 @@ struct super_block {
 
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
