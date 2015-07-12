Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f50.google.com (mail-la0-f50.google.com [209.85.215.50])
	by kanga.kvack.org (Postfix) with ESMTP id 2ABF76B0253
	for <linux-mm@kvack.org>; Sun, 12 Jul 2015 06:56:47 -0400 (EDT)
Received: by lagw2 with SMTP id w2so873288lag.3
        for <linux-mm@kvack.org>; Sun, 12 Jul 2015 03:56:46 -0700 (PDT)
Received: from mail-la0-x22b.google.com (mail-la0-x22b.google.com. [2a00:1450:4010:c03::22b])
        by mx.google.com with ESMTPS id qa2si12401298lbb.153.2015.07.12.03.56.43
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 12 Jul 2015 03:56:43 -0700 (PDT)
Received: by lagx9 with SMTP id x9so286710880lag.1
        for <linux-mm@kvack.org>; Sun, 12 Jul 2015 03:56:43 -0700 (PDT)
Date: Sun, 12 Jul 2015 12:56:34 +0200
From: Marcin =?utf-8?Q?=C5=9Alusarz?= <marcin.slusarz@gmail.com>
Subject: cpu_hotplug vs oom_notify_list: possible circular locking dependency
 detected
Message-ID: <20150712105634.GA11708@marcin-Inspiron-7720>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: linux-mm@kvack.org

