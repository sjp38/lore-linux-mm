Date: Thu, 25 May 2000 18:50:59 +0200
From: Jamie Lokier <lk@tantalophile.demon.co.uk>
Subject: Re: [RFC] 2.3/4 VM queues idea
Message-ID: <20000525185059.A20563@pcep-jamie.cern.ch>
References: <Pine.LNX.4.21.0005241458250.24993-100000@duckman.distro.conectiva> <200005242057.NAA77059@apollo.backplane.com> <20000525115202.A19969@pcep-jamie.cern.ch> <200005251618.JAA82894@apollo.backplane.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <200005251618.JAA82894@apollo.backplane.com>; from dillon@apollo.backplane.com on Thu, May 25, 2000 at 09:18:49AM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matthew Dillon <dillon@apollo.backplane.com>
Cc: Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Matthew Dillon wrote:
>     Yes, but at an unreasonable cost:  Artificially limiting the number
>     of discrete processes able to share a given amount of memory.  Any
>     reasonable limit would still be an order of magnitude more expensive
>     then a physical page scan.

I disagree.  The "amount of sharing" scan-time overhead is there whether
you do a physical or virtual scan.  For a physical scan, if you have a
lot of sharing then you look at a lot of ptes per page.

One possible goal is to limit the total number of mapped ptes in the
system.  You can still permit a lot of sharing: the number does not have
to be limited per task or per mm.

>     And even with limits you still wind up with extremely non-deterministic
>     scanning.

How so?  You're only scanning currently mapped ptes, and one goal is to
keep that number small enough that you can gather good LRU stats of page
usage.  So the set of mapped ptes at any time should reasonably reflect
current usage.  If current usage is chewing up a lot of pages, you
simply get a lot of page faults and very good LRU stats :-)  I don't see
how this is particularly non-deterministic.

>     I'm not advocating a physical page scan for the current linux kernel,
>     it just isn't designed for it, but I would argue that doing a physical
>     page scan should be considered after you get past your next release.

Agreed.  Fwiw, I rather like the idea of physical scanning.  A smaller,
simpler feedback loop should show much less pathological behaviour with
unusual loads.

Fwiw, with COW address_spaces (I posted an article a couple of weeks ago
explaining) it should be fairly simple to find all the ptes for a given
page without the space overhead of pte chaining.

-- Jamie
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
