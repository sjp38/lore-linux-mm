Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 72A916B0313
	for <linux-mm@kvack.org>; Wed, 16 May 2018 06:28:18 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id q67-v6so172764wrb.12
        for <linux-mm@kvack.org>; Wed, 16 May 2018 03:28:18 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g16-v6si2506275edg.21.2018.05.16.03.28.17
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 16 May 2018 03:28:17 -0700 (PDT)
Date: Wed, 16 May 2018 11:28:12 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm/page_alloc: use ac->high_zoneidx for classzone_idx
Message-ID: <20180516102811.huem4rg3mfmp2v5d@suse.de>
References: <1525408246-14768-1-git-send-email-iamjoonsoo.kim@lge.com>
 <8b06973c-ef82-17d2-a83d-454368de75e6@suse.cz>
 <20180504103322.2nbadmnehwdxxaso@suse.de>
 <CAAmzW4PKZFbAS6UEYKP2BBAqgk0=yTMuJRMTz--_0YTj-SjKvw@mail.gmail.com>
 <aa3452e1-db01-42ae-29eb-b23572e88969@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <aa3452e1-db01-42ae-29eb-b23572e88969@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Joonsoo Kim <js1304@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Ye Xiaolong <xiaolong.ye@intel.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Wed, May 16, 2018 at 11:35:55AM +0200, Vlastimil Babka wrote:
> On 05/08/2018 03:00 AM, Joonsoo Kim wrote:
> >> classzone predates my involvement with Linux but I would be less concerneed
> >> about what the original intent was and instead ensure that classzone index
> >> is consistent, sane and potentially renamed while preserving the intent of
> >> "reserve pages in lower zones when an allocation request can use higher
> >> zones". While historically the critical intent was to preserve Normal and
> >> to a lesser extent DMA on 32-bit systems, there still should be some care
> >> of DMA32 so we should not lose that.
> > 
> > Agreed!
> > 
> >> With the patch, the allocator looks like it would be fine as just
> >> reservations change. I think it's unlikely that CMA usage will result
> >> in lowmem starvation.  Compaction becomes a bit weird as classzone index
> >> has no special meaning versis highmem and I think it'll be very easy to
> >> forget.
> 
> I don't understand this point, what do you mean about highmem here?

I mean it has no special meaning as compaction is not primarily concerned
with lowmem protections as it compacts within a zone. It preserves watermarks
but it does not have the same degree of criticality as the page allocator
and reclaim is concerned with.

> I've
> checked and compaction seems to use classzone_idx 1) to pass it to
> watermark checks as part of compaction suitability checks, i.e. the
> usual lowmem protection, and 2) to limit compaction of higher zones in
> kcompactd if the direct compactor can't use them anyway - seems this
> part has currently the same zone imbalance problem as reclaim.
> 

Originally the watermark check for compaction was primarily about not
depleting a single zone but the checks were duplicated anyway. It's not
actually super critical for it to preserve lowmem zones as any memory
usage by compaction is transient.

> > Agreed!
> > I will update this patch to reflect your comment. If someone have an idea
> > on renaming this variable, please let me know.
> 
> Pehaps max_zone_idx? Seems a bit more clear than "high_zoneidx". And I
> have no idea what was actually meant by "class".
> 

I don't have a better suggestion.

-- 
Mel Gorman
SUSE Labs
