Received: from flinx.npwt.net (eric@flinx.npwt.net [208.236.161.237])
	by kvack.org (8.8.7/8.8.7) with ESMTP id EAA30346
	for <linux-mm@kvack.org>; Sun, 26 Apr 1998 04:32:07 -0400
Subject: Very preliminary patch for Large Files on 32bit Linux
From: ebiederm+eric@npwt.net (Eric W. Biederman)
Date: 26 Apr 1998 00:59:38 -0500
Message-ID: <m13ef1m8c5.fsf@flinx.npwt.net>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


This is my preliminary large file support patch.
This is still untested but I believe it meets the first goal, find
everything that needs to be modified.

This has just been tested by compilation.  I'm not in a situation
where I can reboot my computer just now.

The following things are on my todo:
- Examine the performance consequences of making inode->i_size 64bit.
- Modify Ext2 to support large files on 32 bit platforms.
- Reexaming mmap.  Making a 64bit safe mmap looks to be the biggest
  challenge.
- Implement a backing store structure that serves the same function as
  an inode does now except is smaller (with one embedded in inodes by
  default). 

And for the long term.  Plan to have this code ready for the start of 2.3
Whichever way I play it I see that mmap must be modified in some
non-trivial ways... 

Eric
diff -uNr linux-2.1.98/arch/alpha/kernel/ptrace.c linux-2.1.98.x1/arch/alpha/kernel/ptrace.c
--- linux-2.1.98/arch/alpha/kernel/ptrace.c	Tue Dec 16 12:42:09 1997
+++ linux-2.1.98.x1/arch/alpha/kernel/ptrace.c	Sat Apr 25 13:12:30 1998
@@ -264,7 +264,7 @@
 		return NULL;
 	if (vma->vm_end - addr > tsk->rlim[RLIMIT_STACK].rlim_cur)
 		return NULL;
-	vma->vm_offset -= vma->vm_start - addr;
+	vma->vm_index -= (vma->vm_start - addr) >> PAGE_SHIFT;
 	vma->vm_start = addr;
 	return vma;
 }
diff -uNr linux-2.1.98/arch/arm/kernel/ptrace.c linux-2.1.98.x1/arch/arm/kernel/ptrace.c
--- linux-2.1.98/arch/arm/kernel/ptrace.c	Wed Apr 22 11:08:35 1998
+++ linux-2.1.98.x1/arch/arm/kernel/ptrace.c	Sat Apr 25 13:12:54 1998
@@ -179,7 +179,7 @@
 		return NULL;
 	if (vma->vm_end - addr > tsk->rlim[RLIMIT_STACK].rlim_cur)
 		return NULL;
-	vma->vm_offset -= vma->vm_start - addr;
+	vma->vm_index -= (vma->vm_start - addr) >> PAGE_SHIFT;
 	vma->vm_start = addr;
 	return vma;
 }
diff -uNr linux-2.1.98/arch/i386/kernel/ptrace.c linux-2.1.98.x1/arch/i386/kernel/ptrace.c
--- linux-2.1.98/arch/i386/kernel/ptrace.c	Fri Mar 20 17:16:09 1998
+++ linux-2.1.98.x1/arch/i386/kernel/ptrace.c	Sat Apr 25 13:11:13 1998
@@ -187,7 +187,7 @@
 		return NULL;
 	if (vma->vm_end - addr > tsk->rlim[RLIMIT_STACK].rlim_cur)
 		return NULL;
-	vma->vm_offset -= vma->vm_start - addr;
+	vma->vm_index -= (vma->vm_start - addr) >> PAGE_SHIFT;
 	vma->vm_start = addr;
 	return vma;
 }
diff -uNr linux-2.1.98/arch/m68k/atari/stram.c linux-2.1.98.x1/arch/m68k/atari/stram.c
--- linux-2.1.98/arch/m68k/atari/stram.c	Fri Mar 20 17:14:22 1998
+++ linux-2.1.98.x1/arch/m68k/atari/stram.c	Sat Apr 25 19:04:03 1998
@@ -716,7 +716,7 @@
 			DPRINTK( "unswap_pte: page %08lx = entry %08lx was in swap cache; "
 					 "exchanging to %08lx\n",
 					 page_address(pg), entry, page );
-			pg->offset = page;
+			pg->key = page; /* correct change? */
 			swap_free(entry);
 			return 1;
 		}
diff -uNr linux-2.1.98/arch/m68k/kernel/ptrace.c linux-2.1.98.x1/arch/m68k/kernel/ptrace.c
--- linux-2.1.98/arch/m68k/kernel/ptrace.c	Sat Apr  4 11:57:58 1998
+++ linux-2.1.98.x1/arch/m68k/kernel/ptrace.c	Sat Apr 25 13:13:52 1998
@@ -210,7 +210,7 @@
 		return NULL;
 	if (vma->vm_end - addr > tsk->rlim[RLIMIT_STACK].rlim_cur)
 		return NULL;
-	vma->vm_offset -= vma->vm_start - addr;
+	vma->vm_index -= (vma->vm_start - addr) >> PAGE_SHIFT;
 	vma->vm_start = addr;
 	return vma;
 }
diff -uNr linux-2.1.98/arch/mips/kernel/ptrace.c linux-2.1.98.x1/arch/mips/kernel/ptrace.c
--- linux-2.1.98/arch/mips/kernel/ptrace.c	Mon Dec 29 06:17:48 1997
+++ linux-2.1.98.x1/arch/mips/kernel/ptrace.c	Sat Apr 25 13:14:18 1998
@@ -149,7 +149,7 @@
 		return NULL;
 	if (vma->vm_end - addr > tsk->rlim[RLIMIT_STACK].rlim_cur)
 		return NULL;
-	vma->vm_offset -= vma->vm_start - addr;
+	vma->vm_index -= (vma->vm_start - addr) >> PAGE_SHIFT;
 	vma->vm_start = addr;
 	return vma;
 }
diff -uNr linux-2.1.98/arch/ppc/kernel/ptrace.c linux-2.1.98.x1/arch/ppc/kernel/ptrace.c
--- linux-2.1.98/arch/ppc/kernel/ptrace.c	Wed Apr 22 11:10:52 1998
+++ linux-2.1.98.x1/arch/ppc/kernel/ptrace.c	Sat Apr 25 13:14:52 1998
@@ -204,7 +204,7 @@
 		return NULL;
 	if (vma->vm_end - addr > tsk->rlim[RLIMIT_STACK].rlim_cur)
 		return NULL;
-	vma->vm_offset -= vma->vm_start - addr;
+	vma->vm_index -= (vma->vm_start - addr) >> PAGE_SHIFT;
 	vma->vm_start = addr;
 	return vma;
 }
diff -uNr linux-2.1.98/arch/sparc/kernel/ptrace.c linux-2.1.98.x1/arch/sparc/kernel/ptrace.c
--- linux-2.1.98/arch/sparc/kernel/ptrace.c	Fri Mar 20 17:16:10 1998
+++ linux-2.1.98.x1/arch/sparc/kernel/ptrace.c	Sat Apr 25 13:15:21 1998
@@ -149,7 +149,7 @@
 		return NULL;
 	if (vma->vm_end - addr > tsk->rlim[RLIMIT_STACK].rlim_cur)
 		return NULL;
-	vma->vm_offset -= vma->vm_start - addr;
+	vma->vm_index -= (vma->vm_start - addr) >> PAGE_SHIFT;
 	vma->vm_start = addr;
 	return vma;
 }
diff -uNr linux-2.1.98/arch/sparc64/kernel/ptrace.c linux-2.1.98.x1/arch/sparc64/kernel/ptrace.c
--- linux-2.1.98/arch/sparc64/kernel/ptrace.c	Tue Jan 13 19:49:02 1998
+++ linux-2.1.98.x1/arch/sparc64/kernel/ptrace.c	Sat Apr 25 13:28:28 1998
@@ -180,7 +180,7 @@
 		return NULL;
 	if (vma->vm_end - addr > tsk->rlim[RLIMIT_STACK].rlim_cur)
 		return NULL;
-	vma->vm_offset -= vma->vm_start - addr;
+	vma->vm_offset -= (vma->vm_start - addr) >> PAGE_SHIFT;
 	vma->vm_start = addr;
 	return vma;
 }
diff -uNr linux-2.1.98/drivers/block/loop.c linux-2.1.98.x1/drivers/block/loop.c
--- linux-2.1.98/drivers/block/loop.c	Sat Apr  4 11:57:58 1998
+++ linux-2.1.98.x1/drivers/block/loop.c	Sun Apr 26 00:31:59 1998
@@ -167,12 +167,12 @@
 	int	size;
 
 	if (S_ISREG(lo->lo_inode->i_mode))
-		size = (lo->lo_inode->i_size - lo->lo_offset) / BLOCK_SIZE;
+		size = (lo->lo_inode->i_size - lo->lo_offset) >> BLOCK_SIZE_BITS;
 	else {
 		kdev_t lodev = lo->lo_device;
 		if (blk_size[MAJOR(lodev)])
-			size = blk_size[MAJOR(lodev)][MINOR(lodev)] -
-                                lo->lo_offset / BLOCK_SIZE;
+			size = (blk_size[MAJOR(lodev)][MINOR(lodev)] -
+                                lo->lo_offset) >> BLOCK_SIZE_BITS;
 		else
 			size = MAX_DISK_SIZE;
 	}
