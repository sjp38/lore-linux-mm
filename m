Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3F6E36B3E49
	for <linux-mm@kvack.org>; Sun, 25 Nov 2018 19:33:50 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id p4so6707707pgj.21
        for <linux-mm@kvack.org>; Sun, 25 Nov 2018 16:33:50 -0800 (PST)
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id f10si34714255pgo.356.2018.11.25.16.33.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 25 Nov 2018 16:33:45 -0800 (PST)
Date: Mon, 26 Nov 2018 08:33:53 +0800
From: kernel test robot <rong.a.chen@intel.com>
Subject: [LKP] d17a1d97dc [ 56.099059] watchdog: BUG: soft lockup - CPU#0
 stuck for 23s! [swapper:1]
Message-ID: <20181126003353.GJ18977@shao2-debian>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="yywL3DpgDyP4yZ2G"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Pavel Tatashin <pasha.tatashin@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, LKP <lkp@01.org>


--yywL3DpgDyP4yZ2G
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline

Greetings,

0day kernel testing robot got the below dmesg and the first bad commit is

https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master

commit d17a1d97dc208d664c91cc387ffb752c7f85dc61
Author:     Andrey Ryabinin <aryabinin@virtuozzo.com>
AuthorDate: Wed Nov 15 17:36:35 2017 -0800
Commit:     Linus Torvalds <torvalds@linux-foundation.org>
CommitDate: Wed Nov 15 18:21:05 2017 -0800

    x86/mm/kasan: don't use vmemmap_populate() to initialize shadow
    
    The kasan shadow is currently mapped using vmemmap_populate() since that
    provides a semi-convenient way to map pages into init_top_pgt.  However,
    since that no longer zeroes the mapped pages, it is not suitable for
    kasan, which requires zeroed shadow memory.
    
    Add kasan_populate_shadow() interface and use it instead of
    vmemmap_populate().  Besides, this allows us to take advantage of
    gigantic pages and use them to populate the shadow, which should save us
    some memory wasted on page tables and reduce TLB pressure.
    
    Link: http://lkml.kernel.org/r/20171103185147.2688-2-pasha.tatashin@oracle.com
    Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
    Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
    Cc: Steven Sistare <steven.sistare@oracle.com>
    Cc: Daniel Jordan <daniel.m.jordan@oracle.com>
    Cc: Bob Picco <bob.picco@oracle.com>
    Cc: Michal Hocko <mhocko@suse.com>
    Cc: Alexander Potapenko <glider@google.com>
    Cc: Ard Biesheuvel <ard.biesheuvel@linaro.org>
    Cc: Catalin Marinas <catalin.marinas@arm.com>
    Cc: Christian Borntraeger <borntraeger@de.ibm.com>
    Cc: David S. Miller <davem@davemloft.net>
    Cc: Dmitry Vyukov <dvyukov@google.com>
    Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
    Cc: "H. Peter Anvin" <hpa@zytor.com>
    Cc: Ingo Molnar <mingo@redhat.com>
    Cc: Mark Rutland <mark.rutland@arm.com>
    Cc: Matthew Wilcox <willy@infradead.org>
    Cc: Mel Gorman <mgorman@techsingularity.net>
    Cc: Michal Hocko <mhocko@kernel.org>
    Cc: Sam Ravnborg <sam@ravnborg.org>
    Cc: Thomas Gleixner <tglx@linutronix.de>
    Cc: Will Deacon <will.deacon@arm.com>
    Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
    Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>

a4a3ede213  mm: zero reserved and unavailable struct pages
d17a1d97dc  x86/mm/kasan: don't use vmemmap_populate() to initialize shadow
7c98a42618  Merge tag 'ceph-for-4.20-rc4' of https://github.com/ceph/ceph-client
8c9733fd98  Add linux-next specific files for 20181123
+--------------------------------------------------+------------+------------+------------+---------------+
|                                                  | a4a3ede213 | d17a1d97dc | 7c98a42618 | next-20181123 |
+--------------------------------------------------+------------+------------+------------+---------------+
| boot_successes                                   | 187        | 0          | 0          | 0             |
| boot_failures                                    | 1          | 66         | 66         | 52            |
| INFO:task_blocked_for_more_than#seconds          | 1          |            |            |               |
| Kernel_panic-not_syncing:hung_task:blocked_tasks | 1          |            |            |               |
| BUG:soft_lockup-CPU##stuck_for#s                 | 0          | 66         | 66         | 52            |
| RIP:unwind_next_frame                            | 0          | 18         | 13         | 12            |
| Kernel_panic-not_syncing:softlockup:hung_tasks   | 0          | 66         | 66         | 52            |
| RIP:__asan_load8                                 | 0          | 13         | 5          | 4             |
| RIP:acpi_ps_push_scope                           | 0          | 1          |            |               |
| RIP:memcmp                                       | 0          | 2          |            |               |
| RIP:__asan_load4                                 | 0          | 8          | 16         | 5             |
| RIP:__asan_load1                                 | 0          | 6          | 1          |               |
| RIP:unwind_get_return_address                    | 0          | 3          | 2          | 1             |
| RIP:check_memory_region                          | 0          | 1          | 7          | 5             |
| RIP:__asan_store8                                | 0          | 2          | 1          | 3             |
| RIP:deref_stack_reg                              | 0          | 4          | 2          | 3             |
| RIP:__orc_find                                   | 0          | 4          | 7          | 5             |
| RIP:__memset                                     | 0          | 1          |            |               |
| RIP:__asan_loadN                                 | 0          | 1          | 0          | 4             |
| RIP:__kernel_text_address                        | 0          | 1          | 0          | 1             |
| RIP:stack_access_ok                              | 0          | 1          | 1          | 1             |
| RIP:depot_save_stack                             | 0          | 0          | 2          | 4             |
| RIP:__unwind_start                               | 0          | 0          | 2          | 1             |
| RIP:kmem_cache_free                              | 0          | 0          | 1          |               |
| RIP:acpi_os_release_object                       | 0          | 0          | 1          |               |
| RIP:__read_once_size_nocheck                     | 0          | 0          | 1          |               |
| RIP:stackleak_track_stack                        | 0          | 0          | 2          |               |
| RIP:save_stack_address                           | 0          | 0          | 1          |               |
| RIP:acpi_ut_update_object_reference              | 0          | 0          | 1          |               |
| RIP:__save_stack_trace                           | 0          | 0          | 0          | 1             |
| RIP:__kmalloc                                    | 0          | 0          | 0          | 1             |
| RIP:kasan_kmalloc                                | 0          | 0          | 0          | 1             |
+--------------------------------------------------+------------+------------+------------+---------------+

[   30.066434] parport0: AVR Butterfly
[   30.078258] parport0: cannot grant exclusive access for device spi-lm70llp
[   30.092323] spi_lm70llp: spi_lm70llp probe fail, status -12
[   30.107585] e1000: Intel(R) PRO/1000 Network Driver - version 7.3.21-k8-NAPI
[   30.121880] e1000: Copyright (c) 1999-2006 Intel Corporation.
[   56.099059] watchdog: BUG: soft lockup - CPU#0 stuck for 23s! [swapper:1]
[   56.099059] CPU: 0 PID: 1 Comm: swapper Not tainted 4.14.0-04089-gd17a1d9 #1
[   56.099059] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.2-1 04/01/2014
[   56.099059] task: ffff88001a511ac0 task.stack: ffff88001a518000
[   56.099059] RIP: 0010:__asan_load8+0x0/0x80
[   56.099059] RSP: 0000:ffff88001a51ee30 EFLAGS: 00000246 ORIG_RAX: ffffffffffffff11
[   56.099059] RAX: 0000000000000000 RBX: ffff88001a51ef10 RCX: ffffffff8103dec8
[   56.099059] RDX: 0000000000000003 RSI: dffffc0000000000 RDI: ffff88001a51ef48
[   56.099059] RBP: 1ffff100034a3dcf R08: fffffbfff0a02350 R09: fffffbfff0a0234f
[   56.099059] R10: ffffffff85011a7d R11: fffffbfff0a02350 R12: ffff88001a51ff40
[   56.099059] R13: ffffffff85011a7a R14: ffffffff85011a7e R15: 0000000000000001
[   56.099059] FS:  0000000000000000(0000) GS:ffffffff83e6e000(0000) knlGS:0000000000000000
[   56.099059] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   56.099059] CR2: 0000000000000000 CR3: 0000000003e42001 CR4: 00000000000206b0
[   56.099059] Call Trace:
[   56.099059]  unwind_next_frame+0x93b/0x9c0
[   56.099059]  ? kernel_init_freeable+0x1f2/0x32d
[   56.099059]  ? unwind_get_return_address_ptr+0x50/0x50
[   56.099059]  ? memcmp+0x4c/0x70
[   56.099059]  ? depot_save_stack+0x15f/0x530
[   56.099059]  __save_stack_trace+0x91/0xd0
[   56.099059]  ? kernel_init+0xa/0x100
[   56.099059]  kasan_slab_free+0xc2/0x170
[   56.099059]  ? kmem_cache_free+0x10e/0x180
[   56.099059]  ? acpi_os_release_object+0x5/0x10
[   56.099059]  ? acpi_ut_update_object_reference+0x299/0x30f
[   56.099059]  ? acpi_ds_clear_operands+0x59/0xa6
[   56.099059]  ? acpi_ds_exec_end_op+0x344/0xa3a
[   56.099059]  ? acpi_ps_parse_loop+0xe65/0xf6a
[   56.099059]  ? acpi_ps_parse_aml+0x21c/0x665
[   56.099059]  ? acpi_ps_execute_method+0x316/0x407
[   56.099059]  ? acpi_ns_evaluate+0x4de/0x6cd
[   56.099059]  ? acpi_ut_evaluate_object+0xe5/0x2f2
[   56.099059]  ? acpi_rs_get_prt_method_data+0x86/0x106
[   56.099059]  ? acpi_get_irq_routing_table+0xad/0xf3
[   56.099059]  ? acpi_pci_irq_find_prt_entry+0xf5/0x5c0
[   56.099059]  ? acpi_pci_irq_lookup+0x6e/0x4a0
[   56.099059]  ? acpi_pci_irq_enable+0x17c/0x380
[   56.099059]  ? do_pci_enable_device+0xbb/0x160
[   56.099059]  ? pci_enable_device_flags+0x157/0x190
[   56.099059]  ? e1000_probe+0x18b0/0x1b30
[   56.099059]  ? pci_device_probe+0xef/0x190
[   56.099059]  ? driver_probe_device+0x1e2/0x400
[   56.099059]  ? __driver_attach+0x92/0xc0
[   56.099059]  ? bus_for_each_dev+0xbf/0x120
[   56.099059]  ? bus_add_driver+0x16b/0x2f0
[   56.099059]  ? driver_register+0xed/0x150
[   56.099059]  ? e1000_init_module+0x60/0xd9
[   56.099059]  ? do_one_initcall+0x130/0x2c5
[   56.099059]  ? kernel_init_freeable+0x1f2/0x32d
[   56.099059]  ? kernel_init+0xa/0x100
[   56.099059]  ? ret_from_fork+0x1f/0x30
[   56.099059]  ? do_raw_spin_unlock+0xda/0xf0
[   56.099059]  ? debug_check_no_obj_freed+0x26e/0x3f0
[   56.099059]  ? debug_object_active_state+0x220/0x220
[   56.099059]  ? acpi_ut_track_stack_ptr+0x87/0xb5
[   56.099059]  ? acpi_ut_init_stack_ptr_trace+0x71/0x71
[   56.099059]  ? do_raw_spin_unlock+0xda/0xf0
[   56.099059]  ? acpi_os_release_object+0x5/0x10
[   56.099059]  kmem_cache_free+0x10e/0x180
[   56.099059]  acpi_os_release_object+0x5/0x10
[   56.099059]  acpi_ut_update_object_reference+0x299/0x30f
[   56.099059]  ? acpi_ut_update_ref_count+0x9cc/0x9cc
[   56.099059]  ? acpi_ex_opcode_2A_2T_1R+0x1c9/0x1c9
[   56.099059]  acpi_ds_clear_operands+0x59/0xa6
[   56.099059]  acpi_ds_exec_end_op+0x344/0xa3a
[   56.099059]  ? acpi_ds_exec_begin_op+0x391/0x391
[   56.099059]  acpi_ps_parse_loop+0xe65/0xf6a
[   56.099059]  ? acpi_ut_init_stack_ptr_trace+0x71/0x71
[   56.099059]  ? acpi_ps_get_next_arg+0x90d/0x90d
[   56.099059]  ? acpi_ut_init_stack_ptr_trace+0x71/0x71
[   56.099059]  ? acpi_ut_create_generic_state+0x42/0x5e
[   56.099059]  ? kmem_cache_alloc+0x11c/0x140
[   56.099059]  ? acpi_ut_trace+0x33/0x79
[   56.099059]  acpi_ps_parse_aml+0x21c/0x665
[   56.099059]  acpi_ps_execute_method+0x316/0x407
[   56.099059]  acpi_ns_evaluate+0x4de/0x6cd
[   56.099059]  ? kmem_cache_alloc+0x11c/0x140
[   56.099059]  acpi_ut_evaluate_object+0xe5/0x2f2
[   56.099059]  acpi_rs_get_prt_method_data+0x86/0x106
[   56.099059]  ? acpi_rs_set_resource_source+0x79/0x79
[   56.099059]  ? acpi_ut_status_exit+0x94/0xb1
[   56.099059]  ? acpi_rs_validate_parameters+0x11e/0x127
[   56.099059]  acpi_get_irq_routing_table+0xad/0xf3
[   56.099059]  ? acpi_rs_match_vendor_resource+0xf8/0xf8
[   56.099059]  ? stack_access_ok+0x4a/0xb0
[   56.099059]  acpi_pci_irq_find_prt_entry+0xf5/0x5c0
[   56.099059]  ? deref_stack_reg+0x7a/0xb0
[   56.099059]  ? __orc_find+0x55/0xa0
[   56.099059]  ? acpi_penalize_sci_irq+0x30/0x30
[   56.099059]  acpi_pci_irq_lookup+0x6e/0x4a0
[   56.099059]  ? acpi_pci_irq_find_prt_entry+0x5c0/0x5c0
[   56.099059]  ? pci_conf1_read+0xff/0x110
[   56.099059]  acpi_pci_irq_enable+0x17c/0x380
[   56.099059]  ? acpi_pci_irq_lookup+0x4a0/0x4a0
[   56.099059]  ? pci_enable_resources+0xa2/0x1c0
[   56.099059]  ? pci_reassign_resource+0x140/0x140
[   56.099059]  ? pci_platform_power_transition+0xa0/0xa0
[   56.099059]  ? is_acpi_device_node+0x1e/0x30
[   56.099059]  do_pci_enable_device+0xbb/0x160
[   56.099059]  ? pci_set_power_state+0x190/0x190
[   56.099059]  ? bus_for_each_dev+0xbf/0x120
[   56.099059]  ? bus_add_driver+0x16b/0x2f0
[   56.099059]  ? driver_register+0xed/0x150
[   56.099059]  ? e1000_init_module+0x60/0xd9
[   56.099059]  ? do_one_initcall+0x130/0x2c5
[   56.099059]  ? kernel_init_freeable+0x1f2/0x32d
[   56.099059]  ? kernel_init+0xa/0x100
[   56.099059]  ? ret_from_fork+0x1f/0x30
[   56.099059]  ? idr_get_free_cmn+0x318/0x3b0
[   56.099059]  ? delete_node+0x57/0x350
[   56.099059]  pci_enable_device_flags+0x157/0x190
[   56.099059]  ? pci_reenable_device+0x30/0x30
[   56.099059]  ? idr_alloc_cmn+0xf7/0x130
[   56.099059]  ? __fprop_inc_percpu_max+0x110/0x110
[   56.099059]  ? ret_from_fork+0x1f/0x30
[   56.099059]  e1000_probe+0x18b0/0x1b30
[   56.099059]  ? idr_alloc_cyclic+0xa9/0x140
[   56.099059]  ? idr_alloc_cyclic+0x103/0x140
[   56.099059]  ? idr_alloc_cmn+0x130/0x130
[   56.099059]  ? rpm_resume+0x1a3/0x940
[   56.099059]  ? e1000_io_slot_reset+0xc0/0xc0
[   56.099059]  ? __pm_runtime_idle+0x80/0x80
[   56.099059]  ? pci_match_id+0x136/0x160
[   56.099059]  ? pci_match_device+0x209/0x230
[   56.099059]  ? do_raw_spin_unlock+0xda/0xf0
[   56.099059]  pci_device_probe+0xef/0x190
[   56.099059]  driver_probe_device+0x1e2/0x400
[   56.099059]  ? driver_probe_device+0x400/0x400
[   56.099059]  __driver_attach+0x92/0xc0
[   56.099059]  bus_for_each_dev+0xbf/0x120
[   56.099059]  ? bus_remove_file+0x70/0x70
[   56.099059]  ? bus_add_driver+0x291/0x2f0
[   56.099059]  ? do_raw_spin_lock+0xb3/0xd0
[   56.099059]  bus_add_driver+0x16b/0x2f0
[   56.099059]  ? net_olddevs_init+0x109/0x109
[   56.099059]  driver_register+0xed/0x150
[   56.099059]  e1000_init_module+0x60/0xd9
[   56.099059]  do_one_initcall+0x130/0x2c5
[   56.099059]  ? start_kernel+0x8a0/0x8a0
[   56.099059]  ? strcpy+0x1e/0x50
[   56.099059]  ? __asan_load1+0x50/0x50
[   56.099059]  kernel_init_freeable+0x1f2/0x32d
[   56.099059]  ? rest_init+0xb0/0xb0
[   56.099059]  kernel_init+0xa/0x100
[   56.099059]  ? rest_init+0xb0/0xb0
[   56.099059]  ret_from_fork+0x1f/0x30
[   56.099059] Code: ff df 0f b6 04 30 84 c0 74 18 38 d0 0f 9e c0 84 c0 74 0f ba 01 00 00 00 be 04 00 00 00 e9 f9 07 00 00 f3 c3 0f 1f 80 00 00 00 00 <48> b8 ff ff ff ff ff 7f ff ff 48 8b 0c 24 48 39 c7 76 5a 48 8d 
[   56.099059] Kernel panic - not syncing: softlockup: hung tasks
[   56.099059] CPU: 0 PID: 1 Comm: swapper Tainted: G             L  4.14.0-04089-gd17a1d9 #1
[   56.099059] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.2-1 04/01/2014
[   56.099059] Call Trace:
[   56.099059]  <IRQ>
[   56.099059]  panic+0x13a/0x288
[   56.099059]  ? refcount_error_report+0xe8/0xe8
[   56.099059]  watchdog_timer_fn+0x1a7/0x1e0
[   56.099059]  ? watchdog_should_run+0x20/0x20
[   56.099059]  hrtimer_run_queues+0x13e/0x210
[   56.099059]  run_local_timers+0x5/0x50
[   56.099059]  update_process_times+0x1b/0x50
[   56.099059]  tick_nohz_handler+0xb3/0x110
[   56.099059]  smp_apic_timer_interrupt+0x72/0x90
[   56.099059]  apic_timer_interrupt+0x89/0x90
[   56.099059]  </IRQ>
[   56.099059] RIP: 0010:__asan_load8+0x0/0x80
[   56.099059] RSP: 0000:ffff88001a51ee30 EFLAGS: 00000246 ORIG_RAX: ffffffffffffff11
[   56.099059] RAX: 0000000000000000 RBX: ffff88001a51ef10 RCX: ffffffff8103dec8
[   56.099059] RDX: 0000000000000003 RSI: dffffc0000000000 RDI: ffff88001a51ef48
[   56.099059] RBP: 1ffff100034a3dcf R08: fffffbfff0a02350 R09: fffffbfff0a0234f
[   56.099059] R10: ffffffff85011a7d R11: fffffbfff0a02350 R12: ffff88001a51ff40
[   56.099059] R13: ffffffff85011a7a R14: ffffffff85011a7e R15: 0000000000000001
[   56.099059]  ? unwind_next_frame+0x978/0x9c0
[   56.099059]  unwind_next_frame+0x93b/0x9c0
[   56.099059]  ? kernel_init_freeable+0x1f2/0x32d
[   56.099059]  ? unwind_get_return_address_ptr+0x50/0x50
[   56.099059]  ? memcmp+0x4c/0x70
[   56.099059]  ? depot_save_stack+0x15f/0x530
[   56.099059]  __save_stack_trace+0x91/0xd0
[   56.099059]  ? kernel_init+0xa/0x100
[   56.099059]  kasan_slab_free+0xc2/0x170
[   56.099059]  ? kmem_cache_free+0x10e/0x180
[   56.099059]  ? acpi_os_release_object+0x5/0x10
[   56.099059]  ? acpi_ut_update_object_reference+0x299/0x30f
[   56.099059]  ? acpi_ds_clear_operands+0x59/0xa6
[   56.099059]  ? acpi_ds_exec_end_op+0x344/0xa3a
[   56.099059]  ? acpi_ps_parse_loop+0xe65/0xf6a
[   56.099059]  ? acpi_ps_parse_aml+0x21c/0x665
[   56.099059]  ? acpi_ps_execute_method+0x316/0x407
[   56.099059]  ? acpi_ns_evaluate+0x4de/0x6cd
[   56.099059]  ? acpi_ut_evaluate_object+0xe5/0x2f2
[   56.099059]  ? acpi_rs_get_prt_method_data+0x86/0x106
[   56.099059]  ? acpi_get_irq_routing_table+0xad/0xf3
[   56.099059]  ? acpi_pci_irq_find_prt_entry+0xf5/0x5c0
[   56.099059]  ? acpi_pci_irq_lookup+0x6e/0x4a0
[   56.099059]  ? acpi_pci_irq_enable+0x17c/0x380
[   56.099059]  ? do_pci_enable_device+0xbb/0x160

                                                          # HH:MM RESULT GOOD BAD GOOD_BUT_DIRTY DIRTY_NOT_BAD
git bisect start v4.15 v4.14 --
git bisect  bad e017b4db26d03c1a6531f814ecc5ab41bcb889e9  # 17:09  B      2     1    2   2  Merge branch 'sched-urgent-for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/tip/tip
git bisect  bad e0bcb42e602816415f6fe07313b6fc84932244b7  # 17:27  B      9     3    9  10  Merge tag 'ecryptfs-4.15-rc1-fixes' of git://git.kernel.org/pub/scm/linux/kernel/git/tyhicks/ecryptfs
git bisect good 23c258763ba992f6a95a4b8980ffa7c1890bc8d8  # 17:47  G     54     0    1   1  Merge tag 'dmaengine-4.15-rc1' of git://git.infradead.org/users/vkoul/slave-dma
git bisect  bad 93ea0eb7d77afab34657715630d692a78b8cea6a  # 18:01  B     23     3   23  23  Merge tag 'leaks-4.15-rc1' of git://github.com/tcharding/linux
git bisect good 373c4557d2aa362702c4c2d41288fb1e54990b7c  # 18:27  G     62     0    0   0  mm/pagewalk.c: report holes in hugetlb ranges
git bisect good 1bc03573e1c9024d4e4be97df4a1e0931edbae2c  # 18:53  G     61     0    4   4  Merge branch 'for-4.15' of git://git.kernel.org/pub/scm/linux/kernel/git/tj/libata
git bisect good ad0835a93008e5901415a0a27847d6a27649aa3a  # 19:12  G     63     0    1   1  Merge tag 'for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/dledford/rdma
git bisect good 6363b3f3ac5be096d08c8c504128befa0c033529  # 19:36  G     66     0    0   0  Merge tag 'ipmi-for-4.15' of git://github.com/cminyard/linux-ipmi
git bisect  bad 7c225c69f86c934e3be9be63ecde754e286838d7  # 19:50  B      6     1    6   6  Merge branch 'akpm' (patches from Andrew)
git bisect good 4be90299a1693c2112edb20ca78d6cc9f2183326  # 20:10  G     61     0    0   0  ceph: use pagevec_lookup_range_nr_tag()
git bisect  bad 76253fbc8fbf6018401755fc5c07814a837cc832  # 20:25  B     17     4   17  17  mm: move accounting updates before page_cache_tree_delete()
git bisect good 353b1e7b5859e98860f984d8894fa7ddc242a90e  # 20:48  G     62     0    0   0  x86/mm: set fields in deferred pages
git bisect  bad 78c943662f4b1d53ddbfc515e427827915781377  # 21:01  B     14     2   14  14  sparc64: optimize struct page zeroing
git bisect good a4a3ede2132ae0863e2d43e06f9b5697c51a7a3b  # 21:21  G     66     0    1   1  mm: zero reserved and unavailable struct pages
git bisect  bad e17d8025f07e4fd9d73b137a8bcab04548126b83  # 21:37  B     24     2   24  24  arm64/mm/kasan: don't use vmemmap_populate() to initialize shadow
git bisect  bad d17a1d97dc208d664c91cc387ffb752c7f85dc61  # 21:54  B     13     3   13  13  x86/mm/kasan: don't use vmemmap_populate() to initialize shadow
# first bad commit: [d17a1d97dc208d664c91cc387ffb752c7f85dc61] x86/mm/kasan: don't use vmemmap_populate() to initialize shadow
git bisect good a4a3ede2132ae0863e2d43e06f9b5697c51a7a3b  # 22:07  G    181     0    3   4  mm: zero reserved and unavailable struct pages
# extra tests with debug options
git bisect  bad d17a1d97dc208d664c91cc387ffb752c7f85dc61  # 22:26  B     21     2   21  21  x86/mm/kasan: don't use vmemmap_populate() to initialize shadow
# extra tests on HEAD of linux-devel/devel-hourly-2018112413
git bisect  bad 853af81642fe696cb188e1f04c9373cc7c027f38  # 22:32  B      0     4   29   8  0day head guard for 'devel-hourly-2018112413'
# extra tests on tree/branch linus/master
git bisect  bad 7c98a42618271210c60b79128b220107d35938d9  # 22:51  B      5     1    5   5  Merge tag 'ceph-for-4.20-rc4' of https://github.com/ceph/ceph-client
# extra tests on tree/branch linux-next/master
git bisect  bad 8c9733fd9806c71e7f2313a280f98cb3051f93df  # 23:05  B      1     1    1   2  Add linux-next specific files for 20181123

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/lkp                          Intel Corporation

--yywL3DpgDyP4yZ2G
Content-Type: application/gzip
Content-Disposition: attachment; filename="dmesg-yocto-lkp-kboot02-19:20181124215445:x86_64-randconfig-r0-11241445:4.14.0-04089-gd17a1d9:1.gz"
Content-Transfer-Encoding: base64