[28954.363492] ======================================================
[28954.363492] [ INFO: possible circular locking dependency detected ]
[28954.363494] 4.1.2 #56 Not tainted
[28954.363494] -------------------------------------------------------
[28954.363495] pm-suspend/16647 is trying to acquire lock:
[28954.363502]  (s_active#22){++++.+}, at: [<ffffffff812ce269>] kernfs_remove_by_name_ns+0x49/0xb0
[28954.363502] 
but task is already holding lock:
[28954.363505]  (cpu_hotplug.lock#2){+.+.+.}, at: [<ffffffff810b6042>] cpu_hotplug_begin+0x72/0xc0
[28954.363506] 
which lock already depends on the new lock.

[28954.363506] 
the existing dependency chain (in reverse order) is:
[28954.363508] 
-> #4 (cpu_hotplug.lock#2){+.+.+.}:
[28954.363511]        [<ffffffff811103db>] lock_acquire+0xbb/0x290
[28954.363514]        [<ffffffff8179d194>] down_read+0x34/0x50
[28954.363517]        [<ffffffff810dc419>] __blocking_notifier_call_chain+0x39/0x70
[28954.363518]        [<ffffffff810dc466>] blocking_notifier_call_chain+0x16/0x20
[28954.363521]        [<ffffffff811ddaff>] __out_of_memory+0x3f/0x660
[28954.363522]        [<ffffffff811de2bb>] out_of_memory+0x5b/0x80
[28954.363524]        [<ffffffff811e463b>] __alloc_pages_nodemask+0xa7b/0xc20
[28954.363527]        [<ffffffff8122a683>] alloc_pages_current+0xf3/0x1a0
[28954.363528]        [<ffffffff811d9067>] __page_cache_alloc+0x117/0x140
[28954.363530]        [<ffffffff811dbebf>] filemap_fault+0x19f/0x3d0
[28954.363531]        [<ffffffff812088cd>] __do_fault+0x3d/0xc0
[28954.363533]        [<ffffffff8120c2e0>] handle_mm_fault+0xcd0/0x11a0
[28954.363535]        [<ffffffff810a371c>] __do_page_fault+0x18c/0x510
[28954.363536]        [<ffffffff810a3aac>] do_page_fault+0xc/0x10
[28954.363538]        [<ffffffff817a1a62>] page_fault+0x22/0x30
[28954.363539] 
-> #3 ((oom_notify_list).rwsem){++++..}:
[28954.363541]        [<ffffffff811103db>] lock_acquire+0xbb/0x290
[28954.363542]        [<ffffffff8179d194>] down_read+0x34/0x50
[28954.363544]        [<ffffffff810dc419>] __blocking_notifier_call_chain+0x39/0x70
[28954.363546]        [<ffffffff810dc466>] blocking_notifier_call_chain+0x16/0x20
[28954.363547]        [<ffffffff811ddaff>] __out_of_memory+0x3f/0x660
[28954.363549]        [<ffffffff811de2bb>] out_of_memory+0x5b/0x80
[28954.363550]        [<ffffffff811e463b>] __alloc_pages_nodemask+0xa7b/0xc20
[28954.363552]        [<ffffffff8122a683>] alloc_pages_current+0xf3/0x1a0
[28954.363553]        [<ffffffff811d9067>] __page_cache_alloc+0x117/0x140
[28954.363555]        [<ffffffff811dbebf>] filemap_fault+0x19f/0x3d0
[28954.363556]        [<ffffffff812088cd>] __do_fault+0x3d/0xc0
[28954.363557]        [<ffffffff8120c2e0>] handle_mm_fault+0xcd0/0x11a0
[28954.363558]        [<ffffffff810a371c>] __do_page_fault+0x18c/0x510
[28954.363559]        [<ffffffff810a3aac>] do_page_fault+0xc/0x10
[28954.363560]        [<ffffffff817a1a62>] page_fault+0x22/0x30
[28954.363562] 
-> #2 (oom_sem){++++..}:
[28954.363563]        [<ffffffff811103db>] lock_acquire+0xbb/0x290
[28954.363565]        [<ffffffff8179d194>] down_read+0x34/0x50
[28954.363566]        [<ffffffff811de294>] out_of_memory+0x34/0x80
[28954.363568]        [<ffffffff811e463b>] __alloc_pages_nodemask+0xa7b/0xc20
[28954.363570]        [<ffffffff8122a683>] alloc_pages_current+0xf3/0x1a0
[28954.363571]        [<ffffffff811d9067>] __page_cache_alloc+0x117/0x140
[28954.363572]        [<ffffffff811dbebf>] filemap_fault+0x19f/0x3d0
[28954.363573]        [<ffffffff812088cd>] __do_fault+0x3d/0xc0
[28954.363574]        [<ffffffff8120c2e0>] handle_mm_fault+0xcd0/0x11a0
[28954.363575]        [<ffffffff810a371c>] __do_page_fault+0x18c/0x510
[28954.363576]        [<ffffffff810a3aac>] do_page_fault+0xc/0x10
[28954.363578]        [<ffffffff817a1a62>] page_fault+0x22/0x30
[28954.363579] 
-> #1 (&mm->mmap_sem){++++++}:
[28954.363581]        [<ffffffff811103db>] lock_acquire+0xbb/0x290
[28954.363582]        [<ffffffff812087cf>] might_fault+0x6f/0xa0
[28954.363583]        [<ffffffff812cf4ec>] kernfs_fop_write+0x7c/0x1a0
[28954.363585]        [<ffffffff81245388>] __vfs_write+0x28/0xf0
[28954.363587]        [<ffffffff81245ac9>] vfs_write+0xa9/0x1b0
[28954.363588]        [<ffffffff812468e9>] SyS_write+0x49/0xb0
[28954.363589]        [<ffffffff8179fd9b>] system_call_fastpath+0x16/0x73
[28954.363591] 
-> #0 (s_active#22){++++.+}:
[28954.363593]        [<ffffffff8110f6f6>] __lock_acquire+0x1d86/0x2010
[28954.363594]        [<ffffffff811103db>] lock_acquire+0xbb/0x290
[28954.363596]        [<ffffffff812cd080>] __kernfs_remove+0x210/0x2f0
[28954.363598]        [<ffffffff812ce269>] kernfs_remove_by_name_ns+0x49/0xb0
[28954.363600]        [<ffffffff812d0a99>] sysfs_unmerge_group+0x49/0x60
[28954.363602]        [<ffffffff81537e89>] dpm_sysfs_remove+0x39/0x60
[28954.363603]        [<ffffffff8152b778>] device_del+0x58/0x280
[28954.363605]        [<ffffffff8152b9b6>] device_unregister+0x16/0x30
[28954.363606]        [<ffffffff81535b7d>] cpu_cache_sysfs_exit+0x5d/0xc0
[28954.363608]        [<ffffffff81536300>] cacheinfo_cpu_callback+0x40/0xa0
[28954.363609]        [<ffffffff810dc1f6>] notifier_call_chain+0x66/0x90
[28954.363611]        [<ffffffff810dc22e>] __raw_notifier_call_chain+0xe/0x10
[28954.363612]        [<ffffffff810b5ef3>] cpu_notify+0x23/0x50
[28954.363613]        [<ffffffff810b5fbe>] cpu_notify_nofail+0xe/0x20
[28954.363615]        [<ffffffff81792dd9>] _cpu_down+0x1d9/0x2e0
[28954.363616]        [<ffffffff810b65d8>] disable_nonboot_cpus+0xd8/0x530
[28954.363617]        [<ffffffff81117d62>] suspend_devices_and_enter+0x422/0xd60
[28954.363619]        [<ffffffff81118add>] pm_suspend+0x43d/0x530
[28954.363620]        [<ffffffff81116787>] state_store+0xa7/0xb0
[28954.363622]        [<ffffffff81419bdf>] kobj_attr_store+0xf/0x20
[28954.363623]        [<ffffffff812cfca9>] sysfs_kf_write+0x49/0x60
[28954.363624]        [<ffffffff812cf5b0>] kernfs_fop_write+0x140/0x1a0
[28954.363626]        [<ffffffff81245388>] __vfs_write+0x28/0xf0
[28954.363627]        [<ffffffff81245ac9>] vfs_write+0xa9/0x1b0
[28954.363628]        [<ffffffff812468e9>] SyS_write+0x49/0xb0
[28954.363630]        [<ffffffff8179fd9b>] system_call_fastpath+0x16/0x73
[28954.363630] 
other info that might help us debug this:

[28954.363632] Chain exists of:
  s_active#22 --> (oom_notify_list).rwsem --> cpu_hotplug.lock#2

[28954.363633]  Possible unsafe locking scenario:

[28954.363633]        CPU0                    CPU1
[28954.363633]        ----                    ----
[28954.363635]   lock(cpu_hotplug.lock#2);
[28954.363635]                                lock((oom_notify_list).rwsem);
[28954.363636]                                lock(cpu_hotplug.lock#2);
[28954.363637]   lock(s_active#22);
[28954.363638] 
 *** DEADLOCK ***

[28954.363639] 9 locks held by pm-suspend/16647:
[28954.363641]  #0:  (sb_writers#6){.+.+.+}, at: [<ffffffff81245b83>] vfs_write+0x163/0x1b0
[28954.363643]  #1:  (&of->mutex){+.+.+.}, at: [<ffffffff812cf4d6>] kernfs_fop_write+0x66/0x1a0
[28954.363646]  #2:  (s_active#186){.+.+.+}, at: [<ffffffff812cf4de>] kernfs_fop_write+0x6e/0x1a0
[28954.363649]  #3:  (autosleep_lock){+.+...}, at: [<ffffffff8111fcb7>] pm_autosleep_lock+0x17/0x20
[28954.363651]  #4:  (pm_mutex){+.+...}, at: [<ffffffff8111881c>] pm_suspend+0x17c/0x530
[28954.363654]  #5:  (acpi_scan_lock){+.+.+.}, at: [<ffffffff81495716>] acpi_scan_lock_acquire+0x17/0x19
[28954.363656]  #6:  (cpu_add_remove_lock){+.+.+.}, at: [<ffffffff810b6529>] disable_nonboot_cpus+0x29/0x530
[28954.363658]  #7:  (cpu_hotplug.lock){++++++}, at: [<ffffffff810b5fd5>] cpu_hotplug_begin+0x5/0xc0
[28954.363661]  #8:  (cpu_hotplug.lock#2){+.+.+.}, at: [<ffffffff810b6042>] cpu_hotplug_begin+0x72/0xc0
[28954.363661] 
stack backtrace:
[28954.363663] CPU: 3 PID: 16647 Comm: pm-suspend Not tainted 4.1.2 #56
[28954.363663] Hardware name: Dell Inc.          Inspiron 7720/04M3YM, BIOS A07 08/16/2012
[28954.363666]  ffffffff826415a0 ffff88008952b838 ffffffff81796918 0000000080000001
[28954.363667]  ffffffff8263e150 ffff88008952b888 ffffffff8110bf8d ffff880040334cd0
[28954.363669]  ffff88008952b8f8 0000000000000008 ffff880040334ca8 0000000000000008
[28954.363669] Call Trace:
[28954.363671]  [<ffffffff81796918>] dump_stack+0x4f/0x7b
[28954.363673]  [<ffffffff8110bf8d>] print_circular_bug+0x1cd/0x230
[28954.363674]  [<ffffffff8110f6f6>] __lock_acquire+0x1d86/0x2010
[28954.363677]  [<ffffffff811103db>] lock_acquire+0xbb/0x290
[28954.363678]  [<ffffffff812ce269>] ? kernfs_remove_by_name_ns+0x49/0xb0
[28954.363680]  [<ffffffff812cd080>] __kernfs_remove+0x210/0x2f0
[28954.363682]  [<ffffffff812ce269>] ? kernfs_remove_by_name_ns+0x49/0xb0
[28954.363683]  [<ffffffff812cc5c7>] ? kernfs_name_hash+0x17/0xa0
[28954.363685]  [<ffffffff812cd519>] ? kernfs_find_ns+0x89/0x160
[28954.363687]  [<ffffffff812ce269>] kernfs_remove_by_name_ns+0x49/0xb0
[28954.363688]  [<ffffffff812d0a99>] sysfs_unmerge_group+0x49/0x60
[28954.363689]  [<ffffffff81537e89>] dpm_sysfs_remove+0x39/0x60
[28954.363691]  [<ffffffff8152b778>] device_del+0x58/0x280
[28954.363692]  [<ffffffff8152b9b6>] device_unregister+0x16/0x30
[28954.363693]  [<ffffffff81535b7d>] cpu_cache_sysfs_exit+0x5d/0xc0
[28954.363695]  [<ffffffff81536300>] cacheinfo_cpu_callback+0x40/0xa0
[28954.363696]  [<ffffffff810dc1f6>] notifier_call_chain+0x66/0x90
[28954.363698]  [<ffffffff810dc22e>] __raw_notifier_call_chain+0xe/0x10
[28954.363699]  [<ffffffff810b5ef3>] cpu_notify+0x23/0x50
[28954.363699]  [<ffffffff810b5fbe>] cpu_notify_nofail+0xe/0x20
[28954.363700]  [<ffffffff81792dd9>] _cpu_down+0x1d9/0x2e0
[28954.363702]  [<ffffffff8110aa48>] ? __lock_is_held+0x58/0x80
[28954.363703]  [<ffffffff810b65d8>] disable_nonboot_cpus+0xd8/0x530
[28954.363704]  [<ffffffff81117d62>] suspend_devices_and_enter+0x422/0xd60
[28954.363705]  [<ffffffff81795714>] ? printk+0x46/0x48
[28954.363707]  [<ffffffff81118add>] pm_suspend+0x43d/0x530
[28954.363708]  [<ffffffff81116787>] state_store+0xa7/0xb0
[28954.363710]  [<ffffffff81419bdf>] kobj_attr_store+0xf/0x20
[28954.363711]  [<ffffffff812cfca9>] sysfs_kf_write+0x49/0x60
[28954.363712]  [<ffffffff812cf5b0>] kernfs_fop_write+0x140/0x1a0
[28954.363713]  [<ffffffff81245388>] __vfs_write+0x28/0xf0
[28954.363714]  [<ffffffff81245b83>] ? vfs_write+0x163/0x1b0
[28954.363716]  [<ffffffff813cbdb8>] ? apparmor_file_permission+0x18/0x20
[28954.363719]  [<ffffffff813bdca3>] ? security_file_permission+0x23/0xa0
[28954.363720]  [<ffffffff81245ac9>] vfs_write+0xa9/0x1b0
[28954.363721]  [<ffffffff812468e9>] SyS_write+0x49/0xb0
[28954.363723]  [<ffffffff8179fd9b>] system_call_fastpath+0x16/0x73


Precedent part below.

[    0.000000] Initializing cgroup subsys cpuset
[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Initializing cgroup subsys cpuacct
[    0.000000] Linux version 4.1.2 (marcin@marcin-Inspiron-7720) (gcc version 4.9.2 (Ubuntu 4.9.2-10ubuntu13) ) #56 SMP PREEMPT Sat Jul 11 14:18:33 CEST 2015
[    0.000000] Command line: BOOT_IMAGE=/boot/vmlinuz-4.1.2 root=UUID=52f5d786-37ed-4606-afee-522f43cfc1fc ro netconsole=33333@192.168.1.82/eth0,9999@192.168.1.61/00:06:5b:6a:a5:74 panic_timeout=120 quiet splash nouveau.pstate=1 vt.handoff=7
[    0.000000] e820: BIOS-provided physical RAM map:
[    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009d7ff] usable
[    0.000000] BIOS-e820: [mem 0x000000000009d800-0x000000000009ffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000000e0000-0x00000000000fffff] reserved
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x000000001fffffff] usable
[    0.000000] BIOS-e820: [mem 0x0000000020000000-0x00000000201fffff] reserved
[    0.000000] BIOS-e820: [mem 0x0000000020200000-0x0000000040003fff] usable
[    0.000000] BIOS-e820: [mem 0x0000000040004000-0x0000000040004fff] reserved
[    0.000000] BIOS-e820: [mem 0x0000000040005000-0x00000000a8155fff] usable
[    0.000000] BIOS-e820: [mem 0x00000000a8156000-0x00000000a8357fff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000a8358000-0x00000000b7f7cfff] usable
[    0.000000] BIOS-e820: [mem 0x00000000b7f7d000-0x00000000baeeefff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000baeef000-0x00000000baf9efff] ACPI NVS
[    0.000000] BIOS-e820: [mem 0x00000000baf9f000-0x00000000baffefff] ACPI data
[    0.000000] BIOS-e820: [mem 0x00000000bafff000-0x00000000baffffff] usable
[    0.000000] BIOS-e820: [mem 0x00000000bb000000-0x00000000bf9fffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000f8000000-0x00000000fbffffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000fec00000-0x00000000fec00fff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000fed08000-0x00000000fed08fff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000fed10000-0x00000000fed19fff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000fed1c000-0x00000000fed1ffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000fee00000-0x00000000fee00fff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000ff980000-0x00000000ffffffff] reserved
[    0.000000] BIOS-e820: [mem 0x0000000100000000-0x000000013f5fffff] usable
[    0.000000] NX (Execute Disable) protection: active
[    0.000000] SMBIOS 2.7 present.
[    0.000000] DMI: Dell Inc.          Inspiron 7720/04M3YM, BIOS A07 08/16/2012
[    0.000000] e820: update [mem 0x00000000-0x00000fff] usable ==> reserved
[    0.000000] e820: remove [mem 0x000a0000-0x000fffff] usable
[    0.000000] e820: last_pfn = 0x13f600 max_arch_pfn = 0x400000000
[    0.000000] MTRR default type: uncachable
[    0.000000] MTRR fixed ranges enabled:
[    0.000000]   00000-9FFFF write-back
[    0.000000]   A0000-BFFFF uncachable
[    0.000000]   C0000-FFFFF write-protect
[    0.000000] MTRR variable ranges enabled:
[    0.000000]   0 base 0FF800000 mask FFF800000 write-protect
[    0.000000]   1 base 000000000 mask F80000000 write-back
[    0.000000]   2 base 080000000 mask FC0000000 write-back
[    0.000000]   3 base 0BC000000 mask FFC000000 uncachable
[    0.000000]   4 base 0BB000000 mask FFF000000 uncachable
[    0.000000]   5 base 100000000 mask FC0000000 write-back
[    0.000000]   6 base 13F800000 mask FFF800000 uncachable
[    0.000000]   7 base 13F600000 mask FFFE00000 uncachable
[    0.000000]   8 disabled
[    0.000000]   9 disabled
[    0.000000] PAT configuration [0-7]: WB  WC  UC- UC  WB  WC  UC- UC  
[    0.000000] e820: last_pfn = 0xbb000 max_arch_pfn = 0x400000000
[    0.000000] found SMP MP-table at [mem 0x000f0100-0x000f010f] mapped at [ffff8800000f0100]
[    0.000000] Scanning 1 areas for low memory corruption
[    0.000000] Base memory trampoline at [ffff880000097000] 97000 size 24576
[    0.000000] init_memory_mapping: [mem 0x00000000-0x000fffff]
[    0.000000]  [mem 0x00000000-0x000fffff] page 4k
[    0.000000] BRK [0x02e16000, 0x02e16fff] PGTABLE
[    0.000000] BRK [0x02e17000, 0x02e17fff] PGTABLE
[    0.000000] BRK [0x02e18000, 0x02e18fff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x13f400000-0x13f5fffff]
[    0.000000]  [mem 0x13f400000-0x13f5fffff] page 2M
[    0.000000] BRK [0x02e19000, 0x02e19fff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x120000000-0x13f3fffff]
[    0.000000]  [mem 0x120000000-0x13f3fffff] page 2M
[    0.000000] init_memory_mapping: [mem 0x100000000-0x11fffffff]
[    0.000000]  [mem 0x100000000-0x11fffffff] page 2M
[    0.000000] init_memory_mapping: [mem 0x00100000-0x1fffffff]
[    0.000000]  [mem 0x00100000-0x001fffff] page 4k
[    0.000000]  [mem 0x00200000-0x1fffffff] page 2M
[    0.000000] init_memory_mapping: [mem 0x20200000-0x40003fff]
[    0.000000]  [mem 0x20200000-0x3fffffff] page 2M
[    0.000000]  [mem 0x40000000-0x40003fff] page 4k
[    0.000000] BRK [0x02e1a000, 0x02e1afff] PGTABLE
[    0.000000] BRK [0x02e1b000, 0x02e1bfff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x40005000-0xa8155fff]
[    0.000000]  [mem 0x40005000-0x401fffff] page 4k
[    0.000000]  [mem 0x40200000-0xa7ffffff] page 2M
[    0.000000]  [mem 0xa8000000-0xa8155fff] page 4k
[    0.000000] init_memory_mapping: [mem 0xa8358000-0xb7f7cfff]
[    0.000000]  [mem 0xa8358000-0xa83fffff] page 4k
[    0.000000]  [mem 0xa8400000-0xb7dfffff] page 2M
[    0.000000]  [mem 0xb7e00000-0xb7f7cfff] page 4k
[    0.000000] init_memory_mapping: [mem 0xbafff000-0xbaffffff]
[    0.000000]  [mem 0xbafff000-0xbaffffff] page 4k
[    0.000000] RAMDISK: [mem 0x3193c000-0x34c95fff]
[    0.000000] ACPI: Early table checksum verification disabled
[    0.000000] ACPI: RSDP 0x00000000000F0120 000024 (v02 DELL  )
[    0.000000] ACPI: XSDT 0x00000000BAFFE170 00009C (v01 DELL   QA09     00000002 LOHR 00000002)
[    0.000000] ACPI: FACP 0x00000000BAFE4000 00010C (v05 DELL   QA09     00000002 LOHR 00000002)
[    0.000000] ACPI: DSDT 0x00000000BAFF2000 00A6E5 (v02 DELL   IVB-CPT  00000000 INTL 20061109)
[    0.000000] ACPI: FACS 0x00000000BAF7C000 000040
[    0.000000] ACPI: SSDT 0x00000000BAFFD000 000166 (v01 DELL   PtidDevc 00001000 INTL 20061109)
[    0.000000] ACPI: ASF! 0x00000000BAFF1000 0000A5 (v32 DELL   QA09     00000002 LOHR 00000002)
[    0.000000] ACPI: HPET 0x00000000BAFEE000 000038 (v01 DELL   QA09     00000002 LOHR 00000002)
[    0.000000] ACPI: APIC 0x00000000BAFED000 000098 (v01 DELL   QA09     00000002 LOHR 00000002)
[    0.000000] ACPI: MCFG 0x00000000BAFEC000 00003C (v01 DELL   QA09     00000002 LOHR 00000002)
[    0.000000] ACPI: FPDT 0x00000000BAFEB000 000064 (v01 DELL   QA09     00000002 LOHR 00000002)
[    0.000000] ACPI: SSDT 0x00000000BAFEA000 000968 (v01 PmRef  Cpu0Ist  00003000 INTL 20061109)
[    0.000000] ACPI: SSDT 0x00000000BAFE9000 000A92 (v01 PmRef  CpuPm    00003000 INTL 20061109)
[    0.000000] ACPI: UEFI 0x00000000BAFE8000 00003E (v01 DELL   QA09     00000002 LOHR 00000002)
[    0.000000] ACPI: UEFI 0x00000000BAFE7000 000042 (v01 PTL    COMBUF   00000001 PTL  00000001)
[    0.000000] ACPI: POAT 0x00000000BAFE6000 000055 (v03 DELL   QA09     00000002 LOHR 00000002)
[    0.000000] ACPI: SSDT 0x00000000BAFE3000 000EB6 (v01 NvORef NvOptTbl 00001000 INTL 20061109)
[    0.000000] ACPI: UEFI 0x00000000BAFE2000 00027E (v01 DELL   QA09     00000002 LOHR 00000002)
[    0.000000] ACPI: DBG2 0x00000000BAFE0000 000070 (v00 DELL   QA09     00000002 LOHR 00000002)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] No NUMA configuration found
[    0.000000] Faking a node at [mem 0x0000000000000000-0x000000013f5fffff]
[    0.000000] NODE_DATA(0) allocated [mem 0x13f5f6000-0x13f5fafff]
[    0.000000]  [ffffea0000000000-ffffea0004ffffff] PMD -> [ffff88013ac00000-ffff88013ebfffff] on node 0
[    0.000000] Zone ranges:
[    0.000000]   DMA      [mem 0x0000000000001000-0x0000000000ffffff]
[    0.000000]   DMA32    [mem 0x0000000001000000-0x00000000ffffffff]
[    0.000000]   Normal   [mem 0x0000000100000000-0x000000013f5fffff]
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x0000000000001000-0x000000000009cfff]
[    0.000000]   node   0: [mem 0x0000000000100000-0x000000001fffffff]
[    0.000000]   node   0: [mem 0x0000000020200000-0x0000000040003fff]
[    0.000000]   node   0: [mem 0x0000000040005000-0x00000000a8155fff]
[    0.000000]   node   0: [mem 0x00000000a8358000-0x00000000b7f7cfff]
[    0.000000]   node   0: [mem 0x00000000bafff000-0x00000000baffffff]
[    0.000000]   node   0: [mem 0x0000000100000000-0x000000013f5fffff]
[    0.000000] Initmem setup node 0 [mem 0x0000000000001000-0x000000013f5fffff]
[    0.000000] On node 0 totalpages: 1011991
[    0.000000]   DMA zone: 64 pages used for memmap
[    0.000000]   DMA zone: 21 pages reserved
[    0.000000]   DMA zone: 3996 pages, LIFO batch:0
[    0.000000]   DMA32 zone: 11694 pages used for memmap
[    0.000000]   DMA32 zone: 748411 pages, LIFO batch:31
[    0.000000]   Normal zone: 4056 pages used for memmap
[    0.000000]   Normal zone: 259584 pages, LIFO batch:31
[    0.000000] Reserving Intel graphics stolen memory at 0xbba00000-0xbf9fffff
[    0.000000] ACPI: PM-Timer IO Port: 0x408
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x00] high edge lint[0x1])
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0x01] high edge lint[0x1])
[    0.000000] IOAPIC[0]: apic_id 2, version 32, address 0xfec00000, GSI 0-23
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
[    0.000000] ACPI: IRQ0 used by override.
[    0.000000] ACPI: IRQ9 used by override.
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] ACPI: HPET id: 0x8086a301 base: 0xfed00000
[    0.000000] smpboot: Allowing 8 CPUs, 4 hotplug CPUs
[    0.000000] PM: Registered nosave memory: [mem 0x00000000-0x00000fff]
[    0.000000] PM: Registered nosave memory: [mem 0x0009d000-0x0009dfff]
[    0.000000] PM: Registered nosave memory: [mem 0x0009e000-0x0009ffff]
[    0.000000] PM: Registered nosave memory: [mem 0x000a0000-0x000dffff]
[    0.000000] PM: Registered nosave memory: [mem 0x000e0000-0x000fffff]
[    0.000000] PM: Registered nosave memory: [mem 0x20000000-0x201fffff]
[    0.000000] PM: Registered nosave memory: [mem 0x40004000-0x40004fff]
[    0.000000] PM: Registered nosave memory: [mem 0xa8156000-0xa8357fff]
[    0.000000] PM: Registered nosave memory: [mem 0xb7f7d000-0xbaeeefff]
[    0.000000] PM: Registered nosave memory: [mem 0xbaeef000-0xbaf9efff]
[    0.000000] PM: Registered nosave memory: [mem 0xbaf9f000-0xbaffefff]
[    0.000000] PM: Registered nosave memory: [mem 0xbb000000-0xbf9fffff]
[    0.000000] PM: Registered nosave memory: [mem 0xbfa00000-0xf7ffffff]
[    0.000000] PM: Registered nosave memory: [mem 0xf8000000-0xfbffffff]
[    0.000000] PM: Registered nosave memory: [mem 0xfc000000-0xfebfffff]
[    0.000000] PM: Registered nosave memory: [mem 0xfec00000-0xfec00fff]
[    0.000000] PM: Registered nosave memory: [mem 0xfec01000-0xfed07fff]
[    0.000000] PM: Registered nosave memory: [mem 0xfed08000-0xfed08fff]
[    0.000000] PM: Registered nosave memory: [mem 0xfed09000-0xfed0ffff]
[    0.000000] PM: Registered nosave memory: [mem 0xfed10000-0xfed19fff]
[    0.000000] PM: Registered nosave memory: [mem 0xfed1a000-0xfed1bfff]
[    0.000000] PM: Registered nosave memory: [mem 0xfed1c000-0xfed1ffff]
[    0.000000] PM: Registered nosave memory: [mem 0xfed20000-0xfedfffff]
[    0.000000] PM: Registered nosave memory: [mem 0xfee00000-0xfee00fff]
[    0.000000] PM: Registered nosave memory: [mem 0xfee01000-0xff97ffff]
[    0.000000] PM: Registered nosave memory: [mem 0xff980000-0xffffffff]
[    0.000000] e820: [mem 0xbfa00000-0xf7ffffff] available for PCI devices
[    0.000000] clocksource refined-jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 7645519600211568 ns
[    0.000000] setup_percpu: NR_CPUS:8 nr_cpumask_bits:8 nr_cpu_ids:8 nr_node_ids:1
[    0.000000] PERCPU: Embedded 34 pages/cpu @ffff88013f200000 s98824 r8192 d32248 u262144
[    0.000000] pcpu-alloc: s98824 r8192 d32248 u262144 alloc=1*2097152
[    0.000000] pcpu-alloc: [0] 0 1 2 3 4 5 6 7 
[    0.000000] Built 1 zonelists in Node order, mobility grouping on.  Total pages: 996156
[    0.000000] Policy zone: Normal
[    0.000000] Kernel command line: BOOT_IMAGE=/boot/vmlinuz-4.1.2 root=UUID=52f5d786-37ed-4606-afee-522f43cfc1fc ro netconsole=33333@192.168.1.82/eth0,9999@192.168.1.61/00:06:5b:6a:a5:74 panic_timeout=120 quiet splash nouveau.pstate=1 vt.handoff=7
[    0.000000] PID hash table entries: 4096 (order: 3, 32768 bytes)
[    0.000000] xsave: enabled xstate_bv 0x7, cntxt size 0x340 using standard form
[    0.000000] Memory: 3831424K/4047964K available (7833K kernel code, 1268K rwdata, 3104K rodata, 1264K init, 15948K bss, 216540K reserved, 0K cma-reserved)
[    0.000000] SLUB: HWalign=64, Order=0-3, MinObjects=0, CPUs=8, Nodes=1
[    0.000000] Running RCU self tests
[    0.000000] Preemptible hierarchical RCU implementation.
[    0.000000] 	RCU dyntick-idle grace-period acceleration is enabled.
[    0.000000] 	RCU lockdep checking is enabled.
[    0.000000] NR_IRQS:4352 nr_irqs:488 16
[    0.000000] Console: colour dummy device 80x25
[    0.000000] console [tty0] enabled
[    0.000000] Lock dependency validator: Copyright (c) 2006 Red Hat, Inc., Ingo Molnar
[    0.000000] ... MAX_LOCKDEP_SUBCLASSES:  8
[    0.000000] ... MAX_LOCK_DEPTH:          48
[    0.000000] ... MAX_LOCKDEP_KEYS:        8191
[    0.000000] ... CLASSHASH_SIZE:          4096
[    0.000000] ... MAX_LOCKDEP_ENTRIES:     32768
[    0.000000] ... MAX_LOCKDEP_CHAINS:      65536
[    0.000000] ... CHAINHASH_SIZE:          32768
[    0.000000]  memory used by lock dependency info: 8159 kB
[    0.000000]  per task-struct memory footprint: 1920 bytes
[    0.000000] clocksource hpet: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 133484882848 ns
[    0.000000] hpet clockevent registered
[    0.000000] tsc: Fast TSC calibration using PIT
[    0.000000] tsc: Detected 2494.329 MHz processor
[    0.000071] Calibrating delay loop (skipped), value calculated using timer frequency.. 4988.65 BogoMIPS (lpj=9977316)
[    0.000074] pid_max: default: 32768 minimum: 301
[    0.000081] ACPI: Core revision 20150410
[    0.015596] ACPI: All ACPI Tables successfully acquired
[    0.015910] Security Framework initialized
[    0.015917] AppArmor: AppArmor initialized
[    0.016571] Dentry cache hash table entries: 524288 (order: 10, 4194304 bytes)
[    0.017747] Inode-cache hash table entries: 262144 (order: 9, 2097152 bytes)
[    0.018198] Mount-cache hash table entries: 8192 (order: 4, 65536 bytes)
[    0.018210] Mountpoint-cache hash table entries: 8192 (order: 4, 65536 bytes)
[    0.019215] Initializing cgroup subsys blkio
[    0.019221] Initializing cgroup subsys devices
[    0.019246] Initializing cgroup subsys freezer
[    0.019272] Initializing cgroup subsys perf_event
[    0.019303] CPU: Physical Processor ID: 0
[    0.019304] CPU: Processor Core ID: 0
[    0.019308] ENERGY_PERF_BIAS: Set to 'normal', was 'performance'
[    0.019309] ENERGY_PERF_BIAS: View and update with x86_energy_perf_policy(8)
[    0.019667] mce: CPU supports 7 MCE banks
[    0.019675] CPU0: Thermal monitoring handled by SMI
[    0.019689] process: using mwait in idle threads
[    0.019692] Last level iTLB entries: 4KB 512, 2MB 8, 4MB 8
[    0.019694] Last level dTLB entries: 4KB 512, 2MB 32, 4MB 32, 1GB 0
[    0.019956] Freeing SMP alternatives memory: 24K (ffffffff81e7b000 - ffffffff81e81000)
[    0.019962] ftrace: allocating 26871 entries in 105 pages
[    0.033190] x2apic: IRQ remapping doesn't support X2APIC mode
[    0.033768] ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
[    0.073504] TSC deadline timer enabled
[    0.073508] smpboot: CPU0: Intel(R) Core(TM) i5-3210M CPU @ 2.50GHz (fam: 06, model: 3a, stepping: 09)
[    0.073543] Performance Events: PEBS fmt1+, 16-deep LBR, IvyBridge events, full-width counters, Intel PMU driver.
[    0.073570] ... version:                3
[    0.073571] ... bit width:              48
[    0.073572] ... generic registers:      4
[    0.073573] ... value mask:             0000ffffffffffff
[    0.073574] ... max period:             0000ffffffffffff
[    0.073575] ... fixed-purpose events:   3
[    0.073576] ... event mask:             000000070000000f
[    0.105981] x86: Booting SMP configuration:
[    0.105984] .... node  #0, CPUs:      #1
[    0.117351] CPU1: Thermal monitoring handled by SMI
[    0.119746] NMI watchdog: enabled on all CPUs, permanently consumes one hw-PMU counter.
[    0.127658]  #2
[    0.139006] CPU2: Thermal monitoring handled by SMI
[    0.149307]  #3
[    0.160650] CPU3: Thermal monitoring handled by SMI
[    0.162820] x86: Booted up 1 node, 4 CPUs
[    0.162824] smpboot: Total of 4 processors activated (19954.63 BogoMIPS)
[    0.166474] devtmpfs: initialized
[    0.166940] evm: security.capability
[    0.167082] PM: Registering ACPI NVS region [mem 0xbaeef000-0xbaf9efff] (720896 bytes)
[    0.167322] clocksource jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 7645041785100000 ns
[    0.168236] RTC time: 16:27:49, date: 07/11/15
[    0.168579] NET: Registered protocol family 16
[    0.178884] cpuidle: using governor ladder
[    0.189294] cpuidle: using governor menu
[    0.189374] ACPI: bus type PCI registered
[    0.189571] PCI: MMCONFIG for domain 0000 [bus 00-3f] at [mem 0xf8000000-0xfbffffff] (base 0xf8000000)
[    0.189574] PCI: MMCONFIG at [mem 0xf8000000-0xfbffffff] reserved in E820
[    0.189646] PCI: Using configuration type 1 for base access
[    0.189976] perf_event_intel: PMU erratum BJ122, BV98, HSD29 worked around, HT is on
[    0.189981] mtrr: your CPUs had inconsistent variable MTRR settings
[    0.189982] mtrr: probably your BIOS does not setup all CPUs.
[    0.189982] mtrr: corrected configuration.
[    0.203823] ACPI: Added _OSI(Module Device)
[    0.203826] ACPI: Added _OSI(Processor Device)
[    0.203828] ACPI: Added _OSI(3.0 _SCP Extensions)
[    0.203829] ACPI: Added _OSI(Processor Aggregator Device)
[    0.214958] ACPI: Executed 2 blocks of module-level executable AML code
[    0.221405] [Firmware Bug]: ACPI: BIOS _OSI(Linux) query ignored
[    0.222207] ACPI: Dynamic OEM Table Load:
[    0.222225] ACPI: SSDT 0xFFFF880139E3E000 00083B (v01 PmRef  Cpu0Cst  00003001 INTL 20061109)
[    0.224100] ACPI: Dynamic OEM Table Load:
[    0.224116] ACPI: SSDT 0xFFFF880139F12000 000303 (v01 PmRef  ApIst    00003000 INTL 20061109)
[    0.225867] ACPI: Dynamic OEM Table Load:
[    0.225882] ACPI: SSDT 0xFFFF880139D65200 000119 (v01 PmRef  ApCst    00003000 INTL 20061109)
[    0.228528] ACPI : EC: EC started
[    0.230383] ACPI: Interpreter enabled
[    0.230394] ACPI Exception: AE_NOT_FOUND, While evaluating Sleep State [\_S1_] (20150410/hwxface-580)
[    0.230400] ACPI Exception: AE_NOT_FOUND, While evaluating Sleep State [\_S2_] (20150410/hwxface-580)
[    0.230444] ACPI: (supports S0 S3 S4 S5)
[    0.230446] ACPI: Using IOAPIC for interrupt routing
[    0.230505] PCI: Using host bridge windows from ACPI; if necessary, use "pci=nocrs" and report a bug
[    0.246879] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-3e])
[    0.246886] acpi PNP0A08:00: _OSC: OS supports [ExtendedConfig ASPM ClockPM Segments MSI]
[    0.247237] \_SB_.PCI0:_OSC invalid UUID
[    0.247238] _OSC request data:1 1f 0 
[    0.247244] acpi PNP0A08:00: _OSC failed (AE_ERROR); disabling ASPM
[    0.248032] PCI host bridge to bus 0000:00
[    0.248036] pci_bus 0000:00: root bus resource [bus 00-3e]
[    0.248038] pci_bus 0000:00: root bus resource [io  0x0000-0x0cf7 window]
[    0.248040] pci_bus 0000:00: root bus resource [io  0x0d00-0xffff window]
[    0.248042] pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000bffff window]
[    0.248044] pci_bus 0000:00: root bus resource [mem 0xbfa00000-0xfeafffff window]
[    0.248094] pci 0000:00:00.0: [8086:0154] type 00 class 0x060000
[    0.248361] pci 0000:00:01.0: [8086:0151] type 01 class 0x060400
[    0.248415] pci 0000:00:01.0: PME# supported from D0 D3hot D3cold
[    0.248618] pci 0000:00:01.0: System wakeup disabled by ACPI
[    0.248737] pci 0000:00:02.0: [8086:0166] type 00 class 0x030000
[    0.248751] pci 0000:00:02.0: reg 0x10: [mem 0xf1000000-0xf13fffff 64bit]
[    0.248761] pci 0000:00:02.0: reg 0x18: [mem 0xe0000000-0xefffffff 64bit pref]
[    0.248768] pci 0000:00:02.0: reg 0x20: [io  0x4000-0x403f]
[    0.249130] pci 0000:00:14.0: [8086:1e31] type 00 class 0x0c0330
[    0.249168] pci 0000:00:14.0: reg 0x10: [mem 0xf1600000-0xf160ffff 64bit]
[    0.249295] pci 0000:00:14.0: PME# supported from D3hot D3cold
[    0.249374] pci 0000:00:14.0: System wakeup disabled by ACPI
[    0.249485] pci 0000:00:16.0: [8086:1e3a] type 00 class 0x078000
[    0.249521] pci 0000:00:16.0: reg 0x10: [mem 0xf1615000-0xf161500f 64bit]
[    0.249647] pci 0000:00:16.0: PME# supported from D0 D3hot D3cold
[    0.249848] pci 0000:00:1a.0: [8086:1e2d] type 00 class 0x0c0320
[    0.249879] pci 0000:00:1a.0: reg 0x10: [mem 0xf161a000-0xf161a3ff]
[    0.250026] pci 0000:00:1a.0: PME# supported from D0 D3hot D3cold
[    0.250144] pci 0000:00:1a.0: System wakeup disabled by ACPI
[    0.250260] pci 0000:00:1b.0: [8086:1e20] type 00 class 0x040300
[    0.250290] pci 0000:00:1b.0: reg 0x10: [mem 0xf1610000-0xf1613fff 64bit]
[    0.250430] pci 0000:00:1b.0: PME# supported from D0 D3hot D3cold
[    0.250615] pci 0000:00:1c.0: [8086:1e10] type 01 class 0x060400
[    0.250753] pci 0000:00:1c.0: PME# supported from D0 D3hot D3cold
[    0.250837] pci 0000:00:1c.0: System wakeup disabled by ACPI
[    0.250956] pci 0000:00:1c.4: [8086:1e18] type 01 class 0x060400
[    0.251096] pci 0000:00:1c.4: PME# supported from D0 D3hot D3cold
[    0.251183] pci 0000:00:1c.4: System wakeup disabled by ACPI
[    0.251301] pci 0000:00:1d.0: [8086:1e26] type 00 class 0x0c0320
[    0.251332] pci 0000:00:1d.0: reg 0x10: [mem 0xf1619000-0xf16193ff]
[    0.251476] pci 0000:00:1d.0: PME# supported from D0 D3hot D3cold
[    0.251579] pci 0000:00:1d.0: System wakeup disabled by ACPI
[    0.251690] pci 0000:00:1f.0: [8086:1e57] type 00 class 0x060100
[    0.252001] pci 0000:00:1f.2: [8086:1e03] type 00 class 0x010601
[    0.252034] pci 0000:00:1f.2: reg 0x10: [io  0x4098-0x409f]
[    0.252050] pci 0000:00:1f.2: reg 0x14: [io  0x40bc-0x40bf]
[    0.252065] pci 0000:00:1f.2: reg 0x18: [io  0x4090-0x4097]
[    0.252081] pci 0000:00:1f.2: reg 0x1c: [io  0x40b8-0x40bb]
[    0.252095] pci 0000:00:1f.2: reg 0x20: [io  0x4060-0x407f]
[    0.252111] pci 0000:00:1f.2: reg 0x24: [mem 0xf1618000-0xf16187ff]
[    0.252192] pci 0000:00:1f.2: PME# supported from D3hot
[    0.252369] pci 0000:00:1f.3: [8086:1e22] type 00 class 0x0c0500
[    0.252398] pci 0000:00:1f.3: reg 0x10: [mem 0xf1614000-0xf16140ff 64bit]
[    0.252443] pci 0000:00:1f.3: reg 0x20: [io  0xefa0-0xefbf]
[    0.252716] pci 0000:01:00.0: [10de:0fd1] type 00 class 0x030000
[    0.252733] pci 0000:01:00.0: reg 0x10: [mem 0xf0000000-0xf0ffffff]
[    0.252749] pci 0000:01:00.0: reg 0x14: [mem 0xc0000000-0xcfffffff 64bit pref]
[    0.252765] pci 0000:01:00.0: reg 0x1c: [mem 0xd0000000-0xd1ffffff 64bit pref]
[    0.252776] pci 0000:01:00.0: reg 0x24: [io  0x3000-0x307f]
[    0.252786] pci 0000:01:00.0: reg 0x30: [mem 0xfff80000-0xffffffff pref]
[    0.252927] pci 0000:01:00.0: System wakeup disabled by ACPI
[    0.261765] pci 0000:00:01.0: PCI bridge to [bus 01]
[    0.261769] pci 0000:00:01.0:   bridge window [io  0x3000-0x3fff]
[    0.261772] pci 0000:00:01.0:   bridge window [mem 0xf0000000-0xf0ffffff]
[    0.261776] pci 0000:00:01.0:   bridge window [mem 0xc0000000-0xd1ffffff 64bit pref]
[    0.261945] pci 0000:02:00.0: [8086:0887] type 00 class 0x028000
[    0.262017] pci 0000:02:00.0: reg 0x10: [mem 0xf1500000-0xf1501fff 64bit]
[    0.262317] pci 0000:02:00.0: PME# supported from D0 D3hot D3cold
[    0.262390] pci 0000:02:00.0: System wakeup disabled by ACPI
[    0.269813] pci 0000:00:1c.0: PCI bridge to [bus 02]
[    0.269823] pci 0000:00:1c.0:   bridge window [mem 0xf1500000-0xf15fffff]
[    0.269960] pci 0000:03:00.0: [10ec:8136] type 00 class 0x020000
[    0.269992] pci 0000:03:00.0: reg 0x10: [io  0x2000-0x20ff]
[    0.270040] pci 0000:03:00.0: reg 0x18: [mem 0xf1404000-0xf1404fff 64bit pref]
[    0.270070] pci 0000:03:00.0: reg 0x20: [mem 0xf1400000-0xf1403fff 64bit pref]
[    0.270204] pci 0000:03:00.0: supports D1 D2
[    0.270206] pci 0000:03:00.0: PME# supported from D0 D1 D2 D3hot D3cold
[    0.270264] pci 0000:03:00.0: System wakeup disabled by ACPI
[    0.277805] pci 0000:00:1c.4: PCI bridge to [bus 03]
[    0.277811] pci 0000:00:1c.4:   bridge window [io  0x2000-0x2fff]
[    0.277825] pci 0000:00:1c.4:   bridge window [mem 0xf1400000-0xf14fffff 64bit pref]
[    0.278983] ACPI: PCI Interrupt Link [LNKA] (IRQs 1 3 4 5 6 10 *11 12 14 15)
[    0.279094] ACPI: PCI Interrupt Link [LNKB] (IRQs 1 3 4 5 6 10 11 12 14 15) *0, disabled.
[    0.279216] ACPI: PCI Interrupt Link [LNKC] (IRQs 1 3 4 5 6 *10 11 12 14 15)
[    0.279325] ACPI: PCI Interrupt Link [LNKD] (IRQs 1 3 4 5 6 10 *11 12 14 15)
[    0.279432] ACPI: PCI Interrupt Link [LNKE] (IRQs 1 3 4 5 6 10 11 12 14 15) *0, disabled.
[    0.279540] ACPI: PCI Interrupt Link [LNKF] (IRQs 1 3 4 5 6 10 11 12 14 15) *0, disabled.
[    0.279647] ACPI: PCI Interrupt Link [LNKG] (IRQs 1 3 4 5 6 10 11 12 14 15) *7
[    0.279755] ACPI: PCI Interrupt Link [LNKH] (IRQs 1 3 4 5 6 *10 11 12 14 15)
[    0.280262] ACPI: Enabled 5 GPEs in block 00 to 3F
[    0.280529] ACPI : EC: GPE = 0x17, I/O: command/status = 0x66, data = 0x62
[    0.281177] vgaarb: setting as boot device: PCI:0000:00:02.0
[    0.281180] vgaarb: device added: PCI:0000:00:02.0,decodes=io+mem,owns=io+mem,locks=none
[    0.281188] vgaarb: device added: PCI:0000:01:00.0,decodes=io+mem,owns=none,locks=none
[    0.281190] vgaarb: loaded
[    0.281192] vgaarb: bridge control possible 0000:01:00.0
[    0.281193] vgaarb: no bridge control possible 0000:00:02.0
[    0.281595] SCSI subsystem initialized
[    0.281713] libata version 3.00 loaded.
[    0.281783] ACPI: bus type USB registered
[    0.281827] usbcore: registered new interface driver usbfs
[    0.281849] usbcore: registered new interface driver hub
[    0.281906] usbcore: registered new device driver usb
[    0.282217] PCI: Using ACPI for IRQ routing
[    0.284113] PCI: pci_cache_line_size set to 64 bytes
[    0.284234] e820: reserve RAM buffer [mem 0x0009d800-0x0009ffff]
[    0.284242] e820: reserve RAM buffer [mem 0x40004000-0x43ffffff]
[    0.284244] e820: reserve RAM buffer [mem 0xa8156000-0xabffffff]
[    0.284246] e820: reserve RAM buffer [mem 0xb7f7d000-0xb7ffffff]
[    0.284248] e820: reserve RAM buffer [mem 0xbb000000-0xbbffffff]
[    0.284250] e820: reserve RAM buffer [mem 0x13f600000-0x13fffffff]
[    0.284849] NetLabel: Initializing
[    0.284850] NetLabel:  domain hash size = 128
[    0.284851] NetLabel:  protocols = UNLABELED CIPSOv4
[    0.284901] NetLabel:  unlabeled traffic allowed by default
[    0.285069] hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0, 0, 0, 0, 0, 0
[    0.285075] hpet0: 8 comparators, 64-bit 14.318180 MHz counter
[    0.287154] Switched to clocksource hpet
[    0.315411] AppArmor: AppArmor Filesystem Enabled
[    0.315636] pnp: PnP ACPI init
[    0.315890] system 00:00: [io  0x0680-0x069f] has been reserved
[    0.315894] system 00:00: [io  0x1000-0x1003] has been reserved
[    0.315896] system 00:00: [io  0x1004-0x1013] has been reserved
[    0.315898] system 00:00: [io  0xffff] has been reserved
[    0.315902] system 00:00: [io  0x0400-0x0453] could not be reserved
[    0.315904] system 00:00: [io  0x0458-0x047f] has been reserved
[    0.315906] system 00:00: [io  0x0500-0x057f] has been reserved
[    0.315908] system 00:00: [io  0x164e-0x164f] has been reserved
[    0.315942] system 00:00: Plug and Play ACPI device, IDs PNP0c02 (active)
[    0.316020] pnp 00:01: Plug and Play ACPI device, IDs PNP0b00 (active)
[    0.316135] system 00:02: [io  0x0454-0x0457] has been reserved
[    0.316141] system 00:02: Plug and Play ACPI device, IDs INT3f0d PNP0c02 (active)
[    0.316222] pnp 00:03: Plug and Play ACPI device, IDs PNP0303 (active)
[    0.316295] pnp 00:04: Plug and Play ACPI device, IDs DLL0578 PNP0f13 (active)
[    0.316485] pnp 00:05: disabling [mem 0xfffff000-0xffffffff] because it overlaps 0000:01:00.0 BAR 6 [mem 0xfff80000-0xffffffff pref]
[    0.316544] system 00:05: [mem 0xfed1c000-0xfed1ffff] has been reserved
[    0.316546] system 00:05: [mem 0xfed10000-0xfed17fff] has been reserved
[    0.316549] system 00:05: [mem 0xfed18000-0xfed18fff] has been reserved
[    0.316551] system 00:05: [mem 0xfed19000-0xfed19fff] has been reserved
[    0.316553] system 00:05: [mem 0xf8000000-0xfbffffff] has been reserved
[    0.316556] system 00:05: [mem 0xfed20000-0xfed3ffff] has been reserved
[    0.316558] system 00:05: [mem 0xfed90000-0xfed93fff] has been reserved
[    0.316560] system 00:05: [mem 0xfed45000-0xfed8ffff] has been reserved
[    0.316563] system 00:05: [mem 0xff000000-0xffffffff] could not be reserved
[    0.316566] system 00:05: [mem 0xfee00000-0xfeefffff] could not be reserved
[    0.316571] system 00:05: Plug and Play ACPI device, IDs PNP0c02 (active)
[    0.317076] pnp: PnP ACPI: found 6 devices
[    0.326781] clocksource acpi_pm: mask: 0xffffff max_cycles: 0xffffff, max_idle_ns: 2085701024 ns
[    0.326789] pci 0000:01:00.0: can't claim BAR 6 [mem 0xfff80000-0xffffffff pref]: no compatible bridge window
[    0.326830] pci 0000:01:00.0: BAR 6: no space for [mem size 0x00080000 pref]
[    0.326843] pci 0000:01:00.0: BAR 6: failed to assign [mem size 0x00080000 pref]
[    0.326845] pci 0000:00:01.0: PCI bridge to [bus 01]
[    0.326848] pci 0000:00:01.0:   bridge window [io  0x3000-0x3fff]
[    0.326852] pci 0000:00:01.0:   bridge window [mem 0xf0000000-0xf0ffffff]
[    0.326855] pci 0000:00:01.0:   bridge window [mem 0xc0000000-0xd1ffffff 64bit pref]
[    0.326860] pci 0000:00:1c.0: PCI bridge to [bus 02]
[    0.326868] pci 0000:00:1c.0:   bridge window [mem 0xf1500000-0xf15fffff]
[    0.326882] pci 0000:00:1c.4: PCI bridge to [bus 03]
[    0.326886] pci 0000:00:1c.4:   bridge window [io  0x2000-0x2fff]
[    0.326897] pci 0000:00:1c.4:   bridge window [mem 0xf1400000-0xf14fffff 64bit pref]
[    0.326907] pci_bus 0000:00: resource 4 [io  0x0000-0x0cf7 window]
[    0.326909] pci_bus 0000:00: resource 5 [io  0x0d00-0xffff window]
[    0.326910] pci_bus 0000:00: resource 6 [mem 0x000a0000-0x000bffff window]
[    0.326912] pci_bus 0000:00: resource 7 [mem 0xbfa00000-0xfeafffff window]
[    0.326914] pci_bus 0000:01: resource 0 [io  0x3000-0x3fff]
[    0.326916] pci_bus 0000:01: resource 1 [mem 0xf0000000-0xf0ffffff]
[    0.326917] pci_bus 0000:01: resource 2 [mem 0xc0000000-0xd1ffffff 64bit pref]
[    0.326919] pci_bus 0000:02: resource 1 [mem 0xf1500000-0xf15fffff]
[    0.326921] pci_bus 0000:03: resource 0 [io  0x2000-0x2fff]
[    0.326923] pci_bus 0000:03: resource 2 [mem 0xf1400000-0xf14fffff 64bit pref]
[    0.326987] NET: Registered protocol family 2
[    0.327497] TCP established hash table entries: 32768 (order: 6, 262144 bytes)
[    0.327924] TCP bind hash table entries: 32768 (order: 9, 2097152 bytes)
[    0.329629] TCP: Hash tables configured (established 32768 bind 32768)
[    0.329742] UDP hash table entries: 2048 (order: 6, 327680 bytes)
[    0.330015] UDP-Lite hash table entries: 2048 (order: 6, 327680 bytes)
[    0.330390] NET: Registered protocol family 1
[    0.330414] pci 0000:00:02.0: Video device with shadowed ROM
[    0.331656] PCI: CLS 64 bytes, default 64
[    0.331886] Trying to unpack rootfs image as initramfs...
[    1.197507] Freeing initrd memory: 52584K (ffff88003193c000 - ffff880034c96000)
[    1.197518] PCI-DMA: Using software bounce buffering for IO (SWIOTLB)
[    1.197520] software IO TLB [mem 0xb3f7d000-0xb7f7d000] (64MB) mapped at [ffff8800b3f7d000-ffff8800b7f7cfff]
[    1.198138] RAPL PMU detected, API unit is 2^-32 Joules, 3 fixed counters 163840 ms ovfl timer
[    1.198141] hw unit of domain pp0-core 2^-16 Joules
[    1.198142] hw unit of domain package 2^-16 Joules
[    1.198143] hw unit of domain pp1-gpu 2^-16 Joules
[    1.198427] Scanning for low memory corruption every 60 seconds
[    1.199528] futex hash table entries: 2048 (order: 6, 262144 bytes)
[    1.199679] audit: initializing netlink subsys (disabled)
[    1.199740] audit: type=2000 audit(1436632070.188:1): initialized
[    1.200871] HugeTLB registered 2 MB page size, pre-allocated 0 pages
[    1.207121] VFS: Disk quotas dquot_6.6.0
[    1.207221] VFS: Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
[    1.209045] fuse init (API version 7.23)
[    1.210268] bounce: pool size: 64 pages
[    1.210367] Block layer SCSI generic (bsg) driver version 0.4 loaded (major 251)
[    1.210509] io scheduler noop registered
[    1.210512] io scheduler deadline registered (default)
[    1.210607] io scheduler cfq registered
[    1.211570] pci_hotplug: PCI Hot Plug PCI Core version: 0.5
[    1.211700] pciehp: PCI Express Hot Plug Controller Driver version: 0.4
[    1.211725] vesafb: mode is 1600x900x32, linelength=6400, pages=0
[    1.211726] vesafb: scrolling: redraw
[    1.211728] vesafb: Truecolor: size=8:8:8:8, shift=24:16:8:0
[    1.211747] vesafb: framebuffer at 0xe0000000, mapped to 0xffffc90001000000, using 5632k, total 5632k
[    1.304329] Console: switching to colour frame buffer device 200x56
[    1.396059] fb0: VESA VGA frame buffer device
[    1.396094] intel_idle: MWAIT substates: 0x21120
[    1.396095] intel_idle: v0.4 model 0x3A
[    1.396096] intel_idle: lapic_timer_reliable_states 0xffffffff
[    1.604847] ACPI: AC Adapter [ADP0] (on-line)
[    1.605030] input: Power Button as /devices/LNXSYSTM:00/LNXSYBUS:00/PNP0C0C:00/input/input0
[    1.605074] ACPI: Power Button [PWRB]
[    1.605172] input: Sleep Button as /devices/LNXSYSTM:00/LNXSYBUS:00/PNP0C0E:00/input/input1
[    1.605176] ACPI: Sleep Button [SLPB]
[    1.605275] input: Lid Switch as /devices/LNXSYSTM:00/LNXSYBUS:00/PNP0C0D:00/input/input2
[    1.605774] ACPI: Lid Switch [LID0]
[    1.605887] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/input/input3
[    1.605892] ACPI: Power Button [PWRF]
[    1.607143] thermal LNXTHERM:00: registered as thermal_zone0
[    1.607146] ACPI: Thermal Zone [TZ00] (68 C)
[    1.607838] thermal LNXTHERM:01: registered as thermal_zone1
[    1.607840] ACPI: Thermal Zone [TZ01] (68 C)
[    1.607945] GHES: HEST is not enabled!
[    1.608066] Serial: 8250/16550 driver, 32 ports, IRQ sharing enabled
[    1.608372] ACPI: Battery Slot [BAT0] (battery absent)
[    1.613711] Linux agpgart interface v0.103
[    1.619668] brd: module loaded
[    1.623279] loop: module loaded
[    1.631423] libphy: Fixed MDIO Bus: probed
[    1.631629] tun: Universal TUN/TAP device driver, 1.6
[    1.631630] tun: (C) 1999-2004 Max Krasnyansky <maxk@qualcomm.com>
[    1.631792] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
[    1.631799] r8169 0000:03:00.0: can't disable ASPM; OS doesn't have ASPM control
[    1.632415] r8169 0000:03:00.0 eth0: RTL8105e at 0xffffc90000662000, 5c:f9:dd:4a:45:49, XID 00c00000 IRQ 26
[    1.632519] PPP generic driver version 2.4.2
[    1.632933] xhci_hcd 0000:00:14.0: xHCI Host Controller
[    1.633129] xhci_hcd 0000:00:14.0: new USB bus registered, assigned bus number 1
[    1.633324] xhci_hcd 0000:00:14.0: hcc params 0x20007181 hci version 0x100 quirks 0x0000b930
[    1.633344] xhci_hcd 0000:00:14.0: cache line size of 64 is not supported
[    1.633817] usb usb1: New USB device found, idVendor=1d6b, idProduct=0002
[    1.633819] usb usb1: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    1.633821] usb usb1: Product: xHCI Host Controller
[    1.633823] usb usb1: Manufacturer: Linux 4.1.2 xhci-hcd
[    1.633824] usb usb1: SerialNumber: 0000:00:14.0
[    1.634625] hub 1-0:1.0: USB hub found
[    1.634681] hub 1-0:1.0: 4 ports detected
[    1.636432] xhci_hcd 0000:00:14.0: xHCI Host Controller
[    1.636441] xhci_hcd 0000:00:14.0: new USB bus registered, assigned bus number 2
[    1.636564] usb usb2: New USB device found, idVendor=1d6b, idProduct=0003
[    1.636566] usb usb2: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    1.636568] usb usb2: Product: xHCI Host Controller
[    1.636570] usb usb2: Manufacturer: Linux 4.1.2 xhci-hcd
[    1.636571] usb usb2: SerialNumber: 0000:00:14.0
[    1.636991] hub 2-0:1.0: USB hub found
[    1.637024] hub 2-0:1.0: 4 ports detected
[    1.638119] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
[    1.638124] ehci-pci: EHCI PCI platform driver
[    1.638347] ehci-pci 0000:00:1a.0: EHCI Host Controller
[    1.638365] ehci-pci 0000:00:1a.0: new USB bus registered, assigned bus number 3
[    1.638383] ehci-pci 0000:00:1a.0: debug port 2
[    1.642309] ehci-pci 0000:00:1a.0: cache line size of 64 is not supported
[    1.642336] ehci-pci 0000:00:1a.0: irq 16, io mem 0xf161a000
[    1.652748] ehci-pci 0000:00:1a.0: USB 2.0 started, EHCI 1.00
[    1.652845] usb usb3: New USB device found, idVendor=1d6b, idProduct=0002
[    1.652847] usb usb3: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    1.652849] usb usb3: Product: EHCI Host Controller
[    1.652851] usb usb3: Manufacturer: Linux 4.1.2 ehci_hcd
[    1.652852] usb usb3: SerialNumber: 0000:00:1a.0
[    1.653210] hub 3-0:1.0: USB hub found
[    1.653226] hub 3-0:1.0: 2 ports detected
[    1.653811] ehci-pci 0000:00:1d.0: EHCI Host Controller
[    1.653823] ehci-pci 0000:00:1d.0: new USB bus registered, assigned bus number 4
[    1.653843] ehci-pci 0000:00:1d.0: debug port 2
[    1.657768] ehci-pci 0000:00:1d.0: cache line size of 64 is not supported
[    1.657790] ehci-pci 0000:00:1d.0: irq 23, io mem 0xf1619000
[    1.668778] ehci-pci 0000:00:1d.0: USB 2.0 started, EHCI 1.00
[    1.668864] usb usb4: New USB device found, idVendor=1d6b, idProduct=0002
[    1.668866] usb usb4: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    1.668868] usb usb4: Product: EHCI Host Controller
[    1.668870] usb usb4: Manufacturer: Linux 4.1.2 ehci_hcd
[    1.668871] usb usb4: SerialNumber: 0000:00:1d.0
[    1.669214] hub 4-0:1.0: USB hub found
[    1.669228] hub 4-0:1.0: 2 ports detected
[    1.669604] ehci-platform: EHCI generic platform driver
[    1.669626] ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
[    1.669636] ohci-pci: OHCI PCI platform driver
[    1.669663] ohci-platform: OHCI generic platform driver
[    1.669682] uhci_hcd: USB Universal Host Controller Interface driver
[    1.669782] i8042: PNP: PS/2 Controller [PNP0303:PS2K,PNP0f13:PS2M] at 0x60,0x64 irq 1,12
[    1.674369] serio: i8042 KBD port at 0x60,0x64 irq 1
[    1.674699] serio: i8042 AUX port at 0x60,0x64 irq 12
[    1.675092] mousedev: PS/2 mouse device common for all mice
[    1.676118] rtc_cmos 00:01: RTC can wake from S4
[    1.676445] rtc_cmos 00:01: rtc core: registered rtc_cmos as rtc0
[    1.676487] rtc_cmos 00:01: alarms up to one month, y3k, 242 bytes nvram, hpet irqs
[    1.676665] device-mapper: uevent: version 1.0.3
[    1.676963] device-mapper: ioctl: 4.31.0-ioctl (2015-3-12) initialised: dm-devel@redhat.com
[    1.676989] Intel P-state driver initializing.
[    1.677483] oprofile: using NMI interrupt.
[    1.677586] NET: Registered protocol family 17
[    1.677699] Key type dns_resolver registered
[    1.678651] registered taskstats version 1
[    1.682821] Key type trusted registered
[    1.683425] input: AT Translated Set 2 keyboard as /devices/platform/i8042/serio0/input/input4
[    1.688563] Key type encrypted registered
[    1.688573] AppArmor: AppArmor sha1 policy hashing enabled
[    1.688576] evm: HMAC attrs: 0x1
[    1.689421]   Magic number: 7:455:489
[    1.689474] netpoll: netconsole: local port 33333
[    1.689476] netpoll: netconsole: local IPv4 address 192.168.1.82
[    1.689477] netpoll: netconsole: interface 'eth0'
[    1.689478] netpoll: netconsole: remote port 9999
[    1.689479] netpoll: netconsole: remote IPv4 address 192.168.1.61
[    1.689480] netpoll: netconsole: remote ethernet address 00:06:5b:6a:a5:74
[    1.689482] netpoll: netconsole: device eth0 not up yet, forcing it
[    1.689913] r8169 0000:03:00.0: Direct firmware load for rtl_nic/rtl8105e-1.fw failed with error -2
[    1.689918] r8169 0000:03:00.0 eth0: unable to load firmware patch rtl_nic/rtl8105e-1.fw (-2)
[    1.812003] r8169 0000:03:00.0 eth0: link down
[    1.945150] usb 1-2: new low-speed USB device number 2 using xhci_hcd
[    1.965160] usb 3-1: new high-speed USB device number 2 using ehci-pci
[    1.981182] usb 4-1: new high-speed USB device number 2 using ehci-pci
[    2.077246] usb 1-2: New USB device found, idVendor=046d, idProduct=c018
[    2.077249] usb 1-2: New USB device strings: Mfr=1, Product=2, SerialNumber=0
[    2.077251] usb 1-2: Product: USB Optical Mouse
[    2.077253] usb 1-2: Manufacturer: Logitech
[    2.077582] usb 1-2: ep 0x81 - rounding interval to 64 microframes, ep desc says 80 microframes
[    2.098015] usb 3-1: New USB device found, idVendor=8087, idProduct=0024
[    2.098018] usb 3-1: New USB device strings: Mfr=0, Product=0, SerialNumber=0
[    2.098603] hub 3-1:1.0: USB hub found
[    2.098729] hub 3-1:1.0: 6 ports detected
[    2.114034] usb 4-1: New USB device found, idVendor=8087, idProduct=0024
[    2.114037] usb 4-1: New USB device strings: Mfr=0, Product=0, SerialNumber=0
[    2.114606] hub 4-1:1.0: USB hub found
[    2.114767] hub 4-1:1.0: 8 ports detected
[    2.197460] tsc: Refined TSC clocksource calibration: 2494.333 MHz
[    2.197476] clocksource tsc: mask: 0xffffffffffffffff max_cycles: 0x23f45085418, max_idle_ns: 440795285711 ns
[    2.369808] usb 3-1.3: new high-speed USB device number 3 using ehci-pci
[    2.389829] usb 4-1.5: new full-speed USB device number 3 using ehci-pci
[    2.463217] usb 3-1.3: New USB device found, idVendor=0bda, idProduct=0129
[    2.463224] usb 3-1.3: New USB device strings: Mfr=1, Product=2, SerialNumber=3
[    2.463228] usb 3-1.3: Product: USB2.0-CRW
[    2.463243] usb 3-1.3: Manufacturer: Generic
[    2.463244] usb 3-1.3: SerialNumber: 20100201396000000
[    2.486834] usb 4-1.5: New USB device found, idVendor=8087, idProduct=07da
[    2.486837] usb 4-1.5: New USB device strings: Mfr=0, Product=0, SerialNumber=0
[    2.533995] usb 3-1.5: new high-speed USB device number 4 using ehci-pci
[    2.689921] usb 3-1.5: New USB device found, idVendor=0c45, idProduct=648d
[    2.689924] usb 3-1.5: New USB device strings: Mfr=2, Product=1, SerialNumber=0
[    2.689926] usb 3-1.5: Product: Laptop_Integrated_Webcam_HD
[    2.689927] usb 3-1.5: Manufacturer: 1234567890-2JT
[    3.198879] Switched to clocksource tsc
[    5.821543] netpoll: netconsole: timeout waiting for carrier
[    5.821990] console [netcon0] enabled
[    5.821991] netconsole: network logging started
[    5.822062] rtc_cmos 00:01: setting system clock to 2015-07-11 16:27:54 UTC (1436632074)
[    5.822288] BIOS EDD facility v0.16 2004-Jun-25, 0 devices found
[    5.822290] EDD information not available.
[    5.822482] PM: Hibernation image not present or could not be loaded.
[    5.823166] Freeing unused kernel memory: 1264K (ffffffff81d3f000 - ffffffff81e7b000)
[    5.823168] Write protecting the kernel read-only data: 12288k
[    5.823635] Freeing unused kernel memory: 344K (ffff8800017aa000 - ffff880001800000)
[    5.823989] Freeing unused kernel memory: 992K (ffff880001b08000 - ffff880001c00000)
[    5.842180] random: systemd-udevd urandom read with 10 bits of entropy available
[    6.083489] wmi: Mapper loaded
[    6.092659] hidraw: raw HID events driver (C) Jiri Kosina
[    6.094966] [drm] Initialized drm 1.1.0 20060810
[    6.095446] usbcore: registered new interface driver usbhid
[    6.095450] usbhid: USB HID core driver
[    6.100106] ahci 0000:00:1f.2: version 3.0
[    6.113867] ahci 0000:00:1f.2: AHCI 0001.0300 32 slots 6 ports 6 Gbps 0x9 impl SATA mode
[    6.113873] ahci 0000:00:1f.2: flags: 64bit ncq pm led clo pio slum part ems apst 
[    6.129090] scsi host0: ahci
[    6.129634] scsi host1: ahci
[    6.129873] scsi host2: ahci
[    6.138009] scsi host3: ahci
[    6.138856] scsi host4: ahci
[    6.139270] scsi host5: ahci
[    6.139693] ata1: SATA max UDMA/133 abar m2048@0xf1618000 port 0xf1618100 irq 28
[    6.139696] ata2: DUMMY
[    6.139698] ata3: DUMMY
[    6.139702] ata4: SATA max UDMA/133 abar m2048@0xf1618000 port 0xf1618280 irq 28
[    6.139704] ata5: DUMMY
[    6.139706] ata6: DUMMY
[    6.145691] [drm] Memory usable by graphics device = 2048M
[    6.145727] checking generic (e0000000 580000) vs hw (e0000000 10000000)
[    6.145730] fb: switching to inteldrmfb from VESA VGA
[    6.146205] Console: switching to colour dummy device 80x25
[    6.149537] [drm] Replacing VGA console driver
[    6.162373] [drm] Supports vblank timestamp caching Rev 2 (21.10.2013).
[    6.162378] [drm] Driver supports precise vblank timestamp query.
[    6.163787] vgaarb: device changed decodes: PCI:0000:00:02.0,olddecodes=io+mem,decodes=none:owns=io+mem
[    6.177304] input: Logitech USB Optical Mouse as /devices/pci0000:00/0000:00:14.0/usb1/1-2/1-2:1.0/0003:046D:C018.0001/input/input7
[    6.178600] hid-generic 0003:046D:C018.0001: input,hidraw0: USB HID v1.11 Mouse [Logitech USB Optical Mouse] on usb-0000:00:14.0-2/input0
[    6.178679] ACPI Warning: \_SB_.PCI0.GFX0._DSM: Argument #4 type mismatch - Found [Buffer], ACPI requires [Package] (20150410/nsarguments-95)
[    6.179439] ACPI Warning: \_SB_.PCI0.GFX0._DSM: Argument #4 type mismatch - Found [Buffer], ACPI requires [Package] (20150410/nsarguments-95)
[    6.180140] i915 0000:00:02.0: optimus capabilities: enabled, status dynamic power, 
[    6.180219] ACPI Warning: \_SB_.PCI0.PEG0.PEGP._DSM: Argument #4 type mismatch - Found [Buffer], ACPI requires [Package] (20150410/nsarguments-95)
[    6.180845] ACPI Warning: \_SB_.PCI0.PEG0.PEGP._DSM: Argument #4 type mismatch - Found [Buffer], ACPI requires [Package] (20150410/nsarguments-95)
[    6.181431] pci 0000:01:00.0: optimus capabilities: enabled, status dynamic power, 
[    6.181441] VGA switcheroo: detected Optimus DSM method \_SB_.PCI0.PEG0.PEGP handle
[    6.181656] nouveau 0000:01:00.0: enabling device (0006 -> 0007)
[    6.190802] [Firmware Bug]: ACPI(PEGP) defines _DOD but not _DOS
[    6.190922] ACPI: Video Device [PEGP] (multi-head: yes  rom: yes  post: no)
[    6.191235] input: Video Bus as /devices/LNXSYSTM:00/LNXSYBUS:00/PNP0A08:00/device:30/LNXVIDEO:00/input/input8
[    6.193527] ACPI: Video Device [GFX0] (multi-head: yes  rom: no  post: no)
[    6.193749] input: Video Bus as /devices/LNXSYSTM:00/LNXSYBUS:00/PNP0A08:00/LNXVIDEO:01/input/input9
[    6.193989] [drm] Initialized i915 1.6.0 20150327 for 0000:00:02.0 on minor 0
[    6.195044] nouveau  [  DEVICE][0000:01:00.0] BOOT0  : 0x0e7110a2
[    6.195049] nouveau  [  DEVICE][0000:01:00.0] Chipset: GK107 (NVE7)
[    6.195051] nouveau  [  DEVICE][0000:01:00.0] Family : NVE0
[    6.203416] fbcon: inteldrmfb (fb0) is primary device
[    6.240559] nouveau  [   VBIOS][0000:01:00.0] using image from ACPI
[    6.240646] nouveau  [   VBIOS][0000:01:00.0] BIT signature found
[    6.240648] nouveau  [   VBIOS][0000:01:00.0] version 80.07.35.00.0c
[    6.242068] nouveau  [ DEVINIT][0000:01:00.0] adaptor not initialised
[    6.242096] nouveau  [   VBIOS][0000:01:00.0] running init tables
[    6.458235] ata1: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
[    6.460127] ata1.00: ATA-8: ST9500325AS, D005DEM1, max UDMA/133
[    6.460129] ata1.00: 976773168 sectors, multi 16: LBA48 NCQ (depth 31/32)
[    6.462317] ata1.00: configured for UDMA/133
[    6.463008] scsi 0:0:0:0: Direct-Access     ATA      ST9500325AS      DEM1 PQ: 0 ANSI: 5
[    6.464066] sd 0:0:0:0: [sda] 976773168 512-byte logical blocks: (500 GB/465 GiB)
[    6.464211] sd 0:0:0:0: [sda] Write Protect is off
[    6.464214] sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
[    6.464271] sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[    6.465120] sd 0:0:0:0: Attached scsi generic sg0 type 0
[    6.470246] ata4: SATA link up 1.5 Gbps (SStatus 113 SControl 300)
[    6.485560] ata4.00: ATAPI: MATSHITA DVD+/-RW UJ8D1, D.02, max UDMA/100
[    6.488941]  sda: sda1 sda2 sda3 sda4
[    6.490253] sd 0:0:0:0: [sda] Attached SCSI disk
[    6.498712] ata4.00: configured for UDMA/100
[    6.505301] scsi 3:0:0:0: CD-ROM            MATSHITA DVD+-RW UJ8D1    D.02 PQ: 0 ANSI: 5
[    6.524448] nouveau  [     PMC][0000:01:00.0] MSI interrupts enabled
[    6.524518] nouveau  [     PFB][0000:01:00.0] RAM type: GDDR5
[    6.524519] nouveau  [     PFB][0000:01:00.0] RAM size: 2048 MiB
[    6.524520] nouveau  [     PFB][0000:01:00.0]    ZCOMP: 0 tags
[    6.528912] nouveau  [    VOLT][0000:01:00.0] GPU voltage: 850000uv
[    6.531912] sr 3:0:0:0: [sr0] scsi3-mmc drive: 24x/24x writer dvd-ram cd/rw xa/form2 cdda tray
[    6.531914] cdrom: Uniform CD-ROM driver Revision: 3.20
[    6.532515] sr 3:0:0:0: Attached scsi CD-ROM sr0
[    6.532740] sr 3:0:0:0: Attached scsi generic sg1 type 5
[    6.582102] nouveau  [  PTHERM][0000:01:00.0] FAN control: none / external
[    6.582124] nouveau  [  PTHERM][0000:01:00.0] fan management: automatic
[    6.582339] [drm:intel_set_pch_fifo_underrun_reporting [i915]] *ERROR* uncleared pch fifo underrun on pch transcoder A
[    6.582339] nouveau  [  PTHERM][0000:01:00.0] internal sensor: yes
[    6.582360] [drm:intel_pch_fifo_underrun_irq_handler [i915]] *ERROR* PCH transcoder A FIFO underrun
[    6.582510] nouveau  [     CLK][0000:01:00.0] 07: core 270-405 MHz memory 810 MHz 
[    6.582563] nouveau  [     CLK][0000:01:00.0] 0a: core 270-835 MHz memory 1600 MHz 
[    6.582602] nouveau  [     CLK][0000:01:00.0] 0f: core 270-835 MHz memory 4000 MHz 
[    6.582779] nouveau  [     CLK][0000:01:00.0] --: core 405 MHz memory 648 MHz 
[    6.609273] vga_switcheroo: enabled
[    6.609723] [TTM] Zone  kernel: Available graphics memory: 1943316 kiB
[    6.609724] [TTM] Initializing pool allocator
[    6.609744] [TTM] Initializing DMA pool allocator
[    6.609860] nouveau  [     DRM] VRAM: 2048 MiB
[    6.609860] nouveau  [     DRM] GART: 1048576 MiB
[    6.609863] nouveau  [     DRM] TMDS table version 2.0
[    6.609864] nouveau  [     DRM] DCB version 4.0
[    6.609865] nouveau  [     DRM] DCB outp 00: 02000f00 00000000
[    6.609867] nouveau  [     DRM] DCB conn 00: 00000000
[    6.611719] [drm] Supports vblank timestamp caching Rev 2 (21.10.2013).
[    6.611719] [drm] Driver supports precise vblank timestamp query.
[    6.617580] nouveau  [     DRM] MM: using COPY for buffer copies
[    6.628528] nouveau 0000:01:00.0: No connectors reported connected with modes
[    6.628530] [drm] Cannot find any crtc or sizes - going 1024x768
[    6.659059] nouveau  [     DRM] allocated 1024x768 fb: 0x60000, bo ffff880032d42000
[    6.975039] Console: switching to colour frame buffer device 200x56
[    6.977877] i915 0000:00:02.0: fb0: inteldrmfb frame buffer device
[    6.977879] i915 0000:00:02.0: registered panic notifier
[    6.978267] nouveau 0000:01:00.0: fb1: nouveaufb frame buffer device
[    6.978270] nouveau 0000:01:00.0: registered panic notifier
[    6.999215] [drm] Initialized nouveau 1.2.2 20120801 for 0000:01:00.0 on minor 1
[    7.059967] input: AlpsPS/2 ALPS GlidePoint as /devices/platform/i8042/serio1/input/input6
[    8.053967] EXT4-fs (sda3): INFO: recovery required on readonly filesystem
[    8.053970] EXT4-fs (sda3): write access will be enabled during recovery
[    8.363400] random: nonblocking pool is initialized
[   10.267250] EXT4-fs (sda3): orphan cleanup on readonly fs
[   10.562112] EXT4-fs (sda3): 23 orphan inodes deleted
[   10.562115] EXT4-fs (sda3): recovery complete
[   10.834765] EXT4-fs (sda3): mounted filesystem with ordered data mode. Opts: (null)
[   12.283197] systemd[1]: Failed to insert module 'autofs4'
[   12.307994] systemd[1]: Failed to insert module 'ipv6'
[   12.526126] systemd[1]: systemd 219 running in system mode. (+PAM +AUDIT +SELINUX +IMA +APPARMOR +SMACK +SYSVINIT +UTMP +LIBCRYPTSETUP +GCRYPT -GNUTLS +ACL +XZ -LZ4 -SECCOMP +BLKID -ELFUTILS +KMOD -IDN)
[   12.526479] systemd[1]: Detected architecture x86-64.
[   12.604514] systemd[1]: Set hostname to <marcin-Inspiron-7720>.
[   12.969995] ACPI Warning: \_SB_.PCI0.PEG0.PEGP._DSM: Argument #4 type mismatch - Found [Buffer], ACPI requires [Package] (20150410/nsarguments-95)
[   12.970337] ACPI Warning: \_SB_.PCI0.PEG0.PEGP._DSM: Argument #4 type mismatch - Found [Buffer], ACPI requires [Package] (20150410/nsarguments-95)
[   15.970235] systemd[1]: Starting of Arbitrary Executable File Formats File System Automount Point not supported.
[   15.970477] systemd[1]: Reached target Remote File Systems (Pre).
[   15.970489] systemd[1]: Starting Remote File Systems (Pre).
[   15.970598] systemd[1]: Reached target Encrypted Volumes.
[   15.970606] systemd[1]: Starting Encrypted Volumes.
[   15.970782] systemd[1]: Started Forward Password Requests to Wall Directory Watch.
[   15.970791] systemd[1]: Starting Forward Password Requests to Wall Directory Watch.
[   15.970935] systemd[1]: Created slice Root Slice.
[   15.970944] systemd[1]: Starting Root Slice.
[   15.971087] systemd[1]: Listening on fsck to fsckd communication Socket.
[   15.971096] systemd[1]: Starting fsck to fsckd communication Socket.
[   15.971262] systemd[1]: Listening on Journal Socket.
[   15.971275] systemd[1]: Starting Journal Socket.
[   15.971493] systemd[1]: Listening on Journal Audit Socket.
[   15.971502] systemd[1]: Starting Journal Audit Socket.
[   15.971664] systemd[1]: Listening on /dev/initctl Compatibility Named Pipe.
[   15.971673] systemd[1]: Starting /dev/initctl Compatibility Named Pipe.
[   15.972098] systemd[1]: Created slice User and Session Slice.
[   15.972108] systemd[1]: Starting User and Session Slice.
[   15.972221] systemd[1]: Listening on udev Control Socket.
[   15.972230] systemd[1]: Starting udev Control Socket.
[   15.972343] systemd[1]: Listening on Journal Socket (/dev/log).
[   15.972352] systemd[1]: Starting Journal Socket (/dev/log).
[   15.972453] systemd[1]: Listening on Delayed Shutdown Socket.
[   15.972461] systemd[1]: Starting Delayed Shutdown Socket.
[   15.972712] systemd[1]: Created slice System Slice.
[   15.972726] systemd[1]: Starting System Slice.
[   15.973802] systemd[1]: Starting Create list of required static device nodes for the current kernel...
[   15.975461] systemd[1]: Starting Setup Virtual Console...
[   15.977010] systemd[1]: Starting Nameserver information manager...
[   16.265926] systemd[1]: Starting Load Kernel Modules...
[   16.267272] systemd[1]: Starting Increase datagram queue length...
[   16.268629] systemd[1]: Started Braille Device Support.
[   16.269672] systemd[1]: Starting Braille Device Support...
[   16.270917] systemd[1]: Mounting Debug File System...
[   16.485318] systemd[1]: Started Set Up Additional Binary Formats.
[   16.486333] systemd[1]: Starting Uncomplicated firewall...
[   16.488089] systemd[1]: Started Read required files in advance.
[   16.488277] systemd[1]: Starting Read required files in advance...
[   16.488835] systemd[1]: Listening on udev Kernel Socket.
[   16.488847] systemd[1]: Starting udev Kernel Socket.
[   16.489842] systemd[1]: Starting udev Coldplug all Devices...
[   16.490094] systemd[1]: Reached target Slices.
[   16.490114] systemd[1]: Starting Slices.
[   16.491168] systemd[1]: Mounting POSIX Message Queue File System...
[   16.491616] systemd[1]: Created slice system-getty.slice.
[   16.491642] systemd[1]: Starting system-getty.slice.
[   16.492876] systemd[1]: Mounting Huge Pages File System...
[   16.495120] systemd[1]: Mounted Debug File System.
[   16.495384] systemd[1]: Mounted POSIX Message Queue File System.
[   16.496336] systemd[1]: Mounted Huge Pages File System.
[   16.497744] systemd[1]: Started Create list of required static device nodes for the current kernel.
[   16.498702] systemd[1]: Started Setup Virtual Console.
[   16.501411] systemd[1]: Started Increase datagram queue length.
[   16.513875] systemd[1]: Listening on Syslog Socket.
[   16.513889] systemd[1]: Starting Syslog Socket.
[   16.514877] systemd[1]: Starting Journal Service...
[   16.516244] systemd[1]: Starting Create Static Device Nodes in /dev...
[   16.595764] systemd[1]: Started Nameserver information manager.
[   16.719723] systemd[1]: Started udev Coldplug all Devices.
[   16.721812] systemd[1]: Starting udev Wait for Complete Device Initialization...
[   16.723797] systemd[1]: Started Uncomplicated firewall.
[   17.187752] lp: driver loaded but no devices found
[   17.209740] ppdev: user-space parallel port driver
[   17.313333] systemd[1]: Started Journal Service.
[   19.409989] ACPI Warning: SystemIO range 0x0000000000000428-0x000000000000042F conflicts with OpRegion 0x0000000000000400-0x000000000000047F (\PMIO) (20150410/utaddress-254)
[   19.409996] ACPI: If an ACPI driver is available for this device, you should use it instead of the native driver
[   19.410000] ACPI Warning: SystemIO range 0x0000000000000540-0x000000000000054F conflicts with OpRegion 0x0000000000000500-0x0000000000000563 (\GPIO) (20150410/utaddress-254)
[   19.410003] ACPI Warning: SystemIO range 0x0000000000000540-0x000000000000054F conflicts with OpRegion 0x0000000000000500-0x000000000000055F (\_SB_.PCI0.PEG0.PEGP.GPIO) (20150410/utaddress-254)
[   19.410006] ACPI: If an ACPI driver is available for this device, you should use it instead of the native driver
[   19.410008] ACPI Warning: SystemIO range 0x0000000000000530-0x000000000000053F conflicts with OpRegion 0x0000000000000500-0x0000000000000563 (\GPIO) (20150410/utaddress-254)
[   19.410010] ACPI Warning: SystemIO range 0x0000000000000530-0x000000000000053F conflicts with OpRegion 0x0000000000000500-0x000000000000055F (\_SB_.PCI0.PEG0.PEGP.GPIO) (20150410/utaddress-254)
[   19.410013] ACPI: If an ACPI driver is available for this device, you should use it instead of the native driver
[   19.410014] ACPI Warning: SystemIO range 0x0000000000000500-0x000000000000052F conflicts with OpRegion 0x0000000000000500-0x0000000000000563 (\GPIO) (20150410/utaddress-254)
[   19.410017] ACPI Warning: SystemIO range 0x0000000000000500-0x000000000000052F conflicts with OpRegion 0x0000000000000500-0x000000000000055F (\_SB_.PCI0.PEG0.PEGP.GPIO) (20150410/utaddress-254)
[   19.410020] ACPI: If an ACPI driver is available for this device, you should use it instead of the native driver
[   19.410021] lpc_ich: Resource conflict(s) found affecting gpio_ich
[   19.825406] microcode: CPU0 sig=0x306a9, pf=0x10, revision=0x12
[   19.927814] microcode: CPU1 sig=0x306a9, pf=0x10, revision=0x12
[   19.927871] microcode: CPU2 sig=0x306a9, pf=0x10, revision=0x12
[   19.927903] microcode: CPU3 sig=0x306a9, pf=0x10, revision=0x12
[   19.928211] microcode: Microcode Update Driver: v2.00 <tigran@aivazian.fsnet.co.uk>, Peter Oruba
[   20.796161] dcdbas dcdbas: Dell Systems Management Base Driver (version 5.6.0-3.2)
[   20.984423] Linux video capture interface: v2.00
[   21.028076] input: Dell WMI hotkeys as /devices/virtual/input/input10
[   21.319646] Bluetooth: Core ver 2.20
[   21.319675] NET: Registered protocol family 31
[   21.319676] Bluetooth: HCI device and connection manager initialized
[   21.319746] Bluetooth: HCI socket layer initialized
[   21.319750] Bluetooth: L2CAP socket layer initialized
[   21.319802] Bluetooth: SCO socket layer initialized
[   21.432630] snd_hda_codec_idt hdaudioC0D0: autoconfig for 92HD91BXX: line_outs=1 (0xd/0x0/0x0/0x0/0x0) type:speaker
[   21.432634] snd_hda_codec_idt hdaudioC0D0:    speaker_outs=0 (0x0/0x0/0x0/0x0/0x0)
[   21.432636] snd_hda_codec_idt hdaudioC0D0:    hp_outs=1 (0xb/0x0/0x0/0x0/0x0)
[   21.432638] snd_hda_codec_idt hdaudioC0D0:    mono: mono_out=0x0
[   21.432639] snd_hda_codec_idt hdaudioC0D0:    inputs:
[   21.432641] snd_hda_codec_idt hdaudioC0D0:      Internal Mic=0x11
[   21.432643] snd_hda_codec_idt hdaudioC0D0:      Mic=0xa
[   21.438211] usbcore: registered new interface driver btusb
[   21.536735] input: HDA Intel PCH Mic as /devices/pci0000:00/0000:00:1b.0/sound/card0/input11
[   21.537249] input: HDA Intel PCH Headphone as /devices/pci0000:00/0000:00:1b.0/sound/card0/input12
[   21.537509] input: HDA Intel PCH HDMI/DP,pcm=3 as /devices/pci0000:00/0000:00:1b.0/sound/card0/input13
[   21.569313] uvcvideo: Found UVC 1.00 device Laptop_Integrated_Webcam_HD (0c45:648d)
[   21.594334] input: Laptop_Integrated_Webcam_HD as /devices/pci0000:00/0000:00:1a.0/usb3/3-1/3-1.5/3-1.5:1.0/input/input14
[   21.594582] usbcore: registered new interface driver uvcvideo
[   21.594584] USB Video Class driver (1.1.1)
[   21.944289] usbcore: registered new interface driver rtsx_usb
[   23.978247] cfg80211: Calling CRDA to update world regulatory domain
[   24.349533] cfg80211: World regulatory domain updated:
[   24.349538] cfg80211:  DFS Master region: unset
[   24.349540] cfg80211:   (start_freq - end_freq @ bandwidth), (max_antenna_gain, max_eirp), (dfs_cac_time)
[   24.349542] cfg80211:   (2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2000 mBm), (N/A)
[   24.349543] cfg80211:   (2457000 KHz - 2482000 KHz @ 40000 KHz), (300 mBi, 2000 mBm), (N/A)
[   24.349545] cfg80211:   (2474000 KHz - 2494000 KHz @ 20000 KHz), (300 mBi, 2000 mBm), (N/A)
[   24.349546] cfg80211:   (5170000 KHz - 5250000 KHz @ 40000 KHz), (300 mBi, 2000 mBm), (N/A)
[   24.349547] cfg80211:   (5735000 KHz - 5835000 KHz @ 40000 KHz), (300 mBi, 2000 mBm), (N/A)
[   24.678820] Intel(R) Wireless WiFi driver for Linux
[   24.678823] Copyright(c) 2003- 2015 Intel Corporation
[   24.679068] iwlwifi 0000:02:00.0: can't disable ASPM; OS doesn't have ASPM control
[   24.894945] iwlwifi 0000:02:00.0: loaded firmware version 18.168.6.1 op_mode iwldvm
[   24.975507] Adding 3628028k swap on /dev/sda4.  Priority:-1 extents:1 across:3628028k FS
[   25.275209] EXT4-fs (sda3): re-mounted. Opts: errors=remount-ro
[   25.626260] systemd-journald[262]: Received request to flush runtime journal from PID 1
[   25.860455] ACPI Warning: \_SB_.PCI0.PEG0.PEGP._DSM: Argument #4 type mismatch - Found [Buffer], ACPI requires [Package] (20150410/nsarguments-95)
[   25.860801] ACPI Warning: \_SB_.PCI0.PEG0.PEGP._DSM: Argument #4 type mismatch - Found [Buffer], ACPI requires [Package] (20150410/nsarguments-95)
[   27.639175] audit: type=1400 audit(1436632096.287:2): apparmor="STATUS" operation="profile_load" name="/usr/lib/lightdm/lightdm-guest-session" pid=506 comm="apparmor_parser"
[   27.639191] audit: type=1400 audit(1436632096.287:3): apparmor="STATUS" operation="profile_load" name="chromium" pid=506 comm="apparmor_parser"
[   27.675703] audit: type=1400 audit(1436632096.323:4): apparmor="STATUS" operation="profile_load" name="/usr/lib/x86_64-linux-gnu/lightdm-remote-session-freerdp/freerdp-session-wrapper" pid=506 comm="apparmor_parser"
[   27.675735] audit: type=1400 audit(1436632096.323:5): apparmor="STATUS" operation="profile_load" name="chromium" pid=506 comm="apparmor_parser"
[   27.713517] audit: type=1400 audit(1436632096.363:6): apparmor="STATUS" operation="profile_load" name="/usr/lib/x86_64-linux-gnu/lightdm-remote-session-uccsconfigure/uccsconfigure-session-wrapper" pid=506 comm="apparmor_parser"
[   27.713540] audit: type=1400 audit(1436632096.363:7): apparmor="STATUS" operation="profile_load" name="chromium" pid=506 comm="apparmor_parser"
[   27.827253] audit: type=1400 audit(1436632096.475:8): apparmor="STATUS" operation="profile_load" name="/sbin/dhclient" pid=506 comm="apparmor_parser"
[   27.827277] audit: type=1400 audit(1436632096.475:9): apparmor="STATUS" operation="profile_load" name="/usr/lib/NetworkManager/nm-dhcp-client.action" pid=506 comm="apparmor_parser"
[   27.827296] audit: type=1400 audit(1436632096.475:10): apparmor="STATUS" operation="profile_load" name="/usr/lib/NetworkManager/nm-dhcp-helper" pid=506 comm="apparmor_parser"
[   27.827311] audit: type=1400 audit(1436632096.475:11): apparmor="STATUS" operation="profile_load" name="/usr/lib/connman/scripts/dhclient-script" pid=506 comm="apparmor_parser"
[   29.498077] iwlwifi 0000:02:00.0: CONFIG_IWLWIFI_DEBUG disabled
[   29.498080] iwlwifi 0000:02:00.0: CONFIG_IWLWIFI_DEBUGFS enabled
[   29.498082] iwlwifi 0000:02:00.0: CONFIG_IWLWIFI_DEVICE_TRACING enabled
[   29.498084] iwlwifi 0000:02:00.0: Detected Intel(R) Centrino(R) Wireless-N 2230 BGN, REV=0xC8
[   29.498371] iwlwifi 0000:02:00.0: L1 Enabled - LTR Disabled
[   29.519432] cfg80211: Ignoring regulatory request set by core since the driver uses its own custom regulatory domain
[   29.867785] ieee80211 phy0: Selected rate control algorithm 'iwl-agn-rs'
[   36.647056] input: GlidePoint Virtual Touchpad as /devices/virtual/input/input15
[   37.019259] Bluetooth: BNEP (Ethernet Emulation) ver 1.3
[   37.019262] Bluetooth: BNEP filters: protocol multicast
[   37.019270] Bluetooth: BNEP socket layer initialized
[   37.087988] serio_raw serio1: raw access enabled on isa0060/serio1 (serio_raw0, minor 57)
[   37.450962] Bluetooth: RFCOMM TTY layer initialized
[   37.450974] Bluetooth: RFCOMM socket layer initialized
[   37.450985] Bluetooth: RFCOMM ver 1.11
[   37.842152] ACPI Warning: \_SB_.PCI0.PEG0.PEGP._DSM: Argument #4 type mismatch - Found [Buffer], ACPI requires [Package] (20150410/nsarguments-95)
[   37.842491] ACPI Warning: \_SB_.PCI0.PEG0.PEGP._DSM: Argument #4 type mismatch - Found [Buffer], ACPI requires [Package] (20150410/nsarguments-95)
[   39.498975] iwlwifi 0000:02:00.0: L1 Enabled - LTR Disabled
[   39.507242] iwlwifi 0000:02:00.0: Radio type=0x2-0x0-0x0
[   39.755294] iwlwifi 0000:02:00.0: L1 Enabled - LTR Disabled
[   39.762978] iwlwifi 0000:02:00.0: Radio type=0x2-0x0-0x0
[   40.672757] cfg80211: Found new beacon on frequency: 2467 MHz (Ch 12) on phy0
[   40.854884] wlan0: authenticate with 00:71:c2:33:3e:c8
[   40.860955] wlan0: send auth to 00:71:c2:33:3e:c8 (try 1/3)
[   40.864836] wlan0: authenticated
[   40.865733] wlan0: associate with 00:71:c2:33:3e:c8 (try 1/3)
[   40.869614] wlan0: RX AssocResp from 00:71:c2:33:3e:c8 (capab=0x1411 status=0 aid=2)
[   40.876528] wlan0: associated
[   49.859816] ACPI Warning: \_SB_.PCI0.PEG0.PEGP._DSM: Argument #4 type mismatch - Found [Buffer], ACPI requires [Package] (20150410/nsarguments-95)
[   49.860159] ACPI Warning: \_SB_.PCI0.PEG0.PEGP._DSM: Argument #4 type mismatch - Found [Buffer], ACPI requires [Package] (20150410/nsarguments-95)
[   63.696512] ACPI Warning: \_SB_.PCI0.PEG0.PEGP._DSM: Argument #4 type mismatch - Found [Buffer], ACPI requires [Package] (20150410/nsarguments-95)
[   63.696870] ACPI Warning: \_SB_.PCI0.PEG0.PEGP._DSM: Argument #4 type mismatch - Found [Buffer], ACPI requires [Package] (20150410/nsarguments-95)
[   73.758546] ACPI Warning: \_SB_.PCI0.PEG0.PEGP._DSM: Argument #4 type mismatch - Found [Buffer], ACPI requires [Package] (20150410/nsarguments-95)
[   73.758948] ACPI Warning: \_SB_.PCI0.PEG0.PEGP._DSM: Argument #4 type mismatch - Found [Buffer], ACPI requires [Package] (20150410/nsarguments-95)
[   88.606890] ACPI Warning: \_SB_.PCI0.PEG0.PEGP._DSM: Argument #4 type mismatch - Found [Buffer], ACPI requires [Package] (20150410/nsarguments-95)
[   88.607233] ACPI Warning: \_SB_.PCI0.PEG0.PEGP._DSM: Argument #4 type mismatch - Found [Buffer], ACPI requires [Package] (20150410/nsarguments-95)
[  100.632990] cfg80211: Verifying active interfaces after reg change
[  122.616317] ACPI Warning: \_SB_.PCI0.PEG0.PEGP._DSM: Argument #4 type mismatch - Found [Buffer], ACPI requires [Package] (20150410/nsarguments-95)
[  122.616659] ACPI Warning: \_SB_.PCI0.PEG0.PEGP._DSM: Argument #4 type mismatch - Found [Buffer], ACPI requires [Package] (20150410/nsarguments-95)
[  136.622046] ACPI Warning: \_SB_.PCI0.PEG0.PEGP._DSM: Argument #4 type mismatch - Found [Buffer], ACPI requires [Package] (20150410/nsarguments-95)
[  136.622816] ACPI Warning: \_SB_.PCI0.PEG0.PEGP._DSM: Argument #4 type mismatch - Found [Buffer], ACPI requires [Package] (20150410/nsarguments-95)
[  852.597992] perf interrupt took too long (2503 > 2500), lowering kernel.perf_event_max_sample_rate to 50000
[ 1392.422095] perf interrupt took too long (5044 > 5000), lowering kernel.perf_event_max_sample_rate to 25000
[ 5317.957173] perf interrupt took too long (10048 > 10000), lowering kernel.perf_event_max_sample_rate to 12500
[15428.089988] ACPI Warning: \_SB_.PCI0.PEG0.PEGP._DSM: Argument #4 type mismatch - Found [Buffer], ACPI requires [Package] (20150410/nsarguments-95)
[15428.090675] ACPI Warning: \_SB_.PCI0.PEG0.PEGP._DSM: Argument #4 type mismatch - Found [Buffer], ACPI requires [Package] (20150410/nsarguments-95)
[15464.083832] ACPI Warning: \_SB_.PCI0.PEG0.PEGP._DSM: Argument #4 type mismatch - Found [Buffer], ACPI requires [Package] (20150410/nsarguments-95)
[15464.085050] ACPI Warning: \_SB_.PCI0.PEG0.PEGP._DSM: Argument #4 type mismatch - Found [Buffer], ACPI requires [Package] (20150410/nsarguments-95)
[15473.118169] ACPI Warning: \_SB_.PCI0.PEG0.PEGP._DSM: Argument #4 type mismatch - Found [Buffer], ACPI requires [Package] (20150410/nsarguments-95)
[15473.118523] ACPI Warning: \_SB_.PCI0.PEG0.PEGP._DSM: Argument #4 type mismatch - Found [Buffer], ACPI requires [Package] (20150410/nsarguments-95)
[15483.270116] ACPI Warning: \_SB_.PCI0.PEG0.PEGP._DSM: Argument #4 type mismatch - Found [Buffer], ACPI requires [Package] (20150410/nsarguments-95)
[15483.271032] ACPI Warning: \_SB_.PCI0.PEG0.PEGP._DSM: Argument #4 type mismatch - Found [Buffer], ACPI requires [Package] (20150410/nsarguments-95)
[15775.467964] ACPI Warning: \_SB_.PCI0.PEG0.PEGP._DSM: Argument #4 type mismatch - Found [Buffer], ACPI requires [Package] (20150410/nsarguments-95)
[15775.468733] ACPI Warning: \_SB_.PCI0.PEG0.PEGP._DSM: Argument #4 type mismatch - Found [Buffer], ACPI requires [Package] (20150410/nsarguments-95)
[15879.603904] ACPI Warning: \_SB_.PCI0.PEG0.PEGP._DSM: Argument #4 type mismatch - Found [Buffer], ACPI requires [Package] (20150410/nsarguments-95)
[15879.604750] ACPI Warning: \_SB_.PCI0.PEG0.PEGP._DSM: Argument #4 type mismatch - Found [Buffer], ACPI requires [Package] (20150410/nsarguments-95)
[16761.795146] ACPI Warning: \_SB_.PCI0.PEG0.PEGP._DSM: Argument #4 type mismatch - Found [Buffer], ACPI requires [Package] (20150410/nsarguments-95)
[16761.796161] ACPI Warning: \_SB_.PCI0.PEG0.PEGP._DSM: Argument #4 type mismatch - Found [Buffer], ACPI requires [Package] (20150410/nsarguments-95)
[17146.060241] show_signal_msg: 51 callbacks suppressed
[17146.060253] gl-3.1-vao-brok[25936]: segfault at 0 ip 00007f15fe3bff70 sp 00007fff57c81e58 error 4 in libc-2.21.so[7f15fe320000+1c0000]
[17218.144846] ACPI Warning: \_SB_.PCI0.PEG0.PEGP._DSM: Argument #4 type mismatch - Found [Buffer], ACPI requires [Package] (20150410/nsarguments-95)
[17218.145413] ACPI Warning: \_SB_.PCI0.PEG0.PEGP._DSM: Argument #4 type mismatch - Found [Buffer], ACPI requires [Package] (20150410/nsarguments-95)
[17359.803629] gl-3.1-vao-brok[332]: segfault at 0 ip 00007f2551e3cf70 sp 00007ffc7fd83e58 error 4 in libc-2.21.so[7f2551d9d000+1c0000]
[17736.209474] shader_runner[13971]: segfault at 20 ip 00007f928b4b2a17 sp 00007ffe38f23180 error 4 in i965_dri.so[7f928b24c000+55b000]
[18365.397976] shader_runner[8515]: segfault at 20 ip 00007fa90d0c83b7 sp 00007ffd01b03b40 error 4 in ilo_dri.so[7fa90ce91000+7af000]
[18469.712406] glx-multithread[15437]: segfault at 11e0 ip 00007fe5d03ab170 sp 00007fe5d019b400 error 6 in libpciaccess.so.0.11.1[7fe5d03a5000+8000]
[18502.644365] ACPI Warning: \_SB_.PCI0.PEG0.PEGP._DSM: Argument #4 type mismatch - Found [Buffer], ACPI requires [Package] (20150410/nsarguments-95)
[18502.644740] ACPI Warning: \_SB_.PCI0.PEG0.PEGP._DSM: Argument #4 type mismatch - Found [Buffer], ACPI requires [Package] (20150410/nsarguments-95)
[18666.599635] Unable to purge GPU memory due lock contention.
[18666.600991] avahi-daemon invoked oom-killer: gfp_mask=0x201da, order=0, oom_score_adj=0
[18666.600998] avahi-daemon cpuset=/ mems_allowed=0
[18666.601048] CPU: 0 PID: 646 Comm: avahi-daemon Not tainted 4.1.2 #56
[18666.601052] Hardware name: Dell Inc.          Inspiron 7720/04M3YM, BIOS A07 08/16/2012
[18666.601056]  ffff880139f0c2c0 ffff88013703b948 ffffffff81796918 0000000080000001
[18666.601070]  0000000000000000 ffff88013703b9d8 ffffffff81795b33 ffffffff8179f45f
[18666.601082]  0000000000000010 0000000000000292 ffff88013703b988 ffff88013703b998
[18666.601091] Call Trace:
[18666.601101]  [<ffffffff81796918>] dump_stack+0x4f/0x7b
[18666.601106]  [<ffffffff81795b33>] dump_header.isra.12+0x7c/0x22a
[18666.601112]  [<ffffffff8179f45f>] ? _raw_spin_unlock_irqrestore+0x5f/0x80
[18666.601116]  [<ffffffff8179f442>] ? _raw_spin_unlock_irqrestore+0x42/0x80
[18666.601121]  [<ffffffff8141d7a4>] ? ___ratelimit+0x84/0x110
[18666.601128]  [<ffffffff811dd879>] oom_kill_process+0x1d9/0x3c0
[18666.601133]  [<ffffffff811dde60>] __out_of_memory+0x3a0/0x660
[18666.601138]  [<ffffffff811de2bb>] out_of_memory+0x5b/0x80
[18666.601144]  [<ffffffff811e463b>] __alloc_pages_nodemask+0xa7b/0xc20
[18666.601150]  [<ffffffff8122a683>] alloc_pages_current+0xf3/0x1a0
[18666.601154]  [<ffffffff811d9067>] ? __page_cache_alloc+0x117/0x140
[18666.601159]  [<ffffffff811d9067>] __page_cache_alloc+0x117/0x140
[18666.601166]  [<ffffffff811da45c>] ? pagecache_get_page+0x2c/0x1d0
[18666.601171]  [<ffffffff811dbebf>] filemap_fault+0x19f/0x3d0
[18666.601175]  [<ffffffff812088cd>] __do_fault+0x3d/0xc0
[18666.601181]  [<ffffffff8179f395>] ? _raw_spin_unlock+0x35/0x60
[18666.601185]  [<ffffffff8120c2e0>] handle_mm_fault+0xcd0/0x11a0
[18666.601192]  [<ffffffff810a36c6>] ? __do_page_fault+0x136/0x510
[18666.601196]  [<ffffffff810a371c>] __do_page_fault+0x18c/0x510
[18666.601200]  [<ffffffff810a3aac>] do_page_fault+0xc/0x10
[18666.601204]  [<ffffffff817a1a62>] page_fault+0x22/0x30
[18666.601208] Mem-Info:
[18666.601245] active_anon:500600 inactive_anon:409404 isolated_anon:960
 active_file:116 inactive_file:116 isolated_file:0
 unevictable:8 dirty:0 writeback:0 unstable:0
 slab_reclaimable:15872 slab_unreclaimable:12217
 mapped:266996 shmem:677248 pagetables:7589 bounce:0
 free:6685 free_pcp:75 free_cma:0
