Message-ID: <42BA5FC8.9020501@yahoo.com.au>
Date: Thu, 23 Jun 2005 17:07:52 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [patch][rfc] 4/5: remap ZERO_PAGE mappings
References: <42BA5F37.6070405@yahoo.com.au> <42BA5F5C.3080101@yahoo.com.au> <42BA5F7B.30904@yahoo.com.au> <42BA5FA8.7080905@yahoo.com.au>
In-Reply-To: <42BA5FA8.7080905@yahoo.com.au>
Content-Type: multipart/mixed;
 boundary="------------050204080603020303060408"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
Cc: Hugh Dickins <hugh@veritas.com>, Badari Pulavarty <pbadari@us.ibm.com>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------050204080603020303060408
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

4/5

--------------050204080603020303060408
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

In future, this becomes required in order to always be able to detect
whether a pte points to a ZERO_PAGE using only the pte, vaddr pair.

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

--------------050204080603020303060408--
Send instant messages to your online friends http://au.messenger.yahoo.com 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
