Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id BB10A6B01E3
	for <linux-mm@kvack.org>; Wed, 14 Apr 2010 21:34:47 -0400 (EDT)
Date: Thu, 15 Apr 2010 11:34:36 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH] mm: disallow direct reclaim page writeback
Message-ID: <20100415013436.GO2493@dastard>
References: <20100413202021.GZ13327@think>
 <20100414014041.GD2493@dastard>
 <20100414155233.D153.A69D9226@jp.fujitsu.com>
 <20100414072830.GK2493@dastard>
 <20100414085132.GJ25756@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20100414085132.GJ25756@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Chris Mason <chris.mason@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 14, 2010 at 09:51:33AM +0100, Mel Gorman wrote:
> On Wed, Apr 14, 2010 at 05:28:30PM +1000, Dave Chinner wrote:
> > On Wed, Apr 14, 2010 at 03:52:44PM +0900, KOSAKI Motohiro wrote:
> > > > On Tue, Apr 13, 2010 at 04:20:21PM -0400, Chris Mason wrote:
> > > > > On Tue, Apr 13, 2010 at 08:34:29PM +0100, Mel Gorman wrote:
> > > > > > > Basically, there is not enough stack space available to allow direct
> > > > > > > reclaim to enter ->writepage _anywhere_ according to the stack usage
> > > > > > > profiles we are seeing here....
> > > > > > > 
> > > > > > 
> > > > > > I'm not denying the evidence but how has it been gotten away with for years
> > > > > > then? Prevention of writeback isn't the answer without figuring out how
> > > > > > direct reclaimers can queue pages for IO and in the case of lumpy reclaim
> > > > > > doing sync IO, then waiting on those pages.
> > > > > 
> > > > > So, I've been reading along, nodding my head to Dave's side of things
> > > > > because seeks are evil and direct reclaim makes seeks.  I'd really loev
> > > > > for direct reclaim to somehow trigger writepages on large chunks instead
> > > > > of doing page by page spatters of IO to the drive.
> > > 
> > > I agree that "seeks are evil and direct reclaim makes seeks". Actually,
> > > making 4k io is not must for pageout. So, probably we can improve it.
> > > 
> > > 
> > > > Perhaps drop the lock on the page if it is held and call one of the
> > > > helpers that filesystems use to do this, like:
> > > > 
> > > > 	filemap_write_and_wait(page->mapping);
> > > 
> > > Sorry, I'm lost what you talk about. Why do we need per-file
> > > waiting? If file is 1GB file, do we need to wait 1GB writeout?
> > 
> > So use filemap_fdatawrite(page->mapping), or if it's better only
> > to start IO on a segment of the file, use
> > filemap_fdatawrite_range(page->mapping, start, end)....
> 
> That does not help the stack usage issue, the caller ends up in
> ->writepages. From an IO perspective, it'll be better from a seek point of
> view but from a VM perspective, it may or may not be cleaning the right pages.
> So I think this is a red herring.

If you ask it to clean a bunch of pages around the one you want to
reclaim on the LRU, there is a good chance it will also be cleaning
pages that are near the end of the LRU or physically close by as
well. It's not a guarantee, but for the additional IO cost of about
10% wall time on that IO to clean the page you need, you also get
1-2 orders of magnitude other pages cleaned. That sounds like a
win any way you look at it...

I agree that it doesn't solve the stack problem (Chris' suggestion
that we enable the bdi flusher interface would fix this); what I'm
pointing out is that the arguments that it is too hard or there are
no interfaces available to issue larger IO from reclaim are not at
all valid.

> > the deepest call chain in queue_work() needs 700 bytes of stack
> > to complete, wait_for_completion() requires almost 2k of stack space
> > at it's deepest, the scheduler has some heavy stack users, etc,
> > and these are all functions that appear at the top of the stack.
> > 
> 
> The real issue here then is that stack usage has gone out of control.

That's definitely true, but it shouldn't cloud the fact that most
ppl want to kill writeback from direct reclaim, too, so killing two
birds with one stone seems like a good idea.

How about this? For now, we stop direct reclaim from doing writeback
only on order zero allocations, but allow it for higher order
allocations. That will prevent the majority of situations where
direct reclaim blows the stack and interferes with background
writeout, but won't cause lumpy reclaim to change behaviour.
This reduces the scope of impact and hence testing and validation
the needs to be done.

Then we can work towards allowing lumpy reclaim to use background
threads as Chris suggested for doing specific writeback operations
to solve the remaining problems being seen. Does this seem like a
reasonable compromise and approach to dealing with the problem?

> Disabling ->writepage in direct reclaim does not guarantee that stack
> usage will not be a problem again. From your traces, page reclaim itself
> seems to be a big dirty hog.

I couldn't agree more - the kernel still needs to be put on a stack
usage diet, but the above would give use some breathing space to attack the
problem before more people start to hit these problems.

> > Good start, but 512 bytes will only catch select and splice read,
> > and there are 300-400 byte functions in the above list that sit near
> > the top of the stack....
> > 
> 
> They will need to be tackled in turn then but obviously there should be
> a focus on the common paths. The reclaim paths do seem particularly
> heavy and it's down to a lot of temporary variables. I might not get the
> time today but what I'm going to try do some time this week is
> 
> o Look at what temporary variables are copies of other pieces of information
> o See what variables live for the duration of reclaim but are not needed
>   for all of it (i.e. uninline parts of it so variables do not persist)
> o See if it's possible to dynamically allocate scan_control

Welcome to my world ;)

> The last one is the trickiest. Basically, the idea would be to move as much
> into scan_control as possible. Then, instead of allocating it on the stack,
> allocate a fixed number of them at boot-time (NR_CPU probably) protected by
> a semaphore. Limit the number of direct reclaimers that can be active at a
> time to the number of scan_control variables. kswapd could still allocate
> its on the stack or with kmalloc.
> 
> If it works out, it would have two main benefits. Limits the number of
> processes in direct reclaim - if there is NR_CPU-worth of proceses in direct
> reclaim, there is too much going on. It would also shrink the stack usage
> particularly if some of the stack variables are moved into scan_control.
> 
> Maybe someone will beat me to looking at the feasibility of this.

I like the idea - it really sounds like you want a fixed size,
preallocated mempool that can't be enlarged. In fact, I can probably
use something like this in XFS to save a couple of hundred bytes of
stack space in the worst hogs....

> > > > This is the sort of thing I'm pointing at when I say that stack
> > > > usage outside XFS has grown significantly significantly over the
> > > > past couple of years. Given XFS has remained pretty much the same or
> > > > even reduced slightly over the same time period, blaming XFS or
> > > > saying "callers should use GFP_NOFS" seems like a cop-out to me.
> > > > Regardless of the IO pattern performance issues, writeback via
> > > > direct reclaim just uses too much stack to be safe these days...
> > > 
> > > Yeah, My answer is simple, All stack eater should be fixed.
> > > but XFS seems not innocence too. 3.5K is enough big although
> > > xfs have use such amount since very ago.
> > 
> > XFS used to use much more than that - significant effort has been
> > put into reduce the stack footprint over many years. There's not
> > much left to trim without rewriting half the filesystem...
> 
> I don't think he is levelling a complain at XFS in particular - just pointing
> out that it's heavy too. Still, we should be gratful that XFS is sort of
> a "Stack Canary". If it dies, everyone else could be in trouble soon :)

Yeah, true. Sorry N?f in being a bit too defensive here - the scars
from previous discussions like this are showing through....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
