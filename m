Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9149C6B02F4
	for <linux-mm@kvack.org>; Tue,  8 Aug 2017 07:05:36 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id b83so29529549pfl.6
        for <linux-mm@kvack.org>; Tue, 08 Aug 2017 04:05:36 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [103.22.144.67])
        by mx.google.com with ESMTPS id x33si737316plb.838.2017.08.08.04.05.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 08 Aug 2017 04:05:35 -0700 (PDT)
From: Michael Ellerman <mpe@ellerman.id.au>
Subject: ksmd circular locking warning, cpu_hotplug_lock vs ksm_thread_mutex
Date: Tue, 08 Aug 2017 21:05:27 +1000
Message-ID: <87tw1imia0.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, aarcange@redhat.com, hughd@google.com, kirill.shutemov@linux.intel.com, zhongjiang@huawei.com, minchan@kernel.org, mingo@kernel.org, aneesh.kumar@linux.vnet.ibm.com, imbrenda@linux.vnet.ibm.com, linux-kernel@vger.kernel.org, tglx@linutronix.detglx@linutronix.de, linuxppc-dev@lists.ozlabs.orglinuxppc-dev@lists.ozlabs.org

Hi all,

Apologies for the large Cc list, but wasn't really sure who to send this to.

I've seen this once on a Power8 box, with next-20170807.

I think it happened while I was running the memory hoptlug selftests.

