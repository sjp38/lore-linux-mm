Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8C2B96B04E9
	for <linux-mm@kvack.org>; Tue,  1 Aug 2017 01:20:30 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id 41so8335812iop.2
        for <linux-mm@kvack.org>; Mon, 31 Jul 2017 22:20:30 -0700 (PDT)
Received: from tyo162.gate.nec.co.jp (tyo162.gate.nec.co.jp. [114.179.232.162])
        by mx.google.com with ESMTPS id s16si679850ita.101.2017.07.31.22.20.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 31 Jul 2017 22:20:29 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: "BUG: unable to handle kernel NULL pointer dereference" in
 swapping shmem
Date: Tue, 1 Aug 2017 05:17:12 +0000
Message-ID: <20170801051711.GA18875@hori1.linux.bs1.fc.nec.co.jp>
References: <20170801024201.GA31457@hori1.linux.bs1.fc.nec.co.jp>
 <874ltsm0bi.fsf@yhuang-dev.intel.com>
In-Reply-To: <874ltsm0bi.fsf@yhuang-dev.intel.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <4001FF3265B6504E9294CF2E0766DF1A@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Jens Axboe <axboe@fb.com>, Michal Hocko <mhocko@kernel.org>, Ming Lei <ming.lei@redhat.com>

Hello Huang,

On Tue, Aug 01, 2017 at 11:30:41AM +0800, Huang, Ying wrote:
> Hi, Horiguchi san,
>=20
> Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> writes:
>=20
> > Hi,
> >
> > I found the following bug when testing mmotm-2017-07-31-16-56.
> > The triggering testcase just swaps in/out shmem pages.
> > It seems to me related to thp swapping improvement patchset,
> > so let me report this to the relevant people.
> >
> > Thanks,
> > Naoya Horiguchi
> > ---
...
>=20
> Thanks for reporting!  Do you test it on a HDD?  I can reproduce this on
> a HDD, the fix patch is as follow, could you try it?

Yes, my test ran on a HDD.
And I confirmed that the suggested patch fixes the panic.
Thank you for your quick work.

- Naoya Horiguchi

