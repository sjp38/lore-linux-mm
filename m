Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 703256B004D
	for <linux-mm@kvack.org>; Tue, 17 Jun 2014 22:24:14 -0400 (EDT)
Received: by mail-pd0-f178.google.com with SMTP id r10so170156pdi.9
        for <linux-mm@kvack.org>; Tue, 17 Jun 2014 19:24:14 -0700 (PDT)
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
        by mx.google.com with ESMTPS id mk6si506726pab.91.2014.06.17.19.24.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 17 Jun 2014 19:24:12 -0700 (PDT)
Received: by mail-pa0-f52.google.com with SMTP id eu11so189626pac.25
        for <linux-mm@kvack.org>; Tue, 17 Jun 2014 19:24:11 -0700 (PDT)
Message-ID: <53A0F84A.6040708@kernel.dk>
Date: Tue, 17 Jun 2014 19:24:10 -0700
From: Jens Axboe <axboe@kernel.dk>
MIME-Version: 1.0
Subject: Re: [PATCH] [RFC] xfs: wire up aio_fsync method
References: <20140612141329.GA11676@infradead.org> <20140612234441.GT9508@dastard> <20140613162352.GB23394@infradead.org> <20140615223323.GB9508@dastard> <20140616020030.GC9508@dastard> <539E5D66.8040605@kernel.dk> <20140616071951.GD9508@dastard> <539F45E2.5030909@kernel.dk> <20140616222729.GE9508@dastard> <53A0416E.20105@kernel.dk> <20140618002845.GM9508@dastard>
In-Reply-To: <20140618002845.GM9508@dastard>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org, linux-man@vger.kernel.org, xfs@oss.sgi.com, linux-mm@kvack.org

