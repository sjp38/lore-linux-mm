Message-Id: <20070423062131.446138927@sgi.com>
References: <20070423062107.843307112@sgi.com>
Date: Sun, 22 Apr 2007 23:21:22 -0700
From: clameter@sgi.com
Subject: [RFC 15/16] ext2: Add variable page size support
Content-Disposition: inline; filename=var_pc_ext2
To: linux-mm@kvack.org
Cc: Mel Gorman <mel@skynet.ie>, William Lee Irwin III <wli@holomorphy.com>, Adam Litke <aglitke@gmail.com>, David Chinner <dgc@sgi.com>, Jens Axboe <jens.axboe@oracle.com>, Avi Kivity <avi@argo.co.il>, Dave Hansen <hansendc@us.ibm.com>, Badari Pulavarty <pbadari@gmail.com>, Maxim Levitsky <maximlevitsky@gmail.com>
List-ID: <linux-mm.kvack.org>

This adds variable page size support. It is then possible to mount filesystems
that have a larger blocksize than the page size.

F.e. the following is possible on x86_64 and i386 that have only a 4k page
size.

mke2fs -b 16384 /dev/hdd2	<Ignore warning about too large block size>

mount /dev/hdd2 /media
ls -l /media

.... Do more things with the volume that uses a 16k page cache size on
a 4k page sized platform..

Note that there are issues with ext2 support:

1. Data is not writtten back correctly (block layer?)
2. Reclaim does not work right.

And we disable mmap for higher order pages like also done for ramfs. This
is temporary until we get support for mmapping higher order pages.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 fs/ext2/dir.c   |   40 +++++++++++++++++++++++-----------------
 fs/ext2/ext2.h  |    1 +
 fs/ext2/file.c  |   18 ++++++++++++++++++
 fs/ext2/inode.c |   10 ++++++++--
 fs/ext2/namei.c |   10 ++++++++--
 5 files changed, 58 insertions(+), 21 deletions(-)

