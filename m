Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6D0C66B0038
	for <linux-mm@kvack.org>; Wed, 22 Mar 2017 18:56:23 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id a94so166951544oic.5
        for <linux-mm@kvack.org>; Wed, 22 Mar 2017 15:56:23 -0700 (PDT)
Received: from tyo162.gate.nec.co.jp (tyo162.gate.nec.co.jp. [114.179.232.162])
        by mx.google.com with ESMTPS id v50si1359278otd.212.2017.03.22.15.56.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Mar 2017 15:56:22 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v1] mm, hugetlb: use pte_present() instead of
 pmd_present() in follow_huge_pmd()
Date: Wed, 22 Mar 2017 22:53:11 +0000
Message-ID: <20170322225310.GA23466@hori1.linux.bs1.fc.nec.co.jp>
References: <1490149898-20231-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <bd770cf9-c01c-dd50-bf6c-a50872f726ec@de.ibm.com>
 <a3acee49-9ad4-ee94-2e19-55f56fc7151d@de.ibm.com>
In-Reply-To: <a3acee49-9ad4-ee94-2e19-55f56fc7151d@de.ibm.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <9B703C8A85670D4B9F19EED540B8F340@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christian Borntraeger <borntraeger@de.ibm.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>, linux-s390 <linux-s390@vger.kernel.org>

