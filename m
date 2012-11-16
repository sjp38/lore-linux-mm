Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 729C76B005A
	for <linux-mm@kvack.org>; Fri, 16 Nov 2012 12:38:00 -0500 (EST)
Received: by mail-ee0-f41.google.com with SMTP id d41so2177352eek.14
        for <linux-mm@kvack.org>; Fri, 16 Nov 2012 09:37:58 -0800 (PST)
Date: Fri, 16 Nov 2012 18:37:55 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 06/43] mm: numa: Make pte_numa() and pmd_numa() a generic
 implementation
Message-ID: <20121116173755.GB4697@gmail.com>
References: <1353064973-26082-1-git-send-email-mgorman@suse.de>
 <1353064973-26082-7-git-send-email-mgorman@suse.de>
 <50A648FF.2040707@redhat.com>
 <20121116144109.GA8218@suse.de>
 <CA+55aFzH_-6FuwTF1GVDzLK+7c0MGLsLdPFjzzwU78GVUEMbBw@mail.gmail.com>
 <20121116160852.GA4302@gmail.com>
 <20121116165606.GE8218@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121116165606.GE8218@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>


* Mel Gorman <mgorman@suse.de> wrote:

> > AFAICS, this portion of numa/core:
> > 
> > c740b1cccdcb x86/mm: Completely drop the TLB flush from ptep_set_access_flags()
> 
> We share this.
> 
> > 02743c9c03f1 mm/mpol: Use special PROT_NONE to migrate pages
> 
> hard-codes prot_none

I prefer any arch support extensions to be done in the patch 
that adds that specific arch support.

That way we can consider the pros and cons of abstraction. Also 
see further below.

> > cd203e33c39d mm/mpol: Add MPOL_MF_NOOP
> 
> I have a patch that backs this out on the grounds that I don't 
> think we have adequately discussed if it was the correct 
> userspace interface. I know Peter put a lot of time into it so 
> it's probably correct but without man pages or spending time 
> writing an example program that used it, I played safe.

I'm fine with not exposing it to user-space.

> > Mel, could you please work on this basis, or point out the 
> > bits you don't agree with so I can fix it?
> 
> My main hangup is the prot_none choice and I know it's 
> something we have butted heads on without progress. [...]

It's the basic KISS concept - I think you are over-designing 
this. An architecture opts in to the new, generic code via 
doing:

  select ARCH_SUPPORTS_NUMA_BALANCING

... if it cannot enable that then it will extend the core code 
in *very* visible ways.

> [...] I feel it is a lot cleaner to have the _PAGE_NUMA bit 
> (even if it's PROT_NONE underneath) and the helpers avoid 
> function calls where possible. It also made the PMD handling 
> sortof straight-forward and allowed the batching taking of the 
> PTL and migration if the pages in the PMD were all on the same 
> node. I liked this.
> 
> Yours is closer to what the architecture does and can use 
> change_protect() with very few changes but on balance I did 
> not find this a compelling alternative.

IMO here you are on the wrong side of history as well.

For example reusing change_protection() *already* uncovered 
useful optimizations to the generic code:

   http://comments.gmane.org/gmane.linux.kernel.mm/89707

(regardless of how this particular change_protection() 
 optimization will look like.)

that optimization would not have happened with your open-coded 
change_protection() variant plain and simple.

So, to put it bluntly, you are not only doing a stupid thing, 
you are doing an actively harmful thing here...

If you fix that then most of the differences between your tree 
and numa/core disappears. You'll end up very close to:

  - rebasing numa/core pretty much as-is
  + add your migrate_displaced() function
  - remove the user-facing lazy migration facilities.
  + inline pte_numa()/pmd_numa() if you think it's beneficial

If that works for you I'll test and backmerge all such deltas 
quickly and we can move on.

Then you could hack whatever policy and instrumentation bits you 
want, on top of that agreed upon base.

Would that approach work for you?

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
