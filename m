From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <199906152102.OAA22739@google.engr.sgi.com>
Subject: Re: filecache/swapcache questions
Date: Tue, 15 Jun 1999 14:02:07 -0700 (PDT)
In-Reply-To: <Pine.LNX.4.03.9906152223590.534-100000@mirkwood.nl.linux.org> from "Rik van Riel" at Jun 15, 99 10:24:38 pm
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@nl.linux.org>
Cc: linux-mm@kvack.org, sct@redhat.com
List-ID: <linux-mm.kvack.org>

> 
> On Tue, 15 Jun 1999, Kanoj Sarcar wrote:
> 
> > I still can't see how this can happen. Note that try_to_swap_out
> > either does a get_swap_page/swap_duplicate on the swaphandle,
> > which gets the swap_count up to 2, or if it sees a page already in
> > the swapcache, it just does a swap_duplicate. Either way, if the
> > only reference on the physical page is from the swapcache, there
> > will be at least one more reference on the swap page other than
> > due to the swapcache. What am I missing?
> 
> When the swap I/O (if needed) finishes, the page count is
> decreased by one.
>

Never mind, I was being blind before. This is why shrink_mmap 
has code that reads:

                if (PageSwapCache(page)) {
                        if (referenced && swap_count(page->offset) != 1)
                                continue;
                        delete_from_swap_cache(page);
                        return 1;
                }
 
Say a process is just about to execute exit()/munmap(), and kswapd 
steals a page from it, updating the pte with the swaphandle.
zap_pte_range -> free_pte will just free the swaphandle, possibly
leaving the page with a refcount of 1 (from the swapcache) and
a swappage count of 1 (from the swapcache again). shrink_mmap
recognizes the page/swaphandle will not be used by anyone and
frees these up.

Thanks for the pointers, Rik.

Kanoj
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
