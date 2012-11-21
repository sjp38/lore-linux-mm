Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 7F7316B0062
	for <linux-mm@kvack.org>; Wed, 21 Nov 2012 17:01:37 -0500 (EST)
Date: Wed, 21 Nov 2012 17:01:26 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: kswapd endless loop for compaction
Message-ID: <20121121220126.GA2301@cmpxchg.org>
References: <20121120190440.GA24381@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121120190440.GA24381@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

Just to be clear, this is not fixed by Dave's patch to NR_FREE_PAGES
accounting.

I can still get 3.7-rc5 + Dave's fix to drop into an endless loop in
kswapd within a couple of minutes on my test box.

As described below, the bug comes from contradicting conditions in
balance_pgdat(), not an accounting problem.

On Tue, Nov 20, 2012 at 02:04:41PM -0500, Johannes Weiner wrote:
> Hi guys,
> 
> while testing a 3.7-rc5ish kernel, I noticed that kswapd can drop into
> a busy spin state without doing reclaim.  printk-style debugging told
> me that this happens when the distance between a zone's high watermark
> and its low watermark is less than two huge pages (DMA zone).
> 
> 1. The first loop in balance_pgdat() over the zones finds all zones to
> be above their high watermark and only does goto out (all_zones_ok).
> 
> 2. pgdat_balanced() at the out: label also just checks the high
> watermark, so the node is considered balanced and the order is not
> reduced.
> 
> 3. In the `if (order)' block after it, compaction_suitable() checks if
> the zone's low watermark + twice the huge page size is okay, which
> it's not necessarily in a small zone, and so COMPACT_SKIPPED makes it
> it go back to loop_again:.
> 
> This will go on until somebody else allocates and breaches the high
> watermark and then hopefully goes on to reclaim the zone above low
> watermark + 2 * THP.
> 
> I'm not really sure what the correct solution is.  Should we modify
> the zone_watermark_ok() checks in balance_pgdat() to take into account
> the higher watermark requirements for reclaim on behalf of compaction?
> Change the check in compaction_suitable() / not use it directly?
> 
> Thanks,
> Johannes
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
