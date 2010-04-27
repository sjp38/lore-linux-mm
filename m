Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id B867A6B01E3
	for <linux-mm@kvack.org>; Tue, 27 Apr 2010 02:32:46 -0400 (EDT)
Subject: [RFC/PATCH] mm: Use vm_flags_t type for VMA flags
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 27 Apr 2010 16:32:25 +1000
Message-ID: <1272349945.24542.5.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

This patch introduces the vm_flags_t type, which by default remains
an unsigned long, but can be overridden by architectures.

This updates the core code to use it everywhere I could spot
(hopefully I didn't miss to many places) and arch/powerpc. I
have not modified other arch instances where it could be used
as unless those archs change to a different type, their existing
use of long or int will continue to work fine.

The goal here is to allow archs like powerpc to define additional
flags, for things like mapping attributes (and eventually make it
easier to turn it into a u64 globally if we ever need more flags
in the VM).

Subsequent patches will move VM_SAO (which is powerpc specific) to
the arch flags and introduce a new powerpc specific flag for little
endian mappings. This will free one flag bit for future use by the core,
thus delaying a bit more the dreaded switch of everybody to a 64-bit
vm_flags :-)

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---

So let's discuss the details of that one before I get the rest out.

There's a suggestion by Nick to make the VM flags themselves bit
numbers (though we still need to keep the current mask definitions,
but they can be based on the bit numbers), which would allow more
easily for the core to define something like a VMF_end flag,
representing the last bit used by the core, so that arch flags can
be defined as VMF_end + N.

What do you guys thing ? Worth bothering ?

I also avoided touching archs for now, they will work as long as
the type isn't changed. Some archs like ARM seem to have hand
crafted asm that reads VM flags so a change of default size
will need those archs to adapt. 

 arch/powerpc/include/asm/mman.h              |    2 +-
 drivers/infiniband/hw/ipath/ipath_file_ops.c |    6 +-
 fs/binfmt_elf_fdpic.c                        |   21 ++++---
 fs/exec.c                                    |    2 +-
 fs/proc/nommu.c                              |    3 +-
 fs/proc/task_nommu.c                         |    3 +-
 include/linux/backing-dev.h                  |    7 --
 include/linux/hugetlb.h                      |    2 +-
 include/linux/ksm.h                          |    8 +-
 include/linux/mm.h                           |   87 +++++++++++++------------
 include/linux/mm_types.h                     |   15 +++-
 include/linux/mman.h                         |    6 +-
 include/linux/rmap.h                         |    6 +-
 include/linux/shmem_fs.h                     |    2 +-
 mm/fremap.c                                  |    2 +-
 mm/hugetlb.c                                 |    2 +-
 mm/ksm.c                                     |    4 +-
 mm/madvise.c                                 |    2 +-
 mm/memory.c                                  |    9 ++-
 mm/mlock.c                                   |    4 +-
 mm/mmap.c                                    |   30 +++++-----
 mm/mprotect.c                                |    7 +-
 mm/mremap.c                                  |    2 +-
 mm/nommu.c                                   |   17 +++---
 mm/rmap.c                                    |    8 +-
 mm/shmem.c                                   |    8 +-
 mm/vmscan.c                                  |    4 +-
 27 files changed, 140 insertions(+), 129 deletions(-)

diff --git a/arch/powerpc/include/asm/mman.h b/arch/powerpc/include/asm/mman.h
index d4a7f64..451de1c 100644
--- a/arch/powerpc/include/asm/mman.h
+++ b/arch/powerpc/include/asm/mman.h
@@ -44,7 +44,7 @@ static inline unsigned long arch_calc_vm_prot_bits(unsigned long prot)
 }
 #define arch_calc_vm_prot_bits(prot) arch_calc_vm_prot_bits(prot)
 
-static inline pgprot_t arch_vm_get_page_prot(unsigned long vm_flags)
+static inline pgprot_t arch_vm_get_page_prot(vm_flags_t vm_flags)
 {
 	return (vm_flags & VM_SAO) ? __pgprot(_PAGE_SAO) : __pgprot(0);
 }
diff --git a/drivers/infiniband/hw/ipath/ipath_file_ops.c b/drivers/infiniband/hw/ipath/ipath_file_ops.c
index 9c5c66d..35a3374 100644
--- a/drivers/infiniband/hw/ipath/ipath_file_ops.c
+++ b/drivers/infiniband/hw/ipath/ipath_file_ops.c
@@ -1113,7 +1113,8 @@ static int mmap_rcvegrbufs(struct vm_area_struct *vma,
 
 	if (vma->vm_flags & VM_WRITE) {
 		dev_info(&dd->pcidev->dev, "Can't map eager buffers as "
-			 "writable (flags=%lx)\n", vma->vm_flags);
+			 "writable (flags=%llx)\n",
+			 (unsigned long long)vma->vm_flags);
 		ret = -EPERM;
 		goto bail;
 	}
@@ -1202,7 +1203,8 @@ static int mmap_kvaddr(struct vm_area_struct *vma, u64 pgaddr,
                 if (vma->vm_flags & VM_WRITE) {
                         dev_info(&dd->pcidev->dev,
                                  "Can't map eager buffers as "
-                                 "writable (flags=%lx)\n", vma->vm_flags);
+                                 "writable (flags=%llx)\n",
+				 (unsigned long long)vma->vm_flags);
                         ret = -EPERM;
                         goto bail;
                 }
diff --git a/fs/binfmt_elf_fdpic.c b/fs/binfmt_elf_fdpic.c
index 7ab23e0..9e4878c 100644
--- a/fs/binfmt_elf_fdpic.c
+++ b/fs/binfmt_elf_fdpic.c
@@ -1229,7 +1229,8 @@ static int maydump(struct vm_area_struct *vma, unsigned long mm_flags)
 
 	/* Do not dump I/O mapped devices or special mappings */
 	if (vma->vm_flags & (VM_IO | VM_RESERVED)) {
-		kdcore("%08lx: %08lx: no (IO)", vma->vm_start, vma->vm_flags);
+		kdcore("%08lx: %08llx: no (IO)", vma->vm_start,
+		       (unsigned long long)vma->vm_flags);
 		return 0;
 	}
 
