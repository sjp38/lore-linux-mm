Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id 71FA16B0034
	for <linux-mm@kvack.org>; Wed, 31 Jul 2013 01:12:22 -0400 (EDT)
Date: Wed, 31 Jul 2013 14:12:21 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 15/18] mm, hugetlb: move up anon_vma_prepare()
Message-ID: <20130731051221.GK2548@lge.com>
References: <1375075929-6119-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1375075929-6119-16-git-send-email-iamjoonsoo.kim@lge.com>
 <1375124737-9w10y4c4-mutt-n-horiguchi@ah.jp.nec.com>
 <1375125555-yuwxqz39-mutt-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1375125555-yuwxqz39-mutt-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, David Gibson <david@gibson.dropbear.id.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Hillf Danton <dhillf@gmail.com>

On Mon, Jul 29, 2013 at 03:19:15PM -0400, Naoya Horiguchi wrote:
> On Mon, Jul 29, 2013 at 03:05:37PM -0400, Naoya Horiguchi wrote:
> > On Mon, Jul 29, 2013 at 02:32:06PM +0900, Joonsoo Kim wrote:
> > > If we fail with a allocated hugepage, it is hard to recover properly.
> > > One such example is reserve count. We don't have any method to recover
> > > reserve count. Although, I will introduce a function to recover reserve
> > > count in following patch, it is better not to allocate a hugepage
> > > as much as possible. So move up anon_vma_prepare() which can be failed
> > > in OOM situation.
> > > 
> > > Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> > 
> > Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> 
> Sorry, let me suspend this Reviewed for a question.
> If alloc_huge_page failed after we succeeded anon_vma_parepare,
> the allocated anon_vma_chain and/or anon_vma are safely freed?
> Or don't we have to free them?

Yes, it will be freed by free_pgtables() and then unlink_anon_vmas()
when a task terminate. So, we don't have to free them.

Thanks.

> 
> Thanks,
> Naoya Horiguchi
> 
> > > diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> > > index 683fd38..bb8a45f 100644
> > > --- a/mm/hugetlb.c
> > > +++ b/mm/hugetlb.c
> > > @@ -2536,6 +2536,15 @@ retry_avoidcopy:
> > >  	/* Drop page_table_lock as buddy allocator may be called */
> > >  	spin_unlock(&mm->page_table_lock);
> > >  
> > > +	/*
> > > +	 * When the original hugepage is shared one, it does not have
> > > +	 * anon_vma prepared.
> > > +	 */
> > > +	if (unlikely(anon_vma_prepare(vma))) {
> > > +		ret = VM_FAULT_OOM;
> > > +		goto out_old_page;
> > > +	}
> > > +
> > >  	use_reserve = vma_has_reserves(h, vma, address);
> > >  	if (use_reserve == -ENOMEM) {
> > >  		ret = VM_FAULT_OOM;
> > > @@ -2590,15 +2599,6 @@ retry_avoidcopy:
> > >  		goto out_lock;
> > >  	}
> > >  
> > > -	/*
> > > -	 * When the original hugepage is shared one, it does not have
> > > -	 * anon_vma prepared.
> > > -	 */
> > > -	if (unlikely(anon_vma_prepare(vma))) {
> > > -		ret = VM_FAULT_OOM;
> > > -		goto out_new_page;
> > > -	}
> > > -
> > >  	copy_user_huge_page(new_page, old_page, address, vma,
> > >  			    pages_per_huge_page(h));
> > >  	__SetPageUptodate(new_page);
> > > @@ -2625,7 +2625,6 @@ retry_avoidcopy:
> > >  	spin_unlock(&mm->page_table_lock);
> > >  	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
> > >  
> > > -out_new_page:
> > >  	page_cache_release(new_page);
> > >  out_old_page:
> > >  	page_cache_release(old_page);
> > > -- 
> > > 1.7.9.5
> > > 
> > > --
> > > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > > the body to majordomo@kvack.org.  For more info on Linux MM,
> > > see: http://www.linux-mm.org/ .
> > > Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> > >
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
