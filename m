Date: Mon, 13 Nov 2006 17:00:09 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: RE: [hugepage] Fix unmap_and_free_vma backout path
In-Reply-To: <000301c706f6$4ae26160$a081030a@amr.corp.intel.com>
Message-ID: <Pine.LNX.4.64.0611131650140.8280@blonde.wat.veritas.com>
References: <000301c706f6$4ae26160$a081030a@amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: 'David Gibson' <david@gibson.dropbear.id.au>, 'Christoph Lameter' <clameter@sgi.com>, 'Andrew Morton' <akpm@osdl.org>, bill.irwin@oracle.com, 'Adam Litke' <agl@us.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 12 Nov 2006, Chen, Kenneth W wrote:
> David Gibson wrote on Sunday, November 12, 2006 10:23 PM
> > > 
> > > Something like this?  I haven't tested it yet.  But looks plausible
> > > because we already have if is_file_hugepages() in the generic path.
> > 
> > Um.. if you're going to test pgoff here, you should also test the
> > address.
> 
> prepare_hugepage_range() should catch misaligned memory address, right?
> What more does get_unmapped_area() need to test?

David made that remark, I see now, because PowerPC alone omits to
check address and length alignment in its prepare_hugepage_range:
it should be checking those as ia64 and generic do.

> 
> > Oh, and that point is too late to catch MAP_FIXED mappings.
> 
> I don't understand what you mean by that.
> In do_mmap_pgoff(), very early in the code it tries to get an valid
> virtual address:
> 
>         addr = get_unmapped_area(file, addr, len, pgoff, flags);
>         if (addr & ~PAGE_MASK)
>                 return addr;
> 
> We don't even have a vma at this point, there is no error to recover.
> If get_unmapped_area() tests the validity of pgoff and return an error
> code, the immediate two lines of code will catch that and everything
> stops there.  I don't see where the unmap gets called here.  Did I
> miss something?

I agree with Ken on that.  I agree with just about everything said by
people so far.  But I think the check looks nicer tucked away with the
other alignment checks in prepare_hugepage_range: how about this version?
(Perhaps, in another mood, I've have chosen BUG_ONs instead of just
deleting all the redundant tests - another deleted in the ppc case.)


[PATCH] hugetlb: prepare_hugepage_range check offset too

prepare_hugepage_range should check file offset alignment when it checks
virtual address and length, to stop MAP_FIXED with a bad huge offset from
unmapping before it fails further down.  PowerPC should apply the same
prepare_hugepage_range alignment checks as ia64 and all the others do.

Then none of the alignment checks in hugetlbfs_file_mmap are required
(nor is the check for too small a mapping); but even so, move up setting
of VM_HUGETLB and add a comment to warn of what David Gibson discovered -
if hugetlbfs_file_mmap fails before setting it, do_mmap_pgoff's unmap_region
when unwinding from error will go the non-huge way, which may cause bad
behaviour on architectures (powerpc and ia64) which segregate their huge
mappings into a separate region of the address space.

Signed-off-by: Hugh Dickins <hugh@veritas.com>
---

 arch/ia64/mm/hugetlbpage.c    |    4 +++-
 arch/powerpc/mm/hugetlbpage.c |    8 ++++++--
 fs/hugetlbfs/inode.c          |   21 ++++++++-------------
 include/linux/hugetlb.h       |   10 +++++++---
 mm/mmap.c                     |    2 +-
 5 files changed, 25 insertions(+), 20 deletions(-)

