Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id SAA00845
	for <linux-mm@kvack.org>; Mon, 7 Dec 1998 18:40:45 -0500
Date: Tue, 8 Dec 1998 00:12:01 +0100 (CET)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: Re: readahead/behind algorithm
In-Reply-To: <199812072256.WAA04256@dax.scot.redhat.com>
Message-ID: <Pine.LNX.3.96.981208000524.3961D-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Linux MM <linux-mm@kvack.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>
List-ID: <linux-mm.kvack.org>

On Mon, 7 Dec 1998, Stephen C. Tweedie wrote:
> On Mon, 7 Dec 1998 21:17:56 +0100 (CET), Rik van Riel
> <H.H.vanRiel@phys.uu.nl> said:
> 
> > I've thought a bit about what the 'ideal' readahead/behind
> > algorithm would be and reached the following conclusion.
> 
> > 1. we test the presence of pages in the proximity of the
> >    faulting page (31 behind, 32 ahead) building a map of
> >    64 pages.
> 
> It will only be useful to start getting complex here if we take more
> care about maintaining the logical contiguity of pages when we swap
> them.

We will need to test 2 proximities, the one in the process'
address space (of which I was talking here) and the one in
swap space. We only read those virtual addresses that can
be scooped off of swap in one sweep and those that can be
properly clustered.

The rest we put in a new swap bitmap (actually two bitmaps,
which get cleaned&written alternately so we can forget old
requests without forgetting new ones) and we read those pages
only when they become clusterable due to other I/O requests
happening near them or when the process faults on them.

> If swap gets fragmented, then doing this sort of readahead will just
> use up bandwidth without giving any measurable performance gains. 
> It would be better thinking along those lines right now, I suspect. 

At the moment, yes. To do the stuff I wrote about we'd need to
clone about half the code from vmscan.c and pass the faulting
address to swap_in() as an extra parameter.

We probably only want this (expensive!) swapin code on machines
than run multiple large simulations and have loads of memory
but even more swap. It will be a lot of fun to write though :)

cheers,

Rik -- the flu hits, the flu hits, the flu hits -- MORE
+-------------------------------------------------------------------+
| Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
| Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
+-------------------------------------------------------------------+

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
