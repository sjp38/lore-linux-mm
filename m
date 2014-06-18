Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f45.google.com (mail-pb0-f45.google.com [209.85.160.45])
	by kanga.kvack.org (Postfix) with ESMTP id E84A76B005A
	for <linux-mm@kvack.org>; Tue, 17 Jun 2014 23:13:34 -0400 (EDT)
Received: by mail-pb0-f45.google.com with SMTP id rr13so238276pbb.4
        for <linux-mm@kvack.org>; Tue, 17 Jun 2014 20:13:34 -0700 (PDT)
Received: from ipmail06.adl2.internode.on.net (ipmail06.adl2.internode.on.net. [2001:44b8:8060:ff02:300:1:2:6])
        by mx.google.com with ESMTP id qe5si619878pac.103.2014.06.17.20.13.32
        for <linux-mm@kvack.org>;
        Tue, 17 Jun 2014 20:13:33 -0700 (PDT)
Date: Wed, 18 Jun 2014 13:13:29 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH] [RFC] xfs: wire up aio_fsync method
Message-ID: <20140618031329.GN9508@dastard>
References: <20140613162352.GB23394@infradead.org>
 <20140615223323.GB9508@dastard>
 <20140616020030.GC9508@dastard>
 <539E5D66.8040605@kernel.dk>
 <20140616071951.GD9508@dastard>
 <539F45E2.5030909@kernel.dk>
 <20140616222729.GE9508@dastard>
 <53A0416E.20105@kernel.dk>
 <20140618002845.GM9508@dastard>
 <53A0F84A.6040708@kernel.dk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <53A0F84A.6040708@kernel.dk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@kernel.dk>
Cc: Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org, linux-man@vger.kernel.org, xfs@oss.sgi.com, linux-mm@kvack.org

