Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f173.google.com (mail-io0-f173.google.com [209.85.223.173])
	by kanga.kvack.org (Postfix) with ESMTP id 1F7046B025C
	for <linux-mm@kvack.org>; Thu, 28 Jan 2016 22:42:16 -0500 (EST)
Received: by mail-io0-f173.google.com with SMTP id f81so76740048iof.0
        for <linux-mm@kvack.org>; Thu, 28 Jan 2016 19:42:16 -0800 (PST)
Received: from us-alimail-mta1.hst.scl.en.alidc.net (mail113-251.mail.alibaba.com. [205.204.113.251])
        by mx.google.com with ESMTP id 138si23314670ioc.9.2016.01.28.19.42.13
        for <linux-mm@kvack.org>;
        Thu, 28 Jan 2016 19:42:15 -0800 (PST)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <1450203586-10959-1-git-send-email-mhocko@kernel.org> <1454015979-9985-1-git-send-email-mhocko@kernel.org>
In-Reply-To: <1454015979-9985-1-git-send-email-mhocko@kernel.org>
Subject: Re: [PATCH 5/3] mm, vmscan: make zone_reclaimable_pages more precise
Date: Fri, 29 Jan 2016 11:41:53 +0800
Message-ID: <05f101d15a46$fef53b70$fcdfb250$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Michal Hocko' <mhocko@kernel.org>, 'Andrew Morton' <akpm@linux-foundation.org>
Cc: 'Linus Torvalds' <torvalds@linux-foundation.org>, 'Johannes Weiner' <hannes@cmpxchg.org>, 'Mel Gorman' <mgorman@suse.de>, 'David Rientjes' <rientjes@google.com>, 'Tetsuo Handa' <penguin-kernel@I-love.SAKURA.ne.jp>, 'KAMEZAWA Hiroyuki' <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, 'LKML' <linux-kernel@vger.kernel.org>, 'Michal Hocko' <mhocko@suse.com>

> 
> From: Michal Hocko <mhocko@suse.com>
> 
> zone_reclaimable_pages is used in should_reclaim_retry which uses it to
> calculate the target for the watermark check. This means that precise
> numbers are important for the correct decision. zone_reclaimable_pages
> uses zone_page_state which can contain stale data with per-cpu diffs
> not synced yet (the last vmstat_update might have run 1s in the past).
> 
> Use zone_page_state_snapshot in zone_reclaimable_pages instead. None
> of the current callers is in a hot path where getting the precise value
> (which involves per-cpu iteration) would cause an unreasonable overhead.
> 
> Suggested-by: David Rientjes <rientjes@google.com>
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---

Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>

>  mm/vmscan.c | 14 +++++++-------
>  1 file changed, 7 insertions(+), 7 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 489212252cd6..9145e3f89eab 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -196,21 +196,21 @@ unsigned long zone_reclaimable_pages(struct zone *zone)
>  {
>  	unsigned long nr;
> 
> -	nr = zone_page_state(zone, NR_ACTIVE_FILE) +
> -	     zone_page_state(zone, NR_INACTIVE_FILE) +
> -	     zone_page_state(zone, NR_ISOLATED_FILE);
> +	nr = zone_page_state_snapshot(zone, NR_ACTIVE_FILE) +
> +	     zone_page_state_snapshot(zone, NR_INACTIVE_FILE) +
> +	     zone_page_state_snapshot(zone, NR_ISOLATED_FILE);
> 
>  	if (get_nr_swap_pages() > 0)
> -		nr += zone_page_state(zone, NR_ACTIVE_ANON) +
> -		      zone_page_state(zone, NR_INACTIVE_ANON) +
> -		      zone_page_state(zone, NR_ISOLATED_ANON);
> +		nr += zone_page_state_snapshot(zone, NR_ACTIVE_ANON) +
> +		      zone_page_state_snapshot(zone, NR_INACTIVE_ANON) +
> +		      zone_page_state_snapshot(zone, NR_ISOLATED_ANON);
> 
>  	return nr;
>  }
> 
>  bool zone_reclaimable(struct zone *zone)
>  {
> -	return zone_page_state(zone, NR_PAGES_SCANNED) <
> +	return zone_page_state_snapshot(zone, NR_PAGES_SCANNED) <
>  		zone_reclaimable_pages(zone) * 6;
>  }
> 
> --
> 2.7.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
