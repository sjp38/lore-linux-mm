Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id 4B4FD6B0031
	for <linux-mm@kvack.org>; Tue, 30 Jul 2013 03:48:48 -0400 (EDT)
Received: from /spool/local
	by e31.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Tue, 30 Jul 2013 01:48:47 -0600
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 6E9371FF001B
	for <linux-mm@kvack.org>; Tue, 30 Jul 2013 01:43:21 -0600 (MDT)
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r6U7mikx167666
	for <linux-mm@kvack.org>; Tue, 30 Jul 2013 01:48:44 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r6U7mgvk032148
	for <linux-mm@kvack.org>; Tue, 30 Jul 2013 01:48:43 -0600
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: [RFC PATCH 00/10] Improve numa scheduling by consolidating tasks
Date: Tue, 30 Jul 2013 13:18:15 +0530
Message-Id: <1375170505-5967-1-git-send-email-srikar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Ingo Molnar <mingo@kernel.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Preeti U Murthy <preeti@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>

Here is an approach that looks to consolidate workloads across nodes.
This results in much improved performance. Again I would assume this work
is complementary to Mel's work with numa faulting.

Here are the advantages of this approach.
1. Provides excellent consolidation of tasks.
 From my experiments, I have found that the better the task
 consolidation, we achieve better the memory layout, which results in
 better the performance.

2. Provides good improvement in most cases, but there are some regressions.

3. Looks to extend the load balancer esp when the cpus are idling.

Here is the outline of the approach.

- Every process has a per node array where we store the weight of all
  its tasks running on that node. This arrays gets updated on task
  enqueue/dequeue.

- Added a 2 pass mechanism (somewhat taken from numacore but not
  exactly) while choosing tasks to move across nodes.

  In the first pass, choose only tasks that are ideal to be moved.
  While choosing a task, look at the per node process arrays to see if
  moving task helps.
  If the first pass fails to move a task, any task can be chosen on the
  second pass.

- If the regular load balancer (rebalance_domain()) fails to balance the
  load (or finds no imbalance) and there is a cpu, use the cpu to
  consolidate tasks to the nodes by using the information in the per
  node process arrays.

  Every idle cpu if its doesnt have tasks queued after load balance,
  - will walk thro the cpus in its node and checks if there are buddy
    tasks that are not part of the node but should have been ideally
    part of this node.
  - To make sure that we dont pull all buddy tasks and create an
    imbalance, we look at load on the load, pinned tasks and the
    processes contribution to the load for this node.
  - Each cpu looks at the node which has the least number of buddy tasks
    running and tries to pull the tasks from such nodes.

  - Once it finds the cpu from which to pull the tasks, it triggers
    active_balancing. This type of active balancing triggers just one
    pass. i.e it only fetches tasks that increase numa locality.

Here are results of specjbb run on a 2 node machine.
Specjbb was run on 3 vms.
In the fit case, one vm was big to fit one node size.
In the no-fit case, one vm was bigger than the node size.

-------------------------------------------------------------------------------------
|kernel        |                          nofit|                            fit|   vm|
|kernel        |          noksm|            ksm|          noksm|            ksm|   vm|
|kernel        |  nothp|    thp|  nothp|    thp|  nothp|    thp|  nothp|    thp|   vm|
--------------------------------------------------------------------------------------
|v3.9          | 136056| 189423| 135359| 186722| 136983| 191669| 136728| 184253| vm_1|
|v3.9          |  66041|  84779|  64564|  86645|  67426|  84427|  63657|  85043| vm_2|
|v3.9          |  67322|  83301|  63731|  85394|  65015|  85156|  63838|  84199| vm_3|
--------------------------------------------------------------------------------------
|v3.9 + Mel(v5)| 133170| 177883| 136385| 176716| 140650| 174535| 132811| 190120| vm_1|
|v3.9 + Mel(v5)|  65021|  81707|  62876|  81826|  63635|  84943|  58313|  78997| vm_2|
|v3.9 + Mel(v5)|  61915|  82198|  60106|  81723|  64222|  81123|  59559|  78299| vm_3|
| % change     |  -2.12|  -6.09|   0.76|  -5.36|   2.68|  -8.94|  -2.86|   3.18| vm_1|
| % change     |  -1.54|  -3.62|  -2.61|  -5.56|  -5.62|   0.61|  -8.39|  -7.11| vm_2|
| % change     |  -8.03|  -1.32|  -5.69|  -4.30|  -1.22|  -4.74|  -6.70|  -7.01| vm_3|
--------------------------------------------------------------------------------------
|v3.9 + this   | 136766| 189704| 148642| 180723| 147474| 184711| 139270| 186768| vm_1|
|v3.9 + this   |  72742|  86980|  67561|  91659|  69781|  87741|  65989|  83508| vm_2|
|v3.9 + this   |  66075|  90591|  66135|  90059|  67942|  87229|  66100|  85908| vm_3|
| % change     |   0.52|   0.15|   9.81|  -3.21|   7.66|  -3.63|   1.86|   1.36| vm_1|
| % change     |  10.15|   2.60|   4.64|   5.79|   3.49|   3.93|   3.66|  -1.80| vm_2|
| % change     |  -1.85|   8.75|   3.77|   5.46|   4.50|   2.43|   3.54|   2.03| vm_3|
--------------------------------------------------------------------------------------


