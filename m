Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9F07D28025D
	for <linux-mm@kvack.org>; Fri,  5 Jan 2018 09:45:52 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id q6so2899883pff.16
        for <linux-mm@kvack.org>; Fri, 05 Jan 2018 06:45:52 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id t4si4027079plo.697.2018.01.05.06.45.46
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 05 Jan 2018 06:45:46 -0800 (PST)
Subject: [x86? mm? fs? 4.15-rc6] Random oopses by simple write under memory pressure.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-Id: <201801052345.JBJ82317.tJVHFFOMOLFOQS@I-love.SAKURA.ne.jp>
Date: Fri, 5 Jan 2018 23:45:41 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org, linux-mm@kvack.org

Using current linux.git (e1915c8195b38393), I get various oopses shown below.
Note that I'm testing x86_32 kernel using x86_64 CPUs. Note that *pde = 00000000 in most cases.

----------------------------------------
localhost login: [   64.800994] BUG: unable to handle kernel paging request at 1b4150b6
[   64.803072] IP: lock_page_memcg+0x3c/0x80
[   64.804408] *pde = 00000000 
[   64.805352] Oops: 0000 [#1] SMP
[   64.806418] Modules linked in: ip6t_rpfilter ipt_REJECT nf_reject_ipv4 ip6t_REJECT nf_reject_ipv6 xt_conntrack ip_set nfnetlink ebtable_nat ebtable_broute bridge stp llc ip6table_nat nf_conntrack_ipv6 nf_defrag_ipv6 nf_nat_ipv6 ip6table_mangle ip6table_raw iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack iptable_mangle iptable_raw ebtable_filter ebtables ip6table_filter ip6_tables iptable_filter coretemp vmw_balloon vmw_vmci pcspkr sg i2c_piix4 shpchp ip_tables xfs libcrc32c sr_mod cdrom sd_mod ata_generic pata_acpi serio_raw mptspi scsi_transport_spi mptscsih e1000 mptbase ata_piix libata
[   64.823138] CPU: 4 PID: 3928 Comm: a.out Not tainted 4.15.0-rc6+ #258
[   64.824992] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
[   64.828027] EIP: lock_page_memcg+0x3c/0x80
[   64.829193] EFLAGS: 00010202 CPU: 4
[   64.830193] EAX: f33fa6e0 EBX: 1b414f46 ECX: 00000011 EDX: 00000000
[   64.831968] ESI: 00000010 EDI: f33fa6e0 EBP: ec3e3a84 ESP: ec3e3a78
[   64.833733]  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
[   64.835533] CR0: 80050033 CR2: 1b4150b6 CR3: 2ba99000 CR4: 000406d0
[   64.837416] Call Trace:
[   64.838140]  page_remove_rmap+0x92/0x280
[   64.839276]  try_to_unmap_one+0x202/0x530
[   64.840423]  rmap_walk_file+0xf0/0x1e0
[   64.841497]  rmap_walk+0x32/0x60
[   64.842448]  try_to_unmap+0x4d/0xd0
[   64.843463]  ? page_remove_rmap+0x280/0x280
[   64.844654]  ? page_not_mapped+0x10/0x10
[   64.845781]  ? page_get_anon_vma+0x80/0x80
[   64.847085]  shrink_page_list+0x3e2/0xe40
[   64.848235]  shrink_inactive_list+0x1b2/0x440
[   64.849476]  shrink_node_memcg+0x34a/0x770
[   64.850684]  shrink_node+0xbb/0x2e0
[   64.852554]  do_try_to_free_pages+0xb2/0x300
[   64.854599]  try_to_free_pages+0x20b/0x330
----------------------------------------

----------------------------------------
localhost login: [  205.084518] BUG: unable to handle kernel NULL pointer dereference at 00000104
[  205.087492] IP: free_pcppages_bulk+0x8e/0x300
[  205.088554] WARNING: CPU: 5 PID: 1817 at fs/xfs/xfs_aops.c:1468 xfs_vm_set_page_dirty+0x125/0x210 [xfs]
[  205.088555] Modules linked in: ip6t_rpfilter ipt_REJECT nf_reject_ipv4 ip6t_REJECT nf_reject_ipv6 xt_conntrack ip_set nfnetlink ebtable_nat ebtable_broute bridge stp llc ip6table_nat nf_conntrack_ipv6 nf_defrag_ipv6 nf_nat_ipv6 ip6table_mangle ip6table_raw iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack iptable_mangle iptable_raw ebtable_filter ebtables ip6table_filter ip6_tables iptable_filter coretemp sg vmw_balloon pcspkr i2c_piix4 vmw_vmci shpchp ip_tables xfs libcrc32c sr_mod cdrom sd_mod ata_generic pata_acpi serio_raw e1000 mptspi scsi_transport_spi ata_piix mptscsih libata mptbase
[  205.088582] CPU: 5 PID: 1817 Comm: a.out Not tainted 4.15.0-rc6+ #258
[  205.088583] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
[  205.088604] EIP: xfs_vm_set_page_dirty+0x125/0x210 [xfs]
[  205.088605] EFLAGS: 00010046 CPU: 5
[  205.088606] EAX: b6000011 EBX: f247dd58 ECX: f247dd58 EDX: f247dd4c
[  205.088607] ESI: 00000246 EDI: f4b7b8c8 EBP: f36b9a8c ESP: f36b9a68
[  205.088609]  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
[  205.088610] CR0: 80050033 CR2: 38e5e008 CR3: 32881000 CR4: 000406d0
[  205.088689] Call Trace:
[  205.088696]  set_page_dirty+0x3d/0x90
[  205.088699]  try_to_unmap_one+0x36b/0x530
[  205.088702]  rmap_walk_file+0xf0/0x1e0
[  205.088704]  rmap_walk+0x32/0x60
[  205.088706]  try_to_unmap+0x4d/0xd0
[  205.088708]  ? page_remove_rmap+0x280/0x280
[  205.088709]  ? page_not_mapped+0x10/0x10
[  205.088711]  ? page_get_anon_vma+0x80/0x80
[  205.088714]  shrink_page_list+0x3e2/0xe40
[  205.088717]  ? clockevents_program_event+0xa5/0x160
[  205.088721]  shrink_inactive_list+0x1b2/0x440
[  205.088723]  shrink_node_memcg+0x34a/0x770
[  205.088726]  shrink_node+0xbb/0x2e0
[  205.088728]  do_try_to_free_pages+0xb2/0x300
[  205.088730]  try_to_free_pages+0x20b/0x330
[  205.088733]  __alloc_pages_slowpath+0x2fb/0x6d9
[  205.088736]  ? __pagevec_lru_add_fn+0xdb/0x190
[  205.088738]  __alloc_pages_nodemask+0x17a/0x190
[  205.088742]  do_anonymous_page+0xab/0x490
[  205.088744]  handle_mm_fault+0x531/0x8b0
[  205.088746]  ? pick_next_task_fair+0xe1/0x490
[  205.088749]  ? sched_clock_cpu+0x13/0x120
[  205.088752]  ? __do_page_fault+0x4e0/0x4e0
[  205.088754]  __do_page_fault+0x1ef/0x4e0
[  205.088756]  ? __do_page_fault+0x4e0/0x4e0
[  205.088758]  do_page_fault+0x1a/0x20
[  205.088762]  common_exception+0x6f/0x76
[  205.088763] EIP: 0x80484be
[  205.088764] EFLAGS: 00010202 CPU: 5
[  205.088765] EAX: 026a6000 EBX: 80000000 ECX: 3a597008 EDX: 00000000
[  205.088766] ESI: 7ff00000 EDI: 00000000 EBP: bf89aa48 ESP: bf89aa20
[  205.088767]  DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 007b
[  205.088768] Code: e4 8d 58 0c 89 d8 e8 5b b1 c2 c8 89 c6 8b 45 e8 8b 50 04 85 d2 74 5b 8b 40 14 a8 01 0f 85 ce 00 00 00 8b 45 e8 8b 00 a8 08 75 7b <0f> ff 8b 7d e8 8b 55 e4 89 f8 e8 8c 71 6f c8 8b 47 14 a8 01 0f
[  205.088792] ---[ end trace ffb022c0c4b1f1da ]---
[  205.245444] *pde = 00000000 
[  205.247303] Oops: 0002 [#1] SMP
[  205.249245] Modules linked in: ip6t_rpfilter ipt_REJECT nf_reject_ipv4 ip6t_REJECT nf_reject_ipv6 xt_conntrack ip_set nfnetlink ebtable_nat ebtable_broute bridge stp llc ip6table_nat nf_conntrack_ipv6 nf_defrag_ipv6 nf_nat_ipv6 ip6table_mangle ip6table_raw iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack iptable_mangle iptable_raw ebtable_filter ebtables ip6table_filter ip6_tables iptable_filter coretemp sg vmw_balloon pcspkr i2c_piix4 vmw_vmci shpchp ip_tables xfs libcrc32c sr_mod cdrom sd_mod ata_generic pata_acpi serio_raw e1000 mptspi scsi_transport_spi ata_piix mptscsih libata mptbase
[  205.278257] CPU: 3 PID: 363 Comm: kworker/3:2 Tainted: G        W        4.15.0-rc6+ #258
[  205.282307] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
[  205.288393] Workqueue: mm_percpu_wq drain_local_pages_wq
[  205.291486] EIP: free_pcppages_bulk+0x8e/0x300
[  205.294272] EFLAGS: 00010093 CPU: 3
[  205.296725] EAX: 00000200 EBX: f4b7b8dc ECX: c18dbc80 EDX: 00000100
[  205.300201] ESI: f4b7b8c8 EDI: c18db9e0 EBP: f6429ef4 ESP: f6429ebc
[  205.303655]  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
[  205.306816] CR0: 80050033 CR2: 00000104 CR3: 2876b000 CR4: 000406d0
[  205.310373] Call Trace:
[  205.312512]  drain_pages_zone+0x31/0x50
[  205.315176]  drain_pages+0x35/0x50
[  205.317650]  drain_local_pages+0x25/0x30
[  205.320316]  drain_local_pages_wq+0xa/0x10
[  205.323025]  process_one_work+0xe7/0x240
[  205.325684]  worker_thread+0x182/0x360
[  205.328275]  ? __wake_up_locked+0x22/0x30
[  205.330995]  kthread+0xd1/0x100
[  205.333395]  ? rescuer_thread+0x2d0/0x2d0
[  205.336087]  ? kthread_associate_blkcg+0x80/0x80
[  205.338997]  ret_from_fork+0x19/0x24
[  205.341530] Code: 40 0c 89 75 e0 39 c6 74 d4 8b 45 dc 83 f8 03 0f 44 45 d4 89 45 dc 8d b4 26 00 00 00 00 8b 45 e0 8b 58 04 8b 43 04 8d 73 ec 8b 13 <89> 42 04 89 10 8b 43 f4 c7 03 00 01 00 00 c7 43 04 00 02 00 00
[  205.352013] EIP: free_pcppages_bulk+0x8e/0x300 SS:ESP: 0068:f6429ebc
[  205.355540] CR2: 0000000000000104
[  205.358007] ---[ end trace ffb022c0c4b1f1db ]---
[  205.358008] BUG: unable to handle kernel paging request at c10746c4
[  205.358015] IP: _raw_spin_lock_irqsave+0x1c/0x40
[  205.358015] *pde = 010001e1 
[  205.358018] Oops: 0003 [#2] SMP
[  205.358018] Modules linked in: ip6t_rpfilter ipt_REJECT nf_reject_ipv4 ip6t_REJECT nf_reject_ipv6 xt_conntrack ip_set nfnetlink ebtable_nat ebtable_broute bridge stp llc ip6table_nat nf_conntrack_ipv6 nf_defrag_ipv6 nf_nat_ipv6 ip6table_mangle ip6table_raw iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack iptable_mangle iptable_raw ebtable_filter ebtables ip6table_filter ip6_tables iptable_filter coretemp sg vmw_balloon pcspkr i2c_piix4 vmw_vmci shpchp ip_tables xfs libcrc32c sr_mod cdrom sd_mod ata_generic pata_acpi serio_raw e1000 mptspi scsi_transport_spi ata_piix mptscsih libata mptbase
[  205.358051] CPU: 5 PID: 1817 Comm: a.out Tainted: G      D W        4.15.0-rc6+ #258
[  205.358051] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
[  205.358054] EIP: _raw_spin_lock_irqsave+0x1c/0x40
[  205.358054] EFLAGS: 00010046 CPU: 5
[  205.358055] EAX: 00000000 EBX: 00000001 ECX: c10746c4 EDX: 00000000
[  205.358057] ESI: 00000206 EDI: f31afe80 EBP: f36b9a70 ESP: f36b9a68
[  205.358058]  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
[  205.358059] CR0: 80050033 CR2: c10746c4 CR3: 32881000 CR4: 000406d0
[  205.358165] Call Trace:
[  205.358169]  ? dequeue_entity+0xd0/0x290
[  205.358171]  ? dequeue_entity+0x244/0x290
[  205.358175]  lock_page_memcg+0x25/0x80
[  205.358178]  page_remove_rmap+0x92/0x280
[  205.358180]  try_to_unmap_one+0x202/0x530
[  205.358182]  rmap_walk_file+0xf0/0x1e0
[  205.358184]  rmap_walk+0x32/0x60
[  205.358186]  try_to_unmap+0x4d/0xd0
[  205.358188]  ? page_remove_rmap+0x280/0x280
[  205.358189]  ? page_not_mapped+0x10/0x10
[  205.358191]  ? page_get_anon_vma+0x80/0x80
[  205.358195]  shrink_page_list+0x3e2/0xe40
[  205.358198]  ? clockevents_program_event+0xa5/0x160
[  205.358201]  shrink_inactive_list+0x1b2/0x440
[  205.358204]  shrink_node_memcg+0x34a/0x770
[  205.358206]  shrink_node+0xbb/0x2e0
[  205.358208]  do_try_to_free_pages+0xb2/0x300
[  205.358210]  try_to_free_pages+0x20b/0x330
[  205.358213]  __alloc_pages_slowpath+0x2fb/0x6d9
[  205.358215]  ? __pagevec_lru_add_fn+0xdb/0x190
[  205.358218]  __alloc_pages_nodemask+0x17a/0x190
[  205.358221]  do_anonymous_page+0xab/0x490
[  205.358223]  handle_mm_fault+0x531/0x8b0
[  205.358224]  ? pick_next_task_fair+0xe1/0x490
[  205.358226]  ? sched_clock_cpu+0x13/0x120
[  205.358229]  ? __do_page_fault+0x4e0/0x4e0
[  205.358231]  __do_page_fault+0x1ef/0x4e0
[  205.358233]  ? __do_page_fault+0x4e0/0x4e0
[  205.358234]  do_page_fault+0x1a/0x20
[  205.358237]  common_exception+0x6f/0x76
[  205.358238] EIP: 0x80484be
[  205.358239] EFLAGS: 00010202 CPU: 5
[  205.358240] EAX: 026a6000 EBX: 80000000 ECX: 3a597008 EDX: 00000000
[  205.358241] ESI: 7ff00000 EDI: 00000000 EBP: bf89aa48 ESP: bf89aa20
[  205.358242]  DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 007b
[  205.358243] Code: eb f2 8d b6 00 00 00 00 8d bc 27 00 00 00 00 55 89 c1 89 e5 56 53 9c 58 66 66 66 90 89 c6 fa 66 66 90 66 90 31 c0 bb 01 00 00 00 <f0> 0f b1 19 85 c0 75 06 89 f0 5b 5e 5d c3 89 c2 89 c8 e8 5d 1b
[  205.358268] EIP: _raw_spin_lock_irqsave+0x1c/0x40 SS:ESP: 0068:f36b9a68
[  205.358269] CR2: 00000000c10746c4
[  205.358271] ---[ end trace ffb022c0c4b1f1dc ]---
----------------------------------------

----------------------------------------
localhost login: [   67.347704] BUG: unable to handle kernel NULL pointer dereference at 00000180
[   67.350154] IP: lock_page_memcg+0x3c/0x80
[   67.351621] *pde = 00000000 
[   67.352731] Oops: 0000 [#1] SMP
[   67.353916] Modules linked in: ip6t_rpfilter ipt_REJECT nf_reject_ipv4 ip6t_REJECT nf_reject_ipv6 xt_conntrack ip_set nfnetlink ebtable_nat ebtable_broute bridge stp llc ip6table_nat nf_conntrack_ipv6 nf_defrag_ipv6 nf_nat_ipv6 ip6table_mangle ip6table_raw iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack iptable_mangle iptable_raw ebtable_filter ebtables ip6table_filter ip6_tables iptable_filter i2c_piix4 coretemp vmw_balloon pcspkr shpchp sg vmw_vmci ip_tables xfs libcrc32c sd_mod sr_mod cdrom ata_generic pata_acpi serio_raw mptspi e1000 scsi_transport_spi ata_piix mptscsih libata mptbase
[   67.373491] CPU: 2 PID: 1052 Comm: a.out Not tainted 4.15.0-rc6+ #258
[   67.376019] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
[   67.380424] EIP: lock_page_memcg+0x3c/0x80
[   67.382368] EFLAGS: 00010202 CPU: 2
[   67.384037] EAX: f3537288 EBX: 00000010 ECX: 00000222 EDX: 00000000
[   67.386589] ESI: 0000021e EDI: f3537288 EBP: f29438e4 ESP: f29438d8
[   67.389089]  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
[   67.391425] CR0: 80050033 CR2: 00000180 CR3: 32fcd000 CR4: 000406d0
[   67.394103] Call Trace:
[   67.395533]  page_remove_rmap+0x92/0x280
[   67.397470]  try_to_unmap_one+0x202/0x530
[   67.399499]  rmap_walk_file+0xf0/0x1e0
[   67.401413]  rmap_walk+0x32/0x60
[   67.403160]  try_to_unmap+0x4d/0xd0
[   67.404984]  ? page_remove_rmap+0x280/0x280
[   67.407122]  ? page_not_mapped+0x10/0x10
[   67.409115]  ? page_get_anon_vma+0x80/0x80
[   67.411170]  shrink_page_list+0x3e2/0xe40
[   67.413214]  shrink_inactive_list+0x1b2/0x440
[   67.415471]  shrink_node_memcg+0x34a/0x770
[   67.417562]  shrink_node+0xbb/0x2e0
[   67.419462]  do_try_to_free_pages+0xb2/0x300
[   67.421628]  try_to_free_pages+0x20b/0x330
[   67.423783]  ? __queue_work+0xe6/0x270
[   67.425803]  __alloc_pages_slowpath+0x2fb/0x6d9
[   67.428044]  __alloc_pages_nodemask+0x17a/0x190
[   67.430293]  pagecache_get_page+0x53/0x200
[   67.432417]  ? common_exception+0x6f/0x76
[   67.434476]  grab_cache_page_write_begin+0x20/0x40
[   67.436758]  iomap_write_begin.constprop.17+0x6d/0xf0
[   67.439118]  ? iov_iter_fault_in_readable+0x7b/0xd0
[   67.441397]  iomap_write_actor+0xb4/0x1a0
[   67.443392]  ? iomap_write_begin.constprop.17+0xf0/0xf0
[   67.445735]  iomap_apply+0xd8/0x1b0
[   67.447574]  ? iomap_write_begin.constprop.17+0xf0/0xf0
[   67.449710]  iomap_file_buffered_write+0x83/0xc0
[   67.451670]  ? iomap_write_begin.constprop.17+0xf0/0xf0
[   67.453780]  xfs_file_buffered_aio_write+0xa3/0x200 [xfs]
[   67.455983]  xfs_file_write_iter+0x77/0x150 [xfs]
[   67.457919]  __vfs_write+0xef/0x150
[   67.459511]  vfs_write+0x96/0x190
[   67.461042]  SyS_write+0x44/0xa0
[   67.462737]  do_fast_syscall_32+0x87/0x179
[   67.464471]  entry_SYSENTER_32+0x4e/0x7c
[   67.466141] EIP: 0xb7fd2da1
[   67.467484] EFLAGS: 00000246 CPU: 2
[   67.469020] EAX: ffffffda EBX: 00000003 ECX: 0804a060 EDX: 00001000
[   67.471392] ESI: 00000009 EDI: 00000000 EBP: bfc76ff8 ESP: bfc76fb8
[   67.473702]  DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 007b
[   67.475803] Code: db 75 28 eb 5c 66 90 8d b3 74 01 00 00 89 f0 e8 3b 2a 4e 00 8b 4f 20 39 d9 74 2c 89 c2 89 f0 e8 db 26 4e 00 8b 5f 20 85 db 74 36 <8b> 83 70 01 00 00 85 c0 7f d2 89 d9 5b 89 c8 5e 5f 5d c3 90 31
[   67.483059] EIP: lock_page_memcg+0x3c/0x80 SS:ESP: 0068:f29438d8
[   67.485404] CR2: 0000000000000180
[   67.487139] ---[ end trace 8260c8de0ee96afd ]---
----------------------------------------

----------------------------------------
[   47.171548] BUG: unable to handle kernel paging request at 32eac034
[   47.174531] IP: page_remove_rmap+0x19a/0x2e0
[   47.176259] *pde = 00000000 
[   47.177373] Oops: 0002 [#1] SMP DEBUG_PAGEALLOC
[   47.179335] Modules linked in: ip6t_rpfilter ipt_REJECT nf_reject_ipv4 ip6t_REJECT nf_reject_ipv6 xt_conntrack ip_set nfnetlink ebtable_nat ebtable_broute bridge stp llc ip6table_nat nf_conntrack_ipv6 nf_defrag_ipv6 nf_nat_ipv6 ip6table_mangle ip6table_raw iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack iptable_mangle iptable_raw ebtable_filter ebtables ip6table_filter ip6_tables iptable_filter coretemp vmw_balloon pcspkr sg vmw_vmci i2c_piix4 shpchp ip_tables xfs libcrc32c sr_mod cdrom sd_mod ata_generic pata_acpi serio_raw mptspi scsi_transport_spi mptscsih e1000 mptbase ata_piix libata
[   47.202163] CPU: 6 PID: 2947 Comm: a.out Not tainted 4.15.0-rc6+ #259
[   47.204828] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
[   47.210263] EIP: page_remove_rmap+0x19a/0x2e0
[   47.212606] EFLAGS: 00010286 CPU: 6
[   47.214687] EAX: 00000000 EBX: f342cbe0 ECX: ffffffe2 EDX: 0000000d
[   47.217816] ESI: ffffffff EDI: f4a29240 EBP: cc4e1a6c ESP: cc4e1a64
[   47.220462]  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
[   47.222837] CR0: 80050033 CR2: 32eac034 CR3: 2bb4a000 CR4: 000406d0
[   47.225461] Call Trace:
[   47.226954]  try_to_unmap_one+0x20e/0x590
[   47.228920]  rmap_walk_file+0x13c/0x250
[   47.230802]  rmap_walk+0x32/0x60
[   47.232945]  try_to_unmap+0x4d/0x100
[   47.235331]  ? page_remove_rmap+0x2e0/0x2e0
[   47.237999]  ? page_not_mapped+0x10/0x10
[   47.240660]  ? page_get_anon_vma+0x80/0x80
[   47.243251]  shrink_page_list+0x3a2/0x1010
[   47.245916]  shrink_inactive_list+0x1b2/0x440
[   47.248042]  shrink_node_memcg+0x34a/0x770
[   47.250084]  ? __queue_work+0xf2/0x290
[   47.252020]  shrink_node+0xbb/0x2e0
[   47.253940]  do_try_to_free_pages+0xba/0x320
[   47.256063]  try_to_free_pages+0x11d/0x340
[   47.258152]  ? __switch_to+0xa2/0x220
[   47.260102]  __alloc_pages_slowpath+0x303/0x6e2
[   47.262314]  ? page_cache_tree_insert+0xb0/0xb0
[   47.264506]  __alloc_pages_nodemask+0x1a7/0x1c0
[   47.266713]  wp_page_copy+0x5f/0x650
[   47.268627]  ? reuse_swap_page+0x64/0x200
[   47.270586]  do_wp_page+0x82/0x450
[   47.272541]  ? filemap_fdatawait_keep_errors+0x50/0x50
[   47.274707]  handle_mm_fault+0x522/0x8d0
[   47.276547]  __do_page_fault+0x1ef/0x4e0
[   47.278328]  ? __do_page_fault+0x4e0/0x4e0
[   47.280160]  do_page_fault+0x1a/0x20
[   47.281798]  common_exception+0x6f/0x76
[   47.283490] EIP: 0xb7f86025
[   47.284869] EFLAGS: 00010246 CPU: 6
[   47.286405] EAX: b7e91930 EBX: b7f99fbc ECX: 0804a00c EDX: 00000000
[   47.289057] ESI: b7f983d0 EDI: b7db39cc EBP: bfe325b0 ESP: bfe32568
[   47.291615]  DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 007b
[   47.293891] Code: ff ff ff 89 f1 ba 0d 00 00 00 b8 20 f8 8e c1 e8 3d 37 fe ff 66 66 66 66 90 8b 43 20 85 c0 74 1f 66 66 66 66 90 8b 80 80 01 00 00 <64> 01 70 34 8b 43 20 8b 80 fc 01 00 00 8b 40 44 64 01 70 34 8b
[   47.301428] EIP: page_remove_rmap+0x19a/0x2e0 SS:ESP: 0068:cc4e1a64
[   47.303992] CR2: 0000000032eac034
[   47.305695] ---[ end trace 1887d451e7998639 ]---
[   47.310724] BUG: unable to handle kernel paging request at 5a5a5a04
[   47.313277] IP: blk_flush_plug_list+0x77/0x210
[   47.315196] *pde = 00000000 
[   47.316683] Oops: 0002 [#2] SMP DEBUG_PAGEALLOC
[   47.318630] Modules linked in: ip6t_rpfilter ipt_REJECT nf_reject_ipv4 ip6t_REJECT nf_reject_ipv6 xt_conntrack ip_set nfnetlink ebtable_nat ebtable_broute bridge stp llc ip6table_nat nf_conntrack_ipv6 nf_defrag_ipv6 nf_nat_ipv6 ip6table_mangle ip6table_raw iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack iptable_mangle iptable_raw ebtable_filter ebtables ip6table_filter ip6_tables iptable_filter coretemp vmw_balloon pcspkr sg vmw_vmci i2c_piix4 shpchp ip_tables xfs libcrc32c sr_mod cdrom sd_mod ata_generic pata_acpi serio_raw mptspi scsi_transport_spi mptscsih e1000 mptbase ata_piix libata
[   47.339036] CPU: 0 PID: 2947 Comm: a.out Tainted: G      D          4.15.0-rc6+ #259
[   47.342045] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
[   47.346781] EIP: blk_flush_plug_list+0x77/0x210
[   47.348958] EFLAGS: 00010297 CPU: 0
[   47.350841] EAX: cc4e1e40 EBX: cc4e1e40 ECX: eeed0ad7 EDX: 5a5a5a00
[   47.353501] ESI: 00000001 EDI: cc4e1cbc EBP: cc4e1e58 ESP: cc4e1e2c
[   47.356178]  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
[   47.358636] CR0: 80050033 CR2: 5a5a5a04 CR3: 019d0000 CR4: 000406d0
[   47.361376] Call Trace:
[   47.363000]  schedule+0x52/0x70
[   47.364817]  rwsem_down_write_failed+0x185/0x290
[   47.367133]  call_rwsem_down_write_failed+0x9/0xc
[   47.369496]  down_write+0x20/0x30
[   47.371376]  unlink_file_vma+0x25/0x40
[   47.373370]  free_pgtables+0x33/0xf0
[   47.375323]  ? unmap_vmas+0x3b/0x50
[   47.377312]  exit_mmap+0x92/0x140
[   47.379162]  mmput+0x4f/0xf0
[   47.380827]  do_exit+0x22c/0xa10
[   47.382738]  ? __do_page_fault+0x4e0/0x4e0
[   47.384775]  rewind_stack_do_exit+0x11/0x13
[   47.386850] EIP: 0xb7f86025
[   47.388512] EFLAGS: 00010246 CPU: 0
[   47.390300] EAX: b7e91930 EBX: b7f99fbc ECX: 0804a00c EDX: 00000000
[   47.392883] ESI: b7f983d0 EDI: b7db39cc EBP: bfe325b0 ESP: bfe32568
[   47.395478]  DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 007b
[   47.397799] Code: 45 e8 8b 57 14 89 4d e8 89 59 04 89 02 89 50 04 8b 45 dc 89 47 10 89 47 14 8d 76 00 8b 45 e8 39 c3 74 c9 8b 4d e8 8b 11 8b 41 04 <89> 42 04 89 10 89 f2 89 c8 c7 01 00 01 00 00 c7 41 04 00 02 00
[   47.405344] EIP: blk_flush_plug_list+0x77/0x210 SS:ESP: 0068:cc4e1e2c
[   47.407978] CR2: 000000005a5a5a04
[   47.409744] ---[ end trace 1887d451e799863a ]---
----------------------------------------

----------------------------------------
[  121.578226] BUG: unable to handle kernel paging request at 330fa01a
[  121.581057] IP: page_remove_rmap+0x14/0x2e0
[  121.583085] *pde = 00000000 
[  121.584784] Oops: 0000 [#1] SMP DEBUG_PAGEALLOC
[  121.586923] Modules linked in: ip6t_rpfilter ipt_REJECT nf_reject_ipv4 ip6t_REJECT nf_reject_ipv6 xt_conntrack ip_set nfnetlink ebtable_nat ebtable_broute bridge stp llc ip6table_nat nf_conntrack_ipv6 nf_defrag_ipv6 nf_nat_ipv6 ip6table_mangle ip6table_raw iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack iptable_mangle iptable_raw ebtable_filter ebtables ip6table_filter ip6_tables iptable_filter coretemp vmw_balloon pcspkr vmw_vmci sg i2c_piix4 shpchp ip_tables xfs libcrc32c sr_mod cdrom sd_mod ata_generic pata_acpi serio_raw mptspi scsi_transport_spi mptscsih e1000 ata_piix mptbase libata
[  121.607308] CPU: 0 PID: 402 Comm: systemd-journal Not tainted 4.15.0-rc6+ #259
[  121.610170] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
[  121.615142] EIP: page_remove_rmap+0x14/0x2e0
[  121.617238] EFLAGS: 00010202 CPU: 0
[  121.619085] EAX: 330fa016 EBX: f3246808 ECX: 00001534 EDX: 00000000
[  121.621615] ESI: 00001533 EDI: f4af1d30 EBP: f2bb7a34 ESP: f2bb7a2c
[  121.624079]  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
[  121.626348] CR0: 80050033 CR2: 330fa01a CR3: 32b46000 CR4: 000406d0
[  121.629207] Call Trace:
[  121.630896]  try_to_unmap_one+0x20e/0x590
[  121.632921]  rmap_walk_file+0x13c/0x250
[  121.634703]  rmap_walk+0x32/0x60
[  121.636312]  try_to_unmap+0x4d/0x100
[  121.637987]  ? page_remove_rmap+0x2e0/0x2e0
[  121.639813]  ? page_not_mapped+0x10/0x10
[  121.641569]  ? page_get_anon_vma+0x80/0x80
[  121.643473]  shrink_page_list+0x3a2/0x1010
[  121.645371]  ? wake_up_worker+0x1c/0x20
[  121.647311]  shrink_inactive_list+0x1b2/0x440
[  121.649337]  shrink_node_memcg+0x34a/0x770
[  121.651141]  shrink_node+0xbb/0x2e0
[  121.652797]  do_try_to_free_pages+0xba/0x320
[  121.654649]  try_to_free_pages+0x11d/0x340
[  121.656427]  ? schedule_timeout+0x136/0x200
[  121.658204]  __alloc_pages_slowpath+0x303/0x6e2
[  121.660145]  __alloc_pages_nodemask+0x1a7/0x1c0
[  121.662107]  filemap_fault+0x3ca/0x610
[  121.663953]  ? radix_tree_next_chunk+0xf1/0x2c0
[  121.665860]  ? _cond_resched+0x12/0x30
[  121.667507]  ? down_read+0xb/0x30
[  121.669004]  ? filemap_fdatawait_keep_errors+0x50/0x50
[  121.670954]  __xfs_filemap_fault.isra.16+0x2d/0xb0 [xfs]
[  121.672910]  ? filemap_fdatawait_keep_errors+0x50/0x50
[  121.674819]  xfs_filemap_fault+0xa/0x10 [xfs]
[  121.676503]  __do_fault+0x11/0x60
[  121.678115]  handle_mm_fault+0x6dd/0x8d0
[  121.679850]  ? ep_poll+0x1b2/0x340
[  121.681347]  __do_page_fault+0x1ef/0x4e0
[  121.682889]  ? __do_page_fault+0x4e0/0x4e0
[  121.684422]  do_page_fault+0x1a/0x20
[  121.685827]  common_exception+0x6f/0x76
[  121.687285] EIP: 0xb7d89ad8
[  121.688492] EFLAGS: 00010246 CPU: 0
[  121.689858] EAX: 00000001 EBX: 00000007 ECX: bfd3e800 EDX: 00000012
[  121.691915] ESI: ffffffff EDI: 00000012 EBP: bfd3e9b8 ESP: bfd3e7e4
[  121.694042]  DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 007b
[  121.696023] Code: c4 fe ff ff ba 78 55 7f c1 89 d8 e8 47 e5 fe ff 0f 0b 83 e8 01 eb 8e 55 89 e5 56 53 89 c3 8b 40 14 a8 01 0f 85 be 01 00 00 89 d8 <f6> 40 04 01 74 5e 84 d2 0f 85 9e 00 00 00 f0 83 43 0c ff 78 07
[  121.702493] EIP: page_remove_rmap+0x14/0x2e0 SS:ESP: 0068:f2bb7a2c
[  121.704587] CR2: 00000000330fa01a
[  121.706032] ---[ end trace 6878785dacdbec93 ]---
----------------------------------------

----------------------------------------
localhost login: [   87.199039] BUG: unable to handle kernel paging request at 3304501a
[   87.200976] IP: page_remove_rmap+0x14/0x2e0
[   87.202311] *pde = 00000000 
[   87.203268] Oops: 0000 [#1] SMP DEBUG_PAGEALLOC
[   87.204740] Modules linked in: ip6t_rpfilter ipt_REJECT nf_reject_ipv4 ip6t_REJECT nf_reject_ipv6 xt_conntrack ip_set nfnetlink ebtable_nat ebtable_broute bridge stp llc ip6table_nat nf_conntrack_ipv6 nf_defrag_ipv6 nf_nat_ipv6 ip6table_mangle ip6table_raw iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack iptable_mangle iptable_raw ebtable_filter ebtables ip6table_filter ip6_tables iptable_filter coretemp pcspkr vmw_balloon sg vmw_vmci shpchp i2c_piix4 ip_tables xfs libcrc32c sd_mod sr_mod cdrom ata_generic pata_acpi mptspi e1000 ata_piix scsi_transport_spi mptscsih mptbase libata serio_raw
[   87.221708] CPU: 0 PID: 32 Comm: kswapd0 Not tainted 4.15.0-rc6+ #259
[   87.223963] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
[   87.227825] EIP: page_remove_rmap+0x14/0x2e0
[   87.229475] EFLAGS: 00210202 CPU: 0
[   87.230981] EAX: 33045016 EBX: f30afe40 ECX: 00000eca EDX: 00000000
[   87.233204] ESI: 00000e7e EDI: f494dd08 EBP: f35ebc4c ESP: f35ebc44
[   87.235533]  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
[   87.237674] CR0: 80050033 CR2: 3304501a CR3: 019d0000 CR4: 000406d0
[   87.240187] Call Trace:
[   87.241491]  try_to_unmap_one+0x20e/0x590
[   87.243246]  rmap_walk_file+0x13c/0x250
[   87.244921]  rmap_walk+0x32/0x60
[   87.246500]  try_to_unmap+0x4d/0x100
[   87.248134]  ? page_remove_rmap+0x2e0/0x2e0
[   87.249932]  ? page_not_mapped+0x10/0x10
[   87.251897]  ? page_get_anon_vma+0x80/0x80
[   87.253806]  shrink_page_list+0x3a2/0x1010
[   87.255700]  shrink_inactive_list+0x1b2/0x440
[   87.257671]  shrink_node_memcg+0x34a/0x770
[   87.259527]  shrink_node+0xbb/0x2e0
[   87.261369]  kswapd+0x23f/0x5c0
[   87.263047]  kthread+0xd1/0x100
[   87.264812]  ? mem_cgroup_shrink_node+0xa0/0xa0
[   87.267011]  ? kthread_associate_blkcg+0x80/0x80
[   87.269229]  ret_from_fork+0x19/0x24
[   87.271061] Code: c4 fe ff ff ba 78 55 7f c1 89 d8 e8 47 e5 fe ff 0f 0b 83 e8 01 eb 8e 55 89 e5 56 53 89 c3 8b 40 14 a8 01 0f 85 be 01 00 00 89 d8 <f6> 40 04 01 74 5e 84 d2 0f 85 9e 00 00 00 3e 83 43 0c ff 78 07
[   87.278478] EIP: page_remove_rmap+0x14/0x2e0 SS:ESP: 0068:f35ebc44
[   87.280872] CR2: 000000003304501a
[   87.282602] ---[ end trace dd23f463fd05949e ]---
----------------------------------------

----------------------------------------
localhost login: [   44.046356] a.out invoked oom-killer: gfp_mask=0x14280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO), nodemask=(null), order=0, oom_score_adj=0
[   44.050525] CPU: 7 PID: 2807 Comm: a.out Not tainted 4.15.0-rc6+ #260
[   44.052755] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
[   44.057764] Call Trace:
[   44.059257]  dump_stack+0x58/0x76
[   44.061118]  dump_header+0x66/0x261
[   44.063095]  ? ___ratelimit+0x83/0xf0
[   44.065194]  oom_kill_process+0x1e5/0x3e0
[   44.067397]  ? has_capability_noaudit+0x1f/0x30
[   44.069842]  ? oom_badness+0xd0/0x130
[   44.071974]  ? oom_evaluate_task+0xa2/0xe0
[   44.074257]  out_of_memory+0xf2/0x290
[   44.076144]  __alloc_pages_slowpath+0x5c1/0x6e2
[   44.078336]  __alloc_pages_nodemask+0x1a7/0x1c0
[   44.080369]  do_anonymous_page+0xab/0x4f0
[   44.082067]  handle_mm_fault+0x531/0x8d0
[   44.083738]  ? __phys_addr+0x32/0x70
[   44.085469]  ? load_new_mm_cr3+0x6a/0x90
[   44.087200]  __do_page_fault+0x1ef/0x4e0
[   44.089274]  ? __do_page_fault+0x4e0/0x4e0
[   44.091028]  do_page_fault+0x1a/0x20
[   44.092647]  common_exception+0x6f/0x76
[   44.094341] EIP: 0x80484be
[   44.096293] EFLAGS: 00010202 CPU: 7
[   44.098275] EAX: 00a2d000 EBX: 80000000 ECX: 38902008 EDX: 00000000
[   44.101035] ESI: 7ff00000 EDI: 00000000 EBP: bfa039f8 ESP: bfa039d0
[   44.103192] page:5a5a0697 count:-1055023618 mapcount:-1055030029 mapping:26f4be11 index:0xc11d7c83
[   44.103196] flags: 0xc10528fe(waiters|error|referenced|uptodate|dirty|lru|active|reserved|private_2|mappedtodisk|swapbacked)
[   44.103200] raw: c10528fe c114fff7 c11d7c83 c11d84f2 c11d9dfe c11daa34 c11daaa0 c13e65df
[   44.103201] raw: c13e4a1c c13e4c62
[   44.103202] page dumped because: VM_BUG_ON_PAGE(page_ref_count(page) <= 0)
[   44.103203] page->mem_cgroup:35401b27
[   44.103208] ------------[ cut here ]------------
[   44.103209] kernel BUG at ./include/linux/mm.h:844!
[   44.103214] invalid opcode: 0000 [#1] SMP DEBUG_PAGEALLOC
[   44.103214] Modules linked in: ip6t_rpfilter ipt_REJECT nf_reject_ipv4 ip6t_REJECT nf_reject_ipv6 xt_conntrack ip_set nfnetlink ebtable_nat ebtable_broute bridge stp llc ip6table_nat nf_conntrack_ipv6 nf_defrag_ipv6 nf_nat_ipv6 ip6table_mangle ip6table_raw iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack iptable_mangle iptable_raw ebtable_filter ebtables ip6table_filter ip6_tables iptable_filter coretemp sg i2c_piix4 pcspkr vmw_balloon vmw_vmci shpchp ip_tables xfs libcrc32c sr_mod cdrom sd_mod ata_generic pata_acpi serio_raw mptspi scsi_transport_spi mptscsih e1000 mptbase ata_piix libata
[   44.103246] CPU: 4 PID: 1954 Comm: a.out Not tainted 4.15.0-rc6+ #260
[   44.103247] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
[   44.103253] EIP: isolate_lru_page+0x234/0x260
[   44.103254] EFLAGS: 00010086 CPU: 4
[   44.103255] EAX: 00000019 EBX: c18efb40 ECX: c18c4b5c EDX: 00000002
[   44.103256] ESI: f3179560 EDI: e910244c EBP: ee30fa80 ESP: ee30fa64
[   44.103257]  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
[   44.103258] CR0: 80050033 CR2: 3bf77008 CR3: 2e72c000 CR4: 000406d0
[   44.103332] Call Trace:
[   44.103338]  clear_page_mlock+0x71/0xc0
[   44.103340]  page_remove_rmap+0x2a9/0x2e0
[   44.103341]  try_to_unmap_one+0x20e/0x590
[   44.103344]  rmap_walk_file+0x13c/0x250
[   44.103346]  rmap_walk+0x32/0x60
[   44.103347]  try_to_unmap+0x4d/0x100
[   44.103349]  ? page_remove_rmap+0x2e0/0x2e0
[   44.103351]  ? page_not_mapped+0x10/0x10
[   44.103352]  ? page_get_anon_vma+0x80/0x80
[   44.103354]  shrink_page_list+0x3a2/0x1010
[   44.103357]  shrink_inactive_list+0x1b2/0x440
[   44.103360]  shrink_node_memcg+0x34a/0x770
[   44.103363]  shrink_node+0xbb/0x2e0
[   44.103365]  do_try_to_free_pages+0xba/0x320
[   44.103367]  try_to_free_pages+0x11d/0x340
[   44.103371]  __alloc_pages_slowpath+0x303/0x6e2
[   44.103373]  ? release_pages+0x239/0x330
[   44.103376]  __alloc_pages_nodemask+0x1a7/0x1c0
[   44.103378]  do_anonymous_page+0xab/0x4f0
[   44.103380]  handle_mm_fault+0x531/0x8d0
[   44.103383]  ? __schedule+0x173/0x5b0
[   44.103387]  __do_page_fault+0x1ef/0x4e0
[   44.103389]  ? __do_page_fault+0x4e0/0x4e0
[   44.103390]  do_page_fault+0x1a/0x20
[   44.103393]  common_exception+0x6f/0x76
[   44.103394] EIP: 0x80484be
[   44.103395] EFLAGS: 00010202 CPU: 4
[   44.103396] EAX: 00d66000 EBX: 80000000 ECX: 38b97008 EDX: 00000000
[   44.103397] ESI: 7ff00000 EDI: 00000000 EBP: bfcd2948 ESP: bfcd2920
[   44.103398]  DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 007b
[   44.103399] Code: fe ff ff 83 e8 01 e9 6b fe ff ff ba 80 44 7f c1 89 f0 e8 90 66 01 00 0f 0b 83 e8 01 e9 ac fe ff ff ba 3c a5 7d c1 e8 7c 66 01 00 <0f> 0b 83 e8 01 e9 b4 fe ff ff 89 f0 e8 4c 3a 00 00 83 e8 01 e9
[   44.103425] EIP: isolate_lru_page+0x234/0x260 SS:ESP: 0068:ee30fa64
[   44.103427] ---[ end trace e79ca6d793be8d54 ]---
[   44.300720]  DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 007b
[   44.303579] Mem-Info:
[   44.305289] active_anon:690488 inactive_anon:2081 isolated_anon:0
[   44.305289]  active_file:508 inactive_file:529 isolated_file:27
[   44.305289]  unevictable:0 dirty:0 writeback:662 unstable:0
[   44.305289]  slab_reclaimable:1410 slab_unreclaimable:20537
[   44.305289]  mapped:459 shmem:2151 pagetables:11526 bounce:0
[   44.305289]  free:30998 free_pcp:59 free_cma:0
[   44.322423] Node 0 active_anon:2761952kB inactive_anon:8324kB active_file:2032kB inactive_file:2116kB unevictable:0kB isolated(anon):0kB isolated(file):108kB mapped:1836kB dirty:0kB writeback:2648kB shmem:8604kB shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 323584kB writeback_tmp:0kB unstable:0kB all_unreclaimable? no
[   44.336597] DMA free:12708kB min:788kB low:984kB high:1180kB active_anon:3192kB inactive_anon:0kB active_file:0kB inactive_file:4kB unevictable:0kB writepending:0kB present:15992kB managed:15916kB mlocked:0kB kernel_stack:0kB pagetables:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[   44.349286] lowmem_reserve[]: 0 812 2996 2996
[   44.352127] Normal free:110912kB min:41308kB low:51632kB high:61956kB active_anon:547592kB inactive_anon:0kB active_file:300kB inactive_file:236kB unevictable:0kB writepending:352kB present:892920kB managed:831668kB mlocked:0kB kernel_stack:23088kB pagetables:46104kB bounce:0kB free_pcp:108kB local_pcp:0kB free_cma:0kB
[   44.367461] lowmem_reserve[]: 0 0 17471 17471
[   44.370437] HighMem free:372kB min:512kB low:28280kB high:56048kB active_anon:2210712kB inactive_anon:8324kB active_file:1312kB inactive_file:1724kB unevictable:0kB writepending:1176kB present:2236360kB managed:2236360kB mlocked:0kB kernel_stack:0kB pagetables:0kB bounce:0kB free_pcp:128kB local_pcp:0kB free_cma:0kB
[   44.386249] lowmem_reserve[]: 0 0 0 0
[   44.389137] DMA: 13*4kB (UM) 2*8kB (UM) 2*16kB (UM) 0*32kB 3*64kB (UM) 1*128kB (U) 2*256kB (UM) 1*512kB (M) 1*1024kB (U) 1*2048kB (U) 2*4096kB (M) = 12708kB
[   44.397316] Normal: 377*4kB (UM) 382*8kB (UME) 274*16kB (UE) 95*32kB (UME) 39*64kB (UME) 14*128kB (UME) 12*256kB (UME) 3*512kB (ME) 0*1024kB 2*2048kB (ME) 21*4096kB (M) = 110996kB
[   44.406379] HighMem: 0*4kB 1*8kB (M) 3*16kB (M) 2*32kB (M) 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 120kB
[   44.413805] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=4096kB
[   44.421438] 3325 total pagecache pages
[   44.424507] 0 pages in swap cache
[   44.427416] Swap cache stats: add 0, delete 0, find 0/0
[   44.431158] Free swap  = 0kB
[   44.433919] Total swap = 0kB
[   44.436623] 786318 pages RAM
[   44.439339] 559090 pages HighMem/MovableOnly
[   44.442496] 15332 pages reserved
[   44.445283] 0 pages cma reserved
[   44.448070] Out of memory: Kill process 962 (a.out) score 32 or sacrifice child
[   44.452335] Killed process 1167 (a.out) total-vm:2108kB, anon-rss:60kB, file-rss:0kB, shmem-rss:0kB
----------------------------------------

So far I can reproduce this problem when running a guest on an i7-2630QM (8 core) host
but not on an i5-4440S (4 core) host. Thus, maybe this is an architecture specific problem.

----------------------------------------
1c1
< Linux version 4.15.0-rc6+ (root@localhost.localdomain) (gcc version 4.8.5 20150623 (Red Hat 4.8.5-16) (GCC)) #258 SMP Thu Jan 4 16:19:44 JST 2018
---
> Linux version 4.15.0-rc6+ (root@localhost.localdomain) (gcc version 4.8.5 20150623 (Red Hat 4.8.5-16) (GCC)) #195 SMP Fri Jan 5 21:10:49 JST 2018
26c26
< vmware: TSC freq read from hypervisor : 1995.458 MHz
---
> vmware: TSC freq read from hypervisor : 2793.542 MHz
28c28
< vmware: using sched offset of 5372044450 ns
---
> vmware: using sched offset of 57103384027 ns
36c36
< RAMDISK: [mem 0x35fb5000-0x36fd2fff]
---
> RAMDISK: [mem 0x35fda000-0x36fe4fff]
39c39
< ACPI: XSDT 0x00000000BFEF00CB 00005C (v01 INTEL  440BX    06040000 VMW  01324272)
---
> ACPI: XSDT 0x00000000BFEF02EF 00005C (v01 INTEL  440BX    06040000 VMW  01324272)
41c41
< ACPI: DSDT 0x00000000BFEF0405 00EA6E (v01 PTLTD  Custom   06040000 MSFT 03000001)
---
> ACPI: DSDT 0x00000000BFEF05B1 00E8C2 (v01 PTLTD  Custom   06040000 MSFT 03000001)
44,49c44,49
< ACPI: BOOT 0x00000000BFEF03DD 000028 (v01 PTLTD  $SBFTBL$ 06040000  LTP 00000001)
< ACPI: APIC 0x00000000BFEF032B 0000B2 (v01 PTLTD  ? APIC   06040000  LTP 00000000)
< ACPI: MCFG 0x00000000BFEF02EF 00003C (v01 PTLTD  $PCITBL$ 06040000  LTP 00000001)
< ACPI: SRAT 0x00000000BFEF01C7 000128 (v02 VMWARE MEMPLUG  06040000 VMW  00000001)
< ACPI: HPET 0x00000000BFEF018F 000038 (v01 VMWARE VMW HPET 06040000 VMW  00000001)
< ACPI: WAET 0x00000000BFEF0167 000028 (v01 VMWARE VMW WAET 06040000 VMW  00000001)
---
> ACPI: BOOT 0x00000000BFEF0589 000028 (v01 PTLTD  $SBFTBL$ 06040000  LTP 00000001)
> ACPI: APIC 0x00000000BFEF050F 00007A (v01 PTLTD  ? APIC   06040000  LTP 00000000)
> ACPI: MCFG 0x00000000BFEF04D3 00003C (v01 PTLTD  $PCITBL$ 06040000  LTP 00000001)
> ACPI: SRAT 0x00000000BFEF03EB 0000E8 (v02 VMWARE MEMPLUG  06040000 VMW  00000001)
> ACPI: HPET 0x00000000BFEF03B3 000038 (v01 VMWARE VMW HPET 06040000 VMW  00000001)
> ACPI: WAET 0x00000000BFEF038B 000028 (v01 VMWARE VMW WAET 06040000 VMW  00000001)
54d53
< crashkernel: memory value expected
72,75d70
< ACPI: LAPIC_NMI (acpi_id[0x04] high edge lint[0x1])
< ACPI: LAPIC_NMI (acpi_id[0x05] high edge lint[0x1])
< ACPI: LAPIC_NMI (acpi_id[0x06] high edge lint[0x1])
< ACPI: LAPIC_NMI (acpi_id[0x07] high edge lint[0x1])
79c74
< smpboot: Allowing 8 CPUs, 0 hotplug CPUs
---
> smpboot: Allowing 4 CPUs, 0 hotplug CPUs
87c82
< setup_percpu: NR_CPUS:8 nr_cpumask_bits:8 nr_cpu_ids:8 nr_node_ids:1
---
> setup_percpu: NR_CPUS:8 nr_cpumask_bits:8 nr_cpu_ids:4 nr_node_ids:1
90c85
< Kernel command line: BOOT_IMAGE=/boot/vmlinuz-4.15.0-rc6+ root=UUID=dcfdc514-ddcb-4f0c-bddf-e229701a66e5 ro crashkernel=auto sysrq_always_enabled console=ttyS0,115200n8 console=tty0 LANG=en_US.UTF-8
---
> Kernel command line: BOOT_IMAGE=/boot/vmlinuz-4.15.0-rc6+ root=UUID=c6605616-f00a-4630-97c1-847f8e0c850f ro security=none sysrq_always_enabled console=ttyS0,115200n8 console=tty0
97c92
< Memory: 3085040K/3145272K available (6360K kernel code, 391K rwdata, 2408K rodata, 640K init, 1280K bss, 60232K reserved, 0K cma-reserved, 2236360K highmem)
---
> Memory: 3085528K/3145272K available (6385K kernel code, 388K rwdata, 2416K rodata, 644K init, 1280K bss, 59744K reserved, 0K cma-reserved, 2236360K highmem)
104,106c99,101
<       .init : 0xc1907000 - 0xc19a7000   ( 640 kB)
<       .data : 0xc1636011 - 0xc18f6f60   (2819 kB)
<       .text : 0xc1000000 - 0xc1636011   (6360 kB)
---
>       .init : 0xc190f000 - 0xc19b0000   ( 644 kB)
>       .data : 0xc163c611 - 0xc18ff060   (2826 kB)
>       .text : 0xc1000000 - 0xc163c611   (6385 kB)
108c103
< SLUB: HWalign=64, Order=0-3, MinObjects=0, CPUs=8, Nodes=1
---
> SLUB: HWalign=64, Order=0-3, MinObjects=0, CPUs=4, Nodes=1
110c105,107
< NR_IRQS: 2304, nr_irqs: 488, preallocated irqs: 16
---
>       RCU restricting CPUs from NR_CPUS=8 to nr_cpu_ids=4.
> RCU: Adjusting geometry for rcu_fanout_leaf=16, nr_cpu_ids=4
> NR_IRQS: 2304, nr_irqs: 456, preallocated irqs: 16
119,120c116,117
< tsc: Detected 1995.458 MHz processor
< Calibrating delay loop (skipped) preset value.. 3990.91 BogoMIPS (lpj=1995458)
---
> tsc: Detected 2793.542 MHz processor
> Calibrating delay loop (skipped) preset value.. 5587.08 BogoMIPS (lpj=2793542)
129,130c126,127
< Last level iTLB entries: 4KB 512, 2MB 8, 4MB 8
< Last level dTLB entries: 4KB 512, 2MB 32, 4MB 32, 1GB 0
---
> Last level iTLB entries: 4KB 1024, 2MB 1024, 4MB 1024
> Last level dTLB entries: 4KB 1024, 2MB 1024, 4MB 1024, 1GB 4
132,133c129,130
< smpboot: CPU0: Intel(R) Core(TM) i7-2630QM CPU @ 2.00GHz (family: 0x6, model: 0x2a, stepping: 0x7)
< Performance Events: SandyBridge events, core PMU driver.
---
> smpboot: CPU0: Intel(R) Core(TM) i5-4440S CPU @ 2.80GHz (family: 0x6, model: 0x3c, stepping: 0x3)
> Performance Events: Haswell events, core PMU driver.
143c140
< ... generic registers:      4
---
> ... generic registers:      8
147c144
< ... event mask:             000000000000000f
---
> ... event mask:             00000000000000ff
166,188c163,165
<  #4
< Initializing CPU#4
< Disabled fast string operations
< mce: CPU supports 0 MCE banks
< smpboot: CPU 4 Converting physical 8 to logical package 4
<  #5
< Initializing CPU#5
< Disabled fast string operations
< mce: CPU supports 0 MCE banks
< smpboot: CPU 5 Converting physical 10 to logical package 5
<  #6
< Initializing CPU#6
< Disabled fast string operations
< mce: CPU supports 0 MCE banks
< smpboot: CPU 6 Converting physical 12 to logical package 6
<  #7
< Initializing CPU#7
< Disabled fast string operations
< mce: CPU supports 0 MCE banks
< smpboot: CPU 7 Converting physical 14 to logical package 7
< smp: Brought up 1 node, 8 CPUs
< smpboot: Max logical packages: 8
< smpboot: Total of 8 processors activated (31927.32 BogoMIPS)
---
> smp: Brought up 1 node, 4 CPUs
> smpboot: Max logical packages: 4
> smpboot: Total of 4 processors activated (22348.33 BogoMIPS)
192c169
< futex hash table entries: 2048 (order: 4, 65536 bytes)
---
> futex hash table entries: 1024 (order: 3, 32768 bytes)
----------------------------------------

Reproducer is simple. Put the system under memory pressure
while writing to a file on XFS filesystem.

----------------------------------------
#define _FILE_OFFSET_BITS 64
#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <unistd.h>
#include <fcntl.h>

static void run(void)
{
        unsigned long long size;
        char *buf = NULL;
        unsigned long long i;
        for (i = 0; i < 24; i++) {
                if (fork() == 0) {
                        static char buf[4096];
                        int fd;
                        snprintf(buf, sizeof(buf), "file.%u", getpid());
                        fd = open(buf, O_CREAT | O_WRONLY | O_APPEND, 0600);
                        while (write(fd, buf, sizeof(buf)) == sizeof(buf));
                        close(fd);
                        _exit(0);
                }
        }
        for (size = 1048576; size < 512ULL * (1 << 30); size += 1048576) {
                char *cp = realloc(buf, size);
                if (!cp) {
                        size -= 1048576;
                        break;
                }
                buf = cp;
        }
        for (i = 0; i < size; i += 4096)
                buf[i] = 0;
        _exit(0);
}

int main(int argc, char *argv[])
{
        if (argc != 1)
                run();
        else
                while (1)
                        if (fork() == 0)
                                execlp(argv[0], argv[0], "", NULL);
        return 0;
}
----------------------------------------

Do you have any clue?

(Since I need to use i7-2630QM for testing, I won't be able to test
until next Tuesday, sorry.)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
