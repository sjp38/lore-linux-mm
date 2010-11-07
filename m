Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id E40106B0089
	for <linux-mm@kvack.org>; Sun,  7 Nov 2010 08:22:09 -0500 (EST)
Date: Sun, 7 Nov 2010 14:22:04 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH] mm: Avoid livelocking of WB_SYNC_ALL writeback
Message-ID: <20101107132204.GC5126@quack.suse.cz>
References: <1288992383-25475-1-git-send-email-jack@suse.cz>
 <20101106041202.GA15411@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101106041202.GA15411@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sat 06-11-10 12:12:02, Wu Fengguang wrote:
> On Sat, Nov 06, 2010 at 05:26:23AM +0800, Jan Kara wrote:
> 
> > +	/*
> > +	 * In WB_SYNC_ALL mode, we just want to ignore nr_to_write as
> > +	 * we need to write everything and livelock avoidance is implemented
> > +	 * differently.
> > +	 */
> > +	if (wbc.sync_mode == WB_SYNC_NONE)
> > +		write_chunk = MAX_WRITEBACK_PAGES;
> > +	else
> > +		write_chunk = LONG_MAX;
> 
> This looks like a safe change for .37.  I updated the patch on the
> above comment and made no other changes (it seems OK to also remove
> the below line, however that's not the necessary change as a bug fix,
> so I'd rather leave the extra change to the next merge window).
> write_cache_pages():
> 
> -->                     /*
> -->                      * We stop writing back only if we are not doing
> -->                      * integrity sync. In case of integrity sync we have to
> -->                      * keep going until we have written all the pages
> -->                      * we tagged for writeback prior to entering this loop.
> -->                      */
>                         if (--wbc->nr_to_write <= 0 &&
> ==>                         wbc->sync_mode == WB_SYNC_NONE) {
>                                 done = 1;
>                                 break;
  Well, I'd rather leave the test as is. In fact, in my mind-model the
target rather is to completely ignore nr_to_write when we do WB_SYNC_ALL
writeback since obeying it is never what a caller wants to happen...

> +	/*
> +	 * WB_SYNC_ALL mode does livelock avoidance by syncing dirty
> +	 * inodes/pages in one big loop. Setting wbc.nr_to_write=LONG_MAX
> +	 * here avoids calling into writeback_inodes_wb() more than once.
  Maybe I'd add here:
The intended call sequence for WB_SYNC_ALL writeback is:
> +	 *
> +	 *      wb_writeback()
> +	 *          writeback_inodes_wb()       <== called only once
> +	 *              write_cache_pages()     <== called once for each inode
> +	 *                   (quickly) tag currently dirty pages
> +	 *                   (maybe slowly) sync all tagged pages
> +	 */
> +	if (wbc.sync_mode == WB_SYNC_NONE)
> +		write_chunk = MAX_WRITEBACK_PAGES;
> +	else
> +		write_chunk = LONG_MAX;
> +

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
