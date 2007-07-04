Received: by wa-out-1112.google.com with SMTP id m33so2947017wag
        for <linux-mm@kvack.org>; Tue, 03 Jul 2007 18:09:40 -0700 (PDT)
Message-ID: <6934efce0707031809w46f37d66t2b4b0e09283ee1c8@mail.gmail.com>
Date: Tue, 3 Jul 2007 18:09:40 -0700
From: "Jared Hulbert" <jaredeh@gmail.com>
Subject: 2.6.22-rc6-mm1: BUG_ON() mm/memory.c, vm_insert_pfn(), filemap_xip.c, and spufs
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Recently there has been some discussion of the possiblity of reworking
some of filemap_xip.c to be pfn oriented.  This would allow an XIP
fork of cramfs to use the filemap_xip framework.  Today this is not
possible.

I've been trying out vm_insert_pfn() to start down that road.  I used
spufs as a reference for how to use it.  The include patch to cramfs
is my hack at it.

When I try to execute an XIP binary I get a BUG() on 2.6.22-rc6-mm1 at
mm/memory.c line 2334.  The way I read this is says that spufs might
not work.  I can't test it.
In spufs_mem_mmap() line 196 the vma is flagged as VM_PFNMAP:
     vma->vm_flags |= VM_IO | VM_PFNMAP;

When you get a fault in a vma  __do_fault() will get this vma and
BUG() on line 2334:
     BUG_ON(vma->vm_flags & VM_PFNMAP);

What happened to the functionality of do_no_pfn()?




diff -r 74bad9e01817 fs/Kconfig
--- a/fs/Kconfig	Thu Jun 28 13:49:43 2007 -0700
+++ b/fs/Kconfig	Mon Jul 02 15:47:16 2007 -0700
@@ -65,8 +65,7 @@ config FS_XIP
 config FS_XIP
 # execute in place
 	bool
-	depends on EXT2_FS_XIP
-	default y
+	default n

 config EXT3_FS
 	tristate "Ext3 journalling file system support"
@@ -1399,8 +1398,8 @@ endchoice

 config CRAMFS
 	tristate "Compressed ROM file system support (cramfs)"
-	depends on BLOCK
 	select ZLIB_INFLATE
+	select FS_XIP
 	help
 	  Saying Y here includes support for CramFs (Compressed ROM File
 	  System).  CramFs is designed to be a simple, small, and compressed
diff -r 74bad9e01817 fs/cramfs/inode.c
--- a/fs/cramfs/inode.c	Thu Jun 28 13:49:43 2007 -0700
+++ b/fs/cramfs/inode.c	Tue Jul 03 17:45:42 2007 -0700
@@ -24,15 +24,21 @@
 #include <linux/vfs.h>
 #include <linux/mutex.h>
 #include <asm/semaphore.h>
-
+#include <linux/vmalloc.h>
 #include <asm/uaccess.h>

+static const struct file_operations cramfs_xip_fops;
 static const struct super_operations cramfs_ops;
 static const struct inode_operations cramfs_dir_inode_operations;
 static const struct file_operations cramfs_directory_operations;
 static const struct address_space_operations cramfs_aops;
+static const struct address_space_operations cramfs_xip_aops;

 static DEFINE_MUTEX(read_mutex);
+
+static struct backing_dev_info cramfs_backing_dev_info = {
+	.ra_pages		= 0,	/* No readahead */
+};


 /* These two macros may change in future, to provide better st_ino
@@ -77,19 +83,31 @@ static int cramfs_iget5_set(struct inode
 	/* Struct copy intentional */
 	inode->i_mtime = inode->i_atime = inode->i_ctime = zerotime;
 	inode->i_ino = CRAMINO(cramfs_inode);
