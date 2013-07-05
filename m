Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id DE9046B0033
	for <linux-mm@kvack.org>; Fri,  5 Jul 2013 09:15:50 -0400 (EDT)
Message-ID: <51D6C6C9.7070001@parallels.com>
Date: Fri, 5 Jul 2013 17:14:49 +0400
From: Maxim Patlasov <mpatlasov@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: strictlimit feature -v2
References: <20130629174706.20175.78184.stgit@maximpc.sw.ru> <20130702174316.15075.84993.stgit@maximpc.sw.ru> <20130702123804.9f252487f86c12b0f4edee57@linux-foundation.org> <51D4047F.2010700@parallels.com> <20130703231625.GB30822@quack.suse.cz>
In-Reply-To: <20130703231625.GB30822@quack.suse.cz>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, miklos@szeredi.hu, riel@redhat.com, dev@parallels.com, xemul@parallels.com, fuse-devel@lists.sourceforge.net, bfoster@redhat.com, linux-kernel@vger.kernel.org, jbottomley@parallels.com, linux-mm@kvack.org, viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org, fengguang.wu@intel.com, devel@openvz.org, mgorman@suse.de

Hi Jan,

First of all, thanks a lot for review, I highly appreciate it. I agree 
with most of your comments, see please inline replies below.

