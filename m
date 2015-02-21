Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 1C75E6B0032
	for <linux-mm@kvack.org>; Fri, 20 Feb 2015 23:11:06 -0500 (EST)
Received: by pdjz10 with SMTP id z10so12110567pdj.0
        for <linux-mm@kvack.org>; Fri, 20 Feb 2015 20:11:05 -0800 (PST)
Received: from mail-pa0-x236.google.com (mail-pa0-x236.google.com. [2607:f8b0:400e:c03::236])
        by mx.google.com with ESMTPS id br8si1123370pdb.43.2015.02.20.20.11.04
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Feb 2015 20:11:05 -0800 (PST)
Received: by pabrd3 with SMTP id rd3so12924288pab.1
        for <linux-mm@kvack.org>; Fri, 20 Feb 2015 20:11:04 -0800 (PST)
Date: Fri, 20 Feb 2015 20:11:01 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 12/24] huge tmpfs: get_unmapped_area align and fault supply
 huge page
In-Reply-To: <alpine.LSU.2.11.1502201941340.14414@eggly.anvils>
Message-ID: <alpine.LSU.2.11.1502202009300.14414@eggly.anvils>
References: <alpine.LSU.2.11.1502201941340.14414@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Ning Qu <quning@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Now make the shmem.c changes necessary for mapping its huge pages into
userspace with huge pmds: without actually doing so, since that needs
changes in huge_memory.c and across mm, better left to another patch.

Provide a shmem_get_unmapped_area method in file_operations, called
at mmap time to decide the mapping address.  It could be conditional
on CONFIG_TRANSPARENT_HUGEPAGE, but save #ifdefs in other places by
making it unconditional.

shmem_get_unmapped_area() first calls the usual mm->get_unmapped_area
(which we treat as a black box, highly dependent on architecture and
config and executable layout).  Lots of conditions, and in most cases
it just goes with the address that chose; but when our huge stars are
rightly aligned, yet that did not provide a suitable address, go back
to ask for a larger arena, within which to align the mapping suitably.

There have to be some direct calls to shmem_get_unmapped_area(),
not via the file_operations: because of the way shmem_zero_setup()
is called to create a shmem object late in the mmap sequence, when
MAP_SHARED is requested with MAP_ANONYMOUS or /dev/zero.  Though
this only matters when /proc/sys/vm/shmem_huge has been set.

Then at fault time, shmem_fault() does its usual shmem_getpage_gfp(),
and if caller __do_fault() passed FAULT_FLAG_MAY_HUGE (in later patch),
checks if the 4kB page returned is PageTeam, and, subject to further
conditions, proceeds to populate the whole of the huge page (if it
was not already fully populated and uptodate: use PG_owner_priv_1
PageChecked to save repeating all this each time the object is mapped);
then returns it to __do_fault() with a VM_FAULT_HUGE flag to request
a huge pmd.

Among shmem_fault()'s conditions: don't attempt huge if VM_NONLINEAR.
But that raises the question, what if the remap_file_pages(2) system
call were used on an area with huge pmds?  Turns out that it populates
the area using __get_locked_pte(): VM_BUG_ON(pmd_trans_huge(*pmd))
replaced by split_huge_page_pmd_mm() and we should be okay.

Two conditions you might expect, which are not enforced.  Originally
I intended to support just MAP_SHARED at this stage, which should be
good enough for a first implementation; but support for MAP_PRIVATE
(on read fault) needs so little further change, that it was well worth
supporting too - it opens up the opportunity to copy your x86_64 ELF
executables to huge tmpfs, their text then automatically mapped huge.

The other missing condition: shmem_getpage_gfp() is checking that
the fault falls within (4kB-rounded-up) i_size, but shmem_fault() maps
hugely even when the tail of the 2MB falls outside the (4kB-rounded-up)
i_size.  This is intentional, but may need reconsideration - especially
in the MAP_PRIVATE case (is it right for a private mapping to allocate
"hidden" pages to the object beyond its EOF?).  The intent is that an
application can indicate its desire for huge pmds throughout, even of
the tail, by using a hugely-rounded-up mmap size; but we might end up
retracting this, asking for fallocate to be used explicitly for that.
(hugetlbfs behaves even less standardly: its mmap extends the i_size
of the object.)

