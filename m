Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id A53CC6B03A1
	for <linux-mm@kvack.org>; Wed, 19 Apr 2017 19:24:52 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id l21so43728250ioi.2
        for <linux-mm@kvack.org>; Wed, 19 Apr 2017 16:24:52 -0700 (PDT)
Received: from mail-io0-x22f.google.com (mail-io0-x22f.google.com. [2607:f8b0:4001:c06::22f])
        by mx.google.com with ESMTPS id c6si7731429ita.55.2017.04.19.16.24.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Apr 2017 16:24:51 -0700 (PDT)
Received: by mail-io0-x22f.google.com with SMTP id o22so45490243iod.3
        for <linux-mm@kvack.org>; Wed, 19 Apr 2017 16:24:50 -0700 (PDT)
Date: Wed, 19 Apr 2017 16:24:48 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm, vmscan: avoid thrashing anon lru when free + file
 is low
In-Reply-To: <20170419001405.GA13364@bbox>
Message-ID: <alpine.DEB.2.10.1704191623540.48310@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1704171657550.139497@chino.kir.corp.google.com> <20170418013659.GD21354@bbox> <alpine.DEB.2.10.1704181402510.112481@chino.kir.corp.google.com> <20170419001405.GA13364@bbox>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 19 Apr 2017, Minchan Kim wrote:

> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 24efcc20af91..5d2f3fa41e92 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2174,8 +2174,17 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
>  		}
>  
>  		if (unlikely(pgdatfile + pgdatfree <= total_high_wmark)) {
> -			scan_balance = SCAN_ANON;
> -			goto out;
> +			/*
> +			 * force SCAN_ANON if inactive anonymous LRU lists of
> +			 * eligible zones are enough pages. Otherwise, thrashing
> +			 * can be happen on the small anonymous LRU list.
> +			 */
> +			if (!inactive_list_is_low(lruvec, false, NULL, sc, false) &&
> +			     lruvec_lru_size(lruvec, LRU_INACTIVE_ANON, sc->reclaim_idx)
> +					>> sc->priority) {
> +				scan_balance = SCAN_ANON;
> +				goto out;
> +			}
>  		}
>  	}
>  

Hi Minchan,

This looks good and it correctly biases against SCAN_ANON for my workload 
that was thrashing the anon lrus.  Feel free to use parts of my changelog 
if you'd like.

Tested-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
