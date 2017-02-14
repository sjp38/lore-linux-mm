Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 69379680FD0
	for <linux-mm@kvack.org>; Tue, 14 Feb 2017 15:10:09 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id u65so48501205wrc.6
        for <linux-mm@kvack.org>; Tue, 14 Feb 2017 12:10:09 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id g13si2057641wrb.133.2017.02.14.12.10.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Feb 2017 12:10:08 -0800 (PST)
Date: Tue, 14 Feb 2017 15:10:00 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v2 07/10] mm, compaction: restrict async compaction to
 pageblocks of same migratetype
Message-ID: <20170214201000.GH2450@cmpxchg.org>
References: <20170210172343.30283-1-vbabka@suse.cz>
 <20170210172343.30283-8-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170210172343.30283-8-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@techsingularity.net>, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Fri, Feb 10, 2017 at 06:23:40PM +0100, Vlastimil Babka wrote:
> The migrate scanner in async compaction is currently limited to MIGRATE_MOVABLE
> pageblocks. This is a heuristic intended to reduce latency, based on the
> assumption that non-MOVABLE pageblocks are unlikely to contain movable pages.
> 
> However, with the exception of THP's, most high-order allocations are not
> movable. Should the async compaction succeed, this increases the chance that
> the non-MOVABLE allocations will fallback to a MOVABLE pageblock, making the
> long-term fragmentation worse.
> 
> This patch attempts to help the situation by changing async direct compaction
> so that the migrate scanner only scans the pageblocks of the requested
> migratetype. If it's a non-MOVABLE type and there are such pageblocks that do
> contain movable pages, chances are that the allocation can succeed within one
> of such pageblocks, removing the need for a fallback. If that fails, the
> subsequent sync attempt will ignore this restriction.
> 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>

Yes, IMO we should make the async compaction scanner decontaminate
unmovable blocks. This is because we fall back to other-typed blocks
before we reclaim, so any unmovable blocks that aren't perfectly
occupied will fill with greedy page cache (and order-0 doesn't steal
blocks back to make them compactable again). Subsequent unmovable
higher-order allocations in turn are more likely to fall back and
steal more movable blocks.

As long as we have vastly more movable blocks than unmovable blocks,
continuous page cache turnover will counteract this negative trend -
pages are reclaimed mostly from movable blocks and some unmovable
blocks, while new cache allocations are placed into the freed movable
blocks - slowly moving cache out from unmovable blocks into movable
ones. But that effect is independent of the rate of higher-order
allocations and can be overwhelmed, so I think it makes sense to
involve compaction directly in decontamination.

The thing I'm not entirely certain about is the aggressiveness of this
patch. Instead of restricting the async scanner to blocks of the same
migratetype, wouldn't it be better (in terms of allocation latency) to
simply let it compact *all* block types? Maybe changing it to look at
unmovable blocks is enough to curb cross-contamination. Sure there
will still be some, but now we're matching the decontamination rate to
the rate of !movable higher-order allocations and don't just rely on
the independent cache turnover rate, which during higher-order bursts
might not be high enough to prevent an expansion of unmovable blocks.

Does that make sense?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
