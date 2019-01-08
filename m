Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 969B78E0038
	for <linux-mm@kvack.org>; Tue,  8 Jan 2019 06:25:03 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id x15so1508299edd.2
        for <linux-mm@kvack.org>; Tue, 08 Jan 2019 03:25:03 -0800 (PST)
Received: from outbound-smtp02.blacknight.com (outbound-smtp02.blacknight.com. [81.17.249.8])
        by mx.google.com with ESMTPS id i19si2194095edr.271.2019.01.08.03.25.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Jan 2019 03:25:02 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp02.blacknight.com (Postfix) with ESMTPS id E8EDD9888D
	for <linux-mm@kvack.org>; Tue,  8 Jan 2019 11:25:01 +0000 (UTC)
Date: Tue, 8 Jan 2019 11:25:00 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [RFC 2/3] mm, page_alloc: reclaim for __GFP_NORETRY costly
 requests only when compaction was skipped
Message-ID: <20190108112500.GO31517@techsingularity.net>
References: <20181211142941.20500-1-vbabka@suse.cz>
 <20181211142941.20500-3-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20181211142941.20500-3-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On Tue, Dec 11, 2018 at 03:29:40PM +0100, Vlastimil Babka wrote:
> For costly __GFP_NORETRY allocations (including THP's) we first do an initial
> compaction attempt and if that fails, we proceed with reclaim and another
> round of compaction, unless compaction was deferred due to earlier multiple
> failures. Andrea proposed [1] that we count all compaction failures as the
> defered case in try_to_compact_pages(), but I don't think that's a good idea
> in general.

I'm still stuck on the pre/post compaction series dilemma. I agree with
you before the compaction series and disagree with you after. I'm not
sitting on the fence here, I really think the series materially alters
the facts :(.

> Instead, change the __GFP_NORETRY specific condition so that it
> only proceeds with further reclaim/compaction when the initial compaction
> attempt was skipped due to lack of free base pages.
> 
> Note that the original condition probably never worked properly for THP's,
> because compaction can only become deferred after a sync compaction failure,
> and THP's only perform async compaction, except khugepaged, which is
> infrequent, or madvised faults (until the previous patch restored __GFP_NORETRY
> for those) which are not the default case. Deferring due to async compaction
> failures should be however also beneficial and thus introduced in the next
> patch.
> 
> Also note that due to how try_to_compact_pages() constructs its return value
> from compaction attempts across the whole zonelist, returning COMPACT_SKIPPED
> means that compaction was skipped for *all* attempted zones/nodes, which means
> all zones/nodes are low on memory at the same moment. This is probably rare,

It's not as rare as I imagined but compaction series changes it so that
it really is rare or when it occurs, it probably means compaction will
fail if retried.

> which would mean that the resulting 'goto nopage' would be very common,just
> because e.g. a single zone had enough memory and compaction failed there, while
> the rest of nodes could succeed after reclaim.  However, since THP faults use
> __GFP_THISNODE, compaction is also attempted only for a single node, so in
> practice there should be no significant loss of information when constructing
> the return value, nor bias towards 'goto nopage' for THP faults.
> 

Post the compaction series, we never direct compact a remote node. I
think post the series this concept still makes sense but it would turn
into 

a) try async compaction
b) try sync compaction
c) defer unconditionally

Ideally Andrea would be able to report back on this but if we can decide
on the compaction series and the ordering of this, I can shove the results
through the SUSE test grid with both the usemem (similar to Andrea's case)
and the thpscale/thpfioscale cases and see what the latency and success
rates look like.

-- 
Mel Gorman
SUSE Labs
