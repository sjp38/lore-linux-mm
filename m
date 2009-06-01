Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id A05FA5F002A
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 14:17:43 -0400 (EDT)
From: "Eric W. Biederman" <ebiederm@xmission.com>
Date: Mon,  1 Jun 2009 14:50:33 -0700
Message-Id: <1243893048-17031-8-git-send-email-ebiederm@xmission.com>
In-Reply-To: <m1oct739xu.fsf@fess.ebiederm.org>
References: <m1oct739xu.fsf@fess.ebiederm.org>
Subject: [PATCH 08/23] vfs: Teach readdir to use file_hotplug_lock
Sender: owner-linux-mm@kvack.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Hugh Dickins <hugh@veritas.com>, Tejun Heo <tj@kernel.org>, Alexey Dobriyan <adobriyan@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Greg Kroah-Hartman <gregkh@suse.de>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, "Eric W. Biederman" <ebiederm@maxwell.arastra.com>, "Eric W. Biederman" <ebiederm@aristanetworks.com>
List-ID: <linux-mm.kvack.org>

From: Eric W. Biederman <ebiederm@maxwell.arastra.com>

Signed-off-by: Eric W. Biederman <ebiederm@aristanetworks.com>
---
 fs/readdir.c |   20 +++++++++++++++-----
 1 files changed, 15 insertions(+), 5 deletions(-)

diff --git a/fs/readdir.c b/fs/readdir.c
index 7723401..2e147cf 100644
--- a/fs/readdir.c
+++ b/fs/readdir.c
@@ -21,18 +21,26 @@
 
 int vfs_readdir(struct file *file, filldir_t filler, void *buf)
 {
-	struct inode *inode = file->f_path.dentry->d_inode;
-	int res = -ENOTDIR;
-	if (!file->f_op || !file->f_op->readdir)
+	struct inode *inode;
+	int res;
+
+	res = -EIO;
+	if (!file_hotplug_read_trylock(file))
 		goto out;
 
+	inode = file->f_path.dentry->d_inode;
+
+	res = -ENOTDIR;
+	if (!file->f_op || !file->f_op->readdir)
+		goto out_unlock;
+
 	res = security_file_permission(file, MAY_READ);
 	if (res)
-		goto out;
+		goto out_unlock;
 
 	res = mutex_lock_killable(&inode->i_mutex);
 	if (res)
-		goto out;
+		goto out_unlock;
 
 	res = -ENOENT;
 	if (!IS_DEADDIR(inode)) {
@@ -40,6 +48,8 @@ int vfs_readdir(struct file *file, filldir_t filler, void *buf)
 		file_accessed(file);
 	}
 	mutex_unlock(&inode->i_mutex);
+out_unlock:
+	file_hotplug_read_unlock(file);
 out:
 	return res;
 }
-- 
1.6.3.1.54.g99dd.dirty

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
