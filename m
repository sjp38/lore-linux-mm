Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id 23D9D6B0072
	for <linux-mm@kvack.org>; Sat, 11 May 2013 21:21:40 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv4 33/39] thp, mm: implement do_huge_linear_fault()
Date: Sun, 12 May 2013 04:23:30 +0300
Message-Id: <1368321816-17719-34-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1368321816-17719-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1368321816-17719-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Let's modify __do_fault() to handle transhuge pages. To indicate that
huge page is required caller pass flags with FAULT_FLAG_TRANSHUGE set.

__do_fault() now returns VM_FAULT_FALLBACK to indicate that fallback to
small pages is required.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/huge_mm.h |   41 +++++++++++++
 include/linux/mm.h      |    5 ++
 mm/huge_memory.c        |   22 -------
 mm/memory.c             |  148 ++++++++++++++++++++++++++++++++++++++++-------
 4 files changed, 172 insertions(+), 44 deletions(-)

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index d688271..b20334a 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -188,6 +188,28 @@ static inline struct page *compound_trans_head(struct page *page)
 	return page;
 }
 
+static inline gfp_t alloc_hugepage_gfpmask(int defrag, gfp_t extra_gfp)
+{
+	return (GFP_TRANSHUGE & ~(defrag ? 0 : __GFP_WAIT)) | extra_gfp;
+}
+
+static inline struct page *alloc_hugepage_vma(int defrag,
+					      struct vm_area_struct *vma,
+					      unsigned long haddr, int nd,
+					      gfp_t extra_gfp)
+{
+	return alloc_pages_vma(alloc_hugepage_gfpmask(defrag, extra_gfp),
+			       HPAGE_PMD_ORDER, vma, haddr, nd);
+}
+
+static inline pmd_t mk_huge_pmd(struct page *page, pgprot_t prot)
+{
+	pmd_t entry;
+	entry = mk_pmd(page, prot);
+	entry = pmd_mkhuge(entry);
+	return entry;
+}
+
 extern int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 				unsigned long addr, pmd_t pmd, pmd_t *pmdp);
 
@@ -200,12 +222,15 @@ extern int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vm
 #define HPAGE_CACHE_NR         ({ BUILD_BUG(); 0; })
 #define HPAGE_CACHE_INDEX_MASK ({ BUILD_BUG(); 0; })
 
+#define THP_FAULT_ALLOC		({ BUILD_BUG(); 0; })
+#define THP_FAULT_FALLBACK	({ BUILD_BUG(); 0; })
 #define THP_WRITE_ALLOC		({ BUILD_BUG(); 0; })
 #define THP_WRITE_ALLOC_FAILED	({ BUILD_BUG(); 0; })
 
 #define hpage_nr_pages(x) 1
 
 #define transparent_hugepage_enabled(__vma) 0
+#define transparent_hugepage_defrag(__vma) 0
 
 #define transparent_hugepage_flags 0UL
 static inline int
@@ -242,6 +267,22 @@ static inline int pmd_trans_huge_lock(pmd_t *pmd,
 	return 0;
 }
 
