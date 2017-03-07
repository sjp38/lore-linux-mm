Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 855C56B038A
	for <linux-mm@kvack.org>; Mon,  6 Mar 2017 20:00:03 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id f21so226956405pgi.4
        for <linux-mm@kvack.org>; Mon, 06 Mar 2017 17:00:03 -0800 (PST)
Received: from out0-136.mail.aliyun.com (out0-136.mail.aliyun.com. [140.205.0.136])
        by mx.google.com with ESMTP id 34si20643768plz.66.2017.03.06.17.00.02
        for <linux-mm@kvack.org>;
        Mon, 06 Mar 2017 17:00:02 -0800 (PST)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <20170228214007.5621-1-hannes@cmpxchg.org> <20170228214007.5621-2-hannes@cmpxchg.org> <20170303012609.GA3394@bbox> <20170303075954.GA31499@dhcp22.suse.cz> <20170306013740.GA8779@bbox> <20170306162410.GB2090@cmpxchg.org>
In-Reply-To: <20170306162410.GB2090@cmpxchg.org>
Subject: Re: [PATCH 1/9] mm: fix 100% CPU kswapd busyloop on unreclaimable nodes
Date: Tue, 07 Mar 2017 08:59:55 +0800
Message-ID: <086701d296de$231e7370$695b5a50$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Johannes Weiner' <hannes@cmpxchg.org>, 'Minchan Kim' <minchan@kernel.org>
Cc: 'Michal Hocko' <mhocko@kernel.org>, 'Andrew Morton' <akpm@linux-foundation.org>, 'Jia He' <hejianet@gmail.com>, 'Mel Gorman' <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com


On March 07, 2017 12:24 AM Johannes Weiner wrote: 
> On Mon, Mar 06, 2017 at 10:37:40AM +0900, Minchan Kim wrote:
> > On Fri, Mar 03, 2017 at 08:59:54AM +0100, Michal Hocko wrote:
> > > On Fri 03-03-17 10:26:09, Minchan Kim wrote:
> > > > On Tue, Feb 28, 2017 at 04:39:59PM -0500, Johannes Weiner wrote:
> > > > > @@ -3316,6 +3325,9 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
> > > > >  			sc.priority--;
> > > > >  	} while (sc.priority >= 1);
> > > > >
> > > > > +	if (!sc.nr_reclaimed)
> > > > > +		pgdat->kswapd_failures++;
> > > >
> > > > sc.nr_reclaimed is reset to zero in above big loop's beginning so most of time,
> > > > it pgdat->kswapd_failures is increased.
> 
> That wasn't intentional; I didn't see the sc.nr_reclaimed reset.
> 
> ---
> 
> From e126db716926ff353b35f3a6205bd5853e01877b Mon Sep 17 00:00:00 2001
> From: Johannes Weiner <hannes@cmpxchg.org>
> Date: Mon, 6 Mar 2017 10:53:59 -0500
> Subject: [PATCH] mm: fix 100% CPU kswapd busyloop on unreclaimable nodes fix
> 
> Check kswapd failure against the cumulative nr_reclaimed count, not
> against the count from the lowest priority iteration.
> 
> Suggested-by: Minchan Kim <minchan@kernel.org>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
>  mm/vmscan.c | 5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index ddcff8a11c1e..b834b2dd4e19 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -3179,9 +3179,9 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
>  	count_vm_event(PAGEOUTRUN);
> 
>  	do {
> +		unsigned long nr_reclaimed = sc.nr_reclaimed;
>  		bool raise_priority = true;
> 
> -		sc.nr_reclaimed = 0;

This has another effect that we'll reclaim less pages than we're
currently doing if we are balancing for high order request. And 
it looks worth including that info also in log message.

>  		sc.reclaim_idx = classzone_idx;
> 
>  		/*
> @@ -3271,7 +3271,8 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
>  		 * Raise priority if scanning rate is too low or there was no
>  		 * progress in reclaiming pages
>  		 */
> -		if (raise_priority || !sc.nr_reclaimed)
> +		nr_reclaimed = sc.nr_reclaimed - nr_reclaimed;
> +		if (raise_priority || !nr_reclaimed)
>  			sc.priority--;
>  	} while (sc.priority >= 1);
> 
> --
> 2.11.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
