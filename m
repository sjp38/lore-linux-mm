Date: Tue, 9 Jan 2001 16:06:59 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: Yet another bogus piece of do_try_to_free_pages() 
In-Reply-To: <Pine.LNX.4.21.0101091959560.7500-100000@freak.distro.conectiva>
Message-ID: <Pine.LNX.4.10.10101091604180.2906-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@conectiva.com.br>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Tue, 9 Jan 2001, Marcelo Tosatti wrote:
> 
> The problem is that do_try_to_free_pages uses the "wait" argument when
> calling page_launder() (where the paramater is used to indicate if we want
> todo sync or async IO) _and_ used to call refill_inactive(), where this
> parameter is used to indicate if its being called from a normal process or
> from kswapd:

Yes. Bogus.

I suspect that the proper fix is something more along the lines of what we
did to bdflush: get rid of the notion of waiting synchronously from
bdflush, and instead do the work yourself. 

Doing the same to kswapd would imply getting rid of that kswapd_wait
thing, and instead of having people wait on it, they would do
"page_launder(gfp_mask, 1)" themselves (and we _do_ want them to wait,
because that ends up being rate-limiting especially on the applications
that do a lot of memory allocation - which are the applications that end
up being the problem in the first place).

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
