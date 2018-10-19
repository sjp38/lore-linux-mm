Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id EA79E6B000D
	for <linux-mm@kvack.org>; Thu, 18 Oct 2018 23:50:26 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id g63-v6so15182673pfc.9
        for <linux-mm@kvack.org>; Thu, 18 Oct 2018 20:50:26 -0700 (PDT)
Received: from ipmail03.adl2.internode.on.net (ipmail03.adl2.internode.on.net. [150.101.137.141])
        by mx.google.com with ESMTP id z67-v6si16874380pfz.5.2018.10.18.20.50.25
        for <linux-mm@kvack.org>;
        Thu, 18 Oct 2018 20:50:25 -0700 (PDT)
Date: Fri, 19 Oct 2018 14:27:22 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 4/7] mm: use the cached page for filemap_fault
Message-ID: <20181019032722.GJ18822@dastard>
References: <20181018202318.9131-1-josef@toxicpanda.com>
 <20181018202318.9131-5-josef@toxicpanda.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181018202318.9131-5-josef@toxicpanda.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josef Bacik <josef@toxicpanda.com>
Cc: kernel-team@fb.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, tj@kernel.org, akpm@linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-btrfs@vger.kernel.org, riel@fb.com, linux-mm@kvack.org

On Thu, Oct 18, 2018 at 04:23:15PM -0400, Josef Bacik wrote:
> If we drop the mmap_sem we have to redo the vma lookup which requires
> redoing the fault handler.  Chances are we will just come back to the
> same page, so save this page in our vmf->cached_page and reuse it in the
> next loop through the fault handler.
> 
> Signed-off-by: Josef Bacik <josef@toxicpanda.com>
> ---
>  mm/filemap.c | 30 ++++++++++++++++++++++++++++--
>  1 file changed, 28 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/filemap.c b/mm/filemap.c
> index 65395ee132a0..5212ab637832 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -2530,13 +2530,38 @@ vm_fault_t filemap_fault(struct vm_fault *vmf)
>  	pgoff_t offset = vmf->pgoff;
>  	int flags = vmf->flags;
>  	pgoff_t max_off;
> -	struct page *page;
> +	struct page *page = NULL;
> +	struct page *cached_page = vmf->cached_page;
>  	vm_fault_t ret = 0;
>  
>  	max_off = DIV_ROUND_UP(i_size_read(inode), PAGE_SIZE);
>  	if (unlikely(offset >= max_off))
>  		return VM_FAULT_SIGBUS;
>  
> +	/*
> +	 * We may have read in the page already and have a page from an earlier
> +	 * loop.  If so we need to see if this page is still valid, and if not
> +	 * do the whole dance over again.
> +	 */
> +	if (cached_page) {
> +		if (flags & FAULT_FLAG_KILLABLE) {
> +			error = lock_page_killable(cached_page);
> +			if (error) {
> +				up_read(&mm->mmap_sem);
> +				goto out_retry;
> +			}
> +		} else
> +			lock_page(cached_page);
> +		vmf->cached_page = NULL;
> +		if (cached_page->mapping == mapping &&
> +		    cached_page->index == offset) {
> +			page = cached_page;
> +			goto have_cached_page;
> +		}
> +		unlock_page(cached_page);
> +		put_page(cached_page);
> +	}
> +

Can you factor this out so the main code path doesn't get any more
complex than it already is? i.e. something like:

	error = vmf_has_cached_page(vmf, &page);
	if (error)
		goto out_retry;
	if (page)
		goto have_cached_page;

-dave.

-- 
Dave Chinner
david@fromorbit.com
