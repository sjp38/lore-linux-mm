Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id SAA25275
	for <linux-mm@kvack.org>; Thu, 19 Nov 1998 18:01:01 -0500
Date: Thu, 19 Nov 1998 22:58:30 +0100 (CET)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: Re: Linux-2.1.129..
In-Reply-To: <19981119223434.00625@boole.suse.de>
Message-ID: <Pine.LNX.3.96.981119225103.18633A-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Dr. Werner Fink" <werner@suse.de>
Cc: Linus Torvalds <torvalds@transmeta.com>, Kernel Mailing List <linux-kernel@vger.rutgers.edu>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 19 Nov 1998, Dr. Werner Fink wrote:

> Yes on a 512MB system it's a great win ... on a 64 system I see
> something like a ``swapping weasel'' under high load.
> 
> It seems that page ageing or something *similar* would be nice
> for a factor 512/64 >= 2  ... under high load and not enough
> memory it's maybe better if we could get the processes in turn
> into work instead of useless swapping (this was a side effect
> of page ageing due to the implicit slow down).

It was certainly a huge win when page aging was implemented,
but we mainly felt that because there used to be an obscure
bug in vmscan.c, causing the kernel to always start scanning
at the start of the process' address space.

Now that bug is fixed, it might just be better to switch
to a multi-queue system. A full implementation of that
will have to wait until 2.3, but we can easily do an
el-cheapo simulation of it by simply not freeing swap
cached pages on the first pass of shrink_mmap().

This gives the process a chance of reclaiming the page
without incurring any I/O and it gives the kernel the
possibility of keeping a lot of easily-freeable pages
around.

Maybe we even want to keep a 3:1 ratio or something
like that for mapped:swap_cached pages and a semi-
FIFO reclamation of swap cached pages so we can
simulate a bit of (very cheap) page aging.

Digital Unix does things this way and it works pretty
well (they keep a 1:2 ratio though, but the overhead
in maintaining that seems a bit too high).

cheers,

Rik -- slowly getting used to dvorak kbd layout...
+-------------------------------------------------------------------+
| Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
| Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
+-------------------------------------------------------------------+

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
