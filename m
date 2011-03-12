Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 161748D003A
	for <linux-mm@kvack.org>; Fri, 11 Mar 2011 23:28:34 -0500 (EST)
Date: Sat, 12 Mar 2011 05:28:06 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] thp: mremap support and TLB optimization
Message-ID: <20110312042806.GM5641@random.random>
References: <20110311020410.GH5641@random.random>
 <AANLkTikZJqTtVF48cc-AQ1z9iF29Z+f35Qdn_1m_SFQi@mail.gmail.com>
 <AANLkTi=EWW=uaHZbW95_eqabVHTsMdX5N2h_axqi27nn@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <AANLkTi=EWW=uaHZbW95_eqabVHTsMdX5N2h_axqi27nn@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>

On Fri, Mar 11, 2011 at 12:25:42PM -0800, Hugh Dickins wrote:
> Perhaps I should qualify that answer: although I still think it's the
> right change to make (it matches mprotect, for example), and an
> optimization in many cases, it will be a pessimization for anyone who
> mremap moves unpopulated areas (I doubt that's common), and for anyone
> who moves around single page areas (on x86 and probably some others).
> But the exec args case has, I think, few useful tlb entries to lose
> from the mm-wide tlb flush.

The pessimization of the totally unmapped areas I didn't consider it
as a real life possibility. At least the mmu notifier isn't pessimized
if the pmd wasn't none but the pte was none, only the TLB flush really
is pessimized in that case (if all old ptes are none regardless of the
pmd). But the range TLB flush is real easy to optimize for unmapped
areas if we want, just skip the flush_tlb_range if all old ptes were
none and we actually changed nothing, right? Fixing the mmu notifier
isn't possible but that's not a concern and it'll surely be fine to
stay in move_page_tables.

So do we want one more branch to avoid one IPI if mremap runs on an
unmapped area? That's ok with me if it's a real life possibility. At
the moment I think any app doing that is pretty stupid and shouldn't
call mremap in the first place, and it should have used
mmap(MAP_FIXED) or a bigger mmap size in the first place though... If
we add a branch for that case, maybe we should also printk if we
detect that, in addition to skipping the tlb flush.

> flush_tlb_range() ought to special case small areas, doing at most one
> IPI, but up to some number of flush_tlb_one()s; but that would
> certainly have to be another patch.

That's probably a good tradeoff. Even better would be if x86 would be
extended to allow range flushes so we don't have to do guesswork in
software.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
