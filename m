Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id B34916B0038
	for <linux-mm@kvack.org>; Wed,  4 Jan 2017 02:18:11 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id i131so82299785wmf.3
        for <linux-mm@kvack.org>; Tue, 03 Jan 2017 23:18:11 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a189si76720523wme.106.2017.01.03.23.18.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 03 Jan 2017 23:18:10 -0800 (PST)
Date: Wed, 4 Jan 2017 08:18:04 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH] dax: fix deadlock with DAX 4k holes
Message-ID: <20170104071804.GF3780@quack2.suse.cz>
References: <20161027112230.wsumgs62fqdxt3sc@xzhoul.usersys.redhat.com>
 <1483479365-13607-1-git-send-email-ross.zwisler@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1483479365-13607-1-git-send-email-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Xiong Zhou <xzhou@redhat.com>, stable@vger.kernel.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Dave Hansen <dave.hansen@intel.com>, Jan Kara <jack@suse.cz>, linux-mm@kvack.org, linux-nvdimm@lists.01.org

On Tue 03-01-17 14:36:05, Ross Zwisler wrote:
> Currently in DAX if we have three read faults on the same hole address we
> can end up with the following:
> 
> Thread 0		Thread 1		Thread 2
> --------		--------		--------
> dax_iomap_fault
>  grab_mapping_entry
>   lock_slot
>    <locks empty DAX entry>
> 
>   			dax_iomap_fault
> 			 grab_mapping_entry
> 			  get_unlocked_mapping_entry
> 			   <sleeps on empty DAX entry>
> 
> 						dax_iomap_fault
> 						 grab_mapping_entry
> 						  get_unlocked_mapping_entry
> 						   <sleeps on empty DAX entry>
>   dax_load_hole
>    find_or_create_page
>    ...
>     page_cache_tree_insert
>      dax_wake_mapping_entry_waiter
>       <wakes one sleeper>
>      __radix_tree_replace
>       <swaps empty DAX entry with 4k zero page>
> 
> 			<wakes>
> 			get_page
> 			lock_page
> 			...
> 			put_locked_mapping_entry
> 			unlock_page
> 			put_page
> 
> 						<sleeps forever on the DAX
> 						 wait queue>
> 
> The crux of the problem is that once we insert a 4k zero page, all locking
> from then on is done in terms of that 4k zero page and any additional
> threads sleeping on the empty DAX entry will never be woken.  Fix this by
> waking all sleepers when we replace the DAX radix tree entry with a 4k zero
> page.  This will allow all sleeping threads to successfully transition from
> locking based on the DAX empty entry to locking on the 4k zero page.
> 
> With the test case reported by Xiong this happens very regularly in my test
> setup, with some runs resulting in 9+ threads in this deadlocked state.
> With this fix I've been able to run that same test dozens of times in a
> loop without issue.
> 
> Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
> Reported-by: Xiong Zhou <xzhou@redhat.com>
> Fixes: commit ac401cc78242 ("dax: New fault locking")
> Cc: Jan Kara <jack@suse.cz>
> Cc: stable@vger.kernel.org # 4.7+

Ah, very good catch. You can add:

Reviewed-by: Jan Kara <jack@suse.cz>

I wonder why I was not able to reproduce this... Probably the timing didn't
work out right on my test machine.

								Honza

> ---
> 
> This issue exists as far back as v4.7, and I was easly able to reproduce it
> with v4.7 using the same test.
> 
> Unfortunately this patch won't apply cleanly to the stable trees, but the
> change is very simple and should be easy to replicate by hand.  Please ping
> me if you'd like patches that apply cleanly to the v4.9 and v4.8.15 trees.
> 
> ---
>  mm/filemap.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/filemap.c b/mm/filemap.c
> index d0e4d10..b772a33 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -138,7 +138,7 @@ static int page_cache_tree_insert(struct address_space *mapping,
>  				dax_radix_locked_entry(0, RADIX_DAX_EMPTY));
>  			/* Wakeup waiters for exceptional entry lock */
>  			dax_wake_mapping_entry_waiter(mapping, page->index, p,
> -						      false);
> +						      true);
>  		}
>  	}
>  	__radix_tree_replace(&mapping->page_tree, node, slot, page,
> -- 
> 2.7.4
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
