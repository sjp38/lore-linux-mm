Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id E2DBE6B005A
	for <linux-mm@kvack.org>; Fri, 21 Aug 2009 13:23:35 -0400 (EDT)
Subject: Re: [PATCH] mm/vmscan: rename zone_nr_pages() to
 zone_lru_nr_pages()
From: Fernando Carrijo <fcarrijo@yahoo.com.br>
In-Reply-To: <1250793774-7969-1-git-send-email-macli@brc.ubc.ca>
References: <1250793774-7969-1-git-send-email-macli@brc.ubc.ca>
Content-Type: text/plain
Date: Thu, 20 Aug 2009 22:23:39 -0300
Message-Id: <1250817819.4835.21.camel@pc-fernando>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Vincent Li <macli@brc.ubc.ca>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2009-08-20 at 11:42 -0700, Vincent Li wrote:
> Name zone_nr_pages can be mis-read as zone's (total) number pages, but it actually returns
> zone's LRU list number pages.
> 
> I know reading the code would clear the name confusion, want to know if patch making sense.

In case this patch gets an ack, wouldn't it make sense to try to keep
some consistency by renaming the function mem_cgroup_zone_nr_pages to
mem_cgroup_zone_lru_nr_pages, since it also deals with an specific LRU?

Fernando Carrijo

>  
> Signed-off-by: Vincent Li <macli@brc.ubc.ca>
> ---
>  mm/vmscan.c |   12 ++++++------
>  1 files changed, 6 insertions(+), 6 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 00596b9..9a55cb3 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -148,7 +148,7 @@ static struct zone_reclaim_stat *get_reclaim_stat(struct zone *zone,
>  	return &zone->reclaim_stat;
>  }
>  
> -static unsigned long zone_nr_pages(struct zone *zone, struct scan_control *sc,
> +static unsigned long zone_lru_nr_pages(struct zone *zone, struct scan_control *sc,
>  				   enum lru_list lru)
>  {
>  	if (!scanning_global_lru(sc))
> @@ -1479,10 +1479,10 @@ static void get_scan_ratio(struct zone *zone, struct scan_control *sc,
>  	unsigned long ap, fp;
>  	struct zone_reclaim_stat *reclaim_stat = get_reclaim_stat(zone, sc);
>  
> -	anon  = zone_nr_pages(zone, sc, LRU_ACTIVE_ANON) +
> -		zone_nr_pages(zone, sc, LRU_INACTIVE_ANON);
> -	file  = zone_nr_pages(zone, sc, LRU_ACTIVE_FILE) +
> -		zone_nr_pages(zone, sc, LRU_INACTIVE_FILE);
> +	anon  = zone_lru_nr_pages(zone, sc, LRU_ACTIVE_ANON) +
> +		zone_lru_nr_pages(zone, sc, LRU_INACTIVE_ANON);
> +	file  = zone_lru_nr_pages(zone, sc, LRU_ACTIVE_FILE) +
> +		zone_lru_nr_pages(zone, sc, LRU_INACTIVE_FILE);
>  
>  	if (scanning_global_lru(sc)) {
>  		free  = zone_page_state(zone, NR_FREE_PAGES);
> @@ -1590,7 +1590,7 @@ static void shrink_zone(int priority, struct zone *zone,
>  		int file = is_file_lru(l);
>  		unsigned long scan;
>  
> -		scan = zone_nr_pages(zone, sc, l);
> +		scan = zone_lru_nr_pages(zone, sc, l);
>  		if (priority || noswap) {
>  			scan >>= priority;
>  			scan = (scan * percent[file]) / 100;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
