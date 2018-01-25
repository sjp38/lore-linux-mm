Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 11C8D800D8
	for <linux-mm@kvack.org>; Thu, 25 Jan 2018 03:35:19 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id t21so4050542wrb.14
        for <linux-mm@kvack.org>; Thu, 25 Jan 2018 00:35:19 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h12si3278572wre.272.2018.01.25.00.35.17
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 25 Jan 2018 00:35:17 -0800 (PST)
Date: Thu, 25 Jan 2018 09:35:16 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Possible deadlock in v4.14.15 contention on shrinker_rwsem in
 shrink_slab()
Message-ID: <20180125083516.GA22396@dhcp22.suse.cz>
References: <alpine.LRH.2.11.1801242349220.30642@mail.ewheeler.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LRH.2.11.1801242349220.30642@mail.ewheeler.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Wheeler <linux-mm@lists.ewheeler.net>
Cc: linux-mm@kvack.org, "Kirill A. Shutemov" <kirill@shutemov.name>, Minchan Kim <minchan@kernel.org>

[CC Kirill, Minchan]
On Wed 24-01-18 23:57:42, Eric Wheeler wrote:
> Hello all,
> 
> We are getting processes stuck with /proc/pid/stack listing the following:
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
> For some reason io_schedule is not coming back,

Is this a permanent state or does the holder eventually releases the
lock? It smells like somebody hasn't unlocked the shmem page. Tracking
those is a major PITA... :/

Do you remember the last good kernel?

> so shrinker_rwsem never 
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
> 
> I seem to be able to reproduce this somewhat reliably, it will likely be 
> stuck by tomorrow morning. Since it does seem to take a day to hang, I was 
> hoping to avoid a bisect and see if anyone has seen this behavior or knows 
> it to be fixed in 4.15-rc.
> 
> Note that we are using zram as our only swap device, but at the time that 
> it shrink_slab() failed to return, there was plenty of memory available 
> and no swap was in use.

Maybe something related with f80207727aac ("mm/memory.c: release locked
page in do_swap_page()")

> The machine is generally responsive, but `sync` will hang forever and our 
> only way out is `echo b > /proc/sysrq-trigger`.
> 
> Please suggest any additional information you might need for testing, and 
> I am happy to try patches.
> 
> Thank you for your help!
> 
> --
> Eric Wheeler

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
