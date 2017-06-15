Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3C4D86B0279
	for <linux-mm@kvack.org>; Wed, 14 Jun 2017 21:42:18 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id b13so712605pgn.4
        for <linux-mm@kvack.org>; Wed, 14 Jun 2017 18:42:18 -0700 (PDT)
Received: from mail-pg0-x244.google.com (mail-pg0-x244.google.com. [2607:f8b0:400e:c05::244])
        by mx.google.com with ESMTPS id s36si542201pld.152.2017.06.14.18.42.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Jun 2017 18:42:17 -0700 (PDT)
Received: by mail-pg0-x244.google.com with SMTP id j186so99946pge.1
        for <linux-mm@kvack.org>; Wed, 14 Jun 2017 18:42:17 -0700 (PDT)
Date: Thu, 15 Jun 2017 11:41:59 +1000
From: Balbir Singh <bsingharora@gmail.com>
Subject: Re: [HMM-CDM 4/5] mm/memcontrol: support MEMORY_DEVICE_PRIVATE and
 MEMORY_DEVICE_PUBLIC
Message-ID: <20170615114159.11a1eece@firefly.ozlabs.ibm.com>
In-Reply-To: <20170614201144.9306-5-jglisse@redhat.com>
References: <20170614201144.9306-1-jglisse@redhat.com>
	<20170614201144.9306-5-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>, David Nellans <dnellans@nvidia.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, cgroups@vger.kernel.org

On Wed, 14 Jun 2017 16:11:43 -0400
J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com> wrote:

> HMM pages (private or public device pages) are ZONE_DEVICE page and
> thus need special handling when it comes to lru or refcount. This
> patch make sure that memcontrol properly handle those when it face
> them. Those pages are use like regular pages in a process address
> space either as anonymous page or as file back page. So from memcg
> point of view we want to handle them like regular page for now at
> least.
>=20
> Signed-off-by: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
> Cc: cgroups@vger.kernel.org
> ---
>  kernel/memremap.c |  2 ++
>  mm/memcontrol.c   | 58 +++++++++++++++++++++++++++++++++++++++++++++++++=
+-----
>  2 files changed, 55 insertions(+), 5 deletions(-)
>=20
> diff --git a/kernel/memremap.c b/kernel/memremap.c
> index da74775..584984c 100644
> --- a/kernel/memremap.c
> +++ b/kernel/memremap.c
> @@ -479,6 +479,8 @@ void put_zone_device_private_or_public_page(struct pa=
ge *page)
>  		__ClearPageActive(page);
>  		__ClearPageWaiters(page);
> =20
> +		mem_cgroup_uncharge(page);
> +

A zone device page could have a mem_cgroup charge if

1. The old page was charged to a cgroup and the new page from ZONE_DEVICE t=
hen
gets the charge that we need to drop here

And should not be charged

