Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f46.google.com (mail-qg0-f46.google.com [209.85.192.46])
	by kanga.kvack.org (Postfix) with ESMTP id 7C7E36B0009
	for <linux-mm@kvack.org>; Tue, 19 Jan 2016 10:13:15 -0500 (EST)
Received: by mail-qg0-f46.google.com with SMTP id o11so581321078qge.2
        for <linux-mm@kvack.org>; Tue, 19 Jan 2016 07:13:15 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j18si37918690qge.47.2016.01.19.07.13.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Jan 2016 07:13:14 -0800 (PST)
Subject: Re: [BUG] oom hangs the system, NMI backtrace shows most CPUs in
 shrink_slab
References: <569D06F8.4040209@redhat.com>
 <569E1010.2070806@I-love.SAKURA.ne.jp>
From: Jan Stancek <jstancek@redhat.com>
Message-ID: <569E5287.4080503@redhat.com>
Date: Tue, 19 Jan 2016 16:13:11 +0100
MIME-Version: 1.0
In-Reply-To: <569E1010.2070806@I-love.SAKURA.ne.jp>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org
Cc: ltp@lists.linux.it

On 01/19/2016 11:29 AM, Tetsuo Handa wrote:
> Jan Stancek wrote:
>> I'm seeing system occasionally hanging after "oom01" testcase
>> from LTP triggers OOM.
>>
>> Here's a console log obtained from v4.4-8606 (shows oom, followed
>> by blocked task messages, followed by me triggering sysrq-t):
>>   http://jan.stancek.eu/tmp/oom_hangs/oom_hang_v4.4-8606.txt
>>   http://jan.stancek.eu/tmp/oom_hangs/config-v4.4-8606.txt
> 
> I think this console log reports an OOM livelock.
> 
> dump_tasks() shows that there are 2 oom1 tasks (10482 and 10528) but
> show_state() shows that there are 8 oom1 tasks whose parent is 10482
> (10528 10529 10530 10531 10532 10533 10534 10535). Thus, I guess oom1
> process called fork() and the child process created 7 threads.

Correct, parent forks a child and expects that child to be killed by OOM.
Child forks NCPU-1 threads, which all keep allocating/touching memory
while they can.