@@ -1237,7 +1238,8 @@ static int maydump(struct vm_area_struct *vma, unsigned long mm_flags)
 	 * them either. "dump_write()" can't handle it anyway.
 	 */
 	if (!(vma->vm_flags & VM_READ)) {
-		kdcore("%08lx: %08lx: no (!read)", vma->vm_start, vma->vm_flags);
+		kdcore("%08lx: %08llx: no (!read)", vma->vm_start,
+		       (unsigned long long)vma->vm_flags);
 		return 0;
 	}
 
@@ -1245,14 +1247,15 @@ static int maydump(struct vm_area_struct *vma, unsigned long mm_flags)
 	if (vma->vm_flags & VM_SHARED) {
 		if (vma->vm_file->f_path.dentry->d_inode->i_nlink == 0) {
 			dump_ok = test_bit(MMF_DUMP_ANON_SHARED, &mm_flags);
-			kdcore("%08lx: %08lx: %s (share)", vma->vm_start,
-			       vma->vm_flags, dump_ok ? "yes" : "no");
+			kdcore("%08lx: %08llx: %s (share)", vma->vm_start,
+			       (unsigned long long)vma->vm_flags,
+			       dump_ok ? "yes" : "no");
 			return dump_ok;
 		}
 
 		dump_ok = test_bit(MMF_DUMP_MAPPED_SHARED, &mm_flags);
-		kdcore("%08lx: %08lx: %s (share)", vma->vm_start,
-		       vma->vm_flags, dump_ok ? "yes" : "no");
+		kdcore("%08lx: %08llx: %s (share)", vma->vm_start,
+		       (unsigned long long)vma->vm_flags, dump_ok ? "yes" : "no");
 		return dump_ok;
 	}
 
@@ -1260,14 +1263,14 @@ static int maydump(struct vm_area_struct *vma, unsigned long mm_flags)
 	/* By default, if it hasn't been written to, don't write it out */
 	if (!vma->anon_vma) {
 		dump_ok = test_bit(MMF_DUMP_MAPPED_PRIVATE, &mm_flags);
-		kdcore("%08lx: %08lx: %s (!anon)", vma->vm_start,
-		       vma->vm_flags, dump_ok ? "yes" : "no");
+		kdcore("%08lx: %08llx: %s (!anon)", vma->vm_start,
+		       (unsigned long long)vma->vm_flags, dump_ok ? "yes" : "no");
 		return dump_ok;
 	}
 #endif
 
 	dump_ok = test_bit(MMF_DUMP_ANON_PRIVATE, &mm_flags);
-	kdcore("%08lx: %08lx: %s", vma->vm_start, vma->vm_flags,
+	kdcore("%08lx: %08llx: %s", vma->vm_start, (unsigned long long)vma->vm_flags,
 	       dump_ok ? "yes" : "no");
 	return dump_ok;
 }
diff --git a/fs/exec.c b/fs/exec.c
index 49cdaa1..94c45db 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -569,7 +569,7 @@ int setup_arg_pages(struct linux_binprm *bprm,
 	struct mm_struct *mm = current->mm;
 	struct vm_area_struct *vma = bprm->vma;
 	struct vm_area_struct *prev = NULL;
-	unsigned long vm_flags;
+	vm_flags_t vm_flags;
 	unsigned long stack_base;
 	unsigned long stack_size;
 	unsigned long stack_expand;
diff --git a/fs/proc/nommu.c b/fs/proc/nommu.c
index b1822dd..461e46b 100644
--- a/fs/proc/nommu.c
+++ b/fs/proc/nommu.c
@@ -39,7 +39,8 @@ static int nommu_region_show(struct seq_file *m, struct vm_region *region)
 	unsigned long ino = 0;
 	struct file *file;
 	dev_t dev = 0;
-	int flags, len;
+	vm_flags_t flags;
+	int len;
 
 	flags = region->vm_flags;
 	file = region->vm_file;
diff --git a/fs/proc/task_nommu.c b/fs/proc/task_nommu.c
index 46d4b5d..510c093 100644
--- a/fs/proc/task_nommu.c
+++ b/fs/proc/task_nommu.c
@@ -130,7 +130,8 @@ static int nommu_vma_show(struct seq_file *m, struct vm_area_struct *vma)
 	unsigned long ino = 0;
 	struct file *file;
 	dev_t dev = 0;
-	int flags, len;
+	vm_flags_t flags;
+	int len;
 	unsigned long long pgoff = 0;
 
 	flags = vma->vm_flags;
diff --git a/include/linux/backing-dev.h b/include/linux/backing-dev.h
index fcbc26a..247b372 100644
--- a/include/linux/backing-dev.h
+++ b/include/linux/backing-dev.h
@@ -238,13 +238,6 @@ int bdi_set_max_ratio(struct backing_dev_info *bdi, unsigned int max_ratio);
 #define BDI_CAP_NO_ACCT_AND_WRITEBACK \
 	(BDI_CAP_NO_WRITEBACK | BDI_CAP_NO_ACCT_DIRTY | BDI_CAP_NO_ACCT_WB)
 
-#if defined(VM_MAYREAD) && \
-	(BDI_CAP_READ_MAP != VM_MAYREAD || \
-	 BDI_CAP_WRITE_MAP != VM_MAYWRITE || \
-	 BDI_CAP_EXEC_MAP != VM_MAYEXEC)
-#error please change backing_dev_info::capabilities flags
-#endif
-
 extern struct backing_dev_info default_backing_dev_info;
 void default_unplug_io_fn(struct backing_dev_info *bdi, struct page *page);
 
diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 78b4bc6..0fe1469 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -45,7 +45,7 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 			unsigned long address, unsigned int flags);
 int hugetlb_reserve_pages(struct inode *inode, long from, long to,
 						struct vm_area_struct *vma,
-						int acctflags);
+						vm_flags_t acctflags);
 void hugetlb_unreserve_pages(struct inode *inode, long offset, long freed);
 
 extern unsigned long hugepages_treat_as_movable;
