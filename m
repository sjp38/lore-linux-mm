Date: Mon, 4 Apr 2005 14:28:27 -0500
From: Jack Steiner <steiner@sgi.com>
Subject: per_cpu_pagesets degrades MPI performance
Message-ID: <20050404192827.GA15142@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org, hugh@veritas.com
Cc: linux-mm@kvack.org, linux-ia64@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Performnace of a number of MPI benchmarks degraded when we upgraded 
from 2.4 based kernels to 2.6 based kernels.  Surprisingly, we isolated 
the cause of the degradation to page coloring problems caused by
the per_cpu_pagesets feature that was added to 2.6. I'm sure that
this feature is a significant win for many workloads but it is
causing degradations for MPI workloads.

I'm running on an IA64 using systems with L3 caches of 1.5MB, 3MB & 9MB. The
degradation has been seen on all systems. The L3 caches on these systems
are physically tagged & have 16 (1.5MB, 3MB) or 32 (9MB) colors.

MPI programs consist of multiple threads that are simultaneously
launched by a control thread. The threads typically allocate memory
in parallel during the initialization phase.

With per_cpu_pagesets, pages are allocated & released in small batchs.
The batch size on the test system that I used is 4. Batching allocations
introduces a bias into the colors of the pages that are assigned to
a thread and is causing excessive L3 cache misses.

I wrote a simple test program that forked 2 threads, then each thread
malloc'ed & referenced 10MB of memory.  I then counted the colors of
each of the pages in the 10MB region of the 2 threads:

	(color = (phys-addr / pagesize) % 16

           ----------- color--------------------------------------------
           0   1   2   3   4   5   6   7   8   9  10  11  12  13  14  15
Thread 0:  2   2   2   2  75  75  75  75   1   1   1   1  74  74  75  76
Thread 1: 74  74  74  74   1   1   1   1  75  76  76  76   2   2   2   2

Note that thread 0 has most of it pages with colors 4-7 & 12-15 whereas 
the other thread has colors 0-3 & 8-11. This effectively cuts the size of 
the L3 in half. 

The threads are nicely interleaving assignments of the batches of 4 pages.

I see this same skew in page colors assigned to real user programs but it not
as bad as the example shown above. However, performance of MPI programs is
limited by the speed of the slowest thread. If only a single thread has
poor coloring, performance of all threads degrades.

I added a hack to disable the per_cpu_pagesets, the color skew disappears &
both 2.4 & 2.6 kernel perform the same.

With per_cpu_pagesets disabled, I see a tendency to assign a series of 
odd pages to one thread & even pages to the other thread. However, there 
appears to be enough noise in the system so that the pattern does not 
persist for a long time and overall each thread has approximately the same 
number of pages of each color.

I also changed the batch size to 16. (I was running on a system that had
an L3 with 16 colors). Again, the degradation disappeared.


Here is data from a real benchmark suite.  The tests wer run on a 
production system with 64p, 32 nodes.  The numbers show the time
required to run each test. Benchmarks 1, 2 & 5 show significant
degradation caused by the per_cpu_pagesets.

              - PER_CPU_PAGESETS -
TESTCASE      ENABLED     DISABLED        RATIO
BENCHMARK1
      4P         9.97         6.29         0.63
      8P         5.34         3.84         0.72
     16P         2.60         1.96         0.75
     32P         1.64         1.07         0.65
     64P         0.94         0.55         0.59
    128P         0.60         0.33         0.56

BENCHMARK2
      4P      3061.46      2877.89         0.94
      8P      1794.32      1707.51         0.95
     16P      1201.00      1129.44         0.94
     32P      1017.43       932.83         0.92

BENCHMARK3
     32P      3832.90      3897.00         1.02

BENCHMARK4
      2P      1387.00      1378.00         0.99
      4P       698.23       714.24         1.02
      8P       341.71       350.20         1.02
     16P       174.82       170.84         0.98
     32P        73.75        81.54         1.11

BENCHMARK5
      4P       761.07       757.09         0.99
      8P       341.54       295.69         0.87
     16P       142.38       136.37         0.96
     32P        68.41        56.60         0.83
     64P        35.17        34.43         0.98

BENCHMARK6
      1P       155.42       154.94         1.00
      2P        73.40        72.86         0.99
      4P        38.43        37.25         0.97
      6P        25.66        25.49         0.99
      8P        19.93        19.70         0.99
     12P        13.99        13.94         1.00
     16P        10.98        10.85         0.99
     24P         8.02         7.92         0.99
     48P         5.58         5.73         1.03

Has anyone else seen this problem? I am considering adding
a config option to allow a site to control the batch size
used for per_cpu_pagesets. Are there other ideas that should 
be pursued? 


I should also note that the amount of memory potentially trapped in the 
per_cpu_pagesets gets excessively large on big multinode systems.
I'll post another note about this, but it looks like a 
256 node, 512p system can have many GB of memory in the
per_cpu_pagesets.

-- 
Thanks

Jack Steiner (steiner@sgi.com)          651-683-5302
Principal Engineer                      SGI - Silicon Graphics, Inc.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
