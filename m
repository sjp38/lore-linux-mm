Message-ID: <39A6D45D.6F4C3E2F@asplinux.ru>
Date: Sat, 26 Aug 2000 00:17:33 +0400
From: Yuri Pudgorodsky <yur@asplinux.ru>
MIME-Version: 1.0
Subject: Re: Question: memory management and QoS
References: <39A672FD.CEEA798C@asplinux.ru> <39A69617.CE4719EF@tuke.sk>
Content-Type: text/plain; charset=koi8-r
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jan Astalos <astalos@tuke.sk>
Cc: Linux MM mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Jan Astalos wrote:

> > I suppose you missed some points or I do not understand you needs.
> > For general computation (and for almost all other workloads),
> > I think you do not need "reserved" memory - "reserved memory == wasted memory".
>
> Only if reserved == unused. If reserved means 'available when needed' it's
> completely different question. Other users can use it but when the owner
> will reclaim it, system will swap them out.

Yes, I did not read your previous post in such a way. But think of reclaiming
swap space, what does it mean? Copying pages from one swapfile to another?

If we want to reclaim used physical pages, we're speaking about "page replacement
policy". It is not important where we will store swapped pages: on a partition
or a file or multiple files. What is important that's an algorithm used to
choose what page to replace.

Moreover, speaking about performance I'm sure fragmenting swap space to multiple
files is bad unless these files are on seperate physical disks.

What I wanted to say in previous post too, you buy nothing interesting
using swapfile per user. What you need to change to provide a "fairness"
to each user is a page replacement strategy.

There are algorithms for local page replacement policy, implemented for years
on mainframe OS-es (OS/390, MVS, VMS also has it AFAIK). With such design,
if process needs page, OS replaces a page from the process itself, or from
another process of the same user. Of course thare are many configurable
parameters :-)

Unixes on contast traditionally implement global page replacement polices,
using some kind of LRU strategy. This proves to be more better for overall
system performance with a large number of users,  while local policy allow you
to fine tune system for a specific tasks. Global page replacement however often
suffer from a page trashing problems when several processes actively replace each
other pages. I'd like to see trash protecting algorithms find its way into Linux.

Unfortunatly I did not see good papers comparing one system with another.
However I hear OS/390 is able to run 100+ Linux kernels on top of it CP,
while Linux cannot :-)


> In computational grid (multiple clusters and single machines with different
> computing power and resources) application _must_ have guaranteed requested memory
> or some of nodes will get into the state you described. I didn't heard anybody
> speak that nodes would be allocated to application exclusively. But I don't want
> to discuss whether QoS is important or not... (I don't have time to waste on flamewar)

I suppose you want "background" MM policy, to run memory hungry applications.
With swap-out guaranties, you may want to divide all processes to (a) system processes,
(b) user A processes, (c) user B processes, ...  And setup reasonable minimal guaranteed RSS for each group.

For true QoS, once in a while I found  interesting this paper:

    http://www.dcs.gla.ac.uk/~ian/papers/memh.ps


> > If, additionally, you want guaranteed low latency on data  access (for example for doing
> > real-time feed of audio/video/whatever samples), you may lock all process memory
> > to be resident in RAM: mlock(), mlockall() interfaces calls in mind.
>
> No, user should have all used physical memory pages (inside his allocation)
> always resident.

Surely it always better to have your page in RAM then on disk :-)
But for most systems this is expensive... or there would no VMM systems at all.

> >   What you actually suggest is an obscure and inefficient per-user limits
> >   of VM usage (to the size of RAM + swapfile size).
>
> Really ? If user would be able to set the size of his swapfile (according to
> his needs) or not use swapfile at all where are the limits (except his disk
> quota set by sysadmin) ? And btw, I would think twice before saying it
> would be inefficient (see below).

Will, user will set a swapfile to all available disk quota and start trashing VM
with  " *p = 0; p+= PAGE_SIZE ". With global LRU page replacement,
we will end with all RAM occupied by his pages, and unusable performance for each other.

Or you suggest  user disk quota  <  RAM?


> My test on limiting VM space by beancounter showed that mmapping of larger
> files than VM limit was impossible. IMO that's not the right way...

I also agreed here. Limiting VM is not practical, there're better resourses to be limited.
For example, unswappable memory used for PTE/PGD.

> >   Per-user OOM is again just a per-user VM / whatever resource limit.
> >   System OOM can still be triggered in a number of not-so-trivially-to-fix ways:
> >     - many small processes allocated multiple unswapable kernel memory for
> >       kernel objects (sockets, signals, locks, descriptors, ...);
> >     - large fragmented network traffic from a fast media.
>
> Do you have some numbers how much of these objects will hog 128MB of RAM ?
> (I could use your numbers for setting limits...) Is there any reason why
> not to account also this kind of memory to user ?

