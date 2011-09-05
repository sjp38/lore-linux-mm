Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 5CD1D6B00EE
	for <linux-mm@kvack.org>; Mon,  5 Sep 2011 04:33:31 -0400 (EDT)
Date: Mon, 5 Sep 2011 10:33:21 +0200
From: Johannes Weiner <jweiner@redhat.com>
Subject: Re: [PATCH] vmscan: Do reclaim stall in case of mlocked page.
Message-ID: <20110905083321.GA15935@redhat.com>
References: <1321285043-3470-1-git-send-email-minchan.kim@gmail.com>
 <20110831173031.GA21571@redhat.com>
 <CAEwNFnDcNqLvo=oyXXkxgFxs8wNc+WTLwot0qeru1VfQKmUYDQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAEwNFnDcNqLvo=oyXXkxgFxs8wNc+WTLwot0qeru1VfQKmUYDQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

On Fri, Sep 02, 2011 at 11:19:49AM +0900, Minchan Kim wrote:
> On Thu, Sep 1, 2011 at 2:30 AM, Johannes Weiner <jweiner@redhat.com> wrote:
> > On Tue, Nov 15, 2011 at 12:37:23AM +0900, Minchan Kim wrote:
> >> [1] made avoid unnecessary reclaim stall when second shrink_page_list(ie, synchronous
> >> shrink_page_list) try to reclaim page_list which has not-dirty pages.
> >> But it seems rather awkawrd on unevictable page.
> >> The unevictable page in shrink_page_list would be moved into unevictable lru from page_list.
> >> So it would be not on page_list when shrink_page_list returns.
> >> Nevertheless it skips reclaim stall.
> >>
> >> This patch fixes it so that it can do reclaim stall in case of mixing mlocked pages
> >> and writeback pages on page_list.
> >>
> >> [1] 7d3579e,vmscan: narrow the scenarios in whcih lumpy reclaim uses synchrounous reclaim
> >
> > Lumpy isolates physically contiguous in the hope to free a bunch of
> > pages that can be merged to a bigger page.  If an unevictable page is
> > encountered, the chance of that is gone.  Why invest the allocation
> > latency when we know it won't pay off anymore?
> >
> 
> Good point!
> 
> Except some cases, when we require higher orer page, we used zone
> defensive algorithm by zone_watermark_ok. So the number of fewer
> higher order pages would be factor of failure of allocation. If it was
> problem, we could rescue the situation by only reclaim part of the
> block in the hope to free fewer higher order pages.

You mean if we fail to get an order-4, we may still successfully free
some order-3?

I'm not sure we should speculatively do lumpy reclaim.  If someone
wants order-3, they have to get it themselves.

> I thought the lumpy was designed to consider the case.(I might be wrong).
> Why I thought is that when we isolate the pages for lumpy and found
> the page isn't able to isolate, we don't rollback the isolated pages
> in the lumpy phsyical block. It's very pointless to get a higher order
> pages.
> 
> If we consider that, we have to fix other reset_reclaim_mode cases as
> well as mlocked pages.
> Or
> fix isolataion logic for the lumpy? (When we find the page isn't able
> to isolate, rollback the pages in the lumpy block to the LRU)
> Or
> Nothing and wait to remove lumpy completely.
> 
> What do you think about it?

The rollback may be overkill and we already abort clustering the
isolation when one of the pages fails.

I would go with the last option.  Lumpy reclaim is on its way out and
already disabled for a rather common configuration, so I would defer
non-obvious fixes like these until actual bug reports show up.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
