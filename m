Date: Wed, 17 May 2000 11:00:34 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: [davem@redhat.com: my paging work]
Message-ID: <20000517110034.M30758@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Stephen Tweedie <sct@redhat.com>, "David S . Miller" <davem@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi,

Here's davem's page-based swapout snapshot.  It's UNFINISHED + DANGEROUS +
WILL_EAT_YOUR_DISK (his words!), but somebody may want to archive this and
pick up on the work in 2.5.

--Stephen

----- Forwarded message from "David S. Miller" <davem@redhat.com> -----

Date: Sun, 30 Apr 2000 22:29:29 -0700
X-Authentication-Warning: pizda.ninka.net: davem set sender to davem@redhat.com using -f
From: "David S. Miller" <davem@redhat.com>
To: sct@redhat.com
Subject: my paging work


I'm abandoning it for the time being, there are more important
things to work on for 2.4.x :-)  A lot of things started to really
not work out the way I wanted them to.  One example was the locking,
because once you have LRU of all interesting pages in the system the
natural way to swap them out is to lock the
page->mapping->i_shared_lock and walk the VMA's tapping on the ptes
in each.  This is backwards to how the rest of the kernel locks this
stuff, you can see my attempted band-aid in the patch below with the
lock_vma_mappings() stuff.

The code mostly works, no major SMP deadlocks, but the swap cache
leaks heavily under any swap load and the machine still goes into
a catatonic state when paging pressure is high.

The anon layer is done incorrectly, it does in fact have the problem
of making the swapper look at vma's which don't even have the page for
the private file mapping case (very common for pages containing shared
library data sections, and also for elf PLT pages, for example).  This
was very disappointing because I would have been so happy if we could
do it this way and only have a per-VMA cost for this stuff when there
is no paging going on.  The only evident other solution would be
per-page pte chaining just like freebsd does, and I am rather
confident that this would make the changes an instant "no way" from
Linus's perspective because of the high added cost.  I would also
find this kind of cost unacceptable, ho hum...

Anyways, I send you a copy since I'm going off to work on other stuff
for the time being.  Enjoy.

Index: Makefile
===================================================================
RCS file: /cvs/linux/Makefile,v
retrieving revision 1.306
diff -u -r1.306 Makefile
--- Makefile	2000/04/25 04:13:23	1.306
+++ Makefile	2000/05/01 05:32:21
@@ -1,7 +1,7 @@
 VERSION = 2
 PATCHLEVEL = 3
 SUBLEVEL = 99
-EXTRAVERSION = -pre6
+EXTRAVERSION = -pre6ANON
 
 KERNELRELEASE=$(VERSION).$(PATCHLEVEL).$(SUBLEVEL)$(EXTRAVERSION)
 
Index: arch/ia64/ia32/binfmt_elf32.c
===================================================================
RCS file: /cvs/linux/arch/ia64/ia32/binfmt_elf32.c,v
retrieving revision 1.5
diff -u -r1.5 binfmt_elf32.c
--- arch/ia64/ia32/binfmt_elf32.c	2000/04/22 00:45:14	1.5
+++ arch/ia64/ia32/binfmt_elf32.c	2000/05/01 05:32:22
@@ -178,7 +178,7 @@
 		mpnt->vm_ops = NULL;
 		mpnt->vm_pgoff = 0;
 		mpnt->vm_file = NULL;
-		mpnt->vm_private_data = 0;
+		mpnt->vm_anon = NULL;
 		insert_vm_struct(current->mm, mpnt);
 		current->mm->total_vm = (mpnt->vm_end - mpnt->vm_start) >> PAGE_SHIFT;
 	} 
Index: arch/ia64/mm/init.c
===================================================================
RCS file: /cvs/linux/arch/ia64/mm/init.c,v
retrieving revision 1.6
diff -u -r1.6 init.c
--- arch/ia64/mm/init.c	2000/04/22 00:45:15	1.6
+++ arch/ia64/mm/init.c	2000/05/01 05:32:22
@@ -160,7 +160,7 @@
 		vma->vm_ops = NULL;
 		vma->vm_pgoff = 0;
 		vma->vm_file = NULL;
-		vma->vm_private_data = NULL;
+		vma->vm_anon = NULL;
 		insert_vm_struct(current->mm, vma);
 	}
 }
Index: fs/exec.c
===================================================================
RCS file: /cvs/linux/fs/exec.c,v
retrieving revision 1.108
diff -u -r1.108 exec.c
--- fs/exec.c	2000/04/22 00:45:17	1.108
+++ fs/exec.c	2000/05/01 05:32:40
@@ -240,7 +240,7 @@
  * This routine is used to map in a page into an address space: needed by
  * execve() for the initial stack and environment pages.
  */
-void put_dirty_page(struct task_struct * tsk, struct page *page, unsigned long address)
+void put_dirty_page(struct task_struct * tsk, struct vm_area_struct *vma, struct page *page, unsigned long address)
 {
 	pgd_t * pgd;
 	pmd_t * pmd;
@@ -248,6 +248,11 @@
 
 	if (page_count(page) != 1)
 		printk("mem_map disagrees with %p at %08lx\n", page, address);
+	if (anon_page_add(vma, address, page)) {
+		__free_page(page);
+		force_sig(SIGKILL, tsk);
+		return;
+	}
 	pgd = pgd_offset(tsk->mm, address);
 	pmd = pmd_alloc(pgd, address);
 	if (!pmd) {
@@ -297,7 +302,7 @@
 		mpnt->vm_ops = NULL;
 		mpnt->vm_pgoff = 0;
 		mpnt->vm_file = NULL;
-		mpnt->vm_private_data = (void *) 0;
+		mpnt->vm_anon = NULL;
 		vmlist_modify_lock(current->mm);
 		insert_vm_struct(current->mm, mpnt);
 		vmlist_modify_unlock(current->mm);
@@ -307,7 +312,7 @@
 	for (i = 0 ; i < MAX_ARG_PAGES ; i++) {
 		if (bprm->page[i]) {
 			current->mm->rss++;
-			put_dirty_page(current,bprm->page[i],stack_base);
+			put_dirty_page(current,mpnt,bprm->page[i],stack_base);
 		}
 		stack_base += PAGE_SIZE;
 	}
Index: fs/adfs/inode.c
===================================================================
RCS file: /cvs/linux/fs/adfs/inode.c,v
retrieving revision 1.11
diff -u -r1.11 inode.c
--- fs/adfs/inode.c	2000/04/26 09:36:33	1.11
+++ fs/adfs/inode.c	2000/05/01 05:32:40
@@ -76,6 +76,7 @@
 	sync_page:	block_sync_page,
 	prepare_write:	adfs_prepare_write,
 	commit_write:	generic_commit_write,
+	try_to_free_page: filemap_try_to_free_page,
 	bmap:		_adfs_bmap
 };
 
Index: fs/affs/file.c
===================================================================
RCS file: /cvs/linux/fs/affs/file.c,v
retrieving revision 1.33
diff -u -r1.33 file.c
--- fs/affs/file.c	2000/04/26 09:36:33	1.33
+++ fs/affs/file.c	2000/05/01 05:32:40
@@ -361,6 +361,7 @@
 	sync_page: block_sync_page,
 	prepare_write: affs_prepare_write,
 	commit_write: generic_commit_write,
+	try_to_free_page: filemap_try_to_free_page,
 	bmap: _affs_bmap
 };
 
Index: fs/affs/symlink.c
===================================================================
RCS file: /cvs/linux/fs/affs/symlink.c,v
retrieving revision 1.21
diff -u -r1.21 symlink.c
--- fs/affs/symlink.c	2000/02/27 08:18:26	1.21
+++ fs/affs/symlink.c	2000/05/01 05:32:40
@@ -73,6 +73,7 @@
 
 struct address_space_operations affs_symlink_aops = {
 	readpage:	affs_symlink_readpage,
+	try_to_free_page: filemap_try_to_free_page
 };
 
 struct inode_operations affs_symlink_inode_operations = {
Index: fs/bfs/file.c
===================================================================
RCS file: /cvs/linux/fs/bfs/file.c,v
retrieving revision 1.13
diff -u -r1.13 file.c
--- fs/bfs/file.c	2000/04/26 09:36:33	1.13
+++ fs/bfs/file.c	2000/05/01 05:32:40
@@ -153,6 +153,7 @@
 	sync_page:	block_sync_page,
 	prepare_write:	bfs_prepare_write,
 	commit_write:	generic_commit_write,
+	try_to_free_page: filemap_try_to_free_page,
 	bmap:		bfs_bmap
 };
 
Index: fs/coda/symlink.c
===================================================================
RCS file: /cvs/linux/fs/coda/symlink.c,v
retrieving revision 1.13
diff -u -r1.13 symlink.c
--- fs/coda/symlink.c	2000/02/10 21:15:21	1.13
+++ fs/coda/symlink.c	2000/05/01 05:32:40
@@ -49,5 +49,6 @@
 }
 
 struct address_space_operations coda_symlink_aops = {
-	readpage:	coda_symlink_filler
+	readpage:	coda_symlink_filler,
+	try_to_free_page: filemap_try_to_free_page
 };
Index: fs/cramfs/inode.c
===================================================================
RCS file: /cvs/linux/fs/cramfs/inode.c,v
retrieving revision 1.9
diff -u -r1.9 inode.c
--- fs/cramfs/inode.c	2000/03/24 01:32:43	1.9
+++ fs/cramfs/inode.c	2000/05/01 05:32:41
@@ -335,7 +335,8 @@
 }
 
 static struct address_space_operations cramfs_aops = {
-	readpage: cramfs_readpage
+	readpage: cramfs_readpage,
+	try_to_free_page: filemap_try_to_free_page
 };
 
 /*
Index: fs/efs/inode.c
===================================================================
RCS file: /cvs/linux/fs/efs/inode.c,v
retrieving revision 1.8
diff -u -r1.8 inode.c
--- fs/efs/inode.c	2000/04/26 09:36:33	1.8
+++ fs/efs/inode.c	2000/05/01 05:32:41
@@ -22,6 +22,7 @@
 struct address_space_operations efs_aops = {
 	readpage: efs_readpage,
 	sync_page: block_sync_page,
+ 	try_to_free_page: filemap_try_to_free_page,
 	bmap: _efs_bmap
 };
 
Index: fs/efs/symlink.c
===================================================================
RCS file: /cvs/linux/fs/efs/symlink.c,v
retrieving revision 1.8
diff -u -r1.8 symlink.c
--- fs/efs/symlink.c	2000/02/10 21:15:29	1.8
+++ fs/efs/symlink.c	2000/05/01 05:32:41
@@ -49,5 +49,6 @@
 }
 
 struct address_space_operations efs_symlink_aops = {
-	readpage:	efs_symlink_readpage
+	readpage:	efs_symlink_readpage,
+	try_to_free_page: filemap_try_to_free_page,
 };
Index: fs/ext2/inode.c
===================================================================
RCS file: /cvs/linux/fs/ext2/inode.c,v
retrieving revision 1.46
diff -u -r1.46 inode.c
--- fs/ext2/inode.c	2000/04/26 09:36:33	1.46
+++ fs/ext2/inode.c	2000/05/01 05:32:42
@@ -642,6 +642,7 @@
 	sync_page: block_sync_page,
 	prepare_write: ext2_prepare_write,
 	commit_write: generic_commit_write,
+	try_to_free_page: filemap_try_to_free_page,
 	bmap: ext2_bmap
 };
 
Index: fs/fat/inode.c
===================================================================
RCS file: /cvs/linux/fs/fat/inode.c,v
retrieving revision 1.52
diff -u -r1.52 inode.c
--- fs/fat/inode.c	2000/04/26 09:36:33	1.52
+++ fs/fat/inode.c	2000/05/01 05:32:42
@@ -752,6 +752,7 @@
 	sync_page: block_sync_page,
 	prepare_write: fat_prepare_write,
 	commit_write: generic_commit_write,
+	try_to_free_page: filemap_try_to_free_page,
 	bmap: _fat_bmap
 };
 
Index: fs/hfs/inode.c
===================================================================
RCS file: /cvs/linux/fs/hfs/inode.c,v
retrieving revision 1.11
diff -u -r1.11 inode.c
--- fs/hfs/inode.c	2000/04/26 09:36:33	1.11
+++ fs/hfs/inode.c	2000/05/01 05:32:42
@@ -240,6 +240,7 @@
 	sync_page: block_sync_page,
 	prepare_write: hfs_prepare_write,
 	commit_write: generic_commit_write,
+	try_to_free_page: filemap_try_to_free_page,
 	bmap: hfs_bmap
 };
 
Index: fs/hpfs/file.c
===================================================================
RCS file: /cvs/linux/fs/hpfs/file.c,v
retrieving revision 1.12
diff -u -r1.12 file.c
--- fs/hpfs/file.c	2000/04/26 09:36:33	1.12
+++ fs/hpfs/file.c	2000/05/01 05:32:43
@@ -109,6 +109,7 @@
 	sync_page: block_sync_page,
 	prepare_write: hpfs_prepare_write,
 	commit_write: generic_commit_write,
+	try_to_free_page: filemap_try_to_free_page,
 	bmap: _hpfs_bmap
 };
 
Index: fs/hpfs/inode.c
===================================================================
RCS file: /cvs/linux/fs/hpfs/inode.c,v
retrieving revision 1.12
diff -u -r1.12 inode.c
--- fs/hpfs/inode.c	2000/03/13 21:59:20	1.12
+++ fs/hpfs/inode.c	2000/05/01 05:32:43
@@ -48,7 +48,8 @@
 };
 
 struct address_space_operations hpfs_symlink_aops = {
-	readpage:	hpfs_symlink_readpage
+	readpage:	hpfs_symlink_readpage,
+	try_to_free_page: filemap_try_to_free_page
 };
 
 void hpfs_read_inode(struct inode *i)
Index: fs/isofs/inode.c
===================================================================
RCS file: /cvs/linux/fs/isofs/inode.c,v
retrieving revision 1.62
diff -u -r1.62 inode.c
--- fs/isofs/inode.c	2000/04/26 09:36:33	1.62
+++ fs/isofs/inode.c	2000/05/01 05:32:44
@@ -992,6 +992,7 @@
 static struct address_space_operations isofs_aops = {
 	readpage: isofs_readpage,
 	sync_page: block_sync_page,
+ 	try_to_free_page: filemap_try_to_free_page,
 	bmap: _isofs_bmap
 };
 
Index: fs/isofs/rock.c
===================================================================
RCS file: /cvs/linux/fs/isofs/rock.c,v
retrieving revision 1.17
diff -u -r1.17 rock.c
--- fs/isofs/rock.c	2000/02/10 21:15:46	1.17
+++ fs/isofs/rock.c	2000/05/01 05:32:44
@@ -542,5 +542,6 @@
 }
 
 struct address_space_operations isofs_symlink_aops = {
-	readpage:	rock_ridge_symlink_readpage
+	readpage:	rock_ridge_symlink_readpage,
+	try_to_free_page: filemap_try_to_free_page
 };
Index: fs/minix/inode.c
===================================================================
RCS file: /cvs/linux/fs/minix/inode.c,v
retrieving revision 1.45
diff -u -r1.45 inode.c
--- fs/minix/inode.c	2000/04/26 09:36:33	1.45
+++ fs/minix/inode.c	2000/05/01 05:32:45
@@ -1028,6 +1028,7 @@
 	sync_page: block_sync_page,
 	prepare_write: minix_prepare_write,
 	commit_write: generic_commit_write,
+	try_to_free_page: filemap_try_to_free_page,
 	bmap: minix_bmap
 };
 
Index: fs/ncpfs/symlink.c
===================================================================
RCS file: /cvs/linux/fs/ncpfs/symlink.c,v
retrieving revision 1.6
diff -u -r1.6 symlink.c
--- fs/ncpfs/symlink.c	2000/02/10 21:15:56	1.6
+++ fs/ncpfs/symlink.c	2000/05/01 05:32:45
@@ -98,6 +98,7 @@
  */
 struct address_space_operations ncp_symlink_aops = {
 	readpage:	ncp_symlink_readpage,
+	try_to_free_page: filemap_try_to_free_page,
 };
 	
 /* ----- create a new symbolic link -------------------------------------- */
