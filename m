Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id B22766B004A
	for <linux-mm@kvack.org>; Wed, 21 Mar 2012 08:50:16 -0400 (EDT)
Date: Wed, 21 Mar 2012 13:49:37 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [RFC] AutoNUMA alpha6
Message-ID: <20120321124937.GX24602@redhat.com>
References: <20120316144028.036474157@chello.nl>
 <20120316182511.GJ24602@redhat.com>
 <87k42edenh.fsf@danplanet.com>
 <20120321021239.GQ24602@redhat.com>
 <87fwd2d2kp.fsf@danplanet.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87fwd2d2kp.fsf@danplanet.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Smith <danms@us.ibm.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi Dan,

On Tue, Mar 20, 2012 at 09:01:58PM -0700, Dan Smith wrote:
> AA>         upstream autonuma numasched hard inverse
> AA> numa02  64       45       66        42   81
> AA> numa01  491      328      607       321  623 -D THREAD_ALLOC
> AA> numa01  305      207      338       196  378 -D NO_BIND_FORCE_SAME_NODE
> 
> AA> So give me a break... you must have made a real mess in your
> AA> benchmarking.
> 
> I'm just running what you posted, dude :)

Apologies if it felt like I was attacking you, that wasn't my
intention, I actually appreciate your effort!

My exclamation was because I was shocked by the staggering difference
in results, nothing else.

Here I still get the results I posted above from numasched. In fact
even worse, now even -D THREAD_ALLOC wouldn't end (and I disabled
lockdep just in case), I'll try to reboot some more time to see if I
can get some number out of it again.

numa02 at least repeats at 66 sec reproducibly with numasched with or
without lockdep.

> AA> numasched is always doing worse than upstream here, in fact two
> AA> times massively worse. Almost as bad as the inverse binds.
> 
> Well, something clearly isn't right, because my numbers don't match
> yours at all. This time with THP disabled, and compared to the rest of
> the numbers from my previous runs:
> 
>             autonuma   HARD   INVERSE   NO_BIND_FORCE_SAME_MODE
> 
> numa01      366        335    356       377
> numa01THP   388        336    353       399
> 
> That shows that autonuma is worse than inverse binds here. If I'm
> running your stuff incorrectly, please tell me and I'll correct
> it. However, I've now compiled the binary exactly as you asked, with THP
> disabled, and am seeing surprisingly consistent results.

HARD and INVERSE should be the min and max you get.

I would ask you before you test AutoNUMA again, or numasched again, to
repeat this "HARD" vs "INVERSE" vs "NO_BIND_FORCE_SAME_MODE"
benchmark and be sure the above numbers are correct for the above
three cases.

On my hardware you can see on page 7 of my pdf what I get:

http://www.kernel.org/pub/linux/kernel/people/andrea/autonuma/autonuma_bench-20120321.pdf

numa01 -DHARD_BIND | -DNO_BIND_FORCE_SAME_NODE | -DINVERSE_BIND
             196      305                        378

You can do this benchmark on an upstream kernel 3.3-rc, no need of any
patch to collect the above three numbers.

For me this is always true: HARD_BIND <= NO_BIND_FORCE_SAME_NODE <= INVERSE_BIND.

Checking if numa01 HARD_BIND and INVERSE_BIND cases are setting up
your hardware topology correctly may be good idea too.

If it's not a benchmarking error or a topology error in
HARD_BIND/INVERSE_BIND, it may be the hardware you're using is very
different. That would be bad news though, I thought you were using the
same common 2 socket exacore setup that I'm using and I wouldn't have
expected such a staggering difference in results (even for HARD vs
INVERSE vs NO_BIND_FORCE_SAME_NODE, even before we put autonuma or
numasched into the equation).

> AA> Maybe you've more than 16g? I've 16G and that leaves 1G free on both
> AA> nodes at the peak load with AutoNUMA. That shall be enough for
> AA> numasched too (Peter complained me I waste 80MB on a 16G system, so
> AA> he can't possibly be intentionally wasting me 2GB).
> 
> Yep, 24G here. Do I need to tweak the test?

Well maybe you could try to repeat at 16G if you still see numasched
performing great after running it with -DNO_BIND_FORCE_SAME_MODE.

What -DNO_BIND_FORCE_SAME_MODE is meant to do, is to start the "NUMA
migration" races from the worst possible condition.

Imagine it like doing a hiking race consistently always from the
_bottom_ of the mountain, and not randomly from the middle like it
would happen without -DNO_BIND_FORCE_SAME_MODE.

> How do you figure? I didn't post any hard binding numbers. In fact,
> numasched performed about equal to hard binding...definitely within your
> stated 2% error interval. That was with THP enabled, tomorrow I'll be
> glad to run them all again without THP.

Again thanks so much for your effort. I hope others will run more
benchmarks too on both solution. And I repeat what I said yesterday
clear and stright: if numasched will be shown to have the lead on the
vast majority of workloads, I will be happy to "rm -r autonuma" to
stop wasting time on an inferior dead project, and work on something
else entirely or to contribute to numasched in case they will need
help for something.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
