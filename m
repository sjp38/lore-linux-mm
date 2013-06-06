Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 4B6BB6B0073
	for <linux-mm@kvack.org>; Thu,  6 Jun 2013 03:13:32 -0400 (EDT)
Date: Thu, 6 Jun 2013 03:13:31 -0400 (EDT)
From: CAI Qian <caiqian@redhat.com>
Message-ID: <1965620152.12263736.1370502811027.JavaMail.root@redhat.com>
In-Reply-To: <1516975240.12263021.1370502669219.JavaMail.root@redhat.com>
Subject: kernel BUG at mm/slub.c:3352!
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm <linux-mm@kvack.org>
Cc: linux-ext4@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

Just a head-up. While testing the latest ext4 tree,
https://ext4.wiki.kernel.org/index.php/Weekly_devel_tree_testing_status
it triggered this,
[ 1101.707942] kernel BUG at mm/slub.c:3352! 
[ 1101.707949] Oops: Exception in kernel mode, sig: 5 [#1] 
[ 1101.707953] SMP NR_CPUS=1024 NUMA pSeries 
[ 1101.707959] Modules linked in: btrfs(F) raid6_pq(F) xor(F) vfat(F) fat(F) lockd(F) sunrpc(F) nf_conntrack_netbios_ns(F) nf_conntrack_broadcast(F) ipt_MASQUERADE(F) ip6table_mangle(F) ip6t_REJECT(F) nf_conntrack_ipv6(F) nf_defrag_ipv6(F) iptable_nat(F) nf_nat_ipv4(F) nf_nat(F) iptable_mangle(F) ipt_REJECT(F) nf_conntrack_ipv4(F) nf_defrag_ipv4(F) xt_conntrack(F) nf_conntrack(F) ebtable_filter(F) ebtables(F) ip6table_filter(F) ip6_tables(F) iptable_filter(F) ip_tables(F) sg(F) ehea(F) xfs(F) libcrc32c(F) sd_mod(F) crc_t10dif(F) ibmvscsi(F) scsi_transport_srp(F) scsi_tgt(F) dm_mirror(F) dm_region_hash(F) dm_log(F) dm_mod(F) [last unloaded: brd] 
[ 1101.708036] CPU: 27 PID: 19560 Comm: rhts-test-runne Tainted: GF            3.10.0-rc2+ #1 
[ 1101.708042] task: c0000003f54ecb00 ti: c0000003c7b7c000 task.ti: c0000003c7b7c000 
[ 1101.708047] NIP: c0000000001f7960 LR: c00000000021e098 CTR: c00000000021e0c0 
[ 1101.708053] REGS: c0000003c7b7f830 TRAP: 0700   Tainted: GF             (3.10.0-rc2+) 
[ 1101.708057] MSR: 8000000000029032 <SF,EE,ME,IR,DR,RI>  CR: 22044428  XER: 00000000 
[ 1101.708070] SOFTE: 1 
[ 1101.708073] CFAR: c0000000001f78a0 
[ 1101.708076]  
GPR00: c00000000021e098 c0000003c7b7fab0 c000000001118258 c000000300000000  
GPR04: c000000006ed0af0 c0000003f3324c00 c00000000021e08c 0000000000000000  
GPR08: c0000000014b6000 0000000000000001 0000000000000000 0000000000000c00  
GPR12: 0000000022044428 c00000000f246c00 0000010019f53f90 0000000000000000  
GPR16: 0000000000000024 00000000100f2910 00000000101439b8 0000000000000014  
GPR20: 0000000000000000 00000000ffffffff 0000000000000001 0000000000000000  
GPR24: 0000000000000000 c00000037b8b9110 c0000003f6060220 c0000003ef76ad40  
GPR28: c00000000021e098 c000000005fa0000 c000000300000000 c000000300000000  
[ 1101.708141] NIP [c0000000001f7960] .kfree+0x150/0x280 
[ 1101.708146] LR [c00000000021e098] .free_pipe_info+0xa8/0xd0 
[ 1101.708150] Call Trace: 
[ 1101.708156] [c0000003c7b7fab0] [c0000003c7b7fb30] 0xc0000003c7b7fb30 (unreliable) 
[ 1101.708163] [c0000003c7b7fb50] [c00000000021e098] .free_pipe_info+0xa8/0xd0 
[ 1101.708169] [c0000003c7b7fbd0] [c00000000021e198] .pipe_release+0xd8/0x160 
[ 1101.708175] [c0000003c7b7fc60] [c000000000213dd0] .__fput+0xd0/0x2d0 
[ 1101.708183] [c0000003c7b7fd10] [c0000000000b4ca8] .task_work_run+0xe8/0x170 
[ 1101.708189] [c0000003c7b7fdb0] [c000000000017240] .do_notify_resume+0xa0/0xb0 
[ 1101.708195] [c0000003c7b7fe30] [c00000000000a41c] .ret_from_except_lite+0x48/0x4c 
[ 1101.708200] Instruction dump: 
[ 1101.708204] e90d0040 7ca32b78 e9290000 7cea3b78 7c8a402a 7fa44800 409eff98 4bffff80  
[ 1101.708214] e93d0000 552a0423 7d380026 55291ffe <0b090000> e93d0000 38800000 792a97e3  
[ 1101.708230] ---[ end trace c320e07d73bae68f ]--- 
[ 1101.709081]  
[ 1101.709788] Unable to handle kernel paging request for data at address 0x2020207044657669 
[ 1101.709802] Faulting instruction address: 0xc0000000001f91d8 
[ 1101.709814] Oops: Kernel access of bad area, sig: 11 [#2] 
[ 1101.709820] SMP NR_CPUS=1024 NUMA pSeries 
[ 1101.709832] Modules linked in: btrfs(F) raid6_pq(F) xor(F) vfat(F) fat(F) lockd(F) sunrpc(F) nf_conntrack_netbios_ns(F) nf_conntrack_broadcast(F) ipt_MASQUERADE(F) ip6table_mangle(F) ip6t_REJECT(F) nf_conntrack_ipv6(F) nf_defrag_ipv6(F) iptable_nat(F) nf_nat_ipv4(F) nf_nat(F) iptable_mangle(F) ipt_REJECT(F) nf_conntrack_ipv4(F) nf_defrag_ipv4(F) xt_conntrack(F) nf_conntrack(F) ebtable_filter(F) ebtables(F) ip6table_filter(F) ip6_tables(F) iptable_filter(F) ip_tables(F) sg(F) ehea(F) xfs(F) libcrc32c(F) sd_mod(F) crc_t10dif(F) ibmvscsi(F) scsi_transport_srp(F) scsi_tgt(F) dm_mirror(F) dm_region_hash(F) dm_log(F) dm_mod(F) [last unloaded: brd] 
[ 1101.709999] CPU: 26 PID: 12052 Comm: rhts-test-runne Tainted: GF     D      3.10.0-rc2+ #1 
[ 1101.710014] task: c0000003db44f780 ti: c0000003dbd4c000 task.ti: c0000003dbd4c000 
[ 1101.710026] NIP: c0000000001f91d8 LR: c0000000001f92d4 CTR: 0000000000000000 
[ 1101.710039] REGS: c0000003dbd4f810 TRAP: 0300   Tainted: GF     D       (3.10.0-rc2+) 
[ 1101.710052] MSR: 8000000000009032 <SF,EE,ME,IR,DR,RI>  CR: 24044428  XER: 00000000 
[ 1101.710091] SOFTE: 1 
[ 1101.710095] CFAR: c00000000000908c 
[ 1101.710105] DAR: 2020207044657669, DSISR: 40000000 
[ 1101.710117]  
GPR00: c0000000001f92d4 c0000003dbd4fa90 c000000001118258 0000000000000000  
GPR04: 00000000000080d0 0000000000000088 c0000003d4e924e0 c000000001855d00  
GPR08: 000000000000301c 0000000000000000 0000000000000000 c000000000015600  
GPR12: 800000000200f032 c00000000f246800 0000010019f47520 0000000000000000  
GPR16: 0000000000000024 00000000100f2910 00000000101439b8 0000000000000028  
GPR20: 0000000000000000 00000000ffffffff 0000000000000001 0000000000000000  
GPR24: 0000000000000000 0000000000000000 0000000000000088 c0000003fe01b400  
GPR28: c00000000021df30 00000000000080d0 2020207044657669 c0000003fe01b400  
[ 1101.710288] NIP [c0000000001f91d8] .kmem_cache_alloc_trace+0x98/0x2f0 
[ 1101.710299] LR [c0000000001f92d4] .kmem_cache_alloc_trace+0x194/0x2f0 
[ 1101.710306] Call Trace: 
[ 1101.710316] [c0000003dbd4fa90] [c0000000001f92d4] .kmem_cache_alloc_trace+0x194/0x2f0 (unreliable) 
[ 1101.710337] [c0000003dbd4fb40] [c00000000021df30] .alloc_pipe_info+0x30/0xf0 
[ 1101.710351] [c0000003dbd4fbc0] [c00000000021e6b8] .create_pipe_files+0x58/0x240 
[ 1101.710367] [c0000003dbd4fc80] [c00000000021e8ec] .__do_pipe_flags+0x4c/0x180 
[ 1101.710378] [c0000003dbd4fd20] [c00000000021eab4] .SyS_pipe2+0x24/0xd0 
[ 1101.710394] [c0000003dbd4fdc0] [c00000000021eb74] .SyS_pipe+0x14/0x30 
[ 1101.710409] [c0000003dbd4fe30] [c000000000009e54] syscall_exit+0x0/0x98 
[ 1101.710415] Instruction dump: 
[ 1101.717943] 7ce95214 e9070008 7fc9502a e9270010 2fbe0000 41de0084 2fa90000 3b200000  
[ 1101.717975] 419e0078 e95f0022 e93f0000 79290720 <7f1e502a> 0b090000 0b190000 39200000  
[ 1101.718013] ---[ end trace c320e07d73bae690 ]--- 
[ 1101.728370]  
[ 1102.130418] Unable to handle kernel paging request for data at address 0x2020207044657669 
[ 1102.137941] Faulting instruction address: 0xc0000000001f91d8 
[ 1102.137950] Oops: Kernel access of bad area, sig: 11 [#3] 
[ 1102.137954] SMP NR_CPUS=1024 NUMA pSeries 
[ 1102.137961] Modules linked in: btrfs(F) raid6_pq(F) xor(F) vfat(F) fat(F) lockd(F) sunrpc(F) nf_conntrack_netbios_ns(F) nf_conntrack_broadcast(F) ipt_MASQUERADE(F) ip6table_mangle(F) ip6t_REJECT(F) nf_conntrack_ipv6(F) nf_defrag_ipv6(F) iptable_nat(F) nf_nat_ipv4(F) nf_nat(F) iptable_mangle(F) ipt_REJECT(F) nf_conntrack_ipv4(F) nf_defrag_ipv4(F) xt_conntrack(F) nf_conntrack(F) ebtable_filter(F) ebtables(F) ip6table_filter(F) ip6_tables(F) iptable_filter(F) ip_tables(F) sg(F) ehea(F) xfs(F) libcrc32c(F) sd_mod(F) crc_t10dif(F) ibmvscsi(F) scsi_transport_srp(F) scsi_tgt(F) dm_mirror(F) dm_region_hash(F) dm_log(F) dm_mod(F) [last unloaded: brd] 
[ 1102.138037] CPU: 26 PID: 19585 Comm: groff Tainted: GF     D      3.10.0-rc2+ #1 
[ 1102.138044] task: c0000003f0c29400 ti: c0000003f0ce0000 task.ti: c0000003f0ce0000 
[ 1102.138050] NIP: c0000000001f91d8 LR: c0000000001f92d4 CTR: 0000000000000000 
[ 1102.138055] REGS: c0000003f0ce3810 TRAP: 0300   Tainted: GF     D       (3.10.0-rc2+) 
[ 1102.138060] MSR: 8000000000009032 <SF,EE,ME,IR,DR,RI>  CR: 24024088  XER: 00000000 
[ 1102.138075] SOFTE: 1 
[ 1102.138078] CFAR: c00000000000908c 
[ 1102.138082] DAR: 2020207044657669, DSISR: 40000000 
[ 1102.138086]  
GPR00: c0000000001f92d4 c0000003f0ce3a90 c000000001118258 0000000000000000  
GPR04: 00000000000080d0 0000000000000088 c0000003d4e92210 c000000001855d00  
GPR08: 0000000000003020 0000000000000000 0000000000000000 c000000000015600  
GPR12: 800000000200f032 c00000000f246800 00000000100103f0 0000000000000000  
GPR16: 0000000000000000 0000000000000001 00000000100103f8 0000000000000000  
GPR20: 0000000010010820 0000000000000000 0000000010010830 0000000000000001  
GPR24: 0000000010010828 0000000000000000 0000000000000088 c0000003fe01b400  
GPR28: c00000000021df30 00000000000080d0 2020207044657669 c0000003fe01b400  
[ 1102.138158] NIP [c0000000001f91d8] .kmem_cache_alloc_trace+0x98/0x2f0 
[ 1102.138164] LR [c0000000001f92d4] .kmem_cache_alloc_trace+0x194/0x2f0 
[ 1102.138168] Call Trace: 
[ 1102.138173] [c0000003f0ce3a90] [c0000000001f92d4] .kmem_cache_alloc_trace+0x194/0x2f0 (unreliable) 
[ 1102.138181] [c0000003f0ce3b40] [c00000000021df30] .alloc_pipe_info+0x30/0xf0 
[ 1102.138188] [c0000003f0ce3bc0] [c00000000021e6b8] .create_pipe_files+0x58/0x240 
[ 1102.138195] [c0000003f0ce3c80] [c00000000021e8ec] .__do_pipe_flags+0x4c/0x180 
[ 1102.138201] [c0000003f0ce3d20] [c00000000021eab4] .SyS_pipe2+0x24/0xd0 
[ 1102.138208] [c0000003f0ce3dc0] [c00000000021eb74] .SyS_pipe+0x14/0x30 
[ 1102.138215] [c0000003f0ce3e30] [c000000000009e54] syscall_exit+0x0/0x98 
[ 1102.138220] Instruction dump: 
[ 1102.138224] 7ce95214 e9070008 7fc9502a e9270010 2fbe0000 41de0084 2fa90000 3b200000  
[ 1102.138236] 419e0078 e95f0022 e93f0000 79290720 <7f1e502a> 0b090000 0b190000 39200000  
[ 1102.138250] ---[ end trace c320e07d73bae691 ]--- 
[ 1102.139874]  
[ 1103.769587] Unable to handle kernel paging request for data at address 0x2020207044657669 
[ 1103.769602] Faulting instruction address: 0xc0000000001f91d8 
[ 1103.769609] Oops: Kernel access of bad area, sig: 11 [#4] 
[ 1103.769614] SMP NR_CPUS=1024 NUMA pSeries 
[ 1103.769621] Modules linked in: btrfs(F) raid6_pq(F) xor(F) vfat(F) fat(F) lockd(F) sunrpc(F) nf_conntrack_netbios_ns(F) nf_conntrack_broadcast(F) ipt_MASQUERADE(F) ip6table_mangle(F) ip6t_REJECT(F) nf_conntrack_ipv6(F) nf_defrag_ipv6(F) iptable_nat(F) nf_nat_ipv4(F) nf_nat(F) iptable_mangle(F) ipt_REJECT(F) nf_conntrack_ipv4(F) nf_defrag_ipv4(F) xt_conntrack(F) nf_conntrack(F) ebtable_filter(F) ebtables(F) ip6table_filter(F) ip6_tables(F) iptable_filter(F) ip_tables(F) sg(F) ehea(F) xfs(F) libcrc32c(F) sd_mod(F) crc_t10dif(F) ibmvscsi(F) scsi_transport_srp(F) scsi_tgt(F) dm_mirror(F) dm_region_hash(F) dm_log(F) dm_mod(F) [last unloaded: brd] 
[ 1103.769692] CPU: 26 PID: 19614 Comm: xargs Tainted: GF     D      3.10.0-rc2+ #1 
[ 1103.769698] task: c0000003f5b78b80 ti: c0000003f5bd8000 task.ti: c0000003f5bd8000 
[ 1103.769704] NIP: c0000000001f91d8 LR: c0000000001f92d4 CTR: 0000000000000000 
[ 1103.769709] REGS: c0000003f5bdb810 TRAP: 0300   Tainted: GF     D       (3.10.0-rc2+) 
[ 1103.769714] MSR: 8000000000009032 <SF,EE,ME,IR,DR,RI>  CR: 24000428  XER: 00000000 
[ 1103.769729] SOFTE: 1 
[ 1103.769732] CFAR: c00000000000908c 
[ 1103.769736] DAR: 2020207044657669, DSISR: 40000000 
[ 1103.769740]  
GPR00: c0000000001f92d4 c0000003f5bdba90 c000000001118258 0000000000000000  
GPR04: 00000000000080d0 0000000000000088 c0000003d4e921c0 c000000001855d00  
GPR08: 0000000000003020 0000000000000000 0000000000000000 c000000000015600  
GPR12: 800000000200f032 c00000000f246800 000000001000b770 000000001000b778  
GPR16: 000000001000b6e8 0000000010020004 0000000000000001 0000000000000000  
GPR20: 00001ffffff60110 000000001000ac70 00000000100200b0 0000000010020e20  
GPR24: 0000000010020dc8 0000000000000000 0000000000000088 c0000003fe01b400  
GPR28: c00000000021df30 00000000000080d0 2020207044657669 c0000003fe01b400  
[ 1103.769812] NIP [c0000000001f91d8] .kmem_cache_alloc_trace+0x98/0x2f0 
[ 1103.769818] LR [c0000000001f92d4] .kmem_cache_alloc_trace+0x194/0x2f0 
[ 1103.769822] Call Trace: 
[ 1103.769827] [c0000003f5bdba90] [c0000000001f92d4] .kmem_cache_alloc_trace+0x194/0x2f0 (unreliable) 
[ 1103.769835] [c0000003f5bdbb40] [c00000000021df30] .alloc_pipe_info+0x30/0xf0 
[ 1103.769842] [c0000003f5bdbbc0] [c00000000021e6b8] .create_pipe_files+0x58/0x240 
[ 1103.769849] [c0000003f5bdbc80] [c00000000021e8ec] .__do_pipe_flags+0x4c/0x180 
[ 1103.769855] [c0000003f5bdbd20] [c00000000021eab4] .SyS_pipe2+0x24/0xd0 
[ 1103.769862] [c0000003f5bdbdc0] [c00000000021eb74] .SyS_pipe+0x14/0x30 
[ 1103.769869] [c0000003f5bdbe30] [c000000000009e54] syscall_exit+0x0/0x98 
[ 1103.769874] Instruction dump: 
[ 1103.769878] 7ce95214 e9070008 7fc9502a e9270010 2fbe0000 41de0084 2fa90000 3b200000  
[ 1103.769890] 419e0078 e95f0022 e93f0000 79290720 <7f1e502a> 0b090000 0b190000 39200000  
[ 1103.769904] ---[ end trace c320e07d73bae692 ]--- 
[ 1103.778891]  
[ 1104.319798] Unable to handle kernel paging request for data at address 0x2020207044657669 
[ 1104.319816] Faulting instruction address: 0xc0000000001f8314 
[ 1104.319823] Oops: Kernel access of bad area, sig: 11 [#5] 
[ 1104.319827] SMP NR_CPUS=1024 NUMA pSeries 
[ 1104.319835] Modules linked in: btrfs(F) raid6_pq(F) xor(F) vfat(F) fat(F) lockd(F) sunrpc(F) nf_conntrack_netbios_ns(F) nf_conntrack_broadcast(F) ipt_MASQUERADE(F) ip6table_mangle(F) ip6t_REJECT(F) nf_conntrack_ipv6(F) nf_defrag_ipv6(F) iptable_nat(F) nf_nat_ipv4(F) nf_nat(F) iptable_mangle(F) ipt_REJECT(F) nf_conntrack_ipv4(F) nf_defrag_ipv4(F) xt_conntrack(F) nf_conntrack(F) ebtable_filter(F) ebtables(F) ip6table_filter(F) ip6_tables(F) iptable_filter(F) ip_tables(F) sg(F) ehea(F) xfs(F) libcrc32c(F) sd_mod(F) crc_t10dif(F) ibmvscsi(F) scsi_transport_srp(F) scsi_tgt(F) dm_mirror(F) dm_region_hash(F) dm_log(F) dm_mod(F) [last unloaded: brd] 
[ 1104.319905] CPU: 26 PID: 19635 Comm: tar Tainted: GF     D      3.10.0-rc2+ #1 
[ 1104.319911] task: c0000003f221b800 ti: c0000003f22a4000 task.ti: c0000003f22a4000 
[ 1104.319917] NIP: c0000000001f8314 LR: c0000000001f84a4 CTR: c0000000001f8260 
[ 1104.319923] REGS: c0000003f22a7190 TRAP: 0300   Tainted: GF     D       (3.10.0-rc2+) 
[ 1104.319928] MSR: 8000000000009032 <SF,EE,ME,IR,DR,RI>  CR: 24022448  XER: 00000000 
[ 1104.319942] SOFTE: 1 
[ 1104.319945] CFAR: c00000000000908c 
[ 1104.319949] DAR: 2020207044657669, DSISR: 40000000 
[ 1104.319953]  
GPR00: c0000000001f84a4 c0000003f22a7410 c000000001118258 0000000000000000  
GPR04: 0000000000000250 0000000000000001 0000000000000000 c000000001855d00  
GPR08: 0000000000003020 0000000000000000 0000000000000000 c0000000001f8260  
GPR12: d0000000023dc278 c00000000f246800 0000000000000000 0000000000000000  
GPR16: 00000000000081b6 0000000000000004 c00000000bc1c000 c0000003f22a76d0  
GPR20: 0000000000000000 c0000000096b6b30 c0000003f1424000 c0000000096b6c10  
GPR24: 0000000000000000 0000000000000000 d000000002367c1c 0000000000000098  
GPR28: c0000003fe01b400 0000000000000250 2020207044657669 c0000003fe01b400  
[ 1104.320024] NIP [c0000000001f8314] .__kmalloc+0xb4/0x360 
[ 1104.320029] LR [c0000000001f84a4] .__kmalloc+0x244/0x360 
[ 1104.320033] Call Trace: 
[ 1104.320037] [c0000003f22a7410] [c0000000001f84a4] .__kmalloc+0x244/0x360 (unreliable) 
[ 1104.320084] [c0000003f22a74c0] [d000000002367c1c] .kmem_alloc+0x9c/0x140 [xfs] 
[ 1104.320130] [c0000003f22a7560] [d0000000023c1018] .xfs_log_commit_cil+0x188/0x600 [xfs] 
[ 1104.320175] [c0000003f22a7660] [d0000000023baa48] .xfs_trans_commit+0x168/0x300 [xfs] 
[ 1104.320217] [c0000003f22a7710] [d0000000023662c4] .xfs_create+0x5e4/0x620 [xfs] 
[ 1104.320259] [c0000003f22a7830] [d00000000235d8fc] .xfs_vn_mknod+0x8c/0x230 [xfs] 
[ 1104.320267] [c0000003f22a7900] [c000000000222b90] .vfs_create+0xf0/0x180 
[ 1104.320274] [c0000003f22a79b0] [c000000000225bcc] .do_last+0x9ec/0xdf0 
[ 1104.320280] [c0000003f22a7ad0] [c0000000002260bc] .path_openat+0xec/0x5c0 
[ 1104.320287] [c0000003f22a7bf0] [c0000000002269e0] .do_filp_open+0x40/0xb0 
[ 1104.320294] [c0000003f22a7d10] [c000000000210c30] .do_sys_open+0x140/0x250 
[ 1104.320300] [c0000003f22a7dc0] [c000000000210d98] .SyS_creat+0x18/0x30 
[ 1104.320308] [c0000003f22a7e30] [c000000000009e54] syscall_exit+0x0/0x98 
[ 1104.320313] Instruction dump: 
[ 1104.320317] 7ce95214 e9070008 7fc9502a e9270010 2fbe0000 41de0088 2fa90000 3b200000  
[ 1104.320329] 419e007c e95c0022 e93c0000 79290720 <7f1e502a> 0b090000 0b190000 39200000  
[ 1104.320342] ---[ end trace c320e07d73bae693 ]--- 
[ 1104.329423]  
CAI Qian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
