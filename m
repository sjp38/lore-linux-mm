Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 869EE440905
	for <linux-mm@kvack.org>; Fri, 14 Jul 2017 07:35:15 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id t3so8801540wme.9
        for <linux-mm@kvack.org>; Fri, 14 Jul 2017 04:35:15 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h84si2031675wme.104.2017.07.14.04.35.13
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 14 Jul 2017 04:35:14 -0700 (PDT)
Date: Fri, 14 Jul 2017 13:35:08 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: "mm: use early_pfn_to_nid in page_ext_init" broken on some
 configurations?
Message-ID: <20170714113508.GH2618@dhcp22.suse.cz>
References: <20170630141847.GN22917@dhcp22.suse.cz>
 <54336b9a-6dc7-890f-1900-c4188fb6cf1a@suse.cz>
 <20170704051713.GB28589@js1304-desktop>
 <31ca76ee-fd1a-236b-2b9d-fa205202c1ac@suse.cz>
 <20170714091304.GC2618@dhcp22.suse.cz>
 <18f28347-af10-0726-5a62-0dd1afdbd2a9@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <18f28347-af10-0726-5a62-0dd1afdbd2a9@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Joonsoo Kim <js1304@gmail.com>, Yang Shi <yang.shi@linaro.org>, Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Fri 14-07-17 11:34:31, Vlastimil Babka wrote:
> On 07/14/2017 11:13 AM, Michal Hocko wrote:
> > On Fri 07-07-17 14:00:03, Vlastimil Babka wrote:
> >> On 07/04/2017 07:17 AM, Joonsoo Kim wrote:
> >>>>
> >>>> Still, backporting b8f1a75d61d8 fixes this:
> >>>>
> >>>> [    1.538379] allocated 738197504 bytes of page_ext
> >>>> [    1.539340] Node 0, zone      DMA: page owner found early allocated 0 pages
> >>>> [    1.540179] Node 0, zone    DMA32: page owner found early allocated 33 pages
> >>>> [    1.611173] Node 0, zone   Normal: page owner found early allocated 96755 pages
> >>>> [    1.683167] Node 1, zone   Normal: page owner found early allocated 96575 pages
> >>>>
> >>>> No panic, notice how it allocated more for page_ext, and found smaller number of
> >>>> early allocated pages.
> >>>>
> >>>> Now backporting fe53ca54270a on top:
> >>>>
> >>>> [    0.000000] allocated 738197504 bytes of page_ext
> >>>> [    0.000000] Node 0, zone      DMA: page owner found early allocated 0 pages
> >>>> [    0.000000] Node 0, zone    DMA32: page owner found early allocated 33 pages
> >>>> [    0.000000] Node 0, zone   Normal: page owner found early allocated 2842622 pages
> >>>> [    0.000000] Node 1, zone   Normal: page owner found early allocated 3694362 pages
> >>>>
> >>>> Again no panic, and same amount of page_ext usage. But the "early allocated" numbers
> >>>> seem bogus to me. I think it's because init_pages_in_zone() is running and inspecting
> >>>> struct pages that have not been yet initialized. It doesn't end up crashing, but
> >>>> still doesn't seem correct?
> >>>
> >>> Numbers looks sane to me. fe53ca54270a makes init_pages_in_zone()
> >>> called before page_alloc_init_late(). So, there would be many
> >>> uninitialized pages with PageReserved(). Page owner regarded these
> >>> PageReserved() page as allocated page.
> >>
> >> That seems incorrect for two reasons:
> >> - init_pages_in_zone() actually skips PageReserved() pages
> >> - the pages don't have PageReserved() flag, until the deferred struct page init
> >> thread processes them via deferred_init_memmap() -> __init_single_page() AFAICS
> >>
> >> Now I've found out why upstream reports much less early allocated pages than our
> >> kernel. We're missing 9d43f5aec950 ("mm/page_owner: add zone range overlapping
> >> check") which adds a "page_zone(page) != zone" check. I think this only works
> >> because the pages are not initialized and thus have no nid/zone links. Probably
> >> page_zone() only doesn't break because it's all zeroed. I don't think it's safe
> >> to rely on this?
> > 
> > Yes, if anything PageReserved should be checked before the zone check.
> 
> That wouldn't change anything, because we skip PageReserved and it's not
> set.

I thought they were still marked reserved from the bootmem allocator I
would have to go through the initialization code again to be sure.

> Perhaps we could skip pages that have the raw page flags value
> zero, but then a) we should make sure that the allocation of the struct
> page array zeroes the range, and b) the first modification of struct
> page in the initialization is setting the PageReserved flag.

I would rather not depend on the page state. There are plans to not
initialize the struct page (even to 0 during memmap init) until
__init_single_page.

Either the page is fully initialized or we are touching invalid pfn
range. end_pfn = pfn + zone->spanned_pages but I guess we should in fact
consider first_deferred_pfn as well (calculate_node_totalpages is not
deffered initialization aware).
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
