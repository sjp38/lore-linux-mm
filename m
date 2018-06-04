Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id A133C6B0003
	for <linux-mm@kvack.org>; Mon,  4 Jun 2018 13:15:12 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id y21-v6so5752431pfm.4
        for <linux-mm@kvack.org>; Mon, 04 Jun 2018 10:15:12 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g1-v6sor16661118plt.70.2018.06.04.10.15.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 04 Jun 2018 10:15:09 -0700 (PDT)
Date: Mon, 4 Jun 2018 22:47:27 +0530
From: Souptick Joarder <jrdr.linux@gmail.com>
Subject: [PATCH v3] mm: Change return type int to vm_fault_t for fault
 handlers
Message-ID: <20180604171727.GA20279@jordon-HP-15-Notebook-PC>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: willy@infradead.org, viro@zeniv.linux.org.uk, hughd@google.com, akpm@linux-foundation.org, mhocko@suse.com, ross.zwisler@linux.intel.com, zi.yan@cs.rutgers.edu, kirill.shutemov@linux.intel.com, dan.j.williams@intel.com, gregkh@linuxfoundation.org, mark.rutland@arm.com, riel@redhat.com, pasha.tatashin@oracle.com, jschoenh@amazon.de, kstewart@linuxfoundation.org, rientjes@google.com, tglx@linutronix.de, peterz@infradead.org, mgorman@suse.de, yang.s@alibaba-inc.com, minchan@kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Use new return type vm_fault_t for fault handler. For
now, this is just documenting that the function returns
a VM_FAULT value rather than an errno. Once all instances
are converted, vm_fault_t will become a distinct type.

Ref-> commit 1c8f422059ae ("mm: change return type to vm_fault_t")

The aim is to change the return type of finish_fault()
and handle_mm_fault() to vm_fault_t type. As part of
that clean up return type of all other recursively called
functions have been changed to vm_fault_t type.

The places from where handle_mm_fault() is getting invoked
will be change to vm_fault_t type but in a separate patch.

vmf_error() is the newly introduce inline function
in 4.17-rc6.

Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
Reviewed-by: Matthew Wilcox <mawilcox@microsoft.com>
---
v2: Change patch title and fixed sparse warning.

v3: Reviewed by Matthew Wilcox

 fs/userfaultfd.c              |  6 +--
 include/linux/huge_mm.h       | 10 +++--
 include/linux/hugetlb.h       |  2 +-
 include/linux/mm.h            | 14 +++----
 include/linux/oom.h           |  2 +-
 include/linux/swapops.h       |  5 ++-
 include/linux/userfaultfd_k.h |  5 ++-
 kernel/memremap.c             |  2 +-
 mm/gup.c                      |  4 +-
 mm/huge_memory.c              | 25 ++++++------
 mm/hugetlb.c                  | 29 +++++++-------
 mm/internal.h                 |  2 +-
 mm/khugepaged.c               |  3 +-
 mm/memory.c                   | 90 ++++++++++++++++++++++---------------------
 mm/shmem.c                    | 17 ++++----
 15 files changed, 110 insertions(+), 106 deletions(-)

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index cec550c..bf60c6a 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -336,17 +336,15 @@ static inline bool userfaultfd_must_wait(struct userfaultfd_ctx *ctx,
  * fatal_signal_pending()s, and the mmap_sem must be released before
  * returning it.
  */
-int handle_userfault(struct vm_fault *vmf, unsigned long reason)
+vm_fault_t handle_userfault(struct vm_fault *vmf, unsigned long reason)
 {
 	struct mm_struct *mm = vmf->vma->vm_mm;
 	struct userfaultfd_ctx *ctx;
 	struct userfaultfd_wait_queue uwq;
-	int ret;
+	vm_fault_t ret = VM_FAULT_SIGBUS;
 	bool must_wait, return_to_userland;
 	long blocking_state;
 
-	ret = VM_FAULT_SIGBUS;
-
 	/*
 	 * We don't do userfault handling for the final child pid update.
 	 *
diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index a8a1262..8c4f0a6 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -3,10 +3,11 @@
 #define _LINUX_HUGE_MM_H
 
 #include <linux/sched/coredump.h>
+#include <linux/mm_types.h>
 
 #include <linux/fs.h> /* only for vma_is_dax() */
 
-extern int do_huge_pmd_anonymous_page(struct vm_fault *vmf);
+extern vm_fault_t do_huge_pmd_anonymous_page(struct vm_fault *vmf);
 extern int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 			 pmd_t *dst_pmd, pmd_t *src_pmd, unsigned long addr,
 			 struct vm_area_struct *vma);
@@ -23,7 +24,7 @@ static inline void huge_pud_set_accessed(struct vm_fault *vmf, pud_t orig_pud)
 }
 #endif
 
