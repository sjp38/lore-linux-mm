Message-ID: <42F5802F.3050500@yahoo.com.au>
Date: Sun, 07 Aug 2005 13:29:51 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: [patch 1/2] mm: remap ZERO_PAGE mappings
References: <42F57FCA.9040805@yahoo.com.au>
In-Reply-To: <42F57FCA.9040805@yahoo.com.au>
Content-Type: multipart/mixed;
 boundary="------------030508080500010800060405"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel <linux-kernel@vger.kernel.org>
Cc: Linux Memory Management <linux-mm@kvack.org>, Hugh Dickins <hugh@veritas.com>, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, Andrea Arcangeli <andrea@suse.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------030508080500010800060405
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

1/2

I think this is already in -mm (and can probably go
into 2.6.14). Included here for completeness.

-- 
SUSE Labs, Novell Inc.


--------------030508080500010800060405
Content-Type: text/plain;
 name="mm-remap-ZERO_PAGE-mappings.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="mm-remap-ZERO_PAGE-mappings.patch"

Remap ZERO_PAGE ptes when remapping memory. This is currently just an
optimisation for MIPS, which is the only architecture with multiple
zero pages - it now retains the mapping it needs for good cache performance,
and as well do_wp_page is now able to always correctly detect and
optimise zero page COW faults.

This change is required in order to be able to detect whether a pte
points to a ZERO_PAGE using only its (pte, vaddr) pair.

Signed-off-by: Nick Piggin <npiggin@suse.de>

Index: linux-2.6/mm/mremap.c
===================================================================
--- linux-2.6.orig/mm/mremap.c
+++ linux-2.6/mm/mremap.c
@@ -141,6 +141,10 @@ move_one_page(struct vm_area_struct *vma
 			if (dst) {
 				pte_t pte;
 				pte = ptep_clear_flush(vma, old_addr, src);
+				/* ZERO_PAGE can be dependant on virtual addr */
+				if (pfn_valid(pte_pfn(pte)) &&
+					pte_page(pte) == ZERO_PAGE(old_addr))
+					pte = pte_wrprotect(mk_pte(ZERO_PAGE(new_addr), new_vma->vm_page_prot));
 				set_pte_at(mm, new_addr, dst, pte);
 			} else
 				error = -ENOMEM;

--------------030508080500010800060405--
Send instant messages to your online friends http://au.messenger.yahoo.com 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
