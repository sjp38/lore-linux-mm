Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 846FB6B0005
	for <linux-mm@kvack.org>; Mon, 18 Jan 2016 08:08:37 -0500 (EST)
Received: by mail-wm0-f43.google.com with SMTP id b14so122169988wmb.1
        for <linux-mm@kvack.org>; Mon, 18 Jan 2016 05:08:37 -0800 (PST)
Received: from mail-wm0-x22a.google.com (mail-wm0-x22a.google.com. [2a00:1450:400c:c09::22a])
        by mx.google.com with ESMTPS id kd2si38273575wjc.45.2016.01.18.05.08.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Jan 2016 05:08:35 -0800 (PST)
Received: by mail-wm0-x22a.google.com with SMTP id n5so63165815wmn.0
        for <linux-mm@kvack.org>; Mon, 18 Jan 2016 05:08:35 -0800 (PST)
MIME-Version: 1.0
From: Dmitry Vyukov <dvyukov@google.com>
Date: Mon, 18 Jan 2016 14:08:15 +0100
Message-ID: <CACT4Y+ayDrEmn31qyoVdnq6vpSbL=XzFWPM5_Ee4GH=Waf27eA@mail.gmail.com>
Subject: mm: SOFTIRQ-safe -> SOFTIRQ-unsafe lock order detected in split_huge_page_to_list
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Sasha Levin <sasha.levin@oracle.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, jmarchan@redhat.com, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Ebru Akagunduz <ebru.akagunduz@gmail.com>, Dan Williams <dan.j.williams@intel.com>, Minchan Kim <minchan@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
Cc: syzkaller <syzkaller@googlegroups.com>, Kostya Serebryany <kcc@google.com>, Alexander Potapenko <glider@google.com>

Hello,

While running syzkaller fuzzer I've hit the following report.

Looks like cause by the recent commit
e9b61f19858a5d6c42ce2298cf138279375d0d9b "thp: reintroduce
split_huge_page()".

======================================================
[ INFO: SOFTIRQ-safe -> SOFTIRQ-unsafe lock order detected ]
4.4.0+ #259 Tainted: G        W
------------------------------------------------------
syz-executor/18183 [HC0[0]:SC0[2]:HE0:SE0] is trying to acquire:
 (split_queue_lock){+.+...}, at: [<ffffffff817847d4>]
free_transhuge_page+0x24/0x90 mm/huge_memory.c:3436

and this task is already holding:
 (slock-AF_INET){+.-...}, at: [<     inline     >] spin_lock_bh
include/linux/spinlock.h:307
 (slock-AF_INET){+.-...}, at: [<ffffffff851c4fe5>]
lock_sock_fast+0x45/0x120 net/core/sock.c:2462
which would create a new lock dependency:
 (slock-AF_INET){+.-...} -> (split_queue_lock){+.+...}

but this new dependency connects a SOFTIRQ-irq-safe lock:
 (slock-AF_INET){+.-...}
... which became SOFTIRQ-irq-safe at:
  [<     inline     >] mark_irqflags kernel/locking/lockdep.c:2799
  [<ffffffff81454718>] __lock_acquire+0xfd8/0x4700 kernel/locking/lockdep.c:3162
  [<ffffffff8145a28c>] lock_acquire+0x1dc/0x430 kernel/locking/lockdep.c:3585
  [<     inline     >] __raw_spin_lock include/linux/spinlock_api_smp.h:144
  [<ffffffff863248d3>] _raw_spin_lock+0x33/0x50 kernel/locking/spinlock.c:151
  [<     inline     >] spin_lock include/linux/spinlock.h:302
  [<ffffffff855e3df1>] udp_queue_rcv_skb+0x781/0x1550 net/ipv4/udp.c:1680
  [<ffffffff855e4c10>] flush_stack+0x50/0x330 net/ipv6/udp.c:799
  [<ffffffff855e5584>] __udp4_lib_mcast_deliver+0x694/0x7f0 net/ipv4/udp.c:1798
  [<ffffffff855e6ebc>] __udp4_lib_rcv+0x17dc/0x23e0 net/ipv4/udp.c:1888
  [<ffffffff855e9021>] udp_rcv+0x21/0x30 net/ipv4/udp.c:2108
  [<ffffffff85513b33>] ip_local_deliver_finish+0x2b3/0xa50
net/ipv4/ip_input.c:216
  [<     inline     >] NF_HOOK_THRESH include/linux/netfilter.h:226
  [<     inline     >] NF_HOOK include/linux/netfilter.h:249
  [<ffffffff855149d4>] ip_local_deliver+0x1c4/0x2f0 net/ipv4/ip_input.c:257
  [<     inline     >] dst_input include/net/dst.h:498
  [<ffffffff8551273c>] ip_rcv_finish+0x5ec/0x1730 net/ipv4/ip_input.c:365
  [<     inline     >] NF_HOOK_THRESH include/linux/netfilter.h:226
  [<     inline     >] NF_HOOK include/linux/netfilter.h:249
  [<ffffffff85515463>] ip_rcv+0x963/0x1080 net/ipv4/ip_input.c:455
  [<ffffffff8521b410>] __netif_receive_skb_core+0x1620/0x2f80
