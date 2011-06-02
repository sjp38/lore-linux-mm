Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 6F5D56B007B
	for <linux-mm@kvack.org>; Thu,  2 Jun 2011 03:01:23 -0400 (EDT)
From: Dave Chinner <david@fromorbit.com>
Subject: [PATCH 06/12] inode: Make unused inode LRU per superblock
Date: Thu,  2 Jun 2011 17:01:01 +1000
Message-Id: <1306998067-27659-7-git-send-email-david@fromorbit.com>
In-Reply-To: <1306998067-27659-1-git-send-email-david@fromorbit.com>
References: <1306998067-27659-1-git-send-email-david@fromorbit.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, xfs@oss.sgi.com

From: Dave Chinner <dchinner@redhat.com>

The inode unused list is currently a global LRU. This does not match
the other global filesystem cache - the dentry cache - which uses
per-superblock LRU lists. Hence we have related filesystem object
types using different LRU reclaimation schemes.

To enable a per-superblock filesystem cache shrinker, both of these
caches need to have per-sb unused object LRU lists. Hence this patch
converts the global inode LRU to per-sb LRUs.

The patch only does rudimentary per-sb propotioning in the shrinker
infrastructure, as this gets removed when the per-sb shrinker
callouts are introduced later on.

Signed-off-by: Dave Chinner <dchinner@redhat.com>
---
 fs/inode.c         |   91 +++++++++++++++++++++++++++++++++++++++++++++------
 fs/super.c         |    1 +
 include/linux/fs.h |    4 ++
 3 files changed, 85 insertions(+), 11 deletions(-)

diff --git a/fs/inode.c b/fs/inode.c
index 17fea5b..e039115 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -34,7 +34,7 @@
  * inode->i_lock protects:
  *   inode->i_state, inode->i_hash, __iget()
  * inode_lru_lock protects:
- *   inode_lru, inode->i_lru
+ *   inode->i_sb->s_inode_lru, inode->i_lru
  * inode_sb_list_lock protects:
  *   sb->s_inodes, inode->i_sb_list
  * inode_wb_list_lock protects:
@@ -64,7 +64,6 @@ static unsigned int i_hash_shift __read_mostly;
 static struct hlist_head *inode_hashtable __read_mostly;
 static __cacheline_aligned_in_smp DEFINE_SPINLOCK(inode_hash_lock);
 
-static LIST_HEAD(inode_lru);
 static DEFINE_SPINLOCK(inode_lru_lock);
 
 __cacheline_aligned_in_smp DEFINE_SPINLOCK(inode_sb_list_lock);
