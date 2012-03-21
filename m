Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id BB4A56B004A
	for <linux-mm@kvack.org>; Tue, 20 Mar 2012 22:13:22 -0400 (EDT)
Date: Wed, 21 Mar 2012 03:12:39 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [RFC] AutoNUMA alpha6
Message-ID: <20120321021239.GQ24602@redhat.com>
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
> 
> On Peter's modified stream_d test:
> 
>   Autonuma is 35% *slower* than mainline
>   Numasched is 55% faster than mainline

I repeated the benchmark here after applying all Peter's patches in
the same setup where I run this loop of benchmarks on the AutoNUMA
code 24/7 for the last 3 months. So it was pretty quick to do it for
me.

THP was disabled as the only kernel tune tweak to compare apples with
apples (it was already disabled in all my measurements with the
numa01/numa02).

        upstream autonuma numasched hard inverse
numa02  64       45       66        42   81
numa01  491      328      607       321  623 -D THREAD_ALLOC
numa01  305      207      338       196  378 -D NO_BIND_FORCE_SAME_NODE

So give me a break... you must have made a real mess in your
benchmarking. numasched is always doing worse than upstream here, in
fact two times massively worse. Almost as bad as the inverse binds.

Maybe you've more than 16g? I've 16G and that leaves 1G free on both
nodes at the peak load with AutoNUMA. That shall be enough for
numasched too (Peter complained me I waste 80MB on a 16G system, so he
can't possibly be intentionally wasting me 2GB).

In any case your results were already _obviously_ broken without me
having to benchmark numasched to verify, because it's impossible
numasched could be 20% faster than autonuma on numa01, because
otherwise it would mean that numasched is like 18% faster than hard
bindings which is mathematically impossible unless your hardware is
not NUMA or superNUMAbroken.

Also note that I had to even "reboot -f" after the first run of -D
NO_BIND_FORCE_SAME_NODE because otherwise it would never end and it
went 3G in swap already when I rebooted. Maybe a memleak from previous
runs? no idea. After rebooting I run numa01 -D NO_BIND_FORCE_SAME_NODE
after fresh after reboot and after rebooted it looked not in swap. I
just did a "ssh host vmstat 1" to see if it was swapping again and
never ending, and I killed vmstat it after a second, otherwise the
systems are totally undisturbed and there's no cron or anything so the
results are reliable.

I'll repeat the benchmarks for numasched tomorrow with lockdep
disabled (lockdep on or off won't alter autonuma runtime) and to also
run the last numa01+numa02 test. Then I'll update the pdf and
overwrite it so that the pages 3-6 of the pdf will include a 5h column
showing numasched results.

Note that I didn't alter my .config, I just checkout origin/master and
git am the patchset and run make oldconfig (after fixing one trivial
reject in the syscall registration).

Maybe there's a slight chance I won't have to throw autonuma into the
trash after all considering how staggering the difference is.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
