Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f51.google.com (mail-qg0-f51.google.com [209.85.192.51])
	by kanga.kvack.org (Postfix) with ESMTP id 856316B0005
	for <linux-mm@kvack.org>; Mon, 21 Mar 2016 07:27:58 -0400 (EDT)
Received: by mail-qg0-f51.google.com with SMTP id a36so117592131qge.0
        for <linux-mm@kvack.org>; Mon, 21 Mar 2016 04:27:58 -0700 (PDT)
Received: from e37.co.us.ibm.com (e37.co.us.ibm.com. [32.97.110.158])
        by mx.google.com with ESMTPS id e95si10789971qgd.14.2016.03.21.04.27.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Mon, 21 Mar 2016 04:27:57 -0700 (PDT)
Received: from localhost
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 21 Mar 2016 05:27:56 -0600
Received: from b01cxnp23034.gho.pok.ibm.com (b01cxnp23034.gho.pok.ibm.com [9.57.198.29])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 6727A3E4003B
	for <linux-mm@kvack.org>; Mon, 21 Mar 2016 05:27:47 -0600 (MDT)
Received: from d01av05.pok.ibm.com (d01av05.pok.ibm.com [9.56.224.195])
	by b01cxnp23034.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u2LBRkmG26869942
	for <linux-mm@kvack.org>; Mon, 21 Mar 2016 11:27:47 GMT
Received: from d01av05.pok.ibm.com (localhost [127.0.0.1])
	by d01av05.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u2LBMjFI023341
	for <linux-mm@kvack.org>; Mon, 21 Mar 2016 07:22:45 -0400
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH v12 21/29] HMM: mm add helper to update page table when migrating memory back v2.
In-Reply-To: <1457469802-11850-22-git-send-email-jglisse@redhat.com>
References: <1457469802-11850-1-git-send-email-jglisse@redhat.com> <1457469802-11850-22-git-send-email-jglisse@redhat.com>
Date: Mon, 21 Mar 2016 16:57:32 +0530
Message-ID: <877fgwul3v.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?utf-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, joro@8bytes.org, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Christophe Harle <charle@nvidia.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Haggai Eran <haggaie@mellanox.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Leonid Shamis <Leonid.Shamis@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>

J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com> writes:

