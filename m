Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id B9D686B005D
	for <linux-mm@kvack.org>; Mon, 10 Sep 2012 10:44:15 -0400 (EDT)
Date: Mon, 10 Sep 2012 17:44:38 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH v2 10/10] thp: implement refcounting for huge zero page
Message-ID: <20120910144438.GA31697@otc-wbsnb-06>
References: <1347282813-21935-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1347282813-21935-11-git-send-email-kirill.shutemov@linux.intel.com>
 <1347285759.1234.1645.camel@edumazet-glaptop>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="3MwIy2ne0vdjdPXF"
Content-Disposition: inline
In-Reply-To: <1347285759.1234.1645.camel@edumazet-glaptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, "H. Peter Anvin" <hpa@linux.intel.com>, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill@shutemov.name>


--3MwIy2ne0vdjdPXF
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Sep 10, 2012 at 04:02:39PM +0200, Eric Dumazet wrote:
> On Mon, 2012-09-10 at 16:13 +0300, Kirill A. Shutemov wrote:
> > From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> >=20
> > H. Peter Anvin doesn't like huge zero page which sticks in memory forev=
er
> > after the first allocation. Here's implementation of lockless refcounti=
ng
> > for huge zero page.
> >=20
> ...
>=20
> > +static unsigned long get_huge_zero_page(void)
> > +{
> > +	struct page *zero_page;
> > +retry:
> > +	if (likely(atomic_inc_not_zero(&huge_zero_refcount)))
> > +		return ACCESS_ONCE(huge_zero_pfn);
> > +
> > +	zero_page =3D alloc_pages(GFP_TRANSHUGE | __GFP_ZERO, HPAGE_PMD_ORDER=
);
> > +	if (!zero_page)
> > +		return 0;
> > +	if (cmpxchg(&huge_zero_pfn, 0, page_to_pfn(zero_page))) {
> > +		__free_page(zero_page);
> > +		goto retry;
> > +	}
>=20
> This might break if preemption can happen here ?
>=20
> The second thread might loop forever because huge_zero_refcount is 0,
> and huge_zero_pfn not zero.

I fail to see why the second thread might loop forever. Long time yes, but
forever?

Yes, disabling preemption before alloc_pages() and enabling after
atomic_set() looks reasonable. Thanks.

>=20
> If preemption already disabled, a comment would be nice.
>=20
>=20
> > +
> > +	/* We take additional reference here. It will be put back by shinker =
*/
>=20
> typo : shrinker

Thx.

> > +	atomic_set(&huge_zero_refcount, 2);
> > +	return ACCESS_ONCE(huge_zero_pfn);
> > +}
> > +
>=20
>=20
>=20

--=20
 Kirill A. Shutemov

--3MwIy2ne0vdjdPXF
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJQTfzWAAoJEAd+omnVudOMnMoQAK+JYB2wxNHp9jOcWZl8Tqhn
fOB9vDh2PpJca5q7gYDlCHYt8y0JOC/nflDZS/CdaKpztlyszqrkFcAeH0jbhQEc
2rDntfM+riieZPQFvyIRxruQu65P4vooXhzTB/1PqBzOq9F2PblHLxtyVYg9N9V3
P0T/4HicTRbaJS4bwKno9Nm69LbV/Qjqspel2EiH9tpTQa+8JD7EelB/ziqzs/Hk
/5SVVqzwdElHOEd2eqvUPRPvy7/SyG6q7Ar1QRu3Oq5KbmJsN6xWM9XhiUyinNGA
sm6GKfEMZ3LQDZL3I71ud18GgyPiPJdl44K2j4DoRvLwouxpRtKF3RjyDMUaQKHy
XDVqfiDdZtF3hix8SppCoTYntLHxLtXXduBp1y4DRt/Mg6hr1zDGort/VaOLB/iq
3WNGJSyPpC0SZ7Ev0dCa4aUIutfx8SuIK8HZYszkPJqzWJgAkrfripCrIHqKM2au
0YXXwkJvcDZ/mNhOX2Pt1dBqzfXv73rU6MCb5XxO3MczSU9lzpeEblob7HHVpSt1
/AX6u3WIIt/EUJE+8M+DyLuh2MUaAvD+g7PUap/4BPlbsiHLToHFnrwU/1+oC4h3
AP4rOKHdjJFQJjOXFS0/AHjZi4RZIC44M/NHHfPF5cbaaSF/54JBiLi/uS+hZLTh
QKX9Z5uVrW41+6FkKH1h
=pLyw
-----END PGP SIGNATURE-----

--3MwIy2ne0vdjdPXF--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
