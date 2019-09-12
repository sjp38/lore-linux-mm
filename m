Return-Path: <SRS0=iDsh=XH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 64401C4CEC6
	for <linux-mm@archiver.kernel.org>; Thu, 12 Sep 2019 23:39:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BC692206CD
	for <linux-mm@archiver.kernel.org>; Thu, 12 Sep 2019 23:39:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BC692206CD
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=toxcorp.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 52B946B0003; Thu, 12 Sep 2019 19:39:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4DB166B0006; Thu, 12 Sep 2019 19:39:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3A3476B0007; Thu, 12 Sep 2019 19:39:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0016.hostedemail.com [216.40.44.16])
	by kanga.kvack.org (Postfix) with ESMTP id 1BDCB6B0003
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 19:39:19 -0400 (EDT)
Received: from smtpin20.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id C6ADD8243768
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 23:39:18 +0000 (UTC)
X-FDA: 75927887196.20.arch68_511e8d50e7d0e
X-HE-Tag: arch68_511e8d50e7d0e
X-Filterd-Recvd-Size: 64279
Received: from smark.slackware.pl (smark.slackware.pl [88.198.48.135])
	by imf11.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 23:39:17 +0000 (UTC)
Received: from dirac.toxcorp.com (unknown [172.22.22.8])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	(Authenticated sender: shasta@toxcorp.com)
	by smark.slackware.pl (Postfix) with ESMTPSA id 21EE120EDB;
	Fri, 13 Sep 2019 01:39:15 +0200 (CEST)
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
From: Jakub Jankowski <shasta@toxcorp.com>
Subject: Memory corruption (redzone overwritten) names_cache?
Message-ID: <99a811be-58e1-8256-48a2-f7ed12d6ddaa@toxcorp.com>
Date: Fri, 13 Sep 2019 01:39:12 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

We're getting some random memory corruption on an AWS EC2 instance with=20
4.19.x kernels. I've tried 4.19.19, 4.19.52, but the results below are=20
from the most recent (4.19.72). For debugging I enabled=20
KASAN+slub_debug, but TBH, I can't make heads or tails from these.

Without slub_debug, the host reboots within couple of minutes of uptime.=20
With slub_debug it survives a bit longer, but eventually all sorts of=20
issues manifest (including: reboot; ps not being able to read some=20
processes' /proc/<pid>/cmdline while /proc/<pid>/stack shows=20
acct_collect()->down_read(), etc).

Upon multiple tests, the slab I most often seen pop up as first detected=20
as corrupted was names_cache.
What is really weird is that multiple times I saw redzone being=20
overwritten by the same content, which looks like part of 'sessions.py'=C2=
=A0=20
Python's 'requests' module.

Any debugging hints would be greatly appreciated.


Command line: BOOT_IMAGE=3D(hd0,msdos2)/vmlinuz ro root=3D/dev/xvda5 cons=
ole=3Dtty0 console=3DttyS0,9600n8 crashkernel=3D512M-2G:64M,2G-:128M kmem=
leak=3Don slub_debug=3DFZPU slub_nomerge
(...)
[  262.957418] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D
[  262.957423] BUG vm_area_struct (Tainted: G    B      O     ): Redzone =
overwritten
[  262.957424] ----------------------------------------------------------=
-------------------

[  262.957427] INFO: 0x00000000b91cc681-0x0000000098bd5238. First byte 0x=
6e instead of 0xcc
[  262.957433] INFO: Allocated in vm_area_dup+0x1e/0x180 age=3D6117 cpu=3D=
0 pid=3D8187
[  262.957438] 	kmem_cache_alloc+0x1a4/0x1d0
[  262.957439] 	vm_area_dup+0x1e/0x180
[  262.957441] 	copy_process.part.4+0x2fa9/0x6cd0
[  262.957443] 	_do_fork+0x151/0x7a0
[  262.957446] 	do_syscall_64+0x9b/0x290
[  262.957452] 	entry_SYSCALL_64_after_hwframe+0x49/0xbe
[  262.957455] INFO: Freed in qlist_free_all+0x37/0xd0 age=3D7431 cpu=3D0=
 pid=3D8521
[  262.957457] 	quarantine_reduce+0x1a2/0x210
[  262.957458] 	kasan_kmalloc+0x95/0xc0
[  262.957460] 	kmem_cache_alloc+0xc6/0x1d0
[  262.957463] 	getname_flags+0xba/0x510
[  262.957465] 	user_path_at_empty+0x1d/0x40
[  262.957468] 	vfs_statx+0xb9/0x140
[  262.957470] 	__se_sys_newstat+0x7c/0xd0
[  262.957472] 	do_syscall_64+0x9b/0x290
[  262.957474] 	entry_SYSCALL_64_after_hwframe+0x49/0xbe
[  262.957476] INFO: Slab 0x00000000ca532806 objects=3D30 used=3D24 fp=3D=
0x000000006ce6da86 flags=3D0x2ffff0000008101
[  262.957477] INFO: Object 0x000000005eb7e26b @offset=3D8 fp=3D0x0000000=
0ac807fa7

[  262.957480] Redzone 00000000b91cc681: 6e 73 2e 70 79 5c 22 2c         =
                 ns.py\",
