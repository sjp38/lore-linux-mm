Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 1935D6B0031
	for <linux-mm@kvack.org>; Mon, 29 Jul 2013 05:10:21 -0400 (EDT)
Date: Mon, 29 Jul 2013 17:28:23 +1000
From: David Gibson <david@gibson.dropbear.id.au>
Subject: Re: [PATCH 17/18] mm, hugetlb: retry if we fail to allocate a
 hugepage with use_reserve
Message-ID: <20130729072823.GD29970@voom.fritz.box>
References: <1375075929-6119-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1375075929-6119-18-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="hoZxPH4CaxYzWscb"
Content-Disposition: inline
In-Reply-To: <1375075929-6119-18-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <dhillf@gmail.com>


--hoZxPH4CaxYzWscb
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Jul 29, 2013 at 02:32:08PM +0900, Joonsoo Kim wrote:
> If parallel fault occur, we can fail to allocate a hugepage,
> because many threads dequeue a hugepage to handle a fault of same address.
> This makes reserved pool shortage just for a little while and this cause
> faulting thread who is ensured to have enough reserved hugepages
> to get a SIGBUS signal.

It's not just about reserved pages.  The same race can happen
perfectly well when you're really, truly allocating the last hugepage
in the system.

>=20
> To solve this problem, we already have a nice solution, that is,
> a hugetlb_instantiation_mutex. This blocks other threads to dive into
> a fault handler. This solve the problem clearly, but it introduce
> performance degradation, because it serialize all fault handling.
>=20
> Now, I try to remove a hugetlb_instantiation_mutex to get rid of
> performance degradation. A prerequisite is that other thread should
> not get a SIGBUS if they are ensured to have enough reserved pages.
>=20
> For this purpose, if we fail to allocate a new hugepage with use_reserve,
> we return just 0, instead of VM_FAULT_SIGBUS. use_reserve
> represent that this user is legimate one who are ensured to have enough
> reserved pages. This prevent these thread not to get a SIGBUS signal and
> make these thread retrying fault handling.

Not sufficient, since it can happen without reserved pages.

Also, I think there are edge cases where even reserved mappings can
run out, in particular with the interaction between MAP_PRIVATE,
fork() and reservations.  In this case, when you have a genuine out of
memory condition, you will spin forever on the fault.

>=20
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>=20
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 6a9ec69..909075b 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -2623,7 +2623,10 @@ retry_avoidcopy:
>  			WARN_ON_ONCE(1);
>  		}
> =20
> -		ret =3D VM_FAULT_SIGBUS;
> +		if (use_reserve)
> +			ret =3D 0;
> +		else
> +			ret =3D VM_FAULT_SIGBUS;
>  		goto out_lock;
>  	}
> =20
> @@ -2741,7 +2744,10 @@ retry:
> =20
>  		page =3D alloc_huge_page(vma, address, use_reserve);
>  		if (IS_ERR(page)) {
> -			ret =3D VM_FAULT_SIGBUS;
> +			if (use_reserve)
> +				ret =3D 0;
> +			else
> +				ret =3D VM_FAULT_SIGBUS;
>  			goto out;
>  		}
>  		clear_huge_page(page, address, pages_per_huge_page(h));

--=20
David Gibson			| I'll have my music baroque, and my code
david AT gibson.dropbear.id.au	| minimalist, thank you.  NOT _the_ _other_
				| _way_ _around_!
http://www.ozlabs.org/~dgibson

--hoZxPH4CaxYzWscb
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.13 (GNU/Linux)

iEYEARECAAYFAlH2GZcACgkQaILKxv3ab8a9ywCfdDhZEMfPlPQByygWhPMGPX02
qzwAn1LBvtlxZWcs/sMGCCAYu4OBoLkh
=p8Wa
-----END PGP SIGNATURE-----

--hoZxPH4CaxYzWscb--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
