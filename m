Message-ID: <390FC5B6.211AB236@sgi.com>
Date: Tue, 02 May 2000 23:22:46 -0700
From: Rajagopal Ananthanarayanan <ananth@sgi.com>
MIME-Version: 1.0
Subject: Re: Oops in __free_pages_ok (pre7-1) (Long) (backtrace)
References: <200005030526.WAA59352@google.engr.sgi.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Kanoj Sarcar wrote:

> >
> > Wow.
> >
> > That code definitely looks buggy.
> >
> > Looking at the whole try_to_swap_out() in this light shows how it messes
> > with a _lot_ of page information without holding the page lock. I thought
> > we fixed this once already, but maybe not.
> >
> > In try_to_swap_out(), earlier it does a
> >
> >       if (PageLocked(page))
> >               goto out_failed;
> >
> > and that really is wrong - it should do a
> >
> >       if (TryLockPage(page))
> >               goto out_failed;
> 
> Umm, I am not saying this is not a good idea, but maybe code that
> try_to_swap_out() invokes (like filemap_swapout etc) need to be
> taught that the incoming page has already been locked.

Dunno. I tend to agree with Linus. Fundamentally, how can any
code examine & change page state (flags, etc). if the code
does not hold the page lock?

> 
> Nonetheless, unless you show me a possible scenario that will lead
> to the observed panic, I am skeptical that this is the real problem.

Look at trace I sent out. Basically it goes swap_out() -> swap_out_mm() ->
swap_out_vma() -> try_to_swap_out() -> __free_pages_ok().

1. swap_out select process & vm area within the process to swapout.
2. swap_out_mm selects an "address" within the mm.
3. swap_out_vma converts address to pgd.
4. try_to_swap_out takes pgd looks at the "software" state in "struct page".

Step 2 is about the earliest you can lock the victim page;
it isn't locked there. Step 3 doesn't lock it either. Step 4
as pointed out, explicitly avoids pages which are locked,
but doesn't lock the page!

Some more clarifications below:

> 
> Lets just talk about swapcache pages (since the problem happened with
> that type), and lets forget swapfile deletion, I am pretty sure Ananth
> was not trying that. [ ... ]

No, I didn't try to remove swap.

> Anyway, I will try to think if there are more race conditions possible.
> Ananth, was there shared memory programs in your test suite? Also, if you
> have any success in reproducing this, let us know.

I don't think there were any shm stuff in the tests I was running
(again, AFAICT, diff was the only thing running; previous pages
in memory weren't likely from any shm segments). I haven't
reproduced it even a second time. Will let you know.

OTOH, if try_to_swap_out is so broken why aren't we seeing
these problems more often? Or, from other reports in l-k are we?

ananth.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