[  262.957482] Object 000000005eb7e26b: 20 6c 69 6e 65 20 36 34 36 2c 20 =
69 6e 20 73 65   line 646, in se
[  262.957484] Object 000000007d5d4673: 6e 64 5c 6e 20 20 20 20 72 20 3d =
20 61 64 61 70  nd\n    r =3D adap
[  262.957485] Object 00000000a3cf6db1: 74 65 72 2e 73 65 6e 64 28 72 65 =
71 75 65 73 74  ter.send(request
[  262.957487] Object 00000000d8b14cdd: 2c 20 2a 2a 6b 77 61 72 00 00 00 =
00 00 00 00 00  , **kwar........
[  262.957489] Object 000000005eca0928: 40 97 5a 73 83 88 ff ff 25 00 00 =
00 00 00 00 80  @.Zs....%.......
[  262.957491] Object 00000000592ffbd7: 71 00 00 00 00 00 00 00 e0 c8 22 =
6d 83 88 ff ff  q........."m....
[  262.957492] Object 0000000084c88ae5: 00 00 00 00 00 00 00 00 00 00 00 =
00 00 00 00 00  ................
[  262.957494] Object 00000000ea6d1cb3: 83 00 00 00 00 00 00 00 80 c0 fd =
5a 83 88 ff ff  ...........Z....
[  262.957495] Object 00000000a236617c: 80 c0 fd 5a 83 88 ff ff 00 00 00 =
00 00 00 00 00  ...Z............
[  262.957497] Object 0000000091c7956c: 00 3a 94 b0 ff ff ff ff 75 00 00 =
00 00 00 00 00  .:......u.......
[  262.957499] Object 00000000216cef35: c0 85 cc 6a 83 88 ff ff 00 00 00 =
00 00 00 00 00  ...j............
[  262.957500] Object 00000000e0fd506c: 00 00 00 00 00 00 00 00 00 00 00 =
00 00 00 00 00  ................
[  262.957502] Redzone 00000000f5906e86: cc cc cc cc cc cc cc cc         =
                 ........
[  262.957503] Padding 0000000053d79574: 5a 5a 5a 5a 5a 5a 5a 5a         =
                 ZZZZZZZZ
[  262.957507] CPU: 3 PID: 11769 Comm: ps Kdump: loaded Tainted: G    B  =
    O      4.19.72_3upstreamdbg #1
[  262.957508] Hardware name: Xen HVM domU, BIOS 4.2.amazon 08/24/2006
[  262.957509] Call Trace:
[  262.957516]  dump_stack+0x9a/0xf0
[  262.957519]  check_bytes_and_report.cold.24+0x3f/0x6b
[  262.957521]  check_object+0x17c/0x280
[  262.957524]  free_debug_processing+0x105/0x2a0
[  262.957526]  ? qlist_free_all+0x37/0xd0
[  262.957527]  ? qlist_free_all+0x37/0xd0
[  262.957529]  __slab_free+0x218/0x3b0
[  262.957533]  ? __free_pages_ok+0x62f/0x840
[  262.957536]  ? _raw_spin_unlock_irqrestore+0x2b/0x40
[  262.957537]  ? qlist_free_all+0x37/0xd0
[  262.957541]  ? trace_hardirqs_on+0x35/0x140
[  262.957543]  ? qlist_free_all+0x37/0xd0
[  262.957544]  qlist_free_all+0x4c/0xd0
[  262.957546]  quarantine_reduce+0x1a2/0x210
[  262.957549]  ? getname_flags+0xba/0x510
[  262.957550]  kasan_kmalloc+0x95/0xc0
[  262.957553]  ? getname_flags+0xba/0x510
[  262.957555]  kmem_cache_alloc+0xc6/0x1d0
[  262.957557]  getname_flags+0xba/0x510
[  262.957561]  ? task_work_run+0xdf/0x180
[  262.957567]  do_sys_open+0x149/0x300
[  262.957572]  ? filp_open+0x50/0x50
[  262.957575]  ? do_syscall_64+0x18/0x290
[  262.957579]  do_syscall_64+0x9b/0x290
[  262.957583]  entry_SYSCALL_64_after_hwframe+0x49/0xbe
[  262.957586] RIP: 0033:0x7f5b8719e40e
[  262.957591] Code: 25 00 00 41 00 3d 00 00 41 00 74 48 48 8d 05 f9 62 0=
d 00 8b 00 85 c0 75 69 89 f2 b8 01 01 00 00 48 89 fe bf 9c ff ff ff 0f 05=
 <48> 3d 00 f0 ff ff 0f 87 a6 00 00 00 48 8b 4c 24 28 64 48 33 0c 25
[  262.957593] RSP: 002b:00007ffcec0bbac0 EFLAGS: 00000246 ORIG_RAX: 0000=
000000000101
[  262.957598] RAX: ffffffffffffffda RBX: 00007f5b8728e958 RCX: 00007f5b8=
719e40e
[  262.957599] RDX: 0000000000000000 RSI: 00007ffcec0bbb40 RDI: 00000000f=
fffff9c
[  262.957600] RBP: 00007f5b8728e950 R08: 00007f5b87288d46 R09: 00007ffce=
c0bb4b0
[  262.957602] R10: 0000000000000000 R11: 0000000000000246 R12: 00007ffce=
c0bbb40
[  262.957603] R13: 00000000007b4d90 R14: 0000000000000020 R15: 000000000=
0000000
[  262.957606] FIX vm_area_struct: Restoring 0x00000000b91cc681-0x0000000=
098bd5238=3D0xcc

[  262.957608] FIX vm_area_struct: Object at 0x000000005eb7e26b not freed
[  262.957612] kasan: CONFIG_KASAN_INLINE enabled
[  262.962707] kasan: GPF could be caused by NULL-ptr deref or user memor=
y access
[  262.973006] general protection fault: 0000 [#1] SMP KASAN PTI
[  262.978375] CPU: 3 PID: 11769 Comm: ps Kdump: loaded Tainted: G    B  =
    O      4.19.72_3upstreamdbg #1
[  262.987937] Hardware name: Xen HVM domU, BIOS 4.2.amazon 08/24/2006
[  262.993305] RIP: 0010:qlist_free_all+0x80/0xd0
[  262.996830] Code: df 48 85 db 75 db 48 89 f0 4c 01 f0 72 54 4c 89 fa 4=
8 2b 15 82 d0 5a 02 48 01 d0 48 c1 e8 0c 48 c1 e0 06 48 03 05 60 d0 5a 02=
 <48> 8b 50 08 48 8d 4a ff 83 e2 01 48 0f 45 c1 48 8b 78 18 eb a2 49
[  263.013354] RSP: 0018:ffff8882f3cefd48 EFLAGS: 00010203
[  263.017696] RAX: 00d0c45f95b9a580 RBX: 0000000000000000 RCX: ffffffffa=
e6cad40
[  263.023538] RDX: 0000777f80000000 RSI: 343620656e696c20 RDI: 000000000=
0000000
[  263.029706] RBP: 343620656e696c20 R08: ffffed106fd5be97 R09: ffffed106=
fd5be96
[  263.036338] R10: ffffed106fd5be96 R11: ffff88837eadf4b7 R12: ffffffffa=
e8edc17
[  263.042388] R13: ffff8882f3cefd80 R14: 0000000080000000 R15: ffffffff8=
0000000
[  263.048173] FS:  00007f5b870b1740(0000) GS:ffff88837eac0000(0000) knlG=
S:0000000000000000
[  263.054883] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  263.057753] CR2: 00000000007c0c68 CR3: 000000035b8b0005 CR4: 000000000=
01606e0
[  263.062110] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 000000000=
0000000
[  263.066477] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 000000000=
0000400
[  263.071453] Call Trace:
[  263.073312]  quarantine_reduce+0x1a2/0x210
[  263.076307]  ? getname_flags+0xba/0x510
[  263.078948]  kasan_kmalloc+0x95/0xc0
[  263.081357]  ? getname_flags+0xba/0x510
[  263.084200]  kmem_cache_alloc+0xc6/0x1d0
[  263.086942]  getname_flags+0xba/0x510
[  263.089460]  ? task_work_run+0xdf/0x180
[  263.092193]  do_sys_open+0x149/0x300
[  263.094717]  ? filp_open+0x50/0x50
[  263.097150]  ? do_syscall_64+0x18/0x290
[  263.099872]  do_syscall_64+0x9b/0x290
[  263.102388]  entry_SYSCALL_64_after_hwframe+0x49/0xbe
[  263.105832] RIP: 0033:0x7f5b8719e40e
[  263.108292] Code: 25 00 00 41 00 3d 00 00 41 00 74 48 48 8d 05 f9 62 0=
d 00 8b 00 85 c0 75 69 89 f2 b8 01 01 00 00 48 89 fe bf 9c ff ff ff 0f 05=
 <48> 3d 00 f0 ff ff 0f 87 a6 00 00 00 48 8b 4c 24 28 64 48 33 0c 25
[  263.121749] RSP: 002b:00007ffcec0bbac0 EFLAGS: 00000246 ORIG_RAX: 0000=
000000000101
[  263.126863] RAX: ffffffffffffffda RBX: 00007f5b8728e958 RCX: 00007f5b8=
719e40e
[  263.131685] RDX: 0000000000000000 RSI: 00007ffcec0bbb40 RDI: 00000000f=
fffff9c
[  263.136512] RBP: 00007f5b8728e950 R08: 00007f5b87288d46 R09: 00007ffce=
c0bb4b0
[  263.141399] R10: 0000000000000000 R11: 0000000000000246 R12: 00007ffce=
c0bbb40
[  263.146308] R13: 00000000007b4d90 R14: 0000000000000020 R15: 000000000=
0000000
[  263.151119] Modules linked in: xfrm6_mode_tunnel softdog vhost_net vho=
st tap openvswitch nsh xt_condition(O) xt_bpf xt_nfacct ipt_rpfilter bpfi=
lter nf_nat_sip nf_conntrack_sip nf_nat_h323 nf_conntrack_h323 ip6t_ipv6h=
eader ip6t_rt ip6t_eui64 ip6t_frag ip6t_mh ip6t_hbh ip6t_ah ip6t_REJECT n=
f_reject_ipv6 ip6table_mangle ip6table_raw ip6table_filter ip6_tables ebt=
_ip6 ip_set_hash_net ip_set_hash_ip ip_set xt_u32 xt_time xt_tcpmss xt_st=
ring xt_statistic xt_state xt_realm xt_quota xt_policy xt_pkttype xt_phys=
dev xt_multiport xt_mac xt_limit xt_length xt_iprange xt_helper xt_esp xt=
_dscp xt_dccp xt_conntrack xt_connlimit nf_conncount xt_connbytes xt_comm=
ent xt_cluster xt_TRACE xt_TCPOPTSTRIP xt_TCPMSS xt_NFQUEUE xt_NFLOG xt_L=
OG xt_HL xt_DSCP xt_CT xt_CLASSIFY sch_tbf sch_sfb sch_red sch_qfq sch_pr=
io sch_mqprio
[  263.203404]  sch_ingress sch_htb sch_gred sch_choke sch_cbq nfnetlink_=
cttimeout nf_nat_tftp nf_nat_snmp_basic asn1_decoder nf_nat_pptp nf_nat_p=
roto_gre nf_nat_irc nf_nat_ipv6 nf_nat_ftp nf_nat_amanda nf_conntrack_tft=
p nf_conntrack_snmp nf_conntrack_sane nf_conntrack_pptp nf_conntrack_prot=
o_gre nf_conntrack_netlink nf_conntrack_netbios_ns nf_conntrack_irc nf_co=
nntrack_ftp nf_conntrack_broadcast ts_kmp nf_conntrack_amanda iptable_raw=
 iptable_nat iptable_mangle iptable_filter ipt_ah ipt_REJECT ipt_MASQUERA=
DE ipt_ECN ipt_CLUSTERIP ipip ifb em_u32 em_text em_nbyte em_meta em_cmp =
ebtable_nat ebtable_filter ebtable_broute ebtables ebt_vlan ebt_stp ebt_s=
nat ebt_redirect ebt_pkttype ebt_nflog ebt_mark_m ebt_mark ebt_log ebt_li=
mit ebt_ip ebt_dnat ebt_arpreply ebt_arp ebt_among ebt_802_3 cls_u32 cls_=
tcindex
[  263.257550]  cls_route cls_fw cls_cgroup cls_basic arptable_filter arp=
t_mangle arp_tables act_police act_pedit act_nat act_mirred act_ipt act_g=
act pcc_cpufreq crct10dif_pclmul crc32_pclmul ghash_clmulni_intel ixgbevf=
 i2c_piix4 intel_rapl_perf
[  263.273126] ---[ end trace 4a14396e6b248e3f ]---
[  263.276936] RIP: 0010:qlist_free_all+0x80/0xd0
[  263.280735] Code: df 48 85 db 75 db 48 89 f0 4c 01 f0 72 54 4c 89 fa 4=
8 2b 15 82 d0 5a 02 48 01 d0 48 c1 e8 0c 48 c1 e0 06 48 03 05 60 d0 5a 02=
 <48> 8b 50 08 48 8d 4a ff 83 e2 01 48 0f 45 c1 48 8b 78 18 eb a2 49
[  263.297123] RSP: 0018:ffff8882f3cefd48 EFLAGS: 00010203
[  263.301935] RAX: 00d0c45f95b9a580 RBX: 0000000000000000 RCX: ffffffffa=
e6cad40
[  263.307822] RDX: 0000777f80000000 RSI: 343620656e696c20 RDI: 000000000=
0000000
[  263.313679] RBP: 343620656e696c20 R08: ffffed106fd5be97 R09: ffffed106=
fd5be96
[  263.319433] R10: ffffed106fd5be96 R11: ffff88837eadf4b7 R12: ffffffffa=
e8edc17
[  263.325115] R13: ffff8882f3cefd80 R14: 0000000080000000 R15: ffffffff8=
0000000
[  263.330946] FS:  00007f5b870b1740(0000) GS:ffff88837eac0000(0000) knlG=
S:0000000000000000
[  263.337597] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  263.342332] CR2: 00000000007c0c68 CR3: 000000035b8b0005 CR4: 000000000=
01606e0
[  263.347350] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 000000000=
0000000
[  263.352227] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 000000000=
0000400
(...)
[  307.139653] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D
[  307.144271] BUG names_cache (Tainted: G    B D    O     ): Redzone ove=
rwritten
[  307.148280] ----------------------------------------------------------=
-------------------