>=20
> Best Regards,
> Huang, Ying
>=20
> --------->8---------
> From 2487f0230fef59c1ef89792e2af7bcabc02470cf Mon Sep 17 00:00:00 2001
> From: Huang Ying <ying.huang@intel.com>
> Date: Tue, 1 Aug 2017 11:20:23 +0800
> Subject: [PATCH] mm, THP, swap: Fix swap_page_trans_huge_swapped on HDD
>=20
> To fix the following kernel bug,
>=20
> [  112.690842] =3D=3D=3D> testcase 'mm/shmem_swap' start
> [ 112.788440] Adding 40956k swap on
> /mnt/tests/examples/regression/kernel/mm_regression/mm_regression/work/sw=
apfile.
> Priority:-2 extents:1 across:40956k FS
> [  112.815903] bash (17346): drop_caches: 3
> [  112.975713] BUG: unable to handle kernel NULL pointer dereference at 0=
000000000000007
> [  112.984464] IP: swap_page_trans_huge_swapped+0x49/0xd0
> [  112.990202] PGD 805e62067
> [  112.990202] P4D 805e62067
> [  112.993219] PUD 80447b067
> [  112.996236] PMD 0
> [  112.999253]
> [  113.003155] Oops: 0000 [#1] SMP
> [ 113.006658] Modules linked in: nfsv4 dns_resolver nfs fscache
> xt_CHECKSUM iptable_mangle ipt_MASQUERADE nf_nat_masquerade_ipv4
> iptable_nat nf_nat_ipv4 nf_nat nf_conntrack_ipv4 nf_defrag_ipv4
> xt_conntrack nf_conntrack libcrc32c ipt_REJECT nf_reject_ipv4 tun
> bridge stp llc ebtable_filter ebtables ip6_tables iptable_filter
> intel_rapl x86_pkg_temp_thermal intel_powerclamp kvm_intel kvm
> iTCO_wdt nfsd iTCO_vendor_support mei_me auth_rpcgss mei lpc_ich
> ipmi_si ipmi_devintf irqbypass nfs_acl shpchp sg mfd_core ie31200_edac
> lockd ipmi_msghandler pcspkr video acpi_pad grace sunrpc ip_tables
> sr_mod sd_mod cdrom tg3 ata_generic pata_acpi ata_piix ptp libata
> megaraid_sas crc32c_intel pps_core dm_mirror dm_region_hash dm_log
> dm_mod
> [  113.077676] CPU: 0 PID: 17431 Comm: test_alloc_gene Not tainted 4.13.0=
-rc3-mm1-v4.13-rc3-mmotm-2017-07-31-16-56+ #1
> [  113.089323] Hardware name: NEC Express5800/T110g-E [N8100-2187Y]/GA-6L=
ASV1, BIOS 4.6.1204 10/17/2014
> [  113.099516] task: ffffa06705de9740 task.stack: ffffac0947c0c000
> [  113.106124] RIP: 0010:swap_page_trans_huge_swapped+0x49/0xd0
> [  113.112438] RSP: 0018:ffffac0947c0fb38 EFLAGS: 00010246
> [  113.118269] RAX: 0000000000000000 RBX: 0000000000000000 RCX: 000000000=
0000040
> [  113.126233] RDX: 0000000000000001 RSI: 00000000000005d6 RDI: ffffa0670=
5674cfc
> [  113.134196] RBP: ffffac0947c0fb60 R08: 0000000000000000 R09: ffffffff8=
8ca2180
> [  113.142161] R10: 0000000000000230 R11: ffffa066e7a9b451 R12: ffffa0670=
5674c00
> [  113.150123] R13: 00000000000005d6 R14: 0000000000000400 R15: ffffac094=
4001000
> [  113.158088] FS:  00007f855b243740(0000) GS:ffffa0672fc00000(0000) knlG=
S:0000000000000000
> [  113.167118] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [  113.173529] CR2: 0000000000000007 CR3: 0000000808de2002 CR4: 000000000=
01606f0
> [  113.181493] Call Trace:
> [  113.184222]  free_swap_and_cache+0x73/0x1d0
> [  113.188889]  shmem_free_swap+0x5e/0x70
> [  113.193072]  shmem_undo_range+0x4bd/0x8b0
> [  113.197547]  shmem_truncate_range+0x14/0x40
> [  113.202211]  shmem_evict_inode+0xba/0x190
> [  113.206686]  evict+0xd3/0x1a0
> [  113.210004]  iput+0x17d/0x1d0
> [  113.213316]  dentry_unlink_inode+0xb9/0xf0
> [  113.217887]  __dentry_kill+0xc7/0x170
> [  113.221994]  dput+0x19c/0x1d0
> [  113.225311]  __fput+0x188/0x210
> [  113.228813]  ____fput+0xe/0x10
> [  113.232221]  task_work_run+0x86/0xa0
> [  113.236209]  exit_to_usermode_loop+0x6d/0x99
> [  113.240981]  syscall_return_slowpath+0xad/0xd0
> [  113.245961]  entry_SYSCALL_64_fastpath+0xa3/0xa5
> [  113.251127] RIP: 0033:0x7f855a940b17
> [  113.255113] RSP: 002b:00007fff955b5048 EFLAGS: 00000206 ORIG_RAX: 0000=
00000000001f
> [  113.263562] RAX: 0000000000000000 RBX: 0000000000000000 RCX: 00007f855=
a940b17
> [  113.271524] RDX: 0000000000000000 RSI: 0000000000000000 RDI: 000000000=
0028001
> [  113.279488] RBP: 00007fff955b5060 R08: 0000000000000000 R09: 000000000=
0000000
> [  113.287450] R10: 00007fff955b4dd0 R11: 0000000000000206 R12: 000000000=
0401da0
> [  113.295414] R13: 00007fff955b5350 R14: 0000000000000000 R15: 000000000=
0000000
> [ 113.303378] Code: f5 41 54 49 89 fc 53 48 8b 47 70 4c 8b 7f 68 48 85
> c0 74 70 4c 89 f3 48 c1 eb 06 48 01 c3 48 89 df e8 fc 10 54 00 48 85
> db 74 59 <f6> 43 07 04 75 31 48 b8 ff ff ff ff ff ff ff 01 49 21 c5 43
> 80
> [  113.324450] RIP: swap_page_trans_huge_swapped+0x49/0xd0 RSP: ffffac094=
7c0fb38
> [  113.332413] CR2: 0000000000000007
> [  113.336121] ---[ end trace 2cd503b4980b0afc ]---
> [  113.341281] Kernel panic - not syncing: Fatal exception
> [  113.347398] Kernel Offset: 0x7000000 from 0xffffffff81000000 (relocati=
on range: 0xffffffff80000000-0xffffffffbfffffff)
>=20
> Reported-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
> ---
>  mm/swapfile.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>=20
> diff --git a/mm/swapfile.c b/mm/swapfile.c
> index d77fc2fe2b8f..32434541cc12 100644
> --- a/mm/swapfile.c
> +++ b/mm/swapfile.c
> @@ -1390,7 +1390,7 @@ static bool swap_page_trans_huge_swapped(struct swa=
p_info_struct *si,
>  	bool ret =3D false;
> =20
>  	ci =3D lock_cluster_or_swap_info(si, offset);
> -	if (!cluster_is_huge(ci)) {
> +	if (!ci || !cluster_is_huge(ci)) {
>  		if (map[roffset] !=3D SWAP_HAS_CACHE)
>  			ret =3D true;
>  		goto unlock_out;
> --=20
> 2.13.2
> =

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