+
+	if (CRAMFS_INODE_IS_XIP(inode))
+		inode->i_mapping->backing_dev_info = &cramfs_backing_dev_info;
+
 	/* inode->i_nlink is left 1 - arguably wrong for directories,
 	   but it's the best we can do without reading the directory
            contents.  1 yields the right result in GNU find, even
 	   without -noleaf option. */
 	if (S_ISREG(inode->i_mode)) {
-		inode->i_fop = &generic_ro_fops;
-		inode->i_data.a_ops = &cramfs_aops;
+		if (CRAMFS_INODE_IS_XIP(inode)) {
+			inode->i_fop = &cramfs_xip_fops;
+			inode->i_data.a_ops = &cramfs_xip_aops;
+		} else {
+			inode->i_fop = &generic_ro_fops;
+			inode->i_data.a_ops = &cramfs_aops;
+		}
 	} else if (S_ISDIR(inode->i_mode)) {
 		inode->i_op = &cramfs_dir_inode_operations;
 		inode->i_fop = &cramfs_directory_operations;
 	} else if (S_ISLNK(inode->i_mode)) {
 		inode->i_op = &page_symlink_inode_operations;
-		inode->i_data.a_ops = &cramfs_aops;
+		if (CRAMFS_INODE_IS_XIP(inode))
+			inode->i_data.a_ops = &cramfs_xip_aops;
+		else
+			inode->i_data.a_ops = &cramfs_aops;
 	} else {
 		inode->i_size = 0;
 		inode->i_blocks = 0;
@@ -111,34 +129,6 @@ static struct inode *get_cramfs_inode(st
 	return inode;
 }

-/*
- * We have our own block cache: don't fill up the buffer cache
- * with the rom-image, because the way the filesystem is set
- * up the accesses should be fairly regular and cached in the
- * page cache and dentry tree anyway..
- *
- * This also acts as a way to guarantee contiguous areas of up to
- * BLKS_PER_BUF*PAGE_CACHE_SIZE, so that the caller doesn't need to
- * worry about end-of-buffer issues even when decompressing a full
- * page cache.
- */
-#define READ_BUFFERS (2)
-/* NEXT_BUFFER(): Loop over [0..(READ_BUFFERS-1)]. */
-#define NEXT_BUFFER(_ix) ((_ix) ^ 1)
-
-/*
- * BLKS_PER_BUF_SHIFT should be at least 2 to allow for "compressed"
- * data that takes up more space than the original and with unlucky
- * alignment.
- */
-#define BLKS_PER_BUF_SHIFT	(2)
-#define BLKS_PER_BUF		(1 << BLKS_PER_BUF_SHIFT)
-#define BUFFER_SIZE		(BLKS_PER_BUF*PAGE_CACHE_SIZE)
-
-static unsigned char read_buffers[READ_BUFFERS][BUFFER_SIZE];
-static unsigned buffer_blocknr[READ_BUFFERS];
-static struct super_block * buffer_dev[READ_BUFFERS];
-static int next_buffer;

 /*
  * Returns a pointer to a buffer containing at least LEN bytes of
@@ -146,78 +136,11 @@ static int next_buffer;
  */
 static void *cramfs_read(struct super_block *sb, unsigned int offset,
unsigned int len)
 {
-	struct address_space *mapping = sb->s_bdev->bd_inode->i_mapping;
-	struct page *pages[BLKS_PER_BUF];
-	unsigned i, blocknr, buffer, unread;
-	unsigned long devsize;
-	char *data;
+	struct cramfs_sb_info *sbi = CRAMFS_SB(sb);

 	if (!len)
 		return NULL;
-	blocknr = offset >> PAGE_CACHE_SHIFT;
-	offset &= PAGE_CACHE_SIZE - 1;
-
-	/* Check if an existing buffer already has the data.. */
-	for (i = 0; i < READ_BUFFERS; i++) {
-		unsigned int blk_offset;
-
-		if (buffer_dev[i] != sb)
-			continue;
-		if (blocknr < buffer_blocknr[i])
-			continue;
-		blk_offset = (blocknr - buffer_blocknr[i]) << PAGE_CACHE_SHIFT;
-		blk_offset += offset;
-		if (blk_offset + len > BUFFER_SIZE)
-			continue;
-		return read_buffers[i] + blk_offset;
-	}
-
-	devsize = mapping->host->i_size >> PAGE_CACHE_SHIFT;
-
-	/* Ok, read in BLKS_PER_BUF pages completely first. */
-	unread = 0;
-	for (i = 0; i < BLKS_PER_BUF; i++) {
-		struct page *page = NULL;
-
-		if (blocknr + i < devsize) {
-			page = read_mapping_page_async(mapping, blocknr + i,
-									NULL);
-			/* synchronous error? */
-			if (IS_ERR(page))
-				page = NULL;
-		}
-		pages[i] = page;
-	}
-
-	for (i = 0; i < BLKS_PER_BUF; i++) {
-		struct page *page = pages[i];
-		if (page) {
-			wait_on_page_locked(page);
-			if (!PageUptodate(page)) {
-				/* asynchronous error */
-				page_cache_release(page);
-				pages[i] = NULL;
-			}
-		}
-	}
-
-	buffer = next_buffer;
-	next_buffer = NEXT_BUFFER(buffer);
-	buffer_blocknr[buffer] = blocknr;
-	buffer_dev[buffer] = sb;
-
-	data = read_buffers[buffer];
-	for (i = 0; i < BLKS_PER_BUF; i++) {
-		struct page *page = pages[i];
-		if (page) {
-			memcpy(data, kmap(page), PAGE_CACHE_SIZE);
-			kunmap(page);
-			page_cache_release(page);
-		} else
-			memset(data, 0, PAGE_CACHE_SIZE);
-		data += PAGE_CACHE_SIZE;
-	}
-	return read_buffers[buffer] + offset;
+	return sbi->linear_virt_addr + offset;
 }

 static void cramfs_put_super(struct super_block *sb)
@@ -234,11 +157,12 @@ static int cramfs_remount(struct super_b

 static int cramfs_fill_super(struct super_block *sb, void *data, int silent)
 {
-	int i;
 	struct cramfs_super super;
 	unsigned long root_offset;
 	struct cramfs_sb_info *sbi;
 	struct inode *root;
+	unsigned long phys_addr;
+	char *p;

 	sb->s_flags |= MS_RDONLY;

@@ -247,11 +171,36 @@ static int cramfs_fill_super(struct supe
 		return -ENOMEM;
 	sb->s_fs_info = sbi;

-	/* Invalidate the read buffers on mount: think disk change.. */
-	mutex_lock(&read_mutex);
-	for (i = 0; i < READ_BUFFERS; i++)
-		buffer_blocknr[i] = -1;
-
+	p = strstr(data, "physaddr=");
+	if (!p)
+               goto out_kfree;
+
+	phys_addr = simple_strtoul(p + 9, NULL, 0);
+	if (phys_addr & (PAGE_SIZE-1)) {
+		printk(KERN_ERR "cramfs: physical address 0x%lx for linear"
+				"cramfs isn't aligned to a page boundary\n",
+				phys_addr);
+		goto out_kfree;
+	}
+
+	if (phys_addr == 0) {
+		printk(KERN_ERR "cramfs: physical address for linear cramfs"
+				"image can't be 0\n");
+		goto out_kfree;
+	}
+
+	printk(KERN_INFO "cramfs: checking physical address 0x%lx for linear"
+			 "cramfs image\n", phys_addr);
+
+	/* Map only one page for now.  Will remap it when fs size is known. */
+	sbi->linear_virt_addr = ioremap(phys_addr, PAGE_SIZE);
+	if (!sbi->linear_virt_addr) {
+		printk(KERN_ERR "cramfs: ioremap of the linear cramfs image"
+				"failed\n");
+		goto out_kfree;
+	}
+
+	mutex_lock(&read_mutex);
 	/* Read the first block and get the superblock from it */
 	memcpy(&super, cramfs_read(sb, 0, sizeof(super)), sizeof(super));
 	mutex_unlock(&read_mutex);
@@ -265,20 +214,20 @@ static int cramfs_fill_super(struct supe
 		if (super.magic != CRAMFS_MAGIC) {
 			if (!silent)
 				printk(KERN_ERR "cramfs: wrong magic\n");
-			goto out;
+			goto out_iounmap;
 		}
 	}

 	/* get feature flags first */
 	if (super.flags & ~CRAMFS_SUPPORTED_FLAGS) {
 		printk(KERN_ERR "cramfs: unsupported filesystem features\n");
-		goto out;
+		goto out_iounmap;
 	}

 	/* Check that the root inode is in a sane state */
 	if (!S_ISDIR(super.root.mode)) {
 		printk(KERN_ERR "cramfs: root is not a directory\n");
-		goto out;
+		goto out_iounmap;
 	}
 	root_offset = super.root.offset << 2;
 	if (super.flags & CRAMFS_FLAG_FSID_VERSION_2) {
@@ -299,21 +248,35 @@ static int cramfs_fill_super(struct supe
 		  (root_offset != 512 + sizeof(struct cramfs_super))))
 	{
 		printk(KERN_ERR "cramfs: bad root offset %lu\n", root_offset);
-		goto out;
+		goto out_iounmap;
 	}

 	/* Set it all up.. */
 	sb->s_op = &cramfs_ops;
 	root = get_cramfs_inode(sb, &super.root);
 	if (!root)
-		goto out;
+		goto out_iounmap;
 	sb->s_root = d_alloc_root(root);
 	if (!sb->s_root) {
 		iput(root);
-		goto out;
-	}
-	return 0;
-out:
+		goto out_iounmap;
+	}
+
+	/* Remap the whole filesystem now */
+	iounmap(sbi->linear_virt_addr);
+	sbi->linear_virt_addr = ioremap(phys_addr, sbi->size);
+	if (!sbi->linear_virt_addr) {
+		printk(KERN_ERR "cramfs: ioremap of the linear cramfs image"
+				" failed\n");
+		goto out_iounmap;
+	}
+	sbi->linear_phys_addr = phys_addr;
+
+	return 0;
+
+ out_iounmap:
+	iounmap(sbi->linear_virt_addr);
+ out_kfree:
 	kfree(sbi);
 	sb->s_fs_info = NULL;
 	return -EINVAL;
@@ -332,6 +295,61 @@ static int cramfs_statfs(struct dentry *
 	buf->f_ffree = 0;
 	buf->f_namelen = CRAMFS_MAXPATHLEN;
 	return 0;
+}
+
+static struct page *cramfs_mem_mmap_fault(struct vm_area_struct *vma,
+					  struct fault_data *fdata)
+{
+	struct file *file = vma->vm_file;
+	struct address_space *mapping = file->f_mapping;
+	struct inode *inode = mapping->host;
+	struct super_block *sb = inode->i_sb;
+	struct cramfs_sb_info *sbi = CRAMFS_SB(sb);
+	unsigned long pfn;
+	unsigned long offset;
+	unsigned long address;
+	
+	address = PAGE_ALIGN(sbi->linear_phys_addr + OFFSET(inode));
+	offset = fdata->pgoff << PAGE_SHIFT;
+	pfn =  (address + offset) >> PAGE_SHIFT;
+	printk(KERN_ERR "cramfs_mem_mmap_fault: address=0x%lx offset=0x%lx
pfn=0x%lx\n",fdata->address,offset,pfn);
+	vm_insert_pfn(vma, fdata->address, pfn);
+	fdata->type = VM_FAULT_MINOR;
+	return NULL;
+}
+
+static struct vm_operations_struct cramfs_mem_mmap_vmops = {
+	.fault = cramfs_mem_mmap_fault,
+};
+
+static int cramfs_mmap(struct file *file, struct vm_area_struct *vma)
+{
+	if ((vma->vm_flags & VM_SHARED) && (vma->vm_flags & VM_MAYWRITE))
+		return -EINVAL;
+
+	if (vma->vm_flags & VM_WRITE)
+		return generic_file_mmap(file, vma);
+
+	vma->vm_flags |= VM_IO | VM_PFNMAP;
+	vma->vm_ops = &cramfs_mem_mmap_vmops;
+	return 0;
+}
+
+struct page *cramfs_get_xip_page(struct address_space *mapping,
sector_t offset,
+			       int create)
+{
+ 	unsigned long address;
+	unsigned long offs = offset;
+	struct inode *inode = mapping->host;
+	struct super_block *sb = inode->i_sb;
+	struct cramfs_sb_info *sbi = CRAMFS_SB(sb);
+
+	address  = PAGE_ALIGN((unsigned long)(sbi->linear_virt_addr
+		+ OFFSET(inode)));
+	offs *= 512; /* FIXME -- This shouldn't be hard coded */
+	address += offs;
+
+	return virt_to_page(address);
 }

 /*
@@ -503,12 +521,22 @@ static int cramfs_readpage(struct file *
 }

 static const struct address_space_operations cramfs_aops = {
-	.readpage = cramfs_readpage
+	.readpage = cramfs_readpage,
+};
+
+static const struct address_space_operations cramfs_xip_aops = {
+	.readpage = cramfs_readpage,
+	.get_xip_page = cramfs_get_xip_page,	
 };

 /*
  * Our operations:
  */
+
+static const struct file_operations cramfs_xip_fops = {
+	.read		= xip_file_read,
+	.mmap		= cramfs_mmap,
+};

 /*
  * A directory can only readdir
@@ -532,16 +560,14 @@ static int cramfs_get_sb(struct file_sys
 static int cramfs_get_sb(struct file_system_type *fs_type,
 	int flags, const char *dev_name, void *data, struct vfsmount *mnt)
 {
-	return get_sb_bdev(fs_type, flags, dev_name, data, cramfs_fill_super,
-			   mnt);
+	return get_sb_nodev(fs_type, flags, data, cramfs_fill_super, mnt);
 }

 static struct file_system_type cramfs_fs_type = {
 	.owner		= THIS_MODULE,
 	.name		= "cramfs",
 	.get_sb		= cramfs_get_sb,
-	.kill_sb	= kill_block_super,
-	.fs_flags	= FS_REQUIRES_DEV,
+	.kill_sb	= kill_anon_super,
 };

 static int __init init_cramfs_fs(void)
diff -r 74bad9e01817 include/linux/cramfs_fs_sb.h
--- a/include/linux/cramfs_fs_sb.h	Thu Jun 28 13:49:43 2007 -0700
+++ b/include/linux/cramfs_fs_sb.h	Tue Jul 03 13:25:58 2007 -0700
@@ -10,6 +10,8 @@ struct cramfs_sb_info {
 			unsigned long blocks;
 			unsigned long files;
 			unsigned long flags;
+			void __iomem *linear_virt_addr;
+			unsigned long linear_phys_addr;
 };

 static inline struct cramfs_sb_info *CRAMFS_SB(struct super_block *sb)
@@ -17,4 +19,7 @@ static inline struct cramfs_sb_info *CRA
 	return sb->s_fs_info;
 }

+#define CRAMFS_INODE_IS_XIP(x) \
+	((x)->i_mode & S_ISVTX)
+
 #endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
