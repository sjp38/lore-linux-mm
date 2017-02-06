Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 98A686B0033
	for <linux-mm@kvack.org>; Mon,  6 Feb 2017 18:27:27 -0500 (EST)
Received: by mail-oi0-f71.google.com with SMTP id u143so92364735oif.1
        for <linux-mm@kvack.org>; Mon, 06 Feb 2017 15:27:27 -0800 (PST)
Received: from tyo162.gate.nec.co.jp (tyo162.gate.nec.co.jp. [114.179.232.162])
        by mx.google.com with ESMTPS id 102si861103otn.49.2017.02.06.15.27.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Feb 2017 15:27:26 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v3 03/14] mm: use pmd lock instead of racy checks in
 zap_pmd_range()
Date: Mon, 6 Feb 2017 23:22:19 +0000
Message-ID: <20170206232218.GD1659@hori1.linux.bs1.fc.nec.co.jp>
References: <20170205161252.85004-1-zi.yan@sent.com>
 <20170205161252.85004-4-zi.yan@sent.com>
 <20170206074337.GB30339@hori1.linux.bs1.fc.nec.co.jp>
 <786096BE-B071-4635-B92F-348BB72D2304@sent.com>
In-Reply-To: <786096BE-B071-4635-B92F-348BB72D2304@sent.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <B72FA9C3C37F614CA88773D37B9DD71E@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zi Yan <zi.yan@sent.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "minchan@kernel.org" <minchan@kernel.org>, "vbabka@suse.cz" <vbabka@suse.cz>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "khandual@linux.vnet.ibm.com" <khandual@linux.vnet.ibm.com>, Zi Yan <ziy@nvidia.com>

