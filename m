Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id 0708E6B0123
	for <linux-mm@kvack.org>; Mon, 11 Jun 2012 09:33:29 -0400 (EDT)
Message-ID: <1339421596.4942.10.camel@deadeye.wl.decadent.org.uk>
Subject: Re: [PATCH 5/6] mempolicy: fix a memory corruption by refcount
 imbalance in alloc_pages_vma()
From: Ben Hutchings <ben@decadent.org.uk>
Date: Mon, 11 Jun 2012 14:33:16 +0100
In-Reply-To: <1339406250-10169-6-git-send-email-kosaki.motohiro@gmail.com>
References: <1339406250-10169-1-git-send-email-kosaki.motohiro@gmail.com>
	 <1339406250-10169-6-git-send-email-kosaki.motohiro@gmail.com>
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-OODp9vDT+Ck6zlt1wzhi"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kosaki.motohiro@gmail.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@google.com>, Dave Jones <davej@redhat.com>, Mel Gorman <mgorman@suse.de>, Christoph Lameter <cl@linux.com>, stable@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Miao Xie <miaox@cn.fujitsu.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>


--=-OODp9vDT+Ck6zlt1wzhi
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2012-06-11 at 05:17 -0400, kosaki.motohiro@gmail.com wrote:
> From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>=20
> commit cc9a6c8776 (cpuset: mm: reduce large amounts of memory barrier rel=
ated
> damage v3) introduced a memory corruption.
>=20
> shmem_alloc_page() passes pseudo vma and it has one significant unique
> combination, vma->vm_ops=3DNULL and (vma->policy->flags & MPOL_F_SHARED).
>=20
> Now, get_vma_policy() does NOT increase a policy ref when vma->vm_ops=3DN=
ULL
> and mpol_cond_put() DOES decrease a policy ref when a policy has MPOL_F_S=
HARED.
> Therefore, when alloc_pages_vma() goes 'goto retry_cpuset' path, a policy
> refcount will be decreased too much and therefore it will make a memory c=
orruption.
[...]
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -1544,18 +1544,29 @@ struct mempolicy *get_vma_policy(struct task_stru=
ct *task,
>  		struct vm_area_struct *vma, unsigned long addr)
>  {
>  	struct mempolicy *pol =3D task->mempolicy;
> +	int got_ref;

=3D 0

And this should really be a bool.

>  	if (vma) {
>  		if (vma->vm_ops && vma->vm_ops->get_policy) {
>  			struct mempolicy *vpol =3D vma->vm_ops->get_policy(vma,
>  									addr);
> -			if (vpol)
> +			if (vpol) {
>  				pol =3D vpol;
> +				got_ref =3D 1;
> +			}
>  		} else if (vma->vm_policy)
>  			pol =3D vma->vm_policy;
>  	}
>  	if (!pol)
>  		pol =3D &default_policy;
> +
> +	/*
> +	 * shmem_alloc_page() passes MPOL_F_SHARED policy with vma->vm_ops=3DNU=
LL.
> +	 * Thus, we need to take additional ref for avoiding refcount imbalance=
.
> +	 */
> +	if (!got_ref && mpol_needs_cond_ref(pol))
> +		mpol_get(pol);
> +
>  	return pol;
>  }
> =20
[...]

--=20
Ben Hutchings
Computers are not intelligent.	They only think they are.

--=-OODp9vDT+Ck6zlt1wzhi
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIVAwUAT9XznOe/yOyVhhEJAQol/A//SF8qBKptkmR0O84ZNb9/Lp5tD94c2u4o
pcpOXG4oBlHXmKF+C00A3GwSvCIw5tRVGO5E2lbAisxF2J1sZwyqoJ9+6Jy8XwWa
rP3EijMfwisjzpRVSNCXgDmkwhisrk1g+hOeUeLgsYGUW+I3p3QEUnJrdydEkF1s
Fg4t9QGWh5kOyPk7Zhqhx70TD+xr/yu1iTmKohNbPcHZfsZgCyGKhy6LKD6aXGGP
IJL86r/Ux7bJ8TDQuDW0OMwyoDrvsnYuG7WK/bl8VE6WOUJN6tLri6NkO9hnCjR+
nP8rXizkMLUrLgcEtKH9P2eFjIPZX8qthbtxooCWSXfheLoJleo9gk2mRAU9ca7g
Jk68GfKsfMWjd3XfwyesY2miHCpcyDQd7ClpXuMD4nQL+NciwiSfk/xIqbinmsSl
rbdzAEP7W5rUwelyHwB2kSxTcy0MNAQRSqS/X7C7CK/ADR1Cl5CA8p9+2BSJHwOS
6bwFy7g1n5gRBd7GFkPO2bMW8B4GFign1RvxnsR3JfYIJJVYxde7ieajjQ8WiXs4
uzAgwgXcD1ne7i8CHRhcQLlfFFEQNitbPgZ5hPf37PUfJh2ZPTSzTdvdC2seXaxp
ZbrNw34JnMWobwJV9XxD6Lcc127fqQzIctEuEcny/xloOim8qjDodDqxz3VgCkt+
Pcy5hx3ia78=
=DPVT
-----END PGP SIGNATURE-----

--=-OODp9vDT+Ck6zlt1wzhi--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
