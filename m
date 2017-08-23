Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 69DED280757
	for <linux-mm@kvack.org>; Wed, 23 Aug 2017 03:14:58 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id b134so1394781wme.10
        for <linux-mm@kvack.org>; Wed, 23 Aug 2017 00:14:58 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 65si754081wrp.126.2017.08.23.00.14.54
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 23 Aug 2017 00:14:54 -0700 (PDT)
Date: Wed, 23 Aug 2017 09:14:52 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH][v2] PM / Hibernate: Feed the wathdog when creating
 snapshot
Message-ID: <20170823071452.GB2647@dhcp22.suse.cz>
References: <1503372002-13310-1-git-send-email-yu.c.chen@intel.com>
 <1595884.XH9dSsijkg@aspire.rjw.lan>
 <20170823034439.GA29634@yu-desktop-1.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170823034439.GA29634@yu-desktop-1.sh.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Yu <yu.c.chen@intel.com>
Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, Len Brown <lenb@kernel.org>, Dan Williams <dan.j.williams@intel.com>, linux-pm@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed 23-08-17 11:44:39, Chen Yu wrote:
> On Tue, Aug 22, 2017 at 02:55:39PM +0200, Rafael J. Wysocki wrote:
> > On Tuesday, August 22, 2017 5:20:02 AM CEST Chen Yu wrote:
[...]
> > >  void mark_free_pages(struct zone *zone)
> > >  {
> > > -	unsigned long pfn, max_zone_pfn;
> > > +	unsigned long pfn, max_zone_pfn, page_num = 0;
> > 
> > +	unsigned long pfn, max_zone_pfn, page_count = WD_PAGE_COUNT;
> > 
> > >  	unsigned long flags;
> > >  	unsigned int order, t;
> > >  	struct page *page;
> > > @@ -2552,6 +2559,9 @@ void mark_free_pages(struct zone *zone)
> > >  		if (pfn_valid(pfn)) {
> > >  			page = pfn_to_page(pfn);
> > >  
> > > +			if (!((page_num++) % WD_INTERVAL_PAGE))
> > > +				touch_nmi_watchdog();
> > > +
> > 
> > ->
> > 
> > 	if (!--page_count) {
> > 		touch_nmi_watchdog();
> > 		page_count = WD_PAGE_COUNT;
> > 	}
> >
> I guess this is to avoid the possible overflow if the page number is too large?

Even if the page_count overflown it wouldn't be a problem because of the
unsigned arithmetic. To be honest I find yours modulo based approach
easier to follow. Maybe it even compiles to a better code but I haven't
checked. Anyway one way or the other both ways are reasonable so
whatever Rafael (as the maintainer) prefers.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
