Message-ID: <3AF90324.EB4EA970@evision-ventures.com>
Date: Wed, 09 May 2001 10:43:16 +0200
From: Martin Dalecki <dalecki@evision-ventures.com>
MIME-Version: 1.0
Subject: Re: page_launder() bug
References: <m14xJmW-001QgaC@mozart>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rusty Russell <rusty@rustcorp.com.au>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Rusty Russell wrote:
> 
> In message <15094.10942.592911.70443@pizda.ninka.net> you write:
> >
> > Jonathan Morton writes:
> >  > >-                  page_count(page) == (1 + !!page->buffers));
> >  >
> >  > Two inversions in a row?
> >
> > It is the most straightforward way to make a '1' or '0'
> > integer from the NULL state of a pointer.
> 
> Overall, I'd have to say that this:
> 
> -               dead_swap_page =
> -                       (PageSwapCache(page) &&
> -                        page_count(page) == (1 + !!page->buffers));
> -
> 
> Is nicer as:
> 
>                 int dead_swap_page = 0;
> 
>                 if (PageSwapCache(page)
>                     && page_count(page) == (page->buffers ? 1 : 2))
>                         dead_swap_page = 1;
> 
> After all, the second is what the code *means* (1 and 2 are magic
> numbers).
> 
> That said, anyone who doesn't understand the former should probably
> get some more C experience before commenting on others' code...

Basically Amen.

But there are may be better chances that the compiler does do
better job at branch prediction in the second case? 
Wenn anyway objdump -S should show it...
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
