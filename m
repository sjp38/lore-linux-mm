Received: from wli by holomorphy with local (Exim 3.34 #1 (Debian))
	id 17wzJg-0007Jc-00
	for <linux-mm@kvack.org>; Wed, 02 Oct 2002 23:18:32 -0700
Date: Wed, 2 Oct 2002 23:18:31 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: hugetlbfs-2.5.40-2
Message-ID: <20021003061831.GC21837@holomorphy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Against current 2.5.40-bk.

Moves some stuff around between ramfs etc. and libfs.c. Some kind of shm
thing happened too, probably related to sub-HPAGE_SIZE mmapping. More to
come.


Bill


diff -Nur --exclude=SCCS --exclude=BitKeeper --exclude=ChangeSet linux-2.5/arch/i386/mm/hugetlbpage.c hugetlbfs/arch/i386/mm/hugetlbpage.c
--- linux-2.5/arch/i386/mm/hugetlbpage.c	Wed Oct  2 20:14:31 2002
+++ hugetlbfs/arch/i386/mm/hugetlbpage.c	Wed Oct  2 22:00:54 2002
@@ -17,7 +17,7 @@
 #include <asm/tlb.h>
 #include <asm/tlbflush.h>
 
-static struct vm_operations_struct hugetlb_vm_ops;
+struct vm_operations_struct hugetlb_vm_ops;
 struct list_head htlbpage_freelist;
 spinlock_t htlbpage_lock = SPIN_LOCK_UNLOCKED;
 extern long htlbpagemem;
@@ -44,24 +44,22 @@
 static struct page *
 alloc_hugetlb_page(void)
 {
-	struct list_head *curr, *head;
+	int i;
 	struct page *page;
 
 	spin_lock(&htlbpage_lock);
-
-	head = &htlbpage_freelist;
-	curr = head->next;
-
-	if (curr == head) {
+	if (list_empty(&htlbpage_freelist)) {
 		spin_unlock(&htlbpage_lock);
 		return NULL;
 	}
-	page = list_entry(curr, struct page, list);
-	list_del(curr);
+
+	page = list_entry(htlbpage_freelist.next, struct page, list);
+	list_del(&page->list);
 	htlbpagemem--;
 	spin_unlock(&htlbpage_lock);
 	set_page_count(page, 1);
-	memset(page_address(page), 0, HPAGE_SIZE);
+	for (i = 0; i < (HPAGE_SIZE/PAGE_SIZE); ++i)
+		clear_highpage(&page[i]);
 	return page;
 }
 
@@ -459,6 +457,46 @@
 	 return retval;
 }
 
+int hugetlb_prefault(struct address_space *mapping, struct vm_area_struct *vma)
+{
+	struct mm_struct *mm = current->mm;
+	unsigned long addr;
+	int ret = 0;
+
+	BUG_ON(vma->vm_start & ~HPAGE_MASK);
+	BUG_ON(vma->vm_end & ~HPAGE_MASK);
+
+	spin_lock(&mm->page_table_lock);
+	for (addr = vma->vm_start; addr < vma->vm_end; addr += HPAGE_SIZE) {
+		unsigned long idx;
+		pte_t *pte = huge_pte_alloc(mm, addr);
+		struct page *page;
+
+		if (!pte) {
+			ret = -ENOMEM;
+			goto out;
+		}
+		if (!pte_none(*pte))
+			continue;
+
+		idx = ((addr - vma->vm_start) >> HPAGE_SHIFT)
+			+ (vma->vm_pgoff >> (HPAGE_SHIFT - PAGE_SHIFT));
+		page = find_get_page(mapping, idx);
+		if (!page) {
+			page = alloc_hugetlb_page();
+			if (!page) {
+				ret = -ENOMEM;
+				goto out;
+			}
+			add_to_page_cache(page, mapping, idx);
+		}
+		set_huge_pte(mm, vma, page, pte, vma->vm_flags & VM_WRITE);
+	}
+out:
+	spin_unlock(&mm->page_table_lock);
+	return ret;
+}
+
 static int
 alloc_private_hugetlb_pages(int key, unsigned long addr, unsigned long len,
 			    int prot, int flag)
@@ -540,6 +578,13 @@
 	return (int) htlbzone_pages;
 }
 
