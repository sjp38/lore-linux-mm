Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 4EC7F6B006E
	for <linux-mm@kvack.org>; Wed, 18 Jun 2014 01:03:14 -0400 (EDT)
Received: by mail-pd0-f173.google.com with SMTP id r10so297911pdi.4
        for <linux-mm@kvack.org>; Tue, 17 Jun 2014 22:03:14 -0700 (PDT)
Received: from ipmail06.adl2.internode.on.net (ipmail06.adl2.internode.on.net. [2001:44b8:8060:ff02:300:1:2:6])
        by mx.google.com with ESMTP id xo10si853563pac.162.2014.06.17.22.03.12
        for <linux-mm@kvack.org>;
        Tue, 17 Jun 2014 22:03:12 -0700 (PDT)
Date: Wed, 18 Jun 2014 15:02:30 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH] [RFC] xfs: wire up aio_fsync method
Message-ID: <20140618050230.GO9508@dastard>
References: <20140616020030.GC9508@dastard>
 <539E5D66.8040605@kernel.dk>
 <20140616071951.GD9508@dastard>
 <539F45E2.5030909@kernel.dk>
 <20140616222729.GE9508@dastard>
 <53A0416E.20105@kernel.dk>
 <20140618002845.GM9508@dastard>
 <53A0F84A.6040708@kernel.dk>
 <20140618031329.GN9508@dastard>
 <53A10597.6020707@kernel.dk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <53A10597.6020707@kernel.dk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@kernel.dk>
Cc: Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org, linux-man@vger.kernel.org, xfs@oss.sgi.com, linux-mm@kvack.org

On Tue, Jun 17, 2014 at 08:20:55PM -0700, Jens Axboe wrote:
> On 2014-06-17 20:13, Dave Chinner wrote:
> >On Tue, Jun 17, 2014 at 07:24:10PM -0700, Jens Axboe wrote:
> >>On 2014-06-17 17:28, Dave Chinner wrote:
> >>>[cc linux-mm]
> >>>
> >>>On Tue, Jun 17, 2014 at 07:23:58AM -0600, Jens Axboe wrote:
> >>>>On 2014-06-16 16:27, Dave Chinner wrote:
> >>>>>On Mon, Jun 16, 2014 at 01:30:42PM -0600, Jens Axboe wrote:
> >>>>>>On 06/16/2014 01:19 AM, Dave Chinner wrote:
> >>>>>>>On Sun, Jun 15, 2014 at 08:58:46PM -0600, Jens Axboe wrote:
> >>>>>>>>On 2014-06-15 20:00, Dave Chinner wrote:
> >>>>>>>>>On Mon, Jun 16, 2014 at 08:33:23AM +1000, Dave Chinner wrote:
> >>>>>>>>>FWIW, the non-linear system CPU overhead of a fs_mark test I've been
> >>>>>>>>>running isn't anything related to XFS.  The async fsync workqueue
> >>>>>>>>>results in several thousand worker threads dispatching IO
> >>>>>>>>>concurrently across 16 CPUs:
> >....
> >>>>>>>>>I know that the tag allocator has been rewritten, so I tested
> >>>>>>>>>against a current a current Linus kernel with the XFS aio-fsync
> >>>>>>>>>patch. The results are all over the place - from several sequential
> >>>>>>>>>runs of the same test (removing the files in between so each tests
> >>>>>>>>>starts from an empty fs):
> >>>>>>>>>
> >>>>>>>>>Wall time	sys time	IOPS	 files/s
> >>>>>>>>>4m58.151s	11m12.648s	30,000	 13,500
> >>>>>>>>>4m35.075s	12m45.900s	45,000	 15,000
> >>>>>>>>>3m10.665s	11m15.804s	65,000	 21,000
> >>>>>>>>>3m27.384s	11m54.723s	85,000	 20,000
> >>>>>>>>>3m59.574s	11m12.012s	50,000	 16,500
> >>>>>>>>>4m12.704s	12m15.720s	50,000	 17,000

....
> >But the IOPS rate has definitely increased with this config
> >- I just saw 90k, 100k and 110k IOPS in the last 3 iterations of the
> >workload (the above profile is from the 100k IOPS period). However,
> >the wall time was still only 3m58s, which again tends to implicate
> >the write() portion of the benchmark for causing the slowdowns
> >rather than the fsync() portion that is dispatching all the IO...
> 
> Some contention for this case is hard to avoid, and the above looks
> better than 3.15 does. So the big question is whether it's worth
> fixing the gaps with multiple waitqueues (and if that actually still
> buys us anything), or whether we should just disable them.
> 
> If I can get you to try one more thing, can you apply this patch and
> give that a whirl? Get rid of the other patches I sent first, this
> has everything.

Not much difference in the CPU usage profiles or base line
performance. It runs at 3m10s from empty memory, and ~3m45s when
memory starts full of clean pages. system time varies from 10m40s to
12m55s with no real correlation to overall runtime.

>From observation of all the performance metrics I graph in real
time, however, the pattern of the peaks and troughs from run to run
and even iteration to iteration is much more regular than the
previous patches. So from that perspective it is an improvement.
Again, all the variability in the graphs show up when free memory
runs out...

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