H4sICM5o+VsAA2RtZXNnLXlvY3RvLWxrcC1rYm9vdDAyLTE5OjIwMTgxMTI0MjE1NDQ1Ong4
Nl82NC1yYW5kY29uZmlnLXIwLTExMjQxNDQ1OjQuMTQuMC0wNDA4OS1nZDE3YTFkOToxAOxb
WXPjOJJ+r1+RMfOw8o4lA+CtCU2szypFlWy15eruXYdDQZGgzDFFqnn46F+/mSB1kZTLrvbj
OLqLV+aHRAJ5AZB00+gFvCTOkkhCGEMm82KJL3z5Sda/yec8db18+iDTWEafwnhZ5FPfzd0+
sGe2+tN1qQvLrD5HMt75ym19xiz7U1Lk+Hn3U3mpPjU4dd3lM93+VLY+zZPcjaZZ+KfcpfJ1
j0A+nUkvWSxTmWVhPIdvYVw893o9GLupenH+7YIe/SSWvU8nSZLTy/xeQgnf+3QL+Md6Jepd
CQCPErmTGPQe13usy3RmO925zy2X+w50HmZFGPn/Ez7OdO0AOnPPW3OYPWQAwbjFmTChcyZn
oVu97joHB/B3DhM3h8vkEYQOgvcN1tccOJ3cEJddl+c0WSzc2IcojFEBKXZgcOTLx6PUXTC4
L+L5NHezh+nSjUNvwMGXs2IO7hIfytvsJUv/mLrRk/uSTWXsziLpQ+oVSxxP2cObqbcsphnq
GFUdLiQOygAHCGKZ98IgdhcyGzBYpmGcP/Sw4YdFNh9gP8sGuxyyJMijxHsolmsh4kU4fXJz
795P5gP1EpJkmVW3UeL6UxTfD7OHgUBoHL58/YKBn8783iKMk3TqJUWcD2zqRC4Xfi9K5jhd
HmU0kGkK4Rxp5BRfqnerGTzI8xcGalKXYtOLCTvk3BDYsS2qzcvHuTtAsIUbQfpEun4YHHly
eR9kR+VYH6VF3P2jkIU8ekm8POlGD8vuwwyHg4mjZ9ucmno3xXFC9CCcd1PW5VzoXNeNo4hm
VNcnEfvq3+59UqBwXRpuRaX1q5ll+Z5gtm+auudwz9NsKwhmliE8K7AN3zN5fxZm0su7Jabm
HPUeF3T/Z/etCOtWBfZcc7oa7zc61OUOzLA33v1gS/ijPcLDydXVzXQ4Ov58PjhaPszLDv9A
KWgyXfPorUIfrXrZbo8tM4ZmuEyDXnZf5H7yFA9Y3bBQvqNgWfTxxoKL8Xd4CqMIikzCxe+T
41/P6/TSFqwPJ8OrSRen7GPoox0t71+y0MNJc308goW77NeZFHnJebuQi20HVv11d145wSwI
7lAKstN3gTmB1wQLCAxdo0wfpf8uuKApW/DzcLzeVR4Efgn33q4ip2yC/bRsgQxIcdtw9Oqn
4Uq0HbgfSqccdb90ZxSd1g4NYzSFq0aMIitdhetb5egQmKZo6d7r5Je/Q+f8WXpFLuEsVPo+
ILeboyfBkNUHjPXhY2MMyHKTRR8CN8sxKwhzFUTrVJMRaQNEzwYKwjLOG+KejYZ9+OV89B0m
OWK6qQ/jU+iEus4ufod/wHg4/P0QuOOYB4dKt8B7nPXQDQHTjxg/Ql+j10G/vKB9P4ZZkqL+
qCfS78PXX0ftZluGu/porUZpayLCYPCvvQNVYqVykTxuY7kbrOC1SV2yR6jO6TKIYYDcajaj
53ieuql3v36trySsQ4xurq+xv4FbRDnkqII+PKVhLrsz13toJQ7CZwr4bjyX2WqCNNwU3qs+
OBf49woiwLGiO1F0Rey53n1bTwFOFd3FFl414VqFfHTTUGn/x3LCzEUXzZhdaQiVlz3AxcX6
+TWpMD8q539jaAHEK9+0V77pr3wzXvlmvvLN2vuNotb4+KaPeSHF1CJ1yYThlnWtuz78dgLw
2ynA99Mu/g/l87h8/u0GoOHISJc4j5P0BTDlXywTSjMB09Nbmsh2qVTHUcTqApSIY+JqYOJf
B7v+inI8M8MXFr44hOpeWcT4883xybdGUN3isbd47DfyOFs8zht53C0e9zUejOlnw8nXtY/n
6Nqd0tLX4avOc3w6Rl93rgqqXM1o7156D1mxoAIhDDBZUOO1b3hL/uvJ2Xg3HF+YtsWUkXId
Oo84DidXp18mcLAX4GY7Zl5cnHNT2ApAYwTAKwA4+X18WpJXtOrN+mlPAxd4qTegWyWbpTca
KMnf08BZswdY85EKuK6dNho4+5keTBoNsFLHesPvljzH4+FpvddGNS52U60l+XuE+jI+b4yb
cVE2oNmNBkry9zTwLaFsVQnm+j4VzdhcIFVG1eg0JrRLjB2KOk8gWP8ZKsmBDlR/K4BGow+P
i65HxWEfsMoEtLtFlgLrkymhj+CHVFguXPQ+9FlRvgLxXRX0iJCBPjNM3cdOU2lcPTTk32It
FGuGxuhDEgSYWOEFhKNxjMkCaxjvxYtkVkdQ3BkWPB4G2i04ijm0GhHU/lQkL6HoM/d8XUgd
XcXsUH0K/UhOY/xm29xwmOFw3dYgbrT7f5hoVbGwJQaejY5LvbeUFJRp76TtVfLZiqKJNpRq
eaYtW2+iXJZFM4DEIv6lEdyTR+UE/6T+ZLmb5hBgwiYxQENMS081+tJxVgGJCColNNtVH/FV
a13VUAJzZLv4r8Dsr1nqMEPMjYm7XFJTkOwNYu3Fu4pXIGrta+nSNACuMUcX7bOB9NsHUwdF
S0WsrxSNMqARv8YjeMWzL+fdJtYcxy7JD+Hb8OIKc7Hcu+83DG81uUou7tjvEWzDJ0xH11va
03gjVFfCw6zIMQF0H90woonXh5XADd/gZi5WPl/VIuBx6QonLg4kpjepqnZCN8L7PRF6POre
hAukHF7BOEnV+qbJGot3P+F0iawPl9fT0/H3ydEyybIQO0KLdBlE4SJUjovjcLnkzHowThMP
EVGn/Ag9TrUo5jeKsEoUgp9ejobQcb1liA7plrwY1qBBpP7H/C/HV/yu4cuHV8R7yzDNpOVF
ZCV/vlr25NbhTudUFYzfP0+GwLpCaxdneHkznVyfTq9+vYbODHuI6X2RTcP0D7ybR8nMjdSD
WMnXlCpG3VMhRMJg+kqXPA3ndFWAeB1e/6KuagSGZ7C+vcTo2bCoH0pmbEtmwH04vwdVr/9Y
OF4Jp9WEM/YIZ7xbOGdbOOdDhHP2COe8Wzi+M6j49BHiuXvEc98vHt8Rj3+IeLM94s32iHf9
Cyvd5OwFErSuNPRlw5jfPOv5ntYbHvTNiNoexIaFvxlR34PYWPJZa8j4QA2Ze1pvlLdvRrT2
IFo/jWjvQdwTb5DH+bGG1rT8DRNuQ8w/UPfenn55P43o70FshPE3I8o9iI3c9c2IwR7EoI5Y
1jukeuiMjs9uDlTqNBmNwdtZ/AnjgLJwun+lrAx9SlJsZpuuwMKJltFUCSP91jykKv7KqF8v
/2aMyr9VlG84x6+/jqpk2M1eYg/GF0pyVQK2FWlZLt2INh93ykRN2lgjNRh21t1F+ZbSalq2
n6n1nHX6p1odnw7Bl4+h10wCV9vBSzd1H8M0L8qUr9oaBlRty4LyTk2YyiCMpd/9dxgEIWXp
9cqwVhGuXtfKQe5w5piOozMNS0LutJSES9RM142w8T5kDFIGviYs04aivKhPA/7f6uk1Zszg
MOY1VFGEUY55JaXeUZjlmHEvklkYhfkLzNOkWJKekrgHcEM1CayKEmHbVsP1l1k1ztL/bF3/
Z+v6P1vXH751rQyjX16gtI/VlkkjGI8xzNy72X21HC1jjElkuYLpNnSS1JcpPhwCNzUs02cv
ucwa/vyMuF6A9lVkK5hpGJq5RsMEyMBBsu09cENa3ejuRysd2goNEzRhCtT8HrSRWi1CLsPk
3Px6hFMD2b9uRYGOcBwhvq7cOp15wv4y09C+osnQuSZ8NJiFJGlSPTo6QtAyAFEqvFmWkZYs
0yC6asHhENhX8BZud/WiId7k2/cTjMC/YWiZxwMTk90r6teAdTGTHoXx1ezfaBXoqA4BK/5s
gBn7JQqINxskrpAur6eYP0z6oGsGDlicUplCI2mYtI4qlX9Hz+hD+Z6bdYTT0n9glE0iNAX4
9fPxP8DGKGrUKde7y+SQWjaWm1ST/WT7tqubmyB8K2k5RQeJen4M1foCHahittZQSknLyyzp
ePStnEsZZIVHyyJBEUUv4Hp/FGGKilHRCH14S1e2o/r9UuZ/IZRzYTJdN62dKF42Q8hlW+iQ
4hz7N8dgK9NdgRxjtQ40eQoxFlH6lb0sFhINxIPh0RXGZl+WKdaGTzMsYz0GcP6cU1aJqsNp
9feNCxGcO/YdnF8en3wbXn7GBK9bpqDXv2ykFRrKf1du+g+vpi0EBjORQEVrzCYwO8B/4ySn
KRGrzfgNqWVY2s7y0QR1gCmFSr1Kz9JB9wrdf6FWZUBXypM5jLCTfQbH6nQC3pzJLO9v7WwI
hwvjx8iiRNbYCpn9EFmrHNUPkLW6zNpHIet1ZP2jkI06slEi87+MbNaRzY+S2aojWx+FbNeR
7Y9CdurIzkfpmbOGqbAPw26aIf8wbNHAFh+lbd4wRf5htsgbxsg/zBp5wxy58VbsbefLzT3e
t43Weget/Q5a5+20Yl+0aKPl76AV76DVXqft9W6Go/PrPjzi5wQzNgohxM8HCoBjBUiPgkpJ
fKZrHSPPsOI+q86nYYuO1qM9tNGXP6l4LDduNjwC/8MsDVPFGS3t4ETxZeS+YMqSLKGTPYS0
JHNQnrPL4dGNCtnrgW7ZFqLCSTJPRsPxBDrR8t8Dagub2po1GtOsOxTUn2LC0l+dIlul21iD
hItigY9bi8OaoxsY5ifSK1JaCbjAUlc+JelD6w6ZzlTm8r/uwu3DjI7lq/36MPYxDdsUJjo3
uX4H3zAPG4cxraG4/gulODQoHWwpRfPArG2VHm66oGvCtGhXGQulV+oHzoS+Lh8wn7a5I+rF
g44JjF1BLZPwL+NhVaA72Ck6K1mW9OHNt5MNhv71hNa1xEhddLpseE1msh1e/0e8WIl83oGw
mMbvKNXr00IkQqj0ebM52PniZk8yig6gE7iLMHpRO5aHKpGM6F7zDgEz0SUt9NCzvumb7XAa
1zEWpbTOEHsSzil7RdGKOCuWyySl2b00qf0SEUwycBiPvmOFi14sPVSLLU8uCqUy3wwz0+hl
MykczeKoP9qZXC2/9FWLJTl4OEtyWaWzaMABFnfYJqbH99Dd7OE5OjP0VpjtV4D1NfZjd5pt
MCxlujeTU7QR11cn4nK12Vurb+gHHiS0Lx/zxTJAdbRYhbAdQzdqBcZfXy6sagxMrmkpdlNo
CIdxE5sLilw+txf+hrk9mbloFurCEY6OOftzgjQL6WaFOpe8HsH1mbZsKTc9Rf/CqGn8Qw8V
SNS1qXczWmbGVgxBJTGMTo4yuV7f17i+YpnLWGJ1M63omW630qPZWpVg5ZmeoIirU8y7jUKn
1ubBBsTkDBtdrg44Z5I2NNAT+HQSKZNRAKiNHJYu4my6Z3A1RddstNS4Js4a1IJrtPIaongp
LTqkcmd+rL9kxaxcI1yzmlzYJh0XnxeRi5Gn6xeLBRosGhStVGMZKNP1gGuW4zCynPObPlyv
y0l1vjvBOh9Kc99aDcBpY1vI4S0LmlErRc5pPydWZzPiYk1ra47FV2U2bWOoHQ5aU2+Wrrqt
q6qQThYs75f9sij/gjF2HBVzxXSa4DRMogiN6Uz5hdUBApztPWMDZFsMgZBjdeprd8dDCcHV
8r46DuyqYr9k5z10Ag7Nki/FXJIj3UgKNCFgFJ6o9Wt1llUtnXQ3ayds+7wIYqEzoD6lbuib
OFUyKZ55OV07B0SB1kTza01v2+jLmvQ4Y0t6zd6iJ3FMIfguvdjCF6axSy90Lpwm/QpfYKja
odeFqNPrW/iaLXbpTQzirEm/xnd4jZ4zR6zpy6nkRvME84X7xYq/bK3ZltjWbY9+p1e2s2rl
ENLF067bJTZNOYGdJjNsSUNNpJh24JR62ciwZrO4QdN+vgyTbmBx28Yk6BInpwsXGP/lQ7VL
RKefV4e0hNxwC8O23setb7htnZOWqmOkPv12aHo1GXYw1S/QOZ8p3oMNucEdvYV8E88bHCZz
eAuH1mMwnZyOaT1IxmRp2RaTxaw2pk0zx/M5Wg85oXqLwiZzvwPKBtXmAu3woAvtpsksLKM0
OsfyFyZkqB4tlsrnJb6h8LvOJMLF0l39KkD0NMcwyfKr/WZUbIrmmddjLxHamlirqFNlIRlM
GEw0mBgHG0J0j/aKsHQm1aYmuQ8auzQtluvabMWnMxwCseOD7hMMCrM09NF1PGFWmzxlEKTJ
QmH/E8IAsJBAvWEUOVQ/JPvb0gsHceKl2d/U0mMqSUicMrNi0w52eOvkeLV6J+Dz+Dyj3+LO
KG8ARmcBgV2UXHpP6MYWF3nW6wQn40kp3C2+wI8dDFMurcxRELwt96C7QbA62kUopkkmQQ4b
xpdjdsy0PmN9mgWnfbiawFqvt8eT8QhOSRi8TuR8QUnc3QbJUbl/K9IqWescn08vr26mF1ff
L88O/lllXmqPG8HXUAYTrVCEQlpwfR9Go9Ory4vh5+2970Pw3Pi/8ioY0I+YZUxTmrSzGz4y
nHISc1fMgSC/D7NqUHtrERzNZM5WIJtEqNxb7a4R9HTKekyDNWj1Vlquc6rwarRGK63QBQWS
Gq3ZSqthDdjEtVppdcy0eYPWbqU1NDTzBq3TSote2bEatJy1EluaMJqdI7laiNHStRZi0Urs
CJX/1olbxw5tnLf0j7cOno75XlsHW0eP3L1ojghvHT5d2FxrDglvHT8cPlR1k7h1ADHVa5tw
vHUEdQNzVrtBLFpHUDdxKjfFEK0jqFvYw6aNiNYR1G3OzRbi9hGkcqeFuH0EHQcNpUncOoIG
s7nd9AGidQRVadDUs2gdQUOYmt2i59YRNDSseFr03DqChq7zFmKtdQQNQ+OO2SRuHUHDMHUa
W/Kl22EQ3XEZV9BBr47qELWlkV1g+JtufS7PgCiGVJalMNyGCVQJEx2N9wKrCq13GzC0f/4u
ML88EET1dAPMEfYbJWv7feesFdRkqmB7O+jOsaVZ0A6K9esbJf1/1q6FqW1kS/+VvrV3a8gM
Fmq1nq5ld8FAxjVAPDbJzdbUlEqWZPDFr1h2QvLr93ynpZZsmUDmXmYqGLnP1+/u81Z9tdfU
ThhoakNp2xYcp+AB1pUOdIHaW80W6Sxht20w//UsEnceuPYehqwxtJrkAIZsYIRO4PotDFlj
yEMY0pZhjRF5Ehu6jUHrlAezW818arsYU/pVDwU1MwzlIfIZcbbpV9G/uBSwDz9WgLIGtOWE
Z15Oggag5IvgBwDdGlBN/AaSw1zTDyCFjaYFumlBs2nqRwHTRtOCRtNcn6+ZPSRlJk7iSm1P
fthYQIFHwmd7oAijbEJVsa+3l68m0JMl07l2MEVcuMssbo3oOV70CsRAIwb2IcTRzXkFGFKn
3f0Bc3iN0xZxu1KCJ2l1UzX3SQgRfn+fMEZjOel9P8nqfZ+VGj+orcyw090nW2uriRXWWHRw
NM4Qe9LY/qFjs5X/ORhlN2HyGiY/0KTADeT+EKnGUWLb+YEhcnaGKAils78H1eEhysdp3Z5m
gBTBEBcR7U9/E8ZtnAS2PglUg5x4w9ZBop4blbBuxbg9KpEbuHK/KW49Ko6XjA+MStjcH5Fn
t7vjPjcqE1lPNn2smuJZ2LdBeOCmIEnn9v3NWRlMVhWXNJ/ggmrRsW9k4Ovp4lH8cX372xlJ
j3D4EJ74WdpCVtZHz4Jac1fyPEB+/jw5nQme/wJ5ryYn6p+b5BG4pxfIL54lV7SpnZdqH1Xk
P0c1YehH8uC+/HyfJOtxt8rVIZKC/Z3gW1WqhGoMfWM+j1HTQMhFQossT9kZbLr8hRbC8fLL
wnxme8LpwqTk4Aro4vxeBSXXlmotrKiiy2qAkJnNqnjTVcqDmMKGu1Fv1K+11m2bB5VUUGu2
tMbvR+ct1hKFSXyNkDNjrJXkDXXtIv+iNTQTCOzakoSCk6Km9iQUX6+mftiOa1o/AnPyHG05
FXW1htD1eBmVucKmWb4UabLabNd5XSGNOtS7NU3ANKtVEevamHowGMHVC2pwi8P6WsPj0py4
TbpRZYZhGpo1yxcd0Vuuvq6n9w8bQSev16F/AjFcZsvZZCneTpdzLE/xX/flp/9lR1druvnv
up7Ihyw8uBtoW1Wl+znUJi90ITW9Z20VBwcQ8yqy+ZQ+P+aLenaIH8B1djWglT1PFsk9DeSk
MiKbUoEM4SJ2ln2GSjArx3UEdaI4W6cPU9jPMbilzaBfLzmrBvHccFdfx+YHKPngV7Gj3kNx
nw3AXBwnJ5t/Yxj7ONcc9jM65pdupzUdNTWqU8Gw1yenfxpvJxNqWy02NDIyRY1rDBgRn4Ev
YTRSHZkURxWG5xCGs2dW1N6CNIDU8MYXdeS6oXa9ANrsD1ejLlICPRL/tNzQ0ZXhd+xbvmUW
ruchCqMqi++/YyonTr00LrKp2o78HdMioQVeALSrUacHlC77AdRLyyN2Q/lwgqAvr6ZsB90r
QesUsvJqQTLrYDHQ04xTqCrhS5j4uIQor0I2QEEFO4A/BVPo3X1MLHHBasYxQlp0JiTTWl9R
e8IaSb4KSdmqjURALM6VSM6rkCbyAFLgs5qmQgJLns0T4Zi14dNlFe6WeEVdwYH+E+MXQk9X
IbmvQnIPIbkQKGok71VIni3bSAFdxk6N5P9lpDAIQmbcmyupSycGzp1gN2jIt6SiE1zt7TgO
ol7N9w35B834e0Z8xw49iJKOa8z3VAntSyc6JPVXwr77osqEUOhAPawyqVC8F3UlhELXPZSs
z6P4r1aS+BYcuH33e2jBq7UjhKYcD7zIS1ZvxxBA8UOduesNRF7g1JoWOCkPHWJ8bFUuEuq4
dJBqnmOEFwS+F2i8MS6/F4G8Y0Hnkh04+0iRG6qQkbriV4NSGJsFLCfNJutTFXXik8EhbHbW
en8xeNHvwznWKZz2mqIcEg1chuhc06X7l3FcJUP7FT4JhoAYSzAUw0FvhwAxXJl4f9v/KAr4
zG+QpWpRMFsyZ9OpZSAChH+0IbbZ6jtEkChVm2iTfo8oiiLbOUx0ezX67FqIrkwf04dkgXiT
Z4FcqU2obSXdNRI9sP/fdA2DKXEpJ5BWGGpivD8IwonkAYUIbrx+/6MqDYpAGpAEOgWbkc/y
pMgNgKuCwDkEwO6n2guxPzrjLCDUoXs2+CZs6q1b4YVRC4QFjw/MG5eMNDtrFQ8JbWQaruG7
G040Zk6QRuLEptjvg18K3IpX612PELKP9XZsMuH5rikbeQrOAe8XK5oCNB6cAXGck8Ky9MhL
24oU9RpcyDrPTZmsTDyDPCfK+U2XpaHwXB6hQe/65v317xe/d27BbhSb9ZaN24UALw5P0ioP
oWVIAzeCDeHsw0cBY/rl6AdoaWnCQAJD+iRPmP39CUAVO178JKYF0xoXPENMYiBdL3+VWLrS
/8vEtI9hcSpW00WMm7KzoQIE0e10Osj/uOYEJuxf9QeHef7ZFQvOELguYhqYvChOHbGAU2jj
iY3sQZuYhavPyezUtyH9jJdFfippSRHbTLeq+VZR6e2G/jj1RBVFFxd5CpzlYjmZ1EWrBw/L
WUa/y1g7dCR0PRxJ7Y6IHnwROY20fhKXDRAIZzX0kTYJvYpet3aH3pFRFPgH6Q9Vq7MrlVwy
yBUJdNH3q8fjuALTU7DbBJfEY/X9JjRa3mqCryJ5uAevb0IQev7hbjxH2moGb/YfaAZWWrHT
CkUb2T28Fl7bCkUTEryiI3XluwghnUNOBAaqKokzKx7TllzgFppoN6h1uuXDrFtXJNbbxcJk
kQUQcYdw8ToE9A6+rvq53qMJ3FXg/fo3Qx5GDu7Mf7kd0vaD5zr0inbQ5RnCjRP3EcEWCNlD
ARq2+SoeTzfFqe8wy83MyqkMSLwGD1H+Xe70CG7lEXjJ4tOW2B248dbZ30mQIW40QhJaJd+I
wcN0NpuuSCLd3j/k6wqB+DoXfNMtROSKI6jyzE+zGCzuDIqLx/wrq8IMoet5MDD8Vj7fKbyn
d0FxYrX8veKlYaddmFlkBASiR3SfJKIjHjabVffkJMmL9GFqpQ9WvrWW6/sTKnNS0Sm6yqFF
/P32oysmkMC1ns+2HEs16rEqAleGIW6qT4snksWIzG+SUc00iofIVORBjp/AU4ojDY9KRRiP
fUDnxxtTNqK1T2tuyengJkXMNwf91mssTWbGGVynDtDiWHfBicS6drcC8qQKYCAzQBpAM2am
7u0K104ybypAQayUjxaP3vbFx6uRru+sd02MSFFFSCQbYpPHW+ZOFsuyNU3fNcKh/aeXS/+a
UKpKnb3aSBAMMdnUTacr3l6NHOYcuKtVmSiSJFH8qdNsxJsnTs2142V8xF/pgXQQJRrakC/P
eUeStEzrjPW5pfu1OBoX928qlWfVNNtyy8aJo3nyT2JlHDesMR3lwQOKBEpOsLiFd+8CISt7
ixJlXYfjJHbKppNPTdXrUcnV1RV4VEO4RzT/1DHe+QfqgUlun+Tx67i9raiwdBUby9N1qmio
e8NefH0Zn/fvRuIULvJ4cH4pqgeGzKNlaRuyliv4cRXiA38+kj+rCHZ49anQc3xIUovKu50A
HUVbwi0B01ZDTDGSG8CQVsV+qGIZkuTqIqzLVOyQFEEyTYUYp8v5mDN2hCpQz3i4O/BMCdgW
q5vxaqrAV9CfPn2jPUxLFqFt1fZrrH+UDElk9/ZK9nQYSFKJFGza4n340/yR/miWFinBBML+
iVVDfDcL6+mbPpygIp2WqcqpMpLlPcwl3Hvj6SYMunr3GvsNykAzWTkQzzltCIIOluMcHG3j
6U5wSr5e037pOE4FE9i+D8fS4mGVsttNlRP99Y7yrsFylA9dWMGKX5IgKpuN6RgNdwQf68/z
2WTcCECoVOEoEihm83rL7Sxjtp61+b1kTZfdUgyRTEPc9H4th6OGhqqWxowGqv+uSv7Hofer
1WxaT2QIzQ9i3+8TNOHXt2d0YK+zA2KPwwbwCAdUWdgML/9t2d8f2lBJB3qH15uSMhoVQ00M
f/AjpqRiXqTbyZOh9yM2DfD7cEgAJyl3Lc6JP6YTNCnESalPPLm+/Tj6v9HdDUnJ+Dz4x/D8
Fp+ZTv9rG8wwZAahNFg2If8gwistIzu+heB/+D2O6BRPZrQLHc8+kT4dzCYAyxXsyquzUJEY
vtYKhkb0E+F4thuCGSp1tJzYAcwXkg7YT2oSiiMkxzsV7jGHXsTjZJvhdOJkNG8gGCaC6z2r
IH0lA5gqSmUtIGUN6dSQ6tWQge04kDL7jeUsbpfflvNpNTmOJU2naJs4MDDNaLuVX5fXGfKF
mo1eaNWvoVKuNkthOdPxVpJ2xd/7GTS/Vnr8WUA4gMXNPrHVieNQO6Fv9wKRfZl/ccTl00r8
3QB6dqTYpdBaIniAN/p4SXuhrNkyJRHcpaqSV7TKkwVrYbi0+Lrcivm20PJ3nTAXxxxGsg4S
qgGDSKLq2+Wi83k5I6lnZhK/V5c9dcUUj0jqguNLPktnj3HtJI+XE0xoxBadeboaz5CsQjx8
MdWEdqjgU1jMiQ/pdvlXrLOoXA6H74a0N0jonma0x0b4rn9hKB26sqnH8y/JZ8iXKxWENkHo
D/24NvmdYwgu+GVUlzgA6AS9AeNYqiTqtC+IE4Jz9zwhZre0kqMmuv1wfZY18a8s63b5Q8kP
lsBX+rDBVWGqL6cAaWIMohdJOBX+RUQDEwUBBJo/svWcpn6e3a+2Vc4aBFVWHgY7mX6Ijm5J
BcutpmvYRsXne8OAO9AISemwPbTMdVZdojRQnIGo9BEBpOv6uBJ+5CA1tEEYgR2kVYjzJl6l
lelIhz+Unlgtk42hJ/kDdpaSHqrMXqfYfJ2VsTW0Ho55mQeIcxgNBsd3w/7o7uzusjwMA0sS
AMybs5VdxQdVaHTWVIu5w21fvLEMWQRvMDrAxyQ+zLuif34jzkaIdljzODWib3b5YxriHeaF
ZBc74GuXI/c6U2RrwjVJB+896rSEeA+pZ/3p9NaQ+HAQ+YExz2YLxxCHJFNEUHtOEQ8hboh/
nnZobDf852UHjn+ariJRduTA7rCaTp/2nAVROK0ZkCOdNrBrP8FehZw8rLB9Y5Ac4iidg0jY
kdK2/1MsEpjeeB139ZuW9NWOVEUkh2wa7XK16zx+plmOdy7ddKB95tmvPTwDQ+CTBOIbAtki
CEuXUEMQSHYiGnCo0j13tx5d1FmpiqlwJF0fxtRnC0tTOLR8SbcUtf0hS8s33lx8uOgM390c
i7M7HFK9i5PyiZ4NTUjCuhc4uHaZkB2s58mTGPTfueJLssCeoc+O5x0l282ys9ku8jdleJX+
yjZAAaSZEujmHzQMTpUsaFZnOUDBkKQ2SEjUXT1S2tVVToJjXPQ+jgXOg+saEjji+kwiSxJ2
QZUBkwQ1iVeRKIQ/R0zSuc+qlQvtqinhhjxk6yxJu9WJ9EAnw+yArBZhsiNIvA+ruPjymvI0
19C75fNXoYd2YEMVtJim3d60SJdaOr7t98o9zxmvESVuNTvhIo4ELv3TNHKfnhBMl6yIs60e
iNHZ6GRES2BfssbhrHbODihGfLbCUfXTMpr/aPhG9HzbBs4B0aDTwHMssxZcEqHg6TfP75Mi
gSU6gIcwydOWbXfWqTQF/SjEkTtfbRQVbCT1tiQMUvh/v5FhxKYNxZ5Io81yjYDaRtN2nadw
65TeUlAMW7AOUUsqNM/2uaXXNNYlYjlgneFZ/+JVuMrg2jWu47kI5MqpV87aMH98/uBoGueG
EczTBIooOqXP7u7elRSGMSS+O29yhwTt6sjoDzfc3sEHXihZe0JsK7DszqOh80JOYgFp9kOl
+kEQi4NE2/ptTePthH2Q2PB8LIqTe9q+9wVMrwYGSiS6LZYFnRVdkg3uklVe94+ko3eLkVZi
VX5ctTYniiz3WSDmbvFXyd+SNA+PMqhAbYn3VUrVVS7k6ZyOlQaDG1k+EitGpYfgTZ5NE9GD
zRDTVq57m446Ycq7DnPYRVpM+dSjwx6f4/KNaPUghj4CkWiUIHHukwtME3ttxfPxKQ3YcoWE
ek/2MdwU59NNzAGqnFsP+nXa9FPYggxOGHHMNjeDbi7+T1yw6bVzpqMJ8aMXGv3UbRT6h/rt
i8HvtMPE2e2IBjGosAOH2Bl/H/tss+H0/fpxpXsr7u3SY9hQe3TkIong6Oqix4lSOkibIa5m
MMzfwRo80yGNrMozZIHNLNh8kyF5aRcfqo1zRJ/p4ylM6yeL7Xycr99oYYI2w67oHhE/H3nY
5aPzXuftxycxQb10Jr3rImkg7lXHi8TNJcmyT1npcs22WwNA3+OWKWYkkmh2IF9Aed4WUqiw
cjlVxjCZEyMxuOl5nmQZ6Sb/9i1ZQNNHX5WHniWOem/w0rjoGOIXXkSCtCe3+QYGgQaoG+lI
mHlKcN0drYMp4ysP2sKa5VxB0t6uTnSmnXM2ck1mXysCOvp8jvg5wOMapo2YSFiDitW0fG2H
4ux+0tc2Mf0FmCT6AHvFmHZKzDn9joWvNYMn49KrDaRSBbbaJ+Usy3zB02oPBcweJ184nSX/
iF+/MSfRQZYpg+S67G3x3daTzDTLqooMpedrr3czUJCDeFWAIdgv7fuucpulzz4M9wYTxQJa
JTujnyYLTNM9rW9aL0/pbMuuC2Vg72RpbgGqsDObB/ZstjJoxNU6epji8qtu84+S74QeSZ8G
20J0pJkgaQceZLkc3vaN23cwfHcieZ3pBda+eomvtBzZeQw7t2elNAM8R4ZQSZV4tZfuUapX
Lzx1/TpnD40Ab2i9fj260SK8J+jPRjqb8/dvu5yLRejcxXD+RYpHGL3TRx4eRxV/E38UX5DD
e92Vf+6DcZ4gG7lhkTsTrxgmRF2akxpskikznYdz1v6H3Mf7lURivgZxqvyb3vXYgN+wNQfn
CuInZOJJmaQ2P7ZoCtO9L02MRQNi2B908fIwuxvHePVLjHs//IUuiRNIN63iIy5OU9YEznNl
i8ur67O3I/2t7bi+eDfsv42HZx+7jRTp+JGtYeJC9t6PGJ5/3G1/PiEpa9hrAMJLKcvTsAV4
0QZU1Hi6gfgYTpvVXPT3q3HbgOfUb3Y2xnpVbqKydCKGdli2Bd54dgKLDwHa0f7TUsZqAiKI
xXTDo+MvCTJ6Kg8BSme3hZOJ254ZYj/2ARN66rae0m0hvdbwtCYFNtvWpBzhnzeC5tmAqtzP
628eFzP6cp+stc80Nk3nRblixGX1oTe068ZRh+nEVqoFMHQOrJjeUDWeqtx18P633tDdKevY
/rjdooRYX2Ic0ry7/5XYLuBlGS/yp03MTvq0PSI1pg0SpS0g8T+lbkrb7SfrPIda6hdIkA6R
KCc7QFJWcZ9v4jVdXetFXNoN4tVmTbQetqN3qLI5SXDzFRVx0xMoIg4UyfLVchMXULrxqYC2
eBMAqnbxuFEwxuvuubd4h1L2Ql+pXIJXLbWnW79VKiaebMwDQiVTjIU82NxH6lIZdlAWlnaO
0u3jiEqzp/GyoGFj/714yXmjMWTclucotptY58svCWIkyVrnC+6uE0WYKbu1ayvqrIhTqm4d
L+lmoOO8QH2gSfzvkORPeRrnNM1LzJdyXRCo5DmKFU1+si6QDZ8Jch9dmvgvEyTzGXohsSJ8
3/tO+Vy//jgmjvNhmaFV0j/Be3aD54gWRIQMizR0WHQZZsZPD63papyr4vXU5OiIM3GeI1oX
vBNWxIPphsVgp4gw9HlSnx1kUE3Xn+IyqCXelFsvyTByrVPEDEQ6ZTLY97hWzkNKdBM01Du4
yXcIaYaI4SACH8PhJi8SaF01lnaASVIHl3a25PK6bKxZOyIZ4+Qhke//27uyHrdtIPxs/woi
yEOPla3Da8tBlDYNgiBAi6BB3oKC0OkVVrJcybsbp+h/73xDyXYjyrGctmhRLRY+ZJ7D4TfD
GXKoydFKLkkHXVU84RfItdTlYh1Msv6HlG4AsLECDTioGuqimwxx0lmyWt2qlIcOWLHNPKbL
IWWdx+elILAHibVDgPupSKuTuPINpYM23Ba7KzWBal0+mjEPmA1PNLzR+9FLsJClhWBFP4Z7
5bEHI4CG0VI/qsVauT+wPwcNcZDYDnUT9QJZch4kf0eLGhRZ5KAhy4SEQU/f5NJ/kLxl7W4N
7ZqSRyhZTzxYACQHQ5TrAtOemw54sXmCOCey1XCsjqTwtj9GZJtJpB3YBmcgrG5rwaWkpgue
Dzrx726r6LrPspd3C8i7RUsl6k+KvtKpj+zrW/ZfIPcOuSmbupgDMzQMWRcKu7LFH0jk4cCu
tJ9L+5203qJjISqjV31D+4jYCwVsk4P3VtZ5WNOhV30dvUXyJSzW1ARhxjqnX65AZRMItDRP
idrL6qKMKoys3AcbrafdDChzHZ9W0jhGJAaU9Q2rvTT5ZI6iYMdBizqG/mw95gItpqcO06ub
Fyg8X6bu4BwArxjUSTGp3jDgSz15DwOhLDxEORYSS8yUoJNBqB7enoA+HeyTTAsGJ7uDzheq
Y1RdDquOvKe5XJT7/kEhc5GztTynnIrrlSlMFkDlGVC5vdK7XOWLYqCeqog0A9C5owroMUUZ
cunALZR5QikklQ0bE2SlGgUGNvWy+Mu0zlZnqZ+dveXD38U6sSTs66AM61ZdgqWXZqvvBvWg
sx9Hmm3DDmBAn5eRne2nlldVulofsxDN3E6YQp5NvTlAsq1b8tGyFKZHVGd2DWRKyiXLFKUb
Y/8la7r6YbxMs8dcV41q8Jm07k7de9CO/yHtOI1KRjo0QIb5muUPcMrRIkNE6tp2zyG8LHM0
hLtsKaeY/lO+6kIT1XYWbHXDEy5am1TKhNZxG6JcSIhV4orB3P/AQsDsAIbzqdhnCXrU5l2Y
pZDJ/rJzSmtSW6ZzTnImiOI+PUXKTQ5guWODoOWj0KW20HoKFLLKChbXMXiPsVcLXVKiZFKu
0zzmg/HQBfQG+XrMlbxMI27x/CSKqKR73rBxiueD/eXrvj6Wgf52AX2OmWl25DjfjtAfJ8s4
L2htiv3y0AHMLrtrC1NtXl10YOoRrWtKB47e6toLq9c42JXBtV01oGfxkFtmG397AHsfWO8H
6ny+TyqcBuOz0HW1UrfaEg7tGkGrFT9Hbi3rhCH9AklC83jbkJTxSgP350ubz5d1Jpa+4K2E
SSKiRJiJCObCnAnHFO5MhKZYzHB3keOKyMSvyxgP9z8hvS9MC7HZ1H8QI/v+a7wUyVKYi/pr
4ojQQS4rEa55SEb/T2fuMxG4aMjx/6L5MHOFGwgTZ1Hw2VmKcCEWc3Ht80+R+LRf9eW56sJZ
Qx2z3q1DvpblcGHtE75Al12gVYsyJ7y775Rn94l4JY7/fhT/Fl/vKQfV09dvf37WBmRQiuca
+M52dasmWtCwFUfymRGpdiJj2kN/ids5Gm873ytcyoRFpM9KQ6zj63366ganaCDUWOagQe30
N6UqllLVW5O4+Zjbtka9QDJcT6FuOeYF6bV+dtdGq/r4FyfnogN98m3Klsubj7LeEtmAsU7J
qfKNxHVXNUn226ghGmy22LQXTPrk7lKf/OlUN76D537w3POfzmyjdVkv3KneZT04uAcHd8s0
Pji4Bwf34OAeHNz/BxPe4OC+lBSDg3twcA8O7sHBPTi4Bwf34OD+jPI8OLgHB/d/UDseHNyD
g3twcA8O7s9j6uDgHhzcf7uDu3YEv0kSjm27j9Q2fpn5G8R2BKo8EQQl49v73PtqPPo1zu8M
FXfVoDWHnM/GI0PJEIOS0BcCe9wx8BBn2dW3VR5v8Opv6Jc60NRj9U4P6pjo06JKc38VT3dF
uC3Uq7Et8euurmQSrj5Shhy3v9B7lW8E3usz2sxfV8S9HHUg3pr0k/qGO7LLqzRqnvK9WSo4
7zpEqsIoYzykz42DVaRzxzTjKjh6ZvjqlnG2O9HzchtyIDmPnaagElrFgfGI0aK0QOPSaoPI
U3x/FrW9oP4UpVjfZdn46/EYzvJ1BJriuk0PsfumtFyiVsLtLuF2l+x39qzxqK4X3k6v/kyD
QAqxnz34u0o24V9HZaiMLhP6ICF3OZwre0hpYeWBo0ZEi0mawLeOCBWjDVF6ezuh+m/zauUV
a3rE9RpU8WE7wKEx6zyVDWE8fjoeIQhE8xnzhwAqJwLcejYqKPLNdv+EqozKIJpwQDBlGPJc
7g8xVTTJipXM4vs48+KyHI9IIy9KGFFW/HA8onVGVWSxt93uqKTYL7Od6oHHkQSvVEy/P6U7
enq/8r01rvOmksqH8SgoEXvS47uqwE5xNuVX44bWANnOsBFvxLJnljMe/fDmzTv5+qfnr156
083tasqZpopBDdid1HUaRmkanGU2u56uwtCYT+utDosotE03ms9n4dIKQ8ddJEmwuLbDReJe
R+Hcmt7nKPSjod0poacbRjwuk0kThZ7oS9z16PFvNB3ff//L74+EoVhN0DP16f039Hj8B9to
q7mwuQAA

--yywL3DpgDyP4yZ2G
Content-Type: application/gzip
Content-Disposition: attachment; filename="dmesg-yocto-lkp-kboot02-11:20181124211830:x86_64-randconfig-r0-11241445:4.14.0-04088-ga4a3ede:1.gz"
Content-Transfer-Encoding: base64

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
c2zDAAA=

--yywL3DpgDyP4yZ2G
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="reproduce-yocto-lkp-kboot02-19:20181124215445:x86_64-randconfig-r0-11241445:4.14.0-04089-gd17a1d9:1"

#!/bin/bash

kernel=$1
initrd=yocto-trinity-x86_64.cgz

wget --no-clobber https://github.com/fengguang/reproduce-kernel-bug/raw/master/yocto/$initrd

kvm=(
	qemu-system-x86_64
	-enable-kvm
	-cpu Haswell,+smep,+smap
	-kernel $kernel
	-initrd $initrd
	-m 512
	-smp 2
	-device e1000,netdev=net0
	-netdev user,id=net0
	-boot order=nc
	-no-reboot
	-watchdog i6300esb
	-watchdog-action debug
	-rtc base=localtime
	-serial stdio
	-display none
	-monitor null
)

append=(
	root=/dev/ram0
	hung_task_panic=1
	debug
	apic=debug
	sysrq_always_enabled
	rcupdate.rcu_cpu_stall_timeout=100
	net.ifnames=0
	printk.devkmsg=on
	panic=-1
	softlockup_panic=1
	nmi_watchdog=panic
	oops=panic
	load_ramdisk=2
	prompt_ramdisk=0
	drbd.minor_count=8
	systemd.log_level=err
	ignore_loglevel
	console=tty0
	earlyprintk=ttyS0,115200
	console=ttyS0,115200
	vga=normal
	rw
	drbd.minor_count=8
	rcuperf.shutdown=0
)

"${kvm[@]}" -append "${append[*]}"

--yywL3DpgDyP4yZ2G
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="config-4.14.0-04089-gd17a1d9"

#
# Automatically generated file; DO NOT EDIT.
# Linux/x86_64 4.14.0 Kernel Configuration
#
CONFIG_64BIT=y
CONFIG_X86_64=y
CONFIG_X86=y
CONFIG_INSTRUCTION_DECODER=y
CONFIG_OUTPUT_FORMAT="elf64-x86-64"
CONFIG_ARCH_DEFCONFIG="arch/x86/configs/x86_64_defconfig"
CONFIG_LOCKDEP_SUPPORT=y
CONFIG_STACKTRACE_SUPPORT=y
CONFIG_MMU=y
CONFIG_ARCH_MMAP_RND_BITS_MIN=28
CONFIG_ARCH_MMAP_RND_BITS_MAX=32
CONFIG_ARCH_MMAP_RND_COMPAT_BITS_MIN=8
CONFIG_ARCH_MMAP_RND_COMPAT_BITS_MAX=16
CONFIG_NEED_DMA_MAP_STATE=y
CONFIG_NEED_SG_DMA_LENGTH=y
CONFIG_GENERIC_ISA_DMA=y
CONFIG_GENERIC_BUG=y
CONFIG_GENERIC_BUG_RELATIVE_POINTERS=y
CONFIG_GENERIC_HWEIGHT=y
CONFIG_ARCH_MAY_HAVE_PC_FDC=y
CONFIG_RWSEM_XCHGADD_ALGORITHM=y
CONFIG_GENERIC_CALIBRATE_DELAY=y
CONFIG_ARCH_HAS_CPU_RELAX=y
CONFIG_ARCH_HAS_CACHE_LINE_SIZE=y
CONFIG_HAVE_SETUP_PER_CPU_AREA=y
CONFIG_NEED_PER_CPU_EMBED_FIRST_CHUNK=y
CONFIG_NEED_PER_CPU_PAGE_FIRST_CHUNK=y
CONFIG_ARCH_HIBERNATION_POSSIBLE=y
CONFIG_ARCH_SUSPEND_POSSIBLE=y
CONFIG_ARCH_WANT_HUGE_PMD_SHARE=y
CONFIG_ARCH_WANT_GENERAL_HUGETLB=y
CONFIG_ZONE_DMA32=y
CONFIG_AUDIT_ARCH=y
CONFIG_ARCH_SUPPORTS_OPTIMIZED_INLINING=y
CONFIG_ARCH_SUPPORTS_DEBUG_PAGEALLOC=y
CONFIG_KASAN_SHADOW_OFFSET=0xdffffc0000000000
CONFIG_ARCH_SUPPORTS_UPROBES=y
CONFIG_FIX_EARLYCON_MEM=y
CONFIG_PGTABLE_LEVELS=4
CONFIG_DEFCONFIG_LIST="/lib/modules/$UNAME_RELEASE/.config"
CONFIG_CONSTRUCTORS=y
CONFIG_IRQ_WORK=y
CONFIG_BUILDTIME_EXTABLE_SORT=y
CONFIG_THREAD_INFO_IN_TASK=y

#
# General setup
#
CONFIG_BROKEN_ON_SMP=y
CONFIG_INIT_ENV_ARG_LIMIT=32
CONFIG_CROSS_COMPILE=""
# CONFIG_COMPILE_TEST is not set
CONFIG_LOCALVERSION=""
CONFIG_LOCALVERSION_AUTO=y
CONFIG_HAVE_KERNEL_GZIP=y
CONFIG_HAVE_KERNEL_BZIP2=y
CONFIG_HAVE_KERNEL_LZMA=y
CONFIG_HAVE_KERNEL_XZ=y
CONFIG_HAVE_KERNEL_LZO=y
CONFIG_HAVE_KERNEL_LZ4=y
# CONFIG_KERNEL_GZIP is not set
# CONFIG_KERNEL_BZIP2 is not set
# CONFIG_KERNEL_LZMA is not set
# CONFIG_KERNEL_XZ is not set
CONFIG_KERNEL_LZO=y
# CONFIG_KERNEL_LZ4 is not set
CONFIG_DEFAULT_HOSTNAME="(none)"
# CONFIG_SWAP is not set
# CONFIG_SYSVIPC is not set
# CONFIG_POSIX_MQUEUE is not set
CONFIG_CROSS_MEMORY_ATTACH=y
CONFIG_FHANDLE=y
# CONFIG_USELIB is not set
# CONFIG_AUDIT is not set
CONFIG_HAVE_ARCH_AUDITSYSCALL=y

