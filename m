Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id D18E76B02C3
	for <linux-mm@kvack.org>; Wed, 31 May 2017 00:09:16 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id e8so6728136pfl.4
        for <linux-mm@kvack.org>; Tue, 30 May 2017 21:09:16 -0700 (PDT)
Received: from mail-pf0-x243.google.com (mail-pf0-x243.google.com. [2607:f8b0:400e:c00::243])
        by mx.google.com with ESMTPS id g29si15771544pfg.174.2017.05.30.21.09.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 May 2017 21:09:15 -0700 (PDT)
Received: by mail-pf0-x243.google.com with SMTP id w69so985791pfk.1
        for <linux-mm@kvack.org>; Tue, 30 May 2017 21:09:15 -0700 (PDT)
Date: Wed, 31 May 2017 14:09:04 +1000
From: Balbir Singh <bsingharora@gmail.com>
Subject: Re: [HMM 14/15] mm/migrate: support un-addressable ZONE_DEVICE page
 in migration v2
Message-ID: <20170531140904.5c956b9a@firefly.ozlabs.ibm.com>
In-Reply-To: <20170524172024.30810-15-jglisse@redhat.com>
References: <20170524172024.30810-1-jglisse@redhat.com>
	<20170524172024.30810-15-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dan Williams <dan.j.williams@intel.com>, "Kirill A .
 Shutemov" <kirill.shutemov@linux.intel.com>, John Hubbard <jhubbard@nvidia.com>

On Wed, 24 May 2017 13:20:23 -0400
J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com> wrote:

> Allow to unmap and restore special swap entry of un-addressable
> ZONE_DEVICE memory.
>=20
> Changed since v1:
>   - s/device unaddressable/device private/
>=20
> Signed-off-by: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
> Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
>  include/linux/migrate.h |  10 +++-
>  mm/migrate.c            | 134 ++++++++++++++++++++++++++++++++++++++----=
------
>  mm/page_vma_mapped.c    |  10 ++++
>  mm/rmap.c               |  25 +++++++++
>  4 files changed, 150 insertions(+), 29 deletions(-)
>=20
> diff --git a/include/linux/migrate.h b/include/linux/migrate.h
> index 576b3f5..7dd875a 100644
> --- a/include/linux/migrate.h
> +++ b/include/linux/migrate.h
> @@ -130,12 +130,18 @@ static inline int migrate_misplaced_transhuge_page(=
struct mm_struct *mm,
> =20
>  #ifdef CONFIG_MIGRATION
> =20
> +/*
> + * Watch out for PAE architecture, which has an unsigned long, and might=
 not
> + * have enough bits to store all physical address and flags. So far we h=
ave
> + * enough room for all our flags.
> + */
>  #define MIGRATE_PFN_VALID	(1UL << 0)
>  #define MIGRATE_PFN_MIGRATE	(1UL << 1)
>  #define MIGRATE_PFN_LOCKED	(1UL << 2)
>  #define MIGRATE_PFN_WRITE	(1UL << 3)
> -#define MIGRATE_PFN_ERROR	(1UL << 4)
> -#define MIGRATE_PFN_SHIFT	5
> +#define MIGRATE_PFN_DEVICE	(1UL << 4)
> +#define MIGRATE_PFN_ERROR	(1UL << 5)
> +#define MIGRATE_PFN_SHIFT	6
> =20
>  static inline struct page *migrate_pfn_to_page(unsigned long mpfn)
>  {
> diff --git a/mm/migrate.c b/mm/migrate.c
> index 1f2bc61..9e68399 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -36,6 +36,7 @@
>  #include <linux/hugetlb.h>
>  #include <linux/hugetlb_cgroup.h>
>  #include <linux/gfp.h>
> +#include <linux/memremap.h>
>  #include <linux/balloon_compaction.h>
>  #include <linux/mmu_notifier.h>
>  #include <linux/page_idle.h>
> @@ -227,7 +228,15 @@ static bool remove_migration_pte(struct page *page, =
struct vm_area_struct *vma,
>  		if (is_write_migration_entry(entry))
>  			pte =3D maybe_mkwrite(pte, vma);
> =20
> -		flush_dcache_page(new);
> +		if (unlikely(is_zone_device_page(new)) &&
> +		    is_device_private_page(new)) {

I would expect HMM-CDM to never hit this pattern, given that
we should not be creating migration entries for CDM memory.
Is that a fair assumption?

> +			entry =3D make_device_private_entry(new, pte_write(pte));
> +			pte =3D swp_entry_to_pte(entry);
> +			if (pte_swp_soft_dirty(*pvmw.pte))
> +				pte =3D pte_mksoft_dirty(pte);
> +		} else
> +			flush_dcache_page(new);
> +
>  #ifdef CONFIG_HUGETLB_PAGE
>  		if (PageHuge(new)) {
>  			pte =3D pte_mkhuge(pte);
> @@ -2140,17 +2149,40 @@ static int migrate_vma_collect_pmd(pmd_t *pmdp,
>  		pte =3D *ptep;
>  		pfn =3D pte_pfn(pte);
> =20
> -		if (!pte_present(pte)) {
> +		if (pte_none(pte)) {
>  			mpfn =3D pfn =3D 0;
>  			goto next;
>  		}
> =20
> +		if (!pte_present(pte)) {
> +			mpfn =3D pfn =3D 0;
> +
> +			/*
> +			 * Only care about unaddressable device page special
> +			 * page table entry. Other special swap entries are not
> +			 * migratable, and we ignore regular swapped page.
> +			 */
> +			entry =3D pte_to_swp_entry(pte);
> +			if (!is_device_private_entry(entry))
> +				goto next;
> +
> +			page =3D device_private_entry_to_page(entry);
> +			mpfn =3D migrate_pfn(page_to_pfn(page))|
> +				MIGRATE_PFN_DEVICE | MIGRATE_PFN_MIGRATE;
> +			if (is_write_device_private_entry(entry))
> +				mpfn |=3D MIGRATE_PFN_WRITE;
> +		} else {
> +			page =3D vm_normal_page(migrate->vma, addr, pte);
> +			mpfn =3D migrate_pfn(pfn) | MIGRATE_PFN_MIGRATE;
> +			mpfn |=3D pte_write(pte) ? MIGRATE_PFN_WRITE : 0;
> +		}
> +
>  		/* FIXME support THP */
> -		page =3D vm_normal_page(migrate->vma, addr, pte);
>  		if (!page || !page->mapping || PageTransCompound(page)) {
>  			mpfn =3D pfn =3D 0;
>  			goto next;
>  		}
> +		pfn =3D page_to_pfn(page);
> =20
>  		/*
>  		 * By getting a reference on the page we pin it and that blocks
> @@ -2163,8 +2195,6 @@ static int migrate_vma_collect_pmd(pmd_t *pmdp,
>  		 */
>  		get_page(page);
>  		migrate->cpages++;
> -		mpfn =3D migrate_pfn(pfn) | MIGRATE_PFN_MIGRATE;
> -		mpfn |=3D pte_write(pte) ? MIGRATE_PFN_WRITE : 0;
> =20
>  		/*
>  		 * Optimize for the common case where page is only mapped once
> @@ -2195,6 +2225,7 @@ static int migrate_vma_collect_pmd(pmd_t *pmdp,
>  		}
> =20
>  next:
> +		migrate->dst[migrate->npages] =3D 0;
>  		migrate->src[migrate->npages++] =3D mpfn;
>  	}
>  	arch_leave_lazy_mmu_mode();
> @@ -2264,6 +2295,15 @@ static bool migrate_vma_check_page(struct page *pa=
ge)
>  	if (PageCompound(page))
>  		return false;
> =20
> +	/* Page from ZONE_DEVICE have one extra reference */
> +	if (is_zone_device_page(page)) {
> +		if (is_device_private_page(page)) {
> +			extra++;
> +		} else
> +			/* Other ZONE_DEVICE memory type are not supported */
> +			return false;
> +	}
> +
>  	if ((page_count(page) - extra) > page_mapcount(page))
>  		return false;
> =20
> @@ -2301,24 +2341,30 @@ static void migrate_vma_prepare(struct migrate_vm=
a *migrate)
>  			migrate->src[i] |=3D MIGRATE_PFN_LOCKED;
>  		}
> =20
> -		if (!PageLRU(page) && allow_drain) {
> -			/* Drain CPU's pagevec */
> -			lru_add_drain_all();
> -			allow_drain =3D false;
> -		}
> +		/* ZONE_DEVICE pages are not on LRU */
> +		if (!is_zone_device_page(page)) {
> +			if (!PageLRU(page) && allow_drain) {
> +				/* Drain CPU's pagevec */
> +				lru_add_drain_all();
> +				allow_drain =3D false;
> +			}
> =20
> -		if (isolate_lru_page(page)) {
> -			if (remap) {
> -				migrate->src[i] &=3D ~MIGRATE_PFN_MIGRATE;
> -				migrate->cpages--;
> -				restore++;
> -			} else {
> -				migrate->src[i] =3D 0;
> -				unlock_page(page);
> -				migrate->cpages--;
> -				put_page(page);
> +			if (isolate_lru_page(page)) {
> +				if (remap) {
> +					migrate->src[i] &=3D ~MIGRATE_PFN_MIGRATE;
> +					migrate->cpages--;
> +					restore++;
> +				} else {
> +					migrate->src[i] =3D 0;
> +					unlock_page(page);
> +					migrate->cpages--;
> +					put_page(page);
> +				}
> +				continue;
>  			}
> -			continue;
> +
> +			/* Drop the reference we took in collect */
> +			put_page(page);
>  		}
> =20
>  		if (!migrate_vma_check_page(page)) {
> @@ -2327,14 +2373,19 @@ static void migrate_vma_prepare(struct migrate_vm=
a *migrate)
>  				migrate->cpages--;
>  				restore++;
> =20
> -				get_page(page);
> -				putback_lru_page(page);
> +				if (!is_zone_device_page(page)) {
> +					get_page(page);
> +					putback_lru_page(page);
> +				}
>  			} else {
>  				migrate->src[i] =3D 0;
>  				unlock_page(page);
>  				migrate->cpages--;
> =20
> -				putback_lru_page(page);
> +				if (!is_zone_device_page(page))
> +					putback_lru_page(page);
> +				else
> +					put_page(page);
>  			}
>  		}
>  	}
> @@ -2405,7 +2456,10 @@ static void migrate_vma_unmap(struct migrate_vma *=
migrate)
>  		unlock_page(page);
>  		restore--;
> =20
> -		putback_lru_page(page);
> +		if (is_zone_device_page(page))
> +			put_page(page);
> +		else
> +			putback_lru_page(page);
>  	}
>  }
> =20
> @@ -2436,6 +2490,26 @@ static void migrate_vma_pages(struct migrate_vma *=
migrate)
> =20
>  		mapping =3D page_mapping(page);
> =20
> +		if (is_zone_device_page(newpage)) {
> +			if (is_device_private_page(newpage)) {
> +				/*
> +				 * For now only support private anonymous when
> +				 * migrating to un-addressable device memory.
> +				 */
> +				if (mapping) {
> +					migrate->src[i] &=3D ~MIGRATE_PFN_MIGRATE;
> +					continue;
> +				}
> +			} else {
> +				/*
> +				 * Other types of ZONE_DEVICE page are not
> +				 * supported.
> +				 */
> +				migrate->src[i] &=3D ~MIGRATE_PFN_MIGRATE;
> +				continue;
> +			}
> +		}
> +
>  		r =3D migrate_page(mapping, newpage, page, MIGRATE_SYNC_NO_COPY);
>  		if (r !=3D MIGRATEPAGE_SUCCESS)
>  			migrate->src[i] &=3D ~MIGRATE_PFN_MIGRATE;
> @@ -2476,11 +2550,17 @@ static void migrate_vma_finalize(struct migrate_v=
ma *migrate)
>  		unlock_page(page);
>  		migrate->cpages--;
> =20
> -		putback_lru_page(page);
> +		if (is_zone_device_page(page))
> +			put_page(page);
> +		else
> +			putback_lru_page(page);
> =20
>  		if (newpage !=3D page) {
>  			unlock_page(newpage);
> -			putback_lru_page(newpage);
> +			if (is_zone_device_page(newpage))
> +				put_page(newpage);
> +			else
> +				putback_lru_page(newpage);
>  		}
>  	}
>  }
> diff --git a/mm/page_vma_mapped.c b/mm/page_vma_mapped.c
> index de9c40d..f95765c 100644
> --- a/mm/page_vma_mapped.c
> +++ b/mm/page_vma_mapped.c
> @@ -48,6 +48,7 @@ static bool check_pte(struct page_vma_mapped_walk *pvmw)
>  		if (!is_swap_pte(*pvmw->pte))
>  			return false;
>  		entry =3D pte_to_swp_entry(*pvmw->pte);
> +
>  		if (!is_migration_entry(entry))
>  			return false;
>  		if (migration_entry_to_page(entry) - pvmw->page >=3D
> @@ -60,6 +61,15 @@ static bool check_pte(struct page_vma_mapped_walk *pvm=
w)
>  		WARN_ON_ONCE(1);
>  #endif
>  	} else {
> +		if (is_swap_pte(*pvmw->pte)) {
> +			swp_entry_t entry;
> +
> +			entry =3D pte_to_swp_entry(*pvmw->pte);
> +			if (is_device_private_entry(entry) &&
> +			    device_private_entry_to_page(entry) =3D=3D pvmw->page)
> +				return true;
> +		}
> +
>  		if (!pte_present(*pvmw->pte))
>  			return false;
> =20
> diff --git a/mm/rmap.c b/mm/rmap.c
> index d405f0e..515cea6 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -63,6 +63,7 @@
>  #include <linux/hugetlb.h>
>  #include <linux/backing-dev.h>
>  #include <linux/page_idle.h>
> +#include <linux/memremap.h>
> =20
>  #include <asm/tlbflush.h>
> =20
> @@ -1308,6 +1309,10 @@ static bool try_to_unmap_one(struct page *page, st=
ruct vm_area_struct *vma,
>  	if ((flags & TTU_MUNLOCK) && !(vma->vm_flags & VM_LOCKED))
>  		return true;
> =20
> +	if (IS_ENABLED(CONFIG_MIGRATION) && (flags & TTU_MIGRATION) &&
> +	    is_zone_device_page(page) && !is_device_private_page(page))
> +		return true;
> +

I wonder how CDM would ever work with this?

>  	if (flags & TTU_SPLIT_HUGE_PMD) {
>  		split_huge_pmd_address(vma, address,
>  				flags & TTU_MIGRATION, page);
> @@ -1343,6 +1348,26 @@ static bool try_to_unmap_one(struct page *page, st=
ruct vm_area_struct *vma,
>  		subpage =3D page - page_to_pfn(page) + pte_pfn(*pvmw.pte);
>  		address =3D pvmw.address;
> =20
> +		if (IS_ENABLED(CONFIG_MIGRATION) &&
> +		    (flags & TTU_MIGRATION) &&
> +		    is_zone_device_page(page)) {
> +			swp_entry_t entry;
> +			pte_t swp_pte;
> +
> +			pteval =3D ptep_get_and_clear(mm, address, pvmw.pte);
> +
> +			/*
> +			 * Store the pfn of the page in a special migration
> +			 * pte. do_swap_page() will wait until the migration
> +			 * pte is removed and then restart fault handling.
> +			 */
> +			entry =3D make_migration_entry(page, 0);
> +			swp_pte =3D swp_entry_to_pte(entry);
> +			if (pte_soft_dirty(pteval))
> +				swp_pte =3D pte_swp_mksoft_dirty(swp_pte);
> +			set_pte_at(mm, address, pvmw.pte, swp_pte);
> +			goto discard;
> +		}
> =20
>  		if (!(flags & TTU_IGNORE_ACCESS)) {
>  			if (ptep_clear_flush_young_notify(vma, address,


Balbir Singh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
