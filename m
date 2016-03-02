Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f169.google.com (mail-ig0-f169.google.com [209.85.213.169])
	by kanga.kvack.org (Postfix) with ESMTP id EB1426B0009
	for <linux-mm@kvack.org>; Wed,  2 Mar 2016 07:02:38 -0500 (EST)
Received: by mail-ig0-f169.google.com with SMTP id z8so40503166ige.0
        for <linux-mm@kvack.org>; Wed, 02 Mar 2016 04:02:38 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id rt3si5330365igb.53.2016.03.02.04.02.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 02 Mar 2016 04:02:38 -0800 (PST)
Subject: How to avoid printk() delay caused by cond_resched() ?
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-Id: <201603022101.CAH73907.OVOOMFHFFtQJSL@I-love.SAKURA.ne.jp>
Date: Wed, 2 Mar 2016 21:01:03 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: sergey.senozhatsky@gmail.com, pmladek@suse.com
Cc: jack@suse.com, tj@kernel.org, kyle@kernel.org, davej@codemonkey.org.uk, calvinowens@fb.com, akpm@linux-foundation.org, linux-mm@kvack.org

I have a question about "printk: set may_schedule for some of
console_trylock() callers" in linux-next.git.

I'm trying to dump information of all threads which might be relevant
to stalling inside memory allocator. But it seems to me that since this
patch changed to allow calling cond_resched() from printk() if it is
safe to do so, it is now possible that the thread which invoked the OOM
killer can sleep for minutes with the oom_lock mutex held when my dump is
in progress. I want to release oom_lock mutex as soon as possible so
that other threads can call out_of_memory() to get TIF_MEMDIE and exit
their allocations.

So, how can I prevent printk() triggered by out_of_memory() from sleeping
for minutes with oom_lock mutex held? Guard it with preempt_disable() /
preempt_enable() ? Guard it with rcu_read_lock() / rcu_read_unlock() ? 

