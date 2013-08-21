Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id BE8EE6B0069
	for <linux-mm@kvack.org>; Wed, 21 Aug 2013 05:58:10 -0400 (EDT)
Received: from /spool/local
	by e28smtp06.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Wed, 21 Aug 2013 15:18:36 +0530
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id 336281258043
	for <linux-mm@kvack.org>; Wed, 21 Aug 2013 15:27:51 +0530 (IST)
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r7L9w2Pg48037968
	for <linux-mm@kvack.org>; Wed, 21 Aug 2013 15:28:02 +0530
Received: from d28av02.in.ibm.com (localhost [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r7L9w3Fr003165
	for <linux-mm@kvack.org>; Wed, 21 Aug 2013 15:28:04 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 08/20] mm, hugetlb: region manipulation functions take resv_map rather list_head
In-Reply-To: <1376040398-11212-9-git-send-email-iamjoonsoo.kim@lge.com>
References: <1376040398-11212-1-git-send-email-iamjoonsoo.kim@lge.com> <1376040398-11212-9-git-send-email-iamjoonsoo.kim@lge.com>
Date: Wed, 21 Aug 2013 15:28:03 +0530
Message-ID: <87haejgyc4.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, David Gibson <david@gibson.dropbear.id.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <dhillf@gmail.com>

Joonsoo Kim <iamjoonsoo.kim@lge.com> writes:

> To change a protection method for region tracking to find grained one,
> we pass the resv_map, instead of list_head, to region manipulation
> functions. This doesn't introduce any functional change, and it is just
> for preparing a next step.
>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Reviewed-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>

>
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 8751e2c..d9cabf6 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -150,8 +150,9 @@ struct file_region {
>  	long to;
>  };
>
> -static long region_add(struct list_head *head, long f, long t)
> +static long region_add(struct resv_map *resv, long f, long t)
>  {
> +	struct list_head *head = &resv->regions;
>  	struct file_region *rg, *nrg, *trg;
>
>  	/* Locate the region we are either in or before. */
> @@ -186,8 +187,9 @@ static long region_add(struct list_head *head, long f, long t)
>  	return 0;
>  }
>
> -static long region_chg(struct list_head *head, long f, long t)
> +static long region_chg(struct resv_map *resv, long f, long t)
>  {
> +	struct list_head *head = &resv->regions;
>  	struct file_region *rg, *nrg;
>  	long chg = 0;
>
> @@ -235,8 +237,9 @@ static long region_chg(struct list_head *head, long f, long t)
>  	return chg;
>  }
>
> -static long region_truncate(struct list_head *head, long end)
> +static long region_truncate(struct resv_map *resv, long end)
>  {
> +	struct list_head *head = &resv->regions;
>  	struct file_region *rg, *trg;
>  	long chg = 0;
>
> @@ -265,8 +268,9 @@ static long region_truncate(struct list_head *head, long end)
>  	return chg;
>  }
>
> -static long region_count(struct list_head *head, long f, long t)
> +static long region_count(struct resv_map *resv, long f, long t)
>  {
> +	struct list_head *head = &resv->regions;
>  	struct file_region *rg;
>  	long chg = 0;
>
> @@ -392,7 +396,7 @@ void resv_map_release(struct kref *ref)
>  	struct resv_map *resv_map = container_of(ref, struct resv_map, refs);
>
>  	/* Clear out any active regions before we release the map. */
> -	region_truncate(&resv_map->regions, 0);
> +	region_truncate(resv_map, 0);
>  	kfree(resv_map);
>  }
>
> @@ -1099,7 +1103,7 @@ static long vma_needs_reservation(struct hstate *h,
>  		pgoff_t idx = vma_hugecache_offset(h, vma, addr);
>  		struct resv_map *resv = vma_resv_map(vma);
>
> -		err = region_chg(&resv->regions, idx, idx + 1);
> +		err = region_chg(resv, idx, idx + 1);
>  		if (err < 0)
>  			return err;
>  		return 0;
> @@ -1121,9 +1125,8 @@ static void vma_commit_reservation(struct hstate *h,
>  		pgoff_t idx = vma_hugecache_offset(h, vma, addr);
>  		struct resv_map *resv = vma_resv_map(vma);
>
> -		/* Mark this page used in the map. */
> -		region_add(&resv->regions, idx, idx + 1);
> -	}
> +	idx = vma_hugecache_offset(h, vma, addr);
> +	region_add(resv, idx, idx + 1);
>  }
>
>  static struct page *alloc_huge_page(struct vm_area_struct *vma,
> @@ -2211,7 +2214,7 @@ static void hugetlb_vm_op_close(struct vm_area_struct *vma)
>  		end = vma_hugecache_offset(h, vma, vma->vm_end);
>
>  		reserve = (end - start) -
> -			region_count(&resv->regions, start, end);
> +			region_count(resv, start, end);
>
>  		resv_map_put(vma);
>
> @@ -3091,7 +3094,7 @@ int hugetlb_reserve_pages(struct inode *inode,
>  	if (!vma || vma->vm_flags & VM_MAYSHARE) {
>  		resv_map = inode->i_mapping->private_data;
>
> -		chg = region_chg(&resv_map->regions, from, to);
> +		chg = region_chg(resv_map, from, to);
>
>  	} else {
>  		resv_map = resv_map_alloc();
> @@ -3137,7 +3140,7 @@ int hugetlb_reserve_pages(struct inode *inode,
>  	 * else has to be done for private mappings here
>  	 */
>  	if (!vma || vma->vm_flags & VM_MAYSHARE)
> -		region_add(&resv_map->regions, from, to);
> +		region_add(resv_map, from, to);
>  	return 0;
>  out_err:
>  	if (vma)
> @@ -3153,7 +3156,7 @@ void hugetlb_unreserve_pages(struct inode *inode, long offset, long freed)
>  	struct hugepage_subpool *spool = subpool_inode(inode);
>
>  	if (resv_map)
> -		chg = region_truncate(&resv_map->regions, offset);
> +		chg = region_truncate(resv_map, offset);
>  	spin_lock(&inode->i_lock);
>  	inode->i_blocks -= (blocks_per_huge_page(h) * freed);
>  	spin_unlock(&inode->i_lock);
> -- 
> 1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
