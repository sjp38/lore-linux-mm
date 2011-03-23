Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 5CB098D0040
	for <linux-mm@kvack.org>; Tue, 22 Mar 2011 22:00:56 -0400 (EDT)
Received: by iyf13 with SMTP id 13so11072645iyf.14
        for <linux-mm@kvack.org>; Tue, 22 Mar 2011 19:00:48 -0700 (PDT)
From: Valerie Aurora <valerie.aurora@gmail.com>
Subject: [PATCH 09/74] whiteout: tmpfs whiteout support
Date: Tue, 22 Mar 2011 18:58:45 -0700
Message-Id: <1300845590-14184-10-git-send-email-valerie.aurora@gmail.com>
In-Reply-To: <1300845590-14184-1-git-send-email-valerie.aurora@gmail.com>
References: <1300845590-14184-1-git-send-email-valerie.aurora@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux@vger.kernel.org
Cc: viro@zeniv.linux.org.uk, Jan Blunck <jblunck@suse.de>, David Woodhouse <dwmw2@infradead.org>, Valerie Aurora <vaurora@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, linux-mm@kvack.org, Valerie Aurora <valerie.aurora@gmail.com>

From: Jan Blunck <jblunck@suse.de>

Add support for whiteout dentries to tmpfs.  This includes adding
support for whiteouts to d_genocide(), which is called to tear down
pinned tmpfs dentries.  Whiteouts have to be persistent, so they have
a pinning extra ref count that needs to be dropped by d_genocide().

Signed-off-by: Jan Blunck <jblunck@suse.de>
Signed-off-by: David Woodhouse <dwmw2@infradead.org>
Signed-off-by: Valerie Aurora <vaurora@redhat.com>
Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: linux-mm@kvack.org
Signed-off-by: Valerie Aurora <valerie.aurora@gmail.com>
---
 fs/dcache.c |   13 +++++-
 mm/shmem.c  |  145 +++++++++++++++++++++++++++++++++++++++++++++++++++++------
 2 files changed, 143 insertions(+), 15 deletions(-)

diff --git a/fs/dcache.c b/fs/dcache.c
index 28975dd..9358dbc 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -2337,7 +2337,18 @@ resume:
 		struct list_head *tmp = next;
 		struct dentry *dentry = list_entry(tmp, struct dentry, d_u.d_child);
 		next = tmp->next;
-		if (d_unhashed(dentry)||!dentry->d_inode)
+		/*
+		 * Skip unhashed and negative dentries, but process
+		 * positive dentries and whiteouts.  A whiteout looks
+		 * kind of like a negative dentry for purposes of
+		 * lookup, but it has an extra pinning ref count
+		 * because it can't be evicted like a negative dentry
+		 * can.  What we care about here is ref counts - and
+		 * we need to drop the ref count on a whiteout before
+		 * we can evict it.
+		 */
+		if (d_unhashed(dentry)||(!dentry->d_inode &&
+					 !d_is_whiteout(dentry)))
 			continue;
 		if (!list_empty(&dentry->d_subdirs)) {
 			this_parent = dentry;
diff --git a/mm/shmem.c b/mm/shmem.c
index 080b09a..0ac3af3 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -1831,6 +1831,76 @@ static int shmem_statfs(struct dentry *dentry, struct kstatfs *buf)
 	return 0;
 }
 
