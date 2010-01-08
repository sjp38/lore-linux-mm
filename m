Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id E66E76B003D
	for <linux-mm@kvack.org>; Fri,  8 Jan 2010 12:23:19 -0500 (EST)
Date: Fri, 8 Jan 2010 09:22:14 -0800 (PST)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [RFC][PATCH 6/8] mm: handle_speculative_fault()
In-Reply-To: <1262969610.4244.36.camel@laptop>
Message-ID: <alpine.LFD.2.00.1001080911340.7821@localhost.localdomain>
References: <20100104182429.833180340@chello.nl>  <20100104182813.753545361@chello.nl>  <20100105092559.1de8b613.kamezawa.hiroyu@jp.fujitsu.com>  <28c262361001042029w4b95f226lf54a3ed6a4291a3b@mail.gmail.com>  <20100105134357.4bfb4951.kamezawa.hiroyu@jp.fujitsu.com>
  <alpine.LFD.2.00.1001042052210.3630@localhost.localdomain>  <20100105143046.73938ea2.kamezawa.hiroyu@jp.fujitsu.com>  <20100105163939.a3f146fb.kamezawa.hiroyu@jp.fujitsu.com>  <alpine.LFD.2.00.1001050707520.3630@localhost.localdomain>
 <20100106092212.c8766aa8.kamezawa.hiroyu@jp.fujitsu.com>  <alpine.LFD.2.00.1001051718100.3630@localhost.localdomain>  <20100106115233.5621bd5e.kamezawa.hiroyu@jp.fujitsu.com>  <alpine.LFD.2.00.1001051917000.3630@localhost.localdomain>
 <20100106125625.b02c1b3a.kamezawa.hiroyu@jp.fujitsu.com>  <alpine.LFD.2.00.1001052007090.3630@localhost.localdomain> <1262969610.4244.36.camel@laptop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, cl@linux-foundation.org, "hugh.dickins" <hugh.dickins@tiscali.co.uk>, Nick Piggin <nickpiggin@yahoo.com.au>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>



On Fri, 8 Jan 2010, Peter Zijlstra wrote:

> On Tue, 2010-01-05 at 20:20 -0800, Linus Torvalds wrote:
> > 
> > Yeah, I should have looked more at your callchain. That's nasty. Much 
> > worse than the per-mm lock. I thought the page buffering would avoid the 
> > zone lock becoming a huge problem, but clearly not in this case.
> 
> Right, so I ran some numbers on a multi-socket (2) machine as well:
> 
>                                pf/min
> 
> -tip                          56398626
> -tip + xadd                  174753190
> -tip + speculative           189274319
> -tip + xadd + speculative    200174641
> 
> [ variance is around 0.5% for this workload, ran most of these numbers
> with --repeat 5 ]

That's a huge jump. It's clear that the spinlock-based rwsem's simply 
suck.  The speculation gets rid of some additional mmap_sem contention, 
but at least for two sockets it looks like the rwsem implementation was 
the biggest problem by far.

> At both the xadd/speculative point the workload is dominated by the
> zone->lock, the xadd+speculative removes some of the contention, and
> removing the various RSS counters could yield another few percent
> according to the profiles, but then we're pretty much there.

I don't know if worrying about a few percent is worth it. "Perfect is the 
enemy of good", and the workload is pretty dang artificial with the whole 
"remove pages and re-fault them as fast as you can".

So the benchmark is pointless and extreme, and I think it's not worth 
worrying too much about details. Especially when compared to just the 
*three-fold* jump from just the fairly trivial rwsem implementation change 
(with speculation on top of it then adding another 15% improvement - 
nothing to sneeze at, but it's still in a different class).

Of course, larger numbers of sockets will likely change the situation, but 
at the same time I do suspect that workloads designed for hundreds of 
cores will need to try to behave better than that benchmark anyway ;)

> One way around those RSS counters is to track it per task, a quick grep
> shows its only the oom-killer and proc that use them.
> 
> A quick hack removing them gets us: 203158058

Yeah, well.. After that 200% and 15% improvement, a 1.5% improvement on a 
totally artificial benchmark looks less interesting.

Because let's face it - if your workload does several million page faults 
per second, you're just doing something fundamentally _wrong_.

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