Index: fs/nfs/file.c
===================================================================
RCS file: /cvs/linux/fs/nfs/file.c,v
retrieving revision 1.52
diff -u -r1.52 file.c
--- fs/nfs/file.c	2000/04/26 09:36:34	1.52
+++ fs/nfs/file.c	2000/05/01 05:32:45
@@ -203,7 +203,8 @@
 	sync_page: nfs_sync_page,
 	writepage: nfs_writepage,
 	prepare_write: nfs_prepare_write,
-	commit_write: nfs_commit_write
+	commit_write: nfs_commit_write,
+	try_to_free_page: filemap_try_to_free_page
 };
 
 /* 
Index: fs/ntfs/fs.c
===================================================================
RCS file: /cvs/linux/fs/ntfs/fs.c,v
retrieving revision 1.30
diff -u -r1.30 fs.c
--- fs/ntfs/fs.c	2000/04/26 09:36:34	1.30
+++ fs/ntfs/fs.c	2000/05/01 05:32:45
@@ -610,6 +610,7 @@
 	sync_page: block_sync_page,
 	prepare_write: ntfs_prepare_write,
 	commit_write: generic_commit_write,
+	try_to_free_page: filemap_try_to_free_page,
 	bmap: _ntfs_bmap
 };
 /* ntfs_read_inode is called by the Virtual File System (the kernel layer that
Index: fs/qnx4/inode.c
===================================================================
RCS file: /cvs/linux/fs/qnx4/inode.c,v
retrieving revision 1.20
diff -u -r1.20 inode.c
--- fs/qnx4/inode.c	2000/04/26 09:36:34	1.20
+++ fs/qnx4/inode.c	2000/05/01 05:32:46
@@ -433,6 +433,7 @@
 	sync_page: block_sync_page,
 	prepare_write: qnx4_prepare_write,
 	commit_write: generic_commit_write,
+	try_to_free_page: filemap_try_to_free_page,
 	bmap: qnx4_bmap
 };
 
Index: fs/ramfs/inode.c
===================================================================
RCS file: /cvs/linux/fs/ramfs/inode.c,v
retrieving revision 1.2
diff -u -r1.2 inode.c
--- fs/ramfs/inode.c	2000/04/26 09:36:34	1.2
+++ fs/ramfs/inode.c	2000/05/01 05:32:46
@@ -324,7 +324,8 @@
 	readpage:	ramfs_readpage,
 	writepage:	ramfs_writepage,
 	prepare_write:	ramfs_prepare_write,
-	commit_write:	ramfs_commit_write
+	commit_write:	ramfs_commit_write,
+	try_to_free_page: filemap_try_to_free_page
 };
 
 static struct file_operations ramfs_file_operations = {
Index: fs/romfs/inode.c
===================================================================
RCS file: /cvs/linux/fs/romfs/inode.c,v
retrieving revision 1.42
diff -u -r1.42 inode.c
--- fs/romfs/inode.c	2000/04/22 00:45:18	1.42
+++ fs/romfs/inode.c	2000/05/01 05:32:47
@@ -428,7 +428,8 @@
 /* Mapping from our types to the kernel */
 
 static struct address_space_operations romfs_aops = {
-	readpage: romfs_readpage
+	readpage: romfs_readpage,
+	try_to_free_page: filemap_try_to_free_page
 };
 
 static struct file_operations romfs_dir_operations = {
Index: fs/smbfs/file.c
===================================================================
RCS file: /cvs/linux/fs/smbfs/file.c,v
retrieving revision 1.38
diff -u -r1.38 file.c
--- fs/smbfs/file.c	2000/04/26 09:36:34	1.38
+++ fs/smbfs/file.c	2000/05/01 05:32:47
@@ -290,7 +290,8 @@
 	readpage: smb_readpage,
 	writepage: smb_writepage,
 	prepare_write: smb_prepare_write,
-	commit_write: smb_commit_write
+	commit_write: smb_commit_write,
+	try_to_free_page: filemap_try_to_free_page
 };
 
 /* 
Index: fs/sysv/inode.c
===================================================================
RCS file: /cvs/linux/fs/sysv/inode.c,v
retrieving revision 1.41
diff -u -r1.41 inode.c
--- fs/sysv/inode.c	2000/04/26 09:36:34	1.41
+++ fs/sysv/inode.c	2000/05/01 05:32:47
@@ -961,6 +961,7 @@
 	sync_page: block_sync_page,
 	prepare_write: sysv_prepare_write,
 	commit_write: generic_commit_write,
+	try_to_free_page: filemap_try_to_free_page,
 	bmap: sysv_bmap
 };
 
Index: fs/udf/file.c
===================================================================
RCS file: /cvs/linux/fs/udf/file.c,v
retrieving revision 1.18
diff -u -r1.18 file.c
--- fs/udf/file.c	2000/04/26 09:36:34	1.18
+++ fs/udf/file.c	2000/05/01 05:32:47
@@ -121,6 +121,7 @@
 	sync_page:		block_sync_page,
 	prepare_write:		udf_adinicb_prepare_write,
 	commit_write:		udf_adinicb_commit_write,
+	try_to_free_page: filemap_try_to_free_page
 };
 
 static ssize_t udf_file_write(struct file * file, const char * buf,
Index: fs/udf/inode.c
===================================================================
RCS file: /cvs/linux/fs/udf/inode.c,v
retrieving revision 1.14
diff -u -r1.14 inode.c
--- fs/udf/inode.c	2000/04/26 09:36:34	1.14
+++ fs/udf/inode.c	2000/05/01 05:32:48
@@ -151,6 +151,7 @@
 	sync_page:		block_sync_page,
 	prepare_write:		udf_prepare_write,
 	commit_write:		generic_commit_write,
+	try_to_free_page: filemap_try_to_free_page,
 	bmap:				udf_bmap,
 };
 
Index: fs/udf/symlink.c
===================================================================
RCS file: /cvs/linux/fs/udf/symlink.c,v
retrieving revision 1.5
diff -u -r1.5 symlink.c
--- fs/udf/symlink.c	2000/03/02 20:37:00	1.5
+++ fs/udf/symlink.c	2000/05/01 05:32:48
@@ -123,4 +123,5 @@
  */
 struct address_space_operations udf_symlink_aops = {
 	readpage:			udf_symlink_filler,
+	try_to_free_page: filemap_try_to_free_page
 };
Index: fs/ufs/inode.c
===================================================================
RCS file: /cvs/linux/fs/ufs/inode.c,v
retrieving revision 1.15
diff -u -r1.15 inode.c
--- fs/ufs/inode.c	2000/04/26 09:36:34	1.15
+++ fs/ufs/inode.c	2000/05/01 05:32:49
@@ -562,6 +562,7 @@
 	sync_page: block_sync_page,
 	prepare_write: ufs_prepare_write,
 	commit_write: generic_commit_write,
+	try_to_free_page: filemap_try_to_free_page,
 	bmap: ufs_bmap
 };
 
Index: include/linux/fs.h
===================================================================
RCS file: /cvs/linux/include/linux/fs.h,v
retrieving revision 1.167
diff -u -r1.167 fs.h
--- include/linux/fs.h	2000/04/26 09:36:35	1.167
+++ include/linux/fs.h	2000/05/01 05:33:01
@@ -343,9 +343,12 @@
 	int (*sync_page)(struct page *);
 	int (*prepare_write)(struct file *, struct page *, unsigned, unsigned);
 	int (*commit_write)(struct file *, struct page *, unsigned, unsigned);
+	int (*try_to_free_page)(struct page *);
 	/* Unfortunately this kludge is needed for FIBMAP. Don't use it */
 	int (*bmap)(struct address_space *, long);
 };
+
+extern int filemap_try_to_free_page(struct page *);
 
 struct address_space {
 	struct list_head	pages;		/* list of pages */
Index: include/linux/mm.h
===================================================================
RCS file: /cvs/linux/include/linux/mm.h,v
retrieving revision 1.115
diff -u -r1.115 mm.h
--- include/linux/mm.h	2000/04/27 02:49:03	1.115
+++ include/linux/mm.h	2000/05/01 05:33:05
@@ -15,8 +15,16 @@
 extern unsigned long num_physpages;
 extern void * high_memory;
 extern int page_cluster;
-extern struct list_head lru_cache;
 
+/*
+ * Active, inactive, and dirty page lru lists.
+ */
+extern struct list_head lru_active;
+extern struct list_head lru_inactive;
+extern struct list_head lru_dirty;
+extern unsigned long inactive_pages;
+extern unsigned long inactive_goal;
+
 #include <asm/page.h>
 #include <asm/pgtable.h>
 #include <asm/atomic.h>
@@ -62,7 +70,11 @@
 	unsigned long vm_pgoff;		/* offset in PAGE_SIZE units, *not* PAGE_CACHE_SIZE */
 	struct file * vm_file;
 	unsigned long vm_raend;
-	void * vm_private_data;		/* was vm_pte (shared mem) */
+
+	/* Anonymous page state. */
+	struct address_space * vm_anon;
+	struct vm_area_struct *vm_anon_next_share;
+	struct vm_area_struct **vm_anon_pprev_share;
 };
 
 /*
@@ -123,11 +135,6 @@
 	int (*swapout)(struct page *, struct file *);
 };
 
-/*
- * A swap entry has to fit into a "unsigned long", as
- * the entry is hidden in the "index" field of the
- * swapper address space.
- */
 typedef struct {
 	unsigned long val;
 } swp_entry_t;
@@ -151,6 +158,7 @@
 	wait_queue_head_t wait;
 	struct page **pprev_hash;
 	struct buffer_head * buffers;
+	swp_entry_t swapid;
 	unsigned long virtual; /* nonzero if kmapped */
 	struct zone_struct *zone;
 } mem_map_t;
@@ -168,7 +176,7 @@
 #define PG_uptodate		 3
 #define PG_dirty		 4
 #define PG_decr_after		 5
-#define PG_unused_01		 6
+#define PG_anon		 	 6
 #define PG__unused_02		 7
 #define PG_slab			 8
 #define PG_swap_cache		 9
@@ -197,6 +205,9 @@
 #define ClearPageError(page)	clear_bit(PG_error, &(page)->flags)
 #define PageReferenced(page)	test_bit(PG_referenced, &(page)->flags)
 #define PageDecrAfter(page)	test_bit(PG_decr_after, &(page)->flags)
+#define PageAnon(page)		test_bit(PG_anon, &(page)->flags)
+#define SetPageAnon(page)	set_bit(PG_anon, &(page)->flags)
+#define ClearPageAnon(page)	clear_bit(PG_anon, &(page)->flags)
 #define PageSlab(page)		test_bit(PG_slab, &(page)->flags)
 #define PageSwapCache(page)	test_bit(PG_swap_cache, &(page)->flags)
 #define PageReserved(page)	test_bit(PG_reserved, &(page)->flags)
@@ -423,7 +434,10 @@
 
 /* mmap.c */
 extern void vma_init(void);
+extern void lock_vma_mappings(struct vm_area_struct *);
+extern void unlock_vma_mappings(struct vm_area_struct *);
 extern void merge_segments(struct mm_struct *, unsigned long, unsigned long);
+extern void __insert_vm_struct(struct mm_struct *, struct vm_area_struct *);
 extern void insert_vm_struct(struct mm_struct *, struct vm_area_struct *);
 extern void build_mmap_avl(struct mm_struct *);
 extern void exit_mmap(struct mm_struct *);
@@ -456,6 +470,18 @@
 extern unsigned long page_unuse(struct page *);
 extern int shrink_mmap(int, int, zone_t *);
 extern void truncate_inode_pages(struct address_space *, loff_t);
+
+/* anon.c */
+extern void __anon_dup(struct vm_area_struct *, struct vm_area_struct *);
+extern void anon_dup(struct vm_area_struct *, struct vm_area_struct *);
+extern void __anon_put(struct vm_area_struct *);
+extern void anon_put(struct vm_area_struct *);
+extern void anon_trim(struct vm_area_struct *);
+extern int try_to_free_anon_page(struct page *);
+extern void anon_page_kill(struct page *);
+extern struct page *anon_cow(struct vm_area_struct *, unsigned long, struct page *);
+extern int anon_page_add(struct vm_area_struct *vma, unsigned long address, struct page *page);
+extern void anon_init(void);
 
 /* generic vm_area_ops exported for stackable file systems */
 extern int filemap_swapout(struct page * page, struct file *file);
Index: include/linux/swap.h
===================================================================
RCS file: /cvs/linux/include/linux/swap.h,v
retrieving revision 1.54
diff -u -r1.54 swap.h
--- include/linux/swap.h	2000/04/27 02:49:03	1.54
+++ include/linux/swap.h	2000/05/01 05:33:10
@@ -69,7 +69,6 @@
 FASTCALL(unsigned int nr_free_highpages(void));
 extern int nr_lru_pages;
 extern atomic_t nr_async_pages;
-extern struct address_space swapper_space;
 extern atomic_t page_cache_size;
 extern atomic_t buffermem_pages;
 
@@ -144,20 +143,49 @@
 #endif
 
 /*
- * Work out if there are any other processes sharing this page, ignoring
- * any page reference coming from the swap cache, or from outstanding
- * swap IO on this page.  (The page cache _does_ count as another valid
- * reference to the page, however.)
+ * Work out if there are any other processes sharing this swapcache page,
+ * ignoring any page reference coming from the swap cache itself, from the
+ * anon caches, or from outstanding swap IO on this page.
  */
-static inline int is_page_shared(struct page *page)
+static inline int is_swappage_shared(struct page *page, int pg_count)
 {
-	unsigned int count;
-	if (PageReserved(page))
-		return 1;
-	count = page_count(page);
-	if (PageSwapCache(page))
-		count += swap_count(page) - 2 - !!page->buffers;
-	return  count > 1;
+	int swap_cnt;
+
+	/* Since the page is in both the anon and
+	 * swap caches, we account for those implicit
+	 * references.
+	 */
+	if (!PageSwapCache(page))
+		BUG();
+	pg_count -= 1;
+
+	if (!PageAnon(page))
+		BUG();
+	pg_count -= 1;
+
+	/* If the page has buffers attached, this is for swap
+	 * I/O, and these buffers have a hold on the page.
+	 */
+	if (page->buffers)
+		pg_count -= 1;
+
+	/* How many holds does the swapcache have on the page?
+	 * We subtract one from this number, for the reference
+	 * held by the swapcache itself.
+	 *
+	 * NOTE: Our caller does not hold a swapcache reference
+	 *       of his own when he calls this.  The caller does
+	 *       have a hold on the page struct though.
+	 */
+	swap_cnt = swap_count(page);
+	if (swap_cnt < 1)
+		BUG();
+
+	pg_count += (swap_cnt - 1);
+	if (pg_count < 1)
+		BUG();
+
+	return pg_count > 1;
 }
 
 extern spinlock_t pagemap_lru_lock;
@@ -168,7 +196,7 @@
 #define	lru_cache_add(page)			\
 do {						\
 	spin_lock(&pagemap_lru_lock);		\
-	list_add(&(page)->lru, &lru_cache);	\
+	list_add(&(page)->lru, &lru_active);	\
 	nr_lru_pages++;				\
 	spin_unlock(&pagemap_lru_lock);		\
 } while (0)
Index: init/main.c
===================================================================
RCS file: /cvs/linux/init/main.c,v
retrieving revision 1.210
diff -u -r1.210 main.c
--- init/main.c	2000/04/25 13:12:26	1.210
+++ init/main.c	2000/05/01 05:33:20
@@ -570,6 +570,7 @@
 	filescache_init();
 	dcache_init(mempages);
 	vma_init();
+	anon_init();
 	buffer_init(mempages);
 	page_cache_init(mempages);
 	kiobuf_setup();
Index: ipc/shm.c
===================================================================
RCS file: /cvs/linux/ipc/shm.c,v
retrieving revision 1.99
diff -u -r1.99 shm.c
--- ipc/shm.c	2000/04/27 02:49:03	1.99
+++ ipc/shm.c	2000/05/01 05:33:21
@@ -1344,6 +1344,7 @@
  */
 static int shm_swapout(struct page * page, struct file *file)
 {
+	UnlockPage(page);
 	return 0;
 }
 
