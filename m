Message-ID: <39A672FD.CEEA798C@asplinux.ru>
Date: Fri, 25 Aug 2000 17:22:05 +0400
From: Yuri Pudgorodsky <yur@asplinux.ru>
MIME-Version: 1.0
Subject: Re: Question: memory management and QoS
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: astalos@tuke.sk
List-ID: <linux-mm.kvack.org>

Hello,

I suppose you missed some points or I do not understand you needs.
For general computation (and for almost all other workloads),
I think you do not need "reserved" memory - "reserved memory == wasted memory".

With a single memory-hungry computing hog per node in cluster, you may be
happy with current Linux MM. As long as working set for this process fits in RAM
you'll get top performance, and the system will handle  sporadic memory allocations
for other process more or less well. If application working set does not fit in RAM,
you'll get huge (1000+ times) performance drop and no OS algorithms helps
you.

If, additionally, you want guaranteed low latency on data  access (for example for doing
real-time feed of audio/video/whatever samples), you may lock all process memory
to be resident in RAM: mlock(), mlockall() interfaces calls in mind.

Other memory related points on performance gain lay into your application.
You should really take into account hierarchical memory structure, and make
your application cache-friendly and swap-friendly. For some of my work,
I found cache simulator from http://www.cacheprof.org/ to be useful.

QoS issues come to play, if multiple process instances fights with each other
for memory resourse. Even when per-user swapfiles sounds overkill for me,
fills with many drawbacks and a little benefits:

  What you actually suggest is an obscure and inefficient per-user limits
  of VM usage (to the size of RAM + swapfile size).
  Beancounters (or other counters) based implementation is both faster
  and straightforward.

  Per-user OOM is again just a per-user VM / whatever resource limit.
  System OOM can still be triggered in a number of not-so-trivially-to-fix ways:
    - many small processes allocated multiple unswapable kernel memory for
      kernel objects (sockets, signals, locks, descriptors, ...);
    - large fragmented network traffic from a fast media.

  There is no point in reserving RAM or swap for possible future
  allocations: this memory will become wasted memory if no such allocation
  occurs in near future, and we cannot predict this situation.
  Additionally, memory reservation policy does not scale well, specifically
  for systems with many idle users and a couple of active users, where active
  set of users is often changed.

What will the beancounter patch http://www.asplinux.com.sg/install/ubpatch.shtml
trying to guarantee, is a _minimal_ resident memory for a group of processes.
I.e.,  if some group of processes behaves "well" and do not overcome their limits,
their pages are protected from being swapped out due to activity of over processes.
This should at least protect from swap-out attacks while one user trashing
all memory and other users suffer from heavy swapping.

> Concept of personal swapfiles:
>
> The benefits (among others):
> - there wouldn't be system OOM (only per user OOM)

there will be, see above

> - user would be able to check his available memory

This buys nothing for users - users will be happy checking
his limits/guaranties, and the system will be happy
allocating *all* availiable memory to *any* user that need it
with a beancounter / swapout guarantee approach while
provides you quality of service for "well-behaved" objects.

>  - no limits for VM address space

?

Your VM is limited by your hardware/software implementation only,
and hard disk space. All other limits (per-process,
per-users, per-system - the ammount of disk space allocated
for swap) are actually administrative constraints.

> - there could be more policies for sharing of physical memory
>   by users (and system)




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
