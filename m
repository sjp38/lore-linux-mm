Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id C58928E00E5
	for <linux-mm@kvack.org>; Wed, 12 Dec 2018 05:10:55 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id x15so8322080edd.2
        for <linux-mm@kvack.org>; Wed, 12 Dec 2018 02:10:55 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n26si257399edd.409.2018.12.12.02.10.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Dec 2018 02:10:54 -0800 (PST)
Date: Wed, 12 Dec 2018 11:10:51 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 2/3] filemap: pass vm_fault to the mmap ra helpers
Message-ID: <20181212101051.GB10902@quack2.suse.cz>
References: <20181211173801.29535-1-josef@toxicpanda.com>
 <20181211173801.29535-3-josef@toxicpanda.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181211173801.29535-3-josef@toxicpanda.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josef Bacik <josef@toxicpanda.com>
Cc: kernel-team@fb.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, tj@kernel.org, david@fromorbit.com, akpm@linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, riel@redhat.com, jack@suse.cz

On Tue 11-12-18 12:38:00, Josef Bacik wrote:
> All of the arguments to these functions come from the vmf, and the
> following patches are going to add more arguments.  Cut down on the
> amount of arguments passed by simply passing in the vmf to these two
> helpers.
> 
> Signed-off-by: Josef Bacik <josef@toxicpanda.com>

The patch looks good. You can add:

Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> ---
>  mm/filemap.c | 28 ++++++++++++++--------------
>  1 file changed, 14 insertions(+), 14 deletions(-)
> 
> diff --git a/mm/filemap.c b/mm/filemap.c
> index 03bce38d8f2b..8fc45f24b201 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -2309,20 +2309,20 @@ EXPORT_SYMBOL(generic_file_read_iter);
>   * Synchronous readahead happens when we don't even find
>   * a page in the page cache at all.
>   */
> -static void do_sync_mmap_readahead(struct vm_area_struct *vma,
> -				   struct file_ra_state *ra,
> -				   struct file *file,
> -				   pgoff_t offset)
> +static void do_sync_mmap_readahead(struct vm_fault *vmf)
>  {
> +	struct file *file = vmf->vma->vm_file;
> +	struct file_ra_state *ra = &file->f_ra;
>  	struct address_space *mapping = file->f_mapping;
> +	pgoff_t offset = vmf->pgoff;
>  
>  	/* If we don't want any read-ahead, don't bother */
> -	if (vma->vm_flags & VM_RAND_READ)
> +	if (vmf->vma->vm_flags & VM_RAND_READ)
>  		return;
>  	if (!ra->ra_pages)
>  		return;
>  
> -	if (vma->vm_flags & VM_SEQ_READ) {
> +	if (vmf->vma->vm_flags & VM_SEQ_READ) {
>  		page_cache_sync_readahead(mapping, ra, file, offset,
>  					  ra->ra_pages);
>  		return;
> @@ -2352,16 +2352,16 @@ static void do_sync_mmap_readahead(struct vm_area_struct *vma,
>   * Asynchronous readahead happens when we find the page and PG_readahead,
>   * so we want to possibly extend the readahead further..
>   */
> -static void do_async_mmap_readahead(struct vm_area_struct *vma,
> -				    struct file_ra_state *ra,
> -				    struct file *file,
> -				    struct page *page,
> -				    pgoff_t offset)
> +static void do_async_mmap_readahead(struct vm_fault *vmf,
> +				    struct page *page)
>  {
> +	struct file *file = vmf->vma->vm_file;
> +	struct file_ra_state *ra = &file->f_ra;
>  	struct address_space *mapping = file->f_mapping;
> +	pgoff_t offset = vmf->pgoff;
>  
>  	/* If we don't want any read-ahead, don't bother */
> -	if (vma->vm_flags & VM_RAND_READ)
> +	if (vmf->vma->vm_flags & VM_RAND_READ)
>  		return;
>  	if (ra->mmap_miss > 0)
>  		ra->mmap_miss--;
> @@ -2418,10 +2418,10 @@ vm_fault_t filemap_fault(struct vm_fault *vmf)
>  		 * We found the page, so try async readahead before
>  		 * waiting for the lock.
>  		 */
> -		do_async_mmap_readahead(vmf->vma, ra, file, page, offset);
> +		do_async_mmap_readahead(vmf, page);
>  	} else if (!page) {
>  		/* No page in the page cache at all */
> -		do_sync_mmap_readahead(vmf->vma, ra, file, offset);
> +		do_sync_mmap_readahead(vmf);
>  		count_vm_event(PGMAJFAULT);
>  		count_memcg_event_mm(vmf->vma->vm_mm, PGMAJFAULT);
>  		ret = VM_FAULT_MAJOR;
> -- 
> 2.14.3
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
