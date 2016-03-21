Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f169.google.com (mail-ob0-f169.google.com [209.85.214.169])
	by kanga.kvack.org (Postfix) with ESMTP id D39FB6B0253
	for <linux-mm@kvack.org>; Mon, 21 Mar 2016 10:31:09 -0400 (EDT)
Received: by mail-ob0-f169.google.com with SMTP id ts10so176001175obc.1
        for <linux-mm@kvack.org>; Mon, 21 Mar 2016 07:31:09 -0700 (PDT)
Received: from mail-qg0-x244.google.com (mail-qg0-x244.google.com. [2607:f8b0:400d:c04::244])
        by mx.google.com with ESMTPS id l63si14568586oib.16.2016.03.21.07.31.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Mar 2016 07:31:09 -0700 (PDT)
Received: by mail-qg0-x244.google.com with SMTP id j92so11211984qgj.1
        for <linux-mm@kvack.org>; Mon, 21 Mar 2016 07:31:09 -0700 (PDT)
Date: Mon, 21 Mar 2016 15:30:59 +0100
From: Jerome Glisse <j.glisse@gmail.com>
Subject: Re: [PATCH v12 21/29] HMM: mm add helper to update page table when
 migrating memory back v2.
Message-ID: <20160321143058.GB4518@gmail.com>
References: <1457469802-11850-1-git-send-email-jglisse@redhat.com>
 <1457469802-11850-22-git-send-email-jglisse@redhat.com>
 <877fgwul3v.fsf@linux.vnet.ibm.com>
 <20160321120251.GA4518@gmail.com>
 <871t74uekm.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <871t74uekm.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, joro@8bytes.org, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Christophe Harle <charle@nvidia.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Haggai Eran <haggaie@mellanox.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Leonid Shamis <Leonid.Shamis@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>

On Mon, Mar 21, 2016 at 07:18:41PM +0530, Aneesh Kumar K.V wrote:
> Jerome Glisse <j.glisse@gmail.com> writes:
> > [ text/plain ]
> > On Mon, Mar 21, 2016 at 04:57:32PM +0530, Aneesh Kumar K.V wrote:
> >> Jerome Glisse <jglisse@redhat.com> writes:

[...]

> >> > +		ptep = pte_offset_map_lock(mm, pmdp, addr, &ptl);
> >> > +		for (cstart = addr, i = (addr - start) >> PAGE_SHIFT,
> >> > +		     next = min((addr + PMD_SIZE) & PMD_MASK, end);
> >> > +		     addr < next; addr += PAGE_SIZE, ptep++, i++) {
> >> > +			swp_entry_t entry;
> >> > +
> >> > +			entry = pte_to_swp_entry(*ptep);
> >> > +			if (pte_none(*ptep) || pte_present(*ptep) ||
> >> > +			    !is_hmm_entry(entry) ||
> >> > +			    is_hmm_entry_locked(entry))
> >> > +				continue;
> >> > +
> >> > +			set_pte_at(mm, addr, ptep, hmm_entry);
> >> > +			new_pte[i] = pte_mkspecial(pfn_pte(my_zero_pfn(addr),
> >> > +						   vma->vm_page_prot));
> >> > +		}
> >> > +		pte_unmap_unlock(ptep - 1, ptl);
> >> 
> >> 
> >> I guess this is fixing all the ptes in the cpu page table mapping a pmd
> >> entry. But then what is below ?
> >
> > Because we are dealing with special swap entry we know we can not have huge pages.
> > So we only care about HMM special swap entry. We record entry we want to migrate
> > in the new_pte array. The loop above is under pmd spin lock, the loop below does
> > memory allocation and we do not want to hold any spin lock while doing allocation.
> >
> 
> Can this go as code comment ?

Yes of course, i should have added more comment in first place.


