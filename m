Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4DC488E0161
	for <linux-mm@kvack.org>; Thu, 13 Dec 2018 10:11:06 -0500 (EST)
Received: by mail-io1-f72.google.com with SMTP id u13so1966311iog.23
        for <linux-mm@kvack.org>; Thu, 13 Dec 2018 07:11:06 -0800 (PST)
Received: from mail-sor-f69.google.com (mail-sor-f69.google.com. [209.85.220.69])
        by mx.google.com with SMTPS id o2sor4617905itb.1.2018.12.13.07.11.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 13 Dec 2018 07:11:03 -0800 (PST)
MIME-Version: 1.0
Date: Thu, 13 Dec 2018 07:11:03 -0800
Message-ID: <0000000000001f5aa6057ce8b94b@google.com>
Subject: possible deadlock in try_to_wake_up
From: syzbot <syzbot+aa4d6d6e9844c73913b8@syzkaller.appspotmail.com>
Content-Type: text/plain; charset="UTF-8"; format=flowed; delsp=yes
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, aryabinin@virtuozzo.com, guro@fb.com, hannes@cmpxchg.org, jbacik@fb.com, ktkhai@virtuozzo.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mgorman@techsingularity.net, mhocko@suse.com, shakeelb@google.com, syzkaller-bugs@googlegroups.com, vdavydov.dev@gmail.com, willy@infradead.org

Hello,

syzbot found the following crash on:

HEAD commit:    ca40dc225d19 Add linux-next specific files for 20181213
git tree:       linux-next
console output: https://syzkaller.appspot.com/x/log.txt?x=126d9fd5400000
kernel config:  https://syzkaller.appspot.com/x/.config?x=778d1d35b0e8272b
dashboard link: https://syzkaller.appspot.com/bug?extid=aa4d6d6e9844c73913b8
compiler:       gcc (GCC) 8.0.1 20180413 (experimental)

Unfortunately, I don't have any reproducer for this crash yet.

IMPORTANT: if you fix the bug, please add the following tag to the commit:
Reported-by: syzbot+aa4d6d6e9844c73913b8@syzkaller.appspotmail.com


======================================================
WARNING: possible circular locking dependency detected
4.20.0-rc6-next-20181213+ #170 Not tainted
------------------------------------------------------
syz-executor5/1221 is trying to acquire lock:
000000009d8713d8 (&p->pi_lock){-.-.}, at: try_to_wake_up+0xdc/0x1440  
kernel/sched/core.c:1965

but task is already holding lock:
00000000a84a436c (&pgdat->kswapd_wait){....}, at:  
__wake_up_common_lock+0x19e/0x330 kernel/sched/wait.c:120

which lock already depends on the new lock.


the existing dependency chain (in reverse order) is:

-> #4 (&pgdat->kswapd_wait){....}:
        __raw_spin_lock_irqsave include/linux/spinlock_api_smp.h:110 [inline]
        _raw_spin_lock_irqsave+0x99/0xd0 kernel/locking/spinlock.c:152
        __wake_up_common_lock+0x19e/0x330 kernel/sched/wait.c:120
        __wake_up+0xe/0x10 kernel/sched/wait.c:145
        wakeup_kswapd+0x592/0x8f0 mm/vmscan.c:4001
        steal_suitable_fallback+0x538/0x830 mm/page_alloc.c:2308
        __rmqueue_fallback mm/page_alloc.c:2593 [inline]
        __rmqueue mm/page_alloc.c:2619 [inline]
        rmqueue_bulk mm/page_alloc.c:2641 [inline]
        __rmqueue_pcplist mm/page_alloc.c:3106 [inline]
        rmqueue_pcplist mm/page_alloc.c:3135 [inline]
        rmqueue mm/page_alloc.c:3157 [inline]
        get_page_from_freelist+0x32cf/0x5360 mm/page_alloc.c:3570
        __alloc_pages_nodemask+0x668/0xec0 mm/page_alloc.c:4608
        alloc_pages_current+0x173/0x350 mm/mempolicy.c:2106
        alloc_pages include/linux/gfp.h:509 [inline]
        __vmalloc_area_node mm/vmalloc.c:1690 [inline]
        __vmalloc_node_range+0x5ca/0x8d0 mm/vmalloc.c:1750
        __vmalloc_node mm/vmalloc.c:1795 [inline]
        __vmalloc_node_flags mm/vmalloc.c:1809 [inline]
        vmalloc+0x6f/0x80 mm/vmalloc.c:1831
        do_replace_finish+0x10c/0x2940 net/bridge/netfilter/ebtables.c:1019
        do_replace+0x384/0x4c0 net/bridge/netfilter/ebtables.c:1159
        do_ebt_set_ctl+0xe7/0x110 net/bridge/netfilter/ebtables.c:1528
        nf_sockopt net/netfilter/nf_sockopt.c:106 [inline]
        nf_setsockopt+0x7d/0xd0 net/netfilter/nf_sockopt.c:115
        ip_setsockopt+0xd8/0xf0 net/ipv4/ip_sockglue.c:1260
        udp_setsockopt+0x62/0xa0 net/ipv4/udp.c:2649
        ipv6_setsockopt+0x149/0x170 net/ipv6/ipv6_sockglue.c:935
        tcp_setsockopt+0x93/0xe0 net/ipv4/tcp.c:3068
        sock_common_setsockopt+0x9a/0xe0 net/core/sock.c:2986
        __sys_setsockopt+0x1ba/0x3c0 net/socket.c:1903
        __do_sys_setsockopt net/socket.c:1914 [inline]
        __se_sys_setsockopt net/socket.c:1911 [inline]
        __x64_sys_setsockopt+0xbe/0x150 net/socket.c:1911
        do_syscall_64+0x1b9/0x820 arch/x86/entry/common.c:290
        entry_SYSCALL_64_after_hwframe+0x49/0xbe

