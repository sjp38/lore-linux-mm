Received: from mail.ccr.net (ccr@alogconduit1ag.ccr.net [208.130.159.7])
	by kvack.org (8.8.7/8.8.7) with ESMTP id MAA10420
	for <linux-mm@kvack.org>; Wed, 30 Dec 1998 12:18:07 -0500
Subject: Re: Large-File support of 32-bit Linux v0.01 available!
References: <19981227220446Z92289-18655+40@mea.tmt.tele.fi> <m1ww3d3wre.fsf@flinx.ccr.net>
From: ebiederm+eric@ccr.net (Eric W. Biederman)
Date: 30 Dec 1998 11:34:00 -0600
In-Reply-To: ebiederm+eric@ccr.net's message of "27 Dec 1998 19:01:25 -0600"
Message-ID: <m1iuetsfef.fsf@flinx.ccr.net>
Sender: owner-linux-mm@kvack.org
To: Matti Aarnio <matti.aarnio@sonera.fi>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>>>> "EB" == Eric W Biederman <ebiederm> writes:

>>>>> "MA" == Matti Aarnio <matti.aarnio@sonera.fi> writes:
>>> I have some other logic mostly complete that keeps offset parameter in
>>> the vm_area struct at 32 bits, and hopefully a greater chunck of the
>>> page cache.

Yeah.  I actually found/made time to work on this.
This is my patch for allowing large files in the page cache.
vm_offset is no more.  I am currently running it.

There is a little taken from Matti Aarnio (mostly syscalls, and filesystems
I don't usually compile).  But not much as I was my empahses was on stabalizing my code.

I was getting really frustrated and discoraged for a while when this wasn't
booting.  But my 2 or 3 tiny bugs looked to be ironed out.

My next round of work will add a struct vm_store which will replace inode
in the page cache, and allow full 64bit file sizes (by multiple vmstore's per inode)
and unaligned data in the page cache.   The file size limit will again be on inodes.
But the generic code (under the vfs) will not support unaligned data (and doesn't need to).

Then I plan to aim for writing code for one single dirty page write out mechanism.
One single clean page freeing mechanism.
One single page removal mechanism. 

And hopefully have it all ready for early 2.3

Matti.  I don't have access to the LFS spec, and that really isn't
where my interest lies, so I'll leave the syscalls to you.

Now I'm off on vacation for the rest of this week.  And probably won't
have time until the first weekend in January to really work anymore on this.

Eric

diff -uNrX linux-ignore-files linux-2.1.132.eb3/arch/alpha/kernel/ptrace.c linux-2.1.132.eb4/arch/alpha/kernel/ptrace.c
--- linux-2.1.132.eb3/arch/alpha/kernel/ptrace.c	Fri Dec 25 16:41:21 1998
+++ linux-2.1.132.eb4/arch/alpha/kernel/ptrace.c	Sat Dec 26 00:17:09 1998
@@ -261,7 +261,7 @@
 		return NULL;
 	if (vma->vm_end - addr > tsk->rlim[RLIMIT_STACK].rlim_cur)
 		return NULL;
-	vma->vm_offset -= vma->vm_start - addr;
+	vma->vm_index -= (vma->vm_start - addr) >> PAGE_SHIFT;
 	vma->vm_start = addr;
 	return vma;
 }
diff -uNrX linux-ignore-files linux-2.1.132.eb3/arch/arm/kernel/ptrace.c linux-2.1.132.eb4/arch/arm/kernel/ptrace.c
--- linux-2.1.132.eb3/arch/arm/kernel/ptrace.c	Sun Oct 11 13:16:22 1998
+++ linux-2.1.132.eb4/arch/arm/kernel/ptrace.c	Sat Dec 26 00:17:09 1998
@@ -178,7 +178,7 @@
 		return NULL;
 	if (vma->vm_end - addr > tsk->rlim[RLIMIT_STACK].rlim_cur)
 		return NULL;
-	vma->vm_offset -= vma->vm_start - addr;
+	vma->vm_index -= (vma->vm_start - addr) >> PAGE_SHIFT;
 	vma->vm_start = addr;
 	return vma;
 }
diff -uNrX linux-ignore-files linux-2.1.132.eb3/arch/i386/kernel/ptrace.c linux-2.1.132.eb4/arch/i386/kernel/ptrace.c
--- linux-2.1.132.eb3/arch/i386/kernel/ptrace.c	Fri Dec 25 16:43:37 1998
+++ linux-2.1.132.eb4/arch/i386/kernel/ptrace.c	Sat Dec 26 00:17:09 1998
@@ -186,7 +186,7 @@
 		return NULL;
 	if (vma->vm_end - addr > tsk->rlim[RLIMIT_STACK].rlim_cur)
 		return NULL;
-	vma->vm_offset -= vma->vm_start - addr;
+	vma->vm_index -= (vma->vm_start - addr) >> PAGE_SHIFT;
 	vma->vm_start = addr;
 	return vma;
 }
diff -uNrX linux-ignore-files linux-2.1.132.eb3/arch/m68k/kernel/ptrace.c linux-2.1.132.eb4/arch/m68k/kernel/ptrace.c
--- linux-2.1.132.eb3/arch/m68k/kernel/ptrace.c	Fri Dec 25 16:42:40 1998
+++ linux-2.1.132.eb4/arch/m68k/kernel/ptrace.c	Sat Dec 26 00:17:10 1998
@@ -210,7 +210,7 @@
 		return NULL;
 	if (vma->vm_end - addr > tsk->rlim[RLIMIT_STACK].rlim_cur)
 		return NULL;
-	vma->vm_offset -= vma->vm_start - addr;
+	vma->vm_index -= (vma->vm_start - addr) >> PAGE_SHIFT;
 	vma->vm_start = addr;
 	return vma;
 }
diff -uNrX linux-ignore-files linux-2.1.132.eb3/arch/mips/kernel/ptrace.c linux-2.1.132.eb4/arch/mips/kernel/ptrace.c
--- linux-2.1.132.eb3/arch/mips/kernel/ptrace.c	Fri Dec 25 16:41:24 1998
+++ linux-2.1.132.eb4/arch/mips/kernel/ptrace.c	Sat Dec 26 00:17:10 1998
@@ -157,7 +157,7 @@
 		return NULL;
 	if (vma->vm_end - addr > tsk->rlim[RLIMIT_STACK].rlim_cur)
 		return NULL;
-	vma->vm_offset -= vma->vm_start - addr;
+	vma->vm_index -= (vma->vm_start - addr) >> PAGE_SHIFT;
 	vma->vm_start = addr;
 	return vma;
 }
diff -uNrX linux-ignore-files linux-2.1.132.eb3/arch/ppc/kernel/ptrace.c linux-2.1.132.eb4/arch/ppc/kernel/ptrace.c
--- linux-2.1.132.eb3/arch/ppc/kernel/ptrace.c	Sun Oct 11 13:13:27 1998
+++ linux-2.1.132.eb4/arch/ppc/kernel/ptrace.c	Sat Dec 26 00:17:10 1998
@@ -204,7 +204,7 @@
 		return NULL;
 	if (vma->vm_end - addr > tsk->rlim[RLIMIT_STACK].rlim_cur)
 		return NULL;
-	vma->vm_offset -= vma->vm_start - addr;
+	vma->vm_index -= (vma->vm_start - addr) >> PAGE_SHIFT;
 	vma->vm_start = addr;
 	return vma;
 }
diff -uNrX linux-ignore-files linux-2.1.132.eb3/arch/sparc/kernel/ptrace.c linux-2.1.132.eb4/arch/sparc/kernel/ptrace.c
--- linux-2.1.132.eb3/arch/sparc/kernel/ptrace.c	Tue May 12 14:17:34 1998
+++ linux-2.1.132.eb4/arch/sparc/kernel/ptrace.c	Sat Dec 26 00:17:10 1998
@@ -149,7 +149,7 @@
 		return NULL;
 	if (vma->vm_end - addr > tsk->rlim[RLIMIT_STACK].rlim_cur)
 		return NULL;
-	vma->vm_offset -= vma->vm_start - addr;
+	vma->vm_index -= (vma->vm_start - addr) >> PAGE_SHIFT;
 	vma->vm_start = addr;
 	return vma;
 }
diff -uNrX linux-ignore-files linux-2.1.132.eb3/arch/sparc64/kernel/ptrace.c linux-2.1.132.eb4/arch/sparc64/kernel/ptrace.c
--- linux-2.1.132.eb3/arch/sparc64/kernel/ptrace.c	Fri Dec 25 16:42:01 1998
+++ linux-2.1.132.eb4/arch/sparc64/kernel/ptrace.c	Sat Dec 26 02:13:32 1998
@@ -219,7 +219,7 @@
 		return NULL;
 	if (vma->vm_end - addr > tsk->rlim[RLIMIT_STACK].rlim_cur)
 		return NULL;
-	vma->vm_offset -= vma->vm_start - addr;
+	vma->vm_index -= (vma->vm_start - addr) >> PAGE_SHIFT;
 	vma->vm_start = addr;
 	return vma;
 }
diff -uNrX linux-ignore-files linux-2.1.132.eb3/drivers/block/loop.c linux-2.1.132.eb4/drivers/block/loop.c
--- linux-2.1.132.eb3/drivers/block/loop.c	Fri Dec 25 16:43:38 1998
+++ linux-2.1.132.eb4/drivers/block/loop.c	Sat Dec 26 00:17:10 1998
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
diff -uNrX linux-ignore-files linux-2.1.132.eb3/drivers/char/ftape/lowlevel/ftape-ctl.c linux-2.1.132.eb4/drivers/char/ftape/lowlevel/ftape-ctl.c
--- linux-2.1.132.eb3/drivers/char/ftape/lowlevel/ftape-ctl.c	Fri Mar 20 17:12:03 1998
+++ linux-2.1.132.eb4/drivers/char/ftape/lowlevel/ftape-ctl.c	Sun Dec 27 23:21:40 1998
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
diff -uNrX linux-ignore-files linux-2.1.132.eb3/drivers/char/mem.c linux-2.1.132.eb4/drivers/char/mem.c
--- linux-2.1.132.eb3/drivers/char/mem.c	Fri Dec 25 16:44:21 1998
+++ linux-2.1.132.eb4/drivers/char/mem.c	Sun Dec 27 21:17:44 1998
@@ -138,10 +138,17 @@
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
+	if ((offset + (vma->vm_end - vma->vm_start)) > PAGE_MAX_MEMORY_OFFSET) {
+		return -EINVAL;
+	}
+	vma->vm_index = offset >> PAGE_SHIFT;
 	if (offset & ~PAGE_MASK)
 		return -ENXIO;
 #if defined(__i386__)
