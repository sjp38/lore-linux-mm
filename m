Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id ADBBA6B0031
	for <linux-mm@kvack.org>; Sun,  4 Aug 2013 05:48:38 -0400 (EDT)
Date: Sat, 3 Aug 2013 20:43:02 +1000
From: David Gibson <david@gibson.dropbear.id.au>
Subject: Re: [PATCH 17/18] mm, hugetlb: retry if we fail to allocate a
 hugepage with use_reserve
Message-ID: <20130803104302.GC19115@voom.redhat.com>
References: <1375075929-6119-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1375075929-6119-18-git-send-email-iamjoonsoo.kim@lge.com>
 <20130729072823.GD29970@voom.fritz.box>
 <20130731053753.GM2548@lge.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="i7F3eY7HS/tUJxUd"
Content-Disposition: inline
In-Reply-To: <20130731053753.GM2548@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <dhillf@gmail.com>


--i7F3eY7HS/tUJxUd
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Jul 31, 2013 at 02:37:53PM +0900, Joonsoo Kim wrote:
> Hello, David.
>=20
> On Mon, Jul 29, 2013 at 05:28:23PM +1000, David Gibson wrote:
> > On Mon, Jul 29, 2013 at 02:32:08PM +0900, Joonsoo Kim wrote:
> > > If parallel fault occur, we can fail to allocate a hugepage,
> > > because many threads dequeue a hugepage to handle a fault of same add=
ress.
> > > This makes reserved pool shortage just for a little while and this ca=
use
> > > faulting thread who is ensured to have enough reserved hugepages
> > > to get a SIGBUS signal.
> >=20
> > It's not just about reserved pages.  The same race can happen
> > perfectly well when you're really, truly allocating the last hugepage
> > in the system.
>=20
> Yes, you are right.
> This is a critical comment to this patchset :(
>=20
> IIUC, the case you mentioned is about tasks which have a mapping
> with MAP_NORESERVE.

Any mapping that doesn't use the reserved pool, not just
MAP_NORESERVE.  For example, if a process makes a MAP_PRIVATE mapping,
then fork()s then the mapping is instantiated in the child, that will
not draw from the reserved pool.

> Should we ensure them to allocate the last hugepage?
> They map a region with MAP_NORESERVE, so don't assume that their requests
> always succeed.

If the pages are available, people get cranky if it fails for no
apparent reason, MAP_NORESERVE or not.  They get especially cranky if
it sometimes fails and sometimes doesn't due to a race condition.

--=20
David Gibson			| I'll have my music baroque, and my code
david AT gibson.dropbear.id.au	| minimalist, thank you.  NOT _the_ _other_
				| _way_ _around_!
http://www.ozlabs.org/~dgibson

--i7F3eY7HS/tUJxUd
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.13 (GNU/Linux)

iEYEARECAAYFAlH83rYACgkQaILKxv3ab8a6mACeMcPoIM7Q8waoJo5GgwcXbXSf
XG4An3cwsVzfNm5tifu9JOOLiDzisiap
=dFyv
-----END PGP SIGNATURE-----

--i7F3eY7HS/tUJxUd--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
