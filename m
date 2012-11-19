Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id 93B3D6B005D
	for <linux-mm@kvack.org>; Mon, 19 Nov 2012 14:13:45 -0500 (EST)
Received: by mail-ea0-f169.google.com with SMTP id a12so1652205eaa.14
        for <linux-mm@kvack.org>; Mon, 19 Nov 2012 11:13:43 -0800 (PST)
Date: Mon, 19 Nov 2012 20:13:39 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 00/27] Latest numa/core release, v16
Message-ID: <20121119191339.GA11701@gmail.com>
References: <1353291284-2998-1-git-send-email-mingo@kernel.org>
 <20121119162909.GL8218@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121119162909.GL8218@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>


* Mel Gorman <mgorman@suse.de> wrote:

> On Mon, Nov 19, 2012 at 03:14:17AM +0100, Ingo Molnar wrote:
> > I'm pleased to announce the latest version of the numa/core tree.
> > 
> > Here are some quick, preliminary performance numbers on a 4-node,
> > 32-way, 64 GB RAM system:
> > 
> >   CONFIG_NUMA_BALANCING=y
> >   -----------------------------------------------------------------------
> >   [ seconds         ]    v3.7  AutoNUMA   |  numa/core-v16    [ vs. v3.7]
> >   [ lower is better ]   -----  --------   |  -------------    -----------
> >                                           |
> >   numa01                340.3    192.3    |      139.4          +144.1%
> >   numa01_THREAD_ALLOC   425.1    135.1    |      121.1          +251.0%
> >   numa02                 56.1     25.3    |       17.5          +220.5%
> >                                           |
> >   [ SPECjbb transactions/sec ]            |
> >   [ higher is better         ]            |
> >                                           |
> >   SPECjbb single-1x32    524k     507k    |       638k           +21.7%
> >   -----------------------------------------------------------------------
> > 
> 
> I was not able to run a full sets of tests today as I was 
> distracted so all I have is a multi JVM comparison. I'll keep 
> it shorter than average
> 
>                           3.7.0                 3.7.0
>                  rc5-stats-v4r2   rc5-schednuma-v16r1

Thanks for the testing - I'll wait for your full results to see 
whether the other regressions you reported before are 
fixed/improved.

Exactly what tree/commit does "rc5-schednuma-v16r1" mean?

I am starting to have doubts about your testing methods. There 
does seem to be some big disconnect between your testing and 
mine - and I think we should clear that up by specifying exactly 
*what* you have tested. Did you rebase my tree in any fashion?

You can find what I tested in tip:master and I'd encourage you 
to test that too.

Other people within Red Hat have tested these same workloads as 
well, on similarly sided (and even larger) systems as yours, and 
they have already reported to me (much) improved numbers, 
including improvements in the multi-JVM SPECjbb load that you 
are concentrating on ...

> >  - I restructured the whole tree to make it cleaner, to 
> >    simplify its mm/ impact and in general to make it more 
> >    mergable. It now includes either agreed-upon patches, or 
> >    bare essentials that are needed to make the 
> >    CONFIG_NUMA_BALANCING=y feature work. It is fully bisect 
> >    tested - it builds and works at every point.
> 
> It is a misrepresentation to say that all these patches have 
> been agreed upon.

That has not been claimed, please read the sentence above.

> You are still using MIGRATE_FAULT which has not been agreed 
> upon at all.

See my followup patch yesterday.

> While you have renamed change_prot_none to change_prot_numa, 
> it still effectively hard-codes PROT_NONE. Even if an 
> architecture redefines pte_numa to use a bit other than 
> _PAGE_PROTNONE it'll still not work because 
> change_protection() will not recognise it.

This is not how it works.

The new generic PROT_NONE scheme is that an architecture that 
wants to reuse the generic PROT_NONE code can define:

  select ARCH_SUPPORTS_NUMA_BALANCING

and can set:

  select ARCH_WANTS_NUMA_GENERIC_PGPROT

and it will get the generic code very easily. This is what x86 
uses now. No architecture changes needed beyond these two lines 
of Kconfig enablement.

If an architecture wants to provide its own open-coded, optimizd 
variant, it can do so by not defining 
ARCH_SUPPORTS_NUMA_BALANCING, and by offering the following 
methods:

      bool pte_numa(struct vm_area_struct *vma, pte_t pte);
      pte_t pte_mknuma(struct vm_area_struct *vma, pte_t pte);
      bool pmd_numa(struct vm_area_struct *vma, pmd_t pmd);
      pgprot_t pgprot_modify(pgprot_t oldprot, pgprot_t newprot)
      unsigned long change_prot_numa(struct vm_area_struct *vma, unsigned long start, unsigned long

I have not tested the arch-defined portion but barring trivial 
problems it should work. We can extend the list of methods if 
you think more is needed, and we can offer library functions for 
architectures that want to share some but not all generic code - 
I'm personally happy with x86 using change_protection().

I think this got bikeshed painted enough already.

> I still maintain that THP native migration was introduced too 
> early now it's worse because you've collapsed it with another 
> patch. The risk is that you might be depending on THP 
> migration to reduce overhead for the autonumabench test cases. 
> I've said already that I believe that the correct thing to do 
> here is to handle regular PMDs in batch where possible and add 
> THP native migration as an optimisation on top. This avoids us 
> accidentally depending on THP to reduce system CPU usage.

Have you disabled THP in your testing of numa/core???

I think we need to stop the discussion now and clear up exactly 
*what* you have tested. Commit ID and an exact description of 
testing methodology please ...

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