#
# IRQ subsystem
#
CONFIG_GENERIC_IRQ_PROBE=y
CONFIG_GENERIC_IRQ_SHOW=y
CONFIG_GENERIC_IRQ_CHIP=y
CONFIG_IRQ_DOMAIN=y
CONFIG_IRQ_SIM=y
CONFIG_IRQ_DOMAIN_HIERARCHY=y
CONFIG_GENERIC_IRQ_MATRIX_ALLOCATOR=y
CONFIG_GENERIC_IRQ_RESERVATION_MODE=y
# CONFIG_IRQ_DOMAIN_DEBUG is not set
CONFIG_IRQ_FORCED_THREADING=y
CONFIG_SPARSE_IRQ=y
# CONFIG_GENERIC_IRQ_DEBUGFS is not set
CONFIG_CLOCKSOURCE_WATCHDOG=y
CONFIG_ARCH_CLOCKSOURCE_DATA=y
CONFIG_CLOCKSOURCE_VALIDATE_LAST_CYCLE=y
CONFIG_GENERIC_TIME_VSYSCALL=y
CONFIG_GENERIC_CLOCKEVENTS=y
CONFIG_GENERIC_CLOCKEVENTS_BROADCAST=y
CONFIG_GENERIC_CLOCKEVENTS_MIN_ADJUST=y
CONFIG_GENERIC_CMOS_UPDATE=y

#
# Timers subsystem
#
CONFIG_TICK_ONESHOT=y
CONFIG_NO_HZ_COMMON=y
# CONFIG_HZ_PERIODIC is not set
CONFIG_NO_HZ_IDLE=y
CONFIG_NO_HZ=y
# CONFIG_HIGH_RES_TIMERS is not set

#
# CPU/Task time and stats accounting
#
CONFIG_TICK_CPU_ACCOUNTING=y
# CONFIG_VIRT_CPU_ACCOUNTING_GEN is not set
CONFIG_IRQ_TIME_ACCOUNTING=y
# CONFIG_BSD_PROCESS_ACCT is not set
# CONFIG_TASKSTATS is not set
# CONFIG_CPU_ISOLATION is not set

#
# RCU Subsystem
#
CONFIG_TINY_RCU=y
CONFIG_RCU_EXPERT=y
CONFIG_SRCU=y
CONFIG_TINY_SRCU=y
CONFIG_TASKS_RCU=y
# CONFIG_RCU_STALL_COMMON is not set
# CONFIG_RCU_NEED_SEGCBLIST is not set
CONFIG_BUILD_BIN2C=y
CONFIG_IKCONFIG=y
CONFIG_IKCONFIG_PROC=y
CONFIG_LOG_BUF_SHIFT=20
CONFIG_PRINTK_SAFE_LOG_BUF_SHIFT=13
CONFIG_HAVE_UNSTABLE_SCHED_CLOCK=y
CONFIG_ARCH_SUPPORTS_NUMA_BALANCING=y
CONFIG_ARCH_WANT_BATCHED_UNMAP_TLB_FLUSH=y
CONFIG_ARCH_SUPPORTS_INT128=y
CONFIG_CGROUPS=y
# CONFIG_MEMCG is not set
# CONFIG_BLK_CGROUP is not set
# CONFIG_CGROUP_SCHED is not set
# CONFIG_CGROUP_PIDS is not set
# CONFIG_CGROUP_RDMA is not set
# CONFIG_CGROUP_FREEZER is not set
# CONFIG_CGROUP_HUGETLB is not set
# CONFIG_CGROUP_DEVICE is not set
# CONFIG_CGROUP_CPUACCT is not set
# CONFIG_CGROUP_PERF is not set
# CONFIG_CGROUP_DEBUG is not set
# CONFIG_SOCK_CGROUP_DATA is not set
# CONFIG_CHECKPOINT_RESTORE is not set
CONFIG_NAMESPACES=y
CONFIG_UTS_NS=y
CONFIG_USER_NS=y
CONFIG_PID_NS=y
CONFIG_NET_NS=y
# CONFIG_SCHED_AUTOGROUP is not set
# CONFIG_SYSFS_DEPRECATED is not set
CONFIG_RELAY=y
CONFIG_BLK_DEV_INITRD=y
CONFIG_INITRAMFS_SOURCE=""
CONFIG_RD_GZIP=y
CONFIG_RD_BZIP2=y
CONFIG_RD_LZMA=y
CONFIG_RD_XZ=y
CONFIG_RD_LZO=y
CONFIG_RD_LZ4=y
CONFIG_CC_OPTIMIZE_FOR_PERFORMANCE=y
# CONFIG_CC_OPTIMIZE_FOR_SIZE is not set
CONFIG_SYSCTL=y
CONFIG_ANON_INODES=y
CONFIG_SYSCTL_EXCEPTION_TRACE=y
CONFIG_HAVE_PCSPKR_PLATFORM=y
CONFIG_BPF=y
# CONFIG_EXPERT is not set
CONFIG_MULTIUSER=y
CONFIG_SGETMASK_SYSCALL=y
CONFIG_SYSFS_SYSCALL=y
# CONFIG_SYSCTL_SYSCALL is not set
CONFIG_POSIX_TIMERS=y
CONFIG_KALLSYMS=y
CONFIG_KALLSYMS_ALL=y
# CONFIG_KALLSYMS_ABSOLUTE_PERCPU is not set
CONFIG_KALLSYMS_BASE_RELATIVE=y
CONFIG_PRINTK=y
CONFIG_PRINTK_NMI=y
CONFIG_BUG=y
CONFIG_ELF_CORE=y
CONFIG_PCSPKR_PLATFORM=y
CONFIG_BASE_FULL=y
CONFIG_FUTEX=y
CONFIG_FUTEX_PI=y
CONFIG_EPOLL=y
CONFIG_SIGNALFD=y
CONFIG_TIMERFD=y
CONFIG_EVENTFD=y
# CONFIG_BPF_SYSCALL is not set
CONFIG_SHMEM=y
CONFIG_AIO=y
CONFIG_ADVISE_SYSCALLS=y
# CONFIG_USERFAULTFD is not set
CONFIG_PCI_QUIRKS=y
CONFIG_MEMBARRIER=y
# CONFIG_EMBEDDED is not set
CONFIG_HAVE_PERF_EVENTS=y
CONFIG_PERF_USE_VMALLOC=y
# CONFIG_PC104 is not set

#
# Kernel Performance Events And Counters
#
CONFIG_PERF_EVENTS=y
CONFIG_DEBUG_PERF_USE_VMALLOC=y
CONFIG_VM_EVENT_COUNTERS=y
CONFIG_SLUB_DEBUG=y
CONFIG_COMPAT_BRK=y
# CONFIG_SLAB is not set
CONFIG_SLUB=y
CONFIG_SLAB_MERGE_DEFAULT=y
CONFIG_SLAB_FREELIST_RANDOM=y
# CONFIG_SLAB_FREELIST_HARDENED is not set
# CONFIG_SYSTEM_DATA_VERIFICATION is not set
CONFIG_PROFILING=y
CONFIG_CRASH_CORE=y
CONFIG_KEXEC_CORE=y
# CONFIG_OPROFILE is not set
CONFIG_HAVE_OPROFILE=y
CONFIG_OPROFILE_NMI_TIMER=y
CONFIG_JUMP_LABEL=y
CONFIG_STATIC_KEYS_SELFTEST=y
# CONFIG_UPROBES is not set
# CONFIG_HAVE_64BIT_ALIGNED_ACCESS is not set
CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS=y
CONFIG_ARCH_USE_BUILTIN_BSWAP=y
CONFIG_HAVE_IOREMAP_PROT=y
CONFIG_HAVE_KPROBES=y
CONFIG_HAVE_KRETPROBES=y
CONFIG_HAVE_OPTPROBES=y
CONFIG_HAVE_KPROBES_ON_FTRACE=y
CONFIG_HAVE_NMI=y
CONFIG_HAVE_ARCH_TRACEHOOK=y
CONFIG_HAVE_DMA_CONTIGUOUS=y
CONFIG_GENERIC_SMP_IDLE_THREAD=y
CONFIG_ARCH_HAS_FORTIFY_SOURCE=y
CONFIG_ARCH_HAS_SET_MEMORY=y
CONFIG_ARCH_WANTS_DYNAMIC_TASK_STRUCT=y
CONFIG_HAVE_REGS_AND_STACK_ACCESS_API=y
CONFIG_HAVE_CLK=y
CONFIG_HAVE_DMA_API_DEBUG=y
CONFIG_HAVE_HW_BREAKPOINT=y
CONFIG_HAVE_MIXED_BREAKPOINTS_REGS=y
CONFIG_HAVE_USER_RETURN_NOTIFIER=y
CONFIG_HAVE_PERF_EVENTS_NMI=y
CONFIG_HAVE_HARDLOCKUP_DETECTOR_PERF=y
CONFIG_HAVE_PERF_REGS=y
CONFIG_HAVE_PERF_USER_STACK_DUMP=y
CONFIG_HAVE_ARCH_JUMP_LABEL=y
CONFIG_HAVE_RCU_TABLE_FREE=y
CONFIG_ARCH_HAVE_NMI_SAFE_CMPXCHG=y
CONFIG_HAVE_ALIGNED_STRUCT_PAGE=y
CONFIG_HAVE_CMPXCHG_LOCAL=y
CONFIG_HAVE_CMPXCHG_DOUBLE=y
CONFIG_HAVE_ARCH_SECCOMP_FILTER=y
CONFIG_HAVE_GCC_PLUGINS=y
CONFIG_GCC_PLUGINS=y
CONFIG_GCC_PLUGIN_LATENT_ENTROPY=y
# CONFIG_GCC_PLUGIN_STRUCTLEAK is not set
# CONFIG_GCC_PLUGIN_RANDSTRUCT is not set
CONFIG_HAVE_CC_STACKPROTECTOR=y
# CONFIG_CC_STACKPROTECTOR is not set
CONFIG_CC_STACKPROTECTOR_NONE=y
# CONFIG_CC_STACKPROTECTOR_REGULAR is not set
# CONFIG_CC_STACKPROTECTOR_STRONG is not set
CONFIG_THIN_ARCHIVES=y
CONFIG_HAVE_ARCH_WITHIN_STACK_FRAMES=y
CONFIG_HAVE_CONTEXT_TRACKING=y
CONFIG_HAVE_VIRT_CPU_ACCOUNTING_GEN=y
CONFIG_HAVE_IRQ_TIME_ACCOUNTING=y
CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE=y
CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD=y
CONFIG_HAVE_ARCH_HUGE_VMAP=y
CONFIG_HAVE_ARCH_SOFT_DIRTY=y
CONFIG_HAVE_MOD_ARCH_SPECIFIC=y
CONFIG_MODULES_USE_ELF_RELA=y
CONFIG_HAVE_IRQ_EXIT_ON_IRQ_STACK=y
CONFIG_ARCH_HAS_ELF_RANDOMIZE=y
CONFIG_HAVE_ARCH_MMAP_RND_BITS=y
CONFIG_HAVE_EXIT_THREAD=y
CONFIG_ARCH_MMAP_RND_BITS=28
CONFIG_HAVE_COPY_THREAD_TLS=y
CONFIG_HAVE_STACK_VALIDATION=y
# CONFIG_HAVE_ARCH_HASH is not set
# CONFIG_ISA_BUS_API is not set
# CONFIG_CPU_NO_EFFICIENT_FFS is not set
CONFIG_HAVE_ARCH_VMAP_STACK=y
# CONFIG_ARCH_OPTIONAL_KERNEL_RWX is not set
# CONFIG_ARCH_OPTIONAL_KERNEL_RWX_DEFAULT is not set
CONFIG_ARCH_HAS_STRICT_KERNEL_RWX=y
CONFIG_STRICT_KERNEL_RWX=y
CONFIG_ARCH_HAS_STRICT_MODULE_RWX=y
CONFIG_ARCH_HAS_REFCOUNT=y
CONFIG_REFCOUNT_FULL=y

#
# GCOV-based kernel profiling
#
# CONFIG_GCOV_KERNEL is not set
CONFIG_ARCH_HAS_GCOV_PROFILE_ALL=y
# CONFIG_HAVE_GENERIC_DMA_COHERENT is not set
CONFIG_RT_MUTEXES=y
CONFIG_BASE_SMALL=0
# CONFIG_MODULES is not set
CONFIG_MODULES_TREE_LOOKUP=y
CONFIG_BLOCK=y
CONFIG_BLK_SCSI_REQUEST=y
CONFIG_BLK_DEV_BSG=y
CONFIG_BLK_DEV_BSGLIB=y
CONFIG_BLK_DEV_INTEGRITY=y
# CONFIG_BLK_DEV_ZONED is not set
CONFIG_BLK_CMDLINE_PARSER=y
CONFIG_BLK_WBT=y
# CONFIG_BLK_WBT_SQ is not set
CONFIG_BLK_WBT_MQ=y
CONFIG_BLK_DEBUG_FS=y
# CONFIG_BLK_SED_OPAL is not set

#
# Partition Types
#
CONFIG_PARTITION_ADVANCED=y
# CONFIG_ACORN_PARTITION is not set
CONFIG_AIX_PARTITION=y
CONFIG_OSF_PARTITION=y
CONFIG_AMIGA_PARTITION=y
CONFIG_ATARI_PARTITION=y
# CONFIG_MAC_PARTITION is not set
CONFIG_MSDOS_PARTITION=y
# CONFIG_BSD_DISKLABEL is not set
CONFIG_MINIX_SUBPARTITION=y
CONFIG_SOLARIS_X86_PARTITION=y
# CONFIG_UNIXWARE_DISKLABEL is not set
# CONFIG_LDM_PARTITION is not set
CONFIG_SGI_PARTITION=y
# CONFIG_ULTRIX_PARTITION is not set
# CONFIG_SUN_PARTITION is not set
# CONFIG_KARMA_PARTITION is not set
CONFIG_EFI_PARTITION=y
CONFIG_SYSV68_PARTITION=y
# CONFIG_CMDLINE_PARTITION is not set
CONFIG_BLK_MQ_PCI=y
CONFIG_BLK_MQ_VIRTIO=y

#
# IO Schedulers
#
CONFIG_IOSCHED_NOOP=y
# CONFIG_IOSCHED_DEADLINE is not set
CONFIG_IOSCHED_CFQ=y
CONFIG_DEFAULT_CFQ=y
# CONFIG_DEFAULT_NOOP is not set
CONFIG_DEFAULT_IOSCHED="cfq"
CONFIG_MQ_IOSCHED_DEADLINE=y
CONFIG_MQ_IOSCHED_KYBER=y
# CONFIG_IOSCHED_BFQ is not set
CONFIG_ASN1=y
CONFIG_UNINLINE_SPIN_UNLOCK=y
CONFIG_ARCH_SUPPORTS_ATOMIC_RMW=y
CONFIG_ARCH_USE_QUEUED_SPINLOCKS=y
CONFIG_ARCH_USE_QUEUED_RWLOCKS=y
CONFIG_FREEZER=y

#
# Processor type and features
#
CONFIG_ZONE_DMA=y
# CONFIG_SMP is not set
CONFIG_X86_FEATURE_NAMES=y
CONFIG_X86_FAST_FEATURE_TESTS=y
# CONFIG_X86_X2APIC is not set
# CONFIG_X86_MPPARSE is not set
CONFIG_GOLDFISH=y
# CONFIG_INTEL_RDT is not set
CONFIG_X86_EXTENDED_PLATFORM=y
# CONFIG_X86_GOLDFISH is not set
# CONFIG_X86_INTEL_MID is not set
# CONFIG_X86_INTEL_LPSS is not set
CONFIG_X86_AMD_PLATFORM_DEVICE=y
CONFIG_IOSF_MBI=y
# CONFIG_IOSF_MBI_DEBUG is not set
# CONFIG_SCHED_OMIT_FRAME_POINTER is not set
CONFIG_HYPERVISOR_GUEST=y
CONFIG_PARAVIRT=y
# CONFIG_PARAVIRT_DEBUG is not set
# CONFIG_XEN is not set
CONFIG_KVM_GUEST=y
# CONFIG_KVM_DEBUG_FS is not set
# CONFIG_PARAVIRT_TIME_ACCOUNTING is not set
CONFIG_PARAVIRT_CLOCK=y
CONFIG_NO_BOOTMEM=y
# CONFIG_MK8 is not set
# CONFIG_MPSC is not set
# CONFIG_MCORE2 is not set
# CONFIG_MATOM is not set
CONFIG_GENERIC_CPU=y
CONFIG_X86_INTERNODE_CACHE_SHIFT=6
CONFIG_X86_L1_CACHE_SHIFT=6
CONFIG_X86_TSC=y
CONFIG_X86_CMPXCHG64=y
CONFIG_X86_CMOV=y
CONFIG_X86_MINIMUM_CPU_FAMILY=64
CONFIG_X86_DEBUGCTLMSR=y
CONFIG_CPU_SUP_INTEL=y
CONFIG_CPU_SUP_AMD=y
CONFIG_CPU_SUP_CENTAUR=y
CONFIG_HPET_TIMER=y
CONFIG_DMI=y
CONFIG_GART_IOMMU=y
# CONFIG_CALGARY_IOMMU is not set
CONFIG_SWIOTLB=y
CONFIG_IOMMU_HELPER=y
CONFIG_NR_CPUS=1
CONFIG_PREEMPT_NONE=y
# CONFIG_PREEMPT_VOLUNTARY is not set
# CONFIG_PREEMPT is not set
CONFIG_PREEMPT_COUNT=y
CONFIG_UP_LATE_INIT=y
CONFIG_X86_LOCAL_APIC=y
CONFIG_X86_IO_APIC=y
# CONFIG_X86_REROUTE_FOR_BROKEN_BOOT_IRQS is not set
# CONFIG_X86_MCE is not set

#
# Performance monitoring
#
# CONFIG_PERF_EVENTS_INTEL_UNCORE is not set
CONFIG_PERF_EVENTS_INTEL_RAPL=y
# CONFIG_PERF_EVENTS_INTEL_CSTATE is not set
# CONFIG_PERF_EVENTS_AMD_POWER is not set
# CONFIG_VM86 is not set
CONFIG_X86_16BIT=y
CONFIG_X86_ESPFIX64=y
CONFIG_X86_VSYSCALL_EMULATION=y
CONFIG_I8K=y
# CONFIG_MICROCODE is not set
# CONFIG_X86_MSR is not set
# CONFIG_X86_CPUID is not set
# CONFIG_X86_5LEVEL is not set
CONFIG_ARCH_PHYS_ADDR_T_64BIT=y
CONFIG_ARCH_DMA_ADDR_T_64BIT=y
CONFIG_ARCH_HAS_MEM_ENCRYPT=y
CONFIG_AMD_MEM_ENCRYPT=y
# CONFIG_AMD_MEM_ENCRYPT_ACTIVE_BY_DEFAULT is not set
CONFIG_ARCH_USE_MEMREMAP_PROT=y
CONFIG_ARCH_SPARSEMEM_ENABLE=y
CONFIG_ARCH_SPARSEMEM_DEFAULT=y
CONFIG_ARCH_SELECT_MEMORY_MODEL=y
CONFIG_ILLEGAL_POINTER_VALUE=0xdead000000000000
CONFIG_SELECT_MEMORY_MODEL=y
CONFIG_SPARSEMEM_MANUAL=y
CONFIG_SPARSEMEM=y
CONFIG_HAVE_MEMORY_PRESENT=y
CONFIG_SPARSEMEM_EXTREME=y
CONFIG_SPARSEMEM_VMEMMAP_ENABLE=y
CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER=y
# CONFIG_SPARSEMEM_VMEMMAP is not set
CONFIG_HAVE_MEMBLOCK=y
CONFIG_HAVE_MEMBLOCK_NODE_MAP=y
CONFIG_HAVE_GENERIC_GUP=y
CONFIG_ARCH_DISCARD_MEMBLOCK=y
# CONFIG_HAVE_BOOTMEM_INFO_NODE is not set
# CONFIG_MEMORY_HOTPLUG is not set
CONFIG_SPLIT_PTLOCK_CPUS=4
CONFIG_ARCH_ENABLE_SPLIT_PMD_PTLOCK=y
CONFIG_COMPACTION=y
CONFIG_MIGRATION=y
CONFIG_ARCH_ENABLE_HUGEPAGE_MIGRATION=y
CONFIG_PHYS_ADDR_T_64BIT=y
CONFIG_BOUNCE=y
CONFIG_VIRT_TO_BUS=y
CONFIG_MMU_NOTIFIER=y
CONFIG_KSM=y
CONFIG_DEFAULT_MMAP_MIN_ADDR=4096
# CONFIG_TRANSPARENT_HUGEPAGE is not set
CONFIG_ARCH_WANTS_THP_SWAP=y
CONFIG_NEED_PER_CPU_KM=y
CONFIG_CLEANCACHE=y
# CONFIG_CMA is not set
CONFIG_ZPOOL=y
# CONFIG_ZBUD is not set
# CONFIG_Z3FOLD is not set
CONFIG_ZSMALLOC=y
CONFIG_PGTABLE_MAPPING=y
# CONFIG_ZSMALLOC_STAT is not set
CONFIG_GENERIC_EARLY_IOREMAP=y
CONFIG_ARCH_SUPPORTS_DEFERRED_STRUCT_PAGE_INIT=y
CONFIG_IDLE_PAGE_TRACKING=y
CONFIG_ARCH_HAS_ZONE_DEVICE=y
CONFIG_FRAME_VECTOR=y
# CONFIG_PERCPU_STATS is not set
# CONFIG_X86_PMEM_LEGACY is not set
CONFIG_X86_CHECK_BIOS_CORRUPTION=y
# CONFIG_X86_BOOTPARAM_MEMORY_CORRUPTION_CHECK is not set
CONFIG_X86_RESERVE_LOW=64
CONFIG_MTRR=y
CONFIG_MTRR_SANITIZER=y
CONFIG_MTRR_SANITIZER_ENABLE_DEFAULT=0
CONFIG_MTRR_SANITIZER_SPARE_REG_NR_DEFAULT=1
CONFIG_X86_PAT=y
CONFIG_ARCH_USES_PG_UNCACHED=y
CONFIG_ARCH_RANDOM=y
CONFIG_X86_SMAP=y
# CONFIG_X86_INTEL_UMIP is not set
# CONFIG_X86_INTEL_MPX is not set
# CONFIG_X86_INTEL_MEMORY_PROTECTION_KEYS is not set
# CONFIG_EFI is not set
# CONFIG_SECCOMP is not set
# CONFIG_HZ_100 is not set
# CONFIG_HZ_250 is not set
# CONFIG_HZ_300 is not set
CONFIG_HZ_1000=y
CONFIG_HZ=1000
# CONFIG_SCHED_HRTICK is not set
CONFIG_KEXEC=y
CONFIG_KEXEC_FILE=y
# CONFIG_KEXEC_VERIFY_SIG is not set
# CONFIG_CRASH_DUMP is not set
CONFIG_PHYSICAL_START=0x1000000
CONFIG_RELOCATABLE=y
# CONFIG_RANDOMIZE_BASE is not set
CONFIG_PHYSICAL_ALIGN=0x200000
# CONFIG_LEGACY_VSYSCALL_NATIVE is not set
CONFIG_LEGACY_VSYSCALL_EMULATE=y
# CONFIG_LEGACY_VSYSCALL_NONE is not set
# CONFIG_CMDLINE_BOOL is not set
CONFIG_MODIFY_LDT_SYSCALL=y
CONFIG_HAVE_LIVEPATCH=y
CONFIG_ARCH_HAS_ADD_PAGES=y
CONFIG_ARCH_ENABLE_MEMORY_HOTPLUG=y

#
# Power management and ACPI options
#
CONFIG_SUSPEND=y
CONFIG_SUSPEND_FREEZER=y
CONFIG_PM_SLEEP=y
CONFIG_PM_AUTOSLEEP=y
# CONFIG_PM_WAKELOCKS is not set
CONFIG_PM=y
# CONFIG_PM_DEBUG is not set
CONFIG_PM_CLK=y
CONFIG_WQ_POWER_EFFICIENT_DEFAULT=y
CONFIG_ACPI=y
CONFIG_ACPI_LEGACY_TABLES_LOOKUP=y
CONFIG_ARCH_MIGHT_HAVE_ACPI_PDC=y
CONFIG_ACPI_SYSTEM_POWER_STATES_SUPPORT=y
CONFIG_ACPI_DEBUGGER=y
CONFIG_ACPI_DEBUGGER_USER=y
CONFIG_ACPI_LPIT=y
CONFIG_ACPI_SLEEP=y
CONFIG_ACPI_PROCFS_POWER=y
CONFIG_ACPI_REV_OVERRIDE_POSSIBLE=y
CONFIG_ACPI_EC_DEBUGFS=y
CONFIG_ACPI_AC=y
# CONFIG_ACPI_BATTERY is not set
CONFIG_ACPI_BUTTON=y
CONFIG_ACPI_VIDEO=y
# CONFIG_ACPI_FAN is not set
# CONFIG_ACPI_DOCK is not set
CONFIG_ACPI_CPU_FREQ_PSS=y
CONFIG_ACPI_PROCESSOR_CSTATE=y
CONFIG_ACPI_PROCESSOR_IDLE=y
CONFIG_ACPI_PROCESSOR=y
CONFIG_ACPI_PROCESSOR_AGGREGATOR=y
CONFIG_ACPI_THERMAL=y
# CONFIG_ACPI_CUSTOM_DSDT is not set
CONFIG_ARCH_HAS_ACPI_TABLE_UPGRADE=y
CONFIG_ACPI_TABLE_UPGRADE=y
CONFIG_ACPI_DEBUG=y
# CONFIG_ACPI_PCI_SLOT is not set
CONFIG_X86_PM_TIMER=y
# CONFIG_ACPI_CONTAINER is not set
CONFIG_ACPI_HOTPLUG_IOAPIC=y
CONFIG_ACPI_SBS=y
CONFIG_ACPI_HED=y
CONFIG_ACPI_CUSTOM_METHOD=y
# CONFIG_ACPI_REDUCED_HARDWARE_ONLY is not set
# CONFIG_ACPI_NFIT is not set
CONFIG_HAVE_ACPI_APEI=y
CONFIG_HAVE_ACPI_APEI_NMI=y
# CONFIG_ACPI_APEI is not set
CONFIG_DPTF_POWER=y
CONFIG_ACPI_WATCHDOG=y
# CONFIG_PMIC_OPREGION is not set
CONFIG_ACPI_CONFIGFS=y
# CONFIG_SFI is not set

#
# CPU Frequency scaling
#
CONFIG_CPU_FREQ=y
CONFIG_CPU_FREQ_GOV_ATTR_SET=y
CONFIG_CPU_FREQ_GOV_COMMON=y
# CONFIG_CPU_FREQ_STAT is not set
CONFIG_CPU_FREQ_DEFAULT_GOV_PERFORMANCE=y
# CONFIG_CPU_FREQ_DEFAULT_GOV_POWERSAVE is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_USERSPACE is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_ONDEMAND is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_CONSERVATIVE is not set
CONFIG_CPU_FREQ_GOV_PERFORMANCE=y
CONFIG_CPU_FREQ_GOV_POWERSAVE=y
CONFIG_CPU_FREQ_GOV_USERSPACE=y
CONFIG_CPU_FREQ_GOV_ONDEMAND=y
CONFIG_CPU_FREQ_GOV_CONSERVATIVE=y

#
# CPU frequency scaling drivers
#
CONFIG_X86_INTEL_PSTATE=y
CONFIG_X86_PCC_CPUFREQ=y
# CONFIG_X86_ACPI_CPUFREQ is not set
# CONFIG_X86_SPEEDSTEP_CENTRINO is not set
CONFIG_X86_P4_CLOCKMOD=y

#
# shared options
#
CONFIG_X86_SPEEDSTEP_LIB=y

#
# CPU Idle
#
CONFIG_CPU_IDLE=y
# CONFIG_CPU_IDLE_GOV_LADDER is not set
CONFIG_CPU_IDLE_GOV_MENU=y
# CONFIG_ARCH_NEEDS_CPU_IDLE_COUPLED is not set
# CONFIG_INTEL_IDLE is not set

#
# Bus options (PCI etc.)
#
CONFIG_PCI=y
CONFIG_PCI_DIRECT=y
CONFIG_PCI_MMCONFIG=y
CONFIG_PCI_DOMAINS=y
CONFIG_PCIEPORTBUS=y
# CONFIG_HOTPLUG_PCI_PCIE is not set
CONFIG_PCIEAER=y
CONFIG_PCIE_ECRC=y
CONFIG_PCIEAER_INJECT=y
CONFIG_PCIEASPM=y
# CONFIG_PCIEASPM_DEBUG is not set
CONFIG_PCIEASPM_DEFAULT=y
# CONFIG_PCIEASPM_POWERSAVE is not set
# CONFIG_PCIEASPM_POWER_SUPERSAVE is not set
# CONFIG_PCIEASPM_PERFORMANCE is not set
CONFIG_PCIE_PME=y
# CONFIG_PCIE_DPC is not set
# CONFIG_PCIE_PTM is not set
CONFIG_PCI_BUS_ADDR_T_64BIT=y
# CONFIG_PCI_MSI is not set
# CONFIG_PCI_DEBUG is not set
# CONFIG_PCI_REALLOC_ENABLE_AUTO is not set
# CONFIG_PCI_STUB is not set
CONFIG_HT_IRQ=y
CONFIG_PCI_ATS=y
CONFIG_PCI_LOCKLESS_CONFIG=y
# CONFIG_PCI_IOV is not set
# CONFIG_PCI_PRI is not set
CONFIG_PCI_PASID=y
CONFIG_PCI_LABEL=y
CONFIG_HOTPLUG_PCI=y
CONFIG_HOTPLUG_PCI_ACPI=y
# CONFIG_HOTPLUG_PCI_ACPI_IBM is not set
# CONFIG_HOTPLUG_PCI_CPCI is not set
CONFIG_HOTPLUG_PCI_SHPC=y

#
# DesignWare PCI Core Support
#

#
# PCI host controller drivers
#

#
# PCI Endpoint
#
# CONFIG_PCI_ENDPOINT is not set

#
# PCI switch controller drivers
#
CONFIG_PCI_SW_SWITCHTEC=y
CONFIG_ISA_DMA_API=y
CONFIG_AMD_NB=y
CONFIG_PCCARD=y
# CONFIG_PCMCIA is not set
# CONFIG_CARDBUS is not set

#
# PC-card bridges
#
# CONFIG_YENTA is not set
CONFIG_RAPIDIO=y
# CONFIG_RAPIDIO_TSI721 is not set
CONFIG_RAPIDIO_DISC_TIMEOUT=30
CONFIG_RAPIDIO_ENABLE_RX_TX_PORTS=y
# CONFIG_RAPIDIO_DMA_ENGINE is not set
CONFIG_RAPIDIO_DEBUG=y
CONFIG_RAPIDIO_ENUM_BASIC=y
CONFIG_RAPIDIO_CHMAN=y
# CONFIG_RAPIDIO_MPORT_CDEV is not set

#
# RapidIO Switch drivers
#
CONFIG_RAPIDIO_TSI57X=y
CONFIG_RAPIDIO_CPS_XX=y
CONFIG_RAPIDIO_TSI568=y
CONFIG_RAPIDIO_CPS_GEN2=y
CONFIG_RAPIDIO_RXS_GEN3=y
# CONFIG_X86_SYSFB is not set

#
# Executable file formats / Emulations
#
CONFIG_BINFMT_ELF=y
CONFIG_ELFCORE=y
CONFIG_CORE_DUMP_DEFAULT_ELF_HEADERS=y
CONFIG_BINFMT_SCRIPT=y
# CONFIG_HAVE_AOUT is not set
CONFIG_BINFMT_MISC=y
CONFIG_COREDUMP=y
# CONFIG_IA32_EMULATION is not set
# CONFIG_X86_X32 is not set
CONFIG_X86_DEV_DMA_OPS=y
CONFIG_NET=y

#
# Networking options
#
# CONFIG_PACKET is not set
CONFIG_UNIX=y
# CONFIG_UNIX_DIAG is not set
# CONFIG_TLS is not set
CONFIG_XFRM=y
# CONFIG_XFRM_USER is not set
# CONFIG_XFRM_SUB_POLICY is not set
# CONFIG_XFRM_MIGRATE is not set
# CONFIG_XFRM_STATISTICS is not set
# CONFIG_NET_KEY is not set
CONFIG_INET=y
# CONFIG_IP_MULTICAST is not set
# CONFIG_IP_ADVANCED_ROUTER is not set
CONFIG_IP_PNP=y
CONFIG_IP_PNP_DHCP=y
# CONFIG_IP_PNP_BOOTP is not set
# CONFIG_IP_PNP_RARP is not set
# CONFIG_NET_IPIP is not set
# CONFIG_NET_IPGRE_DEMUX is not set
CONFIG_NET_IP_TUNNEL=y
# CONFIG_SYN_COOKIES is not set
# CONFIG_NET_IPVTI is not set
# CONFIG_NET_UDP_TUNNEL is not set
# CONFIG_NET_FOU is not set
# CONFIG_NET_FOU_IP_TUNNELS is not set
# CONFIG_INET_AH is not set
# CONFIG_INET_ESP is not set
# CONFIG_INET_IPCOMP is not set
# CONFIG_INET_XFRM_TUNNEL is not set
CONFIG_INET_TUNNEL=y
CONFIG_INET_XFRM_MODE_TRANSPORT=y
CONFIG_INET_XFRM_MODE_TUNNEL=y
CONFIG_INET_XFRM_MODE_BEET=y
CONFIG_INET_DIAG=y
CONFIG_INET_TCP_DIAG=y
# CONFIG_INET_UDP_DIAG is not set
# CONFIG_INET_RAW_DIAG is not set
# CONFIG_INET_DIAG_DESTROY is not set
# CONFIG_TCP_CONG_ADVANCED is not set
CONFIG_TCP_CONG_CUBIC=y
CONFIG_DEFAULT_TCP_CONG="cubic"
# CONFIG_TCP_MD5SIG is not set
CONFIG_IPV6=y
# CONFIG_IPV6_ROUTER_PREF is not set
# CONFIG_IPV6_OPTIMISTIC_DAD is not set
# CONFIG_INET6_AH is not set
# CONFIG_INET6_ESP is not set
# CONFIG_INET6_IPCOMP is not set
# CONFIG_IPV6_MIP6 is not set
# CONFIG_INET6_XFRM_TUNNEL is not set
# CONFIG_INET6_TUNNEL is not set
CONFIG_INET6_XFRM_MODE_TRANSPORT=y
CONFIG_INET6_XFRM_MODE_TUNNEL=y
CONFIG_INET6_XFRM_MODE_BEET=y
# CONFIG_INET6_XFRM_MODE_ROUTEOPTIMIZATION is not set
# CONFIG_IPV6_VTI is not set
CONFIG_IPV6_SIT=y
# CONFIG_IPV6_SIT_6RD is not set
CONFIG_IPV6_NDISC_NODETYPE=y
# CONFIG_IPV6_TUNNEL is not set
# CONFIG_IPV6_FOU is not set
# CONFIG_IPV6_FOU_TUNNEL is not set
# CONFIG_IPV6_MULTIPLE_TABLES is not set
# CONFIG_IPV6_MROUTE is not set
# CONFIG_IPV6_SEG6_LWTUNNEL is not set
# CONFIG_IPV6_SEG6_HMAC is not set
# CONFIG_NETLABEL is not set
# CONFIG_NETWORK_SECMARK is not set
CONFIG_NET_PTP_CLASSIFY=y
# CONFIG_NETWORK_PHY_TIMESTAMPING is not set
# CONFIG_NETFILTER is not set
# CONFIG_IP_DCCP is not set
# CONFIG_IP_SCTP is not set
# CONFIG_RDS is not set
# CONFIG_TIPC is not set
# CONFIG_ATM is not set
# CONFIG_L2TP is not set
# CONFIG_BRIDGE is not set
CONFIG_HAVE_NET_DSA=y
# CONFIG_NET_DSA is not set
# CONFIG_VLAN_8021Q is not set
# CONFIG_DECNET is not set
# CONFIG_LLC2 is not set
# CONFIG_IPX is not set
# CONFIG_ATALK is not set
# CONFIG_X25 is not set
# CONFIG_LAPB is not set
# CONFIG_PHONET is not set
# CONFIG_6LOWPAN is not set
# CONFIG_IEEE802154 is not set
# CONFIG_NET_SCHED is not set
# CONFIG_DCB is not set
CONFIG_DNS_RESOLVER=y
# CONFIG_BATMAN_ADV is not set
# CONFIG_OPENVSWITCH is not set
# CONFIG_VSOCKETS is not set
# CONFIG_NETLINK_DIAG is not set
# CONFIG_MPLS is not set
# CONFIG_NET_NSH is not set
# CONFIG_HSR is not set
# CONFIG_NET_SWITCHDEV is not set
# CONFIG_NET_L3_MASTER_DEV is not set
# CONFIG_NET_NCSI is not set
# CONFIG_CGROUP_NET_PRIO is not set
# CONFIG_CGROUP_NET_CLASSID is not set
CONFIG_NET_RX_BUSY_POLL=y
CONFIG_BQL=y

