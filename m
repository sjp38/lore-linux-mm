Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8A0FF6B04B0
	for <linux-mm@kvack.org>; Thu, 27 Jul 2017 14:50:10 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id u199so157685026pgb.13
        for <linux-mm@kvack.org>; Thu, 27 Jul 2017 11:50:10 -0700 (PDT)
Received: from EX13-EDG-OU-001.vmware.com (ex13-edg-ou-001.vmware.com. [208.91.0.189])
        by mx.google.com with ESMTPS id m3si8751825pgc.963.2017.07.27.11.50.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 27 Jul 2017 11:50:09 -0700 (PDT)
From: Nadav Amit <namit@vmware.com>
Subject: [PATCH v3 2/2] mm: migrate: fix barriers around tlb_flush_pending
Date: Thu, 27 Jul 2017 04:40:15 -0700
Message-ID: <20170727114015.3452-3-namit@vmware.com>
In-Reply-To: <20170727114015.3452-1-namit@vmware.com>
References: <20170727114015.3452-1-namit@vmware.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: sergey.senozhatsky@gmail.com, minchan@kernel.org, nadav.amit@gmail.com, mgorman@suse.de, riel@redhat.com, luto@kernel.org, Nadav Amit <namit@vmware.com>

Reading tlb_flush_pending while the page-table lock is taken does not
require a barrier, since the lock/unlock already acts as a barrier.
Removing the barrier in mm_tlb_flush_pending() to address this issue.

However, migrate_misplaced_transhuge_page() calls mm_tlb_flush_pending()
while the page-table lock is already released, which may present a
problem on architectures with weak memory model (PPC). To deal with this
case, a new parameter is added to mm_tlb_flush_pending() to indicate
if it is read without the page-table lock taken, and calling
smp_mb__after_unlock_lock() in this case.

Signed-off-by: Nadav Amit <namit@vmware.com>
---
 arch/arm/include/asm/pgtable.h   |  3 ++-
 arch/arm64/include/asm/pgtable.h |  3 ++-
 arch/x86/include/asm/pgtable.h   |  2 +-
 include/linux/mm_types.h         | 31 +++++++++++++++++++++++--------
 mm/migrate.c                     |  2 +-
 5 files changed, 29 insertions(+), 12 deletions(-)

diff --git a/arch/arm/include/asm/pgtable.h b/arch/arm/include/asm/pgtable.h
index 1c462381c225..2e0608a8049d 100644
--- a/arch/arm/include/asm/pgtable.h
+++ b/arch/arm/include/asm/pgtable.h
@@ -223,7 +223,8 @@ static inline pte_t *pmd_page_vaddr(pmd_t pmd)
 #define pte_none(pte)		(!pte_val(pte))
 #define pte_present(pte)	(pte_isset((pte), L_PTE_PRESENT))
 #define pte_valid(pte)		(pte_isset((pte), L_PTE_VALID))
-#define pte_accessible(mm, pte)	(mm_tlb_flush_pending(mm) ? pte_present(pte) : pte_valid(pte))
+#define pte_accessible(mm, pte)	(mm_tlb_flush_pending(mm, true) ? \
+					pte_present(pte) : pte_valid(pte))
 #define pte_write(pte)		(pte_isclear((pte), L_PTE_RDONLY))
 #define pte_dirty(pte)		(pte_isset((pte), L_PTE_DIRTY))
 #define pte_young(pte)		(pte_isset((pte), L_PTE_YOUNG))
diff --git a/arch/arm64/include/asm/pgtable.h b/arch/arm64/include/asm/pgtable.h
index c213fdbd056c..47f934d378ca 100644
--- a/arch/arm64/include/asm/pgtable.h
+++ b/arch/arm64/include/asm/pgtable.h
@@ -108,7 +108,8 @@ extern unsigned long empty_zero_page[PAGE_SIZE / sizeof(unsigned long)];
  * remapped as PROT_NONE but are yet to be flushed from the TLB.
  */
 #define pte_accessible(mm, pte)	\
