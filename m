Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 1466A6B0036
	for <linux-mm@kvack.org>; Thu, 29 Aug 2013 23:36:51 -0400 (EDT)
Date: Thu, 29 Aug 2013 23:36:36 -0400 (EDT)
From: Zhouping Liu <zliu@redhat.com>
Message-ID: <566312294.6919147.1377833796685.JavaMail.root@redhat.com>
In-Reply-To: <55340856.6916553.1377832984360.JavaMail.root@redhat.com>
Subject: BUG: soft lockup - CPU#25 stuck for 23s! [memcg_process_s:5859]
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>
Cc: lizefan@huawei.com, Qian CAI <caiqian@redhat.com>, madper <cxie@redhat.com>

Hello All,

I hit the following errors when running memcg_stress_test.sh comes from LTP test suite on v3.11-rc7+:

------------------------ snip -----------------------------
[ 2163.674483] BUG: soft lockup - CPU#25 stuck for 23s! [memcg_process_s:5859]
[ 2163.674489] Modules linked in: xt_CHECKSUM tun bridge stp llc ebtable_nat nf_conntrack_netbios_ns nf_conntrack_broadcast ipt_MASQUERADE ip6table_nat nf_nat_ipv6 ip6table_mangle ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 iptable_nat nf_nat_ipv4 nf_nat iptable_mangle ipt_REJECT nf_conntrack_ipv4 nf_defrag_ipv4 xt_conntrack nf_conntrack ebtable_filter ebtables ip6table_filter ip6_tables iptable_filter ip_tables sg xfs libcrc32c netxen_nic amd64_edac_mod hpilo hpwdt edac_mce_amd sp5100_tco shpchp pcspkr edac_core serio_raw microcode i2c_piix4 acpi_power_meter k10temp acpi_cpufreq mperf radeon sd_mod i2c_algo_bit crc_t10dif drm_kms_helper ttm ata_generic drm pata_acpi ahci libahci pata_atiixp libata hpsa i2c_core dm_mirror dm_region_hash dm_log dm_mod
[ 2163.674531] CPU: 25 PID: 5859 Comm: memcg_process_s Not tainted 3.11.0-rc7+ #1
[ 2163.674531] Hardware name: HP ProLiant DL585 G7, BIOS A16 12/31/2011
[ 2163.674532] task: ffff884831c99fe0 ti: ffff88483358a000 task.ti: ffff88483358a000
[ 2163.674533] RIP: 0010:[<ffffffff810cd72e>]  [<ffffffff810cd72e>] smp_call_function_many+0x25e/0x2c0
[ 2163.674536] RSP: 0000:ffff88483358ba18  EFLAGS: 00000202
[ 2163.674537] RAX: 0000000000000008 RBX: 0000000000000282 RCX: ffff880237c98cb0
[ 2163.674538] RDX: 0000000000000008 RSI: 0000000000000030 RDI: 0000000000000000
[ 2163.674539] RBP: ffff88483358ba68 R08: ffff882cd089fe00 R09: ffff882cebc17540
[ 2163.674540] R10: ffffea0120ceb200 R11: ffffffff812fc0d9 R12: ffffffff81107cf0
[ 2163.674540] R13: ffff88483358b9b8 R14: 0000000000000206 R15: ffff884831391378
[ 2163.674542] FS:  00007ff5779ec740(0000) GS:ffff882cebc00000(0000) knlGS:0000000000000000
[ 2163.674542] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 2163.674543] CR2: 00007f763b3dc469 CR3: 00000017cd6a6000 CR4: 00000000000006e0
[ 2163.674544] Stack:
[ 2163.674544]  0000000100000000 0000000000015200 ffffffff8114b0b0 ffff88483bcd5200
[ 2163.674556]  0000000000000202 ffffffff81d6ca80 ffffffff8114b0b0 0000000000000000
[ 2163.674564]  0000000000000019 0000000000000001 ffff88483358ba98 ffffffff810cd87a
[ 2163.674571] Call Trace:
[ 2163.674573]  [<ffffffff8114b0b0>] ? drain_pages+0xb0/0xb0
[ 2163.674576]  [<ffffffff8114b0b0>] ? drain_pages+0xb0/0xb0
[ 2163.674580]  [<ffffffff810cd87a>] on_each_cpu_mask+0x2a/0x60
[ 2163.674583]  [<ffffffff81148475>] drain_all_pages+0xb5/0xc0
[ 2163.674587]  [<ffffffff8114c70e>] __alloc_pages_nodemask+0x70e/0xa00
[ 2163.674591]  [<ffffffff811868d9>] alloc_pages_current+0xa9/0x170
[ 2163.674595]  [<ffffffff811436f7>] __page_cache_alloc+0x87/0xb0
[ 2163.674598]  [<ffffffff81145755>] filemap_fault+0x185/0x400
[ 2163.674602]  [<ffffffff81167591>] __do_fault+0x71/0x4f0
[ 2163.674605]  [<ffffffff810a7b39>] ? load_balance+0x109/0x7e0
[ 2163.674608]  [<ffffffff8116a733>] handle_pte_fault+0x93/0xa40
[ 2163.674612]  [<ffffffff8116be81>] handle_mm_fault+0x291/0x660
[ 2163.674615]  [<ffffffff81610ee6>] __do_page_fault+0x146/0x510
[ 2163.674619]  [<ffffffff8160a582>] ? do_nanosleep+0x92/0x130
[ 2163.674623]  [<ffffffff8109109d>] ? hrtimer_nanosleep+0xad/0x170
[ 2163.674626]  [<ffffffff8108fee0>] ? hrtimer_get_res+0x50/0x50
[ 2163.674629]  [<ffffffff816112be>] do_page_fault+0xe/0x10
[ 2163.674633]  [<ffffffff8160d818>] page_fault+0x28/0x30
[ 2163.674635] Code: 48 94 00 89 c2 39 f0 0f 8d 2d fe ff ff 48 98 49 8b 4d 00 48 03 0c c5 40 62 a0 81 f6 41 20 01 74 cc 0f 1f 40 00 f3 90 f6 41 20 01 <75> f8 48 63 35 91 48 94 00 eb b7 0f b6 4d b4 48 8b 75 c0 4c 89 
[ 2163.710494] BUG: soft lockup - CPU#26 stuck for 23s! [memcg_process_s:5915]
[ 2163.710499] Modules linked in: xt_CHECKSUM tun bridge stp llc ebtable_nat nf_conntrack_netbios_ns nf_conntrack_broadcast ipt_MASQUERADE ip6table_nat nf_nat_ipv6 ip6table_mangle ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 iptable_nat nf_nat_ipv4 nf_nat iptable_mangle ipt_REJECT nf_conntrack_ipv4 nf_defrag_ipv4 xt_conntrack nf_conntrack ebtable_filter ebtables ip6table_filter ip6_tables iptable_filter ip_tables sg xfs libcrc32c netxen_nic amd64_edac_mod hpilo hpwdt edac_mce_amd sp5100_tco shpchp pcspkr edac_core serio_raw microcode i2c_piix4 acpi_power_meter k10temp acpi_cpufreq mperf radeon sd_mod i2c_algo_bit crc_t10dif drm_kms_helper ttm ata_generic drm pata_acpi ahci libahci pata_atiixp libata hpsa i2c_core dm_mirror dm_region_hash dm_log dm_mod
[ 2163.710543] CPU: 26 PID: 5915 Comm: memcg_process_s Not tainted 3.11.0-rc7+ #1
[ 2163.710543] Hardware name: HP ProLiant DL585 G7, BIOS A16 12/31/2011
[ 2163.710544] task: ffff884a2c42dfa0 ti: ffff884a2e7f0000 task.ti: ffff884a2e7f0000
[ 2163.710545] RIP: 0010:[<ffffffff810cd72e>]  [<ffffffff810cd72e>] smp_call_function_many+0x25e/0x2c0
[ 2163.710548] RSP: 0000:ffff884a2e7f1960  EFLAGS: 00000202
[ 2163.710549] RAX: 0000000000000008 RBX: ffff88470bd15210 RCX: ffff880237c98cd8
[ 2163.710550] RDX: 0000000000000008 RSI: 0000000000000030 RDI: 0000000000000000
[ 2163.710551] RBP: ffff884a2e7f19b0 R08: ffff8846f888fe00 R09: ffff88470bc17540
[ 2163.710552] R10: ffffea011bdd9e00 R11: ffffffff812fc0d9 R12: ffff884a2e7f1918
[ 2163.710552] R13: ffffffff81107cf0 R14: ffff884a2e7f1900 R15: 0000000000000202
[ 2163.710554] FS:  00007f0275b35740(0000) GS:ffff88470bc00000(0000) knlGS:0000000000000000
[ 2163.710554] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 2163.710555] CR2: 00007f6df18f169e CR3: 0000002ccee5d000 CR4: 00000000000006e0
[ 2163.710556] Stack:
[ 2163.710556]  0000000181a131e0 0000000000015200 ffffffff8114b0b0 ffff88470bd15200
[ 2163.710568]  0000000000000202 ffffffff81d6ca80 ffffffff8114b0b0 0000000000000000
[ 2163.710576]  000000000000001a 0000000000000001 ffff884a2e7f19e0 ffffffff810cd87a
[ 2163.710584] Call Trace:
[ 2163.710586]  [<ffffffff8114b0b0>] ? drain_pages+0xb0/0xb0
[ 2163.710589]  [<ffffffff8114b0b0>] ? drain_pages+0xb0/0xb0
[ 2163.710593]  [<ffffffff810cd87a>] on_each_cpu_mask+0x2a/0x60
[ 2163.710596]  [<ffffffff81148475>] drain_all_pages+0xb5/0xc0
[ 2163.710600]  [<ffffffff8114c70e>] __alloc_pages_nodemask+0x70e/0xa00
[ 2163.710603]  [<ffffffff811868d9>] alloc_pages_current+0xa9/0x170
[ 2163.710607]  [<ffffffff811436f7>] __page_cache_alloc+0x87/0xb0
[ 2163.710611]  [<ffffffff8114ea04>] __do_page_cache_readahead+0xf4/0x240
[ 2163.710615]  [<ffffffff81107cf0>] ? delayacct_end+0x80/0x90
[ 2163.710618]  [<ffffffff8114f1c1>] ra_submit+0x21/0x30
[ 2163.710622]  [<ffffffff8114590c>] filemap_fault+0x33c/0x400
[ 2163.710626]  [<ffffffff81167591>] __do_fault+0x71/0x4f0
[ 2163.710629]  [<ffffffff8116a733>] handle_pte_fault+0x93/0xa40
[ 2163.710633]  [<ffffffff8116be81>] handle_mm_fault+0x291/0x660
[ 2163.710636]  [<ffffffff81610ee6>] __do_page_fault+0x146/0x510
[ 2163.710640]  [<ffffffff810a23e5>] ? set_next_entity+0x95/0xb0
[ 2163.710643]  [<ffffffff81011621>] ? __switch_to+0x181/0x4b0
[ 2163.710647]  [<ffffffff8160afe8>] ? __schedule+0x3a8/0x7d0
[ 2163.710651]  [<ffffffff816112be>] do_page_fault+0xe/0x10
[ 2163.710654]  [<ffffffff8160d818>] page_fault+0x28/0x30
[ 2163.710657] Code: 48 94 00 89 c2 39 f0 0f 8d 2d fe ff ff 48 98 49 8b 4d 00 48 03 0c c5 40 62 a0 81 f6 41 20 01 74 cc 0f 1f 40 00 f3 90 f6 41 20 01 <75> f8 48 63 35 91 48 94 00 eb b7 0f b6 4d b4 48 8b 75 c0 4c 89 
[ 2163.723515] BUG: soft lockup - CPU#27 stuck for 23s! [systemd:1]
[ 2163.723516] Modules linked in: xt_CHECKSUM tun bridge stp llc ebtable_nat nf_conntrack_netbios_ns nf_conntrack_broadcast ipt_MASQUERADE ip6table_nat nf_nat_ipv6 ip6table_mangle ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 iptable_nat nf_nat_ipv4 nf_nat iptable_mangle ipt_REJECT nf_conntrack_ipv4 nf_defrag_ipv4 xt_conntrack nf_conntrack ebtable_filter ebtables ip6table_filter ip6_tables iptable_filter ip_tables sg xfs libcrc32c netxen_nic amd64_edac_mod hpilo hpwdt edac_mce_amd sp5100_tco shpchp pcspkr edac_core serio_raw microcode i2c_piix4 acpi_power_meter k10temp acpi_cpufreq mperf radeon sd_mod i2c_algo_bit crc_t10dif drm_kms_helper ttm ata_generic drm pata_acpi ahci libahci pata_atiixp libata hpsa i2c_core dm_mirror dm_region_hash dm_log dm_mod
[ 2163.723603] CPU: 27 PID: 1 Comm: systemd Not tainted 3.11.0-rc7+ #1
[ 2163.723605] Hardware name: HP ProLiant DL585 G7, BIOS A16 12/31/2011
[ 2163.723607] task: ffff88022f4d0000 ti: ffff88022f4d8000 task.ti: ffff88022f4d8000
[ 2163.723609] RIP: 0010:[<ffffffff810cd72e>]  [<ffffffff810cd72e>] smp_call_function_many+0x25e/0x2c0
[ 2163.723616] RSP: 0000:ffff88022f4d9960  EFLAGS: 00000202
[ 2163.723619] RAX: 0000000000000008 RBX: ffff88470bd55210 RCX: ffff880237c98d00
[ 2163.723620] RDX: 0000000000000008 RSI: 0000000000000030 RDI: 0000000000000000
[ 2163.723623] RBP: ffff88022f4d99b0 R08: ffff884834897e00 R09: ffff88483bc17540
[ 2163.723625] R10: ffffea0120cc5300 R11: ffffffff812fc0d9 R12: ffff88022f4d9918
[ 2163.723627] R13: ffffffff81107cf0 R14: ffff88022f4d9900 R15: 0000000000000206
[ 2163.723630] FS:  00007feb8ce09880(0000) GS:ffff88483bc00000(0000) knlGS:0000000000000000
[ 2163.723632] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 2163.723634] CR2: 0000000000400873 CR3: 00000017cf12f000 CR4: 00000000000006e0
[ 2163.723635] Stack:
[ 2163.723636]  0000000100000000 0000000000015200 ffffffff8114b0b0 ffff88470bd55200
[ 2163.723657]  0000000000000202 ffffffff81d6ca80 ffffffff8114b0b0 0000000000000000
[ 2163.723672]  000000000000001b 0000000000000001 ffff88022f4d99e0 ffffffff810cd87a
[ 2163.723688] Call Trace:
[ 2163.723691]  [<ffffffff8114b0b0>] ? drain_pages+0xb0/0xb0
[ 2163.723699]  [<ffffffff8114b0b0>] ? drain_pages+0xb0/0xb0
[ 2163.723706]  [<ffffffff810cd87a>] on_each_cpu_mask+0x2a/0x60
[ 2163.723714]  [<ffffffff81148475>] drain_all_pages+0xb5/0xc0
[ 2163.723722]  [<ffffffff8114c70e>] __alloc_pages_nodemask+0x70e/0xa00
[ 2163.723731]  [<ffffffff811868d9>] alloc_pages_current+0xa9/0x170
[ 2163.723739]  [<ffffffff811436f7>] __page_cache_alloc+0x87/0xb0
[ 2163.723747]  [<ffffffff8114ea04>] __do_page_cache_readahead+0xf4/0x240
[ 2163.723755]  [<ffffffff8108d9a0>] ? wake_atomic_t_function+0x40/0x40
[ 2163.723763]  [<ffffffff8114f1c1>] ra_submit+0x21/0x30
[ 2163.723770]  [<ffffffff8114590c>] filemap_fault+0x33c/0x400
[ 2163.723778]  [<ffffffff81167591>] __do_fault+0x71/0x4f0
[ 2163.723785]  [<ffffffff8116a733>] handle_pte_fault+0x93/0xa40
[ 2163.723793]  [<ffffffff810796b3>] ? __sigqueue_free.part.15+0x33/0x40
[ 2163.723799]  [<ffffffff81079dac>] ? __dequeue_signal+0x13c/0x220
[ 2163.723806]  [<ffffffff81079bcb>] ? recalc_sigpending+0x1b/0x50
[ 2163.723813]  [<ffffffff8116be81>] handle_mm_fault+0x291/0x660
[ 2163.723820]  [<ffffffff81610ee6>] __do_page_fault+0x146/0x510
[ 2163.723829]  [<ffffffff811ab217>] ? vfs_read+0xf7/0x170
[ 2163.723837]  [<ffffffff816112be>] do_page_fault+0xe/0x10
[ 2163.723845]  [<ffffffff8160d818>] page_fault+0x28/0x30
[ 2163.723850] Code: 48 94 00 89 c2 39 f0 0f 8d 2d fe ff ff 48 98 49 8b 4d 00 48 03 0c c5 40 62 a0 81 f6 41 20 01 74 cc 0f 1f 40 00 f3 90 f6 41 20 01 <75> f8 48 63 35 91 48 94 00 eb b7 0f b6 4d b4 48 8b 75 c0 4c 89 
[ 2163.779522] BUG: soft lockup - CPU#31 stuck for 23s! [memcg_process_s:5969]
[ 2163.779523] Modules linked in: xt_CHECKSUM tun bridge stp llc ebtable_nat nf_conntrack_netbios_ns nf_conntrack_broadcast ipt_MASQUERADE ip6table_nat nf_nat_ipv6 ip6table_mangle ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 iptable_nat nf_nat_ipv4 nf_nat iptable_mangle ipt_REJECT nf_conntrack_ipv4 nf_defrag_ipv4 xt_conntrack nf_conntrack ebtable_filter ebtables ip6table_filter ip6_tables iptable_filter ip_tables sg xfs libcrc32c netxen_nic amd64_edac_mod hpilo hpwdt edac_mce_amd sp5100_tco shpchp pcspkr edac_core serio_raw microcode i2c_piix4 acpi_power_meter k10temp acpi_cpufreq mperf radeon sd_mod i2c_algo_bit crc_t10dif drm_kms_helper ttm ata_generic drm pata_acpi ahci libahci pata_atiixp libata hpsa i2c_core dm_mirror dm_region_hash dm_log dm_mod
[ 2163.779564] CPU: 31 PID: 5969 Comm: memcg_process_s Not tainted 3.11.0-rc7+ #1
[ 2163.779565] Hardware name: HP ProLiant DL585 G7, BIOS A16 12/31/2011
[ 2163.779566] task: ffff88033432aa80 ti: ffff8803337da000 task.ti: ffff8803337da000
[ 2163.779566] RIP: 0010:[<ffffffff810cd72a>]  [<ffffffff810cd72a>] smp_call_function_many+0x25a/0x2c0
[ 2163.779569] RSP: 0000:ffff8803337db960  EFLAGS: 00000202
[ 2163.779570] RAX: 0000000000000008 RBX: ffff88470bc95210 RCX: ffff880237c98da0
[ 2163.779571] RDX: 0000000000000008 RSI: 0000000000000030 RDI: 0000000000000000
[ 2163.779572] RBP: ffff8803337db9b0 R08: ffff884834894200 R09: ffff88483bc57540
[ 2163.779573] R10: ffffea0120cc2000 R11: ffffffff812fc0d9 R12: ffff8803337db918
[ 2163.779574] R13: ffffffff81107cf0 R14: ffff8803337db900 R15: 0000000000000206
[ 2163.779575] FS:  00007f27a32ec740(0000) GS:ffff88483bc40000(0000) knlGS:0000000000000000
[ 2163.779576] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 2163.779576] CR2: 00007f0d65270000 CR3: 00000046f7206000 CR4: 00000000000006e0
[ 2163.779577] Stack:
[ 2163.779577]  0000000100000000 0000000000015200 ffffffff8114b0b0 ffff88470bc95200
[ 2163.779586]  0000000000000202 ffffffff81d6ca80 ffffffff8114b0b0 0000000000000000
[ 2163.779594]  000000000000001f 0000000000000001 ffff8803337db9e0 ffffffff810cd87a
[ 2163.779602] Call Trace:
[ 2163.779603]  [<ffffffff8114b0b0>] ? drain_pages+0xb0/0xb0
[ 2163.779607]  [<ffffffff8114b0b0>] ? drain_pages+0xb0/0xb0
[ 2163.779610]  [<ffffffff810cd87a>] on_each_cpu_mask+0x2a/0x60
[ 2163.779614]  [<ffffffff81148475>] drain_all_pages+0xb5/0xc0
[ 2163.779617]  [<ffffffff8114c70e>] __alloc_pages_nodemask+0x70e/0xa00
[ 2163.779621]  [<ffffffff811868d9>] alloc_pages_current+0xa9/0x170
[ 2163.779625]  [<ffffffff811436f7>] __page_cache_alloc+0x87/0xb0
[ 2163.779629]  [<ffffffff8114ea04>] __do_page_cache_readahead+0xf4/0x240
[ 2163.779632]  [<ffffffff8114f1c1>] ra_submit+0x21/0x30
[ 2163.779635]  [<ffffffff8114590c>] filemap_fault+0x33c/0x400
[ 2163.779639]  [<ffffffff81167591>] __do_fault+0x71/0x4f0
[ 2163.779642]  [<ffffffff8116a733>] handle_pte_fault+0x93/0xa40
[ 2163.779646]  [<ffffffff8116be81>] handle_mm_fault+0x291/0x660
[ 2163.779649]  [<ffffffff81610ee6>] __do_page_fault+0x146/0x510
[ 2163.779653]  [<ffffffff810a23e5>] ? set_next_entity+0x95/0xb0
[ 2163.779656]  [<ffffffff81011621>] ? __switch_to+0x181/0x4b0
[ 2163.779659]  [<ffffffff8160afe8>] ? __schedule+0x3a8/0x7d0
[ 2163.779664]  [<ffffffff816112be>] do_page_fault+0xe/0x10
[ 2163.779668]  [<ffffffff8160d818>] page_fault+0x28/0x30
[ 2163.779670] Code: 48 63 35 c2 48 94 00 89 c2 39 f0 0f 8d 2d fe ff ff 48 98 49 8b 4d 00 48 03 0c c5 40 62 a0 81 f6 41 20 01 74 cc 0f 1f 40 00 f3 90 <f6> 41 20 01 75 f8 48 63 35 91 48 94 00 eb b7 0f b6 4d b4 48 8b 
[ 2167.061460] BUG: soft lockup - CPU#0 stuck for 23s! [memcg_process_s:5891]
[ 2167.061461] Modules linked in: xt_CHECKSUM tun bridge stp llc ebtable_nat nf_conntrack_netbios_ns nf_conntrack_broadcast ipt_MASQUERADE ip6table_nat nf_nat_ipv6 ip6table_mangle ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 iptable_nat nf_nat_ipv4 nf_nat iptable_mangle ipt_REJECT nf_conntrack_ipv4 nf_defrag_ipv4 xt_conntrack nf_conntrack ebtable_filter ebtables ip6table_filter ip6_tables iptable_filter ip_tables sg xfs libcrc32c netxen_nic amd64_edac_mod hpilo hpwdt edac_mce_amd sp5100_tco shpchp pcspkr edac_core serio_raw microcode i2c_piix4 acpi_power_meter k10temp acpi_cpufreq mperf radeon sd_mod i2c_algo_bit crc_t10dif drm_kms_helper ttm ata_generic drm pata_acpi ahci libahci pata_atiixp libata hpsa i2c_core dm_mirror dm_region_hash dm_log dm_mod
[ 2167.061501] CPU: 0 PID: 5891 Comm: memcg_process_s Not tainted 3.11.0-rc7+ #1
[ 2167.061501] Hardware name: HP ProLiant DL585 G7, BIOS A16 12/31/2011
[ 2167.061503] task: ffff884831c98000 ti: ffff884833f1c000 task.ti: ffff884833f1c000
[ 2167.061503] RIP: 0010:[<ffffffff810cd72a>]  [<ffffffff810cd72a>] smp_call_function_many+0x25a/0x2c0
[ 2167.061506] RSP: 0000:ffff884833f1d960  EFLAGS: 00000202
[ 2167.061507] RAX: 0000000000000008 RBX: ffff882cebc55210 RCX: ffff880237c979a8
[ 2167.061507] RDX: 0000000000000008 RSI: 0000000000000030 RDI: 0000000000000000
[ 2167.061508] RBP: ffff884833f1d9b0 R08: ffff88023782aa00 R09: ffff880237c17540
[ 2167.061509] R10: ffffea0008adbb00 R11: ffffffff812fc0d9 R12: ffff884833f1d918
[ 2167.061510] R13: ffffffff81107cf0 R14: ffff884833f1d900 R15: 0000000000000206
[ 2167.061511] FS:  00007fcb5e383740(0000) GS:ffff880237c00000(0000) knlGS:0000000000000000
[ 2167.061512] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 2167.061513] CR2: 00007fbc8cce3000 CR3: 00000017cfa5c000 CR4: 00000000000006f0
[ 2167.061513] Stack:
[ 2167.061513]  0000000100000000 0000000000015200 ffffffff8114b0b0 ffff882cebc55200
[ 2167.061524]  0000000000000202 ffffffff81d6ca80 ffffffff8114b0b0 0000000000000000
[ 2167.061532]  0000000000000000 0000000000000001 ffff884833f1d9e0 ffffffff810cd87a
[ 2167.061540] Call Trace:
[ 2167.061542]  [<ffffffff8114b0b0>] ? drain_pages+0xb0/0xb0
[ 2167.061545]  [<ffffffff8114b0b0>] ? drain_pages+0xb0/0xb0
[ 2167.061549]  [<ffffffff810cd87a>] on_each_cpu_mask+0x2a/0x60
[ 2167.061552]  [<ffffffff81148475>] drain_all_pages+0xb5/0xc0
[ 2167.061556]  [<ffffffff8114c70e>] __alloc_pages_nodemask+0x70e/0xa00
[ 2167.061560]  [<ffffffff811868d9>] alloc_pages_current+0xa9/0x170
[ 2167.061564]  [<ffffffff811436f7>] __page_cache_alloc+0x87/0xb0
[ 2167.061567]  [<ffffffff8114ea04>] __do_page_cache_readahead+0xf4/0x240
[ 2167.061571]  [<ffffffff8114f1c1>] ra_submit+0x21/0x30
[ 2167.061575]  [<ffffffff8114590c>] filemap_fault+0x33c/0x400
[ 2167.061578]  [<ffffffff81167591>] __do_fault+0x71/0x4f0
[ 2167.061582]  [<ffffffff8116a733>] handle_pte_fault+0x93/0xa40
[ 2167.061585]  [<ffffffff81173855>] ? change_protection_range+0x665/0x6f0
[ 2167.061589]  [<ffffffff8116be81>] handle_mm_fault+0x291/0x660
[ 2167.061592]  [<ffffffff81610ee6>] __do_page_fault+0x146/0x510
[ 2167.061596]  [<ffffffff81173945>] ? change_protection+0x65/0xb0
[ 2167.061599]  [<ffffffff811881cb>] ? change_prot_numa+0x1b/0x40
[ 2167.061603]  [<ffffffff810a1127>] ? task_numa_work+0x247/0x2e0
[ 2167.061606]  [<ffffffff8108974c>] ? task_work_run+0xac/0xe0
[ 2167.061610]  [<ffffffff816112be>] do_page_fault+0xe/0x10
[ 2167.061613]  [<ffffffff8160d818>] page_fault+0x28/0x30
[ 2167.061615] Code: 48 63 35 c2 48 94 00 89 c2 39 f0 0f 8d 2d fe ff ff 48 98 49 8b 4d 00 48 03 0c c5 40 62 a0 81 f6 41 20 01 74 cc 0f 1f 40 00 f3 90 <f6> 41 20 01 75 f8 48 63 35 91 48 94 00 eb b7 0f b6 4d b4 48 8b 
[ 2167.282517] BUG: soft lockup - CPU#3 stuck for 22s! [memcg_process_s:5993]
[ 2167.282518] Modules linked in: xt_CHECKSUM tun bridge stp llc ebtable_nat nf_conntrack_netbios_ns nf_conntrack_broadcast ipt_MASQUERADE ip6table_nat nf_nat_ipv6 ip6table_mangle ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 iptable_nat nf_nat_ipv4 nf_nat iptable_mangle ipt_REJECT nf_conntrack_ipv4 nf_defrag_ipv4 xt_conntrack nf_conntrack ebtable_filter ebtables ip6table_filter ip6_tables iptable_filter ip_tables sg xfs libcrc32c netxen_nic amd64_edac_mod hpilo hpwdt edac_mce_amd sp5100_tco shpchp pcspkr edac_core serio_raw microcode i2c_piix4 acpi_power_meter k10temp acpi_cpufreq mperf radeon sd_mod i2c_algo_bit crc_t10dif drm_kms_helper ttm ata_generic drm pata_acpi ahci libahci pata_atiixp libata hpsa i2c_core dm_mirror dm_region_hash dm_log dm_mod
[ 2167.282566] CPU: 3 PID: 5993 Comm: memcg_process_s Not tainted 3.11.0-rc7+ #1
[ 2167.282567] Hardware name: HP ProLiant DL585 G7, BIOS A16 12/31/2011
[ 2167.282568] task: ffff8817cf2474e0 ti: ffff8817cb2c2000 task.ti: ffff8817cb2c2000
[ 2167.282569] RIP: 0010:[<ffffffff810cd72a>]  [<ffffffff810cd72a>] smp_call_function_many+0x25a/0x2c0
[ 2167.282572] RSP: 0000:ffff8817cb2c3960  EFLAGS: 00000202
[ 2167.282573] RAX: 0000000000000008 RBX: ffff8817ebd55210 RCX: ffff880237c98940
[ 2167.282574] RDX: 0000000000000008 RSI: 0000000000000030 RDI: 0000000000000000
[ 2167.282575] RBP: ffff8817cb2c39b0 R08: ffff884a2f4b8000 R09: ffff884a3fa17540
[ 2167.282576] R10: ffffea0128b94300 R11: ffffffff812fc0d9 R12: ffff8817cb2c3918
[ 2167.282577] R13: ffffffff81107cf0 R14: ffff8817cb2c3900 R15: 0000000000000202
[ 2167.282578] FS:  00007f7904f75740(0000) GS:ffff884a3fa00000(0000) knlGS:0000000000000000
[ 2167.282579] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 2167.282580] CR2: 00007f2d04d17000 CR3: 0000004a2e758000 CR4: 00000000000006e0
[ 2167.282581] Stack:
[ 2167.282581]  0000000100000000 0000000000015200 ffffffff8114b0b0 ffff8817ebd55200
[ 2167.282591]  0000000000000202 ffffffff81d6ca80 ffffffff8114b0b0 0000000000000000
[ 2167.282598]  0000000000000003 0000000000000001 ffff8817cb2c39e0 ffffffff810cd87a
[ 2167.282606] Call Trace:
[ 2167.282608]  [<ffffffff8114b0b0>] ? drain_pages+0xb0/0xb0
[ 2167.282611]  [<ffffffff8114b0b0>] ? drain_pages+0xb0/0xb0
[ 2167.282614]  [<ffffffff810cd87a>] on_each_cpu_mask+0x2a/0x60
[ 2167.282618]  [<ffffffff81148475>] drain_all_pages+0xb5/0xc0
[ 2167.282621]  [<ffffffff8114c70e>] __alloc_pages_nodemask+0x70e/0xa00
[ 2167.282625]  [<ffffffff811868d9>] alloc_pages_current+0xa9/0x170
[ 2167.282629]  [<ffffffff811436f7>] __page_cache_alloc+0x87/0xb0
[ 2167.282632]  [<ffffffff8114ea04>] __do_page_cache_readahead+0xf4/0x240
[ 2167.282636]  [<ffffffff8108d9a0>] ? wake_atomic_t_function+0x40/0x40
[ 2167.282639]  [<ffffffff8114f1c1>] ra_submit+0x21/0x30
[ 2167.282642]  [<ffffffff8114590c>] filemap_fault+0x33c/0x400
[ 2167.282646]  [<ffffffff81167591>] __do_fault+0x71/0x4f0
[ 2167.282649]  [<ffffffff8116a733>] handle_pte_fault+0x93/0xa40
[ 2167.282652]  [<ffffffff8116be81>] handle_mm_fault+0x291/0x660
[ 2167.282656]  [<ffffffff81610ee6>] __do_page_fault+0x146/0x510
[ 2167.282659]  [<ffffffff810a23e5>] ? set_next_entity+0x95/0xb0
[ 2167.282662]  [<ffffffff81011621>] ? __switch_to+0x181/0x4b0
[ 2167.282666]  [<ffffffff81079bcb>] ? recalc_sigpending+0x1b/0x50
[ 2167.282669]  [<ffffffff8107a6f2>] ? __set_task_blocked+0x32/0x70
[ 2167.282672]  [<ffffffff816112be>] do_page_fault+0xe/0x10
[ 2167.282675]  [<ffffffff8160d818>] page_fault+0x28/0x30
[ 2167.282678] Code: 48 63 35 c2 48 94 00 89 c2 39 f0 0f 8d 2d fe ff ff 48 98 49 8b 4d 00 48 03 0c c5 40 62 a0 81 f6 41 20 01 74 cc 0f 1f 40 00 f3 90 <f6> 41 20 01 75 f8 48 63 35 91 48 94 00 eb b7 0f b6 4d b4 48 8b 
[ 2167.296528] BUG: soft lockup - CPU#4 stuck for 22s! [memcg_process_s:5819]
[ 2167.296528] Modules linked in: xt_CHECKSUM tun bridge stp llc ebtable_nat nf_conntrack_netbios_ns nf_conntrack_broadcast ipt_MASQUERADE ip6table_nat nf_nat_ipv6 ip6table_mangle ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 iptable_nat nf_nat_ipv4 nf_nat iptable_mangle ipt_REJECT nf_conntrack_ipv4 nf_defrag_ipv4 xt_conntrack nf_conntrack ebtable_filter ebtables ip6table_filter ip6_tables iptable_filter ip_tables sg xfs libcrc32c netxen_nic amd64_edac_mod hpilo hpwdt edac_mce_amd sp5100_tco shpchp pcspkr edac_core serio_raw microcode i2c_piix4 acpi_power_meter k10temp acpi_cpufreq mperf radeon sd_mod i2c_algo_bit crc_t10dif drm_kms_helper ttm ata_generic drm pata_acpi ahci libahci pata_atiixp libata hpsa i2c_core dm_mirror dm_region_hash dm_log dm_mod
[ 2167.296569] CPU: 4 PID: 5819 Comm: memcg_process_s Not tainted 3.11.0-rc7+ #1
[ 2167.296570] Hardware name: HP ProLiant DL585 G7, BIOS A16 12/31/2011
[ 2167.296571] task: ffff880333e68aa0 ti: ffff8803341d0000 task.ti: ffff8803341d0000
[ 2167.296572] RIP: 0010:[<ffffffff810cd72a>]  [<ffffffff810cd72a>] smp_call_function_many+0x25a/0x2c0
[ 2167.296575] RSP: 0000:ffff8803341d1a18  EFLAGS: 00000202
[ 2167.296576] RAX: 0000000000000008 RBX: 0000000000000282 RCX: ffff880237c98968
[ 2167.296577] RDX: 0000000000000008 RSI: 0000000000000030 RDI: 0000000000000000
[ 2167.296577] RBP: ffff8803341d1a68 R08: ffff88022f4f3e00 R09: ffff880237c57540
[ 2167.296578] R10: ffffea0008b39b00 R11: ffffffff812fc0d9 R12: ffffffff81107cf0
[ 2167.296579] R13: ffff8803341d19b8 R14: 0000000000000202 R15: ffff8817cd73e848
[ 2167.296580] FS:  00007f1e30f6a740(0000) GS:ffff880237c40000(0000) knlGS:0000000000000000
[ 2167.296581] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 2167.296582] CR2: 00007f9a99796000 CR3: 00000046f5066000 CR4: 00000000000006e0
[ 2167.296582] Stack:
[ 2167.296583]  0000000100000000 0000000000015200 ffffffff8114b0b0 ffff880237c95200
[ 2167.296593]  0000000000000202 ffffffff81d6ca80 ffffffff8114b0b0 0000000000000000
[ 2167.296601]  0000000000000004 0000000000000001 ffff8803341d1a98 ffffffff810cd87a
[ 2167.296609] Call Trace:
[ 2167.296611]  [<ffffffff8114b0b0>] ? drain_pages+0xb0/0xb0
[ 2167.296614]  [<ffffffff8114b0b0>] ? drain_pages+0xb0/0xb0
[ 2167.296617]  [<ffffffff810cd87a>] on_each_cpu_mask+0x2a/0x60
[ 2167.296621]  [<ffffffff81148475>] drain_all_pages+0xb5/0xc0
[ 2167.296624]  [<ffffffff8114c70e>] __alloc_pages_nodemask+0x70e/0xa00
[ 2167.296628]  [<ffffffff811868d9>] alloc_pages_current+0xa9/0x170
[ 2167.296632]  [<ffffffff811436f7>] __page_cache_alloc+0x87/0xb0
[ 2167.296636]  [<ffffffff81145755>] filemap_fault+0x185/0x400
[ 2167.296640]  [<ffffffff811a0667>] ? __mem_cgroup_uncharge_common+0x47/0x310
[ 2167.296643]  [<ffffffff81167591>] __do_fault+0x71/0x4f0
[ 2167.296647]  [<ffffffff81180efb>] ? __frontswap_invalidate_page+0x2b/0x70
[ 2167.296650]  [<ffffffff8116a733>] handle_pte_fault+0x93/0xa40
[ 2167.296654]  [<ffffffff8116be81>] handle_mm_fault+0x291/0x660
[ 2167.296657]  [<ffffffff81610ee6>] __do_page_fault+0x146/0x510
[ 2167.296661]  [<ffffffff8160a582>] ? do_nanosleep+0x92/0x130
[ 2167.296665]  [<ffffffff8109109d>] ? hrtimer_nanosleep+0xad/0x170
[ 2167.296668]  [<ffffffff8108fee0>] ? hrtimer_get_res+0x50/0x50
[ 2167.296672]  [<ffffffff816112be>] do_page_fault+0xe/0x10
[ 2167.296675]  [<ffffffff8160d818>] page_fault+0x28/0x30
[ 2167.296677] Code: 48 63 35 c2 48 94 00 89 c2 39 f0 0f 8d 2d fe ff ff 48 98 49 8b 4d 00 48 03 0c c5 40 62 a0 81 f6 41 20 01 74 cc 0f 1f 40 00 f3 90 <f6> 41 20 01 75 f8 48 63 35 91 48 94 00 eb b7 0f b6 4d b4 48 8b 
[ 2167.331531] BUG: soft lockup - CPU#5 stuck for 24s! [memcg_process_s:5823]
[ 2167.331537] Modules linked in: xt_CHECKSUM tun bridge stp llc ebtable_nat nf_conntrack_netbios_ns nf_conntrack_broadcast ipt_MASQUERADE ip6table_nat nf_nat_ipv6 ip6table_mangle ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 iptable_nat nf_nat_ipv4 nf_nat iptable_mangle ipt_REJECT nf_conntrack_ipv4 nf_defrag_ipv4 xt_conntrack nf_conntrack ebtable_filter ebtables ip6table_filter ip6_tables iptable_filter ip_tables sg xfs libcrc32c netxen_nic amd64_edac_mod hpilo hpwdt edac_mce_amd sp5100_tco shpchp pcspkr edac_core serio_raw microcode i2c_piix4 acpi_power_meter k10temp acpi_cpufreq mperf radeon sd_mod i2c_algo_bit crc_t10dif drm_kms_helper ttm ata_generic drm pata_acpi ahci libahci pata_atiixp libata hpsa i2c_core dm_mirror dm_region_hash dm_log dm_mod
[ 2167.331577] CPU: 5 PID: 5823 Comm: memcg_process_s Not tainted 3.11.0-rc7+ #1
[ 2167.331578] Hardware name: HP ProLiant DL585 G7, BIOS A16 12/31/2011
[ 2167.331579] task: ffff8839f7070000 ti: ffff8839f7f4e000 task.ti: ffff8839f7f4e000
[ 2167.331580] RIP: 0010:[<ffffffff810cd22a>]  [<ffffffff810cd22a>] generic_exec_single+0x7a/0xa0
[ 2167.331583] RSP: 0000:ffff8839f7f4f8a8  EFLAGS: 00000202
[ 2167.331584] RAX: 0000000000000286 RBX: ffffffff811adb59 RCX: 0000000000003d9f
[ 2167.331584] RDX: ffff880237c95200 RSI: 0000000000000286 RDI: 0000000000000286
[ 2167.331585] RBP: ffff8839f7f4f8e0 R08: ffff880237c95200 R09: 0000000000000001
[ 2167.331586] R10: 0000000000001f00 R11: 0000000000000000 R12: ffff8839f7f4f830
[ 2167.331587] R13: ffff884a2f4ffbb0 R14: ffffffffa0a6269f R15: ffff8839f7f4f820
[ 2167.331588] FS:  00007f1682c9c740(0000) GS:ffff8817ebc40000(0000) knlGS:0000000000000000
[ 2167.331589] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 2167.331590] CR2: 00000000004008c2 CR3: 0000000330daa000 CR4: 00000000000006e0
[ 2167.331590] Stack:
[ 2167.331591]  0000000000000286 ffff880237c98af8 0000000000000008 0000000000000005
[ 2167.331602]  ffffffff81a10b00 ffffffff8114b0b0 ffffffff81d6ca80 ffff8839f7f4f950
[ 2167.331609]  ffffffff810cd335 0000000000000000 ffff88183ffdaba8 ffff880237c98968
[ 2167.331617] Call Trace:
[ 2167.331619]  [<ffffffff8114b0b0>] ? drain_pages+0xb0/0xb0
[ 2167.331622]  [<ffffffff810cd335>] smp_call_function_single+0xe5/0x190
[ 2167.331626]  [<ffffffff8114b0b0>] ? drain_pages+0xb0/0xb0
[ 2167.331629]  [<ffffffff810cd74c>] smp_call_function_many+0x27c/0x2c0
[ 2167.331632]  [<ffffffff8114b0b0>] ? drain_pages+0xb0/0xb0
[ 2167.331635]  [<ffffffff8114b0b0>] ? drain_pages+0xb0/0xb0
[ 2167.331638]  [<ffffffff810cd87a>] on_each_cpu_mask+0x2a/0x60
[ 2167.331642]  [<ffffffff81148475>] drain_all_pages+0xb5/0xc0
[ 2167.331645]  [<ffffffff8114c70e>] __alloc_pages_nodemask+0x70e/0xa00
[ 2167.331649]  [<ffffffff811868d9>] alloc_pages_current+0xa9/0x170
[ 2167.331653]  [<ffffffff811436f7>] __page_cache_alloc+0x87/0xb0
[ 2167.331656]  [<ffffffff8114ea04>] __do_page_cache_readahead+0xf4/0x240
[ 2167.331660]  [<ffffffff811a26b1>] ? __mem_cgroup_try_charge+0x411/0xc40
[ 2167.331663]  [<ffffffff81107cf0>] ? delayacct_end+0x80/0x90
[ 2167.331667]  [<ffffffff8114f1c1>] ra_submit+0x21/0x30
[ 2167.331670]  [<ffffffff8114590c>] filemap_fault+0x33c/0x400
[ 2167.331674]  [<ffffffff811a0667>] ? __mem_cgroup_uncharge_common+0x47/0x310
[ 2167.331677]  [<ffffffff81167591>] __do_fault+0x71/0x4f0
[ 2167.331680]  [<ffffffff81180efb>] ? __frontswap_invalidate_page+0x2b/0x70
[ 2167.331684]  [<ffffffff8116a733>] handle_pte_fault+0x93/0xa40
[ 2167.331687]  [<ffffffff8116be81>] handle_mm_fault+0x291/0x660
[ 2167.331691]  [<ffffffff81610ee6>] __do_page_fault+0x146/0x510
[ 2167.331695]  [<ffffffff8160a582>] ? do_nanosleep+0x92/0x130
[ 2167.331698]  [<ffffffff8109109d>] ? hrtimer_nanosleep+0xad/0x170
[ 2167.331701]  [<ffffffff8108fee0>] ? hrtimer_get_res+0x50/0x50
[ 2167.331705]  [<ffffffff816112be>] do_page_fault+0xe/0x10
[ 2167.331708]  [<ffffffff8160d818>] page_fault+0x28/0x30
[ 2167.331710] Code: 89 45 d0 e8 89 50 24 00 48 8b 45 c8 4c 89 ff 48 89 c6 e8 8a fc 53 00 48 3b 5d d0 74 25 45 85 f6 75 09 eb 0f 0f 1f 44 00 00 f3 90 <41> f6 44 24 20 01 75 f6 48 83 c4 10 5b 41 5c 41 5d 41 5e 41 5f 
[ 2169.410234]  nf_defrag_ipv6 iptable_nat nf_nat_ipv4 nf_nat iptable_mangle ipt_REJECT nf_conntrack_ipv4 nf_defrag_ipv4 xt_conntrack nf_conntrack ebtable_filter ebtables ip6table_filter ip6_tables iptable_filter ip_tables sg xfs libcrc32c netxen_nic amd64_edac_mod hpilo hpwdt edac_mce_amd sp5100_tco shpchp pcspkr edac_core serio_raw microcode i2c_piix4 acpi_power_meter k10temp acpi_cpufreq mperf radeon sd_mod i2c_algo_bit crc_t10dif drm_kms_helper ttm ata_generic drm pata_acpi ahci libahci pata_atiixp libata hpsa i2c_core dm_mirror dm_region_hash dm_log dm_mod
[ 2169.465328] CPU: 7 PID: 5755 Comm: memcg_process_s Not tainted 3.11.0-rc7+ #1
[ 2169.473172] Hardware name: HP ProLiant DL585 G7, BIOS A16 12/31/2011
[ 2169.480155] task: ffff880333e69540 ti: ffff880333800000 task.ti: ffff880333800000
[ 2169.488379] RIP: 0010:[<ffffffff810cd72a>]  [<ffffffff810cd72a>] smp_call_function_many+0x25a/0x2c0
[ 2169.498335] RSP: 0000:ffff880333801a18  EFLAGS: 00000202
[ 2169.504174] RAX: 0000000000000008 RBX: 0000000000000282 RCX: ffff880237c989e0
[ 2169.512016] RDX: 0000000000000008 RSI: 0000000000000030 RDI: 0000000000000000
[ 2169.519861] RBP: ffff880333801a68 R08: ffff884a2f4bbe00 R09: ffff884a3fa57540
[ 2169.527713] R10: ffffea011bd40900 R11: ffffffff812fc0d9 R12: ffffffff81107cf0
[ 2169.535557] R13: ffff8803338019b8 R14: 0000000000000202 R15: ffff8817cd73e998
[ 2169.543402] FS:  00007f5019e79740(0000) GS:ffff884a3fa40000(0000) knlGS:0000000000000000
[ 2169.552297] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 2169.558612] CR2: 00007f7d0a209410 CR3: 00000046f7035000 CR4: 00000000000006e0
[ 2169.566454] Stack:
[ 2169.568660]  0000000100000000 0000000000015200 ffffffff8114b0b0 ffff88470bd55200
[ 2169.576832]  0000000000000202 ffffffff81d6ca80 ffffffff8114b0b0 0000000000000000
[ 2169.585006]  0000000000000007 0000000000000001 ffff880333801a98 ffffffff810cd87a
[ 2169.593242] Call Trace:
[ 2169.595929]  [<ffffffff8114b0b0>] ? drain_pages+0xb0/0xb0
[ 2169.601865]  [<ffffffff8114b0b0>] ? drain_pages+0xb0/0xb0
[ 2169.607801]  [<ffffffff810cd87a>] on_each_cpu_mask+0x2a/0x60
[ 2169.614024]  [<ffffffff81148475>] drain_all_pages+0xb5/0xc0
[ 2169.620150]  [<ffffffff8114c70e>] __alloc_pages_nodemask+0x70e/0xa00
[ 2169.627136]  [<ffffffff811868d9>] alloc_pages_current+0xa9/0x170
[ 2169.633744]  [<ffffffff811436f7>] __page_cache_alloc+0x87/0xb0
[ 2169.640156]  [<ffffffff81145755>] filemap_fault+0x185/0x400
[ 2169.646284]  [<ffffffff81167591>] __do_fault+0x71/0x4f0
[ 2169.652028]  [<ffffffff8116a733>] handle_pte_fault+0x93/0xa40
[ 2169.658346]  [<ffffffff810a23e5>] ? set_next_entity+0x95/0xb0
[ 2169.664664]  [<ffffffff8116be81>] handle_mm_fault+0x291/0x660
[ 2169.670982]  [<ffffffff81610ee6>] __do_page_fault+0x146/0x510
[ 2169.677300]  [<ffffffff8160a582>] ? do_nanosleep+0x92/0x130
[ 2169.683428]  [<ffffffff8109109d>] ? hrtimer_nanosleep+0xad/0x170
[ 2169.690032]  [<ffffffff8108fee0>] ? hrtimer_get_res+0x50/0x50
[ 2169.696350]  [<ffffffff816112be>] do_page_fault+0xe/0x10
[ 2169.702190]  [<ffffffff8160d818>] page_fault+0x28/0x30
[ 2169.707838] Code: 48 63 35 c2 48 94 00 89 c2 39 f0 0f 8d 2d fe ff ff 48 98 49 8b 4d 00 48 03 0c c5 40 62 a0 81 f6 41 20 01 74 cc 0f 1f 40 00 f3 90 <f6> 41 20 01 75 f8 48 63 35 91 48 94 00 eb b7 0f b6 4d b4 48 8b 
[ 2171.209655] BUG: soft lockup - CPU#2 stuck for 23s! [libvirtd:3264]
[ 2171.216550] Modules linked in: xt_CHECKSUM tun bridge stp llc ebtable_nat nf_conntrack_netbios_ns nf_conntrack_broadcast ipt_MASQUERADE ip6table_nat nf_nat_ipv6 ip6table_mangle ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 iptable_nat nf_nat_ipv4 nf_nat iptable_mangle ipt_REJECT nf_conntrack_ipv4 nf_defrag_ipv4 xt_conntrack nf_conntrack ebtable_filter ebtables ip6table_filter ip6_tables iptable_filter ip_tables sg xfs libcrc32c netxen_nic amd64_edac_mod hpilo hpwdt edac_mce_amd sp5100_tco shpchp pcspkr edac_core serio_raw microcode i2c_piix4 acpi_power_meter k10temp acpi_cpufreq mperf radeon sd_mod i2c_algo_bit crc_t10dif drm_kms_helper ttm ata_generic drm pata_acpi ahci libahci pata_atiixp libata hpsa i2c_core dm_mirror dm_region_hash dm_log dm_mod
[ 2171.290143] CPU: 2 PID: 3264 Comm: libvirtd Not tainted 3.11.0-rc7+ #1
[ 2171.297318] Hardware name: HP ProLiant DL585 G7, BIOS A16 12/31/2011
[ 2171.304302] task: ffff884831cc5500 ti: ffff884834142000 task.ti: ffff884834142000
[ 2171.312527] RIP: 0010:[<ffffffff810cd72e>]  [<ffffffff810cd72e>] smp_call_function_many+0x25e/0x2c0
[ 2171.322484] RSP: 0018:ffff884834143960  EFLAGS: 00000202
[ 2171.328320] RAX: 0000000000000008 RBX: ffff88033bc55210 RCX: ffff880237c98918
[ 2171.336163] RDX: 0000000000000008 RSI: 0000000000000030 RDI: 0000000000000000
[ 2171.344018] RBP: ffff8848341439b0 R08: ffff8839f88abe00 R09: ffff883a0bc17540
[ 2171.351861] R10: ffffea00e7dcac00 R11: ffffffff812fc0d9 R12: ffff884834143918
[ 2171.359704] R13: ffffffff81107cf0 R14: ffff884834143900 R15: 0000000000000206
[ 2171.367546] FS:  00007fa6d47be880(0000) GS:ffff883a0bc00000(0000) knlGS:0000000000000000
[ 2171.376440] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 2171.382755] CR2: 00007fde1aace469 CR3: 0000004a2c733000 CR4: 00000000000006e0
[ 2171.390598] Stack:
[ 2171.392804]  0000000100000000 0000000000015200 ffffffff8114b0b0 ffff88033bc55200
[ 2171.400973]  0000000000000202 ffffffff81d6ca80 ffffffff8114b0b0 0000000000000000
[ 2171.409144]  0000000000000002 0000000000000001 ffff8848341439e0 ffffffff810cd87a
[ 2171.417314] Call Trace:
[ 2171.420001]  [<ffffffff8114b0b0>] ? drain_pages+0xb0/0xb0
[ 2171.425937]  [<ffffffff8114b0b0>] ? drain_pages+0xb0/0xb0
[ 2171.431872]  [<ffffffff810cd87a>] on_each_cpu_mask+0x2a/0x60
[ 2171.438093]  [<ffffffff81148475>] drain_all_pages+0xb5/0xc0
[ 2171.444220]  [<ffffffff8114c70e>] __alloc_pages_nodemask+0x70e/0xa00
[ 2171.451207]  [<ffffffff811868d9>] alloc_pages_current+0xa9/0x170
[ 2171.457811]  [<ffffffff811436f7>] __page_cache_alloc+0x87/0xb0
[ 2171.464224]  [<ffffffff8114ea04>] __do_page_cache_readahead+0xf4/0x240
[ 2171.471402]  [<ffffffff8108d9a0>] ? wake_atomic_t_function+0x40/0x40
[ 2171.478387]  [<ffffffff8114f1c1>] ra_submit+0x21/0x30
[ 2171.483940]  [<ffffffff8114590c>] filemap_fault+0x33c/0x400
[ 2171.490065]  [<ffffffff81167591>] __do_fault+0x71/0x4f0
[ 2171.495810]  [<ffffffff8116a733>] handle_pte_fault+0x93/0xa40
[ 2171.502127]  [<ffffffff81173855>] ? change_protection_range+0x665/0x6f0
[ 2171.509399]  [<ffffffff8116be81>] handle_mm_fault+0x291/0x660
[ 2171.515716]  [<ffffffff81610ee6>] __do_page_fault+0x146/0x510
[ 2171.522034]  [<ffffffff81173945>] ? change_protection+0x65/0xb0
[ 2171.528544]  [<ffffffff811881cb>] ? change_prot_numa+0x1b/0x40
[ 2171.534955]  [<ffffffff810a1127>] ? task_numa_work+0x247/0x2e0
[ 2171.541368]  [<ffffffff8108974c>] ? task_work_run+0xac/0xe0
[ 2171.547495]  [<ffffffff816112be>] do_page_fault+0xe/0x10
[ 2171.553333]  [<ffffffff8160d818>] page_fault+0x28/0x30
[ 2171.558979] Code: 48 94 00 89 c2 39 f0 0f 8d 2d fe ff ff 48 98 49 8b 4d 00 48 03 0c c5 40 62 a0 81 f6 41 20 01 74 cc 0f 1f 40 00 f3 90 f6 41 20 01 <75> f8 48 63 35 91 48 94 00 eb b7 0f b6 4d b4 48 8b 75 c0 4c 89 
[ 2748.377519] nf_conntrack: automatic helper assignment is deprecated and it will be removed soon. Use the iptables CT target to attach helpers instead.
------------------------- snip -----------------------------

How to run the reproducer:
1. Install LTP test suite:
  $ git clone git://github.com/linux-test-project/ltp.git; make autotools; ./configure; make; make install
2. Execute the reproducer:
  $ cd /opt/ltp; ./runltp -s memcg_stress_test.sh

The issue doesn't occur on any machine, I just tested it on two machine, one machine is OK, which has 16Gb RAM,
the other machine is crashed, which has 290G RAM, 8 NUMA nodes.

Please let me know if you need more detailed info.

-- 
Thanks,
Zhouping

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
