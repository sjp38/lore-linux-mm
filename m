Message-ID: <39AA24A5.CB461F4E@tuke.sk>
Date: Mon, 28 Aug 2000 10:36:53 +0200
From: Jan Astalos <astalos@tuke.sk>
MIME-Version: 1.0
Subject: Re: Question: memory management and QoS
References: <39A672FD.CEEA798C@asplinux.ru> <39A69617.CE4719EF@tuke.sk> <39A6D45D.6F4C3E2F@asplinux.ru>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yuri Pudgorodsky <yur@asplinux.ru>, Linux MM mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Yuri Pudgorodsky wrote:
> 
> Jan Astalos wrote:
> 
> > > I suppose you missed some points or I do not understand you needs.
> > > For general computation (and for almost all other workloads),
> > > I think you do not need "reserved" memory - "reserved memory == wasted memory".
> >
> > Only if reserved == unused. If reserved means 'available when needed' it's
> > completely different question. Other users can use it but when the owner
> > will reclaim it, system will swap them out.
> 
> Yes, I did not read your previous post in such a way. But think of reclaiming
> swap space, what does it mean? Copying pages from one swapfile to another?

Reclaiming swap space ? What would be that good for ? Pages would change swap
file only if they change owner (swapin, chown, swapout).

> 
> If we want to reclaim used physical pages, we're speaking about "page replacement
> policy". It is not important where we will store swapped pages: on a partition
> or a file or multiple files. What is important that's an algorithm used to
> choose what page to replace.

Incorrect. It is _very_ important where we store swapped pages. IMO it makes big
difference whether we scatter pages of single process across large swap file(s)
or whether we keep it inside relatively small (continuous) disk space.
I agree that LRU policy can improve _overall_ performance. But it sacrifices 
_per_user_ performance.

> 
> Moreover, speaking about performance I'm sure fragmenting swap space to multiple
> files is bad unless these files are on seperate physical disks.
> 
> What I wanted to say in previous post too, you buy nothing interesting
> using swapfile per user. What you need to change to provide a "fairness"
> to each user is a page replacement strategy.

How about to split memory QoS into:
  - guarantied amount of physical memory
  - guarantied amount of virtual memory  

The former is much more complicated and includes page replacement policies
along with fair sharing of physical memory (true core of QoS).

The latter should gurantee users requested amount of VM. I.e. avoid this kind
of situation: successful malloc, a lot of work, killed in action due to OOM (
out of munition^H^H^H^H^H^H^H^Hmemory), RIP...
In the current state it's the problem of system administration. In my approach
it will become user's problem. So user would be able to satisfy his need for
VM himself and system would only take care of fair management of physical memory.

> 
> There are algorithms for local page replacement policy, implemented for years
> on mainframe OS-es (OS/390, MVS, VMS also has it AFAIK). With such design,
> if process needs page, OS replaces a page from the process itself, or from
> another process of the same user. Of course thare are many configurable
> parameters :-)
> 
> Unixes on contast traditionally implement global page replacement polices,
> using some kind of LRU strategy. This proves to be more better for overall
> system performance with a large number of users,  while local policy allow you
> to fine tune system for a specific tasks. Global page replacement however often
> suffer from a page trashing problems when several processes actively replace each
> other pages. I'd like to see trash protecting algorithms find its way into Linux.

Me too...

> 
> Will, user will set a swapfile to all available disk quota and start trashing VM
> with  " *p = 0; p+= PAGE_SIZE ". With global LRU page replacement,
> we will end with all RAM occupied by his pages, and unusable performance for each other.
> 
> Or you suggest  user disk quota  <  RAM?

I think I didn't get your point here...

> Userbeancounters are for that accounting. The problem is there are many different objects
> in play here, and sometimes it is not possible to associate them with particular user.

But that's not a design flaw, it's a problem of implementation.

