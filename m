Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp05.au.ibm.com (8.13.1/8.13.1) with ESMTP id l846VdYi006671
	for <linux-mm@kvack.org>; Tue, 4 Sep 2007 16:31:40 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l846ZAAA140992
	for <linux-mm@kvack.org>; Tue, 4 Sep 2007 16:35:11 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l847Va2u024365
	for <linux-mm@kvack.org>; Tue, 4 Sep 2007 17:31:36 +1000
Message-ID: <46DCFBB2.3060200@linux.vnet.ibm.com>
Date: Tue, 04 Sep 2007 07:31:14 +0100
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [MAILER-DAEMON@watson.ibm.com: Returned mail: see transcript
 for details]
References: <20070903201645.GA11502@wotan.suse.de>
In-Reply-To: <20070903201645.GA11502@wotan.suse.de>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Balbir Singh <balbir@in.ibm.com>, Shailabh Nagar <nagar1234@in.ibm.com>, Linux Memory Management List <linux-mm@kvack.org>, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:
> Hi,
> 
> This mail to Shailabh bounced, but I noticed you're on the Signed-off-by
> trail too, so forwarding to you so you don't miss it. Thanks,
> 

Thanks, Nick. I am cc'ing Shailabh's new email id.

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

Yes, for us it is. We measure the end to end delay of swapping in/out a page.

> But the most obvious delay, where we actually lock the page waiting for
> the swap IO to finish, does not seem to be accounted at all!
> 

Hmm.. Does lock_page() eventually call io_schedule() or io_schedule_timeout()?
I think it does -- via sync_page(). The way our accounting works is that we
account for block I/O in io_schedule*(). If we see the SWAPIN flag set, we
then account for that I/O as swap I/O.


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

Let's start the accounting here.

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

I agree that we should end it after lock_page().

>  	/*
>  	 * Back out if somebody else already faulted in this pte.
> 
> 
> ----- End forwarded message -----


-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
