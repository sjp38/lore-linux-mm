Subject: Re: [rfc] balance-on-fork NUMA placement
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <46B10E9B.2030907@mbligh.org>
References: <20070731054142.GB11306@wotan.suse.de>
	 <200707311114.09284.ak@suse.de> <20070801002313.GC31006@wotan.suse.de>
	 <46B0C8A3.8090506@mbligh.org> <1185993169.5059.79.camel@localhost>
	 <46B10E9B.2030907@mbligh.org>
Content-Type: text/plain
Date: Thu, 02 Aug 2007 10:49:41 -0400
Message-Id: <1186066181.5040.20.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Martin Bligh <mbligh@mbligh.org>
Cc: Nick Piggin <npiggin@suse.de>, Andi Kleen <ak@suse.de>, Ingo Molnar <mingo@elte.hu>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

On Wed, 2007-08-01 at 15:52 -0700, Martin Bligh wrote:
> >> This topic seems to come up periodically every since we first introduced
> >> the NUMA scheduler, and every time we decide it's a bad idea. What's
> >> changed? What workloads does this improve (aside from some artificial
> >> benchmark like stream)?
> >>
> >> To repeat the conclusions of last time ... the primary problem is that
> >> 99% of the time, we exec after we fork, and it makes that fork/exec
> >> cycle slower, not faster, so exec is generally a much better time to do
> >> this. There's no good predictor of whether we'll exec after fork, unless
> >> one has magically appeared since late 2.5.x ?
> >>
> > 
> > As Nick points out, one reason to balance on fork() rather than exec()
> > is that with balance on exec you already have the new task's kernel
> > structs allocated on the "wrong" node.  However, as you point out, this
> > slows down the fork/exec cycle.  This is especially noticeable on larger
> > node-count systems in, e.g., shell scripts that spawn a lot of short
> > lived child processes.  "Back in the day", we got bitten by this on the
> > Alpha EV7 [a.k.a. Marvel] platform with just ~64 nodes--small compared
> > to, say, the current Altix platform.  
> > 
> > On the other hand, if you're launching a few larger, long-lived
> > applications with any significant %-age of system time, you might want
> > to consider spreading them out across nodes and having their warmer
> > kernel data structures close to them.  A dilemma.
> > 
> > Altho' I was no longer working on this platform when this issue came up,
> > I believe that the kernel developers came up with something along these
> > lines:
> > 
> > + define a "credit" member of the "task" struct, initialized to, say,
> > zero.
> > 
> > + when "credit" is zero, or below some threshold, balance on fork--i.e.,
> > spread out the load--otherwise fork "locally" and decrement credit
> > [maybe not < 0].
> > 
> > + when reaping dead children, if the poor thing's cpu utilization is
> > below some threshold, give the parent some credit.  [blood money?]
> > 
> > And so forth.  Initial forks will balance.  If the children refuse to
> > die, forks will continue to balance.  If the parent starts seeing short
> > lived children, fork()s will eventually start to stay local.  
> 
> Fork without exec is much more rare than without. Optimising for
> the uncommon case is the Wrong Thing to Do (tm). What we decided
> the last time(s) this came up was to allow userspace to pass
> a hint in if they wanted to fork and not exec.

I understand.  Again, as Nick mentioned, at exec time, you use the
existing task struct, kernel stack, ... which might [probably will?] end
up on the wrong node.  If the task uses a significant amount of system
time, this can hurt performance/scalability.  And, for short lived, low
cpu usage tasks, such as you can get with shell scripts, you might not
even want to balance at exec time.

I agree with your assertion regarding optimizing for uncommon cases.
The mechanism I described [probably poorly, memory fades and it was only
a "hallway conversation" with the person who implemented it--in response
to a customer complaint] attempted to detect situations where local vs
balanced fork would be beneficial.  I will note, however, that when
balancing, we did look across the entire system.  Linux scheduling
domains has the intermediate "node" level that constrains this balancing
to a subset of the system.  

I'm not suggesting we submit this, nor am I particulary interested in
investigating it myself.  Just pointing out a solution to a workload
scalability issue on an existing, albeit dated, numa platform.  

> 
> > I believe that this solved the pathological behavior we were seeing with
> > shell scripts taking way longer on the larger, supposedly more powerful,
> > platforms.
> > 
> > Of course, that OS could migrate the equivalent of task structs and
> > kernel stack [the old Unix user struct that was traditionally swappable,
> > so fairly easy to migrate].  On Linux, all bets are off, once the
> > scheduler starts migrating tasks away from the node that contains their
> > task struct, ...  [Remember Eric Focht's "NUMA Affine Scheduler" patch
> > with it's "home node"?]
> 
> Task migration doesn't work well at all without userspace hints.
> SGI tried for ages (with IRIX) and failed. There's long discussions
> of all of these things back in the days when we merged the original
> NUMA scheduler in late 2.5 ...

I'm not one to cast aspersions on the IRIX engineers.  However, as I
recall [could be wrong here], they were trying to use hardware counters
to predict what pages to migrate.  On the same OS discussed above, we
found that automatic, lazy migration of pages worked very well for some
workloads.  

I have patches and data [presented at LCA 2007] that shows, on a heavily
loaded 4-node, 16-cpu ia64 numa platform, ~14% reduction in real time
for a kernel build [make -j 32] and something like 22% reduction in
system time and 4% reduction in user time.  This with automatic, lazy
migration enabled vs not, on the same build of a 2.6.19-rc6-mm? kernel.
I'll also note that the reduction in system time was in spite of the
cost of the auto/lazy page migration whenever the tasks migrated to a
different node.

Later,
Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
