Received: from alogconduit1ah.ccr.net (root@alogconduit1ag.ccr.net [208.130.159.7])
	by kvack.org (8.8.7/8.8.7) with ESMTP id PAA12439
	for <linux-mm@kvack.org>; Sun, 23 May 1999 15:27:45 -0400
Subject: [PATCH] cache large files in the page cache
From: ebiederm+eric@ccr.net (Eric W. Biederman)
Date: 23 May 1999 14:28:14 -0500
Message-ID: <m17lpzsi0h.fsf@flinx.ccr.net>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Linus, 
   Since Ingo has been working on the page cache as well, I'm stopping
here.   Any changes up to this point are straight forward to resolve,
and this patch is the really challenging one to port from kernel to
kernel.

Allow large files in the page cache, by sqeezing out the extra bits.
This does not export any of this potential to user space,  that's
a different can of worms.

Details:

This patch replaces vm_offset with vm_index, with the relationship:
vm_offset == (vm_index << PAGE_SHIFT).  Except vm_index can hold larger
offsets.

This patch makes inode->i_size a loff_t, to allow very large files.
So in some places division and multiplcations with inode->i_size have been
replaced by shifts.

The inode operation mmap takes an additional argument of loff_t loff
and has to fill in vma->vm_index itself.  Combined with my vm_store
patch you have the ability to mmap absolutely enormous files, or
unaligned offsets if you need to.

page->offset has bee replaced with page->key. page->key is an arbitrary
value but for the generic code in filemap.c 
page->offset == page->key << PAGE_CACHE_SHIFT

I have defined PAGE_MAX_MEMORY_OFFSET & PAGE_MAX_FILE_OFFSET so I can
make some sanity checks that things aren't too huge.  This may be incomplete.

Added a do_ldiv  in lib/vsprintf.c  It's kind of a hack but it gets the 
job done for displaying long longs

Added checks in the stat routines to see if the values we are copying out are
too big.

Move PAGE_CACHE_SHIFT & co to asm-xxx/page.h, anywhere else and you can get
into awkward head include situations.

filemap.c could possibly be made to reduce the use of loff_t a little
more but that is tricky.  And note, anything that really requires
64bits to handle it, loff_t is more efficient than using double talk to get
around it.

Note: increasing PAGE_CACHE_SIZE really can't increase the amount you
can cache.  page->key is allows it but vma->vm_index can't so you can't
mmap it.  PAGE_CACHE_SIZE caught me off balance when it appeared
in 2.3.3

Eric

diff -uNrX /home/eric/projects/linux/linux-ignore-files linux-2.3.3.eb4/arch/alpha/kernel/ptrace.c linux-2.3.3.eb5/arch/alpha/kernel/ptrace.c
--- linux-2.3.3.eb4/arch/alpha/kernel/ptrace.c	Tue Feb  9 22:56:51 1999
+++ linux-2.3.3.eb5/arch/alpha/kernel/ptrace.c	Sat May 22 17:16:52 1999
@@ -261,7 +261,7 @@
 		return NULL;
 	if (vma->vm_end - addr > tsk->rlim[RLIMIT_STACK].rlim_cur)
 		return NULL;
-	vma->vm_offset -= vma->vm_start - addr;
+	vma->vm_index -= (vma->vm_start - addr) >> PAGE_SHIFT;
 	vma->vm_start = addr;
 	return vma;
 }
diff -uNrX /home/eric/projects/linux/linux-ignore-files linux-2.3.3.eb4/arch/arm/kernel/ptrace.c linux-2.3.3.eb5/arch/arm/kernel/ptrace.c
--- linux-2.3.3.eb4/arch/arm/kernel/ptrace.c	Sun Oct 11 13:16:22 1998
+++ linux-2.3.3.eb5/arch/arm/kernel/ptrace.c	Sat May 22 17:16:52 1999
@@ -178,7 +178,7 @@
 		return NULL;
 	if (vma->vm_end - addr > tsk->rlim[RLIMIT_STACK].rlim_cur)
 		return NULL;
-	vma->vm_offset -= vma->vm_start - addr;
+	vma->vm_index -= (vma->vm_start - addr) >> PAGE_SHIFT;
 	vma->vm_start = addr;
 	return vma;
 }
diff -uNrX /home/eric/projects/linux/linux-ignore-files linux-2.3.3.eb4/arch/i386/kernel/ptrace.c linux-2.3.3.eb5/arch/i386/kernel/ptrace.c
--- linux-2.3.3.eb4/arch/i386/kernel/ptrace.c	Mon Apr  5 20:40:46 1999
+++ linux-2.3.3.eb5/arch/i386/kernel/ptrace.c	Sat May 22 17:16:52 1999
@@ -186,7 +186,7 @@
 		return NULL;
 	if (vma->vm_end - addr > tsk->rlim[RLIMIT_STACK].rlim_cur)
 		return NULL;
-	vma->vm_offset -= vma->vm_start - addr;
+	vma->vm_index -= (vma->vm_start - addr) >> PAGE_SHIFT;
 	vma->vm_start = addr;
 	return vma;
 }
diff -uNrX /home/eric/projects/linux/linux-ignore-files linux-2.3.3.eb4/arch/m68k/kernel/ptrace.c linux-2.3.3.eb5/arch/m68k/kernel/ptrace.c
--- linux-2.3.3.eb4/arch/m68k/kernel/ptrace.c	Sun May 16 21:54:59 1999
+++ linux-2.3.3.eb5/arch/m68k/kernel/ptrace.c	Sat May 22 17:16:52 1999
@@ -210,7 +210,7 @@
 		return NULL;
 	if (vma->vm_end - addr > tsk->rlim[RLIMIT_STACK].rlim_cur)
 		return NULL;
-	vma->vm_offset -= vma->vm_start - addr;
+	vma->vm_index -= (vma->vm_start - addr) >> PAGE_SHIFT;
 	vma->vm_start = addr;
 	return vma;
 }
diff -uNrX /home/eric/projects/linux/linux-ignore-files linux-2.3.3.eb4/arch/mips/kernel/ptrace.c linux-2.3.3.eb5/arch/mips/kernel/ptrace.c
--- linux-2.3.3.eb4/arch/mips/kernel/ptrace.c	Tue Feb  9 22:50:18 1999
+++ linux-2.3.3.eb5/arch/mips/kernel/ptrace.c	Sat May 22 17:16:52 1999
@@ -157,7 +157,7 @@
 		return NULL;
 	if (vma->vm_end - addr > tsk->rlim[RLIMIT_STACK].rlim_cur)
 		return NULL;
-	vma->vm_offset -= vma->vm_start - addr;
+	vma->vm_index -= (vma->vm_start - addr) >> PAGE_SHIFT;
 	vma->vm_start = addr;
 	return vma;
 }
diff -uNrX /home/eric/projects/linux/linux-ignore-files linux-2.3.3.eb4/arch/ppc/kernel/ptrace.c linux-2.3.3.eb5/arch/ppc/kernel/ptrace.c
--- linux-2.3.3.eb4/arch/ppc/kernel/ptrace.c	Sun May 16 21:55:03 1999
+++ linux-2.3.3.eb5/arch/ppc/kernel/ptrace.c	Sat May 22 17:16:52 1999
@@ -204,7 +204,7 @@
 		return NULL;
 	if (vma->vm_end - addr > tsk->rlim[RLIMIT_STACK].rlim_cur)
 		return NULL;
-	vma->vm_offset -= vma->vm_start - addr;
+	vma->vm_index -= (vma->vm_start - addr) >> PAGE_SHIFT;
 	vma->vm_start = addr;
 	return vma;
 }
diff -uNrX /home/eric/projects/linux/linux-ignore-files linux-2.3.3.eb4/arch/sparc/kernel/ptrace.c linux-2.3.3.eb5/arch/sparc/kernel/ptrace.c
--- linux-2.3.3.eb4/arch/sparc/kernel/ptrace.c	Mon Apr  5 20:40:46 1999
+++ linux-2.3.3.eb5/arch/sparc/kernel/ptrace.c	Sat May 22 17:16:52 1999
@@ -149,7 +149,7 @@
 		return NULL;
 	if (vma->vm_end - addr > tsk->rlim[RLIMIT_STACK].rlim_cur)
 		return NULL;
-	vma->vm_offset -= vma->vm_start - addr;
+	vma->vm_index -= (vma->vm_start - addr) >> PAGE_SHIFT;
 	vma->vm_start = addr;
 	return vma;
 }
diff -uNrX /home/eric/projects/linux/linux-ignore-files linux-2.3.3.eb4/arch/sparc64/kernel/ptrace.c linux-2.3.3.eb5/arch/sparc64/kernel/ptrace.c
--- linux-2.3.3.eb4/arch/sparc64/kernel/ptrace.c	Mon Apr  5 20:40:47 1999
+++ linux-2.3.3.eb5/arch/sparc64/kernel/ptrace.c	Sat May 22 17:16:53 1999
@@ -219,7 +219,7 @@
 		return NULL;
 	if (vma->vm_end - addr > tsk->rlim[RLIMIT_STACK].rlim_cur)
 		return NULL;
-	vma->vm_offset -= vma->vm_start - addr;
+	vma->vm_index -= (vma->vm_start - addr) >> PAGE_SHIFT;
 	vma->vm_start = addr;
 	return vma;
 }
diff -uNrX /home/eric/projects/linux/linux-ignore-files linux-2.3.3.eb4/drivers/block/loop.c linux-2.3.3.eb5/drivers/block/loop.c
--- linux-2.3.3.eb4/drivers/block/loop.c	Tue Feb  9 22:59:25 1999
+++ linux-2.3.3.eb5/drivers/block/loop.c	Sat May 22 17:16:32 1999
@@ -137,12 +137,12 @@
 	int	size;
 
 	if (S_ISREG(lo->lo_dentry->d_inode->i_mode))
-		size = (lo->lo_dentry->d_inode->i_size - lo->lo_offset) / BLOCK_SIZE;
+		size = (lo->lo_dentry->d_inode->i_size - lo->lo_offset) >> BLOCK_SIZE_BITS;
 	else {
 		kdev_t lodev = lo->lo_device;
 		if (blk_size[MAJOR(lodev)])
 			size = blk_size[MAJOR(lodev)][MINOR(lodev)] -
-                                lo->lo_offset / BLOCK_SIZE;
+                                (lo->lo_offset >> BLOCK_SIZE_BITS);
 		else
 			size = MAX_DISK_SIZE;
 	}
diff -uNrX /home/eric/projects/linux/linux-ignore-files linux-2.3.3.eb4/drivers/char/ftape/lowlevel/ftape-ctl.c linux-2.3.3.eb5/drivers/char/ftape/lowlevel/ftape-ctl.c
--- linux-2.3.3.eb4/drivers/char/ftape/lowlevel/ftape-ctl.c	Fri Mar 20 17:12:03 1998
+++ linux-2.3.3.eb5/drivers/char/ftape/lowlevel/ftape-ctl.c	Sat May 22 17:16:33 1999
@@ -704,9 +704,11 @@
 	if ((vma_get_flags(vma) & (VM_READ|VM_WRITE)) == 0) {
 		TRACE_ABORT(-EINVAL, ft_t_err, "Undefined mmap() access");
 	}
+#if 0
 	if (vma_get_offset (vma) != 0) {
 		TRACE_ABORT(-EINVAL, ft_t_err, "offset must be 0");
 	}
+#endif
 	if ((vma_get_end (vma) - vma_get_start (vma)) % FT_BUFF_SIZE != 0) {
 		TRACE_ABORT(-EINVAL, ft_t_err,
 			    "size = %ld, should be a multiple of %d",
diff -uNrX /home/eric/projects/linux/linux-ignore-files linux-2.3.3.eb4/drivers/char/mem.c linux-2.3.3.eb5/drivers/char/mem.c
--- linux-2.3.3.eb4/drivers/char/mem.c	Sat May 22 16:10:09 1999
+++ linux-2.3.3.eb5/drivers/char/mem.c	Sat May 22 17:16:53 1999
@@ -183,10 +183,17 @@
 #endif
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
+	if ((offset + (vma->vm_end - vma->vm_start)) > PAGE_MAX_MEMORY_OFFSET) {
+		return -EINVAL;
+	}
+	vma->vm_index = offset >> PAGE_SHIFT;
 	if (offset & ~PAGE_MASK)
 		return -ENXIO;
 
@@ -410,7 +417,7 @@
 	return written ? written : -EFAULT;
 }
 
-static int mmap_zero(struct file * file, struct vm_area_struct * vma)
+static int mmap_zero(struct file * file, struct vm_area_struct * vma, loff_t offset)
 {
 	if (vma->vm_flags & VM_SHARED)
 		return -EINVAL;
diff -uNrX /home/eric/projects/linux/linux-ignore-files linux-2.3.3.eb4/drivers/sgi/char/graphics.c linux-2.3.3.eb5/drivers/sgi/char/graphics.c
--- linux-2.3.3.eb4/drivers/sgi/char/graphics.c	Sun Oct 11 13:15:06 1998
+++ linux-2.3.3.eb5/drivers/sgi/char/graphics.c	Sat May 22 17:16:53 1999
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
@@ -252,7 +260,8 @@
 	vma->vm_page_prot = PAGE_USERIO;
 		
 	/* final setup */
-	vma->vm_dentry = dget (file->f_dentry);
+	vma->vm_file = file;
+	file->f_count++;
 	return 0;
 }
 	
diff -uNrX /home/eric/projects/linux/linux-ignore-files linux-2.3.3.eb4/drivers/sound/soundcard.c linux-2.3.3.eb5/drivers/sound/soundcard.c
--- linux-2.3.3.eb4/drivers/sound/soundcard.c	Mon Apr  5 20:38:31 1999
+++ linux-2.3.3.eb5/drivers/sound/soundcard.c	Sat May 22 17:16:33 1999
@@ -699,7 +699,7 @@
 	return 0;
 }
 
-static int sound_mmap(struct file *file, struct vm_area_struct *vma)
+static int sound_mmap(struct file *file, struct vm_area_struct *vma, loff_t offset)
 {
 	int dev_class;
 	unsigned long size;
@@ -739,7 +739,7 @@
 /*		printk("Sound: mmap() called twice for the same DMA buffer\n");*/
 		return -EIO;
 	}
