Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id D83A66B0253
	for <linux-mm@kvack.org>; Tue, 30 Aug 2016 22:08:55 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id w128so77998080pfd.3
        for <linux-mm@kvack.org>; Tue, 30 Aug 2016 19:08:55 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id x190si47903055pfd.105.2016.08.30.19.08.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Aug 2016 19:08:55 -0700 (PDT)
Subject: [PATCH v2] thp: reduce usage of huge zero page's atomic counter
References: <b7e47f2c-8aac-156a-f627-a50db31220f8@intel.com>
 <20160830155919.GA482@swordfish>
From: Aaron Lu <aaron.lu@intel.com>
Message-ID: <fe51a88f-446a-4622-1363-ad1282d71385@intel.com>
Date: Wed, 31 Aug 2016 10:08:51 +0800
MIME-Version: 1.0
In-Reply-To: <20160830155919.GA482@swordfish>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, "'Kirill A. Shutemov'" <kirill.shutemov@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Huang Ying <ying.huang@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Ebru Akagunduz <ebru.akagunduz@gmail.com>, linux-kernel@vger.kernel.org

On 08/30/2016 11:59 PM, Sergey Senozhatsky wrote:
> Hello,
> 
> for !CONFIG_TRANSPARENT_HUGEPAGE configs mm_put_huge_zero_page() is BUILD_BUG(),
> which gives the following build error (mmots v4.8-rc4-mmots-2016-08-29-16-56)

My bad, I mistakenly understand BUILD_BUG and now that
mm_put_huge_zero_page will not be eliminated during compile time, it's
not appropriate to use BUILD_BUG here.

Thanks for the note, I have changed the BUILD_BUG to "return;".

In the meantime, I have also added performance change and runtime change
data to the changelog.


From: Aaron Lu <aaron.lu@intel.com>
Date: Fri, 17 Jun 2016 17:13:08 +0800
Subject: [PATCH v2] thp: reduce usage of huge zero page's atomic counter

The global zero page is used to satisfy an anonymous read fault. If
THP(Transparent HugePage) is enabled then the global huge zero page is used.
The global huge zero page uses an atomic counter for reference counting
and is allocated/freed dynamically according to its counter value.

CPU time spent on that counter will greatly increase if there are
a lot of processes doing anonymous read faults. This patch proposes a
way to reduce the access to the global counter so that the CPU load
can be reduced accordingly.

To do this, a new flag of the mm_struct is introduced: MMF_USED_HUGE_ZERO_PAGE.
With this flag, the process only need to touch the global counter in
two cases:
1 The first time it uses the global huge zero page;
2 The time when mm_user of its mm_struct reaches zero.

Note that right now, the huge zero page is eligible to be freed as soon
as its last use goes away.  With this patch, the page will not be
eligible to be freed until the exit of the last process from which it
was ever used.

And with the use of mm_user, the kthread is not eligible to use huge
zero page either. Since no kthread is using huge zero page today, there
is no difference after applying this patch. But if that is not desired,
I can change it to when mm_count reaches zero.

Case used for test on Haswell EP:
usemem -n 72 --readonly -j 0x200000 100G
Which spawns 72 processes and each will mmap 100G anonymous space and
then do read only access to that space sequentially with a step of 2MB.

CPU cycles from perf report for base commit:
    54.03%  usemem   [kernel.kallsyms]   [k] get_huge_zero_page
CPU cycles from perf report for this commit:
     0.11%  usemem   [kernel.kallsyms]   [k] mm_get_huge_zero_page

Performance(throughput) of the workload for base commit: 1784430792
Performance(throughput) of the workload for this commit: 4726928591
164% increase.

Runtime of the workload for base commit: 707592 us
Runtime of the workload for this commit: 303970 us
50% drop.

