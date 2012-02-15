Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id AC59F6B004A
	for <linux-mm@kvack.org>; Wed, 15 Feb 2012 16:50:41 -0500 (EST)
Message-ID: <4F3C28AF.9080005@tilera.com>
Date: Wed, 15 Feb 2012 16:50:39 -0500
From: Chris Metcalf <cmetcalf@tilera.com>
MIME-Version: 1.0
Subject: Re: [v7 0/8] Reduce cross CPU IPI interference
References: <1327572121-13673-1-git-send-email-gilad@benyossef.com>  <1327591185.2446.102.camel@twins>  <CAOtvUMeAkPzcZtiPggacMQGa0EywTH5SzcXgWjMtssR6a5KFqA@mail.gmail.com>  <20120201170443.GE6731@somewhere.redhat.com>  <CAOtvUMc8L1nh2eGJez0x44UkfPCqd+xYQASsKOP76atopZi5mw@mail.gmail.com>  <4F2AAEB9.9070302@tilera.com> <1328898816.25989.33.camel@laptop>
In-Reply-To: <1328898816.25989.33.camel@laptop>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Frederic Weisbecker <fweisbec@gmail.com>, Gilad Ben-Yossef <gilad@benyossef.com>, linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux.com>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Sasha Levin <levinsasha928@gmail.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Avi Kivity <avi@redhat.com>, Michal Nazarewicz <mina86@mina86.com>, Kosaki Motohiro <kosaki.motohiro@gmail.com>, Milton Miller <miltonm@bga.com>

On 2/10/2012 1:33 PM, Peter Zijlstra wrote:
> On Thu, 2012-02-02 at 10:41 -0500, Chris Metcalf wrote:
>> At Tilera we have been supporting a "dataplane" mode (aka Zero Overhead
>> Linux - the marketing name).  This is configured on a per-cpu basis, and in
>> addition to setting isolcpus for those nodes, also suppresses various
>> things that might otherwise run (soft lockup detection, vmstat work,
>> etc.).  
> See that's wrong.. it starts being wrong by depending on cpuisol and
> goes from there.
>
>> The claim is that you need to specify these kinds of things
>> per-core since it's not always possible for the kernel to know that you
>> really don't want the scheduler or any other interrupt source to touch the
>> core, as opposed to the case where you just happen to have a single process
>> scheduled on the core and you don't mind occasional interrupts.
> Right, so that claim is proven false I think.
>
>> But
>> there's definitely appeal in having the kernel do it adaptively too,
>> particularly if it can be made to work just as well as configuring it
>> statically. 
> I see no reason why it shouldn't work as well or even better.

Thanks for the feedback.  To echo Gilad's guess in a later email, the code
as-is is not intended as a patch planned for a merge.  The code is in use
by our customers, who have found it useful, but what I'd really like to do
is to make sure to integrate all the functionality that's useful in our
"dataplane" mode into Frederic's ongoing work with nohz cpusets.

The goal of the work we've done is to provide a way for customers to ensure
they reliably have zero jitter on cpus that are trying to process real-time
or otherwise low-latency events.  A good example is 10 Gb network traffic,
where at min-packet sizes you have only 50-odd cpu cycles to dispatch the
packet to one of our 64 cores, and each core then has a budget of only a
few thousand cycles to deal with the core.  A kernel interrupt would mean
dropping packets on the floor.  Similarly, for something like
high-frequency trading, you'd want guaranteed low-latency response.

The Tilera dataplane code is available on the "dataplane" branch (off of
3.3-rc3 at the moment):

git://git.kernel.org/pub/scm/linux/kernel/git/cmetcalf/linux-tile.git

I'm still looking at Frederic's git tree, but I'm assuming the following
are all true of tasks that are running on a nohz cpuset core:

- The core will not run the global scheduler to do work stealing, since
otherwise you can't guarantee that only tasks that care about userspace
nohz get to run there.  (I suppose you could loosen thus such that the core
would do work stealing as long as no task was pinned to that core by
affinity, at which point the pinned task would become the only runnable task.)

- Kernel "background" tasks are disabled on that core, at least while
userspace nohz tasks are running: softlockup watchdog, slab reap timer,
vmstat thread, etc.

