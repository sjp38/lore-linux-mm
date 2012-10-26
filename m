Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id F2D166B0072
	for <linux-mm@kvack.org>; Fri, 26 Oct 2012 09:40:37 -0400 (EDT)
Date: Fri, 26 Oct 2012 16:41:29 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH 1/2] numa, mm: drop redundant check in
 do_huge_pmd_numa_page()
Message-ID: <20121026134129.GA31306@otc-wbsnb-06>
References: <1351256077-1594-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1351256885.16863.62.camel@twins>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="SLDf9lqlvOQaIe6s"
Content-Disposition: inline
In-Reply-To: <1351256885.16863.62.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: linux-mm@kvack.org, Will Deacon <will.deacon@arm.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, linux-kernel@vger.kernel.org


--SLDf9lqlvOQaIe6s
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Oct 26, 2012 at 03:08:05PM +0200, Peter Zijlstra wrote:
> On Fri, 2012-10-26 at 15:54 +0300, Kirill A. Shutemov wrote:
> > From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> >=20
> > We check if the pmd entry is the same as on pmd_trans_huge() in
> > handle_mm_fault(). That's enough.
> >=20
> > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
>=20
> Ah indeed, Will mentioned something like this on IRC as well, I hadn't
> gotten around to looking at it -- now have, thanks!
>=20
> Acked-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
>=20
> That said, where in handle_mm_fault() do we wait for a split to
> complete? We have a pmd_trans_huge() && !pmd_trans_splitting(), so a
> fault on a currently splitting pmd will fall through.
>=20
> Is it the return from the fault on unlikely(pmd_trans_huge()) ?

Yes, this code will catch it:

	/* if an huge pmd materialized from under us just retry later */
	if (unlikely(pmd_trans_huge(*pmd)))
		return 0;

If the pmd is under splitting it's still a pmd_trans_huge().

--=20
 Kirill A. Shutemov

--SLDf9lqlvOQaIe6s
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJQipMJAAoJEAd+omnVudOM8j8P/jV7FrXY1JE5OmKg6Po19tiD
k0TGEYfJvgmpmyX6eNwutMUkZFXit8zBVnqXXLW9RTQivVn/EPRopbh05eq7ulUU
+0i6jNvyrbUaxk7PviW+iejfEkMVlVSOcP4DxRTr8g4LsJmTceKrnCSJCi3mOGj1
Ls9OBxN828xrlSo5d2yX6Keg6TMQL4Ij3fU49cDDruIstcrRQzgq5OLkEK2UDHBY
cvHD4w8ef92eV+x1Z2bj2FITRcEg7oyYkMLretQs7pv+QwfazfRiScGd08pz5uk4
VXplZI55HpqnMElKluYt5LyFvi1pTf0yM7hOulCbb2DXiSciO6WX6hQ0Baljn6t8
WDQ6CkqGgLM3zbicqcfXksv7ST5GJmH9bZuUuhKjjzACMjqgawfombAKBgHWVApo
Q1K91tmUmfYtsakRos4ChbyAjIgg7iUqpGQ9uYNnjEegMgTvdp0OIO3QygbI2IcW
3mmjcbiAWr6J9bbaZ1+cYAt8S0QM8ZXm6dvpLCqYG/6TMsjRNsqpv05GCmDHpX+T
LbBxHA+CaUHMBhPTriDflJFyL2AuUiOTXiNYueD0qQmAGDpfG1I+GI6B0GZwmM8o
HT86DFvoxi0l0JLi8lmrgNve6LT7890i8foavFPAGPTTpK2YIQztKtv8TT1spJ9u
4p85DVfL0h+R2OdAIOZw
=wObX
-----END PGP SIGNATURE-----

--SLDf9lqlvOQaIe6s--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