> >> > +
> >> > +		for (addr = cstart, i = (addr - start) >> PAGE_SHIFT;
> >> > +		     addr < next; addr += PAGE_SIZE, i++) {
> >> 
> >> Your use of vairable addr with multiple loops updating then is also
> >> making it complex. We should definitely add more comments here. I guess
> >> we are going through the same range we iterated above here.
> >
> > Correct we are going over the exact same range, i am keeping the addr only
> > for alloc_zeroed_user_highpage_movable() purpose.
> >
> 
> Can we use a different variable name there ?

If you have suggestion for name ? I am just lacking imagination but i can use
a different name like vaddr.


> >> > +			struct mem_cgroup *memcg;
> >> > +			struct page *page;
> >> > +
> >> > +			if (!pte_present(new_pte[i]))
> >> > +				continue;
> >> 
> >> What is that checking for ?. We set that using pte_mkspecial above ?
> >
> > Not all entry in the range might match the criteria (ie special unlocked HMM swap
> > entry). We want to allocate pages only for entry that match the criteria.
> >
> 
> Since we did in the beginning, 
> 	memset(new_pte, 0, sizeof(pte_t) * ((end - start) >> PAGE_SHIFT));
> 
> we should not find present bit set ? using present there is confusing,
> may be pte_none(). Also with comments around explaining the details ?

Yes pte_none() will works too, i will use that and add comments.


> >> > +			page = alloc_zeroed_user_highpage_movable(vma, addr);
> >> > +			if (!page) {
> >> > +				ret = -ENOMEM;
> >> > +				break;
> >> > +			}
> >> > +			__SetPageUptodate(page);
> >> > +			if (mem_cgroup_try_charge(page, mm, GFP_KERNEL,
> >> > +						  &memcg)) {
> >> > +				page_cache_release(page);
> >> > +				ret = -ENOMEM;
> >> > +				break;
> >> > +			}
> >> > +			/*
> >> > +			 * We can safely reuse the s_mem/mapping field of page
> >> > +			 * struct to store the memcg as the page is only seen
> >> > +			 * by HMM at this point and we can clear it before it
> >> > +			 * is public see mm_hmm_migrate_back_cleanup().
> >> > +			 */
> >> > +			page->s_mem = memcg;
> >> > +			new_pte[i] = mk_pte(page, vma->vm_page_prot);
> >> > +			if (vma->vm_flags & VM_WRITE) {
> >> > +				new_pte[i] = pte_mkdirty(new_pte[i]);
> >> > +				new_pte[i] = pte_mkwrite(new_pte[i]);
> >> > +			}
> >> 
> >> Why mark it dirty if vm_flags is VM_WRITE ?
> >
> > It is a left over of some debuging i was doing, i missed it.

I actually remember why i set the dirty bit, i wanted to change the driver
API to have driver clear the dirty bit if they did not write instead on
relying on them to set it if they did. I thought it was a safer to cope with
potentialy buggy driver. I might update patchset to do that.

[...]

> >> > +		for (addr = cstart, i = (addr - start) >> PAGE_SHIFT;
> >> > +		     addr < next; addr += PAGE_SIZE, ptep++, i++) {
> >> > +			unsigned long pfn = pte_pfn(new_pte[i]);
> >> > +
> >> > +			if (!pte_present(new_pte[i]) || !is_zero_pfn(pfn))
> >> > +				continue;
> >> 
> 
> So here we are using the fact that we had set new pte using zero pfn in
> the firs loop and hence if we find a present new_pte with zero pfn, it implies we
> failed to allocate a page for that ?

Yes that's correct. I could use a another pte flag instead on relying on zero
pfn.

[...]

> >> > +
> >> > +			set_pte_at(mm, addr, ptep, hmm_entry);
> >> > +			pte_clear(mm, addr, &new_pte[i]);
> >> 
> >> what is that pte_clear for ?. Handling of new_pte needs more code comments.
> >> 
> >
> > Entry for which we failed to allocate memory we clear the special HMM swap entry
> > as well as the new_pte entry so that migration code knows it does not have to do
> > anything here.
> >
> 
> So that pte_clear is not expecting to do any sort of tlb flushes etc ? The
> idea is to put new_pte = 0 ?.  

Correct, no tlb flushing needed, new_pte is a private array use only during
migration and never expose to outside world. I will change to new_pte[i] = 0
instead.


> 
> Can we do all those conditionals without using pte bits ? A check like
> pte_present, is_zero_pfn etc confuse the reader. Instead can
> we do
> 
> if (pte_state[i] == SKIP_LOOP_FIRST)
> 
> if (pte_state[i] == SKIP_LOOP_SECOND)
> 
> I understand that we want to return new_pte array with valid pages, so
> may be the above will make code complex, but atleast code should have
> more comments explaining each step

Well another point of new_pte is that we can directly use the new_pte
value to update the CPU page table in the final migration step. But i
can define some HMM_PTE_MIGRATE, HMM_PTE_RESTORE as alias of existing pte
flag and they will be clear along the way depending on outcomes of each
step.

Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
