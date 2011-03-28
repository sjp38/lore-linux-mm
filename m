Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 5997A8D003B
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 03:35:56 -0400 (EDT)
Date: Mon, 28 Mar 2011 16:33:11 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH 1/2] check the return value of soft_limit reclaim
Message-Id: <20110328163311.127575fa.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <1301292775-4091-2-git-send-email-yinghan@google.com>
References: <1301292775-4091-1-git-send-email-yinghan@google.com>
	<1301292775-4091-2-git-send-email-yinghan@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

Hi,

This patch looks good to me, except for one nitpick.

On Sun, 27 Mar 2011 23:12:54 -0700
Ying Han <yinghan@google.com> wrote:

> In the global background reclaim, we do soft reclaim before scanning the
> per-zone LRU. However, the return value is ignored. This patch adds the logic
> where no per-zone reclaim happens if the soft reclaim raise the free pages
> above the zone's high_wmark.
> 
> I did notice a similar check exists but instead leaving a "gap" above the
> high_wmark(the code right after my change in vmscan.c). There are discussions
> on whether or not removing the "gap" which intends to balance pressures across
> zones over time. Without fully understand the logic behind, I didn't try to
> merge them into one, but instead adding the condition only for memcg users
> who care a lot on memory isolation.
> 
> Signed-off-by: Ying Han <yinghan@google.com>
> ---
>  mm/vmscan.c |   16 +++++++++++++++-
>  1 files changed, 15 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 060e4c1..e4601c5 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2320,6 +2320,7 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
>  	int end_zone = 0;	/* Inclusive.  0 = ZONE_DMA */
>  	unsigned long total_scanned;
>  	struct reclaim_state *reclaim_state = current->reclaim_state;
> +	unsigned long nr_soft_reclaimed;
>  	struct scan_control sc = {
>  		.gfp_mask = GFP_KERNEL,
>  		.may_unmap = 1,
> @@ -2413,7 +2414,20 @@ loop_again:
>  			 * Call soft limit reclaim before calling shrink_zone.
>  			 * For now we ignore the return value

You should remove this comment too.

But, Balbir-san, do you remember why did you ignore the return value here ?

Thanks,
Daisuke Nishimura.

>  			 */
> -			mem_cgroup_soft_limit_reclaim(zone, order, sc.gfp_mask);
> +			nr_soft_reclaimed = mem_cgroup_soft_limit_reclaim(zone,
> +							order, sc.gfp_mask);
> +
> +			/*
> +			 * Check the watermark after the soft limit reclaim. If
> +			 * the free pages is above the watermark, no need to
> +			 * proceed to the zone reclaim.
> +			 */
> +			if (nr_soft_reclaimed && zone_watermark_ok_safe(zone,
> +					order, high_wmark_pages(zone),
> +					end_zone, 0)) {
> +				__inc_zone_state(zone, NR_SKIP_RECLAIM_GLOBAL);
> +				continue;
> +			}
>  
>  			/*
>  			 * We put equal pressure on every zone, unless
> -- 
> 1.7.3.1
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
