Message-ID: <4277259C.6000207@engr.sgi.com>
Date: Tue, 03 May 2005 02:17:48 -0500
From: Ray Bryant <raybry@engr.sgi.com>
MIME-Version: 1.0
Subject: Re: [PATCH/RFC 0/4] VM: Manual and Automatic page cache reclaim
References: <20050427150848.GR8018@localhost> <20050427233335.492d0b6f.akpm@osdl.org>
In-Reply-To: <20050427233335.492d0b6f.akpm@osdl.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Martin Hicks <mort@sgi.com>, linux-mm@kvack.org, raybry@sgi.com, ak@suse.de
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> Martin Hicks <mort@sgi.com> wrote:
> 
>>The patches introduce two different ways to free up page cache from a
>> node: manually through a syscall and automatically through flag
>> modifiers to a mempolicy.
> 
> 
> Backing up and thinking about this a bit more....
> 
> 
>> Currently if a job is started and there is page cache lying around on a
>> particular node then allocations will spill onto remote nodes and page
>> cache won't be reclaimed until the whole system is short on memory.
>> This can result in a signficiant performance hit for HPC applications
>> that planned on that memory being allocated locally.
> 
> 
> Why do it this way at all?
> 
> Is it not possible to change the page allocator's zone fallback mechanism
> so that once the local node's zones' pages are all allocated, we don't
> simply advance onto the next node?  Instead, could we not perform a bit of
> reclaim on this node's zones first?  Only advance onto the next nodes if
> things aren't working out?
> 

Effectively, that is what we are trying to do with this set of patches.

Let me see if I can describe the problem we are trying to solve a little
more clearly, and to explain how we got to this particular set of patches.

Before we start on that, however, it is important to understand that this
particular optimization is a crucial performance optimization for certain
kinds of workloads (admittedly on NUMA hardware, only).  That is why we
have made this a controllable policy that would be enabled only for those
workloads where it makes sense.   When the policy is not enabled, the
code is neutral with respect to VM algorithms.  It is not expected that
this code would be enabled for a traditional workload where LRU
aging is important.  So, while it is true that the proposed patch does
modify LRU ordering, that should not be a fundamental argument against
this patchset, since for workloads where keeping the LRU ordering
correct is important, the page cache reclaim code would not be enabled.

Secondly, I would observe that I have run benchmarks of OpenMP applications
with and without these type of page cache reclaiming optimizations.  If we
don't have the kind of operations needed (more on the scenario's below) there
can be a 30-40% reduction in performance due to the fact that storage which
the application believes is local to a thread is actually allocated on a
remote node.  So the optimizations proposed here do matter, and they can
be quite significant.

So what is the problem we are trying to solve?
----------------------------------------------

We are trying to fix the "stickiness" of page-cache pages on NUMA systems
for workloads where local allocation of storage is crucial.   (Note well,
this is not all workloads.)  In many cases, caching disk data in memory is
very important to performance; so the correct tradeoff to make
in most cases is to allocate remotely when a local page is not available
and not to look to see if there are local pages that can be freed instead.

However, the  typical scenario we run up against is the following:  We start 
up a long running parallel application.  As part of the application work flow,
a large amount of data is staged (copied) from a distributed file system
to higher speed local storage.  The data being copied can be 10's to 100's
of GB.  This data is brought into the page cache and the pages become
cleaned through the normal I/O process.  Remember the curse of a large
NUMA machine is that there is lots of memory, but practically none of it
is local.  (e. g. on a 512 CPU Altix, if each node has the same amount
of memory, only 1/256th of the memory available is local).

So what happens due to copying this data is that non-trival numbers
(but not all) of the nodes on the machine become completely filled
with page cache.  Now when the parallel application starts, it pins
processes to nodes and tries to allocate storage local to those processes. 
This is required for good performance -- the applications are optimized to 
place heavily referenced data in storage that the application expects to be 
local to the thread.  Since some of the nodes are full of page cache, the 
processes that are running on those nodes don't get local storage and hence 
run more slowly. We then run up against the second rule of parallel 
processing:  A parallel application only runs as quickly as the slowest 
thread.  So performance of the entire parallel job is impacted because a few 
of the threads didn't get the local storage they expected.

What we have done for our current production kernels to work around this
problem is to implement "manual" page cache reclaim.  This is the
toss_page_cache_nodes patch that we previously submitted.  The disadvantage
of that patch is that it is a "big hammer".  It causes all clean page-cache
pages on the nodes to be released.

The idea of the current patch is to only reclaim as much clean page-cache as
are required for the application by reacting to allocation requests and 
freeing storage proportional to these requests.

Why must this be an optionally controlled component of the VM?
--------------------------------------------------------------

