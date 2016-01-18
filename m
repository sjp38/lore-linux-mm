Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 699B26B0005
	for <linux-mm@kvack.org>; Mon, 18 Jan 2016 08:38:56 -0500 (EST)
Received: by mail-wm0-f49.google.com with SMTP id u188so104429626wmu.1
        for <linux-mm@kvack.org>; Mon, 18 Jan 2016 05:38:56 -0800 (PST)
Received: from mail-wm0-x22b.google.com (mail-wm0-x22b.google.com. [2a00:1450:400c:c09::22b])
        by mx.google.com with ESMTPS id b1si25393713wmi.42.2016.01.18.05.38.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Jan 2016 05:38:55 -0800 (PST)
Received: by mail-wm0-x22b.google.com with SMTP id 123so52793467wmz.0
        for <linux-mm@kvack.org>; Mon, 18 Jan 2016 05:38:55 -0800 (PST)
Date: Mon, 18 Jan 2016 15:38:52 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: mm: SOFTIRQ-safe -> SOFTIRQ-unsafe lock order detected in
 split_huge_page_to_list
Message-ID: <20160118133852.GC14531@node.shutemov.name>
References: <CACT4Y+ayDrEmn31qyoVdnq6vpSbL=XzFWPM5_Ee4GH=Waf27eA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACT4Y+ayDrEmn31qyoVdnq6vpSbL=XzFWPM5_Ee4GH=Waf27eA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Sasha Levin <sasha.levin@oracle.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, jmarchan@redhat.com, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Ebru Akagunduz <ebru.akagunduz@gmail.com>, Dan Williams <dan.j.williams@intel.com>, Minchan Kim <minchan@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, syzkaller <syzkaller@googlegroups.com>, Kostya Serebryany <kcc@google.com>, Alexander Potapenko <glider@google.com>

