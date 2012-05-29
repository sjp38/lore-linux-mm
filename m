Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id 8A6496B005C
	for <linux-mm@kvack.org>; Tue, 29 May 2012 04:55:51 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so7020790pbb.14
        for <linux-mm@kvack.org>; Tue, 29 May 2012 01:55:50 -0700 (PDT)
Date: Tue, 29 May 2012 16:56:41 +0800
From: "majianpeng" <majianpeng@gmail.com>
Subject: [RFC] block_dev:Fix bug when read/write block-device which is larger than 16TB in 32bit-OS.
Message-ID: <201205291656322966937@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, viro <viro@zeniv.linux.org.uk>
Cc: linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>

The size of block-device is larger than 16TB, and the os is 32bit.
If the offset of read/write is larger then 16TB. The index of address_space will
overflow and supply data from low offset instead.

when read-operation, in function do_generic_file_read():
>index = *ppos >> PAGE_CACHE_SHIFT;
Because the *ppos is larger than 16TB and the index  is the type pgoff_t which 32bit
in 32bit-OS. So index will overflow.

When write-operation, in function generic_write_checks():
>if (likely(!isblk)) {
>		.....
>	} else {
>#ifdef CONFIG_BLOCK
>		loff_t isize;
>		if (bdev_read_only(I_BDEV(inode)))
			return -EPERM;
>		isize = i_size_read(inode);
>		if (*pos >= isize) {
>			if (*count || *pos > isize)
>				return -ENOSPC;
>		}
>
>		if (*pos + *count > isize)
>			*count = isize - *pos;
The code only check size.But continue code:
generic_file_buffered_write-->generic_perform_write-->blkdev_write_begin 
--->block_write_begin()
> pgoff_t index = pos >> PAGE_CACHE_SHIFT;
The index will overflow again.

Although filesystem has a attribute s_maxbytes, the block-device was not create so no affect.


Signed-off-by: majianpeng <majianpeng@gmail.com>
---
 fs/block_dev.c |    4 +++-
 mm/filemap.c   |   28 ++++++++++++++++++++++++++++
 2 files changed, 31 insertions(+), 1 deletion(-)

diff --git a/fs/block_dev.c b/fs/block_dev.c
index c2bbe1f..1752c0e 100644
--- a/fs/block_dev.c
+++ b/fs/block_dev.c
@@ -382,7 +382,9 @@ static loff_t block_llseek(struct file *file, loff_t offset, int origin)
 
 	mutex_lock(&bd_inode->i_mutex);
 	size = i_size_read(bd_inode);
-
+#if BITS_PER_LONG == 32
+	size = min_t(loff_t, size, (loff_t)0xFFFFFFFF * PAGE_CACHE_SIZE - 1);
+#endif
 	retval = -EINVAL;
 	switch (origin) {
 		case SEEK_END:
diff --git a/mm/filemap.c b/mm/filemap.c
index 79c4b2b..34a15bf 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1373,6 +1373,25 @@ int generic_segment_checks(const struct iovec *iov,
 }
 EXPORT_SYMBOL(generic_segment_checks);
 
+static inline
+int generic_read_block_checks(struct file *file, loff_t *pos, size_t *count)
+{
+	struct inode *inode = file->f_mapping->host;
+	loff_t isize = 0;
+#if BITS_PER_LONG == 32 && defined(CONFIG_BLOCK)
+	isize = min_t(loff_t, i_size_read(inode),
+			(loff_t)0xFFFFFFFF * PAGE_CACHE_SIZE - 1);
+	if (*pos >= isize) {
+		if (*count || *pos > isize)
+			return -ENOSPC;
+	}
+
+	if (*pos + *count > isize)
+		*count = isize - *pos;
+#endif
+	return 0;
+}
+
 /**
  * generic_file_aio_read - generic filesystem read routine
  * @iocb:	kernel I/O control block
@@ -1398,6 +1417,11 @@ generic_file_aio_read(struct kiocb *iocb, const struct iovec *iov,
 	if (retval)
 		return retval;
 
+	if (S_ISBLK(filp->f_mapping->host->i_mode)) {
+		retval = generic_read_block_checks(filp, &pos, &count);
+		if (retval)
+			return retval;
+	}
 	/* coalesce the iovecs and go direct-to-BIO for O_DIRECT */
 	if (filp->f_flags & O_DIRECT) {
 		loff_t size;
@@ -2214,6 +2238,10 @@ inline int generic_write_checks(struct file *file, loff_t *pos, size_t *count, i
 		if (bdev_read_only(I_BDEV(inode)))
 			return -EPERM;
 		isize = i_size_read(inode);
+#if BITS_PER_LONG == 32
+		isize = min_t(loff_t, isize,
+				(loff_t)0xFFFFFFFF * PAGE_CACHE_SIZE - 1);
+#endif
 		if (*pos >= isize) {
 			if (*count || *pos > isize)
 				return -ENOSPC;
-- 
1.7.9.5

 				
--------------
majianpeng
2012-05-29

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
