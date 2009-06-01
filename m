Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id AEF635F0019
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 12:45:13 -0400 (EDT)
From: "Eric W. Biederman" <ebiederm@xmission.com>
Date: Mon,  1 Jun 2009 14:50:45 -0700
Message-Id: <1243893048-17031-20-git-send-email-ebiederm@xmission.com>
In-Reply-To: <m1oct739xu.fsf@fess.ebiederm.org>
References: <m1oct739xu.fsf@fess.ebiederm.org>
Subject: [PATCH 20/23] vfs: Teach aio to use file_hotplug_lock
Sender: owner-linux-mm@kvack.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Hugh Dickins <hugh@veritas.com>, Tejun Heo <tj@kernel.org>, Alexey Dobriyan <adobriyan@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Greg Kroah-Hartman <gregkh@suse.de>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, "Eric W. Biederman" <ebiederm@maxwell.aristanetworks.com>, "Eric W. Biederman" <ebiederm@aristanetworks.com>
List-ID: <linux-mm.kvack.org>

From: Eric W. Biederman <ebiederm@maxwell.aristanetworks.com>

Signed-off-by: Eric W. Biederman <ebiederm@aristanetworks.com>
---
 fs/aio.c |   51 ++++++++++++++++++++++++++++++++++++++-------------
 1 files changed, 38 insertions(+), 13 deletions(-)

diff --git a/fs/aio.c b/fs/aio.c
index 76da125..eceb215 100644
--- a/fs/aio.c
+++ b/fs/aio.c
@@ -1362,13 +1362,20 @@ static void aio_advance_iovec(struct kiocb *iocb, ssize_t ret)
 static ssize_t aio_rw_vect_retry(struct kiocb *iocb)
 {
 	struct file *file = iocb->ki_filp;
-	struct address_space *mapping = file->f_mapping;
-	struct inode *inode = mapping->host;
+	struct address_space *mapping;
+	struct inode *inode;
 	ssize_t (*rw_op)(struct kiocb *, const struct iovec *,
 			 unsigned long, loff_t);
 	ssize_t ret = 0;
 	unsigned short opcode;
 
+	ret = -EIO;
+	if (!file_hotplug_read_trylock(file))
+		goto out;
+
+	mapping = file->f_mapping;
+	inode = mapping->host;
+
 	if ((iocb->ki_opcode == IOCB_CMD_PREADV) ||
 		(iocb->ki_opcode == IOCB_CMD_PREAD)) {
 		rw_op = file->f_op->aio_read;
@@ -1379,8 +1386,9 @@ static ssize_t aio_rw_vect_retry(struct kiocb *iocb)
 	}
 
 	/* This matches the pread()/pwrite() logic */
+	ret = -EINVAL;
 	if (iocb->ki_pos < 0)
-		return -EINVAL;
+		goto out_unlock;
 
 	do {
 		ret = rw_op(iocb, &iocb->ki_iovec[iocb->ki_cur_seg],
@@ -1407,26 +1415,37 @@ static ssize_t aio_rw_vect_retry(struct kiocb *iocb)
 	    && iocb->ki_nbytes - iocb->ki_left)
 		ret = iocb->ki_nbytes - iocb->ki_left;
 
+out_unlock:
+	file_hotplug_read_unlock(file);
+out:
 	return ret;
 }
 
 static ssize_t aio_fdsync(struct kiocb *iocb)
 {
 	struct file *file = iocb->ki_filp;
-	ssize_t ret = -EINVAL;
+	ssize_t ret = -EIO;
 
-	if (file->f_op->aio_fsync)
-		ret = file->f_op->aio_fsync(iocb, 1);
+	if (file_hotplug_read_trylock(file)) {
+		ret = -EINVAL;
+		if (file->f_op->aio_fsync)
+			ret = file->f_op->aio_fsync(iocb, 1);
+		file_hotplug_read_unlock(file);
+	}
 	return ret;
 }
 
 static ssize_t aio_fsync(struct kiocb *iocb)
 {
 	struct file *file = iocb->ki_filp;
-	ssize_t ret = -EINVAL;
+	ssize_t ret = -EIO;
 
-	if (file->f_op->aio_fsync)
-		ret = file->f_op->aio_fsync(iocb, 0);
+	if (file_hotplug_read_trylock(file)) {
+		ret = -EINVAL;
+		if (file->f_op->aio_fsync)
+			ret = file->f_op->aio_fsync(iocb, 0);
+		file_hotplug_read_unlock(file);
+	}
 	return ret;
 }
 
@@ -1469,7 +1488,11 @@ static ssize_t aio_setup_single_vector(struct kiocb *kiocb)
 static ssize_t aio_setup_iocb(struct kiocb *kiocb)
 {
 	struct file *file = kiocb->ki_filp;
-	ssize_t ret = 0;
+	ssize_t ret;
+
+	ret = -EIO;
+	if (!file_hotplug_read_trylock(file))
+		goto out;
 
 	switch (kiocb->ki_opcode) {
 	case IOCB_CMD_PREAD:
@@ -1551,10 +1574,12 @@ static ssize_t aio_setup_iocb(struct kiocb *kiocb)
 		ret = -EINVAL;
 	}
 
-	if (!kiocb->ki_retry)
-		return ret;
+	if (kiocb->ki_retry)
+		ret = 0;
 
-	return 0;
+	file_hotplug_read_unlock(file);
+out:
+	return ret;
 }
 
 /*
-- 
1.6.3.1.54.g99dd.dirty

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