#
# Network testing
#
# CONFIG_NET_PKTGEN is not set
# CONFIG_HAMRADIO is not set
# CONFIG_CAN is not set
# CONFIG_BT is not set
# CONFIG_AF_RXRPC is not set
# CONFIG_AF_KCM is not set
# CONFIG_STREAM_PARSER is not set
CONFIG_WIRELESS=y
# CONFIG_CFG80211 is not set
# CONFIG_LIB80211 is not set

#
# CFG80211 needs to be enabled for MAC80211
#
CONFIG_MAC80211_STA_HASH_MAX_SIZE=0
# CONFIG_WIMAX is not set
# CONFIG_RFKILL is not set
CONFIG_NET_9P=y
CONFIG_NET_9P_VIRTIO=y
# CONFIG_NET_9P_DEBUG is not set
# CONFIG_CAIF is not set
# CONFIG_CEPH_LIB is not set
# CONFIG_NFC is not set
# CONFIG_PSAMPLE is not set
# CONFIG_NET_IFE is not set
# CONFIG_LWTUNNEL is not set
CONFIG_DST_CACHE=y
CONFIG_GRO_CELLS=y
# CONFIG_NET_DEVLINK is not set
CONFIG_MAY_USE_DEVLINK=y
CONFIG_HAVE_EBPF_JIT=y

#
# Device Drivers
#

#
# Generic Driver Options
#
CONFIG_UEVENT_HELPER=y
CONFIG_UEVENT_HELPER_PATH=""
CONFIG_DEVTMPFS=y
# CONFIG_DEVTMPFS_MOUNT is not set
CONFIG_STANDALONE=y
# CONFIG_PREVENT_FIRMWARE_BUILD is not set
CONFIG_FW_LOADER=y
CONFIG_FIRMWARE_IN_KERNEL=y
CONFIG_EXTRA_FIRMWARE=""
CONFIG_FW_LOADER_USER_HELPER=y
# CONFIG_FW_LOADER_USER_HELPER_FALLBACK is not set
CONFIG_ALLOW_DEV_COREDUMP=y
# CONFIG_DEBUG_DRIVER is not set
CONFIG_DEBUG_DEVRES=y
# CONFIG_DEBUG_TEST_DRIVER_REMOVE is not set
# CONFIG_SYS_HYPERVISOR is not set
# CONFIG_GENERIC_CPU_DEVICES is not set
CONFIG_GENERIC_CPU_AUTOPROBE=y
CONFIG_REGMAP=y
CONFIG_REGMAP_I2C=y
CONFIG_REGMAP_SPI=y
CONFIG_REGMAP_W1=y
CONFIG_REGMAP_MMIO=y
CONFIG_REGMAP_IRQ=y
CONFIG_DMA_SHARED_BUFFER=y
# CONFIG_DMA_FENCE_TRACE is not set

#
# Bus devices
#
# CONFIG_CONNECTOR is not set
CONFIG_MTD=y
# CONFIG_MTD_REDBOOT_PARTS is not set
# CONFIG_MTD_CMDLINE_PARTS is not set
CONFIG_MTD_AR7_PARTS=y

#
# Partition parsers
#

#
# User Modules And Translation Layers
#
CONFIG_MTD_BLKDEVS=y
# CONFIG_MTD_BLOCK is not set
CONFIG_MTD_BLOCK_RO=y
CONFIG_FTL=y
CONFIG_NFTL=y
CONFIG_NFTL_RW=y
CONFIG_INFTL=y
CONFIG_RFD_FTL=y
CONFIG_SSFDC=y
# CONFIG_SM_FTL is not set
CONFIG_MTD_OOPS=y
# CONFIG_MTD_PARTITIONED_MASTER is not set

#
# RAM/ROM/Flash chip drivers
#
CONFIG_MTD_CFI=y
# CONFIG_MTD_JEDECPROBE is not set
CONFIG_MTD_GEN_PROBE=y
# CONFIG_MTD_CFI_ADV_OPTIONS is not set
CONFIG_MTD_MAP_BANK_WIDTH_1=y
CONFIG_MTD_MAP_BANK_WIDTH_2=y
CONFIG_MTD_MAP_BANK_WIDTH_4=y
# CONFIG_MTD_MAP_BANK_WIDTH_8 is not set
# CONFIG_MTD_MAP_BANK_WIDTH_16 is not set
# CONFIG_MTD_MAP_BANK_WIDTH_32 is not set
CONFIG_MTD_CFI_I1=y
CONFIG_MTD_CFI_I2=y
# CONFIG_MTD_CFI_I4 is not set
# CONFIG_MTD_CFI_I8 is not set
CONFIG_MTD_CFI_INTELEXT=y
# CONFIG_MTD_CFI_AMDSTD is not set
CONFIG_MTD_CFI_STAA=y
CONFIG_MTD_CFI_UTIL=y
# CONFIG_MTD_RAM is not set
CONFIG_MTD_ROM=y
CONFIG_MTD_ABSENT=y

#
# Mapping drivers for chip access
#
CONFIG_MTD_COMPLEX_MAPPINGS=y
# CONFIG_MTD_PHYSMAP is not set
CONFIG_MTD_SBC_GXX=y
# CONFIG_MTD_PCI is not set
CONFIG_MTD_GPIO_ADDR=y
# CONFIG_MTD_INTEL_VR_NOR is not set
# CONFIG_MTD_PLATRAM is not set
CONFIG_MTD_LATCH_ADDR=y

#
# Self-contained MTD device drivers
#
CONFIG_MTD_PMC551=y
CONFIG_MTD_PMC551_BUGFIX=y
CONFIG_MTD_PMC551_DEBUG=y
CONFIG_MTD_DATAFLASH=y
# CONFIG_MTD_DATAFLASH_WRITE_VERIFY is not set
# CONFIG_MTD_DATAFLASH_OTP is not set
# CONFIG_MTD_MCHP23K256 is not set
CONFIG_MTD_SST25L=y
CONFIG_MTD_SLRAM=y
# CONFIG_MTD_PHRAM is not set
# CONFIG_MTD_MTDRAM is not set
CONFIG_MTD_BLOCK2MTD=y

#
# Disk-On-Chip Device Drivers
#
# CONFIG_MTD_DOCG3 is not set
# CONFIG_MTD_NAND is not set
# CONFIG_MTD_ONENAND is not set

#
# LPDDR & LPDDR2 PCM memory drivers
#
CONFIG_MTD_LPDDR=y
CONFIG_MTD_QINFO_PROBE=y
# CONFIG_MTD_SPI_NOR is not set
CONFIG_MTD_UBI=y
CONFIG_MTD_UBI_WL_THRESHOLD=4096
CONFIG_MTD_UBI_BEB_LIMIT=20
# CONFIG_MTD_UBI_FASTMAP is not set
CONFIG_MTD_UBI_GLUEBI=y
# CONFIG_MTD_UBI_BLOCK is not set
# CONFIG_OF is not set
CONFIG_ARCH_MIGHT_HAVE_PC_PARPORT=y
CONFIG_PARPORT=y
CONFIG_PARPORT_PC=y
CONFIG_PARPORT_PC_FIFO=y
CONFIG_PARPORT_PC_SUPERIO=y
# CONFIG_PARPORT_GSC is not set
# CONFIG_PARPORT_AX88796 is not set
CONFIG_PARPORT_1284=y
CONFIG_PARPORT_NOT_PC=y
CONFIG_PNP=y
CONFIG_PNP_DEBUG_MESSAGES=y

#
# Protocols
#
CONFIG_PNPACPI=y
CONFIG_BLK_DEV=y
# CONFIG_BLK_DEV_NULL_BLK is not set
# CONFIG_BLK_DEV_FD is not set
# CONFIG_PARIDE is not set
# CONFIG_BLK_DEV_PCIESSD_MTIP32XX is not set
# CONFIG_ZRAM is not set
# CONFIG_BLK_DEV_DAC960 is not set
# CONFIG_BLK_DEV_UMEM is not set
# CONFIG_BLK_DEV_COW_COMMON is not set
# CONFIG_BLK_DEV_LOOP is not set
# CONFIG_BLK_DEV_DRBD is not set
# CONFIG_BLK_DEV_NBD is not set
# CONFIG_BLK_DEV_SKD is not set
# CONFIG_BLK_DEV_SX8 is not set
# CONFIG_BLK_DEV_RAM is not set
# CONFIG_CDROM_PKTCDVD is not set
# CONFIG_ATA_OVER_ETH is not set
# CONFIG_VIRTIO_BLK is not set
# CONFIG_BLK_DEV_RBD is not set
# CONFIG_BLK_DEV_RSXX is not set

#
# NVME Support
#
CONFIG_NVME_CORE=y
CONFIG_BLK_DEV_NVME=y
# CONFIG_NVME_MULTIPATH is not set
CONFIG_NVME_FABRICS=y
CONFIG_NVME_FC=y
# CONFIG_NVME_TARGET is not set

#
# Misc devices
#
CONFIG_SENSORS_LIS3LV02D=y
CONFIG_AD525X_DPOT=y
CONFIG_AD525X_DPOT_I2C=y
CONFIG_AD525X_DPOT_SPI=y
CONFIG_DUMMY_IRQ=y
CONFIG_IBM_ASM=y
# CONFIG_PHANTOM is not set
# CONFIG_SGI_IOC4 is not set
CONFIG_TIFM_CORE=y
CONFIG_TIFM_7XX1=y
CONFIG_ICS932S401=y
CONFIG_ENCLOSURE_SERVICES=y
CONFIG_HP_ILO=y
CONFIG_APDS9802ALS=y
CONFIG_ISL29003=y
# CONFIG_ISL29020 is not set
CONFIG_SENSORS_TSL2550=y
CONFIG_SENSORS_BH1770=y
CONFIG_SENSORS_APDS990X=y
CONFIG_HMC6352=y
# CONFIG_DS1682 is not set
CONFIG_USB_SWITCH_FSA9480=y
CONFIG_LATTICE_ECP3_CONFIG=y
# CONFIG_SRAM is not set
CONFIG_PCI_ENDPOINT_TEST=y
# CONFIG_C2PORT is not set

#
# EEPROM support
#
# CONFIG_EEPROM_AT24 is not set
# CONFIG_EEPROM_AT25 is not set
CONFIG_EEPROM_LEGACY=y
CONFIG_EEPROM_MAX6875=y
CONFIG_EEPROM_93CX6=y
# CONFIG_EEPROM_93XX46 is not set
# CONFIG_EEPROM_IDT_89HPESX is not set
CONFIG_CB710_CORE=y
# CONFIG_CB710_DEBUG is not set
CONFIG_CB710_DEBUG_ASSUMPTIONS=y

#
# Texas Instruments shared transport line discipline
#
# CONFIG_TI_ST is not set
CONFIG_SENSORS_LIS3_I2C=y

#
# Altera FPGA firmware download module
#
CONFIG_ALTERA_STAPL=y
CONFIG_INTEL_MEI=y
CONFIG_INTEL_MEI_ME=y
CONFIG_INTEL_MEI_TXE=y
# CONFIG_VMWARE_VMCI is not set

#
# Intel MIC Bus Driver
#
# CONFIG_INTEL_MIC_BUS is not set

#
# SCIF Bus Driver
#
CONFIG_SCIF_BUS=y

#
# VOP Bus Driver
#
# CONFIG_VOP_BUS is not set

#
# Intel MIC Host Driver
#

#
# Intel MIC Card Driver
#

#
# SCIF Driver
#

#
# Intel MIC Coprocessor State Management (COSM) Drivers
#

#
# VOP Driver
#
CONFIG_GENWQE=y
CONFIG_GENWQE_PLATFORM_ERROR_RECOVERY=0
CONFIG_ECHO=y
# CONFIG_CXL_BASE is not set
# CONFIG_CXL_AFU_DRIVER_OPS is not set
# CONFIG_CXL_LIB is not set
CONFIG_HAVE_IDE=y
CONFIG_IDE=y

#
# Please see Documentation/ide/ide.txt for help/info on IDE drives
#
CONFIG_IDE_XFER_MODE=y
CONFIG_IDE_TIMINGS=y
CONFIG_IDE_ATAPI=y
CONFIG_BLK_DEV_IDE_SATA=y
CONFIG_IDE_GD=y
# CONFIG_IDE_GD_ATA is not set
# CONFIG_IDE_GD_ATAPI is not set
# CONFIG_BLK_DEV_IDECD is not set
CONFIG_BLK_DEV_IDETAPE=y
# CONFIG_BLK_DEV_IDEACPI is not set
CONFIG_IDE_TASK_IOCTL=y
# CONFIG_IDE_PROC_FS is not set

#
# IDE chipset support/bugfixes
#
# CONFIG_IDE_GENERIC is not set
# CONFIG_BLK_DEV_PLATFORM is not set
CONFIG_BLK_DEV_CMD640=y
# CONFIG_BLK_DEV_CMD640_ENHANCED is not set
CONFIG_BLK_DEV_IDEPNP=y
CONFIG_BLK_DEV_IDEDMA_SFF=y

#
# PCI IDE chipsets support
#
CONFIG_BLK_DEV_IDEPCI=y
# CONFIG_IDEPCI_PCIBUS_ORDER is not set
# CONFIG_BLK_DEV_OFFBOARD is not set
CONFIG_BLK_DEV_GENERIC=y
# CONFIG_BLK_DEV_OPTI621 is not set
# CONFIG_BLK_DEV_RZ1000 is not set
CONFIG_BLK_DEV_IDEDMA_PCI=y
CONFIG_BLK_DEV_AEC62XX=y
# CONFIG_BLK_DEV_ALI15X3 is not set
CONFIG_BLK_DEV_AMD74XX=y
CONFIG_BLK_DEV_ATIIXP=y
CONFIG_BLK_DEV_CMD64X=y
CONFIG_BLK_DEV_TRIFLEX=y
CONFIG_BLK_DEV_HPT366=y
CONFIG_BLK_DEV_JMICRON=y
CONFIG_BLK_DEV_PIIX=y
CONFIG_BLK_DEV_IT8172=y
CONFIG_BLK_DEV_IT8213=y
CONFIG_BLK_DEV_IT821X=y
CONFIG_BLK_DEV_NS87415=y
CONFIG_BLK_DEV_PDC202XX_OLD=y
CONFIG_BLK_DEV_PDC202XX_NEW=y
CONFIG_BLK_DEV_SVWKS=y
CONFIG_BLK_DEV_SIIMAGE=y
# CONFIG_BLK_DEV_SIS5513 is not set
CONFIG_BLK_DEV_SLC90E66=y
CONFIG_BLK_DEV_TRM290=y
CONFIG_BLK_DEV_VIA82CXXX=y
CONFIG_BLK_DEV_TC86C001=y
CONFIG_BLK_DEV_IDEDMA=y

#
# SCSI device support
#
CONFIG_SCSI_MOD=y
CONFIG_RAID_ATTRS=y
CONFIG_SCSI=y
CONFIG_SCSI_DMA=y
# CONFIG_SCSI_NETLINK is not set
# CONFIG_SCSI_MQ_DEFAULT is not set
# CONFIG_SCSI_PROC_FS is not set

#
# SCSI support type (disk, tape, CD-ROM)
#
# CONFIG_BLK_DEV_SD is not set
CONFIG_CHR_DEV_ST=y
CONFIG_CHR_DEV_OSST=y
# CONFIG_BLK_DEV_SR is not set
CONFIG_CHR_DEV_SG=y
CONFIG_CHR_DEV_SCH=y
CONFIG_SCSI_ENCLOSURE=y
# CONFIG_SCSI_CONSTANTS is not set
CONFIG_SCSI_LOGGING=y
# CONFIG_SCSI_SCAN_ASYNC is not set

#
# SCSI Transports
#
CONFIG_SCSI_SPI_ATTRS=y
# CONFIG_SCSI_FC_ATTRS is not set
# CONFIG_SCSI_ISCSI_ATTRS is not set
CONFIG_SCSI_SAS_ATTRS=y
CONFIG_SCSI_SAS_LIBSAS=y
# CONFIG_SCSI_SAS_HOST_SMP is not set
CONFIG_SCSI_SRP_ATTRS=y
CONFIG_SCSI_LOWLEVEL=y
# CONFIG_ISCSI_TCP is not set
CONFIG_ISCSI_BOOT_SYSFS=y
# CONFIG_SCSI_CXGB3_ISCSI is not set
# CONFIG_SCSI_CXGB4_ISCSI is not set
# CONFIG_SCSI_BNX2_ISCSI is not set
# CONFIG_BE2ISCSI is not set
CONFIG_BLK_DEV_3W_XXXX_RAID=y
# CONFIG_SCSI_HPSA is not set
# CONFIG_SCSI_3W_9XXX is not set
CONFIG_SCSI_3W_SAS=y
CONFIG_SCSI_ACARD=y
# CONFIG_SCSI_AACRAID is not set
CONFIG_SCSI_AIC7XXX=y
CONFIG_AIC7XXX_CMDS_PER_DEVICE=32
CONFIG_AIC7XXX_RESET_DELAY_MS=5000
# CONFIG_AIC7XXX_BUILD_FIRMWARE is not set
# CONFIG_AIC7XXX_DEBUG_ENABLE is not set
CONFIG_AIC7XXX_DEBUG_MASK=0
# CONFIG_AIC7XXX_REG_PRETTY_PRINT is not set
# CONFIG_SCSI_AIC79XX is not set
CONFIG_SCSI_AIC94XX=y
# CONFIG_AIC94XX_DEBUG is not set
CONFIG_SCSI_MVSAS=y
# CONFIG_SCSI_MVSAS_DEBUG is not set
# CONFIG_SCSI_MVSAS_TASKLET is not set
# CONFIG_SCSI_MVUMI is not set
# CONFIG_SCSI_DPT_I2O is not set
CONFIG_SCSI_ADVANSYS=y
CONFIG_SCSI_ARCMSR=y
CONFIG_SCSI_ESAS2R=y
CONFIG_MEGARAID_NEWGEN=y
# CONFIG_MEGARAID_MM is not set
CONFIG_MEGARAID_LEGACY=y
CONFIG_MEGARAID_SAS=y
CONFIG_SCSI_MPT3SAS=y
CONFIG_SCSI_MPT2SAS_MAX_SGE=128
CONFIG_SCSI_MPT3SAS_MAX_SGE=128
CONFIG_SCSI_MPT2SAS=y
CONFIG_SCSI_SMARTPQI=y
# CONFIG_SCSI_UFSHCD is not set
# CONFIG_SCSI_HPTIOP is not set
CONFIG_SCSI_BUSLOGIC=y
# CONFIG_SCSI_FLASHPOINT is not set
CONFIG_VMWARE_PVSCSI=y
CONFIG_SCSI_SNIC=y
# CONFIG_SCSI_SNIC_DEBUG_FS is not set
# CONFIG_SCSI_DMX3191D is not set
# CONFIG_SCSI_EATA is not set
# CONFIG_SCSI_FUTURE_DOMAIN is not set
# CONFIG_SCSI_GDTH is not set
CONFIG_SCSI_ISCI=y
CONFIG_SCSI_IPS=y
# CONFIG_SCSI_INITIO is not set
CONFIG_SCSI_INIA100=y
# CONFIG_SCSI_PPA is not set
# CONFIG_SCSI_IMM is not set
# CONFIG_SCSI_STEX is not set
CONFIG_SCSI_SYM53C8XX_2=y
CONFIG_SCSI_SYM53C8XX_DMA_ADDRESSING_MODE=1
CONFIG_SCSI_SYM53C8XX_DEFAULT_TAGS=16
CONFIG_SCSI_SYM53C8XX_MAX_TAGS=64
# CONFIG_SCSI_SYM53C8XX_MMIO is not set
CONFIG_SCSI_QLOGIC_1280=y
# CONFIG_SCSI_QLA_ISCSI is not set
CONFIG_SCSI_DC395x=y
# CONFIG_SCSI_AM53C974 is not set
CONFIG_SCSI_WD719X=y
CONFIG_SCSI_DEBUG=y
# CONFIG_SCSI_PMCRAID is not set
CONFIG_SCSI_PM8001=y
# CONFIG_SCSI_VIRTIO is not set
CONFIG_SCSI_DH=y
CONFIG_SCSI_DH_RDAC=y
CONFIG_SCSI_DH_HP_SW=y
CONFIG_SCSI_DH_EMC=y
# CONFIG_SCSI_DH_ALUA is not set
CONFIG_SCSI_OSD_INITIATOR=y
# CONFIG_SCSI_OSD_ULD is not set
CONFIG_SCSI_OSD_DPRINT_SENSE=1
# CONFIG_SCSI_OSD_DEBUG is not set
# CONFIG_ATA is not set
CONFIG_MD=y
CONFIG_BLK_DEV_MD=y
# CONFIG_MD_AUTODETECT is not set
# CONFIG_MD_LINEAR is not set
CONFIG_MD_RAID0=y
CONFIG_MD_RAID1=y
CONFIG_MD_RAID10=y
CONFIG_MD_RAID456=y
CONFIG_MD_MULTIPATH=y
CONFIG_MD_FAULTY=y
# CONFIG_BCACHE is not set
CONFIG_BLK_DEV_DM_BUILTIN=y
CONFIG_BLK_DEV_DM=y
# CONFIG_DM_MQ_DEFAULT is not set
CONFIG_DM_DEBUG=y
CONFIG_DM_BUFIO=y
CONFIG_DM_DEBUG_BLOCK_MANAGER_LOCKING=y
CONFIG_DM_DEBUG_BLOCK_STACK_TRACING=y
CONFIG_DM_BIO_PRISON=y
CONFIG_DM_PERSISTENT_DATA=y
CONFIG_DM_CRYPT=y
CONFIG_DM_SNAPSHOT=y
CONFIG_DM_THIN_PROVISIONING=y
CONFIG_DM_CACHE=y
CONFIG_DM_CACHE_SMQ=y
# CONFIG_DM_ERA is not set
# CONFIG_DM_MIRROR is not set
CONFIG_DM_RAID=y
CONFIG_DM_ZERO=y
CONFIG_DM_MULTIPATH=y
# CONFIG_DM_MULTIPATH_QL is not set
# CONFIG_DM_MULTIPATH_ST is not set
# CONFIG_DM_DELAY is not set
CONFIG_DM_UEVENT=y
CONFIG_DM_FLAKEY=y
CONFIG_DM_VERITY=y
CONFIG_DM_VERITY_FEC=y
CONFIG_DM_SWITCH=y
# CONFIG_DM_LOG_WRITES is not set
CONFIG_DM_INTEGRITY=y
# CONFIG_TARGET_CORE is not set
CONFIG_FUSION=y
# CONFIG_FUSION_SPI is not set
CONFIG_FUSION_SAS=y
CONFIG_FUSION_MAX_SGE=128
CONFIG_FUSION_CTL=y
# CONFIG_FUSION_LOGGING is not set

#
# IEEE 1394 (FireWire) support
#
# CONFIG_FIREWIRE is not set
# CONFIG_FIREWIRE_NOSY is not set
CONFIG_MACINTOSH_DRIVERS=y
CONFIG_MAC_EMUMOUSEBTN=y
CONFIG_NETDEVICES=y
CONFIG_NET_CORE=y
# CONFIG_BONDING is not set
# CONFIG_DUMMY is not set
# CONFIG_EQUALIZER is not set
# CONFIG_NET_FC is not set
# CONFIG_NET_TEAM is not set
# CONFIG_MACVLAN is not set
# CONFIG_VXLAN is not set
# CONFIG_MACSEC is not set
# CONFIG_NETCONSOLE is not set
# CONFIG_NETPOLL is not set
# CONFIG_NET_POLL_CONTROLLER is not set
# CONFIG_RIONET is not set
# CONFIG_TUN is not set
# CONFIG_TUN_VNET_CROSS_LE is not set
# CONFIG_VETH is not set
# CONFIG_VIRTIO_NET is not set
# CONFIG_NLMON is not set
# CONFIG_ARCNET is not set

#
# CAIF transport drivers
#

#
# Distributed Switch Architecture drivers
#
CONFIG_ETHERNET=y
CONFIG_MDIO=y
CONFIG_NET_VENDOR_3COM=y
# CONFIG_VORTEX is not set
# CONFIG_TYPHOON is not set
CONFIG_NET_VENDOR_ADAPTEC=y
# CONFIG_ADAPTEC_STARFIRE is not set
CONFIG_NET_VENDOR_AGERE=y
# CONFIG_ET131X is not set
CONFIG_NET_VENDOR_ALACRITECH=y
# CONFIG_SLICOSS is not set
CONFIG_NET_VENDOR_ALTEON=y
# CONFIG_ACENIC is not set
# CONFIG_ALTERA_TSE is not set
CONFIG_NET_VENDOR_AMAZON=y
CONFIG_NET_VENDOR_AMD=y
# CONFIG_AMD8111_ETH is not set
# CONFIG_PCNET32 is not set
# CONFIG_AMD_XGBE is not set
# CONFIG_AMD_XGBE_HAVE_ECC is not set
CONFIG_NET_VENDOR_AQUANTIA=y
# CONFIG_AQTION is not set
CONFIG_NET_VENDOR_ARC=y
CONFIG_NET_VENDOR_ATHEROS=y
# CONFIG_ATL2 is not set
# CONFIG_ATL1 is not set
# CONFIG_ATL1E is not set
# CONFIG_ATL1C is not set
# CONFIG_ALX is not set
CONFIG_NET_VENDOR_AURORA=y
# CONFIG_AURORA_NB8800 is not set
CONFIG_NET_CADENCE=y
# CONFIG_MACB is not set
CONFIG_NET_VENDOR_BROADCOM=y
# CONFIG_B44 is not set
# CONFIG_BNX2 is not set
# CONFIG_CNIC is not set
# CONFIG_TIGON3 is not set
# CONFIG_BNX2X is not set
# CONFIG_BNXT is not set
CONFIG_NET_VENDOR_BROCADE=y
# CONFIG_BNA is not set
CONFIG_NET_VENDOR_CAVIUM=y
# CONFIG_THUNDER_NIC_PF is not set
# CONFIG_THUNDER_NIC_VF is not set
# CONFIG_THUNDER_NIC_BGX is not set
# CONFIG_THUNDER_NIC_RGX is not set
# CONFIG_LIQUIDIO is not set
CONFIG_NET_VENDOR_CHELSIO=y
# CONFIG_CHELSIO_T1 is not set
# CONFIG_CHELSIO_T3 is not set
# CONFIG_CHELSIO_T4 is not set
# CONFIG_CHELSIO_T4VF is not set
CONFIG_NET_VENDOR_CISCO=y
# CONFIG_ENIC is not set
# CONFIG_CX_ECAT is not set
# CONFIG_DNET is not set
CONFIG_NET_VENDOR_DEC=y
# CONFIG_NET_TULIP is not set
CONFIG_NET_VENDOR_DLINK=y
# CONFIG_DL2K is not set
# CONFIG_SUNDANCE is not set
CONFIG_NET_VENDOR_EMULEX=y
# CONFIG_BE2NET is not set
CONFIG_NET_VENDOR_EZCHIP=y
CONFIG_NET_VENDOR_EXAR=y
# CONFIG_S2IO is not set
# CONFIG_VXGE is not set
CONFIG_NET_VENDOR_HP=y
# CONFIG_HP100 is not set
CONFIG_NET_VENDOR_HUAWEI=y
CONFIG_NET_VENDOR_INTEL=y
# CONFIG_E100 is not set
CONFIG_E1000=y
CONFIG_E1000E=y
CONFIG_E1000E_HWTS=y
CONFIG_IGB=y
CONFIG_IGB_HWMON=y
# CONFIG_IGBVF is not set
# CONFIG_IXGB is not set
CONFIG_IXGBE=y
CONFIG_IXGBE_HWMON=y
# CONFIG_I40E is not set
CONFIG_NET_VENDOR_I825XX=y
# CONFIG_JME is not set
CONFIG_NET_VENDOR_MARVELL=y
# CONFIG_MVMDIO is not set
# CONFIG_SKGE is not set
# CONFIG_SKY2 is not set
CONFIG_NET_VENDOR_MELLANOX=y
# CONFIG_MLX4_EN is not set
# CONFIG_MLX4_CORE is not set
# CONFIG_MLX5_CORE is not set
# CONFIG_MLXSW_CORE is not set
# CONFIG_MLXFW is not set
CONFIG_NET_VENDOR_MICREL=y
# CONFIG_KS8842 is not set
# CONFIG_KS8851 is not set
# CONFIG_KS8851_MLL is not set
# CONFIG_KSZ884X_PCI is not set
CONFIG_NET_VENDOR_MICROCHIP=y
# CONFIG_ENC28J60 is not set
# CONFIG_ENCX24J600 is not set
CONFIG_NET_VENDOR_MYRI=y
# CONFIG_MYRI10GE is not set
# CONFIG_FEALNX is not set
CONFIG_NET_VENDOR_NATSEMI=y
# CONFIG_NATSEMI is not set
# CONFIG_NS83820 is not set
CONFIG_NET_VENDOR_NETRONOME=y
CONFIG_NET_VENDOR_8390=y
# CONFIG_NE2K_PCI is not set
CONFIG_NET_VENDOR_NVIDIA=y
# CONFIG_FORCEDETH is not set
CONFIG_NET_VENDOR_OKI=y
# CONFIG_ETHOC is not set
CONFIG_NET_PACKET_ENGINE=y
# CONFIG_HAMACHI is not set
# CONFIG_YELLOWFIN is not set
CONFIG_NET_VENDOR_QLOGIC=y
# CONFIG_QLA3XXX is not set
# CONFIG_QLCNIC is not set
# CONFIG_QLGE is not set
# CONFIG_NETXEN_NIC is not set
# CONFIG_QED is not set
CONFIG_NET_VENDOR_QUALCOMM=y
# CONFIG_QCOM_EMAC is not set
# CONFIG_RMNET is not set
CONFIG_NET_VENDOR_REALTEK=y
# CONFIG_ATP is not set
# CONFIG_8139CP is not set
# CONFIG_8139TOO is not set
# CONFIG_R8169 is not set
CONFIG_NET_VENDOR_RENESAS=y
CONFIG_NET_VENDOR_RDC=y
# CONFIG_R6040 is not set
CONFIG_NET_VENDOR_ROCKER=y
CONFIG_NET_VENDOR_SAMSUNG=y
# CONFIG_SXGBE_ETH is not set
CONFIG_NET_VENDOR_SEEQ=y
CONFIG_NET_VENDOR_SILAN=y
# CONFIG_SC92031 is not set
CONFIG_NET_VENDOR_SIS=y
# CONFIG_SIS900 is not set
# CONFIG_SIS190 is not set
CONFIG_NET_VENDOR_SOLARFLARE=y
# CONFIG_SFC is not set
# CONFIG_SFC_FALCON is not set
CONFIG_NET_VENDOR_SMSC=y
# CONFIG_EPIC100 is not set
# CONFIG_SMSC911X is not set
# CONFIG_SMSC9420 is not set
CONFIG_NET_VENDOR_STMICRO=y
# CONFIG_STMMAC_ETH is not set
CONFIG_NET_VENDOR_SUN=y
# CONFIG_HAPPYMEAL is not set
# CONFIG_SUNGEM is not set
# CONFIG_CASSINI is not set
# CONFIG_NIU is not set
CONFIG_NET_VENDOR_TEHUTI=y
# CONFIG_TEHUTI is not set
CONFIG_NET_VENDOR_TI=y
# CONFIG_TI_CPSW_ALE is not set
# CONFIG_TLAN is not set
CONFIG_NET_VENDOR_VIA=y
# CONFIG_VIA_RHINE is not set
# CONFIG_VIA_VELOCITY is not set
CONFIG_NET_VENDOR_WIZNET=y
# CONFIG_WIZNET_W5100 is not set
# CONFIG_WIZNET_W5300 is not set
CONFIG_NET_VENDOR_SYNOPSYS=y
# CONFIG_DWC_XLGMAC is not set
# CONFIG_FDDI is not set
# CONFIG_HIPPI is not set
# CONFIG_NET_SB1000 is not set
# CONFIG_MDIO_DEVICE is not set
# CONFIG_MDIO_BUS is not set
# CONFIG_PHYLIB is not set
# CONFIG_MICREL_KS8995MA is not set
# CONFIG_PLIP is not set
# CONFIG_PPP is not set
# CONFIG_SLIP is not set
CONFIG_USB_NET_DRIVERS=y
# CONFIG_USB_CATC is not set
# CONFIG_USB_KAWETH is not set
# CONFIG_USB_PEGASUS is not set
# CONFIG_USB_RTL8150 is not set
# CONFIG_USB_RTL8152 is not set
# CONFIG_USB_LAN78XX is not set
# CONFIG_USB_USBNET is not set
# CONFIG_USB_IPHETH is not set
CONFIG_WLAN=y
CONFIG_WLAN_VENDOR_ADMTEK=y
CONFIG_WLAN_VENDOR_ATH=y
# CONFIG_ATH_DEBUG is not set
# CONFIG_ATH5K_PCI is not set
CONFIG_WLAN_VENDOR_ATMEL=y
CONFIG_WLAN_VENDOR_BROADCOM=y
CONFIG_WLAN_VENDOR_CISCO=y
CONFIG_WLAN_VENDOR_INTEL=y
CONFIG_WLAN_VENDOR_INTERSIL=y
# CONFIG_HOSTAP is not set
# CONFIG_PRISM54 is not set
CONFIG_WLAN_VENDOR_MARVELL=y
CONFIG_WLAN_VENDOR_MEDIATEK=y
CONFIG_WLAN_VENDOR_RALINK=y
CONFIG_WLAN_VENDOR_REALTEK=y
CONFIG_WLAN_VENDOR_RSI=y
CONFIG_WLAN_VENDOR_ST=y
CONFIG_WLAN_VENDOR_TI=y
CONFIG_WLAN_VENDOR_ZYDAS=y
CONFIG_WLAN_VENDOR_QUANTENNA=y

#
# Enable WiMAX (Networking options) to see the WiMAX drivers
#
# CONFIG_WAN is not set
# CONFIG_VMXNET3 is not set
# CONFIG_FUJITSU_ES is not set
# CONFIG_ISDN is not set
# CONFIG_NVM is not set

#
# Input device support
#
CONFIG_INPUT=y
# CONFIG_INPUT_LEDS is not set
CONFIG_INPUT_FF_MEMLESS=y
CONFIG_INPUT_POLLDEV=y
CONFIG_INPUT_SPARSEKMAP=y
CONFIG_INPUT_MATRIXKMAP=y

#
# Userland interfaces
#
# CONFIG_INPUT_MOUSEDEV is not set
# CONFIG_INPUT_JOYDEV is not set
CONFIG_INPUT_EVDEV=y
CONFIG_INPUT_EVBUG=y