net/core/dev.c:4154
  [<ffffffff8521cd9a>] __netif_receive_skb+0x2a/0x160 net/core/dev.c:4189
  [<ffffffff85220795>] netif_receive_skb_internal+0x1b5/0x390
net/core/dev.c:4217
  [<     inline     >] napi_skb_finish net/core/dev.c:4542
  [<ffffffff85224c9d>] napi_gro_receive+0x2bd/0x3c0 net/core/dev.c:4572
  [<ffffffff83a2f142>] e1000_clean_rx_irq+0x4e2/0x1100
drivers/net/ethernet/intel/e1000e/netdev.c:1038
  [<ffffffff83a2c1f8>] e1000_clean+0xa08/0x24a0
drivers/net/ethernet/intel/e1000/e1000_main.c:3819
  [<     inline     >] napi_poll net/core/dev.c:5074
  [<ffffffff8522285b>] net_rx_action+0x7eb/0xdf0 net/core/dev.c:5139
  [<ffffffff81361c0a>] __do_softirq+0x26a/0x920 kernel/softirq.c:273
  [<     inline     >] invoke_softirq kernel/softirq.c:350
  [<ffffffff8136264f>] irq_exit+0x18f/0x1d0 kernel/softirq.c:391
  [<     inline     >] exiting_irq ./arch/x86/include/asm/apic.h:659
  [<ffffffff811a9a66>] do_IRQ+0x86/0x1a0 arch/x86/kernel/irq.c:252
  [<ffffffff863264cc>] ret_from_intr+0x0/0x20 arch/x86/entry/entry_64.S:520
  [<     inline     >] arch_safe_halt ./arch/x86/include/asm/paravirt.h:117
  [<ffffffff811bdd42>] default_idle+0x52/0x2e0 arch/x86/kernel/process.c:304
  [<ffffffff811bf37a>] arch_cpu_idle+0xa/0x10 arch/x86/kernel/process.c:295
  [<ffffffff81439f48>] default_idle_call+0x48/0xa0 kernel/sched/idle.c:92
  [<     inline     >] cpuidle_idle_call kernel/sched/idle.c:156
  [<     inline     >] cpu_idle_loop kernel/sched/idle.c:252
  [<ffffffff8143a604>] cpu_startup_entry+0x554/0x710 kernel/sched/idle.c:300
  [<ffffffff86301262>] rest_init+0x192/0x1a0 init/main.c:412
  [<ffffffff882fa780>] start_kernel+0x678/0x69e init/main.c:683
  [<ffffffff882f9342>] x86_64_start_reservations+0x2a/0x2c
arch/x86/kernel/head64.c:195
  [<ffffffff882f949c>] x86_64_start_kernel+0x158/0x167
arch/x86/kernel/head64.c:184

to a SOFTIRQ-irq-unsafe lock:
 (split_queue_lock){+.+...}
... which became SOFTIRQ-irq-unsafe at:
...  [<     inline     >] mark_irqflags kernel/locking/lockdep.c:2817
...  [<ffffffff81454bae>] __lock_acquire+0x146e/0x4700
kernel/locking/lockdep.c:3162
  [<ffffffff8145a28c>] lock_acquire+0x1dc/0x430 kernel/locking/lockdep.c:3585
  [<     inline     >] __raw_spin_lock include/linux/spinlock_api_smp.h:144
  [<ffffffff863248d3>] _raw_spin_lock+0x33/0x50 kernel/locking/spinlock.c:151
  [<     inline     >] spin_lock include/linux/spinlock.h:302
  [<ffffffff81782320>] split_huge_page_to_list+0xcc0/0x1c50
mm/huge_memory.c:3399
  [<     inline     >] split_huge_page include/linux/huge_mm.h:99
  [<ffffffff8174a4e8>] queue_pages_pte_range+0xa38/0xef0 mm/mempolicy.c:507
  [<     inline     >] walk_pmd_range mm/pagewalk.c:50
  [<     inline     >] walk_pud_range mm/pagewalk.c:90
  [<     inline     >] walk_pgd_range mm/pagewalk.c:116
  [<ffffffff8171d4f3>] __walk_page_range+0x653/0xcd0 mm/pagewalk.c:204
  [<ffffffff8171dc6e>] walk_page_range+0xfe/0x2b0 mm/pagewalk.c:281
  [<ffffffff81746e7b>] queue_pages_range+0xfb/0x130 mm/mempolicy.c:687
  [<     inline     >] migrate_to_node mm/mempolicy.c:1004
  [<ffffffff8174c340>] do_migrate_pages+0x370/0x4e0 mm/mempolicy.c:1109
  [<     inline     >] SYSC_migrate_pages mm/mempolicy.c:1453
  [<ffffffff8174cc10>] SyS_migrate_pages+0x640/0x730 mm/mempolicy.c:1374
  [<ffffffff863259b6>] entry_SYSCALL_64_fastpath+0x16/0x7a
arch/x86/entry/entry_64.S:185

other info that might help us debug this:

 Possible interrupt unsafe locking scenario:

       CPU0                    CPU1
       ----                    ----
  lock(split_queue_lock);
                               local_irq_disable();
                               lock(slock-AF_INET);
                               lock(split_queue_lock);
  <Interrupt>
    lock(slock-AF_INET);

 *** DEADLOCK ***