-	if (vma->vm_offset != 0)
+	if (offset != 0)
 	{
 /*		printk("Sound: mmap() offset must be 0.\n");*/
 		return -EINVAL;
diff -uNrX /home/eric/projects/linux/linux-ignore-files linux-2.3.3.eb4/fs/adfs/inode.c linux-2.3.3.eb5/fs/adfs/inode.c
--- linux-2.3.3.eb4/fs/adfs/inode.c	Mon Apr  5 20:40:53 1999
+++ linux-2.3.3.eb5/fs/adfs/inode.c	Sat May 22 17:16:33 1999
@@ -180,8 +180,8 @@
 		inode->i_mode	 = S_IRWXUGO | S_IFDIR;
 		inode->i_nlink	 = 2;
 		inode->i_size	 = ADFS_NEWDIR_SIZE;
-		inode->i_blksize = PAGE_SIZE;
-		inode->i_blocks  = inode->i_size / sb->s_blocksize;
+		inode->i_blksize = PAGE_CACHE_SIZE;
+		inode->i_blocks  = inode->i_size >> sb->s_blocksize_bits;
 		inode->i_mtime   =
 		inode->i_atime   =
 		inode->i_ctime   = 0;
@@ -203,7 +203,7 @@
 		inode->i_mode	 = adfs_atts2mode(sb, ide.mode, ide.filetype);
 		inode->i_nlink	 = 2;
 		inode->i_size    = ide.size;
-		inode->i_blksize = PAGE_SIZE;
+		inode->i_blksize = PAGE_CACHE_SIZE;
 		inode->i_blocks	 = (inode->i_size + sb->s_blocksize - 1) >> sb->s_blocksize_bits;
 		inode->i_mtime	 =
 		inode->i_atime   =
diff -uNrX /home/eric/projects/linux/linux-ignore-files linux-2.3.3.eb4/fs/affs/file.c linux-2.3.3.eb5/fs/affs/file.c
--- linux-2.3.3.eb4/fs/affs/file.c	Sun Oct 11 13:15:09 1998
+++ linux-2.3.3.eb5/fs/affs/file.c	Sat May 22 17:16:33 1999
@@ -618,7 +618,7 @@
 				written = -ENOSPC;
 			break;
 		}
-		c = blocksize - (pos % blocksize);
+		c = blocksize - (pos & (blocksize -1));
 		if (c > count - written)
 			c = count - written;
 		if (c != blocksize && !buffer_uptodate(bh)) {
@@ -631,7 +631,7 @@
 				break;
 			}
 		}
-		p  = (pos % blocksize) + bh->b_data;
+		p  = (pos & (blocksize -1)) + bh->b_data;
 		c -= copy_from_user(p,buf,c);
 		if (!c) {
 			affs_brelse(bh);
@@ -698,7 +698,7 @@
 				written = -ENOSPC;
 			break;
 		}
-		c = blocksize - (pos % blocksize);
+		c = blocksize - (pos & (blocksize -1));
 		if (c > count - written)
 			c = count - written;
 		if (c != blocksize && !buffer_uptodate(bh)) {
@@ -711,7 +711,7 @@
 				break;
 			}
 		}
-		p  = (pos % blocksize) + bh->b_data + 24;
+		p  = (pos & (blocksize -1)) + bh->b_data + 24;
 		c -= copy_from_user(p,buf,c);
 		if (!c) {
 			affs_brelse(bh);
@@ -780,10 +780,10 @@
 	int	 rem;
 	int	 ext;
 
-	pr_debug("AFFS: truncate(inode=%ld,size=%lu)\n",inode->i_ino,inode->i_size);
+	pr_debug("AFFS: truncate(inode=%ld,size=%lu)\n",inode->i_ino,(unsigned long)inode->i_size);
 
 	net_blocksize = blocksize - ((inode->i_sb->u.affs_sb.s_flags & SF_OFS) ? 24 : 0);
-	first = (inode->i_size + net_blocksize - 1) / net_blocksize;
+	first = (unsigned long)(inode->i_size + net_blocksize - 1) / net_blocksize;
 	if (inode->u.affs_i.i_lastblock < first - 1) {
 		/* There has to be at least one new block to be allocated */
 		if (!inode->u.affs_i.i_ec && alloc_ext_cache(inode)) {
@@ -795,7 +795,7 @@
 			affs_warning(inode->i_sb,"truncate","Cannot extend file");
 			inode->i_size = net_blocksize * (inode->u.affs_i.i_lastblock + 1);
 		} else if (inode->i_sb->u.affs_sb.s_flags & SF_OFS) {
-			rem = inode->i_size % net_blocksize;
+			rem = ((unsigned long)inode->i_size) & (net_blocksize -1);
 			DATA_FRONT(bh)->data_size = cpu_to_be32(rem ? rem : net_blocksize);
 			affs_fix_checksum(blocksize,bh->b_data,5);
 			mark_buffer_dirty(bh,0);
@@ -862,7 +862,7 @@
 			affs_free_block(inode->i_sb,ekey);
 		ekey = key;
 	}
-	block = ((inode->i_size + net_blocksize - 1) / net_blocksize) - 1;
+	block = (((unsigned long)inode->i_size + net_blocksize - 1) / net_blocksize) - 1;
 	inode->u.affs_i.i_lastblock = block;
 
 	/* If the file is not truncated to a block boundary,
@@ -870,7 +870,7 @@
 	 * so it cannot become accessible again.
 	 */
 
-	rem = inode->i_size % net_blocksize;
+	rem = inode->i_size & (net_blocksize -1);
 	if (rem) {
 		if ((inode->i_sb->u.affs_sb.s_flags & SF_OFS)) 
 			rem += 24;
diff -uNrX /home/eric/projects/linux/linux-ignore-files linux-2.3.3.eb4/fs/affs/inode.c linux-2.3.3.eb5/fs/affs/inode.c
--- linux-2.3.3.eb4/fs/affs/inode.c	Mon Apr  5 20:38:36 1999
+++ linux-2.3.3.eb5/fs/affs/inode.c	Sat May 22 17:16:33 1999
@@ -146,7 +146,7 @@
 				block = AFFS_I2BSIZE(inode) - 24;
 			else
 				block = AFFS_I2BSIZE(inode);
-			inode->u.affs_i.i_lastblock = ((inode->i_size + block - 1) / block) - 1;
+			inode->u.affs_i.i_lastblock = (((unsigned long)inode->i_size + block - 1) / block) - 1;
 			break;
 		case ST_SOFTLINK:
 			inode->i_mode |= S_IFLNK;
diff -uNrX /home/eric/projects/linux/linux-ignore-files linux-2.3.3.eb4/fs/buffer.c linux-2.3.3.eb5/fs/buffer.c
--- linux-2.3.3.eb4/fs/buffer.c	Sat May 22 17:09:22 1999
+++ linux-2.3.3.eb5/fs/buffer.c	Sat May 22 17:16:33 1999
@@ -1115,7 +1115,7 @@
 #endif
 	}
 	if (test_and_clear_bit(PG_swap_unlock_after, &page->flags))
-		swap_after_unlock_page(page->offset);
+		swap_after_unlock_page(page->key);
 	if (test_and_clear_bit(PG_free_after, &page->flags))
 		__free_page(page);
 }
@@ -1338,8 +1338,8 @@
 	set_bit(PG_locked, &page->flags);
 	set_bit(PG_free_after, &page->flags);
 	
-	i = PAGE_SIZE >> inode->i_sb->s_blocksize_bits;
-	block = page->offset >> inode->i_sb->s_blocksize_bits;
+	i = PAGE_CACHE_SIZE >> inode->i_sb->s_blocksize_bits;
+	block = page->key << (PAGE_CACHE_SHIFT - inode->i_sb->s_blocksize_bits);
 	p = nr;
 	do {
 		*p = inode->i_op->bmap(inode, block);
diff -uNrX /home/eric/projects/linux/linux-ignore-files linux-2.3.3.eb4/fs/coda/file.c linux-2.3.3.eb5/fs/coda/file.c
--- linux-2.3.3.eb4/fs/coda/file.c	Sun Oct 11 13:15:50 1998
+++ linux-2.3.3.eb5/fs/coda/file.c	Sat May 22 17:16:33 1999
@@ -98,8 +98,8 @@
         coda_prepare_openfile(coda_inode, coda_file, cii->c_ovp,
 			      &cont_file, &cont_dentry);
 
-        CDEBUG(D_INODE, "coda ino: %ld, cached ino %ld, page offset: %lx\n", 
-	       coda_inode->i_ino, cii->c_ovp->i_ino, page->offset);
+        CDEBUG(D_INODE, "coda ino: %ld, cached ino %ld, page key: %lx\n", 
+	       coda_inode->i_ino, cii->c_ovp->i_ino, page->key);
 
         generic_readpage(&cont_file, page);
         EXIT;
diff -uNrX /home/eric/projects/linux/linux-ignore-files linux-2.3.3.eb4/fs/exec.c linux-2.3.3.eb5/fs/exec.c
--- linux-2.3.3.eb4/fs/exec.c	Sun May 16 21:55:19 1999
+++ linux-2.3.3.eb5/fs/exec.c	Sat May 22 17:16:53 1999
@@ -314,7 +314,7 @@
 		mpnt->vm_page_prot = PAGE_COPY;
 		mpnt->vm_flags = VM_STACK_FLAGS;
 		mpnt->vm_ops = NULL;
-		mpnt->vm_offset = 0;
+		mpnt->vm_index = 0;
 		mpnt->vm_file = NULL;
 		mpnt->vm_pte = 0;
 		insert_vm_struct(current->mm, mpnt);
diff -uNrX /home/eric/projects/linux/linux-ignore-files linux-2.3.3.eb4/fs/ext2/inode.c linux-2.3.3.eb5/fs/ext2/inode.c
--- linux-2.3.3.eb4/fs/ext2/inode.c	Sat May 22 16:09:56 1999
+++ linux-2.3.3.eb5/fs/ext2/inode.c	Sat May 22 17:16:34 1999
@@ -538,7 +538,7 @@
 	inode->i_ctime = le32_to_cpu(raw_inode->i_ctime);
 	inode->i_mtime = le32_to_cpu(raw_inode->i_mtime);
 	inode->u.ext2_i.i_dtime = le32_to_cpu(raw_inode->i_dtime);
-	inode->i_blksize = PAGE_SIZE;	/* This is the optimal IO size (for stat), not the fs block size */
+	inode->i_blksize = PAGE_CACHE_SIZE;	/* This is the optimal IO size (for stat), not the fs block size */
 	inode->i_blocks = le32_to_cpu(raw_inode->i_blocks);
 	inode->i_version = ++event;
 	inode->u.ext2_i.i_new_inode = 0;
diff -uNrX /home/eric/projects/linux/linux-ignore-files linux-2.3.3.eb4/fs/ext2/truncate.c linux-2.3.3.eb5/fs/ext2/truncate.c
--- linux-2.3.3.eb4/fs/ext2/truncate.c	Sat May 22 16:10:24 1999
+++ linux-2.3.3.eb5/fs/ext2/truncate.c	Sat May 22 17:16:34 1999
@@ -54,8 +54,8 @@
  * there's no need to test for changes during the operation.
  */
 #define DIRECT_BLOCK(inode) \
-	((inode->i_size + inode->i_sb->s_blocksize - 1) / \
-			  inode->i_sb->s_blocksize)
+	((inode->i_size + inode->i_sb->s_blocksize - 1) >> \
+			  inode->i_sb->s_blocksize_bits)
 #define INDIRECT_BLOCK(inode,offset) ((int)DIRECT_BLOCK(inode) - offset)
 #define DINDIRECT_BLOCK(inode,offset) \
 	(INDIRECT_BLOCK(inode,offset) / addr_per_block)
diff -uNrX /home/eric/projects/linux/linux-ignore-files linux-2.3.3.eb4/fs/fat/mmap.c linux-2.3.3.eb5/fs/fat/mmap.c
--- linux-2.3.3.eb4/fs/fat/mmap.c	Mon Apr  5 20:38:37 1999
+++ linux-2.3.3.eb5/fs/fat/mmap.c	Sat May 22 17:16:53 1999
@@ -42,7 +42,7 @@
 	if (!page)
 		return page;
 	address &= PAGE_MASK;
-	pos = address - area->vm_start + area->vm_offset;
+	pos = (address - area->vm_start) + (area->vm_index << PAGE_SHIFT);
 
 	clear = 0;
 	gap = inode->i_size - pos;
@@ -95,16 +95,22 @@
  * This is used for a general mmap of an msdos file
  * Returns 0 if ok, or a negative error code if not.
  */
-int fat_mmap(struct file * file, struct vm_area_struct * vma)
+int fat_mmap(struct file * file, struct vm_area_struct * vma, loff_t loffset)
 {
 	struct inode *inode = file->f_dentry->d_inode;
+	unsigned long offset;
+	/* fat is strictly a 32 bit filesystem */
+	if ((loffset > ((u32) -1)) || ((loffset + (vma->vm_end - vma->vm_start)) > ((u32) -1))) {
+		return -EINVAL;
+	}
+	offset = loffset;
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
@@ -112,6 +118,8 @@
 		inode->i_atime = CURRENT_TIME;
 		mark_inode_dirty(inode);
 	}
+
+	vma->vm_index = offset >> PAGE_SHIFT;
 
 	vma->vm_ops = &fat_file_mmap;
 	return 0;
diff -uNrX /home/eric/projects/linux/linux-ignore-files linux-2.3.3.eb4/fs/isofs/inode.c linux-2.3.3.eb5/fs/isofs/inode.c
--- linux-2.3.3.eb4/fs/isofs/inode.c	Sat May 22 16:09:57 1999
+++ linux-2.3.3.eb5/fs/isofs/inode.c	Sat May 22 17:16:34 1999
@@ -912,7 +912,7 @@
 	    if( b_off >= max_legal_read_offset )
 	      {
 
-		printk("_isofs_bmap: block>= EOF(%d, %ld)\n", block,
+		printk("_isofs_bmap: block>= EOF(%d, %Ld)\n", block,
 		       inode->i_size);
 	      }
 	    return 0;
@@ -1152,7 +1152,7 @@
 #endif
 
 #ifdef DEBUG
-	printk("Get inode %x: %d %d: %d\n",inode->i_ino, block,
+	printk("Get inode %x: %d %d: %Ld\n",inode->i_ino, block,
 	       ((int)pnt) & 0x3ff, inode->i_size);
 #endif
 
diff -uNrX /home/eric/projects/linux/linux-ignore-files linux-2.3.3.eb4/fs/ncpfs/mmap.c linux-2.3.3.eb5/fs/ncpfs/mmap.c
--- linux-2.3.3.eb4/fs/ncpfs/mmap.c	Sat May 22 16:10:12 1999
+++ linux-2.3.3.eb5/fs/ncpfs/mmap.c	Sat May 22 17:16:53 1999
@@ -46,10 +46,10 @@
 	if (!page)
 		return page;
 	address &= PAGE_MASK;
-	pos = address - area->vm_start + area->vm_offset;
+	pos = (address - area->vm_start) + (area->vm_index << PAGE_SHFT);
 
-	count = PAGE_SIZE;
-	if (address + PAGE_SIZE > area->vm_end) {
+	count = PAGE_CACHE_SIZE;
+	if (address + PAGE_CACHE_SIZE > area->vm_end) {
 		count = area->vm_end - address;
 	}
 	/* what we can read in one go */
@@ -82,9 +82,9 @@
 
 	}
 
-	if (already_read < PAGE_SIZE)
+	if (already_read < PAGE_CACHE_SIZE)
 		memset((char*)(page + already_read), 0, 
-		       PAGE_SIZE - already_read);
+		       PAGE_CACHE_SIZE - already_read);
 	return page;
 }
 
@@ -104,15 +104,28 @@
 
 
 /* This is used for a general mmap of a ncp file */
-int ncp_mmap(struct file *file, struct vm_area_struct *vma)
+int ncp_mmap(struct file *file, struct vm_area_struct *vma, loff_t loffset)
 {
 	struct inode *inode = file->f_dentry->d_inode;
+	unsigned long offset;
+	
+	/* ncp is stricty a 32 bit filesystem */
+	if ((loffset > ((u32) -1)) || ((loffset + (vma->vm_end - vma->vm_start)) > ((u32) -1))) {
+		return -EINVAL;
+	}
+	offset = loffset;
 	
 	DPRINTK(KERN_DEBUG "ncp_mmap: called\n");
 
 	if (!ncp_conn_valid(NCP_SERVER(inode))) {
 		return -EIO;
 	}
+	if (offset > PAGE_MAX_MEMORY_OFFSET) {
+		return -EINVAL;
+	}
+	if (offset & ~PAGE_MASK) {
+		return -EINVAL;
+	}
 	/* only PAGE_COW or read-only supported now */
 	if (vma->vm_flags & VM_SHARED)
 		return -EINVAL;
@@ -122,6 +135,7 @@
 		inode->i_atime = CURRENT_TIME;
 	}
 
+	vma->vm_index = offset >> PAGE_SHIFT;
 	vma->vm_ops = &ncp_file_mmap;
 	return 0;
 }
diff -uNrX /home/eric/projects/linux/linux-ignore-files linux-2.3.3.eb4/fs/nfs/read.c linux-2.3.3.eb5/fs/nfs/read.c
--- linux-2.3.3.eb4/fs/nfs/read.c	Tue Feb  9 22:55:42 1999
+++ linux-2.3.3.eb5/fs/nfs/read.c	Sat May 22 17:16:35 1999
@@ -69,11 +69,11 @@
 nfs_readpage_sync(struct dentry *dentry, struct inode *inode, struct page *page)
 {
 	struct nfs_rreq	rqst;
-	unsigned long	offset = page->offset;
+	unsigned long	offset = page->key << PAGE_CACHE_SHIFT;
 	char		*buffer = (char *) page_address(page);
 	int		rsize = NFS_SERVER(inode)->rsize;
 	int		result, refresh = 0;
-	int		count = PAGE_SIZE;
+	int		count = PAGE_CACHE_SIZE;
 	int		flags = IS_SWAPFILE(inode)? NFS_RPC_SWAPFLAGS : 0;
 
 	dprintk("NFS: nfs_readpage_sync(%p)\n", page);
@@ -142,8 +142,8 @@
 
 	if (result >= 0) {
 		result = req->ra_res.count;
-		if (result < PAGE_SIZE) {
-			memset((char *) address + result, 0, PAGE_SIZE - result);
+		if (result < PAGE_CACHE_SIZE) {
+			memset((char *) address + result, 0, PAGE_CACHE_SIZE - result);
 		}
 		nfs_refresh_inode(req->ra_inode, &req->ra_fattr);
 		set_bit(PG_uptodate, &page->flags);
@@ -183,8 +183,8 @@
 
 	/* Initialize request */
 	/* N.B. Will the dentry remain valid for life of request? */
-	nfs_readreq_setup(req, NFS_FH(dentry), page->offset,
-				(void *) address, PAGE_SIZE);
+	nfs_readreq_setup(req, NFS_FH(dentry), page->key << PAGE_CACHE_SHIFT,
+				(void *) address, PAGE_CACHE_SIZE);
 	req->ra_inode = inode;
 	req->ra_page = page; /* count has been incremented by caller */
 
@@ -228,7 +228,7 @@
 	int		error;
 
 	dprintk("NFS: nfs_readpage (%p %ld@%ld)\n",
-		page, PAGE_SIZE, page->offset);
+		page, PAGE_CACHE_SIZE, page->key << PAGE_CACHE_SHIFT);
 	atomic_inc(&page->count);
 	set_bit(PG_locked, &page->flags);
 
@@ -245,7 +245,7 @@
 
 	error = -1;
 	if (!IS_SWAPFILE(inode) && !PageError(page) &&
-	    NFS_SERVER(inode)->rsize >= PAGE_SIZE)
+	    NFS_SERVER(inode)->rsize >= PAGE_CACHE_SIZE)
 		error = nfs_readpage_async(dentry, inode, page);
 	if (error >= 0)
 		goto out;
diff -uNrX /home/eric/projects/linux/linux-ignore-files linux-2.3.3.eb4/fs/nfs/write.c linux-2.3.3.eb5/fs/nfs/write.c
--- linux-2.3.3.eb4/fs/nfs/write.c	Sat May 22 16:09:58 1999
+++ linux-2.3.3.eb5/fs/nfs/write.c	Sat May 22 17:16:35 1999
@@ -95,10 +95,10 @@
 
 	dprintk("NFS:      nfs_writepage_sync(%s/%s %d@%ld)\n",
 		dentry->d_parent->d_name.name, dentry->d_name.name,
-		count, page->offset + offset);
+		count, (page->key << PAGE_CACHE_SHIFT) + offset);
 
 	buffer = (u8 *) page_address(page) + offset;
-	offset += page->offset;
+	offset += page->key << PAGE_CACHE_SHIFT;
 
 	do {
 		if (count < wsize && !IS_SWAPFILE(inode))
@@ -271,7 +271,7 @@
 
 	dprintk("NFS:      create_write_request(%s/%s, %ld+%d)\n",
 		dentry->d_parent->d_name.name, dentry->d_name.name,
-		page->offset + offset, bytes);
+		(page->key << PAGE_CACHE_SHIFT) + offset, bytes);
 
 	/* FIXME: Enforce hard limit on number of concurrent writes? */
 	wreq = (struct nfs_wreq *) kmalloc(sizeof(*wreq), GFP_KERNEL);
@@ -398,7 +398,7 @@
 nfs_writepage(struct file * file, struct page *page)
 {
 	struct dentry *dentry = file->f_dentry;
-	return nfs_writepage_sync(dentry, dentry->d_inode, page, 0, PAGE_SIZE);
+	return nfs_writepage_sync(dentry, dentry->d_inode, page, 0, PAGE_CACHE_SIZE);
 }
 
 /*
@@ -418,7 +418,7 @@
 
 	dprintk("NFS:      nfs_updatepage(%s/%s %d@%ld, sync=%d)\n",
 		dentry->d_parent->d_name.name, dentry->d_name.name,
-		count, page->offset+offset, sync);
+		count, (page->key << PAGE_CACHE_SHIFT)+offset, sync);
 
 	/*
 	 * Try to find a corresponding request on the writeback queue.
@@ -438,7 +438,7 @@
 	 * If wsize is smaller than page size, update and write
 	 * page synchronously.
 	 */
-	if (NFS_SERVER(inode)->wsize < PAGE_SIZE)
+	if (NFS_SERVER(inode)->wsize < PAGE_CACHE_SIZE)
 		return nfs_writepage_sync(dentry, inode, page, offset, count);
 
 	/* Create the write request. */
@@ -457,7 +457,7 @@
 	synchronous = schedule_write_request(req, sync);
 
 updated:
-	if (req->wb_bytes == PAGE_SIZE)
+	if (req->wb_bytes == PAGE_CACHE_SIZE)
 		set_bit(PG_uptodate, &page->flags);
 
 	retval = count;
@@ -604,7 +604,7 @@
 	/* Setup the task struct for a writeback call */
 	req->wb_flags |= NFS_WRITE_INPROGRESS;
 	req->wb_args.fh     = NFS_FH(dentry);
-	req->wb_args.offset = page->offset + req->wb_offset;
+	req->wb_args.offset = (page->key << PAGE_CACHE_SHIFT) + req->wb_offset;
 	req->wb_args.count  = req->wb_bytes;
 	req->wb_args.buffer = (void *) (page_address(page) + req->wb_offset);
 
diff -uNrX /home/eric/projects/linux/linux-ignore-files linux-2.3.3.eb4/fs/open.c linux-2.3.3.eb5/fs/open.c
--- linux-2.3.3.eb4/fs/open.c	Sun May 16 21:52:52 1999
+++ linux-2.3.3.eb5/fs/open.c	Sat May 22 17:16:35 1999
@@ -63,7 +63,7 @@
 	return error;
 }
 
