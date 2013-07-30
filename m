Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id 3E9D36B0031
	for <linux-mm@kvack.org>; Tue, 30 Jul 2013 13:50:06 -0400 (EDT)
Received: from /spool/local
	by e28smtp06.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Tue, 30 Jul 2013 23:11:17 +0530
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id A5AE0394005B
	for <linux-mm@kvack.org>; Tue, 30 Jul 2013 23:19:54 +0530 (IST)
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r6UHp0TO43778072
	for <linux-mm@kvack.org>; Tue, 30 Jul 2013 23:21:01 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r6UHnvHg021490
	for <linux-mm@kvack.org>; Tue, 30 Jul 2013 17:49:58 GMT
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH 06/18] mm, hugetlb: remove vma_need_reservation()
In-Reply-To: <1375075929-6119-7-git-send-email-iamjoonsoo.kim@lge.com>
References: <1375075929-6119-1-git-send-email-iamjoonsoo.kim@lge.com> <1375075929-6119-7-git-send-email-iamjoonsoo.kim@lge.com>
Date: Tue, 30 Jul 2013 23:19:58 +0530
Message-ID: <87siywos3d.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, David Gibson <david@gibson.dropbear.id.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <dhillf@gmail.com>

Joonsoo Kim <iamjoonsoo.kim@lge.com> writes:

> vma_need_reservation() can be substituted by vma_has_reserves()
> with minor change. These function do almost same thing,
> so unifying them is better to maintain.

I found the resulting code confusing and complex. I am sure there is
more that what is explained in the commit message. If you are just doing
this for cleanup, may be we should avoid doing this  ?


