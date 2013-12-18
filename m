Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f50.google.com (mail-pb0-f50.google.com [209.85.160.50])
	by kanga.kvack.org (Postfix) with ESMTP id 8F6F56B003A
	for <linux-mm@kvack.org>; Wed, 18 Dec 2013 02:28:22 -0500 (EST)
Received: by mail-pb0-f50.google.com with SMTP id rr13so8059493pbb.23
        for <linux-mm@kvack.org>; Tue, 17 Dec 2013 23:28:22 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id jv8si12155760pbc.96.2013.12.17.23.28.19
        for <linux-mm@kvack.org>;
        Tue, 17 Dec 2013 23:28:20 -0800 (PST)
Date: Wed, 18 Dec 2013 15:28:14 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [PATCH 0/4] Fix ebizzy performance regression due to X86 TLB
 range flush v2
Message-ID: <20131218072814.GA798@localhost>
References: <1386964870-6690-1-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1386964870-6690-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Alex Shi <alex.shi@linaro.org>, Ingo Molnar <mingo@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, H Peter Anvin <hpa@zytor.com>, Linux-X86 <x86@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Hi Mel,

I'd like to share some test numbers with your patches applied on top of v3.13-rc3.

Basically there are

1) no big performance changes

  76628486           -0.7%   76107841       TOTAL vm-scalability.throughput
    407038           +1.2%     412032       TOTAL hackbench.throughput
     50307           -1.5%      49549       TOTAL ebizzy.throughput

2) huge proc-vmstat.nr_tlb_* increases

  99986527         +3e+14%  2.988e+20       TOTAL proc-vmstat.nr_tlb_local_flush_one
 3.812e+08       +2.2e+13%  8.393e+19       TOTAL proc-vmstat.nr_tlb_remote_flush_received
 3.301e+08       +2.2e+13%  7.241e+19       TOTAL proc-vmstat.nr_tlb_remote_flush
   5990864       +1.2e+15%  7.032e+19       TOTAL proc-vmstat.nr_tlb_local_flush_all

