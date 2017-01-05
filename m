Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f198.google.com (mail-yb0-f198.google.com [209.85.213.198])
	by kanga.kvack.org (Postfix) with ESMTP id 87CB06B0069
	for <linux-mm@kvack.org>; Thu,  5 Jan 2017 01:37:07 -0500 (EST)
Received: by mail-yb0-f198.google.com with SMTP id v132so420950422yba.3
        for <linux-mm@kvack.org>; Wed, 04 Jan 2017 22:37:07 -0800 (PST)
Received: from ns.sciencehorizons.net (ns.sciencehorizons.net. [71.41.210.147])
        by mx.google.com with SMTP id b39si10854725ybj.21.2017.01.04.22.37.06
        for <linux-mm@kvack.org>;
        Wed, 04 Jan 2017 22:37:06 -0800 (PST)
Date: 5 Jan 2017 01:37:05 -0500
Message-ID: <20170105063705.29290.qmail@ns.sciencehorizons.net>
From: "George Spelvin" <linux@sciencehorizons.net>
Subject: A use case for MAP_COPY
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-mm@kvack.org, torvalds@linux-foundation.org
Cc: linux@sciencehorizons.net

Back in 2001, Linus had some very negative things to say about MAP_COPY.
I'm going to try to change that opinion.

> The thing with MAP_COPY is that how do you efficiently _detect_ somebody
> elses changes on a page that you haven't even read in yet?
> 
> So you have a few choices, all bad:
> 
>  - immediately reading in everything, basically turning the mmap() into a
>    read. Obviously a bad idea.
> 
>  - mark the inode as a "copy" inode, and whenever somebody writes to it,
>    you not only make sure that you do copy-on-write on the page cache page
>    (which, btw, is pretty much impossible - how did you intend to find all
>    the other _non_COPY_ users that _want_ coherency).
> 
>    You also have to make sure that if somebody changes the page, you have
>    to read in the old contents first (not normally needed for most
>    changes that write over at least a full block), but you also have to
>    save the old page somewhere so that the mapping can use it if it faults
>    it in later. And how the hell do you do THAT? Especially as you can
>    have multiple generations of inodes with different sets of "MAP_COPY"
>    on different contents..
> 
>    In short, now you need filesystem versioning at a per-page level etc.
> 
> Trust me. The people who came up with MAP_COPY were stupid. Really. It's
> an idiotic concept, and it's not worth implementing.

I think I have a semantic for MAP_COPY that is both efficiently
implementable and useful.

The meaning is "For each page in the mapping, a snapshot of the backing
file is taken at some undefined time between the mmap() call and the
first access to the mapped memory.  The time of the snapshot may (will!)
be different for each page.  Once taken, the snapshot will not be affected
by later writes to the file.

This does not solve any problems having to do with atomic update of files.
You still need to do the copy-and-rename dance to do an atomic update
larger than a single page.

What it *does* solve is time-of-check-to-time-of-use security problems
in the caller.  Once I've checked the file for corruption, I can
rely on it staying uncorrupted.

Once I've checked it (parsed, validated, checksummed, whatever), I can
use data structures in the mapped file directly in internal code without
fear of a TOCTTOU race.

Without MAP_COPY, my choices are:
- Explicit copy each time, or
- Greatly expanding the amount of code that has to be robust against
  TOCTTOU races.

The former is a waste of time and memory 99% of the time, because the
input file *isn't* being changed.


The goal of this is to provide the same sort of guarantees that
SHMEM_SET_SEALS does.  The bytes we map may be arbitrarily corrupted
by malicious writers, but at least we only see *one* set of bytes.
We don't have to worry about them changing underneath us.


Now, implementation-wise, I hope it's obvious that the "undefined time
between the mmap call and first access" when the snapshot is taken
is when the page is faulted in.  Which the kernel may do whenever it
damn well pleases.

The whole "what if it's not read in yet?" question goes away, because
no guarantees apply until it is.

Once a page is read in, the kernel may clone it at any time that's
convenient.  Avoiding this is an efficiency goal, but it's the all-purpose
solution to awkward corner cases.  In particular, that's what you do
if the page gets evicted.  No support from file systems is required; if
the page is evicted, the file mapping is removed, and the page remains
as as an anonymous page (copy achieved).  A later eviction attempt will
then push it to the swap file.


Implementation isn't effortless; the COW operation is more complex than
for MAP_PRIVATE.

When a write happens, we don't just fork off a copy for the writing mm.
Rather, the mappings have to be divided into MAP_COPY users and others,
and one of those sets moved to a new page.  We can either leave the
snapshot in place and move the named map, or we can make a copy and
avoid touching the file system cache.  I haven't figured out which is
easier yet.


Still, it doesn't seem hopelessly impractical.  And it seems useful.
What do other people think?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
