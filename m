Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id CC4EB8D003B
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 02:11:02 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 74CF13EE0C0
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 15:10:58 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 539CB45DE9C
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 15:10:58 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 324BA45DE95
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 15:10:58 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 169FAE18007
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 15:10:58 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id B5FE6E18002
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 15:10:57 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: mm: convert vma->vm_flags to 64bit
Message-Id: <20110412151116.B50D.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: quoted-printable
Date: Tue, 12 Apr 2011 15:10:56 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Paul Mundt <lethal@linux-sh.org>, Russell King <linux@arm.linux.org.uk>


Benjamin, Hugh, I hope to add your S-O-B to this one because you are origin=
al author.=20
Can I do?

Paul, Russell, This patch modifies arm and sh code a bit. I don't think
they are risky change. but I'm really glad if you see it.


Note: I confirmed x86, power and nommu-arm cross compiler build and
I've got no warning/error.



=46rom d5a0d1c265e4caccb9ff5978c615f74019b65453 Mon Sep 17 00:00:00 2001
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Tue, 12 Apr 2011 14:00:42 +0900
Subject: [PATCH] mm: convert vma->vm_flags to 64bit

For years, powerpc people repeatedly request us to convert vm_flags
to 64bit. Because now it has no room to store an addional powerpc
specific flags.

Here is previous discussion logs.

	http://lkml.org/lkml/2009/10/1/202
	http://lkml.org/lkml/2010/4/27/23

But, unforunately they didn't get merged. This is 3rd trial.
I've merged previous two posted patches and adapted it for
latest tree.

Of cource, this patch has no functional change.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 arch/arm/include/asm/cacheflush.h            |    7 +-
 arch/powerpc/include/asm/mman.h              |    6 +-
 arch/sh/mm/tlbflush_64.c                     |    2 +-
 arch/x86/mm/hugetlbpage.c                    |    4 +-
 drivers/char/agp/frontend.c                  |    2 +-
 drivers/char/mem.c                           |    2 +-
 drivers/infiniband/hw/ipath/ipath_file_ops.c |    4 +-
 drivers/infiniband/hw/qib/qib_file_ops.c     |    4 +-
 drivers/media/video/omap3isp/ispqueue.h      |    2 +-
 fs/binfmt_elf_fdpic.c                        |   10 ++--
 fs/exec.c                                    |    2 +-
 fs/hugetlbfs/inode.c                         |    3 +-
 include/linux/huge_mm.h                      |    4 +-
 include/linux/hugetlb.h                      |    9 ++-
 include/linux/hugetlb_inline.h               |    2 +-
 include/linux/ksm.h                          |    8 +-
 include/linux/mm.h                           |   97 +++++++++++++---------=
---
 include/linux/mm_types.h                     |    7 +-
 include/linux/mman.h                         |   11 ++-
 include/linux/rmap.h                         |    7 +-
 ipc/shm.c                                    |    2 +-
 mm/huge_memory.c                             |    2 +-
 mm/hugetlb.c                                 |    2 +-
 mm/ksm.c                                     |    4 +-
 mm/madvise.c                                 |    2 +-
 mm/memory.c                                  |   10 ++--
 mm/mlock.c                                   |    8 +-
 mm/mmap.c                                    |   45 ++++++------
 mm/mprotect.c                                |    9 ++-
 mm/mremap.c                                  |    2 +-
 mm/nommu.c                                   |   15 ++--
 mm/rmap.c                                    |    8 +-
 mm/shmem.c                                   |   22 +++---
 mm/vmscan.c                                  |    4 +-
 34 files changed, 172 insertions(+), 156 deletions(-)

diff --git a/arch/arm/include/asm/cacheflush.h b/arch/arm/include/asm/cache=
flush.h
index d5d8d5c..45f9fe4 100644
--- a/arch/arm/include/asm/cacheflush.h
+++ b/arch/arm/include/asm/cacheflush.h
@@ -60,7 +60,7 @@
  *		specified address space before a change of page tables.
  *		- start - user start address (inclusive, page aligned)
  *		- end   - user end address   (exclusive, page aligned)
- *		- flags - vma->vm_flags field
+ *		- flags - low unsigned long of vma->vm_flags field
  *
  *	coherent_kern_range(start, end)
  *
@@ -217,7 +217,7 @@ vivt_flush_cache_range(struct vm_area_struct *vma, unsi=
gned long start, unsigned
 {
 	if (cpumask_test_cpu(smp_processor_id(), mm_cpumask(vma->vm_mm)))
 		__cpuc_flush_user_range(start & PAGE_MASK, PAGE_ALIGN(end),
-					vma->vm_flags);
+					(unsigned long)vma->vm_flags);
 }
=20
 static inline void
@@ -225,7 +225,8 @@ vivt_flush_cache_page(struct vm_area_struct *vma, unsig=
ned long user_addr, unsig
 {
 	if (cpumask_test_cpu(smp_processor_id(), mm_cpumask(vma->vm_mm))) {
 		unsigned long addr =3D user_addr & PAGE_MASK;
-		__cpuc_flush_user_range(addr, addr + PAGE_SIZE, vma->vm_flags);
+		__cpuc_flush_user_range(addr, addr + PAGE_SIZE,
+					(unsigned long)vma->vm_flags);
 	}
 }
=20
diff --git a/arch/powerpc/include/asm/mman.h b/arch/powerpc/include/asm/mma=
n.h
index d4a7f64..6ec51cf 100644
--- a/arch/powerpc/include/asm/mman.h
+++ b/arch/powerpc/include/asm/mman.h
@@ -38,13 +38,13 @@
  * This file is included by linux/mman.h, so we can't use cacl_vm_prot_bit=
s()
  * here.  How important is the optimization?
  */
-static inline unsigned long arch_calc_vm_prot_bits(unsigned long prot)
+static inline unsigned long long arch_calc_vm_prot_bits(unsigned long prot=
)
 {
-	return (prot & PROT_SAO) ? VM_SAO : 0;
+	return (prot & PROT_SAO) ? VM_SAO : 0ULL;
 }
 #define arch_calc_vm_prot_bits(prot) arch_calc_vm_prot_bits(prot)
=20
-static inline pgprot_t arch_vm_get_page_prot(unsigned long vm_flags)
+static inline pgprot_t arch_vm_get_page_prot(unsigned long long vm_flags)
 {
 	return (vm_flags & VM_SAO) ? __pgprot(_PAGE_SAO) : __pgprot(0);
 }
diff --git a/arch/sh/mm/tlbflush_64.c b/arch/sh/mm/tlbflush_64.c
index 7f5810f..3e52d60 100644
--- a/arch/sh/mm/tlbflush_64.c
+++ b/arch/sh/mm/tlbflush_64.c
@@ -48,7 +48,7 @@ static inline void print_vma(struct vm_area_struct *vma)
 	printk("vma end   0x%08lx\n", vma->vm_end);
=20
 	print_prots(vma->vm_page_prot);
-	printk("vm_flags 0x%08lx\n", vma->vm_flags);
+	printk("vm_flags 0x%08llx\n", vma->vm_flags);
 }
=20
 static inline void print_task(struct task_struct *tsk)
