Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id C8E516B000D
	for <linux-mm@kvack.org>; Wed, 30 Jan 2013 19:26:27 -0500 (EST)
Received: by mail-da0-f41.google.com with SMTP id e20so1017577dak.0
        for <linux-mm@kvack.org>; Wed, 30 Jan 2013 16:26:27 -0800 (PST)
From: Michel Lespinasse <walken@google.com>
Subject: [PATCH 2/3] mm: accelerate mm_populate() treatment of THP pages
Date: Wed, 30 Jan 2013 16:26:19 -0800
Message-Id: <1359591980-29542-3-git-send-email-walken@google.com>
In-Reply-To: <1359591980-29542-1-git-send-email-walken@google.com>
References: <1359591980-29542-1-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org

This change adds a page_mask argument to follow_page.

follow_page sets *page_mask to HPAGE_PMD_NR - 1 when it encounters a THP page,
and to 0 in other cases.

__get_user_pages() makes use of this in order to accelerate populating
THP ranges - that is, when both the pages and vmas arrays are NULL,
we don't need to iterate HPAGE_PMD_NR times to cover a single THP page
(and we also avoid taking mm->page_table_lock that many times).

Other follow_page() call sites can safely ignore the value returned in
*page_mask.

Signed-off-by: Michel Lespinasse <walken@google.com>

---
 arch/ia64/xen/xencomm.c    |  3 ++-
 arch/powerpc/kernel/vdso.c |  9 +++++----
 arch/s390/mm/pgtable.c     |  3 ++-
 include/linux/mm.h         |  2 +-
 mm/ksm.c                   | 10 +++++++---
 mm/memory.c                | 25 +++++++++++++++++++------
 mm/migrate.c               |  7 +++++--
 mm/mlock.c                 |  4 +++-
 8 files changed, 44 insertions(+), 19 deletions(-)

diff --git a/arch/ia64/xen/xencomm.c b/arch/ia64/xen/xencomm.c
index 73d903ca2d64..c5dcf3a574e9 100644
--- a/arch/ia64/xen/xencomm.c
+++ b/arch/ia64/xen/xencomm.c
@@ -44,6 +44,7 @@ xencomm_vtop(unsigned long vaddr)
 {
 	struct page *page;
 	struct vm_area_struct *vma;
+	long page_mask;
 
 	if (vaddr == 0)
 		return 0UL;
@@ -98,7 +99,7 @@ xencomm_vtop(unsigned long vaddr)
 		return ~0UL;
 
 	/* We assume the page is modified.  */
-	page = follow_page(vma, vaddr, FOLL_WRITE | FOLL_TOUCH);
+	page = follow_page(vma, vaddr, FOLL_WRITE | FOLL_TOUCH, &page_mask);
 	if (IS_ERR_OR_NULL(page))
 		return ~0UL;
 
diff --git a/arch/powerpc/kernel/vdso.c b/arch/powerpc/kernel/vdso.c
index 1b2076f049ce..a529502d60f9 100644
--- a/arch/powerpc/kernel/vdso.c
+++ b/arch/powerpc/kernel/vdso.c
@@ -156,6 +156,7 @@ static void dump_one_vdso_page(struct page *pg, struct page *upg)
 static void dump_vdso_pages(struct vm_area_struct * vma)
 {
 	int i;
+	long page_mask;
 
 	if (!vma || is_32bit_task()) {
 		printk("vDSO32 @ %016lx:\n", (unsigned long)vdso32_kbase);
@@ -163,8 +164,8 @@ static void dump_vdso_pages(struct vm_area_struct * vma)
 			struct page *pg = virt_to_page(vdso32_kbase +
 						       i*PAGE_SIZE);
 			struct page *upg = (vma && vma->vm_mm) ?
-				follow_page(vma, vma->vm_start + i*PAGE_SIZE, 0)
-				: NULL;
+				follow_page(vma, vma->vm_start + i*PAGE_SIZE,
+					    0, &page_mask) : NULL;
 			dump_one_vdso_page(pg, upg);
 		}
 	}
@@ -174,8 +175,8 @@ static void dump_vdso_pages(struct vm_area_struct * vma)
 			struct page *pg = virt_to_page(vdso64_kbase +
 						       i*PAGE_SIZE);
 			struct page *upg = (vma && vma->vm_mm) ?
-				follow_page(vma, vma->vm_start + i*PAGE_SIZE, 0)
-				: NULL;
+				follow_page(vma, vma->vm_start + i*PAGE_SIZE,
+					    0, &page_mask) : NULL;
 			dump_one_vdso_page(pg, upg);
 		}
 	}
