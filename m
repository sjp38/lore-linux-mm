Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id E956C6B0387
	for <linux-mm@kvack.org>; Thu,  9 Feb 2017 14:31:50 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id v96so34998889ioi.5
        for <linux-mm@kvack.org>; Thu, 09 Feb 2017 11:31:50 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id c94si8736810ioa.180.2017.02.09.11.31.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Feb 2017 11:31:50 -0800 (PST)
Subject: Re: [RFC] mm/hugetlb: use mem policy when allocating surplus huge
 pages
References: <1486662620-18146-1-git-send-email-grzegorz.andrejczuk@intel.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <c5eb34e8-91ff-13cb-3c51-873b9af62125@oracle.com>
Date: Thu, 9 Feb 2017 11:31:39 -0800
MIME-Version: 1.0
In-Reply-To: <1486662620-18146-1-git-send-email-grzegorz.andrejczuk@intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Grzegorz Andrejczuk <grzegorz.andrejczuk@intel.com>, akpm@linux-foundation.org, mhocko@suse.com, n-horiguchi@ah.jp.nec.com, gerald.schaefer@de.ibm.com, aneesh.kumar@linux.vnet.ibm.com, vaishali.thakkar@oracle.com, kirill.shutemov@linux.intel.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 02/09/2017 09:50 AM, Grzegorz Andrejczuk wrote:
> Application allocating overcommitted hugepages behave differently when
> its mempolicy is set to bind with NUMA nodes containing CPUs and not
> containing CPUs. When memory is allocated on node with CPUs everything
> work as expected, when memory is allocated on CPU-less node:
> 1. Some memory is allocated from node with CPUs.
> 2. Application is terminated with SIGBUS (due to touching not allocated
>    page).
> 
> Reproduction (Node0: 90GB, 272 logical CPUs; Node1: 16GB, No CPUs):
> int
> main()
> {
>   char *p = (char*)mmap(0, 4*1024*1024, PROT_READ|PROT_WRITE,
>                  MAP_PRIVATE|MAP_ANONYMOUS|MAP_HUGETLB, 0, 0);
>   *p = 0;
>   p += 2*1024*1024;
>   *p=0;
>   return  0;
> }
> 
> echo 2 > /proc/sys/vm/nr_overcommit_hugepages
> numactl -m 0 ./test #works
> numactl -m 1 ./test #sigbus
> 
> The reason for this behavior is hugetlb_reserve_pages(...) omits
> struct vm_area when calling hugetlb_acct_pages(..) and later allocation is
> unable to determine memory policy.

Thanks Grzegorz,

I believe another way of stating the problem is as follows:

At mmap(MAP_HUGETLB) time a reservation for the number of huge pages
is made.  If surplus huge pages need to be (and can be) allocated to
satisfy the reservation, they will be allocated at this time.  However,
the memory policy of the task is not taken into account when these
pages are allocated to satisfy the reservation.

Later when the task actually faults on pages in the mapping, reserved
huge pages should be instantiated in the mapping.  However, at fault time
the task's memory policy is taken into account.  It is possible that the
pages reserved at mmap() time, are located on nodes such that they can
not satisfy the request with the task's memory policy.  In such a case,
the allocation fails in the same way as if there was no reservation.

Does that sound accurate?

Your problem statement (and solution) address the case where surplus huge
pages need to be allocated at mmap() time to satisfy a reservation and
later fault.  I 'think' there is a more general problem huge page reservations
and memory policy.

Note the global resv_huge_pages and free_huge_pages counts.  At the
beginning of gather_surplus_pages() we have:

/*
 * Increase the hugetlb pool such that it can accommodate a reservation
 * of size 'delta'.
 */
static int gather_surplus_pages(struct hstate *h, int delta)
{
        struct list_head surplus_list;
        struct page *page, *tmp;
        int ret, i;
        int needed, allocated;
        bool alloc_ok = true;

        needed = (h->resv_huge_pages + delta) - h->free_huge_pages;
        if (needed <= 0) {
                h->resv_huge_pages += delta;
                return 0;
        }

So, as long as there are enough free pages to satisfy the reservation
gather_surplus_pages (also mmap()) return success.  In this case memory
policy is definitely not taken into account.

Another failure scenario/test would be:
- Assume 2 node system with balanced memory/cpu
- echo 0 > /proc/sys/vm/nr_overcommit_hugepages      # just to be sure
- echo 2 > /proc/sys/vm/nr_hugepages
- Now there should be two free huge pages.  Assume interleave and there
  should be one on each node.
- I would expect
  - numactl -m 0 ./test #sigbus
  - numactl -m 1 ./test #sigbus
- In both cases, there are enough free pages to satisfy the reservation
  at mmap time.  However, at fault time it can not get both the pages is
  requires from the specified node.

I'm thinking we may need to expand the reservation tracking to be
per-node like free_huge_pages_node and others.  Like the code below,
we need to take memory policy into account at reservation time.

Thoughts?
-- 
Mike Kravetz

> To fix this issue memory policy is forwarded from hugetlb_reserved_pages
> to allocation routine.
> When policy is interleave, NUMA Node is computed by:
>   page address >> huge_page_shift() % interleaved nodes count.
> 
> This algorithm assumes that address is known, but in this case address
> is not known so to keep interleave working without it, dummy address is
> computed as vm_start + (1 << huge_page_shift())*n, where n is allocated
> page number.
> 
> Signed-off-by: Grzegorz Andrejczuk <grzegorz.andrejczuk@intel.com>
> ---
>  mm/hugetlb.c | 49 +++++++++++++++++++++++++++++++++++--------------
>  1 file changed, 35 insertions(+), 14 deletions(-)
> 
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 418bf01..3913066 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -67,7 +67,8 @@ static int num_fault_mutexes;
>  struct mutex *hugetlb_fault_mutex_table ____cacheline_aligned_in_smp;
>  
>  /* Forward declaration */
> -static int hugetlb_acct_memory(struct hstate *h, long delta);
> +static int hugetlb_acct_memory(struct hstate *h, long delta,
> +			       struct vm_area_struct *vma);
>  
>  static inline void unlock_or_release_subpool(struct hugepage_subpool *spool)
>  {
> @@ -81,7 +82,7 @@ static inline void unlock_or_release_subpool(struct hugepage_subpool *spool)
>  	if (free) {
>  		if (spool->min_hpages != -1)
>  			hugetlb_acct_memory(spool->hstate,
> -						-spool->min_hpages);
> +						-spool->min_hpages, NULL);
>  		kfree(spool);
>  	}
>  }
> @@ -101,7 +102,7 @@ struct hugepage_subpool *hugepage_new_subpool(struct hstate *h, long max_hpages,
>  	spool->hstate = h;
>  	spool->min_hpages = min_hpages;
>  
> -	if (min_hpages != -1 && hugetlb_acct_memory(h, min_hpages)) {
> +	if (min_hpages != -1 && hugetlb_acct_memory(h, min_hpages, NULL)) {
>  		kfree(spool);
>  		return NULL;
>  	}
> @@ -576,7 +577,7 @@ void hugetlb_fix_reserve_counts(struct inode *inode)
>  	if (rsv_adjust) {
>  		struct hstate *h = hstate_inode(inode);
>  
> -		hugetlb_acct_memory(h, 1);
> +		hugetlb_acct_memory(h, 1, NULL);
>  	}
>  }
>  
> @@ -1690,10 +1691,12 @@ struct page *alloc_huge_page_node(struct hstate *h, int nid)
>   * Increase the hugetlb pool such that it can accommodate a reservation
>   * of size 'delta'.
>   */
> -static int gather_surplus_pages(struct hstate *h, int delta)
> +static int gather_surplus_pages(struct hstate *h, int delta,
> +				struct vm_area_struct *vma)
>  {
>  	struct list_head surplus_list;
>  	struct page *page, *tmp;
> +	unsigned long address_offset = 0;
>  	int ret, i;
>  	int needed, allocated;
>  	bool alloc_ok = true;
> @@ -1711,7 +1714,20 @@ static int gather_surplus_pages(struct hstate *h, int delta)
>  retry:
>  	spin_unlock(&hugetlb_lock);
>  	for (i = 0; i < needed; i++) {
> -		page = __alloc_buddy_huge_page_no_mpol(h, NUMA_NO_NODE);
> +		if (vma) {
> +			unsigned long dummy_addr = vma->vm_start +
> +					(address_offset << huge_page_shift(h));
> +
> +			if (dummy_addr >= vma->vm_end) {
> +				address_offset = 0;
> +				dummy_addr = vma->vm_start;
> +			}
> +			page = __alloc_buddy_huge_page_with_mpol(h, vma,
> +								 dummy_addr);
> +			address_offset++;
> +		} else {
> +			page = __alloc_buddy_huge_page_no_mpol(h, NUMA_NO_NODE);
> +		}
>  		if (!page) {
>  			alloc_ok = false;
>  			break;
> @@ -2057,7 +2073,7 @@ struct page *alloc_huge_page(struct vm_area_struct *vma,
>  		long rsv_adjust;
>  
>  		rsv_adjust = hugepage_subpool_put_pages(spool, 1);
> -		hugetlb_acct_memory(h, -rsv_adjust);
> +		hugetlb_acct_memory(h, -rsv_adjust, NULL);
>  	}
>  	return page;
>  
> @@ -3031,7 +3047,8 @@ unsigned long hugetlb_total_pages(void)
>  	return nr_total_pages;
>  }
>  
> -static int hugetlb_acct_memory(struct hstate *h, long delta)
> +static int hugetlb_acct_memory(struct hstate *h, long delta,
> +			       struct vm_area_struct *vma)
>  {
>  	int ret = -ENOMEM;
>  
> @@ -3054,7 +3071,7 @@ static int hugetlb_acct_memory(struct hstate *h, long delta)
>  	 * semantics that cpuset has.
>  	 */
>  	if (delta > 0) {
> -		if (gather_surplus_pages(h, delta) < 0)
> +		if (gather_surplus_pages(h, delta, vma) < 0)
>  			goto out;
>  
>  		if (delta > cpuset_mems_nr(h->free_huge_pages_node)) {
> @@ -3112,7 +3129,7 @@ static void hugetlb_vm_op_close(struct vm_area_struct *vma)
>  		 * adjusted if the subpool has a minimum size.
>  		 */
>  		gbl_reserve = hugepage_subpool_put_pages(spool, reserve);
> -		hugetlb_acct_memory(h, -gbl_reserve);
> +		hugetlb_acct_memory(h, -gbl_reserve, NULL);
>  	}
>  }
>  
> @@ -4167,9 +4184,13 @@ int hugetlb_reserve_pages(struct inode *inode,
>  
>  	/*
>  	 * Check enough hugepages are available for the reservation.
> -	 * Hand the pages back to the subpool if there are not
> +	 * Hand the pages back to the subpool if there are not.
>  	 */
> -	ret = hugetlb_acct_memory(h, gbl_reserve);
> +	if (!vma || vma->vm_flags & VM_MAYSHARE)
> +		ret = hugetlb_acct_memory(h, gbl_reserve, NULL);
> +	else
> +		ret = hugetlb_acct_memory(h, gbl_reserve, vma);
> +
>  	if (ret < 0) {
>  		/* put back original number of pages, chg */
>  		(void)hugepage_subpool_put_pages(spool, chg);
> @@ -4202,7 +4223,7 @@ int hugetlb_reserve_pages(struct inode *inode,
>  
>  			rsv_adjust = hugepage_subpool_put_pages(spool,
>  								chg - add);
> -			hugetlb_acct_memory(h, -rsv_adjust);
> +			hugetlb_acct_memory(h, -rsv_adjust, NULL);
>  		}
>  	}
>  	return 0;
> @@ -4243,7 +4264,7 @@ long hugetlb_unreserve_pages(struct inode *inode, long start, long end,
>  	 * reservations to be released may be adjusted.
>  	 */
>  	gbl_reserve = hugepage_subpool_put_pages(spool, (chg - freed));
> -	hugetlb_acct_memory(h, -gbl_reserve);
> +	hugetlb_acct_memory(h, -gbl_reserve, NULL);
>  
>  	return 0;
>  }
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
