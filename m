Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id C224C6B0031
	for <linux-mm@kvack.org>; Wed,  5 Jun 2013 17:34:06 -0400 (EDT)
Date: Wed, 5 Jun 2013 18:33:52 -0300
From: Rafael Aquini <aquini@redhat.com>
Subject: Re: [PATCH 1/7] mm: remove ZONE_RECLAIM_LOCKED
Message-ID: <20130605213351.GC19617@optiplex.redhat.com>
References: <1370445037-24144-1-git-send-email-aarcange@redhat.com>
 <1370445037-24144-2-git-send-email-aarcange@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1370445037-24144-2-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Richard Davies <richard@arachsys.com>, Shaohua Li <shli@kernel.org>

On Wed, Jun 05, 2013 at 05:10:31PM +0200, Andrea Arcangeli wrote:
> Zone reclaim locked breaks zone_reclaim_mode=1. If more than one
> thread allocates memory at the same time, it forces a premature
> allocation into remote NUMA nodes even when there's plenty of clean
> cache to reclaim in the local nodes.
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> ---

Acked-by: Rafael Aquini <aquini@redhat.com>


>  include/linux/mmzone.h | 6 ------
>  mm/vmscan.c            | 4 ----
>  2 files changed, 10 deletions(-)
> 
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index 5c76737..f23b080 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -490,7 +490,6 @@ struct zone {
>  } ____cacheline_internodealigned_in_smp;
>  
>  typedef enum {
> -	ZONE_RECLAIM_LOCKED,		/* prevents concurrent reclaim */
>  	ZONE_OOM_LOCKED,		/* zone is in OOM killer zonelist */
>  	ZONE_CONGESTED,			/* zone has many dirty pages backed by
>  					 * a congested BDI
> @@ -517,11 +516,6 @@ static inline int zone_is_reclaim_congested(const struct zone *zone)
>  	return test_bit(ZONE_CONGESTED, &zone->flags);
>  }
>  
> -static inline int zone_is_reclaim_locked(const struct zone *zone)
> -{
> -	return test_bit(ZONE_RECLAIM_LOCKED, &zone->flags);
> -}
> -
>  static inline int zone_is_oom_locked(const struct zone *zone)
>  {
>  	return test_bit(ZONE_OOM_LOCKED, &zone->flags);
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index fa6a853..cc5bb01 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -3424,11 +3424,7 @@ int zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
>  	if (node_state(node_id, N_CPU) && node_id != numa_node_id())
>  		return ZONE_RECLAIM_NOSCAN;
>  
> -	if (zone_test_and_set_flag(zone, ZONE_RECLAIM_LOCKED))
> -		return ZONE_RECLAIM_NOSCAN;
> -
>  	ret = __zone_reclaim(zone, gfp_mask, order);
> -	zone_clear_flag(zone, ZONE_RECLAIM_LOCKED);
>  
>  	if (!ret)
>  		count_vm_event(PGSCAN_ZONE_RECLAIM_FAILED);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
