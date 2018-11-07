Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 457C06B04C3
	for <linux-mm@kvack.org>; Wed,  7 Nov 2018 02:35:54 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id s17-v6so13515999pga.9
        for <linux-mm@kvack.org>; Tue, 06 Nov 2018 23:35:54 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 1-v6si45464240plp.114.2018.11.06.23.35.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Nov 2018 23:35:52 -0800 (PST)
Date: Wed, 7 Nov 2018 08:35:48 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, memory_hotplug: check zone_movable in
 has_unmovable_pages
Message-ID: <20181107073548.GU27423@dhcp22.suse.cz>
References: <20181106095524.14629-1-mhocko@kernel.org>
 <20181106203518.GC9042@350D>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181106203518.GC9042@350D>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Baoquan He <bhe@redhat.com>, Oscar Salvador <OSalvador@suse.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Wed 07-11-18 07:35:18, Balbir Singh wrote:
> On Tue, Nov 06, 2018 at 10:55:24AM +0100, Michal Hocko wrote:
> > From: Michal Hocko <mhocko@suse.com>
> > 
> > Page state checks are racy. Under a heavy memory workload (e.g. stress
> > -m 200 -t 2h) it is quite easy to hit a race window when the page is
> > allocated but its state is not fully populated yet. A debugging patch to
> > dump the struct page state shows
> > : [  476.575516] has_unmovable_pages: pfn:0x10dfec00, found:0x1, count:0x0
> > : [  476.582103] page:ffffea0437fb0000 count:1 mapcount:1 mapping:ffff880e05239841 index:0x7f26e5000 compound_mapcount: 1
> > : [  476.592645] flags: 0x5fffffc0090034(uptodate|lru|active|head|swapbacked)
> > 
> > Note that the state has been checked for both PageLRU and PageSwapBacked
> > already. Closing this race completely would require some sort of retry
> > logic. This can be tricky and error prone (think of potential endless
> > or long taking loops).
> > 
> > Workaround this problem for movable zones at least. Such a zone should
> > only contain movable pages. 15c30bc09085 ("mm, memory_hotplug: make
> > has_unmovable_pages more robust") has told us that this is not strictly
> > true though. Bootmem pages should be marked reserved though so we can
> > move the original check after the PageReserved check. Pages from other
> > zones are still prone to races but we even do not pretend that memory
> > hotremove works for those so pre-mature failure doesn't hurt that much.
> > 
> > Reported-and-tested-by: Baoquan He <bhe@redhat.com>
> > Acked-by: Baoquan He <bhe@redhat.com>
> > Fixes: "mm, memory_hotplug: make has_unmovable_pages more robust")
> > Signed-off-by: Michal Hocko <mhocko@suse.com>
> > ---
> >
> > Hi,
> > this has been reported [1] and we have tried multiple things to address
> > the issue. The only reliable way was to reintroduce the movable zone
> > check into has_unmovable_pages. This time it should be safe also for
> > the bug originally fixed by 15c30bc09085.
> > 
> > [1] http://lkml.kernel.org/r/20181101091055.GA15166@MiWiFi-R3L-srv
> >  mm/page_alloc.c | 8 ++++++++
> >  1 file changed, 8 insertions(+)
> > 
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 863d46da6586..c6d900ee4982 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -7788,6 +7788,14 @@ bool has_unmovable_pages(struct zone *zone, struct page *page, int count,
> >  		if (PageReserved(page))
> >  			goto unmovable;
> >  
> > +		/*
> > +		 * If the zone is movable and we have ruled out all reserved
> > +		 * pages then it should be reasonably safe to assume the rest
> > +		 * is movable.
> > +		 */
> > +		if (zone_idx(zone) == ZONE_MOVABLE)
> > +			continue;
> > +
> >  		/*
> 
> 
> There is a WARN_ON() in case of failure at the end of the routine,
> is that triggered when we hit the bug? If we're adding this patch,
> the WARN_ON needs to go as well.

No the warning should stay in case we encounter reserved pages in zone
movable.

> The check seems to be quite aggressive and in a loop that iterates
> pages, but has nothing to do with the page, did you mean to make
> the check
> 
> zone_idx(page_zone(page)) == ZONE_MOVABLE

Does it make any difference? Can we actually encounter a page from a
different zone here?

> it also skips all checks for pinned pages and other checks

Yes, this is intentional and the comment tries to explain why. I wish we
could be add a more specific checks for movable pages - e.g. detect long
term pins that would prevent migration - but we do not have any facility
for that. Please note that the worst case of a false positive is a
repeated migration failure and user has a way to break out of migration
by a signal.

-- 
Michal Hocko
SUSE Labs
