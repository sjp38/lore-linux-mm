Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 4CFF66B007B
	for <linux-mm@kvack.org>; Wed, 15 Sep 2010 20:10:52 -0400 (EDT)
Received: from wpaz13.hot.corp.google.com (wpaz13.hot.corp.google.com [172.24.198.77])
	by smtp-out.google.com with ESMTP id o8G0AnGC006061
	for <linux-mm@kvack.org>; Wed, 15 Sep 2010 17:10:49 -0700
Received: from gwj18 (gwj18.prod.google.com [10.200.10.18])
	by wpaz13.hot.corp.google.com with ESMTP id o8G0Aio9031392
	for <linux-mm@kvack.org>; Wed, 15 Sep 2010 17:10:49 -0700
Received: by gwj18 with SMTP id 18so646338gwj.2
        for <linux-mm@kvack.org>; Wed, 15 Sep 2010 17:10:44 -0700 (PDT)
Date: Wed, 15 Sep 2010 17:10:36 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] fix swapin race condition
In-Reply-To: <20100915234237.GR5981@random.random>
Message-ID: <alpine.DEB.2.00.1009151703060.7332@tigran.mtv.corp.google.com>
References: <20100903153958.GC16761@random.random> <alpine.LSU.2.00.1009051926330.12092@sister.anvils> <alpine.LSU.2.00.1009151534060.5630@tigran.mtv.corp.google.com> <20100915234237.GR5981@random.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Greg KH <greg@kroah.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 16 Sep 2010, Andrea Arcangeli wrote:
> On Wed, Sep 15, 2010 at 04:02:24PM -0700, Hugh Dickins wrote:
> > I had an afterthought, something I've not thought through fully, but am
> > reminded of by Greg's mail for stable: is your patch incomplete?  Just
> > as it's very unlikely but conceivable the pte_same() test is inadequate,
> > isn't the PageSwapCache() test you've added to do_swap_page() inadequate?
> > Doesn't it need a "page_private(page) == entry.val" test too?
> > 
> > Just as it's conceivable that the same swap has got reused (either via
> > try_to_free_swap or via swapoff+swapon) for a COWed version of the page
> > in that pte slot meanwhile, isn't it conceivable that the page we hold
> 
> Yes, before the fix, the page could be removed from swapcache despite
> being pinned, and the cow copy could reuse the same swap entry and be
> unmapped again so breaking the pte_same check.
> 
> > while waiting for pagelock, has got freed from swap then reallocated to
> > elsewhere on swap meanwhile?  Which, together with your scenario (and I
> > suspect the two unlikelihoods are not actually to be multiplied), would
> > still lead to the wrong result, unless we add the further test.
> 
> For this to happen the page would need to be removed from swapcache
> and then added back to swapcache to a different swap entry. But if
> that happens the "page_table" pointer would be set to a different swap
> entry too, so failing the pte_same check. If the swap entry of the
> page changes the page_table will change with it, so the pte_same check
> will fail in the first place, so at first glance it looks like
> checking the page_private isn't necessary and the pte_same check on
> the page_table is enough.

I agree that if my scenario happened on its own, the pte_same check
would catch it.  But if my scenario happens along with your scenario
(and I'm thinking that the combination is not that much less likely
than either alone), then the PageSwapCache test will succeed and the
pte_same test will succeed, but we're still putting the wrong page into
the pte, since this page is now represented by a different swap entry
(and the page that should be there by our original swap entry).

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