----------
[  460.893958] tgid=11161 invoked oom-killer: gfp_mask=0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD), order=0, oom_score_adj=1000
[  463.892897] tgid=11161 cpuset=/ mems_allowed=0
[  463.894724] CPU: 1 PID: 12346 Comm: tgid=11161 Not tainted 4.5.0-rc6-next-20160302+ #318
[  463.897026] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
[  463.899841]  0000000000000286 00000000733ef955 ffff8800778a79b0 ffffffff813a2ded
[  463.902164]  0000000000000000 ffff8800778a7be0 ffff8800778a7a50 ffffffff811c24d0
[  463.904474]  0000000000000206 ffffffff81810c30 ffff8800778a79f0 ffffffff810bf839
[  463.906801] Call Trace:
[  463.908101]  [<ffffffff813a2ded>] dump_stack+0x85/0xc8
[  463.909921]  [<ffffffff811c24d0>] dump_header+0x5b/0x3b0
[  463.911759]  [<ffffffff810bf839>] ? trace_hardirqs_on_caller+0xf9/0x1c0
[  463.913833]  [<ffffffff810bf90d>] ? trace_hardirqs_on+0xd/0x10
[  463.915751]  [<ffffffff81146f2d>] oom_kill_process+0x37d/0x570
[  463.918024]  [<ffffffff81147366>] out_of_memory+0x1f6/0x5a0
[  463.919890]  [<ffffffff81147424>] ? out_of_memory+0x2b4/0x5a0
[  463.921784]  [<ffffffff8114d041>] __alloc_pages_nodemask+0xc91/0xeb0
[  463.923788]  [<ffffffff81196726>] alloc_pages_current+0x96/0x1b0
[  463.925729]  [<ffffffff8114188d>] __page_cache_alloc+0x12d/0x160
[  463.927682]  [<ffffffff8114537a>] filemap_fault+0x48a/0x6a0
[  463.929547]  [<ffffffff81145247>] ? filemap_fault+0x357/0x6a0
[  463.931409]  [<ffffffff812b9e09>] xfs_filemap_fault+0x39/0x60
[  463.933255]  [<ffffffff8116f19d>] __do_fault+0x6d/0x150
[  463.934974]  [<ffffffff81175b1d>] handle_mm_fault+0xecd/0x1800
[  463.936791]  [<ffffffff81174ca3>] ? handle_mm_fault+0x53/0x1800
[  463.938617]  [<ffffffff8105a796>] __do_page_fault+0x1e6/0x520
[  463.940380]  [<ffffffff8105ab00>] do_page_fault+0x30/0x80
[  463.942074]  [<ffffffff817113e8>] page_fault+0x28/0x30
[  463.943750] Mem-Info:
(...snipped...)
[  554.754959] MemAlloc: tgid=11161(12346) flags=0x400040 switches=865 seq=169 gfp=0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD) order=0 delay=81602
[  554.754962] tgid=11161      R  running task        0 12346  11056 0x00000080
[  554.754965]  ffff8800778a7838 ffff880034510000 ffff8800778b0000 ffff8800778a8000
[  554.754966]  0000000000000091 ffffffff82a86fbc 0000000000000004 0000000000000000
[  554.754967]  ffff8800778a7850 ffffffff8170a5dd 0000000000000296 ffff8800778a7860
[  554.754968] Call Trace:
[  554.754974]  [<ffffffff8170a5dd>] preempt_schedule_common+0x1f/0x42
[  554.754975]  [<ffffffff8170a617>] _cond_resched+0x17/0x20
[  554.754978]  [<ffffffff810d17b9>] console_unlock+0x509/0x5c0
[  554.754979]  [<ffffffff810d1b93>] vprintk_emit+0x323/0x540
[  554.754981]  [<ffffffff810d1f0a>] vprintk_default+0x1a/0x20
[  554.754983]  [<ffffffff8114069e>] printk+0x58/0x6f
[  554.754986]  [<ffffffff813aaede>] show_mem+0x1e/0xe0
[  554.754988]  [<ffffffff811c24ec>] dump_header+0x77/0x3b0
[  554.754990]  [<ffffffff810bf839>] ? trace_hardirqs_on_caller+0xf9/0x1c0
[  554.754991]  [<ffffffff810bf90d>] ? trace_hardirqs_on+0xd/0x10
[  554.754993]  [<ffffffff81146f2d>] oom_kill_process+0x37d/0x570
[  554.754995]  [<ffffffff81147366>] out_of_memory+0x1f6/0x5a0
[  554.754996]  [<ffffffff81147424>] ? out_of_memory+0x2b4/0x5a0
[  554.754997]  [<ffffffff8114d041>] __alloc_pages_nodemask+0xc91/0xeb0
[  554.755000]  [<ffffffff81196726>] alloc_pages_current+0x96/0x1b0
[  554.755001]  [<ffffffff8114188d>] __page_cache_alloc+0x12d/0x160
[  554.755003]  [<ffffffff8114537a>] filemap_fault+0x48a/0x6a0
[  554.755004]  [<ffffffff81145247>] ? filemap_fault+0x357/0x6a0
[  554.755006]  [<ffffffff812b9e09>] xfs_filemap_fault+0x39/0x60
[  554.755007]  [<ffffffff8116f19d>] __do_fault+0x6d/0x150
[  554.755009]  [<ffffffff81175b1d>] handle_mm_fault+0xecd/0x1800
[  554.755010]  [<ffffffff81174ca3>] ? handle_mm_fault+0x53/0x1800
[  554.755012]  [<ffffffff8105a796>] __do_page_fault+0x1e6/0x520
[  554.755013]  [<ffffffff8105ab00>] do_page_fault+0x30/0x80
[  554.755015]  [<ffffffff817113e8>] page_fault+0x28/0x30
----------

CONFIG_PREEMPT_NONE=y
# CONFIG_PREEMPT_VOLUNTARY is not set
# CONFIG_PREEMPT is not set
CONFIG_PREEMPT_COUNT=y

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
