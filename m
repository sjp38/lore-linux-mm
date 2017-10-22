Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8FCA96B0038
	for <linux-mm@kvack.org>; Sun, 22 Oct 2017 12:02:48 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id 191so9895205pgd.0
        for <linux-mm@kvack.org>; Sun, 22 Oct 2017 09:02:48 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id h63si3675710pgc.833.2017.10.22.09.02.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 22 Oct 2017 09:02:47 -0700 (PDT)
Date: Sun, 22 Oct 2017 23:55:51 +0800
From: "Du, Changbin" <changbin.du@intel.com>
Subject: Re: [PATCH v2 1/2] mm, thp: introduce dedicated transparent huge
 page allocation interfaces
Message-ID: <20171022155551.GA23682@intel.com>
References: <1508488588-23539-1-git-send-email-changbin.du@intel.com>
 <1508488588-23539-2-git-send-email-changbin.du@intel.com>
 <alpine.DEB.2.20.1710200634180.10736@nuc-kabylake>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="XsQoSWH+UP9D9v3l"
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1710200634180.10736@nuc-kabylake>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: Changbin Du <changbin.du@intel.com>, akpm@linux-foundation.org, corbet@lwn.net, hughd@google.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, khandual@linux.vnet.ibm.com, kirill@shutemov.name


--XsQoSWH+UP9D9v3l
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Lameter,
On Fri, Oct 20, 2017 at 06:35:44AM -0500, Christopher Lameter wrote:
> On Fri, 20 Oct 2017, changbin.du@intel.com wrote:
>=20
> > diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> > index 269b5df..2a960fc 100644
> > --- a/mm/huge_memory.c
> > +++ b/mm/huge_memory.c
> > @@ -501,6 +501,43 @@ void prep_transhuge_page(struct page *page)
> >  	set_compound_page_dtor(page, TRANSHUGE_PAGE_DTOR);
> >  }
> >
> > +struct page *alloc_transhuge_page_vma(gfp_t gfp_mask,
> > +		struct vm_area_struct *vma, unsigned long addr)
> > +{
> > +	struct page *page;
> > +
> > +	page =3D alloc_pages_vma(gfp_mask | __GFP_COMP, HPAGE_PMD_ORDER,
> > +			       vma, addr, numa_node_id(), true);
> > +	if (unlikely(!page))
> > +		return NULL;
> > +	prep_transhuge_page(page);
> > +	return page;
> > +}
> > +
> > +struct page *alloc_transhuge_page_nodemask(gfp_t gfp_mask,
> > +		int preferred_nid, nodemask_t *nmask)
> > +{
> > +	struct page *page;
> > +
> > +	page =3D __alloc_pages_nodemask(gfp_mask | __GFP_COMP, HPAGE_PMD_ORDE=
R,
> > +				      preferred_nid, nmask);
> > +	if (unlikely(!page))
> > +		return NULL;
> > +	prep_transhuge_page(page);
> > +	return page;
> > +}
> > +
> > +struct page *alloc_transhuge_page(gfp_t gfp_mask)
> > +{
> > +	struct page *page;
> > +
> > +	page =3D alloc_pages(gfp_mask | __GFP_COMP, HPAGE_PMD_ORDER);
> > +	if (unlikely(!page))
> > +		return NULL;
> > +	prep_transhuge_page(page);
> > +	return page;
> > +}
> > +
>=20
> These look pretty similar to the code used for huge pages (aside from the
> call to prep_transhuge_page(). Maybe we can have common allocation
> primitives for huge pages?
>=20
yes, they are similar to each other, but allocation approaches are much dif=
ferent.
hugetlbfs alloc page from reserved memory, while thp just directly get page
=66rom page allocator.

I think it doesn't make much sense to provide uified api for both of them, =
because
transhuge_page allocation primitives only used within hugetlbfs code. thp
allocation is more common as system wide. If Unify them then all the api ne=
ed 1 more
parameter to distinguish what huge page is going to allocate.

--=20
Thanks,
Changbin Du

--XsQoSWH+UP9D9v3l
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAEBAgAGBQJZ7L+HAAoJEAanuZwLnPNUazgIALdl2JgCnklCaTit1zZWHe5o
vRr5E1fklq4Jjmu2YEg95mwpSnzN9JvF61JIRhx/vUtA1fBNpr4Tw5vYxLXIb3vB
CNystPbnhZ8fupu76T805TteEMgJ+iZeHi93Qo1Nn8LQko+zVmLNYAtH/IalR07S
awNlccuTqpeM7B8OaRyWelV//7g8xC0/1cxmM3qUGHrTrz0e+yecug59G3JBhc+q
TOx1k9gF4h/3PLBND20RC6ymw9a7SE7/YZzzw66fvyQpc7nkhVBHPyIjZh4IvyQZ
r4s8C4KldrCR3A7zwW0QcrBNBjFNU45CyLUD9cT4TRCGghJ9xWXWnz0tla7oJwk=
=pLeN
-----END PGP SIGNATURE-----

--XsQoSWH+UP9D9v3l--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
