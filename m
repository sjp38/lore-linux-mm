Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3BE818E00E5
	for <linux-mm@kvack.org>; Wed, 12 Dec 2018 18:55:41 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id f69so195975pff.5
        for <linux-mm@kvack.org>; Wed, 12 Dec 2018 15:55:41 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id u5si155519pgr.316.2018.12.12.15.55.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Dec 2018 15:55:40 -0800 (PST)
Date: Wed, 12 Dec 2018 15:55:36 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH][v6] filemap: drop the mmap_sem for all blocking
 operations
Message-Id: <20181212155536.5fb770a0c9b4f2399d4794e4@linux-foundation.org>
In-Reply-To: <20181212152757.10017-1-josef@toxicpanda.com>
References: <20181211173801.29535-4-josef@toxicpanda.com>
	<20181212152757.10017-1-josef@toxicpanda.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josef Bacik <josef@toxicpanda.com>
Cc: kernel-team@fb.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, tj@kernel.org, david@fromorbit.com, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, riel@redhat.com, jack@suse.cz

On Wed, 12 Dec 2018 10:27:57 -0500 Josef Bacik <josef@toxicpanda.com> wrote:

> v5->v6:
> - added more comments as per Andrew's suggestion.
> - fixed the fpin leaks in the two error paths that were pointed out.
> 

hm,

> --- a/mm/filemap.c~filemap-drop-the-mmap_sem-for-all-blocking-operations-v6
> +++ a/mm/filemap.c
> @@ -2461,7 +2476,8 @@ static struct file *do_sync_mmap_readahe
>  
>  /*
>   * Asynchronous readahead happens when we find the page and PG_readahead,
> - * so we want to possibly extend the readahead further..
> + * so we want to possibly extend the readahead further.  We return the file that
> + * was pinned if we have to drop the mmap_sem in order to do IO.
>   */
>  static struct file *do_async_mmap_readahead(struct vm_fault *vmf,
>  					    struct page *page)
> @@ -2545,14 +2561,15 @@ retry_find:
>  		page = pagecache_get_page(mapping, offset,
>  					  FGP_CREAT|FGP_FOR_MMAP,
>  					  vmf->gfp_mask);
> -		if (!page)
> +		if (!page) {
> +			if (fpin)
> +				goto out_retry;

Is this right?  If pagecache_get_page() returns NULL we can now return
VM_FAULT_MAJOR|VM_FAULT_RETRY whereas we used to return ENOMEM.

>  			return vmf_error(-ENOMEM);
> +		}
>  	}
>  
> -	if (!lock_page_maybe_drop_mmap(vmf, page, &fpin)) {
> -		put_page(page);
> -		return ret | VM_FAULT_RETRY;
> -	}
> +	if (!lock_page_maybe_drop_mmap(vmf, page, &fpin))
> +		goto out_retry;
>  
>  	/* Did it get truncated? */
>  	if (unlikely(page->mapping != mapping)) {
