Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id F1F056B0033
	for <linux-mm@kvack.org>; Mon,  6 Nov 2017 15:49:17 -0500 (EST)
Received: by mail-lf0-f72.google.com with SMTP id f31so3187384lfi.3
        for <linux-mm@kvack.org>; Mon, 06 Nov 2017 12:49:17 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k67sor2175871lfi.65.2017.11.06.12.49.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 06 Nov 2017 12:49:12 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171102150600.yyy2amjaeu2mu2u4@dhcp22.suse.cz>
References: <20171019035641.GB23773@intel.com> <CABXGCsPL0pUHo_M-KxB3mabfdGMSHPC0uchLBBt0JCzF2BYBww@mail.gmail.com>
 <20171020064305.GA13688@intel.com> <20171020091239.cfwapdkx5g7afyp7@dhcp22.suse.cz>
 <CABXGCsMZ0hFFJyPU2cu+JDLHZ+5eO5i=8FOv71biwpY5neyofA@mail.gmail.com>
 <20171024200639.2pyxkw2cucwxrtlb@dhcp22.suse.cz> <CABXGCsPukABMx40dGz7NSjKsWVsz_USFFeHdEY-ZMdgRLCfuwQ@mail.gmail.com>
 <CABXGCsMVsn44xHH6SZxb6jrKv4S_GQFSqHNddAyDKOqNEpP6Ow@mail.gmail.com>
 <a6eab5f2-7ce5-d4fc-5524-0f6b3449742d@I-love.SAKURA.ne.jp>
 <20171102150120.fb5qgrvmebbup64g@dhcp22.suse.cz> <20171102150600.yyy2amjaeu2mu2u4@dhcp22.suse.cz>
From: =?UTF-8?B?0JzQuNGF0LDQuNC7INCT0LDQstGA0LjQu9C+0LI=?= <mikhail.v.gavrilov@gmail.com>
Date: Tue, 7 Nov 2017 01:48:54 +0500
Message-ID: <CABXGCsOzaorL0wKZFYRFKR7RSnUL+7=vspE36sFTENoimsJGSw@mail.gmail.com>
Subject: Re: swapper/0: page allocation failure: order:0, mode:0x1204010(GFP_NOWAIT|__GFP_COMP|__GFP_RECLAIMABLE|__GFP_NOTRACK),
 nodemask=(null)
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, "Du, Changbin" <changbin.du@intel.com>, linux-mm@kvack.org

> I can't tell whether enabling more tracepoints gives us some clue. But
> your system might be merely overloaded.

Ok, system may be merely overloaded, but in this case expected that
user experience should not getting worse. Switching between tasks
(showing activities in gnome shell) should be such fast as after
reboot in ideal. I am understand that is not easy and depends at many
factors. But I notice that every new Linux release working better also
at overloaded case. And it's very nice. So if five year ago using swap
was impossible because system was becoming  fully unresponsible. At
now I see freezes not not exceeding 10 seconds. I hopes thats working
on this warning messages can make Linux better.

> Your system is hosting a lot of
> processes including QEMU and Chrome on 8 CPUs + 32GB RAM + 64GB swap and
> nearly a half of swap is in use, isn't it?

Yes, right.

