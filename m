Date: Sat, 11 Oct 2008 12:51:52 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH updated] ext4: Fix file fragmentation during large file write.
Message-ID: <20081011105152.GB29681@wotan.suse.de>
References: <1223661776-20098-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1223661776-20098-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: cmm@us.ibm.com, tytso@mit.edu, sandeen@redhat.com, chris.mason@oracle.com, akpm@linux-foundation.org, hch@infradead.org, steve@chygwyn.com, mpatocka@redhat.com, linux-mm@kvack.org, inux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, Oct 10, 2008 at 11:32:56PM +0530, Aneesh Kumar K.V wrote:
> The range_cyclic writeback mode use the address_space
> writeback_index as the start index for writeback. With
> delayed allocation we were updating writeback_index
> wrongly resulting in highly fragmented file. Number of
> extents reduced from 4000 to 27 for a 3GB file with
> the below patch.
> 
> The patch also removes the range_cont writeback mode
> added for ext4 delayed allocation. Instead we add
> two new flags in writeback_control which control
> the behaviour of write_cache_pages.

The mm/page-writeback.c changes look OK, although it loks like you've
got rid of range_cont? Should we do a patch to get rid of it entirely
from the tree first?

I don't mind rediffing my patchset on top of this, but this seems smaller
and not strictly a bugfix so I would prefer to go the other way if you
agree.

Seems like it could be broken up into several patches (eg. pagevec_lookup).

The results look very nice.

