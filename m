Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 932876B004A
	for <linux-mm@kvack.org>; Wed,  1 Jun 2011 19:30:44 -0400 (EDT)
Date: Thu, 2 Jun 2011 01:30:36 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] mm: compaction: Abort compaction if too many pages are
 isolated and caller is asynchronous
Message-ID: <20110601233036.GZ19505@random.random>
References: <20110530165546.GC5118@suse.de>
 <20110530175334.GI19505@random.random>
 <20110531121620.GA3490@barrios-laptop>
 <20110531122437.GJ19505@random.random>
 <20110531133340.GB3490@barrios-laptop>
 <20110531141402.GK19505@random.random>
 <20110601005747.GC7019@csn.ul.ie>
 <20110601175809.GB7306@suse.de>
 <20110601191529.GY19505@random.random>
 <20110601214018.GC7306@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110601214018.GC7306@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Minchan Kim <minchan.kim@gmail.com>, akpm@linux-foundation.org, Ury Stankevich <urykhy@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, stable@kernel.org

Hi Mel,

On Wed, Jun 01, 2011 at 10:40:18PM +0100, Mel Gorman wrote:
> On Wed, Jun 01, 2011 at 09:15:29PM +0200, Andrea Arcangeli wrote:
> > On Wed, Jun 01, 2011 at 06:58:09PM +0100, Mel Gorman wrote:
> > > Umm, HIGHMEM4G implies a two-level pagetable layout so where are
> > > things like _PAGE_BIT_SPLITTING being set when THP is enabled?
> > 
> > They should be set on the pgd, pud_offset/pgd_offset will just bypass.
> > The splitting bit shouldn't be special about it, the present bit
> > should work the same.
> 
> This comment is misleading at best then.
> 
> #define _PAGE_BIT_SPLITTING     _PAGE_BIT_UNUSED1 /* only valid on a PSE pmd */

>From common code point of view it's set in the pmd, the comment can be
extended to specify it's actually the pgd in case of 32bit noPAE but I
didn't think it was too misleading as we think in common code terms
all over the code, the fact it's a bypass is pretty clear across the
whole archs.

> At the PGD level, it can have PSE set obviously but it's not a
> PMD. I confess I haven't checked the manual to see if it's safe to
> use _PAGE_BIT_UNUSED1 like this so am taking your word for it. I

To be sure I re-checked on 253668.pdf page 113/114 noPAE and page 122
PAE, on x86 32bit/64 all ptes/pmd/pgd (32bit/64bit PAE/noPAE) have bit
9-11 "Avail" to software. So I think we should be safe here.

> found that the bug is far harder to reproduce with 3 pagetable levels
> than with 2 but that is just timing. So far it has proven impossible
> on x86-64 at least within 27 hours so that has me looking at how
> pagetable management between x86 and x86-64 differ.

Weird.

However I could see it screwing the nr_inactive/active_* stats, but
the nr_isolated should never go below zero, and especially not anon
even if split_huge_page does the accounting wrong (and
migrate/compaction won't mess with THP), or at least I'd expect things
to fall apart in other ways and not with just a fairly innocuous and
not-memory corrupting nr_isolated_ counter going off just by one.

The khugepaged nr_isolated_anon increment couldn't affect the file one
and we hold mmap_sem write mode there to prevent the pte to change
from under us, in addition to the PT and anon_vma lock. Anon_vma lock
being wrong sounds unlikely too, and even if it was it should screw
the nr_isolated_anon counter, impossible to screw the nr_isolated_file
with khugepaged.

Where did you put your bugcheck? It looked like you put it in the < 0
reader, can you add it to all _inc/dec/mod (even _inc just in case) so
we may get a stack trace including the culprit? (not guaranteed but
better chance)

> Barriers are a big different between how 32-bit !SMP and X86-64 but
> don't know yet which one is relevant or if this is even the right
> direction.

The difference is we need xchg on SMP to avoid losing the dirty
bit. Otherwise if we do pmd_t pmd = *pmdp; *pmdp = 0; the dirty bit
may have been set in between the two by another thread running in
userland in a different CPU, while the pmd was still "present". As
long as interrupts don't write to read-write userland memory with the
pte dirty bit clear, we shouldn't need xchg on !SMP.

On PAE we also need to write 0 into pmd_low before worrying about
pmd_high so the present bit is cleared before clearing the high part
of the 32bit PAE pte, and we relay on xchg implicit lock to avoid a
smp_wmb() in between the two writes.

I'm unsure if any of this could be relevant to our problem, also there
can't be more than one writer at once in the pmd, as nobody can modify
it without the page_table_lock held. xchg there is just to be safe for
the dirty bit (or we'd corrupt memory with threads running in userland
and writing to memory on other cpus while we ptep_clear_flush).

I've been wondering about the lack of "lock" on the bus in atomic.h
too, but I can't see how it can possibly matter on !SMP, vmstat
modifications should execute only 1 asm insn so preempt or irq can't
interrupt it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
