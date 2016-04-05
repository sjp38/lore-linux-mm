Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 39EEB6B0291
	for <linux-mm@kvack.org>; Tue,  5 Apr 2016 17:21:25 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id zm5so18200189pac.0
        for <linux-mm@kvack.org>; Tue, 05 Apr 2016 14:21:25 -0700 (PDT)
Received: from mail-pa0-x229.google.com (mail-pa0-x229.google.com. [2607:f8b0:400e:c03::229])
        by mx.google.com with ESMTPS id 79si9615637pfm.61.2016.04.05.14.21.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Apr 2016 14:21:24 -0700 (PDT)
Received: by mail-pa0-x229.google.com with SMTP id td3so18125180pab.2
        for <linux-mm@kvack.org>; Tue, 05 Apr 2016 14:21:24 -0700 (PDT)
Date: Tue, 5 Apr 2016 14:21:21 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 07/31] huge tmpfs: get_unmapped_area align & fault supply
 huge page
In-Reply-To: <alpine.LSU.2.11.1604051403210.5965@eggly.anvils>
Message-ID: <alpine.LSU.2.11.1604051420110.5965@eggly.anvils>
References: <alpine.LSU.2.11.1604051403210.5965@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andres Lagar-Cavilla <andreslc@google.com>, Yang Shi <yang.shi@linaro.org>, Ning Qu <quning@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

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
 Documentation/filesystems/tmpfs.txt |    8 +
 drivers/char/mem.c                  |   23 ++
 include/linux/mm.h                  |    3 
 include/linux/shmem_fs.h            |    2 
 ipc/shm.c                           |    6 
 mm/mmap.c                           |   16 +-
 mm/shmem.c                          |  204 +++++++++++++++++++++++++-
 7 files changed, 253 insertions(+), 9 deletions(-)

--- a/Documentation/filesystems/tmpfs.txt
+++ b/Documentation/filesystems/tmpfs.txt
@@ -168,6 +168,14 @@ disband the team and free those holes; o
 and swap out the tmpfs pagecache.  Free holes are not charged to any
 memcg, and are counted in MemAvailable; but are not counted in MemFree.
 
+If a hugepage is mapped into a well-aligned huge extent of userspace (and
+huge tmpfs defaults to suitable alignment for any mapping large enough), any
+remaining free holes are first filled with zeroes to complete the hugepage.
+So, if the mmap length extends to a hugepage boundary beyond end of file,
+user accesses between end of file and that hugepage boundary will normally
+not fail with SIGBUS, as they would on a huge=0 filesystem - but will fail
+with SIGBUS if the kernel could only allocate small pages to back it.
+
 /proc/sys/vm/shmem_huge (intended for experimentation only):
 
 Default 0; write 1 to set tmpfs mount option huge=1 on the kernel's
--- a/drivers/char/mem.c
+++ b/drivers/char/mem.c
@@ -22,6 +22,7 @@
 #include <linux/device.h>
 #include <linux/highmem.h>
 #include <linux/backing-dev.h>
+#include <linux/shmem_fs.h>
 #include <linux/splice.h>
 #include <linux/pfn.h>
 #include <linux/export.h>
