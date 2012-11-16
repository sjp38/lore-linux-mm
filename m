Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id 7D8876B0081
	for <linux-mm@kvack.org>; Fri, 16 Nov 2012 13:45:05 -0500 (EST)
Date: Fri, 16 Nov 2012 18:44:59 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 06/43] mm: numa: Make pte_numa() and pmd_numa() a generic
 implementation
Message-ID: <20121116184459.GG8218@suse.de>
References: <1353064973-26082-1-git-send-email-mgorman@suse.de>
 <1353064973-26082-7-git-send-email-mgorman@suse.de>
 <50A648FF.2040707@redhat.com>
 <20121116144109.GA8218@suse.de>
 <CA+55aFzH_-6FuwTF1GVDzLK+7c0MGLsLdPFjzzwU78GVUEMbBw@mail.gmail.com>
 <20121116160852.GA4302@gmail.com>
 <20121116165606.GE8218@suse.de>
 <20121116173755.GB4697@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20121116173755.GB4697@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Nov 16, 2012 at 06:37:55PM +0100, Ingo Molnar wrote:
> 
> * Mel Gorman <mgorman@suse.de> wrote:
> 
> > > AFAICS, this portion of numa/core:
> > > 
> > > c740b1cccdcb x86/mm: Completely drop the TLB flush from ptep_set_access_flags()
> > 
> > We share this.
> > 
> > > 02743c9c03f1 mm/mpol: Use special PROT_NONE to migrate pages
> > 
> > hard-codes prot_none
> 
> I prefer any arch support extensions to be done in the patch 
> that adds that specific arch support.
> 
> That way we can consider the pros and cons of abstraction. Also 
> see further below.
> 

Using _PAGE_NUMA mapped onto _PROT_NONE does not prevent the same
abstraction.

> > > cd203e33c39d mm/mpol: Add MPOL_MF_NOOP
> > 
> > I have a patch that backs this out on the grounds that I don't 
> > think we have adequately discussed if it was the correct 
> > userspace interface. I know Peter put a lot of time into it so 
> > it's probably correct but without man pages or spending time 
> > writing an example program that used it, I played safe.
> 
> I'm fine with not exposing it to user-space.
> 

Ok.

> > > Mel, could you please work on this basis, or point out the 
> > > bits you don't agree with so I can fix it?
> > 
> > My main hangup is the prot_none choice and I know it's 
> > something we have butted heads on without progress. [...]
> 
> It's the basic KISS concept - I think you are over-designing 
> this. An architecture opts in to the new, generic code via 
> doing:
> 
>   select ARCH_SUPPORTS_NUMA_BALANCING
> 
> ... if it cannot enable that then it will extend the core code 
> in *very* visible ways.
> 

It won't kill them to decide if they really want to use _PAGE_NUMA or
not. The fact that the generic helpers end up being a few instructions
is nice although you probably could do the same with some juggling.

> > [...] I feel it is a lot cleaner to have the _PAGE_NUMA bit 
> > (even if it's PROT_NONE underneath) and the helpers avoid 
> > function calls where possible. It also made the PMD handling 
> > sortof straight-forward and allowed the batching taking of the 
> > PTL and migration if the pages in the PMD were all on the same 
> > node. I liked this.
> > 
> > Yours is closer to what the architecture does and can use 
> > change_protect() with very few changes but on balance I did 
> > not find this a compelling alternative.
> 
> IMO here you are on the wrong side of history as well.
> 
> For example reusing change_protection() *already* uncovered 
> useful optimizations to the generic code:
> 
>    http://comments.gmane.org/gmane.linux.kernel.mm/89707
> 
> (regardless of how this particular change_protection() 
>  optimization will look like.)
> 
> that optimization would not have happened with your open-coded 
> change_protection() variant plain and simple.
> 

As I said before, very little actually stops me using change_protection if
_PAGE_NUMA == _PAGE_NONE. The only reason I didn't convert yet is because
I wanted to see what the full set of requirements were. Right now they
are simple;

1. Something to avoid unnecessary TLB flushes if there are no updates
2. Return if all the pages underneath are on the same node or not so
   that pmd_numa can be set if desired
3. Collect stats on PTE updates

1 should already be there. 2 would be trivial. 3 should also be fairly
trivial with some jiggery pokery.

A conversion is not a fundamental problem. If an arch cannot use _PAGE_NONE
they will need to implement their own version of change_prot_numa() but
that in itself should be sufficient discouragment.

If an arch cannot use _PAGE_NONE in your case, it's a retrofit to find
all the places that use prot_none and see if they really mean prot_none
or if they meant prot_numa.

> So, to put it bluntly, you are not only doing a stupid thing, 
> you are doing an actively harmful thing here...
> 

Great, calling me stupid is going to help.

Is your major problem the change_page_numa() part? If so, I can fix
that and adjust change_protection in the way I need.

> If you fix that then most of the differences between your tree 
> and numa/core disappears. You'll end up very close to:
> 

MIGRATE_FAULT is still there.

The lack of batch handling of a PMD fault may also be a problem. Right
now you only handle transparent hugepages and then depend on being able to
natively migrate them to avoid a big hit. In my case it is possible to mark
a PMD and deal with it as a single fault even if it's not a transparent
hugepage. This batches the taking of the PTL and migration of pages. This
will trap less although the guy that does trap takes a heavier hit. Maybe
this will work out best, maybe not, but it's possible.

An optimisation of this would be that if all pages in a PMD are on the same
node then only set the PMD. On the next fault if the fault is properly
placed it's one PMD update and the fault is complete. If it's misplaced
then one page needs to migrate and the pte_numa needs to be set on all the
pages below. On a fully converged workload this will be faster as we'll take
one PMD fault instead of 512 PTE faults reducing overall system CPU usage.

There are also the stats that track PTE updates, faults and migrations
which allow a user to make an estimation for how expensive automatic
balancing is from /proc/vmstat. This will help debugging user problems,
possibly without profiling.

>   - rebasing numa/core pretty much as-is
>   + add your migrate_displaced() function
>   - remove the user-facing lazy migration facilities.
>   + inline pte_numa()/pmd_numa() if you think it's beneficial
> 

+ regular pmd batch handling
+ stats on PTE updates and faults to estimate costs from /proc/vmstat

> If that works for you I'll test and backmerge all such deltas 
> quickly and we can move on.
> 

Or if you're willing to backmerge then why not rebase the policy bits on
top of the basic migration policy picking some point between here
depending on what you'd like to do?

 mm: numa: Rate limit setting of pte_numa if node is saturated
 sched: numa: Slowly increase the scanning period as NUMA faults are handled
 mm: numa: Introduce last_nid to the page frame
 mm: numa: Use a two-stage filter to restrict pages being migrated for unlikely task<->node relationships
 sched: numa: Introduce tsk_home_node()
 sched: numa: Make find_busiest_queue() a method
 sched: numa: Implement home-node awareness
 sched: numa: Introduce per-mm and per-task structures

So that way, not only can we see the logical progression of how your
stuff works but also compare it to a basic policy that is not
particularly smart to make sure we are actually going to the right
direction.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
