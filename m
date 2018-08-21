Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 200206B20BB
	for <linux-mm@kvack.org>; Tue, 21 Aug 2018 17:08:16 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id b124-v6so120526itb.9
        for <linux-mm@kvack.org>; Tue, 21 Aug 2018 14:08:16 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id w23-v6si69079itc.94.2018.08.21.14.08.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Aug 2018 14:08:14 -0700 (PDT)
Subject: Re: [PATCH] mm,page_alloc: PF_WQ_WORKER threads must sleep at
 should_reclaim_retry().
References: <9158a23e-7793-7735-e35c-acd540ca59bf@i-love.sakura.ne.jp>
 <20180730144647.GX24267@dhcp22.suse.cz>
 <20180730145425.GE1206094@devbig004.ftw2.facebook.com>
 <0018ac3b-94ee-5f09-e4e0-df53d2cbc925@i-love.sakura.ne.jp>
 <20180730154424.GG1206094@devbig004.ftw2.facebook.com>
 <20180730185110.GB24267@dhcp22.suse.cz>
 <20180730191005.GC24267@dhcp22.suse.cz>
 <6f433d59-4a56-b698-e119-682bb8bf6713@i-love.sakura.ne.jp>
 <20180731050928.GA4557@dhcp22.suse.cz>
 <d11c3aa2-0f14-d882-59c5-6634dc56eed1@i-love.sakura.ne.jp>
 <20180803061653.GB27245@dhcp22.suse.cz>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <804b50cb-0b17-201a-790b-18604396f826@i-love.sakura.ne.jp>
Date: Wed, 22 Aug 2018 06:07:40 +0900
MIME-Version: 1.0
In-Reply-To: <20180803061653.GB27245@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Tejun Heo <tj@kernel.org>, Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 2018/08/03 15:16, Michal Hocko wrote:
> On Fri 03-08-18 07:05:54, Tetsuo Handa wrote:
>> On 2018/07/31 14:09, Michal Hocko wrote:
>>> On Tue 31-07-18 06:01:48, Tetsuo Handa wrote:
>>>> On 2018/07/31 4:10, Michal Hocko wrote:
>>>>> Since should_reclaim_retry() should be a natural reschedule point,
>>>>> let's do the short sleep for PF_WQ_WORKER threads unconditionally in
>>>>> order to guarantee that other pending work items are started. This will
>>>>> workaround this problem and it is less fragile than hunting down when
>>>>> the sleep is missed. E.g. we used to have a sleeping point in the oom
>>>>> path but this has been removed recently because it caused other issues.
>>>>> Having a single sleeping point is more robust.
>>>>
>>>> linux.git has not removed the sleeping point in the OOM path yet. Since removing the
>>>> sleeping point in the OOM path can mitigate CVE-2016-10723, please do so immediately.
>>>
>>> is this an {Acked,Reviewed,Tested}-by?
>>>
>>> I will send the patch to Andrew if the patch is ok. 
>>>
>>>> (And that change will conflict with Roman's cgroup aware OOM killer patchset. But it
>>>> should be easy to rebase.)
>>>
>>> That is still a WIP so I would lose sleep over it.
>>>
>>
>> Now that Roman's cgroup aware OOM killer patchset will be dropped from linux-next.git ,
>> linux-next.git will get the sleeping point removed. Please send this patch to linux-next.git .
> 
> I still haven't heard any explicit confirmation that the patch works for
> your workload. Should I beg for it? Or you simply do not want to have
> your stamp on the patch? If yes, I can live with that but this playing
> hide and catch is not really a lot of fun.
> 

I noticed that the patch has not been sent to linux-next.git yet.
Please send to linux-next.git without my stamp on the patch.