-int do_truncate(struct dentry *dentry, unsigned long length)
+int do_truncate(struct dentry *dentry, loff_t length)
 {
 	struct inode *inode = dentry->d_inode;
 	int error;
diff -uNrX /home/eric/projects/linux/linux-ignore-files linux-2.3.3.eb4/fs/proc/array.c linux-2.3.3.eb5/fs/proc/array.c
--- linux-2.3.3.eb4/fs/proc/array.c	Sat May 22 16:09:58 1999
+++ linux-2.3.3.eb5/fs/proc/array.c	Sat May 22 17:16:53 1999
@@ -1075,8 +1075,8 @@
  *         + (index into the line)
  */
 /* for systems with sizeof(void*) == 4: */
-#define MAPS_LINE_FORMAT4	  "%08lx-%08lx %s %08lx %s %lu"
-#define MAPS_LINE_MAX4	49 /* sum of 8  1  8  1 4 1 8 1 5 1 10 1 */
+#define MAPS_LINE_FORMAT4	  "%08lx-%08lx %s %016Lx %s %lu"
+#define MAPS_LINE_MAX4	57 /* sum of 8  1  8  1 4 1 16 1 5 1 10 1 */
 
 /* for systems with sizeof(void*) == 8: */
 #define MAPS_LINE_FORMAT8	  "%016lx-%016lx %s %016lx %s %lu"
@@ -1163,7 +1163,8 @@
 
 		len = sprintf(line,
 			      sizeof(void*) == 4 ? MAPS_LINE_FORMAT4 : MAPS_LINE_FORMAT8,
-			      map->vm_start, map->vm_end, str, map->vm_offset,
+			      map->vm_start, map->vm_end, str, 
+			      (((loff_t)map->vm_index) << PAGE_SHIFT),
 			      kdevname(dev), ino);
 
 		if(map->vm_file) {
diff -uNrX /home/eric/projects/linux/linux-ignore-files linux-2.3.3.eb4/fs/proc/mem.c linux-2.3.3.eb5/fs/proc/mem.c
--- linux-2.3.3.eb4/fs/proc/mem.c	Sun Oct 11 13:17:26 1998
+++ linux-2.3.3.eb5/fs/proc/mem.c	Sat May 22 17:16:53 1999
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
 	unsigned long stmp, dtmp, mapnr;
 	struct vm_area_struct *src_vma = NULL;
 	struct inode *inode = file->f_dentry->d_inode;
+	unsigned long vm_offset;
 	
 	/* Get the source's task information */
 
@@ -231,9 +232,16 @@
 	 moment because working out the vm_area_struct & nattach stuff isn't
 	 worth it. */
 
+	if ((offset > PAGE_MAX_MEMORY_OFFSET) || 
+	    ((offset + (vma->vm_end - vma->vm_start)) > PAGE_MAX_MEMORY_OFFSET)) {
+		return -EINVAL;
+	}
+	vm_offset = offset;
+	vma->vm_index = vm_offset >> PAGE_SHIFT;
 	src_vma = tsk->mm->mmap;
-	stmp = vma->vm_offset;
-	while (stmp < vma->vm_offset + (vma->vm_end - vma->vm_start)) {
+	stmp = vm_offset;
+	while (stmp < ((vma->vm_index << PAGE_SHIFT) 
+		+ (vma->vm_end - vma->vm_start))) {
 		while (src_vma && stmp > src_vma->vm_end)
 			src_vma = src_vma->vm_next;
 		if (!src_vma || (src_vma->vm_flags & VM_SHM))
@@ -267,7 +275,7 @@
 	}
 
 	src_vma = tsk->mm->mmap;
-	stmp    = vma->vm_offset;
+	stmp    = (vma->vm_index << PAGE_SHIFT);
 	dtmp    = vma->vm_start;
 
 	flush_cache_range(vma->vm_mm, vma->vm_start, vma->vm_end);
diff -uNrX /home/eric/projects/linux/linux-ignore-files linux-2.3.3.eb4/fs/romfs/inode.c linux-2.3.3.eb5/fs/romfs/inode.c
--- linux-2.3.3.eb4/fs/romfs/inode.c	Sun May 16 21:53:59 1999
+++ linux-2.3.3.eb5/fs/romfs/inode.c	Sat May 22 17:16:35 1999
@@ -395,13 +395,13 @@
 	buf = page_address(page);
 	clear_bit(PG_uptodate, &page->flags);
 	clear_bit(PG_error, &page->flags);
-	offset = page->offset;
+	offset = page->key << PAGE_CACHE_SHIFT;
 	if (offset < inode->i_size) {
 		avail = inode->i_size-offset;
-		readlen = min(avail, PAGE_SIZE);
+		readlen = min(avail, PAGE_CACHE_SIZE);
 		if (romfs_copyfrom(inode, (void *)buf, inode->u.romfs_i.i_dataoffset+offset, readlen) == readlen) {
-			if (readlen < PAGE_SIZE) {
-				memset((void *)(buf+readlen),0,PAGE_SIZE-readlen);
+			if (readlen < PAGE_CACHE_SIZE) {
+				memset((void *)(buf+readlen),0,PAGE_CACHE_SIZE-readlen);
 			}
 			set_bit(PG_uptodate, &page->flags);
 			result = 0;
@@ -409,7 +409,7 @@
 	}
 	if (result) {
 		set_bit(PG_error, &page->flags);
-		memset((void *)buf, 0, PAGE_SIZE);
+		memset((void *)buf, 0, PAGE_CACHE_SIZE);
 	}
 
 	clear_bit(PG_locked, &page->flags);
diff -uNrX /home/eric/projects/linux/linux-ignore-files linux-2.3.3.eb4/fs/smbfs/file.c linux-2.3.3.eb5/fs/smbfs/file.c
--- linux-2.3.3.eb4/fs/smbfs/file.c	Mon Apr  5 20:37:56 1999
+++ linux-2.3.3.eb5/fs/smbfs/file.c	Sat May 22 17:16:35 1999
@@ -55,9 +55,9 @@
 smb_readpage_sync(struct dentry *dentry, struct page *page)
 {
 	char *buffer = (char *) page_address(page);
-	unsigned long offset = page->offset;
+	unsigned long offset = page->key << PAGE_CACHE_SHIFT;
 	int rsize = smb_get_rsize(server_from_dentry(dentry));
-	int count = PAGE_SIZE;
+	int count = PAGE_CACHE_SIZE;
 	int result;
 
 	clear_bit(PG_error, &page->flags);
@@ -132,7 +132,7 @@
 	int wsize = smb_get_wsize(server_from_dentry(dentry));
 	int result, written = 0;
 
-	offset += page->offset;
+	offset += page->key << PAGE_CACHE_SHIFT;
 #ifdef SMBFS_DEBUG_VERBOSE
 printk("smb_writepage_sync: file %s/%s, count=%d@%ld, wsize=%d\n",
 dentry->d_parent->d_name.name, dentry->d_name.name, count, offset, wsize);
@@ -181,7 +181,7 @@
 #endif
 	set_bit(PG_locked, &page->flags);
 	atomic_inc(&page->count);
-	result = smb_writepage_sync(dentry, page, 0, PAGE_SIZE);
+	result = smb_writepage_sync(dentry, page, 0, PAGE_CACHE_SIZE);
 	smb_unlock_page(page);
 	free_page(page_address(page));
 	return result;
@@ -194,7 +194,7 @@
 
 	pr_debug("SMBFS: smb_updatepage(%s/%s %d@%ld, sync=%d)\n",
 		dentry->d_parent->d_name.name, dentry->d_name.name,
-	 	count, page->offset+offset, sync);
+	 	count, (page->key << PAGE_CACHE_SHIFT)+offset, sync);
 
 	return smb_writepage_sync(dentry, page, offset, count);
 }
diff -uNrX /home/eric/projects/linux/linux-ignore-files linux-2.3.3.eb4/fs/stat.c linux-2.3.3.eb5/fs/stat.c
--- linux-2.3.3.eb4/fs/stat.c	Tue Feb  9 22:53:45 1999
+++ linux-2.3.3.eb5/fs/stat.c	Sat May 22 17:16:35 1999
@@ -11,6 +11,18 @@
 
 #include <asm/uaccess.h>
 
+#define CHECK_COPY(A, B) \
+do {  \
+	typeof(A) mask = -1;  \
+	typeof(B) masked_b, b;  \
+	b = B; \
+	masked_b = mask & b; \
+	if (masked_b != b) { \
+		return -EOVERFLOW; \
+	} \
+	A = b; \
+} while (0)
+
 /*
  * Revalidate the inode. This is required for proper NFS attribute caching.
  */
@@ -41,17 +53,17 @@
 			current->comm);
 	}
 
-	tmp.st_dev = kdev_t_to_nr(inode->i_dev);
-	tmp.st_ino = inode->i_ino;
-	tmp.st_mode = inode->i_mode;
-	tmp.st_nlink = inode->i_nlink;
-	tmp.st_uid = inode->i_uid;
-	tmp.st_gid = inode->i_gid;
-	tmp.st_rdev = kdev_t_to_nr(inode->i_rdev);
-	tmp.st_size = inode->i_size;
-	tmp.st_atime = inode->i_atime;
-	tmp.st_mtime = inode->i_mtime;
-	tmp.st_ctime = inode->i_ctime;
+	CHECK_COPY(tmp.st_dev, kdev_t_to_nr(inode->i_dev));
+	CHECK_COPY(tmp.st_ino, inode->i_ino);
+	CHECK_COPY(tmp.st_mode, inode->i_mode);
+	CHECK_COPY(tmp.st_nlink, inode->i_nlink);
+	CHECK_COPY(tmp.st_uid, inode->i_uid);
+	CHECK_COPY(tmp.st_gid, inode->i_gid);
+	CHECK_COPY(tmp.st_rdev, kdev_t_to_nr(inode->i_rdev));
+	CHECK_COPY(tmp.st_size, inode->i_size);
+	CHECK_COPY(tmp.st_atime, inode->i_atime);
+	CHECK_COPY(tmp.st_mtime, inode->i_mtime);
+	CHECK_COPY(tmp.st_ctime, inode->i_ctime);
 	return copy_to_user(statbuf,&tmp,sizeof(tmp)) ? -EFAULT : 0;
 }
 
@@ -63,17 +75,17 @@
 	unsigned int blocks, indirect;
 
 	memset(&tmp, 0, sizeof(tmp));
-	tmp.st_dev = kdev_t_to_nr(inode->i_dev);
-	tmp.st_ino = inode->i_ino;
-	tmp.st_mode = inode->i_mode;
-	tmp.st_nlink = inode->i_nlink;
-	tmp.st_uid = inode->i_uid;
-	tmp.st_gid = inode->i_gid;
-	tmp.st_rdev = kdev_t_to_nr(inode->i_rdev);
-	tmp.st_size = inode->i_size;
-	tmp.st_atime = inode->i_atime;
-	tmp.st_mtime = inode->i_mtime;
-	tmp.st_ctime = inode->i_ctime;
+	CHECK_COPY(tmp.st_dev, kdev_t_to_nr(inode->i_dev));
+	CHECK_COPY(tmp.st_ino, inode->i_ino);
+	CHECK_COPY(tmp.st_mode, inode->i_mode);
+	CHECK_COPY(tmp.st_nlink, inode->i_nlink);
+	CHECK_COPY(tmp.st_uid, inode->i_uid);
+	CHECK_COPY(tmp.st_gid, inode->i_gid);
+	CHECK_COPY(tmp.st_rdev, kdev_t_to_nr(inode->i_rdev));
+	CHECK_COPY(tmp.st_size, inode->i_size);
+	CHECK_COPY(tmp.st_atime, inode->i_atime);
+	CHECK_COPY(tmp.st_mtime, inode->i_mtime);
+	CHECK_COPY(tmp.st_ctime, inode->i_ctime);
 /*
  * st_blocks and st_blksize are approximated with a simple algorithm if
  * they aren't supported directly by the filesystem. The minix and msdos
@@ -104,11 +116,11 @@
 					blocks++;
 			}
 		}
-		tmp.st_blocks = (BLOCK_SIZE / 512) * blocks;
-		tmp.st_blksize = BLOCK_SIZE;
+		CHECK_COPY(tmp.st_blocks, (BLOCK_SIZE / 512) * blocks);
+		CHECK_COPY(tmp.st_blksize, BLOCK_SIZE);
 	} else {
-		tmp.st_blocks = inode->i_blocks;
-		tmp.st_blksize = inode->i_blksize;
+		CHECK_COPY(tmp.st_blocks, inode->i_blocks);
+		CHECK_COPY(tmp.st_blksize, inode->i_blksize);
 	}
 	return copy_to_user(statbuf,&tmp,sizeof(tmp)) ? -EFAULT : 0;
 }
diff -uNrX /home/eric/projects/linux/linux-ignore-files linux-2.3.3.eb4/include/asm-alpha/page.h linux-2.3.3.eb5/include/asm-alpha/page.h
--- linux-2.3.3.eb4/include/asm-alpha/page.h	Sun Oct 11 13:16:40 1998
+++ linux-2.3.3.eb5/include/asm-alpha/page.h	Sat May 22 17:16:35 1999
@@ -10,6 +10,10 @@
 
 #ifndef __ASSEMBLY__
 
+#define PAGE_CACHE_SHIFT	PAGE_SHIFT
+#define PAGE_CACHE_SIZE		(1UL << PAGE_CACHE_SHIFT)
+#define PAGE_CACHE_MASK		(~(PAGE_CACHE_SIZE-1))
+
 #define STRICT_MM_TYPECHECKS
 
 /*
diff -uNrX /home/eric/projects/linux/linux-ignore-files linux-2.3.3.eb4/include/asm-arm/page.h linux-2.3.3.eb5/include/asm-arm/page.h
--- linux-2.3.3.eb4/include/asm-arm/page.h	Sun May 16 21:55:24 1999
+++ linux-2.3.3.eb5/include/asm-arm/page.h	Sat May 22 17:16:35 1999
@@ -6,6 +6,10 @@
 
 #ifdef __KERNEL__
 
+#define PAGE_CACHE_SHIFT	PAGE_SHIFT
+#define PAGE_CACHE_SIZE		(1UL << PAGE_CACHE_SHIFT)
+#define PAGE_CACHE_MASK		(~(PAGE_CACHE_SIZE-1))
+
 #define get_user_page(vaddr)		__get_free_page(GFP_KERNEL)
 #define free_user_page(page, addr)	free_page(addr)
 #define clear_page(page)		memzero((void *)(page), PAGE_SIZE)
diff -uNrX /home/eric/projects/linux/linux-ignore-files linux-2.3.3.eb4/include/asm-i386/page.h linux-2.3.3.eb5/include/asm-i386/page.h
--- linux-2.3.3.eb4/include/asm-i386/page.h	Tue Feb  9 23:00:53 1999
+++ linux-2.3.3.eb5/include/asm-i386/page.h	Sat May 22 17:16:35 1999
@@ -9,6 +9,10 @@
 #ifdef __KERNEL__
 #ifndef __ASSEMBLY__
 
+#define PAGE_CACHE_SHIFT	PAGE_SHIFT
+#define PAGE_CACHE_SIZE		(1UL << PAGE_CACHE_SHIFT)
+#define PAGE_CACHE_MASK		(~(PAGE_CACHE_SIZE-1))
+
 #define STRICT_MM_TYPECHECKS
 
 #define clear_page(page)	memset((void *)(page), 0, PAGE_SIZE)
diff -uNrX /home/eric/projects/linux/linux-ignore-files linux-2.3.3.eb4/include/asm-m68k/page.h linux-2.3.3.eb5/include/asm-m68k/page.h
--- linux-2.3.3.eb4/include/asm-m68k/page.h	Sat May 22 16:09:59 1999
+++ linux-2.3.3.eb5/include/asm-m68k/page.h	Sat May 22 17:16:35 1999
@@ -10,6 +10,10 @@
 
 #ifdef __KERNEL__
 
+#define PAGE_CACHE_SHIFT	PAGE_SHIFT
+#define PAGE_CACHE_SIZE		(1UL << PAGE_CACHE_SHIFT)
+#define PAGE_CACHE_MASK		(~(PAGE_CACHE_SIZE-1))
+
 #include <asm/setup.h>
 
 #define STRICT_MM_TYPECHECKS
diff -uNrX /home/eric/projects/linux/linux-ignore-files linux-2.3.3.eb4/include/asm-mips/page.h linux-2.3.3.eb5/include/asm-mips/page.h
--- linux-2.3.3.eb4/include/asm-mips/page.h	Tue May 12 14:18:45 1998
+++ linux-2.3.3.eb5/include/asm-mips/page.h	Sat May 22 17:16:35 1999
@@ -17,6 +17,10 @@
 
 #ifdef __KERNEL__
 
+#define PAGE_CACHE_SHIFT	PAGE_SHIFT
+#define PAGE_CACHE_SIZE		(1UL << PAGE_CACHE_SHIFT)
+#define PAGE_CACHE_MASK		(~(PAGE_CACHE_SIZE-1))
+
 #define STRICT_MM_TYPECHECKS
 
 #ifndef __LANGUAGE_ASSEMBLY__
diff -uNrX /home/eric/projects/linux/linux-ignore-files linux-2.3.3.eb4/include/asm-ppc/page.h linux-2.3.3.eb5/include/asm-ppc/page.h
--- linux-2.3.3.eb4/include/asm-ppc/page.h	Sun May 16 21:55:27 1999
+++ linux-2.3.3.eb5/include/asm-ppc/page.h	Sat May 22 17:16:35 1999
@@ -14,6 +14,10 @@
 #ifndef __ASSEMBLY__
 #ifdef __KERNEL__
 
+#define PAGE_CACHE_SHIFT	PAGE_SHIFT
+#define PAGE_CACHE_SIZE		(1UL << PAGE_CACHE_SHIFT)
+#define PAGE_CACHE_MASK		(~(PAGE_CACHE_SIZE-1))
+
 #define STRICT_MM_TYPECHECKS
 
 #ifdef STRICT_MM_TYPECHECKS
diff -uNrX /home/eric/projects/linux/linux-ignore-files linux-2.3.3.eb4/include/asm-sparc/page.h linux-2.3.3.eb5/include/asm-sparc/page.h
--- linux-2.3.3.eb4/include/asm-sparc/page.h	Mon Apr  5 20:39:59 1999
+++ linux-2.3.3.eb5/include/asm-sparc/page.h	Sat May 22 17:16:35 1999
@@ -28,6 +28,10 @@
 
 #ifndef __ASSEMBLY__
 
+#define PAGE_CACHE_SHIFT	PAGE_SHIFT
+#define PAGE_CACHE_SIZE		(1UL << PAGE_CACHE_SHIFT)
+#define PAGE_CACHE_MASK		(~(PAGE_CACHE_SIZE-1))
+
 #define clear_page(page)	memset((void *)(page), 0, PAGE_SIZE)
 #define copy_page(to,from)	memcpy((void *)(to), (void *)(from), PAGE_SIZE)
 
diff -uNrX /home/eric/projects/linux/linux-ignore-files linux-2.3.3.eb4/include/asm-sparc64/page.h linux-2.3.3.eb5/include/asm-sparc64/page.h
--- linux-2.3.3.eb4/include/asm-sparc64/page.h	Tue Feb  9 22:51:50 1999
+++ linux-2.3.3.eb5/include/asm-sparc64/page.h	Sat May 22 17:16:35 1999
@@ -18,6 +18,10 @@
 
 #ifndef __ASSEMBLY__
 
+#define PAGE_CACHE_SHIFT	PAGE_SHIFT
+#define PAGE_CACHE_SIZE		(1UL << PAGE_CACHE_SHIFT)
+#define PAGE_CACHE_MASK		(~(PAGE_CACHE_SIZE-1))
+
 extern void clear_page(unsigned long page);
 extern void copy_page(unsigned long to, unsigned long from);
 
diff -uNrX /home/eric/projects/linux/linux-ignore-files linux-2.3.3.eb4/include/linux/fs.h linux-2.3.3.eb5/include/linux/fs.h
--- linux-2.3.3.eb4/include/linux/fs.h	Sat May 22 16:10:25 1999
+++ linux-2.3.3.eb5/include/linux/fs.h	Sat May 22 17:16:36 1999
@@ -314,7 +314,7 @@
 	umode_t		ia_mode;
 	uid_t		ia_uid;
 	gid_t		ia_gid;
-	off_t		ia_size;
+	loff_t		ia_size;
 	time_t		ia_atime;
 	time_t		ia_mtime;
 	time_t		ia_ctime;
@@ -349,7 +349,7 @@
 	uid_t			i_uid;
 	gid_t			i_gid;
 	kdev_t			i_rdev;
-	off_t			i_size;
+	loff_t			i_size;
 	time_t			i_atime;
 	time_t			i_mtime;
 	time_t			i_ctime;
@@ -466,8 +466,8 @@
 	struct file *fl_file;
 	unsigned char fl_flags;
 	unsigned char fl_type;
-	off_t fl_start;
-	off_t fl_end;
+	loff_t fl_start;
+	loff_t fl_end;
 
 	void (*fl_notify)(struct file_lock *);	/* unblock callback */
 
@@ -594,7 +594,7 @@
 	int (*readdir) (struct file *, void *, filldir_t);
 	unsigned int (*poll) (struct file *, struct poll_table_struct *);
 	int (*ioctl) (struct inode *, struct file *, unsigned int, unsigned long);
-	int (*mmap) (struct file *, struct vm_area_struct *);
+	int (*mmap) (struct file *, struct vm_area_struct *, loff_t off);
 	int (*open) (struct inode *, struct file *);
 	int (*flush) (struct file *);
 	int (*release) (struct inode *, struct file *);
@@ -702,7 +702,7 @@
 
 asmlinkage int sys_open(const char *, int, int);
 asmlinkage int sys_close(unsigned int);		/* yes, it's really unsigned */
-extern int do_truncate(struct dentry *, unsigned long);
+extern int do_truncate(struct dentry *, loff_t);
 extern int get_unused_fd(void);
 extern void put_unused_fd(unsigned int);
 
@@ -875,7 +875,7 @@
 extern int brw_page(int, struct page *, kdev_t, int [], int, int);
 
 extern int generic_readpage(struct file *, struct page *);
-extern int generic_file_mmap(struct file *, struct vm_area_struct *);
+extern int generic_file_mmap(struct file *, struct vm_area_struct *, loff_t);
 extern ssize_t generic_file_read(struct file *, char *, size_t, loff_t *);
 extern ssize_t generic_file_write(struct file *, const char*, size_t, loff_t*);
 
diff -uNrX /home/eric/projects/linux/linux-ignore-files linux-2.3.3.eb4/include/linux/mm.h linux-2.3.3.eb5/include/linux/mm.h
--- linux-2.3.3.eb4/include/linux/mm.h	Sat May 22 17:09:22 1999
+++ linux-2.3.3.eb5/include/linux/mm.h	Sat May 22 17:16:53 1999
@@ -54,7 +54,11 @@
 	struct vm_area_struct **vm_pprev_share;
 
 	struct vm_operations_struct * vm_ops;
-	unsigned long vm_offset;
+	unsigned long vm_index;
+	/* The old vm_offset value is logically
+	 * (vm_index << PAGE_SHIFT) 
+	 * except the value is potentially too large for the old vm_offset field.
+	 */
 	struct file * vm_file;
 	unsigned long vm_pte;			/* shared mem */
 };