I've appended a FAQ for the Tilera dataplane mode, intended for our
customers.  This covers the use of the set_dataplane() API and the various
DP_XXX flags.  The DP_DEBUG and DP_HARD flags that Peter objected to are,
of course, for internal/development use, though I think convenient in that
capacity.  The point of DP_HARD is to basically catch userspace bugs where
the application calls syscalls accidentally, etc., and you'd like to find
out about it.  The point of DP_DEBUG is mostly just that the kernel support
is new, so the flag helps us track down bugs by adding checks at all the
various interrupt and IPI sources; but it also allows us to point the
finger at drivers that arrange to deliver interrupts to dataplane cores
because they don't know any better.  It may not be the right API to set in
stone for long-term support, but it was easy to cook up for the time
being.  (I am curious, by the way, as to why you say it doesn't cover all
possible scenarios.)

As for DP_POPULATE, it's just a weaker mlockall(MCL_CURRENT); we are not
planning to keep it as part of the supported API.

However, I do think mlockall() is the right thing to do.  In a later email
you suggest that a RT application has a small RT part and a lot of non-RT
parts.  This is true, but in our experience, the application writer is much
better served by having the RT parts and non-RT parts in separate
processes.  The Tilera FAQ I appended below discusses this in more detail. 
The upshot is that doing mlockall() on the RT process(es) and not on the
non-RT process(es) that compose the application turns out to be a better model.

One last (unfortunate) practicality is that I'm taking off for vacation
tomorrow, so I may not be able to reply to any email until I'm back on Feb
27th.


Tilera dataplane FAQ follows.

What is "dataplane" (Zero Overhead Linux, ZOL) mode?

"Dataplane" mode is a per-cpu setting that marks cpus as primarily
intended to run jitter-sensitive or very-low-latency userspace code.
Dataplane cpus will, generally speaking, not be interrupted by kernel
bookkeeping work and will be able to run just userspace code.


How do you configure dataplane mode?

You enable cores for dataplane mode by specifying the "dataplane="
boot argument to the kernel, using the normal kernel list syntax,
i.e. comma-separated cpus or hyphen-separated ranges of cpus.  (If you
specify nonexistent cpus and they will be silently ignored.)  You must
leave at least one non-dataplane cpu configured.

Simulator images are not generally configured with dataplane enabled;
the exception is the "gx8036-dataplane" image, which is configured
with all cores except core 0 configured as dataplane.

It's not currently possible to change cores from dataplane to
non-dataplane or vice versa after booting the system.


When does a core go in or out of dataplane mode?

The kernel places a task in dataplane mode if is running on a core
that is enabled for dataplane and the task meets a number of criteria:

- No other runnable task is on the same core.  In general, you should
  use the standard kernel affinity mechanism to bind only a single
  task (process or thread) to a single dataplane core at a time.  The
  cores do not attempt to steal work from other cores to load-balance.

- No kernel events are pending for that core.

A task leaves dataplane mode when it enters the kernel for any
reason.  The kernel will 


What is different about a dataplane core from a standard Linux core?

Dataplane cores suppress a number of standard kernel book-keeping
tasks to avoid interrupting user space:

- The kernel soft lockup watchdog is disabled, so soft lockups (when
  the kernel blocks internally and stops scheduling new tasks) are
  not detected on dataplane cores.

- vmstat update is skipped on dataplane cores, along with the usual
  draining of per-cpu free pages back to the global allocator.

- TLB flush events that target kernel pages are suppressed when
  they target cores running dataplane tasks.  Instead, the tasks
  will flush all the kernel TLB entries when they finally enter the
  kernel.

Dataplane cores also try to stop the scheduler core if possible
whenever they leave the kernel to return to userspace, which makes
syscalls somewhat slower than they are on non-dataplane cores.


What can cause a dataplane task to be interrupted?

A task can get interrupts from kernel book-keeping for a few ticks
after its last return to userspace, as the kernel cleans up various
bits of internal state (for example, the kernel's RCU locking
mechanism may require waiting a timer tick duration before a cpu
is no longer involved in the RCU locking protocol).  However, see
the DP_QUIESCE flag below.

Note that a task obviously enters the kernel when it makes a system
call, but it also will enter the kernel when it touches a mapped
page of memory for the first time and has to create a suitable page
table entry.  However, see the DP_POPULATE flag below.

