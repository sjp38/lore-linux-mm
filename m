Message-ID: <491C61B5.7020004@goop.org>
Date: Thu, 13 Nov 2008 09:19:49 -0800
From: Jeremy Fitzhardinge <jeremy@goop.org>
MIME-Version: 1.0
Subject: [PATCH 2/2] mm/apply_to_range: call pte function with lazy updates
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, "Pallipadi, Venkatesh" <venkatesh.pallipadi@intel.com>
List-ID: <linux-mm.kvack.org>

Make the pte-level function in apply_to_range be called in lazy mmu
mode, so that any pagetable modifications can be batched.

Signed-off-by: Jeremy Fitzhardinge <jeremy.fitzhardinge@citrix.com>
---
 mm/memory.c |    4 ++++
 1 file changed, 4 insertions(+)

===================================================================
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1545,6 +1545,8 @@
 
 	BUG_ON(pmd_huge(*pmd));
 
+	arch_enter_lazy_mmu_mode();
+
 	token = pmd_pgtable(*pmd);
 
 	do {
@@ -1552,6 +1554,8 @@
 		if (err)
 			break;
 	} while (pte++, addr += PAGE_SIZE, addr != end);
+
+	arch_leave_lazy_mmu_mode();
 
 	if (mm != &init_mm)
 		pte_unmap_unlock(pte-1, ptl);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
