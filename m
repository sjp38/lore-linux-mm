Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 505CD6B04E5
	for <linux-mm@kvack.org>; Mon, 31 Jul 2017 22:45:55 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id h70so6099519ioi.14
        for <linux-mm@kvack.org>; Mon, 31 Jul 2017 19:45:55 -0700 (PDT)
Received: from tyo161.gate.nec.co.jp (tyo161.gate.nec.co.jp. [114.179.232.161])
        by mx.google.com with ESMTPS id k63si386770itg.58.2017.07.31.19.45.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 31 Jul 2017 19:45:54 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: "BUG: unable to handle kernel NULL pointer dereference" in swapping
 shmem
Date: Tue, 1 Aug 2017 02:42:03 +0000
Message-ID: <20170801024201.GA31457@hori1.linux.bs1.fc.nec.co.jp>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <FEB76DE799CD5A40A10972994E1B7635@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Huang, Ying" <ying.huang@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Jens Axboe <axboe@fb.com>, Michal Hocko <mhocko@kernel.org>, Ming Lei <ming.lei@redhat.com>

Hi,

I found the following bug when testing mmotm-2017-07-31-16-56.
The triggering testcase just swaps in/out shmem pages.
It seems to me related to thp swapping improvement patchset,
so let me report this to the relevant people.

Thanks,
Naoya Horiguchi
---
[  112.690842] =3D=3D=3D> testcase 'mm/shmem_swap' start=20
[  112.788440] Adding 40956k swap on /mnt/tests/examples/regression/kernel/=
mm_regression/mm_regression/work/swapfile.  Priority:-2 extents:1 across:40=
956k FS=20
[  112.815903] bash (17346): drop_caches: 3=20
[  112.975713] BUG: unable to handle kernel NULL pointer dereference at 000=
0000000000007=20
[  112.984464] IP: swap_page_trans_huge_swapped+0x49/0xd0=20
[  112.990202] PGD 805e62067 =20
[  112.990202] P4D 805e62067 =20
[  112.993219] PUD 80447b067 =20
[  112.996236] PMD 0 =20
[  112.999253] =20
[  113.003155] Oops: 0000 [#1] SMP=20
[  113.006658] Modules linked in: nfsv4 dns_resolver nfs fscache xt_CHECKSU=
M iptable_mangle ipt_MASQUERADE nf_nat_masquerade_ipv4 iptable_nat nf_nat_i=
pv4 nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_conntrack nf_conntrack libcr=
c32c ipt_REJECT nf_reject_ipv4 tun bridge stp llc ebtable_filter ebtables i=
p6_tables iptable_filter intel_rapl x86_pkg_temp_thermal intel_powerclamp k=
vm_intel kvm iTCO_wdt nfsd iTCO_vendor_support mei_me auth_rpcgss mei lpc_i=
ch ipmi_si ipmi_devintf irqbypass nfs_acl shpchp sg mfd_core ie31200_edac l=
ockd ipmi_msghandler pcspkr video acpi_pad grace sunrpc ip_tables sr_mod sd=
_mod cdrom tg3 ata_generic pata_acpi ata_piix ptp libata megaraid_sas crc32=
c_intel pps_core dm_mirror dm_region_hash dm_log dm_mod=20
[  113.077676] CPU: 0 PID: 17431 Comm: test_alloc_gene Not tainted 4.13.0-r=
c3-mm1-v4.13-rc3-mmotm-2017-07-31-16-56+ #1=20
[  113.089323] Hardware name: NEC Express5800/T110g-E [N8100-2187Y]/GA-6LAS=
V1, BIOS 4.6.1204 10/17/2014=20
[  113.099516] task: ffffa06705de9740 task.stack: ffffac0947c0c000=20
[  113.106124] RIP: 0010:swap_page_trans_huge_swapped+0x49/0xd0=20
[  113.112438] RSP: 0018:ffffac0947c0fb38 EFLAGS: 00010246=20
[  113.118269] RAX: 0000000000000000 RBX: 0000000000000000 RCX: 00000000000=
00040=20
[  113.126233] RDX: 0000000000000001 RSI: 00000000000005d6 RDI: ffffa067056=
74cfc=20
[  113.134196] RBP: ffffac0947c0fb60 R08: 0000000000000000 R09: ffffffff88c=
a2180=20
[  113.142161] R10: 0000000000000230 R11: ffffa066e7a9b451 R12: ffffa067056=
74c00=20
[  113.150123] R13: 00000000000005d6 R14: 0000000000000400 R15: ffffac09440=
01000=20
[  113.158088] FS:  00007f855b243740(0000) GS:ffffa0672fc00000(0000) knlGS:=
0000000000000000=20
[  113.167118] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033=20
[  113.173529] CR2: 0000000000000007 CR3: 0000000808de2002 CR4: 00000000001=
606f0=20
[  113.181493] Call Trace:=20
[  113.184222]  free_swap_and_cache+0x73/0x1d0=20
[  113.188889]  shmem_free_swap+0x5e/0x70=20
[  113.193072]  shmem_undo_range+0x4bd/0x8b0=20
[  113.197547]  shmem_truncate_range+0x14/0x40=20
[  113.202211]  shmem_evict_inode+0xba/0x190=20
[  113.206686]  evict+0xd3/0x1a0=20
[  113.210004]  iput+0x17d/0x1d0=20
[  113.213316]  dentry_unlink_inode+0xb9/0xf0=20
[  113.217887]  __dentry_kill+0xc7/0x170=20
[  113.221994]  dput+0x19c/0x1d0=20
[  113.225311]  __fput+0x188/0x210=20
[  113.228813]  ____fput+0xe/0x10=20
[  113.232221]  task_work_run+0x86/0xa0=20
[  113.236209]  exit_to_usermode_loop+0x6d/0x99=20
[  113.240981]  syscall_return_slowpath+0xad/0xd0=20
[  113.245961]  entry_SYSCALL_64_fastpath+0xa3/0xa5=20
[  113.251127] RIP: 0033:0x7f855a940b17=20
[  113.255113] RSP: 002b:00007fff955b5048 EFLAGS: 00000206 ORIG_RAX: 000000=
000000001f=20
[  113.263562] RAX: 0000000000000000 RBX: 0000000000000000 RCX: 00007f855a9=
40b17=20
[  113.271524] RDX: 0000000000000000 RSI: 0000000000000000 RDI: 00000000000=
28001=20
[  113.279488] RBP: 00007fff955b5060 R08: 0000000000000000 R09: 00000000000=
00000=20
[  113.287450] R10: 00007fff955b4dd0 R11: 0000000000000206 R12: 00000000004=
01da0=20
[  113.295414] R13: 00007fff955b5350 R14: 0000000000000000 R15: 00000000000=
00000=20
[  113.303378] Code: f5 41 54 49 89 fc 53 48 8b 47 70 4c 8b 7f 68 48 85 c0 =
74 70 4c 89 f3 48 c1 eb 06 48 01 c3 48 89 df e8 fc 10 54 00 48 85 db 74 59 =
<f6> 43 07 04 75 31 48 b8 ff ff ff ff ff ff ff 01 49 21 c5 43 80 =20
[  113.324450] RIP: swap_page_trans_huge_swapped+0x49/0xd0 RSP: ffffac0947c=
0fb38=20
[  113.332413] CR2: 0000000000000007=20
[  113.336121] ---[ end trace 2cd503b4980b0afc ]---=20
[  113.341281] Kernel panic - not syncing: Fatal exception=20
[  113.347398] Kernel Offset: 0x7000000 from 0xffffffff81000000 (relocation=
 range: 0xffffffff80000000-0xffffffffbfffffff)=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
