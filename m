Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 24C146B005C
	for <linux-mm@kvack.org>; Mon,  7 Oct 2013 09:54:43 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id bj1so7398297pad.28
        for <linux-mm@kvack.org>; Mon, 07 Oct 2013 06:54:42 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv5 07/11] mm, thp: do not access mm->pmd_huge_pte directly
Date: Mon,  7 Oct 2013 16:54:09 +0300
Message-Id: <1381154053-4848-8-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1381154053-4848-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1381154053-4848-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alex Thorlton <athorlton@sgi.com>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: "Eric W . Biederman" <ebiederm@xmission.com>, "Paul E . McKenney" <paulmck@linux.vnet.ibm.com>, Al Viro <viro@zeniv.linux.org.uk>, Andi Kleen <ak@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Dave Jones <davej@redhat.com>, David Howells <dhowells@redhat.com>, Frederic Weisbecker <fweisbec@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Kees Cook <keescook@chromium.org>, Mel Gorman <mgorman@suse.de>, Michael Kerrisk <mtk.manpages@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Robin Holt <robinmholt@gmail.com>, Sedat Dilek <sedat.dilek@gmail.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Currently mm->pmd_huge_pte protected by page table lock. It will not
work with split lock. We have to have per-pmd pmd_huge_pte for proper
access serialization.

For now, let's just introduce wrapper to access mm->pmd_huge_pte.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Tested-by: Alex Thorlton <athorlton@sgi.com>
---
 arch/s390/mm/pgtable.c | 12 ++++++------
 arch/sparc/mm/tlb.c    | 12 ++++++------
 include/linux/mm.h     |  1 +
 mm/pgtable-generic.c   | 12 ++++++------
 4 files changed, 19 insertions(+), 18 deletions(-)

diff --git a/arch/s390/mm/pgtable.c b/arch/s390/mm/pgtable.c
index de8cbc30dc..c463e5cd3b 100644
--- a/arch/s390/mm/pgtable.c
+++ b/arch/s390/mm/pgtable.c
@@ -1225,11 +1225,11 @@ void pgtable_trans_huge_deposit(struct mm_struct *mm, pmd_t *pmdp,
 	assert_spin_locked(&mm->page_table_lock);
 
 	/* FIFO */
-	if (!mm->pmd_huge_pte)
+	if (!pmd_huge_pte(mm, pmdp))
 		INIT_LIST_HEAD(lh);
 	else
-		list_add(lh, (struct list_head *) mm->pmd_huge_pte);
-	mm->pmd_huge_pte = pgtable;
+		list_add(lh, (struct list_head *) pmd_huge_pte(mm, pmdp));
+	pmd_huge_pte(mm, pmdp) = pgtable;
 }
 
 pgtable_t pgtable_trans_huge_withdraw(struct mm_struct *mm, pmd_t *pmdp)
@@ -1241,12 +1241,12 @@ pgtable_t pgtable_trans_huge_withdraw(struct mm_struct *mm, pmd_t *pmdp)
 	assert_spin_locked(&mm->page_table_lock);
 
 	/* FIFO */
-	pgtable = mm->pmd_huge_pte;
+	pgtable = pmd_huge_pte(mm, pmdp);
 	lh = (struct list_head *) pgtable;
 	if (list_empty(lh))
-		mm->pmd_huge_pte = NULL;
+		pmd_huge_pte(mm, pmdp) = NULL;
 	else {
-		mm->pmd_huge_pte = (pgtable_t) lh->next;
+		pmd_huge_pte(mm, pmdp) = (pgtable_t) lh->next;
 		list_del(lh);
 	}
 	ptep = (pte_t *) pgtable;