-> #3 (&(&zone->lock)->rlock){..-.}:
        __raw_spin_lock_irqsave include/linux/spinlock_api_smp.h:110 [inline]
        _raw_spin_lock_irqsave+0x99/0xd0 kernel/locking/spinlock.c:152
        rmqueue mm/page_alloc.c:3167 [inline]
        get_page_from_freelist+0x9eb/0x5360 mm/page_alloc.c:3570
        __alloc_pages_nodemask+0x668/0xec0 mm/page_alloc.c:4608
        __alloc_pages include/linux/gfp.h:473 [inline]
        alloc_page_interleave+0x25/0x1c0 mm/mempolicy.c:1988
        alloc_pages_current+0x2ac/0x350 mm/mempolicy.c:2104
        alloc_pages include/linux/gfp.h:509 [inline]
        depot_save_stack+0x3f1/0x470 lib/stackdepot.c:260
        save_stack+0xa9/0xd0 mm/kasan/common.c:79
        set_track mm/kasan/common.c:85 [inline]
        kasan_kmalloc+0xcb/0xd0 mm/kasan/common.c:482
        kasan_slab_alloc+0x12/0x20 mm/kasan/common.c:397
        slab_post_alloc_hook mm/slab.h:444 [inline]
        slab_alloc mm/slab.c:3379 [inline]
        kmem_cache_alloc+0x11a/0x730 mm/slab.c:3539
        kmem_cache_zalloc include/linux/slab.h:730 [inline]
        fill_pool lib/debugobjects.c:134 [inline]
        __debug_object_init+0xbb8/0x1290 lib/debugobjects.c:379
        debug_object_init lib/debugobjects.c:431 [inline]
        debug_object_activate+0x323/0x600 lib/debugobjects.c:512
        debug_timer_activate kernel/time/timer.c:708 [inline]
        debug_activate kernel/time/timer.c:763 [inline]
        __mod_timer kernel/time/timer.c:1040 [inline]
        mod_timer kernel/time/timer.c:1101 [inline]
        add_timer+0x50e/0x15a0 kernel/time/timer.c:1137
        __queue_delayed_work+0x249/0x380 kernel/workqueue.c:1533
        queue_delayed_work_on+0x1a2/0x1f0 kernel/workqueue.c:1558
        queue_delayed_work include/linux/workqueue.h:527 [inline]
        schedule_delayed_work include/linux/workqueue.h:628 [inline]
        start_dirtytime_writeback+0x4e/0x53 fs/fs-writeback.c:2043
        do_one_initcall+0x145/0x957 init/main.c:888
        do_initcall_level init/main.c:956 [inline]
        do_initcalls init/main.c:964 [inline]
        do_basic_setup init/main.c:982 [inline]
        kernel_init_freeable+0x5cc/0x6ba init/main.c:1135
        kernel_init+0x11/0x1ae init/main.c:1055
        ret_from_fork+0x3a/0x50 arch/x86/entry/entry_64.S:352

-> #2 (&base->lock){-.-.}:
        __raw_spin_lock_irqsave include/linux/spinlock_api_smp.h:110 [inline]
        _raw_spin_lock_irqsave+0x99/0xd0 kernel/locking/spinlock.c:152
        lock_timer_base+0xbb/0x2b0 kernel/time/timer.c:937
        __mod_timer kernel/time/timer.c:1009 [inline]
        mod_timer kernel/time/timer.c:1101 [inline]
        add_timer+0x87f/0x15a0 kernel/time/timer.c:1137
        __queue_delayed_work+0x249/0x380 kernel/workqueue.c:1533
        queue_delayed_work_on+0x1a2/0x1f0 kernel/workqueue.c:1558
        queue_delayed_work include/linux/workqueue.h:527 [inline]
        schedule_delayed_work include/linux/workqueue.h:628 [inline]
        psi_group_change kernel/sched/psi.c:485 [inline]
        psi_task_change+0x3f1/0x5f0 kernel/sched/psi.c:534
        psi_enqueue kernel/sched/stats.h:82 [inline]
        enqueue_task kernel/sched/core.c:727 [inline]
        activate_task+0x21a/0x430 kernel/sched/core.c:751
        wake_up_new_task+0x523/0xcf0 kernel/sched/core.c:2423
        _do_fork+0x33b/0x11d0 kernel/fork.c:2237
        kernel_thread+0x34/0x40 kernel/fork.c:2271
        rest_init+0x28/0x372 init/main.c:408
        arch_call_rest_init+0xe/0x1b
        start_kernel+0x9a5/0x9e0 init/main.c:740
        x86_64_start_reservations+0x29/0x2b arch/x86/kernel/head64.c:470
        x86_64_start_kernel+0x76/0x79 arch/x86/kernel/head64.c:451
        secondary_startup_64+0xa4/0xb0 arch/x86/kernel/head_64.S:243

-> #1 (&rq->lock){-.-.}:
        __raw_spin_lock include/linux/spinlock_api_smp.h:142 [inline]
        _raw_spin_lock+0x2d/0x40 kernel/locking/spinlock.c:144
        rq_lock kernel/sched/sched.h:1129 [inline]
        task_fork_fair+0xb0/0x6d0 kernel/sched/fair.c:9820
        sched_fork+0x443/0xba0 kernel/sched/core.c:2359
        copy_process+0x25b9/0x87a0 kernel/fork.c:1883
        _do_fork+0x1cb/0x11d0 kernel/fork.c:2212
        kernel_thread+0x34/0x40 kernel/fork.c:2271
        rest_init+0x28/0x372 init/main.c:408
        arch_call_rest_init+0xe/0x1b
        start_kernel+0x9a5/0x9e0 init/main.c:740
        x86_64_start_reservations+0x29/0x2b arch/x86/kernel/head64.c:470
        x86_64_start_kernel+0x76/0x79 arch/x86/kernel/head64.c:451
        secondary_startup_64+0xa4/0xb0 arch/x86/kernel/head_64.S:243

