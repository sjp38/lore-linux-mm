Received: from 218-101-109-217.dialup.clear.net.nz
 (218-101-109-217.dialup.clear.net.nz [218.101.109.217])
 by smtp2.clear.net.nz (CLEAR Net Mail)
 with ESMTP id <0HRS0029L0K01Q@smtp2.clear.net.nz> for linux-mm@kvack.org; Tue,
 20 Jan 2004 19:55:15 +1300 (NZDT)
Date: Tue, 20 Jan 2004 20:00:20 +1300
From: Nigel Cunningham <ncunningham@users.sourceforge.net>
Subject: Re: Memory management in 2.6
In-reply-to: <400CB3BD.4020601@cyberone.com.au>
Reply-to: ncunningham@users.sourceforge.net
Message-id: <1074582020.2246.1.camel@laptop-linux>
MIME-version: 1.0
Content-type: multipart/signed; boundary="=-B44nShPYTGfsuVD59vtk";
 protocol="application/pgp-signature"; micalg=pgp-sha1
References: <400CB3BD.4020601@cyberone.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <piggin@cyberone.com.au>
Cc: Linux Memory Management <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>, Michael Frank <mhf@linuxmail.org>
List-ID: <linux-mm.kvack.org>

--=-B44nShPYTGfsuVD59vtk
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

Hi.

Michael Frank has written some scripts  we've used to stress test
software suspend. Perhaps you might be able to make some mileage from
them?

Regards,

Nigel

On Tue, 2004-01-20 at 17:51, Nick Piggin wrote:
> Hi,
> In the interest of helping improve 2.6 VM performance when
> under heavy swapping load, I'm putting together a few regression
> tests.
>=20
> If anyone has any suggestions of workloads I could use, I will
> try to include them, or code them up if you want a simple concept
> tested. Also, any suggestions of what information I should gather?
>=20
> loads should be runnable on about 64MB, preferably give decently
> repeatable results in under an hour.
>=20
> I'll be happy to test patches. Here is one (results are a bit
> wild because it was only 1 run).
>=20
> Nick
>=20
>=20
> ______________________________________________________________________
>  linux-2.6-npiggin/mm/vmscan.c |   30 +++++++++++++++++++++++-------
>  1 files changed, 23 insertions(+), 7 deletions(-)
>=20
> diff -puN mm/vmscan.c~vm-akpm-balance-pgdat mm/vmscan.c
> --- linux-2.6/mm/vmscan.c~vm-akpm-balance-pgdat	2004-01-17 20:35:39.00000=
0000 +1100
> +++ linux-2.6-npiggin/mm/vmscan.c	2004-01-17 20:35:42.000000000 +1100
> @@ -941,11 +941,12 @@ static int balance_pgdat(pg_data_t *pgda
>  			int nr_mapped =3D 0;
>  			int max_scan;
>  			int to_reclaim;
> +			int reclaimed;
> =20
>  			if (zone->all_unreclaimable && priority !=3D DEF_PRIORITY)
>  				continue;
> =20
> -			if (nr_pages && to_free > 0) {	/* Software suspend */
> +			if (nr_pages && nr_pages > 0) {	/* Software suspend */
>  				to_reclaim =3D min(to_free, SWAP_CLUSTER_MAX*8);
>  			} else {			/* Zone balancing */
>  				to_reclaim =3D zone->pages_high-zone->free_pages;
> @@ -953,28 +954,43 @@ static int balance_pgdat(pg_data_t *pgda
>  					continue;
>  			}
>  			zone->temp_priority =3D priority;
> -			all_zones_ok =3D 0;
>  			max_scan =3D zone->nr_inactive >> priority;
>  			if (max_scan < to_reclaim * 2)
>  				max_scan =3D to_reclaim * 2;
>  			if (max_scan < SWAP_CLUSTER_MAX)
>  				max_scan =3D SWAP_CLUSTER_MAX;
> -			to_free -=3D shrink_zone(zone, max_scan, GFP_KERNEL,
> +			reclaimed =3D shrink_zone(zone, max_scan, GFP_KERNEL,
>  					to_reclaim, &nr_mapped, ps, priority);
>  			if (i < ZONE_HIGHMEM) {
>  				reclaim_state->reclaimed_slab =3D 0;
>  				shrink_slab(max_scan + nr_mapped, GFP_KERNEL);
> -				to_free -=3D reclaim_state->reclaimed_slab;
> +				reclaimed +=3D reclaim_state->reclaimed_slab;
>  			}
> +			to_free -=3D reclaimed;
>  			if (zone->all_unreclaimable)
>  				continue;
>  			if (zone->pages_scanned > zone->present_pages * 2)
>  				zone->all_unreclaimable =3D 1;
> +			/*
> +			 * If this scan failed to reclaim `to_reclaim' or more
> +			 * pages, we're getting into trouble.  Need to scan
> +			 * some more, and throttle kswapd.   Note that this zone
> +			 * may now have sufficient free pages due to freeing
> +			 * activity by some other process.   That's OK - we'll
> +			 * pick that info up on the next pass through the loop.
> +			 */
> +			if (reclaimed < to_reclaim)
> +				all_zones_ok =3D 0;
>  		}
> -		if (all_zones_ok)
> -			break;
>  		if (to_free > 0)
> -			blk_congestion_wait(WRITE, HZ/10);
> +			continue;	/* swsusp: need to do more work */
> +		if (all_zones_ok)
> +			break;		/* kswapd: all done */
> +		/*
> +		 * OK, kswapd is getting into trouble.  Take a nap, then take
> +		 * another pass across the zones.
> +		 */
> +		blk_congestion_wait(WRITE, HZ/10);
>  	}
> =20
>  	for (i =3D 0; i < pgdat->nr_zones; i++) {
>=20
> _
--=20
My work on Software Suspend is graciously brought to you by
LinuxFund.org.

--=-B44nShPYTGfsuVD59vtk
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.3 (GNU/Linux)

iD8DBQBADNIEVfpQGcyBBWkRAjYRAJ9WnZDrcLlRAdbPGiV4cZl/CK+PtwCZAeu4
7fHKoac4Cl9+Ja4WfQZ86q4=
=Jpr+
-----END PGP SIGNATURE-----

--=-B44nShPYTGfsuVD59vtk--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
