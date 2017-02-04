Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 72EFD6B0033
	for <linux-mm@kvack.org>; Sat,  4 Feb 2017 01:38:29 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id 204so47950759pfx.1
        for <linux-mm@kvack.org>; Fri, 03 Feb 2017 22:38:29 -0800 (PST)
Received: from out4441.biz.mail.alibaba.com (out4441.biz.mail.alibaba.com. [47.88.44.41])
        by mx.google.com with ESMTP id u88si27608997pfi.55.2017.02.03.22.38.27
        for <linux-mm@kvack.org>;
        Fri, 03 Feb 2017 22:38:28 -0800 (PST)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <cover.1486163864.git.shli@fb.com> <3914c9f53c343357c39cb891210da31aa30ad3a9.1486163864.git.shli@fb.com>
In-Reply-To: <3914c9f53c343357c39cb891210da31aa30ad3a9.1486163864.git.shli@fb.com>
Subject: Re: [PATCH V2 2/7] mm: move MADV_FREE pages into LRU_INACTIVE_FILE list
Date: Sat, 04 Feb 2017 14:38:07 +0800
Message-ID: <007e01d27eb1$3f98dee0$beca9ca0$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Shaohua Li' <shli@fb.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Kernel-team@fb.com, danielmicay@gmail.com, mhocko@suse.com, minchan@kernel.org, hughd@google.com, hannes@cmpxchg.org, riel@redhat.com, mgorman@techsingularity.net, akpm@linux-foundation.org

On February 04, 2017 7:33 AM Shaohua Li wrote: 
> @@ -1404,6 +1401,8 @@ bool madvise_free_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
>  		set_pmd_at(mm, addr, pmd, orig_pmd);
>  		tlb_remove_pmd_tlb_entry(tlb, pmd, addr);
>  	}
> +
> +	mark_page_lazyfree(page);
>  	ret = true;
>  out:
>  	spin_unlock(ptl);

<snipped>

> -void deactivate_page(struct page *page)
> -{
> -	if (PageLRU(page) && PageActive(page) && !PageUnevictable(page)) {
> -		struct pagevec *pvec = &get_cpu_var(lru_deactivate_pvecs);
> +void mark_page_lazyfree(struct page *page)
> + {
> +	if (PageLRU(page) && PageAnon(page) && PageSwapBacked(page) &&
> +	    !PageUnevictable(page)) {
> +		struct pagevec *pvec = &get_cpu_var(lru_lazyfree_pvecs);
> 
>  		get_page(page);
>  		if (!pagevec_add(pvec, page) || PageCompound(page))
> -			pagevec_lru_move_fn(pvec, lru_deactivate_fn, NULL);
> -		put_cpu_var(lru_deactivate_pvecs);
> +			pagevec_lru_move_fn(pvec, lru_lazyfree_fn, NULL);
> +		put_cpu_var(lru_lazyfree_pvecs);
>  	}
>  }

You are not adding it but would you please try to fix or avoid flipping
preempt count with page table lock hold?

thanks
Hillf


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
