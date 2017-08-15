Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3EC1F6B025F
	for <linux-mm@kvack.org>; Tue, 15 Aug 2017 08:41:23 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id z195so1436027wmz.8
        for <linux-mm@kvack.org>; Tue, 15 Aug 2017 05:41:23 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e8si724099wrc.304.2017.08.15.05.41.22
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 15 Aug 2017 05:41:22 -0700 (PDT)
Date: Tue, 15 Aug 2017 14:41:19 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH][RFC] PM / Hibernate: Feed NMI wathdog when creating
 snapshot
Message-ID: <20170815124119.GG29067@dhcp22.suse.cz>
References: <1502731156-24903-1-git-send-email-yu.c.chen@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1502731156-24903-1-git-send-email-yu.c.chen@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Yu <yu.c.chen@intel.com>
Cc: linux-mm@kvack.org, linux-pm@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, linux-kernel@vger.kernel.org, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Dan Williams <dan.j.williams@intel.com>

On Tue 15-08-17 01:19:16, Chen Yu wrote:
[...]
> @@ -2561,8 +2562,10 @@ void mark_free_pages(struct zone *zone)
>  			unsigned long i;
>  
>  			pfn = page_to_pfn(page);
> -			for (i = 0; i < (1UL << order); i++)
> +			for (i = 0; i < (1UL << order); i++) {
>  				swsusp_set_page_free(pfn_to_page(pfn + i));
> +				touch_nmi_watchdog();
> +			}

this is rather excessive. Why don't you simply call touch_nmi_watchdog
once per every 1000 pages? Or once per free_list entry?

Moreover why don't you need to touch_nmi_watchdog in the loop over all
pfns in the zone (right above this loop)?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
