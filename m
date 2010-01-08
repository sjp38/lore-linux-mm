Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 969906B003D
	for <linux-mm@kvack.org>; Fri,  8 Jan 2010 00:30:35 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o085UXjA008703
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 8 Jan 2010 14:30:33 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id B423B45DE7A
	for <linux-mm@kvack.org>; Fri,  8 Jan 2010 14:30:32 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 8B6AA45DE6F
	for <linux-mm@kvack.org>; Fri,  8 Jan 2010 14:30:32 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 43E20E1800C
	for <linux-mm@kvack.org>; Fri,  8 Jan 2010 14:30:32 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id B5BD8E18005
	for <linux-mm@kvack.org>; Fri,  8 Jan 2010 14:30:31 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH -mmotm-2010-01-06-14-34] check high watermark after shrink zone
In-Reply-To: <20100108141235.ef56b567.minchan.kim@barrios-desktop>
References: <20100108141235.ef56b567.minchan.kim@barrios-desktop>
Message-Id: <20100108141654.C13E.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri,  8 Jan 2010 14:30:30 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

> Kswapd check that zone have enough free by zone_water_mark.
> If any zone doesn't have enough page, it set all_zones_ok to zero.
> all_zone_ok makes kswapd retry not sleeping.
> 
> I think the watermark check before shrink zone is pointless.
> Kswapd try to shrink zone then the check is meaningul.

probably s/meaningul/meaningful/ ?

	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>


> 
> This patch move the check after shrink zone.
> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
> CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> CC: Mel Gorman <mel@csn.ul.ie>
> CC: Rik van Riel <riel@redhat.com>
> ---
>  mm/vmscan.c |   21 +++++++++++----------
>  1 files changed, 11 insertions(+), 10 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 885207a..b81adf8 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2057,9 +2057,6 @@ loop_again:
>  					priority != DEF_PRIORITY)
>  				continue;
>  
> -			if (!zone_watermark_ok(zone, order,
> -					high_wmark_pages(zone), end_zone, 0))
> -				all_zones_ok = 0;
>  			temp_priority[i] = priority;
>  			sc.nr_scanned = 0;
>  			note_zone_scanning_priority(zone, priority);
> @@ -2099,13 +2096,17 @@ loop_again:
>  			    total_scanned > sc.nr_reclaimed + sc.nr_reclaimed / 2)
>  				sc.may_writepage = 1;
>  
> -			/*
> -			 * We are still under min water mark. it mean we have
> -			 * GFP_ATOMIC allocation failure risk. Hurry up!
> -			 */
> -			if (!zone_watermark_ok(zone, order, min_wmark_pages(zone),
> -					      end_zone, 0))
> -				has_under_min_watermark_zone = 1;
> +			if (!zone_watermark_ok(zone, order,
> +					high_wmark_pages(zone), end_zone, 0)) {
> +				all_zones_ok = 0;
> +				/*
> +				 * We are still under min water mark. it mean we have
> +				 * GFP_ATOMIC allocation failure risk. Hurry up!
> +				 */
> +				if (!zone_watermark_ok(zone, order, min_wmark_pages(zone),
> +						      end_zone, 0))
> +					has_under_min_watermark_zone = 1;
> +			}
>  



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