diff --git a/arch/s390/mm/pgtable.c b/arch/s390/mm/pgtable.c
index ae44d2a34313..63e897a6cf45 100644
--- a/arch/s390/mm/pgtable.c
+++ b/arch/s390/mm/pgtable.c
@@ -792,9 +792,10 @@ void thp_split_vma(struct vm_area_struct *vma)
 {
 	unsigned long addr;
 	struct page *page;
+	long page_mask;
 
 	for (addr = vma->vm_start; addr < vma->vm_end; addr += PAGE_SIZE) {
-		page = follow_page(vma, addr, FOLL_SPLIT);
+		page = follow_page(vma, addr, FOLL_SPLIT, &page_mask);
 	}
 }
 
diff --git a/include/linux/mm.h b/include/linux/mm.h
index d5716094f191..6dc0ce370df5 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1636,7 +1636,7 @@ int vm_insert_mixed(struct vm_area_struct *vma, unsigned long addr,
 			unsigned long pfn);
 
 struct page *follow_page(struct vm_area_struct *, unsigned long address,
-			unsigned int foll_flags);
+			 unsigned int foll_flags, long *page_mask);
 #define FOLL_WRITE	0x01	/* check pte is writable */
 #define FOLL_TOUCH	0x02	/* mark page accessed */
 #define FOLL_GET	0x04	/* do get_page on page */
