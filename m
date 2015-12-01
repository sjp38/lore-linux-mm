Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 420A86B0038
	for <linux-mm@kvack.org>; Mon, 30 Nov 2015 21:01:24 -0500 (EST)
Received: by padhx2 with SMTP id hx2so203909383pad.1
        for <linux-mm@kvack.org>; Mon, 30 Nov 2015 18:01:24 -0800 (PST)
Received: from tyo202.gate.nec.co.jp (TYO202.gate.nec.co.jp. [210.143.35.52])
        by mx.google.com with ESMTPS id pz7si14379569pab.1.2015.11.30.18.01.22
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 30 Nov 2015 18:01:23 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v1] mm: hugetlb: call huge_pte_alloc() only if ptep is
 null
Date: Tue, 1 Dec 2015 01:58:47 +0000
Message-ID: <20151201015838.GA4111@hori1.linux.bs1.fc.nec.co.jp>
References: <1448524936-10501-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <565CF5D6.1030602@oracle.com>
In-Reply-To: <565CF5D6.1030602@oracle.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <4A7B954BC5BE8D4D9DCE9185B4F5EA3F@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Mon, Nov 30, 2015 at 05:20:22PM -0800, Mike Kravetz wrote:
> On 11/26/2015 12:02 AM, Naoya Horiguchi wrote:
> > Currently at the beginning of hugetlb_fault(), we call huge_pte_offset(=
)
> > and check whether the obtained *ptep is a migration/hwpoison entry or n=
ot.
> > And if not, then we get to call huge_pte_alloc(). This is racy because =
the
> > *ptep could turn into migration/hwpoison entry after the huge_pte_offse=
t()
> > check. This race results in BUG_ON in huge_pte_alloc().
>=20
> I assume the BUG_ON you hit in huge_pte_alloc is:
>=20
> 	BUG_ON(pte && !pte_none(*pte) && !pte_huge(*pte));
>=20
> Correct?

Yes, that's correct. Actually what I saw was like below:

  [ 1292.609405] kernel BUG at arch/x86/mm/hugetlbpage.c:161!
  [ 1292.614706] invalid opcode: 0000 [#1] SMP
  [ 1292.618830] Modules linked in: hwpoison_inject mce_inject xt_CHECKSUM =
iptable_mangle it_MASQUERADE nf_nat_masquerade_ipv4 iptable_nat nf_nat_ipv4=
 nf_nat nf_conntrack_ipv4 nf_dfrag_ipv4 xt_conntrack nf_conntrack ipt_REJEC=
T tun bridge stp llc ebtable_filter ebtablesip6_tables iptable_filter xprtr=
dma ib_isert iscsi_target_mod ib_iser libiscsi scsi_transprt_iscsi ib_srpt =
target_core_mod ib_srp scsi_transport_srp scsi_tgt ib_ipoib rdma_ucm ib_cm =
ib_uverbs ib_umad rdma_cm ib_cm iw_cm coretemp kvm_intel kvm iTCO_wdt iTCO_=
vendor_supprt sg lpc_ich mfd_core i7core_edac pcspkr shpchp edac_core ioatd=
ma i2c_i801 acpi_cpufreqfsd auth_rpcgss nfs_acl lockd grace sunrpc ip_table=
s ext4 mbcache jbd2 mlx4_ib mlx4_en ibsa ib_mad vxlan ip6_udp_tunnel ib_cor=
e udp_tunnel ib_addr sd_mod crc_t10dif crct10dif_genric crct10dif_common mg=
ag200 ata_generic syscopyarea sysfillrect pata_acpi sysimgblt drm_ms_helper=
 igb ttm ata_piix ptp libata drm pps_core crc32c_intel serio_raw mlx4_core =
dca ic_algo_bit i2c_core dm_mirror dm_region_hash dm_log dm_mod
  [ 1292.711755] CPU: 10 PID: 15818 Comm: iterate_hugepag Tainted: G       =
   I    --------
  ---   3.10.0-324.el7.hm.x86_64 #1
  [ 1292.722643] Hardware name: Supermicro X8DTT/X8DTT, BIOS 080016  05/20/=
2010
  [ 1292.729506] task: ffff88032c4d3980 ti: ffff88061525c000 task.ti: ffff8=
8061525c000
  [ 1292.736977] RIP: 0010:[<ffffffff810667f2>]  [<ffffffff810667f2>] huge_=
pte_alloc+0x452/
  x4d0
  [ 1292.745373] RSP: 0000:ffff88061525fd78  EFLAGS: 00010246
  [ 1292.750684] RAX: ffff88032b637000 RBX: ffff8800bb265700 RCX: ffff88000=
0000000
  [ 1292.757806] RDX: 0000000016b80000 RSI: 0000700000000000 RDI: 000000032=
b637067
  [ 1292.764928] RBP: ffff88061525fdb8 R08: ffff880000000000 R09: 000000000=
00000a9
  [ 1292.772050] R10: 0000000000000000 R11: 00007f87ca84e20a R12: 000000000=
0200000
  [ 1292.779199] R13: ffff88032b486000 R14: ffff880000000000 R15: ffff88032=
cbed780
  [ 1292.786321] FS:  00007f87cb1bf740(0000) GS:ffff880333cc0000(0000) knlG=
S:00000000000000
  0
  [ 1292.794407] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
  [ 1292.800143] CR2: 0000700000046690 CR3: 00000000bb265000 CR4: 000000000=
00007e0
  [ 1292.807265] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 000000000=
0000000
  [ 1292.814388] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 000000000=
0000400
  [ 1292.821535] Stack:
  [ 1292.823574]  80000000b5c000a5 0000000000000000 ffff88032cbed780 ffffff=
ff81e8ae20
  [ 1292.831024]  0000700000000000 ffff8806152b0bd0 ffff88032b637000 ffff88=
032cbed780
  [ 1292.838474]  ffff88061525fe38 ffffffff811b2f51 ffffea000cad8df0 000000=
0000002008
  [ 1292.845926] Call Trace:
  [ 1292.848374]  [<ffffffff811b2f51>] hugetlb_fault+0xa1/0x900
  [ 1292.853876]  [<ffffffff811976fd>] handle_mm_fault+0xd0d/0xf50
  [ 1292.859621]  [<ffffffff813020e7>] ? call_rwsem_wake+0x17/0x30
  [ 1292.865391]  [<ffffffff81641922>] __do_page_fault+0x152/0x420
  [ 1292.871126]  [<ffffffff81641c13>] do_page_fault+0x23/0x80
  [ 1292.876516]  [<ffffffff8163df08>] page_fault+0x28/0x30

This was on RHEL7 kernel and I didn't reproduce it on upstream. But the fix
itself was confirmed, and upstream has the same code, so I'd like the fix
to be applied on upstream before it will get visible in the future.

> This means either:
> 1) The pte was present when entering hugetlb_fault() and not marked
>    for migration or hwpoisoned.
> 2) The pte was added to the page table after the call to huge_pte_offset(=
)
>    and before the call to huge_pte_alloc().
>=20
> Your patch will take care of case # 1.

