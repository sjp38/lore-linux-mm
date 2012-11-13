Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 938136B004D
	for <linux-mm@kvack.org>; Tue, 13 Nov 2012 03:19:42 -0500 (EST)
Received: by mail-ee0-f41.google.com with SMTP id c4so4742803eek.14
        for <linux-mm@kvack.org>; Tue, 13 Nov 2012 00:19:41 -0800 (PST)
Date: Tue, 13 Nov 2012 09:19:35 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 5/8] sched, numa, mm: Add adaptive NUMA affinity support
Message-ID: <20121113081935.GB21386@gmail.com>
References: <20121112160451.189715188@chello.nl>
 <20121112161215.782018877@chello.nl>
 <0000013af7130ad7-95edbaf9-d31d-4258-8fc0-013d152246a2-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0000013af7130ad7-95edbaf9-d31d-4258-8fc0-013d152246a2-000000@email.amazonses.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>


* Christoph Lameter <cl@linux.com> wrote:

> > Using this, we can construct two per-task node-vectors, 
> > 'S_i' and 'P_i' reflecting the amount of shared and 
> > privately used pages of this task respectively. Pages for 
> > which two consecutive 'hits' are of the same cpu are assumed 
> > private and the others are shared.
> 
> The classification is per task? [...]

Yes, exactly - access patterns are fundamentally and physically 
per task, as a task can execute only on a single CPU at once. (I 
say 'task' instead of 'thread' or 'process' because the new code 
makes no distinction between threads and processes.)

The new code maps out inter-task relationships, statistically. 

So we are basically able to (statistically) approximate which 
task relates to which other task in the system, based on their 
memory access patterns alone: using a very compact metric and 
matching scheduler rules and a (lazy) memory placement machinery 
on the VM side.

Say consider the following 10-task workload, where the scheduler 
is able to figure out these relationships:

  { A, B, C, D } dominantly share memory X with each other
  { E, F, G, H } dominantly share memory Y with each other
  { I }          uses memory privately
  { J }          uses memory privately

and the scheduler rules then try to converge these groups of 
tasks ideally.

[ The 'role' and grouping of tasks is not static but sampled and 
  average based - so if a worker thread changes its role, the 
  scheduler will adapt placement to that. ]

[ A 'private task' is basically a special case for sharing 
  memory: if a task only shares memory with itself. Its 
  placement and spreading is easy. ]

> [...] But most tasks have memory areas that are private and 
> other areas where shared accesses occur. Can that be per 
> memory area? [...]

Do you mean per vma, and/or per mm?

How would that work? Consider the above case:

 - 12x CPU-intense threads and a large piece of shared memory

 - 2x 4 threads are using two large shared memory area to 
   calculate (one area for each group of threads)

 - the 4 remaining processes aggregate and sort the results from
   the 8 threads, in their own dominantly 'private' working set.

how does per vma or per mm describe that properly? The whole 
workload might be just within a single large vma within a JVM. 
Or it might be implemented using processes and anonymous shared 
memory.

If you look at this from a 'per task access pattern and 
inter-task working set relationship' perspective then the 
resolution and optimization is natural: the 2x 4 threads should 
be grouped together modulo capacity constraints, while the 
remaining 4 'private memory' threads should be spread out over 
the remaining capacity of the system.

What matters is how tasks relate to each other as they perform 
processing, not which APIs the workload uses to create tasks and 
memory areas.

The main constraint from a placement optimization complexity POV 
is task->CPU placement: for NUMA workloads the main challenge - 
and 80% of the code and much of the real meat of the feature - 
is to categorize and place tasks properly.

There might be much discussion about PROT_NONE and memory 
migration details, but that is because the VM code is 5 times 
larger than the scheduler code and due to that there's 5 times 
more VM hackers than scheduler hackers ;-)

In reality the main complexity of this problem [the placement 
optimization problem portion] is a dominantly CPU/task scheduler 
feature, and IMO rather fundamentally so: it's not an 
implementation choice but derives from the Von Neumann model of 
computing in essence.

And that is why IMO the task based access pattern metric 
implementaton is such a good fit in practice as well - and that 
is why other approaches struggled getting a hold of the NUMA 
problem.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
