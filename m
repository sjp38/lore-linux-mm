Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 068195F0001
	for <linux-mm@kvack.org>; Fri, 10 Apr 2009 02:10:03 -0400 (EDT)
Date: Thu, 9 Apr 2009 23:02:05 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH][1/2]page_fault retry with NOPAGE_RETRY
Message-Id: <20090409230205.310c68a7.akpm@linux-foundation.org>
In-Reply-To: <604427e00904081302m7b29c538u7781cd8f4dd576f2@mail.gmail.com>
References: <604427e00904081302m7b29c538u7781cd8f4dd576f2@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Ying Han <yinghan@google.com>
Cc: linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>, torvalds@linux-foundation.org, Ingo Molnar <mingo@elte.hu>, Mike Waychison <mikew@google.com>, Rohit Seth <rohitseth@google.com>, Hugh Dickins <hugh@veritas.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "H. Peter Anvin" <hpa@zytor.com>, =?ISO-8859-1?Q?T=F6r=F6k?= Edwin <edwintorok@gmail.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Nick Piggin <npiggin@suse.de>, Wu Fengguang <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>


> Subject: [PATCH][1/2]page_fault retry with NOPAGE_RETRY

Please give each patch in the series a unique and meaningful title.

On Wed, 8 Apr 2009 13:02:35 -0700 Ying Han <yinghan@google.com> wrote:

> support for FAULT_FLAG_RETRY with no user change:

yup, we'd prefer a complete changelog here please.

> Signed-off-by: Ying Han <yinghan@google.com>
> 	       Mike Waychison <mikew@google.com>

This form:

Signed-off-by: Ying Han <yinghan@google.com>
Signed-off-by: Mike Waychison <mikew@google.com>

is conventional.

> index 4a853ef..29c2c39 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -793,7 +793,7 @@ struct file_ra_state {
>  					   there are only # of pages ahead */
> 
>  	unsigned int ra_pages;		/* Maximum readahead window */
> -	int mmap_miss;			/* Cache miss stat for mmap accesses */
> +	unsigned int mmap_miss;		/* Cache miss stat for mmap accesses */

This change makes sense, but we're not told the reasons for making it? 
Did it fix a bug, or is it an unrelated fixlet, or...?

>  	loff_t prev_pos;		/* Cache last read() position */
>  };
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index ffee2f7..5a134a9 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -144,6 +144,7 @@ extern pgprot_t protection_map[16];
> 
>  #define FAULT_FLAG_WRITE	0x01	/* Fault was a write access */
>  #define FAULT_FLAG_NONLINEAR	0x02	/* Fault was via a nonlinear mapping */
> +#define FAULT_FLAG_RETRY	0x04	/* Retry major fault */
> 
> 
>  /*
> @@ -690,6 +691,7 @@ static inline int page_mapped(struct page *page)
> 
>  #define VM_FAULT_MINOR	0 /* For backwards compat. Remove me quickly. */
> 
> +#define VM_FAULT_RETRY	0x0010
>  #define VM_FAULT_OOM	0x0001
>  #define VM_FAULT_SIGBUS	0x0002
>  #define VM_FAULT_MAJOR	0x0004
> diff --git a/mm/filemap.c b/mm/filemap.c
> index f3e5f89..6eb7c36 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -714,6 +714,58 @@ repeat:
>  EXPORT_SYMBOL(find_lock_page);
> 
>  /**
> + * find_lock_page_retry - locate, pin and lock a pagecache page
> + * @mapping: the address_space to search
> + * @offset: the page index
> + * @vma: vma in which the fault was taken
> + * @ppage: zero if page not present, otherwise point to the page in pagecache
> + * @retry: 1 indicate caller tolerate a retry.
> + *
> + * If retry flag is on, and page is already locked by someone else, return
> + * a hint of retry and leave *ppage untouched.
> + *
> + * Return *ppage==NULL if page is not in pagecache. Otherwise return *ppage
> + * points to the page in the pagecache with ret=VM_FAULT_RETRY indicate a
> + * hint to caller for retry, or ret=0 which means page is succefully
> + * locked.
> + */

