Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 869FD6B0033
	for <linux-mm@kvack.org>; Wed, 18 Oct 2017 07:07:19 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id p2so3314726pfk.13
        for <linux-mm@kvack.org>; Wed, 18 Oct 2017 04:07:19 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id a91si656223pla.788.2017.10.18.04.07.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Oct 2017 04:07:18 -0700 (PDT)
Date: Wed, 18 Oct 2017 19:00:26 +0800
From: "Du, Changbin" <changbin.du@intel.com>
Subject: Re: [PATCH 1/2] mm, thp: introduce dedicated transparent huge page
 allocation interfaces
Message-ID: <20171018110026.GA4352@intel.com>
References: <1508145557-9944-1-git-send-email-changbin.du@intel.com>
 <1508145557-9944-2-git-send-email-changbin.du@intel.com>
 <20171017102052.ltc2lb6r7kloazgs@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="W/nzBZO5zC0uMSeA"
Content-Disposition: inline
In-Reply-To: <20171017102052.ltc2lb6r7kloazgs@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: changbin.du@intel.com, akpm@linux-foundation.org, corbet@lwn.net, hughd@google.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org


--W/nzBZO5zC0uMSeA
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Hocko,

On Tue, Oct 17, 2017 at 12:20:52PM +0200, Michal Hocko wrote:
> [CC Kirill]
>=20
> On Mon 16-10-17 17:19:16, changbin.du@intel.com wrote:
> > From: Changbin Du <changbin.du@intel.com>
> >=20
> > This patch introduced 4 new interfaces to allocate a prepared
> > transparent huge page.
> >   - alloc_transhuge_page_vma
> >   - alloc_transhuge_page_nodemask
> >   - alloc_transhuge_page_node
> >   - alloc_transhuge_page
> >=20
> > The aim is to remove duplicated code and simplify transparent
> > huge page allocation. These are similar to alloc_hugepage_xxx
> > which are for hugetlbfs pages. This patch does below changes:
> >   - define alloc_transhuge_page_xxx interfaces
> >   - apply them to all existing code
> >   - declare prep_transhuge_page as static since no others use it
> >   - remove alloc_hugepage_vma definition since it no longer has users
>=20
> So what exactly is the advantage of the new API? The diffstat doesn't
> sound very convincing to me.
>
The caller only need one step to allocate thp. Several LOCs removed for all=
 the
caller side with this change. So it's little more convinent.

