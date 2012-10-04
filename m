Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 7B7146B0146
	for <linux-mm@kvack.org>; Thu,  4 Oct 2012 15:47:40 -0400 (EDT)
Date: Thu, 04 Oct 2012 15:47:38 -0400 (EDT)
Message-Id: <20121004.154738.461031090401264236.davem@davemloft.net>
Subject: [PATCH v2 5/7] mm: Add and use update_mmu_cache_pmd() in
 transparent huge page code.
From: David Miller <davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, akpm@linux-foundation.org, aarcange@redhat.com, hannes@cmpxchg.org


The transparent huge page code passes a PMD pointer in as the third
argument of update_mmu_cache(), which expects a PTE pointer.

This never got noticed because X86 implements update_mmu_cache() as a
macro and thus we don't get any type checking, and X86 is the only
architecture which supports transparent huge pages currently.

Before oter architectures can support transparent huge pages properly
we need to add a new interface which will take a PMD pointer as the
third argument rather than a PTE pointer.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 arch/x86/include/asm/pgtable_32.h |    1 +
 arch/x86/include/asm/pgtable_64.h |    1 +
 mm/huge_memory.c                  |    6 +++---
 3 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/arch/x86/include/asm/pgtable_32.h b/arch/x86/include/asm/pgtable_32.h
index 0c92113..8faa215 100644
--- a/arch/x86/include/asm/pgtable_32.h
+++ b/arch/x86/include/asm/pgtable_32.h
@@ -71,6 +71,7 @@ do {						\
  * tables contain all the necessary information.
  */
 #define update_mmu_cache(vma, address, ptep) do { } while (0)
+#define update_mmu_cache_pmd(vma, address, pmd) do { } while (0)
 
 #endif /* !__ASSEMBLY__ */
 
diff --git a/arch/x86/include/asm/pgtable_64.h b/arch/x86/include/asm/pgtable_64.h
index 8251be0..47356f9 100644
--- a/arch/x86/include/asm/pgtable_64.h
+++ b/arch/x86/include/asm/pgtable_64.h
@@ -143,6 +143,7 @@ static inline int pgd_large(pgd_t pgd) { return 0; }
 #define pte_unmap(pte) ((void)(pte))/* NOP */
 
 #define update_mmu_cache(vma, address, ptep) do { } while (0)
+#define update_mmu_cache_pmd(vma, address, pmd) do { } while (0)
 
 /* Encode and de-code a swap entry */
 #if _PAGE_BIT_FILE < _PAGE_BIT_PROTNONE
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index cbc83a1..20eeb2b 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -889,7 +889,7 @@ int do_huge_pmd_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		entry = pmd_mkyoung(orig_pmd);
 		entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
 		if (pmdp_set_access_flags(vma, haddr, pmd, entry,  1))
-			update_mmu_cache(vma, address, pmd);
+			update_mmu_cache_pmd(vma, address, pmd);
 		ret |= VM_FAULT_WRITE;
 		goto out_unlock;
 	}
@@ -941,7 +941,7 @@ int do_huge_pmd_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		pmdp_clear_flush_notify(vma, haddr, pmd);
 		page_add_new_anon_rmap(new_page, vma, haddr);
 		set_pmd_at(mm, haddr, pmd, entry);
-		update_mmu_cache(vma, address, pmd);
+		update_mmu_cache_pmd(vma, address, pmd);
 		page_remove_rmap(page);
 		put_page(page);
 		ret |= VM_FAULT_WRITE;
@@ -2028,7 +2028,7 @@ static void collapse_huge_page(struct mm_struct *mm,
 	BUG_ON(!pmd_none(*pmd));
 	page_add_new_anon_rmap(new_page, vma, address);
 	set_pmd_at(mm, address, pmd, _pmd);
-	update_mmu_cache(vma, address, pmd);
+	update_mmu_cache_pmd(vma, address, pmd);
 	pgtable_trans_huge_deposit(mm, pgtable);
 	spin_unlock(&mm->page_table_lock);
 
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
