Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 1E0EC280257
	for <linux-mm@kvack.org>; Fri,  3 Jul 2015 03:20:45 -0400 (EDT)
Received: by pdbci14 with SMTP id ci14so58917817pdb.2
        for <linux-mm@kvack.org>; Fri, 03 Jul 2015 00:20:44 -0700 (PDT)
Received: from out4133-34.mail.aliyun.com (out4133-34.mail.aliyun.com. [42.120.133.34])
        by mx.google.com with ESMTP id z7si13030417pdm.46.2015.07.03.00.20.40
        for <linux-mm@kvack.org>;
        Fri, 03 Jul 2015 00:20:41 -0700 (PDT)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <1435851526-4200-1-git-send-email-mike.kravetz@oracle.com> <1435851526-4200-3-git-send-email-mike.kravetz@oracle.com>
In-Reply-To: <1435851526-4200-3-git-send-email-mike.kravetz@oracle.com>
Subject: Re: [PATCH 02/10] mm/hugetlb: add region_del() to delete a specific range of entries
Date: Fri, 03 Jul 2015 15:20:34 +0800
Message-ID: <011301d0b560$c0ffc5a0$42ff50e0$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Mike Kravetz' <mike.kravetz@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org
Cc: 'Dave Hansen' <dave.hansen@linux.intel.com>, 'Naoya Horiguchi' <n-horiguchi@ah.jp.nec.com>, 'David Rientjes' <rientjes@google.com>, 'Hugh Dickins' <hughd@google.com>, 'Davidlohr Bueso' <dave@stgolabs.net>, 'Aneesh Kumar' <aneesh.kumar@linux.vnet.ibm.com>, 'Christoph Hellwig' <hch@infradead.org>

> fallocate hole punch will want to remove a specific range of pages.
> The existing region_truncate() routine deletes all region/reserve
> map entries after a specified offset.  region_del() will provide
> this same functionality if the end of region is specified as -1.
> Hence, region_del() can replace region_truncate().
> 
> Unlike region_truncate(), region_del() can return an error in the
> rare case where it can not allocate memory for a region descriptor.
> This ONLY happens in the case where an existing region must be split.
> Current callers passing -1 as end of range will never experience
> this error and do not need to deal with error handling.  Future
> callers of region_del() (such as fallocate hole punch) will need to
> handle this error.
> 
> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
> ---
>  mm/hugetlb.c | 101 ++++++++++++++++++++++++++++++++++++++++++++---------------
>  1 file changed, 75 insertions(+), 26 deletions(-)
> 
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 189c0d7..e8c7f68 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -460,43 +460,92 @@ static void region_abort(struct resv_map *resv, long f, long t)
>  }
> 
>  /*
> - * Truncate the reserve map at index 'end'.  Modify/truncate any
> - * region which contains end.  Delete any regions past end.
> - * Return the number of huge pages removed from the map.
> + * Delete the specified range [f, t) from the reserve map.  If the
> + * t parameter is -1, this indicates that ALL regions after f should
> + * be deleted.  Locate the regions which intersect [f, t) and either
> + * trim, delete or split the existing regions.
> + *
> + * Returns the number of huge pages deleted from the reserve map.
> + * In the normal case, the return value is zero or more.  In the
> + * case where a region must be split, a new region descriptor must
> + * be allocated.  If the allocation fails, -ENOMEM will be returned.
> + * NOTE: If the parameter t == -1, then we will never split a region
> + * and possibly return -ENOMEM.  Callers specifying t == -1 do not
> + * need to check for -ENOMEM error.
>   */
> -static long region_truncate(struct resv_map *resv, long end)
> +static long region_del(struct resv_map *resv, long f, long t)
>  {
>  	struct list_head *head = &resv->regions;
>  	struct file_region *rg, *trg;
> -	long chg = 0;
> +	struct file_region *nrg = NULL;
> +	long del = 0;
> 
> +	if (t == -1)
> +		t = LONG_MAX;

Why not use 
> +retry:
>  	spin_lock(&resv->lock);
> -	/* Locate the region we are either in or before. */
> -	list_for_each_entry(rg, head, link)
> -		if (end <= rg->to)
> +	list_for_each_entry_safe(rg, trg, head, link) {
> +		if (rg->to <= f)
> +			continue;
> +		if (rg->from >= t)
>  			break;
> -	if (&rg->link == head)
> -		goto out;
> 
> -	/* If we are in the middle of a region then adjust it. */
> -	if (end > rg->from) {
> -		chg = rg->to - end;
> -		rg->to = end;
> -		rg = list_entry(rg->link.next, typeof(*rg), link);
> -	}
> +		if (f > rg->from && t < rg->to) { /* Must split region */
> +			/*
> +			 * Check for an entry in the cache before dropping
> +			 * lock and attempting allocation.
> +			 */
> +			if (!nrg &&
> +			    resv->rgn_cache_count > resv->adds_in_progress) {
> +				nrg = list_first_entry(&resv->rgn_cache,
> +							struct file_region,
> +							link);
> +				list_del(&nrg->link);
> +				resv->rgn_cache_count--;
> +			}
> 
> -	/* Drop any remaining regions. */
> -	list_for_each_entry_safe(rg, trg, rg->link.prev, link) {
> -		if (&rg->link == head)
> +			if (!nrg) {
> +				spin_unlock(&resv->lock);
> +				nrg = kmalloc(sizeof(*nrg), GFP_KERNEL);
> +				if (!nrg)
> +					return -ENOMEM;
> +				goto retry;
> +			}
> +
> +			del += t - f;
> +
> +			/* New entry for end of split region */
> +			nrg->from = t;
> +			nrg->to = rg->to;
> +			INIT_LIST_HEAD(&nrg->link);
> +
> +			/* Original entry is trimmed */
> +			rg->to = f;
> +
> +			list_add(&nrg->link, &rg->link);
> +			nrg = NULL;
>  			break;
> -		chg += rg->to - rg->from;
> -		list_del(&rg->link);
> -		kfree(rg);
> +		}
> +
> +		if (f <= rg->from && t >= rg->to) { /* Remove entire region */
> +			del += rg->to - rg->from;
> +			list_del(&rg->link);
> +			kfree(rg);
> +			continue;
> +		}
> +
> +		if (f <= rg->from) {	/* Trim beginning of region */
> +			del += t - rg->from;
> +			rg->from = t;
> +		} else {		/* Trim end of region */
> +			del += rg->to - f;
> +			rg->to = f;
> +		}
>  	}
> 
> -out:
>  	spin_unlock(&resv->lock);
> -	return chg;
> +	kfree(nrg);
> +	return del;
>  }
> 
>  /*
> @@ -647,7 +696,7 @@ void resv_map_release(struct kref *ref)
>  	struct file_region *rg, *trg;
> 
>  	/* Clear out any active regions before we release the map. */
> -	region_truncate(resv_map, 0);
> +	region_del(resv_map, 0, -1);

LONG_MAX is not selected, why?
> 
>  	/* ... and any entries left in the cache */
>  	list_for_each_entry_safe(rg, trg, head, link)
> @@ -3868,7 +3917,7 @@ void hugetlb_unreserve_pages(struct inode *inode, long offset, long freed)
>  	long gbl_reserve;
> 
>  	if (resv_map)
> -		chg = region_truncate(resv_map, offset);
> +		chg = region_del(resv_map, offset, -1);
>  	spin_lock(&inode->i_lock);
>  	inode->i_blocks -= (blocks_per_huge_page(h) * freed);
>  	spin_unlock(&inode->i_lock);
> --
> 2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
