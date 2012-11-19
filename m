Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id 972536B0074
	for <linux-mm@kvack.org>; Mon, 19 Nov 2012 16:18:11 -0500 (EST)
Date: Mon, 19 Nov 2012 21:18:04 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 00/27] Latest numa/core release, v16
Message-ID: <20121119211804.GM8218@suse.de>
References: <1353291284-2998-1-git-send-email-mingo@kernel.org>
 <20121119162909.GL8218@suse.de>
 <20121119191339.GA11701@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20121119191339.GA11701@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>

On Mon, Nov 19, 2012 at 08:13:39PM +0100, Ingo Molnar wrote:
> 
> * Mel Gorman <mgorman@suse.de> wrote:
> 
> > On Mon, Nov 19, 2012 at 03:14:17AM +0100, Ingo Molnar wrote:
> > > I'm pleased to announce the latest version of the numa/core tree.
> > > 
> > > Here are some quick, preliminary performance numbers on a 4-node,
> > > 32-way, 64 GB RAM system:
> > > 
> > >   CONFIG_NUMA_BALANCING=y
> > >   -----------------------------------------------------------------------
> > >   [ seconds         ]    v3.7  AutoNUMA   |  numa/core-v16    [ vs. v3.7]
> > >   [ lower is better ]   -----  --------   |  -------------    -----------
> > >                                           |
> > >   numa01                340.3    192.3    |      139.4          +144.1%
> > >   numa01_THREAD_ALLOC   425.1    135.1    |      121.1          +251.0%
> > >   numa02                 56.1     25.3    |       17.5          +220.5%
> > >                                           |
> > >   [ SPECjbb transactions/sec ]            |
> > >   [ higher is better         ]            |
> > >                                           |
> > >   SPECjbb single-1x32    524k     507k    |       638k           +21.7%
> > >   -----------------------------------------------------------------------
> > > 
> > 
> > I was not able to run a full sets of tests today as I was 
> > distracted so all I have is a multi JVM comparison. I'll keep 
> > it shorter than average
> > 
> >                           3.7.0                 3.7.0
> >                  rc5-stats-v4r2   rc5-schednuma-v16r1
> 
> Thanks for the testing - I'll wait for your full results to see 
> whether the other regressions you reported before are 
> fixed/improved.
> 

Ok.

In response to one of your later questions, I found that I had in fact
disabled THP without properly reporting it. I had configured MMTests to
run specjbb with "base" pages which is the default taken from the specjvm
configuration file. I had noted in different reports that no THP was used
and that THP was not a factor for those tests but had not properly checked
why that was.

However, this also means that *all* the tests disabled THP. Vanilla kernel,
balancenuma and autonuma all ran with THP disabled. The comparisons are
still valid but failing to report the lack of THP was a major mistake.

> Exactly what tree/commit does "rc5-schednuma-v16r1" mean?
> 

Kernel 3.7-rc5
tip/sched/core from when it was last pulled
your patches as posted in this thread

JVM is Oracle JVM
java version "1.7.0_07"
Java(TM) SE Runtime Environment (build 1.7.0_07-b10)
Java HotSpot(TM) 64-Bit Server VM (build 23.3-b01, mixed mode)

I had been thinking that differences in the JVMs might be a factor but it
almost certainly because I had configured mmtests to disable THP for the
specjbb test. Again, I'm sorry that this was not properly identified and
reported by me but will reiterate that all tests were run identically.

> I am starting to have doubts about your testing methods. There 
> does seem to be some big disconnect between your testing and 
> mine - and I think we should clear that up by specifying exactly 
> *what* you have tested.

And the difference was in test methods - specifically I disabled THP.

FWIW, what I'm testing is implemented via mmtests 0.07 which I released a
few days ago. I use the same configuration file each time and the kernel
.config only differs in the name of the numa balancing option it needs
to enable. The THP disabling was a screw-up but it was the same screw up
every time.

> Did you rebase my tree in any fashion?
> 

No.

However, what I will be running next will be rebased on top of rc6. I am
not expecting that to make any difference.

> You can find what I tested in tip:master and I'd encourage you 
> to test that too.
> 

I will.

> Other people within Red Hat have tested these same workloads as 
> well, on similarly sided (and even larger) systems as yours, and 
> they have already reported to me (much) improved numbers, 
> including improvements in the multi-JVM SPECjbb load that you 
> are concentrating on ...
> 

It almost certainly came down to THP and not the JVM. Can you or one
other other testers try with THP disabled and see what they find?

> > >  - I restructured the whole tree to make it cleaner, to 
> > >    simplify its mm/ impact and in general to make it more 
> > >    mergable. It now includes either agreed-upon patches, or 
> > >    bare essentials that are needed to make the 
> > >    CONFIG_NUMA_BALANCING=y feature work. It is fully bisect 
> > >    tested - it builds and works at every point.
> > 
> > It is a misrepresentation to say that all these patches have 
> > been agreed upon.
> 
> That has not been claimed, please read the sentence above.
> 

