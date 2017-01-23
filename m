Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 910CE6B0038
	for <linux-mm@kvack.org>; Mon, 23 Jan 2017 16:51:13 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id 14so213874377pgg.4
        for <linux-mm@kvack.org>; Mon, 23 Jan 2017 13:51:13 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id c1si16849347pld.50.2017.01.23.13.51.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Jan 2017 13:51:12 -0800 (PST)
Date: Mon, 23 Jan 2017 13:51:11 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bug 192981] New: page allocation stalls
Message-Id: <20170123135111.13ac3e47110de10a4bd503ef@linux-foundation.org>
In-Reply-To: <bug-192981-27@https.bugzilla.kernel.org/>
References: <bug-192981-27@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: bugzilla-daemon@bugzilla.kernel.org, apolyakov@beget.ru



(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

A 2100 second page allocation stall!


On Fri, 20 Jan 2017 15:14:13 +0000 bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=192981
> 
>             Bug ID: 192981
>            Summary: page allocation stalls
>            Product: Memory Management
>            Version: 2.5
>     Kernel Version: 4.9
>           Hardware: x86-64
>                 OS: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Page Allocator
>           Assignee: akpm@linux-foundation.org
>           Reporter: apolyakov@beget.ru
>         Regression: No
> 
> Created attachment 252621
>   --> https://bugzilla.kernel.org/attachment.cgi?id=252621&action=edit
> netconsole log with page allocation stalls
> 
> We have been experiencing page allocation stalls regularly on our machines used
> as backup servers (many disks, mostly running rsync and rm).
> 
> A notable one (2102516ms):
> 
> 2017-01-17T11:08:33.754562+03:00 storage8 [335170.452601] rsync: 
> 2017-01-17T11:08:33.754574+03:00 page allocation stalls for 2102516ms, order:0
> 2017-01-17T11:08:33.754825+03:00 storage8 ,
> mode:0x26040d0(GFP_TEMPORARY|__GFP_COMP|__GFP_NOTRACK)
> 2017-01-17T11:08:33.755094+03:00 storage8 [335170.452896] CPU: 2 PID: 20383
> Comm: rsync Tainted: G           O    4.9.0-0-beget-vanilla #1
> 2017-01-17T11:08:33.755337+03:00 storage8 [335170.453156] Hardware name:
> Supermicro X8DTL/X8DTL, BIOS 2.1b       11/16/2012
> 2017-01-17T11:08:33.755379+03:00 storage8 [335170.453414]  0000000000000000
> 2017-01-17T11:08:33.755379+03:00 storage8  ffffffff92441e0b
> 2017-01-17T11:08:33.755393+03:00 storage8  ffff8c4b0f30f430
> 2017-01-17T11:08:33.755484+03:00 storage8  0000000000000001
> 2017-01-17T11:08:33.755600+03:00 storage8  
> 2017-01-17T11:08:33.755603+03:00 storage8 [335170.453681]  ffffffff92c3d1f8
> 2017-01-17T11:08:33.755643+03:00 storage8  ffffffff92189594
> 2017-01-17T11:08:33.755648+03:00 storage8  ffff8c4b0f315088
> 2017-01-17T11:08:33.755754+03:00 storage8  026040d0026040d0
> 2017-01-17T11:08:33.755874+03:00 storage8  
> 2017-01-17T11:08:33.755874+03:00 storage8 [335170.453951]  0000000000000020
> 2017-01-17T11:08:33.755880+03:00 storage8  0000000000000010
> 2017-01-17T11:08:33.755913+03:00 storage8  ffffa449d15cb7f8
> 2017-01-17T11:08:33.756024+03:00 storage8  ffffa449d15cb7a8
> 2017-01-17T11:08:33.756163+03:00 storage8  
> 2017-01-17T11:08:33.756278+03:00 storage8 [335170.454216] Call Trace:
> 2017-01-17T11:08:33.756401+03:00 storage8 [335170.454347]  [<ffffffff92441e0b>]
> ? dump_stack+0x47/0x5c
> 2017-01-17T11:08:33.756537+03:00 storage8 [335170.454479]  [<ffffffff92189594>]
> ? warn_alloc+0x134/0x150
> 2017-01-17T11:08:33.756677+03:00 storage8 [335170.454612]  [<ffffffff92189f2d>]
> ? __alloc_pages_nodemask+0x90d/0xdb0
> 2017-01-17T11:08:33.756808+03:00 storage8 [335170.454753]  [<ffffffff923a5da4>]
> ? _xfs_trans_bjoin+0xe4/0x110
> 2017-01-17T11:08:33.756955+03:00 storage8 [335170.454892]  [<ffffffff921d76fa>]
> ? alloc_pages_current+0x9a/0x120
> 2017-01-17T11:08:33.757096+03:00 storage8 [335170.455027]  [<ffffffff921de440>]
> ? new_slab+0x550/0x5f0
> 2017-01-17T11:08:33.757218+03:00 storage8 [335170.455162]  [<ffffffff921df2eb>]
> ? ___slab_alloc.isra.59+0x3db/0x500
> 2017-01-17T11:08:33.757346+03:00 storage8 [335170.455297]  [<ffffffff923a683a>]
> ? xfs_trans_brelse+0x1aa/0x270
> 2017-01-17T11:08:33.757489+03:00 storage8 [335170.455427]  [<ffffffff921f4612>]
> ? memcg_kmem_get_cache+0x72/0x170
> 2017-01-17T11:08:33.757632+03:00 storage8 [335170.455567]  [<ffffffff92447837>]
> ? __radix_tree_create+0xa7/0x320
> 2017-01-17T11:08:33.757762+03:00 storage8 [335170.455706]  [<ffffffff92200be5>]
> ? __slab_alloc.isra.60+0xe/0x12
> 2017-01-17T11:08:33.757897+03:00 storage8 [335170.455842]  [<ffffffff921df5b0>]
> ? kmem_cache_alloc+0x1a0/0x1b0
> 2017-01-17T11:08:33.758034+03:00 storage8 [335170.455978]  [<ffffffff9221b746>]
> ? __d_alloc+0x26/0x1c0
> 2017-01-17T11:08:33.758160+03:00 storage8 [335170.456108]  [<ffffffff9221bb67>]
> ? d_alloc+0x17/0x80
> 2017-01-17T11:08:33.758290+03:00 storage8 [335170.456236]  [<ffffffff9221bdf1>]
> ? d_alloc_parallel+0x31/0x4b0
> 2017-01-17T11:08:33.758429+03:00 storage8 [335170.456370]  [<ffffffff9220f836>]
> ? lookup_fast+0x56/0x2f0
> 2017-01-17T11:08:33.758579+03:00 storage8 [335170.456505]  [<ffffffff923804de>]
> ? xfs_iunlock+0x17e/0x210
> 2017-01-17T11:08:33.758694+03:00 storage8 [335170.456635]  [<ffffffff922237f2>]
> ? legitimize_mnt+0x12/0x40
> 2017-01-17T11:08:33.758818+03:00 storage8 [335170.456770]  [<ffffffff9220d8f0>]
> ? lookup_slow+0x80/0x170
> 2017-01-17T11:08:33.758955+03:00 storage8 [335170.456897]  [<ffffffff9220fd08>]
> ? walk_component+0x1a8/0x270
> 2017-01-17T11:08:33.759086+03:00 storage8 [335170.457024]  [<ffffffff92210398>]
> ? path_lookupat+0x48/0xf0
> 2017-01-17T11:08:33.759200+03:00 storage8 [335170.457153]  [<ffffffff92212e75>]
> ? filename_lookup+0xb5/0x190
> 2017-01-17T11:08:33.759336+03:00 storage8 [335170.457282]  [<ffffffff92474992>]
> ? strncpy_from_user+0x42/0x140
> 2017-01-17T11:08:33.759462+03:00 storage8 [335170.457411]  [<ffffffff9221305b>]
> ? getname_flags+0x7b/0x200
> 2017-01-17T11:08:33.759593+03:00 storage8 [335170.457538]  [<ffffffff92208b66>]
> ? vfs_fstatat+0x46/0x90
> 2017-01-17T11:08:33.759719+03:00 storage8 [335170.457666]  [<ffffffff9221aaf4>]
> ? dput+0x34/0x200
> 2017-01-17T11:08:33.759859+03:00 storage8 [335170.457793]  [<ffffffff92208d47>]
> ? SyS_newlstat+0x17/0x30
> 2017-01-17T11:08:33.759977+03:00 storage8 [335170.457923]  [<ffffffff9282b7a0>]
> ? entry_SYSCALL_64_fastpath+0x13/0x94
> 
> 
> # sysctl vm
> vm.admin_reserve_kbytes = 1048576
> vm.block_dump = 0
> error: permission denied on key 'vm.compact_memory'
> vm.compact_unevictable_allowed = 1
> vm.dirty_background_bytes = 0
> vm.dirty_background_ratio = 1
> vm.dirty_bytes = 0
> vm.dirty_expire_centisecs = 1000
> vm.dirty_ratio = 1
> vm.dirty_writeback_centisecs = 100
> vm.dirtytime_expire_seconds = 43200
> vm.drop_caches = 0
> vm.extfrag_threshold = 500
> vm.hugepages_treat_as_movable = 0
> vm.hugetlb_shm_group = 0
> vm.laptop_mode = 0
> vm.legacy_va_layout = 0
> vm.lowmem_reserve_ratio = 128   128     16
> vm.max_map_count = 65530
> vm.memory_failure_early_kill = 0
> vm.memory_failure_recovery = 1
> vm.min_free_kbytes = 4194304
> vm.min_slab_ratio = 1
> vm.min_unmapped_ratio = 1
> vm.mmap_min_addr = 65536
> vm.mmap_rnd_bits = 28
> vm.nr_hugepages = 0
> vm.nr_hugepages_mempolicy = 0
> vm.nr_overcommit_hugepages = 0
> vm.nr_pdflush_threads = 0
> vm.numa_zonelist_order = default
> vm.oom_dump_tasks = 1
> vm.oom_kill_allocating_task = 0
> vm.overcommit_kbytes = 0
> vm.overcommit_memory = 1
> vm.overcommit_ratio = 50
> vm.page-cluster = 3
> vm.panic_on_oom = 0
> vm.percpu_pagelist_fraction = 0
> vm.stat_interval = 1
> error: permission denied on key 'vm.stat_refresh'
> vm.swappiness = 0
> vm.user_reserve_kbytes = 131072
> vm.vfs_cache_pressure = 200
> vm.watermark_scale_factor = 100
> vm.zone_reclaim_mode = 7
> 
> # free -m
>              total       used       free     shared    buffers     cached
> Mem:         96646      46330      50315          0      25529       1228
> -/+ buffers/cache:      19572      77073
> Swap:            0          0          0
> 
> (Yes, we don't have any swap configured)
> 
> On this particular one we have 56 disks, using both XFS and EXT4. I attach full
> netconsole log for 18/01/2017. You can see there that we run drop_caches
> regularly as it helps to keep the machine alive.
> 
> Since then we've also tried mounting filesystems with sync flag to avoid
> writeback and it seems to have helped a lot (full day without stalls).
> 
> -- 
> You are receiving this mail because:
> You are the assignee for the bug.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
