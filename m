Date: Tue, 2 May 2000 20:47:57 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: Oops in __free_pages_ok (pre7-1) (Long) (backtrace)
In-Reply-To: <390F98C7.79DDB276@sgi.com>
Message-ID: <Pine.LNX.4.10.10005022040330.778-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rajagopal Ananthanarayanan <ananth@sgi.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Tue, 2 May 2000, Rajagopal Ananthanarayanan wrote:
> -------------
> 
> I ran into a BUG in __free_pages_ok which checks:
> 
> ----------
>         if (PageSwapCache(page))
>                 BUG();
> ----------
> 
> The  call to free the page was from try_to_swap_out():
> 
> ----------
>         /*
>          * Is the page already in the swap cache? If so, then
>          * we can just drop our reference to it without doing
>          * any IO - it's already up-to-date on disk.
>          *
>          * Return 0, as we didn't actually free any real
>          * memory, and we should just continue our scan.
>          */
>         if (PageSwapCache(page)) {
>                 entry.val = page->index;
>                 swap_duplicate(entry);
>                 set_pte(page_table, swp_entry_to_pte(entry));
> drop_pte:
>                 vma->vm_mm->rss--;
>                 flush_tlb_page(vma, address);
>                 __free_page(page);
>                 goto out_failed;
>         }

Wow.

That code definitely looks buggy.

Looking at the whole try_to_swap_out() in this light shows how it messes
with a _lot_ of page information without holding the page lock. I thought
we fixed this once already, but maybe not.

In try_to_swap_out(), earlier it does a

	if (PageLocked(page))
		goto out_failed;

and that really is wrong - it should do a

	if (TryLockPage(page))
		goto out_failed;

and do all the rest with the page locked so that there are no races on
changing the state of the page (and then unlock just before actually
returning, or freeing the page).

As far as I can tell, this is a real bug, and has absolutely nothing to do
with the swap entry cache. It may be that the swap entry cache code just
changed timings for some people enough to show the race.

But maybe I've overlooked something. Anybody else have comments on this?

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
