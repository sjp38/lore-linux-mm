Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 714816B0047
	for <linux-mm@kvack.org>; Thu, 17 Dec 2009 20:36:38 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nBI1aVPf031846
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 18 Dec 2009 10:36:31 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 961DB45DE52
	for <linux-mm@kvack.org>; Fri, 18 Dec 2009 10:36:31 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 6A4CA45DE4E
	for <linux-mm@kvack.org>; Fri, 18 Dec 2009 10:36:31 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 4AD891DB8038
	for <linux-mm@kvack.org>; Fri, 18 Dec 2009 10:36:31 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 84A751DB805B
	for <linux-mm@kvack.org>; Fri, 18 Dec 2009 10:36:30 +0900 (JST)
Date: Fri, 18 Dec 2009 10:33:12 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 28 of 28] memcg huge memory
Message-Id: <20091218103312.2f61bbfc.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <d9c8d2160feb7d82736b.1261076431@v2.random>
References: <patchbomb.1261076403@v2.random>
	<d9c8d2160feb7d82736b.1261076431@v2.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, 17 Dec 2009 19:00:31 -0000
Andrea Arcangeli <aarcange@redhat.com> wrote:

> From: Andrea Arcangeli <aarcange@redhat.com>
> 
> Add memcg charge/uncharge to hugepage faults in huge_memory.c.
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>

Seems nice.

Then, maybe we (I?) should cut this part (and some from 27/28) out and
merge into memcg. It will be helpful to all your work.

But I don't like a situation which memcg's charge are filled with _locked_ memory.
(Especially, bad-configured softlimit+hugepage will adds much regression.)
New counter as "usage of huge page" will be required for memcg, at least.

Thanks,
-Kame

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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
