Date: Sun, 29 Jul 2001 17:31:00 +0200 (CEST)
From: Mike Galbraith <mikeg@wen-online.de>
Subject: Re: 2.4.8-pre1 and dbench -20% throughput
In-Reply-To: <01072916102900.00341@starship>
Message-ID: <Pine.LNX.4.33.0107291713050.336-100000@mikeg.weiden.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@bonn-fries.net>
Cc: Linus Torvalds <torvalds@transmeta.com>, Marcelo Tosatti <marcelo@conectiva.com.br>, linux-mm@kvack.org, Rik van Riel <riel@conectiva.com.br>, Andrew Morton <akpm@zip.com.au>, Steven Cole <elenstev@mesatop.com>, Roger Larsson <roger.larsson@skelleftea.mail.telia.com>
List-ID: <linux-mm.kvack.org>

On Sun, 29 Jul 2001, Daniel Phillips wrote:

> On Saturday 28 July 2001 22:26, Linus Torvalds wrote:
> > On Sat, 28 Jul 2001, Daniel Phillips wrote:
> > > Here is what I think is happening on a typical burst of small,
> > > non-page aligned reads:
> > >
> > >   - Page is read the 1st time: age = 2, inactive
> > >   - Page is read the second time: age = 5, active
> > >   - Two more reads immediately on the same page: age = 11
> >
> > No.
> >
> > We only mark the page referenced when we read it, we don't actually
> > increment the age.
>
> For already-cached pages we have:
>
>    do_generic_file_read->__find_page_nolock->age_page_up
>
> I haven't checked a running kernel yet to see whether pages really do
> get aged the way I described, but I'll do it soon.  My plan is to 'tag'
> selected pages and trace them through the system to see what actually
> happens to them.
>
> When I looked at age_page_up, I saw an anomaly:
>
> 	void age_page_up_nolock(struct page * page)
> 	{
> 	 	if (!page->age)   /* wrong */
> 			activate_page_nolock(page);
>
> 		page->age += PAGE_AGE_ADV;
> 		if (page->age > PAGE_AGE_MAX)
> 			page->age = PAGE_AGE_MAX;
> 	}
>
> The !page->age test was fine when all the ages on the inactive list
> were zero, it's not fine with the use-once patch.  When inactive, the
> sense of !page->age is now "on trial", whether the page got that way by
> being accessed the first time or aged all the way to zero.  The state
> change from !page->age to page->age == START_AGE allows used-often
> pages to be detected, again, while on the inactive list.  Yes, I could
> have used a real state flag for this, or a separate queue, but that
> would have been a more invasive change.
>
> First I tried this:
>
> - 	if (!page->age)
> + 	if (!PageActive(page))
>
> Performance on dbench went way down.  So I did the obvious thing:
>
> -	if (!page->age)
> -		activate_page_nolock(page);
>
> This produced a distinct improvement, bringing 2.4.7 use-once
> performance on dbench up to nearly as good as drop-behind.  Better, the
> performance on my make/grep load for 2.4.7+use.once was also improved,
> coming very close to what I saw on 2.4.5+use.once.
>
> So this is promising.  What it does is bring age_page_up more in line
> with my theoretical model, that is, leaving each page to run its entire
> course on the inactive queue and relying on the Referenced bit to tell
> inactive_scan whether to rescue or continue the eviction process.
>
> > Maybe the problem is that use-once works on accesses, not on ages?
>
> I'm convinced that, for the inactive queue, relying on accesses is
> right.  My theory is that aging has the sole function of determining
> which pages should be tested for inactivity, and I suspect the current
> formula for aging doesn't do that optimally.  As soon as the more
> obvious problems settle down I'd like to take a look at the aging
> calculations and active scanning policy.

FWIW, I'm seeing that referenced is causing problems.  Running plain
jane Bonnie (the old one) I see (huge gobs of) pages being activated
when they are not in pre-use_once kernels.  Also FWIW, if I use my own
changes to buffer.c (which make write throttling work a bit too well;)
I see the problem _exaggerated_ (ie it's timing related, especially when
Bonnie is in the write intelligently phase).  I've eliminated most of
the problem here by means too ugly to be of any interest ;-)

If you grab a copy of xmm (Zlatko's utility for graphical display of
the mm lists), you'll see the problem instantly.  You'll see it with
virgin source as soon as the rewrite test starts.  With virgin source,
when Bonnie starts doing 'writing intellgently', you'll see the problem
BIGTIME.

There is also a problem with page_launder() in that the only thing
which stops it is hitting a page with buffers.  This is only a big
problem only on machines with tons of ram though.

	-Mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
