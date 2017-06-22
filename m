From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: Bad page state freeing hugepages
Date: Thu, 22 Jun 2017 19:22:09 +0900
Message-ID: <790f64f4-dd29-5a9c-b979-725a5b58805a@I-love.SAKURA.ne.jp>
References: <20170615005612.5eeqdajx5qnhxxuf@sasha-lappy>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170615005612.5eeqdajx5qnhxxuf@sasha-lappy>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "Levin, Alexander (Sasha Levin)" <alexander.levin@verizon.com>, "hughd@google.com" <hughd@google.com>, "mhocko@kernel.org" <mhocko@kernel.org>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-Id: linux-mm.kvack.org

FYI, I'm hitting this problem by doing just boot or shutdown sequence,
and this problem is remaining as of next-20170622.

localhost login: [   37.010894] BUG: Bad page state in process gdbus  pfn:11f001
[   37.015328] page:ffffc0ce447c0040 count:0 mapcount:1 mapping:dead000000000000 index:0x7fab97e01 compound_mapcount: 1
[   37.022580] flags: 0x2fffff80000000()
[   37.025584] raw: 002fffff80000000 dead000000000000 0000000000000000 00000000ffffffff
[   37.030924] raw: ffffc0ce447c0001 0000000900000003 0000000000000000 0000000000000000
[   37.035356] page dumped because: nonzero compound_mapcount
[   37.037590] Modules linked in: nf_conntrack_netbios_ns nf_conntrack_broadcast ip6t_rpfilter ipt_REJECT nf_reject_ipv4 ip6t_REJECT nf_reject_ipv6 xt_conntrack ip_set nfnetlink ebtable_nat ebtable_broute bridge stp llc ip6table_nat nf_conntrack_ipv6 nf_defrag_ipv6 nf_nat_ipv6 ip6table_mangle ip6table_raw iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack iptable_mangle iptable_raw ebtable_filter ebtables ip6table_filter ip6_tables iptable_filter coretemp ppdev vmw_balloon pcspkr sg parport_pc vmw_vmci i2c_piix4 parport shpchp ip_tables xfs libcrc32c sr_mod cdrom ata_generic sd_mod pata_acpi vmwgfx mptspi serio_raw drm_kms_helper syscopyarea sysfillrect scsi_transport_spi sysimgblt fb_sys_fops ttm ahci libahci mptscsih e1000 ata_piix drm i2c_core libata mptbase
[   37.066948] CPU: 1 PID: 618 Comm: gdbus Not tainted 4.12.0-rc6-next-20170620 #105
[   37.070248] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
[   37.075194] Call Trace:
[   37.076470]  dump_stack+0x86/0xcf
[   37.078031]  bad_page+0xc1/0x120
[   37.079400]  __free_pages_ok+0x40c/0x5f0
[   37.080979]  free_compound_page+0x1b/0x20
[   37.082581]  free_transhuge_page+0xa4/0xb0
[   37.084486]  ? get_futex_key+0x122/0x730
[   37.086065]  __put_compound_page+0x30/0x50
[   37.087710]  __put_page+0x22/0x40
[   37.089020]  get_futex_key+0x2fa/0x730
[   37.090524]  futex_wake+0x6a/0x170
[   37.092052]  do_futex+0x2a8/0x560
[   37.093521]  ? sched_clock+0x9/0x10
[   37.095007]  ? __might_fault+0x3e/0x90
[   37.097070]  SyS_futex+0x83/0x190
[   37.098577]  mm_release+0x113/0x160
[   37.100046]  do_exit+0x150/0xda0
[   37.101406]  ? get_signal+0x3a4/0x910
[   37.103298]  do_group_exit+0x50/0xd0
[   37.104733]  get_signal+0x2e4/0x910
[   37.106114]  ? trace_hardirqs_on+0xd/0x10
[   37.107833]  do_signal+0x37/0x6b0
[   37.109167]  ? trace_hardirqs_on_caller+0xf5/0x190
[   37.111277]  ? __audit_syscall_exit+0x220/0x2c0
[   37.113271]  ? rcu_read_lock_sched_held+0x4a/0x80
[   37.115305]  ? kfree+0x284/0x2e0
[   37.116614]  ? __audit_syscall_exit+0x220/0x2c0
[   37.118438]  exit_to_usermode_loop+0x69/0xa0
[   37.120508]  do_syscall_64+0x167/0x1c0
[   37.122405]  entry_SYSCALL64_slow_path+0x25/0x25
[   37.124438] RIP: 0033:0x7fab9e5eae2d
[   37.126457] RSP: 002b:00007fab97ffed20 EFLAGS: 00000293 ORIG_RAX: 0000000000000007
[   37.130273] RAX: fffffffffffffdfc RBX: 0000556a49e04540 RCX: 00007fab9e5eae2d
[   37.133741] RDX: 00000000ffffffff RSI: 0000000000000002 RDI: 00007fab900010c0
[   37.137124] RBP: 0000000000000002 R08: 0000000000000002 R09: 0000000000000000
[   37.140547] R10: 0000000000000001 R11: 0000000000000293 R12: 00007fab900010c0
[   37.143980] R13: 00000000ffffffff R14: 00007fab9ed318b0 R15: 0000000000000002
[   37.147453] Disabling lock debugging due to kernel taint
[   37.150240] page:ffffc0ce447c0000 count:0 mapcount:-1 mapping:          (null) index:0x7fab97e00 compound_mapcount: 0
[   37.156008] flags: 0x2fffff80048008(uptodate|head|swapbacked)
[   37.158928] raw: 002fffff80048008 0000000000000000 00000007fab97e00 00000000fffffffe
[   37.163068] raw: ffffc0ce447c0020 ffffc0ce447c0020 0000000000000000 0000000000000000
[   37.167455] page dumped because: VM_BUG_ON_PAGE(page_mapcount(page) < 0)
[   37.171391] ------------[ cut here ]------------
[   37.174013] kernel BUG at mm/huge_memory.c:1646!
[   37.176439] invalid opcode: 0000 [#1] SMP DEBUG_PAGEALLOC
[   37.179034] Modules linked in: nf_conntrack_netbios_ns nf_conntrack_broadcast ip6t_rpfilter ipt_REJECT nf_reject_ipv4 ip6t_REJECT nf_reject_ipv6 xt_conntrack ip_set nfnetlink ebtable_nat ebtable_broute bridge stp llc ip6table_nat nf_conntrack_ipv6 nf_defrag_ipv6 nf_nat_ipv6 ip6table_mangle ip6table_raw iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack iptable_mangle iptable_raw ebtable_filter ebtables ip6table_filter ip6_tables iptable_filter coretemp ppdev vmw_balloon pcspkr sg parport_pc vmw_vmci i2c_piix4 parport shpchp ip_tables xfs libcrc32c sr_mod cdrom ata_generic sd_mod pata_acpi vmwgfx mptspi serio_raw drm_kms_helper syscopyarea sysfillrect scsi_transport_spi sysimgblt fb_sys_fops ttm ahci libahci mptscsih e1000 ata_piix drm i2c_core libata mptbase
[   37.211562] CPU: 2 PID: 618 Comm: gdbus Tainted: G    B           4.12.0-rc6-next-20170620 #105
[   37.215856] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
[   37.220759] task: ffff8d10eded4a40 task.stack: ffff9ab782264000
[   37.223678] RIP: 0010:zap_huge_pmd+0x28c/0x2a0
[   37.226100] RSP: 0018:ffff9ab782267a30 EFLAGS: 00010246
[   37.228761] RAX: 000000000000003c RBX: ffffc0ce447c0000 RCX: 0000000000000000
[   37.232238] RDX: 0000000000000000 RSI: 0000000000000000 RDI: ffff8d10f33ce368
[   37.235620] RBP: ffff9ab782267a60 R08: 0000000000000000 R09: 0000000000000001
[   37.239378] R10: ffff9ab782267968 R11: 0000000000000000 R12: ffff8d10ecb934a0
[   37.242843] R13: ffff8d10eb9d75f8 R14: ffff9ab782267bd8 R15: 00003fffffe00000
[   37.246524] FS:  00007fab97fff700(0000) GS:ffff8d10f3200000(0000) knlGS:0000000000000000
[   37.250734] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   37.253589] CR2: 00007fd4a29f7000 CR3: 000000012db6b000 CR4: 00000000001406e0
[   37.257211] Call Trace:
[   37.258811]  unmap_page_range+0x8d7/0x970
[   37.261008]  unmap_single_vma+0x59/0xe0
[   37.263238]  ? __slab_free+0xa4/0x280
[   37.265304]  unmap_vmas+0x37/0x50
[   37.267229]  exit_mmap+0x97/0x150
[   37.269150]  mmput+0x71/0x160
[   37.270956]  do_exit+0x2cf/0xda0
[   37.273155]  ? get_signal+0x3a4/0x910
[   37.275229]  do_group_exit+0x50/0xd0
[   37.277311]  get_signal+0x2e4/0x910
[   37.279304]  ? trace_hardirqs_on+0xd/0x10
[   37.281541]  do_signal+0x37/0x6b0
[   37.283506]  ? trace_hardirqs_on_caller+0xf5/0x190
[   37.286058]  ? __audit_syscall_exit+0x220/0x2c0
[   37.288678]  ? rcu_read_lock_sched_held+0x4a/0x80
[   37.291116]  ? kfree+0x284/0x2e0
[   37.292993]  ? __audit_syscall_exit+0x220/0x2c0
[   37.295396]  exit_to_usermode_loop+0x69/0xa0
[   37.297784]  do_syscall_64+0x167/0x1c0
[   37.299854]  entry_SYSCALL64_slow_path+0x25/0x25
[   37.302298] RIP: 0033:0x7fab9e5eae2d
[   37.304499] RSP: 002b:00007fab97ffed20 EFLAGS: 00000293 ORIG_RAX: 0000000000000007
[   37.308313] RAX: fffffffffffffdfc RBX: 0000556a49e04540 RCX: 00007fab9e5eae2d
[   37.311755] RDX: 00000000ffffffff RSI: 0000000000000002 RDI: 00007fab900010c0
[   37.315123] RBP: 0000000000000002 R08: 0000000000000002 R09: 0000000000000000
[   37.318786] R10: 0000000000000001 R11: 0000000000000293 R12: 00007fab900010c0
[   37.322110] R13: 00000000ffffffff R14: 00007fab9ed318b0 R15: 0000000000000002
[   37.325448] Code: 00 00 00 fe ff ff e9 cd fe ff ff 48 c7 c6 a0 14 c4 90 48 89 df e8 65 2f fb ff 0f 0b 48 c7 c6 60 53 c4 90 48 89 df e8 54 2f fb ff <0f> 0b 48 c7 c6 98 05 c4 90 48 89 df e8 43 2f fb ff 0f 0b 90 0f
[   37.334298] RIP: zap_huge_pmd+0x28c/0x2a0 RSP: ffff9ab782267a30
[   37.337276] ---[ end trace 35bcf1187115bba1 ]---
[   37.339693] Fixing recursive fault but reboot is needed!
[   37.342383] BUG: scheduling while atomic: gdbus/618/0x00000002
[   37.346255] INFO: lockdep is turned off.
[   37.348380] Modules linked in: nf_conntrack_netbios_ns nf_conntrack_broadcast ip6t_rpfilter ipt_REJECT nf_reject_ipv4 ip6t_REJECT nf_reject_ipv6 xt_conntrack ip_set nfnetlink ebtable_nat ebtable_broute bridge stp llc ip6table_nat nf_conntrack_ipv6 nf_defrag_ipv6 nf_nat_ipv6 ip6table_mangle ip6table_raw iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack iptable_mangle iptable_raw ebtable_filter ebtables ip6table_filter ip6_tables iptable_filter coretemp ppdev vmw_balloon pcspkr sg parport_pc vmw_vmci i2c_piix4 parport shpchp ip_tables xfs libcrc32c sr_mod cdrom ata_generic sd_mod pata_acpi vmwgfx mptspi serio_raw drm_kms_helper syscopyarea sysfillrect scsi_transport_spi sysimgblt fb_sys_fops ttm ahci libahci mptscsih e1000 ata_piix drm i2c_core libata mptbase
[   37.380628] CPU: 2 PID: 618 Comm: gdbus Tainted: G    B D         4.12.0-rc6-next-20170620 #105
[   37.385197] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
[   37.389953] Call Trace:
[   37.391518]  dump_stack+0x86/0xcf
[   37.393557]  __schedule_bug+0x65/0x90
[   37.396119]  __schedule+0x79b/0x990
[   37.398128]  ? vprintk_func+0x27/0x60
[   37.400139]  schedule+0x3d/0x90
[   37.401956]  do_exit+0xa57/0xda0
[   37.404127]  rewind_stack_do_exit+0x17/0x20
[   37.406368] RIP: 0033:0x7fab9e5eae2d
[   37.408375] RSP: 002b:00007fab97ffed20 EFLAGS: 00000293 ORIG_RAX: 0000000000000007
[   37.411956] RAX: fffffffffffffdfc RBX: 0000556a49e04540 RCX: 00007fab9e5eae2d
[   37.415603] RDX: 00000000ffffffff RSI: 0000000000000002 RDI: 00007fab900010c0
[   37.419076] RBP: 0000000000000002 R08: 0000000000000002 R09: 0000000000000000
[   37.422621] R10: 0000000000000001 R11: 0000000000000293 R12: 00007fab900010c0
[   37.426042] R13: 00000000ffffffff R14: 00007fab9ed318b0 R15: 0000000000000002



