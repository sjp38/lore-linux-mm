Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id 19E2C6B00A8
	for <linux-mm@kvack.org>; Thu, 15 Nov 2012 03:50:55 -0500 (EST)
Date: Thu, 15 Nov 2012 10:52:00 +0200
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH v5 06/11] thp: change split_huge_page_pmd() interface
Message-ID: <20121115085200.GD9676@otc-wbsnb-06>
References: <1352300463-12627-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1352300463-12627-7-git-send-email-kirill.shutemov@linux.intel.com>
 <alpine.DEB.2.00.1211141516570.22537@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="fXStkuK2IQBfcDe+"
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1211141516570.22537@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, "H. Peter Anvin" <hpa@linux.intel.com>, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill@shutemov.name>


--fXStkuK2IQBfcDe+
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Nov 14, 2012 at 03:22:03PM -0800, David Rientjes wrote:
> On Wed, 7 Nov 2012, Kirill A. Shutemov wrote:
>=20
> > diff --git a/Documentation/vm/transhuge.txt b/Documentation/vm/transhug=
e.txt
> > index f734bb2..677a599 100644
> > --- a/Documentation/vm/transhuge.txt
> > +++ b/Documentation/vm/transhuge.txt
> > @@ -276,7 +276,7 @@ unaffected. libhugetlbfs will also work fine as usu=
al.
> >  =3D=3D Graceful fallback =3D=3D
> > =20
> >  Code walking pagetables but unware about huge pmds can simply call
> > -split_huge_page_pmd(mm, pmd) where the pmd is the one returned by
> > +split_huge_page_pmd(vma, pmd, addr) where the pmd is the one returned =
by
> >  pmd_offset. It's trivial to make the code transparent hugepage aware
> >  by just grepping for "pmd_offset" and adding split_huge_page_pmd where
> >  missing after pmd_offset returns the pmd. Thanks to the graceful
> > @@ -299,7 +299,7 @@ diff --git a/mm/mremap.c b/mm/mremap.c
> >  		return NULL;
> > =20
> >  	pmd =3D pmd_offset(pud, addr);
> > -+	split_huge_page_pmd(mm, pmd);
> > ++	split_huge_page_pmd(vma, pmd, addr);
> >  	if (pmd_none_or_clear_bad(pmd))
> >  		return NULL;
> > =20
> > diff --git a/arch/x86/kernel/vm86_32.c b/arch/x86/kernel/vm86_32.c
> > index 5c9687b..1dfe69c 100644
> > --- a/arch/x86/kernel/vm86_32.c
> > +++ b/arch/x86/kernel/vm86_32.c
> > @@ -182,7 +182,7 @@ static void mark_screen_rdonly(struct mm_struct *mm)
> >  	if (pud_none_or_clear_bad(pud))
> >  		goto out;
> >  	pmd =3D pmd_offset(pud, 0xA0000);
> > -	split_huge_page_pmd(mm, pmd);
> > +	split_huge_page_pmd_mm(mm, 0xA0000, pmd);
> >  	if (pmd_none_or_clear_bad(pmd))
> >  		goto out;
> >  	pte =3D pte_offset_map_lock(mm, pmd, 0xA0000, &ptl);
>=20
> Why not be consistent and make this split_huge_page_pmd_mm(mm, pmd, addr)?
>=20
> > diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> > index 90c63f9..291a0d1 100644
> > --- a/fs/proc/task_mmu.c
> > +++ b/fs/proc/task_mmu.c
> > @@ -643,7 +643,7 @@ static int clear_refs_pte_range(pmd_t *pmd, unsigne=
d long addr,
> >  	spinlock_t *ptl;
> >  	struct page *page;
> > =20
> > -	split_huge_page_pmd(walk->mm, pmd);
> > +	split_huge_page_pmd(vma, addr, pmd);
>=20
> Ah, it's because the change to the documentation is wrong: the format is=
=20
> actually split_huge_page_pmd(vma, addr, pmd).

Thanks, will fix.

> >  	if (pmd_trans_unstable(pmd))
> >  		return 0;
> > =20
> > diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
> > index b31cb7d..856f080 100644
> > --- a/include/linux/huge_mm.h
> > +++ b/include/linux/huge_mm.h
> > @@ -91,12 +91,14 @@ extern int handle_pte_fault(struct mm_struct *mm,
> >  			    struct vm_area_struct *vma, unsigned long address,
> >  			    pte_t *pte, pmd_t *pmd, unsigned int flags);
> >  extern int split_huge_page(struct page *page);
> > -extern void __split_huge_page_pmd(struct mm_struct *mm, pmd_t *pmd);
> > -#define split_huge_page_pmd(__mm, __pmd)				\
> > +extern void __split_huge_page_pmd(struct vm_area_struct *vma,
> > +		unsigned long address, pmd_t *pmd);
> > +#define split_huge_page_pmd(__vma, __address, __pmd)			\
> >  	do {								\
> >  		pmd_t *____pmd =3D (__pmd);				\
> >  		if (unlikely(pmd_trans_huge(*____pmd)))			\
> > -			__split_huge_page_pmd(__mm, ____pmd);		\
> > +			__split_huge_page_pmd(__vma, __address,		\
> > +					____pmd);			\
> >  	}  while (0)
> >  #define wait_split_huge_page(__anon_vma, __pmd)				\
> >  	do {								\
> > @@ -106,6 +108,8 @@ extern void __split_huge_page_pmd(struct mm_struct =
*mm, pmd_t *pmd);
> >  		BUG_ON(pmd_trans_splitting(*____pmd) ||			\
> >  		       pmd_trans_huge(*____pmd));			\
> >  	} while (0)
> > +extern void split_huge_page_pmd_mm(struct mm_struct *mm, unsigned long=
 address,
> > +		pmd_t *pmd);
> >  #if HPAGE_PMD_ORDER > MAX_ORDER
> >  #error "hugepages can't be allocated by the buddy allocator"
> >  #endif
> > @@ -173,10 +177,12 @@ static inline int split_huge_page(struct page *pa=
ge)
> >  {
> >  	return 0;
> >  }
> > -#define split_huge_page_pmd(__mm, __pmd)	\
> > +#define split_huge_page_pmd(__vma, __address, __pmd)	\
> >  	do { } while (0)
> >  #define wait_split_huge_page(__anon_vma, __pmd)	\
> >  	do { } while (0)
> > +#define split_huge_page_pmd_mm(__mm, __address, __pmd)	\
> > +	do { } while (0)
> >  #define compound_trans_head(page) compound_head(page)
> >  static inline int hugepage_madvise(struct vm_area_struct *vma,
> >  				   unsigned long *vm_flags, int advice)
> > diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> > index 05490b3..90e651c 100644
> > --- a/mm/huge_memory.c
> > +++ b/mm/huge_memory.c
> > @@ -2509,19 +2509,23 @@ static int khugepaged(void *none)
> >  	return 0;
> >  }
> > =20
> > -void __split_huge_page_pmd(struct mm_struct *mm, pmd_t *pmd)
> > +void __split_huge_page_pmd(struct vm_area_struct *vma, unsigned long a=
ddress,
> > +		pmd_t *pmd)
> >  {
> >  	struct page *page;
> > +	unsigned long haddr =3D address & HPAGE_PMD_MASK;
> >=20
>=20
> Just do
>=20
> 	struct mm_struct *mm =3D vma->vm_mm;
>=20
> here and it makes everything else simpler.

Okay.

> > -	spin_lock(&mm->page_table_lock);
> > +	BUG_ON(vma->vm_start > haddr || vma->vm_end < haddr + HPAGE_PMD_SIZE);
> > +
> > +	spin_lock(&vma->vm_mm->page_table_lock);
> >  	if (unlikely(!pmd_trans_huge(*pmd))) {
> > -		spin_unlock(&mm->page_table_lock);
> > +		spin_unlock(&vma->vm_mm->page_table_lock);
> >  		return;
> >  	}
> >  	page =3D pmd_page(*pmd);
> >  	VM_BUG_ON(!page_count(page));
> >  	get_page(page);
> > -	spin_unlock(&mm->page_table_lock);
> > +	spin_unlock(&vma->vm_mm->page_table_lock);
> > =20
> >  	split_huge_page(page);
> > =20

--=20
 Kirill A. Shutemov

--fXStkuK2IQBfcDe+
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJQpK0wAAoJEAd+omnVudOM0KcP/A3s7sj93lp0PUv3rkitDEyY
z4g3S+ocV6U3BbPw1cjY0uGt8egLjYcRPEhuhe7zMO7QACDNqlvrVTPXKWDQOMy8
v0MDjrU28oCp/0EkkSwFk9AyOOmicxMaQRPljvg5s9v66r6FLN738GoscprzJS5e
Ct2KBsFhCP8hQX8l+zmYHWrtm7jK84gw7a5WKcGqXQw1DJe4KYDjxzyeUgKdNa29
77xSTsfoUwzEwpU4o6ZtWg9N3Y0mw5rpoyJnjTeeQTyymyLLIEcHMXPGkOw9WBv2
GXg/qR+o8x6CVoweMXEITEtNmIwkALoNEU2ReAwkujoCGl+lrBiRlb8MAGwEM8wC
LV9N73Zz4ZGL/VHa5NEja77K/Ri2OH4XtlhCqAnfNA2LHmeAMrGkJeS8ZNcGMsPF
veFypHLrAJewN34J04v9oxwU9HrWiOsrl2Sul7ivD7LXO4n/UyYpKawUiU96gub2
24Wf3FacpEK9pQOdWJQnpbsOCCQLDJWpQkAa/pU0ko0CNN4eNYeIapCpczbdsw+d
OVXF1GtbjKzBmaGnuGdcCZezAodALFXfrJwtIEg56iE28MQlGtO+Z663rTrM3DtN
qTYmxpoEG7jKh0ZWKm/uRyrEyc5GqaNhNXRlTd6TMWBhgWq8VXjZxmGTIqeJfOFX
0gjtC0N4uQb/TcoR9vMM
=CSfF
-----END PGP SIGNATURE-----

--fXStkuK2IQBfcDe+--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
