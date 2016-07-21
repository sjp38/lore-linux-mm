Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id C8D4182963
	for <linux-mm@kvack.org>; Thu, 21 Jul 2016 07:27:58 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id x83so11047401wma.2
        for <linux-mm@kvack.org>; Thu, 21 Jul 2016 04:27:58 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id l70si3860885lfi.21.2016.07.21.04.27.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Jul 2016 04:27:57 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id q128so2166943wma.1
        for <linux-mm@kvack.org>; Thu, 21 Jul 2016 04:27:57 -0700 (PDT)
Date: Thu, 21 Jul 2016 13:27:55 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: + mm-hugetlb-fix-race-when-migrate-pages.patch added to -mm tree
Message-ID: <20160721112754.GH26379@dhcp22.suse.cz>
References: <578eb28b.YbRUDGz5RloTVlrE%akpm@linux-foundation.org>
 <20160721074340.GA26398@dhcp22.suse.cz>
 <5790A9D1.6060304@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5790A9D1.6060304@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhong jiang <zhongjiang@huawei.com>
Cc: akpm@linux-foundation.org, qiuxishi@huawei.com, vbabka@suse.cz, mm-commits@vger.kernel.org, Mike Kravetz <mike.kravetz@oracle.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org

On Thu 21-07-16 18:54:09, zhong jiang wrote:
> On 2016/7/21 15:43, Michal Hocko wrote:
> > We have further discussed the patch and I believe it is not correct. See [1].
> > I am proposing the following alternative.
> >
> > [1] http://lkml.kernel.org/r/20160720132431.GM11249@dhcp22.suse.cz
> > ---
> > >From b1e9b3214f1859fdf7d134cdcb56f5871933539c Mon Sep 17 00:00:00 2001
> > From: Michal Hocko <mhocko@suse.com>
> > Date: Thu, 21 Jul 2016 09:28:13 +0200
> > Subject: [PATCH] mm, hugetlb: fix huge_pte_alloc BUG_ON
> >
> > Zhong Jiang has reported a BUG_ON from huge_pte_alloc hitting when he
> > runs his database load with memory online and offline running in
> > parallel. The reason is that huge_pmd_share might detect a shared pmd
> > which is currently migrated and so it has migration pte which is
> > !pte_huge.
> >
> > There doesn't seem to be any easy way to prevent from the race and in
> > fact seeing the migration swap entry is not harmful. Both callers of
> > huge_pte_alloc are prepared to handle them. copy_hugetlb_page_range
> > will copy the swap entry and make it COW if needed. hugetlb_fault will
> > back off and so the page fault is retries if the page is still under
> > migration and waits for its completion in hugetlb_fault.
> >
> > That means that the BUG_ON is wrong and we should update it. Let's
> > simply check that all present ptes are pte_huge instead.
> >
> > Reported-by: zhongjiang <zhongjiang@huawei.com>
> > Signed-off-by: Michal Hocko <mhocko@suse.com>
> > ---
> >  mm/hugetlb.c | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> >
> > diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> > index 34379d653aa3..31dd2b8b86b3 100644
> > --- a/mm/hugetlb.c
> > +++ b/mm/hugetlb.c
> > @@ -4303,7 +4303,7 @@ pte_t *huge_pte_alloc(struct mm_struct *mm,
> >  				pte = (pte_t *)pmd_alloc(mm, pud, addr);
> >  		}
> >  	}
> > -	BUG_ON(pte && !pte_none(*pte) && !pte_huge(*pte));
> > +	BUG_ON(pte && pte_present(*pte) && !pte_huge(*pte));
> >  
> >  	return pte;
> >  }
>
>   I don't think that the patch can fix the question.   The explain is as follow.
> 
>                cpu0                                                                                      cpu1
> copy_hugetlb_page_range                                                       try_to_unmap_one
>              huge_pte_alloc  #pmd may be shared                           
>              lock dst_pte     #dst_pte may be migrate                    
>             lock src_pte     #src_pte may be normal pt1       
>            set_huge_pte_at    #dst_pte points to normal
>            spin_unlock (src_pt1)
>                                                                                                           lock src_pte
>            spin_unlock(dst_pt1)                                                          set src_pte migrate entry
>                                                                                                          spin_unlock(src_pte)
>    *       dst_pte is a normal pte, but corresponding to the
>             pfn is under migrate.  it is dangerous.
> 
> The race may occur. is right ?  if the scenario exist.  we should think about more.

Can this happen at all? copy_hugetlb_page_range does the following to
rule out shared page table entries. At least that is my understanding of
c5c99429fa57 ("fix hugepages leak due to pagetable page sharing")

		/* If the pagetables are shared don't copy or take references */
		if (dst_pte == src_pte)
			continue;
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
