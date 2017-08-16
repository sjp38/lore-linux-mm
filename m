Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0C3056B0292
	for <linux-mm@kvack.org>; Wed, 16 Aug 2017 00:51:40 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id p20so3221882pfj.2
        for <linux-mm@kvack.org>; Tue, 15 Aug 2017 21:51:40 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id z12si6307039pgo.510.2017.08.15.21.51.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Aug 2017 21:51:39 -0700 (PDT)
Date: Wed, 16 Aug 2017 12:53:21 +0800
From: Chen Yu <yu.c.chen@intel.com>
Subject: Re: [PATCH][RFC] PM / Hibernate: Feed NMI wathdog when creating
 snapshot
Message-ID: <20170816045321.GA12984@yu-desktop-1.sh.intel.com>
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
> Moreover why don't you need to touch_nmi_watchdog in the loop over all
> pfns in the zone (right above this loop)?
> --
After re-checking the code, I think we can simply disable the watchdog
temporarily, thus to avoid feeding the watchdog in the loop.
I'm sending another version based on this.
Thanks,
	Yu
> Michal Hocko
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
