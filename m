Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id HAA30189
	for <linux-mm@kvack.org>; Mon, 7 Dec 1998 07:57:33 -0500
Date: Mon, 7 Dec 1998 12:52:54 +0100 (CET)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: Re: [PATCH] swapin readahead and fixes
In-Reply-To: <Pine.LNX.3.96.981204192244.28834B-100000@ferret.lmh.ox.ac.uk>
Message-ID: <Pine.LNX.3.96.981207124716.23360D-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Chris Evans <chris@ferret.lmh.ox.ac.uk>
Cc: Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 4 Dec 1998, Chris Evans wrote:
> On Thu, 3 Dec 1998, Rik van Riel wrote:
> 
> > here is a patch (against 2.1.130, but vs. 2.1.131 should
> > be trivial) that improves the swapping performance both
> > during swapout and swapin and contains a few minor fixes.

Since Dec 3 a lot changed. There now _is_ a patch against the
2.1.131 with Stephen's apparantly excellent shrink_mmap() fix.

> I'm very interested in performance for sequential swapping. This
> occurs in for example scientific applications which much sweep
> through vast arrays much larger than physical RAM. 
> 
> Have you benchmarked booting with low physical RAM, lots of swap and
> writing a simple program that allocates 100's of Mb of memory and
> then sequentially accesses every page in a big loop? 

Yes. Zlatko Calusic made a small and simple program that you
can tell how much memory to use and how many passes it should
make. It simply reads the memory and dirties it. I have achieved
5 MB/s (that's 10 MB/s when you count the fact that you both have
to read _and_ write) on a 200 MB session.

> This is one area in which FreeBSD stomps on us. Theoretically it
> should be possible to get swap with readahead pulling pages into RAM
> at disk speed. 

I have looked at the FreeBSD code. We can do better than that
and I've worked out quite a nice scheme to do both read-ahead,
read-behind or a combination of the two (depending on the
situation). We also should stop reading in pages that are in
the vincinity but don't belong to the program at hand.

Unfortunately the Linux swapout code doesn't do proper clustering
yet (too much fragmentation within a program's address space) and
none of the above ideas have been converted to code yet. :)

cheers,

Rik -- the flu hits, the flu hits, the flu hits -- MORE
+-------------------------------------------------------------------+
| Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
| Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
+-------------------------------------------------------------------+

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
