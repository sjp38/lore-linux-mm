Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 3D3DC280254
	for <linux-mm@kvack.org>; Fri,  3 Jul 2015 00:21:41 -0400 (EDT)
Received: by pacws9 with SMTP id ws9so51651147pac.0
        for <linux-mm@kvack.org>; Thu, 02 Jul 2015 21:21:40 -0700 (PDT)
Received: from out21.biz.mail.alibaba.com (out21.biz.mail.alibaba.com. [205.204.114.132])
        by mx.google.com with ESMTP id y13si12370789pdi.119.2015.07.02.21.21.38
        for <linux-mm@kvack.org>;
        Thu, 02 Jul 2015 21:21:39 -0700 (PDT)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <1435851526-4200-1-git-send-email-mike.kravetz@oracle.com> <1435851526-4200-2-git-send-email-mike.kravetz@oracle.com>
In-Reply-To: <1435851526-4200-2-git-send-email-mike.kravetz@oracle.com>
Subject: Re: [PATCH 01/10] mm/hugetlb: add cache of descriptors to resv_map for region_add
Date: Fri, 03 Jul 2015 12:21:18 +0800
Message-ID: <008301d0b547$b62a10e0$227e32a0$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Mike Kravetz' <mike.kravetz@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org
Cc: 'Dave Hansen' <dave.hansen@linux.intel.com>, 'Naoya Horiguchi' <n-horiguchi@ah.jp.nec.com>, 'David Rientjes' <rientjes@google.com>, 'Hugh Dickins' <hughd@google.com>, 'Davidlohr Bueso' <dave@stgolabs.net>, 'Aneesh Kumar' <aneesh.kumar@linux.vnet.ibm.com>, 'Christoph Hellwig' <hch@infradead.org>