Index: kernel/fork.c
===================================================================
RCS file: /cvs/linux/kernel/fork.c,v
retrieving revision 1.116
diff -u -r1.116 fork.c
--- kernel/fork.c	2000/04/24 07:03:14	1.116
+++ kernel/fork.c	2000/05/01 05:33:22
@@ -270,6 +270,9 @@
 			spin_unlock(&inode->i_mapping->i_shared_lock);
 		}
 
+		if (tmp->vm_anon)
+			anon_dup(mpnt, tmp);
+
 		/* Copy the pages, but defer checking for errors */
 		retval = copy_page_range(mm, current->mm, tmp);
 		if (!retval && tmp->vm_ops && tmp->vm_ops->open)
Index: kernel/ksyms.c
===================================================================
RCS file: /cvs/linux/kernel/ksyms.c,v
retrieving revision 1.174
diff -u -r1.174 ksyms.c
--- kernel/ksyms.c	2000/04/26 09:36:36	1.174
+++ kernel/ksyms.c	2000/05/01 05:33:22
@@ -253,6 +253,7 @@
 EXPORT_SYMBOL(filemap_swapout);
 EXPORT_SYMBOL(filemap_sync);
 EXPORT_SYMBOL(lock_page);
+EXPORT_SYMBOL(filemap_try_to_free_page);
 
 #if !defined(CONFIG_NFSD) && defined(CONFIG_NFSD_MODULE)
 EXPORT_SYMBOL(do_nfsservctl);
Index: mm/Makefile
===================================================================
RCS file: /cvs/linux/mm/Makefile,v
retrieving revision 1.13
diff -u -r1.13 Makefile
--- mm/Makefile	1999/12/20 04:59:33	1.13
+++ mm/Makefile	2000/05/01 05:33:22
@@ -10,7 +10,7 @@
 O_TARGET := mm.o
 O_OBJS	 := memory.o mmap.o filemap.o mprotect.o mlock.o mremap.o \
 	    vmalloc.o slab.o bootmem.o swap.o vmscan.o page_io.o \
-	    page_alloc.o swap_state.o swapfile.o numa.o
+	    page_alloc.o swap_state.o swapfile.o numa.o anon.o
 
 ifeq ($(CONFIG_HIGHMEM),y)
 O_OBJS += highmem.o
Index: mm/filemap.c
===================================================================
RCS file: /cvs/linux/mm/filemap.c,v
retrieving revision 1.144
diff -u -r1.144 filemap.c
--- mm/filemap.c	2000/04/27 02:49:03	1.144
+++ mm/filemap.c	2000/05/01 05:33:23
@@ -44,7 +44,11 @@
 atomic_t page_cache_size = ATOMIC_INIT(0);
 unsigned int page_hash_bits;
 struct page **page_hash_table;
-struct list_head lru_cache;
+struct list_head lru_active;
+struct list_head lru_inactive;
+struct list_head lru_dirty;
+unsigned long inactive_pages;
+unsigned long inactive_goal;
 
 spinlock_t pagecache_lock = SPIN_LOCK_UNLOCKED;
 /*
@@ -236,155 +240,24 @@
 	spin_unlock(&pagecache_lock);
 }
 
-int shrink_mmap(int priority, int gfp_mask, zone_t *zone)
+int filemap_try_to_free_page(struct page *page)
 {
-	int ret = 0, loop = 0, count;
-	LIST_HEAD(young);
-	LIST_HEAD(old);
-	LIST_HEAD(forget);
-	struct list_head * page_lru, * dispose;
-	struct page * page = NULL;
-	struct zone_struct * p_zone;
-	int maxloop = 256 >> priority;
-	
-	if (!zone)
-		BUG();
-
-	count = nr_lru_pages >> priority;
-	if (!count)
-		return ret;
-
-	spin_lock(&pagemap_lru_lock);
-again:
-	/* we need pagemap_lru_lock for list_del() ... subtle code below */
-	while (count > 0 && (page_lru = lru_cache.prev) != &lru_cache) {
-		page = list_entry(page_lru, struct page, lru);
-		list_del(page_lru);
-		p_zone = page->zone;
-
-		/*
-		 * These two tests are there to make sure we don't free too
-		 * many pages from the "wrong" zone. We free some anyway,
-		 * they are the least recently used pages in the system.
-		 * When we don't free them, leave them in &old.
-		 */
-		dispose = &old;
-		if (p_zone != zone && (loop > (maxloop / 4) ||
-				p_zone->free_pages > p_zone->pages_high))
-			goto dispose_continue;
-
-		/* The page is in use, or was used very recently, put it in
-		 * &young to make sure that we won't try to free it the next
-		 * time */
-		dispose = &young;
-
-		if (test_and_clear_bit(PG_referenced, &page->flags))
-			goto dispose_continue;
-
-		count--;
-		if (!page->buffers && page_count(page) > 1)
-			goto dispose_continue;
-
-		/* Page not used -> free it; if that fails -> &old */
-		dispose = &old;
-		if (TryLockPage(page))
-			goto dispose_continue;
+	int ret = 0;
 
-		/* Release the pagemap_lru lock even if the page is not yet
-		   queued in any lru queue since we have just locked down
-		   the page so nobody else may SMP race with us running
-		   a lru_cache_del() (lru_cache_del() always run with the
-		   page locked down ;). */
-		spin_unlock(&pagemap_lru_lock);
-
-		/* avoid freeing the page while it's locked */
-		get_page(page);
-
-		/* Is it a buffer page? */
-		if (page->buffers) {
-			if (!try_to_free_buffers(page))
-				goto unlock_continue;
-			/* page was locked, inode can't go away under us */
-			if (!page->mapping) {
-				atomic_dec(&buffermem_pages);
-				goto made_buffer_progress;
-			}
-		}
-
-		/* Take the pagecache_lock spinlock held to avoid
-		   other tasks to notice the page while we are looking at its
-		   page count. If it's a pagecache-page we'll free it
-		   in one atomic transaction after checking its page count. */
-		spin_lock(&pagecache_lock);
-
-		/*
-		 * We can't free pages unless there's just one user
-		 * (count == 2 because we added one ourselves above).
-		 */
-		if (page_count(page) != 2)
-			goto cache_unlock_continue;
-
-		/*
-		 * Is it a page swap page? If so, we want to
-		 * drop it if it is no longer used, even if it
-		 * were to be marked referenced..
-		 */
-		if (PageSwapCache(page)) {
-			spin_unlock(&pagecache_lock);
-			__delete_from_swap_cache(page);
-			goto made_inode_progress;
-		}	
-
-		/* is it a page-cache page? */
-		if (page->mapping) {
-			if (!PageDirty(page) && !pgcache_under_min()) {
-				remove_page_from_inode_queue(page);
-				remove_page_from_hash_queue(page);
-				page->mapping = NULL;
-				spin_unlock(&pagecache_lock);
-				goto made_inode_progress;
-			}
-			goto cache_unlock_continue;
-		}
-
-		dispose = &forget;
-		printk(KERN_ERR "shrink_mmap: unknown LRU page!\n");
-
-cache_unlock_continue:
-		spin_unlock(&pagecache_lock);
-unlock_continue:
-		spin_lock(&pagemap_lru_lock);
-		UnlockPage(page);
-		put_page(page);
-		list_add(page_lru, dispose);
-		continue;
+	if (page_count(page) <= 1)
+		BUG();
 
-		/* we're holding pagemap_lru_lock, so we can just loop again */
-dispose_continue:
-		list_add(page_lru, dispose);
+	spin_lock(&pagecache_lock);
+	if (page_count(page) == 2 && !PageDirty(page) && !pgcache_under_min()) {
+		remove_page_from_inode_queue(page);
+		remove_page_from_hash_queue(page);
+		page->mapping = NULL;
+		ret = 1;
 	}
-	goto out;
-
-made_inode_progress:
-	page_cache_release(page);
-made_buffer_progress:
-	UnlockPage(page);
-	put_page(page);
-	ret = 1;
-	spin_lock(&pagemap_lru_lock);
-	/* nr_lru_pages needs the spinlock */
-	nr_lru_pages--;
-
-	loop++;
-	/* wrong zone?  not looped too often?    roll again... */
-	if (page->zone != zone && loop < maxloop)
-		goto again;
-
-out:
-	list_splice(&young, &lru_cache);
-	list_splice(&old, lru_cache.prev);
+	spin_unlock(&pagecache_lock);
 
-	spin_unlock(&pagemap_lru_lock);
+	if (ret == 1)
+		page_cache_release(page);
 
 	return ret;
 }
@@ -1435,13 +1308,13 @@
 	 */
 	old_page = page;
 	if (no_share) {
-		struct page *new_page = page_cache_alloc();
+		struct page *new_page = anon_cow(area, address, old_page);
 
-		if (new_page) {
-			copy_user_highpage(new_page, old_page, address);
+		if (new_page)
 			flush_page_to_ram(new_page);
-		} else
+		else
 			new_page = NOPAGE_OOM;
+
 		page_cache_release(page);
 		return new_page;
 	}
@@ -1523,7 +1396,6 @@
 			      struct page * page,
 			      int wait)
 {
-	int result;
 	struct dentry * dentry;
 	struct inode * inode;
 
@@ -1536,10 +1408,10 @@
 	 * vma/file is guaranteed to exist in the unmap/sync cases because
 	 * mmap_sem is held.
 	 */
-	lock_page(page);
-	result = inode->i_mapping->a_ops->writepage(file, dentry, page);
-	UnlockPage(page);
-	return result;
+	if (!PageLocked(page))
+		BUG();
+
+	return inode->i_mapping->a_ops->writepage(file, dentry, page);
 }
 
 
@@ -1547,11 +1419,19 @@
  * The page cache takes care of races between somebody
  * trying to swap something out and swap something in
  * at the same time..
+ *
+ * We get invoked with the page already locked.
  */
 extern void wakeup_bdflush(int);
 int filemap_swapout(struct page * page, struct file * file)
 {
-	int retval = filemap_write_page(file, page->index, page, 0);
+	int retval;
+
+	if (!PageLocked(page))
+		BUG();
+
+	retval = filemap_write_page(file, page->index, page, 0);
+	UnlockPage(page);
 	wakeup_bdflush(0);
 	return retval;
 }
@@ -1597,7 +1477,11 @@
 		printk("weirdness: pgoff=%lu index=%lu address=%lu vm_start=%lu vm_pgoff=%lu\n",
 			pgoff, page->index, address, vma->vm_start, vma->vm_pgoff);
 	}
+
+	lock_page(page);
 	error = filemap_write_page(vma->vm_file, pgoff, page, 1);
+	UnlockPage(page);
+
 	page_cache_free(page);
 	return error;
 }
@@ -1846,11 +1730,15 @@
 	get_file(n->vm_file);
 	if (n->vm_ops && n->vm_ops->open)
 		n->vm_ops->open(n);
+	lock_vma_mappings(vma);
 	vmlist_modify_lock(vma->vm_mm);
 	vma->vm_pgoff += (end - vma->vm_start) >> PAGE_SHIFT;
 	vma->vm_start = end;
-	insert_vm_struct(current->mm, n);
+	__insert_vm_struct(current->mm, n);
+	if (vma->vm_anon)
+		__anon_dup(vma, n);
 	vmlist_modify_unlock(vma->vm_mm);
+	unlock_vma_mappings(vma);
 	return 0;
 }
 
@@ -1870,10 +1758,14 @@
 	get_file(n->vm_file);
 	if (n->vm_ops && n->vm_ops->open)
 		n->vm_ops->open(n);
+	lock_vma_mappings(vma);
 	vmlist_modify_lock(vma->vm_mm);
 	vma->vm_end = start;
-	insert_vm_struct(current->mm, n);
+	__insert_vm_struct(current->mm, n);
+	if (vma->vm_anon)
+		__anon_dup(vma, n);
 	vmlist_modify_unlock(vma->vm_mm);
+	unlock_vma_mappings(vma);
 	return 0;
 }
 
@@ -1903,15 +1795,21 @@
 		vma->vm_ops->open(left);
 		vma->vm_ops->open(right);
 	}
+	lock_vma_mappings(vma);
 	vmlist_modify_lock(vma->vm_mm);
 	vma->vm_pgoff += (start - vma->vm_start) >> PAGE_SHIFT;
 	vma->vm_start = start;
 	vma->vm_end = end;
 	setup_read_behavior(vma, behavior);
 	vma->vm_raend = 0;
-	insert_vm_struct(current->mm, left);
-	insert_vm_struct(current->mm, right);
+	__insert_vm_struct(current->mm, left);
+	__insert_vm_struct(current->mm, right);
+	if (vma->vm_anon) {
+		__anon_dup(vma, left);
+		__anon_dup(vma, right);
+	}
 	vmlist_modify_unlock(vma->vm_mm);
+	unlock_vma_mappings(vma);
 	return 0;
 }
 
Index: mm/highmem.c
===================================================================
RCS file: /cvs/linux/mm/highmem.c,v
retrieving revision 1.12
diff -u -r1.12 highmem.c
--- mm/highmem.c	2000/03/24 01:33:30	1.12
+++ mm/highmem.c	2000/05/01 05:33:23
@@ -74,6 +74,7 @@
 	kunmap(highpage);
 
 	/* Preserve the caching of the swap_entry. */
+#error This does not work with the new anon cache, FIXME -DaveM
 	highpage->index = page->index;
 	highpage->mapping = page->mapping;
 
Index: mm/memory.c
===================================================================
RCS file: /cvs/linux/mm/memory.c,v
retrieving revision 1.111
diff -u -r1.111 memory.c
--- mm/memory.c	2000/04/25 04:13:29	1.111
+++ mm/memory.c	2000/05/01 05:33:24
@@ -53,20 +53,6 @@
 void * high_memory = NULL;
 struct page *highmem_start_page;
 
-/*
- * We special-case the C-O-W ZERO_PAGE, because it's such
- * a common occurrence (no need to read the page to know
- * that it's zero - better for the cache and memory subsystem).
- */
-static inline void copy_cow_page(struct page * from, struct page * to, unsigned long address)
-{
-	if (from == ZERO_PAGE(address)) {
-		clear_user_highpage(to, address);
-		return;
-	}
-	copy_user_highpage(to, from, address);
-}
-
 mem_map_t * mem_map = NULL;
 
 /*
@@ -786,10 +772,9 @@
 	update_mmu_cache(vma, address, entry);
 }
 
-static inline void break_cow(struct vm_area_struct * vma, struct page *	old_page, struct page * new_page, unsigned long address, 
+static inline void break_cow(struct vm_area_struct * vma, struct page * new_page, unsigned long address, 
 		pte_t *page_table)
 {
-	copy_cow_page(old_page,new_page,address);
 	flush_page_to_ram(new_page);
 	flush_cache_page(vma, address);
 	establish_pte(vma, address, page_table, pte_mkwrite(pte_mkdirty(mk_pte(new_page, vma->vm_page_prot))));
@@ -820,6 +805,7 @@
 {
 	unsigned long map_nr;
 	struct page *old_page, *new_page;
+	int count;
 
 	map_nr = pte_pagenr(pte);
 	if (map_nr >= max_mapnr)
@@ -835,7 +821,10 @@
 	 *   in which case we can remove the page
 	 *   from the swap cache.
 	 */
