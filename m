Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 700596B0005
	for <linux-mm@kvack.org>; Thu,  4 Apr 2013 09:46:01 -0400 (EDT)
Date: Thu, 4 Apr 2013 15:45:45 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] THP: Use explicit memory barrier
Message-ID: <20130404134545.GF3423@redhat.com>
References: <1364773535-26264-1-git-send-email-minchan@kernel.org>
 <alpine.DEB.2.02.1304011634530.21603@chino.kir.corp.google.com>
 <20130402003746.GA30444@blaptop>
 <alpine.LNX.2.00.1304021221240.5808@eggly.anvils>
 <20130403001401.GC16026@blaptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130403001401.GC16026@blaptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>

On Wed, Apr 03, 2013 at 09:14:01AM +0900, Minchan Kim wrote:
>  	clear_huge_page(page, haddr, HPAGE_PMD_NR);
> +	/*
> +	 * The memory barrier inside __SetPageUptodate makes sure that
> +	 * clear_huge_page writes become visible after the set_pmd_at()

s/after/before/

> +	 * write.
> +	 */
>  	__SetPageUptodate(page);
>  
>  	spin_lock(&mm->page_table_lock);
> @@ -724,12 +729,6 @@ static int __do_huge_pmd_anonymous_page(struct mm_struct *mm,
>  	} else {
>  		pmd_t entry;
>  		entry = mk_huge_pmd(page, vma);
> -		/*
> -		 * The spinlocking to take the lru_lock inside
> -		 * page_add_new_anon_rmap() acts as a full memory
> -		 * barrier to be sure clear_huge_page writes become
> -		 * visible after the set_pmd_at() write.
> -		 */
>  		page_add_new_anon_rmap(page, vma, haddr);
>  		set_pmd_at(mm, haddr, pmd, entry);
>  		pgtable_trans_huge_deposit(mm, pgtable);
> diff --git a/mm/memory.c b/mm/memory.c
> index 494526a..d0da51e 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -3196,6 +3196,11 @@ static int do_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
>  	page = alloc_zeroed_user_highpage_movable(vma, address);
>  	if (!page)
>  		goto oom;
> +	/*
> +	 * The memory barrier inside __SetPageUptodate makes sure that
> +	 * preceeding stores to the page contents become visible after
> +	 * the set_pte_at() write.
> +	 */

s/after/before/

After the above correction it looks nice cleanup, thanks!

Acked-by: Andrea Arcangeli <aarcange@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
