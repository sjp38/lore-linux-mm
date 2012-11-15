Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 190706B00A4
	for <linux-mm@kvack.org>; Thu, 15 Nov 2012 04:49:15 -0500 (EST)
Date: Thu, 15 Nov 2012 11:50:20 +0200
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH v5 10/11] thp: implement refcounting for huge zero page
Message-ID: <20121115095020.GH9676@otc-wbsnb-06>
References: <1352300463-12627-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1352300463-12627-11-git-send-email-kirill.shutemov@linux.intel.com>
 <alpine.DEB.2.00.1211141538450.22537@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="TBNym+cBXeFsS4Vs"
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1211141538450.22537@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, "H. Peter Anvin" <hpa@linux.intel.com>, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill@shutemov.name>


--TBNym+cBXeFsS4Vs
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Nov 14, 2012 at 03:40:37PM -0800, David Rientjes wrote:
> On Wed, 7 Nov 2012, Kirill A. Shutemov wrote:
>=20
> > From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> >=20
> > H. Peter Anvin doesn't like huge zero page which sticks in memory forev=
er
> > after the first allocation. Here's implementation of lockless refcounti=
ng
> > for huge zero page.
> >=20
> > We have two basic primitives: {get,put}_huge_zero_page(). They
> > manipulate reference counter.
> >=20
> > If counter is 0, get_huge_zero_page() allocates a new huge page and
> > takes two references: one for caller and one for shrinker. We free the
> > page only in shrinker callback if counter is 1 (only shrinker has the
> > reference).
> >=20
> > put_huge_zero_page() only decrements counter. Counter is never zero
> > in put_huge_zero_page() since shrinker holds on reference.
> >=20
> > Freeing huge zero page in shrinker callback helps to avoid frequent
> > allocate-free.
> >=20
> > Refcounting has cost. On 4 socket machine I observe ~1% slowdown on
> > parallel (40 processes) read page faulting comparing to lazy huge page
> > allocation.  I think it's pretty reasonable for synthetic benchmark.
> >=20
>=20
> Eek, this is disappointing that we need to check a refcount before=20
> referencing the zero huge page

No we don't. It's parallel *read* page fault benchmark meaning we
map/unmap huge zero page all the time. So it's pure synthetic test to show
refcounting overhead.

If we see only 1% overhead on the synthetic test we will not see it in
real world workloads.

> and it obviously shows in your benchmark=20
> (which I consider 1% to be significant given the alternative is 2MB of=20
> memory for a system where thp was enabled to be on).  I think it would be=
=20
> much better to simply allocate and reference the zero huge page locklessl=
y=20
> when thp is enabled to be either "madvise" or "always", i.e. allocate it=
=20
> when enabled.

--=20
 Kirill A. Shutemov

--TBNym+cBXeFsS4Vs
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJQpLrcAAoJEAd+omnVudOMH0cP/iRBZgwpZv5+HpAxgjjxmL/A
TqZ1q1vqfvJPvX7g239iScBSD6qtpmpm1MBsUwsAkcAWbHaR+Mx2LcPJK1ms4KcT
hoGBONVRIMQqAsZn+c6fS/YobZGzDEJXplFPsgYaTEm2Kovf+B5Dv7TeMP5cd9Cp
7s4YQ2hCaEbup31TrER74tlkGoY0RgKu49jQyY9ImNWu876A/aAlRuKTMWRErKq2
71MG/3cVF2fPhFJouS1we2VcEgpDH7GCUwP6LNa+horbNO08VCX5co78Vyp+RL3f
LqvPNahzmIYd1EyZg1ac5SqEF26luDGhwafzfKMxZr+MepMQOuNlbs9x6xI1y04w
XqqOOrBaee0OXXOCZJcDCTpZKNSIvD9X375Hj6iNxQAQwevGRIcXRl7advqPVP7P
4JDcxPnWBo/wfpDx17L1EUvOo+V06nFJrvhldwfF5CNxCZqWIjxcipz7caLv26In
mCK9JJGS/X4GnyHzFkSC8NX9DI6vAdvzf/aKuOy8QAQ2Lev+DOtGm/TijjWXbSwx
8g+jxUKgZBvKAMkb14tZ9TIUDfcboRuL05da1MVfPTf9rluTQFyqf84qXjtFa8si
IrsU/pQcG6cVl5hIsERLvf56iY72RvLKPVSKAe0EaI7DpCXELFM8LL4mis0yK+m0
OI0JQThxEgfUYCIWwsvQ
=dUW+
-----END PGP SIGNATURE-----

--TBNym+cBXeFsS4Vs--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
