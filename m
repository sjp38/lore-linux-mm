Message-ID: <46B10E9B.2030907@mbligh.org>
Date: Wed, 01 Aug 2007 15:52:11 -0700
From: Martin Bligh <mbligh@mbligh.org>
MIME-Version: 1.0
Subject: Re: [rfc] balance-on-fork NUMA placement
References: <20070731054142.GB11306@wotan.suse.de>	 <200707311114.09284.ak@suse.de> <20070801002313.GC31006@wotan.suse.de>	 <46B0C8A3.8090506@mbligh.org> <1185993169.5059.79.camel@localhost>
In-Reply-To: <1185993169.5059.79.camel@localhost>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Nick Piggin <npiggin@suse.de>, Andi Kleen <ak@suse.de>, Ingo Molnar <mingo@elte.hu>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

>> This topic seems to come up periodically every since we first introduced
>> the NUMA scheduler, and every time we decide it's a bad idea. What's
>> changed? What workloads does this improve (aside from some artificial
>> benchmark like stream)?
>>
>> To repeat the conclusions of last time ... the primary problem is that
>> 99% of the time, we exec after we fork, and it makes that fork/exec
>> cycle slower, not faster, so exec is generally a much better time to do
>> this. There's no good predictor of whether we'll exec after fork, unless
>> one has magically appeared since late 2.5.x ?
>>
> 
> As Nick points out, one reason to balance on fork() rather than exec()
> is that with balance on exec you already have the new task's kernel
> structs allocated on the "wrong" node.  However, as you point out, this
> slows down the fork/exec cycle.  This is especially noticeable on larger
> node-count systems in, e.g., shell scripts that spawn a lot of short
> lived child processes.  "Back in the day", we got bitten by this on the
> Alpha EV7 [a.k.a. Marvel] platform with just ~64 nodes--small compared
> to, say, the current Altix platform.  
> 
> On the other hand, if you're launching a few larger, long-lived
> applications with any significant %-age of system time, you might want
> to consider spreading them out across nodes and having their warmer
> kernel data structures close to them.  A dilemma.
> 
> Altho' I was no longer working on this platform when this issue came up,
> I believe that the kernel developers came up with something along these
> lines:
> 
> + define a "credit" member of the "task" struct, initialized to, say,
> zero.
> 
> + when "credit" is zero, or below some threshold, balance on fork--i.e.,
> spread out the load--otherwise fork "locally" and decrement credit
> [maybe not < 0].
> 
> + when reaping dead children, if the poor thing's cpu utilization is
> below some threshold, give the parent some credit.  [blood money?]
> 
> And so forth.  Initial forks will balance.  If the children refuse to
> die, forks will continue to balance.  If the parent starts seeing short
> lived children, fork()s will eventually start to stay local.  

Fork without exec is much more rare than without. Optimising for
the uncommon case is the Wrong Thing to Do (tm). What we decided
the last time(s) this came up was to allow userspace to pass
a hint in if they wanted to fork and not exec.

> I believe that this solved the pathological behavior we were seeing with
> shell scripts taking way longer on the larger, supposedly more powerful,
> platforms.
> 
> Of course, that OS could migrate the equivalent of task structs and
> kernel stack [the old Unix user struct that was traditionally swappable,
> so fairly easy to migrate].  On Linux, all bets are off, once the
> scheduler starts migrating tasks away from the node that contains their
> task struct, ...  [Remember Eric Focht's "NUMA Affine Scheduler" patch
> with it's "home node"?]

Task migration doesn't work well at all without userspace hints.
SGI tried for ages (with IRIX) and failed. There's long discussions
of all of these things back in the days when we merged the original
NUMA scheduler in late 2.5 ...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
