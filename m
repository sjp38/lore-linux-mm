Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id D5A306B004F
	for <linux-mm@kvack.org>; Tue, 23 Jun 2009 08:47:44 -0400 (EDT)
Date: Tue, 23 Jun 2009 13:49:05 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: [PATCH] hugetlb: fault flags instead of write_access
In-Reply-To: <alpine.LFD.2.01.0906211331480.3240@localhost.localdomain>
Message-ID: <Pine.LNX.4.64.0906231345001.19552@sister.anvils>
References: <alpine.LFD.2.01.0906211331480.3240@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Wu Fengguang <fengguang.wu@intel.com>, Ingo Molnar <mingo@elte.hu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

handle_mm_fault() is now passing fault flags rather than write_access
down to hugetlb_fault(), so better recognize that in hugetlb_fault(),
and in hugetlb_no_page().

Signed-off-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>
---

 include/linux/hugetlb.h |    4 ++--
 mm/hugetlb.c            |   17 +++++++++--------
 2 files changed, 11 insertions(+), 10 deletions(-)

--- 2.6.30-git20/include/linux/hugetlb.h	2009-06-23 11:06:22.000000000 +0100
+++ linux/include/linux/hugetlb.h	2009-06-23 13:07:57.000000000 +0100
@@ -33,7 +33,7 @@ void hugetlb_report_meminfo(struct seq_f
 int hugetlb_report_node_meminfo(int, char *);
 unsigned long hugetlb_total_pages(void);
 int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
-			unsigned long address, int write_access);
+			unsigned long address, unsigned int flags);
 int hugetlb_reserve_pages(struct inode *inode, long from, long to,
 						struct vm_area_struct *vma,
 						int acctflags);
@@ -98,7 +98,7 @@ static inline void hugetlb_report_meminf
 #define pud_huge(x)	0
 #define is_hugepage_only_range(mm, addr, len)	0
 #define hugetlb_free_pgd_range(tlb, addr, end, floor, ceiling) ({BUG(); 0; })
-#define hugetlb_fault(mm, vma, addr, write)	({ BUG(); 0; })
+#define hugetlb_fault(mm, vma, addr, flags)	({ BUG(); 0; })
 
 #define hugetlb_change_protection(vma, address, end, newprot)
 
--- 2.6.30-git20/mm/hugetlb.c	2009-06-23 11:06:25.000000000 +0100
+++ linux/mm/hugetlb.c	2009-06-23 13:07:57.000000000 +0100
@@ -1985,7 +1985,7 @@ static struct page *hugetlbfs_pagecache_
 }
 
 static int hugetlb_no_page(struct mm_struct *mm, struct vm_area_struct *vma,
-			unsigned long address, pte_t *ptep, int write_access)
+			unsigned long address, pte_t *ptep, unsigned int flags)
 {
 	struct hstate *h = hstate_vma(vma);
 	int ret = VM_FAULT_SIGBUS;
@@ -2053,7 +2053,7 @@ retry:
 	 * any allocations necessary to record that reservation occur outside
 	 * the spinlock.
 	 */
-	if (write_access && !(vma->vm_flags & VM_SHARED))
+	if ((flags & FAULT_FLAG_WRITE) && !(vma->vm_flags & VM_SHARED))
 		if (vma_needs_reservation(h, vma, address) < 0) {
 			ret = VM_FAULT_OOM;
 			goto backout_unlocked;
@@ -2072,7 +2072,7 @@ retry:
 				&& (vma->vm_flags & VM_SHARED)));
 	set_huge_pte_at(mm, address, ptep, new_pte);
 
-	if (write_access && !(vma->vm_flags & VM_SHARED)) {
+	if ((flags & FAULT_FLAG_WRITE) && !(vma->vm_flags & VM_SHARED)) {
 		/* Optimization, do the COW without a second fault */
 		ret = hugetlb_cow(mm, vma, address, ptep, new_pte, page);
 	}
@@ -2091,7 +2091,7 @@ backout_unlocked:
 }
 
 int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
-			unsigned long address, int write_access)
+			unsigned long address, unsigned int flags)
 {
 	pte_t *ptep;
 	pte_t entry;
@@ -2112,7 +2112,7 @@ int hugetlb_fault(struct mm_struct *mm,
 	mutex_lock(&hugetlb_instantiation_mutex);
 	entry = huge_ptep_get(ptep);
 	if (huge_pte_none(entry)) {
-		ret = hugetlb_no_page(mm, vma, address, ptep, write_access);
+		ret = hugetlb_no_page(mm, vma, address, ptep, flags);
 		goto out_mutex;
 	}
 
@@ -2126,7 +2126,7 @@ int hugetlb_fault(struct mm_struct *mm,
 	 * page now as it is used to determine if a reservation has been
 	 * consumed.
 	 */
-	if (write_access && !pte_write(entry)) {
+	if ((flags & FAULT_FLAG_WRITE) && !pte_write(entry)) {
 		if (vma_needs_reservation(h, vma, address) < 0) {
 			ret = VM_FAULT_OOM;
 			goto out_mutex;
@@ -2143,7 +2143,7 @@ int hugetlb_fault(struct mm_struct *mm,
 		goto out_page_table_lock;
 
 
-	if (write_access) {
+	if (flags & FAULT_FLAG_WRITE) {
 		if (!pte_write(entry)) {
 			ret = hugetlb_cow(mm, vma, address, ptep, entry,
 							pagecache_page);
@@ -2152,7 +2152,8 @@ int hugetlb_fault(struct mm_struct *mm,
 		entry = pte_mkdirty(entry);
 	}
 	entry = pte_mkyoung(entry);
-	if (huge_ptep_set_access_flags(vma, address, ptep, entry, write_access))
+	if (huge_ptep_set_access_flags(vma, address, ptep, entry,
+						flags & FAULT_FLAG_WRITE))
 		update_mmu_cache(vma, address, entry);
 
 out_page_table_lock:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
