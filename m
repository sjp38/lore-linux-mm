Message-ID: <388888483.10316@ustc.edu.cn>
Date: Tue, 4 Sep 2007 14:48:02 +0800
From: Fengguang Wu <wfg@mail.ustc.edu.cn>
Subject: Re: [patch][rfc] delayacct: fix swapin delay accounting (maybe)
Message-ID: <20070904064802.GA5527@mail.ustc.edu.cn>
References: <20070903195847.GD24413@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070903195847.GD24413@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Shailabh Nagar <nagar@watson.ibm.com>, Hugh Dickins <hugh@veritas.com>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, Sep 03, 2007 at 09:58:47PM +0200, Nick Piggin wrote:
> Hi,
> 
> I can't convince myself that delay accounting for swapin is quite right
> at the moment (not having a test setup handy to run and check for myself).
> Maybe I'm not reading the swapin code very well...
> 
> lookup_swap_cache, and read_swap_cache_async should be non-blocking
> operations for the most part.
> 
> read_swap_cache_async might, when allocating the new page, go into reclaim
> and take a long time to come back. However is that any more a "swapin" delay
> than eg. when we sleep on mmap_sem when first taking the fault, or any other
> types of fault which require allocations? None of which we account for as
> swapin delay.
> 
> But the most obvious delay, where we actually lock the page waiting for
> the swap IO to finish, does not seem to be accounted at all!

Good catch!  I think you are right after some proof reading. 

That lock_page() should be the first IO block point. There may be
double read_swap_cache_async() calls for the same offset: once in
swapin_readahead(), the other immediately after swapin_readahead().
But the second one will return directly. So there's no other
block/delay point for the newly submitted read IO.

Fengguang

> My proposed fix is to just move the swaping delay accounting to the
> point where the VM does actually wait, for the swapin.
> 
> I have no idea what uses swapin delay accounting, but it would be good to
> see if this makes a positive (or at least not negative) impact on those
> users...
> 
> Thanks,
> Nick
> 
> --
> Index: linux-2.6/mm/memory.c
> ===================================================================
> --- linux-2.6.orig/mm/memory.c
> +++ linux-2.6/mm/memory.c
> @@ -2158,7 +2158,6 @@ static int do_swap_page(struct mm_struct
>  		migration_entry_wait(mm, pmd, address);
>  		goto out;
>  	}
> -	delayacct_set_flag(DELAYACCT_PF_SWAPIN);
>  	page = lookup_swap_cache(entry);
>  	if (!page) {
>  		grab_swap_token(); /* Contend for token _before_ read-in */
> @@ -2172,7 +2171,6 @@ static int do_swap_page(struct mm_struct
>  			page_table = pte_offset_map_lock(mm, pmd, address, &ptl);
>  			if (likely(pte_same(*page_table, orig_pte)))
>  				ret = VM_FAULT_OOM;
> -			delayacct_clear_flag(DELAYACCT_PF_SWAPIN);
>  			goto unlock;
>  		}
>  
> @@ -2181,9 +2179,10 @@ static int do_swap_page(struct mm_struct
>  		count_vm_event(PGMAJFAULT);
>  	}
>  
> -	delayacct_clear_flag(DELAYACCT_PF_SWAPIN);
>  	mark_page_accessed(page);
> +	delayacct_set_flag(DELAYACCT_PF_SWAPIN);
>  	lock_page(page);
> +	delayacct_clear_flag(DELAYACCT_PF_SWAPIN);
>  
>  	/*
>  	 * Back out if somebody else already faulted in this pte.
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
