Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id 288D26B0034
	for <linux-mm@kvack.org>; Wed, 31 Jul 2013 01:21:29 -0400 (EDT)
Date: Wed, 31 Jul 2013 14:21:28 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 16/18] mm, hugetlb: return a reserved page to a reserved
 pool if failed
Message-ID: <20130731052128.GL2548@lge.com>
References: <1375075929-6119-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1375075929-6119-17-git-send-email-iamjoonsoo.kim@lge.com>
 <1375129150-ksnu6mr9-mutt-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1375129150-ksnu6mr9-mutt-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, David Gibson <david@gibson.dropbear.id.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Hillf Danton <dhillf@gmail.com>

On Mon, Jul 29, 2013 at 04:19:10PM -0400, Naoya Horiguchi wrote:
> On Mon, Jul 29, 2013 at 02:32:07PM +0900, Joonsoo Kim wrote:
> > If we fail with a reserved page, just calling put_page() is not sufficient,
> > because put_page() invoke free_huge_page() at last step and it doesn't
> > know whether a page comes from a reserved pool or not. So it doesn't do
> > anything related to reserved count. This makes reserve count lower
> > than how we need, because reserve count already decrease in
> > dequeue_huge_page_vma(). This patch fix this situation.
> 
> I think we could use a page flag (for example PG_reserve) on a hugepage
> in order to record that the hugepage comes from the reserved pool.
> Furthermore, the reserve flag would be set when dequeueing a free hugepage,
> and cleared when hugepage_fault returns, whether it fails or not.
> I think it's simpler than put_page variant approach, but doesn't it work
> to solve your problem?

Yes. That's good idea.
I thought this idea before, but didn't implement that way, because
I was worry that this may make patchset more larger and complex. But
implementing that way may be better.

Thanks.

> 
> Thanks,
> Naoya Horiguchi
> 
> > Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> > 
> > diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> > index bb8a45f..6a9ec69 100644
> > --- a/mm/hugetlb.c
> > +++ b/mm/hugetlb.c
> > @@ -649,6 +649,34 @@ struct hstate *size_to_hstate(unsigned long size)
> >  	return NULL;
> >  }
> >  
> > +static void put_huge_page(struct page *page, int use_reserve)
> > +{
> > +	struct hstate *h = page_hstate(page);
> > +	struct hugepage_subpool *spool =
> > +		(struct hugepage_subpool *)page_private(page);
> > +
> > +	if (!use_reserve) {
> > +		put_page(page);
> > +		return;
> > +	}
> > +
> > +	if (!put_page_testzero(page))
> > +		return;
> > +
> > +	set_page_private(page, 0);
> > +	page->mapping = NULL;
> > +	BUG_ON(page_count(page));
> > +	BUG_ON(page_mapcount(page));
> > +
> > +	spin_lock(&hugetlb_lock);
> > +	hugetlb_cgroup_uncharge_page(hstate_index(h),
> > +				     pages_per_huge_page(h), page);
> > +	enqueue_huge_page(h, page);
> > +	h->resv_huge_pages++;
> > +	spin_unlock(&hugetlb_lock);
> > +	hugepage_subpool_put_pages(spool, 1);
> > +}
> > +
> >  static void free_huge_page(struct page *page)
> >  {
> >  	/*
> > @@ -2625,7 +2653,7 @@ retry_avoidcopy:
> >  	spin_unlock(&mm->page_table_lock);
> >  	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
> >  
> > -	page_cache_release(new_page);
> > +	put_huge_page(new_page, use_reserve);
> >  out_old_page:
> >  	page_cache_release(old_page);
> >  out_lock:
> > @@ -2725,7 +2753,7 @@ retry:
> >  
> >  			err = add_to_page_cache(page, mapping, idx, GFP_KERNEL);
> >  			if (err) {
> > -				put_page(page);
> > +				put_huge_page(page, use_reserve);
> >  				if (err == -EEXIST)
> >  					goto retry;
> >  				goto out;
> > @@ -2798,7 +2826,7 @@ backout:
> >  	spin_unlock(&mm->page_table_lock);
> >  backout_unlocked:
> >  	unlock_page(page);
> > -	put_page(page);
> > +	put_huge_page(page, use_reserve);
> >  	goto out;
> >  }
> >  
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
