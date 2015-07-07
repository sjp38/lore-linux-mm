Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id AA2786B0038
	for <linux-mm@kvack.org>; Tue,  7 Jul 2015 09:47:16 -0400 (EDT)
Received: by pdbep18 with SMTP id ep18so126241585pdb.1
        for <linux-mm@kvack.org>; Tue, 07 Jul 2015 06:47:16 -0700 (PDT)
Received: from mail-pd0-x22c.google.com (mail-pd0-x22c.google.com. [2607:f8b0:400e:c02::22c])
        by mx.google.com with ESMTPS id w8si34799491pdr.164.2015.07.07.06.47.15
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Jul 2015 06:47:15 -0700 (PDT)
Received: by pdbci14 with SMTP id ci14so126225156pdb.2
        for <linux-mm@kvack.org>; Tue, 07 Jul 2015 06:47:15 -0700 (PDT)
Date: Tue, 7 Jul 2015 22:47:08 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v2] mm: show proportional swap share of the mapping
Message-ID: <20150707134708.GE3898@blaptop>
References: <1434373614-1041-1-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1434373614-1041-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Bongkyu Kim <bongkyu.kim@lge.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Jonathan Corbet <corbet@lwn.net>

It seems merge windows is closed so bump up.

On Mon, Jun 15, 2015 at 10:06:54PM +0900, Minchan Kim wrote:
> We want to know per-process workingset size for smart memory management
> on userland and we use swap(ex, zram) heavily to maximize memory efficiency
> so workingset includes swap as well as RSS.
> 
> On such system, if there are lots of shared anonymous pages, it's
> really hard to figure out exactly how many each process consumes
> memory(ie, rss + wap) if the system has lots of shared anonymous
> memory(e.g, android).
> 
> This patch introduces SwapPss field on /proc/<pid>/smaps so we can get
> more exact workingset size per process.
> 
> Bongkyu tested it. Result is below.
> 
> 1. 50M used swap
> SwapTotal: 461976 kB
> SwapFree: 411192 kB
> 
> $ adb shell cat /proc/*/smaps | grep "SwapPss:" | awk '{sum += $2} END {print sum}';
> 48236
> $ adb shell cat /proc/*/smaps | grep "Swap:" | awk '{sum += $2} END {print sum}';
> 141184
> 
> 2. 240M used swap
> SwapTotal: 461976 kB
> SwapFree: 216808 kB
> 
> $ adb shell cat /proc/*/smaps | grep "SwapPss:" | awk '{sum += $2} END {print sum}';
> 230315
> $ adb shell cat /proc/*/smaps | grep "Swap:" | awk '{sum += $2} END {print sum}';
> 1387744
> 
> * from v1
>   * add more description - Andrew
>   * swp_swacount fix on !CONFIG_SWP - Sergey
>   * add what PSS is to proc.txt - Andrew
>     * Bring quote from lwn.net - Corbet
>       * http://lwn.net/Articles/230975/
> 
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
> Cc: Jonathan Corbet <corbet@lwn.net>
> Report-and-Tested-by: Bongkyu Kim <bongkyu.kim@lge.com>
> Signed-off-by: Minchan Kim <minchan@kernel.org>
> ---
>  Documentation/filesystems/proc.txt | 18 +++++++++++-----
>  fs/proc/task_mmu.c                 | 18 ++++++++++++++--
>  include/linux/swap.h               |  6 ++++++
>  mm/swapfile.c                      | 42 ++++++++++++++++++++++++++++++++++++++
>  4 files changed, 77 insertions(+), 7 deletions(-)
> 
> diff --git a/Documentation/filesystems/proc.txt b/Documentation/filesystems/proc.txt
> index c3b6b301d8b0..cfc765e6cfa6 100644
> --- a/Documentation/filesystems/proc.txt
> +++ b/Documentation/filesystems/proc.txt
> @@ -423,6 +423,7 @@ Private_Dirty:         0 kB
>  Referenced:          892 kB
>  Anonymous:             0 kB
>  Swap:                  0 kB
> +SwapPss:               0 kB
>  KernelPageSize:        4 kB
>  MMUPageSize:           4 kB
>  Locked:              374 kB
> @@ -432,16 +433,23 @@ the first of these lines shows the same information as is displayed for the
>  mapping in /proc/PID/maps.  The remaining lines show the size of the mapping
>  (size), the amount of the mapping that is currently resident in RAM (RSS), the
>  process' proportional share of this mapping (PSS), the number of clean and
> -dirty private pages in the mapping.  Note that even a page which is part of a
> -MAP_SHARED mapping, but has only a single pte mapped, i.e.  is currently used
> -by only one process, is accounted as private and not as shared.  "Referenced"
> -indicates the amount of memory currently marked as referenced or accessed.
> +dirty private pages in the mapping.
> +
> +The "proportional set size" (PSS) of a process is the count of pages it has
> +in memory, where each page is divided by the number of processes sharing it.
> +So if a process has 1000 pages all to itself, and 1000 shared with one other
> +process, its PSS will be 1500.
> +Note that even a page which is part of a MAP_SHARED mapping, but has only
> +a single pte mapped, i.e.  is currently used by only one process, is accounted
> +as private and not as shared.
> +"Referenced" indicates the amount of memory currently marked as referenced or
> +accessed.
>  "Anonymous" shows the amount of memory that does not belong to any file.  Even
>  a mapping associated with a file may contain anonymous pages: when MAP_PRIVATE
>  and a page is modified, the file page is replaced by a private anonymous copy.
>  "Swap" shows how much would-be-anonymous memory is also used, but out on
>  swap.
> -
> +"SwapPss" shows proportional swap share of this mapping.
>  "VmFlags" field deserves a separate description. This member represents the kernel
>  flags associated with the particular virtual memory area in two letter encoded
>  manner. The codes are the following:
> diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> index 6dee68d013ff..d537899f4b25 100644
> --- a/fs/proc/task_mmu.c
> +++ b/fs/proc/task_mmu.c
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
> @@ -638,6 +650,7 @@ static int show_smap(struct seq_file *m, void *v, int is_pid)
>  		   "Anonymous:      %8lu kB\n"
>  		   "AnonHugePages:  %8lu kB\n"
>  		   "Swap:           %8lu kB\n"
> +		   "SwapPss:        %8lu kB\n"
>  		   "KernelPageSize: %8lu kB\n"
>  		   "MMUPageSize:    %8lu kB\n"
>  		   "Locked:         %8lu kB\n",
> @@ -652,6 +665,7 @@ static int show_smap(struct seq_file *m, void *v, int is_pid)
>  		   mss.anonymous >> 10,
>  		   mss.anonymous_thp >> 10,
>  		   mss.swap >> 10,
> +		   (unsigned long)(mss.swap_pss >> (10 + PSS_SHIFT)),
>  		   vma_kernel_pagesize(vma) >> 10,
>  		   vma_mmu_pagesize(vma) >> 10,
>  		   (vma->vm_flags & VM_LOCKED) ?
> diff --git a/include/linux/swap.h b/include/linux/swap.h
> index cee108cbe2d5..afc9eb3cba48 100644
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
> @@ -523,6 +524,11 @@ static inline int page_swapcount(struct page *page)
>  	return 0;
>  }
>  
> +static inline int swp_swapcount(swp_entry_t entry)
> +{
> +	return 0;
> +}
> +
>  #define reuse_swap_page(page)	(page_mapcount(page) == 1)
>  
>  static inline int try_to_free_swap(struct page *page)
> diff --git a/mm/swapfile.c b/mm/swapfile.c
> index a7e72103f23b..7a6bd1e5a8e9 100644
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
> -- 
> 1.9.1
> 

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