On Wed, Mar 22, 2017 at 03:39:00PM +0100, Christian Borntraeger wrote:
> On 03/22/2017 01:53 PM, Christian Borntraeger wrote:
> > On 03/22/2017 03:31 AM, Naoya Horiguchi wrote:
> >> I found the race condition which triggers the following bug when
> >> move_pages() and soft offline are called on a single hugetlb page
> >> concurrently.
> >>
> >>     [61163.578957] Soft offlining page 0x119400 at 0x700000000000
> >>     [61163.580062] BUG: unable to handle kernel paging request at ffff=
ea0011943820
> >>     [61163.580791] IP: follow_huge_pmd+0x143/0x190
> >>     [61163.581203] PGD 7ffd2067
> >>     [61163.581204] PUD 7ffd1067
> >>     [61163.581471] PMD 0
> >>     [61163.581723]
> >>     [61163.582052] Oops: 0000 [#1] SMP
> >>     [61163.582349] Modules linked in: binfmt_misc ppdev virtio_balloon=
 parport_pc pcspkr i2c_piix4 parport i2c_core acpi_cpufreq ip_tables xfs li=
bcrc32c ata_generic pata_acpi virtio_blk 8139too crc32c_intel ata_piix seri=
o_raw libata virtio_pci 8139cp virtio_ring virtio mii floppy dm_mirror dm_r=
egion_hash dm_log dm_mod [last unloaded: cap_check]
> >>     [61163.585130] CPU: 0 PID: 22573 Comm: iterate_numa_mo Tainted: P =
          OE   4.11.0-rc2-mm1+ #2
> >>     [61163.586055] Hardware name: Red Hat KVM, BIOS 0.5.1 01/01/2011
> >>     [61163.586627] task: ffff88007c951680 task.stack: ffffc90004bd8000
> >>     [61163.587181] RIP: 0010:follow_huge_pmd+0x143/0x190
> >>     [61163.587622] RSP: 0018:ffffc90004bdbcd0 EFLAGS: 00010202
> >>     [61163.588096] RAX: 0000000465003e80 RBX: ffffea0004e34d30 RCX: 00=
003ffffffff000
> >>     [61163.588818] RDX: 0000000011943800 RSI: 0000000000080001 RDI: 00=
00000465003e80
> >>     [61163.589486] RBP: ffffc90004bdbd18 R08: 0000000000000000 R09: ff=
ff880138d34000
> >>     [61163.590097] R10: ffffea0004650000 R11: 0000000000c363b0 R12: ff=
ffea0011943800
> >>     [61163.590751] R13: ffff8801b8d34000 R14: ffffea0000000000 R15: 00=
0077ff80000000
> >>     [61163.591375] FS:  00007fc977710740(0000) GS:ffff88007dc00000(000=
0) knlGS:0000000000000000
> >>     [61163.592068] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> >>     [61163.592627] CR2: ffffea0011943820 CR3: 000000007a746000 CR4: 00=
000000001406f0
> >>     [61163.593330] Call Trace:
> >>     [61163.593556]  follow_page_mask+0x270/0x550
> >>     [61163.593908]  SYSC_move_pages+0x4ea/0x8f0
> >>     [61163.594253]  ? lru_cache_add_active_or_unevictable+0x4b/0xd0
> >>     [61163.594798]  SyS_move_pages+0xe/0x10
> >>     [61163.595113]  do_syscall_64+0x67/0x180
> >>     [61163.595434]  entry_SYSCALL64_slow_path+0x25/0x25
> >>     [61163.595837] RIP: 0033:0x7fc976e03949
> >>     [61163.596148] RSP: 002b:00007ffe72221d88 EFLAGS: 00000246 ORIG_RA=
X: 0000000000000117
> >>     [61163.596940] RAX: ffffffffffffffda RBX: 0000000000000000 RCX: 00=
007fc976e03949
> >>     [61163.597567] RDX: 0000000000c22390 RSI: 0000000000001400 RDI: 00=
00000000005827
> >>     [61163.598177] RBP: 00007ffe72221e00 R08: 0000000000c2c3a0 R09: 00=
00000000000004
> >>     [61163.598842] R10: 0000000000c363b0 R11: 0000000000000246 R12: 00=
00000000400650
> >>     [61163.599456] R13: 00007ffe72221ee0 R14: 0000000000000000 R15: 00=
00000000000000
> >>     [61163.600067] Code: 81 e4 ff ff 1f 00 48 21 c2 49 c1 ec 0c 48 c1 =
ea 0c 4c 01 e2 49 bc 00 00 00 00 00 ea ff ff 48 c1 e2 06 49 01 d4 f6 45 bc =
04 74 90 <49> 8b 7c 24 20 40 f6 c7 01 75 2b 4c 89 e7 8b 47 1c 85 c0 7e 2a
> >>     [61163.601845] RIP: follow_huge_pmd+0x143/0x190 RSP: ffffc90004bdb=
cd0
> >>     [61163.602376] CR2: ffffea0011943820
> >>     [61163.602767] ---[ end trace e4f81353a2d23232 ]---
> >>     [61163.603236] Kernel panic - not syncing: Fatal exception
> >>     [61163.603706] Kernel Offset: disabled
> >>
> >> This bug is triggered when pmd_present() returns true for non-present
> >> hugetlb, so fixing the present check in follow_huge_pmd() prevents it.
> >> Using pmd_present() to determine present/non-present for hugetlb is
> >> not correct, because pmd_present() checks multiple bits (not only
> >> _PAGE_PRESENT) for historical reason and it can misjudge hugetlb state=
.
> >>
> >> Fixes: e66f17ff7177 ("mm/hugetlb: take page table lock in follow_huge_=
pmd()")
> >> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> >> Cc: <stable@vger.kernel.org>        [4.0+]
> >=20
> > I think this is broken for s390. The page table entries look different =
from
> > the segment table entries (pmds) on s390, e.g. they have the invalid bi=
t at
> > different places. Using pte functions on pmd does not work here.
> > Gerald can you confirm.
> >=20
>=20
>=20
> Hmmm, it looks like that the s390 variant of huge_ptep_get already
> does the translation. So its probably fine.

Thank you for checking. I think so, generic hugetlb code should refer to
leaf level page table entries with 'pte' even if it's actually pmd or pud.
The detail of arch-dependency is contained in huge_ptep_get() as you pointe=
d out.

- Naoya=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
