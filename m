Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id AA8A76B0032
	for <linux-mm@kvack.org>; Tue,  2 Jul 2013 04:34:02 -0400 (EDT)
Message-ID: <51D2906A.3030909@parallels.com>
Date: Tue, 2 Jul 2013 12:33:46 +0400
From: Maxim Patlasov <mpatlasov@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 16/16] mm: strictlimit feature
References: <20130629172211.20175.70154.stgit@maximpc.sw.ru> <20130629174706.20175.78184.stgit@maximpc.sw.ru> <20130701141612.04d867863319bcc23d007a23@linux-foundation.org>
In-Reply-To: <20130701141612.04d867863319bcc23d007a23@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: miklos@szeredi.hu, riel@redhat.com, dev@parallels.com, xemul@parallels.com, fuse-devel@lists.sourceforge.net, bfoster@redhat.com, linux-kernel@vger.kernel.org, jbottomley@parallels.com, linux-mm@kvack.org, viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org, fengguang.wu@intel.com, devel@openvz.org, mgorman@suse.de

Hi Andrew,

07/02/2013 01:16 AM, Andrew Morton D?D,N?DuN?:
> On Sat, 29 Jun 2013 21:48:54 +0400 Maxim Patlasov <MPatlasov@parallels.com> wrote:
>
>> From: Miklos Szeredi <mszeredi@suse.cz>
>>
>> The feature prevents mistrusted filesystems to grow a large number of dirty
>> pages before throttling. For such filesystems balance_dirty_pages always
>> check bdi counters against bdi limits. I.e. even if global "nr_dirty" is under
>> "freerun", it's not allowed to skip bdi checks. The only use case for now is
>> fuse: it sets bdi max_ratio to 1% by default and system administrators are
>> supposed to expect that this limit won't be exceeded.
>>
>> The feature is on if address space is marked by AS_STRICTLIMIT flag.
>> A filesystem may set the flag when it initializes a new inode.
>>
> Fengguang, could you please review this patch?
>
> I suggest you await the next version, which hopefully will be more
> reviewable...

Thanks a lot for quick review, I'll update the patch according to your 
comments soon.

I'm answering the question about BDI_idle below inline, but I'll add 
some comment about it where BDI_idle is actually used as well.

Thanks,
Maxim