> Anyway, this allocation stall warning mechanism is about to be removed
> ( http://lkml.kernel.org/r/1509017339-4802-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp ).

It means this warning was useless?

>
> That being said, though, it makes sense to double check whether we
> cond_resched sufficiently because being stuck for 10s while a handful
> number of processes is reclaiming sounds still too much. Maybe there is
> more than just the reclaim going on. This would require a deeper
> inspection of the trace data and maybe even gather other tracepoints.
> I am sorry but I cannot promis I will find time to look at this anytime
> soon.

Don't hesitate trouble me in further. I am wonder to know what else
tracepoint needed enable for deeper debugging.

Found another easy reproduction case:
It is enough increase min_free_kbytes on working system for get
[swapper/0: page allocation failure: order:0,
mode:0x1284020(GFP_ATOMIC|__GFP_COMP|__GFP_NOTRACK), nodemask=(null)]
message.
It's normal?


# echo 2097152 > /proc/sys/vm/min_free_kbytes

[84072.743874] swapper/0: page allocation failure: order:0,
mode:0x1284020(GFP_ATOMIC|__GFP_COMP|__GFP_NOTRACK), nodemask=(null)
[84072.743882] swapper/0 cpuset=/ mems_allowed=0-1023
[84072.744108] CPU: 0 PID: 0 Comm: swapper/0 Not tainted
4.13.11-300.fc27.x86_64+debug #1
[84072.744109] Hardware name: Gigabyte Technology Co., Ltd.
Z87M-D3H/Z87M-D3H, BIOS F11 08/12/2014
[84072.744111] Call Trace:
[84072.744112]  <IRQ>
[84072.744117]  dump_stack+0x8e/0xd6
[84072.744121]  warn_alloc+0x114/0x1c0
[84072.744128]  __alloc_pages_slowpath+0x104b/0x1100
[84072.744138]  ? _raw_spin_unlock_irqrestore+0x5b/0x60
[84072.744144]  __alloc_pages_nodemask+0x351/0x3e0
[84072.744147]  ? trace_hardirqs_off+0xd/0x10
[84072.744153]  alloc_pages_current+0x6a/0xe0
[84072.744157]  new_slab+0x440/0x740
[84072.744159]  ? __slab_alloc+0x51/0x90
[84072.744164]  ___slab_alloc+0x3eb/0x5e0
[84072.744169]  ? __build_skb+0x2b/0xf0
[84072.744175]  ? __build_skb+0x2b/0xf0
[84072.744177]  __slab_alloc+0x51/0x90
[84072.744179]  ? __slab_alloc+0x51/0x90
[84072.744183]  kmem_cache_alloc+0x235/0x2e0
[84072.744184]  ? __build_skb+0x2b/0xf0
[84072.744187]  __build_skb+0x2b/0xf0
[84072.744190]  __napi_alloc_skb+0xa1/0xf0
[84072.744195]  rtl8169_poll+0x1fa/0x6b0 [r8169]
[84072.744202]  net_rx_action+0x15e/0x4c0
[84072.744209]  __do_softirq+0xce/0x4ed
[84072.744213]  ? sched_clock+0x9/0x10
[84072.744214]  ? sched_clock+0x9/0x10
[84072.744220]  irq_exit+0x10f/0x120
[84072.744222]  do_IRQ+0x92/0x110
[84072.744226]  common_interrupt+0x9d/0x9d
[84072.744229] RIP: 0010:cpuidle_enter_state+0x135/0x390
[84072.744230] RSP: 0018:ffffffffbce03dc0 EFLAGS: 00000206 ORIG_RAX:
ffffffffffffff9c
[84072.744233] RAX: ffffffffbce18500 RBX: 00004c76b6070bca RCX: 0000000000000000
[84072.744234] RDX: ffffffffbce18500 RSI: 0000000000000001 RDI: ffffffffbce18500
[84072.744235] RBP: ffffffffbce03e00 R08: 000000000000006f R09: 0000000000000000
[84072.744237] R10: 0000000000000000 R11: 0000000000000000 R12: ffff8fc5fede5e00
[84072.744238] R13: 0000000000000000 R14: 0000000000000001 R15: ffffffffbd063678
[84072.744239]  </IRQ>
[84072.744250]  cpuidle_enter+0x17/0x20
[84072.744253]  call_cpuidle+0x23/0x40
[84072.744255]  do_idle+0x194/0x1f0
[84072.744259]  cpu_startup_entry+0x73/0x80
[84072.744262]  rest_init+0xd5/0xe0
[84072.744266]  start_kernel+0x4f4/0x515
[84072.744270]  ? early_idt_handler_array+0x120/0x120
[84072.744272]  x86_64_start_reservations+0x24/0x26
[84072.744274]  x86_64_start_kernel+0x13e/0x161
[84072.744279]  secondary_startup_64+0x9f/0x9f
[84072.744347] SLUB: Unable to allocate memory on node -1,
gfp=0x1080020(GFP_ATOMIC)
[84072.744349]   cache: kmalloc-256, object size: 256, buffer size:
256, default order: 1, min order: 0
[84072.744351]   node 0: slabs: 237, objs: 7568, free: 0
[84073.260096] swapper/0: page allocation failure: order:0,
mode:0x1284020(GFP_ATOMIC|__GFP_COMP|__GFP_NOTRACK), nodemask=(null)
[84073.260104] swapper/0 cpuset=/ mems_allowed=0-1023
[84073.260115] CPU: 0 PID: 0 Comm: swapper/0 Not tainted
4.13.11-300.fc27.x86_64+debug #1
[84073.260116] Hardware name: Gigabyte Technology Co., Ltd.
Z87M-D3H/Z87M-D3H, BIOS F11 08/12/2014
[84073.260118] Call Trace:
[84073.260120]  <IRQ>
[84073.260125]  dump_stack+0x8e/0xd6
[84073.260129]  warn_alloc+0x114/0x1c0
[84073.260136]  __alloc_pages_slowpath+0x104b/0x1100
[84073.260146]  ? _raw_spin_unlock_irqrestore+0x5b/0x60
[84073.260152]  __alloc_pages_nodemask+0x351/0x3e0
[84073.260158]  alloc_pages_current+0x6a/0xe0
[84073.260162]  new_slab+0x440/0x740
[84073.260164]  ? __slab_alloc+0x51/0x90
[84073.260170]  ___slab_alloc+0x3eb/0x5e0
[84073.260174]  ? __build_skb+0x2b/0xf0
[84073.260180]  ? __build_skb+0x2b/0xf0
[84073.260182]  __slab_alloc+0x51/0x90
[84073.260184]  ? __slab_alloc+0x51/0x90
[84073.260188]  kmem_cache_alloc+0x235/0x2e0
[84073.260189]  ? __build_skb+0x2b/0xf0
[84073.260193]  __build_skb+0x2b/0xf0
[84073.260195]  __napi_alloc_skb+0xa1/0xf0
[84073.260201]  rtl8169_poll+0x1fa/0x6b0 [r8169]
[84073.260208]  net_rx_action+0x15e/0x4c0
[84073.260215]  __do_softirq+0xce/0x4ed
[84073.260219]  ? sched_clock+0x9/0x10
[84073.260221]  ? sched_clock+0x9/0x10
[84073.260226]  irq_exit+0x10f/0x120
[84073.260229]  do_IRQ+0x92/0x110
[84073.260232]  common_interrupt+0x9d/0x9d
[84073.260235] RIP: 0010:cpuidle_enter_state+0x135/0x390
[84073.260237] RSP: 0018:ffffffffbce03dc0 EFLAGS: 00000202 ORIG_RAX:
ffffffffffffff9c
[84073.260239] RAX: ffffffffbce18500 RBX: 00004c76d4cd7a3b RCX: 0000000000000000
[84073.260240] RDX: ffffffffbce18500 RSI: 0000000000000001 RDI: ffffffffbce18500
[84073.260241] RBP: ffffffffbce03e00 R08: 0000000000000076 R09: 0000000000000000
[84073.260243] R10: 0000000000000000 R11: 0000000000000000 R12: ffff8fc5fede5e00
[84073.260244] R13: 0000000000000000 R14: 0000000000000002 R15: ffffffffbd0636d8
[84073.260246]  </IRQ>
[84073.260256]  cpuidle_enter+0x17/0x20
[84073.260260]  call_cpuidle+0x23/0x40
[84073.260262]  do_idle+0x194/0x1f0
[84073.260266]  cpu_startup_entry+0x73/0x80
[84073.260269]  rest_init+0xd5/0xe0
[84073.260272]  start_kernel+0x4f4/0x515
[84073.260276]  ? early_idt_handler_array+0x120/0x120
[84073.260278]  x86_64_start_reservations+0x24/0x26
[84073.260280]  x86_64_start_kernel+0x13e/0x161
[84073.260285]  secondary_startup_64+0x9f/0x9f
[84073.260294] SLUB: Unable to allocate memory on node -1,
gfp=0x1080020(GFP_ATOMIC)
[84073.260296]   cache: kmalloc-256, object size: 256, buffer size:
256, default order: 1, min order: 0
[84073.260297]   node 0: slabs: 236, objs: 7552, free: 0
[84074.853506] swapper/0: page allocation failure: order:0,
mode:0x1284020(GFP_ATOMIC|__GFP_COMP|__GFP_NOTRACK), nodemask=(null)
[84074.853513] swapper/0 cpuset=/ mems_allowed=0-1023
[84074.853525] CPU: 0 PID: 0 Comm: swapper/0 Not tainted
4.13.11-300.fc27.x86_64+debug #1
[84074.853526] Hardware name: Gigabyte Technology Co., Ltd.
Z87M-D3H/Z87M-D3H, BIOS F11 08/12/2014
[84074.853527] Call Trace:
[84074.853529]  <IRQ>
[84074.853535]  dump_stack+0x8e/0xd6
[84074.853539]  warn_alloc+0x114/0x1c0
[84074.853546]  __alloc_pages_slowpath+0x104b/0x1100
[84074.853557]  ? _raw_spin_unlock_irqrestore+0x5b/0x60
[84074.853563]  __alloc_pages_nodemask+0x351/0x3e0
[84074.853566]  ? trace_hardirqs_off+0xd/0x10
[84074.853571]  alloc_pages_current+0x6a/0xe0
[84074.853576]  new_slab+0x440/0x740
[84074.853578]  ? __slab_alloc+0x51/0x90
[84074.853583]  ___slab_alloc+0x3eb/0x5e0
[84074.853588]  ? __build_skb+0x2b/0xf0
[84074.853594]  ? __build_skb+0x2b/0xf0
[84074.853596]  __slab_alloc+0x51/0x90
[84074.853598]  ? __slab_alloc+0x51/0x90
[84074.853602]  kmem_cache_alloc+0x235/0x2e0
[84074.853604]  ? __build_skb+0x2b/0xf0
[84074.853607]  __build_skb+0x2b/0xf0
[84074.853609]  __napi_alloc_skb+0xa1/0xf0
[84074.853615]  rtl8169_poll+0x1fa/0x6b0 [r8169]
[84074.853623]  net_rx_action+0x15e/0x4c0
[84074.853630]  __do_softirq+0xce/0x4ed
[84074.853634]  ? sched_clock+0x9/0x10
[84074.853636]  ? sched_clock+0x9/0x10
[84074.853641]  irq_exit+0x10f/0x120
[84074.853644]  do_IRQ+0x92/0x110
[84074.853647]  common_interrupt+0x9d/0x9d
[84074.853651] RIP: 0010:cpuidle_enter_state+0x135/0x390
[84074.853652] RSP: 0018:ffffffffbce03dc0 EFLAGS: 00000202 ORIG_RAX:
ffffffffffffff9c
[84074.853655] RAX: ffffffffbce18500 RBX: 00004c7733c6fafd RCX: 0000000000000000
[84074.853656] RDX: ffffffffbce18500 RSI: 0000000000000001 RDI: ffffffffbce18500
[84074.853657] RBP: ffffffffbce03e00 R08: 0000000000000070 R09: 0000000000000000
[84074.853658] R10: 0000000000000000 R11: 0000000000000000 R12: ffff8fc5fede5e00
[84074.853659] R13: 0000000000000000 R14: 0000000000000002 R15: ffffffffbd0636d8
[84074.853661]  </IRQ>
[84074.853672]  cpuidle_enter+0x17/0x20
[84074.853675]  call_cpuidle+0x23/0x40
[84074.853677]  do_idle+0x194/0x1f0
[84074.853682]  cpu_startup_entry+0x73/0x80
[84074.853685]  rest_init+0xd5/0xe0
[84074.853689]  start_kernel+0x4f4/0x515
[84074.853692]  ? early_idt_handler_array+0x120/0x120
[84074.853695]  x86_64_start_reservations+0x24/0x26
[84074.853697]  x86_64_start_kernel+0x13e/0x161
[84074.853702]  secondary_startup_64+0x9f/0x9f
[84074.853711] SLUB: Unable to allocate memory on node -1,
gfp=0x1080020(GFP_ATOMIC)
[84074.853713]   cache: kmalloc-256, object size: 256, buffer size:
256, default order: 1, min order: 0
[84074.853714]   node 0: slabs: 236, objs: 7552, free: 0
[84082.084428] TaskSchedulerFo: page allocation stalls for 10133ms,
order:0, mode:0x1400040(GFP_NOFS), nodemask=(null)
[84082.084528] TaskSchedulerFo cpuset=/ mems_allowed=0
[84082.084785] CPU: 1 PID: 5482 Comm: TaskSchedulerFo Not tainted
4.13.11-300.fc27.x86_64+debug #1
[84082.084788] Hardware name: Gigabyte Technology Co., Ltd.
Z87M-D3H/Z87M-D3H, BIOS F11 08/12/2014
[84082.084790] Call Trace:
[84082.084796]  dump_stack+0x8e/0xd6
[84082.084801]  warn_alloc+0x114/0x1c0
[84082.084816]  __alloc_pages_slowpath+0x90f/0x1100
[84082.084826]  ? ___slab_alloc+0x228/0x5e0
[84082.084846]  __alloc_pages_nodemask+0x351/0x3e0
[84082.084857]  alloc_pages_current+0x6a/0xe0
[84082.084897]  xfs_buf_allocate_memory+0x1e5/0x2e0 [xfs]
[84082.084929]  xfs_buf_get_map+0x2e7/0x490 [xfs]
[84082.084959]  xfs_buf_read_map+0x2b/0x300 [xfs]
[84082.084963]  ? sched_clock+0x9/0x10
[84082.084997]  xfs_trans_read_buf_map+0xc4/0x5d0 [xfs]
[84082.085023]  xfs_btree_read_buf_block.constprop.33+0x72/0xc0 [xfs]
[84082.085050]  xfs_btree_lookup_get_block+0x88/0x180 [xfs]
[84082.085076]  xfs_btree_lookup+0xcd/0x400 [xfs]
[84082.085104]  ? kmem_zone_alloc+0x74/0xf0 [xfs]
[84082.085130]  ? xfs_inobt_init_cursor+0x3e/0xe0 [xfs]
[84082.085155]  xfs_difree_inobt+0x8c/0x350 [xfs]
[84082.085185]  xfs_difree+0xc1/0x1b0 [xfs]
[84082.085191]  ? __lock_is_held+0x65/0xb0
[84082.085220]  xfs_ifree+0x7c/0x100 [xfs]
[84082.085248]  xfs_inactive_ifree+0xc0/0x220 [xfs]
[84082.085280]  xfs_inactive+0x7b/0x110 [xfs]
[84082.085305]  xfs_fs_destroy_inode+0xbb/0x2d0 [xfs]
[84082.085311]  destroy_inode+0x3b/0x60
[84082.085315]  evict+0x13e/0x1a0
[84082.085320]  iput+0x231/0x2f0
[84082.085324]  ? dput.part.23+0x27/0x380
[84082.085329]  dentry_unlink_inode+0xe7/0x140
[84082.085333]  __dentry_kill+0xd6/0x170
[84082.085338]  dput.part.23+0x2c2/0x380
[84082.085345]  dput+0x13/0x20
[84082.085349]  __fput+0x191/0x210
[84082.085357]  ____fput+0xe/0x10
[84082.085361]  task_work_run+0x7a/0xb0
[84082.085369]  exit_to_usermode_loop+0xb5/0xc0
[84082.085374]  syscall_return_slowpath+0xb6/0x110
[84082.085380]  entry_SYSCALL_64_fastpath+0xbc/0xbe
[84082.085383] RIP: 0033:0x7f3cef3a568c
[84082.085385] RSP: 002b:00007f3ca42805e0 EFLAGS: 00000293 ORIG_RAX:
0000000000000003
[84082.085389] RAX: 0000000000000000 RBX: 0000374375936710 RCX: 00007f3cef3a568c
[84082.085391] RDX: 0000000000000000 RSI: 00007f3ca42807e0 RDI: 000000000000008e
[84082.085393] RBP: 0000555db2430064 R08: 000000000f759566 R09: 000000006e4c9e9a
[84082.085395] R10: 000000000000019b R11: 0000000000000293 R12: 00003743759366c0
[84082.085397] R13: 0000000000000002 R14: 00007f3ca4280848 R15: 0000555db8dd0f58
[84082.085522] Mem-Info:
[84082.085528] active_anon:6791799 inactive_anon:437016 isolated_anon:0
                active_file:53818 inactive_file:31435 isolated_file:0
                unevictable:6049 dirty:1009 writeback:0 unstable:0
                slab_reclaimable:68970 slab_unreclaimable:99270
                mapped:382037 shmem:437394 pagetables:95314 bounce:0
                free:238601 free_pcp:563 free_cma:0
[84082.085532] Node 0 active_anon:27167196kB inactive_anon:1748064kB
active_file:215272kB inactive_file:125740kB unevictable:24196kB
isolated(anon):0kB isolated(file):0kB mapped:1528148kB dirty:4036kB
writeback:0kB shmem:1749576kB shmem_thp: 0kB shmem_pmdmapped: 0kB
anon_thp: 264192kB writeback_tmp:0kB unstable:0kB all_unreclaimable?
no
[84082.085534] Node 0 DMA free:15864kB min:1048kB low:1308kB
high:1568kB active_anon:0kB inactive_anon:0kB active_file:0kB
inactive_file:0kB unevictable:0kB writepending:0kB present:15988kB
managed:15896kB mlocked:0kB kernel_stack:0kB pagetables:0kB bounce:0kB
free_pcp:0kB local_pcp:0kB free_cma:0kB
[84082.085540] lowmem_reserve[]: 0 2371 30994 30994 30994
[84082.085554] Node 0 DMA32 free:122076kB min:161588kB low:201984kB
high:242380kB active_anon:2240752kB inactive_anon:8728kB
active_file:4404kB inactive_file:516kB unevictable:184kB
writepending:4kB present:2514388kB managed:2448676kB mlocked:184kB
kernel_stack:432kB pagetables:13372kB bounce:0kB free_pcp:0kB
local_pcp:0kB free_cma:0kB
[84082.085560] lowmem_reserve[]: 0 0 28622 28622 28622
[84082.085573] Node 0 Normal free:816464kB min:1934512kB low:2418140kB
high:2901768kB active_anon:24928100kB inactive_anon:1739336kB
active_file:210868kB inactive_file:125224kB unevictable:24012kB
writepending:3428kB present:29874176kB managed:29314960kB
mlocked:24012kB kernel_stack:53712kB pagetables:367884kB bounce:0kB
free_pcp:2252kB local_pcp:648kB free_cma:0kB
[84082.085579] lowmem_reserve[]: 0 0 0 0 0
[84082.085592] Node 0 DMA: 2*4kB (U) 2*8kB (U) 0*16kB 1*32kB (U)
3*64kB (U) 2*128kB (U) 0*256kB 0*512kB 1*1024kB (U) 1*2048kB (M)
3*4096kB (M) = 15864kB
[84082.085636] Node 0 DMA32: 713*4kB (UME) 371*8kB (UME) 504*16kB
(UMEH) 373*32kB (UMEH) 286*64kB (UMEH) 223*128kB (UMEH) 125*256kB
(UMEH) 32*512kB (UME) 1*1024kB (M) 0*2048kB 0*4096kB = 122076kB
[84082.085681] Node 0 Normal: 63043*4kB (UME) 20323*8kB (UME)
7254*16kB (UMEH) 4290*32kB (UMEH) 1238*64kB (UMEH) 543*128kB (UMEH)
0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 816836kB
[84082.085721] Node 0 hugepages_total=0 hugepages_free=0
hugepages_surp=0 hugepages_size=1048576kB
[84082.085723] Node 0 hugepages_total=0 hugepages_free=0
hugepages_surp=0 hugepages_size=2048kB
[84082.085725] 761603 total pagecache pages
[84082.085736] 237855 pages in swap cache
[84082.085738] Swap cache stats: add 194813677, delete 194563053, find
98116718/185125285
[84082.085740] Free swap  = 50364460kB
[84082.085742] Total swap = 62494716kB
[84082.085847] 8101138 pages RAM
[84082.085849] 0 pages HighMem/MovableOnly
[84082.085851] 156255 pages reserved
[84082.085853] 0 pages cma reserved
[84082.085855] 0 pages hwpoisoned
[84082.262236] TaskSchedulerFo: page allocation stalls for 10311ms,
order:0, mode:0x1400040(GFP_NOFS), nodemask=(null)
[84082.262329] TaskSchedulerFo cpuset=/ mems_allowed=0
[84082.262536] CPU: 6 PID: 5165 Comm: TaskSchedulerFo Not tainted
4.13.11-300.fc27.x86_64+debug #1
[84082.262538] Hardware name: Gigabyte Technology Co., Ltd.
Z87M-D3H/Z87M-D3H, BIOS F11 08/12/2014
[84082.262540] Call Trace:
[84082.262546]  dump_stack+0x8e/0xd6
[84082.262551]  warn_alloc+0x114/0x1c0
[84082.262565]  __alloc_pages_slowpath+0x90f/0x1100
[84082.262576]  ? __lock_acquire+0x31f/0x13b0
[84082.262596]  __alloc_pages_nodemask+0x351/0x3e0
[84082.262607]  alloc_pages_current+0x6a/0xe0
[84082.262638]  xfs_buf_allocate_memory+0x1e5/0x2e0 [xfs]
[84082.262668]  xfs_buf_get_map+0x2e7/0x490 [xfs]
[84082.262695]  xfs_buf_read_map+0x2b/0x300 [xfs]
[84082.262727]  xfs_trans_read_buf_map+0xc4/0x5d0 [xfs]
[84082.262752]  xfs_da_read_buf+0xcb/0x100 [xfs]
[84082.262782]  xfs_dir3_data_read+0x23/0x60 [xfs]
[84082.262806]  xfs_dir2_leafn_lookup_for_entry+0x292/0x3c0 [xfs]
[84082.262835]  xfs_dir2_leafn_lookup_int+0x17/0x20 [xfs]
[84082.262856]  xfs_da3_node_lookup_int+0x330/0x370 [xfs]
[84082.262883]  xfs_dir2_node_lookup+0x64/0x230 [xfs]
[84082.262907]  xfs_dir_lookup+0x198/0x1a0 [xfs]
[84082.262937]  xfs_lookup+0x72/0x1e0 [xfs]
[84082.262966]  xfs_vn_lookup+0x70/0xb0 [xfs]
[84082.262974]  lookup_open+0x2dc/0x7c0
[84082.262986]  ? sched_clock+0x9/0x10
[84082.262995]  ? sched_clock+0x9/0x10
[84082.263003]  path_openat+0x6f7/0xc80
[84082.263016]  do_filp_open+0x9b/0x110
[84082.263032]  ? _raw_spin_unlock+0x27/0x40
[84082.263043]  do_sys_open+0x1ba/0x250
[84082.263045]  ? do_sys_open+0x1ba/0x250
[84082.263054]  SyS_openat+0x14/0x20
[84082.263058]  entry_SYSCALL_64_fastpath+0x1f/0xbe
[84082.263061] RIP: 0033:0x7f3cef3a6000
[84082.263063] RSP: 002b:00007f3c9bedc620 EFLAGS: 00000293 ORIG_RAX:
0000000000000101
[84082.263067] RAX: ffffffffffffffda RBX: 0000000071a6666d RCX: 00007f3cef3a6000
[84082.263069] RDX: 0000000000000002 RSI: 0000374378a15100 RDI: ffffffffffffff9c
[84082.263071] RBP: 0000000000000f5c R08: 0000000000000000 R09: 0000000000000000
[84082.263073] R10: 0000000000000000 R11: 0000000000000293 R12: 0000000000000f3c
[84082.263075] R13: 0000374387a5f5a0 R14: 000037434cf12000 R15: 000037438298e008
[84082.468347] TaskSchedulerFo: page allocation stalls for 10516ms,
order:0, mode:0x1c2004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE),
nodemask=(null)
[84082.468368] TaskSchedulerFo cpuset=/ mems_allowed=0
[84082.468500] CPU: 1 PID: 5163 Comm: TaskSchedulerFo Not tainted
4.13.11-300.fc27.x86_64+debug #1
[84082.468502] Hardware name: Gigabyte Technology Co., Ltd.
Z87M-D3H/Z87M-D3H, BIOS F11 08/12/2014
[84082.468504] Call Trace:
[84082.468509]  dump_stack+0x8e/0xd6
[84082.468514]  warn_alloc+0x114/0x1c0
[84082.468529]  __alloc_pages_slowpath+0x90f/0x1100
[84082.468556]  __alloc_pages_nodemask+0x351/0x3e0
[84082.468567]  alloc_pages_current+0x6a/0xe0
[84082.468573]  __page_cache_alloc+0x119/0x150
[84082.468580]  pagecache_get_page+0xa5/0x290
[84082.468587]  grab_cache_page_write_begin+0x26/0x40
[84082.468591]  iomap_write_begin.constprop.14+0x5d/0x130
[84082.468599]  iomap_write_actor+0x92/0x180
[84082.468608]  ? iomap_write_begin.constprop.14+0x130/0x130
[84082.468611]  iomap_apply+0x9f/0x110
[84082.468621]  ? iomap_write_begin.constprop.14+0x130/0x130
[84082.468625]  iomap_file_buffered_write+0x6e/0xa0
[84082.468627]  ? iomap_write_begin.constprop.14+0x130/0x130
[84082.468658]  xfs_file_buffered_aio_write+0xdd/0x380 [xfs]
[84082.468691]  xfs_file_write_iter+0x9e/0x140 [xfs]
[84082.468697]  __vfs_write+0xf8/0x170
[84082.468710]  vfs_write+0xc6/0x1c0
[84082.468716]  SyS_pwrite64+0x98/0xc0
[84082.468724]  entry_SYSCALL_64_fastpath+0x1f/0xbe
[84082.468727] RIP: 0033:0x7f3cef3a6163
[84082.468729] RSP: 002b:00007f3ca3a7f720 EFLAGS: 00000293 ORIG_RAX:
0000000000000012
[84082.468733] RAX: ffffffffffffffda RBX: 0000555db22eb0a2 RCX: 00007f3cef3a6163
[84082.468735] RDX: 0000000000000018 RSI: 00007f3ca3a7f790 RDI: 0000000000000163
[84082.468737] RBP: 00007f3ca3a7f050 R08: 0000000000000001 R09: 0000000000000000
[84082.468739] R10: 0000000000000000 R11: 0000000000000293 R12: 00007f3ca3a7f200
[84082.468741] R13: 0000000000000000 R14: 00007f3ca3a7f060 R15: 0000000000000031
[84083.219990] CacheThread_Blo: page allocation stalls for 10743ms,
order:0, mode:0x1c2004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE),
nodemask=(null)
[84083.220006] CacheThread_Blo cpuset=/ mems_allowed=0
[84083.220137] CPU: 4 PID: 28073 Comm: CacheThread_Blo Not tainted
4.13.11-300.fc27.x86_64+debug #1
[84083.220138] Hardware name: Gigabyte Technology Co., Ltd.
Z87M-D3H/Z87M-D3H, BIOS F11 08/12/2014
[84083.220139] Call Trace:
[84083.220144]  dump_stack+0x8e/0xd6
[84083.220147]  warn_alloc+0x114/0x1c0
[84083.220156]  __alloc_pages_slowpath+0x90f/0x1100
[84083.220177]  __alloc_pages_nodemask+0x351/0x3e0
[84083.220184]  alloc_pages_current+0x6a/0xe0
[84083.220188]  __page_cache_alloc+0x119/0x150
[84083.220192]  pagecache_get_page+0xa5/0x290
[84083.220196]  grab_cache_page_write_begin+0x26/0x40
[84083.220199]  iomap_write_begin.constprop.14+0x5d/0x130
[84083.220203]  iomap_write_actor+0x92/0x180
[84083.220208]  ? iomap_write_begin.constprop.14+0x130/0x130
[84083.220210]  iomap_apply+0x9f/0x110
[84083.220216]  ? iomap_write_begin.constprop.14+0x130/0x130
[84083.220218]  iomap_file_buffered_write+0x6e/0xa0
[84083.220220]  ? iomap_write_begin.constprop.14+0x130/0x130
[84083.220243]  xfs_file_buffered_aio_write+0xdd/0x380 [xfs]
[84083.220266]  xfs_file_write_iter+0x9e/0x140 [xfs]
[84083.220270]  __vfs_write+0xf8/0x170
[84083.220277]  vfs_write+0xc6/0x1c0
[84083.220282]  SyS_pwrite64+0x98/0xc0
[84083.220289]  entry_SYSCALL_64_fastpath+0x1f/0xbe
[84083.220291] RIP: 0033:0x7f3cef3a6163
[84083.220292] RSP: 002b:00007f3cb4719670 EFLAGS: 00000293 ORIG_RAX:
0000000000000012
[84083.220294] RAX: ffffffffffffffda RBX: 000037434d080b00 RCX: 00007f3cef3a6163
[84083.220296] RDX: 0000000000000128 RSI: 000037435c15ac00 RDI: 000000000000021e
[84083.220297] RBP: 00000000000003c0 R08: 0000000000060000 R09: 00007f3cd2ee5e40
[84083.220298] R10: 0000000000002000 R11: 0000000000000293 R12: 0000374332fbc000
[84083.220299] R13: 000037430c625888 R14: 0000374332fbc000 R15: 0000000000000240
[84083.220312] warn_alloc_show_mem: 2 callbacks suppressed
[84083.220313] Mem-Info:
[84083.220316] active_anon:6790478 inactive_anon:437880 isolated_anon:0
                active_file:53817 inactive_file:31427 isolated_file:0
                unevictable:6049 dirty:1009 writeback:0 unstable:0
                slab_reclaimable:68970 slab_unreclaimable:99270
                mapped:382044 shmem:437394 pagetables:95312 bounce:0
                free:239128 free_pcp:876 free_cma:0
