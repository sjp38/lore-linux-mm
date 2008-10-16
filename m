From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 1/2] Subject: [PATCH] Report the pagesize backing a VMA in /proc/pid/smaps
Date: Thu, 16 Oct 2008 16:58:34 +0100
Message-Id: <1224172715-17667-2-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1224172715-17667-1-git-send-email-mel@csn.ul.ie>
References: <1224172715-17667-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Alexey Dobriyan <adobriyan@gmail.com>, Dave Hansen <dave@linux.vnet.ibm.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

It is useful to verify a hugepage-aware application is using the expected
pagesizes for its memory regions. This patch creates an entry called
KernelPageSize in /proc/pid/smaps that is the size of page used by the
kernel to back a VMA. The entry is not called PageSize as it is possible
the MMU uses a different size. This extension should not break any sensible
parser that skips lines containing unrecognised information.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 fs/proc/task_mmu.c      |    6 ++++--
 include/linux/hugetlb.h |    3 +++
 mm/hugetlb.c            |   16 ++++++++++++++++
 3 files changed, 23 insertions(+), 2 deletions(-)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 4806830..71c9868 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -391,7 +391,8 @@ static int show_smap(struct seq_file *m, void *v)
 		   "Private_Clean:  %8lu kB\n"
 		   "Private_Dirty:  %8lu kB\n"
 		   "Referenced:     %8lu kB\n"
-		   "Swap:           %8lu kB\n",
+		   "Swap:           %8lu kB\n"
+		   "KernelPageSize: %8lu kB\n",
 		   (vma->vm_end - vma->vm_start) >> 10,
 		   mss.resident >> 10,
 		   (unsigned long)(mss.pss >> (10 + PSS_SHIFT)),
@@ -400,7 +401,8 @@ static int show_smap(struct seq_file *m, void *v)
 		   mss.private_clean >> 10,
 		   mss.private_dirty >> 10,
 		   mss.referenced >> 10,
-		   mss.swap >> 10);
+		   mss.swap >> 10,
+		   vma_kernel_pagesize(vma) >> 10);
 
 	return ret;
 }
diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 32e0ef0..ace04a7 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -231,6 +231,8 @@ static inline unsigned long huge_page_size(struct hstate *h)
 	return (unsigned long)PAGE_SIZE << h->order;
 }
 
+extern unsigned long vma_kernel_pagesize(struct vm_area_struct *vma);
+
 static inline unsigned long huge_page_mask(struct hstate *h)
 {
 	return h->mask;
@@ -271,6 +273,7 @@ struct hstate {};
 #define hstate_inode(i) NULL
 #define huge_page_size(h) PAGE_SIZE
 #define huge_page_mask(h) PAGE_MASK
+#define vma_kernel_pagesize(v) PAGE_SIZE
 #define huge_page_order(h) 0
 #define huge_page_shift(h) PAGE_SHIFT
 static inline unsigned int pages_per_huge_page(struct hstate *h)
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 67a7119..7cb27ec 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -219,6 +219,22 @@ static pgoff_t vma_hugecache_offset(struct hstate *h,
 }
 
 /*
+ * Return the size of the pages allocated when backing a VMA. In the majority
+ * cases this will be same size as used by the page table entries.
+ */
+unsigned long vma_kernel_pagesize(struct vm_area_struct *vma)
+{
+	struct hstate *hstate;
+
+	if (!is_vm_hugetlb_page(vma))
+		return PAGE_SIZE;
+
+	hstate = hstate_vma(vma);
+
+	return 1UL << (hstate->order + PAGE_SHIFT);
+}
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
