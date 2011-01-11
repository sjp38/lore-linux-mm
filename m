Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id ADEA56B00E7
	for <linux-mm@kvack.org>; Tue, 11 Jan 2011 16:13:02 -0500 (EST)
From: Eric Paris <eparis@redhat.com>
Subject: [PATCH] tmpfs: implement security.capability xattrs
Date: Tue, 11 Jan 2011 16:07:10 -0500
Message-ID: <20110111210710.32348.1642.stgit@paris.rdu.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: hughd@google.com
List-ID: <linux-mm.kvack.org>

This patch implements security.capability xattrs for tmpfs filesystems.  The
feodra project, while trying to replace suid apps with file capabilities,
realized that tmpfs, which is used on my build systems, does not support file
capabilities and thus cannot be used to build packages which use file
capabilities.  The patch only implements security.capability but there is no
reason it could not be easily expanded to support *.* xattrs as most of the
work is already done.  I don't know what other xattrs are in use in the world
or if they necessarily make sense on tmpfs so I didn't make this
implementation completely generic.

The basic implementation is that I attach a
struct shmem_xattr {
	struct list_head list; /* anchored by shmem_inode_info->xattr_list */
	char *name;
	size_t size;
	char value[0];
};
Into the struct shmem_inode_info for each xattr that is set.  Since I only
allow security.capability obviously this list is only every 0 or 1 entry long.
I could have been a little simpler, but then the next person having to
implement an xattr would have to redo everything I did instead of me just
doing 90% of their work  :)

Signed-off-by: Eric Paris <eparis@redhat.com>
---

 include/linux/shmem_fs.h |    8 +++
 mm/shmem.c               |  112 ++++++++++++++++++++++++++++++++++++++++++++--
 2 files changed, 116 insertions(+), 4 deletions(-)

diff --git a/include/linux/shmem_fs.h b/include/linux/shmem_fs.h
index 399be5a..6f2ebb8 100644
--- a/include/linux/shmem_fs.h
+++ b/include/linux/shmem_fs.h
@@ -9,6 +9,13 @@
 
 #define SHMEM_NR_DIRECT 16
 
