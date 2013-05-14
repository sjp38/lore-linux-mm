Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id A99466B0083
	for <linux-mm@kvack.org>; Tue, 14 May 2013 12:05:45 -0400 (EDT)
Date: Tue, 14 May 2013 17:05:41 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [RFC][PATCH 6/7] use __remove_mapping_batch() in
 shrink_page_list()
Message-ID: <20130514160541.GX11497@suse.de>
References: <20130507211954.9815F9D1@viggo.jf.intel.com>
 <20130507212002.219EDB7F@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20130507212002.219EDB7F@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, tim.c.chen@linux.intel.com

On Tue, May 07, 2013 at 02:20:02PM -0700, Dave Hansen wrote:
> 
> From: Dave Hansen <dave.hansen@linux.intel.com>
> 
> Tim Chen's earlier version of these patches just unconditionally
> created large batches of pages, even if they did not share a
> page->mapping.  This is a bit suboptimal for a few reasons:
> 1. if we can not consolidate lock acquisitions, it makes little
>    sense to batch
> 2. The page locks are held for long periods of time, so we only
>    want to do this when we are sure that we will gain a
>    substantial throughput improvement because we pay a latency
>    cost by holding the locks.
> 
> This patch makes sure to only batch when all the pages on
> 'batch_for_mapping_removal' continue to share a page->mapping.
> This only happens in practice in cases where pages in the same
> file are close to each other on the LRU.  That seems like a
> reasonable assumption.
> 
> In a 128MB virtual machine doing kernel compiles, the average
> batch size when calling __remove_mapping_batch() is around 5,
> so this does seem to do some good in practice.
> 
> On a 160-cpu system doing kernel compiles, I still saw an
> average batch length of about 2.8.  One promising feature:
> as the memory pressure went up, the average batches seem to
> have gotten larger.
> 

That's curious to me. I would expect with 160 CPUs reading files that it
would become less likely that they would insert pages backed by the same
mapping adjacent to each other in the LRU list. Maybe readahead is adding
the pages in batch so they are still adjacent.  I expect you would see
the best batching for kernel compiles with make -j1

> Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
> ---
> 
>  linux.git-davehans/mm/vmscan.c |   52 +++++++++++++++++++++++++++++++++--------
>  1 file changed, 42 insertions(+), 10 deletions(-)
> 
> diff -puN mm/vmscan.c~use-remove_mapping_batch mm/vmscan.c
> --- linux.git/mm/vmscan.c~use-remove_mapping_batch	2013-05-07 13:48:15.016102828 -0700
> +++ linux.git-davehans/mm/vmscan.c	2013-05-07 13:48:15.020103005 -0700
> @@ -599,7 +599,14 @@ static int __remove_mapping_batch(struct
>  		page = lru_to_page(&need_free_mapping);
>  		list_move(&page->list, free_pages);
>  		free_mapping_page(mapping, page);
> -		unlock_page(page);
> +		/*
> +		 * At this point, we have no other references and there is
> +		 * no way to pick any more up (removed from LRU, removed
> +		 * from pagecache). Can use non-atomic bitops now (and
> +		 * we obviously don't have to worry about waking up a process
> +		 * waiting on the page lock, because there are no references.
> +		 */
> +		__clear_page_locked(page);
>  		nr_reclaimed++;
>  	}
>  	return nr_reclaimed;
> @@ -740,6 +747,15 @@ static enum page_references page_check_r
>  	return PAGEREF_RECLAIM;
>  }
>  
> +static bool batch_has_same_mapping(struct page *page, struct list_head *batch)
> +{
> +	struct page *first_in_batch;
> +	first_in_batch = lru_to_page(batch);
> +	if (first_in_batch->mapping == page->mapping)
> +		return true;

If you are batching the removal of PageSwapCache pages, will this check
still work as you used page->mapping instead of page_mapping?

> +	return false;
> +}
> +

This helper seems overkill. Why not just have batch_mapping in
shrink_page_list() that is set when the first page is added to the
batch_for_mapping_removal and defer the decision to drain until after the
page mapping has been looked up?

struct address_space *batch_mapping = NULL;

.....

mapping = page_mapping(page);
if (!batch_mapping)
	batch_mapping = mapping;

if (!list_empty(&batch_for_mapping_removal) && mapping != batch_mapping) {
	nr_reclaimed += __remove_mapping_batch(....);
	batch_mapping = mapping;
}

Locks will still be held across waiting on page writeback or pageout()
which could be for long periods of time and blocking flushers.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