-static struct vm_operations_struct hugetlb_vm_ops = {
+static struct page * hugetlb_nopage(struct vm_area_struct * area, unsigned long address, int unused)
+{
+	BUG();
+	return NULL;
+}
+
+struct vm_operations_struct hugetlb_vm_ops = {
 	.close	= zap_hugetlb_resources,
+	.nopage = hugetlb_nopage,
 };
diff -Nur --exclude=SCCS --exclude=BitKeeper --exclude=ChangeSet linux-2.5/fs/Config.in hugetlbfs/fs/Config.in
--- linux-2.5/fs/Config.in	Wed Oct  2 20:14:48 2002
+++ hugetlbfs/fs/Config.in	Wed Oct  2 22:01:15 2002
@@ -56,6 +56,11 @@
 bool 'Virtual memory file system support (former shm fs)' CONFIG_TMPFS
 define_bool CONFIG_RAMFS y
 
+if [ "$CONFIG_HUGETLB_PAGE" = "y" ] ; then
+   bool 'HugeTLB file system support' CONFIG_HUGETLBFS
+   define_bool CONFIG_HUGETLBFS y
+fi
+
 tristate 'ISO 9660 CDROM file system support' CONFIG_ISO9660_FS
 dep_mbool '  Microsoft Joliet CDROM extensions' CONFIG_JOLIET $CONFIG_ISO9660_FS
 dep_mbool '  Transparent decompression extension' CONFIG_ZISOFS $CONFIG_ISO9660_FS
diff -Nur --exclude=SCCS --exclude=BitKeeper --exclude=ChangeSet linux-2.5/fs/Makefile hugetlbfs/fs/Makefile
--- linux-2.5/fs/Makefile	Wed Oct  2 20:14:48 2002
+++ hugetlbfs/fs/Makefile	Wed Oct  2 22:01:15 2002
@@ -46,6 +46,7 @@
 obj-$(CONFIG_EXT2_FS)		+= ext2/
 obj-$(CONFIG_CRAMFS)		+= cramfs/
 obj-$(CONFIG_RAMFS)		+= ramfs/
+obj-$(CONFIG_HUGETLBFS)		+= hugetlbfs/
 obj-$(CONFIG_CODA_FS)		+= coda/
 obj-$(CONFIG_INTERMEZZO_FS)	+= intermezzo/
 obj-$(CONFIG_MINIX_FS)		+= minix/
diff -Nur --exclude=SCCS --exclude=BitKeeper --exclude=ChangeSet linux-2.5/fs/hugetlbfs/Makefile hugetlbfs/fs/hugetlbfs/Makefile
--- linux-2.5/fs/hugetlbfs/Makefile	Wed Dec 31 16:00:00 1969
+++ hugetlbfs/fs/hugetlbfs/Makefile	Wed Oct  2 22:01:16 2002
@@ -0,0 +1,9 @@
+#
+# Makefile for the linux ramfs routines.
+#
+
+obj-$(CONFIG_HUGETLBFS) += hugetlbfs.o
+
+hugetlbfs-objs := inode.o
+
+include $(TOPDIR)/Rules.make
diff -Nur --exclude=SCCS --exclude=BitKeeper --exclude=ChangeSet linux-2.5/fs/hugetlbfs/inode.c hugetlbfs/fs/hugetlbfs/inode.c
--- linux-2.5/fs/hugetlbfs/inode.c	Wed Dec 31 16:00:00 1969
+++ hugetlbfs/fs/hugetlbfs/inode.c	Wed Oct  2 22:01:16 2002
@@ -0,0 +1,327 @@
+/*
+ * Resizable simple ram filesystem for Linux.
+ *
+ * Copyright (C) 2000 Linus Torvalds.
+ *               2000 Transmeta Corp.
+ *
+ * Usage limits added by David Gibson, Linuxcare Australia.
+ * This file is released under the GPL.
+ * Conversion for HugeTLB support by William Irwin, 2002
+ */
+
+/*
+ * NOTE! This filesystem is probably most useful
+ * not as a real filesystem, but as an example of
+ * how virtual filesystems can be written.
+ *
+ * It doesn't get much simpler than this. Consider
+ * that this file implements the full semantics of
+ * a POSIX-compliant read-write filesystem.
+ *
+ * Note in particular how the filesystem does not
+ * need to implement any data structures of its own
+ * to keep track of the virtual data: using the VFS
+ * caches is sufficient.
+ */
+
+#include <linux/module.h>
+#include <linux/fs.h>
+#include <linux/file.h>
+#include <linux/pagemap.h>
+#include <linux/highmem.h>
+#include <linux/init.h>
+#include <linux/string.h>
+#include <linux/smp_lock.h>
+#include <linux/backing-dev.h>
+
+#include <asm/uaccess.h>
+
+/* some random number */
+#define HUGETLBFS_MAGIC	0x958458f6
+
+static struct super_operations hugetlbfs_ops;
+static struct address_space_operations hugetlbfs_aops;
+struct file_operations hugetlbfs_file_operations;
+static struct inode_operations hugetlbfs_dir_inode_operations;
+
+static struct backing_dev_info hugetlbfs_backing_dev_info = {
+	.ra_pages	= 0,	/* No readahead */
+	.memory_backed	= 1,	/* Does not contribute to dirty memory */
+};
+
+static int hugetlbfs_file_mmap(struct file *file, struct vm_area_struct *vma)
+{
+	struct inode *inode =file->f_dentry->d_inode;
+	struct address_space *mapping = inode->i_mapping;
+	int ret;
+
+	if (vma->vm_start & ~HPAGE_MASK)
+		return -EINVAL;
+
+	if (vma->vm_end & ~HPAGE_MASK)
+		return -EINVAL;
+
+	if (vma->vm_end - vma->vm_start < HPAGE_SIZE)
+		return -EINVAL;
+
+	down(&inode->i_sem);
+
+	UPDATE_ATIME(inode);
+	vma->vm_flags |= VM_HUGETLB | VM_RESERVED;
+	vma->vm_ops = &hugetlb_vm_ops;
+	ret = hugetlb_prefault(mapping, vma);
+
+	up(&inode->i_sem);
+
+	return ret;
+}
+
+/*
+ * Read a page. Again trivial. If it didn't already exist
+ * in the page cache, it is zero-filled.
+ */
+static int hugetlbfs_readpage(struct file *file, struct page * page)
+{
+	return -EINVAL;
+}
+
+static int hugetlbfs_prepare_write(struct file *file, struct page *page, unsigned offset, unsigned to)
+{
+	return -EINVAL;
+}
+
+static int hugetlbfs_commit_write(struct file *file, struct page *page, unsigned offset, unsigned to)
+{
+	return -EINVAL;
+}
+
+struct inode *hugetlbfs_get_inode(struct super_block *sb, int mode, int dev)
+{
+	struct inode * inode = new_inode(sb);
+
+	if (inode) {
+		inode->i_mode = mode;
+		inode->i_uid = current->fsuid;
+		inode->i_gid = current->fsgid;
+		inode->i_blksize = PAGE_CACHE_SIZE;
+		inode->i_blocks = 0;
+		inode->i_rdev = NODEV;
+		inode->i_mapping->a_ops = &hugetlbfs_aops;
+		inode->i_mapping->backing_dev_info = &hugetlbfs_backing_dev_info;
+		inode->i_atime = inode->i_mtime = inode->i_ctime = CURRENT_TIME;
+		switch (mode & S_IFMT) {
+		default:
+			init_special_inode(inode, mode, dev);
+			break;
+		case S_IFREG:
+			inode->i_fop = &hugetlbfs_file_operations;
+			break;
+		case S_IFDIR:
+			inode->i_op = &hugetlbfs_dir_inode_operations;
+			inode->i_fop = &simple_dir_operations;
+
+			/* directory inodes start off with i_nlink == 2 (for "." entry) */
+			inode->i_nlink++;
+			break;
+		case S_IFLNK:
+			inode->i_op = &page_symlink_inode_operations;
+			break;
+		}
+	}
+	return inode;
+}
+
+/*
+ * File creation. Allocate an inode, and we're done..
+ */
+/* SMP-safe */
+static int hugetlbfs_mknod(struct inode *dir, struct dentry *dentry, int mode, int dev)
+{
+	struct inode * inode = hugetlbfs_get_inode(dir->i_sb, mode, dev);
+	int error = -ENOSPC;
+
+	if (inode) {
+		d_instantiate(dentry, inode);
+		dget(dentry);		/* Extra count - pin the dentry in core */
+		error = 0;
+	}
+	return error;
+}
+
+static int hugetlbfs_mkdir(struct inode * dir, struct dentry * dentry, int mode)
+{
+	int retval = hugetlbfs_mknod(dir, dentry, mode | S_IFDIR, 0);
+	if (!retval)
+		dir->i_nlink++;
+	return retval;
+}
+
+static int hugetlbfs_create(struct inode *dir, struct dentry *dentry, int mode)
+{
+	return hugetlbfs_mknod(dir, dentry, mode | S_IFREG, 0);
+}
+
+static int hugetlbfs_symlink(struct inode * dir, struct dentry *dentry, const char * symname)
+{
+	struct inode *inode;
+	int error = -ENOSPC;
+
+	inode = hugetlbfs_get_inode(dir->i_sb, S_IFLNK|S_IRWXUGO, 0);
+	if (inode) {
+		int l = strlen(symname)+1;
+		error = page_symlink(inode, symname, l);
+		if (!error) {
+			d_instantiate(dentry, inode);
+			dget(dentry);
+		} else
+			iput(inode);
+	}
+	return error;
+}
+
+static struct address_space_operations hugetlbfs_aops = {
+	readpage:	hugetlbfs_readpage,
+	writepage:	fail_writepage,
+	prepare_write:	hugetlbfs_prepare_write,
+	commit_write:	hugetlbfs_commit_write
+};
+
+struct file_operations hugetlbfs_file_operations = {
+	read:		generic_file_read,
+	write:		generic_file_write,
+	mmap:		hugetlbfs_file_mmap,
+	fsync:		simple_sync_file,
+	sendfile:	generic_file_sendfile,
+};
+
+static struct inode_operations hugetlbfs_dir_inode_operations = {
+	create:		hugetlbfs_create,
+	lookup:		simple_lookup,
+	link:		simple_link,
+	unlink:		simple_unlink,
+	symlink:	hugetlbfs_symlink,
+	mkdir:		hugetlbfs_mkdir,
+	rmdir:		simple_rmdir,
+	mknod:		hugetlbfs_mknod,
+	rename:		simple_rename,
+};
+
+static struct super_operations hugetlbfs_ops = {
+	statfs:		simple_statfs,
+	drop_inode:	generic_delete_inode,
+};
+
+static int hugetlbfs_fill_super(struct super_block * sb, void * data, int silent)
+{
+	struct inode * inode;
+	struct dentry * root;
+
+	sb->s_blocksize = PAGE_CACHE_SIZE;
+	sb->s_blocksize_bits = PAGE_CACHE_SHIFT;
+	sb->s_magic = HUGETLBFS_MAGIC;
+	sb->s_op = &hugetlbfs_ops;
+	inode = hugetlbfs_get_inode(sb, S_IFDIR | 0755, 0);
+	if (!inode)
+		return -ENOMEM;
+
+	root = d_alloc_root(inode);
+	if (!root) {
+		iput(inode);
+		return -ENOMEM;
+	}
+	sb->s_root = root;
+	return 0;
+}
+
+static struct super_block *hugetlbfs_get_sb(struct file_system_type *fs_type,
+	int flags, char *dev_name, void *data)
+{
+	return get_sb_nodev(fs_type, flags, data, hugetlbfs_fill_super);
+}
+
+static struct file_system_type hugetlbfs_fs_type = {
+	name:		"hugetlbfs",
+	get_sb:		hugetlbfs_get_sb,
+	kill_sb:	kill_litter_super,
+};
+
+static struct vfsmount *hugetlbfs_vfsmount;
+
+static atomic_t hugetlbfs_counter = ATOMIC_INIT(0);
+
+struct file *hugetlb_zero_setup(size_t size)
+{
+	int error, n;
+	struct file *file;
+	struct inode *inode;
+	struct dentry *dentry, *root;
+	struct qstr quick_string;
+	char buf[16];
+
+	n = atomic_read(&hugetlbfs_counter);
+	atomic_inc(&hugetlbfs_counter);
+
+	root = hugetlbfs_vfsmount->mnt_root;
+	snprintf(buf, 16, "%d", n);
+	quick_string.name = buf;
+	quick_string.len = strlen(quick_string.name);
+	quick_string.hash = 0;
+	dentry = d_alloc(root, &quick_string);
+	if (!dentry)
+		return ERR_PTR(-ENOMEM);
+
+	error = -ENFILE;
+	file = get_empty_filp();
+	if (!file)
+		goto out_dentry;
+
+	error = -ENOSPC;
+	inode = hugetlbfs_get_inode(root->d_sb, S_IFREG | S_IRWXUGO, 0);
+	if (!inode)
+		goto out_file;
+
+	d_instantiate(dentry, inode);
+	inode->i_size = size;
+	inode->i_nlink = 0;
+	file->f_vfsmnt = mntget(hugetlbfs_vfsmount);
+	file->f_dentry = dentry;
+	file->f_op = &hugetlbfs_file_operations;
+	file->f_mode = FMODE_WRITE | FMODE_READ;
+	return file;
+
+out_file:
+	put_filp(file);
+out_dentry:
+	dput(dentry);
+	return ERR_PTR(error);
+}
+
+static int __init init_hugetlbfs_fs(void)
+{
+	int error;
+	struct vfsmount *vfsmount;
+
+	error = register_filesystem(&hugetlbfs_fs_type);
+	if (error)
+		return error;
+
+	vfsmount = kern_mount(&hugetlbfs_fs_type);
+
+	if (!IS_ERR(vfsmount)) {
+		hugetlbfs_vfsmount = vfsmount;
+		return 0;
+	}
+
+	error = PTR_ERR(vfsmount);
+	return error;
+}
+
+static void __exit exit_hugetlbfs_fs(void)
+{
+	unregister_filesystem(&hugetlbfs_fs_type);
+}
+
+module_init(init_hugetlbfs_fs)
+module_exit(exit_hugetlbfs_fs)
+
+MODULE_LICENSE("GPL");
diff -Nur --exclude=SCCS --exclude=BitKeeper --exclude=ChangeSet linux-2.5/fs/libfs.c hugetlbfs/fs/libfs.c
--- linux-2.5/fs/libfs.c	Wed Oct  2 20:14:48 2002
+++ hugetlbfs/fs/libfs.c	Wed Oct  2 22:01:15 2002
@@ -208,3 +208,73 @@
 	deactivate_super(s);
 	return ERR_PTR(-ENOMEM);
 }