Autonuma benchmark results on a 2 node machine:
KernelVersion: 3.9.0
		Testcase:      Min      Max      Avg   StdDev
		  numa01:   118.98   122.37   120.96     1.17
     numa01_THREAD_ALLOC:   279.84   284.49   282.53     1.65
		  numa02:    36.84    37.68    37.09     0.31
	      numa02_SMT:    44.67    48.39    47.32     1.38

KernelVersion: 3.9.0 + Mel's v5
		Testcase:      Min      Max      Avg   StdDev  %Change
		  numa01:   115.02   123.08   120.83     3.04    0.11%
     numa01_THREAD_ALLOC:   268.59   298.47   281.15    11.16    0.46%
		  numa02:    36.31    37.34    36.68     0.43    1.10%
	      numa02_SMT:    43.18    43.43    43.29     0.08    9.28%

KernelVersion: 3.9.0 + this patchset
		Testcase:      Min      Max      Avg   StdDev  %Change
		  numa01:   103.46   112.31   106.44     3.10   12.93%
     numa01_THREAD_ALLOC:   277.51   289.81   283.88     4.98   -0.47%
		  numa02:    36.72    40.81    38.42     1.85   -3.26%
	      numa02_SMT:    56.50    60.00    58.08     1.23  -17.93%

KernelVersion: 3.9.0(HT)
		Testcase:      Min      Max      Avg   StdDev
		  numa01:   241.23   244.46   242.94     1.31
     numa01_THREAD_ALLOC:   301.95   307.39   305.04     2.20
		  numa02:    41.31    43.92    42.98     1.02
	      numa02_SMT:    37.02    37.58    37.44     0.21

KernelVersion: 3.9.0 + Mel's v5 (HT)
		Testcase:      Min      Max      Avg   StdDev  %Change
		  numa01:   238.42   242.62   241.60     1.60    0.55%
     numa01_THREAD_ALLOC:   285.01   298.23   291.54     5.37    4.53%
		  numa02:    38.08    38.16    38.11     0.03   12.76%
	      numa02_SMT:    36.20    36.64    36.36     0.17    2.95%

KernelVersion: 3.9.0 + this patchset(HT)
		Testcase:      Min      Max      Avg   StdDev  %Change
		  numa01:   175.17   189.61   181.90     5.26   32.19%
     numa01_THREAD_ALLOC:   285.79   365.26   305.27    30.35   -0.06%
		  numa02:    38.26    38.97    38.50     0.25   11.50%
	      numa02_SMT:    44.66    49.22    46.22     1.60  -17.84%


Autonuma benchmark results on a 4 node machine:
# dmidecode | grep 'Product Name:'
	Product Name: System x3750 M4 -[8722C1A]-
# numactl -H
available: 4 nodes (0-3)
node 0 cpus: 0 1 2 3 4 5 6 7 32 33 34 35 36 37 38 39
node 0 size: 65468 MB
node 0 free: 63890 MB
node 1 cpus: 8 9 10 11 12 13 14 15 40 41 42 43 44 45 46 47
node 1 size: 65536 MB
node 1 free: 64033 MB
node 2 cpus: 16 17 18 19 20 21 22 23 48 49 50 51 52 53 54 55
node 2 size: 65536 MB
node 2 free: 64236 MB
node 3 cpus: 24 25 26 27 28 29 30 31 56 57 58 59 60 61 62 63
node 3 size: 65536 MB
node 3 free: 64162 MB
node distances:
node   0   1   2   3 
  0:  10  11  11  12 
  1:  11  10  12  11 
  2:  11  12  10  11 
  3:  12  11  11  10 

KernelVersion: 3.9.0
		Testcase:      Min      Max      Avg   StdDev
		  numa01:   581.35   761.95   681.23    80.97
     numa01_THREAD_ALLOC:   140.39   164.45   150.34     7.98
		  numa02:    18.47    20.12    19.25     0.65
	      numa02_SMT:    16.40    25.30    21.06     2.86

KernelVersion: 3.9.0 + Mel's v5 patchset
		Testcase:      Min      Max      Avg   StdDev  %Change
		  numa01:   733.15   767.99   748.88    14.51   -8.81%
     numa01_THREAD_ALLOC:   154.18   169.13   160.48     5.76   -6.00%
		  numa02:    19.09    22.15    21.02     1.03   -7.99%
	      numa02_SMT:    23.01    25.53    23.98     0.83  -11.44%

KernelVersion: 3.9.0 + this patchset
		Testcase:      Min      Max      Avg   StdDev  %Change
		  numa01:   409.64   457.91   444.55    17.66   51.69%
     numa01_THREAD_ALLOC:   158.10   174.89   169.32     5.84  -10.85%
		  numa02:    18.89    22.36    19.98     1.29   -3.26%
	      numa02_SMT:    23.33    27.87    25.02     1.68  -14.21%