diff --git a/include/linux/ksm.h b/include/linux/ksm.h
index 43bdab7..b8ca276 100644
--- a/include/linux/ksm.h
+++ b/include/linux/ksm.h
@@ -18,7 +18,7 @@ struct mem_cgroup;
 
 #ifdef CONFIG_KSM
 int ksm_madvise(struct vm_area_struct *vma, unsigned long start,
-		unsigned long end, int advice, unsigned long *vm_flags);
+		unsigned long end, int advice, vm_flags_t *vm_flags);
 int __ksm_enter(struct mm_struct *mm);
 void __ksm_exit(struct mm_struct *mm);
 
@@ -86,7 +86,7 @@ static inline struct page *ksm_might_need_to_copy(struct page *page,
 }
 
 int page_referenced_ksm(struct page *page,
-			struct mem_cgroup *memcg, unsigned long *vm_flags);
+			struct mem_cgroup *memcg, vm_flags_t *vm_flags);
 int try_to_unmap_ksm(struct page *page, enum ttu_flags flags);
 int rmap_walk_ksm(struct page *page, int (*rmap_one)(struct page *,
 		  struct vm_area_struct *, unsigned long, void *), void *arg);
@@ -110,7 +110,7 @@ static inline int PageKsm(struct page *page)
 
 #ifdef CONFIG_MMU
 static inline int ksm_madvise(struct vm_area_struct *vma, unsigned long start,
-		unsigned long end, int advice, unsigned long *vm_flags)
+		unsigned long end, int advice, vm_flags_t *vm_flags)
 {
 	return 0;
 }
@@ -122,7 +122,7 @@ static inline struct page *ksm_might_need_to_copy(struct page *page,
 }
 
 static inline int page_referenced_ksm(struct page *page,
-			struct mem_cgroup *memcg, unsigned long *vm_flags)
+			struct mem_cgroup *memcg, vm_flags_t *vm_flags)
 {
 	return 0;
 }
diff --git a/include/linux/mm.h b/include/linux/mm.h
index e70f21b..afc181b 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -66,46 +66,49 @@ extern unsigned int kobjsize(const void *objp);
 /*
  * vm_flags in vm_area_struct, see mm_types.h.
  */
-#define VM_READ		0x00000001	/* currently active flags */
-#define VM_WRITE	0x00000002
-#define VM_EXEC		0x00000004
-#define VM_SHARED	0x00000008
+
+#define _VMF(f)		((vm_flags_t)f)
+
+#define VM_READ		_VMF(0x00000001)	/* currently active flags */
+#define VM_WRITE	_VMF(0x00000002)
+#define VM_EXEC		_VMF(0x00000004)
+#define VM_SHARED	_VMF(0x00000008)
 
 /* mprotect() hardcodes VM_MAYREAD >> 4 == VM_READ, and so for r/w/x bits. */