1 lock held by syz-executor/18183:
 #0:  (slock-AF_INET){+.-...}, at: [<     inline     >] spin_lock_bh
include/linux/spinlock.h:307
 #0:  (slock-AF_INET){+.-...}, at: [<ffffffff851c4fe5>]
lock_sock_fast+0x45/0x120 net/core/sock.c:2462

the dependencies between SOFTIRQ-irq-safe lock and the holding lock:
-> (slock-AF_INET){+.-...} ops: 596359 {
   HARDIRQ-ON-W at:
                    [<     inline     >] mark_irqflags
kernel/locking/lockdep.c:2813
                    [<ffffffff81454b47>] __lock_acquire+0x1407/0x4700
kernel/locking/lockdep.c:3162
                    [<ffffffff8145a28c>] lock_acquire+0x1dc/0x430
kernel/locking/lockdep.c:3585
                    [<     inline     >] __raw_spin_lock_bh
include/linux/spinlock_api_smp.h:137
                    [<ffffffff86324a1a>] _raw_spin_lock_bh+0x3a/0x50
kernel/locking/spinlock.c:175
                    [<     inline     >] spin_lock_bh
include/linux/spinlock.h:307
                    [<ffffffff851c2cb8>] lock_sock_nested+0x48/0x120
net/core/sock.c:2412
                    [<     inline     >] lock_sock include/net/sock.h:1368
                    [<ffffffff85553642>]
do_tcp_setsockopt.isra.34+0x142/0x1920 net/ipv4/tcp.c:2361
                    [<ffffffff85554ed3>] tcp_setsockopt+0xb3/0xd0
net/ipv4/tcp.c:2618
                    [<ffffffff851c0b77>]
sock_common_setsockopt+0x97/0xd0 net/core/sock.c:2620
                    [<ffffffff85deaf18>] rds_tcp_nonagle+0x138/0x1c0
net/rds/tcp.c:65
                    [<ffffffff85decce8>]
rds_tcp_listen_init+0x118/0x3b0 net/rds/tcp_listen.c:183
                    [<ffffffff85deabcc>] rds_tcp_init_net+0x12c/0x340
net/rds/tcp.c:300
                    [<ffffffff851fb819>] ops_init+0xa9/0x3a0
net/core/net_namespace.c:109
                    [<     inline     >] __register_pernet_operations
net/core/net_namespace.c:781
                    [<ffffffff851fc148>]
register_pernet_operations+0x258/0x4b0 net/core/net_namespace.c:846
                    [<ffffffff851fc3ca>]
register_pernet_subsys+0x2a/0x40 net/core/net_namespace.c:888
                    [<ffffffff85dea79e>] rds_tcp_init+0x5e/0xf0
net/rds/tcp.c:418
                    [<ffffffff81002259>] do_one_initcall+0x159/0x380
init/main.c:794
                    [<     inline     >] do_initcall_level init/main.c:859
                    [<     inline     >] do_initcalls init/main.c:867
                    [<     inline     >] do_basic_setup init/main.c:885
                    [<ffffffff882fac1a>]
kernel_init_freeable+0x474/0x52d init/main.c:1010
                    [<ffffffff86301283>] kernel_init+0x13/0x150 init/main.c:936
                    [<ffffffff86325d6f>] ret_from_fork+0x3f/0x70
arch/x86/entry/entry_64.S:468
   IN-SOFTIRQ-W at:
                    [<     inline     >] mark_irqflags
kernel/locking/lockdep.c:2799
                    [<ffffffff81454718>] __lock_acquire+0xfd8/0x4700
kernel/locking/lockdep.c:3162
                    [<ffffffff8145a28c>] lock_acquire+0x1dc/0x430
kernel/locking/lockdep.c:3585
                    [<     inline     >] __raw_spin_lock
include/linux/spinlock_api_smp.h:144
                    [<ffffffff863248d3>] _raw_spin_lock+0x33/0x50
kernel/locking/spinlock.c:151
                    [<     inline     >] spin_lock include/linux/spinlock.h:302
                    [<ffffffff855e3df1>]
udp_queue_rcv_skb+0x781/0x1550 net/ipv4/udp.c:1680
                    [<ffffffff855e4c10>] flush_stack+0x50/0x330
net/ipv6/udp.c:799
                    [<ffffffff855e5584>]
__udp4_lib_mcast_deliver+0x694/0x7f0 net/ipv4/udp.c:1798
                    [<ffffffff855e6ebc>] __udp4_lib_rcv+0x17dc/0x23e0
net/ipv4/udp.c:1888
                    [<ffffffff855e9021>] udp_rcv+0x21/0x30 net/ipv4/udp.c:2108
                    [<ffffffff85513b33>]
ip_local_deliver_finish+0x2b3/0xa50 net/ipv4/ip_input.c:216
                    [<     inline     >] NF_HOOK_THRESH
include/linux/netfilter.h:226
                    [<     inline     >] NF_HOOK include/linux/netfilter.h:249
                    [<ffffffff855149d4>] ip_local_deliver+0x1c4/0x2f0
net/ipv4/ip_input.c:257
                    [<     inline     >] dst_input include/net/dst.h:498
                    [<ffffffff8551273c>] ip_rcv_finish+0x5ec/0x1730
net/ipv4/ip_input.c:365
                    [<     inline     >] NF_HOOK_THRESH
include/linux/netfilter.h:226
                    [<     inline     >] NF_HOOK include/linux/netfilter.h:249
                    [<ffffffff85515463>] ip_rcv+0x963/0x1080
net/ipv4/ip_input.c:455
                    [<ffffffff8521b410>]
__netif_receive_skb_core+0x1620/0x2f80 net/core/dev.c:4154
                    [<ffffffff8521cd9a>]
__netif_receive_skb+0x2a/0x160 net/core/dev.c:4189
                    [<ffffffff85220795>]
netif_receive_skb_internal+0x1b5/0x390 net/core/dev.c:4217
                    [<     inline     >] napi_skb_finish net/core/dev.c:4542
                    [<ffffffff85224c9d>] napi_gro_receive+0x2bd/0x3c0
net/core/dev.c:4572
                    [<ffffffff83a2f142>]
e1000_clean_rx_irq+0x4e2/0x1100
drivers/net/ethernet/intel/e1000e/netdev.c:1038
                    [<ffffffff83a2c1f8>] e1000_clean+0xa08/0x24a0
drivers/net/ethernet/intel/e1000/e1000_main.c:3819
                    [<     inline     >] napi_poll net/core/dev.c:5074
                    [<ffffffff8522285b>] net_rx_action+0x7eb/0xdf0
net/core/dev.c:5139
                    [<ffffffff81361c0a>] __do_softirq+0x26a/0x920
kernel/softirq.c:273
                    [<     inline     >] invoke_softirq kernel/softirq.c:350
                    [<ffffffff8136264f>] irq_exit+0x18f/0x1d0
kernel/softirq.c:391
                    [<     inline     >] exiting_irq
./arch/x86/include/asm/apic.h:659
                    [<ffffffff811a9a66>] do_IRQ+0x86/0x1a0
arch/x86/kernel/irq.c:252
                    [<ffffffff863264cc>] ret_from_intr+0x0/0x20
arch/x86/entry/entry_64.S:520
                    [<     inline     >] arch_safe_halt
./arch/x86/include/asm/paravirt.h:117
                    [<ffffffff811bdd42>] default_idle+0x52/0x2e0
arch/x86/kernel/process.c:304
                    [<ffffffff811bf37a>] arch_cpu_idle+0xa/0x10
arch/x86/kernel/process.c:295
                    [<ffffffff81439f48>] default_idle_call+0x48/0xa0
kernel/sched/idle.c:92
                    [<     inline     >] cpuidle_idle_call
kernel/sched/idle.c:156
                    [<     inline     >] cpu_idle_loop kernel/sched/idle.c:252
                    [<ffffffff8143a604>] cpu_startup_entry+0x554/0x710
kernel/sched/idle.c:300
                    [<ffffffff86301262>] rest_init+0x192/0x1a0 init/main.c:412
                    [<ffffffff882fa780>] start_kernel+0x678/0x69e
init/main.c:683
                    [<ffffffff882f9342>]
x86_64_start_reservations+0x2a/0x2c arch/x86/kernel/head64.c:195
                    [<ffffffff882f949c>]
x86_64_start_kernel+0x158/0x167 arch/x86/kernel/head64.c:184
   INITIAL USE at:
                   [<ffffffff81454226>] __lock_acquire+0xae6/0x4700
kernel/locking/lockdep.c:3166
                   [<ffffffff8145a28c>] lock_acquire+0x1dc/0x430
kernel/locking/lockdep.c:3585
                   [<     inline     >] __raw_spin_lock_bh
include/linux/spinlock_api_smp.h:137
                   [<ffffffff86324a1a>] _raw_spin_lock_bh+0x3a/0x50
kernel/locking/spinlock.c:175
                   [<     inline     >] spin_lock_bh
include/linux/spinlock.h:307
                   [<ffffffff851c2cb8>] lock_sock_nested+0x48/0x120
net/core/sock.c:2412
                   [<     inline     >] lock_sock include/net/sock.h:1368
                   [<ffffffff85553642>]
do_tcp_setsockopt.isra.34+0x142/0x1920 net/ipv4/tcp.c:2361
                   [<ffffffff85554ed3>] tcp_setsockopt+0xb3/0xd0
net/ipv4/tcp.c:2618
                   [<ffffffff851c0b77>]
sock_common_setsockopt+0x97/0xd0 net/core/sock.c:2620
                   [<ffffffff85deaf18>] rds_tcp_nonagle+0x138/0x1c0
net/rds/tcp.c:65
                   [<ffffffff85decce8>]
rds_tcp_listen_init+0x118/0x3b0 net/rds/tcp_listen.c:183
                   [<ffffffff85deabcc>] rds_tcp_init_net+0x12c/0x340
net/rds/tcp.c:300
                   [<ffffffff851fb819>] ops_init+0xa9/0x3a0
net/core/net_namespace.c:109
                   [<     inline     >] __register_pernet_operations
net/core/net_namespace.c:781
                   [<ffffffff851fc148>]
register_pernet_operations+0x258/0x4b0 net/core/net_namespace.c:846
                   [<ffffffff851fc3ca>]
register_pernet_subsys+0x2a/0x40 net/core/net_namespace.c:888
                   [<ffffffff85dea79e>] rds_tcp_init+0x5e/0xf0 net/rds/tcp.c:418
                   [<ffffffff81002259>] do_one_initcall+0x159/0x380
init/main.c:794
                   [<     inline     >] do_initcall_level init/main.c:859
                   [<     inline     >] do_initcalls init/main.c:867
                   [<     inline     >] do_basic_setup init/main.c:885
                   [<ffffffff882fac1a>]
kernel_init_freeable+0x474/0x52d init/main.c:1010
                   [<ffffffff86301283>] kernel_init+0x13/0x150 init/main.c:936
                   [<ffffffff86325d6f>] ret_from_fork+0x3f/0x70
arch/x86/entry/entry_64.S:468
 }
 ... key      at: [<ffffffff8964c8d0>] af_family_slock_keys+0x10/0x180 ??:?
 ... acquired at:
   [<ffffffff81451092>] check_irq_usage+0x72/0x170 kernel/locking/lockdep.c:1649
   [<     inline     >] check_prev_add_irq kernel/locking/lockdep_states.h:8
   [<     inline     >] check_prev_add kernel/locking/lockdep.c:1857
   [<     inline     >] check_prevs_add kernel/locking/lockdep.c:1958
   [<     inline     >] validate_chain kernel/locking/lockdep.c:2144
   [<ffffffff8145667f>] __lock_acquire+0x2f3f/0x4700
