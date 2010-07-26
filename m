Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 296446007FA
	for <linux-mm@kvack.org>; Mon, 26 Jul 2010 09:00:14 -0400 (EDT)
Date: Mon, 26 Jul 2010 13:59:55 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 4/6] writeback: sync expired inodes first in background
	writeback
Message-ID: <20100726125954.GT5300@csn.ul.ie>
References: <20100722050928.653312535@intel.com> <20100722061822.906037624@intel.com> <20100726105736.GM5300@csn.ul.ie> <20100726125635.GC11947@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100726125635.GC11947@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@infradead.org>, Chris Mason <chris.mason@oracle.com>, Jens Axboe <jens.axboe@oracle.com>, LKML <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, Jul 26, 2010 at 08:56:35PM +0800, Wu Fengguang wrote:
> > > @@ -232,8 +232,15 @@ static void move_expired_inodes(struct l
> > >  	while (!list_empty(delaying_queue)) {
> > >  		inode = list_entry(delaying_queue->prev, struct inode, i_list);
> > >  		if (expire_interval &&
> > > -		    inode_dirtied_after(inode, older_than_this))
> > > -			break;
> > > +		    inode_dirtied_after(inode, older_than_this)) {
> > > +			if (wbc->for_background &&
> > > +			    list_empty(dispatch_queue) && list_empty(&tmp)) {
> > > +				expire_interval >>= 1;
> > > +				older_than_this = jiffies - expire_interval;
> > > +				continue;
> > > +			} else
> > > +				break;
> > > +		}
> > 
> > This needs a comment.
> > 
> > I think what it is saying is that if background flush is active but no
> > inodes are old enough, consider newer inodes. This is on the assumption
> > that page reclaim has encountered dirty pages and the dirty inodes are
> > still too young.
> 
> Yes this should be commented. How about this one?
> 
> @@ -232,8 +232,20 @@ static void move_expired_inodes(struct l
>         while (!list_empty(delaying_queue)) {
>                 inode = list_entry(delaying_queue->prev, struct inode, i_list);
>                 if (expire_interval &&
> -                   inode_dirtied_after(inode, older_than_this))
> +                   inode_dirtied_after(inode, older_than_this)) {
> +                       /*
> +                        * background writeback will start with expired inodes,
> +                        * and then fresh inodes. This order helps reducing
> +                        * the number of dirty pages reaching the end of LRU
> +                        * lists and cause trouble to the page reclaim.
> +                        */

s/reducing/reduce/

Otherwise, it's enough detail to know what is going on. Thanks

Thanks

> +                       if (wbc->for_background &&
> +                           list_empty(dispatch_queue) && list_empty(&tmp)) {
> +                               expire_interval = 0;
> +                               continue;
> +                       }
>                         break;
> +               }
>                 if (sb && sb != inode->i_sb)
>                         do_sb_sort = 1;
>                 sb = inode->i_sb;
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
