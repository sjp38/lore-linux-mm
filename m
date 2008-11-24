Subject: Re: [PATCH 6/8] mm: remove try_to_munlock from vmscan
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <Pine.LNX.4.64.0811232202040.4142@blonde.site>
References: <Pine.LNX.4.64.0811232151400.3748@blonde.site>
	 <Pine.LNX.4.64.0811232202040.4142@blonde.site>
Content-Type: text/plain
Date: Mon, 24 Nov 2008 12:34:52 -0500
Message-Id: <1227548092.6937.23.camel@lts-notebook>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 2008-11-23 at 22:03 +0000, Hugh Dickins wrote:
> An unfortunate feature of the Unevictable LRU work was that reclaiming an
> anonymous page involved an extra scan through the anon_vma: to check that
> the page is evictable before allocating swap, because the swap could not
> be freed reliably soon afterwards.
> 
> Now try_to_free_swap() has replaced remove_exclusive_swap_page(), that's
> not an issue any more: remove try_to_munlock() call from shrink_page_list(),
> leaving it to try_to_munmap() to discover if the page is one to be culled
> to the unevictable list - in which case then try_to_free_swap().
> 
> Update unevictable-lru.txt to remove comments on the try_to_munlock()
> in shrink_page_list(), and shorten some lines over 80 columns.


Hugh:  Thanks for doing this.   Another item on my to-do list, as noted
in the document.

> 
> Signed-off-by: Hugh Dickins <hugh@veritas.com>
> ---
> I've not tested this against whatever test showed the need for that
> try_to_munlock() in shrink_page_list() in the first place.  Rik or Lee,
> please, would you have the time to run that test on the next -mm that has
> this patch in, to check that I've not messed things up?  Alternatively,
> please point me to such a test - but I think you've been targeting
> larger machines than I have access to - thanks.

I will rerun my test workload when this shows up in mmotm.  

I added the extra try_to_munlock() [TODO:  maybe "page_mlocked()" is
better name?] to prevent using swap space for pages that were destined
for the unevictable list.  This is more likely, I think, now that we've
removed the lru_drain_all() calls from the mlock[all]() handlers.  Back
when I added this, I wasn't sure that we could reliably remove swap from
a page with an arbitrary number of mappers.  Rik had warned against
making that assumption.

Lee

<snip>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
