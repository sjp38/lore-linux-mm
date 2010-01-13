From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 8/8] hwpoison: prevent /dev/kcore from accessing hwpoison pages
Date: Wed, 13 Jan 2010 21:53:13 +0800
Message-ID: <20100113135958.291404947@intel.com>
References: <20100113135305.013124116@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 5C8616B0071
	for <linux-mm@kvack.org>; Wed, 13 Jan 2010 09:00:35 -0500 (EST)
Content-Disposition: inline; filename=hwpoison-kcore.patch
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Wu Fengguang <fengguang.wu@intel.com>, LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <andi@firstfloor.org>, Pekka Enberg <penberg@cs.helsinki.fi>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Linux Memory Management List <linux-mm@kvack.org>
List-Id: linux-mm.kvack.org

Silently fill buffer with zeros when encounter hwpoison pages
(accessing the hwpoison page content is deadly).

This patch does not cover X86_32 - which has a dumb kern_addr_valid().
It is unlikely anyone run a 32bit kernel will care about the hwpoison
feature - its usable memory is limited.

CC: Ingo Molnar <mingo@elte.hu>
CC: Andi Kleen <andi@firstfloor.org> 
CC: Pekka Enberg <penberg@cs.helsinki.fi>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 arch/x86/mm/init_64.c |   16 +++++++++++++---
 1 file changed, 13 insertions(+), 3 deletions(-)

--- linux-mm.orig/arch/x86/mm/init_64.c	2010-01-13 21:23:04.000000000 +0800
+++ linux-mm/arch/x86/mm/init_64.c	2010-01-13 21:25:32.000000000 +0800
@@ -825,6 +825,7 @@ int __init reserve_bootmem_generic(unsig
 int kern_addr_valid(unsigned long addr)
 {
 	unsigned long above = ((long)addr) >> __VIRTUAL_MASK_SHIFT;
+	unsigned long pfn;
 	pgd_t *pgd;
 	pud_t *pud;
 	pmd_t *pmd;
@@ -845,14 +846,23 @@ int kern_addr_valid(unsigned long addr)
 	if (pmd_none(*pmd))
 		return 0;
 
-	if (pmd_large(*pmd))
-		return pfn_valid(pmd_pfn(*pmd));
+	if (pmd_large(*pmd)) {
+		pfn = pmd_pfn(*pmd);
+		pfn += pte_index(addr);
+		goto check_pfn;
+	}
 
 	pte = pte_offset_kernel(pmd, addr);
 	if (pte_none(*pte))
 		return 0;
 
-	return pfn_valid(pte_pfn(*pte));
+	pfn = pte_pfn(*pte);
+check_pfn:
+	if (!pfn_valid(pfn))
+		return 0;
+	if (PageHWPoison(pfn_to_page(pfn)))
+		return 0;
+	return 1;
 }
 
 /*


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
