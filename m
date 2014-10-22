Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f49.google.com (mail-wg0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 567C06B006E
	for <linux-mm@kvack.org>; Wed, 22 Oct 2014 07:09:39 -0400 (EDT)
Received: by mail-wg0-f49.google.com with SMTP id x12so3410527wgg.8
        for <linux-mm@kvack.org>; Wed, 22 Oct 2014 04:09:38 -0700 (PDT)
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com. [195.75.94.110])
        by mx.google.com with ESMTPS id ic8si1416797wid.56.2014.10.22.04.09.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 22 Oct 2014 04:09:36 -0700 (PDT)
Received: from /spool/local
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dingel@linux.vnet.ibm.com>;
	Wed, 22 Oct 2014 12:09:35 +0100
Received: from b06cxnps3074.portsmouth.uk.ibm.com (d06relay09.portsmouth.uk.ibm.com [9.149.109.194])
	by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id 36DD51B08074
	for <linux-mm@kvack.org>; Wed, 22 Oct 2014 12:09:33 +0100 (BST)
Received: from d06av11.portsmouth.uk.ibm.com (d06av11.portsmouth.uk.ibm.com [9.149.37.252])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id s9MB9XKE58589312
	for <linux-mm@kvack.org>; Wed, 22 Oct 2014 11:09:33 GMT
Received: from d06av11.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av11.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s9MB9VAH011396
	for <linux-mm@kvack.org>; Wed, 22 Oct 2014 05:09:32 -0600
From: Dominik Dingel <dingel@linux.vnet.ibm.com>
Subject: [PATCH 1/4] s390/mm: recfactor global pgste updates
Date: Wed, 22 Oct 2014 13:09:27 +0200
Message-Id: <1413976170-42501-2-git-send-email-dingel@linux.vnet.ibm.com>
In-Reply-To: <1413976170-42501-1-git-send-email-dingel@linux.vnet.ibm.com>
References: <1413976170-42501-1-git-send-email-dingel@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Paolo Bonzini <pbonzini@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andy Lutomirski <luto@amacapital.net>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Bob Liu <lliubbo@gmail.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Cornelia Huck <cornelia.huck@de.ibm.com>, Gleb Natapov <gleb@kernel.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, "H. Peter Anvin" <hpa@linux.intel.com>, Hugh Dickins <hughd@google.com>, Ingo Molnar <mingo@kernel.org>, Jianyu Zhan <nasa4836@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, kvm@vger.kernel.org, linux390@de.ibm.com, linux-kernel@vger.kernel.org, linux-s390@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Peter Zijlstra <peterz@infradead.org>, Sasha Levin <sasha.levin@oracle.com>, Dominik Dingel <dingel@linux.vnet.ibm.com>

Replace the s390 specific page table walker for the pgste updates
with a call to the common code walk_page_range function.
There are now two pte modification functions, one for the reset
of the CMMA state and another one for the initialization of the
storage keys.

Signed-off-by: Dominik Dingel <dingel@linux.vnet.ibm.com>
---
 arch/s390/include/asm/pgalloc.h |   2 -
 arch/s390/include/asm/pgtable.h |   1 +
 arch/s390/kvm/kvm-s390.c        |   2 +-
 arch/s390/mm/pgtable.c          | 153 ++++++++++++++--------------------------
 4 files changed, 56 insertions(+), 102 deletions(-)

diff --git a/arch/s390/include/asm/pgalloc.h b/arch/s390/include/asm/pgalloc.h
index 9e18a61..120e126 100644
--- a/arch/s390/include/asm/pgalloc.h
+++ b/arch/s390/include/asm/pgalloc.h
@@ -22,8 +22,6 @@ unsigned long *page_table_alloc(struct mm_struct *, unsigned long);
 void page_table_free(struct mm_struct *, unsigned long *);
 void page_table_free_rcu(struct mmu_gather *, unsigned long *);
 
-void page_table_reset_pgste(struct mm_struct *, unsigned long, unsigned long,
-			    bool init_skey);
 int set_guest_storage_key(struct mm_struct *mm, unsigned long addr,
 			  unsigned long key, bool nq);
 