[18666.601251] Node 0 DMA free:15136kB min:28kB low:32kB high:40kB active_anon:108kB inactive_anon:380kB active_file:16kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15984kB managed:15900kB mlocked:0kB dirty:0kB writeback:0kB mapped:48kB shmem:416kB slab_reclaimable:40kB slab_unreclaimable:84kB kernel_stack:0kB pagetables:4kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:33204 all_unreclaimable? yes
[18666.601260] lowmem_reserve[]: 0 2829 3777 3777
[18666.601275] Node 0 DMA32 free:9704kB min:5800kB low:7248kB high:8700kB active_anon:1556084kB inactive_anon:1178164kB active_file:296kB inactive_file:200kB unevictable:32kB isolated(anon):2176kB isolated(file):0kB present:2993644kB managed:2899868kB mlocked:32kB dirty:0kB writeback:0kB mapped:800880kB shmem:1981000kB slab_reclaimable:46940kB slab_unreclaimable:33844kB kernel_stack:4896kB pagetables:22012kB unstable:0kB bounce:0kB free_pcp:124kB local_pcp:20kB free_cma:0kB writeback_tmp:0kB pages_scanned:231136 all_unreclaimable? no
[18666.601284] lowmem_reserve[]: 0 0 948 948
[18666.601297] Node 0 Normal free:1900kB min:1940kB low:2424kB high:2908kB active_anon:446208kB inactive_anon:459172kB active_file:152kB inactive_file:264kB unevictable:0kB isolated(anon):1536kB isolated(file):0kB present:1038336kB managed:970864kB mlocked:0kB dirty:0kB writeback:0kB mapped:267056kB shmem:727576kB slab_reclaimable:16508kB slab_unreclaimable:14940kB kernel_stack:2224kB pagetables:8340kB unstable:0kB bounce:0kB free_pcp:176kB local_pcp:132kB free_cma:0kB writeback_tmp:0kB pages_scanned:153192 all_unreclaimable? no
[18666.601306] lowmem_reserve[]: 0 0 0 0
[18666.601319] Node 0 DMA: 14*4kB (UEM) 17*8kB (UEM) 16*16kB (UEM) 7*32kB (UEM) 0*64kB 1*128kB (U) 2*256kB (U) 3*512kB (UEM) 2*1024kB (EM) 3*2048kB (EMR) 1*4096kB (M) = 15136kB
[18666.601534] Node 0 DMA32: 1413*4kB (UEM) 117*8kB (UEM) 8*16kB (R) 12*32kB (R) 5*64kB (R) 2*128kB (R) 2*256kB (R) 1*512kB (R) 1*1024kB (R) 0*2048kB 0*4096kB = 9724kB
[18666.601802] Node 0 Normal: 148*4kB (UEM) 6*8kB (UR) 3*16kB (R) 13*32kB (R) 3*64kB (R) 5*128kB (R) 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1936kB
[18666.601953] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[18666.601956] 680980 total pagecache pages
[18666.602019] 3441 pages in swap cache
[18666.602023] Swap cache stats: add 817075, delete 813634, find 343841/439745
[18666.602026] Free swap  = 3079184kB
[18666.602028] Total swap = 3628028kB
[18666.602031] 1011991 pages RAM
[18666.602033] 0 pages HighMem/MovableOnly
[18666.602036] 40333 pages reserved
[18666.602039] 0 pages hwpoisoned
[18666.602041] [ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds swapents oom_score_adj name
[18666.602057] [  262]     0   262     7477      320      19       3       67             0 systemd-journal
[18666.602064] [  296]     0   296    10090       35      22       3      210         -1000 systemd-udevd
[18666.602072] [  477]   119   477    25584       16      21       3       49             0 systemd-timesyn
[18666.602141] [  639]     0   639     6191       45      16       3      163             0 smartd
[18666.602147] [  640]     0   640    38670       66      33       3      100             0 thermald
[18666.602154] [  642]     0   642    84104        4      64       4      319             0 ModemManager
[18666.602161] [  643]     0   643    71547      145      41       4      117             0 accounts-daemon
[18666.602167] [  644]     0   644     7130       34      20       3       55             0 systemd-logind
[18666.602173] [  646]   106   646     7578       30      21       3       44             0 avahi-daemon
[18666.602180] [  653]     0   653    22608        2      47       3      668             0 cupsd
[18666.602186] [  661]     0   661     7538       44      21       3       47             0 cron
[18666.602192] [  677]     0   677     4795        0      15       3       45             0 atd
[18666.602199] [  678]   101   678    63974       90      27       3      112             0 rsyslogd
[18666.602205] [  680]     0   680    97484      265      73       3      345             0 NetworkManager
[18666.602211] [  682]     0   682     4891        5      15       3       78             0 bluetoothd
[18666.602217] [  702]   114   702    91939       83      79       3      332             0 whoopsie
[18666.602224] [  713]   103   713    10937      316      26       3      123          -900 dbus-daemon
[18666.602230] [  721]     0   721     4860       26      14       3       29             0 irqbalance
[18666.602236] [  753]   106   753     7547        6      19       3       53             0 avahi-daemon
[18666.602243] [  777]     0   777    71459       72      28       3       31             0 glided
[18666.602312] [  788]     0   788     2667       16      11       3       18             0 glidegrd
[18666.602318] [  804]     0   804    70066       86      39       4      516             0 polkitd
[18666.602325] [  805]   102   805    76738        5      53       3      859             0 colord
[18666.602331] [  813]     0   813    39030       12      45       3      232             0 cups-browsed
[18666.602337] [  819]     0   819    69168      110      36       3      110             0 lightdm
[18666.602344] [  899]     7   899    16033        0      35       3      165             0 dbus
[18666.602350] [  901]     7   901    16033        0      37       3      165             0 dbus
[18666.602356] [  914]     0   914     7689       47      19       3      107             0 wpa_supplicant
[18666.602362] [  918]     0   918   113979     7783     156       3     2233             0 Xorg
[18666.602368] [  959]     0   959     5872       64      14       3     1667             0 dhclient
[18666.602375] [  972] 65534   972     9328       18      24       3       49             0 dnsmasq
[18666.602381] [ 1011]     0  1011     1099        0       8       3       47             0 acpid
[18666.602387] [ 1190]     0  1190     4269        6      13       3       36             0 agetty
[18666.602394] [ 1224]   108  1224     8848       25      20       3       55             0 kerneloops
[18666.602400] [ 1388]     0  1388     6356       24      17       3       53             0 master
[18666.602406] [ 1396]   117  1396     6885       23      19       3       50             0 qmgr
[18666.602413] [ 1459]     0  1459    46921       62      61       3      209             0 lightdm
[18666.602419] [ 1563]   110  1563    42239       23      18       3       38             0 rtkit-daemon
[18666.602425] [ 1564]     0  1564    67823       19      51       3      296             0 upowerd
[18666.602431] [ 1653]  1001  1653    10655        6      26       3      160             0 systemd
[18666.602438] [ 1654]  1001  1654    21839        8      46       3      443             0 (sd-pam)
[18666.602444] [ 1658]  1001  1658    52796       44      36       3      167             0 gnome-keyring-d
[18666.602450] [ 1674]  1001  1674     8337      201      21       3       82             0 upstart
[18666.602520] [ 1760]  1001  1760     5381        5      15       3       44             0 upstart-udev-br
[18666.602527] [ 1762]  1001  1762    10830      277      24       3       71             0 dbus-daemon
[18666.602533] [ 1774]  1001  1774    18068       76      27       4       75             0 window-stack-br
[18666.602540] [ 1801]  1001  1801     4857       27      14       3       21             0 upstart-dbus-br
[18666.602546] [ 1804]  1001  1804     4857       29      14       3       20             0 upstart-dbus-br
[18666.602553] [ 1810]  1001  1810     7013       30      17       3       44             0 upstart-file-br
[18666.602559] [ 1838]  1001  1838    99545     1350     145       3     1030             0 hud-service
[18666.602566] [ 1840]  1001  1840   231987      448     175       4     1351             0 unity-settings-
[18666.602572] [ 1843]  1001  1843    66053       48      32       3       95             0 at-spi-bus-laun
[18666.602579] [ 1844]  1001  1844   136850      117      93       4      390             0 gnome-session
[18666.602586] [ 1847]  1001  1847   156349     2173     128       4      502             0 unity-panel-ser
[18666.602592] [ 1850]  1001  1850    10597       51      25       3       85             0 dbus-daemon
[18666.602599] [ 1852]  1001  1852   369829     8130     266       4     6443             0 compiz
[18666.602605] [ 1857]  1001  1857    30799       75      31       3       82             0 at-spi2-registr
[18666.602612] [ 1863]  1001  1863   125611      767     111       3      526             0 bamfdaemon
[18666.602618] [ 1867]  1001  1867    48686       96      29       4       70             0 gvfsd
[18666.602625] [ 1871]  1001  1871    83806        0      32       3      186             0 gvfsd-fuse
[18666.602631] [ 1910]  1001  1910    44689        5      23       4      180             0 dconf-service
[18666.602696] [ 1916]  1001  1916   110588      155      92       4      796             0 pulseaudio
[18666.602703] [ 1923]  1001  1923    25753        0      53       3      197             0 gconf-helper
[18666.602709] [ 1925]  1001  1925    13474      108      32       3      319             0 gconfd-2
[18666.602715] [ 1927]  1001  1927    72176      186      42       3      128             0 indicator-messa
[18666.602722] [ 1928]  1001  1928    65320        0      31       3      160             0 indicator-bluet
[18666.602728] [ 1930]  1001  1930   103979        0      38       3      181             0 indicator-power
[18666.602734] [ 1932]  1001  1932   294348      106     100       5      750             0 indicator-datet
[18666.602740] [ 1933]  1001  1933   141132      310     129       4     1001             0 indicator-keybo
[18666.602746] [ 1934]  1001  1934   137105      213      67       4      319             0 indicator-sound
[18666.602753] [ 1937]  1001  1937   114216       36     120       3      892             0 indicator-print
[18666.602759] [ 1943]  1001  1943   187387      184      44       4       84             0 indicator-sessi
[18666.602765] [ 1962]  1001  1962    79878       90      82       3      263             0 indicator-appli
[18666.602771] [ 1995]  1001  1995   285851        0     154       5      885             0 evolution-sourc
[18666.602837] [ 2016]  1001  2016   258042      583     220       4     2586             0 nautilus
[18666.602843] [ 2030]  1001  2030    87708       88     105       4      735             0 polkit-gnome-au
[18666.602850] [ 2031]  1001  2031   144996      662     138       4      869             0 nm-applet
[18666.602856] [ 2033]  1001  2033   103766      104     101       3      714             0 unity-fallback-
[18666.602862] [ 2036]  1001  2036    32010       19      28       3       89             0 glideusd
[18666.602868] [ 2048]  1001  2048    72655      226      43       3      136             0 gvfs-udisks2-vo
[18666.602875] [ 2053]     0  2053    92605      188      46       3      294             0 udisksd
[18666.602881] [ 2073]  1001  2073    80864       54      46       4      204             0 gvfs-afc-volume
[18666.602887] [ 2078]  1001  2078    49790       60      33       3      128             0 gvfs-gphoto2-vo
[18666.602893] [ 2091]  1001  2091   162553       50     146       4     1115             0 goa-daemon
[18666.602899] [ 2095]  1001  2095    46747       67      27       4       75             0 gvfs-mtp-volume
[18666.602965] [ 2170]  1001  2170   281223        0     193       4     9347             0 evolution-calen
[18666.603012] [ 2188]  1001  2188    86377      207      56       4      261             0 mission-control
[18666.603023] [ 2225]  1001  2225    67095        0      32       3      164             0 gvfsd-burn
[18666.603029] [ 2243]  1001  2243    86697        0      37       3      220             0 gvfsd-trash
[18666.603036] [ 2282]  1001  2282    28803        0      27       3      492             0 gvfsd-metadata
[18666.603043] [ 2350]  1001  2350   115439       30     112       3      846             0 telepathy-indic
[18666.603049] [ 2390]  1001  2390   118586     2229     119       4      463             0 gnome-terminal-
[18666.603057] [ 2399]  1001  2399     3713       34      12       3        9             0 gnome-pty-helpe
[18666.603066] [ 2460]  1001  2460   106639      136      94       3      408             0 zeitgeist-datah
[18666.603074] [ 2465]  1001  2465    82949      153      30       3       93             0 zeitgeist-daemo
[18666.603081] [ 2479]  1001  2479    58449      104      38       4      181             0 zeitgeist-fts
[18666.603089] [ 2500]  1001  2500     2151        0       9       3       24             0 cat
[18666.603095] [ 3334]  1001  3334   127183       60     113       4      826             0 update-notifier
[18666.603103] [ 3362]  1001  3362    99225      401     116       4      823             0 notify-osd
[18666.603110] [ 3684]  1001  3684     6332        5      17       3      830             0 bash
[18666.603118] [ 4153]  1001  4153    72887        0      44       3      238             0 deja-dup-monito
[18666.603123] [ 6153]  1001  6153    12153       34      31       3      152             0 ssh
[18666.603131] [ 9556]  1001  9556   142171      579      71       4      187             0 unity-scope-hom
[18666.603138] [10289]  1001 10289   110457      312      59       4       88             0 unity-files-dae
[18666.603145] [10290]  1001 10290   145845     2361      79       4      688             0 unity-scope-loa
[18666.603154] [12002]  1001 12002     3694       43      12       3        1             0 eclipse
[18666.603161] [13317]  1001 13317   782959   120250     451       6    10841             0 java
[18666.603168] [12113]  1001 12113   303951    53032     441       4        1             0 firefox
[18666.603174] [20862]  1001 20862     6387      854      18       3        0             0 bash
[18666.603184] [ 8767]  1001  8767     6341      846      18       3        0             0 bash
[18666.603190] [ 9883]  1001  9883     3188       33      12       3        0             0 dmesg
[18666.603198] [24328]   117 24328     6873       70      18       3        0             0 pickup
[18666.603204] [25223]  1001 25223   237550    24837     111       4       22             0 python2
[18666.603213] [16003]  1001 16003   316570   263387     588       6        0             0 max-texture-siz
[18666.603219] [16054]     0 16054     1118       24       7       3        0             0 sh
[18666.603226] [16055]     0 16055     1118       20       8       3        0             0 sh
[18666.603233] [16056]  1001 16056      153        1       5       3        0             0 sh
[18666.603292] [16058]     0 16058     2709       29      11       3        0             0 ps
[18666.603299] [16059]     0 16059     2678       27      11       3        0             0 grep
[18666.603309] [16060]     0 16060     2658       26       9       3        0             0 w
[18666.603315] [16061]     0 16061     2671       27      10       3        0             0 grep
[18666.603321] Out of memory: Kill process 16003 (max-texture-siz) score 140 or sacrifice child
[18666.603485] Killed process 16003 (max-texture-siz) total-vm:1266280kB, anon-rss:4676kB, file-rss:1048872kB
[18676.521453] max-texture-siz: page allocation failure: order:0, mode:0xa00d2
[18676.521468] CPU: 1 PID: 16003 Comm: max-texture-siz Not tainted 4.1.2 #56
[18676.521472] Hardware name: Dell Inc.          Inspiron 7720/04M3YM, BIOS A07 08/16/2012
[18676.521497]  0000000000000000 ffff8800722e7558 ffffffff81796918 0000000080000001
[18676.521515]  00000000000a00d2 ffff8800722e75e8 ffffffff811dffa8 ffff88013f5f7d00
[18676.521535]  0000000000000000 0000000000000000 0000000000000000 ffff88013f5f7d38
[18676.521558] Call Trace:
[18676.521571]  [<ffffffff81796918>] dump_stack+0x4f/0x7b
[18676.521591]  [<ffffffff811dffa8>] warn_alloc_failed+0xd8/0x130
[18676.521596]  [<ffffffff811e3ff0>] __alloc_pages_nodemask+0x430/0xc20
[18676.521608]  [<ffffffff8122c08f>] ? alloc_pages_vma+0x10f/0x290
[18676.521622]  [<ffffffff8122c08f>] alloc_pages_vma+0x10f/0x290
[18676.521627]  [<ffffffff811f34a1>] ? shmem_alloc_page+0x61/0x90
[18676.521641]  [<ffffffff811f34a1>] shmem_alloc_page+0x61/0x90
[18676.521652]  [<ffffffff81435913>] ? __this_cpu_preempt_check+0x13/0x20
[18676.521669]  [<ffffffff81443065>] ? __percpu_counter_add+0x85/0xc0
[18676.521674]  [<ffffffff8120ff1d>] ? __vm_enough_memory+0x2d/0x150
[18676.521693]  [<ffffffff813bc9bc>] ? cap_vm_enough_memory+0x4c/0x60
[18676.521702]  [<ffffffff811f5f44>] shmem_getpage_gfp+0x5b4/0xa90
[18676.521734]  [<ffffffffa01e8520>] ? i915_gem_shrink+0x170/0x250 [i915]
[18676.521751]  [<ffffffff811f64c4>] shmem_read_mapping_page_gfp+0x34/0x60
[18676.521776]  [<ffffffffa01dd602>] i915_gem_object_get_pages_gtt+0x302/0x3e0 [i915]
[18676.521793]  [<ffffffffa01de848>] i915_gem_object_get_pages+0x58/0xd0 [i915]
[18676.521817]  [<ffffffffa01e5068>] i915_gem_object_do_pin+0x6f8/0xdf0 [i915]
[18676.521831]  [<ffffffff812339fc>] ? kmem_cache_alloc_trace+0x2ac/0x2e0
[18676.521855]  [<ffffffffa01e579a>] i915_gem_object_pin+0x3a/0x40 [i915]
[18676.521870]  [<ffffffffa01d3d96>] i915_gem_execbuffer_reserve_vma.isra.15+0x76/0x140 [i915]
[18676.521894]  [<ffffffffa01d414c>] i915_gem_execbuffer_reserve+0x2ec/0x320 [i915]
[18676.521916]  [<ffffffffa01d4bf8>] i915_gem_do_execbuffer.isra.24+0x608/0x10a0 [i915]
[18676.521930]  [<ffffffff812087a2>] ? might_fault+0x42/0xa0
[18676.521952]  [<ffffffffa01d6cdf>] i915_gem_execbuffer2+0xcf/0x2e0 [i915]
[18676.521967]  [<ffffffffa001bd25>] drm_ioctl+0x1a5/0x6b0 [drm]
[18676.521981]  [<ffffffff8128f653>] ? fsnotify+0x3a3/0x750
[18676.521985]  [<ffffffff8128f315>] ? fsnotify+0x65/0x750
[18676.522000]  [<ffffffff8125cac8>] do_vfs_ioctl+0x308/0x540
[18676.522005]  [<ffffffff81245b6c>] ? vfs_write+0x14c/0x1b0
[18676.522020]  [<ffffffff81268ecc>] ? __fget_light+0x6c/0xa0
[18676.522025]  [<ffffffff8125cd81>] SyS_ioctl+0x81/0xa0
[18676.522040]  [<ffffffff8179fd9b>] system_call_fastpath+0x16/0x73
[18676.522044] Mem-Info:
[18676.522060] active_anon:500601 inactive_anon:416545 isolated_anon:992
 active_file:20 inactive_file:43 isolated_file:0
 unevictable:8 dirty:1 writeback:0 unstable:0
 slab_reclaimable:15872 slab_unreclaimable:12217
 mapped:266835 shmem:684401 pagetables:7590 bounce:0
 free:5 free_pcp:21 free_cma:0
[18676.522070] Node 0 DMA free:4kB min:28kB low:32kB high:40kB active_anon:108kB inactive_anon:15516kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15984kB managed:15900kB mlocked:0kB dirty:0kB writeback:0kB mapped:32kB shmem:15564kB slab_reclaimable:40kB slab_unreclaimable:84kB kernel_stack:0kB pagetables:4kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:99040 all_unreclaimable? yes
[18676.522085] lowmem_reserve[]: 0 2829 3777 3777
[18676.522097] Node 0 DMA32 free:0kB min:5800kB low:7248kB high:8700kB active_anon:1556088kB inactive_anon:1188332kB active_file:8kB inactive_file:128kB unevictable:32kB isolated(anon):2944kB isolated(file):0kB present:2993644kB managed:2899868kB mlocked:32kB dirty:0kB writeback:0kB mapped:800428kB shmem:1991856kB slab_reclaimable:46940kB slab_unreclaimable:33844kB kernel_stack:4896kB pagetables:22012kB unstable:0kB bounce:0kB free_pcp:84kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:1849284 all_unreclaimable? no
[18676.522106] lowmem_reserve[]: 0 0 948 948
[18676.522124] Node 0 Normal free:64kB min:1940kB low:2424kB high:2908kB active_anon:446208kB inactive_anon:462332kB active_file:72kB inactive_file:44kB unevictable:0kB isolated(anon):1024kB isolated(file):0kB present:1038336kB managed:970864kB mlocked:0kB dirty:4kB writeback:0kB mapped:266880kB shmem:730184kB slab_reclaimable:16508kB slab_unreclaimable:14940kB kernel_stack:2224kB pagetables:8344kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:1878416 all_unreclaimable? no
[18676.522132] lowmem_reserve[]: 0 0 0 0
[18676.522143] Node 0 DMA: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 0kB
[18676.522181] Node 0 DMA32: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 0kB
[18676.522234] Node 0 Normal: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 0kB
[18676.843374] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[18676.843378] 687955 total pagecache pages
[18676.843390] 3441 pages in swap cache
[18676.843401] Swap cache stats: add 817076, delete 813635, find 343842/439748
[18676.843403] Free swap  = 3079188kB
[18676.843410] Total swap = 3628028kB
[18676.843413] 1011991 pages RAM
[18676.843428] 0 pages HighMem/MovableOnly
[18676.843431] 40333 pages reserved
[18676.843433] 0 pages hwpoisoned
[18721.830742] ACPI Warning: \_SB_.PCI0.PEG0.PEGP._DSM: Argument #4 type mismatch - Found [Buffer], ACPI requires [Package] (20150410/nsarguments-95)
[18721.831088] ACPI Warning: \_SB_.PCI0.PEG0.PEGP._DSM: Argument #4 type mismatch - Found [Buffer], ACPI requires [Package] (20150410/nsarguments-95)
[18752.874229] ACPI Warning: \_SB_.PCI0.PEG0.PEGP._DSM: Argument #4 type mismatch - Found [Buffer], ACPI requires [Package] (20150410/nsarguments-95)
[18752.875051] ACPI Warning: \_SB_.PCI0.PEG0.PEGP._DSM: Argument #4 type mismatch - Found [Buffer], ACPI requires [Package] (20150410/nsarguments-95)
[18795.915377] ACPI Warning: \_SB_.PCI0.PEG0.PEGP._DSM: Argument #4 type mismatch - Found [Buffer], ACPI requires [Package] (20150410/nsarguments-95)
[18795.915716] ACPI Warning: \_SB_.PCI0.PEG0.PEGP._DSM: Argument #4 type mismatch - Found [Buffer], ACPI requires [Package] (20150410/nsarguments-95)
[18853.961705] ACPI Warning: \_SB_.PCI0.PEG0.PEGP._DSM: Argument #4 type mismatch - Found [Buffer], ACPI requires [Package] (20150410/nsarguments-95)
[18853.962098] ACPI Warning: \_SB_.PCI0.PEG0.PEGP._DSM: Argument #4 type mismatch - Found [Buffer], ACPI requires [Package] (20150410/nsarguments-95)
[18872.018422] ACPI Warning: \_SB_.PCI0.PEG0.PEGP._DSM: Argument #4 type mismatch - Found [Buffer], ACPI requires [Package] (20150410/nsarguments-95)
[18872.018953] ACPI Warning: \_SB_.PCI0.PEG0.PEGP._DSM: Argument #4 type mismatch - Found [Buffer], ACPI requires [Package] (20150410/nsarguments-95)
[19441.333056] usb 2-1: new SuperSpeed USB device number 2 using xhci_hcd
[19441.349828] usb 2-1: New USB device found, idVendor=0781, idProduct=5583
[19441.349848] usb 2-1: New USB device strings: Mfr=1, Product=2, SerialNumber=3
[19441.349854] usb 2-1: Product: Ultra Fit
[19441.349859] usb 2-1: Manufacturer: SanDisk
[19441.349863] usb 2-1: SerialNumber: 4C531001370123106552
[19443.996499] usb-storage 2-1:1.0: USB Mass Storage device detected
[19443.996841] scsi host6: usb-storage 2-1:1.0
[19443.997251] usbcore: registered new interface driver usb-storage
[19444.030635] usbcore: registered new interface driver uas
[19444.998089] scsi 6:0:0:0: Direct-Access     SanDisk  Ultra Fit        1.00 PQ: 0 ANSI: 6
[19444.999437] sd 6:0:0:0: [sdb] 60751872 512-byte logical blocks: (31.1 GB/28.9 GiB)
[19444.999467] sd 6:0:0:0: Attached scsi generic sg2 type 0
[19445.000553] sd 6:0:0:0: [sdb] Write Protect is off
[19445.000564] sd 6:0:0:0: [sdb] Mode Sense: 43 00 00 00
[19445.000899] sd 6:0:0:0: [sdb] Write cache: disabled, read cache: enabled, doesn't support DPO or FUA
[19445.024456]  sdb: sdb1
[19445.025951] sd 6:0:0:0: [sdb] Attached SCSI removable disk
[20677.932148] usb 2-1: USB disconnect, device number 2
[28951.412879] PM: Syncing filesystems ... done.
[28951.571772] PM: Preparing system for mem sleep
[28951.709588] Freezing user space processes ... (elapsed 0.151 seconds) done.
[28951.861706] Freezing remaining freezable tasks ... (elapsed 0.001 seconds) done.
[28951.863476] PM: Entering mem sleep
[28951.863566] Suspending console(s) (use no_console_suspend to debug)
[28951.864837] wlan0: deauthenticating from 00:71:c2:33:3e:c8 by local choice (Reason: 3=DEAUTH_LEAVING)
[28951.898243] cfg80211: All devices are disconnected, going to restore regulatory settings
[28951.898254] cfg80211: Restoring regulatory settings
[28951.898265] cfg80211: Kicking the queue
[28951.898269] cfg80211: Calling CRDA to update world regulatory domain
[28951.898875] sd 0:0:0:0: [sda] Synchronizing SCSI cache
[28951.924196] sd 0:0:0:0: [sda] Stopping disk
[28952.860926] nouveau  [     DRM] suspending console...
[28952.860928] nouveau  [     DRM] suspending display...
[28952.860958] nouveau  [     DRM] evicting buffers...
[28952.860961] nouveau  [     DRM] waiting for kernel channels to go idle...
[28952.861001] nouveau  [     DRM] suspending client object trees...
[28952.866571] nouveau  [     DRM] suspending kernel object tree...
[28954.256312] PM: suspend of devices complete after 2389.092 msecs
[28954.256314] PM: suspend devices took 2.392 seconds
[28954.272042] PM: late suspend of devices complete after 15.706 msecs
[28954.274041] ehci-pci 0000:00:1d.0: System wakeup enabled by ACPI
[28954.274104] xhci_hcd 0000:00:14.0: System wakeup enabled by ACPI
[28954.274133] r8169 0000:03:00.0: System wakeup enabled by ACPI
[28954.274193] ehci-pci 0000:00:1a.0: System wakeup enabled by ACPI
[28954.288218] PM: noirq suspend of devices complete after 16.153 msecs
[28954.288411] ACPI: Preparing to enter system sleep state S3
[28954.312511] ACPI : EC: EC stopped
[28954.312512] PM: Saving platform NVS memory
[28954.312539] Disabling non-boot CPUs ...
[28954.313059] intel_pstate CPU 1 exiting
[28954.315408] Broke affinity for irq 26
[28954.316423] kvm: disabling virtualization on CPU1
[28954.316761] smpboot: CPU 1 is now offline

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
