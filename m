Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id D5F746B0562
	for <linux-mm@kvack.org>; Fri, 18 May 2018 00:01:07 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id n26-v6so2405996pgd.2
        for <linux-mm@kvack.org>; Thu, 17 May 2018 21:01:07 -0700 (PDT)
Received: from lgeamrelo11.lge.com (lgeamrelo11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id e11-v6si5356911pgu.459.2018.05.17.21.01.05
        for <linux-mm@kvack.org>;
        Thu, 17 May 2018 21:01:06 -0700 (PDT)
Date: Fri, 18 May 2018 13:01:04 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH] Revert "mm/cma: manage the memory of the CMA area by
 using the ZONE_MOVABLE"
Message-ID: <20180518040104.GA17433@js1304-desktop>
References: <20180517125959.8095-1-ville.syrjala@linux.intel.com>
 <20180517132109.GU12670@dhcp22.suse.cz>
 <20180517133629.GH23723@intel.com>
 <20180517135832.GI23723@intel.com>
 <20180517164947.GV12670@dhcp22.suse.cz>
 <20180517170816.GW12670@dhcp22.suse.cz>
 <ccbe3eda-0880-1d59-2204-6bd4b317a4fe@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <ccbe3eda-0880-1d59-2204-6bd4b317a4fe@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>
Cc: Michal Hocko <mhocko@kernel.org>, Ville =?iso-8859-1?Q?Syrj=E4l=E4?= <ville.syrjala@linux.intel.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Tony Lindgren <tony@atomide.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Laura Abbott <lauraa@codeaurora.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Mel Gorman <mgorman@techsingularity.net>, Michal Nazarewicz <mina86@mina86.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Russell King <linux@armlinux.org.uk>, Will Deacon <will.deacon@arm.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, May 17, 2018 at 10:53:32AM -0700, Laura Abbott wrote:
> On 05/17/2018 10:08 AM, Michal Hocko wrote:
> >On Thu 17-05-18 18:49:47, Michal Hocko wrote:
> >>On Thu 17-05-18 16:58:32, Ville Syrjala wrote:
> >>>On Thu, May 17, 2018 at 04:36:29PM +0300, Ville Syrjala wrote:
> >>>>On Thu, May 17, 2018 at 03:21:09PM +0200, Michal Hocko wrote:
> >>>>>On Thu 17-05-18 15:59:59, Ville Syrjala wrote:
> >>>>>>From: Ville Syrjala <ville.syrjala@linux.intel.com>
> >>>>>>
> >>>>>>This reverts commit bad8c6c0b1144694ecb0bc5629ede9b8b578b86e.
> >>>>>>
> >>>>>>Make x86 with HIGHMEM=y and CMA=y boot again.
> >>>>>
> >>>>>Is there any bug report with some more details? It is much more
> >>>>>preferable to fix the issue rather than to revert the whole thing
> >>>>>right away.
> >>>>
> >>>>The machine I have in front of me right now didn't give me anything.
> >>>>Black screen, and netconsole was silent. No serial port on this
> >>>>machine unfortunately.
> >>>
> >>>Booted on another machine with serial:
> >>
> >>Could you provide your .config please?
> >>
> >>[...]
> >>>[    0.000000] cma: Reserved 4 MiB at 0x0000000037000000
> >>[...]
> >>>[    0.000000] BUG: Bad page state in process swapper  pfn:377fe
> >>>[    0.000000] page:f53effc0 count:0 mapcount:-127 mapping:00000000 index:0x0
> >>
> >>OK, so this looks the be the source of the problem. -128 would be a
> >>buddy page but I do not see anything that would set the counter to -127
> >>and the real map count updates shouldn't really happen that early.
> >>
> >>Maybe CONFIG_DEBUG_VM and CONFIG_DEBUG_HIGHMEM will tell us more.
> >
> >Looking closer, I _think_ that the bug is in set_highmem_pages_init->is_highmem
> >and zone_movable_is_highmem might force CMA pages in the zone movable to
> >be initialized as highmem. And that sounds supicious to me. Joonsoo?
> >
> 
> For a point of reference, arm with this configuration doesn't hit this bug
> because highmem pages are freed via the memblock interface only instead
> of iterating through each zone. It looks like the x86 highmem code
> assumes only a single highmem zone and/or it's disjoint?

Good point! Reason of the crash is that the span of MOVABLE_ZONE is
extended to whole node span for future CMA initialization, and,
normal memory is wrongly freed here.

Here goes the fix. Ville, Could you test below patch?
I re-generated the issue on my side and this patch fixed it.

Thanks.

------------>8-------------
