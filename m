Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 1B1016006B6
	for <linux-mm@kvack.org>; Mon, 26 Jul 2010 07:27:28 -0400 (EDT)
Date: Mon, 26 Jul 2010 19:27:09 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 8/8] vmscan: Kick flusher threads to clean pages when
 reclaim is encountering dirty pages
Message-ID: <20100726112709.GB6284@localhost>
References: <1279545090-19169-1-git-send-email-mel@csn.ul.ie>
 <1279545090-19169-9-git-send-email-mel@csn.ul.ie>
 <20100726072832.GB13076@localhost>
 <20100726092616.GG5300@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100726092616.GG5300@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

> > > @@ -933,13 +934,16 @@ keep_dirty:
> > >  		VM_BUG_ON(PageLRU(page) || PageUnevictable(page));
> > >  	}
> > >  
> > > +	/*
> > > +	 * If reclaim is encountering dirty pages, it may be because
> > > +	 * dirty pages are reaching the end of the LRU even though
> > > +	 * the dirty_ratio may be satisified. In this case, wake
> > > +	 * flusher threads to pro-actively clean some pages
> > > +	 */
> > > +	wakeup_flusher_threads(laptop_mode ? 0 : nr_dirty + nr_dirty / 2);
> > 
> > Ah it's very possible that nr_dirty==0 here! Then you are hitting the
> > number of dirty pages down to 0 whether or not pageout() is called.
> > 
> 
> True, this has been fixed to only wakeup flusher threads when this is
> the file LRU, dirty pages have been encountered and the caller has
> sc->may_writepage.

OK.

> > Another minor issue is, the passed (nr_dirty + nr_dirty / 2) is
> > normally a small number, much smaller than MAX_WRITEBACK_PAGES.
> > The flusher will sync at least MAX_WRITEBACK_PAGES pages, this is good
> > for efficiency.
> > And it seems good to let the flusher write much more
> > than nr_dirty pages to safeguard a reasonable large
> > vmscan-head-to-first-dirty-LRU-page margin. So it would be enough to
> > update the comments.
> > 
> 
> Ok, the reasoning had been to flush a number of pages that was related
> to the scanning rate but if that is inefficient for the flusher, I'll
> use MAX_WRITEBACK_PAGES.

It would be better to pass something like (nr_dirty * N).
MAX_WRITEBACK_PAGES may be increased to 128MB in the future, which is
obviously too large as a parameter. When the batch size is increased
to 128MB, the writeback code may be improved somehow to not exceed the
nr_pages limit too much.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
