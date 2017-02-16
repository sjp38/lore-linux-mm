Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id EE4E4680FEA
	for <linux-mm@kvack.org>; Thu, 16 Feb 2017 06:44:20 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id q124so2864484wmg.2
        for <linux-mm@kvack.org>; Thu, 16 Feb 2017 03:44:20 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id k206si232084wma.17.2017.02.16.03.44.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Feb 2017 03:44:19 -0800 (PST)
Date: Thu, 16 Feb 2017 06:44:10 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v2 08/10] mm, compaction: finish whole pageblock to
 reduce fragmentation
Message-ID: <20170216114410.GA15895@cmpxchg.org>
References: <20170210172343.30283-1-vbabka@suse.cz>
 <20170210172343.30283-9-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170210172343.30283-9-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@techsingularity.net>, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Fri, Feb 10, 2017 at 06:23:41PM +0100, Vlastimil Babka wrote:
> The main goal of direct compaction is to form a high-order page for allocation,
> but it should also help against long-term fragmentation when possible. Most
> lower-than-pageblock-order compactions are for non-movable allocations, which
> means that if we compact in a movable pageblock and terminate as soon as we
> create the high-order page, it's unlikely that the fallback heuristics will
> claim the whole block. Instead there might be a single unmovable page in a
> pageblock full of movable pages, and the next unmovable allocation might pick
> another pageblock and increase long-term fragmentation.
> 
> To help against such scenarios, this patch changes the termination criteria for
> compaction so that the current pageblock is finished even though the high-order
> page already exists. Note that it might be possible that the high-order page
> formed elsewhere in the zone due to parallel activity, but this patch doesn't
> try to detect that.
> 
> This is only done with sync compaction, because async compaction is limited to
> pageblock of the same migratetype, where it cannot result in a migratetype
> fallback. (Async compaction also eagerly skips order-aligned blocks where
> isolation fails, which is against the goal of migrating away as much of the
> pageblock as possible.)
> 
> As a result of this patch, long-term memory fragmentation should be reduced.
> 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
