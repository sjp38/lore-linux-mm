Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28esmtp05.in.ibm.com (8.13.1/8.13.1) with ESMTP id m1R5EXZF017809
	for <linux-mm@kvack.org>; Wed, 27 Feb 2008 10:44:33 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m1R5EX7O1134776
	for <linux-mm@kvack.org>; Wed, 27 Feb 2008 10:44:33 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.13.1/8.13.3) with ESMTP id m1R5EWK7016255
	for <linux-mm@kvack.org>; Wed, 27 Feb 2008 05:14:33 GMT
Date: Wed, 27 Feb 2008 10:38:55 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 04/15] memcg: when do_swap's do_wp_page fails
Message-ID: <20080227050854.GA2317@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <Pine.LNX.4.64.0802252327490.27067@blonde.site> <Pine.LNX.4.64.0802252337110.27067@blonde.site>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0802252337110.27067@blonde.site>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hirokazu Takahashi <taka@valinux.co.jp>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Nick Piggin <npiggin@suse.de>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

* Hugh Dickins <hugh@veritas.com> [2008-02-25 23:38:02]:

> Don't uncharge when do_swap_page's call to do_wp_page fails: the page which
> was charged for is there in the pagetable, and will be correctly uncharged
> when that area is unmapped - it was only its COWing which failed.
> 
> And while we're here, remove earlier XXX comment: yes, OR in do_wp_page's
> return value (maybe VM_FAULT_WRITE) with do_swap_page's there; but if it
> fails, mask out success bits, which might confuse some arches e.g. sparc.
> 
> Signed-off-by: Hugh Dickins <hugh@veritas.com>
> ---
> 
>  mm/memory.c |    9 +++------
>  1 file changed, 3 insertions(+), 6 deletions(-)
> 
> --- memcg03/mm/memory.c	2008-02-25 14:05:43.000000000 +0000
> +++ memcg04/mm/memory.c	2008-02-25 14:05:47.000000000 +0000
> @@ -2093,12 +2093,9 @@ static int do_swap_page(struct mm_struct
>  	unlock_page(page);
> 
>  	if (write_access) {
> -		/* XXX: We could OR the do_wp_page code with this one? */
> -		if (do_wp_page(mm, vma, address,
> -				page_table, pmd, ptl, pte) & VM_FAULT_OOM) {
> -			mem_cgroup_uncharge_page(page);
> -			ret = VM_FAULT_OOM;
> -		}
> +		ret |= do_wp_page(mm, vma, address, page_table, pmd, ptl, pte);
> +		if (ret & VM_FAULT_ERROR)
> +			ret &= VM_FAULT_ERROR;
>  		goto out;
>  	}
>

Looks good to me. Do you think we could add some of the description
from above as a comment in the code? People would not have to look at
the git log to understand why we did not uncharge.

Otherwise, it looks very good

Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>
 
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