@@ -365,7 +372,7 @@
 	return written ? written : -EFAULT;
 }
 
-static int mmap_zero(struct file * file, struct vm_area_struct * vma)
+static int mmap_zero(struct file * file, struct vm_area_struct * vma, loff_t offset)
 {
 	if (vma->vm_flags & VM_SHARED)
 		return -EINVAL;
diff -uNrX linux-ignore-files linux-2.1.132.eb3/drivers/sgi/char/graphics.c linux-2.1.132.eb4/drivers/sgi/char/graphics.c
--- linux-2.1.132.eb3/drivers/sgi/char/graphics.c	Sun Oct 11 13:15:06 1998
+++ linux-2.1.132.eb4/drivers/sgi/char/graphics.c	Sun Dec 27 21:24:18 1998
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
 	
diff -uNrX linux-ignore-files linux-2.1.132.eb3/drivers/sound/soundcard.c linux-2.1.132.eb4/drivers/sound/soundcard.c
--- linux-2.1.132.eb3/drivers/sound/soundcard.c	Fri Dec 25 16:44:36 1998
+++ linux-2.1.132.eb4/drivers/sound/soundcard.c	Sat Dec 26 00:17:10 1998
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
@@ -756,6 +756,7 @@
 		return -EAGAIN;
 
 	vma->vm_file = file;
+	vma->vm_index = 0;
 	file->f_count++;
 
 	dmap->mapping_flags |= DMA_MAP_MAPPED;
diff -uNrX linux-ignore-files linux-2.1.132.eb3/fs/adfs/inode.c linux-2.1.132.eb4/fs/adfs/inode.c
--- linux-2.1.132.eb3/fs/adfs/inode.c	Fri Mar 20 17:13:03 1998
+++ linux-2.1.132.eb4/fs/adfs/inode.c	Tue Dec 29 23:20:54 1998
@@ -167,7 +167,7 @@
 		inode->i_nlink	 = 2;
 		inode->i_size	 = ADFS_NEWDIR_SIZE;
 		inode->i_blksize = PAGE_SIZE;
-		inode->i_blocks  = inode->i_size / sb->s_blocksize;
+		inode->i_blocks  = inode->i_size >> sb->s_blocksize_bits;
 		inode->i_mtime   =
 		inode->i_atime   =
 		inode->i_ctime   = 0;
diff -uNrX linux-ignore-files linux-2.1.132.eb3/fs/affs/file.c linux-2.1.132.eb4/fs/affs/file.c
--- linux-2.1.132.eb3/fs/affs/file.c	Sun Oct 11 13:15:09 1998
+++ linux-2.1.132.eb4/fs/affs/file.c	Tue Dec 29 23:36:30 1998
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
diff -uNrX linux-ignore-files linux-2.1.132.eb3/fs/affs/inode.c linux-2.1.132.eb4/fs/affs/inode.c
--- linux-2.1.132.eb3/fs/affs/inode.c	Fri Dec 25 16:44:41 1998
+++ linux-2.1.132.eb4/fs/affs/inode.c	Tue Dec 29 23:37:16 1998
@@ -147,7 +147,7 @@
 				block = AFFS_I2BSIZE(inode) - 24;
 			else
 				block = AFFS_I2BSIZE(inode);
-			inode->u.affs_i.i_lastblock = ((inode->i_size + block - 1) / block) - 1;
+			inode->u.affs_i.i_lastblock = (((unsigned long)inode->i_size + block - 1) / block) - 1;
 			break;
 		case ST_SOFTLINK:
 			inode->i_mode |= S_IFLNK;
diff -uNrX linux-ignore-files linux-2.1.132.eb3/fs/buffer.c linux-2.1.132.eb4/fs/buffer.c
--- linux-2.1.132.eb3/fs/buffer.c	Fri Dec 25 16:48:50 1998
+++ linux-2.1.132.eb4/fs/buffer.c	Sat Dec 26 02:08:55 1998
@@ -1337,7 +1337,7 @@
 #endif
 	}
 	if (test_and_clear_bit(PG_swap_unlock_after, &page->flags))
-		swap_after_unlock_page(page->offset);
+		swap_after_unlock_page(page->key);
 	if (test_and_clear_bit(PG_free_after, &page->flags))
 		__free_page(page);
 }
@@ -1561,7 +1561,7 @@
 	set_bit(PG_free_after, &page->flags);
 	
 	i = PAGE_SIZE >> inode->i_sb->s_blocksize_bits;
-	block = page->offset >> inode->i_sb->s_blocksize_bits;
+	block = page->key << (PAGE_SHIFT - inode->i_sb->s_blocksize_bits);
 	p = nr;
 	do {
 		*p = inode->i_op->bmap(inode, block);
diff -uNrX linux-ignore-files linux-2.1.132.eb3/fs/coda/file.c linux-2.1.132.eb4/fs/coda/file.c
--- linux-2.1.132.eb3/fs/coda/file.c	Sun Oct 11 13:15:50 1998
+++ linux-2.1.132.eb4/fs/coda/file.c	Sat Dec 26 00:17:10 1998
@@ -98,8 +98,8 @@
         coda_prepare_openfile(coda_inode, coda_file, cii->c_ovp,
 			      &cont_file, &cont_dentry);
 
-        CDEBUG(D_INODE, "coda ino: %ld, cached ino %ld, page offset: %lx\n", 
-	       coda_inode->i_ino, cii->c_ovp->i_ino, page->offset);
+        CDEBUG(D_INODE, "coda ino: %ld, cached ino %ld, page key: %lx\n", 
+	       coda_inode->i_ino, cii->c_ovp->i_ino, page->key);
 
         generic_readpage(&cont_file, page);
         EXIT;
diff -uNrX linux-ignore-files linux-2.1.132.eb3/fs/exec.c linux-2.1.132.eb4/fs/exec.c
--- linux-2.1.132.eb3/fs/exec.c	Fri Dec 25 16:43:18 1998
+++ linux-2.1.132.eb4/fs/exec.c	Sat Dec 26 00:17:10 1998
@@ -315,7 +315,7 @@
 		mpnt->vm_page_prot = PAGE_COPY;
 		mpnt->vm_flags = VM_STACK_FLAGS;
 		mpnt->vm_ops = NULL;
-		mpnt->vm_offset = 0;
+		mpnt->vm_index = 0;
 		mpnt->vm_file = NULL;
 		mpnt->vm_pte = 0;
 		insert_vm_struct(current->mm, mpnt);
diff -uNrX linux-ignore-files linux-2.1.132.eb3/fs/ext2/truncate.c linux-2.1.132.eb4/fs/ext2/truncate.c
--- linux-2.1.132.eb3/fs/ext2/truncate.c	Sun Oct 11 13:18:54 1998
+++ linux-2.1.132.eb4/fs/ext2/truncate.c	Sat Dec 26 00:17:10 1998
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
diff -uNrX linux-ignore-files linux-2.1.132.eb3/fs/fat/mmap.c linux-2.1.132.eb4/fs/fat/mmap.c
--- linux-2.1.132.eb3/fs/fat/mmap.c	Fri Dec 25 16:42:20 1998
+++ linux-2.1.132.eb4/fs/fat/mmap.c	Sun Dec 27 21:37:34 1998
@@ -42,7 +42,7 @@
 	if (!page)
 		return page;
 	address &= PAGE_MASK;
-	pos = address - area->vm_start + area->vm_offset;
+	pos = address - area->vm_start + (area->vm_index << PAGE_SHIFT);
 
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
+	if (offset > ((u32) -1)) || ((loffset + (vma->vm_end - vma->vm_start)) > ((u32) -1))) {
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
@@ -113,6 +119,7 @@
 		mark_inode_dirty(inode);
 	}
 
+	vma->vm_index = offset >> PAGE_SHIFT;
 	vma->vm_file = file;
 	file->f_count++;
 	vma->vm_ops = &fat_file_mmap;
diff -uNrX linux-ignore-files linux-2.1.132.eb3/fs/isofs/inode.c linux-2.1.132.eb4/fs/isofs/inode.c
--- linux-2.1.132.eb3/fs/isofs/inode.c	Sun Oct 11 13:17:25 1998
+++ linux-2.1.132.eb4/fs/isofs/inode.c	Wed Dec 30 09:22:01 1998
@@ -904,7 +904,7 @@
 	    if( b_off >= max_legal_read_offset )
 	      {
 
-		printk("_isofs_bmap: block>= EOF(%d, %ld)\n", block,
+		printk("_isofs_bmap: block>= EOF(%d, %Ld)\n", block,
 		       inode->i_size);
 	      }
 	    return 0;
@@ -1143,7 +1143,7 @@
 #endif
 
 #ifdef DEBUG
-	printk("Get inode %x: %d %d: %d\n",inode->i_ino, block,
+	printk("Get inode %x: %d %d: %Ld\n",inode->i_ino, block,
 	       ((int)pnt) & 0x3ff, inode->i_size);
 #endif
 
diff -uNrX linux-ignore-files linux-2.1.132.eb3/fs/ncpfs/mmap.c linux-2.1.132.eb4/fs/ncpfs/mmap.c
--- linux-2.1.132.eb3/fs/ncpfs/mmap.c	Fri Mar 20 17:15:45 1998
+++ linux-2.1.132.eb4/fs/ncpfs/mmap.c	Sun Dec 27 21:46:44 1998
@@ -47,7 +47,7 @@
 	if (!page)
 		return page;
 	address &= PAGE_MASK;
-	pos = address - area->vm_start + area->vm_offset;
+	pos = address - area->vm_start + (area->vm_index << PAGE_SIZE);
 
 	clear = 0;
 	if (address + PAGE_SIZE > area->vm_end) {
@@ -119,15 +119,28 @@
 
 
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
@@ -137,6 +150,7 @@
 		inode->i_atime = CURRENT_TIME;
 	}
 
+	vma->vm_index = offset >> PAGE_SHIFT;
 	vma->vm_file = file;
 	file->f_count++;
 	vma->vm_ops = &ncp_file_mmap;
diff -uNrX linux-ignore-files linux-2.1.132.eb3/fs/nfs/read.c linux-2.1.132.eb4/fs/nfs/read.c
--- linux-2.1.132.eb3/fs/nfs/read.c	Fri Dec 25 16:44:46 1998
+++ linux-2.1.132.eb4/fs/nfs/read.c	Sat Dec 26 01:58:50 1998
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
 	int		error;
 
 	dprintk("NFS: nfs_readpage (%p %ld@%ld)\n",
-		page, PAGE_SIZE, page->offset);
+		page, PAGE_SIZE, page->key << PAGE_SIZE);
 	atomic_inc(&page->count);
 	set_bit(PG_locked, &page->flags);
 
diff -uNrX linux-ignore-files linux-2.1.132.eb3/fs/nfs/write.c linux-2.1.132.eb4/fs/nfs/write.c
--- linux-2.1.132.eb3/fs/nfs/write.c	Fri Dec 25 16:44:46 1998
+++ linux-2.1.132.eb4/fs/nfs/write.c	Sat Dec 26 02:03:29 1998
@@ -94,10 +94,10 @@
 
 	dprintk("NFS:      nfs_writepage_sync(%s/%s %d@%ld)\n",
 		dentry->d_parent->d_name.name, dentry->d_name.name,
-		count, page->offset + offset);
+		count, (page->key << PAGE_SHIFT) + offset);
 
 	buffer = (u8 *) page_address(page) + offset;
