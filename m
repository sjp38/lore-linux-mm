Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 024956006B4
	for <linux-mm@kvack.org>; Mon, 19 Jul 2010 18:48:53 -0400 (EDT)
Date: Tue, 20 Jul 2010 00:48:39 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 8/8] vmscan: Kick flusher threads to clean pages when
 reclaim is encountering dirty pages
Message-ID: <20100719224838.GC16031@cmpxchg.org>
References: <1279545090-19169-1-git-send-email-mel@csn.ul.ie>
 <1279545090-19169-9-git-send-email-mel@csn.ul.ie>
 <20100719142349.GE12510@infradead.org>
 <20100719143737.GQ13117@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100719143737.GQ13117@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Christoph Hellwig <hch@infradead.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

On Mon, Jul 19, 2010 at 03:37:37PM +0100, Mel Gorman wrote:
> On Mon, Jul 19, 2010 at 10:23:49AM -0400, Christoph Hellwig wrote:
> > On Mon, Jul 19, 2010 at 02:11:30PM +0100, Mel Gorman wrote:
> > > +	/*
> > > +	 * If reclaim is encountering dirty pages, it may be because
> > > +	 * dirty pages are reaching the end of the LRU even though
> > > +	 * the dirty_ratio may be satisified. In this case, wake
> > > +	 * flusher threads to pro-actively clean some pages
> > > +	 */
> > > +	wakeup_flusher_threads(laptop_mode ? 0 : nr_dirty + nr_dirty / 2);
> > > +
> > 
> > Where is the laptop-mode magic coming from?
> > 
> 
> It comes from other parts of page reclaim where writing pages is avoided
> by page reclaim where possible. Things like this
> 
> 	wakeup_flusher_threads(laptop_mode ? 0 : total_scanned);

Actually, it's not avoiding writing pages in laptop mode, instead it
is lumping writeouts aggressively (as I wrote in my other mail,
.nr_pages=0 means 'write everything') to keep disk spinups rare and
make maximum use of them.

> although the latter can get disabled too. Deleting the magic is an
> option which would trade IO efficiency for power efficiency but my
> current thinking is laptop mode preferred reduced power.

Maybe couple your wakeup with sc->may_writepage?  It is usually false
for laptop_mode but direct reclaimers enable it at one point in
do_try_to_free_pages() when it scanned more than 150% of the reclaim
target, so you could use existing disk spin-up points instead of
introducing new ones or disabling the heuristics in laptop mode.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