KernelVersion: 3.9.0 (HT)
		Testcase:      Min      Max      Avg   StdDev
		  numa01:   567.62   752.06   620.26    66.72
     numa01_THREAD_ALLOC:   145.84   172.44   160.73    10.34
		  numa02:    18.11    20.06    19.10     0.67
	      numa02_SMT:    17.59    22.83    19.94     2.17

KernelVersion: 3.9.0 + Mel's v5 patchset (HT)
		Testcase:      Min      Max      Avg   StdDev  %Change
		  numa01:   741.13   753.91   748.10     4.51  -16.96%
     numa01_THREAD_ALLOC:   153.57   162.45   158.22     3.18    1.55%
		  numa02:    19.15    20.96    20.04     0.64   -4.48%
	      numa02_SMT:    22.57    25.92    23.87     1.15  -15.16%

KernelVersion: 3.9.0 + this patchset (HT)
		Testcase:      Min      Max      Avg   StdDev  %Change
		  numa01:   418.46   457.77   436.00    12.81   40.25%
     numa01_THREAD_ALLOC:   156.21   169.79   163.75     4.37   -1.78%
		  numa02:    18.41    20.18    19.06     0.60    0.20%
	      numa02_SMT:    22.72    27.24    25.29     1.76  -19.64%


Autonuma results on a 8 node machine:

# dmidecode | grep 'Product Name:'
	Product Name: IBM x3950-[88722RZ]-

# numactl -H
available: 8 nodes (0-7)
node 0 cpus: 0 1 2 3 4 5 6 7
node 0 size: 32510 MB
node 0 free: 31475 MB
node 1 cpus: 8 9 10 11 12 13 14 15
node 1 size: 32512 MB
node 1 free: 31709 MB
node 2 cpus: 16 17 18 19 20 21 22 23
node 2 size: 32512 MB
node 2 free: 31737 MB
node 3 cpus: 24 25 26 27 28 29 30 31
node 3 size: 32512 MB
node 3 free: 31736 MB
node 4 cpus: 32 33 34 35 36 37 38 39
node 4 size: 32512 MB
node 4 free: 31739 MB
node 5 cpus: 40 41 42 43 44 45 46 47
node 5 size: 32512 MB
node 5 free: 31639 MB
node 6 cpus: 48 49 50 51 52 53 54 55
node 6 size: 65280 MB
node 6 free: 63836 MB
node 7 cpus: 56 57 58 59 60 61 62 63
node 7 size: 65280 MB
node 7 free: 64043 MB
node distances:
node   0   1   2   3   4   5   6   7 
  0:  10  20  20  20  20  20  20  20 
  1:  20  10  20  20  20  20  20  20 
  2:  20  20  10  20  20  20  20  20 
  3:  20  20  20  10  20  20  20  20 
  4:  20  20  20  20  10  20  20  20 
  5:  20  20  20  20  20  10  20  20 
  6:  20  20  20  20  20  20  10  20 
  7:  20  20  20  20  20  20  20  10 

KernelVersion: 3.9.0
	Testcase:      Min      Max      Avg   StdDev
	  numa01:  1796.11  1848.89  1812.39    19.35
	  numa02:    55.05    62.32    58.30     2.37

KernelVersion: 3.9.0-mel_numa_balancing+()
	Testcase:      Min      Max      Avg   StdDev  %Change
	  numa01:  1758.01  1929.12  1853.15    77.15   -2.11%
	  numa02:    50.96    53.63    52.12     0.90   11.52%

KernelVersion: 3.9.0-numa_balancing_v39+()
	Testcase:      Min      Max      Avg   StdDev  %Change
	  numa01:  1081.66  1939.94  1500.01   350.20   16.10%
	  numa02:    35.32    43.92    38.64     3.35   44.76%


TODOs:
1. Use task loads for numa weights
2. Use numa faults as secondary key while moving threads


Andrea Arcangeli (1):
  x86, mm: Prevent gcc to re-read the pagetables

Srikar Dronamraju (9):
  sched: Introduce per node numa weights
  sched: Use numa weights while migrating tasks
  sched: Select a better task to pull across node using iterations
  sched: Move active_load_balance_cpu_stop to a new helper function
  sched: Extend idle balancing to look for consolidation of tasks
  sched: Limit migrations from a node
  sched: Pass hint to active balancer about the task to be chosen
  sched: Prevent a task from migrating immediately after an active balance
  sched: Choose a runqueue that has lesser local affinity tasks

 arch/x86/mm/gup.c        |   23 ++-
 fs/exec.c                |    6 +
 include/linux/mm_types.h |    2 +
 include/linux/sched.h    |    4 +
 kernel/fork.c            |   11 +-
 kernel/sched/core.c      |    2 +
 kernel/sched/fair.c      |  443 ++++++++++++++++++++++++++++++++++++++++++++--
 kernel/sched/sched.h     |    4 +
 mm/memory.c              |    2 +-
 9 files changed, 475 insertions(+), 22 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
