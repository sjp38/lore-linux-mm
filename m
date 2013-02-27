Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id C01AC6B0005
	for <linux-mm@kvack.org>; Wed, 27 Feb 2013 02:27:20 -0500 (EST)
Date: Wed, 27 Feb 2013 02:25:17 -0500
From: Chen Gong <gong.chen@linux.intel.com>
Subject: Re: [PATCH 3/9] soft-offline: use migrate_pages() instead of
 migrate_huge_page()
Message-ID: <20130227072517.GA30971@gchen.bj.intel.com>
References: <1361475708-25991-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1361475708-25991-4-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="MGYHOYXEY6WxJCY8"
Content-Disposition: inline
In-Reply-To: <1361475708-25991-4-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org


--MGYHOYXEY6WxJCY8
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Feb 21, 2013 at 02:41:42PM -0500, Naoya Horiguchi wrote:
> Date: Thu, 21 Feb 2013 14:41:42 -0500
> From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> To: linux-mm@kvack.org
> Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>,
>  Hugh Dickins <hughd@google.com>, KOSAKI Motohiro
>  <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>,
>  linux-kernel@vger.kernel.org
> Subject: [PATCH 3/9] soft-offline: use migrate_pages() instead of
>  migrate_huge_page()
>=20
> Currently migrate_huge_page() takes a pointer to a hugepage to be
> migrated as an argument, instead of taking a pointer to the list of
> hugepages to be migrated. This behavior was introduced in commit
> 189ebff28 ("hugetlb: simplify migrate_huge_page()"), and was OK
> because until now hugepage migration is enabled only for soft-offlining
> which takes only one hugepage in a single call.
>=20
> But the situation will change in the later patches in this series
> which enable other users of page migration to support hugepage migration.
> They can kick migration for both of normal pages and hugepages
> in a single call, so we need to go back to original implementation
> of using linked lists to collect the hugepages to be migrated.
>=20
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> ---
>  mm/memory-failure.c | 20 ++++++++++++++++----
>  mm/migrate.c        |  2 ++
>  2 files changed, 18 insertions(+), 4 deletions(-)
>=20
> diff --git v3.8.orig/mm/memory-failure.c v3.8/mm/memory-failure.c
> index bc126f6..01e4676 100644
> --- v3.8.orig/mm/memory-failure.c
> +++ v3.8/mm/memory-failure.c
> @@ -1467,6 +1467,7 @@ static int soft_offline_huge_page(struct page *page=
, int flags)
>  	int ret;
>  	unsigned long pfn =3D page_to_pfn(page);
>  	struct page *hpage =3D compound_head(page);
> +	LIST_HEAD(pagelist);
> =20
>  	/* Synchronized using the page lock with memory_failure() */
>  	lock_page(hpage);
> @@ -1479,13 +1480,24 @@ static int soft_offline_huge_page(struct page *pa=
ge, int flags)
>  	unlock_page(hpage);
> =20
>  	/* Keep page count to indicate a given hugepage is isolated. */
> -	ret =3D migrate_huge_page(hpage, new_page, MPOL_MF_MOVE_ALL, false,
> -				MIGRATE_SYNC);
> -	put_page(hpage);
> +	list_move(&hpage->lru, &pagelist);
> +	ret =3D migrate_pages(&pagelist, new_page, MPOL_MF_MOVE_ALL, false,
> +				MIGRATE_SYNC, MR_MEMORY_FAILURE);
>  	if (ret) {
>  		pr_info("soft offline: %#lx: migration failed %d, type %lx\n",
>  			pfn, ret, page->flags);
> -		return ret;
> +		/*
> +		 * We know that soft_offline_huge_page() tries to migrate
> +		 * only one hugepage pointed to by hpage, so we need not
> +		 * run through the pagelist here.
> +		 */
> +		putback_active_hugepage(hpage);
> +		if (ret > 0)
> +			ret =3D -EIO;
> +	} else {
> +		set_page_hwpoison_huge_page(hpage);
> +		dequeue_hwpoisoned_huge_page(hpage);
> +		atomic_long_add(1<<compound_trans_order(hpage), &mce_bad_pages);

mce_bad_pages has been substituted by num_poisoned_pages.

[...]

--MGYHOYXEY6WxJCY8
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJRLbTdAAoJEI01n1+kOSLHGogP/Rcv8RKngbiqPEqKYrooYRB7
t0w4yXk9Fn6oewPaUOLFc7WNflFvbLeQI7cPgFjnbP+nB9HKaqVlH52q11363pWK
8hKfRy33gj2cXKbXjBh+Yy+QaeB+HDJQ4gXRGKtVM2O9J03su/GvA6Vx2rj1gnz/
qQkYPu9Zu/9yL3PZP7ggRp9zhO+F6KxEmxdk3HB1UL0qUuEgPi5jqHNN+0euYDXO
p8Vm0NZ68ZHvvfmQswIlzDQpr7F1UOpJJTShBHU0hqsh7Wf1IgDiEfjMljy3xkIl
4p+w+aM733cqxlvDguFzQSiwefwS+s2+OKaAikQSWjKkMZzWRetF+IYa0omJBoKI
g0yl6e8KJKW0t1vB+NSwFbqbyXqethmIiQVFyS/Ym6zAHtP+3NR5CK4E5Q3VrIhp
61plLmxYhuTficNO/T6APwKOHEvE8hHloxuA8c+HpyqrGfXAXmDk2DBo4oIMhuTy
YsrPpxA4mhBDjiP/j95XtGLNWuPwAbXAXEBd7LOmzwfFH7tRceTNEwgkEIvabPKc
YnqpMJrjoCLRO4Kge885VTW544FHWbwgjLbt6jcSUT0GfqAl4xuxlx4kG8NZKg4W
GFB4xxvlnv8uIdbZoXhUE/lOzoKyB1PRD24Tawb0qz1vzXhS/bMGKN1/KenDOtPC
b6SQkMDSmtZYgTPudAcJ
=XqMo
-----END PGP SIGNATURE-----

--MGYHOYXEY6WxJCY8--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