[  307.153261] INFO: 0x000000001d2ecfa4-0x000000002a22a890. First byte 0x=
6e instead of 0xcc
[  307.157848] INFO: Allocated in getname_flags+0xba/0x510 age=3D4369 cpu=
=3D0 pid=3D11772
[  307.161947] 	kmem_cache_alloc+0x1a4/0x1d0
[  307.164241] 	getname_flags+0xba/0x510
[  307.166368] 	user_path_at_empty+0x1d/0x40
[  307.168701] 	vfs_statx+0xb9/0x140
[  307.170717] 	__se_sys_newstat+0x7c/0xd0
[  307.172982] 	do_syscall_64+0x9b/0x290
[  307.175125] 	entry_SYSCALL_64_after_hwframe+0x49/0xbe
[  307.177979] INFO: Freed in qlist_free_all+0x37/0xd0 age=3D4370 cpu=3D0=
 pid=3D11772
[  307.182209] 	quarantine_reduce+0x1a2/0x210
[  307.184868] 	kasan_kmalloc+0x95/0xc0
[  307.187184] 	kmem_cache_alloc+0xc6/0x1d0
[  307.189732] 	getname_flags+0xba/0x510
[  307.192068] 	user_path_at_empty+0x1d/0x40
[  307.194650] 	vfs_statx+0xb9/0x140
[  307.196821] 	__se_sys_newstat+0x7c/0xd0
[  307.199406] 	do_syscall_64+0x9b/0x290
[  307.201916] 	entry_SYSCALL_64_after_hwframe+0x49/0xbe
[  307.205643] INFO: Slab 0x00000000071e61e6 objects=3D7 used=3D6 fp=3D0x=
00000000ae2f1e0c flags=3D0x2ffff0000008101
[  307.212340] INFO: Object 0x0000000029ff60d9 @offset=3D64 fp=3D0x000000=
00525e3571

[  307.217672] Redzone 000000001d2ecfa4: 6e 73 2e 70 79 5c 22 2c 20 6c 69=
 6e 65 20 36 34  ns.py\", line 64
[  307.224248] Redzone 0000000019afa6b8: 36 2c 20 69 6e 20 73 65 6e 64 5c=
 6e 20 20 20 20  6, in send\n
[  307.230709] Redzone 000000006e1958f4: 72 20 3d 20 61 64 61 70 74 65 72=
 2e 73 65 6e 64  r =3D adapter.send
