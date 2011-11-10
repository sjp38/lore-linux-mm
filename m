Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 59EDF6B0080
	for <linux-mm@kvack.org>; Thu, 10 Nov 2011 09:22:09 -0500 (EST)
Date: Thu, 10 Nov 2011 14:22:03 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm: Do not stall in synchronous compaction for THP
 allocations
Message-ID: <20111110142202.GE3083@suse.de>
References: <20111110100616.GD3083@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20111110100616.GD3083@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, Andy Isaacson <adi@hexapodia.org>, Johannes Weiner <jweiner@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Nov 10, 2011 at 10:06:16AM +0000, Mel Gorman wrote:
> than stall. It was suggested that __GFP_NORETRY be used instead of
> __GFP_NO_KSWAPD. This would look less like a special case but would
> still cause compaction to run at least once with sync compaction.
> 

This comment is bogus - __GFP_NORETRY would have caught THP allocations
and would not call sync compaction. The issue was that it would also
have caught any hypothetical high-order GFP_THISNODE allocations that
end up calling compaction here

                /*
                 * High-order allocations do not necessarily loop after
                 * direct reclaim and reclaim/compaction depends on
                 * compaction being called after reclaim so call directly if
                 * necessary
                 */
                page = __alloc_pages_direct_compact(gfp_mask, order,
                                        zonelist, high_zoneidx,
                                        nodemask,
                                        alloc_flags, preferred_zone,
                                        migratetype, &did_some_progress,
                                        sync_migration);

__GFP_NORETRY is used in a bunch of places and while the most
of them are not high-order, some of them potentially are like in
sound/core/memalloc.c. Using __GFP_NO_KSWAPD as the flag allows
these callers to continue using sync compaction.  It could be argued
that they would prefer __GFP_NORETRY but the potential side-effects
should be taken should be taken into account and the comment updated
if that happens.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