Signed-off-by: Aaron Lu <aaron.lu@intel.com>
---
 fs/dax.c                |  2 +-
 include/linux/huge_mm.h |  8 ++++----
 include/linux/sched.h   |  1 +
 kernel/fork.c           |  1 +
 mm/huge_memory.c        | 36 +++++++++++++++++++++++++-----------
 mm/swap.c               |  4 +---
 mm/swap_state.c         |  4 +---
 7 files changed, 34 insertions(+), 22 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index 993dc6fe0416..226c0d5eedac 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -1034,7 +1034,7 @@ int dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
 	if (!write && !buffer_mapped(&bh)) {
 		spinlock_t *ptl;
 		pmd_t entry;
-		struct page *zero_page = get_huge_zero_page();
+		struct page *zero_page = mm_get_huge_zero_page(vma->vm_mm);
 
 		if (unlikely(!zero_page)) {
 			dax_pmd_dbg(&bh, address, "no zero page");
diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index 6f14de45b5ce..9e6ab7eeaf17 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -152,8 +152,8 @@ static inline bool is_huge_zero_pmd(pmd_t pmd)
 	return is_huge_zero_page(pmd_page(pmd));
 }
 
-struct page *get_huge_zero_page(void);
-void put_huge_zero_page(void);
+struct page *mm_get_huge_zero_page(struct mm_struct *mm);
+void mm_put_huge_zero_page(struct mm_struct *mm);
 
 #define mk_huge_pmd(page, prot) pmd_mkhuge(mk_pmd(page, prot))
 
@@ -213,9 +213,9 @@ static inline bool is_huge_zero_page(struct page *page)
 	return false;
 }
 