kernel/locking/lockdep.c:3206
   [<ffffffff8145a28c>] lock_acquire+0x1dc/0x430 kernel/locking/lockdep.c:3585
   [<     inline     >] __raw_spin_lock_irqsave
include/linux/spinlock_api_smp.h:112
   [<ffffffff8632536f>] _raw_spin_lock_irqsave+0x9f/0xd0
kernel/locking/spinlock.c:159
   [<ffffffff817847d4>] free_transhuge_page+0x24/0x90 mm/huge_memory.c:3436
   [<ffffffff81681f3e>] __put_compound_page+0x7e/0xa0 mm/swap.c:91
   [<ffffffff81684a39>] __put_page+0x39/0xa0 mm/swap.c:97
   [<     inline     >] put_page include/linux/mm.h:706
   [<     inline     >] __skb_frag_unref include/linux/skbuff.h:2505
   [<ffffffff851d885a>] skb_release_data+0x1fa/0x420 net/core/skbuff.c:583
   [<ffffffff851d8aca>] skb_release_all+0x4a/0x60 net/core/skbuff.c:659
   [<ffffffff851d8af5>] __kfree_skb+0x15/0x20 net/core/skbuff.c:673
   [<ffffffff851d8be9>] kfree_skb+0xe9/0x2d0 net/core/skbuff.c:694
   [<ffffffff8552564d>] __ip_flush_pending_frames.isra.46+0x12d/0x2e0
