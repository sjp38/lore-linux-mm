Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 11FB26B003D
	for <linux-mm@kvack.org>; Fri,  8 Jan 2010 11:53:44 -0500 (EST)
Subject: Re: [RFC][PATCH 6/8] mm: handle_speculative_fault()
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <alpine.LFD.2.00.1001052007090.3630@localhost.localdomain>
References: <20100104182429.833180340@chello.nl>
	 <20100104182813.753545361@chello.nl>
	 <20100105092559.1de8b613.kamezawa.hiroyu@jp.fujitsu.com>
	 <28c262361001042029w4b95f226lf54a3ed6a4291a3b@mail.gmail.com>
	 <20100105134357.4bfb4951.kamezawa.hiroyu@jp.fujitsu.com>
	 <alpine.LFD.2.00.1001042052210.3630@localhost.localdomain>
	 <20100105143046.73938ea2.kamezawa.hiroyu@jp.fujitsu.com>
	 <20100105163939.a3f146fb.kamezawa.hiroyu@jp.fujitsu.com>
	 <alpine.LFD.2.00.1001050707520.3630@localhost.localdomain>
	 <20100106092212.c8766aa8.kamezawa.hiroyu@jp.fujitsu.com>
	 <alpine.LFD.2.00.1001051718100.3630@localhost.localdomain>
	 <20100106115233.5621bd5e.kamezawa.hiroyu@jp.fujitsu.com>
	 <alpine.LFD.2.00.1001051917000.3630@localhost.localdomain>
	 <20100106125625.b02c1b3a.kamezawa.hiroyu@jp.fujitsu.com>
	 <alpine.LFD.2.00.1001052007090.3630@localhost.localdomain>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 08 Jan 2010 17:53:30 +0100
Message-ID: <1262969610.4244.36.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, cl@linux-foundation.org, "hugh.dickins" <hugh.dickins@tiscali.co.uk>, Nick Piggin <nickpiggin@yahoo.com.au>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Tue, 2010-01-05 at 20:20 -0800, Linus Torvalds wrote:
> 
> On Wed, 6 Jan 2010, KAMEZAWA Hiroyuki wrote:
> > > 
> > > Of course, your other load with MADV_DONTNEED seems to be horrible, and 
> > > has some nasty spinlock issues, but that looks like a separate deal (I 
> > > assume that load is just very hard on the pgtable lock).
> > 
> > It's zone->lock, I guess. My test program avoids pgtable lock problem.
> 
> Yeah, I should have looked more at your callchain. That's nasty. Much 
> worse than the per-mm lock. I thought the page buffering would avoid the 
> zone lock becoming a huge problem, but clearly not in this case.

Right, so I ran some numbers on a multi-socket (2) machine as well:

                               pf/min

-tip                          56398626
-tip + xadd                  174753190
-tip + speculative           189274319
-tip + xadd + speculative    200174641

[ variance is around 0.5% for this workload, ran most of these numbers
with --repeat 5 ]

At both the xadd/speculative point the workload is dominated by the
zone->lock, the xadd+speculative removes some of the contention, and
removing the various RSS counters could yield another few percent
according to the profiles, but then we're pretty much there.

One way around those RSS counters is to track it per task, a quick grep
shows its only the oom-killer and proc that use them.

A quick hack removing them gets us: 203158058

So from a throughput pov. the whole speculative fault thing might not be
interesting until the rest of the vm gets a lift to go along with it.

>From a blocking on mmap_sem pov. I think Linus is right in that we
should first consider things like dropping mmap_sep around IO and page
zeroing, and generally looking at reducing hold times and such.

So while I think its quite feasible to do these speculative faults, it
appears we're not quite ready for them.

Maybe I can get -rt to carry it for a while, there we have to reduce
mmap_sem to a mutex, which hurts lots.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
