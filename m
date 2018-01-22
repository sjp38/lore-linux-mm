Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id B3BDD800D8
	for <linux-mm@kvack.org>; Mon, 22 Jan 2018 03:32:58 -0500 (EST)
Received: by mail-ot0-f198.google.com with SMTP id 78so5870709otj.15
        for <linux-mm@kvack.org>; Mon, 22 Jan 2018 00:32:58 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v48si3344409otd.233.2018.01.22.00.32.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Jan 2018 00:32:56 -0800 (PST)
Date: Mon, 22 Jan 2018 03:32:55 -0500 (EST)
From: Yi Zhang <yi.zhang@redhat.com>
Message-ID: <936807826.1524362.1516609975494.JavaMail.zimbra@redhat.com>
In-Reply-To: <405995114.1520111.1516608361726.JavaMail.zimbra@redhat.com>
Subject: bug report - kernel BUG at mm/slub.c:3894!
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi

With below steps, I always can reproduce this kernel BUG, could anyone help check it, thanks

Reproducer:
STATE=0
j=1
MAXCPUs=`nproc`

while(( ${j}<=10 ))
do
        echo ".....................................$j"
        for i in $(seq 0 `expr ${MAXCPUs} - 1`)
        do
                if ((i%4)); then
                        echo $STATE > /sys/devices/system/cpu/cpu$i/online
                fi
        done
        if [[ $STATE -eq 1 ]]; then
                STATE=0
        else
                STATE=1
        fi
        let "j++"
done

for k in $(seq 0 `expr ${MAXCPUs} - 1`)
do
        echo 1 > /sys/devices/system/cpu/cpu$k/online
done

Environment:
# lscpu 
Architecture:          x86_64
CPU op-mode(s):        32-bit, 64-bit
Byte Order:            Little Endian
CPU(s):                12
On-line CPU(s) list:   0-11
Thread(s) per core:    1
Core(s) per socket:    6
Socket(s):             2
NUMA node(s):          2
Vendor ID:             GenuineIntel
CPU family:            6
Model:                 63
Model name:            Intel(R) Xeon(R) CPU E5-2603 v3 @ 1.60GHz
Stepping:              2
CPU MHz:               1270.507
CPU max MHz:           1600.0000
CPU min MHz:           1200.0000
BogoMIPS:              3199.96
Virtualization:        VT-x
L1d cache:             32K
L1i cache:             32K
L2 cache:              256K
L3 cache:              15360K
NUMA node0 CPU(s):     0,2,4,6,8,10
NUMA node1 CPU(s):     1,3,5,7,9,11
Flags:                 fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx pdpe1gb rdtscp lm constant_tsc arch_perfmon pebs bts rep_good nopl xtopology nonstop_tsc aperfmperf eagerfpu pni pclmulqdq dtes64 monitor ds_cpl vmx smx est tm2 ssse3 sdbg fma cx16 xtpr pdcm pcid dca sse4_1 sse4_2 x2apic movbe popcnt tsc_deadline_timer aes xsave avx f16c rdrand lahf_lm abm epb spec_ctrl ibpb_support tpr_shadow vnmi flexpriority ept vpid fsgsbase tsc_adjust bmi1 avx2 smep bmi2 erms invpcid cqm xsaveopt cqm_llc cqm_occup_llc dtherm arat pln pts


