Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id 0B7676B0044
	for <linux-mm@kvack.org>; Thu, 26 Jul 2012 11:47:56 -0400 (EDT)
Received: from /spool/local
	by e06smtp16.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <schwidefsky@de.ibm.com>;
	Thu, 26 Jul 2012 16:47:55 +0100
Received: from d06av06.portsmouth.uk.ibm.com (d06av06.portsmouth.uk.ibm.com [9.149.37.217])
	by d06nrmr1806.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q6QFlrlL2252956
	for <linux-mm@kvack.org>; Thu, 26 Jul 2012 16:47:53 +0100
Received: from d06av06.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av06.portsmouth.uk.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q6QFlqh0002766
	for <linux-mm@kvack.org>; Thu, 26 Jul 2012 09:47:53 -0600
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: [PATCH 1/2] add mm argument to lazy mmu mode hooks
Date: Thu, 26 Jul 2012 17:47:13 +0200
Message-Id: <1343317634-13197-2-git-send-email-schwidefsky@de.ibm.com>
In-Reply-To: <1343317634-13197-1-git-send-email-schwidefsky@de.ibm.com>
References: <1343317634-13197-1-git-send-email-schwidefsky@de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arch@vger.kernel.org, linux-mm@kvack.org, Zachary Amsden <zach@vmware.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Chris Metcalf <cmetcalf@tilera.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>

To enable lazy TLB flush schemes with a scope limited to a single
mm_struct add the mm pointer as argument to the three lazy mmu mode
hooks.

Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
---
 arch/powerpc/include/asm/tlbflush.h |    6 +++---
 arch/powerpc/mm/subpage-prot.c      |    4 ++--
 arch/powerpc/mm/tlb_hash64.c        |    4 ++--
 arch/tile/mm/fault.c                |    2 +-
 arch/tile/mm/highmem.c              |    4 ++--
 arch/x86/include/asm/paravirt.h     |    6 +++---
 arch/x86/kernel/paravirt.c          |   10 +++++-----
 arch/x86/mm/highmem_32.c            |    4 ++--
 arch/x86/mm/iomap_32.c              |    2 +-
 include/asm-generic/pgtable.h       |    6 +++---
 mm/memory.c                         |   16 ++++++++--------
 mm/mprotect.c                       |    4 ++--
 mm/mremap.c                         |    4 ++--
 13 files changed, 36 insertions(+), 36 deletions(-)

