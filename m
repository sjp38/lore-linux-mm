Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id 87CF26B005C
	for <linux-mm@kvack.org>; Tue, 27 Aug 2013 03:58:12 -0400 (EDT)
Date: Tue, 27 Aug 2013 16:58:38 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v2 14/20] mm, hugetlb: call vma_needs_reservation before
 entering alloc_huge_page()
Message-ID: <20130827075838.GC6795@lge.com>
References: <1376040398-11212-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1376040398-11212-15-git-send-email-iamjoonsoo.kim@lge.com>
 <87vc2sd15e.fsf@linux.vnet.ibm.com>
 <87mwo4d0p2.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87mwo4d0p2.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, David Gibson <david@gibson.dropbear.id.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <dhillf@gmail.com>

> >> @@ -2504,6 +2498,8 @@ static int hugetlb_cow(struct mm_struct *mm, struct vm_area_struct *vma,
> >>  	struct hstate *h = hstate_vma(vma);
> >>  	struct page *old_page, *new_page;
> >>  	int outside_reserve = 0;
> >> +	long chg;
> >> +	bool use_reserve;
> >>  	unsigned long mmun_start;	/* For mmu_notifiers */
> >>  	unsigned long mmun_end;		/* For mmu_notifiers */
> >>
> >> @@ -2535,7 +2531,17 @@ retry_avoidcopy:
> >>
> >>  	/* Drop page_table_lock as buddy allocator may be called */
> >>  	spin_unlock(&mm->page_table_lock);
> >> -	new_page = alloc_huge_page(vma, address, outside_reserve);
> >> +	chg = vma_needs_reservation(h, vma, address);
> >> +	if (chg == -ENOMEM) {
> >
> > why not 
> >
> >     if (chg < 0) ?
> >
> > Should we try to unmap the page from child and avoid cow here ?. May be
> > with outside_reserve = 1 we will never have vma_needs_reservation fail.
> > Any how it would be nice to document why this error case is different
> > from alloc_huge_page error case.
> >
> 
> I guess patch  16 address this . So if we do if (chg < 0) we are good
> here.

Okay! I will change it.

> 
> Reviewed-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
