Date: Tue, 20 Jun 2000 13:18:38 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: shrink_mmap() change in ac-21
In-Reply-To: <Pine.LNX.4.21.0006200043550.988-100000@inspiron.random>
Message-ID: <Pine.LNX.4.21.0006201258190.12944-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Jamie Lokier <lk@tantalophile.demon.co.uk>, Zlatko Calusic <zlatko@iskon.hr>, alan@redhat.com, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

On Tue, 20 Jun 2000, Andrea Arcangeli wrote:
> On Mon, 19 Jun 2000, Jamie Lokier wrote:
> 
> >if those wrong zones are quite full.  If the DMA zone desparately needs
> >free pages and keeps needing them, isn't it good to encourage future
> >non-DMA allocations to use another zone?  Removing pages from other
> 
> After some time the DMA zone will be full again anyway and you
> payed a cost that consists in throwing away unrelated innocent
> pages. I'm not convinced it's the right thing to do.

I didn't know for sure either until I tested -ac21 on my
192MB workstation. The bursts kswapd went through when
it was freeing DMA memory (and 8MB of other memory) have
convinced me that this is not a good idea.

Also, since kswapd stops when all zones have free_pages
above pages_low and we'll free up to pages_high pages of
one zone, it means that we'll:

- allocate the next series of pages from that one zone
  with tons of unused pages
- wake up kswapd so we'll free the *next* unused pages
  from that zone when we run out of the current batch
- rinse and repeat

This means we'll do a *lot* more allocations from the
less loaded zones than from the other zone, with a few
(short) interruptions by kswapd. Also, there's no need
to throw away data early.

Of course, once we have a scavenge list (in the active
inactive scavenge list VM) this whole point will be moot
and we just want to avoid doing too much IO at once).

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
