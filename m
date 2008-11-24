Date: Mon, 24 Nov 2008 19:29:29 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH 6/8] mm: remove try_to_munlock from vmscan
In-Reply-To: <1227548092.6937.23.camel@lts-notebook>
Message-ID: <Pine.LNX.4.64.0811241928260.3700@blonde.site>
References: <Pine.LNX.4.64.0811232151400.3748@blonde.site>
 <Pine.LNX.4.64.0811232202040.4142@blonde.site> <1227548092.6937.23.camel@lts-notebook>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 24 Nov 2008, Lee Schermerhorn wrote:
> On Sun, 2008-11-23 at 22:03 +0000, Hugh Dickins wrote:
> 
> Hugh:  Thanks for doing this.   Another item on my to-do list, as noted
> in the document.

Taking the page_count() check out of remove_exclusive_swap_page()
has been on my to-do list for about four years, so I'd have been
extra ashamed if you got there before me.  Most of that time I'd
been thinking we needed a page_mapcount() check instead, it's only
recently I've realized that it was silly to be requiring "exclusive"
in the first place.

> > 
> > Signed-off-by: Hugh Dickins <hugh@veritas.com>
> > ---
> > I've not tested this against whatever test showed the need for that
> > try_to_munlock() in shrink_page_list() in the first place.  Rik or Lee,
> > please, would you have the time to run that test on the next -mm that has
> > this patch in, to check that I've not messed things up?  Alternatively,
> > please point me to such a test - but I think you've been targeting
> > larger machines than I have access to - thanks.
> 
> I will rerun my test workload when this shows up in mmotm.  

Great, thanks a lot.

> 
> I added the extra try_to_munlock() [TODO:  maybe "page_mlocked()" is
> better name?]

I think it's a much better name, so left in that part of the TODO;
but for some reason felt I'd better leave that change to you.

> to prevent using swap space for pages that were destined
> for the unevictable list.  This is more likely, I think, now that we've
> removed the lru_drain_all() calls from the mlock[all]() handlers.  Back
> when I added this, I wasn't sure that we could reliably remove swap from
> a page with an arbitrary number of mappers.  Rik had warned against
> making that assumption.

Yes, it's bitten us before.  I expect you could have handled it (in
all but racy cases) by use of your remove_exclusive_swap_page_count()
but it's a lot easier never having to worry about exclusivity at all.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
