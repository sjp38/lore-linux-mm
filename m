Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id AF7538D0039
	for <linux-mm@kvack.org>; Wed,  2 Mar 2011 16:40:52 -0500 (EST)
Received: from canuck.infradead.org ([134.117.69.58])
	by bombadil.infradead.org with esmtps (Exim 4.72 #1 (Red Hat Linux))
	id 1Putms-0000L3-BU
	for linux-mm@kvack.org; Wed, 02 Mar 2011 21:40:50 +0000
Received: from j77219.upc-j.chello.nl ([24.132.77.219] helo=dyad.programming.kicks-ass.net)
	by canuck.infradead.org with esmtpsa (Exim 4.72 #1 (Red Hat Linux))
	id 1Putlm-0000cJ-1Q
	for linux-mm@kvack.org; Wed, 02 Mar 2011 21:40:49 +0000
Subject: Re: [RFC][PATCH 2/6] mm: Change flush_tlb_range() to take an
 mm_struct
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <AANLkTimhWKhHojZ-9XZGSh3OzfPhvo__Dib9VfeMWoBQ@mail.gmail.com>
References: <20110302175928.022902359@chello.nl>
	 <20110302180258.956518392@chello.nl>
	 <AANLkTimhWKhHojZ-9XZGSh3OzfPhvo__Dib9VfeMWoBQ@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 02 Mar 2011 22:40:27 +0100
Message-ID: <1299102027.1310.39.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Russell King <rmk@arm.linux.org.uk>, Chris Metcalf <cmetcalf@tilera.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>

On Wed, 2011-03-02 at 11:19 -0800, Linus Torvalds wrote:
> On Wed, Mar 2, 2011 at 9:59 AM, Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
> > In order to be able to properly support architecture that want/need to
> > support TLB range invalidation, we need to change the
> > flush_tlb_range() argument from a vm_area_struct to an mm_struct
> > because the range might very well extend past one VMA, or not have a
> > VMA at all.
> 
> I really don't think this is right. The whole "drop the icache
> information" thing is a total anti-optimization, since for some
> architectures, the icache flush is the _big_ deal. 

Right, so Tile has the I-cache flush from flush_tlb_range(), I'm not
sure if that's the right thing to do, Documentation/cachetlb.txt seems
to suggest doing it from update_mmu_cache() like things.

However, I really don't know, and would happily be explained how these
things are supposed to work. Also:

> Possibly much
> bigger than the TLB flush itself. Doing an icache flush was much more
> expensive than the TLB flush on alpha, for example (the tlb had ASI's
> etc, the icache did not).

Right, but the problem remains that we do page-table teardown without
having a vma.

Now we can re-introduce I/D variants again by assuming D-only and using
tlb_start_vma() to set a I-too bit on VM_EXEC. (this assumes the vm_args
range is non-executable -- which it had better be).

How about I do something like:

enum {
  TLB_FLUSH_I = 1,
  TLB_FLUSH_D = 2,
  TLB_FLUSH_PAGE = 4,
  TLB_FLUSH_HPAGE = 8,
};

void flush_tlb_range(struct mm_struct *mm, unsigned long start,
		     unsigned long end, unsigned int flags);

And we then do:

tlb_gather_mmu(struct mmu_gather *tlb, ...)
{
  ...
  tlb->flush_type = TLB_FLUSH_D | TLB_FLUSH_PAGE;
}

tlb_start_vma(struct mmu_gather *tlb, struct vm_area_struct *vma)
{
  if (!tlb->fullmm)
    flush_cache_range(vma, vma->vm_start, vma->vm_end);

  if (vma->vm_flags & VM_EXEC)
    tlb->flush_type |= TLB_FLUSH_I;

  if (vma->vm_flags & VM_HUGEPAGE)
    tlb->flush_type |= TLB_FLUSH_HPAGE;
}

tlb_flush_mmu(struct mmu_gather *tlb)
{
  if (!tlb->fullmm && tlb->need_flush) {
    flush_tlb_range(tlb->mm, tlb->start, tlb->end, tlb->flush_type);	
    tlb->start = TASK_SIZE;
    tlb->end = 0;
  }
  ...
}

> > There are various reasons that we need to flush TLBs _after_ freeing
> > the page-tables themselves. For some architectures (x86 among others)
> > this serializes against (both hardware and software) page table
> > walkers like gup_fast().
> 
> This part of the changelog also makes no sense what-so-ever. It's
> actively wrong.
> 
> On x86, we absolutely *must* do the TLB flush _before_ we release the
> page tables. So your commentary is actively wrong and misleading.
> 
> The order has to be:
>  - clear the page table entry, queue the page to be free'd
>  - flush the TLB
>  - free the page (and page tables)
> 
> and nothing else is correct, afaik. So the changelog is pure and utter
> garbage. I didn't look at what the patch actually changed.

OK, so I use the wrong terms, I meant page-table tear-down, where we
remove the pte page pointer from the pmd, remove the pmd page from the
pud etc.

We then flush the TLBs and only then actually free the pages. I think
the confusion stems from the fact that we call tear-down free_pgtables()

The point was that we need to TLB flush _after_ tear-down (before actual
free), not before tear-down. The problem is that currently we either end
up doing too many TLB flushes or one too few.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