--- 2.6.19-rc5/arch/ia64/mm/hugetlbpage.c	2006-09-20 04:42:06.000000000 +0100
+++ linux/arch/ia64/mm/hugetlbpage.c	2006-11-13 15:37:04.000000000 +0000
@@ -70,8 +70,10 @@ huge_pte_offset (struct mm_struct *mm, u
  * Don't actually need to do any preparation, but need to make sure
  * the address is in the right region.
  */
-int prepare_hugepage_range(unsigned long addr, unsigned long len)
+int prepare_hugepage_range(unsigned long addr, unsigned long len, pgoff_t pgoff)
 {
+	if (pgoff & (~HPAGE_MASK >> PAGE_SHIFT))
+		return -EINVAL;
 	if (len & ~HPAGE_MASK)
 		return -EINVAL;
 	if (addr & ~HPAGE_MASK)
--- 2.6.19-rc5/arch/powerpc/mm/hugetlbpage.c	2006-11-08 08:30:56.000000000 +0000
+++ linux/arch/powerpc/mm/hugetlbpage.c	2006-11-13 15:37:04.000000000 +0000
@@ -491,11 +491,15 @@ static int open_high_hpage_areas(struct 
 	return 0;
 }
 
-int prepare_hugepage_range(unsigned long addr, unsigned long len)
+int prepare_hugepage_range(unsigned long addr, unsigned long len, pgoff_t pgoff)
 {
 	int err = 0;
 
-	if ( (addr+len) < addr )
+	if (pgoff & (~HPAGE_MASK >> PAGE_SHIFT))
+		return -EINVAL;
+	if (len & ~HPAGE_MASK)
+		return -EINVAL;
+	if (addr & ~HPAGE_MASK)
 		return -EINVAL;
 
 	if (addr < 0x100000000UL)
--- 2.6.19-rc5/fs/hugetlbfs/inode.c	2006-11-08 08:31:14.000000000 +0000
+++ linux/fs/hugetlbfs/inode.c	2006-11-13 15:37:04.000000000 +0000
@@ -62,24 +62,19 @@ static int hugetlbfs_file_mmap(struct fi
 	loff_t len, vma_len;
 	int ret;
 
-	if (vma->vm_pgoff & (HPAGE_SIZE / PAGE_SIZE - 1))
-		return -EINVAL;
-
-	if (vma->vm_start & ~HPAGE_MASK)
-		return -EINVAL;
-
-	if (vma->vm_end & ~HPAGE_MASK)
-		return -EINVAL;
-
-	if (vma->vm_end - vma->vm_start < HPAGE_SIZE)
-		return -EINVAL;
+	/*
+	 * vma alignment has already been checked by prepare_hugepage_range.
+	 * If you add any error returns here, do so after setting VM_HUGETLB,
+	 * so is_vm_huge_tlb_page tests below unmap_region go the right way
+	 * when do_mmap_pgoff unwinds (may be important on powerpc and ia64).
+	 */
+	vma->vm_flags |= VM_HUGETLB | VM_RESERVED;
+	vma->vm_ops = &hugetlb_vm_ops;
 
 	vma_len = (loff_t)(vma->vm_end - vma->vm_start);
 
 	mutex_lock(&inode->i_mutex);
 	file_accessed(file);
-	vma->vm_flags |= VM_HUGETLB | VM_RESERVED;
-	vma->vm_ops = &hugetlb_vm_ops;
 
 	ret = -ENOMEM;
 	len = vma_len + ((loff_t)vma->vm_pgoff << PAGE_SHIFT);
--- 2.6.19-rc5/include/linux/hugetlb.h	2006-11-08 08:31:21.000000000 +0000
+++ linux/include/linux/hugetlb.h	2006-11-13 15:37:04.000000000 +0000
@@ -60,8 +60,11 @@ void hugetlb_free_pgd_range(struct mmu_g
  * If the arch doesn't supply something else, assume that hugepage
  * size aligned regions are ok without further preparation.
  */
-static inline int prepare_hugepage_range(unsigned long addr, unsigned long len)
+static inline int prepare_hugepage_range(unsigned long addr, unsigned long len,
+						pgoff_t pgoff)
 {
+	if (pgoff & (~HPAGE_MASK >> PAGE_SHIFT))
+		return -EINVAL;
 	if (len & ~HPAGE_MASK)
 		return -EINVAL;
 	if (addr & ~HPAGE_MASK)
@@ -69,7 +72,8 @@ static inline int prepare_hugepage_range
 	return 0;
 }
 #else
-int prepare_hugepage_range(unsigned long addr, unsigned long len);
+int prepare_hugepage_range(unsigned long addr, unsigned long len,
+						pgoff_t pgoff);
 #endif
 
 #ifndef ARCH_HAS_SETCLEAR_HUGE_PTE
@@ -107,7 +111,7 @@ static inline unsigned long hugetlb_tota
 #define hugetlb_report_meminfo(buf)		0
 #define hugetlb_report_node_meminfo(n, buf)	0
 #define follow_huge_pmd(mm, addr, pmd, write)	NULL
-#define prepare_hugepage_range(addr, len)	(-EINVAL)
+#define prepare_hugepage_range(addr,len,pgoff)	(-EINVAL)
 #define pmd_huge(x)	0
 #define is_hugepage_only_range(mm, addr, len)	0
 #define hugetlb_free_pgd_range(tlb, addr, end, floor, ceiling) ({BUG(); 0; })
--- 2.6.19-rc5/mm/mmap.c	2006-11-08 08:31:23.000000000 +0000
+++ linux/mm/mmap.c	2006-11-13 15:37:04.000000000 +0000
@@ -1379,7 +1379,7 @@ get_unmapped_area(struct file *file, uns
 		 * Check if the given range is hugepage aligned, and
 		 * can be made suitable for hugepages.
 		 */
-		ret = prepare_hugepage_range(addr, len);
+		ret = prepare_hugepage_range(addr, len, pgoff);
 	} else {
 		/*
 		 * Ensure that a normal request is not falling in a

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
