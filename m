Date: Wed, 17 Jan 2001 17:52:31 +1100 (EST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: Yet another bogus piece of do_try_to_free_pages() 
In-Reply-To: <Pine.LNX.4.10.10101091604180.2906-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.4.31.0101171751060.30841-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Marcelo Tosatti <marcelo@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 9 Jan 2001, Linus Torvalds wrote:
> On Tue, 9 Jan 2001, Marcelo Tosatti wrote:
> >
> > The problem is that do_try_to_free_pages uses the "wait" argument when
> > calling page_launder() (where the paramater is used to indicate if we want
> > todo sync or async IO) _and_ used to call refill_inactive(), where this
> > parameter is used to indicate if its being called from a normal process or
> > from kswapd:
>
> Yes. Bogus.
>
> I suspect that the proper fix is something more along the lines
> of what we did to bdflush: get rid of the notion of waiting
> synchronously from bdflush, and instead do the work yourself.

Agreed. I've been working on this a bit in the last week and
have achieved some interesting results.

The main thing I found that it is *not* trivial to do this
because we can end up with multiple instances of eg. page_launder()
running at the same time and we will want to balance them against
each other in some way to prevent them from flushing too many pages
at once.

regards,

Rik
--
Virtual memory is like a game you can't win;
However, without VM there's truly nothing to lose...

		http://www.surriel.com/
http://www.conectiva.com/	http://distro.conectiva.com.br/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
