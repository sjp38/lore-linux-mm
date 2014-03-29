Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f174.google.com (mail-we0-f174.google.com [74.125.82.174])
	by kanga.kvack.org (Postfix) with ESMTP id 9C3466B0039
	for <linux-mm@kvack.org>; Mon, 31 Mar 2014 06:28:15 -0400 (EDT)
Received: by mail-we0-f174.google.com with SMTP id t60so4489214wes.19
        for <linux-mm@kvack.org>; Mon, 31 Mar 2014 03:28:14 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f10si7139591wix.43.2014.03.31.03.28.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 31 Mar 2014 03:28:13 -0700 (PDT)
Date: Sat, 29 Mar 2014 16:57:24 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v7 01/22] Fix XIP fault vs truncate race
Message-ID: <20140329155724.GB1211@quack.suse.cz>
References: <cover.1395591795.git.matthew.r.wilcox@intel.com>
 <59d73a58d4cfbe190a16ce912bb2776d9cc95447.1395591795.git.matthew.r.wilcox@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <59d73a58d4cfbe190a16ce912bb2776d9cc95447.1395591795.git.matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <matthew.r.wilcox@intel.com>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, willy@linux.intel.com

On Sun 23-03-14 15:08:27, Matthew Wilcox wrote:
> Pagecache faults recheck i_size after taking the page lock to ensure that
> the fault didn't race against a truncate.  We don't have a page to lock
> in the XIP case, so use the i_mmap_mutex instead.  It is locked in the
> truncate path in unmap_mapping_range() after updating i_size.  So while
> we hold it in the fault path, we are guaranteed that either i_size has
> already been updated in the truncate path, or that the truncate will
> subsequently call zap_page_range_single() and so remove the mapping we
> have just inserted.
> 
> There is a window of time in which i_size has been reduced and the
> thread has a mapping to a page which will be removed from the file,
> but this is harmless as the page will not be allocated to a different
> purpose before the thread's access to it is revoked.
  The patch looks good. You can add:
Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> Signed-off-by: Matthew Wilcox <matthew.r.wilcox@intel.com>
> ---
>  mm/filemap_xip.c | 24 ++++++++++++++++++++++--
>  1 file changed, 22 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/filemap_xip.c b/mm/filemap_xip.c
> index d8d9fe3..c8d23e9 100644
> --- a/mm/filemap_xip.c
> +++ b/mm/filemap_xip.c
> @@ -260,8 +260,17 @@ again:
>  		__xip_unmap(mapping, vmf->pgoff);
>  
>  found:
> +		/* We must recheck i_size under i_mmap_mutex */
> +		mutex_lock(&mapping->i_mmap_mutex);
> +		size = (i_size_read(inode) + PAGE_CACHE_SIZE - 1) >>
> +							PAGE_CACHE_SHIFT;
> +		if (unlikely(vmf->pgoff >= size)) {
> +			mutex_unlock(&mapping->i_mmap_mutex);
> +			return VM_FAULT_SIGBUS;
> +		}
>  		err = vm_insert_mixed(vma, (unsigned long)vmf->virtual_address,
>  							xip_pfn);
> +		mutex_unlock(&mapping->i_mmap_mutex);
>  		if (err == -ENOMEM)
>  			return VM_FAULT_OOM;
>  		/*
> @@ -285,16 +294,27 @@ found:
>  		}
>  		if (error != -ENODATA)
>  			goto out;
> +
> +		/* We must recheck i_size under i_mmap_mutex */
> +		mutex_lock(&mapping->i_mmap_mutex);
> +		size = (i_size_read(inode) + PAGE_CACHE_SIZE - 1) >>
> +							PAGE_CACHE_SHIFT;
> +		if (unlikely(vmf->pgoff >= size)) {
> +			ret = VM_FAULT_SIGBUS;
> +			goto unlock;
> +		}
>  		/* not shared and writable, use xip_sparse_page() */
>  		page = xip_sparse_page();
>  		if (!page)
> -			goto out;
> +			goto unlock;
>  		err = vm_insert_page(vma, (unsigned long)vmf->virtual_address,
>  							page);
>  		if (err == -ENOMEM)
> -			goto out;
> +			goto unlock;
>  
>  		ret = VM_FAULT_NOPAGE;
> +unlock:
> +		mutex_unlock(&mapping->i_mmap_mutex);
>  out:
>  		write_seqcount_end(&xip_sparse_seq);
>  		mutex_unlock(&xip_sparse_mutex);
> -- 
> 1.9.0
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-fsdevel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