> 
> fallocate hole punch will want to remove a specific range of
> pages.  When pages are removed, their associated entries in
> the region/reserve map will also be removed.  This will break
> an assumption in the region_chg/region_add calling sequence.
> If a new region descriptor must be allocated, it is done as
> part of the region_chg processing.  In this way, region_add
> can not fail because it does not need to attempt an allocation.
> 
> To prepare for fallocate hole punch, create a "cache" of
> descriptors that can be used by region_add if necessary.
> region_chg will ensure there are sufficient entries in the
> cache.  It will be necessary to track the number of in progress
> add operations to know a sufficient number of descriptors
> reside in the cache.  A new routine region_abort is added to
> adjust this in progress count when add operations are aborted.
> vma_abort_reservation is also added for callers creating
> reservations with vma_needs_reservation/vma_commit_reservation.
> 
> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
> ---
>  include/linux/hugetlb.h |   3 +
>  mm/hugetlb.c            | 166 ++++++++++++++++++++++++++++++++++++++++++------
>  2 files changed, 150 insertions(+), 19 deletions(-)
> 
> diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
> index 2050261..f9c8cb2 100644
> --- a/include/linux/hugetlb.h
> +++ b/include/linux/hugetlb.h
> @@ -35,6 +35,9 @@ struct resv_map {
>  	struct kref refs;
>  	spinlock_t lock;
>  	struct list_head regions;
> +	long adds_in_progress;
> +	struct list_head rgn_cache;
> +	long rgn_cache_count;
>  };
>  extern struct resv_map *resv_map_alloc(void);
>  void resv_map_release(struct kref *ref);
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index a8c3087..189c0d7 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -240,11 +240,14 @@ struct file_region {
> 
>  /*
>   * Add the huge page range represented by [f, t) to the reserve
> - * map.  Existing regions will be expanded to accommodate the
> - * specified range.  We know only existing regions need to be
> - * expanded, because region_add is only called after region_chg
> - * with the same range.  If a new file_region structure must
> - * be allocated, it is done in region_chg.
> + * map.  In the normal case, existing regions will be expanded
> + * to accommodate the specified range.  Sufficient regions should
> + * exist for expansion due to the previous call to region_chg
> + * with the same range.  However, it is possible that region_del
> + * could have been called after region_chg and modifed the map
> + * in such a way that no region exists to be expanded.  In this
> + * case, pull a region descriptor from the cache associated with
> + * the map and use that for the new range.
>   *
>   * Return the number of new huge pages added to the map.  This
>   * number is greater than or equal to zero.
> @@ -261,6 +264,27 @@ static long region_add(struct resv_map *resv, long f, long t)
>  		if (f <= rg->to)
>  			break;
> 
> +	if (&rg->link == head || t < rg->from) {
> +		/*
> +		 * No region exits which can be expanded to include the

s/exits/exists/ ?
> +		 * specified range.  Pull a region descriptor from the
> +		 * cache, and use it for this range.
> +		 */
> +		VM_BUG_ON(!resv->rgn_cache_count);
> +
> +		resv->rgn_cache_count--;
> +		nrg = list_first_entry(&resv->rgn_cache, struct file_region,
> +					link);
> +		list_del(&nrg->link);
> +
> +		nrg->from = f;
> +		nrg->to = t;
> +		list_add(&nrg->link, rg->link.prev);
> +
> +		add += t - f;
> +		goto out_locked;
> +	}
> +
>  	/* Round our left edge to the current segment if it encloses us. */
>  	if (f > rg->from)
>  		f = rg->from;
> @@ -294,6 +318,8 @@ static long region_add(struct resv_map *resv, long f, long t)
>  	add += t - nrg->to;		/* Added to end of region */
>  	nrg->to = t;
> 
> +out_locked:
> +	resv->adds_in_progress--;
>  	spin_unlock(&resv->lock);
>  	VM_BUG_ON(add < 0);
>  	return add;
> @@ -312,11 +338,16 @@ static long region_add(struct resv_map *resv, long f, long t)
>   * so that the subsequent region_add call will have all the
>   * regions it needs and will not fail.
>   *
> + * Upon entry, region_chg will also examine the cache of
> + * region descriptors associated with the map.  If there
> + * not enough descriptors cached, one will be allocated
> + * for the in progress add operation.
> + *
>   * Returns the number of huge pages that need to be added
>   * to the existing reservation map for the range [f, t).
>   * This number is greater or equal to zero.  -ENOMEM is
> - * returned if a new file_region structure is needed and can
> - * not be allocated.
> + * returned if a new file_region structure or cache entry
> + * is needed and can not be allocated.
>   */
>  static long region_chg(struct resv_map *resv, long f, long t)
>  {
> @@ -326,6 +357,30 @@ static long region_chg(struct resv_map *resv, long f, long t)
> 
>  retry:
>  	spin_lock(&resv->lock);
> +	resv->adds_in_progress++;
> +
> +	/*
> +	 * Check for sufficient descriptors in the cache to accommodate
> +	 * the number of in progress add operations.
> +	 */
> +	if (resv->adds_in_progress > resv->rgn_cache_count) {
> +		struct file_region *trg;
> +
> +		VM_BUG_ON(resv->adds_in_progress - resv->rgn_cache_count > 1);
> +		/* Must drop lock to allocate a new descriptor. */
> +		resv->adds_in_progress--;
> +		spin_unlock(&resv->lock);
> +
> +		trg = kmalloc(sizeof(*trg), GFP_KERNEL);
> +		if (!trg)
> +			return -ENOMEM;
> +
> +		spin_lock(&resv->lock);
> +		resv->adds_in_progress++;
> +		list_add(&trg->link, &resv->rgn_cache);
> +		resv->rgn_cache_count++;
> +	}
> +
>  	/* Locate the region we are before or in. */
>  	list_for_each_entry(rg, head, link)
>  		if (f <= rg->to)
> @@ -336,6 +391,7 @@ retry:
>  	 * size such that we can guarantee to record the reservation. */
>  	if (&rg->link == head || t < rg->from) {
>  		if (!nrg) {
> +			resv->adds_in_progress--;
>  			spin_unlock(&resv->lock);
>  			nrg = kmalloc(sizeof(*nrg), GFP_KERNEL);
>  			if (!nrg)
> @@ -385,6 +441,25 @@ out_nrg:
>  }
> 
>  /*
> + * Abort the in progress add operation.  The adds_in_progress field
> + * of the resv_map keeps track of the operations in progress between
> + * calls to region_chg and region_add.  Operations are sometimes
> + * aborted after the call to region_chg.  In such cases, region_abort
> + * is called to decrement the adds_in_progress counter.
> + *
> + * NOTE: The range arguments [f, t) are not needed or used in this
> + * routine.  They are kept to make reading the calling code easier as
> + * arguments will match the associated region_chg call.
> + */
> +static void region_abort(struct resv_map *resv, long f, long t)
> +{
> +	spin_lock(&resv->lock);
> +	VM_BUG_ON(!resv->rgn_cache_count);
> +	resv->adds_in_progress--;
> +	spin_unlock(&resv->lock);
> +}
> +
> +/*
>   * Truncate the reserve map at index 'end'.  Modify/truncate any
>   * region which contains end.  Delete any regions past end.
>   * Return the number of huge pages removed from the map.
> @@ -544,22 +619,42 @@ static void set_vma_private_data(struct vm_area_struct *vma,
>  struct resv_map *resv_map_alloc(void)
>  {
>  	struct resv_map *resv_map = kmalloc(sizeof(*resv_map), GFP_KERNEL);
> -	if (!resv_map)
> +	struct file_region *rg = kmalloc(sizeof(*rg), GFP_KERNEL);
> +
> +	if (!resv_map || !rg) {
> +		kfree(resv_map);
> +		kfree(rg);
>  		return NULL;
> +	}
> 
>  	kref_init(&resv_map->refs);
>  	spin_lock_init(&resv_map->lock);
>  	INIT_LIST_HEAD(&resv_map->regions);
> 
> +	resv_map->adds_in_progress = 0;
> +
> +	INIT_LIST_HEAD(&resv_map->rgn_cache);
> +	list_add(&rg->link, &resv_map->rgn_cache);
> +	resv_map->rgn_cache_count = 1;
> +
>  	return resv_map;
>  }
> 
>  void resv_map_release(struct kref *ref)
>  {
>  	struct resv_map *resv_map = container_of(ref, struct resv_map, refs);
> +	struct list_head *head = &resv_map->regions;
> +	struct file_region *rg, *trg;
> 
>  	/* Clear out any active regions before we release the map. */
>  	region_truncate(resv_map, 0);
> +
> +	/* ... and any entries left in the cache */
> +	list_for_each_entry_safe(rg, trg, head, link)
> +		list_del(&rg->link);
> +

I am wondering if `cache' is rgn_cache.
And rg should be freed if yes.
> +	VM_BUG_ON(resv_map->adds_in_progress);
> +
>  	kfree(resv_map);
>  }
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