@@ -105,6 +109,7 @@
 	unsigned long (*nopage)(struct vm_area_struct * area, unsigned long address, int write_access);
 	unsigned long (*wppage)(struct vm_area_struct * area, unsigned long address,
 		unsigned long page);
+ 	/* swapin & swapout changed! */
 	int (*swapout)(struct vm_area_struct *, struct page *);
 	pte_t (*swapin)(struct vm_area_struct *, unsigned long, unsigned long);
 };
@@ -122,7 +127,7 @@
 	struct page *next;
 	struct page *prev;
 	struct inode *inode;
-	unsigned long offset;
+	unsigned long key;
 	struct page *next_hash;
 	atomic_t count;
 	unsigned long flags;	/* atomic flags, some possibly updated asynchronously */
@@ -210,8 +215,8 @@
  * The following discussion applies only to them.
  *
  * A page may belong to an inode's memory mapping. In this case,
- * page->inode is the pointer to the inode, and page->offset is the
- * file offset of the page (not necessarily a multiple of PAGE_SIZE).
+ * page->inode is the pointer to the inode, and page->key is the
+ * offset into the file (divided by PAGE_CACHE_SIZE).
  *
  * A page may have buffers allocated to it. In this case,
  * PageBuffer(page) is true and page->generic_pp is a circular list of