[84083.220319] Node 0 active_anon:27161912kB inactive_anon:1751520kB
active_file:215268kB inactive_file:125708kB unevictable:24196kB
isolated(anon):0kB isolated(file):0kB mapped:1528176kB dirty:4036kB
writeback:0kB shmem:1749576kB shmem_thp: 0kB shmem_pmdmapped: 0kB
anon_thp: 264192kB writeback_tmp:0kB unstable:0kB all_unreclaimable?
no
[84083.220320] Node 0 DMA free:15864kB min:1048kB low:1308kB
high:1568kB active_anon:0kB inactive_anon:0kB active_file:0kB
inactive_file:0kB unevictable:0kB writepending:0kB present:15988kB
managed:15896kB mlocked:0kB kernel_stack:0kB pagetables:0kB bounce:0kB
free_pcp:0kB local_pcp:0kB free_cma:0kB
[84083.220324] lowmem_reserve[]: 0 2371 30994 30994 30994
[84083.220332] Node 0 DMA32 free:122076kB min:161588kB low:201984kB
high:242380kB active_anon:2240728kB inactive_anon:8744kB
active_file:4404kB inactive_file:516kB unevictable:184kB
writepending:4kB present:2514388kB managed:2448676kB mlocked:184kB
kernel_stack:432kB pagetables:13372kB bounce:0kB free_pcp:8kB
local_pcp:0kB free_cma:0kB
[84083.220335] lowmem_reserve[]: 0 0 28622 28622 28622
[84083.220343] Node 0 Normal free:818572kB min:1934512kB low:2418140kB
high:2901768kB active_anon:24921492kB inactive_anon:1742776kB
active_file:210864kB inactive_file:125192kB unevictable:24012kB
writepending:4032kB present:29874176kB managed:29314960kB
mlocked:24012kB kernel_stack:53472kB pagetables:367876kB bounce:0kB
free_pcp:3496kB local_pcp:176kB free_cma:0kB
[84083.220347] lowmem_reserve[]: 0 0 0 0 0
[84083.220355] Node 0 DMA: 2*4kB (U) 2*8kB (U) 0*16kB 1*32kB (U)
3*64kB (U) 2*128kB (U) 0*256kB 0*512kB 1*1024kB (U) 1*2048kB (M)
3*4096kB (M) = 15864kB
[84083.220380] Node 0 DMA32: 713*4kB (UME) 371*8kB (UME) 504*16kB
(UMEH) 373*32kB (UMEH) 286*64kB (UMEH) 223*128kB (UMEH) 125*256kB
(UMEH) 32*512kB (UME) 1*1024kB (M) 0*2048kB 0*4096kB = 122076kB
[84083.220408] Node 0 Normal: 63142*4kB (UME) 20335*8kB (UME)
7261*16kB (UMEH) 4299*32kB (UMEH) 1257*64kB (UMEH) 543*128kB (UMEH)
0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 818944kB
[84083.220432] Node 0 hugepages_total=0 hugepages_free=0
hugepages_surp=0 hugepages_size=1048576kB
[84083.220434] Node 0 hugepages_total=0 hugepages_free=0
hugepages_surp=0 hugepages_size=2048kB
[84083.220435] 761594 total pagecache pages
[84083.220444] 237813 pages in swap cache
[84083.220445] Swap cache stats: add 194814293, delete 194563711, find
98116718/185125285
[84083.220447] Free swap  = 50361644kB
[84083.220448] Total swap = 62494716kB
[84083.220452] 8101138 pages RAM
[84083.220453] 0 pages HighMem/MovableOnly
[84083.220455] 156255 pages reserved
[84083.220456] 0 pages cma reserved
[84083.220457] 0 pages hwpoisoned
[84083.355246] TaskSchedulerBa: page allocation stalls for 10844ms,
order:0, mode:0x1400040(GFP_NOFS), nodemask=(null)
[84083.355333] TaskSchedulerBa cpuset=/ mems_allowed=0
[84083.355526] CPU: 6 PID: 2555 Comm: TaskSchedulerBa Not tainted
4.13.11-300.fc27.x86_64+debug #1
[84083.355528] Hardware name: Gigabyte Technology Co., Ltd.
Z87M-D3H/Z87M-D3H, BIOS F11 08/12/2014
[84083.355530] Call Trace:
[84083.355536]  dump_stack+0x8e/0xd6
[84083.355541]  warn_alloc+0x114/0x1c0
[84083.355555]  __alloc_pages_slowpath+0x90f/0x1100
[84083.355582]  __alloc_pages_nodemask+0x351/0x3e0
[84083.355593]  alloc_pages_current+0x6a/0xe0
[84083.355623]  xfs_buf_allocate_memory+0x1e5/0x2e0 [xfs]
[84083.355652]  xfs_buf_get_map+0x2e7/0x490 [xfs]
[84083.355679]  xfs_buf_read_map+0x2b/0x300 [xfs]
[84083.355711]  xfs_trans_read_buf_map+0xc4/0x5d0 [xfs]
[84083.355735]  xfs_da_read_buf+0xcb/0x100 [xfs]
[84083.355765]  xfs_dir3_leaf_read+0x23/0x60 [xfs]
[84083.355789]  xfs_dir2_leaf_lookup_int+0x67/0x2d0 [xfs]
[84083.355818]  xfs_dir2_leaf_lookup+0x56/0x200 [xfs]
[84083.355844]  xfs_dir_lookup+0x120/0x1a0 [xfs]
[84083.355875]  xfs_lookup+0x72/0x1e0 [xfs]
[84083.355903]  xfs_vn_lookup+0x70/0xb0 [xfs]
[84083.355910]  lookup_slow+0x132/0x220
[84083.355933]  walk_component+0x1bd/0x340
[84083.355944]  path_lookupat+0x84/0x1f0
[84083.355950]  ? sched_clock+0x9/0x10
[84083.355957]  filename_lookup+0xb6/0x190
[84083.355967]  ? getname_flags+0x4f/0x1f0
[84083.355971]  ? __check_object_size+0xaf/0x1b0
[84083.355977]  ? strncpy_from_user+0x4d/0x170
[84083.355987]  user_path_at_empty+0x36/0x40
[84083.355990]  ? user_path_at_empty+0x36/0x40
[84083.355995]  vfs_statx+0x76/0xe0
[84083.356004]  SYSC_newstat+0x3d/0x70
[84083.356007]  ? do_fcntl+0x535/0x770
[84083.356014]  ? trace_hardirqs_on_caller+0xf4/0x190
[84083.356019]  ? trace_hardirqs_on_thunk+0x1a/0x1c
[84083.356026]  SyS_newstat+0xe/0x10
[84083.356030]  entry_SYSCALL_64_fastpath+0x1f/0xbe
[84083.356033] RIP: 0033:0x7f67ed6b2635
[84083.356035] RSP: 002b:00007f679c1e9178 EFLAGS: 00000246 ORIG_RAX:
0000000000000004
[84083.356039] RAX: ffffffffffffffda RBX: 00003b97d31b6e00 RCX: 00007f67ed6b2635
[84083.356041] RDX: 00007f679c1e9180 RSI: 00007f679c1e9180 RDI: 00003b97cddad267
[84083.356043] RBP: 0000000000000000 R08: 00003b97cbb210c0 R09: 0000000000001f7f
[84083.356046] R10: 00007f679c1e9770 R11: 0000000000000246 R12: 00003b97cea99510
[84083.356048] R13: 0000000000000000 R14: 00003b97cddad1e0 R15: 00003b97cddad000
[84083.564258] TaskSchedulerFo: page allocation stalls for 11167ms,
order:0, mode:0x1c2004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE),
nodemask=(null)
[84083.564272] TaskSchedulerFo cpuset=/ mems_allowed=0
[84083.564390] CPU: 0 PID: 9896 Comm: TaskSchedulerFo Not tainted
4.13.11-300.fc27.x86_64+debug #1
[84083.564392] Hardware name: Gigabyte Technology Co., Ltd.
Z87M-D3H/Z87M-D3H, BIOS F11 08/12/2014
[84083.564393] Call Trace:
[84083.564398]  dump_stack+0x8e/0xd6
[84083.564401]  warn_alloc+0x114/0x1c0
[84083.564409]  __alloc_pages_slowpath+0x90f/0x1100
[84083.564423]  __alloc_pages_nodemask+0x351/0x3e0
[84083.564430]  alloc_pages_current+0x6a/0xe0
[84083.564434]  __page_cache_alloc+0x119/0x150
[84083.564437]  pagecache_get_page+0xa5/0x290
[84083.564442]  grab_cache_page_write_begin+0x26/0x40
[84083.564444]  iomap_write_begin.constprop.14+0x5d/0x130
[84083.564449]  iomap_write_actor+0x92/0x180
[84083.564454]  ? iomap_write_begin.constprop.14+0x130/0x130
[84083.564456]  iomap_apply+0x9f/0x110
[84083.564462]  ? iomap_write_begin.constprop.14+0x130/0x130
[84083.564464]  iomap_file_buffered_write+0x6e/0xa0
[84083.564466]  ? iomap_write_begin.constprop.14+0x130/0x130
[84083.564488]  xfs_file_buffered_aio_write+0xdd/0x380 [xfs]
[84083.564511]  xfs_file_write_iter+0x9e/0x140 [xfs]
[84083.564515]  __vfs_write+0xf8/0x170
[84083.564522]  vfs_write+0xc6/0x1c0
[84083.564526]  SyS_write+0x58/0xc0
[84083.564530]  entry_SYSCALL_64_fastpath+0x1f/0xbe
[84083.564532] RIP: 0033:0x7f67f410c55b
[84083.564534] RSP: 002b:00007f679e60af30 EFLAGS: 00000293 ORIG_RAX:
0000000000000001
[84083.564536] RAX: ffffffffffffffda RBX: 00003b97d266e1c8 RCX: 00007f67f410c55b
[84083.564537] RDX: 0000000000000007 RSI: 00007f679e60b021 RDI: 00000000000000c1
[84083.564539] RBP: 00000000000010b8 R08: 0000000000000000 R09: 000000005fe92fad
[84083.564540] R10: 000000005fe92fad R11: 0000000000000293 R12: 00003b97d266e1c0
[84083.564541] R13: 00000000000010b8 R14: 00007f679e60b5d8 R15: 00007f679e60b7c0
[84083.748335] tracker-store: page allocation stalls for 10512ms,
order:0, mode:0x142014a(GFP_NOFS|__GFP_HIGHMEM|__GFP_COLD|__GFP_HARDWALL|__GFP_MOVABLE),
nodemask=(null)
[84083.748355] tracker-store cpuset=/ mems_allowed=0
[84083.748482] CPU: 1 PID: 2242 Comm: tracker-store Not tainted
4.13.11-300.fc27.x86_64+debug #1
[84083.748484] Hardware name: Gigabyte Technology Co., Ltd.
Z87M-D3H/Z87M-D3H, BIOS F11 08/12/2014
[84083.748486] Call Trace:
[84083.748492]  dump_stack+0x8e/0xd6
[84083.748496]  warn_alloc+0x114/0x1c0
[84083.748511]  __alloc_pages_slowpath+0x90f/0x1100
[84083.748521]  ? __lock_acquire+0x31f/0x13b0
[84083.748541]  __alloc_pages_nodemask+0x351/0x3e0
[84083.748552]  alloc_pages_current+0x6a/0xe0
[84083.748558]  __page_cache_alloc+0x119/0x150
[84083.748565]  generic_file_read_iter+0x8de/0xbf0
[84083.748574]  ? debug_lockdep_rcu_enabled+0x1d/0x30
[84083.748607]  ? xfs_file_buffered_aio_read+0x53/0x180 [xfs]
[84083.748611]  ? down_read_nested+0x73/0xb0
[84083.748641]  xfs_file_buffered_aio_read+0x5e/0x180 [xfs]
[84083.748667]  xfs_file_read_iter+0x68/0xc0 [xfs]
[84083.748671]  __vfs_read+0xf1/0x160
[84083.748684]  vfs_read+0xa3/0x150
[84083.748690]  SyS_pread64+0x98/0xc0
[84083.748698]  entry_SYSCALL_64_fastpath+0x1f/0xbe
[84083.748700] RIP: 0033:0x7f42e89f2103
[84083.748703] RSP: 002b:00007ffe6ae30440 EFLAGS: 00000293 ORIG_RAX:
0000000000000011
[84083.748707] RAX: ffffffffffffffda RBX: 00007ffe6ae30920 RCX: 00007f42e89f2103
[84083.748709] RDX: 0000000000001000 RSI: 000055f76402d608 RDI: 0000000000000008
[84083.748711] RBP: 000055f764028248 R08: 000055f76402d608 R09: 000000000fa10fff
[84083.748713] R10: 0000000003a02000 R11: 0000000000000293 R12: 000000000000003f
[84083.748715] R13: 000055f7640280ec R14: 000055f763ed92a8 R15: 00000000000001e0
[84084.245111] cupsd: page allocation stalls for 10673ms, order:0,
mode:0x1604040(GFP_NOFS|__GFP_COMP|__GFP_NOTRACK), nodemask=(null)
[84084.245128] cupsd cpuset=/ mems_allowed=0
[84084.245258] CPU: 5 PID: 2143 Comm: cupsd Not tainted
4.13.11-300.fc27.x86_64+debug #1
[84084.245260] Hardware name: Gigabyte Technology Co., Ltd.
Z87M-D3H/Z87M-D3H, BIOS F11 08/12/2014
[84084.245261] Call Trace:
[84084.245265]  dump_stack+0x8e/0xd6
[84084.245268]  warn_alloc+0x114/0x1c0
[84084.245276]  __alloc_pages_slowpath+0x90f/0x1100
[84084.245283]  ? sched_clock+0x9/0x10
[84084.245294]  __alloc_pages_nodemask+0x351/0x3e0
[84084.245301]  alloc_pages_current+0x6a/0xe0
[84084.245305]  new_slab+0x440/0x740
[84084.245307]  ? __slab_alloc+0x51/0x90
[84084.245313]  ___slab_alloc+0x3eb/0x5e0
[84084.245318]  ? inode_doinit_with_dentry+0x3a2/0x5f0
[84084.245322]  ? __lock_is_held+0x65/0xb0
[84084.245326]  ? inode_doinit_with_dentry+0x3a2/0x5f0
[84084.245329]  __slab_alloc+0x51/0x90
[84084.245331]  ? __slab_alloc+0x51/0x90
[84084.245335]  kmem_cache_alloc_trace+0x231/0x2e0
[84084.245337]  ? inode_doinit_with_dentry+0x3a2/0x5f0
[84084.245340]  inode_doinit_with_dentry+0x3a2/0x5f0
[84084.245345]  selinux_d_instantiate+0x1c/0x20
[84084.245348]  security_d_instantiate+0x32/0x50
[84084.245352]  d_splice_alias+0x50/0x480
[84084.245357]  ext4_lookup+0x1c8/0x260
[84084.245362]  lookup_slow+0x132/0x220
[84084.245374]  walk_component+0x1bd/0x340
[84084.245376]  ? security_inode_permission+0x41/0x60
[84084.245382]  link_path_walk+0x1bc/0x5a0
[84084.245387]  path_openat+0xe6/0xc80
[84084.245394]  do_filp_open+0x9b/0x110
[84084.245403]  ? _raw_spin_unlock+0x27/0x40
[84084.245409]  do_sys_open+0x1ba/0x250
[84084.245411]  ? do_sys_open+0x1ba/0x250
[84084.245416]  SyS_openat+0x14/0x20
[84084.245418]  entry_SYSCALL_64_fastpath+0x1f/0xbe
[84084.245420] RIP: 0033:0x7f76143abf6e
[84084.245422] RSP: 002b:00007ffe9904ced0 EFLAGS: 00000246 ORIG_RAX:
0000000000000101
[84084.245424] RAX: ffffffffffffffda RBX: 0000559d8c46d7c8 RCX: 00007f76143abf6e
[84084.245425] RDX: 0000000000000001 RSI: 00007ffe9904d4e0 RDI: ffffffffffffff9c
[84084.245427] RBP: 000000005a01abe9 R08: 00007ffe9904d940 R09: 000000000000001c
[84084.245428] R10: 0000000000000000 R11: 0000000000000246 R12: 0000559d8c6819e8
[84084.245429] R13: 000000005a005a83 R14: 000000005a005a69 R15: 000000005a005a69
[84084.245442] warn_alloc_show_mem: 3 callbacks suppressed
[84084.245442] Mem-Info:
[84084.245446] active_anon:6789414 inactive_anon:436784 isolated_anon:32
                active_file:53804 inactive_file:31340 isolated_file:0
                unevictable:6049 dirty:799 writeback:136 unstable:0
                slab_reclaimable:68970 slab_unreclaimable:99270
                mapped:382030 shmem:437294 pagetables:95312 bounce:0
                free:241081 free_pcp:1157 free_cma:0
