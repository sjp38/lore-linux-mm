Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id 43FF36B0083
	for <linux-mm@kvack.org>; Sat, 31 Mar 2012 05:29:24 -0400 (EDT)
Received: by mail-bk0-f41.google.com with SMTP id q16so1494120bkw.14
        for <linux-mm@kvack.org>; Sat, 31 Mar 2012 02:29:23 -0700 (PDT)
Subject: [PATCH 4/7] mm: kill vma flag VM_INSERTPAGE
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Sat, 31 Mar 2012 13:29:19 +0400
Message-ID: <20120331092919.19920.72179.stgit@zurg>
In-Reply-To: <20120331091049.19373.28994.stgit@zurg>
References: <20120331091049.19373.28994.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: Nick Piggin <npiggin@suse.de>, Carsten Otte <cotte@de.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>

This patch merges VM_INSERTPAGE into VM_MIXEDMAP (and moves it near to VM_PFNMAP).
VM_MIXEDMAP vma anyway can mix pure-pfn ptes, special ptes and normal ptes.

this patch side-effects:
* copy_page_range() now always copies VM_MIXEDMAP vma on fork (why not?)
* in case HAVE_PTE_SPECIAL appears non-special ptes in VM_MIXEDMAP vma.
  seems like all ok, all code ready for this.
* in case !HAVE_PTE_SPECIAL: vm_normal_page() will check pfn_valid() after
  inserting pages via vm_insert_page()
* small change in vma_wants_writenotify(), seems like do_wp_page() can handle this.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Nick Piggin <npiggin@suse.de>
Cc: Carsten Otte <cotte@de.ibm.com>
---
 include/linux/mm.h |    3 +--
 mm/huge_memory.c   |    3 +--
 mm/ksm.c           |    2 +-
 mm/memory.c        |   14 ++++++++++++--
 mm/mmap.c          |    2 +-
 5 files changed, 16 insertions(+), 8 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 0dad037..553d134 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -84,6 +84,7 @@ extern unsigned int kobjsize(const void *objp);
 #define VM_MAYSHARE	0x00000080
 
 #define VM_GROWSDOWN	0x00000100	/* general info on the segment */
+#define VM_MIXEDMAP	0x00000200	/* Can contain "struct page" and pure PFN pages */
 #define VM_PFNMAP	0x00000400	/* Page-ranges managed without "struct page", just pure PFN */
 #define VM_DENYWRITE	0x00000800	/* ETXTBSY on write attempts.. */
 
@@ -103,10 +104,8 @@ extern unsigned int kobjsize(const void *objp);
 #define VM_HUGETLB	0x00400000	/* Huge TLB Page VM */
 #define VM_NONLINEAR	0x00800000	/* Is non-linear (remap_file_pages) */
 #define VM_ARCH_1	0x01000000	/* Architecture-specific flag */
-#define VM_INSERTPAGE	0x02000000	/* The vma has had "vm_insert_page()" done on it */
 #define VM_NODUMP	0x04000000	/* Do not include in the core dump */
 
-#define VM_MIXEDMAP	0x10000000	/* Can contain "struct page" and pure PFN pages */
 #define VM_HUGEPAGE	0x20000000	/* MADV_HUGEPAGE marked this vma */
 #define VM_NOHUGEPAGE	0x40000000	/* MADV_NOHUGEPAGE marked this vma */
 #define VM_MERGEABLE	0x80000000	/* KSM may merge identical pages */
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 6ea5477..65ed599 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1482,8 +1482,7 @@ out:
 	return ret;
 }
 
-#define VM_NO_THP (VM_SPECIAL|VM_INSERTPAGE|VM_MIXEDMAP| \
-		   VM_HUGETLB|VM_SHARED|VM_MAYSHARE)
+#define VM_NO_THP (VM_SPECIAL|VM_MIXEDMAP|VM_HUGETLB|VM_SHARED|VM_MAYSHARE)
 
 int hugepage_madvise(struct vm_area_struct *vma,
 		     unsigned long *vm_flags, int advice)
diff --git a/mm/ksm.c b/mm/ksm.c
index d1cbe2a..f9ccb16 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -1469,7 +1469,7 @@ int ksm_madvise(struct vm_area_struct *vma, unsigned long start,
 		 */
 		if (*vm_flags & (VM_MERGEABLE | VM_SHARED  | VM_MAYSHARE   |
 				 VM_PFNMAP    | VM_IO      | VM_DONTEXPAND |
-				 VM_RESERVED  | VM_HUGETLB | VM_INSERTPAGE |
+				 VM_RESERVED  | VM_HUGETLB |
 				 VM_NONLINEAR | VM_MIXEDMAP))
 			return 0;		/* just ignore the advice */
 
diff --git a/mm/memory.c b/mm/memory.c
index e6e4dfd..9b8db37 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1043,7 +1043,8 @@ int copy_page_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 	 * readonly mappings. The tradeoff is that copy_page_range is more
 	 * efficient than faulting.
 	 */
-	if (!(vma->vm_flags & (VM_HUGETLB|VM_NONLINEAR|VM_PFNMAP|VM_INSERTPAGE))) {
+	if (!(vma->vm_flags & (VM_HUGETLB | VM_NONLINEAR |
+			       VM_PFNMAP | VM_MIXEDMAP))) {
 		if (!vma->anon_vma)
 			return 0;
 	}
@@ -2068,6 +2069,11 @@ out:
  * ask for a shared writable mapping!
  *
  * The page does not need to be reserved.
+ *
+ * Usually this function is called from f_op->mmap() handler
+ * under mm->mmap_sem write-lock, so it can change vma->vm_flags.
+ * Caller must set VM_MIXEDMAP on vma if it wants to call this
+ * function from other places, for example from page-fault handler.
  */
 int vm_insert_page(struct vm_area_struct *vma, unsigned long addr,
 			struct page *page)
@@ -2076,7 +2082,11 @@ int vm_insert_page(struct vm_area_struct *vma, unsigned long addr,
 		return -EFAULT;
 	if (!page_count(page))
 		return -EINVAL;
-	vma->vm_flags |= VM_INSERTPAGE;
+	if (!(vma->vm_flags & VM_MIXEDMAP)) {
+		VM_BUG_ON(down_read_trylock(&vma->vm_mm->mmap_sem));
+		VM_BUG_ON(vma->vm_flags & VM_PFNMAP);
+		vma->vm_flags |= VM_MIXEDMAP;
+	}
 	return insert_page(vma, addr, page, vma->vm_page_prot);
 }
 EXPORT_SYMBOL(vm_insert_page);
diff --git a/mm/mmap.c b/mm/mmap.c
index 1a23d2c..3d254ca 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1177,7 +1177,7 @@ int vma_wants_writenotify(struct vm_area_struct *vma)
 		return 0;
 
 	/* Specialty mapping? */
-	if (vm_flags & (VM_PFNMAP|VM_INSERTPAGE))
+	if (vm_flags & VM_PFNMAP)
 		return 0;
 
 	/* Can the mapping track the dirty pages? */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
