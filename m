Date: Thu, 24 Jul 2008 22:25:10 -0400
From: Rik van Riel <riel@redhat.com>
Subject: PERF: performance tests with the split LRU VM in -mm
Message-ID: <20080724222510.3bbbbedc@bree.surriel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

In order to get the performance of the split LRU VM (in -mm) better,
I have performed several performance tests with the following kernels:
- 2.6.26                                                    "2.6.26"
- 2.6.26-rc8-mm1                                            "-mm"
- 2.6.26-rc8-mm1 w/ "evict streaming IO cache first" patch  "stream"
      Patch at: http://lkml.org/lkml/2008/7/15/465
- 2.6.26-rc8-mm1 w/ "fix swapout on sequential IO" patch    "noforce"
      Patch at: http://marc.info/?l=linux-mm&m=121683855132630&w=2

I have run the performance tests on a Dell pe1950 system
with 2 quad-core CPUs, 16GB of RAM and a hardware RAID 1
array of 146GB disks.

The tests are fairly simple, but took a fair amount of time to
run due to the size of the data set involved (full disk for dd,
55GB innodb file for the database tests).


  TEST 1: dd if=/dev/sda of=/dev/null bs=1M

kernel  speed    swap used

2.6.26  111MB/s  500kB
-mm     110MB/s  59MB     (ouch, system noticably slower)
noforce	111MB/s  128kB
stream  108MB/s  0        (slight regression, not sure why yet)

This patch shows that the split LRU VM in -mm has a problem
with large streaming IOs: the working set gets pushed out of
memory, which makes doing anything else during the big streaming
IO kind of painful.

However, either of the two patches posted fixes that problem,
though at a slight performance penalty for the "stream" patch.


  TEST 2: sysbench & linear query

In this test, I run sysbench in parallel with "SELECT COUNT(*) FROM sbtest;"
on a 240,000,000 row sysbench database.  In the first columns, MySQL has
been started up with its default memory allocation; the second set of
results has innodb_buffer_pool_size=12G, allocating 75% of system memory
as innodb buffer.   The sysbench performance number is the number of
transactions per second (tps), while the linear query simply has its
time measured.

         default memory        12GB innodb buffer
kernel   tps   SELECT COUNT    tps   SELECT COUNT   swapped out

2.6.26   100   42 min 6 sec    142   1 hour 20 min  5GB (constant swap IO!)
-mm      109   33 min 25 sec   210   22 min 26 sec  <70MB
noforce  101   34 min 48 sec   207   22 min 16 sec  <70MB
stream   111   32 min 5 sec    209   22 min 22 sec  <70MB

These results show that increasing the database buffer helps
sysbench performance, even in 2.6.26 which is constantly swapping
the database buffer in and out. However, the large linear query
really suffers in the upstream VM.

The upstream VM constantly swaps mysql innodb buffer in and
out, with the amount of swap space in use hovering about half
full (5GB).  This probably indicates that the kernel keeps
cycling mysql in and out of swap, freeing up swap space at
swapin time.

Neither of the patches I proposed for -mm seem to make much of
a performance difference for this test, but they do solve the
interactivity problem during large streaming IO.

The split LRU VM in the -mm kernel really improves the performance
of databases in the presence of streaming IO, which is a real
performance issue for Linux users at the moment.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
