Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 715416B0008
	for <linux-mm@kvack.org>; Thu, 18 Oct 2018 23:14:55 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id f17-v6so24768455plr.1
        for <linux-mm@kvack.org>; Thu, 18 Oct 2018 20:14:55 -0700 (PDT)
Received: from ipmail02.adl2.internode.on.net (ipmail02.adl2.internode.on.net. [150.101.137.139])
        by mx.google.com with ESMTP id u10-v6si22585889plq.1.2018.10.18.20.14.53
        for <linux-mm@kvack.org>;
        Thu, 18 Oct 2018 20:14:54 -0700 (PDT)
Date: Fri, 19 Oct 2018 14:14:46 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 2/7] mm: drop mmap_sem for page cache read IO submission
Message-ID: <20181019031446.GH18822@dastard>
References: <20181018202318.9131-1-josef@toxicpanda.com>
 <20181018202318.9131-3-josef@toxicpanda.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181018202318.9131-3-josef@toxicpanda.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josef Bacik <josef@toxicpanda.com>
Cc: kernel-team@fb.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, tj@kernel.org, akpm@linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-btrfs@vger.kernel.org, riel@fb.com, linux-mm@kvack.org

On Thu, Oct 18, 2018 at 04:23:13PM -0400, Josef Bacik wrote:
> From: Johannes Weiner <hannes@cmpxchg.org>
> 
> Reads can take a long time, and if anybody needs to take a write lock on
> the mmap_sem it'll block any subsequent readers to the mmap_sem while
> the read is outstanding, which could cause long delays.  Instead drop
> the mmap_sem if we do any reads at all.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> Signed-off-by: Josef Bacik <josef@toxicpanda.com>
> ---
.....
>  vm_fault_t filemap_fault(struct vm_fault *vmf)
>  {
>  	int error;
> +	struct mm_struct *mm = vmf->vma->vm_mm;
>  	struct file *file = vmf->vma->vm_file;
>  	struct address_space *mapping = file->f_mapping;
>  	struct file_ra_state *ra = &file->f_ra;
>  	struct inode *inode = mapping->host;
>  	pgoff_t offset = vmf->pgoff;
> +	int flags = vmf->flags;

local copy of flags.

>  	pgoff_t max_off;
>  	struct page *page;
>  	vm_fault_t ret = 0;
> @@ -2509,27 +2540,44 @@ vm_fault_t filemap_fault(struct vm_fault *vmf)
>  	 * Do we have something in the page cache already?
>  	 */
>  	page = find_get_page(mapping, offset);
> -	if (likely(page) && !(vmf->flags & FAULT_FLAG_TRIED)) {
> +	if (likely(page) && !(flags & FAULT_FLAG_TRIED)) {

Used here.

>  		/*
>  		 * We found the page, so try async readahead before
>  		 * waiting for the lock.
>  		 */
> -		do_async_mmap_readahead(vmf->vma, ra, file, page, offset);
> +		error = do_async_mmap_readahead(vmf->vma, ra, file, page, offset, vmf->flags);

Not here.

> +		if (error == -EAGAIN)
> +			goto out_retry_wait;
>  	} else if (!page) {
>  		/* No page in the page cache at all */
> -		do_sync_mmap_readahead(vmf->vma, ra, file, offset);
> -		count_vm_event(PGMAJFAULT);
> -		count_memcg_event_mm(vmf->vma->vm_mm, PGMAJFAULT);
>  		ret = VM_FAULT_MAJOR;
> +		count_vm_event(PGMAJFAULT);
> +		count_memcg_event_mm(mm, PGMAJFAULT);
> +		error = do_sync_mmap_readahead(vmf->vma, ra, file, offset, vmf->flags);

or here.

(Also, the vmf is passed through to where these flags
are used, so why is it passed as a separate flag parameter?)

> +		if (error == -EAGAIN)
> +			goto out_retry_wait;
>  retry_find:
>  		page = find_get_page(mapping, offset);
>  		if (!page)
>  			goto no_cached_page;
>  	}
>  
> -	if (!lock_page_or_retry(page, vmf->vma->vm_mm, vmf->flags)) {
> -		put_page(page);
> -		return ret | VM_FAULT_RETRY;
> +	if (!trylock_page(page)) {
> +		if (flags & FAULT_FLAG_ALLOW_RETRY) {
> +			if (flags & FAULT_FLAG_RETRY_NOWAIT)
> +				goto out_retry;
> +			up_read(&mm->mmap_sem);
> +			goto out_retry_wait;
> +		}
> +		if (flags & FAULT_FLAG_KILLABLE) {

but is used here...

> +			int ret = __lock_page_killable(page);
> +
> +			if (ret) {
> +				up_read(&mm->mmap_sem);
> +				goto out_retry;
> +			}
> +		} else
> +			__lock_page(page);
>  	}
>  
>  	/* Did it get truncated? */
> @@ -2607,6 +2655,19 @@ vm_fault_t filemap_fault(struct vm_fault *vmf)
>  	/* Things didn't work out. Return zero to tell the mm layer so. */
>  	shrink_readahead_size_eio(file, ra);
>  	return VM_FAULT_SIGBUS;
> +
> +out_retry_wait:
> +	if (page) {
> +		if (flags & FAULT_FLAG_KILLABLE)

and here.

Any reason for this discrepancy?

-Dave.
-- 
Dave Chinner
david@fromorbit.com
