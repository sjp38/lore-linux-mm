Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 0B7826B031D
	for <linux-mm@kvack.org>; Fri, 20 Aug 2010 06:24:01 -0400 (EDT)
Date: Fri, 20 Aug 2010 18:23:55 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: compaction: trying to understand the code
Message-ID: <20100820102355.GE8440@localhost>
References: <325E0A25FE724BA18190186F058FF37E@rainbow>
 <20100817111018.GQ19797@csn.ul.ie>
 <4385155269B445AEAF27DC8639A953D7@rainbow>
 <20100818154130.GC9431@localhost>
 <565A4EE71DAC4B1A820B2748F56ABF73@rainbow>
 <20100819160006.GG6805@barrios-desktop>
 <AA3F2D89535A431DB91FE3032EDCB9EA@rainbow>
 <20100820053447.GA13406@localhost>
 <20100820093558.GG19797@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100820093558.GG19797@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Iram Shahzad <iram.shahzad@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Fri, Aug 20, 2010 at 05:35:59PM +0800, Mel Gorman wrote:
> On Fri, Aug 20, 2010 at 01:34:47PM +0800, Wu Fengguang wrote:
> > You do run lots of tasks: kernel_stack=1880kB.
> > 
> > And you have lots of free memory, page reclaim has never run, so
> > inactive_anon=0. This is where compaction is different from vmscan.
> > In vmscan, inactive_anon is reasonably large, and will only be
> > compared directly with isolated_anon.
> > 
> 
> True, the key observation here was that compaction is being run via the
> proc trigger. Normally it would be run as part of the direct reclaim
> path when kswapd would already be awake. too_many_isolated() needs to be
> different for compaction to take the whole system into account. What
> would be the best alternative? Here is one possibility. A reasonable
> alternative would be that when inactive < active that isolated can't be
> more than num_online_cpus() * 2 (i.e. one compactor per online cpu).
>
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 94cce51..1e000b7 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -215,14 +215,16 @@ static void acct_isolated(struct zone *zone, struct compact_control *cc)
>  static bool too_many_isolated(struct zone *zone)
>  {
>  
> -	unsigned long inactive, isolated;
> +	unsigned long active, inactive, isolated;
>  
> +	active = zone_page_state(zone, NR_ACTIVE_FILE) +
> +					zone_page_state(zone, NR_INACTIVE_ANON);

s/NR_INACTIVE_ANON/NR_ACTIVE_ANON/

>  	inactive = zone_page_state(zone, NR_INACTIVE_FILE) +
>  					zone_page_state(zone, NR_INACTIVE_ANON);
>  	isolated = zone_page_state(zone, NR_ISOLATED_FILE) +
>  					zone_page_state(zone, NR_ISOLATED_ANON);
>  
> -	return isolated > inactive;
> +	return (inactive > active) ? isolated > inactive : false;

Note that for anon LRU, inactive_ratio may be large numbers.
(inactive > active) is not easy, and not stable even when inactive_ratio=1.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
