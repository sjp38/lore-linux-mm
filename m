From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <200004072012.NAA10407@google.engr.sgi.com>
Subject: Re: [patch] take 2 Re: PG_swap_entry bug in recent kernels
Date: Fri, 7 Apr 2000 13:12:11 -0700 (PDT)
In-Reply-To: <Pine.LNX.4.21.0004071205300.737-100000@alpha.random> from "Andrea Arcangeli" at Apr 07, 2000 12:45:13 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Ben LaHaise <bcrl@redhat.com>, riel@nl.linux.org, Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrea, 

The swaplist locking changes in swapfile.c in your patch are okay, but
are unneeded when you consider the kernel_lock is already held in most
of those paths. (Complete removal of kernel_lock in those paths are a
little harder, at least when last I tried it). A bigger problem might
be that you are violating lock orders when you grab the vmlist_lock
from inside code that already has tasklist_lock in readmode (your
change in unuse_process()). I may be wrong, so you should try stress
testing with swapdevice removal with a large number of runnable
processes.

Also, did you have a good reason to want to make lookup_swap_cache()
invoke find_get_page(), and not find_lock_page()? I coded some of the 
MP race fixes with the swap cache, some of the logic is in 
Documentation/vm/locking. I remember some intense reasoning and
thinking of obscure conditions, so I am just cautious about any
locking changes.

Kanoj

> --- ref/mm/swap_state.c	Thu Apr  6 01:00:52 2000
> +++ swap-entry-1/mm/swap_state.c	Fri Apr  7 12:29:00 2000
> @@ -126,9 +126,14 @@
>  		UnlockPage(page);
>  	}
>  
> -	ClearPageSwapEntry(page);
> -
> -	__free_page(page);
> +	/*
> +	 * Only the last unmap have to lose the swap entry
> +	 * information that we have cached into page->index.
> +	 */
> +	if (put_page_testzero(page)) {
> +		page->flags &= ~(1UL << PG_swap_entry);
> +		__free_pages_ok(page, 0);
> +	}
>  }
>  
>  
> @@ -151,7 +156,7 @@
>  		 * Right now the pagecache is 32-bit only.  But it's a 32 bit index. =)
>  		 */
>  repeat:
> -		found = find_lock_page(&swapper_space, entry.val);
> +		found = find_get_page(&swapper_space, entry.val);
>  		if (!found)
>  			return 0;
>  		/*
> @@ -163,7 +168,6 @@
>  		 * is enough to check whether the page is still in the scache.
>  		 */
>  		if (!PageSwapCache(found)) {
> -			UnlockPage(found);
>  			__free_page(found);
>  			goto repeat;
>  		}
> @@ -172,13 +176,11 @@
>  #ifdef SWAP_CACHE_INFO
>  		swap_cache_find_success++;
>  #endif
> -		UnlockPage(found);
>  		return found;
>  	}
>  
>  out_bad:
>  	printk (KERN_ERR "VM: Found a non-swapper swap page!\n");
> -	UnlockPage(found);
>  	__free_page(found);
>  	return 0;
>  }
> diff -urN ref/mm/swapfile.c swap-entry-1/mm/swapfile.c
> --- ref/mm/swapfile.c	Thu Apr  6 01:00:52 2000
> +++ swap-entry-1/mm/swapfile.c	Fri Apr  7 12:35:59 2000
> @@ -212,22 +212,22 @@
>  
>  	/* We have the old entry in the page offset still */
>  	if (!page->index)
> -		goto new_swap_entry;
> +		goto null_swap_entry;
>  	entry.val = page->index;
>  	type = SWP_TYPE(entry);
>  	if (type >= nr_swapfiles)
> -		goto new_swap_entry;
> +		goto bad_nofile;
> +	swap_list_lock();
>  	p = type + swap_info;
>  	if ((p->flags & SWP_WRITEOK) != SWP_WRITEOK)
> -		goto new_swap_entry;
> +		goto unlock_list;
>  	offset = SWP_OFFSET(entry);
>  	if (offset >= p->max)
> -		goto new_swap_entry;
> +		goto bad_offset;
>  	/* Has it been re-used for something else? */
> -	swap_list_lock();
>  	swap_device_lock(p);
>  	if (p->swap_map[offset])
> -		goto unlock_new_swap_entry;
> +		goto unlock;
>  
>  	/* We're cool, we can just use the old one */
>  	p->swap_map[offset] = 1;
> @@ -236,11 +236,24 @@
>  	swap_list_unlock();
>  	return entry;
>  
> -unlock_new_swap_entry:
> +unlock:
>  	swap_device_unlock(p);
> +unlock_list:
>  	swap_list_unlock();
> +clear_swap_entry:
> +	ClearPageSwapEntry(page);
>  new_swap_entry:
>  	return get_swap_page();
> +
> +null_swap_entry:
> +	printk(KERN_WARNING __FUNCTION__ " null swap entry\n");
> +	goto clear_swap_entry;
> +bad_nofile:
> +	printk(KERN_WARNING __FUNCTION__ " nonexistent swap file\n");
> +	goto clear_swap_entry;
> +bad_offset:
> +	printk(KERN_WARNING __FUNCTION__ " bad offset\n");
> +	goto unlock_list;
>  }
>  
>  /*
> @@ -263,8 +276,11 @@
>  		/* If this entry is swap-cached, then page must already
>                     hold the right address for any copies in physical
>                     memory */
> -		if (pte_page(pte) != page)
> +		if (pte_page(pte) != page) {
> +			if (page->index == entry.val)
> +				ClearPageSwapEntry(page);
>  			return;
> +		}
>  		/* We will be removing the swap cache in a moment, so... */
>  		set_pte(dir, pte_mkdirty(pte));
>  		return;
> @@ -358,10 +374,20 @@
>  	 */
>  	if (!mm)
>  		return;
> +	/*
> +	 * Avoid the vmas to go away from under us
> +	 * and also avoids the task to play with
> +	 * pagetables while we're running. If the
> +	 * vmlist_modify_lock wouldn't acquire the
> +	 * mm->page_table_lock spinlock we should
> +	 * acquire it by hand.
> +	 */
> +	vmlist_access_lock(mm);
>  	for (vma = mm->mmap; vma; vma = vma->vm_next) {
>  		pgd_t * pgd = pgd_offset(mm, vma->vm_start);
>  		unuse_vma(vma, pgd, entry, page);
>  	}
> +	vmlist_access_unlock(mm);
>  	return;
>  }
>  
> @@ -418,8 +444,10 @@
>  		shm_unuse(entry, page);
>  		/* Now get rid of the extra reference to the temporary
>                     page we've been using. */
> -		if (PageSwapCache(page))
> +		if (PageSwapCache(page)) {
>  			delete_from_swap_cache(page);
> +			ClearPageSwapEntry(page);
> +		}
>  		__free_page(page);
>  		/*
>  		 * Check for and clear any overflowed swap map counts.
> @@ -488,8 +516,8 @@
>  		swap_list.next = swap_list.head;
>  	}
>  	nr_swap_pages -= p->pages;
> -	swap_list_unlock();
>  	p->flags = SWP_USED;
> +	swap_list_unlock();
>  	err = try_to_unuse(type);
>  	if (err) {
>  		/* re-insert swap space back into swap_list */
> 
> Andrea
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux.eu.org/Linux-MM/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
