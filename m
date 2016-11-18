Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id A59DA6B0476
	for <linux-mm@kvack.org>; Fri, 18 Nov 2016 14:57:40 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id p66so270550059pga.4
        for <linux-mm@kvack.org>; Fri, 18 Nov 2016 11:57:40 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id b141si9550710pfb.177.2016.11.18.11.57.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Nov 2016 11:57:39 -0800 (PST)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uAIJsMbt041148
	for <linux-mm@kvack.org>; Fri, 18 Nov 2016 14:57:39 -0500
Received: from e17.ny.us.ibm.com (e17.ny.us.ibm.com [129.33.205.207])
	by mx0a-001b2d01.pphosted.com with ESMTP id 26t2tuyeaj-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 18 Nov 2016 14:57:39 -0500
Received: from localhost
	by e17.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Fri, 18 Nov 2016 14:57:37 -0500
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [HMM v13 16/18] mm/hmm/migrate: new memory migration helper for use with device memory
In-Reply-To: <1479493107-982-17-git-send-email-jglisse@redhat.com>
References: <1479493107-982-1-git-send-email-jglisse@redhat.com> <1479493107-982-17-git-send-email-jglisse@redhat.com>
Date: Sat, 19 Nov 2016 01:27:28 +0530
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Message-Id: <87k2c0muhj.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?utf-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: John Hubbard <jhubbard@nvidia.com>, Jatin Kumar <jakumar@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>

J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com> writes:

> This patch add a new memory migration helpers, which migrate memory
> backing a range of virtual address of a process to different memory
> (which can be allocated through special allocator). It differs from
> numa migration by working on a range of virtual address and thus by
> doing migration in chunk that can be large enough to use DMA engine
> or special copy offloading engine.
>
> Expected users are any one with heterogeneous memory where different
> memory have different characteristics (latency, bandwidth, ...). As
> an example IBM platform with CAPI bus can make use of this feature
> to migrate between regular memory and CAPI device memory. New CPU
> architecture with a pool of high performance memory not manage as
> cache but presented as regular memory (while being faster and with
> lower latency than DDR) will also be prime user of this patch.
>
> Migration to private device memory will be usefull for device that
> have large pool of such like GPU, NVidia plans to use HMM for that.
>



..............


>+
> +static int hmm_collect_walk_pmd(pmd_t *pmdp,
> +				unsigned long start,
> +				unsigned long end,
> +				struct mm_walk *walk)
> +{
> +	struct hmm_migrate *migrate =3D walk->private;
> +	struct mm_struct *mm =3D walk->vma->vm_mm;
> +	unsigned long addr =3D start;
> +	spinlock_t *ptl;
> +	hmm_pfn_t *pfns;
> +	int pages =3D 0;
> +	pte_t *ptep;
> +
> +again:
> +	if (pmd_none(*pmdp))
> +		return 0;
> +
> +	split_huge_pmd(walk->vma, pmdp, addr);
> +	if (pmd_trans_unstable(pmdp))
> +		goto again;
> +
> +	pfns =3D &migrate->pfns[(addr - migrate->start) >> PAGE_SHIFT];
> +	ptep =3D pte_offset_map_lock(mm, pmdp, addr, &ptl);
> +	arch_enter_lazy_mmu_mode();
> +
> +	for (; addr < end; addr +=3D PAGE_SIZE, pfns++, ptep++) {
> +		unsigned long pfn;
> +		swp_entry_t entry;
> +		struct page *page;
> +		hmm_pfn_t flags;
> +		bool write;
> +		pte_t pte;
> +
> +		pte =3D ptep_get_and_clear(mm, addr, ptep);
> +		if (!pte_present(pte)) {
> +			if (pte_none(pte))
> +				continue;
> +
> +			entry =3D pte_to_swp_entry(pte);
> +			if (!is_device_entry(entry)) {
> +				set_pte_at(mm, addr, ptep, pte);
> +				continue;
> +			}
> +
> +			flags =3D HMM_PFN_DEVICE | HMM_PFN_UNADDRESSABLE;
> +			page =3D device_entry_to_page(entry);
> +			write =3D is_write_device_entry(entry);
> +			pfn =3D page_to_pfn(page);
> +
> +			if (!(page->pgmap->flags & MEMORY_MOVABLE)) {
> +				set_pte_at(mm, addr, ptep, pte);
> +				continue;
> +			}
> +
> +		} else {
> +			pfn =3D pte_pfn(pte);
> +			page =3D pfn_to_page(pfn);
> +			write =3D pte_write(pte);
> +			flags =3D is_zone_device_page(page) ? HMM_PFN_DEVICE : 0;
> +		}
> +
> +		/* FIXME support THP see hmm_migrate_page_check() */
> +		if (PageTransCompound(page))
> +			continue;
> +
> +		*pfns =3D hmm_pfn_from_pfn(pfn) | HMM_PFN_MIGRATE | flags;
> +		*pfns |=3D write ? HMM_PFN_WRITE : 0;
> +		migrate->npages++;
> +		get_page(page);
> +
> +		if (!trylock_page(page)) {
> +			set_pte_at(mm, addr, ptep, pte);
> +		} else {
> +			pte_t swp_pte;
> +
> +			*pfns |=3D HMM_PFN_LOCKED;
> +
> +			entry =3D make_migration_entry(page, write);
> +			swp_pte =3D swp_entry_to_pte(entry);
> +			if (pte_soft_dirty(pte))
> +				swp_pte =3D pte_swp_mksoft_dirty(swp_pte);
> +			set_pte_at(mm, addr, ptep, swp_pte);
> +
> +			page_remove_rmap(page, false);
> +			put_page(page);
> +			pages++;
> +		}

Can you explain this. What does a failure to lock means here. Also why
convert the pte to migration entries here ? We do that in try_to_unmap righ=
t ?


> +	}
> +
> +	arch_leave_lazy_mmu_mode();
> +	pte_unmap_unlock(ptep - 1, ptl);
> +
> +	/* Only flush the TLB if we actually modified any entries */
> +	if (pages)
> +		flush_tlb_range(walk->vma, start, end);
> +
> +	return 0;
> +}
>=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