+static int shmem_rmdir(struct inode *dir, struct dentry *dentry);
+static int shmem_unlink(struct inode *dir, struct dentry *dentry);
+
+/*
+ * This is the whiteout support for tmpfs. It uses one singleton whiteout
+ * inode per superblock thus it is very similar to shmem_link().
+ */
+static int shmem_whiteout(struct inode *dir, struct dentry *old_dentry,
+			  struct dentry *new_dentry)
+{
+	struct shmem_sb_info *sbinfo = SHMEM_SB(dir->i_sb);
+	struct dentry *dentry;
+
+	if (!(dir->i_sb->s_flags & MS_WHITEOUT))
+		return -EPERM;
+
+	/* This gives us a proper initialized negative dentry */
+	dentry = simple_lookup(dir, new_dentry, NULL);
+	if (dentry && IS_ERR(dentry))
+		return PTR_ERR(dentry);
+
+	/*
+	 * No ordinary (disk based) filesystem counts whiteouts as inodes;
+	 * but each new link needs a new dentry, pinning lowmem, and
+	 * tmpfs dentries cannot be pruned until they are unlinked.
+	 */
+	if (sbinfo->max_inodes) {
+		spin_lock(&sbinfo->stat_lock);
+		if (!sbinfo->free_inodes) {
+			spin_unlock(&sbinfo->stat_lock);
+			return -ENOSPC;
+		}
+		sbinfo->free_inodes--;
+		spin_unlock(&sbinfo->stat_lock);
+	}
+
+	if (old_dentry->d_inode) {
+		if (S_ISDIR(old_dentry->d_inode->i_mode))
+			shmem_rmdir(dir, old_dentry);
+		else
+			shmem_unlink(dir, old_dentry);
+	}
+
+	dir->i_size += BOGO_DIRENT_SIZE;
+	dir->i_ctime = dir->i_mtime = CURRENT_TIME;
+	/* Extra pinning count for the created dentry */
+	dget(new_dentry);
+	spin_lock(&new_dentry->d_lock);
+	new_dentry->d_flags |= DCACHE_WHITEOUT;
+	spin_unlock(&new_dentry->d_lock);
+	return 0;
+}
+
+static void shmem_d_instantiate(struct inode *dir, struct dentry *dentry,
+				struct inode *inode)
+{
+	if (d_is_whiteout(dentry)) {
+		/* Re-using an existing whiteout */
+		shmem_free_inode(dir->i_sb);
+		if (S_ISDIR(inode->i_mode))
+			inode->i_mode |= S_OPAQUE;
+	} else {
+		/* New dentry */
+		dir->i_size += BOGO_DIRENT_SIZE;
+		dget(dentry); /* Extra count - pin the dentry in core */
+	}
+	/* Will clear DCACHE_WHITEOUT flag */
+	d_instantiate(dentry, inode);
+
+}
 /*
  * File creation. Allocate an inode, and we're done..
  */
@@ -1859,10 +1929,8 @@ shmem_mknod(struct inode *dir, struct dentry *dentry, int mode, dev_t dev)
 #else
 		error = 0;
 #endif
-		dir->i_size += BOGO_DIRENT_SIZE;
+		shmem_d_instantiate(dir, dentry, inode);
 		dir->i_ctime = dir->i_mtime = CURRENT_TIME;
-		d_instantiate(dentry, inode);
-		dget(dentry); /* Extra count - pin the dentry in core */
 	}
 	return error;
 }
@@ -1900,12 +1968,11 @@ static int shmem_link(struct dentry *old_dentry, struct inode *dir, struct dentr
 	if (ret)
 		goto out;
 
-	dir->i_size += BOGO_DIRENT_SIZE;
+	shmem_d_instantiate(dir, dentry, inode);
+
 	inode->i_ctime = dir->i_ctime = dir->i_mtime = CURRENT_TIME;
 	inc_nlink(inode);
 	atomic_inc(&inode->i_count);	/* New dentry reference */
-	dget(dentry);		/* Extra pinning count for the created dentry */
-	d_instantiate(dentry, inode);
 out:
 	return ret;
 }
@@ -1914,21 +1981,61 @@ static int shmem_unlink(struct inode *dir, struct dentry *dentry)
 {
 	struct inode *inode = dentry->d_inode;
 
-	if (inode->i_nlink > 1 && !S_ISDIR(inode->i_mode))
-		shmem_free_inode(inode->i_sb);
+	if (d_is_whiteout(dentry) || (inode->i_nlink > 1 && !S_ISDIR(inode->i_mode)))
+		shmem_free_inode(dir->i_sb);
 
+	if (inode) {
+		inode->i_ctime = dir->i_ctime = dir->i_mtime = CURRENT_TIME;
+		drop_nlink(inode);
+	}
 	dir->i_size -= BOGO_DIRENT_SIZE;
-	inode->i_ctime = dir->i_ctime = dir->i_mtime = CURRENT_TIME;
-	drop_nlink(inode);
 	dput(dentry);	/* Undo the count from "create" - this does all the work */
 	return 0;
 }
 
