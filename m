Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id E4E466B0038
	for <linux-mm@kvack.org>; Tue, 18 Oct 2016 07:28:20 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id g45so151213219qte.5
        for <linux-mm@kvack.org>; Tue, 18 Oct 2016 04:28:20 -0700 (PDT)
Received: from mx6-phx2.redhat.com (mx6-phx2.redhat.com. [209.132.183.39])
        by mx.google.com with ESMTPS id h5si20597812qka.330.2016.10.18.04.28.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Oct 2016 04:28:20 -0700 (PDT)
Date: Tue, 18 Oct 2016 07:28:11 -0400 (EDT)
From: Jan Stancek <jstancek@redhat.com>
Message-ID: <384936622.247965.1476790091266.JavaMail.zimbra@redhat.com>
In-Reply-To: <87funurrb8.fsf@linux.vnet.ibm.com>
References: <57FF7BB4.1070202@redhat.com> <277142fc-330d-76c7-1f03-a1c8ac0cf336@oracle.com> <efa8b5c9-0138-69f9-0399-5580a086729d@oracle.com> <58009BE2.5010805@redhat.com> <0c9e132e-694c-17cd-1890-66fcfd2e8a0d@oracle.com> <472921348.43188.1476715444366.JavaMail.zimbra@redhat.com> <87funurrb8.fsf@linux.vnet.ibm.com>
Subject: Re: [bug/regression] libhugetlbfs testsuite failures and OOMs
 eventually kill my system
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, hillf zj <hillf.zj@alibaba-inc.com>, dave hansen <dave.hansen@linux.intel.com>, kirill shutemov <kirill.shutemov@linux.intel.com>, mhocko@suse.cz, n-horiguchi@ah.jp.nec.com, iamjoonsoo kim <iamjoonsoo.kim@lge.com>





----- Original Message -----
> Jan Stancek <jstancek@redhat.com> writes:
> > Hi Mike,
> >
> > Revert of 67961f9db8c4 helps, I let whole suite run for 100 iterations,
> > there were no issues.
> >
> > I cut down reproducer and removed last mmap/write/munmap as that is enough
> > to reproduce the problem. Then I started introducing some traces into
> > kernel
> > and noticed that on ppc I get 3 faults, while on x86 I get only 2.
> >
> > Interesting is the 2nd fault, that is first write after mapping as PRIVATE.
> > Following condition fails on ppc first time:
> >     if (likely(ptep && pte_same(huge_ptep_get(ptep), pte))) {
> > but it's immediately followed by fault that looks identical
> > and in that one it evaluates as true.
> >
> > Same with alloc_huge_page(), on x86_64 it's called twice, on ppc three
> > times.
> > In 2nd call vma_needs_reservation() returns 0, in 3rd it returns 1.
> >
> > ---- ppc -> 2nd and 3rd fault ---
> > mmap(MAP_PRIVATE)
> > hugetlb_fault address: 3effff000000, flags: 55
> > hugetlb_cow old_page: f0000000010fc000
> > alloc_huge_page ret: f000000001100000
> > hugetlb_cow ptep: c000000455b27cf8, pte_same: 0
> > free_huge_page page: f000000001100000, restore_reserve: 1
> > hugetlb_fault address: 3effff000000, flags: 55
> > hugetlb_cow old_page: f0000000010fc000
> > alloc_huge_page ret: f000000001100000
> > hugetlb_cow ptep: c000000455b27cf8, pte_same: 1
> >
> > --- x86_64 -> 2nd fault ---
> > mmap(MAP_PRIVATE)
> > hugetlb_fault address: 7f71a4200000, flags: 55
> > hugetlb_cow address 0x7f71a4200000, old_page: ffffea0008d20000
> > alloc_huge_page ret: ffffea0008d38000
> > hugetlb_cow ptep: ffff8802314c7908, pte_same: 1
> >
> > Regards,
> > Jan
> >
> 
> Can you check with the below patch. I ran the corrupt-by-cow-opt test with
> this patch
> and resv count got correctly updated.

I am running libhugetlbfs suite with patch below in loop for
~2 hours now and I don't see any problems/ENOMEMs/OOMs or
leaked resv pages:

0       hugepages-16384kB/free_hugepages
0       hugepages-16384kB/nr_hugepages
0       hugepages-16384kB/nr_hugepages_mempolicy
0       hugepages-16384kB/nr_overcommit_hugepages
0       hugepages-16384kB/resv_hugepages
0       hugepages-16384kB/surplus_hugepages
0       hugepages-16777216kB/free_hugepages
0       hugepages-16777216kB/nr_hugepages
0       hugepages-16777216kB/nr_hugepages_mempolicy
0       hugepages-16777216kB/nr_overcommit_hugepages
0       hugepages-16777216kB/resv_hugepages
0       hugepages-16777216kB/surplus_hugepages

Regards,
Jan

> 
> commit fb2e0c081d2922c8aaa49bbe166472aac68ef5e1
> Author: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> Date:   Tue Oct 18 11:23:11 2016 +0530
> 
>     mm/hugetlb: Use the right pte val for compare in hugetlb_cow
>     
>     We cannot use the pte value used in set_pte_at for pte_same comparison,
>     because archs like ppc64, filter/add new pte flag in set_pte_at. Instead
>     fetch the pte value inside hugetlb_cow. We are comparing pte value to
>     make sure the pte didn't change since we dropped the page table lock.
>     hugetlb_cow get called with page table lock held, and we can take a copy
>     of the pte value before we drop the page table lock.
>     
>     Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> 
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index ec49d9ef1eef..da8fbd02b92e 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -3386,15 +3386,17 @@ static void unmap_ref_private(struct mm_struct *mm,
> struct vm_area_struct *vma,
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
> @@ -3668,7 +3670,7 @@ static int hugetlb_no_page(struct mm_struct *mm, struct
> vm_area_struct *vma,
>  	hugetlb_count_add(pages_per_huge_page(h), mm);
>  	if ((flags & FAULT_FLAG_WRITE) && !(vma->vm_flags & VM_SHARED)) {
>  		/* Optimization, do the COW without a second fault */
> -		ret = hugetlb_cow(mm, vma, address, ptep, new_pte, page, ptl);
> +		ret = hugetlb_cow(mm, vma, address, ptep, page, ptl);
>  	}
>  
>  	spin_unlock(ptl);
> @@ -3822,8 +3824,8 @@ int hugetlb_fault(struct mm_struct *mm, struct
> vm_area_struct *vma,
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
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
