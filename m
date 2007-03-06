Date: Tue, 6 Mar 2007 10:30:43 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [rfc][patch 2/2] mm: mlocked pages off LRU
In-Reply-To: <20070306143045.GA28629@wotan.suse.de>
Message-ID: <Pine.LNX.4.64.0703061022270.24461@schroedinger.engr.sgi.com>
References: <20070305161746.GD8128@wotan.suse.de>
 <Pine.LNX.4.64.0703050948040.6620@schroedinger.engr.sgi.com>
 <20070306010529.GB23845@wotan.suse.de> <Pine.LNX.4.64.0703051723240.16842@schroedinger.engr.sgi.com>
 <20070306014403.GD23845@wotan.suse.de> <Pine.LNX.4.64.0703051753070.16964@schroedinger.engr.sgi.com>
 <20070306021307.GE23845@wotan.suse.de> <Pine.LNX.4.64.0703051845050.17203@schroedinger.engr.sgi.com>
 <20070306025016.GA1912@wotan.suse.de> <20070306143045.GA28629@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Christoph Lameter <clameter@engr.sgi.com>, Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>
List-ID: <linux-mm.kvack.org>

On Tue, 6 Mar 2007, Nick Piggin wrote:

> +	struct mm_struct *mm = vma->vm_mm;
> +	unsigned long addr = start;
> +	struct page *pages[16]; /* 16 gives a reasonable batch */

Use a pagevec instead?


> +		/*
> +		 * get_user_pages makes pages present if we are
> +		 * setting mlock.
> +		 */
> +		ret = get_user_pages(current, mm, addr,
> +				min_t(int, nr_pages, ARRAY_SIZE(pages)),
> +				write, 0, pages, NULL);
> +		if (ret < 0)
> +			break;
> +		if (ret == 0) {
> +			/*
> +			 * We know the vma is there, so the only time
> +			 * we cannot get a single page should be an
> +			 * error (ret < 0) case.
> +			 */
> +			WARN_ON(1);
> +			ret = -EFAULT;
> +			break;
> +		}

... pages could be evicted here by reclaim?

> +
> +		for (i = 0; i < ret; i++) {
> +			struct page *page = pages[i];
> +			lock_page(page);
> +			if (lock) {
> +				/*
> +				 * Anonymous pages may have already been
> +				 * mlocked by get_user_pages->handle_mm_fault.
> +				 * Be conservative and don't count these:


> @@ -801,8 +815,21 @@ static int try_to_unmap_anon(struct page
>  		ret = try_to_unmap_one(page, vma, migration);
>  		if (ret == SWAP_FAIL || !page_mapped(page))
>  			break;
> +		if (ret == SWAP_MLOCK) {
> +			if (down_read_trylock(&vma->vm_mm->mmap_sem)) {
> +				if (vma->vm_flags & VM_LOCKED) {
> +					mlock_vma_page(page);
> +					mlocked++;
> +				}
> +				up_read(&vma->vm_mm->mmap_sem);
> +			}
> +		}

Taking mmap_sem in try_to_unmap_one? It may already have been taken by 
page migration. Ok, trylock but still.

>  			goto out;
> +		if (ret == SWAP_MLOCK) {
> +			if (down_read_trylock(&vma->vm_mm->mmap_sem)) {
> +				if (vma->vm_flags & VM_LOCKED) {
> +					mlock_vma_page(page);
> +					mlocked++;
> +				}
> +				up_read(&vma->vm_mm->mmap_sem);
> +			}


Well this piece of code seem to repeat itself. New function?

> @@ -2148,7 +2196,10 @@ static int do_anonymous_page(struct mm_s
>  		if (!pte_none(*page_table))
>  			goto release;
>  		inc_mm_counter(mm, anon_rss);
> -		lru_cache_add_active(page);
> +		if (!(vma->vm_flags & VM_LOCKED))
> +			lru_cache_add_active(page);
> +		else
> +			mlock_new_vma_page(page);
>  		page_add_new_anon_rmap(page, vma, address);
>  	} else {
>  		/* Map the ZERO_PAGE - vm_page_prot is readonly */
> @@ -2291,7 +2342,10 @@ static int __do_fault(struct mm_struct *
>  		set_pte_at(mm, address, page_table, entry);
>  		if (anon) {
>                          inc_mm_counter(mm, anon_rss);
> -                        lru_cache_add_active(page);
> +			if (!(vma->vm_flags & VM_LOCKED))
> +				lru_cache_add_active(page);
> +			else
> +				mlock_new_vma_page(page);
>                          page_add_new_anon_rmap(page, vma, address);
>  		} else {

Another repeating chunk of code?

> Index: linux-2.6/drivers/base/node.c
> ===================================================================
> --- linux-2.6.orig/drivers/base/node.c
> +++ linux-2.6/drivers/base/node.c
> @@ -60,6 +60,7 @@ static ssize_t node_read_meminfo(struct 
>  		       "Node %d FilePages:    %8lu kB\n"
>  		       "Node %d Mapped:       %8lu kB\n"
>  		       "Node %d AnonPages:    %8lu kB\n"
> +		       "Node %d MLock:        %8lu kB\n"

Upper case L in MLock? Should it not be Mlock from mlock with first letter 
capitalized?

> Index: linux-2.6/include/linux/mmzone.h
> ===================================================================
> --- linux-2.6.orig/include/linux/mmzone.h
> +++ linux-2.6/include/linux/mmzone.h
> @@ -54,6 +54,7 @@ enum zone_stat_item {
>  	NR_ANON_PAGES,	/* Mapped anonymous pages */
>  	NR_FILE_MAPPED,	/* pagecache pages mapped into pagetables.
>  			   only modified from process context */
> +	NR_MLOCK,	/* MLocked pages (conservative guess) */

Discovered mlocked pages?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
