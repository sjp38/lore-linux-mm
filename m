Date: Fri, 19 Jan 2001 21:22:23 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [RFC] 2-pointer PTE chaining idea
In-Reply-To: <Pine.LNX.4.31.0101191849050.3368-100000@localhost.localdomain>
Message-ID: <Pine.LNX.4.10.10101192108150.2760-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: "David S. Miller" <davem@redhat.com>, linux-mm@kvack.org, "Stephen C. Tweedie" <sct@redhat.com>, Matthew Dillon <dillon@apollo.backplane.com>
List-ID: <linux-mm.kvack.org>


On Fri, 19 Jan 2001, Rik van Riel wrote:
> 
> > The only sane way I can think of to do the "implied pointer" is to do an
> > order-2 allocation when you allocate a page directory: you get 16kB of
> 
> How about doing an order-1 allocation and having a singly linked
> list ?

The thing is, that _whatever_ you do, I think it's going to suck.

I'll tell you why: I think you're trying to optimize the uncommon case. 

I realize that you think that page table scanning is slow etc. I happen to
think it's acceptable, but never mind that. More important is the fact
that NOT scanning the page tables is what is the normal case BY FAR.

Do you actually have any profiles showing that scanning the page tables is
a problem? I realize that you can create loads that scan the page tables a
lot, but have you really understood and internalized the fact that those
same loads thend to have a CPU usage of just a few percent? The bad loads
tend to spend more time waiting for IO to complete because everybody is
busy SWAPPING.

And you have to realize, that it doesn't MATTER if we spend even 25% of
the CPU power on scanning the page tables (and I want to point out that
I've never heard of such a load), if we spend 50% idle just waiting for
the disk (and the rest of the time mayb eworking or in other VM routines).

This is why I don't think this "try to be clever to avoid work when
swapping" approach is really all that relevant.

There are two IMPORTANT things to do in the VM layer:

 - select the right pages. Don't worry too much about CPU at this point:
   if you have to do IO it's ok to waste some cycles per page. You'll win
   bigger from selecting the right page, than from trying to make the
   infrastructure really cheap.

 - DO NOT WASTE TIME IF YOU HAVE MEMORY!

Th esecond point is important. You have to really think about how Linux
handles anonymous pages, and understand that that is not just an accident.
It's really important to NOT do extra work for the case where an
application just wants a page. Don't allocate swap backing store early.
Don't add it to the page cache if it doesn't need to be there. Don't do
ANYTHING.

This, btw, also implies: don't make the page tables more complex.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
