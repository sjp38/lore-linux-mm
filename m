Received: by zproxy.gmail.com with SMTP id 8so10749nzo
        for <linux-mm@kvack.org>; Tue, 25 Oct 2005 15:42:25 -0700 (PDT)
Message-ID: <6934efce0510251542j66c0a738qe3c37fe56aaaaf2d@mail.gmail.com>
Date: Tue, 25 Oct 2005 15:42:25 -0700
From: Jared Hulbert <jaredeh@gmail.com>
Subject: VM_XIP Request for comments
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

What would it take to get this first patch in the kernel?

The reason for the first patch is in the second patch, which I will
try to get into the kernel list.  With this mmap()'ed files can be
used directly from flash when possible and COW's it when necessary..


Index: include/linux/mm.h
===================================================================
--- include/linux/mm.h	(revision 3)
+++ include/linux/mm.h	(revision 7)
@@ -159,6 +159,7 @@
 #define VM_DONTEXPAND	0x00040000	/* Cannot expand with mremap() */
 #define VM_RESERVED	0x00080000	/* Don't unmap it from swap_out */
 #define VM_ACCOUNT	0x00100000	/* Is a VM accounted object */
+#define VM_XIP		0x00200000	/* Execute In Place from ROM/flash */
 #define VM_HUGETLB	0x00400000	/* Huge TLB Page VM */
 #define VM_NONLINEAR	0x00800000	/* Is non-linear (remap_file_pages) */
 #define VM_MAPPED_COPY	0x01000000	/* T if mapped copy of data (nommu mmap) */
Index: mm/memory.c
===================================================================
--- mm/memory.c	(revision 3)
+++ mm/memory.c	(revision 7)
@@ -945,7 +945,8 @@
 			continue;
 		}

-		if (!vma || (vma->vm_flags & VM_IO)
+		if (!vma || ((vma->vm_flags & VM_IO)
+				&& !(vma->vm_flags & VM_XIP))
 				|| !(flags & vma->vm_flags))
 			return i ? : -EFAULT;

@@ -1252,6 +1253,46 @@
 	int ret;

 	if (unlikely(!pfn_valid(pfn))) {
+		if ((vma->vm_flags & VM_XIP) && pte_present(pte) &&
+		    pte_read(pte)) {
+			/*
+			 * Handle COW of XIP memory.
+			 * Note that the source memory actually isn't a ram
+			 * page so no struct page is associated to the source
+			 * pte.
+			 */
+			char *dst;
+			int ret;
+
+			spin_unlock(&mm->page_table_lock);
+			new_page = alloc_page(GFP_HIGHUSER);
+			if (!new_page)
+				return VM_FAULT_OOM;
+			
+			/* copy XIP data to memory */
+
+			dst = kmap_atomic(new_page, KM_USER0);
+			ret = copy_from_user(dst, (void*)address, PAGE_SIZE);
+			kunmap_atomic(dst, KM_USER0);
+
+			/* make sure pte didn't change while we dropped the
+			   lock */
+			spin_lock(&mm->page_table_lock);
+			if (!ret && pte_same(*page_table, pte)) {
+				++mm->_rss;
+				break_cow(vma, new_page, address, page_table);
+				lru_cache_add(new_page);
+				page_add_file_rmap(new_page);
+				spin_unlock(&mm->page_table_lock);
+				return VM_FAULT_MINOR;	/* Minor fault */
+			}
+
+			/* pte changed: back off */
+			spin_unlock(&mm->page_table_lock);
+			page_cache_release(new_page);
+			return ret ? VM_FAULT_OOM : VM_FAULT_MINOR;
+		}
+
 		/*
 		 * This should really halt the system so it can be debugged or
 		 * at least the kernel stops what it's doing before it corrupts

Index: include/linux/cramfs_fs_sb.h
===================================================================
--- include/linux/cramfs_fs_sb.h	(revision 3)
+++ include/linux/cramfs_fs_sb.h	(revision 7)
@@ -10,6 +10,10 @@
 			unsigned long blocks;
 			unsigned long files;
 			unsigned long flags;
+#ifdef CONFIG_CRAMFS_LINEAR
+			unsigned long linear_phys_addr;
+			char *        linear_virt_addr;
+#endif /* CONFIG_CRAMFS_LINEAR */
 };

 static inline struct cramfs_sb_info *CRAMFS_SB(struct super_block *sb)
Index: init/do_mounts.c
===================================================================
--- init/do_mounts.c	(revision 3)
+++ init/do_mounts.c	(revision 7)
@@ -328,6 +328,15 @@
 	return 0;
 }
 #endif
