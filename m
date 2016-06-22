Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7A9C56B0005
	for <linux-mm@kvack.org>; Tue, 21 Jun 2016 21:43:05 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id b13so62305460pat.3
        for <linux-mm@kvack.org>; Tue, 21 Jun 2016 18:43:05 -0700 (PDT)
Received: from tyo200.gate.nec.co.jp (TYO200.gate.nec.co.jp. [210.143.35.50])
        by mx.google.com with ESMTPS id or6si7760778pac.233.2016.06.21.18.43.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 21 Jun 2016 18:43:04 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v1 1/2] mm: thp: move pmd check inside ptl for
 freeze_page()
Date: Wed, 22 Jun 2016 01:37:00 +0000
Message-ID: <20160622013659.GA6715@hori1.linux.bs1.fc.nec.co.jp>
References: <1466130604-20484-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20160617084041.GA28105@node.shutemov.name>
 <20160620085502.GA17560@hori1.linux.bs1.fc.nec.co.jp>
 <20160620093201.GB27871@node.shutemov.name>
 <20160621150433.GA7536@node.shutemov.name>
In-Reply-To: <20160621150433.GA7536@node.shutemov.name>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <7D4C499A9C76E04DA1CF74A4C0A404E8@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@suse.cz>, Vlastimil Babka <vbabka@suse.cz>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Tue, Jun 21, 2016 at 06:04:33PM +0300, Kirill A. Shutemov wrote:
> On Mon, Jun 20, 2016 at 12:32:01PM +0300, Kirill A. Shutemov wrote:
> > > +void split_huge_pmd_address_freeze(struct vm_area_struct *vma,
> > > +				unsigned long address, struct page *page)
> > > +{
> > > +	pgd_t *pgd;
> > > +	pud_t *pud;
> > > +	pmd_t *pmd;
> > > +
> > > +	pgd =3D pgd_offset(vma->vm_mm, address);
> > > +	if (!pgd_present(*pgd))
> > > +		return;
> > > +
> > > +	pud =3D pud_offset(pgd, address);
> > > +	if (!pud_present(*pud))
> > > +		return;
> > > +
> > > +	pmd =3D pmd_offset(pud, address);
> > > +	__split_huge_pmd(vma, pmd, address, page, true);
> > >  }
> >=20
> > I don't see a reason to introduce new function. Just move the page
> > check under ptl from split_huge_pmd_address() and that should be enough=
.

Sorry for my slow response (I was offline yesterday.)

My point of separating function is to avoid checking pmd_present outside pt=
l
just for freeze=3Dtrue case (I didn't want affect other path,
i.e. from vma_adjust_trans_huge().)
But I think that the new function is unnecessary if we move the following
part of split_huge_pmd_address() into ptl,

        if (!pmd_present(*pmd) || (!pmd_trans_huge(*pmd) && !pmd_devmap(*pm=
d)))
                return;

Does it make sense?

> > Or am I missing something?
>=20
> I'm talking about something like patch below. Could you test it?

Thanks, with this patch my 3-hour testing doesn't trigger the problem,
so it works. But I feel it's weird because I think that the source of the
race is "if (!pmd_present)" check in split_huge_pmd_address() called outsid=
e ptl.
Your patch doesn't change that part, so I'm not sure why this fix works.

> If it works fine to you, feel free to submit with my Signed-off-by.
>=20
> diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
> index eb810816bbc6..92ce91c03cd0 100644
> --- a/include/linux/huge_mm.h
> +++ b/include/linux/huge_mm.h
> @@ -98,7 +98,7 @@ static inline int split_huge_page(struct page *page)
>  void deferred_split_huge_page(struct page *page);
> =20
>  void __split_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
> -		unsigned long address, bool freeze);
> +		unsigned long address, bool freeze, struct page *page);
> =20
>  #define split_huge_pmd(__vma, __pmd, __address)				\
>  	do {								\
> @@ -106,7 +106,7 @@ void __split_huge_pmd(struct vm_area_struct *vma, pmd=
_t *pmd,
>  		if (pmd_trans_huge(*____pmd)				\
>  					|| pmd_devmap(*____pmd))	\
>  			__split_huge_pmd(__vma, __pmd, __address,	\
> -						false);			\
> +						false, NULL);		\
>  	}  while (0)
> =20
> =20
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index eaf3a4a655a6..2297aa41581e 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -1638,7 +1638,7 @@ static void __split_huge_pmd_locked(struct vm_area_=
struct *vma, pmd_t *pmd,
>  }
> =20
>  void __split_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
> -		unsigned long address, bool freeze)
> +		unsigned long address, bool freeze, struct page *page)
>  {
>  	spinlock_t *ptl;
>  	struct mm_struct *mm =3D vma->vm_mm;
> @@ -1646,8 +1646,17 @@ void __split_huge_pmd(struct vm_area_struct *vma, =
pmd_t *pmd,
> =20
>  	mmu_notifier_invalidate_range_start(mm, haddr, haddr + HPAGE_PMD_SIZE);
>  	ptl =3D pmd_lock(mm, pmd);
> +
> +	/*
> +	 * If caller asks to setup a migration entries, we need a page to check
> +	 * pmd against. Otherwise we can end up replacing wrong page.
> +	 */
> +	VM_BUG_ON(freeze && !page);
> +	if (page && page !=3D pmd_page(*pmd))
> +		goto out;
> +
>  	if (pmd_trans_huge(*pmd)) {
> -		struct page *page =3D pmd_page(*pmd);
> +		page =3D pmd_page(*pmd);
>  		if (PageMlocked(page))
>  			clear_page_mlock(page);
>  	} else if (!pmd_devmap(*pmd))
> @@ -1678,20 +1687,12 @@ void split_huge_pmd_address(struct vm_area_struct=
 *vma, unsigned long address,
>  		return;
> =20
>  	/*
> -	 * If caller asks to setup a migration entries, we need a page to check
> -	 * pmd against. Otherwise we can end up replacing wrong page.
> -	 */
> -	VM_BUG_ON(freeze && !page);
> -	if (page && page !=3D pmd_page(*pmd))
> -		return;
> -
> -	/*
>  	 * Caller holds the mmap_sem write mode or the anon_vma lock,
>  	 * so a huge pmd cannot materialize from under us (khugepaged
>  	 * holds both the mmap_sem write mode and the anon_vma lock
>  	 * write mode).

Not a big issue, but this comment about mmap_sem seems relevant only when
called from vma_adjust_trans_huge(), so might need some update?

>  	 */
> -	__split_huge_pmd(vma, pmd, address, freeze);
> +	__split_huge_pmd(vma, pmd, address, freeze, page);
>  }
> =20
>  void vma_adjust_trans_huge(struct vm_area_struct *vma,
> --=20
>  Kirill A. Shutemov
> =

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