-> #0 (&p->pi_lock){-.-.}:
        lock_acquire+0x1ed/0x520 kernel/locking/lockdep.c:3844
        __raw_spin_lock_irqsave include/linux/spinlock_api_smp.h:110 [inline]
        _raw_spin_lock_irqsave+0x99/0xd0 kernel/locking/spinlock.c:152
        try_to_wake_up+0xdc/0x1440 kernel/sched/core.c:1965
        default_wake_function+0x30/0x50 kernel/sched/core.c:3710
        autoremove_wake_function+0x80/0x370 kernel/sched/wait.c:375
        __wake_up_common+0x1d7/0x7d0 kernel/sched/wait.c:92
        __wake_up_common_lock+0x1c2/0x330 kernel/sched/wait.c:121
        __wake_up+0xe/0x10 kernel/sched/wait.c:145
        wakeup_kswapd+0x592/0x8f0 mm/vmscan.c:4001
        steal_suitable_fallback+0x538/0x830 mm/page_alloc.c:2308
        __rmqueue_fallback mm/page_alloc.c:2593 [inline]
        __rmqueue mm/page_alloc.c:2619 [inline]
        rmqueue_bulk mm/page_alloc.c:2641 [inline]
        __rmqueue_pcplist mm/page_alloc.c:3106 [inline]
        rmqueue_pcplist mm/page_alloc.c:3135 [inline]
        rmqueue mm/page_alloc.c:3157 [inline]
        get_page_from_freelist+0x32cf/0x5360 mm/page_alloc.c:3570
        __alloc_pages_nodemask+0x668/0xec0 mm/page_alloc.c:4608
        alloc_pages_current+0x173/0x350 mm/mempolicy.c:2106
        alloc_pages include/linux/gfp.h:509 [inline]
        __vmalloc_area_node mm/vmalloc.c:1690 [inline]
        __vmalloc_node_range+0x5ca/0x8d0 mm/vmalloc.c:1750
        __vmalloc_node mm/vmalloc.c:1795 [inline]
        __vmalloc_node_flags mm/vmalloc.c:1809 [inline]
        vmalloc+0x6f/0x80 mm/vmalloc.c:1831
        do_replace_finish+0x10c/0x2940 net/bridge/netfilter/ebtables.c:1019
        do_replace+0x384/0x4c0 net/bridge/netfilter/ebtables.c:1159
        do_ebt_set_ctl+0xe7/0x110 net/bridge/netfilter/ebtables.c:1528
        nf_sockopt net/netfilter/nf_sockopt.c:106 [inline]
        nf_setsockopt+0x7d/0xd0 net/netfilter/nf_sockopt.c:115
        ip_setsockopt+0xd8/0xf0 net/ipv4/ip_sockglue.c:1260
        udp_setsockopt+0x62/0xa0 net/ipv4/udp.c:2649
        ipv6_setsockopt+0x149/0x170 net/ipv6/ipv6_sockglue.c:935
        tcp_setsockopt+0x93/0xe0 net/ipv4/tcp.c:3068
        sock_common_setsockopt+0x9a/0xe0 net/core/sock.c:2986
        __sys_setsockopt+0x1ba/0x3c0 net/socket.c:1903
        __do_sys_setsockopt net/socket.c:1914 [inline]
        __se_sys_setsockopt net/socket.c:1911 [inline]
        __x64_sys_setsockopt+0xbe/0x150 net/socket.c:1911
        do_syscall_64+0x1b9/0x820 arch/x86/entry/common.c:290
        entry_SYSCALL_64_after_hwframe+0x49/0xbe

other info that might help us debug this:

Chain exists of:
   &p->pi_lock --> &(&zone->lock)->rlock --> &pgdat->kswapd_wait

  Possible unsafe locking scenario:

        CPU0                    CPU1
        ----                    ----
   lock(&pgdat->kswapd_wait);
                                lock(&(&zone->lock)->rlock);
                                lock(&pgdat->kswapd_wait);
   lock(&p->pi_lock);

  *** DEADLOCK ***

2 locks held by syz-executor5/1221:
  #0: 0000000023b66a9e (&(&zone->lock)->rlock){..-.}, at: spin_lock  
include/linux/spinlock.h:329 [inline]
  #0: 0000000023b66a9e (&(&zone->lock)->rlock){..-.}, at: rmqueue_bulk  
mm/page_alloc.c:2639 [inline]
  #0: 0000000023b66a9e (&(&zone->lock)->rlock){..-.}, at: __rmqueue_pcplist  
mm/page_alloc.c:3106 [inline]
  #0: 0000000023b66a9e (&(&zone->lock)->rlock){..-.}, at: rmqueue_pcplist  
mm/page_alloc.c:3135 [inline]
  #0: 0000000023b66a9e (&(&zone->lock)->rlock){..-.}, at: rmqueue  
mm/page_alloc.c:3157 [inline]
  #0: 0000000023b66a9e (&(&zone->lock)->rlock){..-.}, at:  
get_page_from_freelist+0x1cdb/0x5360 mm/page_alloc.c:3570
  #1: 00000000a84a436c (&pgdat->kswapd_wait){....}, at:  
__wake_up_common_lock+0x19e/0x330 kernel/sched/wait.c:120

stack backtrace:
CPU: 0 PID: 1221 Comm: syz-executor5 Not tainted 4.20.0-rc6-next-20181213+  
#170
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS  
Google 01/01/2011
Call Trace:
  __dump_stack lib/dump_stack.c:77 [inline]
  dump_stack+0x244/0x39d lib/dump_stack.c:113
  print_circular_bug.isra.35.cold.56+0x1bd/0x27d  
