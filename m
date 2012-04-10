Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id D8EC26B004D
	for <linux-mm@kvack.org>; Mon,  9 Apr 2012 20:50:52 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 748043EE0C0
	for <linux-mm@kvack.org>; Tue, 10 Apr 2012 09:50:51 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5E4D445DD73
	for <linux-mm@kvack.org>; Tue, 10 Apr 2012 09:50:51 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2934C45DE4D
	for <linux-mm@kvack.org>; Tue, 10 Apr 2012 09:50:51 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1B8191DB803C
	for <linux-mm@kvack.org>; Tue, 10 Apr 2012 09:50:51 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id C545A1DB8038
	for <linux-mm@kvack.org>; Tue, 10 Apr 2012 09:50:50 +0900 (JST)
Message-ID: <4F838385.9070309@jp.fujitsu.com>
Date: Tue, 10 Apr 2012 09:49:09 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [patch] thp, memcg: split hugepage for memcg oom on cow
References: <alpine.DEB.2.00.1204031854530.30629@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1204031854530.30629@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, linux-mm@kvack.org

(2012/04/04 10:56), David Rientjes wrote:

> On COW, a new hugepage is allocated and charged to the memcg.  If the
> memcg is oom, however, this charge will fail and will return VM_FAULT_OOM
> to the page fault handler which results in an oom kill.
> 
> Instead, it's possible to fallback to splitting the hugepage so that the
> COW results only in an order-0 page being charged to the memcg which has
> a higher liklihood to succeed.  This is expensive because the hugepage
> must be split in the page fault handler, but it is much better than
> unnecessarily oom killing a process.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>
> ---
>  mm/huge_memory.c |    1 +
>  mm/memory.c      |   18 +++++++++++++++---
>  2 files changed, 16 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -959,6 +959,7 @@ int do_huge_pmd_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
>  
>  	if (unlikely(mem_cgroup_newpage_charge(new_page, mm, GFP_KERNEL))) {
>  		put_page(new_page);
> +		split_huge_page(page);
>  		put_page(page);
>  		ret |= VM_FAULT_OOM;
>  		goto out;
> diff --git a/mm/memory.c b/mm/memory.c
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -3489,6 +3489,7 @@ int handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
>  	if (unlikely(is_vm_hugetlb_page(vma)))
>  		return hugetlb_fault(mm, vma, address, flags);
>  
> +retry:
>  	pgd = pgd_offset(mm, address);
>  	pud = pud_alloc(mm, pgd, address);
>  	if (!pud)
> @@ -3502,13 +3503,24 @@ int handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
>  							  pmd, flags);
>  	} else {
>  		pmd_t orig_pmd = *pmd;
> +		int ret;
> +
>  		barrier();
>  		if (pmd_trans_huge(orig_pmd)) {
>  			if (flags & FAULT_FLAG_WRITE &&
>  			    !pmd_write(orig_pmd) &&
> -			    !pmd_trans_splitting(orig_pmd))
> -				return do_huge_pmd_wp_page(mm, vma, address,
> -							   pmd, orig_pmd);
> +			    !pmd_trans_splitting(orig_pmd)) {
> +				ret = do_huge_pmd_wp_page(mm, vma, address, pmd,
> +							  orig_pmd);
> +				/*
> +				 * If COW results in an oom memcg, the huge pmd
> +				 * will already have been split, so retry the
> +				 * fault on the pte for a smaller charge.
> +				 */


IIUC, do_huge_pmd_wp_page_fallback() can return VM_FAULT_OOM. So, this check
is not related only to memcg.

> +				if (unlikely(ret & VM_FAULT_OOM))
> +					goto retry;
> +				return ret;
> +			}
>  			return 0;


Anyway, seems reasonable to me.

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