+
+int simple_link(struct dentry *old_dentry, struct inode *dir, struct dentry *dentry)
+{
+	struct inode *inode = old_dentry->d_inode;
+
+	inode->i_nlink++;
+	atomic_inc(&inode->i_count);
+	dget(dentry);
+	d_instantiate(dentry, inode);
+	return 0;
+}
+
+static inline int simple_positive(struct dentry *dentry)
+{
+	return dentry->d_inode && !d_unhashed(dentry);
+}
+
+static int simple_empty(struct dentry *dentry)
+{
+	struct dentry *child;
+	int ret = 0;
+
+	spin_lock(&dcache_lock);
+	list_for_each_entry(child, &dentry->d_subdirs, d_child)
+		if (simple_positive(child))
+			goto out;
+	ret = 1;
+out:
+	spin_unlock(&dcache_lock);
+	return ret;
+}
+
+int simple_unlink(struct inode *dir, struct dentry *dentry)
+{
+	struct inode *inode = dentry->d_inode;
+
+	inode->i_nlink--;
+	dput(dentry);
+	return 0;
+}
+
+int simple_rmdir(struct inode *dir, struct dentry *dentry)
+{
+	if (!simple_empty(dentry))
+		return -ENOTEMPTY;
+
+	dentry->d_inode->i_nlink--;
+	simple_unlink(dir, dentry);
+	dir->i_nlink--;
+	return 0;
+}
+
+int simple_rename(struct inode *old_dir, struct dentry *old_dentry, struct inode *new_dir, struct dentry *new_dentry)
+{
+	struct inode *inode;
+
+	if (!simple_empty(new_dentry))
+		return -ENOTEMPTY;
+
+	inode = new_dentry->d_inode;
+	if (inode) {
+		inode->i_nlink--;
+		dput(new_dentry);
+	}
+	if (S_ISDIR(old_dentry->d_inode->i_mode)) {
+		old_dir->i_nlink--;
+		new_dir->i_nlink++;
+	}
+	return 0;
+}
diff -Nur --exclude=SCCS --exclude=BitKeeper --exclude=ChangeSet linux-2.5/fs/ramfs/inode.c hugetlbfs/fs/ramfs/inode.c
--- linux-2.5/fs/ramfs/inode.c	Wed Oct  2 20:14:49 2002
+++ hugetlbfs/fs/ramfs/inode.c	Wed Oct  2 22:01:17 2002
@@ -155,102 +155,6 @@
 	return ramfs_mknod(dir, dentry, mode | S_IFREG, 0);
 }
 
