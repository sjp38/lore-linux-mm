Date: Thu, 16 Aug 2001 01:07:21 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: 0-order allocation problem 
In-Reply-To: <Pine.LNX.4.33L.0108152036040.5646-100000@imladris.rielhome.conectiva>
Message-ID: <Pine.LNX.4.21.0108160050470.1034-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Linus Torvalds <torvalds@transmeta.com>, Marcelo Tosatti <marcelo@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 15 Aug 2001, Rik van Riel wrote:
> On Thu, 16 Aug 2001, Hugh Dickins wrote:
> 
> > 1. Why test free_shortage() in the high-order case?  The caller has
> >    asked for a high-order allocation, and is prepared to wait: we
> >    haven't found what the caller needs yet, we certainly should not
> >    wait forever, but we should try harder: it's irrelevant whether
> >    there's a free shortage or not - we've found a contiguity shortage.
> 
> It may be irrelevant, but remember that try_to_free_pages()
> doesn't free any pages if there is no free shortage.

I think you've caught me out there.  When "try_to_free_pages()"
actually tries to free pages is something that changes from time
to time, and I hadn't looked to see what current behaviour is.

All the more reason not to call free_shortage(), if try_to_free_pages()
will make its own decision.  The important bit is probably to recycle
round to page_launder(); or perhaps it's just to spend a little time
in the hope that something will turn up.... (not Linus' favoured
strategy, but currently contiguity is given no weight at all in
choosing pages).

> Besides, even if it did chances are you wouldn't be able
> to allocate that 2MB contiguous area any time next week ;)

I'll settle for less...

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