Because this is fundamentally a workload dependent optimization.  Many
workloads want the normal VM algorithms to apply.  Caching data is
important, and until the entire system is under memory pressure,
it makes sense to keep that data in storage.  New page allocation
requests that come in and that can be allocated remotely should be
allocated on a remote node since the system has no way of knowing
how important getting local storage is to the application.  (Equivalently,
the O/S has no way of knowing how long and how intensely the newly
allocated page will be used.  So it cannot make an intelligent
tradeoff about where to allocate the page.)

Effectively, the interface we are proposing here is a way of telling
the system that for this application, getting local storage is more
important than caching data.  It needs to be optional because this
trade off does not apply to all applications.  But for our parallel
application, which may run for 10's to 100's of hours, getting local
storage is crucial and the O/S should work quite hard to try to
allocate local storage.  The time spent doing that now will be more
than made up for by the increased efficiency of the application during
its long run.  So we need a way to tell the O/S that this is
the case for this particular application.

Why can't the VM system just figure this out?
---------------------------------------------

One of the common responses to changes in the VM system for optimizations
of this type is that we instead should devote our efforts to improving
the VM system algorithms and that we are taking an "easy way out" by
putting a hack into the VM system.  Fundamentally, the VM system cannot
predict the future behavior of the application in order to correctly
make this tradeoff.  Since the application programmer (in this environment)
typically knows a lot about the behavior of the application it simply
makes sense to allow the developer a way of telling the operating system
what is about to happen rather than having the O/S make a guess.

Without this interface, the O/S's tradeoff will normally be to allocate 
remotely if local storage is not available.  In the past, it has been 
suggested that the way to react to improper local/remote storage is to watch 
the application (using storage reference counters in the memory interconnect,
for example) and to find pages that appear to be incorrectly placed and
to move those pages.  (This is the so called "Automatic Page Migration"
problem.)  Our experience at SGI with such algorithms is that they don't
work very well.  Part of the reason is that the penalty for making a
mistake is very high -- moving a page takes a long time, and if you
move it to the wrong node you can be very sorry.  The other part of the
problem is that by using sampling based methods to figure out page
placement, you only have partially correct information, and this leads
to occasionally making mistakes.  The combination of these two factors
results in poor placement decisions and a corresponding poorly
performing system.

The other part of the problem is that sampling is historical rather
than predictive.  Just when the O/S has enough samples to make a
migration decision, the computation can start a new phase, possibly
invalidating the decision the operating system has made, and without
the operating systems knowledge.  So it does the wrong thing.

Why isn't it good enough to use the synchronous page cache reclaim path?
-------------------------------------------------------------------------

There are basically two reasons (1)  We have found it to be too slow
(running the entire synchronous reclaim path on even a moderately
large Altix system can take 10's of minutes) and (2)  it is indiscriminate
in that it can also free mapped pages, and we want to keep those around. 
Effectively what we are looking for here is a way to tell the VM system that
allocating local storage is more important to this application than caching
clean file system pages.

(Setting vm_swappiness=0 doesn't do this correctly because it is global to
the system rather than the application, and in certain cases we have found
setting vm_swappiness=0 can cause the VM system to live-lock if then the
system is overcommitted due to mapped pages.)

Why isn't POSIX_FADV_DONTNEED good enough here?
----------------------------------------------

We've tried that too.  If the application is sufficiently aware of what
files it has opened, it could schedule those page cache pages to be
released.  Unfortunately, this doesn't handle the case of the last
application that ran and wrote out a bunch of data before it terminated,
nor does it deal very well with shell scripts that stage data onto and
off of the compute node as part the job's workflow.

So how did we end up with this particular set of patches?
--------------------------------------------------------

This set of patches is based, in part, on experience with our 2.4.21
based kernels.  Those kernels had an "automatic page cache reclaim"
facility, and our benchmarks have shown that this is almost as good
using the "manual page cache reclaim" approach we previously proposed.
Our experience with those kernels was that using the synchronous reclaim
path was too slow, so we special cased the search with code that
paralleled the existing code but would only release clean page-cache
pages.

For 2.6.x, we didn't want code that duplicated much of the VM path
in a separate routine, but instead wanted to slightly modify the
existing VM routines so they would only release clean page-cache
pages and not release mapped storage.  Hence, the extensions that
were proposed to the "scan control" structure.

Originally, we wanted to start with the "manual page cache release"
code we previously proposed, but that got shot down, so here we are
with the "automatic page cache release" approach.

I hope this all helps, rather than hinders the discussion of Martin's
patchset.  Discussion, complaints, and flames, all happily accepted
by yours truly,

-- 
Best Regards,
Ray
-----------------------------------------------
                   Ray Bryant
512-453-9679 (work)         512-507-7807 (cell)
raybry@sgi.com             raybry@austin.rr.com
The box said: "Requires Windows 98 or better",
            so I installed Linux.
-----------------------------------------------
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
