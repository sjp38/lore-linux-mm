Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 34FBA6B02EE
	for <linux-mm@kvack.org>; Tue,  2 May 2017 04:02:50 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id p18so12858966wrb.22
        for <linux-mm@kvack.org>; Tue, 02 May 2017 01:02:50 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w185si1726823wma.80.2017.05.02.01.02.48
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 02 May 2017 01:02:48 -0700 (PDT)
Date: Tue, 2 May 2017 10:02:47 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [patch v2] mm, vmscan: avoid thrashing anon lru when free + file
 is low
Message-ID: <20170502080246.GD14593@dhcp22.suse.cz>
References: <alpine.DEB.2.10.1704171657550.139497@chino.kir.corp.google.com>
 <20170418013659.GD21354@bbox>
 <alpine.DEB.2.10.1704181402510.112481@chino.kir.corp.google.com>
 <20170419001405.GA13364@bbox>
 <alpine.DEB.2.10.1704191623540.48310@chino.kir.corp.google.com>
 <20170420060904.GA3720@bbox>
 <alpine.DEB.2.10.1705011432220.137835@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1705011432220.137835@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon 01-05-17 14:34:21, David Rientjes wrote:
[...]
> @@ -2204,8 +2204,17 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
>  		}
>  
>  		if (unlikely(pgdatfile + pgdatfree <= total_high_wmark)) {
> -			scan_balance = SCAN_ANON;
> -			goto out;
> +			/*
> +			 * Force SCAN_ANON if there are enough inactive
> +			 * anonymous pages on the LRU in eligible zones.
> +			 * Otherwise, the small LRU gets thrashed.
> +			 */
> +			if (!inactive_list_is_low(lruvec, false, sc, false) &&
> +			    lruvec_lru_size(lruvec, LRU_INACTIVE_ANON, sc->reclaim_idx)
> +					>> sc->priority) {
> +				scan_balance = SCAN_ANON;
> +				goto out;
> +			}

I have already asked and my questions were ignored. So let me ask again
and hopefuly not get ignored this time. So Why do we need a different
criterion on anon pages than file pages? I do agree that blindly
scanning anon pages when file pages are low is very suboptimal but this
adds yet another heuristic without _any_ numbers. Why cannot we simply
treat anon and file pages equally? Something like the following

	if (pgdatfile + pgdatanon + pgdatfree > 2*total_high_wmark) {
		scan_balance = SCAN_FILE;
		if (pgdatfile < pgdatanon)
			scan_balance = SCAN_ANON;
		goto out;
	}

Also it would help to describe the workload which can trigger this
behavior so that we can compare numbers before and after this patch.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