> > Signed-off-by: Changbin Du <changbin.du@intel.com>
> > ---
> >  include/linux/gfp.h     |  4 ----
> >  include/linux/huge_mm.h | 13 ++++++++++++-
> >  include/linux/migrate.h | 14 +++++---------
> >  mm/huge_memory.c        | 50 +++++++++++++++++++++++++++++++++++++++++=
+-------
> >  mm/khugepaged.c         | 11 ++---------
> >  mm/mempolicy.c          | 10 +++-------
> >  mm/migrate.c            | 12 ++++--------
> >  mm/shmem.c              |  6 ++----
> >  8 files changed, 71 insertions(+), 49 deletions(-)
> >=20
> > diff --git a/include/linux/gfp.h b/include/linux/gfp.h
> > index f780718..855c72e 100644
> > --- a/include/linux/gfp.h
> > +++ b/include/linux/gfp.h
> > @@ -507,15 +507,11 @@ alloc_pages(gfp_t gfp_mask, unsigned int order)
> >  extern struct page *alloc_pages_vma(gfp_t gfp_mask, int order,
> >  			struct vm_area_struct *vma, unsigned long addr,
> >  			int node, bool hugepage);
> > -#define alloc_hugepage_vma(gfp_mask, vma, addr, order)	\
> > -	alloc_pages_vma(gfp_mask, order, vma, addr, numa_node_id(), true)
> >  #else
> >  #define alloc_pages(gfp_mask, order) \
> >  		alloc_pages_node(numa_node_id(), gfp_mask, order)
> >  #define alloc_pages_vma(gfp_mask, order, vma, addr, node, false)\
> >  	alloc_pages(gfp_mask, order)
> > -#define alloc_hugepage_vma(gfp_mask, vma, addr, order)	\
> > -	alloc_pages(gfp_mask, order)
> >  #endif
> >  #define alloc_page(gfp_mask) alloc_pages(gfp_mask, 0)
> >  #define alloc_page_vma(gfp_mask, vma, addr)			\
> > diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
> > index 14bc21c..1dd2c33 100644
> > --- a/include/linux/huge_mm.h
> > +++ b/include/linux/huge_mm.h
> > @@ -130,9 +130,20 @@ extern unsigned long thp_get_unmapped_area(struct =
file *filp,
> >  		unsigned long addr, unsigned long len, unsigned long pgoff,
> >  		unsigned long flags);
> > =20
> > -extern void prep_transhuge_page(struct page *page);
> >  extern void free_transhuge_page(struct page *page);
> > =20
> > +struct page *alloc_transhuge_page_vma(gfp_t gfp_mask,
> > +		struct vm_area_struct *vma, unsigned long addr);
> > +struct page *alloc_transhuge_page_nodemask(gfp_t gfp_mask,
> > +		int preferred_nid, nodemask_t *nmask);
> > +
> > +static inline struct page *alloc_transhuge_page_node(int nid, gfp_t gf=
p_mask)
> > +{
> > +	return alloc_transhuge_page_nodemask(gfp_mask, nid, NULL);
> > +}
> > +
> > +struct page *alloc_transhuge_page(gfp_t gfp_mask);
> > +
> >  bool can_split_huge_page(struct page *page, int *pextra_pins);
> >  int split_huge_page_to_list(struct page *page, struct list_head *list);
> >  static inline int split_huge_page(struct page *page)
> > diff --git a/include/linux/migrate.h b/include/linux/migrate.h
> > index 643c7ae..70a00f3 100644
> > --- a/include/linux/migrate.h
> > +++ b/include/linux/migrate.h
> > @@ -42,19 +42,15 @@ static inline struct page *new_page_nodemask(struct=
 page *page,
> >  		return alloc_huge_page_nodemask(page_hstate(compound_head(page)),
> >  				preferred_nid, nodemask);
> > =20
> > -	if (thp_migration_supported() && PageTransHuge(page)) {
> > -		order =3D HPAGE_PMD_ORDER;
> > -		gfp_mask |=3D GFP_TRANSHUGE;
> > -	}
> > -
> >  	if (PageHighMem(page) || (zone_idx(page_zone(page)) =3D=3D ZONE_MOVAB=
LE))
> >  		gfp_mask |=3D __GFP_HIGHMEM;
> > =20
> > -	new_page =3D __alloc_pages_nodemask(gfp_mask, order,
> > +	if (thp_migration_supported() && PageTransHuge(page))
> > +		return alloc_transhuge_page_nodemask(gfp_mask | GFP_TRANSHUGE,
> > +				preferred_nid, nodemask);
> > +	else
> > +		return __alloc_pages_nodemask(gfp_mask, order,
> >  				preferred_nid, nodemask);
> > -
> > -	if (new_page && PageTransHuge(page))
> > -		prep_transhuge_page(new_page);
> > =20
> >  	return new_page;
> >  }
> > diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> > index 269b5df..e267488 100644
> > --- a/mm/huge_memory.c
> > +++ b/mm/huge_memory.c
> > @@ -490,7 +490,7 @@ static inline struct list_head *page_deferred_list(=
struct page *page)
> >  	return (struct list_head *)&page[2].mapping;
> >  }
> > =20
> > -void prep_transhuge_page(struct page *page)
> > +static void prep_transhuge_page(struct page *page)
> >  {
> >  	/*
> >  	 * we use page->mapping and page->indexlru in second tail page
> > @@ -501,6 +501,45 @@ void prep_transhuge_page(struct page *page)
> >  	set_compound_page_dtor(page, TRANSHUGE_PAGE_DTOR);
> >  }
> > =20
> > +struct page *alloc_transhuge_page_vma(gfp_t gfp_mask,
> > +		struct vm_area_struct *vma, unsigned long addr)
> > +{
> > +	struct page *page;
> > +
> > +	page =3D alloc_pages_vma(gfp_mask | __GFP_COMP, HPAGE_PMD_ORDER,
> > +			       vma, addr, numa_node_id(), true);
> > +	if (unlikely(!page))
> > +		return NULL;
> > +	prep_transhuge_page(page);
> > +	return page;
> > +}
> > +
> > +struct page *alloc_transhuge_page_nodemask(gfp_t gfp_mask,
> > +		int preferred_nid, nodemask_t *nmask)
> > +{
> > +	struct page *page;
> > +
> > +	page =3D __alloc_pages_nodemask(gfp_mask | __GFP_COMP, HPAGE_PMD_ORDE=
R,
> > +				      preferred_nid, nmask);
> > +	if (unlikely(!page))
> > +		return NULL;
> > +	prep_transhuge_page(page);
> > +	return page;
> > +}
> > +
> > +struct page *alloc_transhuge_page(gfp_t gfp_mask)
> > +{
> > +	struct page *page;
> > +
> > +	VM_BUG_ON(!(gfp_mask & __GFP_COMP));
> > +
> > +	page =3D alloc_pages(gfp_mask | __GFP_COMP, HPAGE_PMD_ORDER);
> > +	if (unlikely(!page))
> > +		return NULL;
> > +	prep_transhuge_page(page);
> > +	return page;
> > +}
> > +
> >  unsigned long __thp_get_unmapped_area(struct file *filp, unsigned long=
 len,
> >  		loff_t off, unsigned long flags, unsigned long size)
> >  {
> > @@ -719,12 +758,11 @@ int do_huge_pmd_anonymous_page(struct vm_fault *v=
mf)
> >  		return ret;
> >  	}
> >  	gfp =3D alloc_hugepage_direct_gfpmask(vma);
> > -	page =3D alloc_hugepage_vma(gfp, vma, haddr, HPAGE_PMD_ORDER);
> > +	page =3D alloc_transhuge_page_vma(gfp, vma, haddr);
> >  	if (unlikely(!page)) {
> >  		count_vm_event(THP_FAULT_FALLBACK);
> >  		return VM_FAULT_FALLBACK;
> >  	}
> > -	prep_transhuge_page(page);
> >  	return __do_huge_pmd_anonymous_page(vmf, page, gfp);
> >  }
> > =20
> > @@ -1288,13 +1326,11 @@ int do_huge_pmd_wp_page(struct vm_fault *vmf, p=
md_t orig_pmd)
> >  	if (transparent_hugepage_enabled(vma) &&
> >  	    !transparent_hugepage_debug_cow()) {
> >  		huge_gfp =3D alloc_hugepage_direct_gfpmask(vma);
> > -		new_page =3D alloc_hugepage_vma(huge_gfp, vma, haddr, HPAGE_PMD_ORDE=
R);
> > +		new_page =3D alloc_transhuge_page_vma(huge_gfp, vma, haddr);
> >  	} else
> >  		new_page =3D NULL;
> > =20
> > -	if (likely(new_page)) {
> > -		prep_transhuge_page(new_page);
> > -	} else {
> > +	if (unlikely(!new_page)) {
> >  		if (!page) {
> >  			split_huge_pmd(vma, vmf->pmd, vmf->address);
> >  			ret |=3D VM_FAULT_FALLBACK;
> > diff --git a/mm/khugepaged.c b/mm/khugepaged.c
> > index c01f177..d17a694 100644
> > --- a/mm/khugepaged.c
> > +++ b/mm/khugepaged.c
> > @@ -745,14 +745,13 @@ khugepaged_alloc_page(struct page **hpage, gfp_t =
gfp, int node)
> >  {
> >  	VM_BUG_ON_PAGE(*hpage, *hpage);
> > =20
> > -	*hpage =3D __alloc_pages_node(node, gfp, HPAGE_PMD_ORDER);
> > +	*hpage =3D alloc_transhuge_page_node(node, gfp);
> >  	if (unlikely(!*hpage)) {
> >  		count_vm_event(THP_COLLAPSE_ALLOC_FAILED);
> >  		*hpage =3D ERR_PTR(-ENOMEM);
> >  		return NULL;
> >  	}
> > =20
> > -	prep_transhuge_page(*hpage);
> >  	count_vm_event(THP_COLLAPSE_ALLOC);
> >  	return *hpage;
> >  }
> > @@ -764,13 +763,7 @@ static int khugepaged_find_target_node(void)
> > =20
> >  static inline struct page *alloc_khugepaged_hugepage(void)
> >  {
> > -	struct page *page;
> > -
> > -	page =3D alloc_pages(alloc_hugepage_khugepaged_gfpmask(),
> > -			   HPAGE_PMD_ORDER);
> > -	if (page)
> > -		prep_transhuge_page(page);
> > -	return page;
> > +	return alloc_transhuge_page(alloc_hugepage_khugepaged_gfpmask());
> >  }
> > =20
> >  static struct page *khugepaged_alloc_hugepage(bool *wait)
> > diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> > index a2af6d5..aa24285 100644
> > --- a/mm/mempolicy.c
> > +++ b/mm/mempolicy.c
> > @@ -949,12 +949,10 @@ static struct page *new_node_page(struct page *pa=
ge, unsigned long node, int **x
> >  	else if (thp_migration_supported() && PageTransHuge(page)) {
> >  		struct page *thp;
> > =20
> > -		thp =3D alloc_pages_node(node,
> > -			(GFP_TRANSHUGE | __GFP_THISNODE),
> > -			HPAGE_PMD_ORDER);
> > +		thp =3D alloc_transhuge_page_node(node,
> > +			(GFP_TRANSHUGE | __GFP_THISNODE));
> >  		if (!thp)
> >  			return NULL;
> > -		prep_transhuge_page(thp);
> >  		return thp;
> >  	} else
> >  		return __alloc_pages_node(node, GFP_HIGHUSER_MOVABLE |
> > @@ -1125,11 +1123,9 @@ static struct page *new_page(struct page *page, =
unsigned long start, int **x)
> >  	} else if (thp_migration_supported() && PageTransHuge(page)) {
> >  		struct page *thp;
> > =20
> > -		thp =3D alloc_hugepage_vma(GFP_TRANSHUGE, vma, address,
> > -					 HPAGE_PMD_ORDER);
> > +		thp =3D alloc_transhuge_page_vma(GFP_TRANSHUGE, vma, address);
> >  		if (!thp)
> >  			return NULL;
> > -		prep_transhuge_page(thp);
> >  		return thp;
> >  	}
> >  	/*
> > diff --git a/mm/migrate.c b/mm/migrate.c
> > index e00814c..7f0486f 100644
> > --- a/mm/migrate.c
> > +++ b/mm/migrate.c
> > @@ -1472,12 +1472,10 @@ static struct page *new_page_node(struct page *=
p, unsigned long private,
> >  	else if (thp_migration_supported() && PageTransHuge(p)) {
> >  		struct page *thp;
> > =20
> > -		thp =3D alloc_pages_node(pm->node,
> > -			(GFP_TRANSHUGE | __GFP_THISNODE) & ~__GFP_RECLAIM,
> > -			HPAGE_PMD_ORDER);
> > +		thp =3D alloc_transhuge_page_node(pm->node,
> > +			(GFP_TRANSHUGE | __GFP_THISNODE) & ~__GFP_RECLAIM);
> >  		if (!thp)
> >  			return NULL;
> > -		prep_transhuge_page(thp);
> >  		return thp;
> >  	} else
> >  		return __alloc_pages_node(pm->node,
> > @@ -2017,12 +2015,10 @@ int migrate_misplaced_transhuge_page(struct mm_=
struct *mm,
> >  	if (numamigrate_update_ratelimit(pgdat, HPAGE_PMD_NR))
> >  		goto out_dropref;
> > =20
> > -	new_page =3D alloc_pages_node(node,
> > -		(GFP_TRANSHUGE_LIGHT | __GFP_THISNODE),
> > -		HPAGE_PMD_ORDER);
> > +	new_page =3D alloc_transhuge_page_node(node,
> > +			(GFP_TRANSHUGE_LIGHT | __GFP_THISNODE));
> >  	if (!new_page)
> >  		goto out_fail;
> > -	prep_transhuge_page(new_page);
> > =20
> >  	isolated =3D numamigrate_isolate_page(pgdat, page);
> >  	if (!isolated) {
> > diff --git a/mm/shmem.c b/mm/shmem.c
> > index 07a1d22..52468f7 100644
> > --- a/mm/shmem.c
> > +++ b/mm/shmem.c
> > @@ -1444,11 +1444,9 @@ static struct page *shmem_alloc_hugepage(gfp_t g=
fp,
> >  	rcu_read_unlock();
> > =20
> >  	shmem_pseudo_vma_init(&pvma, info, hindex);
> > -	page =3D alloc_pages_vma(gfp | __GFP_COMP | __GFP_NORETRY | __GFP_NOW=
ARN,
> > -			HPAGE_PMD_ORDER, &pvma, 0, numa_node_id(), true);
> > +	gfp |=3D __GFP_COMP | __GFP_NORETRY | __GFP_NOWARN;
> > +	page =3D alloc_transhuge_page_vma(gfp, &pvma, 0);
> >  	shmem_pseudo_vma_destroy(&pvma);
> > -	if (page)
> > -		prep_transhuge_page(page);
> >  	return page;
> >  }
> > =20
> > --=20
> > 2.7.4
> >=20
> > --
> > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > the body to majordomo@kvack.org.  For more info on Linux MM,
> > see: http://www.linux-mm.org/ .
> > Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>=20
> --=20
> Michal Hocko
> SUSE Labs

--=20
Thanks,
Changbin Du

--W/nzBZO5zC0uMSeA
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAEBAgAGBQJZ5zRKAAoJEAanuZwLnPNUT/cIAJKvD87yGe3HbMgNYvNO5xmV
SNw2SDJqvxcNLc3+UUb7aL+Tclt4r20qbwnVQp9vA03es5Zv4bAHfeN7y2g5/uxU
AbHU/nAFfZ8ma3kMdy29YQCwW7IVAMgNUcIHiLwE/pdf5hgSPQxVO1BOar1nhGjq
0866XRuzdMhu18SyoHtJrT5rFyUXKyAf9kW/GirRlSK437v57JVE+oI9lf7Hu/U7
GYjcTz8e2F7FFIFlbwgd5J3qK9m07L/7KqIcglohNSGAyU6BiyRlz+Ep4SbvWIhw
ZLk3u7tIH1GgceKIYkLOzXPktIkFqijt1FJjcx77Eivov/ITRqj5cMcKR5S0rig=
=bysx
-----END PGP SIGNATURE-----

--W/nzBZO5zC0uMSeA--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
