Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 7A8225F0019
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 14:17:43 -0400 (EDT)
From: "Eric W. Biederman" <ebiederm@xmission.com>
Date: Mon,  1 Jun 2009 14:50:40 -0700
Message-Id: <1243893048-17031-15-git-send-email-ebiederm@xmission.com>
In-Reply-To: <m1oct739xu.fsf@fess.ebiederm.org>
References: <m1oct739xu.fsf@fess.ebiederm.org>
Subject: [PATCH 15/23] vfs: Teach fallocate, and filp_close to use file_hotplug_lock
Sender: owner-linux-mm@kvack.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Hugh Dickins <hugh@veritas.com>, Tejun Heo <tj@kernel.org>, Alexey Dobriyan <adobriyan@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Greg Kroah-Hartman <gregkh@suse.de>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, "Eric W. Biederman" <ebiederm@maxwell.arastra.com>, "Eric W. Biederman" <ebiederm@aristanetworks.om>
List-ID: <linux-mm.kvack.org>

From: Eric W. Biederman <ebiederm@maxwell.arastra.com>

Signed-off-by: Eric W. Biederman <ebiederm@aristanetworks.om>
---
 fs/open.c |   22 +++++++++++++++++-----
 1 files changed, 17 insertions(+), 5 deletions(-)

diff --git a/fs/open.c b/fs/open.c
index d0b2433..83d6369 100644
--- a/fs/open.c
+++ b/fs/open.c
@@ -398,19 +398,22 @@ SYSCALL_DEFINE(fallocate)(int fd, int mode, loff_t offset, loff_t len)
 		goto out;
 	if (!(file->f_mode & FMODE_WRITE))
 		goto out_fput;
+	ret = -EIO;
+	if (!file_hotplug_read_trylock(file))
+		goto out_fput;
 	/*
 	 * Revalidate the write permissions, in case security policy has
 	 * changed since the files were opened.
 	 */
 	ret = security_file_permission(file, MAY_WRITE);
 	if (ret)
-		goto out_fput;
+		goto out_unlock;
 
 	inode = file->f_path.dentry->d_inode;
 
 	ret = -ESPIPE;
 	if (S_ISFIFO(inode->i_mode))
-		goto out_fput;
+		goto out_unlock;
 
 	ret = -ENODEV;
 	/*
@@ -418,18 +421,20 @@ SYSCALL_DEFINE(fallocate)(int fd, int mode, loff_t offset, loff_t len)
 	 * for directories or not.
 	 */
 	if (!S_ISREG(inode->i_mode) && !S_ISDIR(inode->i_mode))
-		goto out_fput;
+		goto out_unlock;
 
 	ret = -EFBIG;
 	/* Check for wrap through zero too */
 	if (((offset + len) > inode->i_sb->s_maxbytes) || ((offset + len) < 0))
-		goto out_fput;
+		goto out_unlock;
 
 	if (inode->i_op->fallocate)
 		ret = inode->i_op->fallocate(inode, mode, offset, len);
 	else
 		ret = -EOPNOTSUPP;
 
+out_unlock:
+	file_hotplug_read_unlock(file);
 out_fput:
 	fput(file);
 out:
@@ -1101,18 +1106,25 @@ SYSCALL_DEFINE2(creat, const char __user *, pathname, int, mode)
  */
 int filp_close(struct file *filp, fl_owner_t id)
 {
-	int retval = 0;
+	int retval;
 
 	if (!file_count(filp)) {
 		printk(KERN_ERR "VFS: Close: file count is 0\n");
 		return 0;
 	}
 
+	retval = -EIO;
+	if (!file_hotplug_read_trylock(filp))
+		goto out_fput;
+
+	retval = 0;
 	if (filp->f_op && filp->f_op->flush)
 		retval = filp->f_op->flush(filp, id);
 
 	dnotify_flush(filp, id);
 	locks_remove_posix(filp, id);
+	file_hotplug_read_unlock(filp);
+out_fput:
 	fput(filp);
 	return retval;
 }
-- 
1.6.3.1.54.g99dd.dirty

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
