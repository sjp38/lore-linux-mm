Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5D03B6B0253
	for <linux-mm@kvack.org>; Sat, 14 Jan 2017 11:12:44 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id c7so1407123wjb.7
        for <linux-mm@kvack.org>; Sat, 14 Jan 2017 08:12:44 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id y23si15209452wra.86.2017.01.14.08.12.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 14 Jan 2017 08:12:43 -0800 (PST)
Date: Sat, 14 Jan 2017 11:12:36 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [RFC PATCH 1/2] mm, vmscan: consider eligible zones in
 get_scan_count
Message-ID: <20170114161236.GB26139@cmpxchg.org>
References: <20170110125552.4170-1-mhocko@kernel.org>
 <20170110125552.4170-2-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170110125552.4170-2-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>

On Tue, Jan 10, 2017 at 01:55:51PM +0100, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> get_scan_count considers the whole node LRU size when
> - doing SCAN_FILE due to many page cache inactive pages
> - calculating the number of pages to scan
> 
> in both cases this might lead to unexpected behavior especially on 32b
> systems where we can expect lowmem memory pressure very often.

The amount of retrofitting zones back into reclaim is disappointing :/

>  /*
> + * Return the number of pages on the given lru which are eligible for the
> + * given zone_idx
> + */
> +static unsigned long lruvec_lru_size_eligibe_zones(struct lruvec *lruvec,
> +		enum lru_list lru, int zone_idx)
> +{
> +	struct pglist_data *pgdat = lruvec_pgdat(lruvec);
> +	unsigned long lru_size;
> +	int zid;
> +
> +	lru_size = lruvec_lru_size(lruvec, lru);
> +	for (zid = zone_idx + 1; zid < MAX_NR_ZONES; zid++) {
> +		struct zone *zone = &pgdat->node_zones[zid];
> +		unsigned long size;
> +
> +		if (!managed_zone(zone))
> +			continue;
> +
> +		size = lruvec_zone_lru_size(lruvec, lru, zid);
> +		lru_size -= min(size, lru_size);
> +	}
> +
> +	return lru_size;

The only other use of lruvec_lru_size() is also in get_scan_count(),
where it decays the LRU pressure balancing ratios. That caller wants
to operate on the entire lruvec.

Can you instead add the filtering logic to lruvec_lru_size() directly,
and pass MAX_NR_ZONES when operating on the entire lruvec? That would
make the code quite a bit clearer than having 3 different lruvec size
querying functions.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
