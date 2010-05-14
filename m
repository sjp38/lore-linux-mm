Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 5D1F76B01FD
	for <linux-mm@kvack.org>; Fri, 14 May 2010 03:24:41 -0400 (EDT)
From: Dave Chinner <david@fromorbit.com>
Subject: [PATCH 1/5] inode: Make unused inode LRU per superblock
Date: Fri, 14 May 2010 17:24:19 +1000
Message-Id: <1273821863-29524-2-git-send-email-david@fromorbit.com>
In-Reply-To: <1273821863-29524-1-git-send-email-david@fromorbit.com>
References: <1273821863-29524-1-git-send-email-david@fromorbit.com>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: xfs@oss.sgi.com, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

From: Dave Chinner <dchinner@redhat.com>

The inode unused list is currently a global LRU. This does not match
the other global filesystem cache - the dentry cache - which uses
per-superblock LRU lists. Hence we have related filesystem object
types using different LRU reclaimatin schemes.

To enable a per-superblock filesystem cache shrinker, both of these
caches need to have per-sb unused object LRU lists. Hence this patch
converts the global inode LRU to per-sb LRUs.

The patch only does rudimentary per-sb propotioning in the shrinker
infrastructure, as this gets removed when the per-sb shrinker
callouts are introduced later on.

Signed-off-by: Dave Chinner <dchinner@redhat.com>
---
 fs/fs-writeback.c         |    2 +-
 fs/inode.c                |   89 ++++++++++++++++++++++++++++++++++++++++-----
 fs/super.c                |    1 +
 include/linux/fs.h        |    4 ++
 include/linux/writeback.h |    1 -
 5 files changed, 85 insertions(+), 12 deletions(-)

diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index 4b37f7c..fd78854 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -547,7 +547,7 @@ select_queue:
 			/*
 			 * The inode is clean, unused
 			 */
-			list_move(&inode->i_list, &inode_unused);
+			list_move(&inode->i_list, &inode->i_sb->s_inode_lru);
 		}
 	}
 	inode_sync_complete(inode);
diff --git a/fs/inode.c b/fs/inode.c
index 407bf39..8b95b15 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -74,7 +74,6 @@ static unsigned int i_hash_shift __read_mostly;
  */
 
 LIST_HEAD(inode_in_use);
-LIST_HEAD(inode_unused);
 static struct hlist_head *inode_hashtable __read_mostly;
 
 /*
@@ -294,6 +293,7 @@ void __iget(struct inode *inode)
 	if (!(inode->i_state & (I_DIRTY|I_SYNC)))
 		list_move(&inode->i_list, &inode_in_use);
 	inodes_stat.nr_unused--;
+	inode->i_sb->s_nr_inodes_unused--;
 }
 
 /**
@@ -388,6 +388,7 @@ static int invalidate_list(struct list_head *head, struct list_head *dispose)
 		invalidate_inode_buffers(inode);
 		if (!atomic_read(&inode->i_count)) {
 			list_move(&inode->i_list, dispose);
+			inode->i_sb->s_nr_inodes_unused--;
 			WARN_ON(inode->i_state & I_NEW);
 			inode->i_state |= I_FREEING;
 			count++;
@@ -446,32 +447,31 @@ static int can_unuse(struct inode *inode)
  *
  * Any inodes which are pinned purely because of attached pagecache have their
  * pagecache removed.  We expect the final iput() on that inode to add it to
- * the front of the inode_unused list.  So look for it there and if the
+ * the front of the sb->s_inode_lru list.  So look for it there and if the
  * inode is still freeable, proceed.  The right inode is found 99.9% of the
  * time in testing on a 4-way.
  *
  * If the inode has metadata buffers attached to mapping->private_list then
  * try to remove them.
  */
