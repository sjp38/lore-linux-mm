Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id 533536B0032
	for <linux-mm@kvack.org>; Fri, 17 May 2013 09:35:31 -0400 (EDT)
Date: Fri, 17 May 2013 14:35:27 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [RFCv2][PATCH 5/5] batch shrink_page_list() locking operations
Message-ID: <20130517133527.GM11497@suse.de>
References: <20130516203427.E3386936@viggo.jf.intel.com>
 <20130516203434.41DFD429@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20130516203434.41DFD429@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, tim.c.chen@linux.intel.com

On Thu, May 16, 2013 at 01:34:34PM -0700, Dave Hansen wrote:
> 
> From: Dave Hansen <dave.hansen@linux.intel.com>
> changes for v2:
>  * remove batch_has_same_mapping() helper.  A local varible makes
>    the check cheaper and cleaner
>  * Move batch draining later to where we already know
>    page_mapping().  This probably fixes a truncation race anyway
>  * rename batch_for_mapping_removal -> batch_for_mapping_rm.  It
>    caused a line over 80 chars and needed shortening anyway.
>  * Note: we only set 'batch_mapping' when there are pages in the
>    batch_for_mapping_rm list
> 
> --
> 
> We batch like this so that several pages can be freed with a
> single mapping->tree_lock acquisition/release pair.  This reduces
> the number of atomic operations and ensures that we do not bounce
> cachelines around.
> 
> Tim Chen's earlier version of these patches just unconditionally
> created large batches of pages, even if they did not share a
> page_mapping().  This is a bit suboptimal for a few reasons:
> 1. if we can not consolidate lock acquisitions, it makes little
>    sense to batch
> 2. The page locks are held for long periods of time, so we only
>    want to do this when we are sure that we will gain a
>    substantial throughput improvement because we pay a latency
>    cost by holding the locks.
> 
> This patch makes sure to only batch when all the pages on
> 'batch_for_mapping_rm' continue to share a page_mapping().
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
> It has shown some substantial performance benefits on
> microbenchmarks.
> 
> Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
>
> <SNIP>
>
> @@ -718,6 +775,7 @@ static unsigned long shrink_page_list(st
>  		cond_resched();
>  
>  		page = lru_to_page(page_list);
> +
>  		list_del(&page->lru);
>  
>  		if (!trylock_page(page))

Can drop this hunk :/

> @@ -776,6 +834,10 @@ static unsigned long shrink_page_list(st
>  				nr_writeback++;
>  				goto keep_locked;
>  			}
> +			/*
> +			 * batch_for_mapping_rm could be drained here
> +			 * if its lock_page()s hurt latency elsewhere.
> +			 */
>  			wait_on_page_writeback(page);
>  		}
>  
> @@ -805,6 +867,18 @@ static unsigned long shrink_page_list(st
>  		}
>  
>  		mapping = page_mapping(page);
> +		/*
> +		 * batching only makes sense when we can save lock
> +		 * acquisitions, so drain the previously-batched
> +		 * pages when we move over to a different mapping
> +		 */
> +		if (batch_mapping && (batch_mapping != mapping)) {
> +			nr_reclaimed +=
> +				__remove_mapping_batch(&batch_for_mapping_rm,
> +							&ret_pages,
> +							&free_pages);
> +			batch_mapping = NULL;
> +		}
>  
>  		/*
>  		 * The page is mapped into the page tables of one or more

As a heads-up, Andrew picked up a reclaim-related series from me. It
adds a new wait_on_page_writeback() with a revised patch making it a
congestion_wait() inside shrink_page_list. Watch when these two series
are integrated because you almost certainly want to do a follow-up patch
that drains before that congestion_wait too. 

Otherwise

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
