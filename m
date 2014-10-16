Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f175.google.com (mail-lb0-f175.google.com [209.85.217.175])
	by kanga.kvack.org (Postfix) with ESMTP id B4B656B0069
	for <linux-mm@kvack.org>; Thu, 16 Oct 2014 04:58:55 -0400 (EDT)
Received: by mail-lb0-f175.google.com with SMTP id u10so2405843lbd.20
        for <linux-mm@kvack.org>; Thu, 16 Oct 2014 01:58:54 -0700 (PDT)
Received: from mail.efficios.com (mail.efficios.com. [78.47.125.74])
        by mx.google.com with ESMTP id b11si33660673lbq.121.2014.10.16.01.58.53
        for <linux-mm@kvack.org>;
        Thu, 16 Oct 2014 01:58:54 -0700 (PDT)
Date: Thu, 16 Oct 2014 10:56:42 +0200
From: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
Subject: Re: [PATCH v11 03/21] mm: Fix XIP fault vs truncate race
Message-ID: <20141016085642.GB19075@thinkos.etherlink>
References: <1411677218-29146-1-git-send-email-matthew.r.wilcox@intel.com>
 <1411677218-29146-4-git-send-email-matthew.r.wilcox@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1411677218-29146-4-git-send-email-matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <matthew.r.wilcox@intel.com>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 25-Sep-2014 04:33:20 PM, Matthew Wilcox wrote:
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
> 
> Signed-off-by: Matthew Wilcox <matthew.r.wilcox@intel.com>
> Reviewed-by: Jan Kara <jack@suse.cz>
> Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

Reviewed-by: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>

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
> 2.1.0
> 
> 

-- 
Mathieu Desnoyers
EfficiOS Inc.
http://www.efficios.com
Key fingerprint: 2A0B 4ED9 15F2 D3FA 45F5  B162 1728 0A97 8118 6ACF

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
