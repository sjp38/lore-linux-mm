Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id C52226B0044
	for <linux-mm@kvack.org>; Wed, 21 Mar 2012 18:54:29 -0400 (EDT)
Date: Wed, 21 Mar 2012 23:52:43 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [RFC] AutoNUMA alpha6
Message-ID: <20120321225242.GL24602@redhat.com>
References: <20120316144028.036474157@chello.nl>
 <20120316182511.GJ24602@redhat.com>
 <87k42edenh.fsf@danplanet.com>
 <20120321021239.GQ24602@redhat.com>
 <87fwd2d2kp.fsf@danplanet.com>
 <20120321124937.GX24602@redhat.com>
 <87limtboet.fsf@danplanet.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87limtboet.fsf@danplanet.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Smith <danms@us.ibm.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Mar 21, 2012 at 03:05:30PM -0700, Dan Smith wrote:
> something isn't right about my setup, point it out. I've even gone so
> far as to print debug from inside numa01 and numa02 to make sure the
> -DFOO's are working.

That's good check indeed.

> Re-running all the configurations with THP disabled seems to yield very
> similar results to what I reported before:
> 
>         mainline autonuma numasched hard inverse same_node
> numa01  483      366      335       335  483     483

I assume you didn't run the numa01_same_node on the "numasched" kernel
here.

Now if you want I can fix this and boost autonuma for the numa01
without any parameter.

With the first 5 sec of runtime, I thought I'd be ok with the
MPOL_DEFAULT behavior unchanged (where autonuma behaves as a bypass
for those initial seconds).

Now if we're going to measure who places memory better within the
first 10 seconds of startup, I may have to resurrect
autonuma_balance_blind. I disabled that function because I didn't want
blind heuristics that may backfire for some apps.

It's really numa01_same node the interesting benchmark meant
to start from a fixed position and it is the thing that really
exercises ability of the algorithm to converge.

> The inverse and same_node numbers above are on mainline, and both are
> lower on autonuma and numasched:
> 
>            numa01_hard numa01_inverse numa01_same_node
> mainline   335         483            483
> autonuma   335         356            377
> numasched  335         375            491

In these numbers the numa01_inverse column is suspect for
autonuma/numasched.

The numa01_inverse and numa01_hard you should duplicate it from
mainline to be sure. That is an "hardware" not software measurement.

The exact numbers shall be like this:

            numa01_hard numa01_inverse numa01_same_node
 mainline   335         483            483
 autonuma   335         483            377
 numasched  335         483            491



And it pretty much matches what I get. Well I tried many times again
but I couldn't complete any more numa01 runs with numasched, I was
real lucky last night. It never ends... it becomes incredibly slow and
misbehave until it's almost unusable and I reboot it. So I stopped
worrying about benchmarking numasched as it's too unstable for that.

> I also ran your numa02, which seems to correlate to your findings:
> 
>         mainline autonuma numasched hard inverse
> numa02  54       42       55        37   53
> 
> So, I'm not seeing the twofold penalty of running with numasched, and in
> fact, it seems to basically do no worse than current mainline (within
> the error interval). However, I hope the matching trend somewhat
> validates the fact that I'm running your stuff correctly.

I still see it even in your numbers:

numasched 55
mainline  54
autonuma  42
hard      37

numasched 491
mainline  483
autonuma  377
hard      335

Yes I think you're running everything correctly.

I'm only wondering why numa01_inverse is faster than on upstream when
run on autonuma (and numasched), I'll try to reproduce it. I thought I
wasn't messing with anything except MPOL_DEFAULT but I'll have to
re-check that.

> I also ran your numa01 with my system clamped to 16G and saw no change
> in the positioning of the metrics (i.e. same_node was still higher than
> inverse and everything was shifted slightly up linearly).

Yes it shall run fine on all kernels. But for me running that on
numasched (and only on numasched) never ends.

> Well, it's bad in either case, because it means either it's too
> temperamental to behave the same on two similar but differently-sized
> machines, or that it doesn't properly balance the load for machines with
> differing topologies.

Your three numbers of mainline looked ok, it's still strange that
numa01_same_node is identical to numa01_inverse_bind though. It
shoudln't. same_node uses 1 numa node. inverse uses both nodes but
always with remote memory. It's surprising to see an identical value
there.

> I'll be glad to post details of the topology if you tell me specifically
> what you want (above and beyond what I've already posted).

It should look like this to be correct for my -DHARD_BIND and
-DINVERSE_BIND to work as intended:

numactl --hardware

available: 2 nodes (0-1)
node 0 cpus: 0 1 2 3 4 5 12 13 14 15 16 17
node 1 cpus: 6 7 8 9 10 11 18 19 20 21 22 23

If your topology is different than above, then updates are required to
numa*.c.

> Me too. Unless you have specific things for me to try, it's probably
> best to let someone else step in with more interesting and
> representative benchmarks, as all of my numbers seem to continue to
> point in the same direction...

It's all good! Thanks for the help.

If you want to keep benchmarking I'm about to upload the autonuma-dev
branch (same git-tree) with alpha8 based on post-3.3 scheduler
codebase and with some more fix.

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
