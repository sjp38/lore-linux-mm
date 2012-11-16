Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id CD84F6B004D
	for <linux-mm@kvack.org>; Fri, 16 Nov 2012 13:12:21 -0500 (EST)
Date: Fri, 16 Nov 2012 20:13:21 +0200
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH v5 05/11] thp: change_huge_pmd(): keep huge zero page
 write-protected
Message-ID: <20121116181321.GA18313@otc-wbsnb-06>
References: <1352300463-12627-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1352300463-12627-6-git-send-email-kirill.shutemov@linux.intel.com>
 <alpine.DEB.2.00.1211141512400.22537@chino.kir.corp.google.com>
 <20121115084635.GC9676@otc-wbsnb-06>
 <alpine.DEB.2.00.1211151344100.27188@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="UugvWAfsgieZRqgk"
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1211151344100.27188@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, "H. Peter Anvin" <hpa@linux.intel.com>, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill@shutemov.name>


--UugvWAfsgieZRqgk
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Nov 15, 2012 at 01:47:33PM -0800, David Rientjes wrote:
> On Thu, 15 Nov 2012, Kirill A. Shutemov wrote:
>=20
> > > > diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> > > > index d767a7c..05490b3 100644
> > > > --- a/mm/huge_memory.c
> > > > +++ b/mm/huge_memory.c
> > > > @@ -1259,6 +1259,8 @@ int change_huge_pmd(struct vm_area_struct *vm=
a, pmd_t *pmd,
> > > >  		pmd_t entry;
> > > >  		entry =3D pmdp_get_and_clear(mm, addr, pmd);
> > > >  		entry =3D pmd_modify(entry, newprot);
> > > > +		if (is_huge_zero_pmd(entry))
> > > > +			entry =3D pmd_wrprotect(entry);
> > > >  		set_pmd_at(mm, addr, pmd, entry);
> > > >  		spin_unlock(&vma->vm_mm->page_table_lock);
> > > >  		ret =3D 1;
> > >=20
> > > Nack, this should be handled in pmd_modify().
> >=20
> > I disagree. It means we will have to enable hzp per arch. Bad idea.
> >=20
>=20
> pmd_modify() only exists for those architectures with thp support already=
,=20
> so you've already implicitly enabled for all the necessary architectures=
=20
> with your patchset.

Now we have huge zero page fully implemented inside mm/huge_memory.c. Push
this logic to pmd_modify() means we expose hzp implementation details to
arch code. Looks ugly for me.

> > What's wrong with the check?
> >=20
>=20
> Anybody using pmd_modify() to set new protections in the future perhaps=
=20
> without knowledge of huge zero page can incorrectly make the huge zero=20
> page writable, which can never be allowed to happen.  It's better to make=
=20
> sure it can never happen with the usual interface to modify protections.

I haven't found where we check if the page is a 4k zero page, but it's
definitely not pte_modify().

--=20
 Kirill A. Shutemov

--UugvWAfsgieZRqgk
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJQpoJBAAoJEAd+omnVudOMyzoP/1I0PtY02OTwWDoGPfpcCCo3
pf3sH5BMvcYPvtggx5+HzpC4veZFBphzY9RAQrSO+LsF71y+aAMSWc0zyli6diic
SVOjGlKceYCegrHO4zFxXymdPThbEPicKifeKBJ2FAlMcLwRXrQq+A8JrvZtAEsC
Ch4DKXyHQklCWIpfjSK9inc/LiWPkquvruRAcbM+V0vjl5zBVf8Zc1aFNIrU9dJZ
7h31/u7JEkU+unDb8nRSZqbe/OtBYKYrJkHuzmFZrNdA26zX7wPMD6LssVljfeT7
zF3K/Zu9lBMvMmwzwzI7J2EngsmVBNMuFGLv/n6GnPf1sw04rlsysXUAHw2/NsKE
6UjhoSZQ9cl5stOiM+xVVCGXoy0k518KpQwKZSio5AXRz6lDAIeKrL9UduFrCHT9
1ZqveRcEzeoelImBAX70XL+5revTILQGl1E0af0htBR+oIwbq6iLzt+1Hm0iiFLr
ad2GckG24EF3LOtj/Mqy1UA81h4A3rxeiCHYKFFOlJDSJNPp6fS2PtaZPx+KyIl7
qf74obZk5xEKwJgMsMbxULDFzWUsNMuv0b11iexP4IMGb7LWsNvlnqTHoJc6KPj2
oPeZJcAU2zuGjiENt1Zn46J6JmJO3S/j5fdcOPXcyJDS2WWCe0BzWMG6p8aTx6fN
J98tgNfgGClz65qgf8l0
=uEbY
-----END PGP SIGNATURE-----

--UugvWAfsgieZRqgk--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