@@ -223,7 +228,7 @@
  * All pages belonging to an inode make up a doubly linked list
  * inode->i_pages, using the fields page->next and page->prev. (These
  * fields are also used for freelist management when page->count==0.)
- * There is also a hash table mapping (inode,offset) to the page
+ * There is also a hash table mapping (inode,key) to the page
  * in memory if present. The lists for this hash table use the fields
  * page->next_hash and page->pprev_hash.
  *
@@ -244,7 +249,7 @@
  *
  * For choosing which pages to swap out, inode pages carry a
  * PG_referenced bit, which is set any time the system accesses
- * that page through the (inode,offset) hash table.
+ * that page through the (inode,index) hash table.
  *
  * PG_skip is used on sparc/sparc64 architectures to "skip" certain
  * parts of the address space.
@@ -294,7 +299,7 @@
 extern int remap_page_range(unsigned long from, unsigned long to, unsigned long size, pgprot_t prot);
 extern int zeromap_page_range(unsigned long from, unsigned long size, pgprot_t prot);
 
-extern void vmtruncate(struct inode * inode, unsigned long offset);
+extern void vmtruncate(struct inode * inode, loff_t offset);
 extern int handle_mm_fault(struct task_struct *tsk,struct vm_area_struct *vma, unsigned long address, int write_access);
 extern void make_pages_present(unsigned long addr, unsigned long end);
 
@@ -316,14 +321,14 @@
 extern unsigned long get_unmapped_area(unsigned long, unsigned long);
 
 extern unsigned long do_mmap(struct file *, unsigned long, unsigned long,
-	unsigned long, unsigned long, unsigned long);
+	unsigned long, unsigned long, loff_t);
 extern int do_munmap(unsigned long, size_t);
 
 /* filemap.c */
 extern void remove_inode_page(struct page *);
 extern unsigned long page_unuse(struct page *);
 extern int shrink_mmap(int, int);
-extern void truncate_inode_pages(struct inode *, unsigned long);
+extern void truncate_inode_pages(struct inode *, loff_t);
 extern unsigned long get_cached_page(struct inode *, unsigned long, int);
 extern void put_cached_page(unsigned long);
 
@@ -365,8 +370,8 @@
 	    > (unsigned long) current->rlim[RLIMIT_AS].rlim_cur)
 		return -ENOMEM;
 	vma->vm_start = address;
-	vma->vm_offset -= grow;
-	vma->vm_mm->total_vm += grow >> PAGE_SHIFT;
+	vma->vm_index -= grow >> PAGE_SHIFT;
+	vma->vm_mm->total_vm += grow;
 	if (vma->vm_flags & VM_LOCKED)
 		vma->vm_mm->locked_vm += grow >> PAGE_SHIFT;
 	return 0;
@@ -385,6 +390,11 @@
 		vma = NULL;
 	return vma;
 }
+
+/* The old limit on mmap offsets */
+#define PAGE_MAX_MEMORY_OFFSET (-1UL)
+/* The maximum file size we can mmap to one inode */
+#define PAGE_MAX_FILE_OFFSET (((-1UL) * (1ULL << PAGE_SHIFT)) + (PAGE_SIZE -1))
 
 #define buffer_under_min()	((buffermem >> PAGE_SHIFT) * 100 < \
 				buffer_mem.min_percent * num_physpages)
diff -uNrX /home/eric/projects/linux/linux-ignore-files linux-2.3.3.eb4/include/linux/pagemap.h linux-2.3.3.eb5/include/linux/pagemap.h
--- linux-2.3.3.eb4/include/linux/pagemap.h	Sat May 22 17:09:29 1999
+++ linux-2.3.3.eb5/include/linux/pagemap.h	Sat May 22 17:16:36 1999
@@ -24,10 +24,13 @@
  * space in smaller chunks for same flexibility).
  *
  * Or rather, it _will_ be done in larger chunks.
- */
+ *
+ * To start with:
 #define PAGE_CACHE_SHIFT	PAGE_SHIFT
 #define PAGE_CACHE_SIZE		PAGE_SIZE
 #define PAGE_CACHE_MASK		PAGE_MASK
+ */
+
 
 #define page_cache_alloc()	__get_free_page(GFP_USER)
 #define page_cache_free(x)	free_page(x)
@@ -50,10 +53,10 @@
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
@@ -61,9 +64,9 @@
 #undef s
 }
 
-#define page_hash(inode,offset) (page_hash_table+_page_hashfn(inode,offset))
+#define page_hash(inode,key) (page_hash_table+_page_hashfn(inode,key))
 
-static inline struct page * __find_page(struct inode * inode, unsigned long offset, struct page *page)
+static inline struct page * __find_page(struct inode * inode, unsigned long key, struct page *page)
 {
 	goto inside;
 	for (;;) {
@@ -73,7 +76,7 @@
 			goto not_found;
 		if (page->inode != inode)
 			continue;
-		if (page->offset == offset)
+		if (page->key == key)
 			break;
 	}
 	/* Found the page. */
@@ -82,10 +85,9 @@
 not_found:
 	return page;
 }
-
-static inline struct page *find_page(struct inode * inode, unsigned long offset)
+static inline struct page *find_page(struct inode * inode, unsigned long key)
 {
-	return __find_page(inode, offset, *page_hash(inode, offset));
+	return __find_page(inode, key, *page_hash(inode, key));
 }
 
 static inline void remove_page_from_hash_queue(struct page * page)
@@ -108,9 +110,9 @@
 	page->pprev_hash = p;
 }
 
-static inline void add_page_to_hash_queue(struct page * page, struct inode * inode, unsigned long offset)
+static inline void add_page_to_hash_queue(struct page * page, struct inode * inode, unsigned long key)
 {
-	__add_page_to_hash_queue(page, page_hash(inode,offset));
+	__add_page_to_hash_queue(page, page_hash(inode,key));
 }
 
 static inline void remove_page_from_inode_queue(struct page * page)
@@ -148,6 +150,6 @@
 		__wait_on_page(page);
 }
 
-extern void update_vm_cache(struct inode *, unsigned long, const char *, int);
+extern void update_vm_cache(struct inode *, loff_t, const char *, int);
 
 #endif
diff -uNrX /home/eric/projects/linux/linux-ignore-files linux-2.3.3.eb4/include/linux/swap.h linux-2.3.3.eb5/include/linux/swap.h
--- linux-2.3.3.eb4/include/linux/swap.h	Sat May 22 17:09:32 1999
+++ linux-2.3.3.eb5/include/linux/swap.h	Sat May 22 17:16:36 1999
@@ -162,7 +162,7 @@
 extern inline unsigned long in_swap_cache(struct page *page)
 {
 	if (PageSwapCache(page))
-		return page->offset;
+		return page->key;
 	return 0;
 }
 
@@ -179,7 +179,7 @@
 		return 1;
 	count = atomic_read(&page->count);
 	if (PageSwapCache(page))
-		count += swap_count(page->offset) - 2;
+		count += swap_count(page->key) - 2;
 	if (PageFreeAfter(page))
 		count--;
 	return  count > 1;
diff -uNrX /home/eric/projects/linux/linux-ignore-files linux-2.3.3.eb4/include/linux/wrapper.h linux-2.3.3.eb5/include/linux/wrapper.h
--- linux-2.3.3.eb4/include/linux/wrapper.h	Tue Dec 16 12:39:55 1997
+++ linux-2.3.3.eb5/include/linux/wrapper.h	Sat May 22 17:16:36 1999
@@ -28,7 +28,7 @@
 
 #define vma_set_inode(v,i) v->vm_inode = i
 #define vma_get_flags(v) v->vm_flags
-#define vma_get_offset(v) v->vm_offset
+/* #define vma_get_offset(v) v->vm_offset */
 #define vma_get_start(v) v->vm_start
 #define vma_get_end(v) v->vm_end
 #define vma_get_page_prot(v) v->vm_page_prot
diff -uNrX /home/eric/projects/linux/linux-ignore-files linux-2.3.3.eb4/ipc/shm.c linux-2.3.3.eb5/ipc/shm.c
--- linux-2.3.3.eb4/ipc/shm.c	Sat May 22 17:09:32 1999
+++ linux-2.3.3.eb5/ipc/shm.c	Sat May 22 17:20:31 1999
@@ -363,7 +363,7 @@
  * shmd->vm_end		multiple of SHMLBA
  * shmd->vm_next	next attach for task
  * shmd->vm_next_share	next attach for segment
- * shmd->vm_offset	offset into segment
+ * shmd->vm_index	page index into segment
  * shmd->vm_pte		signature for this attach
  */
 
@@ -513,7 +513,7 @@
 			 | VM_MAYREAD | VM_MAYEXEC | VM_READ | VM_EXEC
 			 | ((shmflg & SHM_RDONLY) ? 0 : VM_MAYWRITE | VM_WRITE);
 	shmd->vm_file = NULL;
-	shmd->vm_offset = 0;
+	shmd->vm_index = 0;
 	shmd->vm_ops = &shm_vm_ops;
 
 	shp->u.shm_nattch++;            /* prevent destruction */
@@ -589,7 +589,8 @@
 	for (shmd = current->mm->mmap; shmd; shmd = shmdnext) {
 		shmdnext = shmd->vm_next;
 		if (shmd->vm_ops == &shm_vm_ops
-		    && shmd->vm_start - shmd->vm_offset == (ulong) shmaddr)
+			&& (shmd->vm_start - (shmd->vm_index << PAGE_SHIFT)
+				== (ulong) shmaddr))
 			do_munmap(shmd->vm_start, shmd->vm_end - shmd->vm_start);
 	}
 	unlock_kernel();
@@ -620,7 +621,7 @@
 	unsigned int id, idx;
 
 	id = SWP_OFFSET(shmd->vm_pte) & SHM_ID_MASK;
