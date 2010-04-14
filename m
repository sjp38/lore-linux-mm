Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 789CC6B01E3
	for <linux-mm@kvack.org>; Wed, 14 Apr 2010 04:51:56 -0400 (EDT)
Date: Wed, 14 Apr 2010 09:51:33 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH] mm: disallow direct reclaim page writeback
Message-ID: <20100414085132.GJ25756@csn.ul.ie>
References: <20100413202021.GZ13327@think> <20100414014041.GD2493@dastard> <20100414155233.D153.A69D9226@jp.fujitsu.com> <20100414072830.GK2493@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100414072830.GK2493@dastard>
Sender: owner-linux-mm@kvack.org
To: Dave Chinner <david@fromorbit.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Chris Mason <chris.mason@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 14, 2010 at 05:28:30PM +1000, Dave Chinner wrote:
> On Wed, Apr 14, 2010 at 03:52:44PM +0900, KOSAKI Motohiro wrote:
> > > On Tue, Apr 13, 2010 at 04:20:21PM -0400, Chris Mason wrote:
> > > > On Tue, Apr 13, 2010 at 08:34:29PM +0100, Mel Gorman wrote:
> > > > > > Basically, there is not enough stack space available to allow direct
> > > > > > reclaim to enter ->writepage _anywhere_ according to the stack usage
> > > > > > profiles we are seeing here....
> > > > > > 
> > > > > 
> > > > > I'm not denying the evidence but how has it been gotten away with for years
> > > > > then? Prevention of writeback isn't the answer without figuring out how
> > > > > direct reclaimers can queue pages for IO and in the case of lumpy reclaim
> > > > > doing sync IO, then waiting on those pages.
> > > > 
> > > > So, I've been reading along, nodding my head to Dave's side of things
> > > > because seeks are evil and direct reclaim makes seeks.  I'd really loev
> > > > for direct reclaim to somehow trigger writepages on large chunks instead
> > > > of doing page by page spatters of IO to the drive.
> > 
> > I agree that "seeks are evil and direct reclaim makes seeks". Actually,
> > making 4k io is not must for pageout. So, probably we can improve it.
> > 
> > 
> > > Perhaps drop the lock on the page if it is held and call one of the
> > > helpers that filesystems use to do this, like:
> > > 
> > > 	filemap_write_and_wait(page->mapping);
> > 
> > Sorry, I'm lost what you talk about. Why do we need per-file
> > waiting? If file is 1GB file, do we need to wait 1GB writeout?
> 
> So use filemap_fdatawrite(page->mapping), or if it's better only
> to start IO on a segment of the file, use
> filemap_fdatawrite_range(page->mapping, start, end)....
> 

That does not help the stack usage issue, the caller ends up in
->writepages. From an IO perspective, it'll be better from a seek point of
view but from a VM perspective, it may or may not be cleaning the right pages.
So I think this is a red herring.

> > > > But, somewhere along the line I overlooked the part of Dave's stack trace
> > > > that said:
> > > > 
> > > > 43)     1568     912   do_select+0x3d6/0x700
> > > > 
> > > > Huh, 912 bytes...for select, really?  From poll.h:
> > > 
> > > Sure, it's bad, but we focussing on the specific case misses the
> > > point that even code that is using minimal stack can enter direct
> > > reclaim after consuming 1.5k of stack. e.g.:
> > 
> > checkstack.pl says do_select() and __generic_file_splice_read() are one
> > of worstest stack consumer. both sould be fixed.
> 
> the deepest call chain in queue_work() needs 700 bytes of stack
> to complete, wait_for_completion() requires almost 2k of stack space
> at it's deepest, the scheduler has some heavy stack users, etc,
> and these are all functions that appear at the top of the stack.
> 

The real issue here then is that stack usage has gone out of control.
Disabling ->writepage in direct reclaim does not guarantee that stack
usage will not be a problem again. From your traces, page reclaim itself
seems to be a big dirty hog.

Differences in what people see in their machines may be down to architecture,
compiler but most likely inlining. Changing inlining will not fix the problem,
it'll just move the stack usage around.

