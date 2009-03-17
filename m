Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id DD94F6B003D
	for <linux-mm@kvack.org>; Tue, 17 Mar 2009 14:47:09 -0400 (EDT)
Date: Tue, 17 Mar 2009 19:46:47 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [aarcange@redhat.com: [PATCH] fork vs gup(-fast) fix]
Message-ID: <20090317184647.GC28447@random.random>
References: <200903141620.45052.nickpiggin@yahoo.com.au> <20090316223612.4B2A.A69D9226@jp.fujitsu.com> <alpine.LFD.2.00.0903161739310.3082@localhost.localdomain> <20090317121900.GD20555@random.random> <alpine.LFD.2.00.0903170929180.3082@localhost.localdomain> <alpine.LFD.2.00.0903170950410.3082@localhost.localdomain> <20090317171049.GA28447@random.random> <alpine.LFD.2.00.0903171023390.3082@localhost.localdomain> <alpine.LFD.2.00.0903171048100.3082@localhost.localdomain> <alpine.LFD.2.00.0903171112470.3082@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.0903171112470.3082@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Nick Piggin <npiggin@novell.com>, Hugh Dickins <hugh@veritas.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 17, 2009 at 11:19:59AM -0700, Linus Torvalds wrote:
> 
> 
> On Tue, 17 Mar 2009, Linus Torvalds wrote:
> > 
> > This problem is actually pretty easy to fix for anonymous pages: since the 
> > act of pinning (for writes) should have done all the COW stuff and made 
> > sure the page is not in the swap cache, we only need to avoid adding it 
> > back.
> 
> An alternative approach would have been to just count page pinning as 
> being a "referenced", which to some degree would be even more logical (we 
> don't set the referenced flag when we look those pages up). That would 
> also affect pages that were get_user_page'd just for reading, which might 
> be seen as an additional bonus.
> 
> The "don't turn pinned pages into swap cache pages" is a somewhat more 
> direct patch, though. It gives more obvious guarantees about the lifetime 
> behaviour of anon pages wrt get_user_pages[_fast]().. 

I don't think you can tackle this from add_to_swap because the page
may be in the swapcache well before gup runs (gup(write=1) can map the
swapcache as exclusive and read-write in the pte). So then what
happens is again that the VM unmaps the page, do_swap_page map it as
readonly swapcache (so far so good), and the do_wp_page copies the
page under O_DIRECT read again.

The off by one is most certain as it's invoked by the VM but that's an
implementation detail not relevant for this discussion agreed, and I
guess you also meant page_mapcount instead of page_mapped or I think
shared pages would stop being swapped out. That is more relevant
because of some worry I have in the comparison between page count and
mapcount, see below.

My preference is still to keeps pages with elevated refcount pinned in
the ptes like 2.6.7 did, that will allow do_wp_page to takeover only
pages with page_count not elevated without risk of calling do_wp_page
on any page under gup. Only worry I have now is how to compare count
with mapcount when both can change under us if mapcount > 1, but if
you meant page_mapcount in add_to_swap as I think, that logic in
add_to_swap would have the same problem and so it needs a solution for
doing a coherent/safe comparison too.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
