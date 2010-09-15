Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id D5D586B007B
	for <linux-mm@kvack.org>; Wed, 15 Sep 2010 19:42:45 -0400 (EDT)
Date: Thu, 16 Sep 2010 01:42:37 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] fix swapin race condition
Message-ID: <20100915234237.GR5981@random.random>
References: <20100903153958.GC16761@random.random>
 <alpine.LSU.2.00.1009051926330.12092@sister.anvils>
 <alpine.LSU.2.00.1009151534060.5630@tigran.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.1009151534060.5630@tigran.mtv.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hughd@google.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Greg KH <greg@kroah.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Sep 15, 2010 at 04:02:24PM -0700, Hugh Dickins wrote:
> I had an afterthought, something I've not thought through fully, but am
> reminded of by Greg's mail for stable: is your patch incomplete?  Just
> as it's very unlikely but conceivable the pte_same() test is inadequate,
> isn't the PageSwapCache() test you've added to do_swap_page() inadequate?
> Doesn't it need a "page_private(page) == entry.val" test too?
> 
> Just as it's conceivable that the same swap has got reused (either via
> try_to_free_swap or via swapoff+swapon) for a COWed version of the page
> in that pte slot meanwhile, isn't it conceivable that the page we hold

Yes, before the fix, the page could be removed from swapcache despite
being pinned, and the cow copy could reuse the same swap entry and be
unmapped again so breaking the pte_same check.

> while waiting for pagelock, has got freed from swap then reallocated to
> elsewhere on swap meanwhile?  Which, together with your scenario (and I
> suspect the two unlikelihoods are not actually to be multiplied), would
> still lead to the wrong result, unless we add the further test.

For this to happen the page would need to be removed from swapcache
and then added back to swapcache to a different swap entry. But if
that happens the "page_table" pointer would be set to a different swap
entry too, so failing the pte_same check. If the swap entry of the
page changes the page_table will change with it, so the pte_same check
will fail in the first place, so at first glance it looks like
checking the page_private isn't necessary and the pte_same check on
the page_table is enough.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