@@ -345,7 +344,8 @@ static void inode_lru_list_add(struct inode *inode)
 {
 	spin_lock(&inode_lru_lock);
 	if (list_empty(&inode->i_lru)) {
-		list_add(&inode->i_lru, &inode_lru);
+		list_add(&inode->i_lru, &inode->i_sb->s_inode_lru);
+		inode->i_sb->s_nr_inodes_unused++;
 		this_cpu_inc(nr_unused);
 	}
 	spin_unlock(&inode_lru_lock);
@@ -356,6 +356,7 @@ static void inode_lru_list_del(struct inode *inode)
 	spin_lock(&inode_lru_lock);
 	if (!list_empty(&inode->i_lru)) {
 		list_del_init(&inode->i_lru);
+		inode->i_sb->s_nr_inodes_unused--;
 		this_cpu_dec(nr_unused);
 	}
 	spin_unlock(&inode_lru_lock);
@@ -621,21 +622,20 @@ static int can_unuse(struct inode *inode)
  * LRU does not have strict ordering. Hence we don't want to reclaim inodes
  * with this flag set because they are the inodes that are out of order.
  */
-static void prune_icache(int nr_to_scan)
+static void shrink_icache_sb(struct super_block *sb, int *nr_to_scan)
 {
 	LIST_HEAD(freeable);
 	int nr_scanned;
 	unsigned long reap = 0;
 
-	down_read(&iprune_sem);
 	spin_lock(&inode_lru_lock);
-	for (nr_scanned = 0; nr_scanned < nr_to_scan; nr_scanned++) {
+	for (nr_scanned = *nr_to_scan; nr_scanned >= 0; nr_scanned--) {
 		struct inode *inode;
 
-		if (list_empty(&inode_lru))
+		if (list_empty(&sb->s_inode_lru))
 			break;
 
-		inode = list_entry(inode_lru.prev, struct inode, i_lru);
+		inode = list_entry(sb->s_inode_lru.prev, struct inode, i_lru);
 
 		/*
 		 * we are inverting the inode_lru_lock/inode->i_lock here,
@@ -643,7 +643,7 @@ static void prune_icache(int nr_to_scan)
 		 * inode to the back of the list so we don't spin on it.
 		 */
 		if (!spin_trylock(&inode->i_lock)) {
-			list_move(&inode->i_lru, &inode_lru);
+			list_move(&inode->i_lru, &sb->s_inode_lru);
 			continue;
 		}
 
@@ -655,6 +655,7 @@ static void prune_icache(int nr_to_scan)
 		    (inode->i_state & ~I_REFERENCED)) {
 			list_del_init(&inode->i_lru);
 			spin_unlock(&inode->i_lock);
+			sb->s_nr_inodes_unused--;
 			this_cpu_dec(nr_unused);
 			continue;
 		}
@@ -662,7 +663,7 @@ static void prune_icache(int nr_to_scan)
 		/* recently referenced inodes get one more pass */
 		if (inode->i_state & I_REFERENCED) {
 			inode->i_state &= ~I_REFERENCED;
-			list_move(&inode->i_lru, &inode_lru);
+			list_move(&inode->i_lru, &sb->s_inode_lru);
 			spin_unlock(&inode->i_lock);
 			continue;
 		}
@@ -676,7 +677,7 @@ static void prune_icache(int nr_to_scan)
 			iput(inode);
 			spin_lock(&inode_lru_lock);
 
-			if (inode != list_entry(inode_lru.next,
+			if (inode != list_entry(sb->s_inode_lru.next,
 						struct inode, i_lru))
 				continue;	/* wrong inode or list_empty */
 			/* avoid lock inversions with trylock */
@@ -692,6 +693,7 @@ static void prune_icache(int nr_to_scan)
 		spin_unlock(&inode->i_lock);
 
 		list_move(&inode->i_lru, &freeable);
+		sb->s_nr_inodes_unused--;
 		this_cpu_dec(nr_unused);
 	}
 	if (current_is_kswapd())
@@ -699,8 +701,75 @@ static void prune_icache(int nr_to_scan)
 	else
 		__count_vm_events(PGINODESTEAL, reap);
 	spin_unlock(&inode_lru_lock);
+	*nr_to_scan = nr_scanned;
 
 	dispose_list(&freeable);
+}
+
+static void prune_icache(int count)
+{
+	struct super_block *sb, *p = NULL;
+	int w_count;
+	int unused = inodes_stat.nr_unused;
+	int prune_ratio;
+	int pruned;
+
+	if (unused == 0 || count == 0)
+		return;
+	down_read(&iprune_sem);
+	if (count >= unused)
+		prune_ratio = 1;
+	else
+		prune_ratio = unused / count;
+	spin_lock(&sb_lock);
+	list_for_each_entry(sb, &super_blocks, s_list) {
+		if (list_empty(&sb->s_instances))
+			continue;
+		if (sb->s_nr_inodes_unused == 0)
+			continue;
+		sb->s_count++;
+		/* Now, we reclaim unused dentrins with fairness.
+		 * We reclaim them same percentage from each superblock.
+		 * We calculate number of dentries to scan on this sb
+		 * as follows, but the implementation is arranged to avoid
+		 * overflows:
+		 * number of dentries to scan on this sb =
+		 * count * (number of dentries on this sb /
+		 * number of dentries in the machine)
+		 */
+		spin_unlock(&sb_lock);
+		if (prune_ratio != 1)
+			w_count = (sb->s_nr_inodes_unused / prune_ratio) + 1;
+		else
+			w_count = sb->s_nr_inodes_unused;
+		pruned = w_count;
+		/*
+		 * We need to be sure this filesystem isn't being unmounted,
+		 * otherwise we could race with generic_shutdown_super(), and
+		 * end up holding a reference to an inode while the filesystem
+		 * is unmounted.  So we try to get s_umount, and make sure
+		 * s_root isn't NULL.
+		 */
+		if (down_read_trylock(&sb->s_umount)) {
+			if ((sb->s_root != NULL) &&
+			    (!list_empty(&sb->s_dentry_lru))) {
+				shrink_icache_sb(sb, &w_count);
+				pruned -= w_count;
+			}
+			up_read(&sb->s_umount);
+		}
+		spin_lock(&sb_lock);
+		if (p)
+			__put_super(p);
+		count -= pruned;
+		p = sb;
+		/* more work left to do? */
+		if (count <= 0)
+			break;
+	}
+	if (p)
+		__put_super(p);
+	spin_unlock(&sb_lock);
 	up_read(&iprune_sem);
 }
 
diff --git a/fs/super.c b/fs/super.c
index c755939..ef7caf7 100644
--- a/fs/super.c
+++ b/fs/super.c
@@ -77,6 +77,7 @@ static struct super_block *alloc_super(struct file_system_type *type)
 		INIT_HLIST_BL_HEAD(&s->s_anon);
 		INIT_LIST_HEAD(&s->s_inodes);
 		INIT_LIST_HEAD(&s->s_dentry_lru);
+		INIT_LIST_HEAD(&s->s_inode_lru);
 		init_rwsem(&s->s_umount);
 		mutex_init(&s->s_lock);
 		lockdep_set_class(&s->s_umount, &type->s_umount_key);
diff --git a/include/linux/fs.h b/include/linux/fs.h
index c55d6b7..a96071d 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1393,6 +1393,10 @@ struct super_block {
 	struct list_head	s_dentry_lru;	/* unused dentry lru */
 	int			s_nr_dentry_unused;	/* # of dentry on lru */
 
+	/* inode_lru_lock protects s_inode_lru and s_nr_inodes_unused */
+	struct list_head	s_inode_lru;		/* unused inode lru */
+	int			s_nr_inodes_unused;	/* # of inodes on lru */
+
 	struct block_device	*s_bdev;
 	struct backing_dev_info *s_bdi;
 	struct mtd_info		*s_mtd;
-- 
1.7.5.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
