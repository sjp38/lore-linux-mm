Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f53.google.com (mail-wg0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id D1FF36B0035
	for <linux-mm@kvack.org>; Tue, 17 Dec 2013 06:00:56 -0500 (EST)
Received: by mail-wg0-f53.google.com with SMTP id k14so5892378wgh.20
        for <linux-mm@kvack.org>; Tue, 17 Dec 2013 03:00:56 -0800 (PST)
Received: from mail-ea0-x235.google.com (mail-ea0-x235.google.com [2a00:1450:4013:c01::235])
        by mx.google.com with ESMTPS id jb15si5395536wic.43.2013.12.17.03.00.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 17 Dec 2013 03:00:55 -0800 (PST)
Received: by mail-ea0-f181.google.com with SMTP id m10so2819087eaj.40
        for <linux-mm@kvack.org>; Tue, 17 Dec 2013 03:00:55 -0800 (PST)
Date: Tue, 17 Dec 2013 12:00:51 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 0/4] Fix ebizzy performance regression due to X86 TLB
 range flush v2
Message-ID: <20131217110051.GA27701@gmail.com>
References: <1386964870-6690-1-git-send-email-mgorman@suse.de>
 <CA+55aFyNAigQqBk07xLpf0nkhZ_x-QkBYG8otRzsqg_8A2eg-Q@mail.gmail.com>
 <20131215155539.GM11295@suse.de>
 <20131216102439.GA21624@gmail.com>
 <20131216125923.GS11295@suse.de>
 <20131216134449.GA3034@gmail.com>
 <20131217092124.GV11295@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131217092124.GV11295@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Alex Shi <alex.shi@linaro.org>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Fengguang Wu <fengguang.wu@intel.com>, H Peter Anvin <hpa@zytor.com>, Linux-X86 <x86@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>


* Mel Gorman <mgorman@suse.de> wrote:

> On Mon, Dec 16, 2013 at 02:44:49PM +0100, Ingo Molnar wrote:
> > 
> > * Mel Gorman <mgorman@suse.de> wrote:
> > 
> > > > Whatever we did right in v3.4 we want to do in v3.13 as well - or 
> > > > at least understand it.
> > > 
> > > Also agreed. I started a bisection before answering this mail. It 
> > > would be cooler and potentially faster to figure it out from direct 
> > > analysis but bisection is reliable and less guesswork.
> > 
> > Trying to guess can potentially last a _lot_ longer than a generic, 
> > no-assumptions bisection ...
> > 
> 
> Indeed. In this case, it would have taken me a while to find the correct
> problem because I would consider the affected area to be relatively stable.
> 
> > <SNIP>
> >
> > Does the benchmark execute a fixed amount of transactions per thread? 
> > 
> 
> Yes.
> 
> > That might artificially increase the numeric regression: with more 
> > threads it 'magnifies' any unfairness effects because slower threads 
> > will become slower, faster threads will become faster, as the thread 
> > count increases.
> > 
> > [ That in itself is somewhat artificial, because real workloads tend 
> >   to balance between threads dynamically and don't insist on keeping 
> >   the fastest threads idle near the end of a run. It does not
> >   invalidate the complaint about the unfairness itself, obviously. ]
> > 
> 
> I was wrong about fairness. The first bisection found that cache hotness
> was a more important factor due to a small mistake made in 3.13-rc1
> 
> ---8<---
> sched: Assign correct scheduling domain to sd_llc
> 
> Commit 42eb088e (sched: Avoid NULL dereference on sd_busy) corrected a NULL
> dereference on sd_busy but the fix also altered what scheduling domain it
> used for sd_llc. One impact of this is that a task selecting a runqueue may
> consider idle CPUs that are not cache siblings as candidates for running.
> Tasks are then running on CPUs that are not cache hot.
> 
> This was found through bisection where ebizzy threads were not seeing equal
> performance and it looked like a scheduling fairness issue. This patch
> mitigates but does not completely fix the problem on all machines tested
> implying there may be an additional bug or a common root cause. Here are
> the average range of performance seen by individual ebizzy threads. It
> was tested on top of candidate patches related to x86 TLB range flushing.
> 
> 4-core machine
>                     3.13.0-rc3            3.13.0-rc3
>                        vanilla            fixsd-v3r3
> Mean   1        0.00 (  0.00%)        0.00 (  0.00%)
> Mean   2        0.34 (  0.00%)        0.10 ( 70.59%)
> Mean   3        1.29 (  0.00%)        0.93 ( 27.91%)
> Mean   4        7.08 (  0.00%)        0.77 ( 89.12%)
> Mean   5      193.54 (  0.00%)        2.14 ( 98.89%)
> Mean   6      151.12 (  0.00%)        2.06 ( 98.64%)
> Mean   7      115.38 (  0.00%)        2.04 ( 98.23%)
> Mean   8      108.65 (  0.00%)        1.92 ( 98.23%)
> 
> 8-core machine
> Mean   1         0.00 (  0.00%)        0.00 (  0.00%)
> Mean   2         0.40 (  0.00%)        0.21 ( 47.50%)
> Mean   3        23.73 (  0.00%)        0.89 ( 96.25%)
> Mean   4        12.79 (  0.00%)        1.04 ( 91.87%)
> Mean   5        13.08 (  0.00%)        2.42 ( 81.50%)
> Mean   6        23.21 (  0.00%)       69.46 (-199.27%)
> Mean   7        15.85 (  0.00%)      101.72 (-541.77%)
> Mean   8       109.37 (  0.00%)       19.13 ( 82.51%)
> Mean   12      124.84 (  0.00%)       28.62 ( 77.07%)
> Mean   16      113.50 (  0.00%)       24.16 ( 78.71%)
> 
> It's eliminated for one machine and reduced for another.
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>
> ---
>  kernel/sched/core.c | 5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/kernel/sched/core.c b/kernel/sched/core.c
> index e85cda2..a848254 100644
> --- a/kernel/sched/core.c
> +++ b/kernel/sched/core.c
> @@ -4902,6 +4902,7 @@ DEFINE_PER_CPU(struct sched_domain *, sd_asym);
>  static void update_top_cache_domain(int cpu)
>  {
>  	struct sched_domain *sd;
> +	struct sched_domain *busy_sd = NULL;
>  	int id = cpu;
>  	int size = 1;
>  
> @@ -4909,9 +4910,9 @@ static void update_top_cache_domain(int cpu)
>  	if (sd) {
>  		id = cpumask_first(sched_domain_span(sd));
>  		size = cpumask_weight(sched_domain_span(sd));
> -		sd = sd->parent; /* sd_busy */
> +		busy_sd = sd->parent; /* sd_busy */
>  	}
> -	rcu_assign_pointer(per_cpu(sd_busy, cpu), sd);
> +	rcu_assign_pointer(per_cpu(sd_busy, cpu), busy_sd);
>  
>  	rcu_assign_pointer(per_cpu(sd_llc, cpu), sd);
>  	per_cpu(sd_llc_size, cpu) = size;

Indeed that makes a lot of sense, thanks Mel for tracking down this 
part of the puzzle! Will get your fix to Linus ASAP.

Does this fix also speed up Ebizzy's transaction performance, or is 
its main effect a reduction in workload variation noise?

Also it appears the Ebizzy numbers ought to be stable enough now to 
make the range-TLB-flush measurements more precise?

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
