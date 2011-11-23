Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 5F8676B00C0
	for <linux-mm@kvack.org>; Wed, 23 Nov 2011 03:53:59 -0500 (EST)
From: Cong Wang <amwang@redhat.com>
Subject: [V3 PATCH 1/2] tmpfs: add fallocate support
Date: Wed, 23 Nov 2011 16:53:30 +0800
Message-Id: <1322038412-29013-1-git-send-email-amwang@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org, Pekka Enberg <penberg@kernel.org>, Christoph Hellwig <hch@lst.de>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Lennart Poettering <lennart@poettering.net>, Kay Sievers <kay.sievers@vrfy.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, WANG Cong <amwang@redhat.com>, linux-mm@kvack.org

Systemd needs tmpfs to support fallocate [1], to be able
to safely use mmap(), regarding SIGBUS, on files on the
/dev/shm filesystem. The glibc fallback loop for -ENOSYS
on fallocate is just ugly.

This patch adds fallocate support to tmpfs, and as we
already have shmem_truncate_range(), it is also easy to
add FALLOC_FL_PUNCH_HOLE support too.

1. http://lkml.org/lkml/2011/10/20/275

V2->V3:
a) Read i_size directly after holding i_mutex;
b) Call page_cache_release() too after shmem_getpage();
c) Undo previous changes when -ENOSPC.

Cc: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Hellwig <hch@lst.de>
Cc: Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Lennart Poettering <lennart@poettering.net>
Cc: Kay Sievers <kay.sievers@vrfy.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Signed-off-by: WANG Cong <amwang@redhat.com>

---
 mm/shmem.c |   65 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 65 insertions(+), 0 deletions(-)

diff --git a/mm/shmem.c b/mm/shmem.c
index d672250..65f7a27 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -30,6 +30,7 @@
 #include <linux/mm.h>
 #include <linux/export.h>
 #include <linux/swap.h>
+#include <linux/falloc.h>
 
 static struct vfsmount *shm_mnt;
 
@@ -1431,6 +1432,69 @@ static ssize_t shmem_file_splice_read(struct file *in, loff_t *ppos,
 	return error;
 }
 
+static void shmem_truncate_page(struct inode *inode, pgoff_t index)
+{
+	loff_t start = index << PAGE_CACHE_SHIFT;
+	loff_t end = ((index + 1) << PAGE_CACHE_SHIFT) - 1;
+	shmem_truncate_range(inode, start, end);
+}
+
+static long shmem_fallocate(struct file *file, int mode,
+				loff_t offset, loff_t len)
+{
+	struct inode *inode = file->f_path.dentry->d_inode;
+	pgoff_t start = offset >> PAGE_CACHE_SHIFT;
+	pgoff_t end = DIV_ROUND_UP((offset + len), PAGE_CACHE_SIZE);
+	pgoff_t index = start;
+	loff_t i_size;
+	struct page *page = NULL;
+	int ret = 0;
+
+	mutex_lock(&inode->i_mutex);
+	i_size = inode->i_size;
+	if (mode & FALLOC_FL_PUNCH_HOLE) {
+		if (!(offset > i_size || (end << PAGE_CACHE_SHIFT) > i_size))
+			shmem_truncate_range(inode, offset,
+					     (end << PAGE_CACHE_SHIFT) - 1);
+		goto unlock;
+	}
+
+	if (!(mode & FALLOC_FL_KEEP_SIZE)) {
+		ret = inode_newsize_ok(inode, (offset + len));
+		if (ret)
+			goto unlock;
+	}
+
+	while (index < end) {
+		ret = shmem_getpage(inode, index, &page, SGP_WRITE, NULL);
+		if (ret) {
+			if (ret == -ENOSPC)
+				goto undo;
+			else
+				goto unlock;
+		}
+		if (page) {
+			unlock_page(page);
+			page_cache_release(page);
+		}
+		index++;
+	}
+	if (!(mode & FALLOC_FL_KEEP_SIZE) && (index << PAGE_CACHE_SHIFT) > i_size)
+		i_size_write(inode, index << PAGE_CACHE_SHIFT);
+
+	goto unlock;
+
+undo:
+	while (index > start) {
+		shmem_truncate_page(inode, index);
+		index--;
+	}
+
+unlock:
+	mutex_unlock(&inode->i_mutex);
+	return ret;
+}
+
 static int shmem_statfs(struct dentry *dentry, struct kstatfs *buf)
 {
 	struct shmem_sb_info *sbinfo = SHMEM_SB(dentry->d_sb);
@@ -2286,6 +2350,7 @@ static const struct file_operations shmem_file_operations = {
 	.fsync		= noop_fsync,
 	.splice_read	= shmem_file_splice_read,
 	.splice_write	= generic_file_splice_write,
+	.fallocate	= shmem_fallocate,
 #endif
 };
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