diff --git a/arch/powerpc/include/asm/tlbflush.h b/arch/powerpc/include/asm/tlbflush.h
index 81143fc..7851e0c1 100644
--- a/arch/powerpc/include/asm/tlbflush.h
+++ b/arch/powerpc/include/asm/tlbflush.h
@@ -108,14 +108,14 @@ extern void hpte_need_flush(struct mm_struct *mm, unsigned long addr,
 
 #define __HAVE_ARCH_ENTER_LAZY_MMU_MODE
 
-static inline void arch_enter_lazy_mmu_mode(void)
+static inline void arch_enter_lazy_mmu_mode(struct mm_struct *mm)
 {
 	struct ppc64_tlb_batch *batch = &__get_cpu_var(ppc64_tlb_batch);
 
 	batch->active = 1;
 }
 
-static inline void arch_leave_lazy_mmu_mode(void)
+static inline void arch_leave_lazy_mmu_mode(struct mm_struct *mm)
 {
 	struct ppc64_tlb_batch *batch = &__get_cpu_var(ppc64_tlb_batch);
 
@@ -124,7 +124,7 @@ static inline void arch_leave_lazy_mmu_mode(void)
 	batch->active = 0;
 }
 
-#define arch_flush_lazy_mmu_mode()      do {} while (0)
+#define arch_flush_lazy_mmu_mode(mm)	  do {} while (0)
 
 
 extern void flush_hash_page(unsigned long va, real_pte_t pte, int psize,
diff --git a/arch/powerpc/mm/subpage-prot.c b/arch/powerpc/mm/subpage-prot.c
index e4f8f1f..bf95185 100644
--- a/arch/powerpc/mm/subpage-prot.c
+++ b/arch/powerpc/mm/subpage-prot.c
@@ -76,13 +76,13 @@ static void hpte_flush_range(struct mm_struct *mm, unsigned long addr,
 	if (pmd_none(*pmd))
 		return;
 	pte = pte_offset_map_lock(mm, pmd, addr, &ptl);
-	arch_enter_lazy_mmu_mode();
+	arch_enter_lazy_mmu_mode(mm);
 	for (; npages > 0; --npages) {
 		pte_update(mm, addr, pte, 0, 0);
 		addr += PAGE_SIZE;
 		++pte;
 	}
-	arch_leave_lazy_mmu_mode();
+	arch_leave_lazy_mmu_mode(mm);
 	pte_unmap_unlock(pte - 1, ptl);
 }
 
diff --git a/arch/powerpc/mm/tlb_hash64.c b/arch/powerpc/mm/tlb_hash64.c
index 31f1820..73fd065 100644
--- a/arch/powerpc/mm/tlb_hash64.c
+++ b/arch/powerpc/mm/tlb_hash64.c
@@ -205,7 +205,7 @@ void __flush_hash_table_range(struct mm_struct *mm, unsigned long start,
 	 * way to do things but is fine for our needs here.
 	 */
 	local_irq_save(flags);
-	arch_enter_lazy_mmu_mode();
+	arch_enter_lazy_mmu_mode(mm);
 	for (; start < end; start += PAGE_SIZE) {
 		pte_t *ptep = find_linux_pte(mm->pgd, start);
 		unsigned long pte;
@@ -217,7 +217,7 @@ void __flush_hash_table_range(struct mm_struct *mm, unsigned long start,
 			continue;
 		hpte_need_flush(mm, start, ptep, pte, 0);
 	}
-	arch_leave_lazy_mmu_mode();
+	arch_leave_lazy_mmu_mode(mm);
 	local_irq_restore(flags);
 }
 
diff --git a/arch/tile/mm/fault.c b/arch/tile/mm/fault.c
index 84ce7ab..0d78f93 100644
--- a/arch/tile/mm/fault.c
+++ b/arch/tile/mm/fault.c
@@ -123,7 +123,7 @@ static inline pmd_t *vmalloc_sync_one(pgd_t *pgd, unsigned long address)
 		return NULL;
 	if (!pmd_present(*pmd)) {
 		set_pmd(pmd, *pmd_k);
-		arch_flush_lazy_mmu_mode();
+		arch_flush_lazy_mmu_mode(&init_mm);
 	} else
 		BUG_ON(pmd_ptfn(*pmd) != pmd_ptfn(*pmd_k));
 	return pmd_k;
diff --git a/arch/tile/mm/highmem.c b/arch/tile/mm/highmem.c
index ef8e5a6..85b061e 100644
--- a/arch/tile/mm/highmem.c
+++ b/arch/tile/mm/highmem.c
@@ -114,7 +114,7 @@ static void kmap_atomic_register(struct page *page, enum km_type type,
 
 	list_add(&amp->list, &amp_list);
 	set_pte(ptep, pteval);
-	arch_flush_lazy_mmu_mode();
+	arch_flush_lazy_mmu_mode(&init_mm);
 
 	spin_unlock(&amp_lock);
 	homecache_kpte_unlock(flags);
@@ -259,7 +259,7 @@ void __kunmap_atomic(void *kvaddr)
 		BUG_ON(vaddr >= (unsigned long)high_memory);
 	}
 
-	arch_flush_lazy_mmu_mode();
+	arch_flush_lazy_mmu_mode(&init_mm);
 	pagefault_enable();
 }
 EXPORT_SYMBOL(__kunmap_atomic);
diff --git a/arch/x86/include/asm/paravirt.h b/arch/x86/include/asm/paravirt.h
index 0b47ddb..b097945 100644
--- a/arch/x86/include/asm/paravirt.h
+++ b/arch/x86/include/asm/paravirt.h
@@ -694,17 +694,17 @@ static inline void arch_end_context_switch(struct task_struct *next)
 }
 
 #define  __HAVE_ARCH_ENTER_LAZY_MMU_MODE
-static inline void arch_enter_lazy_mmu_mode(void)
+static inline void arch_enter_lazy_mmu_mode(struct mm_struct *mm)
 {
 	PVOP_VCALL0(pv_mmu_ops.lazy_mode.enter);
 }
 
-static inline void arch_leave_lazy_mmu_mode(void)
+static inline void arch_leave_lazy_mmu_mode(struct mm_struct *mm)
 {
 	PVOP_VCALL0(pv_mmu_ops.lazy_mode.leave);
 }
 
-void arch_flush_lazy_mmu_mode(void);
+void arch_flush_lazy_mmu_mode(struct mm_struct *mm);
 
 static inline void __set_fixmap(unsigned /* enum fixed_addresses */ idx,
 				phys_addr_t phys, pgprot_t flags)
diff --git a/arch/x86/kernel/paravirt.c b/arch/x86/kernel/paravirt.c
index 17fff18..62d9b94 100644
--- a/arch/x86/kernel/paravirt.c
+++ b/arch/x86/kernel/paravirt.c
@@ -268,7 +268,7 @@ void paravirt_start_context_switch(struct task_struct *prev)
 	BUG_ON(preemptible());
 
 	if (this_cpu_read(paravirt_lazy_mode) == PARAVIRT_LAZY_MMU) {
-		arch_leave_lazy_mmu_mode();
+		arch_leave_lazy_mmu_mode(prev->mm);
 		set_ti_thread_flag(task_thread_info(prev), TIF_LAZY_MMU_UPDATES);
 	}
 	enter_lazy(PARAVIRT_LAZY_CPU);
@@ -281,7 +281,7 @@ void paravirt_end_context_switch(struct task_struct *next)
 	leave_lazy(PARAVIRT_LAZY_CPU);
 
 	if (test_and_clear_ti_thread_flag(task_thread_info(next), TIF_LAZY_MMU_UPDATES))
-		arch_enter_lazy_mmu_mode();
+		arch_enter_lazy_mmu_mode(next->mm);
 }
 
 enum paravirt_lazy_mode paravirt_get_lazy_mode(void)
