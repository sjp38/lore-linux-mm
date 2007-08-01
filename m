Subject: Re: [rfc] balance-on-fork NUMA placement
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <46B0C8A3.8090506@mbligh.org>
References: <20070731054142.GB11306@wotan.suse.de>
	 <200707311114.09284.ak@suse.de> <20070801002313.GC31006@wotan.suse.de>
	 <46B0C8A3.8090506@mbligh.org>
Content-Type: text/plain
Date: Wed, 01 Aug 2007 14:32:48 -0400
Message-Id: <1185993169.5059.79.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Martin Bligh <mbligh@mbligh.org>
Cc: Nick Piggin <npiggin@suse.de>, Andi Kleen <ak@suse.de>, Ingo Molnar <mingo@elte.hu>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

On Wed, 2007-08-01 at 10:53 -0700, Martin Bligh wrote:
> Nick Piggin wrote:
> > On Tue, Jul 31, 2007 at 11:14:08AM +0200, Andi Kleen wrote:
> >> On Tuesday 31 July 2007 07:41, Nick Piggin wrote:
> >>
> >>> I haven't given this idea testing yet, but I just wanted to get some
> >>> opinions on it first. NUMA placement still isn't ideal (eg. tasks with
> >>> a memory policy will not do any placement, and process migrations of
> >>> course will leave the memory behind...), but it does give a bit more
> >>> chance for the memory controllers and interconnects to get evenly
> >>> loaded.
> >> I didn't think slab honored mempolicies by default? 
> >> At least you seem to need to set special process flags.
> >>
> >>> NUMA balance-on-fork code is in a good position to allocate all of a new
> >>> process's memory on a chosen node. However, it really only starts
> >>> allocating on the correct node after the process starts running.
> >>>
> >>> task and thread structures, stack, mm_struct, vmas, page tables etc. are
> >>> all allocated on the parent's node.
> >> The page tables should be only allocated when the process runs; except
> >> for the PGD.
> > 
> > We certainly used to copy all page tables on fork. Not any more, but we
> > must still copy anonymous page tables.
> 
> This topic seems to come up periodically every since we first introduced
> the NUMA scheduler, and every time we decide it's a bad idea. What's
> changed? What workloads does this improve (aside from some artificial
> benchmark like stream)?
> 
> To repeat the conclusions of last time ... the primary problem is that
> 99% of the time, we exec after we fork, and it makes that fork/exec
> cycle slower, not faster, so exec is generally a much better time to do
> this. There's no good predictor of whether we'll exec after fork, unless
> one has magically appeared since late 2.5.x ?
> 

As Nick points out, one reason to balance on fork() rather than exec()
is that with balance on exec you already have the new task's kernel
structs allocated on the "wrong" node.  However, as you point out, this
slows down the fork/exec cycle.  This is especially noticeable on larger
node-count systems in, e.g., shell scripts that spawn a lot of short
lived child processes.  "Back in the day", we got bitten by this on the
Alpha EV7 [a.k.a. Marvel] platform with just ~64 nodes--small compared
to, say, the current Altix platform.  

On the other hand, if you're launching a few larger, long-lived
applications with any significant %-age of system time, you might want
to consider spreading them out across nodes and having their warmer
kernel data structures close to them.  A dilemma.

Altho' I was no longer working on this platform when this issue came up,
I believe that the kernel developers came up with something along these
lines:

+ define a "credit" member of the "task" struct, initialized to, say,
zero.

+ when "credit" is zero, or below some threshold, balance on fork--i.e.,
spread out the load--otherwise fork "locally" and decrement credit
[maybe not < 0].

+ when reaping dead children, if the poor thing's cpu utilization is
below some threshold, give the parent some credit.  [blood money?]

And so forth.  Initial forks will balance.  If the children refuse to
die, forks will continue to balance.  If the parent starts seeing short
lived children, fork()s will eventually start to stay local.  

I believe that this solved the pathological behavior we were seeing with
shell scripts taking way longer on the larger, supposedly more powerful,
platforms.

Of course, that OS could migrate the equivalent of task structs and
kernel stack [the old Unix user struct that was traditionally swappable,
so fairly easy to migrate].  On Linux, all bets are off, once the
scheduler starts migrating tasks away from the node that contains their
task struct, ...  [Remember Eric Focht's "NUMA Affine Scheduler" patch
with it's "home node"?]

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
