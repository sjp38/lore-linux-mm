Date: Fri, 22 Sep 2000 08:20:25 +0200 (CEST)
From: Mike Galbraith <mikeg@weiden.de>
Subject: Re: 2.4.0-test9-pre4: __alloc_pages(...) try_again:
In-Reply-To: <39CA50B0.77A2CD84@norran.net>
Message-ID: <Pine.Linu.4.10.10009220754250.1064-100000@mikeg.weiden.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Roger Larsson <roger.larsson@norran.net>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 21 Sep 2000, Roger Larsson wrote:

> Mike Galbraith wrote:
> > 
> > On Wed, 20 Sep 2000, Roger Larsson wrote:
> > 
> > > Hi,
> > >
> > >
> > > Trying to find out why test9-pre4 freezes with mmap002
> > > I added a counter for try_again loops.
> > >
> > > ... __alloc_pages(...)
> > >
> > >         int direct_reclaim = 0;
> > >         unsigned int gfp_mask = zonelist->gfp_mask;
> > >         struct page * page = NULL;
> > > +       int try_again_loops = 0;
> > >
> > > - - -
> > >
> > > +         printk("VM: sync kswapd (direct_reclaim: %d) try_again #
> > > %d\n",
> > > +                direct_reclaim, ++try_again_loops);
> > >                         wakeup_kswapd(1);
> > >                         goto try_again;
> > >
> > >
> > > Result was surprising:
> > >   direct_reclaim was 1.
> > >   try_again_loops did never stop increasing (note: it is not static,
> > >   and should restart from zero after each success)
> > >
> > > Why does this happen?
> > > a) kswapd did not succeed in freeing a suitable page?
> > > b) __alloc_pages did not succeed in grabbing the page?
> > 
> > Hi Roger,
> > 
> > A trace of locked up box shows endless repetitions of kswapd aparantly
> > failing to free anything.  What I don't see in the trace snippet below
> > is reclaim_page().  I wonder if this test in __alloc_pages_limit()
> > should include an || direct_reclaim.
> 
> When I have run into this problem I have had no inactive_clean pages =>
> reclaim_page() should not work... :-(
> That is your situation too...

(Yup, after further reading I quickly ceased wondering about that;)

Much more interesting (i hope) is that refill_inactive() _is_ present
2923 times, we're oom as heck, and neither shm_swap() nor swap_out()
is ever reached in 1048533 lines of trace.  The only way I can see that
this can happen is if refill_inactive_scan() eats all count.

:-) I'm currently wo^Handering what count is and if I shouldn't try
checking nr_inactive_clean_pages() before exiting the loop.

	-Mike


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