@@ -292,13 +292,13 @@ enum paravirt_lazy_mode paravirt_get_lazy_mode(void)
 	return this_cpu_read(paravirt_lazy_mode);
 }
 
-void arch_flush_lazy_mmu_mode(void)
+void arch_flush_lazy_mmu_mode(struct mm_struct *mm)
 {
 	preempt_disable();
 
 	if (paravirt_get_lazy_mode() == PARAVIRT_LAZY_MMU) {
-		arch_leave_lazy_mmu_mode();
-		arch_enter_lazy_mmu_mode();
+		arch_leave_lazy_mmu_mode(mm);
+		arch_enter_lazy_mmu_mode(mm);
 	}
 
 	preempt_enable();
diff --git a/arch/x86/mm/highmem_32.c b/arch/x86/mm/highmem_32.c
index 6f31ee5..318ee33 100644
--- a/arch/x86/mm/highmem_32.c
+++ b/arch/x86/mm/highmem_32.c
@@ -45,7 +45,7 @@ void *kmap_atomic_prot(struct page *page, pgprot_t prot)
 	vaddr = __fix_to_virt(FIX_KMAP_BEGIN + idx);
 	BUG_ON(!pte_none(*(kmap_pte-idx)));
 	set_pte(kmap_pte-idx, mk_pte(page, prot));
-	arch_flush_lazy_mmu_mode();
+	arch_flush_lazy_mmu_mode(&init_mm);
 
 	return (void *)vaddr;
 }
@@ -89,7 +89,7 @@ void __kunmap_atomic(void *kvaddr)
 		 */
 		kpte_clear_flush(kmap_pte-idx, vaddr);
 		kmap_atomic_idx_pop();
-		arch_flush_lazy_mmu_mode();
+		arch_flush_lazy_mmu_mode(&init_mm);
 	}
 #ifdef CONFIG_DEBUG_HIGHMEM
 	else {
diff --git a/arch/x86/mm/iomap_32.c b/arch/x86/mm/iomap_32.c
index 7b179b4..d8a1556 100644
--- a/arch/x86/mm/iomap_32.c
+++ b/arch/x86/mm/iomap_32.c
@@ -65,7 +65,7 @@ void *kmap_atomic_prot_pfn(unsigned long pfn, pgprot_t prot)
 	idx = type + KM_TYPE_NR * smp_processor_id();
 	vaddr = __fix_to_virt(FIX_KMAP_BEGIN + idx);
 	set_pte(kmap_pte - idx, pfn_pte(pfn, prot));
-	arch_flush_lazy_mmu_mode();
+	arch_flush_lazy_mmu_mode(&init_mm);
 
 	return (void *)vaddr;
 }
diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
index ff4947b..2efd6c7 100644
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -359,9 +359,9 @@ static inline void ptep_modify_prot_commit(struct mm_struct *mm,
  * it must synchronize the delayed page table writes properly on other CPUs.
  */
 #ifndef __HAVE_ARCH_ENTER_LAZY_MMU_MODE
-#define arch_enter_lazy_mmu_mode()	do {} while (0)
-#define arch_leave_lazy_mmu_mode()	do {} while (0)
-#define arch_flush_lazy_mmu_mode()	do {} while (0)
+#define arch_enter_lazy_mmu_mode(mm)	do {} while (0)
+#define arch_leave_lazy_mmu_mode(mm)	do {} while (0)
+#define arch_flush_lazy_mmu_mode(mm)	do {} while (0)
 #endif
 
 /*
diff --git a/mm/memory.c b/mm/memory.c
index 2466d12..1c48c22 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -932,7 +932,7 @@ again:
 	spin_lock_nested(src_ptl, SINGLE_DEPTH_NESTING);
 	orig_src_pte = src_pte;
 	orig_dst_pte = dst_pte;
-	arch_enter_lazy_mmu_mode();
+	arch_enter_lazy_mmu_mode(src_mm);
 
 	do {
 		/*
@@ -956,7 +956,7 @@ again:
 		progress += 8;
 	} while (dst_pte++, src_pte++, addr += PAGE_SIZE, addr != end);
 
-	arch_leave_lazy_mmu_mode();
+	arch_leave_lazy_mmu_mode(src_mm);
 	spin_unlock(src_ptl);
 	pte_unmap(orig_src_pte);
 	add_mm_rss_vec(dst_mm, rss);
@@ -1106,7 +1106,7 @@ again:
 	init_rss_vec(rss);
 	start_pte = pte_offset_map_lock(mm, pmd, addr, &ptl);
 	pte = start_pte;
-	arch_enter_lazy_mmu_mode();
+	arch_enter_lazy_mmu_mode(mm);
 	do {
 		pte_t ptent = *pte;
 		if (pte_none(ptent)) {
@@ -1194,7 +1194,7 @@ again:
 	} while (pte++, addr += PAGE_SIZE, addr != end);
 
 	add_mm_rss_vec(mm, rss);
-	arch_leave_lazy_mmu_mode();
+	arch_leave_lazy_mmu_mode(mm);
 	pte_unmap_unlock(start_pte, ptl);
 
 	/*
@@ -2202,13 +2202,13 @@ static int remap_pte_range(struct mm_struct *mm, pmd_t *pmd,
 	pte = pte_alloc_map_lock(mm, pmd, addr, &ptl);
 	if (!pte)
 		return -ENOMEM;
-	arch_enter_lazy_mmu_mode();
+	arch_enter_lazy_mmu_mode(mm);
 	do {
 		BUG_ON(!pte_none(*pte));
 		set_pte_at(mm, addr, pte, pte_mkspecial(pfn_pte(pfn, prot)));
 		pfn++;
 	} while (pte++, addr += PAGE_SIZE, addr != end);
-	arch_leave_lazy_mmu_mode();
+	arch_leave_lazy_mmu_mode(mm);
 	pte_unmap_unlock(pte - 1, ptl);
 	return 0;
 }
@@ -2346,7 +2346,7 @@ static int apply_to_pte_range(struct mm_struct *mm, pmd_t *pmd,
 
 	BUG_ON(pmd_huge(*pmd));
 
-	arch_enter_lazy_mmu_mode();
+	arch_enter_lazy_mmu_mode(mm);
 
 	token = pmd_pgtable(*pmd);
 
@@ -2356,7 +2356,7 @@ static int apply_to_pte_range(struct mm_struct *mm, pmd_t *pmd,
 			break;
 	} while (addr += PAGE_SIZE, addr != end);
 
-	arch_leave_lazy_mmu_mode();
+	arch_leave_lazy_mmu_mode(mm);
 
 	if (mm != &init_mm)
 		pte_unmap_unlock(pte-1, ptl);
diff --git a/mm/mprotect.c b/mm/mprotect.c
index a409926..df8688c 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -43,7 +43,7 @@ static void change_pte_range(struct mm_struct *mm, pmd_t *pmd,
 	spinlock_t *ptl;
 
 	pte = pte_offset_map_lock(mm, pmd, addr, &ptl);
-	arch_enter_lazy_mmu_mode();
+	arch_enter_lazy_mmu_mode(mm);
 	do {
 		oldpte = *pte;
 		if (pte_present(oldpte)) {
@@ -74,7 +74,7 @@ static void change_pte_range(struct mm_struct *mm, pmd_t *pmd,
 			}
 		}
 	} while (pte++, addr += PAGE_SIZE, addr != end);
-	arch_leave_lazy_mmu_mode();
+	arch_leave_lazy_mmu_mode(mm);
 	pte_unmap_unlock(pte - 1, ptl);
 }
 
diff --git a/mm/mremap.c b/mm/mremap.c
index 21fed20..5241520 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -98,7 +98,7 @@ static void move_ptes(struct vm_area_struct *vma, pmd_t *old_pmd,
 	new_ptl = pte_lockptr(mm, new_pmd);
 	if (new_ptl != old_ptl)
 		spin_lock_nested(new_ptl, SINGLE_DEPTH_NESTING);
-	arch_enter_lazy_mmu_mode();
+	arch_enter_lazy_mmu_mode(mm);
 
 	for (; old_addr < old_end; old_pte++, old_addr += PAGE_SIZE,
 				   new_pte++, new_addr += PAGE_SIZE) {
@@ -109,7 +109,7 @@ static void move_ptes(struct vm_area_struct *vma, pmd_t *old_pmd,
 		set_pte_at(mm, new_addr, new_pte, pte);
 	}
 
-	arch_leave_lazy_mmu_mode();
+	arch_leave_lazy_mmu_mode(mm);
 	if (new_ptl != old_ptl)
 		spin_unlock(new_ptl);
 	pte_unmap(new_pte - 1);
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
