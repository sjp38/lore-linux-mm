Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 80C236B0007
	for <linux-mm@kvack.org>; Thu, 19 Apr 2018 01:50:21 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id n5so1068750pgq.3
        for <linux-mm@kvack.org>; Wed, 18 Apr 2018 22:50:21 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id d6si2420991pgn.48.2018.04.18.22.50.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Apr 2018 22:50:20 -0700 (PDT)
Date: Thu, 19 Apr 2018 13:49:41 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: WARNING: stack going in the wrong direction?
 ip=__schedule+0x489/0x830
Message-ID: <20180419054941.hpmfbyybqhlscghh@wfg-t540p.sh.intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="55egzavp6tupoytm"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Luca Abeni <luca.abeni@santannapisa.it>, Nicolas Pitre <nicolas.pitre@linaro.org>, "Steven Rostedt (VMware)" <rostedt@goodmis.org>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, linux-kernel@vger.kernel.org, lkp@01.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, =?utf-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Huang Ying <ying.huang@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Minchan Kim <minchan@kernel.org>, Hugh Dickins <hughd@google.com>


--55egzavp6tupoytm
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hello,

FYI this warning dates back to v4.16-rc5 . It's rather rare and often
happen together with other errors. For example,

[  168.976238] perf: interrupt took too long (10016 > 9973), lowering kernel.perf_event_max_sample_rate to 19000
[  171.793224] WARNING: stack going in the wrong direction? ip=__schedule+0x489/0x830
[  225.573912] BUG: Bad page map in process sort  pte:00000002 pmd:1b6303067
[  225.574302] addr:00000000efb51519 vm_flags:00000070 anon_vma:          (null) mapping:00000000c7c7d07a index:12f

[  171.556542] perf: interrupt took too long (9849 > 9811), lowering kernel.perf_event_max_sample_rate to 20000
[  172.667037] WARNING: stack going in the wrong direction? ip=sched_slice+0x51/0xa0
[  350.325279] BUG: Bad page map in process wc  pte:00000002 pmd:167b93067
[  350.325595] addr:0000000006ece489 vm_flags:00000070 anon_vma:          (null) mapping:00000000e8941173 index:1cd

[  133.751073] WARNING: stack going in the wrong direction? ip=__schedule+0x489/0x830
[  134.048965] perf: interrupt took too long (9682 > 9626), lowering kernel.perf_event_max_sample_rate to 20000
[  134.472390] perf: interrupt took too long (12178 > 12102), lowering kernel.perf_event_max_sample_rate to 16000
[  234.324541] 2018-04-17 16:08:50 umount /fs/pmem0
[  234.324546]
[  240.185400] WARNING: CPU: 0 PID: 6954 at kernel/workqueue.c:4142 destroy_workqueue+0x64/0x1e0

[  174.376074] perf: interrupt took too long (7722 > 7721), lowering kernel.perf_event_max_sample_rate to 25000
[  178.761072] WARNING: stack going in the wrong direction? ip=__schedule+0x489/0x830
[  304.683193] usemem invoked oom-killer: gfp_mask=0x15080c0(GFP_KERNEL_ACCOUNT|__GFP_ZERO), nodemask=(null), order=0, oom_score_adj=0

[   43.869050] perf: interrupt took too long (6180 > 6147), lowering kernel.perf_event_max_sample_rate to 32000
[   48.272805] perf: interrupt took too long (7733 > 7725), lowering kernel.perf_event_max_sample_rate to 25000
[   49.568211] WARNING: stack going in the wrong direction? ip=__slab_free+0x14b/0x2c0
[   53.576116] perf: page allocation failure: order:2, mode:0x108c020(GFP_ATOMIC|__GFP_COMP|__GFP_ZERO), nodemask=(null)

[  168.465169] perf: interrupt took too long (5016 > 4992), lowering kernel.perf_event_max_sample_rate to 39000
[  168.529886] perf: interrupt took too long (6301 > 6270), lowering kernel.perf_event_max_sample_rate to 31000
[  168.657802] perf: interrupt took too long (7979 > 7876), lowering kernel.perf_event_max_sample_rate to 25000
[  168.976238] perf: interrupt took too long (10016 > 9973), lowering kernel.perf_event_max_sample_rate to 19000
[  171.793224] WARNING: stack going in the wrong direction? ip=__schedule+0x489/0x830:
						perf_sw_event_sched at include/linux/perf_event.h:1062
						 (inlined by) perf_event_task_sched_out at include/linux/perf_event.h:1100
						 (inlined by) prepare_task_switch at kernel/sched/core.c:2636
						 (inlined by) context_switch at kernel/sched/core.c:2813
						 (inlined by) __schedule at kernel/sched/core.c:3490
[  225.573912] BUG: Bad page map in process sort  pte:00000002 pmd:1b6303067
[  225.574302] addr:00000000efb51519 vm_flags:00000070 anon_vma:          (null) mapping:00000000c7c7d07a index:12f
[  225.574820] file:libpthread-2.23.so fault:filemap_fault mmap:generic_file_mmap readpage:simple_readpage
[  225.575327] CPU: 5 PID: 29228 Comm: sort Not tainted 4.17.0-rc1 #1
[  225.575643] Hardware name: Dell Inc. Studio XPS 8000/0X231R, BIOS A01 08/11/2009
[  225.576038] Call Trace:
[  225.576207]  dump_stack+0x5c/0x7b:
						dump_stack at lib/dump_stack.c:115
[  225.576409]  print_bad_pte+0x1de/0x290:
						print_bad_pte at mm/memory.c:776 (discriminator 12)
[  225.576628]  unmap_page_range+0x803/0xa20:
						zap_pte_range at mm/memory.c:1384
						 (inlined by) zap_pmd_range at mm/memory.c:1441
						 (inlined by) zap_pud_range at mm/memory.c:1470
						 (inlined by) zap_p4d_range at mm/memory.c:1491
						 (inlined by) unmap_page_range at mm/memory.c:1512
[  225.576855]  unmap_vmas+0x4c/0xa0:
						unmap_vmas at mm/memory.c:1586 (discriminator 3)
[  225.577060]  exit_mmap+0x82/0x150:
						constant_test_bit at arch/x86/include/asm/bitops.h:328
						 (inlined by) mm_is_oom_victim at include/linux/oom.h:75
						 (inlined by) exit_mmap at mm/mmap.c:3040
[  225.577263]  mmput+0x67/0x160:
						__mmput at kernel/fork.c:963
						 (inlined by) mmput at kernel/fork.c:983
[  225.577453]  do_exit+0x2a5/0xb80:
						constant_test_bit at arch/x86/include/asm/bitops.h:328
						 (inlined by) test_ti_thread_flag at include/linux/thread_info.h:79
						 (inlined by) exit_mm at kernel/exit.c:545
						 (inlined by) do_exit at kernel/exit.c:852
[  225.577652]  ? __fput+0x18d/0x220:
						__fput at fs/file_table.c:229
[  225.577856]  ? _cond_resched+0x19/0x30:
						_cond_resched at kernel/sched/core.c:4982
[  225.578078]  do_group_exit+0x3a/0xa0:
						__read_once_size at include/linux/compiler.h:188
						 (inlined by) list_empty at include/linux/list.h:203
						 (inlined by) thread_group_empty at include/linux/sched/signal.h:594
						 (inlined by) do_group_exit at kernel/exit.c:953
[  225.578291]  __x64_sys_exit_group+0x14/0x20:
						__x64_sys_exit_group at kernel/exit.c:979
[  225.578528]  do_syscall_64+0x5b/0x180:
						do_syscall_64 at arch/x86/entry/common.c:287
[  225.578745]  entry_SYSCALL_64_after_hwframe+0x44/0xa9:
						entry_SYSCALL_64_after_hwframe at arch/x86/entry/entry_64.S:247
[  225.579017] RIP: 0033:0x7f36a8f501c8
[  225.579230] RSP: 002b:00007ffcf2d32458 EFLAGS: 00000246 ORIG_RAX: 00000000000000e7
[  225.579635] RAX: ffffffffffffffda RBX: 0000000000000000 RCX: 00007f36a8f501c8
[  225.579988] RDX: 0000000000000000 RSI: 000000000000003c RDI: 0000000000000000
[  225.580343] RBP: 00007f36a92308e0 R08: 00000000000000e7 R09: ffffffffffffff98
[  225.580697] R10: 00007f36a9452250 R11: 0000000000000246 R12: 00007f36a92308e0
[  225.581046] R13: 00007f36a9235c40 R14: 0000000000000000 R15: 0000000000000000
[  225.581429] Disabling lock debugging due to kernel taint
[  225.581791] BUG: Bad rss-counter state mm:00000000997e66fa idx:2 val:-1
[  225.602808] general protection fault: 0000 [#1] SMP PTI
[  225.603092] Modules linked in: netconsole sr_mod cdrom sd_mod sg snd_hda_codec_realtek intel_powerclamp snd_hda_codec_generic snd_hda_codec_hdmi coretemp uas snd_hda_intel kvm_intel ata_generic dcdbas pata_acpi snd_hda_codec dell_smm_hwmon snd_hda_core kvm snd_hwdep snd_pcm firewire_ohci irqbypass crc32c_intel usb_storage pcspkr snd_timer serio_raw firewire_core ata_piix crc_itu_t snd i7core_edac soundcore libata shpchp acpi_cpufreq ip_tables broadcom bcm_phy_lib
[  225.604945] CPU: 3 PID: 29384 Comm: tee Tainted: G    B             4.17.0-rc1 #1
[  225.605370] Hardware name: Dell Inc. Studio XPS 8000/0X231R, BIOS A01 08/11/2009
[  225.606395] RIP: 0010:kmem_cache_alloc+0xa0/0x1e0:
						prefetch_freepointer at mm/slub.c:275
						 (inlined by) slab_alloc_node at mm/slub.c:2734
						 (inlined by) slab_alloc at mm/slub.c:2749
						 (inlined by) kmem_cache_alloc at mm/slub.c:2754
[  225.606648] RSP: 0018:ffffc90003f3bc68 EFLAGS: 00010202
[  225.606927] RAX: 0000000000000000 RBX: 0003ffff88018f94 RCX: 00000000004d265b
[  225.607312] RDX: 00000000004d265a RSI: 00000000014080c0 RDI: 0000000000027360
[  225.607665] RBP: ffff88018f94dff2 R08: ffff8801bfce7360 R09: ffff8801b7c44100
[  225.608018] R10: ffffc90003f3bef0 R11: 8080808080808080 R12: 00000000014080c0
[  225.608372] R13: ffffffff813b13f2 R14: ffff8801bf15ac00 R15: ffff8801bf15ac00
[  225.608726] FS:  00007fcfb09a3700(0000) GS:ffff8801bfcc0000(0000) knlGS:0000000000000000
[  225.609151] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  225.609450] CR2: 00007fcfb082a000 CR3: 00000001b7cf6000 CR4: 00000000000006e0
[  225.609803] Call Trace:
[  225.609975]  selinux_file_alloc_security+0x32/0x50:
						file_alloc_security at security/selinux/hooks.c:392
						 (inlined by) selinux_file_alloc_security at security/selinux/hooks.c:3549
[  225.610239]  security_file_alloc+0x22/0x40:
						security_file_alloc at security/security.c:879 (discriminator 19)
[  225.610474]  get_empty_filp+0x8d/0x1b0:
						get_empty_filp at fs/file_table.c:129
[  225.610694]  path_openat+0x2d/0x1710:
						path_openat at fs/namei.c:3478
[  225.610907]  ? page_add_file_rmap+0x13/0x200:
						page_add_file_rmap at mm/rmap.c:1184
[  225.611149]  ? alloc_set_pte+0x25e/0x520:
						set_pte_at at arch/x86/include/asm/paravirt.h:458
						 (inlined by) alloc_set_pte at mm/memory.c:3449
[  225.611376]  ? filemap_map_pages+0x30a/0x320:
						filemap_map_pages at mm/filemap.c:2681
[  225.611616]  do_filp_open+0x8c/0xf0:
						do_filp_open at fs/namei.c:3536
[  225.611825]  ? __handle_mm_fault+0xd69/0x10a0:
						do_fault_around at mm/memory.c:3611
						 (inlined by) do_read_fault at mm/memory.c:3627
						 (inlined by) do_fault at mm/memory.c:3732
						 (inlined by) handle_pte_fault at mm/memory.c:3963
						 (inlined by) __handle_mm_fault at mm/memory.c:4087
[  225.612112]  ? _cond_resched+0x19/0x30:
						_cond_resched at kernel/sched/core.c:4982
[  225.612331]  ? __alloc_fd+0x44/0x180:
						__alloc_fd at fs/file.c:505
[  225.612542]  ? do_sys_open+0x1a6/0x230:
						do_sys_open at fs/open.c:1094
[  225.612758]  do_sys_open+0x1a6/0x230:
						do_sys_open at fs/open.c:1094
[  225.612971]  do_syscall_64+0x5b/0x180:
						do_syscall_64 at arch/x86/entry/common.c:287
[  225.613187]  entry_SYSCALL_64_after_hwframe+0x44/0xa9:
						entry_SYSCALL_64_after_hwframe at arch/x86/entry/entry_64.S:247
[  225.613454] RIP: 0033:0x7fcfb041191c
[  225.613662] RSP: 002b:00007fff8fb09f40 EFLAGS: 00000202 ORIG_RAX: 0000000000000002
[  225.614060] RAX: ffffffffffffffda RBX: 0000000000aca200 RCX: 00007fcfb041191c
[  225.614407] RDX: 0000000000000001 RSI: 0000000000080000 RDI: 0000000000aca1d0
[  225.614756] RBP: 00007fff8fb0a020 R08: 0000000000aca160 R09: 0000000000000300
[  225.615102] R10: 00007fcfb04645b0 R11: 0000000000000202 R12: 0000000000000000
[  225.615449] R13: 0000000000000000 R14: 00007fcfb05512a0 R15: 0000000000000002
[  225.615797] Code: 01 00 00 41 8b 46 20 49 8b 3e 48 8d 4a 01 48 8b 5c 05 00 48 89 e8 65 48 0f c7 0f 0f 94 c0 84 c0 74 ba 48 85 db 74 0b 41 8b 46 20 <48> 8b 04 03 0f 18 08 41 f7 c4 00 80 00 00 0f 85 08 01 00 00 66
[  225.616765] RIP: kmem_cache_alloc+0xa0/0x1e0:
						prefetch_freepointer at mm/slub.c:275
						 (inlined by) slab_alloc_node at mm/slub.c:2734
						 (inlined by) slab_alloc at mm/slub.c:2749
						 (inlined by) kmem_cache_alloc at mm/slub.c:2754 RSP: ffffc90003f3bc68
[  225.617102] ---[ end trace 8032327fef00e4ff ]---
[  225.617353] Kernel panic - not syncing: Fatal exception

Attached the full dmesg and kconfig.

Thanks,
Fengguang

--55egzavp6tupoytm
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="dmesg-nhm-white:20180416174615:x86_64-rhel-7.2:gcc-7:4.17.0-rc1:1"
Content-Transfer-Encoding: quoted-printable

[    0.000000] Command line: ip=3D::::nhm-white::dhcp root=3D/dev/ram0 user=
=3Dlkp job=3D/lkp/scheduled/nhm-white/unixbench-300s-100%-shell1-debian-x86=
_64-2016-08-31.cgz-60cc43fc888428bb2f18f08997432d426a243338-20180416-49036-=
1w11h1c-0.yaml ARCH=3Dx86_64 kconfig=3Dx86_64-rhel-7.2 branch=3Dinternal-de=
vel/devel-hourly-2018041612-internal commit=3D60cc43fc888428bb2f18f08997432=
d426a243338 BOOT_IMAGE=3D/pkg/linux/x86_64-rhel-7.2/gcc-7/60cc43fc888428bb2=
f18f08997432d426a243338/vmlinuz-4.17.0-rc1 max_uptime=3D1500 RESULT_ROOT=3D=
/result/unixbench/300s-100%-shell1/nhm-white/debian-x86_64-2016-08-31.cgz/x=
86_64-rhel-7.2/gcc-7/60cc43fc888428bb2f18f08997432d426a243338/1 LKP_SERVER=
=3Dinn debug apic=3Ddebug sysrq_always_enabled rcupdate.rcu_cpu_stall_timeo=
ut=3D100 net.ifnames=3D0 printk.devkmsg=3Don panic=3D-1 softlockup_panic=3D=
1 nmi_watchdog=3Dpanic oops=3Dpanic load_ramdisk=3D2 prompt_ramdisk=3D0 drb=
d.minor_count=3D8 systemd.log_level=3Derr ignore_loglevel console=3Dtty0 ea=
rlyprintk=3DttyS0,115200 console=3DttyS0,115200 vga=3Dnormal rw
[    0.000000] x86/fpu: x87 FPU will use FXSAVE
[    0.000000] e820: BIOS-provided physical RAM map:
[    0.000000] BIOS-e820: [mem 0x0000000000000100-0x000000000009fbff] usable
[    0.000000] BIOS-e820: [mem 0x000000000009fc00-0x000000000009ffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000000e6000-0x00000000000fffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x00000000bf77ffff] usable
[    0.000000] BIOS-e820: [mem 0x00000000bf780000-0x00000000bf78dfff] ACPI =
data
[    0.000000] BIOS-e820: [mem 0x00000000bf78e000-0x00000000bf7cffff] ACPI =
NVS
[    0.000000] BIOS-e820: [mem 0x00000000bf7d0000-0x00000000bf7dffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000bf7ed000-0x00000000bfffffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000fee00000-0x00000000fee00fff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000ffb00000-0x00000000ffffffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x0000000100000000-0x00000001bfffffff] usable
[    0.000000] debug: ignoring loglevel setting.
[    0.000000] bootconsole [earlyser0] enabled
[    0.000000] NX (Execute Disable) protection: active
[    0.000000] random: fast init done
[    0.000000] SMBIOS 2.5 present.
[    0.000000] DMI: Dell Inc. Studio XPS 8000/0X231R, BIOS A01 08/11/2009
[    0.000000] e820: update [mem 0x00000000-0x00000fff] usable =3D=3D> rese=
rved
[    0.000000] e820: remove [mem 0x000a0000-0x000fffff] usable
[    0.000000] e820: last_pfn =3D 0x1c0000 max_arch_pfn =3D 0x400000000
[    0.000000] MTRR default type: uncachable
[    0.000000] MTRR fixed ranges enabled:
[    0.000000]   00000-9FFFF write-back
[    0.000000]   A0000-BFFFF uncachable
[    0.000000]   C0000-CFFFF write-protect
[    0.000000]   D0000-DFFFF uncachable
[    0.000000]   E0000-E3FFF write-protect
[    0.000000]   E4000-EBFFF write-through
[    0.000000]   EC000-FFFFF write-protect
[    0.000000] MTRR variable ranges enabled:
[    0.000000]   0 base 1C0000000 mask FC0000000 uncachable
[    0.000000]   1 base 000000000 mask E00000000 write-back
[    0.000000]   2 base 0C0000000 mask FC0000000 uncachable
[    0.000000]   3 disabled
[    0.000000]   4 disabled
[    0.000000]   5 disabled
[    0.000000]   6 disabled
[    0.000000]   7 disabled
[    0.000000] x86/PAT: Configuration [0-7]: WB  WC  UC- UC  WB  WP  UC- WT=
 =20
[    0.000000] e820: update [mem 0xc0000000-0xffffffff] usable =3D=3D> rese=
rved
[    0.000000] e820: last_pfn =3D 0xbf780 max_arch_pfn =3D 0x400000000
[    0.000000] Scan for SMP in [mem 0x00000000-0x000003ff]
[    0.000000] Scan for SMP in [mem 0x0009fc00-0x0009ffff]
[    0.000000] Scan for SMP in [mem 0x000f0000-0x000fffff]
[    0.000000] found SMP MP-table at [mem 0x000ff780-0x000ff78f] mapped at =
[        (ptrval)]
[    0.000000]   mpc: fc850-fc9dc
[    0.000000] Base memory trampoline at [        (ptrval)] 99000 size 24576
[    0.000000] BRK [0x1bef4b000, 0x1bef4bfff] PGTABLE
[    0.000000] BRK [0x1bef4c000, 0x1bef4cfff] PGTABLE
[    0.000000] BRK [0x1bef4d000, 0x1bef4dfff] PGTABLE
[    0.000000] BRK [0x1bef4e000, 0x1bef4efff] PGTABLE
[    0.000000] BRK [0x1bef4f000, 0x1bef4ffff] PGTABLE
[    0.000000] BRK [0x1bef50000, 0x1bef50fff] PGTABLE
[    0.000000] RAMDISK: [mem 0x1a76f7000-0x1bcffffff]
[    0.000000] ACPI: Early table checksum verification disabled
[    0.000000] ACPI: RSDP 0x00000000000F9860 000024 (v02 ACPIAM)
[    0.000000] ACPI: XSDT 0x00000000BF780100 00006C (v01 DELL   FX09     20=
090811 MSFT 00000097)
[    0.000000] ACPI: FACP 0x00000000BF780290 0000F4 (v04 DELL   FX09     20=
090811 MSFT 00000097)
[    0.000000] ACPI BIOS Warning (bug): 32/64X length mismatch in FADT/Gpe0=
Block: 128/64 (20180313/tbfadt-569)
[    0.000000] ACPI: DSDT 0x00000000BF780660 005B67 (v02 1AAAA  1AAAA000 00=
000000 INTL 20051117)
[    0.000000] ACPI: FACS 0x00000000BF78E000 000040
[    0.000000] ACPI: APIC 0x00000000BF780390 00008C (v02 DELL   FX09     20=
090811 MSFT 00000097)
[    0.000000] ACPI: MCFG 0x00000000BF780420 00003C (v01 DELL   OEMMCFG  20=
090811 MSFT 00000097)
[    0.000000] ACPI: SLIC 0x00000000BF780460 000176 (v01 DELL   FX09     20=
090811 MSFT 00000097)
[    0.000000] ACPI: OSFR 0x00000000BF7805E0 000080 (v01 DELL   FX09     20=
090811 MSFT 00000097)
[    0.000000] ACPI: OEMB 0x00000000BF78E040 000072 (v01 DELL   FX09     20=
090811 MSFT 00000097)
[    0.000000] ACPI: HPET 0x00000000BF78A660 000038 (v01 DELL   OEMHPET  20=
090811 MSFT 00000097)
[    0.000000] ACPI: GSCI 0x00000000BF78E0C0 002024 (v01 DELL   GMCHSCI  20=
090811 MSFT 00000097)
[    0.000000] ACPI: SSDT 0x00000000BF792DD0 000363 (v01 DpgPmm CpuPm    00=
000012 INTL 20051117)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to ffffffffff5fc000 (        fee00000)
[    0.000000] No NUMA configuration found
[    0.000000] Faking a node at [mem 0x0000000000000000-0x00000001bfffffff]
[    0.000000] NODE_DATA(0) allocated [mem 0x1bffd2000-0x1bfffcfff]
[    0.000000] cma: Reserved 200 MiB at 0x000000019ac00000
[    0.000000] tsc: Fast TSC calibration using PIT
[    0.000000] Zone ranges:
[    0.000000]   DMA      [mem 0x0000000000001000-0x0000000000ffffff]
[    0.000000]   DMA32    [mem 0x0000000001000000-0x00000000ffffffff]
[    0.000000]   Normal   [mem 0x0000000100000000-0x00000001bfffffff]
[    0.000000]   Device   empty
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x0000000000001000-0x000000000009efff]
[    0.000000]   node   0: [mem 0x0000000000100000-0x00000000bf77ffff]
[    0.000000]   node   0: [mem 0x0000000100000000-0x00000001bfffffff]
[    0.000000] Initmem setup node 0 [mem 0x0000000000001000-0x00000001bffff=
fff]
[    0.000000] On node 0 totalpages: 1570590
[    0.000000]   DMA zone: 64 pages used for memmap
[    0.000000]   DMA zone: 21 pages reserved
[    0.000000]   DMA zone: 3998 pages, LIFO batch:0
[    0.000000]   DMA32 zone: 12190 pages used for memmap
[    0.000000]   DMA32 zone: 780160 pages, LIFO batch:31
[    0.000000]   Normal zone: 12288 pages used for memmap
[    0.000000]   Normal zone: 786432 pages, LIFO batch:31
[    0.000000] Reserved but unavailable: 98 pages
[    0.000000] ACPI: PM-Timer IO Port: 0x808
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] IOAPIC[0]: apic_id 8, version 32, address 0xfec00000, GSI 0-=
23
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 00, APIC ID 8, APIC =
INT 02
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 09, APIC ID 8, APIC =
INT 09
[    0.000000] ACPI: IRQ0 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 01, APIC ID 8, APIC =
INT 01
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 03, APIC ID 8, APIC =
INT 03
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 04, APIC ID 8, APIC =
INT 04
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 05, APIC ID 8, APIC =
INT 05
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 06, APIC ID 8, APIC =
INT 06
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 07, APIC ID 8, APIC =
INT 07
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 08, APIC ID 8, APIC =
INT 08
[    0.000000] ACPI: IRQ9 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0a, APIC ID 8, APIC =
INT 0a
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0b, APIC ID 8, APIC =
INT 0b
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0c, APIC ID 8, APIC =
INT 0c
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0d, APIC ID 8, APIC =
INT 0d
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0e, APIC ID 8, APIC =
INT 0e
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0f, APIC ID 8, APIC =
INT 0f
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] ACPI: HPET id: 0xffffffff base: 0xfed00000
[    0.000000] smpboot: Allowing 8 CPUs, 0 hotplug CPUs
[    0.000000] mapped IOAPIC to ffffffffff5fb000 (fec00000)
[    0.000000] PM: Registered nosave memory: [mem 0x00000000-0x00000fff]
[    0.000000] PM: Registered nosave memory: [mem 0x0009f000-0x0009ffff]
[    0.000000] PM: Registered nosave memory: [mem 0x000a0000-0x000e5fff]
[    0.000000] PM: Registered nosave memory: [mem 0x000e6000-0x000fffff]
[    0.000000] PM: Registered nosave memory: [mem 0xbf780000-0xbf78dfff]
[    0.000000] PM: Registered nosave memory: [mem 0xbf78e000-0xbf7cffff]
[    0.000000] PM: Registered nosave memory: [mem 0xbf7d0000-0xbf7dffff]
[    0.000000] PM: Registered nosave memory: [mem 0xbf7e0000-0xbf7ecfff]
[    0.000000] PM: Registered nosave memory: [mem 0xbf7ed000-0xbfffffff]
[    0.000000] PM: Registered nosave memory: [mem 0xc0000000-0xfedfffff]
[    0.000000] PM: Registered nosave memory: [mem 0xfee00000-0xfee00fff]
[    0.000000] PM: Registered nosave memory: [mem 0xfee01000-0xffafffff]
[    0.000000] PM: Registered nosave memory: [mem 0xffb00000-0xffffffff]
[    0.000000] e820: [mem 0xc0000000-0xfedfffff] available for PCI devices
[    0.000000] Booting paravirtualized kernel on bare hardware
[    0.000000] clocksource: refined-jiffies: mask: 0xffffffff max_cycles: 0=
xffffffff, max_idle_ns: 1910969940391419 ns
[    0.000000] setup_percpu: NR_CPUS:8192 nr_cpumask_bits:8 nr_cpu_ids:8 nr=
_node_ids:1
[    0.000000] percpu: Embedded 45 pages/cpu @        (ptrval) s147032 r819=
2 d29096 u262144
[    0.000000] pcpu-alloc: s147032 r8192 d29096 u262144 alloc=3D1*2097152
[    0.000000] pcpu-alloc: [0] 0 1 2 3 4 5 6 7=20
[    0.000000] Built 1 zonelists, mobility grouping on.  Total pages: 15460=
27
[    0.000000] Policy zone: Normal
[    0.000000] Kernel command line: ip=3D::::nhm-white::dhcp root=3D/dev/ra=
m0 user=3Dlkp job=3D/lkp/scheduled/nhm-white/unixbench-300s-100%-shell1-deb=
ian-x86_64-2016-08-31.cgz-60cc43fc888428bb2f18f08997432d426a243338-20180416=
-49036-1w11h1c-0.yaml ARCH=3Dx86_64 kconfig=3Dx86_64-rhel-7.2 branch=3Dinte=
rnal-devel/devel-hourly-2018041612-internal commit=3D60cc43fc888428bb2f18f0=
8997432d426a243338 BOOT_IMAGE=3D/pkg/linux/x86_64-rhel-7.2/gcc-7/60cc43fc88=
8428bb2f18f08997432d426a243338/vmlinuz-4.17.0-rc1 max_uptime=3D1500 RESULT_=
ROOT=3D/result/unixbench/300s-100%-shell1/nhm-white/debian-x86_64-2016-08-3=
1.cgz/x86_64-rhel-7.2/gcc-7/60cc43fc888428bb2f18f08997432d426a243338/1 LKP_=
SERVER=3Dinn debug apic=3Ddebug sysrq_always_enabled rcupdate.rcu_cpu_stall=
_timeout=3D100 net.ifnames=3D0 printk.devkmsg=3Don panic=3D-1 softlockup_pa=
nic=3D1 nmi_watchdog=3Dpanic oops=3Dpanic load_ramdisk=3D2 prompt_ramdisk=
=3D0 drbd.minor_count=3D8 systemd.log_level=3Derr ignore_loglevel console=
=3Dtty0 earlyprintk=3DttyS0,115200 console=3DttyS0,115200 vga=3Dnormal rw
[    0.000000] sysrq: sysrq always enabled.
[    0.000000] Memory: 5526152K/6282360K available (12300K kernel code, 259=
2K rwdata, 4168K rodata, 2384K init, 2472K bss, 551408K reserved, 204800K c=
ma-reserved)
[    0.000000] SLUB: HWalign=3D64, Order=3D0-3, MinObjects=3D0, CPUs=3D8, N=
odes=3D1
[    0.000000] Kernel/User page tables isolation: enabled
[    0.000000] ftrace: allocating 39726 entries in 156 pages
[    0.000000] Hierarchical RCU implementation.
[    0.000000] 	RCU restricting CPUs from NR_CPUS=3D8192 to nr_cpu_ids=3D8.
[    0.000000] 	RCU CPU stall warnings timeout set to 100 (rcu_cpu_stall_ti=
meout).
[    0.000000] 	Tasks RCU enabled.
[    0.000000] RCU: Adjusting geometry for rcu_fanout_leaf=3D16, nr_cpu_ids=
=3D8
[    0.000000] NR_IRQS: 524544, nr_irqs: 488, preallocated irqs: 16
[    0.000000] Console: colour VGA+ 80x25
[    0.000000] console [tty0] enabled
[    0.000000] console [ttyS0] enabled
[    0.000000] bootconsole [earlyser0] disabled
[    0.000000] ACPI: Core revision 20180313
[    0.000000] ACPI BIOS Warning (bug): Incorrect checksum in table [OEMB] =
- 0x42, should be 0x28 (20180313/tbprint-177)
[    0.000000] clocksource: hpet: mask: 0xffffffff max_cycles: 0xffffffff, =
max_idle_ns: 133484882848 ns
[    0.000000] hpet clockevent registered
[    0.000000] APIC: Switch to symmetric I/O mode setup
[    0.000000] masked ExtINT on CPU#0
[    0.000000] ENABLING IO-APIC IRQs
[    0.000000] init IO_APIC IRQs
[    0.000000]  apic 8 pin 0 not connected
[    0.000000] IOAPIC[0]: Set routing entry (8-1 -> 0xef -> IRQ 1 Mode:0 Ac=
tive:0 Dest:1)
[    0.000000] IOAPIC[0]: Set routing entry (8-2 -> 0x30 -> IRQ 0 Mode:0 Ac=
tive:0 Dest:1)
[    0.000000] IOAPIC[0]: Set routing entry (8-3 -> 0xef -> IRQ 3 Mode:0 Ac=
tive:0 Dest:1)
[    0.000000] IOAPIC[0]: Set routing entry (8-4 -> 0xef -> IRQ 4 Mode:0 Ac=
tive:0 Dest:1)
[    0.000000] IOAPIC[0]: Set routing entry (8-5 -> 0xef -> IRQ 5 Mode:0 Ac=
tive:0 Dest:1)
[    0.000000] IOAPIC[0]: Set routing entry (8-6 -> 0xef -> IRQ 6 Mode:0 Ac=
tive:0 Dest:1)
[    0.000000] IOAPIC[0]: Set routing entry (8-7 -> 0xef -> IRQ 7 Mode:0 Ac=
tive:0 Dest:1)
[    0.000000] IOAPIC[0]: Set routing entry (8-8 -> 0xef -> IRQ 8 Mode:0 Ac=
tive:0 Dest:1)
[    0.000000] IOAPIC[0]: Set routing entry (8-9 -> 0xef -> IRQ 9 Mode:1 Ac=
tive:0 Dest:1)
[    0.000000] IOAPIC[0]: Set routing entry (8-10 -> 0xef -> IRQ 10 Mode:0 =
Active:0 Dest:1)
[    0.000000] IOAPIC[0]: Set routing entry (8-11 -> 0xef -> IRQ 11 Mode:0 =
Active:0 Dest:1)
[    0.000000] IOAPIC[0]: Set routing entry (8-12 -> 0xef -> IRQ 12 Mode:0 =
Active:0 Dest:1)
[    0.000000] IOAPIC[0]: Set routing entry (8-13 -> 0xef -> IRQ 13 Mode:0 =
Active:0 Dest:1)
[    0.000000] IOAPIC[0]: Set routing entry (8-14 -> 0xef -> IRQ 14 Mode:0 =
Active:0 Dest:1)
[    0.000000] IOAPIC[0]: Set routing entry (8-15 -> 0xef -> IRQ 15 Mode:0 =
Active:0 Dest:1)
[    0.000000]  apic 8 pin 16 not connected
[    0.000000]  apic 8 pin 17 not connected
[    0.000000]  apic 8 pin 18 not connected
[    0.000000]  apic 8 pin 19 not connected
[    0.000000]  apic 8 pin 20 not connected
[    0.000000]  apic 8 pin 21 not connected
[    0.000000]  apic 8 pin 22 not connected
[    0.000000]  apic 8 pin 23 not connected
[    0.000000] ..TIMER: vector=3D0x30 apic1=3D0 pin1=3D2 apic2=3D-1 pin2=3D=
-1
[    0.005000] tsc: Fast TSC calibration using PIT
[    0.006000] tsc: Detected 2926.047 MHz processor
[    0.007000] clocksource: tsc-early: mask: 0xffffffffffffffff max_cycles:=
 0x2a2d609f064, max_idle_ns: 440795245704 ns
[    0.007000] Calibrating delay loop (skipped), value calculated using tim=
er frequency.. 5852.09 BogoMIPS (lpj=3D2926047)
[    0.008001] pid_max: default: 32768 minimum: 301
[    0.008254] Security Framework initialized
[    0.008471] SELinux:  Initializing.
[    0.008676] SELinux:  Starting in permissive mode
[    0.010831] Dentry cache hash table entries: 1048576 (order: 11, 8388608=
 bytes)
[    0.012502] Inode-cache hash table entries: 524288 (order: 10, 4194304 b=
ytes)
[    0.012883] Mount-cache hash table entries: 16384 (order: 5, 131072 byte=
s)
[    0.013039] Mountpoint-cache hash table entries: 16384 (order: 5, 131072=
 bytes)
[    0.013610] CPU: Physical Processor ID: 0
[    0.014001] CPU: Processor Core ID: 0
[    0.014207] mce: CPU supports 9 MCE banks
[    0.014425] CPU0: Thermal monitoring enabled (TM1)
[    0.014673] process: using mwait in idle threads
[    0.014910] Last level iTLB entries: 4KB 512, 2MB 7, 4MB 7
[    0.015001] Last level dTLB entries: 4KB 512, 2MB 32, 4MB 32, 1GB 0
[    0.015302] Spectre V2 : Mitigation: Full generic retpoline
[    0.015657] Freeing SMP alternatives memory: 40K
[    0.017145] Using local APIC timer interrupts.
[    0.017145] calibrating APIC timer ...
[    0.018000] ... lapic delta =3D 831232
[    0.018000] ... PM-Timer delta =3D 357949
[    0.018000] ... PM-Timer result ok
[    0.018000] ..... delta 831232
[    0.018000] ..... mult: 35701142
[    0.018000] ..... calibration result: 132997
[    0.018000] ..... CPU clock speed is 2925.0936 MHz.
[    0.018000] ..... host bus clock speed is 132.0997 MHz.
[    0.018006] smpboot: CPU0: Intel(R) Core(TM) i7 CPU         870  @ 2.93G=
Hz (family: 0x6, model: 0x1e, stepping: 0x5)
[    0.018573] Performance Events: PEBS fmt1+, Nehalem events, 16-deep LBR,=
 Intel PMU driver.
[    0.018994] core: CPU erratum AAJ80 worked around
[    0.019001] core: CPUID marked event: 'bus cycles' unavailable
[    0.019287] ... version:                3
[    0.019502] ... bit width:              48
[    0.019720] ... generic registers:      4
[    0.020001] ... value mask:             0000ffffffffffff
[    0.020265] ... max period:             000000007fffffff
[    0.020601] ... fixed-purpose events:   3
[    0.020816] ... event mask:             000000070000000f
[    0.021041] Hierarchical SRCU implementation.
[    0.022649] NMI watchdog: Enabled. Permanently consumes one hw-PMU count=
er.
[    0.022993] smp: Bringing up secondary CPUs ...
[    0.023083] x86: Booting SMP configuration:
[    0.023305] .... node  #0, CPUs:      #1
[    0.001000] masked ExtINT on CPU#1
[    0.026035]  #2
[    0.001000] masked ExtINT on CPU#2
[    0.027094]  #3
[    0.001000] masked ExtINT on CPU#3
[    0.029093]  #4
[    0.001000] masked ExtINT on CPU#4
[    0.030103]  #5
[    0.001000] masked ExtINT on CPU#5
[    0.032095]  #6
[    0.001000] masked ExtINT on CPU#6
[    0.034095]  #7
[    0.001000] masked ExtINT on CPU#7
[    0.035024] smp: Brought up 1 node, 8 CPUs
[    0.035224] smpboot: Max logical packages: 1
[    0.036002] smpboot: Total of 8 processors activated (46816.75 BogoMIPS)
[    0.037356] devtmpfs: initialized
[    0.038047] x86/mm: Memory block size: 128MB
[    0.039575] Built 1 zonelists, mobility grouping on.  Total pages: 14327=
48
[    0.039900] Policy zone: Normal
[    0.040156] evm: security.selinux
[    0.040344] evm: security.ima
[    0.040519] evm: security.capability
[    0.040733] PM: Registering ACPI NVS region [mem 0xbf78e000-0xbf7cffff] =
(270336 bytes)
[    0.041055] clocksource: jiffies: mask: 0xffffffff max_cycles: 0xfffffff=
f, max_idle_ns: 1911260446275000 ns
[    0.042002] futex hash table entries: 2048 (order: 5, 131072 bytes)
[    0.042366] pinctrl core: initialized pinctrl subsystem
[    0.042717] NET: Registered protocol family 16
[    0.043154] audit: initializing netlink subsys (disabled)
[    0.043427] audit: type=3D2000 audit(1523885184.043:1): state=3Dinitiali=
zed audit_enabled=3D0 res=3D1
[    0.043427] cpuidle: using governor menu
[    0.044179] ACPI FADT declares the system doesn't support PCIe ASPM, so =
disable it
[    0.044562] ACPI: bus type PCI registered
[    0.044777] acpiphp: ACPI Hot Plug PCI Controller Driver version: 0.5
[    0.045057] PCI: MMCONFIG for domain 0000 [bus 00-ff] at [mem 0xe0000000=
-0xefffffff] (base 0xe0000000)
[    0.045507] PCI: not using MMCONFIG
[    0.045703] PCI: Using configuration type 1 for base access
[    0.047037] HugeTLB registered 2.00 MiB page size, pre-allocated 0 pages
[    0.048060] ACPI: Added _OSI(Module Device)
[    0.048282] ACPI: Added _OSI(Processor Device)
[    0.048282] ACPI: Added _OSI(3.0 _SCP Extensions)
[    0.048282] ACPI: Added _OSI(Processor Aggregator Device)
[    0.048512] ACPI: Added _OSI(Linux-Dell-Video)
[    0.052981] ACPI: 2 ACPI AML tables successfully acquired and loaded
[    0.056105] ACPI: Dynamic OEM Table Load:
[    0.056105] ACPI: SSDT 0xFFFF88019342C000 00265C (v01 DpgPmm P001Ist  00=
000011 INTL 20051117)
[    0.058398] ACPI: Dynamic OEM Table Load:
[    0.058618] ACPI: SSDT 0xFFFF880193940800 000678 (v01 PmRef  P001Cst  00=
003001 INTL 20051117)
[    0.059666] ACPI: Interpreter enabled
[    0.059883] ACPI: (supports S0 S3 S4 S5)
[    0.060002] ACPI: Using IOAPIC for interrupt routing
[    0.060286] PCI: MMCONFIG for domain 0000 [bus 00-ff] at [mem 0xe0000000=
-0xefffffff] (base 0xe0000000)
[    0.062716] PCI: MMCONFIG at [mem 0xe0000000-0xefffffff] reserved in ACP=
I motherboard resources
[    0.063005] pmd_set_huge: Cannot satisfy [mem 0xe0000000-0xe0200000] wit=
h a huge-page mapping due to MTRR override.
[    0.064019] PCI: Using host bridge windows from ACPI; if necessary, use =
"pci=3Dnocrs" and report a bug
[    0.064623] ACPI: Enabled 14 GPEs in block 00 to 3F
[    0.071915] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
[    0.072006] acpi PNP0A08:00: _OSC: OS supports [ExtendedConfig ASPM Cloc=
kPM Segments MSI]
[    0.072644] acpi PNP0A08:00: _OSC: platform does not support [PCIeCapabi=
lity]
[    0.073115] acpi PNP0A08:00: _OSC: not requesting control; platform does=
 not support [PCIeCapability]
[    0.073632] acpi PNP0A08:00: _OSC: OS requested [PCIeHotplug PME AER PCI=
eCapability]
[    0.074002] acpi PNP0A08:00: _OSC: platform willing to grant [PCIeHotplu=
g PME AER]
[    0.074384] acpi PNP0A08:00: _OSC failed (AE_SUPPORT); disabling ASPM
[    0.075009] acpi PNP0A08:00: ignoring host bridge window [mem 0x000d0000=
-0x000dffff window] (conflicts with Adapter ROM [mem 0x000cf800-0x000d17ff])
[    0.075831] PCI host bridge to bus 0000:00
[    0.076003] pci_bus 0000:00: root bus resource [io  0x0000-0x0cf7 window]
[    0.076324] pci_bus 0000:00: root bus resource [io  0x0d00-0xffff window]
[    0.076645] pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000bfff=
f window]
[    0.077001] pci_bus 0000:00: root bus resource [mem 0xc0000000-0xdffffff=
f window]
[    0.077379] pci_bus 0000:00: root bus resource [mem 0xf0000000-0xfed8fff=
f window]
[    0.077758] pci_bus 0000:00: root bus resource [bus 00-ff]
[    0.078008] pci 0000:00:00.0: [8086:d131] type 00 class 0x060000
[    0.078419] pci 0000:00:03.0: [8086:d138] type 01 class 0x060400
[    0.078761] pci 0000:00:03.0: PME# supported from D0 D3hot D3cold
[    0.079094] pci 0000:00:08.0: [8086:d155] type 00 class 0x088000
[    0.079498] pci 0000:00:08.1: [8086:d156] type 00 class 0x088000
[    0.080064] pci 0000:00:08.2: [8086:d157] type 00 class 0x088000
[    0.080464] pci 0000:00:08.3: [8086:d158] type 00 class 0x088000
[    0.080855] pci 0000:00:10.0: [8086:d150] type 00 class 0x088000
[    0.081093] pci 0000:00:10.1: [8086:d151] type 00 class 0x088000
[    0.081495] pci 0000:00:1a.0: [8086:3b3c] type 00 class 0x0c0320
[    0.081806] pci 0000:00:1a.0: reg 0x10: [mem 0xfbcfc000-0xfbcfc3ff]
[    0.082076] pci 0000:00:1a.0: PME# supported from D0 D3hot D3cold
[    0.082460] pci 0000:00:1b.0: [8086:3b56] type 00 class 0x040300
[    0.083019] pci 0000:00:1b.0: reg 0x10: [mem 0xfbcf8000-0xfbcfbfff 64bit]
[    0.083405] pci 0000:00:1b.0: PME# supported from D0 D3hot D3cold
[    0.083782] pci 0000:00:1c.0: [8086:3b42] type 01 class 0x060400
[    0.084066] pci 0000:00:1c.0: PME# supported from D0 D3hot D3cold
[    0.084453] pci 0000:00:1c.1: [8086:3b44] type 01 class 0x060400
[    0.084809] pci 0000:00:1c.1: PME# supported from D0 D3hot D3cold
[    0.085093] pci 0000:00:1c.4: [8086:3b4a] type 01 class 0x060400
[    0.085450] pci 0000:00:1c.4: PME# supported from D0 D3hot D3cold
[    0.086025] pci 0000:00:1c.5: [8086:3b4c] type 01 class 0x060400
[    0.086381] pci 0000:00:1c.5: PME# supported from D0 D3hot D3cold
[    0.086769] pci 0000:00:1d.0: [8086:3b34] type 00 class 0x0c0320
[    0.087020] pci 0000:00:1d.0: reg 0x10: [mem 0xfbcf6000-0xfbcf63ff]
[    0.087396] pci 0000:00:1d.0: PME# supported from D0 D3hot D3cold
[    0.087777] pci 0000:00:1e.0: [8086:244e] type 01 class 0x060401
[    0.088122] pci 0000:00:1f.0: [8086:3b02] type 00 class 0x060100
[    0.088590] pci 0000:00:1f.2: [8086:3b20] type 00 class 0x01018f
[    0.089015] pci 0000:00:1f.2: reg 0x10: [io  0xcc00-0xcc07]
[    0.089295] pci 0000:00:1f.2: reg 0x14: [io  0xc880-0xc883]
[    0.089644] pci 0000:00:1f.2: reg 0x18: [io  0xc800-0xc807]
[    0.089924] pci 0000:00:1f.2: reg 0x1c: [io  0xc480-0xc483]
[    0.090006] pci 0000:00:1f.2: reg 0x20: [io  0xc400-0xc40f]
[    0.090286] pci 0000:00:1f.2: reg 0x24: [io  0xc080-0xc08f]
[    0.090665] pci 0000:00:1f.3: [8086:3b30] type 00 class 0x0c0500
[    0.091017] pci 0000:00:1f.3: reg 0x10: [mem 0xfbcff800-0xfbcff8ff 64bit]
[    0.091356] pci 0000:00:1f.3: reg 0x20: [io  0x0400-0x041f]
[    0.091720] pci 0000:00:1f.5: [8086:3b26] type 00 class 0x010185
[    0.092015] pci 0000:00:1f.5: reg 0x10: [io  0xbc00-0xbc07]
[    0.092296] pci 0000:00:1f.5: reg 0x14: [io  0xb880-0xb883]
[    0.092576] pci 0000:00:1f.5: reg 0x18: [io  0xb800-0xb807]
[    0.093006] pci 0000:00:1f.5: reg 0x1c: [io  0xb480-0xb483]
[    0.093286] pci 0000:00:1f.5: reg 0x20: [io  0xb400-0xb40f]
[    0.093567] pci 0000:00:1f.5: reg 0x24: [io  0xb080-0xb08f]
[    0.094015] pci 0000:01:00.0: [1002:954f] type 00 class 0x030000
[    0.094323] pci 0000:01:00.0: reg 0x10: [mem 0xd0000000-0xdfffffff 64bit=
 pref]
[    0.094700] pci 0000:01:00.0: reg 0x18: [mem 0xfbdf0000-0xfbdfffff 64bit]
[    0.095006] pci 0000:01:00.0: reg 0x20: [io  0xd000-0xd0ff]
[    0.095290] pci 0000:01:00.0: reg 0x30: [mem 0xfbdc0000-0xfbddffff pref]
[    0.095642] pci 0000:01:00.0: supports D1 D2
[    0.095906] pci 0000:01:00.1: [1002:aa38] type 00 class 0x040300
[    0.096017] pci 0000:01:00.1: reg 0x10: [mem 0xfbdec000-0xfbdeffff 64bit]
[    0.096395] pci 0000:01:00.1: supports D1 D2
[    0.096669] pci 0000:00:03.0: PCI bridge to [bus 01]
[    0.097003] pci 0000:00:03.0:   bridge window [io  0xd000-0xdfff]
[    0.097299] pci 0000:00:03.0:   bridge window [mem 0xfbd00000-0xfbdfffff]
[    0.097623] pci 0000:00:03.0:   bridge window [mem 0xd0000000-0xdfffffff=
 64bit pref]
[    0.098033] pci 0000:00:1c.0: PCI bridge to [bus 02]
[    0.098287] pci 0000:00:1c.0:   bridge window [io  0x1000-0x1fff]
[    0.098584] pci 0000:00:1c.0:   bridge window [mem 0xc0000000-0xc01fffff]
[    0.099004] pci 0000:00:1c.0:   bridge window [mem 0xc0200000-0xc03fffff=
 64bit pref]
[    0.099440] pci 0000:03:00.0: [1106:3403] type 00 class 0x0c0010
[    0.099762] pci 0000:03:00.0: reg 0x10: [mem 0xfbeff800-0xfbefffff 64bit]
[    0.100011] pci 0000:03:00.0: reg 0x18: [io  0xe800-0xe8ff]
[    0.100384] pci 0000:03:00.0: supports D2
[    0.100600] pci 0000:03:00.0: PME# supported from D2 D3hot D3cold
[    0.104016] pci 0000:00:1c.1: PCI bridge to [bus 03]
[    0.104270] pci 0000:00:1c.1:   bridge window [io  0xe000-0xefff]
[    0.104567] pci 0000:00:1c.1:   bridge window [mem 0xfbe00000-0xfbefffff]
[    0.104891] pci 0000:00:1c.1:   bridge window [mem 0xc0400000-0xc05fffff=
 64bit pref]
[    0.105035] pci 0000:00:1c.4: PCI bridge to [bus 04]
[    0.105358] pci 0000:00:1c.4:   bridge window [io  0x2000-0x2fff]
[    0.105655] pci 0000:00:1c.4:   bridge window [mem 0xc0600000-0xc07fffff]
[    0.106005] pci 0000:00:1c.4:   bridge window [mem 0xc0800000-0xc09fffff=
 64bit pref]
[    0.106443] pci 0000:05:00.0: [14e4:1692] type 00 class 0x020000
[    0.107026] pci 0000:05:00.0: reg 0x10: [mem 0xfbff0000-0xfbffffff 64bit]
[    0.107397] pci 0000:05:00.0: reg 0x30: [mem 0x00000000-0x0000ffff pref]
[    0.107799] pci 0000:05:00.0: PME# supported from D3hot D3cold
[    0.108095] pci 0000:00:1c.5: PCI bridge to [bus 05]
[    0.108350] pci 0000:00:1c.5:   bridge window [mem 0xfbf00000-0xfbffffff]
[    0.108731] pci 0000:00:1e.0: PCI bridge to [bus 06] (subtractive decode)
[    0.109008] pci 0000:00:1e.0:   bridge window [io  0x0000-0x0cf7 window]=
 (subtractive decode)
[    0.109427] pci 0000:00:1e.0:   bridge window [io  0x0d00-0xffff window]=
 (subtractive decode)
[    0.109844] pci 0000:00:1e.0:   bridge window [mem 0x000a0000-0x000bffff=
 window] (subtractive decode)
[    0.110001] pci 0000:00:1e.0:   bridge window [mem 0xc0000000-0xdfffffff=
 window] (subtractive decode)
[    0.110446] pci 0000:00:1e.0:   bridge window [mem 0xf0000000-0xfed8ffff=
 window] (subtractive decode)
[    0.111487] ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 6 7 *10 11 12 14 1=
5), disabled.
[    0.112062] ACPI: PCI Interrupt Link [LNKB] (IRQs *5), disabled.
[    0.112415] ACPI: PCI Interrupt Link [LNKC] (IRQs *3 4 6 7 10 11 12 14 1=
5), disabled.
[    0.113061] ACPI: PCI Interrupt Link [LNKD] (IRQs 3 4 6 7 10 *11 12 14 1=
5), disabled.
[    0.113516] ACPI: PCI Interrupt Link [LNKE] (IRQs 3 4 6 7 10 11 12 14 15=
) *0, disabled.
[    0.113977] ACPI: PCI Interrupt Link [LNKF] (IRQs 3 4 6 7 10 11 12 14 15=
) *0, disabled.
[    0.114061] ACPI: PCI Interrupt Link [LNKG] (IRQs 3 4 6 7 10 11 12 14 *1=
5), disabled.
[    0.114516] ACPI: PCI Interrupt Link [LNKH] (IRQs 3 4 6 7 10 11 12 *14 1=
5), disabled.
[    0.115106] pci 0000:01:00.0: vgaarb: setting as boot VGA device
[    0.115302] pci 0000:01:00.0: vgaarb: VGA device added: decodes=3Dio+mem=
,owns=3Dio+mem,locks=3Dnone
[    0.116002] pci 0000:01:00.0: vgaarb: bridge control possible
[    0.116283] vgaarb: loaded
[    0.116522] SCSI subsystem initialized
[    0.116743] ACPI: bus type USB registered
[    0.117013] usbcore: registered new interface driver usbfs
[    0.117289] usbcore: registered new interface driver hub
[    0.118003] usbcore: registered new device driver usb
[    0.118003] pps_core: LinuxPPS API ver. 1 registered
[    0.118003] pps_core: Software ver. 5.3.6 - Copyright 2005-2007 Rodolfo =
Giometti <giometti@linux.it>
[    0.118444] PTP clock support registered
[    0.119015] EDAC MC: Ver: 3.0.0
[    0.119070] PCI: Using ACPI for IRQ routing
[    0.124996] PCI: Discovered peer bus ff
[    0.125001] PCI: root bus ff: using default resources
[    0.125255] PCI: Probing PCI hardware (bus ff)
[    0.125504] PCI host bridge to bus 0000:ff
[    0.125724] pci_bus 0000:ff: root bus resource [io  0x0000-0xffff]
[    0.126002] pci_bus 0000:ff: root bus resource [mem 0x00000000-0xfffffff=
ff]
[    0.126330] pci_bus 0000:ff: No busn resource found for root bus, will u=
se [bus ff-ff]
[    0.126725] pci_bus 0000:ff: busn_res: can not insert [bus ff] under dom=
ain [bus 00-ff] (conflicts with (null) [bus 00-ff])
[    0.127005] pci 0000:ff:00.0: [8086:2c51] type 00 class 0x060000
[    0.127331] pci 0000:ff:00.1: [8086:2c81] type 00 class 0x060000
[    0.128035] pci 0000:ff:02.0: [8086:2c90] type 00 class 0x060000
[    0.128357] pci 0000:ff:02.1: [8086:2c91] type 00 class 0x060000
[    0.128682] pci 0000:ff:03.0: [8086:2c98] type 00 class 0x060000
[    0.129032] pci 0000:ff:03.1: [8086:2c99] type 00 class 0x060000
[    0.129355] pci 0000:ff:03.4: [8086:2c9c] type 00 class 0x060000
[    0.129679] pci 0000:ff:04.0: [8086:2ca0] type 00 class 0x060000
[    0.130034] pci 0000:ff:04.1: [8086:2ca1] type 00 class 0x060000
[    0.130356] pci 0000:ff:04.2: [8086:2ca2] type 00 class 0x060000
[    0.130679] pci 0000:ff:04.3: [8086:2ca3] type 00 class 0x060000
[    0.131033] pci 0000:ff:05.0: [8086:2ca8] type 00 class 0x060000
[    0.131990] pci 0000:ff:05.1: [8086:2ca9] type 00 class 0x060000
[    0.132032] pci 0000:ff:05.2: [8086:2caa] type 00 class 0x060000
[    0.132355] pci 0000:ff:05.3: [8086:2cab] type 00 class 0x060000
[    0.132685] pci_bus 0000:ff: busn_res: [bus ff] end is updated to ff
[    0.133002] pci_bus 0000:ff: busn_res: can not insert [bus ff] under dom=
ain [bus 00-ff] (conflicts with (null) [bus 00-ff])
[    0.133522] PCI: pci_cache_line_size set to 64 bytes
[    0.134052] e820: reserve RAM buffer [mem 0x0009fc00-0x0009ffff]
[    0.134345] e820: reserve RAM buffer [mem 0xbf780000-0xbfffffff]
[    0.135000] NetLabel: Initializing
[    0.135000] NetLabel:  domain hash size =3D 128
[    0.135001] NetLabel:  protocols =3D UNLABELED CIPSOv4 CALIPSO
[    0.135292] NetLabel:  unlabeled traffic allowed by default
[    0.136198] HPET: 8 timers in total, 5 timers will be used for per-cpu t=
imer
[    0.136198] hpet0: at MMIO 0xfed00000, IRQs 2, 8, 24, 25, 26, 27, 28, 0
[    0.136325] hpet0: 8 comparators, 64-bit 14.318180 MHz counter
[    0.140002] Spurious HPET timer interrupt on HPET timer 2
[    0.140281] hpet: hpet2 irq 24 for MSI
[    0.141000] Spurious HPET timer interrupt on HPET timer 3
[    0.141209] hpet: hpet3 irq 25 for MSI
[    0.141269] Spurious HPET timer interrupt on HPET timer 4
[    0.141269] hpet: hpet4 irq 26 for MSI
[    0.142007] Spurious HPET timer interrupt on HPET timer 5
[    0.142282] hpet: hpet5 irq 27 for MSI
[    0.142282] Spurious HPET timer interrupt on HPET timer 6
[    0.142282] hpet: hpet6 irq 28 for MSI
[    0.143018] clocksource: Switched to clocksource tsc-early
[    0.154808] VFS: Disk quotas dquot_6.6.0
[    0.155040] VFS: Dquot-cache hash table entries: 512 (order 0, 4096 byte=
s)
[    0.155415] pnp: PnP ACPI init
[    0.155663] system 00:00: [mem 0xfc000000-0xfcffffff] has been reserved
[    0.155979] system 00:00: [mem 0xfd000000-0xfdffffff] has been reserved
[    0.156298] system 00:00: [mem 0xfe000000-0xfebfffff] has been reserved
[    0.156615] system 00:00: [mem 0xfed14000-0xfed19fff] has been reserved
[    0.156934] system 00:00: Plug and Play ACPI device, IDs PNP0c01 (active)
[    0.157312] pnp 00:01: Plug and Play ACPI device, IDs PNP0b00 (active)
[    0.157857] system 00:02: [io  0x0a00-0x0a0f] has been reserved
[    0.158150] system 00:02: [io  0x0a10-0x0a1f] has been reserved
[    0.158438] system 00:02: [io  0x0a20-0x0a2f] has been reserved
[    0.158729] system 00:02: [io  0x0a30-0x0a3f] has been reserved
[    0.159021] system 00:02: Plug and Play ACPI device, IDs PNP0c02 (active)
[    0.159514] system 00:03: [io  0x04d0-0x04d1] has been reserved
[    0.159804] system 00:03: [io  0x0800-0x087f] has been reserved
[    0.160096] system 00:03: [io  0x0500-0x057f] has been reserved
[    0.160385] system 00:03: [mem 0xfed1c000-0xfed1ffff] has been reserved
[    0.160701] system 00:03: [mem 0xfed20000-0xfed3ffff] has been reserved
[    0.161017] system 00:03: [mem 0xfed40000-0xfed8ffff] has been reserved
[    0.161335] system 00:03: Plug and Play ACPI device, IDs PNP0c02 (active)
[    0.161760] system 00:04: [mem 0xffc00000-0xffefffff] has been reserved
[    0.162082] system 00:04: Plug and Play ACPI device, IDs PNP0c02 (active)
[    0.162528] system 00:05: [mem 0xfec00000-0xfec00fff] could not be reser=
ved
[    0.162858] system 00:05: [mem 0xfee00000-0xfee00fff] has been reserved
[    0.163179] system 00:05: Plug and Play ACPI device, IDs PNP0c02 (active)
[    0.163566] system 00:06: [mem 0xe0000000-0xefffffff] has been reserved
[    0.163884] system 00:06: Plug and Play ACPI device, IDs PNP0c02 (active)
[    0.164416] system 00:07: [mem 0x00000000-0x0009ffff] could not be reser=
ved
[    0.164749] system 00:07: [mem 0x000c0000-0x000cffff] could not be reser=
ved
[    0.165080] system 00:07: [mem 0x000e0000-0x000fffff] could not be reser=
ved
[    0.165408] system 00:07: [mem 0x00100000-0xbfffffff] could not be reser=
ved
[    0.165738] system 00:07: [mem 0xfed90000-0xffffffff] could not be reser=
ved
[    0.166071] system 00:07: Plug and Play ACPI device, IDs PNP0c01 (active)
[    0.166533] pnp: PnP ACPI: found 8 devices
[    0.172401] clocksource: acpi_pm: mask: 0xffffff max_cycles: 0xffffff, m=
ax_idle_ns: 2085701024 ns
[    0.172869] pci 0000:00:03.0: PCI bridge to [bus 01]
[    0.173125] pci 0000:00:03.0:   bridge window [io  0xd000-0xdfff]
[    0.173421] pci 0000:00:03.0:   bridge window [mem 0xfbd00000-0xfbdfffff]
[    0.173745] pci 0000:00:03.0:   bridge window [mem 0xd0000000-0xdfffffff=
 64bit pref]
[    0.174139] pci 0000:00:1c.0: PCI bridge to [bus 02]
[    0.174392] pci 0000:00:1c.0:   bridge window [io  0x1000-0x1fff]
[    0.174690] pci 0000:00:1c.0:   bridge window [mem 0xc0000000-0xc01fffff]
[    0.175015] pci 0000:00:1c.0:   bridge window [mem 0xc0200000-0xc03fffff=
 64bit pref]
[    0.175406] pci 0000:00:1c.1: PCI bridge to [bus 03]
[    0.175660] pci 0000:00:1c.1:   bridge window [io  0xe000-0xefff]
[    0.175956] pci 0000:00:1c.1:   bridge window [mem 0xfbe00000-0xfbefffff]
[    0.176283] pci 0000:00:1c.1:   bridge window [mem 0xc0400000-0xc05fffff=
 64bit pref]
[    0.176675] pci 0000:00:1c.4: PCI bridge to [bus 04]
[    0.176928] pci 0000:00:1c.4:   bridge window [io  0x2000-0x2fff]
[    0.177229] pci 0000:00:1c.4:   bridge window [mem 0xc0600000-0xc07fffff]
[    0.177553] pci 0000:00:1c.4:   bridge window [mem 0xc0800000-0xc09fffff=
 64bit pref]
[    0.177946] pci 0000:05:00.0: BAR 6: assigned [mem 0xfbf00000-0xfbf0ffff=
 pref]
[    0.178319] pci 0000:00:1c.5: PCI bridge to [bus 05]
[    0.178575] pci 0000:00:1c.5:   bridge window [mem 0xfbf00000-0xfbffffff]
[    0.178901] pci 0000:00:1e.0: PCI bridge to [bus 06]
[    0.179164] pci_bus 0000:00: resource 4 [io  0x0000-0x0cf7 window]
[    0.179462] pci_bus 0000:00: resource 5 [io  0x0d00-0xffff window]
[    0.179761] pci_bus 0000:00: resource 6 [mem 0x000a0000-0x000bffff windo=
w]
[    0.180089] pci_bus 0000:00: resource 7 [mem 0xc0000000-0xdfffffff windo=
w]
[    0.180413] pci_bus 0000:00: resource 8 [mem 0xf0000000-0xfed8ffff windo=
w]
[    0.180738] pci_bus 0000:01: resource 0 [io  0xd000-0xdfff]
[    0.181015] pci_bus 0000:01: resource 1 [mem 0xfbd00000-0xfbdfffff]
[    0.181317] pci_bus 0000:01: resource 2 [mem 0xd0000000-0xdfffffff 64bit=
 pref]
[    0.181686] pci_bus 0000:02: resource 0 [io  0x1000-0x1fff]
[    0.181961] pci_bus 0000:02: resource 1 [mem 0xc0000000-0xc01fffff]
[    0.182267] pci_bus 0000:02: resource 2 [mem 0xc0200000-0xc03fffff 64bit=
 pref]
[    0.182636] pci_bus 0000:03: resource 0 [io  0xe000-0xefff]
[    0.182911] pci_bus 0000:03: resource 1 [mem 0xfbe00000-0xfbefffff]
[    0.183215] pci_bus 0000:03: resource 2 [mem 0xc0400000-0xc05fffff 64bit=
 pref]
[    0.183584] pci_bus 0000:04: resource 0 [io  0x2000-0x2fff]
[    0.183859] pci_bus 0000:04: resource 1 [mem 0xc0600000-0xc07fffff]
[    0.184165] pci_bus 0000:04: resource 2 [mem 0xc0800000-0xc09fffff 64bit=
 pref]
[    0.184534] pci_bus 0000:05: resource 1 [mem 0xfbf00000-0xfbffffff]
[    0.184836] pci_bus 0000:06: resource 4 [io  0x0000-0x0cf7 window]
[    0.185138] pci_bus 0000:06: resource 5 [io  0x0d00-0xffff window]
[    0.185436] pci_bus 0000:06: resource 6 [mem 0x000a0000-0x000bffff windo=
w]
[    0.185761] pci_bus 0000:06: resource 7 [mem 0xc0000000-0xdfffffff windo=
w]
[    0.186160] pci_bus 0000:06: resource 8 [mem 0xf0000000-0xfed8ffff windo=
w]
[    0.186536] pci_bus 0000:ff: resource 4 [io  0x0000-0xffff]
[    0.186811] pci_bus 0000:ff: resource 5 [mem 0x00000000-0xfffffffff]
[    0.187143] NET: Registered protocol family 2
[    0.187579] tcp_listen_portaddr_hash hash table entries: 4096 (order: 4,=
 65536 bytes)
[    0.188012] TCP established hash table entries: 65536 (order: 7, 524288 =
bytes)
[    0.188575] TCP bind hash table entries: 65536 (order: 8, 1048576 bytes)
[    0.189197] TCP: Hash tables configured (established 65536 bind 65536)
[    0.189556] UDP hash table entries: 4096 (order: 5, 131072 bytes)
[    0.189899] UDP-Lite hash table entries: 4096 (order: 5, 131072 bytes)
[    0.190292] NET: Registered protocol family 1
[    0.190622] RPC: Registered named UNIX socket transport module.
[    0.190911] RPC: Registered udp transport module.
[    0.191155] RPC: Registered tcp transport module.
[    0.191396] RPC: Registered tcp NFSv4.1 backchannel transport module.
[    0.191810] IOAPIC[0]: Set routing entry (8-16 -> 0xef -> IRQ 16 Mode:1 =
Active:1 Dest:1)
[    0.192376] IOAPIC[0]: Set routing entry (8-23 -> 0xef -> IRQ 23 Mode:1 =
Active:1 Dest:1)
[    0.192873] pci 0000:01:00.0: Video device with shadowed ROM at [mem 0x0=
00c0000-0x000dffff]
[    0.193291] pci 0000:01:00.1: Linked as a consumer to 0000:01:00.0
[    0.193614] PCI: CLS 32 bytes, default 64
[    0.193884] Unpacking initramfs...
[    5.230049] Freeing initrd memory: 353316K
[    5.230275] PCI-DMA: Using software bounce buffering for IO (SWIOTLB)
[    5.230584] software IO TLB [mem 0xbb780000-0xbf780000] (64MB) mapped at=
 [00000000644dc069-000000001edba9bd]
[    5.232565] Initialise system trusted keyrings
[    5.232826] workingset: timestamp_bits=3D36 max_order=3D21 bucket_order=
=3D0
[    5.234350] zbud: loaded
[    5.235003] 9p: Installing v9fs 9p2000 file system support
[    5.235291] pstore: using deflate compression
[    5.235565] SELinux:  Registering netfilter hooks
[    5.236671] NET: Registered protocol family 38
[    5.236904] Key type asymmetric registered
[    5.237130] Asymmetric key parser 'x509' registered
[    5.237402] Block layer SCSI generic (bsg) driver version 0.4 loaded (ma=
jor 247)
[    5.237805] io scheduler noop registered
[    5.238020] io scheduler deadline registered (default)
[    5.238314] io scheduler cfq registered
[    5.238523] io scheduler mq-deadline registered (default)
[    5.238791] io scheduler kyber registered
[    5.239047] atomic64_test: passed for x86-64 platform with CX8 and with =
SSE
[    5.239555] IOAPIC[0]: Set routing entry (8-16 -> 0xef -> IRQ 16 Mode:1 =
Active:1 Dest:1)
[    5.240069] IOAPIC[0]: Set routing entry (8-17 -> 0xef -> IRQ 17 Mode:1 =
Active:1 Dest:1)
[    5.240813] intel_idle: MWAIT substates: 0x1120
[    5.241054] intel_idle: v0.4.1 model 0x1E
[    5.241481] intel_idle: lapic_timer_reliable_states 0x2
[    5.241807] input: Power Button as /devices/LNXSYSTM:00/LNXSYBUS:00/PNP0=
C0C:00/input/input0
[    5.242232] ACPI: Power Button [PWRB]
[    5.242463] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/inpu=
t/input1
[    5.242847] ACPI: Power Button [PWRF]
[    5.243347] ERST DBG: ERST support is disabled.
[    5.243695] Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
[    5.244691] Non-volatile memory driver v1.3
[    5.244977] Linux agpgart interface v0.103
[    5.246753] rdac: device handler registered
[    5.247736] hp_sw: device handler registered
[    5.247975] emc: device handler registered
[    5.248373] alua: device handler registered
[    5.248606] MACsec IEEE 802.1AE
[    5.248823] libphy: Fixed MDIO Bus: probed
[    5.249148] tg3.c:v3.137 (May 11, 2014)
[    5.252073] libphy: tg3 mdio bus: probed
[    5.314755] Broadcom BCM57780 500:01: attached PHY driver [Broadcom BCM5=
7780] (mii_bus:phy_addr=3D500:01, irq=3DPOLL)
[    5.316431] tg3 0000:05:00.0 eth0: Tigon3 [partno(BCM57780) rev 57780001=
] (PCI Express) MAC address 00:25:64:e8:ea:c9
[    5.316927] tg3 0000:05:00.0 eth0: RXcsums[1] LinkChgREG[0] MIirq[0] ASF=
[0] TSOcap[1]
[    5.317321] tg3 0000:05:00.0 eth0: dma_rwctrl[76180000] dma_mask[64-bit]
[    5.317724] e1000: Intel(R) PRO/1000 Network Driver - version 7.3.21-k8-=
NAPI
[    5.318056] e1000: Copyright (c) 1999-2006 Intel Corporation.
[    5.318346] e1000e: Intel(R) PRO/1000 Network Driver - 3.2.6-k
[    5.318629] e1000e: Copyright(c) 1999 - 2015 Intel Corporation.
[    5.318928] igb: Intel(R) Gigabit Ethernet Network Driver - version 5.4.=
0-k
[    5.319256] igb: Copyright (c) 2007-2014 Intel Corporation.
[    5.319539] ixgbe: Intel(R) 10 Gigabit PCI Express Network Driver - vers=
ion 5.1.0-k
[    5.319922] ixgbe: Copyright (c) 1999-2016 Intel Corporation.
[    5.320407] usbcore: registered new interface driver catc
[    5.320680] usbcore: registered new interface driver kaweth
[    5.320953] pegasus: v0.9.3 (2013/04/25), Pegasus/Pegasus II USB Etherne=
t driver
[    5.321332] usbcore: registered new interface driver pegasus
[    5.321613] usbcore: registered new interface driver rtl8150
[    5.321894] usbcore: registered new interface driver asix
[    5.322165] usbcore: registered new interface driver cdc_ether
[    5.322451] usbcore: registered new interface driver cdc_eem
[    5.322731] usbcore: registered new interface driver dm9601
[    5.323011] usbcore: registered new interface driver smsc75xx
[    5.323296] usbcore: registered new interface driver smsc95xx
[    5.323578] usbcore: registered new interface driver gl620a
[    5.323855] usbcore: registered new interface driver net1080
[    5.324137] usbcore: registered new interface driver plusb
[    5.324410] usbcore: registered new interface driver rndis_host
[    5.324700] usbcore: registered new interface driver cdc_subset
[    5.324989] usbcore: registered new interface driver zaurus
[    5.325268] usbcore: registered new interface driver MOSCHIP usb-etherne=
t driver
[    5.325645] usbcore: registered new interface driver int51x1
[    5.325924] usbcore: registered new interface driver ipheth
[    5.326203] usbcore: registered new interface driver sierra_net
[    5.326595] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
[    5.326909] ehci-pci: EHCI PCI platform driver
[    5.327228] ehci-pci 0000:00:1a.0: EHCI Host Controller
[    5.327588] ehci-pci 0000:00:1a.0: new USB bus registered, assigned bus =
number 1
[    5.327973] ehci-pci 0000:00:1a.0: debug port 2
[    5.332330] ehci-pci 0000:00:1a.0: cache line size of 32 is not supported
[    5.332662] ehci-pci 0000:00:1a.0: irq 16, io mem 0xfbcfc000
[    5.339179] ehci-pci 0000:00:1a.0: USB 2.0 started, EHCI 1.00
[    5.339523] usb usb1: New USB device found, idVendor=3D1d6b, idProduct=
=3D0002, bcdDevice=3D 4.17
[    5.339930] usb usb1: New USB device strings: Mfr=3D3, Product=3D2, Seri=
alNumber=3D1
[    5.340300] usb usb1: Product: EHCI Host Controller
[    5.340547] usb usb1: Manufacturer: Linux 4.17.0-rc1 ehci_hcd
[    5.340827] usb usb1: SerialNumber: 0000:00:1a.0
[    5.341406] hub 1-0:1.0: USB hub found
[    5.341626] hub 1-0:1.0: 2 ports detected
[    5.341993] IOAPIC[0]: Set routing entry (8-23 -> 0xef -> IRQ 23 Mode:1 =
Active:1 Dest:1)
[    5.342420] ehci-pci 0000:00:1d.0: EHCI Host Controller
[    5.342804] ehci-pci 0000:00:1d.0: new USB bus registered, assigned bus =
number 2
[    5.343307] ehci-pci 0000:00:1d.0: debug port 2
[    5.347608] ehci-pci 0000:00:1d.0: cache line size of 32 is not supported
[    5.347943] ehci-pci 0000:00:1d.0: irq 23, io mem 0xfbcf6000
[    5.354180] ehci-pci 0000:00:1d.0: USB 2.0 started, EHCI 1.00
[    5.354510] usb usb2: New USB device found, idVendor=3D1d6b, idProduct=
=3D0002, bcdDevice=3D 4.17
[    5.354942] usb usb2: New USB device strings: Mfr=3D3, Product=3D2, Seri=
alNumber=3D1
[    5.355312] usb usb2: Product: EHCI Host Controller
[    5.355560] usb usb2: Manufacturer: Linux 4.17.0-rc1 ehci_hcd
[    5.355840] usb usb2: SerialNumber: 0000:00:1d.0
[    5.356391] hub 2-0:1.0: USB hub found
[    5.356610] hub 2-0:1.0: 2 ports detected
[    5.356902] ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
[    5.357281] ohci-pci: OHCI PCI platform driver
[    5.357518] uhci_hcd: USB Universal Host Controller Interface driver
[    5.357855] usbcore: registered new interface driver usbserial_generic
[    5.358245] usbserial: USB Serial support registered for generic
[    5.358548] i8042: PNP: No PS/2 controller found.
[    5.358788] i8042: Probing ports directly.
[    5.359554] serio: i8042 KBD port at 0x60,0x64 irq 1
[    5.359818] serio: i8042 AUX port at 0x60,0x64 irq 12
[    5.360481] mousedev: PS/2 mouse device common for all mice
[    5.360903] rtc_cmos 00:01: RTC can wake from S4
[    5.361499] rtc_cmos 00:01: registered as rtc0
[    5.361759] rtc_cmos 00:01: alarms up to one month, y3k, 114 bytes nvram=
, hpet irqs
[    5.362334] IOAPIC[0]: Set routing entry (8-18 -> 0xef -> IRQ 18 Mode:1 =
Active:1 Dest:1)
[    5.362755] i801_smbus 0000:00:1f.3: SMBus using PCI interrupt
[    5.363137] iTCO_wdt: Intel TCO WatchDog Timer Driver v1.11
[    5.363430] iTCO_wdt: Found a P55 TCO device (Version=3D2, TCOBASE=3D0x0=
860)
[    5.363919] iTCO_wdt: initialized. heartbeat=3D30 sec (nowayout=3D0)
[    5.364455] iTCO_vendor_support: vendor-support=3D0
[    5.364814] hidraw: raw HID events driver (C) Jiri Kosina
[    5.365253] usbcore: registered new interface driver usbhid
[    5.365526] usbhid: USB HID core driver
[    5.365791] drop_monitor: Initializing network drop monitor service
[    5.366217] Initializing XFRM netlink socket
[    5.366528] NET: Registered protocol family 10
[    5.367028] Segment Routing with IPv6
[    5.367244] NET: Registered protocol family 17
[    5.367582] 9pnet: Installing 9P2000 support
[    5.368960] microcode: sig=3D0x106e5, pf=3D0x2, revision=3D0x7
[    5.369585] microcode: Microcode Update Driver: v2.2.
[    5.369662] ... APIC ID:      00000000 (0)
[    5.370175] ... APIC VERSION: 00060015
[    5.370397] 000000000000000000000000000000000000000000000000000000000000=
0000
[    5.370658] 000000000000000000000000000000000000000000000000000000000000=
0000
[    5.370658] 000000000001000000000000000000000000000000000000000000002000=
0000
[    5.371480] number of MP IRQ sources: 15.
[    5.371714] number of IO-APIC #8 registers: 24.
[    5.371967] testing the IO APIC.......................
[    5.372304] IO APIC #8......
[    5.372490] .... register #00: 01000000
[    5.372715] .......    : physical APIC id: 01
[    5.372960] .......    : Delivery Type: 0
[    5.373296] .......    : LTS          : 0
[    5.373527] .... register #01: 00170020
[    5.373751] .......     : max redirection entries: 17
[    5.374090] .......     : PRQ implemented: 0
[    5.374332] .......     : IO APIC version: 20
[    5.374577] .... IRQ redirection table:
[    5.374801] IOAPIC 0:
[    5.374968]  pin00, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[    5.375446]  pin01, enabled , edge , high, V(22), IRR(0), S(0), logical =
, D(04), M(0)
[    5.375869]  pin02, enabled , edge , high, V(30), IRR(0), S(0), logical =
, D(01), M(0)
[    5.376399]  pin03, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[    5.376823]  pin04, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[    5.377396]  pin05, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[    5.377820]  pin06, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[    5.378296]  pin07, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[    5.378720]  pin08, enabled , edge , high, V(22), IRR(0), S(0), logical =
, D(08), M(0)
[    5.379198]  pin09, enabled , level, high, V(21), IRR(0), S(0), logical =
, D(02), M(0)
[    5.379621]  pin0a, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[    5.380069]  pin0b, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[    5.380653]  pin0c, enabled , edge , high, V(21), IRR(0), S(0), logical =
, D(80), M(0)
[    5.381081]  pin0d, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[    5.381505]  pin0e, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[    5.381929]  pin0f, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[    5.382406]  pin10, enabled , level, low , V(21), IRR(0), S(0), logical =
, D(20), M(0)
[    5.382830]  pin11, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[    5.383279]  pin12, enabled , level, low , V(22), IRR(0), S(0), logical =
, D(10), M(0)
[    5.383703]  pin13, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[    5.384179]  pin14, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[    5.384603]  pin15, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[    5.385094]  pin16, disabled, edge , high, V(00), IRR(0), S(0), physical=
, D(00), M(0)
[    5.385518]  pin17, enabled , level, low , V(21), IRR(0), S(0), logical =
, D(40), M(0)
[    5.386624] IRQ to pin mappings:
[    5.386824] IRQ0 -> 0:2
[    5.386994] IRQ1 -> 0:1
[    5.387194] IRQ3 -> 0:3
[    5.387364] IRQ4 -> 0:4
[    5.387533] IRQ5 -> 0:5
[    5.387702] IRQ6 -> 0:6
[    5.387871] IRQ7 -> 0:7
[    5.388065] IRQ8 -> 0:8
[    5.388235] IRQ9 -> 0:9
[    5.388404] IRQ10 -> 0:10
[    5.388581] IRQ11 -> 0:11
[    5.388757] IRQ12 -> 0:12
[    5.388933] IRQ13 -> 0:13
[    5.389164] IRQ14 -> 0:14
[    5.389340] IRQ15 -> 0:15
[    5.389517] IRQ16 -> 0:16
[    5.389693] IRQ17 -> 0:17
[    5.389869] IRQ18 -> 0:18
[    5.390112] IRQ23 -> 0:23
[    5.390289] .................................... done.
[    5.390578] sched_clock: Marking stable (5390064964, 0)->(5496656545, -1=
06591581)
[    5.391424] registered taskstats version 1
[    5.391642] Loading compiled-in X.509 certificates
[    5.391901] zswap: loaded using pool lzo/zbud
[    5.394618] Key type big_key registered
[    5.397349] Key type trusted registered
[    5.399998] Key type encrypted registered
[    5.400270] ima: No TPM chip found, activating TPM-bypass! (rc=3D-19)
[    5.400598] ima: Allocated hash algorithm: sha1
[    5.400879] evm: HMAC attrs: 0x1
[    5.401898] rtc_cmos 00:01: setting system clock to 2018-04-16 13:26:29 =
UTC (1523885189)
[    5.433381] IPv6: ADDRCONF(NETDEV_UP): eth0: link is not ready
[    5.665176] usb 1-1: new high-speed USB device number 2 using ehci-pci
[    5.681178] usb 2-1: new high-speed USB device number 2 using ehci-pci
[    5.793627] usb 1-1: New USB device found, idVendor=3D8087, idProduct=3D=
0020, bcdDevice=3D 0.00
[    5.794069] usb 1-1: New USB device strings: Mfr=3D0, Product=3D0, Seria=
lNumber=3D0
[    5.794801] hub 1-1:1.0: USB hub found
[    5.795321] hub 1-1:1.0: 6 ports detected
[    5.809985] usb 2-1: New USB device found, idVendor=3D8087, idProduct=3D=
0020, bcdDevice=3D 0.00
[    5.810410] usb 2-1: New USB device strings: Mfr=3D0, Product=3D0, Seria=
lNumber=3D0
[    5.811318] hub 2-1:1.0: USB hub found
[    5.811710] hub 2-1:1.0: 8 ports detected
[    6.071172] usb 1-1.4: new full-speed USB device number 3 using ehci-pci
[    6.087258] usb 2-1.2: new high-speed USB device number 3 using ehci-pci
[    6.158796] usb 1-1.4: New USB device found, idVendor=3D14dd, idProduct=
=3D1005, bcdDevice=3D 0.00
[    6.159336] usb 1-1.4: New USB device strings: Mfr=3D1, Product=3D2, Ser=
ialNumber=3D3
[    6.159723] usb 1-1.4: Product: D2CIM-VUSB
[    6.159940] usb 1-1.4: Manufacturer: Raritan
[    6.160167] usb 1-1.4: SerialNumber: EFFB212D0A6E2DE
[    6.168114] input: Raritan D2CIM-VUSB as /devices/pci0000:00/0000:00:1a.=
0/usb1/1-1/1-1.4/1-1.4:1.0/0003:14DD:1005.0001/input/input5
[    6.169869] usb 2-1.2: New USB device found, idVendor=3D18e3, idProduct=
=3D9106, bcdDevice=3D 1.00
[    6.170301] usb 2-1.2: New USB device strings: Mfr=3D1, Product=3D2, Ser=
ialNumber=3D3
[    6.170671] usb 2-1.2: Product: Mass Storage Device
[    6.170918] usb 2-1.2: Manufacturer: Generic
[    6.171251] usb 2-1.2: SerialNumber: 18E391066476
[    6.220993] hid-generic 0003:14DD:1005.0001: input,hidraw0: USB HID v1.1=
1 Keyboard [Raritan D2CIM-VUSB] on usb-0000:00:1a.0-1.4/input0
[    6.239156] tsc: Refined TSC clocksource calibration: 2925.981 MHz
[    6.239471] clocksource: tsc: mask: 0xffffffffffffffff max_cycles: 0x2a2=
d228446b, max_idle_ns: 440795275274 ns
[    6.240140] clocksource: Switched to clocksource tsc
[    6.496191] tg3 0000:05:00.0 eth0: Link is down
[    8.544243] tg3 0000:05:00.0 eth0: Link is up at 1000 Mbps, full duplex
[    8.544585] tg3 0000:05:00.0 eth0: Flow control is on for TX and on for =
RX
[    8.547190] IPv6: ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
[    8.559136] Sending DHCP requests ., OK
[    8.825365] IP-Config: Got DHCP answer from 192.168.1.1, my address is 1=
92.168.1.166
[    8.825751] IP-Config: Complete:
[    8.825935]      device=3Deth0, hwaddr=3D00:25:64:e8:ea:c9, ipaddr=3D192=
=2E168.1.166, mask=3D255.255.255.0, gw=3D192.168.1.1
[    8.826633]      host=3Dnhm-white, domain=3Dlkp.intel.com, nis-domain=3D=
(none)
[    8.826949]      bootserver=3D192.168.1.1, rootserver=3D192.168.1.1, roo=
tpath=3D     nameserver0=3D192.168.1.1
[    8.829874] Freeing unused kernel memory: 2384K
[    8.830114] Write protecting the kernel read-only data: 20480k
[    8.831174] Freeing unused kernel memory: 2012K
[    8.835089] Freeing unused kernel memory: 1976K
[    8.835336] rodata_test: all tests were successful
[    8.838684] systemd[1]: RTC configured in localtime, applying delta of 4=
80 minutes to system time.
[    8.971257] shpchp: Standard Hot Plug PCI Controller Driver version: 0.4
[    8.975523] EDAC MC0: Giving out device to module i7core_edac.c controll=
er i7 core #0: DEV 0000:ff:03.0 (INTERRUPT)
[    8.975773] libata version 3.00 loaded.
[    8.976525] EDAC PCI0: Giving out device to module i7core_edac controlle=
r EDAC PCI controller: DEV 0000:ff:03.0 (POLLED)
[    8.977604] ata_piix 0000:00:1f.2: version 2.13
[    8.978027] IOAPIC[0]: Set routing entry (8-19 -> 0xef -> IRQ 19 Mode:1 =
Active:1 Dest:1)
[    8.978184] EDAC i7core: Driver loaded, 1 memory controller(s) found.
[    8.978447] ata_piix 0000:00:1f.2: MAP [ P0 P2 P1 P3 ]
[    8.987348] scsi host0: ata_piix
[    8.992174] scsi host1: ata_piix
[    8.992616] ata1: SATA max UDMA/133 cmd 0xcc00 ctl 0xc880 bmdma 0xc400 i=
rq 19
[    8.992959] ata2: SATA max UDMA/133 cmd 0xc800 ctl 0xc480 bmdma 0xc408 i=
rq 19
[    8.993873] ata_piix 0000:00:1f.5: MAP [ P0 -- P1 -- ]
[    9.001915] input: PC Speaker as /devices/platform/pcspkr/input/input6
[    9.005857] scsi host2: ata_piix
[    9.006186] scsi host3: ata_piix
[    9.006430] ata3: SATA max UDMA/133 cmd 0xbc00 ctl 0xb880 bmdma 0xb400 i=
rq 19
[    9.006776] ata4: SATA max UDMA/133 cmd 0xb800 ctl 0xb480 bmdma 0xb408 i=
rq 19
[    9.007963] dell_smm_hwmon: broken Dell BIOS detected, disallow fan type=
 call
[    9.011383] Error: Driver 'pcspkr' is already registered, aborting...
[    9.012167] usb-storage 2-1.2:1.0: USB Mass Storage device detected
[    9.016883] IOAPIC[0]: Set routing entry (8-22 -> 0xef -> IRQ 22 Mode:1 =
Active:1 Dest:1)
[    9.017587] snd_hda_intel 0000:01:00.1: Handle vga_switcheroo audio clie=
nt
[    9.018731] scsi host4: usb-storage 2-1.2:1.0
[    9.018969] dcdbas dcdbas: Dell Systems Management Base Driver (version =
5.6.0-3.2)
[    9.019072] usbcore: registered new interface driver usb-storage
[    9.019401] kvm: VM_EXIT_LOAD_IA32_PERF_GLOBAL_CTRL does not work proper=
ly. Using workaround
[    9.020691] usbcore: registered new interface driver uas
[    9.036208] snd_hda_codec_realtek hdaudioC0D0: autoconfig for ALC887: li=
ne_outs=3D4 (0x14/0x15/0x16/0x17/0x0) type:line
[    9.036718] snd_hda_codec_realtek hdaudioC0D0:    speaker_outs=3D0 (0x0/=
0x0/0x0/0x0/0x0)
[    9.037128] snd_hda_codec_realtek hdaudioC0D0:    hp_outs=3D1 (0x1b/0x0/=
0x0/0x0/0x0)
[    9.037514] snd_hda_codec_realtek hdaudioC0D0:    mono: mono_out=3D0x0
[    9.037823] snd_hda_codec_realtek hdaudioC0D0:    dig-out=3D0x11/0x1e
[    9.038135] snd_hda_codec_realtek hdaudioC0D0:    inputs:
[    9.038414] snd_hda_codec_realtek hdaudioC0D0:      Front Mic=3D0x19
[    9.038721] snd_hda_codec_realtek hdaudioC0D0:      Rear Mic=3D0x18
[    9.039039] snd_hda_codec_realtek hdaudioC0D0:      Line=3D0x1a
[    9.046061] firewire_ohci 0000:03:00.0: added OHCI v1.10 device as card =
0, 4 IR + 8 IT contexts, quirks 0x11
[    9.047923] input: HDA ATI HDMI HDMI/DP,pcm=3D3 as /devices/pci0000:00/0=
000:00:03.0/0000:01:00.1/sound/card1/input7
[    9.051864] alloc_contig_range: [19ae40, 19ae60) PFNs busy
[    9.061763] input: HDA Intel MID Front Mic as /devices/pci0000:00/0000:0=
0:1b.0/sound/card0/input8
[    9.062354] input: HDA Intel MID Rear Mic as /devices/pci0000:00/0000:00=
:1b.0/sound/card0/input9
[    9.062903] input: HDA Intel MID Line as /devices/pci0000:00/0000:00:1b.=
0/sound/card0/input10
[    9.063439] input: HDA Intel MID Line Out Front as /devices/pci0000:00/0=
000:00:1b.0/sound/card0/input11
[    9.063983] input: HDA Intel MID Line Out Surround as /devices/pci0000:0=
0/0000:00:1b.0/sound/card0/input12
[    9.064532] input: HDA Intel MID Line Out CLFE as /devices/pci0000:00/00=
00:00:1b.0/sound/card0/input13
[    9.065069] input: HDA Intel MID Line Out Side as /devices/pci0000:00/00=
00:00:1b.0/sound/card0/input14
[    9.065573] input: HDA Intel MID Front Headphone as /devices/pci0000:00/=
0000:00:1b.0/sound/card0/input15
[    9.112276] Kernel tests: Boot OK!
[    9.112280]=20
[    9.122855] install debs round one: dpkg -i --force-confdef --force-depe=
nds /opt/deb/debconf_1.5.66_all.deb
[    9.122858]=20
[    9.124954] /opt/deb/libtext-charwidth-perl_0.04-7.1_amd64.deb
[    9.124956]=20
[    9.126728] /opt/deb/libtext-iconv-perl_1.7-5+b6_amd64.deb
[    9.126730]=20
[    9.128277] /opt/deb/perl-base_5.26.1-5_amd64.deb
[    9.128279]=20
[    9.130192] /opt/deb/liblocale-gettext-perl_1.07-3+b3_amd64.deb
[    9.130194]=20
[    9.132014] /opt/deb/perl-modules-5.26_5.26.1-5_all.deb
[    9.132016]=20
[    9.133420] /opt/deb/mime-support_3.60_all.deb
[    9.133422]=20
[    9.135049] /opt/deb/libgdbm-compat4_1.14.1-6_amd64.deb
[    9.135050]=20
[    9.136588] /opt/deb/libperl5.26_5.26.1-5_amd64.deb
[    9.136590]=20
[    9.138741] /opt/deb/libssl1.1_1.1.0h-2_amd64.deb
[    9.138742]=20
[    9.140145] /opt/deb/sysstat_11.6.1-1_amd64.deb
[    9.140147]=20
[    9.141694] /opt/deb/gawk_1%3a4.1.4+dfsg-1_amd64.deb
[    9.141695]=20
[    9.143134] /opt/deb/sysstat_11.6.0-1_amd64.deb
[    9.143136]=20
[    9.145600] (Reading database ... 2202 files and directories currently i=
nstalled.)
[    9.145601]=20
[    9.148012] Preparing to unpack .../opt/deb/debconf_1.5.66_all.deb ...
[    9.148014]=20
[    9.149860] Unpacking debconf (1.5.66) over (1.5.59) ...
[    9.149862]=20
[    9.152349] Preparing to unpack .../libtext-charwidth-perl_0.04-7.1_amd6=
4.deb ...
[    9.152351]=20
[    9.154713] Unpacking libtext-charwidth-perl (0.04-7.1) over (0.04-7+b4)=
 ...
[    9.154714]=20
[    9.157141] Preparing to unpack .../libtext-iconv-perl_1.7-5+b6_amd64.de=
b ...
[    9.157143]=20
[    9.159352] Unpacking libtext-iconv-perl (1.7-5+b6) over (1.7-5+b3) ...
[    9.159354]=20
[    9.161411] Preparing to unpack .../perl-base_5.26.1-5_amd64.deb ...
[    9.161413]=20
[    9.163390] Unpacking perl-base (5.26.1-5) over (5.22.2-3) ...
[    9.163392]=20
[    9.302924] Preparing to unpack .../liblocale-gettext-perl_1.07-3+b3_amd=
64.deb ...
[    9.302928]=20
[    9.305693] Unpacking liblocale-gettext-perl (1.07-3+b3) over (1.07-3) .=
=2E.
[    9.305695]=20
[    9.320121] Selecting previously unselected package perl-modules-5.26.
[    9.320127]=20
[    9.326184] Preparing to unpack .../perl-modules-5.26_5.26.1-5_all.deb .=
=2E.
[    9.326187]=20
[    9.328743] ata3: SATA link down (SStatus 0 SControl 300)
[    9.329068] Unpacking perl-modules-5.26 (5.26.1-5) ...
[    9.329070]=20
[    9.339950] ata4: SATA link down (SStatus 0 SControl 300)
[    9.551205] firewire_core 0000:03:00.0: created device fw0: GUID 0025648=
000e8eac9, S400
[    9.624747] ata1.00: SATA link down (SStatus 0 SControl 300)
[    9.625059] ata1.01: SATA link down (SStatus 0 SControl 300)
[    9.628169] Selecting previously unselected package mime-support.
[    9.628172]=20
[    9.632461] Preparing to unpack .../deb/mime-support_3.60_all.deb ...
[    9.632465]=20
[    9.634494] Unpacking mime-support (3.60) ...
[    9.634496]=20
[    9.649950] Selecting previously unselected package libgdbm-compat4:amd6=
4.
[    9.649954]=20
[    9.653598] Preparing to unpack .../libgdbm-compat4_1.14.1-6_amd64.deb .=
=2E.
[    9.653600]=20
[    9.656396] Unpacking libgdbm-compat4:amd64 (1.14.1-6) ...
[    9.656398]=20
[    9.670194] Selecting previously unselected package libperl5.26:amd64.
[    9.670200]=20
[    9.676974] Preparing to unpack .../libperl5.26_5.26.1-5_amd64.deb ...
[    9.676979]=20
[    9.679600] Unpacking libperl5.26:amd64 (5.26.1-5) ...
[    9.679602]=20
[    9.767120] ata2.00: SATA link up 1.5 Gbps (SStatus 113 SControl 300)
[    9.767444] ata2.01: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
[    9.789253] ata2.00: ATAPI: HL-DT-ST DVD+/-RW GH50N, B102, max UDMA/100
[    9.789811] ata2.01: ATA-8: Hitachi HDT721050SLA360, ST3OA38E, max UDMA/=
133
[    9.790184] ata2.01: 976773168 sectors, multi 16: LBA48 NCQ (depth 0/32)
[    9.812241] ata2.00: configured for UDMA/100
[    9.816108] random: crng init done
[    9.817475] ata2.01: configured for UDMA/133
[    9.826799] scsi 1:0:0:0: CD-ROM            HL-DT-ST DVD+-RW GH50N    B1=
02 PQ: 0 ANSI: 5
[    9.848140] scsi 1:0:1:0: Direct-Access     ATA      Hitachi HDT72105 A3=
8E PQ: 0 ANSI: 5
[    9.850733] scsi 1:0:0:0: Attached scsi generic sg0 type 5
[    9.851042] scsi 1:0:1:0: Attached scsi generic sg1 type 0
[    9.852720] sd 1:0:1:0: [sda] 976773168 512-byte logical blocks: (500 GB=
/466 GiB)
[    9.853132] sd 1:0:1:0: [sda] Write Protect is off
[    9.853388] sd 1:0:1:0: [sda] Mode Sense: 00 3a 00 00
[    9.883974] sd 1:0:1:0: [sda] Write cache: enabled, read cache: enabled,=
 doesn't support DPO or FUA
[    9.884012] sr 1:0:0:0: [sr0] scsi3-mmc drive: 48x/48x writer dvd-ram cd=
/rw xa/form2 cdda tray
[    9.884847] cdrom: Uniform CD-ROM driver Revision: 3.20
[    9.885217] sr 1:0:0:0: Attached scsi CD-ROM sr0
[    9.934355]  sda: sda1 sda2 < sda5 >
[    9.987185] sd 1:0:1:0: [sda] Attached SCSI disk
[   10.034082] Selecting previously unselected package libssl1.1:amd64.
[   10.034089]=20
[   10.036387] Preparing to unpack .../libssl1.1_1.1.0h-2_amd64.deb ...
[   10.036389]=20
[   10.038138] Unpacking libssl1.1:amd64 (1.1.0h-2) ...
[   10.038139]=20
[   10.080147] scsi 4:0:0:0: Direct-Access     Generic- SD/MMC           1.=
00 PQ: 0 ANSI: 0
[   10.081291] scsi 4:0:0:1: Direct-Access     Generic- Compact Flash    1.=
01 PQ: 0 ANSI: 0
[   10.082405] scsi 4:0:0:2: Direct-Access     Generic- SM/xD-Picture    1.=
02 PQ: 0 ANSI: 0
[   10.083476] scsi 4:0:0:3: Direct-Access     Generic- MS/MS-Pro        1.=
03 PQ: 0 ANSI: 0
[   10.084226] sd 4:0:0:0: Attached scsi generic sg2 type 0
[   10.084703] sd 4:0:0:1: Attached scsi generic sg3 type 0
[   10.085758] sd 4:0:0:2: Attached scsi generic sg4 type 0
[   10.086218] sd 4:0:0:3: Attached scsi generic sg5 type 0
[   10.114964] sd 4:0:0:0: [sdb] Attached SCSI removable disk
[   10.117160] sd 4:0:0:1: [sdc] Attached SCSI removable disk
[   10.117857] sd 4:0:0:2: [sdd] Attached SCSI removable disk
[   10.118590] sd 4:0:0:3: [sde] Attached SCSI removable disk
[   10.135486] Selecting previously unselected package sysstat.
[   10.135489]=20
[   10.137600] Preparing to unpack .../deb/sysstat_11.6.1-1_amd64.deb ...
[   10.137601]=20
[   10.138963] Unpacking sysstat (11.6.1-1) ...
[   10.138965]=20
[   10.181075] Preparing to unpack .../gawk_1%3a4.1.4+dfsg-1_amd64.deb ...
[   10.181079]=20
[   10.184115] Unpacking gawk (1:4.1.4+dfsg-1) over (1:4.1.1+dfsg-1) ...
[   10.184118]=20
[   10.255318] Preparing to unpack .../deb/sysstat_11.6.0-1_amd64.deb ...
[   10.255321]=20
[   10.257141] Unpacking sysstat (11.6.0-1) over (11.6.1-1) ...
[   10.257142]=20
[   10.338474] More than one copy of package sysstat has been unpacked
[   10.338479]=20
[   10.341286]  in this run !  Only configuring it once.
[   10.341288]=20
[   10.343220] Setting up perl-base (5.26.1-5) ...
[   10.343222]=20
[   10.345638] Setting up liblocale-gettext-perl (1.07-3+b3) ...
[   10.345641]=20
[   10.347944] Setting up perl-modules-5.26 (5.26.1-5) ...
[   10.347946]=20
[   10.349998] Setting up mime-support (3.60) ...
[   10.350000]=20
[   10.354573] Setting up debconf (1.5.66) ...
[   10.354575]=20
[   10.548465] Setting up libtext-charwidth-perl (0.04-7.1) ...
[   10.548468]=20
[   10.550088] Setting up libtext-iconv-perl (1.7-5+b6) ...
[   10.550092]=20
[   10.551568] Setting up libssl1.1:amd64 (1.1.0h-2) ...
[   10.551569]=20
[   10.689359] Setting up libgdbm-compat4:amd64 (1.14.1-6) ...
[   10.689364]=20
[   10.692375] Setting up libperl5.26:amd64 (5.26.1-5) ...
[   10.692378]=20
[   10.694361] Setting up sysstat (11.6.0-1) ...
[   10.694364]=20
[   11.299216] Setting up gawk (1:4.1.4+dfsg-1) ...
[   11.299221]=20
[   11.305136] Processing triggers for libc-bin (2.23-5) ...
[   11.305140]=20
[   11.308063] Processing triggers for systemd (231-5) ...
[   11.308065]=20
[   17.427966] 16 Apr 17:28:44 ntpdate[639]: step time server 192.168.1.1 o=
ffset 14522.882175 sec
[   17.427971]=20
[   17.688772] EXT4-fs (sda1): mounted filesystem with ordered data mode. O=
pts: (null)
[   17.751119] netpoll: netconsole: local port 6665
[   17.751380] netpoll: netconsole: local IPv4 address 0.0.0.0
[   17.751674] netpoll: netconsole: interface 'eth0'
[   17.752098] netpoll: netconsole: remote port 6647
[   17.752358] netpoll: netconsole: remote IPv4 address 192.168.1.1
[   17.752670] netpoll: netconsole: remote ethernet address ff:ff:ff:ff:ff:=
ff
[   17.753029] netpoll: netconsole: local IP 192.168.1.166
[   17.763454] console [netcon0] enabled
[   17.763662] netconsole: network logging started
[   17.765425] /lkp/lkp/src/bin/run-lkp
[   17.765427]=20
[   17.793117] RESULT_ROOT=3D/result/unixbench/300s-100%-shell1/nhm-white/d=
ebian-x86_64-2016-08-31.cgz/x86_64-rhel-7.2/gcc-7/60cc43fc888428bb2f18f0899=
7432d426a243338/1
[   17.793120]=20
[   17.805574] job=3D/lkp/scheduled/nhm-white/unixbench-300s-100%-shell1-de=
bian-x86_64-2016-08-31.cgz-60cc43fc888428bb2f18f08997432d426a243338-2018041=
6-49036-1w11h1c-0.yaml
[   17.805577]=20
[   17.808259] mount.nfs: try 1 time...
[   17.808261]=20
[   17.842298] run-job /lkp/scheduled/nhm-white/unixbench-300s-100%-shell1-=
debian-x86_64-2016-08-31.cgz-60cc43fc888428bb2f18f08997432d426a243338-20180=
416-49036-1w11h1c-0.yaml
[   17.842302]=20
[   17.874161] /usr/bin/curl -sSf http://inn:80/~lkp/cgi-bin/lkp-jobfile-ap=
pend-var?job_file=3D/lkp/scheduled/nhm-white/unixbench-300s-100%25-shell1-d=
ebian-x86_64-2016-08-31.cgz-60cc43fc888428bb2f18f08997432d426a243338-201804=
16-49036-1w11h1c-0.yaml&job_state=3Drunning -o /dev/null
[   17.874164]=20
[   18.056171] microcode current_version: 0x7, target_version: 0x7
[   18.056175]=20
[   18.081672] kernel profiling enabled schedstats, disable via kernel.sche=
d_schedstats.
[   18.091609] capability: warning: `turbostat' uses 32-bit capabilities (l=
egacy support in use)
[   18.097435] x86/PAT: bmc-watchdog:962 map pfn expected mapping type unca=
ched-minus for [mem 0xbf780000-0xbf780fff], got write-back
[   18.098041] x86/PAT: bmc-watchdog:962 map pfn expected mapping type unca=
ched-minus for [mem 0xbf780000-0xbf780fff], got write-back
[   18.098826] x86/PAT: bmc-watchdog:962 map pfn expected mapping type unca=
ched-minus for [mem 0xbf780000-0xbf780fff], got write-back
[   18.099416] x86/PAT: bmc-watchdog:962 map pfn expected mapping type unca=
ched-minus for [mem 0xbf780000-0xbf780fff], got write-back
[   18.100176] x86/PAT: bmc-watchdog:962 map pfn expected mapping type unca=
ched-minus for [mem 0xbf780000-0xbf780fff], got write-back
[   18.100739] x86/PAT: bmc-watchdog:962 map pfn expected mapping type unca=
ched-minus for [mem 0xbf780000-0xbf780fff], got write-back
[   18.101485] x86/PAT: bmc-watchdog:962 map pfn expected mapping type unca=
ched-minus for [mem 0xbf780000-0xbf780fff], got write-back
[   18.102057] x86/PAT: bmc-watchdog:962 map pfn expected mapping type unca=
ched-minus for [mem 0xbf780000-0xbf780fff], got write-back
[   18.102787] x86/PAT: bmc-watchdog:962 map pfn expected mapping type unca=
ched-minus for [mem 0xbf780000-0xbf780fff], got write-back
[   18.103346] x86/PAT: bmc-watchdog:962 map pfn expected mapping type unca=
ched-minus for [mem 0xbf780000-0xbf780fff], got write-back
[   18.104225] x86/PAT: bmc-watchdog:962 map pfn expected mapping type unca=
ched-minus for [mem 0xbf780000-0xbf780fff], got write-back
[   18.104850] x86/PAT: bmc-watchdog:962 map pfn expected mapping type unca=
ched-minus for [mem 0xbf780000-0xbf780fff], got write-back
[   18.105579] x86/PAT: bmc-watchdog:962 map pfn expected mapping type unca=
ched-minus for [mem 0xbf780000-0xbf780fff], got write-back
[   18.106145] x86/PAT: bmc-watchdog:962 map pfn expected mapping type unca=
ched-minus for [mem 0xbf780000-0xbf780fff], got write-back
[   18.106848] x86/PAT: bmc-watchdog:962 map pfn expected mapping type unca=
ched-minus for [mem 0xbf780000-0xbf780fff], got write-back
[   18.107413] x86/PAT: bmc-watchdog:962 map pfn expected mapping type unca=
ched-minus for [mem 0xbf780000-0xbf780fff], got write-back
[   18.108127] x86/PAT: bmc-watchdog:962 map pfn expected mapping type unca=
ched-minus for [mem 0xbf780000-0xbf780fff], got write-back
[   18.108678] x86/PAT: bmc-watchdog:962 map pfn expected mapping type unca=
ched-minus for [mem 0xbf780000-0xbf780fff], got write-back
[   18.109404] x86/PAT: bmc-watchdog:962 map pfn expected mapping type unca=
ched-minus for [mem 0xbf780000-0xbf780fff], got write-back
[   18.109954] x86/PAT: bmc-watchdog:962 map pfn expected mapping type unca=
ched-minus for [mem 0xbf780000-0xbf780fff], got write-back
[   18.110828] x86/PAT: bmc-watchdog:962 map pfn expected mapping type unca=
ched-minus for [mem 0xbf780000-0xbf780fff], got write-back
[   18.111394] x86/PAT: bmc-watchdog:962 map pfn expected mapping type unca=
ched-minus for [mem 0xbf780000-0xbf780fff], got write-back
[   18.112109] x86/PAT: bmc-watchdog:962 map pfn expected mapping type unca=
ched-minus for [mem 0xbf780000-0xbf780fff], got write-back
[   18.112660] x86/PAT: bmc-watchdog:962 map pfn expected mapping type unca=
ched-minus for [mem 0xbf780000-0xbf780fff], got write-back
[   18.113385] x86/PAT: bmc-watchdog:962 map pfn expected mapping type unca=
ched-minus for [mem 0xbf780000-0xbf780fff], got write-back
[   18.113935] x86/PAT: bmc-watchdog:962 map pfn expected mapping type unca=
ched-minus for [mem 0xbf780000-0xbf780fff], got write-back
[   18.114660] x86/PAT: bmc-watchdog:962 map pfn expected mapping type unca=
ched-minus for [mem 0xbf780000-0xbf780fff], got write-back
[   18.115224] x86/PAT: bmc-watchdog:962 map pfn expected mapping type unca=
ched-minus for [mem 0xbf780000-0xbf780fff], got write-back
[   18.115927] x86/PAT: bmc-watchdog:962 map pfn expected mapping type unca=
ched-minus for [mem 0xbf780000-0xbf780fff], got write-back
[   18.116493] x86/PAT: bmc-watchdog:962 map pfn expected mapping type unca=
ched-minus for [mem 0xbf780000-0xbf780fff], got write-back
[   18.292726]=20
[   19.102688] 2018-04-16 17:28:46 ./Run shell1 -c 8 -i 30
[   19.102692]=20
[   19.204212]=20
[   19.208275]    #    #  #    #  #  #    #          #####   ######  #    #=
   ####   #    #
[   19.208277]=20
[   19.212849]    #    #  ##   #  #   #  #           #    #  #       ##   #=
  #    #  #    #
[   19.212852]=20
[   19.216882]    #    #  # #  #  #    ##            #####   #####   # #  #=
  #       ######
[   19.216885]=20
[   19.220289]    #    #  #  # #  #    ##            #    #  #       #  # #=
  #       #    #
[   19.220290]=20
[   19.223138]    #    #  #   ##  #   #  #           #    #  #       #   ##=
  #    #  #    #
[   19.223140]=20
[   19.225994]     ####   #    #  #  #    #          #####   ######  #    #=
   ####   #    #
[   19.225996]=20
[   19.226560]=20
[   19.229101]    Version 5.1.3                      Based on the Byte Maga=
zine Unix Benchmark
[   19.229103]=20
[   19.229668]=20
[   19.231787]    Multi-CPU version                  Version 5 revisions by=
 Ian Smith,
[   19.231788]=20
[   19.233969]                                       Sunnyvale, CA, USA
[   19.233970]=20
[   19.236505]    January 13, 2011                   johantheghost at yahoo=
 period com
[   19.236506]=20
[   19.237123]=20
[   19.237263]=20
[   78.123800] 8 x Shell Scripts (1 concurrent)  1IPMI BMC is not supported=
 on this machine, skip bmc-watchdog setup!
[   78.123804]=20
[  168.392964] WARNING: stack recursion on stack type 4
[  168.392971] WARNING: can't dereference registers at 0000000027a5a2b6 for=
 ip error_entry+0x65/0x100
[  168.401010] perf: interrupt took too long (2510 > 2500), lowering kernel=
=2Eperf_event_max_sample_rate to 79000
[  168.417665] perf: interrupt took too long (3175 > 3137), lowering kernel=
=2Eperf_event_max_sample_rate to 63000
[  168.441514] perf: interrupt took too long (3994 > 3968), lowering kernel=
=2Eperf_event_max_sample_rate to 50000
[  168.465169] perf: interrupt took too long (5016 > 4992), lowering kernel=
=2Eperf_event_max_sample_rate to 39000
[  168.529886] perf: interrupt took too long (6301 > 6270), lowering kernel=
=2Eperf_event_max_sample_rate to 31000
[  168.657802] perf: interrupt took too long (7979 > 7876), lowering kernel=
=2Eperf_event_max_sample_rate to 25000
[  168.976238] perf: interrupt took too long (10016 > 9973), lowering kerne=
l.perf_event_max_sample_rate to 19000
[  171.793224] WARNING: stack going in the wrong direction? ip=3D__schedule=
+0x489/0x830
[  225.573912] BUG: Bad page map in process sort  pte:00000002 pmd:1b6303067
[  225.574302] addr:00000000efb51519 vm_flags:00000070 anon_vma:          (=
null) mapping:00000000c7c7d07a index:12f
[  225.574820] file:libpthread-2.23.so fault:filemap_fault mmap:generic_fil=
e_mmap readpage:simple_readpage
[  225.575327] CPU: 5 PID: 29228 Comm: sort Not tainted 4.17.0-rc1 #1
[  225.575643] Hardware name: Dell Inc. Studio XPS 8000/0X231R, BIOS A01 08=
/11/2009
[  225.576038] Call Trace:
[  225.576207]  dump_stack+0x5c/0x7b
[  225.576409]  print_bad_pte+0x1de/0x290
[  225.576628]  unmap_page_range+0x803/0xa20
[  225.576855]  unmap_vmas+0x4c/0xa0
[  225.577060]  exit_mmap+0x82/0x150
[  225.577263]  mmput+0x67/0x160
[  225.577453]  do_exit+0x2a5/0xb80
[  225.577652]  ? __fput+0x18d/0x220
[  225.577856]  ? _cond_resched+0x19/0x30
[  225.578078]  do_group_exit+0x3a/0xa0
[  225.578291]  __x64_sys_exit_group+0x14/0x20
[  225.578528]  do_syscall_64+0x5b/0x180
[  225.578745]  entry_SYSCALL_64_after_hwframe+0x44/0xa9
[  225.579017] RIP: 0033:0x7f36a8f501c8
[  225.579230] RSP: 002b:00007ffcf2d32458 EFLAGS: 00000246 ORIG_RAX: 000000=
00000000e7
[  225.579635] RAX: ffffffffffffffda RBX: 0000000000000000 RCX: 00007f36a8f=
501c8
[  225.579988] RDX: 0000000000000000 RSI: 000000000000003c RDI: 00000000000=
00000
[  225.580343] RBP: 00007f36a92308e0 R08: 00000000000000e7 R09: fffffffffff=
fff98
[  225.580697] R10: 00007f36a9452250 R11: 0000000000000246 R12: 00007f36a92=
308e0
[  225.581046] R13: 00007f36a9235c40 R14: 0000000000000000 R15: 00000000000=
00000
[  225.581429] Disabling lock debugging due to kernel taint
[  225.581791] BUG: Bad rss-counter state mm:00000000997e66fa idx:2 val:-1
[  225.602808] general protection fault: 0000 [#1] SMP PTI
[  225.603092] Modules linked in: netconsole sr_mod cdrom sd_mod sg snd_hda=
_codec_realtek intel_powerclamp snd_hda_codec_generic snd_hda_codec_hdmi co=
retemp uas snd_hda_intel kvm_intel ata_generic dcdbas pata_acpi snd_hda_cod=
ec dell_smm_hwmon snd_hda_core kvm snd_hwdep snd_pcm firewire_ohci irqbypas=
s crc32c_intel usb_storage pcspkr snd_timer serio_raw firewire_core ata_pii=
x crc_itu_t snd i7core_edac soundcore libata shpchp acpi_cpufreq ip_tables =
broadcom bcm_phy_lib
[  225.604945] CPU: 3 PID: 29384 Comm: tee Tainted: G    B             4.17=
=2E0-rc1 #1
[  225.605370] Hardware name: Dell Inc. Studio XPS 8000/0X231R, BIOS A01 08=
/11/2009
[  225.606395] RIP: 0010:kmem_cache_alloc+0xa0/0x1e0
[  225.606648] RSP: 0018:ffffc90003f3bc68 EFLAGS: 00010202
[  225.606927] RAX: 0000000000000000 RBX: 0003ffff88018f94 RCX: 00000000004=
d265b
[  225.607312] RDX: 00000000004d265a RSI: 00000000014080c0 RDI: 00000000000=
27360
[  225.607665] RBP: ffff88018f94dff2 R08: ffff8801bfce7360 R09: ffff8801b7c=
44100
[  225.608018] R10: ffffc90003f3bef0 R11: 8080808080808080 R12: 00000000014=
080c0
[  225.608372] R13: ffffffff813b13f2 R14: ffff8801bf15ac00 R15: ffff8801bf1=
5ac00
[  225.608726] FS:  00007fcfb09a3700(0000) GS:ffff8801bfcc0000(0000) knlGS:=
0000000000000000
[  225.609151] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  225.609450] CR2: 00007fcfb082a000 CR3: 00000001b7cf6000 CR4: 00000000000=
006e0
[  225.609803] Call Trace:
[  225.609975]  selinux_file_alloc_security+0x32/0x50
[  225.610239]  security_file_alloc+0x22/0x40
[  225.610474]  get_empty_filp+0x8d/0x1b0
[  225.610694]  path_openat+0x2d/0x1710
[  225.610907]  ? page_add_file_rmap+0x13/0x200
[  225.611149]  ? alloc_set_pte+0x25e/0x520
[  225.611376]  ? filemap_map_pages+0x30a/0x320
[  225.611616]  do_filp_open+0x8c/0xf0
[  225.611825]  ? __handle_mm_fault+0xd69/0x10a0
[  225.612112]  ? _cond_resched+0x19/0x30
[  225.612331]  ? __alloc_fd+0x44/0x180
[  225.612542]  ? do_sys_open+0x1a6/0x230
[  225.612758]  do_sys_open+0x1a6/0x230
[  225.612971]  do_syscall_64+0x5b/0x180
[  225.613187]  entry_SYSCALL_64_after_hwframe+0x44/0xa9
[  225.613454] RIP: 0033:0x7fcfb041191c
[  225.613662] RSP: 002b:00007fff8fb09f40 EFLAGS: 00000202 ORIG_RAX: 000000=
0000000002
[  225.614060] RAX: ffffffffffffffda RBX: 0000000000aca200 RCX: 00007fcfb04=
1191c
[  225.614407] RDX: 0000000000000001 RSI: 0000000000080000 RDI: 0000000000a=
ca1d0
[  225.614756] RBP: 00007fff8fb0a020 R08: 0000000000aca160 R09: 00000000000=
00300
[  225.615102] R10: 00007fcfb04645b0 R11: 0000000000000202 R12: 00000000000=
00000
[  225.615449] R13: 0000000000000000 R14: 00007fcfb05512a0 R15: 00000000000=
00002
[  225.615797] Code: 01 00 00 41 8b 46 20 49 8b 3e 48 8d 4a 01 48 8b 5c 05 =
00 48 89 e8 65 48 0f c7 0f 0f 94 c0 84 c0 74 ba 48 85 db 74 0b 41 8b 46 20 =
<48> 8b 04 03 0f 18 08 41 f7 c4 00 80 00 00 0f 85 08 01 00 00 66=20
[  225.616765] RIP: kmem_cache_alloc+0xa0/0x1e0 RSP: ffffc90003f3bc68
[  225.617102] ---[ end trace 8032327fef00e4ff ]---
[  225.617353] Kernel panic - not syncing: Fatal exception
[  225.617629] Kernel Offset: disabled

--55egzavp6tupoytm
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=".config"

#
# Automatically generated file; DO NOT EDIT.
# Linux/x86_64 4.17.0-rc1 Kernel Configuration
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
CONFIG_HAVE_INTEL_TXT=y
CONFIG_X86_64_SMP=y
CONFIG_ARCH_SUPPORTS_UPROBES=y
CONFIG_FIX_EARLYCON_MEM=y
CONFIG_PGTABLE_LEVELS=4
CONFIG_IRQ_WORK=y
CONFIG_BUILDTIME_EXTABLE_SORT=y
CONFIG_THREAD_INFO_IN_TASK=y

#
# General setup
#
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
CONFIG_KERNEL_GZIP=y
# CONFIG_KERNEL_BZIP2 is not set
# CONFIG_KERNEL_LZMA is not set
# CONFIG_KERNEL_XZ is not set
# CONFIG_KERNEL_LZO is not set
# CONFIG_KERNEL_LZ4 is not set
CONFIG_DEFAULT_HOSTNAME="(none)"
CONFIG_SWAP=y
CONFIG_SYSVIPC=y
CONFIG_SYSVIPC_SYSCTL=y
CONFIG_POSIX_MQUEUE=y
CONFIG_POSIX_MQUEUE_SYSCTL=y
CONFIG_CROSS_MEMORY_ATTACH=y
CONFIG_USELIB=y
CONFIG_AUDIT=y
CONFIG_HAVE_ARCH_AUDITSYSCALL=y
CONFIG_AUDITSYSCALL=y
CONFIG_AUDIT_WATCH=y
CONFIG_AUDIT_TREE=y

#
# IRQ subsystem
#
CONFIG_GENERIC_IRQ_PROBE=y
CONFIG_GENERIC_IRQ_SHOW=y
CONFIG_GENERIC_IRQ_EFFECTIVE_AFF_MASK=y
CONFIG_GENERIC_PENDING_IRQ=y
CONFIG_GENERIC_IRQ_MIGRATION=y
CONFIG_IRQ_DOMAIN=y
CONFIG_IRQ_SIM=y
CONFIG_IRQ_DOMAIN_HIERARCHY=y
CONFIG_GENERIC_MSI_IRQ=y
CONFIG_GENERIC_MSI_IRQ_DOMAIN=y
CONFIG_GENERIC_IRQ_MATRIX_ALLOCATOR=y
CONFIG_GENERIC_IRQ_RESERVATION_MODE=y
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
# CONFIG_NO_HZ_IDLE is not set
CONFIG_NO_HZ_FULL=y
CONFIG_NO_HZ=y
CONFIG_HIGH_RES_TIMERS=y

#
# CPU/Task time and stats accounting
#
CONFIG_VIRT_CPU_ACCOUNTING=y
CONFIG_VIRT_CPU_ACCOUNTING_GEN=y
# CONFIG_IRQ_TIME_ACCOUNTING is not set
CONFIG_BSD_PROCESS_ACCT=y
CONFIG_BSD_PROCESS_ACCT_V3=y
CONFIG_TASKSTATS=y
CONFIG_TASK_DELAY_ACCT=y
CONFIG_TASK_XACCT=y
CONFIG_TASK_IO_ACCOUNTING=y
CONFIG_CPU_ISOLATION=y

#
# RCU Subsystem
#
CONFIG_TREE_RCU=y
# CONFIG_RCU_EXPERT is not set
CONFIG_SRCU=y
CONFIG_TREE_SRCU=y
CONFIG_TASKS_RCU=y
CONFIG_RCU_STALL_COMMON=y
CONFIG_RCU_NEED_SEGCBLIST=y
CONFIG_CONTEXT_TRACKING=y
# CONFIG_CONTEXT_TRACKING_FORCE is not set
CONFIG_RCU_NOCB_CPU=y
CONFIG_BUILD_BIN2C=y
CONFIG_IKCONFIG=y
CONFIG_IKCONFIG_PROC=y
CONFIG_LOG_BUF_SHIFT=20
CONFIG_LOG_CPU_MAX_BUF_SHIFT=12
CONFIG_PRINTK_SAFE_LOG_BUF_SHIFT=13
CONFIG_HAVE_UNSTABLE_SCHED_CLOCK=y
CONFIG_ARCH_SUPPORTS_NUMA_BALANCING=y
CONFIG_ARCH_WANT_BATCHED_UNMAP_TLB_FLUSH=y
CONFIG_ARCH_SUPPORTS_INT128=y
CONFIG_NUMA_BALANCING=y
CONFIG_NUMA_BALANCING_DEFAULT_ENABLED=y
CONFIG_CGROUPS=y
CONFIG_PAGE_COUNTER=y
CONFIG_MEMCG=y
CONFIG_MEMCG_SWAP=y
CONFIG_MEMCG_SWAP_ENABLED=y
CONFIG_BLK_CGROUP=y
# CONFIG_DEBUG_BLK_CGROUP is not set
CONFIG_CGROUP_WRITEBACK=y
CONFIG_CGROUP_SCHED=y
CONFIG_FAIR_GROUP_SCHED=y
CONFIG_CFS_BANDWIDTH=y
CONFIG_RT_GROUP_SCHED=y
CONFIG_CGROUP_PIDS=y
CONFIG_CGROUP_RDMA=y
CONFIG_CGROUP_FREEZER=y
CONFIG_CGROUP_HUGETLB=y
CONFIG_CPUSETS=y
CONFIG_PROC_PID_CPUSET=y
CONFIG_CGROUP_DEVICE=y
# CONFIG_CGROUP_CPUACCT is not set
CONFIG_CGROUP_PERF=y
CONFIG_CGROUP_BPF=y
# CONFIG_CGROUP_DEBUG is not set
CONFIG_SOCK_CGROUP_DATA=y
CONFIG_NAMESPACES=y
CONFIG_UTS_NS=y
CONFIG_IPC_NS=y
CONFIG_USER_NS=y
CONFIG_PID_NS=y
CONFIG_NET_NS=y
CONFIG_SCHED_AUTOGROUP=y
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
CONFIG_HAVE_UID16=y
CONFIG_SYSCTL_EXCEPTION_TRACE=y
CONFIG_HAVE_PCSPKR_PLATFORM=y
CONFIG_BPF=y
CONFIG_EXPERT=y
CONFIG_UID16=y
CONFIG_MULTIUSER=y
CONFIG_SGETMASK_SYSCALL=y
CONFIG_SYSFS_SYSCALL=y
# CONFIG_SYSCTL_SYSCALL is not set
CONFIG_FHANDLE=y
CONFIG_POSIX_TIMERS=y
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
CONFIG_SHMEM=y
CONFIG_AIO=y
CONFIG_ADVISE_SYSCALLS=y
CONFIG_MEMBARRIER=y
CONFIG_CHECKPOINT_RESTORE=y
CONFIG_KALLSYMS=y
CONFIG_KALLSYMS_ALL=y
CONFIG_KALLSYMS_ABSOLUTE_PERCPU=y
CONFIG_KALLSYMS_BASE_RELATIVE=y
CONFIG_BPF_SYSCALL=y
# CONFIG_BPF_JIT_ALWAYS_ON is not set
CONFIG_USERFAULTFD=y
CONFIG_ARCH_HAS_MEMBARRIER_SYNC_CORE=y
CONFIG_EMBEDDED=y
CONFIG_HAVE_PERF_EVENTS=y
# CONFIG_PC104 is not set

#
# Kernel Performance Events And Counters
#
CONFIG_PERF_EVENTS=y
# CONFIG_DEBUG_PERF_USE_VMALLOC is not set
CONFIG_VM_EVENT_COUNTERS=y
CONFIG_SLUB_DEBUG=y
# CONFIG_SLUB_MEMCG_SYSFS_ON is not set
# CONFIG_COMPAT_BRK is not set
# CONFIG_SLAB is not set
CONFIG_SLUB=y
# CONFIG_SLOB is not set
CONFIG_SLAB_MERGE_DEFAULT=y
# CONFIG_SLAB_FREELIST_RANDOM is not set
# CONFIG_SLAB_FREELIST_HARDENED is not set
CONFIG_SLUB_CPU_PARTIAL=y
CONFIG_SYSTEM_DATA_VERIFICATION=y
CONFIG_PROFILING=y
CONFIG_TRACEPOINTS=y
CONFIG_CRASH_CORE=y
CONFIG_KEXEC_CORE=y
CONFIG_OPROFILE=m
CONFIG_OPROFILE_EVENT_MULTIPLEX=y
CONFIG_HAVE_OPROFILE=y
CONFIG_OPROFILE_NMI_TIMER=y
CONFIG_KPROBES=y
CONFIG_JUMP_LABEL=y
# CONFIG_STATIC_KEYS_SELFTEST is not set
CONFIG_OPTPROBES=y
CONFIG_KPROBES_ON_FTRACE=y
CONFIG_UPROBES=y
CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS=y
CONFIG_ARCH_USE_BUILTIN_BSWAP=y
CONFIG_KRETPROBES=y
CONFIG_USER_RETURN_NOTIFIER=y
CONFIG_HAVE_IOREMAP_PROT=y
CONFIG_HAVE_KPROBES=y
CONFIG_HAVE_KRETPROBES=y
CONFIG_HAVE_OPTPROBES=y
CONFIG_HAVE_KPROBES_ON_FTRACE=y
CONFIG_HAVE_FUNCTION_ERROR_INJECTION=y
CONFIG_HAVE_NMI=y
CONFIG_HAVE_ARCH_TRACEHOOK=y
CONFIG_HAVE_DMA_CONTIGUOUS=y
CONFIG_GENERIC_SMP_IDLE_THREAD=y
CONFIG_ARCH_HAS_FORTIFY_SOURCE=y
CONFIG_ARCH_HAS_SET_MEMORY=y
CONFIG_HAVE_ARCH_THREAD_STRUCT_WHITELIST=y
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
CONFIG_ARCH_WANT_COMPAT_IPC_PARSE_VERSION=y
CONFIG_ARCH_WANT_OLD_COMPAT_IPC=y
CONFIG_HAVE_ARCH_SECCOMP_FILTER=y
CONFIG_SECCOMP_FILTER=y
CONFIG_HAVE_GCC_PLUGINS=y
# CONFIG_GCC_PLUGINS is not set
CONFIG_HAVE_CC_STACKPROTECTOR=y
CONFIG_CC_STACKPROTECTOR_NONE=y
# CONFIG_CC_STACKPROTECTOR_REGULAR is not set
# CONFIG_CC_STACKPROTECTOR_STRONG is not set
# CONFIG_CC_STACKPROTECTOR_AUTO is not set
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
CONFIG_HAVE_ARCH_MMAP_RND_COMPAT_BITS=y
CONFIG_ARCH_MMAP_RND_COMPAT_BITS=8
CONFIG_HAVE_ARCH_COMPAT_MMAP_BASES=y
CONFIG_HAVE_COPY_THREAD_TLS=y
CONFIG_HAVE_STACK_VALIDATION=y
CONFIG_OLD_SIGSUSPEND3=y
CONFIG_COMPAT_OLD_SIGACTION=y
CONFIG_HAVE_ARCH_VMAP_STACK=y
CONFIG_VMAP_STACK=y
CONFIG_ARCH_HAS_STRICT_KERNEL_RWX=y
CONFIG_STRICT_KERNEL_RWX=y
CONFIG_ARCH_HAS_STRICT_MODULE_RWX=y
CONFIG_STRICT_MODULE_RWX=y
CONFIG_ARCH_HAS_REFCOUNT=y
# CONFIG_REFCOUNT_FULL is not set

#
# GCOV-based kernel profiling
#
# CONFIG_GCOV_KERNEL is not set
CONFIG_ARCH_HAS_GCOV_PROFILE_ALL=y
CONFIG_RT_MUTEXES=y
CONFIG_BASE_SMALL=0
CONFIG_MODULES=y
CONFIG_MODULE_FORCE_LOAD=y
CONFIG_MODULE_UNLOAD=y
# CONFIG_MODULE_FORCE_UNLOAD is not set
# CONFIG_MODVERSIONS is not set
# CONFIG_MODULE_SRCVERSION_ALL is not set
# CONFIG_MODULE_SIG is not set
# CONFIG_MODULE_COMPRESS is not set
# CONFIG_TRIM_UNUSED_KSYMS is not set
CONFIG_MODULES_TREE_LOOKUP=y
CONFIG_BLOCK=y
CONFIG_BLK_SCSI_REQUEST=y
CONFIG_BLK_DEV_BSG=y
CONFIG_BLK_DEV_BSGLIB=y
CONFIG_BLK_DEV_INTEGRITY=y
# CONFIG_BLK_DEV_ZONED is not set
CONFIG_BLK_DEV_THROTTLING=y
# CONFIG_BLK_DEV_THROTTLING_LOW is not set
# CONFIG_BLK_CMDLINE_PARSER is not set
# CONFIG_BLK_WBT is not set
CONFIG_BLK_DEBUG_FS=y
# CONFIG_BLK_SED_OPAL is not set

#
# Partition Types
#
CONFIG_PARTITION_ADVANCED=y
# CONFIG_ACORN_PARTITION is not set
# CONFIG_AIX_PARTITION is not set
CONFIG_OSF_PARTITION=y
CONFIG_AMIGA_PARTITION=y
# CONFIG_ATARI_PARTITION is not set
CONFIG_MAC_PARTITION=y
CONFIG_MSDOS_PARTITION=y
CONFIG_BSD_DISKLABEL=y
CONFIG_MINIX_SUBPARTITION=y
CONFIG_SOLARIS_X86_PARTITION=y
CONFIG_UNIXWARE_DISKLABEL=y
# CONFIG_LDM_PARTITION is not set
CONFIG_SGI_PARTITION=y
# CONFIG_ULTRIX_PARTITION is not set
CONFIG_SUN_PARTITION=y
CONFIG_KARMA_PARTITION=y
CONFIG_EFI_PARTITION=y
# CONFIG_SYSV68_PARTITION is not set
# CONFIG_CMDLINE_PARTITION is not set
CONFIG_BLOCK_COMPAT=y
CONFIG_BLK_MQ_PCI=y
CONFIG_BLK_MQ_VIRTIO=y

#
# IO Schedulers
#
CONFIG_IOSCHED_NOOP=y
CONFIG_IOSCHED_DEADLINE=y
CONFIG_IOSCHED_CFQ=y
CONFIG_CFQ_GROUP_IOSCHED=y
CONFIG_DEFAULT_DEADLINE=y
# CONFIG_DEFAULT_CFQ is not set
# CONFIG_DEFAULT_NOOP is not set
CONFIG_DEFAULT_IOSCHED="deadline"
CONFIG_MQ_IOSCHED_DEADLINE=y
CONFIG_MQ_IOSCHED_KYBER=y
# CONFIG_IOSCHED_BFQ is not set
CONFIG_PREEMPT_NOTIFIERS=y
CONFIG_PADATA=y
CONFIG_ASN1=y
CONFIG_INLINE_SPIN_UNLOCK_IRQ=y
CONFIG_INLINE_READ_UNLOCK=y
CONFIG_INLINE_READ_UNLOCK_IRQ=y
CONFIG_INLINE_WRITE_UNLOCK=y
CONFIG_INLINE_WRITE_UNLOCK_IRQ=y
CONFIG_ARCH_SUPPORTS_ATOMIC_RMW=y
CONFIG_MUTEX_SPIN_ON_OWNER=y
CONFIG_RWSEM_SPIN_ON_OWNER=y
CONFIG_LOCK_SPIN_ON_OWNER=y
CONFIG_ARCH_USE_QUEUED_SPINLOCKS=y
CONFIG_QUEUED_SPINLOCKS=y
CONFIG_ARCH_USE_QUEUED_RWLOCKS=y
CONFIG_QUEUED_RWLOCKS=y
CONFIG_ARCH_HAS_SYNC_CORE_BEFORE_USERMODE=y
CONFIG_ARCH_HAS_SYSCALL_WRAPPER=y
CONFIG_FREEZER=y

#
# Processor type and features
#
CONFIG_ZONE_DMA=y
CONFIG_SMP=y
CONFIG_X86_FEATURE_NAMES=y
CONFIG_X86_X2APIC=y
CONFIG_X86_MPPARSE=y
# CONFIG_GOLDFISH is not set
CONFIG_RETPOLINE=y
CONFIG_INTEL_RDT=y
CONFIG_X86_EXTENDED_PLATFORM=y
# CONFIG_X86_NUMACHIP is not set
# CONFIG_X86_VSMP is not set
CONFIG_X86_UV=y
# CONFIG_X86_GOLDFISH is not set
# CONFIG_X86_INTEL_MID is not set
CONFIG_X86_INTEL_LPSS=y
# CONFIG_X86_AMD_PLATFORM_DEVICE is not set
CONFIG_IOSF_MBI=y
# CONFIG_IOSF_MBI_DEBUG is not set
CONFIG_X86_SUPPORTS_MEMORY_FAILURE=y
# CONFIG_SCHED_OMIT_FRAME_POINTER is not set
CONFIG_HYPERVISOR_GUEST=y
CONFIG_PARAVIRT=y
# CONFIG_PARAVIRT_DEBUG is not set
CONFIG_PARAVIRT_SPINLOCKS=y
# CONFIG_QUEUED_LOCK_STAT is not set
CONFIG_XEN=y
CONFIG_XEN_PV=y
CONFIG_XEN_PV_SMP=y
CONFIG_XEN_DOM0=y
CONFIG_XEN_PVHVM=y
CONFIG_XEN_PVHVM_SMP=y
CONFIG_XEN_512GB=y
CONFIG_XEN_SAVE_RESTORE=y
# CONFIG_XEN_DEBUG_FS is not set
# CONFIG_XEN_PVH is not set
CONFIG_KVM_GUEST=y
# CONFIG_KVM_DEBUG_FS is not set
CONFIG_PARAVIRT_TIME_ACCOUNTING=y
CONFIG_PARAVIRT_CLOCK=y
# CONFIG_JAILHOUSE_GUEST is not set
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
# CONFIG_PROCESSOR_SELECT is not set
CONFIG_CPU_SUP_INTEL=y
CONFIG_CPU_SUP_AMD=y
CONFIG_CPU_SUP_CENTAUR=y
CONFIG_HPET_TIMER=y
CONFIG_HPET_EMULATE_RTC=y
CONFIG_DMI=y
CONFIG_GART_IOMMU=y
# CONFIG_CALGARY_IOMMU is not set
CONFIG_SWIOTLB=y
CONFIG_IOMMU_HELPER=y
CONFIG_MAXSMP=y
CONFIG_NR_CPUS_RANGE_BEGIN=8192
CONFIG_NR_CPUS_RANGE_END=8192
CONFIG_NR_CPUS_DEFAULT=8192
CONFIG_NR_CPUS=8192
CONFIG_SCHED_SMT=y
CONFIG_SCHED_MC=y
CONFIG_SCHED_MC_PRIO=y
# CONFIG_PREEMPT_NONE is not set
CONFIG_PREEMPT_VOLUNTARY=y
# CONFIG_PREEMPT is not set
CONFIG_PREEMPT_COUNT=y
CONFIG_X86_LOCAL_APIC=y
CONFIG_X86_IO_APIC=y
CONFIG_X86_REROUTE_FOR_BROKEN_BOOT_IRQS=y
CONFIG_X86_MCE=y
CONFIG_X86_MCELOG_LEGACY=y
CONFIG_X86_MCE_INTEL=y
CONFIG_X86_MCE_AMD=y
CONFIG_X86_MCE_THRESHOLD=y
CONFIG_X86_MCE_INJECT=m
CONFIG_X86_THERMAL_VECTOR=y

#
# Performance monitoring
#
CONFIG_PERF_EVENTS_INTEL_UNCORE=y
CONFIG_PERF_EVENTS_INTEL_RAPL=y
CONFIG_PERF_EVENTS_INTEL_CSTATE=y
# CONFIG_PERF_EVENTS_AMD_POWER is not set
CONFIG_X86_16BIT=y
CONFIG_X86_ESPFIX64=y
CONFIG_X86_VSYSCALL_EMULATION=y
CONFIG_I8K=m
CONFIG_MICROCODE=y
CONFIG_MICROCODE_INTEL=y
CONFIG_MICROCODE_AMD=y
CONFIG_MICROCODE_OLD_INTERFACE=y
CONFIG_X86_MSR=y
CONFIG_X86_CPUID=y
# CONFIG_X86_5LEVEL is not set
CONFIG_ARCH_PHYS_ADDR_T_64BIT=y
CONFIG_ARCH_DMA_ADDR_T_64BIT=y
CONFIG_X86_DIRECT_GBPAGES=y
CONFIG_ARCH_HAS_MEM_ENCRYPT=y
# CONFIG_AMD_MEM_ENCRYPT is not set
CONFIG_NUMA=y
CONFIG_AMD_NUMA=y
CONFIG_X86_64_ACPI_NUMA=y
CONFIG_NODES_SPAN_OTHER_NODES=y
# CONFIG_NUMA_EMU is not set
CONFIG_NODES_SHIFT=10
CONFIG_ARCH_SPARSEMEM_ENABLE=y
CONFIG_ARCH_SPARSEMEM_DEFAULT=y
CONFIG_ARCH_SELECT_MEMORY_MODEL=y
CONFIG_ARCH_MEMORY_PROBE=y
CONFIG_ARCH_PROC_KCORE_TEXT=y
CONFIG_ILLEGAL_POINTER_VALUE=0xdead000000000000
CONFIG_SELECT_MEMORY_MODEL=y
CONFIG_SPARSEMEM_MANUAL=y
CONFIG_SPARSEMEM=y
CONFIG_NEED_MULTIPLE_NODES=y
CONFIG_HAVE_MEMORY_PRESENT=y
CONFIG_SPARSEMEM_EXTREME=y
CONFIG_SPARSEMEM_VMEMMAP_ENABLE=y
CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER=y
CONFIG_SPARSEMEM_VMEMMAP=y
CONFIG_HAVE_MEMBLOCK=y
CONFIG_HAVE_MEMBLOCK_NODE_MAP=y
CONFIG_HAVE_GENERIC_GUP=y
CONFIG_ARCH_DISCARD_MEMBLOCK=y
CONFIG_MEMORY_ISOLATION=y
CONFIG_HAVE_BOOTMEM_INFO_NODE=y
CONFIG_MEMORY_HOTPLUG=y
CONFIG_MEMORY_HOTPLUG_SPARSE=y
# CONFIG_MEMORY_HOTPLUG_DEFAULT_ONLINE is not set
CONFIG_MEMORY_HOTREMOVE=y
CONFIG_SPLIT_PTLOCK_CPUS=4
CONFIG_ARCH_ENABLE_SPLIT_PMD_PTLOCK=y
CONFIG_MEMORY_BALLOON=y
CONFIG_BALLOON_COMPACTION=y
CONFIG_COMPACTION=y
CONFIG_MIGRATION=y
CONFIG_ARCH_ENABLE_HUGEPAGE_MIGRATION=y
CONFIG_ARCH_ENABLE_THP_MIGRATION=y
CONFIG_PHYS_ADDR_T_64BIT=y
CONFIG_BOUNCE=y
CONFIG_VIRT_TO_BUS=y
CONFIG_MMU_NOTIFIER=y
CONFIG_KSM=y
CONFIG_DEFAULT_MMAP_MIN_ADDR=4096
CONFIG_ARCH_SUPPORTS_MEMORY_FAILURE=y
CONFIG_MEMORY_FAILURE=y
CONFIG_HWPOISON_INJECT=m
CONFIG_TRANSPARENT_HUGEPAGE=y
CONFIG_TRANSPARENT_HUGEPAGE_ALWAYS=y
# CONFIG_TRANSPARENT_HUGEPAGE_MADVISE is not set
CONFIG_ARCH_WANTS_THP_SWAP=y
CONFIG_THP_SWAP=y
CONFIG_TRANSPARENT_HUGE_PAGECACHE=y
CONFIG_CLEANCACHE=y
CONFIG_FRONTSWAP=y
CONFIG_CMA=y
# CONFIG_CMA_DEBUG is not set
# CONFIG_CMA_DEBUGFS is not set
CONFIG_CMA_AREAS=7
# CONFIG_MEM_SOFT_DIRTY is not set
CONFIG_ZSWAP=y
CONFIG_ZPOOL=y
CONFIG_ZBUD=y
# CONFIG_Z3FOLD is not set
CONFIG_ZSMALLOC=y
# CONFIG_PGTABLE_MAPPING is not set
# CONFIG_ZSMALLOC_STAT is not set
CONFIG_GENERIC_EARLY_IOREMAP=y
# CONFIG_DEFERRED_STRUCT_PAGE_INIT is not set
# CONFIG_IDLE_PAGE_TRACKING is not set
CONFIG_ARCH_HAS_ZONE_DEVICE=y
CONFIG_ZONE_DEVICE=y
CONFIG_ARCH_HAS_HMM=y
# CONFIG_HMM_MIRROR is not set
# CONFIG_DEVICE_PRIVATE is not set
# CONFIG_DEVICE_PUBLIC is not set
CONFIG_FRAME_VECTOR=y
CONFIG_ARCH_USES_HIGH_VMA_FLAGS=y
CONFIG_ARCH_HAS_PKEYS=y
# CONFIG_PERCPU_STATS is not set
# CONFIG_GUP_BENCHMARK is not set
CONFIG_X86_PMEM_LEGACY_DEVICE=y
CONFIG_X86_PMEM_LEGACY=m
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
CONFIG_X86_INTEL_UMIP=y
CONFIG_X86_INTEL_MPX=y
CONFIG_X86_INTEL_MEMORY_PROTECTION_KEYS=y
CONFIG_EFI=y
CONFIG_EFI_STUB=y
# CONFIG_EFI_MIXED is not set
CONFIG_SECCOMP=y
# CONFIG_HZ_100 is not set
# CONFIG_HZ_250 is not set
# CONFIG_HZ_300 is not set
CONFIG_HZ_1000=y
CONFIG_HZ=1000
CONFIG_SCHED_HRTICK=y
CONFIG_KEXEC=y
# CONFIG_KEXEC_FILE is not set
CONFIG_CRASH_DUMP=y
CONFIG_KEXEC_JUMP=y
CONFIG_PHYSICAL_START=0x1000000
CONFIG_RELOCATABLE=y
# CONFIG_RANDOMIZE_BASE is not set
CONFIG_PHYSICAL_ALIGN=0x1000000
CONFIG_HOTPLUG_CPU=y
CONFIG_BOOTPARAM_HOTPLUG_CPU0=y
# CONFIG_DEBUG_HOTPLUG_CPU0 is not set
# CONFIG_COMPAT_VDSO is not set
CONFIG_LEGACY_VSYSCALL_EMULATE=y
# CONFIG_LEGACY_VSYSCALL_NONE is not set
# CONFIG_CMDLINE_BOOL is not set
CONFIG_MODIFY_LDT_SYSCALL=y
CONFIG_HAVE_LIVEPATCH=y
# CONFIG_LIVEPATCH is not set
CONFIG_ARCH_HAS_ADD_PAGES=y
CONFIG_ARCH_ENABLE_MEMORY_HOTPLUG=y
CONFIG_ARCH_ENABLE_MEMORY_HOTREMOVE=y
CONFIG_USE_PERCPU_NUMA_NODE_ID=y

#
# Power management and ACPI options
#
CONFIG_ARCH_HIBERNATION_HEADER=y
CONFIG_SUSPEND=y
CONFIG_SUSPEND_FREEZER=y
# CONFIG_SUSPEND_SKIP_SYNC is not set
CONFIG_HIBERNATE_CALLBACKS=y
CONFIG_HIBERNATION=y
CONFIG_PM_STD_PARTITION=""
CONFIG_PM_SLEEP=y
CONFIG_PM_SLEEP_SMP=y
# CONFIG_PM_AUTOSLEEP is not set
# CONFIG_PM_WAKELOCKS is not set
CONFIG_PM=y
CONFIG_PM_DEBUG=y
CONFIG_PM_ADVANCED_DEBUG=y
CONFIG_PM_TEST_SUSPEND=y
CONFIG_PM_SLEEP_DEBUG=y
# CONFIG_DPM_WATCHDOG is not set
# CONFIG_PM_TRACE_RTC is not set
CONFIG_PM_CLK=y
# CONFIG_WQ_POWER_EFFICIENT_DEFAULT is not set
CONFIG_ACPI=y
CONFIG_ACPI_LEGACY_TABLES_LOOKUP=y
CONFIG_ARCH_MIGHT_HAVE_ACPI_PDC=y
CONFIG_ACPI_SYSTEM_POWER_STATES_SUPPORT=y
# CONFIG_ACPI_DEBUGGER is not set
CONFIG_ACPI_SPCR_TABLE=y
CONFIG_ACPI_LPIT=y
CONFIG_ACPI_SLEEP=y
# CONFIG_ACPI_PROCFS_POWER is not set
CONFIG_ACPI_REV_OVERRIDE_POSSIBLE=y
CONFIG_ACPI_EC_DEBUGFS=m
CONFIG_ACPI_AC=y
CONFIG_ACPI_BATTERY=y
CONFIG_ACPI_BUTTON=y
CONFIG_ACPI_VIDEO=m
CONFIG_ACPI_FAN=y
# CONFIG_ACPI_TAD is not set
CONFIG_ACPI_DOCK=y
CONFIG_ACPI_CPU_FREQ_PSS=y
CONFIG_ACPI_PROCESSOR_CSTATE=y
CONFIG_ACPI_PROCESSOR_IDLE=y
CONFIG_ACPI_CPPC_LIB=y
CONFIG_ACPI_PROCESSOR=y
CONFIG_ACPI_IPMI=m
CONFIG_ACPI_HOTPLUG_CPU=y
CONFIG_ACPI_PROCESSOR_AGGREGATOR=m
CONFIG_ACPI_THERMAL=y
CONFIG_ACPI_NUMA=y
CONFIG_ARCH_HAS_ACPI_TABLE_UPGRADE=y
CONFIG_ACPI_TABLE_UPGRADE=y
CONFIG_ACPI_DEBUG=y
CONFIG_ACPI_PCI_SLOT=y
CONFIG_ACPI_CONTAINER=y
CONFIG_ACPI_HOTPLUG_MEMORY=y
CONFIG_ACPI_HOTPLUG_IOAPIC=y
CONFIG_ACPI_SBS=m
CONFIG_ACPI_HED=y
CONFIG_ACPI_CUSTOM_METHOD=m
CONFIG_ACPI_BGRT=y
# CONFIG_ACPI_REDUCED_HARDWARE_ONLY is not set
CONFIG_ACPI_NFIT=m
CONFIG_HAVE_ACPI_APEI=y
CONFIG_HAVE_ACPI_APEI_NMI=y
CONFIG_ACPI_APEI=y
CONFIG_ACPI_APEI_GHES=y
CONFIG_ACPI_APEI_PCIEAER=y
CONFIG_ACPI_APEI_MEMORY_FAILURE=y
CONFIG_ACPI_APEI_EINJ=m
CONFIG_ACPI_APEI_ERST_DEBUG=y
# CONFIG_DPTF_POWER is not set
CONFIG_ACPI_WATCHDOG=y
CONFIG_ACPI_EXTLOG=m
# CONFIG_PMIC_OPREGION is not set
# CONFIG_ACPI_CONFIGFS is not set
CONFIG_X86_PM_TIMER=y
CONFIG_SFI=y

#
# CPU Frequency scaling
#
CONFIG_CPU_FREQ=y
CONFIG_CPU_FREQ_GOV_ATTR_SET=y
CONFIG_CPU_FREQ_GOV_COMMON=y
# CONFIG_CPU_FREQ_STAT is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_PERFORMANCE is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_POWERSAVE is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_USERSPACE is not set
CONFIG_CPU_FREQ_DEFAULT_GOV_ONDEMAND=y
# CONFIG_CPU_FREQ_DEFAULT_GOV_CONSERVATIVE is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_SCHEDUTIL is not set
CONFIG_CPU_FREQ_GOV_PERFORMANCE=y
CONFIG_CPU_FREQ_GOV_POWERSAVE=y
CONFIG_CPU_FREQ_GOV_USERSPACE=y
CONFIG_CPU_FREQ_GOV_ONDEMAND=y
CONFIG_CPU_FREQ_GOV_CONSERVATIVE=y
# CONFIG_CPU_FREQ_GOV_SCHEDUTIL is not set

#
# CPU frequency scaling drivers
#
CONFIG_X86_INTEL_PSTATE=y
CONFIG_X86_PCC_CPUFREQ=m
CONFIG_X86_ACPI_CPUFREQ=m
CONFIG_X86_ACPI_CPUFREQ_CPB=y
CONFIG_X86_POWERNOW_K8=m
CONFIG_X86_AMD_FREQ_SENSITIVITY=m
# CONFIG_X86_SPEEDSTEP_CENTRINO is not set
CONFIG_X86_P4_CLOCKMOD=m

#
# shared options
#
CONFIG_X86_SPEEDSTEP_LIB=m

#
# CPU Idle
#
CONFIG_CPU_IDLE=y
# CONFIG_CPU_IDLE_GOV_LADDER is not set
CONFIG_CPU_IDLE_GOV_MENU=y
CONFIG_INTEL_IDLE=y

#
# Bus options (PCI etc.)
#
CONFIG_PCI=y
CONFIG_PCI_DIRECT=y
CONFIG_PCI_MMCONFIG=y
CONFIG_PCI_XEN=y
CONFIG_PCI_DOMAINS=y
CONFIG_MMCONF_FAM10H=y
# CONFIG_PCI_CNB20LE_QUIRK is not set
CONFIG_PCIEPORTBUS=y
CONFIG_HOTPLUG_PCI_PCIE=y
CONFIG_PCIEAER=y
CONFIG_PCIE_ECRC=y
CONFIG_PCIEAER_INJECT=m
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
CONFIG_PCI_MSI=y
CONFIG_PCI_MSI_IRQ_DOMAIN=y
CONFIG_PCI_QUIRKS=y
# CONFIG_PCI_DEBUG is not set
# CONFIG_PCI_REALLOC_ENABLE_AUTO is not set
CONFIG_PCI_STUB=y
# CONFIG_XEN_PCIDEV_FRONTEND is not set
CONFIG_PCI_ATS=y
CONFIG_PCI_LOCKLESS_CONFIG=y
CONFIG_PCI_IOV=y
CONFIG_PCI_PRI=y
CONFIG_PCI_PASID=y
CONFIG_PCI_LABEL=y
# CONFIG_PCI_HYPERV is not set
CONFIG_HOTPLUG_PCI=y
CONFIG_HOTPLUG_PCI_ACPI=y
CONFIG_HOTPLUG_PCI_ACPI_IBM=m
# CONFIG_HOTPLUG_PCI_CPCI is not set
CONFIG_HOTPLUG_PCI_SHPC=m

#
# Cadence PCIe controllers support
#

#
# DesignWare PCI Core Support
#
# CONFIG_PCIE_DW_PLAT is not set

#
# PCI host controller drivers
#
# CONFIG_VMD is not set

#
# PCI Endpoint
#
# CONFIG_PCI_ENDPOINT is not set

#
# PCI switch controller drivers
#
# CONFIG_PCI_SW_SWITCHTEC is not set
# CONFIG_ISA_BUS is not set
CONFIG_ISA_DMA_API=y
CONFIG_AMD_NB=y
CONFIG_PCCARD=y
# CONFIG_PCMCIA is not set
CONFIG_CARDBUS=y

#
# PC-card bridges
#
CONFIG_YENTA=m
CONFIG_YENTA_O2=y
CONFIG_YENTA_RICOH=y
CONFIG_YENTA_TI=y
CONFIG_YENTA_ENE_TUNE=y
CONFIG_YENTA_TOSHIBA=y
# CONFIG_RAPIDIO is not set
# CONFIG_X86_SYSFB is not set

#
# Executable file formats / Emulations
#
CONFIG_BINFMT_ELF=y
CONFIG_COMPAT_BINFMT_ELF=y
CONFIG_ELFCORE=y
CONFIG_CORE_DUMP_DEFAULT_ELF_HEADERS=y
CONFIG_BINFMT_SCRIPT=y
CONFIG_BINFMT_MISC=m
CONFIG_COREDUMP=y
CONFIG_IA32_EMULATION=y
# CONFIG_IA32_AOUT is not set
# CONFIG_X86_X32 is not set
CONFIG_COMPAT_32=y
CONFIG_COMPAT=y
CONFIG_COMPAT_FOR_U64_ALIGNMENT=y
CONFIG_SYSVIPC_COMPAT=y
CONFIG_X86_DEV_DMA_OPS=y
CONFIG_NET=y
CONFIG_COMPAT_NETLINK_MESSAGES=y
CONFIG_NET_INGRESS=y
CONFIG_NET_EGRESS=y

#
# Networking options
#
CONFIG_PACKET=y
CONFIG_PACKET_DIAG=m
CONFIG_UNIX=y
CONFIG_UNIX_DIAG=m
# CONFIG_TLS is not set
CONFIG_XFRM=y
CONFIG_XFRM_ALGO=y
CONFIG_XFRM_USER=y
CONFIG_XFRM_SUB_POLICY=y
CONFIG_XFRM_MIGRATE=y
CONFIG_XFRM_STATISTICS=y
CONFIG_XFRM_IPCOMP=m
CONFIG_NET_KEY=m
CONFIG_NET_KEY_MIGRATE=y
CONFIG_INET=y
CONFIG_IP_MULTICAST=y
CONFIG_IP_ADVANCED_ROUTER=y
CONFIG_IP_FIB_TRIE_STATS=y
CONFIG_IP_MULTIPLE_TABLES=y
CONFIG_IP_ROUTE_MULTIPATH=y
CONFIG_IP_ROUTE_VERBOSE=y
CONFIG_IP_ROUTE_CLASSID=y
CONFIG_IP_PNP=y
CONFIG_IP_PNP_DHCP=y
# CONFIG_IP_PNP_BOOTP is not set
# CONFIG_IP_PNP_RARP is not set
CONFIG_NET_IPIP=m
CONFIG_NET_IPGRE_DEMUX=m
CONFIG_NET_IP_TUNNEL=m
CONFIG_NET_IPGRE=m
CONFIG_NET_IPGRE_BROADCAST=y
CONFIG_IP_MROUTE_COMMON=y
CONFIG_IP_MROUTE=y
CONFIG_IP_MROUTE_MULTIPLE_TABLES=y
CONFIG_IP_PIMSM_V1=y
CONFIG_IP_PIMSM_V2=y
CONFIG_SYN_COOKIES=y
CONFIG_NET_IPVTI=m
CONFIG_NET_UDP_TUNNEL=m
CONFIG_NET_FOU=m
CONFIG_NET_FOU_IP_TUNNELS=y
CONFIG_INET_AH=m
CONFIG_INET_ESP=m
# CONFIG_INET_ESP_OFFLOAD is not set
CONFIG_INET_IPCOMP=m
CONFIG_INET_XFRM_TUNNEL=m
CONFIG_INET_TUNNEL=m
CONFIG_INET_XFRM_MODE_TRANSPORT=m
CONFIG_INET_XFRM_MODE_TUNNEL=m
CONFIG_INET_XFRM_MODE_BEET=m
CONFIG_INET_DIAG=m
CONFIG_INET_TCP_DIAG=m
CONFIG_INET_UDP_DIAG=m
# CONFIG_INET_RAW_DIAG is not set
# CONFIG_INET_DIAG_DESTROY is not set
CONFIG_TCP_CONG_ADVANCED=y
CONFIG_TCP_CONG_BIC=m
CONFIG_TCP_CONG_CUBIC=y
CONFIG_TCP_CONG_WESTWOOD=m
CONFIG_TCP_CONG_HTCP=m
CONFIG_TCP_CONG_HSTCP=m
CONFIG_TCP_CONG_HYBLA=m
CONFIG_TCP_CONG_VEGAS=m
# CONFIG_TCP_CONG_NV is not set
CONFIG_TCP_CONG_SCALABLE=m
CONFIG_TCP_CONG_LP=m
CONFIG_TCP_CONG_VENO=m
CONFIG_TCP_CONG_YEAH=m
CONFIG_TCP_CONG_ILLINOIS=m
# CONFIG_TCP_CONG_DCTCP is not set
# CONFIG_TCP_CONG_CDG is not set
# CONFIG_TCP_CONG_BBR is not set
CONFIG_DEFAULT_CUBIC=y
# CONFIG_DEFAULT_RENO is not set
CONFIG_DEFAULT_TCP_CONG="cubic"
CONFIG_TCP_MD5SIG=y
CONFIG_IPV6=y
CONFIG_IPV6_ROUTER_PREF=y
CONFIG_IPV6_ROUTE_INFO=y
CONFIG_IPV6_OPTIMISTIC_DAD=y
CONFIG_INET6_AH=m
CONFIG_INET6_ESP=m
# CONFIG_INET6_ESP_OFFLOAD is not set
CONFIG_INET6_IPCOMP=m
CONFIG_IPV6_MIP6=m
# CONFIG_IPV6_ILA is not set
CONFIG_INET6_XFRM_TUNNEL=m
CONFIG_INET6_TUNNEL=m
CONFIG_INET6_XFRM_MODE_TRANSPORT=m
CONFIG_INET6_XFRM_MODE_TUNNEL=m
CONFIG_INET6_XFRM_MODE_BEET=m
CONFIG_INET6_XFRM_MODE_ROUTEOPTIMIZATION=m
CONFIG_IPV6_VTI=m
CONFIG_IPV6_SIT=m
CONFIG_IPV6_SIT_6RD=y
CONFIG_IPV6_NDISC_NODETYPE=y
CONFIG_IPV6_TUNNEL=m
# CONFIG_IPV6_GRE is not set
CONFIG_IPV6_FOU=m
CONFIG_IPV6_FOU_TUNNEL=m
CONFIG_IPV6_MULTIPLE_TABLES=y
# CONFIG_IPV6_SUBTREES is not set
CONFIG_IPV6_MROUTE=y
CONFIG_IPV6_MROUTE_MULTIPLE_TABLES=y
CONFIG_IPV6_PIMSM_V2=y
# CONFIG_IPV6_SEG6_LWTUNNEL is not set
# CONFIG_IPV6_SEG6_HMAC is not set
CONFIG_NETLABEL=y
CONFIG_NETWORK_SECMARK=y
CONFIG_NET_PTP_CLASSIFY=y
CONFIG_NETWORK_PHY_TIMESTAMPING=y
CONFIG_NETFILTER=y
CONFIG_NETFILTER_ADVANCED=y
CONFIG_BRIDGE_NETFILTER=m

#
# Core Netfilter Configuration
#
CONFIG_NETFILTER_INGRESS=y
CONFIG_NETFILTER_NETLINK=m
CONFIG_NETFILTER_FAMILY_BRIDGE=y
CONFIG_NETFILTER_FAMILY_ARP=y
CONFIG_NETFILTER_NETLINK_ACCT=m
CONFIG_NETFILTER_NETLINK_QUEUE=m
CONFIG_NETFILTER_NETLINK_LOG=m
CONFIG_NF_CONNTRACK=m
CONFIG_NF_LOG_COMMON=m
# CONFIG_NF_LOG_NETDEV is not set
CONFIG_NETFILTER_CONNCOUNT=m
CONFIG_NF_CONNTRACK_MARK=y
CONFIG_NF_CONNTRACK_SECMARK=y
CONFIG_NF_CONNTRACK_ZONES=y
CONFIG_NF_CONNTRACK_PROCFS=y
CONFIG_NF_CONNTRACK_EVENTS=y
# CONFIG_NF_CONNTRACK_TIMEOUT is not set
CONFIG_NF_CONNTRACK_TIMESTAMP=y
CONFIG_NF_CONNTRACK_LABELS=y
CONFIG_NF_CT_PROTO_DCCP=y
CONFIG_NF_CT_PROTO_GRE=m
CONFIG_NF_CT_PROTO_SCTP=y
CONFIG_NF_CT_PROTO_UDPLITE=y
CONFIG_NF_CONNTRACK_AMANDA=m
CONFIG_NF_CONNTRACK_FTP=m
CONFIG_NF_CONNTRACK_H323=m
CONFIG_NF_CONNTRACK_IRC=m
CONFIG_NF_CONNTRACK_BROADCAST=m
CONFIG_NF_CONNTRACK_NETBIOS_NS=m
CONFIG_NF_CONNTRACK_SNMP=m
CONFIG_NF_CONNTRACK_PPTP=m
CONFIG_NF_CONNTRACK_SANE=m
CONFIG_NF_CONNTRACK_SIP=m
CONFIG_NF_CONNTRACK_TFTP=m
CONFIG_NF_CT_NETLINK=m
# CONFIG_NF_CT_NETLINK_TIMEOUT is not set
# CONFIG_NETFILTER_NETLINK_GLUE_CT is not set
CONFIG_NF_NAT=m
CONFIG_NF_NAT_NEEDED=y
CONFIG_NF_NAT_PROTO_DCCP=y
CONFIG_NF_NAT_PROTO_UDPLITE=y
CONFIG_NF_NAT_PROTO_SCTP=y
CONFIG_NF_NAT_AMANDA=m
CONFIG_NF_NAT_FTP=m
CONFIG_NF_NAT_IRC=m
CONFIG_NF_NAT_SIP=m
CONFIG_NF_NAT_TFTP=m
CONFIG_NF_NAT_REDIRECT=m
CONFIG_NETFILTER_SYNPROXY=m
CONFIG_NF_TABLES=m
# CONFIG_NF_TABLES_INET is not set
# CONFIG_NF_TABLES_NETDEV is not set
CONFIG_NFT_EXTHDR=m
CONFIG_NFT_META=m
# CONFIG_NFT_RT is not set
# CONFIG_NFT_NUMGEN is not set
CONFIG_NFT_CT=m
# CONFIG_NFT_SET_RBTREE is not set
# CONFIG_NFT_SET_HASH is not set
# CONFIG_NFT_SET_BITMAP is not set
CONFIG_NFT_COUNTER=m
CONFIG_NFT_LOG=m
CONFIG_NFT_LIMIT=m
# CONFIG_NFT_MASQ is not set
# CONFIG_NFT_REDIR is not set
CONFIG_NFT_NAT=m
# CONFIG_NFT_OBJREF is not set
# CONFIG_NFT_QUEUE is not set
# CONFIG_NFT_QUOTA is not set
# CONFIG_NFT_REJECT is not set
CONFIG_NFT_COMPAT=m
CONFIG_NFT_HASH=m
# CONFIG_NF_FLOW_TABLE is not set
CONFIG_NETFILTER_XTABLES=y

#
# Xtables combined modules
#
CONFIG_NETFILTER_XT_MARK=m
CONFIG_NETFILTER_XT_CONNMARK=m
CONFIG_NETFILTER_XT_SET=m

#
# Xtables targets
#
CONFIG_NETFILTER_XT_TARGET_AUDIT=m
CONFIG_NETFILTER_XT_TARGET_CHECKSUM=m
CONFIG_NETFILTER_XT_TARGET_CLASSIFY=m
CONFIG_NETFILTER_XT_TARGET_CONNMARK=m
CONFIG_NETFILTER_XT_TARGET_CONNSECMARK=m
CONFIG_NETFILTER_XT_TARGET_CT=m
CONFIG_NETFILTER_XT_TARGET_DSCP=m
CONFIG_NETFILTER_XT_TARGET_HL=m
CONFIG_NETFILTER_XT_TARGET_HMARK=m
CONFIG_NETFILTER_XT_TARGET_IDLETIMER=m
CONFIG_NETFILTER_XT_TARGET_LED=m
CONFIG_NETFILTER_XT_TARGET_LOG=m
CONFIG_NETFILTER_XT_TARGET_MARK=m
CONFIG_NETFILTER_XT_NAT=m
CONFIG_NETFILTER_XT_TARGET_NETMAP=m
CONFIG_NETFILTER_XT_TARGET_NFLOG=m
CONFIG_NETFILTER_XT_TARGET_NFQUEUE=m
CONFIG_NETFILTER_XT_TARGET_NOTRACK=m
CONFIG_NETFILTER_XT_TARGET_RATEEST=m
CONFIG_NETFILTER_XT_TARGET_REDIRECT=m
CONFIG_NETFILTER_XT_TARGET_TEE=m
CONFIG_NETFILTER_XT_TARGET_TPROXY=m
CONFIG_NETFILTER_XT_TARGET_TRACE=m
CONFIG_NETFILTER_XT_TARGET_SECMARK=m
CONFIG_NETFILTER_XT_TARGET_TCPMSS=m
CONFIG_NETFILTER_XT_TARGET_TCPOPTSTRIP=m

#
# Xtables matches
#
CONFIG_NETFILTER_XT_MATCH_ADDRTYPE=m
CONFIG_NETFILTER_XT_MATCH_BPF=m
# CONFIG_NETFILTER_XT_MATCH_CGROUP is not set
CONFIG_NETFILTER_XT_MATCH_CLUSTER=m
CONFIG_NETFILTER_XT_MATCH_COMMENT=m
CONFIG_NETFILTER_XT_MATCH_CONNBYTES=m
CONFIG_NETFILTER_XT_MATCH_CONNLABEL=m
CONFIG_NETFILTER_XT_MATCH_CONNLIMIT=m
CONFIG_NETFILTER_XT_MATCH_CONNMARK=m
CONFIG_NETFILTER_XT_MATCH_CONNTRACK=m
CONFIG_NETFILTER_XT_MATCH_CPU=m
CONFIG_NETFILTER_XT_MATCH_DCCP=m
CONFIG_NETFILTER_XT_MATCH_DEVGROUP=m
CONFIG_NETFILTER_XT_MATCH_DSCP=m
CONFIG_NETFILTER_XT_MATCH_ECN=m
CONFIG_NETFILTER_XT_MATCH_ESP=m
CONFIG_NETFILTER_XT_MATCH_HASHLIMIT=m
CONFIG_NETFILTER_XT_MATCH_HELPER=m
CONFIG_NETFILTER_XT_MATCH_HL=m
# CONFIG_NETFILTER_XT_MATCH_IPCOMP is not set
CONFIG_NETFILTER_XT_MATCH_IPRANGE=m
CONFIG_NETFILTER_XT_MATCH_IPVS=m
CONFIG_NETFILTER_XT_MATCH_L2TP=m
CONFIG_NETFILTER_XT_MATCH_LENGTH=m
CONFIG_NETFILTER_XT_MATCH_LIMIT=m
CONFIG_NETFILTER_XT_MATCH_MAC=m
CONFIG_NETFILTER_XT_MATCH_MARK=m
CONFIG_NETFILTER_XT_MATCH_MULTIPORT=m
CONFIG_NETFILTER_XT_MATCH_NFACCT=m
CONFIG_NETFILTER_XT_MATCH_OSF=m
CONFIG_NETFILTER_XT_MATCH_OWNER=m
CONFIG_NETFILTER_XT_MATCH_POLICY=m
CONFIG_NETFILTER_XT_MATCH_PHYSDEV=m
CONFIG_NETFILTER_XT_MATCH_PKTTYPE=m
CONFIG_NETFILTER_XT_MATCH_QUOTA=m
CONFIG_NETFILTER_XT_MATCH_RATEEST=m
CONFIG_NETFILTER_XT_MATCH_REALM=m
CONFIG_NETFILTER_XT_MATCH_RECENT=m
CONFIG_NETFILTER_XT_MATCH_SCTP=m
CONFIG_NETFILTER_XT_MATCH_STATE=m
CONFIG_NETFILTER_XT_MATCH_STATISTIC=m
CONFIG_NETFILTER_XT_MATCH_STRING=m
CONFIG_NETFILTER_XT_MATCH_TCPMSS=m
CONFIG_NETFILTER_XT_MATCH_TIME=m
CONFIG_NETFILTER_XT_MATCH_U32=m
CONFIG_IP_SET=m
CONFIG_IP_SET_MAX=256
CONFIG_IP_SET_BITMAP_IP=m
CONFIG_IP_SET_BITMAP_IPMAC=m
CONFIG_IP_SET_BITMAP_PORT=m
CONFIG_IP_SET_HASH_IP=m
# CONFIG_IP_SET_HASH_IPMARK is not set
CONFIG_IP_SET_HASH_IPPORT=m
CONFIG_IP_SET_HASH_IPPORTIP=m
CONFIG_IP_SET_HASH_IPPORTNET=m
# CONFIG_IP_SET_HASH_IPMAC is not set
# CONFIG_IP_SET_HASH_MAC is not set
# CONFIG_IP_SET_HASH_NETPORTNET is not set
CONFIG_IP_SET_HASH_NET=m
# CONFIG_IP_SET_HASH_NETNET is not set
CONFIG_IP_SET_HASH_NETPORT=m
CONFIG_IP_SET_HASH_NETIFACE=m
CONFIG_IP_SET_LIST_SET=m
CONFIG_IP_VS=m
CONFIG_IP_VS_IPV6=y
# CONFIG_IP_VS_DEBUG is not set
CONFIG_IP_VS_TAB_BITS=12

#
# IPVS transport protocol load balancing support
#
CONFIG_IP_VS_PROTO_TCP=y
CONFIG_IP_VS_PROTO_UDP=y
CONFIG_IP_VS_PROTO_AH_ESP=y
CONFIG_IP_VS_PROTO_ESP=y
CONFIG_IP_VS_PROTO_AH=y
CONFIG_IP_VS_PROTO_SCTP=y

#
# IPVS scheduler
#
CONFIG_IP_VS_RR=m
CONFIG_IP_VS_WRR=m
CONFIG_IP_VS_LC=m
CONFIG_IP_VS_WLC=m
# CONFIG_IP_VS_FO is not set
# CONFIG_IP_VS_OVF is not set
CONFIG_IP_VS_LBLC=m
CONFIG_IP_VS_LBLCR=m
CONFIG_IP_VS_DH=m
CONFIG_IP_VS_SH=m
CONFIG_IP_VS_SED=m
CONFIG_IP_VS_NQ=m

#
# IPVS SH scheduler
#
CONFIG_IP_VS_SH_TAB_BITS=8

#
# IPVS application helper
#
CONFIG_IP_VS_FTP=m
CONFIG_IP_VS_NFCT=y
CONFIG_IP_VS_PE_SIP=m

#
# IP: Netfilter Configuration
#
CONFIG_NF_DEFRAG_IPV4=m
CONFIG_NF_CONNTRACK_IPV4=m
# CONFIG_NF_SOCKET_IPV4 is not set
# CONFIG_NF_TABLES_IPV4 is not set
# CONFIG_NF_TABLES_ARP is not set
CONFIG_NF_DUP_IPV4=m
# CONFIG_NF_LOG_ARP is not set
CONFIG_NF_LOG_IPV4=m
CONFIG_NF_REJECT_IPV4=m
CONFIG_NF_NAT_IPV4=m
CONFIG_NF_NAT_MASQUERADE_IPV4=m
CONFIG_NF_NAT_SNMP_BASIC=m
CONFIG_NF_NAT_PROTO_GRE=m
CONFIG_NF_NAT_PPTP=m
CONFIG_NF_NAT_H323=m
CONFIG_IP_NF_IPTABLES=m
CONFIG_IP_NF_MATCH_AH=m
CONFIG_IP_NF_MATCH_ECN=m
CONFIG_IP_NF_MATCH_RPFILTER=m
CONFIG_IP_NF_MATCH_TTL=m
CONFIG_IP_NF_FILTER=m
CONFIG_IP_NF_TARGET_REJECT=m
CONFIG_IP_NF_TARGET_SYNPROXY=m
CONFIG_IP_NF_NAT=m
CONFIG_IP_NF_TARGET_MASQUERADE=m
CONFIG_IP_NF_TARGET_NETMAP=m
CONFIG_IP_NF_TARGET_REDIRECT=m
CONFIG_IP_NF_MANGLE=m
CONFIG_IP_NF_TARGET_CLUSTERIP=m
CONFIG_IP_NF_TARGET_ECN=m
CONFIG_IP_NF_TARGET_TTL=m
CONFIG_IP_NF_RAW=m
CONFIG_IP_NF_SECURITY=m
CONFIG_IP_NF_ARPTABLES=m
CONFIG_IP_NF_ARPFILTER=m
CONFIG_IP_NF_ARP_MANGLE=m

#
# IPv6: Netfilter Configuration
#
CONFIG_NF_DEFRAG_IPV6=m
CONFIG_NF_CONNTRACK_IPV6=m
# CONFIG_NF_SOCKET_IPV6 is not set
# CONFIG_NF_TABLES_IPV6 is not set
CONFIG_NF_DUP_IPV6=m
CONFIG_NF_REJECT_IPV6=m
CONFIG_NF_LOG_IPV6=m
CONFIG_NF_NAT_IPV6=m
# CONFIG_NF_NAT_MASQUERADE_IPV6 is not set
CONFIG_IP6_NF_IPTABLES=m
CONFIG_IP6_NF_MATCH_AH=m
CONFIG_IP6_NF_MATCH_EUI64=m
CONFIG_IP6_NF_MATCH_FRAG=m
CONFIG_IP6_NF_MATCH_OPTS=m
CONFIG_IP6_NF_MATCH_HL=m
CONFIG_IP6_NF_MATCH_IPV6HEADER=m
CONFIG_IP6_NF_MATCH_MH=m
CONFIG_IP6_NF_MATCH_RPFILTER=m
CONFIG_IP6_NF_MATCH_RT=m
# CONFIG_IP6_NF_MATCH_SRH is not set
CONFIG_IP6_NF_TARGET_HL=m
CONFIG_IP6_NF_FILTER=m
CONFIG_IP6_NF_TARGET_REJECT=m
CONFIG_IP6_NF_TARGET_SYNPROXY=m
CONFIG_IP6_NF_MANGLE=m
CONFIG_IP6_NF_RAW=m
CONFIG_IP6_NF_SECURITY=m
# CONFIG_IP6_NF_NAT is not set
# CONFIG_NF_TABLES_BRIDGE is not set
CONFIG_BRIDGE_NF_EBTABLES=m
CONFIG_BRIDGE_EBT_BROUTE=m
CONFIG_BRIDGE_EBT_T_FILTER=m
CONFIG_BRIDGE_EBT_T_NAT=m
CONFIG_BRIDGE_EBT_802_3=m
CONFIG_BRIDGE_EBT_AMONG=m
CONFIG_BRIDGE_EBT_ARP=m
CONFIG_BRIDGE_EBT_IP=m
CONFIG_BRIDGE_EBT_IP6=m
CONFIG_BRIDGE_EBT_LIMIT=m
CONFIG_BRIDGE_EBT_MARK=m
CONFIG_BRIDGE_EBT_PKTTYPE=m
CONFIG_BRIDGE_EBT_STP=m
CONFIG_BRIDGE_EBT_VLAN=m
CONFIG_BRIDGE_EBT_ARPREPLY=m
CONFIG_BRIDGE_EBT_DNAT=m
CONFIG_BRIDGE_EBT_MARK_T=m
CONFIG_BRIDGE_EBT_REDIRECT=m
CONFIG_BRIDGE_EBT_SNAT=m
CONFIG_BRIDGE_EBT_LOG=m
CONFIG_BRIDGE_EBT_NFLOG=m
CONFIG_IP_DCCP=m
CONFIG_INET_DCCP_DIAG=m

#
# DCCP CCIDs Configuration
#
# CONFIG_IP_DCCP_CCID2_DEBUG is not set
CONFIG_IP_DCCP_CCID3=y
# CONFIG_IP_DCCP_CCID3_DEBUG is not set
CONFIG_IP_DCCP_TFRC_LIB=y

#
# DCCP Kernel Hacking
#
# CONFIG_IP_DCCP_DEBUG is not set
CONFIG_IP_SCTP=m
# CONFIG_SCTP_DBG_OBJCNT is not set
# CONFIG_SCTP_DEFAULT_COOKIE_HMAC_MD5 is not set
CONFIG_SCTP_DEFAULT_COOKIE_HMAC_SHA1=y
# CONFIG_SCTP_DEFAULT_COOKIE_HMAC_NONE is not set
CONFIG_SCTP_COOKIE_HMAC_MD5=y
CONFIG_SCTP_COOKIE_HMAC_SHA1=y
CONFIG_INET_SCTP_DIAG=m
# CONFIG_RDS is not set
CONFIG_TIPC=m
CONFIG_TIPC_MEDIA_UDP=y
CONFIG_TIPC_DIAG=m
CONFIG_ATM=m
CONFIG_ATM_CLIP=m
# CONFIG_ATM_CLIP_NO_ICMP is not set
CONFIG_ATM_LANE=m
# CONFIG_ATM_MPOA is not set
CONFIG_ATM_BR2684=m
# CONFIG_ATM_BR2684_IPFILTER is not set
CONFIG_L2TP=m
CONFIG_L2TP_DEBUGFS=m
CONFIG_L2TP_V3=y
CONFIG_L2TP_IP=m
CONFIG_L2TP_ETH=m
CONFIG_STP=m
CONFIG_GARP=m
CONFIG_MRP=m
CONFIG_BRIDGE=m
CONFIG_BRIDGE_IGMP_SNOOPING=y
CONFIG_BRIDGE_VLAN_FILTERING=y
CONFIG_HAVE_NET_DSA=y
# CONFIG_NET_DSA is not set
CONFIG_VLAN_8021Q=m
CONFIG_VLAN_8021Q_GVRP=y
CONFIG_VLAN_8021Q_MVRP=y
# CONFIG_DECNET is not set
CONFIG_LLC=m
# CONFIG_LLC2 is not set
# CONFIG_ATALK is not set
# CONFIG_X25 is not set
# CONFIG_LAPB is not set
# CONFIG_PHONET is not set
# CONFIG_6LOWPAN is not set
CONFIG_IEEE802154=m
# CONFIG_IEEE802154_NL802154_EXPERIMENTAL is not set
CONFIG_IEEE802154_SOCKET=m
CONFIG_MAC802154=m
CONFIG_NET_SCHED=y

#
# Queueing/Scheduling
#
CONFIG_NET_SCH_CBQ=m
CONFIG_NET_SCH_HTB=m
CONFIG_NET_SCH_HFSC=m
CONFIG_NET_SCH_ATM=m
CONFIG_NET_SCH_PRIO=m
CONFIG_NET_SCH_MULTIQ=m
CONFIG_NET_SCH_RED=m
CONFIG_NET_SCH_SFB=m
CONFIG_NET_SCH_SFQ=m
CONFIG_NET_SCH_TEQL=m
CONFIG_NET_SCH_TBF=m
# CONFIG_NET_SCH_CBS is not set
CONFIG_NET_SCH_GRED=m
CONFIG_NET_SCH_DSMARK=m
CONFIG_NET_SCH_NETEM=m
CONFIG_NET_SCH_DRR=m
CONFIG_NET_SCH_MQPRIO=m
CONFIG_NET_SCH_CHOKE=m
CONFIG_NET_SCH_QFQ=m
CONFIG_NET_SCH_CODEL=m
CONFIG_NET_SCH_FQ_CODEL=m
# CONFIG_NET_SCH_FQ is not set
# CONFIG_NET_SCH_HHF is not set
# CONFIG_NET_SCH_PIE is not set
CONFIG_NET_SCH_INGRESS=m
CONFIG_NET_SCH_PLUG=m
# CONFIG_NET_SCH_DEFAULT is not set

#
# Classification
#
CONFIG_NET_CLS=y
CONFIG_NET_CLS_BASIC=m
CONFIG_NET_CLS_TCINDEX=m
CONFIG_NET_CLS_ROUTE4=m
CONFIG_NET_CLS_FW=m
CONFIG_NET_CLS_U32=m
CONFIG_CLS_U32_PERF=y
CONFIG_CLS_U32_MARK=y
CONFIG_NET_CLS_RSVP=m
CONFIG_NET_CLS_RSVP6=m
CONFIG_NET_CLS_FLOW=m
CONFIG_NET_CLS_CGROUP=y
CONFIG_NET_CLS_BPF=m
# CONFIG_NET_CLS_FLOWER is not set
# CONFIG_NET_CLS_MATCHALL is not set
CONFIG_NET_EMATCH=y
CONFIG_NET_EMATCH_STACK=32
CONFIG_NET_EMATCH_CMP=m
CONFIG_NET_EMATCH_NBYTE=m
CONFIG_NET_EMATCH_U32=m
CONFIG_NET_EMATCH_META=m
CONFIG_NET_EMATCH_TEXT=m
# CONFIG_NET_EMATCH_CANID is not set
CONFIG_NET_EMATCH_IPSET=m
# CONFIG_NET_EMATCH_IPT is not set
CONFIG_NET_CLS_ACT=y
CONFIG_NET_ACT_POLICE=m
CONFIG_NET_ACT_GACT=m
CONFIG_GACT_PROB=y
CONFIG_NET_ACT_MIRRED=m
# CONFIG_NET_ACT_SAMPLE is not set
CONFIG_NET_ACT_IPT=m
CONFIG_NET_ACT_NAT=m
CONFIG_NET_ACT_PEDIT=m
CONFIG_NET_ACT_SIMP=m
CONFIG_NET_ACT_SKBEDIT=m
CONFIG_NET_ACT_CSUM=m
# CONFIG_NET_ACT_VLAN is not set
# CONFIG_NET_ACT_BPF is not set
# CONFIG_NET_ACT_CONNMARK is not set
# CONFIG_NET_ACT_SKBMOD is not set
# CONFIG_NET_ACT_IFE is not set
# CONFIG_NET_ACT_TUNNEL_KEY is not set
CONFIG_NET_CLS_IND=y
CONFIG_NET_SCH_FIFO=y
CONFIG_DCB=y
CONFIG_DNS_RESOLVER=m
# CONFIG_BATMAN_ADV is not set
CONFIG_OPENVSWITCH=m
CONFIG_OPENVSWITCH_GRE=m
CONFIG_OPENVSWITCH_VXLAN=m
CONFIG_VSOCKETS=m
CONFIG_VSOCKETS_DIAG=m
CONFIG_VMWARE_VMCI_VSOCKETS=m
# CONFIG_VIRTIO_VSOCKETS is not set
# CONFIG_HYPERV_VSOCKETS is not set
CONFIG_NETLINK_DIAG=m
CONFIG_MPLS=y
CONFIG_NET_MPLS_GSO=m
# CONFIG_MPLS_ROUTING is not set
CONFIG_NET_NSH=m
# CONFIG_HSR is not set
# CONFIG_NET_SWITCHDEV is not set
CONFIG_NET_L3_MASTER_DEV=y
# CONFIG_NET_NCSI is not set
CONFIG_RPS=y
CONFIG_RFS_ACCEL=y
CONFIG_XPS=y
# CONFIG_CGROUP_NET_PRIO is not set
CONFIG_CGROUP_NET_CLASSID=y
CONFIG_NET_RX_BUSY_POLL=y
CONFIG_BQL=y
CONFIG_BPF_JIT=y
CONFIG_BPF_STREAM_PARSER=y
CONFIG_NET_FLOW_LIMIT=y

#
# Network testing
#
CONFIG_NET_PKTGEN=m
CONFIG_NET_DROP_MONITOR=y
# CONFIG_HAMRADIO is not set
CONFIG_CAN=m
CONFIG_CAN_RAW=m
CONFIG_CAN_BCM=m
CONFIG_CAN_GW=m

#
# CAN Device Drivers
#
CONFIG_CAN_VCAN=m
# CONFIG_CAN_VXCAN is not set
# CONFIG_CAN_SLCAN is not set
CONFIG_CAN_DEV=m
CONFIG_CAN_CALC_BITTIMING=y
# CONFIG_CAN_LEDS is not set
# CONFIG_CAN_C_CAN is not set
# CONFIG_CAN_CC770 is not set
# CONFIG_CAN_IFI_CANFD is not set
# CONFIG_CAN_M_CAN is not set
# CONFIG_CAN_PEAK_PCIEFD is not set
# CONFIG_CAN_SJA1000 is not set
# CONFIG_CAN_SOFTING is not set

#
# CAN SPI interfaces
#
# CONFIG_CAN_HI311X is not set
# CONFIG_CAN_MCP251X is not set

#
# CAN USB interfaces
#
# CONFIG_CAN_EMS_USB is not set
# CONFIG_CAN_ESD_USB2 is not set
# CONFIG_CAN_GS_USB is not set
# CONFIG_CAN_KVASER_USB is not set
# CONFIG_CAN_PEAK_USB is not set
# CONFIG_CAN_8DEV_USB is not set
# CONFIG_CAN_MCBA_USB is not set
# CONFIG_CAN_DEBUG_DEVICES is not set
# CONFIG_BT is not set
# CONFIG_AF_RXRPC is not set
# CONFIG_AF_KCM is not set
CONFIG_STREAM_PARSER=y
CONFIG_FIB_RULES=y
CONFIG_WIRELESS=y
CONFIG_WIRELESS_EXT=y
CONFIG_WEXT_CORE=y
CONFIG_WEXT_PROC=y
CONFIG_WEXT_PRIV=y
CONFIG_CFG80211=m
# CONFIG_NL80211_TESTMODE is not set
# CONFIG_CFG80211_DEVELOPER_WARNINGS is not set
# CONFIG_CFG80211_CERTIFICATION_ONUS is not set
CONFIG_CFG80211_REQUIRE_SIGNED_REGDB=y
CONFIG_CFG80211_USE_KERNEL_REGDB_KEYS=y
CONFIG_CFG80211_DEFAULT_PS=y
# CONFIG_CFG80211_DEBUGFS is not set
CONFIG_CFG80211_CRDA_SUPPORT=y
CONFIG_CFG80211_WEXT=y
CONFIG_LIB80211=m
# CONFIG_LIB80211_DEBUG is not set
CONFIG_MAC80211=m
CONFIG_MAC80211_HAS_RC=y
CONFIG_MAC80211_RC_MINSTREL=y
CONFIG_MAC80211_RC_MINSTREL_HT=y
# CONFIG_MAC80211_RC_MINSTREL_VHT is not set
CONFIG_MAC80211_RC_DEFAULT_MINSTREL=y
CONFIG_MAC80211_RC_DEFAULT="minstrel_ht"
CONFIG_MAC80211_MESH=y
CONFIG_MAC80211_LEDS=y
CONFIG_MAC80211_DEBUGFS=y
# CONFIG_MAC80211_MESSAGE_TRACING is not set
# CONFIG_MAC80211_DEBUG_MENU is not set
CONFIG_MAC80211_STA_HASH_MAX_SIZE=0
# CONFIG_WIMAX is not set
CONFIG_RFKILL=m
CONFIG_RFKILL_LEDS=y
CONFIG_RFKILL_INPUT=y
# CONFIG_RFKILL_GPIO is not set
CONFIG_NET_9P=y
CONFIG_NET_9P_VIRTIO=y
# CONFIG_NET_9P_XEN is not set
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
CONFIG_DEVTMPFS_MOUNT=y
CONFIG_STANDALONE=y
CONFIG_PREVENT_FIRMWARE_BUILD=y
CONFIG_FW_LOADER=y
CONFIG_EXTRA_FIRMWARE=""
CONFIG_FW_LOADER_USER_HELPER=y
CONFIG_FW_LOADER_USER_HELPER_FALLBACK=y
CONFIG_ALLOW_DEV_COREDUMP=y
# CONFIG_DEBUG_DRIVER is not set
# CONFIG_DEBUG_DEVRES is not set
# CONFIG_DEBUG_TEST_DRIVER_REMOVE is not set
# CONFIG_TEST_ASYNC_DRIVER_PROBE is not set
CONFIG_SYS_HYPERVISOR=y
CONFIG_GENERIC_CPU_AUTOPROBE=y
CONFIG_GENERIC_CPU_VULNERABILITIES=y
CONFIG_REGMAP=y
CONFIG_REGMAP_I2C=y
CONFIG_REGMAP_SPI=y
CONFIG_DMA_SHARED_BUFFER=y
# CONFIG_DMA_FENCE_TRACE is not set
CONFIG_DMA_CMA=y

#
# Default contiguous memory area size:
#
CONFIG_CMA_SIZE_MBYTES=200
CONFIG_CMA_SIZE_SEL_MBYTES=y
# CONFIG_CMA_SIZE_SEL_PERCENTAGE is not set
# CONFIG_CMA_SIZE_SEL_MIN is not set
# CONFIG_CMA_SIZE_SEL_MAX is not set
CONFIG_CMA_ALIGNMENT=8

#
# Bus devices
#
CONFIG_CONNECTOR=y
CONFIG_PROC_EVENTS=y
CONFIG_MTD=m
# CONFIG_MTD_TESTS is not set
# CONFIG_MTD_REDBOOT_PARTS is not set
# CONFIG_MTD_CMDLINE_PARTS is not set
# CONFIG_MTD_AR7_PARTS is not set

#
# Partition parsers
#

#
# User Modules And Translation Layers
#
CONFIG_MTD_BLKDEVS=m
CONFIG_MTD_BLOCK=m
# CONFIG_MTD_BLOCK_RO is not set
# CONFIG_FTL is not set
# CONFIG_NFTL is not set
# CONFIG_INFTL is not set
# CONFIG_RFD_FTL is not set
# CONFIG_SSFDC is not set
# CONFIG_SM_FTL is not set
# CONFIG_MTD_OOPS is not set
# CONFIG_MTD_SWAP is not set
# CONFIG_MTD_PARTITIONED_MASTER is not set

#
# RAM/ROM/Flash chip drivers
#
# CONFIG_MTD_CFI is not set
# CONFIG_MTD_JEDECPROBE is not set
CONFIG_MTD_MAP_BANK_WIDTH_1=y
CONFIG_MTD_MAP_BANK_WIDTH_2=y
CONFIG_MTD_MAP_BANK_WIDTH_4=y
CONFIG_MTD_CFI_I1=y
CONFIG_MTD_CFI_I2=y
# CONFIG_MTD_RAM is not set
# CONFIG_MTD_ROM is not set
# CONFIG_MTD_ABSENT is not set

#
# Mapping drivers for chip access
#
# CONFIG_MTD_COMPLEX_MAPPINGS is not set
# CONFIG_MTD_INTEL_VR_NOR is not set
# CONFIG_MTD_PLATRAM is not set

#
# Self-contained MTD device drivers
#
# CONFIG_MTD_PMC551 is not set
# CONFIG_MTD_DATAFLASH is not set
# CONFIG_MTD_MCHP23K256 is not set
# CONFIG_MTD_SST25L is not set
# CONFIG_MTD_SLRAM is not set
# CONFIG_MTD_PHRAM is not set
# CONFIG_MTD_MTDRAM is not set
# CONFIG_MTD_BLOCK2MTD is not set

#
# Disk-On-Chip Device Drivers
#
# CONFIG_MTD_DOCG3 is not set
# CONFIG_MTD_ONENAND is not set
# CONFIG_MTD_NAND is not set

#
# LPDDR & LPDDR2 PCM memory drivers
#
# CONFIG_MTD_LPDDR is not set
# CONFIG_MTD_SPI_NOR is not set
CONFIG_MTD_UBI=m
CONFIG_MTD_UBI_WL_THRESHOLD=4096
CONFIG_MTD_UBI_BEB_LIMIT=20
# CONFIG_MTD_UBI_FASTMAP is not set
# CONFIG_MTD_UBI_GLUEBI is not set
# CONFIG_MTD_UBI_BLOCK is not set
# CONFIG_OF is not set
CONFIG_ARCH_MIGHT_HAVE_PC_PARPORT=y
CONFIG_PARPORT=m
CONFIG_PARPORT_PC=m
CONFIG_PARPORT_SERIAL=m
# CONFIG_PARPORT_PC_FIFO is not set
# CONFIG_PARPORT_PC_SUPERIO is not set
# CONFIG_PARPORT_AX88796 is not set
CONFIG_PARPORT_1284=y
CONFIG_PARPORT_NOT_PC=y
CONFIG_PNP=y
# CONFIG_PNP_DEBUG_MESSAGES is not set

#
# Protocols
#
CONFIG_PNPACPI=y
CONFIG_BLK_DEV=y
CONFIG_BLK_DEV_NULL_BLK=m
# CONFIG_BLK_DEV_NULL_BLK_FAULT_INJECTION is not set
CONFIG_BLK_DEV_FD=m
CONFIG_CDROM=m
# CONFIG_PARIDE is not set
CONFIG_BLK_DEV_PCIESSD_MTIP32XX=m
# CONFIG_ZRAM is not set
# CONFIG_BLK_DEV_DAC960 is not set
# CONFIG_BLK_DEV_UMEM is not set
CONFIG_BLK_DEV_LOOP=m
CONFIG_BLK_DEV_LOOP_MIN_COUNT=0
# CONFIG_BLK_DEV_CRYPTOLOOP is not set
# CONFIG_BLK_DEV_DRBD is not set
# CONFIG_BLK_DEV_NBD is not set
# CONFIG_BLK_DEV_SKD is not set
CONFIG_BLK_DEV_SX8=m
CONFIG_BLK_DEV_RAM=m
CONFIG_BLK_DEV_RAM_COUNT=16
CONFIG_BLK_DEV_RAM_SIZE=16384
CONFIG_CDROM_PKTCDVD=m
CONFIG_CDROM_PKTCDVD_BUFFERS=8
# CONFIG_CDROM_PKTCDVD_WCACHE is not set
CONFIG_ATA_OVER_ETH=m
CONFIG_XEN_BLKDEV_FRONTEND=m
# CONFIG_XEN_BLKDEV_BACKEND is not set
CONFIG_VIRTIO_BLK=y
# CONFIG_VIRTIO_BLK_SCSI is not set
# CONFIG_BLK_DEV_RBD is not set
CONFIG_BLK_DEV_RSXX=m

#
# NVME Support
#
CONFIG_NVME_CORE=m
CONFIG_BLK_DEV_NVME=m
# CONFIG_NVME_MULTIPATH is not set
# CONFIG_NVME_FC is not set
# CONFIG_NVME_TARGET is not set

#
# Misc devices
#
CONFIG_SENSORS_LIS3LV02D=m
# CONFIG_AD525X_DPOT is not set
# CONFIG_DUMMY_IRQ is not set
# CONFIG_IBM_ASM is not set
# CONFIG_PHANTOM is not set
CONFIG_SGI_IOC4=m
CONFIG_TIFM_CORE=m
CONFIG_TIFM_7XX1=m
# CONFIG_ICS932S401 is not set
CONFIG_ENCLOSURE_SERVICES=m
CONFIG_SGI_XP=m
CONFIG_HP_ILO=m
CONFIG_SGI_GRU=m
# CONFIG_SGI_GRU_DEBUG is not set
CONFIG_APDS9802ALS=m
CONFIG_ISL29003=m
CONFIG_ISL29020=m
CONFIG_SENSORS_TSL2550=m
CONFIG_SENSORS_BH1770=m
CONFIG_SENSORS_APDS990X=m
# CONFIG_HMC6352 is not set
# CONFIG_DS1682 is not set
CONFIG_VMWARE_BALLOON=m
# CONFIG_USB_SWITCH_FSA9480 is not set
# CONFIG_LATTICE_ECP3_CONFIG is not set
# CONFIG_SRAM is not set
# CONFIG_PCI_ENDPOINT_TEST is not set
# CONFIG_C2PORT is not set

#
# EEPROM support
#
CONFIG_EEPROM_AT24=m
# CONFIG_EEPROM_AT25 is not set
CONFIG_EEPROM_LEGACY=m
CONFIG_EEPROM_MAX6875=m
CONFIG_EEPROM_93CX6=m
# CONFIG_EEPROM_93XX46 is not set
# CONFIG_EEPROM_IDT_89HPESX is not set
CONFIG_CB710_CORE=m
# CONFIG_CB710_DEBUG is not set
CONFIG_CB710_DEBUG_ASSUMPTIONS=y

#
# Texas Instruments shared transport line discipline
#
# CONFIG_TI_ST is not set
CONFIG_SENSORS_LIS3_I2C=m
CONFIG_ALTERA_STAPL=m
CONFIG_INTEL_MEI=y
CONFIG_INTEL_MEI_ME=y
# CONFIG_INTEL_MEI_TXE is not set
CONFIG_VMWARE_VMCI=m

#
# Intel MIC & related support
#

#
# Intel MIC Bus Driver
#
# CONFIG_INTEL_MIC_BUS is not set

#
# SCIF Bus Driver
#
# CONFIG_SCIF_BUS is not set

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
# CONFIG_GENWQE is not set
# CONFIG_ECHO is not set
# CONFIG_MISC_RTSX_PCI is not set
# CONFIG_MISC_RTSX_USB is not set
CONFIG_HAVE_IDE=y
# CONFIG_IDE is not set

#
# SCSI device support
#
CONFIG_SCSI_MOD=y
CONFIG_RAID_ATTRS=m
CONFIG_SCSI=y
CONFIG_SCSI_DMA=y
CONFIG_SCSI_NETLINK=y
# CONFIG_SCSI_MQ_DEFAULT is not set
CONFIG_SCSI_PROC_FS=y

#
# SCSI support type (disk, tape, CD-ROM)
#
CONFIG_BLK_DEV_SD=m
CONFIG_CHR_DEV_ST=m
CONFIG_CHR_DEV_OSST=m
CONFIG_BLK_DEV_SR=m
CONFIG_BLK_DEV_SR_VENDOR=y
CONFIG_CHR_DEV_SG=m
CONFIG_CHR_DEV_SCH=m
CONFIG_SCSI_ENCLOSURE=m
CONFIG_SCSI_CONSTANTS=y
CONFIG_SCSI_LOGGING=y
CONFIG_SCSI_SCAN_ASYNC=y

#
# SCSI Transports
#
CONFIG_SCSI_SPI_ATTRS=m
CONFIG_SCSI_FC_ATTRS=m
CONFIG_SCSI_ISCSI_ATTRS=m
CONFIG_SCSI_SAS_ATTRS=m
CONFIG_SCSI_SAS_LIBSAS=m
CONFIG_SCSI_SAS_ATA=y
CONFIG_SCSI_SAS_HOST_SMP=y
CONFIG_SCSI_SRP_ATTRS=m
CONFIG_SCSI_LOWLEVEL=y
CONFIG_ISCSI_TCP=m
CONFIG_ISCSI_BOOT_SYSFS=m
CONFIG_SCSI_CXGB3_ISCSI=m
CONFIG_SCSI_CXGB4_ISCSI=m
CONFIG_SCSI_BNX2_ISCSI=m
CONFIG_SCSI_BNX2X_FCOE=m
CONFIG_BE2ISCSI=m
# CONFIG_BLK_DEV_3W_XXXX_RAID is not set
CONFIG_SCSI_HPSA=m
CONFIG_SCSI_3W_9XXX=m
CONFIG_SCSI_3W_SAS=m
# CONFIG_SCSI_ACARD is not set
CONFIG_SCSI_AACRAID=m
# CONFIG_SCSI_AIC7XXX is not set
CONFIG_SCSI_AIC79XX=m
CONFIG_AIC79XX_CMDS_PER_DEVICE=4
CONFIG_AIC79XX_RESET_DELAY_MS=15000
# CONFIG_AIC79XX_DEBUG_ENABLE is not set
CONFIG_AIC79XX_DEBUG_MASK=0
# CONFIG_AIC79XX_REG_PRETTY_PRINT is not set
# CONFIG_SCSI_AIC94XX is not set
CONFIG_SCSI_MVSAS=m
# CONFIG_SCSI_MVSAS_DEBUG is not set
CONFIG_SCSI_MVSAS_TASKLET=y
CONFIG_SCSI_MVUMI=m
# CONFIG_SCSI_DPT_I2O is not set
# CONFIG_SCSI_ADVANSYS is not set
CONFIG_SCSI_ARCMSR=m
# CONFIG_SCSI_ESAS2R is not set
# CONFIG_MEGARAID_NEWGEN is not set
# CONFIG_MEGARAID_LEGACY is not set
CONFIG_MEGARAID_SAS=m
CONFIG_SCSI_MPT3SAS=m
CONFIG_SCSI_MPT2SAS_MAX_SGE=128
CONFIG_SCSI_MPT3SAS_MAX_SGE=128
CONFIG_SCSI_MPT2SAS=m
# CONFIG_SCSI_SMARTPQI is not set
CONFIG_SCSI_UFSHCD=m
CONFIG_SCSI_UFSHCD_PCI=m
# CONFIG_SCSI_UFS_DWC_TC_PCI is not set
# CONFIG_SCSI_UFSHCD_PLATFORM is not set
CONFIG_SCSI_HPTIOP=m
# CONFIG_SCSI_BUSLOGIC is not set
CONFIG_VMWARE_PVSCSI=m
# CONFIG_XEN_SCSI_FRONTEND is not set
CONFIG_HYPERV_STORAGE=m
CONFIG_LIBFC=m
CONFIG_LIBFCOE=m
CONFIG_FCOE=m
CONFIG_FCOE_FNIC=m
# CONFIG_SCSI_SNIC is not set
# CONFIG_SCSI_DMX3191D is not set
# CONFIG_SCSI_GDTH is not set
CONFIG_SCSI_ISCI=m
# CONFIG_SCSI_IPS is not set
CONFIG_SCSI_INITIO=m
# CONFIG_SCSI_INIA100 is not set
# CONFIG_SCSI_PPA is not set
# CONFIG_SCSI_IMM is not set
CONFIG_SCSI_STEX=m
# CONFIG_SCSI_SYM53C8XX_2 is not set
CONFIG_SCSI_IPR=m
CONFIG_SCSI_IPR_TRACE=y
CONFIG_SCSI_IPR_DUMP=y
# CONFIG_SCSI_QLOGIC_1280 is not set
CONFIG_SCSI_QLA_FC=m
# CONFIG_TCM_QLA2XXX is not set
CONFIG_SCSI_QLA_ISCSI=m
# CONFIG_SCSI_LPFC is not set
# CONFIG_SCSI_DC395x is not set
# CONFIG_SCSI_AM53C974 is not set
# CONFIG_SCSI_WD719X is not set
CONFIG_SCSI_DEBUG=m
CONFIG_SCSI_PMCRAID=m
CONFIG_SCSI_PM8001=m
# CONFIG_SCSI_BFA_FC is not set
CONFIG_SCSI_VIRTIO=m
CONFIG_SCSI_CHELSIO_FCOE=m
CONFIG_SCSI_DH=y
CONFIG_SCSI_DH_RDAC=y
CONFIG_SCSI_DH_HP_SW=y
CONFIG_SCSI_DH_EMC=y
CONFIG_SCSI_DH_ALUA=y
CONFIG_SCSI_OSD_INITIATOR=m
CONFIG_SCSI_OSD_ULD=m
CONFIG_SCSI_OSD_DPRINT_SENSE=1
# CONFIG_SCSI_OSD_DEBUG is not set
CONFIG_ATA=m
CONFIG_ATA_VERBOSE_ERROR=y
CONFIG_ATA_ACPI=y
# CONFIG_SATA_ZPODD is not set
CONFIG_SATA_PMP=y

#
# Controllers with non-SFF native interface
#
CONFIG_SATA_AHCI=m
CONFIG_SATA_MOBILE_LPM_POLICY=0
CONFIG_SATA_AHCI_PLATFORM=m
# CONFIG_SATA_INIC162X is not set
CONFIG_SATA_ACARD_AHCI=m
CONFIG_SATA_SIL24=m
CONFIG_ATA_SFF=y

#
# SFF controllers with custom DMA interface
#
CONFIG_PDC_ADMA=m
CONFIG_SATA_QSTOR=m
CONFIG_SATA_SX4=m
CONFIG_ATA_BMDMA=y

#
# SATA SFF controllers with BMDMA
#
CONFIG_ATA_PIIX=m
# CONFIG_SATA_DWC is not set
CONFIG_SATA_MV=m
CONFIG_SATA_NV=m
CONFIG_SATA_PROMISE=m
CONFIG_SATA_SIL=m
CONFIG_SATA_SIS=m
CONFIG_SATA_SVW=m
CONFIG_SATA_ULI=m
CONFIG_SATA_VIA=m
CONFIG_SATA_VITESSE=m

#
# PATA SFF controllers with BMDMA
#
CONFIG_PATA_ALI=m
CONFIG_PATA_AMD=m
CONFIG_PATA_ARTOP=m
CONFIG_PATA_ATIIXP=m
CONFIG_PATA_ATP867X=m
CONFIG_PATA_CMD64X=m
# CONFIG_PATA_CYPRESS is not set
# CONFIG_PATA_EFAR is not set
CONFIG_PATA_HPT366=m
CONFIG_PATA_HPT37X=m
CONFIG_PATA_HPT3X2N=m
CONFIG_PATA_HPT3X3=m
# CONFIG_PATA_HPT3X3_DMA is not set
CONFIG_PATA_IT8213=m
CONFIG_PATA_IT821X=m
CONFIG_PATA_JMICRON=m
CONFIG_PATA_MARVELL=m
CONFIG_PATA_NETCELL=m
CONFIG_PATA_NINJA32=m
# CONFIG_PATA_NS87415 is not set
CONFIG_PATA_OLDPIIX=m
# CONFIG_PATA_OPTIDMA is not set
CONFIG_PATA_PDC2027X=m
CONFIG_PATA_PDC_OLD=m
# CONFIG_PATA_RADISYS is not set
CONFIG_PATA_RDC=m
CONFIG_PATA_SCH=m
CONFIG_PATA_SERVERWORKS=m
CONFIG_PATA_SIL680=m
CONFIG_PATA_SIS=m
CONFIG_PATA_TOSHIBA=m
# CONFIG_PATA_TRIFLEX is not set
CONFIG_PATA_VIA=m
# CONFIG_PATA_WINBOND is not set

#
# PIO-only SFF controllers
#
# CONFIG_PATA_CMD640_PCI is not set
# CONFIG_PATA_MPIIX is not set
# CONFIG_PATA_NS87410 is not set
# CONFIG_PATA_OPTI is not set
# CONFIG_PATA_PLATFORM is not set
# CONFIG_PATA_RZ1000 is not set

#
# Generic fallback / legacy drivers
#
CONFIG_PATA_ACPI=m
CONFIG_ATA_GENERIC=m
# CONFIG_PATA_LEGACY is not set
CONFIG_MD=y
CONFIG_BLK_DEV_MD=y
CONFIG_MD_AUTODETECT=y
CONFIG_MD_LINEAR=m
CONFIG_MD_RAID0=m
CONFIG_MD_RAID1=m
CONFIG_MD_RAID10=m
CONFIG_MD_RAID456=m
CONFIG_MD_MULTIPATH=m
CONFIG_MD_FAULTY=m
# CONFIG_MD_CLUSTER is not set
# CONFIG_BCACHE is not set
CONFIG_BLK_DEV_DM_BUILTIN=y
CONFIG_BLK_DEV_DM=m
# CONFIG_DM_MQ_DEFAULT is not set
CONFIG_DM_DEBUG=y
CONFIG_DM_BUFIO=m
# CONFIG_DM_DEBUG_BLOCK_MANAGER_LOCKING is not set
CONFIG_DM_BIO_PRISON=m
CONFIG_DM_PERSISTENT_DATA=m
# CONFIG_DM_UNSTRIPED is not set
CONFIG_DM_CRYPT=m
CONFIG_DM_SNAPSHOT=m
CONFIG_DM_THIN_PROVISIONING=m
CONFIG_DM_CACHE=m
CONFIG_DM_CACHE_SMQ=m
# CONFIG_DM_ERA is not set
CONFIG_DM_MIRROR=m
CONFIG_DM_LOG_USERSPACE=m
CONFIG_DM_RAID=m
CONFIG_DM_ZERO=m
CONFIG_DM_MULTIPATH=m
CONFIG_DM_MULTIPATH_QL=m
CONFIG_DM_MULTIPATH_ST=m
CONFIG_DM_DELAY=m
CONFIG_DM_UEVENT=y
CONFIG_DM_FLAKEY=m
CONFIG_DM_VERITY=m
# CONFIG_DM_VERITY_FEC is not set
CONFIG_DM_SWITCH=m
CONFIG_DM_LOG_WRITES=m
# CONFIG_DM_INTEGRITY is not set
CONFIG_TARGET_CORE=m
CONFIG_TCM_IBLOCK=m
CONFIG_TCM_FILEIO=m
CONFIG_TCM_PSCSI=m
# CONFIG_TCM_USER2 is not set
CONFIG_LOOPBACK_TARGET=m
CONFIG_TCM_FC=m
CONFIG_ISCSI_TARGET=m
# CONFIG_ISCSI_TARGET_CXGB4 is not set
# CONFIG_SBP_TARGET is not set
CONFIG_FUSION=y
CONFIG_FUSION_SPI=m
# CONFIG_FUSION_FC is not set
CONFIG_FUSION_SAS=m
CONFIG_FUSION_MAX_SGE=128
CONFIG_FUSION_CTL=m
CONFIG_FUSION_LOGGING=y

#
# IEEE 1394 (FireWire) support
#
CONFIG_FIREWIRE=m
CONFIG_FIREWIRE_OHCI=m
CONFIG_FIREWIRE_SBP2=m
CONFIG_FIREWIRE_NET=m
# CONFIG_FIREWIRE_NOSY is not set
CONFIG_MACINTOSH_DRIVERS=y
CONFIG_MAC_EMUMOUSEBTN=y
CONFIG_NETDEVICES=y
CONFIG_MII=y
CONFIG_NET_CORE=y
CONFIG_BONDING=m
CONFIG_DUMMY=m
# CONFIG_EQUALIZER is not set
CONFIG_NET_FC=y
CONFIG_IFB=m
CONFIG_NET_TEAM=m
CONFIG_NET_TEAM_MODE_BROADCAST=m
CONFIG_NET_TEAM_MODE_ROUNDROBIN=m
CONFIG_NET_TEAM_MODE_RANDOM=m
CONFIG_NET_TEAM_MODE_ACTIVEBACKUP=m
CONFIG_NET_TEAM_MODE_LOADBALANCE=m
CONFIG_MACVLAN=m
CONFIG_MACVTAP=m
# CONFIG_IPVLAN is not set
CONFIG_VXLAN=m
# CONFIG_GENEVE is not set
# CONFIG_GTP is not set
CONFIG_MACSEC=y
CONFIG_NETCONSOLE=m
CONFIG_NETCONSOLE_DYNAMIC=y
CONFIG_NETPOLL=y
CONFIG_NET_POLL_CONTROLLER=y
CONFIG_TUN=m
CONFIG_TAP=m
# CONFIG_TUN_VNET_CROSS_LE is not set
CONFIG_VETH=m
CONFIG_VIRTIO_NET=y
CONFIG_NLMON=m
CONFIG_NET_VRF=y
# CONFIG_ARCNET is not set
# CONFIG_ATM_DRIVERS is not set

#
# CAIF transport drivers
#

#
# Distributed Switch Architecture drivers
#
CONFIG_ETHERNET=y
CONFIG_MDIO=y
# CONFIG_NET_VENDOR_3COM is not set
# CONFIG_NET_VENDOR_ADAPTEC is not set
CONFIG_NET_VENDOR_AGERE=y
# CONFIG_ET131X is not set
CONFIG_NET_VENDOR_ALACRITECH=y
# CONFIG_SLICOSS is not set
# CONFIG_NET_VENDOR_ALTEON is not set
# CONFIG_ALTERA_TSE is not set
CONFIG_NET_VENDOR_AMAZON=y
# CONFIG_ENA_ETHERNET is not set
# CONFIG_NET_VENDOR_AMD is not set
CONFIG_NET_VENDOR_AQUANTIA=y
# CONFIG_AQTION is not set
CONFIG_NET_VENDOR_ARC=y
CONFIG_NET_VENDOR_ATHEROS=y
CONFIG_ATL2=m
CONFIG_ATL1=m
CONFIG_ATL1E=m
CONFIG_ATL1C=m
CONFIG_ALX=m
# CONFIG_NET_VENDOR_AURORA is not set
CONFIG_NET_CADENCE=y
# CONFIG_MACB is not set
CONFIG_NET_VENDOR_BROADCOM=y
CONFIG_B44=m
CONFIG_B44_PCI_AUTOSELECT=y
CONFIG_BNX2=m
CONFIG_CNIC=m
CONFIG_TIGON3=y
CONFIG_TIGON3_HWMON=y
# CONFIG_BNX2X is not set
# CONFIG_BNXT is not set
CONFIG_NET_VENDOR_BROCADE=y
CONFIG_BNA=m
CONFIG_NET_VENDOR_CAVIUM=y
# CONFIG_THUNDER_NIC_PF is not set
# CONFIG_THUNDER_NIC_VF is not set
# CONFIG_THUNDER_NIC_BGX is not set
# CONFIG_THUNDER_NIC_RGX is not set
CONFIG_CAVIUM_PTP=y
# CONFIG_LIQUIDIO is not set
# CONFIG_LIQUIDIO_VF is not set
CONFIG_NET_VENDOR_CHELSIO=y
# CONFIG_CHELSIO_T1 is not set
CONFIG_CHELSIO_T3=m
CONFIG_CHELSIO_T4=m
# CONFIG_CHELSIO_T4_DCB is not set
CONFIG_CHELSIO_T4VF=m
CONFIG_CHELSIO_LIB=m
CONFIG_NET_VENDOR_CISCO=y
CONFIG_ENIC=m
CONFIG_NET_VENDOR_CORTINA=y
# CONFIG_CX_ECAT is not set
CONFIG_DNET=m
CONFIG_NET_VENDOR_DEC=y
CONFIG_NET_TULIP=y
CONFIG_DE2104X=m
CONFIG_DE2104X_DSL=0
CONFIG_TULIP=y
# CONFIG_TULIP_MWI is not set
CONFIG_TULIP_MMIO=y
# CONFIG_TULIP_NAPI is not set
CONFIG_DE4X5=m
CONFIG_WINBOND_840=m
CONFIG_DM9102=m
CONFIG_ULI526X=m
CONFIG_PCMCIA_XIRCOM=m
# CONFIG_NET_VENDOR_DLINK is not set
CONFIG_NET_VENDOR_EMULEX=y
CONFIG_BE2NET=m
CONFIG_BE2NET_HWMON=y
CONFIG_NET_VENDOR_EZCHIP=y
# CONFIG_NET_VENDOR_EXAR is not set
# CONFIG_NET_VENDOR_HP is not set
CONFIG_NET_VENDOR_HUAWEI=y
# CONFIG_HINIC is not set
CONFIG_NET_VENDOR_INTEL=y
# CONFIG_E100 is not set
CONFIG_E1000=y
CONFIG_E1000E=y
CONFIG_E1000E_HWTS=y
CONFIG_IGB=y
CONFIG_IGB_HWMON=y
CONFIG_IGBVF=m
CONFIG_IXGB=m
CONFIG_IXGBE=y
CONFIG_IXGBE_HWMON=y
CONFIG_IXGBE_DCB=y
CONFIG_IXGBEVF=m
CONFIG_I40E=m
# CONFIG_I40E_DCB is not set
# CONFIG_I40EVF is not set
# CONFIG_ICE is not set
# CONFIG_FM10K is not set
# CONFIG_NET_VENDOR_I825XX is not set
CONFIG_JME=m
CONFIG_NET_VENDOR_MARVELL=y
CONFIG_MVMDIO=m
CONFIG_SKGE=m
CONFIG_SKGE_DEBUG=y
CONFIG_SKGE_GENESIS=y
CONFIG_SKY2=m
CONFIG_SKY2_DEBUG=y
CONFIG_NET_VENDOR_MELLANOX=y
CONFIG_MLX4_EN=m
CONFIG_MLX4_EN_DCB=y
CONFIG_MLX4_CORE=m
CONFIG_MLX4_DEBUG=y
CONFIG_MLX4_CORE_GEN2=y
# CONFIG_MLX5_CORE is not set
# CONFIG_MLXSW_CORE is not set
# CONFIG_MLXFW is not set
# CONFIG_NET_VENDOR_MICREL is not set
CONFIG_NET_VENDOR_MICROCHIP=y
# CONFIG_ENC28J60 is not set
# CONFIG_ENCX24J600 is not set
# CONFIG_LAN743X is not set
CONFIG_NET_VENDOR_MYRI=y
CONFIG_MYRI10GE=m
# CONFIG_FEALNX is not set
# CONFIG_NET_VENDOR_NATSEMI is not set
CONFIG_NET_VENDOR_NETRONOME=y
# CONFIG_NFP is not set
CONFIG_NET_VENDOR_NI=y
# CONFIG_NET_VENDOR_NVIDIA is not set
CONFIG_NET_VENDOR_OKI=y
CONFIG_ETHOC=m
CONFIG_NET_PACKET_ENGINE=y
# CONFIG_HAMACHI is not set
CONFIG_YELLOWFIN=m
CONFIG_NET_VENDOR_QLOGIC=y
CONFIG_QLA3XXX=m
CONFIG_QLCNIC=m
CONFIG_QLCNIC_SRIOV=y
CONFIG_QLCNIC_DCB=y
CONFIG_QLCNIC_HWMON=y
CONFIG_QLGE=m
CONFIG_NETXEN_NIC=m
# CONFIG_QED is not set
CONFIG_NET_VENDOR_QUALCOMM=y
# CONFIG_QCOM_EMAC is not set
# CONFIG_RMNET is not set
CONFIG_NET_VENDOR_REALTEK=y
# CONFIG_ATP is not set
CONFIG_8139CP=y
CONFIG_8139TOO=y
CONFIG_8139TOO_PIO=y
# CONFIG_8139TOO_TUNE_TWISTER is not set
CONFIG_8139TOO_8129=y
# CONFIG_8139_OLD_RX_RESET is not set
CONFIG_R8169=y
CONFIG_NET_VENDOR_RENESAS=y
# CONFIG_NET_VENDOR_RDC is not set
CONFIG_NET_VENDOR_ROCKER=y
CONFIG_NET_VENDOR_SAMSUNG=y
# CONFIG_SXGBE_ETH is not set
# CONFIG_NET_VENDOR_SEEQ is not set
# CONFIG_NET_VENDOR_SILAN is not set
# CONFIG_NET_VENDOR_SIS is not set
CONFIG_NET_VENDOR_SOLARFLARE=y
CONFIG_SFC=m
CONFIG_SFC_MTD=y
CONFIG_SFC_MCDI_MON=y
CONFIG_SFC_SRIOV=y
CONFIG_SFC_MCDI_LOGGING=y
# CONFIG_SFC_FALCON is not set
CONFIG_NET_VENDOR_SMSC=y
CONFIG_EPIC100=m
# CONFIG_SMSC911X is not set
CONFIG_SMSC9420=m
CONFIG_NET_VENDOR_SOCIONEXT=y
# CONFIG_NET_VENDOR_STMICRO is not set
# CONFIG_NET_VENDOR_SUN is not set
# CONFIG_NET_VENDOR_TEHUTI is not set
# CONFIG_NET_VENDOR_TI is not set
# CONFIG_NET_VENDOR_VIA is not set
# CONFIG_NET_VENDOR_WIZNET is not set
CONFIG_NET_VENDOR_SYNOPSYS=y
# CONFIG_DWC_XLGMAC is not set
# CONFIG_FDDI is not set
# CONFIG_HIPPI is not set
# CONFIG_NET_SB1000 is not set
CONFIG_MDIO_DEVICE=y
CONFIG_MDIO_BUS=y
CONFIG_MDIO_BITBANG=m
# CONFIG_MDIO_GPIO is not set
# CONFIG_MDIO_THUNDER is not set
CONFIG_PHYLIB=y
CONFIG_SWPHY=y
# CONFIG_LED_TRIGGER_PHY is not set

#
# MII PHY device drivers
#
CONFIG_AMD_PHY=m
# CONFIG_AQUANTIA_PHY is not set
CONFIG_AT803X_PHY=m
# CONFIG_BCM7XXX_PHY is not set
CONFIG_BCM87XX_PHY=m
CONFIG_BCM_NET_PHYLIB=m
CONFIG_BROADCOM_PHY=m
CONFIG_CICADA_PHY=m
# CONFIG_CORTINA_PHY is not set
CONFIG_DAVICOM_PHY=m
# CONFIG_DP83822_PHY is not set
# CONFIG_DP83848_PHY is not set
# CONFIG_DP83867_PHY is not set
CONFIG_FIXED_PHY=y
CONFIG_ICPLUS_PHY=m
# CONFIG_INTEL_XWAY_PHY is not set
CONFIG_LSI_ET1011C_PHY=m
CONFIG_LXT_PHY=m
CONFIG_MARVELL_PHY=m
# CONFIG_MARVELL_10G_PHY is not set
CONFIG_MICREL_PHY=m
# CONFIG_MICROCHIP_PHY is not set
# CONFIG_MICROSEMI_PHY is not set
CONFIG_NATIONAL_PHY=m
CONFIG_QSEMI_PHY=m
CONFIG_REALTEK_PHY=m
# CONFIG_RENESAS_PHY is not set
# CONFIG_ROCKCHIP_PHY is not set
CONFIG_SMSC_PHY=m
CONFIG_STE10XP=m
# CONFIG_TERANETICS_PHY is not set
CONFIG_VITESSE_PHY=m
# CONFIG_XILINX_GMII2RGMII is not set
# CONFIG_MICREL_KS8995MA is not set
# CONFIG_PLIP is not set
CONFIG_PPP=m
CONFIG_PPP_BSDCOMP=m
CONFIG_PPP_DEFLATE=m
CONFIG_PPP_FILTER=y
CONFIG_PPP_MPPE=m
CONFIG_PPP_MULTILINK=y
CONFIG_PPPOATM=m
CONFIG_PPPOE=m
CONFIG_PPTP=m
CONFIG_PPPOL2TP=m
CONFIG_PPP_ASYNC=m
CONFIG_PPP_SYNC_TTY=m
CONFIG_SLIP=m
CONFIG_SLHC=m
CONFIG_SLIP_COMPRESSED=y
CONFIG_SLIP_SMART=y
# CONFIG_SLIP_MODE_SLIP6 is not set
CONFIG_USB_NET_DRIVERS=y
CONFIG_USB_CATC=y
CONFIG_USB_KAWETH=y
CONFIG_USB_PEGASUS=y
CONFIG_USB_RTL8150=y
CONFIG_USB_RTL8152=m
# CONFIG_USB_LAN78XX is not set
CONFIG_USB_USBNET=y
CONFIG_USB_NET_AX8817X=y
CONFIG_USB_NET_AX88179_178A=m
CONFIG_USB_NET_CDCETHER=y
CONFIG_USB_NET_CDC_EEM=y
CONFIG_USB_NET_CDC_NCM=m
# CONFIG_USB_NET_HUAWEI_CDC_NCM is not set
CONFIG_USB_NET_CDC_MBIM=m
CONFIG_USB_NET_DM9601=y
# CONFIG_USB_NET_SR9700 is not set
# CONFIG_USB_NET_SR9800 is not set
CONFIG_USB_NET_SMSC75XX=y
CONFIG_USB_NET_SMSC95XX=y
CONFIG_USB_NET_GL620A=y
CONFIG_USB_NET_NET1080=y
CONFIG_USB_NET_PLUSB=y
CONFIG_USB_NET_MCS7830=y
CONFIG_USB_NET_RNDIS_HOST=y
CONFIG_USB_NET_CDC_SUBSET_ENABLE=y
CONFIG_USB_NET_CDC_SUBSET=y
CONFIG_USB_ALI_M5632=y
CONFIG_USB_AN2720=y
CONFIG_USB_BELKIN=y
CONFIG_USB_ARMLINUX=y
CONFIG_USB_EPSON2888=y
CONFIG_USB_KC2190=y
CONFIG_USB_NET_ZAURUS=y
CONFIG_USB_NET_CX82310_ETH=m
CONFIG_USB_NET_KALMIA=m
CONFIG_USB_NET_QMI_WWAN=m
CONFIG_USB_HSO=m
CONFIG_USB_NET_INT51X1=y
CONFIG_USB_IPHETH=y
CONFIG_USB_SIERRA_NET=y
CONFIG_USB_VL600=m
# CONFIG_USB_NET_CH9200 is not set
CONFIG_WLAN=y
# CONFIG_WIRELESS_WDS is not set
CONFIG_WLAN_VENDOR_ADMTEK=y
# CONFIG_ADM8211 is not set
CONFIG_WLAN_VENDOR_ATH=y
# CONFIG_ATH_DEBUG is not set
# CONFIG_ATH5K is not set
# CONFIG_ATH5K_PCI is not set
# CONFIG_ATH9K is not set
# CONFIG_ATH9K_HTC is not set
# CONFIG_CARL9170 is not set
# CONFIG_ATH6KL is not set
# CONFIG_AR5523 is not set
# CONFIG_WIL6210 is not set
# CONFIG_ATH10K is not set
# CONFIG_WCN36XX is not set
CONFIG_WLAN_VENDOR_ATMEL=y
# CONFIG_ATMEL is not set
# CONFIG_AT76C50X_USB is not set
CONFIG_WLAN_VENDOR_BROADCOM=y
# CONFIG_B43 is not set
# CONFIG_B43LEGACY is not set
# CONFIG_BRCMSMAC is not set
# CONFIG_BRCMFMAC is not set
CONFIG_WLAN_VENDOR_CISCO=y
# CONFIG_AIRO is not set
CONFIG_WLAN_VENDOR_INTEL=y
# CONFIG_IPW2100 is not set
# CONFIG_IPW2200 is not set
# CONFIG_IWL4965 is not set
# CONFIG_IWL3945 is not set
# CONFIG_IWLWIFI is not set
CONFIG_WLAN_VENDOR_INTERSIL=y
# CONFIG_HOSTAP is not set
# CONFIG_HERMES is not set
# CONFIG_P54_COMMON is not set
# CONFIG_PRISM54 is not set
CONFIG_WLAN_VENDOR_MARVELL=y
# CONFIG_LIBERTAS is not set
# CONFIG_LIBERTAS_THINFIRM is not set
# CONFIG_MWIFIEX is not set
# CONFIG_MWL8K is not set
CONFIG_WLAN_VENDOR_MEDIATEK=y
# CONFIG_MT7601U is not set
# CONFIG_MT76x2E is not set
CONFIG_WLAN_VENDOR_RALINK=y
# CONFIG_RT2X00 is not set
CONFIG_WLAN_VENDOR_REALTEK=y
# CONFIG_RTL8180 is not set
# CONFIG_RTL8187 is not set
CONFIG_RTL_CARDS=m
# CONFIG_RTL8192CE is not set
# CONFIG_RTL8192SE is not set
# CONFIG_RTL8192DE is not set
# CONFIG_RTL8723AE is not set
# CONFIG_RTL8723BE is not set
# CONFIG_RTL8188EE is not set
# CONFIG_RTL8192EE is not set
# CONFIG_RTL8821AE is not set
# CONFIG_RTL8192CU is not set
# CONFIG_RTL8XXXU is not set
CONFIG_WLAN_VENDOR_RSI=y
# CONFIG_RSI_91X is not set
CONFIG_WLAN_VENDOR_ST=y
# CONFIG_CW1200 is not set
CONFIG_WLAN_VENDOR_TI=y
# CONFIG_WL1251 is not set
# CONFIG_WL12XX is not set
# CONFIG_WL18XX is not set
# CONFIG_WLCORE is not set
CONFIG_WLAN_VENDOR_ZYDAS=y
# CONFIG_USB_ZD1201 is not set
# CONFIG_ZD1211RW is not set
CONFIG_WLAN_VENDOR_QUANTENNA=y
# CONFIG_QTNFMAC_PEARL_PCIE is not set
CONFIG_MAC80211_HWSIM=m
# CONFIG_USB_NET_RNDIS_WLAN is not set

#
# Enable WiMAX (Networking options) to see the WiMAX drivers
#
CONFIG_WAN=y
# CONFIG_LANMEDIA is not set
CONFIG_HDLC=m
CONFIG_HDLC_RAW=m
# CONFIG_HDLC_RAW_ETH is not set
CONFIG_HDLC_CISCO=m
CONFIG_HDLC_FR=m
CONFIG_HDLC_PPP=m

#
# X.25/LAPB support is disabled
#
# CONFIG_PCI200SYN is not set
# CONFIG_WANXL is not set
# CONFIG_PC300TOO is not set
# CONFIG_FARSYNC is not set
# CONFIG_DSCC4 is not set
CONFIG_DLCI=m
CONFIG_DLCI_MAX=8
# CONFIG_SBNI is not set
CONFIG_IEEE802154_DRIVERS=m
CONFIG_IEEE802154_FAKELB=m
# CONFIG_IEEE802154_AT86RF230 is not set
# CONFIG_IEEE802154_MRF24J40 is not set
# CONFIG_IEEE802154_CC2520 is not set
# CONFIG_IEEE802154_ATUSB is not set
# CONFIG_IEEE802154_ADF7242 is not set
# CONFIG_IEEE802154_CA8210 is not set
# CONFIG_IEEE802154_MCR20A is not set
CONFIG_XEN_NETDEV_FRONTEND=m
# CONFIG_XEN_NETDEV_BACKEND is not set
CONFIG_VMXNET3=m
# CONFIG_FUJITSU_ES is not set
CONFIG_HYPERV_NET=m
CONFIG_NETDEVSIM=m
CONFIG_ISDN=y
CONFIG_ISDN_I4L=m
CONFIG_ISDN_PPP=y
CONFIG_ISDN_PPP_VJ=y
CONFIG_ISDN_MPP=y
CONFIG_IPPP_FILTER=y
# CONFIG_ISDN_PPP_BSDCOMP is not set
CONFIG_ISDN_AUDIO=y
CONFIG_ISDN_TTY_FAX=y

#
# ISDN feature submodules
#
CONFIG_ISDN_DIVERSION=m

#
# ISDN4Linux hardware drivers
#

#
# Passive cards
#
# CONFIG_ISDN_DRV_HISAX is not set
CONFIG_ISDN_CAPI=m
# CONFIG_CAPI_TRACE is not set
CONFIG_ISDN_CAPI_CAPI20=m
CONFIG_ISDN_CAPI_MIDDLEWARE=y
CONFIG_ISDN_CAPI_CAPIDRV=m
# CONFIG_ISDN_CAPI_CAPIDRV_VERBOSE is not set

#
# CAPI hardware drivers
#
CONFIG_CAPI_AVM=y
CONFIG_ISDN_DRV_AVMB1_B1PCI=m
CONFIG_ISDN_DRV_AVMB1_B1PCIV4=y
CONFIG_ISDN_DRV_AVMB1_T1PCI=m
CONFIG_ISDN_DRV_AVMB1_C4=m
# CONFIG_CAPI_EICON is not set
CONFIG_ISDN_DRV_GIGASET=m
CONFIG_GIGASET_CAPI=y
CONFIG_GIGASET_BASE=m
CONFIG_GIGASET_M105=m
CONFIG_GIGASET_M101=m
# CONFIG_GIGASET_DEBUG is not set
CONFIG_HYSDN=m
CONFIG_HYSDN_CAPI=y
CONFIG_MISDN=m
CONFIG_MISDN_DSP=m
CONFIG_MISDN_L1OIP=m

#
# mISDN hardware drivers
#
CONFIG_MISDN_HFCPCI=m
CONFIG_MISDN_HFCMULTI=m
CONFIG_MISDN_HFCUSB=m
CONFIG_MISDN_AVMFRITZ=m
CONFIG_MISDN_SPEEDFAX=m
CONFIG_MISDN_INFINEON=m
CONFIG_MISDN_W6692=m
CONFIG_MISDN_NETJET=m
CONFIG_MISDN_IPAC=m
CONFIG_MISDN_ISAR=m
CONFIG_ISDN_HDLC=m
# CONFIG_NVM is not set

#
# Input device support
#
CONFIG_INPUT=y
CONFIG_INPUT_LEDS=y
CONFIG_INPUT_FF_MEMLESS=m
CONFIG_INPUT_POLLDEV=m
CONFIG_INPUT_SPARSEKMAP=m
# CONFIG_INPUT_MATRIXKMAP is not set

#
# Userland interfaces
#
CONFIG_INPUT_MOUSEDEV=y
# CONFIG_INPUT_MOUSEDEV_PSAUX is not set
CONFIG_INPUT_MOUSEDEV_SCREEN_X=1024
CONFIG_INPUT_MOUSEDEV_SCREEN_Y=768
# CONFIG_INPUT_JOYDEV is not set
CONFIG_INPUT_EVDEV=y
# CONFIG_INPUT_EVBUG is not set

#
# Input Device Drivers
#
CONFIG_INPUT_KEYBOARD=y
# CONFIG_KEYBOARD_ADP5588 is not set
# CONFIG_KEYBOARD_ADP5589 is not set
CONFIG_KEYBOARD_ATKBD=y
# CONFIG_KEYBOARD_QT1070 is not set
# CONFIG_KEYBOARD_QT2160 is not set
# CONFIG_KEYBOARD_DLINK_DIR685 is not set
# CONFIG_KEYBOARD_LKKBD is not set
# CONFIG_KEYBOARD_GPIO is not set
# CONFIG_KEYBOARD_GPIO_POLLED is not set
# CONFIG_KEYBOARD_TCA6416 is not set
# CONFIG_KEYBOARD_TCA8418 is not set
# CONFIG_KEYBOARD_MATRIX is not set
# CONFIG_KEYBOARD_LM8323 is not set
# CONFIG_KEYBOARD_LM8333 is not set
# CONFIG_KEYBOARD_MAX7359 is not set
# CONFIG_KEYBOARD_MCS is not set
# CONFIG_KEYBOARD_MPR121 is not set
# CONFIG_KEYBOARD_NEWTON is not set
# CONFIG_KEYBOARD_OPENCORES is not set
# CONFIG_KEYBOARD_SAMSUNG is not set
# CONFIG_KEYBOARD_STOWAWAY is not set
# CONFIG_KEYBOARD_SUNKBD is not set
# CONFIG_KEYBOARD_TM2_TOUCHKEY is not set
# CONFIG_KEYBOARD_XTKBD is not set
CONFIG_INPUT_MOUSE=y
CONFIG_MOUSE_PS2=y
CONFIG_MOUSE_PS2_ALPS=y
CONFIG_MOUSE_PS2_BYD=y
CONFIG_MOUSE_PS2_LOGIPS2PP=y
CONFIG_MOUSE_PS2_SYNAPTICS=y
CONFIG_MOUSE_PS2_SYNAPTICS_SMBUS=y
CONFIG_MOUSE_PS2_CYPRESS=y
CONFIG_MOUSE_PS2_LIFEBOOK=y
CONFIG_MOUSE_PS2_TRACKPOINT=y
CONFIG_MOUSE_PS2_ELANTECH=y
CONFIG_MOUSE_PS2_SENTELIC=y
# CONFIG_MOUSE_PS2_TOUCHKIT is not set
CONFIG_MOUSE_PS2_FOCALTECH=y
# CONFIG_MOUSE_PS2_VMMOUSE is not set
CONFIG_MOUSE_PS2_SMBUS=y
CONFIG_MOUSE_SERIAL=m
CONFIG_MOUSE_APPLETOUCH=m
CONFIG_MOUSE_BCM5974=m
CONFIG_MOUSE_CYAPA=m
# CONFIG_MOUSE_ELAN_I2C is not set
CONFIG_MOUSE_VSXXXAA=m
# CONFIG_MOUSE_GPIO is not set
CONFIG_MOUSE_SYNAPTICS_I2C=m
CONFIG_MOUSE_SYNAPTICS_USB=m
# CONFIG_INPUT_JOYSTICK is not set
CONFIG_INPUT_TABLET=y
CONFIG_TABLET_USB_ACECAD=m
CONFIG_TABLET_USB_AIPTEK=m
CONFIG_TABLET_USB_GTCO=m
# CONFIG_TABLET_USB_HANWANG is not set
CONFIG_TABLET_USB_KBTAB=m
# CONFIG_TABLET_USB_PEGASUS is not set
# CONFIG_TABLET_SERIAL_WACOM4 is not set
CONFIG_INPUT_TOUCHSCREEN=y
CONFIG_TOUCHSCREEN_PROPERTIES=y
# CONFIG_TOUCHSCREEN_ADS7846 is not set
# CONFIG_TOUCHSCREEN_AD7877 is not set
# CONFIG_TOUCHSCREEN_AD7879 is not set
# CONFIG_TOUCHSCREEN_ATMEL_MXT is not set
# CONFIG_TOUCHSCREEN_AUO_PIXCIR is not set
# CONFIG_TOUCHSCREEN_BU21013 is not set
# CONFIG_TOUCHSCREEN_CY8CTMG110 is not set
# CONFIG_TOUCHSCREEN_CYTTSP_CORE is not set
# CONFIG_TOUCHSCREEN_CYTTSP4_CORE is not set
# CONFIG_TOUCHSCREEN_DYNAPRO is not set
# CONFIG_TOUCHSCREEN_HAMPSHIRE is not set
# CONFIG_TOUCHSCREEN_EETI is not set
# CONFIG_TOUCHSCREEN_EGALAX_SERIAL is not set
# CONFIG_TOUCHSCREEN_EXC3000 is not set
# CONFIG_TOUCHSCREEN_FUJITSU is not set
# CONFIG_TOUCHSCREEN_GOODIX is not set
# CONFIG_TOUCHSCREEN_HIDEEP is not set
# CONFIG_TOUCHSCREEN_ILI210X is not set
# CONFIG_TOUCHSCREEN_S6SY761 is not set
# CONFIG_TOUCHSCREEN_GUNZE is not set
# CONFIG_TOUCHSCREEN_EKTF2127 is not set
# CONFIG_TOUCHSCREEN_ELAN is not set
# CONFIG_TOUCHSCREEN_ELO is not set
CONFIG_TOUCHSCREEN_WACOM_W8001=m
CONFIG_TOUCHSCREEN_WACOM_I2C=m
# CONFIG_TOUCHSCREEN_MAX11801 is not set
# CONFIG_TOUCHSCREEN_MCS5000 is not set
# CONFIG_TOUCHSCREEN_MMS114 is not set
# CONFIG_TOUCHSCREEN_MELFAS_MIP4 is not set
# CONFIG_TOUCHSCREEN_MTOUCH is not set
# CONFIG_TOUCHSCREEN_INEXIO is not set
# CONFIG_TOUCHSCREEN_MK712 is not set
# CONFIG_TOUCHSCREEN_PENMOUNT is not set
# CONFIG_TOUCHSCREEN_EDT_FT5X06 is not set
# CONFIG_TOUCHSCREEN_TOUCHRIGHT is not set
# CONFIG_TOUCHSCREEN_TOUCHWIN is not set
# CONFIG_TOUCHSCREEN_PIXCIR is not set
# CONFIG_TOUCHSCREEN_WDT87XX_I2C is not set
# CONFIG_TOUCHSCREEN_WM97XX is not set
# CONFIG_TOUCHSCREEN_USB_COMPOSITE is not set
# CONFIG_TOUCHSCREEN_TOUCHIT213 is not set
# CONFIG_TOUCHSCREEN_TSC_SERIO is not set
# CONFIG_TOUCHSCREEN_TSC2004 is not set
# CONFIG_TOUCHSCREEN_TSC2005 is not set
# CONFIG_TOUCHSCREEN_TSC2007 is not set
# CONFIG_TOUCHSCREEN_RM_TS is not set
# CONFIG_TOUCHSCREEN_SILEAD is not set
# CONFIG_TOUCHSCREEN_SIS_I2C is not set
# CONFIG_TOUCHSCREEN_ST1232 is not set
# CONFIG_TOUCHSCREEN_STMFTS is not set
# CONFIG_TOUCHSCREEN_SUR40 is not set
# CONFIG_TOUCHSCREEN_SURFACE3_SPI is not set
# CONFIG_TOUCHSCREEN_SX8654 is not set
# CONFIG_TOUCHSCREEN_TPS6507X is not set
# CONFIG_TOUCHSCREEN_ZET6223 is not set
# CONFIG_TOUCHSCREEN_ZFORCE is not set
# CONFIG_TOUCHSCREEN_ROHM_BU21023 is not set
CONFIG_INPUT_MISC=y
# CONFIG_INPUT_AD714X is not set
# CONFIG_INPUT_BMA150 is not set
# CONFIG_INPUT_E3X0_BUTTON is not set
CONFIG_INPUT_PCSPKR=m
# CONFIG_INPUT_MMA8450 is not set
CONFIG_INPUT_APANEL=m
# CONFIG_INPUT_GP2A is not set
# CONFIG_INPUT_GPIO_BEEPER is not set
# CONFIG_INPUT_GPIO_DECODER is not set
CONFIG_INPUT_ATLAS_BTNS=m
CONFIG_INPUT_ATI_REMOTE2=m
CONFIG_INPUT_KEYSPAN_REMOTE=m
# CONFIG_INPUT_KXTJ9 is not set
CONFIG_INPUT_POWERMATE=m
CONFIG_INPUT_YEALINK=m
CONFIG_INPUT_CM109=m
CONFIG_INPUT_UINPUT=m
# CONFIG_INPUT_PCF8574 is not set
# CONFIG_INPUT_PWM_BEEPER is not set
# CONFIG_INPUT_PWM_VIBRA is not set
# CONFIG_INPUT_GPIO_ROTARY_ENCODER is not set
# CONFIG_INPUT_ADXL34X is not set
# CONFIG_INPUT_IMS_PCU is not set
# CONFIG_INPUT_CMA3000 is not set
CONFIG_INPUT_XEN_KBDDEV_FRONTEND=m
# CONFIG_INPUT_IDEAPAD_SLIDEBAR is not set
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
# CONFIG_SERIO_CT82C710 is not set
# CONFIG_SERIO_PARKBD is not set
# CONFIG_SERIO_PCIPS2 is not set
CONFIG_SERIO_LIBPS2=y
CONFIG_SERIO_RAW=m
CONFIG_SERIO_ALTERA_PS2=m
# CONFIG_SERIO_PS2MULT is not set
CONFIG_SERIO_ARC_PS2=m
CONFIG_HYPERV_KEYBOARD=m
# CONFIG_SERIO_GPIO_PS2 is not set
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
# CONFIG_LEGACY_PTYS is not set
CONFIG_SERIAL_NONSTANDARD=y
# CONFIG_ROCKETPORT is not set
CONFIG_CYCLADES=m
# CONFIG_CYZ_INTR is not set
CONFIG_MOXA_INTELLIO=m
CONFIG_MOXA_SMARTIO=m
CONFIG_SYNCLINK=m
CONFIG_SYNCLINKMP=m
CONFIG_SYNCLINK_GT=m
CONFIG_NOZOMI=m
# CONFIG_ISI is not set
CONFIG_N_HDLC=m
CONFIG_N_GSM=m
# CONFIG_TRACE_SINK is not set
CONFIG_DEVMEM=y
# CONFIG_DEVKMEM is not set

#
# Serial drivers
#
CONFIG_SERIAL_EARLYCON=y
CONFIG_SERIAL_8250=y
# CONFIG_SERIAL_8250_DEPRECATED_OPTIONS is not set
CONFIG_SERIAL_8250_PNP=y
# CONFIG_SERIAL_8250_FINTEK is not set
CONFIG_SERIAL_8250_CONSOLE=y
CONFIG_SERIAL_8250_DMA=y
CONFIG_SERIAL_8250_PCI=y
CONFIG_SERIAL_8250_EXAR=y
CONFIG_SERIAL_8250_NR_UARTS=32
CONFIG_SERIAL_8250_RUNTIME_UARTS=4
CONFIG_SERIAL_8250_EXTENDED=y
CONFIG_SERIAL_8250_MANY_PORTS=y
CONFIG_SERIAL_8250_SHARE_IRQ=y
# CONFIG_SERIAL_8250_DETECT_IRQ is not set
CONFIG_SERIAL_8250_RSA=y
CONFIG_SERIAL_8250_DW=y
# CONFIG_SERIAL_8250_RT288X is not set
CONFIG_SERIAL_8250_LPSS=y
CONFIG_SERIAL_8250_MID=y
# CONFIG_SERIAL_8250_MOXA is not set

#
# Non-8250 serial port support
#
# CONFIG_SERIAL_MAX3100 is not set
# CONFIG_SERIAL_MAX310X is not set
# CONFIG_SERIAL_UARTLITE is not set
CONFIG_SERIAL_CORE=y
CONFIG_SERIAL_CORE_CONSOLE=y
CONFIG_SERIAL_JSM=m
# CONFIG_SERIAL_SCCNXP is not set
# CONFIG_SERIAL_SC16IS7XX is not set
# CONFIG_SERIAL_ALTERA_JTAGUART is not set
# CONFIG_SERIAL_ALTERA_UART is not set
# CONFIG_SERIAL_IFX6X60 is not set
CONFIG_SERIAL_ARC=m
CONFIG_SERIAL_ARC_NR_PORTS=1
# CONFIG_SERIAL_RP2 is not set
# CONFIG_SERIAL_FSL_LPUART is not set
# CONFIG_SERIAL_DEV_BUS is not set
# CONFIG_TTY_PRINTK is not set
CONFIG_PRINTER=m
# CONFIG_LP_CONSOLE is not set
CONFIG_PPDEV=m
CONFIG_HVC_DRIVER=y
CONFIG_HVC_IRQ=y
CONFIG_HVC_XEN=y
CONFIG_HVC_XEN_FRONTEND=y
CONFIG_VIRTIO_CONSOLE=y
CONFIG_IPMI_HANDLER=m
CONFIG_IPMI_DMI_DECODE=y
CONFIG_IPMI_PROC_INTERFACE=y
# CONFIG_IPMI_PANIC_EVENT is not set
CONFIG_IPMI_DEVICE_INTERFACE=m
CONFIG_IPMI_SI=m
# CONFIG_IPMI_SSIF is not set
CONFIG_IPMI_WATCHDOG=m
CONFIG_IPMI_POWEROFF=m
CONFIG_HW_RANDOM=y
CONFIG_HW_RANDOM_TIMERIOMEM=m
CONFIG_HW_RANDOM_INTEL=m
CONFIG_HW_RANDOM_AMD=m
CONFIG_HW_RANDOM_VIA=m
CONFIG_HW_RANDOM_VIRTIO=y
CONFIG_NVRAM=y
# CONFIG_R3964 is not set
# CONFIG_APPLICOM is not set
# CONFIG_MWAVE is not set
CONFIG_RAW_DRIVER=y
CONFIG_MAX_RAW_DEVS=8192
CONFIG_HPET=y
CONFIG_HPET_MMAP=y
# CONFIG_HPET_MMAP_DEFAULT is not set
CONFIG_HANGCHECK_TIMER=m
CONFIG_UV_MMTIMER=m
CONFIG_TCG_TPM=y
CONFIG_HW_RANDOM_TPM=y
CONFIG_TCG_TIS_CORE=y
CONFIG_TCG_TIS=y
# CONFIG_TCG_TIS_SPI is not set
# CONFIG_TCG_TIS_I2C_ATMEL is not set
# CONFIG_TCG_TIS_I2C_INFINEON is not set
# CONFIG_TCG_TIS_I2C_NUVOTON is not set
CONFIG_TCG_NSC=m
CONFIG_TCG_ATMEL=m
CONFIG_TCG_INFINEON=m
# CONFIG_TCG_XEN is not set
CONFIG_TCG_CRB=y
# CONFIG_TCG_VTPM_PROXY is not set
# CONFIG_TCG_TIS_ST33ZP24_I2C is not set
# CONFIG_TCG_TIS_ST33ZP24_SPI is not set
CONFIG_TELCLOCK=m
CONFIG_DEVPORT=y
# CONFIG_XILLYBUS is not set

#
# I2C support
#
CONFIG_I2C=y
CONFIG_ACPI_I2C_OPREGION=y
CONFIG_I2C_BOARDINFO=y
CONFIG_I2C_COMPAT=y
CONFIG_I2C_CHARDEV=m
CONFIG_I2C_MUX=m

#
# Multiplexer I2C Chip support
#
# CONFIG_I2C_MUX_GPIO is not set
# CONFIG_I2C_MUX_LTC4306 is not set
# CONFIG_I2C_MUX_PCA9541 is not set
# CONFIG_I2C_MUX_PCA954x is not set
# CONFIG_I2C_MUX_REG is not set
# CONFIG_I2C_MUX_MLXCPLD is not set
CONFIG_I2C_HELPER_AUTO=y
CONFIG_I2C_SMBUS=y
CONFIG_I2C_ALGOBIT=y
CONFIG_I2C_ALGOPCA=m

#
# I2C Hardware Bus support
#

#
# PC SMBus host controller drivers
#
# CONFIG_I2C_ALI1535 is not set
# CONFIG_I2C_ALI1563 is not set
# CONFIG_I2C_ALI15X3 is not set
CONFIG_I2C_AMD756=m
CONFIG_I2C_AMD756_S4882=m
CONFIG_I2C_AMD8111=m
CONFIG_I2C_I801=y
CONFIG_I2C_ISCH=m
CONFIG_I2C_ISMT=m
CONFIG_I2C_PIIX4=m
CONFIG_I2C_NFORCE2=m
CONFIG_I2C_NFORCE2_S4985=m
# CONFIG_I2C_SIS5595 is not set
# CONFIG_I2C_SIS630 is not set
CONFIG_I2C_SIS96X=m
CONFIG_I2C_VIA=m
CONFIG_I2C_VIAPRO=m

#
# ACPI drivers
#
CONFIG_I2C_SCMI=m

#
# I2C system bus drivers (mostly embedded / system-on-chip)
#
# CONFIG_I2C_CBUS_GPIO is not set
CONFIG_I2C_DESIGNWARE_CORE=m
CONFIG_I2C_DESIGNWARE_PLATFORM=m
# CONFIG_I2C_DESIGNWARE_SLAVE is not set
CONFIG_I2C_DESIGNWARE_PCI=m
# CONFIG_I2C_DESIGNWARE_BAYTRAIL is not set
# CONFIG_I2C_EMEV2 is not set
# CONFIG_I2C_GPIO is not set
# CONFIG_I2C_OCORES is not set
CONFIG_I2C_PCA_PLATFORM=m
CONFIG_I2C_SIMTEC=m
# CONFIG_I2C_XILINX is not set

#
# External I2C/SMBus adapter drivers
#
CONFIG_I2C_DIOLAN_U2C=m
CONFIG_I2C_PARPORT=m
CONFIG_I2C_PARPORT_LIGHT=m
# CONFIG_I2C_ROBOTFUZZ_OSIF is not set
# CONFIG_I2C_TAOS_EVM is not set
CONFIG_I2C_TINY_USB=m
CONFIG_I2C_VIPERBOARD=m

#
# Other I2C/SMBus bus drivers
#
# CONFIG_I2C_MLXCPLD is not set
CONFIG_I2C_STUB=m
# CONFIG_I2C_SLAVE is not set
# CONFIG_I2C_DEBUG_CORE is not set
# CONFIG_I2C_DEBUG_ALGO is not set
# CONFIG_I2C_DEBUG_BUS is not set
CONFIG_SPI=y
# CONFIG_SPI_DEBUG is not set
CONFIG_SPI_MASTER=y

#
# SPI Master Controller Drivers
#
# CONFIG_SPI_ALTERA is not set
# CONFIG_SPI_AXI_SPI_ENGINE is not set
# CONFIG_SPI_BITBANG is not set
# CONFIG_SPI_BUTTERFLY is not set
# CONFIG_SPI_CADENCE is not set
CONFIG_SPI_DESIGNWARE=m
# CONFIG_SPI_DW_PCI is not set
# CONFIG_SPI_DW_MMIO is not set
# CONFIG_SPI_GPIO is not set
# CONFIG_SPI_LM70_LLP is not set
# CONFIG_SPI_OC_TINY is not set
CONFIG_SPI_PXA2XX=m
CONFIG_SPI_PXA2XX_PCI=m
# CONFIG_SPI_ROCKCHIP is not set
# CONFIG_SPI_SC18IS602 is not set
# CONFIG_SPI_XCOMM is not set
# CONFIG_SPI_XILINX is not set
# CONFIG_SPI_ZYNQMP_GQSPI is not set

#
# SPI Protocol Masters
#
# CONFIG_SPI_SPIDEV is not set
# CONFIG_SPI_LOOPBACK_TEST is not set
# CONFIG_SPI_TLE62X0 is not set
# CONFIG_SPI_SLAVE is not set
# CONFIG_SPMI is not set
# CONFIG_HSI is not set
CONFIG_PPS=y
# CONFIG_PPS_DEBUG is not set

#
# PPS clients support
#
# CONFIG_PPS_CLIENT_KTIMER is not set
CONFIG_PPS_CLIENT_LDISC=m
CONFIG_PPS_CLIENT_PARPORT=m
CONFIG_PPS_CLIENT_GPIO=m

#
# PPS generators support
#

#
# PTP clock support
#
CONFIG_PTP_1588_CLOCK=y
CONFIG_DP83640_PHY=m
CONFIG_PTP_1588_CLOCK_KVM=y
CONFIG_PINCTRL=y
CONFIG_PINMUX=y
CONFIG_PINCONF=y
CONFIG_GENERIC_PINCONF=y
# CONFIG_DEBUG_PINCTRL is not set
# CONFIG_PINCTRL_AMD is not set
# CONFIG_PINCTRL_MCP23S08 is not set
# CONFIG_PINCTRL_SX150X is not set
CONFIG_PINCTRL_BAYTRAIL=y
# CONFIG_PINCTRL_CHERRYVIEW is not set
# CONFIG_PINCTRL_BROXTON is not set
# CONFIG_PINCTRL_CANNONLAKE is not set
# CONFIG_PINCTRL_CEDARFORK is not set
# CONFIG_PINCTRL_DENVERTON is not set
# CONFIG_PINCTRL_GEMINILAKE is not set
# CONFIG_PINCTRL_LEWISBURG is not set
# CONFIG_PINCTRL_SUNRISEPOINT is not set
CONFIG_GPIOLIB=y
CONFIG_GPIO_ACPI=y
CONFIG_GPIOLIB_IRQCHIP=y
# CONFIG_DEBUG_GPIO is not set
CONFIG_GPIO_SYSFS=y

#
# Memory mapped GPIO drivers
#
# CONFIG_GPIO_AMDPT is not set
# CONFIG_GPIO_DWAPB is not set
# CONFIG_GPIO_EXAR is not set
# CONFIG_GPIO_GENERIC_PLATFORM is not set
# CONFIG_GPIO_ICH is not set
CONFIG_GPIO_LYNXPOINT=m
# CONFIG_GPIO_MB86S7X is not set
CONFIG_GPIO_MOCKUP=y
# CONFIG_GPIO_VX855 is not set

#
# Port-mapped I/O GPIO drivers
#
# CONFIG_GPIO_F7188X is not set
# CONFIG_GPIO_IT87 is not set
# CONFIG_GPIO_SCH is not set
# CONFIG_GPIO_SCH311X is not set
# CONFIG_GPIO_WINBOND is not set
# CONFIG_GPIO_WS16C48 is not set

#
# I2C GPIO expanders
#
# CONFIG_GPIO_ADP5588 is not set
# CONFIG_GPIO_MAX7300 is not set
# CONFIG_GPIO_MAX732X is not set
# CONFIG_GPIO_PCA953X is not set
# CONFIG_GPIO_PCF857X is not set
# CONFIG_GPIO_TPIC2810 is not set

#
# MFD GPIO expanders
#

#
# PCI GPIO expanders
#
# CONFIG_GPIO_AMD8111 is not set
# CONFIG_GPIO_ML_IOH is not set
# CONFIG_GPIO_PCI_IDIO_16 is not set
# CONFIG_GPIO_PCIE_IDIO_24 is not set
# CONFIG_GPIO_RDC321X is not set

#
# SPI GPIO expanders
#
# CONFIG_GPIO_MAX3191X is not set
# CONFIG_GPIO_MAX7301 is not set
# CONFIG_GPIO_MC33880 is not set
# CONFIG_GPIO_PISOSR is not set
# CONFIG_GPIO_XRA1403 is not set

#
# USB GPIO expanders
#
# CONFIG_GPIO_VIPERBOARD is not set
# CONFIG_W1 is not set
# CONFIG_POWER_AVS is not set
CONFIG_POWER_RESET=y
# CONFIG_POWER_RESET_RESTART is not set
CONFIG_POWER_SUPPLY=y
# CONFIG_POWER_SUPPLY_DEBUG is not set
# CONFIG_PDA_POWER is not set
# CONFIG_TEST_POWER is not set
# CONFIG_BATTERY_DS2780 is not set
# CONFIG_BATTERY_DS2781 is not set
# CONFIG_BATTERY_DS2782 is not set
# CONFIG_BATTERY_SBS is not set
# CONFIG_CHARGER_SBS is not set
# CONFIG_MANAGER_SBS is not set
# CONFIG_BATTERY_BQ27XXX is not set
# CONFIG_BATTERY_MAX17040 is not set
# CONFIG_BATTERY_MAX17042 is not set
# CONFIG_CHARGER_ISP1704 is not set
# CONFIG_CHARGER_MAX8903 is not set
# CONFIG_CHARGER_LP8727 is not set
# CONFIG_CHARGER_GPIO is not set
# CONFIG_CHARGER_LTC3651 is not set
# CONFIG_CHARGER_BQ2415X is not set
# CONFIG_CHARGER_BQ24190 is not set
# CONFIG_CHARGER_BQ24257 is not set
# CONFIG_CHARGER_BQ24735 is not set
# CONFIG_CHARGER_BQ25890 is not set
CONFIG_CHARGER_SMB347=m
# CONFIG_BATTERY_GAUGE_LTC2941 is not set
# CONFIG_CHARGER_RT9455 is not set
CONFIG_HWMON=y
CONFIG_HWMON_VID=m
# CONFIG_HWMON_DEBUG_CHIP is not set

#
# Native drivers
#
CONFIG_SENSORS_ABITUGURU=m
CONFIG_SENSORS_ABITUGURU3=m
# CONFIG_SENSORS_AD7314 is not set
CONFIG_SENSORS_AD7414=m
CONFIG_SENSORS_AD7418=m
CONFIG_SENSORS_ADM1021=m
CONFIG_SENSORS_ADM1025=m
CONFIG_SENSORS_ADM1026=m
CONFIG_SENSORS_ADM1029=m
CONFIG_SENSORS_ADM1031=m
CONFIG_SENSORS_ADM9240=m
CONFIG_SENSORS_ADT7X10=m
# CONFIG_SENSORS_ADT7310 is not set
CONFIG_SENSORS_ADT7410=m
CONFIG_SENSORS_ADT7411=m
CONFIG_SENSORS_ADT7462=m
CONFIG_SENSORS_ADT7470=m
CONFIG_SENSORS_ADT7475=m
CONFIG_SENSORS_ASC7621=m
CONFIG_SENSORS_K8TEMP=m
CONFIG_SENSORS_K10TEMP=m
CONFIG_SENSORS_FAM15H_POWER=m
CONFIG_SENSORS_APPLESMC=m
CONFIG_SENSORS_ASB100=m
# CONFIG_SENSORS_ASPEED is not set
CONFIG_SENSORS_ATXP1=m
CONFIG_SENSORS_DS620=m
CONFIG_SENSORS_DS1621=m
CONFIG_SENSORS_DELL_SMM=m
CONFIG_SENSORS_I5K_AMB=m
CONFIG_SENSORS_F71805F=m
CONFIG_SENSORS_F71882FG=m
CONFIG_SENSORS_F75375S=m
CONFIG_SENSORS_FSCHMD=m
# CONFIG_SENSORS_FTSTEUTATES is not set
CONFIG_SENSORS_GL518SM=m
CONFIG_SENSORS_GL520SM=m
CONFIG_SENSORS_G760A=m
# CONFIG_SENSORS_G762 is not set
# CONFIG_SENSORS_HIH6130 is not set
CONFIG_SENSORS_IBMAEM=m
CONFIG_SENSORS_IBMPEX=m
# CONFIG_SENSORS_I5500 is not set
CONFIG_SENSORS_CORETEMP=m
CONFIG_SENSORS_IT87=m
# CONFIG_SENSORS_JC42 is not set
# CONFIG_SENSORS_POWR1220 is not set
CONFIG_SENSORS_LINEAGE=m
# CONFIG_SENSORS_LTC2945 is not set
# CONFIG_SENSORS_LTC2990 is not set
CONFIG_SENSORS_LTC4151=m
CONFIG_SENSORS_LTC4215=m
# CONFIG_SENSORS_LTC4222 is not set
CONFIG_SENSORS_LTC4245=m
# CONFIG_SENSORS_LTC4260 is not set
CONFIG_SENSORS_LTC4261=m
# CONFIG_SENSORS_MAX1111 is not set
CONFIG_SENSORS_MAX16065=m
CONFIG_SENSORS_MAX1619=m
CONFIG_SENSORS_MAX1668=m
CONFIG_SENSORS_MAX197=m
# CONFIG_SENSORS_MAX31722 is not set
# CONFIG_SENSORS_MAX6621 is not set
CONFIG_SENSORS_MAX6639=m
CONFIG_SENSORS_MAX6642=m
CONFIG_SENSORS_MAX6650=m
CONFIG_SENSORS_MAX6697=m
# CONFIG_SENSORS_MAX31790 is not set
CONFIG_SENSORS_MCP3021=m
# CONFIG_SENSORS_TC654 is not set
# CONFIG_SENSORS_ADCXX is not set
CONFIG_SENSORS_LM63=m
# CONFIG_SENSORS_LM70 is not set
CONFIG_SENSORS_LM73=m
CONFIG_SENSORS_LM75=m
CONFIG_SENSORS_LM77=m
CONFIG_SENSORS_LM78=m
CONFIG_SENSORS_LM80=m
CONFIG_SENSORS_LM83=m
CONFIG_SENSORS_LM85=m
CONFIG_SENSORS_LM87=m
CONFIG_SENSORS_LM90=m
CONFIG_SENSORS_LM92=m
CONFIG_SENSORS_LM93=m
CONFIG_SENSORS_LM95234=m
CONFIG_SENSORS_LM95241=m
CONFIG_SENSORS_LM95245=m
CONFIG_SENSORS_PC87360=m
CONFIG_SENSORS_PC87427=m
CONFIG_SENSORS_NTC_THERMISTOR=m
# CONFIG_SENSORS_NCT6683 is not set
CONFIG_SENSORS_NCT6775=m
# CONFIG_SENSORS_NCT7802 is not set
# CONFIG_SENSORS_NCT7904 is not set
CONFIG_SENSORS_PCF8591=m
CONFIG_PMBUS=m
CONFIG_SENSORS_PMBUS=m
CONFIG_SENSORS_ADM1275=m
# CONFIG_SENSORS_IBM_CFFPS is not set
# CONFIG_SENSORS_IR35221 is not set
CONFIG_SENSORS_LM25066=m
CONFIG_SENSORS_LTC2978=m
# CONFIG_SENSORS_LTC3815 is not set
CONFIG_SENSORS_MAX16064=m
# CONFIG_SENSORS_MAX20751 is not set
# CONFIG_SENSORS_MAX31785 is not set
CONFIG_SENSORS_MAX34440=m
CONFIG_SENSORS_MAX8688=m
# CONFIG_SENSORS_TPS40422 is not set
# CONFIG_SENSORS_TPS53679 is not set
CONFIG_SENSORS_UCD9000=m
CONFIG_SENSORS_UCD9200=m
CONFIG_SENSORS_ZL6100=m
# CONFIG_SENSORS_SHT15 is not set
CONFIG_SENSORS_SHT21=m
# CONFIG_SENSORS_SHT3x is not set
# CONFIG_SENSORS_SHTC1 is not set
CONFIG_SENSORS_SIS5595=m
CONFIG_SENSORS_DME1737=m
CONFIG_SENSORS_EMC1403=m
# CONFIG_SENSORS_EMC2103 is not set
CONFIG_SENSORS_EMC6W201=m
CONFIG_SENSORS_SMSC47M1=m
CONFIG_SENSORS_SMSC47M192=m
CONFIG_SENSORS_SMSC47B397=m
CONFIG_SENSORS_SCH56XX_COMMON=m
CONFIG_SENSORS_SCH5627=m
CONFIG_SENSORS_SCH5636=m
# CONFIG_SENSORS_STTS751 is not set
# CONFIG_SENSORS_SMM665 is not set
# CONFIG_SENSORS_ADC128D818 is not set
CONFIG_SENSORS_ADS1015=m
CONFIG_SENSORS_ADS7828=m
# CONFIG_SENSORS_ADS7871 is not set
CONFIG_SENSORS_AMC6821=m
CONFIG_SENSORS_INA209=m
CONFIG_SENSORS_INA2XX=m
# CONFIG_SENSORS_INA3221 is not set
# CONFIG_SENSORS_TC74 is not set
CONFIG_SENSORS_THMC50=m
CONFIG_SENSORS_TMP102=m
# CONFIG_SENSORS_TMP103 is not set
# CONFIG_SENSORS_TMP108 is not set
CONFIG_SENSORS_TMP401=m
CONFIG_SENSORS_TMP421=m
CONFIG_SENSORS_VIA_CPUTEMP=m
CONFIG_SENSORS_VIA686A=m
CONFIG_SENSORS_VT1211=m
CONFIG_SENSORS_VT8231=m
# CONFIG_SENSORS_W83773G is not set
CONFIG_SENSORS_W83781D=m
CONFIG_SENSORS_W83791D=m
CONFIG_SENSORS_W83792D=m
CONFIG_SENSORS_W83793=m
CONFIG_SENSORS_W83795=m
# CONFIG_SENSORS_W83795_FANCTRL is not set
CONFIG_SENSORS_W83L785TS=m
CONFIG_SENSORS_W83L786NG=m
CONFIG_SENSORS_W83627HF=m
CONFIG_SENSORS_W83627EHF=m
# CONFIG_SENSORS_XGENE is not set

#
# ACPI drivers
#
CONFIG_SENSORS_ACPI_POWER=m
CONFIG_SENSORS_ATK0110=m
CONFIG_THERMAL=y
# CONFIG_THERMAL_STATISTICS is not set
CONFIG_THERMAL_EMERGENCY_POWEROFF_DELAY_MS=0
CONFIG_THERMAL_HWMON=y
CONFIG_THERMAL_WRITABLE_TRIPS=y
CONFIG_THERMAL_DEFAULT_GOV_STEP_WISE=y
# CONFIG_THERMAL_DEFAULT_GOV_FAIR_SHARE is not set
# CONFIG_THERMAL_DEFAULT_GOV_USER_SPACE is not set
# CONFIG_THERMAL_DEFAULT_GOV_POWER_ALLOCATOR is not set
CONFIG_THERMAL_GOV_FAIR_SHARE=y
CONFIG_THERMAL_GOV_STEP_WISE=y
CONFIG_THERMAL_GOV_BANG_BANG=y
CONFIG_THERMAL_GOV_USER_SPACE=y
# CONFIG_THERMAL_GOV_POWER_ALLOCATOR is not set
# CONFIG_CLOCK_THERMAL is not set
# CONFIG_DEVFREQ_THERMAL is not set
# CONFIG_THERMAL_EMULATION is not set
CONFIG_INTEL_POWERCLAMP=m
CONFIG_X86_PKG_TEMP_THERMAL=m
# CONFIG_INTEL_SOC_DTS_THERMAL is not set

#
# ACPI INT340X thermal drivers
#
# CONFIG_INT340X_THERMAL is not set
CONFIG_INTEL_PCH_THERMAL=m
CONFIG_WATCHDOG=y
CONFIG_WATCHDOG_CORE=y
# CONFIG_WATCHDOG_NOWAYOUT is not set
CONFIG_WATCHDOG_HANDLE_BOOT_ENABLED=y
# CONFIG_WATCHDOG_SYSFS is not set

#
# Watchdog Device Drivers
#
CONFIG_SOFT_WATCHDOG=m
CONFIG_WDAT_WDT=m
# CONFIG_XILINX_WATCHDOG is not set
# CONFIG_ZIIRAVE_WATCHDOG is not set
# CONFIG_CADENCE_WATCHDOG is not set
# CONFIG_DW_WATCHDOG is not set
# CONFIG_MAX63XX_WATCHDOG is not set
# CONFIG_ACQUIRE_WDT is not set
# CONFIG_ADVANTECH_WDT is not set
CONFIG_ALIM1535_WDT=m
CONFIG_ALIM7101_WDT=m
# CONFIG_EBC_C384_WDT is not set
CONFIG_F71808E_WDT=m
CONFIG_SP5100_TCO=m
CONFIG_SBC_FITPC2_WATCHDOG=m
# CONFIG_EUROTECH_WDT is not set
CONFIG_IB700_WDT=m
CONFIG_IBMASR=m
# CONFIG_WAFER_WDT is not set
CONFIG_I6300ESB_WDT=y
CONFIG_IE6XX_WDT=m
CONFIG_ITCO_WDT=y
CONFIG_ITCO_VENDOR_SUPPORT=y
CONFIG_IT8712F_WDT=m
CONFIG_IT87_WDT=m
CONFIG_HP_WATCHDOG=m
CONFIG_HPWDT_NMI_DECODING=y
# CONFIG_SC1200_WDT is not set
# CONFIG_PC87413_WDT is not set
CONFIG_NV_TCO=m
# CONFIG_60XX_WDT is not set
# CONFIG_CPU5_WDT is not set
CONFIG_SMSC_SCH311X_WDT=m
# CONFIG_SMSC37B787_WDT is not set
CONFIG_VIA_WDT=m
CONFIG_W83627HF_WDT=m
CONFIG_W83877F_WDT=m
CONFIG_W83977F_WDT=m
CONFIG_MACHZ_WDT=m
# CONFIG_SBC_EPX_C3_WATCHDOG is not set
# CONFIG_INTEL_MEI_WDT is not set
# CONFIG_NI903X_WDT is not set
# CONFIG_NIC7018_WDT is not set
# CONFIG_MEN_A21_WDT is not set
CONFIG_XEN_WDT=m

#
# PCI-based Watchdog Cards
#
CONFIG_PCIPCWATCHDOG=m
CONFIG_WDTPCI=m

#
# USB-based Watchdog Cards
#
CONFIG_USBPCWATCHDOG=m

#
# Watchdog Pretimeout Governors
#
# CONFIG_WATCHDOG_PRETIMEOUT_GOV is not set
CONFIG_SSB_POSSIBLE=y
CONFIG_SSB=m
CONFIG_SSB_SPROM=y
CONFIG_SSB_PCIHOST_POSSIBLE=y
CONFIG_SSB_PCIHOST=y
CONFIG_SSB_SDIOHOST_POSSIBLE=y
CONFIG_SSB_SDIOHOST=y
# CONFIG_SSB_SILENT is not set
# CONFIG_SSB_DEBUG is not set
# CONFIG_SSB_DRIVER_GPIO is not set
CONFIG_BCMA_POSSIBLE=y
CONFIG_BCMA=m
CONFIG_BCMA_HOST_PCI_POSSIBLE=y
CONFIG_BCMA_HOST_PCI=y
# CONFIG_BCMA_HOST_SOC is not set
CONFIG_BCMA_DRIVER_PCI=y
CONFIG_BCMA_DRIVER_GMAC_CMN=y
# CONFIG_BCMA_DRIVER_GPIO is not set
# CONFIG_BCMA_DEBUG is not set

#
# Multifunction device drivers
#
CONFIG_MFD_CORE=y
# CONFIG_MFD_AS3711 is not set
# CONFIG_PMIC_ADP5520 is not set
# CONFIG_MFD_AAT2870_CORE is not set
# CONFIG_MFD_BCM590XX is not set
# CONFIG_MFD_BD9571MWV is not set
# CONFIG_MFD_AXP20X_I2C is not set
# CONFIG_MFD_CROS_EC is not set
# CONFIG_PMIC_DA903X is not set
# CONFIG_MFD_DA9052_SPI is not set
# CONFIG_MFD_DA9052_I2C is not set
# CONFIG_MFD_DA9055 is not set
# CONFIG_MFD_DA9062 is not set
# CONFIG_MFD_DA9063 is not set
# CONFIG_MFD_DA9150 is not set
# CONFIG_MFD_DLN2 is not set
# CONFIG_MFD_MC13XXX_SPI is not set
# CONFIG_MFD_MC13XXX_I2C is not set
# CONFIG_HTC_PASIC3 is not set
# CONFIG_HTC_I2CPLD is not set
# CONFIG_MFD_INTEL_QUARK_I2C_GPIO is not set
CONFIG_LPC_ICH=y
CONFIG_LPC_SCH=m
# CONFIG_INTEL_SOC_PMIC is not set
# CONFIG_INTEL_SOC_PMIC_CHTWC is not set
# CONFIG_INTEL_SOC_PMIC_CHTDC_TI is not set
# CONFIG_MFD_INTEL_LPSS_ACPI is not set
# CONFIG_MFD_INTEL_LPSS_PCI is not set
# CONFIG_MFD_JANZ_CMODIO is not set
# CONFIG_MFD_KEMPLD is not set
# CONFIG_MFD_88PM800 is not set
# CONFIG_MFD_88PM805 is not set
# CONFIG_MFD_88PM860X is not set
# CONFIG_MFD_MAX14577 is not set
# CONFIG_MFD_MAX77693 is not set
# CONFIG_MFD_MAX77843 is not set
# CONFIG_MFD_MAX8907 is not set
# CONFIG_MFD_MAX8925 is not set
# CONFIG_MFD_MAX8997 is not set
# CONFIG_MFD_MAX8998 is not set
# CONFIG_MFD_MT6397 is not set
# CONFIG_MFD_MENF21BMC is not set
# CONFIG_EZX_PCAP is not set
CONFIG_MFD_VIPERBOARD=m
# CONFIG_MFD_RETU is not set
# CONFIG_MFD_PCF50633 is not set
# CONFIG_UCB1400_CORE is not set
# CONFIG_MFD_RDC321X is not set
# CONFIG_MFD_RT5033 is not set
# CONFIG_MFD_RC5T583 is not set
# CONFIG_MFD_SEC_CORE is not set
# CONFIG_MFD_SI476X_CORE is not set
CONFIG_MFD_SM501=m
# CONFIG_MFD_SM501_GPIO is not set
# CONFIG_MFD_SKY81452 is not set
# CONFIG_MFD_SMSC is not set
# CONFIG_ABX500_CORE is not set
# CONFIG_MFD_SYSCON is not set
# CONFIG_MFD_TI_AM335X_TSCADC is not set
# CONFIG_MFD_LP3943 is not set
# CONFIG_MFD_LP8788 is not set
# CONFIG_MFD_TI_LMU is not set
# CONFIG_MFD_PALMAS is not set
# CONFIG_TPS6105X is not set
# CONFIG_TPS65010 is not set
# CONFIG_TPS6507X is not set
# CONFIG_MFD_TPS65086 is not set
# CONFIG_MFD_TPS65090 is not set
# CONFIG_MFD_TPS68470 is not set
# CONFIG_MFD_TI_LP873X is not set
# CONFIG_MFD_TPS6586X is not set
# CONFIG_MFD_TPS65910 is not set
# CONFIG_MFD_TPS65912_I2C is not set
# CONFIG_MFD_TPS65912_SPI is not set
# CONFIG_MFD_TPS80031 is not set
# CONFIG_TWL4030_CORE is not set
# CONFIG_TWL6040_CORE is not set
# CONFIG_MFD_WL1273_CORE is not set
# CONFIG_MFD_LM3533 is not set
CONFIG_MFD_VX855=m
# CONFIG_MFD_ARIZONA_I2C is not set
# CONFIG_MFD_ARIZONA_SPI is not set
# CONFIG_MFD_WM8400 is not set
# CONFIG_MFD_WM831X_I2C is not set
# CONFIG_MFD_WM831X_SPI is not set
# CONFIG_MFD_WM8350_I2C is not set
# CONFIG_MFD_WM8994 is not set
# CONFIG_REGULATOR is not set
CONFIG_RC_CORE=m
CONFIG_RC_MAP=m
# CONFIG_LIRC is not set
CONFIG_RC_DECODERS=y
CONFIG_IR_NEC_DECODER=m
CONFIG_IR_RC5_DECODER=m
CONFIG_IR_RC6_DECODER=m
CONFIG_IR_JVC_DECODER=m
CONFIG_IR_SONY_DECODER=m
CONFIG_IR_SANYO_DECODER=m
CONFIG_IR_SHARP_DECODER=m
CONFIG_IR_MCE_KBD_DECODER=m
CONFIG_IR_XMP_DECODER=m
# CONFIG_IR_IMON_DECODER is not set
CONFIG_RC_DEVICES=y
CONFIG_RC_ATI_REMOTE=m
CONFIG_IR_ENE=m
CONFIG_IR_IMON=m
# CONFIG_IR_IMON_RAW is not set
CONFIG_IR_MCEUSB=m
CONFIG_IR_ITE_CIR=m
CONFIG_IR_FINTEK=m
CONFIG_IR_NUVOTON=m
CONFIG_IR_REDRAT3=m
CONFIG_IR_STREAMZAP=m
CONFIG_IR_WINBOND_CIR=m
# CONFIG_IR_IGORPLUGUSB is not set
CONFIG_IR_IGUANA=m
CONFIG_IR_TTUSBIR=m
# CONFIG_RC_LOOPBACK is not set
# CONFIG_IR_SERIAL is not set
# CONFIG_IR_SIR is not set
CONFIG_MEDIA_SUPPORT=m

#
# Multimedia core support
#
CONFIG_MEDIA_CAMERA_SUPPORT=y
CONFIG_MEDIA_ANALOG_TV_SUPPORT=y
CONFIG_MEDIA_DIGITAL_TV_SUPPORT=y
CONFIG_MEDIA_RADIO_SUPPORT=y
# CONFIG_MEDIA_SDR_SUPPORT is not set
# CONFIG_MEDIA_CEC_SUPPORT is not set
# CONFIG_MEDIA_CONTROLLER is not set
CONFIG_VIDEO_DEV=m
CONFIG_VIDEO_V4L2=m
# CONFIG_VIDEO_ADV_DEBUG is not set
# CONFIG_VIDEO_FIXED_MINOR_RANGES is not set
CONFIG_VIDEO_TUNER=m
CONFIG_VIDEOBUF_GEN=m
CONFIG_VIDEOBUF_DMA_SG=m
CONFIG_VIDEOBUF_VMALLOC=m
CONFIG_VIDEOBUF_DVB=m
CONFIG_DVB_CORE=m
# CONFIG_DVB_MMAP is not set
CONFIG_DVB_NET=y
CONFIG_TTPCI_EEPROM=m
CONFIG_DVB_MAX_ADAPTERS=8
CONFIG_DVB_DYNAMIC_MINORS=y
# CONFIG_DVB_DEMUX_SECTION_LOSS_LOG is not set
# CONFIG_DVB_ULE_DEBUG is not set

#
# Media drivers
#
CONFIG_MEDIA_USB_SUPPORT=y

#
# Webcam devices
#
CONFIG_USB_VIDEO_CLASS=m
CONFIG_USB_VIDEO_CLASS_INPUT_EVDEV=y
CONFIG_USB_GSPCA=m
CONFIG_USB_M5602=m
CONFIG_USB_STV06XX=m
CONFIG_USB_GL860=m
CONFIG_USB_GSPCA_BENQ=m
CONFIG_USB_GSPCA_CONEX=m
CONFIG_USB_GSPCA_CPIA1=m
# CONFIG_USB_GSPCA_DTCS033 is not set
CONFIG_USB_GSPCA_ETOMS=m
CONFIG_USB_GSPCA_FINEPIX=m
CONFIG_USB_GSPCA_JEILINJ=m
CONFIG_USB_GSPCA_JL2005BCD=m
# CONFIG_USB_GSPCA_KINECT is not set
CONFIG_USB_GSPCA_KONICA=m
CONFIG_USB_GSPCA_MARS=m
CONFIG_USB_GSPCA_MR97310A=m
CONFIG_USB_GSPCA_NW80X=m
CONFIG_USB_GSPCA_OV519=m
CONFIG_USB_GSPCA_OV534=m
CONFIG_USB_GSPCA_OV534_9=m
CONFIG_USB_GSPCA_PAC207=m
CONFIG_USB_GSPCA_PAC7302=m
CONFIG_USB_GSPCA_PAC7311=m
CONFIG_USB_GSPCA_SE401=m
CONFIG_USB_GSPCA_SN9C2028=m
CONFIG_USB_GSPCA_SN9C20X=m
CONFIG_USB_GSPCA_SONIXB=m
CONFIG_USB_GSPCA_SONIXJ=m
CONFIG_USB_GSPCA_SPCA500=m
CONFIG_USB_GSPCA_SPCA501=m
CONFIG_USB_GSPCA_SPCA505=m
CONFIG_USB_GSPCA_SPCA506=m
CONFIG_USB_GSPCA_SPCA508=m
CONFIG_USB_GSPCA_SPCA561=m
CONFIG_USB_GSPCA_SPCA1528=m
CONFIG_USB_GSPCA_SQ905=m
CONFIG_USB_GSPCA_SQ905C=m
CONFIG_USB_GSPCA_SQ930X=m
CONFIG_USB_GSPCA_STK014=m
# CONFIG_USB_GSPCA_STK1135 is not set
CONFIG_USB_GSPCA_STV0680=m
CONFIG_USB_GSPCA_SUNPLUS=m
CONFIG_USB_GSPCA_T613=m
CONFIG_USB_GSPCA_TOPRO=m
# CONFIG_USB_GSPCA_TOUPTEK is not set
CONFIG_USB_GSPCA_TV8532=m
CONFIG_USB_GSPCA_VC032X=m
CONFIG_USB_GSPCA_VICAM=m
CONFIG_USB_GSPCA_XIRLINK_CIT=m
CONFIG_USB_GSPCA_ZC3XX=m
CONFIG_USB_PWC=m
# CONFIG_USB_PWC_DEBUG is not set
CONFIG_USB_PWC_INPUT_EVDEV=y
# CONFIG_VIDEO_CPIA2 is not set
CONFIG_USB_ZR364XX=m
CONFIG_USB_STKWEBCAM=m
CONFIG_USB_S2255=m
# CONFIG_VIDEO_USBTV is not set

#
# Analog TV USB devices
#
CONFIG_VIDEO_PVRUSB2=m
CONFIG_VIDEO_PVRUSB2_SYSFS=y
CONFIG_VIDEO_PVRUSB2_DVB=y
# CONFIG_VIDEO_PVRUSB2_DEBUGIFC is not set
CONFIG_VIDEO_HDPVR=m
CONFIG_VIDEO_USBVISION=m
# CONFIG_VIDEO_STK1160_COMMON is not set
# CONFIG_VIDEO_GO7007 is not set

#
# Analog/digital TV USB devices
#
CONFIG_VIDEO_AU0828=m
CONFIG_VIDEO_AU0828_V4L2=y
# CONFIG_VIDEO_AU0828_RC is not set
CONFIG_VIDEO_CX231XX=m
CONFIG_VIDEO_CX231XX_RC=y
CONFIG_VIDEO_CX231XX_ALSA=m
CONFIG_VIDEO_CX231XX_DVB=m
CONFIG_VIDEO_TM6000=m
CONFIG_VIDEO_TM6000_ALSA=m
CONFIG_VIDEO_TM6000_DVB=m

#
# Digital TV USB devices
#
CONFIG_DVB_USB=m
# CONFIG_DVB_USB_DEBUG is not set
CONFIG_DVB_USB_DIB3000MC=m
CONFIG_DVB_USB_A800=m
CONFIG_DVB_USB_DIBUSB_MB=m
# CONFIG_DVB_USB_DIBUSB_MB_FAULTY is not set
CONFIG_DVB_USB_DIBUSB_MC=m
CONFIG_DVB_USB_DIB0700=m
CONFIG_DVB_USB_UMT_010=m
CONFIG_DVB_USB_CXUSB=m
CONFIG_DVB_USB_M920X=m
CONFIG_DVB_USB_DIGITV=m
CONFIG_DVB_USB_VP7045=m
CONFIG_DVB_USB_VP702X=m
CONFIG_DVB_USB_GP8PSK=m
CONFIG_DVB_USB_NOVA_T_USB2=m
CONFIG_DVB_USB_TTUSB2=m
CONFIG_DVB_USB_DTT200U=m
CONFIG_DVB_USB_OPERA1=m
CONFIG_DVB_USB_AF9005=m
CONFIG_DVB_USB_AF9005_REMOTE=m
CONFIG_DVB_USB_PCTV452E=m
CONFIG_DVB_USB_DW2102=m
CONFIG_DVB_USB_CINERGY_T2=m
CONFIG_DVB_USB_DTV5100=m
CONFIG_DVB_USB_FRIIO=m
CONFIG_DVB_USB_AZ6027=m
CONFIG_DVB_USB_TECHNISAT_USB2=m
CONFIG_DVB_USB_V2=m
CONFIG_DVB_USB_AF9015=m
CONFIG_DVB_USB_AF9035=m
CONFIG_DVB_USB_ANYSEE=m
CONFIG_DVB_USB_AU6610=m
CONFIG_DVB_USB_AZ6007=m
CONFIG_DVB_USB_CE6230=m
CONFIG_DVB_USB_EC168=m
CONFIG_DVB_USB_GL861=m
CONFIG_DVB_USB_LME2510=m
CONFIG_DVB_USB_MXL111SF=m
CONFIG_DVB_USB_RTL28XXU=m
# CONFIG_DVB_USB_DVBSKY is not set
# CONFIG_DVB_USB_ZD1301 is not set
CONFIG_DVB_TTUSB_BUDGET=m
CONFIG_DVB_TTUSB_DEC=m
CONFIG_SMS_USB_DRV=m
CONFIG_DVB_B2C2_FLEXCOP_USB=m
# CONFIG_DVB_B2C2_FLEXCOP_USB_DEBUG is not set
# CONFIG_DVB_AS102 is not set

#
# Webcam, TV (analog/digital) USB devices
#
CONFIG_VIDEO_EM28XX=m
# CONFIG_VIDEO_EM28XX_V4L2 is not set
CONFIG_VIDEO_EM28XX_ALSA=m
CONFIG_VIDEO_EM28XX_DVB=m
CONFIG_VIDEO_EM28XX_RC=m
CONFIG_MEDIA_PCI_SUPPORT=y

#
# Media capture support
#
# CONFIG_VIDEO_MEYE is not set
# CONFIG_VIDEO_SOLO6X10 is not set
# CONFIG_VIDEO_TW5864 is not set
# CONFIG_VIDEO_TW68 is not set
# CONFIG_VIDEO_TW686X is not set
# CONFIG_VIDEO_ZORAN is not set

#
# Media capture/analog TV support
#
CONFIG_VIDEO_IVTV=m
# CONFIG_VIDEO_IVTV_DEPRECATED_IOCTLS is not set
# CONFIG_VIDEO_IVTV_ALSA is not set
CONFIG_VIDEO_FB_IVTV=m
# CONFIG_VIDEO_HEXIUM_GEMINI is not set
# CONFIG_VIDEO_HEXIUM_ORION is not set
# CONFIG_VIDEO_MXB is not set
# CONFIG_VIDEO_DT3155 is not set

#
# Media capture/analog/hybrid TV support
#
CONFIG_VIDEO_CX18=m
CONFIG_VIDEO_CX18_ALSA=m
CONFIG_VIDEO_CX23885=m
CONFIG_MEDIA_ALTERA_CI=m
# CONFIG_VIDEO_CX25821 is not set
CONFIG_VIDEO_CX88=m
CONFIG_VIDEO_CX88_ALSA=m
CONFIG_VIDEO_CX88_BLACKBIRD=m
CONFIG_VIDEO_CX88_DVB=m
CONFIG_VIDEO_CX88_ENABLE_VP3054=y
CONFIG_VIDEO_CX88_VP3054=m
CONFIG_VIDEO_CX88_MPEG=m
CONFIG_VIDEO_BT848=m
CONFIG_DVB_BT8XX=m
CONFIG_VIDEO_SAA7134=m
CONFIG_VIDEO_SAA7134_ALSA=m
CONFIG_VIDEO_SAA7134_RC=y
CONFIG_VIDEO_SAA7134_DVB=m
CONFIG_VIDEO_SAA7164=m

#
# Media digital TV PCI Adapters
#
CONFIG_DVB_AV7110_IR=y
CONFIG_DVB_AV7110=m
CONFIG_DVB_AV7110_OSD=y
CONFIG_DVB_BUDGET_CORE=m
CONFIG_DVB_BUDGET=m
CONFIG_DVB_BUDGET_CI=m
CONFIG_DVB_BUDGET_AV=m
CONFIG_DVB_BUDGET_PATCH=m
CONFIG_DVB_B2C2_FLEXCOP_PCI=m
# CONFIG_DVB_B2C2_FLEXCOP_PCI_DEBUG is not set
CONFIG_DVB_PLUTO2=m
CONFIG_DVB_DM1105=m
CONFIG_DVB_PT1=m
# CONFIG_DVB_PT3 is not set
CONFIG_MANTIS_CORE=m
CONFIG_DVB_MANTIS=m
CONFIG_DVB_HOPPER=m
CONFIG_DVB_NGENE=m
CONFIG_DVB_DDBRIDGE=m
# CONFIG_DVB_DDBRIDGE_MSIENABLE is not set
# CONFIG_DVB_SMIPCIE is not set
# CONFIG_DVB_NETUP_UNIDVB is not set
# CONFIG_V4L_PLATFORM_DRIVERS is not set
# CONFIG_V4L_MEM2MEM_DRIVERS is not set
# CONFIG_V4L_TEST_DRIVERS is not set
# CONFIG_DVB_PLATFORM_DRIVERS is not set

#
# Supported MMC/SDIO adapters
#
CONFIG_SMS_SDIO_DRV=m
CONFIG_RADIO_ADAPTERS=y
CONFIG_RADIO_TEA575X=m
# CONFIG_RADIO_SI470X is not set
# CONFIG_RADIO_SI4713 is not set
# CONFIG_USB_MR800 is not set
# CONFIG_USB_DSBR is not set
# CONFIG_RADIO_MAXIRADIO is not set
# CONFIG_RADIO_SHARK is not set
# CONFIG_RADIO_SHARK2 is not set
# CONFIG_USB_KEENE is not set
# CONFIG_USB_RAREMONO is not set
# CONFIG_USB_MA901 is not set
# CONFIG_RADIO_TEA5764 is not set
# CONFIG_RADIO_SAA7706H is not set
# CONFIG_RADIO_TEF6862 is not set
# CONFIG_RADIO_WL1273 is not set

#
# Texas Instruments WL128x FM driver (ST based)
#

#
# Supported FireWire (IEEE 1394) Adapters
#
CONFIG_DVB_FIREDTV=m
CONFIG_DVB_FIREDTV_INPUT=y
CONFIG_MEDIA_COMMON_OPTIONS=y

#
# common driver options
#
CONFIG_VIDEO_CX2341X=m
CONFIG_VIDEO_TVEEPROM=m
CONFIG_CYPRESS_FIRMWARE=m
CONFIG_VIDEOBUF2_CORE=m
CONFIG_VIDEOBUF2_V4L2=m
CONFIG_VIDEOBUF2_MEMOPS=m
CONFIG_VIDEOBUF2_VMALLOC=m
CONFIG_VIDEOBUF2_DMA_SG=m
CONFIG_VIDEOBUF2_DVB=m
CONFIG_DVB_B2C2_FLEXCOP=m
CONFIG_VIDEO_SAA7146=m
CONFIG_VIDEO_SAA7146_VV=m
CONFIG_SMS_SIANO_MDTV=m
CONFIG_SMS_SIANO_RC=y
# CONFIG_SMS_SIANO_DEBUGFS is not set

#
# Media ancillary drivers (tuners, sensors, i2c, spi, frontends)
#
CONFIG_MEDIA_SUBDRV_AUTOSELECT=y
CONFIG_MEDIA_ATTACH=y
CONFIG_VIDEO_IR_I2C=m

#
# Audio decoders, processors and mixers
#
CONFIG_VIDEO_TVAUDIO=m
CONFIG_VIDEO_TDA7432=m
CONFIG_VIDEO_MSP3400=m
CONFIG_VIDEO_CS3308=m
CONFIG_VIDEO_CS5345=m
CONFIG_VIDEO_CS53L32A=m
CONFIG_VIDEO_WM8775=m
CONFIG_VIDEO_WM8739=m
CONFIG_VIDEO_VP27SMPX=m

#
# RDS decoders
#
CONFIG_VIDEO_SAA6588=m

#
# Video decoders
#
CONFIG_VIDEO_SAA711X=m

#
# Video and audio decoders
#
CONFIG_VIDEO_SAA717X=m
CONFIG_VIDEO_CX25840=m

#
# Video encoders
#
CONFIG_VIDEO_SAA7127=m

#
# Camera sensor devices
#

#
# Flash devices
#

#
# Video improvement chips
#
CONFIG_VIDEO_UPD64031A=m
CONFIG_VIDEO_UPD64083=m

#
# Audio/Video compression chips
#
CONFIG_VIDEO_SAA6752HS=m

#
# SDR tuner chips
#

#
# Miscellaneous helper chips
#
CONFIG_VIDEO_M52790=m

#
# Sensors used on soc_camera driver
#

#
# Media SPI Adapters
#
# CONFIG_CXD2880_SPI_DRV is not set
CONFIG_MEDIA_TUNER=m
CONFIG_MEDIA_TUNER_SIMPLE=m
CONFIG_MEDIA_TUNER_TDA18250=m
CONFIG_MEDIA_TUNER_TDA8290=m
CONFIG_MEDIA_TUNER_TDA827X=m
CONFIG_MEDIA_TUNER_TDA18271=m
CONFIG_MEDIA_TUNER_TDA9887=m
CONFIG_MEDIA_TUNER_TEA5761=m
CONFIG_MEDIA_TUNER_TEA5767=m
CONFIG_MEDIA_TUNER_MT20XX=m
CONFIG_MEDIA_TUNER_MT2060=m
CONFIG_MEDIA_TUNER_MT2063=m
CONFIG_MEDIA_TUNER_MT2266=m
CONFIG_MEDIA_TUNER_MT2131=m
CONFIG_MEDIA_TUNER_QT1010=m
CONFIG_MEDIA_TUNER_XC2028=m
CONFIG_MEDIA_TUNER_XC5000=m
CONFIG_MEDIA_TUNER_XC4000=m
CONFIG_MEDIA_TUNER_MXL5005S=m
CONFIG_MEDIA_TUNER_MXL5007T=m
CONFIG_MEDIA_TUNER_MC44S803=m
CONFIG_MEDIA_TUNER_MAX2165=m
CONFIG_MEDIA_TUNER_TDA18218=m
CONFIG_MEDIA_TUNER_FC0011=m
CONFIG_MEDIA_TUNER_FC0012=m
CONFIG_MEDIA_TUNER_FC0013=m
CONFIG_MEDIA_TUNER_TDA18212=m
CONFIG_MEDIA_TUNER_E4000=m
CONFIG_MEDIA_TUNER_FC2580=m
CONFIG_MEDIA_TUNER_M88RS6000T=m
CONFIG_MEDIA_TUNER_TUA9001=m
CONFIG_MEDIA_TUNER_SI2157=m
CONFIG_MEDIA_TUNER_IT913X=m
CONFIG_MEDIA_TUNER_R820T=m
CONFIG_MEDIA_TUNER_QM1D1C0042=m

#
# Multistandard (satellite) frontends
#
CONFIG_DVB_STB0899=m
CONFIG_DVB_STB6100=m
CONFIG_DVB_STV090x=m
CONFIG_DVB_STV0910=m
CONFIG_DVB_STV6110x=m
CONFIG_DVB_STV6111=m
CONFIG_DVB_MXL5XX=m
CONFIG_DVB_M88DS3103=m

#
# Multistandard (cable + terrestrial) frontends
#
CONFIG_DVB_DRXK=m
CONFIG_DVB_TDA18271C2DD=m
CONFIG_DVB_SI2165=m
CONFIG_DVB_MN88472=m
CONFIG_DVB_MN88473=m

#
# DVB-S (satellite) frontends
#
CONFIG_DVB_CX24110=m
CONFIG_DVB_CX24123=m
CONFIG_DVB_MT312=m
CONFIG_DVB_ZL10036=m
CONFIG_DVB_ZL10039=m
CONFIG_DVB_S5H1420=m
CONFIG_DVB_STV0288=m
CONFIG_DVB_STB6000=m
CONFIG_DVB_STV0299=m
CONFIG_DVB_STV6110=m
CONFIG_DVB_STV0900=m
CONFIG_DVB_TDA8083=m
CONFIG_DVB_TDA10086=m
CONFIG_DVB_TDA8261=m
CONFIG_DVB_VES1X93=m
CONFIG_DVB_TUNER_ITD1000=m
CONFIG_DVB_TUNER_CX24113=m
CONFIG_DVB_TDA826X=m
CONFIG_DVB_TUA6100=m
CONFIG_DVB_CX24116=m
CONFIG_DVB_CX24117=m
CONFIG_DVB_CX24120=m
CONFIG_DVB_SI21XX=m
CONFIG_DVB_TS2020=m
CONFIG_DVB_DS3000=m
CONFIG_DVB_MB86A16=m
CONFIG_DVB_TDA10071=m

#
# DVB-T (terrestrial) frontends
#
CONFIG_DVB_SP8870=m
CONFIG_DVB_SP887X=m
CONFIG_DVB_CX22700=m
CONFIG_DVB_CX22702=m
CONFIG_DVB_DRXD=m
CONFIG_DVB_L64781=m
CONFIG_DVB_TDA1004X=m
CONFIG_DVB_NXT6000=m
CONFIG_DVB_MT352=m
CONFIG_DVB_ZL10353=m
CONFIG_DVB_DIB3000MB=m
CONFIG_DVB_DIB3000MC=m
CONFIG_DVB_DIB7000M=m
CONFIG_DVB_DIB7000P=m
CONFIG_DVB_TDA10048=m
CONFIG_DVB_AF9013=m
CONFIG_DVB_EC100=m
CONFIG_DVB_STV0367=m
CONFIG_DVB_CXD2820R=m
CONFIG_DVB_CXD2841ER=m
CONFIG_DVB_RTL2830=m
CONFIG_DVB_RTL2832=m
CONFIG_DVB_SI2168=m
CONFIG_DVB_GP8PSK_FE=m

#
# DVB-C (cable) frontends
#
CONFIG_DVB_VES1820=m
CONFIG_DVB_TDA10021=m
CONFIG_DVB_TDA10023=m
CONFIG_DVB_STV0297=m

#
# ATSC (North American/Korean Terrestrial/Cable DTV) frontends
#
CONFIG_DVB_NXT200X=m
CONFIG_DVB_OR51211=m
CONFIG_DVB_OR51132=m
CONFIG_DVB_BCM3510=m
CONFIG_DVB_LGDT330X=m
CONFIG_DVB_LGDT3305=m
CONFIG_DVB_LGDT3306A=m
CONFIG_DVB_LG2160=m
CONFIG_DVB_S5H1409=m
CONFIG_DVB_AU8522=m
CONFIG_DVB_AU8522_DTV=m
CONFIG_DVB_AU8522_V4L=m
CONFIG_DVB_S5H1411=m

#
# ISDB-T (terrestrial) frontends
#
CONFIG_DVB_S921=m
CONFIG_DVB_DIB8000=m
CONFIG_DVB_MB86A20S=m

#
# ISDB-S (satellite) & ISDB-T (terrestrial) frontends
#
CONFIG_DVB_TC90522=m

#
# Digital terrestrial only tuners/PLL
#
CONFIG_DVB_PLL=m
CONFIG_DVB_TUNER_DIB0070=m
CONFIG_DVB_TUNER_DIB0090=m

#
# SEC control devices for DVB-S
#
CONFIG_DVB_DRX39XYJ=m
CONFIG_DVB_LNBH25=m
CONFIG_DVB_LNBP21=m
CONFIG_DVB_LNBP22=m
CONFIG_DVB_ISL6405=m
CONFIG_DVB_ISL6421=m
CONFIG_DVB_ISL6423=m
CONFIG_DVB_A8293=m
CONFIG_DVB_LGS8GXX=m
CONFIG_DVB_ATBM8830=m
CONFIG_DVB_TDA665x=m
CONFIG_DVB_IX2505V=m
CONFIG_DVB_M88RS2000=m
CONFIG_DVB_AF9033=m

#
# Common Interface (EN50221) controller drivers
#
CONFIG_DVB_CXD2099=m

#
# Tools to develop new frontends
#

#
# Graphics support
#
CONFIG_AGP=y
CONFIG_AGP_AMD64=y
CONFIG_AGP_INTEL=y
CONFIG_AGP_SIS=y
CONFIG_AGP_VIA=y
CONFIG_INTEL_GTT=y
CONFIG_VGA_ARB=y
CONFIG_VGA_ARB_MAX_GPUS=64
CONFIG_VGA_SWITCHEROO=y
CONFIG_DRM=m
CONFIG_DRM_MIPI_DSI=y
# CONFIG_DRM_DP_AUX_CHARDEV is not set
# CONFIG_DRM_DEBUG_MM_SELFTEST is not set
CONFIG_DRM_KMS_HELPER=m
CONFIG_DRM_KMS_FB_HELPER=y
CONFIG_DRM_FBDEV_EMULATION=y
CONFIG_DRM_FBDEV_OVERALLOC=100
CONFIG_DRM_LOAD_EDID_FIRMWARE=y
CONFIG_DRM_TTM=m

#
# I2C encoder or helper chips
#
CONFIG_DRM_I2C_CH7006=m
CONFIG_DRM_I2C_SIL164=m
CONFIG_DRM_I2C_NXP_TDA998X=m
# CONFIG_DRM_RADEON is not set
# CONFIG_DRM_AMDGPU is not set

#
# ACP (Audio CoProcessor) Configuration
#

#
# AMD Library routines
#
# CONFIG_DRM_NOUVEAU is not set
CONFIG_DRM_I915=m
# CONFIG_DRM_I915_ALPHA_SUPPORT is not set
CONFIG_DRM_I915_CAPTURE_ERROR=y
CONFIG_DRM_I915_COMPRESS_ERROR=y
CONFIG_DRM_I915_USERPTR=y
# CONFIG_DRM_I915_GVT is not set

#
# drm/i915 Debugging
#
# CONFIG_DRM_I915_WERROR is not set
# CONFIG_DRM_I915_DEBUG is not set
# CONFIG_DRM_I915_SW_FENCE_DEBUG_OBJECTS is not set
# CONFIG_DRM_I915_SW_FENCE_CHECK_DAG is not set
# CONFIG_DRM_I915_SELFTEST is not set
# CONFIG_DRM_I915_LOW_LEVEL_TRACEPOINTS is not set
# CONFIG_DRM_I915_DEBUG_VBLANK_EVADE is not set
CONFIG_DRM_VGEM=m
CONFIG_DRM_VMWGFX=m
CONFIG_DRM_VMWGFX_FBCON=y
CONFIG_DRM_GMA500=m
CONFIG_DRM_GMA600=y
CONFIG_DRM_GMA3600=y
CONFIG_DRM_UDL=m
CONFIG_DRM_AST=m
CONFIG_DRM_MGAG200=m
CONFIG_DRM_CIRRUS_QEMU=m
CONFIG_DRM_QXL=m
# CONFIG_DRM_BOCHS is not set
# CONFIG_DRM_VIRTIO_GPU is not set
CONFIG_DRM_PANEL=y

#
# Display Panels
#
# CONFIG_DRM_PANEL_RASPBERRYPI_TOUCHSCREEN is not set
CONFIG_DRM_BRIDGE=y
CONFIG_DRM_PANEL_BRIDGE=y

#
# Display Interface Bridges
#
# CONFIG_DRM_ANALOGIX_ANX78XX is not set
# CONFIG_DRM_HISI_HIBMC is not set
# CONFIG_DRM_TINYDRM is not set
# CONFIG_DRM_LEGACY is not set
CONFIG_DRM_PANEL_ORIENTATION_QUIRKS=y

#
# Frame buffer Devices
#
CONFIG_FB=y
# CONFIG_FIRMWARE_EDID is not set
CONFIG_FB_CMDLINE=y
CONFIG_FB_NOTIFY=y
CONFIG_FB_BOOT_VESA_SUPPORT=y
CONFIG_FB_CFB_FILLRECT=y
CONFIG_FB_CFB_COPYAREA=y
CONFIG_FB_CFB_IMAGEBLIT=y
CONFIG_FB_SYS_FILLRECT=m
CONFIG_FB_SYS_COPYAREA=m
CONFIG_FB_SYS_IMAGEBLIT=m
# CONFIG_FB_FOREIGN_ENDIAN is not set
CONFIG_FB_SYS_FOPS=m
CONFIG_FB_DEFERRED_IO=y
# CONFIG_FB_MODE_HELPERS is not set
CONFIG_FB_TILEBLITTING=y

#
# Frame buffer hardware drivers
#
# CONFIG_FB_CIRRUS is not set
# CONFIG_FB_PM2 is not set
# CONFIG_FB_CYBER2000 is not set
# CONFIG_FB_ARC is not set
# CONFIG_FB_ASILIANT is not set
# CONFIG_FB_IMSTT is not set
# CONFIG_FB_VGA16 is not set
# CONFIG_FB_UVESA is not set
CONFIG_FB_VESA=y
CONFIG_FB_EFI=y
# CONFIG_FB_N411 is not set
# CONFIG_FB_HGA is not set
# CONFIG_FB_OPENCORES is not set
# CONFIG_FB_S1D13XXX is not set
# CONFIG_FB_NVIDIA is not set
# CONFIG_FB_RIVA is not set
# CONFIG_FB_I740 is not set
# CONFIG_FB_LE80578 is not set
# CONFIG_FB_INTEL is not set
# CONFIG_FB_MATROX is not set
# CONFIG_FB_RADEON is not set
# CONFIG_FB_ATY128 is not set
# CONFIG_FB_ATY is not set
# CONFIG_FB_S3 is not set
# CONFIG_FB_SAVAGE is not set
# CONFIG_FB_SIS is not set
# CONFIG_FB_VIA is not set
# CONFIG_FB_NEOMAGIC is not set
# CONFIG_FB_KYRO is not set
# CONFIG_FB_3DFX is not set
# CONFIG_FB_VOODOO1 is not set
# CONFIG_FB_VT8623 is not set
# CONFIG_FB_TRIDENT is not set
# CONFIG_FB_ARK is not set
# CONFIG_FB_PM3 is not set
# CONFIG_FB_CARMINE is not set
# CONFIG_FB_SM501 is not set
# CONFIG_FB_SMSCUFX is not set
# CONFIG_FB_UDL is not set
# CONFIG_FB_IBM_GXT4500 is not set
# CONFIG_FB_VIRTUAL is not set
# CONFIG_XEN_FBDEV_FRONTEND is not set
# CONFIG_FB_METRONOME is not set
# CONFIG_FB_MB862XX is not set
# CONFIG_FB_BROADSHEET is not set
# CONFIG_FB_AUO_K190X is not set
CONFIG_FB_HYPERV=m
# CONFIG_FB_SIMPLE is not set
# CONFIG_FB_SM712 is not set
CONFIG_BACKLIGHT_LCD_SUPPORT=y
CONFIG_LCD_CLASS_DEVICE=m
# CONFIG_LCD_L4F00242T03 is not set
# CONFIG_LCD_LMS283GF05 is not set
# CONFIG_LCD_LTV350QV is not set
# CONFIG_LCD_ILI922X is not set
# CONFIG_LCD_ILI9320 is not set
# CONFIG_LCD_TDO24M is not set
# CONFIG_LCD_VGG2432A4 is not set
CONFIG_LCD_PLATFORM=m
# CONFIG_LCD_S6E63M0 is not set
# CONFIG_LCD_LD9040 is not set
# CONFIG_LCD_AMS369FG06 is not set
# CONFIG_LCD_LMS501KF03 is not set
# CONFIG_LCD_HX8357 is not set
CONFIG_BACKLIGHT_CLASS_DEVICE=y
# CONFIG_BACKLIGHT_GENERIC is not set
# CONFIG_BACKLIGHT_PWM is not set
CONFIG_BACKLIGHT_APPLE=m
# CONFIG_BACKLIGHT_PM8941_WLED is not set
# CONFIG_BACKLIGHT_SAHARA is not set
# CONFIG_BACKLIGHT_ADP8860 is not set
# CONFIG_BACKLIGHT_ADP8870 is not set
# CONFIG_BACKLIGHT_LM3630A is not set
# CONFIG_BACKLIGHT_LM3639 is not set
# CONFIG_BACKLIGHT_LP855X is not set
# CONFIG_BACKLIGHT_GPIO is not set
# CONFIG_BACKLIGHT_LV5207LP is not set
# CONFIG_BACKLIGHT_BD6107 is not set
# CONFIG_BACKLIGHT_ARCXCNN is not set
CONFIG_HDMI=y

#
# Console display driver support
#
CONFIG_VGA_CONSOLE=y
CONFIG_VGACON_SOFT_SCROLLBACK=y
CONFIG_VGACON_SOFT_SCROLLBACK_SIZE=64
# CONFIG_VGACON_SOFT_SCROLLBACK_PERSISTENT_ENABLE_BY_DEFAULT is not set
CONFIG_DUMMY_CONSOLE=y
CONFIG_DUMMY_CONSOLE_COLUMNS=80
CONFIG_DUMMY_CONSOLE_ROWS=25
CONFIG_FRAMEBUFFER_CONSOLE=y
CONFIG_FRAMEBUFFER_CONSOLE_DETECT_PRIMARY=y
CONFIG_FRAMEBUFFER_CONSOLE_ROTATION=y
CONFIG_LOGO=y
# CONFIG_LOGO_LINUX_MONO is not set
# CONFIG_LOGO_LINUX_VGA16 is not set
CONFIG_LOGO_LINUX_CLUT224=y
CONFIG_SOUND=m
CONFIG_SOUND_OSS_CORE=y
CONFIG_SOUND_OSS_CORE_PRECLAIM=y
CONFIG_SND=m
CONFIG_SND_TIMER=m
CONFIG_SND_PCM=m
CONFIG_SND_HWDEP=m
CONFIG_SND_SEQ_DEVICE=m
CONFIG_SND_RAWMIDI=m
CONFIG_SND_JACK=y
CONFIG_SND_JACK_INPUT_DEV=y
CONFIG_SND_OSSEMUL=y
# CONFIG_SND_MIXER_OSS is not set
# CONFIG_SND_PCM_OSS is not set
CONFIG_SND_PCM_TIMER=y
CONFIG_SND_HRTIMER=m
CONFIG_SND_DYNAMIC_MINORS=y
CONFIG_SND_MAX_CARDS=32
# CONFIG_SND_SUPPORT_OLD_API is not set
CONFIG_SND_PROC_FS=y
CONFIG_SND_VERBOSE_PROCFS=y
# CONFIG_SND_VERBOSE_PRINTK is not set
# CONFIG_SND_DEBUG is not set
CONFIG_SND_VMASTER=y
CONFIG_SND_DMA_SGBUF=y
CONFIG_SND_SEQUENCER=m
CONFIG_SND_SEQ_DUMMY=m
CONFIG_SND_SEQUENCER_OSS=m
CONFIG_SND_SEQ_HRTIMER_DEFAULT=y
CONFIG_SND_SEQ_MIDI_EVENT=m
CONFIG_SND_SEQ_MIDI=m
CONFIG_SND_SEQ_MIDI_EMUL=m
CONFIG_SND_SEQ_VIRMIDI=m
CONFIG_SND_MPU401_UART=m
CONFIG_SND_OPL3_LIB=m
CONFIG_SND_OPL3_LIB_SEQ=m
CONFIG_SND_VX_LIB=m
CONFIG_SND_AC97_CODEC=m
CONFIG_SND_DRIVERS=y
CONFIG_SND_PCSP=m
CONFIG_SND_DUMMY=m
CONFIG_SND_ALOOP=m
CONFIG_SND_VIRMIDI=m
CONFIG_SND_MTPAV=m
# CONFIG_SND_MTS64 is not set
# CONFIG_SND_SERIAL_U16550 is not set
CONFIG_SND_MPU401=m
# CONFIG_SND_PORTMAN2X4 is not set
CONFIG_SND_AC97_POWER_SAVE=y
CONFIG_SND_AC97_POWER_SAVE_DEFAULT=5
CONFIG_SND_PCI=y
CONFIG_SND_AD1889=m
# CONFIG_SND_ALS300 is not set
# CONFIG_SND_ALS4000 is not set
CONFIG_SND_ALI5451=m
CONFIG_SND_ASIHPI=m
CONFIG_SND_ATIIXP=m
CONFIG_SND_ATIIXP_MODEM=m
CONFIG_SND_AU8810=m
CONFIG_SND_AU8820=m
CONFIG_SND_AU8830=m
# CONFIG_SND_AW2 is not set
# CONFIG_SND_AZT3328 is not set
CONFIG_SND_BT87X=m
# CONFIG_SND_BT87X_OVERCLOCK is not set
CONFIG_SND_CA0106=m
CONFIG_SND_CMIPCI=m
CONFIG_SND_OXYGEN_LIB=m
CONFIG_SND_OXYGEN=m
# CONFIG_SND_CS4281 is not set
CONFIG_SND_CS46XX=m
CONFIG_SND_CS46XX_NEW_DSP=y
CONFIG_SND_CTXFI=m
CONFIG_SND_DARLA20=m
CONFIG_SND_GINA20=m
CONFIG_SND_LAYLA20=m
CONFIG_SND_DARLA24=m
CONFIG_SND_GINA24=m
CONFIG_SND_LAYLA24=m
CONFIG_SND_MONA=m
CONFIG_SND_MIA=m
CONFIG_SND_ECHO3G=m
CONFIG_SND_INDIGO=m
CONFIG_SND_INDIGOIO=m
CONFIG_SND_INDIGODJ=m
CONFIG_SND_INDIGOIOX=m
CONFIG_SND_INDIGODJX=m
CONFIG_SND_EMU10K1=m
CONFIG_SND_EMU10K1_SEQ=m
CONFIG_SND_EMU10K1X=m
CONFIG_SND_ENS1370=m
CONFIG_SND_ENS1371=m
# CONFIG_SND_ES1938 is not set
CONFIG_SND_ES1968=m
CONFIG_SND_ES1968_INPUT=y
CONFIG_SND_ES1968_RADIO=y
# CONFIG_SND_FM801 is not set
CONFIG_SND_HDSP=m
CONFIG_SND_HDSPM=m
CONFIG_SND_ICE1712=m
CONFIG_SND_ICE1724=m
CONFIG_SND_INTEL8X0=m
CONFIG_SND_INTEL8X0M=m
CONFIG_SND_KORG1212=m
CONFIG_SND_LOLA=m
CONFIG_SND_LX6464ES=m
CONFIG_SND_MAESTRO3=m
CONFIG_SND_MAESTRO3_INPUT=y
CONFIG_SND_MIXART=m
# CONFIG_SND_NM256 is not set
CONFIG_SND_PCXHR=m
# CONFIG_SND_RIPTIDE is not set
CONFIG_SND_RME32=m
CONFIG_SND_RME96=m
CONFIG_SND_RME9652=m
# CONFIG_SND_SONICVIBES is not set
CONFIG_SND_TRIDENT=m
CONFIG_SND_VIA82XX=m
CONFIG_SND_VIA82XX_MODEM=m
CONFIG_SND_VIRTUOSO=m
CONFIG_SND_VX222=m
# CONFIG_SND_YMFPCI is not set

#
# HD-Audio
#
CONFIG_SND_HDA=m
CONFIG_SND_HDA_INTEL=m
CONFIG_SND_HDA_HWDEP=y
# CONFIG_SND_HDA_RECONFIG is not set
CONFIG_SND_HDA_INPUT_BEEP=y
CONFIG_SND_HDA_INPUT_BEEP_MODE=0
# CONFIG_SND_HDA_PATCH_LOADER is not set
CONFIG_SND_HDA_CODEC_REALTEK=m
CONFIG_SND_HDA_CODEC_ANALOG=m
CONFIG_SND_HDA_CODEC_SIGMATEL=m
CONFIG_SND_HDA_CODEC_VIA=m
CONFIG_SND_HDA_CODEC_HDMI=m
CONFIG_SND_HDA_CODEC_CIRRUS=m
CONFIG_SND_HDA_CODEC_CONEXANT=m
CONFIG_SND_HDA_CODEC_CA0110=m
CONFIG_SND_HDA_CODEC_CA0132=m
CONFIG_SND_HDA_CODEC_CA0132_DSP=y
CONFIG_SND_HDA_CODEC_CMEDIA=m
CONFIG_SND_HDA_CODEC_SI3054=m
CONFIG_SND_HDA_GENERIC=m
CONFIG_SND_HDA_POWER_SAVE_DEFAULT=0
CONFIG_SND_HDA_CORE=m
CONFIG_SND_HDA_DSP_LOADER=y
CONFIG_SND_HDA_I915=y
CONFIG_SND_HDA_PREALLOC_SIZE=512
CONFIG_SND_SPI=y
CONFIG_SND_USB=y
CONFIG_SND_USB_AUDIO=m
CONFIG_SND_USB_UA101=m
CONFIG_SND_USB_USX2Y=m
CONFIG_SND_USB_CAIAQ=m
CONFIG_SND_USB_CAIAQ_INPUT=y
CONFIG_SND_USB_US122L=m
CONFIG_SND_USB_6FIRE=m
# CONFIG_SND_USB_HIFACE is not set
# CONFIG_SND_BCD2000 is not set
# CONFIG_SND_USB_POD is not set
# CONFIG_SND_USB_PODHD is not set
# CONFIG_SND_USB_TONEPORT is not set
# CONFIG_SND_USB_VARIAX is not set
CONFIG_SND_FIREWIRE=y
CONFIG_SND_FIREWIRE_LIB=m
# CONFIG_SND_DICE is not set
# CONFIG_SND_OXFW is not set
CONFIG_SND_ISIGHT=m
# CONFIG_SND_FIREWORKS is not set
# CONFIG_SND_BEBOB is not set
# CONFIG_SND_FIREWIRE_DIGI00X is not set
# CONFIG_SND_FIREWIRE_TASCAM is not set
# CONFIG_SND_FIREWIRE_MOTU is not set
# CONFIG_SND_FIREFACE is not set
# CONFIG_SND_SOC is not set
CONFIG_SND_X86=y
# CONFIG_HDMI_LPE_AUDIO is not set
CONFIG_SND_SYNTH_EMUX=m
CONFIG_AC97_BUS=m

#
# HID support
#
CONFIG_HID=y
CONFIG_HID_BATTERY_STRENGTH=y
CONFIG_HIDRAW=y
CONFIG_UHID=m
CONFIG_HID_GENERIC=y

#
# Special HID drivers
#
CONFIG_HID_A4TECH=y
# CONFIG_HID_ACCUTOUCH is not set
CONFIG_HID_ACRUX=m
# CONFIG_HID_ACRUX_FF is not set
CONFIG_HID_APPLE=y
CONFIG_HID_APPLEIR=m
# CONFIG_HID_ASUS is not set
CONFIG_HID_AUREAL=m
CONFIG_HID_BELKIN=y
# CONFIG_HID_BETOP_FF is not set
CONFIG_HID_CHERRY=y
CONFIG_HID_CHICONY=y
# CONFIG_HID_CORSAIR is not set
CONFIG_HID_PRODIKEYS=m
# CONFIG_HID_CMEDIA is not set
# CONFIG_HID_CP2112 is not set
CONFIG_HID_CYPRESS=y
CONFIG_HID_DRAGONRISE=m
# CONFIG_DRAGONRISE_FF is not set
# CONFIG_HID_EMS_FF is not set
# CONFIG_HID_ELAN is not set
CONFIG_HID_ELECOM=m
# CONFIG_HID_ELO is not set
CONFIG_HID_EZKEY=y
# CONFIG_HID_GEMBIRD is not set
# CONFIG_HID_GFRM is not set
CONFIG_HID_HOLTEK=m
# CONFIG_HOLTEK_FF is not set
# CONFIG_HID_GOOGLE_HAMMER is not set
# CONFIG_HID_GT683R is not set
CONFIG_HID_KEYTOUCH=m
CONFIG_HID_KYE=m
CONFIG_HID_UCLOGIC=m
CONFIG_HID_WALTOP=m
CONFIG_HID_GYRATION=m
CONFIG_HID_ICADE=m
# CONFIG_HID_ITE is not set
# CONFIG_HID_JABRA is not set
CONFIG_HID_TWINHAN=m
CONFIG_HID_KENSINGTON=y
CONFIG_HID_LCPOWER=m
CONFIG_HID_LED=m
# CONFIG_HID_LENOVO is not set
CONFIG_HID_LOGITECH=y
CONFIG_HID_LOGITECH_DJ=m
CONFIG_HID_LOGITECH_HIDPP=m
# CONFIG_LOGITECH_FF is not set
# CONFIG_LOGIRUMBLEPAD2_FF is not set
# CONFIG_LOGIG940_FF is not set
# CONFIG_LOGIWHEELS_FF is not set
CONFIG_HID_MAGICMOUSE=y
# CONFIG_HID_MAYFLASH is not set
CONFIG_HID_MICROSOFT=y
CONFIG_HID_MONTEREY=y
CONFIG_HID_MULTITOUCH=m
# CONFIG_HID_NTI is not set
CONFIG_HID_NTRIG=y
CONFIG_HID_ORTEK=m
CONFIG_HID_PANTHERLORD=m
# CONFIG_PANTHERLORD_FF is not set
# CONFIG_HID_PENMOUNT is not set
CONFIG_HID_PETALYNX=m
CONFIG_HID_PICOLCD=m
CONFIG_HID_PICOLCD_FB=y
CONFIG_HID_PICOLCD_BACKLIGHT=y
CONFIG_HID_PICOLCD_LCD=y
CONFIG_HID_PICOLCD_LEDS=y
CONFIG_HID_PICOLCD_CIR=y
CONFIG_HID_PLANTRONICS=y
CONFIG_HID_PRIMAX=m
# CONFIG_HID_RETRODE is not set
CONFIG_HID_ROCCAT=m
CONFIG_HID_SAITEK=m
CONFIG_HID_SAMSUNG=m
CONFIG_HID_SONY=m
# CONFIG_SONY_FF is not set
CONFIG_HID_SPEEDLINK=m
CONFIG_HID_STEELSERIES=m
CONFIG_HID_SUNPLUS=m
# CONFIG_HID_RMI is not set
CONFIG_HID_GREENASIA=m
# CONFIG_GREENASIA_FF is not set
CONFIG_HID_HYPERV_MOUSE=m
CONFIG_HID_SMARTJOYPLUS=m
# CONFIG_SMARTJOYPLUS_FF is not set
CONFIG_HID_TIVO=m
CONFIG_HID_TOPSEED=m
CONFIG_HID_THINGM=m
CONFIG_HID_THRUSTMASTER=m
# CONFIG_THRUSTMASTER_FF is not set
# CONFIG_HID_UDRAW_PS3 is not set
CONFIG_HID_WACOM=m
CONFIG_HID_WIIMOTE=m
# CONFIG_HID_XINMO is not set
CONFIG_HID_ZEROPLUS=m
# CONFIG_ZEROPLUS_FF is not set
CONFIG_HID_ZYDACRON=m
# CONFIG_HID_SENSOR_HUB is not set
# CONFIG_HID_ALPS is not set

#
# USB HID support
#
CONFIG_USB_HID=y
CONFIG_HID_PID=y
CONFIG_USB_HIDDEV=y

#
# I2C HID support
#
CONFIG_I2C_HID=m

#
# Intel ISH HID support
#
# CONFIG_INTEL_ISH_HID is not set
CONFIG_USB_OHCI_LITTLE_ENDIAN=y
CONFIG_USB_SUPPORT=y
CONFIG_USB_COMMON=y
CONFIG_USB_ARCH_HAS_HCD=y
CONFIG_USB=y
CONFIG_USB_PCI=y
CONFIG_USB_ANNOUNCE_NEW_DEVICES=y

#
# Miscellaneous USB options
#
CONFIG_USB_DEFAULT_PERSIST=y
# CONFIG_USB_DYNAMIC_MINORS is not set
# CONFIG_USB_OTG is not set
# CONFIG_USB_OTG_WHITELIST is not set
# CONFIG_USB_OTG_BLACKLIST_HUB is not set
# CONFIG_USB_LEDS_TRIGGER_USBPORT is not set
CONFIG_USB_MON=y
CONFIG_USB_WUSB=m
CONFIG_USB_WUSB_CBAF=m
# CONFIG_USB_WUSB_CBAF_DEBUG is not set

#
# USB Host Controller Drivers
#
# CONFIG_USB_C67X00_HCD is not set
CONFIG_USB_XHCI_HCD=y
# CONFIG_USB_XHCI_DBGCAP is not set
CONFIG_USB_XHCI_PCI=y
CONFIG_USB_XHCI_PLATFORM=y
CONFIG_USB_EHCI_HCD=y
CONFIG_USB_EHCI_ROOT_HUB_TT=y
CONFIG_USB_EHCI_TT_NEWSCHED=y
CONFIG_USB_EHCI_PCI=y
# CONFIG_USB_EHCI_HCD_PLATFORM is not set
# CONFIG_USB_OXU210HP_HCD is not set
# CONFIG_USB_ISP116X_HCD is not set
# CONFIG_USB_FOTG210_HCD is not set
# CONFIG_USB_MAX3421_HCD is not set
CONFIG_USB_OHCI_HCD=y
CONFIG_USB_OHCI_HCD_PCI=y
# CONFIG_USB_OHCI_HCD_PLATFORM is not set
CONFIG_USB_UHCI_HCD=y
# CONFIG_USB_U132_HCD is not set
# CONFIG_USB_SL811_HCD is not set
# CONFIG_USB_R8A66597_HCD is not set
# CONFIG_USB_WHCI_HCD is not set
CONFIG_USB_HWA_HCD=m
# CONFIG_USB_HCD_BCMA is not set
# CONFIG_USB_HCD_SSB is not set
# CONFIG_USB_HCD_TEST_MODE is not set

#
# USB Device Class drivers
#
CONFIG_USB_ACM=m
CONFIG_USB_PRINTER=m
CONFIG_USB_WDM=m
CONFIG_USB_TMC=m

#
# NOTE: USB_STORAGE depends on SCSI but BLK_DEV_SD may
#

#
# also be needed; see USB_STORAGE Help for more info
#
CONFIG_USB_STORAGE=m
# CONFIG_USB_STORAGE_DEBUG is not set
CONFIG_USB_STORAGE_REALTEK=m
CONFIG_REALTEK_AUTOPM=y
CONFIG_USB_STORAGE_DATAFAB=m
CONFIG_USB_STORAGE_FREECOM=m
CONFIG_USB_STORAGE_ISD200=m
CONFIG_USB_STORAGE_USBAT=m
CONFIG_USB_STORAGE_SDDR09=m
CONFIG_USB_STORAGE_SDDR55=m
CONFIG_USB_STORAGE_JUMPSHOT=m
CONFIG_USB_STORAGE_ALAUDA=m
CONFIG_USB_STORAGE_ONETOUCH=m
CONFIG_USB_STORAGE_KARMA=m
CONFIG_USB_STORAGE_CYPRESS_ATACB=m
CONFIG_USB_STORAGE_ENE_UB6250=m
CONFIG_USB_UAS=m

#
# USB Imaging devices
#
CONFIG_USB_MDC800=m
CONFIG_USB_MICROTEK=m
# CONFIG_USBIP_CORE is not set
# CONFIG_USB_MUSB_HDRC is not set
CONFIG_USB_DWC3=y
# CONFIG_USB_DWC3_HOST is not set
CONFIG_USB_DWC3_GADGET=y
# CONFIG_USB_DWC3_DUAL_ROLE is not set

#
# Platform Glue Driver Support
#
CONFIG_USB_DWC3_PCI=y
# CONFIG_USB_DWC2 is not set
# CONFIG_USB_CHIPIDEA is not set
# CONFIG_USB_ISP1760 is not set

#
# USB port drivers
#
CONFIG_USB_USS720=m
CONFIG_USB_SERIAL=y
CONFIG_USB_SERIAL_CONSOLE=y
CONFIG_USB_SERIAL_GENERIC=y
# CONFIG_USB_SERIAL_SIMPLE is not set
CONFIG_USB_SERIAL_AIRCABLE=m
CONFIG_USB_SERIAL_ARK3116=m
CONFIG_USB_SERIAL_BELKIN=m
CONFIG_USB_SERIAL_CH341=m
CONFIG_USB_SERIAL_WHITEHEAT=m
CONFIG_USB_SERIAL_DIGI_ACCELEPORT=m
CONFIG_USB_SERIAL_CP210X=m
CONFIG_USB_SERIAL_CYPRESS_M8=m
CONFIG_USB_SERIAL_EMPEG=m
CONFIG_USB_SERIAL_FTDI_SIO=m
CONFIG_USB_SERIAL_VISOR=m
CONFIG_USB_SERIAL_IPAQ=m
CONFIG_USB_SERIAL_IR=m
CONFIG_USB_SERIAL_EDGEPORT=m
CONFIG_USB_SERIAL_EDGEPORT_TI=m
# CONFIG_USB_SERIAL_F81232 is not set
# CONFIG_USB_SERIAL_F8153X is not set
CONFIG_USB_SERIAL_GARMIN=m
CONFIG_USB_SERIAL_IPW=m
CONFIG_USB_SERIAL_IUU=m
CONFIG_USB_SERIAL_KEYSPAN_PDA=m
CONFIG_USB_SERIAL_KEYSPAN=m
CONFIG_USB_SERIAL_KLSI=m
CONFIG_USB_SERIAL_KOBIL_SCT=m
CONFIG_USB_SERIAL_MCT_U232=m
# CONFIG_USB_SERIAL_METRO is not set
CONFIG_USB_SERIAL_MOS7720=m
CONFIG_USB_SERIAL_MOS7715_PARPORT=y
CONFIG_USB_SERIAL_MOS7840=m
# CONFIG_USB_SERIAL_MXUPORT is not set
CONFIG_USB_SERIAL_NAVMAN=m
CONFIG_USB_SERIAL_PL2303=m
CONFIG_USB_SERIAL_OTI6858=m
CONFIG_USB_SERIAL_QCAUX=m
CONFIG_USB_SERIAL_QUALCOMM=m
CONFIG_USB_SERIAL_SPCP8X5=m
CONFIG_USB_SERIAL_SAFE=m
CONFIG_USB_SERIAL_SAFE_PADDED=y
CONFIG_USB_SERIAL_SIERRAWIRELESS=m
CONFIG_USB_SERIAL_SYMBOL=m
# CONFIG_USB_SERIAL_TI is not set
CONFIG_USB_SERIAL_CYBERJACK=m
CONFIG_USB_SERIAL_XIRCOM=m
CONFIG_USB_SERIAL_WWAN=m
CONFIG_USB_SERIAL_OPTION=m
CONFIG_USB_SERIAL_OMNINET=m
CONFIG_USB_SERIAL_OPTICON=m
CONFIG_USB_SERIAL_XSENS_MT=m
# CONFIG_USB_SERIAL_WISHBONE is not set
CONFIG_USB_SERIAL_SSU100=m
CONFIG_USB_SERIAL_QT2=m
# CONFIG_USB_SERIAL_UPD78F0730 is not set
CONFIG_USB_SERIAL_DEBUG=m

#
# USB Miscellaneous drivers
#
CONFIG_USB_EMI62=m
CONFIG_USB_EMI26=m
CONFIG_USB_ADUTUX=m
CONFIG_USB_SEVSEG=m
# CONFIG_USB_RIO500 is not set
CONFIG_USB_LEGOTOWER=m
CONFIG_USB_LCD=m
# CONFIG_USB_CYPRESS_CY7C63 is not set
# CONFIG_USB_CYTHERM is not set
CONFIG_USB_IDMOUSE=m
CONFIG_USB_FTDI_ELAN=m
CONFIG_USB_APPLEDISPLAY=m
CONFIG_USB_SISUSBVGA=m
CONFIG_USB_SISUSBVGA_CON=y
CONFIG_USB_LD=m
# CONFIG_USB_TRANCEVIBRATOR is not set
CONFIG_USB_IOWARRIOR=m
# CONFIG_USB_TEST is not set
# CONFIG_USB_EHSET_TEST_FIXTURE is not set
CONFIG_USB_ISIGHTFW=m
# CONFIG_USB_YUREX is not set
CONFIG_USB_EZUSB_FX2=m
# CONFIG_USB_HUB_USB251XB is not set
CONFIG_USB_HSIC_USB3503=m
# CONFIG_USB_HSIC_USB4604 is not set
# CONFIG_USB_LINK_LAYER_TEST is not set
# CONFIG_USB_CHAOSKEY is not set
CONFIG_USB_ATM=m
CONFIG_USB_SPEEDTOUCH=m
CONFIG_USB_CXACRU=m
CONFIG_USB_UEAGLEATM=m
CONFIG_USB_XUSBATM=m

#
# USB Physical Layer drivers
#
CONFIG_USB_PHY=y
CONFIG_NOP_USB_XCEIV=y
# CONFIG_USB_GPIO_VBUS is not set
# CONFIG_USB_ISP1301 is not set
CONFIG_USB_GADGET=y
# CONFIG_USB_GADGET_DEBUG is not set
# CONFIG_USB_GADGET_DEBUG_FILES is not set
# CONFIG_USB_GADGET_DEBUG_FS is not set
CONFIG_USB_GADGET_VBUS_DRAW=2
CONFIG_USB_GADGET_STORAGE_NUM_BUFFERS=2

#
# USB Peripheral Controller
#
# CONFIG_USB_FOTG210_UDC is not set
# CONFIG_USB_GR_UDC is not set
# CONFIG_USB_R8A66597 is not set
# CONFIG_USB_PXA27X is not set
# CONFIG_USB_MV_UDC is not set
# CONFIG_USB_MV_U3D is not set
# CONFIG_USB_M66592 is not set
# CONFIG_USB_BDC_UDC is not set
# CONFIG_USB_AMD5536UDC is not set
# CONFIG_USB_NET2272 is not set
# CONFIG_USB_NET2280 is not set
# CONFIG_USB_GOKU is not set
# CONFIG_USB_EG20T is not set
# CONFIG_USB_DUMMY_HCD is not set
CONFIG_USB_LIBCOMPOSITE=m
CONFIG_USB_F_MASS_STORAGE=m
# CONFIG_USB_CONFIGFS is not set
# CONFIG_USB_ZERO is not set
# CONFIG_USB_AUDIO is not set
# CONFIG_USB_ETH is not set
# CONFIG_USB_G_NCM is not set
# CONFIG_USB_GADGETFS is not set
# CONFIG_USB_FUNCTIONFS is not set
CONFIG_USB_MASS_STORAGE=m
# CONFIG_USB_GADGET_TARGET is not set
# CONFIG_USB_G_SERIAL is not set
# CONFIG_USB_MIDI_GADGET is not set
# CONFIG_USB_G_PRINTER is not set
# CONFIG_USB_CDC_COMPOSITE is not set
# CONFIG_USB_G_ACM_MS is not set
# CONFIG_USB_G_MULTI is not set
# CONFIG_USB_G_HID is not set
# CONFIG_USB_G_DBGP is not set
# CONFIG_USB_G_WEBCAM is not set
# CONFIG_TYPEC is not set
# CONFIG_USB_LED_TRIG is not set
# CONFIG_USB_ULPI_BUS is not set
CONFIG_UWB=m
CONFIG_UWB_HWA=m
CONFIG_UWB_WHCI=m
CONFIG_UWB_I1480U=m
CONFIG_MMC=m
CONFIG_MMC_BLOCK=m
CONFIG_MMC_BLOCK_MINORS=8
CONFIG_SDIO_UART=m
# CONFIG_MMC_TEST is not set

#
# MMC/SD/SDIO Host Controller Drivers
#
# CONFIG_MMC_DEBUG is not set
CONFIG_MMC_SDHCI=m
CONFIG_MMC_SDHCI_PCI=m
CONFIG_MMC_RICOH_MMC=y
CONFIG_MMC_SDHCI_ACPI=m
CONFIG_MMC_SDHCI_PLTFM=m
# CONFIG_MMC_SDHCI_F_SDH30 is not set
# CONFIG_MMC_WBSD is not set
CONFIG_MMC_TIFM_SD=m
# CONFIG_MMC_SPI is not set
CONFIG_MMC_CB710=m
CONFIG_MMC_VIA_SDMMC=m
CONFIG_MMC_VUB300=m
CONFIG_MMC_USHC=m
# CONFIG_MMC_USDHI6ROL0 is not set
CONFIG_MMC_CQHCI=m
# CONFIG_MMC_TOSHIBA_PCI is not set
# CONFIG_MMC_MTK is not set
# CONFIG_MMC_SDHCI_XENON is not set
CONFIG_MEMSTICK=m
# CONFIG_MEMSTICK_DEBUG is not set

#
# MemoryStick drivers
#
# CONFIG_MEMSTICK_UNSAFE_RESUME is not set
CONFIG_MSPRO_BLOCK=m
# CONFIG_MS_BLOCK is not set

#
# MemoryStick Host Controller Drivers
#
CONFIG_MEMSTICK_TIFM_MS=m
CONFIG_MEMSTICK_JMICRON_38X=m
CONFIG_MEMSTICK_R592=m
CONFIG_NEW_LEDS=y
CONFIG_LEDS_CLASS=y
# CONFIG_LEDS_CLASS_FLASH is not set
# CONFIG_LEDS_BRIGHTNESS_HW_CHANGED is not set

#
# LED drivers
#
# CONFIG_LEDS_APU is not set
CONFIG_LEDS_LM3530=m
# CONFIG_LEDS_LM3642 is not set
# CONFIG_LEDS_PCA9532 is not set
# CONFIG_LEDS_GPIO is not set
CONFIG_LEDS_LP3944=m
# CONFIG_LEDS_LP3952 is not set
CONFIG_LEDS_LP55XX_COMMON=m
CONFIG_LEDS_LP5521=m
CONFIG_LEDS_LP5523=m
CONFIG_LEDS_LP5562=m
# CONFIG_LEDS_LP8501 is not set
CONFIG_LEDS_CLEVO_MAIL=m
# CONFIG_LEDS_PCA955X is not set
# CONFIG_LEDS_PCA963X is not set
# CONFIG_LEDS_DAC124S085 is not set
# CONFIG_LEDS_PWM is not set
# CONFIG_LEDS_BD2802 is not set
CONFIG_LEDS_INTEL_SS4200=m
# CONFIG_LEDS_LT3593 is not set
# CONFIG_LEDS_TCA6507 is not set
# CONFIG_LEDS_TLC591XX is not set
# CONFIG_LEDS_LM355x is not set

#
# LED driver for blink(1) USB RGB LED is under Special HID drivers (HID_THINGM)
#
CONFIG_LEDS_BLINKM=m
# CONFIG_LEDS_MLXCPLD is not set
# CONFIG_LEDS_MLXREG is not set
# CONFIG_LEDS_USER is not set
# CONFIG_LEDS_NIC78BX is not set

#
# LED Triggers
#
CONFIG_LEDS_TRIGGERS=y
CONFIG_LEDS_TRIGGER_TIMER=m
CONFIG_LEDS_TRIGGER_ONESHOT=m
# CONFIG_LEDS_TRIGGER_DISK is not set
# CONFIG_LEDS_TRIGGER_MTD is not set
CONFIG_LEDS_TRIGGER_HEARTBEAT=m
CONFIG_LEDS_TRIGGER_BACKLIGHT=m
# CONFIG_LEDS_TRIGGER_CPU is not set
# CONFIG_LEDS_TRIGGER_ACTIVITY is not set
# CONFIG_LEDS_TRIGGER_GPIO is not set
CONFIG_LEDS_TRIGGER_DEFAULT_ON=m

#
# iptables trigger is under Netfilter config (LED target)
#
CONFIG_LEDS_TRIGGER_TRANSIENT=m
CONFIG_LEDS_TRIGGER_CAMERA=m
# CONFIG_LEDS_TRIGGER_PANIC is not set
# CONFIG_LEDS_TRIGGER_NETDEV is not set
# CONFIG_ACCESSIBILITY is not set
# CONFIG_INFINIBAND is not set
CONFIG_EDAC_ATOMIC_SCRUB=y
CONFIG_EDAC_SUPPORT=y
CONFIG_EDAC=y
CONFIG_EDAC_LEGACY_SYSFS=y
# CONFIG_EDAC_DEBUG is not set
CONFIG_EDAC_DECODE_MCE=m
# CONFIG_EDAC_GHES is not set
CONFIG_EDAC_AMD64=m
# CONFIG_EDAC_AMD64_ERROR_INJECTION is not set
CONFIG_EDAC_E752X=m
CONFIG_EDAC_I82975X=m
CONFIG_EDAC_I3000=m
CONFIG_EDAC_I3200=m
# CONFIG_EDAC_IE31200 is not set
CONFIG_EDAC_X38=m
CONFIG_EDAC_I5400=m
CONFIG_EDAC_I7CORE=m
CONFIG_EDAC_I5000=m
CONFIG_EDAC_I5100=m
CONFIG_EDAC_I7300=m
CONFIG_EDAC_SBRIDGE=m
# CONFIG_EDAC_SKX is not set
# CONFIG_EDAC_PND2 is not set
CONFIG_RTC_LIB=y
CONFIG_RTC_MC146818_LIB=y
CONFIG_RTC_CLASS=y
CONFIG_RTC_HCTOSYS=y
CONFIG_RTC_HCTOSYS_DEVICE="rtc0"
# CONFIG_RTC_SYSTOHC is not set
# CONFIG_RTC_DEBUG is not set
CONFIG_RTC_NVMEM=y

#
# RTC interfaces
#
CONFIG_RTC_INTF_SYSFS=y
CONFIG_RTC_INTF_PROC=y
CONFIG_RTC_INTF_DEV=y
# CONFIG_RTC_INTF_DEV_UIE_EMUL is not set
# CONFIG_RTC_DRV_TEST is not set

#
# I2C RTC drivers
#
# CONFIG_RTC_DRV_ABB5ZES3 is not set
# CONFIG_RTC_DRV_ABX80X is not set
CONFIG_RTC_DRV_DS1307=m
CONFIG_RTC_DRV_DS1307_HWMON=y
# CONFIG_RTC_DRV_DS1307_CENTURY is not set
CONFIG_RTC_DRV_DS1374=m
# CONFIG_RTC_DRV_DS1374_WDT is not set
CONFIG_RTC_DRV_DS1672=m
CONFIG_RTC_DRV_MAX6900=m
CONFIG_RTC_DRV_RS5C372=m
CONFIG_RTC_DRV_ISL1208=m
CONFIG_RTC_DRV_ISL12022=m
CONFIG_RTC_DRV_X1205=m
CONFIG_RTC_DRV_PCF8523=m
# CONFIG_RTC_DRV_PCF85063 is not set
# CONFIG_RTC_DRV_PCF85363 is not set
CONFIG_RTC_DRV_PCF8563=m
CONFIG_RTC_DRV_PCF8583=m
CONFIG_RTC_DRV_M41T80=m
CONFIG_RTC_DRV_M41T80_WDT=y
CONFIG_RTC_DRV_BQ32K=m
# CONFIG_RTC_DRV_S35390A is not set
CONFIG_RTC_DRV_FM3130=m
# CONFIG_RTC_DRV_RX8010 is not set
CONFIG_RTC_DRV_RX8581=m
CONFIG_RTC_DRV_RX8025=m
CONFIG_RTC_DRV_EM3027=m
# CONFIG_RTC_DRV_RV8803 is not set

#
# SPI RTC drivers
#
# CONFIG_RTC_DRV_M41T93 is not set
# CONFIG_RTC_DRV_M41T94 is not set
# CONFIG_RTC_DRV_DS1302 is not set
# CONFIG_RTC_DRV_DS1305 is not set
# CONFIG_RTC_DRV_DS1343 is not set
# CONFIG_RTC_DRV_DS1347 is not set
# CONFIG_RTC_DRV_DS1390 is not set
# CONFIG_RTC_DRV_MAX6916 is not set
# CONFIG_RTC_DRV_R9701 is not set
# CONFIG_RTC_DRV_RX4581 is not set
# CONFIG_RTC_DRV_RX6110 is not set
# CONFIG_RTC_DRV_RS5C348 is not set
# CONFIG_RTC_DRV_MAX6902 is not set
# CONFIG_RTC_DRV_PCF2123 is not set
# CONFIG_RTC_DRV_MCP795 is not set
CONFIG_RTC_I2C_AND_SPI=y

#
# SPI and I2C RTC drivers
#
CONFIG_RTC_DRV_DS3232=m
CONFIG_RTC_DRV_DS3232_HWMON=y
# CONFIG_RTC_DRV_PCF2127 is not set
CONFIG_RTC_DRV_RV3029C2=m
CONFIG_RTC_DRV_RV3029_HWMON=y

#
# Platform RTC drivers
#
CONFIG_RTC_DRV_CMOS=y
CONFIG_RTC_DRV_DS1286=m
CONFIG_RTC_DRV_DS1511=m
CONFIG_RTC_DRV_DS1553=m
# CONFIG_RTC_DRV_DS1685_FAMILY is not set
CONFIG_RTC_DRV_DS1742=m
CONFIG_RTC_DRV_DS2404=m
CONFIG_RTC_DRV_STK17TA8=m
# CONFIG_RTC_DRV_M48T86 is not set
CONFIG_RTC_DRV_M48T35=m
CONFIG_RTC_DRV_M48T59=m
CONFIG_RTC_DRV_MSM6242=m
CONFIG_RTC_DRV_BQ4802=m
CONFIG_RTC_DRV_RP5C01=m
CONFIG_RTC_DRV_V3020=m

#
# on-CPU RTC drivers
#
# CONFIG_RTC_DRV_FTRTC010 is not set

#
# HID Sensor RTC drivers
#
# CONFIG_RTC_DRV_HID_SENSOR_TIME is not set
CONFIG_DMADEVICES=y
# CONFIG_DMADEVICES_DEBUG is not set

#
# DMA Devices
#
CONFIG_DMA_ENGINE=y
CONFIG_DMA_VIRTUAL_CHANNELS=y
CONFIG_DMA_ACPI=y
# CONFIG_ALTERA_MSGDMA is not set
# CONFIG_INTEL_IDMA64 is not set
# CONFIG_INTEL_IOATDMA is not set
# CONFIG_QCOM_HIDMA_MGMT is not set
# CONFIG_QCOM_HIDMA is not set
CONFIG_DW_DMAC_CORE=y
CONFIG_DW_DMAC=m
CONFIG_DW_DMAC_PCI=y
CONFIG_HSU_DMA=y

#
# DMA Clients
#
CONFIG_ASYNC_TX_DMA=y
CONFIG_DMATEST=m
CONFIG_DMA_ENGINE_RAID=y

#
# DMABUF options
#
CONFIG_SYNC_FILE=y
CONFIG_SW_SYNC=y
CONFIG_AUXDISPLAY=y
# CONFIG_HD44780 is not set
CONFIG_KS0108=m
CONFIG_KS0108_PORT=0x378
CONFIG_KS0108_DELAY=2
CONFIG_CFAG12864B=m
CONFIG_CFAG12864B_RATE=20
# CONFIG_IMG_ASCII_LCD is not set
# CONFIG_PANEL is not set
CONFIG_UIO=m
CONFIG_UIO_CIF=m
CONFIG_UIO_PDRV_GENIRQ=m
# CONFIG_UIO_DMEM_GENIRQ is not set
CONFIG_UIO_AEC=m
CONFIG_UIO_SERCOS3=m
CONFIG_UIO_PCI_GENERIC=m
# CONFIG_UIO_NETX is not set
# CONFIG_UIO_PRUSS is not set
# CONFIG_UIO_MF624 is not set
# CONFIG_UIO_HV_GENERIC is not set
CONFIG_VFIO_IOMMU_TYPE1=m
CONFIG_VFIO_VIRQFD=m
CONFIG_VFIO=m
# CONFIG_VFIO_NOIOMMU is not set
CONFIG_VFIO_PCI=m
# CONFIG_VFIO_PCI_VGA is not set
CONFIG_VFIO_PCI_MMAP=y
CONFIG_VFIO_PCI_INTX=y
CONFIG_VFIO_PCI_IGD=y
# CONFIG_VFIO_MDEV is not set
CONFIG_IRQ_BYPASS_MANAGER=m
# CONFIG_VIRT_DRIVERS is not set
CONFIG_VIRTIO=y
CONFIG_VIRTIO_MENU=y
CONFIG_VIRTIO_PCI=y
CONFIG_VIRTIO_PCI_LEGACY=y
CONFIG_VIRTIO_BALLOON=y
# CONFIG_VIRTIO_INPUT is not set
# CONFIG_VIRTIO_MMIO is not set

#
# Microsoft Hyper-V guest support
#
CONFIG_HYPERV=m
CONFIG_HYPERV_TSCPAGE=y
CONFIG_HYPERV_UTILS=m
CONFIG_HYPERV_BALLOON=m

#
# Xen driver support
#
CONFIG_XEN_BALLOON=y
# CONFIG_XEN_SELFBALLOONING is not set
# CONFIG_XEN_BALLOON_MEMORY_HOTPLUG is not set
CONFIG_XEN_SCRUB_PAGES=y
CONFIG_XEN_DEV_EVTCHN=m
CONFIG_XEN_BACKEND=y
CONFIG_XENFS=m
CONFIG_XEN_COMPAT_XENFS=y
CONFIG_XEN_SYS_HYPERVISOR=y
CONFIG_XEN_XENBUS_FRONTEND=y
# CONFIG_XEN_GNTDEV is not set
# CONFIG_XEN_GRANT_DEV_ALLOC is not set
CONFIG_SWIOTLB_XEN=y
CONFIG_XEN_TMEM=m
CONFIG_XEN_PCIDEV_BACKEND=m
# CONFIG_XEN_PVCALLS_FRONTEND is not set
# CONFIG_XEN_PVCALLS_BACKEND is not set
# CONFIG_XEN_SCSI_BACKEND is not set
CONFIG_XEN_PRIVCMD=m
CONFIG_XEN_ACPI_PROCESSOR=m
# CONFIG_XEN_MCE_LOG is not set
CONFIG_XEN_HAVE_PVMMU=y
CONFIG_XEN_EFI=y
CONFIG_XEN_AUTO_XLATE=y
CONFIG_XEN_ACPI=y
CONFIG_XEN_SYMS=y
CONFIG_XEN_HAVE_VPMU=y
CONFIG_STAGING=y
# CONFIG_IPX is not set
# CONFIG_NCP_FS is not set
# CONFIG_PRISM2_USB is not set
# CONFIG_COMEDI is not set
# CONFIG_RTL8192U is not set
CONFIG_RTLLIB=m
CONFIG_RTLLIB_CRYPTO_CCMP=m
CONFIG_RTLLIB_CRYPTO_TKIP=m
CONFIG_RTLLIB_CRYPTO_WEP=m
CONFIG_RTL8192E=m
# CONFIG_RTL8723BS is not set
CONFIG_R8712U=m
# CONFIG_R8188EU is not set
# CONFIG_R8822BE is not set
# CONFIG_RTS5208 is not set
# CONFIG_VT6655 is not set
# CONFIG_VT6656 is not set
# CONFIG_FB_SM750 is not set
# CONFIG_FB_XGI is not set

#
# Speakup console speech
#
# CONFIG_SPEAKUP is not set
# CONFIG_STAGING_MEDIA is not set

#
# Android
#
# CONFIG_LTE_GDM724X is not set
CONFIG_FIREWIRE_SERIAL=m
CONFIG_FWTTY_MAX_TOTAL_PORTS=64
CONFIG_FWTTY_MAX_CARD_PORTS=32
# CONFIG_LNET is not set
# CONFIG_DGNC is not set
# CONFIG_GS_FPGABOOT is not set
# CONFIG_CRYPTO_SKEIN is not set
# CONFIG_UNISYSSPAR is not set
# CONFIG_FB_TFT is not set
# CONFIG_WILC1000_SDIO is not set
# CONFIG_WILC1000_SPI is not set
# CONFIG_MOST is not set
# CONFIG_KS7010 is not set
# CONFIG_GREYBUS is not set

#
# USB Power Delivery and Type-C drivers
#
# CONFIG_DRM_VBOXVIDEO is not set
# CONFIG_PI433 is not set
# CONFIG_MTK_MMC is not set
CONFIG_X86_PLATFORM_DEVICES=y
CONFIG_ACER_WMI=m
# CONFIG_ACER_WIRELESS is not set
CONFIG_ACERHDF=m
# CONFIG_ALIENWARE_WMI is not set
CONFIG_ASUS_LAPTOP=m
# CONFIG_DELL_SMBIOS is not set
# CONFIG_DELL_LAPTOP is not set
# CONFIG_DELL_WMI is not set
CONFIG_DELL_WMI_AIO=m
# CONFIG_DELL_WMI_LED is not set
# CONFIG_DELL_SMO8800 is not set
# CONFIG_DELL_RBTN is not set
CONFIG_FUJITSU_LAPTOP=m
CONFIG_FUJITSU_TABLET=m
CONFIG_AMILO_RFKILL=m
# CONFIG_GPD_POCKET_FAN is not set
CONFIG_HP_ACCEL=m
# CONFIG_HP_WIRELESS is not set
CONFIG_HP_WMI=m
CONFIG_MSI_LAPTOP=m
CONFIG_PANASONIC_LAPTOP=m
CONFIG_COMPAL_LAPTOP=m
CONFIG_SONY_LAPTOP=m
CONFIG_SONYPI_COMPAT=y
CONFIG_IDEAPAD_LAPTOP=m
# CONFIG_SURFACE3_WMI is not set
CONFIG_THINKPAD_ACPI=m
CONFIG_THINKPAD_ACPI_ALSA_SUPPORT=y
# CONFIG_THINKPAD_ACPI_DEBUGFACILITIES is not set
# CONFIG_THINKPAD_ACPI_DEBUG is not set
# CONFIG_THINKPAD_ACPI_UNSAFE_LEDS is not set
CONFIG_THINKPAD_ACPI_VIDEO=y
CONFIG_THINKPAD_ACPI_HOTKEY_POLL=y
CONFIG_SENSORS_HDAPS=m
# CONFIG_INTEL_MENLOW is not set
CONFIG_EEEPC_LAPTOP=m
CONFIG_ASUS_WMI=m
CONFIG_ASUS_NB_WMI=m
CONFIG_EEEPC_WMI=m
# CONFIG_ASUS_WIRELESS is not set
CONFIG_ACPI_WMI=m
CONFIG_WMI_BMOF=m
# CONFIG_INTEL_WMI_THUNDERBOLT is not set
CONFIG_MSI_WMI=m
# CONFIG_PEAQ_WMI is not set
CONFIG_TOPSTAR_LAPTOP=m
CONFIG_TOSHIBA_BT_RFKILL=m
# CONFIG_TOSHIBA_HAPS is not set
# CONFIG_TOSHIBA_WMI is not set
CONFIG_ACPI_CMPC=m
# CONFIG_INTEL_INT0002_VGPIO is not set
# CONFIG_INTEL_HID_EVENT is not set
# CONFIG_INTEL_VBTN is not set
CONFIG_INTEL_IPS=m
# CONFIG_INTEL_PMC_CORE is not set
# CONFIG_IBM_RTL is not set
CONFIG_SAMSUNG_LAPTOP=m
CONFIG_MXM_WMI=m
CONFIG_INTEL_OAKTRAIL=m
CONFIG_SAMSUNG_Q10=m
CONFIG_APPLE_GMUX=m
# CONFIG_INTEL_RST is not set
# CONFIG_INTEL_SMARTCONNECT is not set
CONFIG_PVPANIC=y
# CONFIG_INTEL_PMC_IPC is not set
# CONFIG_SURFACE_PRO3_BUTTON is not set
# CONFIG_INTEL_PUNIT_IPC is not set
# CONFIG_MLX_PLATFORM is not set
# CONFIG_INTEL_TURBO_MAX_3 is not set
CONFIG_PMC_ATOM=y
# CONFIG_CHROME_PLATFORMS is not set
# CONFIG_MELLANOX_PLATFORM is not set
CONFIG_CLKDEV_LOOKUP=y
CONFIG_HAVE_CLK_PREPARE=y
CONFIG_COMMON_CLK=y

#
# Common Clock Framework
#
# CONFIG_COMMON_CLK_SI5351 is not set
# CONFIG_COMMON_CLK_SI544 is not set
# CONFIG_COMMON_CLK_CDCE706 is not set
# CONFIG_COMMON_CLK_CS2000_CP is not set
# CONFIG_COMMON_CLK_PWM is not set
# CONFIG_HWSPINLOCK is not set

#
# Clock Source drivers
#
CONFIG_CLKEVT_I8253=y
CONFIG_I8253_LOCK=y
CONFIG_CLKBLD_I8253=y
CONFIG_MAILBOX=y
CONFIG_PCC=y
# CONFIG_ALTERA_MBOX is not set
CONFIG_IOMMU_API=y
CONFIG_IOMMU_SUPPORT=y

#
# Generic IOMMU Pagetable Support
#
CONFIG_IOMMU_IOVA=y
CONFIG_AMD_IOMMU=y
CONFIG_AMD_IOMMU_V2=m
CONFIG_DMAR_TABLE=y
CONFIG_INTEL_IOMMU=y
# CONFIG_INTEL_IOMMU_SVM is not set
# CONFIG_INTEL_IOMMU_DEFAULT_ON is not set
CONFIG_INTEL_IOMMU_FLOPPY_WA=y
CONFIG_IRQ_REMAP=y

#
# Remoteproc drivers
#
# CONFIG_REMOTEPROC is not set

#
# Rpmsg drivers
#
# CONFIG_RPMSG_QCOM_GLINK_RPM is not set
# CONFIG_RPMSG_VIRTIO is not set
# CONFIG_SOUNDWIRE is not set

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
# CONFIG_SOC_TI is not set

#
# Xilinx SoC drivers
#
# CONFIG_XILINX_VCU is not set
CONFIG_PM_DEVFREQ=y

#
# DEVFREQ Governors
#
CONFIG_DEVFREQ_GOV_SIMPLE_ONDEMAND=m
# CONFIG_DEVFREQ_GOV_PERFORMANCE is not set
# CONFIG_DEVFREQ_GOV_POWERSAVE is not set
# CONFIG_DEVFREQ_GOV_USERSPACE is not set
# CONFIG_DEVFREQ_GOV_PASSIVE is not set

#
# DEVFREQ Drivers
#
# CONFIG_PM_DEVFREQ_EVENT is not set
CONFIG_EXTCON=y

#
# Extcon Device Drivers
#
# CONFIG_EXTCON_GPIO is not set
# CONFIG_EXTCON_INTEL_INT3496 is not set
# CONFIG_EXTCON_MAX3355 is not set
# CONFIG_EXTCON_RT8973A is not set
# CONFIG_EXTCON_SM5502 is not set
# CONFIG_EXTCON_USB_GPIO is not set
# CONFIG_MEMORY is not set
# CONFIG_IIO is not set
CONFIG_NTB=m
# CONFIG_NTB_AMD is not set
# CONFIG_NTB_IDT is not set
# CONFIG_NTB_INTEL is not set
# CONFIG_NTB_SWITCHTEC is not set
# CONFIG_NTB_PINGPONG is not set
# CONFIG_NTB_TOOL is not set
# CONFIG_NTB_PERF is not set
# CONFIG_NTB_TRANSPORT is not set
# CONFIG_VME_BUS is not set
CONFIG_PWM=y
CONFIG_PWM_SYSFS=y
CONFIG_PWM_LPSS=m
CONFIG_PWM_LPSS_PCI=m
CONFIG_PWM_LPSS_PLATFORM=m
# CONFIG_PWM_PCA9685 is not set

#
# IRQ chip support
#
CONFIG_ARM_GIC_MAX_NR=1
# CONFIG_IPACK_BUS is not set
# CONFIG_RESET_CONTROLLER is not set
# CONFIG_FMC is not set

#
# PHY Subsystem
#
CONFIG_GENERIC_PHY=y
# CONFIG_BCM_KONA_USB2_PHY is not set
# CONFIG_PHY_PXA_28NM_HSIC is not set
# CONFIG_PHY_PXA_28NM_USB2 is not set
CONFIG_POWERCAP=y
CONFIG_INTEL_RAPL=m
# CONFIG_MCB is not set

#
# Performance monitor support
#
CONFIG_RAS=y
# CONFIG_RAS_CEC is not set
# CONFIG_THUNDERBOLT is not set

#
# Android
#
# CONFIG_ANDROID is not set
CONFIG_LIBNVDIMM=m
CONFIG_BLK_DEV_PMEM=m
CONFIG_ND_BLK=m
CONFIG_ND_CLAIM=y
CONFIG_ND_BTT=m
CONFIG_BTT=y
CONFIG_ND_PFN=m
CONFIG_NVDIMM_PFN=y
CONFIG_NVDIMM_DAX=y
CONFIG_DAX_DRIVER=y
CONFIG_DAX=y
CONFIG_DEV_DAX=m
CONFIG_DEV_DAX_PMEM=m
CONFIG_NVMEM=y

#
# HW tracing support
#
CONFIG_STM=m
CONFIG_STM_DUMMY=m
CONFIG_STM_SOURCE_CONSOLE=m
CONFIG_STM_SOURCE_HEARTBEAT=m
CONFIG_STM_SOURCE_FTRACE=m
CONFIG_INTEL_TH=m
CONFIG_INTEL_TH_PCI=m
# CONFIG_INTEL_TH_ACPI is not set
CONFIG_INTEL_TH_GTH=m
CONFIG_INTEL_TH_STH=m
CONFIG_INTEL_TH_MSU=m
CONFIG_INTEL_TH_PTI=m
# CONFIG_INTEL_TH_DEBUG is not set
# CONFIG_FPGA is not set
CONFIG_PM_OPP=y
# CONFIG_UNISYS_VISORBUS is not set
# CONFIG_SIOX is not set
# CONFIG_SLIMBUS is not set

#
# Firmware Drivers
#
CONFIG_EDD=m
# CONFIG_EDD_OFF is not set
CONFIG_FIRMWARE_MEMMAP=y
CONFIG_DELL_RBU=m
CONFIG_DCDBAS=m
CONFIG_DMIID=y
CONFIG_DMI_SYSFS=y
CONFIG_DMI_SCAN_MACHINE_NON_EFI_FALLBACK=y
CONFIG_ISCSI_IBFT_FIND=y
CONFIG_ISCSI_IBFT=m
# CONFIG_FW_CFG_SYSFS is not set
# CONFIG_GOOGLE_FIRMWARE is not set

#
# EFI (Extensible Firmware Interface) Support
#
CONFIG_EFI_VARS=y
CONFIG_EFI_ESRT=y
CONFIG_EFI_VARS_PSTORE=y
CONFIG_EFI_VARS_PSTORE_DEFAULT_DISABLE=y
CONFIG_EFI_RUNTIME_MAP=y
# CONFIG_EFI_FAKE_MEMMAP is not set
CONFIG_EFI_RUNTIME_WRAPPERS=y
# CONFIG_EFI_BOOTLOADER_CONTROL is not set
# CONFIG_EFI_CAPSULE_LOADER is not set
# CONFIG_EFI_TEST is not set
# CONFIG_APPLE_PROPERTIES is not set
# CONFIG_RESET_ATTACK_MITIGATION is not set
CONFIG_UEFI_CPER=y

#
# Tegra firmware driver
#

#
# File systems
#
CONFIG_DCACHE_WORD_ACCESS=y
CONFIG_FS_IOMAP=y
# CONFIG_EXT2_FS is not set
# CONFIG_EXT3_FS is not set
CONFIG_EXT4_FS=y
CONFIG_EXT4_USE_FOR_EXT2=y
CONFIG_EXT4_FS_POSIX_ACL=y
CONFIG_EXT4_FS_SECURITY=y
CONFIG_EXT4_ENCRYPTION=y
CONFIG_EXT4_FS_ENCRYPTION=y
# CONFIG_EXT4_DEBUG is not set
CONFIG_JBD2=y
# CONFIG_JBD2_DEBUG is not set
CONFIG_FS_MBCACHE=y
# CONFIG_REISERFS_FS is not set
# CONFIG_JFS_FS is not set
CONFIG_XFS_FS=m
CONFIG_XFS_QUOTA=y
CONFIG_XFS_POSIX_ACL=y
CONFIG_XFS_RT=y
# CONFIG_XFS_ONLINE_SCRUB is not set
CONFIG_XFS_DEBUG=y
CONFIG_XFS_ASSERT_FATAL=y
CONFIG_GFS2_FS=m
CONFIG_GFS2_FS_LOCKING_DLM=y
CONFIG_OCFS2_FS=m
CONFIG_OCFS2_FS_O2CB=m
CONFIG_OCFS2_FS_USERSPACE_CLUSTER=m
CONFIG_OCFS2_FS_STATS=y
CONFIG_OCFS2_DEBUG_MASKLOG=y
# CONFIG_OCFS2_DEBUG_FS is not set
CONFIG_BTRFS_FS=m
CONFIG_BTRFS_FS_POSIX_ACL=y
# CONFIG_BTRFS_FS_CHECK_INTEGRITY is not set
# CONFIG_BTRFS_FS_RUN_SANITY_TESTS is not set
# CONFIG_BTRFS_DEBUG is not set
# CONFIG_BTRFS_ASSERT is not set
# CONFIG_BTRFS_FS_REF_VERIFY is not set
# CONFIG_NILFS2_FS is not set
CONFIG_F2FS_FS=m
CONFIG_F2FS_STAT_FS=y
CONFIG_F2FS_FS_XATTR=y
CONFIG_F2FS_FS_POSIX_ACL=y
# CONFIG_F2FS_FS_SECURITY is not set
# CONFIG_F2FS_CHECK_FS is not set
CONFIG_F2FS_FS_ENCRYPTION=y
# CONFIG_F2FS_IO_TRACE is not set
# CONFIG_F2FS_FAULT_INJECTION is not set
CONFIG_FS_DAX=y
CONFIG_FS_DAX_PMD=y
CONFIG_FS_POSIX_ACL=y
CONFIG_EXPORTFS=y
# CONFIG_EXPORTFS_BLOCK_OPS is not set
CONFIG_FILE_LOCKING=y
CONFIG_MANDATORY_FILE_LOCKING=y
CONFIG_FS_ENCRYPTION=y
CONFIG_FSNOTIFY=y
CONFIG_DNOTIFY=y
CONFIG_INOTIFY_USER=y
CONFIG_FANOTIFY=y
CONFIG_FANOTIFY_ACCESS_PERMISSIONS=y
CONFIG_QUOTA=y
CONFIG_QUOTA_NETLINK_INTERFACE=y
CONFIG_PRINT_QUOTA_WARNING=y
# CONFIG_QUOTA_DEBUG is not set
CONFIG_QUOTA_TREE=y
# CONFIG_QFMT_V1 is not set
CONFIG_QFMT_V2=y
CONFIG_QUOTACTL=y
CONFIG_QUOTACTL_COMPAT=y
CONFIG_AUTOFS4_FS=y
CONFIG_FUSE_FS=m
CONFIG_CUSE=m
CONFIG_OVERLAY_FS=m
# CONFIG_OVERLAY_FS_REDIRECT_DIR is not set
CONFIG_OVERLAY_FS_REDIRECT_ALWAYS_FOLLOW=y
# CONFIG_OVERLAY_FS_INDEX is not set
# CONFIG_OVERLAY_FS_XINO_AUTO is not set

#
# Caches
#
CONFIG_FSCACHE=m
CONFIG_FSCACHE_STATS=y
# CONFIG_FSCACHE_HISTOGRAM is not set
# CONFIG_FSCACHE_DEBUG is not set
# CONFIG_FSCACHE_OBJECT_LIST is not set
CONFIG_CACHEFILES=m
# CONFIG_CACHEFILES_DEBUG is not set
# CONFIG_CACHEFILES_HISTOGRAM is not set

#
# CD-ROM/DVD Filesystems
#
CONFIG_ISO9660_FS=m
CONFIG_JOLIET=y
CONFIG_ZISOFS=y
CONFIG_UDF_FS=m
CONFIG_UDF_NLS=y

#
# DOS/FAT/NT Filesystems
#
CONFIG_FAT_FS=m
CONFIG_MSDOS_FS=m
CONFIG_VFAT_FS=m
CONFIG_FAT_DEFAULT_CODEPAGE=437
CONFIG_FAT_DEFAULT_IOCHARSET="ascii"
# CONFIG_FAT_DEFAULT_UTF8 is not set
# CONFIG_NTFS_FS is not set

#
# Pseudo filesystems
#
CONFIG_PROC_FS=y
CONFIG_PROC_KCORE=y
CONFIG_PROC_VMCORE=y
CONFIG_PROC_SYSCTL=y
CONFIG_PROC_PAGE_MONITOR=y
CONFIG_PROC_CHILDREN=y
CONFIG_KERNFS=y
CONFIG_SYSFS=y
CONFIG_TMPFS=y
CONFIG_TMPFS_POSIX_ACL=y
CONFIG_TMPFS_XATTR=y
CONFIG_HUGETLBFS=y
CONFIG_HUGETLB_PAGE=y
CONFIG_ARCH_HAS_GIGANTIC_PAGE=y
CONFIG_CONFIGFS_FS=y
CONFIG_EFIVAR_FS=y
CONFIG_MISC_FILESYSTEMS=y
# CONFIG_ORANGEFS_FS is not set
# CONFIG_ADFS_FS is not set
# CONFIG_AFFS_FS is not set
# CONFIG_ECRYPT_FS is not set
# CONFIG_HFS_FS is not set
# CONFIG_HFSPLUS_FS is not set
# CONFIG_BEFS_FS is not set
# CONFIG_BFS_FS is not set
# CONFIG_EFS_FS is not set
# CONFIG_JFFS2_FS is not set
# CONFIG_UBIFS_FS is not set
CONFIG_CRAMFS=m
CONFIG_CRAMFS_BLOCKDEV=y
# CONFIG_CRAMFS_MTD is not set
CONFIG_SQUASHFS=m
CONFIG_SQUASHFS_FILE_CACHE=y
# CONFIG_SQUASHFS_FILE_DIRECT is not set
CONFIG_SQUASHFS_DECOMP_SINGLE=y
# CONFIG_SQUASHFS_DECOMP_MULTI is not set
# CONFIG_SQUASHFS_DECOMP_MULTI_PERCPU is not set
CONFIG_SQUASHFS_XATTR=y
CONFIG_SQUASHFS_ZLIB=y
# CONFIG_SQUASHFS_LZ4 is not set
CONFIG_SQUASHFS_LZO=y
CONFIG_SQUASHFS_XZ=y
# CONFIG_SQUASHFS_ZSTD is not set
# CONFIG_SQUASHFS_4K_DEVBLK_SIZE is not set
# CONFIG_SQUASHFS_EMBEDDED is not set
CONFIG_SQUASHFS_FRAGMENT_CACHE_SIZE=3
# CONFIG_VXFS_FS is not set
# CONFIG_MINIX_FS is not set
# CONFIG_OMFS_FS is not set
# CONFIG_HPFS_FS is not set
# CONFIG_QNX4FS_FS is not set
# CONFIG_QNX6FS_FS is not set
# CONFIG_ROMFS_FS is not set
CONFIG_PSTORE=y
CONFIG_PSTORE_DEFLATE_COMPRESS=y
# CONFIG_PSTORE_LZO_COMPRESS is not set
# CONFIG_PSTORE_LZ4_COMPRESS is not set
# CONFIG_PSTORE_LZ4HC_COMPRESS is not set
# CONFIG_PSTORE_842_COMPRESS is not set
CONFIG_PSTORE_COMPRESS=y
CONFIG_PSTORE_DEFLATE_COMPRESS_DEFAULT=y
CONFIG_PSTORE_COMPRESS_DEFAULT="deflate"
CONFIG_PSTORE_CONSOLE=y
CONFIG_PSTORE_PMSG=y
# CONFIG_PSTORE_FTRACE is not set
CONFIG_PSTORE_RAM=m
# CONFIG_SYSV_FS is not set
# CONFIG_UFS_FS is not set
# CONFIG_EXOFS_FS is not set
CONFIG_NETWORK_FILESYSTEMS=y
CONFIG_NFS_FS=y
# CONFIG_NFS_V2 is not set
CONFIG_NFS_V3=y
CONFIG_NFS_V3_ACL=y
CONFIG_NFS_V4=m
# CONFIG_NFS_SWAP is not set
CONFIG_NFS_V4_1=y
CONFIG_NFS_V4_2=y
CONFIG_PNFS_FILE_LAYOUT=m
CONFIG_PNFS_BLOCK=m
CONFIG_PNFS_FLEXFILE_LAYOUT=m
CONFIG_NFS_V4_1_IMPLEMENTATION_ID_DOMAIN="kernel.org"
# CONFIG_NFS_V4_1_MIGRATION is not set
CONFIG_NFS_V4_SECURITY_LABEL=y
CONFIG_ROOT_NFS=y
# CONFIG_NFS_USE_LEGACY_DNS is not set
CONFIG_NFS_USE_KERNEL_DNS=y
CONFIG_NFS_DEBUG=y
CONFIG_NFSD=m
CONFIG_NFSD_V2_ACL=y
CONFIG_NFSD_V3=y
CONFIG_NFSD_V3_ACL=y
CONFIG_NFSD_V4=y
# CONFIG_NFSD_BLOCKLAYOUT is not set
# CONFIG_NFSD_SCSILAYOUT is not set
# CONFIG_NFSD_FLEXFILELAYOUT is not set
CONFIG_NFSD_V4_SECURITY_LABEL=y
# CONFIG_NFSD_FAULT_INJECTION is not set
CONFIG_GRACE_PERIOD=y
CONFIG_LOCKD=y
CONFIG_LOCKD_V4=y
CONFIG_NFS_ACL_SUPPORT=y
CONFIG_NFS_COMMON=y
CONFIG_SUNRPC=y
CONFIG_SUNRPC_GSS=m
CONFIG_SUNRPC_BACKCHANNEL=y
CONFIG_RPCSEC_GSS_KRB5=m
CONFIG_SUNRPC_DEBUG=y
# CONFIG_CEPH_FS is not set
CONFIG_CIFS=m
CONFIG_CIFS_STATS=y
# CONFIG_CIFS_STATS2 is not set
CONFIG_CIFS_WEAK_PW_HASH=y
CONFIG_CIFS_UPCALL=y
CONFIG_CIFS_XATTR=y
CONFIG_CIFS_POSIX=y
CONFIG_CIFS_ACL=y
CONFIG_CIFS_DEBUG=y
# CONFIG_CIFS_DEBUG2 is not set
# CONFIG_CIFS_DEBUG_DUMP_KEYS is not set
CONFIG_CIFS_DFS_UPCALL=y
# CONFIG_CIFS_SMB311 is not set
# CONFIG_CIFS_FSCACHE is not set
# CONFIG_CODA_FS is not set
# CONFIG_AFS_FS is not set
CONFIG_9P_FS=y
CONFIG_9P_FS_POSIX_ACL=y
# CONFIG_9P_FS_SECURITY is not set
CONFIG_NLS=y
CONFIG_NLS_DEFAULT="utf8"
CONFIG_NLS_CODEPAGE_437=y
CONFIG_NLS_CODEPAGE_737=m
CONFIG_NLS_CODEPAGE_775=m
CONFIG_NLS_CODEPAGE_850=m
CONFIG_NLS_CODEPAGE_852=m
CONFIG_NLS_CODEPAGE_855=m
CONFIG_NLS_CODEPAGE_857=m
CONFIG_NLS_CODEPAGE_860=m
CONFIG_NLS_CODEPAGE_861=m
CONFIG_NLS_CODEPAGE_862=m
CONFIG_NLS_CODEPAGE_863=m
CONFIG_NLS_CODEPAGE_864=m
CONFIG_NLS_CODEPAGE_865=m
CONFIG_NLS_CODEPAGE_866=m
CONFIG_NLS_CODEPAGE_869=m
CONFIG_NLS_CODEPAGE_936=m
CONFIG_NLS_CODEPAGE_950=m
CONFIG_NLS_CODEPAGE_932=m
CONFIG_NLS_CODEPAGE_949=m
CONFIG_NLS_CODEPAGE_874=m
CONFIG_NLS_ISO8859_8=m
CONFIG_NLS_CODEPAGE_1250=m
CONFIG_NLS_CODEPAGE_1251=m
CONFIG_NLS_ASCII=y
CONFIG_NLS_ISO8859_1=m
CONFIG_NLS_ISO8859_2=m
CONFIG_NLS_ISO8859_3=m
CONFIG_NLS_ISO8859_4=m
CONFIG_NLS_ISO8859_5=m
CONFIG_NLS_ISO8859_6=m
CONFIG_NLS_ISO8859_7=m
CONFIG_NLS_ISO8859_9=m
CONFIG_NLS_ISO8859_13=m
CONFIG_NLS_ISO8859_14=m
CONFIG_NLS_ISO8859_15=m
CONFIG_NLS_KOI8_R=m
CONFIG_NLS_KOI8_U=m
CONFIG_NLS_MAC_ROMAN=m
CONFIG_NLS_MAC_CELTIC=m
CONFIG_NLS_MAC_CENTEURO=m
CONFIG_NLS_MAC_CROATIAN=m
CONFIG_NLS_MAC_CYRILLIC=m
CONFIG_NLS_MAC_GAELIC=m
CONFIG_NLS_MAC_GREEK=m
CONFIG_NLS_MAC_ICELAND=m
CONFIG_NLS_MAC_INUIT=m
CONFIG_NLS_MAC_ROMANIAN=m
CONFIG_NLS_MAC_TURKISH=m
CONFIG_NLS_UTF8=m
CONFIG_DLM=m
CONFIG_DLM_DEBUG=y

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
CONFIG_BOOT_PRINTK_DELAY=y
CONFIG_DYNAMIC_DEBUG=y

#
# Compile-time checks and compiler options
#
CONFIG_DEBUG_INFO=y
CONFIG_DEBUG_INFO_REDUCED=y
# CONFIG_DEBUG_INFO_SPLIT is not set
# CONFIG_DEBUG_INFO_DWARF4 is not set
# CONFIG_GDB_SCRIPTS is not set
# CONFIG_ENABLE_WARN_DEPRECATED is not set
CONFIG_ENABLE_MUST_CHECK=y
CONFIG_FRAME_WARN=2048
CONFIG_STRIP_ASM_SYMS=y
# CONFIG_READABLE_ASM is not set
# CONFIG_UNUSED_SYMBOLS is not set
# CONFIG_PAGE_OWNER is not set
CONFIG_DEBUG_FS=y
CONFIG_HEADERS_CHECK=y
CONFIG_DEBUG_SECTION_MISMATCH=y
CONFIG_SECTION_MISMATCH_WARN_ONLY=y
CONFIG_STACK_VALIDATION=y
# CONFIG_DEBUG_FORCE_WEAK_PER_CPU is not set
CONFIG_MAGIC_SYSRQ=y
CONFIG_MAGIC_SYSRQ_DEFAULT_ENABLE=0x1
CONFIG_MAGIC_SYSRQ_SERIAL=y
CONFIG_DEBUG_KERNEL=y

#
# Memory Debugging
#
# CONFIG_PAGE_EXTENSION is not set
# CONFIG_DEBUG_PAGEALLOC is not set
# CONFIG_PAGE_POISONING is not set
# CONFIG_DEBUG_PAGE_REF is not set
CONFIG_DEBUG_RODATA_TEST=y
# CONFIG_DEBUG_OBJECTS is not set
# CONFIG_SLUB_DEBUG_ON is not set
# CONFIG_SLUB_STATS is not set
CONFIG_HAVE_DEBUG_KMEMLEAK=y
# CONFIG_DEBUG_KMEMLEAK is not set
# CONFIG_DEBUG_STACK_USAGE is not set
# CONFIG_DEBUG_VM is not set
CONFIG_ARCH_HAS_DEBUG_VIRTUAL=y
# CONFIG_DEBUG_VIRTUAL is not set
CONFIG_DEBUG_MEMORY_INIT=y
CONFIG_MEMORY_NOTIFIER_ERROR_INJECT=m
# CONFIG_DEBUG_PER_CPU_MAPS is not set
CONFIG_HAVE_DEBUG_STACKOVERFLOW=y
CONFIG_DEBUG_STACKOVERFLOW=y
CONFIG_HAVE_ARCH_KASAN=y
# CONFIG_KASAN is not set
CONFIG_ARCH_HAS_KCOV=y
# CONFIG_KCOV is not set
CONFIG_DEBUG_SHIRQ=y

#
# Debug Lockups and Hangs
#
CONFIG_LOCKUP_DETECTOR=y
CONFIG_SOFTLOCKUP_DETECTOR=y
# CONFIG_BOOTPARAM_SOFTLOCKUP_PANIC is not set
CONFIG_BOOTPARAM_SOFTLOCKUP_PANIC_VALUE=0
CONFIG_HARDLOCKUP_DETECTOR_PERF=y
CONFIG_HARDLOCKUP_CHECK_TIMESTAMP=y
CONFIG_HARDLOCKUP_DETECTOR=y
CONFIG_BOOTPARAM_HARDLOCKUP_PANIC=y
CONFIG_BOOTPARAM_HARDLOCKUP_PANIC_VALUE=1
# CONFIG_DETECT_HUNG_TASK is not set
# CONFIG_WQ_WATCHDOG is not set
CONFIG_PANIC_ON_OOPS=y
CONFIG_PANIC_ON_OOPS_VALUE=1
CONFIG_PANIC_TIMEOUT=0
CONFIG_SCHED_DEBUG=y
CONFIG_SCHED_INFO=y
CONFIG_SCHEDSTATS=y
# CONFIG_SCHED_STACK_END_CHECK is not set
# CONFIG_DEBUG_TIMEKEEPING is not set

#
# Lock Debugging (spinlocks, mutexes, etc...)
#
CONFIG_LOCK_DEBUGGING_SUPPORT=y
# CONFIG_PROVE_LOCKING is not set
# CONFIG_LOCK_STAT is not set
# CONFIG_DEBUG_RT_MUTEXES is not set
# CONFIG_DEBUG_SPINLOCK is not set
# CONFIG_DEBUG_MUTEXES is not set
# CONFIG_DEBUG_WW_MUTEX_SLOWPATH is not set
# CONFIG_DEBUG_RWSEMS is not set
# CONFIG_DEBUG_LOCK_ALLOC is not set
CONFIG_DEBUG_ATOMIC_SLEEP=y
# CONFIG_DEBUG_LOCKING_API_SELFTESTS is not set
CONFIG_LOCK_TORTURE_TEST=m
# CONFIG_WW_MUTEX_SELFTEST is not set
CONFIG_STACKTRACE=y
# CONFIG_WARN_ALL_UNSEEDED_RANDOM is not set
# CONFIG_DEBUG_KOBJECT is not set
CONFIG_DEBUG_BUGVERBOSE=y
CONFIG_DEBUG_LIST=y
# CONFIG_DEBUG_PI_LIST is not set
# CONFIG_DEBUG_SG is not set
# CONFIG_DEBUG_NOTIFIERS is not set
# CONFIG_DEBUG_CREDENTIALS is not set

#
# RCU Debugging
#
CONFIG_TORTURE_TEST=m
# CONFIG_RCU_PERF_TEST is not set
CONFIG_RCU_TORTURE_TEST=m
CONFIG_RCU_CPU_STALL_TIMEOUT=60
# CONFIG_RCU_TRACE is not set
# CONFIG_RCU_EQS_DEBUG is not set
# CONFIG_DEBUG_WQ_FORCE_RR_CPU is not set
# CONFIG_DEBUG_BLOCK_EXT_DEVT is not set
# CONFIG_CPU_HOTPLUG_STATE_CONTROL is not set
CONFIG_NOTIFIER_ERROR_INJECTION=m
CONFIG_PM_NOTIFIER_ERROR_INJECT=m
# CONFIG_NETDEV_NOTIFIER_ERROR_INJECT is not set
CONFIG_FAULT_INJECTION=y
CONFIG_FUNCTION_ERROR_INJECTION=y
# CONFIG_FAILSLAB is not set
# CONFIG_FAIL_PAGE_ALLOC is not set
CONFIG_FAIL_MAKE_REQUEST=y
# CONFIG_FAIL_IO_TIMEOUT is not set
# CONFIG_FAIL_MMC_REQUEST is not set
# CONFIG_FAIL_FUTEX is not set
# CONFIG_FAIL_FUNCTION is not set
CONFIG_FAULT_INJECTION_DEBUG_FS=y
CONFIG_LATENCYTOP=y
CONFIG_USER_STACKTRACE_SUPPORT=y
CONFIG_NOP_TRACER=y
CONFIG_HAVE_FUNCTION_TRACER=y
CONFIG_HAVE_FUNCTION_GRAPH_TRACER=y
CONFIG_HAVE_DYNAMIC_FTRACE=y
CONFIG_HAVE_DYNAMIC_FTRACE_WITH_REGS=y
CONFIG_HAVE_FTRACE_MCOUNT_RECORD=y
CONFIG_HAVE_SYSCALL_TRACEPOINTS=y
CONFIG_HAVE_FENTRY=y
CONFIG_HAVE_C_RECORDMCOUNT=y
CONFIG_TRACER_MAX_TRACE=y
CONFIG_TRACE_CLOCK=y
CONFIG_RING_BUFFER=y
CONFIG_EVENT_TRACING=y
CONFIG_CONTEXT_SWITCH_TRACER=y
CONFIG_RING_BUFFER_ALLOW_SWAP=y
CONFIG_TRACING=y
CONFIG_GENERIC_TRACER=y
CONFIG_TRACING_SUPPORT=y
CONFIG_FTRACE=y
CONFIG_FUNCTION_TRACER=y
CONFIG_FUNCTION_GRAPH_TRACER=y
# CONFIG_PREEMPTIRQ_EVENTS is not set
# CONFIG_IRQSOFF_TRACER is not set
CONFIG_SCHED_TRACER=y
# CONFIG_HWLAT_TRACER is not set
CONFIG_FTRACE_SYSCALLS=y
CONFIG_TRACER_SNAPSHOT=y
# CONFIG_TRACER_SNAPSHOT_PER_CPU_SWAP is not set
CONFIG_BRANCH_PROFILE_NONE=y
# CONFIG_PROFILE_ANNOTATED_BRANCHES is not set
# CONFIG_PROFILE_ALL_BRANCHES is not set
CONFIG_STACK_TRACER=y
CONFIG_BLK_DEV_IO_TRACE=y
CONFIG_KPROBE_EVENTS=y
CONFIG_UPROBE_EVENTS=y
CONFIG_BPF_EVENTS=y
CONFIG_PROBE_EVENTS=y
CONFIG_DYNAMIC_FTRACE=y
CONFIG_DYNAMIC_FTRACE_WITH_REGS=y
CONFIG_FUNCTION_PROFILER=y
# CONFIG_BPF_KPROBE_OVERRIDE is not set
CONFIG_FTRACE_MCOUNT_RECORD=y
# CONFIG_FTRACE_STARTUP_TEST is not set
# CONFIG_MMIOTRACE is not set
CONFIG_TRACING_MAP=y
CONFIG_HIST_TRIGGERS=y
# CONFIG_TRACEPOINT_BENCHMARK is not set
CONFIG_RING_BUFFER_BENCHMARK=m
# CONFIG_RING_BUFFER_STARTUP_TEST is not set
# CONFIG_TRACE_EVAL_MAP_FILE is not set
CONFIG_TRACING_EVENTS_GPIO=y
CONFIG_PROVIDE_OHCI1394_DMA_INIT=y
# CONFIG_DMA_API_DEBUG is not set
CONFIG_RUNTIME_TESTING_MENU=y
CONFIG_LKDTM=m
# CONFIG_TEST_LIST_SORT is not set
# CONFIG_TEST_SORT is not set
# CONFIG_KPROBES_SANITY_TEST is not set
# CONFIG_BACKTRACE_SELF_TEST is not set
CONFIG_RBTREE_TEST=m
CONFIG_INTERVAL_TREE_TEST=m
CONFIG_PERCPU_TEST=m
CONFIG_ATOMIC64_SELFTEST=y
CONFIG_ASYNC_RAID6_TEST=m
# CONFIG_TEST_HEXDUMP is not set
# CONFIG_TEST_STRING_HELPERS is not set
CONFIG_TEST_KSTRTOX=m
CONFIG_TEST_PRINTF=m
CONFIG_TEST_BITMAP=m
# CONFIG_TEST_UUID is not set
# CONFIG_TEST_RHASHTABLE is not set
# CONFIG_TEST_HASH is not set
CONFIG_TEST_LKM=m
CONFIG_TEST_USER_COPY=m
CONFIG_TEST_BPF=m
# CONFIG_FIND_BIT_BENCHMARK is not set
CONFIG_TEST_FIRMWARE=m
CONFIG_TEST_SYSCTL=m
CONFIG_TEST_UDELAY=m
CONFIG_TEST_STATIC_KEYS=m
CONFIG_TEST_KMOD=m
# CONFIG_MEMTEST is not set
# CONFIG_BUG_ON_DATA_CORRUPTION is not set
# CONFIG_SAMPLES is not set
CONFIG_HAVE_ARCH_KGDB=y
# CONFIG_KGDB is not set
CONFIG_ARCH_HAS_UBSAN_SANITIZE_ALL=y
# CONFIG_UBSAN is not set
CONFIG_ARCH_HAS_DEVMEM_IS_ALLOWED=y
CONFIG_STRICT_DEVMEM=y
# CONFIG_IO_STRICT_DEVMEM is not set
CONFIG_EARLY_PRINTK_USB=y
CONFIG_X86_VERBOSE_BOOTUP=y
CONFIG_EARLY_PRINTK=y
CONFIG_EARLY_PRINTK_DBGP=y
# CONFIG_EARLY_PRINTK_EFI is not set
# CONFIG_EARLY_PRINTK_USB_XDBC is not set
# CONFIG_X86_PTDUMP is not set
# CONFIG_EFI_PGT_DUMP is not set
# CONFIG_DEBUG_WX is not set
CONFIG_DOUBLEFAULT=y
# CONFIG_DEBUG_TLBFLUSH is not set
# CONFIG_IOMMU_DEBUG is not set
CONFIG_HAVE_MMIOTRACE_SUPPORT=y
CONFIG_X86_DECODER_SELFTEST=y
CONFIG_IO_DELAY_TYPE_0X80=0
CONFIG_IO_DELAY_TYPE_0XED=1
CONFIG_IO_DELAY_TYPE_UDELAY=2
CONFIG_IO_DELAY_TYPE_NONE=3
CONFIG_IO_DELAY_0X80=y
# CONFIG_IO_DELAY_0XED is not set
# CONFIG_IO_DELAY_UDELAY is not set
# CONFIG_IO_DELAY_NONE is not set
CONFIG_DEFAULT_IO_DELAY_TYPE=0
CONFIG_DEBUG_BOOT_PARAMS=y
# CONFIG_CPA_DEBUG is not set
CONFIG_OPTIMIZE_INLINING=y
# CONFIG_DEBUG_ENTRY is not set
# CONFIG_DEBUG_NMI_SELFTEST is not set
CONFIG_X86_DEBUG_FPU=y
# CONFIG_PUNIT_ATOM_DEBUG is not set
CONFIG_UNWINDER_ORC=y
# CONFIG_UNWINDER_FRAME_POINTER is not set
# CONFIG_UNWINDER_GUESS is not set

#
# Security options
#
CONFIG_KEYS=y
CONFIG_KEYS_COMPAT=y
CONFIG_PERSISTENT_KEYRINGS=y
CONFIG_BIG_KEYS=y
CONFIG_TRUSTED_KEYS=y
CONFIG_ENCRYPTED_KEYS=y
# CONFIG_KEY_DH_OPERATIONS is not set
# CONFIG_SECURITY_DMESG_RESTRICT is not set
CONFIG_SECURITY=y
CONFIG_SECURITY_WRITABLE_HOOKS=y
CONFIG_SECURITYFS=y
CONFIG_SECURITY_NETWORK=y
CONFIG_PAGE_TABLE_ISOLATION=y
CONFIG_SECURITY_NETWORK_XFRM=y
# CONFIG_SECURITY_PATH is not set
CONFIG_INTEL_TXT=y
CONFIG_LSM_MMAP_MIN_ADDR=65535
CONFIG_HAVE_HARDENED_USERCOPY_ALLOCATOR=y
# CONFIG_HARDENED_USERCOPY is not set
# CONFIG_FORTIFY_SOURCE is not set
# CONFIG_STATIC_USERMODEHELPER is not set
CONFIG_SECURITY_SELINUX=y
CONFIG_SECURITY_SELINUX_BOOTPARAM=y
CONFIG_SECURITY_SELINUX_BOOTPARAM_VALUE=1
CONFIG_SECURITY_SELINUX_DISABLE=y
CONFIG_SECURITY_SELINUX_DEVELOP=y
CONFIG_SECURITY_SELINUX_AVC_STATS=y
CONFIG_SECURITY_SELINUX_CHECKREQPROT_VALUE=1
# CONFIG_SECURITY_SMACK is not set
# CONFIG_SECURITY_TOMOYO is not set
# CONFIG_SECURITY_APPARMOR is not set
# CONFIG_SECURITY_LOADPIN is not set
# CONFIG_SECURITY_YAMA is not set
CONFIG_INTEGRITY=y
CONFIG_INTEGRITY_SIGNATURE=y
CONFIG_INTEGRITY_ASYMMETRIC_KEYS=y
CONFIG_INTEGRITY_TRUSTED_KEYRING=y
CONFIG_INTEGRITY_AUDIT=y
CONFIG_IMA=y
CONFIG_IMA_MEASURE_PCR_IDX=10
CONFIG_IMA_LSM_RULES=y
# CONFIG_IMA_TEMPLATE is not set
CONFIG_IMA_NG_TEMPLATE=y
# CONFIG_IMA_SIG_TEMPLATE is not set
CONFIG_IMA_DEFAULT_TEMPLATE="ima-ng"
CONFIG_IMA_DEFAULT_HASH_SHA1=y
# CONFIG_IMA_DEFAULT_HASH_SHA256 is not set
# CONFIG_IMA_DEFAULT_HASH_SHA512 is not set
CONFIG_IMA_DEFAULT_HASH="sha1"
# CONFIG_IMA_WRITE_POLICY is not set
# CONFIG_IMA_READ_POLICY is not set
CONFIG_IMA_APPRAISE=y
CONFIG_IMA_APPRAISE_BOOTPARAM=y
CONFIG_IMA_TRUSTED_KEYRING=y
# CONFIG_IMA_BLACKLIST_KEYRING is not set
# CONFIG_IMA_LOAD_X509 is not set
CONFIG_EVM=y
CONFIG_EVM_ATTR_FSUUID=y
# CONFIG_EVM_LOAD_X509 is not set
CONFIG_DEFAULT_SECURITY_SELINUX=y
# CONFIG_DEFAULT_SECURITY_DAC is not set
CONFIG_DEFAULT_SECURITY="selinux"
CONFIG_XOR_BLOCKS=m
CONFIG_ASYNC_CORE=m
CONFIG_ASYNC_MEMCPY=m
CONFIG_ASYNC_XOR=m
CONFIG_ASYNC_PQ=m
CONFIG_ASYNC_RAID6_RECOV=m
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
CONFIG_CRYPTO_ACOMP2=y
CONFIG_CRYPTO_RSA=y
# CONFIG_CRYPTO_DH is not set
# CONFIG_CRYPTO_ECDH is not set
CONFIG_CRYPTO_MANAGER=y
CONFIG_CRYPTO_MANAGER2=y
CONFIG_CRYPTO_USER=m
CONFIG_CRYPTO_MANAGER_DISABLE_TESTS=y
CONFIG_CRYPTO_GF128MUL=y
CONFIG_CRYPTO_NULL=y
CONFIG_CRYPTO_NULL2=y
CONFIG_CRYPTO_PCRYPT=m
CONFIG_CRYPTO_WORKQUEUE=y
CONFIG_CRYPTO_CRYPTD=m
CONFIG_CRYPTO_MCRYPTD=m
CONFIG_CRYPTO_AUTHENC=m
CONFIG_CRYPTO_TEST=m
CONFIG_CRYPTO_SIMD=m
CONFIG_CRYPTO_GLUE_HELPER_X86=m
CONFIG_CRYPTO_ENGINE=m

#
# Authenticated Encryption with Associated Data
#
CONFIG_CRYPTO_CCM=m
CONFIG_CRYPTO_GCM=y
# CONFIG_CRYPTO_CHACHA20POLY1305 is not set
CONFIG_CRYPTO_SEQIV=y
CONFIG_CRYPTO_ECHAINIV=m

#
# Block modes
#
CONFIG_CRYPTO_CBC=y
# CONFIG_CRYPTO_CFB is not set
CONFIG_CRYPTO_CTR=y
CONFIG_CRYPTO_CTS=y
CONFIG_CRYPTO_ECB=y
CONFIG_CRYPTO_LRW=m
CONFIG_CRYPTO_PCBC=m
CONFIG_CRYPTO_XTS=y
# CONFIG_CRYPTO_KEYWRAP is not set

#
# Hash modes
#
CONFIG_CRYPTO_CMAC=m
CONFIG_CRYPTO_HMAC=y
CONFIG_CRYPTO_XCBC=m
CONFIG_CRYPTO_VMAC=m

#
# Digest
#
CONFIG_CRYPTO_CRC32C=y
CONFIG_CRYPTO_CRC32C_INTEL=m
CONFIG_CRYPTO_CRC32=m
CONFIG_CRYPTO_CRC32_PCLMUL=m
CONFIG_CRYPTO_CRCT10DIF=y
CONFIG_CRYPTO_CRCT10DIF_PCLMUL=m
CONFIG_CRYPTO_GHASH=y
# CONFIG_CRYPTO_POLY1305 is not set
# CONFIG_CRYPTO_POLY1305_X86_64 is not set
CONFIG_CRYPTO_MD4=m
CONFIG_CRYPTO_MD5=y
CONFIG_CRYPTO_MICHAEL_MIC=m
CONFIG_CRYPTO_RMD128=m
CONFIG_CRYPTO_RMD160=m
CONFIG_CRYPTO_RMD256=m
CONFIG_CRYPTO_RMD320=m
CONFIG_CRYPTO_SHA1=y
CONFIG_CRYPTO_SHA1_SSSE3=m
CONFIG_CRYPTO_SHA256_SSSE3=m
CONFIG_CRYPTO_SHA512_SSSE3=m
CONFIG_CRYPTO_SHA1_MB=m
CONFIG_CRYPTO_SHA256_MB=m
CONFIG_CRYPTO_SHA512_MB=m
CONFIG_CRYPTO_SHA256=y
CONFIG_CRYPTO_SHA512=y
CONFIG_CRYPTO_SHA3=m
# CONFIG_CRYPTO_SM3 is not set
CONFIG_CRYPTO_TGR192=m
CONFIG_CRYPTO_WP512=m
CONFIG_CRYPTO_GHASH_CLMUL_NI_INTEL=m

#
# Ciphers
#
CONFIG_CRYPTO_AES=y
# CONFIG_CRYPTO_AES_TI is not set
CONFIG_CRYPTO_AES_X86_64=y
CONFIG_CRYPTO_AES_NI_INTEL=m
CONFIG_CRYPTO_ANUBIS=m
CONFIG_CRYPTO_ARC4=m
CONFIG_CRYPTO_BLOWFISH=m
CONFIG_CRYPTO_BLOWFISH_COMMON=m
CONFIG_CRYPTO_BLOWFISH_X86_64=m
CONFIG_CRYPTO_CAMELLIA=m
CONFIG_CRYPTO_CAMELLIA_X86_64=m
CONFIG_CRYPTO_CAMELLIA_AESNI_AVX_X86_64=m
CONFIG_CRYPTO_CAMELLIA_AESNI_AVX2_X86_64=m
CONFIG_CRYPTO_CAST_COMMON=m
CONFIG_CRYPTO_CAST5=m
CONFIG_CRYPTO_CAST5_AVX_X86_64=m
CONFIG_CRYPTO_CAST6=m
CONFIG_CRYPTO_CAST6_AVX_X86_64=m
CONFIG_CRYPTO_DES=m
# CONFIG_CRYPTO_DES3_EDE_X86_64 is not set
CONFIG_CRYPTO_FCRYPT=m
CONFIG_CRYPTO_KHAZAD=m
CONFIG_CRYPTO_SALSA20=m
CONFIG_CRYPTO_SALSA20_X86_64=m
# CONFIG_CRYPTO_CHACHA20 is not set
# CONFIG_CRYPTO_CHACHA20_X86_64 is not set
CONFIG_CRYPTO_SEED=m
CONFIG_CRYPTO_SERPENT=m
CONFIG_CRYPTO_SERPENT_SSE2_X86_64=m
CONFIG_CRYPTO_SERPENT_AVX_X86_64=m
CONFIG_CRYPTO_SERPENT_AVX2_X86_64=m
# CONFIG_CRYPTO_SM4 is not set
# CONFIG_CRYPTO_SPECK is not set
CONFIG_CRYPTO_TEA=m
CONFIG_CRYPTO_TWOFISH=m
CONFIG_CRYPTO_TWOFISH_COMMON=m
CONFIG_CRYPTO_TWOFISH_X86_64=m
CONFIG_CRYPTO_TWOFISH_X86_64_3WAY=m
CONFIG_CRYPTO_TWOFISH_AVX_X86_64=m

#
# Compression
#
CONFIG_CRYPTO_DEFLATE=y
CONFIG_CRYPTO_LZO=y
# CONFIG_CRYPTO_842 is not set
# CONFIG_CRYPTO_LZ4 is not set
# CONFIG_CRYPTO_LZ4HC is not set

#
# Random Number Generation
#
CONFIG_CRYPTO_ANSI_CPRNG=m
CONFIG_CRYPTO_DRBG_MENU=y
CONFIG_CRYPTO_DRBG_HMAC=y
# CONFIG_CRYPTO_DRBG_HASH is not set
# CONFIG_CRYPTO_DRBG_CTR is not set
CONFIG_CRYPTO_DRBG=y
CONFIG_CRYPTO_JITTERENTROPY=y
CONFIG_CRYPTO_USER_API=y
CONFIG_CRYPTO_USER_API_HASH=y
CONFIG_CRYPTO_USER_API_SKCIPHER=y
# CONFIG_CRYPTO_USER_API_RNG is not set
# CONFIG_CRYPTO_USER_API_AEAD is not set
CONFIG_CRYPTO_HASH_INFO=y
CONFIG_CRYPTO_HW=y
CONFIG_CRYPTO_DEV_PADLOCK=m
CONFIG_CRYPTO_DEV_PADLOCK_AES=m
CONFIG_CRYPTO_DEV_PADLOCK_SHA=m
# CONFIG_CRYPTO_DEV_CCP is not set
# CONFIG_CRYPTO_DEV_QAT_DH895xCC is not set
# CONFIG_CRYPTO_DEV_QAT_C3XXX is not set
# CONFIG_CRYPTO_DEV_QAT_C62X is not set
# CONFIG_CRYPTO_DEV_QAT_DH895xCCVF is not set
# CONFIG_CRYPTO_DEV_QAT_C3XXXVF is not set
# CONFIG_CRYPTO_DEV_QAT_C62XVF is not set
# CONFIG_CRYPTO_DEV_NITROX_CNN55XX is not set
# CONFIG_CRYPTO_DEV_CHELSIO is not set
CONFIG_CRYPTO_DEV_VIRTIO=m
CONFIG_ASYMMETRIC_KEY_TYPE=y
CONFIG_ASYMMETRIC_PUBLIC_KEY_SUBTYPE=y
CONFIG_X509_CERTIFICATE_PARSER=y
CONFIG_PKCS7_MESSAGE_PARSER=y
# CONFIG_PKCS7_TEST_KEY is not set
# CONFIG_SIGNED_PE_FILE_VERIFICATION is not set

#
# Certificates for signature checking
#
CONFIG_SYSTEM_TRUSTED_KEYRING=y
CONFIG_SYSTEM_TRUSTED_KEYS=""
# CONFIG_SYSTEM_EXTRA_CERTIFICATE is not set
# CONFIG_SECONDARY_TRUSTED_KEYRING is not set
# CONFIG_SYSTEM_BLACKLIST_KEYRING is not set
CONFIG_HAVE_KVM=y
CONFIG_HAVE_KVM_IRQCHIP=y
CONFIG_HAVE_KVM_IRQFD=y
CONFIG_HAVE_KVM_IRQ_ROUTING=y
CONFIG_HAVE_KVM_EVENTFD=y
CONFIG_KVM_MMIO=y
CONFIG_KVM_ASYNC_PF=y
CONFIG_HAVE_KVM_MSI=y
CONFIG_HAVE_KVM_CPU_RELAX_INTERCEPT=y
CONFIG_KVM_VFIO=y
CONFIG_KVM_GENERIC_DIRTYLOG_READ_PROTECT=y
CONFIG_KVM_COMPAT=y
CONFIG_HAVE_KVM_IRQ_BYPASS=y
CONFIG_VIRTUALIZATION=y
CONFIG_KVM=m
CONFIG_KVM_INTEL=m
CONFIG_KVM_AMD=m
CONFIG_KVM_MMU_AUDIT=y
CONFIG_VHOST_NET=m
# CONFIG_VHOST_SCSI is not set
# CONFIG_VHOST_VSOCK is not set
CONFIG_VHOST=m
# CONFIG_VHOST_CROSS_ENDIAN_LEGACY is not set
CONFIG_BINARY_PRINTF=y

#
# Library routines
#
CONFIG_RAID6_PQ=m
CONFIG_BITREVERSE=y
CONFIG_RATIONAL=y
CONFIG_GENERIC_STRNCPY_FROM_USER=y
CONFIG_GENERIC_STRNLEN_USER=y
CONFIG_GENERIC_NET_UTILS=y
CONFIG_GENERIC_FIND_FIRST_BIT=y
CONFIG_GENERIC_PCI_IOMAP=y
CONFIG_GENERIC_IOMAP=y
CONFIG_ARCH_USE_CMPXCHG_LOCKREF=y
CONFIG_ARCH_HAS_FAST_MULTIPLIER=y
CONFIG_CRC_CCITT=y
CONFIG_CRC16=y
CONFIG_CRC_T10DIF=y
CONFIG_CRC_ITU_T=m
CONFIG_CRC32=y
# CONFIG_CRC32_SELFTEST is not set
CONFIG_CRC32_SLICEBY8=y
# CONFIG_CRC32_SLICEBY4 is not set
# CONFIG_CRC32_SARWATE is not set
# CONFIG_CRC32_BIT is not set
# CONFIG_CRC4 is not set
# CONFIG_CRC7 is not set
CONFIG_LIBCRC32C=y
CONFIG_CRC8=m
CONFIG_XXHASH=m
# CONFIG_RANDOM32_SELFTEST is not set
CONFIG_ZLIB_INFLATE=y
CONFIG_ZLIB_DEFLATE=y
CONFIG_LZO_COMPRESS=y
CONFIG_LZO_DECOMPRESS=y
CONFIG_LZ4_DECOMPRESS=y
CONFIG_ZSTD_COMPRESS=m
CONFIG_ZSTD_DECOMPRESS=m
CONFIG_XZ_DEC=y
CONFIG_XZ_DEC_X86=y
CONFIG_XZ_DEC_POWERPC=y
CONFIG_XZ_DEC_IA64=y
CONFIG_XZ_DEC_ARM=y
CONFIG_XZ_DEC_ARMTHUMB=y
CONFIG_XZ_DEC_SPARC=y
CONFIG_XZ_DEC_BCJ=y
# CONFIG_XZ_DEC_TEST is not set
CONFIG_DECOMPRESS_GZIP=y
CONFIG_DECOMPRESS_BZIP2=y
CONFIG_DECOMPRESS_LZMA=y
CONFIG_DECOMPRESS_XZ=y
CONFIG_DECOMPRESS_LZO=y
CONFIG_DECOMPRESS_LZ4=y
CONFIG_GENERIC_ALLOCATOR=y
CONFIG_REED_SOLOMON=m
CONFIG_REED_SOLOMON_ENC8=y
CONFIG_REED_SOLOMON_DEC8=y
CONFIG_TEXTSEARCH=y
CONFIG_TEXTSEARCH_KMP=m
CONFIG_TEXTSEARCH_BM=m
CONFIG_TEXTSEARCH_FSM=m
CONFIG_BTREE=y
CONFIG_INTERVAL_TREE=y
CONFIG_RADIX_TREE_MULTIORDER=y
CONFIG_ASSOCIATIVE_ARRAY=y
CONFIG_HAS_IOMEM=y
CONFIG_HAS_IOPORT_MAP=y
CONFIG_HAS_DMA=y
CONFIG_SGL_ALLOC=y
CONFIG_DMA_DIRECT_OPS=y
CONFIG_CHECK_SIGNATURE=y
CONFIG_CPUMASK_OFFSTACK=y
CONFIG_CPU_RMAP=y
CONFIG_DQL=y
CONFIG_GLOB=y
# CONFIG_GLOB_SELFTEST is not set
CONFIG_NLATTR=y
CONFIG_CLZ_TAB=y
CONFIG_CORDIC=m
# CONFIG_DDR is not set
CONFIG_IRQ_POLL=y
CONFIG_MPILIB=y
CONFIG_SIGNATURE=y
CONFIG_OID_REGISTRY=y
CONFIG_UCS2_STRING=y
CONFIG_FONT_SUPPORT=y
# CONFIG_FONTS is not set
CONFIG_FONT_8x8=y
CONFIG_FONT_8x16=y
CONFIG_SG_POOL=y
CONFIG_ARCH_HAS_SG_CHAIN=y
CONFIG_ARCH_HAS_PMEM_API=y
CONFIG_ARCH_HAS_UACCESS_FLUSHCACHE=y
CONFIG_SBITMAP=y
# CONFIG_STRING_SELFTEST is not set

--55egzavp6tupoytm--
