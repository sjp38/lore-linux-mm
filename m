Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2BE156B0292
	for <linux-mm@kvack.org>; Wed, 28 Jun 2017 11:37:45 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id u18so56821397pfa.8
        for <linux-mm@kvack.org>; Wed, 28 Jun 2017 08:37:45 -0700 (PDT)
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-ve1eur01on0116.outbound.protection.outlook.com. [104.47.1.116])
        by mx.google.com with ESMTPS id m27si1819690pgn.176.2017.06.28.08.37.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 28 Jun 2017 08:37:44 -0700 (PDT)
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Subject: cpu_hotplug_lock.rw_sem + memhotplug = possible deadlock
Message-ID: <d765d5d1-018a-5819-afa4-a43fcf8ae4f1@virtuozzo.com>
Date: Wed, 28 Jun 2017 18:39:41 +0300
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On linux -next, after onlining hotpluged memory:

======================================================
WARNING: possible circular locking dependency detected
4.12.0-rc6-next-20170626+ #761 Not tainted
------------------------------------------------------
kworker/u8:0/5 is trying to acquire lock:
 (cpu_hotplug_lock.rw_sem){++++++}, at: [<ffffffff812df34c>] stop_machine+0x1c/0x40

but task is already holding lock:
 (zonelists_mutex){+.+.+.}, at: [<ffffffff836e3e7d>] online_pages+0x3bd/0x720

which lock already depends on the new lock.


the existing dependency chain (in reverse order) is:

-> #2 (zonelists_mutex){+.+.+.}:
       __lock_acquire+0x1d1a/0x3120
       lock_acquire+0x10d/0x310
       __mutex_lock+0xcd/0x12d0
       mutex_lock_nested+0x1b/0x20
       online_pages+0x3bd/0x720
       memory_subsys_online+0x32b/0x4f0
       device_online+0xfa/0x170
       online_memory_block+0x12/0x20
       walk_memory_range+0xe9/0x190
       add_memory_resource+0x2c6/0x350
       add_memory+0x12c/0x1d0
       acpi_memory_device_add+0x339/0x9e0
       acpi_bus_attach+0x325/0x810
       acpi_bus_scan+0x7e/0xd0
       acpi_device_hotplug+0x2d9/0x910
       acpi_hotplug_work_fn+0x5e/0x90
       process_one_work+0x68c/0x16b0
       worker_thread+0xde/0x11c0
       kthread+0x2d6/0x3d0
       ret_from_fork+0x27/0x40

-> #1 (mem_hotplug.lock#2){+.+.+.}:
       __lock_acquire+0x1d1a/0x3120
       lock_acquire+0x10d/0x310
       __mutex_lock+0xcd/0x12d0
       mutex_lock_nested+0x1b/0x20
       get_online_mems+0x4c/0x70
       kmem_cache_create+0x30/0x290
       ptlock_cache_init+0x24/0x2d
       start_kernel+0x267/0x5ec
       x86_64_start_reservations+0x2f/0x31
       x86_64_start_kernel+0x143/0x152
       verify_cpu+0x0/0xf1

-> #0 (cpu_hotplug_lock.rw_sem){++++++}:
       check_prevs_add+0x1c0/0x1b30
       __lock_acquire+0x1d1a/0x3120
       lock_acquire+0x10d/0x310
       cpus_read_lock+0x2a/0x60
       stop_machine+0x1c/0x40
       build_all_zonelists+0x80/0x1c1
       online_pages+0x6c2/0x720
       memory_subsys_online+0x32b/0x4f0
       device_online+0xfa/0x170
       online_memory_block+0x12/0x20
       walk_memory_range+0xe9/0x190
       add_memory_resource+0x2c6/0x350
       add_memory+0x12c/0x1d0
       acpi_memory_device_add+0x339/0x9e0
       acpi_bus_attach+0x325/0x810
       acpi_bus_scan+0x7e/0xd0
       acpi_device_hotplug+0x2d9/0x910
       acpi_hotplug_work_fn+0x5e/0x90
       process_one_work+0x68c/0x16b0
       worker_thread+0xde/0x11c0
       kthread+0x2d6/0x3d0
       ret_from_fork+0x27/0x40

other info that might help us debug this:

Chain exists of:
  cpu_hotplug_lock.rw_sem --> mem_hotplug.lock#2 --> zonelists_mutex

 Possible unsafe locking scenario:

       CPU0                    CPU1
       ----                    ----
  lock(zonelists_mutex);
                               lock(mem_hotplug.lock#2);
                               lock(zonelists_mutex);
  lock(cpu_hotplug_lock.rw_sem);

 *** DEADLOCK ***

9 locks held by kworker/u8:0/5:
 #0:  ("kacpi_hotplug"){.+.+.+}, at: [<ffffffff81142c97>] process_one_work+0x5b7/0x16b0
 #1:  ((&hpw->work)){+.+.+.}, at: [<ffffffff81142cc4>] process_one_work+0x5e4/0x16b0
 #2:  (device_hotplug_lock){+.+.+.}, at: [<ffffffff82555427>] lock_device_hotplug+0x17/0x20
 #3:  (acpi_scan_lock){+.+.+.}, at: [<ffffffff822544cb>] acpi_device_hotplug+0x7b/0x910
 #4:  (memory_add_remove_lock){+.+.+.}, at: [<ffffffff81583ab1>] mem_hotplug_begin+0x31/0xc0
 #5:  (mem_hotplug.lock){++++++}, at: [<ffffffff81583a85>] mem_hotplug_begin+0x5/0xc0
 #6:  (mem_hotplug.lock#2){+.+.+.}, at: [<ffffffff81583af2>] mem_hotplug_begin+0x72/0xc0
 #7:  (&dev->mutex){......}, at: [<ffffffff82559611>] device_online+0x21/0x170
 #8:  (zonelists_mutex){+.+.+.}, at: [<ffffffff836e3e7d>] online_pages+0x3bd/0x720

stack backtrace:
CPU: 2 PID: 5 Comm: kworker/u8:0 Not tainted 4.12.0-rc6-next-20170626+ #761
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS rel-1.10.2-0-g5f4c7b1-prebuilt.qemu-project.org 04/01/2014
Workqueue: kacpi_hotplug acpi_hotplug_work_fn
Call Trace:
 dump_stack+0x67/0x99
 print_circular_bug+0x33c/0x650
 check_prevs_add+0x1c0/0x1b30
 __lock_acquire+0x1d1a/0x3120
 lock_acquire+0x10d/0x310
 cpus_read_lock+0x2a/0x60
 stop_machine+0x1c/0x40
 build_all_zonelists+0x80/0x1c1
 online_pages+0x6c2/0x720
 memory_subsys_online+0x32b/0x4f0
 device_online+0xfa/0x170
 online_memory_block+0x12/0x20
 walk_memory_range+0xe9/0x190
 add_memory_resource+0x2c6/0x350
 add_memory+0x12c/0x1d0
 acpi_memory_device_add+0x339/0x9e0
 acpi_bus_attach+0x325/0x810
 acpi_bus_scan+0x7e/0xd0
 acpi_device_hotplug+0x2d9/0x910
 acpi_hotplug_work_fn+0x5e/0x90
 process_one_work+0x68c/0x16b0
 worker_thread+0xde/0x11c0
 kthread+0x2d6/0x3d0
 ret_from_fork+0x27/0x40


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