+static inline pmd_t mk_huge_pmd(struct page *page, pgprot_t prot)
+{
+	pmd_t entry;
+	BUILD_BUG();
+	return entry;
+}
+
+static inline struct page *alloc_hugepage_vma(int defrag,
+		struct vm_area_struct *vma,
+		unsigned long haddr, int nd,
+		gfp_t extra_gfp)
+{
+	BUILD_BUG();
+	return NULL;
+}
+
 static inline int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 					unsigned long addr, pmd_t pmd, pmd_t *pmdp)
 {
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 280b414..563c8b7 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -167,6 +167,11 @@ extern pgprot_t protection_map[16];
 #define FAULT_FLAG_RETRY_NOWAIT	0x10	/* Don't drop mmap_sem and wait when retrying */
 #define FAULT_FLAG_KILLABLE	0x20	/* The fault task is in SIGKILL killable region */
 #define FAULT_FLAG_TRIED	0x40	/* second try */
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE_PAGECACHE
+#define FAULT_FLAG_TRANSHUGE	0x80	/* Try to allocate transhuge page */
+#else
+#define FAULT_FLAG_TRANSHUGE	0	/* Optimize out THP code if disabled */
+#endif
 
 /*
  * vm_fault is filled by the the pagefault handler and passed to the vma's
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index facfdac..893cc69 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -709,14 +709,6 @@ pmd_t maybe_pmd_mkwrite(pmd_t pmd, struct vm_area_struct *vma)
 	return pmd;
 }
 
-static inline pmd_t mk_huge_pmd(struct page *page, pgprot_t prot)
-{
-	pmd_t entry;
-	entry = mk_pmd(page, prot);
-	entry = pmd_mkhuge(entry);
-	return entry;
-}
-
 static int __do_huge_pmd_anonymous_page(struct mm_struct *mm,
 					struct vm_area_struct *vma,
 					unsigned long haddr, pmd_t *pmd,
@@ -758,20 +750,6 @@ static int __do_huge_pmd_anonymous_page(struct mm_struct *mm,
 	return 0;
 }
 
-static inline gfp_t alloc_hugepage_gfpmask(int defrag, gfp_t extra_gfp)
-{
-	return (GFP_TRANSHUGE & ~(defrag ? 0 : __GFP_WAIT)) | extra_gfp;
-}
-
-static inline struct page *alloc_hugepage_vma(int defrag,
-					      struct vm_area_struct *vma,
-					      unsigned long haddr, int nd,
-					      gfp_t extra_gfp)
-{
-	return alloc_pages_vma(alloc_hugepage_gfpmask(defrag, extra_gfp),
-			       HPAGE_PMD_ORDER, vma, haddr, nd);
-}
-
 #ifndef CONFIG_NUMA
 static inline struct page *alloc_hugepage(int defrag)
 {
diff --git a/mm/memory.c b/mm/memory.c
index 97b22c7..8997cd8 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -59,6 +59,7 @@
 #include <linux/gfp.h>
 #include <linux/migrate.h>
 #include <linux/string.h>
+#include <linux/khugepaged.h>
 
 #include <asm/io.h>
 #include <asm/pgalloc.h>
@@ -167,6 +168,7 @@ static void check_sync_rss_stat(struct task_struct *task)
 }
 #else /* SPLIT_RSS_COUNTING */
 
+#define add_mm_counter_fast(mm, member, val) add_mm_counter(mm, member, val)
 #define inc_mm_counter_fast(mm, member) inc_mm_counter(mm, member)
 #define dec_mm_counter_fast(mm, member) dec_mm_counter(mm, member)
 
@@ -3282,6 +3284,38 @@ oom:
 	return VM_FAULT_OOM;
 }
 
