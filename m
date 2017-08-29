Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id A9893280300
	for <linux-mm@kvack.org>; Tue, 29 Aug 2017 19:55:01 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id q53so14819549qtq.3
        for <linux-mm@kvack.org>; Tue, 29 Aug 2017 16:55:01 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n58si3980797qtb.284.2017.08.29.16.55.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Aug 2017 16:55:00 -0700 (PDT)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [PATCH 01/13] dax: update to new mmu_notifier semantic
Date: Tue, 29 Aug 2017 19:54:35 -0400
Message-Id: <20170829235447.10050-2-jglisse@redhat.com>
In-Reply-To: <20170829235447.10050-1-jglisse@redhat.com>
References: <20170829235447.10050-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Bernhard Held <berny156@gmx.de>, Adam Borowski <kilobyte@angband.pl>, Andrea Arcangeli <aarcange@redhat.com>, =?UTF-8?q?Radim=20Kr=C4=8Dm=C3=A1=C5=99?= <rkrcmar@redhat.com>, Wanpeng Li <kernellwp@gmail.com>, Paolo Bonzini <pbonzini@redhat.com>, Takashi Iwai <tiwai@suse.de>, Nadav Amit <nadav.amit@gmail.com>, Mike Galbraith <efault@gmx.de>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, axie <axie@amd.com>, Andrew Morton <akpm@linux-foundation.org>

Replacing all mmu_notifier_invalida_page() by mmu_notifier_invalidat_range
and making sure it is bracketed by call to mmu_notifier_invalidate_range_start/
end.

