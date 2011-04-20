Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 7A6018D003B
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 11:22:17 -0400 (EDT)
Date: Wed, 20 Apr 2011 17:22:11 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 5/6] writeback: try more writeback as long as something
 was written
Message-ID: <20110420152211.GC4991@quack.suse.cz>
References: <20110419030003.108796967@intel.com>
 <20110419030532.778889102@intel.com>
 <20110419102016.GD5257@quack.suse.cz>
 <20110419111601.GA18961@localhost>
 <20110419211008.GD9556@quack.suse.cz>
 <20110420075053.GB30672@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110420075053.GB30672@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@linux.vnet.ibm.com>, Dave Chinner <david@fromorbit.com>, Trond Myklebust <Trond.Myklebust@netapp.com>, Itaru Kitayama <kitayama@cl.bb4u.ne.jp>, Minchan Kim <minchan.kim@gmail.com>, LKML <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

On Wed 20-04-11 15:50:53, Wu Fengguang wrote:
> > > >   Let me understand your concern here: You are afraid that if we do
> > > > for_background or for_kupdate writeback and we write less than
> > > > MAX_WRITEBACK_PAGES, we stop doing writeback although there could be more
> > > > inodes to write at the time we are stopping writeback - the two realistic
> > > 
> > > Yes.
> > > 
> > > > cases I can think of are:
> > > > a) when inodes just freshly expired during writeback
> > > > b) when bdi has less than MAX_WRITEBACK_PAGES of dirty data but we are over
> > > >   background threshold due to data on some other bdi. And then while we are
> > > >   doing writeback someone does dirtying at our bdi.
> > > > Or do you see some other case as well?
> > > > 
> > > > The a) case does not seem like a big issue to me after your changes to
> > > 
> > > Yeah (a) is not an issue with kupdate writeback.
> > > 
> > > > move_expired_inodes(). The b) case maybe but do you think it will make any
> > > > difference? 
> > > 
> > > (b) seems also weird. What in my mind is this for_background case.
> > > Imagine 100 inodes
> > > 
> > >         i0, i1, i2, ..., i90, i91, i99
> > > 
> > > At queue_io() time, i90-i99 happen to be expired and moved to s_io for
> > > IO. When finished successfully, if their total size is less than
> > > MAX_WRITEBACK_PAGES, nr_to_write will be > 0. Then wb_writeback() will
> > > quit the background work (w/o this patch) while it's still over
> > > background threshold.
> > > 
> > > This will be a fairly normal/frequent case I guess.
> >   Ah OK, I see. I missed this case your patch set has added. Also your
> > changes of
> >         if (!wbc->for_kupdate || list_empty(&wb->b_io))
> > to
> > 	if (list_empty(&wb->b_io))
> > are going to cause more cases when we'd hit nr_to_write > 0 (e.g. when one
> > pass of b_io does not write all the inodes so some are left in b_io list
> > and then next call to writeback finds these inodes there but there's less
> > than MAX_WRITEBACK_PAGES in them).
> 
> Yes. It's exactly the more aggressive retry logic in wb_writeback()
> that allows me to comfortably kill that !wbc->for_kupdate test :)
> 
> > Frankly, it makes me like the above change even less. I'd rather see
> > writeback_inodes_wb / __writeback_inodes_sb always work on a fresh
> > set of inodes which is initialized whenever we enter these
> > functions. It just seems less surprising to me...
> 
> The old aggressive enqueue policy is an ad-hoc workaround to prevent
> background work to miss some inodes and quit early. Now that we have
> the complete solution, why not killing it for more consistent code and
> behavior? And get better performance numbers :)
  BTW, have you understood why do you get better numbers? What are we doing
better with this changed logic?

I've though about it and also about Dave's analysis. Now I think it's OK to
not add new inodes to b_io when it's not empty. But what I still don't like
is that the emptiness / non-emptiness of b_io carries hidden internal
state - callers of writeback_inodes_wb() shouldn't have to know or care
about such subtleties (__writeback_inodes_sb() is an internal function so I
don't care about that one too much).

So I'd prefer writeback_inodes_wb() (and also __writeback_inodes_sb() but
that's not too important) to do something like:
	int requeued = 0;
requeue:
	if (list_empty(&wb->b_io)) {
		queue_io(wb, wbc->older_than_this);
		requeued = 1;
	}
	while (!list_empty(&wb->b_io)) {
		... do stuff ...
	}
	if (wbc->nr_to_write > 0 && !requeued)
		goto requeue;

Because if you don't do this, you have to do similar change to all the
callers of writeback_inodes_wb() (Ok, there are just three but still).

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
