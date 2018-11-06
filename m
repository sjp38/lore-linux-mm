Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3BD546B02AA
	for <linux-mm@kvack.org>; Mon,  5 Nov 2018 21:47:20 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id d8-v6so10519045pgq.3
        for <linux-mm@kvack.org>; Mon, 05 Nov 2018 18:47:20 -0800 (PST)
Received: from ipmail02.adl2.internode.on.net (ipmail02.adl2.internode.on.net. [150.101.137.139])
        by mx.google.com with ESMTP id q129-v6si44231026pga.96.2018.11.05.18.47.17
        for <linux-mm@kvack.org>;
        Mon, 05 Nov 2018 18:47:18 -0800 (PST)
Date: Tue, 6 Nov 2018 13:47:15 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 4/6] mm: introduce page->dma_pinned_flags, _count
Message-ID: <20181106024715.GU6311@dastard>
References: <20181012060014.10242-1-jhubbard@nvidia.com>
 <20181012060014.10242-5-jhubbard@nvidia.com>
 <20181013035516.GA18822@dastard>
 <7c2e3b54-0b1d-6726-a508-804ef8620cfd@nvidia.com>
 <20181013164740.GA6593@infradead.org>
 <84811b54-60bf-2bc3-a58d-6a7925c24aad@nvidia.com>
 <20181105095447.GE6953@quack2.suse.cz>
 <f5ad7210-05e0-3dc4-02df-01ce5346e198@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <f5ad7210-05e0-3dc4-02df-01ce5346e198@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@infradead.org>, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>, Jason Gunthorpe <jgg@ziepe.ca>, Dan Williams <dan.j.williams@intel.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>, linux-fsdevel@vger.kernel.org

On Mon, Nov 05, 2018 at 04:26:04PM -0800, John Hubbard wrote:
> On 11/5/18 1:54 AM, Jan Kara wrote:
> > Hmm, have you tried larger buffer sizes? Because synchronous 8k IO isn't
> > going to max-out NVME iops by far. Can I suggest you install fio [1] (it
> > has the advantage that it is pretty much standard for a test like this so
> > everyone knows what the test does from a glimpse) and run with it something
> > like the following workfile:
> > 
> > [reader]
> > direct=1
> > ioengine=libaio
> > blocksize=4096
> > size=1g
> > numjobs=1
> > rw=read
> > iodepth=64
> > 
> > And see how the numbers with and without your patches compare?
> > 
> > 								Honza
> > 
> > [1] https://github.com/axboe/fio
> 
> That program is *very* good to have. Whew. Anyway, it looks like read bandwidth 
> is approximately 74 MiB/s with my patch (it varies a bit, run to run),
> as compared to around 85 without the patch, so still showing about a 20%
> performance degradation, assuming I'm reading this correctly.
> 
> Raw data follows, using the fio options you listed above:
> 
> Baseline (without my patch):
> ---------------------------- 
....
>      lat (usec): min=179, max=14003, avg=2913.65, stdev=1241.75
>     clat percentiles (usec):
>      |  1.00th=[ 2311],  5.00th=[ 2343], 10.00th=[ 2343], 20.00th=[ 2343],
>      | 30.00th=[ 2343], 40.00th=[ 2376], 50.00th=[ 2376], 60.00th=[ 2376],
>      | 70.00th=[ 2409], 80.00th=[ 2933], 90.00th=[ 4359], 95.00th=[ 5276],
>      | 99.00th=[ 8291], 99.50th=[ 9110], 99.90th=[10945], 99.95th=[11469],
>      | 99.99th=[12256]
.....
> Modified (with my patch):
> ---------------------------- 
.....
>      lat (usec): min=81, max=15766, avg=3496.57, stdev=1450.21
>     clat percentiles (usec):
>      |  1.00th=[ 2835],  5.00th=[ 2835], 10.00th=[ 2835], 20.00th=[ 2868],
>      | 30.00th=[ 2868], 40.00th=[ 2868], 50.00th=[ 2868], 60.00th=[ 2900],
>      | 70.00th=[ 2933], 80.00th=[ 3425], 90.00th=[ 5080], 95.00th=[ 6259],
>      | 99.00th=[10159], 99.50th=[11076], 99.90th=[12649], 99.95th=[13435],
>      | 99.99th=[14484]

So it's adding at least 500us of completion latency to every IO?
I'd argue that the IO latency impact is far worse than the a 20%
throughput drop.

i.e. You can make up for throughput drops by running a deeper
queue/more dispatch threads, but you can't reduce IO latency at
all...

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
