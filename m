Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 467586B025F
	for <linux-mm@kvack.org>; Tue, 15 Aug 2017 11:59:37 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id l2so23194394pgu.2
        for <linux-mm@kvack.org>; Tue, 15 Aug 2017 08:59:37 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id b77si5700913pfl.69.2017.08.15.08.59.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Aug 2017 08:59:32 -0700 (PDT)
Date: Wed, 16 Aug 2017 00:01:08 +0800
From: Chen Yu <yu.c.chen@intel.com>
Subject: Re: [PATCH][RFC] PM / Hibernate: Feed NMI wathdog when creating
 snapshot
Message-ID: <20170815160107.GA2541@yu-desktop-1.sh.intel.com>
References: <1502731156-24903-1-git-send-email-yu.c.chen@intel.com>
 <20170815124119.GG29067@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170815124119.GG29067@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-pm@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, linux-kernel@vger.kernel.org, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Dan Williams <dan.j.williams@intel.com>

Hi Michal,
On Tue, Aug 15, 2017 at 02:41:19PM +0200, Michal Hocko wrote:
> On Tue 15-08-17 01:19:16, Chen Yu wrote:
> [...]
> > @@ -2561,8 +2562,10 @@ void mark_free_pages(struct zone *zone)
> >  			unsigned long i;
> >  
> >  			pfn = page_to_pfn(page);
> > -			for (i = 0; i < (1UL << order); i++)
> > +			for (i = 0; i < (1UL << order); i++) {
> >  				swsusp_set_page_free(pfn_to_page(pfn + i));
> > +				touch_nmi_watchdog();
> > +			}
> 
> this is rather excessive. Why don't you simply call touch_nmi_watchdog
> once per every 1000 pages? Or once per free_list entry?
> 
Yes, this would be less costy, previously I thought that, since touch_nmi_watchdog()
would only update very limited amount of percpu variables and it is not costy when
comparing with the huge loop in radix tree searching by the swsusp_set_page_free(),
thus I put it in the deepest level in this loop, as this might be a safer place to avoid NMI.
> Moreover why don't you need to touch_nmi_watchdog in the loop over all
> pfns in the zone (right above this loop)?
As the NMI was triggered when checking the free_list rather than in the loop over
all pfns, it seems that the former has more possibility to catch a NMI if the
latter has already taken too much time. But yes, a safer way is to feed dog
in the latter too. I'll modify the code according to your suggestion.

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