diff --git a/mm/ksm.c b/mm/ksm.c
index 51573858938d..76dfb7133aa4 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -330,10 +330,11 @@ static int break_ksm(struct vm_area_struct *vma, unsigned long addr)
 {
 	struct page *page;
 	int ret = 0;
+	long page_mask;
 
 	do {
 		cond_resched();
-		page = follow_page(vma, addr, FOLL_GET);
+		page = follow_page(vma, addr, FOLL_GET, &page_mask);
 		if (IS_ERR_OR_NULL(page))
 			break;
 		if (PageKsm(page))
@@ -427,13 +428,14 @@ static struct page *get_mergeable_page(struct rmap_item *rmap_item)
 	unsigned long addr = rmap_item->address;
 	struct vm_area_struct *vma;
 	struct page *page;
+	long page_mask;
 
 	down_read(&mm->mmap_sem);
 	vma = find_mergeable_vma(mm, addr);
 	if (!vma)
 		goto out;
 
-	page = follow_page(vma, addr, FOLL_GET);
+	page = follow_page(vma, addr, FOLL_GET, &page_mask);
 	if (IS_ERR_OR_NULL(page))
 		goto out;
 	if (PageAnon(page) || page_trans_compound_anon(page)) {
@@ -1289,6 +1291,7 @@ static struct rmap_item *scan_get_next_rmap_item(struct page **page)
 	struct mm_slot *slot;
 	struct vm_area_struct *vma;
 	struct rmap_item *rmap_item;
+	long page_mask;
 
 	if (list_empty(&ksm_mm_head.mm_list))
 		return NULL;
@@ -1342,7 +1345,8 @@ next_mm:
 		while (ksm_scan.address < vma->vm_end) {
 			if (ksm_test_exit(mm))
 				break;
-			*page = follow_page(vma, ksm_scan.address, FOLL_GET);
+			*page = follow_page(vma, ksm_scan.address, FOLL_GET,
+					    &page_mask);
 			if (IS_ERR_OR_NULL(*page)) {
 				ksm_scan.address += PAGE_SIZE;
 				cond_resched();
diff --git a/mm/memory.c b/mm/memory.c
index 381b78c20d84..1becba27c28a 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1470,7 +1470,7 @@ EXPORT_SYMBOL_GPL(zap_vma_ptes);
  * by a page descriptor (see also vm_normal_page()).
  */
 struct page *follow_page(struct vm_area_struct *vma, unsigned long address,
-			unsigned int flags)
+			 unsigned int flags, long *page_mask)
 {
 	pgd_t *pgd;
 	pud_t *pud;
@@ -1480,6 +1480,8 @@ struct page *follow_page(struct vm_area_struct *vma, unsigned long address,
 	struct page *page;
 	struct mm_struct *mm = vma->vm_mm;
 
+	*page_mask = 0;
+
 	page = follow_huge_addr(mm, address, flags & FOLL_WRITE);
 	if (!IS_ERR(page)) {
 		BUG_ON(flags & FOLL_GET);
@@ -1526,6 +1528,7 @@ struct page *follow_page(struct vm_area_struct *vma, unsigned long address,
 				page = follow_trans_huge_pmd(vma, address,
 							     pmd, flags);
 				spin_unlock(&mm->page_table_lock);
+				*page_mask = HPAGE_PMD_NR - 1;
 				goto out;
 			}
 		} else
@@ -1680,6 +1683,7 @@ long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 {
 	long i;
 	unsigned long vm_flags;
+	long page_mask;
 
 	if (nr_pages <= 0)
 		return 0;
@@ -1757,6 +1761,7 @@ long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 				get_page(page);
 			}
 			pte_unmap(pte);
+			page_mask = 0;
 			goto next_page;
 		}
 
@@ -1774,6 +1779,7 @@ long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 		do {
 			struct page *page;
 			unsigned int foll_flags = gup_flags;
+			long page_increm;
 
 			/*
 			 * If we have a pending SIGKILL, don't keep faulting
@@ -1783,7 +1789,8 @@ long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 				return i ? i : -ERESTARTSYS;
 
 			cond_resched();
-			while (!(page = follow_page(vma, start, foll_flags))) {
+			while (!(page = follow_page(vma, start, foll_flags,
+						    &page_mask))) {
 				int ret;
 				unsigned int fault_flags = 0;
 
@@ -1857,13 +1864,19 @@ long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 
 				flush_anon_page(vma, page, start);
 				flush_dcache_page(page);
+				page_mask = 0;
 			}
 next_page:
-			if (vmas)
+			if (vmas) {
 				vmas[i] = vma;
-			i++;
-			start += PAGE_SIZE;
-			nr_pages--;
+				page_mask = 0;
+			}
+			page_increm = 1 + (~(start >> PAGE_SHIFT) & page_mask);
+			if (page_increm > nr_pages)
+				page_increm = nr_pages;
+			i += page_increm;
+			start += page_increm * PAGE_SIZE;
+			nr_pages -= page_increm;
 		} while (nr_pages && start < vma->vm_end);
 	} while (nr_pages);
 	return i;
diff --git a/mm/migrate.c b/mm/migrate.c
index c38778610aa8..daa5726c9c46 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1124,6 +1124,7 @@ static int do_move_page_to_node_array(struct mm_struct *mm,
 	int err;
 	struct page_to_node *pp;
 	LIST_HEAD(pagelist);
+	long page_mask;
 
 	down_read(&mm->mmap_sem);
 
@@ -1139,7 +1140,8 @@ static int do_move_page_to_node_array(struct mm_struct *mm,
 		if (!vma || pp->addr < vma->vm_start || !vma_migratable(vma))
 			goto set_status;
 
-		page = follow_page(vma, pp->addr, FOLL_GET|FOLL_SPLIT);
+		page = follow_page(vma, pp->addr, FOLL_GET | FOLL_SPLIT,
+				   &page_mask);
 
 		err = PTR_ERR(page);
 		if (IS_ERR(page))
@@ -1291,6 +1293,7 @@ static void do_pages_stat_array(struct mm_struct *mm, unsigned long nr_pages,
 				const void __user **pages, int *status)
 {
 	unsigned long i;
+	long page_mask;
 
 	down_read(&mm->mmap_sem);
 
@@ -1304,7 +1307,7 @@ static void do_pages_stat_array(struct mm_struct *mm, unsigned long nr_pages,
 		if (!vma || addr < vma->vm_start)
 			goto set_status;
 
-		page = follow_page(vma, addr, 0);
+		page = follow_page(vma, addr, 0, &page_mask);
 
 		err = PTR_ERR(page);
 		if (IS_ERR(page))
diff --git a/mm/mlock.c b/mm/mlock.c
index e1fa9e4b0a66..2694f17cca2d 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -223,6 +223,7 @@ void munlock_vma_pages_range(struct vm_area_struct *vma,
 			     unsigned long start, unsigned long end)
 {
 	unsigned long addr;
+	long page_mask;
 
 	lru_add_drain();
 	vma->vm_flags &= ~VM_LOCKED;
@@ -236,7 +237,8 @@ void munlock_vma_pages_range(struct vm_area_struct *vma,
 		 * suits munlock very well (and if somehow an abnormal page
 		 * has sneaked into the range, we won't oops here: great).
 		 */
-		page = follow_page(vma, addr, FOLL_GET | FOLL_DUMP);
+		page = follow_page(vma, addr, FOLL_GET | FOLL_DUMP,
+				   &page_mask);
 		if (page && !IS_ERR(page)) {
 			lock_page(page);
 			munlock_vma_page(page);
-- 
1.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
