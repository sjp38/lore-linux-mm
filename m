Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f177.google.com (mail-qk0-f177.google.com [209.85.220.177])
	by kanga.kvack.org (Postfix) with ESMTP id A77526B007E
	for <linux-mm@kvack.org>; Wed, 23 Mar 2016 06:10:04 -0400 (EDT)
Received: by mail-qk0-f177.google.com with SMTP id s5so3661848qkd.0
        for <linux-mm@kvack.org>; Wed, 23 Mar 2016 03:10:04 -0700 (PDT)
Received: from mail-qg0-x243.google.com (mail-qg0-x243.google.com. [2607:f8b0:400d:c04::243])
        by mx.google.com with ESMTPS id c8si1558737qkb.35.2016.03.23.03.10.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Mar 2016 03:10:03 -0700 (PDT)
Received: by mail-qg0-x243.google.com with SMTP id c67so796435qgc.2
        for <linux-mm@kvack.org>; Wed, 23 Mar 2016 03:10:03 -0700 (PDT)
Date: Wed, 23 Mar 2016 11:09:20 +0100
From: Jerome Glisse <j.glisse@gmail.com>
Subject: Re: [PATCH v12 08/29] HMM: add device page fault support v6.
Message-ID: <20160323100919.GA2888@gmail.com>
References: <1457469802-11850-1-git-send-email-jglisse@redhat.com>
 <1457469802-11850-9-git-send-email-jglisse@redhat.com>
 <87h9fxu1nc.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <87h9fxu1nc.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, joro@8bytes.org, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Christophe Harle <charle@nvidia.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Haggai Eran <haggaie@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Leonid Shamis <Leonid.Shamis@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, Jatin Kumar <jakumar@nvidia.com>

On Wed, Mar 23, 2016 at 12:22:23PM +0530, Aneesh Kumar K.V wrote:
> Jerome Glisse <jglisse@redhat.com> writes:
> 
> > [ text/plain ]
> > This patch add helper for device page fault. Thus helpers will fill
> > the mirror page table using the CPU page table and synchronizing
> > with any update to CPU page table.
> >
> > Changed since v1:
> >   - Add comment about directory lock.
> >
> > Changed since v2:
> >   - Check for mirror->hmm in hmm_mirror_fault()
> >
> > Changed since v3:
> >   - Adapt to HMM page table changes.
> >
> > Changed since v4:
> >   - Fix PROT_NONE, ie do not populate from protnone pte.
> >   - Fix huge pmd handling (start address may != pmd start address)
> >   - Fix missing entry case.
> >
> > Signed-off-by: Jerome Glisse <jglisse@redhat.com>
> > Signed-off-by: Sherry Cheung <SCheung@nvidia.com>
> > Signed-off-by: Subhash Gutti <sgutti@nvidia.com>
> > Signed-off-by: Mark Hairgrove <mhairgrove@nvidia.com>
> > Signed-off-by: John Hubbard <jhubbard@nvidia.com>
> > Signed-off-by: Jatin Kumar <jakumar@nvidia.com>
> > ---
> 
> 
> ....
> ....
> 
>  +static int hmm_mirror_fault_hpmd(struct hmm_mirror *mirror,
> > +				 struct hmm_event *event,
> > +				 struct vm_area_struct *vma,
> > +				 struct hmm_pt_iter *iter,
> > +				 pmd_t *pmdp,
> > +				 struct hmm_mirror_fault *mirror_fault,
> > +				 unsigned long start,
> > +				 unsigned long end)
> > +{
> > +	struct page *page;
> > +	unsigned long addr, pfn;
> > +	unsigned flags = FOLL_TOUCH;
> > +	spinlock_t *ptl;
> > +	int ret;
> > +
> > +	ptl = pmd_lock(mirror->hmm->mm, pmdp);
> > +	if (unlikely(!pmd_trans_huge(*pmdp))) {
> > +		spin_unlock(ptl);
> > +		return -EAGAIN;
> > +	}
> > +	flags |= event->etype == HMM_DEVICE_WFAULT ? FOLL_WRITE : 0;
> > +	page = follow_trans_huge_pmd(vma, start, pmdp, flags);
> > +	pfn = page_to_pfn(page);
> > +	spin_unlock(ptl);
> > +
> > +	/* Just fault in the whole PMD. */
> > +	start &= PMD_MASK;
> > +	end = start + PMD_SIZE - 1;
> > +
> > +	if (!pmd_write(*pmdp) && event->etype == HMM_DEVICE_WFAULT)
> > +			return -ENOENT;
> > +
> > +	for (ret = 0, addr = start; !ret && addr < end;) {
> > +		unsigned long i, next = end;
> > +		dma_addr_t *hmm_pte;
> > +
> > +		hmm_pte = hmm_pt_iter_populate(iter, addr, &next);
> > +		if (!hmm_pte)
> > +			return -ENOMEM;
> > +
> > +		i = hmm_pt_index(&mirror->pt, addr, mirror->pt.llevel);
> > +
> > +		/*
> > +		 * The directory lock protect against concurrent clearing of
> > +		 * page table bit flags. Exceptions being the dirty bit and
> > +		 * the device driver private flags.
> > +		 */
> > +		hmm_pt_iter_directory_lock(iter);
> > +		do {
> > +			if (!hmm_pte_test_valid_pfn(&hmm_pte[i])) {
> > +				hmm_pte[i] = hmm_pte_from_pfn(pfn);
> > +				hmm_pt_iter_directory_ref(iter);
> 
> I looked at that and it is actually 
> static inline void hmm_pt_iter_directory_ref(struct hmm_pt_iter *iter)
> {
> 	BUG_ON(!iter->ptd[iter->pt->llevel - 1]);
> 	hmm_pt_directory_ref(iter->pt, iter->ptd[iter->pt->llevel - 1]);
> }
> 
> static inline void hmm_pt_directory_ref(struct hmm_pt *pt,
> 					struct page *ptd)
> {
> 	if (!atomic_inc_not_zero(&ptd->_mapcount))
> 		/* Illegal this should not happen. */
> 		BUG();
> }
> 
> what is the mapcount update about ?

Unlike regular CPU page table we do not rely on unmap to prune HMM mirror
page table. Rather we free/prune it aggressively once the device no longer
have anything mirror in a given range.

As such mapcount is use to keep track of any many valid entry there is per
directory.

Moreover mapcount is also use to protect from concurrent pruning when
you walk through the page table you increment refcount by one along your
way. When you done walking you decrement refcount.

Because of that last aspect, the mapcount can never reach zero because we
unmap page, it can only reach zero once we cleanup the page table walk.

> 
> > +			}
> > +			BUG_ON(hmm_pte_pfn(hmm_pte[i]) != pfn);
> > +			if (pmd_write(*pmdp))
> > +				hmm_pte_set_write(&hmm_pte[i]);
> > +		} while (addr += PAGE_SIZE, pfn++, i++, addr != next);
> > +		hmm_pt_iter_directory_unlock(iter);
> > +		mirror_fault->addr = addr;
> > +	}
> > +
> 
> So we don't have huge page mapping in hmm page table ? 

No we don't right now. First reason is that i wanted to keep things simple for
device driver. Second motivation is to keep first patchset simpler especialy
the page migration code.

Memory overhead is 2MB per GB of virtual memory mirrored. There is no TLB here.
I believe adding huge page can be done as part of a latter patchset if it makes
sense.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
