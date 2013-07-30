Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 79DFF6B0031
	for <linux-mm@kvack.org>; Tue, 30 Jul 2013 10:27:02 -0400 (EDT)
Date: Tue, 30 Jul 2013 16:27:00 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: +
 mm-hugetlb-decrement-reserve-count-if-vm_noreserve-alloc-page-cache.patch
 added to -mm tree
Message-ID: <20130730142700.GF15847@dhcp22.suse.cz>
References: <51f6e7bf.dqni+XPEIvIQ8a50%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51f6e7bf.dqni+XPEIvIQ8a50%akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mm-commits@vger.kernel.org, riel@redhat.com, n-horiguchi@ah.jp.nec.com, mgorman@suse.de, liwanp@linux.vnet.ibm.com, kamezawa.hiroyu@jp.fujitsu.com, hughd@google.com, dhillf@gmail.com, davidlohr.bueso@hp.com, david@gibson.dropbear.id.au, aneesh.kumar@linux.vnet.ibm.com, iamjoonsoo.kim@lge.com, linux-mm@kvack.org

> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Subject: mm, hugetlb: decrement reserve count if VM_NORESERVE alloc page cache
> 
> If a vma with VM_NORESERVE allocate a new page for page cache, we should
> check whether this area is reserved or not.  If this address is already
> reserved by other process(in case of chg == 0), we should decrement
> reserve count, because this allocated page will go into page cache and
> currently, there is no way to know that this page comes from reserved pool
> or not when releasing inode.  This may introduce over-counting problem to
> reserved count.  With following example code, you can easily reproduce
> this situation.
> 
> Assume 2MB, nr_hugepages = 100
> 
>         size = 20 * MB;
>         flag = MAP_SHARED;
>         p = mmap(NULL, size, PROT_READ|PROT_WRITE, flag, fd, 0);
>         if (p == MAP_FAILED) {
>                 fprintf(stderr, "mmap() failed: %s\n", strerror(errno));
>                 return -1;
>         }
> 
>         flag = MAP_SHARED | MAP_NORESERVE;
>         q = mmap(NULL, size, PROT_READ|PROT_WRITE, flag, fd, 0);
>         if (q == MAP_FAILED) {
>                 fprintf(stderr, "mmap() failed: %s\n", strerror(errno));
>         }
>         q[0] = 'c';
> 
> After finish the program, run 'cat /proc/meminfo'.  You can see below
> result.
> 
> HugePages_Free:      100
> HugePages_Rsvd:        1
> 
> To fix this, we should check our mapping type and tracked region.  If our
> mapping is VM_NORESERVE, VM_MAYSHARE and chg is 0, this imply that current
> allocated page will go into page cache which is already reserved region
> when mapping is created.  In this case, we should decrease reserve count. 
> As implementing above, this patch solve the problem.
> 
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Reviewed-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
> Reviewed-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> Acked-by: Hillf Danton <dhillf@gmail.com>
> Cc: Michal Hocko <mhocko@suse.cz>

This is ugly and makes the reservation code even more subtle but I do
not have a better idea to work it around.

Acked-by: Michal Hocko <mhocko@suse.cz>

> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Davidlohr Bueso <davidlohr.bueso@hp.com>
> Cc: David Gibson <david@gibson.dropbear.id.au>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  mm/hugetlb.c |   34 ++++++++++++++++++++++++++--------
>  1 file changed, 26 insertions(+), 8 deletions(-)
> 
> diff -puN mm/hugetlb.c~mm-hugetlb-decrement-reserve-count-if-vm_noreserve-alloc-page-cache mm/hugetlb.c
> --- a/mm/hugetlb.c~mm-hugetlb-decrement-reserve-count-if-vm_noreserve-alloc-page-cache
> +++ a/mm/hugetlb.c
> @@ -443,10 +443,23 @@ void reset_vma_resv_huge_pages(struct vm
>  }
>  
>  /* Returns true if the VMA has associated reserve pages */
> -static int vma_has_reserves(struct vm_area_struct *vma)
> +static int vma_has_reserves(struct vm_area_struct *vma, long chg)
>  {
> -	if (vma->vm_flags & VM_NORESERVE)
> -		return 0;
> +	if (vma->vm_flags & VM_NORESERVE) {
> +		/*
> +		 * This address is already reserved by other process(chg == 0),
> +		 * so, we should decreament reserved count. Without
> +		 * decreamenting, reserve count is remained after releasing
> +		 * inode, because this allocated page will go into page cache
> +		 * and is regarded as coming from reserved pool in releasing
> +		 * step. Currently, we don't have any other solution to deal
> +		 * with this situation properly, so add work-around here.
> +		 */
> +		if (vma->vm_flags & VM_MAYSHARE && chg == 0)
> +			return 1;
> +		else
> +			return 0;
> +	}
>  
>  	/* Shared mappings always use reserves */
>  	if (vma->vm_flags & VM_MAYSHARE)
> @@ -520,7 +533,8 @@ static struct page *dequeue_huge_page_no
>  
>  static struct page *dequeue_huge_page_vma(struct hstate *h,
>  				struct vm_area_struct *vma,
> -				unsigned long address, int avoid_reserve)
> +				unsigned long address, int avoid_reserve,
> +				long chg)
>  {
>  	struct page *page = NULL;
>  	struct mempolicy *mpol;
> @@ -535,7 +549,7 @@ static struct page *dequeue_huge_page_vm
>  	 * have no page reserves. This check ensures that reservations are
>  	 * not "stolen". The child may still get SIGKILLed
>  	 */
> -	if (!vma_has_reserves(vma) &&
> +	if (!vma_has_reserves(vma, chg) &&
>  			h->free_huge_pages - h->resv_huge_pages == 0)
>  		goto err;
>  
> @@ -553,8 +567,12 @@ retry_cpuset:
>  		if (cpuset_zone_allowed_softwall(zone, htlb_alloc_mask)) {
>  			page = dequeue_huge_page_node(h, zone_to_nid(zone));
>  			if (page) {
> -				if (!avoid_reserve && vma_has_reserves(vma))
> -					h->resv_huge_pages--;
> +				if (avoid_reserve)
> +					break;
> +				if (!vma_has_reserves(vma, chg))
> +					break;
> +
> +				h->resv_huge_pages--;
>  				break;
>  			}
>  		}
> @@ -1155,7 +1173,7 @@ static struct page *alloc_huge_page(stru
>  		return ERR_PTR(-ENOSPC);
>  	}
>  	spin_lock(&hugetlb_lock);
> -	page = dequeue_huge_page_vma(h, vma, addr, avoid_reserve);
> +	page = dequeue_huge_page_vma(h, vma, addr, avoid_reserve, chg);
>  	if (!page) {
>  		spin_unlock(&hugetlb_lock);
>  		page = alloc_buddy_huge_page(h, NUMA_NO_NODE);
> _
> 
> Patches currently in -mm which might be from iamjoonsoo.kim@lge.com are
> 
> mm-hugetlb-move-up-the-code-which-check-availability-of-free-huge-page.patch
> mm-hugetlb-trivial-commenting-fix.patch
> mm-hugetlb-clean-up-alloc_huge_page.patch
> mm-hugetlb-fix-and-clean-up-node-iteration-code-to-alloc-or-free.patch
> mm-hugetlb-remove-redundant-list_empty-check-in-gather_surplus_pages.patch
> mm-hugetlb-do-not-use-a-page-in-page-cache-for-cow-optimization.patch
> mm-hugetlb-add-vm_noreserve-check-in-vma_has_reserves.patch
> mm-hugetlb-remove-decrement_hugepage_resv_vma.patch
> mm-hugetlb-decrement-reserve-count-if-vm_noreserve-alloc-page-cache.patch
> mm-hugetlb-decrement-reserve-count-if-vm_noreserve-alloc-page-cache-fix.patch
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
