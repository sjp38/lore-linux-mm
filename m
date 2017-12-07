Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5DF986B0033
	for <linux-mm@kvack.org>; Thu,  7 Dec 2017 09:12:00 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id a10so5297512pgq.3
        for <linux-mm@kvack.org>; Thu, 07 Dec 2017 06:12:00 -0800 (PST)
Received: from NAM02-CY1-obe.outbound.protection.outlook.com (mail-cys01nam02on0103.outbound.protection.outlook.com. [104.47.37.103])
        by mx.google.com with ESMTPS id 7si3794512ple.586.2017.12.07.06.11.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 07 Dec 2017 06:11:58 -0800 (PST)
Message-ID: <5A294BE7.4010904@cs.rutgers.edu>
Date: Thu, 07 Dec 2017 22:10:47 +0800
From: Zi Yan <zi.yan@cs.rutgers.edu>
MIME-Version: 1.0
Subject: Re: [RFC PATCH] mm: unclutter THP migration
References: <20171207124815.12075-1-mhocko@kernel.org>
In-Reply-To: <20171207124815.12075-1-mhocko@kernel.org>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="------------enigAE95FC686FE59058D452B4EB"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Andrea Reale <ar@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigAE95FC686FE59058D452B4EB
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Hi Michal,

Thanks for sending this out.

Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
>=20
> THP migration is hacked into the generic migration with rather
> surprising semantic. The migration allocation callback is supposed to
> check whether the THP can be migrated at once and if that is not the
> case then it allocates a simple page to migrate. unmap_and_move then
> fixes that up by spliting the THP into small pages while moving the
> head page to the newly allocated order-0 page. Remaning pages are moved=

> to the LRU list by split_huge_page. The same happens if the THP
> allocation fails. This is really ugly and error prone [1].
>=20
> I also believe that split_huge_page to the LRU lists is inherently
> wrong because all tail pages are not migrated. Some callers will just

I agree with you that we should try to migrate all tail pages if the THP
needs to be split. But this might not be compatible with "getting
migration results" in unmap_and_move(), since a caller of
migrate_pages() may want to know the status of each page in the
migration list via int **result in get_new_page() (e.g.
new_page_node()). The caller has no idea whether a THP in its migration
list will be split or not, thus, storing migration results might be
quite tricky if tail pages are added into the migration list.

We need to consider this when we clean up migrate_pages().

> work around that by retrying (e.g. memory hotplug). There are other
> pfn walkers which are simply broken though. e.g. madvise_inject_error
> will migrate head and then advances next pfn by the huge page size.
> do_move_page_to_node_array, queue_pages_range (migrate_pages, mbind),
> will simply split the THP before migration if the THP migration is not
> supported then falls back to single page migration but it doesn't handl=
e
> tail pages if the THP migration path is not able to allocate a fresh
> THP so we end up with ENOMEM and fail the whole migration which is
> a questionable behavior. Page compaction doesn't try to migrate large
> pages so it should be immune.
>=20
> This patch tries to unclutter the situation by moving the special THP
> handling up to the migrate_pages layer where it actually belongs. We
> simply split the THP page into the existing list if unmap_and_move fail=
s
> with ENOMEM and retry. So we will _always_ migrate all THP subpages and=

> specific migrate_pages users do not have to deal with this case in a
> special way.
>=20
> [1] https://na01.safelinks.protection.outlook.com/?url=3Dhttp%3A%2F%2Fl=
kml.kernel.org%2Fr%2F20171121021855.50525-1-zi.yan%40sent.com&data=3D02%7=
C01%7Czi.yan%40cs.rutgers.edu%7C1eb88428b6a24e774ee108d53d70cf1f%7Cb92d2b=
234d35447093ff69aca6632ffe%7C1%7C0%7C636482477084480449&sdata=3Dq5nY%2Fe%=
2F8peEiR1YdcdE3PBGBhC%2B4VsCwadBpQGMeBCo%3D&reserved=3D0
>=20
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
> Hi,
> this is a follow up for [2]. I find this approach much less hackish and=