#
# Input Device Drivers
#
CONFIG_INPUT_KEYBOARD=y
CONFIG_KEYBOARD_ADP5588=y
CONFIG_KEYBOARD_ADP5589=y
CONFIG_KEYBOARD_ATKBD=y
CONFIG_KEYBOARD_QT1070=y
CONFIG_KEYBOARD_QT2160=y
# CONFIG_KEYBOARD_DLINK_DIR685 is not set
CONFIG_KEYBOARD_LKKBD=y
CONFIG_KEYBOARD_GPIO=y
# CONFIG_KEYBOARD_GPIO_POLLED is not set
CONFIG_KEYBOARD_TCA6416=y
CONFIG_KEYBOARD_TCA8418=y
CONFIG_KEYBOARD_MATRIX=y
CONFIG_KEYBOARD_LM8323=y
# CONFIG_KEYBOARD_LM8333 is not set
CONFIG_KEYBOARD_MAX7359=y
CONFIG_KEYBOARD_MCS=y
CONFIG_KEYBOARD_MPR121=y
# CONFIG_KEYBOARD_NEWTON is not set
# CONFIG_KEYBOARD_OPENCORES is not set
CONFIG_KEYBOARD_SAMSUNG=y
CONFIG_KEYBOARD_GOLDFISH_EVENTS=y
CONFIG_KEYBOARD_STOWAWAY=y
# CONFIG_KEYBOARD_SUNKBD is not set
# CONFIG_KEYBOARD_TM2_TOUCHKEY is not set
# CONFIG_KEYBOARD_TWL4030 is not set
CONFIG_KEYBOARD_XTKBD=y
CONFIG_KEYBOARD_CROS_EC=y
# CONFIG_INPUT_MOUSE is not set
# CONFIG_INPUT_JOYSTICK is not set
# CONFIG_INPUT_TABLET is not set
# CONFIG_INPUT_TOUCHSCREEN is not set
CONFIG_INPUT_MISC=y
CONFIG_INPUT_AD714X=y
CONFIG_INPUT_AD714X_I2C=y
# CONFIG_INPUT_AD714X_SPI is not set
CONFIG_INPUT_ARIZONA_HAPTICS=y
# CONFIG_INPUT_BMA150 is not set
CONFIG_INPUT_E3X0_BUTTON=y
CONFIG_INPUT_PCSPKR=y
CONFIG_INPUT_MAX8925_ONKEY=y
# CONFIG_INPUT_MAX8997_HAPTIC is not set
CONFIG_INPUT_MC13783_PWRBUTTON=y
CONFIG_INPUT_MMA8450=y
# CONFIG_INPUT_APANEL is not set
CONFIG_INPUT_GP2A=y
# CONFIG_INPUT_GPIO_BEEPER is not set
# CONFIG_INPUT_GPIO_TILT_POLLED is not set
CONFIG_INPUT_GPIO_DECODER=y
CONFIG_INPUT_ATLAS_BTNS=y
CONFIG_INPUT_ATI_REMOTE2=y
CONFIG_INPUT_KEYSPAN_REMOTE=y
CONFIG_INPUT_KXTJ9=y
CONFIG_INPUT_KXTJ9_POLLED_MODE=y
CONFIG_INPUT_POWERMATE=y
CONFIG_INPUT_YEALINK=y
# CONFIG_INPUT_CM109 is not set
# CONFIG_INPUT_REGULATOR_HAPTIC is not set
CONFIG_INPUT_RETU_PWRBUTTON=y
CONFIG_INPUT_AXP20X_PEK=y
# CONFIG_INPUT_TWL4030_PWRBUTTON is not set
CONFIG_INPUT_TWL4030_VIBRA=y
CONFIG_INPUT_UINPUT=y
CONFIG_INPUT_PCF50633_PMU=y
# CONFIG_INPUT_PCF8574 is not set
CONFIG_INPUT_PWM_BEEPER=y
CONFIG_INPUT_PWM_VIBRA=y
# CONFIG_INPUT_GPIO_ROTARY_ENCODER is not set
CONFIG_INPUT_DA9052_ONKEY=y
# CONFIG_INPUT_DA9055_ONKEY is not set
CONFIG_INPUT_DA9063_ONKEY=y
CONFIG_INPUT_PCAP=y
CONFIG_INPUT_ADXL34X=y
# CONFIG_INPUT_ADXL34X_I2C is not set
# CONFIG_INPUT_ADXL34X_SPI is not set
# CONFIG_INPUT_IMS_PCU is not set
CONFIG_INPUT_CMA3000=y
CONFIG_INPUT_CMA3000_I2C=y
# CONFIG_INPUT_IDEAPAD_SLIDEBAR is not set
# CONFIG_INPUT_SOC_BUTTON_ARRAY is not set
# CONFIG_INPUT_DRV260X_HAPTICS is not set
# CONFIG_INPUT_DRV2665_HAPTICS is not set
# CONFIG_INPUT_DRV2667_HAPTICS is not set
# CONFIG_RMI4_CORE is not set

#
# Hardware I/O ports
#
CONFIG_SERIO=y
CONFIG_ARCH_MIGHT_HAVE_PC_SERIO=y
CONFIG_SERIO_I8042=y
CONFIG_SERIO_SERPORT=y
CONFIG_SERIO_CT82C710=y
# CONFIG_SERIO_PARKBD is not set
# CONFIG_SERIO_PCIPS2 is not set
CONFIG_SERIO_LIBPS2=y
CONFIG_SERIO_RAW=y
CONFIG_SERIO_ALTERA_PS2=y
CONFIG_SERIO_PS2MULT=y
CONFIG_SERIO_ARC_PS2=y
CONFIG_SERIO_GPIO_PS2=y
# CONFIG_USERIO is not set
# CONFIG_GAMEPORT is not set

#
# Character devices
#
CONFIG_TTY=y
CONFIG_VT=y
CONFIG_CONSOLE_TRANSLATIONS=y
CONFIG_VT_CONSOLE=y
CONFIG_VT_CONSOLE_SLEEP=y
CONFIG_HW_CONSOLE=y
CONFIG_VT_HW_CONSOLE_BINDING=y
CONFIG_UNIX98_PTYS=y
CONFIG_LEGACY_PTYS=y
CONFIG_LEGACY_PTY_COUNT=256
# CONFIG_SERIAL_NONSTANDARD is not set
CONFIG_NOZOMI=y
# CONFIG_N_GSM is not set
CONFIG_TRACE_ROUTER=y
CONFIG_TRACE_SINK=y
CONFIG_GOLDFISH_TTY=y
CONFIG_DEVMEM=y
CONFIG_DEVKMEM=y

#
# Serial drivers
#
CONFIG_SERIAL_EARLYCON=y
CONFIG_SERIAL_8250=y
CONFIG_SERIAL_8250_DEPRECATED_OPTIONS=y
CONFIG_SERIAL_8250_PNP=y
# CONFIG_SERIAL_8250_FINTEK is not set
CONFIG_SERIAL_8250_CONSOLE=y
CONFIG_SERIAL_8250_DMA=y
# CONFIG_SERIAL_8250_PCI is not set
CONFIG_SERIAL_8250_NR_UARTS=4
CONFIG_SERIAL_8250_RUNTIME_UARTS=4
CONFIG_SERIAL_8250_EXTENDED=y
CONFIG_SERIAL_8250_MANY_PORTS=y
# CONFIG_SERIAL_8250_SHARE_IRQ is not set
# CONFIG_SERIAL_8250_DETECT_IRQ is not set
# CONFIG_SERIAL_8250_RSA is not set
# CONFIG_SERIAL_8250_FSL is not set
# CONFIG_SERIAL_8250_DW is not set
# CONFIG_SERIAL_8250_RT288X is not set
# CONFIG_SERIAL_8250_LPSS is not set
CONFIG_SERIAL_8250_MID=y
CONFIG_SERIAL_8250_MOXA=y

#
# Non-8250 serial port support
#
# CONFIG_SERIAL_MAX3100 is not set
# CONFIG_SERIAL_MAX310X is not set
CONFIG_SERIAL_UARTLITE=y
# CONFIG_SERIAL_UARTLITE_CONSOLE is not set
CONFIG_SERIAL_UARTLITE_NR_UARTS=1
CONFIG_SERIAL_CORE=y
CONFIG_SERIAL_CORE_CONSOLE=y
# CONFIG_SERIAL_JSM is not set
CONFIG_SERIAL_SCCNXP=y
# CONFIG_SERIAL_SCCNXP_CONSOLE is not set
CONFIG_SERIAL_SC16IS7XX_CORE=y
CONFIG_SERIAL_SC16IS7XX=y
# CONFIG_SERIAL_SC16IS7XX_I2C is not set
CONFIG_SERIAL_SC16IS7XX_SPI=y
CONFIG_SERIAL_ALTERA_JTAGUART=y
# CONFIG_SERIAL_ALTERA_JTAGUART_CONSOLE is not set
# CONFIG_SERIAL_ALTERA_UART is not set
# CONFIG_SERIAL_IFX6X60 is not set
CONFIG_SERIAL_ARC=y
CONFIG_SERIAL_ARC_CONSOLE=y
CONFIG_SERIAL_ARC_NR_PORTS=1
# CONFIG_SERIAL_RP2 is not set
CONFIG_SERIAL_FSL_LPUART=y
# CONFIG_SERIAL_FSL_LPUART_CONSOLE is not set
# CONFIG_SERIAL_DEV_BUS is not set
CONFIG_PRINTER=y
# CONFIG_LP_CONSOLE is not set
# CONFIG_PPDEV is not set
CONFIG_HVC_DRIVER=y
CONFIG_VIRTIO_CONSOLE=y
# CONFIG_IPMI_HANDLER is not set
CONFIG_HW_RANDOM=y
CONFIG_HW_RANDOM_TIMERIOMEM=y
CONFIG_HW_RANDOM_INTEL=y
CONFIG_HW_RANDOM_AMD=y
CONFIG_HW_RANDOM_VIA=y
CONFIG_HW_RANDOM_VIRTIO=y
CONFIG_NVRAM=y
# CONFIG_R3964 is not set
CONFIG_APPLICOM=y
CONFIG_MWAVE=y
CONFIG_RAW_DRIVER=y
CONFIG_MAX_RAW_DEVS=256
# CONFIG_HPET is not set
# CONFIG_HANGCHECK_TIMER is not set
# CONFIG_TCG_TPM is not set
CONFIG_TELCLOCK=y
# CONFIG_DEVPORT is not set
CONFIG_XILLYBUS=y

#
# I2C support
#
CONFIG_I2C=y
CONFIG_ACPI_I2C_OPREGION=y
CONFIG_I2C_BOARDINFO=y
# CONFIG_I2C_COMPAT is not set
CONFIG_I2C_CHARDEV=y
CONFIG_I2C_MUX=y

#
# Multiplexer I2C Chip support
#
CONFIG_I2C_MUX_GPIO=y
CONFIG_I2C_MUX_LTC4306=y
# CONFIG_I2C_MUX_PCA9541 is not set
CONFIG_I2C_MUX_PCA954x=y
CONFIG_I2C_MUX_REG=y
CONFIG_I2C_MUX_MLXCPLD=y
CONFIG_I2C_HELPER_AUTO=y
CONFIG_I2C_SMBUS=y
CONFIG_I2C_ALGOBIT=y
CONFIG_I2C_ALGOPCA=y

#
# I2C Hardware Bus support
#

#
# PC SMBus host controller drivers
#
CONFIG_I2C_ALI1535=y
CONFIG_I2C_ALI1563=y
CONFIG_I2C_ALI15X3=y
# CONFIG_I2C_AMD756 is not set
# CONFIG_I2C_AMD8111 is not set
CONFIG_I2C_I801=y
CONFIG_I2C_ISCH=y
CONFIG_I2C_ISMT=y
CONFIG_I2C_PIIX4=y
CONFIG_I2C_CHT_WC=y
# CONFIG_I2C_NFORCE2 is not set
CONFIG_I2C_SIS5595=y
CONFIG_I2C_SIS630=y
# CONFIG_I2C_SIS96X is not set
CONFIG_I2C_VIA=y
CONFIG_I2C_VIAPRO=y

#
# ACPI drivers
#
CONFIG_I2C_SCMI=y

#
# I2C system bus drivers (mostly embedded / system-on-chip)
#
# CONFIG_I2C_CBUS_GPIO is not set
CONFIG_I2C_DESIGNWARE_CORE=y
CONFIG_I2C_DESIGNWARE_PLATFORM=y
# CONFIG_I2C_DESIGNWARE_SLAVE is not set
# CONFIG_I2C_DESIGNWARE_PCI is not set
CONFIG_I2C_DESIGNWARE_BAYTRAIL=y
CONFIG_I2C_EMEV2=y
CONFIG_I2C_GPIO=y
CONFIG_I2C_KEMPLD=y
CONFIG_I2C_OCORES=y
CONFIG_I2C_PCA_PLATFORM=y
# CONFIG_I2C_PXA_PCI is not set
CONFIG_I2C_SIMTEC=y
CONFIG_I2C_XILINX=y

#
# External I2C/SMBus adapter drivers
#
CONFIG_I2C_DIOLAN_U2C=y
CONFIG_I2C_DLN2=y
CONFIG_I2C_PARPORT=y
CONFIG_I2C_PARPORT_LIGHT=y
CONFIG_I2C_ROBOTFUZZ_OSIF=y
# CONFIG_I2C_TAOS_EVM is not set
# CONFIG_I2C_TINY_USB is not set

#
# Other I2C/SMBus bus drivers
#
CONFIG_I2C_MLXCPLD=y
# CONFIG_I2C_CROS_EC_TUNNEL is not set
CONFIG_I2C_SLAVE=y
CONFIG_I2C_SLAVE_EEPROM=y
# CONFIG_I2C_DEBUG_CORE is not set
# CONFIG_I2C_DEBUG_ALGO is not set
# CONFIG_I2C_DEBUG_BUS is not set
CONFIG_SPI=y
CONFIG_SPI_DEBUG=y
CONFIG_SPI_MASTER=y

#
# SPI Master Controller Drivers
#
CONFIG_SPI_ALTERA=y
# CONFIG_SPI_AXI_SPI_ENGINE is not set
CONFIG_SPI_BITBANG=y
CONFIG_SPI_BUTTERFLY=y
CONFIG_SPI_CADENCE=y
CONFIG_SPI_DESIGNWARE=y
# CONFIG_SPI_DW_PCI is not set
# CONFIG_SPI_DW_MMIO is not set
# CONFIG_SPI_DLN2 is not set
CONFIG_SPI_GPIO=y
CONFIG_SPI_LM70_LLP=y
# CONFIG_SPI_OC_TINY is not set
# CONFIG_SPI_PXA2XX is not set
# CONFIG_SPI_PXA2XX_PCI is not set
CONFIG_SPI_ROCKCHIP=y
CONFIG_SPI_SC18IS602=y
CONFIG_SPI_XCOMM=y
CONFIG_SPI_XILINX=y
# CONFIG_SPI_ZYNQMP_GQSPI is not set

#
# SPI Protocol Masters
#
# CONFIG_SPI_SPIDEV is not set
CONFIG_SPI_TLE62X0=y
CONFIG_SPI_SLAVE=y
CONFIG_SPI_SLAVE_TIME=y
CONFIG_SPI_SLAVE_SYSTEM_CONTROL=y
# CONFIG_SPMI is not set
CONFIG_HSI=y
CONFIG_HSI_BOARDINFO=y

#
# HSI controllers
#

#
# HSI clients
#
# CONFIG_HSI_CHAR is not set
CONFIG_PPS=y
# CONFIG_PPS_DEBUG is not set

#
# PPS clients support
#
# CONFIG_PPS_CLIENT_KTIMER is not set
CONFIG_PPS_CLIENT_LDISC=y
CONFIG_PPS_CLIENT_PARPORT=y
CONFIG_PPS_CLIENT_GPIO=y

#
# PPS generators support
#

#
# PTP clock support
#
CONFIG_PTP_1588_CLOCK=y

#
# Enable PHYLIB and NETWORK_PHY_TIMESTAMPING to see the additional clocks.
#
CONFIG_PTP_1588_CLOCK_KVM=y
CONFIG_PINCTRL=y

#
# Pin controllers
#
CONFIG_PINMUX=y
CONFIG_PINCONF=y
CONFIG_GENERIC_PINCONF=y
CONFIG_DEBUG_PINCTRL=y
CONFIG_PINCTRL_AMD=y
CONFIG_PINCTRL_MCP23S08=y
CONFIG_PINCTRL_SX150X=y
# CONFIG_PINCTRL_BAYTRAIL is not set
# CONFIG_PINCTRL_CHERRYVIEW is not set
CONFIG_PINCTRL_INTEL=y
CONFIG_PINCTRL_BROXTON=y
CONFIG_PINCTRL_CANNONLAKE=y
CONFIG_PINCTRL_DENVERTON=y
CONFIG_PINCTRL_GEMINILAKE=y
# CONFIG_PINCTRL_LEWISBURG is not set
CONFIG_PINCTRL_SUNRISEPOINT=y
CONFIG_GPIOLIB=y
CONFIG_GPIO_ACPI=y
CONFIG_GPIOLIB_IRQCHIP=y
CONFIG_DEBUG_GPIO=y
CONFIG_GPIO_SYSFS=y
CONFIG_GPIO_GENERIC=y
CONFIG_GPIO_MAX730X=y

#
# Memory mapped GPIO drivers
#
CONFIG_GPIO_AMDPT=y
# CONFIG_GPIO_AXP209 is not set
# CONFIG_GPIO_DWAPB is not set
CONFIG_GPIO_GENERIC_PLATFORM=y
# CONFIG_GPIO_ICH is not set
CONFIG_GPIO_LYNXPOINT=y
# CONFIG_GPIO_MB86S7X is not set
CONFIG_GPIO_MOCKUP=y
# CONFIG_GPIO_VX855 is not set

#
# Port-mapped I/O GPIO drivers
#
CONFIG_GPIO_F7188X=y
CONFIG_GPIO_IT87=y
CONFIG_GPIO_SCH=y
CONFIG_GPIO_SCH311X=y

#
# I2C GPIO expanders
#
CONFIG_GPIO_ADP5588=y
# CONFIG_GPIO_ADP5588_IRQ is not set
CONFIG_GPIO_MAX7300=y
CONFIG_GPIO_MAX732X=y
# CONFIG_GPIO_MAX732X_IRQ is not set
CONFIG_GPIO_PCA953X=y
CONFIG_GPIO_PCA953X_IRQ=y
CONFIG_GPIO_PCF857X=y
# CONFIG_GPIO_SX150X is not set
CONFIG_GPIO_TPIC2810=y

#
# MFD GPIO expanders
#
CONFIG_GPIO_ARIZONA=y
CONFIG_GPIO_CRYSTAL_COVE=y
# CONFIG_GPIO_DA9052 is not set
CONFIG_GPIO_DA9055=y
CONFIG_GPIO_DLN2=y
CONFIG_GPIO_JANZ_TTL=y
CONFIG_GPIO_KEMPLD=y
CONFIG_GPIO_LP3943=y
# CONFIG_GPIO_LP873X is not set
# CONFIG_GPIO_RC5T583 is not set
CONFIG_GPIO_TPS65086=y
# CONFIG_GPIO_TPS65912 is not set
# CONFIG_GPIO_TWL4030 is not set
CONFIG_GPIO_UCB1400=y
CONFIG_GPIO_WM8994=y

#
# PCI GPIO expanders
#
CONFIG_GPIO_AMD8111=y
# CONFIG_GPIO_BT8XX is not set
CONFIG_GPIO_ML_IOH=y
# CONFIG_GPIO_PCI_IDIO_16 is not set
# CONFIG_GPIO_RDC321X is not set

#
# SPI GPIO expanders
#
CONFIG_GPIO_MAX3191X=y
# CONFIG_GPIO_MAX7301 is not set
# CONFIG_GPIO_MC33880 is not set
CONFIG_GPIO_PISOSR=y
# CONFIG_GPIO_XRA1403 is not set

#
# USB GPIO expanders
#
CONFIG_W1=y

#
# 1-wire Bus Masters
#
# CONFIG_W1_MASTER_MATROX is not set
CONFIG_W1_MASTER_DS2490=y
CONFIG_W1_MASTER_DS2482=y
# CONFIG_W1_MASTER_DS1WM is not set
CONFIG_W1_MASTER_GPIO=y

#
# 1-wire Slaves
#
# CONFIG_W1_SLAVE_THERM is not set
CONFIG_W1_SLAVE_SMEM=y
CONFIG_W1_SLAVE_DS2405=y
CONFIG_W1_SLAVE_DS2408=y
CONFIG_W1_SLAVE_DS2408_READBACK=y
CONFIG_W1_SLAVE_DS2413=y
CONFIG_W1_SLAVE_DS2406=y
CONFIG_W1_SLAVE_DS2423=y
CONFIG_W1_SLAVE_DS2805=y
# CONFIG_W1_SLAVE_DS2431 is not set
CONFIG_W1_SLAVE_DS2433=y
# CONFIG_W1_SLAVE_DS2433_CRC is not set
CONFIG_W1_SLAVE_DS2438=y
# CONFIG_W1_SLAVE_DS2760 is not set
CONFIG_W1_SLAVE_DS2780=y
CONFIG_W1_SLAVE_DS2781=y
CONFIG_W1_SLAVE_DS28E04=y
# CONFIG_POWER_AVS is not set
# CONFIG_POWER_RESET is not set
CONFIG_POWER_SUPPLY=y
CONFIG_POWER_SUPPLY_DEBUG=y
CONFIG_PDA_POWER=y
# CONFIG_MAX8925_POWER is not set
# CONFIG_TEST_POWER is not set
CONFIG_BATTERY_DS2780=y
# CONFIG_BATTERY_DS2781 is not set
CONFIG_BATTERY_DS2782=y
CONFIG_BATTERY_SBS=y
# CONFIG_CHARGER_SBS is not set
CONFIG_MANAGER_SBS=y
CONFIG_BATTERY_BQ27XXX=y
# CONFIG_BATTERY_BQ27XXX_I2C is not set
# CONFIG_BATTERY_BQ27XXX_HDQ is not set
CONFIG_BATTERY_DA9052=y
# CONFIG_BATTERY_DA9150 is not set
CONFIG_BATTERY_MAX17040=y
CONFIG_BATTERY_MAX17042=y
CONFIG_BATTERY_MAX1721X=y
# CONFIG_CHARGER_PCF50633 is not set
CONFIG_CHARGER_ISP1704=y
CONFIG_CHARGER_MAX8903=y
# CONFIG_CHARGER_LP8727 is not set
CONFIG_CHARGER_GPIO=y
# CONFIG_CHARGER_MANAGER is not set
CONFIG_CHARGER_LTC3651=y
CONFIG_CHARGER_MAX14577=y
CONFIG_CHARGER_MAX8997=y
CONFIG_CHARGER_BQ2415X=y
CONFIG_CHARGER_BQ24190=y
CONFIG_CHARGER_BQ24257=y
CONFIG_CHARGER_BQ24735=y
CONFIG_CHARGER_BQ25890=y
CONFIG_CHARGER_SMB347=y
CONFIG_BATTERY_GAUGE_LTC2941=y
CONFIG_BATTERY_GOLDFISH=y
CONFIG_CHARGER_RT9455=y
CONFIG_HWMON=y
CONFIG_HWMON_VID=y
# CONFIG_HWMON_DEBUG_CHIP is not set

#
# Native drivers
#
CONFIG_SENSORS_ABITUGURU=y
CONFIG_SENSORS_ABITUGURU3=y
# CONFIG_SENSORS_AD7314 is not set
CONFIG_SENSORS_AD7414=y
# CONFIG_SENSORS_AD7418 is not set
# CONFIG_SENSORS_ADM1021 is not set
# CONFIG_SENSORS_ADM1025 is not set
CONFIG_SENSORS_ADM1026=y
# CONFIG_SENSORS_ADM1029 is not set
CONFIG_SENSORS_ADM1031=y
CONFIG_SENSORS_ADM9240=y
CONFIG_SENSORS_ADT7X10=y
CONFIG_SENSORS_ADT7310=y
CONFIG_SENSORS_ADT7410=y
CONFIG_SENSORS_ADT7411=y
CONFIG_SENSORS_ADT7462=y
# CONFIG_SENSORS_ADT7470 is not set
# CONFIG_SENSORS_ADT7475 is not set
CONFIG_SENSORS_ASC7621=y
CONFIG_SENSORS_K8TEMP=y
CONFIG_SENSORS_K10TEMP=y
CONFIG_SENSORS_FAM15H_POWER=y
# CONFIG_SENSORS_APPLESMC is not set
CONFIG_SENSORS_ASB100=y
CONFIG_SENSORS_ASPEED=y
CONFIG_SENSORS_ATXP1=y
CONFIG_SENSORS_DS620=y
CONFIG_SENSORS_DS1621=y
CONFIG_SENSORS_DELL_SMM=y
CONFIG_SENSORS_DA9052_ADC=y
CONFIG_SENSORS_DA9055=y
# CONFIG_SENSORS_I5K_AMB is not set
CONFIG_SENSORS_F71805F=y
# CONFIG_SENSORS_F71882FG is not set
CONFIG_SENSORS_F75375S=y
# CONFIG_SENSORS_MC13783_ADC is not set
# CONFIG_SENSORS_FSCHMD is not set
# CONFIG_SENSORS_FTSTEUTATES is not set
CONFIG_SENSORS_GL518SM=y
# CONFIG_SENSORS_GL520SM is not set
CONFIG_SENSORS_G760A=y
# CONFIG_SENSORS_G762 is not set
# CONFIG_SENSORS_HIH6130 is not set
# CONFIG_SENSORS_I5500 is not set
CONFIG_SENSORS_CORETEMP=y
# CONFIG_SENSORS_IT87 is not set
CONFIG_SENSORS_JC42=y
CONFIG_SENSORS_POWR1220=y
CONFIG_SENSORS_LINEAGE=y
CONFIG_SENSORS_LTC2945=y
CONFIG_SENSORS_LTC2990=y
CONFIG_SENSORS_LTC4151=y
CONFIG_SENSORS_LTC4215=y
CONFIG_SENSORS_LTC4222=y
CONFIG_SENSORS_LTC4245=y
# CONFIG_SENSORS_LTC4260 is not set
CONFIG_SENSORS_LTC4261=y
CONFIG_SENSORS_MAX1111=y
CONFIG_SENSORS_MAX16065=y
CONFIG_SENSORS_MAX1619=y
CONFIG_SENSORS_MAX1668=y
CONFIG_SENSORS_MAX197=y
CONFIG_SENSORS_MAX31722=y
CONFIG_SENSORS_MAX6621=y
CONFIG_SENSORS_MAX6639=y
CONFIG_SENSORS_MAX6642=y
CONFIG_SENSORS_MAX6650=y
CONFIG_SENSORS_MAX6697=y
CONFIG_SENSORS_MAX31790=y
CONFIG_SENSORS_MCP3021=y
CONFIG_SENSORS_TC654=y
CONFIG_SENSORS_MENF21BMC_HWMON=y
# CONFIG_SENSORS_ADCXX is not set
# CONFIG_SENSORS_LM63 is not set
# CONFIG_SENSORS_LM70 is not set
CONFIG_SENSORS_LM73=y
# CONFIG_SENSORS_LM75 is not set
CONFIG_SENSORS_LM77=y
CONFIG_SENSORS_LM78=y
# CONFIG_SENSORS_LM80 is not set
CONFIG_SENSORS_LM83=y
CONFIG_SENSORS_LM85=y
CONFIG_SENSORS_LM87=y
CONFIG_SENSORS_LM90=y
# CONFIG_SENSORS_LM92 is not set
# CONFIG_SENSORS_LM93 is not set
# CONFIG_SENSORS_LM95234 is not set
# CONFIG_SENSORS_LM95241 is not set
CONFIG_SENSORS_LM95245=y
# CONFIG_SENSORS_PC87360 is not set
CONFIG_SENSORS_PC87427=y
# CONFIG_SENSORS_NTC_THERMISTOR is not set
CONFIG_SENSORS_NCT6683=y
# CONFIG_SENSORS_NCT6775 is not set
CONFIG_SENSORS_NCT7802=y
CONFIG_SENSORS_NCT7904=y
CONFIG_SENSORS_PCF8591=y
# CONFIG_PMBUS is not set
CONFIG_SENSORS_SHT15=y
CONFIG_SENSORS_SHT21=y
CONFIG_SENSORS_SHT3x=y
# CONFIG_SENSORS_SHTC1 is not set
CONFIG_SENSORS_SIS5595=y
CONFIG_SENSORS_DME1737=y
CONFIG_SENSORS_EMC1403=y
CONFIG_SENSORS_EMC2103=y
CONFIG_SENSORS_EMC6W201=y
CONFIG_SENSORS_SMSC47M1=y
CONFIG_SENSORS_SMSC47M192=y
# CONFIG_SENSORS_SMSC47B397 is not set
CONFIG_SENSORS_SCH56XX_COMMON=y
CONFIG_SENSORS_SCH5627=y
# CONFIG_SENSORS_SCH5636 is not set
CONFIG_SENSORS_STTS751=y
# CONFIG_SENSORS_SMM665 is not set
CONFIG_SENSORS_ADC128D818=y
# CONFIG_SENSORS_ADS1015 is not set
CONFIG_SENSORS_ADS7828=y
CONFIG_SENSORS_ADS7871=y
CONFIG_SENSORS_AMC6821=y
CONFIG_SENSORS_INA209=y
CONFIG_SENSORS_INA2XX=y
CONFIG_SENSORS_INA3221=y
CONFIG_SENSORS_TC74=y
CONFIG_SENSORS_THMC50=y
# CONFIG_SENSORS_TMP102 is not set
# CONFIG_SENSORS_TMP103 is not set
# CONFIG_SENSORS_TMP108 is not set
# CONFIG_SENSORS_TMP401 is not set
# CONFIG_SENSORS_TMP421 is not set
CONFIG_SENSORS_VIA_CPUTEMP=y
# CONFIG_SENSORS_VIA686A is not set
# CONFIG_SENSORS_VT1211 is not set
CONFIG_SENSORS_VT8231=y
CONFIG_SENSORS_W83781D=y
# CONFIG_SENSORS_W83791D is not set
# CONFIG_SENSORS_W83792D is not set
CONFIG_SENSORS_W83793=y
# CONFIG_SENSORS_W83795 is not set
# CONFIG_SENSORS_W83L785TS is not set
# CONFIG_SENSORS_W83L786NG is not set
# CONFIG_SENSORS_W83627HF is not set
CONFIG_SENSORS_W83627EHF=y

#
# ACPI drivers
#
CONFIG_SENSORS_ACPI_POWER=y
# CONFIG_SENSORS_ATK0110 is not set
CONFIG_THERMAL=y
CONFIG_THERMAL_EMERGENCY_POWEROFF_DELAY_MS=0
CONFIG_THERMAL_HWMON=y
CONFIG_THERMAL_WRITABLE_TRIPS=y
# CONFIG_THERMAL_DEFAULT_GOV_STEP_WISE is not set
# CONFIG_THERMAL_DEFAULT_GOV_FAIR_SHARE is not set
# CONFIG_THERMAL_DEFAULT_GOV_USER_SPACE is not set
CONFIG_THERMAL_DEFAULT_GOV_POWER_ALLOCATOR=y
# CONFIG_THERMAL_GOV_FAIR_SHARE is not set
CONFIG_THERMAL_GOV_STEP_WISE=y
CONFIG_THERMAL_GOV_BANG_BANG=y
CONFIG_THERMAL_GOV_USER_SPACE=y
CONFIG_THERMAL_GOV_POWER_ALLOCATOR=y
# CONFIG_CLOCK_THERMAL is not set
# CONFIG_DEVFREQ_THERMAL is not set
# CONFIG_THERMAL_EMULATION is not set
CONFIG_INTEL_POWERCLAMP=y
CONFIG_INTEL_SOC_DTS_IOSF_CORE=y
CONFIG_INTEL_SOC_DTS_THERMAL=y

#
# ACPI INT340X thermal drivers
#
# CONFIG_INT340X_THERMAL is not set
CONFIG_INTEL_PCH_THERMAL=y
CONFIG_WATCHDOG=y
CONFIG_WATCHDOG_CORE=y
# CONFIG_WATCHDOG_NOWAYOUT is not set
CONFIG_WATCHDOG_HANDLE_BOOT_ENABLED=y
# CONFIG_WATCHDOG_SYSFS is not set

#
# Watchdog Device Drivers
#
# CONFIG_SOFT_WATCHDOG is not set
CONFIG_DA9052_WATCHDOG=y
CONFIG_DA9055_WATCHDOG=y
CONFIG_DA9063_WATCHDOG=y
CONFIG_DA9062_WATCHDOG=y
CONFIG_MENF21BMC_WATCHDOG=y
CONFIG_WDAT_WDT=y
CONFIG_XILINX_WATCHDOG=y
CONFIG_ZIIRAVE_WATCHDOG=y
# CONFIG_CADENCE_WATCHDOG is not set
CONFIG_DW_WATCHDOG=y
CONFIG_TWL4030_WATCHDOG=y
CONFIG_MAX63XX_WATCHDOG=y
CONFIG_RETU_WATCHDOG=y
# CONFIG_ACQUIRE_WDT is not set
CONFIG_ADVANTECH_WDT=y
# CONFIG_ALIM1535_WDT is not set
CONFIG_ALIM7101_WDT=y
CONFIG_F71808E_WDT=y
# CONFIG_SP5100_TCO is not set
CONFIG_SBC_FITPC2_WATCHDOG=y
# CONFIG_EUROTECH_WDT is not set
CONFIG_IB700_WDT=y
CONFIG_IBMASR=y
CONFIG_WAFER_WDT=y
CONFIG_I6300ESB_WDT=y
# CONFIG_IE6XX_WDT is not set
CONFIG_ITCO_WDT=y
CONFIG_ITCO_VENDOR_SUPPORT=y
CONFIG_IT8712F_WDT=y
CONFIG_IT87_WDT=y
# CONFIG_HP_WATCHDOG is not set
CONFIG_KEMPLD_WDT=y
# CONFIG_SC1200_WDT is not set
# CONFIG_PC87413_WDT is not set
CONFIG_NV_TCO=y
CONFIG_60XX_WDT=y
# CONFIG_CPU5_WDT is not set
# CONFIG_SMSC_SCH311X_WDT is not set
CONFIG_SMSC37B787_WDT=y
# CONFIG_VIA_WDT is not set
# CONFIG_W83627HF_WDT is not set
# CONFIG_W83877F_WDT is not set
CONFIG_W83977F_WDT=y
# CONFIG_MACHZ_WDT is not set
CONFIG_SBC_EPX_C3_WATCHDOG=y
CONFIG_INTEL_MEI_WDT=y
CONFIG_NI903X_WDT=y
CONFIG_NIC7018_WDT=y
# CONFIG_MEN_A21_WDT is not set

#
# PCI-based Watchdog Cards
#
CONFIG_PCIPCWATCHDOG=y
CONFIG_WDTPCI=y

#
# USB-based Watchdog Cards
#
CONFIG_USBPCWATCHDOG=y

#
# Watchdog Pretimeout Governors
#
# CONFIG_WATCHDOG_PRETIMEOUT_GOV is not set
CONFIG_SSB_POSSIBLE=y

#
# Sonics Silicon Backplane
#
# CONFIG_SSB is not set
CONFIG_BCMA_POSSIBLE=y
CONFIG_BCMA=y
CONFIG_BCMA_HOST_PCI_POSSIBLE=y
CONFIG_BCMA_HOST_PCI=y
# CONFIG_BCMA_HOST_SOC is not set
CONFIG_BCMA_DRIVER_PCI=y
CONFIG_BCMA_DRIVER_GMAC_CMN=y
CONFIG_BCMA_DRIVER_GPIO=y
CONFIG_BCMA_DEBUG=y

