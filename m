Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id 3B9B56B006C
	for <linux-mm@kvack.org>; Fri, 17 Aug 2012 04:12:48 -0400 (EDT)
Date: Fri, 17 Aug 2012 11:12:33 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH, RFC 7/9] thp: implement splitting pmd for huge zero page
Message-ID: <20120817081233.GB9833@otc-wbsnb-06>
References: <1344503300-9507-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1344503300-9507-8-git-send-email-kirill.shutemov@linux.intel.com>
 <20120816192738.GO11188@redhat.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="MfFXiAuoTsnnDAfZ"
Content-Disposition: inline
In-Reply-To: <20120816192738.GO11188@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, "H. Peter Anvin" <hpa@linux.intel.com>, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill@shutemov.name>


--MfFXiAuoTsnnDAfZ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Aug 16, 2012 at 09:27:38PM +0200, Andrea Arcangeli wrote:
> On Thu, Aug 09, 2012 at 12:08:18PM +0300, Kirill A. Shutemov wrote:
> > +static void __split_huge_zero_page_pmd(struct mm_struct *mm, pmd_t *pm=
d,
> > +		unsigned long address)
> > +{
> > +	pgtable_t pgtable;
> > +	pmd_t _pmd;
> > +	unsigned long haddr =3D address & HPAGE_PMD_MASK;
> > +	struct vm_area_struct *vma;
> > +	int i;
> > +
> > +	vma =3D find_vma(mm, address);
> > +	VM_BUG_ON(vma =3D=3D NULL);
>=20
> I think you can use BUG_ON here just in case but see below how I would
> change it.
>=20
> > +	pmdp_clear_flush_notify(vma, haddr, pmd);
> > +	/* leave pmd empty until pte is filled */
> > +
> > +	pgtable =3D get_pmd_huge_pte(mm);
> > +	pmd_populate(mm, &_pmd, pgtable);
> > +
> > +	for (i =3D 0; i < HPAGE_PMD_NR; i++, haddr +=3D PAGE_SIZE) {
> > +		pte_t *pte, entry;
> > +		entry =3D pfn_pte(my_zero_pfn(haddr), vma->vm_page_prot);
> > +		entry =3D pte_mkspecial(entry);
> > +		pte =3D pte_offset_map(&_pmd, haddr);
> > +		VM_BUG_ON(!pte_none(*pte));
> > +		set_pte_at(mm, haddr, pte, entry);
> > +		pte_unmap(pte);
> > +	}
> > +	smp_wmb(); /* make pte visible before pmd */
> > +	pmd_populate(mm, pmd, pgtable);
> > +}
> > +
>=20
> The last pmd_populate will corrupt memory.

Nice catch, thank you.

I've used do_huge_pmd_wp_page_fallback() as template for my code.
What's difference between these two code paths?
Why is do_huge_pmd_wp_page_fallback() safe?

> > +	if (is_huge_zero_pmd(*pmd)) {
> > +		__split_huge_zero_page_pmd(mm, pmd, address);
>=20
> This will work fine but it's a bit sad having to add "address" at
> every call, just to run a find_vma(). The only place that doesn't have
> a vma already on the caller stack is actually pagewalk, all other
> places already have a vma on the stack without having to find it with
> the rbtree.
>=20
> I think it may be better to change the param to
> split_huge_page_pmd(vma, pmd).
>=20
> Then have standard split_huge_page_pmd obtain the mm with vma->vm_mm
> (most callers already calles it with split_huge_page_pmd(vma->vm_mm)
> so it won't alter the cost to do vma->vm_mm in caller or callee).
>=20
> split_huge_page_address also should take the vma (all callers are
> invoking it as split_huge_page_address(vma->vm_mm) so it'll be zero
> cost change).
>=20
> Then we can add a split_huge_page_pmd_mm(mm, address, pmd) or
> split_huge_page_pmd_address(mm, address, pmd) (call it as you
> prefer...) only for the pagewalk caller that will do the find_vma and
> BUG_ON if it's not found.
>=20
> In that new split_huge_page_pmd_mm you can also add a BUG_ON checking
> vma->vm_start to be <=3D haddr and vma->vm_end >=3D haddr+HPAGE_PMD_SIZE
> in addition to BUG_ON(!vma) above, for more robustness. I'm not aware
> of any place calling it without mmap_sem hold at least for reading
> and the vma must be stable, but more debug checks won't hurt.

Looks resonable. I'll update it in next revision.

--=20
 Kirill A. Shutemov

--MfFXiAuoTsnnDAfZ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJQLfzxAAoJEAd+omnVudOMY58P/i466DRlrDYRpqaOYJvfbQ4p
TXY4C7LS7HgxpcXWyylMWcLkjhJcttCPxIqK6sJuEFU9c5Ik4t+evJjHeZ2OP3If
3DRWixflL0+rMHa1R24eJXZlptW4hjbDp94sQGMcnJnHt0c9v3qm6LRhUqKZDnDf
XxLGr09MowJc7YINluOjZqC26I/+QnDs+DeYynuTa8HjAEjFRs6zJBhO2m8/l/7D
pR9g5YgLapmErMnP+VAhEI4Eaz9C7THmq0/fSit7W4EHL0IzuqoIXqKdlzmAUNnq
Nxp2ZQ5lZ2/F0Qwe6VMtklHAbR0Y4DmDX0fWne0qLQOmRTh+Qd/cEEkQli56YDB/
G2ROZwWMYX8tT4yM30xpe3p0zZWvn3xSEUgTpY+p6WXv5ysFnmwT2V86KoP14S9U
pUwS0Zb1MEe8jtjdtjNMzJx3AzvM5d6WXsqAxVMx8VQ7siA/xYoCWs/6lBWHUfdu
30WEYSOREnSO6LKx5DTLWMl+C9NzjyOG/4yDdOGKk1eumog6KGPatVRkRv0quTIA
Tx7bSSHMBZkV2Q83/kbW9xJmfmF1UVyA2/yOLFyEG38BC6DXFzQg1VfezF8+n+Wy
/u0XFlDm89YPu1RkAoNWkiH9DOP1n2a9A+aiaoffDPPB29tdiMVrwWhyYt4zW/HB
vLgkGpsqt0eFo61kuGCH
=iflw
-----END PGP SIGNATURE-----

--MfFXiAuoTsnnDAfZ--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
