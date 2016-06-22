Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 89C326B0005
	for <linux-mm@kvack.org>; Tue, 21 Jun 2016 22:53:06 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id fg1so63744075pad.1
        for <linux-mm@kvack.org>; Tue, 21 Jun 2016 19:53:06 -0700 (PDT)
Received: from tyo200.gate.nec.co.jp (TYO200.gate.nec.co.jp. [210.143.35.50])
        by mx.google.com with ESMTPS id gg9si12628073pac.111.2016.06.21.19.53.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 21 Jun 2016 19:53:04 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v1 1/2] mm: thp: move pmd check inside ptl for
 freeze_page()
Date: Wed, 22 Jun 2016 02:42:25 +0000
Message-ID: <20160622024224.GB5662@hori1.linux.bs1.fc.nec.co.jp>
References: <1466130604-20484-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20160617084041.GA28105@node.shutemov.name>
 <20160620085502.GA17560@hori1.linux.bs1.fc.nec.co.jp>
 <20160620093201.GB27871@node.shutemov.name>
 <20160621150433.GA7536@node.shutemov.name>
 <20160622013659.GA6715@hori1.linux.bs1.fc.nec.co.jp>
In-Reply-To: <20160622013659.GA6715@hori1.linux.bs1.fc.nec.co.jp>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <19E1BEDC43AFD449BEADFE4552AED9D9@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@suse.cz>, Vlastimil Babka <vbabka@suse.cz>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Wed, Jun 22, 2016 at 01:37:00AM +0000, Horiguchi Naoya(=1B$BKY8}=1B(B =
=1B$BD>Li=1B(B) wrote:
> On Tue, Jun 21, 2016 at 06:04:33PM +0300, Kirill A. Shutemov wrote:
> > On Mon, Jun 20, 2016 at 12:32:01PM +0300, Kirill A. Shutemov wrote:
> > > > +void split_huge_pmd_address_freeze(struct vm_area_struct *vma,
> > > > +				unsigned long address, struct page *page)
> > > > +{
> > > > +	pgd_t *pgd;
> > > > +	pud_t *pud;
> > > > +	pmd_t *pmd;
> > > > +
> > > > +	pgd =3D pgd_offset(vma->vm_mm, address);
> > > > +	if (!pgd_present(*pgd))
> > > > +		return;
> > > > +
> > > > +	pud =3D pud_offset(pgd, address);
> > > > +	if (!pud_present(*pud))
> > > > +		return;
> > > > +
> > > > +	pmd =3D pmd_offset(pud, address);
> > > > +	__split_huge_pmd(vma, pmd, address, page, true);
> > > >  }
> > >=20
> > > I don't see a reason to introduce new function. Just move the page
> > > check under ptl from split_huge_pmd_address() and that should be enou=
gh.
>=20
> Sorry for my slow response (I was offline yesterday.)
>=20
> My point of separating function is to avoid checking pmd_present outside =
ptl
> just for freeze=3Dtrue case (I didn't want affect other path,
> i.e. from vma_adjust_trans_huge().)
> But I think that the new function is unnecessary if we move the following
> part of split_huge_pmd_address() into ptl,
>=20
>         if (!pmd_present(*pmd) || (!pmd_trans_huge(*pmd) && !pmd_devmap(*=
pmd)))
>                 return;
>=20
> Does it make sense?
>=20
> > > Or am I missing something?
> >=20
> > I'm talking about something like patch below. Could you test it?
>=20
> Thanks, with this patch my 3-hour testing doesn't trigger the problem,
> so it works. But I feel it's weird because I think that the source of the
> race is "if (!pmd_present)" check in split_huge_pmd_address() called outs=
ide ptl.
> Your patch doesn't change that part, so I'm not sure why this fix works.

Hmm, after sending previous email, I found the bug triggered with your patc=
h.
So I updated the patch with removing the prechecks.

Thanks,
Naoya Horiguchi
---
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Date: Wed, 22 Jun 2016 11:34:47 +0900
Subject: [PATCH] mm: thp: move pmd check inside ptl for freeze_page()

I found a race condition triggering VM_BUG_ON() in freeze_page(), when runn=
ing
a testcase with 3 processes:
  - process 1: keep writing thp,
  - process 2: keep clearing soft-dirty bits from virtual address of proces=
s 1
  - process 3: call migratepages for process 1,

The kernel message is like this:

  kernel BUG at /src/linux-dev/mm/huge_memory.c:3096!
  invalid opcode: 0000 [#1] SMP
  Modules linked in: cfg80211 rfkill crc32c_intel ppdev serio_raw pcspkr vi=
rtio_balloon virtio_console parport_pc parport pvpanic acpi_cpufreq tpm_tis=
 tpm i2c_piix4 virtio_blk virtio_net ata_generic pata_acpi floppy virtio_pc=
i virtio_ring virtio
  CPU: 0 PID: 28863 Comm: migratepages Not tainted 4.6.0-v4.6-160602-0827-+=
 #2
  Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
  task: ffff880037320000 ti: ffff88007cdd0000 task.ti: ffff88007cdd0000
  RIP: 0010:[<ffffffff811f8e06>]  [<ffffffff811f8e06>] split_huge_page_to_l=
ist+0x496/0x590
  RSP: 0018:ffff88007cdd3b70  EFLAGS: 00010202
  RAX: 0000000000000001 RBX: ffff88007c7b88c0 RCX: 0000000000000000
  RDX: 0000000000000000 RSI: 0000000700000200 RDI: ffffea0003188000
  RBP: ffff88007cdd3bb8 R08: 0000000000000001 R09: 00003ffffffff000
  R10: ffff880000000000 R11: ffffc000001fffff R12: ffffea0003188000
  R13: ffffea0003188000 R14: 0000000000000000 R15: 0400000000000080
  FS:  00007f8ec241d740(0000) GS:ffff88007dc00000(0000) knlGS:0000000000000=
000             CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
  CR2: 00007f8ec1f3ed20 CR3: 000000003707b000 CR4: 00000000000006f0
  Stack:
   ffffffff8139ef6d ffffea00031c6280 ffff88011ffec000 0000000000000000
   0000700000400000 0000700000200000 ffff88007cdd3d08 ffff8800dbbe3008
   0400000000000080 ffff88007cdd3c20 ffffffff811dd0b1 ffff88007cdd3d68
  Call Trace:
   [<ffffffff8139ef6d>] ? list_del+0xd/0x30
   [<ffffffff811dd0b1>] queue_pages_pte_range+0x4d1/0x590
   [<ffffffff811ca1a4>] __walk_page_range+0x204/0x4e0
   [<ffffffff811ca4f1>] walk_page_range+0x71/0xf0
   [<ffffffff811db935>] queue_pages_range+0x75/0x90
   [<ffffffff811dcbe0>] ? queue_pages_hugetlb+0x190/0x190
   [<ffffffff811dca50>] ? new_node_page+0xc0/0xc0
   [<ffffffff811ddac0>] ? change_prot_numa+0x40/0x40
   [<ffffffff811dc001>] migrate_to_node+0x71/0xd0
   [<ffffffff811ddd73>] do_migrate_pages+0x1c3/0x210
   [<ffffffff811de0b1>] SyS_migrate_pages+0x261/0x290
   [<ffffffff816f53f2>] entry_SYSCALL_64_fastpath+0x1a/0xa4
  Code: e8 b0 87 fb ff 0f 0b 48 c7 c6 30 32 9f 81 e8 a2 87 fb ff 0f 0b 48 c=
7 c6 b8 46 9f 81 e8 94 87 fb ff 0f 0b 85 c0 0f 84 3e fd ff ff <0f> 0b 85 c0=
 0f 85 a6 00 00 00 48 8b 75 c0 4c 89 f7 41 be f0 ff
  RIP  [<ffffffff811f8e06>] split_huge_page_to_list+0x496/0x590
   RSP <ffff88007cdd3b70>

I'm not sure of the full scenario of the reproduction, but my debug showed =
that
split_huge_pmd_address(freeze=3Dtrue) returned without running main code of=
 pmd
splitting because pmd_present(*pmd) in precheck somehow returned 0.
If this happens, the subsequent try_to_unmap() fails and returns non-zero
(because page_mapcount() still > 0), and finally VM_BUG_ON() fires.
This patch tries to fix it by prechecking pmd state inside ptl.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
Diff from v2:
- don't use separate function

Diff from v1:
- passed page to __split_huge_pmd()
- dropped unnecessary !pmd_present check
- removed pmd_none check in split_huge_pmd_address_freeze because it's
  effectively done in __split_huge_pmd() with ptl.
---
 include/linux/huge_mm.h |  4 ++--
 mm/huge_memory.c        | 25 ++++++++++++-------------
 2 files changed, 14 insertions(+), 15 deletions(-)

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index d7b9e5346fba..a05ca41ae243 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -96,7 +96,7 @@ static inline int split_huge_page(struct page *page)
 void deferred_split_huge_page(struct page *page);
=20
 void __split_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
-		unsigned long address, bool freeze);
+		unsigned long address, bool freeze, struct page *page);
=20
 #define split_huge_pmd(__vma, __pmd, __address)				\
 	do {								\
@@ -104,7 +104,7 @@ void __split_huge_pmd(struct vm_area_struct *vma, pmd_t=
 *pmd,
 		if (pmd_trans_huge(*____pmd)				\
 					|| pmd_devmap(*____pmd))	\
 			__split_huge_pmd(__vma, __pmd, __address,	\
-						false);			\
+						false, NULL);		\
 	}  while (0)
