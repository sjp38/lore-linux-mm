Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f172.google.com (mail-qc0-f172.google.com [209.85.216.172])
	by kanga.kvack.org (Postfix) with ESMTP id CD80C6B0039
	for <linux-mm@kvack.org>; Mon, 27 Jan 2014 16:03:47 -0500 (EST)
Received: by mail-qc0-f172.google.com with SMTP id c9so8918159qcz.3
        for <linux-mm@kvack.org>; Mon, 27 Jan 2014 13:03:47 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id 21si9572513qga.61.2014.01.27.13.03.46
        for <linux-mm@kvack.org>;
        Mon, 27 Jan 2014 13:03:46 -0800 (PST)
Date: Mon, 27 Jan 2014 16:03:27 -0500
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1390856607-psfeyzze-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1390794746-16755-6-git-send-email-davidlohr@hp.com>
References: <1390794746-16755-1-git-send-email-davidlohr@hp.com>
 <1390794746-16755-6-git-send-email-davidlohr@hp.com>
Subject: Re: [PATCH 5/8] mm, hugetlb: use vma_resv_map() map types
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr@hp.com>
Cc: akpm@linux-foundation.org, iamjoonsoo.kim@lge.com, riel@redhat.com, mgorman@suse.de, mhocko@suse.cz, aneesh.kumar@linux.vnet.ibm.com, kamezawa.hiroyu@jp.fujitsu.com, hughd@google.com, david@gibson.dropbear.id.au, js1304@gmail.com, liwanp@linux.vnet.ibm.com, dhillf@gmail.com, rientjes@google.com, aswin@hp.com, scott.norton@hp.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun, Jan 26, 2014 at 07:52:23PM -0800, Davidlohr Bueso wrote:
> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> 
> Util now, we get a resv_map by two ways according to each mapping type.
> This makes code dirty and unreadable. Unify it.
> 
> Reviewed-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Signed-off-by: Davidlohr Bueso <davidlohr@hp.com>

Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

There are a few small nitpicking below ...

> ---
>  mm/hugetlb.c | 76 ++++++++++++++++++++++++++++++------------------------------
>  1 file changed, 38 insertions(+), 38 deletions(-)
> 
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 13edf17..541cceb 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -417,13 +417,24 @@ void resv_map_release(struct kref *ref)
>  	kfree(resv_map);
>  }
>  
> +static inline struct resv_map *inode_resv_map(struct inode *inode)
> +{
> +	return inode->i_mapping->private_data;
> +}
> +
>  static struct resv_map *vma_resv_map(struct vm_area_struct *vma)
>  {
>  	VM_BUG_ON(!is_vm_hugetlb_page(vma));
> -	if (!(vma->vm_flags & VM_MAYSHARE))
> +	if (vma->vm_flags & VM_MAYSHARE) {
> +		struct address_space *mapping = vma->vm_file->f_mapping;
> +		struct inode *inode = mapping->host;

You don't have to declare mapping.

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
> @@ -1165,48 +1176,34 @@ static void return_unused_surplus_pages(struct hstate *h,
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
> -		return region_chg(resv, idx, idx + 1);
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
> -		region_add(resv, idx, idx + 1);
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
> -		/* Mark this page used in the map. */
> -		region_add(resv, idx, idx + 1);
> -	}
> +	idx = vma_hugecache_offset(h, vma, addr);
> +	region_add(resv, idx, idx + 1);
>  }
>  
>  static struct page *alloc_huge_page(struct vm_area_struct *vma,
> @@ -2269,7 +2266,7 @@ static void hugetlb_vm_op_open(struct vm_area_struct *vma)
>  	 * after this open call completes.  It is therefore safe to take a
>  	 * new reference here without additional locking.
>  	 */
> -	if (resv)
> +	if (resv && is_vma_resv_set(vma, HPAGE_RESV_OWNER))
>  		kref_get(&resv->refs);
>  }
>  
> @@ -2282,7 +2279,10 @@ static void hugetlb_vm_op_close(struct vm_area_struct *vma)
>  	unsigned long start;
>  	unsigned long end;
>  
> -	if (resv) {
> +	if (!resv)
> +		return;
> +
> +	if (is_vma_resv_set(vma, HPAGE_RESV_OWNER)) {

	if (resv && is_vma_resv_set(vma, HPAGE_RESV_OWNER)) {

looks simpler.

Thanks,
Naoya Horiguchi

>  		start = vma_hugecache_offset(h, vma, vma->vm_start);
>  		end = vma_hugecache_offset(h, vma, vma->vm_end);
>  
> @@ -3187,7 +3187,7 @@ int hugetlb_reserve_pages(struct inode *inode,
>  	 * called to make the mapping read-write. Assume !vma is a shm mapping
>  	 */
>  	if (!vma || vma->vm_flags & VM_MAYSHARE) {
> -		resv_map = inode->i_mapping->private_data;
> +		resv_map = inode_resv_map(inode);
>  
>  		chg = region_chg(resv_map, from, to);
>  
> @@ -3246,7 +3246,7 @@ out_err:
>  void hugetlb_unreserve_pages(struct inode *inode, long offset, long freed)
>  {
>  	struct hstate *h = hstate_inode(inode);
> -	struct resv_map *resv_map = inode->i_mapping->private_data;
> +	struct resv_map *resv_map = inode_resv_map(inode);
>  	long chg = 0;
>  	struct hugepage_subpool *spool = subpool_inode(inode);
>  
> -- 
> 1.8.1.4
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
