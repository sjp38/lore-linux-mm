Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 89FD96B01B0
	for <linux-mm@kvack.org>; Wed, 30 Jun 2010 17:25:02 -0400 (EDT)
Date: Wed, 30 Jun 2010 14:24:43 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] Adding four read-only files to /proc/sys/vm
Message-Id: <20100630142443.d9a9c49e.akpm@linux-foundation.org>
In-Reply-To: <1277747099-12770-1-git-send-email-mrubin@google.com>
References: <1277747099-12770-1-git-send-email-mrubin@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Michael Rubin <mrubin@google.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, jack@suse.cz, david@fromorbit.com, hch@lst.de, axboe@kernel.dk
List-ID: <linux-mm.kvack.org>

On Mon, 28 Jun 2010 10:44:59 -0700
Michael Rubin <mrubin@google.com> wrote:

> Adding four read-only files to /proc/sys/vm
> 
> To help developers and applications gain visibility into writeback
> behaviour adding four read only sysctl files into /proc/sys/vm.
> These files allow user apps to understand writeback behaviour over time
> and learn how it is impacting their performance.
> 
>     # cat /proc/sys/vm/pages_dirtied
>     3747
>     # cat /proc/sys/vm/pages_entered_writeback
>     3618
>     # cat /proc/sys/vm/dirty_threshold
>     816673
>     # cat /proc/sys/vm/dirty_background_threshold
>     408336
> 
> Documentation/vm.txt has been updated.
> 
> In order to track the "cleaned" and "dirtied" counts we added two
> vm_stat_items.  Per memory node stats have been added also. So we can
> see per node granularity:
> 
>     # cat /sys/devices/system/node/node20/writebackstat
>     Node 20 pages_writeback: 0 times
>     Node 20 pages_dirtied: 0 times
> 
> A helper function, account_page_writeback, was added to encapsulate
> incrementing vm stats from nilfs. ceph code was also changed to use a
> mm helper routine.
> 

Well...  why are these useful?  In what operational scenario would
someone use these and get goodness from the experience?  Where is the
value?  Sell it to us!



I'm generally reluctant to add /proc knobs which expose internals or
which tie us into particular implementations.

It's hard to see how any future implementation could have a problem
implementing pages_dirtied and pages_entered_writeback, however
dirty_threshold and dirty_background_threshold are, I think, somewhat
specific to the current implementation and may be hard to maintain next
time we rip up and rewrite everything.

>
> ...
>
> +dirty_background_threshold
> +
> +Contains the exact amount of dirty memory memory the kernel uses to trigger the
> +background writeout daemon will start writing out dirty data. This value
> +depends on memory state, dirty_background_ratio and/or
> +dirty_background_bytes. This value is read-only.

Documentation doesn't describe the units.  Pages?  kbytes?  bytes?

I think it's best to encode the units in the procfs filename
(eg: dirty_expire_centisecs, min_free_kbytes).

> +==============================================================
> +
>  dirty_bytes
>  
>  Contains the amount of dirty memory at which a process generating disk writes
> @@ -123,6 +136,15 @@ data.
>  
>  ==============================================================
>  
> +dirty_threshold
> +
> +Contains the exact amount of dirty memory the kernel uses to decide when
> +a process which is generating disk writes will itself start writing
> +out data. This value depends on memory state, dirty_ratio and/or
> +dirty_bytes. This value is read-only.

units?

> +=============================================================
> +
> +pages_dirtied
> +
> +Number of pages that have ever been dirtied since boot.
> +This value is read-only.
> +
>  =============================================================
>  
> +pages_entered_writeback
> +
> +Number of pages that have been moved from dirty to writeback since boot.
> +This is only a count of file pages. This value is read-only.
> +

Am interested in hearing (in the changelog!) why these are considered
useful.  

We're very very interested in knowing how many pages entered writeback
via mm/vmscan.c however this procfs file lumps those together with the
pages which entered writeback via the regular writeback paths, I assume.

>
> ...
>
> --- a/fs/ceph/addr.c
> +++ b/fs/ceph/addr.c
> @@ -105,13 +105,7 @@ static int ceph_set_page_dirty(struct page *page)
>  	spin_lock_irq(&mapping->tree_lock);
>  	if (page->mapping) {	/* Race with truncate? */
>  		WARN_ON_ONCE(!PageUptodate(page));
> -
> -		if (mapping_cap_account_dirty(mapping)) {
> -			__inc_zone_page_state(page, NR_FILE_DIRTY);
> -			__inc_bdi_stat(mapping->backing_dev_info,
> -					BDI_RECLAIMABLE);
> -			task_io_account_write(PAGE_CACHE_SIZE);
> -		}
> +		account_page_dirtied(page, mapping);
>  		radix_tree_tag_set(&mapping->page_tree,
>  				page_index(page), PAGECACHE_TAG_DIRTY);

Nice cleanup.  And a bugfix, perhaps?  The missing
task_dirty_inc(current)?

But we need EXPORT_SYMBOL(account_page_dirtied), methinks.

This should be a separate patch IMO.

>
> ...
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
