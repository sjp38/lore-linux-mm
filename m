Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 995766B0070
	for <linux-mm@kvack.org>; Tue,  9 Jun 2015 20:05:43 -0400 (EDT)
Received: by payr10 with SMTP id r10so22749236pay.1
        for <linux-mm@kvack.org>; Tue, 09 Jun 2015 17:05:43 -0700 (PDT)
Received: from mail-pd0-x230.google.com (mail-pd0-x230.google.com. [2607:f8b0:400e:c02::230])
        by mx.google.com with ESMTPS id to2si10898695pbc.161.2015.06.09.17.05.42
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Jun 2015 17:05:42 -0700 (PDT)
Received: by pdjn11 with SMTP id n11so24755209pdj.0
        for <linux-mm@kvack.org>; Tue, 09 Jun 2015 17:05:42 -0700 (PDT)
Date: Wed, 10 Jun 2015 09:06:09 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH] mm: show proportional swap share of the mapping
Message-ID: <20150610000609.GA596@swordfish>
References: <1433861031-13233-1-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1433861031-13233-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Bongkyu Kim <bongkyu.kim@lge.com>

Hello,

On (06/09/15 23:43), Minchan Kim wrote:
[..]
> @@ -446,6 +446,7 @@ struct mem_size_stats {
>  	unsigned long anonymous_thp;
>  	unsigned long swap;
>  	u64 pss;
> +	u64 swap_pss;
>  };
>  
>  static void smaps_account(struct mem_size_stats *mss, struct page *page,
> @@ -492,9 +493,20 @@ static void smaps_pte_entry(pte_t *pte, unsigned long addr,
>  	} else if (is_swap_pte(*pte)) {
>  		swp_entry_t swpent = pte_to_swp_entry(*pte);
>  
> -		if (!non_swap_entry(swpent))
> +		if (!non_swap_entry(swpent)) {
> +			int mapcount;
> +
>  			mss->swap += PAGE_SIZE;
> -		else if (is_migration_entry(swpent))
> +			mapcount = swp_swapcount(swpent);

I think this will break swapless builds (CONFIG_SWAP=n builds).

	-ss

> +			if (mapcount >= 2) {
> +				u64 pss_delta = (u64)PAGE_SIZE << PSS_SHIFT;
> +
> +				do_div(pss_delta, mapcount);
> +				mss->swap_pss += pss_delta;
> +			} else {
> +				mss->swap_pss += (u64)PAGE_SIZE << PSS_SHIFT;
> +			}
> +		} else if (is_migration_entry(swpent))
>  			page = migration_entry_to_page(swpent);
>  	}
>  
> @@ -640,6 +652,7 @@ static int show_smap(struct seq_file *m, void *v, int is_pid)
>  		   "Anonymous:      %8lu kB\n"
>  		   "AnonHugePages:  %8lu kB\n"
>  		   "Swap:           %8lu kB\n"
> +		   "SwapPss:        %8lu kB\n"
>  		   "KernelPageSize: %8lu kB\n"
>  		   "MMUPageSize:    %8lu kB\n"
>  		   "Locked:         %8lu kB\n",
> @@ -654,6 +667,7 @@ static int show_smap(struct seq_file *m, void *v, int is_pid)
>  		   mss.anonymous >> 10,
>  		   mss.anonymous_thp >> 10,
>  		   mss.swap >> 10,
> +		   (unsigned long)(mss.swap_pss >> (10 + PSS_SHIFT)),
>  		   vma_kernel_pagesize(vma) >> 10,
>  		   vma_mmu_pagesize(vma) >> 10,
>  		   (vma->vm_flags & VM_LOCKED) ?
> diff --git a/include/linux/swap.h b/include/linux/swap.h
> index 9a7adfb..402a24b 100644
> --- a/include/linux/swap.h
> +++ b/include/linux/swap.h
> @@ -432,6 +432,7 @@ extern unsigned int count_swap_pages(int, int);
>  extern sector_t map_swap_page(struct page *, struct block_device **);
>  extern sector_t swapdev_block(int, pgoff_t);
>  extern int page_swapcount(struct page *);
> +extern int swp_swapcount(swp_entry_t entry);
>  extern struct swap_info_struct *page_swap_info(struct page *);
>  extern int reuse_swap_page(struct page *);
>  extern int try_to_free_swap(struct page *);
> diff --git a/mm/swapfile.c b/mm/swapfile.c
> index a7e7210..7a6bd1e 100644
> --- a/mm/swapfile.c
> +++ b/mm/swapfile.c
> @@ -875,6 +875,48 @@ int page_swapcount(struct page *page)
>  }
>  
>  /*
> + * How many references to @entry are currently swapped out?
> + * This considers COUNT_CONTINUED so it returns exact answer.
> + */
> +int swp_swapcount(swp_entry_t entry)
> +{
> +	int count, tmp_count, n;
> +	struct swap_info_struct *p;
> +	struct page *page;
> +	pgoff_t offset;
> +	unsigned char *map;
> +
> +	p = swap_info_get(entry);
> +	if (!p)
> +		return 0;
> +
> +	count = swap_count(p->swap_map[swp_offset(entry)]);
> +	if (!(count & COUNT_CONTINUED))
> +		goto out;
> +
> +	count &= ~COUNT_CONTINUED;
> +	n = SWAP_MAP_MAX + 1;
> +
> +	offset = swp_offset(entry);
> +	page = vmalloc_to_page(p->swap_map + offset);
> +	offset &= ~PAGE_MASK;
> +	VM_BUG_ON(page_private(page) != SWP_CONTINUED);
> +
> +	do {
> +		page = list_entry(page->lru.next, struct page, lru);
> +		map = kmap_atomic(page) + offset;
> +		tmp_count = *map;
> +		kunmap_atomic(map);
> +
> +		count += (tmp_count & ~COUNT_CONTINUED) * n;
> +		n *= (SWAP_CONT_MAX + 1);
> +	} while (tmp_count & COUNT_CONTINUED);
> +out:
> +	spin_unlock(&p->lock);
> +	return count;
> +}
> +
> +/*
>   * We can write to an anon page without COW if there are no other references
>   * to it.  And as a side-effect, free up its swap: because the old content
>   * on disk will never be read, and seeking back there to write new content

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
