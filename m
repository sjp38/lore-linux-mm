From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <200005030526.WAA59352@google.engr.sgi.com>
Subject: Re: Oops in __free_pages_ok (pre7-1) (Long) (backtrace)
Date: Tue, 2 May 2000 22:26:48 -0700 (PDT)
In-Reply-To: <Pine.LNX.4.10.10005022040330.778-100000@penguin.transmeta.com> from "Linus Torvalds" at May 02, 2000 08:47:57 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Rajagopal Ananthanarayanan <ananth@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> 
> 
> On Tue, 2 May 2000, Rajagopal Ananthanarayanan wrote:
> > -------------
> > 
> > I ran into a BUG in __free_pages_ok which checks:
> > 
> > ----------
> >         if (PageSwapCache(page))
> >                 BUG();
> > ----------
> > 
> > The  call to free the page was from try_to_swap_out():
> > 
> > ----------
> >         /*
> >          * Is the page already in the swap cache? If so, then
> >          * we can just drop our reference to it without doing
> >          * any IO - it's already up-to-date on disk.
> >          *
> >          * Return 0, as we didn't actually free any real
> >          * memory, and we should just continue our scan.
> >          */
> >         if (PageSwapCache(page)) {
> >                 entry.val = page->index;
> >                 swap_duplicate(entry);
> >                 set_pte(page_table, swp_entry_to_pte(entry));
> > drop_pte:
> >                 vma->vm_mm->rss--;
> >                 flush_tlb_page(vma, address);
> >                 __free_page(page);
> >                 goto out_failed;
> >         }
> 
> Wow.
> 
> That code definitely looks buggy.
> 
> Looking at the whole try_to_swap_out() in this light shows how it messes
> with a _lot_ of page information without holding the page lock. I thought
> we fixed this once already, but maybe not.
> 
> In try_to_swap_out(), earlier it does a
> 
> 	if (PageLocked(page))
> 		goto out_failed;
> 
> and that really is wrong - it should do a
> 
> 	if (TryLockPage(page))
> 		goto out_failed;

Umm, I am not saying this is not a good idea, but maybe code that 
try_to_swap_out() invokes (like filemap_swapout etc) need to be 
taught that the incoming page has already been locked. 

Nonetheless, unless you show me a possible scenario that will lead
to the observed panic, I am skeptical that this is the real problem.

Lets just talk about swapcache pages (since the problem happened with
that type), and lets forget swapfile deletion, I am pretty sure Ananth
was not trying that. In this restricted situation, I _think_ you can 
not theorize what the problem is. That is, if all code that add/delete
pages from the swap cache make sure they never delete a "shared" page
from the scache (as determined by is_page_shared). This is because 
the process that kswapd is looking at already ensures that the page is
"shared". The only code that does delete "shared" pages from the scache
is shrink_mmap, but if a process already has a page-reference, shrink_mmap
can not touch that page. Also, most process level code that takes a
page out from the swapcache is interlocked out because kswapd is
holding the vmlist/page_table_lock.

Anyway, I will try to think if there are more race conditions possible.
Ananth, was there shared memory programs in your test suite? Also, if you
have any success in reproducing this, let us know.

Kanoj


> 
> and do all the rest with the page locked so that there are no races on
> changing the state of the page (and then unlock just before actually
> returning, or freeing the page).
> 
> As far as I can tell, this is a real bug, and has absolutely nothing to do
> with the swap entry cache. It may be that the swap entry cache code just
> changed timings for some people enough to show the race.
> 
> But maybe I've overlooked something. Anybody else have comments on this?
> 
> 		Linus
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux.eu.org/Linux-MM/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
