Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f199.google.com (mail-yb1-f199.google.com [209.85.219.199])
	by kanga.kvack.org (Postfix) with ESMTP id 717126B04BF
	for <linux-mm@kvack.org>; Wed,  7 Nov 2018 01:36:34 -0500 (EST)
Received: by mail-yb1-f199.google.com with SMTP id s13-v6so11956240ybj.20
        for <linux-mm@kvack.org>; Tue, 06 Nov 2018 22:36:34 -0800 (PST)
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id 80-v6si22497827ywv.108.2018.11.06.22.36.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Nov 2018 22:36:32 -0800 (PST)
Subject: Re: [PATCH 4/6] mm: introduce page->dma_pinned_flags, _count
References: <20181012060014.10242-1-jhubbard@nvidia.com>
 <20181012060014.10242-5-jhubbard@nvidia.com> <20181013035516.GA18822@dastard>
 <7c2e3b54-0b1d-6726-a508-804ef8620cfd@nvidia.com>
 <20181013164740.GA6593@infradead.org>
 <84811b54-60bf-2bc3-a58d-6a7925c24aad@nvidia.com>
 <20181105095447.GE6953@quack2.suse.cz>
 <f5ad7210-05e0-3dc4-02df-01ce5346e198@nvidia.com>
 <20181106024715.GU6311@dastard> <20181106110006.GE25414@quack2.suse.cz>
 <20181106204149.GV6311@dastard>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <f42ffadc-8a7d-7d64-25ba-1990c5596fbc@nvidia.com>
Date: Tue, 6 Nov 2018 22:36:30 -0800
MIME-Version: 1.0
In-Reply-To: <20181106204149.GV6311@dastard>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US-large
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>
Cc: Christoph Hellwig <hch@infradead.org>, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>, Jason Gunthorpe <jgg@ziepe.ca>, Dan Williams <dan.j.williams@intel.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>, linux-fsdevel@vger.kernel.org

On 11/6/18 12:41 PM, Dave Chinner wrote:
> On Tue, Nov 06, 2018 at 12:00:06PM +0100, Jan Kara wrote:
>> On Tue 06-11-18 13:47:15, Dave Chinner wrote:
>>> On Mon, Nov 05, 2018 at 04:26:04PM -0800, John Hubbard wrote:
>>>> On 11/5/18 1:54 AM, Jan Kara wrote:
>>>>> Hmm, have you tried larger buffer sizes? Because synchronous 8k IO isn't
>>>>> going to max-out NVME iops by far. Can I suggest you install fio [1] (it
>>>>> has the advantage that it is pretty much standard for a test like this so
>>>>> everyone knows what the test does from a glimpse) and run with it something
>>>>> like the following workfile:
>>>>>
>>>>> [reader]
>>>>> direct=1
>>>>> ioengine=libaio
>>>>> blocksize=4096
>>>>> size=1g
>>>>> numjobs=1
>>>>> rw=read
>>>>> iodepth=64
>>>>>
>>>>> And see how the numbers with and without your patches compare?
>>>>>
>>>>> 								Honza
>>>>>
>>>>> [1] https://github.com/axboe/fio
>>>>
>>>> That program is *very* good to have. Whew. Anyway, it looks like read bandwidth 
>>>> is approximately 74 MiB/s with my patch (it varies a bit, run to run),
>>>> as compared to around 85 without the patch, so still showing about a 20%
>>>> performance degradation, assuming I'm reading this correctly.
>>>>
>>>> Raw data follows, using the fio options you listed above:
>>>>
>>>> Baseline (without my patch):
>>>> ---------------------------- 
>>> ....
>>>>      lat (usec): min=179, max=14003, avg=2913.65, stdev=1241.75
>>>>     clat percentiles (usec):
>>>>      |  1.00th=[ 2311],  5.00th=[ 2343], 10.00th=[ 2343], 20.00th=[ 2343],
>>>>      | 30.00th=[ 2343], 40.00th=[ 2376], 50.00th=[ 2376], 60.00th=[ 2376],
>>>>      | 70.00th=[ 2409], 80.00th=[ 2933], 90.00th=[ 4359], 95.00th=[ 5276],
>>>>      | 99.00th=[ 8291], 99.50th=[ 9110], 99.90th=[10945], 99.95th=[11469],
>>>>      | 99.99th=[12256]
>>> .....
>>>> Modified (with my patch):
>>>> ---------------------------- 
>>> .....
>>>>      lat (usec): min=81, max=15766, avg=3496.57, stdev=1450.21
>>>>     clat percentiles (usec):
>>>>      |  1.00th=[ 2835],  5.00th=[ 2835], 10.00th=[ 2835], 20.00th=[ 2868],
>>>>      | 30.00th=[ 2868], 40.00th=[ 2868], 50.00th=[ 2868], 60.00th=[ 2900],
>>>>      | 70.00th=[ 2933], 80.00th=[ 3425], 90.00th=[ 5080], 95.00th=[ 6259],
>>>>      | 99.00th=[10159], 99.50th=[11076], 99.90th=[12649], 99.95th=[13435],
>>>>      | 99.99th=[14484]
>>>
>>> So it's adding at least 500us of completion latency to every IO?
>>> I'd argue that the IO latency impact is far worse than the a 20%
>>> throughput drop.
>>
>> Hum, right. So for each IO we have to remove the page from LRU on submit
> 
> Which cost us less then 10us on average:
> 
> 	slat (usec): min=13, max=3855, avg=44.17, stdev=61.18
> vs
> 	slat (usec): min=18, max=4378, avg=52.59, stdev=63.66
> 
>> and then put it back on IO completion (which is going to race with new
>> submits so LRU lock contention might be an issue).
> 
> Removal has to take the same LRU lock, so I don't think contention
> is the problem here. More likely the overhead is in selecting the
> LRU to put it on. e.g. list_lru_from_kmem() which may well be doing
> a memcg lookup.
> 
>> Spending 500 us on that
>> is not unthinkable when the lock is contended but it is more expensive than
>> I'd have thought. John, could you perhaps profile where the time is spent?
> 

OK, some updates on that:

1. First of all, I fixed a direct-io-related call site (it was still calling put_page
instead of put_user_page), and that not only got rid of a problem, it also changed
performance: it makes the impact of the patch a bit less. (Sorry about that!
I was hoping that I could get away with temporarily ignoring that failure, but no.)
The bandwidth numbers in particular look much closer to each other.

2. Second, note that these fio results are noisy. The std deviation is large enough 
that some of this could be noise. In order to highlight that, I did 5 runs each of
with, and without the patch, and while there is definitely a performance drop on 
average, it's also true that there is overlap in the results. In other words, the
best "with patch" run is about the same as the worst "without patch" run.

3. Finally, initial profiling shows that we're adding about 1% total to the this
particular test run...I think. I may have to narrow this down some more, but I don't 
seem to see any real lock contention. Hints or ideas on measurement methods are
welcome, btw.

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


thanks,
-- 
John Hubbard
NVIDIA
