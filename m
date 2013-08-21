Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id BF31F6B0098
	for <linux-mm@kvack.org>; Wed, 21 Aug 2013 06:37:59 -0400 (EDT)
Received: from /spool/local
	by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Thu, 22 Aug 2013 07:32:18 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 880F0357805A
	for <linux-mm@kvack.org>; Wed, 21 Aug 2013 20:37:54 +1000 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r7LAbbXd65470546
	for <linux-mm@kvack.org>; Wed, 21 Aug 2013 20:37:43 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r7LAblEj018051
	for <linux-mm@kvack.org>; Wed, 21 Aug 2013 20:37:48 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 11/20] mm, hugetlb: make vma_resv_map() works for all mapping type
In-Reply-To: <1376040398-11212-12-git-send-email-iamjoonsoo.kim@lge.com>
References: <1376040398-11212-1-git-send-email-iamjoonsoo.kim@lge.com> <1376040398-11212-12-git-send-email-iamjoonsoo.kim@lge.com>
Date: Wed, 21 Aug 2013 16:07:36 +0530
Message-ID: <878uzvgwi7.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, David Gibson <david@gibson.dropbear.id.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <dhillf@gmail.com>

Joonsoo Kim <iamjoonsoo.kim@lge.com> writes:

> Util now, we get a resv_map by two ways according to each mapping type.
> This makes code dirty and unreadable. So unfiying it.
>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 869c3e0..e6c0c77 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -421,13 +421,24 @@ void resv_map_release(struct kref *ref)
>  	kfree(resv_map);
>  }
>
> +static inline struct resv_map *inode_resv_map(struct inode *inode)
> +{
> +	return inode->i_mapping->private_data;
> +}

it would be nice to get have another function that will return resv_map
only if we have HPAGE_RESV_OWNER. So that we could use that in
hugetlb_vm_op_open/close. ? Otherwise 

Reviewed-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>




> +
>  static struct resv_map *vma_resv_map(struct vm_area_struct *vma)
>  {
>  	VM_BUG_ON(!is_vm_hugetlb_page(vma));
> -	if (!(vma->vm_flags & VM_MAYSHARE))
> +	if (vma->vm_flags & VM_MAYSHARE) {
> +		struct address_space *mapping = vma->vm_file->f_mapping;
> +		struct inode *inode = mapping->host;
> +
> +		return inode_resv_map(inode);
> +
> +	} else {
>  		return (struct resv_map *)(get_vma_private_data(vma) &
>  							~HPAGE_RESV_MASK);
> -	return NULL;
> +	}
>  }
>
>  static void set_vma_resv_map(struct vm_area_struct *vma, struct resv_map *map)
> @@ -1107,44 +1118,31 @@ static void return_unused_surplus_pages(struct hstate *h,
>  static long vma_needs_reservation(struct hstate *h,
>  			struct vm_area_struct *vma, unsigned long addr)
>  {
> -	struct address_space *mapping = vma->vm_file->f_mapping;
> -	struct inode *inode = mapping->host;
> -
> -	if (vma->vm_flags & VM_MAYSHARE) {
> -		pgoff_t idx = vma_hugecache_offset(h, vma, addr);
> -		struct resv_map *resv = inode->i_mapping->private_data;
> -
> -		return region_chg(&resv->regions, idx, idx + 1);
> +	struct resv_map *resv;
> +	pgoff_t idx;
> +	long chg;
>
> -	} else if (!is_vma_resv_set(vma, HPAGE_RESV_OWNER)) {
> +	resv = vma_resv_map(vma);
> +	if (!resv)
>  		return 1;
>
> -	} else  {
> -		long err;
> -		pgoff_t idx = vma_hugecache_offset(h, vma, addr);
> -		struct resv_map *resv = vma_resv_map(vma);
> +	idx = vma_hugecache_offset(h, vma, addr);
> +	chg = region_chg(resv, idx, idx + 1);
>
> -		err = region_chg(resv, idx, idx + 1);
> -		if (err < 0)
> -			return err;
> -		return 0;
> -	}
> +	if (vma->vm_flags & VM_MAYSHARE)
> +		return chg;
> +	else
> +		return chg < 0 ? chg : 0;
>  }
>  static void vma_commit_reservation(struct hstate *h,
>  			struct vm_area_struct *vma, unsigned long addr)
>  {
> -	struct address_space *mapping = vma->vm_file->f_mapping;
> -	struct inode *inode = mapping->host;
> -
> -	if (vma->vm_flags & VM_MAYSHARE) {
> -		pgoff_t idx = vma_hugecache_offset(h, vma, addr);
> -		struct resv_map *resv = inode->i_mapping->private_data;
> -
> -		region_add(&resv->regions, idx, idx + 1);
> +	struct resv_map *resv;
> +	pgoff_t idx;
>
> -	} else if (is_vma_resv_set(vma, HPAGE_RESV_OWNER)) {
> -		pgoff_t idx = vma_hugecache_offset(h, vma, addr);
> -		struct resv_map *resv = vma_resv_map(vma);
> +	resv = vma_resv_map(vma);
> +	if (!resv)
> +		return;
>
>  	idx = vma_hugecache_offset(h, vma, addr);
>  	region_add(resv, idx, idx + 1);
> @@ -2208,7 +2206,7 @@ static void hugetlb_vm_op_open(struct vm_area_struct *vma)
>  	 * after this open call completes.  It is therefore safe to take a
>  	 * new reference here without additional locking.
>  	 */
> -	if (resv)
> +	if (resv && is_vma_resv_set(vma, HPAGE_RESV_OWNER))
>  		kref_get(&resv->refs);
>  }
>
> @@ -2221,7 +2219,10 @@ static void hugetlb_vm_op_close(struct vm_area_struct *vma)
>  	unsigned long start;
>  	unsigned long end;
>
> -	if (resv) {
> +	if (!resv)
> +		return;
> +
> +	if (is_vma_resv_set(vma, HPAGE_RESV_OWNER)) {
>  		start = vma_hugecache_offset(h, vma, vma->vm_start);
>  		end = vma_hugecache_offset(h, vma, vma->vm_end);
>
> @@ -3104,7 +3105,7 @@ int hugetlb_reserve_pages(struct inode *inode,
>  	 * called to make the mapping read-write. Assume !vma is a shm mapping
>  	 */
>  	if (!vma || vma->vm_flags & VM_MAYSHARE) {
> -		resv_map = inode->i_mapping->private_data;
> +		resv_map = inode_resv_map(inode);
>
>  		chg = region_chg(resv_map, from, to);
>
> @@ -3163,7 +3164,7 @@ out_err:
>  void hugetlb_unreserve_pages(struct inode *inode, long offset, long freed)
>  {
>  	struct hstate *h = hstate_inode(inode);
> -	struct resv_map *resv_map = inode->i_mapping->private_data;
> +	struct resv_map *resv_map = inode_resv_map(inode);
>  	long chg = 0;
>  	struct hugepage_subpool *spool = subpool_inode(inode);
>
> -- 
> 1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