On 2014-06-17 17:28, Dave Chinner wrote:
> [cc linux-mm]
>
> On Tue, Jun 17, 2014 at 07:23:58AM -0600, Jens Axboe wrote:
>> On 2014-06-16 16:27, Dave Chinner wrote:
>>> On Mon, Jun 16, 2014 at 01:30:42PM -0600, Jens Axboe wrote:
>>>> On 06/16/2014 01:19 AM, Dave Chinner wrote:
>>>>> On Sun, Jun 15, 2014 at 08:58:46PM -0600, Jens Axboe wrote:
>>>>>> On 2014-06-15 20:00, Dave Chinner wrote:
>>>>>>> On Mon, Jun 16, 2014 at 08:33:23AM +1000, Dave Chinner wrote:
>>>>>>> FWIW, the non-linear system CPU overhead of a fs_mark test I've been
>>>>>>> running isn't anything related to XFS.  The async fsync workqueue
>>>>>>> results in several thousand worker threads dispatching IO
>>>>>>> concurrently across 16 CPUs:
>>>>>>>
>>>>>>> $ ps -ef |grep kworker |wc -l
>>>>>>> 4693
>>>>>>> $
>>>>>>>
>>>>>>> Profiles from 3.15 + xfs for-next + xfs aio_fsync show:
>>>>>>>
>>>>>>> -  51.33%  [kernel]            [k] percpu_ida_alloc
>>>>>>>     - percpu_ida_alloc
>>>>>>>        + 85.73% blk_mq_wait_for_tags
>>>>>>>        + 14.23% blk_mq_get_tag
>>>>>>> -  14.25%  [kernel]            [k] _raw_spin_unlock_irqrestore
>>>>>>>     - _raw_spin_unlock_irqrestore
>>>>>>>        - 66.26% virtio_queue_rq
>>>>>>>           - __blk_mq_run_hw_queue
>>>>>>>              - 99.65% blk_mq_run_hw_queue
>>>>>>>                 + 99.47% blk_mq_insert_requests
>>>>>>>                 + 0.53% blk_mq_insert_request
>>>>>>> .....
>>>>>>> -   7.91%  [kernel]            [k] _raw_spin_unlock_irq
>>>>>>>     - _raw_spin_unlock_irq
>>>>>>>        - 69.59% __schedule
>>>>>>>           - 86.49% schedule
>>>>>>>              + 47.72% percpu_ida_alloc
>>>>>>>              + 21.75% worker_thread
>>>>>>>              + 19.12% schedule_timeout
>>>>>>> ....
>>>>>>>        + 18.06% blk_mq_make_request
>>>>>>>
>>>>>>> Runtime:
>>>>>>>
>>>>>>> real    4m1.243s
>>>>>>> user    0m47.724s
>>>>>>> sys     11m56.724s
>>>>>>>
>>>>>>> Most of the excessive CPU usage is coming from the blk-mq layer, and
>>>>>>> XFS is barely showing up in the profiles at all - the IDA tag
>>>>>>> allocator is burning 8 CPUs at about 60,000 write IOPS....
>>>>>>>
>>>>>>> I know that the tag allocator has been rewritten, so I tested
>>>>>>> against a current a current Linus kernel with the XFS aio-fsync
>>>>>>> patch. The results are all over the place - from several sequential
>>>>>>> runs of the same test (removing the files in between so each tests
>>>>>>> starts from an empty fs):
>>>>>>>
>>>>>>> Wall time	sys time	IOPS	 files/s
>>>>>>> 4m58.151s	11m12.648s	30,000	 13,500
>>>>>>> 4m35.075s	12m45.900s	45,000	 15,000
>>>>>>> 3m10.665s	11m15.804s	65,000	 21,000
>>>>>>> 3m27.384s	11m54.723s	85,000	 20,000
>>>>>>> 3m59.574s	11m12.012s	50,000	 16,500
>>>>>>> 4m12.704s	12m15.720s	50,000	 17,000
>>>>>>>
>>>>>>> The 3.15 based kernel was pretty consistent around the 4m10 mark,
>>>>>>> generally only +/-10s in runtime and not much change in system time.
>>>>>>> The files/s rate reported by fs_mark doesn't vary that much, either.
>>>>>>> So the new tag allocator seems to be no better in terms of IO
>>>>>>> dispatch scalability, yet adds significant variability to IO
>>>>>>> performance.
>>>>>>>
>>>>>>> What I noticed is a massive jump in context switch overhead: from
>>>>>>> around 250,000/s to over 800,000/s and the CPU profiles show that
>>>>>>> this comes from the new tag allocator:
>>>>>>>
>>>>>>> -  34.62%  [kernel]  [k] _raw_spin_unlock_irqrestore
>>>>>>>     - _raw_spin_unlock_irqrestore
>>>>>>>        - 58.22% prepare_to_wait
>>>>>>>             100.00% bt_get
>>>>>>>                blk_mq_get_tag
>>>>>>>                __blk_mq_alloc_request
>>>>>>>                blk_mq_map_request
>>>>>>>                blk_sq_make_request
>>>>>>>                generic_make_request
>>>>>>>        - 22.51% virtio_queue_rq
>>>>>>>             __blk_mq_run_hw_queue
>>>>>>> ....
>>>>>>> -  21.56%  [kernel]  [k] _raw_spin_unlock_irq
>>>>>>>     - _raw_spin_unlock_irq
>>>>>>>        - 58.73% __schedule
>>>>>>>           - 53.42% io_schedule
>>>>>>>                99.88% bt_get
>>>>>>>                   blk_mq_get_tag
>>>>>>>                   __blk_mq_alloc_request
>>>>>>>                   blk_mq_map_request
>>>>>>>                   blk_sq_make_request
>>>>>>>                   generic_make_request
>>>>>>>           - 35.58% schedule
>>>>>>>              + 49.31% worker_thread
>>>>>>>              + 32.45% schedule_timeout
>>>>>>>              + 10.35% _xfs_log_force_lsn
>>>>>>>              + 3.10% xlog_cil_force_lsn
>>>>>>> ....
>>> .....
>>>> Can you try with this patch?
>>>
>>> Ok, context switches are back down in the realm of 400,000/s. It's
>>> better, but it's still a bit higher than that the 3.15 code. XFS is
>>> actually showing up in the context switch path profiles now...
>>>
>>> However, performance is still excitingly variable and not much
>>> different to not having this patch applied. System time is unchanged
>>> (still around the 11m20s +/- 1m) and IOPS, wall time and files/s all
>>> show significant variance (at least +/-25%) from run to run. The
>>> worst case is not as slow as the unpatched kernel, but it's no
>>> better than the 3.15 worst case.
>>>
>>> Profiles on a slow run look like:
>>>
>>> -  43.43%  [kernel]  [k] _raw_spin_unlock_irq
>>>     - _raw_spin_unlock_irq
>>>        - 64.23% blk_sq_make_request
>>>             generic_make_request
>>>            submit_bio                                                                                                                                                  ?
>>>        + 26.79% __schedule
>>> ...
>>> -  15.00%  [kernel]  [k] _raw_spin_unlock_irqrestore
>>>     - _raw_spin_unlock_irqrestore
>>>        - 39.81% virtio_queue_rq
>>>             __blk_mq_run_hw_queue
>>>        + 24.13% complete
>>>        + 17.74% prepare_to_wait_exclusive
>>>        + 9.66% remove_wait_queue
>>>
>>> Looks like the main contention problem is in blk_sq_make_request().
>>> Also, there looks to be quite a bit of lock contention on the tag
>>> wait queues given that this patch made prepare_to_wait_exclusive()
>>> suddenly show up in the profiles.
>>>
>>> FWIW, on a fast run there is very little time in
>>> blk_sq_make_request() lock contention, and overall spin lock/unlock
>>> overhead of these two functions is around 10% each....
>>>
>>> So, yes, the patch reduces context switches but doesn't really
>>> reduce system time, improve performance noticably or address the
>>> run-to-run variability issue...
>>
>> OK, so one more thing to try. With the same patch still applied,
>> could you edit block/blk-mq-tag.h and change
>>
>>          BT_WAIT_QUEUES  = 8,
>>
>> to
>>
>>          BT_WAIT_QUEUES  = 1,
>>
>> and see if that smoothes things out?
>
> Ok, that smoothes things out to the point where I can see the
> trigger for the really nasty variable performance. The trigger is
> the machine running out of free memory. i.e. direct reclaim of clean
> pages for the data in the new files in the page cache drives the
> performance down by 25-50% and introduces significant variability.
>
> So the variability doesn't seem to be solely related to the tag
> allocator; it is contributing some via wait queue contention,
> but it's definitely not the main contributor, nor the trigger...
>
> MM-folk - the VM is running fake-numa=4 and has 16GB of RAM, and
> each step in the workload is generating 3.2GB of dirty pages (i.e.
> just on the dirty throttling threshold). It then does a concurrent
> asynchronous fsync of the 800,000 dirty files it just created,
> leaving 3.2GB of clean pages in the cache. The workload iterates
> this several times. Once the machine runs out of free memory (2.5
> iterations in) performance drops by about 30% on average, but the
> drop varies between 20-60% randomly. I'm not concerned by a 30% drop
> when memory fills up - I'm concerned by the volatility of the drop
> that occurs. e.g:
>
> FSUse%        Count         Size    Files/sec     App Overhead
>       0       800000         4096      29938.0         13459475
>       0      1600000         4096      28023.7         15662387
>       0      2400000         4096      23704.6         16451761
>       0      3200000         4096      16976.8         15029056
>       0      4000000         4096      21858.3         15591604
>
> Iteration 3 is where memory fills, and you can see that performance
> dropped by 25%. Iteration 4 drops another 25%, then iteration 5
> regains it. If I keep running the workload for more iterations, this
> is pretty typical of the iteration-to-iteration variability, even
> though every iteration is identical in behaviour as are the initial
> conditions (i.e. memory full of clean, used-once pages).
>
> This didn't happen in 3.15.0, but the behaviour may have been masked
> by the block layer tag allocator CPU overhead dominating the system
> behaviour.

OK, that's reassuring. I'll do some testing with the cyclic wait queues, 
but probably not until Thursday. Alexanders patches might potentially 
fix the variability as well, but if we can make-do without the multiple 
wait queues, I'd much rather just kill it.

Did you see any spinlock contention with BT_WAIT_QUEUES = 1?

>> On the road the next few days, so might take me a few days to get
>> back to this. I was able to reproduce the horrible contention on the
>> wait queue, but everything seemed to behave nicely with just the
>> exclusive_wait/batch_wakeup for me. Looks like I might have to fire
>> up kvm and set it you like you.
>
> I'm guessing that the difference is that you weren't driving the
> machine into memory reclaim at the same time.

My testing was purely O_DIRECT, so no, no reclaim at all. I was only 
focused on the lock contention in there, and the patch completely got 
rid of that.

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
