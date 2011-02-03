Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 552FA8D0039
	for <linux-mm@kvack.org>; Thu,  3 Feb 2011 16:22:28 -0500 (EST)
Received: from wpaz5.hot.corp.google.com (wpaz5.hot.corp.google.com [172.24.198.69])
	by smtp-out.google.com with ESMTP id p13LMPLu026082
	for <linux-mm@kvack.org>; Thu, 3 Feb 2011 13:22:25 -0800
Received: from pwj6 (pwj6.prod.google.com [10.241.219.70])
	by wpaz5.hot.corp.google.com with ESMTP id p13LMObg020913
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 3 Feb 2011 13:22:24 -0800
Received: by pwj6 with SMTP id 6so686268pwj.40
        for <linux-mm@kvack.org>; Thu, 03 Feb 2011 13:22:23 -0800 (PST)
Date: Thu, 3 Feb 2011 13:22:21 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC][PATCH 2/6] pagewalk: only split huge pages when
 necessary
In-Reply-To: <20110201003359.8DDFF665@kernel>
Message-ID: <alpine.DEB.2.00.1102031257490.948@chino.kir.corp.google.com>
References: <20110201003357.D6F0BE0D@kernel> <20110201003359.8DDFF665@kernel>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael J Wolf <mjwolf@us.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>

On Mon, 31 Jan 2011, Dave Hansen wrote:

> 
> Right now, if a mm_walk has either ->pte_entry or ->pmd_entry
> set, it will unconditionally split and transparent huge pages
> it runs in to.  In practice, that means that anyone doing a
> 
> 	cat /proc/$pid/smaps
> 
> will unconditionally break down every huge page in the process
> and depend on khugepaged to re-collapse it later.  This is
> fairly suboptimal.
> 
> This patch changes that behavior.  It teaches each ->pmd_entry
> handler (there are three) that they must break down the THPs
> themselves.  Also, the _generic_ code will never break down
> a THP unless a ->pte_entry handler is actually set.
> 
> This means that the ->pmd_entry handlers can now choose to
> deal with THPs without breaking them down.
> 
> 

No sign-off (goes for patches 3 and 4, as well)?

> ---
> 
>  linux-2.6.git-dave/fs/proc/task_mmu.c |    6 ++++++
>  linux-2.6.git-dave/mm/pagewalk.c      |   24 ++++++++++++++++++++----
>  2 files changed, 26 insertions(+), 4 deletions(-)
> 
> diff -puN mm/pagewalk.c~pagewalk-dont-always-split-thp mm/pagewalk.c
> --- linux-2.6.git/mm/pagewalk.c~pagewalk-dont-always-split-thp	2011-01-27 10:57:02.309914973 -0800
> +++ linux-2.6.git-dave/mm/pagewalk.c	2011-01-27 10:57:02.317914965 -0800
> @@ -33,19 +33,35 @@ static int walk_pmd_range(pud_t *pud, un
>  
>  	pmd = pmd_offset(pud, addr);
>  	do {
> +	again:

checkpatch will warn about the indent.

>  		next = pmd_addr_end(addr, end);
> -		split_huge_page_pmd(walk->mm, pmd);
> -		if (pmd_none_or_clear_bad(pmd)) {
> +		if (pmd_none(*pmd)) {

Not sure why this has been changed from pmd_none_or_clear_bad(), that's 
been done even prior to THP.

>  			if (walk->pte_hole)
>  				err = walk->pte_hole(addr, next, walk);
>  			if (err)
>  				break;
>  			continue;
>  		}
> +		/*
> +		 * This implies that each ->pmd_entry() handler
> +		 * needs to know about pmd_trans_huge() pmds
> +		 */

Probably needs to be documented somewhere for users of pagewalk?

>  		if (walk->pmd_entry)
>  			err = walk->pmd_entry(pmd, addr, next, walk);
> -		if (!err && walk->pte_entry)
> -			err = walk_pte_range(pmd, addr, next, walk);
> +		if (err)
> +			break;
> +
> +		/*
> +		 * Check this here so we only break down trans_huge
> +		 * pages when we _need_ to
> +		 */
> +		if (!walk->pte_entry)
> +			continue;
> +
> +		split_huge_page_pmd(walk->mm, pmd);
> +		if (pmd_none_or_clear_bad(pmd))
> +			goto again;
> +		err = walk_pte_range(pmd, addr, next, walk);
>  		if (err)
>  			break;
>  	} while (pmd++, addr = next, addr != end);
> diff -puN fs/proc/task_mmu.c~pagewalk-dont-always-split-thp fs/proc/task_mmu.c
> --- linux-2.6.git/fs/proc/task_mmu.c~pagewalk-dont-always-split-thp	2011-01-27 10:57:02.313914969 -0800
> +++ linux-2.6.git-dave/fs/proc/task_mmu.c	2011-01-27 10:57:02.321914961 -0800
> @@ -343,6 +343,8 @@ static int smaps_pte_range(pmd_t *pmd, u
>  	struct page *page;
>  	int mapcount;
>  
> +	split_huge_page_pmd(walk->mm, pmd);
> +
>  	pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
>  	for (; addr != end; pte++, addr += PAGE_SIZE) {
>  		ptent = *pte;
> @@ -467,6 +469,8 @@ static int clear_refs_pte_range(pmd_t *p
>  	spinlock_t *ptl;
>  	struct page *page;
>  
> +	split_huge_page_pmd(walk->mm, pmd);
> +
>  	pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
>  	for (; addr != end; pte++, addr += PAGE_SIZE) {
>  		ptent = *pte;
> @@ -623,6 +627,8 @@ static int pagemap_pte_range(pmd_t *pmd,
>  	pte_t *pte;
>  	int err = 0;
>  
> +	split_huge_page_pmd(walk->mm, pmd);
> +
>  	/* find the first VMA at or above 'addr' */
>  	vma = find_vma(walk->mm, addr);
>  	for (; addr != end; addr += PAGE_SIZE) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
