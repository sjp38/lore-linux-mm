Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 076746B006E
	for <linux-mm@kvack.org>; Mon, 14 Jan 2013 10:17:02 -0500 (EST)
Date: Mon, 14 Jan 2013 17:18:02 +0200
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: huge zero page vs FOLL_DUMP
Message-ID: <20130114151802.GA18801@otc-wbsnb-06>
References: <CANN689E5iw=UHfG1r82c91cZVqhX9xrxttKw3SCy=ZSgcAicNQ@mail.gmail.com>
 <20130112033659.GA26890@otc-wbsnb-06>
 <CANN689HKD7t91e+-oZw6Nqq=cYQDk1eo+0JD7g=3AomfpcNSCw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="BOKacYhQ+x31HxR3"
Content-Disposition: inline
In-Reply-To: <CANN689HKD7t91e+-oZw6Nqq=cYQDk1eo+0JD7g=3AomfpcNSCw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, linux-mm <linux-mm@kvack.org>, Michel Lespinasse <walken@google.com>


--BOKacYhQ+x31HxR3
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Jan 11, 2013 at 08:27:31PM -0800, Michel Lespinasse wrote:
> On Fri, Jan 11, 2013 at 7:36 PM, Kirill A. Shutemov
> > Could you tese the patch?
> >
> > From 062a9b670ede9fe5fca1d1947b42990b6b0642a4 Mon Sep 17 00:00:00 2001
> > From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> > Date: Sat, 12 Jan 2013 05:18:58 +0200
> > Subject: [PATCH] thp: Avoid dumping huge zero page
> >
> > No reason to preserve huge zero page in core dump.
> >
> > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > Reported-by: Michel Lespinasse <walken@google.com>
> > ---
> >  mm/huge_memory.c | 4 ++++
> >  1 file changed, 4 insertions(+)
> >
> > diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> > index 6001ee6..b5783d8 100644
> > --- a/mm/huge_memory.c
> > +++ b/mm/huge_memory.c
> > @@ -1257,6 +1257,10 @@ struct page *follow_trans_huge_pmd(struct vm_are=
a_struct *vma,
> >         if (flags & FOLL_WRITE && !pmd_write(*pmd))
> >                 goto out;
> >
> > +       /* Avoid dumping huge zero page */
> > +       if ((flags & FOLL_DUMP) && is_huge_zero_pmd(*pmd))
> > +               return ERR_PTR(-EFAULT);
> > +
> >         page =3D pmd_page(*pmd);
> >         VM_BUG_ON(!PageHead(page));
> >         if (flags & FOLL_TOUCH) {
>=20
> Looks sane to me, and it also helps my munlock test (we were getting
> and dropping references on the zero page which made it noticeably
> slower). Thanks!
>=20
> Reviewed-by: Michel Lespinasse <walken@google.com>

Andrew, please take the patch.

--=20
 Kirill A. Shutemov

--BOKacYhQ+x31HxR3
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJQ9CGqAAoJEAd+omnVudOMmi0QAJ2bqwqyKuuM3wAVxCnuz/T1
VlHn5c1oosLZN8/b4JbYRQ/oji1eLDfmBVqcHsx/ZGR/Mi+cThv8Sn+XRZctXUTf
D3spBCuFxL5Q0TNgGZKvyOnXsytkisx9fACKfqJfe6m5iFOSdE8xLq12NnXi6QOe
eSprZqLDyP7SlZOZoDAesr8tePd2YRzJWfjd+4leiaw92dJh9HUjscEXCT41Xjal
bgTsqr31NJgGl705ubBysxUiNLPO06N79PuSuvADSbcfJSD6sqWp9Fu3jAuowb4E
ZVwRV2bkfwIcQkfd3x+aNcIP6+Xn337vjlT+LNvapP5bsCAtsiHnEUtz5q4lJS2h
//+3M46hcwPJgJq0tDZLdQsoBZ8RpX96RbM6jfVmFN8lpm0i5fFt42tItoYBm+T6
/uw2daMa/1EwbCVDncux+xMPp8NSEgwa/ehMNQDaUCcGhZy9+CdpgleopezCB59Z
s3EOUfCUQCAWqCF5dfr0HshJekdf0y/8S8ogtKD5+qQv+WPaq1R0ZeiSMQ6dYCCG
IFqKpfDEuW6n8+5vIn9zg5L5h+8+zmGX3rruvfZm+Hk/wQNyMgPm9iZCy+QZOlQc
seK0xYjFPlYBzR81OkgFYocDHwtMkvJE2BIsMmnD3QHUj8yqFYCvAeIDIPRw5Lrr
+jtWnX3UBd7Vrp6Uzjin
=TUUA
-----END PGP SIGNATURE-----

--BOKacYhQ+x31HxR3--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