diff --git a/arch/sparc/mm/tlb.c b/arch/sparc/mm/tlb.c
index 7a91f288c7..656cc46a81 100644
--- a/arch/sparc/mm/tlb.c
+++ b/arch/sparc/mm/tlb.c
@@ -196,11 +196,11 @@ void pgtable_trans_huge_deposit(struct mm_struct *mm, pmd_t *pmdp,
 	assert_spin_locked(&mm->page_table_lock);
 
 	/* FIFO */
-	if (!mm->pmd_huge_pte)
+	if (!pmd_huge_pte(mm, pmdp))
 		INIT_LIST_HEAD(lh);
 	else
-		list_add(lh, (struct list_head *) mm->pmd_huge_pte);
-	mm->pmd_huge_pte = pgtable;
+		list_add(lh, (struct list_head *) pmd_huge_pte(mm, pmdp));
+	pmd_huge_pte(mm, pmdp) = pgtable;
 }
 
 pgtable_t pgtable_trans_huge_withdraw(struct mm_struct *mm, pmd_t *pmdp)
@@ -211,12 +211,12 @@ pgtable_t pgtable_trans_huge_withdraw(struct mm_struct *mm, pmd_t *pmdp)
 	assert_spin_locked(&mm->page_table_lock);
 
 	/* FIFO */
-	pgtable = mm->pmd_huge_pte;
+	pgtable = pmd_huge_pte(mm, pmdp);
 	lh = (struct list_head *) pgtable;
 	if (list_empty(lh))
-		mm->pmd_huge_pte = NULL;
+		pmd_huge_pte(mm, pmdp) = NULL;
 	else {
-		mm->pmd_huge_pte = (pgtable_t) lh->next;
+		pmd_huge_pte(mm, pmdp) = (pgtable_t) lh->next;
 		list_del(lh);
 	}
 	pte_val(pgtable[0]) = 0;
diff --git a/include/linux/mm.h b/include/linux/mm.h
index e3481c6b52..b96aac9622 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1299,6 +1299,7 @@ static inline spinlock_t *pmd_lockptr(struct mm_struct *mm, pmd_t *pmd)
 	return &mm->page_table_lock;
 }
 
+#define pmd_huge_pte(mm, pmd) ((mm)->pmd_huge_pte)
 
 static inline spinlock_t *pmd_lock(struct mm_struct *mm, pmd_t *pmd)
 {
diff --git a/mm/pgtable-generic.c b/mm/pgtable-generic.c
index 3929a40bd6..41fee3e5d5 100644
--- a/mm/pgtable-generic.c
+++ b/mm/pgtable-generic.c
@@ -154,11 +154,11 @@ void pgtable_trans_huge_deposit(struct mm_struct *mm, pmd_t *pmdp,
 	assert_spin_locked(&mm->page_table_lock);
 
 	/* FIFO */
-	if (!mm->pmd_huge_pte)
+	if (!pmd_huge_pte(mm, pmdp))
 		INIT_LIST_HEAD(&pgtable->lru);
 	else
-		list_add(&pgtable->lru, &mm->pmd_huge_pte->lru);
-	mm->pmd_huge_pte = pgtable;
+		list_add(&pgtable->lru, &pmd_huge_pte(mm, pmdp)->lru);
+	pmd_huge_pte(mm, pmdp) = pgtable;
 }
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 #endif
@@ -173,11 +173,11 @@ pgtable_t pgtable_trans_huge_withdraw(struct mm_struct *mm, pmd_t *pmdp)
 	assert_spin_locked(&mm->page_table_lock);
 
 	/* FIFO */
-	pgtable = mm->pmd_huge_pte;
+	pgtable = pmd_huge_pte(mm, pmdp);
 	if (list_empty(&pgtable->lru))
-		mm->pmd_huge_pte = NULL;
+		pmd_huge_pte(mm, pmdp) = NULL;
 	else {
-		mm->pmd_huge_pte = list_entry(pgtable->lru.next,
+		pmd_huge_pte(mm, pmdp) = list_entry(pgtable->lru.next,
 					      struct page, lru);
 		list_del(&pgtable->lru);
 	}
-- 
1.8.4.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
