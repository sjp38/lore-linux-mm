Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 23F8E6B00E7
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 14:17:42 -0400 (EDT)
From: "Eric W. Biederman" <ebiederm@xmission.com>
Date: Mon,  1 Jun 2009 14:50:31 -0700
Message-Id: <1243893048-17031-6-git-send-email-ebiederm@xmission.com>
In-Reply-To: <m1oct739xu.fsf@fess.ebiederm.org>
References: <m1oct739xu.fsf@fess.ebiederm.org>
Subject: [PATCH 06/23] vfs: Teach read/write to use file_hotplug_read_lock
Sender: owner-linux-mm@kvack.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Hugh Dickins <hugh@veritas.com>, Tejun Heo <tj@kernel.org>, Alexey Dobriyan <adobriyan@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Greg Kroah-Hartman <gregkh@suse.de>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, "Eric W. Biederman" <ebiederm@maxwell.arastra.com>, "Eric W. Biederman" <ebiederm@aristanetworks.com>
List-ID: <linux-mm.kvack.org>

From: Eric W. Biederman <ebiederm@maxwell.arastra.com>

Signed-off-by: Eric W. Biederman <ebiederm@aristanetworks.com>
---
 fs/compat.c     |   16 +++++++++++-
 fs/read_write.c |   70 +++++++++++++++++++++++++++++++++++++++++++++---------
 2 files changed, 72 insertions(+), 14 deletions(-)

diff --git a/fs/compat.c b/fs/compat.c
index 25be41c..dad9957 100644
--- a/fs/compat.c
+++ b/fs/compat.c
@@ -1196,12 +1196,18 @@ static size_t compat_readv(struct file *file,
 	if (!(file->f_mode & FMODE_READ))
 		goto out;
 
+	ret = -EIO;
+	if (!file_hotplug_read_trylock(file))
+		goto out;
+
 	ret = -EINVAL;
 	if (!file->f_op || (!file->f_op->aio_read && !file->f_op->read))
-		goto out;
+		goto out_unlock;
 
 	ret = compat_do_readv_writev(READ, file, vec, vlen, pos);
 
+out_unlock:
+	file_hotplug_read_unlock(file);
 out:
 	if (ret > 0)
 		add_rchar(current, ret);
@@ -1253,12 +1259,18 @@ static size_t compat_writev(struct file *file,
 	if (!(file->f_mode & FMODE_WRITE))
 		goto out;
 
+	ret = -EIO;
+	if (!file_hotplug_read_trylock(file))
+		goto out;
+
 	ret = -EINVAL;
 	if (!file->f_op || (!file->f_op->aio_write && !file->f_op->write))
-		goto out;
+		goto out_unlock;
 
 	ret = compat_do_readv_writev(WRITE, file, vec, vlen, pos);
 
+out_unlock:
+	file_hotplug_read_unlock(file);
 out:
 	if (ret > 0)
 		add_wchar(current, ret);
diff --git a/fs/read_write.c b/fs/read_write.c
index c9511ce..718baea 100644
--- a/fs/read_write.c
+++ b/fs/read_write.c
@@ -288,12 +288,18 @@ ssize_t vfs_read(struct file *file, char __user *buf, size_t count, loff_t *pos)
 {
 	ssize_t ret;
 
+	ret = -EBADF;
 	if (!(file->f_mode & FMODE_READ))
-		return -EBADF;
+		goto out;
+	ret = -EIO;
+	if (!file_hotplug_read_trylock(file))
+		goto out;
+	ret = -EINVAL;
 	if (!file->f_op || (!file->f_op->read && !file->f_op->aio_read))
-		return -EINVAL;
+		goto out_unlock;
+	ret = -EFAULT;
 	if (unlikely(!access_ok(VERIFY_WRITE, buf, count)))
-		return -EFAULT;
+		goto out_unlock;
 
 	ret = rw_verify_area(READ, file, pos, count);
 	if (ret >= 0) {
@@ -309,6 +315,9 @@ ssize_t vfs_read(struct file *file, char __user *buf, size_t count, loff_t *pos)
 		inc_syscr(current);
 	}
 
+out_unlock:
+	file_hotplug_read_unlock(file);
+out:
 	return ret;
 }
 
@@ -343,12 +352,18 @@ ssize_t vfs_write(struct file *file, const char __user *buf, size_t count, loff_
 {
 	ssize_t ret;
 
+	ret = -EBADF;
 	if (!(file->f_mode & FMODE_WRITE))
-		return -EBADF;
+		goto out;
+	ret = -EIO;
+	if (!file_hotplug_read_trylock(file))
+		goto out;
+	ret = -EINVAL;
 	if (!file->f_op || (!file->f_op->write && !file->f_op->aio_write))
-		return -EINVAL;
+		goto out_unlock;
+	ret = -EFAULT;
 	if (unlikely(!access_ok(VERIFY_READ, buf, count)))
-		return -EFAULT;
+		goto out_unlock;
 
 	ret = rw_verify_area(WRITE, file, pos, count);
 	if (ret >= 0) {
@@ -364,6 +379,9 @@ ssize_t vfs_write(struct file *file, const char __user *buf, size_t count, loff_
 		inc_syscw(current);
 	}
 
+out_unlock:
+	file_hotplug_read_unlock(file);
+out:
 	return ret;
 }
 
@@ -676,12 +694,26 @@ out:
 ssize_t vfs_readv(struct file *file, const struct iovec __user *vec,
 		  unsigned long vlen, loff_t *pos)
 {
+	ssize_t ret;
+
+	ret = -EBADF;
 	if (!(file->f_mode & FMODE_READ))
-		return -EBADF;
+		goto out;
+
+	ret = -EIO;
+	if (!file_hotplug_read_trylock(file))
+		goto out;
+
+	ret = -EINVAL;
 	if (!file->f_op || (!file->f_op->aio_read && !file->f_op->read))
-		return -EINVAL;
+		goto out_unlock;
+
+	ret = do_readv_writev(READ, file, vec, vlen, pos);
 
-	return do_readv_writev(READ, file, vec, vlen, pos);
+out_unlock:
+	file_hotplug_read_unlock(file);
+out:
+	return ret;
 }
 
 EXPORT_SYMBOL(vfs_readv);
@@ -689,12 +721,26 @@ EXPORT_SYMBOL(vfs_readv);
 ssize_t vfs_writev(struct file *file, const struct iovec __user *vec,
 		   unsigned long vlen, loff_t *pos)
 {
+	ssize_t ret;
+
+	ret = -EBADF;
 	if (!(file->f_mode & FMODE_WRITE))
-		return -EBADF;
+		goto out;
+
+	ret = -EIO;
+	if (!file_hotplug_read_trylock(file))
+		goto out;
+
+	ret = -EINVAL;
 	if (!file->f_op || (!file->f_op->aio_write && !file->f_op->write))
-		return -EINVAL;
+		goto out_unlock;
 
-	return do_readv_writev(WRITE, file, vec, vlen, pos);
+	ret = do_readv_writev(WRITE, file, vec, vlen, pos);
+
+out_unlock:
+	file_hotplug_read_unlock(file);
+out:
+	return ret;
 }
 
 EXPORT_SYMBOL(vfs_writev);
-- 
1.6.3.1.54.g99dd.dirty

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