-	switch (page_count(old_page)) {
+	count = page_count(old_page);
+	if (PageAnon(old_page))
+		count -= 1;
+	switch (count) {
 	case 2:
 		/*
 		 * Lock the page so that no one can look it up from
@@ -844,7 +833,7 @@
 		 */
 		if (!PageSwapCache(old_page) || TryLockPage(old_page))
 			break;
-		if (is_page_shared(old_page)) {
+		if (is_swappage_shared(old_page, page_count(old_page))) {
 			UnlockPage(old_page);
 			break;
 		}
@@ -862,9 +851,12 @@
 	 * Ok, we need to copy. Oh, well..
 	 */
 	spin_unlock(&mm->page_table_lock);
-	new_page = alloc_page(GFP_HIGHUSER);
+
+	/* NOTE: This performs the page copy for us. */
+	new_page = anon_cow(vma, address, old_page);
 	if (!new_page)
 		return -1;
+
 	spin_lock(&mm->page_table_lock);
 
 	/*
@@ -873,13 +865,17 @@
 	if (pte_val(*page_table) == pte_val(pte)) {
 		if (PageReserved(old_page))
 			++mm->rss;
-		break_cow(vma, old_page, new_page, address, page_table);
+		break_cow(vma, new_page, address, page_table);
+
+		spin_unlock(&mm->page_table_lock);
 
 		/* Free the old page.. */
-		new_page = old_page;
+		__free_page(old_page);
+	} else {
+		spin_unlock(&mm->page_table_lock);
+		anon_page_kill(new_page);
 	}
-	spin_unlock(&mm->page_table_lock);
-	__free_page(new_page);
+
 	return 1;
 
 bad_wp_page:
@@ -1016,8 +1012,11 @@
 	for (i = 0; i < num; offset++, i++) {
 		/* Don't block on I/O for read-ahead */
 		if (atomic_read(&nr_async_pages) >= pager_daemon.swap_cluster) {
-			while (i++ < num)
-				swap_free(SWP_ENTRY(SWP_TYPE(entry), offset++));
+			while (i < num) {
+				swap_free(SWP_ENTRY(SWP_TYPE(entry), offset));
+				offset++;
+				i++;
+			}
 			break;
 		}
 		/* Ok, do the async read-ahead now */
@@ -1051,6 +1050,11 @@
 	mm->rss++;
 	mm->min_flt++;
 
+	if (anon_page_add(vma, address, page)) {
+		__free_page(page);
+		return -1;
+	}
+
 	pte = mk_pte(page, vma->vm_page_prot);
 
 	SetPageSwapEntry(page);
@@ -1061,8 +1065,13 @@
 	 * obtained page count.
 	 */
 	lock_page(page);
+
+	/* Transition of pte from not present to present
+	 * drops one swapcache reference.
+	 */
 	swap_free(entry);
-	if (write_access && !is_page_shared(page)) {
+
+	if (write_access && !is_swappage_shared(page, page_count(page))) {
 		delete_from_swap_cache_nolock(page);
 		UnlockPage(page);
 		page = replace_with_highmem(page);
@@ -1082,16 +1091,14 @@
  */
 static int do_anonymous_page(struct mm_struct * mm, struct vm_area_struct * vma, pte_t *page_table, int write_access, unsigned long addr)
 {
-	int high = 0;
 	struct page *page = NULL;
 	pte_t entry = pte_wrprotect(mk_pte(ZERO_PAGE(addr), vma->vm_page_prot));
+
 	if (write_access) {
-		page = alloc_page(GFP_HIGHUSER);
+		/* NOTE: This will zero out the page for us. */
+		page = anon_cow(vma, addr, ZERO_PAGE(addr));
 		if (!page)
 			return -1;
-		if (PageHighMem(page))
-			high = 1;
-		clear_user_highpage(page, addr);
 		entry = pte_mkwrite(pte_mkdirty(mk_pte(page, vma->vm_page_prot)));
 		mm->rss++;
 		mm->min_flt++;
Index: mm/mlock.c
===================================================================
RCS file: /cvs/linux/mm/mlock.c,v
retrieving revision 1.28
diff -u -r1.28 mlock.c
--- mm/mlock.c	2000/03/15 02:44:43	1.28
+++ mm/mlock.c	2000/05/01 05:33:24
@@ -36,11 +36,15 @@
 		get_file(n->vm_file);
 	if (n->vm_ops && n->vm_ops->open)
 		n->vm_ops->open(n);
+	lock_vma_mappings(vma);
 	vmlist_modify_lock(vma->vm_mm);
 	vma->vm_pgoff += (end - vma->vm_start) >> PAGE_SHIFT;
 	vma->vm_start = end;
-	insert_vm_struct(current->mm, n);
+	__insert_vm_struct(current->mm, n);
+	if (vma->vm_anon)
+		__anon_dup(vma, n);
 	vmlist_modify_unlock(vma->vm_mm);
+	unlock_vma_mappings(vma);
 	return 0;
 }
 
@@ -61,10 +65,14 @@
 		get_file(n->vm_file);
 	if (n->vm_ops && n->vm_ops->open)
 		n->vm_ops->open(n);
+	lock_vma_mappings(vma);
 	vmlist_modify_lock(vma->vm_mm);
 	vma->vm_end = start;
-	insert_vm_struct(current->mm, n);
+	__insert_vm_struct(current->mm, n);
+	if (vma->vm_anon)
+		__anon_dup(vma, n);
 	vmlist_modify_unlock(vma->vm_mm);
+	unlock_vma_mappings(vma);
 	return 0;
 }
 
@@ -96,15 +104,21 @@
 		vma->vm_ops->open(left);
 		vma->vm_ops->open(right);
 	}
+	lock_vma_mappings(vma);
 	vmlist_modify_lock(vma->vm_mm);
 	vma->vm_pgoff += (start - vma->vm_start) >> PAGE_SHIFT;
 	vma->vm_start = start;
 	vma->vm_end = end;
 	vma->vm_flags = newflags;
 	vma->vm_raend = 0;
-	insert_vm_struct(current->mm, left);
-	insert_vm_struct(current->mm, right);
+	__insert_vm_struct(current->mm, left);
+	__insert_vm_struct(current->mm, right);
+	if (vma->vm_anon) {
+		__anon_dup(vma, left);
+		__anon_dup(vma, right);
+	}
 	vmlist_modify_unlock(vma->vm_mm);
+	unlock_vma_mappings(vma);
 	return 0;
 }
 
Index: mm/mmap.c
===================================================================
RCS file: /cvs/linux/mm/mmap.c,v
retrieving revision 1.96
diff -u -r1.96 mmap.c
--- mm/mmap.c	2000/04/27 02:49:03	1.96
+++ mm/mmap.c	2000/05/01 05:33:25
@@ -70,7 +70,7 @@
 }
 
 /* Remove one vm structure from the inode's i_mmap ring. */
-static inline void remove_shared_vm_struct(struct vm_area_struct *vma)
+static inline void __remove_shared_vm_struct(struct vm_area_struct *vma)
 {
 	struct file * file = vma->vm_file;
 
@@ -78,14 +78,47 @@
 		struct inode *inode = file->f_dentry->d_inode;
 		if (vma->vm_flags & VM_DENYWRITE)
 			atomic_inc(&inode->i_writecount);
-		spin_lock(&inode->i_mapping->i_shared_lock);
 		if(vma->vm_next_share)
 			vma->vm_next_share->vm_pprev_share = vma->vm_pprev_share;
 		*vma->vm_pprev_share = vma->vm_next_share;
-		spin_unlock(&inode->i_mapping->i_shared_lock);
 	}
 }
 
+static inline void remove_shared_vm_struct(struct vm_area_struct *vma)
+{
+	lock_vma_mappings(vma);
+	__remove_shared_vm_struct(vma);
+	unlock_vma_mappings(vma);
+}
+
+void lock_vma_mappings(struct vm_area_struct *vma)
+{
+	struct address_space *file_map, *anon_map;
+
+	anon_map = vma->vm_anon;
+	file_map = NULL;
+	if (vma->vm_file)
+		file_map = vma->vm_file->f_dentry->d_inode->i_mapping;
+	if (anon_map)
+		spin_lock(&anon_map->i_shared_lock);
+	if (file_map)
+		spin_lock(&file_map->i_shared_lock);
+}
+
+void unlock_vma_mappings(struct vm_area_struct *vma)
+{
+	struct address_space *file_map, *anon_map;
+
+	anon_map = vma->vm_anon;
+	file_map = NULL;
+	if (vma->vm_file)
+		file_map = vma->vm_file->f_dentry->d_inode->i_mapping;
+	if (file_map)
+		spin_unlock(&file_map->i_shared_lock);
+	if (anon_map)
+		spin_unlock(&anon_map->i_shared_lock);
+}
+
 /*
  *  sys_brk() for the most part doesn't need the global kernel
  *  lock, except when an application is doing something nasty
@@ -277,7 +310,7 @@
 	vma->vm_ops = NULL;
 	vma->vm_pgoff = pgoff;
 	vma->vm_file = NULL;
-	vma->vm_private_data = NULL;
+	vma->vm_anon = NULL;
 
 	/* Clear old maps */
 	error = -ENOMEM;
@@ -327,11 +360,20 @@
 	 * after the call.  Save the values we need now ...
 	 */
 	flags = vma->vm_flags;
-	addr = vma->vm_start; /* can addr have changed?? */
+
+	/* Can addr have changed??
+	 *
+	 * Answer: Yes, several device drivers can do it in their
+	 *         f_op->mmap method. -DaveM
+	 */
+	addr = vma->vm_start;
+
+	lock_vma_mappings(vma);
 	vmlist_modify_lock(mm);
-	insert_vm_struct(mm, vma);
+	__insert_vm_struct(mm, vma);
 	merge_segments(mm, vma->vm_start, vma->vm_end);
 	vmlist_modify_unlock(mm);
+	unlock_vma_mappings(vma);
 	
 	mm->total_vm += len >> PAGE_SHIFT;
 	if (flags & VM_LOCKED) {
@@ -534,6 +576,8 @@
 			area->vm_ops->close(area);
 		if (area->vm_file)
 			fput(area->vm_file);
+		if (area->vm_anon)
+			anon_put(area);
 		kmem_cache_free(vm_area_cachep, area);
 		return extra;
 	}
@@ -541,10 +585,12 @@
 	/* Work out to one of the ends. */
 	if (end == area->vm_end) {
 		area->vm_end = addr;
+		lock_vma_mappings(area);
 		vmlist_modify_lock(mm);
 	} else if (addr == area->vm_start) {
 		area->vm_pgoff += (end - area->vm_start) >> PAGE_SHIFT;
 		area->vm_start = end;
+		lock_vma_mappings(area);
 		vmlist_modify_lock(mm);
 	} else {
 	/* Unmapping a hole: area->vm_start < addr <= end < area->vm_end */
@@ -561,18 +607,25 @@
 		mpnt->vm_ops = area->vm_ops;
 		mpnt->vm_pgoff = area->vm_pgoff + ((end - area->vm_start) >> PAGE_SHIFT);
 		mpnt->vm_file = area->vm_file;
-		mpnt->vm_private_data = area->vm_private_data;
+		mpnt->vm_anon = area->vm_anon;
 		if (mpnt->vm_file)
 			get_file(mpnt->vm_file);
+		if (mpnt->vm_anon)
+			anon_dup(area, mpnt);
 		if (mpnt->vm_ops && mpnt->vm_ops->open)
 			mpnt->vm_ops->open(mpnt);
 		area->vm_end = addr;	/* Truncate area */
+		lock_vma_mappings(area);
 		vmlist_modify_lock(mm);
-		insert_vm_struct(mm, mpnt);
+		__insert_vm_struct(mm, mpnt);
 	}
+
+	if (area->vm_anon)
+		anon_trim(area);
 
-	insert_vm_struct(mm, area);
+	__insert_vm_struct(mm, area);
 	vmlist_modify_unlock(mm);
+	unlock_vma_mappings(area);
 	return extra;
 }
 
@@ -800,7 +853,7 @@
 	vma->vm_ops = NULL;
 	vma->vm_pgoff = 0;
 	vma->vm_file = NULL;
-	vma->vm_private_data = NULL;
+	vma->vm_anon = NULL;
 
 	/*
 	 * merge_segments may merge our vma, so we can't refer to it
@@ -809,10 +862,12 @@
 	flags = vma->vm_flags;
 	addr = vma->vm_start;
 
+	lock_vma_mappings(vma);
 	vmlist_modify_lock(mm);
-	insert_vm_struct(mm, vma);
+	__insert_vm_struct(mm, vma);
 	merge_segments(mm, vma->vm_start, vma->vm_end);
 	vmlist_modify_unlock(mm);
+	unlock_vma_mappings(vma);
 	
 	mm->total_vm += len >> PAGE_SHIFT;
 	if (flags & VM_LOCKED) {
@@ -862,6 +917,8 @@
 		zap_page_range(mm, start, size);
 		if (mpnt->vm_file)
 			fput(mpnt->vm_file);
+		if (mpnt->vm_anon)
+			anon_put(mpnt);
 		kmem_cache_free(vm_area_cachep, mpnt);
 		mpnt = next;
 	}
@@ -874,9 +931,10 @@
 }
 
 /* Insert vm structure into process list sorted by address
- * and into the inode's i_mmap ring.
+ * and into the inode's i_mmap ring.  If vm_file is non-NULL
+ * then the i_shared_lock must be held here.
  */
-void insert_vm_struct(struct mm_struct *mm, struct vm_area_struct *vmp)
+void __insert_vm_struct(struct mm_struct *mm, struct vm_area_struct *vmp)
 {
 	struct vm_area_struct **pprev;
 	struct file * file;
@@ -907,15 +965,20 @@
 			atomic_dec(&inode->i_writecount);
       
 		/* insert vmp into inode's share list */
-		spin_lock(&mapping->i_shared_lock);
 		if((vmp->vm_next_share = mapping->i_mmap) != NULL)
 			mapping->i_mmap->vm_pprev_share = &vmp->vm_next_share;
 		mapping->i_mmap = vmp;
 		vmp->vm_pprev_share = &mapping->i_mmap;
-		spin_unlock(&mapping->i_shared_lock);
 	}
 }
 
+void insert_vm_struct(struct mm_struct *mm, struct vm_area_struct *vmp)
+{
+	lock_vma_mappings(vmp);
+	__insert_vm_struct(mm, vmp);
+	unlock_vma_mappings(vmp);
+}
+
 /* Merge the list of memory segments if possible.
  * Redundant vm_area_structs are freed.
  * This assumes that the list is ordered by address.
@@ -948,12 +1011,19 @@
 
 		/* To share, we must have the same file, operations.. */
 		if ((mpnt->vm_file != prev->vm_file)||
-		    (mpnt->vm_private_data != prev->vm_private_data)	||
 		    (mpnt->vm_ops != prev->vm_ops)	||
 		    (mpnt->vm_flags != prev->vm_flags)	||
 		    (prev->vm_end != mpnt->vm_start))
 			continue;
 