> 
> >
> > A: making a swap disk and setting per user VM memory limit to
> > size/maximal_number_of_simultaneous_users is TheRightWay (tm)
> > how to avoid memory pressure...
> 
> No. Overcommiting memory is a normal practice within UNIX world. So you
> should not want to restrict users in VM space. However you want to protect
> users using low VM set (actually, low resident pages) from users trashing
> large VM area. Regardless of swap space used.

If you want to implement QoS, you really should avoid overcommiting of memory.
Otherwise your clever page replacement techniques will be absolutely useless.

> 
> So,
> 
> 1) Allocation a large VM area is OK, even overcommitted
>    (and mmaping a large file is OK too).
>    You should not want restrict user VM space.

100% agreed. But it makes a difference in mapped VM and actually
used VM. I'd like to avoid even mention of limits on VM address
space (RLIMIT_AS). But it's necessary to limit the number of
used VM pages (in order to prevent OOM).

> 
> 2) If there is a plenty of RAM, active usage of VM by a single
>    user/process should use all available RAM (even 99,9% of
>    overall system memory).

agreed.

> 
>    Stealing not used for a long time pages from other users is OK too.
>    Stealing an active page from a user with low memory usage
>    (lower then some configurable value) is not OK.

In other words, used memory(meaning physical) pages inside the area
allocated to a process should be protected from swapout. See ? Not
a limit on RSS (beancounter's notation), because it's actually not 
a limit. Limit will be determined by MM policy (see below).

> 
> 3) When low-memory-usage user wants a page, we should first try to
>    take it from users with high (over quota) memory usage.
> 

Exactly. (quota == allocation). But not with LRU. Free memory should be 
divided between users fairly. I mean, according to the ratio of their
allocations.

> 
> I suppose system will loose performance with each logged in user due
> to swap space fragmentation.

I disagree.
  - users with low memory usage (inside their allocation) wont swap at all.
  - users with high memory usage will swap into their own (relatively compact)
    swap file. Therefore it would be possible to exchange a bunch of LRU
    pages (of this user) with his swapped pages without even moving disk heads.

> 
> (A)
>   + guarantee physically continuous space

not at all... even with clustering. Reading the code, the pages of one process
can get scattered over swap device. (Correct me if I missed something).

>   + less overhead

questionable. Finding free swap page would be much easier. But that's not the
point. _per_user_ swapping performance depends on the location of his pages
in swap device.

>   - difficult to resize, usually resulting in admin decision to waste  more disk space

i.e. money... (which could be otherwise spend on physical memory ;-)

> 
> (B)
>   + may use less disk space for many usage patterns
>   + easy to add/delete space
>   - is less efficient due to overhead of additional block bitmap operations,
>     (to convert fs block to pages) but I did not see any actual numbers;

I'm really interested how large is this overhead comparing to disk seek times.
(with regard to increasing CPU speed, readahead stuff in disks and still larger
swapfiles)

>   - may be less efficient (and even to order of magnitute) if we
>     take into account swap clustering: we loose ability to cluster
>     swap requests from different users.

Maybe, maybe not. I can't see right now how clustering of pages from different
users can guarantee (we still talking about QoS) _per_user_ performance...

> 
> Both (A) and (B) needs some QoS-aware "fairness" page replacement algorithms.
> But IMO (A) has more advantages :-) and using (B) has little to do with QoS.

You should ask users whether they accept QoS that forces them to use
calloc(3) to ensure that they really will get requested amount of VM.

IMO, QoS should be transparent to users. If I'll pay for some service,
I'll expect some guarantied quality. Not to force me to rewrite my code.
There is _much_ more users than developers...

> 
> > And another question: How the size of swapfile (partition) affects
> > the performance of swapping (with regard to fragmentation) ?
> 
> Even for unfragmented files, there should be difference.
> I'm interesting in this numbers too :-)
> 

By swap fragmentation I don't mean fragmentation of swap device, but the
fragmentation of swap area.

see the section about swap clustering in http://lwn.net/1999/0121/a/vmreview.html

Jan

PS: Memory management of top-ranking OS of 21st century is not a counting of beans...
    Sorry, I could not help myself :-)
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
