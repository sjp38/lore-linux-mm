Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id 67BC16B2695
	for <linux-mm@kvack.org>; Wed, 21 Nov 2018 11:49:36 -0500 (EST)
Received: by mail-yw1-f71.google.com with SMTP id q3-v6so3607304ywh.17
        for <linux-mm@kvack.org>; Wed, 21 Nov 2018 08:49:36 -0800 (PST)
Received: from p3plsmtpa07-10.prod.phx3.secureserver.net (p3plsmtpa07-10.prod.phx3.secureserver.net. [173.201.192.239])
        by mx.google.com with ESMTPS id u131si11578662ywb.382.2018.11.21.08.49.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Nov 2018 08:49:34 -0800 (PST)
Subject: Re: [PATCH v2 0/6] RFC: gup+dma: tracking dma-pinned pages
References: <20181110085041.10071-1-jhubbard@nvidia.com>
 <942cb823-9b18-69e7-84aa-557a68f9d7e9@talpey.com>
 <97934904-2754-77e0-5fcb-83f2311362ee@nvidia.com>
From: Tom Talpey <tom@talpey.com>
Message-ID: <5159e02f-17f8-df8b-600c-1b09356e46a9@talpey.com>
Date: Wed, 21 Nov 2018 11:49:33 -0500
MIME-Version: 1.0
In-Reply-To: <97934904-2754-77e0-5fcb-83f2311362ee@nvidia.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Hubbard <jhubbard@nvidia.com>, john.hubbard@gmail.com, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>, linux-fsdevel@vger.kernel.org

On 11/21/2018 1:09 AM, John Hubbard wrote:
> On 11/19/18 10:57 AM, Tom Talpey wrote:
>> ~14000 4KB read IOPS is really, really low for an NVMe disk.
> 
> Yes, but Jan Kara's original config file for fio is *intended* to highlight
> the get_user_pages/put_user_pages changes. It was *not* intended to get max
> performance,  as you can see by the numjobs and direct IO parameters:
> 
> cat fio.conf
> [reader]
> direct=1
> ioengine=libaio
> blocksize=4096
> size=1g
> numjobs=1
> rw=read
> iodepth=64

To be clear - I used those identical parameters, on my lower-spec
machine, and got 400,000 4KB read IOPS. Those results are nearly 30x
higher than yours!

> So I'm thinking that this is not a "tainted" test, but rather, we're constraining
> things a lot with these choices. It's hard to find a good test config to run that
> allows decisions, but so far, I'm not really seeing anything that says "this
> is so bad that we can't afford to fix the brokenness." I think.

I'm not suggesting we tune the benchmark, I'm suggesting the results
on your system are not meaningful since they are orders of magnitude
low. And without meaningful data it's impossible to see the performance
impact of the change...

>> Can you confirm what type of hardware you're running this test on?
>> CPU, memory speed and capacity, and NVMe device especially?
>>
>> Tom.
> 
> Yes, it's a nice new system, I don't expect any strange perf problems:
> 
> CPU: Intel(R) Core(TM) i7-7800X CPU @ 3.50GHz
>      (Intel X299 chipset)
> Block device: nvme-Samsung_SSD_970_EVO_250GB
> DRAM: 32 GB

The Samsung Evo 970 250GB is speced to yield 200,000 random read IOPS
with a 4KB QD32 workload:

 
https://www.samsung.com/us/computing/memory-storage/solid-state-drives/ssd-970-evo-nvme-m-2-250gb-mz-v7e250bw/#specs

And the I7-7800X is a 6-core processor (12 hyperthreads).

> So, here's a comparison using 20 threads, direct IO, for the baseline vs.
> patched kernel (below). Highlights:
> 
> 	-- IOPS are similar, around 60k.
> 	-- BW gets worse, dropping from 290 to 220 MB/s.
> 	-- CPU is well under 100%.
> 	-- latency is incredibly long, but...20 threads.
> 
> Baseline:
> 
> $ ./run.sh
> fio configuration:
> [reader]
> ioengine=libaio
> blocksize=4096
> size=1g
> rw=read
> group_reporting
> iodepth=256
> direct=1
> numjobs=20

Ouch - 20 threads issuing 256 io's each!? Of course latency skyrockets.
That's going to cause tremendous queuing, and context switching, far
outside of the get_user_pages() change.

But even so, it only brings IOPS to 74.2K, which is still far short of
the device's 200K spec.

Comparing anyway:


> Patched:
> 
> -------- Running fio:
> reader: (g=0): rw=read, bs=(R) 4096B-4096B, (W) 4096B-4096B, (T) 4096B-4096B, ioengine=libaio, iodepth=256
> ...
> fio-3.3
> Starting 20 processes
> Jobs: 13 (f=8): [_(1),R(1),_(1),f(1),R(2),_(1),f(2),_(1),R(1),f(1),R(1),f(1),R(1),_(2),R(1),_(1),R(1)][97.9%][r=229MiB/s,w=0KiB/s][r=58.5k,w=0 IOPS][eta 00m:02s]
> reader: (groupid=0, jobs=20): err= 0: pid=2104: Tue Nov 20 22:01:58 2018
>     read: IOPS=56.8k, BW=222MiB/s (232MB/s)(20.0GiB/92385msec)
> ...
> Thoughts?

Concern - the 74.2K IOPS unpatched drops to 56.8K patched!

What I'd really like to see is to go back to the original fio parameters
(1 thread, 64 iodepth) and try to get a result that gets at least close
to the speced 200K IOPS of the NVMe device. There seems to be something
wrong with yours, currently.

Then of course, the result with the patched get_user_pages, and
compare whichever of IOPS or CPU% changes, and how much.

If these are within a few percent, I agree it's good to go. If it's
roughly 25% like the result just above, that's a rocky road.

I can try this after the holiday on some basic hardware and might
be able to scrounge up better. Can you post that github link?

Tom.
