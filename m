Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5EC026B02C3
	for <linux-mm@kvack.org>; Thu, 17 Aug 2017 07:28:12 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id x43so12477708wrb.9
        for <linux-mm@kvack.org>; Thu, 17 Aug 2017 04:28:12 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k5si2452636wmg.248.2017.08.17.04.28.10
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 17 Aug 2017 04:28:10 -0700 (PDT)
Date: Thu, 17 Aug 2017 13:28:06 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH][RFC v3] PM / Hibernate: Feed the wathdog when creating
 snapshot
Message-ID: <20170817112806.GD17781@dhcp22.suse.cz>
References: <1502942674-25773-1-git-send-email-yu.c.chen@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1502942674-25773-1-git-send-email-yu.c.chen@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Yu <yu.c.chen@intel.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Dan Williams <dan.j.williams@intel.com>, linux-kernel@vger.kernel.org

On Thu 17-08-17 12:04:34, Chen Yu wrote:
[...]
>  #ifdef CONFIG_HIBERNATION
>  
> +/* Touch watchdog for every WD_INTERVAL_PAGE pages. */
> +#define WD_INTERVAL_PAGE	1000

traversing 1000 pages should never take too much time so this could be
overly aggressive. 100k pages could be acceptable as well. But I haven't
measure that so I might be easily wrong here. So this is just my 2c

> +
>  void mark_free_pages(struct zone *zone)
>  {
>  	unsigned long pfn, max_zone_pfn;
>  	unsigned long flags;
> -	unsigned int order, t;
> +	unsigned int order, t, page_num = 0;
>  	struct page *page;
>  
>  	if (zone_is_empty(zone))
> @@ -2548,6 +2552,9 @@ void mark_free_pages(struct zone *zone)
>  		if (pfn_valid(pfn)) {
>  			page = pfn_to_page(pfn);
>  
> +			if (!((page_num++) % WD_INTERVAL_PAGE))
> +				touch_nmi_watchdog();
> +
>  			if (page_zone(page) != zone)
>  				continue;
>  
> @@ -2555,14 +2562,19 @@ void mark_free_pages(struct zone *zone)
>  				swsusp_unset_page_free(page);
>  		}
>  
> +	page_num = 0;
> +

this part doesn't make much sense to me. You are still inside the same
IRQ disabled section. So why would you want to start counting from 0
again. Not that this would make any difference in real life but the code
is not logical

>  	for_each_migratetype_order(order, t) {
>  		list_for_each_entry(page,
>  				&zone->free_area[order].free_list[t], lru) {
>  			unsigned long i;
>  
>  			pfn = page_to_pfn(page);
> -			for (i = 0; i < (1UL << order); i++)
> +			for (i = 0; i < (1UL << order); i++) {
> +				if (!((page_num++) % WD_INTERVAL_PAGE))
> +					touch_nmi_watchdog();
>  				swsusp_set_page_free(pfn_to_page(pfn + i));
> +			}
>  		}
>  	}
>  	spin_unlock_irqrestore(&zone->lock, flags);
> -- 
> 2.7.4

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
