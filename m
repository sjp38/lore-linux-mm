Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9C5A56B2990
	for <linux-mm@kvack.org>; Thu, 23 Aug 2018 06:33:58 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id n17-v6so2961430pff.17
        for <linux-mm@kvack.org>; Thu, 23 Aug 2018 03:33:58 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p21-v6si3537501plq.338.2018.08.23.03.33.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Aug 2018 03:33:56 -0700 (PDT)
Date: Thu, 23 Aug 2018 12:33:52 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v3 1/2] mm: migration: fix migration of huge PMD shared
 pages
Message-ID: <20180823103352.GZ29735@dhcp22.suse.cz>
References: <20180821205902.21223-2-mike.kravetz@oracle.com>
 <201808220831.eM0je51n%fengguang.wu@intel.com>
 <975b740d-26a6-eb3f-c8ca-1a9995d0d343@oracle.com>
 <20180822122848.GL29735@dhcp22.suse.cz>
 <4a95a24f-534f-0938-f358-2a410817a412@oracle.com>
 <20180823073035.GT29735@dhcp22.suse.cz>
 <20180823082112.xln7rinqcwt54teg@kshutemo-mobl1>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180823082112.xln7rinqcwt54teg@kshutemo-mobl1>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Mike Kravetz <mike.kravetz@oracle.com>, kbuild test robot <lkp@intel.com>, kbuild-all@01.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Davidlohr Bueso <dave@stgolabs.net>, Andrew Morton <akpm@linux-foundation.org>, stable@vger.kernel.org

On Thu 23-08-18 11:21:12, Kirill A. Shutemov wrote:
> On Thu, Aug 23, 2018 at 09:30:35AM +0200, Michal Hocko wrote:
> > On Wed 22-08-18 09:48:16, Mike Kravetz wrote:
> > > On 08/22/2018 05:28 AM, Michal Hocko wrote:
> > > > On Tue 21-08-18 18:10:42, Mike Kravetz wrote:
> > > > [...]
> > > >> diff --git a/mm/rmap.c b/mm/rmap.c
> > > >> index eb477809a5c0..8cf853a4b093 100644
> > > >> --- a/mm/rmap.c
> > > >> +++ b/mm/rmap.c
> > > >> @@ -1362,11 +1362,21 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
> > > >>  	}
> > > >>  
> > > >>  	/*
> > > >> -	 * We have to assume the worse case ie pmd for invalidation. Note that
> > > >> -	 * the page can not be free in this function as call of try_to_unmap()
> > > >> -	 * must hold a reference on the page.
> > > >> +	 * For THP, we have to assume the worse case ie pmd for invalidation.
> > > >> +	 * For hugetlb, it could be much worse if we need to do pud
> > > >> +	 * invalidation in the case of pmd sharing.
> > > >> +	 *
> > > >> +	 * Note that the page can not be free in this function as call of
> > > >> +	 * try_to_unmap() must hold a reference on the page.
> > > >>  	 */
> > > >>  	end = min(vma->vm_end, start + (PAGE_SIZE << compound_order(page)));
> > > >> +	if (PageHuge(page)) {
> > > >> +		/*
> > > >> +		 * If sharing is possible, start and end will be adjusted
> > > >> +		 * accordingly.
> > > >> +		 */
> > > >> +		(void)huge_pmd_sharing_possible(vma, &start, &end);
> > > >> +	}
> > > >>  	mmu_notifier_invalidate_range_start(vma->vm_mm, start, end);
> > > > 
> > > > I do not get this part. Why don't we simply unconditionally invalidate
> > > > the whole huge page range?
> > > 
> > > In this routine, we are only unmapping a single page.  The existing code
> > > is limiting the invalidate range to that page size: 4K or 2M.  With shared
> > > PMDs, we have the possibility of unmapping a PUD_SIZE area: 1G.  I don't
> > > think we want to unconditionally invalidate 1G.  Is that what you are asking?
> > 
> > But we know that huge_pmd_unshare unmapped a shared pte so we know when
> > to flush 2MB or 1GB. I really do not like how huge_pmd_sharing_possible
> > a) duplicates some checks and b) it updates start/stop out of line.
> 
> My reading on this is that mmu_notifier_invalidate_range_start() has to be
> called from sleepable context on the full range that *can* be invalidated
> before following mmu_notifier_invalidate_range_end().
> 
> In this case huge_pmd_unshare() may unmap aligned PUD_SIZE around the PMD
> page that effectively enlarge range that has to be covered by
> mmu_notifier_invalidate_range_start(). We cannot yet know if there's any
> shared page tables in the range, so we need to go with worst case
> scenario.
> 
> I don't see conceptually better solution than what is proposed.

I was thinking we would just pull PageHuge outside of the
page_vma_mapped_walk. I thought it would look much more straightforward
but I've tried to put something together and it grown into an ugly code
as well. So going the Mike's way might be a better option after all.

-- 
Michal Hocko
SUSE Labs
