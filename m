Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f169.google.com (mail-lb0-f169.google.com [209.85.217.169])
	by kanga.kvack.org (Postfix) with ESMTP id B3E426B0036
	for <linux-mm@kvack.org>; Thu, 24 Apr 2014 08:19:44 -0400 (EDT)
Received: by mail-lb0-f169.google.com with SMTP id n15so1961142lbi.0
        for <linux-mm@kvack.org>; Thu, 24 Apr 2014 05:19:43 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id bq4si772588lbb.64.2014.04.24.05.19.42
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Apr 2014 05:19:42 -0700 (PDT)
Message-ID: <5359015C.8050807@parallels.com>
Date: Thu, 24 Apr 2014 16:19:40 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
MIME-Version: 1.0
Subject: Re: Kernel crash triggered by dd to file with memcg, worst on btrfs
References: <20140416174210.GA11486@alpha.arachsys.com> <20140423215852.GA6651@dhcp22.suse.cz>
In-Reply-To: <20140423215852.GA6651@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Richard Davies <richard@arachsys.com>
Cc: Michal Hocko <mhocko@suse.cz>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-btrfs@vger.kernel.org

On 04/24/2014 01:58 AM, Michal Hocko wrote:
>> I have a test case in which I can often crash an entire machine by running
>> dd to a file with a memcg with relatively generous limits. This is
>> simplified from real world problems with heavy disk i/o inside containers.
>>
>> The crashes are easy to trigger when dding to create a file on btrfs. On
>> ext3, typically there is just an error in the kernel log, although
>> occasionally it also crashes.

I have a suspicion that crashes occur, because btrfs doesn't always
expect that kmalloc may fail. At least, when trying to reproduce
the bug, I got the following stack trace, which clearly points to
tree_mod_log_free_eb, where we panic if kmalloc doesn't succeed:

[  728.489378] kernel BUG at fs/btrfs/ctree.c:985!
[  728.489508] invalid opcode: 0000 [#1] SMP
[  728.489636] Modules linked in: btrfs raid6_pq xor xt_length xt_hl xt_tcpmss xt_TCPMSS iptable_mangle xt_multiport xt_limit xt_dscp fuse ebt_among ebtable_filter ebtables bridge stp llc binfmt_misc sbs ppdev sbshc parport_pc parport microcode pcspkr lpc_ich mfd_core e1000 raid1 virtio_balloon shpchp [last unloaded: speedstep_lib]
[  728.490739] CPU: 0 PID: 4053 Comm: dd Not tainted 3.15.0-rc2-mm1+ #160
[  728.490913] Hardware name: Parallels Software International Inc. Parallels Virtual Platform/Parallels Virtual Platform, BIOS 5.0.19471.922416 10/26/2007
[  728.491325] task: ffff880069fe9630 ti: ffff880003dd2000 task.ti: ffff880003dd2000
[  728.491544] RIP: 0010:[<ffffffffa013d497>]  [<ffffffffa013d497>] tree_mod_log_set_root_pointer+0x27/0x40 [btrfs]
[  728.491832] RSP: 0018:ffff880003dd3898  EFLAGS: 00010282
[  728.491975] RAX: 00000000fffffff4 RBX: ffff880076df8000 RCX: 0000000000000007
[  728.492203] RDX: 0000000000003dc0 RSI: ffff880069fe9ed8 RDI: 0000000000000000
[  728.492445] RBP: ffff880003dd3898 R08: ffffffff81d28d40 R09: ffff88007660dd00
[  728.492634] R10: 0000000000000003 R11: 0000000000000001 R12: ffff88006db2c1d0
[  728.492822] R13: ffff8800053d46e0 R14: 0000000000000000 R15: ffff88006db18000
[  728.493010] FS:  00007fa6df2cb700(0000) GS:ffff880079600000(0000) knlGS:0000000000000000
[  728.493239] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  728.493441] CR2: 00007fa6debea300 CR3: 000000004c064000 CR4: 00000000000006f0
[  728.493630] Stack:
[  728.493691]  ffff880003dd3948 ffffffffa013dc28 ffff880000000001 0000000000000000
[  728.493918]  0000000000000000 ffffffff8101c809 ffff880003dd38d8 ffffffff810b3a75
[  728.494146]  ffff8800053d46e0 00000000810cfed5 ffff880003dd3a08 0000000000000000
[  728.494469] Call Trace:
[  728.494551]  [<ffffffffa013dc28>] __btrfs_cow_block+0x478/0x530 [btrfs]
[  728.494733]  [<ffffffff8101c809>] ? sched_clock+0x9/0x10
[  728.494881]  [<ffffffff810b3a75>] ? local_clock+0x25/0x30
[  728.495033]  [<ffffffffa013e2de>] btrfs_cow_block+0x11e/0x1d0 [btrfs]
[  728.495230]  [<ffffffffa01407e3>] btrfs_search_slot+0x1f3/0x990 [btrfs]
[  728.495475]  [<ffffffff811d4fcd>] ? __memcg_kmem_get_cache+0x10d/0x290
[  728.495658]  [<ffffffffa01418c6>] btrfs_insert_empty_items+0x76/0xd0 [btrfs]
[  728.495857]  [<ffffffffa019c214>] btrfs_insert_orphan_item+0x64/0x90 [btrfs]
[  728.496053]  [<ffffffffa01678bf>] btrfs_orphan_add+0xef/0x1d0 [btrfs]
[  728.496267]  [<ffffffffa0173219>] btrfs_setattr+0x1f9/0x300 [btrfs]
[  728.496498]  [<ffffffff811fefc2>] notify_change+0x1c2/0x320
[  728.496679]  [<ffffffff811e81a4>] ? flush_old_exec+0x584/0x7d0
[  728.496837]  [<ffffffff811e0473>] do_truncate+0x63/0xa0
[  728.496980]  [<ffffffff811ef7c6>] do_last+0x646/0xec0
[  728.497122]  [<ffffffff811ee9eb>] ? link_path_walk+0x7b/0x810
[  728.497341]  [<ffffffff811f2cf2>] path_openat+0xc2/0x620
[  728.497501]  [<ffffffff810523b7>] ? kvm_clock_read+0x27/0x40
[  728.497654]  [<ffffffff8101c809>] ? sched_clock+0x9/0x10
[  728.497800]  [<ffffffff812002b1>] ? __alloc_fd+0x31/0x160
[  728.497946]  [<ffffffff811f3385>] do_filp_open+0x45/0xa0
[  728.498090]  [<ffffffff81200338>] ? __alloc_fd+0xb8/0x160
[  728.498272]  [<ffffffff811e0bb5>] do_sys_open+0x115/0x230
[  728.498439]  [<ffffffff810d07f5>] ? trace_hardirqs_on_caller+0x105/0x1d0
[  728.498623]  [<ffffffff81355fbe>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[  728.498796]  [<ffffffff811e0d09>] SyS_open+0x19/0x20
[  728.498933]  [<ffffffff816f23b9>] system_call_fastpath+0x16/0x1b
[  728.499094] Code: ff 0f 1f 00 55 48 8b 87 e8 01 00 00 41 89 d0 48 89 f2 48 8b 37 b9 50 00 00 00 48 89 e5 48 89 c7 e8 9f fc ff ff 85 c0 78 02 c9 c3 <0f> 0b 0f 1f 80 00 00 00 00 eb f7 66 66 66 66 66 2e 0f 1f 84 00
[  728.500178] RIP  [<ffffffffa013d497>] tree_mod_log_set_root_pointer+0x27/0x40 [btrfs]
[  728.500457]  RSP <ffff880003dd3898>

>> Ext3 kernel error log
>> =====================
>>
>> 17:20:05 kernel: SLUB: Unable to allocate memory on node -1 (gfp=0x20)
>> 17:20:05 kernel:  cache: ext4_extent_status(2:test), object size: 40, buffer size: 40, default order: 0, min order: 0
>> 17:20:05 kernel:  node 0: slabs: 375, objs: 38250, free: 0
>> 17:20:05 kernel:  node 1: slabs: 128, objs: 13056, free: 0
>> (many times)
> 
> This looks like the kmem limit has been reached and all the further
> allocation fails.

Michal is right. I guess we shouldn't show those warnings when kmalloc
fails due to memcg limit.

> 
>> Btrfs kernel console crash log
>> ==============================
>>
>> BUG: unable to handle kernel paging request at fffffffe36a55230
>> IP: [<ffffffff810f5055>] cpuacct_charge+0x35/0x58
>> PGD 1b5d067 PUD 0
>> Thread overran stack, or stack corrupted
> 
> This is really unexpected. Especially when the stack dumped bellow is
> not a usual suspect. This is a simple interrupt handler which handles
> hrtimer and this shouldn't overflow the stack...

This trace looks mysterious to me either. Usually on overrun we have a
very long call trace, which points to the guilty, but nothing similar
here. Perhaps, the stack page was corrupted by another thread.

> 
>> Oops: 0000 [#1] PREEMPT SMP
>> Modules linked in:
>> CPU: 6 PID: 5729 Comm: dd Not tainted 3.14.0-elastic #1
>> Hardware name: Supermicro H8DMT-IBX/H8DMT-IBX, BIOS 080014  10/17/2009
>> task: ffff88040a6fdac0 ti: ffff8800d69cc000 task.ti: ffff8800d69cc000
>> RIP: 0010:[<ffffffff810f5055>]  [<ffffffff810f5055>] cpuacct_charge+0x35/0x58
>> RSP: 0018:ffff880827d03d88  EFLAGS: 00010002
>> RAX: 000060f7d80032d0 RBX: ffff88040a6fdac0 RCX: ffffffffd69cc148
>> RDX: ffff88081191a180 RSI: 00000000000ebb99 RDI: ffff88040a6fdac0
>> RBP: ffff880827d03da8 R08: 0000000000000000 R09: ffff880827ffc348
>> R10: ffff880827ffc2a0 R11: ffff880827ffc340 R12: ffffffffd69cc148
>> R13: 00000000000ebb99 R14: fffffffffffebb99 R15: ffff88040a6fdac0
>> FS:  00007f508b54e6f0(0000) GS:ffff880827d00000(0000) knlGS:0000000000000000
>> CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
>> CR2: fffffffe36a55230 CR3: 000000080e9d2000 CR4: 00000000000007e0
>> Stack:
>>  0000000000000000 ffff88040a6fdac0 ffff880810fe2800 00000000000ebb99
>>  ffff880827d03dd8 ffffffff810ebbb3 ffff88040a6fdb28 ffff880810fe2800
>>  ffff880827d11bc0 0000000000000000 ffff880827d03e28 ffffffff810eeaaf
>> Call Trace:
>>  <IRQ>
>>  [<ffffffff810ebbb3>] update_curr+0xc2/0x11e
>>  [<ffffffff810eeaaf>] task_tick_fair+0x3d/0x631
>>  [<ffffffff810e5bb7>] scheduler_tick+0x57/0xba
>>  [<ffffffff81108eaf>] ? tick_nohz_handler+0xcf/0xcf
>>  [<ffffffff810cb73d>] update_process_times+0x55/0x66
>>  [<ffffffff81108f2b>] tick_sched_timer+0x7c/0x9b
>>  [<ffffffff810dd0d2>] __run_hrtimer+0x57/0xcc
>>  [<ffffffff810dd4c7>] hrtimer_interrupt+0xd0/0x1db
>>  [<ffffffff810e761b>] ? __vtime_account_system+0x2d/0x31
>>  [<ffffffff8105f8c1>] local_apic_timer_interrupt+0x53/0x58
>>  [<ffffffff81060475>] smp_apic_timer_interrupt+0x3e/0x51
>>  [<ffffffff8186299d>] apic_timer_interrupt+0x6d/0x80
>>  <EOI>
>> Code: 54 53 48 89 fb 48 83 ec 08 48 8b 47 08 4c 63 60 18 e8 84 8c 00 00 48 8b 83 a0 06 00 00 4c 89 e1 48 8b 50 48 48 8b 82 80 00 00 00 <48> 03 04 cd f0 47 bf 81 4c 01 28 48 8b 52 40 48 85 d2 75 e5 e8
>> RIP  [<ffffffff810f5055>] cpuacct_charge+0x35/0x58
>>  RSP <ffff880827d03d88>
>> CR2: fffffffe36a55230
>> ---[ end trace b449af50c3a0711c ]---
>> Kernel panic - not syncing: Fatal exception in interrupt
>> Kernel Offset: 0x0 from 0xffffffff81000000 (relocation range: 0xffffffff80000000-0xffffffff9fffffff)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
