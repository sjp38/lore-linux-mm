Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f175.google.com (mail-io0-f175.google.com [209.85.223.175])
	by kanga.kvack.org (Postfix) with ESMTP id B44236B007E
	for <linux-mm@kvack.org>; Wed, 23 Mar 2016 02:52:41 -0400 (EDT)
Received: by mail-io0-f175.google.com with SMTP id c63so20931664iof.0
        for <linux-mm@kvack.org>; Tue, 22 Mar 2016 23:52:41 -0700 (PDT)
Received: from e35.co.us.ibm.com (e35.co.us.ibm.com. [32.97.110.153])
        by mx.google.com with ESMTPS id s102si2162103ioi.21.2016.03.22.23.52.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 22 Mar 2016 23:52:41 -0700 (PDT)
Received: from localhost
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Wed, 23 Mar 2016 00:52:39 -0600
Received: from b01cxnp23033.gho.pok.ibm.com (b01cxnp23033.gho.pok.ibm.com [9.57.198.28])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 1A9221FF001F
	for <linux-mm@kvack.org>; Wed, 23 Mar 2016 00:40:45 -0600 (MDT)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by b01cxnp23033.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u2N6qZeG29229160
	for <linux-mm@kvack.org>; Wed, 23 Mar 2016 06:52:35 GMT
Received: from d01av01.pok.ibm.com (localhost [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u2N6qZcI009507
	for <linux-mm@kvack.org>; Wed, 23 Mar 2016 02:52:35 -0400
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH v12 08/29] HMM: add device page fault support v6.
In-Reply-To: <1457469802-11850-9-git-send-email-jglisse@redhat.com>
References: <1457469802-11850-1-git-send-email-jglisse@redhat.com> <1457469802-11850-9-git-send-email-jglisse@redhat.com>
Date: Wed, 23 Mar 2016 12:22:23 +0530
Message-ID: <87h9fxu1nc.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?utf-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, joro@8bytes.org, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Christophe Harle <charle@nvidia.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Haggai Eran <haggaie@mellanox.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Leonid Shamis <Leonid.Shamis@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, Jatin Kumar <jakumar@nvidia.com>

J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com> writes:

> [ text/plain ]
> This patch add helper for device page fault. Thus helpers will fill
> the mirror page table using the CPU page table and synchronizing
> with any update to CPU page table.
>
> Changed since v1:
>   - Add comment about directory lock.
>
> Changed since v2:
>   - Check for mirror->hmm in hmm_mirror_fault()
>
> Changed since v3:
>   - Adapt to HMM page table changes.
>
> Changed since v4:
>   - Fix PROT_NONE, ie do not populate from protnone pte.
>   - Fix huge pmd handling (start address may !=3D pmd start address)
>   - Fix missing entry case.
>
> Signed-off-by: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
> Signed-off-by: Sherry Cheung <SCheung@nvidia.com>
> Signed-off-by: Subhash Gutti <sgutti@nvidia.com>
> Signed-off-by: Mark Hairgrove <mhairgrove@nvidia.com>
> Signed-off-by: John Hubbard <jhubbard@nvidia.com>
> Signed-off-by: Jatin Kumar <jakumar@nvidia.com>
> ---


....
....

 +static int hmm_mirror_fault_hpmd(struct hmm_mirror *mirror,
> +				 struct hmm_event *event,
> +				 struct vm_area_struct *vma,
> +				 struct hmm_pt_iter *iter,
> +				 pmd_t *pmdp,
> +				 struct hmm_mirror_fault *mirror_fault,
> +				 unsigned long start,
> +				 unsigned long end)
> +{
> +	struct page *page;
> +	unsigned long addr, pfn;
> +	unsigned flags =3D FOLL_TOUCH;
> +	spinlock_t *ptl;
> +	int ret;
> +
> +	ptl =3D pmd_lock(mirror->hmm->mm, pmdp);
> +	if (unlikely(!pmd_trans_huge(*pmdp))) {
> +		spin_unlock(ptl);
> +		return -EAGAIN;
> +	}
> +	flags |=3D event->etype =3D=3D HMM_DEVICE_WFAULT ? FOLL_WRITE : 0;
> +	page =3D follow_trans_huge_pmd(vma, start, pmdp, flags);
> +	pfn =3D page_to_pfn(page);
> +	spin_unlock(ptl);
> +
> +	/* Just fault in the whole PMD. */
> +	start &=3D PMD_MASK;
> +	end =3D start + PMD_SIZE - 1;
> +
> +	if (!pmd_write(*pmdp) && event->etype =3D=3D HMM_DEVICE_WFAULT)
> +			return -ENOENT;
> +
> +	for (ret =3D 0, addr =3D start; !ret && addr < end;) {
> +		unsigned long i, next =3D end;
> +		dma_addr_t *hmm_pte;
> +
> +		hmm_pte =3D hmm_pt_iter_populate(iter, addr, &next);
> +		if (!hmm_pte)
> +			return -ENOMEM;
> +
> +		i =3D hmm_pt_index(&mirror->pt, addr, mirror->pt.llevel);
> +
> +		/*
> +		 * The directory lock protect against concurrent clearing of
> +		 * page table bit flags. Exceptions being the dirty bit and
> +		 * the device driver private flags.
> +		 */
> +		hmm_pt_iter_directory_lock(iter);
> +		do {
> +			if (!hmm_pte_test_valid_pfn(&hmm_pte[i])) {
> +				hmm_pte[i] =3D hmm_pte_from_pfn(pfn);
> +				hmm_pt_iter_directory_ref(iter);

I looked at that and it is actually=20
static inline void hmm_pt_iter_directory_ref(struct hmm_pt_iter *iter)
{
	BUG_ON(!iter->ptd[iter->pt->llevel - 1]);
	hmm_pt_directory_ref(iter->pt, iter->ptd[iter->pt->llevel - 1]);
}

static inline void hmm_pt_directory_ref(struct hmm_pt *pt,
					struct page *ptd)
{
	if (!atomic_inc_not_zero(&ptd->_mapcount))
		/* Illegal this should not happen. */
		BUG();
}

what is the mapcount update about ?

> +			}
> +			BUG_ON(hmm_pte_pfn(hmm_pte[i]) !=3D pfn);
> +			if (pmd_write(*pmdp))
> +				hmm_pte_set_write(&hmm_pte[i]);
> +		} while (addr +=3D PAGE_SIZE, pfn++, i++, addr !=3D next);
> +		hmm_pt_iter_directory_unlock(iter);
> +		mirror_fault->addr =3D addr;
> +	}
> +

So we don't have huge page mapping in hmm page table ?=20


> +	return 0;
> +}
> +
> +static int hmm_pte_hole(unsigned long addr,
> +			unsigned long next,
> +			struct mm_walk *walk)
> +{
> +	return -ENOENT;
> +}
> +


-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
