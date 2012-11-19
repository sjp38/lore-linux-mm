Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id 40DA26B006C
	for <linux-mm@kvack.org>; Mon, 19 Nov 2012 04:55:07 -0500 (EST)
Date: Mon, 19 Nov 2012 11:56:15 +0200
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH v6 10/12] thp: implement refcounting for huge zero page
Message-ID: <20121119095615.GA23869@otc-wbsnb-06>
References: <1353007622-18393-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1353007622-18393-11-git-send-email-kirill.shutemov@linux.intel.com>
 <50A87EF0.3060706@gmail.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="82I3+IH0IqGh5yIs"
Content-Disposition: inline
In-Reply-To: <50A87EF0.3060706@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jaegeuk Hanse <jaegeuk.hanse@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, "H. Peter Anvin" <hpa@linux.intel.com>, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill@shutemov.name>, David Rientjes <rientjes@google.com>


--82I3+IH0IqGh5yIs
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sun, Nov 18, 2012 at 02:23:44PM +0800, Jaegeuk Hanse wrote:
> On 11/16/2012 03:27 AM, Kirill A. Shutemov wrote:
> >From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> >
> >H. Peter Anvin doesn't like huge zero page which sticks in memory forever
> >after the first allocation. Here's implementation of lockless refcounting
> >for huge zero page.
> >
> >We have two basic primitives: {get,put}_huge_zero_page(). They
> >manipulate reference counter.
> >
> >If counter is 0, get_huge_zero_page() allocates a new huge page and
> >takes two references: one for caller and one for shrinker. We free the
> >page only in shrinker callback if counter is 1 (only shrinker has the
> >reference).
> >
> >put_huge_zero_page() only decrements counter. Counter is never zero
> >in put_huge_zero_page() since shrinker holds on reference.
> >
> >Freeing huge zero page in shrinker callback helps to avoid frequent
> >allocate-free.
> >
> >Refcounting has cost. On 4 socket machine I observe ~1% slowdown on
> >parallel (40 processes) read page faulting comparing to lazy huge page
> >allocation.  I think it's pretty reasonable for synthetic benchmark.
>=20
> Hi Kirill,
>=20
> I see your and Andew's hot discussion in v4 resend thread.
>=20
> "I also tried another scenario: usemem -n16 100M -r 1000. It creates
> real memory pressure - no easy reclaimable memory. This time
> callback called with nr_to_scan > 0 and we freed hzp. "
>=20
> What's "usemem"? Is it a tool and how to get it?

http://www.spinics.net/lists/linux-mm/attachments/gtarazbJaHPaAT.gtar

> It's hard for me to
> find nr_to_scan > 0 in every callset, how can nr_to_scan > 0 in your
> scenario?

shrink_slab() calls the callback with nr_to_scan > 0 if system is under
pressure -- look for do_shrinker_shrink().

--=20
 Kirill A. Shutemov

--82I3+IH0IqGh5yIs
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJQqgI/AAoJEAd+omnVudOMZosP/RwLT7DEH5aY8rUOVLEvDhBV
blCQEQ3tADzUnT3ZsfvvtA/CxFHKWy5Dbmzx4dSQdirwP27nXjepL7yEW8zI6RSg
qCyg6S54L6BIjlkeCQq35LDXWkgV/oruh9DQsBke7aDojefIfiiiBDAW4RwIYgAW
THsx0VdPI5AyV9Ls6Qxhd61rhyeII1Z6SfZBJJQxeJRfP6w5Lp5upyAefQn0DduN
htLWO12ueRyy1D72NY0l8egq9lg3BpHQryXYbKFL0sCuTD93dKHG+Mzr9go9gSIz
pjAU7jXrogCTLHD6vyV5qrtrxe9raWrUyUrWc+tlYG/F/Ybz6K0kjxC00XM8BtOO
bLt4UO4ooQ17TEluf4cLoAN8Sb03cN/QXkJnCzLD+cAmsaI9U7yROxKcXNJl440Z
A+QZx/YVMuMRJ4kEWoaSiiUEIH8QdYQGZNSWiEgBUfu2ja40X9tjkKi88UQKsbjZ
SPGorA7G4WLPt9zLPCw3WdP+W+L5koIeSQ8tXY2ZiCNrcjxkWPrVxt9UmM45stGm
E6CxLGUBHatYKT5lbJEwWqNnN3sCSy6yyJsbMg4zGseC31gmQ4Uo0nPDmuK61q57
hvzVOi933xDFsdqrrFFbwm6FIgdaapF0jiZGwAk+SkYD+fZWBuVni8nexZpaX4de
BDTBasFuUrl5p5wKcX9p
=nSfS
-----END PGP SIGNATURE-----

--82I3+IH0IqGh5yIs--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
