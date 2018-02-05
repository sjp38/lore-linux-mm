Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id D82EB6B0009
	for <linux-mm@kvack.org>; Sun,  4 Feb 2018 20:28:04 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id q2so11078470pgf.22
        for <linux-mm@kvack.org>; Sun, 04 Feb 2018 17:28:04 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a5-v6si3923270plt.652.2018.02.04.17.28.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 04 Feb 2018 17:28:02 -0800 (PST)
From: Davidlohr Bueso <dbueso@suse.de>
Subject: [RFC PATCH 00/64] mm: towards parallel address space operations
Date: Mon,  5 Feb 2018 02:26:50 +0100
Message-Id: <20180205012754.23615-1-dbueso@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mingo@kernel.org
Cc: peterz@infradead.org, ldufour@linux.vnet.ibm.com, jack@suse.cz, mhocko@kernel.org, kirill.shutemov@linux.intel.com, mawilcox@microsoft.com, mgorman@techsingularity.net, dave@stgolabs.net, linux-mm@kvack.org, linux-kernel@vger.kernel.org

From: Davidlohr Bueso <dave@stgolabs.net>

Hi,

This patchset is a new version of both the range locking machinery as well
as a full mmap_sem conversion that makes use of it -- as the worst case
scenario as all mmap_sem calls are converted to a full range mmap_lock
equivalent. As such, while there is no improvement of concurrency perse,
these changes aim at adding the machinery to permit this in the future.

Direct users of the mm->mmap_sem can be classified as those that (1) acquire
and release the lock within the same context, and (2) those who directly
manipulate the mmap_sem down the callchain. For example:

(1)  down_read(&mm->mmap_sem);
     /* do something */
     /* nobody down the chain uses mmap_sem directly */
     up_read(&mm->mmap_sem);

(2a)  down_read(&mm->mmap_sem);
      /* do something that retuns mmap_sem unlocked */
      fn(mm, &locked);
      if (locked)
        up_read(&mm->mmap_sem);

(2b)  down_read(&mm->mmap_sem);
      /* do something that in between released and reacquired mmap_sem */
      fn(mm);
      up_read(&mm->mmap_sem);

Patches 1-2: add the range locking machinery. This is rebased on the rbtree
optimizations for interval trees such that we can quickly detect overlapping
ranges. More documentation as also been added, with an ordering example in the
source code.

Patch 3: adds new mm locking wrappers around mmap_sem.

Patches 4-15: teaches page fault paths about mmrange (specifically adding the
range in question to the struct vm_fault). In addition, most of these patches
update mmap_sem callers that call into the 2a and 2b examples above.

