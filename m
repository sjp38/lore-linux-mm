Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4E3436B038A
	for <linux-mm@kvack.org>; Thu, 23 Feb 2017 10:05:38 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id z61so16939331wrc.6
        for <linux-mm@kvack.org>; Thu, 23 Feb 2017 07:05:38 -0800 (PST)
Received: from outbound-smtp02.blacknight.com (outbound-smtp02.blacknight.com. [81.17.249.8])
        by mx.google.com with ESMTPS id 16si6407738wrb.160.2017.02.23.07.05.36
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 23 Feb 2017 07:05:37 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp02.blacknight.com (Postfix) with ESMTPS id 152F0994B1
	for <linux-mm@kvack.org>; Thu, 23 Feb 2017 15:05:36 +0000 (UTC)
Date: Thu, 23 Feb 2017 15:05:34 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 1/3] mm, vmscan: fix zone balance check in
 prepare_kswapd_sleep
Message-ID: <20170223150534.64fpsvlse33rj2aa@techsingularity.net>
References: <20170215092247.15989-1-mgorman@techsingularity.net>
 <20170215092247.15989-2-mgorman@techsingularity.net>
 <20170222070036.GA17962@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20170222070036.GA17962@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Shantanu Goel <sgoel01@yahoo.com>, Chris Mason <clm@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Wed, Feb 22, 2017 at 04:00:36PM +0900, Minchan Kim wrote:
> > There are also more allocation stalls. One of the largest impacts was due
> > to pages written back from kswapd context rising from 0 pages to 4516642
> > pages during the hour the workload ran for. By and large, the patch has very
> > bad behaviour but easily missed as the impact on a UMA machine is negligible.
> > 
> > This patch is included with the data in case a bisection leads to this area.
> > This patch is also a pre-requisite for the rest of the series.
> > 
> > Signed-off-by: Shantanu Goel <sgoel01@yahoo.com>
> > Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> 
> Hmm, I don't understand why we should bind wakeup_kcompactd to kswapd's
> short sleep point where every eligible zones are balanced.
> What's the correlation between them?
> 

If kswapd is ready for a short sleep, eligible zones are balanced for
order-0 but not necessarily the originally requested order if kswapd
gave up reclaiming as compaction was ready to start. As kswapd is ready
to sleep for a short period, it's a suitable time for kcompactd to decide
if it should start working or not. There is no need for kswapd to be aware
of kcompactd's wakeup criteria.

> Can't we wake up kcompactd once we found a zone has enough free pages
> above high watermark like this?
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 26c3b405ef34..f4f0ad0e9ede 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -3346,13 +3346,6 @@ static void kswapd_try_to_sleep(pg_data_t *pgdat, int alloc_order, int reclaim_o
>  		 * that pages and compaction may succeed so reset the cache.
>  		 */
>  		reset_isolation_suitable(pgdat);
> -
> -		/*
> -		 * We have freed the memory, now we should compact it to make
> -		 * allocation of the requested order possible.
> -		 */
> -		wakeup_kcompactd(pgdat, alloc_order, classzone_idx);
> -
>  		remaining = schedule_timeout(HZ/10);
>  
>  		/*
> @@ -3451,6 +3444,14 @@ static int kswapd(void *p)
>  		bool ret;
>  
>  kswapd_try_sleep:
> +		/*
> +		 * We have freed the memory, now we should compact it to make
> +		 * allocation of the requested order possible.
> +		 */
> +		if (alloc_order > 0 && zone_balanced(zone, reclaim_order,
> +							classzone_idx))
> +			wakeup_kcompactd(pgdat, alloc_order, classzone_idx);
> +
>  		kswapd_try_to_sleep(pgdat, alloc_order, reclaim_order,
>  					classzone_idx);

That's functionally very similar to what happens already.  wakeup_kcompactd
checks the order and does not wake for order-0. It also makes its own
decisions that include zone_balanced on whether it is safe to wakeup.

I doubt there would be any measurable difference from a patch like this
and to my mind at least, it does not improve the readability or flow of
the code.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
