Date: Thu, 17 May 2001 16:19:35 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: SMP/highmem problem
In-Reply-To: <20010517203933.F6360@vestdata.no>
Message-ID: <Pine.LNX.4.21.0105171612030.5531-100000@imladris.rielhome.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=X-UNKNOWN
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: =?iso-8859-1?Q?Ragnar_Kj=F8rstad?= <kernel@ragnark.vestdata.no>
Cc: linux-mm@kvack.org, tlan@stud.ntnu.no
List-ID: <linux-mm.kvack.org>

On Thu, 17 May 2001, [iso-8859-1] Ragnar Kjorstad wrote:

> I've run into a performance issue.

> I use a single process, bonnie++, that creates 16 1 GB files.
> However, after a while, the machine gets really unresponsive
> and the load gets really high. According to top, all CPU power
> is spent in the kernel, mainly on kswapd, bdflush and kupdated.

This is at least partly due to the following things:

1) balance_dirty_state() tests for a condition bdflush
   may not be able to resolve
2) nr_free_buffer_pages() counts free highmem pages, which
   cannot be allocated to buffer memory, as available; this
   means that bonnie++ never gets to slow down to disk speed
   and fills up all of low memory
3) because of 2) kswapd and bdflush are trying to write the
   data out to disk like crazy, but can never keep up with
   bonnie++
4) bonnie++ tries to allocate new pages all the time, but
   cannot succeed because all of low memory is full of dirty
   page cache data .. this means it loops in __alloc_pages()
   and continuously wakes up kswapd and bdflush

A few fixes for this situation have gone into 2.4.5-pre2 and
2.4.5-pre3. If you have the time, could you test if this problem
has gotten less or has gone away in the latest kernels ?

thanks,

Rik
--
Virtual memory is like a game you can't win;
However, without VM there's truly nothing to lose...

http://www.surriel.com/		http://distro.conectiva.com/

Send all your spam to aardvark@nl.linux.org (spam digging piggy)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
