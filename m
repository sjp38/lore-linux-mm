Date: Wed, 10 Jan 2001 11:29:06 +0000
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: Subtle MM bug
Message-ID: <20010110112906.Q9321@redhat.com>
References: <Pine.LNX.4.10.10101091618110.2815-100000@penguin.transmeta.com> <Pine.LNX.4.21.0101092125520.7500-100000@freak.distro.conectiva>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.21.0101092125520.7500-100000@freak.distro.conectiva>; from marcelo@conectiva.com.br on Tue, Jan 09, 2001 at 10:12:45PM -0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@conectiva.com.br>
Cc: Linus Torvalds <torvalds@transmeta.com>, "Stephen C. Tweedie" <sct@redhat.com>, "David S. Miller" <davem@redhat.com>, Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, Jan 09, 2001 at 10:12:45PM -0200, Marcelo Tosatti wrote:
> On Tue, 9 Jan 2001, Linus Torvalds wrote:
> 
> > Hmm.. Fair enough. However, if you don't have VM pressure, you're also not
> > going to look at the page tables, so you are not going to get any use
> > information from them, either.
> 
> Are you sure that potentially unmapping pte's and swapping out its pages
> in the background scanning is ok? 

Why not?  We're only going to be aging things slowly in the absense of
memory pressure, and if a page hasn't been used between two
widely-separated passes then inactivating the page isn't likely to
have much impact: it's only a soft-fault to get it back.

> > The aging should really be done at roughly the same rate as the "mark
> > active", wouldn't you say? If you mark things active without aging, pages
> > end up all being marked as "new". And if you age without marking things
> > active, they all end up being "old". Neither is good. What you really want
> > to have is aging that happens at the same rate as reference marking.
> > So one "conditional aging" algorithm might just be something as simple as
> > 
> >  - every time you mark something referenced, you increment a counter
> >  - every time you want to age something, you check whethe rthe counter is
> >    positive first (and decrement it if you age something)
> 
> Seems to be a nice solution.

This is _exactly_ what I proposed to Rick last time we talked about
it, and it seems to be the right balance between maintaining uptodate
information when data is being accessed, and maintaining old state
when it isn't.  You need to decay the counter appropriately, though.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
