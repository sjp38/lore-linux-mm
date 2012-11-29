Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id 0C2C76B0081
	for <linux-mm@kvack.org>; Thu, 29 Nov 2012 17:59:26 -0500 (EST)
Date: Thu, 29 Nov 2012 14:59:24 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] tmpfs: support SEEK_DATA and SEEK_HOLE (reprise)
Message-Id: <20121129145924.9fb05982.akpm@linux-foundation.org>
In-Reply-To: <alpine.LNX.2.00.1211281706390.1516@eggly.anvils>
References: <alpine.LNX.2.00.1211281706390.1516@eggly.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Theodore Ts'o <tytso@mit.edu>, Zheng Liu <wenqing.lz@taobao.com>, Jeff liu <jeff.liu@oracle.com>, Jim Meyering <jim@meyering.net>, Paul Eggert <eggert@cs.ucla.edu>, Christoph Hellwig <hch@infradead.org>, Josef Bacik <josef@redhat.com>, Andi Kleen <andi@firstfloor.org>, Andreas Dilger <adilger@dilger.ca>, Dave Chinner <david@fromorbit.com>, Marco Stornelli <marco.stornelli@gmail.com>, Chris Mason <chris.mason@fusionio.com>, Sunil Mushran <sunil.mushran@oracle.com>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Wed, 28 Nov 2012 17:22:03 -0800 (PST)
Hugh Dickins <hughd@google.com> wrote:

> Revert 3.5's f21f8062201f ("tmpfs: revert SEEK_DATA and SEEK_HOLE")
> to reinstate 4fb5ef089b28 ("tmpfs: support SEEK_DATA and SEEK_HOLE"),
> with the intervening additional arg to generic_file_llseek_size().
> 
> In 3.8, ext4 is expected to join btrfs, ocfs2 and xfs with proper
> SEEK_DATA and SEEK_HOLE support; and a good case has now been made
> for it on tmpfs, so let's join the party.
> 
> It's quite easy for tmpfs to scan the radix_tree to support llseek's new
> SEEK_DATA and SEEK_HOLE options: so add them while the minutiae are still
> on my mind (in particular, the !PageUptodate-ness of pages fallocated but
> still unwritten).
> 
> ...
>

> +/*
> + * llseek SEEK_DATA or SEEK_HOLE through the radix_tree.
> + */
> +static pgoff_t shmem_seek_hole_data(struct address_space *mapping,
> +				    pgoff_t index, pgoff_t end, int origin)

So I was starting at this wondering what on earth "origin" is and why
it has the fishy-in-this-context type "int".

There is a pretty well established convention that the lseek seek mode
is called "whence".

The below gets most of it.  Too anal?


From: Andrew Morton <akpm@linux-foundation.org>
Subject: lseek: the "whence" argument is called "whence"

But the kernel decided to call it "origin" instead.  Fix most of the
sites.

Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 fs/bad_inode.c           |    2 -
 fs/block_dev.c           |    4 +--
 fs/btrfs/file.c          |   16 +++++++-------
 fs/ceph/dir.c            |    4 +--
 fs/ceph/file.c           |    6 ++---
 fs/cifs/cifsfs.c         |    8 +++----
 fs/configfs/dir.c        |    4 +--
 fs/ext3/dir.c            |    6 ++---
 fs/ext4/dir.c            |    6 ++---
 fs/ext4/file.c           |   22 ++++++++++----------
 fs/fuse/file.c           |    8 +++----
 fs/gfs2/file.c           |   10 ++++-----
 fs/libfs.c               |    4 +--
 fs/nfs/dir.c             |    6 ++---
 fs/nfs/file.c            |   10 ++++-----
 fs/ocfs2/extent_map.c    |   12 +++++------
 fs/ocfs2/file.c          |    6 ++---
 fs/pstore/inode.c        |    6 ++---
 fs/read_write.c          |   40 ++++++++++++++++++-------------------
 fs/seq_file.c            |    4 +--
 fs/ubifs/dir.c           |    4 +--
 include/linux/fs.h       |   12 +++++------
 include/linux/ftrace.h   |    4 +--
 include/linux/syscalls.h |    4 +--
 kernel/trace/ftrace.c    |    4 +--
 mm/shmem.c               |   20 +++++++++---------
 26 files changed, 116 insertions(+), 116 deletions(-)

