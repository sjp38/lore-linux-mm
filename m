Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id VAA01632
	for <linux-mm@kvack.org>; Mon, 7 Dec 1998 21:36:05 -0500
Date: Tue, 8 Dec 1998 03:31:25 +0100 (CET)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: Re: [PATCH] swapin readahead and fixes
In-Reply-To: <366C8214.F58091FF@thrillseeker.net>
Message-ID: <Pine.LNX.3.96.981208032438.8407C-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Billy Harvey <Billy.Harvey@thrillseeker.net>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>

On Mon, 7 Dec 1998, Billy Harvey wrote:

> Has anyone ever looked at the following concept?  In addition to a
> swap-in read-ahead, have a swap-out write-ahead.  The idea is to use
> all the avaialble swap space as a mirror of memory. 

We do something a bit like this in 2.1.130+. Writing out all
pages to swap will use far too much I/O bandwidth though, so
we will never do that...

> If a need for real memory comes up, and a page has been marked as
> mirrored, then it can be immediately reused without swapping out. 
> The trick would be in deciding how to write-ahead without taking
> significant execution time and disk access time away from other
> processes, that is with no impact to active processes.

We will probably want to implement a kind of write-ahead
algorithm for swapout though, but a slightly different one
than you envisioned.

On a swapout, we will scan ahead of where we are (p->swap_address)
and swap out the next number of pages too. We break the loop if:
- the page isn't present or already in swap
- the next two pages were touched since our last scan
- the page isn't allocated
- we reach the end of a SWAP_CLUSTER area in swap space

If we write this way (no more expensive than normal because
we write the stuff in one disk movement) swapin readahead
will be much more effective and performance will increase.

cheers,

Rik -- the flu hits, the flu hits, the flu hits -- MORE
+-------------------------------------------------------------------+
| Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
| Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
+-------------------------------------------------------------------+

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
