Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 3A17A6B0032
	for <linux-mm@kvack.org>; Thu, 11 Jun 2015 03:12:29 -0400 (EDT)
Received: by pdjm12 with SMTP id m12so52121958pdj.3
        for <linux-mm@kvack.org>; Thu, 11 Jun 2015 00:12:29 -0700 (PDT)
Received: from out21.biz.mail.alibaba.com (out114-136.biz.mail.alibaba.com. [205.204.114.136])
        by mx.google.com with ESMTP id vx6si17769585pab.220.2015.06.11.00.12.26
        for <linux-mm@kvack.org>;
        Thu, 11 Jun 2015 00:12:28 -0700 (PDT)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
Subject: Re: [PATCH 03/25] mm, vmscan: Move LRU lists to node
Date: Thu, 11 Jun 2015 15:12:12 +0800
Message-ID: <00e901d0a415$f06fed80$d14fc880$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="UTF-8"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>

> @@ -774,6 +764,21 @@ typedef struct pglist_data {
>  	ZONE_PADDING(_pad1_)
>  	spinlock_t		lru_lock;
> 
> +	/* Fields commonly accessed by the page reclaim scanner */
> +	struct lruvec		lruvec;
> +
> +	/* Evictions & activations on the inactive file list */
> +	atomic_long_t		inactive_age;
> +
> +	/*
> +	 * The target ratio of ACTIVE_ANON to INACTIVE_ANON pages on
> +	 * this zone's LRU.  Maintained by the pageout code.
> +	 */

The comment has to be updated.

> +	unsigned int inactive_ratio;
> +
> +	unsigned long		flags;
> +
> +	ZONE_PADDING(_pad2_)
>  	struct per_cpu_nodestat __percpu *per_cpu_nodestats;
>  	atomic_long_t		vm_stat[NR_VM_NODE_STAT_ITEMS];
>  } pg_data_t;
> @@ -1185,7 +1185,7 @@ struct lruvec *mem_cgroup_zone_lruvec(struct zone *zone,
>  	struct lruvec *lruvec;
> 
>  	if (mem_cgroup_disabled()) {
> -		lruvec = &zone->lruvec;
> +		lruvec = zone_lruvec(zone);
>  		goto out;
>  	}
> 
> @@ -1197,8 +1197,8 @@ out:
>  	 * we have to be prepared to initialize lruvec->zone here;
>  	 * and if offlined then reonlined, we need to reinitialize it.
>  	 */
> -	if (unlikely(lruvec->zone != zone))
> -		lruvec->zone = zone;
> +	if (unlikely(lruvec->pgdat != zone->zone_pgdat))
> +		lruvec->pgdat = zone->zone_pgdat;

See below please.

>  	return lruvec;
>  }
> 
> @@ -1211,14 +1211,14 @@ out:
>   * and putback protocol: the LRU lock must be held, and the page must
>   * either be PageLRU() or the caller must have isolated/allocated it.
>   */
> -struct lruvec *mem_cgroup_page_lruvec(struct page *page, struct zone *zone)
> +struct lruvec *mem_cgroup_page_lruvec(struct page *page, struct pglist_data *pgdat)
>  {
>  	struct mem_cgroup_per_zone *mz;
>  	struct mem_cgroup *memcg;
>  	struct lruvec *lruvec;
> 
>  	if (mem_cgroup_disabled()) {
> -		lruvec = &zone->lruvec;
> +		lruvec = &pgdat->lruvec;
>  		goto out;
>  	}
> 
> @@ -1238,8 +1238,8 @@ out:
>  	 * we have to be prepared to initialize lruvec->zone here;
>  	 * and if offlined then reonlined, we need to reinitialize it.
>  	 */
> -	if (unlikely(lruvec->zone != zone))
> -		lruvec->zone = zone;
> +	if (unlikely(lruvec->pgdat != pgdat))
> +		lruvec->pgdat = pgdat;

Given &pgdat->lruvec, we no longer need(or are able) to set lruvec->pgdat.

>  	return lruvec;
>  }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