+static void shmem_dir_unlink_whiteouts(struct inode *dir, struct dentry *dentry)
+{
+	if (!dentry->d_inode)
+		return;
+
+	/* Remove whiteouts from logical empty directory */
+	if (S_ISDIR(dentry->d_inode->i_mode) &&
+	    dentry->d_inode->i_sb->s_flags & MS_WHITEOUT) {
+		struct dentry *child, *next;
+		LIST_HEAD(list);
+
+		spin_lock(&dcache_lock);
+		list_for_each_entry(child, &dentry->d_subdirs, d_u.d_child) {
+			spin_lock(&child->d_lock);
+			if (d_is_whiteout(child)) {
+				__d_drop(child);
+				if (!list_empty(&child->d_lru)) {
+					list_del(&child->d_lru);
+					dentry_stat.nr_unused--;
+				}
+				list_add(&child->d_lru, &list);
+			}
+			spin_unlock(&child->d_lock);
+		}
+		spin_unlock(&dcache_lock);
+
+		list_for_each_entry_safe(child, next, &list, d_lru) {
+			spin_lock(&child->d_lock);
+			list_del_init(&child->d_lru);
+			spin_unlock(&child->d_lock);
+
+			shmem_unlink(dentry->d_inode, child);
+		}
+	}
+}
+
 static int shmem_rmdir(struct inode *dir, struct dentry *dentry)
 {
 	if (!simple_empty(dentry))
 		return -ENOTEMPTY;
 
+	/* Remove whiteouts from logical empty directory */
+	shmem_dir_unlink_whiteouts(dir, dentry);
 	drop_nlink(dentry->d_inode);
 	drop_nlink(dir);
 	return shmem_unlink(dir, dentry);
@@ -1937,7 +2044,7 @@ static int shmem_rmdir(struct inode *dir, struct dentry *dentry)
 /*
  * The VFS layer already does all the dentry stuff for rename,
  * we just have to decrement the usage count for the target if
- * it exists so that the VFS layer correctly free's it when it
+ * it exists so that the VFS layer correctly frees it when it
  * gets overwritten.
  */
 static int shmem_rename(struct inode *old_dir, struct dentry *old_dentry, struct inode *new_dir, struct dentry *new_dentry)
@@ -1948,7 +2055,12 @@ static int shmem_rename(struct inode *old_dir, struct dentry *old_dentry, struct
 	if (!simple_empty(new_dentry))
 		return -ENOTEMPTY;
 
+	if (d_is_whiteout(new_dentry))
+		shmem_unlink(new_dir, new_dentry);
+
 	if (new_dentry->d_inode) {
+		/* Remove whiteouts from logical empty directory */
+		shmem_dir_unlink_whiteouts(new_dir, new_dentry);
 		(void) shmem_unlink(new_dir, new_dentry);
 		if (they_are_dirs)
 			drop_nlink(old_dir);
@@ -2013,10 +2125,8 @@ static int shmem_symlink(struct inode *dir, struct dentry *dentry, const char *s
 		unlock_page(page);
 		page_cache_release(page);
 	}
-	dir->i_size += BOGO_DIRENT_SIZE;
+	shmem_d_instantiate(dir, dentry, inode);
 	dir->i_ctime = dir->i_mtime = CURRENT_TIME;
-	d_instantiate(dentry, inode);
-	dget(dentry);
 	return 0;
 }
 
@@ -2394,6 +2504,12 @@ int shmem_fill_super(struct super_block *sb, void *data, int silent)
 	if (!root)
 		goto failed_iput;
 	sb->s_root = root;
+
+#ifdef CONFIG_TMPFS
+	if (!(sb->s_flags & MS_NOUSER))
+		sb->s_flags |= MS_WHITEOUT;
+#endif
+
 	return 0;
 
 failed_iput:
@@ -2493,6 +2609,7 @@ static const struct inode_operations shmem_dir_inode_operations = {
 	.rmdir		= shmem_rmdir,
 	.mknod		= shmem_mknod,
 	.rename		= shmem_rename,
+	.whiteout       = shmem_whiteout,
 #endif
 #ifdef CONFIG_TMPFS_POSIX_ACL
 	.setattr	= shmem_notify_change,
-- 
1.7.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