-	offset += page->offset;
+	offset += page->key << PAGE_SHIFT;
 
 	do {
 		if (count < wsize && !IS_SWAPFILE(inode))
@@ -284,7 +284,7 @@
 
 	dprintk("NFS:      create_write_request(%s/%s, %ld+%d)\n",
 		dentry->d_parent->d_name.name, dentry->d_name.name,
-		page->offset + offset, bytes);
+		(page->key << PAGE_SHIFT) + offset, bytes);
 
 	/* FIXME: Enforce hard limit on number of concurrent writes? */
 	wreq = (struct nfs_wreq *) kmalloc(sizeof(*wreq), GFP_KERNEL);
@@ -426,7 +426,7 @@
 
 	dprintk("NFS:      nfs_updatepage(%s/%s %d@%ld, sync=%d)\n",
 		dentry->d_parent->d_name.name, dentry->d_name.name,
-		count, page->offset+offset, sync);
+		count, (page->key << PAGE_SHIFT)+offset, sync);
 
 	/*
 	 * Try to find a corresponding request on the writeback queue.
@@ -592,7 +592,7 @@
 nfs_flush_trunc(struct inode *inode, unsigned long from)
 {
 	from &= PAGE_MASK;
-	NFS_WB(inode, req->wb_page->offset >= from);
+	NFS_WB(inode, (req->wb_page->key << PAGE_SHIFT) >= from);
 }
 
 void
@@ -633,7 +633,7 @@
 	/* Setup the task struct for a writeback call */
 	req->wb_flags |= NFS_WRITE_INPROGRESS;
 	req->wb_args.fh     = NFS_FH(dentry);
-	req->wb_args.offset = page->offset + req->wb_offset;
+	req->wb_args.offset = (page->key << PAGE_SHIFT) + req->wb_offset;
 	req->wb_args.count  = req->wb_bytes;
 	req->wb_args.buffer = (void *) (page_address(page) + req->wb_offset);
 
diff -uNrX linux-ignore-files linux-2.1.132.eb3/fs/open.c linux-2.1.132.eb4/fs/open.c
--- linux-2.1.132.eb3/fs/open.c	Fri Dec 25 16:43:59 1998
+++ linux-2.1.132.eb4/fs/open.c	Tue Dec 29 23:41:43 1998
@@ -67,7 +67,7 @@
 	return error;
 }
 
-int do_truncate(struct dentry *dentry, unsigned long length)
+int do_truncate(struct dentry *dentry, loff_t length)
 {
 	struct inode *inode = dentry->d_inode;
 	int error;
diff -uNrX linux-ignore-files linux-2.1.132.eb3/fs/proc/array.c linux-2.1.132.eb4/fs/proc/array.c
--- linux-2.1.132.eb3/fs/proc/array.c	Fri Dec 25 16:44:47 1998
+++ linux-2.1.132.eb4/fs/proc/array.c	Sun Dec 27 22:55:00 1998
@@ -1081,8 +1081,8 @@
  *         + (index into the line)
  */
 /* for systems with sizeof(void*) == 4: */
-#define MAPS_LINE_FORMAT4	  "%08lx-%08lx %s %08lx %s %lu"
-#define MAPS_LINE_MAX4	49 /* sum of 8  1  8  1 4 1 8 1 5 1 10 1 */
+#define MAPS_LINE_FORMAT4	  "%08lx-%08lx %s %016Lx %s %lu"
+#define MAPS_LINE_MAX4	57 /* sum of 8  1  8  1 4 1 16 1 5 1 10 1 */
 
 /* for systems with sizeof(void*) == 8: */
 #define MAPS_LINE_FORMAT8	  "%016lx-%016lx %s %016lx %s %lu"
@@ -1169,7 +1169,8 @@
 
 		len = sprintf(line,
 			      sizeof(void*) == 4 ? MAPS_LINE_FORMAT4 : MAPS_LINE_FORMAT8,
-			      map->vm_start, map->vm_end, str, map->vm_offset,
+			      map->vm_start, map->vm_end, str, 
+			      ((loff_t)map->vm_index) << PAGE_SHIFT,
 			      kdevname(dev), ino);
 
 		if(map->vm_file) {
diff -uNrX linux-ignore-files linux-2.1.132.eb3/fs/proc/mem.c linux-2.1.132.eb4/fs/proc/mem.c
--- linux-2.1.132.eb3/fs/proc/mem.c	Sun Oct 11 13:17:26 1998
+++ linux-2.1.132.eb4/fs/proc/mem.c	Sun Dec 27 22:57:30 1998
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
 
@@ -231,9 +232,15 @@
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
+	while (stmp < ((vma->vm_index << PAGE_SHIFT) + (vma->vm_end - vma->vm_start))) {
 		while (src_vma && stmp > src_vma->vm_end)
 			src_vma = src_vma->vm_next;
 		if (!src_vma || (src_vma->vm_flags & VM_SHM))
@@ -267,7 +274,7 @@
 	}
 
 	src_vma = tsk->mm->mmap;
-	stmp    = vma->vm_offset;
+	stmp    = vma->vm_index << PAGE_SHIFT;
 	dtmp    = vma->vm_start;
 
 	flush_cache_range(vma->vm_mm, vma->vm_start, vma->vm_end);
diff -uNrX linux-ignore-files linux-2.1.132.eb3/fs/romfs/inode.c linux-2.1.132.eb4/fs/romfs/inode.c
--- linux-2.1.132.eb3/fs/romfs/inode.c	Sun Oct 11 13:17:26 1998
+++ linux-2.1.132.eb4/fs/romfs/inode.c	Sat Dec 26 00:17:11 1998
@@ -402,7 +402,7 @@
 	buf = page_address(page);
 	clear_bit(PG_uptodate, &page->flags);
 	clear_bit(PG_error, &page->flags);
-	offset = page->offset;
+	offset = page->key << PAGE_SHIFT;
 	if (offset < inode->i_size) {
 		avail = inode->i_size-offset;
 		readlen = min(avail, PAGE_SIZE);
diff -uNrX linux-ignore-files linux-2.1.132.eb3/fs/smbfs/file.c linux-2.1.132.eb4/fs/smbfs/file.c
--- linux-2.1.132.eb3/fs/smbfs/file.c	Fri Dec 25 16:42:48 1998
+++ linux-2.1.132.eb4/fs/smbfs/file.c	Sat Dec 26 00:17:11 1998
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
@@ -201,7 +201,7 @@
 
 	pr_debug("SMBFS: smb_updatepage(%s/%s %d@%ld, sync=%d)\n",
 		dentry->d_parent->d_name.name, dentry->d_name.name,
-	 	count, page->offset+offset, sync);
+	 	count, (page->key << PAGE_SHIFT)+offset, sync);
 
 	return smb_writepage_sync(dentry, page, offset, count);
 }
diff -uNrX linux-ignore-files linux-2.1.132.eb3/fs/stat.c linux-2.1.132.eb4/fs/stat.c
--- linux-2.1.132.eb3/fs/stat.c	Fri Dec 25 16:43:20 1998
+++ linux-2.1.132.eb4/fs/stat.c	Mon Dec 28 21:25:45 1998
@@ -23,13 +23,24 @@
 	return 0;
 }
 
+#define CHECK_COPY(A, B) \
+do { \
+	typeof(A) mask = -1; \
+	typeof(B) masked_b, b; \
+	b = B; \
+	masked_b = mask & b; \
+	if (masked_b != b) { \
+		return -EOVERFLOW; \
+	} \
+	A = b; \
+} while (0)
 
-#if !defined(__alpha__) && !defined(__sparc__)
-
+#ifdef NEED_OLD_STAT
 /*
  * For backward compatibility?  Maybe this should be moved
  * into arch/i386 instead?
  */
