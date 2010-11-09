Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 553976B0087
	for <linux-mm@kvack.org>; Tue,  9 Nov 2010 18:01:03 -0500 (EST)
Date: Tue, 9 Nov 2010 15:00:06 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 3/5] writeback: stop background/kupdate works from
 livelocking other works
Message-Id: <20101109150006.05892241.akpm@linux-foundation.org>
In-Reply-To: <20101109222827.GJ4936@quack.suse.cz>
References: <20101108230916.826791396@intel.com>
	<20101108231726.993880740@intel.com>
	<20101109131310.f442d210.akpm@linux-foundation.org>
	<20101109222827.GJ4936@quack.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Jan Kara <jack@suse.cz>
Cc: Wu Fengguang <fengguang.wu@intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@lst.de>, Jan Engelhardt <jengelh@medozas.de>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, 9 Nov 2010 23:28:27 +0100
Jan Kara <jack@suse.cz> wrote:

>   Hi,
> 
> On Tue 09-11-10 13:13:10, Andrew Morton wrote:
> > On Tue, 09 Nov 2010 07:09:19 +0800
> > Wu Fengguang <fengguang.wu@intel.com> wrote:
> > I find the description to be somewhat incomplete...
>   OK, so let me fill in the gaps ;)
> 
> > > From: Jan Kara <jack@suse.cz>
> > > 
> > > Background writeback are easily livelockable (from a definition of their
> > > target).
> > 
> > *why* is background writeback easily livelockable?  Under which
> > circumstances does this happen and how does it come about?
> > 
> > > This is inconvenient because it can make sync(1) stall forever waiting
> > > on its queued work to be finished.
> > 
> > Again, why?  Because there are works queued from the flusher thread,
> > but that thread is stuck in a livelocked state in <unspecified code
> > location> so it is unable to service the other works?  But the pocess
> > which called sync() will as a last resort itself perform all the
> > required IO, will it not?  If so, how can it livelock?
>   New description which should address above questions:
> Background writeback is easily livelockable in a loop in wb_writeback() by
> a process continuously re-dirtying pages (or continuously appending to a
> file). This is in fact intended as the target of background writeback is to
> write dirty pages it can find as long as we are over
> dirty_background_threshold.

Well.  The objective of the kupdate function is utterly different.

> But the above behavior gets inconvenient at times because no other work
> queued in the flusher thread's queue gets processed. In particular,
> since e.g. sync(1) relies on flusher thread to do all the IO for it,

That's fixable by doing the work synchronously within sync_inodes_sb(),
rather than twiddling thumbs wasting a thread resource while waiting
for kernel threads to do it.  As an added bonus, this even makes cpu
time accounting more accurate ;)

Please remind me why we decided to hand the sync_inodes_sb() work off
to other threads?

> sync(1) can hang forever waiting for flusher thread to do the work.
> 
> Generally, when a flusher thread has some work queued, someone submitted
> the work to achieve a goal more specific than what background writeback
> does. Moreover by working on the specific work, we also reduce amount of
> dirty pages which is exactly the target of background writeout. So it makes
> sense to give specific work a priority over a generic page cleaning.
> 
> Thus we interrupt background writeback if there is some other work to do. We
> return to the background writeback after completing all the queued work.
> 
> Is it better now?
> 
> > > Generally, when a flusher thread has
> > > some work queued, someone submitted the work to achieve a goal more specific
> > > than what background writeback does. So it makes sense to give it a priority
> > > over a generic page cleaning.
> > > 
> > > Thus we interrupt background writeback if there is some other work to do. We
> > > return to the background writeback after completing all the queued work.
> > > 
> > > Signed-off-by: Jan Kara <jack@suse.cz>
> > > Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> > > ---
> > >  fs/fs-writeback.c |    9 +++++++++
> > >  1 file changed, 9 insertions(+)
> > > 
> > > --- linux-next.orig/fs/fs-writeback.c	2010-11-07 21:56:42.000000000 +0800
> > > +++ linux-next/fs/fs-writeback.c	2010-11-07 22:00:51.000000000 +0800
> > > @@ -651,6 +651,15 @@ static long wb_writeback(struct bdi_writ
> > >  			break;
> > >  
> > >  		/*
> > > +		 * Background writeout and kupdate-style writeback are
> > > +		 * easily livelockable. Stop them if there is other work
> > > +		 * to do so that e.g. sync can proceed.
> > > +		 */
> > > +		if ((work->for_background || work->for_kupdate) &&
> > > +		    !list_empty(&wb->bdi->work_list))
> > > +			break;
> > > +
> > > +		/*
> > >  		 * For background writeout, stop when we are below the
> > >  		 * background dirty threshold
> > >  		 */
> > 
> > So...  what prevents higher priority works (eg, sync(1)) from
> > livelocking or seriously retarding background or kudate writeout?
>   If other work than background or kupdate writeout livelocks, it's a bug
> which should be fixed (either by setting sensible nr_to_write or by tagging
> like we do it for WB_SYNC_ALL writeback). Of course, higher priority work
> can be running when background or kupdate writeout would need to run as
> well. But the idea here is that the purpose of background/kupdate types of
> writeout is to get rid of dirty data and any type of writeout does this so
> working on it we also work on background/kupdate writeout only possibly
> less efficiently.

The kupdate function is a data-integrity/quality-of-service sort of
thing.

And what I'm asking is whether this change enables scenarios in which
these threads can be kept so busy that the kupdate function gets
interrupted so frequently that we can have dirty memory not being
written back for arbitrarily long periods of time?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
