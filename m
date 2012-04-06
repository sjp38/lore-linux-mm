Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 34B706B00EB
	for <linux-mm@kvack.org>; Fri,  6 Apr 2012 14:51:44 -0400 (EDT)
Received: from /spool/local
	by e28smtp02.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Sat, 7 Apr 2012 00:21:40 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q36IpTwT4571290
	for <linux-mm@kvack.org>; Sat, 7 Apr 2012 00:21:29 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q370LvYd007356
	for <linux-mm@kvack.org>; Sat, 7 Apr 2012 10:21:58 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH -V5 04/14] hugetlb: Use mmu_gather instead of a temporary linked list for accumulating pages
Date: Sat,  7 Apr 2012 00:20:50 +0530
Message-Id: <1333738260-1329-5-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1333738260-1329-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1333738260-1329-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, mgorman@suse.de, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, aarcange@redhat.com, mhocko@suse.cz, akpm@linux-foundation.org, hannes@cmpxchg.org
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

Use mmu_gather instead of temporary linked list for accumulating pages when
we unmap a hugepage range. This also allows us to get rid of i_mmap_mutex
unmap_hugepage_range in the following patch.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 fs/hugetlbfs/inode.c    |    4 ++--
 include/linux/hugetlb.h |    6 ++---
 mm/hugetlb.c            |   59 ++++++++++++++++++++++++++++-------------------
 mm/memory.c             |    7 ++++--
 4 files changed, 45 insertions(+), 31 deletions(-)

diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index ea25174..92f75aa 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -416,8 +416,8 @@ hugetlb_vmtruncate_list(struct prio_tree_root *root, pgoff_t pgoff)
 		else
 			v_offset = 0;
 
-		__unmap_hugepage_range(vma,
-				vma->vm_start + v_offset, vma->vm_end, NULL);
+		unmap_hugepage_range(vma, vma->vm_start + v_offset,
+				     vma->vm_end, NULL);
 	}
 }
 
diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 876457e..46c6cbd 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -40,9 +40,9 @@ int follow_hugetlb_page(struct mm_struct *, struct vm_area_struct *,
 			struct page **, struct vm_area_struct **,
 			unsigned long *, int *, int, unsigned int flags);
 void unmap_hugepage_range(struct vm_area_struct *,
-			unsigned long, unsigned long, struct page *);
-void __unmap_hugepage_range(struct vm_area_struct *,
-			unsigned long, unsigned long, struct page *);
+			  unsigned long, unsigned long, struct page *);
+void __unmap_hugepage_range(struct mmu_gather *tlb, struct vm_area_struct *,
+			    unsigned long, unsigned long, struct page *);
 int hugetlb_prefault(struct address_space *, struct vm_area_struct *);
 void hugetlb_report_meminfo(struct seq_file *);
 int hugetlb_report_node_meminfo(int, char *);
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index d94c987..a3ac624 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -24,8 +24,9 @@
 
 #include <asm/page.h>
 #include <asm/pgtable.h>
-#include <linux/io.h>
+#include <asm/tlb.h>
 
+#include <linux/io.h>
 #include <linux/hugetlb.h>
 #include <linux/node.h>
 #include "internal.h"
@@ -2300,30 +2301,26 @@ static int is_hugetlb_entry_hwpoisoned(pte_t pte)
 		return 0;
 }
 
