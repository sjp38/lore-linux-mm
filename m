Date: Fri, 18 Apr 2003 19:05:46 -0400 (EDT)
Message-Id: <200304182305.h3IN5klM026249@pacific-carrier-annex.mit.edu>
Reply-to: Ping Huang <pshuang@alum.mit.edu>
From: Ping Huang <pshuang@alum.mit.edu>
Subject: Large-footprint processes in a batch-processing-like scenario
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I'm trying to figure out if there is an efficient way to coerce the
Linux kernel to effectively swap (not demand-page) between multiple
processes which will not all fit together into physical memory.  I'd
be interested in peoples' comments about how they would expect the
Linux VM subsystem to behave for the workload described below, what
kernels might do better vs. others, and how I might tune for system
throughput for this kind of application load.

As a first cut, please reply back to me, I'll collate all replies, and
summarize back to the email list, where people may then discuss
everybody else's contributions and comments.

If this email list is inappropriate for such discussion, I apologize
and look forward to suggestions for better-suited discussion forums.
I skimmed through the thread listings for the the past several months'
worth of messages in the archives before sending this email.

- Hardware: dual Athlon PC's with 3GB physical memory & 15GB of swap
  configured (striped across multiple disks).
- Software: Linux 2.4.18 SMP kernels (otherwise running RedHat 7.2).

- I have 5 separate instances of the same Java application (using the
  Sun 1.4.1 JVM), each of which needs lots of memory, so the JVM is
  started with options to allow 1.8GB of Java heap.  Each application
  has about half a dozen Java threads (translating into Linux
  processes), only one of which is really doing significant amounts of
  work.  Although the application code is the same, each of the 5
  instances is working on a different partition of the same overall
  problem.  Very succintly, each application instance polls a central
  Oracle database for its "events" and then processes the events in
  chronological order.  The applications have a very high
  initialization startup cost; it takes roughly 30 minutes for an
  application instance to start up.  There's a high shutdown cost as
  well, also about 30 minutes.  (The high memory consumption and the
  30 minutes to startup and shutdown is because each application
  instance maintains an immense amount of state.)  But it's easy for
  me to tell the application instance to stop what it's doing and
  sleep, and then later, tell it to start working again.

- Unfortunately, 5 such application instances which are so large
  certainly cannot fit into the 3GB of physical memory I have
  available in their entirety and at the same time.  Each instance's
  memory access patterns is such that the working set of pages for the
  instance includes pretty much the entire 1.8GB Java heap, especially
  when full Java heap garbage collection occurs.  So I can effectively
  only actively run one instance at a time on a 3GB PC; trying to
  actively run two instances simply results in massive thrashing.

- For throughput efficiency reasons I cannot simply start up
  application instance 1, let it do some work (e.g., for an hour),
  then shut it down (have it exit completely), then start up instance
  2, let it do some work, etc.  With a startup cost of 30 minutes and
  shutdown cost of 30 minutes, this would result in only 50% of
  elapsed clock time being spent doing productive work.  If I could
  afford a different (probably 64-bit) hardware platform which
  physically accomodated enough RAM, I could run all 5 instances at
  once, have everything fit in physical memory, and the world would be
  hunky-dory.  But I cannot afford such a platform; and for deployment
  practicality reasons, I can't just use 5 separate PCs each with 3GB
  of memory, running only one application instance on each PC.

- The behavior I would like but I don't think I can get (though I'd
  love to be wrong) is pure process *swapping* as opposed to demand
  paging.  If the multiple Linux processes associated with each
  instance have a cumulative virtual memory footprint of 2.0GB (since
  the 1.8GB Java heap and much of the other memory allocated are
  shared between the different Java threads within an application
  instance, but each thread has some Java-thread/Linux-process private
  pages), then if I have disks capable of sustained 25MB/sec. large
  read-write I/O, then in theory, the OS could swap out all the
  processes associated with application instance 1 in about 80 seconds
  (25MB/sec. * 82 seconds > 2048MB).  The OS could then swap in all
  the processes associated with instance 2 also in about 80 seconds.
  So if I let each application instance work for about an hour, the
  overhead of swapping processes entirely to switch between
  application instances would be about 5% of clock time wasted (160
  seconds wasted every 3600 seconds).  That's pretty reasonable.

- In practice, if I start all 5 application instances on a single 3GB
  PC, and signal instances 2-5 to go to sleep, and let instance 1 run
  for an hour, then signal instance 1 to go to sleep and signal
  instance 2 to wake up, the Linux kernel will page in instance 2's
  2GB working set, but rather slowly.  The application's memory access
  patterns are close enough to being random that Linux is essentially
  paging in its working set randomly, and this is resulting in very
  slow page-in rates compared to the 25MB/sec. bandwidth rate.
  Instead of being bandwidth limited, the observed paging behavior in
  this case seems disk seek limited.  Increasing the value of
  /proc/sys/vm/page-cluster doesn't seem to help.  The application
  instance may spend about half an hour (out of its 1 hour work time
  "quantum") during which the CPUs are often nearly 100% idle while
  the disks are working madly.

- Using the Linux ptrace() system call to let me touch another
  process's virtual memory address space through /proc/$PID/mem, I'm
  able to get Linux to page in a process with a more predictable
  memory access pattern (linear rather than pseudo-random).  This
  seems to help page-in rates significantly.  To switch from
  application instance 1 to instance 2, I now tell instance 1 to go to
  sleep, then run my process memory toucher program to touch one of
  the processes for instance 2, and then tell instance 2 to wake up.
  The overhead of switching is cut down to about 3 minutes, but over
  time, it slowly takes longer and longer (I have a run where
  switching now taking about 5 minutes, although I'm not sure if this
  will continue to grow without bound or not).  My guess is that Linux
  initially does a good job of grouping pages which are adjacent in a
  process's virtual memory address space such that they are adjacent
  in swap space as well, which allows pre-fetch (based on the value
  2^"page-cluster"?) to reduce the number of I/O operations and the
  number of disk seeks necessary when I touch the process's virtual
  address space linearly.  But over time, fragmentation occurs and
  pages adjacent in a process's virtual memory address space become
  separated from each other in swap space.

Thoughts?

-- 
Ping Huang <pshuang@alum.mit.edu>; info: http://web.mit.edu/pshuang/.plan
        Disclaimer: unless explicitly otherwise stated, my
        statements represent my personal viewpoints only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
