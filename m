Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id 08A5B6B005D
	for <linux-mm@kvack.org>; Fri, 16 Nov 2012 13:18:57 -0500 (EST)
Date: Fri, 16 Nov 2012 20:20:05 +0200
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH v5 08/11] thp: setup huge zero page on non-write page
 fault
Message-ID: <20121116182005.GA18394@otc-wbsnb-06>
References: <1352300463-12627-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1352300463-12627-9-git-send-email-kirill.shutemov@linux.intel.com>
 <alpine.DEB.2.00.1211141531110.22537@chino.kir.corp.google.com>
 <20121115093209.GF9676@otc-wbsnb-06>
 <alpine.DEB.2.00.1211151348080.27188@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="CE+1k2dSO48ffgeK"
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1211151348080.27188@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, "H. Peter Anvin" <hpa@linux.intel.com>, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill@shutemov.name>


--CE+1k2dSO48ffgeK
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Nov 15, 2012 at 01:52:44PM -0800, David Rientjes wrote:
> On Thu, 15 Nov 2012, Kirill A. Shutemov wrote:
>=20
> > > > diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> > > > index f36bc7d..41f05f1 100644
> > > > --- a/mm/huge_memory.c
> > > > +++ b/mm/huge_memory.c
> > > > @@ -726,6 +726,16 @@ int do_huge_pmd_anonymous_page(struct mm_struc=
t *mm, struct vm_area_struct *vma,
> > > >  			return VM_FAULT_OOM;
> > > >  		if (unlikely(khugepaged_enter(vma)))
> > > >  			return VM_FAULT_OOM;
> > > > +		if (!(flags & FAULT_FLAG_WRITE)) {
> > > > +			pgtable_t pgtable;
> > > > +			pgtable =3D pte_alloc_one(mm, haddr);
> > > > +			if (unlikely(!pgtable))
> > > > +				goto out;
> > >=20
> > > No use in retrying, just return VM_FAULT_OOM.
> >=20
> > Hm. It's consistent with non-hzp path: if pte_alloc_one() in
> > __do_huge_pmd_anonymous_page() fails __do_huge_pmd_anonymous_page()
> > returns VM_FAULT_OOM which leads to "goto out".
> >=20
>=20
> If the pte_alloc_one(), which wraps __pte_alloc(), you're adding fails,=
=20
> it's pointless to "goto out" to try __pte_alloc() which we know won't=20
> succeed.
>=20
> > Should it be fixed too?
> >=20
>=20
> It's done for maintainablility because although=20
> __do_huge_pmd_anonymous_page() will only return VM_FAULT_OOM today when=
=20
> pte_alloc_one() fails, if it were to ever fail in a different way then th=
e=20
> caller is already has a graceful failure.

Okay, here's fixlet. Andrew, please squash it to the patch 08/11.

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 1f6c6de..d7ab890 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -793,7 +793,7 @@ int do_huge_pmd_anonymous_page(struct mm_struct *mm, st=
ruct vm_area_struct *vma,
 			unsigned long zero_pfn;
 			pgtable =3D pte_alloc_one(mm, haddr);
 			if (unlikely(!pgtable))
-				goto out;
+				return VM_FAULT_OOM;
 			zero_pfn =3D get_huge_zero_page();
 			if (unlikely(!zero_pfn)) {
 				pte_free(mm, pgtable);
--=20
 Kirill A. Shutemov

--CE+1k2dSO48ffgeK
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJQpoPUAAoJEAd+omnVudOMp20P/jJlbYddl3L4FqpYDHVX+U84
+axJiIXc568OT6duGpVuKvJvyRDjw6XdtBkmgRHoBnqNaNgMm3iTJHX1oH1RPPbd
/QfpvwjdrBSEgV/6mJ4E+D61lCuqmJHvd7A6JcalwgJO/QNbFArJlsFd31ZXq77h
6qtJEE5eh7Irrq41msvMn/Qafky4LVQazjdwpzreBIzQgDdYHg4LYmhVgtzqbDt0
USN3pi9p6OM0sdn6+rLhZTcKJdnFdidT1Pb/panDt4ZLorhLNQNveGuTX9VTl/K7
3lrwtPDWmii6rP2H5ml8uMtspcd0YKRInf8JY1YEpFH2uJHEtVqflYKz0ZZpNyoR
1bMmn7wIAPpwg3NdVxzgjrn0iV7Nsr6nHl5Q0tTHnimct89aNDrjCxMlaJM0+4aW
o5TFYycTV/ZIe8/V+5W06alDWZenIfViZRY7+3G+tCGuChRvpf5koVuEOIKhP/1m
yOo5Eu+estAvsZuvQ9BWjczLW5A3CvzQxR3qJC0eYpY/XHh4sFHEAMlEA45rqH4q
r9LSrv9TAorthFYOPyg+iMBDz/cRHTC31C4X0HzU3qyCfw4reM1+D3zPDDidiajX
YdktXUlSBUk1JXIDj6eYnT0rHRBTtlkC0KBgdr2MhpvkkEME7qT9UFiTsbw6LFfh
7xb8xdqWSn2iJXe2jnhX
=1R5G
-----END PGP SIGNATURE-----

--CE+1k2dSO48ffgeK--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
