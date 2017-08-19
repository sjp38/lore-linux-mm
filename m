Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 762D66B04A2
	for <linux-mm@kvack.org>; Sat, 19 Aug 2017 06:05:42 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id u191so40656172pgc.13
        for <linux-mm@kvack.org>; Sat, 19 Aug 2017 03:05:42 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id a33si5145732pli.715.2017.08.19.03.05.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 19 Aug 2017 03:05:41 -0700 (PDT)
Date: Sat, 19 Aug 2017 18:07:21 +0800
From: Chen Yu <yu.c.chen@intel.com>
Subject: Re: [PATCH][RFC v3] PM / Hibernate: Feed the wathdog when creating
 snapshot
Message-ID: <20170819100721.GA18859@yu-desktop-1.sh.intel.com>
References: <1502942674-25773-1-git-send-email-yu.c.chen@intel.com>
 <20170817112806.GD17781@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170817112806.GD17781@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Dan Williams <dan.j.williams@intel.com>, linux-kernel@vger.kernel.org

On Thu, Aug 17, 2017 at 01:28:06PM +0200, Michal Hocko wrote:
> On Thu 17-08-17 12:04:34, Chen Yu wrote:
> [...]
> >  #ifdef CONFIG_HIBERNATION
> >  
> > +/* Touch watchdog for every WD_INTERVAL_PAGE pages. */
> > +#define WD_INTERVAL_PAGE	1000
> 
> traversing 1000 pages should never take too much time so this could be
> overly aggressive. 100k pages could be acceptable as well. But I haven't
> measure that so I might be easily wrong here. So this is just my 2c
>
After checking the log:
[ 1144.690405] done (allocated 6590003 pages)
[ 1144.694971] PM: Allocated 26360012 kbytes in 19.89 seconds (1325.28 MB/s)

The default NMI timeout is 10 seconds AFAIK, in case the user might modify it to
1 second, a safe interval page could be 6590003/20 = 320k pages, but there
might be other machines running in a lower freq, 100k should be more robust.
I'll change it to 100k.
> > +
> >  void mark_free_pages(struct zone *zone)
> >  {
> >  	unsigned long pfn, max_zone_pfn;
> >  	unsigned long flags;
> > -	unsigned int order, t;
> > +	unsigned int order, t, page_num = 0;
> >  	struct page *page;
> >  
> >  	if (zone_is_empty(zone))
> > @@ -2548,6 +2552,9 @@ void mark_free_pages(struct zone *zone)
> >  		if (pfn_valid(pfn)) {
> >  			page = pfn_to_page(pfn);
> >  
> > +			if (!((page_num++) % WD_INTERVAL_PAGE))
> > +				touch_nmi_watchdog();
> > +
> >  			if (page_zone(page) != zone)
> >  				continue;
> >  
> > @@ -2555,14 +2562,19 @@ void mark_free_pages(struct zone *zone)
> >  				swsusp_unset_page_free(page);
> >  		}
> >  
> > +	page_num = 0;
> > +
> 
> this part doesn't make much sense to me. You are still inside the same
> IRQ disabled section. So why would you want to start counting from 0
> again. Not that this would make any difference in real life but the code
> is not logical
> 
Ok, will delete this.
> >  	for_each_migratetype_order(order, t) {
> >  		list_for_each_entry(page,
> >  				&zone->free_area[order].free_list[t], lru) {
> >  			unsigned long i;
> >  
> >  			pfn = page_to_pfn(page);
> > -			for (i = 0; i < (1UL << order); i++)
> > +			for (i = 0; i < (1UL << order); i++) {
> > +				if (!((page_num++) % WD_INTERVAL_PAGE))
> > +					touch_nmi_watchdog();
> >  				swsusp_set_page_free(pfn_to_page(pfn + i));
> > +			}
> >  		}
> >  	}
> >  	spin_unlock_irqrestore(&zone->lock, flags);
> > -- 
> > 2.7.4
> 
> -- 
> Michal Hocko
> SUSE Labs
Thanks,
	Yu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
