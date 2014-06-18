Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 611576B0062
	for <linux-mm@kvack.org>; Tue, 17 Jun 2014 23:20:59 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id rd3so238914pab.32
        for <linux-mm@kvack.org>; Tue, 17 Jun 2014 20:20:59 -0700 (PDT)
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
        by mx.google.com with ESMTPS id ir1si643879pbb.43.2014.06.17.20.20.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 17 Jun 2014 20:20:57 -0700 (PDT)
Received: by mail-pd0-f173.google.com with SMTP id r10so215060pdi.32
        for <linux-mm@kvack.org>; Tue, 17 Jun 2014 20:20:57 -0700 (PDT)
Message-ID: <53A10597.6020707@kernel.dk>
Date: Tue, 17 Jun 2014 20:20:55 -0700
From: Jens Axboe <axboe@kernel.dk>
MIME-Version: 1.0
Subject: Re: [PATCH] [RFC] xfs: wire up aio_fsync method
References: <20140613162352.GB23394@infradead.org> <20140615223323.GB9508@dastard> <20140616020030.GC9508@dastard> <539E5D66.8040605@kernel.dk> <20140616071951.GD9508@dastard> <539F45E2.5030909@kernel.dk> <20140616222729.GE9508@dastard> <53A0416E.20105@kernel.dk> <20140618002845.GM9508@dastard> <53A0F84A.6040708@kernel.dk> <20140618031329.GN9508@dastard>
In-Reply-To: <20140618031329.GN9508@dastard>
Content-Type: multipart/mixed;
 boundary="------------000702050707010803000904"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org, linux-man@vger.kernel.org, xfs@oss.sgi.com, linux-mm@kvack.org

This is a multi-part message in MIME format.
--------------000702050707010803000904
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