How about this:

  If the page was not found in pagecache, find_lock_page_retry()
  returns 0 and sets *@ppage to NULL.

  If the page was found in pagecache but is locked and @retry is
  true, find_lock_page_retry() returns VM_FAULT_RETRY and does not
  write to *@ppage.

  If the page was found in pagecache and @retry is false,
  find_lock_page_retry() locks the page, writes its address to *@ppage
  and returns 0.

> +unsigned find_lock_page_retry(struct address_space *mapping, pgoff_t offset,
> +				struct vm_area_struct *vma, struct page **ppage,
> +				int retry)
> +{
> +	unsigned int ret = 0;
> +	struct page *page;
> +
> +repeat:
> +	page = find_get_page(mapping, offset);
> +	if (page) {
> +		if (!retry)
> +			lock_page(page);
> +		else {
> +			if (!trylock_page(page)) {
> +				struct mm_struct *mm = vma->vm_mm;
> +
> +				up_read(&mm->mmap_sem);
> +				wait_on_page_locked(page);

It looks strange that we wait for the page lock and then don't
just lock the page and return it.

Adding a comment explaining _why_ we do this would be nice.

> +				down_read(&mm->mmap_sem);
> +
> +				page_cache_release(page);
> +				return VM_FAULT_RETRY;
> +			}
> +		}
> +		if (unlikely(page->mapping != mapping)) {
> +			unlock_page(page);
> +			page_cache_release(page);
> +			goto repeat;
> +		}
> +		VM_BUG_ON(page->index != offset);
> +	}
> +	*ppage = page;
> +	return ret;
> +}
> +EXPORT_SYMBOL(find_lock_page_retry);
> +
> +/**
>   * find_or_create_page - locate or add a pagecache page
>   * @mapping: the page's address_space
>   * @index: the page's index into the mapping
> @@ -1444,6 +1496,8 @@ int filemap_fault(struct vm_area_struct *vma, struct vm_
>  	pgoff_t size;
>  	int did_readaround = 0;
>  	int ret = 0;
> +	int retry_flag = vmf->flags & FAULT_FLAG_RETRY;
> +	int retry_ret;
> 
>  	size = (i_size_read(inode) + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
>  	if (vmf->pgoff >= size)
> @@ -1458,6 +1512,7 @@ int filemap_fault(struct vm_area_struct *vma, struct vm_
>  	 */
>  retry_find:
>  	page = find_lock_page(mapping, vmf->pgoff);
> +
>  	/*
>  	 * For sequential accesses, we use the generic readahead logic.
>  	 */
> @@ -1465,7 +1520,13 @@ retry_find:
>  		if (!page) {
>  			page_cache_sync_readahead(mapping, ra, file,
>  							   vmf->pgoff, 1);
> -			page = find_lock_page(mapping, vmf->pgoff);
> +			retry_ret = find_lock_page_retry(mapping, vmf->pgoff,
> +						vma, &page, retry_flag);
> +			if (retry_ret == VM_FAULT_RETRY) {
> +				/* counteract the followed retry hit */
> +				ra->mmap_miss++;
> +				return retry_ret;
> +			}
>  			if (!page)
>  				goto no_cached_page;
>  		}
> @@ -1504,7 +1565,14 @@ retry_find:
>  				start = vmf->pgoff - ra_pages / 2;
>  			do_page_cache_readahead(mapping, file, start, ra_pages);
>  		}
> -		page = find_lock_page(mapping, vmf->pgoff);
> +retry_find_retry:
> +		retry_ret = find_lock_page_retry(mapping, vmf->pgoff,
> +				vma, &page, retry_flag);
> +		if (retry_ret == VM_FAULT_RETRY) {
> +			/* counteract the followed retry hit */
> +			ra->mmap_miss++;
> +			return retry_ret;
> +		}
>  		if (!page)
>  			goto no_cached_page;
>  	}
> @@ -1548,7 +1616,7 @@ no_cached_page:
>  	 * meantime, we'll just come back here and read it again.
>  	 */
>  	if (error >= 0)
> -		goto retry_find;
> +		goto retry_find_retry;
> 
>  	/*
>  	 * An error return from page_cache_read can result if the
> diff --git a/mm/memory.c b/mm/memory.c
> index 164951c..5e215c9 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -2467,6 +2467,13 @@ static int __do_fault(struct mm_struct *mm, struct vm_a
>  	vmf.page = NULL;
> 
>  	ret = vma->vm_ops->fault(vma, &vmf);
> +
> +	/* page may be available, but we have to restart the process
> +	 * because mmap_sem was dropped during the ->fault
> +	 */