@@ -661,6 +662,27 @@ static int mmap_zero(struct file *file,
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
@@ -768,6 +790,7 @@ static const struct file_operations zero
 	.read_iter	= read_iter_zero,
 	.write_iter	= write_iter_zero,
 	.mmap		= mmap_zero,
+	.get_unmapped_area = get_unmapped_area_zero,
 #ifndef CONFIG_MMU
 	.mmap_capabilities = zero_mmap_capabilities,
 #endif
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -276,6 +276,7 @@ extern pgprot_t protection_map[16];
 #define FAULT_FLAG_USER		0x40	/* The fault originated in userspace */
 #define FAULT_FLAG_REMOTE	0x80	/* faulting for non current tsk/mm */
 #define FAULT_FLAG_INSTRUCTION  0x100	/* The fault was during an instruction fetch */
+#define FAULT_FLAG_MAY_HUGE	0x200	/* PT not alloced: could use huge pmd */
 
 /*
  * vm_fault is filled by the the pagefault handler and passed to the vma's
@@ -1079,7 +1080,7 @@ static inline void clear_page_pfmemalloc
 #define VM_FAULT_HWPOISON 0x0010	/* Hit poisoned small page */
 #define VM_FAULT_HWPOISON_LARGE 0x0020  /* Hit poisoned large page. Index encoded in upper bits */
 #define VM_FAULT_SIGSEGV 0x0040
-
+#define VM_FAULT_HUGE	0x0080	/* ->fault needs page installed as huge pmd */
 #define VM_FAULT_NOPAGE	0x0100	/* ->fault installed the pte, not return page */
 #define VM_FAULT_LOCKED	0x0200	/* ->fault locked the returned page */
 #define VM_FAULT_RETRY	0x0400	/* ->fault blocked, must retry */
--- a/include/linux/shmem_fs.h
+++ b/include/linux/shmem_fs.h
@@ -51,6 +51,8 @@ extern struct file *shmem_file_setup(con
 extern struct file *shmem_kernel_file_setup(const char *name, loff_t size,
 					    unsigned long flags);
 extern int shmem_zero_setup(struct vm_area_struct *);
+extern unsigned long shmem_get_unmapped_area(struct file *, unsigned long addr,
+		unsigned long len, unsigned long pgoff, unsigned long flags);
 extern int shmem_lock(struct file *file, int lock, struct user_struct *user);
 extern bool shmem_mapping(struct address_space *mapping);
 extern void shmem_unlock_mapping(struct address_space *mapping);
--- a/ipc/shm.c
+++ b/ipc/shm.c
@@ -476,13 +476,15 @@ static const struct file_operations shm_
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
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -25,6 +25,7 @@
 #include <linux/personality.h>
 #include <linux/security.h>
 #include <linux/hugetlb.h>
+#include <linux/shmem_fs.h>
 #include <linux/profile.h>
 #include <linux/export.h>
 #include <linux/mount.h>
@@ -1900,8 +1901,19 @@ get_unmapped_area(struct file *file, uns
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
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -104,6 +104,7 @@ struct shmem_falloc {
 enum sgp_type {
 	SGP_READ,	/* don't exceed i_size, don't allocate page */
 	SGP_CACHE,	/* don't exceed i_size, may allocate page */
+	SGP_TEAM,	/* may exceed i_size, may make team page Uptodate */
 	SGP_WRITE,	/* may exceed i_size, may allocate !Uptodate page */
 	SGP_FALLOC,	/* like SGP_WRITE, but make existing page Uptodate */
 };
@@ -417,6 +418,44 @@ static void shmem_added_to_hugeteam(stru
 	}
 }
 
+static int shmem_populate_hugeteam(struct inode *inode, struct page *head,
+				   struct vm_area_struct *vma)
+{
+	gfp_t gfp = mapping_gfp_mask(inode->i_mapping);
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
+		error = shmem_getpage_gfp(inode, index, &page, SGP_TEAM,
+					  gfp, vma->vm_mm, NULL);
+		if (error)
+			return error;
+		SetPageDirty(page);
+		unlock_page(page);
+		put_page(page);
+		if (page != head + i)
+			return -EAGAIN;
+		cond_resched();
+	}
+
+	/* Now safe from the shrinker, but not yet from truncate */
+	return 0;
+}
+
 static int shmem_disband_hugehead(struct page *head)
 {
 	struct address_space *mapping;
@@ -452,6 +491,7 @@ static int shmem_disband_hugehead(struct
 			head->mapping = NULL;
 
 		if (nr >= HPAGE_PMD_NR) {
+			ClearPageChecked(head);
 			__dec_zone_state(zone, NR_SHMEM_HUGEPAGES);
 			VM_BUG_ON(nr != HPAGE_PMD_NR);
 		} else if (nr) {
@@ -843,6 +883,12 @@ static inline void shmem_added_to_hugete
 {
 }
 
+static inline int shmem_populate_hugeteam(struct inode *inode,
+				struct page *head, struct vm_area_struct *vma)
+{
+	return -EAGAIN;
+}
+
 static inline unsigned long shmem_shrink_hugehole(struct shrinker *shrink,
 						  struct shrink_control *sc)
 {
@@ -1817,8 +1863,8 @@ static int shmem_replace_page(struct pag
  * vm. If we swap it in we mark it dirty since we also free the swap
  * entry since a page cannot live in both the swap and page cache.
  *
- * fault_mm and fault_type are only supplied by shmem_fault:
- * otherwise they are NULL.
+ * fault_mm and fault_type are only supplied by shmem_fault
+ * (or hugeteam population): otherwise they are NULL.
  */
 static int shmem_getpage_gfp(struct inode *inode, pgoff_t index,
 	struct page **pagep, enum sgp_type sgp, gfp_t gfp,
@@ -2095,10 +2141,13 @@ unlock:
 
 static int shmem_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 {
+	unsigned long addr = (unsigned long)vmf->virtual_address;
 	struct inode *inode = file_inode(vma->vm_file);
 	gfp_t gfp = mapping_gfp_mask(inode->i_mapping);
+	struct page *head;
+	int ret = 0;
+	int once = 0;
 	int error;
-	int ret = VM_FAULT_LOCKED;
 
 	/*
 	 * Trinity finds that probing a hole which tmpfs is punching can
@@ -2158,11 +2207,150 @@ static int shmem_fault(struct vm_area_st
 		spin_unlock(&inode->i_lock);
 	}
 
+single:
+	vmf->page = NULL;
 	error = shmem_getpage_gfp(inode, vmf->pgoff, &vmf->page, SGP_CACHE,
 				  gfp, vma->vm_mm, &ret);
 	if (error)
 		return ((error == -ENOMEM) ? VM_FAULT_OOM : VM_FAULT_SIGBUS);
-	return ret;
+	ret |= VM_FAULT_LOCKED;
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
+		put_page(head);
+		return ret;
+	}
+
+	ret &= ~VM_FAULT_LOCKED;
+	unlock_page(vmf->page);
+	put_page(vmf->page);
+	if (shmem_populate_hugeteam(inode, head, vma) < 0) {
+		put_page(head);
+		goto single;
+	}
+	lock_page(head);
+	if (!PageTeam(head)) {
+		unlock_page(head);
+		put_page(head);
+		goto single;
+	}
+	if (!PageChecked(head))
+		SetPageChecked(head);
+
+	/* Now safe from truncation */
+	vmf->page = head;
+	return ret | VM_FAULT_LOCKED | VM_FAULT_HUGE;
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
@@ -3905,6 +4093,7 @@ static const struct address_space_operat
 
 static const struct file_operations shmem_file_operations = {
 	.mmap		= shmem_mmap,
+	.get_unmapped_area = shmem_get_unmapped_area,
 #ifdef CONFIG_TMPFS
 	.llseek		= shmem_file_llseek,
 	.read_iter	= shmem_file_read_iter,
@@ -4112,6 +4301,13 @@ void shmem_unlock_mapping(struct address
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