-static void prune_icache(int nr_to_scan)
+static void shrink_icache_sb(struct super_block *sb, int *nr_to_scan)
 {
 	LIST_HEAD(freeable);
 	int nr_pruned = 0;
 	int nr_scanned;
 	unsigned long reap = 0;
 
-	down_read(&iprune_sem);
 	spin_lock(&inode_lock);
-	for (nr_scanned = 0; nr_scanned < nr_to_scan; nr_scanned++) {
+	for (nr_scanned = *nr_to_scan; nr_scanned >= 0; nr_scanned--) {
 		struct inode *inode;
 
-		if (list_empty(&inode_unused))
+		if (list_empty(&sb->s_inode_lru))
 			break;
 
-		inode = list_entry(inode_unused.prev, struct inode, i_list);
+		inode = list_entry(sb->s_inode_lru.prev, struct inode, i_list);
 
 		if (inode->i_state || atomic_read(&inode->i_count)) {
-			list_move(&inode->i_list, &inode_unused);
+			list_move(&inode->i_list, &sb->s_inode_lru);
 			continue;
 		}
 		if (inode_has_buffers(inode) || inode->i_data.nrpages) {
@@ -483,7 +483,7 @@ static void prune_icache(int nr_to_scan)
 			iput(inode);
 			spin_lock(&inode_lock);
 
-			if (inode != list_entry(inode_unused.next,
+			if (inode != list_entry(sb->s_inode_lru.next,
 						struct inode, i_list))
 				continue;	/* wrong inode or list_empty */
 			if (!can_unuse(inode))
@@ -495,13 +495,80 @@ static void prune_icache(int nr_to_scan)
 		nr_pruned++;
 	}
 	inodes_stat.nr_unused -= nr_pruned;
+	sb->s_nr_inodes_unused -= nr_pruned;
 	if (current_is_kswapd())
 		__count_vm_events(KSWAPD_INODESTEAL, reap);
 	else
 		__count_vm_events(PGINODESTEAL, reap);
 	spin_unlock(&inode_lock);
+	*nr_to_scan = nr_scanned;
 
 	dispose_list(&freeable);
+}
+
+static void prune_icache(int count)
+{
+	struct super_block *sb;
+	int w_count;
+	int unused = inodes_stat.nr_unused;
+	int prune_ratio;
+	int pruned;
+
+	if (unused == 0 || count == 0)
+		return;
+	down_read(&iprune_sem);
+restart:
+	if (count >= unused)
+		prune_ratio = 1;
+	else
+		prune_ratio = unused / count;
+	spin_lock(&sb_lock);
+	list_for_each_entry(sb, &super_blocks, s_list) {
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
+		count -= pruned;
+		/*
+		 * restart only when sb is no longer on the list and
+		 * we have more work to do.
+		 */
+		if (__put_super_and_need_restart(sb) && count > 0) {
+			spin_unlock(&sb_lock);
+			goto restart;
+		}
+	}
+	spin_unlock(&sb_lock);
 	up_read(&iprune_sem);
 }
 
@@ -1242,8 +1309,9 @@ int generic_detach_inode(struct inode *inode)
 
 	if (!hlist_unhashed(&inode->i_hash)) {
 		if (!(inode->i_state & (I_DIRTY|I_SYNC)))
-			list_move(&inode->i_list, &inode_unused);
+			list_move(&inode->i_list, &sb->s_inode_lru);
 		inodes_stat.nr_unused++;
+		sb->s_nr_inodes_unused++;
 		if (sb->s_flags & MS_ACTIVE) {
 			spin_unlock(&inode_lock);
 			return 0;
@@ -1256,6 +1324,7 @@ int generic_detach_inode(struct inode *inode)
 		WARN_ON(inode->i_state & I_NEW);
 		inode->i_state &= ~I_WILL_FREE;
 		inodes_stat.nr_unused--;
+		sb->s_nr_inodes_unused--;
 		hlist_del_init(&inode->i_hash);
 	}
 	list_del_init(&inode->i_list);
diff --git a/fs/super.c b/fs/super.c
index 1527e6a..18655e6 100644
--- a/fs/super.c
+++ b/fs/super.c
@@ -68,6 +68,7 @@ static struct super_block *alloc_super(struct file_system_type *type)
 		INIT_HLIST_HEAD(&s->s_anon);
 		INIT_LIST_HEAD(&s->s_inodes);
 		INIT_LIST_HEAD(&s->s_dentry_lru);
+		INIT_LIST_HEAD(&s->s_inode_lru);
 		init_rwsem(&s->s_umount);
 		mutex_init(&s->s_lock);
 		lockdep_set_class(&s->s_umount, &type->s_umount_key);
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 44f35ae..41132e3 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1348,6 +1348,10 @@ struct super_block {
 	struct list_head	s_dentry_lru;	/* unused dentry lru */
 	int			s_nr_dentry_unused;	/* # of dentry on lru */
 
+	/* s_inode_lru and s_nr_inodes_unused are protected by inode_lock */
+	struct list_head	s_inode_lru;	/* unused inode lru */
+	int			s_nr_inodes_unused;	/* # of inodes on lru */
+
 	struct block_device	*s_bdev;
 	struct backing_dev_info *s_bdi;
 	struct mtd_info		*s_mtd;
diff --git a/include/linux/writeback.h b/include/linux/writeback.h
index 36520de..2636ade 100644
--- a/include/linux/writeback.h
+++ b/include/linux/writeback.h
@@ -11,7 +11,6 @@ struct backing_dev_info;
 
 extern spinlock_t inode_lock;
 extern struct list_head inode_in_use;
-extern struct list_head inode_unused;
 
 /*
  * fs/fs-writeback.c
-- 
1.5.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
