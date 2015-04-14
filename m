Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 93A3F6B0032
	for <linux-mm@kvack.org>; Tue, 14 Apr 2015 12:49:44 -0400 (EDT)
Received: by widdi4 with SMTP id di4so121462084wid.0
        for <linux-mm@kvack.org>; Tue, 14 Apr 2015 09:49:44 -0700 (PDT)
Received: from mail-wg0-x22e.google.com (mail-wg0-x22e.google.com. [2a00:1450:400c:c00::22e])
        by mx.google.com with ESMTPS id eb1si21230861wib.34.2015.04.14.09.49.42
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Apr 2015 09:49:42 -0700 (PDT)
Received: by wgin8 with SMTP id n8so18785475wgi.0
        for <linux-mm@kvack.org>; Tue, 14 Apr 2015 09:49:42 -0700 (PDT)
Date: Tue, 14 Apr 2015 18:49:40 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 09/12] mm: page_alloc: private memory reserves for
 OOM-killing allocations
Message-ID: <20150414164939.GJ17160@dhcp22.suse.cz>
References: <1427264236-17249-1-git-send-email-hannes@cmpxchg.org>
 <1427264236-17249-10-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1427264236-17249-10-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Huang Ying <ying.huang@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>

[Sorry for the late reply]

On Wed 25-03-15 02:17:13, Johannes Weiner wrote:
> The OOM killer connects random tasks in the system with unknown
> dependencies between them, and the OOM victim might well get blocked
> behind the task that is trying to allocate.  That means that while
> allocations can issue OOM kills to improve the low memory situation,
> which generally frees more than they are going to take out, they can
> not rely on their *own* OOM kills to make forward progress for them.
> 
> Secondly, we want to avoid a racing allocation swooping in to steal
> the work of the OOM killing allocation, causing spurious allocation
> failures.  The one that put in the work must have priority - if its
> efforts are enough to serve both allocations that's fine, otherwise
> concurrent allocations should be forced to issue their own OOM kills.
> 
> Keep some pages below the min watermark reserved for OOM-killing
> allocations to protect them from blocking victims and concurrent
> allocations not pulling their weight.

Yes, this makes a lot of sense. I am just not sure I am happy about some
details.

[...]
> @@ -3274,6 +3290,7 @@ void show_free_areas(unsigned int filter)
>  		show_node(zone);
>  		printk("%s"
>  			" free:%lukB"
> +			" oom:%lukB"
>  			" min:%lukB"
>  			" low:%lukB"
>  			" high:%lukB"
> @@ -3306,6 +3323,7 @@ void show_free_areas(unsigned int filter)
>  			"\n",
>  			zone->name,
>  			K(zone_page_state(zone, NR_FREE_PAGES)),
> +			K(oom_wmark_pages(zone)),
>  			K(min_wmark_pages(zone)),
>  			K(low_wmark_pages(zone)),
>  			K(high_wmark_pages(zone)),

Do we really need to export the new watermark into the userspace?
How would it help user/admin? OK, maybe show_free_areas could be helpful
for oom reports but why to export it in /proc/zoneinfo which is done
further down?

> @@ -5747,17 +5765,18 @@ static void __setup_per_zone_wmarks(void)
>  
>  			min_pages = zone->managed_pages / 1024;
>  			min_pages = clamp(min_pages, SWAP_CLUSTER_MAX, 128UL);
> -			zone->watermark[WMARK_MIN] = min_pages;
> +			zone->watermark[WMARK_OOM] = min_pages;
>  		} else {
>  			/*
>  			 * If it's a lowmem zone, reserve a number of pages
>  			 * proportionate to the zone's size.
>  			 */
> -			zone->watermark[WMARK_MIN] = tmp;
> +			zone->watermark[WMARK_OOM] = tmp;
>  		}
>  
> -		zone->watermark[WMARK_LOW]  = min_wmark_pages(zone) + (tmp >> 2);
> -		zone->watermark[WMARK_HIGH] = min_wmark_pages(zone) + (tmp >> 1);
> +		zone->watermark[WMARK_MIN]  = oom_wmark_pages(zone) + (tmp >> 3);
> +		zone->watermark[WMARK_LOW]  = oom_wmark_pages(zone) + (tmp >> 2);
> +		zone->watermark[WMARK_HIGH] = oom_wmark_pages(zone) + (tmp >> 1);

This will basically elevate the min watermark, right? And that might lead
to subtle performance differences even when OOM killer is not invoked
because the direct reclaim will start sooner.
Shouldn't we rather give WMARK_OOM half of WMARK_MIN instead?

>  
>  		__mod_zone_page_state(zone, NR_ALLOC_BATCH,
>  			high_wmark_pages(zone) - low_wmark_pages(zone) -
> diff --git a/mm/vmstat.c b/mm/vmstat.c
> index 1fd0886a389f..a62f16ef524c 100644
> --- a/mm/vmstat.c
> +++ b/mm/vmstat.c
> @@ -1188,6 +1188,7 @@ static void zoneinfo_show_print(struct seq_file *m, pg_data_t *pgdat,
>  	seq_printf(m, "Node %d, zone %8s", pgdat->node_id, zone->name);
>  	seq_printf(m,
>  		   "\n  pages free     %lu"
> +		   "\n        oom      %lu"
>  		   "\n        min      %lu"
>  		   "\n        low      %lu"
>  		   "\n        high     %lu"
> @@ -1196,6 +1197,7 @@ static void zoneinfo_show_print(struct seq_file *m, pg_data_t *pgdat,
>  		   "\n        present  %lu"
>  		   "\n        managed  %lu",
>  		   zone_page_state(zone, NR_FREE_PAGES),
> +		   oom_wmark_pages(zone),
>  		   min_wmark_pages(zone),
>  		   low_wmark_pages(zone),
>  		   high_wmark_pages(zone),
> -- 
> 2.3.3
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
