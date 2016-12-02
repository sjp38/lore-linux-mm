Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id DE0BC6B0038
	for <linux-mm@kvack.org>; Fri,  2 Dec 2016 06:02:45 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id he10so3697153wjc.6
        for <linux-mm@kvack.org>; Fri, 02 Dec 2016 03:02:45 -0800 (PST)
Received: from outbound-smtp03.blacknight.com (outbound-smtp03.blacknight.com. [81.17.249.16])
        by mx.google.com with ESMTPS id v130si2419120wmf.126.2016.12.02.03.02.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 02 Dec 2016 03:02:44 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp03.blacknight.com (Postfix) with ESMTPS id CCE672F8079
	for <linux-mm@kvack.org>; Fri,  2 Dec 2016 11:02:43 +0000 (UTC)
Date: Fri, 2 Dec 2016 11:02:42 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 1/2] mm, page_alloc: Keep pcp count and list contents in
 sync if struct page is corrupted
Message-ID: <20161202110242.tjy7fj55naubx6bk@techsingularity.net>
References: <20161202002244.18453-1-mgorman@techsingularity.net>
 <20161202002244.18453-2-mgorman@techsingularity.net>
 <01d601d24c4e$dca6e190$95f4a4b0$@alibaba-inc.com>
 <55e1d640-72cf-d7b5-695b-87863ca7a843@suse.cz>
 <01f201d24c7e$ac04ed40$040ec7c0$@alibaba-inc.com>
 <20161202100411.GG6830@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20161202100411.GG6830@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Hillf Danton <hillf.zj@alibaba-inc.com>, 'Vlastimil Babka' <vbabka@suse.cz>, 'Andrew Morton' <akpm@linux-foundation.org>, 'Christoph Lameter' <cl@linux.com>, 'Johannes Weiner' <hannes@cmpxchg.org>, 'Jesper Dangaard Brouer' <brouer@redhat.com>, 'Linux-MM' <linux-mm@kvack.org>, 'Linux-Kernel' <linux-kernel@vger.kernel.org>

On Fri, Dec 02, 2016 at 11:04:11AM +0100, Michal Hocko wrote:
> On Fri 02-12-16 17:30:07, Hillf Danton wrote:
> [...]
> > > >> @@ -2217,13 +2217,14 @@ static int rmqueue_bulk(struct zone *zone, unsigned int order,
> > > >>  		else
> > > >>  			list_add_tail(&page->lru, list);
> > > >>  		list = &page->lru;
> > > >> +		alloced++;
> > > >>  		if (is_migrate_cma(get_pcppage_migratetype(page)))
> > > >>  			__mod_zone_page_state(zone, NR_FREE_CMA_PAGES,
> > > >>  					      -(1 << order));
> > > >>  	}
> > > >>  	__mod_zone_page_state(zone, NR_FREE_PAGES, -(i << order));
> > > >
> > > > Now i is a pure index, yes?
> > > 
> > > No, even if a page fails the check_pcp_refill() check and is not
> > > "allocated", it is also no longer a free page, so it's correct to
> > > subtract it from NR_FREE_PAGES.
> > > 
> > Yes, we can allocate free page   next time.
> 
> No we cannot. The page is gone from the free list. We have effectively
> leaked it.

And deliberately so. It's in an unknown state, possibly due to memory
corruption or a use-after free bug. The machine can continue limping on
with warnings in the kernel log but the VM stops going near the page
itself as much as possible.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
