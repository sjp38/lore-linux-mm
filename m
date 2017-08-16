Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0F10E6B025F
	for <linux-mm@kvack.org>; Wed, 16 Aug 2017 10:31:21 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id f23so50351661pgn.15
        for <linux-mm@kvack.org>; Wed, 16 Aug 2017 07:31:21 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id r70si620568pfe.5.2017.08.16.07.31.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Aug 2017 07:31:19 -0700 (PDT)
Date: Wed, 16 Aug 2017 22:33:02 +0800
From: Chen Yu <yu.c.chen@intel.com>
Subject: Re: [PATCH][RFC v2] PM / Hibernate: Disable wathdog when creating
 snapshot
Message-ID: <20170816143301.GA19921@yu-desktop-1.sh.intel.com>
References: <1502859218-13099-1-git-send-email-yu.c.chen@intel.com>
 <20170816123359.GC32161@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170816123359.GC32161@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Dan Williams <dan.j.williams@intel.com>, linux-pm@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, Aug 16, 2017 at 02:33:59PM +0200, Michal Hocko wrote:
> On Wed 16-08-17 12:53:38, Chen Yu wrote:
> [...]
> > @@ -2537,10 +2538,15 @@ void mark_free_pages(struct zone *zone)
> >  	unsigned long flags;
> >  	unsigned int order, t;
> >  	struct page *page;
> > +	bool wd_suspended;
> >  
> >  	if (zone_is_empty(zone))
> >  		return;
> >  
> > +	wd_suspended = lockup_detector_suspend() ? false : true;
> > +	if (!wd_suspended)
> > +		pr_warn_once("Failed to disable lockup detector during hibernation.\n");
> > +
> >  	spin_lock_irqsave(&zone->lock, flags);
> >  
> >  	max_zone_pfn = zone_end_pfn(zone);
> 
> I am not maintainer of this code so I am not very familiar with the full
> context of this function but lockup_detector_suspend is just too heavy
> for the purpose you are trying to achive. Really why don't you just
> poke the watchdog every N pages?
OK, I'll send another version.
Thanks,
	Yu
> -- 
> Michal Hocko
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
