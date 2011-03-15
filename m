Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id D0FD98D003A
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 05:28:17 -0400 (EDT)
Date: Tue, 15 Mar 2011 10:27:50 +0100
From: Johannes Weiner <jweiner@redhat.com>
Subject: Re: [PATCH] thp: mremap support and TLB optimization
Message-ID: <20110315092750.GD2140@redhat.com>
References: <20110311020410.GH5641@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110311020410.GH5641@random.random>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>

On Fri, Mar 11, 2011 at 03:04:10AM +0100, Andrea Arcangeli wrote:
> @@ -42,7 +42,7 @@ static pmd_t *get_old_pmd(struct mm_stru
>  
>  	pmd = pmd_offset(pud, addr);
>  	split_huge_page_pmd(mm, pmd);

Wasn't getting rid of this line the sole purpose of the patch? :)

> -	if (pmd_none_or_clear_bad(pmd))
> +	if (pmd_none(*pmd))
>  		return NULL;
>  
>  	return pmd;

[...]

> @@ -151,6 +148,23 @@ unsigned long move_page_tables(struct vm
>  		new_pmd = alloc_new_pmd(vma->vm_mm, vma, new_addr);
>  		if (!new_pmd)
>  			break;
> +		if (pmd_trans_huge(*old_pmd)) {
> +			int err = move_huge_pmd(vma, old_addr, new_addr,
> +						old_end, old_pmd, new_pmd);
> +			if (err > 0) {
> +				old_addr += HPAGE_PMD_SIZE;
> +				new_addr += HPAGE_PMD_SIZE;
> +				continue;
> +			}
> +		}
> +		/*
> +		 * split_huge_page_pmd() must run outside the
> +		 * pmd_trans_huge() block above because that check
> +		 * racy. split_huge_page_pmd() will recheck
> +		 * pmd_trans_huge() but in a not racy way under the
> +		 * page_table_lock.
> +		 */
> +		split_huge_page_pmd(vma->vm_mm, old_pmd);

I don't understand what we are racing here against.  If we see a huge
pmd, it may split.  But we hold mmap_sem in write-mode, I don't see
how a regular pmd could become huge all of a sudden at this point.

	Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
