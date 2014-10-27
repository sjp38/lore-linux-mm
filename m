Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 9F88B6B0069
	for <linux-mm@kvack.org>; Sun, 26 Oct 2014 20:19:11 -0400 (EDT)
Received: by mail-wi0-f175.google.com with SMTP id h11so3008581wiw.2
        for <linux-mm@kvack.org>; Sun, 26 Oct 2014 17:19:11 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d5si12102587wjs.63.2014.10.26.17.19.09
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 26 Oct 2014 17:19:09 -0700 (PDT)
Date: Mon, 27 Oct 2014 01:18:42 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH V2 1/2] mm: Update generic gup implementation to handle
 hugepage directory
Message-ID: <20141027001842.GU6911@redhat.com>
References: <1413520687-31729-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <20141022160224.9c2268795e55d5a2eff5b94d@linux-foundation.org>
 <20141023.184035.388557314666522484.davem@davemloft.net>
 <1414107635.364.91.camel@pasglop>
 <1414167761.19984.17.camel@jarvis.lan>
 <1414356641.364.142.camel@pasglop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1414356641.364.142.camel@pasglop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: James Bottomley <James.Bottomley@HansenPartnership.com>, David Miller <davem@davemloft.net>, akpm@linux-foundation.org, aneesh.kumar@linux.vnet.ibm.com, steve.capper@linaro.org, mpe@ellerman.id.au, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-arch@vger.kernel.org, hannes@cmpxchg.org

Hello,

On Mon, Oct 27, 2014 at 07:50:41AM +1100, Benjamin Herrenschmidt wrote:
> On Fri, 2014-10-24 at 09:22 -0700, James Bottomley wrote:
> 
> > Parisc does this.  As soon as one CPU issues a TLB purge, it's broadcast
> > to all the CPUs on the inter-CPU bus.  The next instruction isn't
> > executed until they respond.
> > 
> > But this is only for our CPU TLB.  There's no other external
> > consequence, so removal from the page tables isn't effected by this TLB
> > flush, therefore the theory on which Dave bases the change to
> > atomic_add() should work for us (of course, atomic_add is lock add
> > unlock on our CPU, so it's not going to be of much benefit).
> 
> I'm not sure I follow you here.
> 
> Do you or do you now perform an IPI to do TLB flushes ? If you don't
> (for example because you have HW broadcast), then you need the
> speculative get_page(). If you do (and can read a PTE atomically), you
> can get away with atomic_add().
> 
> The reason is that if you remember how zap_pte_range works, we perform
> the flush before we get rid of the page.
> 
> So if your using IPIs for the flush, the fact that gup_fast has
> interrupts disabled will delay the IPI response and thus effectively
> prevent the pages from being actually freed, allowing us to simply do
> the atomic_add() on x86.
> 
> But if we don't use IPIs because we have HW broadcast of TLB
> invalidations, then we don't have that synchronization. atomic_add won't
> work, we need get_page_speculative() because the page could be
> concurrently being freed.

I looked at how this works more closely and I agree
get_page_unless_zero is always necessary if the TLB flush doesn't
always wait for IPIs to all CPUs where a gup_fast may be running onto.

To summarize, the pagetables are freed with RCU (arch sets
HAVE_RCU_TABLE_FREE) and that allows to walk them lockless with RCU.

After we can walk the pagetables lockless with RCU, we get to the page
lockless, but the pages themself can still be freed at any time from
under us (hence the need for get_page_unless_zero).

The additional trick gup_fast RCU does is to recheck the pte after
elevating the page count with get_page_unless_zero. Rechecking the
pte/hugepmd to be sure it didn't change from under us is critical to
be sure get_page_unless_zero didn't run after the page was freed and
reallocated which would otherwise lead to a security problem too
(i.e. it protects against get_page_unless_zero false positives).

The last bit required is to still disable irqs like on x86 to
serialize against THP splits combined with pmdp_splitting_flush always
delivering IPIs (pmdp_splitting_flush must wait all gup_fast to
complete before proceeding in mangling the page struct of the compound
page).

Preventing the irq disable while taking a gup_fast pin using
compound_lock isn't as "easy" as it is to do for put_page. put_page
(non-compound) fastest path remains THP agnostic because
collapse_huge_page is inhibited by any existing gup pin, but here
we're exactly taking it, so we can't depend on it to already exist to
avoid the race with collapse_huge_page. It's not just split_huge_page
we need to protect against.

So while thinking the above summary, I noticed this patch misses a IPI
in mm/huge_memory.c that must be delivered after pmdp_clear_flush
below to be safe against collapse_huge_page for the same reasons it
sends it within pmdp_splitting_flush. Without this IPI what can happen
is that the GUP pin protection in __collapse_huge_page_isolate races
against gup_fast-RCU.

If gup_fast reads the pte on one CPU before pmdp_clear_flush, and on
the other CPU __collapse_huge_page_isolate succeeds, then gup_fast
could recheck the pte that hasn't been zapped yet by
__collapse_huge_page_copy. gup_fast would succeed because the pte
wasn't zapped yet, but then __collapse_huge_page_copy would run
replacing the pte with a transhuge pmd, making gup_fast return the old
page, while the process got the copy as part of the collapsed hugepage.

	/*
	 * After this gup_fast can't run anymore. This also removes
	   ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ -> invariant broken by gup_fast-RCU
	 * any huge TLB entry from the CPU so we won't allow
	 * huge and small TLB entries for the same virtual address
	 * to avoid the risk of CPU bugs in that area.
	 */
	_pmd = pmdp_clear_flush(vma, address, pmd);
	spin_unlock(pmd_ptl);
	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);

	spin_lock(pte_ptl);
	isolated = __collapse_huge_page_isolate(vma, address, pte);
	spin_unlock(pte_ptl);

CPU0					CPU1
---------				-------------
gup_fast-RCU
local_irq_disable()
pte = pte_offset_map(pmd, address)

					pmdp_clear_flush (not sending IPI -> bug)

					__collapse_huge_page_isolate -> succeeds

					(page_count != 1 gup-pin check of
					__collapse_huge_page_isolate
					didn't fire)

page = vm_normal_page(pte)
get_page_unless_zero() -> succeeds
recheck pte -> succeeds
local_irq_enable()
return page

					collapse_huge_page thought
					no gup_fast could run after
					pmdp_clear_flush returned

					__collapse_huge_page_copy (zap
					pte too late, gup_fast already
					returned on the other CPU)

					set_pmd_at(mm, address, pmd, _pmd);

					virtual memory backed by THP

gup_fast went out of sync with virtual memory

It could be solved also without IPI, for example by adding a failure
path to __collapse_huge_page_copy and by adding a second gup-pin check
(page_count != 1) after pte_clear(vma->vm_mm, address, _pte) (with a
smp_mb() in between) and returning a failure if the check
triggers. However then we need to store the 512 pte pointers in a
temporary page to roll all of them back if we raced.

Comments what is preferable between IPI and a gup-pin check after
zapping the pte in __collapse_huge_page_copy welcome. If a
modification to __collapse_huge_page_copy is preferable the temporary
pte allocation (for rollback in the gup-pin check trigger case) should
still be skipped on x86.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
