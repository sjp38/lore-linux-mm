Message-ID: <39A69617.CE4719EF@tuke.sk>
Date: Fri, 25 Aug 2000 17:51:51 +0200
From: Jan Astalos <astalos@tuke.sk>
MIME-Version: 1.0
Subject: Re: Question: memory management and QoS
References: <39A672FD.CEEA798C@asplinux.ru>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Yuri Pudgorodsky <yur@asplinux.ru>
List-ID: <linux-mm.kvack.org>

Yuri Pudgorodsky wrote:
> 
> Hello,
> 
> I suppose you missed some points or I do not understand you needs.
> For general computation (and for almost all other workloads),
> I think you do not need "reserved" memory - "reserved memory == wasted memory".

Only if reserved == unused. If reserved means 'available when needed' it's
completely different question. Other users can use it but when the owner
will reclaim it, system will swap them out.

> 
> With a single memory-hungry computing hog per node in cluster, you may be
> happy with current Linux MM. As long as working set for this process fits in RAM
> you'll get top performance, and the system will handle  sporadic memory allocations
> for other process more or less well. If application working set does not fit in RAM,
> you'll get huge (1000+ times) performance drop and no OS algorithms helps
> you.

You are talking about single user dedicated cluster. I'm talking about multi user
resource sharing... To desing application that fits into a cluster (and uses 100 %
of resources) is non-trivial task. Of course unless your app is embarrassingly
parallel. In computational grid (multiple clusters and single machines with different 
computing power and resources) application _must_ have guaranteed requested memory
or some of nodes will get into the state you described. I didn't heard anybody
speak that nodes would be allocated to application exclusively. But I don't want 
to discuss whether QoS is important or not... (I don't have time to waste on flamewar)

> 
> If, additionally, you want guaranteed low latency on data  access (for example for doing
> real-time feed of audio/video/whatever samples), you may lock all process memory
> to be resident in RAM: mlock(), mlockall() interfaces calls in mind.

No, user should have all used physical memory pages (inside his allocation)
always resident.

> 
> Other memory related points on performance gain lay into your application.
> You should really take into account hierarchical memory structure, and make
> your application cache-friendly and swap-friendly. For some of my work,
> I found cache simulator from http://www.cacheprof.org/ to be useful.

There's really no doubt that application should be well designed. Is it ? :-)

> 
> QoS issues come to play, if multiple process instances fights with each other
> for memory resourse. Even when per-user swapfiles sounds overkill for me,
> fills with many drawbacks and a little benefits:

We'll see...

> 
>   What you actually suggest is an obscure and inefficient per-user limits
>   of VM usage (to the size of RAM + swapfile size).

Really ? If user would be able to set the size of his swapfile (according to
his needs) or not use swapfile at all where are the limits (except his disk
quota set by sysadmin) ? And btw, I would think twice before saying it 
would be inefficient (see below).

>   Beancounters (or other counters) based implementation is both faster
>   and straightforward.

My test on limiting VM space by beancounter showed that mmapping of larger
files than VM limit was impossible. IMO that's not the right way...

> 
>   Per-user OOM is again just a per-user VM / whatever resource limit.
>   System OOM can still be triggered in a number of not-so-trivially-to-fix ways:
>     - many small processes allocated multiple unswapable kernel memory for
>       kernel objects (sockets, signals, locks, descriptors, ...);
>     - large fragmented network traffic from a fast media.

Do you have some numbers how much of these objects will hog 128MB of RAM ?
(I could use your numbers for setting limits...) Is there any reason why
not to account also this kind of memory to user ?

> 
>   There is no point in reserving RAM or swap for possible future
>   allocations: this memory will become wasted memory if no such allocation

Again. By reserved, I don't mean unused... My fault, I thought it's obvious.

>   occurs in near future, and we cannot predict this situation.
>   Additionally, memory reservation policy does not scale well, specifically
>   for systems with many idle users and a couple of active users, where active
>   set of users is often changed.
> 
> What will the beancounter patch http://www.asplinux.com.sg/install/ubpatch.shtml
> trying to guarantee, is a _minimal_ resident memory for a group of processes.
> I.e.,  if some group of processes behaves "well" and do not overcome their limits,
> their pages are protected from being swapped out due to activity of over processes

I don't claim that beancounter is bad. On the level of physical memory, MM should
work exactly this way. Another question is level of virtual memory.

> This should at least protect from swap-out attacks while one user trashing
> all memory and other users suffer from heavy swapping.

Impossible with per user swapfiles. If process would be outside his allocation
and will want another page and system won't have any, page for swapout will be
selected from the pages of its owner. So user could trash only his own processes.

> 
> > Concept of personal swapfiles:
> >
> > The benefits (among others):
> > - there wouldn't be system OOM (only per user OOM)
> 
> there will be, see above

:-)

> 
> > - user would be able to check his available memory
> 
> This buys nothing for users - users will be happy checking
> his limits/guaranties, and the system will be happy
> allocating *all* availiable memory to *any* user that need it
> with a beancounter / swapout guarantee approach while
> provides you quality of service for "well-behaved" objects.

and without VM limits system will let users hog all available VM...
and with limits there will be no mmap for larger files than
VM memory limit. OK, some people can live with it...
(Maybe it can be fixed in beancounter.)

I think that marking processes/users as '[well/bad]-behaved' is
very unfortunate. There should be strictly defined rules and 
system just should not let users break them.

> 
> >  - no limits for VM address space
> 
> ?
> 
> Your VM is limited by your hardware/software implementation only,
> and hard disk space. All other limits (per-process,
> per-users, per-system - the ammount of disk space allocated
> for swap) are actually administrative constraints.

So you suggests that 

A: making a swap disk and setting per user VM memory limit to
size/maximal_number_of_simultaneous_users is TheRightWay (tm)
how to avoid memory pressure...

I suggest that

B: system swapfile would have only necessary size and won't
   be ever touched by users (no system OOM). Only users that 
   _need_ VM would have swapfiles. And possibly

.login
   create_swapfile
   swapon swapfile

.logout
   swapoff swapfile
   destroy_swapfile

Q: What approach is more inefficient and wasting disk space ?

And another question: How the size of swapfile (partition) affects
the performance of swapping (with regard to fragmentation) ?
Has anyone some numbers ?

Cheers,

Jan
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
