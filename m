Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f52.google.com (mail-oi0-f52.google.com [209.85.218.52])
	by kanga.kvack.org (Postfix) with ESMTP id CA9336B0005
	for <linux-mm@kvack.org>; Wed, 20 Jan 2016 08:55:50 -0500 (EST)
Received: by mail-oi0-f52.google.com with SMTP id k206so5481176oia.1
        for <linux-mm@kvack.org>; Wed, 20 Jan 2016 05:55:50 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id w13si5172752oep.70.2016.01.20.05.55.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 20 Jan 2016 05:55:49 -0800 (PST)
Subject: Re: [BUG] oom hangs the system, NMI backtrace shows most CPUs in shrink_slab
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <569D06F8.4040209@redhat.com>
	<569E1010.2070806@I-love.SAKURA.ne.jp>
	<569E5287.4080503@redhat.com>
	<201601201923.DCC48978.FSHLOQtOVJFFOM@I-love.SAKURA.ne.jp>
In-Reply-To: <201601201923.DCC48978.FSHLOQtOVJFFOM@I-love.SAKURA.ne.jp>
Message-Id: <201601202217.BEF43262.QOLFHOOJFVFtMS@I-love.SAKURA.ne.jp>
Date: Wed, 20 Jan 2016 22:17:23 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tj@kernel.org, jiangshanlai@gmail.com
Cc: jstancek@redhat.com, linux-mm@kvack.org, ltp@lists.linux.it

Tetsuo Handa wrote:
> (3) I/O for swap memory was effectively disabled by uptime = 6904.
> 
>     I don't know the reason why the kernel cannot access swap memory.
>     To access swap memory, some memory allocation is needed which is
>     failing due to free: field of Normal zone smaller than min: field?
>     If accessing swap memory depends on workqueue items, are they
>     created with WQ_MEM_RECLAIM?
> 

Tejun, I have a question about system_freezable_power_efficient_wq.

        system_freezable_power_efficient_wq = alloc_workqueue("events_freezable_power_efficient",
                                              WQ_FREEZABLE | WQ_POWER_EFFICIENT,
                                              0);

This workqueue is used by cdrom driver for periodically checking status.
----------
[ 6916.734842] kworker/1:1     R  running task    12592 20708      2 0x00000080 
[ 6916.742739] Workqueue: events_freezable_power_ disk_events_workfn 
[ 6916.749541]  ffff8801cf5877f8 ffff8801cf5878e8 0000000000000000 0000000000000002 
[ 6916.757840]  0000000000000000 ffff88045e822800 ffff88045a138000 ffff8801cf588000 
[ 6916.766139]  ffff8801cf5879d0 0000000000000000 0000000000000000 0000000000000000 
[ 6916.774440] Call Trace: 
[ 6916.777169]  [<ffffffff8177e946>] ? _raw_spin_unlock_irqrestore+0x36/0x60 
[ 6916.784746]  [<ffffffff811ecaaf>] ? shrink_zone+0x18f/0x330 
[ 6916.790966]  [<ffffffff811ecff4>] ? do_try_to_free_pages+0x174/0x440 
[ 6916.798058]  [<ffffffff811ed3c0>] ? try_to_free_pages+0x100/0x2c0 
[ 6916.804860]  [<ffffffff81269102>] ? __alloc_pages_slowpath+0x278/0x78c 
[ 6916.812147]  [<ffffffff811dcdb1>] ? __alloc_pages_nodemask+0x4a1/0x4d0 
[ 6916.819426]  [<ffffffff810f51f4>] ? __lock_is_held+0x54/0x70 
[ 6916.825742]  [<ffffffff81232387>] ? alloc_pages_current+0x97/0x1b0 
[ 6916.832641]  [<ffffffff8137f389>] ? bio_copy_kern+0xc9/0x180 
[ 6916.838957]  [<ffffffff8138e2c5>] ? blk_rq_map_kern+0x75/0x130 
[ 6916.845469]  [<ffffffff81527192>] ? scsi_execute+0x132/0x160 
[ 6916.851787]  [<ffffffff8152972e>] ? scsi_execute_req_flags+0x8e/0xf0 
[ 6916.858880]  [<ffffffffa012d6e7>] ? sr_check_events+0xb7/0x2a0 [sr_mod] 
[ 6916.866257]  [<ffffffffa0085058>] ? cdrom_check_events+0x18/0x30 [cdrom] 
[ 6916.873736]  [<ffffffffa012db2a>] ? sr_block_check_events+0x2a/0x30 [sr_mod] 
[ 6916.881603]  [<ffffffff8139a360>] ? disk_check_events+0x60/0x170 
[ 6916.888308]  [<ffffffff8139a48c>] ? disk_events_workfn+0x1c/0x20 
[ 6916.895013]  [<ffffffff810b7065>] ? process_one_work+0x215/0x650 
[ 6916.901721]  [<ffffffff810b6fd1>] ? process_one_work+0x181/0x650 
[ 6916.908428]  [<ffffffff810b75c5>] ? worker_thread+0x125/0x4a0 
[ 6916.914840]  [<ffffffff810b74a0>] ? process_one_work+0x650/0x650 
[ 6916.921544]  [<ffffffff810be1a1>] ? kthread+0x101/0x120 
[ 6916.927377]  [<ffffffff810f8c29>] ? trace_hardirqs_on_caller+0xf9/0x1c0 
[ 6916.934754]  [<ffffffff810be0a0>] ? kthread_create_on_node+0x250/0x250 
[ 6916.942040]  [<ffffffff8177f75f>] ? ret_from_fork+0x3f/0x70 
[ 6916.948260]  [<ffffffff810be0a0>] ? kthread_create_on_node+0x250/0x250 
[ 6916.955546] 3 locks held by kworker/1:1/20708: 
[ 6916.960504]  #0:  ("events_freezable_power_efficient"){.+.+.+}, at: [<ffffffff810b6fd1>] process_one_work+0x181/0x650 
[ 6916.972402]  #1:  ((&(&ev->dwork)->work)){+.+.+.}, at: [<ffffffff810b6fd1>] process_one_work+0x181/0x650 
[ 6916.983044]  #2:  (shrinker_rwsem){++++..}, at: [<ffffffff8125712f>] mem_cgroup_iter+0x14f/0x870 
----------

What happens if memory allocation requests from items using this workqueue
got stuck due to OOM livelock? Are pending items in this workqueue cannot
be processed because this workqueue was created without WQ_MEM_RECLAIM?

I don't know whether accessing swap memory depends on this workqueue.
But if disk driver depends on this workqueue for accessing swap partition
on the disk, some event is looping inside memory allocator will result in
unable to process disk I/O request for accessing swap partition on the disk?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
