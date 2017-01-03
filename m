Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1DE7F6B0069
	for <linux-mm@kvack.org>; Tue,  3 Jan 2017 12:21:51 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id s63so79854796wms.7
        for <linux-mm@kvack.org>; Tue, 03 Jan 2017 09:21:51 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z80si74293102wmd.57.2017.01.03.09.21.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 03 Jan 2017 09:21:50 -0800 (PST)
Subject: Re: [PATCH 3/7] mm, vmscan: show the number of skipped pages in
 mm_vmscan_lru_isolate
References: <20161228153032.10821-1-mhocko@kernel.org>
 <20161228153032.10821-4-mhocko@kernel.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <f4ca13b7-c4ce-eb4c-8314-c710d93785d3@suse.cz>
Date: Tue, 3 Jan 2017 18:21:48 +0100
MIME-Version: 1.0
In-Reply-To: <20161228153032.10821-4-mhocko@kernel.org>
Content-Type: text/plain; charset=iso-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On 12/28/2016 04:30 PM, Michal Hocko wrote:
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1428,6 +1428,7 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
>  	unsigned long nr_taken = 0;
>  	unsigned long nr_zone_taken[MAX_NR_ZONES] = { 0 };
>  	unsigned long nr_skipped[MAX_NR_ZONES] = { 0, };
> +	unsigned long skipped = 0, total_skipped = 0;
>  	unsigned long scan, nr_pages;
>  	LIST_HEAD(pages_skipped);
>
> @@ -1479,14 +1480,13 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
>  	 */
>  	if (!list_empty(&pages_skipped)) {
>  		int zid;
> -		unsigned long total_skipped = 0;
>
>  		for (zid = 0; zid < MAX_NR_ZONES; zid++) {
>  			if (!nr_skipped[zid])
>  				continue;
>
>  			__count_zid_vm_events(PGSCAN_SKIP, zid, nr_skipped[zid]);
> -			total_skipped += nr_skipped[zid];
> +			skipped += nr_skipped[zid];
>  		}
>
>  		/*
> @@ -1494,13 +1494,13 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
>  		 * close to unreclaimable. If the LRU list is empty, account
>  		 * skipped pages as a full scan.
>  		 */
> -		scan += list_empty(src) ? total_skipped : total_skipped >> 2;
> +		total_skipped = list_empty(src) ? skipped : skipped >> 2;

Should the tracepoint output reflect this halving heuristic or rather report the 
raw data? Or is each variant inferrable from the other?

>
>  		list_splice(&pages_skipped, src);
>  	}
> -	*nr_scanned = scan;
> +	*nr_scanned = scan + total_skipped;
>  	trace_mm_vmscan_lru_isolate(sc->reclaim_idx, sc->order, nr_to_scan, scan,
> -				    nr_taken, mode, is_file_lru(lru));
> +				    skipped, nr_taken, mode, is_file_lru(lru));
>  	update_lru_sizes(lruvec, lru, nr_zone_taken, nr_taken);
>  	return nr_taken;
>  }
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