On 2014-06-17 20:13, Dave Chinner wrote:
> On Tue, Jun 17, 2014 at 07:24:10PM -0700, Jens Axboe wrote:
>> On 2014-06-17 17:28, Dave Chinner wrote:
>>> [cc linux-mm]
>>>
>>> On Tue, Jun 17, 2014 at 07:23:58AM -0600, Jens Axboe wrote:
>>>> On 2014-06-16 16:27, Dave Chinner wrote:
>>>>> On Mon, Jun 16, 2014 at 01:30:42PM -0600, Jens Axboe wrote:
>>>>>> On 06/16/2014 01:19 AM, Dave Chinner wrote:
>>>>>>> On Sun, Jun 15, 2014 at 08:58:46PM -0600, Jens Axboe wrote:
>>>>>>>> On 2014-06-15 20:00, Dave Chinner wrote:
>>>>>>>>> On Mon, Jun 16, 2014 at 08:33:23AM +1000, Dave Chinner wrote:
>>>>>>>>> FWIW, the non-linear system CPU overhead of a fs_mark test I've been
>>>>>>>>> running isn't anything related to XFS.  The async fsync workqueue
>>>>>>>>> results in several thousand worker threads dispatching IO
>>>>>>>>> concurrently across 16 CPUs:
> ....
>>>>>>>>> I know that the tag allocator has been rewritten, so I tested
>>>>>>>>> against a current a current Linus kernel with the XFS aio-fsync
>>>>>>>>> patch. The results are all over the place - from several sequential
>>>>>>>>> runs of the same test (removing the files in between so each tests
>>>>>>>>> starts from an empty fs):
>>>>>>>>>
>>>>>>>>> Wall time	sys time	IOPS	 files/s
>>>>>>>>> 4m58.151s	11m12.648s	30,000	 13,500
>>>>>>>>> 4m35.075s	12m45.900s	45,000	 15,000
>>>>>>>>> 3m10.665s	11m15.804s	65,000	 21,000
>>>>>>>>> 3m27.384s	11m54.723s	85,000	 20,000
>>>>>>>>> 3m59.574s	11m12.012s	50,000	 16,500
>>>>>>>>> 4m12.704s	12m15.720s	50,000	 17,000
>>>>>>>>>
>>>>>>>>> The 3.15 based kernel was pretty consistent around the 4m10 mark,
>>>>>>>>> generally only +/-10s in runtime and not much change in system time.
>>>>>>>>> The files/s rate reported by fs_mark doesn't vary that much, either.
>>>>>>>>> So the new tag allocator seems to be no better in terms of IO
>>>>>>>>> dispatch scalability, yet adds significant variability to IO
>>>>>>>>> performance.
>>>>>>>>>
>>>>>>>>> What I noticed is a massive jump in context switch overhead: from
>>>>>>>>> around 250,000/s to over 800,000/s and the CPU profiles show that
>>>>>>>>> this comes from the new tag allocator:
> ....
>>>>>> Can you try with this patch?
>>>>>
>>>>> Ok, context switches are back down in the realm of 400,000/s. It's
>>>>> better, but it's still a bit higher than that the 3.15 code. XFS is
>>>>> actually showing up in the context switch path profiles now...
>>>>>
>>>>> However, performance is still excitingly variable and not much
>>>>> different to not having this patch applied. System time is unchanged
>>>>> (still around the 11m20s +/- 1m) and IOPS, wall time and files/s all
>>>>> show significant variance (at least +/-25%) from run to run. The
>>>>> worst case is not as slow as the unpatched kernel, but it's no
>>>>> better than the 3.15 worst case.
> ....
>>>>> Looks like the main contention problem is in blk_sq_make_request().
>>>>> Also, there looks to be quite a bit of lock contention on the tag
>>>>> wait queues given that this patch made prepare_to_wait_exclusive()
>>>>> suddenly show up in the profiles.
>>>>>
>>>>> FWIW, on a fast run there is very little time in
>>>>> blk_sq_make_request() lock contention, and overall spin lock/unlock
>>>>> overhead of these two functions is around 10% each....
>>>>>
>>>>> So, yes, the patch reduces context switches but doesn't really
>>>>> reduce system time, improve performance noticably or address the
>>>>> run-to-run variability issue...
>>>>
>>>> OK, so one more thing to try. With the same patch still applied,
>>>> could you edit block/blk-mq-tag.h and change
>>>>
>>>>          BT_WAIT_QUEUES  = 8,
>>>>
>>>> to
>>>>
>>>>          BT_WAIT_QUEUES  = 1,
>>>>
>>>> and see if that smoothes things out?
>>>
>>> Ok, that smoothes things out to the point where I can see the
>>> trigger for the really nasty variable performance. The trigger is
>>> the machine running out of free memory. i.e. direct reclaim of clean
>>> pages for the data in the new files in the page cache drives the
>>> performance down by 25-50% and introduces significant variability.
>>>
>>> So the variability doesn't seem to be solely related to the tag
>>> allocator; it is contributing some via wait queue contention,
>>> but it's definitely not the main contributor, nor the trigger...
>>>
>>> MM-folk - the VM is running fake-numa=4 and has 16GB of RAM, and
>>> each step in the workload is generating 3.2GB of dirty pages (i.e.
>>> just on the dirty throttling threshold). It then does a concurrent
>>> asynchronous fsync of the 800,000 dirty files it just created,
>>> leaving 3.2GB of clean pages in the cache. The workload iterates
>>> this several times. Once the machine runs out of free memory (2.5
>>> iterations in) performance drops by about 30% on average, but the
>>> drop varies between 20-60% randomly. I'm not concerned by a 30% drop
>>> when memory fills up - I'm concerned by the volatility of the drop
>>> that occurs. e.g:
>>>
>>> FSUse%        Count         Size    Files/sec     App Overhead
>>>       0       800000         4096      29938.0         13459475
>>>       0      1600000         4096      28023.7         15662387
>>>       0      2400000         4096      23704.6         16451761
>>>       0      3200000         4096      16976.8         15029056
>>>       0      4000000         4096      21858.3         15591604
>>>
>>> Iteration 3 is where memory fills, and you can see that performance
>>> dropped by 25%. Iteration 4 drops another 25%, then iteration 5
>>> regains it. If I keep running the workload for more iterations, this
>>> is pretty typical of the iteration-to-iteration variability, even
>>> though every iteration is identical in behaviour as are the initial
>>> conditions (i.e. memory full of clean, used-once pages).
>>>
>>> This didn't happen in 3.15.0, but the behaviour may have been masked
>>> by the block layer tag allocator CPU overhead dominating the system
>>> behaviour.
>>
>> OK, that's reassuring. I'll do some testing with the cyclic wait
>> queues, but probably not until Thursday. Alexanders patches might
>> potentially fix the variability as well, but if we can make-do
>> without the multiple wait queues, I'd much rather just kill it.
>>
>> Did you see any spinlock contention with BT_WAIT_QUEUES = 1?
>
> Yes. During the 15-20s of high IOPS dispatch rates the profile looks
> like this:
>
> -  36.00%  [kernel]  [k] _raw_spin_unlock_irq
>     - _raw_spin_unlock_irq
>        - 69.72% blk_sq_make_request
>             generic_make_request
>           + submit_bio
>        + 24.81% __schedule
> ....
> -  15.00%  [kernel]  [k] _raw_spin_unlock_irqrestore
>     - _raw_spin_unlock_irqrestore
>        - 32.87% prepare_to_wait_exclusive
>             bt_get
>             blk_mq_get_tag
>             __blk_mq_alloc_request
>             blk_mq_map_request
>             blk_sq_make_request
>             generic_make_request
>           + submit_bio
>        - 29.21% virtio_queue_rq
>             __blk_mq_run_hw_queue
>        + 11.69% complete
>        + 8.21% finish_wait
>          8.10% remove_wait_queue
>
> But the IOPS rate has definitely increased with this config
> - I just saw 90k, 100k and 110k IOPS in the last 3 iterations of the
> workload (the above profile is from the 100k IOPS period). However,
> the wall time was still only 3m58s, which again tends to implicate
> the write() portion of the benchmark for causing the slowdowns
> rather than the fsync() portion that is dispatching all the IO...

