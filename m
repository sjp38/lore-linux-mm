Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id A9ADC6B0006
	for <linux-mm@kvack.org>; Wed, 14 Nov 2018 22:18:07 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id w185so42883501qka.9
        for <linux-mm@kvack.org>; Wed, 14 Nov 2018 19:18:07 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v127si12885113qkc.159.2018.11.14.19.18.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Nov 2018 19:18:06 -0800 (PST)
Date: Thu, 15 Nov 2018 11:18:01 +0800
From: Baoquan He <bhe@redhat.com>
Subject: Re: [PATCH] mm, memory_hotplug: check zone_movable in
 has_unmovable_pages
Message-ID: <20181115031801.GJ2653@MiWiFi-R3L-srv>
References: <20181106095524.14629-1-mhocko@kernel.org>
 <20181115031325.GI2653@MiWiFi-R3L-srv>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181115031325.GI2653@MiWiFi-R3L-srv>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oscar Salvador <OSalvador@suse.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On 11/15/18 at 11:13am, Baoquan He wrote:
> On 11/06/18 at 10:55am, Michal Hocko wrote:
> > From: Michal Hocko <mhocko@suse.com>
> > 
> > Page state checks are racy. Under a heavy memory workload (e.g. stress
> > -m 200 -t 2h) it is quite easy to hit a race window when the page is
> > allocated but its state is not fully populated yet. A debugging patch to
> 
> The original phenomenon is the value of /sys/devices/system/memory/memoryxxx/removable
> is 0 on several memory blocks of hotpluggable node. And almost on each
> hotpluggable node, there are one or several blocks which has this zero
> value of removable attribute. It caused the hot removing failure always.
> 
> And only cat /sys/devices/system/memory/memoryxxx/removable will trigger
> the call trace.
> 
> With this fix, all 'removable' of memory block on those hotpluggable
> nodes are '1', and hotplug can succeed.

Oh, by the way, hot removing/adding can always succeed when no memory
pressure is added.

The hot removing failure with high memory pressure has been raised in
another thread.

Thanks
Baoquan

> 
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
> 
> Fixes: 15c30bc09085 "mm, memory_hotplug: make has_unmovable_pages more robust")
> 
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
> >  		 * Hugepages are not in LRU lists, but they're movable.
> >  		 * We need not scan over tail pages bacause we don't
> > -- 
> > 2.19.1
> > 