-/*
- * Link a file..
- */
-static int ramfs_link(struct dentry *old_dentry, struct inode * dir, struct dentry * dentry)
-{
-	struct inode *inode = old_dentry->d_inode;
-
-	inode->i_nlink++;
-	atomic_inc(&inode->i_count);	/* New dentry reference */
-	dget(dentry);		/* Extra pinning count for the created dentry */
-	d_instantiate(dentry, inode);
-	return 0;
-}
-
-static inline int ramfs_positive(struct dentry *dentry)
-{
-	return dentry->d_inode && !d_unhashed(dentry);
-}
-
-/*
- * Check that a directory is empty (this works
- * for regular files too, they'll just always be
- * considered empty..).
- *
- * Note that an empty directory can still have
- * children, they just all have to be negative..
- */
-static int ramfs_empty(struct dentry *dentry)
-{
-	struct list_head *list;
-
-	spin_lock(&dcache_lock);
-	list = dentry->d_subdirs.next;
-
-	while (list != &dentry->d_subdirs) {
-		struct dentry *de = list_entry(list, struct dentry, d_child);
-
-		if (ramfs_positive(de)) {
-			spin_unlock(&dcache_lock);
-			return 0;
-		}
-		list = list->next;
-	}
-	spin_unlock(&dcache_lock);
-	return 1;
-}
-
-/*
- * Unlink a ramfs entry
- */
-static int ramfs_unlink(struct inode * dir, struct dentry *dentry)
-{
-	struct inode *inode = dentry->d_inode;
-
-	inode->i_nlink--;
-	dput(dentry);			/* Undo the count from "create" - this does all the work */
-	return 0;
-}
-
-static int ramfs_rmdir(struct inode * dir, struct dentry *dentry)
-{
-	int retval = -ENOTEMPTY;
-
-	if (ramfs_empty(dentry)) {
-		dentry->d_inode->i_nlink--;
-		ramfs_unlink(dir, dentry);
-		dir->i_nlink--;
-		retval = 0;
-	}
-	return retval;
-}
-
-/*
- * The VFS layer already does all the dentry stuff for rename,
- * we just have to decrement the usage count for the target if
- * it exists so that the VFS layer correctly free's it when it
- * gets overwritten.
- */
-static int ramfs_rename(struct inode * old_dir, struct dentry *old_dentry, struct inode * new_dir,struct dentry *new_dentry)
-{
-	int error = -ENOTEMPTY;
-
-	if (ramfs_empty(new_dentry)) {
-		struct inode *inode = new_dentry->d_inode;
-		if (inode) {
-			inode->i_nlink--;
-			dput(new_dentry);
-		}
-		if (S_ISDIR(old_dentry->d_inode->i_mode)) {
-			old_dir->i_nlink--;
-			new_dir->i_nlink++;
-		}
-		error = 0;
-	}
-	return error;
-}
 
 static int ramfs_symlink(struct inode * dir, struct dentry *dentry, const char * symname)
 {
@@ -270,11 +174,6 @@
 	return error;
 }
 
