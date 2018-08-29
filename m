Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id BFE086B4CF7
	for <linux-mm@kvack.org>; Wed, 29 Aug 2018 14:14:29 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id y54-v6so5298823qta.8
        for <linux-mm@kvack.org>; Wed, 29 Aug 2018 11:14:29 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id u41-v6si4611834qvc.146.2018.08.29.11.14.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Aug 2018 11:14:28 -0700 (PDT)
Date: Wed, 29 Aug 2018 14:14:25 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH v6 1/2] mm: migration: fix migration of huge PMD shared
 pages
Message-ID: <20180829181424.GB3784@redhat.com>
References: <20180823205917.16297-1-mike.kravetz@oracle.com>
 <20180823205917.16297-2-mike.kravetz@oracle.com>
 <20180824084157.GD29735@dhcp22.suse.cz>
 <6063f215-a5c8-2f0c-465a-2c515ddc952d@oracle.com>
 <20180827074645.GB21556@dhcp22.suse.cz>
 <20180827134633.GB3930@redhat.com>
 <9209043d-3240-105b-72a3-b4cd30f1b1f1@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <9209043d-3240-105b-72a3-b4cd30f1b1f1@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Davidlohr Bueso <dave@stgolabs.net>, Andrew Morton <akpm@linux-foundation.org>, stable@vger.kernel.org

On Wed, Aug 29, 2018 at 10:24:44AM -0700, Mike Kravetz wrote:
> On 08/27/2018 06:46 AM, Jerome Glisse wrote:
> > On Mon, Aug 27, 2018 at 09:46:45AM +0200, Michal Hocko wrote:
> >> On Fri 24-08-18 11:08:24, Mike Kravetz wrote:
> >>> Here is an updated patch which does as you suggest above.
> >> [...]
> >>> @@ -1409,6 +1419,32 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
> >>>  		subpage = page - page_to_pfn(page) + pte_pfn(*pvmw.pte);
> >>>  		address = pvmw.address;
> >>>  
> >>> +		if (PageHuge(page)) {
> >>> +			if (huge_pmd_unshare(mm, &address, pvmw.pte)) {
> >>> +				/*
> >>> +				 * huge_pmd_unshare unmapped an entire PMD
> >>> +				 * page.  There is no way of knowing exactly
> >>> +				 * which PMDs may be cached for this mm, so
> >>> +				 * we must flush them all.  start/end were
> >>> +				 * already adjusted above to cover this range.
> >>> +				 */
> >>> +				flush_cache_range(vma, start, end);
> >>> +				flush_tlb_range(vma, start, end);
> >>> +				mmu_notifier_invalidate_range(mm, start, end);
> >>> +
> >>> +				/*
> >>> +				 * The ref count of the PMD page was dropped
> >>> +				 * which is part of the way map counting
> >>> +				 * is done for shared PMDs.  Return 'true'
> >>> +				 * here.  When there is no other sharing,
> >>> +				 * huge_pmd_unshare returns false and we will
> >>> +				 * unmap the actual page and drop map count
> >>> +				 * to zero.
> >>> +				 */
> >>> +				page_vma_mapped_walk_done(&pvmw);
> >>> +				break;
> >>> +			}
> >>
> >> This still calls into notifier while holding the ptl lock. Either I am
> >> missing something or the invalidation is broken in this loop (not also
> >> for other invalidations).
> > 
> > mmu_notifier_invalidate_range() is done with pt lock held only the start
> > and end versions need to happen outside pt lock.
> 
> Hi Jerome (and anyone else having good understanding of mmu notifier API),
> 
> Michal and I have been looking at backports to stable releases.  If you look
> at the v4.4 version of try_to_unmap_one(), it does not use the
> mmu_notifier_invalidate_range_start/end interfaces. Rather, it uses the
> mmu_notifier_invalidate_page(), passing in the address of the page it
> unmapped.  This is done after releasing the ptl lock.  I'm not even sure if
> this works for huge pages, as it appears some THP supporting code was added
> to try_to_unmap_one() after v4.4.
> 
> But, we were wondering what mmu notifier interface to use in the case where
> try_to_unmap_one() unmaps a shared pmd huge page as addressed in the patch
> above.  In this case, a PUD sized area is effectively unmapped.  In the
> code/patch above we have the invalidate range (start and end as well) take
> the PUD sized area into account.
> 
> What would be the best mmu notifier interface to use where there are no
> start/end calls?
> Or, is the best solution to add the start/end calls as is done in later
> versions of the code?  If that is the suggestion, has there been any change
> in invalidate start/end semantics that we should take into account?

start/end would be the one to add, 4.4 seems broken in respect to THP
and mmu notification. Another solution is to fix user of mmu notifier,
they were only a handful back then. For instance properly adjust the
address to match first address covered by pmd or pud and passing down
correct page size to mmu_notifier_invalidate_page() would allow to fix
this easily.

This is ok because user of try_to_unmap_one() replace the pte/pmd/pud
with an invalid one (either poison, migration or swap) inside the
function. So anyone racing would synchronize on those special entry
hence why it is fine to delay mmu_notifier_invalidate_page() to after
dropping the page table lock.

Adding start/end might the solution with less code churn as you would
only need to change try_to_unmap_one().

Cheers,
Jerome