On Tue, Jun 17, 2014 at 07:24:10PM -0700, Jens Axboe wrote:
> On 2014-06-17 17:28, Dave Chinner wrote:
> >[cc linux-mm]
> >
> >On Tue, Jun 17, 2014 at 07:23:58AM -0600, Jens Axboe wrote:
> >>On 2014-06-16 16:27, Dave Chinner wrote:
> >>>On Mon, Jun 16, 2014 at 01:30:42PM -0600, Jens Axboe wrote:
> >>>>On 06/16/2014 01:19 AM, Dave Chinner wrote:
> >>>>>On Sun, Jun 15, 2014 at 08:58:46PM -0600, Jens Axboe wrote:
> >>>>>>On 2014-06-15 20:00, Dave Chinner wrote:
> >>>>>>>On Mon, Jun 16, 2014 at 08:33:23AM +1000, Dave Chinner wrote:
> >>>>>>>FWIW, the non-linear system CPU overhead of a fs_mark test I've been
> >>>>>>>running isn't anything related to XFS.  The async fsync workqueue
> >>>>>>>results in several thousand worker threads dispatching IO
> >>>>>>>concurrently across 16 CPUs:
....
> >>>>>>>I know that the tag allocator has been rewritten, so I tested
> >>>>>>>against a current a current Linus kernel with the XFS aio-fsync
> >>>>>>>patch. The results are all over the place - from several sequential
> >>>>>>>runs of the same test (removing the files in between so each tests
> >>>>>>>starts from an empty fs):
> >>>>>>>
> >>>>>>>Wall time	sys time	IOPS	 files/s
> >>>>>>>4m58.151s	11m12.648s	30,000	 13,500
> >>>>>>>4m35.075s	12m45.900s	45,000	 15,000
> >>>>>>>3m10.665s	11m15.804s	65,000	 21,000
> >>>>>>>3m27.384s	11m54.723s	85,000	 20,000
> >>>>>>>3m59.574s	11m12.012s	50,000	 16,500
> >>>>>>>4m12.704s	12m15.720s	50,000	 17,000
> >>>>>>>
> >>>>>>>The 3.15 based kernel was pretty consistent around the 4m10 mark,
> >>>>>>>generally only +/-10s in runtime and not much change in system time.
> >>>>>>>The files/s rate reported by fs_mark doesn't vary that much, either.
> >>>>>>>So the new tag allocator seems to be no better in terms of IO
> >>>>>>>dispatch scalability, yet adds significant variability to IO
> >>>>>>>performance.
> >>>>>>>
> >>>>>>>What I noticed is a massive jump in context switch overhead: from
> >>>>>>>around 250,000/s to over 800,000/s and the CPU profiles show that
> >>>>>>>this comes from the new tag allocator:
....
> >>>>Can you try with this patch?
> >>>
> >>>Ok, context switches are back down in the realm of 400,000/s. It's
> >>>better, but it's still a bit higher than that the 3.15 code. XFS is
> >>>actually showing up in the context switch path profiles now...
> >>>
> >>>However, performance is still excitingly variable and not much
> >>>different to not having this patch applied. System time is unchanged
> >>>(still around the 11m20s +/- 1m) and IOPS, wall time and files/s all
> >>>show significant variance (at least +/-25%) from run to run. The
> >>>worst case is not as slow as the unpatched kernel, but it's no
> >>>better than the 3.15 worst case.
....
> >>>Looks like the main contention problem is in blk_sq_make_request().
> >>>Also, there looks to be quite a bit of lock contention on the tag
> >>>wait queues given that this patch made prepare_to_wait_exclusive()
> >>>suddenly show up in the profiles.
> >>>
> >>>FWIW, on a fast run there is very little time in
> >>>blk_sq_make_request() lock contention, and overall spin lock/unlock
> >>>overhead of these two functions is around 10% each....
> >>>
> >>>So, yes, the patch reduces context switches but doesn't really
> >>>reduce system time, improve performance noticably or address the
> >>>run-to-run variability issue...
> >>
> >>OK, so one more thing to try. With the same patch still applied,
> >>could you edit block/blk-mq-tag.h and change
> >>
> >>         BT_WAIT_QUEUES  = 8,
> >>
> >>to
> >>
> >>         BT_WAIT_QUEUES  = 1,
> >>
> >>and see if that smoothes things out?
> >
> >Ok, that smoothes things out to the point where I can see the
> >trigger for the really nasty variable performance. The trigger is
> >the machine running out of free memory. i.e. direct reclaim of clean
> >pages for the data in the new files in the page cache drives the
> >performance down by 25-50% and introduces significant variability.
> >
> >So the variability doesn't seem to be solely related to the tag
> >allocator; it is contributing some via wait queue contention,
> >but it's definitely not the main contributor, nor the trigger...
> >
> >MM-folk - the VM is running fake-numa=4 and has 16GB of RAM, and
> >each step in the workload is generating 3.2GB of dirty pages (i.e.
> >just on the dirty throttling threshold). It then does a concurrent
> >asynchronous fsync of the 800,000 dirty files it just created,
> >leaving 3.2GB of clean pages in the cache. The workload iterates
> >this several times. Once the machine runs out of free memory (2.5
> >iterations in) performance drops by about 30% on average, but the
> >drop varies between 20-60% randomly. I'm not concerned by a 30% drop
> >when memory fills up - I'm concerned by the volatility of the drop
> >that occurs. e.g:
> >
> >FSUse%        Count         Size    Files/sec     App Overhead
> >      0       800000         4096      29938.0         13459475
> >      0      1600000         4096      28023.7         15662387
> >      0      2400000         4096      23704.6         16451761
> >      0      3200000         4096      16976.8         15029056
> >      0      4000000         4096      21858.3         15591604
> >
> >Iteration 3 is where memory fills, and you can see that performance
> >dropped by 25%. Iteration 4 drops another 25%, then iteration 5
> >regains it. If I keep running the workload for more iterations, this
> >is pretty typical of the iteration-to-iteration variability, even
> >though every iteration is identical in behaviour as are the initial
> >conditions (i.e. memory full of clean, used-once pages).
> >
> >This didn't happen in 3.15.0, but the behaviour may have been masked
> >by the block layer tag allocator CPU overhead dominating the system
> >behaviour.
> 
> OK, that's reassuring. I'll do some testing with the cyclic wait
> queues, but probably not until Thursday. Alexanders patches might
> potentially fix the variability as well, but if we can make-do
> without the multiple wait queues, I'd much rather just kill it.
> 
> Did you see any spinlock contention with BT_WAIT_QUEUES = 1?

Yes. During the 15-20s of high IOPS dispatch rates the profile looks
like this:

-  36.00%  [kernel]  [k] _raw_spin_unlock_irq
   - _raw_spin_unlock_irq
      - 69.72% blk_sq_make_request
           generic_make_request
         + submit_bio
      + 24.81% __schedule
....
-  15.00%  [kernel]  [k] _raw_spin_unlock_irqrestore
   - _raw_spin_unlock_irqrestore
      - 32.87% prepare_to_wait_exclusive
           bt_get
           blk_mq_get_tag
           __blk_mq_alloc_request
           blk_mq_map_request
           blk_sq_make_request
           generic_make_request
         + submit_bio
      - 29.21% virtio_queue_rq
           __blk_mq_run_hw_queue
      + 11.69% complete
      + 8.21% finish_wait
        8.10% remove_wait_queue

But the IOPS rate has definitely increased with this config
- I just saw 90k, 100k and 110k IOPS in the last 3 iterations of the
workload (the above profile is from the 100k IOPS period). However,
the wall time was still only 3m58s, which again tends to implicate
the write() portion of the benchmark for causing the slowdowns
rather than the fsync() portion that is dispatching all the IO...

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
