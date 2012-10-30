Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id DC3DD6B0070
	for <linux-mm@kvack.org>; Tue, 30 Oct 2012 12:59:06 -0400 (EDT)
Date: Tue, 30 Oct 2012 16:59:01 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 00/31] numa/core patches
Message-ID: <20121030165901.GF3888@suse.de>
References: <20121025121617.617683848@chello.nl>
 <20121030122032.GC3888@suse.de>
 <20121030082810.b9576441.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20121030082810.b9576441.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@kernel.org>

On Tue, Oct 30, 2012 at 08:28:10AM -0700, Andrew Morton wrote:
> 
> On Tue, 30 Oct 2012 12:20:32 +0000 Mel Gorman <mgorman@suse.de> wrote:
> 
> > ...
> 
> Useful testing - thanks.  Did I miss the description of what
> autonumabench actually does?  How representitive is it of real-world
> things?
> 

It's not representative of anything at all. It's a synthetic benchmark
that just measures if automatic NUMA migration (whatever the mechanism)
is working as expected. I'm not aware of a decent description of what
the test does and why. Here is my current interpretation and hopefully
Andrea will correct me if I'm wrong.

NUMA01
  Two processes
  NUM_CPUS/2 number of threads so all CPUs are in use
  
  On startup, the process forks
  Each process mallocs a 3G buffer but there is no communication
      between the processes.
  Threads are created that zeros out the full buffer 1000 times

  The objective of the test is that initially the two processes
  allocate their memory on the same node. As the threads are
  are created the memory will migrate from the initial node to
  nodes that are closer to the referencing thread.

  It is worth noting that this benchmark is specifically tuned
  for two nodes and the expectation is that the two processes
  and their threads split so that all process A runs on node 0
  and all threads on process B run in node 1

  With 4 and more nodes, this is actually an adverse workload.
  As all the buffer is zeroed in both processes, there is an
  expectation that it will continually bounce between two nodes.

  So, on 2 nodes, this benchmark tests convergence. On 4 or more
  nodes, this partially measures how much busy work automatic
  NUMA migrate does and it'll be very noisy due to cache conflicts.

NUMA01_THREADLOCAL
  Two processes
  NUM_CPUS/2 number of threads so all CPUs are in use

  On startup, the process forks
  Each process mallocs a 3G buffer but there is no communication
      between the processes
  Threads are created that zero out their own subset of the buffer.
      Each buffer is 3G/NR_THREADS in size
  
  This benchmark is more realistic. In an ideal situation, each
  thread will migrate its data to its local node. The test really
  is to see does it converge and how quickly.

NUMA02
 One process, NR_CPU threads

 On startup, malloc a 1G buffer
 Create threads that zero out a thread-local portion of the buffer.
      Zeros multiple times - the number of times is fixed and seems
      to just be to take a period of time

 This is similar in principal to NUMA01_THREADLOCAL except that only
 one process is involved. I think it was aimed at being more JVM-like.

NUMA02_SMT
 One process, NR_CPU/2 threads

 This is a variation of NUMA02 except that with half the cores idle it
 is checking if the system migrates the memory to two or more nodes or
 if it tries to fit everything in one node even though the memory should
 migrate to be close to the CPU

> > I also expect autonuma is continually scanning where as schednuma is
> > reacting to some other external event or at least less frequently scanning.
> 
> Might this imply that autonuma is consuming more CPU in kernel threads,
> the cost of which didn't get included in these results?

It might but according to top, knuma_scand only used 7.86 seconds of CPU
time during the whole test and the time used by the migration tests is
also very low. Most migration threads used less than 1 second of CPU
time. Two migration threads used 2 seconds of CPU time each but that
still seems low.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