Ok yes, it is one or the other.

> > You are still using MIGRATE_FAULT which has not been agreed 
> > upon at all.
> 
> See my followup patch yesterday.
> 

I missed the follow-up patch. I was looking at the series as-posted.

> > While you have renamed change_prot_none to change_prot_numa, 
> > it still effectively hard-codes PROT_NONE. Even if an 
> > architecture redefines pte_numa to use a bit other than 
> > _PAGE_PROTNONE it'll still not work because 
> > change_protection() will not recognise it.
> 
> This is not how it works.
> 
> The new generic PROT_NONE scheme is that an architecture that 
> wants to reuse the generic PROT_NONE code can define:
> 
>   select ARCH_SUPPORTS_NUMA_BALANCING
> 
> and can set:
> 
>   select ARCH_WANTS_NUMA_GENERIC_PGPROT
> 
> and it will get the generic code very easily. This is what x86 
> uses now. No architecture changes needed beyond these two lines 
> of Kconfig enablement.
> 
> If an architecture wants to provide its own open-coded, optimizd 
> variant, it can do so by not defining 
> ARCH_SUPPORTS_NUMA_BALANCING, and by offering the following 
> methods:
> 
>       bool pte_numa(struct vm_area_struct *vma, pte_t pte);
>       pte_t pte_mknuma(struct vm_area_struct *vma, pte_t pte);
>       bool pmd_numa(struct vm_area_struct *vma, pmd_t pmd);
>       pgprot_t pgprot_modify(pgprot_t oldprot, pgprot_t newprot)
>       unsigned long change_prot_numa(struct vm_area_struct *vma, unsigned long start, unsigned long
> 

Ah ok. The arch would indeed need change_prot_numa().

> I have not tested the arch-defined portion but barring trivial 
> problems it should work. We can extend the list of methods if 
> you think more is needed, and we can offer library functions for 
> architectures that want to share some but not all generic code - 
> I'm personally happy with x86 using change_protection().
> 

FWIW, I don't think the list needs to be extended. I'm still disappointed
that the pte_numa and friend implementations are relatively heavy and
require a function call to vm_get_page_prot(). I'm also disappointed
that regularly PMDs cannot be easily handled in batch without further
modification.

On the batch PMD thing, I'm in the process of converting to using
change_protection. Preserving all the logic from the old change_prot_numa()
is a bit of a mess right now but so far I've found that at least two major
factors are;

1. If page_mapcount > 1 pages are marked pte_numa then the overhead
   increases a lot. This is partially due to the placement policy being
   really dumb and unable to handle shared pages.

2. With a partial series (I don't have test results with a full series
   yet) I find that if I do not set pmd_numa and batch handle the faults
   that it takes 5 times longer to complete the numa01 test. This is even
   slower than the vanilla kernel and is probably fault overhead.

In both cases the overhead could be overcome by having a smart placement
policy and then scanning backoff logic to reduce the number of faults
incurred. If for some reason the scanning rate cannot be reduced because
the placement policy bounces pages around nodes en the CPU usage will go
through the roof setting all the PTEs and handling the faults.

> I think this got bikeshed painted enough already.
> 
> > I still maintain that THP native migration was introduced too 
> > early now it's worse because you've collapsed it with another 
> > patch. The risk is that you might be depending on THP 
> > migration to reduce overhead for the autonumabench test cases. 
> > I've said already that I believe that the correct thing to do 
> > here is to handle regular PMDs in batch where possible and add 
> > THP native migration as an optimisation on top. This avoids us 
> > accidentally depending on THP to reduce system CPU usage.
> 
> Have you disabled THP in your testing of numa/core???
> 

As it turned out, yes, I did disable THP. The vmstats I posted in other
reports all showed that no THPs were used because of this.

If your internal testers run with THP disabled, it would be interesting
to know if they see similar regressions. If they do, it implies that the
performance of schednuma depends on THP. If they do not, something else
is also making a big difference.

The temptation is to just ignore the THP problem but if workloads cannot
use THP or the system gets into a state where it cannot allocate THP
then performance will be badly hurt. It'll be hard to spot that the lack
of THP is what is causing the regression.

> I think we need to stop the discussion now and clear up exactly 
> *what* you have tested. Commit ID and an exact description of 
> testing methodology please ...
> 

Kernel and JVM used have already been mentioned. Testing methodology is
as implemented in mmtests 0.07. The configuration file for multi JVMs is
configs/config-global-dhp__jvm-specjbb and sets SPECJBB_PAGESIZES="base"
which is what disabled THP.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
