Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id 737D46B005D
	for <linux-mm@kvack.org>; Mon, 19 Nov 2012 11:29:17 -0500 (EST)
Date: Mon, 19 Nov 2012 16:29:09 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 00/27] Latest numa/core release, v16
Message-ID: <20121119162909.GL8218@suse.de>
References: <1353291284-2998-1-git-send-email-mingo@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1353291284-2998-1-git-send-email-mingo@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>

On Mon, Nov 19, 2012 at 03:14:17AM +0100, Ingo Molnar wrote:
> I'm pleased to announce the latest version of the numa/core tree.
> 
> Here are some quick, preliminary performance numbers on a 4-node,
> 32-way, 64 GB RAM system:
> 
>   CONFIG_NUMA_BALANCING=y
>   -----------------------------------------------------------------------
>   [ seconds         ]    v3.7  AutoNUMA   |  numa/core-v16    [ vs. v3.7]
>   [ lower is better ]   -----  --------   |  -------------    -----------
>                                           |
>   numa01                340.3    192.3    |      139.4          +144.1%
>   numa01_THREAD_ALLOC   425.1    135.1    |      121.1          +251.0%
>   numa02                 56.1     25.3    |       17.5          +220.5%
>                                           |
>   [ SPECjbb transactions/sec ]            |
>   [ higher is better         ]            |
>                                           |
>   SPECjbb single-1x32    524k     507k    |       638k           +21.7%
>   -----------------------------------------------------------------------
> 

I was not able to run a full sets of tests today as I was distracted so
all I have is a multi JVM comparison. I'll keep it shorter than average

                          3.7.0                 3.7.0
                 rc5-stats-v4r2   rc5-schednuma-v16r1
TPut   1     101903.00 (  0.00%)     77651.00 (-23.80%)
TPut   2     213825.00 (  0.00%)    160285.00 (-25.04%)
TPut   3     307905.00 (  0.00%)    237472.00 (-22.87%)
TPut   4     397046.00 (  0.00%)    302814.00 (-23.73%)
TPut   5     477557.00 (  0.00%)    364281.00 (-23.72%)
TPut   6     542973.00 (  0.00%)    420810.00 (-22.50%)
TPut   7     540466.00 (  0.00%)    448976.00 (-16.93%)
TPut   8     543226.00 (  0.00%)    463568.00 (-14.66%)
TPut   9     513351.00 (  0.00%)    468238.00 ( -8.79%)
TPut   10    484126.00 (  0.00%)    457018.00 ( -5.60%)
TPut   11    467440.00 (  0.00%)    457999.00 ( -2.02%)
TPut   12    430423.00 (  0.00%)    447928.00 (  4.07%)
TPut   13    445803.00 (  0.00%)    434823.00 ( -2.46%)
TPut   14    427388.00 (  0.00%)    430667.00 (  0.77%)
TPut   15    437183.00 (  0.00%)    423746.00 ( -3.07%)
TPut   16    423245.00 (  0.00%)    416259.00 ( -1.65%)
TPut   17    417666.00 (  0.00%)    407186.00 ( -2.51%)
TPut   18    413046.00 (  0.00%)    398197.00 ( -3.59%)

This version of the patches manages to cripple performance entirely. I
do not have a single JVM comparison available as the machine has been in
use during the day. I accept that it is very possible that the single
JVM figures are better.

SPECJBB PEAKS
                                       3.7.0                      3.7.0
                              rc5-stats-v4r2        rc5-schednuma-v16r1
 Expctd Warehouse                   12.00 (  0.00%)                   12.00 (  0.00%)
 Expctd Peak Bops               430423.00 (  0.00%)               447928.00 (  4.07%)
 Actual Warehouse                    8.00 (  0.00%)                    9.00 ( 12.50%)
 Actual Peak Bops               543226.00 (  0.00%)               468238.00 (-13.80%)

Peaks at a higher number of warehouses but actual peak throughput is
hurt badly.

MMTests Statistics: duration
               3.7.0       3.7.0
        rc5-stats-v4r2rc5-schednuma-v16r1
User       203918.23   176061.11
System        141.06    24846.23
Elapsed      4979.65     4964.45

System CPU usage.

MMTests Statistics: vmstat

No meaningful stats are available with your series.

> On my NUMA system the numa/core tree now significantly outperforms both
> the vanilla kernel and the AutoNUMA (v28) kernel, in these benchmarks.
> No NUMA balancing kernel has ever performed so well on this system.
> 

Maybe on your machine and maybe on your specjbb configuration it works
well. But for my machine and for a multi JVM configuration, it hurts
quite badly.

> It is notable that workloads where 'private' processing dominates
> (numa01_THREAD_ALLOC and numa02) are now very close to bare metal
> hard binding performance.
> 
> These are the main changes in this release:
> 
>  - There are countless performance improvements. The new shared/private
>    distinction metric we introduced in v15 is now further refined and
>    is used in more places within the scheduler to converge in a better
>    and more directed fashion.
> 

Great.

>  - I restructured the whole tree to make it cleaner, to simplify its
>    mm/ impact and in general to make it more mergable. It now includes
>    either agreed-upon patches, or bare essentials that are needed to
>    make the CONFIG_NUMA_BALANCING=y feature work. It is fully bisect
>    tested - it builds and works at every point.
> 

It is a misrepresentation to say that all these patches have been agreed
upon.

You are still using MIGRATE_FAULT which has not been agreed upon at
all.

While you have renamed change_prot_none to change_prot_numa, it still
effectively hard-codes PROT_NONE. Even if an architecture redefines
pte_numa to use a bit other than _PAGE_PROTNONE it'll still not work
because change_protection() will not recognise it.

I still maintain that THP native migration was introduced too early now
it's worse because you've collapsed it with another patch. The risk is
that you might be depending on THP migration to reduce overhead for the
autonumabench test cases. I've said already that I believe that the correct
thing to do here is to handle regular PMDs in batch where possible and add
THP native migration as an optimisation on top. This avoids us accidentally
depending on THP to reduce system CPU usage.

While the series may be bisectable, it still is an all-or-nothing
approach. Consider "sched, numa, mm: Add the scanning page fault machinery"
for example. Despite its name it is very much orientated around schednuma
and adds the fields schednuma requires. This is a small example. The
bigger example continues to be "sched: Add adaptive NUMA affinity support"
which is a monolithic patch that introduces .... basically everything. It
would be extremely difficult to retrofit an alternative policy on top of
this and to make an apples-to-apples comparison.  My whole point about
bisection was that we would have three major points that could be bisected

1. vanilla kernel
2. one set of optimisations, basic stats
3. basic placement policy
4. more optimisations if necessary
5. complex placement policy

The complex placement policy it would either be schednuma, autonuma or some
combination and it could be evaluated in terms of a basic placement policy
-- how much better does it perform? How much system overhead does it add?
Otherwise it's too easy to fall into a trap where a complex placement policy
for the tested workloads hides all the cost of the underlying machinery
and then falls apart when tested by a larger number of users. If/when the
placement policy fails the system gets majorly bogged down and it'll not
be possible to break up the series in any meaningful way to see where
the problem was introduced. I'm running out of creative ways to repeat
myself on this.

>  - The hard-coded "PROT_NONE" feature that reviewers complained about
>    is now factored out and selectable on a per architecture basis.
>    (the arch porting aspect of this is untested, but the basic fabric
>     is there and should be pretty close to what we need.)
> 
>    The generic PROT_NONE based facility can be used by architectures
>    to prototype this feature quickly.
> 

They'll also need to alter change_protection() or reimplement it. It's
still effectively hard-coded although it's getting better in this
regard.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
