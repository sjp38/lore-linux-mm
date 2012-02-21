Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id 6C7096B004A
	for <linux-mm@kvack.org>; Tue, 21 Feb 2012 14:54:54 -0500 (EST)
From: David Howells <dhowells@redhat.com>
Subject: [PATCH 15/73] tmpfs: Add whiteout support [ver #2]
Date: Tue, 21 Feb 2012 17:59:22 +0000
Message-ID: <20120221175922.25235.80876.stgit@warthog.procyon.org.uk>
In-Reply-To: <20120221175721.25235.8901.stgit@warthog.procyon.org.uk>
References: <20120221175721.25235.8901.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, viro@ZenIV.linux.org.uk, valerie.aurora@gmail.com
Cc: linux-kernel@vger.kernel.org, Jan Blunck <jblunck@suse.de>, David Woodhouse <dwmw2@infradead.org>, Valerie Aurora <vaurora@redhat.com>, David Howells <dhowells@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, linux-mm@kvack.org

From: Jan Blunck <jblunck@suse.de>

Add support for whiteout dentries to tmpfs.  This includes adding support for
whiteouts to d_genocide(), which is called to tear down pinned tmpfs dentries.
Whiteouts have to be persistent, so they have a pinning extra ref count that
needs to be dropped by d_genocide().

Signed-off-by: Jan Blunck <jblunck@suse.de>
Signed-off-by: David Woodhouse <dwmw2@infradead.org>
Signed-off-by: Valerie Aurora <vaurora@redhat.com>
Signed-off-by: David Howells <dhowells@redhat.com>
Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: linux-mm@kvack.org
---

 fs/dcache.c |   12 +++++
 mm/shmem.c  |  144 +++++++++++++++++++++++++++++++++++++++++++++++++++++------
 2 files changed, 141 insertions(+), 15 deletions(-)

diff --git a/fs/dcache.c b/fs/dcache.c
index a8355d5..60af7b1 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -2886,7 +2886,17 @@ resume:
 		next = tmp->next;
 
 		spin_lock_nested(&dentry->d_lock, DENTRY_D_LOCK_NESTED);
-		if (d_unhashed(dentry) || !dentry->d_inode) {
+
+		/* Skip unhashed and negative dentries, but process positive
+		 * dentries and whiteouts.  A whiteout looks kind of like a
+		 * negative dentry for purposes of lookup, but it has an extra
+		 * pinning ref count because it can't be evicted like a
+		 * negative dentry can.  What we care about here is ref counts
+		 * - and we need to drop the ref count on a whiteout before we
+		 * can evict it.
+		 */
+		if (d_unhashed(dentry) ||
+		    (!dentry->d_inode && !d_is_whiteout(dentry))) {
 			spin_unlock(&dentry->d_lock);
 			continue;
 		}
diff --git a/mm/shmem.c b/mm/shmem.c
index 269d049..ca0bd30 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -1477,6 +1477,76 @@ static int shmem_statfs(struct dentry *dentry, struct kstatfs *buf)
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
@@ -1506,10 +1576,8 @@ shmem_mknod(struct inode *dir, struct dentry *dentry, umode_t mode, dev_t dev)
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
@@ -1547,12 +1615,10 @@ static int shmem_link(struct dentry *old_dentry, struct inode *dir, struct dentr
 	if (ret)
 		goto out;
 
-	dir->i_size += BOGO_DIRENT_SIZE;
 	inode->i_ctime = dir->i_ctime = dir->i_mtime = CURRENT_TIME;
 	inc_nlink(inode);
 	ihold(inode);	/* New dentry reference */
-	dget(dentry);		/* Extra pinning count for the created dentry */
-	d_instantiate(dentry, inode);
+	shmem_d_instantiate(dir, dentry, inode);
 out:
 	return ret;
 }
@@ -1561,21 +1627,61 @@ static int shmem_unlink(struct inode *dir, struct dentry *dentry)
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
+		spin_lock(&dentry->d_lock);
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
+		spin_unlock(&dentry->d_lock);
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
@@ -1584,7 +1690,7 @@ static int shmem_rmdir(struct inode *dir, struct dentry *dentry)
 /*
  * The VFS layer already does all the dentry stuff for rename,
  * we just have to decrement the usage count for the target if
- * it exists so that the VFS layer correctly free's it when it
+ * it exists so that the VFS layer correctly frees it when it
  * gets overwritten.
  */
 static int shmem_rename(struct inode *old_dir, struct dentry *old_dentry, struct inode *new_dir, struct dentry *new_dentry)
@@ -1595,7 +1701,12 @@ static int shmem_rename(struct inode *old_dir, struct dentry *old_dentry, struct
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
@@ -1663,10 +1774,8 @@ static int shmem_symlink(struct inode *dir, struct dentry *dentry, const char *s
 		unlock_page(page);
 		page_cache_release(page);
 	}
-	dir->i_size += BOGO_DIRENT_SIZE;
 	dir->i_ctime = dir->i_mtime = CURRENT_TIME;
-	d_instantiate(dentry, inode);
-	dget(dentry);
+	shmem_d_instantiate(dir, dentry, inode);
 	return 0;
 }
 
@@ -2236,6 +2345,12 @@ int shmem_fill_super(struct super_block *sb, void *data, int silent)
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
@@ -2335,6 +2450,7 @@ static const struct inode_operations shmem_dir_inode_operations = {
 	.rmdir		= shmem_rmdir,
 	.mknod		= shmem_mknod,
 	.rename		= shmem_rename,
+	.whiteout       = shmem_whiteout,
 #endif
 #ifdef CONFIG_TMPFS_XATTR
 	.setxattr	= shmem_setxattr,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
