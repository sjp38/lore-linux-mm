Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 708416B0033
	for <linux-mm@kvack.org>; Tue, 17 Jan 2017 01:58:23 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id n189so114515923pga.4
        for <linux-mm@kvack.org>; Mon, 16 Jan 2017 22:58:23 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id 1si24024551pli.45.2017.01.16.22.58.21
        for <linux-mm@kvack.org>;
        Mon, 16 Jan 2017 22:58:22 -0800 (PST)
Date: Tue, 17 Jan 2017 15:58:19 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 1/3] mm, vmscan: cleanup lru size claculations
Message-ID: <20170117065818.GC9812@blaptop>
References: <20170116160123.GB30300@cmpxchg.org>
 <20170116193317.20390-1-mhocko@kernel.org>
MIME-Version: 1.0
In-Reply-To: <20170116193317.20390-1-mhocko@kernel.org>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Hillf Danton <hillf.zj@alibaba-inc.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Mon, Jan 16, 2017 at 08:33:15PM +0100, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> lruvec_lru_size returns the full size of the LRU list while we sometimes
> need a value reduced only to eligible zones (e.g. for lowmem requests).
> inactive_list_is_low is one such user. Later patches will add more of
> them. Add a new parameter to lruvec_lru_size and allow it filter out
> zones which are not eligible for the given context.
> 
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
>  include/linux/mmzone.h |  2 +-
>  mm/vmscan.c            | 88 ++++++++++++++++++++++++--------------------------
>  mm/workingset.c        |  2 +-
>  3 files changed, 45 insertions(+), 47 deletions(-)
> 
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index d1d440cff60e..91f69aa0d581 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -780,7 +780,7 @@ static inline struct pglist_data *lruvec_pgdat(struct lruvec *lruvec)
>  #endif
>  }
>  
> -extern unsigned long lruvec_lru_size(struct lruvec *lruvec, enum lru_list lru);
> +extern unsigned long lruvec_lru_size(struct lruvec *lruvec, enum lru_list lru, int zone_idx);
>  
>  #ifdef CONFIG_HAVE_MEMORY_PRESENT
>  void memory_present(int nid, unsigned long start, unsigned long end);
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index cf940af609fd..1cb0ebdef305 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -234,22 +234,38 @@ bool pgdat_reclaimable(struct pglist_data *pgdat)
>  		pgdat_reclaimable_pages(pgdat) * 6;
>  }
>  
> -unsigned long lruvec_lru_size(struct lruvec *lruvec, enum lru_list lru)
> +/** lruvec_lru_size -  Returns the number of pages on the given LRU list.

minor:

/*
 * lruvec_lru_size

I don't have any preferance but just found.

Otherwise,
Acked-by: Minchan Kim <minchan@kernel.org>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
