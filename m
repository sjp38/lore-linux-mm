Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id E4A3D6B003D
	for <linux-mm@kvack.org>; Tue, 17 Mar 2009 15:09:55 -0400 (EDT)
Date: Tue, 17 Mar 2009 12:03:55 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [aarcange@redhat.com: [PATCH] fork vs gup(-fast) fix]
In-Reply-To: <20090317184647.GC28447@random.random>
Message-ID: <alpine.LFD.2.00.0903171155090.3082@localhost.localdomain>
References: <200903141620.45052.nickpiggin@yahoo.com.au> <20090316223612.4B2A.A69D9226@jp.fujitsu.com> <alpine.LFD.2.00.0903161739310.3082@localhost.localdomain> <20090317121900.GD20555@random.random> <alpine.LFD.2.00.0903170929180.3082@localhost.localdomain>
 <alpine.LFD.2.00.0903170950410.3082@localhost.localdomain> <20090317171049.GA28447@random.random> <alpine.LFD.2.00.0903171023390.3082@localhost.localdomain> <alpine.LFD.2.00.0903171048100.3082@localhost.localdomain> <alpine.LFD.2.00.0903171112470.3082@localhost.localdomain>
 <20090317184647.GC28447@random.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Nick Piggin <npiggin@novell.com>, Hugh Dickins <hugh@veritas.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>



On Tue, 17 Mar 2009, Andrea Arcangeli wrote:
> 
> I don't think you can tackle this from add_to_swap because the page
> may be in the swapcache well before gup runs (gup(write=1) can map the
> swapcache as exclusive and read-write in the pte).

If it's in the swap cache, it should be mapped read-only, and gup(write=1) 
will do the COW break and un-swapcache it.

When can it be writably in the swap cache? The write-only thing is the one 
we use to invalidate stale swap cache entries, and when we mark those 
pages writable (in do_wp_page or do_swap_page) we always remove the page 
from the swap cache at the same time.

Or is there some other path I missed?

> My preference is still to keeps pages with elevated refcount pinned in
> the ptes like 2.6.7 did, that will allow do_wp_page to takeover only
> pages with page_count not elevated without risk of calling do_wp_page
> on any page under gup.

I agree that that would also work - and be even simpler. If done right, we 
can even avoid clearing the dirty bit (in page_mkclean()) for such pages, 
and now it works for _all_ pages, not just anonymous pages.

IOW, even if you had a shared mapping and were to GUP() those pages for 
writing, they'd _stay_ dirty until you free'd them - no need to re-dirty 
them in case somebody did IO on them. 

> Only worry I have now is how to compare count
> with mapcount when both can change under us if mapcount > 1, but if
> you meant page_mapcount in add_to_swap as I think, that logic in
> add_to_swap would have the same problem and so it needs a solution for
> doing a coherent/safe comparison too.

I don't think you can use just mapcount on its own - you have to compare 
it to page_count(). Otherwise perfectly normal (non-gup) pages will 
trigger, since that page count is the only thing that differs between the 
two cases.

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