> 
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> ---
>  fs/ext4/inode.c           |  110 +++++++++++++++++++++++++-------------------
>  include/linux/writeback.h |    5 ++-
>  mm/page-writeback.c       |   11 +++--
>  3 files changed, 73 insertions(+), 53 deletions(-)
> 
> diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
> index 7c2820e..f8890b9 100644
> --- a/fs/ext4/inode.c
> +++ b/fs/ext4/inode.c
> @@ -1648,6 +1648,7 @@ static int mpage_da_submit_io(struct mpage_da_data *mpd)
>  	int ret = 0, err, nr_pages, i;
>  	unsigned long index, end;
>  	struct pagevec pvec;
> +	long pages_skipped;
>  
>  	BUG_ON(mpd->next_page <= mpd->first_page);
>  	pagevec_init(&pvec, 0);
> @@ -1655,20 +1656,30 @@ static int mpage_da_submit_io(struct mpage_da_data *mpd)
>  	end = mpd->next_page - 1;
>  
>  	while (index <= end) {
> -		/* XXX: optimize tail */
> -		nr_pages = pagevec_lookup(&pvec, mapping, index, PAGEVEC_SIZE);
> +		/*
> +		 * We can use PAGECACHE_TAG_DIRTY lookup here because
> +		 * even though we have cleared the dirty flag on the page
> +		 * We still keep the page in the radix tree with tag
> +		 * PAGECACHE_TAG_DIRTY. See clear_page_dirty_for_io.
> +		 * The PAGECACHE_TAG_DIRTY is cleared in set_page_writeback
> +		 * which is called via the below writepage callback.
> +		 */
> +		nr_pages = pagevec_lookup_tag(&pvec, mapping, &index,
> +					PAGECACHE_TAG_DIRTY,
> +					min(end - index,
> +					(pgoff_t)PAGEVEC_SIZE-1) + 1);
>  		if (nr_pages == 0)
>  			break;
>  		for (i = 0; i < nr_pages; i++) {
>  			struct page *page = pvec.pages[i];
>  
> -			index = page->index;
> -			if (index > end)
> -				break;
> -			index++;
> -
> +			pages_skipped = mpd->wbc->pages_skipped;
>  			err = mapping->a_ops->writepage(page, mpd->wbc);
> -			if (!err)
> +			if (!err && (pages_skipped == mpd->wbc->pages_skipped))
> +				/*
> +				 * have successfully written the page
> +				 * without skipping the same
> +				 */
>  				mpd->pages_written++;
>  			/*
>  			 * In error case, we have to continue because
> @@ -2104,7 +2115,6 @@ static int mpage_da_writepages(struct address_space *mapping,
>  			       struct writeback_control *wbc,
>  			       struct mpage_da_data *mpd)
>  {
> -	long to_write;
>  	int ret;
>  
>  	if (!mpd->get_block)
> @@ -2119,10 +2129,7 @@ static int mpage_da_writepages(struct address_space *mapping,
>  	mpd->pages_written = 0;
>  	mpd->retval = 0;
>  
> -	to_write = wbc->nr_to_write;
> -
>  	ret = write_cache_pages(mapping, wbc, __mpage_da_writepage, mpd);
> -
>  	/*
>  	 * Handle last extent of pages
>  	 */
> @@ -2131,7 +2138,7 @@ static int mpage_da_writepages(struct address_space *mapping,
>  			mpage_da_submit_io(mpd);
>  	}
>  
> -	wbc->nr_to_write = to_write - mpd->pages_written;
> +	wbc->nr_to_write -= mpd->pages_written;
>  	return ret;
>  }
>  
> @@ -2360,12 +2367,14 @@ static int ext4_da_writepages_trans_blocks(struct inode *inode)
>  static int ext4_da_writepages(struct address_space *mapping,
>  			      struct writeback_control *wbc)
>  {
> +	pgoff_t	index;
> +	int range_whole = 0;
>  	handle_t *handle = NULL;
> -	loff_t range_start = 0;
> +	long pages_written = 0;
>  	struct mpage_da_data mpd;
>  	struct inode *inode = mapping->host;
> +	int no_nrwrite_update, no_index_update;
>  	int needed_blocks, ret = 0, nr_to_writebump = 0;
> -	long to_write, pages_skipped = 0;
>  	struct ext4_sb_info *sbi = EXT4_SB(mapping->host->i_sb);
>  
>  	/*
> @@ -2385,23 +2394,27 @@ static int ext4_da_writepages(struct address_space *mapping,
>  		nr_to_writebump = sbi->s_mb_stream_request - wbc->nr_to_write;
>  		wbc->nr_to_write = sbi->s_mb_stream_request;
>  	}
> +	if (wbc->range_start == 0 && wbc->range_end == LLONG_MAX)
> +		range_whole = 1;
>  
> -	if (!wbc->range_cyclic)
> -		/*
> -		 * If range_cyclic is not set force range_cont
> -		 * and save the old writeback_index
> -		 */
> -		wbc->range_cont = 1;
> -
> -	range_start =  wbc->range_start;
> -	pages_skipped = wbc->pages_skipped;
> +	if (wbc->range_cyclic)
> +		index = mapping->writeback_index;
> +	else
> +		index = wbc->range_start >> PAGE_CACHE_SHIFT;
>  
>  	mpd.wbc = wbc;
>  	mpd.inode = mapping->host;
>  
> -restart_loop:
> -	to_write = wbc->nr_to_write;
> -	while (!ret && to_write > 0) {
> +	/*
> +	 * we don't want write_cache_pages to update
> +	 * nr_to_write and writeback_index
> +	 */
> +	no_nrwrite_update = wbc->no_nrwrite_update;
> +	wbc->no_nrwrite_update = 1;
> +	no_index_update = wbc->no_index_update;
> +	wbc->no_index_update   = 1;
> +
> +	while (!ret && wbc->nr_to_write > 0) {
>  
>  		/*
>  		 * we  insert one extent at a time. So we need
> @@ -2422,48 +2435,49 @@ static int ext4_da_writepages(struct address_space *mapping,
>  			dump_stack();
>  			goto out_writepages;
>  		}
> -		to_write -= wbc->nr_to_write;
> -
>  		mpd.get_block = ext4_da_get_block_write;
>  		ret = mpage_da_writepages(mapping, wbc, &mpd);
>  
>  		ext4_journal_stop(handle);
>  
> -		if (mpd.retval == -ENOSPC)
> +		if (mpd.retval == -ENOSPC) {
> +			/* commit the transaction which would
> +			 * free blocks released in the transaction
> +			 * and try again
> +			 */
>  			jbd2_journal_force_commit_nested(sbi->s_journal);
> -
> -		/* reset the retry count */
> -		if (ret == MPAGE_DA_EXTENT_TAIL) {
> +			ret = 0;
> +		} else if (ret == MPAGE_DA_EXTENT_TAIL) {
>  			/*
>  			 * got one extent now try with
>  			 * rest of the pages
>  			 */
> -			to_write += wbc->nr_to_write;
> +			pages_written += mpd.pages_written;
>  			ret = 0;
> -		} else if (wbc->nr_to_write) {
> +		} else if (wbc->nr_to_write)
>  			/*
>  			 * There is no more writeout needed
>  			 * or we requested for a noblocking writeout
>  			 * and we found the device congested
>  			 */
> -			to_write += wbc->nr_to_write;
>  			break;
> -		}
> -		wbc->nr_to_write = to_write;
>  	}
>  
> -	if (wbc->range_cont && (pages_skipped != wbc->pages_skipped)) {
> -		/* We skipped pages in this loop */
> -		wbc->range_start = range_start;
> -		wbc->nr_to_write = to_write +
> -				wbc->pages_skipped - pages_skipped;
> -		wbc->pages_skipped = pages_skipped;
> -		goto restart_loop;
> -	}
> +	/* Update index */
> +	index += pages_written;
> +	if (wbc->range_cyclic || (range_whole && wbc->nr_to_write > 0))
> +		/*
> +		 * set the writeback_index so that range_cyclic
> +		 * mode will write it back later
> +		 */
> +		mapping->writeback_index = index;
>  
>  out_writepages:
> -	wbc->nr_to_write = to_write - nr_to_writebump;
> -	wbc->range_start = range_start;
> +	if (!no_nrwrite_update)
> +		wbc->no_nrwrite_update = 0;
> +	if (!no_index_update)
> +		wbc->no_index_update   = 0;
> +	wbc->nr_to_write -= nr_to_writebump;
>  	return ret;
>  }
>  
> diff --git a/include/linux/writeback.h b/include/linux/writeback.h
> index 12b15c5..b04287e 100644
> --- a/include/linux/writeback.h
> +++ b/include/linux/writeback.h
> @@ -63,7 +63,10 @@ struct writeback_control {
>  	unsigned for_writepages:1;	/* This is a writepages() call */
>  	unsigned range_cyclic:1;	/* range_start is cyclic */
>  	unsigned more_io:1;		/* more io to be dispatched */
> -	unsigned range_cont:1;
> +
> +	/* write_cache_pages() control */
> +	unsigned no_nrwrite_update:1;	/* don't update nr_to_write */
> +	unsigned no_index_update:1;	/* don't update writeback_index */
>  };
>  
>  /*
> diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> index 24de8b6..a85930c 100644
> --- a/mm/page-writeback.c
> +++ b/mm/page-writeback.c
> @@ -876,6 +876,7 @@ int write_cache_pages(struct address_space *mapping,
>  	pgoff_t end;		/* Inclusive */
>  	int scanned = 0;
>  	int range_whole = 0;
> +	long nr_to_write = wbc->nr_to_write;
>  
>  	if (wbc->nonblocking && bdi_write_congested(bdi)) {
>  		wbc->encountered_congestion = 1;
> @@ -939,7 +940,7 @@ int write_cache_pages(struct address_space *mapping,
>  				unlock_page(page);
>  				ret = 0;
>  			}
> -			if (ret || (--(wbc->nr_to_write) <= 0))
> +			if (ret || (--nr_to_write <= 0))
>  				done = 1;
>  			if (wbc->nonblocking && bdi_write_congested(bdi)) {
>  				wbc->encountered_congestion = 1;
> @@ -958,11 +959,13 @@ int write_cache_pages(struct address_space *mapping,
>  		index = 0;
>  		goto retry;
>  	}
> -	if (wbc->range_cyclic || (range_whole && wbc->nr_to_write > 0))
> +	if (!wbc->no_index_update &&
> +		(wbc->range_cyclic || (range_whole && wbc->nr_to_write > 0))) {
>  		mapping->writeback_index = index;
> +	}
> +	if (!wbc->no_nrwrite_update)
> +		wbc->nr_to_write = nr_to_write;
>  
> -	if (wbc->range_cont)
> -		wbc->range_start = index << PAGE_CACHE_SHIFT;
>  	return ret;
>  }
>  EXPORT_SYMBOL(write_cache_pages);
> -- 
> 1.6.0.1.285.g1070

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