To make further reviews easier, I'm going to send the next version in 
the form of small mm-only patchset (i.e. putting all that "fuse 
writeback cache policy" stuff aside).

07/04/2013 03:16 AM, Jan Kara D?D,N?DuN?:
> On Wed 03-07-13 15:01:19, Maxim Patlasov wrote:
>> 07/02/2013 11:38 PM, Andrew Morton D?D,N?DuN?:
>>> On Tue, 02 Jul 2013 21:44:47 +0400 Maxim Patlasov <MPatlasov@parallels.com> wrote:
>>>
>>>> From: Miklos Szeredi <mszeredi@suse.cz>
>>>>
>>>> The feature prevents mistrusted filesystems to grow a large number of dirty
>>>> pages before throttling. For such filesystems balance_dirty_pages always
>>>> check bdi counters against bdi limits. I.e. even if global "nr_dirty" is under
>>>> "freerun", it's not allowed to skip bdi checks. The only use case for now is
>>>> fuse: it sets bdi max_ratio to 1% by default and system administrators are
>>>> supposed to expect that this limit won't be exceeded.
>>>>
>>>> The feature is on if address space is marked by AS_STRICTLIMIT flag.
>>>> A filesystem may set the flag when it initializes a new inode.
>>>>
>>>> Changed in v2 (thanks to Andrew Morton):
>>>>   - added a few explanatory comments
>>>>   - cleaned up the mess in backing_dev_info foo_stamp fields: now it's clearly
>>>>     stated that bw_time_stamp is measured in jiffies; renamed other foo_stamp
>>>>     fields to reflect that they are in units of number-of-pages.
>>>>
>>> Better, thanks.
>>>
>>> The writeback arithemtic makes my head spin - I'd really like Fengguang
>>> to go over this, please.
>>>
>>> A quick visit from the spelling police:
>> Great! Thank you, Andrew. I'll wait for Fengguang' feedback for a
>> while before respin.
>    Sorry for the bad mail threading but I've noticed the thread only now and
> I don't have email with your patches in my mailbox anymore. Below is a
> review of your strictlimit patch. In principle, I'm OK with the idea (I
> even wanted to have a similar ability e.g. for NFS mounts) but I have some
> reservations regarding the implementation:
>
>> diff --git a/fs/fuse/inode.c b/fs/fuse/inode.c
>> index 4beb8e3..00a28af 100644
>> --- a/fs/fuse/inode.c
>> +++ b/fs/fuse/inode.c
>> @@ -305,6 +305,7 @@ struct inode *fuse_iget(struct super_block *sb, u64 nodeid,
>>   			inode->i_flags |= S_NOCMTIME;
>>   		inode->i_generation = generation;
>>   		inode->i_data.backing_dev_info = &fc->bdi;
>> +		set_bit(AS_STRICTLIMIT, &inode->i_data.flags);
>>   		fuse_init_inode(inode, attr);
>>   		unlock_new_inode(inode);
>>   	} else if ((inode->i_mode ^ attr->mode) & S_IFMT) {
>    It seems wrong to use address space bits for this. Using BDI capabilities for
> this would look more appropriate. Sure you couldn't then always tune this on
> per-fs basis since filesystems can share BDI (e.g. when they are on different
> partitions of one disk) but if several filesystems are sharing a BDI and some
> would want 'strict' behavior and some don't I don't believe the resulting
> behavior would be sane - e.g. non-strict fs could be getting bdi over per-bdi
> limit without any throttling and strictly limited fs would be continuously
> stalled. Or do I miss any reason why this is set on address space?
>
> As a bonus you don't have to pass the 'strictlimit' flag to writeback
> functions when it is a bdi flag.

Completely agree. Address space flag was Miklos' idea. I had to convert 
it to bdi cap from the beginning.

>
>> diff --git a/include/linux/backing-dev.h b/include/linux/backing-dev.h
>> index c388155..6b12d01 100644
>> --- a/include/linux/backing-dev.h
>> +++ b/include/linux/backing-dev.h
>> @@ -33,6 +33,8 @@ enum bdi_state {
>>   	BDI_sync_congested,	/* The sync queue is getting full */
>>   	BDI_registered,		/* bdi_register() was done */
>>   	BDI_writeback_running,	/* Writeback is in progress */
>> +	BDI_idle,		/* No pages under writeback at the moment of
>> +				 * last update of write bw */
>>   	BDI_unused,		/* Available bits start here */
>>   };
>>   
>> @@ -41,8 +43,15 @@ typedef int (congested_fn)(void *, int);
>>   enum bdi_stat_item {
>>   	BDI_RECLAIMABLE,
>>   	BDI_WRITEBACK,
>> -	BDI_DIRTIED,
>> -	BDI_WRITTEN,
>> +
>> +	/*
>> +	 * The three counters below reflects number of events of specific type
>> +	 * happened since bdi_init(). The type is defined in comments below:
>> +	 */
>> +	BDI_DIRTIED,	  /* a page was dirtied */
>> +	BDI_WRITTEN,	  /* writeout completed for a page */
>> +	BDI_WRITTEN_BACK, /* a page went to writeback */
>> +
>>   	NR_BDI_STAT_ITEMS
>>   };
>>   
>> @@ -73,9 +82,12 @@ struct backing_dev_info {
>>   
>>   	struct percpu_counter bdi_stat[NR_BDI_STAT_ITEMS];
>>   
>> -	unsigned long bw_time_stamp;	/* last time write bw is updated */
>> -	unsigned long dirtied_stamp;
>> -	unsigned long written_stamp;	/* pages written at bw_time_stamp */
>> +	unsigned long bw_time_stamp;	/* last time (in jiffies) write bw
>> +					 * is updated */
>> +	unsigned long dirtied_nr_stamp;
>> +	unsigned long written_nr_stamp;	/* pages written at bw_time_stamp */
>> +	unsigned long writeback_nr_stamp; /* pages sent to writeback at
>> +					   * bw_time_stamp */
>>   	unsigned long write_bandwidth;	/* the estimated write bandwidth */
>>   	unsigned long avg_write_bandwidth; /* further smoothed write bw */
>>   
>> diff --git a/mm/page-writeback.c b/mm/page-writeback.c
>> index 4514ad7..83c7434 100644
>> --- a/mm/page-writeback.c
>> +++ b/mm/page-writeback.c
>> @@ -680,28 +712,55 @@ static unsigned long bdi_position_ratio(struct backing_dev_info *bdi,
>>   		return 0;
>>   
>>   	/*
>> -	 * global setpoint
>> +	 * The strictlimit feature is a tool preventing mistrusted filesystems
>> +	 * to grow a large number of dirty pages before throttling. For such
>> +	 * filesystems balance_dirty_pages always checks bdi counters against
>> +	 * bdi limits. Even if global "nr_dirty" is under "freerun". This is
>> +	 * especially important for fuse who sets bdi->max_ratio to 1% by
>> +	 * default. Without strictlimit feature, fuse writeback may consume
>> +	 * arbitrary amount of RAM because it is accounted in
>> +	 * NR_WRITEBACK_TEMP which is not involved in calculating "nr_dirty".
>>   	 *
>> -	 *                           setpoint - dirty 3
>> -	 *        f(dirty) := 1.0 + (----------------)
>> -	 *                           limit - setpoint
>> +	 * Here, in bdi_position_ratio(), we calculate pos_ratio based on
>> +	 * two values: bdi_dirty and bdi_thresh. Let's consider an example:
>> +	 * total amount of RAM is 16GB, bdi->max_ratio is equal to 1%, global
>> +	 * limits are set by default to 10% and 20% (background and throttle).
>> +	 * Then bdi_thresh is 1% of 20% of 16GB. This amounts to ~8K pages.
>> +	 * bdi_dirty_limit(bdi, bg_thresh) is about ~4K pages. bdi_setpoint is
>> +	 * about ~6K pages (as the average of background and throttle bdi
>> +	 * limits). The 3rd order polynomial will provide positive feedback if
>> +	 * bdi_dirty is under bdi_setpoint and vice versa.
>>   	 *
>> -	 * it's a 3rd order polynomial that subjects to
>> +	 * Note, that we cannot use global counters in these calculations
>> +	 * because we want to throttle process writing to strictlimit address
>> +	 * space much earlier than global "freerun" is reached (~23MB vs.
>> +	 * ~2.3GB in the example above).
>> +	 */
>> +	if (unlikely(strictlimit)) {
>> +		if (bdi_dirty < 8)
>> +			return 2 << RATELIMIT_CALC_SHIFT;
>> +
>> +		if (bdi_dirty >= bdi_thresh)
>> +			return 0;
>> +
>> +		bdi_setpoint = bdi_thresh + bdi_dirty_limit(bdi, bg_thresh);
>> +		bdi_setpoint /= 2;
>> +
>> +		if (bdi_setpoint == 0 || bdi_setpoint == bdi_thresh)
>> +			return 0;
>> +
>> +		pos_ratio = pos_ratio_polynom(bdi_setpoint, bdi_dirty,
>> +					      bdi_thresh);
>> +		return min_t(long long, pos_ratio, 2 << RATELIMIT_CALC_SHIFT);
>> +	}
>    But if global limits are exceeded but a BDI in strict mode is below limit,
> this would allow dirtying on that BDI which seems wrong. Also the logic
> in bdi_position_ratio() is already supposed to take bdi limits in account
> (although the math is somewhat convoluted) so you shouldn't have to touch it.
> Only maybe the increasing of bdi_thresh to (limit - dirty) / 8 might be too
> much for strict limitting so that may need some tweaking (although setting it
> at 8 pages as your patch does seems *too* strict to me).

I agree that if global nr_dirty comes close to global limit (or already 
exceeded it), we must take global pos_ratio in consideration (even if 
bdi_dirty << bdi_thresh). But I don't think we can keep 
bdi_position_ratio() intact. Because: 1) the math there goes crazy if 
dirty < freerun; 2) "(limit - dirty) / 8" is useless for FUSE which 
account internal writeback in NR_WRITEBACK_TEMP; i.e. you can easily 
observe "dirty" close to zero while bdi_dirty is huge. Please let me 
know if you need more details about NR_WRITEBACK_TEMP peculiarities.

>
>> +
>> +	/*
>> +	 * global setpoint
>>   	 *
>> -	 * (1) f(freerun)  = 2.0 => rampup dirty_ratelimit reasonably fast
>> -	 * (2) f(setpoint) = 1.0 => the balance point
>> -	 * (3) f(limit)    = 0   => the hard limit
>> -	 * (4) df/dx      <= 0	 => negative feedback control
>> -	 * (5) the closer to setpoint, the smaller |df/dx| (and the reverse)
>> -	 *     => fast response on large errors; small oscillation near setpoint
>> +	 * See comment for pos_ratio_polynom().
>>   	 */
>>   	setpoint = (freerun + limit) / 2;
>> -	x = div_s64(((s64)setpoint - (s64)dirty) << RATELIMIT_CALC_SHIFT,
>> -		    limit - setpoint + 1);
>> -	pos_ratio = x;
>> -	pos_ratio = pos_ratio * x >> RATELIMIT_CALC_SHIFT;
>> -	pos_ratio = pos_ratio * x >> RATELIMIT_CALC_SHIFT;
>> -	pos_ratio += 1 << RATELIMIT_CALC_SHIFT;
>> +	pos_ratio = pos_ratio_polynom(setpoint, dirty, limit);
>>   
>>   	/*
>>   	 * We have computed basic pos_ratio above based on global situation. If
>> @@ -892,7 +951,8 @@ static void bdi_update_dirty_ratelimit(struct backing_dev_info *bdi,
>>   				       unsigned long bdi_thresh,
>>   				       unsigned long bdi_dirty,
>>   				       unsigned long dirtied,
>> -				       unsigned long elapsed)
>> +				       unsigned long elapsed,
>> +				       bool strictlimit)
>>   {
>>   	unsigned long freerun = dirty_freerun_ceiling(thresh, bg_thresh);
>>   	unsigned long limit = hard_dirty_limit(thresh);
>> @@ -910,10 +970,10 @@ static void bdi_update_dirty_ratelimit(struct backing_dev_info *bdi,
>>   	 * The dirty rate will match the writeout rate in long term, except
>>   	 * when dirty pages are truncated by userspace or re-dirtied by FS.
>>   	 */
>> -	dirty_rate = (dirtied - bdi->dirtied_stamp) * HZ / elapsed;
>> +	dirty_rate = (dirtied - bdi->dirtied_nr_stamp) * HZ / elapsed;
>>   
>>   	pos_ratio = bdi_position_ratio(bdi, thresh, bg_thresh, dirty,
>> -				       bdi_thresh, bdi_dirty);
>> +				       bdi_thresh, bdi_dirty, strictlimit);
>>   	/*
>>   	 * task_ratelimit reflects each dd's dirty rate for the past 200ms.
>>   	 */
>> @@ -994,6 +1054,26 @@ static void bdi_update_dirty_ratelimit(struct backing_dev_info *bdi,
>>   	 * keep that period small to reduce time lags).
>>   	 */
>>   	step = 0;
>> +
>> +	/*
>> +	 * For strictlimit case, balanced_dirty_ratelimit was calculated
>> +	 * above based on bdi counters and limits (see bdi_position_ratio()).
>> +	 * Hence, to calculate "step" properly, we have to use bdi_dirty as
>> +	 * "dirty" and bdi_setpoint as "setpoint".
>> +	 *
>> +	 * We rampup dirty_ratelimit forcibly if bdi_dirty is low because
>> +	 * it's possible that bdi_thresh is close to zero due to inactivity
>> +	 * of backing device (see the implementation of bdi_dirty_limit()).
>> +	 */
>> +	if (unlikely(strictlimit)) {
>> +		dirty = bdi_dirty;
>> +		if (bdi_dirty < 8)
>> +			setpoint = bdi_dirty + 1;
>> +		else
>> +			setpoint = (bdi_thresh +
>> +				    bdi_dirty_limit(bdi, bg_thresh)) / 2;
>> +	}
>> +
>>   	if (dirty < setpoint) {
>>   		x = min(bdi->balanced_dirty_ratelimit,
>>   			 min(balanced_dirty_ratelimit, task_ratelimit));
>> @@ -1034,12 +1114,14 @@ void __bdi_update_bandwidth(struct backing_dev_info *bdi,
>>   			    unsigned long dirty,
>>   			    unsigned long bdi_thresh,
>>   			    unsigned long bdi_dirty,
>> -			    unsigned long start_time)
>> +			    unsigned long start_time,
>> +			    bool strictlimit)
>>   {
>>   	unsigned long now = jiffies;
>>   	unsigned long elapsed = now - bdi->bw_time_stamp;
>>   	unsigned long dirtied;
>>   	unsigned long written;
>> +	unsigned long writeback;
>>   
>>   	/*
>>   	 * rate-limit, only update once every 200ms.
>> @@ -1049,6 +1131,7 @@ void __bdi_update_bandwidth(struct backing_dev_info *bdi,
>>   
>>   	dirtied = percpu_counter_read(&bdi->bdi_stat[BDI_DIRTIED]);
>>   	written = percpu_counter_read(&bdi->bdi_stat[BDI_WRITTEN]);
>> +	writeback = bdi_stat_sum(bdi, BDI_WRITTEN_BACK);
>>   
>>   	/*
>>   	 * Skip quiet periods when disk bandwidth is under-utilized.
>> @@ -1057,18 +1140,32 @@ void __bdi_update_bandwidth(struct backing_dev_info *bdi,
>>   	if (elapsed > HZ && time_before(bdi->bw_time_stamp, start_time))
>>   		goto snapshot;
>>   
>> +	/*
>> +	 * Skip periods when backing dev was idle due to abscence of pages
>> +	 * under writeback (when over_bground_thresh() returns false)
>> +	 */
>> +	if (test_bit(BDI_idle, &bdi->state) &&
>> +	    bdi->writeback_nr_stamp == writeback)
>> +		goto snapshot;
>> +
>    Hum, I understand the desire behind BDI_idle but that seems to be solving
> only a special case, isn't it? When there is a small traffic on the bdi, the
> bandwidth will get updated anyway and the computed bandwidth will go down
> from the real maximum value when there are enouch pages to write. So I'm not
> sure how much this really helps. Plus this 'idle' logic seems completely
> independent to balance_dirty_pages() tweaks so it would be better done as a
> separate patch (in case you have convincing reasons we really need that
> logic).

Yes, I'll move it to separate patch. The rationale behind BDI_idle looks 
like this:

> BDI_idle along with BDI_WRITTEN_BACK exists to distinguish two cases:
>
> 1st. BDI_WRITTEN has not been incremented since we looked at it last
> time because backing dev is unresponding. I.e. it had some pages under
> writeback but it have not made any progress for some reasons.
>
> 2nd. BDI_WRITTEN has not been incremented since we looked at it last
> time because backing dev had nothing to do. I.e. there are some dirty
> pages on bdi, but they have not been passed to backing dev yet. This is
> the case when bdi_dirty is under bdi background threshold and flusher
> refrains from flushing even if we woke it up explicitly by
> bdi_start_background_writeback.
>
> We have to skip bdi_update_write_bandwidth() in the 2nd case because
> otherwise bdi_update_write_bandwidth() will see written==0 and
> mistakenly decrease write_bandwidth. The criterion to skip is the
> following: BDI_idle is set (i.e. there were no pages under writeback
> when we looked at the bdi last time) && BDI_WRITTEN_BACK counter has not
> changed (i.e. no new pages has been sent to writeback since we looked at
> the bdi last time).

Notice, that BDI_idle is useful right now only for strictlimit feature 
because w/o strictlimit, we do not call bdi_update_write_bandwidth() 
until "dirty" exceeds "freerun" and over_bground_thresh() guarantees 
that flusher has passed some amount of work to backing dev by then.

>
>>   	if (thresh) {
>>   		global_update_bandwidth(thresh, dirty, now);
>>   		bdi_update_dirty_ratelimit(bdi, thresh, bg_thresh, dirty,
>>   					   bdi_thresh, bdi_dirty,
>> -					   dirtied, elapsed);
>> +					   dirtied, elapsed, strictlimit);
>>   	}
>>   	bdi_update_write_bandwidth(bdi, elapsed, written);
>>   
>>   snapshot:
>> -	bdi->dirtied_stamp = dirtied;
>> -	bdi->written_stamp = written;
>> +	bdi->dirtied_nr_stamp = dirtied;
>> +	bdi->written_nr_stamp = written;
>>   	bdi->bw_time_stamp = now;
>> +
>> +	bdi->writeback_nr_stamp = writeback;
>> +	if (bdi_stat_sum(bdi, BDI_WRITEBACK) == 0)
>> +		set_bit(BDI_idle, &bdi->state);
>> +	else
>> +		clear_bit(BDI_idle, &bdi->state);
>>   }
>>   
>>   static void bdi_update_bandwidth(struct backing_dev_info *bdi,
>> @@ -1077,13 +1174,14 @@ static void bdi_update_bandwidth(struct backing_dev_info *bdi,
>>   				 unsigned long dirty,
>>   				 unsigned long bdi_thresh,
>>   				 unsigned long bdi_dirty,
>> -				 unsigned long start_time)
>> +				 unsigned long start_time,
>> +				 bool strictlimit)
>>   {
>>   	if (time_is_after_eq_jiffies(bdi->bw_time_stamp + BANDWIDTH_INTERVAL))
>>   		return;
>>   	spin_lock(&bdi->wb.list_lock);
>>   	__bdi_update_bandwidth(bdi, thresh, bg_thresh, dirty,
>> -			       bdi_thresh, bdi_dirty, start_time);
>> +			       bdi_thresh, bdi_dirty, start_time, strictlimit);
>>   	spin_unlock(&bdi->wb.list_lock);
>>   }
>>   
>> @@ -1226,6 +1324,7 @@ static void balance_dirty_pages(struct address_space *mapping,
>>   	unsigned long dirty_ratelimit;
>>   	unsigned long pos_ratio;
>>   	struct backing_dev_info *bdi = mapping->backing_dev_info;
>> +	bool strictlimit = test_bit(AS_STRICTLIMIT, &mapping->flags);
>>   	unsigned long start_time = jiffies;
>>   
>>   	for (;;) {
>> @@ -1250,7 +1349,7 @@ static void balance_dirty_pages(struct address_space *mapping,
>>   		 */
>>   		freerun = dirty_freerun_ceiling(dirty_thresh,
>>   						background_thresh);
>> -		if (nr_dirty <= freerun) {
>> +		if (nr_dirty <= freerun  && !strictlimit) {
>>   			current->dirty_paused_when = now;
>>   			current->nr_dirtied = 0;
>>   			current->nr_dirtied_pause =
>    I'd rather change this to check bdi_dirty <= bdi_freerun in strictlimit
> case.

An excellent idea, thank you very much! Some complication comes from the 
fact that bdi_dirty and bdi_freerun are not calculated by that time, but 
we can check bdi_dirty <= bdi_freerun a bit later -- that shouldn't make 
big difference.

>
>> @@ -1258,7 +1357,7 @@ static void balance_dirty_pages(struct address_space *mapping,
>>   			break;
>>   		}
>>   
>> -		if (unlikely(!writeback_in_progress(bdi)))
>> +		if (unlikely(!writeback_in_progress(bdi)) && !strictlimit)
>>   			bdi_start_background_writeback(bdi);
>    This can then go away.

Yes.

>
>>   		/*
>> @@ -1296,19 +1395,24 @@ static void balance_dirty_pages(struct address_space *mapping,
>>   				    bdi_stat(bdi, BDI_WRITEBACK);
>>   		}
>>   
>> +		if (unlikely(!writeback_in_progress(bdi)) &&
>> +		    bdi_dirty > bdi_thresh / 4)
>> +			bdi_start_background_writeback(bdi);
>> +
>    Why is this?

We attempted to avoid kicking flusher every time we dive into 
balance_dirty_pages(). This will surely go away.

>
>>   		dirty_exceeded = (bdi_dirty > bdi_thresh) &&
>> -				  (nr_dirty > dirty_thresh);
>> +				 ((nr_dirty > dirty_thresh) || strictlimit);
>>   		if (dirty_exceeded && !bdi->dirty_exceeded)
>>   			bdi->dirty_exceeded = 1;
>>   
>>   		bdi_update_bandwidth(bdi, dirty_thresh, background_thresh,
>>   				     nr_dirty, bdi_thresh, bdi_dirty,
>> -				     start_time);
>> +				     start_time, strictlimit);
>>   
>>   		dirty_ratelimit = bdi->dirty_ratelimit;
>>   		pos_ratio = bdi_position_ratio(bdi, dirty_thresh,
>>   					       background_thresh, nr_dirty,
>> -					       bdi_thresh, bdi_dirty);
>> +					       bdi_thresh, bdi_dirty,
>> +					       strictlimit);
>>   		task_ratelimit = ((u64)dirty_ratelimit * pos_ratio) >>
>>   							RATELIMIT_CALC_SHIFT;
>>   		max_pause = bdi_max_pause(bdi, bdi_dirty);
>> @@ -1362,6 +1466,8 @@ static void balance_dirty_pages(struct address_space *mapping,
>>   		}
>>   
>>   pause:
>> +		if (unlikely(!writeback_in_progress(bdi)))
>> +			bdi_start_background_writeback(bdi);
>>   		trace_balance_dirty_pages(bdi,
>>   					  dirty_thresh,
>>   					  background_thresh,
>    And this shouldn't be necessary either after updating the freerun test
> properly.

Yep!

Thanks,
Maxim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