> 
> ----------
> [  495.322098] [10482]     0 10482     2692       10      11       3       27             0 oom01
> [  495.341231] [10528]     0 10528  8667787  3731327   11002      28  1890661             0 oom01
> [ 1736.414809] oom01           S ffff880453dd3e48 13008 10482  10479 0x00000080
> [ 1737.025258] oom01           x ffff88044ff9bc98 13080 10528  10482 0x00000084
> [ 1737.129553] oom01           R  running task    11616 10529  10482 0x00000084
> [ 1737.309520] oom01           R  running task    11544 10530  10482 0x00000084
> [ 1737.417212] oom01           R  running task    11616 10531  10482 0x00000084
> [ 1737.551904] oom01           R  running task    11616 10532  10482 0x00000084
> [ 1737.725174] oom01           R  running task    11616 10533  10482 0x00000084
> [ 1737.898452] oom01           R  running task    11616 10534  10482 0x00000084
> [ 1738.078431] oom01           R  running task    11616 10535  10482 0x00000084
> ----------
> 
> 10528 got both SIGKILL and TIF_MEMDIE at uptime = 495 and has exited by uptime = 1737.
> 
> ----------
> [  495.350845] Out of memory: Kill process 10528 (oom01) score 952 or sacrifice child
> [  495.359301] Killed process 10528 (oom01) total-vm:34671148kB, anon-rss:14925308kB, file-rss:0kB, shmem-rss:0kB
> ----------
> 
> Since 10529 to 10535 got only SIGKILL, all of them are looping inside __alloc_pages_slowpath().
> 
> ----------
> [ 1737.129553] oom01           R  running task    11616 10529  10482 0x00000084
> [ 1737.172049]  [<ffffffff81778a8c>] _cond_resched+0x1c/0x30
> [ 1737.178072]  [<ffffffff811e6daf>] shrink_slab.part.42+0x2cf/0x540
> [ 1737.184873]  [<ffffffff811176ae>] ? rcu_read_lock_held+0x5e/0x70
> [ 1737.191577]  [<ffffffff811ec4ba>] shrink_zone+0x30a/0x330
> [ 1737.197602]  [<ffffffff811ec884>] do_try_to_free_pages+0x174/0x440
> [ 1737.204499]  [<ffffffff811ecc50>] try_to_free_pages+0x100/0x2c0
> [ 1737.211107]  [<ffffffff81268ae0>] __alloc_pages_slowpath.constprop.85+0x3c6/0x74a
> [ 1737.309520] oom01           R  running task    11544 10530  10482 0x00000084
> [ 1737.352024]  [<ffffffff81778a8c>] _cond_resched+0x1c/0x30
> [ 1737.358049]  [<ffffffff81268b12>] __alloc_pages_slowpath.constprop.85+0x3f8/0x74a
> [ 1737.417212] oom01           R  running task    11616 10531  10482 0x00000084
> [ 1737.459715]  [<ffffffff81778a8c>] _cond_resched+0x1c/0x30
> [ 1737.465739]  [<ffffffff811e6daf>] shrink_slab.part.42+0x2cf/0x540
> [ 1737.472540]  [<ffffffff811176ae>] ? rcu_read_lock_held+0x5e/0x70
> [ 1737.479242]  [<ffffffff811ec4ba>] shrink_zone+0x30a/0x330
> [ 1737.485266]  [<ffffffff811ec884>] do_try_to_free_pages+0x174/0x440
> [ 1737.492162]  [<ffffffff811ecc50>] try_to_free_pages+0x100/0x2c0
> [ 1737.498768]  [<ffffffff81268ae0>] __alloc_pages_slowpath.constprop.85+0x3c6/0x74a
> [ 1737.551904] oom01           R  running task    11616 10532  10482 0x00000084
> [ 1737.594403]  [<ffffffff81778a8c>] _cond_resched+0x1c/0x30
> [ 1737.600428]  [<ffffffff811e6cf0>] shrink_slab.part.42+0x210/0x540
> [ 1737.607228]  [<ffffffff811ec4ba>] shrink_zone+0x30a/0x330
> [ 1737.613252]  [<ffffffff811ec884>] do_try_to_free_pages+0x174/0x440
> [ 1737.620150]  [<ffffffff811ecc50>] try_to_free_pages+0x100/0x2c0
> [ 1737.626755]  [<ffffffff81268ae0>] __alloc_pages_slowpath.constprop.85+0x3c6/0x74a
> [ 1737.725174] oom01           R  running task    11616 10533  10482 0x00000084
> [ 1737.767682]  [<ffffffff81778a8c>] _cond_resched+0x1c/0x30
> [ 1737.773705]  [<ffffffff811e6cf0>] shrink_slab.part.42+0x210/0x540
> [ 1737.780506]  [<ffffffff811ec4ba>] shrink_zone+0x30a/0x330
> [ 1737.786532]  [<ffffffff811ec884>] do_try_to_free_pages+0x174/0x440
> [ 1737.793428]  [<ffffffff811ecc50>] try_to_free_pages+0x100/0x2c0
> [ 1737.800037]  [<ffffffff81268ae0>] __alloc_pages_slowpath.constprop.85+0x3c6/0x74a
> [ 1737.898452] oom01           R  running task    11616 10534  10482 0x00000084
> [ 1737.940961]  [<ffffffff81778a8c>] _cond_resched+0x1c/0x30
> [ 1737.946985]  [<ffffffff811e6daf>] shrink_slab.part.42+0x2cf/0x540
> [ 1737.953785]  [<ffffffff811176ae>] ? rcu_read_lock_held+0x5e/0x70
> [ 1737.960488]  [<ffffffff811ec4ba>] shrink_zone+0x30a/0x330
> [ 1737.966512]  [<ffffffff811ec884>] do_try_to_free_pages+0x174/0x440
> [ 1737.973408]  [<ffffffff811ecc50>] try_to_free_pages+0x100/0x2c0
> [ 1737.980015]  [<ffffffff81268ae0>] __alloc_pages_slowpath.constprop.85+0x3c6/0x74a
> [ 1738.078431] oom01           R  running task    11616 10535  10482 0x00000084
> [ 1738.120938]  [<ffffffff81778a8c>] _cond_resched+0x1c/0x30
> [ 1738.126961]  [<ffffffff81268b12>] __alloc_pages_slowpath.constprop.85+0x3f8/0x74a
> ----------
> 
> As a result, 10482 remains sleeping at wait().
> 
> ----------
> [ 1736.414809] oom01           S ffff880453dd3e48 13008 10482  10479 0x00000080
> [ 1736.450320]  [<ffffffff817787ec>] schedule+0x3c/0x90
> [ 1736.455859]  [<ffffffff8109ba93>] do_wait+0x213/0x2f0
> [ 1736.461495]  [<ffffffff8109ce60>] SyS_wait4+0x80/0x100
> ----------
> 
> Also, 10519 is a typical trace which is looping inside __alloc_pages_slowpath()
> which can be observed when we hit OOM livelock. Since this allocation request
> includes neither __GFP_NOFAIL nor __GFP_FS, out_of_memory() cannot be called.
> 
> ----------
> [ 1736.716427] kworker/2:1     R  running task    12616 10519      2 0x00000088
> [ 1736.724319] Workqueue: events_freezable_power_ disk_events_workfn
> [ 1736.731128]  00000000ca948786 ffff88035997b8e8 0000000000000000 0000000000000000
> [ 1736.739427]  0000000000000000 0000000000000000 ffff88035997b850 ffffffff811ec4ba
> [ 1736.747725]  ffff88035997b9d0 0000000000000000 0000000000000000 0001000000000000
> [ 1736.756022] Call Trace:
> [ 1736.758749]  [<ffffffff811ec4ba>] ? shrink_zone+0x30a/0x330
> [ 1736.764969]  [<ffffffff811ec884>] ? do_try_to_free_pages+0x174/0x440
> [ 1736.772060]  [<ffffffff811ecc50>] ? try_to_free_pages+0x100/0x2c0
> [ 1736.778861]  [<ffffffff81268ae0>] ? __alloc_pages_slowpath.constprop.85+0x3c6/0x74a
> [ 1736.787408]  [<ffffffff811dc666>] ? __alloc_pages_nodemask+0x456/0x460
> [ 1736.794690]  [<ffffffff810f51e4>] ? __lock_is_held+0x54/0x70
> [ 1736.801004]  [<ffffffff81231c17>] ? alloc_pages_current+0x97/0x1b0
> [ 1736.807902]  [<ffffffff8137ebd9>] ? bio_copy_kern+0xc9/0x180
> [ 1736.814217]  [<ffffffff8138db15>] ? blk_rq_map_kern+0x75/0x130
> [ 1736.820726]  [<ffffffff815269e2>] ? scsi_execute+0x132/0x160
> [ 1736.827041]  [<ffffffff81528f7e>] ? scsi_execute_req_flags+0x8e/0xf0
> [ 1736.834133]  [<ffffffffa01956e7>] ? sr_check_events+0xb7/0x2a0 [sr_mod]
> [ 1736.841514]  [<ffffffffa00d7058>] ? cdrom_check_events+0x18/0x30 [cdrom]
> [ 1736.848992]  [<ffffffffa0195b2a>] ? sr_block_check_events+0x2a/0x30 [sr_mod]
> [ 1736.856859]  [<ffffffff81399bb0>] ? disk_check_events+0x60/0x170
> [ 1736.863561]  [<ffffffff81399cdc>] ? disk_events_workfn+0x1c/0x20
> [ 1736.870264]  [<ffffffff810b7055>] ? process_one_work+0x215/0x650
> [ 1736.876967]  [<ffffffff810b6fc1>] ? process_one_work+0x181/0x650
> [ 1736.883671]  [<ffffffff810b75b5>] ? worker_thread+0x125/0x4a0
> [ 1736.890082]  [<ffffffff810b7490>] ? process_one_work+0x650/0x650
> [ 1736.896785]  [<ffffffff810be191>] ? kthread+0x101/0x120
> [ 1736.902615]  [<ffffffff810f8c19>] ? trace_hardirqs_on_caller+0xf9/0x1c0
> [ 1736.909997]  [<ffffffff810be090>] ? kthread_create_on_node+0x250/0x250
> [ 1736.917281]  [<ffffffff8177ef9f>] ? ret_from_fork+0x3f/0x70
> [ 1736.923499]  [<ffffffff810be090>] ? kthread_create_on_node+0x250/0x250
> ----------
> 
> What is strange is, 10529 to 10535 should be able to get TIF_MEMDIE and exit
> __alloc_pages_slowpath(). There are three possibilities. First is that they are
> too unlucky to take oom_lock mutex which is needed for calling out_of_memory(),
> but it should not continue failing to take oom_lock mutex for such long time.
> Second is that their allocation requests include neither __GFP_NOFAIL nor
> __GFP_FS which is needed for calling out_of_memory(). Third is that, although I
> couldn't find evidence that mlock() and madvice() are related with this hangup,
> something is preventing __GFP_NOFAIL or __GFP_FS allocation requests from
> calling out_of_memory(). If you can reproduce with kmallocwd patch at
> https://lkml.kernel.org/r/201511250024.AAE78692.QVOtFFOSFOMLJH@I-love.SAKURA.ne.jp
> applied, I think you will be able to know which possibility you are hitting.
> 

