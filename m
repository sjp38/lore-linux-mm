Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id E618A6B0038
	for <linux-mm@kvack.org>; Wed,  3 May 2017 18:52:07 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id p81so3013089pfd.12
        for <linux-mm@kvack.org>; Wed, 03 May 2017 15:52:07 -0700 (PDT)
Received: from mail-pg0-x233.google.com (mail-pg0-x233.google.com. [2607:f8b0:400e:c05::233])
        by mx.google.com with ESMTPS id d92si380222pld.304.2017.05.03.15.52.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 May 2017 15:52:06 -0700 (PDT)
Received: by mail-pg0-x233.google.com with SMTP id o3so1871125pgn.2
        for <linux-mm@kvack.org>; Wed, 03 May 2017 15:52:06 -0700 (PDT)
Date: Wed, 3 May 2017 15:52:04 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch v2] mm, vmscan: avoid thrashing anon lru when free + file
 is low
In-Reply-To: <20170503084952.GD8836@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.10.1705031547360.50439@chino.kir.corp.google.com>
References: <20170418013659.GD21354@bbox> <alpine.DEB.2.10.1704181402510.112481@chino.kir.corp.google.com> <20170419001405.GA13364@bbox> <alpine.DEB.2.10.1704191623540.48310@chino.kir.corp.google.com> <20170420060904.GA3720@bbox>
 <alpine.DEB.2.10.1705011432220.137835@chino.kir.corp.google.com> <20170502080246.GD14593@dhcp22.suse.cz> <alpine.DEB.2.10.1705021331450.116499@chino.kir.corp.google.com> <20170503061528.GB1236@dhcp22.suse.cz> <20170503070656.GA8836@dhcp22.suse.cz>
 <20170503084952.GD8836@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 3 May 2017, Michal Hocko wrote:

> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 24efcc20af91..f3ec8760dc06 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2113,16 +2113,14 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
>  	u64 denominator = 0;	/* gcc */
>  	struct pglist_data *pgdat = lruvec_pgdat(lruvec);
>  	unsigned long anon_prio, file_prio;
> -	enum scan_balance scan_balance;
> +	enum scan_balance scan_balance = SCAN_FILE;
>  	unsigned long anon, file;
>  	unsigned long ap, fp;
>  	enum lru_list lru;
>  
>  	/* If we have no swap space, do not bother scanning anon pages. */
> -	if (!sc->may_swap || mem_cgroup_get_nr_swap_pages(memcg) <= 0) {
> -		scan_balance = SCAN_FILE;
> +	if (!sc->may_swap || mem_cgroup_get_nr_swap_pages(memcg) <= 0)
>  		goto out;
> -	}
>  
>  	/*
>  	 * Global reclaim will swap to prevent OOM even with no
> @@ -2131,10 +2129,8 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
>  	 * using the memory controller's swap limit feature would be
>  	 * too expensive.
>  	 */
> -	if (!global_reclaim(sc) && !swappiness) {
> -		scan_balance = SCAN_FILE;
> +	if (!global_reclaim(sc) && !swappiness)
>  		goto out;
> -	}
>  
>  	/*
>  	 * Do not apply any pressure balancing cleverness when the

Good as a cleanup so far.

> @@ -2147,8 +2143,9 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
>  	}
>  
>  	/*
> -	 * Prevent the reclaimer from falling into the cache trap: as
> -	 * cache pages start out inactive, every cache fault will tip
> +	 * We usually want to bias page cache reclaim over anonymous
> +	 * memory. Prevent the reclaimer from falling into the cache trap:
> +	 * as cache pages start out inactive, every cache fault will tip
>  	 * the scan balance towards the file LRU.  And as the file LRU
>  	 * shrinks, so does the window for rotation from references.
>  	 * This means we have a runaway feedback loop where a tiny

I think Minchan made a good point earlier about anon being more likely to 
be working set since it is mapped, but this may be a biased opinion coming 
from me since I am primarily concerned with malloc.

> @@ -2173,26 +2170,24 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
>  			total_high_wmark += high_wmark_pages(zone);
>  		}
>  
> -		if (unlikely(pgdatfile + pgdatfree <= total_high_wmark)) {
> +		if (unlikely(pgdatfile + pgdatfree <= total_high_wmark))
>  			scan_balance = SCAN_ANON;
> -			goto out;
> -		}
>  	}
>  
>  	/*
> -	 * If there is enough inactive page cache, i.e. if the size of the
> -	 * inactive list is greater than that of the active list *and* the
> -	 * inactive list actually has some pages to scan on this priority, we
> -	 * do not reclaim anything from the anonymous working set right now.
> -	 * Without the second condition we could end up never scanning an
> -	 * lruvec even if it has plenty of old anonymous pages unless the
> -	 * system is under heavy pressure.
> +	 * Make sure there are enough pages on the biased LRU before we go
> +	 * and do an exclusive reclaim from that list, i.e. if the
> +	 * size of the inactive list is greater than that of the active list
> +	 * *and* the inactive list actually has some pages to scan on this
> +	 * priority.
> +	 * Without the second condition we could end up never scanning other
> +	 * lruvecs even if they have plenty of old pages unless the system is
> +	 * under heavy pressure.
>  	 */
> -	if (!inactive_list_is_low(lruvec, true, memcg, sc, false) &&
> -	    lruvec_lru_size(lruvec, LRU_INACTIVE_FILE, sc->reclaim_idx) >> sc->priority) {
> -		scan_balance = SCAN_FILE;
> +	lru = LRU_INACTIVE_ANON + LRU_FILE * (scan_balance == SCAN_FILE);

This part seems to complicate the logic since it determines the lru under 
test based on the current setting of scan_balance.  I think I prefer 
individual heuristics with well written comments, but others may feel 
differently about this.

> +	if (!inactive_list_is_low(lruvec, is_file_lru(lru), memcg, sc, false) &&
> +	    lruvec_lru_size(lruvec, lru, sc->reclaim_idx) >> sc->priority)
>  		goto out;
> -	}
>  
>  	scan_balance = SCAN_FRACT;
>  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
