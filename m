Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f54.google.com (mail-qg0-f54.google.com [209.85.192.54])
	by kanga.kvack.org (Postfix) with ESMTP id B590B6B0005
	for <linux-mm@kvack.org>; Mon, 21 Mar 2016 10:25:31 -0400 (EDT)
Received: by mail-qg0-f54.google.com with SMTP id w104so153178421qge.1
        for <linux-mm@kvack.org>; Mon, 21 Mar 2016 07:25:31 -0700 (PDT)
Received: from e33.co.us.ibm.com (e33.co.us.ibm.com. [32.97.110.151])
        by mx.google.com with ESMTPS id q66si11300796qgd.93.2016.03.21.07.25.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Mon, 21 Mar 2016 07:25:30 -0700 (PDT)
Received: from localhost
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 21 Mar 2016 08:25:28 -0600
Received: from b03cxnp07029.gho.boulder.ibm.com (b03cxnp07029.gho.boulder.ibm.com [9.17.130.16])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id D14F61FF004B
	for <linux-mm@kvack.org>; Mon, 21 Mar 2016 08:13:29 -0600 (MDT)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by b03cxnp07029.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u2LEPK0t30540008
	for <linux-mm@kvack.org>; Mon, 21 Mar 2016 07:25:20 -0700
Received: from d03av03.boulder.ibm.com (localhost [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u2LEPJ5l016160
	for <linux-mm@kvack.org>; Mon, 21 Mar 2016 08:25:20 -0600
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH v12 22/29] HMM: mm add helper to update page table when migrating memory v3.
In-Reply-To: <1457469802-11850-23-git-send-email-jglisse@redhat.com>
References: <1457469802-11850-1-git-send-email-jglisse@redhat.com> <1457469802-11850-23-git-send-email-jglisse@redhat.com>
Date: Mon, 21 Mar 2016 19:54:39 +0530
Message-ID: <87y49bucwo.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?utf-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, joro@8bytes.org, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Christophe Harle <charle@nvidia.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Haggai Eran <haggaie@mellanox.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Leonid Shamis <Leonid.Shamis@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>

J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com> writes:

> +
> +	/* Try to fail early on. */
> +	if (unlikely(anon_vma_prepare(vma)))
> +		return -ENOMEM;
> +

What is this about ?

> +retry:
> +	lru_add_drain();
> +	tlb_gather_mmu(&tlb, mm, range.start, range.end);
> +	update_hiwater_rss(mm);
> +	mmu_notifier_invalidate_range_start_excluding(mm, &range,
> +						      mmu_notifier_exclude);
> +	tlb_start_vma(&tlb, vma);
> +	for (addr =3D range.start, i =3D 0; addr < end && !ret;) {
> +		unsigned long cstart, next, npages =3D 0;
> +		spinlock_t *ptl;
> +		pgd_t *pgdp;
> +		pud_t *pudp;
> +		pmd_t *pmdp;
> +		pte_t *ptep;
> +
> +		/*
> +		 * Pretty much the exact same logic as __handle_mm_fault(),
> +		 * exception being the handling of huge pmd.
> +		 */
> +		pgdp =3D pgd_offset(mm, addr);
> +		pudp =3D pud_alloc(mm, pgdp, addr);
> +		if (!pudp) {
> +			ret =3D -ENOMEM;
> +			break;
> +		}
> +		pmdp =3D pmd_alloc(mm, pudp, addr);
> +		if (!pmdp) {
> +			ret =3D -ENOMEM;
> +			break;
> +		}
> +		if (unlikely(pte_alloc(mm, pmdp, addr))) {
> +			ret =3D -ENOMEM;
> +			break;
> +		}
> +
> +		/*
> +		 * If a huge pmd materialized under us just retry later.  Use
> +		 * pmd_trans_unstable() instead of pmd_trans_huge() to ensure the pmd
> +		 * didn't become pmd_trans_huge under us and then back to pmd_none, as
> +		 * a result of MADV_DONTNEED running immediately after a huge pmd fault
> +		 * in a different thread of this mm, in turn leading to a misleading
> +		 * pmd_trans_huge() retval.  All we have to ensure is that it is a
> +		 * regular pmd that we can walk with pte_offset_map() and we can do th=
at
> +		 * through an atomic read in C, which is what pmd_trans_unstable()
> +		 * provides.
> +		 */
> +		if (unlikely(pmd_trans_unstable(pmdp) || pmd_devmap(*pmdp))) {
> +			ret =3D -EAGAIN;
> +			break;
> +		}
> +
> +		/*
> +		 * If an huge pmd materialized from under us split it and break
> +		 * out of the loop to retry.
> +		 */
> +		if (pmd_trans_huge(*pmdp) || pmd_devmap(*pmdp)) {
> +			split_huge_pmd(vma, addr, pmdp);
> +			ret =3D -EAGAIN;
> +			break;
> +		}
> +
> +		/*
> +		 * A regular pmd is established and it can't morph into a huge pmd
> +		 * from under us anymore at this point because we hold the mmap_sem
> +		 * read mode and khugepaged takes it in write mode. So now it's
> +		 * safe to run pte_offset_map().
> +		 */
> +		ptep =3D pte_offset_map(pmdp, addr);
> +
> +		/*
> +		 * A regular pmd is established and it can't morph into a huge
> +		 * pmd from under us anymore at this point because we hold the
> +		 * mmap_sem read mode and khugepaged takes it in write mode. So
> +		 * now it's safe to run pte_offset_map().
> +		 */
> +		ptep =3D pte_offset_map_lock(mm, pmdp, addr, &ptl);


Why pte_offset_map followed by map_lock ?

> +		for (i =3D (addr - start) >> PAGE_SHIFT, cstart =3D addr,
> +		     next =3D min((addr + PMD_SIZE) & PMD_MASK, end);
> +		     addr < next; addr +=3D PAGE_SIZE, ptep++, i++) {
> +			save_pte[i] =3D ptep_get_and_clear(mm, addr, ptep);
> +			tlb_remove_tlb_entry(&tlb, ptep, addr);
> +			set_pte_at(mm, addr, ptep, hmm_entry);
> +
> +			if (pte_present(save_pte[i]))
> +				continue;
> +
> +			if (!pte_none(save_pte[i])) {
> +				set_pte_at(mm, addr, ptep, save_pte[i]);
> +				ret =3D -ENOENT;
> +				ptep++;
> +				break;
> +			}

What is special about pte_none ? Why break the loop ? I guess we are
checking for swap_pte ? why not is_swap_pte ? is that we already checked
pte_present ?

> +			/*
> +			 * TODO: This mm_forbids_zeropage() really does not
> +			 * apply to us. First it seems only S390 have it set,
> +			 * second we are not even using the zero page entry
> +			 * to populate the CPU page table, thought on error
> +			 * we might use the save_pte entry to set the CPU
> +			 * page table entry.
> +			 *
> +			 * Live with that oddity for now.
> +			 */
> +			if (mm_forbids_zeropage(mm)) {
> +				pte_clear(mm, addr, &save_pte[i]);
> +				npages++;
> +				continue;
> +			}
> +			save_pte[i] =3D pte_mkspecial(pfn_pte(my_zero_pfn(addr),
> +						    vma->vm_page_prot));
> +		}
> +		pte_unmap_unlock(ptep - 1, ptl);
> +
> +		/*
> +		 * So we must allocate pages before checking for error, which
> +		 * here indicate that one entry is a swap entry. We need to
> +		 * allocate first because otherwise there is no easy way to
> +		 * know on retry or in error code path wether the CPU page
> +		 * table locked HMM entry is ours or from some other thread.
> +		 */
> +
> +		if (!npages)
> +			continue;
> +
> +		for (next =3D addr, addr =3D cstart,
> +		     i =3D (addr - start) >> PAGE_SHIFT;
> +		     addr < next; addr +=3D PAGE_SIZE, i++) {
> +			struct mem_cgroup *memcg;
> +			struct page *page;
> +
> +			if (pte_present(save_pte[i]) || !pte_none(save_pte[i]))
> +				continue;
> +
> +			page =3D alloc_zeroed_user_highpage_movable(vma, addr);
> +			if (!page) {
> +				ret =3D -ENOMEM;
> +				break;
> +			}
> +			__SetPageUptodate(page);
> +			if (mem_cgroup_try_charge(page, mm, GFP_KERNEL,
> +						  &memcg, false)) {
> +				page_cache_release(page);
> +				ret =3D -ENOMEM;
> +				break;
> +			}
> +			save_pte[i] =3D mk_pte(page, vma->vm_page_prot);
> +			if (vma->vm_flags & VM_WRITE)
> +				save_pte[i] =3D pte_mkwrite(save_pte[i]);

I guess this also need to go ?

> +			inc_mm_counter_fast(mm, MM_ANONPAGES);
> +			/*
> +			 * Because we set the page table entry to the special
> +			 * HMM locked entry we know no other process might do
> +			 * anything with it and thus we can safely account the
> +			 * page without holding any lock at this point.
> +			 */
> +			page_add_new_anon_rmap(page, vma, addr, false);
> +			mem_cgroup_commit_charge(page, memcg, false, false);
> +			/*
> +			 * Add to active list so we know vmscan will not waste
> +			 * its time with that page while we are still using it.
> +			 */
> +			lru_cache_add_active_or_unevictable(page, vma);
> +		}
> +	}
> +	tlb_end_vma(&tlb, vma);
> +	mmu_notifier_invalidate_range_end_excluding(mm, &range,
> +						    mmu_notifier_exclude);
> +	tlb_finish_mmu(&tlb, range.start, range.end);
> +
> +	if (backoff && *backoff) {
> +		/* Stick to the range we updated. */
> +		ret =3D -EAGAIN;
> +		end =3D addr;
> +		goto out;
> +	}
> +
> +	/* Check if something is missing or something went wrong. */
> +	if (ret =3D=3D -ENOENT) {
> +		int flags =3D FAULT_FLAG_ALLOW_RETRY;
> +
> +		do {
> +			/*
> +			 * Using __handle_mm_fault() as current->mm !=3D mm ie we
> +			 * might have been call from a kernel thread on behalf
> +			 * of a driver and all accounting handle_mm_fault() is
> +			 * pointless in our case.
> +			 */
> +			ret =3D __handle_mm_fault(mm, vma, addr, flags);
> +			flags |=3D FAULT_FLAG_TRIED;
> +		} while ((ret & VM_FAULT_RETRY));
> +		if ((ret & VM_FAULT_ERROR)) {
> +			/* Stick to the range we updated. */
> +			end =3D addr;
> +			ret =3D -EFAULT;
> +			goto out;
> +		}
> +		range.start =3D addr;
> +		goto retry;
> +	}
> +	if (ret =3D=3D -EAGAIN) {
> +		range.start =3D addr;
> +		goto retry;
> +	}
> +	if (ret)
> +		/* Stick to the range we updated. */
> +		end =3D addr;
> +
> +	/*
> +	 * At this point no one else can take a reference on the page from this
> +	 * process CPU page table. So we can safely check wether we can migrate
> +	 * or not the page.
> +	 */
> +
> +out:
> +	for (addr =3D start, i =3D 0; addr < end;) {
> +		unsigned long next;
> +		spinlock_t *ptl;
> +		pgd_t *pgdp;
> +		pud_t *pudp;
> +		pmd_t *pmdp;
> +		pte_t *ptep;
> +
> +		/*
> +		 * We know for certain that we did set special swap entry for
> +		 * the range and HMM entry are mark as locked so it means that
> +		 * no one beside us can modify them which apply that all level
> +		 * of the CPU page table are valid.
> +		 */
> +		pgdp =3D pgd_offset(mm, addr);
> +		pudp =3D pud_offset(pgdp, addr);
> +		VM_BUG_ON(!pudp);
> +		pmdp =3D pmd_offset(pudp, addr);
> +		VM_BUG_ON(!pmdp || pmd_bad(*pmdp) || pmd_none(*pmdp) ||
> +			  pmd_trans_huge(*pmdp));
> +
> +		ptep =3D pte_offset_map_lock(mm, pmdp, addr, &ptl);
> +		for (next =3D min((addr + PMD_SIZE) & PMD_MASK, end),
> +		     i =3D (addr - start) >> PAGE_SHIFT; addr < next;
> +		     addr +=3D PAGE_SIZE, ptep++, i++) {
> +			struct page *page;
> +			swp_entry_t entry;
> +			int swapped;
> +
> +			entry =3D pte_to_swp_entry(save_pte[i]);
> +			if (is_hmm_entry(entry)) {
> +				/*
> +				 * Logic here is pretty involve. If save_pte is
> +				 * an HMM special swap entry then it means that
> +				 * we failed to swap in that page so error must
> +				 * be set.
> +				 *
> +				 * If that's not the case than it means we are
> +				 * seriously screw.
> +				 */
> +				VM_BUG_ON(!ret);
> +				continue;
> +			}
> +
> +			/*
> +			 * This can not happen, no one else can replace our
> +			 * special entry and as range end is re-ajusted on
> +			 * error.
> +			 */
> +			entry =3D pte_to_swp_entry(*ptep);
> +			VM_BUG_ON(!is_hmm_entry_locked(entry));
> +
> +			/* On error or backoff restore all the saved pte. */
> +			if (ret)
> +				goto restore;
> +
> +			page =3D vm_normal_page(vma, addr, save_pte[i]);
> +			/* The zero page is fine to migrate. */
> +			if (!page)
> +				continue;
> +
> +			/*
> +			 * Check that only CPU mapping hold a reference on the
> +			 * page. To make thing simpler we just refuse bail out
> +			 * if page_mapcount() !=3D page_count() (also accounting
> +			 * for swap cache).
> +			 *
> +			 * There is a small window here where wp_page_copy()
> +			 * might have decremented mapcount but have not yet
> +			 * decremented the page count. This is not an issue as
> +			 * we backoff in that case.
> +			 */
> +			swapped =3D PageSwapCache(page);
> +			if (page_mapcount(page) + swapped =3D=3D page_count(page))
> +				continue;
> +
> +restore:
> +			/* Ok we have to restore that page. */
> +			set_pte_at(mm, addr, ptep, save_pte[i]);
> +			/*
> +			 * No need to invalidate - it was non-present
> +			 * before.
> +			 */
> +			update_mmu_cache(vma, addr, ptep);
> +			pte_clear(mm, addr, &save_pte[i]);
> +		}
> +		pte_unmap_unlock(ptep - 1, ptl);
> +	}
> +	return ret;
> +}
> +EXPORT_SYMBOL(mm_hmm_migrate);

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
