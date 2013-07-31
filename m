Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id D8C1F6B0034
	for <linux-mm@kvack.org>; Wed, 31 Jul 2013 01:06:03 -0400 (EDT)
Date: Wed, 31 Jul 2013 14:06:03 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 10/18] mm, hugetlb: call vma_has_reserve() before
 entering alloc_huge_page()
Message-ID: <20130731050603.GI2548@lge.com>
References: <1375075929-6119-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1375075929-6119-11-git-send-email-iamjoonsoo.kim@lge.com>
 <1375122474-w2vygb3x-mutt-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1375122474-w2vygb3x-mutt-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, David Gibson <david@gibson.dropbear.id.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Hillf Danton <dhillf@gmail.com>

On Mon, Jul 29, 2013 at 02:27:54PM -0400, Naoya Horiguchi wrote:
> On Mon, Jul 29, 2013 at 02:32:01PM +0900, Joonsoo Kim wrote:
> > To implement a graceful failure handling, we need to know whether
> > allocation request is for reserved pool or not, on higher level.
> > In this patch, we just move up vma_has_reseve() to caller function
> > in order to know it. There is no functional change.
> > 
> > Following patches implement a grace failure handling and remove
> > a hugetlb_instantiation_mutex.
> > 
> > Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> > 
> > diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> > index a66226e..5f31ca5 100644
> > --- a/mm/hugetlb.c
> > +++ b/mm/hugetlb.c
> > @@ -1123,12 +1123,12 @@ static void vma_commit_reservation(struct hstate *h,
> >  }
> >  
> >  static struct page *alloc_huge_page(struct vm_area_struct *vma,
> > -				    unsigned long addr, int avoid_reserve)
> > +				    unsigned long addr, int use_reserve)
> >  {
> >  	struct hugepage_subpool *spool = subpool_vma(vma);
> >  	struct hstate *h = hstate_vma(vma);
> >  	struct page *page;
> > -	int ret, idx, use_reserve;
> > +	int ret, idx;
> >  	struct hugetlb_cgroup *h_cg;
> >  
> >  	idx = hstate_index(h);
> > @@ -1140,11 +1140,6 @@ static struct page *alloc_huge_page(struct vm_area_struct *vma,
> >  	 * need pages and subpool limit allocated allocated if no reserve
> >  	 * mapping overlaps.
> >  	 */
> > -	use_reserve = vma_has_reserves(h, vma, addr);
> > -	if (use_reserve < 0)
> > -		return ERR_PTR(-ENOMEM);
> > -
> > -	use_reserve = use_reserve && !avoid_reserve;
> >  	if (!use_reserve && (hugepage_subpool_get_pages(spool, 1) < 0))
> >  			return ERR_PTR(-ENOSPC);
> >  
> > @@ -2520,7 +2515,7 @@ static int hugetlb_cow(struct mm_struct *mm, struct vm_area_struct *vma,
> >  {
> >  	struct hstate *h = hstate_vma(vma);
> >  	struct page *old_page, *new_page;
> > -	int outside_reserve = 0;
> > +	int use_reserve, outside_reserve = 0;
> >  	unsigned long mmun_start;	/* For mmu_notifiers */
> >  	unsigned long mmun_end;		/* For mmu_notifiers */
> >  
> > @@ -2553,7 +2548,18 @@ retry_avoidcopy:
> >  
> >  	/* Drop page_table_lock as buddy allocator may be called */
> >  	spin_unlock(&mm->page_table_lock);
> > -	new_page = alloc_huge_page(vma, address, outside_reserve);
> > +
> > +	use_reserve = vma_has_reserves(h, vma, address);
> > +	if (use_reserve == -ENOMEM) {
> > +		page_cache_release(old_page);
> > +
> > +		/* Caller expects lock to be held */
> > +		spin_lock(&mm->page_table_lock);
> > +		return VM_FAULT_OOM;
> > +	}
> > +	use_reserve = use_reserve && !outside_reserve;
> 
> When outside_reserve is true, we don't have to call vma_has_reserves
> because then use_reserve is always false. So something like:
> 
>   use_reserve = 0;
>   if (!outside_reserve) {
>           use_reserve = vma_has_reserves(...);
>           ...
>   }
> 
> looks better to me.
> Or if you expect vma_has_reserves to change resv_map implicitly,
> could you add a comment about it.

Yes, you are right.
I will change it.

Thanks.

> 
> Thanks,
> Naoya Horiguchi
> 
> > +
> > +	new_page = alloc_huge_page(vma, address, use_reserve);
> >  
> >  	if (IS_ERR(new_page)) {
> >  		long err = PTR_ERR(new_page);
> > @@ -2679,6 +2685,7 @@ static int hugetlb_no_page(struct mm_struct *mm, struct vm_area_struct *vma,
> >  	struct page *page;
> >  	struct address_space *mapping;
> >  	pte_t new_pte;
> > +	int use_reserve = 0;
> >  
> >  	/*
> >  	 * Currently, we are forced to kill the process in the event the
> > @@ -2704,7 +2711,14 @@ retry:
> >  		size = i_size_read(mapping->host) >> huge_page_shift(h);
> >  		if (idx >= size)
> >  			goto out;
> > -		page = alloc_huge_page(vma, address, 0);
> > +
> > +		use_reserve = vma_has_reserves(h, vma, address);
> > +		if (use_reserve == -ENOMEM) {
> > +			ret = VM_FAULT_OOM;
> > +			goto out;
> > +		}
> > +
> > +		page = alloc_huge_page(vma, address, use_reserve);
> >  		if (IS_ERR(page)) {
> >  			ret = PTR_ERR(page);
> >  			if (ret == -ENOMEM)
> > -- 
> > 1.7.9.5
> >
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