-#define VM_MAYREAD	0x00000010	/* limits for mprotect() etc */
-#define VM_MAYWRITE	0x00000020
-#define VM_MAYEXEC	0x00000040
-#define VM_MAYSHARE	0x00000080
-
-#define VM_GROWSDOWN	0x00000100	/* general info on the segment */
-#define VM_GROWSUP	0x00000200
-#define VM_PFNMAP	0x00000400	/* Page-ranges managed without "struct page", just pure PFN */
-#define VM_DENYWRITE	0x00000800	/* ETXTBSY on write attempts.. */
-
-#define VM_EXECUTABLE	0x00001000
-#define VM_LOCKED	0x00002000
-#define VM_IO           0x00004000	/* Memory mapped I/O or similar */
-
-					/* Used by sys_madvise() */
-#define VM_SEQ_READ	0x00008000	/* App will access data sequentially */
-#define VM_RAND_READ	0x00010000	/* App will not benefit from clustered reads */
-
-#define VM_DONTCOPY	0x00020000      /* Do not copy this vma on fork */
-#define VM_DONTEXPAND	0x00040000	/* Cannot expand with mremap() */
-#define VM_RESERVED	0x00080000	/* Count as reserved_vm like IO */
-#define VM_ACCOUNT	0x00100000	/* Is a VM accounted object */
-#define VM_NORESERVE	0x00200000	/* should the VM suppress accounting */
-#define VM_HUGETLB	0x00400000	/* Huge TLB Page VM */
-#define VM_NONLINEAR	0x00800000	/* Is non-linear (remap_file_pages) */
-#define VM_MAPPED_COPY	0x01000000	/* T if mapped copy of data (nommu mmap) */
-#define VM_INSERTPAGE	0x02000000	/* The vma has had "vm_insert_page()" done on it */
-#define VM_ALWAYSDUMP	0x04000000	/* Always include in core dumps */
-
-#define VM_CAN_NONLINEAR 0x08000000	/* Has ->fault & does nonlinear pages */
-#define VM_MIXEDMAP	0x10000000	/* Can contain "struct page" and pure PFN pages */
-#define VM_SAO		0x20000000	/* Strong Access Ordering (powerpc) */
-#define VM_PFN_AT_MMAP	0x40000000	/* PFNMAP vma that is fully mapped at mmap time */
-#define VM_MERGEABLE	0x80000000	/* KSM may merge identical pages */
+#define VM_MAYREAD	_VMF(0x00000010)	/* limits for mprotect() etc */
+#define VM_MAYWRITE	_VMF(0x00000020)
+#define VM_MAYEXEC	_VMF(0x00000040)
+#define VM_MAYSHARE	_VMF(0x00000080)
+
+#define VM_GROWSDOWN	_VMF(0x00000100)	/* general info on the segment */
+#define VM_GROWSUP	_VMF(0x00000200)
+#define VM_PFNMAP	_VMF(0x00000400)	/* Page-ranges managed without "struct page", just pure PFN */
+#define VM_DENYWRITE	_VMF(0x00000800)	/* ETXTBSY on write attempts.. */
+
+#define VM_EXECUTABLE	_VMF(0x00001000)
+#define VM_LOCKED	_VMF(0x00002000)
+#define VM_IO           _VMF(0x00004000)	/* Memory mapped I/O or similar */
+
+/* Used by sys_madvise() */
+#define VM_SEQ_READ	_VMF(0x00008000)	/* App will access data sequentially */
+#define VM_RAND_READ	_VMF(0x00010000)	/* App will not benefit from clustered reads */
+
+#define VM_DONTCOPY	_VMF(0x00020000)      /* Do not copy this vma on fork */
+#define VM_DONTEXPAND	_VMF(0x00040000)	/* Cannot expand with mremap() */
+#define VM_RESERVED	_VMF(0x00080000)	/* Count as reserved_vm like IO */
+#define VM_ACCOUNT	_VMF(0x00100000)	/* Is a VM accounted object */
+#define VM_NORESERVE	_VMF(0x00200000)	/* should the VM suppress accounting */
+#define VM_HUGETLB	_VMF(0x00400000)	/* Huge TLB Page VM */
+#define VM_NONLINEAR	_VMF(0x00800000)	/* Is non-linear (remap_file_pages) */
+#define VM_MAPPED_COPY	_VMF(0x01000000)	/* T if mapped copy of data (nommu mmap) */
+#define VM_INSERTPAGE	_VMF(0x02000000)	/* The vma has had "vm_insert_page()" done on it */
+#define VM_ALWAYSDUMP	_VMF(0x04000000)	/* Always include in core dumps */
+
+#define VM_CAN_NONLINEAR _VMF(0x08000000)	/* Has ->fault & does nonlinear pages */
+#define VM_MIXEDMAP	_VMF(0x10000000)	/* Can contain "struct page" and pure PFN pages */
+#define VM_SAO		_VMF(0x20000000)	/* Strong Access Ordering (powerpc) */
+#define VM_PFN_AT_MMAP	_VMF(0x40000000)	/* PFNMAP vma that is fully mapped at mmap time */
+#define VM_MERGEABLE	_VMF(0x80000000)	/* KSM may merge identical pages */
 
 #ifndef VM_STACK_DEFAULT_FLAGS		/* arch can override this */
 #define VM_STACK_DEFAULT_FLAGS VM_DATA_DEFAULT_FLAGS
