Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id 587B06B0044
	for <linux-mm@kvack.org>; Tue, 20 Mar 2012 21:01:09 -0400 (EDT)
Date: Wed, 21 Mar 2012 02:00:12 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [RFC] AutoNUMA alpha6
Message-ID: <20120321010012.GO24602@redhat.com>
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
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Mar 20, 2012 at 04:41:06PM -0700, Dan Smith wrote:
> AA> Could you try my two trivial benchmarks I sent on lkml too?
> 
> I just got around to running your numa01 test on mainline, autonuma, and
> numasched.  This is on a 2-socket, 6-cores-per-socket,
> 2-threads-per-core machine, with your test configured to run 24
> threads. I also ran Peter's modified stream_d on all three as well, with
> 24 instances in parallel. I know it's already been pointed out that it's
> not the ideal or end-all benchmark, but I figured it was still
> worthwhile to see if the trend continued.
> 
> On your numa01 test:
> 
>   Autonuma is 22% faster than mainline
>   Numasched is 42% faster than mainline

Can you please disable THP for the benchmarks? Until native THP
migration is available that tends to skews the results because the
migrated memory is not backed by THP.

Or if you prefer not to disable THP, just set
khugepaged/scan_sleep_millisecs to 10.

Can you also build it with?

gcc -DNO_BIND_FORCE_SAME_NODE -O2 -o numa01 kernel/proggy/numa01.c -lnuma -lpthread

If you can run numa02 as well (no special -D flags there), that would
be interesting.

You could report the results of -DHARD_BIND and -DINVERSE_BIND too as
a sanity check.

My raw numbers are:

numa01 -DNO_BIND_FORCE_SAME_NODE (12 thread per process, 2 process)
thread uses shared memory

upstream 3.2	bind	reverse bind	autonuma
305.36	        196.07	378.34	        207.47

What's the percentage if you calculate the same way you did on your
numbers?

(I don't know how you calculated it)

Maybe it was the lack of get -DDNO_BIND_FORCE_SAME_NODE that reduced
the difference but it shouldn't have been so different. Maybe it was a
THP effect dunno.

> On Peter's modified stream_d test:
> 
>   Autonuma is 35% *slower* than mainline
>   Numasched is 55% faster than mainline

Is the modified stream_d posted somewhere? I missed it. How long it
takes to run? What's the measurement error of it? On my tests the
measurement error is within 2%.

In the meantime I've more benchmark data too (including a worst case
kernel build benchmark with autonuma on and off with THP on) and
specjbb (with THP on).

You can jump to slide 8 if you already read the previous pdf:

http://www.kernel.org/pub/linux/kernel/people/andrea/autonuma/autonuma_bench-20120321.pdf

If numbers like above will be be confirmed across the board including
specjbb and pretty much everything I'll happily "rm -r autonuma"
:). For now your numa01 numbers are so out of sync with mine that I
wouldn't take too many conclusions from them, I'm so close to the hard
bindings already in numa01 that there's no way anything else can
perform 20% faster than AutoNUMA.

The numbers in slide 10 of the pdf were provided to me by a
professional, I didn't measure it myself.

And about measurement errors: numa01 is 100% reproducible here, I run
it in a loop for months and not a single time it deviates more than
10sec from the average.

About stream_d, the only chance for autonuma to underperform like -35%
is if you get massive amount of migration going to the wrong place in
a trashing way. I never seen it happening here since I run these
algorithms, but hopefully fixable if that really has happened... So
I'm very interested to gain access to the source of modified stream_d.

Enjoy,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
