Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id D3A936B0315
	for <linux-mm@kvack.org>; Tue, 16 May 2017 04:47:40 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id s62so131388326pgc.2
        for <linux-mm@kvack.org>; Tue, 16 May 2017 01:47:40 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w17si4676100pfi.116.2017.05.16.01.47.39
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 16 May 2017 01:47:40 -0700 (PDT)
Date: Tue, 16 May 2017 10:47:34 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v7 0/7] Introduce ZONE_CMA
Message-ID: <20170516084734.GC2481@dhcp22.suse.cz>
References: <20170424130936.GB1746@dhcp22.suse.cz>
 <20170425034255.GB32583@js1304-desktop>
 <20170427150636.GM4706@dhcp22.suse.cz>
 <20170502040129.GA27335@js1304-desktop>
 <20170502133229.GK14593@dhcp22.suse.cz>
 <20170511021240.GA22319@js1304-desktop>
 <20170511091304.GH26782@dhcp22.suse.cz>
 <20170512020046.GA5538@js1304-desktop>
 <20170512063815.GC6803@dhcp22.suse.cz>
 <20170515035712.GA11257@js1304-desktop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170515035712.GA11257@js1304-desktop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, mgorman@techsingularity.net, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, Russell King <linux@armlinux.org.uk>, Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@lge.com

On Mon 15-05-17 12:57:15, Joonsoo Kim wrote:
> On Fri, May 12, 2017 at 08:38:15AM +0200, Michal Hocko wrote:
[...]
> > I really do not want to question your "simple test" but page_zonenum is
> > used in many performance sensitive paths and proving it doesn't regress
> > would require testing many different workload. Are you going to do that?
> 
> In fact, I don't think that we need to take care about this
> performance problem seriously. The reasons are that:
> 
> 1. Currently, there is a usable bit in the page flags.
> 2. Even if others consume one usable bit, there still exists spare bit
> in 64b kernel. And, for 32b kernel, the number of the zone can be five
> if both, ZONE_CMA and ZONE_HIGHMEM, are used. And, using ZONE_HIGHMEM
> in 32b system is out of the trend.
> 3. Even if we fall into the latter category, I can optimize it not to
> regress if both the zone, ZONE_MOVABLE and ZONE_CMA, aren't used
> simultaneously with two zone bits in page flags. However, using both
> zones is not usual case.
> 4. This performance problem only affects CMA users and there is also a
> benefit due to removal of many hooks in MM subsystem so net result would
> not be worse.

A lot of fiddling for something that we can address in a different way,
really.

> So, I think that performance would be better in most of cases. It
> would be magianlly worse in rare cases and they could bear with it. Do
> you still think that using ZONE_MOVABLE for CMA memory is
> necessary rather than separate zone, ZONE_CMA?

yes, because the main point is that a new zone is not really needed
AFAICS. Just try to reuse what we already have (ZONE_MOVABLE). And more
over a new zone just pulls a lot of infrastructure which will be never
used.

> > > > But I feel we are looping without much progress. So let me NAK this
> > > > until it is _proven_ that the current code is unfixable nor ZONE_MOVABLE
> > > > can be reused
> > > 
> > > I want to open all the possibilty so could you check that ZONE_MOVABLE
> > > can be overlapped with other zones? IIRC, your rework doesn't allow
> > > it.
> > 
> > My rework keeps the status quo, which is based on the assumption that
> > zones cannot overlap. A longer term plan is that this restriction is
> > removed. As I've said earlier overlapping zones is an interesting
> > concept which is definitely worth pursuing.
> 
> Okay. We did a lot of discussion so it's better to summarise it.
> 
> 1. ZONE_CMA might be a nicer solution than MIGRATETYPE.
> 2. Additional bit in page flags would cause another kind of
> maintenance problem so it's better to avoid it as much as possible.
> 3. Abusing ZONE_MOVABLE looks better than introducing ZONE_CMA since
> it doesn't need additional bit in page flag.
> 4. (Not-yet-finished) If ZONE_CMA doesn't need extra bit in page
> flags with hacky magic and it has no performance regression,
> ??? (it's okay to use separate zone for CMA?)

As mentioned above. I do not see why we should go over additional hops
just to have a zone which is not strictly needed. So if there are no
inherent problems reusing MOVABLE/HIGMEM zone then a separate zone
sounds like a wrong direction.

But let me repeat. I am _not_ convinced that the migratetype situation
is all that bad and unfixable. You have mentioned some issues with the
current approach but none of them seem inherently unfixable. So I would
still prefer keeping the current way. But I am not going to insist if
you _really_ believe that the long term maintenance cost will be higher
than a zone approach and you can reuse MOVABLE/HIGHMEM zones without
disruptive changes. I can help you with the hotplug part of the MOVABLE
zone because that is desirable on its own.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
