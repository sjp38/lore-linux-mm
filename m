Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4A0D46B0033
	for <linux-mm@kvack.org>; Wed, 18 Oct 2017 23:04:40 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id z11so4709825pfk.23
        for <linux-mm@kvack.org>; Wed, 18 Oct 2017 20:04:40 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f4sor857611plm.6.2017.10.18.20.04.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 18 Oct 2017 20:04:38 -0700 (PDT)
Date: Thu, 19 Oct 2017 14:04:26 +1100
From: Balbir Singh <bsingharora@gmail.com>
Subject: Re: [PATCH 1/2] mm/mmu_notifier: avoid double notification when it
 is useless v2
Message-ID: <20171019140426.21f51957@MiWiFi-R3-srv>
In-Reply-To: <20171017031003.7481-2-jglisse@redhat.com>
References: <20171017031003.7481-1-jglisse@redhat.com>
	<20171017031003.7481-2-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jglisse@redhat.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, Nadav Amit <nadav.amit@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Joerg Roedel <jroedel@suse.de>, Suravee Suthikulpanit <suravee.suthikulpanit@amd.com>, David Woodhouse <dwmw2@infradead.org>, Alistair Popple <alistair@popple.id.au>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Stephen Rothwell <sfr@canb.auug.org.au>, Andrew Donnellan <andrew.donnellan@au1.ibm.com>, iommu@lists.linux-foundation.org, linuxppc-dev@lists.ozlabs.org, linux-next@vger.kernel.org

On Mon, 16 Oct 2017 23:10:02 -0400
jglisse@redhat.com wrote:

> From: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
>=20
> +		/*
> +		 * No need to call mmu_notifier_invalidate_range() as we are
> +		 * downgrading page table protection not changing it to point
> +		 * to a new page.
> +		 *
> +		 * See Documentation/vm/mmu_notifier.txt
> +		 */
>  		if (pmdp) {
>  #ifdef CONFIG_FS_DAX_PMD
>  			pmd_t pmd;
> @@ -628,7 +635,6 @@ static void dax_mapping_entry_mkclean(struct address_=
space *mapping,
>  			pmd =3D pmd_wrprotect(pmd);
>  			pmd =3D pmd_mkclean(pmd);
>  			set_pmd_at(vma->vm_mm, address, pmdp, pmd);
> -			mmu_notifier_invalidate_range(vma->vm_mm, start, end);

Could the secondary TLB still see the mapping as dirty and propagate the di=
rty bit back?

>  unlock_pmd:
>  			spin_unlock(ptl);
>  #endif
> @@ -643,7 +649,6 @@ static void dax_mapping_entry_mkclean(struct address_=
space *mapping,
>  			pte =3D pte_wrprotect(pte);
>  			pte =3D pte_mkclean(pte);
>  			set_pte_at(vma->vm_mm, address, ptep, pte);
> -			mmu_notifier_invalidate_range(vma->vm_mm, start, end);

Ditto

>  unlock_pte:
>  			pte_unmap_unlock(ptep, ptl);
>  		}
> diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
> index 6866e8126982..49c925c96b8a 100644
> --- a/include/linux/mmu_notifier.h
> +++ b/include/linux/mmu_notifier.h
> @@ -155,7 +155,8 @@ struct mmu_notifier_ops {
>  	 * shared page-tables, it not necessary to implement the
>  	 * invalidate_range_start()/end() notifiers, as
>  	 * invalidate_range() alread catches the points in time when an
> -	 * external TLB range needs to be flushed.
> +	 * external TLB range needs to be flushed. For more in depth
> +	 * discussion on this see Documentation/vm/mmu_notifier.txt
>  	 *
>  	 * The invalidate_range() function is called under the ptl
>  	 * spin-lock and not allowed to sleep.
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index c037d3d34950..ff5bc647b51d 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -1186,8 +1186,15 @@ static int do_huge_pmd_wp_page_fallback(struct vm_=
fault *vmf, pmd_t orig_pmd,
>  		goto out_free_pages;
>  	VM_BUG_ON_PAGE(!PageHead(page), page);
> =20
> +	/*
> +	 * Leave pmd empty until pte is filled note we must notify here as
> +	 * concurrent CPU thread might write to new page before the call to
> +	 * mmu_notifier_invalidate_range_end() happens which can lead to a
> +	 * device seeing memory write in different order than CPU.
> +	 *
> +	 * See Documentation/vm/mmu_notifier.txt
> +	 */
>  	pmdp_huge_clear_flush_notify(vma, haddr, vmf->pmd);
> -	/* leave pmd empty until pte is filled */
> =20
>  	pgtable =3D pgtable_trans_huge_withdraw(vma->vm_mm, vmf->pmd);
>  	pmd_populate(vma->vm_mm, &_pmd, pgtable);
> @@ -2026,8 +2033,15 @@ static void __split_huge_zero_page_pmd(struct vm_a=
rea_struct *vma,
>  	pmd_t _pmd;
>  	int i;
> =20
> -	/* leave pmd empty until pte is filled */
> -	pmdp_huge_clear_flush_notify(vma, haddr, pmd);
> +	/*
> +	 * Leave pmd empty until pte is filled note that it is fine to delay
> +	 * notification until mmu_notifier_invalidate_range_end() as we are
> +	 * replacing a zero pmd write protected page with a zero pte write
> +	 * protected page.
> +	 *
> +	 * See Documentation/vm/mmu_notifier.txt
> +	 */
> +	pmdp_huge_clear_flush(vma, haddr, pmd);

Shouldn't the secondary TLB know if the page size changed?

> =20
>  	pgtable =3D pgtable_trans_huge_withdraw(mm, pmd);
>  	pmd_populate(mm, &_pmd, pgtable);
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 1768efa4c501..63a63f1b536c 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -3254,9 +3254,14 @@ int copy_hugetlb_page_range(struct mm_struct *dst,=
 struct mm_struct *src,
>  			set_huge_swap_pte_at(dst, addr, dst_pte, entry, sz);
>  		} else {
>  			if (cow) {
> +				/*
> +				 * No need to notify as we are downgrading page
> +				 * table protection not changing it to point
> +				 * to a new page.
> +				 *
> +				 * See Documentation/vm/mmu_notifier.txt
> +				 */
>  				huge_ptep_set_wrprotect(src, addr, src_pte);

OK.. so we could get write faults on write accesses from the device.

> -				mmu_notifier_invalidate_range(src, mmun_start,
> -								   mmun_end);
>  			}
>  			entry =3D huge_ptep_get(src_pte);
>  			ptepage =3D pte_page(entry);
> @@ -4288,7 +4293,12 @@ unsigned long hugetlb_change_protection(struct vm_=
area_struct *vma,
>  	 * and that page table be reused and filled with junk.
>  	 */
>  	flush_hugetlb_tlb_range(vma, start, end);
> -	mmu_notifier_invalidate_range(mm, start, end);
> +	/*
> +	 * No need to call mmu_notifier_invalidate_range() we are downgrading
> +	 * page table protection not changing it to point to a new page.
> +	 *
> +	 * See Documentation/vm/mmu_notifier.txt
> +	 */
>  	i_mmap_unlock_write(vma->vm_file->f_mapping);
>  	mmu_notifier_invalidate_range_end(mm, start, end);
> =20
> diff --git a/mm/ksm.c b/mm/ksm.c
> index 6cb60f46cce5..be8f4576f842 100644
> --- a/mm/ksm.c
> +++ b/mm/ksm.c
> @@ -1052,8 +1052,13 @@ static int write_protect_page(struct vm_area_struc=
t *vma, struct page *page,
>  		 * So we clear the pte and flush the tlb before the check
>  		 * this assure us that no O_DIRECT can happen after the check
>  		 * or in the middle of the check.
> +		 *
> +		 * No need to notify as we are downgrading page table to read
> +		 * only not changing it to point to a new page.
> +		 *
> +		 * See Documentation/vm/mmu_notifier.txt
>  		 */
> -		entry =3D ptep_clear_flush_notify(vma, pvmw.address, pvmw.pte);
> +		entry =3D ptep_clear_flush(vma, pvmw.address, pvmw.pte);
>  		/*
>  		 * Check that no O_DIRECT or similar I/O is in progress on the
>  		 * page
> @@ -1136,7 +1141,13 @@ static int replace_page(struct vm_area_struct *vma=
, struct page *page,
>  	}
> =20
>  	flush_cache_page(vma, addr, pte_pfn(*ptep));
> -	ptep_clear_flush_notify(vma, addr, ptep);
> +	/*
> +	 * No need to notify as we are replacing a read only page with another
> +	 * read only page with the same content.
> +	 *
> +	 * See Documentation/vm/mmu_notifier.txt
> +	 */
> +	ptep_clear_flush(vma, addr, ptep);
>  	set_pte_at_notify(mm, addr, ptep, newpte);
> =20
>  	page_remove_rmap(page, false);
> diff --git a/mm/rmap.c b/mm/rmap.c
> index 061826278520..6b5a0f219ac0 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -937,10 +937,15 @@ static bool page_mkclean_one(struct page *page, str=
uct vm_area_struct *vma,
>  #endif
>  		}
> =20
> -		if (ret) {
> -			mmu_notifier_invalidate_range(vma->vm_mm, cstart, cend);
> +		/*
> +		 * No need to call mmu_notifier_invalidate_range() as we are
> +		 * downgrading page table protection not changing it to point
> +		 * to a new page.
> +		 *
> +		 * See Documentation/vm/mmu_notifier.txt
> +		 */
> +		if (ret)
>  			(*cleaned)++;
> -		}
>  	}
> =20
>  	mmu_notifier_invalidate_range_end(vma->vm_mm, start, end);
> @@ -1424,6 +1429,10 @@ static bool try_to_unmap_one(struct page *page, st=
ruct vm_area_struct *vma,
>  			if (pte_soft_dirty(pteval))
>  				swp_pte =3D pte_swp_mksoft_dirty(swp_pte);
>  			set_pte_at(mm, pvmw.address, pvmw.pte, swp_pte);
> +			/*
> +			 * No need to invalidate here it will synchronize on
> +			 * against the special swap migration pte.
> +			 */
>  			goto discard;
>  		}
> =20
> @@ -1481,6 +1490,9 @@ static bool try_to_unmap_one(struct page *page, str=
uct vm_area_struct *vma,
>  			 * will take care of the rest.
>  			 */
>  			dec_mm_counter(mm, mm_counter(page));
> +			/* We have to invalidate as we cleared the pte */
> +			mmu_notifier_invalidate_range(mm, address,
> +						      address + PAGE_SIZE);
>  		} else if (IS_ENABLED(CONFIG_MIGRATION) &&
>  				(flags & (TTU_MIGRATION|TTU_SPLIT_FREEZE))) {
>  			swp_entry_t entry;
> @@ -1496,6 +1508,10 @@ static bool try_to_unmap_one(struct page *page, st=
ruct vm_area_struct *vma,
>  			if (pte_soft_dirty(pteval))
>  				swp_pte =3D pte_swp_mksoft_dirty(swp_pte);
>  			set_pte_at(mm, address, pvmw.pte, swp_pte);
> +			/*
> +			 * No need to invalidate here it will synchronize on
> +			 * against the special swap migration pte.
> +			 */
>  		} else if (PageAnon(page)) {
>  			swp_entry_t entry =3D { .val =3D page_private(subpage) };
>  			pte_t swp_pte;
> @@ -1507,6 +1523,8 @@ static bool try_to_unmap_one(struct page *page, str=
uct vm_area_struct *vma,
>  				WARN_ON_ONCE(1);
>  				ret =3D false;
>  				/* We have to invalidate as we cleared the pte */
> +				mmu_notifier_invalidate_range(mm, address,
> +							address + PAGE_SIZE);
>  				page_vma_mapped_walk_done(&pvmw);
>  				break;
>  			}
> @@ -1514,6 +1532,9 @@ static bool try_to_unmap_one(struct page *page, str=
uct vm_area_struct *vma,
>  			/* MADV_FREE page check */
>  			if (!PageSwapBacked(page)) {
>  				if (!PageDirty(page)) {
> +					/* Invalidate as we cleared the pte */
> +					mmu_notifier_invalidate_range(mm,
> +						address, address + PAGE_SIZE);
>  					dec_mm_counter(mm, MM_ANONPAGES);
>  					goto discard;
>  				}
> @@ -1547,13 +1568,39 @@ static bool try_to_unmap_one(struct page *page, s=
truct vm_area_struct *vma,
>  			if (pte_soft_dirty(pteval))
>  				swp_pte =3D pte_swp_mksoft_dirty(swp_pte);
>  			set_pte_at(mm, address, pvmw.pte, swp_pte);
> -		} else
> +			/* Invalidate as we cleared the pte */
> +			mmu_notifier_invalidate_range(mm, address,
> +						      address + PAGE_SIZE);
> +		} else {
> +			/*
> +			 * We should not need to notify here as we reach this
> +			 * case only from freeze_page() itself only call from
> +			 * split_huge_page_to_list() so everything below must
> +			 * be true:
> +			 *   - page is not anonymous
> +			 *   - page is locked
> +			 *
> +			 * So as it is a locked file back page thus it can not
> +			 * be remove from the page cache and replace by a new
> +			 * page before mmu_notifier_invalidate_range_end so no
> +			 * concurrent thread might update its page table to
> +			 * point at new page while a device still is using this
> +			 * page.
> +			 *
> +			 * See Documentation/vm/mmu_notifier.txt
> +			 */
>  			dec_mm_counter(mm, mm_counter_file(page));
> +		}
>  discard:
> +		/*
> +		 * No need to call mmu_notifier_invalidate_range() it has be
> +		 * done above for all cases requiring it to happen under page
> +		 * table lock before mmu_notifier_invalidate_range_end()
> +		 *
> +		 * See Documentation/vm/mmu_notifier.txt
> +		 */
>  		page_remove_rmap(subpage, PageHuge(page));
>  		put_page(page);
> -		mmu_notifier_invalidate_range(mm, address,
> -					      address + PAGE_SIZE);
>  	}
> =20
>  	mmu_notifier_invalidate_range_end(vma->vm_mm, start, end);

Looking at the patchset, I understand the efficiency, but I am concerned
with correctness.

Balbir Singh.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