+		/* If both have a vm_anon, they must be the same.
+		 * It is OK for one to be NULL.
+		 */
+		if (mpnt->vm_anon &&
+		    prev->vm_anon &&
+		    (mpnt->vm_anon != prev->vm_anon))
+			continue;
+
 		/*
 		 * If we have a file or it's a shared memory area
 		 * the offsets must be contiguous..
@@ -976,14 +1046,21 @@
 		if (mpnt->vm_ops && mpnt->vm_ops->close) {
 			mpnt->vm_pgoff += (mpnt->vm_end - mpnt->vm_start) >> PAGE_SHIFT;
 			mpnt->vm_start = mpnt->vm_end;
+			unlock_vma_mappings(mpnt);
 			vmlist_modify_unlock(mm);
 			mpnt->vm_ops->close(mpnt);
 			vmlist_modify_lock(mm);
+			lock_vma_mappings(mpnt);
 		}
 		mm->map_count--;
-		remove_shared_vm_struct(mpnt);
+		__remove_shared_vm_struct(mpnt);
 		if (mpnt->vm_file)
 			fput(mpnt->vm_file);
+		if (mpnt->vm_anon) {
+			if (!prev->vm_anon)
+				__anon_dup(mpnt, prev);
+			__anon_put(mpnt);
+		}
 		kmem_cache_free(vm_area_cachep, mpnt);
 		mpnt = prev;
 	}
Index: mm/mprotect.c
===================================================================
RCS file: /cvs/linux/mm/mprotect.c,v
retrieving revision 1.27
diff -u -r1.27 mprotect.c
--- mm/mprotect.c	2000/03/15 02:44:44	1.27
+++ mm/mprotect.c	2000/05/01 05:33:25
@@ -111,11 +111,15 @@
 		get_file(n->vm_file);
 	if (n->vm_ops && n->vm_ops->open)
 		n->vm_ops->open(n);
+	lock_vma_mappings(vma);
 	vmlist_modify_lock(vma->vm_mm);
 	vma->vm_pgoff += (end - vma->vm_start) >> PAGE_SHIFT;
 	vma->vm_start = end;
-	insert_vm_struct(current->mm, n);
+	__insert_vm_struct(current->mm, n);
+	if (vma->vm_anon)
+		__anon_dup(vma, n);
 	vmlist_modify_unlock(vma->vm_mm);
+	unlock_vma_mappings(vma);
 	return 0;
 }
 
@@ -138,10 +142,14 @@
 		get_file(n->vm_file);
 	if (n->vm_ops && n->vm_ops->open)
 		n->vm_ops->open(n);
+	lock_vma_mappings(vma);
 	vmlist_modify_lock(vma->vm_mm);
 	vma->vm_end = start;
-	insert_vm_struct(current->mm, n);
+	__insert_vm_struct(current->mm, n);
+	if (vma->vm_anon)
+		__anon_dup(vma, n);
 	vmlist_modify_unlock(vma->vm_mm);
+	unlock_vma_mappings(vma);
 	return 0;
 }
 
@@ -172,6 +180,7 @@
 		vma->vm_ops->open(left);
 		vma->vm_ops->open(right);
 	}
+	lock_vma_mappings(vma);
 	vmlist_modify_lock(vma->vm_mm);
 	vma->vm_pgoff += (start - vma->vm_start) >> PAGE_SHIFT;
 	vma->vm_start = start;
@@ -179,9 +188,14 @@
 	vma->vm_flags = newflags;
 	vma->vm_raend = 0;
 	vma->vm_page_prot = prot;
-	insert_vm_struct(current->mm, left);
-	insert_vm_struct(current->mm, right);
+	__insert_vm_struct(current->mm, left);
+	__insert_vm_struct(current->mm, right);
+	if (vma->vm_anon) {
+		__anon_dup(vma, left);
+		__anon_dup(vma, right);
+	}
 	vmlist_modify_unlock(vma->vm_mm);
+	unlock_vma_mappings(vma);
 	return 0;
 }
 
Index: mm/mremap.c
===================================================================
RCS file: /cvs/linux/mm/mremap.c,v
retrieving revision 1.34
diff -u -r1.34 mremap.c
--- mm/mremap.c	2000/04/27 02:49:03	1.34
+++ mm/mremap.c	2000/05/01 05:33:25
@@ -141,10 +141,14 @@
 				get_file(new_vma->vm_file);
 			if (new_vma->vm_ops && new_vma->vm_ops->open)
 				new_vma->vm_ops->open(new_vma);
+			lock_vma_mappings(vma);
 			vmlist_modify_lock(current->mm);
-			insert_vm_struct(current->mm, new_vma);
+			__insert_vm_struct(current->mm, new_vma);
+			if (vma->vm_anon)
+				__anon_dup(vma, new_vma);
 			merge_segments(current->mm, new_vma->vm_start, new_vma->vm_end);
 			vmlist_modify_unlock(vma->vm_mm);
+			unlock_vma_mappings(vma);
 			do_munmap(current->mm, addr, old_len);
 			current->mm->total_vm += new_len >> PAGE_SHIFT;
 			if (new_vma->vm_flags & VM_LOCKED) {
Index: mm/page_alloc.c
===================================================================
RCS file: /cvs/linux/mm/page_alloc.c,v
retrieving revision 1.85
diff -u -r1.85 page_alloc.c
--- mm/page_alloc.c	2000/04/27 02:49:03	1.85
+++ mm/page_alloc.c	2000/05/01 05:33:26
@@ -24,6 +24,8 @@
 #define NUMNODES numnodes
 #endif
 
+extern int nr_anon_pages;
+
 int nr_swap_pages = 0;
 int nr_lru_pages = 0;
 pg_data_t *pgdat_list = (pg_data_t *)0;
@@ -273,8 +275,6 @@
 struct page * __alloc_pages(zonelist_t *zonelist, unsigned long order)
 {
 	zone_t **zone = zonelist->zones;
-	int gfp_mask = zonelist->gfp_mask;
-	static int low_on_memory;
 
 	/*
 	 * If this is a recursive call, we'd better
@@ -284,11 +284,6 @@
 	if (current->flags & PF_MEMALLOC)
 		goto allocate_ok;
 
-	/* If we're a memory hog, unmap some pages */
-	if (current->hog && low_on_memory &&
-			(gfp_mask & __GFP_WAIT))
-		swap_out(4, gfp_mask);
-
 	/*
 	 * (If anyone calls gfp from interrupts nonatomically then it
 	 * will sooner or later tripped up by a schedule().)
@@ -306,13 +301,11 @@
 		/* Are we supposed to free memory? Don't make it worse.. */
 		if (!z->zone_wake_kswapd && z->free_pages > z->pages_low) {
 			struct page *page = rmqueue(z, order);
-			low_on_memory = 0;
 			if (page)
 				return page;
 		}
 	}
 
-	low_on_memory = 1;
 	/*
 	 * Ok, no obvious zones were available, start
 	 * balancing things a bit..
@@ -396,8 +389,9 @@
 		nr_free_pages() << (PAGE_SHIFT-10),
 		nr_free_highpages() << (PAGE_SHIFT-10));
 
-	printk("( Free: %d, lru_cache: %d (%d %d %d) )\n",
+	printk("( Free: %d, anon: %d lru_cache: %d (%d %d %d) )\n",
 		nr_free_pages(),
+	        nr_anon_pages,
 		nr_lru_pages,
 		freepages.min,
 		freepages.low,
@@ -539,7 +533,11 @@
 	freepages.min += i;
 	freepages.low += i * 2;
 	freepages.high += i * 3;
-	memlist_init(&lru_cache);
+	memlist_init(&lru_active);
+	memlist_init(&lru_inactive);
+	memlist_init(&lru_dirty);
+	inactive_pages = 0;
+	inactive_goal = realtotalpages / 3;
 
 	/*
 	 * Some architectures (with lots of mem and discontinous memory
Index: mm/page_io.c
===================================================================
RCS file: /cvs/linux/mm/page_io.c,v
retrieving revision 1.35
diff -u -r1.35 page_io.c
--- mm/page_io.c	1999/12/20 04:59:39	1.35
+++ mm/page_io.c	2000/05/01 05:33:26
@@ -89,8 +89,9 @@
  		return 1;
 
  	wait_on_page(page);
+
 	/* This shouldn't happen, but check to be sure. */
-	if (page_count(page) == 0)
+	if (page_count(page) <= 1)
 		printk(KERN_ERR "rw_swap_page: page unused while waiting!\n");
 
 	return 1;
@@ -101,21 +102,21 @@
  * that all swap pages go through the swap cache! We verify that:
  *  - the page is locked
  *  - it's marked as being swap-cache
- *  - it's associated with the swap inode
+ *  - if we're writing, it is in the anon cache
+ *  - it has a valid swap handle
  */
 void rw_swap_page(int rw, struct page *page, int wait)
 {
-	swp_entry_t entry;
-
-	entry.val = page->index;
-
 	if (!PageLocked(page))
 		PAGE_BUG(page);
 	if (!PageSwapCache(page))
 		PAGE_BUG(page);
-	if (page->mapping != &swapper_space)
+	if (rw == WRITE && !PageAnon(page))
 		PAGE_BUG(page);
-	if (!rw_swap_page_base(rw, entry, page, wait))
+	if (!page->swapid.val)
+		PAGE_BUG(page);
+
+	if (!rw_swap_page_base(rw, page->swapid, page, wait))
 		UnlockPage(page);
 }
 
Index: mm/swap_state.c
===================================================================
RCS file: /cvs/linux/mm/swap_state.c,v
retrieving revision 1.35
diff -u -r1.35 swap_state.c
--- mm/swap_state.c	2000/04/26 09:36:36	1.35
+++ mm/swap_state.c	2000/05/01 05:33:26
@@ -5,6 +5,7 @@
  *  Swap reorganised 29.12.95, Stephen Tweedie
  *
  *  Rewritten to use page cache, (C) 1998 Stephen Tweedie
+ *  Rewritten to use private lookup table, DaveM
  */
 
 #include <linux/mm.h>
@@ -17,19 +18,6 @@
 
 #include <asm/pgtable.h>
 
-static struct address_space_operations swap_aops = {
-	sync_page: block_sync_page
-};
-
-struct address_space swapper_space = {
-	{				/* pages	*/
-		&swapper_space.pages,	/*        .next */
-		&swapper_space.pages	/*	  .prev */
-	},
-	0,				/* nrpages	*/
-	&swap_aops,
-};
-
 #ifdef SWAP_CACHE_INFO
 unsigned long swap_cache_add_total = 0;
 unsigned long swap_cache_del_total = 0;
@@ -45,29 +33,94 @@
 }
 #endif
 
+static spinlock_t swaphash_lock = SPIN_LOCK_UNLOCKED;
+#define SWAPHASH_SIZE	512
+static struct page *swaphash[SWAPHASH_SIZE];
+
+#define SWAPHASHFN(ENTRY) \
+	((((ENTRY).val) >> PAGE_SHIFT) & (SWAPHASH_SIZE - 1))
+
+static void swapcache_hash(struct page *page, swp_entry_t entry)
+{
+	struct page **head = &swaphash[SWAPHASHFN(entry)];
+
+	get_page(page);
+
+	spin_lock(&swaphash_lock);
+	page->swapid = entry;
+	if ((page->next_hash = *head) != NULL)
+		(*head)->pprev_hash = &page->next_hash;
+	*head = page;
+	page->pprev_hash = head;
+	spin_unlock(&swaphash_lock);
+}
+
+static void swapcache_unhash(struct page *page)
+{
+	spin_lock(&swaphash_lock);
+	if (page->next_hash)
+		page->next_hash->pprev_hash = page->pprev_hash;
+	*(page->pprev_hash) = page->next_hash;
+	spin_unlock(&swaphash_lock);
+
+	put_page(page);
+}
+
+/* Find the page corresponding to a swapcache entry.
+ * If the page is successfully found, we return with
+ * it locked and a reference to it.
+ */
+static struct page *swaphash_find_lock(swp_entry_t entry)
+{
+	struct page *page, **head;
+
+repeat:
+	head = &swaphash[SWAPHASHFN(entry)];
+	spin_lock(&swaphash_lock);
+	for (page = *head; page; page = page->next_hash) {
+		if (page->swapid.val == entry.val)
+			break;
+	}
+	if (page)
+		get_page(page);
+	spin_unlock(&swaphash_lock);
+
+	if (page && TryLockPage(page)) {
+		DECLARE_WAITQUEUE(wait, current);
+
+		__set_task_state(current, TASK_UNINTERRUPTIBLE);
+		add_wait_queue(&page->wait, &wait);
+
+		if (PageLocked(page))
+			schedule();
+
+		__set_task_state(current, TASK_RUNNING);
+		remove_wait_queue(&page->wait, &wait);
+
+		put_page(page);
+		goto repeat;
+	}
+
+	return page;
+}
+
 void add_to_swap_cache(struct page *page, swp_entry_t entry)
 {
 #ifdef SWAP_CACHE_INFO
 	swap_cache_add_total++;
 #endif
 	if (PageTestandSetSwapCache(page))
-		BUG();
-	if (page->mapping)
 		BUG();
-	add_to_page_cache(page, &swapper_space, entry.val);
+	swapcache_hash(page, entry);
 }
 
 static inline void remove_from_swap_cache(struct page *page)
 {
-	struct address_space *mapping = page->mapping;
-
-	if (mapping != &swapper_space)
-		BUG();
 	if (!PageSwapCache(page) || !PageLocked(page))
 		PAGE_BUG(page);
 
 	PageClearSwapCache(page);
-	remove_inode_page(page);
+	swapcache_unhash(page);
 }
 
 /*
@@ -76,10 +129,8 @@
  */
 void __delete_from_swap_cache(struct page *page)
 {
-	swp_entry_t entry;
+	swp_entry_t entry = page->swapid;
 
-	entry.val = page->index;
-
 #ifdef SWAP_CACHE_INFO
 	swap_cache_del_total++;
 #endif
@@ -96,11 +147,9 @@
 	if (!PageLocked(page))
 		BUG();
 
-	if (block_flushpage(page, 0))
-		lru_cache_del(page);
+	block_flushpage(page, 0);
 
 	__delete_from_swap_cache(page);
-	page_cache_release(page);
 }
 
 /*
@@ -125,9 +174,12 @@
 	 * If we are the only user, then try to free up the swap cache. 
 	 */
 	if (PageSwapCache(page) && !TryLockPage(page)) {
-		if (!is_page_shared(page)) {
+		if (!PageAnon(page))
+			BUG();
+
+		if (!is_swappage_shared(page, page_count(page)))
 			delete_from_swap_cache_nolock(page);
-		}
+
 		UnlockPage(page);
 	}
 
@@ -156,13 +208,13 @@
 		 * Right now the pagecache is 32-bit only.  But it's a 32 bit index. =)
 		 */
 repeat:
-		found = find_lock_page(&swapper_space, entry.val);
+		found = swaphash_find_lock(entry);
 		if (!found)
 			return 0;
 		/*
 		 * Though the "found" page was in the swap cache an instant
 		 * earlier, it might have been removed by shrink_mmap etc.
-		 * Re search ... Since find_lock_page grabs a reference on
+		 * Re search ... Since swaphash_find_lock grabs a reference on
 		 * the page, it can not be reused for anything else, namely
 		 * it can not be associated with another swaphandle, so it
 		 * is enough to check whether the page is still in the scache.
@@ -172,20 +224,12 @@
 			__free_page(found);
 			goto repeat;
 		}
-		if (found->mapping != &swapper_space)
-			goto out_bad;
 #ifdef SWAP_CACHE_INFO
 		swap_cache_find_success++;
 #endif
 		UnlockPage(found);
 		return found;
 	}
-
-out_bad:
-	printk (KERN_ERR "VM: Found a non-swapper swap page!\n");
-	UnlockPage(found);
-	__free_page(found);
-	return 0;
 }
 
 /* 
@@ -200,12 +244,19 @@
 struct page * read_swap_cache_async(swp_entry_t entry, int wait)
 {
 	struct page *found_page = 0, *new_page;
-	unsigned long new_page_addr;
 	
 	/*
 	 * Make sure the swap entry is still in use.
+	 *
+	 * This swapcache reference is for two purposes:
+	 * 1) To make sure existing swapcache entries do not
+	 *    disappear on us.  This reference only needs to
+	 *    exist while this function runs.
+	 * 2) As the initial hold on the entry if we place a
+	 *    new page into the swapcache.  In this case we
+	 *    do not drop the reference before returning.
 	 */
-	if (!swap_duplicate(entry))	/* Account for the swap cache */
+	if (!swap_duplicate(entry))
 		goto out;
 	/*
 	 * Look for the page in the swap cache.
@@ -214,10 +265,9 @@
 	if (found_page)
 		goto out_free_swap;
 
-	new_page_addr = __get_free_page(GFP_USER);
-	if (!new_page_addr)
+	new_page = alloc_page(GFP_USER);
+	if (!new_page)
 		goto out_free_swap;	/* Out of memory */
-	new_page = mem_map + MAP_NR(new_page_addr);
 
 	/*
 	 * Check the swap cache again, in case we stalled above.
@@ -226,8 +276,10 @@
 	if (found_page)
 		goto out_free_page;
 	/* 
-	 * Add it to the swap cache and read its contents.
+	 * Lock the page, add it to the swap cache, and read its contents.
 	 */
+	if (TryLockPage(new_page))
+		BUG();
 	add_to_swap_cache(new_page, entry);
 	rw_swap_page(READ, new_page, wait);
 	return new_page;
Index: mm/swapfile.c
===================================================================
RCS file: /cvs/linux/mm/swapfile.c,v
retrieving revision 1.72
diff -u -r1.72 swapfile.c
--- mm/swapfile.c	2000/04/22 00:45:18	1.72
+++ mm/swapfile.c	2000/05/01 05:33:26
@@ -211,9 +211,9 @@
 		goto new_swap_entry;
 
 	/* We have the old entry in the page offset still */
-	if (!page->index)
+	if (!page->swapid.val)
 		goto new_swap_entry;
-	entry.val = page->index;
+	entry = page->swapid;
 	type = SWP_TYPE(entry);
 	if (type >= nr_swapfiles)
 		goto new_swap_entry;
