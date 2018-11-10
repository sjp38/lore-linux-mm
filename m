Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id 142756B0779
	for <linux-mm@kvack.org>; Sat, 10 Nov 2018 03:50:57 -0500 (EST)
Received: by mail-ot1-f69.google.com with SMTP id c33so2728558otb.18
        for <linux-mm@kvack.org>; Sat, 10 Nov 2018 00:50:57 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 129-v6sor5257439oib.173.2018.11.10.00.50.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 10 Nov 2018 00:50:55 -0800 (PST)
From: john.hubbard@gmail.com
Subject: [PATCH v2 0/6] RFC: gup+dma: tracking dma-pinned pages
Date: Sat, 10 Nov 2018 00:50:35 -0800
Message-Id: <20181110085041.10071-1-jhubbard@nvidia.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>, linux-fsdevel@vger.kernel.org, John Hubbard <jhubbard@nvidia.com>

From: John Hubbard <jhubbard@nvidia.com>

Hi, here is fodder for conversation during LPC.

Changes since v1:

a) Uses a simpler set/clear/test bit approach in the page flags.

b) Added some initial performance results in the cover letter here, below.

c) Rebased to latest linux.git

d) Puts pages back on the LRU when its done with them.

Here is an updated proposal for tracking pages that have had
get_user_pages*() called on them. This is in support of fixing the problem
discussed in [1]. This RFC only shows how to set up a reliable
PageDmaPinned flag. What to *do* with that flag is left for a later
discussion.

The sequence would be:

    -- apply patches 1-2,

    -- convert the rest of the subsystems to call put_user_page*(). Patch #3
       is an example of that. It converts infiniband.

    -- apply patches 4-6,

    -- apply more patches, to actually use the new PageDmaPinned flag.

One question up front was, "how do we ensure that either put_user_page()
or put_page() are called, depending on whether the page came from
get_user_pages() or not?". From this series, you can see that:

    -- It's possible to assert within put_page(), that we are probably in the
       right place. In practice this assertion definitely helps.

    -- In the other direction, if put_user_page() is called when put_page()
       should have been used instead, then a "clear" report of LRU list
       corruption shows up reliably, because the first thing put_user_page()
       attempts is to decrement the lru's list.prev pointer, and so you'll
       see pointer values that are one less than an aligned pointer value.
       This is not great, but it's usable. So I think that the conversion
       will turn into an exercise of trying to get code coverage, and that
       should work out.

I have lots of other patches, not shown here, in various stages of polish, to
convert enough of the kernel in order to run fio [2]. I did that, and got some
rather noisy performance results.

Here they are again:

Performance notes:

1. These fio results are noisy. The std deviation is large enough
that some of this could be noise. In order to highlight that, I did 5 runs
each of with, and without the patch, and while there is definitely a
performance drop on average, it's also true that there is overlap in the
results. In other words, the best "with patch" run is about the same as
the worst "without patch" run.

2. Initial profiling shows that we're adding about 1% total to the this
particular test run...I think. I may have to narrow this down some more,
but I don't seem to see any real lock contention. Hints or ideas on
measurement methods are welcome, btw.

    -- 0.59% in put_user_page
    -- 0.2% (or 0.54%, depending on how you read the perf out below) in
       get_user_pages_fast:


          1.36%--iov_iter_get_pages
                    |
                     --1.27%--get_user_pages_fast
                               |
                                --0.54%--pin_page_for_dma

          0.59%--put_user_page

          1.34%     0.03%  fio   [kernel.vmlinux]     [k] _raw_spin_lock
          0.95%     0.55%  fio   [kernel.vmlinux]     [k] do_raw_spin_lock
          0.17%     0.03%  fio   [kernel.vmlinux]     [k] isolate_lru_page
          0.06%     0.00%  fio   [kernel.vmlinux]     [k] putback_lru_page

4. Here's some raw fio data: one run without the patch, and two with the patch:

------------------------------------------------------
WITHOUT the patch:
------------------------------------------------------
reader: (g=0): rw=read, bs=(R) 4096B-4096B, (W) 4096B-4096B, (T) 4096B-4096B, ioengine=libaio, iodepth=64
fio-3.3
Starting 1 process
Jobs: 1 (f=1): [R(1)][100.0%][r=55.5MiB/s,w=0KiB/s][r=14.2k,w=0 IOPS][eta 00m:00s]
reader: (groupid=0, jobs=1): err= 0: pid=1750: Tue Nov  6 20:18:06 2018
   read: IOPS=13.9k, BW=54.4MiB/s (57.0MB/s)(1024MiB/18826msec)
    slat (usec): min=25, max=4870, avg=68.19, stdev=85.21
    clat (usec): min=74, max=19814, avg=4525.40, stdev=1844.03
     lat (usec): min=183, max=19927, avg=4593.69, stdev=1866.65
    clat percentiles (usec):
     |  1.00th=[ 3687],  5.00th=[ 3720], 10.00th=[ 3720], 20.00th=[ 3752],
     | 30.00th=[ 3752], 40.00th=[ 3752], 50.00th=[ 3752], 60.00th=[ 3785],
     | 70.00th=[ 4178], 80.00th=[ 4490], 90.00th=[ 6652], 95.00th=[ 8225],
     | 99.00th=[13173], 99.50th=[14353], 99.90th=[16581], 99.95th=[17171],
     | 99.99th=[18220]
   bw (  KiB/s): min=49920, max=59320, per=100.00%, avg=55742.24, stdev=2224.20, samples=37
   iops        : min=12480, max=14830, avg=13935.35, stdev=556.05, samples=37
  lat (usec)   : 100=0.01%, 250=0.01%, 500=0.01%, 750=0.01%, 1000=0.01%
  lat (msec)   : 2=0.01%, 4=68.78%, 10=28.14%, 20=3.08%
  cpu          : usr=2.39%, sys=95.30%, ctx=669, majf=0, minf=72
  IO depths    : 1=0.1%, 2=0.1%, 4=0.1%, 8=0.1%, 16=0.1%, 32=0.1%, >=64=100.0%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.1%, >=64=0.0%
     issued rwts: total=262144,0,0,0 short=0,0,0,0 dropped=0,0,0,0
     latency   : target=0, window=0, percentile=100.00%, depth=64

Run status group 0 (all jobs):
   READ: bw=54.4MiB/s (57.0MB/s), 54.4MiB/s-54.4MiB/s (57.0MB/s-57.0MB/s), io=1024MiB (1074MB), run=18826-18826msec

Disk stats (read/write):
  nvme0n1: ios=259490/1, merge=0/0, ticks=14822/0, in_queue=19241, util=100.00%

------------------------------------------------------
With the patch applied:
------------------------------------------------------
reader: (g=0): rw=read, bs=(R) 4096B-4096B, (W) 4096B-4096B, (T) 4096B-4096B, ioengine=libaio, iodepth=64
fio-3.3
Starting 1 process
Jobs: 1 (f=1): [R(1)][100.0%][r=51.2MiB/s,w=0KiB/s][r=13.1k,w=0 IOPS][eta 00m:00s]
reader: (groupid=0, jobs=1): err= 0: pid=2568: Tue Nov  6 20:03:50 2018
   read: IOPS=12.8k, BW=50.1MiB/s (52.5MB/s)(1024MiB/20453msec)
    slat (usec): min=33, max=4365, avg=74.05, stdev=85.79
    clat (usec): min=39, max=19818, avg=4916.61, stdev=1961.79
     lat (usec): min=100, max=20002, avg=4990.78, stdev=1985.23
    clat percentiles (usec):
     |  1.00th=[ 4047],  5.00th=[ 4080], 10.00th=[ 4080], 20.00th=[ 4080],
     | 30.00th=[ 4113], 40.00th=[ 4113], 50.00th=[ 4113], 60.00th=[ 4146],
     | 70.00th=[ 4178], 80.00th=[ 4817], 90.00th=[ 7308], 95.00th=[ 8717],
     | 99.00th=[14091], 99.50th=[15270], 99.90th=[17433], 99.95th=[18220],
     | 99.99th=[19006]
   bw (  KiB/s): min=45370, max=55784, per=100.00%, avg=51332.33, stdev=1843.77, samples=40
   iops        : min=11342, max=13946, avg=12832.83, stdev=460.92, samples=40
  lat (usec)   : 50=0.01%, 250=0.01%, 500=0.01%, 750=0.01%, 1000=0.01%
  lat (msec)   : 2=0.01%, 4=0.01%, 10=96.44%, 20=3.53%
  cpu          : usr=2.91%, sys=95.18%, ctx=398, majf=0, minf=73
  IO depths    : 1=0.1%, 2=0.1%, 4=0.1%, 8=0.1%, 16=0.1%, 32=0.1%, >=64=100.0%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.1%, >=64=0.0%
     issued rwts: total=262144,0,0,0 short=0,0,0,0 dropped=0,0,0,0
     latency   : target=0, window=0, percentile=100.00%, depth=64

Run status group 0 (all jobs):
   READ: bw=50.1MiB/s (52.5MB/s), 50.1MiB/s-50.1MiB/s (52.5MB/s-52.5MB/s), io=1024MiB (1074MB), run=20453-20453msec