>
>> ...
>>
>> --- a/include/linux/backing-dev.h
>> +++ b/include/linux/backing-dev.h
>> @@ -33,6 +33,8 @@ enum bdi_state {
>>   	BDI_sync_congested,	/* The sync queue is getting full */
>>   	BDI_registered,		/* bdi_register() was done */
>>   	BDI_writeback_running,	/* Writeback is in progress */
>> +	BDI_idle,		/* No pages under writeback at the moment of
>> +				 * last update of write bw */
> Why does BDI_idle exist?

BDI_idle along with BDI_WRITTEN_BACK exists to distinguish two cases:

1st. BDI_WRITTEN has not been incremented since we looked at it last 
time because backing dev is unresponding. I.e. it had some pages under 
writeback but it have not made any progress for some reasons.

2nd. BDI_WRITTEN has not been incremented since we looked at it last 
time because backing dev had nothing to do. I.e. there are some dirty 
pages on bdi, but they have not been passed to backing dev yet. This is 
the case when bdi_dirty is under bdi background threshold and flusher 
refrains from flushing even if we woke it up explicitly by 
bdi_start_background_writeback.

We have to skip bdi_update_write_bandwidth() in the 2nd case because 
otherwise bdi_update_write_bandwidth() will see written==0 and 
mistakenly decrease write_bandwidth. The criterion to skip is the 
following: BDI_idle is set (i.e. there were no pages under writeback 
when we looked at the bdi last time) && BDI_WRITTEN_BACK counter has not 
changed (i.e. no new pages has been sent to writeback since we looked at 
the bdi last time).

Thanks,
Maxim

>
>>   	BDI_unused,		/* Available bits start here */
>>   };
>>   
>> @@ -43,6 +45,7 @@ enum bdi_stat_item {
>>   	BDI_WRITEBACK,
>>   	BDI_DIRTIED,
>>   	BDI_WRITTEN,
>> +	BDI_WRITTEN_BACK,
>>   	NR_BDI_STAT_ITEMS
>>   };
>>   
>> @@ -76,6 +79,8 @@ struct backing_dev_info {
>>   	unsigned long bw_time_stamp;	/* last time write bw is updated */
>>   	unsigned long dirtied_stamp;
>>   	unsigned long written_stamp;	/* pages written at bw_time_stamp */
>> +	unsigned long writeback_stamp;	/* pages sent to writeback at
>> +					 * bw_time_stamp */
> Well this sucks.  Some of the "foo_stamp" fields are in units of time
> (jiffies?  We aren't told) and some of the "foo_stamp" fields are in
> units of number-of-pages.  It would be good to fix the naming here.
>
>>   	unsigned long write_bandwidth;	/* the estimated write bandwidth */
>>   	unsigned long avg_write_bandwidth; /* further smoothed write bw */
>>   
>> diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
>> index e3dea75..baac702 100644
>> --- a/include/linux/pagemap.h
>> +++ b/include/linux/pagemap.h
>> @@ -25,6 +25,7 @@ enum mapping_flags {
>>   	AS_MM_ALL_LOCKS	= __GFP_BITS_SHIFT + 2,	/* under mm_take_all_locks() */
>>   	AS_UNEVICTABLE	= __GFP_BITS_SHIFT + 3,	/* e.g., ramdisk, SHM_LOCK */
>>   	AS_BALLOON_MAP  = __GFP_BITS_SHIFT + 4, /* balloon page special map */
>> +	AS_STRICTLIMIT	= __GFP_BITS_SHIFT + 5, /* strict dirty limit */
> Thing is, "strict dirty limit" isn't documented anywhere, so this
> reference is left dangling.
>
>> ...
>>
>> --- a/mm/backing-dev.c
>> +++ b/mm/backing-dev.c
>> @@ -94,6 +94,7 @@ static int bdi_debug_stats_show(struct seq_file *m, void *v)
>>   		   "BackgroundThresh:   %10lu kB\n"
>>   		   "BdiDirtied:         %10lu kB\n"
>>   		   "BdiWritten:         %10lu kB\n"
>> +		   "BdiWrittenBack:     %10lu kB\n"
>>   		   "BdiWriteBandwidth:  %10lu kBps\n"
>>   		   "b_dirty:            %10lu\n"
>>   		   "b_io:               %10lu\n"
> I can't imagine what the difference is between BdiWritten and
> BdiWrittenBack.
>
> I suggest you document this at the BDI_WRITTEN_BACK definition site in
> enum bdi_stat_item.  BDI_WRITTEN (at least) will also need
> documentation so people can understand the difference.
>
>> ...
>>
>> @@ -679,29 +711,31 @@ static unsigned long bdi_position_ratio(struct backing_dev_info *bdi,
>>   	if (unlikely(dirty >= limit))
>>   		return 0;
>>   
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
> This would be a suitable site at which to document the strictlimit
> feature.  What it is, how it works and most importantly, why it exists.
>
>> ...
>>
>> @@ -994,6 +1029,16 @@ static void bdi_update_dirty_ratelimit(struct backing_dev_info *bdi,
>>   	 * keep that period small to reduce time lags).
>>   	 */
>>   	step = 0;
>> +
>> +	if (unlikely(strictlimit)) {
>> +		dirty = bdi_dirty;
>> +		if (bdi_dirty < 8)
>> +			setpoint = bdi_dirty + 1;
>> +		else
>> +			setpoint = (bdi_thresh +
>> +				    bdi_dirty_limit(bdi, bg_thresh)) / 2;
>> +	}
> Explain this to the reader, please.
>
>> ...
>>
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