diff --git a/arch/s390/include/asm/pgtable.h b/arch/s390/include/asm/pgtable.h
index 5efb2fe..1e991f6a 100644
--- a/arch/s390/include/asm/pgtable.h
+++ b/arch/s390/include/asm/pgtable.h
@@ -1750,6 +1750,7 @@ extern int vmem_add_mapping(unsigned long start, unsigned long size);
 extern int vmem_remove_mapping(unsigned long start, unsigned long size);
 extern int s390_enable_sie(void);
 extern void s390_enable_skey(void);
+extern void s390_reset_cmma(struct mm_struct *mm);
 
 /*
  * No page table caches to initialise
diff --git a/arch/s390/kvm/kvm-s390.c b/arch/s390/kvm/kvm-s390.c
index 81b0e11..7a33c11 100644
--- a/arch/s390/kvm/kvm-s390.c
+++ b/arch/s390/kvm/kvm-s390.c
@@ -281,7 +281,7 @@ static int kvm_s390_mem_control(struct kvm *kvm, struct kvm_device_attr *attr)
 	case KVM_S390_VM_MEM_CLR_CMMA:
 		mutex_lock(&kvm->lock);
 		idx = srcu_read_lock(&kvm->srcu);
-		page_table_reset_pgste(kvm->arch.gmap->mm, 0, TASK_SIZE, false);
+		s390_reset_cmma(kvm->arch.gmap->mm);
 		srcu_read_unlock(&kvm->srcu, idx);
 		mutex_unlock(&kvm->lock);
 		ret = 0;
diff --git a/arch/s390/mm/pgtable.c b/arch/s390/mm/pgtable.c
index 5404a62..ab55ba8 100644
--- a/arch/s390/mm/pgtable.c
+++ b/arch/s390/mm/pgtable.c
@@ -885,99 +885,6 @@ static inline void page_table_free_pgste(unsigned long *table)
 	__free_page(page);
 }
 
-static inline unsigned long page_table_reset_pte(struct mm_struct *mm, pmd_t *pmd,
-			unsigned long addr, unsigned long end, bool init_skey)
-{
-	pte_t *start_pte, *pte;
-	spinlock_t *ptl;
-	pgste_t pgste;
-
-	start_pte = pte_offset_map_lock(mm, pmd, addr, &ptl);
-	pte = start_pte;
-	do {
-		pgste = pgste_get_lock(pte);
-		pgste_val(pgste) &= ~_PGSTE_GPS_USAGE_MASK;
-		if (init_skey) {
-			unsigned long address;
-
-			pgste_val(pgste) &= ~(PGSTE_ACC_BITS | PGSTE_FP_BIT |
-					      PGSTE_GR_BIT | PGSTE_GC_BIT);
-
-			/* skip invalid and not writable pages */
-			if (pte_val(*pte) & _PAGE_INVALID ||
-			    !(pte_val(*pte) & _PAGE_WRITE)) {
-				pgste_set_unlock(pte, pgste);
-				continue;
-			}
-
-			address = pte_val(*pte) & PAGE_MASK;
-			page_set_storage_key(address, PAGE_DEFAULT_KEY, 1);
-		}
-		pgste_set_unlock(pte, pgste);
-	} while (pte++, addr += PAGE_SIZE, addr != end);
-	pte_unmap_unlock(start_pte, ptl);
-
-	return addr;
-}
-
-static inline unsigned long page_table_reset_pmd(struct mm_struct *mm, pud_t *pud,
-			unsigned long addr, unsigned long end, bool init_skey)
-{
-	unsigned long next;
-	pmd_t *pmd;
-
-	pmd = pmd_offset(pud, addr);
-	do {
-		next = pmd_addr_end(addr, end);
-		if (pmd_none_or_clear_bad(pmd))
-			continue;
-		next = page_table_reset_pte(mm, pmd, addr, next, init_skey);
-	} while (pmd++, addr = next, addr != end);
-
-	return addr;
-}
-
-static inline unsigned long page_table_reset_pud(struct mm_struct *mm, pgd_t *pgd,
-			unsigned long addr, unsigned long end, bool init_skey)
-{
-	unsigned long next;
-	pud_t *pud;
-
-	pud = pud_offset(pgd, addr);
-	do {
-		next = pud_addr_end(addr, end);
-		if (pud_none_or_clear_bad(pud))
-			continue;
-		next = page_table_reset_pmd(mm, pud, addr, next, init_skey);
-	} while (pud++, addr = next, addr != end);
-
-	return addr;
-}
-
-void page_table_reset_pgste(struct mm_struct *mm, unsigned long start,
-			    unsigned long end, bool init_skey)
-{
-	unsigned long addr, next;
-	pgd_t *pgd;
-
-	down_write(&mm->mmap_sem);
-	if (init_skey && mm_use_skey(mm))
-		goto out_up;
-	addr = start;
-	pgd = pgd_offset(mm, addr);
-	do {
-		next = pgd_addr_end(addr, end);
-		if (pgd_none_or_clear_bad(pgd))
-			continue;
-		next = page_table_reset_pud(mm, pgd, addr, next, init_skey);
-	} while (pgd++, addr = next, addr != end);
-	if (init_skey)
-		current->mm->context.use_skey = 1;
-out_up:
-	up_write(&mm->mmap_sem);
-}
-EXPORT_SYMBOL(page_table_reset_pgste);
-
 int set_guest_storage_key(struct mm_struct *mm, unsigned long addr,
 			  unsigned long key, bool nq)
 {
@@ -1044,11 +951,6 @@ static inline unsigned long *page_table_alloc_pgste(struct mm_struct *mm,
 	return NULL;
 }
 
-void page_table_reset_pgste(struct mm_struct *mm, unsigned long start,
-			    unsigned long end, bool init_skey)
-{
-}
-
 static inline void page_table_free_pgste(unsigned long *table)
 {
 }
@@ -1400,13 +1302,66 @@ EXPORT_SYMBOL_GPL(s390_enable_sie);
  * Enable storage key handling from now on and initialize the storage
  * keys with the default key.
  */
+static int __s390_enable_skey(pte_t *pte, unsigned long addr,
+			      unsigned long next, struct mm_walk *walk)
+{
+	unsigned long ptev;
+	pgste_t pgste;
+
+	pgste = pgste_get_lock(pte);
+	/* Clear storage key */
+	pgste_val(pgste) &= ~(PGSTE_ACC_BITS | PGSTE_FP_BIT |
+			      PGSTE_GR_BIT | PGSTE_GC_BIT);
+	ptev = pte_val(*pte);
+	if (!(ptev & _PAGE_INVALID) && (ptev & _PAGE_WRITE))
+		page_set_storage_key(ptev & PAGE_MASK, PAGE_DEFAULT_KEY, 1);
+	pgste_set_unlock(pte, pgste);
+	return 0;
+}
+
 void s390_enable_skey(void)
 {
-	page_table_reset_pgste(current->mm, 0, TASK_SIZE, true);
+	struct mm_walk walk = { .pte_entry = __s390_enable_skey };
+	struct mm_struct *mm = current->mm;
+
+	down_write(&mm->mmap_sem);
+	if (mm_use_skey(mm))
+		goto out_up;
+	walk.mm = mm;
+	walk_page_range(0, TASK_SIZE, &walk);
+	mm->context.use_skey = 1;
+
+out_up:
+	up_write(&mm->mmap_sem);
 }
 EXPORT_SYMBOL_GPL(s390_enable_skey);
 
 /*
+ * Reset CMMA state, make all pages stable again.
+ */
+static int __s390_reset_cmma(pte_t *pte, unsigned long addr,
+			     unsigned long next, struct mm_walk *walk)
+{
+	pgste_t pgste;
+
+	pgste = pgste_get_lock(pte);
+	pgste_val(pgste) &= ~_PGSTE_GPS_USAGE_MASK;
+	pgste_set_unlock(pte, pgste);
+	return 0;
+}
+
+void s390_reset_cmma(struct mm_struct *mm)
+{
+	struct mm_walk walk = { .pte_entry = __s390_reset_cmma };
+
+	down_write(&mm->mmap_sem);
+	walk.mm = mm;
+	walk_page_range(0, TASK_SIZE, &walk);
+	up_write(&mm->mmap_sem);
+}
+EXPORT_SYMBOL_GPL(s390_reset_cmma);
+
+/*
  * Test and reset if a guest page is dirty
  */
 bool gmap_test_and_clear_dirty(unsigned long address, struct gmap *gmap)
-- 
1.8.5.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