Here are the detailed numbers. eabb1f89905a0c809d13 is the HEAD commit
with 4 patches applied. The "~ N%" notations are the stddev percent.
The "[+-] N%" notations are the increase/decrease percent. The
brickland2, lkp-snb01, lkp-ib03 etc. are testbox names.

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
   3345155 ~ 0%      -0.3%    3335172 ~ 0%  brickland2/micro/vm-scalability/16G-shm-pread-rand-mt
  33249939 ~ 0%      +3.3%   34336155 ~ 1%  brickland2/micro/vm-scalability/1T-shm-pread-seq
   4669392 ~ 0%      -0.2%    4660378 ~ 0%  brickland2/micro/vm-scalability/300s-anon-r-rand
  18822426 ~ 5%     -10.2%   16911111 ~ 0%  brickland2/micro/vm-scalability/300s-anon-r-seq-mt
   4993937 ~ 1%      +4.6%    5221846 ~ 2%  brickland2/micro/vm-scalability/300s-anon-rx-rand-mt
   4010960 ~ 0%      +0.4%    4025880 ~ 0%  brickland2/micro/vm-scalability/300s-anon-rx-seq-mt
   7536676 ~ 0%      +1.1%    7617297 ~ 0%  brickland2/micro/vm-scalability/300s-lru-file-readtwice
  76628486           -0.7%   76107841       TOTAL vm-scalability.throughput

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
     88901 ~ 2%      -3.1%      86131 ~ 0%  brickland2/micro/hackbench/600%-process-pipe
    153250 ~ 2%      +3.1%     157931 ~ 1%  brickland2/micro/hackbench/600%-process-socket
    164886 ~ 1%      +1.9%     167969 ~ 0%  lkp-snb01/micro/hackbench/1600%-threads-pipe
    407038           +1.2%     412032       TOTAL hackbench.throughput

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
     50307 ~ 1%      -1.5%      49549 ~ 0%  lkp-ib03/micro/ebizzy/400%-5-30
     50307           -1.5%      49549       TOTAL ebizzy.throughput

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
    270328 ~ 0%    -100.0%          0 ~ 0%  avoton1/crypto/tcrypt/2s-505-509
    512691 ~ 0%  +4.7e+14%  2.412e+18 ~51%  brickland1/micro/will-it-scale/futex1
    510718 ~ 1%  +2.8e+14%  1.408e+18 ~83%  brickland1/micro/will-it-scale/futex2
    514847 ~ 0%  +1.5e+14%   7.66e+17 ~44%  brickland1/micro/will-it-scale/getppid1
    512854 ~ 0%  +1.4e+14%  7.159e+17 ~34%  brickland1/micro/will-it-scale/lock1
    516614 ~ 0%  +8.1e+13%  4.189e+17 ~82%  brickland1/micro/will-it-scale/lseek1
    514457 ~ 1%  +2.2e+14%   1.12e+18 ~71%  brickland1/micro/will-it-scale/lseek2
    533138 ~ 0%  +4.8e+14%  2.561e+18 ~33%  brickland1/micro/will-it-scale/malloc2
    518503 ~ 0%  +2.7e+14%  1.414e+18 ~74%  brickland1/micro/will-it-scale/open1
    512378 ~ 0%  +2.4e+14%  1.232e+18 ~56%  brickland1/micro/will-it-scale/open2
    515078 ~ 0%  +1.8e+14%  9.444e+17 ~23%  brickland1/micro/will-it-scale/page_fault1
    511034 ~ 0%  +1.1e+14%  5.572e+17 ~43%  brickland1/micro/will-it-scale/page_fault2
    516217 ~ 0%  +2.8e+14%  1.457e+18 ~57%  brickland1/micro/will-it-scale/page_fault3
    513735 ~ 0%  +4.5e+13%   2.32e+17 ~75%  brickland1/micro/will-it-scale/pipe1
    513640 ~ 1%  +7.3e+14%  3.766e+18 ~31%  brickland1/micro/will-it-scale/poll1
    515473 ~ 0%  +6.1e+14%  3.138e+18 ~24%  brickland1/micro/will-it-scale/poll2
    517039 ~ 0%    +2e+14%  1.032e+18 ~48%  brickland1/micro/will-it-scale/posix_semaphore1
    513686 ~ 0%    +2e+14%  1.045e+18 ~107%  brickland1/micro/will-it-scale/pread1
    517218 ~ 1%  +1.7e+14%  8.752e+17 ~57%  brickland1/micro/will-it-scale/pread2
    514904 ~ 0%  +1.2e+14%  6.399e+17 ~46%  brickland1/micro/will-it-scale/pthread_mutex1
    512881 ~ 0%  +2.6e+14%  1.314e+18 ~47%  brickland1/micro/will-it-scale/pthread_mutex2
    512844 ~ 0%  +3.1e+14%   1.57e+18 ~91%  brickland1/micro/will-it-scale/pwrite1
    516859 ~ 0%  +2.9e+14%  1.512e+18 ~37%  brickland1/micro/will-it-scale/pwrite2
    513227 ~ 0%  +6.9e+13%  3.518e+17 ~90%  brickland1/micro/will-it-scale/read1
    518291 ~ 0%  +3.6e+14%  1.875e+18 ~18%  brickland1/micro/will-it-scale/read2
    517795 ~ 0%  +4.5e+14%  2.306e+18 ~53%  brickland1/micro/will-it-scale/readseek
    521558 ~ 0%  +4.3e+14%  2.252e+18 ~41%  brickland1/micro/will-it-scale/sched_yield
    518017 ~ 1%  +1.5e+14%   7.85e+17 ~42%  brickland1/micro/will-it-scale/unlink2
    514742 ~ 0%    +4e+14%  2.046e+18 ~53%  brickland1/micro/will-it-scale/write1
    512803 ~ 0%  +4.8e+14%  2.443e+18 ~22%  brickland1/micro/will-it-scale/writeseek
   1777511 ~ 0%  +1.9e+13%  3.363e+17 ~33%  brickland2/micro/hackbench/600%-process-pipe
   2132721 ~ 6%  +5.5e+13%  1.172e+18 ~24%  brickland2/micro/hackbench/600%-process-socket
    886153 ~ 1%  +6.1e+13%  5.427e+17 ~38%  brickland2/micro/hackbench/600%-threads-pipe
    627654 ~ 2%  +2.3e+14%  1.452e+18 ~ 8%  brickland2/micro/hackbench/600%-threads-socket
   5022448 ~ 7%  +9.8e+12%  4.911e+17 ~70%  brickland2/micro/vm-scalability/16G-msync
    655929 ~ 2%  +3.3e+13%  2.161e+17 ~43%  brickland2/micro/vm-scalability/16G-shm-pread-rand-mt
    645229 ~ 1%    +1e+14%  6.675e+17 ~92%  brickland2/micro/vm-scalability/16G-shm-pread-rand
    511508 ~ 1%    +4e+14%  2.054e+18 ~29%  brickland2/micro/vm-scalability/16G-shm-xread-rand-mt
    649861 ~ 0%  +3.7e+13%  2.395e+17 ~62%  brickland2/micro/vm-scalability/16G-shm-xread-rand
    324497 ~ 0%    -100.0%          0 ~ 0%  brickland2/micro/vm-scalability/16G-truncate
    511881 ~ 0%  +9.4e+13%  4.792e+17 ~ 5%  brickland2/micro/vm-scalability/1T-shm-pread-seq-mt
    523080 ~ 0%    +4e+14%  2.087e+18 ~17%  brickland2/micro/vm-scalability/1T-shm-pread-seq
    483125 ~ 1%  +4.6e+14%   2.23e+18 ~13%  brickland2/micro/vm-scalability/1T-shm-xread-seq-mt
    527818 ~ 0%  +3.6e+14%  1.898e+18 ~19%  brickland2/micro/vm-scalability/1T-shm-xread-seq
    449900 ~ 1%  +2.1e+14%  9.422e+17 ~60%  brickland2/micro/vm-scalability/300s-anon-r-seq-mt
    286569 ~ 0%  +7.3e+14%  2.103e+18 ~83%  brickland2/micro/vm-scalability/300s-anon-r-seq
    458987 ~ 0%  +5.7e+13%  2.601e+17 ~35%  brickland2/micro/vm-scalability/300s-anon-rx-rand-mt
    459891 ~ 1%  +1.8e+14%  8.497e+17 ~33%  brickland2/micro/vm-scalability/300s-anon-rx-seq-mt
   1918575 ~ 0%  +2.5e+13%  4.831e+17 ~17%  brickland2/micro/vm-scalability/300s-lru-file-mmap-read-rand
   1691758 ~ 0%  +6.3e+13%   1.06e+18 ~30%  brickland2/micro/vm-scalability/300s-lru-file-mmap-read
    500601 ~ 0%  +7.3e+13%  3.678e+17 ~31%  brickland2/micro/vm-scalability/300s-lru-file-readonce
    471815 ~ 1%  +9.5e+13%  4.485e+17 ~74%  brickland2/micro/vm-scalability/300s-lru-file-readtwice
    499281 ~ 1%  +1.3e+14%  6.267e+17 ~10%  brickland2/micro/vm-scalability/300s-mmap-pread-rand-mt
    541137 ~ 0%  +7.4e+13%  4.026e+17 ~50%  brickland2/micro/vm-scalability/300s-mmap-pread-rand
    422058 ~ 1%  +2.4e+14%  9.997e+17 ~16%  brickland2/micro/vm-scalability/300s-mmap-pread-seq
    486583 ~ 2%  +1.3e+14%  6.117e+17 ~37%  brickland2/micro/vm-scalability/300s-mmap-xread-rand-mt
    429204 ~ 2%  +4.2e+14%  1.792e+18 ~ 6%  brickland2/micro/vm-scalability/300s-mmap-xread-seq-mt
    358178 ~ 0%  +4.4e+14%   1.58e+18 ~ 9%  fat/micro/dd-write/1HDD-cfq-btrfs-100dd
    335104 ~ 0%  +5.5e+14%  1.848e+18 ~16%  fat/micro/dd-write/1HDD-cfq-btrfs-10dd
    331175 ~ 0%  +4.4e+14%  1.471e+18 ~44%  fat/micro/dd-write/1HDD-cfq-btrfs-1dd
    356821 ~ 0%  +2.4e+14%  8.612e+17 ~63%  fat/micro/dd-write/1HDD-cfq-xfs-100dd
    336606 ~ 0%    +2e+14%  6.822e+17 ~73%  fat/micro/dd-write/1HDD-cfq-xfs-10dd
    329511 ~ 0%  +2.9e+14%  9.518e+17 ~63%  fat/micro/dd-write/1HDD-cfq-xfs-1dd
    335872 ~ 0%  +4.6e+14%   1.55e+18 ~ 2%  fat/micro/dd-write/1HDD-deadline-btrfs-10dd
    332429 ~ 0%  +3.2e+14%  1.051e+18 ~61%  fat/micro/dd-write/1HDD-deadline-btrfs-1dd
    359230 ~ 0%  +1.8e+14%  6.545e+17 ~50%  fat/micro/dd-write/1HDD-deadline-ext4-100dd
    335957 ~ 0%  +2.9e+14%   9.75e+17 ~25%  fat/micro/dd-write/1HDD-deadline-ext4-10dd
    333178 ~ 0%  +1.1e+14%  3.511e+17 ~65%  fat/micro/dd-write/1HDD-deadline-ext4-1dd
    357406 ~ 0%  +7.1e+14%   2.55e+18 ~22%  fat/micro/dd-write/1HDD-deadline-xfs-100dd
    332342 ~ 0%    +4e+14%  1.319e+18 ~11%  fat/micro/dd-write/1HDD-deadline-xfs-10dd
    331823 ~ 0%  +2.2e+14%  7.247e+17 ~58%  fat/micro/dd-write/1HDD-deadline-xfs-1dd
    103797 ~ 0%    -100.0%          1 ~141%  lkp-a04/micro/netperf/120s-200%-TCP_RR
  29352723 ~ 0%  +1.8e+12%  5.199e+17 ~68%  lkp-ib03/micro/netperf/120s-200%-TCP_CRR
    253764 ~ 0%  +1.5e+14%  3.723e+17 ~41%  lkp-ib03/micro/netperf/120s-200%-TCP_MAERTS
    251460 ~ 1%  +1.2e+14%   3.09e+17 ~66%  lkp-ib03/micro/netperf/120s-200%-TCP_RR
    252357 ~ 1%  +1.8e+14%  4.643e+17 ~42%  lkp-ib03/micro/netperf/120s-200%-UDP_RR
   2802319 ~ 3%  +8.8e+12%  2.476e+17 ~83%  lkp-nex05/micro/hackbench/800%-process-pipe
   2344699 ~ 0%  +3.1e+13%  7.351e+17 ~24%  lkp-nex05/micro/hackbench/800%-process-socket
    944933 ~ 2%  +4.3e+13%   4.06e+17 ~ 7%  lkp-nex05/micro/hackbench/800%-threads-pipe
    763122 ~ 0%  +5.6e+13%  4.296e+17 ~61%  lkp-nex05/micro/hackbench/800%-threads-socket
    265113 ~ 0%    -100.0%          0       lkp-nex05/micro/tlbflush/100%-8
   1375290 ~ 3%  +2.4e+13%  3.263e+17 ~51%  lkp-snb01/micro/hackbench/1600%-threads-pipe
   1141467 ~ 1%  +1.7e+13%  1.977e+17 ~40%  lkp-snb01/micro/hackbench/1600%-threads-socket
    789789 ~ 0%  +1.7e+15%   1.37e+19 ~ 2%  lkp-ws02/micro/dd-write/11HDD-JBOD-cfq-btrfs-100dd
    559134 ~ 0%  +2.2e+15%  1.211e+19 ~ 1%  lkp-ws02/micro/dd-write/11HDD-JBOD-cfq-btrfs-10dd
    533188 ~ 0%  +2.1e+15%  1.105e+19 ~ 5%  lkp-ws02/micro/dd-write/11HDD-JBOD-cfq-btrfs-1dd
    794948 ~ 0%  +1.9e+15%  1.518e+19 ~ 1%  lkp-ws02/micro/dd-write/11HDD-JBOD-cfq-ext4-100dd
    555237 ~ 0%  +2.4e+15%   1.35e+19 ~ 1%  lkp-ws02/micro/dd-write/11HDD-JBOD-cfq-ext4-10dd
    531695 ~ 0%  +1.5e+15%  8.153e+18 ~11%  lkp-ws02/micro/dd-write/11HDD-JBOD-cfq-ext4-1dd
    778886 ~ 0%  +1.9e+15%  1.517e+19 ~ 2%  lkp-ws02/micro/dd-write/11HDD-JBOD-cfq-xfs-100dd
    549300 ~ 0%  +2.3e+15%  1.283e+19 ~ 0%  lkp-ws02/micro/dd-write/11HDD-JBOD-cfq-xfs-10dd
    527275 ~ 0%  +1.2e+15%   6.59e+18 ~12%  lkp-ws02/micro/dd-write/11HDD-JBOD-cfq-xfs-1dd
    794872 ~ 0%  +1.9e+15%  1.506e+19 ~ 0%  lkp-ws02/micro/dd-write/11HDD-JBOD-deadline-ext4-100dd
    553822 ~ 0%  +2.4e+15%  1.306e+19 ~ 2%  lkp-ws02/micro/dd-write/11HDD-JBOD-deadline-ext4-10dd
    529079 ~ 0%  +1.5e+15%  7.958e+18 ~ 2%  lkp-ws02/micro/dd-write/11HDD-JBOD-deadline-ext4-1dd
    776427 ~ 0%    +2e+15%  1.552e+19 ~ 1%  lkp-ws02/micro/dd-write/11HDD-JBOD-deadline-xfs-100dd
    546912 ~ 0%  +2.3e+15%  1.263e+19 ~ 3%  lkp-ws02/micro/dd-write/11HDD-JBOD-deadline-xfs-10dd
    523882 ~ 0%  +1.3e+15%  6.782e+18 ~ 7%  lkp-ws02/micro/dd-write/11HDD-JBOD-deadline-xfs-1dd
    466018 ~ 0%  +7.2e+14%  3.362e+18 ~ 4%  snb-drag/sysbench/fileio/600s-100%-1HDD-btrfs-64G-1024-seqrewr-sync
    465694 ~ 0%  +7.5e+14%  3.494e+18 ~20%  snb-drag/sysbench/fileio/600s-100%-1HDD-btrfs-64G-1024-seqwr-sync
    636199 ~ 1%  +1.4e+14%    8.6e+17 ~38%  snb-drag/sysbench/fileio/600s-100%-1HDD-ext4-64G-1024-rndrd-sync
    628230 ~ 1%  +1.3e+14%  7.951e+17 ~14%  snb-drag/sysbench/fileio/600s-100%-1HDD-ext4-64G-1024-rndrw-sync
    624286 ~ 0%  +9.9e+14%  6.187e+18 ~ 2%  snb-drag/sysbench/fileio/600s-100%-1HDD-ext4-64G-1024-seqrd-sync
    470666 ~ 1%  +3.7e+14%  1.748e+18 ~ 5%  snb-drag/sysbench/fileio/600s-100%-1HDD-ext4-64G-1024-seqrewr-sync
    465417 ~ 0%  +5.1e+14%  2.354e+18 ~32%  snb-drag/sysbench/fileio/600s-100%-1HDD-ext4-64G-1024-seqwr-sync
    581600 ~ 0%  +1.4e+14%  8.304e+17 ~15%  snb-drag/sysbench/fileio/600s-100%-1HDD-xfs-64G-1024-rndrd-sync
    581818 ~ 0%  +1.9e+14%  1.097e+18 ~57%  snb-drag/sysbench/fileio/600s-100%-1HDD-xfs-64G-1024-rndrw-sync
    467899 ~ 0%  +2.3e+13%  1.061e+17 ~22%  snb-drag/sysbench/fileio/600s-100%-1HDD-xfs-64G-1024-rndwr-sync
    582271 ~ 0%  +1.2e+15%  7.192e+18 ~ 5%  snb-drag/sysbench/fileio/600s-100%-1HDD-xfs-64G-1024-seqrd-sync
    471064 ~ 1%  +2.8e+14%  1.305e+18 ~18%  snb-drag/sysbench/fileio/600s-100%-1HDD-xfs-64G-1024-seqrewr-sync
    464862 ~ 0%  +5.6e+14%  2.612e+18 ~13%  snb-drag/sysbench/fileio/600s-100%-1HDD-xfs-64G-1024-seqwr-sync
  99986527         +3e+14%  2.988e+20       TOTAL proc-vmstat.nr_tlb_local_flush_one

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
       393 ~ 1%     -85.7%         56 ~28%  avoton1/crypto/tcrypt/2s-505-509
     15803 ~11%  +1.2e+16%  1.965e+18 ~65%  brickland1/micro/will-it-scale/futex1
      4913 ~12%  +3.2e+16%  1.554e+18 ~84%  brickland1/micro/will-it-scale/futex2
     12852 ~85%  +3.4e+15%  4.376e+17 ~45%  brickland1/micro/will-it-scale/futex4
     14179 ~47%  +6.3e+15%  8.988e+17 ~47%  brickland1/micro/will-it-scale/getppid1
     12671 ~27%  +6.9e+15%  8.774e+17 ~20%  brickland1/micro/will-it-scale/lock1
     13765 ~10%  +3.1e+15%   4.23e+17 ~80%  brickland1/micro/will-it-scale/lseek1
      9585 ~64%  +1.4e+16%  1.334e+18 ~81%  brickland1/micro/will-it-scale/lseek2
     13775 ~43%  +1.9e+16%  2.658e+18 ~36%  brickland1/micro/will-it-scale/malloc2
      8969 ~58%    +1e+16%  9.329e+17 ~61%  brickland1/micro/will-it-scale/open1
      8056 ~30%  +1.6e+16%  1.253e+18 ~57%  brickland1/micro/will-it-scale/open2
     12380 ~45%    +8e+15%   9.92e+17 ~44%  brickland1/micro/will-it-scale/page_fault1
     15214 ~54%  +3.9e+15%   5.92e+17 ~53%  brickland1/micro/will-it-scale/page_fault2
     10910 ~23%  +1.1e+16%   1.19e+18 ~85%  brickland1/micro/will-it-scale/page_fault3
     20099 ~55%  +1.9e+15%  3.798e+17 ~66%  brickland1/micro/will-it-scale/pipe1
      8468 ~54%  +4.1e+16%  3.458e+18 ~39%  brickland1/micro/will-it-scale/poll1
     14578 ~28%  +2.4e+16%  3.558e+18 ~ 8%  brickland1/micro/will-it-scale/poll2
     12628 ~16%  +8.1e+15%  1.027e+18 ~50%  brickland1/micro/will-it-scale/posix_semaphore1
      5493 ~11%  +2.5e+16%  1.349e+18 ~103%  brickland1/micro/will-it-scale/pread1
     12278 ~29%  +5.4e+15%  6.626e+17 ~39%  brickland1/micro/will-it-scale/pread2
     12944 ~19%  +6.7e+15%    8.7e+17 ~66%  brickland1/micro/will-it-scale/pthread_mutex1
     11687 ~66%  +9.9e+15%   1.16e+18 ~64%  brickland1/micro/will-it-scale/pthread_mutex2
     20841 ~16%  +9.1e+15%  1.907e+18 ~101%  brickland1/micro/will-it-scale/pwrite1
     16466 ~56%  +8.8e+15%  1.441e+18 ~35%  brickland1/micro/will-it-scale/pwrite2
     12778 ~42%  +2.7e+15%  3.469e+17 ~91%  brickland1/micro/will-it-scale/read1
     12599 ~34%  +1.6e+16%  2.013e+18 ~22%  brickland1/micro/will-it-scale/read2
     10827 ~35%  +1.9e+16%  2.047e+18 ~59%  brickland1/micro/will-it-scale/readseek
     12148 ~40%  +1.9e+16%  2.274e+18 ~41%  brickland1/micro/will-it-scale/sched_yield
     15135 ~13%  +2.4e+15%  3.685e+17 ~69%  brickland1/micro/will-it-scale/unix1
     10193 ~24%  +5.5e+15%  5.606e+17 ~80%  brickland1/micro/will-it-scale/unlink1
     12863 ~10%  +4.8e+15%  6.189e+17 ~29%  brickland1/micro/will-it-scale/unlink2
     13792 ~66%  +1.3e+16%    1.8e+18 ~72%  brickland1/micro/will-it-scale/write1
      9516 ~64%  +2.6e+16%  2.468e+18 ~21%  brickland1/micro/will-it-scale/writeseek
     10528 ~46%  +3.5e+15%  3.672e+17 ~18%  brickland2/micro/hackbench/600%-process-pipe
      5690 ~31%  +1.6e+16%   9.28e+17 ~45%  brickland2/micro/hackbench/600%-process-socket
     51573 ~27%  +9.6e+14%   4.94e+17 ~53%  brickland2/micro/hackbench/600%-threads-pipe
     95291 ~44%  +1.1e+15%  1.062e+18 ~ 6%  brickland2/micro/hackbench/600%-threads-socket
     51844 ~10%  +5.5e+14%   2.86e+17 ~105%  brickland2/micro/vm-scalability/16G-msync
     13334 ~80%  +1.6e+15%  2.094e+17 ~68%  brickland2/micro/vm-scalability/16G-shm-pread-rand-mt
      6719 ~49%    +1e+16%  6.792e+17 ~89%  brickland2/micro/vm-scalability/16G-shm-pread-rand
      9280 ~57%    +2e+16%  1.868e+18 ~15%  brickland2/micro/vm-scalability/16G-shm-xread-rand-mt
     13979 ~52%  +1.7e+15%  2.309e+17 ~23%  brickland2/micro/vm-scalability/16G-shm-xread-rand
     17219 ~28%    -100.0%          1 ~70%  brickland2/micro/vm-scalability/16G-truncate
     15478 ~ 6%  +2.5e+15%   3.82e+17 ~14%  brickland2/micro/vm-scalability/1T-shm-pread-seq-mt
      9384 ~50%  +2.1e+16%  1.927e+18 ~27%  brickland2/micro/vm-scalability/1T-shm-pread-seq
      4074 ~12%  +5.1e+16%  2.073e+18 ~19%  brickland2/micro/vm-scalability/1T-shm-xread-seq-mt
     17303 ~57%    +1e+16%  1.774e+18 ~20%  brickland2/micro/vm-scalability/1T-shm-xread-seq
      7018 ~10%  +7.9e+15%  5.548e+17 ~45%  brickland2/micro/vm-scalability/300s-anon-r-seq-mt
     25135 ~13%  +8.2e+15%  2.071e+18 ~79%  brickland2/micro/vm-scalability/300s-anon-r-seq
      8835 ~36%  +1.1e+16%  1.003e+18 ~109%  brickland2/micro/vm-scalability/300s-anon-rx-rand-mt
      4975 ~28%  +1.2e+16%  5.832e+17 ~40%  brickland2/micro/vm-scalability/300s-anon-rx-seq-mt
 1.682e+08 ~ 1%  +2.7e+11%  4.532e+17 ~ 5%  brickland2/micro/vm-scalability/300s-lru-file-mmap-read-rand
 1.578e+08 ~ 0%    +6e+11%  9.516e+17 ~35%  brickland2/micro/vm-scalability/300s-lru-file-mmap-read
     16968 ~26%  +1.8e+15%  3.027e+17 ~52%  brickland2/micro/vm-scalability/300s-lru-file-readonce
     10641 ~50%    +4e+15%   4.27e+17 ~50%  brickland2/micro/vm-scalability/300s-lru-file-readtwice
     12265 ~46%    +5e+15%  6.188e+17 ~11%  brickland2/micro/vm-scalability/300s-mmap-pread-rand-mt
     12728 ~45%  +3.1e+15%  3.979e+17 ~35%  brickland2/micro/vm-scalability/300s-mmap-pread-rand
     21516 ~ 9%  +4.4e+15%  9.517e+17 ~ 8%  brickland2/micro/vm-scalability/300s-mmap-pread-seq
     12009 ~83%  +4.6e+15%  5.548e+17 ~45%  brickland2/micro/vm-scalability/300s-mmap-xread-rand-mt
     13007 ~51%  +1.4e+16%  1.792e+18 ~15%  brickland2/micro/vm-scalability/300s-mmap-xread-seq-mt
      4428 ~12%    +2e+16%  8.883e+17 ~ 7%  fat/micro/dd-write/1HDD-cfq-btrfs-100dd
       769 ~21%  +1.8e+17%  1.351e+18 ~ 9%  fat/micro/dd-write/1HDD-cfq-btrfs-10dd
       420 ~ 3%  +2.2e+17%  9.427e+17 ~24%  fat/micro/dd-write/1HDD-cfq-btrfs-1dd
      4840 ~ 9%    +1e+15%  4.839e+16 ~92%  fat/micro/dd-write/1HDD-cfq-xfs-100dd
      1447 ~ 2%    +2e+16%  2.953e+17 ~56%  fat/micro/dd-write/1HDD-cfq-xfs-10dd
       378 ~25%  +4.9e+16%  1.871e+17 ~75%  fat/micro/dd-write/1HDD-cfq-xfs-1dd
       751 ~27%  +1.6e+17%  1.202e+18 ~ 3%  fat/micro/dd-write/1HDD-deadline-btrfs-10dd
       424 ~13%  +1.9e+17%  8.096e+17 ~44%  fat/micro/dd-write/1HDD-deadline-btrfs-1dd
      4650 ~ 8%  +1.2e+15%  5.675e+16 ~44%  fat/micro/dd-write/1HDD-deadline-ext4-100dd
      1179 ~21%  +1.5e+16%  1.725e+17 ~116%  fat/micro/dd-write/1HDD-deadline-ext4-10dd
       327 ~27%  +2.9e+16%  9.597e+16 ~86%  fat/micro/dd-write/1HDD-deadline-ext4-1dd
      4657 ~ 9%  +1.6e+15%  7.341e+16 ~67%  fat/micro/dd-write/1HDD-deadline-xfs-100dd
       908 ~13%  +2.9e+16%  2.589e+17 ~31%  fat/micro/dd-write/1HDD-deadline-xfs-10dd
       406 ~20%  +3.5e+16%   1.43e+17 ~141%  fat/micro/dd-write/1HDD-deadline-xfs-1dd
       222 ~ 2%  +7.2e+16%  1.597e+17 ~ 0%  lkp-a04/micro/netperf/120s-200%-TCP_CRR
       215 ~ 4%     -99.4%          1 ~141%  lkp-a04/micro/netperf/120s-200%-TCP_RR
      1547 ~ 2%  +3.3e+16%  5.041e+17 ~61%  lkp-ib03/micro/netperf/120s-200%-TCP_CRR
      1535 ~ 0%  +2.3e+16%  3.583e+17 ~48%  lkp-ib03/micro/netperf/120s-200%-TCP_MAERTS
      1462 ~ 3%  +1.6e+16%  2.332e+17 ~77%  lkp-ib03/micro/netperf/120s-200%-TCP_RR
      1419 ~17%  +2.2e+16%  3.102e+17 ~20%  lkp-ib03/micro/netperf/120s-200%-UDP_RR
  52605367 ~ 5%    +5e+11%  2.654e+17 ~50%  lkp-nex04/micro/ebizzy/400%-5-30
      1907 ~ 3%  +1.2e+16%  2.253e+17 ~87%  lkp-nex05/micro/hackbench/800%-process-pipe
      1845 ~ 2%  +2.4e+16%  4.353e+17 ~24%  lkp-nex05/micro/hackbench/800%-process-socket
    117908 ~15%  +2.3e+14%  2.681e+17 ~21%  lkp-nex05/micro/hackbench/800%-threads-pipe
    183191 ~82%  +2.1e+14%  3.871e+17 ~63%  lkp-nex05/micro/hackbench/800%-threads-socket
    678123 ~ 2%    -100.0%         24 ~141%  lkp-nex05/micro/tlbflush/100%-8
    259357 ~ 4%    +1e+14%  2.723e+17 ~32%  lkp-snb01/micro/hackbench/1600%-threads-pipe
    381071 ~22%  +3.9e+13%  1.497e+17 ~33%  lkp-snb01/micro/hackbench/1600%-threads-socket
     15987 ~ 0%    +3e+15%  4.763e+17 ~20%  lkp-ws02/micro/dd-write/11HDD-JBOD-cfq-btrfs-100dd
      2759 ~ 2%  +2.4e+16%  6.527e+17 ~25%  lkp-ws02/micro/dd-write/11HDD-JBOD-cfq-btrfs-10dd
       847 ~ 5%  +1.2e+17%  9.831e+17 ~30%  lkp-ws02/micro/dd-write/11HDD-JBOD-cfq-btrfs-1dd
     14573 ~ 2%  +1.3e+14%  1.943e+16 ~70%  lkp-ws02/micro/dd-write/11HDD-JBOD-cfq-ext4-100dd
      3509 ~ 8%    +2e+15%  6.971e+16 ~40%  lkp-ws02/micro/dd-write/11HDD-JBOD-cfq-ext4-10dd
       783 ~ 1%  +1.7e+16%  1.365e+17 ~54%  lkp-ws02/micro/dd-write/11HDD-JBOD-cfq-ext4-1dd
     15418 ~ 1%    +3e+14%  4.676e+16 ~102%  lkp-ws02/micro/dd-write/11HDD-JBOD-cfq-xfs-100dd
      3521 ~ 8%  +3.4e+15%  1.209e+17 ~37%  lkp-ws02/micro/dd-write/11HDD-JBOD-cfq-xfs-10dd
       750 ~ 0%  +3.8e+16%  2.836e+17 ~59%  lkp-ws02/micro/dd-write/11HDD-JBOD-cfq-xfs-1dd
     15271 ~ 1%  +6.1e+13%  9.373e+15 ~141%  lkp-ws02/micro/dd-write/11HDD-JBOD-deadline-ext4-100dd
      3663 ~ 3%  +2.1e+15%  7.845e+16 ~40%  lkp-ws02/micro/dd-write/11HDD-JBOD-deadline-ext4-10dd
       811 ~ 4%  +6.3e+16%  5.119e+17 ~33%  lkp-ws02/micro/dd-write/11HDD-JBOD-deadline-ext4-1dd
     15401 ~ 1%  +2.3e+14%  3.542e+16 ~72%  lkp-ws02/micro/dd-write/11HDD-JBOD-deadline-xfs-100dd
      3601 ~12%  +4.1e+15%  1.462e+17 ~51%  lkp-ws02/micro/dd-write/11HDD-JBOD-deadline-xfs-10dd
       830 ~ 5%  +1.3e+16%  1.076e+17 ~53%  lkp-ws02/micro/dd-write/11HDD-JBOD-deadline-xfs-1dd
      1758 ~ 3%  +1.1e+17%  1.901e+18 ~ 9%  snb-drag/sysbench/fileio/600s-100%-1HDD-btrfs-64G-1024-seqrewr-sync
      1729 ~ 2%  +9.3e+16%  1.609e+18 ~ 3%  snb-drag/sysbench/fileio/600s-100%-1HDD-btrfs-64G-1024-seqwr-sync
       984 ~ 8%  +1.3e+07%  1.323e+08 ~39%  snb-drag/sysbench/fileio/600s-100%-1HDD-ext4-64G-1024-rndrd-sync
      1170 ~21%    +1e+07%  1.225e+08 ~12%  snb-drag/sysbench/fileio/600s-100%-1HDD-ext4-64G-1024-rndrw-sync
      1024 ~14%  +7.5e+05%    7730209 ~33%  snb-drag/sysbench/fileio/600s-100%-1HDD-ext4-64G-1024-rndwr-sync
      1512 ~ 4%  +8.8e+14%  1.336e+16 ~141%  snb-drag/sysbench/fileio/600s-100%-1HDD-ext4-64G-1024-seqrd-sync
      2073 ~ 3%  +1.2e+07%  2.403e+08 ~10%  snb-drag/sysbench/fileio/600s-100%-1HDD-ext4-64G-1024-seqrewr-sync
      2213 ~ 3%  +1.4e+07%  3.113e+08 ~33%  snb-drag/sysbench/fileio/600s-100%-1HDD-ext4-64G-1024-seqwr-sync
       805 ~13%  +6.6e+15%  5.352e+16 ~92%  snb-drag/sysbench/fileio/600s-100%-1HDD-xfs-64G-1024-rndrd-sync
      1048 ~ 3%  +6.6e+15%  6.933e+16 ~40%  snb-drag/sysbench/fileio/600s-100%-1HDD-xfs-64G-1024-rndrw-sync
      1097 ~ 4%    +6e+15%  6.557e+16 ~45%  snb-drag/sysbench/fileio/600s-100%-1HDD-xfs-64G-1024-rndwr-sync
      1531 ~ 3%  +4.7e+15%  7.266e+16 ~19%  snb-drag/sysbench/fileio/600s-100%-1HDD-xfs-64G-1024-seqrd-sync
      1800 ~ 9%    +1e+07%  1.852e+08 ~18%  snb-drag/sysbench/fileio/600s-100%-1HDD-xfs-64G-1024-seqrewr-sync
      1962 ~ 2%  +5.2e+14%  1.016e+16 ~141%  snb-drag/sysbench/fileio/600s-100%-1HDD-xfs-64G-1024-seqwr-sync
 3.812e+08       +2.2e+13%  8.393e+19       TOTAL proc-vmstat.nr_tlb_remote_flush_received

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
       136 ~ 4%    -100.0%          0 ~ 0%  avoton1/crypto/tcrypt/2s-505-509
       215 ~ 7%    +1e+18%  2.238e+18 ~47%  brickland1/micro/will-it-scale/futex1
       142 ~ 2%  +1.1e+18%   1.55e+18 ~87%  brickland1/micro/will-it-scale/futex2
       186 ~18%  +2.8e+17%  5.303e+17 ~82%  brickland1/micro/will-it-scale/getppid1
       198 ~16%  +3.8e+17%  7.492e+17 ~30%  brickland1/micro/will-it-scale/lock1
       185 ~ 5%  +2.3e+17%  4.223e+17 ~81%  brickland1/micro/will-it-scale/lseek1
       165 ~ 9%  +7.9e+17%  1.307e+18 ~81%  brickland1/micro/will-it-scale/lseek2
       199 ~ 9%  +1.2e+18%  2.462e+18 ~38%  brickland1/micro/will-it-scale/malloc2
       187 ~11%  +5.9e+17%  1.095e+18 ~71%  brickland1/micro/will-it-scale/open1
       211 ~29%    +6e+17%  1.263e+18 ~59%  brickland1/micro/will-it-scale/open2
       258 ~ 6%  +2.8e+17%  7.292e+17 ~39%  brickland1/micro/will-it-scale/page_fault1
       310 ~18%  +1.3e+17%  4.018e+17 ~28%  brickland1/micro/will-it-scale/page_fault2
       357 ~ 8%  +3.3e+17%  1.161e+18 ~88%  brickland1/micro/will-it-scale/page_fault3
       232 ~31%  +1.8e+17%  4.117e+17 ~64%  brickland1/micro/will-it-scale/pipe1
       250 ~26%  +1.3e+18%   3.23e+18 ~33%  brickland1/micro/will-it-scale/poll1
       208 ~ 8%  +1.5e+18%  3.172e+18 ~12%  brickland1/micro/will-it-scale/poll2
       198 ~13%  +5.1e+17%  1.013e+18 ~51%  brickland1/micro/will-it-scale/posix_semaphore1
       179 ~ 9%  +6.2e+17%  1.117e+18 ~112%  brickland1/micro/will-it-scale/pread1
       714 ~ 4%    +1e+17%  7.243e+17 ~36%  brickland1/micro/will-it-scale/pread2
       259 ~ 8%  +2.8e+17%  7.329e+17 ~62%  brickland1/micro/will-it-scale/pthread_mutex1
       190 ~ 5%  +7.6e+17%  1.456e+18 ~36%  brickland1/micro/will-it-scale/pthread_mutex2
       281 ~41%  +6.9e+17%  1.952e+18 ~102%  brickland1/micro/will-it-scale/pwrite1
       682 ~13%    +2e+17%  1.362e+18 ~36%  brickland1/micro/will-it-scale/pwrite2
       224 ~45%  +1.5e+17%  3.452e+17 ~92%  brickland1/micro/will-it-scale/read1
       279 ~11%  +6.6e+17%   1.83e+18 ~14%  brickland1/micro/will-it-scale/read2
       187 ~ 9%  +1.2e+18%  2.203e+18 ~55%  brickland1/micro/will-it-scale/readseek
       207 ~10%  +1.2e+18%  2.535e+18 ~21%  brickland1/micro/will-it-scale/sched_yield
       198 ~ 8%  +2.1e+17%  4.259e+17 ~36%  brickland1/micro/will-it-scale/unlink2
       219 ~22%  +8.3e+17%  1.823e+18 ~76%  brickland1/micro/will-it-scale/write1
       183 ~23%  +1.3e+18%   2.39e+18 ~26%  brickland1/micro/will-it-scale/writeseek
       256 ~22%  +1.3e+17%  3.385e+17 ~21%  brickland2/micro/hackbench/600%-process-pipe
       237 ~11%  +3.8e+17%  8.978e+17 ~36%  brickland2/micro/hackbench/600%-process-socket
      2000 ~30%  +2.4e+16%  4.869e+17 ~42%  brickland2/micro/hackbench/600%-threads-pipe
      2742 ~10%  +3.8e+16%  1.042e+18 ~12%  brickland2/micro/hackbench/600%-threads-socket
     46754 ~11%  +1.1e+15%  5.134e+17 ~51%  brickland2/micro/vm-scalability/16G-msync
      1296 ~19%  +1.8e+16%  2.275e+17 ~48%  brickland2/micro/vm-scalability/16G-shm-pread-rand-mt
       427 ~ 9%  +1.5e+17%  6.322e+17 ~89%  brickland2/micro/vm-scalability/16G-shm-pread-rand
       469 ~11%  +4.7e+17%  2.208e+18 ~29%  brickland2/micro/vm-scalability/16G-shm-xread-rand-mt
       429 ~22%  +4.3e+16%   1.86e+17 ~19%  brickland2/micro/vm-scalability/16G-shm-xread-rand
       278 ~32%    -100.0%          0 ~ 0%  brickland2/micro/vm-scalability/16G-truncate
      1044 ~12%  +3.9e+16%  4.044e+17 ~21%  brickland2/micro/vm-scalability/1T-shm-pread-seq-mt
      1027 ~ 0%  +1.9e+17%  1.989e+18 ~23%  brickland2/micro/vm-scalability/1T-shm-pread-seq
       334 ~25%    +6e+17%  2.005e+18 ~10%  brickland2/micro/vm-scalability/1T-shm-xread-seq-mt
      1007 ~10%  +1.6e+17%   1.61e+18 ~18%  brickland2/micro/vm-scalability/1T-shm-xread-seq
       191 ~ 9%    +2e+17%  3.891e+17 ~88%  brickland2/micro/vm-scalability/300s-anon-r-rand
       204 ~10%  +2.5e+17%  5.182e+17 ~49%  brickland2/micro/vm-scalability/300s-anon-r-seq-mt
       263 ~23%  +7.8e+17%  2.054e+18 ~88%  brickland2/micro/vm-scalability/300s-anon-r-seq
       189 ~33%  +6.5e+17%  1.227e+18 ~115%  brickland2/micro/vm-scalability/300s-anon-rx-rand-mt
       158 ~38%  +3.9e+17%  6.175e+17 ~45%  brickland2/micro/vm-scalability/300s-anon-rx-seq-mt
 1.683e+08 ~ 1%  +2.4e+11%  4.035e+17 ~36%  brickland2/micro/vm-scalability/300s-lru-file-mmap-read-rand
 1.578e+08 ~ 0%  +5.5e+11%  8.677e+17 ~34%  brickland2/micro/vm-scalability/300s-lru-file-mmap-read
       429 ~ 5%  +7.3e+16%  3.133e+17 ~39%  brickland2/micro/vm-scalability/300s-lru-file-readonce
       205 ~22%  +2.5e+17%    5.1e+17 ~86%  brickland2/micro/vm-scalability/300s-lru-file-readtwice
       555 ~ 7%  +1.1e+17%  6.182e+17 ~ 6%  brickland2/micro/vm-scalability/300s-mmap-pread-rand-mt
       221 ~11%  +1.7e+17%  3.722e+17 ~48%  brickland2/micro/vm-scalability/300s-mmap-pread-rand
       389 ~15%  +2.3e+17%  8.909e+17 ~20%  brickland2/micro/vm-scalability/300s-mmap-pread-seq
      1130 ~ 7%  +4.1e+16%  4.646e+17 ~35%  brickland2/micro/vm-scalability/300s-mmap-xread-rand-mt
       654 ~ 8%  +2.2e+17%  1.436e+18 ~15%  brickland2/micro/vm-scalability/300s-mmap-xread-seq-mt
      4330 ~12%  +1.1e+15%    4.7e+16 ~87%  fat/micro/dd-write/1HDD-cfq-btrfs-100dd
       678 ~22%    +4e+16%  2.689e+17 ~25%  fat/micro/dd-write/1HDD-cfq-btrfs-10dd
       320 ~ 7%  +3.4e+16%  1.098e+17 ~33%  fat/micro/dd-write/1HDD-cfq-btrfs-1dd
      4749 ~ 9%  +3.8e+14%  1.794e+16 ~122%  fat/micro/dd-write/1HDD-cfq-xfs-100dd
      1339 ~ 2%  +6.1e+15%  8.145e+16 ~86%  fat/micro/dd-write/1HDD-cfq-xfs-10dd
       273 ~29%  +2.4e+16%  6.472e+16 ~115%  fat/micro/dd-write/1HDD-cfq-xfs-1dd
       646 ~32%  +7.6e+15%  4.926e+16 ~52%  fat/micro/dd-write/1HDD-deadline-btrfs-10dd
       316 ~15%  +2.5e+16%  7.789e+16 ~110%  fat/micro/dd-write/1HDD-deadline-btrfs-1dd
      4548 ~ 8%  +3.6e+14%  1.624e+16 ~141%  fat/micro/dd-write/1HDD-deadline-ext4-100dd
      1070 ~23%  +3.8e+15%  4.059e+16 ~141%  fat/micro/dd-write/1HDD-deadline-ext4-10dd
       221 ~39%  +1.1e+16%   2.45e+16 ~81%  fat/micro/dd-write/1HDD-deadline-ext4-1dd
      4563 ~ 9%  +4.7e+13%   2.16e+15 ~140%  fat/micro/dd-write/1HDD-deadline-xfs-100dd
       811 ~15%    +3e+15%  2.447e+16 ~81%  fat/micro/dd-write/1HDD-deadline-xfs-10dd
       295 ~27%  +1.3e+12%  3.881e+12 ~63%  fat/micro/dd-write/1HDD-deadline-xfs-1dd
       156 ~ 2%  +5.1e+16%   8.02e+16 ~99%  lkp-a04/micro/netperf/120s-200%-TCP_CRR
       148 ~ 3%    -100.0%          0 ~ 0%  lkp-a04/micro/netperf/120s-200%-TCP_RR
   3772540 ~ 0%  +5.5e+12%  2.085e+17 ~27%  lkp-ib03/micro/ebizzy/400%-5-30
       221 ~ 5%    +2e+17%  4.434e+17 ~92%  lkp-ib03/micro/netperf/120s-200%-TCP_CRR
       176 ~ 7%  +1.7e+17%  2.957e+17 ~87%  lkp-ib03/micro/netperf/120s-200%-TCP_MAERTS
       214 ~12%    +7e+16%  1.494e+17 ~62%  lkp-ib03/micro/netperf/120s-200%-TCP_RR
       169 ~ 5%  +2.6e+17%  4.341e+17 ~33%  lkp-ib03/micro/netperf/120s-200%-UDP_RR
       513 ~ 3%  +4.3e+16%  2.192e+17 ~85%  lkp-nex05/micro/hackbench/800%-process-pipe
       603 ~ 3%  +7.7e+16%  4.669e+17 ~13%  lkp-nex05/micro/hackbench/800%-process-socket
      6124 ~17%  +5.7e+15%  3.474e+17 ~26%  lkp-nex05/micro/hackbench/800%-threads-pipe
      7565 ~49%  +5.5e+15%  4.128e+17 ~68%  lkp-nex05/micro/hackbench/800%-threads-socket
     21252 ~ 6%  +1.3e+15%  2.728e+17 ~39%  lkp-snb01/micro/hackbench/1600%-threads-pipe
     24516 ~16%  +8.3e+14%  2.034e+17 ~53%  lkp-snb01/micro/hackbench/1600%-threads-socket
     15165 ~ 0%  +3.2e+15%   4.86e+17 ~16%  lkp-ws02/micro/dd-write/11HDD-JBOD-cfq-btrfs-100dd
      2396 ~ 2%  +2.6e+16%  6.187e+17 ~29%  lkp-ws02/micro/dd-write/11HDD-JBOD-cfq-btrfs-10dd
       473 ~ 8%  +1.9e+17%  8.989e+17 ~43%  lkp-ws02/micro/dd-write/11HDD-JBOD-cfq-btrfs-1dd
     14021 ~ 2%  +7.8e+13%  1.092e+16 ~141%  lkp-ws02/micro/dd-write/11HDD-JBOD-cfq-ext4-100dd
      3150 ~ 9%  +4.3e+14%  1.359e+16 ~140%  lkp-ws02/micro/dd-write/11HDD-JBOD-cfq-ext4-10dd
       418 ~ 0%  +2.3e+16%  9.474e+16 ~28%  lkp-ws02/micro/dd-write/11HDD-JBOD-cfq-ext4-1dd
     14661 ~ 0%  +3.6e+14%   5.33e+16 ~97%  lkp-ws02/micro/dd-write/11HDD-JBOD-cfq-xfs-100dd
      3084 ~10%  +4.2e+15%  1.295e+17 ~54%  lkp-ws02/micro/dd-write/11HDD-JBOD-cfq-xfs-10dd
       361 ~ 3%  +6.6e+16%  2.403e+17 ~57%  lkp-ws02/micro/dd-write/11HDD-JBOD-cfq-xfs-1dd
     14473 ~ 1%  +1.6e+13%  2.367e+15 ~140%  lkp-ws02/micro/dd-write/11HDD-JBOD-deadline-ext4-100dd
      3296 ~ 3%  +1.1e+15%   3.58e+16 ~46%  lkp-ws02/micro/dd-write/11HDD-JBOD-deadline-ext4-10dd
       400 ~ 4%    +5e+16%  2.014e+17 ~69%  lkp-ws02/micro/dd-write/11HDD-JBOD-deadline-ext4-1dd
     14638 ~ 1%  +1.1e+14%  1.654e+16 ~141%  lkp-ws02/micro/dd-write/11HDD-JBOD-deadline-xfs-100dd
      3218 ~13%  +4.9e+15%  1.592e+17 ~74%  lkp-ws02/micro/dd-write/11HDD-JBOD-deadline-xfs-10dd
       405 ~ 4%  +2.4e+16%  9.656e+16 ~48%  lkp-ws02/micro/dd-write/11HDD-JBOD-deadline-xfs-1dd
      1686 ~ 3%    +3e+16%  5.075e+17 ~32%  snb-drag/sysbench/fileio/600s-100%-1HDD-btrfs-64G-1024-seqrewr-sync
      1658 ~ 2%  +2.1e+16%  3.512e+17 ~25%  snb-drag/sysbench/fileio/600s-100%-1HDD-btrfs-64G-1024-seqwr-sync
       927 ~10%  +5.1e+11%   4.73e+12 ~44%  snb-drag/sysbench/fileio/600s-100%-1HDD-ext4-64G-1024-rndrd-sync
      1110 ~23%  +3.9e+11%  4.386e+12 ~21%  snb-drag/sysbench/fileio/600s-100%-1HDD-ext4-64G-1024-rndrw-sync
      1450 ~ 4%  +7.1e+11%   1.03e+13 ~ 4%  snb-drag/sysbench/fileio/600s-100%-1HDD-ext4-64G-1024-seqrd-sync
      2003 ~ 3%  +4.8e+11%  9.596e+12 ~12%  snb-drag/sysbench/fileio/600s-100%-1HDD-ext4-64G-1024-seqrewr-sync
      2134 ~ 3%  +6.2e+11%  1.317e+13 ~31%  snb-drag/sysbench/fileio/600s-100%-1HDD-ext4-64G-1024-seqwr-sync
       763 ~12%  +7.2e+15%  5.504e+16 ~73%  snb-drag/sysbench/fileio/600s-100%-1HDD-xfs-64G-1024-rndrd-sync
       971 ~ 3%  +8.3e+15%  8.058e+16 ~45%  snb-drag/sysbench/fileio/600s-100%-1HDD-xfs-64G-1024-rndrw-sync
      1024 ~ 5%    +1e+16%  1.073e+17 ~60%  snb-drag/sysbench/fileio/600s-100%-1HDD-xfs-64G-1024-rndwr-sync
      1464 ~ 3%  +2.5e+15%  3.613e+16 ~24%  snb-drag/sysbench/fileio/600s-100%-1HDD-xfs-64G-1024-seqrd-sync
      1744 ~10%    +4e+11%  6.932e+12 ~24%  snb-drag/sysbench/fileio/600s-100%-1HDD-xfs-64G-1024-seqrewr-sync
      1894 ~ 2%  +5.9e+11%  1.111e+13 ~18%  snb-drag/sysbench/fileio/600s-100%-1HDD-xfs-64G-1024-seqwr-sync
 3.301e+08       +2.2e+13%  7.241e+19       TOTAL proc-vmstat.nr_tlb_remote_flush

      v3.13-rc3       eabb1f89905a0c809d13  