Userbeancounters are for that accounting. The problem is there are many different objects
in play here, and sometimes it is not possible to associate them with particular user.


> >   There is no point in reserving RAM or swap for possible future
> >   allocations: this memory will become wasted memory if no such allocation
>
> Again. By reserved, I don't mean unused... My fault, I thought it's obvious.
>
> >   occurs in near future, and we cannot predict this situation.
> >   Additionally, memory reservation policy does not scale well, specifically
> >   for systems with many idle users and a couple of active users, where active
> >   set of users is often changed.
> >
> > What will the beancounter patch http://www.asplinux.com.sg/install/ubpatch.shtml
> > trying to guarantee, is a _minimal_ resident memory for a group of processes.
> > I.e.,  if some group of processes behaves "well" and do not overcome their limits,
> > their pages are protected from being swapped out due to activity of over processes
>
> I don't claim that beancounter is bad. On the level of physical memory, MM should
> work exactly this way. Another question is level of virtual memory.
>
> > This should at least protect from swap-out attacks while one user trashing
> > all memory and other users suffer from heavy swapping.
>
> Impossible with per user swapfiles. If process would be outside his allocation
> and will want another page and system won't have any, page for swapout will be
> selected from the pages of its owner. So user could trash only his own processes.
>
> >
> > > Concept of personal swapfiles:
> > >
> > > The benefits (among others):
> > > - there wouldn't be system OOM (only per user OOM)
> >
> > there will be, see above
>
> :-)
>
> >
> > > - user would be able to check his available memory
> >
> > This buys nothing for users - users will be happy checking
> > his limits/guaranties, and the system will be happy
> > allocating *all* availiable memory to *any* user that need it
> > with a beancounter / swapout guarantee approach while
> > provides you quality of service for "well-behaved" objects.
>
> and without VM limits system will let users hog all available VM...
> and with limits there will be no mmap for larger files than
> VM memory limit. OK, some people can live with it...
> (Maybe it can be fixed in beancounter.)
>
> I think that marking processes/users as '[well/bad]-behaved' is
> very unfortunate. There should be strictly defined rules and
> system just should not let users break them.
>
> >
> > >  - no limits for VM address space
> >
> > ?
> >
> > Your VM is limited by your hardware/software implementation only,
> > and hard disk space. All other limits (per-process,
> > per-users, per-system - the ammount of disk space allocated
> > for swap) are actually administrative constraints.
>
> So you suggests that
>
> A: making a swap disk and setting per user VM memory limit to
> size/maximal_number_of_simultaneous_users is TheRightWay (tm)
> how to avoid memory pressure...

No. Overcommiting memory is a normal practice within UNIX world. So you
should not want to restrict users in VM space. However you want to protect
users using low VM set (actually, low resident pages) from users trashing
large VM area. Regardless of swap space used.

So,

1) Allocation a large VM area is OK, even overcommitted
   (and mmaping a large file is OK too).
   You should not want restrict user VM space.

2) If there is a plenty of RAM, active usage of VM by a single
   user/process should use all available RAM (even 99,9% of
   overall system memory).

   Stealing not used for a long time pages from other users is OK too.
   Stealing an active page from a user with low memory usage
   (lower then some configurable value) is not OK.

3) When low-memory-usage user wants a page, we should first try to
   take it from users with high (over quota) memory usage.


> I suggest that
>
> B: system swapfile would have only necessary size and won't
>    be ever touched by users (no system OOM). Only users that
>    _need_ VM would have swapfiles. And possibly
>
> .login
>    create_swapfile
>    swapon swapfile
>
> .logout
>    swapoff swapfile
>    destroy_swapfile
>
> Q: What approach is more inefficient and wasting disk space ?

I suppose system will loose performance with each logged in user due
to swap space fragmentation.

(A)
  + guarantee physically continuous space
  + less overhead
  - difficult to resize, usually resulting in admin decision to waste  more disk space


(B)
  + may use less disk space for many usage patterns
  + easy to add/delete space
  - is less efficient due to overhead of additional block bitmap operations,
    (to convert fs block to pages) but I did not see any actual numbers;
  - may be less efficient (and even to order of magnitute) if we
    take into account swap clustering: we loose ability to cluster
    swap requests from different users.

Both (A) and (B) needs some QoS-aware "fairness" page replacement algorithms.
But IMO (A) has more advantages :-) and using (B) has little to do with QoS.


> And another question: How the size of swapfile (partition) affects
> the performance of swapping (with regard to fragmentation) ?

Even for unfragmented files, there should be difference.
I'm interesting in this numbers too :-)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
