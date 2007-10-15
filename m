Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp05.au.ibm.com (8.13.1/8.13.1) with ESMTP id l9FHRi0T020885
	for <linux-mm@kvack.org>; Tue, 16 Oct 2007 03:27:44 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9FHVJ3T274388
	for <linux-mm@kvack.org>; Tue, 16 Oct 2007 03:31:19 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9FHRSYw012154
	for <linux-mm@kvack.org>; Tue, 16 Oct 2007 03:27:28 +1000
Message-ID: <4713A2F2.1010408@linux.vnet.ibm.com>
Date: Mon, 15 Oct 2007 22:57:14 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC] [-mm PATCH] Memory controller fix swap charging context
 in unuse_pte()
References: <20071005041406.21236.88707.sendpatchset@balbir-laptop> <Pine.LNX.4.64.0710071735530.13138@blonde.wat.veritas.com>
In-Reply-To: <Pine.LNX.4.64.0710071735530.13138@blonde.wat.veritas.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Linux MM Mailing List <linux-mm@kvack.org>, Linux Containers <containers@lists.osdl.org>
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote:
> 
> --- 2.6.23-rc8-mm2/mm/swapfile.c	2007-09-27 12:03:36.000000000 +0100
> +++ linux/mm/swapfile.c	2007-10-07 14:33:05.000000000 +0100
> @@ -507,11 +507,23 @@ unsigned int count_swap_pages(int type, 
>   * just let do_wp_page work it out if a write is requested later - to
>   * force COW, vm_page_prot omits write permission from any private vma.
>   */
> -static int unuse_pte(struct vm_area_struct *vma, pte_t *pte,
> +static int unuse_pte(struct vm_area_struct *vma, pmd_t *pmd,
>  		unsigned long addr, swp_entry_t entry, struct page *page)
>  {
> +	spinlock_t *ptl;
> +	pte_t *pte;
> +	int ret = 1;
> +
>  	if (mem_cgroup_charge(page, vma->vm_mm, GFP_KERNEL))
> -		return -ENOMEM;
> +		ret = -ENOMEM;
> +
> +	pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
> +	if (unlikely(!pte_same(*pte, swp_entry_to_pte(entry)))) {
> +		if (ret > 0)
> +			mem_cgroup_uncharge_page(page);
> +		ret = 0;
> +		goto out;
> +	}
> 
>  	inc_mm_counter(vma->vm_mm, anon_rss);
>  	get_page(page);
> @@ -524,7 +536,9 @@ static int unuse_pte(struct vm_area_stru
>  	 * immediately swapped out again after swapon.
>  	 */
>  	activate_page(page);
> -	return 1;
> +out:
> +	pte_unmap_unlock(pte, ptl);
> +	return ret;
>  }
> 
>  static int unuse_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
> @@ -533,21 +547,33 @@ static int unuse_pte_range(struct vm_are
>  {
>  	pte_t swp_pte = swp_entry_to_pte(entry);
>  	pte_t *pte;
> -	spinlock_t *ptl;
>  	int ret = 0;
> 
> -	pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
> +	/*
> +	 * We don't actually need pte lock while scanning for swp_pte:
> +	 * since we hold page lock, swp_pte cannot be inserted into or
> +	 * removed from a page table while we're scanning; but on some
> +	 * architectures (e.g. i386 with PAE) we might catch a glimpse
> +	 * of unmatched parts which look like swp_pte, so unuse_pte
> +	 * must recheck under pte lock.  Scanning without the lock
> +	 * is preemptible if CONFIG_PREEMPT without CONFIG_HIGHPTE.
> +	 */
> +	pte = pte_offset_map(pmd, addr);
>  	do {
>  		/*
>  		 * swapoff spends a _lot_ of time in this loop!
>  		 * Test inline before going to call unuse_pte.
>  		 */
>  		if (unlikely(pte_same(*pte, swp_pte))) {
> -			ret = unuse_pte(vma, pte++, addr, entry, page);
> -			break;
> +			pte_unmap(pte);
> +			ret = unuse_pte(vma, pmd, addr, entry, page);
> +			if (ret)
> +				goto out;
> +			pte = pte_offset_map(pmd, addr);
>  		}
>  	} while (pte++, addr += PAGE_SIZE, addr != end);
> -	pte_unmap_unlock(pte - 1, ptl);
> +	pte_unmap(pte - 1);
> +out:
>  	return ret;
>  }
> 

I tested this patch and it seems to be working fine. I tried swapoff -a
in the middle of tests consuming swap. Not 100% rigorous, but a good
test nevertheless.

Tested-by: Balbir Singh <balbir@linux.vnet.ibm.com>

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
