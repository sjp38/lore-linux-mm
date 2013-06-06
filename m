Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id C4D976B003B
	for <linux-mm@kvack.org>; Thu,  6 Jun 2013 16:34:47 -0400 (EDT)
From: Glauber Costa <glommer@openvz.org>
Subject: [PATCH v11 09/25] inode: convert inode lru list to generic lru list code.
Date: Fri,  7 Jun 2013 00:34:42 +0400
Message-Id: <1370550898-26711-10-git-send-email-glommer@openvz.org>
In-Reply-To: <1370550898-26711-1-git-send-email-glommer@openvz.org>
References: <1370550898-26711-1-git-send-email-glommer@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-fsdevel@vger.kernel.org, mgorman@suse.de, david@fromorbit.com, linux-mm@kvack.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, mhocko@suze.cz, hannes@cmpxchg.org, hughd@google.com, gthelen@google.com, Dave Chinner <dchinner@redhat.com>, Glauber Costa <glommer@openvz.org>

From: Dave Chinner <dchinner@redhat.com>

[ glommer: adapted for new LRU return codes ]
Signed-off-by: Dave Chinner <dchinner@redhat.com>
Signed-off-by: Glauber Costa <glommer@openvz.org>
---
 fs/inode.c         | 175 +++++++++++++++++++++--------------------------------
 fs/super.c         |  12 ++--
 include/linux/fs.h |   6 +-
 3 files changed, 77 insertions(+), 116 deletions(-)

diff --git a/fs/inode.c b/fs/inode.c
index 1ddaa2e..5d85521 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -17,6 +17,7 @@
 #include <linux/prefetch.h>
 #include <linux/buffer_head.h> /* for inode_has_buffers */
 #include <linux/ratelimit.h>
+#include <linux/list_lru.h>
 #include "internal.h"
 
 /*
@@ -24,7 +25,7 @@
  *
  * inode->i_lock protects:
  *   inode->i_state, inode->i_hash, __iget()
- * inode->i_sb->s_inode_lru_lock protects:
+ * Inode LRU list locks protect:
  *   inode->i_sb->s_inode_lru, inode->i_lru
  * inode_sb_list_lock protects:
  *   sb->s_inodes, inode->i_sb_list
@@ -37,7 +38,7 @@
  *
  * inode_sb_list_lock
  *   inode->i_lock
- *     inode->i_sb->s_inode_lru_lock
+ *     Inode LRU list locks
  *
  * bdi->wb.list_lock
  *   inode->i_lock
@@ -399,13 +400,8 @@ EXPORT_SYMBOL(ihold);
 
 static void inode_lru_list_add(struct inode *inode)
 {
-	spin_lock(&inode->i_sb->s_inode_lru_lock);
-	if (list_empty(&inode->i_lru)) {
-		list_add(&inode->i_lru, &inode->i_sb->s_inode_lru);
-		inode->i_sb->s_nr_inodes_unused++;
+	if (list_lru_add(&inode->i_sb->s_inode_lru, &inode->i_lru))
 		this_cpu_inc(nr_unused);
-	}
-	spin_unlock(&inode->i_sb->s_inode_lru_lock);
 }
 
 /*
@@ -423,13 +419,9 @@ void inode_add_lru(struct inode *inode)
 
 static void inode_lru_list_del(struct inode *inode)
 {
-	spin_lock(&inode->i_sb->s_inode_lru_lock);
-	if (!list_empty(&inode->i_lru)) {
-		list_del_init(&inode->i_lru);
-		inode->i_sb->s_nr_inodes_unused--;
+
+	if (list_lru_del(&inode->i_sb->s_inode_lru, &inode->i_lru))
 		this_cpu_dec(nr_unused);
-	}
-	spin_unlock(&inode->i_sb->s_inode_lru_lock);
 }
 
 /**
@@ -673,24 +665,8 @@ int invalidate_inodes(struct super_block *sb, bool kill_dirty)
 	return busy;
 }
 
-static int can_unuse(struct inode *inode)
-{
-	if (inode->i_state & ~I_REFERENCED)
-		return 0;
-	if (inode_has_buffers(inode))
-		return 0;
-	if (atomic_read(&inode->i_count))
-		return 0;
-	if (inode->i_data.nrpages)
-		return 0;
-	return 1;
-}
-
 /*
- * Walk the superblock inode LRU for freeable inodes and attempt to free them.
- * This is called from the superblock shrinker function with a number of inodes
- * to trim from the LRU. Inodes to be freed are moved to a temporary list and
- * then are freed outside inode_lock by dispose_list().
+ * Isolate the inode from the LRU in preparation for freeing it.
  *
  * Any inodes which are pinned purely because of attached pagecache have their
  * pagecache removed.  If the inode has metadata buffers attached to
@@ -704,90 +680,79 @@ static int can_unuse(struct inode *inode)
  * LRU does not have strict ordering. Hence we don't want to reclaim inodes
  * with this flag set because they are the inodes that are out of order.
  */