[84084.245448] Node 0 active_anon:27157656kB inactive_anon:1747136kB
active_file:215216kB inactive_file:125360kB unevictable:24196kB
isolated(anon):128kB isolated(file):0kB mapped:1528120kB dirty:3196kB
writeback:544kB shmem:1749176kB shmem_thp: 0kB shmem_pmdmapped: 0kB
anon_thp: 264192kB writeback_tmp:0kB unstable:0kB all_unreclaimable?
no
[84084.245450] Node 0 DMA free:15864kB min:1048kB low:1308kB
high:1568kB active_anon:0kB inactive_anon:0kB active_file:0kB
inactive_file:0kB unevictable:0kB writepending:0kB present:15988kB
managed:15896kB mlocked:0kB kernel_stack:0kB pagetables:0kB bounce:0kB
free_pcp:0kB local_pcp:0kB free_cma:0kB
[84084.245453] lowmem_reserve[]: 0 2371 30994 30994 30994
[84084.245461] Node 0 DMA32 free:122076kB min:161588kB low:201984kB
high:242380kB active_anon:2240688kB inactive_anon:8784kB
active_file:4404kB inactive_file:516kB unevictable:184kB
writepending:4kB present:2514388kB managed:2448676kB mlocked:184kB
kernel_stack:432kB pagetables:13372kB bounce:0kB free_pcp:8kB
local_pcp:0kB free_cma:0kB
[84084.245465] lowmem_reserve[]: 0 0 28622 28622 28622
[84084.245472] Node 0 Normal free:826384kB min:1934512kB low:2418140kB
high:2901768kB active_anon:24917352kB inactive_anon:1738352kB
active_file:210812kB inactive_file:124632kB unevictable:24012kB
writepending:3736kB present:29874176kB managed:29314960kB
mlocked:24012kB kernel_stack:53296kB pagetables:367876kB bounce:0kB
free_pcp:4536kB local_pcp:512kB free_cma:0kB
[84084.245476] lowmem_reserve[]: 0 0 0 0 0
[84084.245483] Node 0 DMA: 2*4kB (U) 2*8kB (U) 0*16kB 1*32kB (U)
3*64kB (U) 2*128kB (U) 0*256kB 0*512kB 1*1024kB (U) 1*2048kB (M)
3*4096kB (M) = 15864kB
[84084.245508] Node 0 DMA32: 713*4kB (UME) 371*8kB (UME) 504*16kB
(UMEH) 373*32kB (UMEH) 286*64kB (UMEH) 223*128kB (UMEH) 125*256kB
(UMEH) 32*512kB (UME) 1*1024kB (M) 0*2048kB 0*4096kB = 122076kB
[84084.245534] Node 0 Normal: 63692*4kB (UME) 20452*8kB (UME)
7324*16kB (UMEH) 4341*32kB (UMEH) 1295*64kB (UMEH) 547*128kB (UMEH)
0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 827376kB
[84084.245564] Node 0 hugepages_total=0 hugepages_free=0
hugepages_surp=0 hugepages_size=1048576kB
[84084.245566] Node 0 hugepages_total=0 hugepages_free=0
hugepages_surp=0 hugepages_size=2048kB
[84084.245567] 761313 total pagecache pages
[84084.245575] 237795 pages in swap cache
[84084.245577] Swap cache stats: add 194816237, delete 194565673, find
98116718/185125285
[84084.245578] Free swap  = 50354220kB
[84084.245579] Total swap = 62494716kB
[84084.245584] 8101138 pages RAM
[84084.245586] 0 pages HighMem/MovableOnly
[84084.245587] 156255 pages reserved
[84084.245588] 0 pages cma reserved
[84084.245589] 0 pages hwpoisoned
[84084.700982] kworker/2:0: page allocation stalls for 11336ms,
order:0, mode:0x1400000(GFP_NOIO), nodemask=(null)
[84084.701003] kworker/2:0 cpuset=/ mems_allowed=0
[84084.701193] CPU: 2 PID: 4801 Comm: kworker/2:0 Not tainted
4.13.11-300.fc27.x86_64+debug #1
[84084.701195] Hardware name: Gigabyte Technology Co., Ltd.
Z87M-D3H/Z87M-D3H, BIOS F11 08/12/2014
[84084.701201] Workqueue: events_freezable_power_ disk_events_workfn
[84084.701204] Call Trace:
[84084.701208]  dump_stack+0x8e/0xd6
[84084.701211]  warn_alloc+0x114/0x1c0
[84084.701219]  __alloc_pages_slowpath+0x90f/0x1100
[84084.701234]  __alloc_pages_nodemask+0x351/0x3e0
[84084.701240]  alloc_pages_current+0x6a/0xe0
[84084.701245]  bio_copy_kern+0xef/0x200
[84084.701250]  blk_rq_map_kern+0xc6/0x120
[84084.701254]  scsi_execute+0x209/0x250
[84084.701259]  sr_check_events+0xa1/0x2b0
[84084.701266]  cdrom_check_events+0x18/0x30
[84084.701269]  sr_block_check_events+0x2a/0x30
[84084.701271]  disk_check_events+0x62/0x150
[84084.701274]  ? process_one_work+0x1d0/0x6a0
[84084.701279]  disk_events_workfn+0x1c/0x20
[84084.701281]  process_one_work+0x253/0x6a0
[84084.701288]  worker_thread+0x4e/0x3c0
[84084.701293]  kthread+0x133/0x150
[84084.701295]  ? process_one_work+0x6a0/0x6a0
[84084.701297]  ? kthread_create_on_node+0x70/0x70
[84084.701300]  ? syscall_return_slowpath+0xb6/0x110
[84084.701303]  ret_from_fork+0x2a/0x40
[84088.792886] Chrome_HistoryT: page allocation stalls for 10054ms,
order:0, mode:0x1400040(GFP_NOFS), nodemask=(null)
[84088.792898] Chrome_HistoryT cpuset=/ mems_allowed=0
[84088.792907] CPU: 6 PID: 28111 Comm: Chrome_HistoryT Not tainted
4.13.11-300.fc27.x86_64+debug #1
[84088.792909] Hardware name: Gigabyte Technology Co., Ltd.
Z87M-D3H/Z87M-D3H, BIOS F11 08/12/2014
[84088.792911] Call Trace:
[84088.792919]  dump_stack+0x8e/0xd6
[84088.792924]  warn_alloc+0x114/0x1c0
[84088.792939]  __alloc_pages_slowpath+0x90f/0x1100
[84088.792966]  __alloc_pages_nodemask+0x351/0x3e0
[84088.792978]  alloc_pages_current+0x6a/0xe0
[84088.793021]  xfs_buf_allocate_memory+0x1e5/0x2e0 [xfs]
[84088.793055]  xfs_buf_get_map+0x2e7/0x490 [xfs]
[84088.793085]  xfs_buf_read_map+0x2b/0x300 [xfs]
[84088.793090]  ? reacquire_held_locks+0xf8/0x180
[84088.793123]  xfs_trans_read_buf_map+0xc4/0x5d0 [xfs]
[84088.793148]  xfs_btree_read_buf_block.constprop.33+0x72/0xc0 [xfs]
[84088.793176]  xfs_btree_lookup_get_block+0x88/0x180 [xfs]
[84088.793202]  xfs_btree_lookup+0xcd/0x400 [xfs]
[84088.793230]  ? kmem_zone_alloc+0x74/0xf0 [xfs]
[84088.793253]  ? xfs_allocbt_init_cursor+0x3e/0xe0 [xfs]
[84088.793276]  xfs_alloc_ag_vextent_near+0xaf/0xfe0 [xfs]
[84088.793305]  xfs_alloc_ag_vextent+0x141/0x150 [xfs]
[84088.793325]  xfs_alloc_vextent+0x5b0/0x9c0 [xfs]
[84088.793348]  xfs_bmap_btalloc+0x2f8/0x7a0 [xfs]
[84088.793386]  xfs_bmap_alloc+0xe/0x10 [xfs]
[84088.793405]  xfs_bmapi_write+0x68d/0xc30 [xfs]
[84088.793456]  xfs_iomap_write_allocate+0x196/0x3a0 [xfs]
[84088.793497]  xfs_map_blocks+0x1be/0x400 [xfs]
[84088.793524]  xfs_do_writepage+0x16c/0x810 [xfs]
[84088.793540]  write_cache_pages+0x204/0x650
[84088.793564]  ? xfs_aops_discard_page+0x130/0x130 [xfs]
[84088.793590]  ? xfs_vm_writepages+0x5b/0xe0 [xfs]
[84088.793618]  xfs_vm_writepages+0xb9/0xe0 [xfs]
[84088.793630]  do_writepages+0x48/0xf0
[84088.793643]  __filemap_fdatawrite_range+0xc1/0x100
[84088.793646]  ? __filemap_fdatawrite_range+0xc1/0x100
[84088.793649]  ? rcu_read_lock_sched_held+0x79/0x80
[84088.793662]  file_write_and_wait_range+0x4d/0xc0
[84088.793688]  xfs_file_fsync+0x7c/0x2b0 [xfs]
[84088.793698]  vfs_fsync_range+0x4b/0xb0
[84088.793704]  do_fsync+0x3d/0x70
[84088.793710]  SyS_fdatasync+0x13/0x20
[84088.793713]  entry_SYSCALL_64_fastpath+0x1f/0xbe
[84088.793716] RIP: 0033:0x7f3ce9070abc
[84088.793718] RSP: 002b:00007f3cb3494060 EFLAGS: 00000293 ORIG_RAX:
000000000000004b
[84088.793723] RAX: ffffffffffffffda RBX: 000037430d8de5a0 RCX: 00007f3ce9070abc
[84088.793725] RDX: 0000000000000000 RSI: 0000000000000002 RDI: 000000000000024b
[84088.793727] RBP: 000037430d8e0b80 R08: 000037430d4c1000 R09: 0000555db26b2544
[84088.793729] R10: 0000000000005400 R11: 0000000000000293 R12: 0000000000000000
[84088.793731] R13: 000037430d8de5a0 R14: 000037430d8e0b80 R15: 00007f3cb3494748
[84088.793838] warn_alloc_show_mem: 1 callbacks suppressed
[84088.793839] Mem-Info:
[84088.793844] active_anon:6765748 inactive_anon:446921 isolated_anon:0
                active_file:53798 inactive_file:30944 isolated_file:0
                unevictable:6049 dirty:617 writeback:39 unstable:0
                slab_reclaimable:68970 slab_unreclaimable:99246
                mapped:381989 shmem:437294 pagetables:95312 bounce:0
                free:256142 free_pcp:532 free_cma:0
[84088.793849] Node 0 active_anon:27062992kB inactive_anon:1787684kB
active_file:215192kB inactive_file:123776kB unevictable:24196kB
isolated(anon):0kB isolated(file):0kB mapped:1527956kB dirty:2468kB
writeback:156kB shmem:1749176kB shmem_thp: 0kB shmem_pmdmapped: 0kB
anon_thp: 264192kB writeback_tmp:0kB unstable:0kB all_unreclaimable?
no
[84088.793851] Node 0 DMA free:15864kB min:1048kB low:1308kB
high:1568kB active_anon:0kB inactive_anon:0kB active_file:0kB
inactive_file:0kB unevictable:0kB writepending:0kB present:15988kB
managed:15896kB mlocked:0kB kernel_stack:0kB pagetables:0kB bounce:0kB
free_pcp:0kB local_pcp:0kB free_cma:0kB
[84088.793857] lowmem_reserve[]: 0 2371 30994 30994 30994
[84088.793870] Node 0 DMA32 free:122092kB min:161588kB low:201984kB
high:242380kB active_anon:2238532kB inactive_anon:10932kB
active_file:4404kB inactive_file:516kB unevictable:184kB
writepending:4kB present:2514388kB managed:2448676kB mlocked:184kB
kernel_stack:432kB pagetables:13372kB bounce:0kB free_pcp:0kB
local_pcp:0kB free_cma:0kB
[84088.793876] lowmem_reserve[]: 0 0 28622 28622 28622
[84088.793890] Node 0 Normal free:886612kB min:1934512kB low:2418140kB
high:2901768kB active_anon:24825028kB inactive_anon:1776216kB
active_file:210788kB inactive_file:123260kB unevictable:24012kB
writepending:2300kB present:29874176kB managed:29314960kB
mlocked:24012kB kernel_stack:53216kB pagetables:367876kB bounce:0kB
free_pcp:2128kB local_pcp:412kB free_cma:0kB
[84088.793896] lowmem_reserve[]: 0 0 0 0 0
[84088.793909] Node 0 DMA: 2*4kB (U) 2*8kB (U) 0*16kB 1*32kB (U)
3*64kB (U) 2*128kB (U) 0*256kB 0*512kB 1*1024kB (U) 1*2048kB (M)
3*4096kB (M) = 15864kB
[84088.793970] Node 0 DMA32: 720*4kB (UME) 371*8kB (UME) 504*16kB
(UMEH) 373*32kB (UMEH) 286*64kB (UMEH) 223*128kB (UMEH) 125*256kB
(UMEH) 32*512kB (UME) 1*1024kB (M) 0*2048kB 0*4096kB = 122104kB
[84088.794016] Node 0 Normal: 68363*4kB (UME) 21894*8kB (UME)
7899*16kB (UMEH) 4524*32kB (UMEH) 1415*64kB (UMEH) 597*128kB (UMEH)
0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 886732kB
[84088.794056] Node 0 hugepages_total=0 hugepages_free=0
hugepages_surp=0 hugepages_size=1048576kB
[84088.794059] Node 0 hugepages_total=0 hugepages_free=0
hugepages_surp=0 hugepages_size=2048kB
[84088.794061] 760450 total pagecache pages
[84088.794072] 237284 pages in swap cache
[84088.794075] Swap cache stats: add 194829267, delete 194579214, find
98116718/185125290
[84088.794077] Free swap  = 50302252kB
[84088.794079] Total swap = 62494716kB
[84088.794081] 8101138 pages RAM
[84088.794083] 0 pages HighMem/MovableOnly
[84088.794085] 156255 pages reserved
[84088.794087] 0 pages cma reserved
[84088.794089] 0 pages hwpoisoned
[84090.789073] qemu-system-x86: page allocation stalls for 18881ms,
order:0, mode:0x14000c0(GFP_KERNEL), nodemask=(null)
[84090.789085] qemu-system-x86 cpuset=emulator mems_allowed=0
[84090.789094] CPU: 7 PID: 4413 Comm: qemu-system-x86 Not tainted
4.13.11-300.fc27.x86_64+debug #1
[84090.789096] Hardware name: Gigabyte Technology Co., Ltd.
Z87M-D3H/Z87M-D3H, BIOS F11 08/12/2014
[84090.789098] Call Trace:
[84090.789107]  dump_stack+0x8e/0xd6
[84090.789113]  warn_alloc+0x114/0x1c0
[84090.789127]  __alloc_pages_slowpath+0x90f/0x1100
[84090.789155]  __alloc_pages_nodemask+0x351/0x3e0
[84090.789166]  alloc_pages_current+0x6a/0xe0
[84090.789173]  __get_free_pages+0x14/0x40
[84090.789177]  __pollwait+0x52/0xe0
[84090.789183]  unix_poll+0x29/0xb0
[84090.789188]  sock_poll+0x6e/0x90
[84090.789194]  do_sys_poll+0x283/0x590
[84090.789224]  ? poll_initwait+0x40/0x40
[84090.789232]  ? set_fd_set.part.1+0x60/0x60
[84090.789239]  ? set_fd_set.part.1+0x60/0x60
[84090.789246]  ? set_fd_set.part.1+0x60/0x60
[84090.789253]  ? set_fd_set.part.1+0x60/0x60
[84090.789259]  ? set_fd_set.part.1+0x60/0x60
[84090.789266]  ? set_fd_set.part.1+0x60/0x60
[84090.789273]  ? set_fd_set.part.1+0x60/0x60
[84090.789280]  ? set_fd_set.part.1+0x60/0x60
[84090.789287]  ? set_fd_set.part.1+0x60/0x60
[84090.789296]  SyS_ppoll+0x166/0x190
[84090.789300]  ? SyS_ppoll+0x166/0x190
[84090.789312]  entry_SYSCALL_64_fastpath+0x1f/0xbe
[84090.789315] RIP: 0033:0x7fabe6e789b6
[84090.789317] RSP: 002b:00007ffe0a735be0 EFLAGS: 00000293 ORIG_RAX:
000000000000010f
[84090.789321] RAX: ffffffffffffffda RBX: 000055d48f2d51a0 RCX: 00007fabe6e789b6
[84090.789323] RDX: 00007ffe0a735c00 RSI: 000000000000004e RDI: 000055d49094dc50
[84090.789325] RBP: 0000000000000000 R08: 0000000000000008 R09: 0000000000000000
[84090.789327] R10: 0000000000000000 R11: 0000000000000293 R12: 00007ffe0a735bf0
[84090.789329] R13: 00007ffe0a735be8 R14: 000000007fffffff R15: 000055d48e04e880
[84090.789345] Mem-Info:
[84090.789350] active_anon:6738881 inactive_anon:453252 isolated_anon:0
                active_file:53967 inactive_file:30219 isolated_file:0
                unevictable:6049 dirty:617 writeback:203 unstable:0
                slab_reclaimable:68970 slab_unreclaimable:99238
                mapped:381756 shmem:437034 pagetables:95312 bounce:0
                free:276350 free_pcp:981 free_cma:0
