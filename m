Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id 8496D6B0072
	for <linux-mm@kvack.org>; Fri, 16 Nov 2012 04:54:12 -0500 (EST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 1/2] thp: fix update_mmu_cache_pmd() calls
Date: Fri, 16 Nov 2012 11:55:15 +0200
Message-Id: <1353059717-9850-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, Andrea Arcangeli <aarcange@redhat.com>, Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org

From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

update_mmu_cache_pmd() takes pointer to pmd_t as third, not pmd_t.

mm/huge_memory.c: In function 'do_huge_pmd_numa_page':
mm/huge_memory.c:825:2: error: incompatible type for argument 3 of 'update_mmu_cache_pmd'
In file included from include/linux/mm.h:44:0,
                 from mm/huge_memory.c:8:
arch/mips/include/asm/pgtable.h:385:20: note: expected 'struct pmd_t *' but argument is of type 'pmd_t'
mm/huge_memory.c:895:2: error: incompatible type for argument 3 of 'update_mmu_cache_pmd'
In file included from include/linux/mm.h:44:0,
                 from mm/huge_memory.c:8:
arch/mips/include/asm/pgtable.h:385:20: note: expected 'struct pmd_t *' but argument is of type 'pmd_t'

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/huge_memory.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 4489e16..2401a16 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -886,7 +886,7 @@ fixup:
 	/* change back to regular protection */
 	entry = pmd_modify(entry, vma->vm_page_prot);
 	set_pmd_at(mm, haddr, pmd, entry);
-	update_mmu_cache_pmd(vma, address, entry);
+	update_mmu_cache_pmd(vma, address, &entry);
 
 unlock:
 	spin_unlock(&mm->page_table_lock);
@@ -956,7 +956,7 @@ migrate:
 	page_add_new_anon_rmap(new_page, vma, haddr);
 
 	set_pmd_at(mm, haddr, pmd, entry);
-	update_mmu_cache_pmd(vma, address, entry);
+	update_mmu_cache_pmd(vma, address, &entry);
 	page_remove_rmap(page);
 	spin_unlock(&mm->page_table_lock);
 
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
