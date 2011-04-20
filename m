Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id C17CB8D003B
	for <linux-mm@kvack.org>; Tue, 19 Apr 2011 21:21:27 -0400 (EDT)
Date: Wed, 20 Apr 2011 11:21:20 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 3/6] writeback: sync expired inodes first in background
 writeback
Message-ID: <20110420012120.GK23985@dastard>
References: <20110419030003.108796967@intel.com>
 <20110419030532.515923886@intel.com>
 <20110419073523.GF23985@dastard>
 <20110419095740.GC5257@quack.suse.cz>
 <20110419125616.GA20059@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110419125616.GA20059@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@linux.vnet.ibm.com>, Mel Gorman <mel@csn.ul.ie>, Trond Myklebust <Trond.Myklebust@netapp.com>, Itaru Kitayama <kitayama@cl.bb4u.ne.jp>, Minchan Kim <minchan.kim@gmail.com>, LKML <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

On Tue, Apr 19, 2011 at 08:56:16PM +0800, Wu Fengguang wrote:
> On Tue, Apr 19, 2011 at 05:57:40PM +0800, Jan Kara wrote:
> > On Tue 19-04-11 17:35:23, Dave Chinner wrote:
> > > On Tue, Apr 19, 2011 at 11:00:06AM +0800, Wu Fengguang wrote:
> > > > A background flush work may run for ever. So it's reasonable for it to
> > > > mimic the kupdate behavior of syncing old/expired inodes first.
> > > > 
> > > > The policy is
> > > > - enqueue all newly expired inodes at each queue_io() time
> > > > - enqueue all dirty inodes if there are no more expired inodes to sync
> > > > 
> > > > This will help reduce the number of dirty pages encountered by page
> > > > reclaim, eg. the pageout() calls. Normally older inodes contain older
> > > > dirty pages, which are more close to the end of the LRU lists. So
> > > > syncing older inodes first helps reducing the dirty pages reached by
> > > > the page reclaim code.
> > > 
> > > Once again I think this is the wrong place to be changing writeback
> > > policy decisions. for_background writeback only goes through
> > > wb_writeback() and writeback_inodes_wb() (same as for_kupdate
> > > writeback), so a decision to change from expired inodes to fresh
> > > inodes, IMO, should be made in wb_writeback.
> > > 
> > > That is, for_background and for_kupdate writeback start with the
> > > same policy (older_than_this set) to writeback expired inodes first,
> > > then when background writeback runs out of expired inodes, it should
> > > switch to all remaining inodes by clearing older_than_this instead
> > > of refreshing it for the next loop.
> >   Yes, I agree with this and my impression is that Fengguang is trying to
> > achieve exactly this behavior.
> > 
> > > This keeps all the policy decisions in the one place, all using the
> > > same (existing) mechanism, and all relatively simple to understand,
> > > and easy to tracepoint for debugging.  Changing writeback policy
> > > deep in the writeback stack is not a good idea as it will make
> > > extending writeback policies in future (e.g. for cgroup awareness)
> > > very messy.
> >   Hmm, I see. I agree the policy decisions should be at one place if
> > reasonably possible. Fengguang moves them from wb_writeback() to inode
> > queueing code which looks like a logical place to me as well - there we
> > have the largest control over what inodes do we decide to write and don't
> > have to pass all the detailed 'instructions' down in wbc structure. So if
> > we later want to add cgroup awareness to writeback, I imagine we just add
> > the knowledge to inode queueing code.
> 
> I actually started with wb_writeback() as a natural choice, and then
> found it much easier to do the expired-only=>all-inodes switching in
> move_expired_inodes() since it needs to know the @b_dirty and @tmp
> lists' emptiness to trigger the switch. It's not sane for
> wb_writeback() to look into such details. And once you do the switch
> part in move_expired_inodes(), the whole policy naturally follows.

Well, not really. You didn't need to modify move_expired_inodes() at
all to implement these changes - all you needed to do was modify how
older_than_this is configured.

writeback policy is defined by the struct writeback_control.
move_expired_inodes() is pure mechanism. What you've done is remove
policy from the struct wbc and moved it to move_expired_inodes(),
which now defines both policy and mechanism.

Furhter, this means that all the tracing that uses the struct wbc no
no longer shows the entire writeback policy that is being worked on,
so we lose visibility into policy decisions that writeback is
making.

This same change is as simple as updating wbc->older_than_this
appropriately after the wb_writeback() call for both background and
kupdate and leaving the lower layers untouched. It's just a policy
change. If you thinkthe mechanism is inefficient, copy
wbc->older_than_this to a local variable inside
move_expired_inodes()....

