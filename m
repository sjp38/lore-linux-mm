Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id C9DE96B007B
	for <linux-mm@kvack.org>; Mon, 10 Sep 2012 09:13:25 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH v2 10/10] thp: implement refcounting for huge zero page
Date: Mon, 10 Sep 2012 16:13:33 +0300
Message-Id: <1347282813-21935-11-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1347282813-21935-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1347282813-21935-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org
Cc: Andi Kleen <ak@linux.intel.com>, "H. Peter Anvin" <hpa@linux.intel.com>, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill@shutemov.name>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

H. Peter Anvin doesn't like huge zero page which sticks in memory forever
after the first allocation. Here's implementation of lockless refcounting
for huge zero page.

We have two basic primitives: {get,put}_huge_zero_page(). They
manipulate reference counter.

If counter is 0, get_huge_zero_page() allocates a new huge page and
takes two references: one for caller and one for shrinker. We free the
page only in shrinker callback if counter is 1 (only shrinker has the
reference).

put_huge_zero_page() only decrements counter. Counter is never zero
in put_huge_zero_page() since shrinker holds on reference.

Freeing huge zero page in shrinker callback helps to avoid frequent
allocate-free.

Refcounting has cost. On 4 socket machine I observe ~1% slowdown on
parallel (40 processes) read page faulting comparing to lazy huge page
allocation.  I think it's pretty reasonable for synthetic benchmark.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/huge_memory.c |  108 ++++++++++++++++++++++++++++++++++++++++++------------
 1 files changed, 84 insertions(+), 24 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 0981b09..fa740fc 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -17,6 +17,7 @@
 #include <linux/khugepaged.h>
 #include <linux/freezer.h>
 #include <linux/mman.h>
+#include <linux/shrinker.h>
 #include <asm/tlb.h>
 #include <asm/pgalloc.h>
 #include "internal.h"
@@ -46,7 +47,6 @@ static unsigned int khugepaged_scan_sleep_millisecs __read_mostly = 10000;
 /* during fragmentation poll the hugepage allocator once every minute */
 static unsigned int khugepaged_alloc_sleep_millisecs __read_mostly = 60000;
 static struct task_struct *khugepaged_thread __read_mostly;
-static unsigned long huge_zero_pfn __read_mostly;
 static DEFINE_MUTEX(khugepaged_mutex);
 static DEFINE_SPINLOCK(khugepaged_mm_lock);
 static DECLARE_WAIT_QUEUE_HEAD(khugepaged_wait);
@@ -168,23 +168,13 @@ out:
 	return err;
 }
 
-static int init_huge_zero_pfn(void)
-{
-	struct page *hpage;
-	unsigned long pfn;
-
-	hpage = alloc_pages(GFP_TRANSHUGE | __GFP_ZERO, HPAGE_PMD_ORDER);
-	if (!hpage)
-		return -ENOMEM;
-	pfn = page_to_pfn(hpage);
-	if (cmpxchg(&huge_zero_pfn, 0, pfn))
-		__free_page(hpage);
-	return 0;
-}
+static atomic_t huge_zero_refcount;
+static unsigned long huge_zero_pfn __read_mostly;
 
 static inline bool is_huge_zero_pfn(unsigned long pfn)
 {
-	return huge_zero_pfn && pfn == huge_zero_pfn;
+	unsigned long zero_pfn = ACCESS_ONCE(huge_zero_pfn);
+	return zero_pfn && pfn == zero_pfn;
 }
 
 static inline bool is_huge_zero_pmd(pmd_t pmd)
@@ -192,6 +182,56 @@ static inline bool is_huge_zero_pmd(pmd_t pmd)
 	return is_huge_zero_pfn(pmd_pfn(pmd));
 }
 
+static unsigned long get_huge_zero_page(void)
+{
+	struct page *zero_page;
+retry:
+	if (likely(atomic_inc_not_zero(&huge_zero_refcount)))
+		return ACCESS_ONCE(huge_zero_pfn);
+
+	zero_page = alloc_pages(GFP_TRANSHUGE | __GFP_ZERO, HPAGE_PMD_ORDER);
+	if (!zero_page)
+		return 0;
+	if (cmpxchg(&huge_zero_pfn, 0, page_to_pfn(zero_page))) {
+		__free_page(zero_page);
+		goto retry;
+	}
+
+	/* We take additional reference here. It will be put back by shinker */
+	atomic_set(&huge_zero_refcount, 2);
+	return ACCESS_ONCE(huge_zero_pfn);
+}
+
+static void put_huge_zero_page(void)
+{
+	/*
+	 * Counter should never go to zero here. Only shrinker can put
+	 * last reference.
+	 */
+	BUG_ON(atomic_dec_and_test(&huge_zero_refcount));
+}
+
+static int shrink_huge_zero_page(struct shrinker *shrink,
+		struct shrink_control *sc)
+{
+	if (!sc->nr_to_scan)
+		/* we can free zero page only if last reference remains */
+		return atomic_read(&huge_zero_refcount) == 1 ? HPAGE_PMD_NR : 0;
+
+	if (atomic_cmpxchg(&huge_zero_refcount, 1, 0) == 1) {
+		unsigned long zero_pfn = xchg(&huge_zero_pfn, 0);
+		BUG_ON(zero_pfn == 0);
+		__free_page(__pfn_to_page(zero_pfn));
+	}
+
+	return 0;
+}
+
+static struct shrinker huge_zero_page_shrinker = {
+	.shrink = shrink_huge_zero_page,
+	.seeks = DEFAULT_SEEKS,
+};
+
 #ifdef CONFIG_SYSFS
 
 static ssize_t double_flag_show(struct kobject *kobj,
@@ -585,6 +625,8 @@ static int __init hugepage_init(void)
 		goto out;
 	}
 
