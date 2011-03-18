Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id E16658D0039
	for <linux-mm@kvack.org>; Fri, 18 Mar 2011 03:30:26 -0400 (EDT)
Received: by iwl42 with SMTP id 42so5137855iwl.14
        for <linux-mm@kvack.org>; Fri, 18 Mar 2011 00:29:58 -0700 (PDT)
From: Nai Xia <nai.xia@gmail.com>
Reply-To: nai.xia@gmail.com
Subject: Re: [PATCH] ksm: add vm_stat and meminfo entry to reflect pte mapping to ksm pages
Date: Fri, 18 Mar 2011 15:29:43 +0800
References: <201102262256.31565.nai.xia@gmail.com> <20110302143142.a3c0002b.akpm@linux-foundation.org>
In-Reply-To: <20110302143142.a3c0002b.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <201103181529.43659.nai.xia@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrea Arcangeli <aarcange@redhat.com>, Chris Wright <chrisw@sous-sol.org>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-janitors@vger.kernel.org


>On Thursday 03 March 2011, at 06:31:42, <Andrew Morton <akpm@linux-foundation.org>> wrote
> This patch obviously wasn't tested with CONFIG_KSM=n, which was a
> pretty basic patch-testing failure :(

Oops, I will be careful to avoid similar mistakes next time.

> 
> I fixed up my tree with the below, but really the amount of ifdeffing
> is unacceptable - please find a cleaner way to fix up this patch.

Ok, I will have a try in my next patch submit. 

Thanks,
-Nai
> 
> --- a/mm/ksm.c~ksm-add-vm_stat-and-meminfo-entry-to-reflect-pte-mapping-to-ksm-pages-fix
> +++ a/mm/ksm.c
> @@ -883,7 +883,6 @@ static int try_to_merge_one_page(struct 
>  	 */
>  	if (write_protect_page(vma, page, &orig_pte) == 0) {
>  		if (!kpage) {
> -			long mapcount = page_mapcount(page);
>  			/*
>  			 * While we hold page lock, upgrade page from
>  			 * PageAnon+anon_vma to PageKsm+NULL stable_node:
> @@ -891,10 +890,12 @@ static int try_to_merge_one_page(struct 
>  			 */
>  			set_page_stable_node(page, NULL);
>  			mark_page_accessed(page);
> -			if (mapcount)
> +#ifdef CONFIG_KSM
> +			if (page_mapcount(page))
>  				add_zone_page_state(page_zone(page),
>  						    NR_KSM_PAGES_SHARING,
>  						    mapcount);
> +#endif
>  			err = 0;
>  		} else if (pages_identical(page, kpage))
>  			err = replace_page(vma, page, kpage, orig_pte);
> --- a/mm/memory.c~ksm-add-vm_stat-and-meminfo-entry-to-reflect-pte-mapping-to-ksm-pages-fix
> +++ a/mm/memory.c
> @@ -719,8 +719,10 @@ copy_one_pte(struct mm_struct *dst_mm, s
>  			rss[MM_ANONPAGES]++;
>  		else
>  			rss[MM_FILEPAGES]++;
> +#ifdef CONFIG_KSM
>  		if (PageKsm(page)) /* follows page_dup_rmap() */
>  			inc_zone_page_state(page, NR_KSM_PAGES_SHARING);
> +#endif
>  	}
>  
>  out_set_pte:
> --- a/mm/rmap.c~ksm-add-vm_stat-and-meminfo-entry-to-reflect-pte-mapping-to-ksm-pages-fix
> +++ a/mm/rmap.c
> @@ -893,11 +893,12 @@ void do_page_add_anon_rmap(struct page *
>  			__inc_zone_page_state(page,
>  					      NR_ANON_TRANSPARENT_HUGEPAGES);
>  	}
> +#ifdef CONFIG_KSM
>  	if (unlikely(PageKsm(page))) {
>  		__inc_zone_page_state(page, NR_KSM_PAGES_SHARING);
>  		return;
>  	}
> -
> +#endif
>  	VM_BUG_ON(!PageLocked(page));
>  	VM_BUG_ON(address < vma->vm_start || address >= vma->vm_end);
>  	if (first)
> @@ -955,9 +956,10 @@ void page_add_file_rmap(struct page *pag
>   */
>  void page_remove_rmap(struct page *page)
>  {
> +#ifdef CONFIG_KSM
>  	if (PageKsm(page))
>  		__dec_zone_page_state(page, NR_KSM_PAGES_SHARING);
> -
> +#endif
>  	/* page still mapped by someone else? */
>  	if (!atomic_add_negative(-1, &page->_mapcount))
>  		return;
> _
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
