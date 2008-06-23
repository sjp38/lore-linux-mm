Received: by fk-out-0910.google.com with SMTP id z22so2181086fkz.6
        for <linux-mm@kvack.org>; Sun, 22 Jun 2008 22:10:55 -0700 (PDT)
Message-ID: <21d7e9970806222210s8fec8acybb2b5af17256d555@mail.gmail.com>
Date: Mon, 23 Jun 2008 15:10:55 +1000
From: "Dave Airlie" <airlied@gmail.com>
Subject: strategies for nicely handling large amount of uc/wc allocations.
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi linux-mm hackers,

So the situation I'm currently pondering has the following requirements.

1. Would like to re-use as much of shmfs as possible, it deals with
swap etc already.
2. Would like to allocate pages into shmfs vmas from a pool of pages
suitable for using in uc/wc mappings (without causing aliasing).
(either pages with no mappings or pages with their kernel mappings
already changed).
3. Would like the uc/wc page pool to grow/shrink with allocations and
memory pressure respectively.

An object allocated with this system can be in one of 3 states:

1. not in use by the GPU at all - pages mapped into user VMA, or even
swapped out.
2. mapped into the GPU GART - all pages locked into memory and all
mappings are uc/wc.
3. acting as backing store for a memory region in GPU VRAM - swap area
reserved, but may not need any pages in RAM,
any pages need to only have uc/wc mappings as to be migrated from VRAM
may involve mapping the backing store into the GART and blitting.

The issues I'm seeing with just doing my own pool of uncached pages
like the ia64 uncached allocator, is how do I deal with swapping
objects to disk and memory pressure.
considering GPU applications do a lot of memory allocations I can't
really just ignore swap.

I think ideally I'd like a zone for these sort of pages to become a
first class member of the VM, so that I can set a VMA to have an
uncached/wc bit,
then it sets a GFP uncached bit, and alloc_page goes and fetch
suitable pages from either the highmem zone, or from a resizeable
piece of normal zone.
This zone wouldn't be required to be a fixed size, and we could
migrate chunks of RAM into the zone as needed and flush them back out
under memory pressure. The big problem is we can't afford to migrate
pages at a time from the normal zone as the overhead is too much, so
it would have to be done in large blocks (probably around 1MB or so).

So I know this mail is probably a bit incoherent but I'm going around
in circles here on the best way to do this nicely, so I'm hoping
someone will either say this is crazy or point out something I've
missed.

Dave.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