Disk stats (read/write):
  nvme0n1: ios=261399/0, merge=0/0, ticks=16019/0, in_queue=20910, util=100.00%

------------------------------------------------------
OR, here's a better run WITH the patch applied, and you can see that this is nearly as good
as the "without" case:
------------------------------------------------------

reader: (g=0): rw=read, bs=(R) 4096B-4096B, (W) 4096B-4096B, (T) 4096B-4096B, ioengine=libaio, iodepth=64
fio-3.3
Starting 1 process
Jobs: 1 (f=1): [R(1)][100.0%][r=53.2MiB/s,w=0KiB/s][r=13.6k,w=0 IOPS][eta 00m:00s]
reader: (groupid=0, jobs=1): err= 0: pid=2521: Tue Nov  6 20:01:33 2018
   read: IOPS=13.4k, BW=52.5MiB/s (55.1MB/s)(1024MiB/19499msec)
    slat (usec): min=30, max=12458, avg=69.71, stdev=88.01
    clat (usec): min=39, max=25590, avg=4687.42, stdev=1925.29
     lat (usec): min=97, max=25704, avg=4757.25, stdev=1946.06
    clat percentiles (usec):
     |  1.00th=[ 3884],  5.00th=[ 3884], 10.00th=[ 3916], 20.00th=[ 3916],
     | 30.00th=[ 3916], 40.00th=[ 3916], 50.00th=[ 3949], 60.00th=[ 3949],
     | 70.00th=[ 3982], 80.00th=[ 4555], 90.00th=[ 6915], 95.00th=[ 8848],
     | 99.00th=[13566], 99.50th=[14877], 99.90th=[16909], 99.95th=[17695],
     | 99.99th=[24249]
   bw (  KiB/s): min=48905, max=58016, per=100.00%, avg=53855.79, stdev=2115.03, samples=38
   iops        : min=12226, max=14504, avg=13463.79, stdev=528.76, samples=38
  lat (usec)   : 50=0.01%, 250=0.01%, 500=0.01%, 750=0.01%, 1000=0.01%
  lat (msec)   : 2=0.01%, 4=71.80%, 10=24.66%, 20=3.51%, 50=0.02%
  cpu          : usr=3.47%, sys=94.61%, ctx=370, majf=0, minf=73
  IO depths    : 1=0.1%, 2=0.1%, 4=0.1%, 8=0.1%, 16=0.1%, 32=0.1%, >=64=100.0%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.1%, >=64=0.0%
     issued rwts: total=262144,0,0,0 short=0,0,0,0 dropped=0,0,0,0
     latency   : target=0, window=0, percentile=100.00%, depth=64

Run status group 0 (all jobs):
   READ: bw=52.5MiB/s (55.1MB/s), 52.5MiB/s-52.5MiB/s (55.1MB/s-55.1MB/s), io=1024MiB (1074MB), run=19499-19499msec

Disk stats (read/write):
  nvme0n1: ios=260720/0, merge=0/0, ticks=15036/0, in_queue=19876, util=100.00%


[1] https://lwn.net/Articles/753027/ : "The Trouble with get_user_pages()"

[2] fio: https://github.com/axboe/fio

John Hubbard (6):
  mm/gup: finish consolidating error handling
  mm: introduce put_user_page*(), placeholder versions
  infiniband/mm: convert put_page() to put_user_page*()
  mm: introduce page->dma_pinned_flags, _count
  mm: introduce zone_gup_lock, for dma-pinned pages
  mm: track gup pages with page->dma_pinned_* fields

 drivers/infiniband/core/umem.c              |   7 +-
 drivers/infiniband/core/umem_odp.c          |   2 +-
 drivers/infiniband/hw/hfi1/user_pages.c     |  11 +-
 drivers/infiniband/hw/mthca/mthca_memfree.c |   6 +-
 drivers/infiniband/hw/qib/qib_user_pages.c  |  11 +-
 drivers/infiniband/hw/qib/qib_user_sdma.c   |   6 +-
 drivers/infiniband/hw/usnic/usnic_uiom.c    |   7 +-
 include/linux/mm.h                          |  13 ++
 include/linux/mm_types.h                    |  22 +++-
 include/linux/mmzone.h                      |   6 +
 include/linux/page-flags.h                  |  61 +++++++++
 mm/gup.c                                    |  58 +++++++-
 mm/memcontrol.c                             |   8 ++
 mm/page_alloc.c                             |   1 +
 mm/swap.c                                   | 138 ++++++++++++++++++++
 15 files changed, 320 insertions(+), 37 deletions(-)

-- 
2.19.1
