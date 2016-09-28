Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id CBDCC28025C
	for <linux-mm@kvack.org>; Wed, 28 Sep 2016 05:00:51 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id l132so32778434wmf.0
        for <linux-mm@kvack.org>; Wed, 28 Sep 2016 02:00:51 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o2si7433774wjr.120.2016.09.28.02.00.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 28 Sep 2016 02:00:48 -0700 (PDT)
Subject: Re: Regression in mobility grouping?
References: <20160928014148.GA21007@cmpxchg.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <8c3b7dd8-ef6f-6666-2f60-8168d41202cf@suse.cz>
Date: Wed, 28 Sep 2016 11:00:15 +0200
MIME-Version: 1.0
In-Reply-To: <20160928014148.GA21007@cmpxchg.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <js1304@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On 09/28/2016 03:41 AM, Johannes Weiner wrote:
> Hi guys,
> 
> we noticed what looks like a regression in page mobility grouping
> during an upgrade from 3.10 to 4.0. Identical machines, workloads, and
> uptime, but /proc/pagetypeinfo on 3.10 looks like this:
> 
> Number of blocks type     Unmovable  Reclaimable      Movable      Reserve      Isolate 
> Node 1, zone   Normal          815          433        31518            2            0 
> 
> and on 4.0 like this:
> 
> Number of blocks type     Unmovable  Reclaimable      Movable      Reserve          CMA      Isolate 
> Node 1, zone   Normal         3880         3530        25356            2            0            0 

It's worth to keep in mind that this doesn't reflect where the actual
unmovable pages reside. It might be that in 3.10 they are spread within
the movable pages. IIRC enabling page_owner (not sure if in 4.0, there
were some later fixes I think) can augment pagetypeinfo with at least
some statistics of polluted pageblocks.

Does e.g. /proc/meminfo suggest how much unmovable/reclaimable memory
there should be allocated and if it would fill the respective
pageblocks, or if they are poorly utilized?

> 4.0 is either polluting pageblocks more aggressively at allocation, or
> is not able to make pageblocks movable again when the reclaimable and
> unmovable allocations are released. Invoking compaction manually
> (/proc/sys/vm/compact_memory) is not bringing them back, either.
>
> The problem we are debugging is that these machines have a very high
> rate of order-3 allocations (fdtable during fork, network rx), and
> after the upgrade allocstalls have increased dramatically. I'm not
> entirely sure this is the same issue, since even order-0 allocations
> are struggling, but the mobility grouping in itself looks problematic.
> 
> I'm still going through the changes relevant to mobility grouping in
> that timeframe, but if this rings a bell for anyone, it would help. I
> hate blaming random patches, but these caught my eye:
> 
> 9c0415e mm: more aggressive page stealing for UNMOVABLE allocations
> 3a1086f mm: always steal split buddies in fallback allocations
> 99592d5 mm: when stealing freepages, also take pages created by splitting buddy page

Check also the changelogs for mentions of earlier commits, e.g. 99592d5
should be restoring behavior that changed in 3.12-3.13 and you are
upgrading from 3.10.

> The changelog states that by aggressively stealing split buddy pages
> during a fallback allocation we avoid subsequent stealing. But since
> there are generally more movable/reclaimable pages available, and so
> less falling back and stealing freepages on behalf of movable, won't
> this mean that we could expect exactly that result - growing numbers
> of unmovable blocks, while rarely stealing them back in movable alloc
> fallbacks? And the expansion of !MOVABLE blocks would over time make
> compaction less and less effective too, seeing as it doesn't consider
> anything !MOVABLE suitable migration targets?

Yeah this is an issue with compaction that was brought up recently and I
want to tackle next.

> Attached are the full /proc/pagetypeinfo and /proc/buddyinfo from both
> kernels on machines with similar uptimes and directly after invoking
> compaction. As you can see, the buddy lists are much more fragmented
> on 4.0, with unmovable/reclaimable allocations polluting more blocks.
> 
> Any thoughts on this would be greatly appreciated. I can test patches.

I guess testing revert of 9c0415e could give us some idea. Commit
3a1086f shouldn't result in pageblock marking differences and as I said
above, 99592d5 should be just restoring to what 3.10 did.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