-	(mm_tlb_flush_pending(mm) ? pte_present(pte) : pte_valid_young(pte))
+	(mm_tlb_flush_pending(mm, true) ? pte_present(pte) : \
+					  pte_valid_young(pte))
 
 static inline pte_t clear_pte_bit(pte_t pte, pgprot_t prot)
 {
diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index f5af95a0c6b8..da16793203dd 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -642,7 +642,7 @@ static inline bool pte_accessible(struct mm_struct *mm, pte_t a)
 		return true;
 
 	if ((pte_flags(a) & _PAGE_PROTNONE) &&
-			mm_tlb_flush_pending(mm))
+			mm_tlb_flush_pending(mm, true))
 		return true;
 
 	return false;
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 36f4ec589544..57ab8061a2c0 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -522,12 +522,21 @@ static inline cpumask_t *mm_cpumask(struct mm_struct *mm)
 /*
  * Memory barriers to keep this state in sync are graciously provided by
  * the page table locks, outside of which no page table modifications happen.
- * The barriers below prevent the compiler from re-ordering the instructions
- * around the memory barriers that are already present in the code.
+ * The barriers are used to ensure the order between tlb_flush_pending updates,
+ * which happen while the lock is not taken, and the PTE updates, which happen
+ * while the lock is taken, are serialized.
  */
-static inline bool mm_tlb_flush_pending(struct mm_struct *mm)
+static inline bool mm_tlb_flush_pending(struct mm_struct *mm, bool pt_locked)
 {
-	barrier();
+	/*
+	 * mm_tlb_flush_pending() is safe if it is executed while the page-table
+	 * lock is taken. But if the lock was already released, there does not
+	 * seem to be a guarantee that a memory barrier. A memory barrier is
+	 * therefore needed on architectures with weak memory models.
+	 */
+	if (!pt_locked)
+		smp_mb__after_unlock_lock();
+
 	return atomic_read(&mm->tlb_flush_pending) > 0;
 }
 static inline void set_tlb_flush_pending(struct mm_struct *mm)
@@ -535,19 +544,25 @@ static inline void set_tlb_flush_pending(struct mm_struct *mm)
 	atomic_inc(&mm->tlb_flush_pending);
 
 	/*
-	 * Guarantee that the tlb_flush_pending store does not leak into the
+	 * Guarantee that the tlb_flush_pending increase does not leak into the
 	 * critical section updating the page tables
 	 */
 	smp_mb__before_spinlock();
 }
-/* Clearing is done after a TLB flush, which also provides a barrier. */
+
 static inline void clear_tlb_flush_pending(struct mm_struct *mm)
 {
-	barrier();
+	/*
+	 * Guarantee that the tlb_flush_pending does not not leak into the
+	 * critical section, since we must order the PTE change and changes to
+	 * the pending TLB flush indication. We could have relied on TLB flush
+	 * as a memory barrier, but this behavior is not clearly documented.
+	 */
+	smp_mb__before_atomic();
 	atomic_dec(&mm->tlb_flush_pending);
 }
 #else
-static inline bool mm_tlb_flush_pending(struct mm_struct *mm)
+static inline bool mm_tlb_flush_pending(struct mm_struct *mm, bool pt_locked)
 {
 	return false;
 }
diff --git a/mm/migrate.c b/mm/migrate.c
index 89a0a1707f4c..169c3165be41 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1939,7 +1939,7 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 	 * We are not sure a pending tlb flush here is for a huge page
 	 * mapping or not. Hence use the tlb range variant
 	 */
-	if (mm_tlb_flush_pending(mm))
+	if (mm_tlb_flush_pending(mm, false))
 		flush_tlb_range(vma, mmun_start, mmun_end);
 
 	/* Prepare a page as a migration target */
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
