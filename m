Date: Sun, 15 Oct 2006 18:57:18 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [rfc][patch] shmem: don't zero full-page writes
In-Reply-To: <20061014055956.GA6014@wotan.suse.de>
Message-ID: <Pine.LNX.4.64.0610151749190.32055@blonde.wat.veritas.com>
References: <20061014055956.GA6014@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sat, 14 Oct 2006, Nick Piggin wrote:
> Just while looking at the peripheral code around the pagecache deadlocks
> problem, I noticed we might be able to speed up shmem a bit. This patch
> isn't well tested when shmem goes into swap, but before wasting more time on
> it I just wanted to see if there is a fundamental reason why we're not doing
> this?

No fundamental reason: I did consider doing so a couple of times,
but it's rather messy and nobody was complaining, so I didn't bother.

> 
> --
> Don't zero out newly allocated tmpfs pages if we're about to write a full
> page to them anyway, and also don't bother to read them in from swap.
> Increases aligned write bandwidth by about 30% for 4M writes to shmfs
> in RAM, and about 7% for 4K writes. Not tested with swap backed shm yet;
> the improvement will be much larger but it should be much less common.

That's quite nice: though as I say, nobody had complained (I think the
high performance people are usually looking at the shm end rather than
at tmpfs files, so wouldn't see any benefit).

I'd like your patch _so_ much more if it didn't scatter SGP_WRITE_FULL
(and free_swap) conditionals all over: we'd all prefer a simpler
shmem_getpage to a more complex one.  That's the messiness that
put me off.  I wonder if there's a better way, but don't see it.

I wonder if the patch you tested is this one you've sent out: it
seems uncertain what to do with PageUptodate, and mishandles it.

> -	if (filepage && PageUptodate(filepage))
> -		goto done;
> +	if (filepage) {
> +		if (PageUptodate(filepage) || sgp == SGP_WRITE_FULL)
> +			goto done;
> +	} else if (sgp != SGP_QUICK && sgp != SGP_READ) {
> +		gfp_t gfp = mapping_gfp_mask(mapping);
> +		if (sgp != SGP_WRITE_FULL)
> +			gfp |= __GFP_ZERO;
> +		cache = shmem_alloc_page(mapping_gfp_mask(mapping), info, idx);
> +		if (sgp != SGP_WRITE_FULL) {
> +			flush_dcache_page(filepage);
> +			SetPageUptodate(filepage); /* could be non-atomic */
> +		}

That's a very odd place to SetPageUptodate(filepage), where filepage
is NULL.  Those lines seem to have crept up from much further down.

> +not_swap_backed:
> +			BUG_ON(!cache);
> +			filepage = cache;
> +			if (add_to_page_cache_lru(filepage, mapping,
> +							idx, GFP_ATOMIC)) {
> +				if (free_swap)
> +					shmem_swp_unmap(entry);
>  				spin_unlock(&info->lock);
> -				page_cache_release(filepage);
>  				shmem_unacct_blocks(info->flags, 1);
>  				shmem_free_blocks(inode, 1);
>  				filepage = NULL;
> -				if (error)
> -					goto failed;
>  				goto repeat;

You're in danger of leaking your cache page when you go back to repeat
there.  But you do indeed want to retry a memory allocation, otherwise
it might cycle around without any memory for the add_to_page_cache_lru.
Perhaps you just need to reinstate the page_cache_release(filepage)?

But the main problem is over in shmem_file_write:

> @@ -1458,6 +1480,8 @@ shmem_file_write(struct file *file, cons
>  			i_size_write(inode, pos);
>  
>  		flush_dcache_page(page);
> +		if (sgp == SGP_WRITE_FULL)
> +			SetPageUptodate(page);
>  		set_page_dirty(page);
>  		mark_page_accessed(page);
>  		page_cache_release(page);

If someone might be waiting for PageUptodate, you ought to wake them.
But in fact nobody does wait for that PageUptodate, and you don't
have pagelock, which is bad news: someone can get in to peep at the
uninitialized page (just as I think you've discovered in ramfs).

I suggest you set this patch aside for now.  If your various
truncation/pagelock/deadlock efforts work out, then it should
become natural for us to change shmem_getpage to return with
pagelock held, and then might as well SetPageUptodate itself
as now (prematurely, but no matter while pagelock is held,
since even to read demands pagelock for a moment).

And meanwhile we'll maybe think of a more appealing way to do it.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
