Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 9F3816B004A
	for <linux-mm@kvack.org>; Thu, 23 Sep 2010 18:29:45 -0400 (EDT)
Received: by wyb36 with SMTP id 36so2878766wyb.14
        for <linux-mm@kvack.org>; Thu, 23 Sep 2010 15:29:43 -0700 (PDT)
MIME-Version: 1.0
Date: Thu, 23 Sep 2010 15:29:43 -0700
Message-ID: <AANLkTim1R7-FVwofw-otpGCcHqQHLDwaTYYWFS1ZhSoW@mail.gmail.com>
Subject: Linux swapping with MySQL/InnoDB due to NUMA architecture imbalanced allocations?
From: Jeremy Cole <jeremy@jcole.us>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hello Linux MM community!

I have some questions about Linux memory management, perhaps if
someone can check my theory.  I've been researching why sometimes
larger MySQL servers tend to swap even though they don't appear to be
under memory pressure.  The machine(s) in question are dual quad core
Intel Nehalem processors, with 64GB (16x4GB) memory.  They are used
for a MySQL+InnoDB workload with 48GB allocated to InnoDB's buffer
pool.

My theory is that it is caused by the interplay between the NUMA
memory allocation policy and the paging and page reclaim algorithms,
but I'd like a double-check on my understanding of it and whether my
theory makes sense.

With our configuration, MySQL allocates about 53GB of memory -- 48GB
in the buffer pool, plus a bunch of smaller allocations.  This occurs
nearly at once near startup time (as expected) and the NUMA policy is
"local" by default, so the memory ends up being allocated
preferentially in Node 0 (in this case), and since Node 0 only has
less than 32GB total, once it is full, it spills over into more than
half of Node 1 as well.

Now, since Node 0 has zero free memory, the entirety of the file cache
and most of the rest of the on-demand memory allocations on the system
occur only in Node 1 free memory.  So while the system has lots of
"free" memory tied up in caches, nearly none of it is on Node 0.
There seem to be a bundle of allocations which for whatever reason
must be done in Node 0, and this causes some of the already allocated
memory in Node 0 to be paged out to make room.  However, mostly what
is getting paged out is parts of InnoDB's buffer pool which inevitably
needs to be paged back in to satisfy a query fairly soon.

(Note that this isn't always Node 0, sometimes Node 1 gets most of the
memory allocated and the exact same thing happens in reverse.)

This seems to be especially exacerbated on machines that are acting as
a slave primarily (single writer reading from master, and various logs
queuing on disk) and systems where backups are occurring.

On an exemplary running (production) system, free shows:

# free -m
             total       used       free     shared    buffers     cached
Mem:         64435      64218        216          0        240      10570
-/+ buffers/cache:      53406      11028
Swap:        31996      15068      16928

The InnoDB buffer pool can be found easily enough (by its sheer size)
in the numa_maps:

# grep 2aaaaad3e000 /proc/20520/numa_maps
2aaaaad3e000 default anon=13226274 dirty=13210834 swapcache=3440575
active=13226272 N0=7849384 N1=5376890

(anon=~50.45GB swapcache=~13.12GB N0=~29.94GB N1=~20.51GB)

(Note: It would be quite interesting for this case to see e.g.
N0_swapcache and N1_swapcache separated from each other.  I noticed in
the code that only the totals are accounted for per-node.  Would it
make sense to tally them all up per-node and then add them together
for presentation of totals?)

So the questions are:

1. Is it plausible that Linux for whatever reason needs memory to be
in Node 0, and chooses to page out used memory to make room, rather
than choosing to drop some of the cache in Node 1 and use that memory?
 I think this is true, but maybe I've missed something important.

2. If so, what circumstances would you expect to see that in?

I think we have a solution to this (still in testing and
qualification) using "numactl --interleave all" with the mysqld
process, but in the mean time I am hoping to check my understanding
and theory.  However, this of course spreads all the allocations
between the two nodes, which allows for some of the memory to be used
for file cache on each node, thus meaning they are on at least equal
footing for freeing memory.

All replies, questions, clarifications, requests for clarification,
and requests to bugger off welcome!

Regards,

Jeremy

P.S.: Thank you a million times to Rik van Riel and to Mel Gorman;
your amazing documentation, wiki posts, mailing list replies, etc.,
have helped me immensely in understanding how things work and in
researching this issue.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
