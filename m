Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5DD506B03E8
	for <linux-mm@kvack.org>; Fri, 17 Feb 2017 11:32:05 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id gh4so9125455wjb.7
        for <linux-mm@kvack.org>; Fri, 17 Feb 2017 08:32:05 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e71si2263163wmc.105.2017.02.17.08.32.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 17 Feb 2017 08:32:04 -0800 (PST)
Subject: Re: [PATCH v2 07/10] mm, compaction: restrict async compaction to
 pageblocks of same migratetype
References: <20170210172343.30283-1-vbabka@suse.cz>
 <20170210172343.30283-8-vbabka@suse.cz> <20170214201000.GH2450@cmpxchg.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <a0409d22-6794-bb33-6bdd-438b386412a3@suse.cz>
Date: Fri, 17 Feb 2017 17:32:00 +0100
MIME-Version: 1.0
In-Reply-To: <20170214201000.GH2450@cmpxchg.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@techsingularity.net>, linux-kernel@vger.kernel.org, kernel-team@fb.com

On 02/14/2017 09:10 PM, Johannes Weiner wrote:
> On Fri, Feb 10, 2017 at 06:23:40PM +0100, Vlastimil Babka wrote:
>> The migrate scanner in async compaction is currently limited to MIGRATE_MOVABLE
>> pageblocks. This is a heuristic intended to reduce latency, based on the
>> assumption that non-MOVABLE pageblocks are unlikely to contain movable pages.
>> 
>> However, with the exception of THP's, most high-order allocations are not
>> movable. Should the async compaction succeed, this increases the chance that
>> the non-MOVABLE allocations will fallback to a MOVABLE pageblock, making the
>> long-term fragmentation worse.
>> 
>> This patch attempts to help the situation by changing async direct compaction
>> so that the migrate scanner only scans the pageblocks of the requested
>> migratetype. If it's a non-MOVABLE type and there are such pageblocks that do
>> contain movable pages, chances are that the allocation can succeed within one
>> of such pageblocks, removing the need for a fallback. If that fails, the
>> subsequent sync attempt will ignore this restriction.
>> 
>> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> 
> Yes, IMO we should make the async compaction scanner decontaminate
> unmovable blocks. This is because we fall back to other-typed blocks
> before we reclaim,

Which we could change too, patch 9 is a step in that direction.

> so any unmovable blocks that aren't perfectly
> occupied will fill with greedy page cache (and order-0 doesn't steal
> blocks back to make them compactable again).

order-0 allocation can actually steal the block back, the decisions to steal are
based on the order of the free pages in the fallback block, not on the
allocation order. But maybe I'm not sure what exactly you meant here.

> Subsequent unmovable
> higher-order allocations in turn are more likely to fall back and
> steal more movable blocks.

Yes.

> As long as we have vastly more movable blocks than unmovable blocks,
> continuous page cache turnover will counteract this negative trend -
> pages are reclaimed mostly from movable blocks and some unmovable
> blocks, while new cache allocations are placed into the freed movable
> blocks - slowly moving cache out from unmovable blocks into movable
> ones. But that effect is independent of the rate of higher-order
> allocations and can be overwhelmed, so I think it makes sense to
> involve compaction directly in decontamination.

Interesting observation, I agree.

> The thing I'm not entirely certain about is the aggressiveness of this
> patch. Instead of restricting the async scanner to blocks of the same
> migratetype, wouldn't it be better (in terms of allocation latency) to
> simply let it compact *all* block types?

Yes it would help allocation latency, but I'm afraid it will remove most of the
decontamination effect.

> Maybe changing it to look at
> unmovable blocks is enough to curb cross-contamination. Sure there
> will still be some, but now we're matching the decontamination rate to
> the rate of !movable higher-order allocations and don't just rely on
> the independent cache turnover rate, which during higher-order bursts
> might not be high enough to prevent an expansion of unmovable blocks.

The rate of compaction attempts is matched with allocations, but the probability
of compaction scanner being in unmovable block is low when the majority of
blocks are movable. So the decontamination rate is proportional but much smaller.

> Does that make sense?

I guess I can try and look at the stats, but I have doubts.

Thanks for the feedback!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