+
 static int cp_old_stat(struct inode * inode, struct __old_kernel_stat * statbuf)
 {
 	static int warncount = 5;
@@ -41,39 +52,23 @@
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
 
-#endif
+#endif /* NEED_OLD_STAT */
 
-static int cp_new_stat(struct inode * inode, struct stat * statbuf)
-{
-	struct stat tmp;
-	unsigned int blocks, indirect;
-
-	memset(&tmp, 0, sizeof(tmp));
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
+#if defined(NEED_NEW_STAT) || defined(NEED_STAT64)
 /*
  * st_blocks and st_blksize are approximated with a simple algorithm if
  * they aren't supported directly by the filesystem. The minix and msdos
@@ -92,29 +87,85 @@
 #define D_B   7
 #define I_B   (BLOCK_SIZE / sizeof(unsigned short))
 
-	if (!inode->i_blksize) {
-		blocks = (tmp.st_size + BLOCK_SIZE - 1) / BLOCK_SIZE;
-		if (blocks > D_B) {
-			indirect = (blocks - D_B + I_B - 1) / I_B;
+static unsigned int guess_blocks(unsigned int st_size)
+{
+	unsigned int blocks, indirect;
+	blocks = (st_size + BLOCK_SIZE - 1) / BLOCK_SIZE;
+	if (blocks > D_B) {
+		indirect = (blocks - D_B + I_B - 1) / I_B;
+		blocks += indirect;
+		if (indirect > 1) {
+			indirect = (indirect - 1 + I_B - 1) / I_B;
 			blocks += indirect;
-			if (indirect > 1) {
-				indirect = (indirect - 1 + I_B - 1) / I_B;
-				blocks += indirect;
-				if (indirect > 1)
-					blocks++;
-			}
+			if (indirect > 1)
+				blocks++;
 		}
-		tmp.st_blocks = (BLOCK_SIZE / 512) * blocks;
-		tmp.st_blksize = BLOCK_SIZE;
+	}
+	return (BLOCK_SIZE / 512) * blocks;
+}
+#endif
+
+#ifdef NEED_NEW_STAT
+static int cp_new_stat(struct inode * inode, struct stat * statbuf)
+{
+	struct stat tmp;
+
+	memset(&tmp, 0, sizeof(tmp));
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
+
+	/* If the filesystem doesn't compute the # of blocks guess */
+	if (!inode->i_blksize) {
+		CHECK_COPY(tmp.st_blocks, guess_blocks(tmp.st_size));
+		CHECK_COPY(tmp.st_blksize, BLOCK_SIZE);
 	} else {
-		tmp.st_blocks = inode->i_blocks;
-		tmp.st_blksize = inode->i_blksize;
+		CHECK_COPY(tmp.st_blocks, inode->i_blocks);
+		CHECK_COPY(tmp.st_blksize, inode->i_blksize);
 	}
 	return copy_to_user(statbuf,&tmp,sizeof(tmp)) ? -EFAULT : 0;
 }
+#endif /* NEED_NEW_STAT */
+
+#ifdef NEED_STAT64
+static int cp_stat64(struct inode * inode, struct stat64 * statbuf)
+{
+	struct stat64 tmp;
 
+	memset(&tmp, 0, sizeof(tmp));
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
 
-#if !defined(__alpha__) && !defined(__sparc__)
+	/* If the filesystem doesn't compute the # of blocks guess */
+	if (!inode->i_blksize) {
+		CHECK_COPY(tmp.st_blocks, guess_blocks(tmp.st_size));
+		CHECK_COPY(tmp.st_blksize, BLOCK_SIZE);
+	} else {
+		CHECK_COPY(tmp.st_blocks, inode->i_blocks);
+		CHECK_COPY(tmp.st_blksize, inode->i_blksize);
+	}
+	return copy_to_user(statbuf,&tmp,sizeof(tmp)) ? -EFAULT : 0;
+}
+#endif /* NEED_STAT64 */
+
+#ifdef NEED_OLD_STAT
 /*
  * For backward compatibility?  Maybe this should be moved
  * into arch/i386 instead?
@@ -138,8 +189,9 @@
 	unlock_kernel();
 	return error;
 }
-#endif
+#endif /* NEED_OLD_STAT */
 
+#ifdef NEED_NEW_STAT 
 asmlinkage int sys_newstat(char * filename, struct stat * statbuf)
 {
 	struct dentry * dentry;
@@ -159,8 +211,31 @@
 	unlock_kernel();
 	return error;
 }
+#endif /* NEED_NEW_STAT */
 
-#if !defined(__alpha__) && !defined(__sparc__)
+#ifdef NEED_STAT64
+asmlinkage int sys_stat64(char * filename, struct stat64 * statbuf)
+{
+	struct dentry * dentry;
+	int error;
+
+	lock_kernel();
+	dentry = namei(filename);
+
+	error = PTR_ERR(dentry);
+	if (!IS_ERR(dentry)) {
+		error = do_revalidate(dentry);
+		if (!error)
+			error = cp_stat64(dentry->d_inode, statbuf);
+
+		dput(dentry);
+	}
+	unlock_kernel();
+	return error;
+}
+#endif /* NEED_STAT64 */
+
+#ifdef NEED_OLD_STAT 
 
 /*
  * For backward compatibility?  Maybe this should be moved
@@ -186,8 +261,9 @@
 	return error;
 }
 
-#endif
+#endif /* NEED_OLD_STAT */
 
+#ifdef NEED_NEW_STAT
 asmlinkage int sys_newlstat(char * filename, struct stat * statbuf)
 {
 	struct dentry * dentry;
@@ -207,9 +283,31 @@
 	unlock_kernel();
 	return error;
 }
+#endif /* NEED_NEW_STAT */
+
+#ifdef NEED_STAT64
+asmlinkage int sys_lstat64(char * filename, struct stat64 * statbuf)
+{
+	struct dentry * dentry;
+	int error;
 
-#if !defined(__alpha__) && !defined(__sparc__)
+	lock_kernel();
+	dentry = lnamei(filename);
 
+	error = PTR_ERR(dentry);
+	if (!IS_ERR(dentry)) {
+		error = do_revalidate(dentry);
+		if (!error)
+			error = cp_stat64(dentry->d_inode, statbuf);
+
+		dput(dentry);
+	}
+	unlock_kernel();
+	return error;
+}
+#endif /* NEED_STAT64 */
+
+#ifdef NEED_OLD_STAT 
 /*
  * For backward compatibility?  Maybe this should be moved
  * into arch/i386 instead?
@@ -233,8 +331,9 @@
 	return err;
 }
 
-#endif
+#endif /* NEED_OLD_STAT */
 
+#ifdef NEED_NEW_STAT
 asmlinkage int sys_newfstat(unsigned int fd, struct stat * statbuf)
 {
 	struct file * f;
@@ -253,6 +352,28 @@
 	unlock_kernel();
 	return err;
 }
+#endif /* NEED_NEW_STAT */
+
+#ifdef NEED_STAT64
+asmlinkage int sys_fstat64(unsigned int fd, struct stat64 * statbuf)
+{
+	struct file * f;
+	int err = -EBADF;
+
+	lock_kernel();
+	f = fget(fd);
+	if (f) {
+		struct dentry * dentry = f->f_dentry;
+
+		err = do_revalidate(dentry);
+		if (!err)
+			err = cp_stat64(dentry->d_inode, statbuf);
+		fput(f);
+	}
+	unlock_kernel();
+	return err;
+}
+#endif /* NEED_STAT64 */
 
 asmlinkage int sys_readlink(const char * path, char * buf, int bufsiz)
 {
diff -uNrX linux-ignore-files linux-2.1.132.eb3/include/asm-alpha/stat.h linux-2.1.132.eb4/include/asm-alpha/stat.h
--- linux-2.1.132.eb3/include/asm-alpha/stat.h	Mon Sep 30 09:42:43 1996
+++ linux-2.1.132.eb4/include/asm-alpha/stat.h	Mon Dec 28 21:18:23 1998
@@ -1,24 +1,6 @@
 #ifndef _ALPHA_STAT_H
 #define _ALPHA_STAT_H
 
-struct __old_kernel_stat {
-	unsigned int	st_dev;
-	unsigned int	st_ino;
-	unsigned int	st_mode;
-	unsigned int	st_nlink;
-	unsigned int	st_uid;
-	unsigned int	st_gid;
-	unsigned int	st_rdev;
-	long		st_size;
-	unsigned long	st_atime;
-	unsigned long	st_mtime;
-	unsigned long	st_ctime;
-	unsigned int	st_blksize;
-	int		st_blocks;
-	unsigned int	st_flags;
-	unsigned int	st_gen;
-};
-
 struct stat {
 	unsigned int	st_dev;
 	unsigned int	st_ino;
@@ -36,5 +18,7 @@
 	unsigned int	st_flags;
 	unsigned int	st_gen;
 };
+
+#define NEED_NEW_STAT
 
 #endif
diff -uNrX linux-ignore-files linux-2.1.132.eb3/include/asm-arm/stat.h linux-2.1.132.eb4/include/asm-arm/stat.h
--- linux-2.1.132.eb3/include/asm-arm/stat.h	Sun Oct 11 13:13:47 1998
+++ linux-2.1.132.eb4/include/asm-arm/stat.h	Mon Dec 28 21:19:04 1998
@@ -38,4 +38,6 @@
 	unsigned long  __unused5;
 };
 
+#define NEED_OLD_STAT
+#define NEED_NEW_STAT
 #endif
diff -uNrX linux-ignore-files linux-2.1.132.eb3/include/asm-i386/stat.h linux-2.1.132.eb4/include/asm-i386/stat.h
--- linux-2.1.132.eb3/include/asm-i386/stat.h	Mon Sep 30 09:42:31 1996
+++ linux-2.1.132.eb4/include/asm-i386/stat.h	Sat Dec 26 13:00:40 1998
@@ -38,4 +38,35 @@
 	unsigned long  __unused5;
 };
 
+struct stat64 {
+	unsigned long long st_ino;
+	unsigned long long st_size;
+	unsigned long long st_blocks;
+	unsigned short st_dev;
+	unsigned short __pad1;
+	unsigned short st_rdev;
+	unsigned short __pad2;
+	unsigned short st_mode;
+	unsigned short __unused1;
+	unsigned short st_nlink;
+	unsigned short __unused2;
+	unsigned short st_uid;
+	unsigned short __unused3;
+	unsigned short st_gid;
+	unsigned short __unused4;
+	unsigned long  st_blksize;
+	unsigned long  st_atime;
+	unsigned long  __unused5;
+	unsigned long  st_mtime;
+	unsigned long  __unused6;
+	unsigned long  st_ctime;
+	unsigned long  __unused7;
+	unsigned long  __unused8;
+	unsigned long  __unused9;
+};
+
+#define NEED_OLD_STAT
+#define NEED_NEW_STAT
+#define NEED_STAT64
+
 #endif
diff -uNrX linux-ignore-files linux-2.1.132.eb3/include/asm-m68k/stat.h linux-2.1.132.eb4/include/asm-m68k/stat.h
--- linux-2.1.132.eb3/include/asm-m68k/stat.h	Sun Oct 11 13:18:55 1998
+++ linux-2.1.132.eb4/include/asm-m68k/stat.h	Mon Dec 28 21:19:44 1998
@@ -38,4 +38,7 @@
 	unsigned long  __unused5;
 };
 
+#define NEED_OLD_STAT
+#define NEED_NEW_STAT
+
 #endif /* _M68K_STAT_H */
diff -uNrX linux-ignore-files linux-2.1.132.eb3/include/asm-mips/stat.h linux-2.1.132.eb4/include/asm-mips/stat.h
--- linux-2.1.132.eb3/include/asm-mips/stat.h	Thu Jun 26 14:33:40 1997
+++ linux-2.1.132.eb4/include/asm-mips/stat.h	Mon Dec 28 21:21:55 1998
@@ -52,4 +52,7 @@
 	unsigned int	st_gen;
 };
 
+#define NEED_OLD_STAT
+#define NEED_NEW_STAT
+
 #endif /* __ASM_MIPS_STAT_H */
diff -uNrX linux-ignore-files linux-2.1.132.eb3/include/asm-ppc/stat.h linux-2.1.132.eb4/include/asm-ppc/stat.h
--- linux-2.1.132.eb3/include/asm-ppc/stat.h	Sun Oct 11 13:13:50 1998
+++ linux-2.1.132.eb4/include/asm-ppc/stat.h	Mon Dec 28 21:22:58 1998
@@ -37,4 +37,6 @@
 	unsigned long  	__unused5;
 };
 
+#define NEED_OLD_STAT
+#define NEED_NEW_STAT
 #endif