>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index bf2ee11..ff46a2c 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -451,8 +451,18 @@ void reset_vma_resv_huge_pages(struct vm_area_struct *vma)
>  		vma->vm_private_data = (void *)0;
>  }
>
> -/* Returns true if the VMA has associated reserve pages */
> -static int vma_has_reserves(struct vm_area_struct *vma, long chg)
> +/*
> + * Determine if the huge page at addr within the vma has an associated
> + * reservation.  Where it does not we will need to logically increase
> + * reservation and actually increase subpool usage before an allocation
> + * can occur.  Where any new reservation would be required the
> + * reservation change is prepared, but not committed.  Once the page
> + * has been allocated from the subpool and instantiated the change should
> + * be committed via vma_commit_reservation.  No action is required on
> + * failure.
> + */
> +static int vma_has_reserves(struct hstate *h,
> +			struct vm_area_struct *vma, unsigned long addr)
>  {
>  	if (vma->vm_flags & VM_NORESERVE) {
>  		/*
> @@ -464,10 +474,22 @@ static int vma_has_reserves(struct vm_area_struct *vma, long chg)
>  		 * step. Currently, we don't have any other solution to deal
>  		 * with this situation properly, so add work-around here.
>  		 */
> -		if (vma->vm_flags & VM_MAYSHARE && chg == 0)
> -			return 1;
> -		else
> -			return 0;
> +		if (vma->vm_flags & VM_MAYSHARE) {
> +			struct address_space *mapping = vma->vm_file->f_mapping;
> +			struct inode *inode = mapping->host;
> +			pgoff_t idx = vma_hugecache_offset(h, vma, addr);
> +			struct resv_map *resv = inode->i_mapping->private_data;
> +			long chg;
> +
> +			chg = region_chg(resv, idx, idx + 1);
> +			if (chg < 0)
> +				return -ENOMEM;
> +
> +			if (chg == 0)
> +				return 1;
> +		}
> +
> +		return 0;
>  	}
>
>  	/* Shared mappings always use reserves */
> @@ -478,8 +500,16 @@ static int vma_has_reserves(struct vm_area_struct *vma, long chg)
>  	 * Only the process that called mmap() has reserves for
>  	 * private mappings.
>  	 */
> -	if (is_vma_resv_set(vma, HPAGE_RESV_OWNER))
> +	if (is_vma_resv_set(vma, HPAGE_RESV_OWNER)) {
> +		pgoff_t idx = vma_hugecache_offset(h, vma, addr);
> +		struct resv_map *resv = vma_resv_map(vma);
> +
> +		/* Just for allocating region structure */
> +		if (region_chg(resv, idx, idx + 1) < 0)
> +			return -ENOMEM;
> +
>  		return 1;
> +	}
>
>  	return 0;
>  }
> @@ -542,8 +572,7 @@ static struct page *dequeue_huge_page_node(struct hstate *h, int nid)
>
>  static struct page *dequeue_huge_page_vma(struct hstate *h,
>  				struct vm_area_struct *vma,
> -				unsigned long address, int avoid_reserve,
> -				long chg)
> +				unsigned long address, int avoid_reserve)
>  {
>  	struct page *page = NULL;
>  	struct mempolicy *mpol;
> @@ -558,7 +587,7 @@ static struct page *dequeue_huge_page_vma(struct hstate *h,
>  	 * have no page reserves. This check ensures that reservations are
>  	 * not "stolen". The child may still get SIGKILLed
>  	 */
> -	if (!vma_has_reserves(vma, chg) &&
> +	if (!vma_has_reserves(h, vma, address) &&
>  			h->free_huge_pages - h->resv_huge_pages == 0)
>  		return NULL;
>
> @@ -578,7 +607,7 @@ retry_cpuset:
>  			if (page) {
>  				if (avoid_reserve)
>  					break;
> -				if (!vma_has_reserves(vma, chg))
> +				if (!vma_has_reserves(h, vma, address))
>  					break;
>
>  				h->resv_huge_pages--;
> @@ -1077,42 +1106,6 @@ static void return_unused_surplus_pages(struct hstate *h,
>  	}
>  }
>
> -/*
> - * Determine if the huge page at addr within the vma has an associated
> - * reservation.  Where it does not we will need to logically increase
> - * reservation and actually increase subpool usage before an allocation
> - * can occur.  Where any new reservation would be required the
> - * reservation change is prepared, but not committed.  Once the page
> - * has been allocated from the subpool and instantiated the change should
> - * be committed via vma_commit_reservation.  No action is required on
> - * failure.
> - */
> -static long vma_needs_reservation(struct hstate *h,
> -			struct vm_area_struct *vma, unsigned long addr)
> -{
> -	struct address_space *mapping = vma->vm_file->f_mapping;
> -	struct inode *inode = mapping->host;
> -
> -	if (vma->vm_flags & VM_MAYSHARE) {
> -		pgoff_t idx = vma_hugecache_offset(h, vma, addr);
> -		struct resv_map *resv = inode->i_mapping->private_data;
> -
> -		return region_chg(resv, idx, idx + 1);
> -
> -	} else if (!is_vma_resv_set(vma, HPAGE_RESV_OWNER)) {
> -		return 1;
> -
> -	} else  {
> -		long err;
> -		pgoff_t idx = vma_hugecache_offset(h, vma, addr);
> -		struct resv_map *resv = vma_resv_map(vma);
> -
> -		err = region_chg(resv, idx, idx + 1);
> -		if (err < 0)
> -			return err;
> -		return 0;
> -	}
> -}
>  static void vma_commit_reservation(struct hstate *h,
>  			struct vm_area_struct *vma, unsigned long addr)
>  {
> @@ -1140,8 +1133,7 @@ static struct page *alloc_huge_page(struct vm_area_struct *vma,
>  	struct hugepage_subpool *spool = subpool_vma(vma);
>  	struct hstate *h = hstate_vma(vma);
>  	struct page *page;
> -	long chg;
> -	int ret, idx;
> +	int ret, idx, has_reserve;
>  	struct hugetlb_cgroup *h_cg;
>
>  	idx = hstate_index(h);
> @@ -1153,20 +1145,21 @@ static struct page *alloc_huge_page(struct vm_area_struct *vma,
>  	 * need pages and subpool limit allocated allocated if no reserve
>  	 * mapping overlaps.
>  	 */
> -	chg = vma_needs_reservation(h, vma, addr);
> -	if (chg < 0)
> +	has_reserve = vma_has_reserves(h, vma, addr);
> +	if (has_reserve < 0)
>  		return ERR_PTR(-ENOMEM);
> -	if (chg)
> -		if (hugepage_subpool_get_pages(spool, chg))
> +
> +	if (!has_reserve && (hugepage_subpool_get_pages(spool, 1) < 0))
>  			return ERR_PTR(-ENOSPC);
>
>  	ret = hugetlb_cgroup_charge_cgroup(idx, pages_per_huge_page(h), &h_cg);
>  	if (ret) {
> -		hugepage_subpool_put_pages(spool, chg);
> +		if (!has_reserve)
> +			hugepage_subpool_put_pages(spool, 1);
>  		return ERR_PTR(-ENOSPC);
>  	}
>  	spin_lock(&hugetlb_lock);
> -	page = dequeue_huge_page_vma(h, vma, addr, avoid_reserve, chg);
> +	page = dequeue_huge_page_vma(h, vma, addr, avoid_reserve);
>  	if (!page) {
>  		spin_unlock(&hugetlb_lock);
>  		page = alloc_buddy_huge_page(h, NUMA_NO_NODE);
> @@ -1174,7 +1167,8 @@ static struct page *alloc_huge_page(struct vm_area_struct *vma,
>  			hugetlb_cgroup_uncharge_cgroup(idx,
>  						       pages_per_huge_page(h),
>  						       h_cg);
> -			hugepage_subpool_put_pages(spool, chg);
> +			if (!has_reserve)
> +				hugepage_subpool_put_pages(spool, 1);
>  			return ERR_PTR(-ENOSPC);
>  		}
>  		spin_lock(&hugetlb_lock);
> @@ -2769,7 +2763,7 @@ retry:
>  	 * the spinlock.
>  	 */
>  	if ((flags & FAULT_FLAG_WRITE) && !(vma->vm_flags & VM_SHARED))
> -		if (vma_needs_reservation(h, vma, address) < 0) {
> +		if (vma_has_reserves(h, vma, address) < 0) {
>  			ret = VM_FAULT_OOM;
>  			goto backout_unlocked;
>  		}
> @@ -2860,7 +2854,7 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
>  	 * consumed.
>  	 */
>  	if ((flags & FAULT_FLAG_WRITE) && !huge_pte_write(entry)) {
> -		if (vma_needs_reservation(h, vma, address) < 0) {
> +		if (vma_has_reserves(h, vma, address) < 0) {
>  			ret = VM_FAULT_OOM;
>  			goto out_mutex;
>  		}
> -- 
> 1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
