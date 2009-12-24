Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 7F5AC620002
	for <linux-mm@kvack.org>; Thu, 24 Dec 2009 05:00:44 -0500 (EST)
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by e28smtp09.in.ibm.com (8.14.3/8.13.1) with ESMTP id nBO9Ypv0019863
	for <linux-mm@kvack.org>; Thu, 24 Dec 2009 15:04:51 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id nBOA0YQY3711164
	for <linux-mm@kvack.org>; Thu, 24 Dec 2009 15:30:34 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id nBOA0XF7022332
	for <linux-mm@kvack.org>; Thu, 24 Dec 2009 21:00:34 +1100
Date: Thu, 24 Dec 2009 15:30:30 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 28 of 28] memcg huge memory
Message-ID: <20091224100030.GD13983@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <patchbomb.1261076403@v2.random>
 <d9c8d2160feb7d82736b.1261076431@v2.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <d9c8d2160feb7d82736b.1261076431@v2.random>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

* Andrea Arcangeli <aarcange@redhat.com> [2009-12-17 19:00:31]:

> From: Andrea Arcangeli <aarcange@redhat.com>
> 
> Add memcg charge/uncharge to hugepage faults in huge_memory.c.
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> ---
> 
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -207,6 +207,7 @@ static int __do_huge_anonymous_page(stru
>  	VM_BUG_ON(!PageCompound(page));
>  	pgtable = pte_alloc_one(mm, address);
>  	if (unlikely(!pgtable)) {
> +		mem_cgroup_uncharge_page(page);
>  		put_page(page);
>  		return VM_FAULT_OOM;
>  	}
> @@ -218,6 +219,7 @@ static int __do_huge_anonymous_page(stru
> 
>  	spin_lock(&mm->page_table_lock);
>  	if (unlikely(!pmd_none(*pmd))) {
> +		mem_cgroup_uncharge_page(page);
>  		put_page(page);
>  		pte_free(mm, pgtable);
>  	} else {
> @@ -251,6 +253,10 @@ int do_huge_anonymous_page(struct mm_str
>  				   HPAGE_ORDER);
>  		if (unlikely(!page))
>  			goto out;
> +		if (unlikely(mem_cgroup_newpage_charge(page, mm, GFP_KERNEL))) {
> +			put_page(page);
> +			goto out;
> +		}
> 
>  		return __do_huge_anonymous_page(mm, vma,
>  						address, pmd,
> @@ -379,9 +385,16 @@ int do_huge_wp_page(struct mm_struct *mm
>  		for (i = 0; i < HPAGE_NR; i++) {
>  			pages[i] = alloc_page_vma(GFP_HIGHUSER_MOVABLE,
>  						  vma, address);
> -			if (unlikely(!pages[i])) {
> -				while (--i >= 0)
> +			if (unlikely(!pages[i] ||
> +				     mem_cgroup_newpage_charge(pages[i],
> +							       mm,
> +							       GFP_KERNEL))) {
> +				if (pages[i])
>  					put_page(pages[i]);
> +				while (--i >= 0) {
> +					mem_cgroup_uncharge_page(pages[i]);
> +					put_page(pages[i]);
> +				}
>  				kfree(pages);
>  				ret |= VM_FAULT_OOM;
>  				goto out;
> @@ -439,15 +452,21 @@ int do_huge_wp_page(struct mm_struct *mm
>  		goto out;
>  	}
> 
> +	if (unlikely(mem_cgroup_newpage_charge(new_page, mm, GFP_KERNEL))) {
> +		put_page(new_page);
> +		ret |= VM_FAULT_OOM;
> +		goto out;
> +	}
>  	copy_huge_page(new_page, page, haddr, vma, HPAGE_NR);
>  	__SetPageUptodate(new_page);
> 
>  	smp_wmb();
> 
>  	spin_lock(&mm->page_table_lock);
> -	if (unlikely(!pmd_same(*pmd, orig_pmd)))
> +	if (unlikely(!pmd_same(*pmd, orig_pmd))) {
> +		mem_cgroup_uncharge_page(new_page);
>  		put_page(new_page);
> -	else {
> +	} else {
>  		pmd_t entry;
>  		entry = mk_pmd(new_page, vma->vm_page_prot);
>  		entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
> @@ -466,8 +485,10 @@ out:
>  	return ret;
> 
>  out_free_pages:
> -	for (i = 0; i < HPAGE_NR; i++)
> +	for (i = 0; i < HPAGE_NR; i++) {
> +		mem_cgroup_uncharge_page(pages[i]);
>  		put_page(pages[i]);
> +	}
>  	kfree(pages);
>  	goto out_unlock;
>  }
>

Charging huge pages might be OK, but I wonder if we should create a
separate counter since hugepages are not reclaimable.  I am yet to
look at the complete series, does this series make hugepages
reclaimable? Could you please update Documentation/cgroups/memcg* as
well.

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