diff -uNrX linux-ignore-files linux-2.1.132.eb3/include/asm-sparc/stat.h linux-2.1.132.eb4/include/asm-sparc/stat.h
--- linux-2.1.132.eb3/include/asm-sparc/stat.h	Sun Oct 11 13:13:52 1998
+++ linux-2.1.132.eb4/include/asm-sparc/stat.h	Mon Dec 28 21:23:55 1998
@@ -38,4 +38,6 @@
 	unsigned long  __unused4[2];
 };
 
+#define NEED_OLD_STAT
+#define NEED_NEW_STAT
 #endif
diff -uNrX linux-ignore-files linux-2.1.132.eb3/include/linux/fs.h linux-2.1.132.eb4/include/linux/fs.h
--- linux-2.1.132.eb3/include/linux/fs.h	Fri Dec 25 17:07:33 1998
+++ linux-2.1.132.eb4/include/linux/fs.h	Wed Dec 30 09:18:14 1998
@@ -308,7 +308,7 @@
 	umode_t		ia_mode;
 	uid_t		ia_uid;
 	gid_t		ia_gid;
-	off_t		ia_size;
+	loff_t		ia_size;
 	time_t		ia_atime;
 	time_t		ia_mtime;
 	time_t		ia_ctime;
@@ -343,7 +343,7 @@
 	uid_t			i_uid;
 	gid_t			i_gid;
 	kdev_t			i_rdev;
-	off_t			i_size;
+	loff_t			i_size;
 	time_t			i_atime;
 	time_t			i_mtime;
 	time_t			i_ctime;
@@ -456,8 +456,8 @@
 	struct file *fl_file;
 	unsigned char fl_flags;
 	unsigned char fl_type;
-	off_t fl_start;
-	off_t fl_end;
+	loff_t fl_start;
+	loff_t fl_end;
 
 	void (*fl_notify)(struct file_lock *);	/* unblock callback */
 
@@ -577,7 +577,7 @@
 	int (*readdir) (struct file *, void *, filldir_t);
 	unsigned int (*poll) (struct file *, struct poll_table_struct *);
 	int (*ioctl) (struct inode *, struct file *, unsigned int, unsigned long);
-	int (*mmap) (struct file *, struct vm_area_struct *);
+	int (*mmap) (struct file *, struct vm_area_struct *, loff_t off);
 	int (*open) (struct inode *, struct file *);
 	int (*flush) (struct file *);
 	int (*release) (struct inode *, struct file *);
@@ -685,7 +685,7 @@
 
 asmlinkage int sys_open(const char *, int, int);
 asmlinkage int sys_close(unsigned int);		/* yes, it's really unsigned */
-extern int do_truncate(struct dentry *, unsigned long);
+extern int do_truncate(struct dentry *, loff_t);
 extern int get_unused_fd(void);
 extern void put_unused_fd(unsigned int);
 extern int close_fp(struct file *, fl_owner_t id);
@@ -837,7 +837,7 @@
 extern int brw_page(int, struct page *, kdev_t, int [], int, int);
 
 extern int generic_readpage(struct file *, struct page *);
-extern int generic_file_mmap(struct file *, struct vm_area_struct *);
+extern int generic_file_mmap(struct file *, struct vm_area_struct *, loff_t);
 extern ssize_t generic_file_read(struct file *, char *, size_t, loff_t *);
 extern ssize_t generic_file_write(struct file *, const char*, size_t, loff_t*);
 
diff -uNrX linux-ignore-files linux-2.1.132.eb3/include/linux/mm.h linux-2.1.132.eb4/include/linux/mm.h
--- linux-2.1.132.eb3/include/linux/mm.h	Fri Dec 25 17:07:33 1998
+++ linux-2.1.132.eb4/include/linux/mm.h	Wed Dec 30 09:23:16 1998
@@ -47,7 +47,7 @@
 	struct vm_area_struct **vm_pprev_share;
 
 	struct vm_operations_struct * vm_ops;
-	unsigned long vm_offset;
+	unsigned long vm_index;
 	struct file * vm_file;
 	unsigned long vm_pte;			/* shared mem */
 };
@@ -98,6 +98,7 @@
 	unsigned long (*nopage)(struct vm_area_struct * area, unsigned long address, int write_access);
 	unsigned long (*wppage)(struct vm_area_struct * area, unsigned long address,
 		unsigned long page);
+	/* swapin & swapout changed! */
 	int (*swapout)(struct vm_area_struct *,  unsigned long, pte_t *);
 	pte_t (*swapin)(struct vm_area_struct *, unsigned long, unsigned long);
 };
@@ -115,7 +116,7 @@
 	struct page *next;
 	struct page *prev;
 	struct inode *inode;
-	unsigned long offset;
+	unsigned long key;
 	struct page *next_hash;
 	atomic_t count;
 	unsigned int unused;
@@ -196,8 +197,9 @@
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
  * PageBuffer(page) is true and page->generic_pp is a circular list of
@@ -209,7 +211,7 @@
  * All pages belonging to an inode make up a doubly linked list
  * inode->i_pages, using the fields page->next and page->prev. (These
  * fields are also used for freelist management when page->count==0.)
- * There is also a hash table mapping (inode,offset) to the page
+ * There is also a hash table mapping (inode,key) to the page
  * in memory if present. The lists for this hash table use the fields
  * page->next_hash and page->prev_hash.
  *
@@ -230,7 +232,7 @@
  *
  * For choosing which pages to swap out, inode pages carry a
  * page->referenced bit, which is set any time the system accesses
- * that page through the (inode,offset) hash table.
+ * that page through the (inode,index) hash table.
  */
 
 extern mem_map_t * mem_map;
@@ -273,7 +275,7 @@
 extern int remap_page_range(unsigned long from, unsigned long to, unsigned long size, pgprot_t prot);
 extern int zeromap_page_range(unsigned long from, unsigned long size, pgprot_t prot);
 
-extern void vmtruncate(struct inode * inode, unsigned long offset);
+extern void vmtruncate(struct inode * inode, loff_t offset);
 extern int handle_mm_fault(struct task_struct *tsk,struct vm_area_struct *vma, unsigned long address, int write_access);
 extern void make_pages_present(unsigned long addr, unsigned long end);
 
@@ -294,14 +296,14 @@
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
 
@@ -338,17 +340,17 @@
 	unsigned long grow;
 
 	address &= PAGE_MASK;
-	grow = vma->vm_start - address;
+	grow = (vma->vm_start - address) >> PAGE_SHIFT;
 	if (vma->vm_end - address
 	    > (unsigned long) current->rlim[RLIMIT_STACK].rlim_cur ||
-	    (vma->vm_mm->total_vm << PAGE_SHIFT) + grow
+	    ((vma->vm_mm->total_vm + grow) << PAGE_SHIFT)
 	    > (unsigned long) current->rlim[RLIMIT_AS].rlim_cur)
 		return -ENOMEM;
 	vma->vm_start = address;
-	vma->vm_offset -= grow;
-	vma->vm_mm->total_vm += grow >> PAGE_SHIFT;
+	vma->vm_index -= grow;
+	vma->vm_mm->total_vm += grow;
 	if (vma->vm_flags & VM_LOCKED)
-		vma->vm_mm->locked_vm += grow >> PAGE_SHIFT;
+		vma->vm_mm->locked_vm += grow;
 	return 0;
 }
 
@@ -380,6 +382,11 @@
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
diff -uNrX linux-ignore-files linux-2.1.132.eb3/include/linux/pagemap.h linux-2.1.132.eb4/include/linux/pagemap.h
--- linux-2.1.132.eb3/include/linux/pagemap.h	Fri Dec 25 17:07:33 1998
+++ linux-2.1.132.eb4/include/linux/pagemap.h	Wed Dec 30 10:36:44 1998
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
@@ -42,9 +42,11 @@
 #undef s
 }
 
-#define page_hash(inode,offset) (page_hash_table+_page_hashfn(inode,offset))
+#define page_hash(inode,key) (page_hash_table+_page_hashfn(inode,key))
 
-static inline struct page * __find_page(struct inode * inode, unsigned long offset, struct page *page)
+#undef PAGE_MAP_DEBUG
+#ifndef PAGE_MAP_DEBUG
+static inline struct page * __find_page(struct inode * inode, unsigned long key, struct page *page)
 {
 	goto inside;
 	for (;;) {
@@ -54,7 +56,7 @@
 			goto not_found;
 		if (page->inode != inode)
 			continue;
-		if (page->offset == offset)
+		if (page->key == key)
 			break;
 	}
 	/* Found the page. */
@@ -63,11 +65,49 @@
 not_found:
 	return page;
 }
-
-static inline struct page *find_page(struct inode * inode, unsigned long offset)
+static inline struct page *find_page(struct inode * inode, unsigned long key)
+{
+	return __find_page(inode, key, *page_hash(inode, key));
+}
+#else
+#include <linux/kernel.h>
+static inline struct page * ___find_page(struct inode * inode, unsigned long key, struct page *page, char *file, int line)
 {
-	return __find_page(inode, offset, *page_hash(inode, offset));
+	goto inside;
+	for (;;) {
+		page = page->next_hash;
+inside:
+		if (!page)
+			goto not_found;
+		if (page->inode != inode)
+			continue;
+		if (page->key == key)
+			break;
+	}
+	/* Found the page. */
+	atomic_inc(&page->count);
+	set_bit(PG_referenced, &page->flags);
+	{
+		int i;
+		int *p;
+		p = (void *)page_address(page);
+		for(i = 0; i < (PAGE_SIZE/sizeof(int)); i++) {
+			if (p[i] != 0) {
+				goto out;
+			}
+		}
+		printk(KERN_WARNING "Found zero page at: %s:%d inode:%ld key:%ld\n",
+			file, line, page->inode->i_ino, page->key);
+		
+	}
+out:
+not_found:
+	return page;
 }
+#define __find_page(inode, key, hash) ___find_page(inode, key, hash, __FILE__, __LINE__)
+#define find_page(inode, key) ___find_page(inode, key, *page_hash(inode, key), __FILE__, __LINE__)
+#endif
+
 
 static inline void remove_page_from_hash_queue(struct page * page)
 {
@@ -89,9 +129,9 @@
 	page->pprev_hash = p;
 }
 
-static inline void add_page_to_hash_queue(struct page * page, struct inode * inode, unsigned long offset)
+static inline void add_page_to_hash_queue(struct page * page, struct inode * inode, unsigned long key)
 {
-	__add_page_to_hash_queue(page, page_hash(inode,offset));
+	__add_page_to_hash_queue(page, page_hash(inode,key));
 }
 
 static inline void remove_page_from_inode_queue(struct page * page)
@@ -129,6 +169,6 @@
 		__wait_on_page(page);
 }
 
