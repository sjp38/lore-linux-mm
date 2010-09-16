Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 3942C6B0078
	for <linux-mm@kvack.org>; Thu, 16 Sep 2010 17:03:52 -0400 (EDT)
Date: Thu, 16 Sep 2010 23:03:49 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] fix swapin race condition
Message-ID: <20100916210349.GU5981@random.random>
References: <20100903153958.GC16761@random.random>
 <alpine.LSU.2.00.1009051926330.12092@sister.anvils>
 <alpine.LSU.2.00.1009151534060.5630@tigran.mtv.corp.google.com>
 <20100915234237.GR5981@random.random>
 <alpine.DEB.2.00.1009151703060.7332@tigran.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1009151703060.7332@tigran.mtv.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hughd@google.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Greg KH <greg@kroah.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Hugh,

On Wed, Sep 15, 2010 at 05:10:36PM -0700, Hugh Dickins wrote:
> I agree that if my scenario happened on its own, the pte_same check
> would catch it.  But if my scenario happens along with your scenario
> (and I'm thinking that the combination is not that much less likely
> than either alone), then the PageSwapCache test will succeed and the
> pte_same test will succeed, but we're still putting the wrong page into
> the pte, since this page is now represented by a different swap entry
> (and the page that should be there by our original swap entry).

If I understood well you're saying that it is possible that this
BUG_ON triggers:

   page_table = pte_offset_map_lock(mm, pmd, address, &ptl);
   BUG_ON(page_private(page) != entry.val && pte_same(page_table, orig_pte));
   if (unlikely(!pte_same(*page_table, orig_pte)))

I still don't get it (that doesn't make me right though).

I'll try to rephrase my argument: if the page was swapped in from
swapcache by swapoff and then swapon runs again and the page is added
to swapcache to a different swap entry, in between the
lookup_swap_cache and the lock_page, the pte_same(*page_table,
orig_pte) in pte_same should always fail in the first place (so
without requiring the page_private(page) != entry.val check).

If the page is found mapped during pte_same the pte_same check will
fail (pte_present first of all). If the page got unmapped and
page_private(page) != entry.val, the "entry" == "orig_pte" will be
different to what we read in *page_table at the above BUG_ON line (the
page has to be unmapped before pte_same check can succeed, but if gets
unmapped the new swap entry will be written in the page_table and it
won't risk to succeed the pte_same check).

If the page wasn't mapped when it was removed from swapcache, it can't
be added to swapcache at all because it was pinned: because only free
pages (during swapin) or mapped pages (during swapout) can be added to
swapcache.

If I'm missing something a trace of the exact scenario would help to
clarify your point.

Thanks!
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
