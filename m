Date: Mon, 19 Jun 2000 19:10:00 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: shrink_mmap() change in ac-21
In-Reply-To: <20000619234627.B23135@pcep-jamie.cern.ch>
Message-ID: <Pine.LNX.4.21.0006191905460.1290-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jamie Lokier <lk@tantalophile.demon.co.uk>
Cc: Zlatko Calusic <zlatko@iskon.hr>, alan@redhat.com, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

On Mon, 19 Jun 2000, Jamie Lokier wrote:
> Zlatko Calusic wrote:
> > The shrink_mmap() change in your latest prepatch (ac12) doesn't look
> > very healthy. Removing the test for the wrong zone we effectively
> > discard lots of wrong pages before we get to the right one. That is
> > effectively flushing the page cache and we have unbalanced system.
> 
> You know, there may be some sense in removing pages from the
> wrong zone, if those wrong zones are quite full.

If the zone is full, it can't be a "wrong zone". The problem
was that we kept removing pages from zones they shouldn't be
removed from. If a zone has zone->free_pages > zone->pages_high,
we should stop freeing pages from that zone.

> If the DMA zone desparately needs free pages and keeps needing
> them, isn't it good to encourage future non-DMA allocations to
> use another zone?

Ahh, but we already do this (up to zone->pages_high). It just
doesn't make sense to keep doing this infinitely ;)

Please wait a few more minutes for a patch which should fix it.
I've assembled a very conservative patch set, grabbing bits from
patches by Juan Quintela, Roger Larson and one minute snippet
from the old 2.3 code...

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
