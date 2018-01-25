Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1EE7E800D8
	for <linux-mm@kvack.org>; Wed, 24 Jan 2018 21:04:44 -0500 (EST)
Received: by mail-oi0-f71.google.com with SMTP id x9so830810oie.2
        for <linux-mm@kvack.org>; Wed, 24 Jan 2018 18:04:44 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id 42si1393040otk.546.2018.01.24.18.04.42
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 24 Jan 2018 18:04:42 -0800 (PST)
Message-Id: <201801250204.w0P24NKZ033992@www262.sakura.ne.jp>
Subject: Re: [PATCH 1/2] mm,vmscan: Kill global shrinker lock.
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
MIME-Version: 1.0
Date: Thu, 25 Jan 2018 11:04:23 +0900
References: <20171115140020.GA6771@cmpxchg.org> <20171115141113.2nw4c4nejermhckb@dhcp22.suse.cz>
In-Reply-To: <20171115141113.2nw4c4nejermhckb@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@lists.ewheeler.net
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Minchan Kim <minchan@kernel.org>, Huang Ying <ying.huang@intel.com>, Mel Gorman <mgorman@techsingularity.net>, Vladimir Davydov <vdavydov.dev@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Shakeel Butt <shakeelb@google.com>, Greg Thelen <gthelen@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> On Wed 15-11-17 09:00:20, Johannes Weiner wrote:
> > In any case, Minchan's lock breaking seems way preferable over that
> > level of headscratching complexity for an unusual case like Shakeel's.
> 
> agreed! I would go the more complex way only if it turns out that early
> break out causes some real problems.
> 

Eric Wheeler wrote (at http://lkml.kernel.org/r/alpine.LRH.2.11.1801242349220.30642@mail.ewheeler.net ):
> Hello all,
> 
> We are getting processes stuck with /proc/pid/stack listing the following:

Yes, I think that this is a silent OOM lockup.

> 
> [<ffffffffac0cd0d2>] io_schedule+0x12/0x40
> [<ffffffffac1b4695>] __lock_page+0x105/0x150
> [<ffffffffac1b4dc1>] pagecache_get_page+0x161/0x210
> [<ffffffffac1d4ab4>] shmem_unused_huge_shrink+0x334/0x3f0
> [<ffffffffac251546>] super_cache_scan+0x176/0x180
> [<ffffffffac1cb6c5>] shrink_slab+0x275/0x460
> [<ffffffffac1d0b8e>] shrink_node+0x10e/0x320
> [<ffffffffac1d0f3d>] node_reclaim+0x19d/0x250
> [<ffffffffac1be0aa>] get_page_from_freelist+0x16a/0xac0
> [<ffffffffac1bed87>] __alloc_pages_nodemask+0x107/0x290
> [<ffffffffac06dbc3>] pte_alloc_one+0x13/0x40
> [<ffffffffac1ef329>] __pte_alloc+0x19/0x100
> [<ffffffffac1f17b8>] alloc_set_pte+0x468/0x4c0
> [<ffffffffac1f184a>] finish_fault+0x3a/0x70
> [<ffffffffac1f369a>] __handle_mm_fault+0x94a/0x1190
> [<ffffffffac1f3fa4>] handle_mm_fault+0xc4/0x1d0
> [<ffffffffac0682a3>] __do_page_fault+0x253/0x4d0
> [<ffffffffac068553>] do_page_fault+0x33/0x120
> [<ffffffffac8019dc>] page_fault+0x4c/0x60
> 
> 
> For some reason io_schedule is not coming back, so shrinker_rwsem never 
> gets an up_read. When this happens, other processes like libvirt get stuck 
> trying to start VMs with the /proc/pid/stack of libvirtd looking like so, 
> while register_shrinker waits for shrinker_rwsem to be released:
> 
> [<ffffffffac7538d3>] call_rwsem_down_write_failed+0x13/0x20
> [<ffffffffac1cb985>] register_shrinker+0x45/0xa0
> [<ffffffffac250f68>] sget_userns+0x468/0x4a0
> [<ffffffffac25106a>] mount_nodev+0x2a/0xa0
> [<ffffffffac251be4>] mount_fs+0x34/0x150
> [<ffffffffac2701f2>] vfs_kern_mount+0x62/0x120
> [<ffffffffac272a0e>] do_mount+0x1ee/0xc50
> [<ffffffffac27377e>] SyS_mount+0x7e/0xd0
> [<ffffffffac003831>] do_syscall_64+0x61/0x1a0
> [<ffffffffac80012c>] entry_SYSCALL64_slow_path+0x25/0x25
> [<ffffffffffffffff>] 0xffffffffffffffff
> 

If io_schedule() depends on somebody else's memory allocation request, that
somebody else will call shrink_slab() and down_read_trylock(&shrinker_rwsem)
will fail without making progress. This means that that somebody else will
forever retry as long as should_continue_reclaim() returns true.

I don't know what is causing should_continue_reclaim() to return true, but
nobody will be able to reclaim memory because down_read_trylock(&shrinker_rwsem)
continues failing without making progress.

> 
> I seem to be able to reproduce this somewhat reliably, it will likely be 
> stuck by tomorrow morning. Since it does seem to take a day to hang, I was 
> hoping to avoid a bisect and see if anyone has seen this behavior or knows 
> it to be fixed in 4.15-rc.

I think that this problem is not yet fixed in linux-next.git .

> 
> Note that we are using zram as our only swap device, but at the time that 
> it shrink_slab() failed to return, there was plenty of memory available 
> and no swap was in use.
> 
> The machine is generally responsive, but `sync` will hang forever and our 
> only way out is `echo b > /proc/sysrq-trigger`.
> 
> Please suggest any additional information you might need for testing, and 
> I am happy to try patches.
> 
> Thank you for your help!

Pretending we will be able to make progress

	if (!down_read_trylock(&shrinker_rwsem)) {
		/*
		 * If we would return 0, our callers would understand that we
		 * have nothing else to shrink and give up trying. By returning
		 * 1 we keep it going and assume we'll be able to shrink next
		 * time.
		 */
		freed = 1;
		goto out;
	}

can work only if do_shrink_slab() does not depend on somebody else's
memory allocation. I think we should kill shrinker_rwsem assumption.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
