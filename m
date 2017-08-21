Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id AB4A928042F
	for <linux-mm@kvack.org>; Mon, 21 Aug 2017 16:26:04 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id p67so11000161wrb.10
        for <linux-mm@kvack.org>; Mon, 21 Aug 2017 13:26:04 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 73si4873454wmo.272.2017.08.21.13.26.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Aug 2017 13:26:03 -0700 (PDT)
Date: Mon, 21 Aug 2017 13:26:00 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] PM / Hibernate: Feed the wathdog when creating snapshot
Message-Id: <20170821132600.c8a509bcacce123e3f51d989@linux-foundation.org>
In-Reply-To: <1503328098-5120-1-git-send-email-yu.c.chen@intel.com>
References: <1503328098-5120-1-git-send-email-yu.c.chen@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Yu <yu.c.chen@intel.com>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Dan Williams <dan.j.williams@intel.com>, linux-pm@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon, 21 Aug 2017 23:08:18 +0800 Chen Yu <yu.c.chen@intel.com> wrote:

> There is a problem that when counting the pages for creating
> the hibernation snapshot will take significant amount of
> time, especially on system with large memory. Since the counting
> job is performed with irq disabled, this might lead to NMI lockup.
> The following warning were found on a system with 1.5TB DRAM:
> 
> ...
> 
> It has taken nearly 20 seconds(2.10GHz CPU) thus the NMI lockup
> was triggered. In case the timeout of the NMI watch dog has been
> set to 1 second, a safe interval should be 6590003/20 = 320k pages
> in theory. However there might also be some platforms running at a
> lower frequency, so feed the watchdog every 100k pages.
> 
> ...
>
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2531,9 +2532,12 @@ void drain_all_pages(struct zone *zone)
>  
>  #ifdef CONFIG_HIBERNATION
>  
> +/* Touch watchdog for every WD_INTERVAL_PAGE pages. */
> +#define WD_INTERVAL_PAGE	(100*1024)
> +
>  void mark_free_pages(struct zone *zone)
>  {
> -	unsigned long pfn, max_zone_pfn;
> +	unsigned long pfn, max_zone_pfn, page_num = 0;
>  	unsigned long flags;
>  	unsigned int order, t;
>  	struct page *page;
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
> @@ -2561,8 +2568,11 @@ void mark_free_pages(struct zone *zone)
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

hm, is it really worth all the WD_INTERVAL_PAGE stuff? 
touch_nmi_watchdog() is pretty efficient and calling it once-per-page
may not have a measurable effect.

And if we're really concerned about the performance impact it would be
better to make WD_INTERVAL_PAGE a power of 2 (128*1024?) to avoid the
modulus operation.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
