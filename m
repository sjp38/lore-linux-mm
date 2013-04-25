Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 920226B0033
	for <linux-mm@kvack.org>; Wed, 24 Apr 2013 21:24:27 -0400 (EDT)
Message-ID: <517885C0.70701@redhat.com>
Date: Thu, 25 Apr 2013 09:24:16 +0800
From: Lingzhu Xiang <lxiang@redhat.com>
MIME-Version: 1.0
Subject: BUG in __mem_cgroup_uncharge_common
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>
Cc: cgroups@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Hit VM_BUG_ON(PageSwapCache(page)) in mm/memcontrol.c twice with 3.9-rc8
and 3.7.6 during LTP run on ppc64 machines.


[ 9699.793674] ------------[ cut here ]------------ 
[ 9699.793719] kernel BUG at mm/memcontrol.c:3994! 
[ 9699.793745] Oops: Exception in kernel mode, sig: 5 [#1] 
[ 9699.793756] SMP NR_CPUS=1024 NUMA pSeries 
[ 9699.793768] Modules linked in: tun(F) scsi_transport_iscsi(F) ipt_ULOG(F) nfc(F) af_key(F) rds(F) af_802154(F) pppoe(F) pppox(F) ppp_generic(F) slhc(F) atm(F) sctp(F) ip6table_filter(F) ip6_tables(F) iptable_filter(F) ip_tables(F) btrfs(F) raid6_pq(F) xor(F) vfat(F) fat(F) nfsv3(F) nfs_acl(F) nfsv2(F) nfs(F) lockd(F) sunrpc(F) fscache(F) nfnetlink_log(F) nfnetlink(F) bluetooth(F) rfkill(F) arc4(F) md4(F) nls_utf8(F) cifs(F) dns_resolver(F) nf_tproxy_core(F) nls_koi8_u(F) nls_cp932(F) ts_kmp(F) fuse(F) sg(F) ehea(F) xfs(F) libcrc32c(F) sd_mod(F) crc_t10dif(F) ibmvscsi(F) scsi_transport_srp(F) scsi_tgt(F) dm_mirror(F) dm_region_hash(F) dm_log(F) dm_mod(F) [last unloaded: ipt_REJECT] 
[ 9699.794061] NIP: c000000000201c40 LR: c0000000001cf770 CTR: 0000000000021f84 
[ 9699.794082] REGS: c0000000210674e0 TRAP: 0700   Tainted: GF             (3.9.0-rc8) 
[ 9699.794091] MSR: 8000000000029032 <SF,EE,ME,IR,DR,RI>  CR: 22824422  XER: 00000000 
[ 9699.794141] SOFTE: 1 
[ 9699.794151] CFAR: c0000000002076a8 
[ 9699.794159] TASK = c000000075c4bfa0[48350] 'msgctl10' THREAD: c000000021064000 CPU: 15 
GPR00: c0000000001cf770 c000000021067760 c0000000010f3dc8 c00000007f2236b0  
GPR04: 0000000000000001 0000000000000000 0000000000000000 0000000000000000  
GPR08: c00000007f2236c8 0000000000000001 0000000000000000 00000000187e8800  
GPR12: 0000000022824428 c00000000ede3c00 c00000007f2236b0 ffffffffffffff80  
GPR16: 4000000000000000 0000000000000001 00003fffd1f30000 c00000007f041bc8  
GPR20: 00003fffd1f20000 c00000010c4ba9a0 0000000000000000 c000000000ae0788  
GPR24: c000000000ae0788 0000187e88000393 c000000001163dc8 0000000000000001  
GPR28: c000000001160900 c00000007f2236b0 ffffffffffffffff c00000007f2236b0  
[ 9699.794381] NIP [c000000000201c40] .__mem_cgroup_uncharge_common+0x50/0x340 
[ 9699.794398] LR [c0000000001cf770] .page_remove_rmap+0x120/0x1d0 
[ 9699.794414] Call Trace: 
[ 9699.794427] [c000000021067760] [c000000000201d00] .__mem_cgroup_uncharge_common+0x110/0x340 (unreliable) 
[ 9699.794441] [c000000021067810] [c0000000001cf770] .page_remove_rmap+0x120/0x1d0 
[ 9699.794461] [c0000000210678a0] [c0000000001c10f0] .unmap_single_vma+0x5b0/0x8c0 
[ 9699.794494] [c0000000210679e0] [c0000000001c1ea4] .unmap_vmas+0x74/0xe0 
[ 9699.794515] [c000000021067a80] [c0000000001cbd48] .exit_mmap+0xd8/0x1a0 
[ 9699.794542] [c000000021067ba0] [c000000000082e90] .mmput+0xa0/0x170 
[ 9699.794575] [c000000021067c30] [c00000000008d4e8] .do_exit+0x308/0xb40 
[ 9699.794587] [c000000021067d30] [c00000000008ddc4] .do_group_exit+0x54/0xf0 
[ 9699.794612] [c000000021067dc0] [c00000000008de74] .SyS_exit_group+0x14/0x20 
[ 9699.794633] [c000000021067e30] [c000000000009e54] syscall_exit+0x0/0x98 
[ 9699.794645] Instruction dump: 
[ 9699.794663] fba1ffe8 fbc1fff0 fbe1fff8 2f890000 f8010010 91810008 f821ff51 409e019c  
[ 9699.794702] e9230000 7c7d1b78 7c9b2378 792987e2 <0b090000> f8a10070 48006959 60000000  
[ 9699.794761] ---[ end trace 18332a81b4a27c2d ]--- 

[ 6230.168170] ------------[ cut here ]------------ 
[ 6230.168200] kernel BUG at mm/memcontrol.c:3027! 
[ 6230.168206] Oops: Exception in kernel mode, sig: 5 [#1] 
[ 6230.168210] SMP NR_CPUS=1024 NUMA pSeries 
[ 6230.168215] Modules linked in: tun binfmt_misc hidp cmtp kernelcapi rfcomm l2tp_ppp l2tp_netlink l2tp_core bnep nfc af_802154 pppoe pppox ppp_generic slhc rds af_key atm sctp ip6table_filter ip6_tables iptable_filter ip_tables btrfs libcrc32c vfat fat nfsv3 nfs_acl nfsv2 nfs lockd sunrpc fscache nfnetlink_log nfnetlink bluetooth rfkill des_generic md4 nls_utf8 cifs dns_resolver nf_tproxy_core deflate lzo nls_koi8_u nls_cp932 ts_kmp sg ehea xfs sd_mod crc_t10dif ibmvscsi scsi_transport_srp scsi_tgt dm_mirror dm_region_hash dm_log dm_mod [last unloaded: ipt_REJECT] 
[ 6230.168322] NIP: c0000000001f4d70 LR: c0000000001c5480 CTR: 0000000000000000 
[ 6230.168327] REGS: c000000107c9f2c0 TRAP: 0700   Tainted: G        W     (3.7.6+) 
[ 6230.168330] MSR: 8000000002029032 <SF,VEC,EE,ME,IR,DR,RI>  CR: 28004082  XER: 00000001 
[ 6230.168341] SOFTE: 1 
[ 6230.168343] CFAR: c0000000001f9448 
[ 6230.168346] TASK = c000000108ef9a40[27179] 'msgctl10' THREAD: c000000107c9c000 CPU: 49 
GPR00: c0000000001c5480 c000000107c9f540 c000000001133ab0 c00000013f2932f8  
GPR04: 0000000000000001 0000000000000000 0000000000000c00 0000000000000011  
GPR08: c00000013f293310 0000000000000001 0000000000000000 0000000000000060  
GPR12: 0000000028004088 c00000000ee0ab80 0000000000000000 0000000000000000  
GPR16: 0000000000000000 0000000000000000 0000000000000000 c00000013f1c0378  
GPR20: 00003fffb1990000 00003fffb1980000 c00000011b0f0000 c00000000147da80  
GPR24: 000045da80000393 c0000000ad960900 0000000000000001 c0000000011a09e0  
GPR28: c00000013f2932f8 c0000000adf2cad0 c0000000010b8d58 c00000013f2932f8  
[ 6230.168401] NIP [c0000000001f4d70] .__mem_cgroup_uncharge_common+0x50/0x320 
[ 6230.168405] LR [c0000000001c5480] .page_remove_rmap+0x140/0x1d0 
[ 6230.168408] Call Trace: 
[ 6230.168411] [c000000107c9f5f0] [c0000000001c5480] .page_remove_rmap+0x140/0x1d0 
[ 6230.168417] [c000000107c9f680] [c0000000001b6c30] .do_wp_page+0x3f0/0xd80 
[ 6230.168421] [c000000107c9f780] [c0000000001b92e0] .handle_pte_fault+0x350/0xca0 
[ 6230.168428] [c000000107c9f880] [c000000000708440] .do_page_fault+0x420/0x830 
[ 6230.168433] [c000000107c9fab0] [c000000000005d68] handle_page_fault+0x10/0x30 
[ 6230.168439] --- Exception: 301 at .schedule_tail+0x94/0x120 
[ 6230.168439]     LR = .schedule_tail+0x8c/0x120 
[ 6230.168444] [c000000107c9fda0] [c0000000000c5b4c] .schedule_tail+0x5c/0x120 (unreliable) 
[ 6230.168449] [c000000107c9fe30] [c000000000009a9c] .ret_from_fork+0x4/0x54 
[ 6230.168453] Instruction dump: 
[ 6230.168455] ebc2bc58 f8010010 91810008 f821ff51 eb7e8000 813b0068 2f890000 409e019c  
[ 6230.168463] e9230000 7c7c1b78 7c9a2378 792987e2 <0b090000> f8a10070 48005649 60000000  
[ 6230.168476] ---[ end trace 13237c53a86ce213 ]--- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
