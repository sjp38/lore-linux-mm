Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 594546B0038
	for <linux-mm@kvack.org>; Tue, 11 Apr 2017 21:35:18 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id c16so7563014pfl.21
        for <linux-mm@kvack.org>; Tue, 11 Apr 2017 18:35:18 -0700 (PDT)
Received: from mail-pg0-x243.google.com (mail-pg0-x243.google.com. [2607:f8b0:400e:c05::243])
        by mx.google.com with ESMTPS id 9si15056926pfq.177.2017.04.11.18.35.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Apr 2017 18:35:17 -0700 (PDT)
Received: by mail-pg0-x243.google.com with SMTP id o123so2383994pga.1
        for <linux-mm@kvack.org>; Tue, 11 Apr 2017 18:35:17 -0700 (PDT)
Date: Wed, 12 Apr 2017 10:35:06 +0900
From: Joonsoo Kim <js1304@gmail.com>
Subject: Re: [PATCH v7 0/7] Introduce ZONE_CMA
Message-ID: <20170412013503.GA8448@js1304-desktop>
References: <1491880640-9944-1-git-send-email-iamjoonsoo.kim@lge.com>
 <20170411181519.GC21171@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170411181519.GC21171@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, mgorman@techsingularity.net, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, Russell King <linux@armlinux.org.uk>, Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@lge.com

On Tue, Apr 11, 2017 at 08:15:20PM +0200, Michal Hocko wrote:
> Hi,
> I didn't get to read though patches yet but the cover letter didn't
> really help me to understand the basic concepts to have a good starting
> point before diving into implementation details. It contains a lot of
> history remarks which is not bad but IMHO too excessive here. I would
> appreciate the following information (some of that is already provided
> in the cover but could benefit from some rewording/text reorganization).
> 
> - what is ZONE_CMA and how it is configured (from admin POV)
> - how does ZONE_CMA compare to other zones
> - who is allowed to allocate from this zone and what are the
>   guarantees/requirements for successful allocation
> - how does the zone compare to a preallocate allocation pool
> - how is ZONE_CMA balanced/reclaimed due to internal memory pressure
>   (from CMA users)
> - is this zone reclaimable for the global memory reclaim
> - why this was/is controversial

Hello,

I hope that following summary helps you to understand this patchset.
I skip some basic things about CMA. I will attach this description to
the cover-letter if re-spin is needed.

1. What is ZONE_CMA

ZONE_CMA is a newly introduced zone that manages freepages in CMA areas.
Previously, freepages in CMA areas are in the ordinary zone and
managed/distinguished by the special migratetype, MIGRATE_CMA.
However, it causes too many subtle problems and fixing all the problems
due to it seems to be impossible and too intrusive to MM subsystem.
Therefore, different solution is requested and this is the outcome of
this request. Problem details are described in PART 3.

There is no change in admin POV. It is just implementation detail.
If the kernel is congifured to use CMA, it is managed by MM like as before
except pages are now belong to the separate zone, ZONE_CMA.

2. How does ZONE_CMA compare to other zones

ZONE_CMA is conceptually the same with ZONE_MOVABLE. There is a software
constraint to guarantee the success of future allocation request from
the device. If the device requests the specific range of the memory in CMA
area at the runtime, page that allocated by MM will be migrated to
the other page and it will be returned to the device. To guarantee it,
ZONE_CMA only takes the allocation request with GFP_MOVABLE.

The other important point about ZONE_CMA is that span of ZONE_CMA would be
overlapped with the other zone. This is not new to MM subsystem and
MM subsystem has enough logic to handle such situation
so there would be no problem.

Other things are completely the same with other zones. For MM POV, there is
no difference in allocation process except that it only takes
GFP_MOVABLE request. In reclaim, pages that are allocated by MM will
be reclaimed by the same policy of the MM. So, no difference.

This 'no difference' is a strong point of this approach. ZONE_CMA is
naturally handled by MM subsystem unlike as before (special handling is
required for MIGRATE_CMA).

3. Controversial Point

Major concern from Mel is that zone concept is abused. ZONE is originally
introduced to solve some issues due to H/W addressing limitation.
However, from the age of ZONE_MOVABLE, ZONE is used to solve the issues
due to S/W limitation. This S/W limitation causes highmem/lowmem problem
that is some of memory cannot be usable for kernel memory and LRU ordering
would be broken easily. My major objection to this point is that
this problem isn't related to implementation detail like as ZONE.
Problems just comes from S/W limitation that we cannot use this memory
for kernel memory to guarantee offlining the memory (ZONE_MOVABLE) or
allocation from the device (ZONE_CMA) in the future. See PART 1 for
more information.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
