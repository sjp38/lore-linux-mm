Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id E9B566B0005
	for <linux-mm@kvack.org>; Tue, 12 Jul 2016 10:23:04 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id r190so14732536wmr.0
        for <linux-mm@kvack.org>; Tue, 12 Jul 2016 07:23:04 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id 11si3743809wmi.28.2016.07.12.07.23.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Jul 2016 07:23:03 -0700 (PDT)
Date: Tue, 12 Jul 2016 10:22:56 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 11/34] mm, vmscan: remove duplicate logic clearing node
 congestion and dirty state
Message-ID: <20160712142256.GE5881@cmpxchg.org>
References: <1467970510-21195-1-git-send-email-mgorman@techsingularity.net>
 <1467970510-21195-12-git-send-email-mgorman@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1467970510-21195-12-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>

On Fri, Jul 08, 2016 at 10:34:47AM +0100, Mel Gorman wrote:
> @@ -3008,7 +3008,17 @@ static bool zone_balanced(struct zone *zone, int order, int classzone_idx)
>  {
>  	unsigned long mark = high_wmark_pages(zone);
>  
> -	return zone_watermark_ok_safe(zone, order, mark, classzone_idx);
> +	if (!zone_watermark_ok_safe(zone, order, mark, classzone_idx))
> +		return false;
> +
> +	/*
> +	 * If any eligible zone is balanced then the node is not considered
> +	 * to be congested or dirty
> +	 */
> +	clear_bit(PGDAT_CONGESTED, &zone->zone_pgdat->flags);
> +	clear_bit(PGDAT_DIRTY, &zone->zone_pgdat->flags);

Predicate functions that secretly modify internal state give me the
willies... The diffstat is flat, too. Is this really an improvement?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
