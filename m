Message-ID: <3B113CFB.B1ABAE0A@colorfullife.com>
Date: Sun, 27 May 2001 19:44:27 +0200
From: Manfred Spraul <manfred@colorfullife.com>
MIME-Version: 1.0
Subject: Re: [PATCH] modified memory_pressure calculation
References: <Pine.LNX.4.21.0105271256500.1907-100000@imladris.rielhome.conectiva>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
> 
> On Sun, 27 May 2001, Manfred Spraul wrote:
> 
> > * if reclaim_page() finds a page that is Referenced, Dirty or Locked
> >   then it must increase memory_pressure.
> 
> Why ?
>
Because it means that a page that was not really unused was detected by
reclaim_page.
It's not really an increase of the memory pressure, it's a decrease of
the efficiency of the inactive_clean_list.

I'll think about it again.

> > * I don't understand the purpose of the second ++ in alloc_pages().
> 
> It's broken and should be removed. Thanks for spotting
> this one.
> 
> > What about the attached patch [vs. 2.4.5]? It's just an idea, untested.
> 
> Just remove the in_interrupt() check near PF_MEMALLOC, will you?
>
Of course.
I forgot to remove that line, it's unrelated to the memory_pressure
calculation. But I think it's another problem I spotted.

> Adding that check makes it possible for a pingflood to deadlock
> kswapd, as the network card can allocate the very last pages in
> the system and kswapd needs those pages to free up memory.
>

Are you sure? It should be the other way around:

>          if (z->free_pages < z->pages_min / 4 &&
> -           !(current->flags & PF_MEMALLOC))
> +            (in_interrupt() || !(current->flags & PF_MEMALLOC)))
>		continue;

It's 'if (in_interrupt()) continue', not 'if (in_interrupt()) alloc'.
Currently a network card can allocate the last few pages if the
interrupt occurs in the context of the PF_MEMALLOC thread. I think
PF_MEMALLOC memory should never be available to interrupt handlers.

--
	Manfred
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