-	idx = (address - shmd->vm_start + shmd->vm_offset) >> PAGE_SHIFT;
+	idx = ((address - shmd->vm_start) >> PAGE_SHIFT) + shmd->vm_index;
 
 #ifdef DEBUG_SHM
 	if (id > max_shmid) {
diff -uNrX /home/eric/projects/linux/linux-ignore-files linux-2.3.3.eb4/lib/vsprintf.c linux-2.3.3.eb5/lib/vsprintf.c
--- linux-2.3.3.eb4/lib/vsprintf.c	Mon Apr  5 20:40:05 1999
+++ linux-2.3.3.eb5/lib/vsprintf.c	Sat May 22 17:16:36 1999
@@ -139,6 +139,104 @@
 	return str;
 }
 
+/* Note: do_ldev assumes that unsigned long long is a 64 bit long
+ * and unsigned long is at least a 32 bits long.
+ */
+#define do_ldiv(n, base) \
+({ \
+	int __res; \
+	unsigned long long value = n; \
+	unsigned long long leftover; \
+	unsigned long temp; \
+	unsigned long result_div1, result_div2, result_div3, result_mod; \
+\
+	temp = value >> 32; \
+	result_div1 = temp/(base); \
+	result_mod = temp%(base); \
+\
+	temp = (result_mod << 24) | ((value >> 8) & 0xFFFFFF); \
+	result_div2 = temp/(base); \
+	result_mod = temp%(base); \
+\
+	temp = (result_mod << 8) | (value & 0xFF); \
+	result_div3 = temp/(base); \
+	result_mod = temp%(base);\
+\
+	leftover = ((unsigned long long)result_div1 << 32) | \
+		((unsigned long long)result_div2 << 8) | (result_div3); \
+\
+	n = leftover; \
+	__res = result_mod; \
+	__res; \
+})
+
+static char * lnumber(char * str, long long num, int base, int size, int precision
+	,int type)
+{
+	char c,sign,tmp[66];
+	const char *digits="0123456789abcdefghijklmnopqrstuvwxyz";
+	int i;
+
+	if (type & LARGE)
+		digits = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
+	if (type & LEFT)
+		type &= ~ZEROPAD;
+	if (base < 2 || base > 36)
+		return 0;
+	c = (type & ZEROPAD) ? '0' : ' ';
+	sign = 0;
+	if (type & SIGN) {
+		if (num < 0) {
+			sign = '-';
+			num = -num;
+			size--;
+		} else if (type & PLUS) {
+			sign = '+';
+			size--;
+		} else if (type & SPACE) {
+			sign = ' ';
+			size--;
+		}
+	}
+	if (type & SPECIAL) {
+		if (base == 16)
+			size -= 2;
+		else if (base == 8)
+			size--;
+	}
+	i = 0;
+	if (num == 0)
+		tmp[i++]='0';
+	else while (num != 0)
+		tmp[i++] = digits[do_ldiv(num,base)];
+	if (i > precision)
+		precision = i;
+	size -= precision;
+	if (!(type&(ZEROPAD+LEFT)))
+		while(size-->0)
+			*str++ = ' ';
+	if (sign)
+		*str++ = sign;
+	if (type & SPECIAL) {
+		if (base==8)
+			*str++ = '0';
+		else if (base==16) {
+			*str++ = '0';
+			*str++ = digits[33];
+		}
+	}
+	if (!(type & LEFT))
+		while (size-- > 0)
+			*str++ = c;
+	while (i < precision--)
+		*str++ = '0';
+	while (i-- > 0)
+		*str++ = tmp[i];
+	while (size-- > 0)
+		*str++ = ' ';
+	return str;
+}
+
 /* Forward decl. needed for IP address printing stuff... */
 int sprintf(char * buf, const char *fmt, ...);
 
@@ -288,6 +386,13 @@
 				*str++ = *fmt;
 			else
 				--fmt;
+			continue;
+		}
+		if (qualifier == 'L') {
+			unsigned long long lnum;
+			lnum = va_arg(args, unsigned long long);
+			str = lnumber(str, lnum, base, field_width,
+				      precision, flags);
 			continue;
 		}
 		if (qualifier == 'l')
diff -uNrX /home/eric/projects/linux/linux-ignore-files linux-2.3.3.eb4/mm/filemap.c linux-2.3.3.eb5/mm/filemap.c
--- linux-2.3.3.eb4/mm/filemap.c	Sat May 22 17:09:26 1999
+++ linux-2.3.3.eb5/mm/filemap.c	Sat May 22 17:27:18 1999
@@ -43,7 +43,7 @@
 {
 	struct pio_request *	next;
 	struct file *		file;
-	unsigned long		offset;
+	unsigned long		index;
 	unsigned long		page;
 };
 static struct pio_request *pio_first = NULL, **pio_last = &pio_first;
@@ -86,18 +86,27 @@
  * Truncate the page cache at a set offset, removing the pages
  * that are beyond that offset (and zeroing out partial pages).
  */
