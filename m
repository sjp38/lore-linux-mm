Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id RAA16435
	for <linux-mm@kvack.org>; Wed, 24 Jun 1998 17:31:59 -0400
Date: Wed, 24 Jun 1998 22:19:29 +0200 (CEST)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: Re: accounting for kernel resources
In-Reply-To: <19980624110227.38267@lucifer.guardian.no>
Message-ID: <Pine.LNX.3.96.980624221108.27393F-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Alexander Kjeldaas <astor@guardian.no>
Cc: security-audit@ferret.lmh.ox.ac.uk, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 24 Jun 1998, Alexander Kjeldaas wrote:

> I know Alan Cox has given some thought to accounting the memory
> mapping resources allocated by the kernel (pte). I haven't seen the

These should probably be allocated to both the process
involved _and_ to a special page_tbl statistic. It would
be nice to see how much overhead the pagetables _really_
take up (and their impact on memory fragmentation).
Also, this statistic will be somewhat needed once I implement
the zone allocator...

> design so I don't know how it works, but I'd like the kernel to
> account for resources allocated more aggressively. A simple step would
> be to let all structures allocated by kmalloc and associated with a
> process be accounted for. Ideally, the only thing the kernel should be

This is a very good idea, but we must be careful about some
things...

> responsible for should be caches that can be shrinked without having
> any user-land effects. The accounting should not naively count the
> number of bytes allocated, but take into account alignment-issues.

What about network buffers and other stuff that's been
pushed 'under' the current process but that doesn't really
belong to it?
There are several border cases, we probably should just
give an extra argument to get_free_page() saying to which
entitie(s) the memory should be charged...

> I think implementing this should be fairly easy - basically extending
> rlimits and making a few macros. However, there might be some
> border-cases where accounting is difficult. I can't think of them, but
> others on this list might come up with something.

DMA buffers, for character devices we probably want to
charge the process using it, for block devices the choice
is less obvious... (TAR-usage, filesystem, database on raw
disk, etc)

All shared memory things. Buffers replicated from a written-too
pagecache page (not dirty since the pagecache uses write-through
to the buffer cache). Network buffers, filehandles and other
stuff that's too small to charge to individual processes. These
things grow large however when a process uses tons of 'em (500
filehandles).

The memory used to index the above cruft :)

Rik.
+-------------------------------------------------------------------+
| Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
| Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
+-------------------------------------------------------------------+