diff --git a/arch/x86/mm/hugetlbpage.c b/arch/x86/mm/hugetlbpage.c
index d420398..9d86252 100644
--- a/arch/x86/mm/hugetlbpage.c
+++ b/arch/x86/mm/hugetlbpage.c
@@ -26,8 +26,8 @@ static unsigned long page_table_shareable(struct vm_area_=
struct *svma,
 	unsigned long s_end =3D sbase + PUD_SIZE;
=20
 	/* Allow segments to share if only one is marked locked */
-	unsigned long vm_flags =3D vma->vm_flags & ~VM_LOCKED;
-	unsigned long svm_flags =3D svma->vm_flags & ~VM_LOCKED;
+	unsigned long long vm_flags =3D vma->vm_flags & ~VM_LOCKED;
+	unsigned long long svm_flags =3D svma->vm_flags & ~VM_LOCKED;
=20
 	/*
 	 * match the virtual addresses, permission and the alignment of the
diff --git a/drivers/char/agp/frontend.c b/drivers/char/agp/frontend.c
index 2e04433..6fa411f 100644
--- a/drivers/char/agp/frontend.c
+++ b/drivers/char/agp/frontend.c
@@ -155,7 +155,7 @@ static void agp_add_seg_to_client(struct agp_client *cl=
ient,
=20
 static pgprot_t agp_convert_mmap_flags(int prot)
 {
-	unsigned long prot_bits;
+	unsigned long long prot_bits;
=20
 	prot_bits =3D calc_vm_prot_bits(prot) | VM_SHARED;
 	return vm_get_page_prot(prot_bits);
diff --git a/drivers/char/mem.c b/drivers/char/mem.c
index 436a990..a85a3a4 100644
--- a/drivers/char/mem.c
+++ b/drivers/char/mem.c
@@ -279,7 +279,7 @@ static unsigned long get_unmapped_area_mem(struct file =
*file,
 /* can't do an in-place private mapping if there's no MMU */
 static inline int private_mapping_ok(struct vm_area_struct *vma)
 {
-	return vma->vm_flags & VM_MAYSHARE;
+	return !!(vma->vm_flags & VM_MAYSHARE);
 }
 #else
 #define get_unmapped_area_mem	NULL
diff --git a/drivers/infiniband/hw/ipath/ipath_file_ops.c b/drivers/infinib=
and/hw/ipath/ipath_file_ops.c
index 6d4b29c..70cd05f 100644
--- a/drivers/infiniband/hw/ipath/ipath_file_ops.c
+++ b/drivers/infiniband/hw/ipath/ipath_file_ops.c
@@ -1113,7 +1113,7 @@ static int mmap_rcvegrbufs(struct vm_area_struct *vma=
,
=20
 	if (vma->vm_flags & VM_WRITE) {
 		dev_info(&dd->pcidev->dev, "Can't map eager buffers as "
-			 "writable (flags=3D%lx)\n", vma->vm_flags);
+			 "writable (flags=3D%llx)\n", vma->vm_flags);
 		ret =3D -EPERM;
 		goto bail;
 	}
@@ -1202,7 +1202,7 @@ static int mmap_kvaddr(struct vm_area_struct *vma, u6=
4 pgaddr,
                 if (vma->vm_flags & VM_WRITE) {
                         dev_info(&dd->pcidev->dev,
                                  "Can't map eager buffers as "
-                                 "writable (flags=3D%lx)\n", vma->vm_flags=
);
+                                 "writable (flags=3D%llx)\n", vma->vm_flag=
s);
                         ret =3D -EPERM;
                         goto bail;
                 }
diff --git a/drivers/infiniband/hw/qib/qib_file_ops.c b/drivers/infiniband/=
hw/qib/qib_file_ops.c
index 75bfad1..f335236 100644
--- a/drivers/infiniband/hw/qib/qib_file_ops.c
+++ b/drivers/infiniband/hw/qib/qib_file_ops.c
@@ -856,7 +856,7 @@ static int mmap_rcvegrbufs(struct vm_area_struct *vma,
=20
 	if (vma->vm_flags & VM_WRITE) {
 		qib_devinfo(dd->pcidev, "Can't map eager buffers as "
-			 "writable (flags=3D%lx)\n", vma->vm_flags);
+			 "writable (flags=3D%llx)\n", vma->vm_flags);
 		ret =3D -EPERM;
 		goto bail;
 	}
@@ -945,7 +945,7 @@ static int mmap_kvaddr(struct vm_area_struct *vma, u64 =
pgaddr,
 		if (vma->vm_flags & VM_WRITE) {
 			qib_devinfo(dd->pcidev,
 				 "Can't map eager buffers as "
-				 "writable (flags=3D%lx)\n", vma->vm_flags);
+				 "writable (flags=3D%llx)\n", vma->vm_flags);
 			ret =3D -EPERM;
 			goto bail;
 		}
diff --git a/drivers/media/video/omap3isp/ispqueue.h b/drivers/media/video/=
omap3isp/ispqueue.h
index 251de3e..b0653cf 100644
--- a/drivers/media/video/omap3isp/ispqueue.h
+++ b/drivers/media/video/omap3isp/ispqueue.h
@@ -90,7 +90,7 @@ struct isp_video_buffer {
 	void *vaddr;
=20
 	/* For userspace buffers. */
-	unsigned long vm_flags;
+	unsigned long long vm_flags;
 	unsigned long offset;
 	unsigned int npages;
 	struct page **pages;
diff --git a/fs/binfmt_elf_fdpic.c b/fs/binfmt_elf_fdpic.c
index 63039ed..f92adfa 100644
--- a/fs/binfmt_elf_fdpic.c
+++ b/fs/binfmt_elf_fdpic.c
@@ -1226,7 +1226,7 @@ static int maydump(struct vm_area_struct *vma, unsign=
ed long mm_flags)
 	 * them either. "dump_write()" can't handle it anyway.
 	 */
 	if (!(vma->vm_flags & VM_READ)) {
-		kdcore("%08lx: %08lx: no (!read)", vma->vm_start, vma->vm_flags);
+		kdcore("%08lx: %08llx: no (!read)", vma->vm_start, vma->vm_flags);
 		return 0;
 	}
=20
@@ -1234,13 +1234,13 @@ static int maydump(struct vm_area_struct *vma, unsi=
gned long mm_flags)
 	if (vma->vm_flags & VM_SHARED) {
 		if (vma->vm_file->f_path.dentry->d_inode->i_nlink =3D=3D 0) {
 			dump_ok =3D test_bit(MMF_DUMP_ANON_SHARED, &mm_flags);
-			kdcore("%08lx: %08lx: %s (share)", vma->vm_start,
+			kdcore("%08lx: %08llx: %s (share)", vma->vm_start,
 			       vma->vm_flags, dump_ok ? "yes" : "no");
 			return dump_ok;
 		}
=20
 		dump_ok =3D test_bit(MMF_DUMP_MAPPED_SHARED, &mm_flags);
-		kdcore("%08lx: %08lx: %s (share)", vma->vm_start,
+		kdcore("%08lx: %08llx: %s (share)", vma->vm_start,
 		       vma->vm_flags, dump_ok ? "yes" : "no");
 		return dump_ok;
 	}
@@ -1249,14 +1249,14 @@ static int maydump(struct vm_area_struct *vma, unsi=
gned long mm_flags)
 	/* By default, if it hasn't been written to, don't write it out */
 	if (!vma->anon_vma) {
 		dump_ok =3D test_bit(MMF_DUMP_MAPPED_PRIVATE, &mm_flags);
-		kdcore("%08lx: %08lx: %s (!anon)", vma->vm_start,
+		kdcore("%08lx: %08llx: %s (!anon)", vma->vm_start,
 		       vma->vm_flags, dump_ok ? "yes" : "no");
 		return dump_ok;
 	}
 #endif
=20
 	dump_ok =3D test_bit(MMF_DUMP_ANON_PRIVATE, &mm_flags);
-	kdcore("%08lx: %08lx: %s", vma->vm_start, vma->vm_flags,
+	kdcore("%08lx: %08llx: %s", vma->vm_start, vma->vm_flags,
 	       dump_ok ? "yes" : "no");
 	return dump_ok;
 }
diff --git a/fs/exec.c b/fs/exec.c
index 4c561fa..451c7e5 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -619,7 +619,7 @@ int setup_arg_pages(struct linux_binprm *bprm,
 	struct mm_struct *mm =3D current->mm;
 	struct vm_area_struct *vma =3D bprm->vma;
 	struct vm_area_struct *prev =3D NULL;
-	unsigned long vm_flags;
+	unsigned long long vm_flags;
 	unsigned long stack_base;
 	unsigned long stack_size;
 	unsigned long stack_expand;
diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index b9eeb1c..bcb1527 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -921,7 +921,8 @@ static int can_do_hugetlb_shm(void)
 	return capable(CAP_IPC_LOCK) || in_group_p(sysctl_hugetlb_shm_group);
 }
=20
-struct file *hugetlb_file_setup(const char *name, size_t size, int acctfla=
g,
+struct file *hugetlb_file_setup(const char *name, size_t size,
+				unsigned long long acctflag,
 				struct user_struct **user, int creat_flags)
 {
 	int error =3D -ENOMEM;
diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index df29c8f..019dc9e 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -107,7 +107,7 @@ extern void __split_huge_page_pmd(struct mm_struct *mm,=
 pmd_t *pmd);
 #error "hugepages can't be allocated by the buddy allocator"
 #endif
 extern int hugepage_madvise(struct vm_area_struct *vma,
-			    unsigned long *vm_flags, int advice);
+			    unsigned long long *vm_flags, int advice);
 extern void __vma_adjust_trans_huge(struct vm_area_struct *vma,
 				    unsigned long start,
 				    unsigned long end,
@@ -164,7 +164,7 @@ static inline int split_huge_page(struct page *page)
 	do { } while (0)
 #define compound_trans_head(page) compound_head(page)
 static inline int hugepage_madvise(struct vm_area_struct *vma,
-				   unsigned long *vm_flags, int advice)
+				   unsigned long long *vm_flags, int advice)
 {
 	BUG();
 	return 0;
diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 943c76b..4683f03 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -41,7 +41,7 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_area_st=
ruct *vma,
 			unsigned long address, unsigned int flags);
 int hugetlb_reserve_pages(struct inode *inode, long from, long to,
 						struct vm_area_struct *vma,
-						int acctflags);
+						unsigned long long acctflags);
 void hugetlb_unreserve_pages(struct inode *inode, long offset, long freed)=
;
 int dequeue_hwpoisoned_huge_page(struct page *page);
 void copy_huge_page(struct page *dst, struct page *src);
@@ -168,7 +168,8 @@ static inline struct hugetlbfs_sb_info *HUGETLBFS_SB(st=
ruct super_block *sb)
=20
 extern const struct file_operations hugetlbfs_file_operations;
 extern const struct vm_operations_struct hugetlb_vm_ops;
-struct file *hugetlb_file_setup(const char *name, size_t size, int acct,
+struct file *hugetlb_file_setup(const char *name, size_t size,
+				unsigned long long acctflag,
 				struct user_struct **user, int creat_flags);
 int hugetlb_get_quota(struct address_space *mapping, long delta);
 void hugetlb_put_quota(struct address_space *mapping, long delta);
@@ -192,7 +193,9 @@ static inline void set_file_hugepages(struct file *file=
)
 #define is_file_hugepages(file)			0
 #define set_file_hugepages(file)		BUG()
 static inline struct file *hugetlb_file_setup(const char *name, size_t siz=
e,
-		int acctflag, struct user_struct **user, int creat_flags)
+					      unsigned long long acctflag,
+					      struct user_struct **user,
+					      int creat_flags)
 {
 	return ERR_PTR(-ENOSYS);
 }
diff --git a/include/linux/hugetlb_inline.h b/include/linux/hugetlb_inline.=
h
index 6931489..2bb681f 100644
--- a/include/linux/hugetlb_inline.h
+++ b/include/linux/hugetlb_inline.h
@@ -7,7 +7,7 @@
=20
 static inline int is_vm_hugetlb_page(struct vm_area_struct *vma)
 {
-	return vma->vm_flags & VM_HUGETLB;
+	return !!(vma->vm_flags & VM_HUGETLB);
 }
=20
 #else
diff --git a/include/linux/ksm.h b/include/linux/ksm.h
index 3319a69..893cf62 100644
--- a/include/linux/ksm.h
+++ b/include/linux/ksm.h
@@ -21,7 +21,7 @@ struct page *ksm_does_need_to_copy(struct page *page,
=20
 #ifdef CONFIG_KSM
 int ksm_madvise(struct vm_area_struct *vma, unsigned long start,
-		unsigned long end, int advice, unsigned long *vm_flags);
+		unsigned long end, int advice, unsigned long long *vm_flags);
 int __ksm_enter(struct mm_struct *mm);
 void __ksm_exit(struct mm_struct *mm);
=20
@@ -84,7 +84,7 @@ static inline int ksm_might_need_to_copy(struct page *pag=
e,
 }
=20
 int page_referenced_ksm(struct page *page,
-			struct mem_cgroup *memcg, unsigned long *vm_flags);
+			struct mem_cgroup *memcg, unsigned long long *vm_flags);
 int try_to_unmap_ksm(struct page *page, enum ttu_flags flags);
 int rmap_walk_ksm(struct page *page, int (*rmap_one)(struct page *,
 		  struct vm_area_struct *, unsigned long, void *), void *arg);
@@ -108,7 +108,7 @@ static inline int PageKsm(struct page *page)
=20
 #ifdef CONFIG_MMU
 static inline int ksm_madvise(struct vm_area_struct *vma, unsigned long st=
art,
-		unsigned long end, int advice, unsigned long *vm_flags)
+		unsigned long end, int advice, unsigned long long *vm_flags)
 {
 	return 0;
 }
@@ -120,7 +120,7 @@ static inline int ksm_might_need_to_copy(struct page *p=
age,
 }
=20
 static inline int page_referenced_ksm(struct page *page,
-			struct mem_cgroup *memcg, unsigned long *vm_flags)
+			struct mem_cgroup *memcg, unsigned long long *vm_flags)
 {
 	return 0;
 }
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 628b31c..63772c2 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -67,55 +67,55 @@ extern unsigned int kobjsize(const void *objp);
 /*
  * vm_flags in vm_area_struct, see mm_types.h.
  */
-#define VM_READ		0x00000001	/* currently active flags */
-#define VM_WRITE	0x00000002
-#define VM_EXEC		0x00000004
-#define VM_SHARED	0x00000008
+#define VM_READ		0x00000001ULL	/* currently active flags */
+#define VM_WRITE	0x00000002ULL
+#define VM_EXEC		0x00000004ULL
+#define VM_SHARED	0x00000008ULL
=20
 /* mprotect() hardcodes VM_MAYREAD >> 4 =3D=3D VM_READ, and so for r/w/x b=
its. */
-#define VM_MAYREAD	0x00000010	/* limits for mprotect() etc */
-#define VM_MAYWRITE	0x00000020
-#define VM_MAYEXEC	0x00000040
-#define VM_MAYSHARE	0x00000080
+#define VM_MAYREAD	0x00000010ULL	/* limits for mprotect() etc */
+#define VM_MAYWRITE	0x00000020ULL
+#define VM_MAYEXEC	0x00000040ULL
+#define VM_MAYSHARE	0x00000080ULL
=20
-#define VM_GROWSDOWN	0x00000100	/* general info on the segment */
+#define VM_GROWSDOWN	0x00000100ULL	/* general info on the segment */
 #if defined(CONFIG_STACK_GROWSUP) || defined(CONFIG_IA64)
-#define VM_GROWSUP	0x00000200
+#define VM_GROWSUP	0x00000200ULL
 #else
-#define VM_GROWSUP	0x00000000
-#define VM_NOHUGEPAGE	0x00000200	/* MADV_NOHUGEPAGE marked this vma */
+#define VM_GROWSUP	0x00000000ULL
+#define VM_NOHUGEPAGE	0x00000200ULL	/* MADV_NOHUGEPAGE marked this vma */
 #endif
-#define VM_PFNMAP	0x00000400	/* Page-ranges managed without "struct page",=
 just pure PFN */
-#define VM_DENYWRITE	0x00000800	/* ETXTBSY on write attempts.. */
+#define VM_PFNMAP	0x00000400ULL	/* Page-ranges managed without "struct pag=
e", just pure PFN */
+#define VM_DENYWRITE	0x00000800ULL	/* ETXTBSY on write attempts.. */
=20
-#define VM_EXECUTABLE	0x00001000
-#define VM_LOCKED	0x00002000
-#define VM_IO           0x00004000	/* Memory mapped I/O or similar */
+#define VM_EXECUTABLE	0x00001000ULL
+#define VM_LOCKED	0x00002000ULL
+#define VM_IO           0x00004000ULL	/* Memory mapped I/O or similar */
=20
 					/* Used by sys_madvise() */
-#define VM_SEQ_READ	0x00008000	/* App will access data sequentially */
-#define VM_RAND_READ	0x00010000	/* App will not benefit from clustered rea=
ds */
-
-#define VM_DONTCOPY	0x00020000      /* Do not copy this vma on fork */
-#define VM_DONTEXPAND	0x00040000	/* Cannot expand with mremap() */
-#define VM_RESERVED	0x00080000	/* Count as reserved_vm like IO */
-#define VM_ACCOUNT	0x00100000	/* Is a VM accounted object */
-#define VM_NORESERVE	0x00200000	/* should the VM suppress accounting */
-#define VM_HUGETLB	0x00400000	/* Huge TLB Page VM */
-#define VM_NONLINEAR	0x00800000	/* Is non-linear (remap_file_pages) */
+#define VM_SEQ_READ	0x00008000ULL	/* App will access data sequentially */
+#define VM_RAND_READ	0x00010000ULL	/* App will not benefit from clustered =
reads */
+
+#define VM_DONTCOPY	0x00020000ULL	/* Do not copy this vma on fork */
+#define VM_DONTEXPAND	0x00040000ULL	/* Cannot expand with mremap() */
+#define VM_RESERVED	0x00080000ULL	/* Count as reserved_vm like IO */
+#define VM_ACCOUNT	0x00100000ULL	/* Is a VM accounted object */
+#define VM_NORESERVE	0x00200000ULL	/* should the VM suppress accounting */
+#define VM_HUGETLB	0x00400000ULL	/* Huge TLB Page VM */
+#define VM_NONLINEAR	0x00800000ULL	/* Is non-linear (remap_file_pages) */
 #ifndef CONFIG_TRANSPARENT_HUGEPAGE
-#define VM_MAPPED_COPY	0x01000000	/* T if mapped copy of data (nommu mmap)=
 */
+#define VM_MAPPED_COPY	0x01000000ULL	/* T if mapped copy of data (nommu mm=
ap) */
 #else
-#define VM_HUGEPAGE	0x01000000	/* MADV_HUGEPAGE marked this vma */
+#define VM_HUGEPAGE	0x01000000ULL	/* MADV_HUGEPAGE marked this vma */
 #endif
-#define VM_INSERTPAGE	0x02000000	/* The vma has had "vm_insert_page()" don=
e on it */
-#define VM_ALWAYSDUMP	0x04000000	/* Always include in core dumps */
+#define VM_INSERTPAGE	0x02000000ULL	/* The vma has had "vm_insert_page()" =
done on it */
+#define VM_ALWAYSDUMP	0x04000000ULL	/* Always include in core dumps */
=20
-#define VM_CAN_NONLINEAR 0x08000000	/* Has ->fault & does nonlinear pages =
*/
-#define VM_MIXEDMAP	0x10000000	/* Can contain "struct page" and pure PFN p=
ages */
-#define VM_SAO		0x20000000	/* Strong Access Ordering (powerpc) */
-#define VM_PFN_AT_MMAP	0x40000000	/* PFNMAP vma that is fully mapped at mm=
ap time */
-#define VM_MERGEABLE	0x80000000	/* KSM may merge identical pages */
+#define VM_CAN_NONLINEAR 0x08000000ULL	/* Has ->fault & does nonlinear pag=
es */
+#define VM_MIXEDMAP	0x10000000ULL	/* Can contain "struct page" and pure PF=
N pages */
+#define VM_SAO		0x20000000ULL	/* Strong Access Ordering (powerpc) */
+#define VM_PFN_AT_MMAP	0x40000000ULL	/* PFNMAP vma that is fully mapped at=
 mmap time */
+#define VM_MERGEABLE	0x80000000ULL	/* KSM may merge identical pages */
=20
 /* Bits set in the VMA until the stack is in its final location */
 #define VM_STACK_INCOMPLETE_SETUP	(VM_RAND_READ | VM_SEQ_READ)
@@ -163,12 +163,12 @@ extern pgprot_t protection_map[16];
  */
 static inline int is_linear_pfn_mapping(struct vm_area_struct *vma)
 {
-	return (vma->vm_flags & VM_PFN_AT_MMAP);
+	return !!(vma->vm_flags & VM_PFN_AT_MMAP);
 }
=20
 static inline int is_pfn_mapping(struct vm_area_struct *vma)
 {
-	return (vma->vm_flags & VM_PFNMAP);
+	return !!(vma->vm_flags & VM_PFNMAP);
 }
=20
 /*
@@ -870,7 +870,7 @@ extern void show_free_areas(unsigned int flags);
 extern bool skip_free_areas_node(unsigned int flags, int nid);
=20
 int shmem_lock(struct file *file, int lock, struct user_struct *user);
-struct file *shmem_file_setup(const char *name, loff_t size, unsigned long=
 flags);
+struct file *shmem_file_setup(const char *name, loff_t size, unsigned long=
 long vm_flags);
 int shmem_zero_setup(struct vm_area_struct *);
=20
 #ifndef CONFIG_MMU
@@ -1023,7 +1023,7 @@ extern unsigned long do_mremap(unsigned long addr,
 			       unsigned long flags, unsigned long new_addr);
 extern int mprotect_fixup(struct vm_area_struct *vma,
 			  struct vm_area_struct **pprev, unsigned long start,
-			  unsigned long end, unsigned long newflags);
+			  unsigned long end, unsigned long long newflags);
=20
 /*
  * doesn't attempt to fault and will return short.
@@ -1397,7 +1397,7 @@ extern int vma_adjust(struct vm_area_struct *vma, uns=
igned long start,
 	unsigned long end, pgoff_t pgoff, struct vm_area_struct *insert);
 extern struct vm_area_struct *vma_merge(struct mm_struct *,
 	struct vm_area_struct *prev, unsigned long addr, unsigned long end,
-	unsigned long vm_flags, struct anon_vma *, struct file *, pgoff_t,
+	unsigned long long vm_flags, struct anon_vma *, struct file *, pgoff_t,
 	struct mempolicy *);
 extern struct anon_vma *find_mergeable_anon_vma(struct vm_area_struct *);
 extern int split_vma(struct mm_struct *,
@@ -1428,7 +1428,8 @@ static inline void removed_exe_file_vma(struct mm_str=
uct *mm)
 extern int may_expand_vm(struct mm_struct *mm, unsigned long npages);
 extern int install_special_mapping(struct mm_struct *mm,
 				   unsigned long addr, unsigned long len,
-				   unsigned long flags, struct page **pages);
+				   unsigned long long vm_flags,
+				   struct page **pages);
=20
 extern unsigned long get_unmapped_area(struct file *, unsigned long, unsig=
ned long, unsigned long, unsigned long);
=20
@@ -1437,7 +1438,7 @@ extern unsigned long do_mmap_pgoff(struct file *file,=
 unsigned long addr,
 	unsigned long flag, unsigned long pgoff);
 extern unsigned long mmap_region(struct file *file, unsigned long addr,
 	unsigned long len, unsigned long flags,
-	unsigned int vm_flags, unsigned long pgoff);
+	unsigned long long vm_flags, unsigned long pgoff);
=20
 static inline unsigned long do_mmap(struct file *file, unsigned long addr,
 	unsigned long len, unsigned long prot,
@@ -1526,9 +1527,9 @@ static inline unsigned long vma_pages(struct vm_area_=
struct *vma)
 }
=20
 #ifdef CONFIG_MMU
-pgprot_t vm_get_page_prot(unsigned long vm_flags);
+pgprot_t vm_get_page_prot(unsigned long long vm_flags);
 #else
-static inline pgprot_t vm_get_page_prot(unsigned long vm_flags)
+static inline pgprot_t vm_get_page_prot(unsigned long long vm_flags)
 {
 	return __pgprot(0);
 }
@@ -1567,10 +1568,12 @@ extern int apply_to_page_range_batch(struct mm_stru=
ct *mm,
 				     pte_batch_fn_t fn, void *data);
=20
 #ifdef CONFIG_PROC_FS
-void vm_stat_account(struct mm_struct *, unsigned long, struct file *, lon=
g);
+void vm_stat_account(struct mm_struct *mm, unsigned long long vm_flags,
+		     struct file *file, long pages);
 #else
 static inline void vm_stat_account(struct mm_struct *mm,
-			unsigned long flags, struct file *file, long pages)
+				   unsigned long long flags,
+				   struct file *file, long pages)
 {
 }
 #endif /* CONFIG_PROC_FS */
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 02aa561..4b0b990 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -109,7 +109,7 @@ struct page {
  */
 struct vm_region {
 	struct rb_node	vm_rb;		/* link in global region tree */
-	unsigned long	vm_flags;	/* VMA vm_flags */
+	unsigned long long vm_flags;	/* VMA vm_flags */
 	unsigned long	vm_start;	/* start address of region */
 	unsigned long	vm_end;		/* region initialised to here */
 	unsigned long	vm_top;		/* region allocated to here */
@@ -137,7 +137,7 @@ struct vm_area_struct {
 	struct vm_area_struct *vm_next, *vm_prev;
=20
 	pgprot_t vm_page_prot;		/* Access permissions of this VMA. */
-	unsigned long vm_flags;		/* Flags, see mm.h. */
+	unsigned long long vm_flags;		/* Flags, see mm.h. */
=20
 	struct rb_node vm_rb;
=20
@@ -251,7 +251,8 @@ struct mm_struct {
 	unsigned long hiwater_vm;	/* High-water virtual memory usage */
=20
 	unsigned long total_vm, locked_vm, shared_vm, exec_vm;
-	unsigned long stack_vm, reserved_vm, def_flags, nr_ptes;
+	unsigned long stack_vm, reserved_vm, nr_ptes;
+	unsigned long long def_flags;
 	unsigned long start_code, end_code, start_data, end_data;
 	unsigned long start_brk, brk, start_stack;
 	unsigned long arg_start, arg_end, env_start, env_end;
diff --git a/include/linux/mman.h b/include/linux/mman.h
index 9872d6c..ffb2770 100644
--- a/include/linux/mman.h
+++ b/include/linux/mman.h
@@ -35,11 +35,14 @@ static inline void vm_unacct_memory(long pages)
  */
=20
 #ifndef arch_calc_vm_prot_bits
-#define arch_calc_vm_prot_bits(prot) 0
+#define arch_calc_vm_prot_bits(prot) 0ULL
 #endif
=20
 #ifndef arch_vm_get_page_prot
-#define arch_vm_get_page_prot(vm_flags) __pgprot(0)
+static inline pgprot_t arch_vm_get_page_prot(unsigned long long vm_flags)
+{
+	return __pgprot(0);
+}
 #endif
=20
 #ifndef arch_validate_prot
@@ -69,7 +72,7 @@ static inline int arch_validate_prot(unsigned long prot)
 /*
  * Combine the mmap "prot" argument into "vm_flags" used internally.
  */
-static inline unsigned long
+static inline unsigned long long
 calc_vm_prot_bits(unsigned long prot)
 {
 	return _calc_vm_trans(prot, PROT_READ,  VM_READ ) |
@@ -81,7 +84,7 @@ calc_vm_prot_bits(unsigned long prot)
 /*
  * Combine the mmap "flags" argument into "vm_flags" used internally.
  */
-static inline unsigned long
+static inline unsigned long long
 calc_vm_flag_bits(unsigned long flags)
 {
 	return _calc_vm_trans(flags, MAP_GROWSDOWN,  VM_GROWSDOWN ) |
diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index 830e65d..c0a478a 100644
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -157,9 +157,10 @@ static inline void page_dup_rmap(struct page *page)
  * Called from mm/vmscan.c to handle paging out
  */
 int page_referenced(struct page *, int is_locked,
-			struct mem_cgroup *cnt, unsigned long *vm_flags);
+			struct mem_cgroup *cnt, unsigned long long *vm_flags);
 int page_referenced_one(struct page *, struct vm_area_struct *,
-	unsigned long address, unsigned int *mapcount, unsigned long *vm_flags);
+			unsigned long address, unsigned int *mapcount,
+			unsigned long long *vm_flags);
=20
 enum ttu_flags {
 	TTU_UNMAP =3D 0,			/* unmap mode */
@@ -249,7 +250,7 @@ int rmap_walk(struct page *page, int (*rmap_one)(struct=
 page *,
=20
 static inline int page_referenced(struct page *page, int is_locked,
 				  struct mem_cgroup *cnt,
-				  unsigned long *vm_flags)
+				  unsigned long long *vm_flags)
 {
 	*vm_flags =3D 0;
 	return 0;
diff --git a/ipc/shm.c b/ipc/shm.c
index 8644452..84ba822 100644
--- a/ipc/shm.c
+++ b/ipc/shm.c
@@ -347,7 +347,7 @@ static int newseg(struct ipc_namespace *ns, struct ipc_=
params *params)
 	struct file * file;
 	char name[13];
 	int id;
-	int acctflag =3D 0;
+	unsigned long long acctflag =3D 0;
=20
 	if (size < SHMMIN || size > ns->shm_ctlmax)
 		return -EINVAL;
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 1722683..b5521b8 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1405,7 +1405,7 @@ out:
 }
=20
 int hugepage_madvise(struct vm_area_struct *vma,
-		     unsigned long *vm_flags, int advice)
+		     unsigned long long *vm_flags, int advice)
 {
 	switch (advice) {
 	case MADV_HUGEPAGE:
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 06de5aa..bee50a3 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -2833,7 +2833,7 @@ void hugetlb_change_protection(struct vm_area_struct =
*vma,
 int hugetlb_reserve_pages(struct inode *inode,
 					long from, long to,
 					struct vm_area_struct *vma,
-					int acctflag)
+					unsigned long long acctflag)
 {
 	long ret, chg;
 	struct hstate *h =3D hstate_inode(inode);
diff --git a/mm/ksm.c b/mm/ksm.c
index 1bbe785..ed283de 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -1446,7 +1446,7 @@ static int ksm_scan_thread(void *nothing)
 }
=20
 int ksm_madvise(struct vm_area_struct *vma, unsigned long start,
-		unsigned long end, int advice, unsigned long *vm_flags)
+		unsigned long end, int advice, unsigned long long *vm_flags)
 {
 	struct mm_struct *mm =3D vma->vm_mm;
 	int err;
@@ -1581,7 +1581,7 @@ struct page *ksm_does_need_to_copy(struct page *page,
 }
=20
 int page_referenced_ksm(struct page *page, struct mem_cgroup *memcg,
-			unsigned long *vm_flags)
+			unsigned long long *vm_flags)
 {
 	struct stable_node *stable_node;
 	struct rmap_item *rmap_item;
diff --git a/mm/madvise.c b/mm/madvise.c
index 2221491..4bf81ac 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -43,7 +43,7 @@ static long madvise_behavior(struct vm_area_struct * vma,
 	struct mm_struct * mm =3D vma->vm_mm;
 	int error =3D 0;
 	pgoff_t pgoff;
-	unsigned long new_flags =3D vma->vm_flags;
+	unsigned long long new_flags =3D vma->vm_flags;
=20
 	switch (behavior) {
 	case MADV_NORMAL:
diff --git a/mm/memory.c b/mm/memory.c
index 3c1307b..2f4c223 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -518,7 +518,7 @@ static void print_bad_pte(struct vm_area_struct *vma, u=
nsigned long addr,
 	if (page)
 		dump_page(page);
 	printk(KERN_ALERT
-		"addr:%p vm_flags:%08lx anon_vma:%p mapping:%p index:%lx\n",
+		"addr:%p vm_flags:%08llx anon_vma:%p mapping:%p index:%lx\n",
 		(void *)addr, vma->vm_flags, vma->anon_vma, mapping, index);
 	/*
 	 * Choose text because data symbols depend on CONFIG_KALLSYMS_ALL=3Dy
@@ -533,9 +533,9 @@ static void print_bad_pte(struct vm_area_struct *vma, u=
nsigned long addr,
 	add_taint(TAINT_BAD_PAGE);
 }
=20
-static inline int is_cow_mapping(unsigned int flags)
+static inline int is_cow_mapping(unsigned long long vm_flags)
 {
-	return (flags & (VM_SHARED | VM_MAYWRITE)) =3D=3D VM_MAYWRITE;
+	return (vm_flags & (VM_SHARED | VM_MAYWRITE)) =3D=3D VM_MAYWRITE;
 }
=20
 #ifndef is_zero_pfn
@@ -658,7 +658,7 @@ copy_one_pte(struct mm_struct *dst_mm, struct mm_struct=
 *src_mm,
 		pte_t *dst_pte, pte_t *src_pte, struct vm_area_struct *vma,
 		unsigned long addr, int *rss)
 {
-	unsigned long vm_flags =3D vma->vm_flags;
+	unsigned long long vm_flags =3D vma->vm_flags;
 	pte_t pte =3D *src_pte;
 	struct page *page;
=20
@@ -1465,7 +1465,7 @@ int __get_user_pages(struct task_struct *tsk, struct =
mm_struct *mm,
 		     int *nonblocking)
 {
 	int i;
-	unsigned long vm_flags;
+	unsigned long long vm_flags;
=20
 	if (nr_pages <=3D 0)
 		return 0;
diff --git a/mm/mlock.c b/mm/mlock.c
index 2689a08c..19fbf08 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -323,13 +323,13 @@ void munlock_vma_pages_range(struct vm_area_struct *v=
ma,
  * For vmas that pass the filters, merge/split as appropriate.
  */
 static int mlock_fixup(struct vm_area_struct *vma, struct vm_area_struct *=
*prev,
-	unsigned long start, unsigned long end, unsigned int newflags)
+	unsigned long start, unsigned long end, unsigned long long newflags)
 {
 	struct mm_struct *mm =3D vma->vm_mm;
 	pgoff_t pgoff;
 	int nr_pages;
 	int ret =3D 0;
-	int lock =3D newflags & VM_LOCKED;
+	int lock =3D !!(newflags & VM_LOCKED);
=20
 	if (newflags =3D=3D vma->vm_flags || (vma->vm_flags & VM_SPECIAL) ||
 	    is_vm_hugetlb_page(vma) || vma =3D=3D get_gate_vma(current->mm))
@@ -401,7 +401,7 @@ static int do_mlock(unsigned long start, size_t len, in=
t on)
 		prev =3D vma;
=20
 	for (nstart =3D start ; ; ) {
-		unsigned int newflags;
+		unsigned long long newflags;
=20
 		/* Here we know that  vma->vm_start <=3D nstart < vma->vm_end. */
=20
@@ -540,7 +540,7 @@ static int do_mlockall(int flags)
 		goto out;
=20
 	for (vma =3D current->mm->mmap; vma ; vma =3D prev->vm_next) {
-		unsigned int newflags;
+		unsigned long long newflags;
=20
 		newflags =3D vma->vm_flags | VM_LOCKED;
 		if (!(flags & MCL_CURRENT))
diff --git a/mm/mmap.c b/mm/mmap.c
index b15f9f6..8b96c21 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -76,7 +76,7 @@ pgprot_t protection_map[16] =3D {
 	__S000, __S001, __S010, __S011, __S100, __S101, __S110, __S111
 };
=20
-pgprot_t vm_get_page_prot(unsigned long vm_flags)
+pgprot_t vm_get_page_prot(unsigned long long vm_flags)
 {
 	return __pgprot(pgprot_val(protection_map[vm_flags &
 				(VM_READ|VM_WRITE|VM_EXEC|VM_SHARED)]) |
@@ -667,7 +667,7 @@ again:			remove_next =3D 1 + (end > next->vm_end);
  * per-vma resources, so we don't attempt to merge those.
  */
 static inline int is_mergeable_vma(struct vm_area_struct *vma,
-			struct file *file, unsigned long vm_flags)
+			struct file *file, unsigned long long vm_flags)
 {
 	/* VM_CAN_NONLINEAR may get set later by f_op->mmap() */
 	if ((vma->vm_flags ^ vm_flags) & ~VM_CAN_NONLINEAR)
@@ -705,7 +705,7 @@ static inline int is_mergeable_anon_vma(struct anon_vma=
 *anon_vma1,
  * wrap, nor mmaps which cover the final page at index -1UL.
  */
 static int
-can_vma_merge_before(struct vm_area_struct *vma, unsigned long vm_flags,
+can_vma_merge_before(struct vm_area_struct *vma, unsigned long long vm_fla=
gs,
 	struct anon_vma *anon_vma, struct file *file, pgoff_t vm_pgoff)
 {
 	if (is_mergeable_vma(vma, file, vm_flags) &&
@@ -724,7 +724,7 @@ can_vma_merge_before(struct vm_area_struct *vma, unsign=
ed long vm_flags,
  * anon_vmas, nor if same anon_vma is assigned but offsets incompatible.
  */
 static int
-can_vma_merge_after(struct vm_area_struct *vma, unsigned long vm_flags,
+can_vma_merge_after(struct vm_area_struct *vma, unsigned long long vm_flag=
s,
 	struct anon_vma *anon_vma, struct file *file, pgoff_t vm_pgoff)
 {
 	if (is_mergeable_vma(vma, file, vm_flags) &&
@@ -768,7 +768,7 @@ can_vma_merge_after(struct vm_area_struct *vma, unsigne=
d long vm_flags,
  */
 struct vm_area_struct *vma_merge(struct mm_struct *mm,
 			struct vm_area_struct *prev, unsigned long addr,
-			unsigned long end, unsigned long vm_flags,
+			unsigned long end, unsigned long long vm_flags,
 		     	struct anon_vma *anon_vma, struct file *file,
 			pgoff_t pgoff, struct mempolicy *policy)
 {
@@ -944,19 +944,19 @@ none:
 }
=20
 #ifdef CONFIG_PROC_FS
-void vm_stat_account(struct mm_struct *mm, unsigned long flags,
-						struct file *file, long pages)
+void vm_stat_account(struct mm_struct *mm, unsigned long long vm_flags,
+		     struct file *file, long pages)
 {
-	const unsigned long stack_flags
+	const unsigned long long stack_flags
 		=3D VM_STACK_FLAGS & (VM_GROWSUP|VM_GROWSDOWN);
=20
 	if (file) {
 		mm->shared_vm +=3D pages;
-		if ((flags & (VM_EXEC|VM_WRITE)) =3D=3D VM_EXEC)
+		if ((vm_flags & (VM_EXEC|VM_WRITE)) =3D=3D VM_EXEC)
 			mm->exec_vm +=3D pages;
-	} else if (flags & stack_flags)
+	} else if (vm_flags & stack_flags)
 		mm->stack_vm +=3D pages;
-	if (flags & (VM_RESERVED|VM_IO))
+	if (vm_flags & (VM_RESERVED|VM_IO))
 		mm->reserved_vm +=3D pages;
 }
 #endif /* CONFIG_PROC_FS */
@@ -971,7 +971,7 @@ unsigned long do_mmap_pgoff(struct file *file, unsigned=
 long addr,
 {
 	struct mm_struct * mm =3D current->mm;
 	struct inode *inode;
-	unsigned int vm_flags;
+	unsigned long long vm_flags;
 	int error;
 	unsigned long reqprot =3D prot;
=20
@@ -1176,7 +1176,7 @@ SYSCALL_DEFINE1(old_mmap, struct mmap_arg_struct __us=
er *, arg)
  */
 int vma_wants_writenotify(struct vm_area_struct *vma)
 {
-	unsigned int vm_flags =3D vma->vm_flags;
+	unsigned long long vm_flags =3D vma->vm_flags;
=20
 	/* If it was private or non-writable, the write bit is already clear */
 	if ((vm_flags & (VM_WRITE|VM_SHARED)) !=3D ((VM_WRITE|VM_SHARED)))
@@ -1204,7 +1204,8 @@ int vma_wants_writenotify(struct vm_area_struct *vma)
  * We account for memory if it's a private writeable mapping,
  * not hugepages and VM_NORESERVE wasn't set.
  */
-static inline int accountable_mapping(struct file *file, unsigned int vm_f=
lags)
+static inline int accountable_mapping(struct file *file,
+				      unsigned long long vm_flags)
 {
 	/*
 	 * hugetlb has its own accounting separate from the core VM
@@ -1218,7 +1219,7 @@ static inline int accountable_mapping(struct file *fi=
le, unsigned int vm_flags)
=20
 unsigned long mmap_region(struct file *file, unsigned long addr,
 			  unsigned long len, unsigned long flags,
-			  unsigned int vm_flags, unsigned long pgoff)
+			  unsigned long long vm_flags, unsigned long pgoff)
 {
 	struct mm_struct *mm =3D current->mm;
 	struct vm_area_struct *vma, *prev;
@@ -2157,7 +2158,7 @@ unsigned long do_brk(unsigned long addr, unsigned lon=
g len)
 {
 	struct mm_struct * mm =3D current->mm;
 	struct vm_area_struct * vma, * prev;
-	unsigned long flags;
+	unsigned long long vm_flags;
 	struct rb_node ** rb_link, * rb_parent;
 	pgoff_t pgoff =3D addr >> PAGE_SHIFT;
 	int error;
@@ -2170,7 +2171,7 @@ unsigned long do_brk(unsigned long addr, unsigned lon=
g len)
 	if (error)
 		return error;
=20
-	flags =3D VM_DATA_DEFAULT_FLAGS | VM_ACCOUNT | mm->def_flags;
+	vm_flags =3D VM_DATA_DEFAULT_FLAGS | VM_ACCOUNT | mm->def_flags;
=20
 	error =3D get_unmapped_area(NULL, addr, len, 0, MAP_FIXED);
 	if (error & ~PAGE_MASK)
@@ -2217,7 +2218,7 @@ unsigned long do_brk(unsigned long addr, unsigned lon=
g len)
 		return -ENOMEM;
=20
 	/* Can we just expand an old private anonymous mapping? */
-	vma =3D vma_merge(mm, prev, addr, addr + len, flags,
+	vma =3D vma_merge(mm, prev, addr, addr + len, vm_flags,
 					NULL, NULL, pgoff, NULL);
 	if (vma)
 		goto out;
@@ -2236,13 +2237,13 @@ unsigned long do_brk(unsigned long addr, unsigned l=
ong len)
 	vma->vm_start =3D addr;
 	vma->vm_end =3D addr + len;
 	vma->vm_pgoff =3D pgoff;
-	vma->vm_flags =3D flags;
-	vma->vm_page_prot =3D vm_get_page_prot(flags);
+	vma->vm_flags =3D vm_flags;
+	vma->vm_page_prot =3D vm_get_page_prot(vm_flags);
 	vma_link(mm, vma, prev, rb_link, rb_parent);
 out:
 	perf_event_mmap(vma);
 	mm->total_vm +=3D len >> PAGE_SHIFT;
-	if (flags & VM_LOCKED) {
+	if (vm_flags & VM_LOCKED) {
 		if (!mlock_vma_pages_range(vma, addr, addr + len))
 			mm->locked_vm +=3D (len >> PAGE_SHIFT);
 	}
@@ -2464,7 +2465,7 @@ static const struct vm_operations_struct special_mapp=
ing_vmops =3D {
  */
 int install_special_mapping(struct mm_struct *mm,
 			    unsigned long addr, unsigned long len,
-			    unsigned long vm_flags, struct page **pages)
+			    unsigned long long vm_flags, struct page **pages)
 {
 	int ret;
 	struct vm_area_struct *vma;
diff --git a/mm/mprotect.c b/mm/mprotect.c
index 5a688a2..84d79c5 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -143,10 +143,10 @@ static void change_protection(struct vm_area_struct *=
vma,
=20
 int
 mprotect_fixup(struct vm_area_struct *vma, struct vm_area_struct **pprev,
-	unsigned long start, unsigned long end, unsigned long newflags)
+	unsigned long start, unsigned long end, unsigned long long newflags)
 {
 	struct mm_struct *mm =3D vma->vm_mm;
-	unsigned long oldflags =3D vma->vm_flags;
+	unsigned long long oldflags =3D vma->vm_flags;
 	long nrpages =3D (end - start) >> PAGE_SHIFT;
 	unsigned long charged =3D 0;
 	pgoff_t pgoff;
@@ -232,7 +232,8 @@ fail:
 SYSCALL_DEFINE3(mprotect, unsigned long, start, size_t, len,
 		unsigned long, prot)
 {
-	unsigned long vm_flags, nstart, end, tmp, reqprot;
+	unsigned long long vm_flags;
+	unsigned long nstart, end, tmp, reqprot;
 	struct vm_area_struct *vma, *prev;
 	int error =3D -EINVAL;
 	const int grows =3D prot & (PROT_GROWSDOWN|PROT_GROWSUP);
@@ -288,7 +289,7 @@ SYSCALL_DEFINE3(mprotect, unsigned long, start, size_t,=
 len,
 		prev =3D vma;
=20
 	for (nstart =3D start ; ; ) {
-		unsigned long newflags;
+		unsigned long long newflags;
=20
 		/* Here we know that  vma->vm_start <=3D nstart < vma->vm_end. */
=20
diff --git a/mm/mremap.c b/mm/mremap.c
index 1de98d4..c68c461 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -169,7 +169,7 @@ static unsigned long move_vma(struct vm_area_struct *vm=
a,
 {
 	struct mm_struct *mm =3D vma->vm_mm;
 	struct vm_area_struct *new_vma;
-	unsigned long vm_flags =3D vma->vm_flags;
+	unsigned long long vm_flags =3D vma->vm_flags;
 	unsigned long new_pgoff;
 	unsigned long moved_len;
 	unsigned long excess =3D 0;
diff --git a/mm/nommu.c b/mm/nommu.c
index 92e1a47..610c35c 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -131,7 +131,7 @@ int __get_user_pages(struct task_struct *tsk, struct mm=
_struct *mm,
 		     int *retry)
 {
 	struct vm_area_struct *vma;
-	unsigned long vm_flags;
+	unsigned long long vm_flags;
 	int i;
=20
 	/* calculate required read or write permissions.
@@ -1059,12 +1059,12 @@ static int validate_mmap_request(struct file *file,
  * we've determined that we can make the mapping, now translate what we
  * now know into VMA flags
  */
-static unsigned long determine_vm_flags(struct file *file,
-					unsigned long prot,
-					unsigned long flags,
-					unsigned long capabilities)
+static unsigned long long determine_vm_flags(struct file *file,
+					     unsigned long prot,
+					     unsigned long flags,
+					     unsigned long capabilities)
 {
-	unsigned long vm_flags;
+	unsigned long long vm_flags;
=20
 	vm_flags =3D calc_vm_prot_bits(prot) | calc_vm_flag_bits(flags);
 	/* vm_flags |=3D mm->def_flags; */
@@ -1243,7 +1243,8 @@ unsigned long do_mmap_pgoff(struct file *file,
 	struct vm_area_struct *vma;
 	struct vm_region *region;
 	struct rb_node *rb;
-	unsigned long capabilities, vm_flags, result;
+	unsigned long capabilities, result;
+	unsigned long long vm_flags;
 	int ret;
=20
 	kenter(",%lx,%lx,%lx,%lx,%lx", addr, len, prot, flags, pgoff);
diff --git a/mm/rmap.c b/mm/rmap.c
index 8da044a..725cd74 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -497,7 +497,7 @@ int page_mapped_in_vma(struct page *page, struct vm_are=
a_struct *vma)
  */
 int page_referenced_one(struct page *page, struct vm_area_struct *vma,
 			unsigned long address, unsigned int *mapcount,
-			unsigned long *vm_flags)
+			unsigned long long *vm_flags)
 {
 	struct mm_struct *mm =3D vma->vm_mm;
 	int referenced =3D 0;
@@ -577,7 +577,7 @@ out:
=20
 static int page_referenced_anon(struct page *page,
 				struct mem_cgroup *mem_cont,
-				unsigned long *vm_flags)
+				unsigned long long *vm_flags)
 {
 	unsigned int mapcount;
 	struct anon_vma *anon_vma;
@@ -626,7 +626,7 @@ static int page_referenced_anon(struct page *page,
  */
 static int page_referenced_file(struct page *page,
 				struct mem_cgroup *mem_cont,
-				unsigned long *vm_flags)
+				unsigned long long *vm_flags)
 {
 	unsigned int mapcount;
 	struct address_space *mapping =3D page->mapping;
@@ -692,7 +692,7 @@ static int page_referenced_file(struct page *page,
 int page_referenced(struct page *page,
 		    int is_locked,
 		    struct mem_cgroup *mem_cont,
-		    unsigned long *vm_flags)
+		    unsigned long long *vm_flags)
 {
 	int referenced =3D 0;
 	int we_locked =3D 0;
diff --git a/mm/shmem.c b/mm/shmem.c
index 1250dcd..ed62e3e 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -183,15 +183,15 @@ static inline struct shmem_sb_info *SHMEM_SB(struct s=
uper_block *sb)
  * (unless MAP_NORESERVE and sysctl_overcommit_memory <=3D 1),
  * consistent with the pre-accounting of private mappings ...
  */
-static inline int shmem_acct_size(unsigned long flags, loff_t size)
+static inline int shmem_acct_size(unsigned long long vm_flags, loff_t size=
)
 {
-	return (flags & VM_NORESERVE) ?
+	return (vm_flags & VM_NORESERVE) ?
 		0 : security_vm_enough_memory_kern(VM_ACCT(size));
 }
=20
-static inline void shmem_unacct_size(unsigned long flags, loff_t size)
+static inline void shmem_unacct_size(unsigned long long vm_flags, loff_t s=
ize)
 {
-	if (!(flags & VM_NORESERVE))
+	if (!(vm_flags & VM_NORESERVE))
 		vm_unacct_memory(VM_ACCT(size));
 }
=20
@@ -1575,7 +1575,7 @@ static int shmem_mmap(struct file *file, struct vm_ar=
ea_struct *vma)
 }
=20
 static struct inode *shmem_get_inode(struct super_block *sb, const struct =
inode *dir,
-				     int mode, dev_t dev, unsigned long flags)
+				     int mode, dev_t dev, unsigned long long vm_flags)
 {
 	struct inode *inode;
 	struct shmem_inode_info *info;
@@ -1595,7 +1595,7 @@ static struct inode *shmem_get_inode(struct super_blo=
ck *sb, const struct inode
 		info =3D SHMEM_I(inode);
 		memset(info, 0, (char *)inode - (char *)info);
 		spin_lock_init(&info->lock);
-		info->flags =3D flags & VM_NORESERVE;
+		info->flags =3D vm_flags & VM_NORESERVE;
 		INIT_LIST_HEAD(&info->swaplist);
 		cache_no_acl(inode);
=20
@@ -2704,7 +2704,7 @@ out:
=20
 #define shmem_vm_ops				generic_file_vm_ops
 #define shmem_file_operations			ramfs_file_operations
-#define shmem_get_inode(sb, dir, mode, dev, flags)	ramfs_get_inode(sb, dir=
, mode, dev)
+#define shmem_get_inode(sb, dir, mode, dev, vm_flags)	ramfs_get_inode(sb, =
dir, mode, dev)
 #define shmem_acct_size(flags, size)		0
 #define shmem_unacct_size(flags, size)		do {} while (0)
 #define SHMEM_MAX_BYTES				MAX_LFS_FILESIZE
@@ -2719,7 +2719,7 @@ out:
  * @size: size to be set for the file
  * @flags: VM_NORESERVE suppresses pre-accounting of the entire object siz=
e
  */
-struct file *shmem_file_setup(const char *name, loff_t size, unsigned long=
 flags)
+struct file *shmem_file_setup(const char *name, loff_t size, unsigned long=
 long vm_flags)
 {
 	int error;
 	struct file *file;
@@ -2734,7 +2734,7 @@ struct file *shmem_file_setup(const char *name, loff_=
t size, unsigned long flags
 	if (size < 0 || size > SHMEM_MAX_BYTES)
 		return ERR_PTR(-EINVAL);
=20
-	if (shmem_acct_size(flags, size))
+	if (shmem_acct_size(vm_flags, size))
 		return ERR_PTR(-ENOMEM);
=20
 	error =3D -ENOMEM;
@@ -2748,7 +2748,7 @@ struct file *shmem_file_setup(const char *name, loff_=
t size, unsigned long flags
 	path.mnt =3D mntget(shm_mnt);
=20
 	error =3D -ENOSPC;
-	inode =3D shmem_get_inode(root->d_sb, NULL, S_IFREG | S_IRWXUGO, 0, flags=
);
+	inode =3D shmem_get_inode(root->d_sb, NULL, S_IFREG | S_IRWXUGO, 0, vm_fl=
ags);
 	if (!inode)
 		goto put_dentry;
=20
@@ -2772,7 +2772,7 @@ struct file *shmem_file_setup(const char *name, loff_=
t size, unsigned long flags
 put_dentry:
 	path_put(&path);
 put_memory:
-	shmem_unacct_size(flags, size);
+	shmem_unacct_size(vm_flags, size);
 	return ERR_PTR(error);
 }
 EXPORT_SYMBOL_GPL(shmem_file_setup);
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 0c5a3d6..cd72e59 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -632,7 +632,7 @@ static enum page_references page_check_references(struc=
t page *page,
 						  struct scan_control *sc)
 {
 	int referenced_ptes, referenced_page;
-	unsigned long vm_flags;
+	unsigned long long vm_flags;
=20
 	referenced_ptes =3D page_referenced(page, 1, sc->mem_cgroup, &vm_flags);
 	referenced_page =3D TestClearPageReferenced(page);
@@ -1504,7 +1504,7 @@ static void shrink_active_list(unsigned long nr_pages=
, struct zone *zone,
 {
 	unsigned long nr_taken;
 	unsigned long pgscanned;
-	unsigned long vm_flags;
+	unsigned long long vm_flags;
 	LIST_HEAD(l_hold);	/* The pages which were snipped off */
 	LIST_HEAD(l_active);
 	LIST_HEAD(l_inactive);
--=20
1.7.3.1



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
