Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 9662F600815
	for <linux-mm@kvack.org>; Tue, 27 Jul 2010 10:24:40 -0400 (EDT)
Date: Tue, 27 Jul 2010 22:24:13 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 8/8] vmscan: Kick flusher threads to clean pages when
 reclaim is encountering dirty pages
Message-ID: <20100727142412.GA4771@localhost>
References: <1279545090-19169-1-git-send-email-mel@csn.ul.ie>
 <1279545090-19169-9-git-send-email-mel@csn.ul.ie>
 <20100726072832.GB13076@localhost>
 <20100726092616.GG5300@csn.ul.ie>
 <20100726112709.GB6284@localhost>
 <20100726125717.GS5300@csn.ul.ie>
 <20100726131008.GE11947@localhost>
 <20100727133513.GZ5300@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100727133513.GZ5300@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

On Tue, Jul 27, 2010 at 09:35:13PM +0800, Mel Gorman wrote:
> On Mon, Jul 26, 2010 at 09:10:08PM +0800, Wu Fengguang wrote:
> > On Mon, Jul 26, 2010 at 08:57:17PM +0800, Mel Gorman wrote:
> > > On Mon, Jul 26, 2010 at 07:27:09PM +0800, Wu Fengguang wrote:
> > > > > > > @@ -933,13 +934,16 @@ keep_dirty:
> > > > > > >  		VM_BUG_ON(PageLRU(page) || PageUnevictable(page));
> > > > > > >  	}
> > > > > > >  
> > > > > > > +	/*
> > > > > > > +	 * If reclaim is encountering dirty pages, it may be because
> > > > > > > +	 * dirty pages are reaching the end of the LRU even though
> > > > > > > +	 * the dirty_ratio may be satisified. In this case, wake
> > > > > > > +	 * flusher threads to pro-actively clean some pages
> > > > > > > +	 */
> > > > > > > +	wakeup_flusher_threads(laptop_mode ? 0 : nr_dirty + nr_dirty / 2);
> > > > > > 
> > > > > > Ah it's very possible that nr_dirty==0 here! Then you are hitting the
> > > > > > number of dirty pages down to 0 whether or not pageout() is called.
> > > > > > 
> > > > > 
> > > > > True, this has been fixed to only wakeup flusher threads when this is
> > > > > the file LRU, dirty pages have been encountered and the caller has
> > > > > sc->may_writepage.
> > > > 
> > > > OK.
> > > > 
> > > > > > Another minor issue is, the passed (nr_dirty + nr_dirty / 2) is
> > > > > > normally a small number, much smaller than MAX_WRITEBACK_PAGES.
> > > > > > The flusher will sync at least MAX_WRITEBACK_PAGES pages, this is good
> > > > > > for efficiency.
> > > > > > And it seems good to let the flusher write much more
> > > > > > than nr_dirty pages to safeguard a reasonable large
> > > > > > vmscan-head-to-first-dirty-LRU-page margin. So it would be enough to
> > > > > > update the comments.
> > > > > > 
> > > > > 
> > > > > Ok, the reasoning had been to flush a number of pages that was related
> > > > > to the scanning rate but if that is inefficient for the flusher, I'll
> > > > > use MAX_WRITEBACK_PAGES.
> > > > 
> > > > It would be better to pass something like (nr_dirty * N).
> > > > MAX_WRITEBACK_PAGES may be increased to 128MB in the future, which is
> > > > obviously too large as a parameter. When the batch size is increased
> > > > to 128MB, the writeback code may be improved somehow to not exceed the
> > > > nr_pages limit too much.
> > > > 
> > > 
> > > What might be a useful value for N? 1.5 appears to work reasonably well
> > > to create a window of writeback ahead of the scanner but it's a bit
> > > arbitrary.
> > 
> > I'd recommend N to be a large value. It's no longer relevant now since
> > we'll call the flusher to sync some range containing the target page.
> > The flusher will then choose an N large enough (eg. 4MB) for efficient
> > IO. It needs to be a large value, otherwise the vmscan code will
> > quickly run into dirty pages again..
> > 
> 
> Ok, I took the 4MB at face value to be a "reasonable amount that should
> not cause congestion".

Under memory pressure, the disk should be busy/congested anyway.
The big 4MB adds much work, however many of the pages may need to be
synced in the near future anyway. It also requires more time to do
the bigger IO, hence adding some latency, however the latency should
be a small factor comparing to the IO queue time (which will be long
for a busy disk).

Overall expectation is, the more efficient IO, the more progress :)

> The end result is
> 
> #define MAX_WRITEBACK (4194304UL >> PAGE_SHIFT)
> #define WRITEBACK_FACTOR (MAX_WRITEBACK / SWAP_CLUSTER_MAX)
> static inline long nr_writeback_pages(unsigned long nr_dirty)
> {
>         return laptop_mode ? 0 :
>                         min(MAX_WRITEBACK, (nr_dirty * WRITEBACK_FACTOR));
> }
> 
> nr_writeback_pages(nr_dirty) is what gets passed to
> wakeup_flusher_threads(). Does that seem sensible?

If you plan to keep wakeup_flusher_threads(), a simpler form may be
sufficient, eg.

        laptop_mode ? 0 : (nr_dirty * 16)

On top of this, we may write another patch to convert the
wakeup_flusher_threads(bdi, nr_pages) call to some
bdi_start_inode_writeback(inode, offset) call, to start more oriented
writeback.

When talking the 4MB optimization, I was referring to the internal
implementation of bdi_start_inode_writeback(). Sorry for the missing
context in the previous email.

It may need a big patch to implement bdi_start_inode_writeback().
Would you like to try it, or leave the task to me?

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
