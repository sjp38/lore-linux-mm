Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 190206B02E1
	for <linux-mm@kvack.org>; Mon, 24 Apr 2017 23:43:07 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id m132so80051807ith.17
        for <linux-mm@kvack.org>; Mon, 24 Apr 2017 20:43:07 -0700 (PDT)
Received: from mail-pg0-x243.google.com (mail-pg0-x243.google.com. [2607:f8b0:400e:c05::243])
        by mx.google.com with ESMTPS id j5si16967046ioj.127.2017.04.24.20.43.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Apr 2017 20:43:05 -0700 (PDT)
Received: by mail-pg0-x243.google.com with SMTP id t7so4530328pgt.1
        for <linux-mm@kvack.org>; Mon, 24 Apr 2017 20:43:05 -0700 (PDT)
Date: Tue, 25 Apr 2017 12:42:57 +0900
From: Joonsoo Kim <js1304@gmail.com>
Subject: Re: [PATCH v7 0/7] Introduce ZONE_CMA
Message-ID: <20170425034255.GB32583@js1304-desktop>
References: <1491880640-9944-1-git-send-email-iamjoonsoo.kim@lge.com>
 <20170411181519.GC21171@dhcp22.suse.cz>
 <20170412013503.GA8448@js1304-desktop>
 <20170413115615.GB11795@dhcp22.suse.cz>
 <20170417020210.GA1351@js1304-desktop>
 <20170424130936.GB1746@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170424130936.GB1746@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, mgorman@techsingularity.net, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, Russell King <linux@armlinux.org.uk>, Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@lge.com

On Mon, Apr 24, 2017 at 03:09:36PM +0200, Michal Hocko wrote:
> On Mon 17-04-17 11:02:12, Joonsoo Kim wrote:
> > On Thu, Apr 13, 2017 at 01:56:15PM +0200, Michal Hocko wrote:
> > > On Wed 12-04-17 10:35:06, Joonsoo Kim wrote:
> [...]
> > > > ZONE_CMA is conceptually the same with ZONE_MOVABLE. There is a software
> > > > constraint to guarantee the success of future allocation request from
> > > > the device. If the device requests the specific range of the memory in CMA
> > > > area at the runtime, page that allocated by MM will be migrated to
> > > > the other page and it will be returned to the device. To guarantee it,
> > > > ZONE_CMA only takes the allocation request with GFP_MOVABLE.
> > > 
> > > The immediate follow up question is. Why cannot we reuse ZONE_MOVABLE
> > > for that purpose?
> > 
> > I can make CMA reuses the ZONE_MOVABLE but I don't want it. Reasons
> > are that
> > 
> > 1. If ZONE_MOVABLE has two different types of memory, hotpluggable and
> > CMA, it may need special handling for each type. This would lead to a new
> > migratetype again (to distinguish them) and easy to be error-prone. I
> > don't want that case.
> 
> Hmm, I see your motivation. I believe that we could find a way
> around this. Anyway, movable zones are quite special and configuring
> overlapping CMA and hotplug movable regions could be refused. So I am
> not even sure this is a real problem in practice.
> 
> > 2. CMA users want to see usage stat separately since CMA often causes
> > the problems and separate stat would helps to debug it.
> 
> That could be solved by a per-zone/node counter.
> 
> Anyway, these reasons should be mentioned as well. Adding a new zone is

Okay.

> not for free. For most common configurations where we have ZONE_DMA,
> ZONE_DMA32, ZONE_NORMAL and ZONE_MOVABLE all the 3 bits are already
> consumed so a new zone will need a new one AFAICS.

Yes, it requires one more bit for a new zone and it's handled by the patch.

> 
> [...]
> > > > Other things are completely the same with other zones. For MM POV, there is
> > > > no difference in allocation process except that it only takes
> > > > GFP_MOVABLE request. In reclaim, pages that are allocated by MM will
> > > > be reclaimed by the same policy of the MM. So, no difference.
> > > 
> > > OK, so essentially this is yet another "highmem" zone. We already know
> > > that only GFP_MOVABLE are allowed to fallback to ZONE_CMA but do CMA
> > > allocations fallback to other zones and punch new holes? In which zone
> > > order?
> > 
> > Hmm... I don't understand your question. Could you elaborate it more?
> 
> Well, my question was about the zone fallback chain. MOVABLE allocation
> can fallback to lower zones and also to the ZONE_CMA with your patch. If
> there is a CMA allocation it doesn't fall back to any other zone - in
> other words no new holes are punched to other zones. Is this correct?

Hmm... I still don't get the meaning of "no new holes are punched to
other zones". I try to answer with my current understanding about your
question.

MOVABLE allocation will fallback as following sequence.

ZONE_CMA -> ZONE_MOVABLE -> ZONE_HIGHMEM -> ZONE_NORMAL -> ...