Some contention for this case is hard to avoid, and the above looks 
better than 3.15 does. So the big question is whether it's worth fixing 
the gaps with multiple waitqueues (and if that actually still buys us 
anything), or whether we should just disable them.

If I can get you to try one more thing, can you apply this patch and 
give that a whirl? Get rid of the other patches I sent first, this has 
everything.

-- 
Jens Axboe


--------------000702050707010803000904
Content-Type: text/x-patch;
 name="wake-all.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="wake-all.patch"

diff --git a/block/blk-mq-tag.c b/block/blk-mq-tag.c
index 1aab39f71d95..d376669769e7 100644
--- a/block/blk-mq-tag.c
+++ b/block/blk-mq-tag.c
@@ -43,9 +43,16 @@ bool blk_mq_has_free_tags(struct blk_mq_tags *tags)
 	return bt_has_free_tags(&tags->bitmap_tags);
 }
 
-static inline void bt_index_inc(unsigned int *index)
+static inline int bt_index_inc(int index)
 {
-	*index = (*index + 1) & (BT_WAIT_QUEUES - 1);
+	return (index + 1) & (BT_WAIT_QUEUES - 1);
+}
+
+static inline void bt_index_atomic_inc(atomic_t *index)
+{
+	int old = atomic_read(index);
+	int new = bt_index_inc(old);
+	atomic_cmpxchg(index, old, new);
 }
 
 /*
@@ -69,14 +76,14 @@ static void blk_mq_tag_wakeup_all(struct blk_mq_tags *tags)
 	int i, wake_index;
 
 	bt = &tags->bitmap_tags;
-	wake_index = bt->wake_index;
+	wake_index = atomic_read(&bt->wake_index);
 	for (i = 0; i < BT_WAIT_QUEUES; i++) {
 		struct bt_wait_state *bs = &bt->bs[wake_index];
 
 		if (waitqueue_active(&bs->wait))
-			wake_up(&bs->wait);
+			wake_up_all(&bs->wait);
 
-		bt_index_inc(&wake_index);
+		wake_index = bt_index_inc(wake_index);
 	}
 }
 
@@ -212,12 +219,14 @@ static struct bt_wait_state *bt_wait_ptr(struct blk_mq_bitmap_tags *bt,
 					 struct blk_mq_hw_ctx *hctx)
 {
 	struct bt_wait_state *bs;
+	int wait_index;
 
 	if (!hctx)
 		return &bt->bs[0];
 
-	bs = &bt->bs[hctx->wait_index];
-	bt_index_inc(&hctx->wait_index);
+	wait_index = atomic_read(&hctx->wait_index);
+	bs = &bt->bs[wait_index];
+	bt_index_atomic_inc(&hctx->wait_index);
 	return bs;
 }
 
@@ -239,18 +248,13 @@ static int bt_get(struct blk_mq_alloc_data *data,
 
 	bs = bt_wait_ptr(bt, hctx);
 	do {
-		bool was_empty;
-
-		was_empty = list_empty(&wait.task_list);
-		prepare_to_wait(&bs->wait, &wait, TASK_UNINTERRUPTIBLE);
+		prepare_to_wait_exclusive(&bs->wait, &wait,
+						TASK_UNINTERRUPTIBLE);
 
 		tag = __bt_get(hctx, bt, last_tag);
 		if (tag != -1)
 			break;
 
-		if (was_empty)
-			atomic_set(&bs->wait_cnt, bt->wake_cnt);
-
 		blk_mq_put_ctx(data->ctx);
 
 		io_schedule();
@@ -313,18 +317,19 @@ static struct bt_wait_state *bt_wake_ptr(struct blk_mq_bitmap_tags *bt)
 {
 	int i, wake_index;
 
-	wake_index = bt->wake_index;
+	wake_index = atomic_read(&bt->wake_index);
 	for (i = 0; i < BT_WAIT_QUEUES; i++) {
 		struct bt_wait_state *bs = &bt->bs[wake_index];
 
 		if (waitqueue_active(&bs->wait)) {
-			if (wake_index != bt->wake_index)
-				bt->wake_index = wake_index;
+			int o = atomic_read(&bt->wake_index);
+			if (wake_index != o)
+				atomic_cmpxchg(&bt->wake_index, o, wake_index);
 
 			return bs;
 		}
 
-		bt_index_inc(&wake_index);
+		wake_index = bt_index_inc(wake_index);
 	}
 
 	return NULL;
@@ -334,6 +339,7 @@ static void bt_clear_tag(struct blk_mq_bitmap_tags *bt, unsigned int tag)
 {
 	const int index = TAG_TO_INDEX(bt, tag);
 	struct bt_wait_state *bs;
+	int wait_cnt;
 
 	/*
 	 * The unlock memory barrier need to order access to req in free
@@ -342,10 +348,19 @@ static void bt_clear_tag(struct blk_mq_bitmap_tags *bt, unsigned int tag)
 	clear_bit_unlock(TAG_TO_BIT(bt, tag), &bt->map[index].word);
 
 	bs = bt_wake_ptr(bt);
-	if (bs && atomic_dec_and_test(&bs->wait_cnt)) {
-		atomic_set(&bs->wait_cnt, bt->wake_cnt);
-		bt_index_inc(&bt->wake_index);
-		wake_up(&bs->wait);
+	if (!bs)
+		return;
+
+	wait_cnt = atomic_dec_return(&bs->wait_cnt);
+	if (wait_cnt == 0) {
+wake:
+		atomic_add(bt->wake_cnt, &bs->wait_cnt);
+		bt_index_atomic_inc(&bt->wake_index);
+		wake_up_nr(&bs->wait, bt->wake_cnt);
+	} else if (wait_cnt < 0) {
+		wait_cnt = atomic_inc_return(&bs->wait_cnt);
+		if (!wait_cnt)
+			goto wake;
 	}
 }
 
@@ -499,10 +514,13 @@ static int bt_alloc(struct blk_mq_bitmap_tags *bt, unsigned int depth,
 		return -ENOMEM;
 	}
 
-	for (i = 0; i < BT_WAIT_QUEUES; i++)
+	bt_update_count(bt, depth);
+
+	for (i = 0; i < BT_WAIT_QUEUES; i++) {
 		init_waitqueue_head(&bt->bs[i].wait);
+		atomic_set(&bt->bs[i].wait_cnt, bt->wake_cnt);
+	}
 
-	bt_update_count(bt, depth);
 	return 0;
 }
 
diff --git a/block/blk-mq-tag.h b/block/blk-mq-tag.h
index 98696a65d4d4..6206ed17ef76 100644
--- a/block/blk-mq-tag.h
+++ b/block/blk-mq-tag.h
@@ -24,7 +24,7 @@ struct blk_mq_bitmap_tags {
 	unsigned int map_nr;
 	struct blk_align_bitmap *map;
 
-	unsigned int wake_index;
+	atomic_t wake_index;
 	struct bt_wait_state *bs;
 };
 
diff --git a/include/linux/blk-mq.h b/include/linux/blk-mq.h
index a002cf191427..eb726b9c5762 100644
--- a/include/linux/blk-mq.h
+++ b/include/linux/blk-mq.h
@@ -42,7 +42,7 @@ struct blk_mq_hw_ctx {
 	unsigned int		nr_ctx;
 	struct blk_mq_ctx	**ctxs;
 
-	unsigned int		wait_index;
+	atomic_t		wait_index;
 
 	struct blk_mq_tags	*tags;
 

--------------000702050707010803000904--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