[  307.237255] Redzone 000000002cfdad55: 28 72 65 71 75 65 73 74 2c 20 2a=
 2a 6b 77 61 72  (request, **kwar
[  307.243769] Object 0000000029ff60d9: 40 47 9e 5c 83 88 ff ff 40 be 77 =
02 00 00 00 00  @G.\....@.w.....
[  307.249758] Object 000000007c05b8ad: 00 00 00 00 6b 6b 6b 6b 00 00 00 =
00 00 00 00 00  ....kkkk........
[  307.256292] Object 000000003c27c064: 2f 6f 70 74 2f 4f 53 41 47 70 6d =
6f 6e 2f 6c 69  /opt/OSAGpmon/li
[  307.262715] Object 0000000069f20b8f: 62 2f 4e 65 74 2f 49 50 2e 70 6d =
00 00 00 00 00  b/Net/IP.pm.....
[  307.269096] Object 0000000042d7882f: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  307.275649] Object 000000003b7b6941: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  307.282184] Object 00000000fe5ff8f2: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  307.288430] Object 00000000b56d40c9: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  307.294531] Object 000000002fe598b6: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  307.300656] Object 00000000d0e72570: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  307.307338] Object 000000002d3efd2e: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  307.315481] Object 000000009dd4b99f: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  307.323242] Object 00000000b1feef78: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  307.330056] Object 00000000f3960085: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  307.336504] Object 000000001e37161a: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  307.342602] Object 00000000f2d92361: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  307.348767] Object 0000000022351192: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  307.355124] Object 000000008f893258: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  307.361220] Object 00000000300b78fd: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  307.367426] Object 0000000051f24bbb: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  307.373756] Object 0000000083bde3d9: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  307.381097] Object 00000000d9d100b5: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  307.387323] Object 000000003ee0873d: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  307.393653] Object 00000000b64903d5: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  307.401595] Object 000000007225d6f3: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  307.408112] Object 000000006b53efc1: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  307.414222] Object 0000000012fbc488: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  307.420396] Object 00000000e9eb9844: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  307.428116] Object 0000000086e41de1: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  307.436173] Object 0000000076a949df: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  307.444604] Object 00000000ae0dec44: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  307.452689] Object 00000000024ab661: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  307.460856] Object 000000009d475ad2: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  307.468905] Object 0000000004f78267: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  307.477688] Object 00000000e62ff8d1: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  307.485703] Object 0000000088713e3d: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  307.493726] Object 00000000a9368135: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  307.501817] Object 0000000082deba41: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  307.509904] Object 00000000a24e7af2: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  307.517934] Object 0000000040003803: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  307.525979] Object 00000000a2d4c4a9: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  307.533997] Object 00000000a3a52870: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  307.541982] Object 00000000153363bf: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  307.549942] Object 000000004b1b9728: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  307.558003] Object 0000000022ccf740: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  307.566045] Object 00000000c6a2f5f4: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  307.574123] Object 000000001c530041: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  307.582196] Object 00000000ba1b837e: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  307.590212] Object 00000000fe934652: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  307.598331] Object 000000009476ecd2: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  307.606470] Object 00000000ee346717: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  307.614376] Object 000000007563dd22: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  307.621238] Object 00000000fbd95e3d: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  307.628105] Object 00000000874d57b7: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  307.634921] Object 000000009e0be854: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  307.641773] Object 00000000aa9680fb: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  307.648657] Object 00000000e80633ec: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  307.655444] Object 00000000b3a18cc5: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  307.662269] Object 0000000036e19b64: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  307.669088] Object 0000000077e05b9a: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  307.676005] Object 0000000019cbaed8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  307.682852] Object 00000000592919ad: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  307.689780] Object 00000000652ca9d1: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  307.696800] Object 00000000fda2e9a4: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  307.703630] Object 000000009ea088da: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  307.710480] Object 0000000013bb8ffa: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  307.717387] Object 00000000ebb31e93: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  307.724205] Object 00000000f31cebb6: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  307.732212] Object 00000000a2e4af58: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  307.740342] Object 000000005efc4cfb: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  307.747979] Object 0000000073a79836: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  307.756064] Object 00000000f1663642: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  307.764114] Object 000000005a097483: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  307.772008] Object 00000000bc9a0c5f: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  307.780047] Object 0000000037ca3439: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  307.786894] Object 000000004df4ccd1: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  307.793755] Object 00000000cde4c3c2: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  307.800552] Object 00000000e730bcee: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  307.807421] Object 000000006a7d069a: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  307.815464] Object 00000000dc6f6590: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  307.822919] Object 000000008d19ed7c: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  307.830687] Object 000000004aba5612: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  307.838612] Object 00000000cc236d40: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  307.846975] Object 000000008275e651: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  307.855551] Object 0000000022faf866: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  307.864022] Object 0000000070b4fe4c: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  307.870877] Object 0000000086063d4f: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  307.878416] Object 00000000d7cdd269: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  307.887649] Object 0000000012abb3eb: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  307.895043] Object 00000000a0329c09: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  307.902654] Object 00000000882c68e9: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  307.910384] Object 00000000ef755419: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  307.918119] Object 00000000eaf8f566: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  307.925558] Object 00000000feb8be05: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  307.933123] Object 00000000a07f00c7: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  307.941017] Object 00000000693a9d80: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  307.953833] Object 00000000ec229757: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  307.961361] Object 000000003fe74859: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  307.969075] Object 00000000a422ae4e: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  307.975915] Object 000000002b80a221: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  307.982797] Object 0000000083a42691: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  307.989635] Object 0000000097449cf3: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  307.996504] Object 0000000021147164: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.003350] Object 0000000013335dbc: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.010239] Object 00000000dfa8618b: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.017095] Object 00000000e26536ea: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.023986] Object 00000000a9f298b3: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.030890] Object 000000004dcb65bb: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.037862] Object 000000006041ee03: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.045170] Object 00000000571fd7ec: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.052061] Object 00000000583dd3a2: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.060974] Object 00000000ac33937d: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.067829] Object 0000000037662654: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.075295] Object 0000000047c841c9: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.083844] Object 00000000ef60d38f: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.091958] Object 00000000f043240b: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.098780] Object 00000000ad763686: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.105635] Object 00000000b7d1e0c4: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.112560] Object 0000000003347ab7: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.119321] Object 0000000007e52a79: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.126062] Object 00000000c7ee1536: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.132848] Object 00000000e3c3094a: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.139619] Object 00000000d72b0624: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.146854] Object 0000000085f9114e: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.153566] Object 000000001901d21c: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.160309] Object 00000000b20f5e25: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.167099] Object 000000009850bf02: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.173961] Object 00000000af5143ca: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.180853] Object 00000000cbfdf629: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.187633] Object 00000000409e66fb: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.194468] Object 0000000037542b18: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.201534] Object 00000000058241f4: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.208272] Object 0000000073222e4a: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.215004] Object 000000004e4ff23d: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.221848] Object 00000000154b9b5f: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.228584] Object 00000000ed6f9f66: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.235346] Object 000000000709958f: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.242062] Object 00000000b04313b8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.248979] Object 00000000d29c7775: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.255889] Object 00000000230a81f7: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.262690] Object 00000000ff8bd575: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.269554] Object 000000000db07b7f: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.276395] Object 000000004f9c6f00: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.283194] Object 00000000b2a3f813: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.290031] Object 00000000f80a8072: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.296802] Object 000000005cf9aa70: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.304413] Object 00000000cad72b3d: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.311881] Object 00000000225a9dd1: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.320033] Object 0000000076518ab0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.327632] Object 000000007f06b351: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.337496] Object 00000000b1e88291: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.344849] Object 000000000bff1356: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.353320] Object 00000000f26ec2ae: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.361880] Object 00000000a5cb3e10: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.370304] Object 0000000087b9cb6e: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.377455] Object 000000005cabfb1a: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.384257] Object 00000000e4da7e25: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.391131] Object 000000004a1005ec: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.397947] Object 0000000047359d40: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.404711] Object 000000002555b160: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.411481] Object 00000000b37e4f34: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.418330] Object 0000000069528973: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.425197] Object 00000000689e0945: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.431976] Object 00000000e1d4851b: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.438799] Object 00000000ba28a1a4: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.445700] Object 00000000dc4e0d71: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.452609] Object 0000000064c16b40: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.459400] Object 0000000002b2836a: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.466283] Object 0000000064cccaf3: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.473111] Object 00000000ce66295b: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.479921] Object 00000000b0fce3a1: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.486764] Object 00000000d953cf2a: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.493599] Object 0000000032971099: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.500397] Object 000000004cb051cc: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.507233] Object 0000000045a7e834: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.514025] Object 000000009abf3009: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.520834] Object 0000000075ed740d: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.527662] Object 000000003d1f2f4c: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.534523] Object 000000003cc7f3f6: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.541456] Object 00000000d3f918d5: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.548388] Object 00000000df9307ab: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.555254] Object 00000000f93826b4: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.562085] Object 000000005fb343a8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.568936] Object 000000005dad0b94: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.575929] Object 0000000003049af0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.582788] Object 000000005831a996: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.589553] Object 0000000043da6189: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.596410] Object 0000000017326f98: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.603213] Object 00000000dd270209: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.609942] Object 00000000f745f437: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.617496] Object 000000008822777a: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.625284] Object 000000002cf552d7: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.632825] Object 000000007f7f0498: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.640889] Object 000000001034683d: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.649000] Object 000000007b46d828: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.656874] Object 000000004e055246: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.664988] Object 0000000042074305: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.673053] Object 000000005203f3d2: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.681042] Object 00000000c5ff3bf1: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.689142] Object 0000000089e53bd0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.697233] Object 0000000056b9686e: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.707172] Object 00000000c292b303: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.715207] Object 00000000fb7177f7: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.723360] Object 00000000c4959417: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.731267] Object 0000000045790fe1: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.739313] Object 00000000aeba7e4d: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.747457] Object 000000002e7ebce9: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.755312] Object 000000004f25d974: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.763556] Object 00000000760cc051: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.771686] Object 000000005f2ac704: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.779627] Object 000000000a6a6b41: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.787690] Object 0000000074580d46: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.795825] Object 00000000b47fba88: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.803762] Object 00000000bc73dc78: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.811778] Object 00000000b776e10b: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.819909] Object 0000000036725f6c: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.827832] Object 000000004790848d: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.835918] Object 000000006d2afa17: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.844035] Object 000000008faea528: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.851997] Object 00000000da0ada39: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.860093] Object 00000000418c8207: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.868229] Object 00000000bfc37df8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.876277] Object 000000007029bbc3: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.884360] Object 00000000849badd8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.893050] Object 000000005b3619d4: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.901062] Object 000000008bbb001e: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.909058] Object 00000000eeb5b28a: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.917211] Object 00000000d5ae2a95: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.925273] Object 0000000030985d80: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.933359] Object 0000000053480c8c: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.941546] Object 000000005b33e767: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.949484] Object 00000000939af4b5: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.957573] Object 000000001f4a95d2: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.965802] Object 00000000d9aa53ba: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.973943] Object 0000000055b3b900: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.982142] Object 00000000eac6cc50: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.990794] Object 00000000550f2266: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  308.999072] Object 00000000e7974ad7: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  309.007861] Object 000000002d394c40: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  309.016075] Object 000000008c50910a: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  309.024478] Object 000000002d60db08: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  309.032926] Object 00000000f4c4160d: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  309.041336] Object 00000000c027146c: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  309.049650] Object 00000000c7da39ef: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  309.057711] Object 00000000d0ad21e0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  309.065845] Object 00000000f809ef6b: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  309.073819] Object 00000000d4cc2cd0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  309.081963] Object 00000000445d6b05: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  309.089909] Object 00000000f991101d: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  309.097788] Object 00000000de83d96c: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  309.105866] Object 00000000fa2acbfa: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  309.114022] Object 0000000016b28d35: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  309.121712] Object 00000000580f966c: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  309.129805] Object 000000000153cb7b: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  309.137960] Object 0000000088fcbc6c: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  309.145534] Object 0000000093987c62: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b a5  kkkkkkkkkkkkkkk.
[  309.153683] Redzone 0000000057ed140d: cc cc cc cc cc cc cc cc         =
                 ........