-extern int do_huge_pmd_wp_page(struct vm_fault *vmf, pmd_t orig_pmd);
+extern vm_fault_t do_huge_pmd_wp_page(struct vm_fault *vmf, pmd_t orig_pmd);
 extern struct page *follow_trans_huge_pmd(struct vm_area_struct *vma,
 					  unsigned long addr,
 					  pmd_t *pmd,
@@ -216,7 +217,7 @@ struct page *follow_devmap_pmd(struct vm_area_struct *vma, unsigned long addr,
 struct page *follow_devmap_pud(struct vm_area_struct *vma, unsigned long addr,
 		pud_t *pud, int flags);
 
-extern int do_huge_pmd_numa_page(struct vm_fault *vmf, pmd_t orig_pmd);
+extern vm_fault_t do_huge_pmd_numa_page(struct vm_fault *vmf, pmd_t orig_pmd);
 
 extern struct page *huge_zero_page;
 
@@ -321,7 +322,8 @@ static inline spinlock_t *pud_trans_huge_lock(pud_t *pud,
 	return NULL;
 }
 
-static inline int do_huge_pmd_numa_page(struct vm_fault *vmf, pmd_t orig_pmd)
+static inline vm_fault_t do_huge_pmd_numa_page(struct vm_fault *vmf,
+		pmd_t orig_pmd)
 {
 	return 0;
 }
diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 36fa6a2..c779b2f 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -105,7 +105,7 @@ void __unmap_hugepage_range(struct mmu_gather *tlb, struct vm_area_struct *vma,
 int hugetlb_report_node_meminfo(int, char *);
 void hugetlb_show_meminfo(void);
 unsigned long hugetlb_total_pages(void);
-int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
+vm_fault_t hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 			unsigned long address, unsigned int flags);
 int hugetlb_mcopy_atomic_pte(struct mm_struct *dst_mm, pte_t *dst_pte,
 				struct vm_area_struct *dst_vma,
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 02a616e..2971bff 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -694,10 +694,10 @@ static inline pte_t maybe_mkwrite(pte_t pte, struct vm_area_struct *vma)
 	return pte;
 }
 
-int alloc_set_pte(struct vm_fault *vmf, struct mem_cgroup *memcg,
+vm_fault_t alloc_set_pte(struct vm_fault *vmf, struct mem_cgroup *memcg,
 		struct page *page);
-int finish_fault(struct vm_fault *vmf);
-int finish_mkwrite_fault(struct vm_fault *vmf);
+vm_fault_t finish_fault(struct vm_fault *vmf);
+vm_fault_t finish_mkwrite_fault(struct vm_fault *vmf);
 #endif
 
 /*
@@ -1343,8 +1343,8 @@ int generic_access_phys(struct vm_area_struct *vma, unsigned long addr,
 int invalidate_inode_page(struct page *page);
 
 #ifdef CONFIG_MMU
-extern int handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
-		unsigned int flags);
+extern vm_fault_t handle_mm_fault(struct vm_area_struct *vma,
+			unsigned long address, unsigned int flags);
 extern int fixup_user_fault(struct task_struct *tsk, struct mm_struct *mm,
 			    unsigned long address, unsigned int fault_flags,
 			    bool *unlocked);
@@ -1353,7 +1353,7 @@ void unmap_mapping_pages(struct address_space *mapping,
 void unmap_mapping_range(struct address_space *mapping,
 		loff_t const holebegin, loff_t const holelen, int even_cows);
 #else
-static inline int handle_mm_fault(struct vm_area_struct *vma,
+static inline vm_fault_t handle_mm_fault(struct vm_area_struct *vma,
 		unsigned long address, unsigned int flags)
 {
 	/* should never happen if there's no MMU */
@@ -2501,7 +2501,7 @@ static inline struct page *follow_page(struct vm_area_struct *vma,
 #define FOLL_COW	0x4000	/* internal GUP flag */
 #define FOLL_ANON	0x8000	/* don't do file mappings */
 
-static inline int vm_fault_to_errno(int vm_fault, int foll_flags)
+static inline int vm_fault_to_errno(vm_fault_t vm_fault, int foll_flags)
 {
 	if (vm_fault & VM_FAULT_OOM)
 		return -ENOMEM;
diff --git a/include/linux/oom.h b/include/linux/oom.h
index 6adac11..9d30c15 100644
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -88,7 +88,7 @@ static inline bool mm_is_oom_victim(struct mm_struct *mm)
  *
  * Return 0 when the PF is safe VM_FAULT_SIGBUS otherwise.
  */
-static inline int check_stable_address_space(struct mm_struct *mm)
+static inline vm_fault_t check_stable_address_space(struct mm_struct *mm)
 {
 	if (unlikely(test_bit(MMF_UNSTABLE, &mm->flags)))
 		return VM_FAULT_SIGBUS;
diff --git a/include/linux/swapops.h b/include/linux/swapops.h
index 1d3877c..9bc8ddb 100644
--- a/include/linux/swapops.h
+++ b/include/linux/swapops.h
@@ -4,6 +4,7 @@
 
 #include <linux/radix-tree.h>
 #include <linux/bug.h>
+#include <linux/mm_types.h>
 
 /*
  * swapcache pages are stored in the swapper_space radix tree.  We want to
@@ -134,7 +135,7 @@ static inline struct page *device_private_entry_to_page(swp_entry_t entry)
 	return pfn_to_page(swp_offset(entry));
 }
 
-int device_private_entry_fault(struct vm_area_struct *vma,
+vm_fault_t device_private_entry_fault(struct vm_area_struct *vma,
 		       unsigned long addr,
 		       swp_entry_t entry,
 		       unsigned int flags,
@@ -169,7 +170,7 @@ static inline struct page *device_private_entry_to_page(swp_entry_t entry)
 	return NULL;
 }
 
-static inline int device_private_entry_fault(struct vm_area_struct *vma,
+static inline vm_fault_t device_private_entry_fault(struct vm_area_struct *vma,
 				     unsigned long addr,
 				     swp_entry_t entry,
 				     unsigned int flags,
diff --git a/include/linux/userfaultfd_k.h b/include/linux/userfaultfd_k.h
index f2f3b68..1f36c80 100644
--- a/include/linux/userfaultfd_k.h
+++ b/include/linux/userfaultfd_k.h
@@ -28,7 +28,7 @@
 #define UFFD_SHARED_FCNTL_FLAGS (O_CLOEXEC | O_NONBLOCK)
 #define UFFD_FLAGS_SET (EFD_SHARED_FCNTL_FLAGS)
 
-extern int handle_userfault(struct vm_fault *vmf, unsigned long reason);
+extern vm_fault_t handle_userfault(struct vm_fault *vmf, unsigned long reason);
 
 extern ssize_t mcopy_atomic(struct mm_struct *dst_mm, unsigned long dst_start,
 			    unsigned long src_start, unsigned long len);
@@ -75,7 +75,8 @@ extern void userfaultfd_unmap_complete(struct mm_struct *mm,
 #else /* CONFIG_USERFAULTFD */
 
 /* mm helpers */
-static inline int handle_userfault(struct vm_fault *vmf, unsigned long reason)
+static inline vm_fault_t handle_userfault(struct vm_fault *vmf,
+				unsigned long reason)
 {
 	return VM_FAULT_SIGBUS;
 }
diff --git a/kernel/memremap.c b/kernel/memremap.c
index 895e6b7..d148d09 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -214,7 +214,7 @@ static unsigned long order_at(struct resource *res, unsigned long pgoff)
 			pgoff += 1UL << order, order = order_at((res), pgoff))
 
 #if IS_ENABLED(CONFIG_DEVICE_PRIVATE)
-int device_private_entry_fault(struct vm_area_struct *vma,
+vm_fault_t device_private_entry_fault(struct vm_area_struct *vma,
 		       unsigned long addr,
 		       swp_entry_t entry,
 		       unsigned int flags,
diff --git a/mm/gup.c b/mm/gup.c
index 541904a..e3a957e 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -481,7 +481,7 @@ static int faultin_page(struct task_struct *tsk, struct vm_area_struct *vma,
 		unsigned long address, unsigned int *flags, int *nonblocking)
 {
 	unsigned int fault_flags = 0;
-	int ret;
+	vm_fault_t ret;
 
 	/* mlock all present pages, but do not fault in new pages */
 	if ((*flags & (FOLL_POPULATE | FOLL_MLOCK)) == FOLL_MLOCK)
@@ -802,7 +802,7 @@ int fixup_user_fault(struct task_struct *tsk, struct mm_struct *mm,
 		     bool *unlocked)
 {
 	struct vm_area_struct *vma;
-	int ret, major = 0;
+	vm_fault_t ret, major = 0;
 
 	if (unlocked)
 		fault_flags |= FAULT_FLAG_ALLOW_RETRY;
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index a3a1815..82dc477 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -544,14 +544,14 @@ unsigned long thp_get_unmapped_area(struct file *filp, unsigned long addr,
 }
 EXPORT_SYMBOL_GPL(thp_get_unmapped_area);
 
-static int __do_huge_pmd_anonymous_page(struct vm_fault *vmf, struct page *page,
-		gfp_t gfp)
+static vm_fault_t __do_huge_pmd_anonymous_page(struct vm_fault *vmf,
+			struct page *page, gfp_t gfp)
 {
 	struct vm_area_struct *vma = vmf->vma;
 	struct mem_cgroup *memcg;
 	pgtable_t pgtable;
 	unsigned long haddr = vmf->address & HPAGE_PMD_MASK;
-	int ret = 0;
+	vm_fault_t ret = 0;
 
 	VM_BUG_ON_PAGE(!PageCompound(page), page);
 
@@ -587,7 +587,7 @@ static int __do_huge_pmd_anonymous_page(struct vm_fault *vmf, struct page *page,
 
 		/* Deliver the page fault to userland */
 		if (userfaultfd_missing(vma)) {
-			int ret;
+			vm_fault_t ret;
 
 			spin_unlock(vmf->ptl);
 			mem_cgroup_cancel_charge(page, memcg, true);
@@ -666,7 +666,7 @@ static bool set_huge_zero_page(pgtable_t pgtable, struct mm_struct *mm,
 	return true;
 }
 
-int do_huge_pmd_anonymous_page(struct vm_fault *vmf)
+vm_fault_t do_huge_pmd_anonymous_page(struct vm_fault *vmf)
 {
 	struct vm_area_struct *vma = vmf->vma;
 	gfp_t gfp;
@@ -685,7 +685,7 @@ int do_huge_pmd_anonymous_page(struct vm_fault *vmf)
 		pgtable_t pgtable;
 		struct page *zero_page;
 		bool set;
-		int ret;
+		vm_fault_t ret;
 		pgtable = pte_alloc_one(vma->vm_mm, haddr);
 		if (unlikely(!pgtable))
 			return VM_FAULT_OOM;
@@ -1121,15 +1121,16 @@ void huge_pmd_set_accessed(struct vm_fault *vmf, pmd_t orig_pmd)
 	spin_unlock(vmf->ptl);
 }
 
-static int do_huge_pmd_wp_page_fallback(struct vm_fault *vmf, pmd_t orig_pmd,
-		struct page *page)
+static vm_fault_t do_huge_pmd_wp_page_fallback(struct vm_fault *vmf,
+			pmd_t orig_pmd, struct page *page)
 {
 	struct vm_area_struct *vma = vmf->vma;
 	unsigned long haddr = vmf->address & HPAGE_PMD_MASK;
 	struct mem_cgroup *memcg;
 	pgtable_t pgtable;
 	pmd_t _pmd;
-	int ret = 0, i;
+	int i;
+	vm_fault_t ret = 0;
 	struct page **pages;
 	unsigned long mmun_start;	/* For mmu_notifiers */
 	unsigned long mmun_end;		/* For mmu_notifiers */
@@ -1239,7 +1240,7 @@ static int do_huge_pmd_wp_page_fallback(struct vm_fault *vmf, pmd_t orig_pmd,
 	goto out;
 }
 
-int do_huge_pmd_wp_page(struct vm_fault *vmf, pmd_t orig_pmd)
+vm_fault_t do_huge_pmd_wp_page(struct vm_fault *vmf, pmd_t orig_pmd)
 {
 	struct vm_area_struct *vma = vmf->vma;
 	struct page *page = NULL, *new_page;
@@ -1248,7 +1249,7 @@ int do_huge_pmd_wp_page(struct vm_fault *vmf, pmd_t orig_pmd)
 	unsigned long mmun_start;	/* For mmu_notifiers */
 	unsigned long mmun_end;		/* For mmu_notifiers */
 	gfp_t huge_gfp;			/* for allocation and charge */
-	int ret = 0;
+	vm_fault_t ret = 0;
 
 	vmf->ptl = pmd_lockptr(vma->vm_mm, vmf->pmd);
 	VM_BUG_ON_VMA(!vma->anon_vma, vma);
@@ -1459,7 +1460,7 @@ struct page *follow_trans_huge_pmd(struct vm_area_struct *vma,
 }
 
 /* NUMA hinting page fault entry point for trans huge pmds */
-int do_huge_pmd_numa_page(struct vm_fault *vmf, pmd_t pmd)
+vm_fault_t do_huge_pmd_numa_page(struct vm_fault *vmf, pmd_t pmd)
 {
 	struct vm_area_struct *vma = vmf->vma;
 	struct anon_vma *anon_vma = NULL;
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 2186791..d17b186 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -3499,14 +3499,15 @@ static void unmap_ref_private(struct mm_struct *mm, struct vm_area_struct *vma,
  * cannot race with other handlers or page migration.
  * Keep the pte_same checks anyway to make transition from the mutex easier.
  */
-static int hugetlb_cow(struct mm_struct *mm, struct vm_area_struct *vma,
+static vm_fault_t hugetlb_cow(struct mm_struct *mm, struct vm_area_struct *vma,
 		       unsigned long address, pte_t *ptep,
 		       struct page *pagecache_page, spinlock_t *ptl)
 {
 	pte_t pte;
 	struct hstate *h = hstate_vma(vma);
 	struct page *old_page, *new_page;
-	int ret = 0, outside_reserve = 0;
+	int outside_reserve = 0;
+	vm_fault_t ret = 0;
 	unsigned long mmun_start;	/* For mmu_notifiers */
 	unsigned long mmun_end;		/* For mmu_notifiers */
 
@@ -3570,8 +3571,7 @@ static int hugetlb_cow(struct mm_struct *mm, struct vm_area_struct *vma,
 			return 0;
 		}
 
-		ret = (PTR_ERR(new_page) == -ENOMEM) ?
-			VM_FAULT_OOM : VM_FAULT_SIGBUS;
+		ret = vmf_error(PTR_ERR(new_page));
 		goto out_release_old;
 	}
 
@@ -3675,12 +3675,13 @@ int huge_add_to_page_cache(struct page *page, struct address_space *mapping,
 	return 0;
 }
 
-static int hugetlb_no_page(struct mm_struct *mm, struct vm_area_struct *vma,
-			   struct address_space *mapping, pgoff_t idx,
-			   unsigned long address, pte_t *ptep, unsigned int flags)
+static vm_fault_t hugetlb_no_page(struct mm_struct *mm,
+			struct vm_area_struct *vma,
+			struct address_space *mapping, pgoff_t idx,
+			unsigned long address, pte_t *ptep, unsigned int flags)
 {
 	struct hstate *h = hstate_vma(vma);
-	int ret = VM_FAULT_SIGBUS;
+	vm_fault_t ret = VM_FAULT_SIGBUS;
 	int anon_rmap = 0;
 	unsigned long size;
 	struct page *page;
@@ -3742,11 +3743,7 @@ static int hugetlb_no_page(struct mm_struct *mm, struct vm_area_struct *vma,
 
 		page = alloc_huge_page(vma, address, 0);
 		if (IS_ERR(page)) {
-			ret = PTR_ERR(page);
-			if (ret == -ENOMEM)
-				ret = VM_FAULT_OOM;
-			else
-				ret = VM_FAULT_SIGBUS;
+			ret = vmf_error(PTR_ERR(page));
 			goto out;
 		}
 		clear_huge_page(page, address, pages_per_huge_page(h));
@@ -3870,12 +3867,12 @@ u32 hugetlb_fault_mutex_hash(struct hstate *h, struct mm_struct *mm,
 }
 #endif
 
-int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
+vm_fault_t hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 			unsigned long address, unsigned int flags)
 {
 	pte_t *ptep, entry;
 	spinlock_t *ptl;
-	int ret;
+	vm_fault_t ret;
 	u32 hash;
 	pgoff_t idx;
 	struct page *page = NULL;
@@ -4206,7 +4203,7 @@ long follow_hugetlb_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		if (absent || is_swap_pte(huge_ptep_get(pte)) ||
 		    ((flags & FOLL_WRITE) &&
 		      !huge_pte_write(huge_ptep_get(pte)))) {
-			int ret;
+			vm_fault_t ret;
 			unsigned int fault_flags = 0;
 
 			if (pte)
diff --git a/mm/internal.h b/mm/internal.h
index 502d141..4044456 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -38,7 +38,7 @@
 
 void page_writeback_init(void);
 
-int do_swap_page(struct vm_fault *vmf);
+vm_fault_t do_swap_page(struct vm_fault *vmf);
 
 void free_pgtables(struct mmu_gather *tlb, struct vm_area_struct *start_vma,
 		unsigned long floor, unsigned long ceiling);
diff --git a/mm/khugepaged.c b/mm/khugepaged.c
index d7b2a4b..778fd40 100644
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -880,7 +880,8 @@ static bool __collapse_huge_page_swapin(struct mm_struct *mm,
 					unsigned long address, pmd_t *pmd,
 					int referenced)
 {
-	int swapped_in = 0, ret = 0;
+	int swapped_in = 0;
+	vm_fault_t ret = 0;
 	struct vm_fault vmf = {
 		.vma = vma,
 		.address = address,
diff --git a/mm/memory.c b/mm/memory.c
index 01f5464..cee8245 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2360,9 +2360,9 @@ static gfp_t __get_fault_gfp_mask(struct vm_area_struct *vma)
  *
  * We do this without the lock held, so that it can sleep if it needs to.
  */
-static int do_page_mkwrite(struct vm_fault *vmf)
+static vm_fault_t do_page_mkwrite(struct vm_fault *vmf)
 {
-	int ret;
+	vm_fault_t ret;
 	struct page *page = vmf->page;
 	unsigned int old_flags = vmf->flags;
 
@@ -2466,7 +2466,7 @@ static inline void wp_page_reuse(struct vm_fault *vmf)
  *   held to the old page, as well as updating the rmap.
  * - In any case, unlock the PTL and drop the reference we took to the old page.
  */
-static int wp_page_copy(struct vm_fault *vmf)
+static vm_fault_t wp_page_copy(struct vm_fault *vmf)
 {
 	struct vm_area_struct *vma = vmf->vma;
 	struct mm_struct *mm = vma->vm_mm;
@@ -2614,7 +2614,7 @@ static int wp_page_copy(struct vm_fault *vmf)
  * The function expects the page to be locked or other protection against
  * concurrent faults / writeback (such as DAX radix tree locks).
  */
-int finish_mkwrite_fault(struct vm_fault *vmf)
+vm_fault_t finish_mkwrite_fault(struct vm_fault *vmf)
 {
 	WARN_ON_ONCE(!(vmf->vma->vm_flags & VM_SHARED));
 	vmf->pte = pte_offset_map_lock(vmf->vma->vm_mm, vmf->pmd, vmf->address,
@@ -2635,12 +2635,12 @@ int finish_mkwrite_fault(struct vm_fault *vmf)
  * Handle write page faults for VM_MIXEDMAP or VM_PFNMAP for a VM_SHARED
  * mapping
  */
-static int wp_pfn_shared(struct vm_fault *vmf)
+static vm_fault_t wp_pfn_shared(struct vm_fault *vmf)
 {
 	struct vm_area_struct *vma = vmf->vma;
 
 	if (vma->vm_ops && vma->vm_ops->pfn_mkwrite) {
-		int ret;
+		vm_fault_t ret;
 
 		pte_unmap_unlock(vmf->pte, vmf->ptl);
 		vmf->flags |= FAULT_FLAG_MKWRITE;
@@ -2653,7 +2653,7 @@ static int wp_pfn_shared(struct vm_fault *vmf)
 	return VM_FAULT_WRITE;
 }
 
-static int wp_page_shared(struct vm_fault *vmf)
+static vm_fault_t wp_page_shared(struct vm_fault *vmf)
 	__releases(vmf->ptl)
 {
 	struct vm_area_struct *vma = vmf->vma;
@@ -2661,7 +2661,7 @@ static int wp_page_shared(struct vm_fault *vmf)
 	get_page(vmf->page);
 
 	if (vma->vm_ops && vma->vm_ops->page_mkwrite) {
-		int tmp;
+		vm_fault_t tmp;
 
 		pte_unmap_unlock(vmf->pte, vmf->ptl);
 		tmp = do_page_mkwrite(vmf);
@@ -2704,7 +2704,7 @@ static int wp_page_shared(struct vm_fault *vmf)
  * but allow concurrent faults), with pte both mapped and locked.
  * We return with mmap_sem still held, but pte unmapped and unlocked.
  */
-static int do_wp_page(struct vm_fault *vmf)
+static vm_fault_t do_wp_page(struct vm_fault *vmf)
 	__releases(vmf->ptl)
 {
 	struct vm_area_struct *vma = vmf->vma;
@@ -2880,7 +2880,7 @@ void unmap_mapping_range(struct address_space *mapping,
  * We return with the mmap_sem locked or unlocked in the same cases
  * as does filemap_fault().
  */
-int do_swap_page(struct vm_fault *vmf)
+vm_fault_t do_swap_page(struct vm_fault *vmf)
 {
 	struct vm_area_struct *vma = vmf->vma;
 	struct page *page = NULL, *swapcache;
@@ -2889,7 +2889,7 @@ int do_swap_page(struct vm_fault *vmf)
 	pte_t pte;
 	int locked;
 	int exclusive = 0;
-	int ret = 0;
+	vm_fault_t ret = 0;
 
 	if (!pte_unmap_same(vma->vm_mm, vmf->pmd, vmf->pte, vmf->orig_pte))
 		goto out;
@@ -3100,12 +3100,12 @@ int do_swap_page(struct vm_fault *vmf)
  * but allow concurrent faults), and pte mapped but not yet locked.
  * We return with mmap_sem still held, but pte unmapped and unlocked.
  */
-static int do_anonymous_page(struct vm_fault *vmf)
+static vm_fault_t do_anonymous_page(struct vm_fault *vmf)
 {
 	struct vm_area_struct *vma = vmf->vma;
 	struct mem_cgroup *memcg;
 	struct page *page;
-	int ret = 0;
+	vm_fault_t ret = 0;
 	pte_t entry;
 
 	/* File mapping without ->vm_ops ? */
@@ -3214,10 +3214,10 @@ static int do_anonymous_page(struct vm_fault *vmf)
  * released depending on flags and vma->vm_ops->fault() return value.
  * See filemap_fault() and __lock_page_retry().
  */
-static int __do_fault(struct vm_fault *vmf)
+static vm_fault_t __do_fault(struct vm_fault *vmf)
 {
 	struct vm_area_struct *vma = vmf->vma;
-	int ret;
+	vm_fault_t ret;
 
 	ret = vma->vm_ops->fault(vmf);
 	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE | VM_FAULT_RETRY |
@@ -3251,7 +3251,7 @@ static int pmd_devmap_trans_unstable(pmd_t *pmd)
 	return pmd_devmap(*pmd) || pmd_trans_unstable(pmd);
 }
 
-static int pte_alloc_one_map(struct vm_fault *vmf)
+static vm_fault_t pte_alloc_one_map(struct vm_fault *vmf)
 {
 	struct vm_area_struct *vma = vmf->vma;
 
@@ -3327,13 +3327,14 @@ static void deposit_prealloc_pte(struct vm_fault *vmf)
 	vmf->prealloc_pte = NULL;
 }
 
-static int do_set_pmd(struct vm_fault *vmf, struct page *page)
+static vm_fault_t do_set_pmd(struct vm_fault *vmf, struct page *page)
 {
 	struct vm_area_struct *vma = vmf->vma;
 	bool write = vmf->flags & FAULT_FLAG_WRITE;
 	unsigned long haddr = vmf->address & HPAGE_PMD_MASK;
 	pmd_t entry;
-	int i, ret;
+	int i;
+	vm_fault_t ret;
 
 	if (!transhuge_vma_suitable(vma, haddr))
 		return VM_FAULT_FALLBACK;
@@ -3383,7 +3384,7 @@ static int do_set_pmd(struct vm_fault *vmf, struct page *page)
 	return ret;
 }
 #else
-static int do_set_pmd(struct vm_fault *vmf, struct page *page)
+static vm_fault_t do_set_pmd(struct vm_fault *vmf, struct page *page)
 {
 	BUILD_BUG();
 	return 0;
@@ -3404,13 +3405,13 @@ static int do_set_pmd(struct vm_fault *vmf, struct page *page)
  * Target users are page handler itself and implementations of
  * vm_ops->map_pages.
  */
-int alloc_set_pte(struct vm_fault *vmf, struct mem_cgroup *memcg,
+vm_fault_t alloc_set_pte(struct vm_fault *vmf, struct mem_cgroup *memcg,
 		struct page *page)
 {
 	struct vm_area_struct *vma = vmf->vma;
 	bool write = vmf->flags & FAULT_FLAG_WRITE;
 	pte_t entry;
-	int ret;
+	vm_fault_t ret;
 
 	if (pmd_none(*vmf->pmd) && PageTransCompound(page) &&
 			IS_ENABLED(CONFIG_TRANSPARENT_HUGE_PAGECACHE)) {
@@ -3469,10 +3470,10 @@ int alloc_set_pte(struct vm_fault *vmf, struct mem_cgroup *memcg,
  * The function expects the page to be locked and on success it consumes a
  * reference of a page being mapped (for the PTE which maps it).
  */
-int finish_fault(struct vm_fault *vmf)
+vm_fault_t finish_fault(struct vm_fault *vmf)
 {
 	struct page *page;
-	int ret = 0;
+	vm_fault_t ret = 0;
 
 	/* Did we COW the page? */
 	if ((vmf->flags & FAULT_FLAG_WRITE) &&
@@ -3558,12 +3559,13 @@ static int __init fault_around_debugfs(void)
  * (and therefore to page order).  This way it's easier to guarantee
  * that we don't cross page table boundaries.
  */
-static int do_fault_around(struct vm_fault *vmf)
+static vm_fault_t do_fault_around(struct vm_fault *vmf)
 {
 	unsigned long address = vmf->address, nr_pages, mask;
 	pgoff_t start_pgoff = vmf->pgoff;
 	pgoff_t end_pgoff;
-	int off, ret = 0;
+	int off;
+	vm_fault_t ret = 0;
 
 	nr_pages = READ_ONCE(fault_around_bytes) >> PAGE_SHIFT;
 	mask = ~(nr_pages * PAGE_SIZE - 1) & PAGE_MASK;
@@ -3613,10 +3615,10 @@ static int do_fault_around(struct vm_fault *vmf)
 	return ret;
 }
 
-static int do_read_fault(struct vm_fault *vmf)
+static vm_fault_t do_read_fault(struct vm_fault *vmf)
 {
 	struct vm_area_struct *vma = vmf->vma;
-	int ret = 0;
+	vm_fault_t ret = 0;
 
 	/*
 	 * Let's call ->map_pages() first and use ->fault() as fallback
@@ -3640,10 +3642,10 @@ static int do_read_fault(struct vm_fault *vmf)
 	return ret;
 }
 
-static int do_cow_fault(struct vm_fault *vmf)
+static vm_fault_t do_cow_fault(struct vm_fault *vmf)
 {
 	struct vm_area_struct *vma = vmf->vma;
-	int ret;
+	vm_fault_t ret;
 
 	if (unlikely(anon_vma_prepare(vma)))
 		return VM_FAULT_OOM;
@@ -3679,10 +3681,10 @@ static int do_cow_fault(struct vm_fault *vmf)
 	return ret;
 }
 
-static int do_shared_fault(struct vm_fault *vmf)
+static vm_fault_t do_shared_fault(struct vm_fault *vmf)
 {
 	struct vm_area_struct *vma = vmf->vma;
-	int ret, tmp;
+	vm_fault_t ret, tmp;
 
 	ret = __do_fault(vmf);
 	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE | VM_FAULT_RETRY)))
@@ -3720,10 +3722,10 @@ static int do_shared_fault(struct vm_fault *vmf)
  * The mmap_sem may have been released depending on flags and our
  * return value.  See filemap_fault() and __lock_page_or_retry().
  */
-static int do_fault(struct vm_fault *vmf)
+static vm_fault_t do_fault(struct vm_fault *vmf)
 {
 	struct vm_area_struct *vma = vmf->vma;
-	int ret;
+	vm_fault_t ret;
 
 	/* The VMA was not fully populated on mmap() or missing VM_DONTEXPAND */
 	if (!vma->vm_ops->fault)
@@ -3758,7 +3760,7 @@ static int numa_migrate_prep(struct page *page, struct vm_area_struct *vma,
 	return mpol_misplaced(page, vma, addr);
 }
 
-static int do_numa_page(struct vm_fault *vmf)
+static vm_fault_t do_numa_page(struct vm_fault *vmf)
 {
 	struct vm_area_struct *vma = vmf->vma;
 	struct page *page = NULL;
@@ -3848,7 +3850,7 @@ static int do_numa_page(struct vm_fault *vmf)
 	return 0;
 }
 
-static inline int create_huge_pmd(struct vm_fault *vmf)
+static inline vm_fault_t create_huge_pmd(struct vm_fault *vmf)
 {
 	if (vma_is_anonymous(vmf->vma))
 		return do_huge_pmd_anonymous_page(vmf);
@@ -3858,7 +3860,7 @@ static inline int create_huge_pmd(struct vm_fault *vmf)
 }
 
 /* `inline' is required to avoid gcc 4.1.2 build error */
-static inline int wp_huge_pmd(struct vm_fault *vmf, pmd_t orig_pmd)
+static inline vm_fault_t wp_huge_pmd(struct vm_fault *vmf, pmd_t orig_pmd)
 {
 	if (vma_is_anonymous(vmf->vma))
 		return do_huge_pmd_wp_page(vmf, orig_pmd);
@@ -3877,7 +3879,7 @@ static inline bool vma_is_accessible(struct vm_area_struct *vma)
 	return vma->vm_flags & (VM_READ | VM_EXEC | VM_WRITE);
 }
 
-static int create_huge_pud(struct vm_fault *vmf)
+static vm_fault_t create_huge_pud(struct vm_fault *vmf)
 {
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 	/* No support for anonymous transparent PUD pages yet */
@@ -3889,7 +3891,7 @@ static int create_huge_pud(struct vm_fault *vmf)
 	return VM_FAULT_FALLBACK;
 }
 
-static int wp_huge_pud(struct vm_fault *vmf, pud_t orig_pud)
+static vm_fault_t wp_huge_pud(struct vm_fault *vmf, pud_t orig_pud)
 {
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 	/* No support for anonymous transparent PUD pages yet */
@@ -3916,7 +3918,7 @@ static int wp_huge_pud(struct vm_fault *vmf, pud_t orig_pud)
  * The mmap_sem may have been released depending on flags and our return value.
  * See filemap_fault() and __lock_page_or_retry().
  */
-static int handle_pte_fault(struct vm_fault *vmf)
+static vm_fault_t handle_pte_fault(struct vm_fault *vmf)
 {
 	pte_t entry;
 
@@ -4004,8 +4006,8 @@ static int handle_pte_fault(struct vm_fault *vmf)
  * The mmap_sem may have been released depending on flags and our
  * return value.  See filemap_fault() and __lock_page_or_retry().
  */
-static int __handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
-		unsigned int flags)
+static vm_fault_t __handle_mm_fault(struct vm_area_struct *vma,
+		unsigned long address, unsigned int flags)
 {
 	struct vm_fault vmf = {
 		.vma = vma,
@@ -4018,7 +4020,7 @@ static int __handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
 	struct mm_struct *mm = vma->vm_mm;
 	pgd_t *pgd;
 	p4d_t *p4d;
-	int ret;
+	vm_fault_t ret;
 
 	pgd = pgd_offset(mm, address);
 	p4d = p4d_alloc(mm, pgd, address);
@@ -4093,10 +4095,10 @@ static int __handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
  * The mmap_sem may have been released depending on flags and our
  * return value.  See filemap_fault() and __lock_page_or_retry().
  */
-int handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
+vm_fault_t handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
 		unsigned int flags)
 {
-	int ret;
+	vm_fault_t ret;
 
 	__set_current_state(TASK_RUNNING);
 
diff --git a/mm/shmem.c b/mm/shmem.c
index 9d6c7e5..af05c35 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -123,7 +123,7 @@ static int shmem_replace_page(struct page **pagep, gfp_t gfp,
 static int shmem_getpage_gfp(struct inode *inode, pgoff_t index,
 		struct page **pagep, enum sgp_type sgp,
 		gfp_t gfp, struct vm_area_struct *vma,
-		struct vm_fault *vmf, int *fault_type);
+		struct vm_fault *vmf, vm_fault_t *fault_type);
 
 int shmem_getpage(struct inode *inode, pgoff_t index,
 		struct page **pagep, enum sgp_type sgp)
@@ -1604,7 +1604,8 @@ static int shmem_replace_page(struct page **pagep, gfp_t gfp,
  */
 static int shmem_getpage_gfp(struct inode *inode, pgoff_t index,
 	struct page **pagep, enum sgp_type sgp, gfp_t gfp,
-	struct vm_area_struct *vma, struct vm_fault *vmf, int *fault_type)
+	struct vm_area_struct *vma, struct vm_fault *vmf,
+			vm_fault_t *fault_type)
 {
 	struct address_space *mapping = inode->i_mapping;
 	struct shmem_inode_info *info = SHMEM_I(inode);
@@ -1931,14 +1932,14 @@ static int synchronous_wake_function(wait_queue_entry_t *wait, unsigned mode, in
 	return ret;
 }
 
-static int shmem_fault(struct vm_fault *vmf)
+static vm_fault_t shmem_fault(struct vm_fault *vmf)
 {
 	struct vm_area_struct *vma = vmf->vma;
 	struct inode *inode = file_inode(vma->vm_file);
 	gfp_t gfp = mapping_gfp_mask(inode->i_mapping);
 	enum sgp_type sgp;
-	int error;
-	int ret = VM_FAULT_LOCKED;
+	int err;
+	vm_fault_t ret = VM_FAULT_LOCKED;
 
 	/*
 	 * Trinity finds that probing a hole which tmpfs is punching can
@@ -2006,10 +2007,10 @@ static int shmem_fault(struct vm_fault *vmf)
 	else if (vma->vm_flags & VM_HUGEPAGE)
 		sgp = SGP_HUGE;
 
-	error = shmem_getpage_gfp(inode, vmf->pgoff, &vmf->page, sgp,
+	err = shmem_getpage_gfp(inode, vmf->pgoff, &vmf->page, sgp,
 				  gfp, vma, vmf, &ret);
-	if (error)
-		return ((error == -ENOMEM) ? VM_FAULT_OOM : VM_FAULT_SIGBUS);
+	if (err)
+		ret = vmf_error(err);
 	return ret;
 }
 
-- 
1.9.1
