Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 500B06B00E9
	for <linux-mm@kvack.org>; Tue, 15 May 2012 02:58:04 -0400 (EDT)
From: Cong Wang <amwang@redhat.com>
Subject: [PATCH 2/2] fs: move file_remove_suid() to fs/inode.c
Date: Tue, 15 May 2012 14:57:33 +0800
Message-Id: <1337065058-310-2-git-send-email-amwang@redhat.com>
In-Reply-To: <1337065058-310-1-git-send-email-amwang@redhat.com>
References: <1337065058-310-1-git-send-email-amwang@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Cong Wang <xiyou.wangcong@gmail.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Fengguang Wu <fengguang.wu@intel.com>, Minchan Kim <minchan.kim@gmail.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

From: Cong Wang <xiyou.wangcong@gmail.com>

file_remove_suid() is a generic function operates on struct file,
it almost has no relations with file mapping, so move it to fs/inode.c.

Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 fs/inode.c   |   65 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 mm/filemap.c |   65 ----------------------------------------------------------
 2 files changed, 65 insertions(+), 65 deletions(-)

diff --git a/fs/inode.c b/fs/inode.c
index 9f4f5fe..1f9627d 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -1524,6 +1524,71 @@ void touch_atime(struct path *path)
 }
 EXPORT_SYMBOL(touch_atime);
 
+/*
+ * The logic we want is
+ *
+ *	if suid or (sgid and xgrp)
+ *		remove privs
+ */
+int should_remove_suid(struct dentry *dentry)
+{
+	umode_t mode = dentry->d_inode->i_mode;
+	int kill = 0;
+
+	/* suid always must be killed */
+	if (unlikely(mode & S_ISUID))
+		kill = ATTR_KILL_SUID;
+
+	/*
+	 * sgid without any exec bits is just a mandatory locking mark; leave
+	 * it alone.  If some exec bits are set, it's a real sgid; kill it.
+	 */
+	if (unlikely((mode & S_ISGID) && (mode & S_IXGRP)))
+		kill |= ATTR_KILL_SGID;
+
+	if (unlikely(kill && !capable(CAP_FSETID) && S_ISREG(mode)))
+		return kill;
+
+	return 0;
+}
+EXPORT_SYMBOL(should_remove_suid);
+
+static int __remove_suid(struct dentry *dentry, int kill)
+{
+	struct iattr newattrs;
+
+	newattrs.ia_valid = ATTR_FORCE | kill;
+	return notify_change(dentry, &newattrs);
+}
+
+int file_remove_suid(struct file *file)
+{
+	struct dentry *dentry = file->f_path.dentry;
+	struct inode *inode = dentry->d_inode;
+	int killsuid;
+	int killpriv;
+	int error = 0;
+
+	/* Fast path for nothing security related */
+	if (IS_NOSEC(inode))
+		return 0;
+
+	killsuid = should_remove_suid(dentry);
+	killpriv = security_inode_need_killpriv(dentry);
+
+	if (killpriv < 0)
+		return killpriv;
+	if (killpriv)
+		error = security_inode_killpriv(dentry);
+	if (!error && killsuid)
+		error = __remove_suid(dentry, killsuid);
+	if (!error && (inode->i_sb->s_flags & MS_NOSEC))
+		inode->i_flags |= S_NOSEC;
+
+	return error;
+}
+EXPORT_SYMBOL(file_remove_suid);
+
 /**
  *	file_update_time	-	update mtime and ctime time
  *	@file: file accessed
diff --git a/mm/filemap.c b/mm/filemap.c
index 64b48f9..b70e777 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1899,71 +1899,6 @@ struct page *read_cache_page(struct address_space *mapping,
 }
 EXPORT_SYMBOL(read_cache_page);
 
-/*
- * The logic we want is
- *
- *	if suid or (sgid and xgrp)
- *		remove privs
- */
-int should_remove_suid(struct dentry *dentry)
-{
-	umode_t mode = dentry->d_inode->i_mode;
-	int kill = 0;
-
-	/* suid always must be killed */
-	if (unlikely(mode & S_ISUID))
-		kill = ATTR_KILL_SUID;
-
-	/*
-	 * sgid without any exec bits is just a mandatory locking mark; leave
-	 * it alone.  If some exec bits are set, it's a real sgid; kill it.
-	 */
-	if (unlikely((mode & S_ISGID) && (mode & S_IXGRP)))
-		kill |= ATTR_KILL_SGID;
-
-	if (unlikely(kill && !capable(CAP_FSETID) && S_ISREG(mode)))
-		return kill;
-
-	return 0;
-}
-EXPORT_SYMBOL(should_remove_suid);
-
-static int __remove_suid(struct dentry *dentry, int kill)
-{
-	struct iattr newattrs;
-
-	newattrs.ia_valid = ATTR_FORCE | kill;
-	return notify_change(dentry, &newattrs);
-}
-
-int file_remove_suid(struct file *file)
-{
-	struct dentry *dentry = file->f_path.dentry;
-	struct inode *inode = dentry->d_inode;
-	int killsuid;
-	int killpriv;
-	int error = 0;
-
-	/* Fast path for nothing security related */
-	if (IS_NOSEC(inode))
-		return 0;
-
-	killsuid = should_remove_suid(dentry);
-	killpriv = security_inode_need_killpriv(dentry);
-
-	if (killpriv < 0)
-		return killpriv;
-	if (killpriv)
-		error = security_inode_killpriv(dentry);
-	if (!error && killsuid)
-		error = __remove_suid(dentry, killsuid);
-	if (!error && (inode->i_sb->s_flags & MS_NOSEC))
-		inode->i_flags |= S_NOSEC;
-
-	return error;
-}
-EXPORT_SYMBOL(file_remove_suid);
-
 static size_t __iovec_copy_from_user_inatomic(char *vaddr,
 			const struct iovec *iov, size_t base, size_t bytes)
 {
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