[84090.789354] Node 0 active_anon:26955524kB inactive_anon:1813300kB
active_file:215868kB inactive_file:120876kB unevictable:24196kB
isolated(anon):0kB isolated(file):0kB mapped:1527024kB dirty:2468kB
writeback:812kB shmem:1748136kB shmem_thp: 0kB shmem_pmdmapped: 0kB
anon_thp: 264192kB writeback_tmp:0kB unstable:0kB all_unreclaimable?
no
[84090.789356] Node 0 DMA free:15864kB min:1048kB low:1308kB
high:1568kB active_anon:0kB inactive_anon:0kB active_file:0kB
inactive_file:0kB unevictable:0kB writepending:0kB present:15988kB
managed:15896kB mlocked:0kB kernel_stack:0kB pagetables:0kB bounce:0kB
free_pcp:0kB local_pcp:0kB free_cma:0kB
[84090.789361] lowmem_reserve[]: 0 2371 30994 30994 30994
[84090.789374] Node 0 DMA32 free:122104kB min:161588kB low:201984kB
high:242380kB active_anon:2238412kB inactive_anon:11044kB
active_file:4456kB inactive_file:452kB unevictable:184kB
writepending:4kB present:2514388kB managed:2448676kB mlocked:184kB
kernel_stack:432kB pagetables:13372kB bounce:0kB free_pcp:48kB
local_pcp:4kB free_cma:0kB
[84090.789380] lowmem_reserve[]: 0 0 28622 28622 28622
[84090.789392] Node 0 Normal free:967432kB min:1934512kB low:2418140kB
high:2901768kB active_anon:24718696kB inactive_anon:1801612kB
active_file:211332kB inactive_file:120424kB unevictable:24012kB
writepending:2636kB present:29874176kB managed:29314960kB
mlocked:24012kB kernel_stack:53200kB pagetables:367876kB bounce:0kB
free_pcp:3876kB local_pcp:676kB free_cma:0kB
[84090.789398] lowmem_reserve[]: 0 0 0 0 0
[84090.789410] Node 0 DMA: 2*4kB (U) 2*8kB (U) 0*16kB 1*32kB (U)
3*64kB (U) 2*128kB (U) 0*256kB 0*512kB 1*1024kB (U) 1*2048kB (M)
3*4096kB (M) = 15864kB
[84090.789450] Node 0 DMA32: 722*4kB (UME) 371*8kB (UME) 504*16kB
(UMEH) 373*32kB (UMEH) 286*64kB (UMEH) 223*128kB (UMEH) 125*256kB
(UMEH) 32*512kB (UME) 1*1024kB (M) 0*2048kB 0*4096kB = 122112kB
[84090.789492] Node 0 Normal: 75195*4kB (UME) 24132*8kB (UME)
8752*16kB (UMEH) 4811*32kB (UMEH) 1522*64kB (UMEH) 653*128kB (UMEH)
0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 968812kB
[84090.789530] Node 0 hugepages_total=0 hugepages_free=0
hugepages_surp=0 hugepages_size=1048576kB
[84090.789532] Node 0 hugepages_total=0 hugepages_free=0
hugepages_surp=0 hugepages_size=2048kB
[84090.789534] 757139 total pagecache pages
[84090.789544] 234858 pages in swap cache
[84090.789547] Swap cache stats: add 194846927, delete 194599300, find
98116718/185125290
[84090.789548] Free swap  = 50231596kB
[84090.789550] Total swap = 62494716kB
[84090.789553] 8101138 pages RAM
[84090.789555] 0 pages HighMem/MovableOnly
[84090.789557] 156255 pages reserved
[84090.789559] 0 pages cma reserved
[84090.789561] 0 pages hwpoisoned
[84090.792003] opera-developer: page allocation stalls for 18291ms,
order:0, mode:0x14280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO),
nodemask=(null)
[84090.792051] opera-developer cpuset=/ mems_allowed=0
[84090.792290] CPU: 6 PID: 596 Comm: opera-developer Not tainted
4.13.11-300.fc27.x86_64+debug #1
[84090.792292] Hardware name: Gigabyte Technology Co., Ltd.
Z87M-D3H/Z87M-D3H, BIOS F11 08/12/2014
[84090.792294] Call Trace:
[84090.792300]  dump_stack+0x8e/0xd6
[84090.792305]  warn_alloc+0x114/0x1c0
[84090.792320]  __alloc_pages_slowpath+0x90f/0x1100
[84090.792348]  __alloc_pages_nodemask+0x351/0x3e0
[84090.792359]  alloc_pages_vma+0x88/0x200
[84090.792367]  __handle_mm_fault+0x80c/0x10c0
[84090.792383]  handle_mm_fault+0x14d/0x310
[84090.792390]  __do_page_fault+0x27c/0x520
[84090.792401]  do_page_fault+0x30/0x80
[84090.792407]  page_fault+0x28/0x30
[84090.792410] RIP: 0033:0x55e61a6
[84090.792412] RSP: 002b:00007fff6266fed0 EFLAGS: 00010206
[84090.792416] RAX: 0000000006d09708 RBX: 00002118a74a1f90 RCX: 00000000000001e6
[84090.792419] RDX: 0000000000000001 RSI: 00007fff6266feb8 RDI: 0000000000000023
[84090.792421] RBP: 0000000000003480 R08: 00002118a74a1fe0 R09: 00000000000000ff
[84090.792423] R10: 000000000000000f R11: 00000000002d7731 R12: 0000000000003480
[84090.792425] R13: 00001066cc511ba8 R14: 00002c458b6425c8 R15: 00007fff6266fed8
[84090.798066] Xwayland: page allocation stalls for 18238ms, order:0,
mode:0x14000d0(GFP_TEMPORARY), nodemask=(null)
[84090.798085] Xwayland cpuset=/ mems_allowed=0
[84090.798245] CPU: 3 PID: 1941 Comm: Xwayland Not tainted
4.13.11-300.fc27.x86_64+debug #1
[84090.798247] Hardware name: Gigabyte Technology Co., Ltd.
Z87M-D3H/Z87M-D3H, BIOS F11 08/12/2014
[84090.798249] Call Trace:
[84090.798255]  dump_stack+0x8e/0xd6
[84090.798260]  warn_alloc+0x114/0x1c0
[84090.798274]  __alloc_pages_slowpath+0x90f/0x1100
[84090.798303]  __alloc_pages_nodemask+0x351/0x3e0
[84090.798314]  alloc_pages_current+0x6a/0xe0
[84090.798321]  __get_free_pages+0x14/0x40
[84090.798325]  proc_pid_cmdline_read+0xa0/0x4d0
[84090.798342]  __vfs_read+0x37/0x160
[84090.798345]  ? __vfs_read+0x37/0x160
[84090.798355]  ? security_file_permission+0x9e/0xc0
[84090.798361]  vfs_read+0xa3/0x150
[84090.798368]  SyS_read+0x58/0xc0
[84090.798377]  entry_SYSCALL_64_fastpath+0x1f/0xbe
[84090.798379] RIP: 0033:0x7ff10b7945f8
[84090.798382] RSP: 002b:00007ffe1c219b50 EFLAGS: 00000246 ORIG_RAX:
0000000000000000
[84090.798386] RAX: ffffffffffffffda RBX: 00007ff0dabeb5cc RCX: 00007ff10b7945f8
[84090.798388] RDX: 0000000000001001 RSI: 00007ffe1c219b80 RDI: 000000000000004d
[84090.798390] RBP: 000000000000009b R08: 0000000000000000 R09: 0000000000000000
[84090.798392] R10: 0000000000000000 R11: 0000000000000246 R12: 00007ff0d98af3d0
[84090.798394] R13: 00000000000000d3 R14: 00007ffe1c21a574 R15: 0000000000000001
[84090.800002] chrome: page allocation stalls for 15299ms, order:0,
mode:0x14280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO), nodemask=(null)
[84090.800012] chrome cpuset=/ mems_allowed=0
[84090.800019] CPU: 6 PID: 30299 Comm: chrome Not tainted
4.13.11-300.fc27.x86_64+debug #1
[84090.800021] Hardware name: Gigabyte Technology Co., Ltd.
Z87M-D3H/Z87M-D3H, BIOS F11 08/12/2014
[84090.800023] Call Trace:
[84090.800028]  dump_stack+0x8e/0xd6
[84090.800033]  warn_alloc+0x114/0x1c0
[84090.800047]  __alloc_pages_slowpath+0x90f/0x1100
[84090.800074]  __alloc_pages_nodemask+0x351/0x3e0
[84090.800085]  alloc_pages_vma+0x88/0x200
[84090.800093]  __handle_mm_fault+0x80c/0x10c0
[84090.800108]  handle_mm_fault+0x14d/0x310
[84090.800115]  __do_page_fault+0x27c/0x520
[84090.800126]  do_page_fault+0x30/0x80
[84090.800132]  page_fault+0x28/0x30
[84090.800134] RIP: 0033:0xd40068766a6
[84090.800137] RSP: 002b:00007ffcd96713f8 EFLAGS: 00010246
[84090.800141] RAX: 00007ffcd9671460 RBX: 0000000100000000 RCX: 0000000000000001
[84090.800143] RDX: 00007ffcd9671460 RSI: 000010266eb23fd9 RDI: 000010266eb23ff9
[84090.800145] RBP: 00007ffcd9671460 R08: 000010266eb23fd8 R09: 000010266eb00000
[84090.800147] R10: 000015aca8cf32e2 R11: 0000000000000004 R12: 0000000000000039
[84090.800149] R13: 000015aca8cf40c8 R14: 00000b3ac3f75aa1 R15: 000015aca8d4f410
[84090.810993] chrome: page allocation stalls for 18307ms, order:0,
mode:0x14280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO), nodemask=(null)
[84090.811004] chrome cpuset=/ mems_allowed=0
[84090.811013] CPU: 1 PID: 28730 Comm: chrome Not tainted
4.13.11-300.fc27.x86_64+debug #1
[84090.811015] Hardware name: Gigabyte Technology Co., Ltd.
Z87M-D3H/Z87M-D3H, BIOS F11 08/12/2014
[84090.811017] Call Trace:
[84090.811022]  dump_stack+0x8e/0xd6
[84090.811027]  warn_alloc+0x114/0x1c0
[84090.811042]  __alloc_pages_slowpath+0x90f/0x1100
[84090.811071]  __alloc_pages_nodemask+0x351/0x3e0
[84090.811082]  alloc_pages_vma+0x88/0x200
[84090.811090]  __handle_mm_fault+0x80c/0x10c0
[84090.811106]  handle_mm_fault+0x14d/0x310
[84090.811113]  __do_page_fault+0x27c/0x520
[84090.811124]  do_page_fault+0x30/0x80
[84090.811130]  page_fault+0x28/0x30
[84090.811133] RIP: 0033:0x55a791f4cb05
[84090.811135] RSP: 002b:00007ffcd9670ef0 EFLAGS: 00010206
[84090.811140] RAX: 0000000000000002 RBX: 000026c35b021779 RCX: 000031b408d82251
[84090.811142] RDX: 0000000000000000 RSI: 0000000000000028 RDI: 000015aca8ce5020
[84090.811144] RBP: 0000000000000028 R08: 000012e76bfc3800 R09: 00000000000000ff
[84090.811146] R10: 000012e76be1d4f0 R11: 0000000000000004 R12: 000026c35b021778
[84090.811148] R13: 0000000000000000 R14: 0000000000000005 R15: 0000299892049ff1
[84090.813094] chrome: page allocation stalls for 18307ms, order:0,
mode:0x14280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO), nodemask=(null)
[84090.813104] chrome cpuset=/ mems_allowed=0
[84090.813112] CPU: 0 PID: 30360 Comm: chrome Not tainted
4.13.11-300.fc27.x86_64+debug #1
[84090.813114] Hardware name: Gigabyte Technology Co., Ltd.
Z87M-D3H/Z87M-D3H, BIOS F11 08/12/2014
[84090.813115] Call Trace:
[84090.813120]  dump_stack+0x8e/0xd6
[84090.813125]  warn_alloc+0x114/0x1c0
[84090.813139]  __alloc_pages_slowpath+0x90f/0x1100
[84090.813167]  __alloc_pages_nodemask+0x351/0x3e0
[84090.813178]  alloc_pages_vma+0x88/0x200
[84090.813185]  __handle_mm_fault+0x80c/0x10c0
[84090.813201]  handle_mm_fault+0x14d/0x310
[84090.813207]  __do_page_fault+0x27c/0x520
[84090.813218]  do_page_fault+0x30/0x80
[84090.813224]  page_fault+0x28/0x30
[84090.813226] RIP: 0033:0x55a791f4cb05
[84090.813229] RSP: 002b:00007ffcd9671030 EFLAGS: 00010202
[84090.813232] RAX: 0000000000000001 RBX: 00001807ce284051 RCX: 00003a19b0d02251
[84090.813234] RDX: 0000000000000000 RSI: 0000000000000028 RDI: 000015aca8d0d020
[84090.813237] RBP: 0000000000000028 R08: 000012ab824a5000 R09: 0000000000000040
[84090.813239] R10: 000015aca8d0ea90 R11: 00002e6f82423771 R12: 00001807ce284050
[84090.813241] R13: 0000000000000000 R14: 0000000000000005 R15: 00003d1dc4682ff9
[84090.813553] chrome: page allocation stalls for 18308ms, order:0,
mode:0x14280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO), nodemask=(null)
[84090.813562] chrome cpuset=/ mems_allowed=0
[84090.813569] CPU: 0 PID: 28939 Comm: chrome Not tainted
4.13.11-300.fc27.x86_64+debug #1
[84090.813571] Hardware name: Gigabyte Technology Co., Ltd.
Z87M-D3H/Z87M-D3H, BIOS F11 08/12/2014
[84090.813573] Call Trace:
[84090.813577]  dump_stack+0x8e/0xd6
[84090.813581]  warn_alloc+0x114/0x1c0
[84090.813595]  __alloc_pages_slowpath+0x90f/0x1100
[84090.813623]  __alloc_pages_nodemask+0x351/0x3e0
[84090.813633]  alloc_pages_vma+0x88/0x200
[84090.813641]  __handle_mm_fault+0x80c/0x10c0
[84090.813656]  handle_mm_fault+0x14d/0x310
[84090.813662]  __do_page_fault+0x27c/0x520
[84090.813673]  do_page_fault+0x30/0x80
[84090.813679]  page_fault+0x28/0x30
[84090.813681] RIP: 0033:0xe0f42b742d3
[84090.813683] RSP: 002b:00007ffcd9671370 EFLAGS: 00010216
[84090.813687] RAX: 000021ae89ba6001 RBX: 0000000000000002 RCX: 000013af2ed0c429
[84090.813689] RDX: 00007ffcd9671450 RSI: 000015aca8c3c470 RDI: 000021ae89ba6000
[84090.813691] RBP: 00007ffcd96713c8 R08: 000021ae89ba6028 R09: 0000000300000000
[84090.813693] R10: 000015aca8d16a80 R11: 0000000000000003 R12: 00000000000000ee
[84090.813695] R13: 000015aca8d150c8 R14: 000002911cf022f1 R15: 000015aca8d2a410
[84090.814016] chrome: page allocation stalls for 18906ms, order:0,
mode:0x14280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO), nodemask=(null)
[84090.814025] chrome cpuset=/ mems_allowed=0
[84090.814033] CPU: 6 PID: 28014 Comm: chrome Not tainted
4.13.11-300.fc27.x86_64+debug #1
[84090.814035] Hardware name: Gigabyte Technology Co., Ltd.
Z87M-D3H/Z87M-D3H, BIOS F11 08/12/2014
[84090.814037] Call Trace:
[84090.814042]  dump_stack+0x8e/0xd6
[84090.814046]  warn_alloc+0x114/0x1c0
[84090.814060]  __alloc_pages_slowpath+0x90f/0x1100
[84090.814071]  ? trace_hardirqs_on_caller+0xf4/0x190
[84090.814091]  __alloc_pages_nodemask+0x351/0x3e0
[84090.814102]  alloc_pages_vma+0x88/0x200
[84090.814110]  __handle_mm_fault+0x80c/0x10c0
[84090.814126]  handle_mm_fault+0x14d/0x310
[84090.814132]  __do_page_fault+0x27c/0x520
[84090.814143]  do_page_fault+0x30/0x80
[84090.814149]  page_fault+0x28/0x30
[84090.814151] RIP: 0033:0x555db4ee880e
[84090.814153] RSP: 002b:00007ffe3e24cc30 EFLAGS: 00010206
[84090.814157] RAX: 0000005000007033 RBX: 00007ffe3e24cca0 RCX: 0000000000040000
[84090.814159] RDX: 00000000000005a4 RSI: 00007ffe3e24cca0 RDI: 00003743885aa000
[84090.814161] RBP: 00003743885b0000 R08: 000000000000000c R09: 0000000000000000
[84090.814164] R10: 00007ffe3e24cc20 R11: 0000000000000001 R12: 00003743885aa000
[84090.814166] R13: 00003743885a4000 R14: 00003743885aa000 R15: 00007ffe3e24cca0
[84090.822003] chrome: page allocation stalls for 18320ms, order:0,
mode:0x14280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO), nodemask=(null)
[84090.822012] chrome cpuset=/ mems_allowed=0
[84090.822020] CPU: 6 PID: 30640 Comm: chrome Not tainted
4.13.11-300.fc27.x86_64+debug #1
[84090.822022] Hardware name: Gigabyte Technology Co., Ltd.
Z87M-D3H/Z87M-D3H, BIOS F11 08/12/2014
[84090.822024] Call Trace:
[84090.822028]  dump_stack+0x8e/0xd6
[84090.822033]  warn_alloc+0x114/0x1c0
[84090.822047]  __alloc_pages_slowpath+0x90f/0x1100
[84090.822075]  __alloc_pages_nodemask+0x351/0x3e0
[84090.822086]  alloc_pages_vma+0x88/0x200
[84090.822093]  __handle_mm_fault+0x80c/0x10c0
[84090.822109]  handle_mm_fault+0x14d/0x310
[84090.822115]  __do_page_fault+0x27c/0x520
[84090.822126]  do_page_fault+0x30/0x80
[84090.822132]  page_fault+0x28/0x30
[84090.822135] RIP: 0033:0x31987265fae
[84090.822137] RSP: 002b:00007ffcd9671190 EFLAGS: 00010206
[84090.822141] RAX: 00002125bf9be001 RBX: 00007ffcd96711d8 RCX: 00000161b46024d1
[84090.822143] RDX: 000023e7d0ada559 RSI: 0000000000000003 RDI: 00002125bf9be010
[84090.822145] RBP: 00007ffcd96711d8 R08: 00000161b46024d1 R09: 0000094d4dcd85b9
[84090.822147] R10: 000015aca8cd91c2 R11: 0000000000000003 R12: 0000000000000050
[84090.822149] R13: 000015aca8ce40c8 R14: 000023e7d0ada471 R15: 000015aca8d44410
[84093.851332] warn_alloc: 183 callbacks suppressed
[84093.851334] chrome: page allocation stalls for 21346ms, order:0,
mode:0x14200ca(GFP_HIGHUSER_MOVABLE), nodemask=(null)
[84093.851345] chrome cpuset=/ mems_allowed=0
[84093.851354] CPU: 5 PID: 29652 Comm: chrome Not tainted
4.13.11-300.fc27.x86_64+debug #1
[84093.851356] Hardware name: Gigabyte Technology Co., Ltd.
Z87M-D3H/Z87M-D3H, BIOS F11 08/12/2014
[84093.851358] Call Trace:
[84093.851365]  dump_stack+0x8e/0xd6
[84093.851370]  warn_alloc+0x114/0x1c0
[84093.851385]  __alloc_pages_slowpath+0x90f/0x1100
[84093.851413]  __alloc_pages_nodemask+0x351/0x3e0
[84093.851424]  alloc_pages_vma+0x88/0x200
[84093.851432]  __read_swap_cache_async+0x168/0x270
[84093.851441]  read_swap_cache_async+0x2b/0x60
[84093.851447]  swapin_readahead+0x196/0x250
[84093.851453]  ? find_get_entry+0x191/0x280
[84093.851464]  do_swap_page+0x268/0x880
[84093.851467]  ? do_swap_page+0x268/0x880
[84093.851476]  __handle_mm_fault+0x725/0x10c0
[84093.851492]  handle_mm_fault+0x14d/0x310
[84093.851499]  __do_page_fault+0x27c/0x520
[84093.851511]  do_page_fault+0x30/0x80
[84093.851517]  page_fault+0x28/0x30
[84093.851520] RIP: 0033:0x55a793936494
[84093.851522] RSP: 002b:00007ffcd9670e50 EFLAGS: 00010246
[84093.851526] RAX: 00001765e032aa0c RBX: 000023fe42e97800 RCX: 000000000000002d
[84093.851528] RDX: 000000000000002d RSI: 00007ffcd9670e78 RDI: 00001765dd99cca0
[84093.851531] RBP: 00003169ddae8501 R08: 0000000000000800 R09: 000000000000007f
[84093.851533] R10: 00001765ddc5ee80 R11: 0000000000000002 R12: 00000070c15cc7b8
[84093.851535] R13: 000023fe42e97800 R14: 0000000000000000 R15: 00003169ddae85d0
[84093.851574] warn_alloc_show_mem: 8 callbacks suppressed
[84093.851574] Mem-Info:
[84093.851579] active_anon:6588960 inactive_anon:494211 isolated_anon:3993
                active_file:50320 inactive_file:29174 isolated_file:0
                unevictable:6049 dirty:617 writeback:1403 unstable:0
                slab_reclaimable:68966 slab_unreclaimable:99234
                mapped:380607 shmem:412233 pagetables:95312 bounce:0
                free:386589 free_pcp:1195 free_cma:0