If a task sets up a request for an interrupt, obviously the kernel
will track that and deliver the interrupt as scheduled; for example,
see the alarm() and timer_create() kernel APIs.  Due to hardware
timer limitations, this may require multiple brief interrupts where
the kernel resets the hardware timer to a bit futher out each time;
the Tilera timers only count down over a period of a few seconds, so
multiple interrupts might be required to get a single specified
time requested of the kernel.

User-space TLB flushes will interrupt all threads that share
a given address space.  These can be caused by munmap(), which
in turn can be caused by free().  It can also be caused by threads
migrated to different cpus if kernel homecaching is enabled and
the threads are configured to home the cache for their stacks on the
current cpu, as is true by default; in this case the kernel has
to do a TLB flush to all the other threads so they know to reload
their TLBs if they have to access the migrating task's stack.

Other global kernel events will also cause interrupts, such as
kernel module unload; a list is currently being maintained at
https://github.com/gby/linux/wiki with sources of CPU interference
in core Linux code.


What programming models are recommended for dataplane?

In general, the dataplane cores should run standalone processes,
or else threads of a process that does not run threads on
non-dataplane cores.  Otherwise, the threads running on non-dataplane
cores can cause TLB flushes to the dataplane threads somewhat
unpredictably.  While it's possible to make this work, it's a
difficult discipline and not recommended.

To communicate between dataplane and non-dataplane processes,
the best mechanism is typically some form of shared memory: for
example, shared anonymous memory if one process is forked from
the other, or else a shared memory-mapped file.

Using locks of any kind directly between dataplane and non-dataplane
processes is not recommended.  Pthread locks use kernel support
(futexes) which will cause dataplane tasks to enter the kernel,
which is generally not appropriate.  However, memory-based spin locks
can cause problems when run on non-dataplane cores, since if the
lock is taken and the lock holder is scheduled out by the kernel for
any reason, there can be very long latencies imposed on any other
task (dataplane or non-dataplane) trying to acquire the lock.

A good model is a shared memory circular queue, such as the
<tmc/queue.h> API.  In this case, locking is done separately at each
end of the queue, so dataplane processes only contend with each other.


How does the set_dataplane() API help with dataplane programming?

The <sys/dataplane.h> header provides the set_dataplane() API;
a set_dataplane(2) man page is provided with Tilera Linux as well.

The DP_QUIESCE flag quiesces the timer interrupt before returning to
user space after a system call. Normally if a task on a dataplane core
makes a syscall, the system will run one or more timer ticks after the
syscall has completed, causing unexpected interrupts in
userspace. Setting DP_QUIESCE avoids that problem by having the kernel
"hold" the task in kernel mode until the timer ticks are
complete. This will make syscalls dramatically slower. If multiple
dataplane tasks are scheduled on a single core, this in effect
silently disables DP_QUIESCE, which allows the tasks to make progress,
but without actually disabling the timer tick.

DP_STRICT disallows the application from entering the kernel in any
way, unless it calls set_dataplane() again without this bit
set. Issuing any other syscall or causing a page fault would generate
a kernel message, and "kill -9" the process.  Setting this flag
automatically sets DP_QUIESCE as well, to hold the process in kernel
space until any timer ticks due to the set_dataplane() call have
completed.  This is essentially a development debugging aid.

DP_DEBUG provides support to debug dataplane interrupts, so that if
any interrupt source attempts to involve a dataplane cpu, a kernel
message and stack backtrace will be generated on the console. As this
warning is a slow event, it may make sense to avoid this mode in
production code to avoid making any possible interrupts even more
heavyweight. Setting this flag automatically sets DP_QUIESCE as
well.  This is also intended as a development debugging aid, though
in this case its primary use is to uncover kernel or driver bugs.

Finally, DP_POPULATE causes all memory mappings to be populated in the
page table.  Specifying this when entering dataplane mode ensures that
no future page fault events will occur to cause interrupts into the
Linux kernel, as long as no new mappings are installed by mmap(),
etc.  Note that since the hardware TLB is of finite size, there will
still be the potential for TLB misses that the hypervisor handles,
either via its software TLB cache (fast path) or by walking the kernel
page tables (slow path), so touching large amounts of memory will
still incur hypervisor interrupt overhead.  This is essentially the
same as mlockall(MCL_CURRENT), but without the pages being locked
into memory; this API may be deprecated in the future in favor of
simply requiring mlockall() to be used.


-- 
Chris Metcalf, Tilera Corp.
http://www.tilera.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
