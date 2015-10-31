Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 2449682F64
	for <linux-mm@kvack.org>; Fri, 30 Oct 2015 23:57:20 -0400 (EDT)
Received: by pasz6 with SMTP id z6so91515117pas.2
        for <linux-mm@kvack.org>; Fri, 30 Oct 2015 20:57:19 -0700 (PDT)
Received: from us-alimail-mta1.hst.scl.en.alidc.net (mail113-250.mail.alibaba.com. [205.204.113.250])
        by mx.google.com with ESMTP id qy7si15731819pab.169.2015.10.30.20.57.17
        for <linux-mm@kvack.org>;
        Fri, 30 Oct 2015 20:57:19 -0700 (PDT)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <1446131835-3263-1-git-send-email-mhocko@kernel.org> <1446131835-3263-2-git-send-email-mhocko@kernel.org> <00f201d112c8$e2377720$a6a66560$@alibaba-inc.com> <20151030083626.GC18429@dhcp22.suse.cz> <20151030101436.GH18429@dhcp22.suse.cz>
In-Reply-To: <20151030101436.GH18429@dhcp22.suse.cz>
Subject: Re: [RFC 1/3] mm, oom: refactor oom detection
Date: Sat, 31 Oct 2015 11:57:00 +0800
Message-ID: <007101d11390$32703d90$9750b8b0$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Michal Hocko' <mhocko@kernel.org>
Cc: linux-mm@kvack.org, 'Andrew Morton' <akpm@linux-foundation.org>, 'Linus Torvalds' <torvalds@linux-foundation.org>, 'Mel Gorman' <mgorman@suse.de>, 'Johannes Weiner' <hannes@cmpxchg.org>, 'Rik van Riel' <riel@redhat.com>, 'David Rientjes' <rientjes@google.com>, 'Tetsuo Handa' <penguin-kernel@I-love.SAKURA.ne.jp>, 'LKML' <linux-kernel@vger.kernel.org>

> On Fri 30-10-15 09:36:26, Michal Hocko wrote:
> > On Fri 30-10-15 12:10:15, Hillf Danton wrote:
> > [...]
> > > > +	for_each_zone_zonelist_nodemask(zone, z, ac->zonelist, ac->high_zoneidx, ac->nodemask) {
> > > > +		unsigned long free = zone_page_state(zone, NR_FREE_PAGES);
> > > > +		unsigned long reclaimable;
> > > > +		unsigned long target;
> > > > +
> > > > +		reclaimable = zone_reclaimable_pages(zone) +
> > > > +			      zone_page_state(zone, NR_ISOLATED_FILE) +
> > > > +			      zone_page_state(zone, NR_ISOLATED_ANON);
> > > > +		target = reclaimable;
> > > > +		target -= stall_backoff * (1 + target/MAX_STALL_BACKOFF);
> > >
> > > 		target = reclaimable - stall_backoff * (1 + target/MAX_STALL_BACKOFF);
> > > 		             = reclaimable - stall_backoff - stall_backoff  * (target/MAX_STALL_BACKOFF);
> > >
> > > then the first stall_backoff looks unreasonable.
> >
> > First stall_backoff is off by 1 but that shouldn't make any difference.
> >
> > > I guess you mean
> > > 		target	= reclaimable - target * (stall_backoff/MAX_STALL_BACKOFF);
> > > 			= reclaimable - stall_back * (target/MAX_STALL_BACKOFF);
> >
> > No the reason I used the bias is to converge for MAX_STALL_BACKOFF. If
> > you have target which is not divisible by MAX_STALL_BACKOFF then the
> > rounding would get target > 0 and so we wouldn't converge. With the +1
> > you underflow which is MAX_STALL_BACKOFF in maximum which should be
> > fixed up by the free memory. Maybe a check for free < MAX_STALL_BACKOFF
> > would be good but I didn't get that far with this.
> 
> I've ended up with the following after all. It uses ceiling for the
> division this should be underflow safe albeit less readable (at least
> for me).

Looks good, thanks.

Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>

> ---
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 0dc1ca9b1219..c9a4e62f234e 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3176,7 +3176,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  			      zone_page_state(zone, NR_ISOLATED_FILE) +
>  			      zone_page_state(zone, NR_ISOLATED_ANON);
>  		target = reclaimable;
> -		target -= stall_backoff * (1 + target/MAX_STALL_BACKOFF);
> +		target -= (stall_backoff * target + MAX_STALL_BACKOFF - 1) / MAX_STALL_BACKOFF;
>  		target += free;
> 
>  		/*
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index bc14217acd47..0b3ec972ec7a 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2672,7 +2672,6 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
>  	int initial_priority = sc->priority;
>  	unsigned long total_scanned = 0;
>  	unsigned long writeback_threshold;
> -	bool zones_reclaimable;
>  retry:
>  	delayacct_freepages_start();
> 
> @@ -2683,7 +2682,7 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
>  		vmpressure_prio(sc->gfp_mask, sc->target_mem_cgroup,
>  				sc->priority);
>  		sc->nr_scanned = 0;
> -		zones_reclaimable = shrink_zones(zonelist, sc);
> +		shrink_zones(zonelist, sc);
> 
>  		total_scanned += sc->nr_scanned;
>  		if (sc->nr_reclaimed >= sc->nr_to_reclaim)
> --
> Michal Hocko
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
