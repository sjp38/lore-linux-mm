Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 335976B0085
	for <linux-mm@kvack.org>; Wed, 27 Oct 2010 13:16:59 -0400 (EDT)
Date: Wed, 27 Oct 2010 18:16:43 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 4/7] vmscan: narrowing synchrounous lumply reclaim
	condition
Message-ID: <20101027171643.GA4896@csn.ul.ie>
References: <20100805150624.31B7.A69D9226@jp.fujitsu.com> <20100805151341.31C3.A69D9226@jp.fujitsu.com> <20101027164138.GD29304@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20101027164138.GD29304@random.random>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Wu Fengguang <fengguang.wu@intel.com>, Minchan Kim <minchan.kim@gmail.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Wed, Oct 27, 2010 at 06:41:38PM +0200, Andrea Arcangeli wrote:
> Hi,
> 
> > <SNIP>
> 
> [...]
> 
> this rejects on THP code, lumpy is unusable with hugepages, it grinds
> the system to an halt, and there's no reason to let it survive. Lumpy
> is like compaction done with an hammer while blindfolded.
> 

The series drastically limits the level of hammering lumpy does to the
system. I'm currently keeping it alive because lumpy reclaim has received a lot
more testing than compaction has. While I ultimately see it going away, I am
resisting it being deleted until compaction has been around for a few releases.

> I don't know why community insists on improving lumpy when it has to
> be removed completely, especially now that we have memory compaction.
> 

Simply because it has been tested and even with compaction there were cases
envisoned where it would be used - low memory or when compaction is not
configured in for example. The ideal is that compaction is used until lumpy
is necessary although this applies more to the static resizing of the huge
page pool than THP which I'd expect to backoff without using lumpy reclaim
i.e. fail the allocation rather than using lumpy reclaim.

> I'll keep deleting on my tree...
> 
> I hope lumpy work stops here and that it goes away whenever THP is
> merged.
> 

Uhhh, I have one more modification in mind when lumpy is involved and
it's to relax the zone watermark slightly to only obey up to
PAGE_ALLOC_COSTLY_ORDER. At the moment, it is freeing more pages than
are necessary to satisfy an allocation request and hits the system
harder than it should. Similar logic should apply to compaction.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
