Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 577496B0033
	for <linux-mm@kvack.org>; Tue, 26 Dec 2017 21:19:47 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id f64so26497387pfd.6
        for <linux-mm@kvack.org>; Tue, 26 Dec 2017 18:19:47 -0800 (PST)
Received: from NAM01-SN1-obe.outbound.protection.outlook.com (mail-sn1nam01on0091.outbound.protection.outlook.com. [104.47.32.91])
        by mx.google.com with ESMTPS id k136si14237208pgc.618.2017.12.26.18.19.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 26 Dec 2017 18:19:45 -0800 (PST)
From: "Zi Yan" <zi.yan@cs.rutgers.edu>
Subject: Re: [RFC PATCH 3/3] mm: unclutter THP migration
Date: Tue, 26 Dec 2017 21:19:35 -0500
Message-ID: <AEE005DE-5103-4BCC-BAAB-9E126173AB62@cs.rutgers.edu>
In-Reply-To: <20171208161559.27313-4-mhocko@kernel.org>
References: <20171207143401.GK20234@dhcp22.suse.cz>
 <20171208161559.27313-1-mhocko@kernel.org>
 <20171208161559.27313-4-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: multipart/signed;
 boundary="=_MailMate_47AE1533-2DE1-41E6-8A85-27860D2A510C_=";
 micalg=pgp-sha512; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Andrea Reale <ar@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

This is an OpenPGP/MIME signed message (RFC 3156 and 4880).

--=_MailMate_47AE1533-2DE1-41E6-8A85-27860D2A510C_=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 8 Dec 2017, at 11:15, Michal Hocko wrote:

> From: Michal Hocko <mhocko@suse.com>
>
> THP migration is hacked into the generic migration with rather
> surprising semantic. The migration allocation callback is supposed to
> check whether the THP can be migrated at once and if that is not the
> case then it allocates a simple page to migrate. unmap_and_move then
> fixes that up by spliting the THP into small pages while moving the
> head page to the newly allocated order-0 page. Remaning pages are moved=

> to the LRU list by split_huge_page. The same happens if the THP
> allocation fails. This is really ugly and error prone [1].
>
> I also believe that split_huge_page to the LRU lists is inherently
> wrong because all tail pages are not migrated. Some callers will just
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
>
> This patch tries to unclutter the situation by moving the special THP
> handling up to the migrate_pages layer where it actually belongs. We
> simply split the THP page into the existing list if unmap_and_move fail=
s
> with ENOMEM and retry. So we will _always_ migrate all THP subpages and=