diff -puN fs/read_write.c~lseek-the-whence-argument-is-called-whence fs/read_write.c
--- a/fs/read_write.c~lseek-the-whence-argument-is-called-whence
+++ a/fs/read_write.c
@@ -54,7 +54,7 @@ static loff_t lseek_execute(struct file 
  * generic_file_llseek_size - generic llseek implementation for regular files
  * @file:	file structure to seek on
  * @offset:	file offset to seek to
- * @origin:	type of seek
+ * @whence:	type of seek
  * @size:	max size of this file in file system
  * @eof:	offset used for SEEK_END position
  *
@@ -67,12 +67,12 @@ static loff_t lseek_execute(struct file 
  * read/writes behave like SEEK_SET against seeks.
  */
 loff_t
-generic_file_llseek_size(struct file *file, loff_t offset, int origin,
+generic_file_llseek_size(struct file *file, loff_t offset, int whence,
 		loff_t maxsize, loff_t eof)
 {
 	struct inode *inode = file->f_mapping->host;
 
-	switch (origin) {
+	switch (whence) {
 	case SEEK_END:
 		offset += eof;
 		break;
@@ -122,17 +122,17 @@ EXPORT_SYMBOL(generic_file_llseek_size);
  * generic_file_llseek - generic llseek implementation for regular files
  * @file:	file structure to seek on
  * @offset:	file offset to seek to
- * @origin:	type of seek
+ * @whence:	type of seek
  *
  * This is a generic implemenation of ->llseek useable for all normal local
  * filesystems.  It just updates the file offset to the value specified by
- * @offset and @origin under i_mutex.
+ * @offset and @whence under i_mutex.
  */
-loff_t generic_file_llseek(struct file *file, loff_t offset, int origin)
+loff_t generic_file_llseek(struct file *file, loff_t offset, int whence)
 {
 	struct inode *inode = file->f_mapping->host;
 
-	return generic_file_llseek_size(file, offset, origin,
+	return generic_file_llseek_size(file, offset, whence,
 					inode->i_sb->s_maxbytes,
 					i_size_read(inode));
 }
@@ -142,32 +142,32 @@ EXPORT_SYMBOL(generic_file_llseek);
  * noop_llseek - No Operation Performed llseek implementation
  * @file:	file structure to seek on
  * @offset:	file offset to seek to
- * @origin:	type of seek
+ * @whence:	type of seek
  *
  * This is an implementation of ->llseek useable for the rare special case when
  * userspace expects the seek to succeed but the (device) file is actually not
  * able to perform the seek. In this case you use noop_llseek() instead of
  * falling back to the default implementation of ->llseek.
  */
-loff_t noop_llseek(struct file *file, loff_t offset, int origin)
+loff_t noop_llseek(struct file *file, loff_t offset, int whence)
 {
 	return file->f_pos;
 }
 EXPORT_SYMBOL(noop_llseek);
 
-loff_t no_llseek(struct file *file, loff_t offset, int origin)
+loff_t no_llseek(struct file *file, loff_t offset, int whence)
 {
 	return -ESPIPE;
 }
 EXPORT_SYMBOL(no_llseek);
 
-loff_t default_llseek(struct file *file, loff_t offset, int origin)
+loff_t default_llseek(struct file *file, loff_t offset, int whence)
 {
 	struct inode *inode = file->f_path.dentry->d_inode;
 	loff_t retval;
 
 	mutex_lock(&inode->i_mutex);
-	switch (origin) {
+	switch (whence) {
 		case SEEK_END:
 			offset += i_size_read(inode);
 			break;
@@ -216,7 +216,7 @@ out:
 }
 EXPORT_SYMBOL(default_llseek);
 
-loff_t vfs_llseek(struct file *file, loff_t offset, int origin)
+loff_t vfs_llseek(struct file *file, loff_t offset, int whence)
 {
 	loff_t (*fn)(struct file *, loff_t, int);
 
@@ -225,11 +225,11 @@ loff_t vfs_llseek(struct file *file, lof
 		if (file->f_op && file->f_op->llseek)
 			fn = file->f_op->llseek;
 	}
-	return fn(file, offset, origin);
+	return fn(file, offset, whence);
 }
 EXPORT_SYMBOL(vfs_llseek);
 
-SYSCALL_DEFINE3(lseek, unsigned int, fd, off_t, offset, unsigned int, origin)
+SYSCALL_DEFINE3(lseek, unsigned int, fd, off_t, offset, unsigned int, whence)
 {
 	off_t retval;
 	struct fd f = fdget(fd);
@@ -237,8 +237,8 @@ SYSCALL_DEFINE3(lseek, unsigned int, fd,
 		return -EBADF;
 
 	retval = -EINVAL;
-	if (origin <= SEEK_MAX) {
-		loff_t res = vfs_llseek(f.file, offset, origin);
+	if (whence <= SEEK_MAX) {
+		loff_t res = vfs_llseek(f.file, offset, whence);
 		retval = res;
 		if (res != (loff_t)retval)
 			retval = -EOVERFLOW;	/* LFS: should only happen on 32 bit platforms */
@@ -250,7 +250,7 @@ SYSCALL_DEFINE3(lseek, unsigned int, fd,
 #ifdef __ARCH_WANT_SYS_LLSEEK
 SYSCALL_DEFINE5(llseek, unsigned int, fd, unsigned long, offset_high,
 		unsigned long, offset_low, loff_t __user *, result,
-		unsigned int, origin)
+		unsigned int, whence)
 {
 	int retval;
 	struct fd f = fdget(fd);
@@ -260,11 +260,11 @@ SYSCALL_DEFINE5(llseek, unsigned int, fd
 		return -EBADF;
 
 	retval = -EINVAL;
-	if (origin > SEEK_MAX)
+	if (whence > SEEK_MAX)
 		goto out_putf;
 
 	offset = vfs_llseek(f.file, ((loff_t) offset_high << 32) | offset_low,
-			origin);
+			whence);
 
 	retval = (int)offset;
 	if (offset >= 0) {
diff -puN include/linux/fs.h~lseek-the-whence-argument-is-called-whence include/linux/fs.h
--- a/include/linux/fs.h~lseek-the-whence-argument-is-called-whence
+++ a/include/linux/fs.h
@@ -2291,9 +2291,9 @@ extern ino_t find_inode_number(struct de
 #include <linux/err.h>
 
 /* needed for stackable file system support */
-extern loff_t default_llseek(struct file *file, loff_t offset, int origin);
+extern loff_t default_llseek(struct file *file, loff_t offset, int whence);
 
-extern loff_t vfs_llseek(struct file *file, loff_t offset, int origin);
+extern loff_t vfs_llseek(struct file *file, loff_t offset, int whence);
 
 extern int inode_init_always(struct super_block *, struct inode *);
 extern void inode_init_once(struct inode *);
@@ -2403,11 +2403,11 @@ extern long do_splice_direct(struct file
 
 extern void
 file_ra_state_init(struct file_ra_state *ra, struct address_space *mapping);
-extern loff_t noop_llseek(struct file *file, loff_t offset, int origin);
-extern loff_t no_llseek(struct file *file, loff_t offset, int origin);
-extern loff_t generic_file_llseek(struct file *file, loff_t offset, int origin);
+extern loff_t noop_llseek(struct file *file, loff_t offset, int whence);
+extern loff_t no_llseek(struct file *file, loff_t offset, int whence);
+extern loff_t generic_file_llseek(struct file *file, loff_t offset, int whence);
 extern loff_t generic_file_llseek_size(struct file *file, loff_t offset,
-		int origin, loff_t maxsize, loff_t eof);
+		int whence, loff_t maxsize, loff_t eof);
 extern int generic_file_open(struct inode * inode, struct file * filp);
 extern int nonseekable_open(struct inode * inode, struct file * filp);
 
diff -puN mm/shmem.c~lseek-the-whence-argument-is-called-whence mm/shmem.c
--- a/mm/shmem.c~lseek-the-whence-argument-is-called-whence
+++ a/mm/shmem.c
@@ -1714,7 +1714,7 @@ static ssize_t shmem_file_splice_read(st
  * llseek SEEK_DATA or SEEK_HOLE through the radix_tree.
  */
 static pgoff_t shmem_seek_hole_data(struct address_space *mapping,
-				    pgoff_t index, pgoff_t end, int origin)
+				    pgoff_t index, pgoff_t end, int whence)
 {
 	struct page *page;
 	struct pagevec pvec;
@@ -1728,13 +1728,13 @@ static pgoff_t shmem_seek_hole_data(stru
 		pvec.nr = shmem_find_get_pages_and_swap(mapping, index,
 					pvec.nr, pvec.pages, indices);
 		if (!pvec.nr) {
-			if (origin == SEEK_DATA)
+			if (whence == SEEK_DATA)
 				index = end;
 			break;
 		}
 		for (i = 0; i < pvec.nr; i++, index++) {
 			if (index < indices[i]) {
-				if (origin == SEEK_HOLE) {
+				if (whence == SEEK_HOLE) {
 					done = true;
 					break;
 				}
@@ -1746,8 +1746,8 @@ static pgoff_t shmem_seek_hole_data(stru
 					page = NULL;
 			}
 			if (index >= end ||
-			    (page && origin == SEEK_DATA) ||
-			    (!page && origin == SEEK_HOLE)) {
+			    (page && whence == SEEK_DATA) ||
+			    (!page && whence == SEEK_HOLE)) {
 				done = true;
 				break;
 			}
@@ -1760,15 +1760,15 @@ static pgoff_t shmem_seek_hole_data(stru
 	return index;
 }
 
-static loff_t shmem_file_llseek(struct file *file, loff_t offset, int origin)
+static loff_t shmem_file_llseek(struct file *file, loff_t offset, int whence)
 {
 	struct address_space *mapping = file->f_mapping;
 	struct inode *inode = mapping->host;
 	pgoff_t start, end;
 	loff_t new_offset;
 
-	if (origin != SEEK_DATA && origin != SEEK_HOLE)
-		return generic_file_llseek_size(file, offset, origin,
+	if (whence != SEEK_DATA && whence != SEEK_HOLE)
+		return generic_file_llseek_size(file, offset, whence,
 					MAX_LFS_FILESIZE, i_size_read(inode));
 	mutex_lock(&inode->i_mutex);
 	/* We're holding i_mutex so we can access i_size directly */
@@ -1780,12 +1780,12 @@ static loff_t shmem_file_llseek(struct f
 	else {
 		start = offset >> PAGE_CACHE_SHIFT;
 		end = (inode->i_size + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
-		new_offset = shmem_seek_hole_data(mapping, start, end, origin);
+		new_offset = shmem_seek_hole_data(mapping, start, end, whence);
 		new_offset <<= PAGE_CACHE_SHIFT;
 		if (new_offset > offset) {
 			if (new_offset < inode->i_size)
 				offset = new_offset;
-			else if (origin == SEEK_DATA)
+			else if (whence == SEEK_DATA)
 				offset = -ENXIO;
 			else
 				offset = inode->i_size;
diff -puN fs/bad_inode.c~lseek-the-whence-argument-is-called-whence fs/bad_inode.c
--- a/fs/bad_inode.c~lseek-the-whence-argument-is-called-whence
+++ a/fs/bad_inode.c
@@ -16,7 +16,7 @@
 #include <linux/poll.h>
 
 
-static loff_t bad_file_llseek(struct file *file, loff_t offset, int origin)
+static loff_t bad_file_llseek(struct file *file, loff_t offset, int whence)
 {
 	return -EIO;
 }
diff -puN fs/block_dev.c~lseek-the-whence-argument-is-called-whence fs/block_dev.c
--- a/fs/block_dev.c~lseek-the-whence-argument-is-called-whence
+++ a/fs/block_dev.c
@@ -392,7 +392,7 @@ static int blkdev_write_end(struct file 
  * for a block special file file->f_path.dentry->d_inode->i_size is zero
  * so we compute the size by hand (just as in block_read/write above)
  */
-static loff_t block_llseek(struct file *file, loff_t offset, int origin)
+static loff_t block_llseek(struct file *file, loff_t offset, int whence)
 {
 	struct inode *bd_inode = file->f_mapping->host;
 	loff_t size;
@@ -402,7 +402,7 @@ static loff_t block_llseek(struct file *
 	size = i_size_read(bd_inode);
 
 	retval = -EINVAL;
-	switch (origin) {
+	switch (whence) {
 		case SEEK_END:
 			offset += size;
 			break;
diff -puN fs/libfs.c~lseek-the-whence-argument-is-called-whence fs/libfs.c
--- a/fs/libfs.c~lseek-the-whence-argument-is-called-whence
+++ a/fs/libfs.c
@@ -81,11 +81,11 @@ int dcache_dir_close(struct inode *inode
 	return 0;
 }
 
-loff_t dcache_dir_lseek(struct file *file, loff_t offset, int origin)
+loff_t dcache_dir_lseek(struct file *file, loff_t offset, int whence)
 {
 	struct dentry *dentry = file->f_path.dentry;
 	mutex_lock(&dentry->d_inode->i_mutex);
-	switch (origin) {
+	switch (whence) {
 		case 1:
 			offset += file->f_pos;
 		case 0:
diff -puN fs/seq_file.c~lseek-the-whence-argument-is-called-whence fs/seq_file.c
--- a/fs/seq_file.c~lseek-the-whence-argument-is-called-whence
+++ a/fs/seq_file.c
@@ -300,14 +300,14 @@ EXPORT_SYMBOL(seq_read);
  *
  *	Ready-made ->f_op->llseek()
  */
-loff_t seq_lseek(struct file *file, loff_t offset, int origin)
+loff_t seq_lseek(struct file *file, loff_t offset, int whence)
 {
 	struct seq_file *m = file->private_data;
 	loff_t retval = -EINVAL;
 
 	mutex_lock(&m->lock);
 	m->version = file->f_version;
-	switch (origin) {
+	switch (whence) {
 		case 1:
 			offset += file->f_pos;
 		case 0:
diff -puN include/linux/ftrace.h~lseek-the-whence-argument-is-called-whence include/linux/ftrace.h
--- a/include/linux/ftrace.h~lseek-the-whence-argument-is-called-whence
+++ a/include/linux/ftrace.h
@@ -394,7 +394,7 @@ ssize_t ftrace_filter_write(struct file 
 			    size_t cnt, loff_t *ppos);
 ssize_t ftrace_notrace_write(struct file *file, const char __user *ubuf,
 			     size_t cnt, loff_t *ppos);
-loff_t ftrace_regex_lseek(struct file *file, loff_t offset, int origin);
+loff_t ftrace_regex_lseek(struct file *file, loff_t offset, int whence);
 int ftrace_regex_release(struct inode *inode, struct file *file);
 
 void __init
@@ -559,7 +559,7 @@ static inline ssize_t ftrace_filter_writ
 			    size_t cnt, loff_t *ppos) { return -ENODEV; }
 static inline ssize_t ftrace_notrace_write(struct file *file, const char __user *ubuf,
 			     size_t cnt, loff_t *ppos) { return -ENODEV; }
-static inline loff_t ftrace_regex_lseek(struct file *file, loff_t offset, int origin)
+static inline loff_t ftrace_regex_lseek(struct file *file, loff_t offset, int whence)
 {
 	return -ENODEV;
 }
diff -puN include/linux/syscalls.h~lseek-the-whence-argument-is-called-whence include/linux/syscalls.h
--- a/include/linux/syscalls.h~lseek-the-whence-argument-is-called-whence
+++ a/include/linux/syscalls.h
@@ -560,10 +560,10 @@ asmlinkage long sys_utime(char __user *f
 asmlinkage long sys_utimes(char __user *filename,
 				struct timeval __user *utimes);
 asmlinkage long sys_lseek(unsigned int fd, off_t offset,
-			  unsigned int origin);
+			  unsigned int whence);
 asmlinkage long sys_llseek(unsigned int fd, unsigned long offset_high,
 			unsigned long offset_low, loff_t __user *result,
-			unsigned int origin);
+			unsigned int whence);
 asmlinkage long sys_read(unsigned int fd, char __user *buf, size_t count);
 asmlinkage long sys_readahead(int fd, loff_t offset, size_t count);
 asmlinkage long sys_readv(unsigned long fd,
diff -puN kernel/trace/ftrace.c~lseek-the-whence-argument-is-called-whence kernel/trace/ftrace.c
--- a/kernel/trace/ftrace.c~lseek-the-whence-argument-is-called-whence
+++ a/kernel/trace/ftrace.c
@@ -2675,12 +2675,12 @@ ftrace_notrace_open(struct inode *inode,
 }
 
 loff_t
-ftrace_regex_lseek(struct file *file, loff_t offset, int origin)
+ftrace_regex_lseek(struct file *file, loff_t offset, int whence)
 {
 	loff_t ret;
 
 	if (file->f_mode & FMODE_READ)
-		ret = seq_lseek(file, offset, origin);
+		ret = seq_lseek(file, offset, whence);
 	else
 		file->f_pos = ret = 1;
 
diff -puN fs/btrfs/file.c~lseek-the-whence-argument-is-called-whence fs/btrfs/file.c
--- a/fs/btrfs/file.c~lseek-the-whence-argument-is-called-whence
+++ a/fs/btrfs/file.c
@@ -2120,7 +2120,7 @@ out:
 	return ret;
 }
 
-static int find_desired_extent(struct inode *inode, loff_t *offset, int origin)
+static int find_desired_extent(struct inode *inode, loff_t *offset, int whence)
 {
 	struct btrfs_root *root = BTRFS_I(inode)->root;
 	struct extent_map *em;
@@ -2154,7 +2154,7 @@ static int find_desired_extent(struct in
 	 * before the position we want in case there is outstanding delalloc
 	 * going on here.
 	 */
-	if (origin == SEEK_HOLE && start != 0) {
+	if (whence == SEEK_HOLE && start != 0) {
 		if (start <= root->sectorsize)
 			em = btrfs_get_extent_fiemap(inode, NULL, 0, 0,
 						     root->sectorsize, 0);
@@ -2188,13 +2188,13 @@ static int find_desired_extent(struct in
 				}
 			}
 
-			if (origin == SEEK_HOLE) {
+			if (whence == SEEK_HOLE) {
 				*offset = start;
 				free_extent_map(em);
 				break;
 			}
 		} else {
-			if (origin == SEEK_DATA) {
+			if (whence == SEEK_DATA) {
 				if (em->block_start == EXTENT_MAP_DELALLOC) {
 					if (start >= inode->i_size) {
 						free_extent_map(em);
@@ -2231,16 +2231,16 @@ out:
 	return ret;
 }
 
-static loff_t btrfs_file_llseek(struct file *file, loff_t offset, int origin)
+static loff_t btrfs_file_llseek(struct file *file, loff_t offset, int whence)
 {
 	struct inode *inode = file->f_mapping->host;
 	int ret;
 
 	mutex_lock(&inode->i_mutex);
-	switch (origin) {
+	switch (whence) {
 	case SEEK_END:
 	case SEEK_CUR:
-		offset = generic_file_llseek(file, offset, origin);
+		offset = generic_file_llseek(file, offset, whence);
 		goto out;
 	case SEEK_DATA:
 	case SEEK_HOLE:
@@ -2249,7 +2249,7 @@ static loff_t btrfs_file_llseek(struct f
 			return -ENXIO;
 		}
 
-		ret = find_desired_extent(inode, &offset, origin);
+		ret = find_desired_extent(inode, &offset, whence);
 		if (ret) {
 			mutex_unlock(&inode->i_mutex);
 			return ret;
diff -puN fs/ceph/dir.c~lseek-the-whence-argument-is-called-whence fs/ceph/dir.c
--- a/fs/ceph/dir.c~lseek-the-whence-argument-is-called-whence
+++ a/fs/ceph/dir.c
@@ -454,7 +454,7 @@ static void reset_readdir(struct ceph_fi
 	fi->flags &= ~CEPH_F_ATEND;
 }
 
-static loff_t ceph_dir_llseek(struct file *file, loff_t offset, int origin)
+static loff_t ceph_dir_llseek(struct file *file, loff_t offset, int whence)
 {
 	struct ceph_file_info *fi = file->private_data;
 	struct inode *inode = file->f_mapping->host;
@@ -463,7 +463,7 @@ static loff_t ceph_dir_llseek(struct fil
 
 	mutex_lock(&inode->i_mutex);
 	retval = -EINVAL;
-	switch (origin) {
+	switch (whence) {
 	case SEEK_END:
 		offset += inode->i_size + 2;   /* FIXME */
 		break;
diff -puN fs/ceph/file.c~lseek-the-whence-argument-is-called-whence fs/ceph/file.c
--- a/fs/ceph/file.c~lseek-the-whence-argument-is-called-whence
+++ a/fs/ceph/file.c
@@ -797,7 +797,7 @@ out:
 /*
  * llseek.  be sure to verify file size on SEEK_END.
  */
-static loff_t ceph_llseek(struct file *file, loff_t offset, int origin)
+static loff_t ceph_llseek(struct file *file, loff_t offset, int whence)
 {
 	struct inode *inode = file->f_mapping->host;
 	int ret;
@@ -805,7 +805,7 @@ static loff_t ceph_llseek(struct file *f
 	mutex_lock(&inode->i_mutex);
 	__ceph_do_pending_vmtruncate(inode);
 
-	if (origin == SEEK_END || origin == SEEK_DATA || origin == SEEK_HOLE) {
+	if (whence == SEEK_END || whence == SEEK_DATA || whence == SEEK_HOLE) {
 		ret = ceph_do_getattr(inode, CEPH_STAT_CAP_SIZE);
 		if (ret < 0) {
 			offset = ret;
@@ -813,7 +813,7 @@ static loff_t ceph_llseek(struct file *f
 		}
 	}
 
-	switch (origin) {
+	switch (whence) {
 	case SEEK_END:
 		offset += inode->i_size;
 		break;
diff -puN fs/cifs/cifsfs.c~lseek-the-whence-argument-is-called-whence fs/cifs/cifsfs.c
--- a/fs/cifs/cifsfs.c~lseek-the-whence-argument-is-called-whence
+++ a/fs/cifs/cifsfs.c
@@ -694,13 +694,13 @@ static ssize_t cifs_file_aio_write(struc
 	return written;
 }
 
-static loff_t cifs_llseek(struct file *file, loff_t offset, int origin)
+static loff_t cifs_llseek(struct file *file, loff_t offset, int whence)
 {
 	/*
-	 * origin == SEEK_END || SEEK_DATA || SEEK_HOLE => we must revalidate
+	 * whence == SEEK_END || SEEK_DATA || SEEK_HOLE => we must revalidate
 	 * the cached file length
 	 */
-	if (origin != SEEK_SET && origin != SEEK_CUR) {
+	if (whence != SEEK_SET && whence != SEEK_CUR) {
 		int rc;
 		struct inode *inode = file->f_path.dentry->d_inode;
 
@@ -727,7 +727,7 @@ static loff_t cifs_llseek(struct file *f
 		if (rc < 0)
 			return (loff_t)rc;
 	}
-	return generic_file_llseek(file, offset, origin);
+	return generic_file_llseek(file, offset, whence);
 }
 
 static int cifs_setlease(struct file *file, long arg, struct file_lock **lease)
diff -puN fs/configfs/dir.c~lseek-the-whence-argument-is-called-whence fs/configfs/dir.c
--- a/fs/configfs/dir.c~lseek-the-whence-argument-is-called-whence
+++ a/fs/configfs/dir.c
@@ -1613,12 +1613,12 @@ static int configfs_readdir(struct file 
 	return 0;
 }
 
-static loff_t configfs_dir_lseek(struct file * file, loff_t offset, int origin)
+static loff_t configfs_dir_lseek(struct file * file, loff_t offset, int whence)
 {
 	struct dentry * dentry = file->f_path.dentry;
 
 	mutex_lock(&dentry->d_inode->i_mutex);
-	switch (origin) {
+	switch (whence) {
 		case 1:
 			offset += file->f_pos;
 		case 0:
diff -puN fs/ext3/dir.c~lseek-the-whence-argument-is-called-whence fs/ext3/dir.c
--- a/fs/ext3/dir.c~lseek-the-whence-argument-is-called-whence
+++ a/fs/ext3/dir.c
@@ -296,17 +296,17 @@ static inline loff_t ext3_get_htree_eof(
  * NOTE: offsets obtained *before* ext3_set_inode_flag(dir, EXT3_INODE_INDEX)
  *       will be invalid once the directory was converted into a dx directory
  */
-loff_t ext3_dir_llseek(struct file *file, loff_t offset, int origin)
+loff_t ext3_dir_llseek(struct file *file, loff_t offset, int whence)
 {
 	struct inode *inode = file->f_mapping->host;
 	int dx_dir = is_dx_dir(inode);
 	loff_t htree_max = ext3_get_htree_eof(file);
 
 	if (likely(dx_dir))
-		return generic_file_llseek_size(file, offset, origin,
+		return generic_file_llseek_size(file, offset, whence,
 					        htree_max, htree_max);
 	else
-		return generic_file_llseek(file, offset, origin);
+		return generic_file_llseek(file, offset, whence);
 }
 
 /*
diff -puN fs/ext4/dir.c~lseek-the-whence-argument-is-called-whence fs/ext4/dir.c
--- a/fs/ext4/dir.c~lseek-the-whence-argument-is-called-whence
+++ a/fs/ext4/dir.c
@@ -334,17 +334,17 @@ static inline loff_t ext4_get_htree_eof(
  *
  * For non-htree, ext4_llseek already chooses the proper max offset.
  */
-loff_t ext4_dir_llseek(struct file *file, loff_t offset, int origin)
+loff_t ext4_dir_llseek(struct file *file, loff_t offset, int whence)
 {
 	struct inode *inode = file->f_mapping->host;
 	int dx_dir = is_dx_dir(inode);
 	loff_t htree_max = ext4_get_htree_eof(file);
 
 	if (likely(dx_dir))
-		return generic_file_llseek_size(file, offset, origin,
+		return generic_file_llseek_size(file, offset, whence,
 						    htree_max, htree_max);
 	else
-		return ext4_llseek(file, offset, origin);
+		return ext4_llseek(file, offset, whence);
 }
 
 /*
diff -puN fs/ext4/file.c~lseek-the-whence-argument-is-called-whence fs/ext4/file.c
--- a/fs/ext4/file.c~lseek-the-whence-argument-is-called-whence
+++ a/fs/ext4/file.c
@@ -303,7 +303,7 @@ static int ext4_file_open(struct inode *
  * page cache has data or not.
  */
 static int ext4_find_unwritten_pgoff(struct inode *inode,
-				     int origin,
+				     int whence,
 				     struct ext4_map_blocks *map,
 				     loff_t *offset)
 {
@@ -333,10 +333,10 @@ static int ext4_find_unwritten_pgoff(str
 		nr_pages = pagevec_lookup(&pvec, inode->i_mapping, index,
 					  (pgoff_t)num);
 		if (nr_pages == 0) {
-			if (origin == SEEK_DATA)
+			if (whence == SEEK_DATA)
 				break;
 
-			BUG_ON(origin != SEEK_HOLE);
+			BUG_ON(whence != SEEK_HOLE);
 			/*
 			 * If this is the first time to go into the loop and
 			 * offset is not beyond the end offset, it will be a
@@ -352,7 +352,7 @@ static int ext4_find_unwritten_pgoff(str
 		 * offset is smaller than the first page offset, it will be a
 		 * hole at this offset.
 		 */
-		if (lastoff == startoff && origin == SEEK_HOLE &&
+		if (lastoff == startoff && whence == SEEK_HOLE &&
 		    lastoff < page_offset(pvec.pages[0])) {
 			found = 1;
 			break;
@@ -366,7 +366,7 @@ static int ext4_find_unwritten_pgoff(str
 			 * If the current offset is not beyond the end of given
 			 * range, it will be a hole.
 			 */
-			if (lastoff < endoff && origin == SEEK_HOLE &&
+			if (lastoff < endoff && whence == SEEK_HOLE &&
 			    page->index > end) {
 				found = 1;
 				*offset = lastoff;
@@ -391,10 +391,10 @@ static int ext4_find_unwritten_pgoff(str
 				do {
 					if (buffer_uptodate(bh) ||
 					    buffer_unwritten(bh)) {
-						if (origin == SEEK_DATA)
+						if (whence == SEEK_DATA)
 							found = 1;
 					} else {
-						if (origin == SEEK_HOLE)
+						if (whence == SEEK_HOLE)
 							found = 1;
 					}
 					if (found) {
@@ -416,7 +416,7 @@ static int ext4_find_unwritten_pgoff(str
 		 * The no. of pages is less than our desired, that would be a
 		 * hole in there.
 		 */
-		if (nr_pages < num && origin == SEEK_HOLE) {
+		if (nr_pages < num && whence == SEEK_HOLE) {
 			found = 1;
 			*offset = lastoff;
 			break;
@@ -609,7 +609,7 @@ static loff_t ext4_seek_hole(struct file
  * by calling generic_file_llseek_size() with the appropriate maxbytes
  * value for each.
  */
-loff_t ext4_llseek(struct file *file, loff_t offset, int origin)
+loff_t ext4_llseek(struct file *file, loff_t offset, int whence)
 {
 	struct inode *inode = file->f_mapping->host;
 	loff_t maxbytes;
@@ -619,11 +619,11 @@ loff_t ext4_llseek(struct file *file, lo
 	else
 		maxbytes = inode->i_sb->s_maxbytes;
 
-	switch (origin) {
+	switch (whence) {
 	case SEEK_SET:
 	case SEEK_CUR:
 	case SEEK_END:
-		return generic_file_llseek_size(file, offset, origin,
+		return generic_file_llseek_size(file, offset, whence,
 						maxbytes, i_size_read(inode));
 	case SEEK_DATA:
 		return ext4_seek_data(file, offset, maxbytes);
diff -puN fs/fuse/file.c~lseek-the-whence-argument-is-called-whence fs/fuse/file.c
--- a/fs/fuse/file.c~lseek-the-whence-argument-is-called-whence
+++ a/fs/fuse/file.c
@@ -1699,19 +1699,19 @@ static sector_t fuse_bmap(struct address
 	return err ? 0 : outarg.block;
 }
 
-static loff_t fuse_file_llseek(struct file *file, loff_t offset, int origin)
+static loff_t fuse_file_llseek(struct file *file, loff_t offset, int whence)
 {
 	loff_t retval;
 	struct inode *inode = file->f_path.dentry->d_inode;
 
 	/* No i_mutex protection necessary for SEEK_CUR and SEEK_SET */
-	if (origin == SEEK_CUR || origin == SEEK_SET)
-		return generic_file_llseek(file, offset, origin);
+	if (whence == SEEK_CUR || whence == SEEK_SET)
+		return generic_file_llseek(file, offset, whence);
 
 	mutex_lock(&inode->i_mutex);
 	retval = fuse_update_attributes(inode, NULL, file, NULL);
 	if (!retval)
-		retval = generic_file_llseek(file, offset, origin);
+		retval = generic_file_llseek(file, offset, whence);
 	mutex_unlock(&inode->i_mutex);
 
 	return retval;
diff -puN fs/gfs2/file.c~lseek-the-whence-argument-is-called-whence fs/gfs2/file.c
--- a/fs/gfs2/file.c~lseek-the-whence-argument-is-called-whence
+++ a/fs/gfs2/file.c
@@ -44,7 +44,7 @@
  * gfs2_llseek - seek to a location in a file
  * @file: the file
  * @offset: the offset
- * @origin: Where to seek from (SEEK_SET, SEEK_CUR, or SEEK_END)
+ * @whence: Where to seek from (SEEK_SET, SEEK_CUR, or SEEK_END)
  *
  * SEEK_END requires the glock for the file because it references the
  * file's size.
@@ -52,26 +52,26 @@
  * Returns: The new offset, or errno
  */
 
-static loff_t gfs2_llseek(struct file *file, loff_t offset, int origin)
+static loff_t gfs2_llseek(struct file *file, loff_t offset, int whence)
 {
 	struct gfs2_inode *ip = GFS2_I(file->f_mapping->host);
 	struct gfs2_holder i_gh;
 	loff_t error;
 
-	switch (origin) {
+	switch (whence) {
 	case SEEK_END: /* These reference inode->i_size */
 	case SEEK_DATA:
 	case SEEK_HOLE:
 		error = gfs2_glock_nq_init(ip->i_gl, LM_ST_SHARED, LM_FLAG_ANY,
 					   &i_gh);
 		if (!error) {
-			error = generic_file_llseek(file, offset, origin);
+			error = generic_file_llseek(file, offset, whence);
 			gfs2_glock_dq_uninit(&i_gh);
 		}
 		break;
 	case SEEK_CUR:
 	case SEEK_SET:
-		error = generic_file_llseek(file, offset, origin);
+		error = generic_file_llseek(file, offset, whence);
 		break;
 	default:
 		error = -EINVAL;
diff -puN fs/nfs/dir.c~lseek-the-whence-argument-is-called-whence fs/nfs/dir.c
--- a/fs/nfs/dir.c~lseek-the-whence-argument-is-called-whence
+++ a/fs/nfs/dir.c
@@ -870,7 +870,7 @@ out:
 	return res;
 }
 
-static loff_t nfs_llseek_dir(struct file *filp, loff_t offset, int origin)
+static loff_t nfs_llseek_dir(struct file *filp, loff_t offset, int whence)
 {
 	struct dentry *dentry = filp->f_path.dentry;
 	struct inode *inode = dentry->d_inode;
@@ -879,10 +879,10 @@ static loff_t nfs_llseek_dir(struct file
 	dfprintk(FILE, "NFS: llseek dir(%s/%s, %lld, %d)\n",
 			dentry->d_parent->d_name.name,
 			dentry->d_name.name,
-			offset, origin);
+			offset, whence);
 
 	mutex_lock(&inode->i_mutex);
-	switch (origin) {
+	switch (whence) {
 		case 1:
 			offset += filp->f_pos;
 		case 0:
diff -puN fs/nfs/file.c~lseek-the-whence-argument-is-called-whence fs/nfs/file.c
--- a/fs/nfs/file.c~lseek-the-whence-argument-is-called-whence
+++ a/fs/nfs/file.c
@@ -119,18 +119,18 @@ force_reval:
 	return __nfs_revalidate_inode(server, inode);
 }
 
-loff_t nfs_file_llseek(struct file *filp, loff_t offset, int origin)
+loff_t nfs_file_llseek(struct file *filp, loff_t offset, int whence)
 {
 	dprintk("NFS: llseek file(%s/%s, %lld, %d)\n",
 			filp->f_path.dentry->d_parent->d_name.name,
 			filp->f_path.dentry->d_name.name,
-			offset, origin);
+			offset, whence);
 
 	/*
-	 * origin == SEEK_END || SEEK_DATA || SEEK_HOLE => we must revalidate
+	 * whence == SEEK_END || SEEK_DATA || SEEK_HOLE => we must revalidate
 	 * the cached file length
 	 */
-	if (origin != SEEK_SET && origin != SEEK_CUR) {
+	if (whence != SEEK_SET && whence != SEEK_CUR) {
 		struct inode *inode = filp->f_mapping->host;
 
 		int retval = nfs_revalidate_file_size(inode, filp);
@@ -138,7 +138,7 @@ loff_t nfs_file_llseek(struct file *filp
 			return (loff_t)retval;
 	}
 
-	return generic_file_llseek(filp, offset, origin);
+	return generic_file_llseek(filp, offset, whence);
 }
 EXPORT_SYMBOL_GPL(nfs_file_llseek);
 
diff -puN fs/ocfs2/extent_map.c~lseek-the-whence-argument-is-called-whence fs/ocfs2/extent_map.c
--- a/fs/ocfs2/extent_map.c~lseek-the-whence-argument-is-called-whence
+++ a/fs/ocfs2/extent_map.c
@@ -832,7 +832,7 @@ out:
 	return ret;
 }
 
-int ocfs2_seek_data_hole_offset(struct file *file, loff_t *offset, int origin)
+int ocfs2_seek_data_hole_offset(struct file *file, loff_t *offset, int whence)
 {
 	struct inode *inode = file->f_mapping->host;
 	int ret;
@@ -843,7 +843,7 @@ int ocfs2_seek_data_hole_offset(struct f
 	struct buffer_head *di_bh = NULL;
 	struct ocfs2_extent_rec rec;
 
-	BUG_ON(origin != SEEK_DATA && origin != SEEK_HOLE);
+	BUG_ON(whence != SEEK_DATA && whence != SEEK_HOLE);
 
 	ret = ocfs2_inode_lock(inode, &di_bh, 0);
 	if (ret) {
@@ -859,7 +859,7 @@ int ocfs2_seek_data_hole_offset(struct f
 	}
 
 	if (OCFS2_I(inode)->ip_dyn_features & OCFS2_INLINE_DATA_FL) {
-		if (origin == SEEK_HOLE)
+		if (whence == SEEK_HOLE)
 			*offset = inode->i_size;
 		goto out_unlock;
 	}
@@ -888,8 +888,8 @@ int ocfs2_seek_data_hole_offset(struct f
 			is_data = (rec.e_flags & OCFS2_EXT_UNWRITTEN) ?  0 : 1;
 		}
 
-		if ((!is_data && origin == SEEK_HOLE) ||
-		    (is_data && origin == SEEK_DATA)) {
+		if ((!is_data && whence == SEEK_HOLE) ||
+		    (is_data && whence == SEEK_DATA)) {
 			if (extoff > *offset)
 				*offset = extoff;
 			goto out_unlock;
@@ -899,7 +899,7 @@ int ocfs2_seek_data_hole_offset(struct f
 			cpos += clen;
 	}
 
-	if (origin == SEEK_HOLE) {
+	if (whence == SEEK_HOLE) {
 		extoff = cpos;
 		extoff <<= cs_bits;
 		extlen = clen;
diff -puN fs/ocfs2/file.c~lseek-the-whence-argument-is-called-whence fs/ocfs2/file.c
--- a/fs/ocfs2/file.c~lseek-the-whence-argument-is-called-whence
+++ a/fs/ocfs2/file.c
@@ -2637,14 +2637,14 @@ bail:
 }
 
 /* Refer generic_file_llseek_unlocked() */
-static loff_t ocfs2_file_llseek(struct file *file, loff_t offset, int origin)
+static loff_t ocfs2_file_llseek(struct file *file, loff_t offset, int whence)
 {
 	struct inode *inode = file->f_mapping->host;
 	int ret = 0;
 
 	mutex_lock(&inode->i_mutex);
 
-	switch (origin) {
+	switch (whence) {
 	case SEEK_SET:
 		break;
 	case SEEK_END:
@@ -2659,7 +2659,7 @@ static loff_t ocfs2_file_llseek(struct f
 		break;
 	case SEEK_DATA:
 	case SEEK_HOLE:
-		ret = ocfs2_seek_data_hole_offset(file, &offset, origin);
+		ret = ocfs2_seek_data_hole_offset(file, &offset, whence);
 		if (ret)
 			goto out;
 		break;
diff -puN fs/pstore/inode.c~lseek-the-whence-argument-is-called-whence fs/pstore/inode.c
--- a/fs/pstore/inode.c~lseek-the-whence-argument-is-called-whence
+++ a/fs/pstore/inode.c
@@ -151,13 +151,13 @@ static int pstore_file_open(struct inode
 	return 0;
 }
 
-static loff_t pstore_file_llseek(struct file *file, loff_t off, int origin)
+static loff_t pstore_file_llseek(struct file *file, loff_t off, int whence)
 {
 	struct seq_file *sf = file->private_data;
 
 	if (sf->op)
-		return seq_lseek(file, off, origin);
-	return default_llseek(file, off, origin);
+		return seq_lseek(file, off, whence);
+	return default_llseek(file, off, whence);
 }
 
 static const struct file_operations pstore_file_operations = {
diff -puN fs/ubifs/dir.c~lseek-the-whence-argument-is-called-whence fs/ubifs/dir.c
--- a/fs/ubifs/dir.c~lseek-the-whence-argument-is-called-whence
+++ a/fs/ubifs/dir.c
@@ -453,11 +453,11 @@ out:
 }
 
 /* If a directory is seeked, we have to free saved readdir() state */
-static loff_t ubifs_dir_llseek(struct file *file, loff_t offset, int origin)
+static loff_t ubifs_dir_llseek(struct file *file, loff_t offset, int whence)
 {
 	kfree(file->private_data);
 	file->private_data = NULL;
-	return generic_file_llseek(file, offset, origin);
+	return generic_file_llseek(file, offset, whence);
 }
 
 /* Free saved readdir() state when the directory is closed */
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