[  OK  ] Stopped firewalld - dynamic firewall daemon.
[  113.764020] BUG: Bad page state in process runaway-killer-  pfn:121801
         Stopping D-Bus System Message Bus...
[  113.769256] page:ffffc0ce44860040 count:0 mapcount:1 mapping:dead000000000000 index:0x7f0004c01 compound_mapcount: 1
[  113.769260] flags: 0x2fffff80000000()
[  113.769264] raw: 002fffff80000000 dead000000000000 0000000000000000 00000000ffffffff
[  113.769266] raw: ffffc0ce44860001 0000000900000003 0000000000000000 0000000000000000
[  113.769267] page dumped because: nonzero compound_mapcount
[  113.769267] Modules linked in: ip_set nfnetlink bridge stp llc coretemp ppdev vmw_balloon pcspkr sg parport_pc vmw_vmci i2c_piix4 parport shpchp xfs libcrc32c sr_mod cdrom ata_generic sd_mod pata_acpi vmwgfx mptspi serio_raw drm_kms_helper syscopyarea sysfillrect scsi_transport_spi sysimgblt fb_sys_fops ttm ahci libahci mptscsih e1000 ata_piix drm i2c_core libata mptbase [last unloaded: ip_tables]
[  113.769316] CPU: 3 PID: 584 Comm: runaway-killer- Tainted: G    B D W       4.12.0-rc6-next-20170620 #105
[  113.769318] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
[  113.769319] Call Trace:
[  113.769326]  dump_stack+0x86/0xcf
[  113.769331]  bad_page+0xc1/0x120
[  113.769335]  __free_pages_ok+0x40c/0x5f0
[  113.769340]  free_compound_page+0x1b/0x20
[  113.769343]  free_transhuge_page+0xa4/0xb0
[  113.769348]  ? get_futex_key+0x122/0x730
[  113.769351]  __put_compound_page+0x30/0x50
[  113.769353]  __put_page+0x22/0x40
[  113.769356]  get_futex_key+0x2fa/0x730
[  113.769362]  futex_wake+0x6a/0x170
[  113.769365]  ? trace_hardirqs_on+0xd/0x10
[  113.769371]  do_futex+0x2a8/0x560
[  113.769373]  ? lock_acquire+0xfb/0x200
[  113.769378]  ? __might_fault+0x3e/0x90
[  113.769385]  SyS_futex+0x83/0x190
[  113.769394]  mm_release+0x113/0x160
[  113.769398]  do_exit+0x150/0xda0
[  113.769402]  ? get_signal+0xc7/0x910
[  113.769406]  do_group_exit+0x50/0xd0
[  113.769411]  get_signal+0x2e4/0x910
[  113.769420]  do_signal+0x37/0x6b0
[  113.769424]  ? trace_hardirqs_on_caller+0xf5/0x190
[  113.769426]  ? trace_hardirqs_on+0xd/0x10
[  113.769431]  ? getnstimeofday64+0xe/0x20
[  113.769433]  ? kfree+0x1fc/0x2e0
[  113.769438]  ? __audit_syscall_exit+0x220/0x2c0
[  113.769443]  exit_to_usermode_loop+0x69/0xa0
[  113.769446]  do_syscall_64+0x167/0x1c0
[  113.769451]  entry_SYSCALL64_slow_path+0x25/0x25
[  113.769454] RIP: 0033:0x7f000a807e2d
[  113.769455] RSP: 002b:00007f0004dfed10 EFLAGS: 00000293 ORIG_RAX: 0000000000000007
[  113.769458] RAX: fffffffffffffdfc RBX: 00007efff40008c0 RCX: 00007f000a807e2d
[  113.769459] RDX: 00000000ffffffff RSI: 0000000000000001 RDI: 00007efff4001220
[  113.769461] RBP: 0000000000000001 R08: 0000000000000001 R09: 0000000000000000
[  113.769462] R10: 0000000000000001 R11: 0000000000000293 R12: 00007efff4001220
[  113.769463] R13: 00000000ffffffff R14: 00007f000b55f8b0 R15: 0000000000000001
[  113.769591] page:ffffc0ce44860000 count:0 mapcount:-1 mapping:          (null) index:0x7f0004c00 compound_mapcount: 0
[  113.769595] flags: 0x2fffff80048008(uptodate|head|swapbacked)
[  113.769598] raw: 002fffff80048008 0000000000000000 00000007f0004c00 00000000fffffffe
[  113.769599] raw: ffffc0ce44860020 ffffc0ce44860020 0000000000000000 0000000000000000
[  113.769600] page dumped because: VM_BUG_ON_PAGE(page_mapcount(page) < 0)
[  113.769614] ------------[ cut here ]------------
[  113.769615] kernel BUG at mm/huge_memory.c:1646!
[  113.769618] invalid opcode: 0000 [#2] SMP DEBUG_PAGEALLOC
[  113.769620] Modules linked in: ip_set nfnetlink bridge stp llc coretemp ppdev vmw_balloon pcspkr sg parport_pc vmw_vmci i2c_piix4 parport shpchp xfs libcrc32c sr_mod cdrom ata_generic sd_mod pata_acpi vmwgfx mptspi serio_raw drm_kms_helper syscopyarea sysfillrect scsi_transport_spi sysimgblt fb_sys_fops ttm ahci libahci mptscsih e1000 ata_piix drm i2c_core libata mptbase [last unloaded: ip_tables]
[  113.769658] CPU: 3 PID: 584 Comm: runaway-killer- Tainted: G    B D W       4.12.0-rc6-next-20170620 #105
[  113.769659] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
[  113.769660] task: ffff8d10e5ec4a40 task.stack: ffff9ab783864000
[  113.769663] RIP: 0010:zap_huge_pmd+0x28c/0x2a0
[  113.769665] RSP: 0018:ffff9ab783867a30 EFLAGS: 00010246
[  113.769667] RAX: 000000000000003c RBX: ffffc0ce44860000 RCX: 0000000000000000
[  113.769668] RDX: 0000000000000000 RSI: 0000000000000000 RDI: 0000000000000292
[  113.769669] RBP: ffff9ab783867a60 R08: 0000000000000000 R09: 0000000000000001
[  113.769670] R10: ffff9ab783867968 R11: 0000000000000000 R12: ffff8d10ec3d4cc8
[  113.769671] R13: ffff8d10e96aa130 R14: ffff9ab783867bd8 R15: 00003fffffe00000
[  113.769673] FS:  0000000000000000(0000) GS:ffff8d10f3400000(0000) knlGS:0000000000000000
[  113.769674] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  113.769676] CR2: 00007fcaf3489298 CR3: 000000012dbde000 CR4: 00000000001406e0
[  113.769718] Call Trace:
[  113.769724]  unmap_page_range+0x8d7/0x970
[  113.769735]  unmap_single_vma+0x59/0xe0
[  113.769738]  ? __slab_free+0xa4/0x280
[  113.769742]  unmap_vmas+0x37/0x50
[  113.769746]  exit_mmap+0x97/0x150
[  113.769756]  mmput+0x71/0x160
[  113.769760]  do_exit+0x2cf/0xda0
[  113.769764]  ? get_signal+0xc7/0x910
[  113.769769]  do_group_exit+0x50/0xd0
[  113.769773]  get_signal+0x2e4/0x910
[  113.769781]  do_signal+0x37/0x6b0
[  113.769785]  ? trace_hardirqs_on_caller+0xf5/0x190
[  113.769787]  ? trace_hardirqs_on+0xd/0x10
[  113.769792]  ? getnstimeofday64+0xe/0x20
[  113.769794]  ? kfree+0x1fc/0x2e0
[  113.769799]  ? __audit_syscall_exit+0x220/0x2c0
[  113.769805]  exit_to_usermode_loop+0x69/0xa0
[  113.769809]  do_syscall_64+0x167/0x1c0
[  113.769813]  entry_SYSCALL64_slow_path+0x25/0x25
[  113.769815] RIP: 0033:0x7f000a807e2d
[  113.769816] RSP: 002b:00007f0004dfed10 EFLAGS: 00000293 ORIG_RAX: 0000000000000007
[  113.769818] RAX: fffffffffffffdfc RBX: 00007efff40008c0 RCX: 00007f000a807e2d
[  113.769819] RDX: 00000000ffffffff RSI: 0000000000000001 RDI: 00007efff4001220
[  113.769820] RBP: 0000000000000001 R08: 0000000000000001 R09: 0000000000000000
[  113.769821] R10: 0000000000000001 R11: 0000000000000293 R12: 00007efff4001220
[  113.769822] R13: 00000000ffffffff R14: 00007f000b55f8b0 R15: 0000000000000001
[  113.769829] Code: 00 00 00 fe ff ff e9 cd fe ff ff 48 c7 c6 a0 14 c4 90 48 89 df e8 65 2f fb ff 0f 0b 48 c7 c6 60 53 c4 90 48 89 df e8 54 2f fb ff <0f> 0b 48 c7 c6 98 05 c4 90 48 89 df e8 43 2f fb ff 0f 0b 90 0f
[  113.769877] RIP: zap_huge_pmd+0x28c/0x2a0 RSP: ffff9ab783867a30
[  113.769880] ---[ end trace 35bcf1187115bba2 ]---
[  113.769882] Fixing recursive fault but reboot is needed!
[  113.769883] BUG: scheduling while atomic: runaway-killer-/584/0x00000002
[  113.769884] INFO: lockdep is turned off.
[  113.769885] Modules linked in: ip_set nfnetlink bridge stp llc coretemp ppdev vmw_balloon pcspkr sg parport_pc vmw_vmci i2c_piix4 parport shpchp xfs libcrc32c sr_mod cdrom ata_generic sd_mod pata_acpi vmwgfx mptspi serio_raw drm_kms_helper syscopyarea sysfillrect scsi_transport_spi sysimgblt fb_sys_fops ttm ahci libahci mptscsih e1000 ata_piix drm i2c_core libata mptbase [last unloaded: ip_tables]
[  113.769916] CPU: 3 PID: 584 Comm: runaway-killer- Tainted: G    B D W       4.12.0-rc6-next-20170620 #105
[  113.769918] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 07/31/2013
[  113.769918] Call Trace:
[  113.769922]  dump_stack+0x86/0xcf
[  113.769926]  __schedule_bug+0x65/0x90
[  113.769929]  __schedule+0x79b/0x990
[  113.769932]  ? vprintk_func+0x27/0x60
[  113.769938]  schedule+0x3d/0x90
[  113.769942]  do_exit+0xa57/0xda0
[  113.769948]  rewind_stack_do_exit+0x17/0x20
[  113.769949] RIP: 0033:0x7f000a807e2d
[  113.769950] RSP: 002b:00007f0004dfed10 EFLAGS: 00000293 ORIG_RAX: 0000000000000007
[  113.769952] RAX: fffffffffffffdfc RBX: 00007efff40008c0 RCX: 00007f000a807e2d
[  113.769953] RDX: 00000000ffffffff RSI: 0000000000000001 RDI: 00007efff4001220
[  113.769954] RBP: 0000000000000001 R08: 0000000000000001 R09: 0000000000000000
[  113.769955] R10: 0000000000000001 R11: 0000000000000293 R12: 00007efff4001220
[  113.769956] R13: 00000000ffffffff R14: 00007f000b55f8b0 R15: 0000000000000001
         Stopping Authorization Manager...
