Date: Tue, 16 May 2000 07:03:38 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: Estrange behaviour of pre9-1
In-Reply-To: <Pine.LNX.4.21.0005152147490.20410-100000@duckman.distro.conectiva>
Message-ID: <Pine.LNX.4.10.10005160653380.1398-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: "Juan J. Quintela" <quintela@fi.udc.es>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Mon, 15 May 2000, Rik van Riel wrote:
> > 
> > linus> Think of it as "this user can allocate a few pages, but it's on credit.
> > linus> They have to be paid back with the appropriate 'try_to_free_pages()'".
> 
> I don't think this will help. Imagine a user firing up 'ls', that
> will need more than one page. Besides, the difference isn't that
> we have to free pages, but that we have to deal with a *LOT* of
> dirty pages at once, unexpectedly.

The reason it will help is that we can usethe "credit" to balance out the
spikes.

Think of how people use credit cards. They get paid once or twice a month,
andthen they have lots of money. But sometimes there's a big item like a
cruise in the caribbean, and that rum ended up being more expensive than
you thought.. Not to mention all those trinkets.

So what do you do? Do you pay it off immediately? Maybe you cannot afford
to, right then. You'll have to pay it off partially each month, but you
don't have to pay it all at once. And you have to pay interest.

This is a similar situation. We will have to pay interest (== free more
pages than we actually allocated), and we'll have to do it each month (==
call try_to_free_pages() on every allocation that happens while we have an
outstanding balance). But we don't have to pay it all back immediately (==
a single negative return from try_to_free_pages() does not kill us).

Right now "try_to_free_pages()" tries to always "pay back" something like
8 or 16 pages for each page we "borrowed". That's good. But let's face it,
we might be asked to pay back during a market slump when all the pages are
dirty, and while we have the "money", it's locked up right now. It would
be ok to pay off just one or two pages (== miniumum monthly payment), as
long as we pay back the rest later.

See?

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
