Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 3397D6B003D
	for <linux-mm@kvack.org>; Sat,  9 Jan 2010 09:48:03 -0500 (EST)
From: Ed Tomlinson <edt@aei.ca>
Subject: Re: [RFC][PATCH 6/8] mm: handle_speculative_fault()
Date: Sat, 9 Jan 2010 09:47:57 -0500
References: <20100104182429.833180340@chello.nl> <alpine.LFD.2.00.1001052007090.3630@localhost.localdomain> <1262969610.4244.36.camel@laptop>
In-Reply-To: <1262969610.4244.36.camel@laptop>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <201001090947.57479.edt@aei.ca>
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, cl@linux-foundation.org, "hugh.dickins" <hugh.dickins@tiscali.co.uk>, Nick Piggin <nickpiggin@yahoo.com.au>, Ingo Molnar <mingo@elte.hu>, Nitin Gupta <ngupta@vflare.org>
List-ID: <linux-mm.kvack.org>

On Friday 08 January 2010 11:53:30 Peter Zijlstra wrote:
> On Tue, 2010-01-05 at 20:20 -0800, Linus Torvalds wrote:
> > 
> > On Wed, 6 Jan 2010, KAMEZAWA Hiroyuki wrote:
> > > > 
> > > > Of course, your other load with MADV_DONTNEED seems to be horrible, and 
> > > > has some nasty spinlock issues, but that looks like a separate deal (I 
> > > > assume that load is just very hard on the pgtable lock).
> > > 
> > > It's zone->lock, I guess. My test program avoids pgtable lock problem.
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

Has anyone tried these patches with ramzswap?  Nitin do they help with the locking
issues you mentioned?

Thanks,
Ed

 
> [ variance is around 0.5% for this workload, ran most of these numbers
> with --repeat 5 ]
> 
> At both the xadd/speculative point the workload is dominated by the
> zone->lock, the xadd+speculative removes some of the contention, and
> removing the various RSS counters could yield another few percent
> according to the profiles, but then we're pretty much there.
> 
> One way around those RSS counters is to track it per task, a quick grep
> shows its only the oom-killer and proc that use them.
> 
> A quick hack removing them gets us: 203158058
> 
> So from a throughput pov. the whole speculative fault thing might not be
> interesting until the rest of the vm gets a lift to go along with it.
> 
> >From a blocking on mmap_sem pov. I think Linus is right in that we
> should first consider things like dropping mmap_sep around IO and page
> zeroing, and generally looking at reducing hold times and such.
> 
> So while I think its quite feasible to do these speculative faults, it
> appears we're not quite ready for them.
> 
> Maybe I can get -rt to carry it for a while, there we have to reduce
> mmap_sem to a mutex, which hurts lots.
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
