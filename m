Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id A5D5A600365
	for <linux-mm@kvack.org>; Tue, 27 Jul 2010 05:45:54 -0400 (EDT)
Date: Tue, 27 Jul 2010 10:45:34 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 4/6] writeback: sync expired inodes first in background
	writeback
Message-ID: <20100727094534.GW5300@csn.ul.ie>
References: <20100722050928.653312535@intel.com> <20100722061822.906037624@intel.com> <20100726105736.GM5300@csn.ul.ie> <20100726125635.GC11947@localhost> <20100726125954.GT5300@csn.ul.ie> <20100726131152.GF11947@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100726131152.GF11947@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@infradead.org>, Chris Mason <chris.mason@oracle.com>, Jens Axboe <jens.axboe@oracle.com>, LKML <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, Jul 26, 2010 at 09:11:52PM +0800, Wu Fengguang wrote:
> On Mon, Jul 26, 2010 at 08:59:55PM +0800, Mel Gorman wrote:
> > On Mon, Jul 26, 2010 at 08:56:35PM +0800, Wu Fengguang wrote:
> > > > > @@ -232,8 +232,15 @@ static void move_expired_inodes(struct l
> > > > >  	while (!list_empty(delaying_queue)) {
> > > > >  		inode = list_entry(delaying_queue->prev, struct inode, i_list);
> > > > >  		if (expire_interval &&
> > > > > -		    inode_dirtied_after(inode, older_than_this))
> > > > > -			break;
> > > > > +		    inode_dirtied_after(inode, older_than_this)) {
> > > > > +			if (wbc->for_background &&
> > > > > +			    list_empty(dispatch_queue) && list_empty(&tmp)) {
> > > > > +				expire_interval >>= 1;
> > > > > +				older_than_this = jiffies - expire_interval;
> > > > > +				continue;
> > > > > +			} else
> > > > > +				break;
> > > > > +		}
> > > > 
> > > > This needs a comment.
> > > > 
> > > > I think what it is saying is that if background flush is active but no
> > > > inodes are old enough, consider newer inodes. This is on the assumption
> > > > that page reclaim has encountered dirty pages and the dirty inodes are
> > > > still too young.
> > > 
> > > Yes this should be commented. How about this one?
> > > 
> > > @@ -232,8 +232,20 @@ static void move_expired_inodes(struct l
> > >         while (!list_empty(delaying_queue)) {
> > >                 inode = list_entry(delaying_queue->prev, struct inode, i_list);
> > >                 if (expire_interval &&
> > > -                   inode_dirtied_after(inode, older_than_this))
> > > +                   inode_dirtied_after(inode, older_than_this)) {
> > > +                       /*
> > > +                        * background writeback will start with expired inodes,
> > > +                        * and then fresh inodes. This order helps reducing
> > > +                        * the number of dirty pages reaching the end of LRU
> > > +                        * lists and cause trouble to the page reclaim.
> > > +                        */
> > 
> > s/reducing/reduce/
> > 
> > Otherwise, it's enough detail to know what is going on. Thanks
> 
> Thanks. Here is the updated patch.
> ---
> Subject: writeback: sync expired inodes first in background writeback
> From: Wu Fengguang <fengguang.wu@intel.com>
> Date: Wed Jul 21 20:11:53 CST 2010
> 
> A background flush work may run for ever. So it's reasonable for it to
> mimic the kupdate behavior of syncing old/expired inodes first.
> 
> The policy is
> - enqueue all newly expired inodes at each queue_io() time
> - enqueue all dirty inodes if there are no more expired inodes to sync
> 
> This will help reduce the number of dirty pages encountered by page
> reclaim, eg. the pageout() calls. Normally older inodes contain older
> dirty pages, which are more close to the end of the LRU lists. So
> syncing older inodes first helps reducing the dirty pages reached by
> the page reclaim code.
> 
> CC: Jan Kara <jack@suse.cz>
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>

Acked-by: Mel Gorman <mel@csn.ul.ie>

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
