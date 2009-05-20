Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id DF4B76B0062
	for <linux-mm@kvack.org>; Wed, 20 May 2009 03:25:44 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n4K7Q6j9021377
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 20 May 2009 16:26:06 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7E30845DD7F
	for <linux-mm@kvack.org>; Wed, 20 May 2009 16:26:06 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4A7AE45DD7D
	for <linux-mm@kvack.org>; Wed, 20 May 2009 16:26:06 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 30D5D1DB8037
	for <linux-mm@kvack.org>; Wed, 20 May 2009 16:26:06 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id CBEC41DB803C
	for <linux-mm@kvack.org>; Wed, 20 May 2009 16:26:05 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 2/3] add inactive ratio calculation function of each zone
In-Reply-To: <20090520161936.c86a0e38.minchan.kim@barrios-desktop>
References: <20090520161936.c86a0e38.minchan.kim@barrios-desktop>
Message-Id: <20090520162527.7449.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 20 May 2009 16:26:04 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

> This patch divides setup_per_zone_inactive_ratio with
> per zone inactive ratio calculaton.
> 
> CC: Rik van Riel <riel@redhat.com>
> CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> CC: Johannes Weiner <hannes@cmpxchg.org>
> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>

looks good.
  Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>


> ---
>  include/linux/mm.h |    1 +
>  mm/page_alloc.c    |   14 +++++++++-----
>  2 files changed, 10 insertions(+), 5 deletions(-)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 1b2cb16..cede957 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -1059,6 +1059,7 @@ extern void set_dma_reserve(unsigned long new_dma_reserve);
>  extern void memmap_init_zone(unsigned long, int, unsigned long,
>  				unsigned long, enum memmap_context);
>  extern void setup_per_zone_wmark_min(void);
> +extern void calculate_per_zone_inactive_ratio(struct zone* zone);
>  extern void mem_init(void);
>  extern void __init mmap_init(void);
>  extern void show_mem(void);
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 273526b..4601ba0 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -4552,11 +4552,8 @@ void setup_per_zone_wmark_min(void)
>   *    1TB     101        10GB
>   *   10TB     320        32GB
>   */
> -static void __init setup_per_zone_inactive_ratio(void)
> +void calculate_per_zone_inactive_ratio(struct zone* zone)
>  {
> -	struct zone *zone;
> -
> -	for_each_zone(zone) {
>  		unsigned int gb, ratio;
>  
>  		/* Zone size in gigabytes */
> @@ -4567,7 +4564,14 @@ static void __init setup_per_zone_inactive_ratio(void)
>  			ratio = 1;
>  
>  		zone->inactive_ratio = ratio;
> -	}
> +}
> +
> +static void __init setup_per_zone_inactive_ratio(void)
> +{
> +	struct zone *zone;
> +
> +	for_each_zone(zone) 
> +		calculate_per_zone_inactive_ratio(zone);
>  }
>  
>  /*
> -- 
> 1.5.4.3
> 
> 
> 
> -- 
> Kinds Regards
> Minchan Kim



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
