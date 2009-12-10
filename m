Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 9E6A56B003D
	for <linux-mm@kvack.org>; Thu, 10 Dec 2009 02:55:05 -0500 (EST)
Date: Thu, 10 Dec 2009 08:54:54 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [RFC mm][PATCH 2/5] percpu cached mm counter
Message-ID: <20091210075454.GB25549@elte.hu>
References: <20091210163115.463d96a3.kamezawa.hiroyu@jp.fujitsu.com>
 <20091210163448.338a0bd2.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091210163448.338a0bd2.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, cl@linux-foundation.org, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, minchan.kim@gmail.com
List-ID: <linux-mm.kvack.org>


* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> Now, mm's counter information is updated by atomic_long_xxx() 
> functions if USE_SPLIT_PTLOCKS is defined. This causes cache-miss when 
> page faults happens simultaneously in prural cpus. (Almost all 
> process-shared objects is...)
> 
> Considering accounting per-mm page usage more, one of problems is cost 
> of this counter.

I'd really like these kinds of stats available via the tool you used to 
develop this patchset:

>  After:
>     Performance counter stats for './multi-fault 2' (5 runs):
> 
>        46997471  page-faults                ( +-   0.720% )
>      1004100076  cache-references           ( +-   0.734% )
>       180959964  cache-misses               ( +-   0.374% )
>    29263437363580464  bus-cycles                 ( +-   0.002% )
> 
>    60.003315683  seconds time elapsed   ( +-   0.004% )
> 
>    cachemiss/page faults is reduced from 4.55 miss/faults to be 3.85miss/faults

I.e. why not expose these stats via perf events and counts as well, 
beyond the current (rather minimal) set of MM stats perf supports 
currently?

That way we'd get a _lot_ of interesting per task mm stats available via 
perf stat (and maybe they can be profiled as well via perf record), and 
we could perhaps avoid uglies like having to hack hooks into sched.c:

> +	/*
> +	 * sync/invaldidate per-cpu cached mm related information
> +	 * before taling rq->lock. (see include/linux/mm.h)

(minor typo: s/taling/taking )

> +	 */
> +	sync_mm_counters_atomic();
>  
>  	spin_lock_irq(&rq->lock);
>  	update_rq_clock(rq);

It's not a simple task i guess since this per mm counting business has 
grown its own variant which takes time to rearchitect, plus i'm sure 
there's performance issues to solve if such a model is exposed via perf, 
but users and developers would be _very_ well served by such 
capabilities:

 - clean, syscall based API available to monitor tasks, workloads and 
   CPUs. (or the whole system)

 - sampling (profiling)

 - tracing, post-process scripting via Perl plugins

etc.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
