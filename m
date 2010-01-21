Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 5CB8B6B00BF
	for <linux-mm@kvack.org>; Thu, 21 Jan 2010 02:19:53 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o0L7JW4j002308
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 21 Jan 2010 16:19:33 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5F14745DD6F
	for <linux-mm@kvack.org>; Thu, 21 Jan 2010 16:19:32 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 338BF45DE4D
	for <linux-mm@kvack.org>; Thu, 21 Jan 2010 16:19:32 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 031E31DB8041
	for <linux-mm@kvack.org>; Thu, 21 Jan 2010 16:19:32 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9D8011DB803C
	for <linux-mm@kvack.org>; Thu, 21 Jan 2010 16:19:31 +0900 (JST)
Date: Thu, 21 Jan 2010 16:16:01 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 28 of 30] memcg huge memory
Message-Id: <20100121161601.6612fd79.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4c405faf58cfe5d1aa6e.1264054852@v2.random>
References: <patchbomb.1264054824@v2.random>
	<4c405faf58cfe5d1aa6e.1264054852@v2.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, 21 Jan 2010 07:20:52 +0100
Andrea Arcangeli <aarcange@redhat.com> wrote:

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
> @@ -212,6 +212,7 @@ static int __do_huge_pmd_anonymous_page(
>  	VM_BUG_ON(!PageCompound(page));
>  	pgtable = pte_alloc_one(mm, address);
>  	if (unlikely(!pgtable)) {
> +		mem_cgroup_uncharge_page(page);
>  		put_page(page);
>  		return VM_FAULT_OOM;
>  	}
> @@ -228,6 +229,7 @@ static int __do_huge_pmd_anonymous_page(
>  
>  	spin_lock(&mm->page_table_lock);
>  	if (unlikely(!pmd_none(*pmd))) {
> +		mem_cgroup_uncharge_page(page);
>  		put_page(page);
>  		pte_free(mm, pgtable);

Can't we do this put_page() and uncharge() outside of page table lock ?

Thanks,
-Kame

>  	} else {
> @@ -265,6 +267,10 @@ int do_huge_pmd_anonymous_page(struct mm
>  		page = alloc_hugepage(transparent_hugepage_defrag(vma));
>  		if (unlikely(!page))
>  			goto out;
> +		if (unlikely(mem_cgroup_newpage_charge(page, mm, GFP_KERNEL))) {
> +			put_page(page);
> +			goto out;
> +		}
>  
>  		return __do_huge_pmd_anonymous_page(mm, vma, address, pmd,
>  						    page, haddr);
> @@ -365,9 +371,15 @@ static int do_huge_pmd_wp_page_fallback(
>  	for (i = 0; i < HPAGE_PMD_NR; i++) {
>  		pages[i] = alloc_page_vma(GFP_HIGHUSER_MOVABLE,
>  					  vma, address);
> -		if (unlikely(!pages[i])) {
> -			while (--i >= 0)
> +		if (unlikely(!pages[i] ||
> +			     mem_cgroup_newpage_charge(pages[i], mm,
> +						       GFP_KERNEL))) {
> +			if (pages[i])
>  				put_page(pages[i]);
> +			while (--i >= 0) {
> +				mem_cgroup_uncharge_page(pages[i]);
> +				put_page(pages[i]);
> +			}

Maybe we can use batched_uncharge here. As

	mem_cgroup_uncharge_start();
	while (--i) {
		mem_cgroup_uncharge_page(page[i]);
		put_page(pages[i]);
	}
	mem_cgroup_uncharge_end();

Hmm...but this requires some modification to memcontrol.c. Okay, please
leave this as my homework.

 
>  			kfree(pages);
>  			ret |= VM_FAULT_OOM;
>  			goto out;
> @@ -426,8 +438,10 @@ out:
>  
>  out_free_pages:
>  	spin_unlock(&mm->page_table_lock);
> -	for (i = 0; i < HPAGE_PMD_NR; i++)
> +	for (i = 0; i < HPAGE_PMD_NR; i++) {
> +		mem_cgroup_uncharge_page(pages[i]);
>  		put_page(pages[i]);
> +	}
here too.

Bye.
-Kame
>  	kfree(pages);
>  	goto out;
>  }
> @@ -469,6 +483,11 @@ int do_huge_pmd_wp_page(struct mm_struct
>  		goto out;
>  	}
>  
> +	if (unlikely(mem_cgroup_newpage_charge(new_page, mm, GFP_KERNEL))) {
> +		put_page(new_page);
> +		ret |= VM_FAULT_OOM;
> +		goto out;
> +	}
>  	copy_huge_page(new_page, page, haddr, vma, HPAGE_PMD_NR);
>  	__SetPageUptodate(new_page);
>  
> @@ -480,9 +499,10 @@ int do_huge_pmd_wp_page(struct mm_struct
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
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
