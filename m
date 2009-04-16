Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 2EE365F0001
	for <linux-mm@kvack.org>; Wed, 15 Apr 2009 21:41:09 -0400 (EDT)
Date: Wed, 15 Apr 2009 18:38:47 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch] mm: close page_mkwrite races (try 3)
Message-Id: <20090415183847.d4fa1efb.akpm@linux-foundation.org>
In-Reply-To: <20090415082507.GA23674@wotan.suse.de>
References: <20090414071152.GC23528@wotan.suse.de>
	<20090415082507.GA23674@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Sage Weil <sage@newdream.net>, Trond Myklebust <trond.myklebust@fys.uio.no>, linux-fsdevel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 15 Apr 2009 10:25:07 +0200 Nick Piggin <npiggin@suse.de> wrote:

> OK, that one had some rough patches (in the changelog and the patch itself).
> One more try... if it's still misunderstandable, I give up :)
> 
> --
> 
> Change page_mkwrite to allow implementations to return with the page locked,
> and also change it's callers (in page fault paths) to hold the lock until the
> page is marked dirty. This allows the filesystem to have full control of page
> dirtying events coming from the VM.
> 
> Rather than simply hold the page locked over the page_mkwrite call, we call
> page_mkwrite with the page unlocked and allow callers to return with it locked,
> so filesystems can avoid LOR conditions with page lock.

All right, I give up.  What's LOR?

> The problem with the current scheme is this: a filesystem that wants to
> associate some metadata with a page as long as the page is dirty, will perform
> this manipulation in its ->page_mkwrite. It currently then must return with the
> page unlocked and may not hold any other locks (according to existing
> page_mkwrite convention).
> 
> In this window, the VM could write out the page, clearing page-dirty. The
> filesystem has no good way to detect that a dirty pte is about to be attached,
> so it will happily write out the page, at which point, the filesystem may
> manipulate the metadata to reflect that the page is no longer dirty.
> 
> It is not always possible to perform the required metadata manipulation in
> ->set_page_dirty, because that function cannot block or fail. The filesystem
> may need to allocate some data structure, for example.
> 
> And the VM cannot mark the pte dirty before page_mkwrite, because page_mkwrite
> is allowed to fail, so we must not allow any window where the page could be
> written to if page_mkwrite does fail.
> 
> This solution of holding the page locked over the 3 critical operations
> (page_mkwrite, setting the pte dirty, and finally setting the page dirty)
> closes out races nicely, preventing page cleaning for writeout being initiated
> in that window. This provides the filesystem with a strong synchronisation
> against the VM here.
> 
> - Sage needs this race closed for ceph filesystem.
> - Trond for NFS (http://bugzilla.kernel.org/show_bug.cgi?id=12913).

I wonder which kernel version(s) we should put this in.

Going BUG isn't nice, but that report is against 2.6.27.  Is the BUG
super-rare, or did we avoid it via other means, or what?

> - I need it for fsblock.
> - I suspect other filesystems may need it too (eg. btrfs).
> - I have converted buffer.c to the new locking. Even simple block allocation
>   under dirty pages might be susceptible to i_size changing under partial page
>   at the end of file (we also have a buffer.c-side problem here, but it cannot
>   be fixed properly without this patch).
> - Other filesystems (eg. NFS, maybe btrfs) will need to change their
>   page_mkwrite functions themselves.
> 
> [ This also moves page_mkwrite another step closer to fault, which should
>   eventually allow page_mkwrite to be moved into ->fault, and thus avoiding a
>   filesystem calldown and page lock/unlock cycle in __do_fault. ]
> 
>
> ...
>
> @@ -1980,9 +1989,11 @@ static int do_wp_page(struct mm_struct *
>  			 */
>  			page_table = pte_offset_map_lock(mm, pmd, address,
>  							 &ptl);
> -			page_cache_release(old_page);
> -			if (!pte_same(*page_table, orig_pte))
> +			if (!pte_same(*page_table, orig_pte)) {
> +				unlock_page(old_page);
> +				page_cache_release(old_page);
>  				goto unlock;
> +			}
>  
>  			page_mkwrite = 1;
>  		}
> @@ -2105,16 +2116,31 @@ unlock:
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
> +			struct address_space *mapping = dirty_page->mapping;
> +
> +			set_page_dirty(dirty_page);
> +			unlock_page(dirty_page);
> +			page_cache_release(dirty_page);
> +			balance_dirty_pages_ratelimited(mapping);

hm.  I wonder what prevents (prevented) *mapping from vanishing under
our feet here.

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
>
> ...
>
> @@ -2736,19 +2757,29 @@ static int __do_fault(struct mm_struct *
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
> -		set_page_dirty_balance(dirty_page, page_mkwrite);
> +		if (set_page_dirty(dirty_page))
> +			page_mkwrite = 1;
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

Whoa.  Running file_update_time() under lock_page() opens a whole can
of worms, doesn't it?  That thing can do journal commits and all sorts
of stuff.  And I don't think this ordering is necessary here?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
