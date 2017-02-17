Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 38FB3680FC1
	for <linux-mm@kvack.org>; Fri, 17 Feb 2017 12:39:49 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id le4so4458009wjb.1
        for <linux-mm@kvack.org>; Fri, 17 Feb 2017 09:39:49 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id b66si2450836wmc.145.2017.02.17.09.39.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Feb 2017 09:39:47 -0800 (PST)
Date: Fri, 17 Feb 2017 12:39:40 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v2 07/10] mm, compaction: restrict async compaction to
 pageblocks of same migratetype
Message-ID: <20170217173940.GA25565@cmpxchg.org>
References: <20170210172343.30283-1-vbabka@suse.cz>
 <20170210172343.30283-8-vbabka@suse.cz>
 <20170214201000.GH2450@cmpxchg.org>
 <a0409d22-6794-bb33-6bdd-438b386412a3@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a0409d22-6794-bb33-6bdd-438b386412a3@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@techsingularity.net>, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Fri, Feb 17, 2017 at 05:32:00PM +0100, Vlastimil Babka wrote:
> On 02/14/2017 09:10 PM, Johannes Weiner wrote:
> > On Fri, Feb 10, 2017 at 06:23:40PM +0100, Vlastimil Babka wrote:
> >> The migrate scanner in async compaction is currently limited to MIGRATE_MOVABLE
> >> pageblocks. This is a heuristic intended to reduce latency, based on the
> >> assumption that non-MOVABLE pageblocks are unlikely to contain movable pages.
> >> 
> >> However, with the exception of THP's, most high-order allocations are not
> >> movable. Should the async compaction succeed, this increases the chance that
> >> the non-MOVABLE allocations will fallback to a MOVABLE pageblock, making the
> >> long-term fragmentation worse.
> >> 
> >> This patch attempts to help the situation by changing async direct compaction
> >> so that the migrate scanner only scans the pageblocks of the requested
> >> migratetype. If it's a non-MOVABLE type and there are such pageblocks that do
> >> contain movable pages, chances are that the allocation can succeed within one
> >> of such pageblocks, removing the need for a fallback. If that fails, the
> >> subsequent sync attempt will ignore this restriction.
> >> 
> >> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> > 
> > Yes, IMO we should make the async compaction scanner decontaminate
> > unmovable blocks. This is because we fall back to other-typed blocks
> > before we reclaim,
> 
> Which we could change too, patch 9 is a step in that direction.

Yep, patch 9 looks good to me too, pending data that confirms it.

> > so any unmovable blocks that aren't perfectly
> > occupied will fill with greedy page cache (and order-0 doesn't steal
> > blocks back to make them compactable again).
> 
> order-0 allocation can actually steal the block back, the decisions to steal are
> based on the order of the free pages in the fallback block, not on the
> allocation order. But maybe I'm not sure what exactly you meant here.

No, that was me misreading the code. Scratch what's in parentheses.

> > The thing I'm not entirely certain about is the aggressiveness of this
> > patch. Instead of restricting the async scanner to blocks of the same
> > migratetype, wouldn't it be better (in terms of allocation latency) to
> > simply let it compact *all* block types?
> 
> Yes it would help allocation latency, but I'm afraid it will remove most of the
> decontamination effect.
> 
> > Maybe changing it to look at
> > unmovable blocks is enough to curb cross-contamination. Sure there
> > will still be some, but now we're matching the decontamination rate to
> > the rate of !movable higher-order allocations and don't just rely on
> > the independent cache turnover rate, which during higher-order bursts
> > might not be high enough to prevent an expansion of unmovable blocks.
> 
> The rate of compaction attempts is matched with allocations, but the probability
> of compaction scanner being in unmovable block is low when the majority of
> blocks are movable. So the decontamination rate is proportional but much smaller.

Yeah, you're right. The unmovable blocks would still expand, we'd just
turn it into a logarithmic curve.

> > Does that make sense?
> 
> I guess I can try and look at the stats, but I have doubts.

I don't insist. Your patch is implementing a good thing, we can just
keep an eye out for a change in allocation latencies before spending
time trying to mitigate a potential non-issue.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
