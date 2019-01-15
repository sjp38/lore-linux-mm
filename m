Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3AF908E0002
	for <linux-mm@kvack.org>; Tue, 15 Jan 2019 07:17:09 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id s50so1041541edd.11
        for <linux-mm@kvack.org>; Tue, 15 Jan 2019 04:17:09 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w11-v6si877731ejk.26.2019.01.15.04.17.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Jan 2019 04:17:07 -0800 (PST)
Date: Tue, 15 Jan 2019 13:17:06 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm: Remove 7th argument of isolate_lru_pages()
Message-ID: <20190115121706.GR21345@dhcp22.suse.cz>
References: <154748280735.29962.15867846875217618569.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <154748280735.29962.15867846875217618569.stgit@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org

On Mon 14-01-19 19:20:24, Kirill Tkhai wrote:
> We may simply check for sc->may_unmap in isolate_lru_pages()
> instead of doing that in both of its callers.

This code seems stale for a long time. AFAICS 1276ad68e249 ("mm: vmscan:
scan dirty pages even in laptop mode") has removed ISOLATE_CLEAN and
there was no other mode besides that and ISOLATE_UNMAPPED.

> Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/vmscan.c |   15 ++++-----------
>  1 file changed, 4 insertions(+), 11 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index a714c4f800e9..8202f8eb602d 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1663,7 +1663,7 @@ static __always_inline void update_lru_sizes(struct lruvec *lruvec,
>  static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
>  		struct lruvec *lruvec, struct list_head *dst,
>  		unsigned long *nr_scanned, struct scan_control *sc,
> -		isolate_mode_t mode, enum lru_list lru)
> +		enum lru_list lru)
>  {
>  	struct list_head *src = &lruvec->lists[lru];
>  	unsigned long nr_taken = 0;
> @@ -1672,6 +1672,7 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
>  	unsigned long skipped = 0;
>  	unsigned long scan, total_scan, nr_pages;
>  	LIST_HEAD(pages_skipped);
> +	isolate_mode_t mode = (sc->may_unmap ? 0 : ISOLATE_UNMAPPED);
>  
>  	scan = 0;
>  	for (total_scan = 0;
> @@ -1910,7 +1911,6 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
>  	unsigned long nr_reclaimed = 0;
>  	unsigned long nr_taken;
>  	struct reclaim_stat stat = {};
> -	isolate_mode_t isolate_mode = 0;
>  	int file = is_file_lru(lru);
>  	struct pglist_data *pgdat = lruvec_pgdat(lruvec);
>  	struct zone_reclaim_stat *reclaim_stat = &lruvec->reclaim_stat;
> @@ -1931,13 +1931,10 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
>  
>  	lru_add_drain();
>  
> -	if (!sc->may_unmap)
> -		isolate_mode |= ISOLATE_UNMAPPED;
> -
>  	spin_lock_irq(&pgdat->lru_lock);
>  
>  	nr_taken = isolate_lru_pages(nr_to_scan, lruvec, &page_list,
> -				     &nr_scanned, sc, isolate_mode, lru);
> +				     &nr_scanned, sc, lru);
>  
>  	__mod_node_page_state(pgdat, NR_ISOLATED_ANON + file, nr_taken);
>  	reclaim_stat->recent_scanned[file] += nr_taken;
> @@ -2094,19 +2091,15 @@ static void shrink_active_list(unsigned long nr_to_scan,
>  	struct zone_reclaim_stat *reclaim_stat = &lruvec->reclaim_stat;
>  	unsigned nr_deactivate, nr_activate;
>  	unsigned nr_rotated = 0;
> -	isolate_mode_t isolate_mode = 0;
>  	int file = is_file_lru(lru);
>  	struct pglist_data *pgdat = lruvec_pgdat(lruvec);
>  
>  	lru_add_drain();
>  
> -	if (!sc->may_unmap)
> -		isolate_mode |= ISOLATE_UNMAPPED;
> -
>  	spin_lock_irq(&pgdat->lru_lock);
>  
>  	nr_taken = isolate_lru_pages(nr_to_scan, lruvec, &l_hold,
> -				     &nr_scanned, sc, isolate_mode, lru);
> +				     &nr_scanned, sc, lru);
>  
>  	__mod_node_page_state(pgdat, NR_ISOLATED_ANON + file, nr_taken);
>  	reclaim_stat->recent_scanned[file] += nr_taken;
> 

-- 
Michal Hocko
SUSE Labs
