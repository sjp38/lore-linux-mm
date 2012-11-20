Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id CAC136B006E
	for <linux-mm@kvack.org>; Tue, 20 Nov 2012 14:04:48 -0500 (EST)
Date: Tue, 20 Nov 2012 14:04:41 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: kswapd endless loop for compaction
Message-ID: <20121120190440.GA24381@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi guys,

while testing a 3.7-rc5ish kernel, I noticed that kswapd can drop into
a busy spin state without doing reclaim.  printk-style debugging told
me that this happens when the distance between a zone's high watermark
and its low watermark is less than two huge pages (DMA zone).

1. The first loop in balance_pgdat() over the zones finds all zones to
be above their high watermark and only does goto out (all_zones_ok).

2. pgdat_balanced() at the out: label also just checks the high
watermark, so the node is considered balanced and the order is not
reduced.

3. In the `if (order)' block after it, compaction_suitable() checks if
the zone's low watermark + twice the huge page size is okay, which
it's not necessarily in a small zone, and so COMPACT_SKIPPED makes it
it go back to loop_again:.

This will go on until somebody else allocates and breaches the high
watermark and then hopefully goes on to reclaim the zone above low
watermark + 2 * THP.

I'm not really sure what the correct solution is.  Should we modify
the zone_watermark_ok() checks in balance_pgdat() to take into account
the higher watermark requirements for reclaim on behalf of compaction?
Change the check in compaction_suitable() / not use it directly?

Thanks,
Johannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
