Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f197.google.com (mail-yb1-f197.google.com [209.85.219.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9295A6B0299
	for <linux-mm@kvack.org>; Mon,  5 Nov 2018 19:26:07 -0500 (EST)
Received: by mail-yb1-f197.google.com with SMTP id w13-v6so7055154ybm.11
        for <linux-mm@kvack.org>; Mon, 05 Nov 2018 16:26:07 -0800 (PST)
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id n9-v6si27340381ybp.250.2018.11.05.16.26.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Nov 2018 16:26:06 -0800 (PST)
Subject: Re: [PATCH 4/6] mm: introduce page->dma_pinned_flags, _count
References: <20181012060014.10242-1-jhubbard@nvidia.com>
 <20181012060014.10242-5-jhubbard@nvidia.com> <20181013035516.GA18822@dastard>
 <7c2e3b54-0b1d-6726-a508-804ef8620cfd@nvidia.com>
 <20181013164740.GA6593@infradead.org>
 <84811b54-60bf-2bc3-a58d-6a7925c24aad@nvidia.com>
 <20181105095447.GE6953@quack2.suse.cz>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <f5ad7210-05e0-3dc4-02df-01ce5346e198@nvidia.com>
Date: Mon, 5 Nov 2018 16:26:04 -0800
MIME-Version: 1.0
In-Reply-To: <20181105095447.GE6953@quack2.suse.cz>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US-large
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>, Jason Gunthorpe <jgg@ziepe.ca>, Dan Williams <dan.j.williams@intel.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>, linux-fsdevel@vger.kernel.org

On 11/5/18 1:54 AM, Jan Kara wrote:
> On Sun 04-11-18 23:10:12, John Hubbard wrote:
>> On 10/13/18 9:47 AM, Christoph Hellwig wrote:
>>> On Sat, Oct 13, 2018 at 12:34:12AM -0700, John Hubbard wrote:
>>>> In patch 6/6, pin_page_for_dma(), which is called at the end of get_user_pages(),
>>>> unceremoniously rips the pages out of the LRU, as a prerequisite to using
>>>> either of the page->dma_pinned_* fields. 
>>>>
>>>> The idea is that LRU is not especially useful for this situation anyway,
>>>> so we'll just make it one or the other: either a page is dma-pinned, and
>>>> just hanging out doing RDMA most likely (and LRU is less meaningful during that
>>>> time), or it's possibly on an LRU list.
>>>
>>> Have you done any benchmarking what this does to direct I/O performance,
>>> especially for small I/O directly to a (fast) block device?
>>>
>>
>> Hi Christoph,
>>
>> I'm seeing about 20% slower in one case: lots of reads and writes of size 8192 B,
>> on a fast NVMe device. My put_page() --> put_user_page() conversions are incomplete 
>> and buggy yet, but I've got enough of them done to briefly run the test.
>>
>> One thing that occurs to me is that jumping on and off the LRU takes time, and
>> if we limited this to 64-bit platforms, maybe we could use a real page flag? I 
>> know that leaves 32-bit out in the cold, but...maybe use this slower approach
>> for 32-bit, and the pure page flag for 64-bit? uggh, we shouldn't slow down anything
>> by 20%. 
>>
>> Test program is below. I hope I didn't overlook something obvious, but it's 
>> definitely possible, given my lack of experience with direct IO. 
>>
>> I'm preparing to send an updated RFC this week, that contains the feedback to date,
>> and also many converted call sites as well, so that everyone can see what the whole
>> (proposed) story would look like in its latest incarnation.
> 
> Hmm, have you tried larger buffer sizes? Because synchronous 8k IO isn't
> going to max-out NVME iops by far. Can I suggest you install fio [1] (it
> has the advantage that it is pretty much standard for a test like this so
> everyone knows what the test does from a glimpse) and run with it something
> like the following workfile:
> 
> [reader]
> direct=1
> ioengine=libaio
> blocksize=4096
> size=1g
> numjobs=1
> rw=read
> iodepth=64
> 
> And see how the numbers with and without your patches compare?
> 
> 								Honza
> 
> [1] https://github.com/axboe/fio

That program is *very* good to have. Whew. Anyway, it looks like read bandwidth 
is approximately 74 MiB/s with my patch (it varies a bit, run to run),
as compared to around 85 without the patch, so still showing about a 20%
performance degradation, assuming I'm reading this correctly.

Raw data follows, using the fio options you listed above:

Baseline (without my patch):
---------------------------- 
reader: (g=0): rw=read, bs=(R) 4096B-4096B, (W) 4096B-4096B, (T) 4096B-4096B, ioengine=libaio, iodepth=64
fio-3.3
Starting 1 process
Jobs: 1 (f=1): [R(1)][100.0%][r=87.2MiB/s,w=0KiB/s][r=22.3k,w=0 IOPS][eta 00m:00s]
reader: (groupid=0, jobs=1): err= 0: pid=1775: Mon Nov  5 12:08:45 2018
   read: IOPS=21.9k, BW=85.7MiB/s (89.9MB/s)(1024MiB/11945msec)
    slat (usec): min=13, max=3855, avg=44.17, stdev=61.18
    clat (usec): min=71, max=13093, avg=2869.40, stdev=1225.23
     lat (usec): min=179, max=14003, avg=2913.65, stdev=1241.75
    clat percentiles (usec):
     |  1.00th=[ 2311],  5.00th=[ 2343], 10.00th=[ 2343], 20.00th=[ 2343],
     | 30.00th=[ 2343], 40.00th=[ 2376], 50.00th=[ 2376], 60.00th=[ 2376],
     | 70.00th=[ 2409], 80.00th=[ 2933], 90.00th=[ 4359], 95.00th=[ 5276],
     | 99.00th=[ 8291], 99.50th=[ 9110], 99.90th=[10945], 99.95th=[11469],
     | 99.99th=[12256]
   bw (  KiB/s): min=80648, max=93288, per=99.80%, avg=87608.57, stdev=3201.35, samples=23
   iops        : min=20162, max=23322, avg=21902.09, stdev=800.37, samples=23
  lat (usec)   : 100=0.01%, 250=0.01%, 500=0.01%, 750=0.01%, 1000=0.01%
  lat (msec)   : 2=0.02%, 4=88.47%, 10=11.27%, 20=0.25%
  cpu          : usr=2.68%, sys=94.68%, ctx=408, majf=0, minf=73
  IO depths    : 1=0.1%, 2=0.1%, 4=0.1%, 8=0.1%, 16=0.1%, 32=0.1%, >=64=100.0%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.1%, >=64=0.0%
     issued rwts: total=262144,0,0,0 short=0,0,0,0 dropped=0,0,0,0
     latency   : target=0, window=0, percentile=100.00%, depth=64

Run status group 0 (all jobs):
   READ: bw=85.7MiB/s (89.9MB/s), 85.7MiB/s-85.7MiB/s (89.9MB/s-89.9MB/s), io=1024MiB (1074MB), run=11945-11945msec

Disk stats (read/write):
  nvme0n1: ios=260906/3, merge=0/1, ticks=14618/4, in_queue=17670, util=100.00%

Modified (with my patch):
---------------------------- 

reader: (g=0): rw=read, bs=(R) 4096B-4096B, (W) 4096B-4096B, (T) 4096B-4096B, ioengine=libaio, iodepth=64
fio-3.3
Starting 1 process
Jobs: 1 (f=1): [R(1)][100.0%][r=74.1MiB/s,w=0KiB/s][r=18.0k,w=0 IOPS][eta 00m:00s]
reader: (groupid=0, jobs=1): err= 0: pid=1808: Mon Nov  5 16:11:09 2018
   read: IOPS=18.3k, BW=71.4MiB/s (74.9MB/s)(1024MiB/14334msec)
    slat (usec): min=18, max=4378, avg=52.59, stdev=63.66
    clat (usec): min=31, max=15622, avg=3443.86, stdev=1431.27
     lat (usec): min=81, max=15766, avg=3496.57, stdev=1450.21
    clat percentiles (usec):
     |  1.00th=[ 2835],  5.00th=[ 2835], 10.00th=[ 2835], 20.00th=[ 2868],
     | 30.00th=[ 2868], 40.00th=[ 2868], 50.00th=[ 2868], 60.00th=[ 2900],
     | 70.00th=[ 2933], 80.00th=[ 3425], 90.00th=[ 5080], 95.00th=[ 6259],
     | 99.00th=[10159], 99.50th=[11076], 99.90th=[12649], 99.95th=[13435],
     | 99.99th=[14484]
   bw (  KiB/s): min=63142, max=77464, per=99.97%, avg=73128.46, stdev=3383.81, samples=28
   iops        : min=15785, max=19366, avg=18281.96, stdev=845.95, samples=28
  lat (usec)   : 50=0.01%, 100=0.01%, 250=0.01%, 500=0.01%, 750=0.01%
  lat (usec)   : 1000=0.01%
  lat (msec)   : 2=0.01%, 4=84.77%, 10=14.12%, 20=1.09%
  cpu          : usr=2.20%, sys=95.72%, ctx=360, majf=0, minf=72
  IO depths    : 1=0.1%, 2=0.1%, 4=0.1%, 8=0.1%, 16=0.1%, 32=0.1%, >=64=100.0%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.1%, >=64=0.0%
     issued rwts: total=262144,0,0,0 short=0,0,0,0 dropped=0,0,0,0
     latency   : target=0, window=0, percentile=100.00%, depth=64

Run status group 0 (all jobs):
   READ: bw=71.4MiB/s (74.9MB/s), 71.4MiB/s-71.4MiB/s (74.9MB/s-74.9MB/s), io=1024MiB (1074MB), run=14334-14334msec

Disk stats (read/write):
  nvme0n1: ios=258235/3, merge=0/1, ticks=12583/10, in_queue=14779, util=100.00%



thanks,
-- 
John Hubbard
NVIDIA