[  309.161265] Padding 000000005a9b402c: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a=
 5a 5a 5a 5a 5a  ZZZZZZZZZZZZZZZZ
[  309.169393] Padding 00000000f67c467d: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a=
 5a 5a 5a 5a 5a  ZZZZZZZZZZZZZZZZ
[  309.177451] Padding 000000006b61ac26: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a=
 5a 5a 5a 5a 5a  ZZZZZZZZZZZZZZZZ
[  309.185591] CPU: 1 PID: 6003 Comm: redis-server Kdump: loaded Tainted:=
 G    B D    O      4.19.72_3upstreamdbg #1
[  309.194668] Hardware name: Xen HVM domU, BIOS 4.2.amazon 08/24/2006
[  309.199561] Call Trace:
[  309.201678]  dump_stack+0x9a/0xf0
[  309.204456]  check_bytes_and_report.cold.24+0x3f/0x6b
[  309.208554]  check_object+0x17c/0x280
[  309.211583]  free_debug_processing+0x105/0x2a0
[  309.215204]  ? qlist_free_all+0x37/0xd0
[  309.218357]  ? qlist_free_all+0x37/0xd0
[  309.221504]  __slab_free+0x218/0x3b0
[  309.224450]  ? __free_pages_ok+0x62f/0x840
[  309.227804]  ? _raw_spin_unlock_irqrestore+0x2b/0x40
[  309.231834]  ? qlist_free_all+0x37/0xd0
[  309.234996]  ? trace_hardirqs_on+0x35/0x140
[  309.238440]  ? qlist_free_all+0x37/0xd0
[  309.241607]  qlist_free_all+0x4c/0xd0
[  309.244682]  quarantine_reduce+0x1a2/0x210
[  309.248101]  ? getname_flags+0xba/0x510
[  309.251282]  kasan_kmalloc+0x95/0xc0
[  309.254298]  ? getname_flags+0xba/0x510
[  309.257467]  kmem_cache_alloc+0xc6/0x1d0
[  309.260690]  getname_flags+0xba/0x510
[  309.263805]  do_sys_open+0x149/0x300
[  309.266760]  ? filp_open+0x50/0x50
[  309.269591]  ? do_syscall_64+0x18/0x290
[  309.272773]  do_syscall_64+0x9b/0x290
[  309.275909]  entry_SYSCALL_64_after_hwframe+0x49/0xbe
[  309.280046] RIP: 0033:0x7fd116808b7e
[  309.283065] Code: 89 54 24 08 e8 a3 f4 ff ff 8b 74 24 0c 48 8b 3c 24 4=
1 89 c0 44 8b 54 24 08 b8 01 01 00 00 89 f2 48 89 fe bf 9c ff ff ff 0f 05=
 <48> 3d 00 f0 ff ff 77 30 44 89 c7 89 44 24 08 e8 ce f4 ff ff 8b 44
[  309.299289] RSP: 002b:00007ffd93eb6030 EFLAGS: 00000293 ORIG_RAX: 0000=
000000000101
[  309.305350] RAX: ffffffffffffffda RBX: 0000000000000001 RCX: 00007fd11=
6808b7e
[  309.311030] RDX: 0000000000000000 RSI: 00007ffd93eb60a0 RDI: 00000000f=
fffff9c
[  309.316797] RBP: 0000000000000000 R08: 0000000000000000 R09: 000000000=
0000006
[  309.322349] R10: 0000000000000000 R11: 0000000000000293 R12: 000000000=
0001000
[  309.328059] R13: 0000000000000002 R14: 00007fd116222080 R15: 000000000=
0000001
[  309.333764] FIX names_cache: Restoring 0x000000001d2ecfa4-0x000000002a=
22a890=3D0xcc

[  309.341073] FIX names_cache: Object at 0x0000000029ff60d9 not freed
[  313.708858] eth1: dropped over-mtu packet: 1612 > 1500
[  315.307429] eth1: dropped over-mtu packet: 2515 > 1500
[  320.378201] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D
[  320.383907] BUG vm_area_struct (Tainted: G    B D    O     ): Redzone =
overwritten
[  320.388905] ----------------------------------------------------------=
-------------------

[  320.394971] INFO: 0x00000000c07ff6f2-0x00000000922a1eef. First byte 0x=
6e instead of 0xcc
[  320.400704] INFO: Allocated in vm_area_dup+0x1e/0x180 age=3D4236 cpu=3D=
3 pid=3D8727
[  320.405838] 	kmem_cache_alloc+0x1a4/0x1d0
[  320.408727] 	vm_area_dup+0x1e/0x180
[  320.411223] 	copy_process.part.4+0x2fa9/0x6cd0
[  320.414277] 	_do_fork+0x151/0x7a0
[  320.416538] 	do_syscall_64+0x9b/0x290
[  320.419068] 	entry_SYSCALL_64_after_hwframe+0x49/0xbe
[  320.422569] INFO: Freed in qlist_free_all+0x37/0xd0 age=3D4608 cpu=3D0=
 pid=3D11841
[  320.427782] 	quarantine_reduce+0x1a2/0x210
[  320.430698] 	kasan_kmalloc+0x95/0xc0
[  320.433246] 	kmem_cache_alloc+0xc6/0x1d0
[  320.435966] 	vm_area_alloc+0x1b/0xf0
[  320.438305] 	mmap_region+0x580/0x1190
[  320.440673] 	do_mmap+0x675/0xe20
[  320.444058] 	vm_mmap_pgoff+0x163/0x1b0
[  320.446515] 	ksys_mmap_pgoff+0x23e/0x590
[  320.449162] 	do_syscall_64+0x9b/0x290
[  320.451625] 	entry_SYSCALL_64_after_hwframe+0x49/0xbe
[  320.454960] INFO: Slab 0x00000000017620bc objects=3D30 used=3D7 fp=3D0=
x0000000035357a9a flags=3D0x2ffff0000008101
[  320.461606] INFO: Object 0x000000004f79ecae @offset=3D8 fp=3D0x0000000=
00da6908e