Signed-off-by: Hugh Dickins <hughd@google.com>
---
 drivers/char/mem.c       |   23 ++++
 include/linux/mm.h       |    3 
 include/linux/shmem_fs.h |    2 
 ipc/shm.c                |    6 -
 mm/memory.c              |    3 
 mm/mmap.c                |   16 ++
 mm/shmem.c               |  200 ++++++++++++++++++++++++++++++++++++-
 7 files changed, 243 insertions(+), 10 deletions(-)

--- thpfs.orig/drivers/char/mem.c	2015-02-08 18:54:22.000000000 -0800
+++ thpfs/drivers/char/mem.c	2015-02-20 19:34:21.595969599 -0800
@@ -22,6 +22,7 @@
 #include <linux/device.h>
 #include <linux/highmem.h>
 #include <linux/backing-dev.h>
+#include <linux/shmem_fs.h>
 #include <linux/splice.h>
 #include <linux/pfn.h>
 #include <linux/export.h>
@@ -654,6 +655,27 @@ static int mmap_zero(struct file *file,
 	return 0;
 }
 
+static unsigned long get_unmapped_area_zero(struct file *file,
+				unsigned long addr, unsigned long len,
+				unsigned long pgoff, unsigned long flags)
+{
+#ifndef CONFIG_MMU
+	return -ENOSYS;
+#endif
+	if (flags & MAP_SHARED) {
+		/*
+		 * mmap_zero() will call shmem_zero_setup() to create a file,
+		 * so use shmem's get_unmapped_area in case it can be huge;
+		 * and pass NULL for file as in mmap.c's get_unmapped_area(),
+		 * so as not to confuse shmem with our handle on "/dev/zero".
+		 */
+		return shmem_get_unmapped_area(NULL, addr, len, pgoff, flags);
+	}
+
+	/* Otherwise flags & MAP_PRIVATE: with no shmem object beneath it */
+	return current->mm->get_unmapped_area(file, addr, len, pgoff, flags);
+}
+
 static ssize_t write_full(struct file *file, const char __user *buf,
 			  size_t count, loff_t *ppos)
 {
@@ -760,6 +782,7 @@ static const struct file_operations zero
 	.read_iter	= read_iter_zero,
 	.aio_write	= aio_write_zero,
 	.mmap		= mmap_zero,
+	.get_unmapped_area = get_unmapped_area_zero,
 };
 
 /*
--- thpfs.orig/include/linux/mm.h	2015-02-20 19:34:11.231993296 -0800
+++ thpfs/include/linux/mm.h	2015-02-20 19:34:21.599969589 -0800
@@ -213,6 +213,7 @@ extern pgprot_t protection_map[16];
 #define FAULT_FLAG_KILLABLE	0x20	/* The fault task is in SIGKILL killable region */
 #define FAULT_FLAG_TRIED	0x40	/* second try */
 #define FAULT_FLAG_USER		0x80	/* The fault originated in userspace */
+#define FAULT_FLAG_MAY_HUGE	0x100	/* PT not alloced: could use huge pmd */
 
 /*
  * vm_fault is filled by the the pagefault handler and passed to the vma's
@@ -1069,7 +1070,7 @@ static inline int page_mapped(struct pag
 #define VM_FAULT_HWPOISON 0x0010	/* Hit poisoned small page */
 #define VM_FAULT_HWPOISON_LARGE 0x0020  /* Hit poisoned large page. Index encoded in upper bits */
 #define VM_FAULT_SIGSEGV 0x0040
-
+#define VM_FAULT_HUGE	0x0080	/* ->fault needs page installed as huge pmd */
 #define VM_FAULT_NOPAGE	0x0100	/* ->fault installed the pte, not return page */
 #define VM_FAULT_LOCKED	0x0200	/* ->fault locked the returned page */
 #define VM_FAULT_RETRY	0x0400	/* ->fault blocked, must retry */
--- thpfs.orig/include/linux/shmem_fs.h	2015-02-20 19:34:16.135982083 -0800
+++ thpfs/include/linux/shmem_fs.h	2015-02-20 19:34:21.599969589 -0800
@@ -54,6 +54,8 @@ extern struct file *shmem_file_setup(con
 extern struct file *shmem_kernel_file_setup(const char *name, loff_t size,
 					    unsigned long flags);
 extern int shmem_zero_setup(struct vm_area_struct *);
+extern unsigned long shmem_get_unmapped_area(struct file *, unsigned long addr,
+		unsigned long len, unsigned long pgoff, unsigned long flags);
 extern int shmem_lock(struct file *file, int lock, struct user_struct *user);
 extern bool shmem_mapping(struct address_space *mapping);
 extern void shmem_unlock_mapping(struct address_space *mapping);
--- thpfs.orig/ipc/shm.c	2015-02-08 18:54:22.000000000 -0800
+++ thpfs/ipc/shm.c	2015-02-20 19:34:21.599969589 -0800
@@ -442,13 +442,15 @@ static const struct file_operations shm_
 	.mmap		= shm_mmap,
 	.fsync		= shm_fsync,
 	.release	= shm_release,
-#ifndef CONFIG_MMU
 	.get_unmapped_area	= shm_get_unmapped_area,
-#endif
 	.llseek		= noop_llseek,
 	.fallocate	= shm_fallocate,
 };
 