#
# Multifunction device drivers
#
CONFIG_MFD_CORE=y
CONFIG_MFD_AS3711=y
# CONFIG_PMIC_ADP5520 is not set
# CONFIG_MFD_AAT2870_CORE is not set
# CONFIG_MFD_BCM590XX is not set
# CONFIG_MFD_BD9571MWV is not set
CONFIG_MFD_AXP20X=y
CONFIG_MFD_AXP20X_I2C=y
CONFIG_MFD_CROS_EC=y
# CONFIG_MFD_CROS_EC_I2C is not set
# CONFIG_MFD_CROS_EC_SPI is not set
# CONFIG_PMIC_DA903X is not set
CONFIG_PMIC_DA9052=y
CONFIG_MFD_DA9052_SPI=y
# CONFIG_MFD_DA9052_I2C is not set
CONFIG_MFD_DA9055=y
CONFIG_MFD_DA9062=y
CONFIG_MFD_DA9063=y
CONFIG_MFD_DA9150=y
CONFIG_MFD_DLN2=y
CONFIG_MFD_MC13XXX=y
CONFIG_MFD_MC13XXX_SPI=y
# CONFIG_MFD_MC13XXX_I2C is not set
# CONFIG_HTC_PASIC3 is not set
# CONFIG_HTC_I2CPLD is not set
# CONFIG_MFD_INTEL_QUARK_I2C_GPIO is not set
CONFIG_LPC_ICH=y
CONFIG_LPC_SCH=y
CONFIG_INTEL_SOC_PMIC=y
CONFIG_INTEL_SOC_PMIC_CHTWC=y
CONFIG_MFD_INTEL_LPSS=y
# CONFIG_MFD_INTEL_LPSS_ACPI is not set
CONFIG_MFD_INTEL_LPSS_PCI=y
CONFIG_MFD_JANZ_CMODIO=y
CONFIG_MFD_KEMPLD=y
# CONFIG_MFD_88PM800 is not set
CONFIG_MFD_88PM805=y
# CONFIG_MFD_88PM860X is not set
CONFIG_MFD_MAX14577=y
# CONFIG_MFD_MAX77693 is not set
# CONFIG_MFD_MAX77843 is not set
CONFIG_MFD_MAX8907=y
CONFIG_MFD_MAX8925=y
CONFIG_MFD_MAX8997=y
CONFIG_MFD_MAX8998=y
CONFIG_MFD_MT6397=y
CONFIG_MFD_MENF21BMC=y
CONFIG_EZX_PCAP=y
# CONFIG_MFD_VIPERBOARD is not set
CONFIG_MFD_RETU=y
CONFIG_MFD_PCF50633=y
CONFIG_PCF50633_ADC=y
# CONFIG_PCF50633_GPIO is not set
CONFIG_UCB1400_CORE=y
CONFIG_MFD_RDC321X=y
# CONFIG_MFD_RTSX_PCI is not set
# CONFIG_MFD_RT5033 is not set
# CONFIG_MFD_RTSX_USB is not set
CONFIG_MFD_RC5T583=y
CONFIG_MFD_SEC_CORE=y
CONFIG_MFD_SI476X_CORE=y
# CONFIG_MFD_SM501 is not set
CONFIG_MFD_SKY81452=y
CONFIG_MFD_SMSC=y
# CONFIG_ABX500_CORE is not set
CONFIG_MFD_SYSCON=y
CONFIG_MFD_TI_AM335X_TSCADC=y
CONFIG_MFD_LP3943=y
# CONFIG_MFD_LP8788 is not set
# CONFIG_MFD_TI_LMU is not set
# CONFIG_MFD_PALMAS is not set
CONFIG_TPS6105X=y
# CONFIG_TPS65010 is not set
CONFIG_TPS6507X=y
CONFIG_MFD_TPS65086=y
# CONFIG_MFD_TPS65090 is not set
# CONFIG_MFD_TPS65217 is not set
# CONFIG_MFD_TPS68470 is not set
CONFIG_MFD_TI_LP873X=y
# CONFIG_MFD_TPS65218 is not set
# CONFIG_MFD_TPS6586X is not set
# CONFIG_MFD_TPS65910 is not set
CONFIG_MFD_TPS65912=y
# CONFIG_MFD_TPS65912_I2C is not set
CONFIG_MFD_TPS65912_SPI=y
# CONFIG_MFD_TPS80031 is not set
CONFIG_TWL4030_CORE=y
CONFIG_MFD_TWL4030_AUDIO=y
# CONFIG_TWL6040_CORE is not set
# CONFIG_MFD_WL1273_CORE is not set
CONFIG_MFD_LM3533=y
# CONFIG_MFD_TMIO is not set
CONFIG_MFD_VX855=y
CONFIG_MFD_ARIZONA=y
CONFIG_MFD_ARIZONA_I2C=y
# CONFIG_MFD_ARIZONA_SPI is not set
# CONFIG_MFD_CS47L24 is not set
CONFIG_MFD_WM5102=y
# CONFIG_MFD_WM5110 is not set
# CONFIG_MFD_WM8997 is not set
# CONFIG_MFD_WM8998 is not set
CONFIG_MFD_WM8400=y
# CONFIG_MFD_WM831X_I2C is not set
# CONFIG_MFD_WM831X_SPI is not set
# CONFIG_MFD_WM8350_I2C is not set
CONFIG_MFD_WM8994=y
CONFIG_REGULATOR=y
CONFIG_REGULATOR_DEBUG=y
CONFIG_REGULATOR_FIXED_VOLTAGE=y
CONFIG_REGULATOR_VIRTUAL_CONSUMER=y
# CONFIG_REGULATOR_USERSPACE_CONSUMER is not set
# CONFIG_REGULATOR_ACT8865 is not set
CONFIG_REGULATOR_AD5398=y
CONFIG_REGULATOR_ANATOP=y
# CONFIG_REGULATOR_ARIZONA_LDO1 is not set
CONFIG_REGULATOR_ARIZONA_MICSUPP=y
CONFIG_REGULATOR_AS3711=y
CONFIG_REGULATOR_AXP20X=y
CONFIG_REGULATOR_DA9052=y
# CONFIG_REGULATOR_DA9055 is not set
# CONFIG_REGULATOR_DA9062 is not set
CONFIG_REGULATOR_DA9063=y
# CONFIG_REGULATOR_DA9210 is not set
CONFIG_REGULATOR_DA9211=y
CONFIG_REGULATOR_FAN53555=y
# CONFIG_REGULATOR_GPIO is not set
# CONFIG_REGULATOR_ISL9305 is not set
# CONFIG_REGULATOR_ISL6271A is not set
# CONFIG_REGULATOR_LP3971 is not set
CONFIG_REGULATOR_LP3972=y
CONFIG_REGULATOR_LP872X=y
# CONFIG_REGULATOR_LP8755 is not set
CONFIG_REGULATOR_LTC3589=y
CONFIG_REGULATOR_LTC3676=y
CONFIG_REGULATOR_MAX14577=y
CONFIG_REGULATOR_MAX1586=y
CONFIG_REGULATOR_MAX8649=y
# CONFIG_REGULATOR_MAX8660 is not set
# CONFIG_REGULATOR_MAX8907 is not set
CONFIG_REGULATOR_MAX8925=y
# CONFIG_REGULATOR_MAX8952 is not set
CONFIG_REGULATOR_MAX8997=y
# CONFIG_REGULATOR_MAX8998 is not set
CONFIG_REGULATOR_MC13XXX_CORE=y
CONFIG_REGULATOR_MC13783=y
CONFIG_REGULATOR_MC13892=y
CONFIG_REGULATOR_MT6311=y
CONFIG_REGULATOR_MT6323=y
CONFIG_REGULATOR_MT6397=y
CONFIG_REGULATOR_PCAP=y
CONFIG_REGULATOR_PCF50633=y
CONFIG_REGULATOR_PFUZE100=y
CONFIG_REGULATOR_PV88060=y
# CONFIG_REGULATOR_PV88080 is not set
# CONFIG_REGULATOR_PV88090 is not set
CONFIG_REGULATOR_PWM=y
CONFIG_REGULATOR_RC5T583=y
CONFIG_REGULATOR_S2MPA01=y
CONFIG_REGULATOR_S2MPS11=y
CONFIG_REGULATOR_S5M8767=y
CONFIG_REGULATOR_SKY81452=y
# CONFIG_REGULATOR_TPS51632 is not set
# CONFIG_REGULATOR_TPS6105X is not set
# CONFIG_REGULATOR_TPS62360 is not set
# CONFIG_REGULATOR_TPS65023 is not set
CONFIG_REGULATOR_TPS6507X=y
# CONFIG_REGULATOR_TPS65086 is not set
CONFIG_REGULATOR_TPS65132=y
CONFIG_REGULATOR_TPS6524X=y
CONFIG_REGULATOR_TPS65912=y
CONFIG_REGULATOR_TWL4030=y
# CONFIG_REGULATOR_WM8400 is not set
CONFIG_REGULATOR_WM8994=y
# CONFIG_RC_CORE is not set
CONFIG_MEDIA_SUPPORT=y

#
# Multimedia core support
#
CONFIG_MEDIA_CAMERA_SUPPORT=y
CONFIG_MEDIA_ANALOG_TV_SUPPORT=y
# CONFIG_MEDIA_DIGITAL_TV_SUPPORT is not set
CONFIG_MEDIA_RADIO_SUPPORT=y
# CONFIG_MEDIA_SDR_SUPPORT is not set
CONFIG_MEDIA_CEC_SUPPORT=y
# CONFIG_MEDIA_CONTROLLER is not set
CONFIG_VIDEO_DEV=y
CONFIG_VIDEO_V4L2=y
CONFIG_VIDEO_ADV_DEBUG=y
CONFIG_VIDEO_FIXED_MINOR_RANGES=y
CONFIG_VIDEO_PCI_SKELETON=y
CONFIG_V4L2_MEM2MEM_DEV=y
CONFIG_VIDEOBUF_GEN=y
CONFIG_VIDEOBUF_DMA_SG=y
CONFIG_VIDEOBUF2_CORE=y
CONFIG_VIDEOBUF2_MEMOPS=y
CONFIG_VIDEOBUF2_DMA_CONTIG=y
CONFIG_VIDEOBUF2_VMALLOC=y
CONFIG_VIDEOBUF2_DMA_SG=y
# CONFIG_TTPCI_EEPROM is not set

#
# Media drivers
#
# CONFIG_MEDIA_USB_SUPPORT is not set
CONFIG_MEDIA_PCI_SUPPORT=y

#
# Media capture support
#
# CONFIG_VIDEO_SOLO6X10 is not set
CONFIG_VIDEO_TW5864=y
CONFIG_VIDEO_TW68=y
CONFIG_VIDEO_TW686X=y
# CONFIG_VIDEO_ZORAN is not set

#
# Media capture/analog TV support
#
CONFIG_VIDEO_HEXIUM_GEMINI=y
# CONFIG_VIDEO_HEXIUM_ORION is not set
# CONFIG_VIDEO_MXB is not set
CONFIG_VIDEO_DT3155=y

#
# Media capture/analog/hybrid TV support
#
CONFIG_VIDEO_CX25821=y
# CONFIG_VIDEO_CX25821_ALSA is not set
# CONFIG_VIDEO_SAA7134 is not set
# CONFIG_V4L_PLATFORM_DRIVERS is not set
CONFIG_V4L_MEM2MEM_DRIVERS=y
CONFIG_VIDEO_MEM2MEM_DEINTERLACE=y
# CONFIG_VIDEO_SH_VEU is not set
# CONFIG_V4L_TEST_DRIVERS is not set
# CONFIG_CEC_PLATFORM_DRIVERS is not set

#
# Supported MMC/SDIO adapters
#
# CONFIG_RADIO_ADAPTERS is not set
CONFIG_CYPRESS_FIRMWARE=y
CONFIG_VIDEO_SAA7146=y
CONFIG_VIDEO_SAA7146_VV=y

#
# Media ancillary drivers (tuners, sensors, i2c, spi, frontends)
#
CONFIG_MEDIA_SUBDRV_AUTOSELECT=y

#
# Audio decoders, processors and mixers
#

#
# RDS decoders
#

#
# Video decoders
#

#
# Video and audio decoders
#

#
# Video encoders
#

#
# Camera sensor devices
#

#
# Flash devices
#

#
# Video improvement chips
#

#
# Audio/Video compression chips
#

#
# SDR tuner chips
#

#
# Miscellaneous helper chips
#

#
# Sensors used on soc_camera driver
#
CONFIG_MEDIA_TUNER=y
CONFIG_MEDIA_TUNER_SIMPLE=y
CONFIG_MEDIA_TUNER_TDA8290=y
CONFIG_MEDIA_TUNER_TDA827X=y
CONFIG_MEDIA_TUNER_TDA18271=y
CONFIG_MEDIA_TUNER_TDA9887=y
CONFIG_MEDIA_TUNER_TEA5761=y
CONFIG_MEDIA_TUNER_TEA5767=y
CONFIG_MEDIA_TUNER_MT20XX=y
CONFIG_MEDIA_TUNER_XC2028=y
CONFIG_MEDIA_TUNER_XC5000=y
CONFIG_MEDIA_TUNER_XC4000=y
CONFIG_MEDIA_TUNER_MC44S803=y

#
# Tools to develop new frontends
#

#
# Graphics support
#
# CONFIG_AGP is not set
CONFIG_INTEL_GTT=y
CONFIG_VGA_ARB=y
CONFIG_VGA_ARB_MAX_GPUS=16
# CONFIG_VGA_SWITCHEROO is not set
CONFIG_DRM=y
CONFIG_DRM_MIPI_DSI=y
CONFIG_DRM_DP_AUX_CHARDEV=y
CONFIG_DRM_DEBUG_MM=y
# CONFIG_DRM_DEBUG_MM_SELFTEST is not set
CONFIG_DRM_KMS_HELPER=y
CONFIG_DRM_KMS_FB_HELPER=y
CONFIG_DRM_FBDEV_EMULATION=y
CONFIG_DRM_FBDEV_OVERALLOC=100
CONFIG_DRM_LOAD_EDID_FIRMWARE=y
CONFIG_DRM_TTM=y
CONFIG_DRM_GEM_CMA_HELPER=y
CONFIG_DRM_KMS_CMA_HELPER=y
CONFIG_DRM_VM=y

#
# I2C encoder or helper chips
#
# CONFIG_DRM_I2C_CH7006 is not set
CONFIG_DRM_I2C_SIL164=y
CONFIG_DRM_I2C_NXP_TDA998X=y
# CONFIG_DRM_RADEON is not set
CONFIG_DRM_AMDGPU=y
# CONFIG_DRM_AMDGPU_SI is not set
# CONFIG_DRM_AMDGPU_CIK is not set
# CONFIG_DRM_AMDGPU_USERPTR is not set
# CONFIG_DRM_AMDGPU_GART_DEBUGFS is not set

#
# ACP (Audio CoProcessor) Configuration
#
# CONFIG_DRM_AMD_ACP is not set
CONFIG_DRM_NOUVEAU=y
CONFIG_NOUVEAU_DEBUG=5
CONFIG_NOUVEAU_DEBUG_DEFAULT=3
# CONFIG_DRM_NOUVEAU_BACKLIGHT is not set
CONFIG_DRM_I915=y
CONFIG_DRM_I915_ALPHA_SUPPORT=y
# CONFIG_DRM_I915_CAPTURE_ERROR is not set
CONFIG_DRM_I915_USERPTR=y
CONFIG_DRM_I915_GVT=y
CONFIG_DRM_VGEM=y
CONFIG_DRM_VMWGFX=y
# CONFIG_DRM_VMWGFX_FBCON is not set
CONFIG_DRM_GMA500=y
# CONFIG_DRM_GMA600 is not set
CONFIG_DRM_GMA3600=y
CONFIG_DRM_UDL=y
CONFIG_DRM_AST=y
CONFIG_DRM_MGAG200=y
CONFIG_DRM_CIRRUS_QEMU=y
CONFIG_DRM_QXL=y
# CONFIG_DRM_BOCHS is not set
CONFIG_DRM_VIRTIO_GPU=y
CONFIG_DRM_PANEL=y

#
# Display Panels
#
CONFIG_DRM_BRIDGE=y
CONFIG_DRM_PANEL_BRIDGE=y

#
# Display Interface Bridges
#
# CONFIG_DRM_ANALOGIX_ANX78XX is not set
CONFIG_DRM_HISI_HIBMC=y
CONFIG_DRM_TINYDRM=y
CONFIG_TINYDRM_MIPI_DBI=y
CONFIG_TINYDRM_MI0283QT=y
# CONFIG_TINYDRM_REPAPER is not set
CONFIG_TINYDRM_ST7586=y
# CONFIG_DRM_LEGACY is not set
# CONFIG_DRM_LIB_RANDOM is not set

#
# Frame buffer Devices
#
CONFIG_FB=y
# CONFIG_FIRMWARE_EDID is not set
CONFIG_FB_CMDLINE=y
CONFIG_FB_NOTIFY=y
CONFIG_FB_DDC=y
CONFIG_FB_BOOT_VESA_SUPPORT=y
CONFIG_FB_CFB_FILLRECT=y
CONFIG_FB_CFB_COPYAREA=y
CONFIG_FB_CFB_IMAGEBLIT=y
# CONFIG_FB_CFB_REV_PIXELS_IN_BYTE is not set
CONFIG_FB_SYS_FILLRECT=y
CONFIG_FB_SYS_COPYAREA=y
CONFIG_FB_SYS_IMAGEBLIT=y
# CONFIG_FB_PROVIDE_GET_FB_UNMAPPED_AREA is not set
CONFIG_FB_FOREIGN_ENDIAN=y
# CONFIG_FB_BOTH_ENDIAN is not set
# CONFIG_FB_BIG_ENDIAN is not set
CONFIG_FB_LITTLE_ENDIAN=y
CONFIG_FB_SYS_FOPS=y
CONFIG_FB_DEFERRED_IO=y
CONFIG_FB_HECUBA=y
CONFIG_FB_SVGALIB=y
# CONFIG_FB_MACMODES is not set
CONFIG_FB_BACKLIGHT=y
CONFIG_FB_MODE_HELPERS=y
CONFIG_FB_TILEBLITTING=y

#
# Frame buffer hardware drivers
#
CONFIG_FB_CIRRUS=y
CONFIG_FB_PM2=y
# CONFIG_FB_PM2_FIFO_DISCONNECT is not set
CONFIG_FB_CYBER2000=y
CONFIG_FB_CYBER2000_DDC=y
CONFIG_FB_ARC=y
# CONFIG_FB_ASILIANT is not set
# CONFIG_FB_IMSTT is not set
# CONFIG_FB_VGA16 is not set
# CONFIG_FB_VESA is not set
CONFIG_FB_N411=y
CONFIG_FB_HGA=y
CONFIG_FB_OPENCORES=y
CONFIG_FB_S1D13XXX=y
CONFIG_FB_NVIDIA=y
CONFIG_FB_NVIDIA_I2C=y
# CONFIG_FB_NVIDIA_DEBUG is not set
# CONFIG_FB_NVIDIA_BACKLIGHT is not set
# CONFIG_FB_RIVA is not set
CONFIG_FB_I740=y
CONFIG_FB_LE80578=y
CONFIG_FB_CARILLO_RANCH=y
CONFIG_FB_MATROX=y
# CONFIG_FB_MATROX_MILLENIUM is not set
# CONFIG_FB_MATROX_MYSTIQUE is not set
CONFIG_FB_MATROX_G=y
CONFIG_FB_MATROX_I2C=y
CONFIG_FB_MATROX_MAVEN=y
CONFIG_FB_RADEON=y
# CONFIG_FB_RADEON_I2C is not set
# CONFIG_FB_RADEON_BACKLIGHT is not set
# CONFIG_FB_RADEON_DEBUG is not set
CONFIG_FB_ATY128=y
CONFIG_FB_ATY128_BACKLIGHT=y
# CONFIG_FB_ATY is not set
CONFIG_FB_S3=y
CONFIG_FB_S3_DDC=y
# CONFIG_FB_SAVAGE is not set
CONFIG_FB_SIS=y
CONFIG_FB_SIS_300=y
CONFIG_FB_SIS_315=y
# CONFIG_FB_VIA is not set
# CONFIG_FB_NEOMAGIC is not set
CONFIG_FB_KYRO=y
CONFIG_FB_3DFX=y
CONFIG_FB_3DFX_ACCEL=y
# CONFIG_FB_3DFX_I2C is not set
CONFIG_FB_VOODOO1=y
# CONFIG_FB_VT8623 is not set
CONFIG_FB_TRIDENT=y
# CONFIG_FB_ARK is not set
CONFIG_FB_PM3=y
CONFIG_FB_CARMINE=y
# CONFIG_FB_CARMINE_DRAM_EVAL is not set
CONFIG_CARMINE_DRAM_CUSTOM=y
CONFIG_FB_SMSCUFX=y
CONFIG_FB_UDL=y
CONFIG_FB_IBM_GXT4500=y
CONFIG_FB_GOLDFISH=y
# CONFIG_FB_VIRTUAL is not set
CONFIG_FB_METRONOME=y
# CONFIG_FB_MB862XX is not set
# CONFIG_FB_BROADSHEET is not set
# CONFIG_FB_AUO_K190X is not set
# CONFIG_FB_SIMPLE is not set
CONFIG_FB_SM712=y
CONFIG_BACKLIGHT_LCD_SUPPORT=y
CONFIG_LCD_CLASS_DEVICE=y
# CONFIG_LCD_L4F00242T03 is not set
# CONFIG_LCD_LMS283GF05 is not set
# CONFIG_LCD_LTV350QV is not set
CONFIG_LCD_ILI922X=y
CONFIG_LCD_ILI9320=y
CONFIG_LCD_TDO24M=y
# CONFIG_LCD_VGG2432A4 is not set
CONFIG_LCD_PLATFORM=y
# CONFIG_LCD_S6E63M0 is not set
# CONFIG_LCD_LD9040 is not set
CONFIG_LCD_AMS369FG06=y
CONFIG_LCD_LMS501KF03=y
CONFIG_LCD_HX8357=y
CONFIG_BACKLIGHT_CLASS_DEVICE=y
CONFIG_BACKLIGHT_GENERIC=y
CONFIG_BACKLIGHT_LM3533=y
# CONFIG_BACKLIGHT_CARILLO_RANCH is not set
# CONFIG_BACKLIGHT_PWM is not set
CONFIG_BACKLIGHT_DA9052=y
CONFIG_BACKLIGHT_MAX8925=y
CONFIG_BACKLIGHT_APPLE=y
# CONFIG_BACKLIGHT_PM8941_WLED is not set
# CONFIG_BACKLIGHT_SAHARA is not set
CONFIG_BACKLIGHT_ADP8860=y
# CONFIG_BACKLIGHT_ADP8870 is not set
# CONFIG_BACKLIGHT_PCF50633 is not set
CONFIG_BACKLIGHT_LM3630A=y
CONFIG_BACKLIGHT_LM3639=y
CONFIG_BACKLIGHT_LP855X=y
CONFIG_BACKLIGHT_PANDORA=y
# CONFIG_BACKLIGHT_SKY81452 is not set
# CONFIG_BACKLIGHT_AS3711 is not set
# CONFIG_BACKLIGHT_GPIO is not set
CONFIG_BACKLIGHT_LV5207LP=y
# CONFIG_BACKLIGHT_BD6107 is not set
# CONFIG_BACKLIGHT_ARCXCNN is not set
CONFIG_VGASTATE=y
CONFIG_HDMI=y

#
# Console display driver support
#
CONFIG_VGA_CONSOLE=y
# CONFIG_VGACON_SOFT_SCROLLBACK is not set
CONFIG_DUMMY_CONSOLE=y
CONFIG_DUMMY_CONSOLE_COLUMNS=80
CONFIG_DUMMY_CONSOLE_ROWS=25
CONFIG_FRAMEBUFFER_CONSOLE=y
CONFIG_FRAMEBUFFER_CONSOLE_DETECT_PRIMARY=y
CONFIG_FRAMEBUFFER_CONSOLE_ROTATION=y
CONFIG_LOGO=y
# CONFIG_LOGO_LINUX_MONO is not set
CONFIG_LOGO_LINUX_VGA16=y
# CONFIG_LOGO_LINUX_CLUT224 is not set
CONFIG_SOUND=y
# CONFIG_SOUND_OSS_CORE is not set
CONFIG_SND=y
CONFIG_SND_TIMER=y
CONFIG_SND_PCM=y
CONFIG_SND_PCM_ELD=y
CONFIG_SND_PCM_IEC958=y
CONFIG_SND_DMAENGINE_PCM=y
CONFIG_SND_HWDEP=y
CONFIG_SND_SEQ_DEVICE=y
CONFIG_SND_RAWMIDI=y
CONFIG_SND_JACK=y
CONFIG_SND_JACK_INPUT_DEV=y
# CONFIG_SND_OSSEMUL is not set
CONFIG_SND_PCM_TIMER=y
# CONFIG_SND_DYNAMIC_MINORS is not set
# CONFIG_SND_SUPPORT_OLD_API is not set
CONFIG_SND_PROC_FS=y
# CONFIG_SND_VERBOSE_PROCFS is not set
# CONFIG_SND_VERBOSE_PRINTK is not set
# CONFIG_SND_DEBUG is not set
CONFIG_SND_VMASTER=y
CONFIG_SND_DMA_SGBUF=y
CONFIG_SND_SEQUENCER=y
CONFIG_SND_SEQ_DUMMY=y
CONFIG_SND_SEQ_MIDI_EVENT=y
CONFIG_SND_SEQ_MIDI=y
CONFIG_SND_SEQ_MIDI_EMUL=y
CONFIG_SND_SEQ_VIRMIDI=y
CONFIG_SND_MPU401_UART=y
CONFIG_SND_OPL3_LIB=y
CONFIG_SND_OPL3_LIB_SEQ=y
# CONFIG_SND_OPL4_LIB_SEQ is not set
CONFIG_SND_VX_LIB=y
CONFIG_SND_AC97_CODEC=y
CONFIG_SND_DRIVERS=y
CONFIG_SND_DUMMY=y
CONFIG_SND_ALOOP=y
CONFIG_SND_VIRMIDI=y
CONFIG_SND_MTPAV=y
# CONFIG_SND_MTS64 is not set
CONFIG_SND_SERIAL_U16550=y
CONFIG_SND_MPU401=y
CONFIG_SND_PORTMAN2X4=y
CONFIG_SND_AC97_POWER_SAVE=y
CONFIG_SND_AC97_POWER_SAVE_DEFAULT=0
CONFIG_SND_PCI=y
CONFIG_SND_AD1889=y
# CONFIG_SND_ALS300 is not set
# CONFIG_SND_ALS4000 is not set
CONFIG_SND_ALI5451=y
# CONFIG_SND_ASIHPI is not set
# CONFIG_SND_ATIIXP is not set
CONFIG_SND_ATIIXP_MODEM=y
CONFIG_SND_AU8810=y
CONFIG_SND_AU8820=y
# CONFIG_SND_AU8830 is not set
CONFIG_SND_AW2=y
# CONFIG_SND_AZT3328 is not set
# CONFIG_SND_BT87X is not set
CONFIG_SND_CA0106=y
# CONFIG_SND_CMIPCI is not set
# CONFIG_SND_OXYGEN is not set
CONFIG_SND_CS4281=y
CONFIG_SND_CS46XX=y
# CONFIG_SND_CS46XX_NEW_DSP is not set
# CONFIG_SND_CTXFI is not set
CONFIG_SND_DARLA20=y
CONFIG_SND_GINA20=y
CONFIG_SND_LAYLA20=y
CONFIG_SND_DARLA24=y
# CONFIG_SND_GINA24 is not set
# CONFIG_SND_LAYLA24 is not set
CONFIG_SND_MONA=y
# CONFIG_SND_MIA is not set
# CONFIG_SND_ECHO3G is not set
CONFIG_SND_INDIGO=y
CONFIG_SND_INDIGOIO=y
CONFIG_SND_INDIGODJ=y
# CONFIG_SND_INDIGOIOX is not set
CONFIG_SND_INDIGODJX=y
CONFIG_SND_EMU10K1=y
CONFIG_SND_EMU10K1_SEQ=y
CONFIG_SND_EMU10K1X=y
CONFIG_SND_ENS1370=y
# CONFIG_SND_ENS1371 is not set
# CONFIG_SND_ES1938 is not set
# CONFIG_SND_ES1968 is not set
# CONFIG_SND_FM801 is not set
CONFIG_SND_HDSP=y

#
# Don't forget to add built-in firmwares for HDSP driver
#
# CONFIG_SND_HDSPM is not set
CONFIG_SND_ICE1712=y
CONFIG_SND_ICE1724=y
CONFIG_SND_INTEL8X0=y
# CONFIG_SND_INTEL8X0M is not set
CONFIG_SND_KORG1212=y
# CONFIG_SND_LOLA is not set
CONFIG_SND_LX6464ES=y
CONFIG_SND_MAESTRO3=y
# CONFIG_SND_MAESTRO3_INPUT is not set
CONFIG_SND_MIXART=y
CONFIG_SND_NM256=y
CONFIG_SND_PCXHR=y
CONFIG_SND_RIPTIDE=y
CONFIG_SND_RME32=y
CONFIG_SND_RME96=y
CONFIG_SND_RME9652=y
# CONFIG_SND_SE6X is not set
CONFIG_SND_SONICVIBES=y
CONFIG_SND_TRIDENT=y
CONFIG_SND_VIA82XX=y
# CONFIG_SND_VIA82XX_MODEM is not set
# CONFIG_SND_VIRTUOSO is not set
CONFIG_SND_VX222=y
CONFIG_SND_YMFPCI=y

#
# HD-Audio
#
CONFIG_SND_HDA=y
CONFIG_SND_HDA_INTEL=y
# CONFIG_SND_HDA_HWDEP is not set
CONFIG_SND_HDA_RECONFIG=y
CONFIG_SND_HDA_INPUT_BEEP=y
CONFIG_SND_HDA_INPUT_BEEP_MODE=1
# CONFIG_SND_HDA_PATCH_LOADER is not set
# CONFIG_SND_HDA_CODEC_REALTEK is not set
# CONFIG_SND_HDA_CODEC_ANALOG is not set
CONFIG_SND_HDA_CODEC_SIGMATEL=y
CONFIG_SND_HDA_CODEC_VIA=y
# CONFIG_SND_HDA_CODEC_HDMI is not set
CONFIG_SND_HDA_CODEC_CIRRUS=y
# CONFIG_SND_HDA_CODEC_CONEXANT is not set
# CONFIG_SND_HDA_CODEC_CA0110 is not set
# CONFIG_SND_HDA_CODEC_CA0132 is not set
CONFIG_SND_HDA_CODEC_CMEDIA=y
CONFIG_SND_HDA_CODEC_SI3054=y
CONFIG_SND_HDA_GENERIC=y
CONFIG_SND_HDA_POWER_SAVE_DEFAULT=0
CONFIG_SND_HDA_CORE=y
CONFIG_SND_HDA_I915=y
CONFIG_SND_HDA_PREALLOC_SIZE=64
# CONFIG_SND_SPI is not set
# CONFIG_SND_USB is not set
CONFIG_SND_SOC=y
CONFIG_SND_SOC_GENERIC_DMAENGINE_PCM=y
CONFIG_SND_SOC_AMD_ACP=y
CONFIG_SND_SOC_AMD_CZ_RT5645_MACH=y
CONFIG_SND_ATMEL_SOC=y
# CONFIG_SND_DESIGNWARE_I2S is not set

#
# SoC Audio for Freescale CPUs
#

#
# Common SoC Audio options for Freescale CPUs:
#
# CONFIG_SND_SOC_FSL_ASRC is not set
CONFIG_SND_SOC_FSL_SAI=y
CONFIG_SND_SOC_FSL_SSI=y
CONFIG_SND_SOC_FSL_SPDIF=y
CONFIG_SND_SOC_FSL_ESAI=y
# CONFIG_SND_SOC_IMX_AUDMUX is not set
# CONFIG_SND_I2S_HI6210_I2S is not set
CONFIG_SND_SOC_IMG=y
CONFIG_SND_SOC_IMG_I2S_IN=y
# CONFIG_SND_SOC_IMG_I2S_OUT is not set
# CONFIG_SND_SOC_IMG_PARALLEL_OUT is not set
CONFIG_SND_SOC_IMG_SPDIF_IN=y
CONFIG_SND_SOC_IMG_SPDIF_OUT=y
CONFIG_SND_SOC_IMG_PISTACHIO_INTERNAL_DAC=y
# CONFIG_SND_SOC_INTEL_SST_TOPLEVEL is not set

#
# STMicroelectronics STM32 SOC audio support
#
CONFIG_SND_SOC_XTFPGA_I2S=y
CONFIG_ZX_TDM=y
CONFIG_SND_SOC_I2C_AND_SPI=y

#
# CODEC drivers
#
# CONFIG_SND_SOC_AC97_CODEC is not set
CONFIG_SND_SOC_ADAU_UTILS=y
# CONFIG_SND_SOC_ADAU1701 is not set
CONFIG_SND_SOC_ADAU17X1=y
CONFIG_SND_SOC_ADAU1761=y
# CONFIG_SND_SOC_ADAU1761_I2C is not set
CONFIG_SND_SOC_ADAU1761_SPI=y
CONFIG_SND_SOC_ADAU7002=y
# CONFIG_SND_SOC_AK4104 is not set
# CONFIG_SND_SOC_AK4554 is not set
CONFIG_SND_SOC_AK4613=y
CONFIG_SND_SOC_AK4642=y
CONFIG_SND_SOC_AK5386=y
CONFIG_SND_SOC_ALC5623=y
CONFIG_SND_SOC_BT_SCO=y
CONFIG_SND_SOC_CS35L32=y
# CONFIG_SND_SOC_CS35L33 is not set
CONFIG_SND_SOC_CS35L34=y
CONFIG_SND_SOC_CS35L35=y
CONFIG_SND_SOC_CS42L42=y
CONFIG_SND_SOC_CS42L51=y
CONFIG_SND_SOC_CS42L51_I2C=y
# CONFIG_SND_SOC_CS42L52 is not set
CONFIG_SND_SOC_CS42L56=y
CONFIG_SND_SOC_CS42L73=y
CONFIG_SND_SOC_CS4265=y
CONFIG_SND_SOC_CS4270=y
CONFIG_SND_SOC_CS4271=y
CONFIG_SND_SOC_CS4271_I2C=y
CONFIG_SND_SOC_CS4271_SPI=y
CONFIG_SND_SOC_CS42XX8=y
CONFIG_SND_SOC_CS42XX8_I2C=y
# CONFIG_SND_SOC_CS43130 is not set
CONFIG_SND_SOC_CS4349=y
CONFIG_SND_SOC_CS53L30=y
# CONFIG_SND_SOC_DIO2125 is not set
CONFIG_SND_SOC_HDMI_CODEC=y
CONFIG_SND_SOC_ES7134=y
CONFIG_SND_SOC_ES8316=y
CONFIG_SND_SOC_ES8328=y
CONFIG_SND_SOC_ES8328_I2C=y
CONFIG_SND_SOC_ES8328_SPI=y
# CONFIG_SND_SOC_GTM601 is not set
CONFIG_SND_SOC_INNO_RK3036=y
CONFIG_SND_SOC_MAX98504=y
CONFIG_SND_SOC_MAX98927=y
CONFIG_SND_SOC_MAX9860=y
# CONFIG_SND_SOC_MSM8916_WCD_DIGITAL is not set
CONFIG_SND_SOC_PCM1681=y
CONFIG_SND_SOC_PCM179X=y
CONFIG_SND_SOC_PCM179X_I2C=y
CONFIG_SND_SOC_PCM179X_SPI=y
CONFIG_SND_SOC_PCM3168A=y
CONFIG_SND_SOC_PCM3168A_I2C=y
# CONFIG_SND_SOC_PCM3168A_SPI is not set
CONFIG_SND_SOC_PCM512x=y
# CONFIG_SND_SOC_PCM512x_I2C is not set
CONFIG_SND_SOC_PCM512x_SPI=y
CONFIG_SND_SOC_RL6231=y
# CONFIG_SND_SOC_RT5514_SPI_BUILTIN is not set
# CONFIG_SND_SOC_RT5616 is not set
# CONFIG_SND_SOC_RT5631 is not set
CONFIG_SND_SOC_RT5645=y
# CONFIG_SND_SOC_RT5677_SPI is not set
CONFIG_SND_SOC_SGTL5000=y
CONFIG_SND_SOC_SIGMADSP=y
CONFIG_SND_SOC_SIGMADSP_REGMAP=y
# CONFIG_SND_SOC_SIRF_AUDIO_CODEC is not set
CONFIG_SND_SOC_SPDIF=y
CONFIG_SND_SOC_SSM2602=y
CONFIG_SND_SOC_SSM2602_SPI=y
CONFIG_SND_SOC_SSM2602_I2C=y
CONFIG_SND_SOC_SSM4567=y
CONFIG_SND_SOC_STA32X=y
CONFIG_SND_SOC_STA350=y
CONFIG_SND_SOC_STI_SAS=y
CONFIG_SND_SOC_TAS2552=y
# CONFIG_SND_SOC_TAS5086 is not set
# CONFIG_SND_SOC_TAS571X is not set
CONFIG_SND_SOC_TAS5720=y
# CONFIG_SND_SOC_TFA9879 is not set
CONFIG_SND_SOC_TLV320AIC23=y
# CONFIG_SND_SOC_TLV320AIC23_I2C is not set
CONFIG_SND_SOC_TLV320AIC23_SPI=y
CONFIG_SND_SOC_TLV320AIC31XX=y
CONFIG_SND_SOC_TLV320AIC3X=y
# CONFIG_SND_SOC_TS3A227E is not set
CONFIG_SND_SOC_WM8510=y
CONFIG_SND_SOC_WM8523=y
CONFIG_SND_SOC_WM8524=y
CONFIG_SND_SOC_WM8580=y
CONFIG_SND_SOC_WM8711=y
# CONFIG_SND_SOC_WM8728 is not set
CONFIG_SND_SOC_WM8731=y
CONFIG_SND_SOC_WM8737=y
CONFIG_SND_SOC_WM8741=y
CONFIG_SND_SOC_WM8750=y
CONFIG_SND_SOC_WM8753=y
CONFIG_SND_SOC_WM8770=y
CONFIG_SND_SOC_WM8776=y
CONFIG_SND_SOC_WM8804=y
CONFIG_SND_SOC_WM8804_I2C=y
# CONFIG_SND_SOC_WM8804_SPI is not set
# CONFIG_SND_SOC_WM8903 is not set
CONFIG_SND_SOC_WM8960=y
CONFIG_SND_SOC_WM8962=y
# CONFIG_SND_SOC_WM8974 is not set
CONFIG_SND_SOC_WM8978=y
# CONFIG_SND_SOC_WM8985 is not set
CONFIG_SND_SOC_ZX_AUD96P22=y
# CONFIG_SND_SOC_NAU8540 is not set
CONFIG_SND_SOC_NAU8810=y
CONFIG_SND_SOC_NAU8824=y
CONFIG_SND_SOC_TPA6130A2=y
CONFIG_SND_SIMPLE_CARD_UTILS=y
CONFIG_SND_SIMPLE_CARD=y
# CONFIG_SND_X86 is not set
CONFIG_SND_SYNTH_EMUX=y
CONFIG_AC97_BUS=y

