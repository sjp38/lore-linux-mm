Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id E312D6B0038
	for <linux-mm@kvack.org>; Wed, 18 Oct 2017 07:08:18 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id b192so3880050pga.14
        for <linux-mm@kvack.org>; Wed, 18 Oct 2017 04:08:18 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id p33si7648471pld.51.2017.10.18.04.08.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Oct 2017 04:08:18 -0700 (PDT)
Date: Wed, 18 Oct 2017 19:01:15 +0800
From: "Du, Changbin" <changbin.du@intel.com>
Subject: Re: [PATCH 1/2] mm, thp: introduce dedicated transparent huge page
 allocation interfaces
Message-ID: <20171018110114.GB4352@intel.com>
References: <1508145557-9944-1-git-send-email-changbin.du@intel.com>
 <1508145557-9944-2-git-send-email-changbin.du@intel.com>
 <20171017111246.7rhmy7klggxjozom@node.shutemov.name>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="MfFXiAuoTsnnDAfZ"
Content-Disposition: inline
In-Reply-To: <20171017111246.7rhmy7klggxjozom@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: changbin.du@intel.com, akpm@linux-foundation.org, corbet@lwn.net, hughd@google.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org


--MfFXiAuoTsnnDAfZ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Oct 17, 2017 at 02:12:46PM +0300, Kirill A. Shutemov wrote:
> On Mon, Oct 16, 2017 at 05:19:16PM +0800, changbin.du@intel.com wrote:
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
> > +	VM_BUG_ON(!(gfp_mask & __GFP_COMP));
>=20
> Why do you check for __GFP_COMP only in this helper?
>=20
> > +	page =3D alloc_pages(gfp_mask | __GFP_COMP, HPAGE_PMD_ORDER);
>=20
> And still apply __GFP_COMP anyway?
>
This is a mistake, will removed. Thanks.

> > +	if (unlikely(!page))
> > +		return NULL;
> > +	prep_transhuge_page(page);
> > +	return page;
> > +}
> > +
> >  unsigned long __thp_get_unmapped_area(struct file *filp, unsigned long=
 len,
> >  		loff_t off, unsigned long flags, unsigned long size)
> >  {
>=20
> --=20
>  Kirill A. Shutemov

--=20
Thanks,
Changbin Du

--MfFXiAuoTsnnDAfZ
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAEBAgAGBQJZ5zR6AAoJEAanuZwLnPNUYDoH/jZC79Ky3xbVzdKV7OuGEi7f
SPCfRfcFX/erKjb1ugIJA8DajO+nDntnE50Rt9F9wciuR8bcnZv+GWvWJ0WZbra0
p6qQbJsCcQiOEhS4mgUCMIhR6FjL+udUk6R3IIQ2Pgkg5/eig+vfwUqtc3KOJQc2
FfClenU5iqwer98gV0q0i1iGM7gPmsQ7ggK6NpXvPfm/dHfHZhekjYiGePaNYjLN
8MPsHGhXW5mETpxbriDuQMY9ZP6WLdtOVPHTKRPBr/pRnSMfGwmHsfVFyGfuYj6l
mK5cZPBQnw+DI+uF4fVvv6TMRitFPdcO//MLwV5M+EV/utcXVCz6vms5yCquYg0=
=mWo8
-----END PGP SIGNATURE-----

--MfFXiAuoTsnnDAfZ--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