Patches 15-63: adds most of the trivial conversions -- the (1) example above.
(patches 21, 22, 23 are hacks that avoid rwsem_is_locked(mmap_sem) such that
we don't have to teach file_operations about mmrange.

Patch 64: finally do the actual conversion and replace mmap_sem with the range
mmap_lock.

I've run the series on a 40-core (ht) 2-socket IvyBridge with 16 Gb of memory
on various benchmarks that stress address space concurrency.

** pft is a microbenchmark for page fault rates.

When running with increasing thread counts, range locking takes a rather small
hit (yet constant) of ~2% for the pft timings, with a max of 5%. This translates
similarly to faults/cpu.


pft timings
                                  v4.15-rc8              v4.15-rc8
                                                range-mmap_lock-v1
Amean     system-1          1.11 (   0.00%)        1.17 (  -5.86%)
Amean     system-4          1.14 (   0.00%)        1.18 (  -3.07%)
Amean     system-7          1.38 (   0.00%)        1.36 (   0.94%)
Amean     system-12         2.28 (   0.00%)        2.31 (  -1.18%)
Amean     system-21         4.11 (   0.00%)        4.13 (  -0.44%)
Amean     system-30         5.94 (   0.00%)        6.01 (  -1.11%)
Amean     system-40         8.24 (   0.00%)        8.33 (  -1.04%)
Amean     elapsed-1         1.28 (   0.00%)        1.33 (  -4.50%)
Amean     elapsed-4         0.32 (   0.00%)        0.34 (  -5.27%)
Amean     elapsed-7         0.24 (   0.00%)        0.24 (  -0.43%)
Amean     elapsed-12        0.23 (   0.00%)        0.23 (  -0.22%)
Amean     elapsed-21        0.26 (   0.00%)        0.25 (   0.39%)
Amean     elapsed-30        0.24 (   0.00%)        0.24 (  -0.21%)
Amean     elapsed-40        0.24 (   0.00%)        0.24 (   0.84%)
Stddev    system-1          0.04 (   0.00%)        0.05 ( -16.29%)
Stddev    system-4          0.03 (   0.00%)        0.03 (  17.70%)
Stddev    system-7          0.08 (   0.00%)        0.02 (  68.56%)
Stddev    system-12         0.05 (   0.00%)        0.06 ( -31.22%)
Stddev    system-21         0.06 (   0.00%)        0.06 (   8.07%)
Stddev    system-30         0.05 (   0.00%)        0.09 ( -70.15%)
Stddev    system-40         0.11 (   0.00%)        0.07 (  41.53%)
Stddev    elapsed-1         0.03 (   0.00%)        0.05 ( -72.14%)
Stddev    elapsed-4         0.01 (   0.00%)        0.01 (  -4.98%)
Stddev    elapsed-7         0.01 (   0.00%)        0.01 (  60.65%)
Stddev    elapsed-12        0.01 (   0.00%)        0.01 (   6.24%)
Stddev    elapsed-21        0.01 (   0.00%)        0.01 (  -1.13%)
Stddev    elapsed-30        0.00 (   0.00%)        0.00 ( -45.10%)
Stddev    elapsed-40        0.01 (   0.00%)        0.01 (  25.97%)

pft faults
                                       v4.15-rc8                v4.15-rc8
                                                       range-mmap_lock-v1
Hmean     faults/cpu-1    629011.4218 (   0.00%)   601523.2875 (  -4.37%)
Hmean     faults/cpu-4    630952.1771 (   0.00%)   602105.6527 (  -4.57%)
Hmean     faults/cpu-7    518412.2806 (   0.00%)   518082.2585 (  -0.06%)
Hmean     faults/cpu-12   324957.1130 (   0.00%)   321678.8932 (  -1.01%)
Hmean     faults/cpu-21   182712.2633 (   0.00%)   182643.5347 (  -0.04%)
Hmean     faults/cpu-30   126618.2558 (   0.00%)   125698.1965 (  -0.73%)
Hmean     faults/cpu-40    91266.3914 (   0.00%)    90614.9956 (  -0.71%)
Hmean     faults/sec-1    628010.9821 (   0.00%)   600700.3641 (  -4.35%)
Hmean     faults/sec-4   2475859.3012 (   0.00%)  2351373.1960 (  -5.03%)
Hmean     faults/sec-7   3372026.7978 (   0.00%)  3408924.8028 (   1.09%)
Hmean     faults/sec-12  3517750.6290 (   0.00%)  3488785.0815 (  -0.82%)
Hmean     faults/sec-21  3151328.9188 (   0.00%)  3156983.9401 (   0.18%)
Hmean     faults/sec-30  3324673.3141 (   0.00%)  3318585.9949 (  -0.18%)
Hmean     faults/sec-40  3362503.8992 (   0.00%)  3410086.6644 (   1.42%)
Stddev    faults/cpu-1     14795.1817 (   0.00%)    22870.4755 ( -54.58%)
Stddev    faults/cpu-4      8759.4355 (   0.00%)     8117.4629 (   7.33%)
Stddev    faults/cpu-7     20638.6659 (   0.00%)     2290.0083 (  88.90%)
Stddev    faults/cpu-12     4003.9838 (   0.00%)     5297.7747 ( -32.31%)
Stddev    faults/cpu-21     2127.4059 (   0.00%)     1186.5330 (  44.23%)
Stddev    faults/cpu-30      558.8082 (   0.00%)     1366.5374 (-144.54%)
Stddev    faults/cpu-40     1234.8354 (   0.00%)      768.8031 (  37.74%)
Stddev    faults/sec-1     14757.0434 (   0.00%)    22740.7172 ( -54.10%)
Stddev    faults/sec-4     49934.6675 (   0.00%)    54133.9449 (  -8.41%)
Stddev    faults/sec-7    152781.8690 (   0.00%)    16415.0736 (  89.26%)
Stddev    faults/sec-12   228697.8709 (   0.00%)   239575.3690 (  -4.76%)
Stddev    faults/sec-21    70244.4600 (   0.00%)    75031.5776 (  -6.81%)
Stddev    faults/sec-30    52147.1842 (   0.00%)    58651.5496 ( -12.47%)
Stddev    faults/sec-40   149846.3761 (   0.00%)   113646.0640 (  24.16%)

           v4.15-rc8   v4.15-rc8
                    range-mmap_lock-v1
User           47.46       48.21
System        540.43      546.03
Elapsed        61.85       64.33

** gitcheckout is probably the workload that takes the biggest hit (-35%).
Sys time, as expected, increases quite a bit, coming from overhead of blocking.

gitcheckout
                              v4.15-rc8              v4.15-rc8
                                            range-mmap_lock-v1
System  mean            9.49 (   0.00%)        9.82 (  -3.49%)
System  stddev          0.20 (   0.00%)        0.39 ( -95.73%)
Elapsed mean           22.87 (   0.00%)       30.90 ( -35.12%)
Elapsed stddev          0.39 (   0.00%)        6.32 (-1526.48%)
CPU     mean           98.07 (   0.00%)       76.27 (  22.23%)
CPU     stddev          0.70 (   0.00%)       14.63 (-1978.37%)


           v4.15-rc8   v4.15-rc8
                    range-mmap_lock-v1
User          224.06      224.80
System        176.05      181.01
Elapsed       619.51      801.78


** freqmine is an implementation of Frequent Itemsets Mining (FIM) that
analyses a set of transactions looking to extract association rules with
threads. This is a common workload in retail. This configuration uses
between 2 and 4*NUMCPUs. The performance differences with this patchset
are marginal.

freqmine-large
                               v4.15-rc8                  v4.15-rc8
                                                 range-mmap_lock-v1
Amean     2            216.89 (   0.00%)          216.59 (   0.14%)
Amean     5             91.56 (   0.00%)           91.58 (  -0.02%)
Amean     8             59.41 (   0.00%)           59.54 (  -0.22%)
Amean     12            44.19 (   0.00%)           44.24 (  -0.12%)
Amean     21            33.97 (   0.00%)           33.55 (   1.25%)
Amean     30            33.28 (   0.00%)           33.15 (   0.40%)
Amean     48            34.38 (   0.00%)           34.21 (   0.48%)
Amean     79            33.22 (   0.00%)           32.83 (   1.19%)
Amean     110           36.15 (   0.00%)           35.29 (   2.40%)
Amean     141           35.63 (   0.00%)           36.38 (  -2.12%)
Amean     160           36.31 (   0.00%)           36.05 (   0.73%)
Stddev    2              1.10 (   0.00%)            0.19 (  82.79%)
Stddev    5              0.23 (   0.00%)            0.10 (  54.31%)
Stddev    8              0.17 (   0.00%)            0.43 (-146.19%)
Stddev    12             0.12 (   0.00%)            0.12 (  -0.05%)
Stddev    21             0.49 (   0.00%)            0.39 (  21.88%)
Stddev    30             1.07 (   0.00%)            0.93 (  12.61%)
Stddev    48             0.76 (   0.00%)            0.66 (  12.07%)
Stddev    79             0.29 (   0.00%)            0.58 ( -98.77%)
Stddev    110            1.10 (   0.00%)            0.53 (  51.93%)
Stddev    141            0.66 (   0.00%)            0.79 ( -18.83%)
Stddev    160            0.27 (   0.00%)            0.15 (  42.71%)

           v4.15-rc8   v4.15-rc8
                    range-mmap_lock-v1
User        29346.21    28818.39
System        292.18      676.92
Elapsed      2622.81     2615.77


** kernbench (build kernels). With increasing thread counts, the amoung of
overhead from range locking is no more than ~5%.

kernbench
                               v4.15-rc8              v4.15-rc8
                                             range-mmap_lock-v1
Amean     user-2       554.53 (   0.00%)      555.74 (  -0.22%)
Amean     user-4       566.23 (   0.00%)      567.15 (  -0.16%)
Amean     user-8       588.66 (   0.00%)      589.68 (  -0.17%)
Amean     user-16      647.97 (   0.00%)      648.46 (  -0.08%)
Amean     user-32      923.05 (   0.00%)      925.25 (  -0.24%)
Amean     user-64     1066.74 (   0.00%)     1067.11 (  -0.03%)
Amean     user-80     1082.50 (   0.00%)     1082.11 (   0.04%)
Amean     syst-2        71.80 (   0.00%)       74.90 (  -4.31%)
Amean     syst-4        76.77 (   0.00%)       79.91 (  -4.10%)
Amean     syst-8        71.58 (   0.00%)       74.83 (  -4.54%)
Amean     syst-16       79.21 (   0.00%)       82.95 (  -4.73%)
Amean     syst-32      104.21 (   0.00%)      108.47 (  -4.09%)
Amean     syst-64      113.69 (   0.00%)      119.39 (  -5.02%)
Amean     syst-80      113.98 (   0.00%)      120.18 (  -5.44%)
Amean     elsp-2       307.65 (   0.00%)      309.27 (  -0.53%)
Amean     elsp-4       159.86 (   0.00%)      160.94 (  -0.67%)
Amean     elsp-8        84.76 (   0.00%)       85.04 (  -0.33%)
Amean     elsp-16       49.63 (   0.00%)       49.56 (   0.15%)
Amean     elsp-32       37.52 (   0.00%)       38.16 (  -1.68%)
Amean     elsp-64       36.76 (   0.00%)       37.03 (  -0.72%)
Amean     elsp-80       37.09 (   0.00%)       37.49 (  -1.08%)
Stddev    user-2         0.97 (   0.00%)        0.66 (  32.20%)
Stddev    user-4         0.52 (   0.00%)        0.60 ( -17.34%)
Stddev    user-8         0.64 (   0.00%)        0.23 (  63.28%)
Stddev    user-16        1.40 (   0.00%)        0.64 (  54.46%)
Stddev    user-32        1.32 (   0.00%)        0.95 (  28.47%)
Stddev    user-64        0.77 (   0.00%)        1.47 ( -91.61%)
Stddev    user-80        1.12 (   0.00%)        0.94 (  16.00%)
Stddev    syst-2         0.45 (   0.00%)        0.45 (   0.22%)
Stddev    syst-4         0.41 (   0.00%)        0.58 ( -41.24%)
Stddev    syst-8         0.55 (   0.00%)        0.28 (  49.35%)
Stddev    syst-16        0.22 (   0.00%)        0.29 ( -30.98%)
Stddev    syst-32        0.44 (   0.00%)        0.56 ( -27.75%)
Stddev    syst-64        0.47 (   0.00%)        0.48 (  -1.91%)
Stddev    syst-80        0.24 (   0.00%)        0.60 (-144.20%)
Stddev    elsp-2         0.46 (   0.00%)        0.31 (  32.97%)
Stddev    elsp-4         0.14 (   0.00%)        0.25 ( -72.38%)
Stddev    elsp-8         0.36 (   0.00%)        0.08 (  77.92%)
Stddev    elsp-16        0.74 (   0.00%)        0.58 (  22.00%)
Stddev    elsp-32        0.31 (   0.00%)        0.74 (-138.95%)
Stddev    elsp-64        0.12 (   0.00%)        0.12 (   1.62%)
Stddev    elsp-80        0.23 (   0.00%)        0.15 (  35.38%)

           v4.15-rc8   v4.15-rc8
                    range-mmap_lock-v1
User        28309.95    28341.20
System       3320.18     3473.73
Elapsed      3792.13     3850.21



** reaim's compute, new_dbase and shared workloads were tested, with
the new dbase one taking up to a 20% hit, which is expected as this
micro benchmark context switches a lot and benefits from reducing them
with spin-on-owner feature that range locks lack. Compute otoh was
boosted for higher thread counts.

reaim
                                     v4.15-rc8              v4.15-rc8
                                                   range-mmap_lock-v1
Hmean     compute-1         5652.98 (   0.00%)     5738.64 (   1.52%)
Hmean     compute-21       81997.42 (   0.00%)    81997.42 (  -0.00%)
Hmean     compute-41      135622.27 (   0.00%)   138959.73 (   2.46%)
Hmean     compute-61      179272.55 (   0.00%)   174367.92 (  -2.74%)
Hmean     compute-81      200187.60 (   0.00%)   195250.60 (  -2.47%)
Hmean     compute-101     207337.40 (   0.00%)   187633.35 (  -9.50%)
Hmean     compute-121     179018.55 (   0.00%)   206087.69 (  15.12%)
Hmean     compute-141     175887.20 (   0.00%)   195528.60 (  11.17%)
Hmean     compute-161     198063.33 (   0.00%)   190335.54 (  -3.90%)
Hmean     new_dbase-1         56.64 (   0.00%)       60.76 (   7.27%)
Hmean     new_dbase-21     11149.48 (   0.00%)    10082.35 (  -9.57%)
Hmean     new_dbase-41     25161.87 (   0.00%)    21626.83 ( -14.05%)
Hmean     new_dbase-61     39858.32 (   0.00%)    33956.04 ( -14.81%)
Hmean     new_dbase-81     55057.19 (   0.00%)    43879.73 ( -20.30%)
Hmean     new_dbase-101    67566.57 (   0.00%)    56323.77 ( -16.64%)
Hmean     new_dbase-121    79517.22 (   0.00%)    64877.67 ( -18.41%)
Hmean     new_dbase-141    92365.91 (   0.00%)    76571.18 ( -17.10%)
Hmean     new_dbase-161   101590.77 (   0.00%)    85332.76 ( -16.00%)
Hmean     shared-1            71.26 (   0.00%)       76.43 (   7.26%)
Hmean     shared-21        11546.39 (   0.00%)    10521.92 (  -8.87%)
Hmean     shared-41        28302.97 (   0.00%)    22116.50 ( -21.86%)
Hmean     shared-61        23814.56 (   0.00%)    21886.13 (  -8.10%)
Hmean     shared-81        11578.89 (   0.00%)    16423.55 (  41.84%)
Hmean     shared-101        9991.41 (   0.00%)    11378.95 (  13.89%)
Hmean     shared-121        9884.83 (   0.00%)    10010.92 (   1.28%)
Hmean     shared-141        9911.88 (   0.00%)     9637.14 (  -2.77%)
Hmean     shared-161        8587.14 (   0.00%)     9613.53 (  11.95%)
Stddev    compute-1           94.42 (   0.00%)      166.37 ( -76.20%)
Stddev    compute-21        1915.36 (   0.00%)     2582.96 ( -34.85%)
Stddev    compute-41        4822.88 (   0.00%)     6057.32 ( -25.60%)
Stddev    compute-61        4425.14 (   0.00%)     3676.90 (  16.91%)
Stddev    compute-81        5549.60 (   0.00%)    17213.90 (-210.18%)
Stddev    compute-101      19395.33 (   0.00%)    28315.96 ( -45.99%)
Stddev    compute-121      16140.56 (   0.00%)    27927.63 ( -73.03%)
Stddev    compute-141       9616.27 (   0.00%)    31273.43 (-225.21%)
Stddev    compute-161      34746.00 (   0.00%)    20706.81 (  40.41%)
Stddev    new_dbase-1          1.08 (   0.00%)        0.80 (  25.62%)
Stddev    new_dbase-21       356.67 (   0.00%)      297.23 (  16.66%)
Stddev    new_dbase-41       739.68 (   0.00%)     1287.72 ( -74.09%)
Stddev    new_dbase-61       896.06 (   0.00%)     1293.55 ( -44.36%)
Stddev    new_dbase-81      2003.96 (   0.00%)     2018.08 (  -0.70%)
Stddev    new_dbase-101     2101.25 (   0.00%)     3461.91 ( -64.75%)
Stddev    new_dbase-121     3294.30 (   0.00%)     3917.20 ( -18.91%)
Stddev    new_dbase-141     3488.81 (   0.00%)     5242.36 ( -50.26%)
Stddev    new_dbase-161     2744.12 (   0.00%)     5262.36 ( -91.77%)
Stddev    shared-1             1.38 (   0.00%)        1.24 (   9.84%)
Stddev    shared-21         1930.40 (   0.00%)      232.81 (  87.94%)
Stddev    shared-41         1939.93 (   0.00%)     2316.09 ( -19.39%)
Stddev    shared-61        15001.13 (   0.00%)    12004.82 (  19.97%)
Stddev    shared-81         1313.02 (   0.00%)    14583.51 (-1010.68%)
Stddev    shared-101         355.44 (   0.00%)      393.79 ( -10.79%)
Stddev    shared-121        1736.68 (   0.00%)      782.50 (  54.94%)
Stddev    shared-141        1865.93 (   0.00%)     1140.24 (  38.89%)
Stddev    shared-161        1155.19 (   0.00%)     2045.55 ( -77.07%)

Overall sys% always increases, which is expected, but with the exception
of git-checkout, the worst case scenario is not that excruciating.

Full test and details (including sysbench oltp mysql and specjbb) can be found here:
https://linux-scalability.org/range-mmap_lock/tweed-results/

Testing: I have setup an mmtests config file with all the workloads described:
http://linux-scalability.org/mmtests-config

Applies on top of linux-next (20180202). At least compile tested on
the following architectures:

x86_64, alpha, arm32, blackfin, cris, frv, ia64, m32r, m68k, mips, microblaze
ppc, s390, sparc, tile and xtensa.


Thanks!

Davidlohr Bueso (64):
  interval-tree: build unconditionally
  Introduce range reader/writer lock
  mm: introduce mm locking wrappers
  mm: add a range parameter to the vm_fault structure
  mm,khugepaged: prepare passing of rangelock field to vm_fault
  mm: teach pagefault paths about range locking
  mm/hugetlb: teach hugetlb_fault() about range locking
  mm: teach lock_page_or_retry() about range locking
  mm/mmu_notifier: teach oom reaper about range locking
  kernel/exit: teach exit_mm() about range locking
  prctl: teach about range locking
  fs/userfaultfd: teach userfaultfd_must_wait() about range locking
  fs/proc: teach about range locking
  fs/coredump: teach about range locking
  ipc: use mm locking wrappers
  virt: use mm locking wrappers
  kernel: use mm locking wrappers
  mm/ksm: teach about range locking
  mm/mlock: use mm locking wrappers
  mm/madvise: use mm locking wrappers
  mm: teach drop/take_all_locks() about range locking
  mm: avoid mmap_sem trylock in vm_insert_page()
  mm: huge pagecache: do not check mmap_sem state
  mm/thp: disable mmap_sem is_locked checks
  mm: use mm locking wrappers
  fs: use mm locking wrappers
  arch/{x86,sh,ppc}: teach bad_area() about range locking
  arch/x86: use mm locking wrappers
  arch/alpha: use mm locking wrappers
  arch/tile: use mm locking wrappers
  arch/sparc: use mm locking wrappers
  arch/s390: use mm locking wrappers
  arch/powerpc: use mm locking wrappers
  arch/parisc: use mm locking wrappers
  arch/ia64: use mm locking wrappers
  arch/mips: use mm locking wrappers
  arch/arc: use mm locking wrappers
  arch/blackfin: use mm locking wrappers
  arch/m68k: use mm locking wrappers
  arch/sh: use mm locking wrappers
  arch/cris: use mm locking wrappers
  arch/frv: use mm locking wrappers
  arch/hexagon: use mm locking wrappers
  arch/score: use mm locking wrappers
  arch/m32r: use mm locking wrappers
  arch/metag: use mm locking wrappers
  arch/microblaze: use mm locking wrappers
  arch/tile: use mm locking wrappers
  arch/xtensa: use mm locking wrappers
  arch/unicore32: use mm locking wrappers
  arch/mn10300: use mm locking wrappers
  arch/openrisc: use mm locking wrappers
  arch/nios2: use mm locking wrappers
  arch/arm: use mm locking wrappers
  arch/riscv: use mm locking wrappers
  drivers/android: use mm locking wrappers
  drivers/gpu: use mm locking wrappers
  drivers/infiniband: use mm locking wrappers
  drivers/iommu: use mm locking helpers
  drivers/xen: use mm locking wrappers
  staging/lustre: use generic range lock
  drivers: use mm locking wrappers (the rest)
  mm/mmap: hack drop down_write_nest_lock()
  mm: convert mmap_sem to range mmap_lock

 arch/alpha/kernel/traps.c                          |   6 +-
 arch/alpha/mm/fault.c                              |  13 +-
 arch/arc/kernel/troubleshoot.c                     |   5 +-
 arch/arc/mm/fault.c                                |  15 +-
 arch/arm/kernel/process.c                          |   5 +-
 arch/arm/kernel/swp_emulate.c                      |   5 +-
 arch/arm/lib/uaccess_with_memcpy.c                 |  18 +-
 arch/arm/mm/fault.c                                |  14 +-
 arch/arm/probes/uprobes/core.c                     |   5 +-
 arch/arm64/kernel/traps.c                          |   5 +-
 arch/arm64/kernel/vdso.c                           |  12 +-
 arch/arm64/mm/fault.c                              |  13 +-
 arch/blackfin/kernel/ptrace.c                      |   5 +-
 arch/blackfin/kernel/trace.c                       |   7 +-
 arch/cris/mm/fault.c                               |  13 +-
 arch/frv/mm/fault.c                                |  13 +-
 arch/hexagon/kernel/vdso.c                         |   5 +-
 arch/hexagon/mm/vm_fault.c                         |  11 +-
 arch/ia64/kernel/perfmon.c                         |  10 +-
 arch/ia64/mm/fault.c                               |  13 +-
 arch/ia64/mm/init.c                                |  13 +-
 arch/m32r/mm/fault.c                               |  15 +-
 arch/m68k/kernel/sys_m68k.c                        |  18 +-
 arch/m68k/mm/fault.c                               |  11 +-
 arch/metag/mm/fault.c                              |  13 +-
 arch/microblaze/mm/fault.c                         |  15 +-
 arch/mips/kernel/traps.c                           |   5 +-
 arch/mips/kernel/vdso.c                            |   7 +-
 arch/mips/mm/c-octeon.c                            |   5 +-
 arch/mips/mm/c-r4k.c                               |   5 +-
 arch/mips/mm/fault.c                               |  13 +-
 arch/mn10300/mm/fault.c                            |  13 +-
 arch/nios2/mm/fault.c                              |  15 +-
 arch/nios2/mm/init.c                               |   5 +-
 arch/openrisc/kernel/dma.c                         |   6 +-
 arch/openrisc/mm/fault.c                           |  13 +-
 arch/parisc/kernel/traps.c                         |   7 +-
 arch/parisc/mm/fault.c                             |  11 +-
 arch/powerpc/include/asm/mmu_context.h             |   3 +-
 arch/powerpc/include/asm/powernv.h                 |   5 +-
 arch/powerpc/kernel/vdso.c                         |   7 +-
 arch/powerpc/kvm/book3s_64_mmu_hv.c                |   6 +-
 arch/powerpc/kvm/book3s_64_mmu_radix.c             |   6 +-
 arch/powerpc/kvm/book3s_64_vio.c                   |   5 +-
 arch/powerpc/kvm/book3s_hv.c                       |   7 +-
 arch/powerpc/kvm/e500_mmu_host.c                   |   5 +-
 arch/powerpc/mm/copro_fault.c                      |   8 +-
 arch/powerpc/mm/fault.c                            |  35 +-
 arch/powerpc/mm/mmu_context_iommu.c                |   5 +-
 arch/powerpc/mm/subpage-prot.c                     |  13 +-
 arch/powerpc/oprofile/cell/spu_task_sync.c         |   7 +-
 arch/powerpc/platforms/cell/spufs/file.c           |   6 +-
 arch/powerpc/platforms/powernv/npu-dma.c           |   7 +-
 arch/riscv/kernel/vdso.c                           |   5 +-
 arch/riscv/mm/fault.c                              |  13 +-
 arch/s390/include/asm/gmap.h                       |  14 +-
 arch/s390/kernel/vdso.c                            |   5 +-
 arch/s390/kvm/gaccess.c                            |  35 +-
 arch/s390/kvm/kvm-s390.c                           |  24 +-
 arch/s390/kvm/priv.c                               |  29 +-
 arch/s390/mm/fault.c                               |   9 +-
 arch/s390/mm/gmap.c                                | 125 ++--
 arch/s390/pci/pci_mmio.c                           |   5 +-
 arch/score/mm/fault.c                              |  13 +-
 arch/sh/kernel/sys_sh.c                            |   7 +-
 arch/sh/kernel/vsyscall/vsyscall.c                 |   5 +-
 arch/sh/mm/fault.c                                 |  50 +-
 arch/sparc/mm/fault_32.c                           |  24 +-
 arch/sparc/mm/fault_64.c                           |  15 +-
 arch/sparc/vdso/vma.c                              |   5 +-
 arch/tile/kernel/stack.c                           |   5 +-
 arch/tile/mm/elf.c                                 |  12 +-
 arch/tile/mm/fault.c                               |  15 +-
 arch/tile/mm/pgtable.c                             |   6 +-
 arch/um/include/asm/mmu_context.h                  |   8 +-
 arch/um/kernel/tlb.c                               |  12 +-
 arch/um/kernel/trap.c                              |   9 +-
 arch/unicore32/mm/fault.c                          |  14 +-
 arch/x86/entry/vdso/vma.c                          |  14 +-
 arch/x86/events/core.c                             |   2 +-
 arch/x86/include/asm/mmu_context.h                 |   5 +-
 arch/x86/include/asm/mpx.h                         |   6 +-
 arch/x86/kernel/tboot.c                            |   2 +-
 arch/x86/kernel/vm86_32.c                          |   5 +-
 arch/x86/mm/debug_pagetables.c                     |  13 +-
 arch/x86/mm/fault.c                                |  40 +-
 arch/x86/mm/mpx.c                                  |  55 +-
 arch/x86/um/vdso/vma.c                             |   5 +-
 arch/xtensa/mm/fault.c                             |  13 +-
 drivers/android/binder_alloc.c                     |  12 +-
 drivers/gpu/drm/Kconfig                            |   2 -
 drivers/gpu/drm/amd/amdgpu/amdgpu_mn.c             |   7 +-
 drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c            |  11 +-
 drivers/gpu/drm/amd/amdkfd/kfd_events.c            |   5 +-
 drivers/gpu/drm/i915/Kconfig                       |   1 -
 drivers/gpu/drm/i915/i915_gem.c                    |   5 +-
 drivers/gpu/drm/i915/i915_gem_userptr.c            |  13 +-
 drivers/gpu/drm/radeon/radeon_cs.c                 |   5 +-
 drivers/gpu/drm/radeon/radeon_gem.c                |   7 +-
 drivers/gpu/drm/radeon/radeon_mn.c                 |   7 +-
 drivers/gpu/drm/radeon/radeon_ttm.c                |   4 +-
 drivers/gpu/drm/ttm/ttm_bo_vm.c                    |   4 +-
 drivers/infiniband/core/umem.c                     |  19 +-
 drivers/infiniband/core/umem_odp.c                 |  14 +-
 drivers/infiniband/hw/hfi1/user_pages.c            |  15 +-
 drivers/infiniband/hw/mlx4/main.c                  |   5 +-
 drivers/infiniband/hw/mlx5/main.c                  |   5 +-
 drivers/infiniband/hw/qib/qib_user_pages.c         |  17 +-
 drivers/infiniband/hw/usnic/usnic_uiom.c           |  19 +-
 drivers/iommu/amd_iommu_v2.c                       |   9 +-
 drivers/iommu/intel-svm.c                          |   9 +-
 drivers/media/v4l2-core/videobuf-core.c            |   5 +-
 drivers/media/v4l2-core/videobuf-dma-contig.c      |   5 +-
 drivers/media/v4l2-core/videobuf-dma-sg.c          |  22 +-
 drivers/misc/cxl/cxllib.c                          |   5 +-
 drivers/misc/cxl/fault.c                           |   5 +-
 drivers/misc/mic/scif/scif_rma.c                   |  17 +-
 drivers/misc/sgi-gru/grufault.c                    |  91 +--
 drivers/misc/sgi-gru/grufile.c                     |   5 +-
 drivers/oprofile/buffer_sync.c                     |  12 +-
 drivers/staging/lustre/lustre/llite/Makefile       |   2 +-
 drivers/staging/lustre/lustre/llite/file.c         |  16 +-
 .../staging/lustre/lustre/llite/llite_internal.h   |   4 +-
 drivers/staging/lustre/lustre/llite/llite_mmap.c   |   4 +-
 drivers/staging/lustre/lustre/llite/range_lock.c   | 240 --------
 drivers/staging/lustre/lustre/llite/range_lock.h   |  83 ---
 drivers/staging/lustre/lustre/llite/vvp_io.c       |   7 +-
 .../media/atomisp/pci/atomisp2/hmm/hmm_bo.c        |   5 +-
 drivers/tee/optee/call.c                           |   5 +-
 drivers/vfio/vfio_iommu_spapr_tce.c                |   8 +-
 drivers/vfio/vfio_iommu_type1.c                    |  16 +-
 drivers/xen/gntdev.c                               |   5 +-
 drivers/xen/privcmd.c                              |  12 +-
 fs/aio.c                                           |   7 +-
 fs/binfmt_elf.c                                    |   3 +-
 fs/coredump.c                                      |   5 +-
 fs/exec.c                                          |  38 +-
 fs/proc/base.c                                     |  33 +-
 fs/proc/internal.h                                 |   3 +
 fs/proc/task_mmu.c                                 |  51 +-
 fs/proc/task_nommu.c                               |  22 +-
 fs/proc/vmcore.c                                   |  14 +-
 fs/userfaultfd.c                                   |  64 +-
 include/asm-generic/mm_hooks.h                     |   3 +-
 include/linux/hmm.h                                |   4 +-
 include/linux/huge_mm.h                            |   2 -
 include/linux/hugetlb.h                            |   9 +-
 include/linux/ksm.h                                |   6 +-
 include/linux/lockdep.h                            |  33 +
 include/linux/migrate.h                            |   4 +-
 include/linux/mm.h                                 | 159 ++++-
 include/linux/mm_types.h                           |   4 +-
 include/linux/mmu_notifier.h                       |   6 +-
 include/linux/pagemap.h                            |   7 +-
 include/linux/range_lock.h                         | 189 ++++++
 include/linux/uprobes.h                            |  15 +-
 include/linux/userfaultfd_k.h                      |   5 +-
 ipc/shm.c                                          |  22 +-
 kernel/acct.c                                      |   5 +-
 kernel/events/core.c                               |   5 +-
 kernel/events/uprobes.c                            |  66 +-
 kernel/exit.c                                      |   9 +-
 kernel/fork.c                                      |  18 +-
 kernel/futex.c                                     |   7 +-
 kernel/locking/Makefile                            |   2 +-
 kernel/locking/range_lock.c                        | 667 +++++++++++++++++++++
 kernel/sched/fair.c                                |   5 +-
 kernel/sys.c                                       |  22 +-
 kernel/trace/trace_output.c                        |   5 +-
 lib/Kconfig                                        |  14 -
 lib/Kconfig.debug                                  |   1 -
 lib/Makefile                                       |   3 +-
 mm/filemap.c                                       |   9 +-
 mm/frame_vector.c                                  |   8 +-
 mm/gup.c                                           |  79 ++-
 mm/hmm.c                                           |  37 +-
 mm/hugetlb.c                                       |  16 +-
 mm/init-mm.c                                       |   2 +-
 mm/internal.h                                      |   3 +-
 mm/khugepaged.c                                    |  57 +-
 mm/ksm.c                                           |  64 +-
 mm/madvise.c                                       |  80 ++-
 mm/memcontrol.c                                    |  21 +-
 mm/memory.c                                        |  30 +-
 mm/mempolicy.c                                     |  56 +-
 mm/migrate.c                                       |  30 +-
 mm/mincore.c                                       |  28 +-
 mm/mlock.c                                         |  49 +-
 mm/mmap.c                                          | 145 +++--
 mm/mmu_notifier.c                                  |  14 +-
 mm/mprotect.c                                      |  28 +-
 mm/mremap.c                                        |  34 +-
 mm/msync.c                                         |   9 +-
 mm/nommu.c                                         |  55 +-
 mm/oom_kill.c                                      |  11 +-
 mm/pagewalk.c                                      |  60 +-
 mm/process_vm_access.c                             |   8 +-
 mm/shmem.c                                         |   2 +-
 mm/swapfile.c                                      |   7 +-
 mm/userfaultfd.c                                   |  24 +-
 mm/util.c                                          |  12 +-
 security/tomoyo/domain.c                           |   3 +-
 virt/kvm/arm/mmu.c                                 |  17 +-
 virt/kvm/async_pf.c                                |   7 +-
 virt/kvm/kvm_main.c                                |  25 +-
 205 files changed, 2817 insertions(+), 1651 deletions(-)
 delete mode 100644 drivers/staging/lustre/lustre/llite/range_lock.c
 delete mode 100644 drivers/staging/lustre/lustre/llite/range_lock.h
 create mode 100644 include/linux/range_lock.h
 create mode 100644 kernel/locking/range_lock.c

-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