#
# HID support
#
CONFIG_HID=y
CONFIG_HID_BATTERY_STRENGTH=y
# CONFIG_HIDRAW is not set
CONFIG_UHID=y
CONFIG_HID_GENERIC=y

#
# Special HID drivers
#
CONFIG_HID_A4TECH=y
CONFIG_HID_ACRUX=y
# CONFIG_HID_ACRUX_FF is not set
CONFIG_HID_APPLE=y
CONFIG_HID_ASUS=y
CONFIG_HID_AUREAL=y
CONFIG_HID_BELKIN=y
# CONFIG_HID_CHERRY is not set
# CONFIG_HID_CHICONY is not set
CONFIG_HID_CORSAIR=y
CONFIG_HID_PRODIKEYS=y
CONFIG_HID_CMEDIA=y
# CONFIG_HID_CYPRESS is not set
CONFIG_HID_DRAGONRISE=y
# CONFIG_DRAGONRISE_FF is not set
CONFIG_HID_EMS_FF=y
CONFIG_HID_ELECOM=y
CONFIG_HID_EZKEY=y
CONFIG_HID_GEMBIRD=y
# CONFIG_HID_GFRM is not set
CONFIG_HID_KEYTOUCH=y
# CONFIG_HID_KYE is not set
# CONFIG_HID_WALTOP is not set
CONFIG_HID_GYRATION=y
CONFIG_HID_ICADE=y
CONFIG_HID_ITE=y
CONFIG_HID_TWINHAN=y
CONFIG_HID_KENSINGTON=y
CONFIG_HID_LCPOWER=y
# CONFIG_HID_LED is not set
CONFIG_HID_LENOVO=y
CONFIG_HID_LOGITECH=y
CONFIG_HID_LOGITECH_HIDPP=y
# CONFIG_LOGITECH_FF is not set
# CONFIG_LOGIRUMBLEPAD2_FF is not set
CONFIG_LOGIG940_FF=y
CONFIG_LOGIWHEELS_FF=y
# CONFIG_HID_MAGICMOUSE is not set
CONFIG_HID_MAYFLASH=y
CONFIG_HID_MICROSOFT=y
CONFIG_HID_MONTEREY=y
CONFIG_HID_MULTITOUCH=y
CONFIG_HID_NTI=y
# CONFIG_HID_ORTEK is not set
# CONFIG_HID_PANTHERLORD is not set
# CONFIG_HID_PETALYNX is not set
CONFIG_HID_PICOLCD=y
CONFIG_HID_PICOLCD_FB=y
CONFIG_HID_PICOLCD_BACKLIGHT=y
CONFIG_HID_PICOLCD_LCD=y
CONFIG_HID_PICOLCD_LEDS=y
CONFIG_HID_PLANTRONICS=y
# CONFIG_HID_PRIMAX is not set
# CONFIG_HID_SAITEK is not set
CONFIG_HID_SAMSUNG=y
CONFIG_HID_SPEEDLINK=y
# CONFIG_HID_STEELSERIES is not set
CONFIG_HID_SUNPLUS=y
# CONFIG_HID_RMI is not set
CONFIG_HID_GREENASIA=y
CONFIG_GREENASIA_FF=y
CONFIG_HID_SMARTJOYPLUS=y
# CONFIG_SMARTJOYPLUS_FF is not set
CONFIG_HID_TIVO=y
CONFIG_HID_TOPSEED=y
# CONFIG_HID_THINGM is not set
CONFIG_HID_THRUSTMASTER=y
# CONFIG_THRUSTMASTER_FF is not set
CONFIG_HID_UDRAW_PS3=y
# CONFIG_HID_WIIMOTE is not set
# CONFIG_HID_XINMO is not set
# CONFIG_HID_ZEROPLUS is not set
CONFIG_HID_ZYDACRON=y
# CONFIG_HID_SENSOR_HUB is not set
CONFIG_HID_ALPS=y

#
# USB HID support
#
# CONFIG_USB_HID is not set
CONFIG_HID_PID=y

#
# I2C HID support
#
# CONFIG_I2C_HID is not set

#
# Intel ISH HID support
#
CONFIG_INTEL_ISH_HID=y
CONFIG_USB_OHCI_LITTLE_ENDIAN=y
CONFIG_USB_SUPPORT=y
CONFIG_USB_COMMON=y
CONFIG_USB_ARCH_HAS_HCD=y
CONFIG_USB=y
# CONFIG_USB_PCI is not set
# CONFIG_USB_ANNOUNCE_NEW_DEVICES is not set

#
# Miscellaneous USB options
#
CONFIG_USB_DEFAULT_PERSIST=y
CONFIG_USB_DYNAMIC_MINORS=y
CONFIG_USB_OTG=y
# CONFIG_USB_OTG_WHITELIST is not set
# CONFIG_USB_OTG_BLACKLIST_HUB is not set
# CONFIG_USB_OTG_FSM is not set
CONFIG_USB_MON=y
CONFIG_USB_WUSB=y
# CONFIG_USB_WUSB_CBAF is not set

#
# USB Host Controller Drivers
#
# CONFIG_USB_C67X00_HCD is not set
CONFIG_USB_XHCI_HCD=y
CONFIG_USB_XHCI_PLATFORM=y
CONFIG_USB_EHCI_HCD=y
CONFIG_USB_EHCI_ROOT_HUB_TT=y
# CONFIG_USB_EHCI_TT_NEWSCHED is not set
CONFIG_USB_EHCI_HCD_PLATFORM=y
# CONFIG_USB_OXU210HP_HCD is not set
CONFIG_USB_ISP116X_HCD=y
# CONFIG_USB_ISP1362_HCD is not set
# CONFIG_USB_FOTG210_HCD is not set
CONFIG_USB_MAX3421_HCD=y
CONFIG_USB_OHCI_HCD=y
CONFIG_USB_OHCI_HCD_PLATFORM=y
CONFIG_USB_U132_HCD=y
CONFIG_USB_SL811_HCD=y
# CONFIG_USB_SL811_HCD_ISO is not set
CONFIG_USB_R8A66597_HCD=y
# CONFIG_USB_HWA_HCD is not set
CONFIG_USB_HCD_BCMA=y
CONFIG_USB_HCD_TEST_MODE=y

#
# USB Device Class drivers
#
# CONFIG_USB_ACM is not set
CONFIG_USB_PRINTER=y
# CONFIG_USB_WDM is not set
CONFIG_USB_TMC=y

#
# NOTE: USB_STORAGE depends on SCSI but BLK_DEV_SD may
#

#
# also be needed; see USB_STORAGE Help for more info
#
# CONFIG_USB_STORAGE is not set

#
# USB Imaging devices
#
CONFIG_USB_MDC800=y
CONFIG_USB_MICROTEK=y
# CONFIG_USBIP_CORE is not set
# CONFIG_USB_MUSB_HDRC is not set
CONFIG_USB_DWC3=y
# CONFIG_USB_DWC3_ULPI is not set
CONFIG_USB_DWC3_HOST=y

#
# Platform Glue Driver Support
#
CONFIG_USB_DWC2=y
CONFIG_USB_DWC2_HOST=y

#
# Gadget/Dual-role mode requires USB Gadget support to be enabled
#
# CONFIG_USB_DWC2_DEBUG is not set
CONFIG_USB_DWC2_TRACK_MISSED_SOFS=y
CONFIG_USB_CHIPIDEA=y
# CONFIG_USB_CHIPIDEA_HOST is not set
# CONFIG_USB_CHIPIDEA_ULPI is not set
CONFIG_USB_ISP1760=y
CONFIG_USB_ISP1760_HCD=y
CONFIG_USB_ISP1760_HOST_ROLE=y

#
# USB port drivers
#
CONFIG_USB_USS720=y
# CONFIG_USB_SERIAL is not set

#
# USB Miscellaneous drivers
#
CONFIG_USB_EMI62=y
# CONFIG_USB_EMI26 is not set
CONFIG_USB_ADUTUX=y
# CONFIG_USB_SEVSEG is not set
CONFIG_USB_RIO500=y
CONFIG_USB_LEGOTOWER=y
# CONFIG_USB_LCD is not set
CONFIG_USB_CYPRESS_CY7C63=y
CONFIG_USB_CYTHERM=y
CONFIG_USB_IDMOUSE=y
CONFIG_USB_FTDI_ELAN=y
CONFIG_USB_APPLEDISPLAY=y
CONFIG_USB_SISUSBVGA=y
# CONFIG_USB_SISUSBVGA_CON is not set
CONFIG_USB_LD=y
# CONFIG_USB_TRANCEVIBRATOR is not set
CONFIG_USB_IOWARRIOR=y
# CONFIG_USB_TEST is not set
# CONFIG_USB_EHSET_TEST_FIXTURE is not set
CONFIG_USB_ISIGHTFW=y
CONFIG_USB_YUREX=y
CONFIG_USB_EZUSB_FX2=y
# CONFIG_USB_HUB_USB251XB is not set
# CONFIG_USB_HSIC_USB3503 is not set
# CONFIG_USB_HSIC_USB4604 is not set
CONFIG_USB_LINK_LAYER_TEST=y
CONFIG_USB_CHAOSKEY=y

#
# USB Physical Layer drivers
#
CONFIG_USB_PHY=y
CONFIG_NOP_USB_XCEIV=y
CONFIG_USB_GPIO_VBUS=y
CONFIG_TAHVO_USB=y
# CONFIG_TAHVO_USB_HOST_BY_DEFAULT is not set
CONFIG_USB_ISP1301=y
# CONFIG_USB_GADGET is not set

#
# USB Power Delivery and Type-C drivers
#
CONFIG_TYPEC=y
# CONFIG_TYPEC_TCPM is not set
CONFIG_TYPEC_UCSI=y
CONFIG_UCSI_ACPI=y
CONFIG_TYPEC_TPS6598X=y
CONFIG_USB_ULPI_BUS=y
CONFIG_UWB=y
# CONFIG_UWB_HWA is not set
CONFIG_UWB_WHCI=y
CONFIG_MMC=y
CONFIG_MMC_BLOCK=y
CONFIG_MMC_BLOCK_MINORS=8
CONFIG_SDIO_UART=y
# CONFIG_MMC_TEST is not set

#
# MMC/SD/SDIO Host Controller Drivers
#
# CONFIG_MMC_DEBUG is not set
CONFIG_MMC_SDHCI=y
CONFIG_MMC_SDHCI_PCI=y
CONFIG_MMC_RICOH_MMC=y
# CONFIG_MMC_SDHCI_ACPI is not set
CONFIG_MMC_SDHCI_PLTFM=y
CONFIG_MMC_WBSD=y
CONFIG_MMC_TIFM_SD=y
CONFIG_MMC_GOLDFISH=y
CONFIG_MMC_SPI=y
CONFIG_MMC_CB710=y
CONFIG_MMC_VIA_SDMMC=y
CONFIG_MMC_VUB300=y
CONFIG_MMC_USHC=y
# CONFIG_MMC_USDHI6ROL0 is not set
CONFIG_MMC_TOSHIBA_PCI=y
CONFIG_MMC_MTK=y
CONFIG_MMC_SDHCI_XENON=y
CONFIG_MEMSTICK=y
CONFIG_MEMSTICK_DEBUG=y

#
# MemoryStick drivers
#
# CONFIG_MEMSTICK_UNSAFE_RESUME is not set
CONFIG_MSPRO_BLOCK=y
CONFIG_MS_BLOCK=y

#
# MemoryStick Host Controller Drivers
#
CONFIG_MEMSTICK_TIFM_MS=y
# CONFIG_MEMSTICK_JMICRON_38X is not set
CONFIG_MEMSTICK_R592=y
CONFIG_NEW_LEDS=y
CONFIG_LEDS_CLASS=y
CONFIG_LEDS_CLASS_FLASH=y
CONFIG_LEDS_BRIGHTNESS_HW_CHANGED=y

#
# LED drivers
#
CONFIG_LEDS_APU=y
CONFIG_LEDS_AS3645A=y
# CONFIG_LEDS_LM3530 is not set
CONFIG_LEDS_LM3533=y
# CONFIG_LEDS_LM3642 is not set
# CONFIG_LEDS_MT6323 is not set
# CONFIG_LEDS_PCA9532 is not set
# CONFIG_LEDS_GPIO is not set
CONFIG_LEDS_LP3944=y
CONFIG_LEDS_LP3952=y
CONFIG_LEDS_LP55XX_COMMON=y
# CONFIG_LEDS_LP5521 is not set
# CONFIG_LEDS_LP5523 is not set
CONFIG_LEDS_LP5562=y
CONFIG_LEDS_LP8501=y
# CONFIG_LEDS_LP8860 is not set
CONFIG_LEDS_CLEVO_MAIL=y
CONFIG_LEDS_PCA955X=y
CONFIG_LEDS_PCA955X_GPIO=y
CONFIG_LEDS_PCA963X=y
CONFIG_LEDS_DA9052=y
# CONFIG_LEDS_DAC124S085 is not set
# CONFIG_LEDS_PWM is not set
# CONFIG_LEDS_REGULATOR is not set
CONFIG_LEDS_BD2802=y
CONFIG_LEDS_INTEL_SS4200=y
CONFIG_LEDS_LT3593=y
CONFIG_LEDS_MC13783=y
CONFIG_LEDS_TCA6507=y
# CONFIG_LEDS_TLC591XX is not set
# CONFIG_LEDS_MAX8997 is not set
# CONFIG_LEDS_LM355x is not set
# CONFIG_LEDS_MENF21BMC is not set

#
# LED driver for blink(1) USB RGB LED is under Special HID drivers (HID_THINGM)
#
# CONFIG_LEDS_BLINKM is not set
# CONFIG_LEDS_MLXCPLD is not set
CONFIG_LEDS_USER=y
CONFIG_LEDS_NIC78BX=y

#
# LED Triggers
#
# CONFIG_LEDS_TRIGGERS is not set
CONFIG_ACCESSIBILITY=y
CONFIG_A11Y_BRAILLE_CONSOLE=y
# CONFIG_INFINIBAND is not set
CONFIG_EDAC_ATOMIC_SCRUB=y
CONFIG_EDAC_SUPPORT=y
# CONFIG_EDAC is not set
CONFIG_RTC_LIB=y
CONFIG_RTC_MC146818_LIB=y
CONFIG_RTC_CLASS=y
# CONFIG_RTC_HCTOSYS is not set
CONFIG_RTC_SYSTOHC=y
CONFIG_RTC_SYSTOHC_DEVICE="rtc0"
CONFIG_RTC_DEBUG=y
CONFIG_RTC_NVMEM=y

#
# RTC interfaces
#
CONFIG_RTC_INTF_SYSFS=y
# CONFIG_RTC_INTF_PROC is not set
# CONFIG_RTC_INTF_DEV is not set
# CONFIG_RTC_DRV_TEST is not set

#
# I2C RTC drivers
#
# CONFIG_RTC_DRV_ABB5ZES3 is not set
# CONFIG_RTC_DRV_ABX80X is not set
# CONFIG_RTC_DRV_DS1307 is not set
# CONFIG_RTC_DRV_DS1374 is not set
# CONFIG_RTC_DRV_DS1672 is not set
CONFIG_RTC_DRV_MAX6900=y
CONFIG_RTC_DRV_MAX8907=y
# CONFIG_RTC_DRV_MAX8925 is not set
CONFIG_RTC_DRV_MAX8998=y
# CONFIG_RTC_DRV_MAX8997 is not set
CONFIG_RTC_DRV_RS5C372=y
# CONFIG_RTC_DRV_ISL1208 is not set
CONFIG_RTC_DRV_ISL12022=y
CONFIG_RTC_DRV_X1205=y
CONFIG_RTC_DRV_PCF8523=y
CONFIG_RTC_DRV_PCF85063=y
CONFIG_RTC_DRV_PCF8563=y
CONFIG_RTC_DRV_PCF8583=y
# CONFIG_RTC_DRV_M41T80 is not set
CONFIG_RTC_DRV_BQ32K=y
CONFIG_RTC_DRV_RC5T583=y
# CONFIG_RTC_DRV_S35390A is not set
# CONFIG_RTC_DRV_FM3130 is not set
CONFIG_RTC_DRV_RX8010=y
CONFIG_RTC_DRV_RX8581=y
CONFIG_RTC_DRV_RX8025=y
# CONFIG_RTC_DRV_EM3027 is not set
CONFIG_RTC_DRV_RV8803=y
# CONFIG_RTC_DRV_S5M is not set

#
# SPI RTC drivers
#
CONFIG_RTC_DRV_M41T93=y
CONFIG_RTC_DRV_M41T94=y
CONFIG_RTC_DRV_DS1302=y
# CONFIG_RTC_DRV_DS1305 is not set
CONFIG_RTC_DRV_DS1343=y
CONFIG_RTC_DRV_DS1347=y
CONFIG_RTC_DRV_DS1390=y
# CONFIG_RTC_DRV_MAX6916 is not set
# CONFIG_RTC_DRV_R9701 is not set
CONFIG_RTC_DRV_RX4581=y
# CONFIG_RTC_DRV_RX6110 is not set
# CONFIG_RTC_DRV_RS5C348 is not set
CONFIG_RTC_DRV_MAX6902=y
CONFIG_RTC_DRV_PCF2123=y
CONFIG_RTC_DRV_MCP795=y
CONFIG_RTC_I2C_AND_SPI=y

#
# SPI and I2C RTC drivers
#
CONFIG_RTC_DRV_DS3232=y
# CONFIG_RTC_DRV_DS3232_HWMON is not set
CONFIG_RTC_DRV_PCF2127=y
# CONFIG_RTC_DRV_RV3029C2 is not set

#
# Platform RTC drivers
#
# CONFIG_RTC_DRV_CMOS is not set
# CONFIG_RTC_DRV_DS1286 is not set
CONFIG_RTC_DRV_DS1511=y
CONFIG_RTC_DRV_DS1553=y
# CONFIG_RTC_DRV_DS1685_FAMILY is not set
# CONFIG_RTC_DRV_DS1742 is not set
CONFIG_RTC_DRV_DS2404=y
CONFIG_RTC_DRV_DA9052=y
# CONFIG_RTC_DRV_DA9055 is not set
CONFIG_RTC_DRV_DA9063=y
# CONFIG_RTC_DRV_STK17TA8 is not set
# CONFIG_RTC_DRV_M48T86 is not set
# CONFIG_RTC_DRV_M48T35 is not set
CONFIG_RTC_DRV_M48T59=y
CONFIG_RTC_DRV_MSM6242=y
# CONFIG_RTC_DRV_BQ4802 is not set
CONFIG_RTC_DRV_RP5C01=y
# CONFIG_RTC_DRV_V3020 is not set
# CONFIG_RTC_DRV_PCF50633 is not set

#
# on-CPU RTC drivers
#
# CONFIG_RTC_DRV_FTRTC010 is not set
# CONFIG_RTC_DRV_PCAP is not set
CONFIG_RTC_DRV_MC13XXX=y
CONFIG_RTC_DRV_MT6397=y

#
# HID Sensor RTC drivers
#
CONFIG_DMADEVICES=y
CONFIG_DMADEVICES_DEBUG=y
CONFIG_DMADEVICES_VDEBUG=y

#
# DMA Devices
#
CONFIG_DMA_ENGINE=y
CONFIG_DMA_VIRTUAL_CHANNELS=y
CONFIG_DMA_ACPI=y
# CONFIG_ALTERA_MSGDMA is not set
CONFIG_INTEL_IDMA64=y
# CONFIG_INTEL_IOATDMA is not set
CONFIG_QCOM_HIDMA_MGMT=y
CONFIG_QCOM_HIDMA=y
CONFIG_DW_DMAC_CORE=y
# CONFIG_DW_DMAC is not set
CONFIG_DW_DMAC_PCI=y
CONFIG_HSU_DMA=y

#
# DMA Clients
#
CONFIG_ASYNC_TX_DMA=y
CONFIG_DMATEST=y
CONFIG_DMA_ENGINE_RAID=y

#
# DMABUF options
#
CONFIG_SYNC_FILE=y
# CONFIG_SW_SYNC is not set
CONFIG_AUXDISPLAY=y
# CONFIG_HD44780 is not set
CONFIG_KS0108=y
CONFIG_KS0108_PORT=0x378
CONFIG_KS0108_DELAY=2
CONFIG_CFAG12864B=y
CONFIG_CFAG12864B_RATE=20
CONFIG_IMG_ASCII_LCD=y
# CONFIG_PANEL is not set
CONFIG_UIO=y
CONFIG_UIO_CIF=y
CONFIG_UIO_PDRV_GENIRQ=y
CONFIG_UIO_DMEM_GENIRQ=y
# CONFIG_UIO_AEC is not set
CONFIG_UIO_SERCOS3=y
CONFIG_UIO_PCI_GENERIC=y
CONFIG_UIO_NETX=y
CONFIG_UIO_PRUSS=y
CONFIG_UIO_MF624=y
CONFIG_VIRT_DRIVERS=y
CONFIG_VIRTIO=y

#
# Virtio drivers
#
# CONFIG_VIRTIO_PCI is not set
# CONFIG_VIRTIO_BALLOON is not set
# CONFIG_VIRTIO_INPUT is not set
# CONFIG_VIRTIO_MMIO is not set

#
# Microsoft Hyper-V guest support
#
# CONFIG_HYPERV is not set
# CONFIG_HYPERV_TSCPAGE is not set
# CONFIG_STAGING is not set
CONFIG_X86_PLATFORM_DEVICES=y
CONFIG_ACER_WMI=y
# CONFIG_ACERHDF is not set
CONFIG_ALIENWARE_WMI=y
CONFIG_ASUS_LAPTOP=y
CONFIG_DELL_SMBIOS=y
# CONFIG_DELL_LAPTOP is not set
CONFIG_DELL_WMI=y
# CONFIG_DELL_WMI_AIO is not set
CONFIG_DELL_WMI_LED=y
# CONFIG_DELL_SMO8800 is not set
# CONFIG_FUJITSU_LAPTOP is not set
CONFIG_FUJITSU_TABLET=y
CONFIG_HP_ACCEL=y
CONFIG_HP_WIRELESS=y
CONFIG_HP_WMI=y
# CONFIG_PANASONIC_LAPTOP is not set
CONFIG_SURFACE3_WMI=y
# CONFIG_THINKPAD_ACPI is not set
# CONFIG_SENSORS_HDAPS is not set
# CONFIG_INTEL_MENLOW is not set
CONFIG_EEEPC_LAPTOP=y
# CONFIG_ASUS_WMI is not set
CONFIG_ASUS_WIRELESS=y
CONFIG_ACPI_WMI=y
CONFIG_WMI_BMOF=y
CONFIG_MSI_WMI=y
CONFIG_PEAQ_WMI=y
CONFIG_TOPSTAR_LAPTOP=y
CONFIG_TOSHIBA_BT_RFKILL=y
# CONFIG_TOSHIBA_HAPS is not set
CONFIG_TOSHIBA_WMI=y
CONFIG_ACPI_CMPC=y
# CONFIG_INTEL_CHT_INT33FE is not set
# CONFIG_INTEL_INT0002_VGPIO is not set
CONFIG_INTEL_HID_EVENT=y
# CONFIG_INTEL_VBTN is not set
# CONFIG_INTEL_IPS is not set
CONFIG_INTEL_PMC_CORE=y
CONFIG_IBM_RTL=y
CONFIG_SAMSUNG_LAPTOP=y
CONFIG_MXM_WMI=y
CONFIG_SAMSUNG_Q10=y
# CONFIG_APPLE_GMUX is not set
CONFIG_INTEL_RST=y
CONFIG_INTEL_SMARTCONNECT=y
CONFIG_PVPANIC=y
# CONFIG_INTEL_PMC_IPC is not set
CONFIG_SURFACE_PRO3_BUTTON=y
CONFIG_SURFACE_3_BUTTON=y
CONFIG_INTEL_PUNIT_IPC=y
# CONFIG_MLX_PLATFORM is not set
# CONFIG_MLX_CPLD_PLATFORM is not set
CONFIG_PMC_ATOM=y
# CONFIG_GOLDFISH_BUS is not set
CONFIG_GOLDFISH_PIPE=y
CONFIG_CHROME_PLATFORMS=y
CONFIG_CHROMEOS_LAPTOP=y
CONFIG_CHROMEOS_PSTORE=y
# CONFIG_CROS_EC_CHARDEV is not set
CONFIG_CROS_EC_LPC=y
# CONFIG_CROS_EC_LPC_MEC is not set
CONFIG_CROS_EC_PROTO=y
CONFIG_CROS_KBD_LED_BACKLIGHT=y
CONFIG_CLKDEV_LOOKUP=y
CONFIG_HAVE_CLK_PREPARE=y
CONFIG_COMMON_CLK=y

#
# Common Clock Framework
#
CONFIG_COMMON_CLK_SI5351=y
CONFIG_COMMON_CLK_CDCE706=y
CONFIG_COMMON_CLK_CS2000_CP=y
CONFIG_COMMON_CLK_S2MPS11=y
# CONFIG_COMMON_CLK_NXP is not set
CONFIG_COMMON_CLK_PWM=y
# CONFIG_COMMON_CLK_PXA is not set
# CONFIG_COMMON_CLK_PIC32 is not set
# CONFIG_HWSPINLOCK is not set

#
# Clock Source drivers
#
CONFIG_CLKEVT_I8253=y
CONFIG_I8253_LOCK=y
CONFIG_CLKBLD_I8253=y
# CONFIG_ATMEL_PIT is not set
# CONFIG_SH_TIMER_CMT is not set
# CONFIG_SH_TIMER_MTU2 is not set
# CONFIG_SH_TIMER_TMU is not set
# CONFIG_EM_TIMER_STI is not set
CONFIG_MAILBOX=y
# CONFIG_PCC is not set
CONFIG_ALTERA_MBOX=y
# CONFIG_IOMMU_SUPPORT is not set

#
# Remoteproc drivers
#
CONFIG_REMOTEPROC=y

#
# Rpmsg drivers
#
# CONFIG_RPMSG_QCOM_GLINK_RPM is not set

#
# SOC (System On Chip) specific Drivers
#

#
# Amlogic SoC drivers
#

#
# Broadcom SoC drivers
#

#
# i.MX SoC drivers
#

#
# Qualcomm SoC drivers
#
# CONFIG_SUNXI_SRAM is not set
CONFIG_SOC_TI=y
CONFIG_PM_DEVFREQ=y

#
# DEVFREQ Governors
#
CONFIG_DEVFREQ_GOV_SIMPLE_ONDEMAND=y
# CONFIG_DEVFREQ_GOV_PERFORMANCE is not set
CONFIG_DEVFREQ_GOV_POWERSAVE=y
CONFIG_DEVFREQ_GOV_USERSPACE=y
# CONFIG_DEVFREQ_GOV_PASSIVE is not set

#
# DEVFREQ Drivers
#
# CONFIG_PM_DEVFREQ_EVENT is not set
CONFIG_EXTCON=y

#
# Extcon Device Drivers
#
# CONFIG_EXTCON_ARIZONA is not set
# CONFIG_EXTCON_AXP288 is not set
CONFIG_EXTCON_GPIO=y
# CONFIG_EXTCON_INTEL_INT3496 is not set
# CONFIG_EXTCON_INTEL_CHT_WC is not set
# CONFIG_EXTCON_MAX14577 is not set
CONFIG_EXTCON_MAX3355=y
CONFIG_EXTCON_MAX8997=y
CONFIG_EXTCON_RT8973A=y
# CONFIG_EXTCON_SM5502 is not set
# CONFIG_EXTCON_USB_GPIO is not set
CONFIG_EXTCON_USBC_CROS_EC=y
CONFIG_MEMORY=y
# CONFIG_IIO is not set
# CONFIG_NTB is not set
CONFIG_VME_BUS=y

#
# VME Bridge Drivers
#
CONFIG_VME_CA91CX42=y
CONFIG_VME_TSI148=y
CONFIG_VME_FAKE=y

#
# VME Board Drivers
#
# CONFIG_VMIVME_7805 is not set

#
# VME Device Drivers
#
CONFIG_PWM=y
CONFIG_PWM_SYSFS=y
# CONFIG_PWM_CRC is not set
CONFIG_PWM_CROS_EC=y
# CONFIG_PWM_LP3943 is not set
CONFIG_PWM_LPSS=y
CONFIG_PWM_LPSS_PCI=y
# CONFIG_PWM_LPSS_PLATFORM is not set
CONFIG_PWM_PCA9685=y
# CONFIG_PWM_TWL is not set
CONFIG_PWM_TWL_LED=y

#
# IRQ chip support
#
CONFIG_ARM_GIC_MAX_NR=1
CONFIG_IPACK_BUS=y
CONFIG_BOARD_TPCI200=y
# CONFIG_SERIAL_IPOCTAL is not set
CONFIG_RESET_CONTROLLER=y
# CONFIG_RESET_ATH79 is not set
# CONFIG_RESET_BERLIN is not set
# CONFIG_RESET_IMX7 is not set
# CONFIG_RESET_LANTIQ is not set
# CONFIG_RESET_LPC18XX is not set
# CONFIG_RESET_MESON is not set
# CONFIG_RESET_PISTACHIO is not set
# CONFIG_RESET_SOCFPGA is not set
# CONFIG_RESET_STM32 is not set
# CONFIG_RESET_SUNXI is not set
CONFIG_RESET_TI_SYSCON=y
# CONFIG_RESET_ZYNQ is not set
# CONFIG_RESET_TEGRA_BPMP is not set
CONFIG_FMC=y
CONFIG_FMC_FAKEDEV=y
CONFIG_FMC_TRIVIAL=y
CONFIG_FMC_WRITE_EEPROM=y
CONFIG_FMC_CHARDEV=y

#
# PHY Subsystem
#
CONFIG_GENERIC_PHY=y
CONFIG_BCM_KONA_USB2_PHY=y
# CONFIG_PHY_PXA_28NM_HSIC is not set
CONFIG_PHY_PXA_28NM_USB2=y
# CONFIG_PHY_QCOM_USB_HS is not set
# CONFIG_PHY_QCOM_USB_HSIC is not set
CONFIG_PHY_SAMSUNG_USB2=y
# CONFIG_PHY_EXYNOS4210_USB2 is not set
# CONFIG_PHY_EXYNOS4X12_USB2 is not set
# CONFIG_PHY_EXYNOS5250_USB2 is not set
CONFIG_PHY_TUSB1210=y
# CONFIG_POWERCAP is not set
# CONFIG_MCB is not set

#
# Performance monitor support
#
CONFIG_RAS=y
# CONFIG_THUNDERBOLT is not set

#
# Android
#
# CONFIG_ANDROID is not set
# CONFIG_LIBNVDIMM is not set
CONFIG_DAX=y
CONFIG_NVMEM=y
CONFIG_STM=y
CONFIG_STM_DUMMY=y
# CONFIG_STM_SOURCE_CONSOLE is not set
# CONFIG_STM_SOURCE_HEARTBEAT is not set
CONFIG_INTEL_TH=y
CONFIG_INTEL_TH_PCI=y
# CONFIG_INTEL_TH_GTH is not set
# CONFIG_INTEL_TH_STH is not set
CONFIG_INTEL_TH_MSU=y
# CONFIG_INTEL_TH_PTI is not set
CONFIG_INTEL_TH_DEBUG=y
CONFIG_FPGA=y
CONFIG_FPGA_MGR_ALTERA_CVP=y
CONFIG_FPGA_MGR_ALTERA_PS_SPI=y
# CONFIG_FPGA_MGR_XILINX_SPI is not set
CONFIG_ALTERA_PR_IP_CORE=y

#
# FSI support
#
# CONFIG_FSI is not set
CONFIG_PM_OPP=y

#
# Firmware Drivers
#
CONFIG_EDD=y
CONFIG_EDD_OFF=y
CONFIG_FIRMWARE_MEMMAP=y
# CONFIG_DELL_RBU is not set
CONFIG_DCDBAS=y
# CONFIG_DMIID is not set
CONFIG_DMI_SYSFS=y
CONFIG_DMI_SCAN_MACHINE_NON_EFI_FALLBACK=y
CONFIG_ISCSI_IBFT_FIND=y
# CONFIG_ISCSI_IBFT is not set
CONFIG_FW_CFG_SYSFS=y
# CONFIG_FW_CFG_SYSFS_CMDLINE is not set
CONFIG_GOOGLE_FIRMWARE=y
# CONFIG_GOOGLE_COREBOOT_TABLE_ACPI is not set
CONFIG_GOOGLE_MEMCONSOLE=y
CONFIG_GOOGLE_MEMCONSOLE_X86_LEGACY=y
# CONFIG_EFI_DEV_PATH_PARSER is not set

#
# Tegra firmware driver
#

#
# File systems
#
CONFIG_DCACHE_WORD_ACCESS=y
CONFIG_FS_IOMAP=y
CONFIG_EXT2_FS=y
CONFIG_EXT2_FS_XATTR=y
# CONFIG_EXT2_FS_POSIX_ACL is not set
CONFIG_EXT2_FS_SECURITY=y
CONFIG_EXT3_FS=y
CONFIG_EXT3_FS_POSIX_ACL=y
# CONFIG_EXT3_FS_SECURITY is not set
CONFIG_EXT4_FS=y
CONFIG_EXT4_FS_POSIX_ACL=y
CONFIG_EXT4_FS_SECURITY=y
# CONFIG_EXT4_ENCRYPTION is not set
# CONFIG_EXT4_DEBUG is not set
CONFIG_JBD2=y
# CONFIG_JBD2_DEBUG is not set
CONFIG_FS_MBCACHE=y
CONFIG_REISERFS_FS=y
CONFIG_REISERFS_CHECK=y
CONFIG_REISERFS_PROC_INFO=y
CONFIG_REISERFS_FS_XATTR=y
# CONFIG_REISERFS_FS_POSIX_ACL is not set
CONFIG_REISERFS_FS_SECURITY=y
# CONFIG_JFS_FS is not set
CONFIG_XFS_FS=y
# CONFIG_XFS_QUOTA is not set
CONFIG_XFS_POSIX_ACL=y
# CONFIG_XFS_RT is not set
# CONFIG_XFS_ONLINE_SCRUB is not set
CONFIG_XFS_WARN=y
# CONFIG_XFS_DEBUG is not set
CONFIG_GFS2_FS=y
# CONFIG_OCFS2_FS is not set
CONFIG_BTRFS_FS=y
CONFIG_BTRFS_FS_POSIX_ACL=y
CONFIG_BTRFS_FS_CHECK_INTEGRITY=y
# CONFIG_BTRFS_FS_RUN_SANITY_TESTS is not set
CONFIG_BTRFS_DEBUG=y
# CONFIG_BTRFS_ASSERT is not set
CONFIG_BTRFS_FS_REF_VERIFY=y
CONFIG_NILFS2_FS=y
CONFIG_F2FS_FS=y
CONFIG_F2FS_STAT_FS=y
# CONFIG_F2FS_FS_XATTR is not set
CONFIG_F2FS_CHECK_FS=y
CONFIG_F2FS_FAULT_INJECTION=y
CONFIG_FS_DAX=y
CONFIG_FS_POSIX_ACL=y
CONFIG_EXPORTFS=y
CONFIG_EXPORTFS_BLOCK_OPS=y
CONFIG_FILE_LOCKING=y
CONFIG_MANDATORY_FILE_LOCKING=y
CONFIG_FS_ENCRYPTION=y
CONFIG_FSNOTIFY=y
CONFIG_DNOTIFY=y
CONFIG_INOTIFY_USER=y
CONFIG_FANOTIFY=y
CONFIG_FANOTIFY_ACCESS_PERMISSIONS=y
CONFIG_QUOTA=y
# CONFIG_QUOTA_NETLINK_INTERFACE is not set
CONFIG_PRINT_QUOTA_WARNING=y
# CONFIG_QUOTA_DEBUG is not set
# CONFIG_QFMT_V1 is not set
# CONFIG_QFMT_V2 is not set
CONFIG_QUOTACTL=y
# CONFIG_AUTOFS4_FS is not set
CONFIG_FUSE_FS=y
CONFIG_CUSE=y
# CONFIG_OVERLAY_FS is not set