net/ipv4/ip_output.c:1473
   [<ffffffff85530110>] ip_flush_pending_frames+0x20/0x30
net/ipv4/ip_output.c:1480
   [<     inline     >] udp_flush_pending_frames net/ipv4/udp.c:782
   [<ffffffff855dc8d5>] udp_destroy_sock+0x165/0x190 net/ipv4/udp.c:2115
   [<ffffffff851ce0bb>] sk_common_release+0x6b/0x400 net/core/sock.c:2641
   [<ffffffff855da005>] udp_lib_close+0x15/0x20 include/net/udp.h:190
   [<ffffffff85609b0f>] inet_release+0xef/0x1c0 net/ipv4/af_inet.c:416
   [<ffffffff851b6f1f>] sock_release+0x8f/0x1d0 net/socket.c:572
   [<ffffffff851b7076>] sock_close+0x16/0x20 net/socket.c:1023
   [<ffffffff817b36e6>] __fput+0x236/0x780 fs/file_table.c:208
   [<ffffffff817b3cb5>] ____fput+0x15/0x20 fs/file_table.c:244
   [<ffffffff813af2b0>] task_work_run+0x170/0x210 kernel/task_work.c:115
   [<     inline     >] exit_task_work include/linux/task_work.h:21
   [<ffffffff8135b275>] do_exit+0x8b5/0x2c60 kernel/exit.c:750
   [<ffffffff8135d798>] do_group_exit+0x108/0x330 kernel/exit.c:880
   [<ffffffff813806e4>] get_signal+0x5e4/0x14f0 kernel/signal.c:2307
   [<ffffffff811a2db3>] do_signal+0x83/0x1c90 arch/x86/kernel/signal.c:712
   [<ffffffff81006685>] exit_to_usermode_loop+0x1a5/0x210
arch/x86/entry/common.c:247
   [<     inline     >] prepare_exit_to_usermode arch/x86/entry/common.c:282
   [<ffffffff810084ea>] syscall_return_slowpath+0x2ba/0x340
arch/x86/entry/common.c:344
   [<ffffffff86325b22>] int_ret_from_sys_call+0x25/0x9f
arch/x86/entry/entry_64.S:281