> > > > @@ -585,7 +597,8 @@ void writeback_inodes_wb(struct bdi_writ
> > > >  	if (!wbc->wb_start)
> > > >  		wbc->wb_start = jiffies; /* livelock avoidance */
> > > >  	spin_lock(&inode_wb_list_lock);
> > > > -	if (!wbc->for_kupdate || list_empty(&wb->b_io))
> > > > +
> > > > +	if (list_empty(&wb->b_io))
> > > >  		queue_io(wb, wbc);
> > > >  
> > > >  	while (!list_empty(&wb->b_io)) {
> > > > @@ -612,7 +625,7 @@ static void __writeback_inodes_sb(struct
> > > >  	WARN_ON(!rwsem_is_locked(&sb->s_umount));
> > > >  
> > > >  	spin_lock(&inode_wb_list_lock);
> > > > -	if (!wbc->for_kupdate || list_empty(&wb->b_io))
> > > > +	if (list_empty(&wb->b_io))
> > > >  		queue_io(wb, wbc);
> > > >  	writeback_sb_inodes(sb, wb, wbc, true);
> > > >  	spin_unlock(&inode_wb_list_lock);
> > > 
> > > That changes the order in which we queue inodes for writeback.
> > > Instead of calling every time to move b_more_io inodes onto the b_io
> > > list and expiring more aged inodes, we only ever do it when the list
> > > is empty. That is, it seems to me that this will tend to give
> > > b_more_io inodes a smaller share of writeback because they are being
> > > moved back to the b_io list less frequently where there are lots of
> > > other inodes being dirtied. Have you tested the impact of this
> > > change on mixed workload performance? Indeed, can you starve
> > > writeback of a large file simply by creating lots of small files in
> > > another thread?
> >   Yeah, this change looks suspicious to me as well.
> 
> The exact behaviors are indeed rather complex. I personally feel the
> new "always refill iff empty" policy more consistent, clean and easy
> to understand.

That may be so, but that doesn't make the change good from an IO
perspective. You said you'd only done light testing, and that's not
sufficient to guage the impact of such a change.

> It basically says: at each round started by a b_io refill, setup a
> _fixed_ work set with all current expired (or all currently dirtied
> inodes if non is expired) and walk through it. "Fixed" work set means
> no new inodes will be added to the work set during the walk.  When a
> complete walk is done, start over with a new set of inodes that are
> eligible at the time.

Yes, I know what it does - I can read the code. You haven't however,
answered why it is a good change from an IO persepctive, however.

> The figure in page 14 illustrates the "rounds" idea:
> http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/slides/linux-writeback-queues.pdf
> 
> This procedure provides fairness among the inodes and guarantees each
> inode to be synced once and only once at each round. So it's free from
> starvations.

Perhaps you should add some of this commentary to the commit
message? That talks about the VM and LRU writeback, but that has
nothing to do with writeback fairness. The commit message or
comments in the code need to explain why something is being
changed....

> 
> If you are worried about performance, here is a simple tar+dd benchmark.
> Both commands are actually running faster with this patchset:
.....
> The base kernel is 2.6.39-rc3+ plus IO-less patchset plus large write
> chunk size. The test box has 3G mem and runs XFS. Test script is:

<sigh>

The numbers are meaningless to me - you've got a large number of
other changes that are affecting writeback behaviour, and that's
especially important because, at minimum, the change in write chunk
size will hide any differences in IO patterns that this change will
make. Please test against a vanilla kernel if that is what you are
aiming these patches for. If you aren't aiming for a vanilla kernel,
please say so in the patch series header...

Anyway, I'm going to put some numbers into a hypothetical steady
state situation to demonstrate the differences in algorithms.
Let's say we have lots of inodes with 100 dirty pages being created,
and one large writeback going on. We expire 8 new inodes for every
1024 pages we write back.

With the old code, we do:

	b_more_io (large inode) -> b_io (1l)
	8 newly expired inodes -> b_io (1l, 8s)

	writeback  large inode 1024 pages -> b_more_io

	b_more_io (large inode) -> b_io (8s, 1l)
	8 newly expired inodes -> b_io (8s, 1l, 8s)

	writeback  8 small inodes 800 pages
		   1 large inode 224 pages -> b_more_io

	b_more_io (large inode) -> b_io (8s, 1l)
	8 newly expired inodes -> b_io (8s, 1l, 8s)
	.....

Your new code:

	b_more_io (large inode) -> b_io (1l)
	8 newly expired inodes -> b_io (1l, 8s)

	writeback  large inode 1024 pages -> b_more_io
	(b_io == 8s)
	writeback  8 small inodes 800 pages

	b_io empty: (1800 pages written)
		b_more_io (large inode) -> b_io (1l)
		14 newly expired inodes -> b_io (1l, 14s)

	writeback  large inode 1024 pages -> b_more_io
	(b_io == 14s)
	writeback  10 small inodes 1000 pages
		   1 small inode 24 pages -> b_more_io (1l, 1s(24))
	writeback  5 small inodes 500 pages
	b_io empty: (2548 pages written)
		b_more_io (large inode) -> b_io (1l, 1s(24))
		20 newly expired inodes -> b_io (1l, 1s(24), 20s)
	......

Rough progression of pages written at b_io refill:

Old code:

	total	large file	% of writeback
	1024	224		21.9% (fixed)
	
New code:
	total	large file	% of writeback
	1800	1024		~55%
	2550	1024		~40%
	3050	1024		~33%
	3500	1024		~29%
	3950	1024		~26%
	4250	1024		~24%
	4500	1024		~22.7%
	4700	1024		~21.7%
	4800	1024		~21.3%
	4800	1024		~21.3%
	(pretty much steady state from here)

Ok, so the steady state is reached with a similar percentage of
writeback to the large file as the existing code. Ok, that's good,
but providing some evidence that is doesn't change the shared of
writeback to the large should be in the commit message ;)

The other advantage to this is that we always write 1024 page chunks
to the large file, rather than smaller "whatever remains" chunks. I
think this will have a bigger effect on a vanilla kernel than on the
kernel you tested on above because of the smaller writeback chunk
size.

I'm convinced that the refilling only when the queue is empty is a
sane change now. you need to separate this from the
move_expired_inodes() changes because it is doing something very
different to writeback.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