> specific migrate_pages users do not have to deal with this case in a
> special way.
>
> [1] https://na01.safelinks.protection.outlook.com/?url=3Dhttp%3A%2F%2Fl=
kml.kernel.org%2Fr%2F20171121021855.50525-1-zi.yan%40sent.com&data=3D02%7=
C01%7Czi.yan%40cs.rutgers.edu%7Cfbb3ed29196a430d9c7808d53e5703cc%7Cb92d2b=
234d35447093ff69aca6632ffe%7C1%7C0%7C636483465807198257&sdata=3D1jHMT9Nsy=
fc7xiMpjy05vYHrY9DCV4Z9LlOSsaJFdBY%3D&reserved=3D0
>
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
>  include/linux/migrate.h |  4 ++--
>  mm/huge_memory.c        |  6 ++++++
>  mm/memory_hotplug.c     |  2 +-
>  mm/mempolicy.c          | 31 +++----------------------------
>  mm/migrate.c            | 29 +++++++++++++++++++----------
>  5 files changed, 31 insertions(+), 41 deletions(-)
>
> diff --git a/include/linux/migrate.h b/include/linux/migrate.h
> index e5d99ade2319..0c6fe904bc97 100644
> --- a/include/linux/migrate.h
> +++ b/include/linux/migrate.h
> @@ -42,9 +42,9 @@ static inline struct page *new_page_nodemask(struct p=
age *page,
>  		return alloc_huge_page_nodemask(page_hstate(compound_head(page)),
>  				preferred_nid, nodemask);
>
> -	if (thp_migration_supported() && PageTransHuge(page)) {
> -		order =3D HPAGE_PMD_ORDER;
> +	if (PageTransHuge(page)) {
>  		gfp_mask |=3D GFP_TRANSHUGE;
> +		order =3D HPAGE_PMD_ORDER;
>  	}
>
>  	if (PageHighMem(page) || (zone_idx(page_zone(page)) =3D=3D ZONE_MOVAB=
LE))
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 7544ce4ef4dc..8865906c248c 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -2425,6 +2425,12 @@ static void __split_huge_page_tail(struct page *=
head, int tail,
>
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
>
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index d865623edee7..442e63a2cf72 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -1390,7 +1390,7 @@ do_migrate_range(unsigned long start_pfn, unsigne=
d long end_pfn)
>  			if (isolate_huge_page(page, &source))
>  				move_pages -=3D 1 << compound_order(head);
>  			continue;
> -		} else if (thp_migration_supported() && PageTransHuge(page))
> +		} else if (PageTransHuge(page))
>  			pfn =3D page_to_pfn(compound_head(page))
>  				+ hpage_nr_pages(page) - 1;
>
> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> index 4d849d3098e5..b6f4fcf9df64 100644
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
> @@ -495,7 +486,7 @@ static int queue_pages_pte_range(pmd_t *pmd, unsign=
ed long addr,
>
>  	if (pmd_trans_unstable(pmd))
>  		return 0;
> -retry:
> +
>  	pte =3D pte_offset_map_lock(walk->mm, pmd, addr, &ptl);
>  	for (; addr !=3D end; pte++, addr +=3D PAGE_SIZE) {
>  		if (!pte_present(*pte))
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
> @@ -948,7 +923,7 @@ struct page *alloc_new_node_page(struct page *page,=
 unsigned long node)
>  	if (PageHuge(page))
>  		return alloc_huge_page_node(page_hstate(compound_head(page)),
>  					node);
> -	else if (thp_migration_supported() && PageTransHuge(page)) {
> +	else if (PageTransHuge(page)) {
>  		struct page *thp;
>
>  		thp =3D alloc_pages_node(node,
> @@ -1124,7 +1099,7 @@ static struct page *new_page(struct page *page, u=
nsigned long start)
>  	if (PageHuge(page)) {
>  		BUG_ON(!vma);
>  		return alloc_huge_page_noerr(vma, address, 1);
> -	} else if (thp_migration_supported() && PageTransHuge(page)) {
> +	} else if (PageTransHuge(page)) {
>  		struct page *thp;
>
>  		thp =3D alloc_hugepage_vma(GFP_TRANSHUGE, vma, address,
> diff --git a/mm/migrate.c b/mm/migrate.c
> index f9235f0155a4..dc5df5fe5c82 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -1138,6 +1138,9 @@ static ICE_noinline int unmap_and_move(new_page_t=
 get_new_page,
>  	int rc =3D MIGRATEPAGE_SUCCESS;
>  	struct page *newpage;
>
> +	if (!thp_migration_supported() && PageTransHuge(page))
> +		return -ENOMEM;
> +
>  	newpage =3D get_new_page(page, private);
>  	if (!newpage)
>  		return -ENOMEM;
> @@ -1159,14 +1162,6 @@ static ICE_noinline int unmap_and_move(new_page_=
t get_new_page,
>  		goto out;
>  	}
>
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
> @@ -1381,6 +1376,7 @@ int migrate_pages(struct list_head *from, new_pag=
e_t get_new_page,
>  		retry =3D 0;
>
>  		list_for_each_entry_safe(page, page2, from, lru) {
> +retry:
>  			cond_resched();
>
>  			if (PageHuge(page))
> @@ -1394,6 +1390,21 @@ int migrate_pages(struct list_head *from, new_pa=
ge_t get_new_page,
>
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

The hunk splits the THP and adds all tail pages at the end of the list =E2=
=80=9Cfrom=E2=80=9D.
Why do we need =E2=80=9Clist_safe_reset_next(page, page2, lru);=E2=80=9D =
here, when page2 is not changed here?

And it seems a little bit strange to only re-migrate the head page, then =
come back to all tail
pages after migrating the rest of pages in the list =E2=80=9Cfrom=E2=80=9D=
=2E Is it better to split the THP into
a list other than =E2=80=9Cfrom=E2=80=9D and insert the list after =E2=80=
=9Cpage=E2=80=9D, then retry from the split =E2=80=9Cpage=E2=80=9D?
Thus, we attempt to migrate all sub pages of the THP after it is split.


>  				nr_failed++;
>  				goto out;
>  			case -EAGAIN:
> @@ -1480,8 +1491,6 @@ static int add_page_for_migration(struct mm_struc=
t *mm, unsigned long addr,
>
>  	/* FOLL_DUMP to ignore special (like zero) pages */
>  	follflags =3D FOLL_GET | FOLL_DUMP;
> -	if (!thp_migration_supported())
> -		follflags |=3D FOLL_SPLIT;
>  	page =3D follow_page(vma, addr, follflags);
>
>  	err =3D PTR_ERR(page);
> -- =

> 2.15.0


=E2=80=94
Best Regards,
Yan Zi

--=_MailMate_47AE1533-2DE1-41E6-8A85-27860D2A510C_=
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename=signature.asc
Content-Type: application/pgp-signature; name=signature.asc

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - https://gpgtools.org

iQFKBAEBCgA0FiEEOXBxLIohamfZUwd5QYsvEZxOpswFAlpDAzgWHHppLnlhbkBj
cy5ydXRnZXJzLmVkdQAKCRBBiy8RnE6mzC2TCACaBlfdAH0y4fOd8pSFOSHGbcH1
iaUR2ZJMIuAgkf9nPYEOeSFk9IrwrLpxDhU2FoUaR1KZmUh+F/nrEMQTKNxRjkqz
diaRosC+xhZ21WsLTp6i1jjBWLlh2aHkulXwjXhrEPCFQRiUrI/Mwd6cZs8xuI7e
UyDtGk8WR2Esaou0K7KLQX+pJ5RW6IVta59BAw6KTdQqqvYB5zSEsmTmeLuJZZou
tuZvEAk9+R7FejCY7RKOrgECu5F4FLiYg0Og8z1fXduT4fRbDVk6JbW33vNPFTh3
bGHwRW0YZO/ucNOY9bQlXecOgLEndc15/kFsprWgJNE2pafI3ytCQYtYhV18
=0LT1
-----END PGP SIGNATURE-----

--=_MailMate_47AE1533-2DE1-41E6-8A85-27860D2A510C_=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
