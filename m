Date: Wed, 11 Jul 2007 13:51:25 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 1/2] mm: fault feedback 1
Message-ID: <20070711115125.GB18204@wotan.suse.de>
References: <20070711115004.GA18204@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070711115004.GA18204@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, Jul 11, 2007 at 01:50:04PM +0200, Nick Piggin wrote:
> Feedback from Linus. Not really sure what to name this patch, but I
> guess it can just be a fix for, and merged into the patch that introducdes
> ->fault() (otoh I had prefered to stay back compatible and remove the
> old APIs incrementally, but nobody seems to want this anyway).
> 
> I have your series file now looking like this:
> 
> mm-fix-fault-vs-invalidate-race-for-linear-mappings.patch
> mm-fix-fault-vs-invalidate-race-for-linear-mappings-fix.patch
> mm-merge-populate-and-nopage-into-fault-fixes-nonlinear.patch
> mm-merge-populate-and-nopage-into-fault-fixes-nonlinear-fix.patch
> ocfs2-release-page-lock-before-calling-page_mkwrite.patch
> document-page_mkwrite-locking.patch
> mm-fault-feedback.patch
> mm-fault-feedback2.patch
> #mm-merge-nopfn-into-fault.patch
> #mm-merge-nopfn-into-fault-spufs-fix.patch
> #convert-hugetlbfs-to-use-vm_ops-fault.patch
> #mm-remove-legacy-cruft.patch
> mm-debug-check-for-the-fault-vs-invalidate-race.patch
> mm-fix-clear_page_dirty_for_io-vs-fault-race.patch
> 
> So if you take these next two patches, please drop the nopfn stuff
> (that seems to be getting too far ahead of ourselves ATM), and the next
> two patches got obsolted by these.
> 
> readahead-convert-filemap-invocations.patch
> readahead-split-ondemand-readahead-interface-into-two-functions.patch
> 
> Both the above get rejects and need a `%s/fdata/vmf/g`.

Bah, forgot to cc linux-mm.
--

Change ->fault prototype. We now return an int, which contains VM_FAULT_xxx
code in the low byte, and FAULT_RET_xxx code in the next byte. FAULT_RET_
code tells the VM whether a page was found, whether it has been locked, and
potentially other things. This is not quite the way he wanted it yet, but
that's changed in the next patch (which requires changes to arch code).

This means we no longer set VM_CAN_INVALIDATE in the vma in order to say
that a page is locked which requires filemap_nopage to go away (because we
can no longer remain backward compatible without that flag), but we were
going to do that anyway.

struct fault_data is renamed to struct vm_fault as Linus asked. address
is now a void __user * that we should firmly encourage drivers not to use
without really good reason.

The page is now returned via a page pointer in the vm_fault struct.

Signed-off-by: Nick Piggin <npiggin@suse.de>

---
 Documentation/feature-removal-schedule.txt |   20 --
 fs/gfs2/ops_file.c                         |    2 
 fs/gfs2/ops_vm.c                           |   47 ++--
 fs/ncpfs/mmap.c                            |   35 +--
 fs/ocfs2/mmap.c                            |   27 +-
 fs/xfs/linux-2.6/xfs_file.c                |   12 -
 include/linux/mm.h                         |   82 ++++----
 ipc/shm.c                                  |    5 
 mm/filemap.c                               |  283 ++++-------------------------
 mm/filemap_xip.c                           |   37 +--
 mm/memory.c                                |   97 ++++-----
 mm/nommu.c                                 |    2 
 mm/shmem.c                                 |   29 +-
 13 files changed, 214 insertions(+), 464 deletions(-)

Index: linux-2.6/fs/gfs2/ops_vm.c
===================================================================
--- linux-2.6.orig/fs/gfs2/ops_vm.c
+++ linux-2.6/fs/gfs2/ops_vm.c
@@ -27,13 +27,12 @@
 #include "trans.h"
 #include "util.h"
 
-static struct page *gfs2_private_fault(struct vm_area_struct *vma,
-					struct fault_data *fdata)
+static int gfs2_private_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 {
 	struct gfs2_inode *ip = GFS2_I(vma->vm_file->f_mapping->host);
 
 	set_bit(GIF_PAGED, &ip->i_flags);
-	return filemap_fault(vma, fdata);
+	return filemap_fault(vma, vmf);
 }
 
 static int alloc_page_backing(struct gfs2_inode *ip, struct page *page)
@@ -104,55 +103,55 @@ out:
 	return error;
 }
 
