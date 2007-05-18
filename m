Message-Id: <200705180737.l4I7b5aR010752@shell0.pdx.osdl.net>
Subject: [patch 2/8] mm: merge populate and nopage into fault (fixes nonlinear)
From: akpm@linux-foundation.org
Date: Fri, 18 May 2007 00:37:06 -0700
Sender: owner-linux-mm@kvack.org
From: Nick Piggin <npiggin@suse.de>
Return-Path: <owner-linux-mm@kvack.org>
To: torvalds@linux-foundation.org
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, npiggin@suse.de, randy.dunlap@oracle.com
List-ID: <linux-mm.kvack.org>

Nonlinear mappings are (AFAIKS) simply a virtual memory concept that encodes
the virtual address -> file offset differently from linear mappings.

->populate is a layering violation because the filesystem/pagecache code
should need to know anything about the virtual memory mapping.  The hitch here
is that the ->nopage handler didn't pass down enough information (ie.  pgoff).
 But it is more logical to pass pgoff rather than have the ->nopage function
calculate it itself anyway (because that's a similar layering violation).

Having the populate handler install the pte itself is likewise a nasty thing
to be doing.

This patch introduces a new fault handler that replaces ->nopage and
->populate and (later) ->nopfn.  Most of the old mechanism is still in place
so there is a lot of duplication and nice cleanups that can be removed if
everyone switches over.

The rationale for doing this in the first place is that nonlinear mappings are
subject to the pagefault vs invalidate/truncate race too, and it seemed stupid
to duplicate the synchronisation logic rather than just consolidate the two.

After this patch, MAP_NONBLOCK no longer sets up ptes for pages present in
pagecache.  Seems like a fringe functionality anyway.

NOPAGE_REFAULT is removed.  This should be implemented with ->fault, and no
users have hit mainline yet.

[akpm@linux-foundation.org: cleanup]
[randy.dunlap@oracle.com: doc. fixes for readahead]
Signed-off-by: Nick Piggin <npiggin@suse.de>
Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 Documentation/feature-removal-schedule.txt |   27 +++
 Documentation/filesystems/Locking          |    2 
 fs/gfs2/ops_address.c                      |    2 
 fs/gfs2/ops_file.c                         |    2 
 fs/gfs2/ops_vm.c                           |   34 ++--
 fs/ncpfs/mmap.c                            |   23 +--
 fs/ocfs2/aops.c                            |    2 
 fs/ocfs2/mmap.c                            |   17 +-
 fs/xfs/linux-2.6/xfs_file.c                |   23 +--
 include/linux/mm.h                         |   41 ++++-
 ipc/shm.c                                  |    9 -
 mm/filemap.c                               |   94 ++++++++-----
 mm/filemap_xip.c                           |   54 ++++---
 mm/fremap.c                                |  105 ++++++++++-----
 mm/memory.c                                |  132 ++++++++++++-------
 mm/mmap.c                                  |    8 -
 mm/nommu.c                                 |    3 
 mm/rmap.c                                  |    4 
 mm/shmem.c                                 |   82 ++---------
 mm/truncate.c                              |    2 
 20 files changed, 394 insertions(+), 272 deletions(-)

diff -puN Documentation/feature-removal-schedule.txt~mm-merge-populate-and-nopage-into-fault-fixes-nonlinear Documentation/feature-removal-schedule.txt
--- a/Documentation/feature-removal-schedule.txt~mm-merge-populate-and-nopage-into-fault-fixes-nonlinear
+++ a/Documentation/feature-removal-schedule.txt
@@ -160,6 +160,33 @@ Who:	Greg Kroah-Hartman <gregkh@suse.de>
 
 ---------------------------
 
+What:	filemap_nopage, filemap_populate
+When:	April 2007
+Why:	These legacy interfaces no longer have any callers in the kernel and
+	any functionality provided can be provided with filemap_fault. The
+	removal schedule is short because they are a big maintainence burden
+	and have some bugs.
+Who:	Nick Piggin <npiggin@suse.de>
+
+---------------------------
+
+What:	vm_ops.populate, install_page
+When:	April 2007
+Why:	These legacy interfaces no longer have any callers in the kernel and
+	any functionality provided can be provided with vm_ops.fault.
+Who:	Nick Piggin <npiggin@suse.de>
+
+---------------------------
+
+What:	vm_ops.nopage
+When:	February 2008, provided in-kernel callers have been converted
+Why:	This interface is replaced by vm_ops.fault, but it has been around
+	forever, is used by a lot of drivers, and doesn't cost much to
+	maintain.
+Who:	Nick Piggin <npiggin@suse.de>
+
+---------------------------
+
 What:	Interrupt only SA_* flags
 When:	September 2007
 Why:	The interrupt related SA_* flags are replaced by IRQF_* to move them
diff -puN Documentation/filesystems/Locking~mm-merge-populate-and-nopage-into-fault-fixes-nonlinear Documentation/filesystems/Locking
--- a/Documentation/filesystems/Locking~mm-merge-populate-and-nopage-into-fault-fixes-nonlinear
+++ a/Documentation/filesystems/Locking
@@ -510,12 +510,14 @@ More details about quota locking can be 
 prototypes:
 	void (*open)(struct vm_area_struct*);
 	void (*close)(struct vm_area_struct*);
+	struct page *(*fault)(struct vm_area_struct*, struct fault_data *);
 	struct page *(*nopage)(struct vm_area_struct*, unsigned long, int *);
 
 locking rules:
 		BKL	mmap_sem
 open:		no	yes
 close:		no	yes
+fault:		no	yes
 nopage:		no	yes
 
 ================================================================================
diff -puN fs/gfs2/ops_address.c~mm-merge-populate-and-nopage-into-fault-fixes-nonlinear fs/gfs2/ops_address.c
--- a/fs/gfs2/ops_address.c~mm-merge-populate-and-nopage-into-fault-fixes-nonlinear
+++ a/fs/gfs2/ops_address.c
@@ -250,7 +250,7 @@ static int gfs2_readpage(struct file *fi
 		if (file) {
 			gf = file->private_data;
 			if (test_bit(GFF_EXLOCK, &gf->f_flags))
-				/* gfs2_sharewrite_nopage has grabbed the ip->i_gl already */
+				/* gfs2_sharewrite_fault has grabbed the ip->i_gl already */
 				goto skip_lock;
 		}
 		gfs2_holder_init(ip->i_gl, LM_ST_SHARED, GL_ATIME|LM_FLAG_TRY_1CB, &gh);
diff -puN fs/gfs2/ops_file.c~mm-merge-populate-and-nopage-into-fault-fixes-nonlinear fs/gfs2/ops_file.c
--- a/fs/gfs2/ops_file.c~mm-merge-populate-and-nopage-into-fault-fixes-nonlinear
+++ a/fs/gfs2/ops_file.c
@@ -364,7 +364,7 @@ static int gfs2_mmap(struct file *file, 
 	else
 		vma->vm_ops = &gfs2_vm_ops_private;
 
-	vma->vm_flags |= VM_CAN_INVALIDATE;
+	vma->vm_flags |= VM_CAN_INVALIDATE|VM_CAN_NONLINEAR;
 
 	gfs2_glock_dq_uninit(&i_gh);
 
diff -puN fs/gfs2/ops_vm.c~mm-merge-populate-and-nopage-into-fault-fixes-nonlinear fs/gfs2/ops_vm.c
--- a/fs/gfs2/ops_vm.c~mm-merge-populate-and-nopage-into-fault-fixes-nonlinear
+++ a/fs/gfs2/ops_vm.c
@@ -27,13 +27,13 @@
 #include "trans.h"
 #include "util.h"
 
-static struct page *gfs2_private_nopage(struct vm_area_struct *area,
-					unsigned long address, int *type)
+static struct page *gfs2_private_fault(struct vm_area_struct *vma,
+					struct fault_data *fdata)
 {
-	struct gfs2_inode *ip = GFS2_I(area->vm_file->f_mapping->host);
+	struct gfs2_inode *ip = GFS2_I(vma->vm_file->f_mapping->host);
 
 	set_bit(GIF_PAGED, &ip->i_flags);
-	return filemap_nopage(area, address, type);
+	return filemap_fault(vma, fdata);
 }
 
 static int alloc_page_backing(struct gfs2_inode *ip, struct page *page)
@@ -104,16 +104,14 @@ out:
 	return error;
 }
 
-static struct page *gfs2_sharewrite_nopage(struct vm_area_struct *area,
-					   unsigned long address, int *type)
+static struct page *gfs2_sharewrite_fault(struct vm_area_struct *vma,
+						struct fault_data *fdata)
 {
-	struct file *file = area->vm_file;
+	struct file *file = vma->vm_file;
 	struct gfs2_file *gf = file->private_data;
 	struct gfs2_inode *ip = GFS2_I(file->f_mapping->host);
 	struct gfs2_holder i_gh;
 	struct page *result = NULL;
-	unsigned long index = ((address - area->vm_start) >> PAGE_CACHE_SHIFT) +
-			      area->vm_pgoff;
 	int alloc_required;
 	int error;
 
@@ -124,21 +122,25 @@ static struct page *gfs2_sharewrite_nopa
 	set_bit(GIF_PAGED, &ip->i_flags);
 	set_bit(GIF_SW_PAGED, &ip->i_flags);
 
-	error = gfs2_write_alloc_required(ip, (u64)index << PAGE_CACHE_SHIFT,
-					  PAGE_CACHE_SIZE, &alloc_required);
-	if (error)
+	error = gfs2_write_alloc_required(ip,
+					(u64)fdata->pgoff << PAGE_CACHE_SHIFT,
+					PAGE_CACHE_SIZE, &alloc_required);
+	if (error) {
+		fdata->type = VM_FAULT_OOM; /* XXX: are these right? */
 		goto out;
+	}
 
 	set_bit(GFF_EXLOCK, &gf->f_flags);
-	result = filemap_nopage(area, address, type);
+	result = filemap_fault(vma, fdata);
 	clear_bit(GFF_EXLOCK, &gf->f_flags);
-	if (!result || result == NOPAGE_OOM)
+	if (!result)
 		goto out;
 
 	if (alloc_required) {
 		error = alloc_page_backing(ip, result);
 		if (error) {
 			page_cache_release(result);
+			fdata->type = VM_FAULT_OOM;
 			result = NULL;
 			goto out;
 		}
@@ -152,10 +154,10 @@ out:
 }
 
 struct vm_operations_struct gfs2_vm_ops_private = {
-	.nopage = gfs2_private_nopage,
+	.fault = gfs2_private_fault,
 };
 
 struct vm_operations_struct gfs2_vm_ops_sharewrite = {
-	.nopage = gfs2_sharewrite_nopage,
+	.fault = gfs2_sharewrite_fault,
 };
 
diff -puN fs/ncpfs/mmap.c~mm-merge-populate-and-nopage-into-fault-fixes-nonlinear fs/ncpfs/mmap.c
--- a/fs/ncpfs/mmap.c~mm-merge-populate-and-nopage-into-fault-fixes-nonlinear
+++ a/fs/ncpfs/mmap.c
@@ -25,8 +25,8 @@
 /*
  * Fill in the supplied page for mmap
  */
-static struct page* ncp_file_mmap_nopage(struct vm_area_struct *area,
-				     unsigned long address, int *type)
+static struct page* ncp_file_mmap_fault(struct vm_area_struct *area,
+						struct fault_data *fdata)
 {
 	struct file *file = area->vm_file;
 	struct dentry *dentry = file->f_path.dentry;
@@ -40,15 +40,17 @@ static struct page* ncp_file_mmap_nopage
 
 	page = alloc_page(GFP_HIGHUSER); /* ncpfs has nothing against high pages
 	           as long as recvmsg and memset works on it */
-	if (!page)
-		return page;
+	if (!page) {
+		fdata->type = VM_FAULT_OOM;
+		return NULL;
+	}
 	pg_addr = kmap(page);
-	address &= PAGE_MASK;
-	pos = address - area->vm_start + (area->vm_pgoff << PAGE_SHIFT);
+	pos = fdata->pgoff << PAGE_SHIFT;
 
 	count = PAGE_SIZE;
-	if (address + PAGE_SIZE > area->vm_end) {
-		count = area->vm_end - address;
+	if (fdata->address + PAGE_SIZE > area->vm_end) {
+		WARN_ON(1); /* shouldn't happen? */
+		count = area->vm_end - fdata->address;
 	}
 	/* what we can read in one go */
 	bufsize = NCP_SERVER(inode)->buffer_size;
@@ -91,15 +93,14 @@ static struct page* ncp_file_mmap_nopage
 	 * fetches from the network, here the analogue of disk.
 	 * -- wli
 	 */
-	if (type)
-		*type = VM_FAULT_MAJOR;
+	fdata->type = VM_FAULT_MAJOR;
 	count_vm_event(PGMAJFAULT);
 	return page;
 }
 
 static struct vm_operations_struct ncp_file_mmap =
 {
-	.nopage	= ncp_file_mmap_nopage,
+	.fault = ncp_file_mmap_fault,
 };
 
 
diff -puN fs/ocfs2/aops.c~mm-merge-populate-and-nopage-into-fault-fixes-nonlinear fs/ocfs2/aops.c
--- a/fs/ocfs2/aops.c~mm-merge-populate-and-nopage-into-fault-fixes-nonlinear
+++ a/fs/ocfs2/aops.c
@@ -229,7 +229,7 @@ static int ocfs2_readpage(struct file *f
 	 * might now be discovering a truncate that hit on another node.
 	 * block_read_full_page->get_block freaks out if it is asked to read
 	 * beyond the end of a file, so we check here.  Callers
-	 * (generic_file_read, fault->nopage) are clever enough to check i_size
+	 * (generic_file_read, vm_ops->fault) are clever enough to check i_size
 	 * and notice that the page they just read isn't needed.
 	 *
 	 * XXX sys_readahead() seems to get that wrong?
diff -puN fs/ocfs2/mmap.c~mm-merge-populate-and-nopage-into-fault-fixes-nonlinear fs/ocfs2/mmap.c
--- a/fs/ocfs2/mmap.c~mm-merge-populate-and-nopage-into-fault-fixes-nonlinear
+++ a/fs/ocfs2/mmap.c
@@ -42,16 +42,14 @@
 #include "inode.h"
 #include "mmap.h"
 
-static struct page *ocfs2_nopage(struct vm_area_struct * area,
-				 unsigned long address,
-				 int *type)
+static struct page *ocfs2_fault(struct vm_area_struct *area,
+						struct fault_data *fdata)
 {
-	struct page *page = NOPAGE_SIGBUS;
+	struct page *page = NULL;
 	sigset_t blocked, oldset;
 	int ret;
 
-	mlog_entry("(area=%p, address=%lu, type=%p)\n", area, address,
-		   type);
+	mlog_entry("(area=%p, page offset=%lu)\n", area, fdata->pgoff);
 
 	/* The best way to deal with signals in this path is
 	 * to block them upfront, rather than allowing the
@@ -62,11 +60,12 @@ static struct page *ocfs2_nopage(struct 
 	 * from sigprocmask */
 	ret = sigprocmask(SIG_BLOCK, &blocked, &oldset);
 	if (ret < 0) {
+		fdata->type = VM_FAULT_SIGBUS;
 		mlog_errno(ret);
 		goto out;
 	}
 
-	page = filemap_nopage(area, address, type);
+	page = filemap_fault(area, fdata);
 
 	ret = sigprocmask(SIG_SETMASK, &oldset, NULL);
 	if (ret < 0)
@@ -77,7 +76,7 @@ out:
 }
 
 static struct vm_operations_struct ocfs2_file_vm_ops = {
-	.nopage = ocfs2_nopage,
+	.fault		= ocfs2_fault,
 };
 
 int ocfs2_mmap(struct file *file, struct vm_area_struct *vma)
@@ -107,7 +106,7 @@ int ocfs2_mmap(struct file *file, struct
 	ocfs2_meta_unlock(file->f_dentry->d_inode, lock_level);
 out:
 	vma->vm_ops = &ocfs2_file_vm_ops;
-	vma->vm_flags |= VM_CAN_INVALIDATE;
+	vma->vm_flags |= VM_CAN_INVALIDATE | VM_CAN_NONLINEAR;
 	return 0;
 }
 
diff -puN fs/xfs/linux-2.6/xfs_file.c~mm-merge-populate-and-nopage-into-fault-fixes-nonlinear fs/xfs/linux-2.6/xfs_file.c
--- a/fs/xfs/linux-2.6/xfs_file.c~mm-merge-populate-and-nopage-into-fault-fixes-nonlinear
+++ a/fs/xfs/linux-2.6/xfs_file.c
@@ -246,18 +246,19 @@ xfs_file_fsync(
 
 #ifdef CONFIG_XFS_DMAPI
 STATIC struct page *
-xfs_vm_nopage(
-	struct vm_area_struct	*area,
-	unsigned long		address,
-	int			*type)
+xfs_vm_fault(
+	struct vm_area_struct	*vma,
+	struct fault_data	*fdata)
 {
-	struct inode	*inode = area->vm_file->f_path.dentry->d_inode;
+	struct inode	*inode = vma->vm_file->f_path.dentry->d_inode;
 	bhv_vnode_t	*vp = vn_from_inode(inode);
 
 	ASSERT_ALWAYS(vp->v_vfsp->vfs_flag & VFS_DMI);
-	if (XFS_SEND_MMAP(XFS_VFSTOM(vp->v_vfsp), area, 0))
+	if (XFS_SEND_MMAP(XFS_VFSTOM(vp->v_vfsp), vma, 0)) {
+		fdata->type = VM_FAULT_SIGBUS;
 		return NULL;
-	return filemap_nopage(area, address, type);
+	}
+	return filemap_fault(vma, fdata);
 }
 #endif /* CONFIG_XFS_DMAPI */
 
@@ -343,7 +344,7 @@ xfs_file_mmap(
 	struct vm_area_struct *vma)
 {
 	vma->vm_ops = &xfs_file_vm_ops;
-	vma->vm_flags |= VM_CAN_INVALIDATE;
+	vma->vm_flags |= VM_CAN_INVALIDATE | VM_CAN_NONLINEAR;
 
 #ifdef CONFIG_XFS_DMAPI
 	if (vn_from_inode(filp->f_path.dentry->d_inode)->v_vfsp->vfs_flag & VFS_DMI)
@@ -502,14 +503,12 @@ const struct file_operations xfs_dir_fil
 };
 
 static struct vm_operations_struct xfs_file_vm_ops = {
-	.nopage		= filemap_nopage,
-	.populate	= filemap_populate,
+	.fault		= filemap_fault,
 };
 
 #ifdef CONFIG_XFS_DMAPI
 static struct vm_operations_struct xfs_dmapi_file_vm_ops = {
-	.nopage		= xfs_vm_nopage,
-	.populate	= filemap_populate,
+	.fault		= xfs_vm_fault,
 #ifdef HAVE_VMOP_MPROTECT
 	.mprotect	= xfs_vm_mprotect,
 #endif
diff -puN include/linux/mm.h~mm-merge-populate-and-nopage-into-fault-fixes-nonlinear include/linux/mm.h
--- a/include/linux/mm.h~mm-merge-populate-and-nopage-into-fault-fixes-nonlinear
+++ a/include/linux/mm.h
@@ -175,6 +175,7 @@ extern unsigned int kobjsize(const void 
 					 * In this case, do_no_page must
 					 * return with the page locked.
 					 */
+#define VM_CAN_NONLINEAR 0x10000000	/* Has ->fault & does nonlinear pages */
 
 #ifndef VM_STACK_DEFAULT_FLAGS		/* arch can override this */
 #define VM_STACK_DEFAULT_FLAGS VM_DATA_DEFAULT_FLAGS
@@ -198,6 +199,25 @@ extern unsigned int kobjsize(const void 
  */
 extern pgprot_t protection_map[16];
 
+#define FAULT_FLAG_WRITE	0x01
+#define FAULT_FLAG_NONLINEAR	0x02
+
+/*
+ * fault_data is filled in the the pagefault handler and passed to the
+ * vma's ->fault function. That function is responsible for filling in
+ * 'type', which is the type of fault if a page is returned, or the type
+ * of error if NULL is returned.
+ *
+ * pgoff should be used in favour of address, if possible. If pgoff is
+ * used, one may set VM_CAN_NONLINEAR in the vma->vm_flags to get
+ * nonlinear mapping support.
+ */
+struct fault_data {
+	unsigned long address;
+	pgoff_t pgoff;
+	unsigned int flags;
+	int type;
+};
 
 /*
  * These are the virtual MM functions - opening of an area, closing and
@@ -207,9 +227,15 @@ extern pgprot_t protection_map[16];
 struct vm_operations_struct {
 	void (*open)(struct vm_area_struct * area);
 	void (*close)(struct vm_area_struct * area);
-	struct page * (*nopage)(struct vm_area_struct * area, unsigned long address, int *type);
-	unsigned long (*nopfn)(struct vm_area_struct * area, unsigned long address);
-	int (*populate)(struct vm_area_struct * area, unsigned long address, unsigned long len, pgprot_t prot, unsigned long pgoff, int nonblock);
+	struct page *(*fault)(struct vm_area_struct *vma,
+			struct fault_data *fdata);
+	struct page *(*nopage)(struct vm_area_struct *area,
+			unsigned long address, int *type);
+	unsigned long (*nopfn)(struct vm_area_struct *area,
+			unsigned long address);
+	int (*populate)(struct vm_area_struct *area, unsigned long address,
+			unsigned long len, pgprot_t prot, unsigned long pgoff,
+			int nonblock);
 
 	/* notification that a previously read-only page is about to become
 	 * writable, if an error is returned it will cause a SIGBUS */
@@ -658,7 +684,6 @@ static inline int page_mapped(struct pag
  */
 #define NOPAGE_SIGBUS	(NULL)
 #define NOPAGE_OOM	((struct page *) (-1))
-#define NOPAGE_REFAULT	((struct page *) (-2))	/* Return to userspace, rerun */
 
 /*
  * Error return values for the *_nopfn functions
@@ -1106,9 +1131,11 @@ extern void truncate_inode_pages_range(s
 				       loff_t lstart, loff_t lend);
 
 /* generic vm_area_ops exported for stackable file systems */
-extern struct page *filemap_nopage(struct vm_area_struct *, unsigned long, int *);
-extern int filemap_populate(struct vm_area_struct *, unsigned long,
-		unsigned long, pgprot_t, unsigned long, int);
+extern struct page *filemap_fault(struct vm_area_struct *, struct fault_data *);
+extern struct page * __deprecated_for_modules
+filemap_nopage(struct vm_area_struct *, unsigned long, int *);
+extern int __deprecated_for_modules filemap_populate(struct vm_area_struct *,
+		unsigned long, unsigned long, pgprot_t, unsigned long, int);
 
 /* mm/page-writeback.c */
 int write_one_page(struct page *page, int wait);
diff -puN ipc/shm.c~mm-merge-populate-and-nopage-into-fault-fixes-nonlinear ipc/shm.c
--- a/ipc/shm.c~mm-merge-populate-and-nopage-into-fault-fixes-nonlinear
+++ a/ipc/shm.c
@@ -226,13 +226,13 @@ static void shm_close(struct vm_area_str
 	mutex_unlock(&shm_ids(ns).mutex);
 }
 
-static struct page *shm_nopage(struct vm_area_struct *vma,
-			       unsigned long address, int *type)
+static struct page *shm_fault(struct vm_area_struct *vma,
+					struct fault_data *fdata)
 {
 	struct file *file = vma->vm_file;
 	struct shm_file_data *sfd = shm_file_data(file);
 
-	return sfd->vm_ops->nopage(vma, address, type);
+	return sfd->vm_ops->fault(vma, fdata);
 }
 
 #ifdef CONFIG_NUMA
@@ -269,6 +269,7 @@ static int shm_mmap(struct file * file, 
 	if (ret != 0)
 		return ret;
 	sfd->vm_ops = vma->vm_ops;
+	BUG_ON(!sfd->vm_ops->fault);
 	vma->vm_ops = &shm_vm_ops;
 	shm_open(vma);
 
@@ -327,7 +328,7 @@ static const struct file_operations shm_
 static struct vm_operations_struct shm_vm_ops = {
 	.open	= shm_open,	/* callback for a new vm-area open */
 	.close	= shm_close,	/* callback for when the vm-area is released */
-	.nopage	= shm_nopage,
+	.fault	= shm_fault,
 #if defined(CONFIG_NUMA)
 	.set_policy = shm_set_policy,
 	.get_policy = shm_get_policy,
diff -puN mm/filemap.c~mm-merge-populate-and-nopage-into-fault-fixes-nonlinear mm/filemap.c
--- a/mm/filemap.c~mm-merge-populate-and-nopage-into-fault-fixes-nonlinear
+++ a/mm/filemap.c
@@ -1334,40 +1334,38 @@ static int fastcall page_cache_read(stru
 #define MMAP_LOTSAMISS  (100)
 
 /**
- * filemap_nopage - read in file data for page fault handling
- * @area:	the applicable vm_area
- * @address:	target address to read in
- * @type:	returned with VM_FAULT_{MINOR,MAJOR} if not %NULL
+ * filemap_fault - read in file data for page fault handling
+ * @vma:	user vma (not used)
+ * @fdata:	the applicable fault_data
  *
- * filemap_nopage() is invoked via the vma operations vector for a
+ * filemap_fault() is invoked via the vma operations vector for a
  * mapped memory region to read in file data during a page fault.
  *
  * The goto's are kind of ugly, but this streamlines the normal case of having
  * it in the page cache, and handles the special cases reasonably without
  * having a lot of duplicated code.
  */
-struct page *filemap_nopage(struct vm_area_struct *area,
-				unsigned long address, int *type)
+struct page *filemap_fault(struct vm_area_struct *vma, struct fault_data *fdata)
 {
 	int error;
-	struct file *file = area->vm_file;
+	struct file *file = vma->vm_file;
 	struct address_space *mapping = file->f_mapping;
 	struct file_ra_state *ra = &file->f_ra;
 	struct inode *inode = mapping->host;
 	struct page *page;
-	unsigned long size, pgoff;
-	int did_readaround = 0, majmin = VM_FAULT_MINOR;
+	unsigned long size;
+	int did_readaround = 0;
 
-	BUG_ON(!(area->vm_flags & VM_CAN_INVALIDATE));
+	fdata->type = VM_FAULT_MINOR;
 
-	pgoff = ((address-area->vm_start) >> PAGE_CACHE_SHIFT) + area->vm_pgoff;
+	BUG_ON(!(vma->vm_flags & VM_CAN_INVALIDATE));
 
 	size = (i_size_read(inode) + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
-	if (pgoff >= size)
+	if (fdata->pgoff >= size)
 		goto outside_data_content;
 
 	/* If we don't want any read-ahead, don't bother */
-	if (VM_RandomReadHint(area))
+	if (VM_RandomReadHint(vma))
 		goto no_cached_page;
 
 	/*
@@ -1376,19 +1374,19 @@ struct page *filemap_nopage(struct vm_ar
 	 *
 	 * For sequential accesses, we use the generic readahead logic.
 	 */
-	if (VM_SequentialReadHint(area))
-		page_cache_readahead(mapping, ra, file, pgoff, 1);
+	if (VM_SequentialReadHint(vma))
+		page_cache_readahead(mapping, ra, file, fdata->pgoff, 1);
 
 	/*
 	 * Do we have something in the page cache already?
 	 */
 retry_find:
-	page = find_lock_page(mapping, pgoff);
+	page = find_lock_page(mapping, fdata->pgoff);
 	if (!page) {
 		unsigned long ra_pages;
 
-		if (VM_SequentialReadHint(area)) {
-			handle_ra_miss(mapping, ra, pgoff);
+		if (VM_SequentialReadHint(vma)) {
+			handle_ra_miss(mapping, ra, fdata->pgoff);
 			goto no_cached_page;
 		}
 		ra->mmap_miss++;
@@ -1405,7 +1403,7 @@ retry_find:
 		 * check did_readaround, as this is an inner loop.
 		 */
 		if (!did_readaround) {
-			majmin = VM_FAULT_MAJOR;
+			fdata->type = VM_FAULT_MAJOR;
 			count_vm_event(PGMAJFAULT);
 		}
 		did_readaround = 1;
@@ -1413,11 +1411,11 @@ retry_find:
 		if (ra_pages) {
 			pgoff_t start = 0;
 
-			if (pgoff > ra_pages / 2)
-				start = pgoff - ra_pages / 2;
+			if (fdata->pgoff > ra_pages / 2)
+				start = fdata->pgoff - ra_pages / 2;
 			do_page_cache_readahead(mapping, file, start, ra_pages);
 		}
-		page = find_lock_page(mapping, pgoff);
+		page = find_lock_page(mapping, fdata->pgoff);
 		if (!page)
 			goto no_cached_page;
 	}
@@ -1434,7 +1432,7 @@ retry_find:
 
 	/* Must recheck i_size under page lock */
 	size = (i_size_read(inode) + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
-	if (unlikely(pgoff >= size)) {
+	if (unlikely(fdata->pgoff >= size)) {
 		unlock_page(page);
 		goto outside_data_content;
 	}
@@ -1443,8 +1441,6 @@ retry_find:
 	 * Found the page and have a reference on it.
 	 */
 	mark_page_accessed(page);
-	if (type)
-		*type = majmin;
 	return page;
 
 outside_data_content:
@@ -1452,15 +1448,17 @@ outside_data_content:
 	 * An external ptracer can access pages that normally aren't
 	 * accessible..
 	 */
-	if (area->vm_mm == current->mm)
-		return NOPAGE_SIGBUS;
+	if (vma->vm_mm == current->mm) {
+		fdata->type = VM_FAULT_SIGBUS;
+		return NULL;
+	}
 	/* Fall through to the non-read-ahead case */
 no_cached_page:
 	/*
 	 * We're only likely to ever get here if MADV_RANDOM is in
 	 * effect.
 	 */
-	error = page_cache_read(file, pgoff);
+	error = page_cache_read(file, fdata->pgoff);
 
 	/*
 	 * The page we want has now been added to the page cache.
@@ -1476,13 +1474,15 @@ no_cached_page:
 	 * to schedule I/O.
 	 */
 	if (error == -ENOMEM)
-		return NOPAGE_OOM;
-	return NOPAGE_SIGBUS;
+		fdata->type = VM_FAULT_OOM;
+	else
+		fdata->type = VM_FAULT_SIGBUS;
+	return NULL;
 
 page_not_uptodate:
 	/* IO error path */
 	if (!did_readaround) {
-		majmin = VM_FAULT_MAJOR;
+		fdata->type = VM_FAULT_MAJOR;
 		count_vm_event(PGMAJFAULT);
 	}
 
@@ -1501,7 +1501,30 @@ page_not_uptodate:
 
 	/* Things didn't work out. Return zero to tell the mm layer so. */
 	shrink_readahead_size_eio(file, ra);
-	return NOPAGE_SIGBUS;
+	fdata->type = VM_FAULT_SIGBUS;
+	return NULL;
+}
+EXPORT_SYMBOL(filemap_fault);
+
+/*
+ * filemap_nopage and filemap_populate are legacy exports that are not used
+ * in tree. Scheduled for removal.
+ */
+struct page *filemap_nopage(struct vm_area_struct *area,
+				unsigned long address, int *type)
+{
+	struct page *page;
+	struct fault_data fdata;
+	fdata.address = address;
+	fdata.pgoff = ((address - area->vm_start) >> PAGE_CACHE_SHIFT)
+			+ area->vm_pgoff;
+	fdata.flags = 0;
+
+	page = filemap_fault(area, &fdata);
+	if (type)
+		*type = fdata.type;
+
+	return page;
 }
 EXPORT_SYMBOL(filemap_nopage);
 
@@ -1679,8 +1702,7 @@ repeat:
 EXPORT_SYMBOL(filemap_populate);
 
 struct vm_operations_struct generic_file_vm_ops = {
-	.nopage		= filemap_nopage,
-	.populate	= filemap_populate,
+	.fault		= filemap_fault,
 };
 
 /* This is used for a general mmap of a disk file */
@@ -1693,7 +1715,7 @@ int generic_file_mmap(struct file * file
 		return -ENOEXEC;
 	file_accessed(file);
 	vma->vm_ops = &generic_file_vm_ops;
-	vma->vm_flags |= VM_CAN_INVALIDATE;
+	vma->vm_flags |= VM_CAN_INVALIDATE | VM_CAN_NONLINEAR;
 	return 0;
 }
 
diff -puN mm/filemap_xip.c~mm-merge-populate-and-nopage-into-fault-fixes-nonlinear mm/filemap_xip.c
--- a/mm/filemap_xip.c~mm-merge-populate-and-nopage-into-fault-fixes-nonlinear
+++ a/mm/filemap_xip.c
@@ -226,62 +226,67 @@ __xip_unmap (struct address_space * mapp
 }
 
 /*
- * xip_nopage() is invoked via the vma operations vector for a
+ * xip_fault() is invoked via the vma operations vector for a
  * mapped memory region to read in file data during a page fault.
  *
- * This function is derived from filemap_nopage, but used for execute in place
+ * This function is derived from filemap_fault, but used for execute in place
  */
-static struct page *
-xip_file_nopage(struct vm_area_struct * area,
-		   unsigned long address,
-		   int *type)
+static struct page *xip_file_fault(struct vm_area_struct *area,
+					struct fault_data *fdata)
 {
 	struct file *file = area->vm_file;
 	struct address_space *mapping = file->f_mapping;
 	struct inode *inode = mapping->host;
 	struct page *page;
-	unsigned long size, pgoff, endoff;
+	pgoff_t size;
 
-	pgoff = ((address - area->vm_start) >> PAGE_CACHE_SHIFT)
-		+ area->vm_pgoff;
-	endoff = ((area->vm_end - area->vm_start) >> PAGE_CACHE_SHIFT)
-		+ area->vm_pgoff;
+	/* XXX: are VM_FAULT_ codes OK? */
 
 	size = (i_size_read(inode) + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
-	if (pgoff >= size)
-		return NOPAGE_SIGBUS;
+	if (fdata->pgoff >= size) {
+		fdata->type = VM_FAULT_SIGBUS;
+		return NULL;
+	}
 
-	page = mapping->a_ops->get_xip_page(mapping, pgoff*(PAGE_SIZE/512), 0);
+	page = mapping->a_ops->get_xip_page(mapping,
+					fdata->pgoff*(PAGE_SIZE/512), 0);
 	if (!IS_ERR(page))
 		goto out;
-	if (PTR_ERR(page) != -ENODATA)
-		return NOPAGE_SIGBUS;
+	if (PTR_ERR(page) != -ENODATA) {
+		fdata->type = VM_FAULT_OOM;
+		return NULL;
+	}
 
 	/* sparse block */
 	if ((area->vm_flags & (VM_WRITE | VM_MAYWRITE)) &&
 	    (area->vm_flags & (VM_SHARED| VM_MAYSHARE)) &&
 	    (!(mapping->host->i_sb->s_flags & MS_RDONLY))) {
 		/* maybe shared writable, allocate new block */
-		page = mapping->a_ops->get_xip_page (mapping,
-			pgoff*(PAGE_SIZE/512), 1);
-		if (IS_ERR(page))
-			return NOPAGE_SIGBUS;
+		page = mapping->a_ops->get_xip_page(mapping,
+					fdata->pgoff*(PAGE_SIZE/512), 1);
+		if (IS_ERR(page)) {
+			fdata->type = VM_FAULT_SIGBUS;
+			return NULL;
+		}
 		/* unmap page at pgoff from all other vmas */
-		__xip_unmap(mapping, pgoff);
+		__xip_unmap(mapping, fdata->pgoff);
 	} else {
 		/* not shared and writable, use xip_sparse_page() */
 		page = xip_sparse_page();
-		if (!page)
-			return NOPAGE_OOM;
+		if (!page) {
+			fdata->type = VM_FAULT_OOM;
+			return NULL;
+		}
 	}
 
 out:
+	fdata->type = VM_FAULT_MINOR;
 	page_cache_get(page);
 	return page;
 }
 
 static struct vm_operations_struct xip_file_vm_ops = {
-	.nopage         = xip_file_nopage,
+	.fault	= xip_file_fault,
 };
 
 int xip_file_mmap(struct file * file, struct vm_area_struct * vma)
@@ -290,6 +295,7 @@ int xip_file_mmap(struct file * file, st
 
 	file_accessed(file);
 	vma->vm_ops = &xip_file_vm_ops;
+	vma->vm_flags |= VM_CAN_NONLINEAR;
 	return 0;
 }
 EXPORT_SYMBOL_GPL(xip_file_mmap);
diff -puN mm/fremap.c~mm-merge-populate-and-nopage-into-fault-fixes-nonlinear mm/fremap.c
--- a/mm/fremap.c~mm-merge-populate-and-nopage-into-fault-fixes-nonlinear
+++ a/mm/fremap.c
@@ -126,6 +126,25 @@ out:
 	return err;
 }
 
+static int populate_range(struct mm_struct *mm, struct vm_area_struct *vma,
+			unsigned long addr, unsigned long size, pgoff_t pgoff)
+{
+	int err;
+
+	do {
+		err = install_file_pte(mm, vma, addr, pgoff, vma->vm_page_prot);
+		if (err)
+			return err;
+
+		size -= PAGE_SIZE;
+		addr += PAGE_SIZE;
+		pgoff++;
+	} while (size);
+
+        return 0;
+
+}
+
 /***
  * sys_remap_file_pages - remap arbitrary pages of a shared backing store
  *                        file within an existing vma.
@@ -183,41 +202,63 @@ asmlinkage long sys_remap_file_pages(uns
 	 * the single existing vma.  vm_private_data is used as a
 	 * swapout cursor in a VM_NONLINEAR vma.
 	 */
-	if (vma && (vma->vm_flags & VM_SHARED) &&
-		(!vma->vm_private_data || (vma->vm_flags & VM_NONLINEAR)) &&
-		vma->vm_ops && vma->vm_ops->populate &&
-			end > start && start >= vma->vm_start &&
-				end <= vma->vm_end) {
-
-		/* Must set VM_NONLINEAR before any pages are populated. */
-		if (pgoff != linear_page_index(vma, start) &&
-		    !(vma->vm_flags & VM_NONLINEAR)) {
-			if (!has_write_lock) {
-				up_read(&mm->mmap_sem);
-				down_write(&mm->mmap_sem);
-				has_write_lock = 1;
-				goto retry;
-			}
-			mapping = vma->vm_file->f_mapping;
-			spin_lock(&mapping->i_mmap_lock);
-			flush_dcache_mmap_lock(mapping);
-			vma->vm_flags |= VM_NONLINEAR;
-			vma_prio_tree_remove(vma, &mapping->i_mmap);
-			vma_nonlinear_insert(vma, &mapping->i_mmap_nonlinear);
-			flush_dcache_mmap_unlock(mapping);
-			spin_unlock(&mapping->i_mmap_lock);
+	if (!vma || !(vma->vm_flags & VM_SHARED))
+		goto out;
+
+	if (vma->vm_private_data && !(vma->vm_flags & VM_NONLINEAR))
+		goto out;
+
+	if ((!vma->vm_ops || !vma->vm_ops->populate) &&
+					!(vma->vm_flags & VM_CAN_NONLINEAR))
+		goto out;
+
+	if (end <= start || start < vma->vm_start || end > vma->vm_end)
+		goto out;
+
+	/* Must set VM_NONLINEAR before any pages are populated. */
+	if (!(vma->vm_flags & VM_NONLINEAR)) {
+		/* Don't need a nonlinear mapping, exit success */
+		if (pgoff == linear_page_index(vma, start)) {
+			err = 0;
+			goto out;
 		}
 
-		err = vma->vm_ops->populate(vma, start, size,
-					    vma->vm_page_prot,
-					    pgoff, flags & MAP_NONBLOCK);
-
-		/*
-		 * We can't clear VM_NONLINEAR because we'd have to do
-		 * it after ->populate completes, and that would prevent
-		 * downgrading the lock.  (Locks can't be upgraded).
-		 */
+		if (!has_write_lock) {
+			up_read(&mm->mmap_sem);
+			down_write(&mm->mmap_sem);
+			has_write_lock = 1;
+			goto retry;
+		}
+		mapping = vma->vm_file->f_mapping;
+		spin_lock(&mapping->i_mmap_lock);
+		flush_dcache_mmap_lock(mapping);
+		vma->vm_flags |= VM_NONLINEAR;
+		vma_prio_tree_remove(vma, &mapping->i_mmap);
+		vma_nonlinear_insert(vma, &mapping->i_mmap_nonlinear);
+		flush_dcache_mmap_unlock(mapping);
+		spin_unlock(&mapping->i_mmap_lock);
 	}
+
+	if (vma->vm_flags & VM_CAN_NONLINEAR) {
+		err = populate_range(mm, vma, start, size, pgoff);
+		if (!err && !(flags & MAP_NONBLOCK)) {
+			if (unlikely(has_write_lock)) {
+				downgrade_write(&mm->mmap_sem);
+				has_write_lock = 0;
+			}
+			make_pages_present(start, start+size);
+		}
+	} else
+		err = vma->vm_ops->populate(vma, start, size, vma->vm_page_prot,
+					    	pgoff, flags & MAP_NONBLOCK);
+
+	/*
+	 * We can't clear VM_NONLINEAR because we'd have to do
+	 * it after ->populate completes, and that would prevent
+	 * downgrading the lock.  (Locks can't be upgraded).
+	 */
+
+out:
 	if (likely(!has_write_lock))
 		up_read(&mm->mmap_sem);
 	else
diff -puN mm/memory.c~mm-merge-populate-and-nopage-into-fault-fixes-nonlinear mm/memory.c
--- a/mm/memory.c~mm-merge-populate-and-nopage-into-fault-fixes-nonlinear
+++ a/mm/memory.c
@@ -1049,7 +1049,8 @@ int get_user_pages(struct task_struct *t
 		if (pages)
 			foll_flags |= FOLL_GET;
 		if (!write && !(vma->vm_flags & VM_LOCKED) &&
-		    (!vma->vm_ops || !vma->vm_ops->nopage))
+		    (!vma->vm_ops || (!vma->vm_ops->nopage &&
+					!vma->vm_ops->fault)))
 			foll_flags |= FOLL_ANON;
 
 		do {
@@ -2281,10 +2282,10 @@ oom:
 }
 
 /*
- * do_no_page() tries to create a new page mapping. It aggressively
+ * __do_fault() tries to create a new page mapping. It aggressively
  * tries to share with existing pages, but makes a separate copy if
- * the "write_access" parameter is true in order to avoid the next
- * page fault.
+ * the FAULT_FLAG_WRITE is set in the flags parameter in order to avoid
+ * the next page fault.
  *
  * As this is called only for pages that do not currently exist, we
  * do not need to flush old virtual caches or the TLB.
@@ -2293,64 +2294,82 @@ oom:
  * but allow concurrent faults), and pte mapped but not yet locked.
  * We return with mmap_sem still held, but pte unmapped and unlocked.
  */
-static int do_no_page(struct mm_struct *mm, struct vm_area_struct *vma,
+static int __do_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 		unsigned long address, pte_t *page_table, pmd_t *pmd,
-		int write_access)
+		pgoff_t pgoff, unsigned int flags, pte_t orig_pte)
 {
 	spinlock_t *ptl;
-	struct page *page, *nopage_page;
+	struct page *page, *faulted_page;
 	pte_t entry;
-	int ret = VM_FAULT_MINOR;
 	int anon = 0;
 	struct page *dirty_page = NULL;
+	struct fault_data fdata;
+
+	fdata.address = address & PAGE_MASK;
+	fdata.pgoff = pgoff;
+	fdata.flags = flags;
 
 	pte_unmap(page_table);
 	BUG_ON(vma->vm_flags & VM_PFNMAP);
 
-	nopage_page = vma->vm_ops->nopage(vma, address & PAGE_MASK, &ret);
-	/* no page was available -- either SIGBUS, OOM or REFAULT */
-	if (unlikely(nopage_page == NOPAGE_SIGBUS))
-		return VM_FAULT_SIGBUS;
-	else if (unlikely(nopage_page == NOPAGE_OOM))
-		return VM_FAULT_OOM;
-	else if (unlikely(nopage_page == NOPAGE_REFAULT))
-		return VM_FAULT_MINOR;
+	if (likely(vma->vm_ops->fault)) {
+		fdata.type = -1;
+		faulted_page = vma->vm_ops->fault(vma, &fdata);
+		WARN_ON(fdata.type == -1);
+		if (unlikely(!faulted_page))
+			return fdata.type;
+	} else {
+		/* Legacy ->nopage path */
+		fdata.type = VM_FAULT_MINOR;
+		faulted_page = vma->vm_ops->nopage(vma, address & PAGE_MASK,
+								&fdata.type);
+		/* no page was available -- either SIGBUS or OOM */
+		if (unlikely(faulted_page == NOPAGE_SIGBUS))
+			return VM_FAULT_SIGBUS;
+		else if (unlikely(faulted_page == NOPAGE_OOM))
+			return VM_FAULT_OOM;
+	}
 
-	BUG_ON(vma->vm_flags & VM_CAN_INVALIDATE && !PageLocked(nopage_page));
 	/*
-	 * For consistency in subsequent calls, make the nopage_page always
+	 * For consistency in subsequent calls, make the faulted_page always
 	 * locked.
 	 */
 	if (unlikely(!(vma->vm_flags & VM_CAN_INVALIDATE)))
-		lock_page(nopage_page);
+		lock_page(faulted_page);
+	else
+		BUG_ON(!PageLocked(faulted_page));
 
 	/*
 	 * Should we do an early C-O-W break?
 	 */
-	page = nopage_page;
-	if (write_access) {
+	page = faulted_page;
+	if (flags & FAULT_FLAG_WRITE) {
 		if (!(vma->vm_flags & VM_SHARED)) {
+			anon = 1;
 			if (unlikely(anon_vma_prepare(vma))) {
-				ret = VM_FAULT_OOM;
-				goto out_error;
+				fdata.type = VM_FAULT_OOM;
+				goto out;
 			}
 			page = alloc_page_vma(GFP_HIGHUSER, vma, address);
 			if (!page) {
-				ret = VM_FAULT_OOM;
-				goto out_error;
+				fdata.type = VM_FAULT_OOM;
+				goto out;
 			}
-			copy_user_highpage(page, nopage_page, address, vma);
-			anon = 1;
+			copy_user_highpage(page, faulted_page, address, vma);
 		} else {
-			/* if the page will be shareable, see if the backing
+			/*
+			 * If the page will be shareable, see if the backing
 			 * address space wants to know that the page is about
-			 * to become writable */
+			 * to become writable
+			 */
 			if (vma->vm_ops->page_mkwrite &&
 			    vma->vm_ops->page_mkwrite(vma, page) < 0) {
-				ret = VM_FAULT_SIGBUS;
-				goto out_error;
+				fdata.type = VM_FAULT_SIGBUS;
+				anon = 1; /* no anon but release faulted_page */
+				goto out;
 			}
 		}
+
 	}
 
 	page_table = pte_offset_map_lock(mm, pmd, address, &ptl);
@@ -2366,10 +2385,10 @@ static int do_no_page(struct mm_struct *
 	 * handle that later.
 	 */
 	/* Only go through if we didn't race with anybody else... */
-	if (likely(pte_none(*page_table))) {
+	if (likely(pte_same(*page_table, orig_pte))) {
 		flush_icache_page(vma, page);
 		entry = mk_pte(page, vma->vm_page_prot);
-		if (write_access)
+		if (flags & FAULT_FLAG_WRITE)
 			entry = maybe_mkwrite(pte_mkdirty(entry), vma);
 		set_pte_at(mm, address, page_table, entry);
 		if (anon) {
@@ -2379,7 +2398,7 @@ static int do_no_page(struct mm_struct *
 		} else {
 			inc_mm_counter(mm, file_rss);
 			page_add_file_rmap(page);
-			if (write_access) {
+			if (flags & FAULT_FLAG_WRITE) {
 				dirty_page = page;
 				get_page(dirty_page);
 			}
@@ -2392,25 +2411,42 @@ static int do_no_page(struct mm_struct *
 		if (anon)
 			page_cache_release(page);
 		else
-			anon = 1; /* not anon, but release nopage_page */
+			anon = 1; /* no anon but release faulted_page */
 	}
 
 	pte_unmap_unlock(page_table, ptl);
 
 out:
-	unlock_page(nopage_page);
+	unlock_page(faulted_page);
 	if (anon)
-		page_cache_release(nopage_page);
+		page_cache_release(faulted_page);
 	else if (dirty_page) {
 		set_page_dirty_balance(dirty_page);
 		put_page(dirty_page);
 	}
 
-	return ret;
+	return fdata.type;
+}
 
-out_error:
-	anon = 1; /* relase nopage_page */
-	goto out;
+static int do_linear_fault(struct mm_struct *mm, struct vm_area_struct *vma,
+		unsigned long address, pte_t *page_table, pmd_t *pmd,
+		int write_access, pte_t orig_pte)
+{
+	pgoff_t pgoff = (((address & PAGE_MASK)
+			- vma->vm_start) >> PAGE_CACHE_SHIFT) + vma->vm_pgoff;
+	unsigned int flags = (write_access ? FAULT_FLAG_WRITE : 0);
+
+	return __do_fault(mm, vma, address, page_table, pmd, pgoff, flags, orig_pte);
+}
+
+static int do_nonlinear_fault(struct mm_struct *mm, struct vm_area_struct *vma,
+		unsigned long address, pte_t *page_table, pmd_t *pmd,
+		int write_access, pgoff_t pgoff, pte_t orig_pte)
+{
+	unsigned int flags = FAULT_FLAG_NONLINEAR |
+				(write_access ? FAULT_FLAG_WRITE : 0);
+
+	return __do_fault(mm, vma, address, page_table, pmd, pgoff, flags, orig_pte);
 }
 
 /*
@@ -2489,9 +2525,14 @@ static int do_file_page(struct mm_struct
 		print_bad_pte(vma, orig_pte, address);
 		return VM_FAULT_OOM;
 	}
-	/* We can then assume vm->vm_ops && vma->vm_ops->populate */
 
 	pgoff = pte_to_pgoff(orig_pte);
+
+	if (vma->vm_ops && vma->vm_ops->fault)
+		return do_nonlinear_fault(mm, vma, address, page_table, pmd,
+					write_access, pgoff, orig_pte);
+
+	/* We can then assume vm->vm_ops && vma->vm_ops->populate */
 	err = vma->vm_ops->populate(vma, address & PAGE_MASK, PAGE_SIZE,
 					vma->vm_page_prot, pgoff, 0);
 	if (err == -ENOMEM)
@@ -2526,10 +2567,9 @@ static inline int handle_pte_fault(struc
 	if (!pte_present(entry)) {
 		if (pte_none(entry)) {
 			if (vma->vm_ops) {
-				if (vma->vm_ops->nopage)
-					return do_no_page(mm, vma, address,
-							  pte, pmd,
-							  write_access);
+				if (vma->vm_ops->fault || vma->vm_ops->nopage)
+					return do_linear_fault(mm, vma, address,
+						pte, pmd, write_access, entry);
 				if (unlikely(vma->vm_ops->nopfn))
 					return do_no_pfn(mm, vma, address, pte,
 							 pmd, write_access);
diff -puN mm/mmap.c~mm-merge-populate-and-nopage-into-fault-fixes-nonlinear mm/mmap.c
--- a/mm/mmap.c~mm-merge-populate-and-nopage-into-fault-fixes-nonlinear
+++ a/mm/mmap.c
@@ -1150,12 +1150,8 @@ out:	
 		mm->locked_vm += len >> PAGE_SHIFT;
 		make_pages_present(addr, addr + len);
 	}
-	if (flags & MAP_POPULATE) {
-		up_write(&mm->mmap_sem);
-		sys_remap_file_pages(addr, len, 0,
-					pgoff, flags & MAP_NONBLOCK);
-		down_write(&mm->mmap_sem);
-	}
+	if ((flags & MAP_POPULATE) && !(flags & MAP_NONBLOCK))
+		make_pages_present(addr, addr + len);
 	return addr;
 
 unmap_and_free_vma:
diff -puN mm/nommu.c~mm-merge-populate-and-nopage-into-fault-fixes-nonlinear mm/nommu.c
--- a/mm/nommu.c~mm-merge-populate-and-nopage-into-fault-fixes-nonlinear
+++ a/mm/nommu.c
@@ -1336,8 +1336,7 @@ int in_gate_area_no_task(unsigned long a
 	return 0;
 }
 
-struct page *filemap_nopage(struct vm_area_struct *area,
-			unsigned long address, int *type)
+struct page *filemap_fault(struct vm_area_struct *vma, struct fault_data *fdata)
 {
 	BUG();
 	return NULL;
diff -puN mm/rmap.c~mm-merge-populate-and-nopage-into-fault-fixes-nonlinear mm/rmap.c
--- a/mm/rmap.c~mm-merge-populate-and-nopage-into-fault-fixes-nonlinear
+++ a/mm/rmap.c
@@ -643,8 +643,10 @@ void page_remove_rmap(struct page *page,
 			printk (KERN_EMERG "  page->count = %x\n", page_count(page));
 			printk (KERN_EMERG "  page->mapping = %p\n", page->mapping);
 			print_symbol (KERN_EMERG "  vma->vm_ops = %s\n", (unsigned long)vma->vm_ops);
-			if (vma->vm_ops)
+			if (vma->vm_ops) {
 				print_symbol (KERN_EMERG "  vma->vm_ops->nopage = %s\n", (unsigned long)vma->vm_ops->nopage);
+				print_symbol (KERN_EMERG "  vma->vm_ops->fault = %s\n", (unsigned long)vma->vm_ops->fault);
+			}
 			if (vma->vm_file && vma->vm_file->f_op)
 				print_symbol (KERN_EMERG "  vma->vm_file->f_op->mmap = %s\n", (unsigned long)vma->vm_file->f_op->mmap);
 			BUG();
diff -puN mm/shmem.c~mm-merge-populate-and-nopage-into-fault-fixes-nonlinear mm/shmem.c
--- a/mm/shmem.c~mm-merge-populate-and-nopage-into-fault-fixes-nonlinear
+++ a/mm/shmem.c
@@ -82,7 +82,7 @@ enum sgp_type {
 	SGP_READ,	/* don't exceed i_size, don't allocate page */
 	SGP_CACHE,	/* don't exceed i_size, may allocate page */
 	SGP_WRITE,	/* may exceed i_size, may allocate page */
-	SGP_NOPAGE,	/* same as SGP_CACHE, return with page locked */
+	SGP_FAULT,	/* same as SGP_CACHE, return with page locked */
 };
 
 static int shmem_getpage(struct inode *inode, unsigned long idx,
@@ -1095,6 +1095,10 @@ static int shmem_getpage(struct inode *i
 
 	if (idx >= SHMEM_MAX_INDEX)
 		return -EFBIG;
+
+	if (type)
+		*type = VM_FAULT_MINOR;
+
 	/*
 	 * Normally, filepage is NULL on entry, and either found
 	 * uptodate immediately, or allocated and zeroed, or read
@@ -1285,7 +1289,7 @@ repeat:
 done:
 	if (*pagep != filepage) {
 		*pagep = filepage;
-		if (sgp != SGP_NOPAGE)
+		if (sgp != SGP_FAULT)
 			unlock_page(filepage);
 
 	}
@@ -1299,76 +1303,31 @@ failed:
 	return error;
 }
 
-static struct page *shmem_nopage(struct vm_area_struct *vma,
-				 unsigned long address, int *type)
+static struct page *shmem_fault(struct vm_area_struct *vma,
+					struct fault_data *fdata)
 {
 	struct inode *inode = vma->vm_file->f_path.dentry->d_inode;
 	struct page *page = NULL;
-	unsigned long idx;
 	int error;
 
 	BUG_ON(!(vma->vm_flags & VM_CAN_INVALIDATE));
 
-	idx = (address - vma->vm_start) >> PAGE_SHIFT;
-	idx += vma->vm_pgoff;
-	idx >>= PAGE_CACHE_SHIFT - PAGE_SHIFT;
-	if (((loff_t) idx << PAGE_CACHE_SHIFT) >= i_size_read(inode))
-		return NOPAGE_SIGBUS;
+	if (((loff_t)fdata->pgoff << PAGE_CACHE_SHIFT) >= i_size_read(inode)) {
+		fdata->type = VM_FAULT_SIGBUS;
+		return NULL;
+	}
 
-	error = shmem_getpage(inode, idx, &page, SGP_NOPAGE, type);
-	if (error)
-		return (error == -ENOMEM)? NOPAGE_OOM: NOPAGE_SIGBUS;
+	error = shmem_getpage(inode, fdata->pgoff, &page,
+						SGP_FAULT, &fdata->type);
+	if (error) {
+		fdata->type = ((error == -ENOMEM)?VM_FAULT_OOM:VM_FAULT_SIGBUS);
+		return NULL;
+	}
 
 	mark_page_accessed(page);
 	return page;
 }
 
-static int shmem_populate(struct vm_area_struct *vma,
-	unsigned long addr, unsigned long len,
-	pgprot_t prot, unsigned long pgoff, int nonblock)
-{
-	struct inode *inode = vma->vm_file->f_path.dentry->d_inode;
-	struct mm_struct *mm = vma->vm_mm;
-	enum sgp_type sgp = nonblock? SGP_QUICK: SGP_CACHE;
-	unsigned long size;
-
-	size = (i_size_read(inode) + PAGE_SIZE - 1) >> PAGE_SHIFT;
-	if (pgoff >= size || pgoff + (len >> PAGE_SHIFT) > size)
-		return -EINVAL;
-
-	while ((long) len > 0) {
-		struct page *page = NULL;
-		int err;
-		/*
-		 * Will need changing if PAGE_CACHE_SIZE != PAGE_SIZE
-		 */
-		err = shmem_getpage(inode, pgoff, &page, sgp, NULL);
-		if (err)
-			return err;
-		/* Page may still be null, but only if nonblock was set. */
-		if (page) {
-			mark_page_accessed(page);
-			err = install_page(mm, vma, addr, page, prot);
-			if (err) {
-				page_cache_release(page);
-				return err;
-			}
-		} else if (vma->vm_flags & VM_NONLINEAR) {
-			/* No page was found just because we can't read it in
-			 * now (being here implies nonblock != 0), but the page
-			 * may exist, so set the PTE to fault it in later. */
-    			err = install_file_pte(mm, vma, addr, pgoff, prot);
-			if (err)
-	    			return err;
-		}
-
-		len -= PAGE_SIZE;
-		addr += PAGE_SIZE;
-		pgoff++;
-	}
-	return 0;
-}
-
 #ifdef CONFIG_NUMA
 int shmem_set_policy(struct vm_area_struct *vma, struct mempolicy *new)
 {
@@ -1413,7 +1372,7 @@ static int shmem_mmap(struct file *file,
 {
 	file_accessed(file);
 	vma->vm_ops = &shmem_vm_ops;
-	vma->vm_flags |= VM_CAN_INVALIDATE;
+	vma->vm_flags |= VM_CAN_INVALIDATE | VM_CAN_NONLINEAR;
 	return 0;
 }
 
@@ -2467,8 +2426,7 @@ static const struct super_operations shm
 };
 
 static struct vm_operations_struct shmem_vm_ops = {
-	.nopage		= shmem_nopage,
-	.populate	= shmem_populate,
+	.fault		= shmem_fault,
 #ifdef CONFIG_NUMA
 	.set_policy     = shmem_set_policy,
 	.get_policy     = shmem_get_policy,
diff -puN mm/truncate.c~mm-merge-populate-and-nopage-into-fault-fixes-nonlinear mm/truncate.c
--- a/mm/truncate.c~mm-merge-populate-and-nopage-into-fault-fixes-nonlinear
+++ a/mm/truncate.c
@@ -82,7 +82,7 @@ EXPORT_SYMBOL(cancel_dirty_page);
 /*
  * If truncate cannot remove the fs-private metadata from the page, the page
  * becomes anonymous.  It will be left on the LRU and may even be mapped into
- * user pagetables if we're racing with filemap_nopage().
+ * user pagetables if we're racing with filemap_fault().
  *
  * We need to bale out if page->mapping is no longer equal to the original
  * mapping.  This happens a) when the VM reclaimed the page while we waited on
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