2. If the driver allowed mmap based allocation (these pages are not on LRU


Since put_zone_device_private_or_public_page() is called from release_pages=
(),
I think the assumption is that 2 is not a problem? I've not tested the mmap
bits yet.

>  		page->pgmap->page_free(page, page->pgmap->data);
>  	}
>  	else if (!count)
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index b93f5fe..171b638 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -4391,12 +4391,13 @@ enum mc_target_type {
>  	MC_TARGET_NONE =3D 0,
>  	MC_TARGET_PAGE,
>  	MC_TARGET_SWAP,
> +	MC_TARGET_DEVICE,
>  };
> =20
>  static struct page *mc_handle_present_pte(struct vm_area_struct *vma,
>  						unsigned long addr, pte_t ptent)
>  {
> -	struct page *page =3D vm_normal_page(vma, addr, ptent);
> +	struct page *page =3D _vm_normal_page(vma, addr, ptent, true);
> =20
>  	if (!page || !page_mapped(page))
>  		return NULL;
> @@ -4407,13 +4408,20 @@ static struct page *mc_handle_present_pte(struct =
vm_area_struct *vma,
>  		if (!(mc.flags & MOVE_FILE))
>  			return NULL;
>  	}
> -	if (!get_page_unless_zero(page))
> +	if (is_device_public_page(page)) {
> +		/*
> +		 * MEMORY_DEVICE_PUBLIC means ZONE_DEVICE page and which have a
> +		 * refcount of 1 when free (unlike normal page)
> +		 */
> +		if (!page_ref_add_unless(page, 1, 1))
> +			return NULL;
> +	} else if (!get_page_unless_zero(page))
>  		return NULL;
> =20
>  	return page;
>  }
> =20
> -#ifdef CONFIG_SWAP
> +#if defined(CONFIG_SWAP) || defined(CONFIG_DEVICE_PRIVATE)
>  static struct page *mc_handle_swap_pte(struct vm_area_struct *vma,
>  			pte_t ptent, swp_entry_t *entry)
>  {
> @@ -4422,6 +4430,23 @@ static struct page *mc_handle_swap_pte(struct vm_a=
rea_struct *vma,
> =20
>  	if (!(mc.flags & MOVE_ANON) || non_swap_entry(ent))
>  		return NULL;
> +
> +	/*
> +	 * Handle MEMORY_DEVICE_PRIVATE which are ZONE_DEVICE page belonging to
> +	 * a device and because they are not accessible by CPU they are store
> +	 * as special swap entry in the CPU page table.
> +	 */
> +	if (is_device_private_entry(ent)) {
> +		page =3D device_private_entry_to_page(ent);
> +		/*
> +		 * MEMORY_DEVICE_PRIVATE means ZONE_DEVICE page and which have
> +		 * a refcount of 1 when free (unlike normal page)
> +		 */
> +		if (!page_ref_add_unless(page, 1, 1))
> +			return NULL;
> +		return page;
> +	}
> +
>  	/*
>  	 * Because lookup_swap_cache() updates some statistics counter,
>  	 * we call find_get_page() with swapper_space directly.
> @@ -4582,6 +4607,8 @@ static int mem_cgroup_move_account(struct page *pag=
e,
>   *   2(MC_TARGET_SWAP): if the swap entry corresponding to this pte is a
>   *     target for charge migration. if @target is not NULL, the entry is=
 stored
>   *     in target->ent.
> + *   3(MC_TARGET_DEVICE): like MC_TARGET_PAGE  but page is MEMORY_DEVICE=
_PUBLIC
> + *     or MEMORY_DEVICE_PRIVATE (so ZONE_DEVICE page and thus not on the=
 lru).
>   *
>   * Called with pte lock held.
>   */
> @@ -4610,6 +4637,9 @@ static enum mc_target_type get_mctgt_type(struct vm=
_area_struct *vma,
>  		 */
>  		if (page->mem_cgroup =3D=3D mc.from) {
>  			ret =3D MC_TARGET_PAGE;
> +			if (is_device_private_page(page) ||
> +			    is_device_public_page(page))
> +				ret =3D MC_TARGET_DEVICE;
>  			if (target)
>  				target->page =3D page;
>  		}
> @@ -4669,6 +4699,11 @@ static int mem_cgroup_count_precharge_pte_range(pm=
d_t *pmd,
> =20
>  	ptl =3D pmd_trans_huge_lock(pmd, vma);
>  	if (ptl) {
> +		/*
> +		 * Note their can not be MC_TARGET_DEVICE for now as we do not
                        there
> +		 * support transparent huge page with MEMORY_DEVICE_PUBLIC or
> +		 * MEMORY_DEVICE_PRIVATE but this might change.

I am trying to remind myself why THP and MEMORY_DEVICE_* pages don't work w=
ell
together today, the driver could allocate a THP size set of pages and migra=
te it.
There are patches to do THP migration, not upstream yet. Could you remind me
of any other limitations?

Balbir Singh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
