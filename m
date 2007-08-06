Subject: Re: What archs need flush_tlb_page() in handle_pte_fault() ?
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <1186018621.5495.558.camel@localhost.localdomain>
References: <1186018621.5495.558.camel@localhost.localdomain>
Content-Type: text/plain
Date: Mon, 06 Aug 2007 16:37:42 +1000
Message-Id: <1186382262.938.35.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Linux Kernel list <linux-kernel@vger.kernel.org>, Linux Arch list <linux-arch@vger.kernel.org>, Linus Torvalds <torvalds@osdl.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2007-08-02 at 11:37 +1000, Benjamin Herrenschmidt wrote:
> Heya !
> 
> In my page table accessor spring cleaning, one of my targets is
> flush_tlb_page(). At this stage, it's only called by generic code in one
> place (in addition to the asm-generic bits that use it to implement
> missing accessors, but I'm taking care of those spearately) :

 .../...

No reply, so I suppose I can rip it out ? :-)

Thus any reason why that patch wouln't fly ? (not for 2.6.23 of course)

This removes the last occurence of flush_tlb_page() from generic code,
thus making this hook now optional for architectures that don't use
the helpers in asm-generic/pgtable.h

I couldn't find a case where this is actually needed, but I may well
have missed something. If I did though, please tell me what. If an
architecture need that call for obscure reason, it could be simply
folded in that architecture's implementation ptep_set_access_flags().

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---

Index: linux-work/mm/memory.c
===================================================================
--- linux-work.orig/mm/memory.c	2007-08-06 16:32:12.000000000 +1000
+++ linux-work/mm/memory.c	2007-08-06 16:34:07.000000000 +1000
@@ -2609,15 +2609,6 @@ static inline int handle_pte_fault(struc
 	if (ptep_set_access_flags(vma, address, pte, entry, write_access)) {
 		update_mmu_cache(vma, address, entry);
 		lazy_mmu_prot_update(entry);
-	} else {
-		/*
-		 * This is needed only for protection faults but the arch code
-		 * is not yet telling us if this is a protection fault or not.
-		 * This still avoids useless tlb flushes for .text page faults
-		 * with threads.
-		 */
-		if (write_access)
-			flush_tlb_page(vma, address);
 	}
 unlock:
 	pte_unmap_unlock(pte, ptl);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
