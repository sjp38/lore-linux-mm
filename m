Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id C5F936B026A
	for <linux-mm@kvack.org>; Tue, 19 Jul 2016 03:34:31 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id r190so8004025wmr.0
        for <linux-mm@kvack.org>; Tue, 19 Jul 2016 00:34:31 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id y135si18497208wmd.74.2016.07.19.00.34.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Jul 2016 00:34:30 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id i5so1804726wmg.2
        for <linux-mm@kvack.org>; Tue, 19 Jul 2016 00:34:30 -0700 (PDT)
Date: Tue, 19 Jul 2016 09:34:29 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/vmscan: remove pglist_data->inactive_ratio
Message-ID: <20160719073428.GB9486@dhcp22.suse.cz>
References: <1468894049-786-1-git-send-email-opensource.ganesh@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1468894049-786-1-git-send-email-opensource.ganesh@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ganesh Mahendran <opensource.ganesh@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, mgorman@techsingularity.net, minchan@kernel.org, hannes@cmpxchg.org, riel@redhat.com, dan.j.williams@intel.com, vdavydov@virtuozzo.com, kirill.shutemov@linux.intel.com, cl@linux.com, hughd@google.com

On Tue 19-07-16 10:07:29, Ganesh Mahendran wrote:
> In patch [1], the inactive_ratio is now automatically calculated

It is better to give the direct reference to the patch 59dc76b0d4df
("mm: vmscan: reduce size of inactive file list")

> in inactive_list_is_low(). So there is no need to keep inactive_ratio
> in pglist_data,

OK

> and shown in zoneinfo.

I am not so sure about this. To be honest I have never really used this
value but maybe there is somebody outher who relies on it. It would be
safer if the ratio calculation in inactive_list_is_low would be
extracted and used to display the information rather than dropping that
on the floor.

The patch should also state that the above patch has broken the zoneinfo
information.

> [1] mm: vmscan: reduce size of inactive file list
> 
> Signed-off-by: Ganesh Mahendran <opensource.ganesh@gmail.com>
> ---
>  include/linux/mmzone.h | 6 ------
>  mm/vmscan.c            | 2 +-
>  mm/vmstat.c            | 6 ++----
>  3 files changed, 3 insertions(+), 11 deletions(-)
> 
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index a3b7f45..b3ade54 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -700,12 +700,6 @@ typedef struct pglist_data {
>  	/* Fields commonly accessed by the page reclaim scanner */
>  	struct lruvec		lruvec;
>  
> -	/*
> -	 * The target ratio of ACTIVE_ANON to INACTIVE_ANON pages on
> -	 * this node's LRU.  Maintained by the pageout code.
> -	 */
> -	unsigned int inactive_ratio;
> -
>  	unsigned long		flags;
>  
>  	ZONE_PADDING(_pad2_)
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 429bf3a..3c1de58 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1915,7 +1915,7 @@ static void shrink_active_list(unsigned long nr_to_scan,
>   * page has a chance to be referenced again before it is reclaimed.
>   *
>   * The inactive_ratio is the target ratio of ACTIVE to INACTIVE pages
> - * on this LRU, maintained by the pageout code. A zone->inactive_ratio
> + * on this LRU, maintained by the pageout code. A inactive_ratio
>   * of 3 means 3:1 or 25% of the pages are kept on the inactive list.
>   *
>   * total     target    max
> diff --git a/mm/vmstat.c b/mm/vmstat.c
> index 91ecca9..74a0eca 100644
> --- a/mm/vmstat.c
> +++ b/mm/vmstat.c
> @@ -1491,11 +1491,9 @@ static void zoneinfo_show_print(struct seq_file *m, pg_data_t *pgdat,
>  	}
>  	seq_printf(m,
>  		   "\n  node_unreclaimable:  %u"
> -		   "\n  start_pfn:           %lu"
> -		   "\n  node_inactive_ratio: %u",
> +		   "\n  start_pfn:           %lu",
>  		   !pgdat_reclaimable(zone->zone_pgdat),
> -		   zone->zone_start_pfn,
> -		   zone->zone_pgdat->inactive_ratio);
> +		   zone->zone_start_pfn);
>  	seq_putc(m, '\n');
>  }
>  
> -- 
> 1.9.1
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