Note that because we can not presume the pmd value or pte value we have to
assume the worse and unconditionaly report an invalidation as happening.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Bernhard Held <berny156@gmx.de>
Cc: Adam Borowski <kilobyte@angband.pl>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Radim KrA?mA!A? <rkrcmar@redhat.com>
Cc: Wanpeng Li <kernellwp@gmail.com>
Cc: Paolo Bonzini <pbonzini@redhat.com>
Cc: Takashi Iwai <tiwai@suse.de>
Cc: Nadav Amit <nadav.amit@gmail.com>
Cc: Mike Galbraith <efault@gmx.de>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: axie <axie@amd.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 fs/dax.c           | 19 +++++++++++--------
 include/linux/mm.h |  1 +
 mm/memory.c        | 26 +++++++++++++++++++++-----
 3 files changed, 33 insertions(+), 13 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index 865d42c63e23..ab925dc6647a 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -646,11 +646,10 @@ static void dax_mapping_entry_mkclean(struct address_space *mapping,
 	pte_t pte, *ptep = NULL;
 	pmd_t *pmdp = NULL;
 	spinlock_t *ptl;
-	bool changed;
 
 	i_mmap_lock_read(mapping);
 	vma_interval_tree_foreach(vma, &mapping->i_mmap, index, index) {
-		unsigned long address;
+		unsigned long address, start, end;
 
 		cond_resched();
 
@@ -658,8 +657,13 @@ static void dax_mapping_entry_mkclean(struct address_space *mapping,
 			continue;
 
 		address = pgoff_address(index, vma);
-		changed = false;
-		if (follow_pte_pmd(vma->vm_mm, address, &ptep, &pmdp, &ptl))
+
+		/*
+		 * Note because we provide start/end to follow_pte_pmd it will
+		 * call mmu_notifier_invalidate_range_start() on our behalf
+		 * before taking any lock.
+		 */
+		if (follow_pte_pmd(vma->vm_mm, address, &start, &end, &ptep, &pmdp, &ptl))
 			continue;
 
 		if (pmdp) {
@@ -676,7 +680,7 @@ static void dax_mapping_entry_mkclean(struct address_space *mapping,
 			pmd = pmd_wrprotect(pmd);
 			pmd = pmd_mkclean(pmd);
 			set_pmd_at(vma->vm_mm, address, pmdp, pmd);
-			changed = true;
+			mmu_notifier_invalidate_range(vma->vm_mm, start, end);
 unlock_pmd:
 			spin_unlock(ptl);
 #endif
@@ -691,13 +695,12 @@ static void dax_mapping_entry_mkclean(struct address_space *mapping,
 			pte = pte_wrprotect(pte);
 			pte = pte_mkclean(pte);
 			set_pte_at(vma->vm_mm, address, ptep, pte);
-			changed = true;
+			mmu_notifier_invalidate_range(vma->vm_mm, start, end);
 unlock_pte:
 			pte_unmap_unlock(ptep, ptl);
 		}
 
-		if (changed)
-			mmu_notifier_invalidate_page(vma->vm_mm, address);
+		mmu_notifier_invalidate_range_end(vma->vm_mm, start, end);
 	}
 	i_mmap_unlock_read(mapping);
 }
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 46b9ac5e8569..c1f6c95f3496 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1260,6 +1260,7 @@ int copy_page_range(struct mm_struct *dst, struct mm_struct *src,
 void unmap_mapping_range(struct address_space *mapping,
 		loff_t const holebegin, loff_t const holelen, int even_cows);
 int follow_pte_pmd(struct mm_struct *mm, unsigned long address,
+			     unsigned long *start, unsigned long *end,
 			     pte_t **ptepp, pmd_t **pmdpp, spinlock_t **ptlp);
 int follow_pfn(struct vm_area_struct *vma, unsigned long address,
 	unsigned long *pfn);
diff --git a/mm/memory.c b/mm/memory.c
index fe2fba27ded2..56e48e4593cb 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -4008,7 +4008,8 @@ int __pmd_alloc(struct mm_struct *mm, pud_t *pud, unsigned long address)
 #endif /* __PAGETABLE_PMD_FOLDED */
 
 static int __follow_pte_pmd(struct mm_struct *mm, unsigned long address,
-		pte_t **ptepp, pmd_t **pmdpp, spinlock_t **ptlp)
+			    unsigned long *start, unsigned long *end,
+			    pte_t **ptepp, pmd_t **pmdpp, spinlock_t **ptlp)
 {
 	pgd_t *pgd;
 	p4d_t *p4d;
@@ -4035,17 +4036,29 @@ static int __follow_pte_pmd(struct mm_struct *mm, unsigned long address,
 		if (!pmdpp)
 			goto out;
 
+		if (start && end) {
+			*start = address & PMD_MASK;
+			*end = *start + PMD_SIZE;
+			mmu_notifier_invalidate_range_start(mm, *start, *end);
+		}
 		*ptlp = pmd_lock(mm, pmd);
 		if (pmd_huge(*pmd)) {
 			*pmdpp = pmd;
 			return 0;
 		}
 		spin_unlock(*ptlp);
+		if (start && end)
+			mmu_notifier_invalidate_range_end(mm, *start, *end);
 	}
 
 	if (pmd_none(*pmd) || unlikely(pmd_bad(*pmd)))
 		goto out;
 
+	if (start && end) {
+		*start = address & PAGE_MASK;
+		*end = *start + PAGE_SIZE;
+		mmu_notifier_invalidate_range_start(mm, *start, *end);
+	}
 	ptep = pte_offset_map_lock(mm, pmd, address, ptlp);
 	if (!pte_present(*ptep))
 		goto unlock;
@@ -4053,6 +4066,8 @@ static int __follow_pte_pmd(struct mm_struct *mm, unsigned long address,
 	return 0;
 unlock:
 	pte_unmap_unlock(ptep, *ptlp);
+	if (start && end)
+		mmu_notifier_invalidate_range_end(mm, *start, *end);
 out:
 	return -EINVAL;
 }
@@ -4064,20 +4079,21 @@ static inline int follow_pte(struct mm_struct *mm, unsigned long address,
 
 	/* (void) is needed to make gcc happy */
 	(void) __cond_lock(*ptlp,
-			   !(res = __follow_pte_pmd(mm, address, ptepp, NULL,
-					   ptlp)));
+			   !(res = __follow_pte_pmd(mm, address, NULL, NULL,
+						    ptepp, NULL, ptlp)));
 	return res;
 }
 
 int follow_pte_pmd(struct mm_struct *mm, unsigned long address,
+			     unsigned long *start, unsigned long *end,
 			     pte_t **ptepp, pmd_t **pmdpp, spinlock_t **ptlp)
 {
 	int res;
 
 	/* (void) is needed to make gcc happy */
 	(void) __cond_lock(*ptlp,
-			   !(res = __follow_pte_pmd(mm, address, ptepp, pmdpp,
-					   ptlp)));
+			   !(res = __follow_pte_pmd(mm, address, start, end,
+						    ptepp, pmdpp, ptlp)));
 	return res;
 }
 EXPORT_SYMBOL(follow_pte_pmd);
-- 
2.13.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