> > also, checkstack.pl says such stack eater aren't so much.
> 
> Yeah, but when we have ia callchain 70 or more functions deep,
> even 100 bytes of stack is a lot....
> 
> > > > So, select is intentionally trying to use that much stack.  It should be using
> > > > GFP_NOFS if it really wants to suck down that much stack...
> > > 
> > > The code that did the allocation is called from multiple different
> > > contexts - how is it supposed to know that in some of those contexts
> > > it is supposed to treat memory allocation differently?
> > > 
> > > This is my point - if you introduce a new semantic to memory allocation
> > > that is "use GFP_NOFS when you are using too much stack" and too much
> > > stack is more than 15% of the stack, then pretty much every code path
> > > will need to set that flag...
> > 
> > Nodding my head to Dave's side. changing caller argument seems not good
> > solution. I mean
> >  - do_select() should use GFP_KERNEL instead stack (as revert 70674f95c0)
> >  - reclaim and xfs (and other something else) need to diet.
> 
> The list I'm seeing so far includes:
> 	- scheduler
> 	- completion interfaces
> 	- radix tree
> 	- memory allocation, memory reclaim
> 	- anything that implements ->writepage
> 	- select
> 	- splice read
> 
> > Also, I believe stack eater function should be created waring. patch attached.
> 
> Good start, but 512 bytes will only catch select and splice read,
> and there are 300-400 byte functions in the above list that sit near
> the top of the stack....
> 

They will need to be tackled in turn then but obviously there should be
a focus on the common paths. The reclaim paths do seem particularly
heavy and it's down to a lot of temporary variables. I might not get the
time today but what I'm going to try do some time this week is

o Look at what temporary variables are copies of other pieces of information
o See what variables live for the duration of reclaim but are not needed
  for all of it (i.e. uninline parts of it so variables do not persist)
o See if it's possible to dynamically allocate scan_control

The last one is the trickiest. Basically, the idea would be to move as much
into scan_control as possible. Then, instead of allocating it on the stack,
allocate a fixed number of them at boot-time (NR_CPU probably) protected by
a semaphore. Limit the number of direct reclaimers that can be active at a
time to the number of scan_control variables. kswapd could still allocate
its on the stack or with kmalloc.

If it works out, it would have two main benefits. Limits the number of
processes in direct reclaim - if there is NR_CPU-worth of proceses in direct
reclaim, there is too much going on. It would also shrink the stack usage
particularly if some of the stack variables are moved into scan_control.

Maybe someone will beat me to looking at the feasibility of this.

> > > We need at least _700_ bytes of stack free just to call queue_work(),
> > > and that now happens deep in the guts of the driver subsystem below XFS.
> > > This trace shows 1.8k of stack usage on a simple, single sata disk
> > > storage subsystem, so my estimate of 2k of stack for the storage system
> > > below XFS is too small - a worst case of 2.5-3k of stack space is probably
> > > closer to the mark.
> > 
> > your explanation is very interesting. I have a (probably dumb) question.
> > Why nobody faced stack overflow issue in past? now I think every users
> > easily get stack overflow if your explanation is correct.
> 
> It's always a problem, but the focus on minimising stack usage has
> gone away since i386 has mostly disappeared from server rooms.
> 
> XFS has always been the thing that triggered stack usage problems
> first - the first reports of problems on x86_64 with 8k stacks in low
> memory situations have only just come in, and this is the first time
> in a couple of years I've paid close attention to stack usage
> outside XFS. What I'm seeing is not pretty....
> 
> > > This is the sort of thing I'm pointing at when I say that stack
> > > usage outside XFS has grown significantly significantly over the
> > > past couple of years. Given XFS has remained pretty much the same or
> > > even reduced slightly over the same time period, blaming XFS or
> > > saying "callers should use GFP_NOFS" seems like a cop-out to me.
> > > Regardless of the IO pattern performance issues, writeback via
> > > direct reclaim just uses too much stack to be safe these days...
> > 
> > Yeah, My answer is simple, All stack eater should be fixed.
> > but XFS seems not innocence too. 3.5K is enough big although
> > xfs have use such amount since very ago.
> 
> XFS used to use much more than that - significant effort has been
> put into reduce the stack footprint over many years. There's not
> much left to trim without rewriting half the filesystem...
> 

I don't think he is levelling a complain at XFS in particular - just pointing
out that it's heavy too. Still, we should be gratful that XFS is sort of
a "Stack Canary". If it dies, everyone else could be in trouble soon :)

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