#
# Caches
#
CONFIG_FSCACHE=y
# CONFIG_FSCACHE_STATS is not set
CONFIG_FSCACHE_HISTOGRAM=y
# CONFIG_FSCACHE_DEBUG is not set
CONFIG_FSCACHE_OBJECT_LIST=y
CONFIG_CACHEFILES=y
# CONFIG_CACHEFILES_DEBUG is not set
# CONFIG_CACHEFILES_HISTOGRAM is not set

#
# CD-ROM/DVD Filesystems
#
# CONFIG_ISO9660_FS is not set
CONFIG_UDF_FS=y
CONFIG_UDF_NLS=y

#
# DOS/FAT/NT Filesystems
#
CONFIG_FAT_FS=y
CONFIG_MSDOS_FS=y
CONFIG_VFAT_FS=y
CONFIG_FAT_DEFAULT_CODEPAGE=437
CONFIG_FAT_DEFAULT_IOCHARSET="iso8859-1"
# CONFIG_FAT_DEFAULT_UTF8 is not set
# CONFIG_NTFS_FS is not set

#
# Pseudo filesystems
#
CONFIG_PROC_FS=y
# CONFIG_PROC_KCORE is not set
CONFIG_PROC_SYSCTL=y
CONFIG_PROC_PAGE_MONITOR=y
# CONFIG_PROC_CHILDREN is not set
CONFIG_KERNFS=y
CONFIG_SYSFS=y
CONFIG_TMPFS=y
CONFIG_TMPFS_POSIX_ACL=y
CONFIG_TMPFS_XATTR=y
CONFIG_HUGETLBFS=y
CONFIG_HUGETLB_PAGE=y
CONFIG_CONFIGFS_FS=y
CONFIG_MISC_FILESYSTEMS=y
CONFIG_ORANGEFS_FS=y
CONFIG_ADFS_FS=y
CONFIG_ADFS_FS_RW=y
# CONFIG_AFFS_FS is not set
# CONFIG_ECRYPT_FS is not set
# CONFIG_HFS_FS is not set
# CONFIG_HFSPLUS_FS is not set
# CONFIG_BEFS_FS is not set
# CONFIG_BFS_FS is not set
CONFIG_EFS_FS=y
CONFIG_JFFS2_FS=y
CONFIG_JFFS2_FS_DEBUG=0
CONFIG_JFFS2_FS_WRITEBUFFER=y
CONFIG_JFFS2_FS_WBUF_VERIFY=y
CONFIG_JFFS2_SUMMARY=y
CONFIG_JFFS2_FS_XATTR=y
CONFIG_JFFS2_FS_POSIX_ACL=y
# CONFIG_JFFS2_FS_SECURITY is not set
CONFIG_JFFS2_COMPRESSION_OPTIONS=y
CONFIG_JFFS2_ZLIB=y
# CONFIG_JFFS2_LZO is not set
# CONFIG_JFFS2_RTIME is not set
# CONFIG_JFFS2_RUBIN is not set
# CONFIG_JFFS2_CMODE_NONE is not set
# CONFIG_JFFS2_CMODE_PRIORITY is not set
CONFIG_JFFS2_CMODE_SIZE=y
# CONFIG_JFFS2_CMODE_FAVOURLZO is not set
CONFIG_UBIFS_FS=y
# CONFIG_UBIFS_FS_ADVANCED_COMPR is not set
CONFIG_UBIFS_FS_LZO=y
CONFIG_UBIFS_FS_ZLIB=y
CONFIG_UBIFS_ATIME_SUPPORT=y
# CONFIG_UBIFS_FS_ENCRYPTION is not set
CONFIG_UBIFS_FS_SECURITY=y
# CONFIG_CRAMFS is not set
CONFIG_SQUASHFS=y
# CONFIG_SQUASHFS_FILE_CACHE is not set
CONFIG_SQUASHFS_FILE_DIRECT=y
# CONFIG_SQUASHFS_DECOMP_SINGLE is not set
# CONFIG_SQUASHFS_DECOMP_MULTI is not set
CONFIG_SQUASHFS_DECOMP_MULTI_PERCPU=y
CONFIG_SQUASHFS_XATTR=y
# CONFIG_SQUASHFS_ZLIB is not set
# CONFIG_SQUASHFS_LZ4 is not set
CONFIG_SQUASHFS_LZO=y
CONFIG_SQUASHFS_XZ=y
# CONFIG_SQUASHFS_ZSTD is not set
# CONFIG_SQUASHFS_4K_DEVBLK_SIZE is not set
# CONFIG_SQUASHFS_EMBEDDED is not set
CONFIG_SQUASHFS_FRAGMENT_CACHE_SIZE=3
CONFIG_VXFS_FS=y
CONFIG_MINIX_FS=y
CONFIG_OMFS_FS=y
CONFIG_HPFS_FS=y
CONFIG_QNX4FS_FS=y
CONFIG_QNX6FS_FS=y
CONFIG_QNX6FS_DEBUG=y
# CONFIG_ROMFS_FS is not set
# CONFIG_PSTORE is not set
CONFIG_SYSV_FS=y
CONFIG_UFS_FS=y
CONFIG_UFS_FS_WRITE=y
# CONFIG_UFS_DEBUG is not set
CONFIG_NETWORK_FILESYSTEMS=y
CONFIG_NFS_FS=y
CONFIG_NFS_V2=y
CONFIG_NFS_V3=y
# CONFIG_NFS_V3_ACL is not set
CONFIG_NFS_V4=y
# CONFIG_NFS_SWAP is not set
# CONFIG_NFS_V4_1 is not set
# CONFIG_ROOT_NFS is not set
# CONFIG_NFS_FSCACHE is not set
# CONFIG_NFS_USE_LEGACY_DNS is not set
CONFIG_NFS_USE_KERNEL_DNS=y
# CONFIG_NFSD is not set
CONFIG_GRACE_PERIOD=y
CONFIG_LOCKD=y
CONFIG_LOCKD_V4=y
CONFIG_NFS_COMMON=y
CONFIG_SUNRPC=y
CONFIG_SUNRPC_GSS=y
CONFIG_RPCSEC_GSS_KRB5=y
# CONFIG_SUNRPC_DEBUG is not set
# CONFIG_CEPH_FS is not set
CONFIG_CIFS=y
# CONFIG_CIFS_STATS is not set
# CONFIG_CIFS_WEAK_PW_HASH is not set
# CONFIG_CIFS_UPCALL is not set
# CONFIG_CIFS_XATTR is not set
CONFIG_CIFS_DEBUG=y
# CONFIG_CIFS_DEBUG2 is not set
# CONFIG_CIFS_DEBUG_DUMP_KEYS is not set
# CONFIG_CIFS_DFS_UPCALL is not set
# CONFIG_CIFS_SMB311 is not set
# CONFIG_CIFS_FSCACHE is not set
# CONFIG_NCP_FS is not set
# CONFIG_CODA_FS is not set
# CONFIG_AFS_FS is not set
# CONFIG_9P_FS is not set
CONFIG_NLS=y
CONFIG_NLS_DEFAULT="iso8859-1"
# CONFIG_NLS_CODEPAGE_437 is not set
CONFIG_NLS_CODEPAGE_737=y
CONFIG_NLS_CODEPAGE_775=y
CONFIG_NLS_CODEPAGE_850=y
CONFIG_NLS_CODEPAGE_852=y
# CONFIG_NLS_CODEPAGE_855 is not set
# CONFIG_NLS_CODEPAGE_857 is not set
# CONFIG_NLS_CODEPAGE_860 is not set
CONFIG_NLS_CODEPAGE_861=y
# CONFIG_NLS_CODEPAGE_862 is not set
CONFIG_NLS_CODEPAGE_863=y
CONFIG_NLS_CODEPAGE_864=y
CONFIG_NLS_CODEPAGE_865=y
# CONFIG_NLS_CODEPAGE_866 is not set
CONFIG_NLS_CODEPAGE_869=y
CONFIG_NLS_CODEPAGE_936=y
CONFIG_NLS_CODEPAGE_950=y
# CONFIG_NLS_CODEPAGE_932 is not set
CONFIG_NLS_CODEPAGE_949=y
CONFIG_NLS_CODEPAGE_874=y
CONFIG_NLS_ISO8859_8=y
CONFIG_NLS_CODEPAGE_1250=y
CONFIG_NLS_CODEPAGE_1251=y
# CONFIG_NLS_ASCII is not set
CONFIG_NLS_ISO8859_1=y
# CONFIG_NLS_ISO8859_2 is not set
# CONFIG_NLS_ISO8859_3 is not set
CONFIG_NLS_ISO8859_4=y
CONFIG_NLS_ISO8859_5=y
CONFIG_NLS_ISO8859_6=y
CONFIG_NLS_ISO8859_7=y
CONFIG_NLS_ISO8859_9=y
CONFIG_NLS_ISO8859_13=y
# CONFIG_NLS_ISO8859_14 is not set
CONFIG_NLS_ISO8859_15=y
CONFIG_NLS_KOI8_R=y
CONFIG_NLS_KOI8_U=y
CONFIG_NLS_MAC_ROMAN=y
CONFIG_NLS_MAC_CELTIC=y
CONFIG_NLS_MAC_CENTEURO=y
CONFIG_NLS_MAC_CROATIAN=y
CONFIG_NLS_MAC_CYRILLIC=y
CONFIG_NLS_MAC_GAELIC=y
# CONFIG_NLS_MAC_GREEK is not set
CONFIG_NLS_MAC_ICELAND=y
CONFIG_NLS_MAC_INUIT=y
CONFIG_NLS_MAC_ROMANIAN=y
CONFIG_NLS_MAC_TURKISH=y
CONFIG_NLS_UTF8=y
# CONFIG_DLM is not set

#
# Kernel hacking
#
CONFIG_TRACE_IRQFLAGS_SUPPORT=y

#
# printk and dmesg options
#
CONFIG_PRINTK_TIME=y
CONFIG_CONSOLE_LOGLEVEL_DEFAULT=7
CONFIG_MESSAGE_LOGLEVEL_DEFAULT=4
# CONFIG_BOOT_PRINTK_DELAY is not set
# CONFIG_DYNAMIC_DEBUG is not set

#
# Compile-time checks and compiler options
#
CONFIG_DEBUG_INFO=y
CONFIG_DEBUG_INFO_REDUCED=y
# CONFIG_DEBUG_INFO_SPLIT is not set
# CONFIG_DEBUG_INFO_DWARF4 is not set
# CONFIG_GDB_SCRIPTS is not set
CONFIG_ENABLE_WARN_DEPRECATED=y
# CONFIG_ENABLE_MUST_CHECK is not set
CONFIG_FRAME_WARN=8192
# CONFIG_STRIP_ASM_SYMS is not set
CONFIG_READABLE_ASM=y
CONFIG_UNUSED_SYMBOLS=y
# CONFIG_PAGE_OWNER is not set
CONFIG_DEBUG_FS=y
CONFIG_HEADERS_CHECK=y
# CONFIG_DEBUG_SECTION_MISMATCH is not set
# CONFIG_SECTION_MISMATCH_WARN_ONLY is not set
CONFIG_STACK_VALIDATION=y
CONFIG_DEBUG_FORCE_WEAK_PER_CPU=y
CONFIG_MAGIC_SYSRQ=y
CONFIG_MAGIC_SYSRQ_DEFAULT_ENABLE=0x1
CONFIG_MAGIC_SYSRQ_SERIAL=y
CONFIG_DEBUG_KERNEL=y

#
# Memory Debugging
#
CONFIG_PAGE_EXTENSION=y
CONFIG_DEBUG_PAGEALLOC=y
# CONFIG_DEBUG_PAGEALLOC_ENABLE_DEFAULT is not set
CONFIG_PAGE_POISONING=y
CONFIG_PAGE_POISONING_NO_SANITY=y
CONFIG_PAGE_POISONING_ZERO=y
# CONFIG_DEBUG_RODATA_TEST is not set
CONFIG_DEBUG_OBJECTS=y
# CONFIG_DEBUG_OBJECTS_SELFTEST is not set
CONFIG_DEBUG_OBJECTS_FREE=y
# CONFIG_DEBUG_OBJECTS_TIMERS is not set
CONFIG_DEBUG_OBJECTS_WORK=y
# CONFIG_DEBUG_OBJECTS_RCU_HEAD is not set
# CONFIG_DEBUG_OBJECTS_PERCPU_COUNTER is not set
CONFIG_DEBUG_OBJECTS_ENABLE_DEFAULT=1
# CONFIG_SLUB_DEBUG_ON is not set
CONFIG_SLUB_STATS=y
CONFIG_HAVE_DEBUG_KMEMLEAK=y
# CONFIG_DEBUG_KMEMLEAK is not set
# CONFIG_DEBUG_STACK_USAGE is not set
# CONFIG_DEBUG_VM is not set
CONFIG_ARCH_HAS_DEBUG_VIRTUAL=y
CONFIG_DEBUG_VIRTUAL=y
CONFIG_DEBUG_MEMORY_INIT=y
CONFIG_HAVE_DEBUG_STACKOVERFLOW=y
# CONFIG_DEBUG_STACKOVERFLOW is not set
CONFIG_HAVE_ARCH_KASAN=y
CONFIG_KASAN=y
CONFIG_KASAN_OUTLINE=y
# CONFIG_KASAN_INLINE is not set
CONFIG_ARCH_HAS_KCOV=y
# CONFIG_KCOV is not set
CONFIG_DEBUG_SHIRQ=y

#
# Debug Lockups and Hangs
#
CONFIG_LOCKUP_DETECTOR=y
CONFIG_SOFTLOCKUP_DETECTOR=y
CONFIG_HARDLOCKUP_DETECTOR_PERF=y
CONFIG_HARDLOCKUP_CHECK_TIMESTAMP=y
CONFIG_HARDLOCKUP_DETECTOR=y
CONFIG_BOOTPARAM_HARDLOCKUP_PANIC=y
CONFIG_BOOTPARAM_HARDLOCKUP_PANIC_VALUE=1
CONFIG_BOOTPARAM_SOFTLOCKUP_PANIC=y
CONFIG_BOOTPARAM_SOFTLOCKUP_PANIC_VALUE=1
CONFIG_DETECT_HUNG_TASK=y
CONFIG_DEFAULT_HUNG_TASK_TIMEOUT=120
CONFIG_BOOTPARAM_HUNG_TASK_PANIC=y
CONFIG_BOOTPARAM_HUNG_TASK_PANIC_VALUE=1
CONFIG_WQ_WATCHDOG=y
CONFIG_PANIC_ON_OOPS=y
CONFIG_PANIC_ON_OOPS_VALUE=1
CONFIG_PANIC_TIMEOUT=0
CONFIG_SCHED_DEBUG=y
CONFIG_SCHED_INFO=y
CONFIG_SCHEDSTATS=y
CONFIG_SCHED_STACK_END_CHECK=y
CONFIG_DEBUG_TIMEKEEPING=y

#
# Lock Debugging (spinlocks, mutexes, etc...)
#
# CONFIG_DEBUG_RT_MUTEXES is not set
CONFIG_DEBUG_SPINLOCK=y
# CONFIG_DEBUG_MUTEXES is not set
# CONFIG_DEBUG_WW_MUTEX_SLOWPATH is not set
# CONFIG_DEBUG_LOCK_ALLOC is not set
# CONFIG_PROVE_LOCKING is not set
# CONFIG_LOCK_STAT is not set
CONFIG_DEBUG_ATOMIC_SLEEP=y
# CONFIG_DEBUG_LOCKING_API_SELFTESTS is not set
CONFIG_LOCK_TORTURE_TEST=y
CONFIG_WW_MUTEX_SELFTEST=y
CONFIG_STACKTRACE=y
# CONFIG_WARN_ALL_UNSEEDED_RANDOM is not set
# CONFIG_DEBUG_KOBJECT is not set
CONFIG_DEBUG_BUGVERBOSE=y
# CONFIG_DEBUG_LIST is not set
CONFIG_DEBUG_PI_LIST=y
# CONFIG_DEBUG_SG is not set
CONFIG_DEBUG_NOTIFIERS=y
# CONFIG_DEBUG_CREDENTIALS is not set

#
# RCU Debugging
#
# CONFIG_PROVE_RCU is not set
CONFIG_TORTURE_TEST=y
CONFIG_RCU_PERF_TEST=y
CONFIG_RCU_TORTURE_TEST=y
# CONFIG_RCU_TRACE is not set
# CONFIG_RCU_EQS_DEBUG is not set
CONFIG_DEBUG_WQ_FORCE_RR_CPU=y
# CONFIG_DEBUG_BLOCK_EXT_DEVT is not set
# CONFIG_NOTIFIER_ERROR_INJECTION is not set
# CONFIG_FAULT_INJECTION is not set
CONFIG_LATENCYTOP=y
CONFIG_USER_STACKTRACE_SUPPORT=y
CONFIG_HAVE_FUNCTION_TRACER=y
CONFIG_HAVE_FUNCTION_GRAPH_TRACER=y
CONFIG_HAVE_DYNAMIC_FTRACE=y
CONFIG_HAVE_DYNAMIC_FTRACE_WITH_REGS=y
CONFIG_HAVE_FTRACE_MCOUNT_RECORD=y
CONFIG_HAVE_SYSCALL_TRACEPOINTS=y
CONFIG_HAVE_FENTRY=y
CONFIG_HAVE_C_RECORDMCOUNT=y
CONFIG_TRACING_SUPPORT=y
# CONFIG_FTRACE is not set
CONFIG_PROVIDE_OHCI1394_DMA_INIT=y
# CONFIG_DMA_API_DEBUG is not set

#
# Runtime Testing
#
# CONFIG_LKDTM is not set
# CONFIG_TEST_LIST_SORT is not set
# CONFIG_TEST_SORT is not set
# CONFIG_BACKTRACE_SELF_TEST is not set
# CONFIG_RBTREE_TEST is not set
# CONFIG_INTERVAL_TREE_TEST is not set
# CONFIG_ATOMIC64_SELFTEST is not set
# CONFIG_ASYNC_RAID6_TEST is not set
# CONFIG_TEST_HEXDUMP is not set
# CONFIG_TEST_STRING_HELPERS is not set
# CONFIG_TEST_KSTRTOX is not set
# CONFIG_TEST_PRINTF is not set
# CONFIG_TEST_BITMAP is not set
# CONFIG_TEST_UUID is not set
# CONFIG_TEST_RHASHTABLE is not set
# CONFIG_TEST_HASH is not set
# CONFIG_TEST_FIRMWARE is not set
# CONFIG_TEST_SYSCTL is not set
# CONFIG_TEST_UDELAY is not set
# CONFIG_TEST_DEBUG_VIRTUAL is not set
# CONFIG_MEMTEST is not set
# CONFIG_BUG_ON_DATA_CORRUPTION is not set
# CONFIG_SAMPLES is not set
CONFIG_HAVE_ARCH_KGDB=y
# CONFIG_KGDB is not set
CONFIG_ARCH_HAS_UBSAN_SANITIZE_ALL=y
# CONFIG_ARCH_WANTS_UBSAN_NO_NULL is not set
CONFIG_UBSAN=y
# CONFIG_UBSAN_SANITIZE_ALL is not set
# CONFIG_UBSAN_ALIGNMENT is not set
CONFIG_UBSAN_NULL=y
CONFIG_ARCH_HAS_DEVMEM_IS_ALLOWED=y
# CONFIG_STRICT_DEVMEM is not set
CONFIG_X86_VERBOSE_BOOTUP=y
CONFIG_EARLY_PRINTK=y
# CONFIG_EARLY_PRINTK_DBGP is not set
# CONFIG_EARLY_PRINTK_USB_XDBC is not set
CONFIG_X86_PTDUMP_CORE=y
CONFIG_X86_PTDUMP=y
CONFIG_DEBUG_WX=y
CONFIG_DOUBLEFAULT=y
# CONFIG_DEBUG_TLBFLUSH is not set
CONFIG_IOMMU_DEBUG=y
# CONFIG_IOMMU_STRESS is not set
CONFIG_HAVE_MMIOTRACE_SUPPORT=y
CONFIG_IO_DELAY_TYPE_0X80=0
CONFIG_IO_DELAY_TYPE_0XED=1
CONFIG_IO_DELAY_TYPE_UDELAY=2
CONFIG_IO_DELAY_TYPE_NONE=3
# CONFIG_IO_DELAY_0X80 is not set
CONFIG_IO_DELAY_0XED=y
# CONFIG_IO_DELAY_UDELAY is not set
# CONFIG_IO_DELAY_NONE is not set
CONFIG_DEFAULT_IO_DELAY_TYPE=1
# CONFIG_DEBUG_BOOT_PARAMS is not set
# CONFIG_CPA_DEBUG is not set
# CONFIG_OPTIMIZE_INLINING is not set
# CONFIG_DEBUG_ENTRY is not set
CONFIG_DEBUG_NMI_SELFTEST=y
CONFIG_X86_DEBUG_FPU=y
# CONFIG_PUNIT_ATOM_DEBUG is not set
CONFIG_UNWINDER_ORC=y
# CONFIG_UNWINDER_FRAME_POINTER is not set

#
# Security options
#
CONFIG_KEYS=y
CONFIG_PERSISTENT_KEYRINGS=y
# CONFIG_BIG_KEYS is not set
CONFIG_ENCRYPTED_KEYS=y
# CONFIG_KEY_DH_OPERATIONS is not set
# CONFIG_SECURITY_DMESG_RESTRICT is not set
CONFIG_SECURITY=y
# CONFIG_SECURITY_WRITABLE_HOOKS is not set
# CONFIG_SECURITYFS is not set
CONFIG_SECURITY_NETWORK=y
# CONFIG_SECURITY_NETWORK_XFRM is not set
# CONFIG_SECURITY_PATH is not set
CONFIG_HAVE_HARDENED_USERCOPY_ALLOCATOR=y
# CONFIG_HARDENED_USERCOPY is not set
# CONFIG_FORTIFY_SOURCE is not set
# CONFIG_STATIC_USERMODEHELPER is not set
# CONFIG_SECURITY_SMACK is not set
# CONFIG_SECURITY_TOMOYO is not set
# CONFIG_SECURITY_APPARMOR is not set
CONFIG_SECURITY_LOADPIN=y
# CONFIG_SECURITY_LOADPIN_ENABLED is not set
CONFIG_SECURITY_YAMA=y
CONFIG_INTEGRITY=y
CONFIG_INTEGRITY_SIGNATURE=y
# CONFIG_INTEGRITY_ASYMMETRIC_KEYS is not set
# CONFIG_IMA is not set
# CONFIG_EVM is not set
CONFIG_DEFAULT_SECURITY_DAC=y
CONFIG_DEFAULT_SECURITY=""
CONFIG_XOR_BLOCKS=y
CONFIG_ASYNC_CORE=y
CONFIG_ASYNC_MEMCPY=y
CONFIG_ASYNC_XOR=y
CONFIG_ASYNC_PQ=y
CONFIG_ASYNC_RAID6_RECOV=y
CONFIG_CRYPTO=y

#
# Crypto core or helper
#
CONFIG_CRYPTO_ALGAPI=y
CONFIG_CRYPTO_ALGAPI2=y
CONFIG_CRYPTO_AEAD=y
CONFIG_CRYPTO_AEAD2=y
CONFIG_CRYPTO_BLKCIPHER=y
CONFIG_CRYPTO_BLKCIPHER2=y
CONFIG_CRYPTO_HASH=y
CONFIG_CRYPTO_HASH2=y
CONFIG_CRYPTO_RNG=y
CONFIG_CRYPTO_RNG2=y
CONFIG_CRYPTO_RNG_DEFAULT=y
CONFIG_CRYPTO_AKCIPHER2=y
CONFIG_CRYPTO_AKCIPHER=y
CONFIG_CRYPTO_KPP2=y
CONFIG_CRYPTO_KPP=y
CONFIG_CRYPTO_ACOMP2=y
CONFIG_CRYPTO_RSA=y
CONFIG_CRYPTO_DH=y
# CONFIG_CRYPTO_ECDH is not set
CONFIG_CRYPTO_MANAGER=y
CONFIG_CRYPTO_MANAGER2=y
# CONFIG_CRYPTO_USER is not set
CONFIG_CRYPTO_MANAGER_DISABLE_TESTS=y
CONFIG_CRYPTO_GF128MUL=y
CONFIG_CRYPTO_NULL=y
CONFIG_CRYPTO_NULL2=y
CONFIG_CRYPTO_WORKQUEUE=y
CONFIG_CRYPTO_CRYPTD=y
# CONFIG_CRYPTO_MCRYPTD is not set
# CONFIG_CRYPTO_AUTHENC is not set
CONFIG_CRYPTO_ABLK_HELPER=y
CONFIG_CRYPTO_GLUE_HELPER_X86=y

#
# Authenticated Encryption with Associated Data
#
CONFIG_CRYPTO_CCM=y
CONFIG_CRYPTO_GCM=y
# CONFIG_CRYPTO_CHACHA20POLY1305 is not set
CONFIG_CRYPTO_SEQIV=y
CONFIG_CRYPTO_ECHAINIV=y

#
# Block modes
#
CONFIG_CRYPTO_CBC=y
CONFIG_CRYPTO_CTR=y
CONFIG_CRYPTO_CTS=y
CONFIG_CRYPTO_ECB=y
CONFIG_CRYPTO_LRW=y
# CONFIG_CRYPTO_PCBC is not set
CONFIG_CRYPTO_XTS=y
CONFIG_CRYPTO_KEYWRAP=y

#
# Hash modes
#
CONFIG_CRYPTO_CMAC=y
CONFIG_CRYPTO_HMAC=y
CONFIG_CRYPTO_XCBC=y
CONFIG_CRYPTO_VMAC=y

#
# Digest
#
CONFIG_CRYPTO_CRC32C=y
CONFIG_CRYPTO_CRC32C_INTEL=y
CONFIG_CRYPTO_CRC32=y
CONFIG_CRYPTO_CRC32_PCLMUL=y
CONFIG_CRYPTO_CRCT10DIF=y
# CONFIG_CRYPTO_CRCT10DIF_PCLMUL is not set
CONFIG_CRYPTO_GHASH=y
CONFIG_CRYPTO_POLY1305=y
CONFIG_CRYPTO_POLY1305_X86_64=y
CONFIG_CRYPTO_MD4=y
CONFIG_CRYPTO_MD5=y
CONFIG_CRYPTO_MICHAEL_MIC=y
# CONFIG_CRYPTO_RMD128 is not set
# CONFIG_CRYPTO_RMD160 is not set
CONFIG_CRYPTO_RMD256=y
CONFIG_CRYPTO_RMD320=y
CONFIG_CRYPTO_SHA1=y
# CONFIG_CRYPTO_SHA1_SSSE3 is not set
CONFIG_CRYPTO_SHA256_SSSE3=y
CONFIG_CRYPTO_SHA512_SSSE3=y
# CONFIG_CRYPTO_SHA1_MB is not set
# CONFIG_CRYPTO_SHA256_MB is not set
# CONFIG_CRYPTO_SHA512_MB is not set
CONFIG_CRYPTO_SHA256=y
CONFIG_CRYPTO_SHA512=y
CONFIG_CRYPTO_SHA3=y
# CONFIG_CRYPTO_SM3 is not set
CONFIG_CRYPTO_TGR192=y
CONFIG_CRYPTO_WP512=y
# CONFIG_CRYPTO_GHASH_CLMUL_NI_INTEL is not set

#
# Ciphers
#
CONFIG_CRYPTO_AES=y
CONFIG_CRYPTO_AES_TI=y
CONFIG_CRYPTO_AES_X86_64=y
# CONFIG_CRYPTO_AES_NI_INTEL is not set
CONFIG_CRYPTO_ANUBIS=y
CONFIG_CRYPTO_ARC4=y
CONFIG_CRYPTO_BLOWFISH=y
CONFIG_CRYPTO_BLOWFISH_COMMON=y
CONFIG_CRYPTO_BLOWFISH_X86_64=y
CONFIG_CRYPTO_CAMELLIA=y
CONFIG_CRYPTO_CAMELLIA_X86_64=y
CONFIG_CRYPTO_CAMELLIA_AESNI_AVX_X86_64=y
# CONFIG_CRYPTO_CAMELLIA_AESNI_AVX2_X86_64 is not set
CONFIG_CRYPTO_CAST_COMMON=y
CONFIG_CRYPTO_CAST5=y
CONFIG_CRYPTO_CAST5_AVX_X86_64=y
CONFIG_CRYPTO_CAST6=y
# CONFIG_CRYPTO_CAST6_AVX_X86_64 is not set
CONFIG_CRYPTO_DES=y
CONFIG_CRYPTO_DES3_EDE_X86_64=y
# CONFIG_CRYPTO_FCRYPT is not set
CONFIG_CRYPTO_KHAZAD=y
CONFIG_CRYPTO_SALSA20=y
# CONFIG_CRYPTO_SALSA20_X86_64 is not set
CONFIG_CRYPTO_CHACHA20=y
CONFIG_CRYPTO_CHACHA20_X86_64=y
# CONFIG_CRYPTO_SEED is not set
CONFIG_CRYPTO_SERPENT=y
# CONFIG_CRYPTO_SERPENT_SSE2_X86_64 is not set
CONFIG_CRYPTO_SERPENT_AVX_X86_64=y
# CONFIG_CRYPTO_SERPENT_AVX2_X86_64 is not set
CONFIG_CRYPTO_TEA=y
# CONFIG_CRYPTO_TWOFISH is not set
CONFIG_CRYPTO_TWOFISH_COMMON=y
CONFIG_CRYPTO_TWOFISH_X86_64=y
CONFIG_CRYPTO_TWOFISH_X86_64_3WAY=y
CONFIG_CRYPTO_TWOFISH_AVX_X86_64=y

#
# Compression
#
CONFIG_CRYPTO_DEFLATE=y
CONFIG_CRYPTO_LZO=y
CONFIG_CRYPTO_842=y
CONFIG_CRYPTO_LZ4=y
CONFIG_CRYPTO_LZ4HC=y

#
# Random Number Generation
#
CONFIG_CRYPTO_ANSI_CPRNG=y
CONFIG_CRYPTO_DRBG_MENU=y
CONFIG_CRYPTO_DRBG_HMAC=y
# CONFIG_CRYPTO_DRBG_HASH is not set
# CONFIG_CRYPTO_DRBG_CTR is not set
CONFIG_CRYPTO_DRBG=y
CONFIG_CRYPTO_JITTERENTROPY=y
# CONFIG_CRYPTO_USER_API_HASH is not set
# CONFIG_CRYPTO_USER_API_SKCIPHER is not set
# CONFIG_CRYPTO_USER_API_RNG is not set
# CONFIG_CRYPTO_USER_API_AEAD is not set
# CONFIG_CRYPTO_HW is not set
# CONFIG_ASYMMETRIC_KEY_TYPE is not set

#
# Certificates for signature checking
#
# CONFIG_SYSTEM_BLACKLIST_KEYRING is not set
CONFIG_HAVE_KVM=y
# CONFIG_VIRTUALIZATION is not set
# CONFIG_BINARY_PRINTF is not set

#
# Library routines
#
CONFIG_RAID6_PQ=y
CONFIG_BITREVERSE=y
# CONFIG_HAVE_ARCH_BITREVERSE is not set
CONFIG_RATIONAL=y
CONFIG_GENERIC_STRNCPY_FROM_USER=y
CONFIG_GENERIC_STRNLEN_USER=y
CONFIG_GENERIC_NET_UTILS=y
CONFIG_GENERIC_FIND_FIRST_BIT=y
CONFIG_GENERIC_PCI_IOMAP=y
CONFIG_GENERIC_IOMAP=y
CONFIG_GENERIC_IO=y
CONFIG_ARCH_USE_CMPXCHG_LOCKREF=y
CONFIG_ARCH_HAS_FAST_MULTIPLIER=y
CONFIG_CRC_CCITT=y
CONFIG_CRC16=y
CONFIG_CRC_T10DIF=y
CONFIG_CRC_ITU_T=y
CONFIG_CRC32=y
CONFIG_CRC32_SELFTEST=y
# CONFIG_CRC32_SLICEBY8 is not set
# CONFIG_CRC32_SLICEBY4 is not set
# CONFIG_CRC32_SARWATE is not set
CONFIG_CRC32_BIT=y
CONFIG_CRC4=y
CONFIG_CRC7=y
CONFIG_LIBCRC32C=y
CONFIG_CRC8=y
CONFIG_XXHASH=y
# CONFIG_AUDIT_ARCH_COMPAT_GENERIC is not set
CONFIG_RANDOM32_SELFTEST=y
CONFIG_842_COMPRESS=y
CONFIG_842_DECOMPRESS=y
CONFIG_ZLIB_INFLATE=y
CONFIG_ZLIB_DEFLATE=y
CONFIG_LZO_COMPRESS=y
CONFIG_LZO_DECOMPRESS=y
CONFIG_LZ4_COMPRESS=y
CONFIG_LZ4HC_COMPRESS=y
CONFIG_LZ4_DECOMPRESS=y
CONFIG_ZSTD_COMPRESS=y
CONFIG_ZSTD_DECOMPRESS=y
CONFIG_XZ_DEC=y
CONFIG_XZ_DEC_X86=y
CONFIG_XZ_DEC_POWERPC=y
CONFIG_XZ_DEC_IA64=y
CONFIG_XZ_DEC_ARM=y
CONFIG_XZ_DEC_ARMTHUMB=y
CONFIG_XZ_DEC_SPARC=y
CONFIG_XZ_DEC_BCJ=y
CONFIG_XZ_DEC_TEST=y
CONFIG_DECOMPRESS_GZIP=y
CONFIG_DECOMPRESS_BZIP2=y
CONFIG_DECOMPRESS_LZMA=y
CONFIG_DECOMPRESS_XZ=y
CONFIG_DECOMPRESS_LZO=y
CONFIG_DECOMPRESS_LZ4=y
CONFIG_GENERIC_ALLOCATOR=y
CONFIG_REED_SOLOMON=y
CONFIG_REED_SOLOMON_DEC8=y
CONFIG_INTERVAL_TREE=y
CONFIG_ASSOCIATIVE_ARRAY=y
CONFIG_HAS_IOMEM=y
CONFIG_HAS_IOPORT_MAP=y
CONFIG_HAS_DMA=y
# CONFIG_DMA_NOOP_OPS is not set
# CONFIG_DMA_VIRT_OPS is not set
CONFIG_CHECK_SIGNATURE=y
CONFIG_DQL=y
CONFIG_NLATTR=y
CONFIG_CLZ_TAB=y
CONFIG_CORDIC=y
# CONFIG_DDR is not set
# CONFIG_IRQ_POLL is not set
CONFIG_MPILIB=y
CONFIG_SIGNATURE=y
CONFIG_OID_REGISTRY=y
CONFIG_FONT_SUPPORT=y
CONFIG_FONTS=y
# CONFIG_FONT_8x8 is not set
CONFIG_FONT_8x16=y
# CONFIG_FONT_6x11 is not set
CONFIG_FONT_7x14=y
# CONFIG_FONT_PEARL_8x8 is not set
# CONFIG_FONT_ACORN_8x8 is not set
CONFIG_FONT_MINI_4x6=y
CONFIG_FONT_6x10=y
CONFIG_FONT_10x18=y
CONFIG_FONT_SUN8x16=y
CONFIG_FONT_SUN12x22=y
# CONFIG_SG_SPLIT is not set
CONFIG_SG_POOL=y
CONFIG_ARCH_HAS_SG_CHAIN=y
CONFIG_ARCH_HAS_PMEM_API=y
CONFIG_ARCH_HAS_UACCESS_FLUSHCACHE=y
CONFIG_STACKDEPOT=y
CONFIG_SBITMAP=y
CONFIG_STRING_SELFTEST=y

--yywL3DpgDyP4yZ2G--
