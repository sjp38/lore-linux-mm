Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f50.google.com (mail-vk0-f50.google.com [209.85.213.50])
	by kanga.kvack.org (Postfix) with ESMTP id 9D8B26B0005
	for <linux-mm@kvack.org>; Mon, 21 Mar 2016 08:03:09 -0400 (EDT)
Received: by mail-vk0-f50.google.com with SMTP id k1so211802537vkb.0
        for <linux-mm@kvack.org>; Mon, 21 Mar 2016 05:03:09 -0700 (PDT)
Received: from mail-qg0-x242.google.com (mail-qg0-x242.google.com. [2607:f8b0:400d:c04::242])
        by mx.google.com with ESMTPS id 8si16191700vki.134.2016.03.21.05.03.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Mar 2016 05:03:08 -0700 (PDT)
Received: by mail-qg0-x242.google.com with SMTP id y89so13002473qge.0
        for <linux-mm@kvack.org>; Mon, 21 Mar 2016 05:03:08 -0700 (PDT)
Date: Mon, 21 Mar 2016 13:02:54 +0100
From: Jerome Glisse <j.glisse@gmail.com>
Subject: Re: [PATCH v12 21/29] HMM: mm add helper to update page table when
 migrating memory back v2.
Message-ID: <20160321120251.GA4518@gmail.com>
References: <1457469802-11850-1-git-send-email-jglisse@redhat.com>
 <1457469802-11850-22-git-send-email-jglisse@redhat.com>
 <877fgwul3v.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <877fgwul3v.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, joro@8bytes.org, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Christophe Harle <charle@nvidia.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Haggai Eran <haggaie@mellanox.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Leonid Shamis <Leonid.Shamis@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>

On Mon, Mar 21, 2016 at 04:57:32PM +0530, Aneesh Kumar K.V wrote:
> Jerome Glisse <jglisse@redhat.com> writes:

[...]

> > +
> > +#ifdef CONFIG_HMM
> > +/* mm_hmm_migrate_back() - lock HMM CPU page table entry and allocate new page.
> > + *
> > + * @mm: The mm struct.
> > + * @vma: The vm area struct the range is in.
> > + * @new_pte: Array of new CPU page table entry value.
> > + * @start: Start address of the range (inclusive).
> > + * @end: End address of the range (exclusive).
> > + *
> > + * This function will lock HMM page table entry and allocate new page for entry
> > + * it successfully locked.
> > + */
> 
> 
> Can you add more comments around this ?

I should describe the process a bit more i guess. It is multi-step, first we update
CPU page table with special HMM "lock" entry, this is to exclude concurrent migration
happening on same page. Once we have "locked" the CPU page table entry we allocate
the proper number of pages. Then we schedule the dma from the GPU to this pages and
once it is done we update the CPU page table to point to this pages. This is why we
are going over the page table so many times. This should answer most of your questions
below but i still provide answer for each of them.

