Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 7B85D6006A9
	for <linux-mm@kvack.org>; Mon, 19 Jul 2010 10:37:55 -0400 (EDT)
Date: Mon, 19 Jul 2010 15:37:37 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 8/8] vmscan: Kick flusher threads to clean pages when
	reclaim is encountering dirty pages
Message-ID: <20100719143737.GQ13117@csn.ul.ie>
References: <1279545090-19169-1-git-send-email-mel@csn.ul.ie> <1279545090-19169-9-git-send-email-mel@csn.ul.ie> <20100719142349.GE12510@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100719142349.GE12510@infradead.org>
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Wu Fengguang <fengguang.wu@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

On Mon, Jul 19, 2010 at 10:23:49AM -0400, Christoph Hellwig wrote:
> On Mon, Jul 19, 2010 at 02:11:30PM +0100, Mel Gorman wrote:
> > +	/*
> > +	 * If reclaim is encountering dirty pages, it may be because
> > +	 * dirty pages are reaching the end of the LRU even though
> > +	 * the dirty_ratio may be satisified. In this case, wake
> > +	 * flusher threads to pro-actively clean some pages
> > +	 */
> > +	wakeup_flusher_threads(laptop_mode ? 0 : nr_dirty + nr_dirty / 2);
> > +
> 
> Where is the laptop-mode magic coming from?
> 

It comes from other parts of page reclaim where writing pages is avoided
by page reclaim where possible. Things like this

	wakeup_flusher_threads(laptop_mode ? 0 : total_scanned);

and

	.may_writepage = !laptop_mode

although the latter can get disabled too. Deleting the magic is an
option which would trade IO efficiency for power efficiency but my
current thinking is laptop mode preferred reduced power.

> And btw, at least currently wakeup_flusher_threads writes back nr_pages
> for each BDI, which might not be what you want. 

I saw you pointing that out in another thread all right although I can't
remember the context. It's not exactly what I want but then again we
really want writing back of pages from a particular zone which we don't
get either. There did not seem to be an ideal here and this appeared to
be "less bad" than the alternatives.

> Then again probably
> no caller wants it, but I don't see an easy way to fix it.
> 

I didn't either but my writeback-foo is weak (getting better but still weak). I
hoped to bring it up at MM Summit and maybe at the Filesystem Summit too to
see what ideas exist to improve this.

When this idea was first floated, you called it a band-aid and I
prioritised writing back old inodes over this. How do you feel about
this approach now?

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