+#ifdef CONFIG_ROOT_CRAMFS_LINEAR
+static int __init mount_cramfs_linear_root(void)
+{
+	create_dev("/dev/root", ROOT_DEV, root_device_name);
+	if (do_mount_root("/dev/root","cramfs",root_mountflags,root_mount_data) == 0)
+		return 1;
+	return 0;
+}
+#endif

 #if defined(CONFIG_BLK_DEV_RAM) || defined(CONFIG_BLK_DEV_FD)
 void __init change_floppy(char *fmt, ...)
@@ -361,6 +370,13 @@

 void __init mount_root(void)
 {
+#ifdef CONFIG_ROOT_CRAMFS_LINEAR
+        if (ROOT_DEV == MKDEV(0, 0)) {
+	        if (mount_cramfs_linear_root())
+		        return;
+		printk (KERN_ERR "VFS: Unable to mount linear cramfs root.\n");
+	}
+#endif
 #ifdef CONFIG_ROOT_NFS
 	if (MAJOR(ROOT_DEV) == UNNAMED_MAJOR) {
 		if (mount_nfs_root())
Index: fs/cramfs/inode.c
===================================================================
--- fs/cramfs/inode.c	(revision 3)
+++ fs/cramfs/inode.c	(revision 7)
@@ -11,6 +11,39 @@
  * The actual compression is based on zlib, see the other files.
  */

+/* Linear Addressing code
+ *
+ * Copyright (C) 2000 Shane Nay.
+ *
+ * Allows you to have a linearly addressed cramfs filesystem.
+ * Saves the need for buffer, and the munging of the buffer.
+ * Savings a bit over 32k with default PAGE_SIZE, BUFFER_SIZE
+ * etc.  Usefull on embedded platform with ROM :-).
+ *
+ * Downsides- Currently linear addressed cramfs partitions
+ * don't co-exist with block cramfs partitions.
+ *
+ */
+
+/*
+ * 28-Dec-2000: XIP mode for linear cramfs
+ * Copyright (C) 2000 Robert Leslie <rob@mars.org>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+
 #include <linux/module.h>
 #include <linux/fs.h>
 #include <linux/pagemap.h>
@@ -25,6 +58,7 @@
 #include <asm/semaphore.h>

 #include <asm/uaccess.h>
+#include <asm/tlbflush.h>

 static struct super_operations cramfs_ops;
 static struct inode_operations cramfs_dir_inode_operations;
@@ -71,6 +105,66 @@
 	return 0;
 }

+ #ifdef CONFIG_CRAMFS_LINEAR_XIP
+ static int cramfs_mmap(struct file *file, struct vm_area_struct *vma)
+ {
+ 	unsigned long address, length;
+ 	struct inode *inode = file->f_dentry->d_inode;
+ 	struct super_block *sb = inode->i_sb;
+ 	struct cramfs_sb_info *sbi = CRAMFS_SB(sb);
+
+ 	/* this is only used in the case of read-only maps for XIP */
+
+ 	if (vma->vm_flags & VM_WRITE)
+ 		return generic_file_mmap(file, vma);
+
+ 	if ((vma->vm_flags & VM_SHARED) && (vma->vm_flags & VM_MAYWRITE))
+ 		return -EINVAL;
+
+ 	address  = PAGE_ALIGN(sbi->linear_phys_addr + OFFSET(inode));
+ 	address += vma->vm_pgoff << PAGE_SHIFT;
+
+ 	length = vma->vm_end - vma->vm_start;
+
+ 	if (length > inode->i_size)
+ 		length = inode->i_size;
+
+ 	length = PAGE_ALIGN(length);
+
+ 	/*
+ 	 * Don't dump addresses that are not real memory to a core file.
+ 	 */
+ 	vma->vm_flags |= (VM_IO | VM_XIP);
+ 	flush_tlb_page(vma, address);
+ 	if (remap_pfn_range(vma, vma->vm_start, address >> PAGE_SHIFT, length,
+ 			     vma->vm_page_prot))
+ 		return -EAGAIN;
+
+ #ifdef DEBUG_CRAMFS_XIP
+ 	printk("cramfs_mmap: mapped %s at 0x%08lx, length %lu to vma 0x%08lx"
+ 		", page_prot 0x%08lx\n",
+ 		file->f_dentry->d_name.name, address, length,
+ 		vma->vm_start, pgprot_val(vma->vm_page_prot));
+ #endif
+
+ 	return 0;
+ }
+
+ static struct file_operations cramfs_linear_xip_fops = {
+ 	read:	generic_file_read,
+ 	mmap:	cramfs_mmap,
+ };
+
+ #define CRAMFS_INODE_IS_XIP(x) ((x)->i_mode & S_ISVTX)
+
+ #endif
+
+ #ifdef CONFIG_CRAMFS_LINEAR
+ static struct backing_dev_info cramfs_backing_dev_info = {
+ 	.ra_pages	= 0,	/* No readahead */
+ };
+ #endif
+
 static struct inode *get_cramfs_inode(struct super_block *sb,
 				struct cramfs_inode * cramfs_inode)
 {
@@ -86,6 +180,9 @@
 		inode->i_blocks = (cramfs_inode->size - 1) / 512 + 1;
 		inode->i_blksize = PAGE_CACHE_SIZE;
 		inode->i_gid = cramfs_inode->gid;
+#ifdef CONFIG_CRAMFS_LINEAR
+		inode->i_mapping->backing_dev_info = &cramfs_backing_dev_info;
+#endif
 		/* Struct copy intentional */
 		inode->i_mtime = inode->i_atime = inode->i_ctime = zerotime;
 		inode->i_ino = CRAMINO(cramfs_inode);
@@ -94,7 +191,11 @@
 	           contents.  1 yields the right result in GNU find, even
 		   without -noleaf option. */
 		if (S_ISREG(inode->i_mode)) {
+#ifdef CONFIG_CRAMFS_LINEAR_XIP
+			inode->i_fop = CRAMFS_INODE_IS_XIP(inode) ?
&cramfs_linear_xip_fops : &generic_ro_fops;
+#else
 			inode->i_fop = &generic_ro_fops;
+#endif
 			inode->i_data.a_ops = &cramfs_aops;
 		} else if (S_ISDIR(inode->i_mode)) {
 			inode->i_op = &cramfs_dir_inode_operations;
@@ -113,7 +214,20 @@
 	return inode;
 }

+#ifdef CONFIG_CRAMFS_LINEAR
 /*
+ * Return a pointer to the block in the linearly addressed cramfs image.
+ */
+static void *cramfs_read(struct super_block *sb, unsigned int offset,
unsigned int len)
+{
+	struct cramfs_sb_info *sbi = CRAMFS_SB(sb);
+
+	if (!len)
+		return NULL;
+	return (void*)(sbi->linear_virt_addr + offset);
+}
+#else /* Not linear addressing - aka regular block mode. */
+/*
  * We have our own block cache: don't fill up the buffer cache
  * with the rom-image, because the way the filesystem is set
  * up the accesses should be fairly regular and cached in the
@@ -222,6 +336,7 @@
 	}
 	return read_buffers[buffer] + offset;
 }
+#endif /* CONFIG_CRAMFS_LINEAR */

 static void cramfs_put_super(struct super_block *sb)
 {
@@ -237,7 +352,11 @@

 static int cramfs_fill_super(struct super_block *sb, void *data, int silent)
 {
+#ifndef CONFIG_CRAMFS_LINEAR
 	int i;
+#else
+	char *p;
+#endif
 	struct cramfs_super super;
 	unsigned long root_offset;
 	struct cramfs_sb_info *sbi;
@@ -251,11 +370,48 @@
 	sb->s_fs_info = sbi;
 	memset(sbi, 0, sizeof(struct cramfs_sb_info));

+#ifndef CONFIG_CRAMFS_LINEAR
 	/* Invalidate the read buffers on mount: think disk change.. */
 	down(&read_mutex);
 	for (i = 0; i < READ_BUFFERS; i++)
 		buffer_blocknr[i] = -1;

+#else /* CONFIG_CRAMFS_LINEAR */
+	/*
+	 * The physical location of the cramfs image is specified as
+	 * a mount parameter.  This parameter is mandatory for obvious
+	 * reasons.  Some validation is made on the phys address but this
+	 * is not exhaustive and we count on the fact that someone using
+	 * this feature is supposed to know what he/she's doing.
+	 */
+	if (!data || !(p = strstr((char *)data, "physaddr="))) {
+		printk(KERN_ERR "cramfs: unknown physical address for linear cramfs
image\n");
+		goto out;
+	}
+	sbi->linear_phys_addr = simple_strtoul(p + 9, NULL, 0);
+	if (sbi->linear_phys_addr & (PAGE_SIZE-1)) {
+		printk(KERN_ERR "cramfs: physical address 0x%lx for linear cramfs
isn't aligned to a page boundary\n",
+		       sbi->linear_phys_addr);
+		goto out;
+	}
+	if (sbi->linear_phys_addr == 0) {
+		printk(KERN_ERR "cramfs: physical address for linear cramfs image
can't be 0\n");
+		goto out;
+	}
+	printk(KERN_INFO "cramfs: checking physical address 0x%lx for linear
cramfs image\n",
+	       sbi->linear_phys_addr);
+
+	/* Map only one page for now.  Will remap it when fs size is known. */
+	sbi->linear_virt_addr =
+		ioremap(sbi->linear_phys_addr, PAGE_SIZE);
+	if (!sbi->linear_virt_addr) {
+		printk(KERN_ERR "cramfs: ioremap of the linear cramfs image failed\n");
+		goto out;
+	}
+
+	down(&read_mutex);
+#endif /* CONFIG_CRAMFS_LINEAR */
+
 	/* Read the first block and get the superblock from it */
 	memcpy(&super, cramfs_read(sb, 0, sizeof(super)), sizeof(super));
 	up(&read_mutex);
@@ -316,8 +472,27 @@
 		iput(root);
 		goto out;
 	}
+
+#ifdef CONFIG_CRAMFS_LINEAR
+	/* Remap the whole filesystem now */
+	iounmap(sbi->linear_virt_addr);
+	printk(KERN_INFO "cramfs: linear cramfs image appears to be %lu KB in size\n",
+	       sbi->size/1024);
+
+	sbi->linear_virt_addr =
+		ioremap_cached(sbi->linear_phys_addr, sbi->size);
+
+	if (!sbi->linear_virt_addr) {
+		printk(KERN_ERR "cramfs: ioremap of the linear cramfs image failed\n");
+		goto out;
+	}
+#endif /* CONFIG_CRAMFS_LINEAR */
 	return 0;
 out:
+#ifdef CONFIG_CRAMFS_LINEAR
+	if (sbi->linear_virt_addr)
+		iounmap(sbi->linear_virt_addr);
+#endif /* CONFIG_CRAMFS_LINEAR */
 	kfree(sbi);
 	sb->s_fs_info = NULL;
 	return -EINVAL;
@@ -475,6 +650,20 @@
 		u32 blkptr_offset = OFFSET(inode) + page->index*4;
 		u32 start_offset, compr_len;

+#ifdef CONFIG_CRAMFS_LINEAR_XIP
+		if(CRAMFS_INODE_IS_XIP(inode)) {
+			blkptr_offset =
+				PAGE_ALIGN(OFFSET(inode)) +
+				page->index * PAGE_CACHE_SIZE;
+			down(&read_mutex);
+			memcpy(page_address(page),
+				cramfs_read(sb, blkptr_offset, PAGE_CACHE_SIZE),
+				PAGE_CACHE_SIZE);
+			up(&read_mutex);
+			bytes_filled = PAGE_CACHE_SIZE;
+			pgdata = kmap(page);
+		} else {
+#endif /* CONFIG_CRAMFS_LINEAR_XIP */
 		start_offset = OFFSET(inode) + maxblock*4;
 		down(&read_mutex);
 		if (page->index)
@@ -492,6 +681,9 @@
 				 compr_len);
 			up(&read_mutex);
 		}
+#ifdef CONFIG_CRAMFS_LINEAR_XIP
+		}
+#endif /* CONFIG_CRAMFS_LINEAR_XIP */
 	} else
 		pgdata = kmap(page);
 	memset(pgdata + bytes_filled, 0, PAGE_CACHE_SIZE - bytes_filled);
@@ -532,7 +724,11 @@
 static struct super_block *cramfs_get_sb(struct file_system_type *fs_type,
 	int flags, const char *dev_name, void *data)
 {
+#ifdef CONFIG_CRAMFS_LINEAR
+	return get_sb_nodev(fs_type, flags, data, cramfs_fill_super);
+#else
 	return get_sb_bdev(fs_type, flags, dev_name, data, cramfs_fill_super);
+#endif
 }

 static struct file_system_type cramfs_fs_type = {
@@ -540,7 +736,9 @@
 	.name		= "cramfs",
 	.get_sb		= cramfs_get_sb,
 	.kill_sb	= kill_block_super,
+#ifndef CONFIG_CRAMFS_LINEAR
 	.fs_flags	= FS_REQUIRES_DEV,
+#endif /* CONFIG_CRAMFS_LINEAR */
 };

 static int __init init_cramfs_fs(void)
Index: fs/Kconfig
===================================================================
--- fs/Kconfig	(revision 3)
+++ fs/Kconfig	(revision 7)
@@ -1137,6 +1137,51 @@

 	  If unsure, say N.

+config CRAMFS_LINEAR
+	bool "Use linear addressing for CramFs"
+	depends on CRAMFS
+	help
+	  This option tells the CramFs driver to load data directly from
+	  a linear adressed memory range (usually non volatile memory
+	  like flash) instead of going through the block device layer.
+	  This saves some memory since no intermediate buffering is
+	  necessary.
+
+	  This is also a prerequisite for XIP of binaries stored on the
+	  filesystem.
+
+	  The location of the CramFs image in memory is board
+	  dependent. Therefore, if you say Y, you must know the proper
+	  physical address where to store the CramFs image and specify
+	  it using the physaddr=0x******** mount option (for example:
+	  "mount -t cramfs -o physaddr=0x100000 none /mnt").
+
+	  If unsure, say N.
+
+config CRAMFS_LINEAR_XIP
+	bool "Support XIP on linear CramFs"
+	depends on CRAMFS_LINEAR
+	help
+	  You must say Y to this option if you want to be able to run
+	  applications directly from non-volatile memory.  XIP
+	  applications are marked by setting the sticky bit (ie, "chmod
+	  +t <app name>").  A cramfs file system then needs to be
+	  created using mkcramfs (with XIP cramfs support in
+	  it). Applications marked for XIP execution will not be
+	  compressed since they have to run directly from flash.
+
+config ROOT_CRAMFS_LINEAR
+	bool "Root file system on linear CramFs"
+	depends on CRAMFS_LINEAR
+	help
+	  Say Y if you have enabled linear CramFs, and you want to be
+	  able to use the linear CramFs image as a root file system.  To
+	  actually have the kernel mount this CramFs image as a root
+	  file system, you must also pass the command line parameter
+	  "root=/dev/null rootflags=physaddr=0x********" to the kernel
+	  (replace 0x******** with the physical address location of the
+	  linear CramFs image to boot with).
+
 config VXFS_FS
 	tristate "FreeVxFS file system support (VERITAS VxFS(TM) compatible)"
 	help

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
