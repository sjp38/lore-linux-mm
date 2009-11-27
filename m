Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 6D6C26B004D
	for <linux-mm@kvack.org>; Fri, 27 Nov 2009 00:44:34 -0500 (EST)
Date: Thu, 26 Nov 2009 21:44:30 -0800 (PST)
From: Vincent Li <macli@brc.ubc.ca>
Subject: Re: [PATCH 2/4] vmscan: make lru_index() helper function
In-Reply-To: <20091127091755.A7CF.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.0911262138310.14657@kernalhack.brc.ubc.ca>
References: <20091127091357.A7CC.A69D9226@jp.fujitsu.com> <20091127091755.A7CF.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>


Hi KOSAKI,

On Fri, 27 Nov 2009, KOSAKI Motohiro wrote:

> Current lru calculation (e.g. LRU_ACTIVE + file * LRU_FILE) is a bit
> ugly.
> To make helper function improve code readability a bit.
> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> ---
>  mm/vmscan.c |   25 ++++++++++++++-----------
>  1 files changed, 14 insertions(+), 11 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index a58ff15..7e0245d 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -156,6 +156,16 @@ static unsigned long zone_nr_lru_pages(struct zone *zone,
>  	return zone_page_state(zone, NR_LRU_BASE + lru);
>  }
>  
> +static inline enum lru_list lru_index(int active, int file)
> +{
> +	int lru = LRU_BASE;
> +	if (active)
> +		lru += LRU_ACTIVE;
> +	if (file)
> +		lru += LRU_FILE;
> +
> +	return lru;
> +}
>  
> @@ -1373,10 +1378,8 @@ static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
>  	 */
>  	reclaim_stat->recent_rotated[file] += nr_rotated;
>  
> -	move_active_pages_to_lru(zone, &l_active,
> -						LRU_ACTIVE + file * LRU_FILE);
> -	move_active_pages_to_lru(zone, &l_inactive,
> -						LRU_BASE   + file * LRU_FILE);
> +	move_active_pages_to_lru(zone, &l_active, lru_index(1, file));
> +	move_active_pages_to_lru(zone, &l_inactive, lru_index(0, file));

How about:
	move_active_pages_to_lru(zone, &l_active, lru_index(LRU_ACTIVE, file));
	move_active_pages_to_lru(zone, &l_inactive, lru_index(LRU_BASE, file));
?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
