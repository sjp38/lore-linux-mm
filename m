Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id C46B56B004D
	for <linux-mm@kvack.org>; Tue, 31 Mar 2009 15:54:26 -0400 (EDT)
Date: Tue, 31 Mar 2009 12:55:16 -0700 (PDT)
From: Sage Weil <sage@newdream.net>
Subject: Re: [patch] mm: close page_mkwrite races
In-Reply-To: <20090330135613.GQ31000@wotan.suse.de>
Message-ID: <Pine.LNX.4.64.0903311244200.19769@cobra.newdream.net>
References: <20090330135307.GP31000@wotan.suse.de> <20090330135613.GQ31000@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Trond Myklebust <trond.myklebust@fys.uio.no>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 30 Mar 2009, Nick Piggin wrote:
> [Fixed linux-mm address. Please reply here]
> 
> Hi,
> 
> I'd like opinions on this patch (applies on top of the previous
> page_mkwrite fixes in -mm). I was not going to ask to merge it
> immediately however it appears that fsblock is not the only one who
> needs it...
> --
> 
> I want to have the page be protected by page lock between page_mkwrite
> notification to the filesystem, and the actual setting of the page
> dirty. Do this by allowing the filesystem to return a locked page from
> page_mkwrite, and have the page fault code keep it held until after it
> calls set_page_dirty.
> 
> I need this in fsblock because I am working to ensure filesystem metadata
> can be correctly allocated and refcounted. This means that page cleaning
> should not require memory allocation.
> 
> Without this patch, then for example we could get a concurrent writeout
> after the page_mkwrite (which allocates page metadata required to clean
> it), but before the set_page_dirty. The writeout will clean the page and
> notice that the metadata is now unused and may be deallocated (because
> it appears clean as set_page_dirty hasn't been called yet). So at this
> point the page may be dirtied via the pte without enough metadata to be
> able to write it back.
> 
> Sage needs this race closed for ceph, and Trond maybe for NFS.

I ran a few tests and this fixes the problem for me (although fyi the 
patch didn't apply cleanly on top of your previously posted page_mkwrite 
prototype change patch, due to some differences in block_page_mkwrite).

Thanks-
sage



> 
> Cc: Sage Weil <sage@newdream.net>
> Cc: Trond Myklebust <trond.myklebust@fys.uio.no>
> Signed-off-by: Nick Piggin <npiggin@suse.de>
> 
> ---
>  Documentation/filesystems/Locking |   24 +++++++---
>  fs/buffer.c                       |   10 ++--
>  mm/memory.c                       |   83 ++++++++++++++++++++++++++------------
>  3 files changed, 79 insertions(+), 38 deletions(-)
> 
> Index: linux-2.6/fs/buffer.c
> ===================================================================
> --- linux-2.6.orig/fs/buffer.c
> +++ linux-2.6/fs/buffer.c
> @@ -2480,7 +2480,8 @@ block_page_mkwrite(struct vm_area_struct
>  	if ((page->mapping != inode->i_mapping) ||
>  	    (page_offset(page) > size)) {
>  		/* page got truncated out from underneath us */
> -		goto out_unlock;
> +		unlock_page(page);
> +		goto out;
>  	}
>  
>  	/* page is wholly or partially inside EOF */
> @@ -2494,14 +2495,15 @@ block_page_mkwrite(struct vm_area_struct
>  		ret = block_commit_write(page, 0, end);
>  
>  	if (unlikely(ret)) {
> +		unlock_page(page);
>  		if (ret == -ENOMEM)
>  			ret = VM_FAULT_OOM;
>  		else /* -ENOSPC, -EIO, etc */
>  			ret = VM_FAULT_SIGBUS;
> -	}
> +	} else
> +		ret = VM_FAULT_LOCKED;
>  
> -out_unlock:
> -	unlock_page(page);
> +out:
>  	return ret;
>  }
>  
> Index: linux-2.6/mm/memory.c
> ===================================================================
> --- linux-2.6.orig/mm/memory.c
> +++ linux-2.6/mm/memory.c
> @@ -1964,6 +1964,15 @@ static int do_wp_page(struct mm_struct *
>  				ret = tmp;
>  				goto unwritable_page;
>  			}
> +			if (unlikely(!(tmp & VM_FAULT_LOCKED))) {
> +				lock_page(old_page);
> +				if (!old_page->mapping) {
> +					ret = 0; /* retry the fault */
> +					unlock_page(old_page);
> +					goto unwritable_page;
> +				}
> +			} else
> +				VM_BUG_ON(!PageLocked(old_page));
>  
>  			/*
>  			 * Since we dropped the lock we need to revalidate
> @@ -1973,9 +1982,11 @@ static int do_wp_page(struct mm_struct *
>  			 */
>  			page_table = pte_offset_map_lock(mm, pmd, address,
>  							 &ptl);
> -			page_cache_release(old_page);
> -			if (!pte_same(*page_table, orig_pte))
> +			if (!pte_same(*page_table, orig_pte)) {
> +				page_cache_release(old_page);
> +				unlock_page(old_page);
>  				goto unlock;
> +			}
>  
>  			page_mkwrite = 1;
>  		}
> @@ -2098,16 +2109,30 @@ unlock:
>  		 *
>  		 * do_no_page is protected similarly.
>  		 */
> -		wait_on_page_locked(dirty_page);
> -		set_page_dirty_balance(dirty_page, page_mkwrite);
> +		if (!page_mkwrite) {
> +			wait_on_page_locked(dirty_page);
> +			set_page_dirty_balance(dirty_page, page_mkwrite);
> +		}
>  		put_page(dirty_page);
> +		if (page_mkwrite) {
> +			struct address_space *mapping = old_page->mapping;
> +
> +			unlock_page(old_page);
> +			page_cache_release(old_page);
> +			balance_dirty_pages_ratelimited(mapping);
> +		}
>  	}
>  	return ret;
>  oom_free_new:
>  	page_cache_release(new_page);
>  oom:
> -	if (old_page)
> +	if (old_page) {
> +		if (page_mkwrite) {
> +			unlock_page(old_page);
> +			page_cache_release(old_page);
> +		}
>  		page_cache_release(old_page);
> +	}
>  	return VM_FAULT_OOM;
>  
>  unwritable_page:
> @@ -2659,27 +2684,22 @@ static int __do_fault(struct mm_struct *
>  				int tmp;
>  
>  				unlock_page(page);
> -				vmf.flags |= FAULT_FLAG_MKWRITE;
> +				vmf.flags = FAULT_FLAG_WRITE|FAULT_FLAG_MKWRITE;
>  				tmp = vma->vm_ops->page_mkwrite(vma, &vmf);
>  				if (unlikely(tmp &
>  					  (VM_FAULT_ERROR | VM_FAULT_NOPAGE))) {
>  					ret = tmp;
> -					anon = 1; /* no anon but release vmf.page */
> -					goto out_unlocked;
> -				}
> -				lock_page(page);
> -				/*
> -				 * XXX: this is not quite right (racy vs
> -				 * invalidate) to unlock and relock the page
> -				 * like this, however a better fix requires
> -				 * reworking page_mkwrite locking API, which
> -				 * is better done later.
> -				 */
> -				if (!page->mapping) {
> -					ret = 0;
> -					anon = 1; /* no anon but release vmf.page */
> -					goto out;
> +					goto unwritable_page;
>  				}
> +				if (unlikely(!(tmp & VM_FAULT_LOCKED))) {
> +					lock_page(page);
> +					if (!page->mapping) {
> +						ret = 0; /* retry the fault */
> +						unlock_page(page);
> +						goto unwritable_page;
> +					}
> +				} else
> +					VM_BUG_ON(!PageLocked(page));
>  				page_mkwrite = 1;
>  			}
>  		}
> @@ -2731,19 +2751,30 @@ static int __do_fault(struct mm_struct *
>  	pte_unmap_unlock(page_table, ptl);
>  
>  out:
> -	unlock_page(vmf.page);
> -out_unlocked:
> -	if (anon)
> -		page_cache_release(vmf.page);
> -	else if (dirty_page) {
> +	if (dirty_page) {
> +		struct address_space *mapping = page->mapping;
> +
>  		if (vma->vm_file)
>  			file_update_time(vma->vm_file);
>  
> +		if (set_page_dirty(dirty_page))
> +			page_mkwrite = 1;
>  		set_page_dirty_balance(dirty_page, page_mkwrite);
> +		unlock_page(dirty_page);
>  		put_page(dirty_page);
> +		if (page_mkwrite)
> +			balance_dirty_pages_ratelimited(mapping);
> +	} else {
> +		unlock_page(vmf.page);
> +		if (anon)
> +			page_cache_release(vmf.page);
>  	}
>  
>  	return ret;
> +
> +unwritable_page:
> +	page_cache_release(page);
> +	return ret;
>  }
>  
>  static int do_linear_fault(struct mm_struct *mm, struct vm_area_struct *vma,
> Index: linux-2.6/Documentation/filesystems/Locking
> ===================================================================
> --- linux-2.6.orig/Documentation/filesystems/Locking
> +++ linux-2.6/Documentation/filesystems/Locking
> @@ -509,16 +509,24 @@ locking rules:
>  		BKL	mmap_sem	PageLocked(page)
>  open:		no	yes
>  close:		no	yes
> -fault:		no	yes
> -page_mkwrite:	no	yes		no
> +fault:		no	yes		can return with page locked
> +page_mkwrite:	no	yes		can return with page locked
>  access:		no	yes
>  
> -	->page_mkwrite() is called when a previously read-only page is
> -about to become writeable. The file system is responsible for
> -protecting against truncate races. Once appropriate action has been
> -taking to lock out truncate, the page range should be verified to be
> -within i_size. The page mapping should also be checked that it is not
> -NULL.
> +	->fault() is called when a previously not present pte is about
> +to be faulted in. The filesystem must find and return the page associated
> +with the passed in "pgoff" in the vm_fault structure. If it is possible that
> +the page may be truncated and/or invalidated, then the filesystem must lock
> +the page, then ensure it is not already truncated (the page lock will block
> +subsequent truncate), and then return with VM_FAULT_LOCKED, and the page
> +locked. The VM will unlock the page.
> +
> +	->page_mkwrite() is called when a previously read-only pte is
> +about to become writeable. The filesystem again must ensure that there are
> +no truncate/invalidate races, and then return with the page locked. If
> +the page has been truncated, the filesystem should not look up a new page
> +like the ->fault() handler, but simply return with VM_FAULT_NOPAGE, which
> +will cause the VM to retry the fault.
>  
>  	->access() is called when get_user_pages() fails in
>  acces_process_vm(), typically used to debug a process through
> --
> To unsubscribe from this list: send the line "unsubscribe linux-fsdevel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