cheers

  [ 3532.474435] ======================================================
  [ 3532.474440] WARNING: possible circular locking dependency detected
  [ 3532.474446] 4.13.0-rc3-gcc6-next-20170807-g4751f76 #1 Not tainted
  [ 3532.474450] ------------------------------------------------------
  [ 3532.474454] ksmd/1459 is trying to acquire lock:
  [ 3532.474460]  (cpu_hotplug_lock.rw_sem){++++++}, at: [<c0000000002b06b0>] lru_add_drain_all+0x20/0x40
  [ 3532.474476] 
                 but task is already holding lock:
  [ 3532.474480]  (ksm_thread_mutex){+.+...}, at: [<c000000000330778>] ksm_scan_thread+0xd8/0x1a30
  [ 3532.474493] 
                 which lock already depends on the new lock.
  
  [ 3532.474499] 
                 the existing dependency chain (in reverse order) is:
  [ 3532.474504] 
                 -> #3 (ksm_thread_mutex){+.+...}:
  [ 3532.474517]        __mutex_lock+0x8c/0xa80
  [ 3532.474522]        ksm_memory_callback+0xa4/0x390
  [ 3532.474529]        notifier_call_chain+0xa4/0x110
  [ 3532.474533]        __blocking_notifier_call_chain+0x74/0xb0
  [ 3532.474540]        memory_notify+0x30/0x50
  [ 3532.474544]        __offline_pages.constprop.6+0x1c0/0xa50
  [ 3532.474549]        memory_subsys_offline+0x68/0xf0
  [ 3532.474555]        device_offline+0x104/0x140
  [ 3532.474560]        store_mem_state+0x178/0x190
  [ 3532.474566]        dev_attr_store+0x3c/0x60
  [ 3532.474572]        sysfs_kf_write+0x9c/0xc0
  [ 3532.474576]        kernfs_fop_write+0x190/0x260
  [ 3532.474582]        __vfs_write+0x44/0x1a0
  [ 3532.474586]        vfs_write+0xd4/0x240
  [ 3532.474591]        SyS_write+0x68/0x110
  [ 3532.474597]        system_call+0x58/0x6c
  [ 3532.474600] 
                 -> #2 ((memory_chain).rwsem){++++..}:
  [ 3532.474609]        down_read+0x44/0xa0
  [ 3532.474613]        __blocking_notifier_call_chain+0x58/0xb0
  [ 3532.474618]        memory_notify+0x30/0x50
  [ 3532.474622]        __offline_pages.constprop.6+0x1c0/0xa50
  [ 3532.474627]        memory_subsys_offline+0x68/0xf0
  [ 3532.474631]        device_offline+0x104/0x140
  [ 3532.474636]        store_mem_state+0x178/0x190
  [ 3532.474641]        dev_attr_store+0x3c/0x60
  [ 3532.474645]        sysfs_kf_write+0x9c/0xc0
  [ 3532.474649]        kernfs_fop_write+0x190/0x260
  [ 3532.474654]        __vfs_write+0x44/0x1a0
  [ 3532.474659]        vfs_write+0xd4/0x240
  [ 3532.474663]        SyS_write+0x68/0x110
  [ 3532.474668]        system_call+0x58/0x6c
  [ 3532.474671] 
                 -> #1 (mem_hotplug_lock.rw_sem){++++++}:
  [ 3532.474680]        get_online_mems+0x4c/0xd0
  [ 3532.474685]        kmem_cache_create+0x6c/0x2a0
  [ 3532.474691]        ptlock_cache_init+0x38/0x54
  [ 3532.474696]        start_kernel+0x2ac/0x558
  [ 3532.474700]        start_here_common+0x1c/0x4ac
  [ 3532.474704] 
                 -> #0 (cpu_hotplug_lock.rw_sem){++++++}:
  [ 3532.474713]        lock_acquire+0xec/0x2e0
  [ 3532.474718]        cpus_read_lock+0x4c/0xd0
  [ 3532.474723]        lru_add_drain_all+0x20/0x40
  [ 3532.474728]        ksm_scan_thread+0xba4/0x1a30
  [ 3532.474734]        kthread+0x164/0x1b0
  [ 3532.474739]        ret_from_kernel_thread+0x5c/0x74
  [ 3532.474742] 
                 other info that might help us debug this:
  
  [ 3532.474748] Chain exists of:
                   cpu_hotplug_lock.rw_sem --> (memory_chain).rwsem --> ksm_thread_mutex
  
  [ 3532.474760]  Possible unsafe locking scenario:
  
  [ 3532.474764]        CPU0                    CPU1
  [ 3532.474768]        ----                    ----
  [ 3532.474771]   lock(ksm_thread_mutex);
  [ 3532.474775]                                lock((memory_chain).rwsem);
  [ 3532.474781]                                lock(ksm_thread_mutex);
  [ 3532.474786]   lock(cpu_hotplug_lock.rw_sem);
  [ 3532.474791] 
                  *** DEADLOCK ***
  
  [ 3532.474797] 1 lock held by ksmd/1459:
  [ 3532.474800]  #0:  (ksm_thread_mutex){+.+...}, at: [<c000000000330778>] ksm_scan_thread+0xd8/0x1a30
  [ 3532.474810] 
                 stack backtrace:
  [ 3532.474816] CPU: 0 PID: 1459 Comm: ksmd Not tainted 4.13.0-rc3-gcc6-next-20170807-g4751f76 #1
  [ 3532.474822] Call Trace:
  [ 3532.474827] [c000001e54d13930] [c000000000b57c38] dump_stack+0xe8/0x160 (unreliable)
  [ 3532.474835] [c000001e54d13970] [c000000000157968] print_circular_bug+0x288/0x3d0
  [ 3532.474842] [c000001e54d13a10] [c00000000015b9c8] __lock_acquire+0x1858/0x1a20
  [ 3532.474849] [c000001e54d13b80] [c00000000015c6fc] lock_acquire+0xec/0x2e0
  [ 3532.474855] [c000001e54d13c50] [c0000000000d85cc] cpus_read_lock+0x4c/0xd0
  [ 3532.474862] [c000001e54d13c80] [c0000000002b06b0] lru_add_drain_all+0x20/0x40
  [ 3532.474869] [c000001e54d13ca0] [c000000000331244] ksm_scan_thread+0xba4/0x1a30
  [ 3532.474876] [c000001e54d13dc0] [c00000000010b614] kthread+0x164/0x1b0
  [ 3532.474883] [c000001e54d13e30] [c00000000000b6e8] ret_from_kernel_thread+0x5c/0x74


cheers

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