kernel/locking/lockdep.c:1221
  check_prev_add kernel/locking/lockdep.c:1863 [inline]
  check_prevs_add kernel/locking/lockdep.c:1976 [inline]
  validate_chain kernel/locking/lockdep.c:2347 [inline]
  __lock_acquire+0x3399/0x4c20 kernel/locking/lockdep.c:3341
  lock_acquire+0x1ed/0x520 kernel/locking/lockdep.c:3844
  __raw_spin_lock_irqsave include/linux/spinlock_api_smp.h:110 [inline]
  _raw_spin_lock_irqsave+0x99/0xd0 kernel/locking/spinlock.c:152
  try_to_wake_up+0xdc/0x1440 kernel/sched/core.c:1965
  default_wake_function+0x30/0x50 kernel/sched/core.c:3710
  autoremove_wake_function+0x80/0x370 kernel/sched/wait.c:375
  __wake_up_common+0x1d7/0x7d0 kernel/sched/wait.c:92
  __wake_up_common_lock+0x1c2/0x330 kernel/sched/wait.c:121
  __wake_up+0xe/0x10 kernel/sched/wait.c:145
  wakeup_kswapd+0x592/0x8f0 mm/vmscan.c:4001
  steal_suitable_fallback+0x538/0x830 mm/page_alloc.c:2308
  __rmqueue_fallback mm/page_alloc.c:2593 [inline]
  __rmqueue mm/page_alloc.c:2619 [inline]
  rmqueue_bulk mm/page_alloc.c:2641 [inline]
  __rmqueue_pcplist mm/page_alloc.c:3106 [inline]
  rmqueue_pcplist mm/page_alloc.c:3135 [inline]
  rmqueue mm/page_alloc.c:3157 [inline]
  get_page_from_freelist+0x32cf/0x5360 mm/page_alloc.c:3570
  __alloc_pages_nodemask+0x668/0xec0 mm/page_alloc.c:4608
  alloc_pages_current+0x173/0x350 mm/mempolicy.c:2106
  alloc_pages include/linux/gfp.h:509 [inline]
  __vmalloc_area_node mm/vmalloc.c:1690 [inline]
  __vmalloc_node_range+0x5ca/0x8d0 mm/vmalloc.c:1750
  __vmalloc_node mm/vmalloc.c:1795 [inline]
  __vmalloc_node_flags mm/vmalloc.c:1809 [inline]
  vmalloc+0x6f/0x80 mm/vmalloc.c:1831
  do_replace_finish+0x10c/0x2940 net/bridge/netfilter/ebtables.c:1019
  do_replace+0x384/0x4c0 net/bridge/netfilter/ebtables.c:1159
  do_ebt_set_ctl+0xe7/0x110 net/bridge/netfilter/ebtables.c:1528
  nf_sockopt net/netfilter/nf_sockopt.c:106 [inline]
  nf_setsockopt+0x7d/0xd0 net/netfilter/nf_sockopt.c:115
  ip_setsockopt+0xd8/0xf0 net/ipv4/ip_sockglue.c:1260
  udp_setsockopt+0x62/0xa0 net/ipv4/udp.c:2649
  ipv6_setsockopt+0x149/0x170 net/ipv6/ipv6_sockglue.c:935
  tcp_setsockopt+0x93/0xe0 net/ipv4/tcp.c:3068
  sock_common_setsockopt+0x9a/0xe0 net/core/sock.c:2986
  __sys_setsockopt+0x1ba/0x3c0 net/socket.c:1903
  __do_sys_setsockopt net/socket.c:1914 [inline]
  __se_sys_setsockopt net/socket.c:1911 [inline]
  __x64_sys_setsockopt+0xbe/0x150 net/socket.c:1911
  do_syscall_64+0x1b9/0x820 arch/x86/entry/common.c:290
  entry_SYSCALL_64_after_hwframe+0x49/0xbe