> easier to maintain as well. It also fixes few bugs. I didn't really go
> deeply into each migration path and evaluate the user visible bugs but
> at least the explicit migration is suboptimal to say the least
>=20
> # A simple 100M mmap with MADV_HUGEPAGE and explicit migrate from node =
0
> # to node 1 with results displayed "After pause"
> root@test1:~# numactl -m 0 ./map_thp=20
> 7f749d0aa000 bind:0 anon=3D25600 dirty=3D25600 N0=3D25600 kernelpagesiz=
e_kB=3D4
> 7f749d0aa000-7f74a34aa000 rw-p 00000000 00:00 0=20
> Size:             102400 kB
> Rss:              102400 kB
> AnonHugePages:    100352 kB
>=20
> After pause
> 7f749d0aa000 bind:0 anon=3D25600 dirty=3D25600 N0=3D18602 N1=3D6998 ker=
nelpagesize_kB=3D4
> 7f749d0aa000-7f74a34aa000 rw-p 00000000 00:00 0=20
> Size:             102400 kB
> Rss:              102400 kB
> AnonHugePages:    100352 kB
>=20
> root@test1:~# migratepages $(pgrep map_thp) 0 1
> migrate_pages: Cannot allocate memory
>=20
> While the migration succeeds with the patch applied even though some TH=
P
> had to be split and migrated page by page.
>=20
> I believe that thp_migration_supported shouldn't be spread outside
> of the migration code but I've left few assertion in place. Maybe
> they should go as well. I haven't spent too much time on those. My
> testing was quite limited and this might still blow up so I would reall=
y
> appreciate a careful review.
>=20
> Thanks!
>=20
> [2] https://na01.safelinks.protection.outlook.com/?url=3Dhttp%3A%2F%2Fl=
kml.kernel.org%2Fr%2F20171122130121.ujp6qppa7nhahazh%40dhcp22.suse.cz&dat=
a=3D02%7C01%7Czi.yan%40cs.rutgers.edu%7C1eb88428b6a24e774ee108d53d70cf1f%=
7Cb92d2b234d35447093ff69aca6632ffe%7C1%7C0%7C636482477084480449&sdata=3D9=
W%2FW3zgu8lKXEZLoXRi%2BQd9xr1PuuSI%2FRZZrl2ylkdQ%3D&reserved=3D0
>=20
>  include/linux/migrate.h |  6 ++++--
>  mm/huge_memory.c        |  6 ++++++
>  mm/memory_hotplug.c     |  2 +-
>  mm/mempolicy.c          | 29 ++---------------------------
>  mm/migrate.c            | 31 ++++++++++++++++++++-----------
>  5 files changed, 33 insertions(+), 41 deletions(-)
>=20
> diff --git a/include/linux/migrate.h b/include/linux/migrate.h
> index a2246cf670ba..ec9503e5f2c2 100644
> --- a/include/linux/migrate.h
> +++ b/include/linux/migrate.h
> @@ -43,9 +43,11 @@ static inline struct page *new_page_nodemask(struct =
page *page,
>  		return alloc_huge_page_nodemask(page_hstate(compound_head(page)),
>  				preferred_nid, nodemask);
> =20
> -	if (thp_migration_supported() && PageTransHuge(page)) {
> -		order =3D HPAGE_PMD_ORDER;
> +	if (PageTransHuge(page)) {
> +		if (!thp_migration_supported())
> +			return NULL;
We may not need these two lines, since if thp_migration_supported() is
false, unmap_and_move() returns -ENOMEM in your code below, which has
the same result of returning NULL here.

>  		gfp_mask |=3D GFP_TRANSHUGE;
> +		order =3D HPAGE_PMD_ORDER;
>  	}
> =20
>  	if (PageHighMem(page) || (zone_idx(page_zone(page)) =3D=3D ZONE_MOVAB=
LE))
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 7544ce4ef4dc..304f39b9aa5c 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -2425,6 +2425,12 @@ static void __split_huge_page_tail(struct page *=
head, int tail,
> =20
>  	page_tail->index =3D head->index + tail;
>  	page_cpupid_xchg_last(page_tail, page_cpupid_last(head));
> +
> +	/*
> +	 * always add to the tail because some iterators expect new
> +	 * pages to show after the currently processed elements - e.g.
> +	 * migrate_pages
> +	 */
>  	lru_add_page_tail(head, page_tail, lruvec, list);
>  }
> =20
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index d0856ab2f28d..ad0a84aa7b53 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -1391,7 +1391,7 @@ do_migrate_range(unsigned long start_pfn, unsigne=
d long end_pfn)
>  			if (isolate_huge_page(page, &source))
>  				move_pages -=3D 1 << compound_order(head);
>  			continue;
> -		} else if (thp_migration_supported() && PageTransHuge(page))
> +		} else if (PageTransHuge(page))
>  			pfn =3D page_to_pfn(compound_head(page))
>  				+ hpage_nr_pages(page) - 1;
> =20
> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> index f604b22ebb65..49ecbb50b5f0 100644
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -446,15 +446,6 @@ static int queue_pages_pmd(pmd_t *pmd, spinlock_t =
*ptl, unsigned long addr,
>  		__split_huge_pmd(walk->vma, pmd, addr, false, NULL);
>  		goto out;
>  	}
> -	if (!thp_migration_supported()) {
> -		get_page(page);
> -		spin_unlock(ptl);
> -		lock_page(page);
> -		ret =3D split_huge_page(page);
> -		unlock_page(page);
> -		put_page(page);
> -		goto out;
> -	}
>  	if (!queue_pages_required(page, qp)) {
>  		ret =3D 1;
>  		goto unlock;
> @@ -511,22 +502,6 @@ static int queue_pages_pte_range(pmd_t *pmd, unsig=
ned long addr,
>  			continue;
>  		if (!queue_pages_required(page, qp))
>  			continue;
> -		if (PageTransCompound(page) && !thp_migration_supported()) {
> -			get_page(page);
> -			pte_unmap_unlock(pte, ptl);
> -			lock_page(page);
> -			ret =3D split_huge_page(page);
> -			unlock_page(page);
> -			put_page(page);
> -			/* Failed to split -- skip. */
> -			if (ret) {
> -				pte =3D pte_offset_map_lock(walk->mm, pmd,
> -						addr, &ptl);
> -				continue;
> -			}
> -			goto retry;
> -		}
> -
>  		migrate_page_add(page, qp->pagelist, flags);
>  	}
>  	pte_unmap_unlock(pte - 1, ptl);
> @@ -947,7 +922,7 @@ static struct page *new_node_page(struct page *page=
, unsigned long node, int **x
>  	if (PageHuge(page))
>  		return alloc_huge_page_node(page_hstate(compound_head(page)),
>  					node);
> -	else if (thp_migration_supported() && PageTransHuge(page)) {
> +	else if (PageTransHuge(page)) {
>  		struct page *thp;
> =20
>  		thp =3D alloc_pages_node(node,
> @@ -1123,7 +1098,7 @@ static struct page *new_page(struct page *page, u=
nsigned long start, int **x)
>  	if (PageHuge(page)) {
>  		BUG_ON(!vma);
>  		return alloc_huge_page_noerr(vma, address, 1);
> -	} else if (thp_migration_supported() && PageTransHuge(page)) {
> +	} else if (PageTransHuge(page)) {
>  		struct page *thp;
> =20
>  		thp =3D alloc_hugepage_vma(GFP_TRANSHUGE, vma, address,
> diff --git a/mm/migrate.c b/mm/migrate.c
> index 4d0be47a322a..ed21642a5c1d 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -1139,6 +1139,9 @@ static ICE_noinline int unmap_and_move(new_page_t=
 get_new_page,
>  	int *result =3D NULL;
>  	struct page *newpage;
> =20
> +	if (!thp_migration_supported() && PageTransHuge(page))
> +		return -ENOMEM;
> +
>  	newpage =3D get_new_page(page, private, &result);
>  	if (!newpage)
>  		return -ENOMEM;
> @@ -1160,14 +1163,6 @@ static ICE_noinline int unmap_and_move(new_page_=
t get_new_page,
>  		goto out;
>  	}
> =20
> -	if (unlikely(PageTransHuge(page) && !PageTransHuge(newpage))) {
> -		lock_page(page);
> -		rc =3D split_huge_page(page);
> -		unlock_page(page);
> -		if (rc)
> -			goto out;
> -	}
> -
>  	rc =3D __unmap_and_move(page, newpage, force, mode);
>  	if (rc =3D=3D MIGRATEPAGE_SUCCESS)
>  		set_page_owner_migrate_reason(newpage, reason);
> @@ -1395,6 +1390,7 @@ int migrate_pages(struct list_head *from, new_pag=
e_t get_new_page,
>  		retry =3D 0;
> =20
>  		list_for_each_entry_safe(page, page2, from, lru) {
> +retry:
>  			cond_resched();
> =20
>  			if (PageHuge(page))
> @@ -1408,6 +1404,21 @@ int migrate_pages(struct list_head *from, new_pa=
ge_t get_new_page,
> =20
>  			switch(rc) {
>  			case -ENOMEM:
> +				/*
> +				 * THP migration might be unsupported or the
> +				 * allocation could've failed so we should
> +				 * retry on the same page with the THP split
> +				 * to base pages.
> +				 */
> +				if (PageTransHuge(page)) {
> +					lock_page(page);
> +					rc =3D split_huge_page_to_list(page, from);
> +					unlock_page(page);
> +					if (!rc) {
> +						list_safe_reset_next(page, page2, lru);
> +						goto retry;
> +					}
> +				}
>  				nr_failed++;
>  				goto out;
>  			case -EAGAIN:
> @@ -1470,7 +1481,7 @@ static struct page *new_page_node(struct page *p,=
 unsigned long private,
>  	if (PageHuge(p))
>  		return alloc_huge_page_node(page_hstate(compound_head(p)),
>  					pm->node);
> -	else if (thp_migration_supported() && PageTransHuge(p)) {
> +	else if (PageTransHuge(p)) {
>  		struct page *thp;
> =20
>  		thp =3D alloc_pages_node(pm->node,
> @@ -1517,8 +1528,6 @@ static int do_move_page_to_node_array(struct mm_s=
truct *mm,
> =20
>  		/* FOLL_DUMP to ignore special (like zero) pages */
>  		follflags =3D FOLL_GET | FOLL_DUMP;
> -		if (!thp_migration_supported())
> -			follflags |=3D FOLL_SPLIT;
>  		page =3D follow_page(vma, pp->addr, follflags);
> =20
>  		err =3D PTR_ERR(page);

Other than the concern of "getting migration results" and two lines of
code I mentioned above, the rest of the code looks good to me.

--=20
Best Regards,
Yan Zi


--------------enigAE95FC686FE59058D452B4EB
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iQEcBAEBCAAGBQJaKUwOAAoJEEGLLxGcTqbM91MH/1Gw9tzmmNEFGBqY+JWF7Fny
/yyQH67uh3dH5x7orhvDEI0NBKOYdc2nTj4af90zFTzXBiSS5ewIXQzpRGFdsGtP
b1WoT2M2s8nfassznParMV/QntcToB3DEdM27RPdIKS3364t2TDN187y2dfM4hwe
bD3kKPaFGgqQpFU0ZoHg7bth+Ax8zpEGhWVPSDphDDd5fHbl9AvBVSAtdBqQc7Xd
hIW3ZcA8gaP0BAYV7oNARktHbtMbItaXi6pzR9NitNEzeTsh9MWkHpFKjlpmcptZ
yDd/NonCHCCky/lYYoy+Gbq6GD92ZLXNrTVLb+I1mkBU70oOWYxzkPE8XiG63Mc=
=153F
-----END PGP SIGNATURE-----

--------------enigAE95FC686FE59058D452B4EB--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