-static int ramfs_sync_file(struct file * file, struct dentry *dentry, int datasync)
-{
-	return 0;
-}
-
 static struct address_space_operations ramfs_aops = {
 	.readpage	= ramfs_readpage,
 	.writepage	= fail_writepage,
@@ -286,20 +185,20 @@
 	.read		= generic_file_read,
 	.write		= generic_file_write,
 	.mmap		= generic_file_mmap,
-	.fsync		= ramfs_sync_file,
+	.fsync		= simple_sync_file,
 	.sendfile	= generic_file_sendfile,
 };
 
 static struct inode_operations ramfs_dir_inode_operations = {
 	.create		= ramfs_create,
 	.lookup		= simple_lookup,
-	.link		= ramfs_link,
-	.unlink		= ramfs_unlink,
+	.link		= simple_link,
+	.unlink		= simple_unlink,
 	.symlink	= ramfs_symlink,
 	.mkdir		= ramfs_mkdir,
-	.rmdir		= ramfs_rmdir,
+	.rmdir		= simple_rmdir,
 	.mknod		= ramfs_mknod,
-	.rename		= ramfs_rename,
+	.rename		= simple_rename,
 };
 
 static struct super_operations ramfs_ops = {
diff -Nur --exclude=SCCS --exclude=BitKeeper --exclude=ChangeSet linux-2.5/include/linux/fs.h hugetlbfs/include/linux/fs.h
--- linux-2.5/include/linux/fs.h	Wed Oct  2 20:14:55 2002
+++ hugetlbfs/include/linux/fs.h	Wed Oct  2 22:01:24 2002
@@ -1290,6 +1290,11 @@
 extern loff_t dcache_dir_lseek(struct file *, loff_t, int);
 extern int dcache_readdir(struct file *, void *, filldir_t);
 extern int simple_statfs(struct super_block *, struct statfs *);
+extern int simple_link(struct dentry *, struct inode *, struct dentry *);
+extern int simple_unlink(struct inode *, struct dentry *);
+extern int simple_rmdir(struct inode *, struct dentry *);
+extern int simple_rename(struct inode *, struct dentry *, struct inode *, struct dentry *);
+extern int simple_sync_file(struct file *, struct dentry *, int);
 extern struct dentry *simple_lookup(struct inode *, struct dentry *);
 extern ssize_t generic_read_dir(struct file *, char *, size_t, loff_t *);
 extern struct file_operations simple_dir_operations;
diff -Nur --exclude=SCCS --exclude=BitKeeper --exclude=ChangeSet linux-2.5/include/linux/mm.h hugetlbfs/include/linux/mm.h
--- linux-2.5/include/linux/mm.h	Wed Oct  2 20:14:55 2002
+++ hugetlbfs/include/linux/mm.h	Wed Oct  2 22:01:25 2002
@@ -386,7 +386,9 @@
 extern int copy_hugetlb_page_range(struct mm_struct *, struct mm_struct *, struct vm_area_struct *);
 extern int follow_hugetlb_page(struct mm_struct *, struct vm_area_struct *, struct page **, struct vm_area_struct **, unsigned long *, int *, int);
 extern	int free_hugepages(struct vm_area_struct *);
-
+extern int hugetlb_prefault(struct address_space *, struct vm_area_struct *);
+extern struct file *hugetlb_zero_setup(size_t);
+extern struct file_operations hugetlbfs_file_operations;
 #else
 #define is_vm_hugetlb_page(vma) (0)
 #define follow_hugetlb_page(mm, vma, pages, vmas, start, len, i) (0)
@@ -394,6 +396,7 @@
 #define free_hugepages(mpnt)  do { } while(0)
 #endif
 
+extern struct vm_operations_struct hugetlb_vm_ops;
 
 /*
  * If the mapping doesn't provide a set_page_dirty a_op, then
diff -Nur --exclude=SCCS --exclude=BitKeeper --exclude=ChangeSet linux-2.5/include/linux/shm.h hugetlbfs/include/linux/shm.h
--- linux-2.5/include/linux/shm.h	Wed Oct  2 20:14:55 2002
+++ hugetlbfs/include/linux/shm.h	Wed Oct  2 22:01:25 2002
@@ -88,6 +88,7 @@
 /* shm_mode upper byte flags */
 #define	SHM_DEST	01000	/* segment will be destroyed on last detach */
 #define SHM_LOCKED      02000   /* segment will not be swapped */
+#define SHM_HUGETLB     04000   /* segment will use huge TLB pages */
 
 asmlinkage long sys_shmget (key_t key, size_t size, int flag);
 asmlinkage long sys_shmat (int shmid, char *shmaddr, int shmflg, unsigned long *addr);
diff -Nur --exclude=SCCS --exclude=BitKeeper --exclude=ChangeSet linux-2.5/ipc/shm.c hugetlbfs/ipc/shm.c
--- linux-2.5/ipc/shm.c	Wed Oct  2 20:14:56 2002
+++ hugetlbfs/ipc/shm.c	Wed Oct  2 22:01:26 2002
@@ -185,8 +185,12 @@
 	shp->shm_perm.key = key;
 	shp->shm_flags = (shmflg & S_IRWXUGO);
 
-	sprintf (name, "SYSV%08x", key);
-	file = shmem_file_setup(name, size, VM_ACCOUNT);
+	if (shmflg & SHM_HUGETLB)
+		file = hugetlb_zero_setup(size);
+	else {
+		sprintf (name, "SYSV%08x", key);
+		file = shmem_file_setup(name, size, VM_ACCOUNT);
+	}
 	error = PTR_ERR(file);
 	if (IS_ERR(file))
 		goto no_file;
@@ -205,7 +209,10 @@
 	shp->id = shm_buildid(id,shp->shm_perm.seq);
 	shp->shm_file = file;
 	file->f_dentry->d_inode->i_ino = shp->id;
-	file->f_op = &shm_file_operations;
+	if (shmflg & SHM_HUGETLB)
+		file->f_op = &hugetlbfs_file_operations;
+	else
+		file->f_op = &shm_file_operations;
 	shm_tot += numpages;
 	shm_unlock (id);
 	return shp->id;
@@ -663,18 +670,26 @@
 asmlinkage long sys_shmdt (char *shmaddr)
 {
 	struct mm_struct *mm = current->mm;
-	struct vm_area_struct *shmd, *shmdnext;
+	struct vm_area_struct *vma;
+	unsigned long address = (unsigned long)shmaddr;
 	int retval = -EINVAL;
 
 	down_write(&mm->mmap_sem);
-	for (shmd = mm->mmap; shmd; shmd = shmdnext) {
-		shmdnext = shmd->vm_next;
-		if (shmd->vm_ops == &shm_vm_ops
-		    && shmd->vm_start - (shmd->vm_pgoff << PAGE_SHIFT) == (ulong) shmaddr) {
-			do_munmap(mm, shmd->vm_start, shmd->vm_end - shmd->vm_start);
-			retval = 0;
-		}
-	}
+	vma = find_vma(mm, address);
+	if (!vma)
+		goto out;
+	if (vma->vm_start != address)
+		goto out;
+	
+	/* ->vm_pgoff is always 0, see do_mmap() in sys_shmat() */
+	retval = 0;
+	if (vma->vm_ops == &shm_vm_ops)
+		do_munmap(mm, vma->vm_start, vma->vm_end - vma->vm_start);
+	else if (vma->vm_ops == &hugetlb_vm_ops)
+		free_hugepages(vma);
+	else
+		retval = -EINVAL;
+out:
 	up_write(&mm->mmap_sem);
 	return retval;
 }
diff -Nur --exclude=SCCS --exclude=BitKeeper --exclude=ChangeSet linux-2.5/kernel/ksyms.c hugetlbfs/kernel/ksyms.c
--- linux-2.5/kernel/ksyms.c	Wed Oct  2 20:14:56 2002
+++ hugetlbfs/kernel/ksyms.c	Wed Oct  2 22:01:26 2002
@@ -302,6 +302,11 @@
 EXPORT_SYMBOL(simple_lookup);
 EXPORT_SYMBOL(simple_dir_operations);
 EXPORT_SYMBOL(simple_dir_inode_operations);
+EXPORT_SYMBOL(simple_link);
+EXPORT_SYMBOL(simple_unlink);
+EXPORT_SYMBOL(simple_rmdir);
+EXPORT_SYMBOL(simple_rename);
+EXPORT_SYMBOL(simple_sync_file);
 EXPORT_SYMBOL(fd_install);
 EXPORT_SYMBOL(put_unused_fd);
 EXPORT_SYMBOL(get_sb_bdev);
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
