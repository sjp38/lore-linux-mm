Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 9A5F56B004D
	for <linux-mm@kvack.org>; Tue, 17 Mar 2009 15:35:56 -0400 (EDT)
Date: Tue, 17 Mar 2009 20:35:38 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [aarcange@redhat.com: [PATCH] fork vs gup(-fast) fix]
Message-ID: <20090317193538.GD28447@random.random>
References: <alpine.LFD.2.00.0903161739310.3082@localhost.localdomain> <20090317121900.GD20555@random.random> <alpine.LFD.2.00.0903170929180.3082@localhost.localdomain> <alpine.LFD.2.00.0903170950410.3082@localhost.localdomain> <20090317171049.GA28447@random.random> <alpine.LFD.2.00.0903171023390.3082@localhost.localdomain> <alpine.LFD.2.00.0903171048100.3082@localhost.localdomain> <alpine.LFD.2.00.0903171112470.3082@localhost.localdomain> <20090317184647.GC28447@random.random> <alpine.LFD.2.00.0903171155090.3082@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.0903171155090.3082@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Nick Piggin <npiggin@novell.com>, Hugh Dickins <hugh@veritas.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 17, 2009 at 12:03:55PM -0700, Linus Torvalds wrote:
> If it's in the swap cache, it should be mapped read-only, and gup(write=1) 
> will do the COW break and un-swapcache it.

It may turn it read-write instead of COW break and un-swapcache.

   if (write_access && reuse_swap_page(page)) {
      pte = maybe_mkwrite(pte_mkdirty(pte), vma);

This is done to avoid fragmenting the swap device.

> I agree that that would also work - and be even simpler. If done right, we 
> can even avoid clearing the dirty bit (in page_mkclean()) for such pages, 
> and now it works for _all_ pages, not just anonymous pages.
> 
> IOW, even if you had a shared mapping and were to GUP() those pages for 
> writing, they'd _stay_ dirty until you free'd them - no need to re-dirty 
> them in case somebody did IO on them. 

I agree in principle, if the VM stays away from pages under GUP
theoretically the dirty bit shouldn't be transferred to the PG_dirty
of the page until after the I/O is complete, so the dirty bit set by
gup in the pte may be enough. Not sure if there are other places that
could transfer the dirty bit of the pte before the gup user releases
the page-pin.

> I don't think you can use just mapcount on its own - you have to compare 
> it to page_count(). Otherwise perfectly normal (non-gup) pages will 
> trigger, since that page count is the only thing that differs between the 
> two cases.

Yes, page_count shall be compared with page_mapcount. My worry is only
that both can change from under us if mapcount > 1 (not enough to hold
PT lock to be sure mapcount/count is stable if mapcount > 1).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