> 
> > +int mm_hmm_migrate_back(struct mm_struct *mm,
> > +			struct vm_area_struct *vma,
> > +			pte_t *new_pte,
> > +			unsigned long start,
> > +			unsigned long end)
> > +{
> > +	pte_t hmm_entry = swp_entry_to_pte(make_hmm_entry_locked());
> > +	unsigned long addr, i;
> > +	int ret = 0;
> > +
> > +	VM_BUG_ON(vma->vm_ops || (vma->vm_flags & (VM_PFNMAP|VM_MIXEDMAP)));
> > +
> > +	if (unlikely(anon_vma_prepare(vma)))
> > +		return -ENOMEM;
> > +
> > +	start &= PAGE_MASK;
> > +	end = PAGE_ALIGN(end);
> > +	memset(new_pte, 0, sizeof(pte_t) * ((end - start) >> PAGE_SHIFT));
> > +
> > +	for (addr = start; addr < end;) {
> > +		unsigned long cstart, next;
> > +		spinlock_t *ptl;
> > +		pgd_t *pgdp;
> > +		pud_t *pudp;
> > +		pmd_t *pmdp;
> > +		pte_t *ptep;
> > +
> > +		pgdp = pgd_offset(mm, addr);
> > +		pudp = pud_offset(pgdp, addr);
> > +		/*
> > +		 * Some other thread might already have migrated back the entry
> > +		 * and freed the page table. Unlikely thought.
> > +		 */
> > +		if (unlikely(!pudp)) {
> > +			addr = min((addr + PUD_SIZE) & PUD_MASK, end);
> > +			continue;
> > +		}
> > +		pmdp = pmd_offset(pudp, addr);
> > +		if (unlikely(!pmdp || pmd_bad(*pmdp) || pmd_none(*pmdp) ||
> > +			     pmd_trans_huge(*pmdp))) {
> > +			addr = min((addr + PMD_SIZE) & PMD_MASK, end);
> > +			continue;
> > +		}
> > +		ptep = pte_offset_map_lock(mm, pmdp, addr, &ptl);
> > +		for (cstart = addr, i = (addr - start) >> PAGE_SHIFT,
> > +		     next = min((addr + PMD_SIZE) & PMD_MASK, end);
> > +		     addr < next; addr += PAGE_SIZE, ptep++, i++) {
> > +			swp_entry_t entry;
> > +
> > +			entry = pte_to_swp_entry(*ptep);
> > +			if (pte_none(*ptep) || pte_present(*ptep) ||
> > +			    !is_hmm_entry(entry) ||
> > +			    is_hmm_entry_locked(entry))
> > +				continue;
> > +
> > +			set_pte_at(mm, addr, ptep, hmm_entry);
> > +			new_pte[i] = pte_mkspecial(pfn_pte(my_zero_pfn(addr),
> > +						   vma->vm_page_prot));
> > +		}
> > +		pte_unmap_unlock(ptep - 1, ptl);
> 
> 
> I guess this is fixing all the ptes in the cpu page table mapping a pmd
> entry. But then what is below ?

Because we are dealing with special swap entry we know we can not have huge pages.
So we only care about HMM special swap entry. We record entry we want to migrate
in the new_pte array. The loop above is under pmd spin lock, the loop below does
memory allocation and we do not want to hold any spin lock while doing allocation.

> 
> > +
> > +		for (addr = cstart, i = (addr - start) >> PAGE_SHIFT;
> > +		     addr < next; addr += PAGE_SIZE, i++) {
> 
> Your use of vairable addr with multiple loops updating then is also
> making it complex. We should definitely add more comments here. I guess
> we are going through the same range we iterated above here.

Correct we are going over the exact same range, i am keeping the addr only
for alloc_zeroed_user_highpage_movable() purpose.

> 
> > +			struct mem_cgroup *memcg;
> > +			struct page *page;
> > +
> > +			if (!pte_present(new_pte[i]))
> > +				continue;
> 
> What is that checking for ?. We set that using pte_mkspecial above ?

Not all entry in the range might match the criteria (ie special unlocked HMM swap
entry). We want to allocate pages only for entry that match the criteria.

> 
> > +
> > +			page = alloc_zeroed_user_highpage_movable(vma, addr);
> > +			if (!page) {
> > +				ret = -ENOMEM;
> > +				break;
> > +			}
> > +			__SetPageUptodate(page);
> > +			if (mem_cgroup_try_charge(page, mm, GFP_KERNEL,
> > +						  &memcg)) {
> > +				page_cache_release(page);
> > +				ret = -ENOMEM;
> > +				break;
> > +			}
> > +			/*
> > +			 * We can safely reuse the s_mem/mapping field of page
> > +			 * struct to store the memcg as the page is only seen
> > +			 * by HMM at this point and we can clear it before it
> > +			 * is public see mm_hmm_migrate_back_cleanup().
> > +			 */
> > +			page->s_mem = memcg;
> > +			new_pte[i] = mk_pte(page, vma->vm_page_prot);
> > +			if (vma->vm_flags & VM_WRITE) {
> > +				new_pte[i] = pte_mkdirty(new_pte[i]);
> > +				new_pte[i] = pte_mkwrite(new_pte[i]);
> > +			}
> 
> Why mark it dirty if vm_flags is VM_WRITE ?

It is a left over of some debuging i was doing, i missed it.

> 
> > +		}
> > +
> > +		if (!ret)
> > +			continue;
> > +
> > +		hmm_entry = swp_entry_to_pte(make_hmm_entry());
> > +		ptep = pte_offset_map_lock(mm, pmdp, addr, &ptl);
> 
> 
> Again we loop through the same range ?

Yes but this is the out of memory code path here, ie we have to split the migration
into several pass. So what happen here is we clear the new_pte array for entry we
failed to allocate a page for.

> 
> > +		for (addr = cstart, i = (addr - start) >> PAGE_SHIFT;
> > +		     addr < next; addr += PAGE_SIZE, ptep++, i++) {
> > +			unsigned long pfn = pte_pfn(new_pte[i]);
> > +
> > +			if (!pte_present(new_pte[i]) || !is_zero_pfn(pfn))
> > +				continue;
> 
> 
> What is that checking for ?

If new_pte entry is not present then it is not something we want to migrate. If it
is present but does not point to zero pfn then it is an entry for which we allocated
a page so we want to keep it.

> > +
> > +			set_pte_at(mm, addr, ptep, hmm_entry);
> > +			pte_clear(mm, addr, &new_pte[i]);
> 
> what is that pte_clear for ?. Handling of new_pte needs more code comments.
> 

Entry for which we failed to allocate memory we clear the special HMM swap entry
as well as the new_pte entry so that migration code knows it does not have to do
anything here.

Hopes this clarify this code.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
