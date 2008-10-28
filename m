Message-ID: <4906CBEA.8040605@goop.org>
Date: Tue, 28 Oct 2008 19:23:06 +1100
From: Jeremy Fitzhardinge <jeremy@goop.org>
MIME-Version: 1.0
Subject: [PATCH 2/2] xen: make sure stray alias mappings are gone before pinning
References: <49010D41.1080305@goop.org> <200810281619.10388.nickpiggin@yahoo.com.au>
In-Reply-To: <200810281619.10388.nickpiggin@yahoo.com.au>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

Xen requires that all mappings of pagetable pages are read-only, so
that they can't be updated illegally.  As a result, if a page is being
turned into a pagetable page, we need to make sure all its mappings
are RO.

If the page had been used for ioremap or vmalloc, it may still have
left over mappings as a result of not having been lazily unmapped.
This change makes sure we explicitly mop them all up before pinning
the page.

Unlike aliases created by kmap, the there can be vmalloc aliases even
for non-high pages, so we must do the flush unconditionally.

Signed-off-by: Jeremy Fitzhardinge <jeremy.fitzhardinge@citrix.com>
---
 arch/x86/xen/enlighten.c |    5 +++--
 arch/x86/xen/mmu.c       |    9 ++++++---
 2 files changed, 9 insertions(+), 5 deletions(-)

===================================================================
--- a/arch/x86/xen/enlighten.c
+++ b/arch/x86/xen/enlighten.c
@@ -863,15 +863,16 @@
 	if (PagePinned(virt_to_page(mm->pgd))) {
 		SetPagePinned(page);
 
+		vm_unmap_aliases();
 		if (!PageHighMem(page)) {
 			make_lowmem_page_readonly(__va(PFN_PHYS((unsigned long)pfn)));
 			if (level == PT_PTE && USE_SPLIT_PTLOCKS)
 				pin_pagetable_pfn(MMUEXT_PIN_L1_TABLE, pfn);
-		} else
+		} else {
 			/* make sure there are no stray mappings of
 			   this page */
 			kmap_flush_unused();
-			vm_unmap_aliases();
+		}
 	}
 }
 
===================================================================
--- a/arch/x86/xen/mmu.c
+++ b/arch/x86/xen/mmu.c
@@ -840,13 +840,16 @@
    read-only, and can be pinned. */
 static void __xen_pgd_pin(struct mm_struct *mm, pgd_t *pgd)
 {
+	vm_unmap_aliases();
+
 	xen_mc_batch();
 
-	if (xen_pgd_walk(mm, xen_pin_page, USER_LIMIT)) {
-		/* re-enable interrupts for kmap_flush_unused */
+	 if (xen_pgd_walk(mm, xen_pin_page, USER_LIMIT)) {
+		/* re-enable interrupts for flushing */
 		xen_mc_issue(0);
+
 		kmap_flush_unused();
-		vm_unmap_aliases();
+
 		xen_mc_batch();
 	}
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
