Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2A17F6B0038
	for <linux-mm@kvack.org>; Tue, 18 Oct 2016 09:00:44 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id f134so11214108lfg.6
        for <linux-mm@kvack.org>; Tue, 18 Oct 2016 06:00:44 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 79si22631996lfr.225.2016.10.18.06.00.41
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 18 Oct 2016 06:00:42 -0700 (PDT)
Subject: Re: [PATCH] mm: pagealloc: fix continued prints in show_free_areas
References: <1476790457-7776-1-git-send-email-mark.rutland@arm.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <d92624ee-76f2-5e42-8318-94ddf0f22bbf@suse.cz>
Date: Tue, 18 Oct 2016 15:00:40 +0200
MIME-Version: 1.0
In-Reply-To: <1476790457-7776-1-git-send-email-mark.rutland@arm.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Rutland <mark.rutland@arm.com>, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, linux-mm@kvack.org, Joe Perches <joe@perches.com>, Michal Hocko <mhocko@kernel.org>

On 10/18/2016 01:34 PM, Mark Rutland wrote:
> Recently, printk was reworked in commit:
>
>   4bcc595ccd80decb ("printk: reinstate KERN_CONT for printing continuation
>   lines")
>
> As of this commit, printk calls missing KERN_CONT will have a linebreak
> inserted implicitly.
>
> In show_free_areas, we miss KERN_CONT in a few cases, and as a result
> prints are unexpectedly split over a number of lines, making them
> difficult to read (in v4.9-rc1).
>
> This patch uses pr_cont (with uits implicit KERN_CONT) to mark all
> continued prints that occur withing a show_free_areas() call. Note that
> show_migration_types() is only called by show_free_areas().
> Depending on CONFIG_NUMA a printk after show_node() may or may not be a
> continuation, but follows an explicit newline if not (and thus marking
> it as a continuation should not be harmful).

I think this was already fixed:

http://marc.info/?l=linux-mm&m=147623910031630&w=2

> Signed-off-by: Mark Rutland <mark.rutland@arm.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Cc: Mel Gorman <mgorman@techsingularity.net>
> Cc: linux-mm@kvack.org
> Cc: linux-kernel@vger.kernel.org
> ---
>  mm/page_alloc.c | 14 +++++++-------
>  1 file changed, 7 insertions(+), 7 deletions(-)
>
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 2b3bf67..833f271 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -4224,7 +4224,7 @@ static void show_migration_types(unsigned char type)
>  	}
>
>  	*p = '\0';
> -	printk("(%s) ", tmp);
> +	pr_cont("(%s) ", tmp);
>  }
>
>  /*
> @@ -4335,7 +4335,7 @@ void show_free_areas(unsigned int filter)
>  			free_pcp += per_cpu_ptr(zone->pageset, cpu)->pcp.count;
>
>  		show_node(zone);
> -		printk("%s"
> +		pr_cont("%s"
>  			" free:%lukB"
>  			" min:%lukB"
>  			" low:%lukB"
> @@ -4382,8 +4382,8 @@ void show_free_areas(unsigned int filter)
>  			K(zone_page_state(zone, NR_FREE_CMA_PAGES)));
>  		printk("lowmem_reserve[]:");
>  		for (i = 0; i < MAX_NR_ZONES; i++)
> -			printk(" %ld", zone->lowmem_reserve[i]);
> -		printk("\n");
> +			pr_cont(" %ld", zone->lowmem_reserve[i]);
> +		pr_cont("\n");
>  	}
>
>  	for_each_populated_zone(zone) {
> @@ -4394,7 +4394,7 @@ void show_free_areas(unsigned int filter)
>  		if (skip_free_areas_node(filter, zone_to_nid(zone)))
>  			continue;
>  		show_node(zone);
> -		printk("%s: ", zone->name);
> +		pr_cont("%s: ", zone->name);
>
>  		spin_lock_irqsave(&zone->lock, flags);
>  		for (order = 0; order < MAX_ORDER; order++) {
> @@ -4412,11 +4412,11 @@ void show_free_areas(unsigned int filter)
>  		}
>  		spin_unlock_irqrestore(&zone->lock, flags);
>  		for (order = 0; order < MAX_ORDER; order++) {
> -			printk("%lu*%lukB ", nr[order], K(1UL) << order);
> +			pr_cont("%lu*%lukB ", nr[order], K(1UL) << order);
>  			if (nr[order])
>  				show_migration_types(types[order]);
>  		}
> -		printk("= %lukB\n", K(total));
> +		pr_cont("= %lukB\n", K(total));
>  	}
>
>  	hugetlb_show_meminfo();
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
