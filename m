Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 977166B0038
	for <linux-mm@kvack.org>; Tue, 17 Oct 2017 05:23:30 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id g6so1077963pgn.11
        for <linux-mm@kvack.org>; Tue, 17 Oct 2017 02:23:30 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id u3si5939811plm.546.2017.10.17.02.23.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Oct 2017 02:23:29 -0700 (PDT)
Date: Tue, 17 Oct 2017 17:16:39 +0800
From: "Du, Changbin" <changbin.du@intel.com>
Subject: Re: [PATCH 1/2] mm, thp: introduce dedicated transparent huge page
 allocation interfaces
Message-ID: <20171017091638.GA7748@intel.com>
References: <1508145557-9944-1-git-send-email-changbin.du@intel.com>
 <1508145557-9944-2-git-send-email-changbin.du@intel.com>
 <66a3f340-ff44-efad-48ad-a95554938a29@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="RnlQjJ0d97Da+TV1"
Content-Disposition: inline
In-Reply-To: <66a3f340-ff44-efad-48ad-a95554938a29@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: changbin.du@intel.com, akpm@linux-foundation.org, corbet@lwn.net, hughd@google.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org


--RnlQjJ0d97Da+TV1
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Khandual,
Thanks for your review.

On Tue, Oct 17, 2017 at 01:38:07PM +0530, Anshuman Khandual wrote:
> On 10/16/2017 02:49 PM, changbin.du@intel.com wrote:
> > From: Changbin Du <changbin.du@intel.com>
> >=20
> > This patch introduced 4 new interfaces to allocate a prepared
> > transparent huge page.
> >   - alloc_transhuge_page_vma
> >   - alloc_transhuge_page_nodemask
> >   - alloc_transhuge_page_node
> >   - alloc_transhuge_page
> >=20
>=20
> If we are trying to match HugeTLB helpers, then it should have
> format something like alloc_transhugepage_xxx instead of
> alloc_transhuge_page_XXX. But I think its okay.
>
HugeTLB helpers are something like alloc_huge_page, so I think
alloc_transhuge_page match it. And existing names already have
*transhuge_page* style.

> > diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
> > index 14bc21c..1dd2c33 100644
> > --- a/include/linux/huge_mm.h
> > +++ b/include/linux/huge_mm.h
> > @@ -130,9 +130,20 @@ extern unsigned long thp_get_unmapped_area(struct =
file *filp,
> >  		unsigned long addr, unsigned long len, unsigned long pgoff,
> >  		unsigned long flags);
> > =20
> > -extern void prep_transhuge_page(struct page *page);
> >  extern void free_transhuge_page(struct page *page);
> > =20
> > +struct page *alloc_transhuge_page_vma(gfp_t gfp_mask,
> > +		struct vm_area_struct *vma, unsigned long addr);
> > +struct page *alloc_transhuge_page_nodemask(gfp_t gfp_mask,
> > +		int preferred_nid, nodemask_t *nmask);
>=20
> Would not they require 'extern' here ?
>
Need or not, function declaration are implicitly 'extern'. I will add it to
align with existing code.

