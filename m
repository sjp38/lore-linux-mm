Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id EC4B08E005B
	for <linux-mm@kvack.org>; Mon, 31 Dec 2018 02:49:33 -0500 (EST)
Received: by mail-it1-f197.google.com with SMTP id x82so31283251ita.9
        for <linux-mm@kvack.org>; Sun, 30 Dec 2018 23:49:33 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x64sor26843296iof.102.2018.12.30.23.49.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 30 Dec 2018 23:49:31 -0800 (PST)
MIME-Version: 1.0
References: <0000000000007beca9057e4c8c14@google.com>
In-Reply-To: <0000000000007beca9057e4c8c14@google.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Mon, 31 Dec 2018 08:49:19 +0100
Message-ID: <CACT4Y+Yx4BJw=F_PMx9a8AjPKzEwhzLnzt9K-dgkBoNkKQj2+g@mail.gmail.com>
Subject: Re: INFO: rcu detected stall in ndisc_alloc_skb
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: syzbot <syzbot+ea7d9cb314b4ab49a18a@syzkaller.appspotmail.com>
Cc: David Miller <davem@davemloft.net>, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, LKML <linux-kernel@vger.kernel.org>, netdev <netdev@vger.kernel.org>, syzkaller-bugs <syzkaller-bugs@googlegroups.com>, Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>, Linux-MM <linux-mm@kvack.org>

On Mon, Dec 31, 2018 at 8:42 AM syzbot
<syzbot+ea7d9cb314b4ab49a18a@syzkaller.appspotmail.com> wrote:
>
> Hello,
>
> syzbot found the following crash on:
>
> HEAD commit:    ef4ab8447aa2 selftests: bpf: install script with_addr.sh
> git tree:       bpf-next
> console output: https://syzkaller.appspot.com/x/log.txt?x=14a28b6e400000
> kernel config:  https://syzkaller.appspot.com/x/.config?x=7e7e2279c0020d5f
> dashboard link: https://syzkaller.appspot.com/bug?extid=ea7d9cb314b4ab49a18a
> compiler:       gcc (GCC) 8.0.1 20180413 (experimental)
>
> Unfortunately, I don't have any reproducer for this crash yet.
>
> IMPORTANT: if you fix the bug, please add the following tag to the commit:
> Reported-by: syzbot+ea7d9cb314b4ab49a18a@syzkaller.appspotmail.com

Since this involves OOMs and looks like a one-off induced memory corruption:

#syz dup: kernel panic: corrupted stack end in wb_workfn