The preferred comment layout is:

	/*
	 * The page may be available, but we have to restart the process
	 * because mmap_sem was dropped during the ->fault
	 */

> +	if (ret & VM_FAULT_RETRY)
> +		return ret;

Again, I worry that in some places we treat VM_FAULT_RETRY as an
enumerated type:

	if (foo == VM_FAULT_RETRY)

but in other places we treat it as a bitfield

	if (foo & VM_FAULT_RETRY)

it may not be buggy, but it _looks_ buggy.  And confusing and
inconsistent and dangerous.

Can it be improved?

>  	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE)))
>  		return ret;
> 
> @@ -2611,8 +2618,10 @@ static int do_linear_fault(struct mm_struct *mm, struct
>  {
>  	pgoff_t pgoff = (((address & PAGE_MASK)
>  			- vma->vm_start) >> PAGE_SHIFT) + vma->vm_pgoff;
> -	unsigned int flags = (write_access ? FAULT_FLAG_WRITE : 0);
> +	int write = write_access & ~FAULT_FLAG_RETRY;
> +	unsigned int flags = (write ? FAULT_FLAG_WRITE : 0);
> 
> +	flags |= (write_access & FAULT_FLAG_RETRY);

gee, I'm lost.

Can we please redo this as:


	int write;
	unsigned int flags;

	/*
	 * Big fat comment explaining the next three lines goes here
	 */
	write = write_access & ~FAULT_FLAG_RETRY;
	unsigned int flags = (write ? FAULT_FLAG_WRITE : 0);
	flags |= (write_access & FAULT_FLAG_RETRY);

?

>  	pte_unmap(page_table);
>  	return __do_fault(mm, vma, address, pmd, pgoff, flags, orig_pte);
>  }
> @@ -2726,26 +2735,32 @@ int handle_mm_fault(struct mm_struct *mm, struct vm_ar
>  	pud_t *pud;
>  	pmd_t *pmd;
>  	pte_t *pte;
> +	int ret;
> 
>  	__set_current_state(TASK_RUNNING);
> 
> -	count_vm_event(PGFAULT);
> -
> -	if (unlikely(is_vm_hugetlb_page(vma)))
> -		return hugetlb_fault(mm, vma, address, write_access);
> +	if (unlikely(is_vm_hugetlb_page(vma))) {
> +		ret = hugetlb_fault(mm, vma, address, write_access);
> +		goto out;
> +	}
> 
> +	ret = VM_FAULT_OOM;
>  	pgd = pgd_offset(mm, address);
>  	pud = pud_alloc(mm, pgd, address);
>  	if (!pud)
> -		return VM_FAULT_OOM;
> +		goto out;
>  	pmd = pmd_alloc(mm, pud, address);
>  	if (!pmd)
> -		return VM_FAULT_OOM;
> +		goto out;
>  	pte = pte_alloc_map(mm, pmd, address);
>  	if (!pte)
> -		return VM_FAULT_OOM;
> +		goto out;
> 
> -	return handle_pte_fault(mm, vma, address, pte, pmd, write_access);
> +	ret = handle_pte_fault(mm, vma, address, pte, pmd, write_access);
> +out:
> +	if (!(ret & VM_FAULT_RETRY))
> +		count_vm_event(PGFAULT);
> +	return ret;
>  }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