I don't understand what you mean CMA allocation. In MM's context,
there is no CMA allocation. That is just MOVABLE allocation.

For device's context, there is CMA allocation. It is range specific
allocation so it should be succeed for requested range. No fallback is
allowed in this case.

> > > > This 'no difference' is a strong point of this approach. ZONE_CMA is
> > > > naturally handled by MM subsystem unlike as before (special handling is
> > > > required for MIGRATE_CMA).
> > > > 
> > > > 3. Controversial Point
> > > > 
> > > > Major concern from Mel is that zone concept is abused. ZONE is originally
> > > > introduced to solve some issues due to H/W addressing limitation.
> > > 
> > > Yes, very much agreed on that. You basically want to punch holes into
> > > other zones to guarantee an allocation progress. Marking those wholes
> > > with special migrate type sounds quite natural but I will have to study
> > > the current code some more to see whether issues you mention are
> > > inherently unfixable. This might very well turn out to be the case.
> > 
> > At a glance, special migratetype sound natural. I also did. However,
> > it's not natural in implementation POV. Zone consists of the same type
> > of memory (by definition ?) and MM subsystem is implemented with that
> > assumption. If difference type of memory shares the same zone, it easily
> > causes the problem and CMA problems are the such case.
> 
> But this is not any different from the highmem vs. lowmem problems we
> already have, no? I have looked at your example in the cover where you
> mention utilization and the reclaim problems. With the node reclaim we
> will have pages from all zones on the same LRU(s). isolate_lru_pages
> will skip those from ZONE_CMA because their zone_idx is higher than
> gfp_idx(GFP_KERNEL). The same could be achieved by an explicit check for
> the pageblock migrate type. So the zone doesn't really help much. Or is
> there some aspect that I am missing?

Your understanding is correct. It can archieved by an explict check
for migratetype. And, this is the main reason that we should avoid
such approach.

With ZONE approach, all these things are done naturally. We don't need
any explicit check to anywhere. We already have a code to skip to
reclaim such pages by checking zone_idx.

However, with MIGRATETYPE approach, all these things *cannot* be done
naturally. We need extra checks to all the places (allocator fast
path, reclaim path, compaction, etc...). It is really error-prone and
it already causes many problems due to this aspect. For the
performance wise, this approach is also bad since it requires to check
migratetype for each pages.

Moreover, even if we adds extra checks, things cannot be easily
perfect. See 3) Atomic allocation failure problem. It's inherent
problem if we have different types of memory in a single zone.
We possibly can make things perfect even with MIGRATETYPE approach,
however, it requires additional checks in hotpath than current. It's
expensive and undesirable. It will make future maintenance of MM code
much difficult.

This is why I prefer the ZONE approach.


> 
> Another worry I would have with the zone approach is that there is a
> risk to reintroduce issues we used to have with small zones in the
> past. Just consider that the CMA will get depleted by CMA users almost
> completely. Now that zone will not get balanced with only few pages.
> wakeup_kswapd/pgdat_balanced already has measures to prevent from wake
> ups but I cannot say I would be sure everything will work smoothly.

If there is a small zone problem, it should be fixed in any case.
There are many workloads that allocates memory almost completely
and doesn't return them back to the page allocator.

> I have glanced through the cumulative diff and to be honest I am not
> really sure the result is a great simplification in the end. There is
> still quite a lot of special casing. It is true that the page allocator

Special casing is mostly for initialization. We cannot avoid such things
since CMA isn't normal memory. We have just two choices.

1) ZONE: special casing in intialization phase
2) MIGRATETYPE: special casing in runtime phase

And, I choose 1).

> path is cleaned up and some CMA specific checks are moved away. This is
> definitely good to see but I am not convinced that the new zone is
> really justified. Only very little from the zone infrastructure is used
> in the end AFAICS. Is there any specific usecase which cannot be solved
> with the pageblock while it could be with the zone approach? That would
> be a strong argument to chose one over another.

As I mentioned above, atomic allocation failure problem is somewhat
inherent problem. Another one is described in Vlastimil's reply in
other thread.

lkml.kernel.org/r/ae9c5714-ff45-05ea-6a10-976c311b5742@suse.cz
> 
> Please do _not_ take this as a NAK from me. At least not at this time. I
> am still trying to understand all the consequences but my intuition
> tells me that building on top of highmem like approach will turn out to
> be problematic in future (as we have already seen with the highmem and
> movable zones) so this needs a very prudent consideration.

I can understand that you are prudent to this issue. However, it takes more
than two years and many people already expressed that ZONE approach is the
way to go.

As I said before, some problems are due to S/W limitation of the CMA
memory, not due to the implementation. Even if it chooses MIGRATETYPE
approach, some problem that you have seen in highmem and
movable zones will still exist. So, it should not be a criteria for
implementation decision.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
