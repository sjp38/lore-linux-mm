Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id A06BD6B025E
	for <linux-mm@kvack.org>; Fri,  2 Dec 2016 05:04:13 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id i131so2127236wmf.3
        for <linux-mm@kvack.org>; Fri, 02 Dec 2016 02:04:13 -0800 (PST)
Received: from mail-wj0-f193.google.com (mail-wj0-f193.google.com. [209.85.210.193])
        by mx.google.com with ESMTPS id c74si2299379wme.33.2016.12.02.02.04.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Dec 2016 02:04:12 -0800 (PST)
Received: by mail-wj0-f193.google.com with SMTP id j10so2162643wjb.3
        for <linux-mm@kvack.org>; Fri, 02 Dec 2016 02:04:12 -0800 (PST)
Date: Fri, 2 Dec 2016 11:04:11 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2] mm, page_alloc: Keep pcp count and list contents in
 sync if struct page is corrupted
Message-ID: <20161202100411.GG6830@dhcp22.suse.cz>
References: <20161202002244.18453-1-mgorman@techsingularity.net>
 <20161202002244.18453-2-mgorman@techsingularity.net>
 <01d601d24c4e$dca6e190$95f4a4b0$@alibaba-inc.com>
 <55e1d640-72cf-d7b5-695b-87863ca7a843@suse.cz>
 <01f201d24c7e$ac04ed40$040ec7c0$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <01f201d24c7e$ac04ed40$040ec7c0$@alibaba-inc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <hillf.zj@alibaba-inc.com>
Cc: 'Vlastimil Babka' <vbabka@suse.cz>, 'Mel Gorman' <mgorman@techsingularity.net>, 'Andrew Morton' <akpm@linux-foundation.org>, 'Christoph Lameter' <cl@linux.com>, 'Johannes Weiner' <hannes@cmpxchg.org>, 'Jesper Dangaard Brouer' <brouer@redhat.com>, 'Linux-MM' <linux-mm@kvack.org>, 'Linux-Kernel' <linux-kernel@vger.kernel.org>

On Fri 02-12-16 17:30:07, Hillf Danton wrote:
[...]
> > >> @@ -2217,13 +2217,14 @@ static int rmqueue_bulk(struct zone *zone, unsigned int order,
> > >>  		else
> > >>  			list_add_tail(&page->lru, list);
> > >>  		list = &page->lru;
> > >> +		alloced++;
> > >>  		if (is_migrate_cma(get_pcppage_migratetype(page)))
> > >>  			__mod_zone_page_state(zone, NR_FREE_CMA_PAGES,
> > >>  					      -(1 << order));
> > >>  	}
> > >>  	__mod_zone_page_state(zone, NR_FREE_PAGES, -(i << order));
> > >
> > > Now i is a pure index, yes?
> > 
> > No, even if a page fails the check_pcp_refill() check and is not
> > "allocated", it is also no longer a free page, so it's correct to
> > subtract it from NR_FREE_PAGES.
> > 
> Yes, we can allocate free page   next time.

No we cannot. The page is gone from the free list. We have effectively
leaked it.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