+struct shmem_xattr {
+	struct list_head list; /* anchored by shmem_inode_info->xattr_list */
+	char *name;
+	size_t size;
+	char value[0];
+};
+
 struct shmem_inode_info {
 	spinlock_t		lock;
 	unsigned long		flags;
@@ -19,6 +26,7 @@ struct shmem_inode_info {
 	struct page		*i_indirect;	/* top indirect blocks page */
 	swp_entry_t		i_direct[SHMEM_NR_DIRECT]; /* first blocks */
 	struct list_head	swaplist;	/* chain of maybes on swap */
+	struct list_head	xattr_list;	/* list of shmem_xattr */
 	struct inode		vfs_inode;
 };
 
diff --git a/mm/shmem.c b/mm/shmem.c
index 86cd21d..d2bacd6 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -822,6 +822,7 @@ static int shmem_notify_change(struct dentry *dentry, struct iattr *attr)
 static void shmem_evict_inode(struct inode *inode)
 {
 	struct shmem_inode_info *info = SHMEM_I(inode);
+	struct shmem_xattr *xattr, *nxattr;
 
 	if (inode->i_mapping->a_ops == &shmem_aops) {
 		truncate_inode_pages(inode->i_mapping, 0);
@@ -834,6 +835,9 @@ static void shmem_evict_inode(struct inode *inode)
 			mutex_unlock(&shmem_swaplist_mutex);
 		}
 	}
+
+	list_for_each_entry_safe(xattr, nxattr, &info->xattr_list, list)
+		kfree(xattr);
 	BUG_ON(inode->i_blocks);
 	shmem_free_inode(inode->i_sb);
 	end_writeback(inode);
@@ -1597,6 +1601,7 @@ static struct inode *shmem_get_inode(struct super_block *sb, const struct inode
 		spin_lock_init(&info->lock);
 		info->flags = flags & VM_NORESERVE;
 		INIT_LIST_HEAD(&info->swaplist);
+		INIT_LIST_HEAD(&info->xattr_list);
 		cache_no_acl(inode);
 
 		switch (mode & S_IFMT) {
@@ -2071,24 +2076,123 @@ static size_t shmem_xattr_security_list(struct dentry *dentry, char *list,
 					size_t list_len, const char *name,
 					size_t name_len, int handler_flags)
 {
-	return security_inode_listsecurity(dentry->d_inode, list, list_len);
+	struct shmem_xattr *xattr;
+	struct shmem_inode_info *shmem_i;
+	size_t used;
+	char *buf = NULL;
+
+	used = security_inode_listsecurity(dentry->d_inode, list, list_len);
+
+	shmem_i = SHMEM_I(dentry->d_inode);
+	if (list)
+		buf = list + used;
+
+	spin_lock(&dentry->d_inode->i_lock);
+	list_for_each_entry(xattr, &shmem_i->xattr_list, list) {
+		size_t len = XATTR_SECURITY_PREFIX_LEN;
+		len += strlen(xattr->name) + 1;
+		if (list_len - (used + len) >= 0 && buf) {
+			strncpy(buf, XATTR_SECURITY_PREFIX, XATTR_SECURITY_PREFIX_LEN);
+			buf += XATTR_SECURITY_PREFIX_LEN;
+			strncpy(buf, xattr->name, strlen(xattr->name) + 1);
+			buf += strlen(xattr->name) + 1;
+		}
+		used += len;
+	}
+	spin_unlock(&dentry->d_inode->i_lock);
+
+	return used;
 }
 
 static int shmem_xattr_security_get(struct dentry *dentry, const char *name,
 		void *buffer, size_t size, int handler_flags)
 {
+	struct shmem_inode_info *shmem_i;
+	struct shmem_xattr *xattr;
+	int ret;
+
 	if (strcmp(name, "") == 0)
 		return -EINVAL;
-	return xattr_getsecurity(dentry->d_inode, name, buffer, size);
+
+	ret = xattr_getsecurity(dentry->d_inode, name, buffer, size);
+	if (ret != -EOPNOTSUPP)
+		return ret;
+
+	/* if we make this generic this needs to go... */
+	if (strcmp(name, XATTR_CAPS_SUFFIX))
+		return -EOPNOTSUPP;
+
+	ret = -ENODATA;
+	shmem_i = SHMEM_I(dentry->d_inode);
+
+	spin_lock(&dentry->d_inode->i_lock);
+	list_for_each_entry(xattr, &shmem_i->xattr_list, list) {
+		if (!strcmp(name, xattr->name)) {
+			ret = xattr->size;
+			if (buffer) {
+				if (size < xattr->size)
+					ret = -ERANGE;
+				else
+					memcpy(buffer, xattr->value, xattr->size);
+			}
+			break;
+		}
+	}
+	spin_unlock(&dentry->d_inode->i_lock);
+	return ret;
 }
 
 static int shmem_xattr_security_set(struct dentry *dentry, const char *name,
 		const void *value, size_t size, int flags, int handler_flags)
 {
+	int ret;
+	struct inode *inode = dentry->d_inode;
+	struct shmem_inode_info *shmem_i = SHMEM_I(inode);
+	struct shmem_xattr *xattr;
+	struct shmem_xattr *new_xattr;
+	size_t len;
+
 	if (strcmp(name, "") == 0)
 		return -EINVAL;
-	return security_inode_setsecurity(dentry->d_inode, name, value,
-					  size, flags);
+	ret = security_inode_setsecurity(inode, name, value, size, flags);
+	if (ret != -EOPNOTSUPP)
+		return ret;
+
+	/*
+	 * We only store fcaps for now, but this could be a lot more generic.
+	 * We could hold the prefix as well as the suffix in the xattr struct
+	 * We would also need to hold a copy of the suffix rather than a
+	 * pointer to XATTR_CAPS_SUFFIX
+	 */
+	if (strcmp(name, XATTR_CAPS_SUFFIX))
+		return -EOPNOTSUPP;
+
+	/* wrap around? */
+	len = sizeof(*new_xattr) + size;
+	if (len <= sizeof(*new_xattr))
+		return -ENOMEM;
+
+	new_xattr = kmalloc(GFP_NOFS, len);
+	if (!new_xattr)
+		return -ENOMEM;
+
+	new_xattr->name = XATTR_CAPS_SUFFIX;
+	new_xattr->size = size;
+	memcpy(new_xattr->value, value, size);
+
+	spin_lock(&inode->i_lock);
+	list_for_each_entry(xattr, &shmem_i->xattr_list, list) {
+		if (!strcmp(name, xattr->name)) {
+			list_replace(&xattr->list, &new_xattr->list);
+			goto out;
+		}
+	}
+	list_add(&new_xattr->list, &shmem_i->xattr_list);
+	xattr = NULL;
+out:
+	spin_unlock(&inode->i_lock);
+	kfree(xattr);
+	return 0;
 }
 
 static const struct xattr_handler shmem_xattr_security_handler = {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
