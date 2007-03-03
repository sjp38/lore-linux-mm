Date: Fri, 2 Mar 2007 16:54:30 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: The performance and behaviour of the anti-fragmentation related
 patches
Message-Id: <20070302165430.816db9a0.akpm@linux-foundation.org>
In-Reply-To: <20070303003319.GB23573@holomorphy.com>
References: <20070302093501.34c6ef2a.akpm@linux-foundation.org>
	<45E8624E.2080001@redhat.com>
	<20070302100619.cec06d6a.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0703021012170.17676@schroedinger.engr.sgi.com>
	<45E86BA0.50508@redhat.com>
	<20070302211207.GJ10643@holomorphy.com>
	<45E894D7.2040309@redhat.com>
	<20070302135243.ada51084.akpm@linux-foundation.org>
	<45E89F1E.8020803@redhat.com>
	<20070302142256.0127f5ac.akpm@linux-foundation.org>
	<20070303003319.GB23573@holomorphy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: Rik van Riel <riel@redhat.com>, Bill Irwin <bill.irwin@oracle.com>, Christoph Lameter <clameter@engr.sgi.com>, Mel Gorman <mel@skynet.ie>, npiggin@suse.de, mingo@elte.hu, jschopp@austin.ibm.com, arjan@infradead.org, torvalds@linux-foundation.org, mbligh@mbligh.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 2 Mar 2007 16:33:19 -0800
William Lee Irwin III <wli@holomorphy.com> wrote:

> On Fri, Mar 02, 2007 at 02:22:56PM -0800, Andrew Morton wrote:
> > Opterons seem to be particularly prone to lock starvation where a cacheline
> > gets captured in a single package for ever.
> 
> AIUI that phenomenon is universal to NUMA. Maybe it's time we
> reexamined our locking algorithms in the light of fairness
> considerations.
> 

It's also a multicore thing.  iirc Kiran was seeing it on Intel CPUs.

I expect the phenomenon would be observeable on a number of locks in the
kernel, give the appropriate workload.  We just hit it first on lru_lock.

I'd have thought that increasing SWAP_CLUSTER_MAX by two or four orders of
magnitude would plug it, simply by decreasing the acquisition frequency but
I think Kiran fiddled with that to no effect.


See below for Linus's thoughts, forwarded without permission..





Begin forwarded message:

Date: Mon, 22 Jan 2007 13:49:02 -0800 (PST)
From: Linus Torvalds <torvalds@linux-foundation.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Ravikiran G Thirumalai <kiran@scalex86.org>
Subject: Re: High lock spin time for zone->lru_lock under extreme conditions



On Mon, 22 Jan 2007, Andrew Morton wrote:
> 
> Please review the whole thread sometime.  I think we're pretty screwed, and
> the problem will only become worse as more cores get rolled out and I don't
> know what to do about it apart from whining to Intel, but that won't fix
> anything.

I think people need to realize that spinlocks are always going to be 
unfair, and *extremely* so under some conditions. And yes, multi-core 
brought those conditions home to roost for some people (two or more cores 
much closer to each other than others, and able to basically ping-pong the 
spinlock to each other, with nobody else ever able to get it).

There's only a few possible solutions:

 - use the much slower semaphores, which actually try to do fairness. 

 - if you cannot sleep, introduce a separate "fair spinlock" type. It's 
   going to be appreciably slower (and will possibly have a bigger memory 
   footprint) than a regular spinlock, though. But it's certainly a 
   possible thing to do.

 - make sure no lock that you care about ever has high enough contention 
   to matter. NOTE! back-off etc simply will not help. This is not a 
   back-off issue. Back-off helps keep down coherency traffic, but it 
   doesn't help fairness.

If somebody wants to play with fair spinlocks, go wild. I looked at it at 
one point, and it was not wonderful. It's pretty complicated to do, and 
the best way I could come up with was literally a list of waiting CPU's 
(but you only need one static list entry per CPU). I didn't bother to 
think a whole lot about it.

The "never enough contention" is the real solution. For example, anything 
that drops and just re-takes the lock again (which some paths do for 
latency reduction) won't do squat. The same CPU that dropped the lock will 
basically always be able to retake it (and multi-core just means that is 
even more true, with the lock staying within one die even if some other 
core can get it).

Of course, "never enough contention" may not be possible for all locks. 
Which is why a "fair spinlock" may be the solution - use it for the few 
locks that care (and the VM locks could easily be it).

What CANNOT work: timeouts. A watchdog won't work. If you have workloads 
with enough contention, once you have enough CPU's, there's no upper bound 
on one of the cores not being able to get the lock.

On the other hand, what CAN work is: not caring. If it's ok to not be 
fair, and it only happens under extreme load, then "we don't care" is a 
perfectly fine option. 

In the "it could work" corner, I used to hope that cache coherency 
protocols in hw would do some kind of fairness thing, but I've come to the 
conclusion that it's just too hard. It's hard enough for software, it's 
likely really painful for hw too. So not only does hw generally not do it 
today (although certain platforms are better at it than others), I don't 
really expect this to change.

If anything, we'll see more of it, since multicore is one thing that makes 
things worse (as does multiple levels of caching - NUMA machines tend to 
have this problem even without multi-core, simply because they don't have 
a shared bus, which happens to hide many cases).

I'm personally in the "don't care" camp, until somebody shows a real-life 
workload. I'd often prefer to disable a watchdog if that's the biggest 
problem, for example. But if there's a real load that shows this as a real 
problem...

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