-static struct page *gfs2_sharewrite_fault(struct vm_area_struct *vma,
-						struct fault_data *fdata)
+static int gfs2_sharewrite_fault(struct vm_area_struct *vma,
+						struct vm_fault *vmf)
 {
 	struct file *file = vma->vm_file;
 	struct gfs2_file *gf = file->private_data;
 	struct gfs2_inode *ip = GFS2_I(file->f_mapping->host);
 	struct gfs2_holder i_gh;
-	struct page *result = NULL;
 	int alloc_required;
 	int error;
+	int ret = VM_FAULT_MINOR;
 
 	error = gfs2_glock_nq_init(ip->i_gl, LM_ST_EXCLUSIVE, 0, &i_gh);
 	if (error)
-		return NULL;
+		goto out;
 
 	set_bit(GIF_PAGED, &ip->i_flags);
 	set_bit(GIF_SW_PAGED, &ip->i_flags);
 
 	error = gfs2_write_alloc_required(ip,
-					(u64)fdata->pgoff << PAGE_CACHE_SHIFT,
+					(u64)vmf->pgoff << PAGE_CACHE_SHIFT,
 					PAGE_CACHE_SIZE, &alloc_required);
 	if (error) {
-		fdata->type = VM_FAULT_OOM; /* XXX: are these right? */
-		goto out;
+		ret = VM_FAULT_OOM; /* XXX: are these right? */
+		goto out_unlock;
 	}
 
 	set_bit(GFF_EXLOCK, &gf->f_flags);
-	result = filemap_fault(vma, fdata);
+	ret = filemap_fault(vma, vmf);
 	clear_bit(GFF_EXLOCK, &gf->f_flags);
-	if (!result)
-		goto out;
+	if (ret & (VM_FAULT_ERROR | FAULT_RET_NOPAGE))
+		goto out_unlock;
 
 	if (alloc_required) {
-		error = alloc_page_backing(ip, result);
+		/* XXX: do we need to drop page lock around alloc_page_backing?*/
+		error = alloc_page_backing(ip, vmf->page);
 		if (error) {
-			if (vma->vm_flags & VM_CAN_INVALIDATE)
-				unlock_page(result);
-			page_cache_release(result);
-			fdata->type = VM_FAULT_OOM;
-			result = NULL;
-			goto out;
+			if (ret & FAULT_RET_LOCKED)
+				unlock_page(vmf->page);
+			page_cache_release(vmf->page);
+			ret = VM_FAULT_OOM;
+			goto out_unlock;
 		}
-		set_page_dirty(result);
+		set_page_dirty(vmf->page);
 	}
 
-out:
+out_unlock:
 	gfs2_glock_dq_uninit(&i_gh);
-
-	return result;
+out:
+	return ret;
 }
 
 struct vm_operations_struct gfs2_vm_ops_private = {
Index: linux-2.6/fs/ncpfs/mmap.c
===================================================================
--- linux-2.6.orig/fs/ncpfs/mmap.c
+++ linux-2.6/fs/ncpfs/mmap.c
@@ -24,33 +24,35 @@
 
 /*
  * Fill in the supplied page for mmap
+ * XXX: how are we excluding truncate/invalidate here? Maybe need to lock
+ * page?
  */
-static struct page* ncp_file_mmap_fault(struct vm_area_struct *area,
-						struct fault_data *fdata)
+static int ncp_file_mmap_fault(struct vm_area_struct *area,
+					struct vm_fault *vmf)
 {
 	struct file *file = area->vm_file;
 	struct dentry *dentry = file->f_path.dentry;
 	struct inode *inode = dentry->d_inode;
-	struct page* page;
 	char *pg_addr;
 	unsigned int already_read;
 	unsigned int count;
 	int bufsize;
-	int pos;
+	int pos; /* XXX: loff_t ? */
 
-	page = alloc_page(GFP_HIGHUSER); /* ncpfs has nothing against high pages
-	           as long as recvmsg and memset works on it */
-	if (!page) {
-		fdata->type = VM_FAULT_OOM;
-		return NULL;
-	}
-	pg_addr = kmap(page);
-	pos = fdata->pgoff << PAGE_SHIFT;
+	/*
+	 * ncpfs has nothing against high pages as long
+	 * as recvmsg and memset works on it
+	 */
+	vmf->page = alloc_page(GFP_HIGHUSER);
+	if (!vmf->page)
+		return VM_FAULT_OOM;
+	pg_addr = kmap(vmf->page);
+	pos = vmf->pgoff << PAGE_SHIFT;
 
 	count = PAGE_SIZE;
-	if (fdata->address + PAGE_SIZE > area->vm_end) {
+	if ((unsigned long)vmf->virtual_address + PAGE_SIZE > area->vm_end) {
 		WARN_ON(1); /* shouldn't happen? */
-		count = area->vm_end - fdata->address;
+		count = area->vm_end - (unsigned long)vmf->virtual_address;
 	}
 	/* what we can read in one go */
 	bufsize = NCP_SERVER(inode)->buffer_size;
@@ -85,17 +87,16 @@ static struct page* ncp_file_mmap_fault(
 
 	if (already_read < PAGE_SIZE)
 		memset(pg_addr + already_read, 0, PAGE_SIZE - already_read);
-	flush_dcache_page(page);
-	kunmap(page);
+	flush_dcache_page(vmf->page);
+	kunmap(vmf->page);
 
 	/*
 	 * If I understand ncp_read_kernel() properly, the above always
 	 * fetches from the network, here the analogue of disk.
 	 * -- wli
 	 */
-	fdata->type = VM_FAULT_MAJOR;
 	count_vm_event(PGMAJFAULT);
-	return page;
+	return VM_FAULT_MAJOR;
 }
 
 static struct vm_operations_struct ncp_file_mmap =
@@ -124,7 +125,6 @@ int ncp_mmap(struct file *file, struct v
 		return -EFBIG;
 
 	vma->vm_ops = &ncp_file_mmap;
-	vma->vm_flags |= VM_CAN_INVALIDATE;
 	file_accessed(file);
 	return 0;
 }
Index: linux-2.6/fs/ocfs2/mmap.c
===================================================================
--- linux-2.6.orig/fs/ocfs2/mmap.c
+++ linux-2.6/fs/ocfs2/mmap.c
@@ -60,30 +60,28 @@ static inline int ocfs2_vm_op_unblock_si
 	return sigprocmask(SIG_SETMASK, oldset, NULL);
 }
 
-static struct page *ocfs2_fault(struct vm_area_struct *area,
-						struct fault_data *fdata)
+static int ocfs2_fault(struct vm_area_struct *area, struct vm_fault *vmf)
 {
-	struct page *page = NULL;
 	sigset_t blocked, oldset;
-	int ret;
+	int error, ret;
 
-	mlog_entry("(area=%p, page offset=%lu)\n", area, fdata->pgoff);
+	mlog_entry("(area=%p, page offset=%lu)\n", area, vmf->pgoff);
 
-	ret = ocfs2_vm_op_block_sigs(&blocked, &oldset);
-	if (ret < 0) {
-		fdata->type = VM_FAULT_SIGBUS;
-		mlog_errno(ret);
+	error = ocfs2_vm_op_block_sigs(&blocked, &oldset);
+	if (error < 0) {
+		mlog_errno(error);
+		ret = VM_FAULT_SIGBUS;
 		goto out;
 	}
 
-	page = filemap_fault(area, fdata);
+	ret = filemap_fault(area, vmf);
 
-	ret = ocfs2_vm_op_unblock_sigs(&oldset);
-	if (ret < 0)
-		mlog_errno(ret);
+	error = ocfs2_vm_op_unblock_sigs(&oldset);
+	if (error < 0)
+		mlog_errno(error);
 out:
-	mlog_exit_ptr(page);
-	return page;
+	mlog_exit_ptr(vmf->page);
+	return ret;
 }
 
 static int __ocfs2_page_mkwrite(struct inode *inode, struct buffer_head *di_bh,
@@ -225,7 +223,7 @@ int ocfs2_mmap(struct file *file, struct
 	ocfs2_meta_unlock(file->f_dentry->d_inode, lock_level);
 out:
 	vma->vm_ops = &ocfs2_file_vm_ops;
-	vma->vm_flags |= VM_CAN_INVALIDATE | VM_CAN_NONLINEAR;
+	vma->vm_flags |= VM_CAN_NONLINEAR;
 	return 0;
 }
 
Index: linux-2.6/fs/xfs/linux-2.6/xfs_file.c
===================================================================
--- linux-2.6.orig/fs/xfs/linux-2.6/xfs_file.c
+++ linux-2.6/fs/xfs/linux-2.6/xfs_file.c
@@ -245,20 +245,18 @@ xfs_file_fsync(
 }
 
 #ifdef CONFIG_XFS_DMAPI
-STATIC struct page *
+STATIC int
 xfs_vm_fault(
 	struct vm_area_struct	*vma,
-	struct fault_data	*fdata)
+	struct vm_fault	*vmf)
 {
 	struct inode	*inode = vma->vm_file->f_path.dentry->d_inode;
 	bhv_vnode_t	*vp = vn_from_inode(inode);
 
 	ASSERT_ALWAYS(vp->v_vfsp->vfs_flag & VFS_DMI);
-	if (XFS_SEND_MMAP(XFS_VFSTOM(vp->v_vfsp), vma, 0)) {
-		fdata->type = VM_FAULT_SIGBUS;
-		return NULL;
-	}
-	return filemap_fault(vma, fdata);
+	if (XFS_SEND_MMAP(XFS_VFSTOM(vp->v_vfsp), vma, 0))
+		return VM_FAULT_SIGBUS;
+	return filemap_fault(vma, vmf);
 }
 #endif /* CONFIG_XFS_DMAPI */
 
@@ -344,7 +342,7 @@ xfs_file_mmap(
 	struct vm_area_struct *vma)
 {
 	vma->vm_ops = &xfs_file_vm_ops;
-	vma->vm_flags |= VM_CAN_INVALIDATE | VM_CAN_NONLINEAR;
+	vma->vm_flags |= VM_CAN_NONLINEAR;
 
 #ifdef CONFIG_XFS_DMAPI
 	if (vn_from_inode(filp->f_path.dentry->d_inode)->v_vfsp->vfs_flag & VFS_DMI)
Index: linux-2.6/include/linux/mm.h
===================================================================
--- linux-2.6.orig/include/linux/mm.h
+++ linux-2.6/include/linux/mm.h
@@ -170,12 +170,7 @@ extern unsigned int kobjsize(const void 
 #define VM_INSERTPAGE	0x02000000	/* The vma has had "vm_insert_page()" done on it */
 #define VM_ALWAYSDUMP	0x04000000	/* Always include in core dumps */
 
-#define VM_CAN_INVALIDATE 0x08000000	/* The mapping may be invalidated,
-					 * eg. truncate or invalidate_inode_*.
-					 * In this case, do_no_page must
-					 * return with the page locked.
-					 */
-#define VM_CAN_NONLINEAR 0x10000000	/* Has ->fault & does nonlinear pages */
+#define VM_CAN_NONLINEAR 0x08000000	/* Has ->fault & does nonlinear pages */
 
 #ifndef VM_STACK_DEFAULT_FLAGS		/* arch can override this */
 #define VM_STACK_DEFAULT_FLAGS VM_DATA_DEFAULT_FLAGS
@@ -199,24 +194,44 @@ extern unsigned int kobjsize(const void 
  */
 extern pgprot_t protection_map[16];
 
-#define FAULT_FLAG_WRITE	0x01
-#define FAULT_FLAG_NONLINEAR	0x02
+#define FAULT_FLAG_WRITE	0x01	/* Fault was a write access */
+#define FAULT_FLAG_NONLINEAR	0x02	/* Fault was via a nonlinear mapping */
+
+
+#define FAULT_RET_NOPAGE	0x0100	/* ->fault did not return a page. This
+					 * can be used if the handler installs
+					 * their own pte.
+					 */
+#define FAULT_RET_LOCKED	0x0200	/* ->fault locked the page, caller must
+					 * unlock after installing the mapping.
+					 * This is used by pagecache in
+					 * particular, where the page lock is
+					 * used to synchronise against truncate
+					 * and invalidate. Mutually exclusive
+					 * with FAULT_RET_NOPAGE.
+					 */
 
 /*
- * fault_data is filled in the the pagefault handler and passed to the
- * vma's ->fault function. That function is responsible for filling in
- * 'type', which is the type of fault if a page is returned, or the type
- * of error if NULL is returned.
- *
- * pgoff should be used in favour of address, if possible. If pgoff is
- * used, one may set VM_CAN_NONLINEAR in the vma->vm_flags to get
- * nonlinear mapping support.
- */
-struct fault_data {
-	unsigned long address;
-	pgoff_t pgoff;
-	unsigned int flags;
-	int type;
+ * vm_fault is filled by the the pagefault handler and passed to the vma's
+ * ->fault function. The vma's ->fault is responsible for returning the
+ * VM_FAULT_xxx type which occupies the lowest byte of the return code, ORed
+ * with FAULT_RET_ flags that occupy the next byte and give details about
+ * how the fault was handled.
+ *
+ * pgoff should be used in favour of virtual_address, if possible. If pgoff
+ * is used, one may set VM_CAN_NONLINEAR in the vma->vm_flags to get nonlinear
+ * mapping support.
+ */
+struct vm_fault {
+	unsigned int flags;		/* FAULT_FLAG_xxx flags */
+	pgoff_t pgoff;			/* Logical page offset based on vma */
+	void __user *virtual_address;	/* Faulting virtual address */
+
+	struct page *page;		/* ->fault handlers should return a
+					 * page here, unless FAULT_RET_NOPAGE
+					 * is set (which is also implied by
+					 * VM_FAULT_OOM or SIGBUS).
+					 */
 };
 
 /*
@@ -227,15 +242,11 @@ struct fault_data {
 struct vm_operations_struct {
 	void (*open)(struct vm_area_struct * area);
 	void (*close)(struct vm_area_struct * area);
-	struct page *(*fault)(struct vm_area_struct *vma,
-			struct fault_data *fdata);
+	int (*fault)(struct vm_area_struct *vma, struct vm_fault *vmf);
 	struct page *(*nopage)(struct vm_area_struct *area,
 			unsigned long address, int *type);
 	unsigned long (*nopfn)(struct vm_area_struct *area,
 			unsigned long address);
-	int (*populate)(struct vm_area_struct *area, unsigned long address,
-			unsigned long len, pgprot_t prot, unsigned long pgoff,
-			int nonblock);
 
 	/* notification that a previously read-only page is about to become
 	 * writable, if an error is returned it will cause a SIGBUS */
@@ -701,8 +712,14 @@ static inline int page_mapped(struct pag
  * Used to decide whether a process gets delivered SIGBUS or
  * just gets major/minor fault counters bumped up.
  */
-#define VM_FAULT_OOM	0x00
-#define VM_FAULT_SIGBUS	0x01
+
+/*
+ * VM_FAULT_ERROR is set for the error cases, to make some tests simpler.
+ */
+#define VM_FAULT_ERROR	0x20
+
+#define VM_FAULT_OOM	(0x00 | VM_FAULT_ERROR)
+#define VM_FAULT_SIGBUS	(0x01 | VM_FAULT_ERROR)
 #define VM_FAULT_MINOR	0x02
 #define VM_FAULT_MAJOR	0x03
 
@@ -712,6 +729,11 @@ static inline int page_mapped(struct pag
  */
 #define VM_FAULT_WRITE	0x10
 
+/*
+ * Mask of VM_FAULT_ flags
+ */
+#define VM_FAULT_MASK	0xff
+
 #define offset_in_page(p)	((unsigned long)(p) & ~PAGE_MASK)
 
 extern void show_free_areas(void);
@@ -794,8 +816,6 @@ static inline void unmap_shared_mapping_
 
 extern int vmtruncate(struct inode * inode, loff_t offset);
 extern int vmtruncate_range(struct inode * inode, loff_t offset, loff_t end);
-extern int install_page(struct mm_struct *mm, struct vm_area_struct *vma, unsigned long addr, struct page *page, pgprot_t prot);
-extern int install_file_pte(struct mm_struct *mm, struct vm_area_struct *vma, unsigned long addr, unsigned long pgoff, pgprot_t prot);
 
 #ifdef CONFIG_MMU
 extern int __handle_mm_fault(struct mm_struct *mm,struct vm_area_struct *vma,
@@ -1128,11 +1148,7 @@ extern void truncate_inode_pages_range(s
 				       loff_t lstart, loff_t lend);
 
 /* generic vm_area_ops exported for stackable file systems */
-extern struct page *filemap_fault(struct vm_area_struct *, struct fault_data *);
-extern struct page * __deprecated_for_modules
-filemap_nopage(struct vm_area_struct *, unsigned long, int *);
-extern int __deprecated_for_modules filemap_populate(struct vm_area_struct *,
-		unsigned long, unsigned long, pgprot_t, unsigned long, int);
+extern int filemap_fault(struct vm_area_struct *, struct vm_fault *);
 
 /* mm/page-writeback.c */
 int write_one_page(struct page *page, int wait);
Index: linux-2.6/ipc/shm.c
===================================================================
--- linux-2.6.orig/ipc/shm.c
+++ linux-2.6/ipc/shm.c
@@ -226,13 +226,12 @@ static void shm_close(struct vm_area_str
 	mutex_unlock(&shm_ids(ns).mutex);
 }
 
-static struct page *shm_fault(struct vm_area_struct *vma,
-					struct fault_data *fdata)
+static int shm_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 {
 	struct file *file = vma->vm_file;
 	struct shm_file_data *sfd = shm_file_data(file);
 
-	return sfd->vm_ops->fault(vma, fdata);
+	return sfd->vm_ops->fault(vma, vmf);
 }
 
 #ifdef CONFIG_NUMA
Index: linux-2.6/mm/filemap.c
===================================================================
--- linux-2.6.orig/mm/filemap.c
+++ linux-2.6/mm/filemap.c
@@ -1335,8 +1335,8 @@ static int fastcall page_cache_read(stru
 
 /**
  * filemap_fault - read in file data for page fault handling
- * @vma:	user vma (not used)
- * @fdata:	the applicable fault_data
+ * @vma:	vma in which the fault was taken
+ * @vmf:	struct vm_fault containing details of the fault
  *
  * filemap_fault() is invoked via the vma operations vector for a
  * mapped memory region to read in file data during a page fault.
@@ -1345,7 +1345,7 @@ static int fastcall page_cache_read(stru
  * it in the page cache, and handles the special cases reasonably without
  * having a lot of duplicated code.
  */
-struct page *filemap_fault(struct vm_area_struct *vma, struct fault_data *fdata)
+int filemap_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 {
 	int error;
 	struct file *file = vma->vm_file;
@@ -1355,13 +1355,12 @@ struct page *filemap_fault(struct vm_are
 	struct page *page;
 	unsigned long size;
 	int did_readaround = 0;
+	int ret;
 
-	fdata->type = VM_FAULT_MINOR;
-
-	BUG_ON(!(vma->vm_flags & VM_CAN_INVALIDATE));
+	ret = VM_FAULT_MINOR;
 
 	size = (i_size_read(inode) + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
-	if (fdata->pgoff >= size)
+	if (vmf->pgoff >= size)
 		goto outside_data_content;
 
 	/* If we don't want any read-ahead, don't bother */
@@ -1375,18 +1374,18 @@ struct page *filemap_fault(struct vm_are
 	 * For sequential accesses, we use the generic readahead logic.
 	 */
 	if (VM_SequentialReadHint(vma))
-		page_cache_readahead(mapping, ra, file, fdata->pgoff, 1);
+		page_cache_readahead(mapping, ra, file, vmf->pgoff, 1);
 
 	/*
 	 * Do we have something in the page cache already?
 	 */
 retry_find:
-	page = find_lock_page(mapping, fdata->pgoff);
+	page = find_lock_page(mapping, vmf->pgoff);
 	if (!page) {
 		unsigned long ra_pages;
 
 		if (VM_SequentialReadHint(vma)) {
-			handle_ra_miss(mapping, ra, fdata->pgoff);
+			handle_ra_miss(mapping, ra, vmf->pgoff);
 			goto no_cached_page;
 		}
 		ra->mmap_miss++;
@@ -1403,7 +1402,7 @@ retry_find:
 		 * check did_readaround, as this is an inner loop.
 		 */
 		if (!did_readaround) {
-			fdata->type = VM_FAULT_MAJOR;
+			ret = VM_FAULT_MAJOR;
 			count_vm_event(PGMAJFAULT);
 		}
 		did_readaround = 1;
@@ -1411,11 +1410,11 @@ retry_find:
 		if (ra_pages) {
 			pgoff_t start = 0;
 
-			if (fdata->pgoff > ra_pages / 2)
-				start = fdata->pgoff - ra_pages / 2;
+			if (vmf->pgoff > ra_pages / 2)
+				start = vmf->pgoff - ra_pages / 2;
 			do_page_cache_readahead(mapping, file, start, ra_pages);
 		}
-		page = find_lock_page(mapping, fdata->pgoff);
+		page = find_lock_page(mapping, vmf->pgoff);
 		if (!page)
 			goto no_cached_page;
 	}
@@ -1432,7 +1431,7 @@ retry_find:
 
 	/* Must recheck i_size under page lock */
 	size = (i_size_read(inode) + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
-	if (unlikely(fdata->pgoff >= size)) {
+	if (unlikely(vmf->pgoff >= size)) {
 		unlock_page(page);
 		goto outside_data_content;
 	}
@@ -1441,24 +1440,24 @@ retry_find:
 	 * Found the page and have a reference on it.
 	 */
 	mark_page_accessed(page);
-	return page;
+	vmf->page = page;
+	return ret | FAULT_RET_LOCKED;
 
 outside_data_content:
 	/*
 	 * An external ptracer can access pages that normally aren't
 	 * accessible..
 	 */
-	if (vma->vm_mm == current->mm) {
-		fdata->type = VM_FAULT_SIGBUS;
-		return NULL;
-	}
+	if (vma->vm_mm == current->mm)
+		return VM_FAULT_SIGBUS;
+
 	/* Fall through to the non-read-ahead case */
 no_cached_page:
 	/*
 	 * We're only likely to ever get here if MADV_RANDOM is in
 	 * effect.
 	 */
-	error = page_cache_read(file, fdata->pgoff);
+	error = page_cache_read(file, vmf->pgoff);
 
 	/*
 	 * The page we want has now been added to the page cache.
@@ -1474,15 +1473,13 @@ no_cached_page:
 	 * to schedule I/O.
 	 */
 	if (error == -ENOMEM)
-		fdata->type = VM_FAULT_OOM;
-	else
-		fdata->type = VM_FAULT_SIGBUS;
-	return NULL;
+		return VM_FAULT_OOM;
+	return VM_FAULT_SIGBUS;
 
 page_not_uptodate:
 	/* IO error path */
 	if (!did_readaround) {
-		fdata->type = VM_FAULT_MAJOR;
+		ret = VM_FAULT_MAJOR;
 		count_vm_event(PGMAJFAULT);
 	}
 
@@ -1501,206 +1498,10 @@ page_not_uptodate:
 
 	/* Things didn't work out. Return zero to tell the mm layer so. */
 	shrink_readahead_size_eio(file, ra);
-	fdata->type = VM_FAULT_SIGBUS;
-	return NULL;
+	return VM_FAULT_SIGBUS;
 }
 EXPORT_SYMBOL(filemap_fault);
 
-/*
- * filemap_nopage and filemap_populate are legacy exports that are not used
- * in tree. Scheduled for removal.
- */
-struct page *filemap_nopage(struct vm_area_struct *area,
-				unsigned long address, int *type)
-{
-	struct page *page;
-	struct fault_data fdata;
-	fdata.address = address;
-	fdata.pgoff = ((address - area->vm_start) >> PAGE_CACHE_SHIFT)
-			+ area->vm_pgoff;
-	fdata.flags = 0;
-
-	page = filemap_fault(area, &fdata);
-	if (type)
-		*type = fdata.type;
-
-	return page;
-}
-EXPORT_SYMBOL(filemap_nopage);
-
-static struct page * filemap_getpage(struct file *file, unsigned long pgoff,
-					int nonblock)
-{
-	struct address_space *mapping = file->f_mapping;
-	struct page *page;
-	int error;
-
-	/*
-	 * Do we have something in the page cache already?
-	 */
-retry_find:
-	page = find_get_page(mapping, pgoff);
-	if (!page) {
-		if (nonblock)
-			return NULL;
-		goto no_cached_page;
-	}
-
-	/*
-	 * Ok, found a page in the page cache, now we need to check
-	 * that it's up-to-date.
-	 */
-	if (!PageUptodate(page)) {
-		if (nonblock) {
-			page_cache_release(page);
-			return NULL;
-		}
-		goto page_not_uptodate;
-	}
-
-success:
-	/*
-	 * Found the page and have a reference on it.
-	 */
-	mark_page_accessed(page);
-	return page;
-
-no_cached_page:
-	error = page_cache_read(file, pgoff);
-
-	/*
-	 * The page we want has now been added to the page cache.
-	 * In the unlikely event that someone removed it in the
-	 * meantime, we'll just come back here and read it again.
-	 */
-	if (error >= 0)
-		goto retry_find;
-
-	/*
-	 * An error return from page_cache_read can result if the
-	 * system is low on memory, or a problem occurs while trying
-	 * to schedule I/O.
-	 */
-	return NULL;
-
-page_not_uptodate:
-	lock_page(page);
-
-	/* Did it get truncated while we waited for it? */
-	if (!page->mapping) {
-		unlock_page(page);
-		goto err;
-	}
-
-	/* Did somebody else get it up-to-date? */
-	if (PageUptodate(page)) {
-		unlock_page(page);
-		goto success;
-	}
-
-	error = mapping->a_ops->readpage(file, page);
-	if (!error) {
-		wait_on_page_locked(page);
-		if (PageUptodate(page))
-			goto success;
-	} else if (error == AOP_TRUNCATED_PAGE) {
-		page_cache_release(page);
-		goto retry_find;
-	}
-
-	/*
-	 * Umm, take care of errors if the page isn't up-to-date.
-	 * Try to re-read it _once_. We do this synchronously,
-	 * because there really aren't any performance issues here
-	 * and we need to check for errors.
-	 */
-	lock_page(page);
-
-	/* Somebody truncated the page on us? */
-	if (!page->mapping) {
-		unlock_page(page);
-		goto err;
-	}
-	/* Somebody else successfully read it in? */
-	if (PageUptodate(page)) {
-		unlock_page(page);
-		goto success;
-	}
-
-	ClearPageError(page);
-	error = mapping->a_ops->readpage(file, page);
-	if (!error) {
-		wait_on_page_locked(page);
-		if (PageUptodate(page))
-			goto success;
-	} else if (error == AOP_TRUNCATED_PAGE) {
-		page_cache_release(page);
-		goto retry_find;
-	}
-
-	/*
-	 * Things didn't work out. Return zero to tell the
-	 * mm layer so, possibly freeing the page cache page first.
-	 */
-err:
-	page_cache_release(page);
-
-	return NULL;
-}
-
-int filemap_populate(struct vm_area_struct *vma, unsigned long addr,
-		unsigned long len, pgprot_t prot, unsigned long pgoff,
-		int nonblock)
-{
-	struct file *file = vma->vm_file;
-	struct address_space *mapping = file->f_mapping;
-	struct inode *inode = mapping->host;
-	unsigned long size;
-	struct mm_struct *mm = vma->vm_mm;
-	struct page *page;
-	int err;
-
-	if (!nonblock)
-		force_page_cache_readahead(mapping, vma->vm_file,
-					pgoff, len >> PAGE_CACHE_SHIFT);
-
-repeat:
-	size = (i_size_read(inode) + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
-	if (pgoff + (len >> PAGE_CACHE_SHIFT) > size)
-		return -EINVAL;
-
-	page = filemap_getpage(file, pgoff, nonblock);
-
-	/* XXX: This is wrong, a filesystem I/O error may have happened. Fix that as
-	 * done in shmem_populate calling shmem_getpage */
-	if (!page && !nonblock)
-		return -ENOMEM;
-
-	if (page) {
-		err = install_page(mm, vma, addr, page, prot);
-		if (err) {
-			page_cache_release(page);
-			return err;
-		}
-	} else if (vma->vm_flags & VM_NONLINEAR) {
-		/* No page was found just because we can't read it in now (being
-		 * here implies nonblock != 0), but the page may exist, so set
-		 * the PTE to fault it in later. */
-		err = install_file_pte(mm, vma, addr, pgoff, prot);
-		if (err)
-			return err;
-	}
-
-	len -= PAGE_SIZE;
-	addr += PAGE_SIZE;
-	pgoff++;
-	if (len)
-		goto repeat;
-
-	return 0;
-}
-EXPORT_SYMBOL(filemap_populate);
-
 struct vm_operations_struct generic_file_vm_ops = {
 	.fault		= filemap_fault,
 };
@@ -1715,7 +1516,7 @@ int generic_file_mmap(struct file * file
 		return -ENOEXEC;
 	file_accessed(file);
 	vma->vm_ops = &generic_file_vm_ops;
-	vma->vm_flags |= VM_CAN_INVALIDATE | VM_CAN_NONLINEAR;
+	vma->vm_flags |= VM_CAN_NONLINEAR;
 	return 0;
 }
 
Index: linux-2.6/mm/filemap_xip.c
===================================================================
--- linux-2.6.orig/mm/filemap_xip.c
+++ linux-2.6/mm/filemap_xip.c
@@ -232,8 +232,7 @@ __xip_unmap (struct address_space * mapp
  *
  * This function is derived from filemap_fault, but used for execute in place
  */
-static struct page *xip_file_fault(struct vm_area_struct *area,
-					struct fault_data *fdata)
+static int xip_file_fault(struct vm_area_struct *area, struct vm_fault *vmf)
 {
 	struct file *file = area->vm_file;
 	struct address_space *mapping = file->f_mapping;
@@ -244,19 +243,15 @@ static struct page *xip_file_fault(struc
 	/* XXX: are VM_FAULT_ codes OK? */
 
 	size = (i_size_read(inode) + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
-	if (fdata->pgoff >= size) {
-		fdata->type = VM_FAULT_SIGBUS;
-		return NULL;
-	}
+	if (vmf->pgoff >= size)
+		return VM_FAULT_SIGBUS;
 
 	page = mapping->a_ops->get_xip_page(mapping,
-					fdata->pgoff*(PAGE_SIZE/512), 0);
+					vmf->pgoff*(PAGE_SIZE/512), 0);
 	if (!IS_ERR(page))
 		goto out;
-	if (PTR_ERR(page) != -ENODATA) {
-		fdata->type = VM_FAULT_OOM;
-		return NULL;
-	}
+	if (PTR_ERR(page) != -ENODATA)
+		return VM_FAULT_OOM;
 
 	/* sparse block */
 	if ((area->vm_flags & (VM_WRITE | VM_MAYWRITE)) &&
@@ -264,26 +259,22 @@ static struct page *xip_file_fault(struc
 	    (!(mapping->host->i_sb->s_flags & MS_RDONLY))) {
 		/* maybe shared writable, allocate new block */
 		page = mapping->a_ops->get_xip_page(mapping,
-					fdata->pgoff*(PAGE_SIZE/512), 1);
-		if (IS_ERR(page)) {
-			fdata->type = VM_FAULT_SIGBUS;
-			return NULL;
-		}
+					vmf->pgoff*(PAGE_SIZE/512), 1);
+		if (IS_ERR(page))
+			return VM_FAULT_SIGBUS;
 		/* unmap page at pgoff from all other vmas */
-		__xip_unmap(mapping, fdata->pgoff);
+		__xip_unmap(mapping, vmf->pgoff);
 	} else {
 		/* not shared and writable, use xip_sparse_page() */
 		page = xip_sparse_page();
-		if (!page) {
-			fdata->type = VM_FAULT_OOM;
-			return NULL;
-		}
+		if (!page)
+			return VM_FAULT_OOM;
 	}
 
 out:
-	fdata->type = VM_FAULT_MINOR;
 	page_cache_get(page);
-	return page;
+	vmf->page = page;
+	return VM_FAULT_MINOR;
 }
 
 static struct vm_operations_struct xip_file_vm_ops = {
Index: linux-2.6/mm/memory.c
===================================================================
--- linux-2.6.orig/mm/memory.c
+++ linux-2.6/mm/memory.c
@@ -1828,10 +1828,10 @@ static int unmap_mapping_range_vma(struc
 
 	/*
 	 * files that support invalidating or truncating portions of the
-	 * file from under mmaped areas must set the VM_CAN_INVALIDATE flag, and
-	 * have their .nopage function return the page locked.
+	 * file from under mmaped areas must have their ->fault function
+	 * return a locked page (and FAULT_RET_LOCKED code). This provides
+	 * synchronisation against concurrent unmapping here.
 	 */
-	BUG_ON(!(vma->vm_flags & VM_CAN_INVALIDATE));
 
 again:
 	restart_addr = vma->vm_truncate_count;
@@ -2300,63 +2300,62 @@ static int __do_fault(struct mm_struct *
 		pgoff_t pgoff, unsigned int flags, pte_t orig_pte)
 {
 	spinlock_t *ptl;
-	struct page *page, *faulted_page;
+	struct page *page;
 	pte_t entry;
 	int anon = 0;
 	struct page *dirty_page = NULL;
-	struct fault_data fdata;
+	struct vm_fault vmf;
+	int ret;
 
-	fdata.address = address & PAGE_MASK;
-	fdata.pgoff = pgoff;
-	fdata.flags = flags;
+	vmf.virtual_address = (void __user *)(address & PAGE_MASK);
+	vmf.pgoff = pgoff;
+	vmf.flags = flags;
+	vmf.page = NULL;
 
 	pte_unmap(page_table);
 	BUG_ON(vma->vm_flags & VM_PFNMAP);
 
 	if (likely(vma->vm_ops->fault)) {
-		fdata.type = -1;
-		faulted_page = vma->vm_ops->fault(vma, &fdata);
-		WARN_ON(fdata.type == -1);
-		if (unlikely(!faulted_page))
-			return fdata.type;
+		ret = vma->vm_ops->fault(vma, &vmf);
+		if (unlikely(ret & (VM_FAULT_ERROR | FAULT_RET_NOPAGE)))
+			return (ret & VM_FAULT_MASK);
 	} else {
 		/* Legacy ->nopage path */
-		fdata.type = VM_FAULT_MINOR;
-		faulted_page = vma->vm_ops->nopage(vma, address & PAGE_MASK,
-								&fdata.type);
+		ret = VM_FAULT_MINOR;
+		vmf.page = vma->vm_ops->nopage(vma, address & PAGE_MASK, &ret);
 		/* no page was available -- either SIGBUS or OOM */
-		if (unlikely(faulted_page == NOPAGE_SIGBUS))
+		if (unlikely(vmf.page == NOPAGE_SIGBUS))
 			return VM_FAULT_SIGBUS;
-		else if (unlikely(faulted_page == NOPAGE_OOM))
+		else if (unlikely(vmf.page == NOPAGE_OOM))
 			return VM_FAULT_OOM;
 	}
 
 	/*
-	 * For consistency in subsequent calls, make the faulted_page always
+	 * For consistency in subsequent calls, make the faulted page always
 	 * locked.
 	 */
-	if (unlikely(!(vma->vm_flags & VM_CAN_INVALIDATE)))
-		lock_page(faulted_page);
+	if (unlikely(!(ret & FAULT_RET_LOCKED)))
+		lock_page(vmf.page);
 	else
-		BUG_ON(!PageLocked(faulted_page));
+		VM_BUG_ON(!PageLocked(vmf.page));
 
 	/*
 	 * Should we do an early C-O-W break?
 	 */
-	page = faulted_page;
+	page = vmf.page;
 	if (flags & FAULT_FLAG_WRITE) {
 		if (!(vma->vm_flags & VM_SHARED)) {
 			anon = 1;
 			if (unlikely(anon_vma_prepare(vma))) {
-				fdata.type = VM_FAULT_OOM;
+				ret = VM_FAULT_OOM;
 				goto out;
 			}
 			page = alloc_page_vma(GFP_HIGHUSER, vma, address);
 			if (!page) {
-				fdata.type = VM_FAULT_OOM;
+				ret = VM_FAULT_OOM;
 				goto out;
 			}
-			copy_user_highpage(page, faulted_page, address, vma);
+			copy_user_highpage(page, vmf.page, address, vma);
 		} else {
 			/*
 			 * If the page will be shareable, see if the backing
@@ -2366,11 +2365,23 @@ static int __do_fault(struct mm_struct *
 			if (vma->vm_ops->page_mkwrite) {
 				unlock_page(page);
 				if (vma->vm_ops->page_mkwrite(vma, page) < 0) {
-					fdata.type = VM_FAULT_SIGBUS;
-					anon = 1; /* no anon but release faulted_page */
+					ret = VM_FAULT_SIGBUS;
+					anon = 1; /* no anon but release vmf.page */
 					goto out_unlocked;
 				}
 				lock_page(page);
+				/*
+				 * XXX: this is not quite right (racy vs
+				 * invalidate) to unlock and relock the page
+				 * like this, however a better fix requires
+				 * reworking page_mkwrite locking API, which
+				 * is better done later.
+				 */
+				if (!page->mapping) {
+					ret = VM_FAULT_MINOR;
+					anon = 1; /* no anon but release vmf.page */
+					goto out;
+				}
 			}
 		}
 
@@ -2421,16 +2432,16 @@ static int __do_fault(struct mm_struct *
 	pte_unmap_unlock(page_table, ptl);
 
 out:
-	unlock_page(faulted_page);
+	unlock_page(vmf.page);
 out_unlocked:
 	if (anon)
-		page_cache_release(faulted_page);
+		page_cache_release(vmf.page);
 	else if (dirty_page) {
 		set_page_dirty_balance(dirty_page);
 		put_page(dirty_page);
 	}
 
-	return fdata.type;
+	return (ret & VM_FAULT_MASK);
 }
 
 static int do_linear_fault(struct mm_struct *mm, struct vm_area_struct *vma,
@@ -2441,18 +2452,10 @@ static int do_linear_fault(struct mm_str
 			- vma->vm_start) >> PAGE_CACHE_SHIFT) + vma->vm_pgoff;
 	unsigned int flags = (write_access ? FAULT_FLAG_WRITE : 0);
 
-	return __do_fault(mm, vma, address, page_table, pmd, pgoff, flags, orig_pte);
+	return __do_fault(mm, vma, address, page_table, pmd, pgoff,
+							flags, orig_pte);
 }
 
-static int do_nonlinear_fault(struct mm_struct *mm, struct vm_area_struct *vma,
-		unsigned long address, pte_t *page_table, pmd_t *pmd,
-		int write_access, pgoff_t pgoff, pte_t orig_pte)
-{
-	unsigned int flags = FAULT_FLAG_NONLINEAR |
-				(write_access ? FAULT_FLAG_WRITE : 0);
-
-	return __do_fault(mm, vma, address, page_table, pmd, pgoff, flags, orig_pte);
-}
 
 /*
  * do_no_pfn() tries to create a new page mapping for a page without
@@ -2513,17 +2516,19 @@ static noinline int do_no_pfn(struct mm_
  * but allow concurrent faults), and pte mapped but not yet locked.
  * We return with mmap_sem still held, but pte unmapped and unlocked.
  */
-static int do_file_page(struct mm_struct *mm, struct vm_area_struct *vma,
+static int do_nonlinear_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 		unsigned long address, pte_t *page_table, pmd_t *pmd,
 		int write_access, pte_t orig_pte)
 {
+	unsigned int flags = FAULT_FLAG_NONLINEAR |
+				(write_access ? FAULT_FLAG_WRITE : 0);
 	pgoff_t pgoff;
-	int err;
 
 	if (!pte_unmap_same(mm, pmd, page_table, orig_pte))
 		return VM_FAULT_MINOR;
 
-	if (unlikely(!(vma->vm_flags & VM_NONLINEAR))) {
+	if (unlikely(!(vma->vm_flags & VM_NONLINEAR) ||
+			!(vma->vm_flags & VM_CAN_NONLINEAR))) {
 		/*
 		 * Page table corrupted: show pte and kill process.
 		 */
@@ -2533,18 +2538,8 @@ static int do_file_page(struct mm_struct
 
 	pgoff = pte_to_pgoff(orig_pte);
 
-	if (vma->vm_ops && vma->vm_ops->fault)
-		return do_nonlinear_fault(mm, vma, address, page_table, pmd,
-					write_access, pgoff, orig_pte);
-
-	/* We can then assume vm->vm_ops && vma->vm_ops->populate */
-	err = vma->vm_ops->populate(vma, address & PAGE_MASK, PAGE_SIZE,
-					vma->vm_page_prot, pgoff, 0);
-	if (err == -ENOMEM)
-		return VM_FAULT_OOM;
-	if (err)
-		return VM_FAULT_SIGBUS;
-	return VM_FAULT_MAJOR;
+	return __do_fault(mm, vma, address, page_table, pmd, pgoff,
+							flags, orig_pte);
 }
 
 /*
@@ -2582,7 +2577,7 @@ static inline int handle_pte_fault(struc
 						 pte, pmd, write_access);
 		}
 		if (pte_file(entry))
-			return do_file_page(mm, vma, address,
+			return do_nonlinear_fault(mm, vma, address,
 					pte, pmd, write_access, entry);
 		return do_swap_page(mm, vma, address,
 					pte, pmd, write_access, entry);
Index: linux-2.6/mm/nommu.c
===================================================================
--- linux-2.6.orig/mm/nommu.c
+++ linux-2.6/mm/nommu.c
@@ -1336,10 +1336,10 @@ int in_gate_area_no_task(unsigned long a
 	return 0;
 }
 
-struct page *filemap_fault(struct vm_area_struct *vma, struct fault_data *fdata)
+int filemap_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 {
 	BUG();
-	return NULL;
+	return 0;
 }
 
 /*
Index: linux-2.6/mm/shmem.c
===================================================================
--- linux-2.6.orig/mm/shmem.c
+++ linux-2.6/mm/shmem.c
@@ -1305,29 +1305,21 @@ failed:
 	return error;
 }
 
-static struct page *shmem_fault(struct vm_area_struct *vma,
-					struct fault_data *fdata)
+static int shmem_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 {
 	struct inode *inode = vma->vm_file->f_path.dentry->d_inode;
-	struct page *page = NULL;
 	int error;
+	int ret;
 
-	BUG_ON(!(vma->vm_flags & VM_CAN_INVALIDATE));
+	if (((loff_t)vmf->pgoff << PAGE_CACHE_SHIFT) >= i_size_read(inode))
+		return VM_FAULT_SIGBUS;
 
-	if (((loff_t)fdata->pgoff << PAGE_CACHE_SHIFT) >= i_size_read(inode)) {
-		fdata->type = VM_FAULT_SIGBUS;
-		return NULL;
-	}
-
-	error = shmem_getpage(inode, fdata->pgoff, &page,
-						SGP_FAULT, &fdata->type);
-	if (error) {
-		fdata->type = ((error == -ENOMEM)?VM_FAULT_OOM:VM_FAULT_SIGBUS);
-		return NULL;
-	}
+	error = shmem_getpage(inode, vmf->pgoff, &vmf->page, SGP_FAULT, &ret);
+	if (error)
+		return ((error == -ENOMEM) ? VM_FAULT_OOM : VM_FAULT_SIGBUS);
 
-	mark_page_accessed(page);
-	return page;
+	mark_page_accessed(vmf->page);
+	return ret | FAULT_RET_LOCKED;
 }
 
 #ifdef CONFIG_NUMA
@@ -1374,7 +1366,7 @@ static int shmem_mmap(struct file *file,
 {
 	file_accessed(file);
 	vma->vm_ops = &shmem_vm_ops;
-	vma->vm_flags |= VM_CAN_INVALIDATE | VM_CAN_NONLINEAR;
+	vma->vm_flags |= VM_CAN_NONLINEAR;
 	return 0;
 }
 
@@ -2564,6 +2556,5 @@ int shmem_zero_setup(struct vm_area_stru
 		fput(vma->vm_file);
 	vma->vm_file = file;
 	vma->vm_ops = &shmem_vm_ops;
-	vma->vm_flags |= VM_CAN_INVALIDATE;
 	return 0;
 }
Index: linux-2.6/fs/gfs2/ops_file.c
===================================================================
--- linux-2.6.orig/fs/gfs2/ops_file.c
+++ linux-2.6/fs/gfs2/ops_file.c
@@ -364,8 +364,6 @@ static int gfs2_mmap(struct file *file, 
 	else
 		vma->vm_ops = &gfs2_vm_ops_private;
 
-	vma->vm_flags |= VM_CAN_INVALIDATE|VM_CAN_NONLINEAR;
-
 	gfs2_glock_dq_uninit(&i_gh);
 
 	return error;
Index: linux-2.6/Documentation/feature-removal-schedule.txt
===================================================================
--- linux-2.6.orig/Documentation/feature-removal-schedule.txt
+++ linux-2.6/Documentation/feature-removal-schedule.txt
@@ -145,26 +145,8 @@ Who:	Greg Kroah-Hartman <gregkh@suse.de>
 
 ---------------------------
 
-What:	filemap_nopage, filemap_populate
-When:	April 2007
-Why:	These legacy interfaces no longer have any callers in the kernel and
-	any functionality provided can be provided with filemap_fault. The
-	removal schedule is short because they are a big maintainence burden
-	and have some bugs.
-Who:	Nick Piggin <npiggin@suse.de>
-
----------------------------
-
-What:	vm_ops.populate, install_page
-When:	April 2007
-Why:	These legacy interfaces no longer have any callers in the kernel and
-	any functionality provided can be provided with vm_ops.fault.
-Who:	Nick Piggin <npiggin@suse.de>
-
----------------------------
-
 What:	vm_ops.nopage
-When:	February 2008, provided in-kernel callers have been converted
+When:	Soon, provided in-kernel callers have been converted
 Why:	This interface is replaced by vm_ops.fault, but it has been around
 	forever, is used by a lot of drivers, and doesn't cost much to
 	maintain.
Index: linux-2.6/Documentation/filesystems/Locking
===================================================================
--- linux-2.6.orig/Documentation/filesystems/Locking
+++ linux-2.6/Documentation/filesystems/Locking
@@ -510,7 +510,7 @@ More details about quota locking can be 
 prototypes:
 	void (*open)(struct vm_area_struct*);
 	void (*close)(struct vm_area_struct*);
-	struct page *(*fault)(struct vm_area_struct*, struct fault_data *);
+	int (*fault)(struct vm_area_struct*, struct vm_fault *);
 	struct page *(*nopage)(struct vm_area_struct*, unsigned long, int *);
 	int (*page_mkwrite)(struct vm_area_struct *, struct page *);
 
Index: linux-2.6/mm/fremap.c
===================================================================
--- linux-2.6.orig/mm/fremap.c
+++ linux-2.6/mm/fremap.c
@@ -20,13 +20,14 @@
 #include <asm/cacheflush.h>
 #include <asm/tlbflush.h>
 
-static int zap_pte(struct mm_struct *mm, struct vm_area_struct *vma,
+static void zap_pte(struct mm_struct *mm, struct vm_area_struct *vma,
 			unsigned long addr, pte_t *ptep)
 {
 	pte_t pte = *ptep;
-	struct page *page = NULL;
 
 	if (pte_present(pte)) {
+		struct page *page;
+
 		flush_cache_page(vma, addr, pte_pfn(pte));
 		pte = ptep_clear_flush(vma, addr, ptep);
 		page = vm_normal_page(vma, addr, pte);
@@ -35,68 +36,21 @@ static int zap_pte(struct mm_struct *mm,
 				set_page_dirty(page);
 			page_remove_rmap(page, vma);
 			page_cache_release(page);
+			update_hiwater_rss(mm);
+			dec_mm_counter(mm, file_rss);
 		}
 	} else {
 		if (!pte_file(pte))
 			free_swap_and_cache(pte_to_swp_entry(pte));
 		pte_clear_not_present_full(mm, addr, ptep, 0);
 	}
-	return !!page;
 }
 
 /*
- * Install a file page to a given virtual memory address, release any
- * previously existing mapping.
- */
-int install_page(struct mm_struct *mm, struct vm_area_struct *vma,
-		unsigned long addr, struct page *page, pgprot_t prot)
-{
-	struct inode *inode;
-	pgoff_t size;
-	int err = -ENOMEM;
-	pte_t *pte;
-	pte_t pte_val;
-	spinlock_t *ptl;
-
-	pte = get_locked_pte(mm, addr, &ptl);
-	if (!pte)
-		goto out;
-
-	/*
-	 * This page may have been truncated. Tell the
-	 * caller about it.
-	 */
-	err = -EINVAL;
-	inode = vma->vm_file->f_mapping->host;
-	size = (i_size_read(inode) + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
-	if (!page->mapping || page->index >= size)
-		goto unlock;
-	err = -ENOMEM;
-	if (page_mapcount(page) > INT_MAX/2)
-		goto unlock;
-
-	if (pte_none(*pte) || !zap_pte(mm, vma, addr, pte))
-		inc_mm_counter(mm, file_rss);
-
-	flush_icache_page(vma, page);
-	pte_val = mk_pte(page, prot);
-	set_pte_at(mm, addr, pte, pte_val);
-	page_add_file_rmap(page);
-	update_mmu_cache(vma, addr, pte_val);
-	lazy_mmu_prot_update(pte_val);
-	err = 0;
-unlock:
-	pte_unmap_unlock(pte, ptl);
-out:
-	return err;
-}
-EXPORT_SYMBOL(install_page);
-
-/*
  * Install a file pte to a given virtual memory address, release any
  * previously existing mapping.
  */
-int install_file_pte(struct mm_struct *mm, struct vm_area_struct *vma,
+static int install_file_pte(struct mm_struct *mm, struct vm_area_struct *vma,
 		unsigned long addr, unsigned long pgoff, pgprot_t prot)
 {
 	int err = -ENOMEM;
@@ -107,10 +61,8 @@ int install_file_pte(struct mm_struct *m
 	if (!pte)
 		goto out;
 
-	if (!pte_none(*pte) && zap_pte(mm, vma, addr, pte)) {
-		update_hiwater_rss(mm);
-		dec_mm_counter(mm, file_rss);
-	}
+	if (!pte_none(*pte))
+		zap_pte(mm, vma, addr, pte);
 
 	set_pte_at(mm, addr, pte, pgoff_to_pte(pgoff));
 	/*
@@ -208,8 +160,7 @@ asmlinkage long sys_remap_file_pages(uns
 	if (vma->vm_private_data && !(vma->vm_flags & VM_NONLINEAR))
 		goto out;
 
-	if ((!vma->vm_ops || !vma->vm_ops->populate) &&
-					!(vma->vm_flags & VM_CAN_NONLINEAR))
+	if (!vma->vm_flags & VM_CAN_NONLINEAR)
 		goto out;
 
 	if (end <= start || start < vma->vm_start || end > vma->vm_end)
@@ -239,18 +190,14 @@ asmlinkage long sys_remap_file_pages(uns
 		spin_unlock(&mapping->i_mmap_lock);
 	}
 
-	if (vma->vm_flags & VM_CAN_NONLINEAR) {
-		err = populate_range(mm, vma, start, size, pgoff);
-		if (!err && !(flags & MAP_NONBLOCK)) {
-			if (unlikely(has_write_lock)) {
-				downgrade_write(&mm->mmap_sem);
-				has_write_lock = 0;
-			}
-			make_pages_present(start, start+size);
+	err = populate_range(mm, vma, start, size, pgoff);
+	if (!err && !(flags & MAP_NONBLOCK)) {
+		if (unlikely(has_write_lock)) {
+			downgrade_write(&mm->mmap_sem);
+			has_write_lock = 0;
 		}
-	} else
-		err = vma->vm_ops->populate(vma, start, size, vma->vm_page_prot,
-					    	pgoff, flags & MAP_NONBLOCK);
+		make_pages_present(start, start+size);
+	}
 
 	/*
 	 * We can't clear VM_NONLINEAR because we'd have to do
Index: linux-2.6/mm/hugetlb.c
===================================================================
--- linux-2.6.orig/mm/hugetlb.c
+++ linux-2.6/mm/hugetlb.c
@@ -292,15 +292,14 @@ unsigned long hugetlb_total_pages(void)
  * hugegpage VMA.  do_page_fault() is supposed to trap this, so BUG is we get
  * this far.
  */
-static struct page *hugetlb_nopage(struct vm_area_struct *vma,
-				unsigned long address, int *unused)
+static int hugetlb_vm_op_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 {
 	BUG();
-	return NULL;
+	return 0;
 }
 
 struct vm_operations_struct hugetlb_vm_ops = {
-	.nopage = hugetlb_nopage,
+	.fault = hugetlb_vm_op_fault,
 };
 
 static pte_t make_huge_pte(struct vm_area_struct *vma, struct page *page,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
