Date: Sat, 13 Jul 2002 13:18:37 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: scalable kmap (was Re: vm lock contention reduction)
Message-ID: <20020713111837.GD2526@dualathlon.random>
References: <3D2BC6DB.B60E010D@zip.com.au> <91460000.1026341000@flay> <3D2CBE6A.53A720A0@zip.com.au> <253370000.1026496086@flay>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <253370000.1026496086@flay>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <Martin.Bligh@us.ibm.com>
Cc: Andrew Morton <akpm@zip.com.au>, Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, Jul 12, 2002 at 10:48:06AM -0700, Martin J. Bligh wrote:
> OK, preliminary results we've seen about another 15% reduction in CPU load
> on Apache Specweb99 on an 8-way machine with Andrew's kmap patches!
> Will send out some more detailed numbers later from the official specweb
> machine (thanks to Dave Hansen for running the prelim tests).
> 
> Secondly, I'd like to propose yet another mechanism, which would
> also be a cheaper way to do things .... based vaguely on an RCU
> type mechanism:
> 
> When you go to allocate a new global kmap, the danger is that its PTE
> entry has not been TLB flushed, and the old value is still in some CPUs 
> TLB cache.
> 
> If only this task context is going to use this kmap (eg copy_to_user), 
> all we need do is check that we have context switched since we last 

you also must turn off the global bit from the kmap_prot first if you
want this to work.

> used this kmap entry (since it was freed is easiest). If we have not, we 
> merely do a local single line invalidate of that entry. If we switch to 
> running on any other CPU in the future, we'll do a global TLB flush on 
> the switch, so no problem there. I suspect that 99% of the time, this 
> means no TLB flush at all, or even an invalidate.
> 
> If multiple task contexts might use this kmap, we need to check that
> ALL cpus have done an context switch since this entry was last used.
> If not, we send a single line invalidate to only those other CPUs that
> have not switched, and thus might still have a dirty entry ...
> 
> I believe RCU already has all the mechanisms for checking context
> switches. By context switch, I really mean TLB flush - ie switched

RCU doesn't have and doesn't need that kind of mechanism. First of all
RCU don't even track context switches, it only tracks quiescent points
(even if there's no context switch if somebody called schedule() that's
a quiescent point even if we keep running the current task afterwards
maybe because it's the only running task). But even tracking context
switches isn't enough as you said, you've to track mm_switches that is
yet in a different place.

So the mm_switch code would need a new instrumentation but that's not
the main issue, it's just the logic to keep track of this info seem
overcomplex, doesn't really sound an obvious optimization to me.  Also I
would remind it should be implemented it in a zerocost way for the 64bit
archs but that's certainly not a problem (just a reminder :).

> processes, not just threads.
> 
> Madness?
> 
> M.


Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
