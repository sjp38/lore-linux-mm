Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id ABF7D8D0039
	for <linux-mm@kvack.org>; Tue, 22 Feb 2011 08:35:46 -0500 (EST)
Date: Tue, 22 Feb 2011 14:35:20 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 4/5] teach smaps_pte_range() about THP pmds
Message-ID: <20110222133520.GS13092@random.random>
References: <20110222015338.309727CA@kernel>
 <20110222015343.41586948@kernel>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110222015343.41586948@kernel>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael J Wolf <mjwolf@us.ibm.com>, akpm@osdl.org, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>

On Mon, Feb 21, 2011 at 05:53:43PM -0800, Dave Hansen wrote:
> @@ -385,8 +387,25 @@ static int smaps_pte_range(pmd_t *pmd, u
>  	pte_t *pte;
>  	spinlock_t *ptl;
>  
> -	split_huge_page_pmd(walk->mm, pmd);
> -
> +	spin_lock(&walk->mm->page_table_lock);
> +	if (pmd_trans_huge(*pmd)) {
> +		if (pmd_trans_splitting(*pmd)) {
> +			spin_unlock(&walk->mm->page_table_lock);
> +			wait_split_huge_page(vma->anon_vma, pmd);
> +		} else {
> +			smaps_pte_entry(*(pte_t *)pmd, addr,
> +					HPAGE_PMD_SIZE, walk);
> +			spin_unlock(&walk->mm->page_table_lock);
> +			return 0;
> +		}
> +	} else {
> +		spin_unlock(&walk->mm->page_table_lock);
> +	}
> +	/*
> +	 * The mmap_sem held all the way back in m_start() is what
> +	 * keeps khugepaged out of here and from collapsing things
> +	 * in here.
> +	 */

This time the locking is right and HPAGE_PMD_SIZE is used instead of
HPAGE_SIZE, thanks! I think all 5 patches can go in -mm and upstream
anytime (not mandatory for 2.6.38 but definitely we want this for
2.6.39).

BTW, Andi in his NUMA THP improvement series added a THP_SPLIT vmstat
per-cpu counter so that part removed from his series, is taken care by
him.

Acked-by: Andrea Arcangeli <aarcange@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