Kernel log:
[  283.648463] IRQ 82: no longer affine to CPU2
[  283.653223] IRQ 83: no longer affine to CPU2
[  283.657987] IRQ 88: no longer affine to CPU2
[  283.662753] IRQ 96: no longer affine to CPU2
[  284.072489] IRQ 60: no longer affine to CPU6
[  284.077267] IRQ 81: no longer affine to CPU6
[  284.082032] IRQ 85: no longer affine to CPU6
[  284.086799] IRQ 93: no longer affine to CPU6
[  284.505883] IRQ 87: no longer affine to CPU10
[  284.510750] IRQ 89: no longer affine to CPU10
[  284.530224] NOHZ: local_softirq_pending 02
[  284.658280] ------------[ cut here ]------------
[  284.663434] kernel BUG at mm/slub.c:3894!
[  284.667927] invalid opcode: 0000 [#1] SMP PTI
[  284.672787] Modules linked in: acpi_cpufreq(+) sunrpc vfat fat intel_rapl sb_edac btrfs x86_pkg_temp_thermal intel_powerclamp coretemp xor kvm_intel kvm zstd_decompress irqbypass zstd_compress xxhash crct10dif_pclmul ipmi_ssif crc32_pclmul ghash_clmulni_intel pcbc iTCO_wdt aesni_intel iTCO_vendor_support crypto_simd glue_helper raid6_pq ipmi_si cryptd mxm_wmi dcdbas ipmi_devintf pcspkr ipmi_msghandler sg mei_me lpc_ich mei shpchp acpi_power_meter wmi dm_multipath ip_tables xfs libcrc32c sd_mod mgag200 i2c_algo_bit drm_kms_helper syscopyarea sysfillrect sysimgblt fb_sys_fops ttm drm ahci libahci nvme libata tg3 crc32c_intel nvme_core megaraid_sas i2c_core ptp pps_core dm_mirror dm_region_hash dm_log dm_mod
[  284.742576] CPU: 1 PID: 14 Comm: cpuhp/1 Not tainted 4.15.0-rc8 #1
[  284.749473] Hardware name: Dell Inc. PowerEdge R730xd/072T6D, BIOS 2.5.5 08/16/2017
[  284.758025] RIP: 0010:kfree+0x15b/0x170
[  284.762303] RSP: 0018:ffffafec00197d28 EFLAGS: 00010246
[  284.768132] RAX: dead000000000100 RBX: ffff957b47000000 RCX: ffff957cb70f2b40
[  284.776094] RDX: 00006a8740000000 RSI: ffff957b47371ea0 RDI: ffff957b47000000
[  284.784055] RBP: ffff957cb34b2a18 R08: ffff957cb70f2b40 R09: ffff957ab2cafab8
[  284.792018] R10: ffff9579ce508bc8 R11: fffff1908c1c0000 R12: ffffffffa04cf6c1
[  284.799980] R13: 0000000000000000 R14: ffff9579cfd02df0 R15: 0000000000000084
[  284.807943] FS:  0000000000000000(0000) GS:ffff957cbfc00000(0000) knlGS:0000000000000000
[  284.816971] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  284.823383] CR2: 00007f46dc730000 CR3: 00000003eb80a001 CR4: 00000000001606e0
[  284.831345] Call Trace:
[  284.834078]  kernfs_put+0x71/0x190
[  284.837876]  ? nmi_panic_self_stop+0x30/0x30
[  284.842638]  __kernfs_remove+0xf7/0x1f0
[  284.846919]  ? kernfs_name_hash+0x12/0x80
[  284.851391]  kernfs_remove_by_name_ns+0x3e/0x80
[  284.856451]  device_del+0x8f/0x310
[  284.860247]  ? class_find_device+0x91/0xe0
[  284.864816]  ? nmi_panic_self_stop+0x30/0x30
[  284.869580]  device_unregister+0x16/0x70
[  284.873956]  device_destroy+0x3a/0x40
[  284.878042]  msr_device_destroy+0x19/0x20
[  284.882520]  cpuhp_invoke_callback+0xad/0x590
[  284.887383]  ? __padata_remove_cpu.part.8+0x90/0x90
[  284.892827]  cpuhp_thread_fun+0xc6/0x160
[  284.897203]  smpboot_thread_fn+0xfe/0x150
[  284.901679]  kthread+0xf5/0x130
[  284.905183]  ? sort_range+0x20/0x20
[  284.909074]  ? kthread_associate_blkcg+0x90/0x90
[  284.914228]  ret_from_fork+0x32/0x40
[  284.918215] Code: ff 49 8b 03 f6 c4 80 75 08 49 8b 43 20 a8 01 74 1a 49 8b 03 31 f6 f6 c4 80 74 04 41 8b 73 6c 5b 5d 41 5c 4c 89 df e9 c5 45 f9 ff <0f> 0b 48 83 e8 01 e9 01 ff ff ff 49 83 eb 01 e9 e9 fe ff ff 90 
[  284.939309] RIP: kfree+0x15b/0x170 RSP: ffffafec00197d28
[  284.945252] ---[ end trace 5a3846fe48038f5d ]---
[  284.957384] Kernel panic - not syncing: Fatal exception
[  284.963261] Kernel Offset: 0x1f200000 from 0xffffffff81000000 (relocation range: 0xffffffff80000000-0xffffffffbfffffff)
[  284.982209] ---[ end Kernel panic - not syncing: Fatal exception
[  284.988934] WARNING: CPU: 1 PID: 14 at kernel/sched/core.c:1188 set_task_cpu+0x184/0x190
[  284.997964] Modules linked in: acpi_cpufreq(+) sunrpc vfat fat intel_rapl sb_edac btrfs x86_pkg_temp_thermal intel_powerclamp coretemp xor kvm_intel kvm zstd_decompress irqbypass zstd_compress xxhash crct10dif_pclmul ipmi_ssif crc32_pclmul ghash_clmulni_intel pcbc iTCO_wdt aesni_intel iTCO_vendor_support crypto_simd glue_helper raid6_pq ipmi_si cryptd mxm_wmi dcdbas ipmi_devintf pcspkr ipmi_msghandler sg mei_me lpc_ich mei shpchp acpi_power_meter wmi dm_multipath ip_tables xfs libcrc32c sd_mod mgag200 i2c_algo_bit drm_kms_helper syscopyarea sysfillrect sysimgblt fb_sys_fops ttm drm ahci libahci nvme libata tg3 crc32c_intel nvme_core megaraid_sas i2c_core ptp pps_core dm_mirror dm_region_hash dm_log dm_mod
[  285.067755] CPU: 1 PID: 14 Comm: cpuhp/1 Tainted: G      D          4.15.0-rc8 #1
[  285.076104] Hardware name: Dell Inc. PowerEdge R730xd/072T6D, BIOS 2.5.5 08/16/2017
[  285.084651] RIP: 0010:set_task_cpu+0x184/0x190
[  285.089607] RSP: 0018:ffff957cbfc03cf8 EFLAGS: 00010046
[  285.095436] RAX: 0000000000000200 RBX: ffff957cb246dd00 RCX: 0000000000000001
[  285.103398] RDX: 0000000000000001 RSI: 0000000000000000 RDI: ffff957cb246dd00
[  285.111361] RBP: 0000000000022240 R08: 0000000000000555 R09: 0000000000000000
[  285.119322] R10: 0000000000000000 R11: ffffafec00197848 R12: 0000000000000000
[  285.127284] R13: 0000000000000000 R14: 0000000000000046 R15: 0000000000000000
[  285.135247] FS:  0000000000000000(0000) GS:ffff957cbfc00000(0000) knlGS:0000000000000000
[  285.144277] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  285.150687] CR2: 00007f46dc730000 CR3: 00000003eb80a001 CR4: 00000000001606e0
[  285.158650] Call Trace:
[  285.161380]  <IRQ>
[  285.163626]  try_to_wake_up+0x161/0x440
[  285.167908]  ? account_entity_enqueue+0xc5/0xf0
[  285.172956]  __wake_up_common+0x8a/0x150
[  285.177336]  ep_poll_callback+0xc9/0x2f0
[  285.181713]  __wake_up_common+0x8a/0x150
[  285.186090]  __wake_up_common_lock+0x7a/0xc0
[  285.190858]  irq_work_run_list+0x46/0x70
[  285.195237]  ? tick_sched_do_timer+0x60/0x60
[  285.200004]  update_process_times+0x3b/0x50
[  285.204671]  tick_sched_handle+0x26/0x60
[  285.209048]  tick_sched_timer+0x34/0x70
[  285.213327]  __hrtimer_run_queues+0xdc/0x220
[  285.218091]  hrtimer_interrupt+0x99/0x190
[  285.222566]  smp_apic_timer_interrupt+0x56/0x120
[  285.227716]  apic_timer_interrupt+0xa2/0xb0
[  285.232384]  </IRQ>
[  285.234727] RIP: 0010:panic+0x1fa/0x23c
[  285.238996] RSP: 0018:ffffafec00197ad8 EFLAGS: 00000246 ORIG_RAX: ffffffffffffff11
[  285.247443] RAX: 0000000000000034 RBX: 0000000000000200 RCX: 0000000000000006
[  285.255406] RDX: 0000000000000000 RSI: 0000000000000086 RDI: ffff957cbfc16870
[  285.263369] RBP: ffffafec00197b48 R08: 0000000000000000 R09: 00000000000006ac
[  285.271332] R10: 0000000000000000 R11: ffffafec00197848 R12: ffffffffa104ae70
[  285.279295] R13: 0000000000000000 R14: 0000000000000000 R15: ffffffffa104a6e9
[  285.287260]  ? panic+0x1f3/0x23c
[  285.290863]  oops_end+0xaf/0xc0
[  285.294360]  do_trap+0x13d/0x150
[  285.297962]  do_error_trap+0xc1/0x120
[  285.302051]  ? kfree+0x15b/0x170
[  285.305652]  ? __switch_to+0xa8/0x4f0
[  285.309739]  ? kernfs_put+0x71/0x190
[  285.313731]  invalid_op+0x22/0x40
[  285.317429] RIP: 0010:kfree+0x15b/0x170
[  285.321707] RSP: 0018:ffffafec00197d28 EFLAGS: 00010246
[  285.327537] RAX: dead000000000100 RBX: ffff957b47000000 RCX: ffff957cb70f2b40
[  285.335500] RDX: 00006a8740000000 RSI: ffff957b47371ea0 RDI: ffff957b47000000
[  285.343464] RBP: ffff957cb34b2a18 R08: ffff957cb70f2b40 R09: ffff957ab2cafab8
[  285.351427] R10: ffff9579ce508bc8 R11: fffff1908c1c0000 R12: ffffffffa04cf6c1
[  285.359387] R13: 0000000000000000 R14: ffff9579cfd02df0 R15: 0000000000000084
[  285.367351]  ? kernfs_put+0x71/0x190
[  285.371339]  kernfs_put+0x71/0x190
[  285.375135]  ? nmi_panic_self_stop+0x30/0x30
[  285.379899]  __kernfs_remove+0xf7/0x1f0
[  285.384180]  ? kernfs_name_hash+0x12/0x80
[  285.388653]  kernfs_remove_by_name_ns+0x3e/0x80
[  285.393711]  device_del+0x8f/0x310
[  285.397506]  ? class_find_device+0x91/0xe0
[  285.402075]  ? nmi_panic_self_stop+0x30/0x30
[  285.406839]  device_unregister+0x16/0x70
[  285.411216]  device_destroy+0x3a/0x40
[  285.415302]  msr_device_destroy+0x19/0x20
[  285.419776]  cpuhp_invoke_callback+0xad/0x590
[  285.424639]  ? __padata_remove_cpu.part.8+0x90/0x90
[  285.430073]  cpuhp_thread_fun+0xc6/0x160
[  285.434449]  smpboot_thread_fn+0xfe/0x150
[  285.438923]  kthread+0xf5/0x130
[  285.442428]  ? sort_range+0x20/0x20
[  285.446319]  ? kthread_associate_blkcg+0x90/0x90
[  285.451472]  ret_from_fork+0x32/0x40
[  285.455461] Code: ff 80 8b 9c 08 00 00 04 e9 2b ff ff ff 0f ff e9 c7 fe ff ff f7 83 84 00 00 00 fd ff ff ff 0f 84 d1 fe ff ff 0f ff e9 ca fe ff ff <0f> ff e9 d9 fe ff ff 0f 1f 44 00 00 0f 1f 44 00 00 41 55 49 89 
[  285.476554] ---[ end trace 5a3846fe48038f5e ]---
[  285.481707] ------------[ cut here ]------------
[  285.486857] sched: Unexpected reschedule of offline CPU#0!
[  285.492979] WARNING: CPU: 1 PID: 14 at arch/x86/kernel/smp.c:128 native_smp_send_reschedule+0x36/0x40
[  285.503267] Modules linked in: acpi_cpufreq(+) sunrpc vfat fat intel_rapl sb_edac btrfs x86_pkg_temp_thermal intel_powerclamp coretemp xor kvm_intel kvm zstd_decompress irqbypass zstd_compress xxhash crct10dif_pclmul ipmi_ssif crc32_pclmul ghash_clmulni_intel pcbc iTCO_wdt aesni_intel iTCO_vendor_support crypto_simd glue_helper raid6_pq ipmi_si cryptd mxm_wmi dcdbas ipmi_devintf pcspkr ipmi_msghandler sg mei_me lpc_ich mei shpchp acpi_power_meter wmi dm_multipath ip_tables xfs libcrc32c sd_mod mgag200 i2c_algo_bit drm_kms_helper syscopyarea sysfillrect sysimgblt fb_sys_fops ttm drm ahci libahci nvme libata tg3 crc32c_intel nvme_core megaraid_sas i2c_core ptp pps_core dm_mirror dm_region_hash dm_log dm_mod
[  285.573036] CPU: 1 PID: 14 Comm: cpuhp/1 Tainted: G      D W        4.15.0-rc8 #1
[  285.581385] Hardware name: Dell Inc. PowerEdge R730xd/072T6D, BIOS 2.5.5 08/16/2017
[  285.589930] RIP: 0010:native_smp_send_reschedule+0x36/0x40
[  285.596050] RSP: 0018:ffff957cbfc03d18 EFLAGS: 00010086
[  285.601879] RAX: 0000000000000000 RBX: ffff957cb246dd00 RCX: 0000000000000006
[  285.609841] RDX: 0000000000000000 RSI: 0000000000000096 RDI: ffff957cbfc16870
[  285.617804] RBP: 0000000000022240 R08: 0000000000000000 R09: 00000000000006fa
[  285.625766] R10: 0000000000000000 R11: ffff957cbfc03a80 R12: ffff957cb246e89c
[  285.633728] R13: 0000000000000004 R14: 0000000000000046 R15: 0000000000000000
[  285.641691] FS:  0000000000000000(0000) GS:ffff957cbfc00000(0000) knlGS:0000000000000000
[  285.650721] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  285.657131] CR2: 00007f46dc730000 CR3: 00000003eb80a001 CR4: 00000000001606e0
[  285.665093] Call Trace:
[  285.667821]  <IRQ>
[  285.670066]  try_to_wake_up+0x3cb/0x440
[  285.674345]  ? account_entity_enqueue+0xc5/0xf0
[  285.679399]  __wake_up_common+0x8a/0x150
[  285.683775]  ep_poll_callback+0xc9/0x2f0
[  285.688151]  __wake_up_common+0x8a/0x150
[  285.692527]  __wake_up_common_lock+0x7a/0xc0
[  285.697294]  irq_work_run_list+0x46/0x70
[  285.701669]  ? tick_sched_do_timer+0x60/0x60
[  285.706434]  update_process_times+0x3b/0x50
[  285.711102]  tick_sched_handle+0x26/0x60
[  285.715477]  tick_sched_timer+0x34/0x70
[  285.719755]  __hrtimer_run_queues+0xdc/0x220
[  285.724519]  hrtimer_interrupt+0x99/0x190
[  285.728993]  smp_apic_timer_interrupt+0x56/0x120
[  285.734145]  apic_timer_interrupt+0xa2/0xb0
[  285.738810]  </IRQ>
[  285.741150] RIP: 0010:panic+0x1fa/0x23c
[  285.745427] RSP: 0018:ffffafec00197ad8 EFLAGS: 00000246 ORIG_RAX: ffffffffffffff11
[  285.753876] RAX: 0000000000000034 RBX: 0000000000000200 RCX: 0000000000000006
[  285.761839] RDX: 0000000000000000 RSI: 0000000000000086 RDI: ffff957cbfc16870
[  285.769801] RBP: ffffafec00197b48 R08: 0000000000000000 R09: 00000000000006ac
[  285.777764] R10: 0000000000000000 R11: ffffafec00197848 R12: ffffffffa104ae70
[  285.785726] R13: 0000000000000000 R14: 0000000000000000 R15: ffffffffa104a6e9
[  285.793692]  ? panic+0x1f3/0x23c
[  285.797293]  oops_end+0xaf/0xc0
[  285.800796]  do_trap+0x13d/0x150
[  285.804398]  do_error_trap+0xc1/0x120
[  285.808485]  ? kfree+0x15b/0x170
[  285.812085]  ? __switch_to+0xa8/0x4f0
[  285.816169]  ? kernfs_put+0x71/0x190
[  285.820159]  invalid_op+0x22/0x40
[  285.823857] RIP: 0010:kfree+0x15b/0x170
[  285.828134] RSP: 0018:ffffafec00197d28 EFLAGS: 00010246
[  285.833963] RAX: dead000000000100 RBX: ffff957b47000000 RCX: ffff957cb70f2b40
[  285.841926] RDX: 00006a8740000000 RSI: ffff957b47371ea0 RDI: ffff957b47000000
[  285.849888] RBP: ffff957cb34b2a18 R08: ffff957cb70f2b40 R09: ffff957ab2cafab8
[  285.857851] R10: ffff9579ce508bc8 R11: fffff1908c1c0000 R12: ffffffffa04cf6c1
[  285.865813] R13: 0000000000000000 R14: ffff9579cfd02df0 R15: 0000000000000084
[  285.873775]  ? kernfs_put+0x71/0x190
[  285.877763]  kernfs_put+0x71/0x190
[  285.881557]  ? nmi_panic_self_stop+0x30/0x30
[  285.886321]  __kernfs_remove+0xf7/0x1f0
[  285.890601]  ? kernfs_name_hash+0x12/0x80
[  285.895074]  kernfs_remove_by_name_ns+0x3e/0x80
[  285.900130]  device_del+0x8f/0x310
[  285.903924]  ? class_find_device+0x91/0xe0
[  285.908494]  ? nmi_panic_self_stop+0x30/0x30
[  285.913260]  device_unregister+0x16/0x70
[  285.917636]  device_destroy+0x3a/0x40
[  285.921721]  msr_device_destroy+0x19/0x20
[  285.926194]  cpuhp_invoke_callback+0xad/0x590
[  285.931055]  ? __padata_remove_cpu.part.8+0x90/0x90
[  285.936497]  cpuhp_thread_fun+0xc6/0x160
[  285.940872]  smpboot_thread_fn+0xfe/0x150
[  285.945347]  kthread+0xf5/0x130
[  285.948849]  ? sort_range+0x20/0x20
[  285.952742]  ? kthread_associate_blkcg+0x90/0x90
[  285.957895]  ret_from_fork+0x32/0x40
[  285.961881] Code: b1 62 1c 01 0f 92 c0 84 c0 74 12 48 8b 05 43 db eb 00 be fd 00 00 00 48 8b 40 30 ff e0 89 fe 48 c7 c7 78 29 05 a1 e8 ba c4 03 00 <0f> ff c3 0f 1f 80 00 00 00 00 0f 1f 44 00 00 53 be 20 00 08 01 
[  285.982972] ---[ end trace 5a3846fe48038f5f ]---
[  285.988126] ------------[ cut here ]------------
[  285.993268] sched: Unexpected reschedule of offline CPU#3!
[  285.999391] WARNING: CPU: 1 PID: 14 at arch/x86/kernel/smp.c:128 native_smp_send_reschedule+0x36/0x40
[  286.009681] Modules linked in: acpi_cpufreq(+) sunrpc vfat fat intel_rapl sb_edac btrfs x86_pkg_temp_thermal intel_powerclamp coretemp xor kvm_intel kvm zstd_decompress irqbypass zstd_compress xxhash crct10dif_pclmul ipmi_ssif crc32_pclmul ghash_clmulni_intel pcbc iTCO_wdt aesni_intel iTCO_vendor_support crypto_simd glue_helper raid6_pq ipmi_si cryptd mxm_wmi dcdbas ipmi_devintf pcspkr ipmi_msghandler sg mei_me lpc_ich mei shpchp acpi_power_meter wmi dm_multipath ip_tables xfs libcrc32c sd_mod mgag200 i2c_algo_bit drm_kms_helper syscopyarea sysfillrect sysimgblt fb_sys_fops ttm drm ahci libahci nvme libata tg3 crc32c_intel nvme_core megaraid_sas i2c_core ptp pps_core dm_mirror dm_region_hash dm_log dm_mod
[  286.079448] CPU: 1 PID: 14 Comm: cpuhp/1 Tainted: G      D W        4.15.0-rc8 #1
[  286.087797] Hardware name: Dell Inc. PowerEdge R730xd/072T6D, BIOS 2.5.5 08/16/2017
[  286.096342] RIP: 0010:native_smp_send_reschedule+0x36/0x40
[  286.102462] RSP: 0018:ffff957cbfc03ed0 EFLAGS: 00010086
[  286.108293] RAX: 0000000000000000 RBX: ffff957cbfc22240 RCX: 0000000000000006
[  286.116255] RDX: 0000000000000000 RSI: 0000000000000086 RDI: ffff957cbfc16870
[  286.124217] RBP: ffff957cbfc22240 R08: 0000000000000000 R09: 0000000000000748
[  286.132180] R10: 0000000000000000 R11: ffff957cbfc03c38 R12: 0000000000000001
[  286.140141] R13: ffff957b4718c5c0 R14: 0000000000000001 R15: ffff957cbfc1ce80
[  286.148104] FS:  0000000000000000(0000) GS:ffff957cbfc00000(0000) knlGS:0000000000000000
[  286.157133] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  286.163543] CR2: 00007f46dc730000 CR3: 00000003eb80a001 CR4: 00000000001606e0
[  286.171505] Call Trace:
[  286.174231]  <IRQ>
[  286.176476]  scheduler_tick+0xa4/0xd0
[  286.180563]  ? tick_sched_do_timer+0x60/0x60
[  286.185327]  update_process_times+0x40/0x50
[  286.189993]  tick_sched_handle+0x26/0x60
[  286.194368]  tick_sched_timer+0x34/0x70
[  286.198647]  __hrtimer_run_queues+0xdc/0x220
[  286.203411]  hrtimer_interrupt+0x99/0x190
[  286.207883]  smp_apic_timer_interrupt+0x56/0x120
[  286.213033]  apic_timer_interrupt+0xa2/0xb0
[  286.217699]  </IRQ>
[  286.220040] RIP: 0010:panic+0x1fa/0x23c
[  286.224318] RSP: 0018:ffffafec00197ad8 EFLAGS: 00000246 ORIG_RAX: ffffffffffffff11
[  286.232764] RAX: 0000000000000034 RBX: 0000000000000200 RCX: 0000000000000006
[  286.240725] RDX: 0000000000000000 RSI: 0000000000000086 RDI: ffff957cbfc16870
[  286.248688] RBP: ffffafec00197b48 R08: 0000000000000000 R09: 00000000000006ac
[  286.256650] R10: 0000000000000000 R11: ffffafec00197848 R12: ffffffffa104ae70
[  286.264612] R13: 0000000000000000 R14: 0000000000000000 R15: ffffffffa104a6e9
[  286.272578]  ? panic+0x1f3/0x23c
[  286.276179]  oops_end+0xaf/0xc0
[  286.279683]  do_trap+0x13d/0x150
[  286.283283]  do_error_trap+0xc1/0x120
[  286.287370]  ? kfree+0x15b/0x170
[  286.290972]  ? __switch_to+0xa8/0x4f0
[  286.295058]  ? kernfs_put+0x71/0x190
[  286.299045]  invalid_op+0x22/0x40
[  286.302744] RIP: 0010:kfree+0x15b/0x170
[  286.307021] RSP: 0018:ffffafec00197d28 EFLAGS: 00010246
[  286.312850] RAX: dead000000000100 RBX: ffff957b47000000 RCX: ffff957cb70f2b40
[  286.320813] RDX: 00006a8740000000 RSI: ffff957b47371ea0 RDI: ffff957b47000000
[  286.328774] RBP: ffff957cb34b2a18 R08: ffff957cb70f2b40 R09: ffff957ab2cafab8
[  286.336735] R10: ffff9579ce508bc8 R11: fffff1908c1c0000 R12: ffffffffa04cf6c1
[  286.344696] R13: 0000000000000000 R14: ffff9579cfd02df0 R15: 0000000000000084
[  286.352659]  ? kernfs_put+0x71/0x190
[  286.356649]  kernfs_put+0x71/0x190
[  286.360443]  ? nmi_panic_self_stop+0x30/0x30
[  286.365206]  __kernfs_remove+0xf7/0x1f0
[  286.369486]  ? kernfs_name_hash+0x12/0x80
[  286.373958]  kernfs_remove_by_name_ns+0x3e/0x80
[  286.379015]  device_del+0x8f/0x310
[  286.382809]  ? class_find_device+0x91/0xe0
[  286.387378]  ? nmi_panic_self_stop+0x30/0x30
[  286.392142]  device_unregister+0x16/0x70
[  286.396518]  device_destroy+0x3a/0x40
[  286.400602]  msr_device_destroy+0x19/0x20
[  286.405075]  cpuhp_invoke_callback+0xad/0x590
[  286.409936]  ? __padata_remove_cpu.part.8+0x90/0x90
[  286.415379]  cpuhp_thread_fun+0xc6/0x160
[  286.419754]  smpboot_thread_fn+0xfe/0x150
[  286.424227]  kthread+0xf5/0x130
[  286.427730]  ? sort_range+0x20/0x20
[  286.431621]  ? kthread_associate_blkcg+0x90/0x90
[  286.436774]  ret_from_fork+0x32/0x40
[  286.440763] Code: b1 62 1c 01 0f 92 c0 84 c0 74 12 48 8b 05 43 db eb 00 be fd 00 00 00 48 8b 40 30 ff e0 89 fe 48 c7 c7 78 29 05 a1 e8 ba c4 03 00 <0f> ff c3 0f 1f 80 00 00 00 00 0f 1f 44 00 00 53 be 20 00 08 01 
[  286.461854] ---[ end trace 5a3846fe48038f60 ]---



Best Regards,
  Yi Zhang


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
