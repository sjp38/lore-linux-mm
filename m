Date: Tue, 13 Jun 2000 16:20:10 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [patch] improve streaming I/O [bug in shrink_mmap()]
In-Reply-To: <Pine.LNX.4.21.0006131700490.5590-100000@inspiron.random>
Message-ID: <Pine.LNX.4.21.0006131611350.30443-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Zlatko Calusic <zlatko@iskon.hr>, alan@redhat.com, Linux MM List <linux-mm@kvack.org>, Linux Kernel List <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>

On Tue, 13 Jun 2000, Andrea Arcangeli wrote:
> On Mon, 12 Jun 2000, Stephen C. Tweedie wrote:
> 
> >Nice --- it might also explain some of the excessive kswap CPU 
> >utilisation we've seen reported now and again.
> 
> You have more kswapd load for sure due the strict zone approch.
> It maybe not noticeable but it's real.

Theoretically it's real, but having a certain number of free pages
around in the normal zone so we can do eg. process struct allocations
and slab allocations from there is well worth it. You may want to
closely re-read Linus' response to your classzone proposal some
weeks ago.

> I think Linus's argument about the above scenario is simply that
> the above isn't going to happen very often, but how can I ignore
> this broken behaviour? I hate code that works in the common case
> but that have drawbacks in the corner case.

Let me summarise the drawbacks of classzone and the strict zone
approach:

Strict zone approach:
- use slightly more memory, on the order of maybe 1 or 2%
- use slightly more kswapd cpu time since the free page goals
  are stricter

Classzone:
- can easily run out of 2- and 4-page contiguous areas of
  free memory in the normal zone, leading to the need to
  do allocation of task_structs and most slab caches from
  the dma zone
- this in turn will lead to the dma zone being less reliable
  when we need to allocate dma pages, or to a fork() failing
  with out of memory once we have a lot of processes on very
  big systems

Here you'll see that both systems have their advantages and
disadvantages. The zoned approach has a few (minimal) performance
disadvantages while classzone has a few stability disadvantages.
Personally I'd chose stability over performance any day, but that's
just me.

The big gains in classzone are most likely from the _other_ changes
that are somewhere inside the classzone patch. If we focus on
merging some of those (and maybe even improving some of the others
before merging), we can have a 2.4 which performs as good as or
better than the current classzone code but without the drawbacks.


Oh, btw, the classzone patch is vulnerable to the infinite-loop
in shrink_mmap too. Imagine a page shortage in the dma zone but
having only zone_normal pages on the lru queue ...

(and since the zone_normal classzone already has enough free pages,
shrink_mmap will find itself looping forever searching for freeable
zone_dma pages which aren't there)

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
