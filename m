Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id 20C5B6B003B
	for <linux-mm@kvack.org>; Mon, 23 Jun 2014 07:15:59 -0400 (EDT)
Received: by mail-wi0-f179.google.com with SMTP id cc10so4060583wib.6
        for <linux-mm@kvack.org>; Mon, 23 Jun 2014 04:15:58 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 18si4884340wjt.144.2014.06.23.04.15.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 23 Jun 2014 04:15:57 -0700 (PDT)
Date: Mon, 23 Jun 2014 12:15:54 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm:vmscan:replace zone_watermark_ok with zone_balanced
 for determining if kswapd will call compaction
Message-ID: <20140623111554.GJ10819@suse.de>
References: <1403427060-16711-1-git-send-email-slaoub@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1403427060-16711-1-git-send-email-slaoub@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Yucong <slaoub@gmail.com>
Cc: hannes@cmpxchg.org, mhocko@suse.cz, riel@redhat.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun, Jun 22, 2014 at 04:51:00PM +0800, Chen Yucong wrote:
> According to the commit messages of "mm: vmscan: fix endless loop in kswapd balancing"
> and "mm: vmscan: decide whether to compact the pgdat based on reclaim progress", minor
> change is required to the following snippet.
> 
>         /*
>          * If any zone is currently balanced then kswapd will
>          * not call compaction as it is expected that the
>          * necessary pages are already available.
>          */
>         if (pgdat_needs_compaction &&
>                 zone_watermark_ok(zone, order,
>                                         low_wmark_pages(zone),
>                                         *classzone_idx, 0))
>                 pgdat_needs_compaction = false;
> 
> zone_watermark_ok() should be replaced by zone_balanced() in the above snippet. That's
> because zone_balanced() is more suitable for the context.
> 

What bug does this fix?

The intent here is to prevent kswapd compacting a node if an allocation
request within that node would succeed against the low watermark.
Your change alters that to check against hte high watermark + balance gap
without explaining why kswapd should compact until the high watermark is
reached.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