+	register_shrinker(&huge_zero_page_shrinker);
+
 	/*
 	 * By default disable transparent hugepages on smaller systems,
 	 * where the extra memory used could hurt more than TLB overhead
@@ -722,10 +764,11 @@ static inline struct page *alloc_hugepage(int defrag)
 #endif
 
 static void set_huge_zero_page(pgtable_t pgtable, struct mm_struct *mm,
-		struct vm_area_struct *vma, unsigned long haddr, pmd_t *pmd)
+		struct vm_area_struct *vma, unsigned long haddr, pmd_t *pmd,
+		unsigned long zero_pfn)
 {
 	pmd_t entry;
-	entry = pfn_pmd(huge_zero_pfn, vma->vm_page_prot);
+	entry = pfn_pmd(zero_pfn, vma->vm_page_prot);
 	entry = pmd_wrprotect(entry);
 	entry = pmd_mkhuge(entry);
 	set_pmd_at(mm, haddr, pmd, entry);
@@ -748,15 +791,19 @@ int do_huge_pmd_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
 			return VM_FAULT_OOM;
 		if (!(flags & FAULT_FLAG_WRITE)) {
 			pgtable_t pgtable;
-			if (unlikely(!huge_zero_pfn && init_huge_zero_pfn())) {
-				count_vm_event(THP_FAULT_FALLBACK);
-				goto out;
-			}
+			unsigned long zero_pfn;
 			pgtable = pte_alloc_one(mm, haddr);
 			if (unlikely(!pgtable))
 				goto out;
+			zero_pfn = get_huge_zero_page();
+			if (unlikely(!zero_pfn)) {
+				pte_free(mm, pgtable);
+				count_vm_event(THP_FAULT_FALLBACK);
+				goto out;
+			}
 			spin_lock(&mm->page_table_lock);
-			set_huge_zero_page(pgtable, mm, vma, haddr, pmd);
+			set_huge_zero_page(pgtable, mm, vma, haddr, pmd,
+					zero_pfn);
 			spin_unlock(&mm->page_table_lock);
 			return 0;
 		}
@@ -825,7 +872,15 @@ int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 		goto out_unlock;
 	}
 	if (is_huge_zero_pmd(pmd)) {
-		set_huge_zero_page(pgtable, dst_mm, vma, addr, dst_pmd);
+		unsigned long zero_pfn;
+		/*
+		 * get_huge_zero_page() will never allocate a new page here,
+		 * since we already have a zero page to copy. It just takes a
+		 * reference.
+		 */
+		zero_pfn = get_huge_zero_page();
+		set_huge_zero_page(pgtable, dst_mm, vma, addr, dst_pmd,
+				zero_pfn);
 		ret = 0;
 		goto out_unlock;
 	}
@@ -926,6 +981,7 @@ static int do_huge_pmd_wp_zero_page_fallback(struct mm_struct *mm,
 	smp_wmb(); /* make pte visible before pmd */
 	pmd_populate(mm, pmd, pgtable);
 	spin_unlock(&mm->page_table_lock);
+	put_huge_zero_page();
 
 	ret |= VM_FAULT_WRITE;
 out:
@@ -1110,8 +1166,10 @@ alloc:
 		page_add_new_anon_rmap(new_page, vma, haddr);
 		set_pmd_at(mm, haddr, pmd, entry);
 		update_mmu_cache(vma, address, entry);
-		if (is_huge_zero_pmd(orig_pmd))
+		if (is_huge_zero_pmd(orig_pmd)) {
 			add_mm_counter(mm, MM_ANONPAGES, HPAGE_PMD_NR);
+			put_huge_zero_page();
+		}
 		if (page) {
 			VM_BUG_ON(!PageHead(page));
 			page_remove_rmap(page);
@@ -1175,6 +1233,7 @@ int zap_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
 			tlb_remove_pmd_tlb_entry(tlb, pmd, addr);
 			tlb->mm->nr_ptes--;
 			spin_unlock(&tlb->mm->page_table_lock);
+			put_huge_zero_page();
 		} else {
 			page = pmd_page(*pmd);
 			pmd_clear(pmd);
@@ -2538,6 +2597,7 @@ static void __split_huge_zero_page_pmd(struct vm_area_struct *vma,
 	}
 	smp_wmb(); /* make pte visible before pmd */
 	pmd_populate(vma->vm_mm, pmd, pgtable);
+	put_huge_zero_page();
 }
 
 void __split_huge_page_pmd(struct vm_area_struct *vma, unsigned long address,
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
