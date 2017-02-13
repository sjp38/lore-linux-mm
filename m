Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id E36B46B0388
	for <linux-mm@kvack.org>; Mon, 13 Feb 2017 05:56:58 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id an2so41686817wjc.3
        for <linux-mm@kvack.org>; Mon, 13 Feb 2017 02:56:58 -0800 (PST)
Received: from outbound-smtp04.blacknight.com (outbound-smtp04.blacknight.com. [81.17.249.35])
        by mx.google.com with ESMTPS id i17si13366847wrb.90.2017.02.13.02.56.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 13 Feb 2017 02:56:57 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp04.blacknight.com (Postfix) with ESMTPS id 841A198B5E
	for <linux-mm@kvack.org>; Mon, 13 Feb 2017 10:56:57 +0000 (UTC)
Date: Mon, 13 Feb 2017 10:56:56 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH v2 07/10] mm, compaction: restrict async compaction to
 pageblocks of same migratetype
Message-ID: <20170213105656.2pp5mrdhlkvh73tr@techsingularity.net>
References: <20170210172343.30283-1-vbabka@suse.cz>
 <20170210172343.30283-8-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20170210172343.30283-8-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, kernel-team@fb.com

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

Ok, I really like this idea. The thinking of async originally was to
reduce latency but that was also at the time when THP allocations were
stalling for long periods of time. Now that the default has changed,
this idea makes a lot of sense. A few months ago I would have thought
that this will increase the changes that a high-order allocation for the
stack may have a higher chance of failing but with VMAP_STACK, this is
much less of a concern. It would be very nice to know for this patch if
the number of times the extfrag tracepoint is triggered is reduced or
increased by this patch. Do you have that data?

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
