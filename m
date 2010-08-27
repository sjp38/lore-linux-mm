Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 1475C6B01F2
	for <linux-mm@kvack.org>; Thu, 26 Aug 2010 21:22:16 -0400 (EDT)
Date: Fri, 27 Aug 2010 09:21:47 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [RFC PATCH 0/3] Do not wait the full timeout on
 congestion_wait when there is no congestion
Message-ID: <20100827012147.GC7353@localhost>
References: <1282835656-5638-1-git-send-email-mel@csn.ul.ie>
 <20100826172038.GA6873@barrios-desktop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100826172038.GA6873@barrios-desktop>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Mel Gorman <mel@csn.ul.ie>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Li Shaohua <shaohua.li@intel.com>
List-ID: <linux-mm.kvack.org>

Minchan,

It's much cleaner to keep the unchanged congestion_wait() and add a
congestion_wait_check() for converting problematic wait sites. The
too_many_isolated() wait is merely a protective mechanism, I won't
bother to improve it at the cost of more code.

Thanks,
Fengguang

> diff --git a/mm/compaction.c b/mm/compaction.c
> index 94cce51..7370683 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -253,7 +253,11 @@ static unsigned long isolate_migratepages(struct zone *zone,
>          * delay for some time until fewer pages are isolated
>          */  
>         while (unlikely(too_many_isolated(zone))) {
> -               congestion_wait(BLK_RW_ASYNC, HZ/10);
> +               long timeout = HZ/10;
> +               if (timeout == congestion_wait(BLK_RW_ASYNC, timeout)) {
> +                       set_current_state(TASK_INTERRUPTIBLE);
> +                       schedule_timeout(timeout);
> +               }
> 
>                 if (fatal_signal_pending(current))
>                         return 0;

> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 3109ff7..f5e3e28 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1337,7 +1337,11 @@ shrink_inactive_list(unsigned long nr_to_scan, struct zone *zone,
>         unsigned long nr_dirty;
>         while (unlikely(too_many_isolated(zone, file, sc))) {
> -               congestion_wait(BLK_RW_ASYNC, HZ/10);
> +               long timeout = HZ/10;
> +               if (timeout == congestion_wait(BLK_RW_ASYNC, timeout)) {
> +                       set_current_state(TASK_INTERRUPTIBLE);
> +                       schedule_timeout(timeout);
> +               }
> 
>                 /* We are about to die and free our memory. Return now. */
>                 if (fatal_signal_pending(current))
> -- 
> 1.7.0.5
> 
> 
> -- 
> Kind regards,
> Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
