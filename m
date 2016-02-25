Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f173.google.com (mail-pf0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 5885C6B0005
	for <linux-mm@kvack.org>; Thu, 25 Feb 2016 14:38:51 -0500 (EST)
Received: by mail-pf0-f173.google.com with SMTP id e127so37911990pfe.3
        for <linux-mm@kvack.org>; Thu, 25 Feb 2016 11:38:51 -0800 (PST)
Received: from mail-pf0-x236.google.com (mail-pf0-x236.google.com. [2607:f8b0:400e:c00::236])
        by mx.google.com with ESMTPS id lu9si14219269pab.215.2016.02.25.11.38.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Feb 2016 11:38:50 -0800 (PST)
Received: by mail-pf0-x236.google.com with SMTP id e127so37911787pfe.3
        for <linux-mm@kvack.org>; Thu, 25 Feb 2016 11:38:50 -0800 (PST)
Subject: Re: [PATCH] writeback: call writeback tracepoints withoud holding
 list_lock in wb_writeback()
References: <1456354043-31420-1-git-send-email-yang.shi@linaro.org>
 <20160224214042.71c3493b@grimm.local.home>
From: "Shi, Yang" <yang.shi@linaro.org>
Message-ID: <56CF5848.7050806@linaro.org>
Date: Thu, 25 Feb 2016 11:38:48 -0800
MIME-Version: 1.0
In-Reply-To: <20160224214042.71c3493b@grimm.local.home>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: tj@kernel.org, jack@suse.cz, axboe@fb.com, fengguang.wu@intel.com, tglx@linutronix.de, bigeasy@linutronix.de, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-rt-users@vger.kernel.org, linaro-kernel@lists.linaro.org

On 2/24/2016 6:40 PM, Steven Rostedt wrote:
> On Wed, 24 Feb 2016 14:47:23 -0800
> Yang Shi <yang.shi@linaro.org> wrote:
>
>> commit 5634cc2aa9aebc77bc862992e7805469dcf83dac ("writeback: update writeback
>> tracepoints to report cgroup") made writeback tracepoints report cgroup
>> writeback, but it may trigger the below bug on -rt kernel due to the list_lock
>> held for the for loop in wb_writeback().
>
> list_lock is a sleeping mutex, it's not disabling preemption. Moving it
> doesn't make a difference.
>
>>
>> BUG: sleeping function called from invalid context at kernel/locking/rtmutex.c:930
>> in_atomic(): 1, irqs_disabled(): 0, pid: 625, name: kworker/u16:3
>
> Something else disabled preemption. And note, nothing in the tracepoint
> should have called a sleeping function.

Yes, it makes me confused too. It sounds like the preempt_ip address is 
not that accurate.

>
>
>> INFO: lockdep is turned off.
>> Preemption disabled at:[<ffffffc000374a5c>] wb_writeback+0xec/0x830
>>
>> CPU: 7 PID: 625 Comm: kworker/u16:3 Not tainted 4.4.1-rt5 #20
>> Hardware name: Freescale Layerscape 2085a RDB Board (DT)
>> Workqueue: writeback wb_workfn (flush-7:0)
>> Call trace:
>> [<ffffffc00008d708>] dump_backtrace+0x0/0x200
>> [<ffffffc00008d92c>] show_stack+0x24/0x30
>> [<ffffffc0007b0f40>] dump_stack+0x88/0xa8
>> [<ffffffc000127d74>] ___might_sleep+0x2ec/0x300
>> [<ffffffc000d5d550>] rt_spin_lock+0x38/0xb8
>> [<ffffffc0003e0548>] kernfs_path_len+0x30/0x90
>> [<ffffffc00036b360>] trace_event_raw_event_writeback_work_class+0xe8/0x2e8
>
> How accurate is this trace back? Here's the code that is executed in
> this tracepoint:
>
> 	TP_fast_assign(
> 		struct device *dev = bdi->dev;
> 		if (!dev)
> 			dev = default_backing_dev_info.dev;
> 		strncpy(__entry->name, dev_name(dev), 32);
> 		__entry->nr_pages = work->nr_pages;
> 		__entry->sb_dev = work->sb ? work->sb->s_dev : 0;
> 		__entry->sync_mode = work->sync_mode;
> 		__entry->for_kupdate = work->for_kupdate;
> 		__entry->range_cyclic = work->range_cyclic;
> 		__entry->for_background	= work->for_background;
> 		__entry->reason = work->reason;
> 	),
>
> See anything that would sleep?

According to the stack backtrace, kernfs_path_len calls slepping lock, 
which is called by __trace_wb_cgroup_size(wb) in __dynamic_array(char, 
cgroup, __trace_wb_cgroup_size(wb)).

The below is the definition:

DECLARE_EVENT_CLASS(writeback_work_class,
         TP_PROTO(struct bdi_writeback *wb, struct wb_writeback_work *work),
         TP_ARGS(wb, work),
         TP_STRUCT__entry(
                 __array(char, name, 32)
                 __field(long, nr_pages)
                 __field(dev_t, sb_dev)
                 __field(int, sync_mode)
                 __field(int, for_kupdate)
                 __field(int, range_cyclic)
                 __field(int, for_background)
                 __field(int, reason)
                 __dynamic_array(char, cgroup, __trace_wb_cgroup_size(wb))

Thanks,
Yang

>
>> [<ffffffc000374f90>] wb_writeback+0x620/0x830
>> [<ffffffc000376224>] wb_workfn+0x61c/0x950
>> [<ffffffc000110adc>] process_one_work+0x3ac/0xb30
>> [<ffffffc0001112fc>] worker_thread+0x9c/0x7a8
>> [<ffffffc00011a9e8>] kthread+0x190/0x1b0
>> [<ffffffc000086ca0>] ret_from_fork+0x10/0x30
>>
>> The list_lock was moved outside the for loop by commit
>> e8dfc30582995ae12454cda517b17d6294175b07 ("writeback: elevate queue_io()
>> into wb_writeback())", however, the commit log says "No behavior change", so
>> it sounds safe to have the list_lock acquired inside the for loop as it did
>> before.
>>
>> Just acquire list_lock at the necessary points and keep all writeback
>> tracepoints outside the critical area protected by list_lock in
>> wb_writeback().
>
> But list_lock itself is a sleeping lock. This doesn't make sense.
>
> This is not the bug you are looking for.
>
> -- Steve
>
>>
>> Signed-off-by: Yang Shi <yang.shi@linaro.org>
>> ---
>>   fs/fs-writeback.c | 12 +++++++-----
>>   1 file changed, 7 insertions(+), 5 deletions(-)
>>
>> diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
>> index 1f76d89..9b7b5f6 100644
>> --- a/fs/fs-writeback.c
>> +++ b/fs/fs-writeback.c
>> @@ -1623,7 +1623,6 @@ static long wb_writeback(struct bdi_writeback *wb,
>>   	work->older_than_this = &oldest_jif;
>>
>>   	blk_start_plug(&plug);
>> -	spin_lock(&wb->list_lock);
>>   	for (;;) {
>>   		/*
>>   		 * Stop writeback when nr_pages has been consumed
>> @@ -1661,15 +1660,19 @@ static long wb_writeback(struct bdi_writeback *wb,
>>   			oldest_jif = jiffies;
>>
>>   		trace_writeback_start(wb, work);
>> +
>> +		spin_lock(&wb->list_lock);
>>   		if (list_empty(&wb->b_io))
>>   			queue_io(wb, work);
>>   		if (work->sb)
>>   			progress = writeback_sb_inodes(work->sb, wb, work);
>>   		else
>>   			progress = __writeback_inodes_wb(wb, work);
>> -		trace_writeback_written(wb, work);
>>
>>   		wb_update_bandwidth(wb, wb_start);
>> +		spin_unlock(&wb->list_lock);
>> +
>> +		trace_writeback_written(wb, work);
>>
>>   		/*
>>   		 * Did we write something? Try for more
>> @@ -1693,15 +1696,14 @@ static long wb_writeback(struct bdi_writeback *wb,
>>   		 */
>>   		if (!list_empty(&wb->b_more_io))  {
>>   			trace_writeback_wait(wb, work);
>> +			spin_lock(&wb->list_lock);
>>   			inode = wb_inode(wb->b_more_io.prev);
>> -			spin_lock(&inode->i_lock);
>>   			spin_unlock(&wb->list_lock);
>> +			spin_lock(&inode->i_lock);
>>   			/* This function drops i_lock... */
>>   			inode_sleep_on_writeback(inode);
>> -			spin_lock(&wb->list_lock);
>>   		}
>>   	}
>> -	spin_unlock(&wb->list_lock);
>>   	blk_finish_plug(&plug);
>>
>>   	return nr_pages - work->nr_pages;
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
