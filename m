Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f181.google.com (mail-pf0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id CB84B6B0255
	for <linux-mm@kvack.org>; Thu, 25 Feb 2016 18:16:56 -0500 (EST)
Received: by mail-pf0-f181.google.com with SMTP id x65so40702106pfb.1
        for <linux-mm@kvack.org>; Thu, 25 Feb 2016 15:16:56 -0800 (PST)
Received: from mail-pa0-x22b.google.com (mail-pa0-x22b.google.com. [2607:f8b0:400e:c03::22b])
        by mx.google.com with ESMTPS id 7si15334598pfm.127.2016.02.25.15.16.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Feb 2016 15:16:56 -0800 (PST)
Received: by mail-pa0-x22b.google.com with SMTP id fl4so39858422pad.0
        for <linux-mm@kvack.org>; Thu, 25 Feb 2016 15:16:56 -0800 (PST)
Subject: Re: [PATCH] writeback: call writeback tracepoints withoud holding
 list_lock in wb_writeback()
References: <1456354043-31420-1-git-send-email-yang.shi@linaro.org>
 <20160224214042.71c3493b@grimm.local.home> <56CF5848.7050806@linaro.org>
 <20160225145432.3749e5ec@gandalf.local.home>
From: "Shi, Yang" <yang.shi@linaro.org>
Message-ID: <56CF8B66.8070108@linaro.org>
Date: Thu, 25 Feb 2016 15:16:54 -0800
MIME-Version: 1.0
In-Reply-To: <20160225145432.3749e5ec@gandalf.local.home>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: tj@kernel.org, jack@suse.cz, axboe@fb.com, fengguang.wu@intel.com, tglx@linutronix.de, bigeasy@linutronix.de, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-rt-users@vger.kernel.org, linaro-kernel@lists.linaro.org

On 2/25/2016 11:54 AM, Steven Rostedt wrote:
> On Thu, 25 Feb 2016 11:38:48 -0800
> "Shi, Yang" <yang.shi@linaro.org> wrote:
>
>> On 2/24/2016 6:40 PM, Steven Rostedt wrote:
>>> On Wed, 24 Feb 2016 14:47:23 -0800
>>> Yang Shi <yang.shi@linaro.org> wrote:
>>>
>>>> commit 5634cc2aa9aebc77bc862992e7805469dcf83dac ("writeback: update writeback
>>>> tracepoints to report cgroup") made writeback tracepoints report cgroup
>>>> writeback, but it may trigger the below bug on -rt kernel due to the list_lock
>>>> held for the for loop in wb_writeback().
>>>
>>> list_lock is a sleeping mutex, it's not disabling preemption. Moving it
>>> doesn't make a difference.
>>>
>>>>
>>>> BUG: sleeping function called from invalid context at kernel/locking/rtmutex.c:930
>>>> in_atomic(): 1, irqs_disabled(): 0, pid: 625, name: kworker/u16:3
>>>
>>> Something else disabled preemption. And note, nothing in the tracepoint
>>> should have called a sleeping function.
>>
>> Yes, it makes me confused too. It sounds like the preempt_ip address is
>> not that accurate.
>
> Yep, but the change you made doesn't look to be the fix.

Actually, regardless whether this is the right fix for the splat, it 
makes me be wondering if the spin lock which protects the whole for loop 
is really necessary. It sounds feasible to move it into the for loop and 
just protect the necessary area.

>
>>
>>>
>>>
>>>> INFO: lockdep is turned off.
>>>> Preemption disabled at:[<ffffffc000374a5c>] wb_writeback+0xec/0x830
>
> Can you disassemble the vmlinux file to see exactly where that call is.
> I use gdb to find the right locations.
>
>   gdb> li *0xffffffc000374a5c
>   gdb> disass 0xffffffc000374a5c

I use gdb to get the code too.

It does point to the spin_lock.

(gdb) list *0xffffffc000374a5c
0xffffffc000374a5c is in wb_writeback (fs/fs-writeback.c:1621).
1616
1617            oldest_jif = jiffies;
1618            work->older_than_this = &oldest_jif;
1619
1620            blk_start_plug(&plug);
1621            spin_lock(&wb->list_lock);
1622            for (;;) {
1623                    /*
1624                     * Stop writeback when nr_pages has been consumed
1625                     */


The disassemble:
    0xffffffc000374a58 <+232>:   bl      0xffffffc0001300b0 
<migrate_disable>
    0xffffffc000374a5c <+236>:   mov     x0, x22
    0xffffffc000374a60 <+240>:   bl      0xffffffc000d5d518 <rt_spin_lock>

>
>>>>
>>>> CPU: 7 PID: 625 Comm: kworker/u16:3 Not tainted 4.4.1-rt5 #20
>>>> Hardware name: Freescale Layerscape 2085a RDB Board (DT)
>>>> Workqueue: writeback wb_workfn (flush-7:0)
>>>> Call trace:
>>>> [<ffffffc00008d708>] dump_backtrace+0x0/0x200
>>>> [<ffffffc00008d92c>] show_stack+0x24/0x30
>>>> [<ffffffc0007b0f40>] dump_stack+0x88/0xa8
>>>> [<ffffffc000127d74>] ___might_sleep+0x2ec/0x300
>>>> [<ffffffc000d5d550>] rt_spin_lock+0x38/0xb8
>>>> [<ffffffc0003e0548>] kernfs_path_len+0x30/0x90
>>>> [<ffffffc00036b360>] trace_event_raw_event_writeback_work_class+0xe8/0x2e8
>>>
>>> How accurate is this trace back? Here's the code that is executed in
>>> this tracepoint:
>>>
>>> 	TP_fast_assign(
>>> 		struct device *dev = bdi->dev;
>>> 		if (!dev)
>>> 			dev = default_backing_dev_info.dev;
>>> 		strncpy(__entry->name, dev_name(dev), 32);
>>> 		__entry->nr_pages = work->nr_pages;
>>> 		__entry->sb_dev = work->sb ? work->sb->s_dev : 0;
>>> 		__entry->sync_mode = work->sync_mode;
>>> 		__entry->for_kupdate = work->for_kupdate;
>>> 		__entry->range_cyclic = work->range_cyclic;
>>> 		__entry->for_background	= work->for_background;
>>> 		__entry->reason = work->reason;
>>> 	),
>>>
>>> See anything that would sleep?
>>
>> According to the stack backtrace, kernfs_path_len calls slepping lock,
>> which is called by __trace_wb_cgroup_size(wb) in __dynamic_array(char,
>> cgroup, __trace_wb_cgroup_size(wb)).
>>
>> The below is the definition:
>>
>> DECLARE_EVENT_CLASS(writeback_work_class,
>>           TP_PROTO(struct bdi_writeback *wb, struct wb_writeback_work *work),
>>           TP_ARGS(wb, work),
>>           TP_STRUCT__entry(
>>                   __array(char, name, 32)
>>                   __field(long, nr_pages)
>>                   __field(dev_t, sb_dev)
>>                   __field(int, sync_mode)
>>                   __field(int, for_kupdate)
>>                   __field(int, range_cyclic)
>>                   __field(int, for_background)
>>                   __field(int, reason)
>>                   __dynamic_array(char, cgroup, __trace_wb_cgroup_size(wb))
>>
>
> Ah, thanks for pointing that out. I missed that.

It sounds not correct if tracepoint doesn't allow sleep.

I considered to change sleeping lock to raw lock in kernfs_* functions, 
but it sounds not reasonable since they are used heavily by cgroup.

Thanks,
Yang

>
> -- Steve
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
