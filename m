Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id D22E2280278
	for <linux-mm@kvack.org>; Thu, 10 Nov 2016 17:52:24 -0500 (EST)
Received: by mail-pa0-f69.google.com with SMTP id kr7so31671838pab.5
        for <linux-mm@kvack.org>; Thu, 10 Nov 2016 14:52:24 -0800 (PST)
Received: from tyo202.gate.nec.co.jp (TYO202.gate.nec.co.jp. [210.143.35.52])
        by mx.google.com with ESMTPS id v5si5939162pag.30.2016.11.10.14.52.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 10 Nov 2016 14:52:23 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v2 05/12] mm: thp: add core routines for thp/pmd
 migration
Date: Thu, 10 Nov 2016 09:43:28 +0000
Message-ID: <20161110094327.GE9173@hori1.linux.bs1.fc.nec.co.jp>
References: <1478561517-4317-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1478561517-4317-6-git-send-email-n-horiguchi@ah.jp.nec.com>
 <58242FCF.50602@linux.vnet.ibm.com>
In-Reply-To: <58242FCF.50602@linux.vnet.ibm.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <E623130A30E4FB498C3E5F01334ADD59@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Pavel Emelyanov <xemul@parallels.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Balbir Singh <bsingharora@gmail.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Thu, Nov 10, 2016 at 01:59:03PM +0530, Anshuman Khandual wrote:
> On 11/08/2016 05:01 AM, Naoya Horiguchi wrote:
> > This patch prepares thp migration's core code. These code will be open =
when
> > unmap_and_move() stops unconditionally splitting thp and get_new_page()=
 starts
> > to allocate destination thps.
> >=20
>=20
> Snip
>=20
> > Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> > ---
> > ChangeLog v1 -> v2:
> > - support pte-mapped thp, doubly-mapped thp
> > ---
> >  arch/x86/include/asm/pgtable_64.h |   2 +
> >  include/linux/swapops.h           |  61 +++++++++++++++
> >  mm/huge_memory.c                  | 154 ++++++++++++++++++++++++++++++=
++++++++
> >  mm/migrate.c                      |  44 ++++++++++-
> >  mm/pgtable-generic.c              |   3 +-
> >  5 files changed, 262 insertions(+), 2 deletions(-)
>=20
>=20
> > diff --git v4.9-rc2-mmotm-2016-10-27-18-27/mm/pgtable-generic.c v4.9-rc=
2-mmotm-2016-10-27-18-27_patched/mm/pgtable-generic.c
> > index 71c5f91..6012343 100644
> > --- v4.9-rc2-mmotm-2016-10-27-18-27/mm/pgtable-generic.c
> > +++ v4.9-rc2-mmotm-2016-10-27-18-27_patched/mm/pgtable-generic.c
> > @@ -118,7 +118,8 @@ pmd_t pmdp_huge_clear_flush(struct vm_area_struct *=
vma, unsigned long address,
> >  {
> >  	pmd_t pmd;
> >  	VM_BUG_ON(address & ~HPAGE_PMD_MASK);
> > -	VM_BUG_ON(!pmd_trans_huge(*pmdp) && !pmd_devmap(*pmdp));
> > +	VM_BUG_ON(pmd_present(*pmdp) && !pmd_trans_huge(*pmdp) &&
> > +		  !pmd_devmap(*pmdp))
>=20
> Its a valid VM_BUG_ON check but is it related to THP migration or
> just a regular fix up ?

Without this change, this VM_BUG_ON always triggers when migration happens
on normal thp and it succeeds, so I included it here.

- Naoya Horiguchi=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
