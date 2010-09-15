Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id C0EA36B0078
	for <linux-mm@kvack.org>; Wed, 15 Sep 2010 19:02:44 -0400 (EDT)
Received: from kpbe12.cbf.corp.google.com (kpbe12.cbf.corp.google.com [172.25.105.76])
	by smtp-out.google.com with ESMTP id o8FN2YNV017900
	for <linux-mm@kvack.org>; Wed, 15 Sep 2010 16:02:41 -0700
Received: from gxk10 (gxk10.prod.google.com [10.202.11.10])
	by kpbe12.cbf.corp.google.com with ESMTP id o8FN2F5d003053
	for <linux-mm@kvack.org>; Wed, 15 Sep 2010 16:02:32 -0700
Received: by gxk10 with SMTP id 10so319150gxk.34
        for <linux-mm@kvack.org>; Wed, 15 Sep 2010 16:02:32 -0700 (PDT)
Date: Wed, 15 Sep 2010 16:02:24 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] fix swapin race condition
In-Reply-To: <alpine.LSU.2.00.1009051926330.12092@sister.anvils>
Message-ID: <alpine.LSU.2.00.1009151534060.5630@tigran.mtv.corp.google.com>
References: <20100903153958.GC16761@random.random> <alpine.LSU.2.00.1009051926330.12092@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Greg KH <greg@kroah.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 5 Sep 2010, Hugh Dickins wrote:
> On Fri, 3 Sep 2010, Andrea Arcangeli wrote:
> > From: Andrea Arcangeli <aarcange@redhat.com>
> > 
> > The pte_same check is reliable only if the swap entry remains pinned
> > (by the page lock on swapcache). We've also to ensure the swapcache
> > isn't removed before we take the lock as try_to_free_swap won't care
> > about the page pin.
> > 
> > Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> 
> Acked-by: Hugh Dickins <hughd@google.com>
> 
> Yes, it's a great little find, and long predates the KSM hooks you've
> had to adjust.  It does upset me (aesthetically) that the KSM case now
> intrudes into do_swap_swap() much more than it used to; but I have not
> come up with a better solution, so yes, let's go forward with this.

I had an afterthought, something I've not thought through fully, but am
reminded of by Greg's mail for stable: is your patch incomplete?  Just
as it's very unlikely but conceivable the pte_same() test is inadequate,
isn't the PageSwapCache() test you've added to do_swap_page() inadequate?
Doesn't it need a "page_private(page) == entry.val" test too?

Just as it's conceivable that the same swap has got reused (either via
try_to_free_swap or via swapoff+swapon) for a COWed version of the page
in that pte slot meanwhile, isn't it conceivable that the page we hold
while waiting for pagelock, has got freed from swap then reallocated to
elsewhere on swap meanwhile?  Which, together with your scenario (and I
suspect the two unlikelihoods are not actually to be multiplied), would
still lead to the wrong result, unless we add the further test.

I apologize if I'm holding up your stable fix, and just vying against
you in a "world's most unlikely VM race" competition, but I don't at
present see what prevents this variant.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