On Mon, Jan 18, 2016 at 02:08:15PM +0100, Dmitry Vyukov wrote:
> Hello,
> 
> While running syzkaller fuzzer I've hit the following report.
> 
> Looks like cause by the recent commit
> e9b61f19858a5d6c42ce2298cf138279375d0d9b "thp: reintroduce
> split_huge_page()".
> 
> ======================================================
> [ INFO: SOFTIRQ-safe -> SOFTIRQ-unsafe lock order detected ]
> 4.4.0+ #259 Tainted: G        W
> ------------------------------------------------------
> syz-executor/18183 [HC0[0]:SC0[2]:HE0:SE0] is trying to acquire:
>  (split_queue_lock){+.+...}, at: [<ffffffff817847d4>]
> free_transhuge_page+0x24/0x90 mm/huge_memory.c:3436
> 
> and this task is already holding:
>  (slock-AF_INET){+.-...}, at: [<     inline     >] spin_lock_bh
> include/linux/spinlock.h:307
>  (slock-AF_INET){+.-...}, at: [<ffffffff851c4fe5>]
> lock_sock_fast+0x45/0x120 net/core/sock.c:2462
> which would create a new lock dependency:
>  (slock-AF_INET){+.-...} -> (split_queue_lock){+.+...}
> 
> but this new dependency connects a SOFTIRQ-irq-safe lock:
>  (slock-AF_INET){+.-...}
> ... which became SOFTIRQ-irq-safe at:
>   [<     inline     >] mark_irqflags kernel/locking/lockdep.c:2799
>   [<ffffffff81454718>] __lock_acquire+0xfd8/0x4700 kernel/locking/lockdep.c:3162
>   [<ffffffff8145a28c>] lock_acquire+0x1dc/0x430 kernel/locking/lockdep.c:3585
>   [<     inline     >] __raw_spin_lock include/linux/spinlock_api_smp.h:144
>   [<ffffffff863248d3>] _raw_spin_lock+0x33/0x50 kernel/locking/spinlock.c:151
>   [<     inline     >] spin_lock include/linux/spinlock.h:302
>   [<ffffffff855e3df1>] udp_queue_rcv_skb+0x781/0x1550 net/ipv4/udp.c:1680
>   [<ffffffff855e4c10>] flush_stack+0x50/0x330 net/ipv6/udp.c:799
>   [<ffffffff855e5584>] __udp4_lib_mcast_deliver+0x694/0x7f0 net/ipv4/udp.c:1798
>   [<ffffffff855e6ebc>] __udp4_lib_rcv+0x17dc/0x23e0 net/ipv4/udp.c:1888
>   [<ffffffff855e9021>] udp_rcv+0x21/0x30 net/ipv4/udp.c:2108
>   [<ffffffff85513b33>] ip_local_deliver_finish+0x2b3/0xa50
> net/ipv4/ip_input.c:216
>   [<     inline     >] NF_HOOK_THRESH include/linux/netfilter.h:226
>   [<     inline     >] NF_HOOK include/linux/netfilter.h:249
>   [<ffffffff855149d4>] ip_local_deliver+0x1c4/0x2f0 net/ipv4/ip_input.c:257
>   [<     inline     >] dst_input include/net/dst.h:498
>   [<ffffffff8551273c>] ip_rcv_finish+0x5ec/0x1730 net/ipv4/ip_input.c:365
>   [<     inline     >] NF_HOOK_THRESH include/linux/netfilter.h:226
>   [<     inline     >] NF_HOOK include/linux/netfilter.h:249
>   [<ffffffff85515463>] ip_rcv+0x963/0x1080 net/ipv4/ip_input.c:455
>   [<ffffffff8521b410>] __netif_receive_skb_core+0x1620/0x2f80
> net/core/dev.c:4154
>   [<ffffffff8521cd9a>] __netif_receive_skb+0x2a/0x160 net/core/dev.c:4189
>   [<ffffffff85220795>] netif_receive_skb_internal+0x1b5/0x390
> net/core/dev.c:4217
>   [<     inline     >] napi_skb_finish net/core/dev.c:4542
>   [<ffffffff85224c9d>] napi_gro_receive+0x2bd/0x3c0 net/core/dev.c:4572
>   [<ffffffff83a2f142>] e1000_clean_rx_irq+0x4e2/0x1100
> drivers/net/ethernet/intel/e1000e/netdev.c:1038
>   [<ffffffff83a2c1f8>] e1000_clean+0xa08/0x24a0
> drivers/net/ethernet/intel/e1000/e1000_main.c:3819
>   [<     inline     >] napi_poll net/core/dev.c:5074
>   [<ffffffff8522285b>] net_rx_action+0x7eb/0xdf0 net/core/dev.c:5139
>   [<ffffffff81361c0a>] __do_softirq+0x26a/0x920 kernel/softirq.c:273
>   [<     inline     >] invoke_softirq kernel/softirq.c:350
>   [<ffffffff8136264f>] irq_exit+0x18f/0x1d0 kernel/softirq.c:391
>   [<     inline     >] exiting_irq ./arch/x86/include/asm/apic.h:659
>   [<ffffffff811a9a66>] do_IRQ+0x86/0x1a0 arch/x86/kernel/irq.c:252
>   [<ffffffff863264cc>] ret_from_intr+0x0/0x20 arch/x86/entry/entry_64.S:520
>   [<     inline     >] arch_safe_halt ./arch/x86/include/asm/paravirt.h:117
>   [<ffffffff811bdd42>] default_idle+0x52/0x2e0 arch/x86/kernel/process.c:304
>   [<ffffffff811bf37a>] arch_cpu_idle+0xa/0x10 arch/x86/kernel/process.c:295
>   [<ffffffff81439f48>] default_idle_call+0x48/0xa0 kernel/sched/idle.c:92
>   [<     inline     >] cpuidle_idle_call kernel/sched/idle.c:156
>   [<     inline     >] cpu_idle_loop kernel/sched/idle.c:252
>   [<ffffffff8143a604>] cpu_startup_entry+0x554/0x710 kernel/sched/idle.c:300
>   [<ffffffff86301262>] rest_init+0x192/0x1a0 init/main.c:412
>   [<ffffffff882fa780>] start_kernel+0x678/0x69e init/main.c:683
>   [<ffffffff882f9342>] x86_64_start_reservations+0x2a/0x2c
> arch/x86/kernel/head64.c:195
>   [<ffffffff882f949c>] x86_64_start_kernel+0x158/0x167
> arch/x86/kernel/head64.c:184
> 
> to a SOFTIRQ-irq-unsafe lock:
>  (split_queue_lock){+.+...}
> ... which became SOFTIRQ-irq-unsafe at:
> ...  [<     inline     >] mark_irqflags kernel/locking/lockdep.c:2817
> ...  [<ffffffff81454bae>] __lock_acquire+0x146e/0x4700
> kernel/locking/lockdep.c:3162
>   [<ffffffff8145a28c>] lock_acquire+0x1dc/0x430 kernel/locking/lockdep.c:3585
>   [<     inline     >] __raw_spin_lock include/linux/spinlock_api_smp.h:144
>   [<ffffffff863248d3>] _raw_spin_lock+0x33/0x50 kernel/locking/spinlock.c:151
>   [<     inline     >] spin_lock include/linux/spinlock.h:302
>   [<ffffffff81782320>] split_huge_page_to_list+0xcc0/0x1c50
> mm/huge_memory.c:3399
>   [<     inline     >] split_huge_page include/linux/huge_mm.h:99
>   [<ffffffff8174a4e8>] queue_pages_pte_range+0xa38/0xef0 mm/mempolicy.c:507
>   [<     inline     >] walk_pmd_range mm/pagewalk.c:50
>   [<     inline     >] walk_pud_range mm/pagewalk.c:90
>   [<     inline     >] walk_pgd_range mm/pagewalk.c:116
>   [<ffffffff8171d4f3>] __walk_page_range+0x653/0xcd0 mm/pagewalk.c:204
>   [<ffffffff8171dc6e>] walk_page_range+0xfe/0x2b0 mm/pagewalk.c:281
>   [<ffffffff81746e7b>] queue_pages_range+0xfb/0x130 mm/mempolicy.c:687
>   [<     inline     >] migrate_to_node mm/mempolicy.c:1004
>   [<ffffffff8174c340>] do_migrate_pages+0x370/0x4e0 mm/mempolicy.c:1109
>   [<     inline     >] SYSC_migrate_pages mm/mempolicy.c:1453
>   [<ffffffff8174cc10>] SyS_migrate_pages+0x640/0x730 mm/mempolicy.c:1374
>   [<ffffffff863259b6>] entry_SYSCALL_64_fastpath+0x16/0x7a
> arch/x86/entry/entry_64.S:185
> 
> other info that might help us debug this:
> 
>  Possible interrupt unsafe locking scenario:
> 
>        CPU0                    CPU1
>        ----                    ----
>   lock(split_queue_lock);
>                                local_irq_disable();
>                                lock(slock-AF_INET);
>                                lock(split_queue_lock);
>   <Interrupt>
>     lock(slock-AF_INET);

Thanks for report.

I think this should fix the issue:
