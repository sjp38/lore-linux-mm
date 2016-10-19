Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5B4576B0069
	for <linux-mm@kvack.org>; Tue, 18 Oct 2016 23:22:17 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id r16so6222057pfg.4
        for <linux-mm@kvack.org>; Tue, 18 Oct 2016 20:22:17 -0700 (PDT)
Received: from out4440.biz.mail.alibaba.com (out4440.biz.mail.alibaba.com. [47.88.44.40])
        by mx.google.com with ESMTP id l184si35018926pgd.113.2016.10.18.20.22.14
        for <linux-mm@kvack.org>;
        Tue, 18 Oct 2016 20:22:16 -0700 (PDT)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <20161018154245.18023-1-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <20161018154245.18023-1-aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm/hugetlb: Use the right pte val for compare in hugetlb_cow
Date: Wed, 19 Oct 2016 11:22:01 +0800
Message-ID: <027301d229b7$f543f030$dfcbd090$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "'Aneesh Kumar K.V'" <aneesh.kumar@linux.vnet.ibm.com>, akpm@linux-foundation.org, 'Jan Stancek' <jstancek@redhat.com>, 'Mike Kravetz' <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

On Tuesday, October 18, 2016 11:43 PM Aneesh Kumar K.V wrote:
> 
> We cannot use the pte value used in set_pte_at for pte_same comparison,
> because archs like ppc64, filter/add new pte flag in set_pte_at. Instead
> fetch the pte value inside hugetlb_cow. We are comparing pte value to
> make sure the pte didn't change since we dropped the page table lock.
> hugetlb_cow get called with page table lock held, and we can take a copy
> of the pte value before we drop the page table lock.
> 
> With hugetlbfs, we optimize the MAP_PRIVATE write fault path with no
> previous mapping (huge_pte_none entries), by forcing a cow in the fault
> path. This avoid take an addition fault to covert a read-only mapping
> to read/write. Here we were comparing a recently instantiated pte (via
> set_pte_at) to the pte values from linux page table. As explained above
> on ppc64 such pte_same check returned wrong result, resulting in us
> taking an additional fault on ppc64.
> 
> Fixes: 6a119eae942c ("powerpc/mm: Add a _PAGE_PTE bit")
> 
> Reported-by: Jan Stancek <jstancek@redhat.com>
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> ---

Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>

>  mm/hugetlb.c | 12 +++++++-----
>  1 file changed, 7 insertions(+), 5 deletions(-)
> 
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index ec49d9ef1eef..da8fbd02b92e 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -3386,15 +3386,17 @@ static void unmap_ref_private(struct mm_struct *mm, struct vm_area_struct *vma,
>   * Keep the pte_same checks anyway to make transition from the mutex easier.
>   */
>  static int hugetlb_cow(struct mm_struct *mm, struct vm_area_struct *vma,
> -			unsigned long address, pte_t *ptep, pte_t pte,
> -			struct page *pagecache_page, spinlock_t *ptl)
> +		       unsigned long address, pte_t *ptep,
> +		       struct page *pagecache_page, spinlock_t *ptl)
>  {
> +	pte_t pte;
>  	struct hstate *h = hstate_vma(vma);
>  	struct page *old_page, *new_page;
>  	int ret = 0, outside_reserve = 0;
>  	unsigned long mmun_start;	/* For mmu_notifiers */
>  	unsigned long mmun_end;		/* For mmu_notifiers */
> 
> +	pte = huge_ptep_get(ptep);
>  	old_page = pte_page(pte);
> 
>  retry_avoidcopy:
> @@ -3668,7 +3670,7 @@ static int hugetlb_no_page(struct mm_struct *mm, struct vm_area_struct *vma,
>  	hugetlb_count_add(pages_per_huge_page(h), mm);
>  	if ((flags & FAULT_FLAG_WRITE) && !(vma->vm_flags & VM_SHARED)) {
>  		/* Optimization, do the COW without a second fault */
> -		ret = hugetlb_cow(mm, vma, address, ptep, new_pte, page, ptl);
> +		ret = hugetlb_cow(mm, vma, address, ptep, page, ptl);
>  	}
> 
>  	spin_unlock(ptl);
> @@ -3822,8 +3824,8 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
> 
>  	if (flags & FAULT_FLAG_WRITE) {
>  		if (!huge_pte_write(entry)) {
> -			ret = hugetlb_cow(mm, vma, address, ptep, entry,
> -					pagecache_page, ptl);
> +			ret = hugetlb_cow(mm, vma, address, ptep,
> +					  pagecache_page, ptl);
>  			goto out_put_page;
>  		}
>  		entry = huge_pte_mkdirty(entry);
> --
> 2.10.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