[   44.863590] Out of memory: Kill process 1071 (a.out) score 865 or sacrifice child
[   44.867666] Killed process 1817 (a.out) total-vm:5244kB, anon-rss:1040kB, file-rss:0kB, shmem-rss:0kB
[   44.872176] oom_reaper: reaped process 1817 (a.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
[   91.698761] BUG: workqueue lockup - pool cpus=0 node=0 flags=0x0 nice=0 stuck for 48s!
[   91.702313] Showing busy workqueues and worker pools:
[   91.705011] workqueue events: flags=0x0
[   91.707482]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=8/256
[   91.710524]     pending: vmpressure_work_fn, vmw_fb_dirty_flush [vmwgfx], e1000_watchdog [e1000], vmstat_shepherd, free_work, mmdrop_async_fn, mmdrop_async_fn, check_corruption
[   91.717439] workqueue events_freezable: flags=0x4
[   91.720161]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
[   91.723304]     pending: vmballoon_work [vmw_balloon]
[   91.726167] workqueue events_power_efficient: flags=0x80
[   91.729139]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=4/256
[   91.732253]     pending: fb_flashcursor, gc_worker [nf_conntrack], neigh_periodic_work, neigh_periodic_work
[   91.736471] workqueue events_freezable_power_: flags=0x84
[   91.739546]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
[   91.742696]     in-flight: 2097:disk_events_workfn
[   91.745517] workqueue mm_percpu_wq: flags=0x8
[   91.748069]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=2/256
[   91.751182]     pending: drain_local_pages_wq BAR(1830), vmstat_update
[   91.754661] workqueue mpt_poll_0: flags=0x8
[   91.757161]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
[   91.759958]     pending: mpt_fault_reset_work [mptbase]
[   91.762696] workqueue xfs-data/sda1: flags=0xc
[   91.765353]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=3/256
[   91.768248]     pending: xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs]
[   91.771589] workqueue xfs-cil/sda1: flags=0xc
[   91.774009]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
[   91.776800]     pending: xlog_cil_push_work [xfs] BAR(703)
[   91.779464] workqueue xfs-reclaim/sda1: flags=0xc
[   91.782017]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
[   91.784599]     pending: xfs_reclaim_worker [xfs]
[   91.786930] workqueue xfs-sync/sda1: flags=0x4
[   91.789289]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
[   91.792075]     pending: xfs_log_worker [xfs]
[   91.794213] pool 0: cpus=0 node=0 flags=0x0 nice=0 hung=48s workers=4 idle: 52 13 5
[  121.906640] BUG: workqueue lockup - pool cpus=0 node=0 flags=0x0 nice=0 stuck for 78s!
[  121.909572] Showing busy workqueues and worker pools:
[  121.911703] workqueue events: flags=0x0
[  121.913531]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=8/256
[  121.915873]     pending: vmpressure_work_fn, vmw_fb_dirty_flush [vmwgfx], e1000_watchdog [e1000], vmstat_shepherd, free_work, mmdrop_async_fn, mmdrop_async_fn, check_corruption
[  121.921962] workqueue events_freezable: flags=0x4
[  121.924336]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
[  121.926941]     pending: vmballoon_work [vmw_balloon]
[  121.929226] workqueue events_power_efficient: flags=0x80
[  121.931554]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=4/256
[  121.933983]     pending: fb_flashcursor, gc_worker [nf_conntrack], neigh_periodic_work, neigh_periodic_work
[  121.937415] workqueue events_freezable_power_: flags=0x84
[  121.939719]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
[  121.942166]     in-flight: 2097:disk_events_workfn
[  121.944385] workqueue mm_percpu_wq: flags=0x8
[  121.946468]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=2/256
[  121.948975]     pending: drain_local_pages_wq BAR(1830), vmstat_update
[  121.951808] workqueue mpt_poll_0: flags=0x8
[  121.953864]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
[  121.956245]     pending: mpt_fault_reset_work [mptbase]
[  121.958505] workqueue xfs-data/sda1: flags=0xc
[  121.960514]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=3/256
[  121.962896]     pending: xfs_end_io [xfs], xfs_end_io [xfs], xfs_end_io [xfs]
[  121.965682] workqueue xfs-cil/sda1: flags=0xc
[  121.967639]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
[  121.970004]     pending: xlog_cil_push_work [xfs] BAR(703)
[  121.972285] workqueue xfs-reclaim/sda1: flags=0xc
[  121.974339]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
[  121.976779]     pending: xfs_reclaim_worker [xfs]
[  121.978926] workqueue xfs-sync/sda1: flags=0x4
[  121.980997]   pwq 0: cpus=0 node=0 flags=0x0 nice=0 active=1/256
[  121.983364]     pending: xfs_log_worker [xfs]
[  121.985326] pool 0: cpus=0 node=0 flags=0x0 nice=0 hung=78s workers=4 idle: 52 13 5
[  147.872620] sysrq: SysRq : Terminate All Tasks
