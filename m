Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id CF19D8D003B
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 03:50:57 -0400 (EDT)
Date: Wed, 20 Apr 2011 15:50:53 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 5/6] writeback: try more writeback as long as something
 was written
Message-ID: <20110420075053.GB30672@localhost>
References: <20110419030003.108796967@intel.com>
 <20110419030532.778889102@intel.com>
 <20110419102016.GD5257@quack.suse.cz>
 <20110419111601.GA18961@localhost>
 <20110419211008.GD9556@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110419211008.GD9556@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@linux.vnet.ibm.com>, Dave Chinner <david@fromorbit.com>, Trond Myklebust <Trond.Myklebust@netapp.com>, Itaru Kitayama <kitayama@cl.bb4u.ne.jp>, Minchan Kim <minchan.kim@gmail.com>, LKML <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

On Wed, Apr 20, 2011 at 05:10:08AM +0800, Jan Kara wrote:
> On Tue 19-04-11 19:16:01, Wu Fengguang wrote:
> > On Tue, Apr 19, 2011 at 06:20:16PM +0800, Jan Kara wrote:
> > > On Tue 19-04-11 11:00:08, Wu Fengguang wrote:
> > > > writeback_inodes_wb()/__writeback_inodes_sb() are not aggressive in that
> > > > they only populate possibly a subset of elegible inodes into b_io at
> > > > entrance time. When the queued set of inodes are all synced, they just
> > > > return, possibly with all queued inode pages written but still
> > > > wbc.nr_to_write > 0.
> > > > 
> > > > For kupdate and background writeback, there may be more eligible inodes
> > > > sitting in b_dirty when the current set of b_io inodes are completed. So
> > > > it is necessary to try another round of writeback as long as we made some
> > > > progress in this round. When there are no more eligible inodes, no more
> > > > inodes will be enqueued in queue_io(), hence nothing could/will be
> > > > synced and we may safely bail.
> > >   Let me understand your concern here: You are afraid that if we do
> > > for_background or for_kupdate writeback and we write less than
> > > MAX_WRITEBACK_PAGES, we stop doing writeback although there could be more
> > > inodes to write at the time we are stopping writeback - the two realistic
> > 
> > Yes.
> > 
> > > cases I can think of are:
> > > a) when inodes just freshly expired during writeback
> > > b) when bdi has less than MAX_WRITEBACK_PAGES of dirty data but we are over
> > >   background threshold due to data on some other bdi. And then while we are
> > >   doing writeback someone does dirtying at our bdi.
> > > Or do you see some other case as well?
> > > 
> > > The a) case does not seem like a big issue to me after your changes to
> > 
> > Yeah (a) is not an issue with kupdate writeback.
> > 
> > > move_expired_inodes(). The b) case maybe but do you think it will make any
> > > difference? 
> > 
> > (b) seems also weird. What in my mind is this for_background case.
> > Imagine 100 inodes
> > 
> >         i0, i1, i2, ..., i90, i91, i99
> > 
> > At queue_io() time, i90-i99 happen to be expired and moved to s_io for
> > IO. When finished successfully, if their total size is less than
> > MAX_WRITEBACK_PAGES, nr_to_write will be > 0. Then wb_writeback() will
> > quit the background work (w/o this patch) while it's still over
> > background threshold.
> > 
> > This will be a fairly normal/frequent case I guess.
>   Ah OK, I see. I missed this case your patch set has added. Also your
> changes of
>         if (!wbc->for_kupdate || list_empty(&wb->b_io))
> to
> 	if (list_empty(&wb->b_io))
> are going to cause more cases when we'd hit nr_to_write > 0 (e.g. when one
> pass of b_io does not write all the inodes so some are left in b_io list
> and then next call to writeback finds these inodes there but there's less
> than MAX_WRITEBACK_PAGES in them).

Yes. It's exactly the more aggressive retry logic in wb_writeback()
that allows me to comfortably kill that !wbc->for_kupdate test :)

> Frankly, it makes me like the above change even less. I'd rather see
> writeback_inodes_wb / __writeback_inodes_sb always work on a fresh
> set of inodes which is initialized whenever we enter these
> functions. It just seems less surprising to me...

The old aggressive enqueue policy is an ad-hoc workaround to prevent
background work to miss some inodes and quit early. Now that we have
the complete solution, why not killing it for more consistent code and
behavior? And get better performance numbers :)

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