-void __unmap_hugepage_range(struct vm_area_struct *vma, unsigned long start,
-			    unsigned long end, struct page *ref_page)
+void __unmap_hugepage_range(struct mmu_gather *tlb, struct vm_area_struct *vma,
+			    unsigned long start, unsigned long end,
+			    struct page *ref_page)
 {
+	int force_flush = 0;
 	struct mm_struct *mm = vma->vm_mm;
 	unsigned long address;
 	pte_t *ptep;
 	pte_t pte;
 	struct page *page;
-	struct page *tmp;
 	struct hstate *h = hstate_vma(vma);
 	unsigned long sz = huge_page_size(h);
 
-	/*
-	 * A page gathering list, protected by per file i_mmap_mutex. The
-	 * lock is used to avoid list corruption from multiple unmapping
-	 * of the same page since we are using page->lru.
-	 */
-	LIST_HEAD(page_list);
-
 	WARN_ON(!is_vm_hugetlb_page(vma));
 	BUG_ON(start & ~huge_page_mask(h));
 	BUG_ON(end & ~huge_page_mask(h));
 
+	tlb_start_vma(tlb, vma);
 	mmu_notifier_invalidate_range_start(mm, start, end);
+again:
 	spin_lock(&mm->page_table_lock);
 	for (address = start; address < end; address += sz) {
 		ptep = huge_pte_offset(mm, address);
@@ -2362,30 +2359,45 @@ void __unmap_hugepage_range(struct vm_area_struct *vma, unsigned long start,
 		}
 
 		pte = huge_ptep_get_and_clear(mm, address, ptep);
+		tlb_remove_tlb_entry(tlb, ptep, address);
 		if (pte_dirty(pte))
 			set_page_dirty(page);
-		list_add(&page->lru, &page_list);
 
+		page_remove_rmap(page);
+		force_flush = !__tlb_remove_page(tlb, page);
+		if (force_flush)
+			break;
 		/* Bail out after unmapping reference page if supplied */
 		if (ref_page)
 			break;
 	}
-	flush_tlb_range(vma, start, end);
 	spin_unlock(&mm->page_table_lock);
-	mmu_notifier_invalidate_range_end(mm, start, end);
-	list_for_each_entry_safe(page, tmp, &page_list, lru) {
-		page_remove_rmap(page);
-		list_del(&page->lru);
-		put_page(page);
+	/*
+	 * mmu_gather ran out of room to batch pages, we break out of
+	 * the PTE lock to avoid doing the potential expensive TLB invalidate
+	 * and page-free while holding it.
+	 */
+	if (force_flush) {
+		force_flush = 0;
+		tlb_flush_mmu(tlb);
+		if (address < end && !ref_page)
+			goto again;
 	}
+	mmu_notifier_invalidate_range_end(mm, start, end);
+	tlb_end_vma(tlb, vma);
 }
 
 void unmap_hugepage_range(struct vm_area_struct *vma, unsigned long start,
 			  unsigned long end, struct page *ref_page)
 {
-	mutex_lock(&vma->vm_file->f_mapping->i_mmap_mutex);
-	__unmap_hugepage_range(vma, start, end, ref_page);
-	mutex_unlock(&vma->vm_file->f_mapping->i_mmap_mutex);
+	struct mm_struct *mm;
+	struct mmu_gather tlb;
+
+	mm = vma->vm_mm;
+
+	tlb_gather_mmu(&tlb, mm, 0);
+	__unmap_hugepage_range(&tlb, vma, start, end, ref_page);
+	tlb_finish_mmu(&tlb, start, end);
 }
 
 /*
@@ -2430,9 +2442,8 @@ static int unmap_ref_private(struct mm_struct *mm, struct vm_area_struct *vma,
 		 * from the time of fork. This would look like data corruption
 		 */
 		if (!is_vma_resv_set(iter_vma, HPAGE_RESV_OWNER))
-			__unmap_hugepage_range(iter_vma,
-				address, address + huge_page_size(h),
-				page);
+			unmap_hugepage_range(iter_vma, address,
+					     address + huge_page_size(h), page);
 	}
 	mutex_unlock(&mapping->i_mmap_mutex);
 
diff --git a/mm/memory.c b/mm/memory.c
index 6105f47..4b11961 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1326,8 +1326,11 @@ static void unmap_single_vma(struct mmu_gather *tlb,
 			 * Since no pte has actually been setup, it is
 			 * safe to do nothing in this case.
 			 */
-			if (vma->vm_file)
-				unmap_hugepage_range(vma, start, end, NULL);
+			if (vma->vm_file) {
+				mutex_lock(&vma->vm_file->f_mapping->i_mmap_mutex);
+				__unmap_hugepage_range(tlb, vma, start, end, NULL);
+				mutex_unlock(&vma->vm_file->f_mapping->i_mmap_mutex);
+			}
 		} else
 			unmap_page_range(tlb, vma, start, end, details);
 	}
-- 
1.7.10.rc3.3.g19a6c

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
