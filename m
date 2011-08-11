Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id A979E6B0169
	for <linux-mm@kvack.org>; Thu, 11 Aug 2011 17:10:06 -0400 (EDT)
Date: Thu, 11 Aug 2011 23:09:14 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 2/8] mm: memcg-aware global reclaim
Message-ID: <20110811210914.GB31229@cmpxchg.org>
References: <1306909519-7286-1-git-send-email-hannes@cmpxchg.org>
 <1306909519-7286-3-git-send-email-hannes@cmpxchg.org>
 <CALWz4iwChnacF061L9vWo7nEA7qaXNJrK=+jsEe9xBtvEBD9MA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALWz4iwChnacF061L9vWo7nEA7qaXNJrK=+jsEe9xBtvEBD9MA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Aug 11, 2011 at 01:39:45PM -0700, Ying Han wrote:
> Please consider including the following patch for the next post. It causes
> crash on some of the tests where sc->mem_cgroup is NULL (global kswapd).
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index b72a844..12ab25d 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2768,7 +2768,8 @@ loop_again:
>                          * Do some background aging of the anon list, to
> give
>                          * pages a chance to be referenced before
> reclaiming.
>                          */
> -                       if (inactive_anon_is_low(zone, &sc))
> +                       if (scanning_global_lru(&sc) &&
> +                                       inactive_anon_is_low(zone, &sc))
>                                 shrink_active_list(SWAP_CLUSTER_MAX, zone,
>                                                         &sc, priority, 0);

Thanks!  I completely overlooked this one and only noticed it after
changing the arguments to shrink_active_list().

On memcg configurations, scanning_global_lru() will essentially never
be true again, so I moved the anon pre-aging to a separate function
that also does a hierarchy loop to preage the per-memcg anon lists.

I hope to send out the next revision soon.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
