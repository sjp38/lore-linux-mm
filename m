Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f171.google.com (mail-io0-f171.google.com [209.85.223.171])
	by kanga.kvack.org (Postfix) with ESMTP id 603BD6B0254
	for <linux-mm@kvack.org>; Thu, 25 Feb 2016 14:54:36 -0500 (EST)
Received: by mail-io0-f171.google.com with SMTP id g203so99945853iof.2
        for <linux-mm@kvack.org>; Thu, 25 Feb 2016 11:54:36 -0800 (PST)
Received: from smtprelay.hostedemail.com (smtprelay0092.hostedemail.com. [216.40.44.92])
        by mx.google.com with ESMTPS id ph3si6425724igb.20.2016.02.25.11.54.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Feb 2016 11:54:35 -0800 (PST)
Date: Thu, 25 Feb 2016 14:54:32 -0500
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH] writeback: call writeback tracepoints withoud holding
 list_lock in wb_writeback()
Message-ID: <20160225145432.3749e5ec@gandalf.local.home>
In-Reply-To: <56CF5848.7050806@linaro.org>
References: <1456354043-31420-1-git-send-email-yang.shi@linaro.org>
	<20160224214042.71c3493b@grimm.local.home>
	<56CF5848.7050806@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Shi, Yang" <yang.shi@linaro.org>
Cc: tj@kernel.org, jack@suse.cz, axboe@fb.com, fengguang.wu@intel.com, tglx@linutronix.de, bigeasy@linutronix.de, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-rt-users@vger.kernel.org, linaro-kernel@lists.linaro.org

On Thu, 25 Feb 2016 11:38:48 -0800
"Shi, Yang" <yang.shi@linaro.org> wrote:

> On 2/24/2016 6:40 PM, Steven Rostedt wrote:
> > On Wed, 24 Feb 2016 14:47:23 -0800
> > Yang Shi <yang.shi@linaro.org> wrote:
> >  
> >> commit 5634cc2aa9aebc77bc862992e7805469dcf83dac ("writeback: update writeback
> >> tracepoints to report cgroup") made writeback tracepoints report cgroup
> >> writeback, but it may trigger the below bug on -rt kernel due to the list_lock
> >> held for the for loop in wb_writeback().  
> >
> > list_lock is a sleeping mutex, it's not disabling preemption. Moving it
> > doesn't make a difference.
> >  
> >>
> >> BUG: sleeping function called from invalid context at kernel/locking/rtmutex.c:930
> >> in_atomic(): 1, irqs_disabled(): 0, pid: 625, name: kworker/u16:3  
> >
> > Something else disabled preemption. And note, nothing in the tracepoint
> > should have called a sleeping function.  
> 
> Yes, it makes me confused too. It sounds like the preempt_ip address is 
> not that accurate.

Yep, but the change you made doesn't look to be the fix.

> 
> >
> >  
> >> INFO: lockdep is turned off.
> >> Preemption disabled at:[<ffffffc000374a5c>] wb_writeback+0xec/0x830

Can you disassemble the vmlinux file to see exactly where that call is.
I use gdb to find the right locations.

 gdb> li *0xffffffc000374a5c
 gdb> disass 0xffffffc000374a5c

> >>
> >> CPU: 7 PID: 625 Comm: kworker/u16:3 Not tainted 4.4.1-rt5 #20
> >> Hardware name: Freescale Layerscape 2085a RDB Board (DT)
> >> Workqueue: writeback wb_workfn (flush-7:0)
> >> Call trace:
> >> [<ffffffc00008d708>] dump_backtrace+0x0/0x200
> >> [<ffffffc00008d92c>] show_stack+0x24/0x30
> >> [<ffffffc0007b0f40>] dump_stack+0x88/0xa8
> >> [<ffffffc000127d74>] ___might_sleep+0x2ec/0x300
> >> [<ffffffc000d5d550>] rt_spin_lock+0x38/0xb8
> >> [<ffffffc0003e0548>] kernfs_path_len+0x30/0x90
> >> [<ffffffc00036b360>] trace_event_raw_event_writeback_work_class+0xe8/0x2e8  
> >
> > How accurate is this trace back? Here's the code that is executed in
> > this tracepoint:
> >
> > 	TP_fast_assign(
> > 		struct device *dev = bdi->dev;
> > 		if (!dev)
> > 			dev = default_backing_dev_info.dev;
> > 		strncpy(__entry->name, dev_name(dev), 32);
> > 		__entry->nr_pages = work->nr_pages;
> > 		__entry->sb_dev = work->sb ? work->sb->s_dev : 0;
> > 		__entry->sync_mode = work->sync_mode;
> > 		__entry->for_kupdate = work->for_kupdate;
> > 		__entry->range_cyclic = work->range_cyclic;
> > 		__entry->for_background	= work->for_background;
> > 		__entry->reason = work->reason;
> > 	),
> >
> > See anything that would sleep?  
> 
> According to the stack backtrace, kernfs_path_len calls slepping lock, 
> which is called by __trace_wb_cgroup_size(wb) in __dynamic_array(char, 
> cgroup, __trace_wb_cgroup_size(wb)).
> 
> The below is the definition:
> 
> DECLARE_EVENT_CLASS(writeback_work_class,
>          TP_PROTO(struct bdi_writeback *wb, struct wb_writeback_work *work),
>          TP_ARGS(wb, work),
>          TP_STRUCT__entry(
>                  __array(char, name, 32)
>                  __field(long, nr_pages)
>                  __field(dev_t, sb_dev)
>                  __field(int, sync_mode)
>                  __field(int, for_kupdate)
>                  __field(int, range_cyclic)
>                  __field(int, for_background)
>                  __field(int, reason)
>                  __dynamic_array(char, cgroup, __trace_wb_cgroup_size(wb))
> 

Ah, thanks for pointing that out. I missed that.

-- Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
