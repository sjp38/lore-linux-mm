Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f172.google.com (mail-qk0-f172.google.com [209.85.220.172])
	by kanga.kvack.org (Postfix) with ESMTP id B3CEE6B006E
	for <linux-mm@kvack.org>; Tue, 16 Jun 2015 09:17:29 -0400 (EDT)
Received: by qkfe185 with SMTP id e185so8383359qkf.3
        for <linux-mm@kvack.org>; Tue, 16 Jun 2015 06:17:29 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z9si896057qcn.27.2015.06.16.06.17.28
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Jun 2015 06:17:28 -0700 (PDT)
Message-ID: <558021D9.4050304@redhat.com>
Date: Tue, 16 Jun 2015 15:17:13 +0200
From: Jerome Marchand <jmarchan@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCHv6 00/36] THP refcounting redesign
References: <1433351167-125878-1-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1433351167-125878-1-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="RnfWSoDh1HA2hp7JGlHcIF39CRmLhiEuV"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--RnfWSoDh1HA2hp7JGlHcIF39CRmLhiEuV
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 06/03/2015 07:05 PM, Kirill A. Shutemov wrote:
> Hello everybody,
>=20
> Here's new revision of refcounting patchset. Please review and consider=

> applying.
>=20
> The goal of patchset is to make refcounting on THP pages cheaper with
> simpler semantics and allow the same THP compound page to be mapped wit=
h
> PMD and PTEs. This is required to get reasonable THP-pagecache
> implementation.
>=20
> With the new refcounting design it's much easier to protect against
> split_huge_page(): simple reference on a page will make you the deal.
> It makes gup_fast() implementation simpler and doesn't require
> special-case in futex code to handle tail THP pages.
>=20
> It should improve THP utilization over the system since splitting THP i=
n
> one process doesn't necessary lead to splitting the page in all other
> processes have the page mapped.
>=20
> The patchset drastically lower complexity of get_page()/put_page()
> codepaths. I encourage people look on this code before-and-after to
> justify time budget on reviewing this patchset.
>=20
> =3D Changelog =3D
>=20
> v6:
>   - rebase to since-4.0;
>   - optimize mapcount handling: significantely reduce overhead for most=

>     common cases.
>   - split pages on migrate_pages();
>   - remove infrastructure for handling splitting PMDs on all architectu=
res;
>   - fix page_mapcount() for hugetlb pages;
>=20

Hi Kirill,

I ran some LTP mm tests and hugemmap tests trigger the following:

[  438.749457] page:ffffea0000df8000 count:2 mapcount:0 mapping:         =
 (null) index:0x0 compound_mapcount: 0