-static inline void put_huge_zero_page(void)
+static inline void mm_put_huge_zero_page(struct mm_struct *mm)
 {
-	BUILD_BUG();
+	return;
 }
 
 static inline struct page *follow_devmap_pmd(struct vm_area_struct *vma,
diff --git a/include/linux/sched.h b/include/linux/sched.h
index d7e1e783cf01..02246a70b63c 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -523,6 +523,7 @@ static inline int get_dumpable(struct mm_struct *mm)
 #define MMF_RECALC_UPROBES	20	/* MMF_HAS_UPROBES can be wrong */
 #define MMF_OOM_REAPED		21	/* mm has been already reaped */
 #define MMF_OOM_NOT_REAPABLE	22	/* mm couldn't be reaped */
+#define MMF_HUGE_ZERO_PAGE	23      /* mm has ever used the global huge zero page */
 
 #define MMF_INIT_MASK		(MMF_DUMPABLE_MASK | MMF_DUMP_FILTER_MASK)
 
diff --git a/kernel/fork.c b/kernel/fork.c
index 52e725d4a866..372e02616b47 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -711,6 +711,7 @@ static inline void __mmput(struct mm_struct *mm)
 	ksm_exit(mm);
 	khugepaged_exit(mm); /* must run before exit_mmap */
 	exit_mmap(mm);
+	mm_put_huge_zero_page(mm);
 	set_mm_exe_file(mm, NULL);
 	if (!list_empty(&mm->mmlist)) {
 		spin_lock(&mmlist_lock);
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 2db2112aa31e..d88bb1ec6fad 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -59,7 +59,7 @@ static struct shrinker deferred_split_shrinker;
 static atomic_t huge_zero_refcount;
 struct page *huge_zero_page __read_mostly;
 
-struct page *get_huge_zero_page(void)
+static struct page *get_huge_zero_page(void)
 {
 	struct page *zero_page;
 retry:
@@ -86,7 +86,7 @@ retry:
 	return READ_ONCE(huge_zero_page);
 }
 
-void put_huge_zero_page(void)
+static void put_huge_zero_page(void)
 {
 	/*
 	 * Counter should never go to zero here. Only shrinker can put
@@ -95,6 +95,26 @@ void put_huge_zero_page(void)
 	BUG_ON(atomic_dec_and_test(&huge_zero_refcount));
 }
 
+struct page *mm_get_huge_zero_page(struct mm_struct *mm)
+{
+	if (test_bit(MMF_HUGE_ZERO_PAGE, &mm->flags))
+		return READ_ONCE(huge_zero_page);
+
+	if (!get_huge_zero_page())
+		return NULL;
+
+	if (test_and_set_bit(MMF_HUGE_ZERO_PAGE, &mm->flags))
+		put_huge_zero_page();
+
+	return READ_ONCE(huge_zero_page);
+}
+
+void mm_put_huge_zero_page(struct mm_struct *mm)
+{
+	if (test_bit(MMF_HUGE_ZERO_PAGE, &mm->flags))
+		put_huge_zero_page();
+}
+
 static unsigned long shrink_huge_zero_page_count(struct shrinker *shrink,
 					struct shrink_control *sc)
 {
@@ -601,7 +621,7 @@ int do_huge_pmd_anonymous_page(struct fault_env *fe)
 		pgtable = pte_alloc_one(vma->vm_mm, haddr);
 		if (unlikely(!pgtable))
 			return VM_FAULT_OOM;
-		zero_page = get_huge_zero_page();
+		zero_page = mm_get_huge_zero_page(vma->vm_mm);
 		if (unlikely(!zero_page)) {
 			pte_free(vma->vm_mm, pgtable);
 			count_vm_event(THP_FAULT_FALLBACK);
@@ -623,10 +643,8 @@ int do_huge_pmd_anonymous_page(struct fault_env *fe)
 			}
 		} else
 			spin_unlock(fe->ptl);
-		if (!set) {
+		if (!set)
 			pte_free(vma->vm_mm, pgtable);
-			put_huge_zero_page();
-		}
 		return ret;
 	}
 	gfp = alloc_hugepage_direct_gfpmask(vma);
@@ -780,7 +798,7 @@ int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 		 * since we already have a zero page to copy. It just takes a
 		 * reference.
 		 */
-		zero_page = get_huge_zero_page();
+		zero_page = mm_get_huge_zero_page(dst_mm);
 		set_huge_zero_page(pgtable, dst_mm, vma, addr, dst_pmd,
 				zero_page);
 		ret = 0;
@@ -1038,7 +1056,6 @@ alloc:
 		update_mmu_cache_pmd(vma, fe->address, fe->pmd);
 		if (!page) {
 			add_mm_counter(vma->vm_mm, MM_ANONPAGES, HPAGE_PMD_NR);
-			put_huge_zero_page();
 		} else {
 			VM_BUG_ON_PAGE(!PageHead(page), page);
 			page_remove_rmap(page, true);
@@ -1502,7 +1519,6 @@ static void __split_huge_zero_page_pmd(struct vm_area_struct *vma,
 	}
 	smp_wmb(); /* make pte visible before pmd */
 	pmd_populate(mm, pmd, pgtable);
-	put_huge_zero_page();
 }
 
 static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
@@ -1525,8 +1541,6 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
 
 	if (!vma_is_anonymous(vma)) {
 		_pmd = pmdp_huge_clear_flush_notify(vma, haddr, pmd);
-		if (is_huge_zero_pmd(_pmd))
-			put_huge_zero_page();
 		if (vma_is_dax(vma))
 			return;
 		page = pmd_page(_pmd);
diff --git a/mm/swap.c b/mm/swap.c
index 75c63bb2a1da..4dcf852e1e6d 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -748,10 +748,8 @@ void release_pages(struct page **pages, int nr, bool cold)
 			locked_pgdat = NULL;
 		}
 
-		if (is_huge_zero_page(page)) {
-			put_huge_zero_page();
+		if (is_huge_zero_page(page))
 			continue;
-		}
 
 		page = compound_head(page);
 		if (!put_page_testzero(page))
diff --git a/mm/swap_state.c b/mm/swap_state.c
index c8310a37be3a..5ffd3ee26592 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -252,9 +252,7 @@ static inline void free_swap_cache(struct page *page)
 void free_page_and_swap_cache(struct page *page)
 {
 	free_swap_cache(page);
-	if (is_huge_zero_page(page))
-		put_huge_zero_page();
-	else
+	if (!is_huge_zero_page(page))
 		put_page(page);
 }
 
-- 
2.5.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