-extern void update_vm_cache(struct inode *, unsigned long, const char *, int);
+extern void update_vm_cache(struct inode *, loff_t, const char *, int);
 
 #endif
diff -uNrX linux-ignore-files linux-2.1.132.eb3/include/linux/swap.h linux-2.1.132.eb4/include/linux/swap.h
--- linux-2.1.132.eb3/include/linux/swap.h	Fri Dec 25 16:48:17 1998
+++ linux-2.1.132.eb4/include/linux/swap.h	Sat Dec 26 06:43:39 1998
@@ -149,7 +149,7 @@
 extern inline unsigned long in_swap_cache(struct page *page)
 {
 	if (PageSwapCache(page))
-		return page->offset;
+		return page->key;
 	return 0;
 }
 
@@ -170,7 +170,7 @@
 		/* PARANOID */
 		if (page->inode != &swapper_inode)
 			panic("swap cache page has wrong inode\n");
-		count += swap_count(page->offset) - 2;
+		count += swap_count(page->key) - 2;
 	}
 	if (PageFreeAfter(page))
 		count--;
diff -uNrX linux-ignore-files linux-2.1.132.eb3/include/linux/wrapper.h linux-2.1.132.eb4/include/linux/wrapper.h
--- linux-2.1.132.eb3/include/linux/wrapper.h	Tue Dec 16 12:39:55 1997
+++ linux-2.1.132.eb4/include/linux/wrapper.h	Sat Dec 26 00:17:11 1998
@@ -28,7 +28,7 @@
 
 #define vma_set_inode(v,i) v->vm_inode = i
 #define vma_get_flags(v) v->vm_flags
-#define vma_get_offset(v) v->vm_offset
+/* #define vma_get_offset(v) v->vm_offset */
 #define vma_get_start(v) v->vm_start
 #define vma_get_end(v) v->vm_end
 #define vma_get_page_prot(v) v->vm_page_prot
diff -uNrX linux-ignore-files linux-2.1.132.eb3/ipc/shm.c linux-2.1.132.eb4/ipc/shm.c
--- linux-2.1.132.eb3/ipc/shm.c	Fri Dec 25 16:44:53 1998
+++ linux-2.1.132.eb4/ipc/shm.c	Sat Dec 26 11:23:03 1998
@@ -353,7 +353,7 @@
  * shmd->vm_end		multiple of SHMLBA
  * shmd->vm_next	next attach for task
  * shmd->vm_next_share	next attach for segment
- * shmd->vm_offset	offset into segment
+ * shmd->vm_index	page index into segment
  * shmd->vm_pte		signature for this attach
  */
 
@@ -414,7 +414,7 @@
 	/* map page range */
 	error = 0;
 	shm_sgn = shmd->vm_pte +
-	  SWP_ENTRY(0, (shmd->vm_offset >> PAGE_SHIFT) << SHM_IDX_SHIFT);
+	  SWP_ENTRY(0, shmd->vm_index << SHM_IDX_SHIFT);
 	flush_cache_range(shmd->vm_mm, shmd->vm_start, shmd->vm_end);
 	for (tmp = shmd->vm_start;
 	     tmp < shmd->vm_end;
@@ -530,7 +530,7 @@
 			 | VM_MAYREAD | VM_MAYEXEC | VM_READ | VM_EXEC
 			 | ((shmflg & SHM_RDONLY) ? 0 : VM_MAYWRITE | VM_WRITE);
 	shmd->vm_file = NULL;
-	shmd->vm_offset = 0;
+	shmd->vm_index = 0;
 	shmd->vm_ops = &shm_vm_ops;
 
 	shp->u.shm_nattch++;            /* prevent destruction */
@@ -606,7 +606,7 @@
 	for (shmd = current->mm->mmap; shmd; shmd = shmdnext) {
 		shmdnext = shmd->vm_next;
 		if (shmd->vm_ops == &shm_vm_ops
-		    && shmd->vm_start - shmd->vm_offset == (ulong) shmaddr)
+		    && shmd->vm_start - (shmd->vm_index << PAGE_SHIFT) == (ulong) shmaddr)
 			do_munmap(shmd->vm_start, shmd->vm_end - shmd->vm_start);
 	}
 	unlock_kernel();
@@ -617,7 +617,7 @@
 /*
  * page not present ... go through shm_pages
  */
-static pte_t shm_swap_in(struct vm_area_struct * shmd, unsigned long offset, unsigned long code)
+static pte_t shm_swap_in(struct vm_area_struct * shmd, unsigned long index, unsigned long code)
 {
 	pte_t pte;
 	struct shmid_kernel *shp;
@@ -639,9 +639,9 @@
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
@@ -748,7 +748,7 @@
 				id, SWP_OFFSET(shmd->vm_pte) & SHM_ID_MASK);
 			continue;
 		}
-		tmp = shmd->vm_start + (idx << PAGE_SHIFT) - shmd->vm_offset;
+		tmp = shmd->vm_start + ((idx - shmd->vm_index) << PAGE_SHIFT);
 		if (!(tmp >= shmd->vm_start && tmp < shmd->vm_end))
 			continue;
 		page_dir = pgd_offset(shmd->vm_mm,tmp);
diff -uNrX linux-ignore-files linux-2.1.132.eb3/lib/vsprintf.c linux-2.1.132.eb4/lib/vsprintf.c
--- linux-2.1.132.eb3/lib/vsprintf.c	Fri Dec 25 16:43:26 1998
+++ linux-2.1.132.eb4/lib/vsprintf.c	Mon Dec 28 22:47:08 1998
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
 
@@ -285,6 +383,13 @@
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
diff -uNrX linux-ignore-files linux-2.1.132.eb3/mm/filemap.c linux-2.1.132.eb4/mm/filemap.c
--- linux-2.1.132.eb3/mm/filemap.c	Sat Dec 26 00:16:25 1998
+++ linux-2.1.132.eb4/mm/filemap.c	Wed Dec 30 10:25:57 1998
@@ -71,18 +71,27 @@
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
+	keep_bytes = start & ~PAGE_MASK;
+	partial_keep = start >> PAGE_SHIFT;
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
@@ -98,11 +107,10 @@
 			continue;
 		}
 		p = &page->next;
-		offset = start - offset;
 		/* partial truncate, clear end of page */
-		if (offset < PAGE_SIZE) {
+		if (index == partial_keep) {
 			unsigned long address = page_address(page);
-			memset((void *) (offset + address), 0, PAGE_SIZE - offset);
+			memset((void *) (keep_bytes + address), 0, PAGE_SIZE - keep_bytes);
 			flush_page_to_ram(address);
 		}
 	}
@@ -206,19 +214,22 @@
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
@@ -228,17 +239,17 @@
 		buf += len;
 		len = PAGE_SIZE;
 		offset = 0;
