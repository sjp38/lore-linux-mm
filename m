Date: Mon, 28 Jun 1999 15:39:43 -0400 (EDT)
From: Chuck Lever <cel@monkey.org>
Subject: Re: filecache/swapcache questions [RFC] [RFT] [PATCH] kanoj-mm12-2.3.8
 Fix swapoff races
In-Reply-To: <199906280148.SAA94463@google.engr.sgi.com>
Message-ID: <Pine.BSO.4.10.9906281530400.24888-100000@funky.monkey.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: Andrea Arcangeli <andrea@suse.de>, torvalds@transmeta.com, sct@redhat.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 27 Jun 1999, Kanoj Sarcar wrote:
> Basically, all these operations are synchronized by the process
> mmap_sem. Unfortunately, swapoff has to visit all processes, during
> which it must hold tasklist_lock, a spinlock. Hence, it can not take
> the mmap_sem, a sleeping mutex. So, the patch links up all active
> mm's in a list that swapoff can visit (with minor restructuring, 
> kswapd can also use this, although it can not hold mmap_sem).
> Addition/deletions to the list are protected by a sleeping 
> mutex, hence swapoff can grab the individual mmap_sems, while
> preventing changes to the list. Effectively, process creation
> and destruction are locked out if swapoff is running.
> 
> To do this, the lock ordering is mm_sem -> mmap_sem. To 
> prevent deadlocks, care must be taken that a process invoking
> delete/insert_mmlist does not have its own mmap_sem held. For
> this, the do_fork path needs to change so as not to acquire
> mmap_sem early, rather only when it is really needed. This does
> not open up a resource-ordering problem between kernel_lock and
> mmap_sem, since the kernel_lock is a monitor lock that is released
> at schedule time, so no deadlocks are possible.

i'm already working on a patch that will allow kswapd to grab the mmap_sem
for the task that is about to be swapped.  this takes a slightly different
approach, since i'm focusing on kswapd and not on swapoff.  essentially
the patch does two things:

1)  it separates the logic of try_to_free_pages() and kswapd.  kswapd now
does the swapping, while try_to_free_pages() only does the shrink_mmap()
phase.

2)  after kswapd has chosen a process to swap, it drops the kernel lock
and grabs the mmap_sem for the thing it's about to swap.  it picks up the
kernel lock at appropriate points lower in the code.

i think it simplifies things a lot; there is no longer a concern about a
process deadlocking when re-acquiring it's own semaphore.  and, swapping
and page-fault handling for a given object can be serialized via the
object's mmap_sem.

	- Chuck Lever
--
corporate:	<chuckl@netscape.com>
personal:	<chucklever@netscape.net> or <cel@monkey.org>

The Linux Scalability project:
	http://www.citi.umich.edu/projects/linux-scalability/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
