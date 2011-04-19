Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 503C5900086
	for <linux-mm@kvack.org>; Tue, 19 Apr 2011 06:20:21 -0400 (EDT)
Date: Tue, 19 Apr 2011 12:20:16 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 5/6] writeback: try more writeback as long as something
 was written
Message-ID: <20110419102016.GD5257@quack.suse.cz>
References: <20110419030003.108796967@intel.com>
 <20110419030532.778889102@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110419030532.778889102@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mel Gorman <mel@linux.vnet.ibm.com>, Dave Chinner <david@fromorbit.com>, Trond Myklebust <Trond.Myklebust@netapp.com>, Itaru Kitayama <kitayama@cl.bb4u.ne.jp>, Minchan Kim <minchan.kim@gmail.com>, LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>

On Tue 19-04-11 11:00:08, Wu Fengguang wrote:
> writeback_inodes_wb()/__writeback_inodes_sb() are not aggressive in that
> they only populate possibly a subset of elegible inodes into b_io at
> entrance time. When the queued set of inodes are all synced, they just
> return, possibly with all queued inode pages written but still
> wbc.nr_to_write > 0.
> 
> For kupdate and background writeback, there may be more eligible inodes
> sitting in b_dirty when the current set of b_io inodes are completed. So
> it is necessary to try another round of writeback as long as we made some
> progress in this round. When there are no more eligible inodes, no more
> inodes will be enqueued in queue_io(), hence nothing could/will be
> synced and we may safely bail.
  Let me understand your concern here: You are afraid that if we do
for_background or for_kupdate writeback and we write less than
MAX_WRITEBACK_PAGES, we stop doing writeback although there could be more
inodes to write at the time we are stopping writeback - the two realistic
cases I can think of are:
a) when inodes just freshly expired during writeback
b) when bdi has less than MAX_WRITEBACK_PAGES of dirty data but we are over
  background threshold due to data on some other bdi. And then while we are
  doing writeback someone does dirtying at our bdi.
Or do you see some other case as well?

The a) case does not seem like a big issue to me after your changes to
move_expired_inodes(). The b) case maybe but do you think it will make any
difference? 

								Honza
> 
> Jan raised the concern
> 
> 	I'm just afraid that in some pathological cases this could
> 	result in bad writeback pattern - like if there is some process
> 	which manages to dirty just a few pages while we are doing
> 	writeout, this looping could result in writing just a few pages
> 	in each round which is bad for fragmentation etc.
> 
> However it requires really strong timing to make that to (continuously)
> happen.  In practice it's very hard to produce such a pattern even if
> it's possible in theory. I actually tried to write 1 page per 1ms with
> this command
> 
> 	write-and-fsync -n10000 -S 1000 -c 4096 /fs/test
> 
> and do sync(1) at the same time. The sync completes quickly on ext4,
> xfs, btrfs. The readers could try other write-and-sleep patterns and
> check if it can block sync for longer time.
> 
> CC: Jan Kara <jack@suse.cz>
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> ---
>  fs/fs-writeback.c |   16 ++++++++--------
>  1 file changed, 8 insertions(+), 8 deletions(-)
> 
> --- linux-next.orig/fs/fs-writeback.c	2011-04-19 10:18:30.000000000 +0800
> +++ linux-next/fs/fs-writeback.c	2011-04-19 10:18:31.000000000 +0800
> @@ -750,23 +750,23 @@ static long wb_writeback(struct bdi_writ
>  		wrote += write_chunk - wbc.nr_to_write;
>  
>  		/*
> -		 * If we consumed everything, see if we have more
> +		 * Did we write something? Try for more
> +		 *
> +		 * Dirty inodes are moved to b_io for writeback in batches.
> +		 * The completion of the current batch does not necessarily
> +		 * mean the overall work is done. So we keep looping as long
> +		 * as made some progress on cleaning pages or inodes.
>  		 */
> -		if (wbc.nr_to_write <= 0)
> +		if (wbc.nr_to_write < write_chunk)
>  			continue;
>  		if (wbc.inodes_cleaned)
>  			continue;
>  		/*
> -		 * Didn't write everything and we don't have more IO, bail
> +		 * No more inodes for IO, bail
>  		 */
>  		if (!wbc.more_io)
>  			break;
>  		/*
> -		 * Did we write something? Try for more
> -		 */
> -		if (wbc.nr_to_write < write_chunk)
> -			continue;
> -		/*
>  		 * Nothing written. Wait for some inode to
>  		 * become available for writeback. Otherwise
>  		 * we'll just busyloop.
> 
> 
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
