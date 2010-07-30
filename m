Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id DE7F06B02A4
	for <linux-mm@kvack.org>; Fri, 30 Jul 2010 01:17:50 -0400 (EDT)
Date: Fri, 30 Jul 2010 13:17:46 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 3/5] writeback: prevent sync livelock with the
 sync_after timestamp
Message-ID: <20100730051746.GB8811@localhost>
References: <20100729115142.102255590@intel.com>
 <20100729121423.471866750@intel.com>
 <20100729150241.GC12690@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100729150241.GC12690@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
To: Jan Kara <jack@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

On Thu, Jul 29, 2010 at 11:02:41PM +0800, Jan Kara wrote:
>   Hi Fengguang,
> 
> On Thu 29-07-10 19:51:45, Wu Fengguang wrote:
> > The start time in writeback_inodes_wb() is not very useful because it
> > slips at each invocation time. Preferrably one _constant_ time shall be
> > used at the beginning to cover the whole sync() work.
> > 
> > The newly dirtied inodes are now guarded at the queue_io() time instead
> > of the b_io walk time. This is more natural: non-empty b_io/b_more_io
> > means "more work pending".
> > 
> > The timestamp is now grabbed the sync work submission time, and may be
> > further optimized to the initial sync() call time.
>   The patch seems to have some issues...
> 
> > +	if (wbc->for_sync) {
>   For example this is never set. You only set wb->for_sync.

Ah right.

> > +		expire_interval = 1;
> > +		older_than_this = wbc->sync_after;
>   And sync_after is never set either???

Sorry I must lose some chunk when rebasing the patch ..

> > -	if (!(wbc->for_kupdate || wbc->for_background) || list_empty(&wb->b_io))
> > +	if (list_empty(&wb->b_io))
> >  		queue_io(wb, wbc);
>   And what is the purpose of this? It looks as an unrelated change to me.

Yes it's not tightly related. It may be simpler to do

 -	if (!wbc->for_kupdate || list_empty(&wb->b_io))
 +	if (list_empty(&wb->b_io))

in the previous patch "writeback: sync expired inodes first in
background writeback".

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
