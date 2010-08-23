Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id BA6AD6007DC
	for <linux-mm@kvack.org>; Mon, 23 Aug 2010 03:16:27 -0400 (EDT)
Date: Mon, 23 Aug 2010 08:16:11 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: compaction: trying to understand the code
Message-ID: <20100823071610.GL19797@csn.ul.ie>
References: <20100817111018.GQ19797@csn.ul.ie> <4385155269B445AEAF27DC8639A953D7@rainbow> <20100818154130.GC9431@localhost> <565A4EE71DAC4B1A820B2748F56ABF73@rainbow> <20100819160006.GG6805@barrios-desktop> <AA3F2D89535A431DB91FE3032EDCB9EA@rainbow> <20100820053447.GA13406@localhost> <20100820093558.GG19797@csn.ul.ie> <AANLkTimVmoomDjGMCfKvNrS+v-mMnfeq6JDZzx7fjZi+@mail.gmail.com> <20100822153121.GA29389@barrios-desktop>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100822153121.GA29389@barrios-desktop>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, Iram Shahzad <iram.shahzad@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Mon, Aug 23, 2010 at 12:31:21AM +0900, Minchan Kim wrote:
> <SNIP>
> 
> From 560e8898295c663f02aede07b3d55880eba16c69 Mon Sep 17 00:00:00 2001
> From: Minchan Kim <minchan.kim@gmail.com>
> Date: Mon, 23 Aug 2010 00:20:44 +0900
> Subject: [PATCH] compaction: handle active and inactive fairly in too_many_isolated
> 
> Iram reported compaction's too_many_isolated loops forever.
> (http://www.spinics.net/lists/linux-mm/msg08123.html)
> 
> The meminfo of situation happened was inactive anon is zero.
> That's because the system has no memory pressure until then.
> While all anon pages was in active lru, compaction could select
> active lru as well as inactive lru. That's different things
> with vmscan's isolated. So we has been two too_many_isolated.
> 
> While compaction can isolated pages in both active and inactive,
> current implementation of too_many_isolated only considers inactive.
> It made Iram's problem.
> 
> This patch handles active and inactie with fair.
> That's because we can't expect where from and how many compaction would
> isolated pages.
> 
> This patch changes (nr_isolated > nr_inactive) with
> nr_isolated > (nr_active + nr_inactive) / 2.
> 
> Cc: Mel Gorman <mel@csn.ul.ie>
> Cc: Wu Fengguang <fengguang.wu@intel.com>
> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>

Seems reasonable to me.

Acked-by: Mel Gorman <mel@csn.ul.ie>

Want to repost this as a standalone patch?

> ---
>  mm/compaction.c |    9 +++++----
>  1 files changed, 5 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 94cce51..0864839 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -214,15 +214,16 @@ static void acct_isolated(struct zone *zone, struct compact_control *cc)
>  /* Similar to reclaim, but different enough that they don't share logic */
>  static bool too_many_isolated(struct zone *zone)
>  {
> -
> -       unsigned long inactive, isolated;
> +       unsigned long active, inactive, isolated;
>  
>         inactive = zone_page_state(zone, NR_INACTIVE_FILE) +
>                                         zone_page_state(zone, NR_INACTIVE_ANON);
> +       active = zone_page_state(zone, NR_ACTIVE_FILE) +
> +                                       zone_page_state(zone, NR_ACTIVE_ANON);
>         isolated = zone_page_state(zone, NR_ISOLATED_FILE) +
>                                         zone_page_state(zone, NR_ISOLATED_ANON);
> -
> -       return isolated > inactive;
> +
> +       return isolated > (inactive + active) / 2;
>  }
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
