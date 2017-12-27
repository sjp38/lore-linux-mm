Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id C5F316B0033
	for <linux-mm@kvack.org>; Tue, 26 Dec 2017 21:12:46 -0500 (EST)
Received: by mail-pl0-f72.google.com with SMTP id d3so20813142plj.22
        for <linux-mm@kvack.org>; Tue, 26 Dec 2017 18:12:46 -0800 (PST)
Received: from NAM03-BY2-obe.outbound.protection.outlook.com (mail-by2nam03on0102.outbound.protection.outlook.com. [104.47.42.102])
        by mx.google.com with ESMTPS id i187si14885416pgc.532.2017.12.26.18.12.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 26 Dec 2017 18:12:45 -0800 (PST)
From: "Zi Yan" <zi.yan@cs.rutgers.edu>
Subject: Re: [RFC PATCH 2/3] mm, migrate: remove reason argument from
 new_page_t
Date: Tue, 26 Dec 2017 21:12:38 -0500
Message-ID: <5881ED15-2645-4D62-B558-9007DA9DE3D5@cs.rutgers.edu>
In-Reply-To: <20171208161559.27313-3-mhocko@kernel.org>
References: <20171207143401.GK20234@dhcp22.suse.cz>
 <20171208161559.27313-1-mhocko@kernel.org>
 <20171208161559.27313-3-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: multipart/signed;
 boundary="=_MailMate_96ABA5D6-39FB-486D-B617-DA87E049D04B_=";
 micalg=pgp-sha512; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Andrea Reale <ar@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

This is an OpenPGP/MIME signed message (RFC 3156 and 4880).

--=_MailMate_96ABA5D6-39FB-486D-B617-DA87E049D04B_=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 8 Dec 2017, at 11:15, Michal Hocko wrote:

> From: Michal Hocko <mhocko@suse.com>
>
> No allocation callback is using this argument anymore. new_page_node
> used to use this parameter to convey node_id resp. migration error
> up to move_pages code (do_move_page_to_node_array). The error status
> never made it into the final status field and we have a better way
> to communicate node id to the status field now. All other allocation
> callbacks simply ignored the argument so we can drop it finally.
>
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
>  include/linux/migrate.h        |  3 +--
>  include/linux/page-isolation.h |  3 +--
>  mm/compaction.c                |  3 +--
>  mm/internal.h                  |  2 +-
>  mm/memory_hotplug.c            |  3 +--
>  mm/mempolicy.c                 |  6 +++---
>  mm/migrate.c                   | 19 ++-----------------
>  mm/page_isolation.c            |  3 +--
>  8 files changed, 11 insertions(+), 31 deletions(-)
>
> diff --git a/include/linux/migrate.h b/include/linux/migrate.h
> index a2246cf670ba..e5d99ade2319 100644
> --- a/include/linux/migrate.h
> +++ b/include/linux/migrate.h
> @@ -7,8 +7,7 @@
>  #include <linux/migrate_mode.h>
>  #include <linux/hugetlb.h>
>
> -typedef struct page *new_page_t(struct page *page, unsigned long priva=
te,
> -				int **reason);
> +typedef struct page *new_page_t(struct page *page, unsigned long priva=
te);
>  typedef void free_page_t(struct page *page, unsigned long private);
>
>  /*
> diff --git a/include/linux/page-isolation.h b/include/linux/page-isolat=
ion.h
> index cdad58bbfd8b..4ae347cbc36d 100644
> --- a/include/linux/page-isolation.h
> +++ b/include/linux/page-isolation.h
> @@ -63,7 +63,6 @@ undo_isolate_page_range(unsigned long start_pfn, unsi=
gned long end_pfn,
>  int test_pages_isolated(unsigned long start_pfn, unsigned long end_pfn=
,
>  			bool skip_hwpoisoned_pages);
>
> -struct page *alloc_migrate_target(struct page *page, unsigned long pri=
vate,
> -				int **resultp);
> +struct page *alloc_migrate_target(struct page *page, unsigned long pri=
vate);
>
>  #endif
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 10cd757f1006..692d21d63391 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -1165,8 +1165,7 @@ static void isolate_freepages(struct compact_cont=
rol *cc)
>   * from the isolated freelists in the block we are migrating to.
>   */
>  static struct page *compaction_alloc(struct page *migratepage,
> -					unsigned long data,
> -					int **result)
> +					unsigned long data)
>  {
>  	struct compact_control *cc =3D (struct compact_control *)data;
>  	struct page *freepage;
> diff --git a/mm/internal.h b/mm/internal.h
> index 1a1bb5d59c15..502d14189794 100644
> --- a/mm/internal.h
> +++ b/mm/internal.h
> @@ -538,5 +538,5 @@ static inline bool is_migrate_highatomic_page(struc=
t page *page)
>  }
>
>  void setup_zone_pageset(struct zone *zone);
> -extern struct page *alloc_new_node_page(struct page *page, unsigned lo=
ng node, int **x);
> +extern struct page *alloc_new_node_page(struct page *page, unsigned lo=
ng node);
>  #endif	/* __MM_INTERNAL_H */
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index d0856ab2f28d..d865623edee7 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -1347,8 +1347,7 @@ static unsigned long scan_movable_pages(unsigned =
long start, unsigned long end)
>  	return 0;
>  }
>
> -static struct page *new_node_page(struct page *page, unsigned long pri=
vate,
> -		int **result)
> +static struct page *new_node_page(struct page *page, unsigned long pri=
vate)
>  {
>  	int nid =3D page_to_nid(page);
>  	nodemask_t nmask =3D node_states[N_MEMORY];
> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> index 66c9c79b21be..4d849d3098e5 100644
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -943,7 +943,7 @@ static void migrate_page_add(struct page *page, str=
uct list_head *pagelist,
>  }
>
>  /* page allocation callback for NUMA node migration */
> -struct page *alloc_new_node_page(struct page *page, unsigned long node=
, int **x)
> +struct page *alloc_new_node_page(struct page *page, unsigned long node=
)
>  {
>  	if (PageHuge(page))
>  		return alloc_huge_page_node(page_hstate(compound_head(page)),
> @@ -1108,7 +1108,7 @@ int do_migrate_pages(struct mm_struct *mm, const =
nodemask_t *from,
>   * list of pages handed to migrate_pages()--which is how we get here--=

>   * is in virtual address order.
>   */
> -static struct page *new_page(struct page *page, unsigned long start, i=
nt **x)
> +static struct page *new_page(struct page *page, unsigned long start)
>  {
>  	struct vm_area_struct *vma;
>  	unsigned long uninitialized_var(address);
> @@ -1153,7 +1153,7 @@ int do_migrate_pages(struct mm_struct *mm, const =
nodemask_t *from,
>  	return -ENOSYS;
>  }
>
> -static struct page *new_page(struct page *page, unsigned long start, i=
nt **x)
> +static struct page *new_page(struct page *page, unsigned long start)
>  {
>  	return NULL;
>  }
> diff --git a/mm/migrate.c b/mm/migrate.c
> index 9d7252ea2acd..f9235f0155a4 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -1136,10 +1136,9 @@ static ICE_noinline int unmap_and_move(new_page_=
t get_new_page,
>  				   enum migrate_reason reason)
>  {
>  	int rc =3D MIGRATEPAGE_SUCCESS;
> -	int *result =3D NULL;
>  	struct page *newpage;
>
> -	newpage =3D get_new_page(page, private, &result);
> +	newpage =3D get_new_page(page, private);
>  	if (!newpage)
>  		return -ENOMEM;
>
> @@ -1230,12 +1229,6 @@ static ICE_noinline int unmap_and_move(new_page_=
t get_new_page,
>  			put_page(newpage);
>  	}
>
> -	if (result) {
> -		if (rc)
> -			*result =3D rc;
> -		else
> -			*result =3D page_to_nid(newpage);
> -	}
>  	return rc;
>  }
>
> @@ -1263,7 +1256,6 @@ static int unmap_and_move_huge_page(new_page_t ge=
t_new_page,
>  				enum migrate_mode mode, int reason)
>  {
>  	int rc =3D -EAGAIN;
> -	int *result =3D NULL;
>  	int page_was_mapped =3D 0;
>  	struct page *new_hpage;
>  	struct anon_vma *anon_vma =3D NULL;
> @@ -1280,7 +1272,7 @@ static int unmap_and_move_huge_page(new_page_t ge=
t_new_page,
>  		return -ENOSYS;
>  	}
>
> -	new_hpage =3D get_new_page(hpage, private, &result);
> +	new_hpage =3D get_new_page(hpage, private);
>  	if (!new_hpage)
>  		return -ENOMEM;
>
> @@ -1345,12 +1337,6 @@ static int unmap_and_move_huge_page(new_page_t g=
et_new_page,
>  	else
>  		putback_active_hugepage(new_hpage);
>
> -	if (result) {
> -		if (rc)
> -			*result =3D rc;
> -		else
> -			*result =3D page_to_nid(new_hpage);
> -	}
>  	return rc;
>  }
>
> @@ -1622,7 +1608,6 @@ static int do_pages_move(struct mm_struct *mm, no=
demask_t task_nodes,
>  		}
>  		chunk_node =3D NUMA_NO_NODE;
>  	}
> -	err =3D 0;

This line can be merged into Patch 1. Or did I miss anything?


>  out_flush:
>  	/* Make sure we do not overwrite the existing error */
>  	err1 =3D do_move_pages_to_node(mm, &pagelist, chunk_node);
> diff --git a/mm/page_isolation.c b/mm/page_isolation.c
> index 165ed8117bd1..53d801235e22 100644
> --- a/mm/page_isolation.c
> +++ b/mm/page_isolation.c
> @@ -293,8 +293,7 @@ int test_pages_isolated(unsigned long start_pfn, un=
signed long end_pfn,
>  	return pfn < end_pfn ? -EBUSY : 0;
>  }
>
> -struct page *alloc_migrate_target(struct page *page, unsigned long pri=
vate,
> -				  int **resultp)
> +struct page *alloc_migrate_target(struct page *page, unsigned long pri=
vate)
>  {
>  	return new_page_nodemask(page, numa_node_id(), &node_states[N_MEMORY]=
);
>  }
> -- =

> 2.15.0

Everything else looks good to me.

Reviewed-by: Zi Yan <zi.yan@cs.rutgers.edu>

=E2=80=94
Best Regards,
Yan Zi

--=_MailMate_96ABA5D6-39FB-486D-B617-DA87E049D04B_=
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename=signature.asc
Content-Type: application/pgp-signature; name=signature.asc

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - https://gpgtools.org

iQFKBAEBCgA0FiEEOXBxLIohamfZUwd5QYsvEZxOpswFAlpDAZYWHHppLnlhbkBj
cy5ydXRnZXJzLmVkdQAKCRBBiy8RnE6mzMdHCAC71ag0paIZocpuWqhgYNzczbow
UZZvmhjCKGtQ7XeJZR35BeOix9iyF/qf4qV6abU48k/kqayDD7letJNRbrSmgqdI
1l44M7kFz5Shk5+xJ5StEDMig0J8dTwYiQDoawnAqBB9wbL2DMdZdRsnutAE6Yys
HMC4aBghPcfAkmkM7RqJewMtIQgiRdhTeNKw4F0oyXHgMJ2Y/Ca3hl0BEeCjXOwL
N2ORzHhoQZFeD+V7etCZO7ndsoVYI+fvzKikn9bTtgQNRG9WSloo5dixcnTD+I1T
d74vuY6npTux0cqufxxTeyz8aKzPGiOYqNgC28VtQv6csQZwCDAhluTyHJZa
=Id7g
-----END PGP SIGNATURE-----

--=_MailMate_96ABA5D6-39FB-486D-B617-DA87E049D04B_=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
