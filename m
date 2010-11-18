Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 6B92A6B004A
	for <linux-mm@kvack.org>; Thu, 18 Nov 2010 03:13:11 -0500 (EST)
Date: Thu, 18 Nov 2010 08:12:54 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 0/8] Use memory compaction instead of lumpy reclaim
	during high-order allocations
Message-ID: <20101118081254.GB8135@csn.ul.ie>
References: <1290010969-26721-1-git-send-email-mel@csn.ul.ie> <20101117154641.51fd7ce5.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20101117154641.51fd7ce5.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, Nov 17, 2010 at 03:46:41PM -0800, Andrew Morton wrote:
> On Wed, 17 Nov 2010 16:22:41 +0000
> Mel Gorman <mel@csn.ul.ie> wrote:
> 
> > Huge page allocations are not expected to be cheap but lumpy reclaim
> > is still very disruptive.
> 
> Huge pages are boring.  Can we expect any benefit for the
> stupid-nic-driver-which-does-order-4-GFP_ATOMIC-allocations problem?
> 

Yes. Specifically, while GFP_ATOMIC allocations still cannot enter compaction
(although with asynchronous migration, it's closer), kswapd will react
faster. As a result, it should be harder to trigger allocation failures.

Huge pages are simply the worst case in terms of allocation latency which
is why I tend to focus testing on them. That, and I don't have a suitable
pair of machines with one of these order-4-atomic-stupid-nics.

> > I haven't pushed hard on the concept of lumpy compaction yet and right
> > now I don't intend to during this cycle. The initial prototypes did not
> > behave as well as expected and this series improves the current situation
> > a lot without introducing new algorithms. Hence, I'd like this series to
> > be considered for merging.
> 
> Translation: "Andrew, wait for the next version"? :)
> 

Preferably do not wait unless review reveals a major flaw. Lumpy compaction
in its initial prototype versions simply did not work out as a good policy
modification and requires much deeper thought. This series was effective
at getting latencies down to the level I expected lumpy compaction to.
If I do make lumpy compaction work properly, its effect will be to reduce
scanning rates but the latencies are likely to be similar.

> > I'm hoping that this series also removes the
> > necessity for the "delete lumpy reclaim" patch from the THP tree.
> 
> Now I'm sad.  I read all that and was thinking "oh goody, we get to
> delete something for once".  But no :(
> 
> If you can get this stuff to work nicely, why can't we remove lumpy
> reclaim?

Ultimately we should be able to. Lumpy reclaim is still there for the
!CONFIG_COMPACTION case and to have an option if we find that compaction
behaves badly for some reason.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
