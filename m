Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id 5408E6B004D
	for <linux-mm@kvack.org>; Fri, 20 Jul 2012 07:18:02 -0400 (EDT)
Date: Fri, 20 Jul 2012 14:19:47 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH] Cgroup: Fix memory accounting scalability in
 shrink_page_list
Message-ID: <20120720111947.GA8035@otc-wbsnb-06>
References: <1342740866.13492.50.camel@schen9-DESK>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="17pEHd4RhPHOinZp"
Content-Disposition: inline
In-Reply-To: <1342740866.13492.50.camel@schen9-DESK>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, "andi.kleen" <andi.kleen@intel.com>, linux-mm <linux-mm@kvack.org>, linux-kernel@vger.kernel.org


--17pEHd4RhPHOinZp
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Jul 19, 2012 at 04:34:26PM -0700, Tim Chen wrote:
> Hi,
>=20
> I noticed in a multi-process parallel files reading benchmark I ran on a
> 8 socket machine,  throughput slowed down by a factor of 8 when I ran
> the benchmark within a cgroup container.  I traced the problem to the
> following code path (see below) when we are trying to reclaim memory
> from file cache.  The res_counter_uncharge function is called on every
> page that's reclaimed and created heavy lock contention.  The patch
> below allows the reclaimed pages to be uncharged from the resource
> counter in batch and recovered the regression.=20
>=20
> Tim
>=20
>      40.67%           usemem  [kernel.kallsyms]                   [k] _ra=
w_spin_lock
>                       |
>                       --- _raw_spin_lock
>                          |
>                          |--92.61%-- res_counter_uncharge
>                          |          |
>                          |          |--100.00%-- __mem_cgroup_uncharge_co=
mmon
>                          |          |          |
>                          |          |          |--100.00%-- mem_cgroup_un=
charge_cache_page
>                          |          |          |          __remove_mapping
>                          |          |          |          shrink_page_list
>                          |          |          |          shrink_inactive=
_list
>                          |          |          |          shrink_mem_cgro=
up_zone
>                          |          |          |          shrink_zone
>                          |          |          |          do_try_to_free_=
pages
>                          |          |          |          try_to_free_pag=
es
>                          |          |          |          __alloc_pages_n=
odemask
>                          |          |          |          alloc_pages_cur=
rent
>=20
>=20
> ---
> Signed-off-by: Tim Chen <tim.c.chen@linux.intel.com>

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

--=20
 Kirill A. Shutemov

--17pEHd4RhPHOinZp
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJQCT7TAAoJEAd+omnVudOMAScP/AjkMoJgxfipxvTEKFcMdEM4
Bb1iqr1KcfjeeHI8c1FSGKuE2q9BLBP6GXogodLSXxJtjcMMDrXoPtt7KzA/cuZZ
IbUbtP+Go4y5LPbPsnByXpize+DtebuOhCnnhLA3YMr6z/wsxZMLvGfHvA3sP0YB
wmHi3vd3GkHC280+1PBP0odRlMb9UylfPjW7lDawLtRrTxoDJ0N1DTnDR44myXUs
C1MOz466kvjWe4RKDfJwNex7KD2wufGeY7XRv/RMdh43A5fMOjpKSJC6Oq9DbjT7
tjXo/xsz4sn9LoTD/x3Sq/AfpQMmj2I3VXZO1ELANKpJkCrOUHPNPA7FupcSe9Pl
CU4EhZxy4NGNfDr9G8ChPLxWvBpDOVpOHkknVltJtSgl+84M2C8UMf/HKoWkYld+
FxNZBMSywWMRrCNVNpLVt3VvLTiKunaI54U++uL7GblETzEIlPb1FX4R1Iz9t55A
VKRi/n3rHp4ZKrOa7gysD3hULfbwMNcv0MBd55LzF1X95M0f8Jd0TRLR5rUigwt3
b9b2EJ2YjhTC4ncKy2koxamoAtuSpJO0dtfjj/dVk2qgI6IpLabyL6eeCD448F1Q
pY2H9mZZTnnBKw9Quk7qdX6jb3rl4DIb0WKZFoReqckjuhAkClJbyUyVrP/Gjwzy
qjbnOxaRJ3LMygyeQchX
=UrYg
-----END PGP SIGNATURE-----

--17pEHd4RhPHOinZp--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
