Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 6D5B96B00ED
	for <linux-mm@kvack.org>; Wed, 21 Mar 2012 03:53:54 -0400 (EDT)
Received: by wibhq7 with SMTP id hq7so4968100wib.8
        for <linux-mm@kvack.org>; Wed, 21 Mar 2012 00:53:52 -0700 (PDT)
Date: Wed, 21 Mar 2012 08:53:49 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [RFC] AutoNUMA alpha6
Message-ID: <20120321075349.GB24997@gmail.com>
References: <20120316144028.036474157@chello.nl>
 <20120316182511.GJ24602@redhat.com>
 <87k42edenh.fsf@danplanet.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87k42edenh.fsf@danplanet.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Smith <danms@us.ibm.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org


* Dan Smith <danms@us.ibm.com> wrote:

> On your numa01 test:
> 
>   Autonuma is 22% faster than mainline
>   Numasched is 42% faster than mainline
> 
> On Peter's modified stream_d test:
> 
>   Autonuma is 35% *slower* than mainline
>   Numasched is 55% faster than mainline
> 
> I know that the "real" performance guys here are going to be 
> posting some numbers from more interesting benchmarks soon, 
> but since nobody had answered Andrea's question, I figured I'd 
> do it.

It would also be nice to find and run *real* HPC workloads that 
were not written by Andrea or Peter and which computes something 
non-trivial and real - and then compare the various methods.

Ideally we'd like to measure the two conceptual working set 
corner cases:

  - global working set HPC with a large shared working set:

      - Many types of Monte-Carlo optimizations tend to be
        like this - they have a large shared time series and
        threads compute on those with comparatively little
        private state.

      - 3D rendering with physical modelling: a large, complex
        3D scene set with private worker threads. (much of this 
        tends to be done in GPUs these days though.)

  - private working set HPC with little shared/global working 
    set and lots of per process/thread private memory 
    allocations:

      - Quantum chemistry optimization runs tend to be like this
        with their often gigabytes large matrices.

      - Gas, fluid, solid state and gravitational particle
        simulations - most ab initio methods tend to have very
        little global shared state, each thread iterates its own
        version of the universe.

      - More complex runs of ray tracing as well IIRC.

My impression is that while threading is on the rise due to its 
ease of use, many threaded HPC workloads still fall into the 
second category.

In fact they are often explicitly *turned* into the second 
category at the application level by duplicating shared global 
data explicitly and turning it into per thread local data.

So we need to cover these major HPC usecases - we won't merge 
any of this based on just synthetic benchmarks.

And to default-enable any of this on stock kernels we'd need to 
even more testing and widespread, feel-good speedups in almost 
every key Linux workload... I don't see that happening though, 
so the best we can get are probably some easy and flexible knobs 
for HPC.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
