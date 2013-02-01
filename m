Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id 4DADF6B0007
	for <linux-mm@kvack.org>; Fri,  1 Feb 2013 18:15:04 -0500 (EST)
Date: Fri, 1 Feb 2013 15:15:02 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 10/18] mm: teach truncate_inode_pages_range() to handle
 non page aligned ranges
Message-Id: <20130201151502.59398b29.akpm@linux-foundation.org>
In-Reply-To: <1359715424-32318-11-git-send-email-lczerner@redhat.com>
References: <1359715424-32318-1-git-send-email-lczerner@redhat.com>
	<1359715424-32318-11-git-send-email-lczerner@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lukas Czerner <lczerner@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, xfs@oss.sgi.com, Hugh Dickins <hughd@google.com>

On Fri,  1 Feb 2013 11:43:36 +0100
Lukas Czerner <lczerner@redhat.com> wrote:

> This commit changes truncate_inode_pages_range() so it can handle non
> page aligned regions of the truncate. Currently we can hit BUG_ON when
> the end of the range is not page aligned, but we can handle unaligned
> start of the range.
> 
> Being able to handle non page aligned regions of the page can help file
> system punch_hole implementations and save some work, because once we're
> holding the page we might as well deal with it right away.
> 
> In previous commits we've changed ->invalidatepage() prototype to accept
> 'length' argument to be able to specify range to invalidate. No we can
> use that new ability in truncate_inode_pages_range().

The change seems sensible.

> This was based on the code provided by Hugh Dickins

Despite this ;)

> changes to make use of do_invalidatepage_range().
>
> ...
>
>  void truncate_inode_pages_range(struct address_space *mapping,
>  				loff_t lstart, loff_t lend)
>  {
> -	const pgoff_t start = (lstart + PAGE_CACHE_SIZE-1) >> PAGE_CACHE_SHIFT;
> -	const unsigned partial = lstart & (PAGE_CACHE_SIZE - 1);
> +	pgoff_t start = (lstart + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
> +	pgoff_t end = (lend + 1) >> PAGE_CACHE_SHIFT;
> +	unsigned int partial_start = lstart & (PAGE_CACHE_SIZE - 1);
> +	unsigned int partial_end = (lend + 1) & (PAGE_CACHE_SIZE - 1);
>  	struct pagevec pvec;
>  	pgoff_t index;
> -	pgoff_t end;
>  	int i;

This is starting to get pretty hairy.  Some of these "end" variables
are inclusive and some are exclusive.

Can we improve things?  We can drop all this tiresome
intialisation-at-declaration-site stuff and do:

	pgoff_t start;			/* inclusive */
	pgoff_t end;			/* exclusive */
	unsigned int partial_start;	/* inclusive */
	unsigned int partial_end;	/* exclusive */
	struct pagevec pvec;
	pgoff_t index;
	int i;

	start = (lstart + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
	end = (lend + 1) >> PAGE_CACHE_SHIFT;
	partial_start = lstart & (PAGE_CACHE_SIZE - 1);
	partial_end = (lend + 1) & (PAGE_CACHE_SIZE - 1);

And lo, I see that the "inclusive" thing only applies to incoming arg
`lend'.  I seem to recall that being my handiwork and somehow I seem to
not have documented the reason: it was so that we can pass
lend=0xffffffff into truncate_inode_pages_range) to indicate "end of
file".

Your code handles this in a rather nasty fashion.  It permits the above
overflow to occur then later fixes it up with an explicit test for -1. 
And it then sets `end' (which is a pgoff_t!) to -1.

I guess this works, but let's make it clearer, with something like:

	if (lend == -1) {
		/*
		 * Nice explanation goes here
		 */
		end = -1;
	} else {
		end = (lend + 1) >> PAGE_CACHE_SHIFT;
	}


>  	cleancache_invalidate_inode(mapping);
>  	if (mapping->nrpages == 0)
>  		return;
>  
> -	BUG_ON((lend & (PAGE_CACHE_SIZE - 1)) != (PAGE_CACHE_SIZE - 1));
> -	end = (lend >> PAGE_CACHE_SHIFT);
> +	if (lend == -1)
> +		end = -1;	/* unsigned, so actually very big */
>  
>  	pagevec_init(&pvec, 0);
>  	index = start;
> -	while (index <= end && pagevec_lookup(&pvec, mapping, index,
> -			min(end - index, (pgoff_t)PAGEVEC_SIZE - 1) + 1)) {
> +	while (index < end && pagevec_lookup(&pvec, mapping, index,
> +			min(end - index, (pgoff_t)PAGEVEC_SIZE))) {

Here, my brain burst.  You've effectively added 1 to (end - index).  Is
that correct?

>  		mem_cgroup_uncharge_start();
>  		for (i = 0; i < pagevec_count(&pvec); i++) {
>  			struct page *page = pvec.pages[i];
>  
>  			/* We rely upon deletion not changing page->index */
>  			index = page->index;
> -			if (index > end)
> +			if (index >= end)

hm.  This change implies that the patch changed `end' from inclusive to
exclusive.  But the patch didn't do that.

>  				break;
>  
>  			if (!trylock_page(page))
> @@ -250,27 +247,51 @@ void truncate_inode_pages_range(struct address_space *mapping,
>  		index++;
>  	}
>  
> -	if (partial) {
> +	if (partial_start) {
>  		struct page *page = find_lock_page(mapping, start - 1);
>  		if (page) {
> +			unsigned int top = PAGE_CACHE_SIZE;
> +			if (start > end) {

How can this be true?

> +				top = partial_end;
> +				partial_end = 0;
> +			}
> +			wait_on_page_writeback(page);
> +			zero_user_segment(page, partial_start, top);
> +			cleancache_invalidate_page(mapping, page);
> +			if (page_has_private(page))
> +				do_invalidatepage(page, partial_start,
> +						  top - partial_start);
> +			unlock_page(page);
> +			page_cache_release(page);
> +		}
> +	}
> +	if (partial_end) {
> +		struct page *page = find_lock_page(mapping, end);
> +		if (page) {
>  			wait_on_page_writeback(page);
> -			truncate_partial_page(page, partial);
> +			zero_user_segment(page, 0, partial_end);
> +			cleancache_invalidate_page(mapping, page);
> +			if (page_has_private(page))
> +				do_invalidatepage(page, 0,
> +						  partial_end);
>  			unlock_page(page);
>  			page_cache_release(page);
>  		}
>  	}
> +	if (start >= end)
> +		return;

Again, how can start be greater than end??

I suspect a lot of the confustion and churn in here is due to `end'
being kinda-exclusive.  If `lend' was 4094 then `end' is zero.  But if
`lend' was 4095' then `end' is 1.  So even though `end' refers to the same
page, it has a different value!

Would the code be simpler and clearer if we were to make `end' "pgoff_t
of the last-affected page", and document it as such?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
