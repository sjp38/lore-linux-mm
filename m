Message-ID: <44718672.8050408@yahoo.com.au>
Date: Mon, 22 May 2006 19:37:54 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [patch 2/2] mm: handle unaligned zones
References: <4470232B.7040802@yahoo.com.au> <44702358.1090801@yahoo.com.au> <447173EF.9090000@shadowen.org>
In-Reply-To: <447173EF.9090000@shadowen.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: Andrew Morton <akpm@osdl.org>, Mel Gorman <mel@csn.ul.ie>, stable@kernel.org, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Andy Whitcroft wrote:

> Ok.  I agree that that unaligned zones should be opt-in, it always was

Yes.

> However, this patch here seems redundant.  The requirement from the
> buddy allocator has been an aligned node_mem_map out to MAX_ORDER either
> side of the zones in that node.  With the recent patch from Bob Picco it
> is now allocated that way always.  So we will always have a page* from
> either the adjoining zone or from the node_mem_map padding to examine
> when we are looking for a buddy to coelesce with.  It should always be
> safe to examine that page*'s flags to see if its free to coelesce.  For
> pages outside any zone PG_buddy will never be true, for those in another
> zone the page_zone_idx() check is sufficient.

That's true - does this cover all architectures that do not define
CONFIG_HOLES_IN_ZONE ?

> With the page_zone_idx check enabled and the node_mem_map aligned, I
> cannot see why we would also need to check the zone pfn numbers too?  If
> we did need to check them, then there would be no benefit in checking
> the page_zone_idx as that check would always succeed.

Yes. BTW. are the struct pages outside the nodes going to be correctly
aligned? Either way, I think we should also check that everything has
been set up in the way we expect at meminit time (see my debug function).

> 
> I think the smallest, lightest weight set of changes for this problem is
> the node_mem_map alignement patch from Bob Picco, plus the changes to
> add just the page_zone_idx checks to the allocator.  If the stack that

Yes, that sounds fine.

> makes this an opt-out option is too large, a two liner to check just
> page_zone_idx always would be a good option for stable.

I think it is more a question of time for all arch maintainers to verify
rather than size.

If you just mean: you want to negate the meaning of the CONFIG_ option,
and go through and define it in all architectures, I'd be fine with that
too (by opt-in I just mean the check should be turned on until proven
otherwise)

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
