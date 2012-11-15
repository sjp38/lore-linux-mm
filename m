Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id B965B6B008A
	for <linux-mm@kvack.org>; Thu, 15 Nov 2012 03:00:36 -0500 (EST)
Date: Thu, 15 Nov 2012 10:01:33 +0200
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH v5 03/11] thp: copy_huge_pmd(): copy huge zero page
Message-ID: <20121115080133.GA9676@otc-wbsnb-06>
References: <1352300463-12627-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1352300463-12627-4-git-send-email-kirill.shutemov@linux.intel.com>
 <alpine.DEB.2.00.1211141433150.13515@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="y0ulUmNC+osPPQO6"
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1211141433150.13515@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, "H. Peter Anvin" <hpa@linux.intel.com>, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill@shutemov.name>


--y0ulUmNC+osPPQO6
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Nov 14, 2012 at 02:33:44PM -0800, David Rientjes wrote:
> On Wed, 7 Nov 2012, Kirill A. Shutemov wrote:
>=20
> > diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> > index ff834ea..0d903bf 100644
> > --- a/mm/huge_memory.c
> > +++ b/mm/huge_memory.c
> > @@ -701,6 +701,18 @@ static inline struct page *alloc_hugepage(int defr=
ag)
> >  }
> >  #endif
> > =20
> > +static void set_huge_zero_page(pgtable_t pgtable, struct mm_struct *mm,
> > +		struct vm_area_struct *vma, unsigned long haddr, pmd_t *pmd)
> > +{
> > +	pmd_t entry;
> > +	entry =3D pfn_pmd(huge_zero_pfn, vma->vm_page_prot);
> > +	entry =3D pmd_wrprotect(entry);
> > +	entry =3D pmd_mkhuge(entry);
> > +	set_pmd_at(mm, haddr, pmd, entry);
> > +	pgtable_trans_huge_deposit(mm, pgtable);
> > +	mm->nr_ptes++;
> > +}
> > +
> >  int do_huge_pmd_anonymous_page(struct mm_struct *mm, struct vm_area_st=
ruct *vma,
> >  			       unsigned long address, pmd_t *pmd,
> >  			       unsigned int flags)
> > @@ -778,6 +790,11 @@ int copy_huge_pmd(struct mm_struct *dst_mm, struct=
 mm_struct *src_mm,
> >  		pte_free(dst_mm, pgtable);
> >  		goto out_unlock;
> >  	}
> > +	if (is_huge_zero_pmd(pmd)) {
> > +		set_huge_zero_page(pgtable, dst_mm, vma, addr, dst_pmd);
> > +		ret =3D 0;
> > +		goto out_unlock;
> > +	}
>=20
> You said in the introduction message in this series that you still allow=
=20
> splitting of the pmd, so why no check for pmd_trans_splitting() before=20
> this?

pmd_trans_splitting() returns true only for pmd which points to a page
under spliiting. It never happens with huge zero page.
We only split a pmd to a page table without touching the page.
mm->page_table_lock is enough to protect against that.

--=20
 Kirill A. Shutemov

--y0ulUmNC+osPPQO6
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJQpKFdAAoJEAd+omnVudOMk+AP/i32Hz/B8KB3OEY/IaFA6XO+
PYwAa4zBhW6AD18dbZQjOVim/fCdgsYj5UKCFNyJOflKNk3J9LBQOlA7DV6WB50p
5nsrHle17wyX/09JkMOMnTFtQHGbhCxzpwFDyws28pRv0w2uTmGG2mr4tsNkaGcP
XciUwt5OeEESfZ2zTA66wknCL8JaaO/8I/10clo+nL9wAOiuF9fW1M0lF4yjwlh8
HRQ3F8bENHd1OBPar8wkqwts6C0razvBRc+eFJFKV5Fd4RRwBglRVUSTjzUbfBbB
Uor+TvFVuHstDXr72il1bDvX8m7yvxCYOmbLeksU9GEtnngWx23kxpQaewH55c/o
aVVDjpRxYyOOCQzteCx3PytWHKRYpy3zbyq0hVgbjWwdeb7oRc9gZ1hRpgv+nuQg
IkpXD6e3Oqe5rK5IgmZKoOTmdIFsFo2KFYWkoQnooX6MH6+MH4dHT8yI51BvCd3V
fob+LiK4g1UioyF6ijW/EuOoGlqKQLKvJRGR5yqqUs4aB0T8mKnRMH+5Wjct0xDf
p5opfs065GlZw0ltkzzioeY9q84TvZ60RpfjqAjC5OhlDN5pozoz+l1IPA4M4dUF
g4VojEXF0+cPO686ZmOM1bgJxlOA7+VLHSLk20w9noa8yzsAxu7Hy/uvIzA2u9Oj
qp2t2/ENmLdaTGQpPv/h
=j3lU
-----END PGP SIGNATURE-----

--y0ulUmNC+osPPQO6--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