+static inline bool transhuge_vma_suitable(struct vm_area_struct *vma,
+		unsigned long addr)
+{
+	unsigned long haddr = addr & HPAGE_PMD_MASK;
+
+	if (((vma->vm_start >> PAGE_SHIFT) & HPAGE_CACHE_INDEX_MASK) !=
+			(vma->vm_pgoff & HPAGE_CACHE_INDEX_MASK))
+		return false;
+	if (haddr < vma->vm_start || haddr + HPAGE_PMD_SIZE > vma->vm_end)
+		return false;
+	return true;
+}
+
+static struct page *alloc_fault_page_vma(struct vm_area_struct *vma,
+		unsigned long addr, unsigned int flags)
+{
+
+	if (flags & FAULT_FLAG_TRANSHUGE) {
+		struct page *page;
+		unsigned long haddr = addr & HPAGE_PMD_MASK;
+
+		page = alloc_hugepage_vma(transparent_hugepage_defrag(vma),
+				vma, haddr, numa_node_id(), 0);
+		if (page)
+			count_vm_event(THP_FAULT_ALLOC);
+		else
+			count_vm_event(THP_FAULT_FALLBACK);
+		return page;
+	}
+	return alloc_page_vma(GFP_HIGHUSER_MOVABLE, vma, addr);
+}
+
 /*
  * __do_fault() tries to create a new page mapping. It aggressively
  * tries to share with existing pages, but makes a separate copy if
@@ -3301,12 +3335,23 @@ static int __do_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 {
 	pte_t *page_table;
 	spinlock_t *ptl;
+	pgtable_t pgtable = NULL;
 	struct page *page, *cow_page, *dirty_page = NULL;
-	pte_t entry;
 	bool anon = false, page_mkwrite = false;
 	bool write = flags & FAULT_FLAG_WRITE;
+	bool thp = flags & FAULT_FLAG_TRANSHUGE;
+	unsigned long addr_aligned;
 	struct vm_fault vmf;
-	int ret;
+	int nr, ret;
+
+	if (thp) {
+		if (!transhuge_vma_suitable(vma, address))
+			return VM_FAULT_FALLBACK;
+		if (unlikely(khugepaged_enter(vma)))
+			return VM_FAULT_OOM;
+		addr_aligned = address & HPAGE_PMD_MASK;
+	} else
+		addr_aligned = address & PAGE_MASK;
 
 	/*
 	 * If we do COW later, allocate page befor taking lock_page()
@@ -3316,17 +3361,25 @@ static int __do_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 		if (unlikely(anon_vma_prepare(vma)))
 			return VM_FAULT_OOM;
 
-		cow_page = alloc_page_vma(GFP_HIGHUSER_MOVABLE, vma, address);
+		cow_page = alloc_fault_page_vma(vma, address, flags);
 		if (!cow_page)
-			return VM_FAULT_OOM;
+			return VM_FAULT_OOM | VM_FAULT_FALLBACK;
 
 		if (mem_cgroup_newpage_charge(cow_page, mm, GFP_KERNEL)) {
 			page_cache_release(cow_page);
-			return VM_FAULT_OOM;
+			return VM_FAULT_OOM | VM_FAULT_FALLBACK;
 		}
 	} else
 		cow_page = NULL;
 
+	if (thp) {
+		pgtable = pte_alloc_one(mm, address);
+		if (unlikely(!pgtable)) {
+			ret = VM_FAULT_OOM;
+			goto uncharge_out;
+		}
+	}
+
 	vmf.virtual_address = (void __user *)(address & PAGE_MASK);
 	vmf.pgoff = pgoff;
 	vmf.flags = flags;
@@ -3353,6 +3406,13 @@ static int __do_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 		VM_BUG_ON(!PageLocked(vmf.page));
 
 	page = vmf.page;
+
+	/*
+	 * If we asked for huge page we expect to get it or VM_FAULT_FALLBACK.
+	 * If we don't ask for huge page it must be splitted in ->fault().
+	 */
+	BUG_ON(PageTransHuge(page) != thp);
+
 	if (!write)
 		goto update_pgtable;
 
