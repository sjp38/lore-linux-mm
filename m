Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id 079206B0034
	for <linux-mm@kvack.org>; Wed, 31 Jul 2013 01:08:24 -0400 (EDT)
Date: Wed, 31 Jul 2013 14:08:24 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 11/18] mm, hugetlb: move down outside_reserve check
Message-ID: <20130731050824.GJ2548@lge.com>
References: <1375075929-6119-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1375075929-6119-12-git-send-email-iamjoonsoo.kim@lge.com>
 <1375123170-v27s5zvu-mutt-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1375123170-v27s5zvu-mutt-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, David Gibson <david@gibson.dropbear.id.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Hillf Danton <dhillf@gmail.com>

On Mon, Jul 29, 2013 at 02:39:30PM -0400, Naoya Horiguchi wrote:
> On Mon, Jul 29, 2013 at 02:32:02PM +0900, Joonsoo Kim wrote:
> > Just move down outsider_reserve check.
> > This makes code more readable.
> > 
> > There is no functional change.
> 
> Why don't you do this in 10/18?

Just help to review :)
Step-by-step approach may help to review, so I decide to be separate it.
If you don't want it, I will merge it in next spin.

Thanks.

> 
> Thanks,
> Naoya Horiguchi
> 
> > Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> > 
> > diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> > index 5f31ca5..94173e0 100644
> > --- a/mm/hugetlb.c
> > +++ b/mm/hugetlb.c
> > @@ -2530,20 +2530,6 @@ retry_avoidcopy:
> >  		return 0;
> >  	}
> >  
> > -	/*
> > -	 * If the process that created a MAP_PRIVATE mapping is about to
> > -	 * perform a COW due to a shared page count, attempt to satisfy
> > -	 * the allocation without using the existing reserves. The pagecache
> > -	 * page is used to determine if the reserve at this address was
> > -	 * consumed or not. If reserves were used, a partial faulted mapping
> > -	 * at the time of fork() could consume its reserves on COW instead
> > -	 * of the full address range.
> > -	 */
> > -	if (!(vma->vm_flags & VM_MAYSHARE) &&
> > -			is_vma_resv_set(vma, HPAGE_RESV_OWNER) &&
> > -			old_page != pagecache_page)
> > -		outside_reserve = 1;
> > -
> >  	page_cache_get(old_page);
> >  
> >  	/* Drop page_table_lock as buddy allocator may be called */
> > @@ -2557,6 +2543,20 @@ retry_avoidcopy:
> >  		spin_lock(&mm->page_table_lock);
> >  		return VM_FAULT_OOM;
> >  	}
> > +
> > +	/*
> > +	 * If the process that created a MAP_PRIVATE mapping is about to
> > +	 * perform a COW due to a shared page count, attempt to satisfy
> > +	 * the allocation without using the existing reserves. The pagecache
> > +	 * page is used to determine if the reserve at this address was
> > +	 * consumed or not. If reserves were used, a partial faulted mapping
> > +	 * at the time of fork() could consume its reserves on COW instead
> > +	 * of the full address range.
> > +	 */
> > +	if (!(vma->vm_flags & VM_MAYSHARE) &&
> > +			is_vma_resv_set(vma, HPAGE_RESV_OWNER) &&
> > +			old_page != pagecache_page)
> > +		outside_reserve = 1;
> >  	use_reserve = use_reserve && !outside_reserve;
> >  
> >  	new_page = alloc_huge_page(vma, address, use_reserve);
> > -- 
> > 1.7.9.5
> > 
> > --
> > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > the body to majordomo@kvack.org.  For more info on Linux MM,
> > see: http://www.linux-mm.org/ .
> > Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
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
