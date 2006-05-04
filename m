Date: Thu, 4 May 2006 16:27:42 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: RFC: RCU protected page table walking
In-Reply-To: <445A0784.2090803@bull.net>
Message-ID: <Pine.LNX.4.64.0605041611340.13830@blonde.wat.veritas.com>
References: <4458CCDC.5060607@bull.net> <200605041131.46254.ak@suse.de>
 <4459E663.10008@bull.net> <200605041400.34851.ak@suse.de> <445A0784.2090803@bull.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
Cc: Andi Kleen <ak@suse.de>, "Chen, Kenneth W" <kenneth.w.chen@intel.com>, Christoph Lameter <clameter@sgi.com>, linux-ia64@vger.kernel.org, linux-mm@kvack.org, Zoltan.Menyhart@free.fr
List-ID: <linux-mm.kvack.org>

On Thu, 4 May 2006, Zoltan Menyhart wrote:
> Andi Kleen wrote:
> 
> > > >We don't free the pages until the other CPUs have been flushed
> > > >synchronously.
> > >
> > >Do you mean the TLB entries mapping the leaf pages?
> > >If yes, then I agree with you about them.
> > >Yet I speak about the directory pages. Let's take an example:
> > 
> > x86 uses this for the directory pages too (well for PMD/PUD - PGD never
> > goes away until final exit).
> 
> The i386 branch:
> 
> tlb_remove_page():
>    // assuming !tlb_fast_mode(tlb)
>    tlb_flush_mmu():
>        tlb_flush():
>            flush_tlb_mm():
>                __flush_tlb();
>    free_pages_and_swap_cache();
> 
> __flush_tlb():
> 	"movl %%cr3, %0;
> 	"movl %0, %%cr3;  # flush TLB
> 
> Do I understand correctly that it purges the local TLBs only?

__flush_tlb() purges the local TLBs only; but when you found the i386
or x86_64 flush_tlb_mm() calling __flush_tlb() above, you were looking
at the #ifndef CONFIG_SMP block of include/asm/tlbflush.h.  Go over to
arch/{i386,x86_64}/kernel/smp.c to see what CONFIG_SMP flush_tlb_mm does.

> > Actually x86-64 didn't
> > fully at some point and it resulted in a nasty to track down bug.
> > But it was fixed then. I really went all over this with a very fine
> > comb back then and I'm pretty sure it's correct now :)
> 
> Can you please indicate how the page table walking of the other
> CPUs is "aborted"?

I cannot answer for other architectures: you need to ask the specialist
list of each architecture for its answer (or hope that a specialist in
each is already reading this thread on linux-mm).  What's certain is
that the issue is _supposed_ to be already covered safely on all arches,
hence the care which has gone into include/asm-generic/tlb.h etc.  But
you may be right that some architectures get it wrong, I cannot tell.

I've CC'ed Ken Chen and linux-ia64 (as Christoph intended to), since
that's your first concern; but I'm reluctant to CC lots of different
architecture lists together myself.

Hugh

> > > >After the flush the other CPUs don't walk pages anymore.
> 
> Can you please point me where it is documented that the HW walkers
> abort on a TLB flush / purge?
> 
> Yet I did verify that it is not (always) the case for the RISC-s.
> 
> E.g. arch/ia64/kernel/ivt.S:
> 
> ENTRY(vhpt_miss)
> ...
> 	// r17 = pmd_offset(pud, addr)
> // -->
> (p7)    ld8 r20=[r17]	// get *pmd (may be 0)
> 
> Assume we have reached the point indicated by "// -->":
> we have got a valid address for the next level.
> Assume "free_pgtables()" sets free these PMD / PTE pages.
> The eventual TLB flushes do not do anything to the "ld8"
> going to be executed.
> 
> Can you explain please why you think that walking the
> 
> 	rx = ... -> pgd[i] -> pud[j] -> pmd[k] -> pte[l]
> 
> chain is safe in this condition, too?
> 
> Another example in arch/ppc/kernel/head_44x.S:
> 
> 	/* Data TLB Error Interrupt */
> 	START_EXCEPTION(DataTLBError)
> ...
> 	// r11 -> PGD or PTE page, r12 = index * sizeof(void *)
> // -->
> 	lwzx    r11, r12, r11           /* Get pgd/pmd entry */
> 
> > >Can you explain please why they do not?
> > 
> > Because the PGD/PMD/PUD has been rewritten and they won't be able
> > to find the old pages anymore.
> 
> As in the two examples above, the walkers have already picked up
> references to the next levels, and these references were valid
> at that moment.
> 
> > They also don't have it in their
> > TLBs because that has been flushed.
> 
> Are you sure this is true for the RISC-s, too?
> Even if an architecture does not play with TLB-s before really
> finding a valid PTE?
> 
> > >There is a possibility that walking has already been started, but it has
> > >not been completed yet, when "free_pgtables()" runs.
> > 
> > Yes, that is why we delay the freeing of the pages to prevent anything
> > going wrong.
> 
> Can you explain please why the already-started walks, which do not
> care for the TLB flushes, can be safe?
> 
> > What do you mean with "physical mode"?
> 
> Not using any TLB entry (or any HW supported address translation stuff)
> to translate the data addresses before they go out of the CPU.
> 
> > >is insensitive to any TLB purges, therefore these purges do not make sure
> > >that there is no other CPU just
> > >in the middle of page table walking.
> 
> > A TLB Flush stops all MMU activity - or rather waits for it to finish.
> 
> This is what I am trying to say: not on all archtectures.
> 
> Thanks,
> 
> Zoltan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