[  320.466679] Redzone 00000000c07ff6f2: 6e 73 2e 70 79 5c 22 2c         =
                 ns.py\",
[  320.472736] Object 000000004f79ecae: 20 6c 69 6e 65 20 36 34 36 2c 20 =
69 6e 20 73 65   line 646, in se
[  320.479647] Object 0000000037f06e68: 6e 64 5c 6e 20 20 20 20 72 20 3d =
20 61 64 61 70  nd\n    r =3D adap
[  320.486250] Object 00000000787a17aa: 74 65 72 2e 73 65 6e 64 28 72 65 =
71 75 65 73 74  ter.send(request
[  320.492925] Object 000000004e0d15b6: 2c 20 2a 2a 6b 77 61 72 00 00 00 =
00 00 00 00 00  , **kwar........
[  320.499449] Object 000000009bdfffbc: 00 f9 f9 3d 83 88 ff ff 25 00 00 =
00 00 00 00 80  ...=3D....%.......
[  320.508725] Object 00000000a1744f46: 71 00 00 00 00 00 00 00 c0 86 64 =
72 83 88 ff ff  q.........dr....
[  320.515302] Object 0000000025612fc3: 00 00 00 00 00 00 00 00 00 00 00 =
00 00 00 00 00  ................
[  320.521944] Object 00000000c7e51536: 01 00 00 00 00 00 00 00 80 c0 34 =
62 83 88 ff ff  ..........4b....
[  320.528711] Object 00000000c60fa612: 80 c0 34 62 83 88 ff ff 00 00 00 =
00 00 00 00 00  ..4b............
[  320.535411] Object 0000000069262720: 00 3a 94 b0 ff ff ff ff 00 00 00 =
00 00 00 00 00  .:..............
[  320.542063] Object 00000000acc3bec2: 40 21 af 63 83 88 ff ff 00 00 00 =
00 00 00 00 00  @!.c............
[  320.548806] Object 0000000021f1d4e2: 00 00 00 00 00 00 00 00 00 00 00 =
00 00 00 00 00  ................
[  320.555363] Redzone 000000006f8ed805: cc cc cc cc cc cc cc cc         =
                 ........
[  320.561546] Padding 00000000abbb7ef9: 5a 5a 5a 5a 5a 5a 5a 5a         =
                 ZZZZZZZZ
[  320.567794] CPU: 2 PID: 12306 Comm: ssh_to_self.sh Kdump: loaded Taint=
ed: G    B D    O      4.19.72_3upstreamdbg #1
[  320.575622] Hardware name: Xen HVM domU, BIOS 4.2.amazon 08/24/2006
[  320.579747] Call Trace:
[  320.581411]  dump_stack+0x9a/0xf0
[  320.583692]  check_bytes_and_report.cold.24+0x3f/0x6b
[  320.587121]  check_object+0x17c/0x280
[  320.589672]  free_debug_processing+0x105/0x2a0
[  320.592796]  ? qlist_free_all+0x37/0xd0
[  320.595353]  ? qlist_free_all+0x37/0xd0
[  320.597909]  __slab_free+0x218/0x3b0
[  320.600262]  ? _raw_spin_unlock_irqrestore+0x2b/0x40
[  320.603539]  ? qlist_free_all+0x37/0xd0
[  320.606123]  ? trace_hardirqs_on+0x35/0x140
[  320.608957]  ? qlist_free_all+0x37/0xd0
[  320.611603]  qlist_free_all+0x4c/0xd0
[  320.614192]  quarantine_reduce+0x1a2/0x210
[  320.617110]  ? vm_area_alloc+0x1b/0xf0
[  320.619731]  kasan_kmalloc+0x95/0xc0
[  320.622218]  ? vm_area_alloc+0x1b/0xf0
[  320.624775]  kmem_cache_alloc+0xc6/0x1d0
[  320.627391]  vm_area_alloc+0x1b/0xf0
[  320.629809]  mmap_region+0x580/0x1190
[  320.632283]  ? vm_brk+0x10/0x10
[  320.634519]  ? security_mmap_addr+0x3f/0x70
[  320.637357]  ? get_unmapped_area+0x1c7/0x350
[  320.640333]  do_mmap+0x675/0xe20
[  320.642536]  ? ecryptfs_fill_auth_tok+0x310/0x310
[  320.645701]  ? security_mmap_file+0xcc/0x140
[  320.648564]  vm_mmap_pgoff+0x163/0x1b0
[  320.651087]  ? vma_is_stack_for_current+0x90/0x90
[  320.654261]  ? do_dup2+0x3f0/0x3f0
[  320.656610]  ? vfs_statx_fd+0x44/0x80
[  320.659136]  ? __se_sys_newfstat+0xba/0xd0
[  320.661984]  ksys_mmap_pgoff+0x23e/0x590
[  320.664775]  ? find_mergeable_anon_vma+0x280/0x280
[  320.667948]  ? trace_hardirqs_off_caller+0x3b/0x140
[  320.671172]  ? do_syscall_64+0x18/0x290
[  320.673934]  do_syscall_64+0x9b/0x290
[  320.676398]  entry_SYSCALL_64_after_hwframe+0x49/0xbe
[  320.679836] RIP: 0033:0x7f6a0347c5a3
[  320.682557] Code: 54 41 89 d4 55 48 89 fd 53 4c 89 cb 48 85 ff 74 4e 4=
9 89 d9 45 89 f8 45 89 f2 44 89 e2 4c 89 ee 48 89 ef b8 09 00 00 00 0f 05=
 <48> 3d 00 f0 ff ff 77 65 5b 5d 41 5c 41 5d 41 5e 41 5f c3 66 2e 0f
[  320.697479] RSP: 002b:00007ffc21a28e18 EFLAGS: 00000246 ORIG_RAX: 0000=
000000000009
[  320.702540] RAX: ffffffffffffffda RBX: 0000000000000000 RCX: 00007f6a0=
347c5a3
[  320.707497] RDX: 0000000000000001 RSI: 00000000000085c4 RDI: 000000000=
0000000
[  320.712463] RBP: 0000000000000000 R08: 0000000000000004 R09: 000000000=
0000000
[  320.717185] R10: 0000000000000002 R11: 0000000000000246 R12: 000000000=
0000001
[  320.722031] R13: 00000000000085c4 R14: 0000000000000002 R15: 000000000=
0000004
[  320.726842] FIX vm_area_struct: Restoring 0x00000000c07ff6f2-0x0000000=
0922a1eef=3D0xcc

[  320.732784] FIX vm_area_struct: Object at 0x000000004f79ecae not freed
[  320.737953] kasan: CONFIG_KASAN_INLINE enabled
[  320.741662] kasan: GPF could be caused by NULL-ptr deref or user memor=
y access
[  320.747529] general protection fault: 0000 [#2] SMP KASAN PTI
[  320.752324] CPU: 2 PID: 12306 Comm: ssh_to_self.sh Kdump: loaded Taint=
ed: G    B D    O      4.19.72_3upstreamdbg #1
[  320.762087] Hardware name: Xen HVM domU, BIOS 4.2.amazon 08/24/2006
[  320.767338] RIP: 0010:qlist_free_all+0x80/0xd0
[  320.771141] Code: df 48 85 db 75 db 48 89 f0 4c 01 f0 72 54 4c 89 fa 4=
8 2b 15 82 d0 5a 02 48 01 d0 48 c1 e8 0c 48 c1 e0 06 48 03 05 60 d0 5a 02=
 <48> 8b 50 08 48 8d 4a ff 83 e2 01 48 0f 45 c1 48 8b 78 18 eb a2 49
[  320.787525] RSP: 0018:ffff888375c9fb00 EFLAGS: 00010203
[  320.791949] RAX: 00d0c45f95b9a580 RBX: 0000000000000000 RCX: ffffffffb=
03cd983
[  320.797841] RDX: 0000777f80000000 RSI: 343620656e696c20 RDI: 000000000=
0000000
[  320.803963] RBP: 343620656e696c20 R08: fffffbfff64886ed R09: fffffbfff=
64886ec
[  320.809897] R10: fffffbfff64886ec R11: 0000000000000003 R12: ffffffffa=
e8edc17
[  320.815595] R13: ffff888375c9fb38 R14: 0000000080000000 R15: ffffffff8=
0000000
[  320.820564] FS:  0000000000000000(0000) GS:ffff88837ea80000(0000) knlG=
S:0000000000000000
[  320.826646] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  320.830822] CR2: 00007ffc21a28fa4 CR3: 000000035c05a003 CR4: 000000000=
01606e0
[  320.836025] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 000000000=
0000000
[  320.841145] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 000000000=
0000400
[  320.846493] Call Trace:
[  320.848419]  quarantine_reduce+0x1a2/0x210
[  320.851531]  ? vm_area_alloc+0x1b/0xf0
[  320.854182]  kasan_kmalloc+0x95/0xc0
[  320.856560]  ? vm_area_alloc+0x1b/0xf0
[  320.859093]  kmem_cache_alloc+0xc6/0x1d0
[  320.861728]  vm_area_alloc+0x1b/0xf0
[  320.864206]  mmap_region+0x580/0x1190
[  320.866728]  ? vm_brk+0x10/0x10
[  320.868919]  ? security_mmap_addr+0x3f/0x70
[  320.871809]  ? get_unmapped_area+0x1c7/0x350
[  320.874751]  do_mmap+0x675/0xe20
[  320.876934]  ? ecryptfs_fill_auth_tok+0x310/0x310
[  320.880110]  ? security_mmap_file+0xcc/0x140
[  320.882949]  vm_mmap_pgoff+0x163/0x1b0
[  320.885571]  ? vma_is_stack_for_current+0x90/0x90
[  320.888794]  ? do_dup2+0x3f0/0x3f0
[  320.891225]  ? vfs_statx_fd+0x44/0x80
[  320.893791]  ? __se_sys_newfstat+0xba/0xd0
[  320.896672]  ksys_mmap_pgoff+0x23e/0x590
[  320.899360]  ? find_mergeable_anon_vma+0x280/0x280
[  320.902816]  ? trace_hardirqs_off_caller+0x3b/0x140
[  320.905843]  ? do_syscall_64+0x18/0x290
[  320.908184]  do_syscall_64+0x9b/0x290
[  320.910453]  entry_SYSCALL_64_after_hwframe+0x49/0xbe
[  320.914018] RIP: 0033:0x7f6a0347c5a3
[  320.916544] Code: 54 41 89 d4 55 48 89 fd 53 4c 89 cb 48 85 ff 74 4e 4=
9 89 d9 45 89 f8 45 89 f2 44 89 e2 4c 89 ee 48 89 ef b8 09 00 00 00 0f 05=
 <48> 3d 00 f0 ff ff 77 65 5b 5d 41 5c 41 5d 41 5e 41 5f c3 66 2e 0f
[  320.929816] RSP: 002b:00007ffc21a28e18 EFLAGS: 00000246 ORIG_RAX: 0000=
000000000009
[  320.934899] RAX: ffffffffffffffda RBX: 0000000000000000 RCX: 00007f6a0=
347c5a3
[  320.939780] RDX: 0000000000000001 RSI: 00000000000085c4 RDI: 000000000=
0000000
[  320.944638] RBP: 0000000000000000 R08: 0000000000000004 R09: 000000000=
0000000
[  320.949315] R10: 0000000000000002 R11: 0000000000000246 R12: 000000000=
0000001
[  320.954102] R13: 00000000000085c4 R14: 0000000000000002 R15: 000000000=
0000004
[  320.958769] Modules linked in: xfrm6_mode_tunnel softdog vhost_net vho=
st tap openvswitch nsh xt_condition(O) xt_bpf xt_nfacct ipt_rpfilter bpfi=
lter nf_nat_sip nf_conntrack_sip nf_nat_h323 nf_conntrack_h323 ip6t_ipv6h=
eader ip6t_rt ip6t_eui64 ip6t_frag ip6t_mh ip6t_hbh ip6t_ah ip6t_REJECT n=
f_reject_ipv6 ip6table_mangle ip6table_raw ip6table_filter ip6_tables ebt=
_ip6 ip_set_hash_net ip_set_hash_ip ip_set xt_u32 xt_time xt_tcpmss xt_st=
ring xt_statistic xt_state xt_realm xt_quota xt_policy xt_pkttype xt_phys=
dev xt_multiport xt_mac xt_limit xt_length xt_iprange xt_helper xt_esp xt=
_dscp xt_dccp xt_conntrack xt_connlimit nf_conncount xt_connbytes xt_comm=
ent xt_cluster xt_TRACE xt_TCPOPTSTRIP xt_TCPMSS xt_NFQUEUE xt_NFLOG xt_L=
OG xt_HL xt_DSCP xt_CT xt_CLASSIFY sch_tbf sch_sfb sch_red sch_qfq sch_pr=
io sch_mqprio
[  321.010148]  sch_ingress sch_htb sch_gred sch_choke sch_cbq nfnetlink_=
cttimeout nf_nat_tftp nf_nat_snmp_basic asn1_decoder nf_nat_pptp nf_nat_p=
roto_gre nf_nat_irc nf_nat_ipv6 nf_nat_ftp nf_nat_amanda nf_conntrack_tft=
p nf_conntrack_snmp nf_conntrack_sane nf_conntrack_pptp nf_conntrack_prot=
o_gre nf_conntrack_netlink nf_conntrack_netbios_ns nf_conntrack_irc nf_co=
nntrack_ftp nf_conntrack_broadcast ts_kmp nf_conntrack_amanda iptable_raw=
 iptable_nat iptable_mangle iptable_filter ipt_ah ipt_REJECT ipt_MASQUERA=
DE ipt_ECN ipt_CLUSTERIP ipip ifb em_u32 em_text em_nbyte em_meta em_cmp =
ebtable_nat ebtable_filter ebtable_broute ebtables ebt_vlan ebt_stp ebt_s=
nat ebt_redirect ebt_pkttype ebt_nflog ebt_mark_m ebt_mark ebt_log ebt_li=
mit ebt_ip ebt_dnat ebt_arpreply ebt_arp ebt_among ebt_802_3 cls_u32 cls_=
tcindex
[  321.058925]  cls_route cls_fw cls_cgroup cls_basic arptable_filter arp=
t_mangle arp_tables act_police act_pedit act_nat act_mirred act_ipt act_g=
act pcc_cpufreq crct10dif_pclmul crc32_pclmul ghash_clmulni_intel ixgbevf=
 i2c_piix4 intel_rapl_perf
[  321.073628] ---[ end trace 4a14396e6b248e40 ]---
[  321.077512] RIP: 0010:qlist_free_all+0x80/0xd0
[  321.081001] Code: df 48 85 db 75 db 48 89 f0 4c 01 f0 72 54 4c 89 fa 4=
8 2b 15 82 d0 5a 02 48 01 d0 48 c1 e8 0c 48 c1 e0 06 48 03 05 60 d0 5a 02=
 <48> 8b 50 08 48 8d 4a ff 83 e2 01 48 0f 45 c1 48 8b 78 18 eb a2 49
[  321.096100] RSP: 0018:ffff8882f3cefd48 EFLAGS: 00010203
[  321.100187] RAX: 00d0c45f95b9a580 RBX: 0000000000000000 RCX: ffffffffa=
e6cad40
[  321.105462] RDX: 0000777f80000000 RSI: 343620656e696c20 RDI: 000000000=
0000000
[  321.110235] RBP: 343620656e696c20 R08: ffffed106fd5be97 R09: ffffed106=
fd5be96
[  321.116855] R10: ffffed106fd5be96 R11: ffff88837eadf4b7 R12: ffffffffa=
e8edc17
[  321.121992] R13: ffff8882f3cefd80 R14: 0000000080000000 R15: ffffffff8=
0000000
[  321.126896] FS:  0000000000000000(0000) GS:ffff88837ea80000(0000) knlG=
S:0000000000000000
[  321.132353] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  321.136398] CR2: 00007ffc21a28fa4 CR3: 000000035c05a003 CR4: 000000000=
01606e0
[  321.141482] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 000000000=
0000000
[  321.146430] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 000000000=
0000400