@@ -271,6 +271,8 @@
 	}
 	if (pte_val(pte) != entry.val)
 		return;
+	if (anon_page_add(vma, address, page))
+		return;
 	set_pte(dir, pte_mkdirty(mk_pte(page, vma->vm_page_prot)));
 	swap_free(entry);
 	get_page(page);
@@ -934,7 +936,7 @@
 	swp_entry_t entry;
 	int retval = 0;
 
-	entry.val = page->index;
+	entry = page->swapid;
 	if (!entry.val)
 		goto bad_entry;
 	type = SWP_TYPE(entry);
Index: mm/vmscan.c
===================================================================
RCS file: /cvs/linux/mm/vmscan.c,v
retrieving revision 1.97
diff -u -r1.97 vmscan.c
--- mm/vmscan.c	2000/04/27 02:49:03	1.97
+++ mm/vmscan.c	2000/05/01 05:33:27
@@ -9,6 +9,7 @@
  *  to bring the system back to freepages.high: 2.4.97, Rik van Riel.
  *  Version: $Id: vmscan.c,v 1.5 1998/02/23 22:14:28 sct Exp $
  *  Zone aware kswapd started 02/00, Kanoj Sarcar (kanoj@sgi.com).
+ *  Rewritten from scratch 04/00, DaveM
  */
 
 #include <linux/slab.h>
@@ -23,525 +24,674 @@
 
 #include <asm/pgalloc.h>
 
-/*
- * The swap-out functions return 1 if they successfully
- * threw something out, and we got a free page. It returns
- * zero if it couldn't do anything, and any other value
- * indicates it decreased rss, but the page was shared.
- *
- * NOTE! If it sleeps, it *must* return 1 to make sure we
- * don't continue with the swap-out. Otherwise we may be
- * using a process that no longer actually exists (it might
- * have died while we slept).
- */
-static int try_to_swap_out(struct mm_struct * mm, struct vm_area_struct* vma, unsigned long address, pte_t * page_table, int gfp_mask)
+static __inline__ struct vm_area_struct *next_vma(struct vm_area_struct *vma, int anon)
 {
-	pte_t pte;
-	swp_entry_t entry;
-	struct page * page;
-	int (*swapout)(struct page *, struct file *);
-
-	pte = *page_table;
-	if (!pte_present(pte))
-		goto out_failed;
-	page = pte_page(pte);
-	if ((page-mem_map >= max_mapnr) || PageReserved(page))
-		goto out_failed;
-
-	mm->swap_cnt--;
-	/* Don't look at this pte if it's been accessed recently. */
-	if (pte_young(pte)) {
-		/*
-		 * Transfer the "accessed" bit from the page
-		 * tables to the global page map.
-		 */
-		set_pte(page_table, pte_mkold(pte));
-		set_bit(PG_referenced, &page->flags);
-		goto out_failed;
-	}
-
-	if (PageLocked(page))
-		goto out_failed;
-
-	/*
-	 * Is the page already in the swap cache? If so, then
-	 * we can just drop our reference to it without doing
-	 * any IO - it's already up-to-date on disk.
-	 *
-	 * Return 0, as we didn't actually free any real
-	 * memory, and we should just continue our scan.
-	 */
-	if (PageSwapCache(page)) {
-		entry.val = page->index;
-		swap_duplicate(entry);
-		set_pte(page_table, swp_entry_to_pte(entry));
-drop_pte:
-		vma->vm_mm->rss--;
-		flush_tlb_page(vma, address);
-		__free_page(page);
-		goto out_failed;
-	}
+	if (anon)
+		return vma->vm_anon_next_share;
+	return vma->vm_next_share;
+}
 