[  438.750089] flags: 0x3ffc0000004001(locked|head)
[  438.750089] page dumped because: VM_BUG_ON_PAGE(page_mapped(page))
[  438.750089] ------------[ cut here ]------------
[  438.768046] kernel BUG at mm/filemap.c:205!
[  438.768046] invalid opcode: 0000 [#1] SMP=20
[  438.768046] Modules linked in: loop ip6t_rpfilter ip6t_REJECT nf_rejec=
t_ipv6 xt_conntrack ebtable_nat ebtable_broute bridge stp llc ebtable_fil=
ter ebtables ip6table_nat nf_conntrack_ipv6 nf_defrag_ipv6 nf_nat_ipv6 ip=
6table_mangle ip6table_security ip6table_raw ip6table_filter ip6_tables i=
ptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntra=
ck iptable_mangle iptable_security iptable_raw ppdev iosf_mbi crct10dif_p=
clmul crc32_pclmul crc32c_intel joydev ghash_clmulni_intel virtio_balloon=
 pcspkr virtio_console nfsd parport_pc parport floppy pvpanic i2c_piix4 a=
cpi_cpufreq auth_rpcgss nfs_acl lockd grace sunrpc virtio_net qxl virtio_=
blk drm_kms_helper ttm drm serio_raw ata_generic virtio_pci virtio_ring v=
irtio pata_acpi
[  438.768046] CPU: 1 PID: 12918 Comm: hugemmap01 Not tainted 4.0.0thprfc=
-kasv6+ #247
[  438.768046] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[  438.768046] task: ffff88007b09cc40 ti: ffff880077b88000 task.ti: ffff8=
80077b88000
[  438.768046] RIP: 0010:[<ffffffff811e2aac>]  [<ffffffff811e2aac>] __del=
ete_from_page_cache+0x4bc/0x5a0
[  438.768046] RSP: 0018:ffff880077b8bc58  EFLAGS: 00010086
[  438.768046] RAX: 0000000000000036 RBX: ffffea0000df8000 RCX: 000000000=
0000006
[  438.768046] RDX: 0000000000000000 RSI: 0000000000000000 RDI: ffff88007=
d5ce9c0
[  438.768046] RBP: ffff880077b8bcb8 R08: 0000000000000001 R09: 000000000=
0000001
[  438.768046] R10: 0000000000000001 R11: ffff880034e44210 R12: ffffea000=
0df8000
[  438.768046] R13: ffff88003562cac0 R14: 0000000000000000 R15: ffff88003=
562cac8
[  438.768046] FS:  00007fda9ccbb700(0000) GS:ffff88007d400000(0000) knlG=
S:0000000000000000
[  438.768046] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  438.768046] CR2: 00007fda9ccc7000 CR3: 00000000785e6000 CR4: 000000000=
01407e0
[  438.768046] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 000000000=
0000000
[  438.768046] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 000000000=
0000400
[  438.768046] Stack:
[  438.768046]  0000000000000246 ffff88003562cad8 ffff88003562caf0 000000=
0000000000
[  438.768046]  ffff88003562cad0 000000009bfc6d69 ffff880077b8bcb8 ffffea=
0000df8000
[  438.768046]  ffff88003562cad8 0000000000000000 ffffea0000df8000 000000=
0000000000
[  438.768046] Call Trace:
[  438.768046]  [<ffffffff811e2be5>] delete_from_page_cache+0x55/0xd0
[  438.768046]  [<ffffffff81380be5>] truncate_hugepages+0x135/0x290
[  438.768046]  [<ffffffff810e7df5>] ? local_clock+0x15/0x30
[  438.768046]  [<ffffffff8110647f>] ? lock_release_holdtime.part.31+0xf/=
0x190
[  438.768046]  [<ffffffff81380eb8>] hugetlbfs_evict_inode+0x18/0x40
[  438.768046]  [<ffffffff812982bb>] evict+0xab/0x180
[  438.768046]  [<ffffffff81298cee>] iput+0x1ce/0x390
[  438.768046]  [<ffffffff8128aba9>] do_unlinkat+0x209/0x330
[  438.768046]  [<ffffffff81884632>] ? ret_from_sys_call+0x24/0x5f
[  438.768046]  [<ffffffff811095ed>] ? trace_hardirqs_on_caller+0xfd/0x1c=
0
[  438.768046]  [<ffffffff8128bf66>] SyS_unlink+0x16/0x20
[  438.768046]  [<ffffffff81884609>] system_call_fastpath+0x12/0x17
[  438.768046] Code: 49 8b 14 24 4c 89 e0 80 e6 80 74 08 4c 89 e7 e8 15 2=
e 69 00 8b 40 48 83 c0 01 74 25 48 c7 c6 28 fb c6 81 48 89 df e8 d4 43 03=
 00 <0f> 0b 48 89 df e8 f4 2d 69 00 48 f7 00 00 c0 00 00 49 89 c4 75=20
[  438.768046] RIP  [<ffffffff811e2aac>] __delete_from_page_cache+0x4bc/0=
x5a0
[  438.768046]  RSP <ffff880077b8bc58>
[  438.768046] ---[ end trace 3903188dcb3f3d48 ]---
[  438.768046] BUG: sleeping function called from invalid context at kern=
el/locking/rwsem.c:41
[  438.768046] in_atomic(): 1, irqs_disabled(): 1, pid: 12918, name: huge=
mmap01
[  438.768046] INFO: lockdep is turned off.
[  438.768046] irq event stamp: 6218
[  438.768046] hardirqs last  enabled at (6217): [<ffffffff818812df>] __m=
utex_unlock_slowpath+0xbf/0x190
[  438.768046] hardirqs last disabled at (6218): [<ffffffff8188387f>] _ra=
w_spin_lock_irq+0x1f/0x80
[  438.768046] softirqs last  enabled at (6042): [<ffffffff810b0df7>] __d=
o_softirq+0x377/0x670
[  438.768046] softirqs last disabled at (6027): [<ffffffff810b14ad>] irq=
_exit+0x11d/0x130
[  438.768046] CPU: 1 PID: 12918 Comm: hugemmap01 Tainted: G      D      =
   4.0.0thprfc-kasv6+ #247
