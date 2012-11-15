Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id 598236B0070
	for <linux-mm@kvack.org>; Thu, 15 Nov 2012 04:23:45 -0500 (EST)
Date: Thu, 15 Nov 2012 11:24:51 +0200
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH v5 07/11] thp: implement splitting pmd for huge zero page
Message-ID: <20121115092451.GE9676@otc-wbsnb-06>
References: <1352300463-12627-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1352300463-12627-8-git-send-email-kirill.shutemov@linux.intel.com>
 <alpine.DEB.2.00.1211141524010.22537@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="Oiv9uiLrevHtW1RS"
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1211141524010.22537@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, "H. Peter Anvin" <hpa@linux.intel.com>, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill@shutemov.name>


--Oiv9uiLrevHtW1RS
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Nov 14, 2012 at 03:28:15PM -0800, David Rientjes wrote:
> On Wed, 7 Nov 2012, Kirill A. Shutemov wrote:
>=20
> > diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> > index 90e651c..f36bc7d 100644
> > --- a/mm/huge_memory.c
> > +++ b/mm/huge_memory.c
> > @@ -1611,6 +1611,7 @@ int split_huge_page(struct page *page)
> >  	struct anon_vma *anon_vma;
> >  	int ret =3D 1;
> > =20
> > +	BUG_ON(is_huge_zero_pfn(page_to_pfn(page)));
> >  	BUG_ON(!PageAnon(page));
> >  	anon_vma =3D page_lock_anon_vma(page);
> >  	if (!anon_vma)
> > @@ -2509,23 +2510,63 @@ static int khugepaged(void *none)
> >  	return 0;
> >  }
> > =20
> > +static void __split_huge_zero_page_pmd(struct vm_area_struct *vma,
> > +		unsigned long haddr, pmd_t *pmd)
> > +{
>=20
> This entire function duplicates other code in mm/huge_memory.c which give=
s=20
> even more incentive into breaking do_huge_pmd_wp_zero_page_fallback() int=
o=20
> logical helper functions and reusing them for both page and !page. =20
> Duplicating all this code throughout the thp code just becomes a=20
> maintenance nightmare down the road.

Okay, I'll try.

> > +	pgtable_t pgtable;
> > +	pmd_t _pmd;
> > +	int i;
> > +
> > +	pmdp_clear_flush(vma, haddr, pmd);
> > +	/* leave pmd empty until pte is filled */
> > +
> > +	pgtable =3D get_pmd_huge_pte(vma->vm_mm);
> > +	pmd_populate(vma->vm_mm, &_pmd, pgtable);
> > +
> > +	for (i =3D 0; i < HPAGE_PMD_NR; i++, haddr +=3D PAGE_SIZE) {
> > +		pte_t *pte, entry;
> > +		entry =3D pfn_pte(my_zero_pfn(haddr), vma->vm_page_prot);
> > +		entry =3D pte_mkspecial(entry);
> > +		pte =3D pte_offset_map(&_pmd, haddr);
> > +		VM_BUG_ON(!pte_none(*pte));
> > +		set_pte_at(vma->vm_mm, haddr, pte, entry);
> > +		pte_unmap(pte);
> > +	}
> > +	smp_wmb(); /* make pte visible before pmd */
> > +	pmd_populate(vma->vm_mm, pmd, pgtable);
> > +}
> > +
> >  void __split_huge_page_pmd(struct vm_area_struct *vma, unsigned long a=
ddress,
> >  		pmd_t *pmd)
> >  {
> >  	struct page *page;
> > +	struct mm_struct *mm =3D vma->vm_mm;
> >  	unsigned long haddr =3D address & HPAGE_PMD_MASK;
> > +	unsigned long mmun_start;	/* For mmu_notifiers */
> > +	unsigned long mmun_end;		/* For mmu_notifiers */
> > =20
> >  	BUG_ON(vma->vm_start > haddr || vma->vm_end < haddr + HPAGE_PMD_SIZE);
> > =20
> > -	spin_lock(&vma->vm_mm->page_table_lock);
> > +	mmun_start =3D haddr;
> > +	mmun_end   =3D address + HPAGE_PMD_SIZE;
>=20
> address or haddr?

haddr. I'll fix.

--=20
 Kirill A. Shutemov

--Oiv9uiLrevHtW1RS
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJQpLTjAAoJEAd+omnVudOM+wsQALniVCI+LqtwvOmAIyDo4nBx
ENFer1WxW3asHbwxe2XRTG9J75xjoOu4VZMWe6EqFr9iqpdDFZFcCqfPHJKOTNQv
UEA7bCPh4IWtQ4kqBri3VbXnmt13/5RUhyH3MaNcIYZTp+kqR2QlsCIjOi1Pozcf
z6J1aHfWt5KNzHdi/8j4Gxb0XxknRO1k6cRjhs+r4bomV4hMnNhOIEapILsFqwNT
cyQICoV2Sz24CWuP+8zn8cKNe/ZjS6u5FVzDfQ6TQZw/ZydUnCYkcMiIL6Zf0+KS
xjN8QiGjg+/3JchmeA9jDX3zIoy7okOBFpDi9WL43/RO/6aBx0Xf+NVWvNKJV5KD
mLoEa2bkpABEpnkJq5PNPOT3lE86+NtF1pFHR+YTA5tImLUDp5hIvjMOGIWknR0u
MJ/DLeaCJfZC6bFbuHXEcIOAVbYQR1BZrphSg9IN4n3qM0efA0YqQ8mCcQ/K38Z8
fPcENmkOeJQR7OSG+2SAFsNivyTGgVlHCzG2/psYRVDF6GHAofdohz+rsQfOosI7
pD/23EzIAvN1iHDn1sTWhkwdnwWQpI1VksVVuPsSVclBmZ7XVEzsWiVRDVCd9p6P
7nh7ZbfSEQ3R0ZUjAUXpUefGrwbksiVI0s/Qwk2duajiFM+u5UC5wHOX9SSIFk0U
/RLWPjeVHo1e+n42QXix
=Iumx
-----END PGP SIGNATURE-----

--Oiv9uiLrevHtW1RS--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