=20
=20
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index b49ee126d4d1..44a3555c1d23 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2981,7 +2981,7 @@ static void __split_huge_pmd_locked(struct vm_area_st=
ruct *vma, pmd_t *pmd,
 }
=20
 void __split_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
-		unsigned long address, bool freeze)
+		unsigned long address, bool freeze, struct page *page)
 {
 	spinlock_t *ptl;
 	struct mm_struct *mm =3D vma->vm_mm;
@@ -2989,8 +2989,17 @@ void __split_huge_pmd(struct vm_area_struct *vma, pm=
d_t *pmd,
=20
 	mmu_notifier_invalidate_range_start(mm, haddr, haddr + HPAGE_PMD_SIZE);
 	ptl =3D pmd_lock(mm, pmd);
+
+	/*
+	 * If caller asks to setup a migration entries, we need a page to check
+	 * pmd against. Otherwise we can end up replacing wrong page.
+	 */
+	VM_BUG_ON(freeze && !page);
+	if (page && page !=3D pmd_page(*pmd))
+	        goto out;
+
 	if (pmd_trans_huge(*pmd)) {
-		struct page *page =3D pmd_page(*pmd);
+		page =3D pmd_page(*pmd);
 		if (PageMlocked(page))
 			clear_page_mlock(page);
 	} else if (!pmd_devmap(*pmd))
@@ -3017,22 +3026,12 @@ void split_huge_pmd_address(struct vm_area_struct *=
vma, unsigned long address,
 		return;
=20
 	pmd =3D pmd_offset(pud, address);
-	if (!pmd_present(*pmd) || (!pmd_trans_huge(*pmd) && !pmd_devmap(*pmd)))
-		return;
-
-	/*
-	 * If caller asks to setup a migration entries, we need a page to check
-	 * pmd against. Otherwise we can end up replacing wrong page.
-	 */
-	VM_BUG_ON(freeze && !page);
-	if (page && page !=3D pmd_page(*pmd))
-		return;
=20
 	/*
 	 * Caller holds the mmap_sem write mode, so a huge pmd cannot
 	 * materialize from under us.
 	 */
-	__split_huge_pmd(vma, pmd, address, freeze);
+	__split_huge_pmd(vma, pmd, address, freeze, page);
 }
=20
 void vma_adjust_trans_huge(struct vm_area_struct *vma,
--=20
2.5.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
