Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id E80EB6B3D25
	for <linux-mm@kvack.org>; Mon, 27 Aug 2018 09:46:37 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id u45-v6so15373098qte.12
        for <linux-mm@kvack.org>; Mon, 27 Aug 2018 06:46:37 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id t23-v6si5847820qtt.278.2018.08.27.06.46.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Aug 2018 06:46:37 -0700 (PDT)
Date: Mon, 27 Aug 2018 09:46:33 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH v6 1/2] mm: migration: fix migration of huge PMD shared
 pages
Message-ID: <20180827134633.GB3930@redhat.com>
References: <20180823205917.16297-1-mike.kravetz@oracle.com>
 <20180823205917.16297-2-mike.kravetz@oracle.com>
 <20180824084157.GD29735@dhcp22.suse.cz>
 <6063f215-a5c8-2f0c-465a-2c515ddc952d@oracle.com>
 <20180827074645.GB21556@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20180827074645.GB21556@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Mike Kravetz <mike.kravetz@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Davidlohr Bueso <dave@stgolabs.net>, Andrew Morton <akpm@linux-foundation.org>, stable@vger.kernel.org

On Mon, Aug 27, 2018 at 09:46:45AM +0200, Michal Hocko wrote:
> On Fri 24-08-18 11:08:24, Mike Kravetz wrote:
> > On 08/24/2018 01:41 AM, Michal Hocko wrote:
> > > On Thu 23-08-18 13:59:16, Mike Kravetz wrote:
> > > 
> > > Acked-by: Michal Hocko <mhocko@suse.com>
> > > 
> > > One nit below.
> > > 
> > > [...]
> > >> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> > >> index 3103099f64fd..a73c5728e961 100644
> > >> --- a/mm/hugetlb.c
> > >> +++ b/mm/hugetlb.c
> > >> @@ -4548,6 +4548,9 @@ static unsigned long page_table_shareable(struct vm_area_struct *svma,
> > >>  	return saddr;
> > >>  }
> > >>  
> > >> +#define _range_in_vma(vma, start, end) \
> > >> +	((vma)->vm_start <= (start) && (end) <= (vma)->vm_end)
> > >> +
> > > 
> > > static inline please. Macros and potential side effects on given
> > > arguments are just not worth the risk. I also think this is something
> > > for more general use. We have that pattern at many places. So I would
> > > stick that to linux/mm.h
> > 
> > Thanks Michal,
> > 
> > Here is an updated patch which does as you suggest above.
> [...]
> > @@ -1409,6 +1419,32 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
> >  		subpage = page - page_to_pfn(page) + pte_pfn(*pvmw.pte);
> >  		address = pvmw.address;
> >  
> > +		if (PageHuge(page)) {
> > +			if (huge_pmd_unshare(mm, &address, pvmw.pte)) {
> > +				/*
> > +				 * huge_pmd_unshare unmapped an entire PMD
> > +				 * page.  There is no way of knowing exactly
> > +				 * which PMDs may be cached for this mm, so
> > +				 * we must flush them all.  start/end were
> > +				 * already adjusted above to cover this range.
> > +				 */
> > +				flush_cache_range(vma, start, end);
> > +				flush_tlb_range(vma, start, end);
> > +				mmu_notifier_invalidate_range(mm, start, end);
> > +
> > +				/*
> > +				 * The ref count of the PMD page was dropped
> > +				 * which is part of the way map counting
> > +				 * is done for shared PMDs.  Return 'true'
> > +				 * here.  When there is no other sharing,
> > +				 * huge_pmd_unshare returns false and we will
> > +				 * unmap the actual page and drop map count
> > +				 * to zero.
> > +				 */
> > +				page_vma_mapped_walk_done(&pvmw);
> > +				break;
> > +			}
> 
> This still calls into notifier while holding the ptl lock. Either I am
> missing something or the invalidation is broken in this loop (not also
> for other invalidations).

mmu_notifier_invalidate_range() is done with pt lock held only the start
and end versions need to happen outside pt lock.

Cheers,
Jerome
