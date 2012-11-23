Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id 5F44D6B006C
	for <linux-mm@kvack.org>; Fri, 23 Nov 2012 03:50:33 -0500 (EST)
Received: by mail-ie0-f169.google.com with SMTP id 10so16181015ied.14
        for <linux-mm@kvack.org>; Fri, 23 Nov 2012 00:50:32 -0800 (PST)
Message-ID: <50AF38D2.6090106@gmail.com>
Date: Fri, 23 Nov 2012 16:50:26 +0800
From: Jaegeuk Hanse <jaegeuk.hanse@gmail.com>
MIME-Version: 1.0
Subject: Re: kswapd endless loop for compaction
References: <20121120190440.GA24381@cmpxchg.org>
In-Reply-To: <20121120190440.GA24381@cmpxchg.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 11/21/2012 03:04 AM, Johannes Weiner wrote:
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

Hi Johannes,

If depend on compaction get enough contigous pages, why

if (CONPACT_BUILD && order &&
     compaction_suitable(zone, order) !=
         COMPACTION_SKIPPED)
     testorder = 0;

can't guarantee low watermark + twice the huge page size is okay?

Regards,
Jaegeuk

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