> [ text/plain ]
> To migrate memory back we first need to lock HMM special CPU page
> table entry so we know no one else might try to migrate those entry
> back. Helper also allocate new page where data will be copied back
> from the device. Then we can proceed with the device DMA operation.
>
> Once DMA is done we can update again the CPU page table to point to
> the new page that holds the content copied back from device memory.
>
> Note that we do not need to invalidate the range are we are only
> modifying non present CPU page table entry.
>
> Changed since v1:
>   - Save memcg against which each page is precharge as it might
>     change along the way.
>
> Signed-off-by: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
> ---
>  include/linux/mm.h |  12 +++
>  mm/memory.c        | 257 +++++++++++++++++++++++++++++++++++++++++++++++=
++++++
>  2 files changed, 269 insertions(+)
>
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index c5c062e..1cd060f 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -2392,6 +2392,18 @@ static inline void hmm_mm_init(struct mm_struct *m=
m)
>  {
>  	mm->hmm =3D NULL;
>  }
> +
> +int mm_hmm_migrate_back(struct mm_struct *mm,
> +			struct vm_area_struct *vma,
> +			pte_t *new_pte,
> +			unsigned long start,
> +			unsigned long end);
> +void mm_hmm_migrate_back_cleanup(struct mm_struct *mm,
> +				 struct vm_area_struct *vma,
> +				 pte_t *new_pte,
> +				 dma_addr_t *hmm_pte,
> +				 unsigned long start,
> +				 unsigned long end);
>  #else /* !CONFIG_HMM */
>  static inline void hmm_mm_init(struct mm_struct *mm)
>  {
> diff --git a/mm/memory.c b/mm/memory.c
> index 3cb3653..d917911a 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -3513,6 +3513,263 @@ int handle_mm_fault(struct mm_struct *mm, struct =
vm_area_struct *vma,
>  }
>  EXPORT_SYMBOL_GPL(handle_mm_fault);
>=20=20
> +
> +#ifdef CONFIG_HMM
> +/* mm_hmm_migrate_back() - lock HMM CPU page table entry and allocate ne=
w page.
> + *
> + * @mm: The mm struct.
> + * @vma: The vm area struct the range is in.
> + * @new_pte: Array of new CPU page table entry value.
> + * @start: Start address of the range (inclusive).
> + * @end: End address of the range (exclusive).
> + *
> + * This function will lock HMM page table entry and allocate new page fo=
r entry
> + * it successfully locked.
> + */


Can you add more comments around this ?

> +int mm_hmm_migrate_back(struct mm_struct *mm,
> +			struct vm_area_struct *vma,
> +			pte_t *new_pte,
> +			unsigned long start,
> +			unsigned long end)
> +{
> +	pte_t hmm_entry =3D swp_entry_to_pte(make_hmm_entry_locked());
> +	unsigned long addr, i;
> +	int ret =3D 0;
> +
> +	VM_BUG_ON(vma->vm_ops || (vma->vm_flags & (VM_PFNMAP|VM_MIXEDMAP)));
> +
> +	if (unlikely(anon_vma_prepare(vma)))
> +		return -ENOMEM;
> +
> +	start &=3D PAGE_MASK;
> +	end =3D PAGE_ALIGN(end);
> +	memset(new_pte, 0, sizeof(pte_t) * ((end - start) >> PAGE_SHIFT));
> +
> +	for (addr =3D start; addr < end;) {
> +		unsigned long cstart, next;
> +		spinlock_t *ptl;
> +		pgd_t *pgdp;
> +		pud_t *pudp;
> +		pmd_t *pmdp;
> +		pte_t *ptep;
> +
> +		pgdp =3D pgd_offset(mm, addr);
> +		pudp =3D pud_offset(pgdp, addr);
> +		/*
> +		 * Some other thread might already have migrated back the entry
> +		 * and freed the page table. Unlikely thought.
> +		 */
> +		if (unlikely(!pudp)) {
> +			addr =3D min((addr + PUD_SIZE) & PUD_MASK, end);
> +			continue;
> +		}
> +		pmdp =3D pmd_offset(pudp, addr);
> +		if (unlikely(!pmdp || pmd_bad(*pmdp) || pmd_none(*pmdp) ||
> +			     pmd_trans_huge(*pmdp))) {
> +			addr =3D min((addr + PMD_SIZE) & PMD_MASK, end);
> +			continue;
> +		}
> +		ptep =3D pte_offset_map_lock(mm, pmdp, addr, &ptl);
> +		for (cstart =3D addr, i =3D (addr - start) >> PAGE_SHIFT,
> +		     next =3D min((addr + PMD_SIZE) & PMD_MASK, end);
> +		     addr < next; addr +=3D PAGE_SIZE, ptep++, i++) {
> +			swp_entry_t entry;
> +
> +			entry =3D pte_to_swp_entry(*ptep);
> +			if (pte_none(*ptep) || pte_present(*ptep) ||
> +			    !is_hmm_entry(entry) ||
> +			    is_hmm_entry_locked(entry))
> +				continue;
> +
> +			set_pte_at(mm, addr, ptep, hmm_entry);
> +			new_pte[i] =3D pte_mkspecial(pfn_pte(my_zero_pfn(addr),
> +						   vma->vm_page_prot));
> +		}
> +		pte_unmap_unlock(ptep - 1, ptl);


I guess this is fixing all the ptes in the cpu page table mapping a pmd
entry. But then what is below ?


> +
> +		for (addr =3D cstart, i =3D (addr - start) >> PAGE_SHIFT;
> +		     addr < next; addr +=3D PAGE_SIZE, i++) {

Your use of vairable addr with multiple loops updating then is also
making it complex. We should definitely add more comments here. I guess
we are going through the same range we iterated above here.

> +			struct mem_cgroup *memcg;
> +			struct page *page;
> +
> +			if (!pte_present(new_pte[i]))
> +				continue;

What is that checking for ?. We set that using pte_mkspecial above ?

> +
> +			page =3D alloc_zeroed_user_highpage_movable(vma, addr);
> +			if (!page) {
> +				ret =3D -ENOMEM;
> +				break;
> +			}
> +			__SetPageUptodate(page);
> +			if (mem_cgroup_try_charge(page, mm, GFP_KERNEL,
> +						  &memcg)) {
> +				page_cache_release(page);
> +				ret =3D -ENOMEM;
> +				break;
> +			}
> +			/*
> +			 * We can safely reuse the s_mem/mapping field of page
> +			 * struct to store the memcg as the page is only seen
> +			 * by HMM at this point and we can clear it before it
> +			 * is public see mm_hmm_migrate_back_cleanup().
> +			 */
> +			page->s_mem =3D memcg;
> +			new_pte[i] =3D mk_pte(page, vma->vm_page_prot);
> +			if (vma->vm_flags & VM_WRITE) {
> +				new_pte[i] =3D pte_mkdirty(new_pte[i]);
> +				new_pte[i] =3D pte_mkwrite(new_pte[i]);
> +			}

Why mark it dirty if vm_flags is VM_WRITE ?

> +		}
> +
> +		if (!ret)
> +			continue;
> +
> +		hmm_entry =3D swp_entry_to_pte(make_hmm_entry());
> +		ptep =3D pte_offset_map_lock(mm, pmdp, addr, &ptl);


Again we loop through the same range ?

> +		for (addr =3D cstart, i =3D (addr - start) >> PAGE_SHIFT;
> +		     addr < next; addr +=3D PAGE_SIZE, ptep++, i++) {
> +			unsigned long pfn =3D pte_pfn(new_pte[i]);
> +
> +			if (!pte_present(new_pte[i]) || !is_zero_pfn(pfn))
> +				continue;


What is that checking for ?
> +
> +			set_pte_at(mm, addr, ptep, hmm_entry);
> +			pte_clear(mm, addr, &new_pte[i]);

what is that pte_clear for ?. Handling of new_pte needs more code comments.

> +		}
> +		pte_unmap_unlock(ptep - 1, ptl);
> +		break;
> +	}
> +	return ret;
> +}
> +EXPORT_SYMBOL(mm_hmm_migrate_back);
> +


-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
