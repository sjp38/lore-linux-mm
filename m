From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 2/2] Report the MMU pagesize in /proc/pid/smaps
Date: Thu, 16 Oct 2008 16:58:35 +0100
Message-Id: <1224172715-17667-3-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1224172715-17667-1-git-send-email-mel@csn.ul.ie>
References: <1224172715-17667-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Alexey Dobriyan <adobriyan@gmail.com>, Dave Hansen <dave@linux.vnet.ibm.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

The KernelPageSize entry in /proc/pid/smaps is the pagesize used by the
kernel to back a VMA. This matches the size used by the MMU in the majority
of cases. However, one counter-example occurs on PPC64 kernels whereby
a kernel using 64K as a base pagesize may still use 4K pages for the MMU
on older processor. To distinguish, this patch reports MMUPageSize as the
pagesize used by the MMU in /proc/pid/smaps.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 arch/powerpc/include/asm/hugetlb.h |    6 ++++++
 arch/powerpc/mm/hugetlbpage.c      |    7 +++++++
 fs/proc/task_mmu.c                 |    6 ++++--
 include/linux/hugetlb.h            |    3 +++
 mm/hugetlb.c                       |   13 +++++++++++++
 5 files changed, 33 insertions(+), 2 deletions(-)

diff --git a/arch/powerpc/include/asm/hugetlb.h b/arch/powerpc/include/asm/hugetlb.h
index 26f0d0a..2655146 100644
--- a/arch/powerpc/include/asm/hugetlb.h
+++ b/arch/powerpc/include/asm/hugetlb.h
@@ -18,6 +18,12 @@ pte_t huge_ptep_get_and_clear(struct mm_struct *mm, unsigned long addr,
 			      pte_t *ptep);
 
 /*
+ * The version of vma_mmu_pagesize() in arch/powerpc/mm/hugetlbpage.c needs
+ * to override the version in mm/hugetlb.c
+ */
+#define vma_mmu_pagesize vma_mmu_pagesize
+
+/*
  * If the arch doesn't supply something else, assume that hugepage
  * size aligned regions are ok without further preparation.
  */
diff --git a/arch/powerpc/mm/hugetlbpage.c b/arch/powerpc/mm/hugetlbpage.c
index a117024..edc0c69 100644
--- a/arch/powerpc/mm/hugetlbpage.c
+++ b/arch/powerpc/mm/hugetlbpage.c
@@ -510,6 +510,13 @@ unsigned long hugetlb_get_unmapped_area(struct file *file, unsigned long addr,
 	return slice_get_unmapped_area(addr, len, flags, mmu_psize, 1, 0);
 }
 
+unsigned long vma_mmu_pagesize(struct vm_area_struct *vma)
+{
+	unsigned int psize = get_slice_psize(vma->vm_mm, vma->vm_start);
+
+	return 1UL << mmu_psize_to_shift(psize);
+}
+
 /*
  * Called by asm hashtable.S for doing lazy icache flush
  */
diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 71c9868..3517892 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -392,7 +392,8 @@ static int show_smap(struct seq_file *m, void *v)
 		   "Private_Dirty:  %8lu kB\n"
 		   "Referenced:     %8lu kB\n"
 		   "Swap:           %8lu kB\n"
-		   "KernelPageSize: %8lu kB\n",
+		   "KernelPageSize: %8lu kB\n"
+		   "MMUPageSize:    %8lu kB\n",
 		   (vma->vm_end - vma->vm_start) >> 10,
 		   mss.resident >> 10,
 		   (unsigned long)(mss.pss >> (10 + PSS_SHIFT)),
@@ -402,7 +403,8 @@ static int show_smap(struct seq_file *m, void *v)
 		   mss.private_dirty >> 10,
 		   mss.referenced >> 10,
 		   mss.swap >> 10,
-		   vma_kernel_pagesize(vma) >> 10);
+		   vma_kernel_pagesize(vma) >> 10,
+		   vma_mmu_pagesize(vma) >> 10);
 
 	return ret;
 }
diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index ace04a7..5056021 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -233,6 +233,8 @@ static inline unsigned long huge_page_size(struct hstate *h)
 
 extern unsigned long vma_kernel_pagesize(struct vm_area_struct *vma);
 
+extern unsigned long vma_mmu_pagesize(struct vm_area_struct *vma);
+
 static inline unsigned long huge_page_mask(struct hstate *h)
 {
 	return h->mask;
@@ -274,6 +276,7 @@ struct hstate {};
 #define huge_page_size(h) PAGE_SIZE
 #define huge_page_mask(h) PAGE_MASK
 #define vma_kernel_pagesize(v) PAGE_SIZE
+#define vma_mmu_pagesize(v) PAGE_SIZE
 #define huge_page_order(h) 0
 #define huge_page_shift(h) PAGE_SHIFT
 static inline unsigned int pages_per_huge_page(struct hstate *h)
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 7cb27ec..fee3d1d 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -235,6 +235,19 @@ unsigned long vma_kernel_pagesize(struct vm_area_struct *vma)
 }
 
 /*
+ * Return the page size being used by the MMU to back a VMA. In the majority
+ * of cases, the page size used by the kernel matches the MMU size. On
+ * architectures where it differs, an architecture-specific version of this
+ * function is required.
+ */
+#ifndef vma_mmu_pagesize
+unsigned long vma_mmu_pagesize(struct vm_area_struct *vma)
+{
+	return vma_kernel_pagesize(vma);
+}
+#endif
+
+/*
  * Flags for MAP_PRIVATE reservations.  These are stored in the bottom
  * bits of the reservation map pointer, which are always clear due to
  * alignment.
-- 
1.5.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
