Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4D1C26B03AC
	for <linux-mm@kvack.org>; Thu, 13 Apr 2017 07:56:25 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id v52so6066818wrb.14
        for <linux-mm@kvack.org>; Thu, 13 Apr 2017 04:56:25 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x133si12819082wmx.26.2017.04.13.04.56.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 13 Apr 2017 04:56:23 -0700 (PDT)
Date: Thu, 13 Apr 2017 13:56:15 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v7 0/7] Introduce ZONE_CMA
Message-ID: <20170413115615.GB11795@dhcp22.suse.cz>
References: <1491880640-9944-1-git-send-email-iamjoonsoo.kim@lge.com>
 <20170411181519.GC21171@dhcp22.suse.cz>
 <20170412013503.GA8448@js1304-desktop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170412013503.GA8448@js1304-desktop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, mgorman@techsingularity.net, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, Russell King <linux@armlinux.org.uk>, Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@lge.com

On Wed 12-04-17 10:35:06, Joonsoo Kim wrote:
> On Tue, Apr 11, 2017 at 08:15:20PM +0200, Michal Hocko wrote:
> > Hi,
> > I didn't get to read though patches yet but the cover letter didn't
> > really help me to understand the basic concepts to have a good starting
> > point before diving into implementation details. It contains a lot of
> > history remarks which is not bad but IMHO too excessive here. I would
> > appreciate the following information (some of that is already provided
> > in the cover but could benefit from some rewording/text reorganization).
> > 
> > - what is ZONE_CMA and how it is configured (from admin POV)
> > - how does ZONE_CMA compare to other zones
> > - who is allowed to allocate from this zone and what are the
> >   guarantees/requirements for successful allocation
> > - how does the zone compare to a preallocate allocation pool
> > - how is ZONE_CMA balanced/reclaimed due to internal memory pressure
> >   (from CMA users)
> > - is this zone reclaimable for the global memory reclaim
> > - why this was/is controversial
> 
> Hello,
> 
> I hope that following summary helps you to understand this patchset.
> I skip some basic things about CMA. I will attach this description to
> the cover-letter if re-spin is needed.

I believe that sorting out these questions is more important than what
you have in the current cover letter. Andrew tends to fold the cover
into the first patch so I think you should update.

> 2. How does ZONE_CMA compare to other zones
> 
> ZONE_CMA is conceptually the same with ZONE_MOVABLE. There is a software
> constraint to guarantee the success of future allocation request from
> the device. If the device requests the specific range of the memory in CMA
> area at the runtime, page that allocated by MM will be migrated to
> the other page and it will be returned to the device. To guarantee it,
> ZONE_CMA only takes the allocation request with GFP_MOVABLE.

The immediate follow up question is. Why cannot we reuse ZONE_MOVABLE
for that purpose?

> The other important point about ZONE_CMA is that span of ZONE_CMA would be
> overlapped with the other zone. This is not new to MM subsystem and
> MM subsystem has enough logic to handle such situation
> so there would be no problem.

I am not really sure this is actually true. Zones are disjoint from the
early beginning. I remember that we had something like numa nodes
interleaving but that is such a rare configuration that I wouldn't be
surprised if it wasn't very well tested and actually broken in some
subtle ways.

There are many page_zone(page) != zone checks sprinkled in the code but
I do not see anything consistent there. Similarly pageblock_pfn_to_page
is only used by compaction but there are other pfn walkers which do
ad-hoc checking. I was staring into that code these days due to my
hotplug patches.

That being said, I think that interleaving zones are an interesting
concept but I would be rather nervous to consider this as working
currently without a deeper review.

> Other things are completely the same with other zones. For MM POV, there is
> no difference in allocation process except that it only takes
> GFP_MOVABLE request. In reclaim, pages that are allocated by MM will
> be reclaimed by the same policy of the MM. So, no difference.

OK, so essentially this is yet another "highmem" zone. We already know
that only GFP_MOVABLE are allowed to fallback to ZONE_CMA but do CMA
allocations fallback to other zones and punch new holes? In which zone
order?

> This 'no difference' is a strong point of this approach. ZONE_CMA is
> naturally handled by MM subsystem unlike as before (special handling is
> required for MIGRATE_CMA).
> 
> 3. Controversial Point
> 
> Major concern from Mel is that zone concept is abused. ZONE is originally
> introduced to solve some issues due to H/W addressing limitation.

Yes, very much agreed on that. You basically want to punch holes into
other zones to guarantee an allocation progress. Marking those wholes
with special migrate type sounds quite natural but I will have to study
the current code some more to see whether issues you mention are
inherently unfixable. This might very well turn out to be the case.

> However, from the age of ZONE_MOVABLE, ZONE is used to solve the issues
> due to S/W limitation.

copying ZONE_MOVABLE pattern doesn't sound all that great to me to be
honest.

> This S/W limitation causes highmem/lowmem problem
> that is some of memory cannot be usable for kernel memory and LRU ordering
> would be broken easily. My major objection to this point is that
> this problem isn't related to implementation detail like as ZONE.

yes, agreement on that.

> Problems just comes from S/W limitation that we cannot use this memory
> for kernel memory to guarantee offlining the memory (ZONE_MOVABLE) or
> allocation from the device (ZONE_CMA) in the future. See PART 1 for
> more information.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
