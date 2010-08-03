Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id DB2DC6008E4
	for <linux-mm@kvack.org>; Tue,  3 Aug 2010 06:48:36 -0400 (EDT)
Date: Tue, 3 Aug 2010 12:55:20 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 2/5] writeback: stop periodic/background work on seeing
 sync works
Message-ID: <20100803105520.GA3322@quack.suse.cz>
References: <20100729115142.102255590@intel.com>
 <20100729121423.332557547@intel.com>
 <20100729162027.GF12690@quack.suse.cz>
 <20100730040306.GA5694@localhost>
 <20100802205152.GL3278@quack.suse.cz>
 <20100803030125.GA12070@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100803030125.GA12070@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

On Tue 03-08-10 11:01:25, Wu Fengguang wrote:
> On Tue, Aug 03, 2010 at 04:51:52AM +0800, Jan Kara wrote:
> > On Fri 30-07-10 12:03:06, Wu Fengguang wrote:
> > > On Fri, Jul 30, 2010 at 12:20:27AM +0800, Jan Kara wrote:
> > > > On Thu 29-07-10 19:51:44, Wu Fengguang wrote:
> > > > > The periodic/background writeback can run forever. So when any
> > > > > sync work is enqueued, increase bdi->sync_works to notify the
> > > > > active non-sync works to exit. Non-sync works queued after sync
> > > > > works won't be affected.
> > > >   Hmm, wouldn't it be simpler logic to just make for_kupdate and
> > > > for_background work always yield when there's some other work to do (as
> > > > they are livelockable from the definition of the target they have) and
> > > > make sure any other work isn't livelockable?
> > > 
> > > Good idea!
> > > 
> > > > The only downside is that
> > > > non-livelockable work cannot be "fair" in the sense that we cannot switch
> > > > inodes after writing MAX_WRITEBACK_PAGES.
> > > 
> > > Cannot switch indoes _before_ finish with the current
> > > MAX_WRITEBACK_PAGES batch? 
> >   Well, even after writing all those MAX_WRITEBACK_PAGES. Because what you
> > want to do in a non-livelockable work is: take inode, write it, never look at
> > it again for this work. Because if you later return to the inode, it can
> > have newer dirty pages and thus you cannot really avoid livelock. Of
> > course, this all assumes .nr_to_write isn't set to something small. That
> > avoids the livelock as well.
> 
> I do have a poor man's solution that can handle this case.
> https://kerneltrap.org/mailarchive/linux-fsdevel/2009/10/7/6476473/thread
> It may do more extra works, but will stop livelock in theory.
  So I don't think sync work on it's own is a problem. There we can just
give up any fairness and just go inode by inode. IMHO it's much simpler that
way. The remaining types of work we have are "for_reclaim" and then ones
triggered by filesystems to get rid of delayed allocated data. These cases
can easily have well defined and low nr_to_write so they wouldn't be
livelockable either. What do you think?

> A related question is, what if some for_reclaim works get enqueued?
> Shall we postpone the sync work as well? The global sync is not likely
> to hit the dirty pages in a small memcg, or may take long time. It
> seems not a high priority task though.
  I see some incentive to do this but the simple thing with for_background
and for_kupdate work is that they are essentially state-less and so they
can be easily (and automatically) restarted. It would be really hard to
implement something like this for sync and still avoid livelocks.

> > > >   I even had a patch for this but it's already outdated by now. But I
> > > > can refresh it if we decide this is the way to go.
> > > 
> > > I'm very interested in your old patch, would you post it? Let's see
> > > which one is easier to work with :)
> >   OK, attached is the patch. I've rebased it against 2.6.35.
> > 									Honza
> > -- 
> > Jan Kara <jack@suse.cz>
> > SUSE Labs, CR
> 
> > From a6df0d4db148f983fe756df4791409db28dff459 Mon Sep 17 00:00:00 2001
> > From: Jan Kara <jack@suse.cz>
> > Date: Mon, 2 Aug 2010 22:30:25 +0200
> > Subject: [PATCH] mm: Stop background writeback if there is other work queued for the thread
> > 
> > Background writeback and kupdate-style writeback are easily livelockable
> > (from a definition of their target). This is inconvenient because it can
> > make sync(1) stall forever waiting on its queued work to be finished.
> > Fix the problem by interrupting background and kupdate writeback if there
> > is some other work to do. We can return to them after completing all the
> > queued work.
> > 
> > Signed-off-by: Jan Kara <jack@suse.cz>
> > ---
> >  fs/fs-writeback.c |    8 ++++++++
> >  1 files changed, 8 insertions(+), 0 deletions(-)
> > 
> > diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
> > index d5be169..542471e 100644
> > --- a/fs/fs-writeback.c
> > +++ b/fs/fs-writeback.c
> > @@ -633,6 +633,14 @@ static long wb_writeback(struct bdi_writeback *wb,
> >  			break;
> >  
> >  		/*
> > +		 * Background writeout and kupdate-style writeback are
> > +		 * easily livelockable. Stop them if there is other work
> > +		 * to do so that e.g. sync can proceed.
> > +		 */
> > +		if ((work->for_background || work->for_kupdate) &&
> > +		    !list_empty(&wb->bdi->work_list))
> > +			break;
> > +		/*
> 
> I like it. It's much simpler.
> 
> Reviewed-by: Wu Fengguang <fengguang.wu@intel.com>
  Thanks. I think I'll try to get this merged via Jens' tree in this
merge window.

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
