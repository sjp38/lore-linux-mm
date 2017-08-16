Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 39AF06B025F
	for <linux-mm@kvack.org>; Wed, 16 Aug 2017 08:34:07 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id 30so5328279wrk.7
        for <linux-mm@kvack.org>; Wed, 16 Aug 2017 05:34:07 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u107si592517wrc.554.2017.08.16.05.34.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 16 Aug 2017 05:34:05 -0700 (PDT)
Date: Wed, 16 Aug 2017 14:33:59 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH][RFC v2] PM / Hibernate: Disable wathdog when creating
 snapshot
Message-ID: <20170816123359.GC32161@dhcp22.suse.cz>
References: <1502859218-13099-1-git-send-email-yu.c.chen@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1502859218-13099-1-git-send-email-yu.c.chen@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Yu <yu.c.chen@intel.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Dan Williams <dan.j.williams@intel.com>, linux-pm@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed 16-08-17 12:53:38, Chen Yu wrote:
[...]
> @@ -2537,10 +2538,15 @@ void mark_free_pages(struct zone *zone)
>  	unsigned long flags;
>  	unsigned int order, t;
>  	struct page *page;
> +	bool wd_suspended;
>  
>  	if (zone_is_empty(zone))
>  		return;
>  
> +	wd_suspended = lockup_detector_suspend() ? false : true;
> +	if (!wd_suspended)
> +		pr_warn_once("Failed to disable lockup detector during hibernation.\n");
> +
>  	spin_lock_irqsave(&zone->lock, flags);
>  
>  	max_zone_pfn = zone_end_pfn(zone);

I am not maintainer of this code so I am not very familiar with the full
context of this function but lockup_detector_suspend is just too heavy
for the purpose you are trying to achive. Really why don't you just
poke the watchdog every N pages?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
