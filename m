Date: Wed, 15 Aug 2001 19:44:41 -0300 (BRT)
From: Marcelo Tosatti <marcelo@conectiva.com.br>
Subject: Re: 0-order allocation problem 
In-Reply-To: <Pine.LNX.4.21.0108160050470.1034-100000@localhost.localdomain>
Message-ID: <Pine.LNX.4.21.0108151943040.26574-100000@freak.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Rik van Riel <riel@conectiva.com.br>, Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Thu, 16 Aug 2001, Hugh Dickins wrote:

> On Wed, 15 Aug 2001, Rik van Riel wrote:
> > On Thu, 16 Aug 2001, Hugh Dickins wrote:
> > 
> > > 1. Why test free_shortage() in the high-order case?  The caller has
> > >    asked for a high-order allocation, and is prepared to wait: we
> > >    haven't found what the caller needs yet, we certainly should not
> > >    wait forever, but we should try harder: it's irrelevant whether
> > >    there's a free shortage or not - we've found a contiguity shortage.
> > 
> > It may be irrelevant, but remember that try_to_free_pages()
> > doesn't free any pages if there is no free shortage.
> 
> I think you've caught me out there.  When "try_to_free_pages()"
> actually tries to free pages is something that changes from time
> to time, and I hadn't looked to see what current behaviour is.
> 
> All the more reason not to call free_shortage(), if try_to_free_pages()
> will make its own decision.  The important bit is probably to recycle
> round to page_launder(); or perhaps it's just to spend a little time
> in the hope that something will turn up.... (not Linus' favoured
> strategy, but currently contiguity is given no weight at all in
> choosing pages).

Try this: Add a "priority" argument to page_launder(), and make the
refill_freelist() call to page_launder() use a very low priority, and keep
DEF_PRIORITY in the other callers.

That will confirm if my theory is correct. 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