Right. In case #1, huge_pte_alloc() is just needless because we already
have ptep allocated.

>  I am not sure case # 2 is possible,
> but your patch would not address this situation.

In case #2, the huge_ptep_get() in hugetlb_fault() after holding
hugetlb_fault_mutex_table should get the valid (just added) pte,
so the fault should be properly handled.

Thanks,
Naoya Horiguchi

> --=20
> Mike Kravetz
>=20
> >=20
> > We don't have to call huge_pte_alloc() when the huge_pte_offset() retur=
ns
> > non-NULL, so let's fix this bug with moving the code into else block.
> >=20
> > Note that the *ptep could turn into a migration/hwpoison entry after
> > this block, but that's not a problem because we have another !pte_prese=
nt
> > check later (we never go into hugetlb_no_page() in that case.)
> >=20
> > Fixes: 290408d4a250 ("hugetlb: hugepage migration core")
> > Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> > Cc: <stable@vger.kernel.org> [2.6.36+]
> > ---
> >  mm/hugetlb.c |    8 ++++----
> >  1 files changed, 4 insertions(+), 4 deletions(-)
> >=20
> > diff --git next-20151123/mm/hugetlb.c next-20151123_patched/mm/hugetlb.=
c
> > index 1101ccd..6ad5e91 100644
> > --- next-20151123/mm/hugetlb.c
> > +++ next-20151123_patched/mm/hugetlb.c
> > @@ -3696,12 +3696,12 @@ int hugetlb_fault(struct mm_struct *mm, struct =
vm_area_struct *vma,
> >  		} else if (unlikely(is_hugetlb_entry_hwpoisoned(entry)))
> >  			return VM_FAULT_HWPOISON_LARGE |
> >  				VM_FAULT_SET_HINDEX(hstate_index(h));
> > +	} else {
> > +		ptep =3D huge_pte_alloc(mm, address, huge_page_size(h));
> > +		if (!ptep)
> > +			return VM_FAULT_OOM;
> >  	}
> > =20
> > -	ptep =3D huge_pte_alloc(mm, address, huge_page_size(h));
> > -	if (!ptep)
> > -		return VM_FAULT_OOM;
> > -
> >  	mapping =3D vma->vm_file->f_mapping;
> >  	idx =3D vma_hugecache_offset(h, vma, address);
> > =20
> > =

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