RIP: 0033:0x457679
Code: fd b3 fb ff c3 66 2e 0f 1f 84 00 00 00 00 00 66 90 48 89 f8 48 89 f7  
48 89 d6 48 89 ca 4d 89 c2 4d 89 c8 4c 8b 4c 24 08 0f 05 <48> 3d 01 f0 ff  
ff 0f 83 cb b3 fb ff c3 66 2e 0f 1f 84 00 00 00 00
RSP: 002b:00007f2b4ec2fc78 EFLAGS: 00000246 ORIG_RAX: 0000000000000036
RAX: ffffffffffffffda RBX: 0000000000000005 RCX: 0000000000457679
RDX: 0000000000000080 RSI: 0000000000000000 RDI: 0000000000000003
RBP: 000000000072bf00 R08: 00000000000003e0 R09: 0000000000000000
R10: 00000000200004c0 R11: 0000000000000246 R12: 00007f2b4ec306d4
R13: 00000000004c4618 R14: 00000000004d77f8 R15: 00000000ffffffff
__bpf_mt_check_bytecode: 9 callbacks suppressed
xt_bpf: check failed: parse error
kobject: 'loop5' (0000000051a7cf3c): kobject_uevent_env
kobject: 'kvm' (00000000ef57b484): kobject_uevent_env
kobject: 'loop5' (0000000051a7cf3c): fill_kobj_path: path  
= '/devices/virtual/block/loop5'
kobject: 'kvm' (00000000ef57b484): fill_kobj_path: path  
= '/devices/virtual/misc/kvm'
xt_bpf: check failed: parse error
kobject: 'kvm' (00000000ef57b484): kobject_uevent_env
kobject: 'loop4' (00000000cc7e0096): kobject_uevent_env
kobject: 'kvm' (00000000ef57b484): fill_kobj_path: path  
= '/devices/virtual/misc/kvm'
kobject: 'kvm' (00000000ef57b484): kobject_uevent_env
kobject: 'loop4' (00000000cc7e0096): fill_kobj_path: path  
= '/devices/virtual/block/loop4'
kobject: 'kvm' (00000000ef57b484): fill_kobj_path: path  
= '/devices/virtual/misc/kvm'
kobject: 'loop5' (0000000051a7cf3c): kobject_uevent_env
xt_bpf: check failed: parse error
kobject: 'loop5' (0000000051a7cf3c): fill_kobj_path: path  
= '/devices/virtual/block/loop5'
xt_bpf: check failed: parse error
kobject: 'loop2' (000000003765b848): kobject_uevent_env
kobject: 'kvm' (00000000ef57b484): kobject_uevent_env
kobject: 'loop2' (000000003765b848): fill_kobj_path: path  
= '/devices/virtual/block/loop2'
kobject: 'kvm' (00000000ef57b484): fill_kobj_path: path  
= '/devices/virtual/misc/kvm'
kobject: 'loop1' (00000000ab5963b8): kobject_uevent_env
kobject: 'loop1' (00000000ab5963b8): fill_kobj_path: path  
= '/devices/virtual/block/loop1'
kobject: 'loop4' (00000000cc7e0096): kobject_uevent_env
xt_bpf: check failed: parse error
xt_bpf: check failed: parse error
kobject: 'loop4' (00000000cc7e0096): fill_kobj_path: path  
= '/devices/virtual/block/loop4'
kobject: 'kvm' (00000000ef57b484): kobject_uevent_env
kobject: 'kvm' (00000000ef57b484): fill_kobj_path: path  
= '/devices/virtual/misc/kvm'
kobject: 'loop5' (0000000051a7cf3c): kobject_uevent_env
kobject: 'loop5' (0000000051a7cf3c): fill_kobj_path: path  
= '/devices/virtual/block/loop5'
kobject: 'loop3' (000000007885b562): kobject_uevent_env
kobject: 'loop3' (000000007885b562): fill_kobj_path: path  
= '/devices/virtual/block/loop3'
kobject: 'loop2' (000000003765b848): kobject_uevent_env
kobject: 'loop2' (000000003765b848): fill_kobj_path: path  
= '/devices/virtual/block/loop2'
kobject: 'kvm' (00000000ef57b484): kobject_uevent_env
kobject: 'kvm' (00000000ef57b484): fill_kobj_path: path  
= '/devices/virtual/misc/kvm'
kobject: 'loop5' (0000000051a7cf3c): kobject_uevent_env
xt_bpf: check failed: parse error
xt_bpf: check failed: parse error
kobject: 'loop5' (0000000051a7cf3c): fill_kobj_path: path  
= '/devices/virtual/block/loop5'
kobject: 'kvm' (00000000ef57b484): kobject_uevent_env
kobject: 'kvm' (00000000ef57b484): fill_kobj_path: path  
= '/devices/virtual/misc/kvm'
kobject: 'loop4' (00000000cc7e0096): kobject_uevent_env
kobject: 'loop4' (00000000cc7e0096): fill_kobj_path: path  
= '/devices/virtual/block/loop4'
kobject: 'loop1' (00000000ab5963b8): kobject_uevent_env
kobject: 'loop1' (00000000ab5963b8): fill_kobj_path: path  
= '/devices/virtual/block/loop1'
kobject: 'loop2' (000000003765b848): kobject_uevent_env
xt_bpf: check failed: parse error
kobject: 'kvm' (00000000ef57b484): kobject_uevent_env
kobject: 'loop2' (000000003765b848): fill_kobj_path: path  
= '/devices/virtual/block/loop2'
kobject: 'kvm' (00000000ef57b484): fill_kobj_path: path  
= '/devices/virtual/misc/kvm'
kobject: 'loop5' (0000000051a7cf3c): kobject_uevent_env
xt_bpf: check failed: parse error
kobject: 'kvm' (00000000ef57b484): kobject_uevent_env
kobject: 'loop5' (0000000051a7cf3c): fill_kobj_path: path  
= '/devices/virtual/block/loop5'
kobject: 'kvm' (00000000ef57b484): fill_kobj_path: path  
= '/devices/virtual/misc/kvm'
kobject: 'loop4' (00000000cc7e0096): kobject_uevent_env
kobject: 'loop4' (00000000cc7e0096): fill_kobj_path: path  
= '/devices/virtual/block/loop4'
kobject: 'kvm' (00000000ef57b484): kobject_uevent_env
kobject: 'loop3' (000000007885b562): kobject_uevent_env
kobject: 'kvm' (00000000ef57b484): fill_kobj_path: path  
= '/devices/virtual/misc/kvm'
kobject: 'loop3' (000000007885b562): fill_kobj_path: path  
= '/devices/virtual/block/loop3'
kobject: 'loop5' (0000000051a7cf3c): kobject_uevent_env
kobject: 'loop5' (0000000051a7cf3c): fill_kobj_path: path  
= '/devices/virtual/block/loop5'
kobject: 'kvm' (00000000ef57b484): kobject_uevent_env
kobject: 'loop2' (000000003765b848): kobject_uevent_env
kobject: 'loop2' (000000003765b848): fill_kobj_path: path  
= '/devices/virtual/block/loop2'
kobject: 'kvm' (00000000ef57b484): fill_kobj_path: path  
= '/devices/virtual/misc/kvm'
kobject: 'loop1' (00000000ab5963b8): kobject_uevent_env
kobject: 'loop1' (00000000ab5963b8): fill_kobj_path: path  
= '/devices/virtual/block/loop1'
kobject: 'loop4' (00000000cc7e0096): kobject_uevent_env
kobject: 'loop4' (00000000cc7e0096): fill_kobj_path: path  
= '/devices/virtual/block/loop4'
kobject: 'loop2' (000000003765b848): kobject_uevent_env
kobject: 'loop2' (000000003765b848): fill_kobj_path: path  
= '/devices/virtual/block/loop2'
kobject: 'loop5' (0000000051a7cf3c): kobject_uevent_env
kobject: 'loop5' (0000000051a7cf3c): fill_kobj_path: path  
= '/devices/virtual/block/loop5'
kobject: 'kvm' (00000000ef57b484): kobject_uevent_env
kobject: 'loop4' (00000000cc7e0096): kobject_uevent_env
kobject: 'kvm' (00000000ef57b484): fill_kobj_path: path  
= '/devices/virtual/misc/kvm'
kobject: 'loop4' (00000000cc7e0096): fill_kobj_path: path  
= '/devices/virtual/block/loop4'
kobject: 'loop1' (00000000ab5963b8): kobject_uevent_env
kobject: 'loop1' (00000000ab5963b8): fill_kobj_path: path  
= '/devices/virtual/block/loop1'
kobject: 'loop5' (0000000051a7cf3c): kobject_uevent_env
kobject: 'loop5' (0000000051a7cf3c): fill_kobj_path: path  
= '/devices/virtual/block/loop5'
kobject: 'loop4' (00000000cc7e0096): kobject_uevent_env
kobject: 'loop4' (00000000cc7e0096): fill_kobj_path: path  
= '/devices/virtual/block/loop4'
kobject: 'loop2' (000000003765b848): kobject_uevent_env
kobject: 'kvm' (00000000ef57b484): kobject_uevent_env
kobject: 'loop2' (000000003765b848): fill_kobj_path: path  
= '/devices/virtual/block/loop2'
kobject: 'kvm' (00000000ef57b484): fill_kobj_path: path  
= '/devices/virtual/misc/kvm'
kobject: 'loop3' (000000007885b562): kobject_uevent_env
kobject: 'loop3' (000000007885b562): fill_kobj_path: path  
= '/devices/virtual/block/loop3'
kobject: 'kvm' (00000000ef57b484): kobject_uevent_env
kobject: 'kvm' (00000000ef57b484): kobject_uevent_env
kobject: 'loop5' (0000000051a7cf3c): kobject_uevent_env
kobject: 'loop5' (0000000051a7cf3c): fill_kobj_path: path  
= '/devices/virtual/block/loop5'
kobject: 'kvm' (00000000ef57b484): fill_kobj_path: path  
= '/devices/virtual/misc/kvm'
kobject: 'kvm' (00000000ef57b484): fill_kobj_path: path  
= '/devices/virtual/misc/kvm'
kobject: 'loop1' (00000000ab5963b8): kobject_uevent_env
kobject: 'loop1' (00000000ab5963b8): fill_kobj_path: path  
= '/devices/virtual/block/loop1'
kobject: 'loop4' (00000000cc7e0096): kobject_uevent_env
kobject: 'loop4' (00000000cc7e0096): fill_kobj_path: path  
= '/devices/virtual/block/loop4'
kobject: 'kvm' (00000000ef57b484): kobject_uevent_env
kobject: 'loop4' (00000000cc7e0096): kobject_uevent_env
kobject: 'kvm' (00000000ef57b484): fill_kobj_path: path  
= '/devices/virtual/misc/kvm'
kobject: 'loop4' (00000000cc7e0096): fill_kobj_path: path  
= '/devices/virtual/block/loop4'
kobject: 'loop5' (0000000051a7cf3c): kobject_uevent_env
kobject: 'loop5' (0000000051a7cf3c): fill_kobj_path: path  
= '/devices/virtual/block/loop5'
kobject: 'loop1' (00000000ab5963b8): kobject_uevent_env
kobject: 'loop1' (00000000ab5963b8): fill_kobj_path: path  
= '/devices/virtual/block/loop1'
kobject: 'loop4' (00000000cc7e0096): kobject_uevent_env
kobject: 'kvm' (00000000ef57b484): kobject_uevent_env
kobject: 'loop4' (00000000cc7e0096): fill_kobj_path: path  
= '/devices/virtual/block/loop4'
kobject: 'loop5' (0000000051a7cf3c): kobject_uevent_env
kobject: 'kvm' (00000000ef57b484): fill_kobj_path: path  
= '/devices/virtual/misc/kvm'
kobject: 'loop5' (0000000051a7cf3c): fill_kobj_path: path  
= '/devices/virtual/block/loop5'
kobject: 'loop3' (000000007885b562): kobject_uevent_env
kobject: 'loop3' (000000007885b562): fill_kobj_path: path  
= '/devices/virtual/block/loop3'
kobject: 'kvm' (00000000ef57b484): kobject_uevent_env
kobject: 'loop4' (00000000cc7e0096): kobject_uevent_env
kobject: 'kvm' (00000000ef57b484): fill_kobj_path: path  
= '/devices/virtual/misc/kvm'
kobject: 'loop4' (00000000cc7e0096): fill_kobj_path: path  
= '/devices/virtual/block/loop4'
kobject: 'kvm' (00000000ef57b484): kobject_uevent_env
kobject: 'kvm' (00000000ef57b484): fill_kobj_path: path  
= '/devices/virtual/misc/kvm'
kobject: 'kvm' (00000000ef57b484): kobject_uevent_env
kobject: 'loop1' (00000000ab5963b8): kobject_uevent_env
kobject: 'kvm' (00000000ef57b484): fill_kobj_path: path  
= '/devices/virtual/misc/kvm'
kobject: 'loop1' (00000000ab5963b8): fill_kobj_path: path  
= '/devices/virtual/block/loop1'
kobject: 'loop3' (000000007885b562): kobject_uevent_env
kobject: 'loop3' (000000007885b562): fill_kobj_path: path  
= '/devices/virtual/block/loop3'
kobject: 'kvm' (00000000ef57b484): kobject_uevent_env
kobject: 'loop2' (000000003765b848): kobject_uevent_env
kobject: 'loop2' (000000003765b848): fill_kobj_path: path  
= '/devices/virtual/block/loop2'
kobject: 'loop4' (00000000cc7e0096): kobject_uevent_env
kobject: 'kvm' (00000000ef57b484): fill_kobj_path: path  
= '/devices/virtual/misc/kvm'
kobject: 'loop4' (00000000cc7e0096): fill_kobj_path: path  
= '/devices/virtual/block/loop4'
kobject: 'kvm' (00000000ef57b484): kobject_uevent_env
kobject: 'kvm' (00000000ef57b484): kobject_uevent_env
kobject: 'loop5' (0000000051a7cf3c): kobject_uevent_env
kobject: 'kvm' (00000000ef57b484): fill_kobj_path: path  
= '/devices/virtual/misc/kvm'
kobject: 'loop5' (0000000051a7cf3c): fill_kobj_path: path  
= '/devices/virtual/block/loop5'
kobject: 'kvm' (00000000ef57b484): fill_kobj_path: path  
= '/devices/virtual/misc/kvm'
kobject: 'loop4' (00000000cc7e0096): kobject_uevent_env
kobject: 'loop4' (00000000cc7e0096): fill_kobj_path: path  
= '/devices/virtual/block/loop4'
kobject: 'loop1' (00000000ab5963b8): kobject_uevent_env
kobject: 'loop1' (00000000ab5963b8): fill_kobj_path: path  
= '/devices/virtual/block/loop1'
kobject: 'kvm' (00000000ef57b484): kobject_uevent_env
kobject: 'kvm' (00000000ef57b484): fill_kobj_path: path  
= '/devices/virtual/misc/kvm'
kobject: 'loop2' (000000003765b848): kobject_uevent_env
kobject: 'loop2' (000000003765b848): fill_kobj_path: path  
= '/devices/virtual/block/loop2'
kobject: 'loop4' (00000000cc7e0096): kobject_uevent_env
kobject: 'loop4' (00000000cc7e0096): fill_kobj_path: path  
= '/devices/virtual/block/loop4'
kobject: 'loop3' (000000007885b562): kobject_uevent_env
kobject: 'kvm' (00000000ef57b484): kobject_uevent_env
kobject: 'loop3' (000000007885b562): fill_kobj_path: path  
= '/devices/virtual/block/loop3'
kobject: 'kvm' (00000000ef57b484): fill_kobj_path: path  
= '/devices/virtual/misc/kvm'
kobject: 'loop4' (00000000cc7e0096): kobject_uevent_env
kobject: 'loop4' (00000000cc7e0096): fill_kobj_path: path  
= '/devices/virtual/block/loop4'
kobject: 'kvm' (00000000ef57b484): kobject_uevent_env
kobject: 'loop1' (00000000ab5963b8): kobject_uevent_env
kobject: 'kvm' (00000000ef57b484): fill_kobj_path: path  
= '/devices/virtual/misc/kvm'
kobject: 'loop1' (00000000ab5963b8): fill_kobj_path: path  
= '/devices/virtual/block/loop1'
kobject: 'kvm' (00000000ef57b484): kobject_uevent_env
kobject: 'kvm' (00000000ef57b484): fill_kobj_path: path  
= '/devices/virtual/misc/kvm'
kobject: 'loop4' (00000000cc7e0096): kobject_uevent_env
kobject: 'loop4' (00000000cc7e0096): fill_kobj_path: path  
= '/devices/virtual/block/loop4'
kobject: 'kvm' (00000000ef57b484): kobject_uevent_env
kobject: 'kvm' (00000000ef57b484): fill_kobj_path: path  
= '/devices/virtual/misc/kvm'
kobject: 'loop3' (000000007885b562): kobject_uevent_env
kobject: 'loop3' (000000007885b562): fill_kobj_path: path  
= '/devices/virtual/block/loop3'
kobject: 'loop1' (00000000ab5963b8): kobject_uevent_env
kobject: 'loop1' (00000000ab5963b8): fill_kobj_path: path  
= '/devices/virtual/block/loop1'
kobject: 'loop4' (00000000cc7e0096): kobject_uevent_env
kobject: 'loop4' (00000000cc7e0096): fill_kobj_path: path  
= '/devices/virtual/block/loop4'
kobject: 'loop2' (000000003765b848): kobject_uevent_env
kobject: 'loop2' (000000003765b848): fill_kobj_path: path  
= '/devices/virtual/block/loop2'
kobject: 'loop5' (0000000051a7cf3c): kobject_uevent_env
kobject: 'kvm' (00000000ef57b484): kobject_uevent_env
kobject: 'loop5' (0000000051a7cf3c): fill_kobj_path: path  
= '/devices/virtual/block/loop5'
__bpf_mt_check_bytecode: 22 callbacks suppressed
xt_bpf: check failed: parse error
kobject: 'kvm' (00000000ef57b484): fill_kobj_path: path  
= '/devices/virtual/misc/kvm'
kobject: 'loop4' (00000000cc7e0096): kobject_uevent_env
kobject: 'loop4' (00000000cc7e0096): fill_kobj_path: path  
= '/devices/virtual/block/loop4'
kobject: 'kvm' (00000000ef57b484): kobject_uevent_env
kobject: 'kvm' (00000000ef57b484): fill_kobj_path: path  
= '/devices/virtual/misc/kvm'
kobject: 'loop5' (0000000051a7cf3c): kobject_uevent_env
xt_bpf: check failed: parse error
kobject: 'kvm' (00000000ef57b484): kobject_uevent_env
kobject: 'loop5' (0000000051a7cf3c): fill_kobj_path: path  
= '/devices/virtual/block/loop5'
kobject: 'kvm' (00000000ef57b484): fill_kobj_path: path  
= '/devices/virtual/misc/kvm'
xt_bpf: check failed: parse error
kobject: 'loop5' (0000000051a7cf3c): kobject_uevent_env
xt_bpf: check failed: parse error
kobject: 'loop5' (0000000051a7cf3c): fill_kobj_path: path  
= '/devices/virtual/block/loop5'
kobject: 'loop1' (00000000ab5963b8): kobject_uevent_env
kobject: 'loop1' (00000000ab5963b8): fill_kobj_path: path  
= '/devices/virtual/block/loop1'
kobject: 'loop4' (00000000cc7e0096): kobject_uevent_env
kobject: 'kvm' (00000000ef57b484): kobject_uevent_env
kobject: 'loop4' (00000000cc7e0096): fill_kobj_path: path  
= '/devices/virtual/block/loop4'
kobject: 'kvm' (00000000ef57b484): fill_kobj_path: path  
= '/devices/virtual/misc/kvm'
kobject: 'loop5' (0000000051a7cf3c): kobject_uevent_env
kobject: 'loop5' (0000000051a7cf3c): fill_kobj_path: path  
= '/devices/virtual/block/loop5'
xt_bpf: check failed: parse error
xt_bpf: check failed: parse error
kobject: 'loop1' (00000000ab5963b8): kobject_uevent_env
kobject: 'loop1' (00000000ab5963b8): fill_kobj_path: path  
= '/devices/virtual/block/loop1'
kobject: 'loop3' (000000007885b562): kobject_uevent_env
kobject: 'loop3' (000000007885b562): fill_kobj_path: path  
= '/devices/virtual/block/loop3'
kobject: 'loop4' (00000000cc7e0096): kobject_uevent_env
kobject: 'loop4' (00000000cc7e0096): fill_kobj_path: path  
= '/devices/virtual/block/loop4'
kobject: 'kvm' (00000000ef57b484): kobject_uevent_env
kobject: 'loop5' (0000000051a7cf3c): kobject_uevent_env
kobject: 'kvm' (00000000ef57b484): fill_kobj_path: path  
= '/devices/virtual/misc/kvm'
kobject: 'loop5' (0000000051a7cf3c): fill_kobj_path: path  
= '/devices/virtual/block/loop5'
kobject: 'kvm' (00000000ef57b484): kobject_uevent_env
kobject: 'kvm' (00000000ef57b484): fill_kobj_path: path  
= '/devices/virtual/misc/kvm'
kobject: 'kvm' (00000000ef57b484): kobject_uevent_env
kobject: 'kvm' (00000000ef57b484): fill_kobj_path: path  
= '/devices/virtual/misc/kvm'
kobject: 'loop1' (00000000ab5963b8): kobject_uevent_env
kobject: 'loop1' (00000000ab5963b8): fill_kobj_path: path  
= '/devices/virtual/block/loop1'
kobject: 'kvm' (00000000ef57b484): kobject_uevent_env
kobject: 'kvm' (00000000ef57b484): fill_kobj_path: path  
= '/devices/virtual/misc/kvm'
kobject: 'loop3' (000000007885b562): kobject_uevent_env
kobject: 'loop3' (000000007885b562): fill_kobj_path: path  
= '/devices/virtual/block/loop3'
kobject: 'loop2' (000000003765b848): kobject_uevent_env
kobject: 'kvm' (00000000ef57b484): kobject_uevent_env
xt_bpf: check failed: parse error
kobject: 'kvm' (00000000ef57b484): fill_kobj_path: path  
= '/devices/virtual/misc/kvm'
kobject: 'loop2' (000000003765b848): fill_kobj_path: path  
= '/devices/virtual/block/loop2'
kobject: 'loop4' (00000000cc7e0096): kobject_uevent_env
kobject: 'kvm' (00000000ef57b484): kobject_uevent_env
kobject: 'kvm' (00000000ef57b484): fill_kobj_path: path  
= '/devices/virtual/misc/kvm'
kobject: 'loop4' (00000000cc7e0096): fill_kobj_path: path  
= '/devices/virtual/block/loop4'
kobject: 'kvm' (00000000ef57b484): kobject_uevent_env
kobject: 'kvm' (00000000ef57b484): fill_kobj_path: path  
= '/devices/virtual/misc/kvm'
xt_bpf: check failed: parse error
kobject: 'loop1' (00000000ab5963b8): kobject_uevent_env
kobject: 'loop1' (00000000ab5963b8): fill_kobj_path: path  
= '/devices/virtual/block/loop1'
kobject: 'kvm' (00000000ef57b484): kobject_uevent_env
kobject: 'loop4' (00000000cc7e0096): kobject_uevent_env
kobject: 'kvm' (00000000ef57b484): fill_kobj_path: path  
= '/devices/virtual/misc/kvm'
kobject: 'loop4' (00000000cc7e0096): fill_kobj_path: path  
= '/devices/virtual/block/loop4'
kobject: 'loop3' (000000007885b562): kobject_uevent_env
xt_bpf: check failed: parse error
kobject: 'loop3' (000000007885b562): fill_kobj_path: path  
= '/devices/virtual/block/loop3'
kobject: 'kvm' (00000000ef57b484): kobject_uevent_env
kobject: 'kvm' (00000000ef57b484): fill_kobj_path: path  
= '/devices/virtual/misc/kvm'
kobject: 'loop4' (00000000cc7e0096): kobject_uevent_env
kobject: 'loop4' (00000000cc7e0096): fill_kobj_path: path  
= '/devices/virtual/block/loop4'
kobject: 'kvm' (00000000ef57b484): kobject_uevent_env
kobject: 'kvm' (00000000ef57b484): kobject_uevent_env
kobject: 'loop1' (00000000ab5963b8): kobject_uevent_env
kobject: 'loop1' (00000000ab5963b8): fill_kobj_path: path  
= '/devices/virtual/block/loop1'
kobject: 'kvm' (00000000ef57b484): fill_kobj_path: path  
= '/devices/virtual/misc/kvm'
kobject: 'kvm' (00000000ef57b484): fill_kobj_path: path  
= '/devices/virtual/misc/kvm'
kobject: 'kvm' (00000000ef57b484): kobject_uevent_env
kobject: 'kvm' (00000000ef57b484): fill_kobj_path: path  
= '/devices/virtual/misc/kvm'
kobject: 'loop3' (000000007885b562): kobject_uevent_env
kobject: 'loop3' (000000007885b562): fill_kobj_path: path  
= '/devices/virtual/block/loop3'
kobject: 'loop2' (000000003765b848): kobject_uevent_env
kobject: 'loop2' (000000003765b848): fill_kobj_path: path  
= '/devices/virtual/block/loop2'
xt_bpf: check failed: parse error


---
This bug is generated by a bot. It may contain errors.
See https://goo.gl/tpsmEJ for more information about syzbot.
syzbot engineers can be reached at syzkaller@googlegroups.com.

syzbot will keep track of this bug report. See:
https://goo.gl/tpsmEJ#bug-status-tracking for how to communicate with  
syzbot.
