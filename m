Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5B41F6B038A
	for <linux-mm@kvack.org>; Mon, 13 Feb 2017 05:57:12 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id h7so41598490wjy.6
        for <linux-mm@kvack.org>; Mon, 13 Feb 2017 02:57:12 -0800 (PST)
Received: from outbound-smtp05.blacknight.com (outbound-smtp05.blacknight.com. [81.17.249.38])
        by mx.google.com with ESMTPS id u203si5039127wmu.140.2017.02.13.02.57.11
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 13 Feb 2017 02:57:11 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp05.blacknight.com (Postfix) with ESMTPS id 124B798B5E
	for <linux-mm@kvack.org>; Mon, 13 Feb 2017 10:57:11 +0000 (UTC)
Date: Mon, 13 Feb 2017 10:57:10 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH v2 08/10] mm, compaction: finish whole pageblock to
 reduce fragmentation
Message-ID: <20170213105710.knhhoqe6jfkwoaxo@techsingularity.net>
References: <20170210172343.30283-1-vbabka@suse.cz>
 <20170210172343.30283-9-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20170210172343.30283-9-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, kernel-team@fb.com

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

Acked-by: Mel Gorman <mgorman@techsingularity.net>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