the dependencies between the lock to be acquired and SOFTIRQ-irq-unsafe lock:
-> (split_queue_lock){+.+...} ops: 1384883 {
   HARDIRQ-ON-W at:
                    [<     inline     >] mark_irqflags
kernel/locking/lockdep.c:2813
                    [<ffffffff81454b47>] __lock_acquire+0x1407/0x4700
kernel/locking/lockdep.c:3162
                    [<ffffffff8145a28c>] lock_acquire+0x1dc/0x430
kernel/locking/lockdep.c:3585
                    [<     inline     >] __raw_spin_lock
include/linux/spinlock_api_smp.h:144
                    [<ffffffff863248d3>] _raw_spin_lock+0x33/0x50
kernel/locking/spinlock.c:151
                    [<     inline     >] spin_lock include/linux/spinlock.h:302
                    [<ffffffff81782320>]
split_huge_page_to_list+0xcc0/0x1c50 mm/huge_memory.c:3399
                    [<     inline     >] split_huge_page
include/linux/huge_mm.h:99
                    [<ffffffff8174a4e8>]
queue_pages_pte_range+0xa38/0xef0 mm/mempolicy.c:507
                    [<     inline     >] walk_pmd_range mm/pagewalk.c:50
                    [<     inline     >] walk_pud_range mm/pagewalk.c:90
                    [<     inline     >] walk_pgd_range mm/pagewalk.c:116
                    [<ffffffff8171d4f3>] __walk_page_range+0x653/0xcd0
mm/pagewalk.c:204
                    [<ffffffff8171dc6e>] walk_page_range+0xfe/0x2b0
mm/pagewalk.c:281
                    [<ffffffff81746e7b>] queue_pages_range+0xfb/0x130
mm/mempolicy.c:687
                    [<     inline     >] migrate_to_node mm/mempolicy.c:1004
                    [<ffffffff8174c340>] do_migrate_pages+0x370/0x4e0
mm/mempolicy.c:1109
                    [<     inline     >] SYSC_migrate_pages mm/mempolicy.c:1453
                    [<ffffffff8174cc10>] SyS_migrate_pages+0x640/0x730
mm/mempolicy.c:1374
                    [<ffffffff863259b6>]
entry_SYSCALL_64_fastpath+0x16/0x7a arch/x86/entry/entry_64.S:185
   SOFTIRQ-ON-W at:
                    [<     inline     >] mark_irqflags
kernel/locking/lockdep.c:2817
                    [<ffffffff81454bae>] __lock_acquire+0x146e/0x4700
kernel/locking/lockdep.c:3162
                    [<ffffffff8145a28c>] lock_acquire+0x1dc/0x430
kernel/locking/lockdep.c:3585
                    [<     inline     >] __raw_spin_lock
include/linux/spinlock_api_smp.h:144
                    [<ffffffff863248d3>] _raw_spin_lock+0x33/0x50
kernel/locking/spinlock.c:151
                    [<     inline     >] spin_lock include/linux/spinlock.h:302
                    [<ffffffff81782320>]
split_huge_page_to_list+0xcc0/0x1c50 mm/huge_memory.c:3399
                    [<     inline     >] split_huge_page
include/linux/huge_mm.h:99
                    [<ffffffff8174a4e8>]
queue_pages_pte_range+0xa38/0xef0 mm/mempolicy.c:507
                    [<     inline     >] walk_pmd_range mm/pagewalk.c:50
                    [<     inline     >] walk_pud_range mm/pagewalk.c:90
                    [<     inline     >] walk_pgd_range mm/pagewalk.c:116
                    [<ffffffff8171d4f3>] __walk_page_range+0x653/0xcd0
mm/pagewalk.c:204
                    [<ffffffff8171dc6e>] walk_page_range+0xfe/0x2b0
mm/pagewalk.c:281
                    [<ffffffff81746e7b>] queue_pages_range+0xfb/0x130
mm/mempolicy.c:687
                    [<     inline     >] migrate_to_node mm/mempolicy.c:1004
                    [<ffffffff8174c340>] do_migrate_pages+0x370/0x4e0
mm/mempolicy.c:1109
                    [<     inline     >] SYSC_migrate_pages mm/mempolicy.c:1453
                    [<ffffffff8174cc10>] SyS_migrate_pages+0x640/0x730
mm/mempolicy.c:1374
                    [<ffffffff863259b6>]
entry_SYSCALL_64_fastpath+0x16/0x7a arch/x86/entry/entry_64.S:185
   INITIAL USE at:
                   [<ffffffff81454226>] __lock_acquire+0xae6/0x4700
kernel/locking/lockdep.c:3166
                   [<ffffffff8145a28c>] lock_acquire+0x1dc/0x430
kernel/locking/lockdep.c:3585
                   [<     inline     >] __raw_spin_lock_irqsave
include/linux/spinlock_api_smp.h:112
                   [<ffffffff8632536f>]
_raw_spin_lock_irqsave+0x9f/0xd0 kernel/locking/spinlock.c:159
                   [<ffffffff817847d4>] free_transhuge_page+0x24/0x90
mm/huge_memory.c:3436
                   [<ffffffff81681f3e>] __put_compound_page+0x7e/0xa0
mm/swap.c:91
                   [<ffffffff81684a39>] __put_page+0x39/0xa0 mm/swap.c:97
                   [<     inline     >] put_page include/linux/mm.h:706
                   [<ffffffff8176df5d>]
migrate_misplaced_transhuge_page+0xfad/0x19c0 mm/migrate.c:1767
                   [<ffffffff8177ab5f>]
do_huge_pmd_numa_page+0x6ef/0xd40 mm/huge_memory.c:1521
                   [<     inline     >] __handle_mm_fault mm/memory.c:3382
                   [<ffffffff816ea096>] handle_mm_fault+0x1336/0x4640
mm/memory.c:3446
                   [<ffffffff8127eff6>] __do_page_fault+0x376/0x960
arch/x86/mm/fault.c:1238
                   [<ffffffff8127f738>] trace_do_page_fault+0xe8/0x420
arch/x86/mm/fault.c:1331
                   [<ffffffff812705c4>] do_async_page_fault+0x14/0xd0
arch/x86/kernel/kvm.c:264
                   [<ffffffff86327cf8>] async_page_fault+0x28/0x30
arch/x86/entry/entry_64.S:986
 }
 ... key      at: [<ffffffff87731398>] split_queue_lock+0x18/0x60 ??:?
 ... acquired at:
   [<ffffffff81451092>] check_irq_usage+0x72/0x170 kernel/locking/lockdep.c:1649
   [<     inline     >] check_prev_add_irq kernel/locking/lockdep_states.h:8
   [<     inline     >] check_prev_add kernel/locking/lockdep.c:1857
   [<     inline     >] check_prevs_add kernel/locking/lockdep.c:1958
   [<     inline     >] validate_chain kernel/locking/lockdep.c:2144
   [<ffffffff8145667f>] __lock_acquire+0x2f3f/0x4700