It took slightly longer this time. Here's full console log:
  http://jan.stancek.eu/tmp/oom_hangs/console.log.2-v4.4-8606-with-memalloc_wc.txt.bz2

Last OOM message happens at:
[ 6845.765153] oom01 invoked oom-killer: gfp_mask=0x24280ca, order=0, oom_score_adj=0

The moments later, first MemAlloc output starts appearing:
[ 6904.555880] MemAlloc-Info: 2 stalling task, 0 dying task, 0 victim task.
[ 6904.563387] MemAlloc: oom01(22011) seq=5135 gfp=0x24280ca order=0 delay=10001
[ 6904.571353] MemAlloc: oom01(22013) seq=5101 gfp=0x24280ca order=0 delay=10001

[ 6915.195869] MemAlloc-Info: 16 stalling task, 0 dying task, 0 victim task.
[ 6915.203458] MemAlloc: systemd-journal(592) seq=33409 gfp=0x24201ca order=0 delay=20495
[ 6915.212300] MemAlloc: NetworkManager(807) seq=42042 gfp=0x24200ca order=0 delay=12030
[ 6915.221042] MemAlloc: gssproxy(815) seq=1551 gfp=0x24201ca order=0 delay=19414
[ 6915.229104] MemAlloc: irqbalance(825) seq=6763 gfp=0x24201ca order=0 delay=11234
[ 6915.237363] MemAlloc: tuned(1339) seq=74664 gfp=0x24201ca order=0 delay=20354
[ 6915.245329] MemAlloc: top(10485) seq=486624 gfp=0x24201ca order=0 delay=20124
[ 6915.253288] MemAlloc: kworker/1:1(20708) seq=48 gfp=0x2400000 order=0 delay=20248
[ 6915.261640] MemAlloc: sendmail(21855) seq=207 gfp=0x24201ca order=0 delay=19977
[ 6915.269800] MemAlloc: oom01(22007) seq=2 gfp=0x24201ca order=0 delay=20269
[ 6915.277466] MemAlloc: oom01(22008) seq=5659 gfp=0x24280ca order=0 delay=20502
[ 6915.285432] MemAlloc: oom01(22009) seq=5189 gfp=0x24280ca order=0 delay=20502
[ 6915.293389] MemAlloc: oom01(22010) seq=4795 gfp=0x24280ca order=0 delay=20502
[ 6915.301353] MemAlloc: oom01(22011) seq=5135 gfp=0x24280ca order=0 delay=20641
[ 6915.309316] MemAlloc: oom01(22012) seq=3828 gfp=0x24280ca order=0 delay=20502
[ 6915.317280] MemAlloc: oom01(22013) seq=5101 gfp=0x24280ca order=0 delay=20641
[ 6915.325244] MemAlloc: oom01(22014) seq=3633 gfp=0x24280ca order=0 delay=20502

seq numbers above appear to hold for another ~40 minutes, then I power cycled the system.

Regards,
Jan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
