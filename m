Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id A03966B0038
	for <linux-mm@kvack.org>; Wed,  3 May 2017 04:49:55 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id u96so17449935wrc.7
        for <linux-mm@kvack.org>; Wed, 03 May 2017 01:49:55 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r195si5442854wmb.166.2017.05.03.01.49.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 03 May 2017 01:49:54 -0700 (PDT)
Date: Wed, 3 May 2017 10:49:52 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [patch v2] mm, vmscan: avoid thrashing anon lru when free + file
 is low
Message-ID: <20170503084952.GD8836@dhcp22.suse.cz>
References: <20170418013659.GD21354@bbox>
 <alpine.DEB.2.10.1704181402510.112481@chino.kir.corp.google.com>
 <20170419001405.GA13364@bbox>
 <alpine.DEB.2.10.1704191623540.48310@chino.kir.corp.google.com>
 <20170420060904.GA3720@bbox>
 <alpine.DEB.2.10.1705011432220.137835@chino.kir.corp.google.com>
 <20170502080246.GD14593@dhcp22.suse.cz>
 <alpine.DEB.2.10.1705021331450.116499@chino.kir.corp.google.com>
 <20170503061528.GB1236@dhcp22.suse.cz>
 <20170503070656.GA8836@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170503070656.GA8836@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed 03-05-17 09:06:56, Michal Hocko wrote:
[...]
> This is still untested but should be much closer to what I've had in
> mind.
> ---
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 24efcc20af91..bcdad30f942d 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2174,8 +2174,14 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
>  		}
>  
>  		if (unlikely(pgdatfile + pgdatfree <= total_high_wmark)) {
> -			scan_balance = SCAN_ANON;
> -			goto out;
> +			unsigned long pgdatanon;
> +
> +			pgdatanon = node_page_state(pgdat, NR_ACTIVE_ANON) +
> +				node_page_state(pgdat, NR_INACTIVE_ANON);
> +			if (pgdatanon + pgdatfree > total_high_wmark) {
> +				scan_balance = SCAN_ANON;
> +				goto out;
> +			}
>  		}
>  	}

I've realized that this just makes the situation more obscure than
necessary after thinking some more about it. It also doesn't achieve my
original intention to treat biased anon and file LRUs the same. Now that
I've digested the change more thoroughly I am willing to ack your patch.
So feel free to add
Acked-by: Michal Hocko <mhocko@suse.com>
And sorry about the diversion here but I am always nervous when touching
g_s_c because this tends to lead to subtle issues.

Maybe we could make this aspect of the biased LRUs more explicit by
doing the following rather than duplicating the condition. What do you
think?
---
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 24efcc20af91..f3ec8760dc06 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2113,16 +2113,14 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
 	u64 denominator = 0;	/* gcc */
 	struct pglist_data *pgdat = lruvec_pgdat(lruvec);
 	unsigned long anon_prio, file_prio;
-	enum scan_balance scan_balance;
+	enum scan_balance scan_balance = SCAN_FILE;
 	unsigned long anon, file;
 	unsigned long ap, fp;
 	enum lru_list lru;
 
 	/* If we have no swap space, do not bother scanning anon pages. */
-	if (!sc->may_swap || mem_cgroup_get_nr_swap_pages(memcg) <= 0) {
-		scan_balance = SCAN_FILE;
+	if (!sc->may_swap || mem_cgroup_get_nr_swap_pages(memcg) <= 0)
 		goto out;
-	}
 
 	/*
 	 * Global reclaim will swap to prevent OOM even with no
@@ -2131,10 +2129,8 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
 	 * using the memory controller's swap limit feature would be
 	 * too expensive.
 	 */
-	if (!global_reclaim(sc) && !swappiness) {
-		scan_balance = SCAN_FILE;
+	if (!global_reclaim(sc) && !swappiness)
 		goto out;
-	}
 
 	/*
 	 * Do not apply any pressure balancing cleverness when the
@@ -2147,8 +2143,9 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
 	}
 
 	/*
-	 * Prevent the reclaimer from falling into the cache trap: as
-	 * cache pages start out inactive, every cache fault will tip
+	 * We usually want to bias page cache reclaim over anonymous
+	 * memory. Prevent the reclaimer from falling into the cache trap:
+	 * as cache pages start out inactive, every cache fault will tip
 	 * the scan balance towards the file LRU.  And as the file LRU
 	 * shrinks, so does the window for rotation from references.
 	 * This means we have a runaway feedback loop where a tiny
@@ -2173,26 +2170,24 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
 			total_high_wmark += high_wmark_pages(zone);
 		}
 
-		if (unlikely(pgdatfile + pgdatfree <= total_high_wmark)) {
+		if (unlikely(pgdatfile + pgdatfree <= total_high_wmark))
 			scan_balance = SCAN_ANON;
-			goto out;
-		}
 	}
 
 	/*
-	 * If there is enough inactive page cache, i.e. if the size of the
-	 * inactive list is greater than that of the active list *and* the
-	 * inactive list actually has some pages to scan on this priority, we
-	 * do not reclaim anything from the anonymous working set right now.
-	 * Without the second condition we could end up never scanning an
-	 * lruvec even if it has plenty of old anonymous pages unless the
-	 * system is under heavy pressure.
+	 * Make sure there are enough pages on the biased LRU before we go
+	 * and do an exclusive reclaim from that list, i.e. if the
+	 * size of the inactive list is greater than that of the active list
+	 * *and* the inactive list actually has some pages to scan on this
+	 * priority.
+	 * Without the second condition we could end up never scanning other
+	 * lruvecs even if they have plenty of old pages unless the system is
+	 * under heavy pressure.
 	 */
-	if (!inactive_list_is_low(lruvec, true, memcg, sc, false) &&
-	    lruvec_lru_size(lruvec, LRU_INACTIVE_FILE, sc->reclaim_idx) >> sc->priority) {
-		scan_balance = SCAN_FILE;
+	lru = LRU_INACTIVE_ANON + LRU_FILE * (scan_balance == SCAN_FILE);
+	if (!inactive_list_is_low(lruvec, is_file_lru(lru), memcg, sc, false) &&
+	    lruvec_lru_size(lruvec, lru, sc->reclaim_idx) >> sc->priority)
 		goto out;
-	}
 
 	scan_balance = SCAN_FRACT;
 
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