On Mon, Feb 06, 2017 at 07:02:41AM -0600, Zi Yan wrote:
> On 6 Feb 2017, at 1:43, Naoya Horiguchi wrote:
>=20
> > On Sun, Feb 05, 2017 at 11:12:41AM -0500, Zi Yan wrote:
> >> From: Zi Yan <ziy@nvidia.com>
> >>
> >> Originally, zap_pmd_range() checks pmd value without taking pmd lock.
> >> This can cause pmd_protnone entry not being freed.
> >>
> >> Because there are two steps in changing a pmd entry to a pmd_protnone
> >> entry. First, the pmd entry is cleared to a pmd_none entry, then,
> >> the pmd_none entry is changed into a pmd_protnone entry.
> >> The racy check, even with barrier, might only see the pmd_none entry
> >> in zap_pmd_range(), thus, the mapping is neither split nor zapped.
> >>
> >> Later, in free_pmd_range(), pmd_none_or_clear() will see the
> >> pmd_protnone entry and clear it as a pmd_bad entry. Furthermore,
> >> since the pmd_protnone entry is not properly freed, the corresponding
> >> deposited pte page table is not freed either.
> >>
> >> This causes memory leak or kernel crashing, if VM_BUG_ON() is enabled.
> >>
> >> This patch relies on __split_huge_pmd_locked() and
> >> __zap_huge_pmd_locked().
> >>
> >> Signed-off-by: Zi Yan <zi.yan@cs.rutgers.edu>
> >> ---
> >>  mm/memory.c | 24 +++++++++++-------------
> >>  1 file changed, 11 insertions(+), 13 deletions(-)
> >>
> >> diff --git a/mm/memory.c b/mm/memory.c
> >> index 3929b015faf7..7cfdd5208ef5 100644
> >> --- a/mm/memory.c
> >> +++ b/mm/memory.c
> >> @@ -1233,33 +1233,31 @@ static inline unsigned long zap_pmd_range(stru=
ct mmu_gather *tlb,
> >>  				struct zap_details *details)
> >>  {
> >>  	pmd_t *pmd;
> >> +	spinlock_t *ptl;
> >>  	unsigned long next;
> >>
> >>  	pmd =3D pmd_offset(pud, addr);
> >> +	ptl =3D pmd_lock(vma->vm_mm, pmd);
> >
> > If USE_SPLIT_PMD_PTLOCKS is true, pmd_lock() returns different ptl for
> > each pmd. The following code runs over pmds within [addr, end) with
> > a single ptl (of the first pmd,) so I suspect this locking really works=
.
> > Maybe pmd_lock() should be called inside while loop?
>=20
> According to include/linux/mm.h, pmd_lockptr() first gets the page the pm=
d is in,
> using mask =3D ~(PTRS_PER_PMD * sizeof(pmd_t) -1) =3D 0xfffffffffffff000 =
and virt_to_page().
> Then, ptlock_ptr() gets spinlock_t either from page->ptl (split case) or
> mm->page_table_lock (not split case).
>=20
> It seems to me that all PMDs in one page table page share a single spinlo=
ck. Let me know
> if I misunderstand any code.

Thanks for clarification, it was my misunderstanding.

Naoya

>=20
> But your suggestion can avoid holding the pmd lock for long without cond_=
sched(),
> I can move the spinlock inside the loop.
>=20
> Thanks.
>=20
> diff --git a/mm/memory.c b/mm/memory.c
> index 5299b261c4b4..ff61d45eaea7 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -1260,31 +1260,34 @@ static inline unsigned long zap_pmd_range(struct =
mmu_gather *tlb,
>                                 struct zap_details *details)
>  {
>         pmd_t *pmd;
> -       spinlock_t *ptl;
> +       spinlock_t *ptl =3D NULL;
>         unsigned long next;
>=20
>         pmd =3D pmd_offset(pud, addr);
> -       ptl =3D pmd_lock(vma->vm_mm, pmd);
>         do {
> +               ptl =3D pmd_lock(vma->vm_mm, pmd);
>                 next =3D pmd_addr_end(addr, end);
>                 if (is_swap_pmd(*pmd) || pmd_trans_huge(*pmd) || pmd_devm=
ap(*pmd)) {
>                         if (next - addr !=3D HPAGE_PMD_SIZE) {
>                                 VM_BUG_ON_VMA(vma_is_anonymous(vma) &&
>                                     !rwsem_is_locked(&tlb->mm->mmap_sem),=
 vma);
>                                 __split_huge_pmd_locked(vma, pmd, addr, f=
alse);
> -                       } else if (__zap_huge_pmd_locked(tlb, vma, pmd, a=
ddr))
> -                               continue;
> +                       } else if (__zap_huge_pmd_locked(tlb, vma, pmd, a=
ddr)) {
> +                               spin_unlock(ptl);
> +                               goto next;
> +                       }
>                         /* fall through */
>                 }
>=20
> -               if (pmd_none_or_clear_bad(pmd))
> -                       continue;
> +               if (pmd_none_or_clear_bad(pmd)) {
> +                       spin_unlock(ptl);
> +                       goto next;
> +               }
>                 spin_unlock(ptl);
>                 next =3D zap_pte_range(tlb, vma, pmd, addr, next, details=
);
> +next:
>                 cond_resched();
> -               spin_lock(ptl);
>         } while (pmd++, addr =3D next, addr !=3D end);
> -       spin_unlock(ptl);
>=20
>         return addr;
>  }
>=20
>=20
> >
> > Thanks,
> > Naoya Horiguchi
> >
> >>  	do {
> >>  		next =3D pmd_addr_end(addr, end);
> >>  		if (pmd_trans_huge(*pmd) || pmd_devmap(*pmd)) {
> >>  			if (next - addr !=3D HPAGE_PMD_SIZE) {
> >>  				VM_BUG_ON_VMA(vma_is_anonymous(vma) &&
> >>  				    !rwsem_is_locked(&tlb->mm->mmap_sem), vma);
> >> -				__split_huge_pmd(vma, pmd, addr, false, NULL);
> >> -			} else if (zap_huge_pmd(tlb, vma, pmd, addr))
> >> -				goto next;
> >> +				__split_huge_pmd_locked(vma, pmd, addr, false);
> >> +			} else if (__zap_huge_pmd_locked(tlb, vma, pmd, addr))
> >> +				continue;
> >>  			/* fall through */
> >>  		}
> >> -		/*
> >> -		 * Here there can be other concurrent MADV_DONTNEED or
> >> -		 * trans huge page faults running, and if the pmd is
> >> -		 * none or trans huge it can change under us. This is
> >> -		 * because MADV_DONTNEED holds the mmap_sem in read
> >> -		 * mode.
> >> -		 */
> >> -		if (pmd_none_or_trans_huge_or_clear_bad(pmd))
> >> -			goto next;
> >> +
> >> +		if (pmd_none_or_clear_bad(pmd))
> >> +			continue;
> >> +		spin_unlock(ptl);
> >>  		next =3D zap_pte_range(tlb, vma, pmd, addr, next, details);
> >> -next:
> >>  		cond_resched();
> >> +		spin_lock(ptl);
> >>  	} while (pmd++, addr =3D next, addr !=3D end);
> >> +	spin_unlock(ptl);
> >>
> >>  	return addr;
> >>  }
> >> --=20
> >> 2.11.0
> >>
>=20
>=20
> --
> Best Regards
> Yan Zi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
