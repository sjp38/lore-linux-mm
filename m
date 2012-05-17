Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id 201196B00EC
	for <linux-mm@kvack.org>; Thu, 17 May 2012 13:23:49 -0400 (EDT)
Date: Thu, 17 May 2012 18:22:15 +0100
From: Russell King <rmk@arm.linux.org.uk>
Subject: Re: [RFC][PATCH 4/6] arm, mm: Convert arm to generic tlb
Message-ID: <20120517172215.GB11487@flint.arm.linux.org.uk>
References: <20110302175928.022902359@chello.nl> <20110302180259.109909335@chello.nl> <20120517030551.GA11623@linux-sh.org> <20120517093022.GA14666@arm.com> <20120517095124.GN23420@flint.arm.linux.org.uk> <1337254086.4281.26.camel@twins> <20120517160012.GB18593@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120517160012.GB18593@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Mundt <lethal@linux-sh.org>, Andrea Arcangeli <aarcange@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Chris Metcalf <cmetcalf@tilera.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>

On Thu, May 17, 2012 at 05:00:12PM +0100, Catalin Marinas wrote:
> On Thu, May 17, 2012 at 12:28:06PM +0100, Peter Zijlstra wrote:
> > On Thu, 2012-05-17 at 10:51 +0100, Russell King wrote:
> > > On Thu, May 17, 2012 at 10:30:23AM +0100, Catalin Marinas wrote:
> > > > Another minor thing is that on newer ARM processors (Cortex-A15) we
> > > > need the TLB shootdown even on UP systems, so tlb_fast_mode should
> > > > always return 0. Something like below (untested):
> > > 
> > > No Catalin, we need this for virtually all ARMv7 CPUs whether they're UP
> > > or SMP, not just for A15, because of the speculative prefetch which can
> > > re-load TLB entries from the page tables at _any_ time.
> > 
> > Hmm,. so this is mostly because of the confusion/coupling between
> > tlb_remove_page() and tlb_remove_table() I guess. Since I don't see the
> > freeing of the actual pages being a problem with speculative TLB
> > reloads, just the page-tables.
> > 
> > Should we introduce a tlb_remove_table() regardless of
> > HAVE_RCU_TABLE_FREE which always queues the tables regardless of
> > tlb_fast_mode()? 
> 
> BTW, looking at your tlb-unify branch, does tlb_remove_table() call
> tlb_flush/tlb_flush_mmu before freeing the tables?  I can only see
> tlb_remove_page() doing this. On ARM, even UP, we need the TLB flushing
> after clearing the pmd and before freeing the pte page table (and
> ideally doing it less often than at every pte_free_tlb() call).

Catalin,

The way TLB shootdown stuff works is that _every_ single bit of memory
which gets freed, whether its a page or a page table, gets added to a
list of pages to be freed.

So, the sequence is:
- remove pte/pmd/pud/pgd pointers
- add pages, whether they be pages pointed to by pte entries or page tables
  to be freed to a list
- when list is sufficiently full, invalidate TLBs
- free list of pages

That means the pages will not be freed, whether it be a page mapped
into userspace or a page table until such time that the TLB has been
invalidated.

For page tables, this is done via pXX_free_tlb(), which then calls out
to the arch specific __pXX_free_tlb(), which ultimately then hands the
page table over to tlb_remove_page() to add to the list of to-be-freed
pages.

-- 
Russell King
 Linux kernel    2.6 ARM Linux   - http://www.arm.linux.org.uk/
 maintainer of:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