> > +
> > +static inline struct page *alloc_transhuge_page_node(int nid, gfp_t gf=
p_mask)
> > +{
> > +	return alloc_transhuge_page_nodemask(gfp_mask, nid, NULL);
> > +}
> > +
> > +struct page *alloc_transhuge_page(gfp_t gfp_mask);
> > +
> >  bool can_split_huge_page(struct page *page, int *pextra_pins);
> >  int split_huge_page_to_list(struct page *page, struct list_head *list);
> >  static inline int split_huge_page(struct page *page)
> > diff --git a/include/linux/migrate.h b/include/linux/migrate.h
> > index 643c7ae..70a00f3 100644
> > --- a/include/linux/migrate.h
> > +++ b/include/linux/migrate.h
> > @@ -42,19 +42,15 @@ static inline struct page *new_page_nodemask(struct=
 page *page,
> >  		return alloc_huge_page_nodemask(page_hstate(compound_head(page)),
> >  				preferred_nid, nodemask);
> > =20
> > -	if (thp_migration_supported() && PageTransHuge(page)) {
> > -		order =3D HPAGE_PMD_ORDER;
> > -		gfp_mask |=3D GFP_TRANSHUGE;
> > -	}
> > -
> >  	if (PageHighMem(page) || (zone_idx(page_zone(page)) =3D=3D ZONE_MOVAB=
LE))
> >  		gfp_mask |=3D __GFP_HIGHMEM;
> > =20
> > -	new_page =3D __alloc_pages_nodemask(gfp_mask, order,
> > +	if (thp_migration_supported() && PageTransHuge(page))
> > +		return alloc_transhuge_page_nodemask(gfp_mask | GFP_TRANSHUGE,
> > +				preferred_nid, nodemask);
> > +	else
> > +		return __alloc_pages_nodemask(gfp_mask, order,
> >  				preferred_nid, nodemask);
> > -
> > -	if (new_page && PageTransHuge(page))
> > -		prep_transhuge_page(new_page);
>=20
> This makes sense, calling prep_transhuge_page() inside the
> function alloc_transhuge_page_nodemask() is better I guess.
>=20
> > =20
> >  	return new_page;
> >  }
> > diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> > index 269b5df..e267488 100644
> > --- a/mm/huge_memory.c
> > +++ b/mm/huge_memory.c
> > @@ -490,7 +490,7 @@ static inline struct list_head *page_deferred_list(=
struct page *page)
> >  	return (struct list_head *)&page[2].mapping;
> >  }
> > =20
> > -void prep_transhuge_page(struct page *page)
> > +static void prep_transhuge_page(struct page *page)
>=20
> Right. It wont be used outside huge page allocation context and
> you have already mentioned about it.
>=20
> >  {
> >  	/*
> >  	 * we use page->mapping and page->indexlru in second tail page
> > @@ -501,6 +501,45 @@ void prep_transhuge_page(struct page *page)
> >  	set_compound_page_dtor(page, TRANSHUGE_PAGE_DTOR);
> >  }
> > =20
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
>=20
> __GFP_COMP and HPAGE_PMD_ORDER are the minimum flags which will be used
> for huge page allocation and preparation. Any thing else depending upon
> the context will be passed by the caller. Makes sense.
>=20
yes, thanks.

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
>=20
> Same here.
>=20
> > +struct page *alloc_transhuge_page(gfp_t gfp_mask)
> > +{
> > +	struct page *page;
> > +
> > +	VM_BUG_ON(!(gfp_mask & __GFP_COMP));
>=20
> You expect the caller to provide __GFP_COMP, why ? You are
> anyways providing it later.
>=20
oops, I forgot to update this line. Will remove it. Thanks for figuring it =
out.

--=20
Thanks,
Changbin Du

--RnlQjJ0d97Da+TV1
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAEBAgAGBQJZ5cp2AAoJEAanuZwLnPNUnc4IAI8JihFynL2P5Lzy2dzcSg4B
2evr1cmQ8vmf6TKygDpzg+uo2Q0wMXznXo4rgCszf0iH1LwQzSasi/iNcK0WUSeE
l1/fUzouDomNCaAVu7QA0Dc4ov710Zli8Yj1PTRH2VnHrG7qeiAu0OsimX06Wh3S
y6ZHkz9PRw7QmVZWm05MENjJVRsAHWIZ9ZxcBnxvrO2T8S02HnFU9NOM65r8LnA+
HipRnmOERQz0ZJHdeC4/LyYGaD2aCLCsOY9jDoNHBnVL08sZ3bnpE1/RtlFLLFz0
G681odJDKMFSIxURYmfL51fXigENsTSBAv9Z5j9M63ahL6BKwjcOh1UVoESzmS4=
=EAaI
-----END PGP SIGNATURE-----

--RnlQjJ0d97Da+TV1--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