+/*
+ * shm_file_operations_huge is now identical to shm_file_operations,
+ * but we keep it distinct for the sake of is_file_shm_hugepages().
+ */
 static const struct file_operations shm_file_operations_huge = {
 	.mmap		= shm_mmap,
 	.fsync		= shm_fsync,
--- thpfs.orig/mm/memory.c	2015-02-08 18:54:22.000000000 -0800
+++ thpfs/mm/memory.c	2015-02-20 19:34:21.599969589 -0800
@@ -1448,7 +1448,8 @@ pte_t *__get_locked_pte(struct mm_struct
 	if (pud) {
 		pmd_t * pmd = pmd_alloc(mm, pud, addr);
 		if (pmd) {
-			VM_BUG_ON(pmd_trans_huge(*pmd));
+			/* VM_NONLINEAR install_file_pte() must split hugepmd */
+			split_huge_page_pmd_mm(mm, addr, pmd);
 			return pte_alloc_map_lock(mm, pmd, addr, ptl);
 		}
 	}
--- thpfs.orig/mm/mmap.c	2015-02-20 19:33:56.528026917 -0800
+++ thpfs/mm/mmap.c	2015-02-20 19:34:21.603969581 -0800
@@ -25,6 +25,7 @@
 #include <linux/personality.h>
 #include <linux/security.h>
 #include <linux/hugetlb.h>
+#include <linux/shmem_fs.h>
 #include <linux/profile.h>
 #include <linux/export.h>
 #include <linux/mount.h>
@@ -2017,8 +2018,19 @@ get_unmapped_area(struct file *file, uns
 		return -ENOMEM;
 
 	get_area = current->mm->get_unmapped_area;
-	if (file && file->f_op->get_unmapped_area)
-		get_area = file->f_op->get_unmapped_area;
+	if (file) {
+		if (file->f_op->get_unmapped_area)
+			get_area = file->f_op->get_unmapped_area;
+	} else if (flags & MAP_SHARED) {
+		/*
+		 * mmap_region() will call shmem_zero_setup() to create a file,
+		 * so use shmem's get_unmapped_area in case it can be huge.
+		 * do_mmap_pgoff() will clear pgoff, so match alignment.
+		 */
+		pgoff = 0;
+		get_area = shmem_get_unmapped_area;
+	}
+
 	addr = get_area(file, addr, len, pgoff, flags);
 	if (IS_ERR_VALUE(addr))
 		return addr;
--- thpfs.orig/mm/shmem.c	2015-02-20 19:34:16.139982074 -0800
+++ thpfs/mm/shmem.c	2015-02-20 19:34:21.603969581 -0800
@@ -103,6 +103,8 @@ struct shmem_falloc {
 enum sgp_type {
 	SGP_READ,	/* don't exceed i_size, don't allocate page */
 	SGP_CACHE,	/* don't exceed i_size, may allocate page */
+			/* ordering assumed: those above don't check i_size */
+	SGP_TEAM,	/* may exceed i_size, may make team page Uptodate */
 	SGP_WRITE,	/* may exceed i_size, may allocate !Uptodate page */
 	SGP_FALLOC,	/* like SGP_WRITE, but make existing page Uptodate */
 };
@@ -421,6 +423,42 @@ static void shmem_added_to_hugeteam(stru
 	}
 }
 
+static int shmem_populate_hugeteam(struct inode *inode, struct page *head)
+{
+	struct page *page;
+	pgoff_t index;
+	int error;
+	int i;
+
+	/* We only have to do this once */
+	if (PageChecked(head))
+		return 0;
+
+	index = head->index;
+	for (i = 0; i < HPAGE_PMD_NR; i++, index++) {
+		if (!PageTeam(head))
+			return -EAGAIN;
+		if (PageChecked(head))
+			return 0;
+		/* Mark all pages dirty even when map is readonly, for now */
+		if (PageUptodate(head + i) && PageDirty(head + i))
+			continue;
+		error = shmem_getpage(inode, index, &page, SGP_TEAM, NULL);
+		if (error)
+			return error;
+		SetPageDirty(page);
+		unlock_page(page);
+		page_cache_release(page);
+		if (page != head + i)
+			return -EAGAIN;
+		cond_resched();
+	}
+
+	/* Now safe from the shrinker, but not yet from truncate */
+	SetPageChecked(head);
+	return 0;
+}
+
 static int shmem_disband_hugehead(struct page *head)
 {
 	struct address_space *mapping;
@@ -844,6 +882,12 @@ static inline void shmem_added_to_hugete
 {
 }
 
+static inline int shmem_populate_hugeteam(struct inode *inode,
+					  struct page *head)
+{
+	return -EAGAIN;
+}
+
 static inline unsigned long shmem_shrink_hugehole(struct shrinker *shrink,
 						  struct shrink_control *sc)
 {
@@ -1745,7 +1789,7 @@ repeat:
 		page = NULL;
 	}
 
-	if (sgp != SGP_WRITE && sgp != SGP_FALLOC &&
+	if (sgp <= SGP_CACHE &&
 	    ((loff_t)index << PAGE_CACHE_SHIFT) >= i_size_read(inode)) {
 		error = -EINVAL;
 		goto failed;
@@ -1936,7 +1980,7 @@ clear:
 	}
 
 	/* Perhaps the file has been truncated since we checked */
-	if (sgp != SGP_WRITE && sgp != SGP_FALLOC &&
+	if (sgp <= SGP_CACHE &&
 	    ((loff_t)index << PAGE_CACHE_SHIFT) >= i_size_read(inode)) {
 		error = -EINVAL;
 		alloced_huge = NULL;	/* already exposed: maybe now in use */
@@ -1992,9 +2036,12 @@ unlock:
 
 static int shmem_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 {
+	unsigned long addr = (unsigned long)vmf->virtual_address;
 	struct inode *inode = file_inode(vma->vm_file);
-	int error;
+	struct page *head;
 	int ret = VM_FAULT_LOCKED;
+	int once = 0;
+	int error;
 
 	/*
 	 * Trinity finds that probing a hole which tmpfs is punching can
@@ -2054,6 +2101,8 @@ static int shmem_fault(struct vm_area_st
 		spin_unlock(&inode->i_lock);
 	}
 
+single:
+	vmf->page = NULL;
 	error = shmem_getpage(inode, vmf->pgoff, &vmf->page, SGP_CACHE, &ret);
 	if (error)
 		return ((error == -ENOMEM) ? VM_FAULT_OOM : VM_FAULT_SIGBUS);
@@ -2062,7 +2111,142 @@ static int shmem_fault(struct vm_area_st
 		count_vm_event(PGMAJFAULT);
 		mem_cgroup_count_vm_event(vma->vm_mm, PGMAJFAULT);
 	}
-	return ret;
+
+	/*
+	 * Shall we map a huge page hugely?
+	 */
+	if (!IS_ENABLED(CONFIG_TRANSPARENT_HUGEPAGE))
+		return ret;
+	if (!(vmf->flags & FAULT_FLAG_MAY_HUGE))
+		return ret;
+	if (!PageTeam(vmf->page))
+		return ret;
+	if (once++)
+		return ret;
+	if (vma->vm_flags & VM_NONLINEAR)
+		return ret;
+	if (!(vma->vm_flags & VM_SHARED) && (vmf->flags & FAULT_FLAG_WRITE))
+		return ret;
+	if ((vma->vm_start-(vma->vm_pgoff<<PAGE_SHIFT)) & (HPAGE_PMD_SIZE-1))
+		return ret;
+	if (round_down(addr, HPAGE_PMD_SIZE) < vma->vm_start)
+		return ret;
+	if (round_up(addr + 1, HPAGE_PMD_SIZE) > vma->vm_end)
+		return ret;
+	/* But omit i_size check: allow up to huge page boundary */
+
+	head = team_head(vmf->page);
+	if (!get_page_unless_zero(head))
+		return ret;
+	if (!PageTeam(head)) {
+		page_cache_release(head);
+		return ret;
+	}
+
+	unlock_page(vmf->page);
+	page_cache_release(vmf->page);
+	if (shmem_populate_hugeteam(inode, head) < 0) {
+		page_cache_release(head);
+		goto single;
+	}
+	lock_page(head);
+	if (!PageTeam(head)) {
+		unlock_page(head);
+		page_cache_release(head);
+		goto single;
+	}
+
+	/* Now safe from truncation */
+	vmf->page = head;
+	return ret | VM_FAULT_HUGE;
+}
+
+unsigned long shmem_get_unmapped_area(struct file *file,
+				      unsigned long uaddr, unsigned long len,
+				      unsigned long pgoff, unsigned long flags)
+{
+	unsigned long (*get_area)(struct file *,
+		unsigned long, unsigned long, unsigned long, unsigned long);
+	unsigned long addr;
+	unsigned long offset;
+	unsigned long inflated_len;
+	unsigned long inflated_addr;
+	unsigned long inflated_offset;
+
+	if (len > TASK_SIZE)
+		return -ENOMEM;
+
+	get_area = current->mm->get_unmapped_area;
+	addr = get_area(file, uaddr, len, pgoff, flags);
+
+	if (!IS_ENABLED(CONFIG_TRANSPARENT_HUGEPAGE))
+		return addr;
+	if (IS_ERR_VALUE(addr))
+		return addr;
+	if (addr & ~PAGE_MASK)
+		return addr;
+	if (addr > TASK_SIZE - len)
+		return addr;
+
+	if (shmem_huge == SHMEM_HUGE_DENY)
+		return addr;
+	if (len < HPAGE_PMD_SIZE)
+		return addr;
+	if (flags & MAP_FIXED)
+		return addr;
+	/*
+	 * Our priority is to support MAP_SHARED mapped hugely;
+	 * and support MAP_PRIVATE mapped hugely too, until it is COWed.
+	 * But if caller specified an address hint, respect that as before.
+	 */
+	if (uaddr)
+		return addr;
+
+	if (shmem_huge != SHMEM_HUGE_FORCE) {
+		struct super_block *sb;
+
+		if (file) {
+			VM_BUG_ON(file->f_op != &shmem_file_operations);
+			sb = file_inode(file)->i_sb;
+		} else {
+			/*
+			 * Called directly from mm/mmap.c, or drivers/char/mem.c
+			 * for "/dev/zero", to create a shared anonymous object.
+			 */
+			if (IS_ERR(shm_mnt))
+				return addr;
+			sb = shm_mnt->mnt_sb;
+		}
+		if (!SHMEM_SB(sb)->huge)
+			return addr;
+	}
+
+	offset = (pgoff << PAGE_SHIFT) & (HPAGE_PMD_SIZE-1);
+	if (offset && offset + len < 2 * HPAGE_PMD_SIZE)
+		return addr;
+	if ((addr & (HPAGE_PMD_SIZE-1)) == offset)
+		return addr;
+
+	inflated_len = len + HPAGE_PMD_SIZE - PAGE_SIZE;
+	if (inflated_len > TASK_SIZE)
+		return addr;
+	if (inflated_len < len)
+		return addr;
+
+	inflated_addr = get_area(NULL, 0, inflated_len, 0, flags);
+	if (IS_ERR_VALUE(inflated_addr))
+		return addr;
+	if (inflated_addr & ~PAGE_MASK)
+		return addr;
+
+	inflated_offset = inflated_addr & (HPAGE_PMD_SIZE-1);
+	inflated_addr += offset - inflated_offset;
+	if (inflated_offset > offset)
+		inflated_addr += HPAGE_PMD_SIZE;
+
+	if (inflated_addr > TASK_SIZE - len)
+		return addr;
+	return inflated_addr;
 }
 
 #ifdef CONFIG_NUMA
@@ -3852,6 +4036,7 @@ static const struct address_space_operat
 
 static const struct file_operations shmem_file_operations = {
 	.mmap		= shmem_mmap,
+	.get_unmapped_area = shmem_get_unmapped_area,
 #ifdef CONFIG_TMPFS
 	.llseek		= shmem_file_llseek,
 	.read		= new_sync_read,
@@ -4063,6 +4248,13 @@ void shmem_unlock_mapping(struct address
 {
 }
 
+unsigned long shmem_get_unmapped_area(struct file *file,
+				      unsigned long addr, unsigned long len,
+				      unsigned long pgoff, unsigned long flags)
+{
+	return current->mm->get_unmapped_area(file, addr, len, pgoff, flags);
+}
+
 void shmem_truncate_range(struct inode *inode, loff_t lstart, loff_t lend)
 {
 	truncate_inode_pages_range(inode->i_mapping, lstart, lend);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