> CPU: 1 PID: 5702 Comm: rsyslogd Not tainted 4.19.0-rc6+ #118
> rcu: INFO: rcu_preempt detected stalls on CPUs/tasks:
> Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS
> Google 01/01/2011
> Call Trace:
> rcu:    (detected by 0, t=10712 jiffies, g=90369, q=135)
>   <IRQ>
>   __dump_stack lib/dump_stack.c:77 [inline]
>   dump_stack+0x1c4/0x2b4 lib/dump_stack.c:113
> rcu: All QSes seen, last rcu_preempt kthread activity 10548
> (4295003843-4294993295), jiffies_till_next_fqs=1, root ->qsmask 0x0
> syz-executor0   R
>    running task
>   warn_alloc.cold.119+0xb7/0x1bd mm/page_alloc.c:3426
> 22896  7592   5826 0x8010000c
> Call Trace:
>   <IRQ>
>   sched_show_task.cold.83+0x2b6/0x30a kernel/sched/core.c:5296
>   __alloc_pages_slowpath+0x2667/0x2d80 mm/page_alloc.c:4297
>   print_other_cpu_stall.cold.79+0xa83/0xba5 kernel/rcu/tree.c:1430
>   check_cpu_stall kernel/rcu/tree.c:1557 [inline]
>   __rcu_pending kernel/rcu/tree.c:3276 [inline]
>   rcu_pending kernel/rcu/tree.c:3319 [inline]
>   rcu_check_callbacks+0xafc/0x1990 kernel/rcu/tree.c:2665
>   __alloc_pages_nodemask+0xa80/0xde0 mm/page_alloc.c:4390
>   __alloc_pages include/linux/gfp.h:473 [inline]
>   __alloc_pages_node include/linux/gfp.h:486 [inline]
>   kmem_getpages mm/slab.c:1409 [inline]
>   cache_grow_begin+0x91/0x8c0 mm/slab.c:2677
>   fallback_alloc+0x203/0x2e0 mm/slab.c:3219
>   ____cache_alloc_node+0x1c7/0x1e0 mm/slab.c:3287
>   slab_alloc_node mm/slab.c:3327 [inline]
>   kmem_cache_alloc_node+0xe3/0x730 mm/slab.c:3642
>   __alloc_skb+0x119/0x770 net/core/skbuff.c:193
>   alloc_skb include/linux/skbuff.h:997 [inline]
>   ndisc_alloc_skb+0x144/0x340 net/ipv6/ndisc.c:403
>   ndisc_send_rs+0x331/0x6e0 net/ipv6/ndisc.c:669
>   update_process_times+0x2d/0x70 kernel/time/timer.c:1636
>   addrconf_rs_timer+0x314/0x690 net/ipv6/addrconf.c:3836
>   tick_sched_handle+0x9f/0x180 kernel/time/tick-sched.c:164
>   tick_sched_timer+0x45/0x130 kernel/time/tick-sched.c:1274
>   __run_hrtimer kernel/time/hrtimer.c:1398 [inline]
>   __hrtimer_run_queues+0x41c/0x10d0 kernel/time/hrtimer.c:1460
>   call_timer_fn+0x272/0x920 kernel/time/timer.c:1326
>   hrtimer_interrupt+0x313/0x780 kernel/time/hrtimer.c:1518
>   local_apic_timer_interrupt arch/x86/kernel/apic/apic.c:1029 [inline]
>   smp_apic_timer_interrupt+0x1a1/0x760 arch/x86/kernel/apic/apic.c:1054
>   apic_timer_interrupt+0xf/0x20 arch/x86/entry/entry_64.S:864
> RIP: 0010:arch_local_irq_restore arch/x86/include/asm/paravirt.h:788
> [inline]
> RIP: 0010:slab_alloc_node mm/slab.c:3329 [inline]
> RIP: 0010:kmem_cache_alloc_node+0x247/0x730 mm/slab.c:3642
> Code: 3f 7e 0f 85 32 ff ff ff e8 a5 7f 3e ff e9 28 ff ff ff e8 0c e3 c2 ff
> 48 83 3d 5c f4 6f 07 00 0f 84 33 01 00 00 4c 89 ff 57 9d <0f> 1f 44 00 00
> e9 bf fe ff ff 31 d2 be a5 01 00 00 48 c7 c7 62 23
> RSP: 0000:ffff8801dae07450 EFLAGS: 00000286 ORIG_RAX: ffffffffffffff13
> RAX: 0000000000000000 RBX: 0000000000480020 RCX: ffffffff8184e1ca
> RDX: 0000000000000004 RSI: ffffffff8184e1e4 RDI: 0000000000000286
> RBP: ffff8801dae074c0 R08: ffff880193c38700 R09: fffffbfff12812c4
> R10: ffff8801dae06098 R11: ffffffff89409623 R12: ffff8801d9a04040
> R13: ffff8801d9a04040 R14: 0000000000000000 R15: 0000000000000286
>   __alloc_skb+0x119/0x770 net/core/skbuff.c:193
>   alloc_skb include/linux/skbuff.h:997 [inline]
>   ndisc_alloc_skb+0x144/0x340 net/ipv6/ndisc.c:403
>   expire_timers kernel/time/timer.c:1363 [inline]
>   __run_timers+0x7e5/0xc70 kernel/time/timer.c:1682
>   ndisc_send_rs+0x331/0x6e0 net/ipv6/ndisc.c:669
>   addrconf_rs_timer+0x314/0x690 net/ipv6/addrconf.c:3836
>   call_timer_fn+0x272/0x920 kernel/time/timer.c:1326
>   run_timer_softirq+0x52/0xb0 kernel/time/timer.c:1695
>   __do_softirq+0x30b/0xad8 kernel/softirq.c:292
>   expire_timers kernel/time/timer.c:1363 [inline]
>   __run_timers+0x7e5/0xc70 kernel/time/timer.c:1682
>   invoke_softirq kernel/softirq.c:372 [inline]
>   irq_exit+0x17f/0x1c0 kernel/softirq.c:412
>   exiting_irq arch/x86/include/asm/apic.h:536 [inline]
>   smp_apic_timer_interrupt+0x1cb/0x760 arch/x86/kernel/apic/apic.c:1056
>   run_timer_softirq+0x52/0xb0 kernel/time/timer.c:1695
>   __do_softirq+0x30b/0xad8 kernel/softirq.c:292
>   apic_timer_interrupt+0xf/0x20 arch/x86/entry/entry_64.S:864
>   </IRQ>
> RIP: 0010:arch_local_irq_restore arch/x86/include/asm/paravirt.h:788
> [inline]
> RIP: 0010:console_unlock+0xfdf/0x1160 kernel/printk/printk.c:2409
> Code: c1 e8 03 42 80 3c 20 00 0f 85 d1 00 00 00 48 83 3d cd 54 cd 07 00 0f
> 84 bc 00 00 00 e8 ca 37 1a 00 48 8b bd b0 fe ff ff 57 9d <0f> 1f 44 00 00
> e9 cc f9 ff ff 48 8b bd c8 fe ff ff e8 3b d8 5d 00
> RSP: 0000:ffff8801bccde450 EFLAGS: 00000293
>   ORIG_RAX: ffffffffffffff13
>   invoke_softirq kernel/softirq.c:372 [inline]
>   irq_exit+0x17f/0x1c0 kernel/softirq.c:412
> RAX: ffff8801bd36a180 RBX: 0000000000000200 RCX: ffffffff8184e1ca
> RDX: 0000000000000000 RSI: ffffffff81649dc6 RDI: 0000000000000293
>   exiting_irq arch/x86/include/asm/apic.h:536 [inline]
>   smp_apic_timer_interrupt+0x1cb/0x760 arch/x86/kernel/apic/apic.c:1056
> RBP: ffff8801bccde5b8 R08: ffff8801bd36a180 R09: fffffbfff12720c0
> R10: fffffbfff12720c0 R11: ffffffff89390603 R12: dffffc0000000000
> R13: ffffffff84885bf0 R14: dffffc0000000000 R15: ffffffff899428d0
>   vprintk_emit+0x33d/0x930 kernel/printk/printk.c:1922
>   apic_timer_interrupt+0xf/0x20 arch/x86/entry/entry_64.S:864
>   </IRQ>
> RIP: 0010:arch_local_irq_restore arch/x86/include/asm/paravirt.h:788
> [inline]
> RIP: 0010:slab_alloc mm/slab.c:3385 [inline]
> RIP: 0010:kmem_cache_alloc+0x297/0x730 mm/slab.c:3552
> Code: 7e 0f 85 cf fe ff ff e8 06 60 3e ff e9 c5 fe ff ff e8 6d c3 c2 ff 48
> 83 3d bd d4 6f 07 00 0f 84 3b 03 00 00 48 8b 7d d0 57 9d <0f> 1f 44 00 00
> e9 54 fe ff ff 31 d2 be a5 01 00 00 48 c7 c7 62 23
> RSP: 0000:ffff8801980a7748 EFLAGS: 00000286
>   vprintk_default+0x28/0x30 kernel/printk/printk.c:1963
>   ORIG_RAX: ffffffffffffff13
>   vprintk_func+0x7e/0x181 kernel/printk/printk_safe.c:398
> RAX: 0000000000000000 RBX: 0000000000480020 RCX: ffffc90001e5c000
>   printk+0xa7/0xcf kernel/printk/printk.c:1996
> RDX: 0000000000000004 RSI: ffffffff8184e1e4 RDI: 0000000000000286
> RBP: ffff8801980a77b0 R08: ffff880193c38700 R09: fffffbfff12812c4
> R10: ffff8801980a6390 R11: ffffffff89409623 R12: 0000000000000000
>   dump_unreclaimable_slab.cold.22+0xd8/0xe5 mm/slab_common.c:1371
> R13: ffff8801d9a04040 R14: ffff8801d9a04040 R15: 0000000000480020
>   dump_header+0x7cc/0xf72 mm/oom_kill.c:447
>   skb_clone+0x1bb/0x500 net/core/skbuff.c:1280
>   ____bpf_clone_redirect net/core/filter.c:2079 [inline]
>   bpf_clone_redirect+0xb9/0x490 net/core/filter.c:2066
>   bpf_prog_41f2bcae09cd4ac3+0x194/0x1000
>   oom_kill_process.cold.27+0x10/0x903 mm/oom_kill.c:953
>   out_of_memory+0xa84/0x1430 mm/oom_kill.c:1120
>   __alloc_pages_may_oom mm/page_alloc.c:3522 [inline]
>   __alloc_pages_slowpath+0x2318/0x2d80 mm/page_alloc.c:4235
> rcu: rcu_preempt kthread starved for 10548 jiffies! g90369 f0x2
> RCU_GP_WAIT_FQS(5) ->state=0x0 ->cpu=1
> rcu: RCU grace-period kthread stack dump:
> rcu_preempt     R
>    running task    22736    10      2 0x80000000
> Call Trace:
>   context_switch kernel/sched/core.c:2825 [inline]
>   __schedule+0x86c/0x1ed0 kernel/sched/core.c:3473
>   __alloc_pages_nodemask+0xa80/0xde0 mm/page_alloc.c:4390
>   schedule+0xfe/0x460 kernel/sched/core.c:3517
>   __alloc_pages include/linux/gfp.h:473 [inline]
>   __alloc_pages_node include/linux/gfp.h:486 [inline]
>   kmem_getpages mm/slab.c:1409 [inline]
>   cache_grow_begin+0x91/0x8c0 mm/slab.c:2677
>   schedule_timeout+0x140/0x260 kernel/time/timer.c:1804
>   fallback_alloc+0x203/0x2e0 mm/slab.c:3219
>   ____cache_alloc_node+0x1c7/0x1e0 mm/slab.c:3287
>   __do_cache_alloc mm/slab.c:3356 [inline]
>   slab_alloc mm/slab.c:3384 [inline]
>   kmem_cache_alloc_trace+0x214/0x750 mm/slab.c:3618
>   rcu_gp_kthread+0x9d9/0x2310 kernel/rcu/tree.c:2194
>   kmalloc include/linux/slab.h:513 [inline]
>   syslog_print kernel/printk/printk.c:1297 [inline]
>   do_syslog+0xb9b/0x1690 kernel/printk/printk.c:1465
>   kmsg_read+0x8f/0xc0 fs/proc/kmsg.c:40
>   proc_reg_read+0x2a3/0x3d0 fs/proc/inode.c:231
>   __vfs_read+0x117/0x9b0 fs/read_write.c:416
>   vfs_read+0x17f/0x3c0 fs/read_write.c:452
>   ksys_read+0x101/0x260 fs/read_write.c:578
>   __do_sys_read fs/read_write.c:588 [inline]
>   __se_sys_read fs/read_write.c:586 [inline]
>   __x64_sys_read+0x73/0xb0 fs/read_write.c:586
>   do_syscall_64+0x1b9/0x820 arch/x86/entry/common.c:290
>   entry_SYSCALL_64_after_hwframe+0x49/0xbe
> RIP: 0033:0x7f5bbee581fd
> Code: Bad RIP value.
> RSP: 002b:00007f5bbc3f7e30 EFLAGS: 00000293
>   ORIG_RAX: 0000000000000000
> RAX: ffffffffffffffda RBX: 0000000001bc9ce0 RCX: 00007f5bbee581fd
> RDX: 0000000000000fff RSI: 00007f5bbdc2c5a0 RDI: 0000000000000004
> RBP: 0000000000000000 R08: 0000000001bb5260 R09: 0000000000000000
> R10: 6b205d3334383630 R11: 0000000000000293 R12: 000000000065e420
> R13: 00007f5bbc3f89c0 R14: 00007f5bbf49d040 R15: 0000000000000003
> warn_alloc_show_mem: 1 callbacks suppressed
> Mem-Info:
> active_anon:48193 inactive_anon:137 isolated_anon:0
>   active_file:16 inactive_file:15 isolated_file:0
>   unevictable:0 dirty:0 writeback:0 unstable:0
>   slab_reclaimable:9165 slab_unreclaimable:1475206
>   mapped:8194 shmem:144 pagetables:402 bounce:0
>   free:13771 free_pcp:443 free_cma:0
> Node 0 active_anon:192772kB inactive_anon:548kB active_file:64kB
> inactive_file:60kB unevictable:0kB isolated(anon):0kB isolated(file):0kB
> mapped:32776kB dirty:0kB writeback:0kB shmem:576kB shmem_thp: 0kB
> shmem_pmdmapped: 0kB anon_thp: 178176kB writeback_tmp:0kB unstable:0kB
> all_unreclaimable? yes
> Node 0
> DMA free:15908kB min:164kB low:204kB high:244kB active_anon:0kB
> inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB
> writepending:0kB present:15992kB managed:15908kB mlocked:0kB
> kernel_stack:0kB pagetables:0kB bounce:0kB free_pcp:0kB local_pcp:0kB
> free_cma:0kB
> lowmem_reserve[]:
>   0
>   2819
>   6323
>   6323
> Node 0
> DMA32 free:25264kB min:30060kB low:37572kB high:45084kB active_anon:0kB
> inactive_anon:0kB active_file:4kB inactive_file:0kB unevictable:0kB
> writepending:0kB present:3129332kB managed:2890736kB mlocked:0kB
> kernel_stack:0kB pagetables:0kB bounce:0kB free_pcp:248kB local_pcp:0kB
> free_cma:0kB
> lowmem_reserve[]:
>   0
>   0
>   3503
>   3503
> Node 0
> Normal free:13912kB min:37352kB low:46688kB high:56024kB
> active_anon:192772kB inactive_anon:548kB active_file:60kB
> inactive_file:60kB unevictable:0kB writepending:0kB present:4718592kB
> managed:3588044kB mlocked:0kB kernel_stack:5248kB pagetables:1608kB
> bounce:0kB free_pcp:1524kB local_pcp:1456kB free_cma:0kB
> lowmem_reserve[]:
>   kthread+0x35a/0x420 kernel/kthread.c:246
>   0
>   0
>   0
>   ret_from_fork+0x3a/0x50 arch/x86/entry/entry_64.S:413
>   0
> ICMPv6: ndisc: ndisc_alloc_skb failed to allocate an skb
> Node 0 DMA: 1*4kB (U) 0*8kB 0*16kB 1*32kB
> syz-executor0: page allocation failure: order:0, mode:0x484020(GFP_ATOMIC|
> __GFP_COMP), nodemask=(null)
> (U)
> syz-executor0 cpuset=
> 2*64kB
> syz0
> (U)
>   mems_allowed=0
> 1*128kB
> CPU: 0 PID: 7592 Comm: syz-executor0 Not tainted 4.19.0-rc6+ #118
> (U)
> Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS
> Google 01/01/2011
> 1*256kB (U)
> Call Trace:
> 0*512kB
>   <IRQ>
> 1*1024kB
>   __dump_stack lib/dump_stack.c:77 [inline]
>   dump_stack+0x1c4/0x2b4 lib/dump_stack.c:113
> (U)
> 1*2048kB
>   warn_alloc.cold.119+0xb7/0x1bd mm/page_alloc.c:3426
> (M)
> 3*4096kB
> (M)
> = 15908kB
> Node 0
>   __alloc_pages_slowpath+0x2667/0x2d80 mm/page_alloc.c:4297
> DMA32:
> 4*4kB
> (UM)
> 2*8kB (M)
> 3*16kB
> (M)
> 3*32kB
> (M)
> 4*64kB
> (UM)
> 4*128kB
> (UM)
> 3*256kB
> (M)
> 4*512kB
> (UM)
> 3*1024kB
> (UM)
> 3*2048kB
> (M)
> 3*4096kB
> (M)
> = 25264kB
> Node 0
> Normal:
> 942*4kB
> (UME)
>   __alloc_pages_nodemask+0xa80/0xde0 mm/page_alloc.c:4390
> 338*8kB
> (UMEH)
> 149*16kB
> (UME)
> 84*32kB
> (UMEH)
>   __alloc_pages include/linux/gfp.h:473 [inline]
>   __alloc_pages_node include/linux/gfp.h:486 [inline]
>   kmem_getpages mm/slab.c:1409 [inline]
>   cache_grow_begin+0x91/0x8c0 mm/slab.c:2677
> 25*64kB (UM)
> 2*128kB
>   fallback_alloc+0x203/0x2e0 mm/slab.c:3219
> (UH)
>   ____cache_alloc_node+0x1c7/0x1e0 mm/slab.c:3287
> 0*256kB
>   slab_alloc_node mm/slab.c:3327 [inline]
>   kmem_cache_alloc_node+0xe3/0x730 mm/slab.c:3642
> 1*512kB
> (H)
>   __alloc_skb+0x119/0x770 net/core/skbuff.c:193
> 0*1024kB
> 0*2048kB 0*4096kB
> = 13912kB
> Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0
> hugepages_size=1048576kB
> Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0
> hugepages_size=2048kB
> 175 total pagecache pages
> 0 pages in swap cache
>   alloc_skb include/linux/skbuff.h:997 [inline]
>   ndisc_alloc_skb+0x144/0x340 net/ipv6/ndisc.c:403
> Swap cache stats: add 0, delete 0, find 0/0
>   ndisc_send_rs+0x331/0x6e0 net/ipv6/ndisc.c:669
> Free swap  = 0kB
>   addrconf_rs_timer+0x314/0x690 net/ipv6/addrconf.c:3836
> Total swap = 0kB
> 1965979 pages RAM
>   call_timer_fn+0x272/0x920 kernel/time/timer.c:1326
> 0 pages HighMem/MovableOnly
> 342307 pages reserved
> 0 pages cma reserved
> ICMPv6: ndisc: ndisc_alloc_skb failed to allocate an skb
> rsyslogd: page allocation failure: order:0, mode:0x484020(GFP_ATOMIC|
> __GFP_COMP), nodemask=(null)
> rsyslogd cpuset=
> /
>   mems_allowed=0
>   expire_timers kernel/time/timer.c:1363 [inline]
>   __run_timers+0x7e5/0xc70 kernel/time/timer.c:1682
>   run_timer_softirq+0x52/0xb0 kernel/time/timer.c:1695
>   __do_softirq+0x30b/0xad8 kernel/softirq.c:292
>   invoke_softirq kernel/softirq.c:372 [inline]
>   irq_exit+0x17f/0x1c0 kernel/softirq.c:412
>   exiting_irq arch/x86/include/asm/apic.h:536 [inline]
>   smp_apic_timer_interrupt+0x1cb/0x760 arch/x86/kernel/apic/apic.c:1056
>   apic_timer_interrupt+0xf/0x20 arch/x86/entry/entry_64.S:864
>   </IRQ>
> RIP: 0010:arch_local_irq_restore arch/x86/include/asm/paravirt.h:788
> [inline]
> RIP: 0010:slab_alloc mm/slab.c:3385 [inline]
> RIP: 0010:kmem_cache_alloc+0x297/0x730 mm/slab.c:3552
> Code: 7e 0f 85 cf fe ff ff e8 06 60 3e ff e9 c5 fe ff ff e8 6d c3 c2 ff 48
> 83 3d bd d4 6f 07 00 0f 84 3b 03 00 00 48 8b 7d d0 57 9d <0f> 1f 44 00 00
> e9 54 fe ff ff 31 d2 be a5 01 00 00 48 c7 c7 62 23
> RSP: 0000:ffff8801980a7748 EFLAGS: 00000286 ORIG_RAX: ffffffffffffff13
> RAX: 0000000000000000 RBX: 0000000000480020 RCX: ffffc90001e5c000
> RDX: 0000000000000004 RSI: ffffffff8184e1e4 RDI: 0000000000000286
> RBP: ffff8801980a77b0 R08: ffff880193c38700 R09: fffffbfff12812c4
> R10: ffff8801980a6390 R11: ffffffff89409623 R12: 0000000000000000
> R13: ffff8801d9a04040 R14: ffff8801d9a04040 R15: 0000000000480020
>   skb_clone+0x1bb/0x500 net/core/skbuff.c:1280
>   ____bpf_clone_redirect net/core/filter.c:2079 [inline]
>   bpf_clone_redirect+0xb9/0x490 net/core/filter.c:2066
>   bpf_prog_41f2bcae09cd4ac3+0x194/0x1000
> Mem-Info:
> CPU: 1 PID: 5702 Comm: rsyslogd Not tainted 4.19.0-rc6+ #118
> Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS
> Google 01/01/2011
> active_anon:48193 inactive_anon:137 isolated_anon:0
>   active_file:16 inactive_file:15 isolated_file:0
>   unevictable:0 dirty:0 writeback:0 unstable:0
>   slab_reclaimable:9165 slab_unreclaimable:1475206
>   mapped:8194 shmem:144 pagetables:402 bounce:0
>   free:13771 free_pcp:443 free_cma:0
> Call Trace:
> Node 0 active_anon:192772kB inactive_anon:548kB active_file:64kB
> inactive_file:60kB unevictable:0kB isolated(anon):0kB isolated(file):0kB
> mapped:32776kB dirty:0kB writeback:0kB shmem:576kB shmem_thp: 0kB
> shmem_pmdmapped: 0kB anon_thp: 178176kB writeback_tmp:0kB unstable:0kB
> all_unreclaimable? yes
>   <IRQ>
> Node 0
>   __dump_stack lib/dump_stack.c:77 [inline]
>   dump_stack+0x1c4/0x2b4 lib/dump_stack.c:113
> DMA free:15908kB min:164kB low:204kB high:244kB active_anon:0kB
> inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB
> writepending:0kB present:15992kB managed:15908kB mlocked:0kB
> kernel_stack:0kB pagetables:0kB bounce:0kB free_pcp:0kB local_pcp:0kB
> free_cma:0kB
> lowmem_reserve[]:
>   warn_alloc.cold.119+0xb7/0x1bd mm/page_alloc.c:3426
>   0
>   2819
>   6323
>   6323
>   __alloc_pages_slowpath+0x2667/0x2d80 mm/page_alloc.c:4297
> Node 0
> DMA32 free:25264kB min:30060kB low:37572kB high:45084kB active_anon:0kB
> inactive_anon:0kB active_file:4kB inactive_file:0kB unevictable:0kB
> writepending:0kB present:3129332kB managed:2890736kB mlocked:0kB
> kernel_stack:0kB pagetables:0kB bounce:0kB free_pcp:248kB local_pcp:248kB
> free_cma:0kB
> lowmem_reserve[]:
>   0
>   0
>   3503
>   3503
> Node 0
> Normal free:13912kB min:37352kB low:46688kB high:56024kB
> active_anon:192772kB inactive_anon:548kB active_file:60kB
> inactive_file:60kB unevictable:0kB writepending:0kB present:4718592kB
> managed:3588044kB mlocked:0kB kernel_stack:5248kB pagetables:1608kB
> bounce:0kB free_pcp:1524kB local_pcp:68kB free_cma:0kB
> lowmem_reserve[]: 0
>   0
>   0
>   0
> Node 0 DMA:
> 1*4kB
> (U)
> 0*8kB
> 0*16kB
> 1*32kB
> (U)
> 2*64kB
> (U)
> 1*128kB
> (U)
> 1*256kB
> (U)
> 0*512kB
> 1*1024kB
> (U)
> 1*2048kB
>   __alloc_pages_nodemask+0xa80/0xde0 mm/page_alloc.c:4390
> (M)
> 3*4096kB
> (M)
> = 15908kB
> Node 0
> DMA32:
>   __alloc_pages include/linux/gfp.h:473 [inline]
>   __alloc_pages_node include/linux/gfp.h:486 [inline]
>   kmem_getpages mm/slab.c:1409 [inline]
>   cache_grow_begin+0x91/0x8c0 mm/slab.c:2677
> 4*4kB
> (UM)
>   fallback_alloc+0x203/0x2e0 mm/slab.c:3219
> 2*8kB
>   ____cache_alloc_node+0x1c7/0x1e0 mm/slab.c:3287
> (M)
>   slab_alloc_node mm/slab.c:3327 [inline]
>   kmem_cache_alloc_node+0xe3/0x730 mm/slab.c:3642
> 3*16kB
> (M)
>   __alloc_skb+0x119/0x770 net/core/skbuff.c:193
> 3*32kB
> (M)
> 4*64kB
> (UM)
> 4*128kB
> (UM)
> 3*256kB
>   alloc_skb include/linux/skbuff.h:997 [inline]
>   ndisc_alloc_skb+0x144/0x340 net/ipv6/ndisc.c:403
> (M)
>   ndisc_send_rs+0x331/0x6e0 net/ipv6/ndisc.c:669
> 4*512kB
>   addrconf_rs_timer+0x314/0x690 net/ipv6/addrconf.c:3836
> (UM)
> 3*1024kB
> (UM)
>   call_timer_fn+0x272/0x920 kernel/time/timer.c:1326
> 3*2048kB
> (M)
> 3*4096kB
> (M)
> = 25264kB
> Node 0
> Normal:
> 942*4kB
> (UME)
> 338*8kB
> (UMEH)
> 149*16kB
> (UME)
> 84*32kB
> (UMEH)
> 25*64kB
> (UM)
>   expire_timers kernel/time/timer.c:1363 [inline]
>   __run_timers+0x7e5/0xc70 kernel/time/timer.c:1682
> 2*128kB
> (UH)
> 0*256kB
> 1*512kB
> (H)
> 0*1024kB
> 0*2048kB
> 0*4096kB
> = 13912kB
> Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0
> hugepages_size=1048576kB
> Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0
> hugepages_size=2048kB
> 175 total pagecache pages
> 0 pages in swap cache
> Swap cache stats: add 0, delete 0, find 0/0
> Free swap  = 0kB
> Total swap = 0kB
>   run_timer_softirq+0x52/0xb0 kernel/time/timer.c:1695
> 1965979 pages RAM
> 0 pages HighMem/MovableOnly
>   __do_softirq+0x30b/0xad8 kernel/softirq.c:292
> 342307 pages reserved
> 0 pages cma reserved
> ICMPv6: ndisc: ndisc_alloc_skb failed to allocate an skb
> syz-executor0: page allocation failure: order:0, mode:0x484020(GFP_ATOMIC|
> __GFP_COMP), nodemask=(null)
> syz-executor0 cpuset=
> syz0
>   mems_allowed=0
>   invoke_softirq kernel/softirq.c:372 [inline]
>   irq_exit+0x17f/0x1c0 kernel/softirq.c:412
>   exiting_irq arch/x86/include/asm/apic.h:536 [inline]
>   smp_apic_timer_interrupt+0x1cb/0x760 arch/x86/kernel/apic/apic.c:1056
>   apic_timer_interrupt+0xf/0x20 arch/x86/entry/entry_64.S:864
>   </IRQ>
> RIP: 0010:arch_local_irq_restore arch/x86/include/asm/paravirt.h:788
> [inline]
> RIP: 0010:console_unlock+0xfdf/0x1160 kernel/printk/printk.c:2409
> Code: c1 e8 03 42 80 3c 20 00 0f 85 d1 00 00 00 48 83 3d cd 54 cd 07 00 0f
> 84 bc 00 00 00 e8 ca 37 1a 00 48 8b bd b0 fe ff ff 57 9d <0f> 1f 44 00 00
> e9 cc f9 ff ff 48 8b bd c8 fe ff ff e8 3b d8 5d 00
> RSP: 0000:ffff8801bccde450 EFLAGS: 00000293 ORIG_RAX: ffffffffffffff13
> RAX: ffff8801bd36a180 RBX: 0000000000000200 RCX: ffffffff8184e1ca
> RDX: 0000000000000000 RSI: ffffffff81649dc6 RDI: 0000000000000293
> RBP: ffff8801bccde5b8 R08: ffff8801bd36a180 R09: fffffbfff12720c0
> R10: fffffbfff12720c0 R11: ffffffff89390603 R12: dffffc0000000000
> R13: ffffffff84885bf0 R14: dffffc0000000000 R15: ffffffff899428d0
>   vprintk_emit+0x33d/0x930 kernel/printk/printk.c:1922
>   vprintk_default+0x28/0x30 kernel/printk/printk.c:1963
>   vprintk_func+0x7e/0x181 kernel/printk/printk_safe.c:398
>   printk+0xa7/0xcf kernel/printk/printk.c:1996
>   dump_unreclaimable_slab.cold.22+0xd8/0xe5 mm/slab_common.c:1371
>   dump_header+0x7cc/0xf72 mm/oom_kill.c:447
>   oom_kill_process.cold.27+0x10/0x903 mm/oom_kill.c:953
>   out_of_memory+0xa84/0x1430 mm/oom_kill.c:1120
>   __alloc_pages_may_oom mm/page_alloc.c:3522 [inline]
>   __alloc_pages_slowpath+0x2318/0x2d80 mm/page_alloc.c:4235
>   __alloc_pages_nodemask+0xa80/0xde0 mm/page_alloc.c:4390
>   __alloc_pages include/linux/gfp.h:473 [inline]
>   __alloc_pages_node include/linux/gfp.h:486 [inline]
>   kmem_getpages mm/slab.c:1409 [inline]
>   cache_grow_begin+0x91/0x8c0 mm/slab.c:2677
>   fallback_alloc+0x203/0x2e0 mm/slab.c:3219
>   ____cache_alloc_node+0x1c7/0x1e0 mm/slab.c:3287
>   __do_cache_alloc mm/slab.c:3356 [inline]
>   slab_alloc mm/slab.c:3384 [inline]
>   kmem_cache_alloc_trace+0x214/0x750 mm/slab.c:3618
>   kmalloc include/linux/slab.h:513 [inline]
>   syslog_print kernel/printk/printk.c:1297 [inline]
>   do_syslog+0xb9b/0x1690 kernel/printk/printk.c:1465
>   kmsg_read+0x8f/0xc0 fs/proc/kmsg.c:40
>   proc_reg_read+0x2a3/0x3d0 fs/proc/inode.c:231
>   __vfs_read+0x117/0x9b0 fs/read_write.c:416
>   vfs_read+0x17f/0x3c0 fs/read_write.c:452
>   ksys_read+0x101/0x260 fs/read_write.c:578
>   __do_sys_read fs/read_write.c:588 [inline]
>   __se_sys_read fs/read_write.c:586 [inline]
>   __x64_sys_read+0x73/0xb0 fs/read_write.c:586
>   do_syscall_64+0x1b9/0x820 arch/x86/entry/common.c:290
>   entry_SYSCALL_64_after_hwframe+0x49/0xbe
> RIP: 0033:0x7f5bbee581fd
> Code: Bad RIP value.
> RSP: 002b:00007f5bbc3f7e30 EFLAGS: 00000293 ORIG_RAX: 0000000000000000
> RAX: ffffffffffffffda RBX: 0000000001bc9ce0 RCX: 00007f5bbee581fd
> RDX: 0000000000000fff RSI: 00007f5bbdc2c5a0 RDI: 0000000000000004
> RBP: 0000000000000000 R08: 0000000001bb5260 R09: 0000000000000000
> R10: 6b205d3334383630 R11: 0000000000000293 R12: 000000000065e420
> R13: 00007f5bbc3f89c0 R14: 00007f5bbf49d040 R15: 0000000000000003
> CPU: 0 PID: 7592 Comm: syz-executor0 Not tainted 4.19.0-rc6+ #118
> Mem-Info:
> active_anon:48193 inactive_anon:137 isolated_anon:0
>   active_file:16 inactive_file:15 isolated_file:0
>   unevictable:0 dirty:0 writeback:0 unstable:0
>   slab_reclaimable:9165 slab_unreclaimable:1475206
>   mapped:8194 shmem:144 pagetables:402 bounce:0
>   free:13771 free_pcp:443 free_cma:0
> Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS
> Google 01/01/2011
> Node 0 active_anon:192772kB inactive_anon:548kB active_file:64kB
> inactive_file:60kB unevictable:0kB isolated(anon):0kB isolated(file):0kB
> mapped:32776kB dirty:0kB writeback:0kB shmem:576kB shmem_thp: 0kB
> shmem_pmdmapped: 0kB anon_thp: 178176kB writeback_tmp:0kB unstable:0kB
> all_unreclaimable? yes
> Call Trace:
> Node 0
>   <IRQ>
> DMA free:15908kB min:164kB low:204kB high:244kB active_anon:0kB
> inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB
> writepending:0kB present:15992kB managed:15908kB mlocked:0kB
> kernel_stack:0kB pagetables:0kB bounce:0kB free_pcp:0kB local_pcp:0kB
> free_cma:0kB
>   __dump_stack lib/dump_stack.c:77 [inline]
>   dump_stack+0x1c4/0x2b4 lib/dump_stack.c:113
> lowmem_reserve[]:
>   0
>   warn_alloc.cold.119+0xb7/0x1bd mm/page_alloc.c:3426
>   2819
>   6323 6323
> Node 0 DMA32 free:25264kB min:30060kB low:37572kB high:45084kB
> active_anon:0kB inactive_anon:0kB active_file:4kB inactive_file:0kB
> unevictable:0kB writepending:0kB present:3129332kB managed:2890736kB
> mlocked:0kB kernel_stack:0kB pagetables:0kB bounce:0kB free_pcp:248kB
> local_pcp:0kB free_cma:0kB
>   __alloc_pages_slowpath+0x2667/0x2d80 mm/page_alloc.c:4297
> lowmem_reserve[]:
>   0
>   0 3503
>   3503
> Node 0
> Normal free:13912kB min:37352kB low:46688kB high:56024kB
> active_anon:192772kB inactive_anon:548kB active_file:60kB
> inactive_file:60kB unevictable:0kB writepending:0kB present:4718592kB
> managed:3588044kB mlocked:0kB kernel_stack:5248kB pagetables:1608kB
> bounce:0kB free_pcp:1524kB local_pcp:1456kB free_cma:0kB
> lowmem_reserve[]:
>   0
>   0
>   0
>   0
> Node 0 DMA:
> 1*4kB
> (U)
> 0*8kB
> 0*16kB
> 1*32kB
> (U)
> 2*64kB
> (U)
> 1*128kB
> (U)
> 1*256kB
> (U)
> 0*512kB
>   __alloc_pages_nodemask+0xa80/0xde0 mm/page_alloc.c:4390
> 1*1024kB
> (U)
> 1*2048kB
> (M)
> 3*4096kB
> (M)
>   __alloc_pages include/linux/gfp.h:473 [inline]
>   __alloc_pages_node include/linux/gfp.h:486 [inline]
>   kmem_getpages mm/slab.c:1409 [inline]
>   cache_grow_begin+0x91/0x8c0 mm/slab.c:2677
> = 15908kB
> Node 0
>   fallback_alloc+0x203/0x2e0 mm/slab.c:3219
> DMA32:
>   ____cache_alloc_node+0x1c7/0x1e0 mm/slab.c:3287
> 4*4kB
>   slab_alloc_node mm/slab.c:3327 [inline]
>   kmem_cache_alloc_node+0xe3/0x730 mm/slab.c:3642
> (UM)
> 2*8kB
>   __alloc_skb+0x119/0x770 net/core/skbuff.c:193
> (M)
> 3*16kB
> (M)
> 3*32kB
> (M)
> 4*64kB
>   alloc_skb include/linux/skbuff.h:997 [inline]
>   ndisc_alloc_skb+0x144/0x340 net/ipv6/ndisc.c:403
> (UM)
>   ndisc_send_rs+0x331/0x6e0 net/ipv6/ndisc.c:669
> 4*128kB
>   addrconf_rs_timer+0x314/0x690 net/ipv6/addrconf.c:3836
> (UM)
> 3*256kB
>   call_timer_fn+0x272/0x920 kernel/time/timer.c:1326
> (M)
> 4*512kB
> (UM)
> 3*1024kB
> (UM)
> 3*2048kB
> (M)
> 3*4096kB
> (M)
> = 25264kB
> Node 0
> Normal:
> 942*4kB
> (UME)
> 338*8kB
> (UMEH)
> 149*16kB
>   expire_timers kernel/time/timer.c:1363 [inline]
>   __run_timers+0x7e5/0xc70 kernel/time/timer.c:1682
> (UME)
> 84*32kB
> (UMEH)
> 25*64kB
> (UM)
> 2*128kB
> (UH)
> 0*256kB
> 1*512kB
> (H)
> 0*1024kB
> 0*2048kB
> 0*4096kB
> = 13912kB
> Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0
> hugepages_size=1048576kB
> Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0
> hugepages_size=2048kB
>   run_timer_softirq+0x52/0xb0 kernel/time/timer.c:1695
> 175 total pagecache pages
> 0 pages in swap cache
>   __do_softirq+0x30b/0xad8 kernel/softirq.c:292
> Swap cache stats: add 0, delete 0, find 0/0
> Free swap  = 0kB
> Total swap = 0kB
> 1965979 pages RAM
> 0 pages HighMem/MovableOnly
> 342307 pages reserved
> 0 pages cma reserved
> ICMPv6: ndisc: ndisc_alloc_skb failed to allocate an skb
> rsyslogd: page allocation failure: order:0, mode:0x484020(GFP_ATOMIC|
> __GFP_COMP), nodemask=(null)
> rsyslogd cpuset=
>   invoke_softirq kernel/softirq.c:372 [inline]
>   irq_exit+0x17f/0x1c0 kernel/softirq.c:412
> /
>   exiting_irq arch/x86/include/asm/apic.h:536 [inline]
>   smp_apic_timer_interrupt+0x1cb/0x760 arch/x86/kernel/apic/apic.c:1056
>   mems_allowed=0
>   apic_timer_interrupt+0xf/0x20 arch/x86/entry/entry_64.S:864
>   </IRQ>
> RIP: 0010:arch_local_irq_restore arch/x86/include/asm/paravirt.h:788
> [inline]
> RIP: 0010:slab_alloc mm/slab.c:3385 [inline]
> RIP: 0010:kmem_cache_alloc+0x297/0x730 mm/slab.c:3552
> Code: 7e 0f 85 cf fe ff ff e8 06 60 3e ff e9 c5 fe ff ff e8 6d c3 c2 ff 48
> 83 3d bd d4 6f 07 00 0f 84 3b 03 00 00 48 8b 7d d0 57 9d <0f> 1f 44 00 00
> e9 54 fe ff ff 31 d2 be a5 01 00 00 48 c7 c7 62 23
> RSP: 0000:ffff8801980a7748 EFLAGS: 00000286 ORIG_RAX: ffffffffffffff13
> RAX: 0000000000000000 RBX: 0000000000480020 RCX: ffffc90001e5c000
> RDX: 0000000000000004 RSI: ffffffff8184e1e4 RDI: 0000000000000286
> RBP: ffff8801980a77b0 R08: ffff880193c38700 R09: fffffbfff12812c4
> R10: ffff8801980a6390 R11: ffffffff89409623 R12: 0000000000000000
> R13: ffff8801d9a04040 R14: ffff8801d9a04040 R15: 0000000000480020
>   skb_clone+0x1bb/0x500 net/core/skbuff.c:1280
>   ____bpf_clone_redirect net/core/filter.c:2079 [inline]
>   bpf_clone_redirect+0xb9/0x490 net/core/filter.c:2066
>   bpf_prog_41f2bcae09cd4ac3+0x194/0x1000
> CPU: 1 PID: 5702 Comm: rsyslogd Not tainted 4.19.0-rc6+ #118
> ICMPv6: ndisc: ndisc_alloc_skb failed to allocate an skb
> Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS
> Google 01/01/2011
> Call Trace:
>   <IRQ>
>   __dump_stack lib/dump_stack.c:77 [inline]
>   dump_stack+0x1c4/0x2b4 lib/dump_stack.c:113
> syz-executor0: page allocation failure: order:0, mode:0x484020(GFP_ATOMIC|
> __GFP_COMP), nodemask=(null)
>   warn_alloc.cold.119+0xb7/0x1bd mm/page_alloc.c:3426
> syz-executor0 cpuset=
> syz0
>   mems_allowed=0
>   __alloc_pages_slowpath+0x2667/0x2d80 mm/page_alloc.c:4297
>   __alloc_pages_nodemask+0xa80/0xde0 mm/page_alloc.c:4390
>   __alloc_pages include/linux/gfp.h:473 [inline]
>   __alloc_pages_node include/linux/gfp.h:486 [inline]
>   kmem_getpages mm/slab.c:1409 [inline]
>   cache_grow_begin+0x91/0x8c0 mm/slab.c:2677
>   fallback_alloc+0x203/0x2e0 mm/slab.c:3219
>   ____cache_alloc_node+0x1c7/0x1e0 mm/slab.c:3287
>   slab_alloc_node mm/slab.c:3327 [inline]
>   kmem_cache_alloc_node+0xe3/0x730 mm/slab.c:3642
>   __alloc_skb+0x119/0x770 net/core/skbuff.c:193
>   alloc_skb include/linux/skbuff.h:997 [inline]
>   ndisc_alloc_skb+0x144/0x340 net/ipv6/ndisc.c:403
>   ndisc_send_rs+0x331/0x6e0 net/ipv6/ndisc.c:669
>   addrconf_rs_timer+0x314/0x690 net/ipv6/addrconf.c:3836
>   call_timer_fn+0x272/0x920 kernel/time/timer.c:1326
>   expire_timers kernel/time/timer.c:1363 [inline]
>   __run_timers+0x7e5/0xc70 kernel/time/timer.c:1682
>   run_timer_softirq+0x52/0xb0 kernel/time/timer.c:1695
>   __do_softirq+0x30b/0xad8 kernel/softirq.c:292
>   invoke_softirq kernel/softirq.c:372 [inline]
>   irq_exit+0x17f/0x1c0 kernel/softirq.c:412
>   exiting_irq arch/x86/include/asm/apic.h:536 [inline]
>   smp_apic_timer_interrupt+0x1cb/0x760 arch/x86/kernel/apic/apic.c:1056
>   apic_timer_interrupt+0xf/0x20 arch/x86/entry/entry_64.S:864
>   </IRQ>
> RIP: 0010:arch_local_irq_restore arch/x86/include/asm/paravirt.h:788
> [inline]
> RIP: 0010:console_unlock+0xfdf/0x1160 kernel/printk/printk.c:2409
> Code: c1 e8 03 42 80 3c 20 00 0f 85 d1 00 00 00 48 83 3d cd 54 cd 07 00 0f
> 84 bc 00 00 00 e8 ca 37 1a 00 48 8b bd b0 fe ff ff 57 9d <0f> 1f 44 00 00
> e9 cc f9 ff ff 48 8b bd c8 fe ff ff e8 3b d8 5d 00
> RSP: 0000:ffff8801bccde450 EFLAGS: 00000293 ORIG_RAX: ffffffffffffff13
> RAX: ffff8801bd36a180 RBX: 0000000000000200 RCX: ffffffff8184e1ca
> RDX: 0000000000000000 RSI: ffffffff81649dc6 RDI: 0000000000000293
> RBP: ffff8801bccde5b8 R08: ffff8801bd36a180 R09: fffffbfff12720c0
> R10: fffffbfff12720c0 R11: ffffffff89390603 R12: dffffc0000000000
> R13: ffffffff84885bf0 R14: dffffc0000000000 R15: ffffffff899428d0
>   vprintk_emit+0x33d/0x930 kernel/printk/printk.c:1922
>   vprintk_default+0x28/0x30 kernel/printk/printk.c:1963
>   vprintk_func+0x7e/0x181 kernel/printk/printk_safe.c:398
>   printk+0xa7/0xcf kernel/printk/printk.c:1996
>   dump_unreclaimable_slab.cold.22+0xd8/0xe5 mm/slab_common.c:1371
>   dump_header+0x7cc/0xf72 mm/oom_kill.c:447
>   oom_kill_process.cold.27+0x10/0x903 mm/oom_kill.c:953
>   out_of_memory+0xa84/0x1430 mm/oom_kill.c:1120
>   __alloc_pages_may_oom mm/page_alloc.c:3522 [inline]
>   __alloc_pages_slowpath+0x2318/0x2d80 mm/page_alloc.c:4235
>   __alloc_pages_nodemask+0xa80/0xde0 mm/page_alloc.c:4390
>   __alloc_pages include/linux/gfp.h:473 [inline]
>   __alloc_pages_node include/linux/gfp.h:486 [inline]
>   kmem_getpages mm/slab.c:1409 [inline]
>   cache_grow_begin+0x91/0x8c0 mm/slab.c:2677
>   fallback_alloc+0x203/0x2e0 mm/slab.c:3219
>   ____cache_alloc_node+0x1c7/0x1e0 mm/slab.c:3287
>   __do_cache_alloc mm/slab.c:3356 [inline]
>   slab_alloc mm/slab.c:3384 [inline]
>   kmem_cache_alloc_trace+0x214/0x750 mm/slab.c:3618
>   kmalloc include/linux/slab.h:513 [inline]
>   syslog_print kernel/printk/printk.c:1297 [inline]
>   do_syslog+0xb9b/0x1690 kernel/printk/printk.c:1465
>   kmsg_read+0x8f/0xc0 fs/proc/kmsg.c:40
>   proc_reg_read+0x2a3/0x3d0 fs/proc/inode.c:231
>   __vfs_read+0x117/0x9b0 fs/read_write.c:416
>   vfs_read+0x17f/0x3c0 fs/read_write.c:452
>   ksys_read+0x101/0x260 fs/read_write.c:578
>   __do_sys_read fs/read_write.c:588 [inline]
>   __se_sys_read fs/read_write.c:586 [inline]
>   __x64_sys_read+0x73/0xb0 fs/read_write.c:586
>   do_syscall_64+0x1b9/0x820 arch/x86/entry/common.c:290
>   entry_SYSCALL_64_after_hwframe+0x49/0xbe
> RIP: 0033:0x7f5bbee581fd
> Code: Bad RIP value.
> RSP: 002b:00007f5bbc3f7e30 EFLAGS: 00000293 ORIG_RAX: 0000000000000000
> RAX: ffffffffffffffda RBX: 0000000001bc9ce0 RCX: 00007f5bbee581fd
> RDX: 0000000000000fff RSI: 00007f5bbdc2c5a0 RDI: 0000000000000004
> RBP: 0000000000000000 R08: 0000000001bb5260 R09: 0000000000000000
> R10: 6b205d3334383630 R11: 0000000000000293 R12: 000000000065e420
> R13: 00007f5bbc3f89c0 R14: 00007f5bbf49d040 R15: 0000000000000003
> warn_alloc_show_mem: 1 callbacks suppressed
> CPU: 0 PID: 7592 Comm: syz-executor0 Not tainted 4.19.0-rc6+ #118
> Mem-Info:
> active_anon:48193 inactive_anon:137 isolated_anon:0
>   active_file:16 inactive_file:15 isolated_file:0
>   unevictable:0 dirty:0 writeback:0 unstable:0
>   slab_reclaimable:9165 slab_unreclaimable:1475206
>   mapped:8194 shmem:144 pagetables:402 bounce:0
>   free:13771 free_pcp:443 free_cma:0
> Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS
> Google 01/01/2011
> Node 0 active_anon:192772kB inactive_anon:548kB active_file:64kB
> inactive_file:60kB unevictable:0kB isolated(anon):0kB isolated(file):0kB
> mapped:32776kB dirty:0kB writeback:0kB shmem:576kB shmem_thp: 0kB
> shmem_pmdmapped: 0kB anon_thp: 178176kB writeback_tmp:0kB unstable:0kB
> all_unreclaimable? yes
> Call Trace:
> Node 0
>   <IRQ>
> DMA free:15908kB min:164kB low:204kB high:244kB active_anon:0kB
> inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB
> writepending:0kB present:15992kB managed:15908kB mlocked:0kB
> kernel_stack:0kB pagetables:0kB bounce:0kB free_pcp:0kB local_pcp:0kB
> free_cma:0kB
>   __dump_stack lib/dump_stack.c:77 [inline]
>   dump_stack+0x1c4/0x2b4 lib/dump_stack.c:113
> lowmem_reserve[]:
>   0
>   warn_alloc.cold.119+0xb7/0x1bd mm/page_alloc.c:3426
>   2819
>   6323
>   6323
> Node 0
>   __alloc_pages_slowpath+0x2667/0x2d80 mm/page_alloc.c:4297
> DMA32 free:25264kB min:30060kB low:37572kB high:45084kB active_anon:0kB
> inactive_anon:0kB active_file:4kB inactive_file:0kB unevictable:0kB
> writepending:0kB present:3129332kB managed:2890736kB mlocked:0kB
> kernel_stack:0kB pagetables:0kB bounce:0kB free_pcp:248kB local_pcp:0kB
> free_cma:0kB
> lowmem_reserve[]:
>   0
>   0
>   3503 3503
> Node 0 Normal free:13912kB min:37352kB low:46688kB high:56024kB
> active_anon:192772kB inactive_anon:548kB active_file:60kB
> inactive_file:60kB unevictable:0kB writepending:0kB present:4718592kB
> managed:3588044kB mlocked:0kB kernel_stack:5248kB pagetables:1608kB
> bounce:0kB free_pcp:1524kB local_pcp:1456kB free_cma:0kB
> lowmem_reserve[]:
>   0 0
>   0
>   0
> Node 0 DMA:
> 1*4kB
> (U)
> 0*8kB
> 0*16kB
> 1*32kB
> (U)
> 2*64kB
> (U) 1*128kB
> (U)
>   __alloc_pages_nodemask+0xa80/0xde0 mm/page_alloc.c:4390
> 1*256kB
> (U)
> 0*512kB
> 1*1024kB
> (U)
> 1*2048kB
>   __alloc_pages include/linux/gfp.h:473 [inline]
>   __alloc_pages_node include/linux/gfp.h:486 [inline]
>   kmem_getpages mm/slab.c:1409 [inline]
>   cache_grow_begin+0x91/0x8c0 mm/slab.c:2677
> (M)
> 3*4096kB
>   fallback_alloc+0x203/0x2e0 mm/slab.c:3219
> (M) = 15908kB
>   ____cache_alloc_node+0x1c7/0x1e0 mm/slab.c:3287
> Node 0
>   slab_alloc_node mm/slab.c:3327 [inline]
>   kmem_cache_alloc_node+0xe3/0x730 mm/slab.c:3642
> DMA32:
> 4*4kB
>   __alloc_skb+0x119/0x770 net/core/skbuff.c:193
> (UM)
> 2*8kB
> (M)
> 3*16kB
> (M)
> 3*32kB
> (M)
>   alloc_skb include/linux/skbuff.h:997 [inline]
>   ndisc_alloc_skb+0x144/0x340 net/ipv6/ndisc.c:403
> 4*64kB
>   ndisc_send_rs+0x331/0x6e0 net/ipv6/ndisc.c:669
> (UM)
>   addrconf_rs_timer+0x314/0x690 net/ipv6/addrconf.c:3836
> 4*128kB
> (UM)
>   call_timer_fn+0x272/0x920 kernel/time/timer.c:1326
> 3*256kB
> (M)
> 4*512kB
> (UM)
> 3*1024kB
> (UM)
> 3*2048kB
> (M)
> 3*4096kB
> (M)
> = 25264kB
> Node 0
> Normal:
> 942*4kB
> (UME)
> 338*8kB
> (UMEH)
>   expire_timers kernel/time/timer.c:1363 [inline]
>   __run_timers+0x7e5/0xc70 kernel/time/timer.c:1682
> 149*16kB
> (UME)
> 84*32kB
> (UMEH)
> 25*64kB
> (UM)
> 2*128kB
> (UH)
> 0*256kB
> 1*512kB
> (H)
> 0*1024kB
> 0*2048kB
> 0*4096kB
> = 13912kB
> Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0
> hugepages_size=1048576kB
>   run_timer_softirq+0x52/0xb0 kernel/time/timer.c:1695
> Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0
> hugepages_size=2048kB
> 175 total pagecache pages
>   __do_softirq+0x30b/0xad8 kernel/softirq.c:292
> 0 pages in swap cache
> Swap cache stats: add 0, delete 0, find 0/0
> Free swap  = 0kB
> Total swap = 0kB
> 1965979 pages RAM
> 0 pages HighMem/MovableOnly
> 342307 pages reserved
> 0 pages cma reserved
> ICMPv6: ndisc: ndisc_alloc_skb failed to allocate an skb
> rsyslogd: page allocation failure: order:0, mode:0x484020(GFP_ATOMIC|
> __GFP_COMP), nodemask=(null)
>   invoke_softirq kernel/softirq.c:372 [inline]
>   irq_exit+0x17f/0x1c0 kernel/softirq.c:412
> rsyslogd cpuset=
>   exiting_irq arch/x86/include/asm/apic.h:536 [inline]
>   smp_apic_timer_interrupt+0x1cb/0x760 arch/x86/kernel/apic/apic.c:1056
> /
>   mems_allowed=0
>   apic_timer_interrupt+0xf/0x20 arch/x86/entry/entry_64.S:864
>   </IRQ>
> RIP: 0010:arch_local_irq_restore arch/x86/include/asm/paravirt.h:788
> [inline]
> RIP: 0010:slab_alloc mm/slab.c:3385 [inline]
> RIP: 0010:kmem_cache_alloc+0x297/0x730 mm/slab.c:3552
> Code: 7e 0f 85 cf fe ff ff e8 06 60 3e ff e9 c5 fe ff ff e8 6d c3 c2 ff 48
> 83 3d bd d4 6f 07 00 0f 84 3b 03 00 00 48 8b 7d d0 57 9d <0f> 1f 44 00 00
> e9 54 fe ff ff 31 d2 be a5 01 00 00 48 c7 c7 62 23
> RSP: 0000:ffff8801980a7748 EFLAGS: 00000286 ORIG_RAX: ffffffffffffff13
> RAX: 0000000000000000 RBX: 0000000000480020 RCX: ffffc90001e5c000
> RDX: 0000000000000004 RSI: ffffffff8184e1e4 RDI: 0000000000000286
> RBP: ffff8801980a77b0 R08: ffff880193c38700 R09: fffffbfff12812c4
> R10: ffff8801980a6390 R11: ffffffff89409623 R12: 0000000000000000
> R13: ffff8801d9a04040 R14: ffff8801d9a04040 R15: 0000000000480020
>   skb_clone+0x1bb/0x500 net/core/skbuff.c:1280
>   ____bpf_clone_redirect net/core/filter.c:2079 [inline]
>   bpf_clone_redirect+0xb9/0x490 net/core/filter.c:2066
>   bpf_prog_41f2bcae09cd4ac3+0x194/0x1000
> CPU: 1 PID: 5702 Comm: rsyslogd Not tainted 4.19.0-rc6+ #118
> ICMPv6: ndisc: ndisc_alloc_skb failed to allocate an skb
> Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS
> Google 01/01/2011
> Call Trace:
>   <IRQ>
>   __dump_stack lib/dump_stack.c:77 [inline]
>   dump_stack+0x1c4/0x2b4 lib/dump_stack.c:113
>   warn_alloc.cold.119+0xb7/0x1bd mm/page_alloc.c:3426
> syz-executor0: page allocation failure: order:0, mode:0x484020(GFP_ATOMIC|
> __GFP_COMP), nodemask=(null)
> syz-executor0 cpuset=
> syz0 mems_allowed=0
>   __alloc_pages_slowpath+0x2667/0x2d80 mm/page_alloc.c:4297
>   __alloc_pages_nodemask+0xa80/0xde0 mm/page_alloc.c:4390
>   __alloc_pages include/linux/gfp.h:473 [inline]
>   __alloc_pages_node include/linux/gfp.h:486 [inline]
>   kmem_getpages mm/slab.c:1409 [inline]
>   cache_grow_begin+0x91/0x8c0 mm/slab.c:2677
>   fallback_alloc+0x203/0x2e0 mm/slab.c:3219
>   ____cache_alloc_node+0x1c7/0x1e0 mm/slab.c:3287
>   slab_alloc_node mm/slab.c:3327 [inline]
>   kmem_cache_alloc_node+0xe3/0x730 mm/slab.c:3642
>   __alloc_skb+0x119/0x770 net/core/skbuff.c:193
>   alloc_skb include/linux/skbuff.h:997 [inline]
>   ndisc_alloc_skb+0x144/0x340 net/ipv6/ndisc.c:403
>   ndisc_send_rs+0x331/0x6e0 net/ipv6/ndisc.c:669
>   addrconf_rs_timer+0x314/0x690 net/ipv6/addrconf.c:3836
>   call_timer_fn+0x272/0x920 kernel/time/timer.c:1326
>   expire_timers kernel/time/timer.c:1363 [inline]
>   __run_timers+0x7e5/0xc70 kernel/time/timer.c:1682
>
>
> ---
> This bug is generated by a bot. It may contain errors.
> See https://goo.gl/tpsmEJ for more information about syzbot.
> syzbot engineers can be reached at syzkaller@googlegroups.com.
>
> syzbot will keep track of this bug report. See:
> https://goo.gl/tpsmEJ#bug-status-tracking for how to communicate with
> syzbot.
>
> --
> You received this message because you are subscribed to the Google Groups "syzkaller-bugs" group.
> To unsubscribe from this group and stop receiving emails from it, send an email to syzkaller-bugs+unsubscribe@googlegroups.com.
> To view this discussion on the web visit https://groups.google.com/d/msgid/syzkaller-bugs/0000000000007beca9057e4c8c14%40google.com.
> For more options, visit https://groups.google.com/d/optout.