[84093.851584] Node 0 active_anon:26355840kB inactive_anon:1976844kB
active_file:201280kB inactive_file:116696kB unevictable:24196kB
isolated(anon):15972kB isolated(file):0kB mapped:1522428kB
dirty:2468kB writeback:5612kB shmem:1648932kB shmem_thp: 0kB
shmem_pmdmapped: 0kB anon_thp: 237568kB writeback_tmp:0kB unstable:0kB
all_unreclaimable? no
[84093.851586] Node 0 DMA free:15864kB min:1048kB low:1308kB
high:1568kB active_anon:0kB inactive_anon:0kB active_file:0kB
inactive_file:0kB unevictable:0kB writepending:0kB present:15988kB
managed:15896kB mlocked:0kB kernel_stack:0kB pagetables:0kB bounce:0kB
free_pcp:0kB local_pcp:0kB free_cma:0kB
[84093.851591] lowmem_reserve[]: 0 2371 30994 30994 30994
[84093.851605] Node 0 DMA32 free:122652kB min:161588kB low:201984kB
high:242380kB active_anon:2211624kB inactive_anon:35248kB
active_file:4420kB inactive_file:480kB unevictable:184kB
writepending:0kB present:2514388kB managed:2448676kB mlocked:184kB
kernel_stack:432kB pagetables:13372kB bounce:0kB free_pcp:12kB
local_pcp:0kB free_cma:0kB
[84093.851611] lowmem_reserve[]: 0 0 28622 28622 28622
[84093.851623] Node 0 Normal free:1407840kB min:1934512kB
low:2418140kB high:2901768kB active_anon:24144964kB
inactive_anon:1941808kB active_file:197156kB inactive_file:116108kB
unevictable:24012kB writepending:8952kB present:29874176kB
managed:29314960kB mlocked:24012kB kernel_stack:53088kB
pagetables:367876kB bounce:0kB free_pcp:4812kB local_pcp:572kB
free_cma:0kB
[84093.851629] lowmem_reserve[]: 0 0 0 0 0
[84093.851642] Node 0 DMA: 2*4kB (U) 2*8kB (U) 0*16kB 1*32kB (U)
3*64kB (U) 2*128kB (U) 0*256kB 0*512kB 1*1024kB (U) 1*2048kB (M)
3*4096kB (M) = 15864kB
[84093.851684] Node 0 DMA32: 853*4kB (UME) 374*8kB (UME) 504*16kB
(UMEH) 373*32kB (UMEH) 286*64kB (UMEH) 223*128kB (UMEH) 125*256kB
(UMEH) 32*512kB (UME) 1*1024kB (M) 0*2048kB 0*4096kB = 122660kB
[84093.851728] Node 0 Normal: 118883*4kB (UME) 33580*8kB (UME)
11806*16kB (UMEH) 6233*32kB (UMEH) 2622*64kB (UMEH) 786*128kB (UMEH)
23*256kB (ME) 1*512kB (M) 3*1024kB (M) 0*2048kB 0*4096kB = 1410412kB
[84093.851773] Node 0 hugepages_total=0 hugepages_free=0
hugepages_surp=0 hugepages_size=1048576kB
[84093.851775] Node 0 hugepages_total=0 hugepages_free=0
hugepages_surp=0 hugepages_size=2048kB
[84093.851777] 740234 total pagecache pages
[84093.851788] 247796 pages in swap cache
[84093.851790] Swap cache stats: add 194966621, delete 194706071, find
98116718/185125292
[84093.851792] Free swap  = 49756460kB
[84093.851794] Total swap = 62494716kB
[84093.851814] 8101138 pages RAM
[84093.851816] 0 pages HighMem/MovableOnly
[84093.851818] 156255 pages reserved
[84093.851820] 0 pages cma reserved
[84093.851822] 0 pages hwpoisoned
[84094.024045] firefox: page allocation stalls for 20179ms, order:0,
mode:0x14280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO), nodemask=(null)
[84094.024056] firefox cpuset=/ mems_allowed=0
[84094.024066] CPU: 4 PID: 32080 Comm: firefox Not tainted
4.13.11-300.fc27.x86_64+debug #1
[84094.024068] Hardware name: Gigabyte Technology Co., Ltd.
Z87M-D3H/Z87M-D3H, BIOS F11 08/12/2014
[84094.024070] Call Trace:
[84094.024077]  dump_stack+0x8e/0xd6
[84094.024083]  warn_alloc+0x114/0x1c0
[84094.024097]  __alloc_pages_slowpath+0x90f/0x1100
[84094.024125]  __alloc_pages_nodemask+0x351/0x3e0
[84094.024137]  alloc_pages_vma+0x88/0x200
[84094.024145]  __handle_mm_fault+0x80c/0x10c0
[84094.024161]  handle_mm_fault+0x14d/0x310
[84094.024168]  __do_page_fault+0x27c/0x520
[84094.024179]  do_page_fault+0x30/0x80
[84094.024186]  page_fault+0x28/0x30
[84094.024189] RIP: 0033:0x7f0f731416ad
[84094.024191] RSP: 002b:00007ffe020c9320 EFLAGS: 00010206
[84094.024195] RAX: 000000000000003f RBX: 00007f0f1ab00000 RCX: 00007f0f1ab3e000
[84094.024197] RDX: 0000000000000001 RSI: 0000000000000000 RDI: 000000000003e000
[84094.024200] RBP: 00007ffe020c93b0 R08: 0000000000000000 R09: 00007f0f5e9de000
[84094.024202] R10: 00007f0f1ab3e000 R11: 000000000000003e R12: 0000000000000007
[84094.024204] R13: 00007f0f5c4d9000 R14: 00007f0f5c4d91c0 R15: 0000000000000007
[84094.066024] opera-developer: page allocation stalls for 20565ms,
order:0, mode:0x14200ca(GFP_HIGHUSER_MOVABLE), nodemask=(null)
[84094.066034] opera-developer cpuset=/ mems_allowed=0
[84094.066043] CPU: 1 PID: 651 Comm: opera-developer Not tainted
4.13.11-300.fc27.x86_64+debug #1
[84094.066045] Hardware name: Gigabyte Technology Co., Ltd.
Z87M-D3H/Z87M-D3H, BIOS F11 08/12/2014
[84094.066047] Call Trace:
[84094.066053]  dump_stack+0x8e/0xd6
[84094.066058]  warn_alloc+0x114/0x1c0
[84094.066072]  __alloc_pages_slowpath+0x90f/0x1100
[84094.066099]  __alloc_pages_nodemask+0x351/0x3e0
[84094.066111]  alloc_pages_vma+0x88/0x200
[84094.066119]  __read_swap_cache_async+0x168/0x270
[84094.066128]  read_swap_cache_async+0x2b/0x60
[84094.066133]  swapin_readahead+0x196/0x250
[84094.066139]  ? find_get_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