@@ -3362,7 +3422,11 @@ static int __do_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	if (!(vma->vm_flags & VM_SHARED)) {
 		page = cow_page;
 		anon = true;
-		copy_user_highpage(page, vmf.page, address, vma);
+		if (thp)
+			copy_user_huge_page(page, vmf.page, addr_aligned, vma,
+					HPAGE_PMD_NR);
+		else
+			copy_user_highpage(page, vmf.page, address, vma);
 		__SetPageUptodate(page);
 	} else if (vma->vm_ops->page_mkwrite) {
 		/*
@@ -3373,6 +3437,8 @@ static int __do_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 
 		unlock_page(page);
 		vmf.flags = FAULT_FLAG_WRITE | FAULT_FLAG_MKWRITE;
+		if (thp)
+			vmf.flags |= FAULT_FLAG_TRANSHUGE;
 		tmp = vma->vm_ops->page_mkwrite(vma, &vmf);
 		if (unlikely(tmp & (VM_FAULT_ERROR | VM_FAULT_NOPAGE))) {
 			ret = tmp;
@@ -3391,19 +3457,30 @@ static int __do_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	}
 
 update_pgtable:
-	page_table = pte_offset_map_lock(mm, pmd, address, &ptl);
 	/* Only go through if we didn't race with anybody else... */
-	if (unlikely(!pte_same(*page_table, orig_pte))) {
-		pte_unmap_unlock(page_table, ptl);
-		goto race_out;
+	if (thp) {
+		spin_lock(&mm->page_table_lock);
+		if (!pmd_none(*pmd)) {
+			spin_unlock(&mm->page_table_lock);
+			goto race_out;
+		}
+		/* make GCC happy */
+		ptl = NULL; page_table = NULL;
+	} else {
+		page_table = pte_offset_map_lock(mm, pmd, address, &ptl);
+		if (unlikely(!pte_same(*page_table, orig_pte))) {
+			pte_unmap_unlock(page_table, ptl);
+			goto race_out;
+		}
 	}
 
 	flush_icache_page(vma, page);
+	nr = thp ? HPAGE_PMD_NR : 1;
 	if (anon) {
-		inc_mm_counter_fast(mm, MM_ANONPAGES);
-		page_add_new_anon_rmap(page, vma, address);
+		add_mm_counter_fast(mm, MM_ANONPAGES, nr);
+		page_add_new_anon_rmap(page, vma, addr_aligned);
 	} else {
-		inc_mm_counter_fast(mm, MM_FILEPAGES);
+		add_mm_counter_fast(mm, MM_FILEPAGES, nr);
 		page_add_file_rmap(page);
 		if (write) {
 			dirty_page = page;
@@ -3419,15 +3496,23 @@ update_pgtable:
 	 * exclusive copy of the page, or this is a shared mapping, so we can
 	 * make it writable and dirty to avoid having to handle that later.
 	 */
-	entry = mk_pte(page, vma->vm_page_prot);
-	if (write)
-		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
-	set_pte_at(mm, address, page_table, entry);
-
-	/* no need to invalidate: a not-present page won't be cached */
-	update_mmu_cache(vma, address, page_table);
-
-	pte_unmap_unlock(page_table, ptl);
+	if (thp) {
+		pmd_t entry = mk_huge_pmd(page, vma->vm_page_prot);
+		if (flags & FAULT_FLAG_WRITE)
+			entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
+		set_pmd_at(mm, address, pmd, entry);
+		pgtable_trans_huge_deposit(mm, pgtable);
+		mm->nr_ptes++;
+		update_mmu_cache_pmd(vma, address, pmd);
+		spin_unlock(&mm->page_table_lock);
+	} else {
+		pte_t entry = mk_pte(page, vma->vm_page_prot);
+		if (write)
+			entry = maybe_mkwrite(pte_mkdirty(entry), vma);
+		set_pte_at(mm, address, page_table, entry);
+		update_mmu_cache(vma, address, page_table);
+		pte_unmap_unlock(page_table, ptl);
+	}
 
 	if (dirty_page) {
 		struct address_space *mapping = page->mapping;
@@ -3457,9 +3542,13 @@ update_pgtable:
 	return ret;
 
 unwritable_page:
+	if (pgtable)
+		pte_free(mm, pgtable);
 	page_cache_release(page);
 	return ret;
 uncharge_out:
+	if (pgtable)
+		pte_free(mm, pgtable);
 	/* fs's fault handler get error */
 	if (cow_page) {
 		mem_cgroup_uncharge_page(cow_page);
@@ -3467,6 +3556,8 @@ uncharge_out:
 	}
 	return ret;
 race_out:
+	if (pgtable)
+		pte_free(mm, pgtable);
 	if (cow_page)
 		mem_cgroup_uncharge_page(cow_page);
 	if (anon)
@@ -3519,6 +3610,19 @@ static int do_nonlinear_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	return __do_fault(mm, vma, address, pmd, pgoff, flags, orig_pte);
 }
 
+static int do_huge_linear_fault(struct mm_struct *mm,
+		struct vm_area_struct *vma, unsigned long address, pmd_t *pmd,
+		unsigned int flags)
+{
+	pgoff_t pgoff = (((address & PAGE_MASK)
+			- vma->vm_start) >> PAGE_SHIFT) + vma->vm_pgoff;
+	pte_t __unused; /* unused with FAULT_FLAG_TRANSHUGE */
+
+	flags |= FAULT_FLAG_TRANSHUGE;
+
+	return __do_fault(mm, vma, address, pmd, pgoff, flags, __unused);
+}
+
 int numa_migrate_prep(struct page *page, struct vm_area_struct *vma,
 				unsigned long addr, int current_nid)
 {
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
