Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id 252906B0044
	for <linux-mm@kvack.org>; Wed, 21 Mar 2012 18:05:34 -0400 (EDT)
From: Dan Smith <danms@us.ibm.com>
Subject: Re: [RFC] AutoNUMA alpha6
References: <20120316144028.036474157@chello.nl>
	<20120316182511.GJ24602@redhat.com> <87k42edenh.fsf@danplanet.com>
	<20120321021239.GQ24602@redhat.com> <87fwd2d2kp.fsf@danplanet.com>
	<20120321124937.GX24602@redhat.com>
Date: Wed, 21 Mar 2012 15:05:30 -0700
Message-ID: <87limtboet.fsf@danplanet.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

AA> HARD and INVERSE should be the min and max you get.

AA> I would ask you before you test AutoNUMA again, or numasched again,
AA> to repeat this "HARD" vs "INVERSE" vs "NO_BIND_FORCE_SAME_MODE"
AA> benchmark and be sure the above numbers are correct for the above
AA> three cases.

I've always been running all three, knowing that hard and inverse should
be the bounds. Not knowing (until today) what the third was, I wasn't
sure where it was supposed to lie. However, I've yet to see the spread
that you describe, regardless of the configuration. If that means
something isn't right about my setup, point it out. I've even gone so
far as to print debug from inside numa01 and numa02 to make sure the
-DFOO's are working.

Re-running all the configurations with THP disabled seems to yield very
similar results to what I reported before:

        mainline autonuma numasched hard inverse same_node
numa01  483      366      335       335  483     483

The inverse and same_node numbers above are on mainline, and both are
lower on autonuma and numasched:

           numa01_hard numa01_inverse numa01_same_node
mainline   335         483            483
autonuma   335         356            377
numasched  335         375            491

I also ran your numa02, which seems to correlate to your findings:

        mainline autonuma numasched hard inverse
numa02  54       42       55        37   53

So, I'm not seeing the twofold penalty of running with numasched, and in
fact, it seems to basically do no worse than current mainline (within
the error interval). However, I hope the matching trend somewhat
validates the fact that I'm running your stuff correctly.

I also ran your numa01 with my system clamped to 16G and saw no change
in the positioning of the metrics (i.e. same_node was still higher than
inverse and everything was shifted slightly up linearly).

AA> If it's not a benchmarking error or a topology error in
AA> HARD_BIND/INVERSE_BIND, it may be the hardware you're using is very
AA> different. That would be bad news though, I thought you were using
AA> the same common 2 socket exacore setup that I'm using and I wouldn't
AA> have expected such a staggering difference in results (even for HARD
AA> vs INVERSE vs NO_BIND_FORCE_SAME_NODE, even before we put autonuma
AA> or numasched into the equation).

Well, it's bad in either case, because it means either it's too
temperamental to behave the same on two similar but differently-sized
machines, or that it doesn't properly balance the load for machines with
differing topologies.

I'll be glad to post details of the topology if you tell me specifically
what you want (above and beyond what I've already posted).

AA> I hope others will run more benchmarks too on both solution.

Me too. Unless you have specific things for me to try, it's probably
best to let someone else step in with more interesting and
representative benchmarks, as all of my numbers seem to continue to
point in the same direction...

Thanks!

-- 
Dan Smith
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
