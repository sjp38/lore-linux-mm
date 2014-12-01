Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 365FF6B0069
	for <linux-mm@kvack.org>; Mon,  1 Dec 2014 09:07:08 -0500 (EST)
Received: by mail-pd0-f182.google.com with SMTP id r10so11006596pdi.27
        for <linux-mm@kvack.org>; Mon, 01 Dec 2014 06:07:07 -0800 (PST)
Received: from e28smtp06.in.ibm.com (e28smtp06.in.ibm.com. [122.248.162.6])
        by mx.google.com with ESMTPS id fy2si29012477pbb.67.2014.12.01.06.07.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 01 Dec 2014 06:07:06 -0800 (PST)
Received: from /spool/local
	by e28smtp06.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 1 Dec 2014 19:36:59 +0530
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 420AE3940048
	for <linux-mm@kvack.org>; Mon,  1 Dec 2014 19:36:56 +0530 (IST)
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay05.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id sB1E7SCQ66060402
	for <linux-mm@kvack.org>; Mon, 1 Dec 2014 19:37:29 +0530
Received: from d28av01.in.ibm.com (localhost [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id sB1E6pfM026878
	for <linux-mm@kvack.org>; Mon, 1 Dec 2014 19:36:51 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH V2] mm/thp: Allocate transparent hugepages on local node
In-Reply-To: <20141201113340.GA545@node.dhcp.inet.fi>
References: <1417412803-27234-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20141201113340.GA545@node.dhcp.inet.fi>
Date: Mon, 01 Dec 2014 19:36:50 +0530
Message-ID: <87vblvh3b9.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: akpm@linux-foundation.org, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

"Kirill A. Shutemov" <kirill@shutemov.name> writes:

> On Mon, Dec 01, 2014 at 11:16:43AM +0530, Aneesh Kumar K.V wrote:
>> This make sure that we try to allocate hugepages from local node if
>> allowed by mempolicy. If we can't, we fallback to small page allocation
>> based on mempolicy. This is based on the observation that allocating pages
>> on local node is more beneficial that allocating hugepages on remote node.
>> 
>> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
>> ---
>>  include/linux/gfp.h |  4 ++++
>>  mm/huge_memory.c    | 24 +++++++++---------------
>>  mm/mempolicy.c      | 40 ++++++++++++++++++++++++++++++++++++++++
>>  3 files changed, 53 insertions(+), 15 deletions(-)
>> 
>> diff --git a/include/linux/gfp.h b/include/linux/gfp.h
>> index 41b30fd4d041..fcbd017b4fb4 100644
>> --- a/include/linux/gfp.h
>> +++ b/include/linux/gfp.h
>> @@ -338,11 +338,15 @@ alloc_pages(gfp_t gfp_mask, unsigned int order)
>>  extern struct page *alloc_pages_vma(gfp_t gfp_mask, int order,
>>  			struct vm_area_struct *vma, unsigned long addr,
>>  			int node);
>> +extern struct page *alloc_hugepage_vma(gfp_t gfp, struct vm_area_struct *vma,
>> +				       unsigned long addr, int order);
>>  #else
>>  #define alloc_pages(gfp_mask, order) \
>>  		alloc_pages_node(numa_node_id(), gfp_mask, order)
>>  #define alloc_pages_vma(gfp_mask, order, vma, addr, node)	\
>>  	alloc_pages(gfp_mask, order)
>> +#define alloc_hugepage_vma(gfp_mask, vma, addr, order)	\
>> +	alloc_pages(gfp_mask, order)
>>  #endif
>>  #define alloc_page(gfp_mask) alloc_pages(gfp_mask, 0)
>>  #define alloc_page_vma(gfp_mask, vma, addr)			\
>> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
>> index de984159cf0b..7903eb995b7f 100644
>> --- a/mm/huge_memory.c
>> +++ b/mm/huge_memory.c
>> @@ -766,15 +766,6 @@ static inline gfp_t alloc_hugepage_gfpmask(int defrag, gfp_t extra_gfp)
>>  	return (GFP_TRANSHUGE & ~(defrag ? 0 : __GFP_WAIT)) | extra_gfp;
>>  }
>>  
>> -static inline struct page *alloc_hugepage_vma(int defrag,
>> -					      struct vm_area_struct *vma,
>> -					      unsigned long haddr, int nd,
>> -					      gfp_t extra_gfp)
>> -{
>> -	return alloc_pages_vma(alloc_hugepage_gfpmask(defrag, extra_gfp),
>> -			       HPAGE_PMD_ORDER, vma, haddr, nd);
>> -}
>> -
>>  /* Caller must hold page table lock. */
>>  static bool set_huge_zero_page(pgtable_t pgtable, struct mm_struct *mm,
>>  		struct vm_area_struct *vma, unsigned long haddr, pmd_t *pmd,
>> @@ -796,6 +787,7 @@ int do_huge_pmd_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
>>  			       unsigned long address, pmd_t *pmd,
>>  			       unsigned int flags)
>>  {
>> +	gfp_t gfp;
>>  	struct page *page;
>>  	unsigned long haddr = address & HPAGE_PMD_MASK;
>>  
>> @@ -830,8 +822,8 @@ int do_huge_pmd_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
>>  		}
>>  		return 0;
>>  	}
>> -	page = alloc_hugepage_vma(transparent_hugepage_defrag(vma),
>> -			vma, haddr, numa_node_id(), 0);
>> +	gfp = alloc_hugepage_gfpmask(transparent_hugepage_defrag(vma), 0);
>> +	page = alloc_hugepage_vma(gfp, vma, haddr, HPAGE_PMD_ORDER);
>>  	if (unlikely(!page)) {
>>  		count_vm_event(THP_FAULT_FALLBACK);
>>  		return VM_FAULT_FALLBACK;
>> @@ -1119,10 +1111,12 @@ int do_huge_pmd_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
>>  	spin_unlock(ptl);
>>  alloc:
>>  	if (transparent_hugepage_enabled(vma) &&
>> -	    !transparent_hugepage_debug_cow())
>> -		new_page = alloc_hugepage_vma(transparent_hugepage_defrag(vma),
>> -					      vma, haddr, numa_node_id(), 0);
>> -	else
>> +	    !transparent_hugepage_debug_cow()) {
>> +		gfp_t gfp;
>> +
>> +		gfp = alloc_hugepage_gfpmask(transparent_hugepage_defrag(vma), 0);
>> +		new_page = alloc_hugepage_vma(gfp, vma, haddr, HPAGE_PMD_ORDER);
>
> Should node of page we're handling wp-fault for be part of decision?


We are doing that in alloc_hugepage_vma by using numa_node_id(), I am
not sure whether it really matters w.r.t to the task getting preempted
and running on another node ? Even if we make it same as the node on
which the page fault happened, we could end up running on another
node. That situation is no worse than what we have today. 



>
>> +	} else
>>  		new_page = NULL;
>>  
>>  	if (unlikely(!new_page)) {
>> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
>> index e58725aff7e9..fa96af5b31f7 100644
>> --- a/mm/mempolicy.c
>> +++ b/mm/mempolicy.c
>> @@ -2041,6 +2041,46 @@ retry_cpuset:
>>  	return page;
>>  }
>>  
>> +struct page *alloc_hugepage_vma(gfp_t gfp, struct vm_area_struct *vma,
>> +				unsigned long addr, int order)
>> +{
>> +	struct page *page;
>> +	nodemask_t *nmask;
>> +	struct mempolicy *pol;
>> +	int node = numa_node_id();
>
> Hm. What if the code will be preempted and scheduled on different node?
> I'm not really familiar with mempolicy details and not sure if we should
> care. Probably not.
>
>> +	unsigned int cpuset_mems_cookie;
>> +
>> +retry_cpuset:
>> +	pol = get_vma_policy(vma, addr);
>> +	cpuset_mems_cookie = read_mems_allowed_begin();
>> +
>> +	if (pol->mode != MPOL_INTERLEAVE) {
>> +		/*
>> +		 * For interleave policy, we don't worry about
>> +		 * current node. Otherwise if current node is
>> +		 * in nodemask, try to allocate hugepage from
>> +		 * current node. Don't fall back to other nodes
>> +		 * for THP.
>> +		 */
>
> The comment probably should be above "if ()", not below.

ok

>
>> +		nmask = policy_nodemask(gfp, pol);
>> +		if (!nmask || node_isset(node, *nmask)) {
>> +			mpol_cond_put(pol);
>> +			page = alloc_pages_exact_node(node, gfp, order);
>> +			if (unlikely(!page &&
>> +				     read_mems_allowed_retry(cpuset_mems_cookie)))
>> +				goto retry_cpuset;
>> +			return page;
>> +		}
>> +	}
>> +	mpol_cond_put(pol);
>> +	/*
>> +	 * if current node is not part of node mask, try
>> +	 * the allocation from any node, and we can do retry
>> +	 * in that case.
>> +	 */
>> +	return alloc_pages_vma(gfp, order, vma, addr, node);
>> +}
>> +
>>  /**
>>   * 	alloc_pages_current - Allocate pages.
>>   *

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