-void truncate_inode_pages(struct inode * inode, unsigned long start)
+void truncate_inode_pages(struct inode * inode, loff_t start)
 {
 	struct page ** p;
 	struct page * page;
+	unsigned long last_keep, partial_keep;
+	unsigned long keep_bytes;
+
+	if (start > PAGE_MAX_FILE_OFFSET) {
+		return;
+	}
+	keep_bytes = start & ~PAGE_CACHE_MASK;
+	partial_keep = start >> PAGE_CACHE_SHIFT;
+	last_keep = partial_keep + (keep_bytes?1:0);
 
 repeat:
 	p = &inode->i_pages;
 	while ((page = *p) != NULL) {
-		unsigned long offset = page->offset;
+		unsigned long index = page->key;
 
 		/* page wholly truncated - free it */
-		if (offset >= start) {
+		if (index >= last_keep) {
 			if (PageLocked(page)) {
 				wait_on_page(page);
 				goto repeat;
@@ -113,11 +122,10 @@
 			continue;
 		}
 		p = &page->next;
-		offset = start - offset;
 		/* partial truncate, clear end of page */
-		if (offset < PAGE_CACHE_SIZE) {
+		if (index == partial_keep) {
 			unsigned long address = page_address(page);
-			memset((void *) (offset + address), 0, PAGE_CACHE_SIZE - offset);
+			memset((void *) (keep_bytes + address), 0, PAGE_CACHE_SIZE - keep_bytes);
 			flush_page_to_ram(address);
 		}
 	}
@@ -182,7 +190,7 @@
 		 * were to be marked referenced..
 		 */
 		if (PageSwapCache(page)) {
-			if (referenced && swap_count(page->offset) != 1)
+			if (referenced && swap_count(page->key) != 1)
 				continue;
 			delete_from_swap_cache(page);
 			return 1;
@@ -216,19 +224,22 @@
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
 	offset = (pos & ~PAGE_CACHE_MASK);
-	pos = pos & PAGE_CACHE_MASK;
+	index = pos >> PAGE_CACHE_SHIFT;
 	len = PAGE_CACHE_SIZE - offset;
 	do {
 		struct page * page;
 
 		if (len > count)
 			len = count;
-		page = find_page(inode, pos);
+		page = find_page(inode, index);
 		if (page) {
 			wait_on_page(page);
 			memcpy((void *) (offset + page_address(page)), buf, len);
@@ -238,17 +249,17 @@
 		buf += len;
 		len = PAGE_CACHE_SIZE;
 		offset = 0;
-		pos += PAGE_CACHE_SIZE;
+		index++
 	} while (count);
 }
 
 static inline void add_to_page_cache(struct page * page,
-	struct inode * inode, unsigned long offset,
+	struct inode * inode, unsigned long key,
 	struct page **hash)
 {
 	atomic_inc(&page->count);
 	page->flags = (page->flags & ~((1 << PG_uptodate) | (1 << PG_error))) | (1 << PG_referenced);
-	page->offset = offset;
+	page->key = key;
 	add_page_to_inode_queue(inode, page);
 	__add_page_to_hash_queue(page, hash);
 }
@@ -259,29 +270,28 @@
  * this is all overlapped with the IO on the previous page finishing anyway)
  */
 static unsigned long try_to_read_ahead(struct file * file,
-				unsigned long offset, unsigned long page_cache)
+				unsigned long index, unsigned long page_cache)
 {
 	struct inode *inode = file->f_dentry->d_inode;
 	struct page * page;
 	struct page ** hash;
 
-	offset &= PAGE_CACHE_MASK;
 	switch (page_cache) {
 	case 0:
 		page_cache = page_cache_alloc();
 		if (!page_cache)
 			break;
 	default:
-		if (offset >= inode->i_size)
+		if ((((loff_t)index) << PAGE_CACHE_SHIFT) > inode->i_size)
 			break;
-		hash = page_hash(inode, offset);
-		page = __find_page(inode, offset, *hash);
+		hash = page_hash(inode, index);
+		page = __find_page(inode, index, *hash);
 		if (!page) {
 			/*
 			 * Ok, add the new page to the hash-queues...
 			 */
 			page = page_cache_entry(page_cache);
-			add_to_page_cache(page, inode, offset, hash);
+			add_to_page_cache(page, inode, index, hash);
 			inode->i_op->readpage(file, page);
 			page_cache = 0;
 		}
@@ -385,11 +395,11 @@
  * Read-ahead context:
  * -------------------
  * The read ahead context fields of the "struct file" are the following:
- * - f_raend : position of the first byte after the last page we tried to
+ * - f_raend : index of the first page after the last page we tried to
  *             read ahead.
- * - f_ramax : current read-ahead maximum size.
- * - f_ralen : length of the current IO read block we tried to read-ahead.
- * - f_rawin : length of the current read-ahead window.
+ * - f_ramax : current read-ahead maximum size, in pages.
+ * - f_ralen : length of the current IO read block we tried to read-ahead, in pages.
+ * - f_rawin : length of the current read-ahead window, in pages.
  *             if last read-ahead was synchronous then
  *                  f_rawin = f_ralen
  *             otherwise (was asynchronous)
@@ -439,20 +449,24 @@
 
 static inline int get_max_readahead(struct inode * inode)
 {
-	if (!inode->i_dev || !max_readahead[MAJOR(inode->i_dev)])
-		return MAX_READAHEAD;
-	return max_readahead[MAJOR(inode->i_dev)][MINOR(inode->i_dev)];
+	unsigned long max;
+	if (!inode->i_dev || !max_readahead[MAJOR(inode->i_dev)]) {
+		max = MAX_READAHEAD;
+	} else {
+		max = max_readahead[MAJOR(inode->i_dev)][MINOR(inode->i_dev)];
+	}
+	return max >> PAGE_CACHE_SHIFT;
 }
 
 static inline unsigned long generic_file_readahead(int reada_ok,
 	struct file * filp, struct inode * inode,
-	unsigned long ppos, struct page * page, unsigned long page_cache)
+	unsigned long index, struct page * page, unsigned long page_cache)
 {
 	unsigned long max_ahead, ahead;
 	unsigned long raend;
 	int max_readahead = get_max_readahead(inode);
 
-	raend = filp->f_raend & PAGE_CACHE_MASK;
+	raend = filp->f_raend;
 	max_ahead = 0;
 
 /*
@@ -465,13 +479,13 @@
  */
 	if (PageLocked(page)) {
 		if (!filp->f_ralen || ppos >= raend || ppos + filp->f_ralen < raend) {
-			raend = ppos;
-			if (raend < inode->i_size)
+			raend = index;
+			if (((loff_t)raend << PAGE_CACHE_SHIFT) < inode->i_size)
 				max_ahead = filp->f_ramax;
 			filp->f_rawin = 0;
-			filp->f_ralen = PAGE_CACHE_SIZE;
+			filp->f_ralen = 1;
 			if (!max_ahead) {
-				filp->f_raend  = ppos + filp->f_ralen;
+				filp->f_raend  = index + filp->f_ralen;
 				filp->f_rawin += filp->f_ralen;
 			}
 		}
@@ -484,8 +498,8 @@
  *   it is the moment to try to read ahead asynchronously.
  * We will later force unplug device in order to force asynchronous read IO.
  */
-	else if (reada_ok && filp->f_ramax && raend >= PAGE_CACHE_SIZE &&
-	         ppos <= raend && ppos + filp->f_ralen >= raend) {
+	else if (reada_ok && filp->f_ramax && raend >= 1 &&
+	         index <= raend && index + filp->f_ralen >= raend) {
 /*
  * Add ONE page to max_ahead in order to try to have about the same IO max size
  * as synchronous read-ahead (MAX_READAHEAD + 1)*PAGE_CACHE_SIZE.
@@ -493,8 +507,8 @@
  * begin to read ahead just at the next page.
  */
 		raend -= PAGE_CACHE_SIZE;
-		if (raend < inode->i_size)
-			max_ahead = filp->f_ramax + PAGE_CACHE_SIZE;
+		if (((loff_t)raend << PAGE_CACHE_SHIFT) < inode->i_size)
+			max_ahead = filp->f_ramax + 1;
 
 		if (max_ahead) {
 			filp->f_rawin = filp->f_ralen;
@@ -509,7 +523,7 @@
  */
 	ahead = 0;
 	while (ahead < max_ahead) {
-		ahead += PAGE_CACHE_SIZE;
+		ahead += 1;
 		page_cache = try_to_read_ahead(filp, raend + ahead,
 						page_cache);
 	}
@@ -531,7 +545,7 @@
 
 		filp->f_ralen += ahead;
 		filp->f_rawin += filp->f_ralen;
-		filp->f_raend = raend + ahead + PAGE_CACHE_SIZE;
+		filp->f_raend = raend + ahead + 1;
 
 		filp->f_ramax += filp->f_ramax;
 
@@ -576,14 +590,20 @@
 {
 	struct dentry *dentry = filp->f_dentry;
 	struct inode *inode = dentry->d_inode;
+	unsinged long page_cache, index;
 	size_t pos, pgpos, page_cache;
 	int reada_ok;
 	int max_readahead = get_max_readahead(inode);
+	loff_t pos;
 
 	page_cache = 0;
 
 	pos = *ppos;
-	pgpos = pos & PAGE_CACHE_MASK;
+	if (pos > PAGE_MAX_FILE_OFFSET) {
+		desc->error = -EFBIG;
+		return;
+	}
+	index = pos >> PAGE_CACHE_SHIFT;
 /*
  * If the current position is outside the previous read-ahead window, 
  * we reset the current read-ahead context and set read ahead max to zero
@@ -591,7 +611,7 @@
  * otherwise, we assume that the file accesses are sequential enough to
  * continue read-ahead.
  */
-	if (pgpos > filp->f_raend || pgpos + filp->f_rawin < filp->f_raend) {
+	if (index > filp->f_raend || index + filp->f_rawin < filp->f_raend) {
 		reada_ok = 0;
 		filp->f_raend = 0;
 		filp->f_ralen = 0;
@@ -612,13 +632,13 @@
 	} else {
 		unsigned long needed;
 
-		needed = ((pos + desc->count) & PAGE_CACHE_MASK) - pgpos;
+		needed = ((pos + desc->count) >> PAGE_CACHE_SHIFT) - index;
 
 		if (filp->f_ramax < needed)
 			filp->f_ramax = needed;
 
-		if (reada_ok && filp->f_ramax < MIN_READAHEAD)
-				filp->f_ramax = MIN_READAHEAD;
+		if (reada_ok && filp->f_ramax < (MIN_READAHEAD >> PAGE_CACHE_SHIFT))
+				filp->f_ramax = (MIN_READAHEAD >> PAGE_CACHE_SHIFT);
 		if (filp->f_ramax > max_readahead)
 			filp->f_ramax = max_readahead;
 	}
@@ -629,11 +649,16 @@
 		if (pos >= inode->i_size)
 			break;
 
+		if (pos > PAGE_MAX_FILE_OFFSET) {
+			desc->error = -EFBIG;
+		}
+
+		index = pos >> PAGE_CACHE_SHIFT;
 		/*
 		 * Try to find the data in the page cache..
 		 */
-		hash = page_hash(inode, pos & PAGE_CACHE_MASK);
-		page = __find_page(inode, pos & PAGE_CACHE_MASK, *hash);
+		hash = page_hash(inode, index);
+		page = __find_page(inode, index, *hash);
 		if (!page)
 			goto no_cached_page;
 
@@ -647,8 +672,8 @@
  */
 		if (PageUptodate(page) || PageLocked(page))
 			page_cache = generic_file_readahead(reada_ok, filp, inode, pos & PAGE_CACHE_MASK, page, page_cache);
-		else if (reada_ok && filp->f_ramax > MIN_READAHEAD)
-				filp->f_ramax = MIN_READAHEAD;
+		else if (reada_ok && filp->f_ramax > (MIN_READAHEAD >> PAGE_CACHE_SHIFT))
+				filp->f_ramax = (MIN_READAHEAD >> PAGE_CACHE_SHIFT);
 
 		wait_on_page(page);
 
@@ -665,7 +690,7 @@
 
 		offset = pos & ~PAGE_CACHE_MASK;
 		nr = PAGE_CACHE_SIZE - offset;
-		if (nr > inode->i_size - pos)
+		if ((loff_t)nr > (inode->i_size - pos))
 			nr = inode->i_size - pos;
 
 		/*
@@ -705,7 +730,7 @@
 		 */
 		page = page_cache_entry(page_cache);
 		page_cache = 0;
-		add_to_page_cache(page, inode, pos & PAGE_CACHE_MASK, hash);
+		add_to_page_cache(page, inode, index, hash);
 
 		/*
 		 * Error handling is tricky. If we get a read error,
@@ -722,8 +747,8 @@
  * the application process needs it, or has been rewritten.
  * Decrease max readahead size to the minimum value in that situation.
  */
-		if (reada_ok && filp->f_ramax > MIN_READAHEAD)
-			filp->f_ramax = MIN_READAHEAD;
+		if (reada_ok && filp->f_ramax > (MIN_READAHEAD >> PAGE_CACHE_SHIFT))
+			filp->f_ramax = (MIN_READAHEAD >> PAGE_CACHE_SHIFT);
 
 		{
 			int error = inode->i_op->readpage(filp, page);
@@ -931,20 +956,22 @@
 	struct file * file = area->vm_file;
 	struct dentry * dentry = file->f_dentry;
 	struct inode * inode = dentry->d_inode;
-	unsigned long offset, reada, i;
+	unsigned long index, reada, i;
 	struct page * page, **hash;
 	unsigned long old_page, new_page;
+	
 
 	new_page = 0;
-	offset = (address & PAGE_MASK) - area->vm_start + area->vm_offset;
-	if (offset >= inode->i_size && (area->vm_flags & VM_SHARED) && area->vm_mm == current->mm)
+	index = area->vm_index + ((address - area->vm_start) >> PAGE_SHIFT);
+	if ((area->vm_flags & VM_SHARED) &&
+		((((loff_t)index) << PAGE_SHIFT) >= inode->i_size))
 		goto no_page;
 
+	hash = page_hash(inode, (index >> (PAGE_CACHE_SHIFT - PAGE_SHIFT)));
 	/*
 	 * Do we have something in the page cache already?
 	 */
-	hash = page_hash(inode, offset);
-	page = __find_page(inode, offset, *hash);
+	page = __find_page(inode, (index >> (PAGE_CACHE_SHIFT - PAGE_SHIFT)), *hash);
 	if (!page)
 		goto no_cached_page;
 
@@ -980,7 +1007,7 @@
 			page_cache_free(new_page);
 
 		flush_page_to_ram(old_page);
-		return old_page;
+		return old_page /* + (index << PAGE_SHIFT) & ~PAGE_CACHE_MASK */;
 	}
 
 	/*
@@ -989,17 +1016,17 @@
 	copy_page(new_page, old_page);
 	flush_page_to_ram(new_page);
 	page_cache_release(page);
-	return new_page;
+	return new_page  /* + (index << PAGE_SHIFT) & ~PAGE_CACHE_MASK */;
 
 no_cached_page:
 	/*
 	 * Try to read in an entire cluster at once.
 	 */
-	reada   = offset;
-	reada >>= PAGE_CACHE_SHIFT + page_cluster;
-	reada <<= PAGE_CACHE_SHIFT + page_cluster;
+	reada   = index >> (PAGE_CACHE_SHIFT - PAGE_SHIFT);
+	reada >>= page_cluster;
+	reada <<= page_cluster;
 
-	for (i = 1 << page_cluster; i > 0; --i, reada += PAGE_CACHE_SIZE)
+	for (i = 1 << page_cluster; i > 0; --i, reada++)
 		new_page = try_to_read_ahead(file, reada, new_page);
 
 	if (!new_page)
@@ -1013,7 +1040,7 @@
 	 * cache.. The page we just got may be useful if we
 	 * can't share, so don't get rid of it here.
 	 */
-	page = find_page(inode, offset);
+	page = __find_page(inode, (index >> (PAGE_CACHE_SHIFT - PAGE_SHIFT)), *hash);
 	if (page)
 		goto found_page;
 
@@ -1022,7 +1049,7 @@
 	 */
 	page = page_cache_entry(new_page);
 	new_page = 0;
-	add_to_page_cache(page, inode, offset, hash);
+	add_to_page_cache(page, inode, (index >> (PAGE_CACHE_SHIFT - PAGE_SHIFT)), hash);
 
 	if (inode->i_op->readpage(file, page) != 0)
 		goto failure;
@@ -1066,23 +1093,24 @@
  * if the disk is full.
  */
 static inline int do_write_page(struct inode * inode, struct file * file,
-	const char * page, unsigned long offset)
+	const char * page, unsigned long index)
 {
 	int retval;
 	unsigned long size;
-	loff_t loff = offset;
+	loff_t loff = ((loff_t)index) << PAGE_CACHE_SHIFT;
 	mm_segment_t old_fs;
 
-	size = offset + PAGE_SIZE;
+	size = PAGE_CACHE_SIZE;
 	/* refuse to extend file size.. */
 	if (S_ISREG(inode->i_mode)) {
-		if (size > inode->i_size)
-			size = inode->i_size;
+		if (PAGE_CACHE_SIZE > (inode->i_size - loff)) {
+			size = inode->i_size - loff;
+		} 
 		/* Ho humm.. We should have tested for this earlier */
-		if (size < offset)
+		if (size < 0) {
 			return -EIO;
+		}
 	}
-	size -= offset;
 	old_fs = get_fs();
 	set_fs(KERNEL_DS);
 	retval = -EIO;
@@ -1093,7 +1121,7 @@
 }
 
 static int filemap_write_page(struct vm_area_struct * vma,
-			      unsigned long offset,
+			      unsigned long index,
 			      unsigned long page,
 			      int wait)
 {
@@ -1120,12 +1148,12 @@
 	 * to the kpiod thread.  Just queue the request for now.
 	 */
 	if (!wait) {
-		make_pio_request(file, offset, page);
+		make_pio_request(file, index, page);
 		return 0;
 	}
 	
 	down(&inode->i_sem);
-	result = do_write_page(inode, file, (const char *) page, offset);
+	result = do_write_page(inode, file, (const char *) page, index);
 	up(&inode->i_sem);
 	fput(file);
 	return result;
@@ -1139,7 +1167,7 @@
  */
 int filemap_swapout(struct vm_area_struct * vma, struct page * page)
 {
-	return filemap_write_page(vma, page->offset, page_address(page), 0);
+	return filemap_write_page(vma, page->key, page_address(page), 0);
 }
 
 static inline int filemap_sync_pte(pte_t * ptep, struct vm_area_struct *vma,
@@ -1147,6 +1175,7 @@
 {
 	pte_t pte = *ptep;
 	unsigned long page;
+	unsigned long index;
 	int error;
 
 	if (!(flags & MS_INVALIDATE)) {
@@ -1176,7 +1205,9 @@
 			return 0;
 		}
 	}
-	error = filemap_write_page(vma, address - vma->vm_start + vma->vm_offset, page, 1);
+	index = ((address - vma->vm_start) >> PAGE_CACHE_SHIFT)
+		+ (vma->vm_index >> (PAGE_CACHE_SHIFT - PAGE_SHIFT));
+	error = filemap_write_page(vma, index, page, 1);
 	page_cache_free(page);
 	return error;
 }
@@ -1205,7 +1236,7 @@
 	error = 0;
 	do {
 		error |= filemap_sync_pte(pte, vma, address + offset, flags);
-		address += PAGE_SIZE;
+		address += PAGE_CACHE_SIZE;
 		pte++;
 	} while (address < end);
 	return error;
@@ -1306,27 +1337,37 @@
 
 /* This is used for a general mmap of a disk file */
 
-int generic_file_mmap(struct file * file, struct vm_area_struct * vma)
+int generic_file_mmap(struct file * file, struct vm_area_struct * vma, 
+	loff_t offset)
 {
 	struct vm_operations_struct * ops;
 	struct inode *inode = file->f_dentry->d_inode;
+	unsigned long index;
+
+	if ((offset > PAGE_MAX_FILE_OFFSET) ||
+		((offset + (vma->vm_end - vma->vm_start)) > PAGE_MAX_FILE_OFFSET)) {
+		return -EINVAL;
+	}
+
+	/* share_page() can only guarantee proper page sharing if
+	 * the offsets are all page aligned. 
+	 */
+	if (offset & ~PAGE_MASK) {
+		return -EINVAL;
+	}
+	index = offset >> PAGE_CACHE_SHIFT;
 
 	if ((vma->vm_flags & VM_SHARED) && (vma->vm_flags & VM_MAYWRITE)) {
 		ops = &file_shared_mmap;
-		/* share_page() can only guarantee proper page sharing if
-		 * the offsets are all page aligned. */
-		if (vma->vm_offset & (PAGE_SIZE - 1))
-			return -EINVAL;
 	} else {
 		ops = &file_private_mmap;
-		if (vma->vm_offset & (PAGE_SIZE -1))
-			return -EINVAL;
 	}
 	if (!inode->i_sb || !S_ISREG(inode->i_mode))
 		return -EACCES;
 	if (!inode->i_op || !inode->i_op->readpage)
 		return -ENOEXEC;
 	UPDATE_ATIME(inode);
+	vma->vm_index = index;
 	vma->vm_ops = ops;
 	return 0;
 }
@@ -1437,8 +1478,8 @@
 {
 	struct dentry	*dentry = file->f_dentry; 
 	struct inode	*inode = dentry->d_inode; 
-	unsigned long	pos = *ppos;
-	unsigned long	limit = current->rlim[RLIMIT_FSIZE].rlim_cur;
+	loff_t pos = *ppos;
+	loff_t limit = current->rlim[RLIMIT_FSIZE].rlim_cur;
 	struct page	*page, **hash;
 	unsigned long	page_cache = 0;
 	unsigned long	written;
@@ -1459,6 +1500,11 @@
 	if (file->f_flags & O_APPEND)
 		pos = inode->i_size;
 
+	/* keep the limit in check */
+	if (limit > PAGE_MAX_FILE_OFFSET) {
+		limit = PAGE_MAX_FILE_OFFSET +1;
+	}
+
 	/*
 	 * Check whether we've reached the file size limit.
 	 */
@@ -1479,19 +1525,19 @@
 	}
 
 	while (count) {
-		unsigned long bytes, pgpos, offset;
+		unsigned long bytes, index, offset;
 		/*
 		 * Try to find the page in the cache. If it isn't there,
 		 * allocate a free page.
 		 */
 		offset = (pos & ~PAGE_CACHE_MASK);
-		pgpos = pos & PAGE_CACHE_MASK;
+		index = pos >> PAGE_CACHE_SHIFT;
 		bytes = PAGE_CACHE_SIZE - offset;
 		if (bytes > count)
 			bytes = count;
 
-		hash = page_hash(inode, pgpos);
-		page = __find_page(inode, pgpos, *hash);
+		hash = page_hash(inode, index);
+		page = __find_page(inode, index, *hash);
 		if (!page) {
 			if (!page_cache) {
 				page_cache = page_cache_alloc();
@@ -1501,7 +1547,7 @@
 				break;
 			}
 			page = page_cache_entry(page_cache);
-			add_to_page_cache(page, inode, pgpos, hash);
+			add_to_page_cache(page, inode, index, hash);
 			page_cache = 0;
 		}
 
@@ -1559,9 +1605,12 @@
 	struct page * page;
 	struct page ** hash;
 	unsigned long page_cache = 0;
+	unsigned long index;
+
+	index = offset >> PAGE_CACHE_SHIFT;
 
-	hash = page_hash(inode, offset);
-	page = __find_page(inode, offset, *hash);
+	hash = page_hash(inode, index);
+	page = __find_page(inode, index, *hash);
 	if (!page) {
 		if (!new)
 			goto out;
@@ -1570,7 +1619,7 @@
 			goto out;
 		clear_page(page_cache);
 		page = page_cache_entry(page_cache);
-		add_to_page_cache(page, inode, offset, hash);
+		add_to_page_cache(page, inode, index, hash);
 	}
 	if (atomic_read(&page->count) != 2)
 		printk(KERN_ERR "get_cached_page: page count=%d\n",
@@ -1625,7 +1674,7 @@
 /* Make a new page IO request and queue it to the kpiod thread */
 
 static inline void make_pio_request(struct file *file,
-				    unsigned long offset,
+				    unsigned long index,
 				    unsigned long page)
 {
 	struct pio_request *p;
@@ -1652,7 +1701,7 @@
 	}
 	
 	p->file   = file;
-	p->offset = offset;
+	p->index  = index;
 	p->page   = page;
 
 	put_pio_request(p);
@@ -1715,7 +1764,7 @@
 			
 			down(&inode->i_sem);
 			do_write_page(inode, p->file,
-				      (const char *) p->page, p->offset);
+				      (const char *) p->page, p->index);
 			up(&inode->i_sem);
 			fput(p->file);
 			page_cache_free(p->page);
diff -uNrX /home/eric/projects/linux/linux-ignore-files linux-2.3.3.eb4/mm/memory.c linux-2.3.3.eb5/mm/memory.c
--- linux-2.3.3.eb4/mm/memory.c	Sun May 16 21:52:58 1999
+++ linux-2.3.3.eb5/mm/memory.c	Sat May 22 17:16:55 1999
@@ -647,7 +647,7 @@
 	case 2:
 		if (!PageSwapCache(page_map))
 			break;
-		if (swap_count(page_map->offset) != 1)
+		if (swap_count(page_map->key) != 1)
 			break;
 		delete_from_swap_cache(page_map);
 		/* FallThrough */
@@ -733,13 +733,19 @@
  * between the file and the memory map for a potential last
  * incomplete page.  Ugly, but necessary.
  */
-void vmtruncate(struct inode * inode, unsigned long offset)
+void vmtruncate(struct inode * inode, loff_t offset)
 {
+	unsigned long index, trunk_index;
+	unsigned long partial;
 	struct vm_area_struct * mpnt;
 
 	truncate_inode_pages(inode, offset);
-	if (!inode->i_mmap)
+	if ((!inode->i_mmap) || (offset > PAGE_MAX_FILE_OFFSET)) {
 		return;
+	}
+	index = offset >> PAGE_CACHE_SHIFT;
+	partial = offset & PAGE_CACHE_MASK;
+	trunk_index = index + (partial)? 1 : 0;
 	mpnt = inode->i_mmap;
 	do {
 		struct mm_struct *mm = mpnt->vm_mm;
@@ -749,22 +755,22 @@
 		unsigned long diff;
 
 		/* mapping wholly truncated? */
-		if (mpnt->vm_offset >= offset) {
+		if ((mpnt->vm_index >> (PAGE_CACHE_SHIFT - PAGE_SHIFT)) >= trunk_index) {
 			flush_cache_range(mm, start, end);
 			zap_page_range(mm, start, len);
 			flush_tlb_range(mm, start, end);
 			continue;
 		}
 		/* mapping wholly unaffected? */
-		diff = offset - mpnt->vm_offset;
+		diff = ((index << PAGE_CACHE_SHIFT) - (mpnt->vm_index << PAGE_SHIFT)) + partial;
 		if (diff >= len)
 			continue;
 		/* Ok, partially affected.. */
 		start += diff;
-		len = (len - diff) & PAGE_MASK;
-		if (start & ~PAGE_MASK) {
+		len = (len - diff) & PAGE_CACHE_MASK;
+		if (start & ~PAGE_CACHE_MASK) {
 			partial_clear(mpnt, start);
-			start = (start + ~PAGE_MASK) & PAGE_MASK;
+			start = (start + ~PAGE_CACHE_MASK) & PAGE_CACHE_MASK;
 		}
 		flush_cache_range(mm, start, end);
 		zap_page_range(mm, start, len);
@@ -785,7 +791,9 @@
 		swap_in(tsk, vma, page_table, pte_val(entry), write_access);
 		flush_page_to_ram(pte_page(*page_table));
 	} else {
-		pte_t page = vma->vm_ops->swapin(vma, address - vma->vm_start + vma->vm_offset, pte_val(entry));
+		unsigned long index = ((address - vma->vm_start) >> PAGE_SHIFT)	
+			+ vma->vm_index;
+		pte_t page = vma->vm_ops->swapin(vma, index, pte_val(entry));
 		if (pte_val(*page_table) != pte_val(entry)) {
 			free_page(pte_page(page));
 		} else {
diff -uNrX /home/eric/projects/linux/linux-ignore-files linux-2.3.3.eb4/mm/mlock.c linux-2.3.3.eb5/mm/mlock.c
--- linux-2.3.3.eb4/mm/mlock.c	Sat May 22 16:10:25 1999
+++ linux-2.3.3.eb5/mm/mlock.c	Sat May 22 17:16:56 1999
@@ -28,7 +28,7 @@
 	*n = *vma;
 	vma->vm_start = end;
 	n->vm_end = end;
-	vma->vm_offset += vma->vm_start - n->vm_start;
+	vma->vm_index += (vma->vm_start - n->vm_start) >> PAGE_SHIFT;
 	n->vm_flags = newflags;
 	if (n->vm_file)
 		n->vm_file->f_count++;
@@ -42,14 +42,13 @@
 	unsigned long start, int newflags)
 {
 	struct vm_area_struct * n;
-
 	n = kmem_cache_alloc(vm_area_cachep, SLAB_KERNEL);
 	if (!n)
 		return -EAGAIN;
 	*n = *vma;
 	vma->vm_end = start;
 	n->vm_start = start;
-	n->vm_offset += n->vm_start - vma->vm_start;
+	n->vm_index += (n->vm_start - vma->vm_start) >> PAGE_SHIFT;
 	n->vm_flags = newflags;
 	if (n->vm_file)
 		n->vm_file->f_count++;
@@ -63,7 +62,6 @@
 	unsigned long start, unsigned long end, int newflags)
 {
 	struct vm_area_struct * left, * right;
-
 	left = kmem_cache_alloc(vm_area_cachep, SLAB_KERNEL);
 	if (!left)
 		return -EAGAIN;
@@ -78,8 +76,8 @@
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
diff -uNrX /home/eric/projects/linux/linux-ignore-files linux-2.3.3.eb4/mm/mmap.c linux-2.3.3.eb5/mm/mmap.c
--- linux-2.3.3.eb4/mm/mmap.c	Sun May 16 21:55:30 1999
+++ linux-2.3.3.eb5/mm/mmap.c	Sat May 22 17:16:56 1999
@@ -170,7 +170,7 @@
 }
 
 unsigned long do_mmap(struct file * file, unsigned long addr, unsigned long len,
-	unsigned long prot, unsigned long flags, unsigned long off)
+	unsigned long prot, unsigned long flags, loff_t off)
 {
 	struct mm_struct * mm = current->mm;
 	struct vm_area_struct * vma;
@@ -278,7 +278,7 @@
 		vma->vm_flags |= VM_MAYREAD | VM_MAYWRITE | VM_MAYEXEC;
 	vma->vm_page_prot = protection_map[vma->vm_flags & 0x0f];
 	vma->vm_ops = NULL;
-	vma->vm_offset = off;
+	vma->vm_index = 0;
 	vma->vm_file = NULL;
 	vma->vm_pte = 0;
 
@@ -313,7 +313,7 @@
 			file->f_dentry->d_inode->i_writecount--;
 			correct_wcount = 1;
 		}
-		error = file->f_op->mmap(file, vma);
+		error = file->f_op->mmap(file, vma, off);
 		/* Fix up the count if necessary, then check for an error */
 		if (correct_wcount)
 			file->f_dentry->d_inode->i_writecount++;
@@ -514,7 +514,7 @@
 	if (end == area->vm_end)
 		area->vm_end = addr;
 	else if (addr == area->vm_start) {
-		area->vm_offset += (end - area->vm_start);
+		area->vm_index += (end - area->vm_start) >> PAGE_SHIFT;
 		area->vm_start = end;
 	} else {
 	/* Unmapping a hole: area->vm_start < addr <= end < area->vm_end */
@@ -528,7 +528,7 @@
 		mpnt->vm_page_prot = area->vm_page_prot;
 		mpnt->vm_flags = area->vm_flags;
 		mpnt->vm_ops = area->vm_ops;
-		mpnt->vm_offset = area->vm_offset + (end - area->vm_start);
+		mpnt->vm_index = area->vm_index + ((end - area->vm_start) >> PAGE_SHIFT);
 		mpnt->vm_file = area->vm_file;
 		mpnt->vm_pte = area->vm_pte;
 		if (mpnt->vm_file)
@@ -830,8 +830,9 @@
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
 
@@ -844,7 +845,7 @@
 		prev->vm_end = mpnt->vm_end;
 		prev->vm_next = mpnt->vm_next;
 		if (mpnt->vm_ops && mpnt->vm_ops->close) {
-			mpnt->vm_offset += mpnt->vm_end - mpnt->vm_start;
+			mpnt->vm_index += (mpnt->vm_end - mpnt->vm_start) >> PAGE_SHIFT;
 			mpnt->vm_start = mpnt->vm_end;
 			mpnt->vm_ops->close(mpnt);
 		}
diff -uNrX /home/eric/projects/linux/linux-ignore-files linux-2.3.3.eb4/mm/mprotect.c linux-2.3.3.eb5/mm/mprotect.c
--- linux-2.3.3.eb4/mm/mprotect.c	Tue Feb  9 22:54:15 1999
+++ linux-2.3.3.eb5/mm/mprotect.c	Sat May 22 17:16:56 1999
@@ -99,7 +99,7 @@
 	*n = *vma;
 	vma->vm_start = end;
 	n->vm_end = end;
-	vma->vm_offset += vma->vm_start - n->vm_start;
+	vma->vm_index += (vma->vm_start - n->vm_start) >> PAGE_SHIFT;
 	n->vm_flags = newflags;
 	n->vm_page_prot = prot;
 	if (n->vm_file)
@@ -122,7 +122,7 @@
 	*n = *vma;
 	vma->vm_end = start;
 	n->vm_start = start;
-	n->vm_offset += n->vm_start - vma->vm_start;
+	n->vm_index += (n->vm_start - vma->vm_start) >> PAGE_SHIFT;
 	n->vm_flags = newflags;
 	n->vm_page_prot = prot;
 	if (n->vm_file)
@@ -138,6 +138,7 @@
 	int newflags, pgprot_t prot)
 {
 	struct vm_area_struct * left, * right;
+	unsigned long shift;
 
 	left = kmem_cache_alloc(vm_area_cachep, SLAB_KERNEL);
 	if (!left)
@@ -153,8 +154,8 @@
 	vma->vm_start = start;
 	vma->vm_end = end;
 	right->vm_start = end;
-	vma->vm_offset += vma->vm_start - left->vm_start;
-	right->vm_offset += right->vm_start - left->vm_start;
+	vma->vm_index += (vma->vm_start - left->vm_start) >> PAGE_SHIFT;
+	right->vm_index += (right->vm_start - left->vm_start) >> PAGE_SHIFT;
 	vma->vm_flags = newflags;
 	vma->vm_page_prot = prot;
 	if (vma->vm_file)
diff -uNrX /home/eric/projects/linux/linux-ignore-files linux-2.3.3.eb4/mm/mremap.c linux-2.3.3.eb5/mm/mremap.c
--- linux-2.3.3.eb4/mm/mremap.c	Tue Feb  9 22:54:15 1999
+++ linux-2.3.3.eb5/mm/mremap.c	Sat May 22 17:16:56 1999
@@ -133,7 +133,7 @@
 			*new_vma = *vma;
 			new_vma->vm_start = new_addr;
 			new_vma->vm_end = new_addr+new_len;
-			new_vma->vm_offset = vma->vm_offset + (addr - vma->vm_start);
+			new_vma->vm_index = vma->vm_index + ((addr - vma->vm_start) >> PAGE_SHIFT);
 			if (new_vma->vm_file)
 				new_vma->vm_file->f_count++;
 			if (new_vma->vm_ops && new_vma->vm_ops->open)
diff -uNrX /home/eric/projects/linux/linux-ignore-files linux-2.3.3.eb4/mm/page_io.c linux-2.3.3.eb5/mm/page_io.c
--- linux-2.3.3.eb4/mm/page_io.c	Sat May 22 16:10:03 1999
+++ linux-2.3.3.eb5/mm/page_io.c	Sat May 22 17:16:37 1999
@@ -99,7 +99,7 @@
 		 * as if it were: we are not allowed to manipulate the inode
 		 * hashing for locked pages.
 		 */
-		if (page->offset != entry) {
+		if (page->key != entry) {
 			printk ("swap entry mismatch");
 			return;
 		}
@@ -252,7 +252,7 @@
 		printk("VM: swap page is not in swap cache\n");
 		return;
 	}
-	if (page->offset != entry) {
+	if (page->key != entry) {
 		printk ("swap entry mismatch");
 		return;
 	}
@@ -279,7 +279,7 @@
 		return;
 	}
 	page->inode = &swapper_inode;
-	page->offset = entry;
+	page->key = entry;
 	atomic_inc(&page->count);	/* Protect from shrink_mmap() */
 	rw_swap_page(rw, entry, buffer, 1);
 	atomic_dec(&page->count);
diff -uNrX /home/eric/projects/linux/linux-ignore-files linux-2.3.3.eb4/mm/swap_state.c linux-2.3.3.eb5/mm/swap_state.c
--- linux-2.3.3.eb4/mm/swap_state.c	Tue Feb  9 22:59:11 1999
+++ linux-2.3.3.eb5/mm/swap_state.c	Sat May 22 17:16:37 1999
@@ -54,7 +54,7 @@
 	if (PageTestandSetSwapCache(page)) {
 		printk(KERN_ERR "swap_cache: replacing non-empty entry %08lx "
 		       "on page %08lx\n",
-		       page->offset, page_address(page));
+		       page->key, page_address(page));
 		return 0;
 	}
 	if (page->inode) {
@@ -64,7 +64,7 @@
 	}
 	atomic_inc(&page->count);
 	page->inode = &swapper_inode;
-	page->offset = entry;
+	page->key = entry;
 	add_page_to_hash_queue(page, &swapper_inode, entry);
 	add_page_to_inode_queue(&swapper_inode, page);
 	return 1;
@@ -203,7 +203,7 @@
  */
 void delete_from_swap_cache(struct page *page)
 {
-	long entry = page->offset;
+	long entry = page->key;
 
 #ifdef SWAP_CACHE_INFO
 	swap_cache_del_total++;
diff -uNrX /home/eric/projects/linux/linux-ignore-files linux-2.3.3.eb4/mm/vmscan.c linux-2.3.3.eb5/mm/vmscan.c
--- linux-2.3.3.eb4/mm/vmscan.c	Sun May 16 21:54:08 1999
+++ linux-2.3.3.eb5/mm/vmscan.c	Sat May 22 17:16:37 1999
@@ -71,7 +71,7 @@
 	 * memory, and we should just continue our scan.
 	 */
 	if (PageSwapCache(page_map)) {
-		entry = page_map->offset;
+		entry = page_map->key;
 		swap_duplicate(entry);
 		set_pte(page_table, __pte(entry));
 drop_pte:
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