kernel/locking/lockdep.c:3206
   [<ffffffff8145a28c>] lock_acquire+0x1dc/0x430 kernel/locking/lockdep.c:3585
   [<     inline     >] __raw_spin_lock_irqsave
include/linux/spinlock_api_smp.h:112
   [<ffffffff8632536f>] _raw_spin_lock_irqsave+0x9f/0xd0
kernel/locking/spinlock.c:159
   [<ffffffff817847d4>] free_transhuge_page+0x24/0x90 mm/huge_memory.c:3436
   [<ffffffff81681f3e>] __put_compound_page+0x7e/0xa0 mm/swap.c:91
   [<ffffffff81684a39>] __put_page+0x39/0xa0 mm/swap.c:97
   [<     inline     >] put_page include/linux/mm.h:706
   [<     inline     >] __skb_frag_unref include/linux/skbuff.h:2505
   [<ffffffff851d885a>] skb_release_data+0x1fa/0x420 net/core/skbuff.c:583
   [<ffffffff851d8aca>] skb_release_all+0x4a/0x60 net/core/skbuff.c:659
   [<ffffffff851d8af5>] __kfree_skb+0x15/0x20 net/core/skbuff.c:673
   [<ffffffff851d8be9>] kfree_skb+0xe9/0x2d0 net/core/skbuff.c:694
   [<ffffffff8552564d>] __ip_flush_pending_frames.isra.46+0x12d/0x2e0
net/ipv4/ip_output.c:1473
   [<ffffffff85530110>] ip_flush_pending_frames+0x20/0x30
net/ipv4/ip_output.c:1480
   [<     inline     >] udp_flush_pending_frames net/ipv4/udp.c:782
   [<ffffffff855dc8d5>] udp_destroy_sock+0x165/0x190 net/ipv4/udp.c:2115
   [<ffffffff851ce0bb>] sk_common_release+0x6b/0x400 net/core/sock.c:2641
   [<ffffffff855da005>] udp_lib_close+0x15/0x20 include/net/udp.h:190
   [<ffffffff85609b0f>] inet_release+0xef/0x1c0 net/ipv4/af_inet.c:416
   [<ffffffff851b6f1f>] sock_release+0x8f/0x1d0 net/socket.c:572
   [<ffffffff851b7076>] sock_close+0x16/0x20 net/socket.c:1023
   [<ffffffff817b36e6>] __fput+0x236/0x780 fs/file_table.c:208
   [<ffffffff817b3cb5>] ____fput+0x15/0x20 fs/file_table.c:244
   [<ffffffff813af2b0>] task_work_run+0x170/0x210 kernel/task_work.c:115
   [<     inline     >] exit_task_work include/linux/task_work.h:21
   [<ffffffff8135b275>] do_exit+0x8b5/0x2c60 kernel/exit.c:750
   [<ffffffff8135d798>] do_group_exit+0x108/0x330 kernel/exit.c:880
   [<ffffffff813806e4>] get_signal+0x5e4/0x14f0 kernel/signal.c:2307
   [<ffffffff811a2db3>] do_signal+0x83/0x1c90 arch/x86/kernel/signal.c:712
   [<ffffffff81006685>] exit_to_usermode_loop+0x1a5/0x210
arch/x86/entry/common.c:247
   [<     inline     >] prepare_exit_to_usermode arch/x86/entry/common.c:282
   [<ffffffff810084ea>] syscall_return_slowpath+0x2ba/0x340
