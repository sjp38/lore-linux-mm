Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 1F0986B00CB
	for <linux-mm@kvack.org>; Fri,  5 Nov 2010 22:55:52 -0400 (EDT)
Date: Sat, 6 Nov 2010 10:55:48 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH] mm: Avoid livelocking of WB_SYNC_ALL writeback
Message-ID: <20101106025548.GA16378@localhost>
References: <1288992383-25475-1-git-send-email-jack@suse.cz>
 <20101105223038.GA16666@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101105223038.GA16666@lst.de>
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@lst.de>
Cc: Jan Kara <jack@suse.cz>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

[add CC to linux-mm list]

On Sat, Nov 06, 2010 at 06:30:38AM +0800, Christoph Hellwig wrote:
> > +	/*
> > +	 * In WB_SYNC_ALL mode, we just want to ignore nr_to_write as
> > +	 * we need to write everything and livelock avoidance is implemented
> > +	 * differently.
> > +	 */
> > +       if (wbc.sync_mode == WB_SYNC_NONE)
> > +               write_chunk = MAX_WRITEBACK_PAGES;
> > +       else
> > +               write_chunk = LONG_MAX;

Good catch!

> 
> I think it would be useful to elaborate here on how livelock avoidance
> is supposed to work.

It's supposed to sync files in a big loop

        for each dirty inode
            write_cache_pages()
                (quickly) tag currently dirty pages
                (maybe slowly) sync all tagged pages

Ideally the loop should call write_cache_pages() _once_ for each inode.
At least this is the assumption made by commit f446daaea (mm:
implement writeback livelock avoidance using page tagging).

Setting wbc.nr_to_write to LONG_MAX ensures that writeback_inodes_wb()
will complete the above loop before returning to wb_writeback(), and
to prevent wb_writeback() from looping (thus re-syncing extra data) in
the below range of code.

   643                 wbc.nr_to_write = MAX_WRITEBACK_PAGES;
   644                 wbc.pages_skipped = 0;
   645            
   646                 trace_wbc_writeback_start(&wbc, wb->bdi);
   647                 if (work->sb)
   648                         __writeback_inodes_sb(work->sb, wb, &wbc);
   649                 else
   650                         writeback_inodes_wb(wb, &wbc);
   651                 trace_wbc_writeback_written(&wbc, wb->bdi);
   652            
   653                 work->nr_pages -= MAX_WRITEBACK_PAGES - wbc.nr_to_write;
   654                 wrote += MAX_WRITEBACK_PAGES - wbc.nr_to_write;
   655            
   656                 /*
   657                  * If we consumed everything, see if we have more
   658                  */
   659                 if (wbc.nr_to_write <= 0)
   660                         continue;

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
