Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id E4C166B00B9
	for <linux-mm@kvack.org>; Tue, 13 Nov 2012 06:24:15 -0500 (EST)
Date: Tue, 13 Nov 2012 11:24:10 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 05/19] mm: numa: pte_numa() and pmd_numa()
Message-ID: <20121113112410.GW8218@suse.de>
References: <1352193295-26815-1-git-send-email-mgorman@suse.de>
 <1352193295-26815-6-git-send-email-mgorman@suse.de>
 <20121113095417.GB21522@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20121113095417.GB21522@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Hi Ingo,

On Tue, Nov 13, 2012 at 10:54:17AM +0100, Ingo Molnar wrote:
> 
> * Mel Gorman <mgorman@suse.de> wrote:
> 
> > From: Andrea Arcangeli <aarcange@redhat.com>
> > 
> > Implement pte_numa and pmd_numa.
> > 
> > <Changlog SNIP>
> > ---
> >  arch/x86/include/asm/pgtable.h |   65 ++++++++++++++++++++++++++++++++++++++--
> >  include/asm-generic/pgtable.h  |   12 ++++++++
> >  2 files changed, 75 insertions(+), 2 deletions(-)
> > 
> > <Patch SNIP>
> 
> Hm, this overcomplicates things quite a bit and adds arch 
> specific code, and there's no explanation given for that 
> approach that I can see?
> 

So there are two possible problems here - the PTE flag naming and how
it's implemented.

On the PTE flag naming front, the changelog explains the disadvantages
to using PROT_NONE and this arrangement allows an architecture to make a
better decision if one is available. The relevant parts of the changelog are

	_PAGE_NUMA on x86 shares the same bit number of _PAGE_PROTNONE (but
	it could also use a different bitflag, it's up to the architecture
	to decide).

and

	Sharing the same bitflag with _PAGE_PROTNONE in fact complicates
	things: it requires us to ensure the code paths executed by
	_PAGE_PROTNONE remains mutually exclusive to the code paths executed
	by _PAGE_NUMA at all times, to avoid _PAGE_NUMA and _PAGE_PROTNONE
	to step into each other toes.

so I'd like to keep that. Any major objections?

> Basically, what's wrong with the generic approach that numa/core 
> has:
> 
>  __weak bool pte_numa(struct vm_area_struct *vma, pte_t pte)
> 
> [see the full function below.]
> 
> Then we can reuse existing protection-changing functionality and 
> keep it all tidy.
> 

I very much like this idea of this approach. Superficially I see nothing
wrong with it. I just didn't think of it when I was trying to resolve
the two trees together.

> an architecture that wants to do something special could 
> possibly override it in the future - but we want to keep the 
> generic logic in generic code.
> 

Sensible and probably less mess in the future.

> __weak bool pte_numa(struct vm_area_struct *vma, pte_t pte)
> {

I'll lift this and see can it be modified to use _PAGE_NUMA instead of
hard-coding for PROT_NONE.  Of course if you beat me to it and send a patch,
that'd be cool too :)

Thanks!

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
