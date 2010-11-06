Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id C0E6D6B00BF
	for <linux-mm@kvack.org>; Fri,  5 Nov 2010 21:36:23 -0400 (EDT)
Date: Sat, 6 Nov 2010 02:36:14 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm: Avoid livelocking of WB_SYNC_ALL writeback
Message-ID: <20101106013613.GE23393@cmpxchg.org>
References: <1288992383-25475-1-git-send-email-jack@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1288992383-25475-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
To: Jan Kara <jack@suse.cz>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Christoph Hellwig <hch@lst.de>, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Can you please keep linux-mm@kvack.org in the loop on writeback stuff?

I Cc'd it now, here is the full quote:

On Fri, Nov 05, 2010 at 10:26:23PM +0100, Jan Kara wrote:
> When wb_writeback() is called in WB_SYNC_ALL mode, work->nr_to_write is usually
> set to LONG_MAX. The logic in wb_writeback() then calls __writeback_inodes_sb()
> with nr_to_write == MAX_WRITEBACK_PAGES and thus we easily end up with negative
> nr_to_write after the function returns. wb_writeback() then decides we need
> another round of writeback but this is wrong in some cases! For example when
> a single large file is continuously dirtied, we would never finish syncing
> it because each pass would be able to write MAX_WRITEBACK_PAGES and inode dirty
> timestamp never gets updated (as inode is never completely clean).
> 
> Fix the issue by setting nr_to_write to LONG_MAX in WB_SYNC_ALL mode. We do not
> need nr_to_write in WB_SYNC_ALL mode anyway since livelock avoidance is done
> differently for it.
> 
> After this patch, program from http://lkml.org/lkml/2010/10/24/154 is no longer
> able to stall sync forever.
> 
> Signed-off-by: Jan Kara <jack@suse.cz>
> ---
>  fs/fs-writeback.c |   18 ++++++++++++++----
>  1 files changed, 14 insertions(+), 4 deletions(-)
> 
>   Fengguang, I've been testing with those writeback fixes you reposted
> a few days ago and I've been able to still reproduce livelocks with
> Jan Engelhard's test case. Using writeback tracing I've tracked the
> problem to the above and with this patch, sync finishes OK (well, it still
> takes about 15 minutes but that's about expected time given the throughput
> I see to the disk - the test case randomly dirties pages in a huge file).
> So could you please add this patch to the previous two send them to Jens
> for inclusion?
> 
> diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
> index 6b4d02a..d5873a6 100644
> --- a/fs/fs-writeback.c
> +++ b/fs/fs-writeback.c
> @@ -629,6 +629,7 @@ static long wb_writeback(struct bdi_writeback *wb,
>  	};
>  	unsigned long oldest_jif;
>  	long wrote = 0;
> +	long write_chunk;
>  	struct inode *inode;
>  
>  	if (wbc.for_kupdate) {
> @@ -640,6 +641,15 @@ static long wb_writeback(struct bdi_writeback *wb,
>  		wbc.range_start = 0;
>  		wbc.range_end = LLONG_MAX;
>  	}
> +	/*
> +	 * In WB_SYNC_ALL mode, we just want to ignore nr_to_write as
> +	 * we need to write everything and livelock avoidance is implemented
> +	 * differently.
> +	 */
> +	if (wbc.sync_mode == WB_SYNC_NONE)
> +		write_chunk = MAX_WRITEBACK_PAGES;
> +	else
> +		write_chunk = LONG_MAX;
>  
>  	wbc.wb_start = jiffies; /* livelock avoidance */
>  	for (;;) {
> @@ -665,7 +675,7 @@ static long wb_writeback(struct bdi_writeback *wb,
>  			break;
>  
>  		wbc.more_io = 0;
> -		wbc.nr_to_write = MAX_WRITEBACK_PAGES;
> +		wbc.nr_to_write = write_chunk;
>  		wbc.pages_skipped = 0;
>  
>  		trace_wbc_writeback_start(&wbc, wb->bdi);
> @@ -675,8 +685,8 @@ static long wb_writeback(struct bdi_writeback *wb,
>  			writeback_inodes_wb(wb, &wbc);
>  		trace_wbc_writeback_written(&wbc, wb->bdi);
>  
> -		work->nr_pages -= MAX_WRITEBACK_PAGES - wbc.nr_to_write;
> -		wrote += MAX_WRITEBACK_PAGES - wbc.nr_to_write;
> +		work->nr_pages -= write_chunk - wbc.nr_to_write;
> +		wrote += write_chunk - wbc.nr_to_write;
>  
>  		/*
>  		 * If we consumed everything, see if we have more
> @@ -691,7 +701,7 @@ static long wb_writeback(struct bdi_writeback *wb,
>  		/*
>  		 * Did we write something? Try for more
>  		 */
> -		if (wbc.nr_to_write < MAX_WRITEBACK_PAGES)
> +		if (wbc.nr_to_write < write_chunk)
>  			continue;
>  		/*
>  		 * Nothing written. Wait for some inode to
> -- 
> 1.7.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-fsdevel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
