Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id A53F96B004A
	for <linux-mm@kvack.org>; Thu, 23 Feb 2012 15:12:43 -0500 (EST)
Date: Thu, 23 Feb 2012 12:12:38 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: hugetlb: bail out unmapping after serving reference
 page
Message-Id: <20120223121238.b597e7e4.akpm@linux-foundation.org>
In-Reply-To: <CAJd=RBA53nS70Q7GEeskKFas-hfg4GKmUf=Zut5anSN0P+d1KA@mail.gmail.com>
References: <CAJd=RBALNtedfq+PLPnGKd4i4D0mLiVPdW_7pWWopnSZNC_vqA@mail.gmail.com>
	<20120222130659.d75b6f69.akpm@linux-foundation.org>
	<CAJd=RBA53nS70Q7GEeskKFas-hfg4GKmUf=Zut5anSN0P+d1KA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>

On Thu, 23 Feb 2012 21:05:41 +0800
Hillf Danton <dhillf@gmail.com> wrote:

> and a follow-up cleanup also attached.

Please, never put more than one patches in an email - it is rather a
pain to manually unpick everything.

> When unmapping given VM range, a couple of code duplicate, such as pte_page()
> and huge_pte_none(), so a cleanup needed to compact them together.
> 
> Signed-off-by: Hillf Danton <dhillf@gmail.com>
> ---
> 
> --- a/mm/hugetlb.c	Thu Feb 23 20:13:06 2012
> +++ b/mm/hugetlb.c	Thu Feb 23 20:30:16 2012
> @@ -2245,16 +2245,23 @@ void __unmap_hugepage_range(struct vm_ar
>  		if (huge_pmd_unshare(mm, &address, ptep))
>  			continue;
> 
> +		pte = huge_ptep_get(ptep);
> +		if (huge_pte_none(pte))
> +			continue;
> +
> +		/*
> +		 * HWPoisoned hugepage is already unmapped and dropped reference
> +		 */
> +		if (unlikely(is_hugetlb_entry_hwpoisoned(pte)))
> +			continue;
> +
> +		page = pte_page(pte);
>  		/*
>  		 * If a reference page is supplied, it is because a specific
>  		 * page is being unmapped, not a range. Ensure the page we
>  		 * are about to unmap is the actual page of interest.
>  		 */
>  		if (ref_page) {
> -			pte = huge_ptep_get(ptep);
> -			if (huge_pte_none(pte))
> -				continue;
> -			page = pte_page(pte);
>  			if (page != ref_page)
>  				continue;
> 
> @@ -2267,16 +2274,6 @@ void __unmap_hugepage_range(struct vm_ar
>  		}
> 
>  		pte = huge_ptep_get_and_clear(mm, address, ptep);
> -		if (huge_pte_none(pte))
> -			continue;
> -
> -		/*
> -		 * HWPoisoned hugepage is already unmapped and dropped reference
> -		 */
> -		if (unlikely(is_hugetlb_entry_hwpoisoned(pte)))
> -			continue;
> -
> -		page = pte_page(pte);
>  		if (pte_dirty(pte))
>  			set_page_dirty(page);
>  		list_add(&page->lru, &page_list);

This changes behaviour when ref_page refers to a hwpoisoned page.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