[  507.460860] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D
[  507.467842] BUG filp (Tainted: G    B D    O     ): Redzone overwritte=
n
[  507.473148] ----------------------------------------------------------=
-------------------

[  507.480248] INFO: 0x000000007d719b7b-0x000000006c66d62d. First byte 0x=
6e instead of 0xbb
[  507.485978] INFO: Allocated in __alloc_file+0x2b/0x340 age=3D8119 cpu=3D=
0 pid=3D13295
[  507.490788] 	kmem_cache_alloc+0x1a4/0x1d0
[  507.493819] 	__alloc_file+0x2b/0x340
[  507.496558] 	alloc_empty_file+0x43/0x100
[  507.499572] 	path_openat+0x114/0x3f20
[  507.502356] 	do_filp_open+0x17c/0x250
[  507.505189] 	do_sys_open+0x1db/0x300
[  507.507943] 	do_syscall_64+0x9b/0x290
[  507.510787] 	entry_SYSCALL_64_after_hwframe+0x49/0xbe
[  507.514637] INFO: Freed in qlist_free_all+0x37/0xd0 age=3D601 cpu=3D0 =
pid=3D8601
[  507.519935] 	quarantine_reduce+0x1a2/0x210
[  507.523255] 	kasan_kmalloc+0x95/0xc0
[  507.525968] 	kmem_cache_alloc+0xc6/0x1d0
[  507.528944] 	sock_alloc_inode+0x18/0x220
[  507.531905] 	alloc_inode+0x59/0x150
[  507.534589] 	new_inode_pseudo+0xc/0xd0
[  507.537534] 	sock_alloc+0x3c/0x260
[  507.540134] 	__sock_create+0x85/0x4a0
[  507.542902] 	__sys_socket+0xd6/0x1b0
[  507.545597] 	__x64_sys_socket+0x6f/0xb0
[  507.548493] 	do_syscall_64+0x9b/0x290
[  507.551358] 	entry_SYSCALL_64_after_hwframe+0x49/0xbe
[  507.555158] INFO: Slab 0x00000000eb7c0300 objects=3D23 used=3D23 fp=3D=
0x          (null) flags=3D0x2ffff0000008100
[  507.562760] INFO: Object 0x0000000000f72fb5 @offset=3D64 fp=3D0x000000=
0044f349d6