-		pos += PAGE_SIZE;
+		index++;
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
@@ -249,29 +260,28 @@
  * this is all overlapped with the IO on the previous page finishing anyway)
  */
 static unsigned long try_to_read_ahead(struct file * file,
-				unsigned long offset, unsigned long page_cache)
+				       unsigned long index, unsigned long page_cache)
 {
 	struct inode *inode = file->f_dentry->d_inode;
 	struct page * page;
 	struct page ** hash;
 
-	offset &= PAGE_MASK;
 	switch (page_cache) {
 	case 0:
 		page_cache = __get_free_page(GFP_USER);
 		if (!page_cache)
 			break;
 	default:
-		if (offset >= inode->i_size)
+		if ((((loff_t)index) << PAGE_SHIFT) > inode->i_size) 
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
@@ -376,11 +386,11 @@
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
@@ -430,20 +440,24 @@
 
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
+	return max >> PAGE_SHIFT;
 }
 
 static inline unsigned long generic_file_readahead(int reada_ok,
 	struct file * filp, struct inode * inode,
-	unsigned long ppos, struct page * page, unsigned long page_cache)
+	unsigned long index, struct page * page, unsigned long page_cache)
 {
 	unsigned long max_ahead, ahead;
 	unsigned long raend;
 	int max_readahead = get_max_readahead(inode);
 
-	raend = filp->f_raend & PAGE_MASK;
+	raend = filp->f_raend;
 	max_ahead = 0;
 
 /*
@@ -455,14 +469,14 @@
  * page only.
  */
 	if (PageLocked(page)) {
-		if (!filp->f_ralen || ppos >= raend || ppos + filp->f_ralen < raend) {
-			raend = ppos;
+		if (!filp->f_ralen || index >= raend || index + filp->f_ralen < raend) {
+			raend = index;
 			if (raend < inode->i_size)
 				max_ahead = filp->f_ramax;
 			filp->f_rawin = 0;
-			filp->f_ralen = PAGE_SIZE;
+			filp->f_ralen = 1;
 			if (!max_ahead) {
-				filp->f_raend  = ppos + filp->f_ralen;
+				filp->f_raend  = index + filp->f_ralen;
 				filp->f_rawin += filp->f_ralen;
 			}
 		}
@@ -475,17 +489,17 @@
  *   it is the moment to try to read ahead asynchronously.
  * We will later force unplug device in order to force asynchronous read IO.
  */
-	else if (reada_ok && filp->f_ramax && raend >= PAGE_SIZE &&
-	         ppos <= raend && ppos + filp->f_ralen >= raend) {
+	else if (reada_ok && filp->f_ramax && raend >= 1 &&
+	         index <= raend && index + filp->f_ralen >= raend) {
 /*
  * Add ONE page to max_ahead in order to try to have about the same IO max size
  * as synchronous read-ahead (MAX_READAHEAD + 1)*PAGE_SIZE.
  * Compute the position of the last page we have tried to read in order to 
  * begin to read ahead just at the next page.
  */
-		raend -= PAGE_SIZE;
-		if (raend < inode->i_size)
-			max_ahead = filp->f_ramax + PAGE_SIZE;
+		raend -= 1;
+		if (((loff_t)raend << PAGE_SHIFT) < inode->i_size)
+			max_ahead = filp->f_ramax + 1;
 
 		if (max_ahead) {
 			filp->f_rawin = filp->f_ralen;
@@ -500,9 +514,8 @@
  */
 	ahead = 0;
 	while (ahead < max_ahead) {
-		ahead += PAGE_SIZE;
-		page_cache = try_to_read_ahead(filp, raend + ahead,
-						page_cache);
+		ahead += 1;
+		page_cache = try_to_read_ahead(filp, raend + ahead, page_cache);
 	}
 /*
  * If we tried to read ahead some pages,
@@ -522,7 +535,7 @@
 
 		filp->f_ralen += ahead;
 		filp->f_rawin += filp->f_ralen;
-		filp->f_raend = raend + ahead + PAGE_SIZE;
+		filp->f_raend = raend + ahead + 1;
 
 		filp->f_ramax += filp->f_ramax;
 
@@ -567,14 +580,20 @@
 {
 	struct dentry *dentry = filp->f_dentry;
 	struct inode *inode = dentry->d_inode;
-	size_t pos, pgpos, page_cache;
+	unsigned long page_cache;
+	unsigned long index;
 	int reada_ok;
 	int max_readahead = get_max_readahead(inode);
+	loff_t pos;
 
 	page_cache = 0;
 
 	pos = *ppos;
-	pgpos = pos & PAGE_MASK;
+	if (pos > PAGE_MAX_FILE_OFFSET) {
+		desc->error = -EFBIG;
+		return;
+	}
+	index = pos >> PAGE_SHIFT;
 /*
  * If the current position is outside the previous read-ahead window, 
  * we reset the current read-ahead context and set read ahead max to zero
@@ -582,7 +601,7 @@
  * otherwise, we assume that the file accesses are sequential enough to
  * continue read-ahead.
  */
-	if (pgpos > filp->f_raend || pgpos + filp->f_rawin < filp->f_raend) {
+	if (index > filp->f_raend || index + filp->f_rawin < filp->f_raend) {
 		reada_ok = 0;
 		filp->f_raend = 0;
 		filp->f_ralen = 0;
@@ -603,13 +622,13 @@
 	} else {
 		unsigned long needed;
 
-		needed = ((pos + desc->count) & PAGE_MASK) - pgpos;
+		needed = ((pos + desc->count) >> PAGE_SHIFT) - index;
 
 		if (filp->f_ramax < needed)
 			filp->f_ramax = needed;
 
-		if (reada_ok && filp->f_ramax < MIN_READAHEAD)
-				filp->f_ramax = MIN_READAHEAD;
+		if (reada_ok && filp->f_ramax < (MIN_READAHEAD >> PAGE_SHIFT))
+				filp->f_ramax = (MIN_READAHEAD >> PAGE_SHIFT);
 		if (filp->f_ramax > max_readahead)
 			filp->f_ramax = max_readahead;
 	}
@@ -619,12 +638,17 @@
 
 		if (pos >= inode->i_size)
 			break;
+		if (pos > PAGE_MAX_FILE_OFFSET) {
+			desc->error = -EFBIG;
+		}
+
+		index = pos >> PAGE_SHIFT;
 
 		/*
 		 * Try to find the data in the page cache..
 		 */
-		hash = page_hash(inode, pos & PAGE_MASK);
-		page = __find_page(inode, pos & PAGE_MASK, *hash);
+		hash = page_hash(inode, index);
+		page = __find_page(inode, index, *hash);
 		if (!page)
 			goto no_cached_page;
 
@@ -637,9 +661,9 @@
  * the page has been rewritten.
  */
 		if (PageUptodate(page) || PageLocked(page))
-			page_cache = generic_file_readahead(reada_ok, filp, inode, pos & PAGE_MASK, page, page_cache);
-		else if (reada_ok && filp->f_ramax > MIN_READAHEAD)
-				filp->f_ramax = MIN_READAHEAD;
+			page_cache = generic_file_readahead(reada_ok, filp, inode, index, page, page_cache);
+		else if (reada_ok && filp->f_ramax > (MIN_READAHEAD >> PAGE_SHIFT))
+				filp->f_ramax = (MIN_READAHEAD >> PAGE_SHIFT);
 
 		wait_on_page(page);
 
@@ -656,7 +680,7 @@
 
 		offset = pos & ~PAGE_MASK;
 		nr = PAGE_SIZE - offset;
-		if (nr > inode->i_size - pos)
+		if ((loff_t)nr > (inode->i_size - pos))
 			nr = inode->i_size - pos;
 
 		/*
@@ -696,7 +720,7 @@
 		 */
 		page = mem_map + MAP_NR(page_cache);
 		page_cache = 0;
-		add_to_page_cache(page, inode, pos & PAGE_MASK, hash);
+		add_to_page_cache(page, inode, index, hash);
 
 		/*
 		 * Error handling is tricky. If we get a read error,
@@ -713,8 +737,8 @@
  * the application process needs it, or has been rewritten.
  * Decrease max readahead size to the minimum value in that situation.
  */
-		if (reada_ok && filp->f_ramax > MIN_READAHEAD)
-			filp->f_ramax = MIN_READAHEAD;
+		if (reada_ok && filp->f_ramax > (MIN_READAHEAD >> PAGE_SHIFT))
+			filp->f_ramax = (MIN_READAHEAD >> PAGE_SHIFT);
 
 		{
 			int error = inode->i_op->readpage(filp, page);
@@ -922,20 +946,21 @@
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
-		goto no_page;
-
+	index = area->vm_index + (((address & PAGE_MASK) - area->vm_start) >> PAGE_SHIFT);
+	hash = page_hash(inode, index);
+	if (index < area->vm_index) {
+		goto anonymous_page;
+	}
 	/*
 	 * Do we have something in the page cache already?
 	 */
-	hash = page_hash(inode, offset);
-	page = __find_page(inode, offset, *hash);
+	page = __find_page(inode, index, *hash);
 	if (!page)
 		goto no_cached_page;
 
@@ -983,14 +1008,16 @@
 	return new_page;
 
 no_cached_page:
+	if ((((loff_t)index) << PAGE_SHIFT) >= inode->i_size) 
+		goto anonymous_page;
 	/*
 	 * Try to read in an entire cluster at once.
 	 */
-	reada   = offset;
-	reada >>= PAGE_SHIFT + page_cluster;
-	reada <<= PAGE_SHIFT + page_cluster;
+	reada   = index;
+	reada >>= page_cluster;
+	reada <<= page_cluster;
 
-	for (i = 1 << page_cluster; i > 0; --i, reada += PAGE_SIZE)
+	for (i = 1 << page_cluster; i > 0; --i, reada++)
 		new_page = try_to_read_ahead(file, reada, new_page);
 
 	if (!new_page)
@@ -1004,7 +1031,7 @@
 	 * cache.. The page we just got may be useful if we
 	 * can't share, so don't get rid of it here.
 	 */
-	page = find_page(inode, offset);
+	page = __find_page(inode, index, *hash);
 	if (page)
 		goto found_page;
 
@@ -1013,13 +1040,41 @@
 	 */
 	page = mem_map + MAP_NR(new_page);
 	new_page = 0;
-	add_to_page_cache(page, inode, offset, hash);
+	add_to_page_cache(page, inode, index, hash);
 
 	if (inode->i_op->readpage(file, page) != 0)
 		goto failure;
 
 	goto found_page;
 
+ anonymous_page:
+	if ((area->vm_flags & VM_SHARED) && (area->vm_mm == current->mm))
+		goto no_page;
+	new_page = __get_free_page(GFP_USER);
+	if (!new_page)
+		goto no_page;
+	/*
+	 * During getting the above page we might have slept,
+	 * so we need to re-check the situation with the page
+	 * cache.. The page we just got may be useful if we
+	 * can't share, so don't get rid of it here.
+	 */
+	if (index >= area->vm_index) {
+		page = __find_page(inode, index, *hash);
+		if (page) 
+			goto found_page;
+	}
+	/*
+	 * Now, create a new page-cache page, so if we are readonly
+	 * we can later get the value when the page is extended.
+	 */
+	clear_page(new_page);
+	page = mem_map + MAP_NR(new_page);
+	new_page = 0;
+	add_to_page_cache(page, inode, index, hash);
+	set_bit(PG_uptodate, &page->flags);
+	goto found_page;
+
 page_locked_wait:
 	__wait_on_page(page);
 	if (PageUptodate(page))
@@ -1057,23 +1112,24 @@
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
+		if (PAGE_SIZE > (inode->i_size - loff)) {
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
@@ -1084,7 +1140,7 @@
 }
 
 static int filemap_write_page(struct vm_area_struct * vma,
-	unsigned long offset,
+	unsigned long index,
 	unsigned long page)
 {
 	int result;
@@ -1121,7 +1177,7 @@
 	 */
 	file->f_count++;
 	down(&inode->i_sem);
-	result = do_write_page(inode, file, (const char *) page, offset);
+	result = do_write_page(inode, file, (const char *) page, index);
 	up(&inode->i_sem);
 	fput(file);
 	return result;
@@ -1139,17 +1195,18 @@
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
@@ -1162,7 +1219,7 @@
  * So we just use it directly..
  */
 static pte_t filemap_swapin(struct vm_area_struct * vma,
-	unsigned long offset,
+	unsigned long index,
 	unsigned long entry)
 {
 	unsigned long page = SWP_OFFSET(entry);
@@ -1178,6 +1235,7 @@
 {
 	pte_t pte = *ptep;
 	unsigned long page;
+	unsigned long index;
 	int error;
 
 	if (!(flags & MS_INVALIDATE)) {
@@ -1207,7 +1265,8 @@
 			return 0;
 		}
 	}
-	error = filemap_write_page(vma, address - vma->vm_start + vma->vm_offset, page);
+	index = ((address - vma->vm_start) >> PAGE_SHIFT) + vma->vm_index; 
+	error = filemap_write_page(vma, index, page);
 	free_page(page);
 	return error;
 }
@@ -1337,27 +1396,35 @@
 
 /* This is used for a general mmap of a disk file */
 
-int generic_file_mmap(struct file * file, struct vm_area_struct * vma)
+int generic_file_mmap(struct file * file, struct vm_area_struct * vma,
+		      loff_t offset)
 {
 	struct vm_operations_struct * ops;
 	struct inode *inode = file->f_dentry->d_inode;
+	unsigned long index;
+
+ 	if (offset > PAGE_MAX_FILE_OFFSET) {
+ 		return -EINVAL;
+ 	}
+	/* share_page() can only guarantee proper page sharing if
+	 * the offsets are all page aligned. 
+	 */
+	if (offset & ~PAGE_MASK) {
+		return -EINVAL;
+	}
+ 	index = offset >> PAGE_SHIFT;
 
 	if ((vma->vm_flags & VM_SHARED) && (vma->vm_flags & VM_MAYWRITE)) {
 		ops = &file_shared_mmap;
-		/* share_page() can only guarantee proper page sharing if
-		 * the offsets are all page aligned. */
-		if (vma->vm_offset & (PAGE_SIZE - 1))
-			return -EINVAL;
 	} else {
 		ops = &file_private_mmap;
-		if (vma->vm_offset & (PAGE_SIZE - 1))
-			return -EINVAL;
 	}
 	if (!inode->i_sb || !S_ISREG(inode->i_mode))
 		return -EACCES;
 	if (!inode->i_op || !inode->i_op->readpage)
 		return -ENOEXEC;
 	UPDATE_ATIME(inode);
+	vma->vm_index = index;
 	vma->vm_file = file;
 	file->f_count++;
 	vma->vm_ops = ops;
@@ -1470,8 +1537,8 @@
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
@@ -1486,6 +1553,11 @@
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
@@ -1506,19 +1578,19 @@
 	}
 
 	while (count) {
-		unsigned long bytes, pgpos, offset;
+		unsigned long bytes, index, offset;
 		/*
 		 * Try to find the page in the cache. If it isn't there,
 		 * allocate a free page.
 		 */
 		offset = (pos & ~PAGE_MASK);
-		pgpos = pos & PAGE_MASK;
+		index = pos >> PAGE_SHIFT;
 		bytes = PAGE_SIZE - offset;
 		if (bytes > count)
 			bytes = count;
 
-		hash = page_hash(inode, pgpos);
-		page = __find_page(inode, pgpos, *hash);
+		hash = page_hash(inode, index);
+		page = __find_page(inode, index, *hash);
 		if (!page) {
 			if (!page_cache) {
 				page_cache = __get_free_page(GFP_USER);
@@ -1528,7 +1600,7 @@
 				break;
 			}
 			page = mem_map + MAP_NR(page_cache);
-			add_to_page_cache(page, inode, pgpos, hash);
+			add_to_page_cache(page, inode, index, hash);
 			page_cache = 0;
 		}
 
@@ -1586,9 +1658,12 @@
 	struct page * page;
 	struct page ** hash;
 	unsigned long page_cache = 0;
+	unsigned long index;
+
+	index = offset >> PAGE_SHIFT;
 
-	hash = page_hash(inode, offset);
-	page = __find_page(inode, offset, *hash);
+	hash = page_hash(inode, index);
+	page = __find_page(inode, index, *hash);
 	if (!page) {
 		if (!new)
 			goto out;
@@ -1596,7 +1671,7 @@
 		if (!page_cache)
 			goto out;
 		page = mem_map + MAP_NR(page_cache);
-		add_to_page_cache(page, inode, offset, hash);
+		add_to_page_cache(page, inode, index, hash);
 	}
 	if (atomic_read(&page->count) != 2)
 		printk(KERN_ERR "get_cached_page: page count=%d\n",
diff -uNrX linux-ignore-files linux-2.1.132.eb3/mm/memory.c linux-2.1.132.eb4/mm/memory.c
--- linux-2.1.132.eb3/mm/memory.c	Fri Dec 25 16:43:46 1998
+++ linux-2.1.132.eb4/mm/memory.c	Tue Dec 29 20:51:05 1998
@@ -729,13 +729,19 @@
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
+	index = offset >> PAGE_SHIFT;
+	partial = offset & PAGE_MASK;
+	trunk_index = index + (partial)? 1 : 0;
 	mpnt = inode->i_mmap;
 	do {
 		struct mm_struct *mm = mpnt->vm_mm;
@@ -745,14 +751,14 @@
 		unsigned long diff;
 
 		/* mapping wholly truncated? */
-		if (mpnt->vm_offset >= offset) {
+		if (mpnt->vm_index >= trunk_index) {
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
@@ -781,7 +787,8 @@
 		swap_in(tsk, vma, page_table, pte_val(entry), write_access);
 		flush_page_to_ram(pte_page(*page_table));
 	} else {
-		pte_t page = vma->vm_ops->swapin(vma, address - vma->vm_start + vma->vm_offset, pte_val(entry));
+		unsigned long index = ((address - vma->vm_start) >> PAGE_SHIFT) + vma->vm_index;
+		pte_t page = vma->vm_ops->swapin(vma, index, pte_val(entry));
 		if (pte_val(*page_table) != pte_val(entry)) {
 			free_page(pte_page(page));
 		} else {
diff -uNrX linux-ignore-files linux-2.1.132.eb3/mm/mlock.c linux-2.1.132.eb4/mm/mlock.c
--- linux-2.1.132.eb3/mm/mlock.c	Fri Dec 25 16:43:46 1998
+++ linux-2.1.132.eb4/mm/mlock.c	Sat Dec 26 00:17:12 1998
@@ -28,7 +28,7 @@
 	*n = *vma;
 	vma->vm_start = end;
 	n->vm_end = end;
-	vma->vm_offset += vma->vm_start - n->vm_start;
+	vma->vm_index += (vma->vm_start - n->vm_start) >> PAGE_SHIFT;
 	n->vm_flags = newflags;
 	if (n->vm_file)
 		n->vm_file->f_count++;
@@ -49,7 +49,7 @@
 	*n = *vma;
 	vma->vm_end = start;
 	n->vm_start = start;
-	n->vm_offset += n->vm_start - vma->vm_start;
+	n->vm_index += (n->vm_start - vma->vm_start) >> PAGE_SHIFT;
 	n->vm_flags = newflags;
 	if (n->vm_file)
 		n->vm_file->f_count++;
@@ -78,8 +78,8 @@
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
diff -uNrX linux-ignore-files linux-2.1.132.eb3/mm/mmap.c linux-2.1.132.eb4/mm/mmap.c
--- linux-2.1.132.eb3/mm/mmap.c	Fri Dec 25 16:43:46 1998
+++ linux-2.1.132.eb4/mm/mmap.c	Mon Dec 28 23:51:57 1998
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
@@ -417,7 +417,7 @@
 	if (end == area->vm_end)
 		area->vm_end = addr;
 	else if (addr == area->vm_start) {
-		area->vm_offset += (end - area->vm_start);
+		area->vm_index += ((end - area->vm_start) >> PAGE_SHIFT);
 		area->vm_start = end;
 	} else {
 	/* Unmapping a hole: area->vm_start < addr <= end < area->vm_end */
@@ -431,7 +431,7 @@
 		mpnt->vm_page_prot = area->vm_page_prot;
 		mpnt->vm_flags = area->vm_flags;
 		mpnt->vm_ops = area->vm_ops;
-		mpnt->vm_offset = area->vm_offset + (end - area->vm_start);
+		mpnt->vm_index = area->vm_index + ((end - area->vm_start) >> PAGE_SHIFT);
 		mpnt->vm_file = area->vm_file;
 		mpnt->vm_pte = area->vm_pte;
 		if (mpnt->vm_file)
@@ -675,8 +675,9 @@
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
 
@@ -690,7 +691,7 @@
 
 		prev->vm_end = mpnt->vm_end;
 		if (mpnt->vm_ops && mpnt->vm_ops->close) {
-			mpnt->vm_offset += mpnt->vm_end - mpnt->vm_start;
+			mpnt->vm_index += (mpnt->vm_end - mpnt->vm_start) >> PAGE_SHIFT;
 			mpnt->vm_start = mpnt->vm_end;
 			mpnt->vm_ops->close(mpnt);
 		}
diff -uNrX linux-ignore-files linux-2.1.132.eb3/mm/mprotect.c linux-2.1.132.eb4/mm/mprotect.c
--- linux-2.1.132.eb3/mm/mprotect.c	Fri Dec 25 16:43:46 1998
+++ linux-2.1.132.eb4/mm/mprotect.c	Sat Dec 26 00:17:12 1998
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
@@ -153,8 +153,8 @@
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
diff -uNrX linux-ignore-files linux-2.1.132.eb3/mm/mremap.c linux-2.1.132.eb4/mm/mremap.c
--- linux-2.1.132.eb3/mm/mremap.c	Fri Dec 25 16:43:46 1998
+++ linux-2.1.132.eb4/mm/mremap.c	Sat Dec 26 07:50:57 1998
@@ -133,7 +133,7 @@
 			*new_vma = *vma;
 			new_vma->vm_start = new_addr;
 			new_vma->vm_end = new_addr+new_len;
-			new_vma->vm_offset = vma->vm_offset + (addr - vma->vm_start);
+			new_vma->vm_index = vma->vm_index + ((addr - vma->vm_start) >> PAGE_SHIFT);
 			if (new_vma->vm_file)
 				new_vma->vm_file->f_count++;
 			if (new_vma->vm_ops && new_vma->vm_ops->open)
diff -uNrX linux-ignore-files linux-2.1.132.eb3/mm/page_io.c linux-2.1.132.eb4/mm/page_io.c
--- linux-2.1.132.eb3/mm/page_io.c	Fri Dec 25 16:48:17 1998
+++ linux-2.1.132.eb4/mm/page_io.c	Sat Dec 26 01:24:40 1998
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
diff -uNrX linux-ignore-files linux-2.1.132.eb3/mm/swap_state.c linux-2.1.132.eb4/mm/swap_state.c
--- linux-2.1.132.eb3/mm/swap_state.c	Fri Dec 25 16:44:53 1998
+++ linux-2.1.132.eb4/mm/swap_state.c	Sat Dec 26 01:23:40 1998
@@ -56,7 +56,7 @@
 	if (PageTestandSetSwapCache(page)) {
 		printk(KERN_ERR "swap_cache: replacing non-empty entry %08lx "
 		       "on page %08lx\n",
-		       page->offset, page_address(page));
+		       page->key, page_address(page));
 		return 0;
 	}
 	if (page->inode) {
@@ -66,7 +66,7 @@
 	}
 	atomic_inc(&page->count);
 	page->inode = &swapper_inode;
-	page->offset = entry;
+	page->key = entry;
 	add_page_to_hash_queue(page, &swapper_inode, entry);
 	add_page_to_inode_queue(&swapper_inode, page);
 #ifdef SWAP_CACHE_INFO
@@ -218,7 +218,7 @@
  */
 void delete_from_swap_cache(struct page *page)
 {
-	long entry = page->offset;
+	long entry = page->key;
 
 #ifdef SWAP_CACHE_INFO
 	swap_cache_del_total++;
diff -uNrX linux-ignore-files linux-2.1.132.eb3/mm/vmscan.c linux-2.1.132.eb4/mm/vmscan.c
--- linux-2.1.132.eb3/mm/vmscan.c	Fri Dec 25 16:44:53 1998
+++ linux-2.1.132.eb4/mm/vmscan.c	Sat Dec 26 00:17:35 1998
@@ -91,10 +91,10 @@
 			struct page *found;
 			printk ("VM: Found a writable swap-cached page!\n");
 			/* Try to diagnose the problem ... */
-			found = find_page(&swapper_inode, page_map->offset);
+			found = find_page(&swapper_inode, page_map->key);
 			if (found) {
 				printk("page=%p@%08lx, found=%p, count=%d\n",
-					page_map, page_map->offset,
+					page_map, page_map->key,
 					found, atomic_read(&found->count));
 				__free_page(found);
 			} else 
@@ -125,9 +125,10 @@
 
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
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
