Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id 52C088D0002
	for <linux-mm@kvack.org>; Fri, 16 Nov 2012 11:56:12 -0500 (EST)
Date: Fri, 16 Nov 2012 16:56:06 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 06/43] mm: numa: Make pte_numa() and pmd_numa() a generic
 implementation
Message-ID: <20121116165606.GE8218@suse.de>
References: <1353064973-26082-1-git-send-email-mgorman@suse.de>
 <1353064973-26082-7-git-send-email-mgorman@suse.de>
 <50A648FF.2040707@redhat.com>
 <20121116144109.GA8218@suse.de>
 <CA+55aFzH_-6FuwTF1GVDzLK+7c0MGLsLdPFjzzwU78GVUEMbBw@mail.gmail.com>
 <20121116160852.GA4302@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20121116160852.GA4302@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Nov 16, 2012 at 05:08:52PM +0100, Ingo Molnar wrote:
> 
> * Linus Torvalds <torvalds@linux-foundation.org> wrote:
> 
> > On Fri, Nov 16, 2012 at 6:41 AM, Mel Gorman <mgorman@suse.de> wrote:
> > >
> > > I would have preferred asm-generic/pgtable.h myself and use
> > > __HAVE_ARCH_whatever tricks
> > 
> > PLEASE NO!
> > 
> > Dammit, why is this disease still so prevalent, and why do people
> > continue to do this crap?
> 
> Also, why is this done in a weird, roundabout way of first 
> picking up a bad patch and then modifying it and making it even 
> worse?
> 

To keep the history so that someone looking at mails with just new subjects
may spot it. I'll collapse the patches together in the next release because
the difference will no longer beinteresting.

> Why not use something what we have in numa/core already:
> 
>   f05ea0948708 mm/mpol: Create special PROT_NONE infrastructure
> 

Because it's hard-coded to PROT_NONE underneath which I've complained about
before. It also depends on being able to use vm_get_page_prot(vmflags)
which will always be a function call which to me would always be heavier.

> AFAICS, this portion of numa/core:
> 
> c740b1cccdcb x86/mm: Completely drop the TLB flush from ptep_set_access_flags()

We share this.

> 02743c9c03f1 mm/mpol: Use special PROT_NONE to migrate pages

hard-codes prot_none

> b33467764d8a mm/migrate: Introduce migrate_misplaced_page()

bolts onto the side of migration and introduces MIGRATE_FAULT which
should not have been necessary. Already complained about.

The alternative uses the existing migrate_pages() function but has
different requirements for taking a reference to the page.

> db4aa58db59a numa, mm: Support NUMA hinting page faults from gup/gup_fast

We share this.

> ca2ea0747a5b mm/mpol: Add MPOL_MF_LAZY

We more or less share this except I backed out the userspace visible bits
in a separate patch because I didn't think it had been carefully reviewed
how an application should use it and if it was a good idea. Covered in an
earlier review.

> f05ea0948708 mm/mpol: Create special PROT_NONE infrastructure

hard-codes to prot_none.

I know I am should convert change_prot_numa to wrap around change_protection
if _PAGE_NUMA == _PAGE_PROTNONE but wanted to make sure we had all the
requirements for change_prot_none correct before adapting it.

Otherwise from a high-level we are very similar here.

> 37081a3de2bf mm/mpol: Check for misplaced page

Think we share this.

> cd203e33c39d mm/mpol: Add MPOL_MF_NOOP

I have a patch that backs this out on the grounds that I don't think we
have adequately discussed if it was the correct userspace interface. I
know Peter put a lot of time into it so it's probably correct but
without man pages or spending time writing an example program that used
it, I played safe.

> 88f4670789e3 mm/mpol: Make MPOL_LOCAL a real policy

We share this.

> 83babc0d2944 mm/pgprot: Move the pgprot_modify() fallback definition to mm.h

Related to prot_none hard-coding

> 536165ead34b sched, numa, mm, MIPS/thp: Add pmd_pgprot() implementation

Same

> 6fe64360a759 mm: Only flush the TLB when clearing an accessible pte

I missed this. Stupid stupid stupid! It would reduce the TLB flushes from
migration context.

> e9df40bfeb25 x86/mm: Introduce pte_accessible()

prot_none.

> 3f2b613771ec mm/thp: Preserve pgprot across huge page split

Lot more churn in there than is necessary which was covered in review.
Otherwise functionally we share this.

> a5a608d83e0e sched, numa, mm, s390/thp: Implement pmd_pgprot() for s390

prot_none choice

> 995334a2ee83 sched, numa, mm: Describe the NUMA scheduling problem formally

I like this. I didn't pick it up until the policy stuff was more
advanced so it could be properly described in the same fashion.

> 7ee9d9209c57 sched, numa, mm: Make find_busiest_queue() a method

We share this. I introduce it much later when it becomes required.

> 4fd98847ba5c x86/mm: Only do a local tlb flush in ptep_set_access_flags()
> d24fc0571afb mm/generic: Only flush the local TLB in ptep_set_access_flags()
> 

We share this.

> is a good foundation already with no WIP policy bits in it.
> 
> Mel, could you please work on this basis, or point out the bits 
> you don't agree with so I can fix it?
> 

My main hangup is the prot_none choice and I know it's something we have
butted heads on without progress. I feel it is a lot cleaner to have
the _PAGE_NUMA bit (even if it's PROT_NONE underneath) and the helpers
avoid function calls where possible. It also made the PMD handling sortof
straight-forward and allowed the batching taking of the PTL and migration
if the pages in the PMD were all on the same node. I liked this.

Yours is closer to what the architecture does and can use change_protect()
with very few changes but on balance I did not find this a compelling
alternative.

Further I took the time to put together a basic policy instead of jumping
straight to the end so the logical progression from beginning to end is
obvious. This to me at least is a more incremental approach.  It also
allows us to keep a close eye on the system CPU usage and know which parts
of it might be due to the underlying mechanics and which are due to poor
placement policy decisions. The series is longer as a result but it is
more tractable and will be bisectable.

> Since I'm working on improving the policy bits I essentially 
> need and have done all the 'foundation' work already - you might 
> as well reuse it as-is instead of rebasing it?
> 

I really have hangups about the prot_none thing. I also have hang-ups
that the "policy" bit is one big patch doing all the changes at once
making it harder to figure out whether it is the load balancer changes,
scanning machinery or placement policy that are making the big differences.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