diff -uNr linux-2.1.98/drivers/char/fbmem.c linux-2.1.98.x1/drivers/char/fbmem.c
--- linux-2.1.98/drivers/char/fbmem.c	Fri Mar 20 17:15:35 1998
+++ linux-2.1.98.x1/drivers/char/fbmem.c	Sat Apr 25 13:49:52 1998
@@ -199,25 +199,32 @@
 	}
 }
 
-static int fb_mmap(struct file *file, struct vm_area_struct * vma)
+static int fb_mmap(struct file *file, struct vm_area_struct * vma, loff_t offset)
 {
 	struct fb_ops *fb = registered_fb[GET_FB_IDX(file->f_dentry->d_inode->i_rdev)];
 	struct fb_fix_screeninfo fix;
+	unsigned long vm_offset;
 
+	if (offset > PAGE_MAX_MEMORY_OFFSET) {
+		return -EINVAL;
+	}
+	vm_offset = offset;
+	vma->vm_index = offset >> PAGE_SHIFT;
 	if (! fb)
 		return -ENODEV;
 	fb->fb_get_fix(&fix, PROC_CONSOLE());
-	if ((vma->vm_end - vma->vm_start + vma->vm_offset) > fix.smem_len)
+	if ((vma->vm_end - vma->vm_start + vm_offset) > fix.smem_len)
 		return -EINVAL;
-	vma->vm_offset += __pa(fix.smem_start);
-	if (vma->vm_offset & ~PAGE_MASK)
+	vm_offset += __pa(fix.smem_start);
+	vma->vm_index = vm_offset >> PAGE_SHIFT;
+	if (vm_offset & ~PAGE_MASK)
 		return -ENXIO;
 	if (CPU_IS_040_OR_060) {
 		pgprot_val(vma->vm_page_prot) &= _CACHEMASK040;
 		/* Use write-through cache mode */
 		pgprot_val(vma->vm_page_prot) |= _PAGE_NOCACHE_S;
 	}
-	if (remap_page_range(vma->vm_start, vma->vm_offset,
+	if (remap_page_range(vma->vm_start, vm_offset,
 			     vma->vm_end - vma->vm_start, vma->vm_page_prot))
 		return -EAGAIN;
 	vma->vm_file = file;
diff -uNr linux-2.1.98/drivers/char/mem.c linux-2.1.98.x1/drivers/char/mem.c
--- linux-2.1.98/drivers/char/mem.c	Wed Apr 22 11:11:04 1998
+++ linux-2.1.98.x1/drivers/char/mem.c	Sat Apr 25 20:19:16 1998
@@ -122,10 +122,14 @@
 	return do_write_mem(file, __va(p), p, buf, count, ppos);
 }
 
-static int mmap_mem(struct file * file, struct vm_area_struct * vma)
+static int mmap_mem(struct file * file, struct vm_area_struct * vma, loff_t loff)
 {
-	unsigned long offset = vma->vm_offset;
-
+	unsigned long offset;
+	if (loff > PAGE_MAX_MEMORY_OFFSET) {
+		return -EINVAL;
+	}
+	offset = loff;
+	vma->vm_index = offset >> PAGE_SHIFT;
 	if (offset & ~PAGE_MASK)
 		return -ENXIO;
 #if defined(__i386__)
@@ -339,7 +343,7 @@
 	return written ? written : -EFAULT;
 }
 
-static int mmap_zero(struct file * file, struct vm_area_struct * vma)
+static int mmap_zero(struct file * file, struct vm_area_struct * vma, loff_t offset)
 {
 	if (vma->vm_flags & VM_SHARED)
 		return -EINVAL;
diff -uNr linux-2.1.98/drivers/sbus/char/sunfb.c linux-2.1.98.x1/drivers/sbus/char/sunfb.c
--- linux-2.1.98/drivers/sbus/char/sunfb.c	Tue Jan 13 19:49:15 1998
+++ linux-2.1.98.x1/drivers/sbus/char/sunfb.c	Sat Apr 25 14:01:35 1998
@@ -272,7 +272,6 @@
 	FB_SETUP(ENXIO)
 
 	fb = &fbinfo [minor];
-
 	if (fb->mmap){
 		int v;
 		
diff -uNr linux-2.1.98/drivers/sgi/char/graphics.c linux-2.1.98.x1/drivers/sgi/char/graphics.c
--- linux-2.1.98/drivers/sgi/char/graphics.c	Mon Dec 29 06:17:54 1997
+++ linux-2.1.98.x1/drivers/sgi/char/graphics.c	Sat Apr 25 14:10:20 1998
@@ -237,12 +237,20 @@
 };
 	
 int
-sgi_graphics_mmap (struct inode *inode, struct file *file, struct vm_area_struct *vma)
+sgi_graphics_mmap (struct inode *inode, struct file *file, struct vm_area_struct *vma,
+		   loff_t offset)
 {
 	uint size;
+	unsigned long vm_offset;
+	
+	if (offset > PAGE_MAX_MEMORY_OFFSET) {
+		return -EINVAL;
+	}
+	vm_offset = offset;
+	vma->vm_index = vm_offset >> PAGE_SHIFT;
 
 	size = vma->vm_end - vma->vm_start;
-	if (vma->vm_offset & ~PAGE_MASK)
+	if (vm_offset & ~PAGE_MASK)
 		return -ENXIO;
 
 	/* 1. Set our special graphic virtualizer  */
diff -uNr linux-2.1.98/drivers/sound/soundcard.c linux-2.1.98.x1/drivers/sound/soundcard.c
--- linux-2.1.98/drivers/sound/soundcard.c	Wed Apr 22 11:08:12 1998
+++ linux-2.1.98.x1/drivers/sound/soundcard.c	Sat Apr 25 20:39:19 1998
@@ -683,7 +683,7 @@
 	return 0;
 }
 
-static int sound_mmap(struct file *file, struct vm_area_struct *vma)
+static int sound_mmap(struct file *file, struct vm_area_struct *vma, loff_t offset)
 {
 	int dev_class;
 	unsigned long size;
@@ -723,7 +723,7 @@
 /*		printk("Sound: mmap() called twice for the same DMA buffer\n");*/
 		return -EIO;
 	}
-	if (vma->vm_offset != 0)
+	if (offset != 0)
 	{
 /*		printk("Sound: mmap() offset must be 0.\n");*/
 		return -EINVAL;
@@ -740,6 +740,7 @@
 		return -EAGAIN;
 
 	vma->vm_file = file;
+	vma->vm_index = 0;
 	file->f_count++;
 
 	dmap->mapping_flags |= DMA_MAP_MAPPED;
diff -uNr linux-2.1.98/fs/buffer.c linux-2.1.98.x1/fs/buffer.c
--- linux-2.1.98/fs/buffer.c	Wed Apr 22 11:08:13 1998
+++ linux-2.1.98.x1/fs/buffer.c	Wed Apr 22 11:45:42 1998
@@ -1336,7 +1336,7 @@
 #endif
 	}
 	if (test_and_clear_bit(PG_swap_unlock_after, &page->flags))
-		swap_after_unlock_page(page->offset);
+		swap_after_unlock_page(page->key);
 	if (test_and_clear_bit(PG_free_after, &page->flags))
 		__free_page(page);
 }
@@ -1560,7 +1560,7 @@
 	set_bit(PG_free_after, &page->flags);
 	
 	i = PAGE_SIZE >> inode->i_sb->s_blocksize_bits;
-	block = page->offset >> inode->i_sb->s_blocksize_bits;
+	block = page->key << (PAGE_SHIFT - inode->i_sb->s_blocksize_bits);
 	p = nr;
 	do {
 		*p = inode->i_op->bmap(inode, block);
diff -uNr linux-2.1.98/fs/coda/file.c linux-2.1.98.x1/fs/coda/file.c
--- linux-2.1.98/fs/coda/file.c	Fri Mar 20 17:16:22 1998
+++ linux-2.1.98.x1/fs/coda/file.c	Sat Apr 25 19:05:10 1998
@@ -95,8 +95,8 @@
         coda_prepare_openfile(coda_inode, coda_file, cii->c_ovp,
 			      &cont_file, &cont_dentry);
 
-        CDEBUG(D_INODE, "coda ino: %ld, cached ino %ld, page offset: %lx\n", 
-	       coda_inode->i_ino, cii->c_ovp->i_ino, page->offset);
+        CDEBUG(D_INODE, "coda ino: %ld, cached ino %ld, page key: %lx\n", 
+	       coda_inode->i_ino, cii->c_ovp->i_ino, page->key);
 
         generic_readpage(&cont_file, page);
         EXIT;
diff -uNr linux-2.1.98/fs/exec.c linux-2.1.98.x1/fs/exec.c
--- linux-2.1.98/fs/exec.c	Wed Apr 22 11:07:56 1998
+++ linux-2.1.98.x1/fs/exec.c	Sat Apr 25 18:22:49 1998
@@ -331,7 +331,7 @@
 		mpnt->vm_page_prot = PAGE_COPY;
 		mpnt->vm_flags = VM_STACK_FLAGS;
 		mpnt->vm_ops = NULL;
-		mpnt->vm_offset = 0;
+		mpnt->vm_index = 0;
 		mpnt->vm_file = NULL;
 		mpnt->vm_pte = 0;
 		insert_vm_struct(current->mm, mpnt);
diff -uNr linux-2.1.98/fs/ext2/truncate.c linux-2.1.98.x1/fs/ext2/truncate.c
--- linux-2.1.98/fs/ext2/truncate.c	Sat Apr  4 11:58:06 1998
+++ linux-2.1.98.x1/fs/ext2/truncate.c	Sun Apr 26 00:26:25 1998
@@ -68,8 +68,8 @@
 	unsigned long free_count = 0;
 	int retry = 0;
 	int blocks = inode->i_sb->s_blocksize / 512;
-#define DIRECT_BLOCK ((inode->i_size + inode->i_sb->s_blocksize - 1) / \
-			inode->i_sb->s_blocksize)
+#define DIRECT_BLOCK ((inode->i_size + inode->i_sb->s_blocksize - 1) >> \
+			inode->i_sb->s_blocksize_bits)
 	int direct_block = DIRECT_BLOCK;
 
 repeat:
diff -uNr linux-2.1.98/fs/fat/mmap.c linux-2.1.98.x1/fs/fat/mmap.c
--- linux-2.1.98/fs/fat/mmap.c	Fri Mar 20 17:15:44 1998
+++ linux-2.1.98.x1/fs/fat/mmap.c	Sat Apr 25 18:28:42 1998
@@ -42,7 +42,7 @@
 	if (!page)
 		return page;
 	address &= PAGE_MASK;
-	pos = address - area->vm_start + area->vm_offset;
+	pos = address - area->vm_start + (area->vm_index << PAGE_SHIFT);
 
 	clear = 0;
 	gap = inode->i_size - pos;
@@ -94,16 +94,19 @@
  * This is used for a general mmap of an msdos file
  * Returns 0 if ok, or a negative error code if not.
  */
-int fat_mmap(struct file * file, struct vm_area_struct * vma)
+int fat_mmap(struct file * file, struct vm_area_struct * vma, loff_t offset)
 {
 	struct inode *inode = file->f_dentry->d_inode;
+	if (offset > PAGE_MAX_MEMORY_OFFSET) {
+		return -EINVAL;
+	}
 	if (MSDOS_SB(inode->i_sb)->cvf_format &&
 	    MSDOS_SB(inode->i_sb)->cvf_format->cvf_mmap)
 		return MSDOS_SB(inode->i_sb)->cvf_format->cvf_mmap(file,vma);
 
 	if (vma->vm_flags & VM_SHARED)	/* only PAGE_COW or read-only supported now */
 		return -EINVAL;
-	if (vma->vm_offset & (inode->i_sb->s_blocksize - 1))
+	if (offset & ~PAGE_MASK) 
 		return -EINVAL;
 	if (!inode->i_sb || !S_ISREG(inode->i_mode))
 		return -EACCES;
@@ -112,6 +115,7 @@
 		mark_inode_dirty(inode);
 	}
 
+	vma->vm_index = offset >> PAGE_SHIFT;
 	vma->vm_file = file;
 	file->f_count++;
 	vma->vm_ops = &fat_file_mmap;
diff -uNr linux-2.1.98/fs/ncpfs/mmap.c linux-2.1.98.x1/fs/ncpfs/mmap.c
--- linux-2.1.98/fs/ncpfs/mmap.c	Fri Mar 20 17:15:45 1998
+++ linux-2.1.98.x1/fs/ncpfs/mmap.c	Sat Apr 25 18:32:14 1998
@@ -47,7 +47,7 @@
 	if (!page)
 		return page;
 	address &= PAGE_MASK;
-	pos = address - area->vm_start + area->vm_offset;
+	pos = address - area->vm_start + (area->vm_index << PAGE_SIZE);
 
 	clear = 0;
 	if (address + PAGE_SIZE > area->vm_end) {
@@ -119,7 +119,7 @@
 
 
 /* This is used for a general mmap of a ncp file */
-int ncp_mmap(struct file *file, struct vm_area_struct *vma)
+int ncp_mmap(struct file *file, struct vm_area_struct *vma, loff_t offset)
 {
 	struct inode *inode = file->f_dentry->d_inode;
 	
@@ -127,6 +127,12 @@
 
 	if (!ncp_conn_valid(NCP_SERVER(inode))) {
 		return -EIO;
+	}
+	if (offset > PAGE_MAX_MEMORY_OFFSET) {
+		return -EINVAL;
+	}
+	if (offset & ~PAGE_MASK) {
+		return -EINVAL;
 	}
 	/* only PAGE_COW or read-only supported now */
 	if (vma->vm_flags & VM_SHARED)
diff -uNr linux-2.1.98/fs/nfs/read.c linux-2.1.98.x1/fs/nfs/read.c
--- linux-2.1.98/fs/nfs/read.c	Fri Mar 20 17:15:46 1998
+++ linux-2.1.98.x1/fs/nfs/read.c	Sat Apr 25 19:06:37 1998
@@ -69,7 +69,7 @@
 nfs_readpage_sync(struct dentry *dentry, struct inode *inode, struct page *page)
 {
 	struct nfs_rreq	rqst;
-	unsigned long	offset = page->offset;
+	unsigned long	offset = page->key << PAGE_SHIFT;
 	char		*buffer = (char *) page_address(page);
 	int		rsize = NFS_SERVER(inode)->rsize;
 	int		result, refresh = 0;
@@ -183,7 +183,7 @@
 
 	/* Initialize request */
 	/* N.B. Will the dentry remain valid for life of request? */
-	nfs_readreq_setup(req, NFS_FH(dentry), page->offset,
+	nfs_readreq_setup(req, NFS_FH(dentry), page->key << PAGE_SHIT,
 				(void *) address, PAGE_SIZE);
 	req->ra_inode = inode;
 	req->ra_page = page; /* count has been incremented by caller */
@@ -228,7 +228,7 @@
 	int		error = -1;
 
 	dprintk("NFS: nfs_readpage (%p %ld@%ld)\n",
-		page, PAGE_SIZE, page->offset);
+		page, PAGE_SIZE, page->key << PAGE_SHIFT);
 	set_bit(PG_locked, &page->flags);
 	atomic_inc(&page->count);
 	if (!IS_SWAPFILE(inode) && !PageError(page) &&
diff -uNr linux-2.1.98/fs/nfs/write.c linux-2.1.98.x1/fs/nfs/write.c
--- linux-2.1.98/fs/nfs/write.c	Fri Mar 20 17:15:46 1998
+++ linux-2.1.98.x1/fs/nfs/write.c	Sat Apr 25 19:12:21 1998
@@ -97,7 +97,7 @@
 static inline void
 nfs_unlock_page(struct page *page)
 {
-	dprintk("NFS:      unlock %ld\n", page->offset);
+	dprintk("NFS:      unlock %ld\n", page->key << PAGE_SHIFT);
 	clear_bit(PG_locked, &page->flags);
 	wake_up(&page->wait);
 
@@ -146,10 +146,10 @@
 
 	dprintk("NFS:      nfs_writepage_sync(%s/%s %d@%ld)\n",
 		dentry->d_parent->d_name.name, dentry->d_name.name,
-		count, page->offset + offset);
+		count, (page->key << PAGE_SHIFT) + offset);
 
 	buffer = (u8 *) page_address(page) + offset;
-	offset += page->offset;
+	offset += page->key << PAGE_SHIFT;
 
 	do {
 		if (count < wsize && !IS_SWAPFILE(inode))
@@ -377,7 +377,7 @@
 
 	dprintk("NFS:      create_write_request(%s/%s, %ld+%d)\n",
 		dentry->d_parent->d_name.name, dentry->d_name.name,
-		page->offset + offset, bytes);
+		(page->key << PAGE_SHIFT) + offset, bytes);
 
 	/* FIXME: Enforce hard limit on number of concurrent writes? */
 
@@ -517,7 +517,7 @@
 
 	dprintk("NFS:      nfs_updatepage(%s/%s %d@%ld, sync=%d)\n",
 		dentry->d_parent->d_name.name, dentry->d_name.name,
-		count, page->offset+offset, sync);
+		count, (page->key << PAGE_SHIFT)+offset, sync);
 
 	set_bit(PG_locked, &page->flags);
 
@@ -617,7 +617,7 @@
 #endif
 	dprintk("NFS:      nfs_flush_request(%s/%s, @%ld)\n",
 		req->wb_dentry->d_parent->d_name.name,
-		req->wb_dentry->d_name.name, page->offset);
+		req->wb_dentry->d_name.name, page->key << PAGE_SHIFT);
 
 	req->wb_flags |= NFS_WRITE_WANTLOCK;
 	if (!test_and_set_bit(PG_locked, &page->flags)) {
@@ -647,9 +647,9 @@
 			req->wb_task.tk_pid,
 			req->wb_dentry->d_parent->d_name.name,
 			req->wb_dentry->d_name.name,
-			req->wb_page->offset, req->wb_flags);
+			req->wb_page->key << PAGE_SHIFT, req->wb_flags);
 
-		rqoffset = req->wb_page->offset + req->wb_offset;
+		rqoffset = (req->wb_page->key << PAGE_SHIFT) + req->wb_offset;
 		rqend    = rqoffset + req->wb_bytes;
 		if (rqoffset < end && offset < rqend &&
 		    (pid == 0 || req->wb_pid == pid)) {
@@ -777,7 +777,7 @@
 
 	req = head = NFS_WRITEBACK(inode);
 	while (req != NULL) {
-		rqoffset = req->wb_page->offset + req->wb_offset;
+		rqoffset = (req->wb_page->key << PAGE_SHIFT) + req->wb_offset;
 
 		if (rqoffset >= offset) {
 			nfs_cancel_request(req);
@@ -842,7 +842,7 @@
 
 	/* Setup the task struct for a writeback call */
 	req->wb_args.fh     = NFS_FH(dentry);
-	req->wb_args.offset = page->offset + req->wb_offset;
+	req->wb_args.offset = (page->key << PAGE_SHIFT) + req->wb_offset;
 	req->wb_args.count  = req->wb_bytes;
 	req->wb_args.buffer = (void *) (page_address(page) + req->wb_offset);
 
diff -uNr linux-2.1.98/fs/proc/array.c linux-2.1.98.x1/fs/proc/array.c
--- linux-2.1.98/fs/proc/array.c	Fri Mar 20 17:16:25 1998
+++ linux-2.1.98.x1/fs/proc/array.c	Sat Apr 25 18:35:49 1998
@@ -1094,7 +1094,7 @@
 
 		len = sprintf(line,
 			      sizeof(void*) == 4 ? MAPS_LINE_FORMAT4 : MAPS_LINE_FORMAT8,
-			      map->vm_start, map->vm_end, str, map->vm_offset,
+			      map->vm_start, map->vm_end, str, map->vm_index,
 			      kdevname(dev), ino);
 
 		if(map->vm_file) {
diff -uNr linux-2.1.98/fs/proc/mem.c linux-2.1.98.x1/fs/proc/mem.c
--- linux-2.1.98/fs/proc/mem.c	Sat Apr  4 11:58:41 1998
+++ linux-2.1.98.x1/fs/proc/mem.c	Sat Apr 25 18:43:43 1998
@@ -209,7 +209,7 @@
 /*
  * This isn't really reliable by any means..
  */
-int mem_mmap(struct file * file, struct vm_area_struct * vma)
+int mem_mmap(struct file * file, struct vm_area_struct * vma, loff_t offset)
 {
 	struct task_struct *tsk;
 	pgd_t *src_dir, *dest_dir;
@@ -218,6 +218,7 @@
 	unsigned long stmp, dtmp;
 	struct vm_area_struct *src_vma = NULL;
 	struct inode *inode = file->f_dentry->d_inode;
+	unsigned long vm_offset;
 	
 	/* Get the source's task information */
 
@@ -231,9 +232,14 @@
 	 moment because working out the vm_area_struct & nattach stuff isn't
 	 worth it. */
 
+	if (offset > PAGE_MAX_MEMORY_OFFSET) {
+		return -EINVAL;
+	}
+	vm_offset = offset;
+	vma->vm_index = vm_offset >> PAGE_SHIFT;
 	src_vma = tsk->mm->mmap;
-	stmp = vma->vm_offset;
-	while (stmp < vma->vm_offset + (vma->vm_end - vma->vm_start)) {
+	stmp = vm_offset;
+	while (stmp < ((vma->vm_index << PAGE_SHIFT) + (vma->vm_end - vma->vm_start))) {
 		while (src_vma && stmp > src_vma->vm_end)
 			src_vma = src_vma->vm_next;
 		if (!src_vma || (src_vma->vm_flags & VM_SHM))
@@ -267,7 +273,7 @@
 	}
 
 	src_vma = tsk->mm->mmap;
-	stmp    = vma->vm_offset;
+	stmp    = vma->vm_index << PAGE_SHIFT;
 	dtmp    = vma->vm_start;
 
 	flush_cache_range(vma->vm_mm, vma->vm_start, vma->vm_end);
diff -uNr linux-2.1.98/fs/romfs/inode.c linux-2.1.98.x1/fs/romfs/inode.c
--- linux-2.1.98/fs/romfs/inode.c	Wed Apr 22 11:07:57 1998
+++ linux-2.1.98.x1/fs/romfs/inode.c	Sat Apr 25 19:17:30 1998
@@ -401,7 +401,7 @@
 	buf = page_address(page);
 	clear_bit(PG_uptodate, &page->flags);
 	clear_bit(PG_error, &page->flags);
-	offset = page->offset;
+	offset = page->key << PAGE_SHIFT;
 	if (offset < inode->i_size) {
 		avail = inode->i_size-offset;
 		readlen = min(avail, PAGE_SIZE);
diff -uNr linux-2.1.98/fs/smbfs/file.c linux-2.1.98.x1/fs/smbfs/file.c
--- linux-2.1.98/fs/smbfs/file.c	Fri Mar 20 17:15:46 1998
+++ linux-2.1.98.x1/fs/smbfs/file.c	Sat Apr 25 19:16:10 1998
@@ -55,7 +55,7 @@
 smb_readpage_sync(struct dentry *dentry, struct page *page)
 {
 	char *buffer = (char *) page_address(page);
-	unsigned long offset = page->offset;
+	unsigned long offset = page->key << PAGE_SHIFT;
 	int rsize = smb_get_rsize(server_from_dentry(dentry));
 	int count = PAGE_SIZE;
 	int result;
@@ -132,7 +132,7 @@
 	int wsize = smb_get_wsize(server_from_dentry(dentry));
 	int result, written = 0;
 
-	offset += page->offset;
+	offset += page->key << PAGE_SHIFT;
 #ifdef SMBFS_DEBUG_VERBOSE
 printk("smb_writepage_sync: file %s/%s, count=%d@%ld, wsize=%d\n",
 dentry->d_parent->d_name.name, dentry->d_name.name, count, offset, wsize);
@@ -204,7 +204,7 @@
 
 	pr_debug("SMBFS: smb_updatepage(%s/%s %d@%ld, sync=%d)\n",
 		dentry->d_parent->d_name.name, dentry->d_name.name,
-	 	count, page->offset+offset, sync);
+	 	count, (page->key << PAGE_SHIFT)+offset, sync);
 
 #ifdef SMBFS_PARANOIA
 	if (test_bit(PG_locked, &page->flags))
diff -uNr linux-2.1.98/include/linux/fs.h linux-2.1.98.x1/include/linux/fs.h
--- linux-2.1.98/include/linux/fs.h	Fri Mar 20 17:15:48 1998
+++ linux-2.1.98.x1/include/linux/fs.h	Sat Apr 25 23:02:20 1998
@@ -300,7 +300,7 @@
 	umode_t		ia_mode;
 	uid_t		ia_uid;
 	gid_t		ia_gid;
-	off_t		ia_size;
+	loff_t		ia_size;
 	time_t		ia_atime;
 	time_t		ia_mtime;
 	time_t		ia_ctime;
@@ -331,7 +331,7 @@
 	uid_t			i_uid;
 	gid_t			i_gid;
 	kdev_t			i_rdev;
-	off_t			i_size;
+	loff_t			i_size;
 	time_t			i_atime;
 	time_t			i_mtime;
 	time_t			i_ctime;
@@ -441,8 +441,8 @@
 	struct file *fl_file;
 	unsigned char fl_flags;
 	unsigned char fl_type;
-	off_t fl_start;
-	off_t fl_end;
+	loff_t fl_start;
+	loff_t fl_end;
 
 	void (*fl_notify)(struct file_lock *);	/* unblock callback */
 
@@ -581,7 +581,7 @@
 	int (*readdir) (struct file *, void *, filldir_t);
 	unsigned int (*poll) (struct file *, struct poll_table_struct *);
 	int (*ioctl) (struct inode *, struct file *, unsigned int, unsigned long);
-	int (*mmap) (struct file *, struct vm_area_struct *);
+	int (*mmap) (struct file *, struct vm_area_struct *, loff_t off);
 	int (*open) (struct inode *, struct file *);
 	int (*release) (struct inode *, struct file *);
 	int (*fsync) (struct file *, struct dentry *);
@@ -808,7 +808,7 @@
 extern int brw_page(int, struct page *, kdev_t, int [], int, int);
 
 extern int generic_readpage(struct file *, struct page *);
-extern int generic_file_mmap(struct file *, struct vm_area_struct *);
+extern int generic_file_mmap(struct file *, struct vm_area_struct *, loff_t);
 extern ssize_t generic_file_read(struct file *, char *, size_t, loff_t *);
 extern ssize_t generic_file_write(struct file *, const char*, size_t, loff_t*);
 
diff -uNr linux-2.1.98/include/linux/mm.h linux-2.1.98.x1/include/linux/mm.h
--- linux-2.1.98/include/linux/mm.h	Wed Apr 22 11:08:16 1998
+++ linux-2.1.98.x1/include/linux/mm.h	Sun Apr 26 00:37:33 1998
@@ -47,7 +47,7 @@
 	struct vm_area_struct **vm_pprev_share;
 
 	struct vm_operations_struct * vm_ops;
-	unsigned long vm_offset;
+	unsigned long vm_index;
 	struct file * vm_file;
 	unsigned long vm_pte;			/* shared mem */
 };
@@ -74,6 +74,10 @@
 #define VM_LOCKED	0x2000
 #define VM_IO           0x4000  /* Memory mapped I/O or similar */
 
+#define VM_SPARSE_MERGE	0x8000 /* Sparce VMA's with non continous
+				* indecies may be merged 
+				*/
+
 #define VM_STACK_FLAGS	0x0177
 
 /*
@@ -98,6 +102,7 @@
 	unsigned long (*nopage)(struct vm_area_struct * area, unsigned long address, int write_access);
 	unsigned long (*wppage)(struct vm_area_struct * area, unsigned long address,
 		unsigned long page);
+	/* swapin & swapout changed! */
 	int (*swapout)(struct vm_area_struct *,  unsigned long, pte_t *);
 	pte_t (*swapin)(struct vm_area_struct *, unsigned long, unsigned long);
 };
@@ -115,7 +120,7 @@
 	struct page *next;
 	struct page *prev;
 	struct inode *inode;
-	unsigned long offset;
+	unsigned long key;
 	struct page *next_hash;
 	atomic_t count;
 	unsigned int age;
@@ -191,8 +196,9 @@
  * The following discussion applies only to them.
  *
  * A page may belong to an inode's memory mapping. In this case,
- * page->inode is the inode, and page->offset is the file offset
- * of the page (not necessarily a multiple of PAGE_SIZE).
+ * page->inode is the inode, and page->key is the index into a file.
+ * Generally the data for a page can be found in the page->inode at
+ * offset key*PAGE_SIZE.  
  *
  * A page may have buffers allocated to it. In this case,
  * page->buffers is a circular list of these buffer heads. Else,
@@ -204,7 +210,7 @@
  * All pages belonging to an inode make up a doubly linked list
  * inode->i_pages, using the fields page->next and page->prev. (These
  * fields are also used for freelist management when page->count==0.)
- * There is also a hash table mapping (inode,offset) to the page
+ * There is also a hash table mapping (inode,key) to the page
  * in memory if present. The lists for this hash table use the fields
  * page->next_hash and page->prev_hash.
  *
@@ -225,7 +231,7 @@
  *
  * For choosing which pages to swap out, inode pages carry a
  * page->referenced bit, which is set any time the system accesses
- * that page through the (inode,offset) hash table.
+ * that page through the (inode,key) hash table.
  * There is also the page->age counter, which implements a linear
  * decay (why not an exponential decay?), see swapctl.h.
  */
@@ -288,7 +294,7 @@
 extern int remap_page_range(unsigned long from, unsigned long to, unsigned long size, pgprot_t prot);
 extern int zeromap_page_range(unsigned long from, unsigned long size, pgprot_t prot);
 
-extern void vmtruncate(struct inode * inode, unsigned long offset);
+extern void vmtruncate(struct inode * inode, loff_t offset);
 extern void handle_mm_fault(struct task_struct *tsk,struct vm_area_struct *vma, unsigned long address, int write_access);
 
 extern unsigned long paging_init(unsigned long start_mem, unsigned long end_mem);
@@ -300,7 +306,7 @@
 /* mmap.c */
 extern void vma_init(void);
 extern unsigned long do_mmap(struct file * file, unsigned long addr, unsigned long len,
-	unsigned long prot, unsigned long flags, unsigned long off);
+	unsigned long prot, unsigned long flags, loff_t off);
 extern void merge_segments(struct mm_struct *, unsigned long, unsigned long);
 extern void insert_vm_struct(struct mm_struct *, struct vm_area_struct *);
 extern void exit_mmap(struct mm_struct *);
@@ -310,7 +316,7 @@
 /* filemap.c */
 extern unsigned long page_unuse(unsigned long);
 extern int shrink_mmap(int, int);
-extern void truncate_inode_pages(struct inode *, unsigned long);
+extern void truncate_inode_pages(struct inode *, loff_t);
 extern unsigned long get_cached_page(struct inode *, unsigned long, int);
 extern void put_cached_page(unsigned long);
 
@@ -350,7 +356,7 @@
 	    > (unsigned long) current->rlim[RLIMIT_AS].rlim_cur)
 		return -ENOMEM;
 	vma->vm_start = address;
-	vma->vm_offset -= grow;
+	vma->vm_index -= (grow >> PAGE_SHIFT);
 	vma->vm_mm->total_vm += grow >> PAGE_SHIFT;
 	if (vma->vm_flags & VM_LOCKED)
 		vma->vm_mm->locked_vm += grow >> PAGE_SHIFT;
@@ -385,6 +391,11 @@
 		vma = NULL;
 	return vma;
 }
+
+/* The old limit on mmap offsets */
+#define PAGE_MAX_MEMORY_OFFSET (-1UL)
+/* The maximum file size we can mmap to one inode */
+#define PAGE_MAX_FILE_OFFSET (((-1UL) * (1ULL << PAGE_SHIFT)) + (PAGE_SIZE -1))
 
 #endif /* __KERNEL__ */
 
diff -uNr linux-2.1.98/include/linux/pagemap.h linux-2.1.98.x1/include/linux/pagemap.h
--- linux-2.1.98/include/linux/pagemap.h	Sat Sep  6 12:50:21 1997
+++ linux-2.1.98.x1/include/linux/pagemap.h	Sat Apr 25 23:02:39 1998
@@ -31,10 +31,10 @@
  * inode pointer and offsets are distributed (ie, we
  * roughly know which bits are "significant")
  */
-static inline unsigned long _page_hashfn(struct inode * inode, unsigned long offset)
+static inline unsigned long _page_hashfn(struct inode * inode, unsigned long key)
 {
 #define i (((unsigned long) inode)/(sizeof(struct inode) & ~ (sizeof(struct inode) - 1)))
-#define o (offset >> PAGE_SHIFT)
+#define o (key)
 #define s(x) ((x)+((x)>>PAGE_HASH_BITS))
 	return s(i+o) & (PAGE_HASH_SIZE-1);
 #undef i
@@ -42,9 +42,9 @@
 #undef s
 }
 
-#define page_hash(inode,offset) (page_hash_table+_page_hashfn(inode,offset))
+#define page_hash(inode,key) (page_hash_table+_page_hashfn(inode,key))
 
-static inline struct page * __find_page(struct inode * inode, unsigned long offset, struct page *page)
+static inline struct page * __find_page(struct inode * inode, unsigned long key, struct page *page)
 {
 	goto inside;
 	for (;;) {
@@ -54,7 +54,7 @@
 			goto not_found;
 		if (page->inode != inode)
 			continue;
-		if (page->offset == offset)
+		if (page->key == key)
 			break;
 	}
 	/* Found the page. */
@@ -64,9 +64,9 @@
 	return page;
 }
 
-static inline struct page *find_page(struct inode * inode, unsigned long offset)
+static inline struct page *find_page(struct inode * inode, unsigned long key)
 {
-	return __find_page(inode, offset, *page_hash(inode, offset));
+	return __find_page(inode, key, *page_hash(inode, key));
 }
 
 static inline void remove_page_from_hash_queue(struct page * page)
@@ -91,9 +91,9 @@
 	page->pprev_hash = p;
 }
 
-static inline void add_page_to_hash_queue(struct page * page, struct inode * inode, unsigned long offset)
+static inline void add_page_to_hash_queue(struct page * page, struct inode * inode, unsigned long key)
 {
-	__add_page_to_hash_queue(page, page_hash(inode,offset));
+	__add_page_to_hash_queue(page, page_hash(inode,key));
 }
 
 static inline void remove_page_from_inode_queue(struct page * page)
@@ -131,6 +131,6 @@
 		__wait_on_page(page);
 }
 
-extern void update_vm_cache(struct inode *, unsigned long, const char *, int);
+extern void update_vm_cache(struct inode *, loff_t, const char *, int);
 
 #endif
diff -uNr linux-2.1.98/include/linux/swap.h linux-2.1.98.x1/include/linux/swap.h
--- linux-2.1.98/include/linux/swap.h	Wed Apr 22 11:08:16 1998
+++ linux-2.1.98.x1/include/linux/swap.h	Sat Apr 25 19:13:23 1998
@@ -101,7 +101,7 @@
 extern inline unsigned long in_swap_cache(struct page *page)
 {
 	if (PageSwapCache(page))
-		return page->offset;
+		return page->key;
 	return 0;
 }
 
diff -uNr linux-2.1.98/include/linux/wrapper.h linux-2.1.98.x1/include/linux/wrapper.h
--- linux-2.1.98/include/linux/wrapper.h	Tue Dec 16 12:39:55 1997
+++ linux-2.1.98.x1/include/linux/wrapper.h	Sat Apr 25 19:00:02 1998
@@ -28,7 +28,7 @@
 
 #define vma_set_inode(v,i) v->vm_inode = i
 #define vma_get_flags(v) v->vm_flags
-#define vma_get_offset(v) v->vm_offset
+/* #define vma_get_offset(v) v->vm_offset */
 #define vma_get_start(v) v->vm_start
 #define vma_get_end(v) v->vm_end
 #define vma_get_page_prot(v) v->vm_page_prot
diff -uNr linux-2.1.98/ipc/shm.c linux-2.1.98.x1/ipc/shm.c
--- linux-2.1.98/ipc/shm.c	Sat Apr  4 11:58:44 1998
+++ linux-2.1.98.x1/ipc/shm.c	Sat Apr 25 14:34:39 1998
@@ -386,7 +386,7 @@
  * shmd->vm_end		multiple of SHMLBA
  * shmd->vm_next	next attach for task
  * shmd->vm_next_share	next attach for segment
- * shmd->vm_offset	offset into segment
+ * shmd->vm_index	page index into segment
  * shmd->vm_pte		signature for this attach
  */
 
@@ -447,7 +447,7 @@
 	/* map page range */
 	error = 0;
 	shm_sgn = shmd->vm_pte +
-	  SWP_ENTRY(0, (shmd->vm_offset >> PAGE_SHIFT) << SHM_IDX_SHIFT);
+	  SWP_ENTRY(0, shmd->vm_index << SHM_IDX_SHIFT);
 	flush_cache_range(shmd->vm_mm, shmd->vm_start, shmd->vm_end);
 	for (tmp = shmd->vm_start;
 	     tmp < shmd->vm_end;
@@ -562,7 +562,7 @@
 			 | VM_MAYREAD | VM_MAYEXEC | VM_READ | VM_EXEC
 			 | ((shmflg & SHM_RDONLY) ? 0 : VM_MAYWRITE | VM_WRITE);
 	shmd->vm_file = NULL;
-	shmd->vm_offset = 0;
+	shmd->vm_index = 0;
 	shmd->vm_ops = &shm_vm_ops;
 
 	shp->shm_nattch++;            /* prevent destruction */
@@ -636,7 +636,7 @@
 	for (shmd = current->mm->mmap; shmd; shmd = shmdnext) {
 		shmdnext = shmd->vm_next;
 		if (shmd->vm_ops == &shm_vm_ops
-		    && shmd->vm_start - shmd->vm_offset == (ulong) shmaddr)
+		    && shmd->vm_start - (shmd->vm_index << PAGE_SHIFT) == (ulong) shmaddr)
 			do_munmap(shmd->vm_start, shmd->vm_end - shmd->vm_start);
 	}
 	unlock_kernel();
@@ -646,7 +646,7 @@
 /*
  * page not present ... go through shm_pages
  */
-static pte_t shm_swap_in(struct vm_area_struct * shmd, unsigned long offset, unsigned long code)
+static pte_t shm_swap_in(struct vm_area_struct * shmd, unsigned long index, unsigned long code)
 {
 	pte_t pte;
 	struct shmid_ds *shp;
@@ -668,9 +668,9 @@
 		return BAD_PAGE;
 	}
 	idx = (SWP_OFFSET(code) >> SHM_IDX_SHIFT) & SHM_IDX_MASK;
-	if (idx != (offset >> PAGE_SHIFT)) {
+	if (idx != index) {
 		printk ("shm_swap_in: code idx = %u and shmd idx = %lu differ\n",
-			idx, offset >> PAGE_SHIFT);
+			idx, index);
 		return BAD_PAGE;
 	}
 	if (idx >= shp->shm_npages) {
@@ -777,7 +777,7 @@
 				id, SWP_OFFSET(shmd->vm_pte) & SHM_ID_MASK);
 			continue;
 		}
-		tmp = shmd->vm_start + (idx << PAGE_SHIFT) - shmd->vm_offset;
+		tmp = shmd->vm_start + (idx - shmd->vm_index) << PAGE_SHIFT;
 		if (!(tmp >= shmd->vm_start && tmp < shmd->vm_end))
 			continue;
 		page_dir = pgd_offset(shmd->vm_mm,tmp);
diff -uNr linux-2.1.98/mm/filemap.c linux-2.1.98.x1/mm/filemap.c
--- linux-2.1.98/mm/filemap.c	Sat Apr  4 11:58:09 1998
+++ linux-2.1.98.x1/mm/filemap.c	Sat Apr 25 21:31:29 1998
@@ -80,18 +80,29 @@
  * Truncate the page cache at a set offset, removing the pages
  * that are beyond that offset (and zeroing out partial pages).
  */
-void truncate_inode_pages(struct inode * inode, unsigned long start)
+void truncate_inode_pages(struct inode * inode, loff_t start)
 {
 	struct page ** p;
 	struct page * page;
+	unsigned long last_keep;
+	unsigned long keep_bytes;
+
+	if (start > PAGE_MAX_FILE_OFFSET) {
+		return;
+	}
+	keep_bytes = start & PAGE_MASK;
+	last_keep = start >> PAGE_SHIFT;
+	if (!keep_bytes) {
+		last_keep--;
+	}
 
 repeat:
 	p = &inode->i_pages;
 	while ((page = *p) != NULL) {
-		unsigned long offset = page->offset;
+		unsigned long index = page->key;
 
 		/* page wholly truncated - free it */
-		if (offset >= start) {
+		if (index > last_keep) {
 			if (PageLocked(page)) {
 				wait_on_page(page);
 				goto repeat;
@@ -107,11 +118,10 @@
 			continue;
 		}
 		p = &page->next;
-		offset = start - offset;
 		/* partial truncate, clear end of page */
-		if (offset < PAGE_SIZE) {
+		if (index == last_keep) {
 			unsigned long address = page_address(page);
-			memset((void *) (offset + address), 0, PAGE_SIZE - offset);
+			memset((void *) (keep_bytes + address), 0, PAGE_SIZE - keep_bytes);
 			flush_page_to_ram(address);
 		}
 	}
@@ -237,19 +247,22 @@
  * Update a page cache copy, when we're doing a "write()" system call
  * See also "update_vm_cache()".
  */
-void update_vm_cache(struct inode * inode, unsigned long pos, const char * buf, int count)
+void update_vm_cache(struct inode * inode, loff_t pos, const char * buf, int count)
 {
-	unsigned long offset, len;
+	unsigned long offset, len, index;
 
+	if (pos > PAGE_MAX_FILE_OFFSET) {
+		return;
+	}
 	offset = (pos & ~PAGE_MASK);
-	pos = pos & PAGE_MASK;
+	index = pos >> PAGE_SHIFT;
 	len = PAGE_SIZE - offset;
 	do {
 		struct page * page;
 
 		if (len > count)
 			len = count;
-		page = find_page(inode, pos);
+		page = find_page(inode, index);
 		if (page) {
 			wait_on_page(page);
 			memcpy((void *) (offset + page_address(page)), buf, len);
@@ -259,17 +272,17 @@
 		buf += len;
 		len = PAGE_SIZE;
 		offset = 0;
-		pos += PAGE_SIZE;
-	} while (count);
+		index++;
+	} while (count && index);
 }
 
 static inline void add_to_page_cache(struct page * page,
-	struct inode * inode, unsigned long offset,
+	struct inode * inode, unsigned long key,
 	struct page **hash)
 {
 	atomic_inc(&page->count);
 	page->flags &= ~((1 << PG_uptodate) | (1 << PG_error));
-	page->offset = offset;
+	page->key = key;
 	add_page_to_inode_queue(inode, page);
 	__add_page_to_hash_queue(page, hash);
 }
@@ -280,13 +293,17 @@
  * this is all overlapped with the IO on the previous page finishing anyway)
  */
 static unsigned long try_to_read_ahead(struct file * file,
-				unsigned long offset, unsigned long page_cache)
+				       loff_t offset, unsigned long page_cache)
 {
+	unsigned long index;
 	struct inode *inode = file->f_dentry->d_inode;
 	struct page * page;
 	struct page ** hash;
 
-	offset &= PAGE_MASK;
+	if (offset > PAGE_MAX_FILE_OFFSET) {
+		return -EINVAL;
+	}
+	index = offset >> PAGE_SHIFT;
 	switch (page_cache) {
 	case 0:
 		page_cache = __get_free_page(GFP_KERNEL);
@@ -295,14 +312,14 @@
 	default:
 		if (offset >= inode->i_size)
 			break;
-		hash = page_hash(inode, offset);
-		page = __find_page(inode, offset, *hash);
+		hash = page_hash(inode, index);
+		page = __find_page(inode, index, *hash);
 		if (!page) {
 			/*
 			 * Ok, add the new page to the hash-queues...
 			 */
 			page = mem_map + MAP_NR(page_cache);
-			add_to_page_cache(page, inode, offset, hash);
+			add_to_page_cache(page, inode, index, hash);
 			inode->i_op->readpage(file, page);
 			page_cache = 0;
 		}
@@ -578,6 +595,7 @@
  * of the logic when it comes to error handling etc.
  */
 
+/* Need to 64 bit safe this!! */
 ssize_t generic_file_read(struct file * filp, char * buf,
 			  size_t count, loff_t *ppos)
 {
@@ -789,20 +807,22 @@
 	struct file * file = area->vm_file;
 	struct dentry * dentry = file->f_dentry;
 	struct inode * inode = dentry->d_inode;
-	unsigned long offset;
+	loff_t offset;
+	unsigned long index;
 	struct page * page, **hash;
 	unsigned long old_page, new_page;
 
 	new_page = 0;
-	offset = (address & PAGE_MASK) - area->vm_start + area->vm_offset;
+	offset = (address & PAGE_MASK) - area->vm_start + (area->vm_index << PAGE_SHIFT);
 	if (offset >= inode->i_size && (area->vm_flags & VM_SHARED) && area->vm_mm == current->mm)
 		goto no_page;
 
+	index = offset >> PAGE_SHIFT;
 	/*
 	 * Do we have something in the page cache already?
 	 */
-	hash = page_hash(inode, offset);
-	page = __find_page(inode, offset, *hash);
+	hash = page_hash(inode, index);
+	page = __find_page(inode, index, *hash);
 	if (!page)
 		goto no_cached_page;
 
@@ -860,7 +880,7 @@
 	 * cache.. The page we just got may be useful if we
 	 * can't share, so don't get rid of it here.
 	 */
-	page = find_page(inode, offset);
+	page = find_page(inode, index);
 	if (page)
 		goto found_page;
 
@@ -869,7 +889,7 @@
 	 */
 	page = mem_map + MAP_NR(new_page);
 	new_page = 0;
-	add_to_page_cache(page, inode, offset, hash);
+	add_to_page_cache(page, inode, index, hash);
 
 	if (inode->i_op->readpage(file, page) != 0)
 		goto failure;
@@ -918,23 +938,24 @@
  * if the disk is full.
  */
 static inline int do_write_page(struct inode * inode, struct file * file,
-	const char * page, unsigned long offset)
+	const char * page, unsigned long index)
 {
 	int retval;
 	unsigned long size;
-	loff_t loff = offset;
+	loff_t loff = ((loff_t)index) << PAGE_SHIFT;
 	mm_segment_t old_fs;
 
-	size = offset + PAGE_SIZE;
+	size = PAGE_SIZE;
 	/* refuse to extend file size.. */
 	if (S_ISREG(inode->i_mode)) {
-		if (size > inode->i_size)
-			size = inode->i_size;
+		if ((inode->i_size - loff) < PAGE_SIZE) {
+			size = inode->i_size - loff;
+		} 
 		/* Ho humm.. We should have tested for this earlier */
-		if (size < offset)
+		if ((inode->i_size - loff) <= 0) {
 			return -EIO;
+		}
 	}
-	size -= offset;
 	old_fs = get_fs();
 	set_fs(KERNEL_DS);
 	retval = -EIO;
@@ -945,7 +966,7 @@
 }
 
 static int filemap_write_page(struct vm_area_struct * vma,
-	unsigned long offset,
+	unsigned long index,
 	unsigned long page)
 {
 	int result;
@@ -981,7 +1002,7 @@
 	 */
 	file->f_count++;
 	down(&inode->i_sem);
-	result = do_write_page(inode, file, (const char *) page, offset);
+	result = do_write_page(inode, file, (const char *) page, index);
 	up(&inode->i_sem);
 	fput(file);
 	return result;
@@ -999,17 +1020,18 @@
  * up-to-date disk file.
  */
 int filemap_swapout(struct vm_area_struct * vma,
-	unsigned long offset,
+	unsigned long index,
 	pte_t *page_table)
 {
 	int error;
 	unsigned long page = pte_page(*page_table);
 	unsigned long entry = SWP_ENTRY(SHM_SWP_TYPE, MAP_NR(page));
+	unsigned long vm_address = vma->vm_start + ((index - vma->vm_index) << PAGE_SHIFT);
 
-	flush_cache_page(vma, (offset + vma->vm_start - vma->vm_offset));
+	flush_cache_page(vma, vm_address);
 	set_pte(page_table, __pte(entry));
-	flush_tlb_page(vma, (offset + vma->vm_start - vma->vm_offset));
-	error = filemap_write_page(vma, offset, page);
+	flush_tlb_page(vma, vm_address);
+	error = filemap_write_page(vma, index, page);
 	if (pte_val(*page_table) == entry)
 		pte_clear(page_table);
 	return error;
@@ -1022,7 +1044,7 @@
  * So we just use it directly..
  */
 static pte_t filemap_swapin(struct vm_area_struct * vma,
-	unsigned long offset,
+	unsigned long index,
 	unsigned long entry)
 {
 	unsigned long page = SWP_OFFSET(entry);
@@ -1038,6 +1060,7 @@
 {
 	pte_t pte = *ptep;
 	unsigned long page;
+	unsigned long index;
 	int error;
 
 	if (!(flags & MS_INVALIDATE)) {
@@ -1067,7 +1090,8 @@
 			return 0;
 		}
 	}
-	error = filemap_write_page(vma, address - vma->vm_start + vma->vm_offset, page);
+	index = ((address - vma->vm_start) >> PAGE_SHIFT) + vma->vm_index; 
+	error = filemap_write_page(vma, index, page);
 	free_page(page);
 	return error;
 }
@@ -1197,21 +1221,34 @@
 
 /* This is used for a general mmap of a disk file */
 
-int generic_file_mmap(struct file * file, struct vm_area_struct * vma)
+int generic_file_mmap(struct file * file, struct vm_area_struct * vma, 
+		      loff_t offset)
 {
 	struct vm_operations_struct * ops;
 	struct inode *inode = file->f_dentry->d_inode;
+	unsigned long index;
 
+	if (offset > PAGE_MAX_FILE_OFFSET) {
+		return -EINVAL;
+	}
+	if (offset & ~PAGE_MASK) {  /* temporarily break old a.out support */
+		return -EINVAL;
+	}
+	index = offset >> PAGE_SHIFT;
 	if ((vma->vm_flags & VM_SHARED) && (vma->vm_flags & VM_MAYWRITE)) {
 		ops = &file_shared_mmap;
 		/* share_page() can only guarantee proper page sharing if
 		 * the offsets are all page aligned. */
-		if (vma->vm_offset & (PAGE_SIZE - 1))
+#if 0
+		if (off & ~PAGE_MASK)
 			return -EINVAL;
+#endif
 	} else {
 		ops = &file_private_mmap;
-		if (vma->vm_offset & (inode->i_sb->s_blocksize - 1))
+#if 0
+		if (offset & (inode->i_sb->s_blocksize - 1))
 			return -EINVAL;
+#endif
 	}
 	if (!inode->i_sb || !S_ISREG(inode->i_mode))
 		return -EACCES;
diff -uNr linux-2.1.98/mm/memory.c linux-2.1.98.x1/mm/memory.c
--- linux-2.1.98/mm/memory.c	Fri Mar 20 17:15:52 1998
+++ linux-2.1.98.x1/mm/memory.c	Sat Apr 25 20:45:31 1998
@@ -719,13 +719,21 @@
  * between the file and the memory map for a potential last
  * incomplete page.  Ugly, but necessary.
  */
-void vmtruncate(struct inode * inode, unsigned long offset)
+void vmtruncate(struct inode * inode, loff_t offset)
 {
+	unsigned long index;
+	unsigned long partial;
 	struct vm_area_struct * mpnt;
 
 	truncate_inode_pages(inode, offset);
-	if (!inode->i_mmap)
+	if ((!inode->i_mmap) || (offset > PAGE_MAX_FILE_OFFSET)) {
 		return;
+	}
+	index = offset >> PAGE_SHIFT;
+	partial = offset & PAGE_MASK;
+	if (!partial) {
+		index--;
+	}
 	mpnt = inode->i_mmap;
 	do {
 		struct mm_struct *mm = mpnt->vm_mm;
@@ -735,14 +743,14 @@
 		unsigned long diff;
 
 		/* mapping wholly truncated? */
-		if (mpnt->vm_offset >= offset) {
+		if (mpnt->vm_index > index) {
 			flush_cache_range(mm, start, end);
 			zap_page_range(mm, start, len);
 			flush_tlb_range(mm, start, end);
 			continue;
 		}
 		/* mapping wholly unaffected? */
-		diff = offset - mpnt->vm_offset;
+		diff = ((index - mpnt->vm_index) << PAGE_SHIFT) + partial;
 		if (diff >= len)
 			continue;
 		/* Ok, partially affected.. */
@@ -764,13 +772,15 @@
 	pte_t * page_table, pte_t entry, int write_access)
 {
 	pte_t page;
+	unsigned long index;
 
 	if (!vma->vm_ops || !vma->vm_ops->swapin) {
 		swap_in(tsk, vma, page_table, pte_val(entry), write_access);
 		flush_page_to_ram(pte_page(*page_table));
 		return;
 	}
-	page = vma->vm_ops->swapin(vma, address - vma->vm_start + vma->vm_offset, pte_val(entry));
+	index = ((address - vma->vm_start) >> PAGE_SHIFT) + vma->vm_index;
+	page = vma->vm_ops->swapin(vma, index, pte_val(entry));
 	if (pte_val(*page_table) != pte_val(entry)) {
 		free_page(pte_page(page));
 		return;
diff -uNr linux-2.1.98/mm/mlock.c linux-2.1.98.x1/mm/mlock.c
--- linux-2.1.98/mm/mlock.c	Fri Mar 20 17:15:52 1998
+++ linux-2.1.98.x1/mm/mlock.c	Sat Apr 25 13:06:07 1998
@@ -36,7 +36,7 @@
 	*n = *vma;
 	vma->vm_start = end;
 	n->vm_end = end;
-	vma->vm_offset += vma->vm_start - n->vm_start;
+	vma->vm_index += (vma->vm_start - n->vm_start) >> PAGE_SHIFT;
 	n->vm_flags = newflags;
 	if (n->vm_file)
 		n->vm_file->f_count++;
@@ -57,7 +57,7 @@
 	*n = *vma;
 	vma->vm_end = start;
 	n->vm_start = start;
-	n->vm_offset += n->vm_start - vma->vm_start;
+	n->vm_index += (n->vm_start - vma->vm_start) >> PAGE_SHIFT;
 	n->vm_flags = newflags;
 	if (n->vm_file)
 		n->vm_file->f_count++;
@@ -86,8 +86,8 @@
 	vma->vm_start = start;
 	vma->vm_end = end;
 	right->vm_start = end;
-	vma->vm_offset += vma->vm_start - left->vm_start;
-	right->vm_offset += right->vm_start - left->vm_start;
+	vma->vm_index += (vma->vm_start - left->vm_start) >> PAGE_SHIFT;
+	right->vm_index += (right->vm_start - left->vm_start) >> PAGE_SHIFT;
 	vma->vm_flags = newflags;
 	if (vma->vm_file)
 		vma->vm_file->f_count += 2;
diff -uNr linux-2.1.98/mm/mmap.c linux-2.1.98.x1/mm/mmap.c
--- linux-2.1.98/mm/mmap.c	Fri Mar 20 17:15:52 1998
+++ linux-2.1.98.x1/mm/mmap.c	Sat Apr 25 13:00:23 1998
@@ -158,7 +158,7 @@
 }
 
 unsigned long do_mmap(struct file * file, unsigned long addr, unsigned long len,
-	unsigned long prot, unsigned long flags, unsigned long off)
+	unsigned long prot, unsigned long flags, loff_t off)
 {
 	struct mm_struct * mm = current->mm;
 	struct vm_area_struct * vma;
@@ -261,7 +261,7 @@
 		vma->vm_flags |= VM_MAYREAD | VM_MAYWRITE | VM_MAYEXEC;
 	vma->vm_page_prot = protection_map[vma->vm_flags & 0x0f];
 	vma->vm_ops = NULL;
-	vma->vm_offset = off;
+	vma->vm_index = 0;
 	vma->vm_file = NULL;
 	vma->vm_pte = 0;
 
@@ -297,7 +297,7 @@
 			}
 		}
 		if (!error)
-			error = file->f_op->mmap(file, vma);
+			error = file->f_op->mmap(file, vma, off);
 	
 	}
 	/* Fix up the count if necessary, then check for an error */
@@ -404,7 +404,7 @@
 	if (end == area->vm_end)
 		area->vm_end = addr;
 	else if (addr == area->vm_start) {
-		area->vm_offset += (end - area->vm_start);
+		area->vm_index += ((end - area->vm_start) >> PAGE_SHIFT);
 		area->vm_start = end;
 	} else {
 	/* Unmapping a hole: area->vm_start < addr <= end < area->vm_end */
@@ -418,7 +418,7 @@
 		mpnt->vm_page_prot = area->vm_page_prot;
 		mpnt->vm_flags = area->vm_flags;
 		mpnt->vm_ops = area->vm_ops;
-		mpnt->vm_offset = area->vm_offset + (end - area->vm_start);
+		mpnt->vm_index = area->vm_index + ((end - area->vm_start) >> PAGE_SHIFT);
 		mpnt->vm_file = area->vm_file;
 		if (mpnt->vm_file)
 			mpnt->vm_file->f_count++;
@@ -673,8 +673,9 @@
 		 * the offsets must be contiguous..
 		 */
 		if ((mpnt->vm_file != NULL) || (mpnt->vm_flags & VM_SHM)) {
-			unsigned long off = prev->vm_offset+prev->vm_end-prev->vm_start;
-			if (off != mpnt->vm_offset)
+			unsigned long off = prev->vm_index + 
+				((prev->vm_end - prev->vm_start) >> PAGE_SHIFT);
+			if (off != mpnt->vm_index)
 				continue;
 		}
 
@@ -688,7 +689,7 @@
 
 		prev->vm_end = mpnt->vm_end;
 		if (mpnt->vm_ops && mpnt->vm_ops->close) {
-			mpnt->vm_offset += mpnt->vm_end - mpnt->vm_start;
+			mpnt->vm_index += (mpnt->vm_end - mpnt->vm_start) >> PAGE_SHIFT;
 			mpnt->vm_start = mpnt->vm_end;
 			mpnt->vm_ops->close(mpnt);
 		}
diff -uNr linux-2.1.98/mm/mprotect.c linux-2.1.98.x1/mm/mprotect.c
--- linux-2.1.98/mm/mprotect.c	Sat Apr  4 11:58:09 1998
+++ linux-2.1.98.x1/mm/mprotect.c	Sat Apr 25 13:04:31 1998
@@ -107,7 +107,7 @@
 	*n = *vma;
 	vma->vm_start = end;
 	n->vm_end = end;
-	vma->vm_offset += vma->vm_start - n->vm_start;
+	vma->vm_index += (vma->vm_start - n->vm_start) >> PAGE_SHIFT;
 	n->vm_flags = newflags;
 	n->vm_page_prot = prot;
 	if (n->vm_file)
@@ -130,7 +130,7 @@
 	*n = *vma;
 	vma->vm_end = start;
 	n->vm_start = start;
-	n->vm_offset += n->vm_start - vma->vm_start;
+	n->vm_index += (n->vm_start - vma->vm_start) >> PAGE_SHIFT;
 	n->vm_flags = newflags;
 	n->vm_page_prot = prot;
 	if (n->vm_file)
@@ -161,8 +161,8 @@
 	vma->vm_start = start;
 	vma->vm_end = end;
 	right->vm_start = end;
-	vma->vm_offset += vma->vm_start - left->vm_start;
-	right->vm_offset += right->vm_start - left->vm_start;
+	vma->vm_index += (vma->vm_index - left->vm_start) >> PAGE_SHIFT;
+	right->vm_index += (right->vm_start - left->vm_start) >> PAGE_SHIFT;
 	vma->vm_flags = newflags;
 	vma->vm_page_prot = prot;
 	if (vma->vm_file)
diff -uNr linux-2.1.98/mm/mremap.c linux-2.1.98.x1/mm/mremap.c
--- linux-2.1.98/mm/mremap.c	Fri Mar 20 17:15:52 1998
+++ linux-2.1.98.x1/mm/mremap.c	Sat Apr 25 13:01:15 1998
@@ -139,7 +139,7 @@
 			*new_vma = *vma;
 			new_vma->vm_start = new_addr;
 			new_vma->vm_end = new_addr+new_len;
-			new_vma->vm_offset = vma->vm_offset + (addr - vma->vm_start);
+			new_vma->vm_index = vma->vm_index + ((addr - vma->vm_start) >> PAGE_SHIFT);
 			new_vma->vm_file = vma->vm_file;
 			if (new_vma->vm_file)
 				new_vma->vm_file->f_count++;
diff -uNr linux-2.1.98/mm/page_io.c linux-2.1.98.x1/mm/page_io.c
--- linux-2.1.98/mm/page_io.c	Wed Apr 22 11:08:16 1998
+++ linux-2.1.98.x1/mm/page_io.c	Wed Apr 22 11:47:09 1998
@@ -114,7 +114,7 @@
 		printk("VM: swap page is not in swap cache\n");
 		return;
 	}
-	if (page->offset != entry) {
+	if (page->key != entry) {
 		printk ("swap entry mismatch");
 		return;
 	}
@@ -234,7 +234,7 @@
 		return;
 	}
 	page->inode = &swapper_inode;
-	page->offset = entry;
+	page->key = entry;
 	atomic_inc(&page->count);	/* Protect from shrink_mmap() */
 	rw_swap_page(rw, entry, buffer, 1);
 	atomic_dec(&page->count);
diff -uNr linux-2.1.98/mm/swap_state.c linux-2.1.98.x1/mm/swap_state.c
--- linux-2.1.98/mm/swap_state.c	Fri Mar 20 17:16:30 1998
+++ linux-2.1.98.x1/mm/swap_state.c	Sat Apr 25 13:07:34 1998
@@ -65,7 +65,7 @@
 	if (PageTestandSetSwapCache(page)) {
 		printk("swap_cache: replacing non-empty entry %08lx "
 		       "on page %08lx\n",
-		       page->offset, page_address(page));
+		       page->key, page_address(page));
 		return 0;
 	}
 	if (page->inode) {
@@ -75,7 +75,7 @@
 	}
 	atomic_inc(&page->count);
 	page->inode = &swapper_inode;
-	page->offset = entry;
+	page->key = entry;
 	add_page_to_hash_queue(page, &swapper_inode, entry);
 	add_page_to_inode_queue(&swapper_inode, page);
 #ifdef SWAP_CACHE_INFO
@@ -172,7 +172,7 @@
 	swap_cache_find_total++;
 #endif
 	if (PageSwapCache (page))  {
-		long entry = page->offset;
+		long entry = page->key;
 #ifdef SWAP_CACHE_INFO
 		swap_cache_find_success++;
 #endif	
@@ -188,7 +188,7 @@
 	swap_cache_del_total++;
 #endif	
 	if (PageSwapCache (page))  {
-		long entry = page->offset;
+		long entry = page->key;
 #ifdef SWAP_CACHE_INFO
 		swap_cache_del_success++;
 #endif
diff -uNr linux-2.1.98/mm/vmscan.c linux-2.1.98.x1/mm/vmscan.c
--- linux-2.1.98/mm/vmscan.c	Sat Apr  4 11:58:09 1998
+++ linux-2.1.98.x1/mm/vmscan.c	Sat Apr 25 13:07:00 1998
@@ -133,9 +133,10 @@
 
 	if (pte_dirty(pte)) {
 		if (vma->vm_ops && vma->vm_ops->swapout) {
+			unsigned long index = ((address - vma->vm_start) >> PAGE_SHIFT) + vma->vm_index;
 			pid_t pid = tsk->pid;
 			vma->vm_mm->rss--;
-			if (vma->vm_ops->swapout(vma, address - vma->vm_start + vma->vm_offset, page_table))
+			if (vma->vm_ops->swapout(vma, index, page_table))
 				kill_proc(pid, SIGBUS, 1);
 		} else {
 			/*
@@ -145,7 +146,7 @@
 			 * page with that swap entry.
 			 */
 			if (PageSwapCache(page_map)) {
-				entry = page_map->offset;
+				entry = page_map->key;
 			} else {
 				entry = get_swap_page();
 				if (!entry)
