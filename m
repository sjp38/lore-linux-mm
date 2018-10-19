Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id F308C6B000D
	for <linux-mm@kvack.org>; Thu, 18 Oct 2018 23:44:26 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id g63-v6so15174924pfc.9
        for <linux-mm@kvack.org>; Thu, 18 Oct 2018 20:44:26 -0700 (PDT)
Received: from ipmail03.adl2.internode.on.net (ipmail03.adl2.internode.on.net. [150.101.137.141])
        by mx.google.com with ESMTP id i9-v6si23691020pgk.20.2018.10.18.20.44.25
        for <linux-mm@kvack.org>;
        Thu, 18 Oct 2018 20:44:25 -0700 (PDT)
Date: Fri, 19 Oct 2018 14:21:54 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 3/7] mm: drop the mmap_sem in all read fault cases
Message-ID: <20181019032154.GI18822@dastard>
References: <20181018202318.9131-1-josef@toxicpanda.com>
 <20181018202318.9131-4-josef@toxicpanda.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181018202318.9131-4-josef@toxicpanda.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josef Bacik <josef@toxicpanda.com>
Cc: kernel-team@fb.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, tj@kernel.org, akpm@linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-btrfs@vger.kernel.org, riel@fb.com, linux-mm@kvack.org

On Thu, Oct 18, 2018 at 04:23:14PM -0400, Josef Bacik wrote:
> Johannes' patches didn't quite cover all of the IO cases that we need to
> drop the mmap_sem for, this patch covers the rest of them.
> 
> Signed-off-by: Josef Bacik <josef@toxicpanda.com>
> ---
>  mm/filemap.c | 11 +++++++++++
>  1 file changed, 11 insertions(+)
> 
> diff --git a/mm/filemap.c b/mm/filemap.c
> index 1ed35cd99b2c..65395ee132a0 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -2523,6 +2523,7 @@ vm_fault_t filemap_fault(struct vm_fault *vmf)
>  	int error;
>  	struct mm_struct *mm = vmf->vma->vm_mm;
>  	struct file *file = vmf->vma->vm_file;
> +	struct file *fpin = NULL;
>  	struct address_space *mapping = file->f_mapping;
>  	struct file_ra_state *ra = &file->f_ra;
>  	struct inode *inode = mapping->host;
> @@ -2610,11 +2611,15 @@ vm_fault_t filemap_fault(struct vm_fault *vmf)
>  	return ret | VM_FAULT_LOCKED;
>  
>  no_cached_page:
> +	fpin = maybe_unlock_mmap_for_io(vmf->vma, vmf->flags);
> +
>  	/*
>  	 * We're only likely to ever get here if MADV_RANDOM is in
>  	 * effect.
>  	 */
>  	error = page_cache_read(file, offset, vmf->gfp_mask);
> +	if (fpin)
> +		goto out_retry;

Please put the unlock after the comment explaining the goto label
so it's clear that the pin is associated only with the read
operations like so:

no_cached_page:
	/*
	 * We're only likely to ever get here if MADV_RANDOM is in
	 * effect.
	 */
	fpin = maybe_unlock_mmap_for_io(vmf->vma, vmf->flags);
	error = page_cache_read(file, offset, vmf->gfp_mask);
	if (fpin)
		goto out_retry;
>  
>  	/*
>  	 * The page we want has now been added to the page cache.
> @@ -2634,6 +2639,8 @@ vm_fault_t filemap_fault(struct vm_fault *vmf)
>  	return VM_FAULT_SIGBUS;
>  
>  page_not_uptodate:
> +	fpin = maybe_unlock_mmap_for_io(vmf->vma, vmf->flags);
> +
>  	/*
>  	 * Umm, take care of errors if the page isn't up-to-date.
>  	 * Try to re-read it _once_. We do this synchronously,

Same here.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
