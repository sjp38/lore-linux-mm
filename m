Date: Wed, 7 Jun 2000 11:35:37 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: reduce shrink_mmap rate of failure (initial attempt)
In-Reply-To: <01BFD09A.CC430AF0@lando.optronic.se>
Message-ID: <Pine.LNX.4.21.0006071132150.14304-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Roger Larsson <roger.larsson@optronic.se>
Cc: "'quintela@fi.udc.es'" <quintela@fi.udc.es>, "'linux-mm@kvack.org'" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 7 Jun 2000, Roger Larsson wrote:

> >That patch hangs my machine here when I run mmap002.  The machine is
> >in shrink_mmap.  It hangs trying to get the pagmap_lru_lock.
> 
> The only possible explaination is that we are searching for
> pages on a zone. But no such pages are possible to free from
> LRU...  And we LOOP the list, holding the lru lock...

Indeed. I'll make sure to have this fixed in the multi-list
setup I'm working on. A quick fix is to have a per-zone counter
of the number of lru pages, so you can just stop when
zone->lru_pages == 0.

> May the allocation of pages play a part? Filling zone after zone
> will give no mix between the zones.

Ohh, but it does. On most systems, after memory fills up, we'll
be allocating a few pages from one zone, then a few pages from
the next zone, then kswapd kicks in and we start all over again.

The fact that you and quintela had to go through trouble to hit
the bug makes me believe that it's not a very big issue in the
normal case ... just something we want fixed and luckily the
fix is easy.

regards,

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.

Wanna talk about the kernel?  irc.openprojects.net / #kernelnewbies
http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