---------------  -------------------------  
     36971 ~ 0%  +1.5e+08%  5.564e+10 ~141%  avoton1/crypto/tcrypt/2s-301-319
     30210 ~ 0%     -89.7%       3108 ~19%  avoton1/crypto/tcrypt/2s-505-509
     17804 ~ 0%    +1e+16%  1.861e+18 ~76%  brickland1/micro/will-it-scale/futex1
     17813 ~ 0%  +8.6e+15%  1.528e+18 ~83%  brickland1/micro/will-it-scale/futex2
     17880 ~ 0%  +3.9e+15%  6.977e+17 ~55%  brickland1/micro/will-it-scale/getppid1
     17829 ~ 0%  +4.7e+15%  8.331e+17 ~33%  brickland1/micro/will-it-scale/lock1
     17850 ~ 0%  +2.3e+15%  4.164e+17 ~82%  brickland1/micro/will-it-scale/lseek1
     17850 ~ 0%  +4.8e+15%  8.603e+17 ~61%  brickland1/micro/will-it-scale/lseek2
     17846 ~ 0%  +1.1e+16%  2.025e+18 ~59%  brickland1/micro/will-it-scale/malloc2
     18172 ~ 0%     -63.6%       6623 ~14%  brickland1/micro/will-it-scale/mmap2
     17899 ~ 0%  +6.1e+15%  1.093e+18 ~69%  brickland1/micro/will-it-scale/open1
     17837 ~ 0%    +7e+15%  1.255e+18 ~57%  brickland1/micro/will-it-scale/open2
     54199 ~ 0%  +1.8e+15%  9.902e+17 ~13%  brickland1/micro/will-it-scale/page_fault1
     42510 ~ 0%  +9.6e+14%  4.069e+17 ~45%  brickland1/micro/will-it-scale/page_fault2
    170171 ~ 0%  +8.2e+14%  1.399e+18 ~61%  brickland1/micro/will-it-scale/page_fault3
     17855 ~ 0%    +1e+15%   1.87e+17 ~49%  brickland1/micro/will-it-scale/pipe1
     17873 ~ 0%  +1.8e+16%  3.161e+18 ~37%  brickland1/micro/will-it-scale/poll1
     17843 ~ 0%  +1.9e+16%  3.335e+18 ~ 9%  brickland1/micro/will-it-scale/poll2
     17872 ~ 0%  +5.7e+15%  1.024e+18 ~50%  brickland1/micro/will-it-scale/posix_semaphore1
     17827 ~ 0%  +5.2e+15%  9.269e+17 ~107%  brickland1/micro/will-it-scale/pread1
     17982 ~ 0%    +4e+15%  7.161e+17 ~42%  brickland1/micro/will-it-scale/pread2
     17865 ~ 0%  +3.9e+15%  6.932e+17 ~48%  brickland1/micro/will-it-scale/pthread_mutex1
     17818 ~ 0%  +6.2e+15%  1.109e+18 ~55%  brickland1/micro/will-it-scale/pthread_mutex2
     17819 ~ 0%  +8.9e+15%  1.592e+18 ~93%  brickland1/micro/will-it-scale/pwrite1
     18000 ~ 0%  +7.3e+15%   1.32e+18 ~39%  brickland1/micro/will-it-scale/pwrite2
     17874 ~ 0%  +1.9e+15%  3.418e+17 ~94%  brickland1/micro/will-it-scale/read1
     17988 ~ 0%  +1.1e+16%  1.964e+18 ~20%  brickland1/micro/will-it-scale/read2
     17897 ~ 0%  +1.2e+16%  2.063e+18 ~53%  brickland1/micro/will-it-scale/readseek
     17978 ~ 0%  +1.3e+16%  2.259e+18 ~41%  brickland1/micro/will-it-scale/sched_yield
     17855 ~ 0%  +3.1e+15%  5.594e+17 ~40%  brickland1/micro/will-it-scale/unlink2
     17841 ~ 0%  +1.1e+16%  1.942e+18 ~59%  brickland1/micro/will-it-scale/write1
     17840 ~ 0%  +1.4e+16%  2.555e+18 ~15%  brickland1/micro/will-it-scale/writeseek
     27664 ~ 2%  +1.1e+15%  3.078e+17 ~15%  brickland2/micro/hackbench/600%-process-pipe
     15925 ~ 5%  +5.6e+15%  8.867e+17 ~24%  brickland2/micro/hackbench/600%-process-socket
     28749 ~ 2%  +1.6e+15%  4.511e+17 ~47%  brickland2/micro/hackbench/600%-threads-pipe
     16005 ~ 9%  +6.6e+15%  1.061e+18 ~10%  brickland2/micro/hackbench/600%-threads-socket
     25886 ~ 2%  +8.7e+14%   2.26e+17 ~35%  brickland2/micro/vm-scalability/16G-shm-pread-rand-mt
     25203 ~ 0%  +2.5e+15%  6.257e+17 ~95%  brickland2/micro/vm-scalability/16G-shm-pread-rand
     19097 ~ 0%    +1e+16%  1.974e+18 ~16%  brickland2/micro/vm-scalability/16G-shm-xread-rand-mt
     25288 ~ 0%  +7.2e+14%  1.812e+17 ~48%  brickland2/micro/vm-scalability/16G-shm-xread-rand
     10671 ~ 0%     -71.1%       3086 ~15%  brickland2/micro/vm-scalability/16G-truncate
     19001 ~ 0%  +2.3e+15%  4.431e+17 ~ 9%  brickland2/micro/vm-scalability/1T-shm-pread-seq-mt
     19721 ~ 0%  +9.2e+15%  1.823e+18 ~24%  brickland2/micro/vm-scalability/1T-shm-pread-seq
     17867 ~ 0%  +1.2e+16%  2.118e+18 ~ 9%  brickland2/micro/vm-scalability/1T-shm-xread-seq-mt
     19893 ~ 0%    +9e+15%  1.788e+18 ~22%  brickland2/micro/vm-scalability/1T-shm-xread-seq
     16433 ~ 2%  +3.2e+15%  5.303e+17 ~45%  brickland2/micro/vm-scalability/300s-anon-r-seq-mt
      8837 ~ 0%  +2.3e+16%   1.99e+18 ~94%  brickland2/micro/vm-scalability/300s-anon-r-seq
     16862 ~ 0%    +7e+15%  1.176e+18 ~114%  brickland2/micro/vm-scalability/300s-anon-rx-rand-mt
     16808 ~ 0%  +4.6e+15%  7.766e+17 ~33%  brickland2/micro/vm-scalability/300s-anon-rx-seq-mt
     20507 ~ 0%  +1.7e+15%   3.41e+17 ~31%  brickland2/micro/vm-scalability/300s-lru-file-mmap-read-rand
     18674 ~ 0%  +5.1e+15%  9.583e+17 ~31%  brickland2/micro/vm-scalability/300s-lru-file-mmap-read
     18832 ~ 0%  +1.8e+15%  3.443e+17 ~28%  brickland2/micro/vm-scalability/300s-lru-file-readonce
     17489 ~ 0%  +2.4e+15%  4.206e+17 ~76%  brickland2/micro/vm-scalability/300s-lru-file-readtwice
     18790 ~ 2%  +2.7e+15%  5.119e+17 ~ 5%  brickland2/micro/vm-scalability/300s-mmap-pread-rand-mt
     20337 ~ 0%    +2e+15%  4.009e+17 ~46%  brickland2/micro/vm-scalability/300s-mmap-pread-rand
     14994 ~ 0%  +5.5e+15%  8.186e+17 ~20%  brickland2/micro/vm-scalability/300s-mmap-pread-seq
     17830 ~ 0%  +2.6e+15%  4.586e+17 ~43%  brickland2/micro/vm-scalability/300s-mmap-xread-rand-mt
     15556 ~ 2%  +1.1e+16%  1.649e+18 ~ 7%  brickland2/micro/vm-scalability/300s-mmap-xread-seq-mt
     15258 ~ 0%  +4.6e+14%  6.963e+16 ~49%  fat/micro/dd-write/1HDD-cfq-btrfs-100dd
     14293 ~ 0%  +2.2e+15%  3.199e+17 ~17%  fat/micro/dd-write/1HDD-cfq-btrfs-10dd
     14104 ~ 0%  +6.2e+14%  8.718e+16 ~31%  fat/micro/dd-write/1HDD-cfq-btrfs-1dd
     15176 ~ 0%  +1.2e+14%  1.872e+16 ~113%  fat/micro/dd-write/1HDD-cfq-xfs-100dd
     14257 ~ 0%  +5.7e+14%  8.144e+16 ~86%  fat/micro/dd-write/1HDD-cfq-xfs-10dd
     14065 ~ 0%  +4.6e+14%  6.471e+16 ~115%  fat/micro/dd-write/1HDD-cfq-xfs-1dd
     14296 ~ 0%  +3.3e+14%   4.72e+16 ~20%  fat/micro/dd-write/1HDD-deadline-btrfs-10dd
     14163 ~ 0%  +6.9e+14%  9.719e+16 ~79%  fat/micro/dd-write/1HDD-deadline-btrfs-1dd
     15217 ~ 0%  +1.1e+14%  1.623e+16 ~141%  fat/micro/dd-write/1HDD-deadline-ext4-100dd
     14180 ~ 0%  +1.7e+14%  2.446e+16 ~81%  fat/micro/dd-write/1HDD-deadline-xfs-10dd
     10634 ~ 0%     -43.9%       5971 ~ 1%  lkp-a04/micro/netperf/120s-200%-TCP_RR
   3781807 ~ 0%  +6.7e+12%  2.543e+17 ~42%  lkp-ib03/micro/ebizzy/400%-5-30
      9234 ~ 0%  +2.7e+15%  2.489e+17 ~74%  lkp-ib03/micro/netperf/120s-200%-TCP_CRR
      9079 ~ 0%    +3e+15%  2.682e+17 ~103%  lkp-ib03/micro/netperf/120s-200%-TCP_MAERTS
      9016 ~ 0%  +3.1e+15%  2.775e+17 ~69%  lkp-ib03/micro/netperf/120s-200%-TCP_RR
      9099 ~ 0%  +4.2e+15%  3.854e+17 ~25%  lkp-ib03/micro/netperf/120s-200%-UDP_RR
     22724 ~ 0%  +1.1e+15%  2.508e+17 ~77%  lkp-nex05/micro/hackbench/800%-process-pipe
     15900 ~ 2%  +2.8e+15%  4.396e+17 ~29%  lkp-nex05/micro/hackbench/800%-process-socket
     23757 ~ 2%  +1.2e+15%   2.94e+17 ~18%  lkp-nex05/micro/hackbench/800%-threads-pipe
     14867 ~ 0%  +2.6e+15%  3.863e+17 ~65%  lkp-nex05/micro/hackbench/800%-threads-socket
      5515 ~ 0%     -42.3%       3184 ~42%  lkp-nex05/micro/tlbflush/100%-8
     18295 ~ 3%  +1.3e+15%   2.39e+17 ~28%  lkp-snb01/micro/hackbench/1600%-threads-pipe
      9304 ~ 1%  +1.6e+15%  1.483e+17 ~50%  lkp-snb01/micro/hackbench/1600%-threads-socket
     34259 ~ 0%  +1.8e+15%  6.324e+17 ~39%  lkp-ws02/micro/dd-write/11HDD-JBOD-cfq-btrfs-100dd
     24088 ~ 0%  +2.8e+15%  6.708e+17 ~26%  lkp-ws02/micro/dd-write/11HDD-JBOD-cfq-btrfs-10dd
     22923 ~ 0%  +4.7e+15%  1.076e+18 ~27%  lkp-ws02/micro/dd-write/11HDD-JBOD-cfq-btrfs-1dd
     23949 ~ 0%  +3.6e+14%  8.725e+16 ~ 4%  lkp-ws02/micro/dd-write/11HDD-JBOD-cfq-ext4-10dd
     22852 ~ 0%  +6.2e+14%  1.418e+17 ~54%  lkp-ws02/micro/dd-write/11HDD-JBOD-cfq-ext4-1dd
     33664 ~ 0%  +1.3e+14%  4.488e+16 ~101%  lkp-ws02/micro/dd-write/11HDD-JBOD-cfq-xfs-100dd
     23679 ~ 0%  +7.3e+14%  1.734e+17 ~72%  lkp-ws02/micro/dd-write/11HDD-JBOD-cfq-xfs-10dd
     22691 ~ 0%  +1.2e+15%  2.759e+17 ~58%  lkp-ws02/micro/dd-write/11HDD-JBOD-cfq-xfs-1dd
     23989 ~ 0%  +4.3e+14%  1.021e+17 ~22%  lkp-ws02/micro/dd-write/11HDD-JBOD-deadline-ext4-10dd
     22874 ~ 0%    +2e+15%  4.529e+17 ~69%  lkp-ws02/micro/dd-write/11HDD-JBOD-deadline-ext4-1dd
     23682 ~ 0%  +6.8e+14%    1.6e+17 ~56%  lkp-ws02/micro/dd-write/11HDD-JBOD-deadline-xfs-10dd
     22652 ~ 0%  +4.3e+14%  9.848e+16 ~49%  lkp-ws02/micro/dd-write/11HDD-JBOD-deadline-xfs-1dd
     20029 ~ 0%  +2.3e+15%  4.684e+17 ~41%  snb-drag/sysbench/fileio/600s-100%-1HDD-btrfs-64G-1024-seqrewr-sync
     20044 ~ 0%  +1.5e+15%  2.936e+17 ~26%  snb-drag/sysbench/fileio/600s-100%-1HDD-btrfs-64G-1024-seqwr-sync
     28205 ~ 1%     -78.1%       6186 ~ 6%  snb-drag/sysbench/fileio/600s-100%-1HDD-ext4-64G-1024-rndrd-sync
     27802 ~ 1%     -78.5%       5968 ~ 4%  snb-drag/sysbench/fileio/600s-100%-1HDD-ext4-64G-1024-rndrw-sync
     20016 ~ 0%     -74.2%       5167 ~ 0%  snb-drag/sysbench/fileio/600s-100%-1HDD-ext4-64G-1024-rndwr-sync
     27596 ~ 0%     -79.0%       5801 ~ 1%  snb-drag/sysbench/fileio/600s-100%-1HDD-ext4-64G-1024-seqrd-sync
     20198 ~ 1%     -63.7%       7336 ~ 1%  snb-drag/sysbench/fileio/600s-100%-1HDD-ext4-64G-1024-seqrewr-sync
     20032 ~ 0%     -60.1%       7997 ~ 9%  snb-drag/sysbench/fileio/600s-100%-1HDD-ext4-64G-1024-seqwr-sync
     25640 ~ 0%  +1.9e+14%  4.937e+16 ~51%  snb-drag/sysbench/fileio/600s-100%-1HDD-xfs-64G-1024-rndrw-sync
     20047 ~ 0%    +9e+14%  1.798e+17 ~17%  snb-drag/sysbench/fileio/600s-100%-1HDD-xfs-64G-1024-rndwr-sync
     25624 ~ 0%  +6.3e+13%  1.607e+16 ~53%  snb-drag/sysbench/fileio/600s-100%-1HDD-xfs-64G-1024-seqrd-sync
     20246 ~ 1%     -66.7%       6734 ~ 7%  snb-drag/sysbench/fileio/600s-100%-1HDD-xfs-64G-1024-seqrewr-sync
     20025 ~ 0%     -63.1%       7395 ~ 5%  snb-drag/sysbench/fileio/600s-100%-1HDD-xfs-64G-1024-seqwr-sync
   5990864       +1.2e+15%  7.032e+19       TOTAL proc-vmstat.nr_tlb_local_flush_all

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