[  507.568674] Redzone 000000007d719b7b: 6e 73 2e 70 79 5c 22 2c 20 6c 69=
 6e 65 20 36 34  ns.py\", line 64
[  507.576141] Redzone 000000008a448ace: 36 2c 20 69 6e 20 73 65 6e 64 5c=
 6e 20 20 20 20  6, in send\n
[  507.583755] Redzone 0000000079af1bc6: 72 20 3d 20 61 64 61 70 74 65 72=
 2e 73 65 6e 64  r =3D adapter.send
[  507.591277] Redzone 00000000d20be79e: 28 72 65 71 75 65 73 74 2c 20 2a=
 2a 6b 77 61 72  (request, **kwar
[  507.598796] Object 0000000000f72fb5: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  507.606108] Object 000000006d9c0410: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  507.613503] Object 00000000869bb10b: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  507.621000] Object 0000000021024cb0: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  507.628431] Object 000000004bd5b924: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  507.635810] Object 00000000baa6db8b: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  507.643062] Object 00000000b0129e9f: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  507.650360] Object 000000008081619a: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  507.657773] Object 000000007c9879c4: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  507.665107] Object 000000009903c776: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  507.672513] Object 0000000065122075: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  507.679983] Object 00000000edf96763: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  507.687599] Object 0000000010aaaa9a: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  507.695094] Object 000000004bdab3e7: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  507.702421] Object 000000004e6d9293: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
[  507.709983] Object 00000000a13b86f8: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b =
6b 6b 6b 6b a5  kkkkkkkkkkkkkkk.
[  507.717470] Redzone 000000008b2fdb56: bb bb bb bb bb bb bb bb         =
                 ........
[  507.724729] Padding 0000000021a7a02a: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a=
 5a 5a 5a 5a 5a  ZZZZZZZZZZZZZZZZ
[  507.732247] Padding 000000000e257ed9: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a=
 5a 5a 5a 5a 5a  ZZZZZZZZZZZZZZZZ
[  507.739868] Padding 00000000938b1d71: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a=
 5a 5a 5a 5a 5a  ZZZZZZZZZZZZZZZZ
[  507.747632] CPU: 1 PID: 8601 Comm: snmpd Kdump: loaded Tainted: G    B=
 D    O      4.19.72_3upstreamdbg #1
[  507.755901] Hardware name: Xen HVM domU, BIOS 4.2.amazon 08/24/2006
[  507.760662] Call Trace:
[  507.762601]  dump_stack+0x9a/0xf0
[  507.765159]  check_bytes_and_report.cold.24+0x3f/0x6b
[  507.769065]  check_object+0x17c/0x280
[  507.771927]  ? __alloc_file+0x2b/0x340
[  507.774908]  alloc_debug_processing+0x105/0x170
[  507.778485]  ___slab_alloc+0x4ba/0x530
[  507.781441]  ? __alloc_file+0x2b/0x340
[  507.784376]  ? __d_alloc+0x2a/0xa30
[  507.787110]  ? __alloc_file+0x2b/0x340
[  507.790040]  ? __alloc_file+0x2b/0x340
[  507.792973]  __slab_alloc+0x48/0x90
[  507.795737]  ? __alloc_file+0x2b/0x340
[  507.798695]  kmem_cache_alloc+0x1a4/0x1d0
[  507.801844]  __alloc_file+0x2b/0x340
[  507.804616]  alloc_empty_file+0x43/0x100
[  507.807590]  alloc_file+0x57/0x3d0
[  507.810168]  alloc_file_pseudo+0x15f/0x220
[  507.813234]  ? sock_init_data+0xbb2/0xfe0
[  507.816315]  ? alloc_file+0x3d0/0x3d0
[  507.819217]  ? m_stop+0x20/0x20
[  507.821692]  ? __alloc_fd+0x178/0x410
[  507.824584]  sock_alloc_file+0x39/0x160
[  507.827478]  __sys_socket+0x102/0x1b0
[  507.829618]  ? trace_hardirqs_on+0x35/0x140
[  507.832059]  ? move_addr_to_kernel+0x20/0x20
[  507.834561]  ? trace_hardirqs_off_caller+0x3b/0x140
[  507.837397]  ? do_syscall_64+0x18/0x290
[  507.839663]  __x64_sys_socket+0x6f/0xb0
[  507.841911]  do_syscall_64+0x9b/0x290
[  507.844066]  entry_SYSCALL_64_after_hwframe+0x49/0xbe
[  507.846904] RIP: 0033:0x7fa5f2669bf7
[  507.848984] Code: 73 01 c3 48 8b 0d 99 02 0c 00 f7 d8 64 89 01 48 83 c=
8 ff c3 66 2e 0f 1f 84 00 00 00 00 00 0f 1f 44 00 00 b8 29 00 00 00 0f 05=
 <48> 3d 01 f0 ff ff 73 01 c3 48 8b 0d 69 02 0c 00 f7 d8 64 89 01 48
[  507.860003] RSP: 002b:00007ffeb7319288 EFLAGS: 00000246 ORIG_RAX: 0000=
000000000029
[  507.864251] RAX: ffffffffffffffda RBX: 00007ffeb7319381 RCX: 00007fa5f=
2669bf7
[  507.868214] RDX: 0000000000000000 RSI: 0000000000000002 RDI: 000000000=
0000002
[  507.872141] RBP: 00007ffeb73192c0 R08: 000000000165dd9e R09: 000000000=
0000000
[  507.876186] R10: 00007fa5f2544740 R11: 0000000000000246 R12: 00000000f=
fffffff
[  507.880208] R13: 0000000000008933 R14: 0000000000000000 R15: 00007ffeb=
7319386
[  507.884198] FIX filp: Restoring 0x000000007d719b7b-0x000000006c66d62d=3D=
0xbb

[  507.888502] FIX filp: Marking all objects used

Best regards,
 =C2=A0Jakub.


