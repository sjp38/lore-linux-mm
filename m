Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 80D966B011A
	for <linux-mm@kvack.org>; Wed, 13 Oct 2010 09:23:02 -0400 (EDT)
Date: Wed, 13 Oct 2010 14:22:46 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [experimental][PATCH] mm,vmstat: per cpu stat flush too when
	per cpu page cache flushed
Message-ID: <20101013132246.GO30667@csn.ul.ie>
References: <20101013121913.ADB4.A69D9226@jp.fujitsu.com> <20101013151723.ADBD.A69D9226@jp.fujitsu.com> <20101013160640.ADC9.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20101013160640.ADC9.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Shaohua Li <shaohua.li@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "cl@linux.com" <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Wed, Oct 13, 2010 at 04:10:43PM +0900, KOSAKI Motohiro wrote:
> When memory shortage, we are using drain_pages() for flushing per cpu
> page cache. In this case, per cpu stat should be flushed too. because
> now we are under memory shortage and we need to know exact free pages.
> 
> Otherwise get_page_from_freelist() may fail even though pcp was flushed.
> 

With my patch adjusting the threshold to a small value while kswapd is awake,
it seems less necessary. It's also very hard to predict the performance of
this. We are certainly going to take a hit to do the flush but we *might*
gain slightly if an allocation succeeds because a watermark check passed
when the counters were updated. It's a definite hit for a possible gain
though which is not a great trade-off. Would need some performance testing.

I still think my patch on adjusting thresholds is our best proposal so
far on how to reduce Shaohua's performance problems while still being
safer from livelocks due to memory exhaustion.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
