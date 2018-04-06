Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4DF986B0003
	for <linux-mm@kvack.org>; Fri,  6 Apr 2018 01:15:30 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id v137-v6so15433821oie.11
        for <linux-mm@kvack.org>; Thu, 05 Apr 2018 22:15:30 -0700 (PDT)
Received: from tyo162.gate.nec.co.jp (tyo162.gate.nec.co.jp. [114.179.232.162])
        by mx.google.com with ESMTPS id w2-v6si2675273otg.433.2018.04.05.22.15.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Apr 2018 22:15:29 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH] mm: shmem: enable thp migration (Re: [PATCH v1] mm:
 consider non-anonymous thp as unmovable page)
Date: Fri, 6 Apr 2018 05:14:53 +0000
Message-ID: <20180406051452.GB23467@hori1.linux.bs1.fc.nec.co.jp>
References: <20180403083451.GG5501@dhcp22.suse.cz>
 <20180403105411.hknofkbn6rzs26oz@node.shutemov.name>
 <20180405085927.GC6312@dhcp22.suse.cz>
 <20180405122838.6a6b35psizem4tcy@node.shutemov.name>
 <20180405124830.GJ6312@dhcp22.suse.cz>
 <20180405134045.7axuun6d7ufobzj4@node.shutemov.name>
 <20180405150547.GN6312@dhcp22.suse.cz>
 <20180405155551.wchleyaf4rxooj6m@node.shutemov.name>
 <20180405160317.GP6312@dhcp22.suse.cz>
 <20180406030706.GA2434@hori1.linux.bs1.fc.nec.co.jp>
In-Reply-To: <20180406030706.GA2434@hori1.linux.bs1.fc.nec.co.jp>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <4B18407D8E0EC54F85B336EEEC256530@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Zi Yan <zi.yan@sent.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Fri, Apr 06, 2018 at 03:07:11AM +0000, Horiguchi Naoya(=1B$BKY8}=1B(B =
=1B$BD>Li=1B(B) wrote:
...
> -----
> From e31ec037701d1cc76b26226e4b66d8c783d40889 Mon Sep 17 00:00:00 2001
> From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Date: Fri, 6 Apr 2018 10:58:35 +0900
> Subject: [PATCH] mm: enable thp migration for shmem thp
>=20
> My testing for the latest kernel supporting thp migration showed an
> infinite loop in offlining the memory block that is filled with shmem
> thps.  We can get out of the loop with a signal, but kernel should
> return with failure in this case.
>=20
> What happens in the loop is that scan_movable_pages() repeats returning
> the same pfn without any progress. That's because page migration always
> fails for shmem thps.
>=20
> In memory offline code, memory blocks containing unmovable pages should
> be prevented from being offline targets by has_unmovable_pages() inside
> start_isolate_page_range(). So it's possible to change migratability
> for non-anonymous thps to avoid the issue, but it introduces more complex
> and thp-specific handling in migration code, so it might not good.
>=20
> So this patch is suggesting to fix the issue by enabling thp migration
> for shmem thp. Both of anon/shmem thp are migratable so we don't need
> precheck about the type of thps.
>=20
> Fixes: commit 72b39cfc4d75 ("mm, memory_hotplug: do not fail offlining to=
o early")
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: stable@vger.kernel.org # v4.15+

... oh, I don't think this is suitable for stable.
Michal's fix in another email can come first with "CC: stable",
then this one.
Anyway I want to get some feedback on the change of this patch.

Thanks,
Naoya Horiguchi

> ---
>  mm/huge_memory.c |  5 ++++-
>  mm/migrate.c     | 19 ++++++++++++++++---
>  mm/rmap.c        |  3 ---
>  3 files changed, 20 insertions(+), 7 deletions(-)
>=20
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 2aff58624886..933c1bbd3464 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -2926,7 +2926,10 @@ void remove_migration_pmd(struct page_vma_mapped_w=
alk *pvmw, struct page *new)
>  		pmde =3D maybe_pmd_mkwrite(pmde, vma);
> =20
>  	flush_cache_range(vma, mmun_start, mmun_start + HPAGE_PMD_SIZE);
> -	page_add_anon_rmap(new, vma, mmun_start, true);
> +	if (PageAnon(new))
> +		page_add_anon_rmap(new, vma, mmun_start, true);
> +	else
> +		page_add_file_rmap(new, true);
>  	set_pmd_at(mm, mmun_start, pvmw->pmd, pmde);
>  	if (vma->vm_flags & VM_LOCKED)
>  		mlock_vma_page(new);
> diff --git a/mm/migrate.c b/mm/migrate.c
> index bdef905b1737..f92dd9f50981 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -472,7 +472,7 @@ int migrate_page_move_mapping(struct address_space *m=
apping,
>  	pslot =3D radix_tree_lookup_slot(&mapping->i_pages,
>   					page_index(page));
> =20
> -	expected_count +=3D 1 + page_has_private(page);
> +	expected_count +=3D hpage_nr_pages(page) + page_has_private(page);
>  	if (page_count(page) !=3D expected_count ||
>  		radix_tree_deref_slot_protected(pslot,
>  					&mapping->i_pages.xa_lock) !=3D page) {
> @@ -505,7 +505,7 @@ int migrate_page_move_mapping(struct address_space *m=
apping,
>  	 */
>  	newpage->index =3D page->index;
>  	newpage->mapping =3D page->mapping;
> -	get_page(newpage);	/* add cache reference */
> +	page_ref_add(newpage, hpage_nr_pages(page)); /* add cache reference */
>  	if (PageSwapBacked(page)) {
>  		__SetPageSwapBacked(newpage);
>  		if (PageSwapCache(page)) {
> @@ -524,13 +524,26 @@ int migrate_page_move_mapping(struct address_space =
*mapping,
>  	}
> =20
>  	radix_tree_replace_slot(&mapping->i_pages, pslot, newpage);
> +	if (PageTransHuge(page)) {
> +		int i;
> +		int index =3D page_index(page);
> +
> +		for (i =3D 0; i < HPAGE_PMD_NR; i++) {
> +			pslot =3D radix_tree_lookup_slot(&mapping->i_pages,
> +						       index + i);
> +			radix_tree_replace_slot(&mapping->i_pages, pslot,
> +						newpage + i);
> +		}
> +	} else {
> +		radix_tree_replace_slot(&mapping->i_pages, pslot, newpage);
> +	}
> =20
>  	/*
>  	 * Drop cache reference from old page by unfreezing
>  	 * to one less reference.
>  	 * We know this isn't the last reference.
>  	 */
> -	page_ref_unfreeze(page, expected_count - 1);
> +	page_ref_unfreeze(page, expected_count - hpage_nr_pages(page));
> =20
>  	xa_unlock(&mapping->i_pages);
>  	/* Leave irq disabled to prevent preemption while updating stats */
> diff --git a/mm/rmap.c b/mm/rmap.c
> index f0dd4e4565bc..8d5337fed37b 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -1374,9 +1374,6 @@ static bool try_to_unmap_one(struct page *page, str=
uct vm_area_struct *vma,
>  		if (!pvmw.pte && (flags & TTU_MIGRATION)) {
>  			VM_BUG_ON_PAGE(PageHuge(page) || !PageTransCompound(page), page);
> =20
> -			if (!PageAnon(page))
> -				continue;
> -
>  			set_pmd_migration_entry(&pvmw, page);
>  			continue;
>  		}
> --=20
> 2.7.4
> =