Index: linux-2.6.21-rc7/fs/ext2/dir.c
===================================================================
--- linux-2.6.21-rc7.orig/fs/ext2/dir.c	2007-04-22 19:43:05.000000000 -0700
+++ linux-2.6.21-rc7/fs/ext2/dir.c	2007-04-22 20:09:57.000000000 -0700
@@ -44,7 +44,8 @@ static inline void ext2_put_page(struct 
 
 static inline unsigned long dir_pages(struct inode *inode)
 {
-	return (inode->i_size+PAGE_CACHE_SIZE-1)>>PAGE_CACHE_SHIFT;
+	return (inode->i_size+page_cache_size(inode->i_mapping)-1)>>
+			page_cache_shift(inode->i_mapping);
 }
 
 /*
@@ -55,10 +56,11 @@ static unsigned
 ext2_last_byte(struct inode *inode, unsigned long page_nr)
 {
 	unsigned last_byte = inode->i_size;
+	struct address_space *mapping = inode->i_mapping;
 
-	last_byte -= page_nr << PAGE_CACHE_SHIFT;
-	if (last_byte > PAGE_CACHE_SIZE)
-		last_byte = PAGE_CACHE_SIZE;
+	last_byte -= page_nr << page_cache_shift(mapping);
+	if (last_byte > page_cache_size(mapping))
+		last_byte = page_cache_size(mapping);
 	return last_byte;
 }
 
@@ -77,18 +79,19 @@ static int ext2_commit_chunk(struct page
 
 static void ext2_check_page(struct page *page)
 {
-	struct inode *dir = page->mapping->host;
+	struct address_space *mapping = page->mapping;
+	struct inode *dir = mapping->host;
 	struct super_block *sb = dir->i_sb;
 	unsigned chunk_size = ext2_chunk_size(dir);
 	char *kaddr = page_address(page);
 	u32 max_inumber = le32_to_cpu(EXT2_SB(sb)->s_es->s_inodes_count);
 	unsigned offs, rec_len;
-	unsigned limit = PAGE_CACHE_SIZE;
+	unsigned limit = page_cache_size(mapping);
 	ext2_dirent *p;
 	char *error;
 
-	if ((dir->i_size >> PAGE_CACHE_SHIFT) == page->index) {
-		limit = dir->i_size & ~PAGE_CACHE_MASK;
+	if (page_cache_index(mapping, dir->i_size) == page->index) {
+		limit = page_cache_offset(mapping, dir->i_size);
 		if (limit & (chunk_size - 1))
 			goto Ebadsize;
 		if (!limit)
@@ -140,7 +143,7 @@ Einumber:
 bad_entry:
 	ext2_error (sb, "ext2_check_page", "bad entry in directory #%lu: %s - "
 		"offset=%lu, inode=%lu, rec_len=%d, name_len=%d",
-		dir->i_ino, error, (page->index<<PAGE_CACHE_SHIFT)+offs,
+		dir->i_ino, error, page_cache_pos(mapping, page->index, offs),
 		(unsigned long) le32_to_cpu(p->inode),
 		rec_len, p->name_len);
 	goto fail;
@@ -149,7 +152,7 @@ Eend:
 	ext2_error (sb, "ext2_check_page",
 		"entry in directory #%lu spans the page boundary"
 		"offset=%lu, inode=%lu",
-		dir->i_ino, (page->index<<PAGE_CACHE_SHIFT)+offs,
+		dir->i_ino, page_cache_pos(mapping, page->index, offs),
 		(unsigned long) le32_to_cpu(p->inode));
 fail:
 	SetPageChecked(page);
@@ -250,8 +253,9 @@ ext2_readdir (struct file * filp, void *
 	loff_t pos = filp->f_pos;
 	struct inode *inode = filp->f_path.dentry->d_inode;
 	struct super_block *sb = inode->i_sb;
-	unsigned int offset = pos & ~PAGE_CACHE_MASK;
-	unsigned long n = pos >> PAGE_CACHE_SHIFT;
+	struct address_space *mapping = inode->i_mapping;
+	unsigned int offset = page_cache_offset(mapping, pos);
+	unsigned long n = page_cache_index(mapping, pos);
 	unsigned long npages = dir_pages(inode);
 	unsigned chunk_mask = ~(ext2_chunk_size(inode)-1);
 	unsigned char *types = NULL;
@@ -272,14 +276,14 @@ ext2_readdir (struct file * filp, void *
 			ext2_error(sb, __FUNCTION__,
 				   "bad page in #%lu",
 				   inode->i_ino);
-			filp->f_pos += PAGE_CACHE_SIZE - offset;
+			filp->f_pos += page_cache_size(mapping) - offset;
 			return -EIO;
 		}
 		kaddr = page_address(page);
 		if (unlikely(need_revalidate)) {
 			if (offset) {
 				offset = ext2_validate_entry(kaddr, offset, chunk_mask);
-				filp->f_pos = (n<<PAGE_CACHE_SHIFT) + offset;
+				filp->f_pos = page_cache_pos(mapping, n, offset);
 			}
 			filp->f_version = inode->i_version;
 			need_revalidate = 0;
@@ -302,7 +306,7 @@ ext2_readdir (struct file * filp, void *
 
 				offset = (char *)de - kaddr;
 				over = filldir(dirent, de->name, de->name_len,
-						(n<<PAGE_CACHE_SHIFT) | offset,
+						page_cache_pos(mapping, n, offset),
 						le32_to_cpu(de->inode), d_type);
 				if (over) {
 					ext2_put_page(page);
@@ -328,6 +332,7 @@ struct ext2_dir_entry_2 * ext2_find_entr
 			struct dentry *dentry, struct page ** res_page)
 {
 	const char *name = dentry->d_name.name;
+	struct address_space *mapping = dir->i_mapping;
 	int namelen = dentry->d_name.len;
 	unsigned reclen = EXT2_DIR_REC_LEN(namelen);
 	unsigned long start, n;
@@ -369,7 +374,7 @@ struct ext2_dir_entry_2 * ext2_find_entr
 		if (++n >= npages)
 			n = 0;
 		/* next page is past the blocks we've got */
-		if (unlikely(n > (dir->i_blocks >> (PAGE_CACHE_SHIFT - 9)))) {
+		if (unlikely(n > (dir->i_blocks >> (page_cache_shift(mapping) - 9)))) {
 			ext2_error(dir->i_sb, __FUNCTION__,
 				"dir %lu size %lld exceeds block count %llu",
 				dir->i_ino, dir->i_size,
@@ -438,6 +443,7 @@ void ext2_set_link(struct inode *dir, st
 int ext2_add_link (struct dentry *dentry, struct inode *inode)
 {
 	struct inode *dir = dentry->d_parent->d_inode;
+	struct address_space *mapping = inode->i_mapping;
 	const char *name = dentry->d_name.name;
 	int namelen = dentry->d_name.len;
 	unsigned chunk_size = ext2_chunk_size(dir);
@@ -467,7 +473,7 @@ int ext2_add_link (struct dentry *dentry
 		kaddr = page_address(page);
 		dir_end = kaddr + ext2_last_byte(dir, n);
 		de = (ext2_dirent *)kaddr;
-		kaddr += PAGE_CACHE_SIZE - reclen;
+		kaddr += page_cache_size(mapping) - reclen;
 		while ((char *)de <= kaddr) {
 			if ((char *)de == dir_end) {
 				/* We hit i_size */
Index: linux-2.6.21-rc7/fs/ext2/ext2.h
===================================================================
--- linux-2.6.21-rc7.orig/fs/ext2/ext2.h	2007-04-22 19:43:05.000000000 -0700
+++ linux-2.6.21-rc7/fs/ext2/ext2.h	2007-04-22 19:44:22.000000000 -0700
@@ -160,6 +160,7 @@ extern const struct file_operations ext2
 /* file.c */
 extern const struct inode_operations ext2_file_inode_operations;
 extern const struct file_operations ext2_file_operations;
+extern const struct file_operations ext2_no_mmap_file_operations;
 extern const struct file_operations ext2_xip_file_operations;
 
 /* inode.c */
Index: linux-2.6.21-rc7/fs/ext2/file.c
===================================================================
--- linux-2.6.21-rc7.orig/fs/ext2/file.c	2007-04-22 19:43:05.000000000 -0700
+++ linux-2.6.21-rc7/fs/ext2/file.c	2007-04-22 19:44:22.000000000 -0700
@@ -58,6 +58,24 @@ const struct file_operations ext2_file_o
 	.splice_write	= generic_file_splice_write,
 };
 
+const struct file_operations ext2_no_mmap_file_operations = {
+	.llseek		= generic_file_llseek,
+	.read		= do_sync_read,
+	.write		= do_sync_write,
+	.aio_read	= generic_file_aio_read,
+	.aio_write	= generic_file_aio_write,
+	.ioctl		= ext2_ioctl,
+#ifdef CONFIG_COMPAT
+	.compat_ioctl	= ext2_compat_ioctl,
+#endif
+	.open		= generic_file_open,
+	.release	= ext2_release_file,
+	.fsync		= ext2_sync_file,
+	.sendfile	= generic_file_sendfile,
+	.splice_read	= generic_file_splice_read,
+	.splice_write	= generic_file_splice_write,
+};
+
 #ifdef CONFIG_EXT2_FS_XIP
 const struct file_operations ext2_xip_file_operations = {
 	.llseek		= generic_file_llseek,
Index: linux-2.6.21-rc7/fs/ext2/inode.c
===================================================================
--- linux-2.6.21-rc7.orig/fs/ext2/inode.c	2007-04-22 19:43:05.000000000 -0700
+++ linux-2.6.21-rc7/fs/ext2/inode.c	2007-04-22 19:44:22.000000000 -0700
@@ -1128,10 +1128,16 @@ void ext2_read_inode (struct inode * ino
 			inode->i_fop = &ext2_xip_file_operations;
 		} else if (test_opt(inode->i_sb, NOBH)) {
 			inode->i_mapping->a_ops = &ext2_nobh_aops;
-			inode->i_fop = &ext2_file_operations;
+			if (inode->i_mapping->order)
+				inode->i_fop = &ext2_no_mmap_file_operations;
+			else
+				inode->i_fop = &ext2_file_operations;
 		} else {
 			inode->i_mapping->a_ops = &ext2_aops;
-			inode->i_fop = &ext2_file_operations;
+			if (inode->i_mapping->order)
+				inode->i_fop = &ext2_no_mmap_file_operations;
+			else
+				inode->i_fop = &ext2_file_operations;
 		}
 	} else if (S_ISDIR(inode->i_mode)) {
 		inode->i_op = &ext2_dir_inode_operations;
Index: linux-2.6.21-rc7/fs/ext2/namei.c
===================================================================
--- linux-2.6.21-rc7.orig/fs/ext2/namei.c	2007-04-22 19:43:05.000000000 -0700
+++ linux-2.6.21-rc7/fs/ext2/namei.c	2007-04-22 19:44:22.000000000 -0700
@@ -114,10 +114,16 @@ static int ext2_create (struct inode * d
 			inode->i_fop = &ext2_xip_file_operations;
 		} else if (test_opt(inode->i_sb, NOBH)) {
 			inode->i_mapping->a_ops = &ext2_nobh_aops;
-			inode->i_fop = &ext2_file_operations;
+			if (inode->i_mapping->order)
+				inode->i_fop = &ext2_no_mmap_file_operations;
+			else
+				inode->i_fop = &ext2_file_operations;
 		} else {
 			inode->i_mapping->a_ops = &ext2_aops;
-			inode->i_fop = &ext2_file_operations;
+			if (inode->i_mapping->order)
+				inode->i_fop = &ext2_no_mmap_file_operations;
+			else
+				inode->i_fop = &ext2_file_operations;
 		}
 		mark_inode_dirty(inode);
 		err = ext2_add_nondir(dentry, inode);

--