@@ -863,7 +866,7 @@ extern unsigned long do_mremap(unsigned long addr,
 			       unsigned long flags, unsigned long new_addr);
 extern int mprotect_fixup(struct vm_area_struct *vma,
 			  struct vm_area_struct **pprev, unsigned long start,
-			  unsigned long end, unsigned long newflags);
+			  unsigned long end, vm_flags_t newflags);
 
 /*
  * doesn't attempt to fault and will return short.
@@ -1226,7 +1229,7 @@ extern int vma_adjust(struct vm_area_struct *vma, unsigned long start,
 	unsigned long end, pgoff_t pgoff, struct vm_area_struct *insert);
 extern struct vm_area_struct *vma_merge(struct mm_struct *,
 	struct vm_area_struct *prev, unsigned long addr, unsigned long end,
-	unsigned long vm_flags, struct anon_vma *, struct file *, pgoff_t,
+	vm_flags_t vm_flags, struct anon_vma *, struct file *, pgoff_t,
 	struct mempolicy *);
 extern struct anon_vma *find_mergeable_anon_vma(struct vm_area_struct *);
 extern int split_vma(struct mm_struct *,
@@ -1266,7 +1269,7 @@ extern unsigned long do_mmap_pgoff(struct file *file, unsigned long addr,
 	unsigned long flag, unsigned long pgoff);
 extern unsigned long mmap_region(struct file *file, unsigned long addr,
 	unsigned long len, unsigned long flags,
-	unsigned int vm_flags, unsigned long pgoff);
+	vm_flags_t vm_flags, unsigned long pgoff);
 
 static inline unsigned long do_mmap(struct file *file, unsigned long addr,
 	unsigned long len, unsigned long prot,
@@ -1352,7 +1355,7 @@ static inline unsigned long vma_pages(struct vm_area_struct *vma)
 	return (vma->vm_end - vma->vm_start) >> PAGE_SHIFT;
 }
 
-pgprot_t vm_get_page_prot(unsigned long vm_flags);
+pgprot_t vm_get_page_prot(vm_flags_t vm_flags);
 struct vm_area_struct *find_extend_vma(struct mm_struct *, unsigned long addr);
 int remap_pfn_range(struct vm_area_struct *, unsigned long addr,
 			unsigned long pfn, unsigned long size, pgprot_t);
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index b8bb9a6..eba80bd 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -24,6 +24,12 @@ struct address_space;
 
 #define USE_SPLIT_PTLOCKS	(NR_CPUS >= CONFIG_SPLIT_PTLOCK_CPUS)
 
+#ifndef vm_flags_t
+#define vm_flags_t vm_flags_t
+typedef unsigned long vm_flags_t;
+#define ARCH_VMA_FLAGS_MASK	0
+#endif
+
 /*
  * Each physical page in the system has a struct page associated with
  * it to keep track of whatever it is we are using the page for at the
@@ -109,7 +115,7 @@ struct page {
  */
 struct vm_region {
 	struct rb_node	vm_rb;		/* link in global region tree */
-	unsigned long	vm_flags;	/* VMA vm_flags */
+	vm_flags_t	vm_flags;	/* VMA vm_flags */
 	unsigned long	vm_start;	/* start address of region */
 	unsigned long	vm_end;		/* region initialised to here */
 	unsigned long	vm_top;		/* region allocated to here */
@@ -121,6 +127,7 @@ struct vm_region {
 						* this region */
 };
 
+
 /*
  * This struct defines a memory VMM memory area. There is one of these
  * per VM-area/task.  A VM area is any part of the process virtual memory
@@ -137,7 +144,7 @@ struct vm_area_struct {
 	struct vm_area_struct *vm_next;
 
 	pgprot_t vm_page_prot;		/* Access permissions of this VMA. */
-	unsigned long vm_flags;		/* Flags, see mm.h. */
+	vm_flags_t vm_flags;		/* Flags, see mm.h. */
 
 	struct rb_node vm_rb;
 
@@ -250,11 +257,11 @@ struct mm_struct {
 	unsigned long hiwater_vm;	/* High-water virtual memory usage */
 
 	unsigned long total_vm, locked_vm, shared_vm, exec_vm;
-	unsigned long stack_vm, reserved_vm, def_flags, nr_ptes;
+	unsigned long stack_vm, reserved_vm, nr_ptes;
 	unsigned long start_code, end_code, start_data, end_data;
 	unsigned long start_brk, brk, start_stack;
 	unsigned long arg_start, arg_end, env_start, env_end;
-
+	vm_flags_t def_flags;
 	unsigned long saved_auxv[AT_VECTOR_SIZE]; /* for /proc/PID/auxv */
 
 	/*
diff --git a/include/linux/mman.h b/include/linux/mman.h
index 9872d6c..b2e6b86 100644
--- a/include/linux/mman.h
+++ b/include/linux/mman.h
@@ -69,8 +69,7 @@ static inline int arch_validate_prot(unsigned long prot)
 /*
  * Combine the mmap "prot" argument into "vm_flags" used internally.
  */
-static inline unsigned long
-calc_vm_prot_bits(unsigned long prot)
+static inline vm_flags_t calc_vm_prot_bits(unsigned long prot)
 {
 	return _calc_vm_trans(prot, PROT_READ,  VM_READ ) |
 	       _calc_vm_trans(prot, PROT_WRITE, VM_WRITE) |
@@ -81,8 +80,7 @@ calc_vm_prot_bits(unsigned long prot)
 /*
  * Combine the mmap "flags" argument into "vm_flags" used internally.
  */
-static inline unsigned long
-calc_vm_flag_bits(unsigned long flags)
+static inline vm_flags_t calc_vm_flag_bits(unsigned long flags)
 {
 	return _calc_vm_trans(flags, MAP_GROWSDOWN,  VM_GROWSDOWN ) |
 	       _calc_vm_trans(flags, MAP_DENYWRITE,  VM_DENYWRITE ) |
diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index d25bd22..b0c7380 100644
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -140,9 +140,9 @@ static inline void page_dup_rmap(struct page *page)
  * Called from mm/vmscan.c to handle paging out
  */
 int page_referenced(struct page *, int is_locked,
-			struct mem_cgroup *cnt, unsigned long *vm_flags);
+			struct mem_cgroup *cnt, vm_flags_t *vm_flags);
 int page_referenced_one(struct page *, struct vm_area_struct *,
-	unsigned long address, unsigned int *mapcount, unsigned long *vm_flags);
+	unsigned long address, unsigned int *mapcount, vm_flags_t *vm_flags);
 
 enum ttu_flags {
 	TTU_UNMAP = 0,			/* unmap mode */
@@ -206,7 +206,7 @@ int rmap_walk(struct page *page, int (*rmap_one)(struct page *,
 
 static inline int page_referenced(struct page *page, int is_locked,
 				  struct mem_cgroup *cnt,
-				  unsigned long *vm_flags)
+				  vm_flags_t *vm_flags)
 {
 	*vm_flags = 0;
 	return 0;
diff --git a/include/linux/shmem_fs.h b/include/linux/shmem_fs.h
index e164291..6d7e4f0 100644
--- a/include/linux/shmem_fs.h
+++ b/include/linux/shmem_fs.h
@@ -10,7 +10,7 @@
 
 struct shmem_inode_info {
 	spinlock_t		lock;
-	unsigned long		flags;
+	vm_flags_t		flags;
 	unsigned long		alloced;	/* data pages alloced to file */
 	unsigned long		swapped;	/* subtotal assigned to swap */
 	unsigned long		next_index;	/* highest alloced index + 1 */
diff --git a/mm/fremap.c b/mm/fremap.c
index 46f5dac..37ca02d 100644
--- a/mm/fremap.c
+++ b/mm/fremap.c
@@ -221,7 +221,7 @@ SYSCALL_DEFINE5(remap_file_pages, unsigned long, start, unsigned long, size,
 		/*
 		 * drop PG_Mlocked flag for over-mapped range
 		 */
-		unsigned int saved_flags = vma->vm_flags;
+		vm_flags_t saved_flags = vma->vm_flags;
 		munlock_vma_pages_range(vma, start, start + size);
 		vma->vm_flags = saved_flags;
 	}
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 6034dc9..9ca258e 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -2701,7 +2701,7 @@ void hugetlb_change_protection(struct vm_area_struct *vma,
 int hugetlb_reserve_pages(struct inode *inode,
 					long from, long to,
 					struct vm_area_struct *vma,
-					int acctflag)
+					vm_flags_t acctflag)
 {
 	long ret, chg;
 	struct hstate *h = hstate_inode(inode);
diff --git a/mm/ksm.c b/mm/ksm.c
index 8cdfc2a..bc523c1 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -1407,7 +1407,7 @@ static int ksm_scan_thread(void *nothing)
 }
 
 int ksm_madvise(struct vm_area_struct *vma, unsigned long start,
-		unsigned long end, int advice, unsigned long *vm_flags)
+		unsigned long end, int advice, vm_flags_t *vm_flags)
 {
 	struct mm_struct *mm = vma->vm_mm;
 	int err;
@@ -1545,7 +1545,7 @@ struct page *ksm_does_need_to_copy(struct page *page,
 }
 
 int page_referenced_ksm(struct page *page, struct mem_cgroup *memcg,
-			unsigned long *vm_flags)
+			vm_flags_t *vm_flags)
 {
 	struct stable_node *stable_node;
 	struct rmap_item *rmap_item;
diff --git a/mm/madvise.c b/mm/madvise.c
index 319528b..b5d8044 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -43,7 +43,7 @@ static long madvise_behavior(struct vm_area_struct * vma,
 	struct mm_struct * mm = vma->vm_mm;
 	int error = 0;
 	pgoff_t pgoff;
-	unsigned long new_flags = vma->vm_flags;
+	vm_flags_t new_flags = vma->vm_flags;
 
 	switch (behavior) {
 	case MADV_NORMAL:
diff --git a/mm/memory.c b/mm/memory.c
index 1d2ea39..5fa2624 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -514,8 +514,9 @@ static void print_bad_pte(struct vm_area_struct *vma, unsigned long addr,
 	if (page)
 		dump_page(page);
 	printk(KERN_ALERT
-		"addr:%p vm_flags:%08lx anon_vma:%p mapping:%p index:%lx\n",
-		(void *)addr, vma->vm_flags, vma->anon_vma, mapping, index);
+		"addr:%p vm_flags:%08llx anon_vma:%p mapping:%p index:%lx\n",
+	       (void *)addr, (unsigned long long)vma->vm_flags,
+	       vma->anon_vma, mapping, index);
 	/*
 	 * Choose text because data symbols depend on CONFIG_KALLSYMS_ALL=y
 	 */
@@ -654,7 +655,7 @@ copy_one_pte(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 		pte_t *dst_pte, pte_t *src_pte, struct vm_area_struct *vma,
 		unsigned long addr, int *rss)
 {
-	unsigned long vm_flags = vma->vm_flags;
+	vm_flags_t vm_flags = vma->vm_flags;
 	pte_t pte = *src_pte;
 	struct page *page;
 
@@ -1338,7 +1339,7 @@ int __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 		     struct page **pages, struct vm_area_struct **vmas)
 {
 	int i;
-	unsigned long vm_flags;
+	vm_flags_t vm_flags;
 
 	if (nr_pages <= 0)
 		return 0;
diff --git a/mm/mlock.c b/mm/mlock.c
index 8f4e2df..f21ead6 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -351,7 +351,7 @@ void munlock_vma_pages_range(struct vm_area_struct *vma,
  * For vmas that pass the filters, merge/split as appropriate.
  */
 static int mlock_fixup(struct vm_area_struct *vma, struct vm_area_struct **prev,
-	unsigned long start, unsigned long end, unsigned int newflags)
+		       unsigned long start, unsigned long end, vm_flags_t newflags)
 {
 	struct mm_struct *mm = vma->vm_mm;
 	pgoff_t pgoff;
@@ -440,7 +440,7 @@ static int do_mlock(unsigned long start, size_t len, int on)
 		prev = vma;
 
 	for (nstart = start ; ; ) {
-		unsigned int newflags;
+		vm_flags_t newflags;
 
 		/* Here we know that  vma->vm_start <= nstart < vma->vm_end. */
 
diff --git a/mm/mmap.c b/mm/mmap.c
index 75557c6..3a96c2b 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -74,7 +74,7 @@ pgprot_t protection_map[16] = {
 	__S000, __S001, __S010, __S011, __S100, __S101, __S110, __S111
 };
 
-pgprot_t vm_get_page_prot(unsigned long vm_flags)
+pgprot_t vm_get_page_prot(vm_flags_t vm_flags)
 {
 	return __pgprot(pgprot_val(protection_map[vm_flags &
 				(VM_READ|VM_WRITE|VM_EXEC|VM_SHARED)]) |
@@ -660,7 +660,7 @@ again:			remove_next = 1 + (end > next->vm_end);
  * per-vma resources, so we don't attempt to merge those.
  */
 static inline int is_mergeable_vma(struct vm_area_struct *vma,
-			struct file *file, unsigned long vm_flags)
+			struct file *file, vm_flags_t vm_flags)
 {
 	/* VM_CAN_NONLINEAR may get set later by f_op->mmap() */
 	if ((vma->vm_flags ^ vm_flags) & ~VM_CAN_NONLINEAR)
@@ -690,7 +690,7 @@ static inline int is_mergeable_anon_vma(struct anon_vma *anon_vma1,
  * wrap, nor mmaps which cover the final page at index -1UL.
  */
 static int
-can_vma_merge_before(struct vm_area_struct *vma, unsigned long vm_flags,
+can_vma_merge_before(struct vm_area_struct *vma, vm_flags_t vm_flags,
 	struct anon_vma *anon_vma, struct file *file, pgoff_t vm_pgoff)
 {
 	if (is_mergeable_vma(vma, file, vm_flags) &&
@@ -709,7 +709,7 @@ can_vma_merge_before(struct vm_area_struct *vma, unsigned long vm_flags,
  * anon_vmas, nor if same anon_vma is assigned but offsets incompatible.
  */
 static int
-can_vma_merge_after(struct vm_area_struct *vma, unsigned long vm_flags,
+can_vma_merge_after(struct vm_area_struct *vma, vm_flags_t vm_flags,
 	struct anon_vma *anon_vma, struct file *file, pgoff_t vm_pgoff)
 {
 	if (is_mergeable_vma(vma, file, vm_flags) &&
@@ -753,7 +753,7 @@ can_vma_merge_after(struct vm_area_struct *vma, unsigned long vm_flags,
  */
 struct vm_area_struct *vma_merge(struct mm_struct *mm,
 			struct vm_area_struct *prev, unsigned long addr,
-			unsigned long end, unsigned long vm_flags,
+			unsigned long end, vm_flags_t vm_flags,
 		     	struct anon_vma *anon_vma, struct file *file,
 			pgoff_t pgoff, struct mempolicy *policy)
 {
@@ -835,7 +835,7 @@ struct vm_area_struct *vma_merge(struct mm_struct *mm,
 struct anon_vma *find_mergeable_anon_vma(struct vm_area_struct *vma)
 {
 	struct vm_area_struct *near;
-	unsigned long vm_flags;
+	vm_flags_t vm_flags;
 
 	near = vma->vm_next;
 	if (!near)
@@ -889,10 +889,10 @@ none:
 }
 
 #ifdef CONFIG_PROC_FS
-void vm_stat_account(struct mm_struct *mm, unsigned long flags,
-						struct file *file, long pages)
+void vm_stat_account(struct mm_struct *mm, vm_flags_t flags, struct file *file,
+		     long pages)
 {
-	const unsigned long stack_flags
+	const vm_flags_t stack_flags
 		= VM_STACK_FLAGS & (VM_GROWSUP|VM_GROWSDOWN);
 
 	if (file) {
@@ -916,7 +916,7 @@ unsigned long do_mmap_pgoff(struct file *file, unsigned long addr,
 {
 	struct mm_struct * mm = current->mm;
 	struct inode *inode;
-	unsigned int vm_flags;
+	vm_flags_t vm_flags;
 	int error;
 	unsigned long reqprot = prot;
 
@@ -1120,7 +1120,7 @@ SYSCALL_DEFINE1(old_mmap, struct mmap_arg_struct __user *, arg)
  */
 int vma_wants_writenotify(struct vm_area_struct *vma)
 {
-	unsigned int vm_flags = vma->vm_flags;
+	vm_flags_t vm_flags = vma->vm_flags;
 
 	/* If it was private or non-writable, the write bit is already clear */
 	if ((vm_flags & (VM_WRITE|VM_SHARED)) != ((VM_WRITE|VM_SHARED)))
@@ -1148,7 +1148,7 @@ int vma_wants_writenotify(struct vm_area_struct *vma)
  * We account for memory if it's a private writeable mapping,
  * not hugepages and VM_NORESERVE wasn't set.
  */
-static inline int accountable_mapping(struct file *file, unsigned int vm_flags)
+static inline int accountable_mapping(struct file *file, vm_flags_t vm_flags)
 {
 	/*
 	 * hugetlb has its own accounting separate from the core VM
@@ -1162,7 +1162,7 @@ static inline int accountable_mapping(struct file *file, unsigned int vm_flags)
 
 unsigned long mmap_region(struct file *file, unsigned long addr,
 			  unsigned long len, unsigned long flags,
-			  unsigned int vm_flags, unsigned long pgoff)
+			  vm_flags_t vm_flags, unsigned long pgoff)
 {
 	struct mm_struct *mm = current->mm;
 	struct vm_area_struct *vma, *prev;
@@ -2094,7 +2094,7 @@ unsigned long do_brk(unsigned long addr, unsigned long len)
 {
 	struct mm_struct * mm = current->mm;
 	struct vm_area_struct * vma, * prev;
-	unsigned long flags;
+	vm_flags_t flags;
 	struct rb_node ** rb_link, * rb_parent;
 	pgoff_t pgoff = addr >> PAGE_SHIFT;
 	int error;
@@ -2400,7 +2400,7 @@ static const struct vm_operations_struct special_mapping_vmops = {
  */
 int install_special_mapping(struct mm_struct *mm,
 			    unsigned long addr, unsigned long len,
-			    unsigned long vm_flags, struct page **pages)
+			    vm_flags_t vm_flags, struct page **pages)
 {
 	struct vm_area_struct *vma;
 
diff --git a/mm/mprotect.c b/mm/mprotect.c
index 2d1bf7c..e102e4b 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -133,10 +133,10 @@ static void change_protection(struct vm_area_struct *vma,
 
 int
 mprotect_fixup(struct vm_area_struct *vma, struct vm_area_struct **pprev,
-	unsigned long start, unsigned long end, unsigned long newflags)
+	unsigned long start, unsigned long end, vm_flags_t newflags)
 {
 	struct mm_struct *mm = vma->vm_mm;
-	unsigned long oldflags = vma->vm_flags;
+	vm_flags_t oldflags = vma->vm_flags;
 	long nrpages = (end - start) >> PAGE_SHIFT;
 	unsigned long charged = 0;
 	pgoff_t pgoff;
@@ -221,7 +221,8 @@ fail:
 SYSCALL_DEFINE3(mprotect, unsigned long, start, size_t, len,
 		unsigned long, prot)
 {
-	unsigned long vm_flags, nstart, end, tmp, reqprot;
+	unsigned long nstart, end, tmp, reqprot;
+	vm_flags_t vm_flags;
 	struct vm_area_struct *vma, *prev;
 	int error = -EINVAL;
 	const int grows = prot & (PROT_GROWSDOWN|PROT_GROWSUP);
diff --git a/mm/mremap.c b/mm/mremap.c
index cde56ee..63f0087 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -168,7 +168,7 @@ static unsigned long move_vma(struct vm_area_struct *vma,
 {
 	struct mm_struct *mm = vma->vm_mm;
 	struct vm_area_struct *new_vma;
-	unsigned long vm_flags = vma->vm_flags;
+	vm_flags_t vm_flags = vma->vm_flags;
 	unsigned long new_pgoff;
 	unsigned long moved_len;
 	unsigned long excess = 0;
diff --git a/mm/nommu.c b/mm/nommu.c
index 63fa17d..ab9846f 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -134,7 +134,7 @@ int __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 		     struct page **pages, struct vm_area_struct **vmas)
 {
 	struct vm_area_struct *vma;
-	unsigned long vm_flags;
+	vm_flags_t vm_flags;
 	int i;
 
 	/* calculate required read or write permissions.
@@ -588,7 +588,7 @@ static void put_nommu_region(struct vm_region *region)
 /*
  * update protection on a vma
  */
-static void protect_vma(struct vm_area_struct *vma, unsigned long flags)
+static void protect_vma(struct vm_area_struct *vma, vm_flags_t flags)
 {
 #ifdef CONFIG_MPU
 	struct mm_struct *mm = vma->vm_mm;
@@ -988,12 +988,12 @@ static int validate_mmap_request(struct file *file,
  * we've determined that we can make the mapping, now translate what we
  * now know into VMA flags
  */
-static unsigned long determine_vm_flags(struct file *file,
-					unsigned long prot,
-					unsigned long flags,
-					unsigned long capabilities)
+static vm_flags_t determine_vm_flags(struct file *file,
+				     unsigned long prot,
+				     unsigned long flags,
+				     unsigned long capabilities)
 {
-	unsigned long vm_flags;
+	vm_flags_t vm_flags;
 
 	vm_flags = calc_vm_prot_bits(prot) | calc_vm_flag_bits(flags);
 	vm_flags |= VM_MAYREAD | VM_MAYWRITE | VM_MAYEXEC;
@@ -1174,7 +1174,8 @@ unsigned long do_mmap_pgoff(struct file *file,
 	struct vm_area_struct *vma;
 	struct vm_region *region;
 	struct rb_node *rb;
-	unsigned long capabilities, vm_flags, result;
+	unsigned long capabilities, result;
+	vm_flags_t vm_flags;
 	int ret;
 
 	kenter(",%lx,%lx,%lx,%lx,%lx", addr, len, prot, flags, pgoff);
diff --git a/mm/rmap.c b/mm/rmap.c
index eaa7a09..ff2ea5e 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -430,7 +430,7 @@ int page_mapped_in_vma(struct page *page, struct vm_area_struct *vma)
  */
 int page_referenced_one(struct page *page, struct vm_area_struct *vma,
 			unsigned long address, unsigned int *mapcount,
-			unsigned long *vm_flags)
+			vm_flags_t *vm_flags)
 {
 	struct mm_struct *mm = vma->vm_mm;
 	pte_t *pte;
@@ -482,7 +482,7 @@ out:
 
 static int page_referenced_anon(struct page *page,
 				struct mem_cgroup *mem_cont,
-				unsigned long *vm_flags)
+				vm_flags_t *vm_flags)
 {
 	unsigned int mapcount;
 	struct anon_vma *anon_vma;
@@ -531,7 +531,7 @@ static int page_referenced_anon(struct page *page,
  */
 static int page_referenced_file(struct page *page,
 				struct mem_cgroup *mem_cont,
-				unsigned long *vm_flags)
+				vm_flags_t *vm_flags)
 {
 	unsigned int mapcount;
 	struct address_space *mapping = page->mapping;
@@ -597,7 +597,7 @@ static int page_referenced_file(struct page *page,
 int page_referenced(struct page *page,
 		    int is_locked,
 		    struct mem_cgroup *mem_cont,
-		    unsigned long *vm_flags)
+		    vm_flags_t *vm_flags)
 {
 	int referenced = 0;
 	int we_locked = 0;
diff --git a/mm/shmem.c b/mm/shmem.c
index eef4ebe..6b774ea 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -182,13 +182,13 @@ static inline struct shmem_sb_info *SHMEM_SB(struct super_block *sb)
  * (unless MAP_NORESERVE and sysctl_overcommit_memory <= 1),
  * consistent with the pre-accounting of private mappings ...
  */
-static inline int shmem_acct_size(unsigned long flags, loff_t size)
+static inline int shmem_acct_size(vm_flags_t flags, loff_t size)
 {
 	return (flags & VM_NORESERVE) ?
 		0 : security_vm_enough_memory_kern(VM_ACCT(size));
 }
 
-static inline void shmem_unacct_size(unsigned long flags, loff_t size)
+static inline void shmem_unacct_size(vm_flags_t flags, loff_t size)
 {
 	if (!(flags & VM_NORESERVE))
 		vm_unacct_memory(VM_ACCT(size));
@@ -1546,7 +1546,7 @@ static int shmem_mmap(struct file *file, struct vm_area_struct *vma)
 }
 
 static struct inode *shmem_get_inode(struct super_block *sb, int mode,
-					dev_t dev, unsigned long flags)
+					dev_t dev, vm_flags_t flags)
 {
 	struct inode *inode;
 	struct shmem_inode_info *info;
@@ -2626,7 +2626,7 @@ int shmem_lock(struct file *file, int lock, struct user_struct *user)
  * @size: size to be set for the file
  * @flags: VM_NORESERVE suppresses pre-accounting of the entire object size
  */
-struct file *shmem_file_setup(const char *name, loff_t size, unsigned long flags)
+struct file *shmem_file_setup(const char *name, loff_t size, vm_flags_t flags)
 {
 	int error;
 	struct file *file;
diff --git a/mm/vmscan.c b/mm/vmscan.c
index e0e5f15..739e669 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -569,7 +569,7 @@ static enum page_references page_check_references(struct page *page,
 						  struct scan_control *sc)
 {
 	int referenced_ptes, referenced_page;
-	unsigned long vm_flags;
+	vm_flags_t vm_flags;
 
 	referenced_ptes = page_referenced(page, 1, sc->mem_cgroup, &vm_flags);
 	referenced_page = TestClearPageReferenced(page);
@@ -1346,7 +1346,7 @@ static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
 {
 	unsigned long nr_taken;
 	unsigned long pgscanned;
-	unsigned long vm_flags;
+	vm_flags_t vm_flags;
 	LIST_HEAD(l_hold);	/* The pages which were snipped off */
 	LIST_HEAD(l_active);
 	LIST_HEAD(l_inactive);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