arch/x86/entry/common.c:344
   [<ffffffff86325b22>] int_ret_from_sys_call+0x25/0x9f
arch/x86/entry/entry_64.S:281


stack backtrace:
CPU: 0 PID: 18183 Comm: syz-executor Tainted: G        W       4.4.0+ #259
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
 00000000ffffffff ffff880042a2f2c8 ffffffff8298accd 1ffff10008545e6a
 ffffffff88f91ad0 ffffffff88fb8110 ffff880042a2f4e0 ffffffff81450ee3
 0000000000000002 0000000000000000 0000000000000000 ffffffff81446d50
Call Trace:
 [<     inline     >] __dump_stack lib/dump_stack.c:15
 [<ffffffff8298accd>] dump_stack+0x6f/0xa2 lib/dump_stack.c:50
 [<     inline     >] print_bad_irq_dependency kernel/locking/lockdep.c:1561
 [<ffffffff81450ee3>] check_usage+0x913/0xa50 kernel/locking/lockdep.c:1593
 [<ffffffff81451092>] check_irq_usage+0x72/0x170 kernel/locking/lockdep.c:1649
 [<     inline     >] check_prev_add_irq kernel/locking/lockdep_states.h:8
 [<     inline     >] check_prev_add kernel/locking/lockdep.c:1857
 [<     inline     >] check_prevs_add kernel/locking/lockdep.c:1958
 [<     inline     >] validate_chain kernel/locking/lockdep.c:2144
 [<ffffffff8145667f>] __lock_acquire+0x2f3f/0x4700 kernel/locking/lockdep.c:3206
 [<ffffffff8145a28c>] lock_acquire+0x1dc/0x430 kernel/locking/lockdep.c:3585
 [<     inline     >] __raw_spin_lock_irqsave
include/linux/spinlock_api_smp.h:112
 [<ffffffff8632536f>] _raw_spin_lock_irqsave+0x9f/0xd0
kernel/locking/spinlock.c:159
 [<ffffffff817847d4>] free_transhuge_page+0x24/0x90 mm/huge_memory.c:3436
 [<ffffffff81681f3e>] __put_compound_page+0x7e/0xa0 mm/swap.c:91
 [<ffffffff81684a39>] __put_page+0x39/0xa0 mm/swap.c:97
 [<     inline     >] put_page include/linux/mm.h:706
 [<     inline     >] __skb_frag_unref include/linux/skbuff.h:2505
 [<ffffffff851d885a>] skb_release_data+0x1fa/0x420 net/core/skbuff.c:583
 [<ffffffff851d8aca>] skb_release_all+0x4a/0x60 net/core/skbuff.c:659
 [<ffffffff851d8af5>] __kfree_skb+0x15/0x20 net/core/skbuff.c:673
 [<ffffffff851d8be9>] kfree_skb+0xe9/0x2d0 net/core/skbuff.c:694
 [<ffffffff8552564d>] __ip_flush_pending_frames.isra.46+0x12d/0x2e0
net/ipv4/ip_output.c:1473
 [<ffffffff85530110>] ip_flush_pending_frames+0x20/0x30
net/ipv4/ip_output.c:1480
 [<     inline     >] udp_flush_pending_frames net/ipv4/udp.c:782
 [<ffffffff855dc8d5>] udp_destroy_sock+0x165/0x190 net/ipv4/udp.c:2115
 [<ffffffff851ce0bb>] sk_common_release+0x6b/0x400 net/core/sock.c:2641
 [<ffffffff855da005>] udp_lib_close+0x15/0x20 include/net/udp.h:190
 [<ffffffff85609b0f>] inet_release+0xef/0x1c0 net/ipv4/af_inet.c:416
 [<ffffffff851b6f1f>] sock_release+0x8f/0x1d0 net/socket.c:572
 [<ffffffff851b7076>] sock_close+0x16/0x20 net/socket.c:1023
 [<ffffffff817b36e6>] __fput+0x236/0x780 fs/file_table.c:208
 [<ffffffff817b3cb5>] ____fput+0x15/0x20 fs/file_table.c:244
 [<ffffffff813af2b0>] task_work_run+0x170/0x210 kernel/task_work.c:115
 [<     inline     >] exit_task_work include/linux/task_work.h:21
 [<ffffffff8135b275>] do_exit+0x8b5/0x2c60 kernel/exit.c:750
 [<ffffffff8135d798>] do_group_exit+0x108/0x330 kernel/exit.c:880
 [<ffffffff813806e4>] get_signal+0x5e4/0x14f0 kernel/signal.c:2307
 [<ffffffff811a2db3>] do_signal+0x83/0x1c90 arch/x86/kernel/signal.c:712
 [<ffffffff81006685>] exit_to_usermode_loop+0x1a5/0x210
arch/x86/entry/common.c:247
 [<     inline     >] prepare_exit_to_usermode arch/x86/entry/common.c:282
 [<ffffffff810084ea>] syscall_return_slowpath+0x2ba/0x340
arch/x86/entry/common.c:344
 [<ffffffff86325b22>] int_ret_from_sys_call+0x25/0x9f
arch/x86/entry/entry_64.S:281


On commit 5807fcaa9bf7dd87241df739161c119cf78a6bc4.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
