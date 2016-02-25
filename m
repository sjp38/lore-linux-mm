Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 1077C6B0254
	for <linux-mm@kvack.org>; Thu, 25 Feb 2016 18:47:23 -0500 (EST)
Received: by mail-pa0-f49.google.com with SMTP id fy10so40199200pac.1
        for <linux-mm@kvack.org>; Thu, 25 Feb 2016 15:47:23 -0800 (PST)
Received: from mail-pf0-x232.google.com (mail-pf0-x232.google.com. [2607:f8b0:400e:c00::232])
        by mx.google.com with ESMTPS id va5si15463962pac.165.2016.02.25.15.47.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Feb 2016 15:47:22 -0800 (PST)
Received: by mail-pf0-x232.google.com with SMTP id x65so41102742pfb.1
        for <linux-mm@kvack.org>; Thu, 25 Feb 2016 15:47:22 -0800 (PST)
Subject: Re: [PATCH] writeback: call writeback tracepoints withoud holding
 list_lock in wb_writeback()
References: <1456354043-31420-1-git-send-email-yang.shi@linaro.org>
 <20160224214042.71c3493b@grimm.local.home> <56CF5848.7050806@linaro.org>
 <20160225145432.3749e5ec@gandalf.local.home> <56CF8B66.8070108@linaro.org>
 <20160225183107.1902d42b@gandalf.local.home>
From: "Shi, Yang" <yang.shi@linaro.org>
Message-ID: <56CF9288.5010406@linaro.org>
Date: Thu, 25 Feb 2016 15:47:20 -0800
MIME-Version: 1.0
In-Reply-To: <20160225183107.1902d42b@gandalf.local.home>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: tj@kernel.org, jack@suse.cz, axboe@fb.com, fengguang.wu@intel.com, tglx@linutronix.de, bigeasy@linutronix.de, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-rt-users@vger.kernel.org, linaro-kernel@lists.linaro.org

On 2/25/2016 3:31 PM, Steven Rostedt wrote:
> On Thu, 25 Feb 2016 15:16:54 -0800
> "Shi, Yang" <yang.shi@linaro.org> wrote:
>
>
>> Actually, regardless whether this is the right fix for the splat, it
>> makes me be wondering if the spin lock which protects the whole for loop
>> is really necessary. It sounds feasible to move it into the for loop and
>> just protect the necessary area.
>
> That's a separate issue, which may have its own merits that should be
> decided by the writeback folks.

Yes, definitely. I will rework my commit log for this part.

>
>>
>>>
>>>>
>>>>>
>>>>>
>>>>>> INFO: lockdep is turned off.
>>>>>> Preemption disabled at:[<ffffffc000374a5c>] wb_writeback+0xec/0x830
>>>
>>> Can you disassemble the vmlinux file to see exactly where that call is.
>>> I use gdb to find the right locations.
>>>
>>>    gdb> li *0xffffffc000374a5c
>>>    gdb> disass 0xffffffc000374a5c
>>
>> I use gdb to get the code too.
>>
>> It does point to the spin_lock.
>>
>> (gdb) list *0xffffffc000374a5c
>> 0xffffffc000374a5c is in wb_writeback (fs/fs-writeback.c:1621).
>> 1616
>> 1617            oldest_jif = jiffies;
>> 1618            work->older_than_this = &oldest_jif;
>> 1619
>> 1620            blk_start_plug(&plug);
>> 1621            spin_lock(&wb->list_lock);
>> 1622            for (;;) {
>> 1623                    /*
>> 1624                     * Stop writeback when nr_pages has been consumed
>> 1625                     */
>>
>>
>> The disassemble:
>>      0xffffffc000374a58 <+232>:   bl      0xffffffc0001300b0
>
> The above is the place it recorded. But I just realized, this isn't the
> issue. I know where the problem is.
>
>
>> <migrate_disable>
>>      0xffffffc000374a5c <+236>:   mov     x0, x22
>>      0xffffffc000374a60 <+240>:   bl      0xffffffc000d5d518 <rt_spin_lock>
>>
>>>
>
>
>
>>>> DECLARE_EVENT_CLASS(writeback_work_class,
>>>>            TP_PROTO(struct bdi_writeback *wb, struct wb_writeback_work *work),
>>>>            TP_ARGS(wb, work),
>>>>            TP_STRUCT__entry(
>>>>                    __array(char, name, 32)
>>>>                    __field(long, nr_pages)
>>>>                    __field(dev_t, sb_dev)
>>>>                    __field(int, sync_mode)
>>>>                    __field(int, for_kupdate)
>>>>                    __field(int, range_cyclic)
>>>>                    __field(int, for_background)
>>>>                    __field(int, reason)
>>>>                    __dynamic_array(char, cgroup, __trace_wb_cgroup_size(wb))
>>>>
>>>
>>> Ah, thanks for pointing that out. I missed that.
>>
>> It sounds not correct if tracepoint doesn't allow sleep.
>>
>> I considered to change sleeping lock to raw lock in kernfs_* functions,
>> but it sounds not reasonable since they are used heavily by cgroup.
>
> It is the kernfs_* that can't sleep. Tracepoints use
> rcu_read_lock_sched_notrace(), which disables preemption, and not only
> that, hides itself from lockdep as the last place to disable preemption.

Ah, thanks for pointing out this.

>
> Is there a way to not use the kernfs_* function? At least for -rt?

I'm not quite sure if there is straightforward replacement. However, I'm 
wondering if lock free version could be used by tracing.

For example, create __kernfs_path_len which doesn't acquire any lock for 
writeback tracing as long as there is not any race condition.

At least we could rule out preemption.

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