-	/*
-	 * Is it a clean page? Then it must be recoverable
-	 * by just paging it in again, and we can just drop
-	 * it..
-	 *
-	 * However, this won't actually free any real
-	 * memory, as the page will just be in the page cache
-	 * somewhere, and as such we should just continue
-	 * our scan.
-	 *
-	 * Basically, this just makes it possible for us to do
-	 * some real work in the future in "shrink_mmap()".
-	 */
-	if (!pte_dirty(pte)) {
-		flush_cache_page(vma, address);
-		pte_clear(page_table);
-		goto drop_pte;
+static pte_t *get_pte(struct mm_struct *mm, unsigned long address)
+{
+	pgd_t *pgdp;
+	pmd_t *pmdp;
+
+	pgdp = pgd_offset(mm, address);
+	pmdp = pmd_offset(pgdp, address);
+	if (pmdp)
+		return pte_offset(pmdp, address);
+
+	return NULL;
+}
+
+static void zap_clean_mappings(struct page *page)
+{
+	struct vm_area_struct *vma;
+	int anon = PageAnon(page);
+
+	spin_lock(&page->mapping->i_shared_lock);
+	vma = page->mapping->i_mmap;
+	while (vma) {
+		pte_t *ptep, entry;
+		unsigned long address;
+
+		if (vma->vm_flags & VM_LOCKED)
+			goto next;
+		if ((long)vma->vm_pgoff > (long)page->index)
+			goto next;
+
+		address = (vma->vm_start +
+			   ((page->index - vma->vm_pgoff) << PAGE_SHIFT));
+
+		if (address >= vma->vm_end)
+			goto next;
+
+		vmlist_access_lock(vma->vm_mm);
+		ptep = get_pte(vma->vm_mm, address);
+		if (!ptep)
+			goto next_unlock;
+
+		entry = *ptep;
+		if (pte_present(entry) && pte_page(entry) == page) {
+			if (PageSwapCache(page)) {
+				swp_entry_t swap_entry;
+
+				swap_entry = page->swapid;
+
+				/* Transition of pte from present to not
+				 * present grabs a swapcache reference.
+				 */
+				swap_duplicate(swap_entry);
+				flush_cache_page(vma, address);
+				set_pte(ptep, swp_entry_to_pte(swap_entry));
+				flush_tlb_page(vma, address);
+				vma->vm_mm->rss--;
+				__free_page(page);
+			} else if (!pte_dirty(entry)) {
+				flush_cache_page(vma, address);
+				pte_clear(ptep);
+				flush_tlb_page(vma, address);
+				vma->vm_mm->rss--;
+				__free_page(page);
+			}
+		}
+	next_unlock:
+		vmlist_access_unlock(vma->vm_mm);
+
+	next:
+		vma = next_vma(vma, anon);
 	}
+	spin_unlock(&page->mapping->i_shared_lock);
+}
 
-	/*
-	 * Don't go down into the swap-out stuff if
-	 * we cannot do I/O! Avoid recursing on FS
-	 * locks etc.
-	 */
-	if (!(gfp_mask & __GFP_IO))
-		goto out_failed;
+#define PAGE_REFERENCED		0x1
+#define PAGE_DIRTY		0x2
+#define PAGE_USER_MAPPED	0x4
 
-	/*
-	 * Ok, it's really dirty. That means that
-	 * we should either create a new swap cache
-	 * entry for it, or we should write it back
-	 * to its own backing store.
-	 *
-	 * Note that in neither case do we actually
-	 * know that we make a page available, but
-	 * as we potentially sleep we can no longer
-	 * continue scanning, so we migth as well
-	 * assume we free'd something.
-	 *
-	 * NOTE NOTE NOTE! This should just set a
-	 * dirty bit in 'page', and just drop the
-	 * pte. All the hard work would be done by
-	 * shrink_mmap().
-	 *
-	 * That would get rid of a lot of problems.
-	 */
-	flush_cache_page(vma, address);
-	if (vma->vm_ops && (swapout = vma->vm_ops->swapout)) {
-		int error;
-		struct file *file = vma->vm_file;
-		if (file) get_file(file);
-		pte_clear(page_table);
-		vma->vm_mm->rss--;
-		flush_tlb_page(vma, address);
+static int check_pgtable_references(struct page *page)
+{
+	struct vm_area_struct *vma;
+	int ret = 0, anon = PageAnon(page);
+
+	spin_lock(&page->mapping->i_shared_lock);
+	vma = page->mapping->i_mmap;
+	while (vma) {
+		pte_t *ptep, entry;
+		unsigned long address;
+
+		if (vma->vm_flags & VM_LOCKED)
+			goto next;
+		if ((long)vma->vm_pgoff > (long)page->index)
+			goto next;
+
+		address = (vma->vm_start +
+			   ((page->index - vma->vm_pgoff) << PAGE_SHIFT));
+
+		if (address >= vma->vm_end)
+			goto next;
+
+		vmlist_access_lock(vma->vm_mm);
+		ptep = get_pte(vma->vm_mm, address);
+		if (!ptep)
+			goto next_unlock;
+
+		entry = *ptep;
+		if (pte_present(entry) && pte_page(entry) == page) {
+			ret |= PAGE_USER_MAPPED;
+			if (pte_dirty(entry))
+				ret |= PAGE_DIRTY;
+			if (pte_young(entry)) {
+				set_pte(ptep, pte_mkold(entry));
+				ret |= PAGE_REFERENCED;
+			}
+		}
+	next_unlock:
 		vmlist_access_unlock(vma->vm_mm);
-		error = swapout(page, file);
-		if (file) fput(file);
-		if (!error)
-			goto out_free_success;
-		__free_page(page);
-		return error;
+
+	next:
+		vma = next_vma(vma, anon);
 	}
+	spin_unlock(&page->mapping->i_shared_lock);
 
-	/*
-	 * This is a dirty, swappable page.  First of all,
-	 * get a suitable swap entry for it, and make sure
-	 * we have the swap cache set up to associate the
-	 * page with that swap entry.
-	 */
-	entry = acquire_swap_entry(page);
-	if (!entry.val)
-		goto out_failed; /* No swap space left */
-		
-	if (!(page = prepare_highmem_swapout(page)))
-		goto out_swap_free;
-
-	swap_duplicate(entry);	/* One for the process, one for the swap cache */
-
-	/* This will also lock the page */
-	add_to_swap_cache(page, entry);
-	/* Put the swap entry into the pte after the page is in swapcache */
-	vma->vm_mm->rss--;
-	set_pte(page_table, swp_entry_to_pte(entry));
-	flush_tlb_page(vma, address);
-	vmlist_access_unlock(vma->vm_mm);
+	return ret;
+}
 
-	/* OK, do a physical asynchronous write to swap.  */
-	rw_swap_page(WRITE, page, 0);
+static __inline__ int check_page_references(struct page *page)
+{
+	if (test_and_clear_bit(PG_referenced, &page->flags))
+		return PAGE_REFERENCED;
 
-out_free_success:
-	__free_page(page);
-	return 1;
-out_swap_free:
-	swap_free(entry);
-out_failed:
-	return 0;
+	if (!page->mapping || !page->mapping->i_mmap)
+		return 0;
 
+	return check_pgtable_references(page);
 }
 
-/*
- * A new implementation of swap_out().  We do not swap complete processes,
- * but only a small number of blocks, before we continue with the next
- * process.  The number of blocks actually swapped is determined on the
- * number of page faults, that this process actually had in the last time,
- * so we won't swap heavily used processes all the time ...
- *
- * Note: the priority argument is a hint on much CPU to waste with the
- *       swap block search, not a hint, of how much blocks to swap with
- *       each process.
+/* Attempt to populate the inactive LRU queue for a zone.
  *
- * (C) 1993 Kai Petzke, wpp@marie.physik.tu-berlin.de
+ * The work_budget says how many pages we should try to
+ * move to the inactive list this run.
  */
-
-static inline int swap_out_pmd(struct mm_struct * mm, struct vm_area_struct * vma, pmd_t *dir, unsigned long address, unsigned long end, int gfp_mask)
+static void populate_inactive_list(long work_budget)
 {
-	pte_t * pte;
-	unsigned long pmd_end;
-
-	if (pmd_none(*dir))
-		return 0;
-	if (pmd_bad(*dir)) {
-		pmd_ERROR(*dir);
-		pmd_clear(dir);
-		return 0;
+	struct list_head *entry;
+	LIST_HEAD(still_active_head);
+	LIST_HEAD(inactive);
+
+	spin_lock(&pagemap_lru_lock);
+
+	entry = lru_active.prev;
+	while ((entry != &lru_active) && (work_budget > 0)) {
+		struct list_head *next = entry->prev;
+		struct list_head *dest;
+		struct page *page;
+		int state;
+
+		page = list_entry(entry, struct page, lru);
+		list_del(entry);
+
+		/* If the page has been referenced since we last
+		 * tested, put it back at the end of the active LRU
+		 * to age it again.
+		 */
+		dest = &still_active_head;
+		state = check_page_references(page);
+		if (state & PAGE_REFERENCED)
+			goto queue_page;
+
+		/* OK, we choose to deactivate this guy. */
+		inactive_pages++;
+		dest = &inactive;
+		work_budget--;
+
+	queue_page:
+		list_add(entry, dest);
+		entry = next;
 	}
-	
-	pte = pte_offset(dir, address);
-	
-	pmd_end = (address + PMD_SIZE) & PMD_MASK;
-	if (end > pmd_end)
-		end = pmd_end;
-
-	do {
-		int result;
-		vma->vm_mm->swap_address = address + PAGE_SIZE;
-		result = try_to_swap_out(mm, vma, address, pte, gfp_mask);
-		if (result)
-			return result;
-		if (!mm->swap_cnt)
-			return 0;
-		address += PAGE_SIZE;
-		pte++;
-	} while (address && (address < end));
-	return 0;
+
+	/* Now splice everything back into the appropriate LRU
+	 * lists.
+	 */
+	list_splice(&still_active_head, &lru_active);
+	list_splice(&inactive, &lru_inactive);
+
+	spin_unlock(&pagemap_lru_lock);
 }
 
-static inline int swap_out_pgd(struct mm_struct * mm, struct vm_area_struct * vma, pgd_t *dir, unsigned long address, unsigned long end, int gfp_mask)
+/* Try to completely free up old pages in the inactive LRU
+ * queue.
+ *
+ * The work_budget says how many pages we should try to
+ * free up.
+ */
+static int free_inactive_pages(long work_budget)
 {
-	pmd_t * pmd;
-	unsigned long pgd_end;
+	struct list_head *entry;
+	LIST_HEAD(back_to_active);
+	LIST_HEAD(inactive_tail);
+	LIST_HEAD(dirty);
+
+	spin_lock(&pagemap_lru_lock);
+
+	while (((entry = lru_inactive.prev) != &lru_inactive) &&
+	       (work_budget > 0)) {
+		struct list_head *dest;
+		struct page *page;
+		int state;
 
-	if (pgd_none(*dir))
-		return 0;
-	if (pgd_bad(*dir)) {
-		pgd_ERROR(*dir);
-		pgd_clear(dir);
-		return 0;
+		page = list_entry(entry, struct page, lru);
+		list_del(entry);
+
+		/* Reactivate this sucker if it has been referenced
+		 * since we placed it onto the inactive list.
+		 */
+		dest = &back_to_active;
+		state = check_page_references(page);
+		if (state & PAGE_REFERENCED) {
+			inactive_pages--;
+			goto queue_page;
+		}
+
+		/* Only the washing machine knows how to deal with
+		 * dirty pages.
+		 */
+		dest = &dirty;
+		if (state & PAGE_DIRTY) {
+			inactive_pages--;
+			goto queue_page;
+		}
+
+		dest = &inactive_tail;
+		if (TryLockPage(page))
+			goto queue_page;
+
+		get_page(page);
+
+		/* NOTE: All code paths past this point must unlock and
+		 *       release the page before moving on to the next
+		 *       inactive page.
+		 */
+
+		if (state & PAGE_USER_MAPPED)
+			zap_clean_mappings(page);
+
+		if (!page->buffers) {
+			int cache_owners = 1;
+
+			if (PageSwapCache(page))
+				cache_owners = 2;
+			if (page_count(page) > cache_owners)
+				goto could_not_free;
+		}
+
+		/* We might actually be able to free this thing. */
+		spin_unlock(&pagemap_lru_lock);
+		if (page->buffers) {
+			if (!try_to_free_buffers(page))
+				goto could_not_free_unlock;
+			if (!page->mapping) {
+				atomic_dec(&buffermem_pages);
+				goto made_progress;
+			}
+		}
+
+		/* All pages in the LRU lists must have a
+		 * mapping of some kind.  One implication of
+		 * this is that it is illegal to nullify the
+		 * mapping of a page without having the page
+		 * locked.
+		 */
+		if (!page->mapping)
+			BUG();
+
+		/* And if a class of non-buffer pages will appear
+		 * in the LRU lists, it _must_ have a page liberation
+		 * method.
+		 */
+		if (!page->mapping->a_ops->try_to_free_page)
+			BUG();
+
+		if (page->mapping->a_ops->try_to_free_page(page)) {
+	made_progress:
+			UnlockPage(page);
+			put_page(page);
+			work_budget--;
+			spin_lock(&pagemap_lru_lock);
+			inactive_pages--;
+			nr_lru_pages--;
+			continue;
+		}
+
+		/* We couldn't free up the page completely, move on
+		 * to inspect the next lru entry.
+		 */
+	could_not_free_unlock:
+		spin_lock(&pagemap_lru_lock);
+	could_not_free:
+		UnlockPage(page);
+		put_page(page);
+
+	queue_page:
+		list_add(entry, dest);
 	}
 
-	pmd = pmd_offset(dir, address);
+	/* Now splice the non-freed pages back into the appropriate
+	 * LRU lists.
+	 */
+	list_splice(&back_to_active, &lru_active);
+	list_splice(&inactive_tail, lru_inactive.prev);
+	list_splice(&dirty, &lru_dirty);
 
-	pgd_end = (address + PGDIR_SIZE) & PGDIR_MASK;	
-	if (pgd_end && (end > pgd_end))
-		end = pgd_end;
-	
-	do {
-		int result = swap_out_pmd(mm, vma, pmd, address, end, gfp_mask);
-		if (result)
-			return result;
-		if (!mm->swap_cnt)
-			return 0;
-		address = (address + PMD_SIZE) & PMD_MASK;
-		pmd++;
-	} while (address && (address < end));
-	return 0;
+	spin_unlock(&pagemap_lru_lock);
+
+	return work_budget;
 }
 
-static int swap_out_vma(struct mm_struct * mm, struct vm_area_struct * vma, unsigned long address, int gfp_mask)
+static int swap_out_pte(struct page *page, struct vm_area_struct *vma,
+	unsigned long address, pte_t entry, pte_t *ptep)
 {
-	pgd_t *pgdir;
-	unsigned long end;
+	swp_entry_t swap_entry;
 
-	/* Don't swap out areas which are locked down */
-	if (vma->vm_flags & VM_LOCKED)
-		return 0;
+	flush_cache_page(vma, address);
 
-	pgdir = pgd_offset(vma->vm_mm, address);
+	if (PageSwapCache(page)) {
+		swap_entry = page->swapid;
 
-	end = vma->vm_end;
-	if (address >= end)
-		BUG();
-	do {
-		int result = swap_out_pgd(mm, vma, pgdir, address, end, gfp_mask);
-		if (result)
-			return result;
-		if (!mm->swap_cnt)
+		/* Transition of pte from present to not
+		 * present grabs a swapcache reference.
+		 */
+		swap_duplicate(swap_entry);
+		set_pte(ptep, swp_entry_to_pte(swap_entry));
+		goto put_pte;
+	}
+
+	if (!pte_dirty(entry)) {
+		pte_clear(ptep);
+		flush_tlb_page(vma, address);
+		goto put_pte;
+	}
+
+	if (vma->vm_ops &&
+	    vma->vm_ops->swapout != NULL) {
+		int (*swapout)(struct page *, struct file *);
+		struct file *file;
+
+		swapout = vma->vm_ops->swapout;
+		if ((file = vma->vm_file) != NULL)
+			get_file(file);
+		pte_clear(ptep);
+		flush_tlb_page(vma, address);
+		vma->vm_mm->rss--;
+
+		vmlist_access_unlock(vma->vm_mm);
+		spin_unlock(&page->mapping->i_shared_lock);
+
+		swapout(page, file);
+		if (file)
+			fput(file);
+	} else {
+		struct page *new_page;
+
+		/* Get a fresh swapcache entry, it will have a
+		 * reference count of one (for this pte entry).
+		 */
+		swap_entry = acquire_swap_entry(page);
+		if (!swap_entry.val)
+			return 0;
+
+		if (!(new_page = prepare_highmem_swapout(page))) {
+			swap_free(swap_entry);
 			return 0;
-		address = (address + PGDIR_SIZE) & PGDIR_MASK;
-		pgdir++;
-	} while (address && (address < end));
+		}
+
+		if (new_page != page) {
+			if (TryLockPage(new_page))
+				BUG();
+		}
+
+		/* Give the swapcache entry another reference, for the
+		 * swapcache itself.  This is actually a bit sloppy, the
+		 * cache management in swap_state.c should be taking care
+		 * of these references for us.
+		 *
+		 * Next, we actually add the entry into the swapcache.
+		 * This will acquire a new reference to the page.
+		 */
+		swap_duplicate(swap_entry);
+		add_to_swap_cache(new_page, swap_entry);
+		vma->vm_mm->rss--;
+
+		/* Now, stick the swap entry into the page tables, and
+		 * flush the TLB.  The cache flush was done above already.
+		 */
+		set_pte(ptep, swp_entry_to_pte(swap_entry));
+		flush_tlb_page(vma, address);
+
+		/* Drop the locks so we can submit the I/O, which can
+		 * sleep.
+		 */
+		vmlist_access_unlock(vma->vm_mm);
+		spin_unlock(&page->mapping->i_shared_lock);
+
+		/* Duplicate some consistency checking here so if it
+		 * triggers we know who is to blame.
+		 */
+		if (!page->mapping ||
+		    !PageLocked(page) ||
+		    !PageAnon(page) ||
+		    !PageSwapCache(page))
+			BUG();
+
+		/* Perform the actual I/O.  We keep the page locked, and
+		 * anyone who tries to get at this page sleeps when they
+		 * try to lock it.  Later they will be awoken when the
+		 * page I/O completes.
+		 *
+		 * We perform asynchronous I/O, so that in this dirty LRU
+		 * run we can queue multiple swapouts, and then the caller
+		 * makes sure to run tq_disk which pushes the requests off
+		 * to the disk if necessary.
+		 */
+		rw_swap_page(WRITE, new_page, 0);
+	}
+
+	__free_page(page);
+	return 1;
+
+put_pte:
+	flush_tlb_page(vma, address);
+	vma->vm_mm->rss--;
+	__free_page(page);
 	return 0;
 }
 
-static int swap_out_mm(struct mm_struct * mm, int gfp_mask)
+static int swap_it_out(struct page *page)
 {
-	unsigned long address;
-	struct vm_area_struct* vma;
+	struct vm_area_struct *vma;
+	int anon = PageAnon(page);
 
-	/*
-	 * Go through process' page directory.
-	 */
-	address = mm->swap_address;
+	if (!page->mapping)
+		BUG();
 
-	/*
-	 * Find the proper vm-area after freezing the vma chain 
-	 * and ptes.
-	 */
-	vmlist_access_lock(mm);
-	vma = find_vma(mm, address);
-	if (vma) {
-		if (address < vma->vm_start)
-			address = vma->vm_start;
-
-		for (;;) {
-			int result = swap_out_vma(mm, vma, address, gfp_mask);
-			if (result)
-				return result;
-			vma = vma->vm_next;
-			if (!vma)
-				break;
-			address = vma->vm_start;
-		}
-	}
-	vmlist_access_unlock(mm);
-
-	/* We didn't find anything for the process */
-	mm->swap_cnt = 0;
-	mm->swap_address = 0;
+	spin_lock(&page->mapping->i_shared_lock);
+
+	vma = page->mapping->i_mmap;
+	while (vma) {
+		pte_t *ptep, entry;
+		unsigned long address;
+
+		if (vma->vm_flags & VM_LOCKED)
+			goto next;
+		if ((long)vma->vm_pgoff > (long)page->index)
+			goto next;
+
+		address = (vma->vm_start +
+			   ((page->index - vma->vm_pgoff) << PAGE_SHIFT));
+
+		if (address >= vma->vm_end)
+			goto next;
+
+		vmlist_access_lock(vma->vm_mm);
+		ptep = get_pte(vma->vm_mm, address);
+		if (ptep &&
+		    pte_present(entry = *ptep) &&
+		    pte_page(entry) == page) {
+			/* If this actually swaps out the page, it will
+			 * drop the vmlist_access_lock and the i_shared_lock.
+			 */
+			if (swap_out_pte(page, vma, address, entry, ptep))
+				return 1;
+		}
+		vmlist_access_unlock(vma->vm_mm);
+
+	next:
+		vma = next_vma(vma, anon);
+	}
+
+	spin_unlock(&page->mapping->i_shared_lock);
+
 	return 0;
 }
 
-/*
- * Select the task with maximal swap_cnt and try to swap out a page.
- * N.B. This function returns only 0 or 1.  Return values != 1 from
- * the lower level routines result in continued processing.
+/* We toss dirty inactive pages onto a special
+ * dirty lru list.  This allows us to
+ * only look at pages which are interesting.
+ *
+ * So we just take such pages and try to put
+ * them into the washing machine, and stop this
+ * process when we've created a full load.
+ *
+ * Rinse, dry, repeat...
  */
-int swap_out(unsigned int priority, int gfp_mask)
+static int rinse_cycle(long work_budget)
 {
-	struct task_struct * p;
-	int counter;
-	int __ret = 0;
-	int assign = 0;
-
-	lock_kernel();
-	/* 
-	 * We make one or two passes through the task list, indexed by 
-	 * assign = {0, 1}:
-	 *   Pass 1: select the swappable task with maximal RSS that has
-	 *         not yet been swapped out. 
-	 *   Pass 2: re-assign rss swap_cnt values, then select as above.
-	 *
-	 * With this approach, there's no need to remember the last task
-	 * swapped out.  If the swap-out fails, we clear swap_cnt so the 
-	 * task won't be selected again until all others have been tried.
-	 *
-	 * Think of swap_cnt as a "shadow rss" - it tells us which process
-	 * we want to page out (always try largest first).
-	 */
-	counter = nr_threads / (priority+1);
-	if (counter < 1)
-		counter = 1;
-
-	for (; counter >= 0; counter--) {
-		unsigned long max_cnt = 0;
-		struct mm_struct *best = NULL;
-		int pid = 0;
-	select:
-		read_lock(&tasklist_lock);
-		p = init_task.next_task;
-		for (; p != &init_task; p = p->next_task) {
-			struct mm_struct *mm = p->mm;
-			p->hog = 0;
-			if (!p->swappable || !mm)
-				continue;
-	 		if (mm->rss <= 0)
-				continue;
-			/* Refresh swap_cnt? */
-			if (assign == 1)
-				mm->swap_cnt = mm->rss;
-			if (mm->swap_cnt > max_cnt) {
-				max_cnt = mm->swap_cnt;
-				best = mm;
-				pid = p->pid;
-			}
-		}
-		if (assign == 1) {
-			/* we just assigned swap_cnt, normalise values */
-			assign = 2;
-			p = init_task.next_task;
-			for (; p != &init_task; p = p->next_task) {
-				int i = 0;
-				struct mm_struct *mm = p->mm;
-				if (!p->swappable || !mm || mm->rss <= 0)
-					continue;
-				/* small processes are swapped out less */
-				while ((mm->swap_cnt << 2 * (i + 1) < max_cnt))
-					i++;
-				mm->swap_cnt >>= i;
-				mm->swap_cnt += i; /* if swap_cnt reaches 0 */
-				/* we're big -> hog treatment */
-				if (!i)
-					p->hog = 1;
-			}
-		}
-		read_unlock(&tasklist_lock);
-		if (!best) {
-			if (!assign) {
-				assign = 1;
-				goto select;
-			}
-			goto out;
-		} else {
-			int ret;
+	struct list_head *entry;
 
-			atomic_inc(&best->mm_count);
-			ret = swap_out_mm(best, gfp_mask);
-			mmdrop(best);
+	spin_lock(&pagemap_lru_lock);
+	while (((entry = lru_dirty.next) != &lru_dirty) &&
+	       (work_budget > 0)) {
+		struct page *page = list_entry(entry, struct page, lru);
+		int state;
+
+		list_del(entry);
+		list_add_tail(entry, &lru_inactive);
+		inactive_pages++;
+
+		state = check_page_references(page);
+		if ((state & PAGE_DIRTY) == 0 || TryLockPage(page))
+			continue;
+
+		spin_unlock(&pagemap_lru_lock);
+		get_page(page);
+
+		/* Swap it out.  If we transferred ownership of the
+		 * page to swapout handling, we should not unlock the
+		 * page.
+		 */
+		if (!swap_it_out(page))
+			UnlockPage(page);
 
-			if (!ret)
-				continue;
+		put_page(page);
+		work_budget--;
 
-			if (ret < 0)
-				kill_proc(pid, SIGBUS, 1);
-			__ret = 1;
-			goto out;
-		}
+		spin_lock(&pagemap_lru_lock);
 	}
-out:
-	unlock_kernel();
-	return __ret;
+	spin_unlock(&pagemap_lru_lock);
+
+	return work_budget;
 }
 
-/*
- * We need to make the locks finer granularity, but right
- * now we need this so that we can do page allocations
- * without holding the kernel lock etc.
- *
- * We want to try to free "count" pages, and we need to 
- * cluster them so that we get good swap-out behaviour. See
- * the "free_memory()" macro for details.
- */
 static int do_try_to_free_pages(unsigned int gfp_mask, zone_t *zone)
 {
-	int priority;
-	int count = SWAP_CLUSTER_MAX;
-	int ret;
+	long free_goal, i_goal, priority;
+	long swap_limit = SWAP_CLUSTER_MAX;
+	long orig_free_goal;
+
+	free_goal = (zone->pages_high - zone->free_pages);
+	if (free_goal < SWAP_CLUSTER_MAX)
+		free_goal = SWAP_CLUSTER_MAX;
+	orig_free_goal = free_goal;
 
-	/* Always trim SLAB caches when memory gets low. */
-	kmem_cache_reap(gfp_mask);
-
 	priority = 6;
-	do {
-		while ((ret = shrink_mmap(priority, gfp_mask, zone))) {
-			if (!--count)
-				goto done;
+repeat:
+	if (!list_empty(&lru_inactive))
+		free_goal = free_inactive_pages(free_goal);
+	if (gfp_mask & __GFP_IO) {
+		if (!list_empty(&lru_dirty)) {
+			long this_swap_max = swap_limit;
+			long orig_swap_max = this_swap_max;
+
+			this_swap_max = rinse_cycle(this_swap_max);
+
+			if (this_swap_max != orig_swap_max) {
+				swap_limit -= (orig_swap_max - this_swap_max);
+				free_goal -= (orig_swap_max - this_swap_max);
+			}
 		}
 
+		free_goal -= shrink_dcache_memory(priority, gfp_mask, zone);
+		free_goal -= shrink_icache_memory(priority, gfp_mask, zone);
+		if (free_goal < 0)
+			free_goal = 0;
+	}
 
-		/* Try to get rid of some shared memory pages.. */
+	/* Always rescan for inactive pages. */
+	i_goal = (inactive_goal - inactive_pages) + free_goal;
+	if (inactive_goal > 0)
+		populate_inactive_list(i_goal);
+
+	/* No matter what happens, attempt some SLAB cache trimming.
+	 * We do it last, because several of the actions above potentially
+	 * trim SLABs.
+	 */
+	kmem_cache_reap(gfp_mask);
+
+	/* If have still not reached a suitable free page state for
+	 * this zone, we should try to write stuff out if we can.
+	 */
+	if (free_goal > 0) {
 		if (gfp_mask & __GFP_IO) {
-			/*
-			 * don't be too light against the d/i cache since
-		   	 * shrink_mmap() almost never fail when there's
-		   	 * really plenty of memory free. 
-			 */
-			count -= shrink_dcache_memory(priority, gfp_mask, zone);
-			count -= shrink_icache_memory(priority, gfp_mask, zone);
-			if (count <= 0)
-				goto done;
 			while (shm_swap(priority, gfp_mask, zone)) {
-				if (!--count)
+				if (!--free_goal)
 					goto done;
 			}
 		}
+		if (--priority >= 0)
+			goto repeat;
 
-		/* Then, try to page stuff out..
-		 * We use swapcount here because this doesn't actually
-		 * free pages */
-		while (swap_out(priority, gfp_mask)) {
-			if (!--count)
-				goto done;
-		}
-	} while (--priority >= 0);
+		if (swap_limit != SWAP_CLUSTER_MAX)
+			run_task_queue(&tq_disk);
+
+		return 0;
+	}
+
 done:
+	if (swap_limit != SWAP_CLUSTER_MAX)
+		run_task_queue(&tq_disk);
 
-	return priority >= 0;
+	return 1;
 }
 
+/* When memory is not tight, the page daemon calls this periodically
+ * to seach for inactive queue candidates.  When memory pressure actually
+ * hits us, we will be ready as we will already know which pages are
+ * easy to liberate.
+ */
+static void inactive_page_scan(void)
+{
+	long goal;
+
+	goal = inactive_goal;
+	goal -= inactive_pages;
+	if (goal > 0)
+		populate_inactive_list(goal);
+}
+
 DECLARE_WAIT_QUEUE_HEAD(kswapd_wait);
 
-/*
- * The background pageout daemon, started as a kernel thread
- * from the init process. 
- *
- * This basically trickles out pages so that we have _some_
- * free memory available even if there is no other activity
- * that frees anything up. This is needed for things like routing
- * etc, where we otherwise might have all activity going on in
- * asynchronous contexts that cannot page things out.
- *
- * If there are applications that are active memory-allocators
- * (most normal use), this basically shouldn't matter.
- */
 int kswapd(void *unused)
 {
-	int i;
-	struct task_struct *tsk = current;
-	pg_data_t *pgdat;
-	zone_t *zone;
-
-	tsk->session = 1;
-	tsk->pgrp = 1;
-	strcpy(tsk->comm, "kswapd");
-	sigfillset(&tsk->blocked);
-	
-	/*
-	 * Tell the memory management that we're a "memory allocator",
-	 * and that if we need more memory we should get access to it
-	 * regardless (see "__alloc_pages()"). "kswapd" should
-	 * never get caught in the normal page freeing logic.
-	 *
-	 * (Kswapd normally doesn't need memory anyway, but sometimes
-	 * you need a small amount of memory in order to be able to
-	 * page out something else, and this flag essentially protects
-	 * us from recursively trying to free more memory as we're
-	 * trying to free the first piece of memory in the first place).
-	 */
-	tsk->flags |= PF_MEMALLOC;
+	signed long t;
 
-	while (1) {
-		/*
-		 * If we actually get into a low-memory situation,
-		 * the processes needing more memory will wake us
-		 * up on a more timely basis.
-		 */
-		pgdat = pgdat_list;
+	current->session = 1;
+	current->pgrp = 1;
+	strcpy(current->comm, "kswapd");
+	sigfillset(&current->blocked);
+	current->flags |= PF_MEMALLOC;
+
+	t = 0;
+	for (;;) {
+		pg_data_t *pgdat = pgdat_list;
+		long sleep_time = (5 * HZ);
+
+		if (t == 0) {
+			inactive_page_scan();
+			goto do_sleep;
+		}
 		while (pgdat) {
+			int i;
+
 			for (i = 0; i < MAX_NR_ZONES; i++) {
-				zone = pgdat->node_zones + i;
-				if (tsk->need_resched)
+				zone_t *zone = pgdat->node_zones + i;
+
+				if (current->need_resched)
 					schedule();
-				if ((!zone->size) || (!zone->zone_wake_kswapd))
+
+				if (!zone->size)
 					continue;
-				do_try_to_free_pages(GFP_KSWAPD, zone);
+				if (zone->zone_wake_kswapd) {
+					do_try_to_free_pages(GFP_KSWAPD, zone);
+					if (zone->zone_wake_kswapd)
+						sleep_time = (HZ / 2);
+				}
 			}
+
 			pgdat = pgdat->node_next;
 		}
-		run_task_queue(&tq_disk);
-		tsk->state = TASK_INTERRUPTIBLE;
-		interruptible_sleep_on(&kswapd_wait);
+
+	do_sleep:
+		current->state = TASK_INTERRUPTIBLE;
+		t = interruptible_sleep_on_timeout(&kswapd_wait, sleep_time);
 	}
 }
 
--- /dev/null	Tue May  5 13:32:27 1998
+++ mm/anon.c	Sat Apr 29 20:07:43 2000
@@ -0,0 +1,406 @@
+/*
+ *	linux/mm/anon.c
+ *
+ * Written by DaveM.
+ */
+
+#include <linux/kernel.h>
+#include <linux/sched.h>
+#include <linux/mm.h>
+#include <linux/slab.h>
+#include <linux/fs.h>
+#include <linux/swap.h>
+#include <linux/pagemap.h>
+#include <linux/spinlock.h>
+#include <linux/highmem.h>
+
+/* The anon layer provides a virtual backing object for anonymous
+ * private pages.  The anon objects hang off of vmas and are created
+ * at the first cow fault into a private mapping.
+ *
+ * The anon address space is just like the page cache, it holds a
+ * reference to each of the pages attached to it.
+ */
+
+static kmem_cache_t *anon_cachep;
+static spinlock_t anoncache_lock = SPIN_LOCK_UNLOCKED;
+int nr_anon_pages = 0;
+
+static __inline__ void __anon_insert_vma(struct vm_area_struct *vma,
+					 struct address_space *mapping)
+{
+	struct vm_area_struct *next;
+
+	next = mapping->i_mmap;
+	if ((vma->vm_anon_next_share = next) != NULL)
+		next->vm_anon_pprev_share = &vma->vm_anon_next_share;
+	mapping->i_mmap = vma;
+	vma->vm_anon_pprev_share = &mapping->i_mmap;
+}
+
+static __inline__ int __anon_remove_vma(struct vm_area_struct *vma,
+					struct address_space *mapping)
+{
+	struct vm_area_struct *next;
+	int ret = 0;
+
+	next = vma->vm_anon_next_share;
+	if (next)
+		next->vm_anon_pprev_share = vma->vm_anon_pprev_share;
+	*(vma->vm_anon_pprev_share) = next;
+	if (mapping->i_mmap == NULL)
+		ret = 1;
+
+	return ret;
+}
+
+/* Attach VMA's anon_area to NEW_VMA */
+void __anon_dup(struct vm_area_struct *vma, struct vm_area_struct *new_vma)
+{
+	struct address_space *mapping = vma->vm_anon;
+
+	__anon_insert_vma(new_vma, mapping);
+	new_vma->vm_anon = mapping;
+}
+
+void anon_dup(struct vm_area_struct *vma, struct vm_area_struct *new_vma)
+{
+	struct address_space *mapping = vma->vm_anon;
+
+	if (mapping == NULL)
+		BUG();
+
+	spin_lock(&mapping->i_shared_lock);
+	__anon_insert_vma(new_vma, mapping);
+	new_vma->vm_anon = mapping;
+	spin_unlock(&mapping->i_shared_lock);
+}
+
+/* Free up all the anonymous pages assosciated with MAPPING. */
+static void invalidate_anon_pages(struct address_space *mapping)
+{
+	spin_lock(&anoncache_lock);
+
+	for (;;) {
+		struct list_head *entry = mapping->pages.next;
+		struct page *page;
+
+		if (entry == &mapping->pages)
+			break;
+
+		page = list_entry(entry, struct page, list);
+
+		get_page(page);
+		while (TryLockPage(page)) {
+			spin_unlock(&anoncache_lock);
+			wait_on_page(page);
+			spin_lock(&anoncache_lock);
+		}
+
+		if (PageSwapCache(page)) {
+			spin_unlock(&anoncache_lock);
+			delete_from_swap_cache_nolock(page);
+			spin_lock(&anoncache_lock);
+		}
+		put_page(page);
+
+		nr_anon_pages--;
+
+		lru_cache_del(page);
+
+		list_del(&page->list);
+		mapping->nrpages--;
+		ClearPageAnon(page);
+		page->mapping = NULL;
+		UnlockPage(page);
+
+		__free_page(page);
+	}
+
+	spin_unlock(&anoncache_lock);
+
+	if (mapping->nrpages != 0)
+		BUG();
+}
+
+/* VMA has been resized in some way, or one of the anon_area owners
+ * has gone away.  Trim the anonymous pages from the anon_area which
+ * have a reference count of one.  These pages are no longer
+ * referenced validly by any VMA and thus can be safely disposed.
+ *
+ * This is actually an optimization of sorts, we could just
+ * ignore this situation and let the eventual final anon_put
+ * get rid of the pages.
+ *
+ * It is the callers responsibility to unmap and free the
+ * pages from the address space of the process before invoking
+ * this.  It cannot work otherwise.
+ */
+void anon_trim(struct vm_area_struct *vma)
+{
+	struct address_space *mapping = vma->vm_anon;
+	struct list_head *entry;
+
+	spin_lock(&anoncache_lock);
+
+	entry = mapping->pages.next;
+	while (entry != &mapping->pages) {
+		struct page *page = list_entry(entry, struct page, list);
+		struct list_head *next = entry->next;
+
+		entry = next;
+
+		if (page_count(page) != 1)
+			continue;
+
+		if (TryLockPage(page))
+			continue;
+
+		nr_anon_pages--;
+
+		lru_cache_del(page);
+
+		list_del(&page->list);
+		mapping->nrpages--;
+		ClearPageAnon(page);
+		page->mapping = NULL;
+		UnlockPage(page);
+
+		__free_page(page);
+	}
+
+	spin_unlock(&anoncache_lock);
+}
+
+/* Disassosciate VMA with the vm_anon attached to it. */
+void __anon_put(struct vm_area_struct *vma)
+{
+	struct address_space *mapping = vma->vm_anon;
+
+	if (mapping == NULL)
+		BUG();
+	if (mapping->i_mmap == NULL)
+		BUG();
+
+	if (__anon_remove_vma(vma, mapping))
+		BUG();
+
+	anon_trim(vma);
+
+	vma->vm_anon = NULL;
+}
+
+void anon_put(struct vm_area_struct *vma)
+{
+	struct address_space *mapping = vma->vm_anon;
+
+	if (mapping == NULL)
+		BUG();
+	if (mapping->i_mmap == NULL)
+		BUG();
+
+	spin_lock(&mapping->i_shared_lock);
+	if (__anon_remove_vma(vma, mapping)) {
+		spin_unlock(&mapping->i_shared_lock);
+		invalidate_anon_pages(mapping);
+		kmem_cache_free(anon_cachep, mapping);
+	} else {
+		spin_unlock(&mapping->i_shared_lock);
+		anon_trim(vma);
+	}
+
+	vma->vm_anon = NULL;
+}
+
+
+/* Forcibly delete an anonymous page.  This also kills the
+ * original reference made by anon_cow.
+ */
+void anon_page_kill(struct page *page)
+{
+	get_page(page);
+	lock_page(page);
+	put_page(page);
+
+	spin_lock(&anoncache_lock);
+
+	nr_anon_pages--;
+	lru_cache_del(page);
+	page->mapping->nrpages--;
+	list_del(&page->list);
+	ClearPageAnon(page);
+	page->mapping = NULL;
+	UnlockPage(page);
+
+	put_page(page);
+	__free_page(page);
+
+	spin_unlock(&anoncache_lock);
+}
+
+static int anon_try_to_free_page(struct page *page)
+{
+	if (page_count(page) <= 1)
+		BUG();
+	if (!PageLocked(page))
+		BUG();
+
+	if (PageSwapCache(page)) {
+		int pg_count = page_count(page);
+
+		/* In this case there had better be at least
+		 * 3 owners of this page.  The anon cache, the
+		 * swap cache, and our caller.  If not, we have
+		 * some _SERIOUS_ problems.
+		 */
+		if (pg_count < 3)
+			BUG();
+
+		/* And we can only delete the page from the
+		 * swapcache if the count is exactly three.
+		 */
+		if (pg_count != 3)
+			return 0;
+
+		__delete_from_swap_cache(page);
+	}
+
+	spin_lock(&anoncache_lock);
+	if (page_count(page) == 2) {
+		struct address_space *mapping = page->mapping;
+
+		nr_anon_pages--;
+
+		mapping->nrpages--;
+		list_del(&page->list);
+		ClearPageAnon(page);
+		page->mapping = NULL;
+		spin_unlock(&anoncache_lock);
+
+		__free_page(page);
+		return 1;
+	}
+	spin_unlock(&anoncache_lock);
+
+	return 0;
+}
+
+struct address_space_operations anon_address_space_operations = {
+	sync_page:		block_sync_page,
+	try_to_free_page:	anon_try_to_free_page
+};
+
+/* SLAB constructor for anonymous area mappings. */
+static void anon_ctor(void *__p, kmem_cache_t *cache, unsigned long flags)
+{
+	struct address_space *mapping = __p;
+
+	INIT_LIST_HEAD(&mapping->pages);
+	mapping->nrpages = 0;
+	mapping->a_ops = &anon_address_space_operations;
+	mapping->host = NULL;
+	mapping->i_mmap = NULL;
+	spin_lock_init(&mapping->i_shared_lock);
+}
+
+/* Create a new anonymous mapping, and attach it to VMA. */
+static struct address_space *anon_alloc(struct vm_area_struct *vma)
+{
+	struct address_space *mapping = kmem_cache_alloc(anon_cachep, GFP_KERNEL);
+
+	if (mapping) {
+		mapping->i_mmap = vma;
+		vma->vm_anon = mapping;
+		vma->vm_anon_next_share = NULL;
+		vma->vm_anon_pprev_share = &mapping->i_mmap;
+	}
+
+	return mapping;
+}
+
+static void anon_page_insert(struct vm_area_struct *vma, unsigned long address,
+	struct address_space *mapping, struct page *page)
+{
+	page->index = ((address - vma->vm_start) >> PAGE_SHIFT) + vma->vm_pgoff;
+
+	get_page(page);
+
+	spin_lock(&anoncache_lock);
+	SetPageAnon(page);
+	mapping->nrpages++;
+	list_add(&page->list, &mapping->pages);
+	page->mapping = mapping;
+	spin_unlock(&anoncache_lock);
+
+	lru_cache_add(page);
+
+	nr_anon_pages++;
+}
+
+static __inline__ struct address_space *get_anon(struct vm_area_struct *vma)
+{
+	struct address_space *mapping = vma->vm_anon;
+
+	if (mapping == NULL)
+		mapping = anon_alloc(vma);
+
+	return mapping;
+}
+
+int anon_page_add(struct vm_area_struct *vma, unsigned long address, struct page *page)
+{
+	if (!page->mapping) {
+		struct address_space *mapping = get_anon(vma);
+		if (mapping) {
+			anon_page_insert(vma, address, mapping, page);
+			return 0;
+		}
+	} else {
+		if (vma->vm_anon != page->mapping)
+			BUG();
+		return 0;
+	}
+	return -1;
+}
+
+/*
+ * We special-case the C-O-W ZERO_PAGE, because it's such
+ * a common occurrence (no need to read the page to know
+ * that it's zero - better for the cache and memory subsystem).
+ */
+static inline void copy_cow_page(struct page * from, struct page * to, unsigned long address)
+{
+	if (from == ZERO_PAGE(address)) {
+		clear_user_highpage(to, address);
+		return;
+	}
+	copy_user_highpage(to, from, address);
+}
+
+struct page *anon_cow(struct vm_area_struct *vma, unsigned long address, struct page *orig_page)
+{
+	struct address_space *mapping = get_anon(vma);
+
+	if (mapping) {
+		struct page *new_page = alloc_page(GFP_HIGHUSER);
+
+		if (new_page) {
+			copy_cow_page(orig_page, new_page, address);
+			anon_page_insert(vma, address, mapping, new_page);
+		}
+
+		return new_page;
+	}
+
+	return NULL;
+}
+
+void anon_init(void)
+{
+	anon_cachep = kmem_cache_create("anon_area",
+					sizeof(struct address_space),
+					0, SLAB_HWCACHE_ALIGN,
+					anon_ctor, NULL);
+	if (!anon_cachep)
+		panic("anon_init: Cannot alloc anonymous area mapping cache.");
+}

----- End forwarded message -----
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
