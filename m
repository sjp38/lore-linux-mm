Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id B22DB6B006C
	for <linux-mm@kvack.org>; Thu, 23 Aug 2012 13:19:00 -0400 (EDT)
Received: from /spool/local
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <gerald.schaefer@de.ibm.com>;
	Thu, 23 Aug 2012 18:18:58 +0100
Received: from d06av02.portsmouth.uk.ibm.com (d06av02.portsmouth.uk.ibm.com [9.149.37.228])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q7NHIoY418153500
	for <linux-mm@kvack.org>; Thu, 23 Aug 2012 17:18:50 GMT
Received: from d06av02.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av02.portsmouth.uk.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q7NHItYC018778
	for <linux-mm@kvack.org>; Thu, 23 Aug 2012 11:18:56 -0600
Message-Id: <20120823171854.792085547@de.ibm.com>
Date: Thu, 23 Aug 2012 19:17:38 +0200
From: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Subject: [RFC patch 5/7] thp, s390: thp pagetable pre-allocation for System z
References: <20120823171733.595087166@de.ibm.com>
Content-Disposition: inline; filename=linux-3.5-thp-s390-pgtable.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, aarcange@redhat.com, linux-mm@kvack.org, ak@linux.intel.com, hughd@google.com
Cc: linux-kernel@vger.kernel.org, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, gerald.schaefer@de.ibm.com

This patch is part of the architecture backend for thp on System z.
It provides the pagetable pre-allocation functions pgtable_deposit()
and pgtable_withdraw(). Unlike other archs, s390 has no struct page *
as pgtable_t, but rather a pointer to the page table. So instead of
saving the pagetable pre-allocation list info inside the struct page,
it is being saved within the pagetable itself.

Signed-off-by: Gerald Schaefer <gerald.schaefer@de.ibm.com>
---
 arch/s390/include/asm/pgtable.h |    6 ++++++
 arch/s390/mm/pgtable.c          |   38 ++++++++++++++++++++++++++++++++++++++
 2 files changed, 44 insertions(+)

--- a/arch/s390/include/asm/pgtable.h
+++ b/arch/s390/include/asm/pgtable.h
@@ -1166,6 +1166,12 @@ static inline pmd_t *pmd_offset(pud_t *p
 #define pte_unmap(pte) do { } while (0)
 
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
+#define __HAVE_ARCH_PGTABLE_DEPOSIT
+extern void pgtable_deposit(struct mm_struct *mm, pgtable_t pgtable);
+
+#define __HAVE_ARCH_PGTABLE_WITHDRAW
+extern pgtable_t pgtable_withdraw(struct mm_struct *mm);
+
 static inline int pmd_trans_splitting(pmd_t pmd)
 {
 	return pmd_val(pmd) & _SEGMENT_ENTRY_SPLIT;
--- a/arch/s390/mm/pgtable.c
+++ b/arch/s390/mm/pgtable.c
@@ -883,4 +883,42 @@ void pmdp_splitting_flush(struct vm_area
 		smp_call_function(pmdp_splitting_flush_sync, NULL, 1);
 	}
 }
+
+void pgtable_deposit(struct mm_struct *mm, pgtable_t pgtable)
+{
+	struct list_head *lh = (struct list_head *) pgtable;
+
+	assert_spin_locked(&mm->page_table_lock);
+
+	/* FIFO */
+	if (!mm->pmd_huge_pte)
+		INIT_LIST_HEAD(lh);
+	else
+		list_add(lh, (struct list_head *) mm->pmd_huge_pte);
+	mm->pmd_huge_pte = pgtable;
+}
+
+pgtable_t pgtable_withdraw(struct mm_struct *mm)
+{
+	struct list_head *lh;
+	pgtable_t pgtable;
+	pte_t *ptep;
+
+	assert_spin_locked(&mm->page_table_lock);
+
+	/* FIFO */
+	pgtable = mm->pmd_huge_pte;
+	lh = (struct list_head *) pgtable;
+	if (list_empty(lh))
+		mm->pmd_huge_pte = NULL;
+	else {
+		mm->pmd_huge_pte = (pgtable_t) lh->next;
+		list_del(lh);
+	}
+	ptep = (pte_t *) pgtable;
+	pte_val(*ptep) = _PAGE_TYPE_EMPTY;
+	ptep++;
+	pte_val(*ptep) = _PAGE_TYPE_EMPTY;
+	return pgtable;
+}
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