[  438.768046] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[  438.768046]  0000000000000000 000000009bfc6d69 ffff880077b8b8a8 ffffff=
ff81879afa
[  438.768046]  0000000000000000 ffff88007b09cc40 ffff880077b8b8d8 ffffff=
ff810da0cc
[  438.768046]  0000000000000000 ffffffff81c68746 0000000000000029 000000=
0000000000
[  438.768046] Call Trace:
[  438.768046]  [<ffffffff81879afa>] dump_stack+0x4c/0x65
[  438.768046]  [<ffffffff810da0cc>] ___might_sleep+0x18c/0x250
[  438.768046]  [<ffffffff810da1dd>] __might_sleep+0x4d/0x90
[  438.768046]  [<ffffffff8188163a>] down_read+0x2a/0xa0
[  438.768046]  [<ffffffff810be6c3>] exit_signals+0x33/0x150
[  438.768046]  [<ffffffff810adc2f>] do_exit+0xcf/0xd20
[  438.768046]  [<ffffffff81121006>] ? kmsg_dump+0x166/0x220
[  438.768046]  [<ffffffff81120ed4>] ? kmsg_dump+0x34/0x220
[  438.768046]  [<ffffffff81021cce>] oops_end+0x9e/0xe0
[  438.768046]  [<ffffffff8102224b>] die+0x4b/0x70
[  438.768046]  [<ffffffff8101df80>] do_trap+0xb0/0x150
[  438.768046]  [<ffffffff8101e2f4>] do_error_trap+0xa4/0x180
[  438.768046]  [<ffffffff811e2aac>] ? __delete_from_page_cache+0x4bc/0x5=
a0
[  438.768046]  [<ffffffff81120255>] ? vprintk_emit+0x285/0x620
[  438.768046]  [<ffffffff81435b9d>] ? trace_hardirqs_off_thunk+0x3a/0x3c=

[  438.768046]  [<ffffffff8101ee90>] do_invalid_op+0x20/0x30
[  438.768046]  [<ffffffff818860de>] invalid_op+0x1e/0x30
[  438.768046]  [<ffffffff811e2aac>] ? __delete_from_page_cache+0x4bc/0x5=
a0
[  438.768046]  [<ffffffff811e2aac>] ? __delete_from_page_cache+0x4bc/0x5=
a0
[  438.768046]  [<ffffffff811e2be5>] delete_from_page_cache+0x55/0xd0
[  438.768046]  [<ffffffff81380be5>] truncate_hugepages+0x135/0x290
[  438.768046]  [<ffffffff810e7df5>] ? local_clock+0x15/0x30
[  438.768046]  [<ffffffff8110647f>] ? lock_release_holdtime.part.31+0xf/=
0x190
[  438.768046]  [<ffffffff81380eb8>] hugetlbfs_evict_inode+0x18/0x40
[  438.768046]  [<ffffffff812982bb>] evict+0xab/0x180
[  438.768046]  [<ffffffff81298cee>] iput+0x1ce/0x390
[  438.768046]  [<ffffffff8128aba9>] do_unlinkat+0x209/0x330
[  438.768046]  [<ffffffff81884632>] ? ret_from_sys_call+0x24/0x5f
[  438.768046]  [<ffffffff811095ed>] ? trace_hardirqs_on_caller+0xfd/0x1c=
0
[  438.768046]  [<ffffffff8128bf66>] SyS_unlink+0x16/0x20
[  438.768046]  [<ffffffff81884609>] system_call_fastpath+0x12/0x17
[  438.768046] note: hugemmap01[12918] exited with preempt_count 1

Jerome


--RnfWSoDh1HA2hp7JGlHcIF39CRmLhiEuV
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBCAAGBQJVgCHgAAoJEHTzHJCtsuoChOoIAIaFc2YmJ0b28TqlEpLA0y+O
GL4veffsIImf5kC/SoJqitKhRxMMkCyHg5PM3gC+23MDppDPyMt+RYO4p040w/Ge
EfP8rKKZAoY3hUXoa191tA+nO0pM+RwzBtvO774PVqI0qPN6piF1p/alVxjhVxb5
QeLnoJP9mqWWS9i4T80ta0KP9qom6IFOOOULEAZ+ZNd4Ny+DLm2mNPf2JtOFN0aV
h1jjqbjGqLFcyjU2S+XktsAiiySH5xaD/NB7X5VxxJWoVLIWQYF10TMiqap2QJHX
dt+g2A03i5U7DQnSNxjSP1DW4tc3OTl2YtFTExeDRUqEN93N1xotEZggbPb3gGM=
=SBPa
-----END PGP SIGNATURE-----

--RnfWSoDh1HA2hp7JGlHcIF39CRmLhiEuV--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