-long prune_icache_sb(struct super_block *sb, unsigned long nr_to_scan)
+static enum lru_status
+inode_lru_isolate(struct list_head *item, spinlock_t *lru_lock, void *arg)
 {
-	LIST_HEAD(freeable);
-	long nr_scanned;
-	long freed = 0;
-	unsigned long reap = 0;
+	struct list_head *freeable = arg;
+	struct inode	*inode = container_of(item, struct inode, i_lru);
 
-	spin_lock(&sb->s_inode_lru_lock);
-	for (nr_scanned = nr_to_scan; nr_scanned >= 0; nr_scanned--) {
-		struct inode *inode;
+	/*
+	 * we are inverting the lru lock/inode->i_lock here, so use a trylock.
+	 * If we fail to get the lock, just skip it.
+	 */
+	if (!spin_trylock(&inode->i_lock))
+		return LRU_SKIP;
 
-		if (list_empty(&sb->s_inode_lru))
-			break;
+	/*
+	 * Referenced or dirty inodes are still in use. Give them another pass
+	 * through the LRU as we canot reclaim them now.
+	 */
+	if (atomic_read(&inode->i_count) ||
+	    (inode->i_state & ~I_REFERENCED)) {
+		list_del_init(&inode->i_lru);
+		spin_unlock(&inode->i_lock);
+		this_cpu_dec(nr_unused);
+		return LRU_REMOVED;
+	}
 
-		inode = list_entry(sb->s_inode_lru.prev, struct inode, i_lru);
+	/* recently referenced inodes get one more pass */
+	if (inode->i_state & I_REFERENCED) {
+		inode->i_state &= ~I_REFERENCED;
+		spin_unlock(&inode->i_lock);
+		return LRU_ROTATE;
+	}
 
-		/*
-		 * we are inverting the sb->s_inode_lru_lock/inode->i_lock here,
-		 * so use a trylock. If we fail to get the lock, just move the
-		 * inode to the back of the list so we don't spin on it.
-		 */
-		if (!spin_trylock(&inode->i_lock)) {
-			list_move(&inode->i_lru, &sb->s_inode_lru);
-			continue;
+	if (inode_has_buffers(inode) || inode->i_data.nrpages) {
+		__iget(inode);
+		spin_unlock(&inode->i_lock);
+		spin_unlock(lru_lock);
+		if (remove_inode_buffers(inode)) {
+			unsigned long reap;
+			reap = invalidate_mapping_pages(&inode->i_data, 0, -1);
+			if (current_is_kswapd())
+				__count_vm_events(KSWAPD_INODESTEAL, reap);
+			else
+				__count_vm_events(PGINODESTEAL, reap);
+			if (current->reclaim_state)
+				current->reclaim_state->reclaimed_slab += reap;
 		}
+		iput(inode);
+		spin_lock(lru_lock);
+		return LRU_RETRY;
+	}
 
-		/*
-		 * Referenced or dirty inodes are still in use. Give them
-		 * another pass through the LRU as we canot reclaim them now.
-		 */
-		if (atomic_read(&inode->i_count) ||
-		    (inode->i_state & ~I_REFERENCED)) {
-			list_del_init(&inode->i_lru);
-			spin_unlock(&inode->i_lock);
-			sb->s_nr_inodes_unused--;
-			this_cpu_dec(nr_unused);
-			continue;
-		}
+	WARN_ON(inode->i_state & I_NEW);
+	inode->i_state |= I_FREEING;
+	spin_unlock(&inode->i_lock);
 
-		/* recently referenced inodes get one more pass */
-		if (inode->i_state & I_REFERENCED) {
-			inode->i_state &= ~I_REFERENCED;
-			list_move(&inode->i_lru, &sb->s_inode_lru);
-			spin_unlock(&inode->i_lock);
-			continue;
-		}
-		if (inode_has_buffers(inode) || inode->i_data.nrpages) {
-			__iget(inode);
-			spin_unlock(&inode->i_lock);
-			spin_unlock(&sb->s_inode_lru_lock);
-			if (remove_inode_buffers(inode))
-				reap += invalidate_mapping_pages(&inode->i_data,
-								0, -1);
-			iput(inode);
-			spin_lock(&sb->s_inode_lru_lock);
-
-			if (inode != list_entry(sb->s_inode_lru.next,
-						struct inode, i_lru))
-				continue;	/* wrong inode or list_empty */
-			/* avoid lock inversions with trylock */
-			if (!spin_trylock(&inode->i_lock))
-				continue;
-			if (!can_unuse(inode)) {
-				spin_unlock(&inode->i_lock);
-				continue;
-			}
-		}
-		WARN_ON(inode->i_state & I_NEW);
-		inode->i_state |= I_FREEING;
-		spin_unlock(&inode->i_lock);
+	list_move(&inode->i_lru, freeable);
+	this_cpu_dec(nr_unused);
+	return LRU_REMOVED;
+}
 
-		list_move(&inode->i_lru, &freeable);
-		sb->s_nr_inodes_unused--;
-		this_cpu_dec(nr_unused);
-		freed++;
-	}
-	if (current_is_kswapd())
-		__count_vm_events(KSWAPD_INODESTEAL, reap);
-	else
-		__count_vm_events(PGINODESTEAL, reap);
-	spin_unlock(&sb->s_inode_lru_lock);
-	if (current->reclaim_state)
-		current->reclaim_state->reclaimed_slab += reap;
+/*
+ * Walk the superblock inode LRU for freeable inodes and attempt to free them.
+ * This is called from the superblock shrinker function with a number of inodes
+ * to trim from the LRU. Inodes to be freed are moved to a temporary list and
+ * then are freed outside inode_lock by dispose_list().
+ */
+long prune_icache_sb(struct super_block *sb, unsigned long nr_to_scan)
+{
+	LIST_HEAD(freeable);
+	long freed;
 
+	freed = list_lru_walk(&sb->s_inode_lru, inode_lru_isolate,
+						&freeable, nr_to_scan);
 	dispose_list(&freeable);
 	return freed;
 }
diff --git a/fs/super.c b/fs/super.c
index 86801eb..fea5c44 100644
--- a/fs/super.c
+++ b/fs/super.c
@@ -77,14 +77,13 @@ static long super_cache_scan(struct shrinker *shrink, struct shrink_control *sc)
 	if (sb->s_op && sb->s_op->nr_cached_objects)
 		fs_objects = sb->s_op->nr_cached_objects(sb);
 
-	total_objects = sb->s_nr_dentry_unused +
-			sb->s_nr_inodes_unused + fs_objects + 1;
+	inodes = list_lru_count(&sb->s_inode_lru);
+	total_objects = sb->s_nr_dentry_unused + inodes + fs_objects + 1;
 
 	/* proportion the scan between the caches */
 	dentries = mult_frac(sc->nr_to_scan, sb->s_nr_dentry_unused,
 								total_objects);
-	inodes = mult_frac(sc->nr_to_scan, sb->s_nr_inodes_unused,
-								total_objects);
+	inodes = mult_frac(sc->nr_to_scan, inodes, total_objects);
 
 	/*
 	 * prune the dcache first as the icache is pinned by it, then
@@ -117,7 +116,7 @@ static long super_cache_count(struct shrinker *shrink, struct shrink_control *sc
 		total_objects = sb->s_op->nr_cached_objects(sb);
 
 	total_objects += sb->s_nr_dentry_unused;
-	total_objects += sb->s_nr_inodes_unused;
+	total_objects += list_lru_count(&sb->s_inode_lru);
 
 	total_objects = vfs_pressure_ratio(total_objects);
 	drop_super(sb);
@@ -198,8 +197,7 @@ static struct super_block *alloc_super(struct file_system_type *type, int flags)
 		INIT_LIST_HEAD(&s->s_inodes);
 		INIT_LIST_HEAD(&s->s_dentry_lru);
 		spin_lock_init(&s->s_dentry_lru_lock);
-		INIT_LIST_HEAD(&s->s_inode_lru);
-		spin_lock_init(&s->s_inode_lru_lock);
+		list_lru_init(&s->s_inode_lru);
 		INIT_LIST_HEAD(&s->s_mounts);
 		init_rwsem(&s->s_umount);
 		lockdep_set_class(&s->s_umount, &type->s_umount_key);
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 2913d3b..a50f175 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -10,6 +10,7 @@
 #include <linux/stat.h>
 #include <linux/cache.h>
 #include <linux/list.h>
+#include <linux/list_lru.h>
 #include <linux/radix-tree.h>
 #include <linux/rbtree.h>
 #include <linux/init.h>
@@ -1270,10 +1271,7 @@ struct super_block {
 	struct list_head	s_dentry_lru;	/* unused dentry lru */
 	long			s_nr_dentry_unused;	/* # of dentry on lru */
 
-	/* s_inode_lru_lock protects s_inode_lru and s_nr_inodes_unused */
-	spinlock_t		s_inode_lru_lock ____cacheline_aligned_in_smp;
-	struct list_head	s_inode_lru;		/* unused inode lru */
-	long			s_nr_inodes_unused;	/* # of inodes on lru */
+	struct list_lru		s_inode_lru ____cacheline_aligned_in_smp;
 
 	struct block_device	*s_bdev;
 	struct backing_dev_info *s_bdi;
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
