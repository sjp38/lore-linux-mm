Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 600F66B0033
	for <linux-mm@kvack.org>; Thu, 12 Oct 2017 09:33:26 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id 136so3142288wmu.10
        for <linux-mm@kvack.org>; Thu, 12 Oct 2017 06:33:26 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p14si817992wre.148.2017.10.12.06.33.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 12 Oct 2017 06:33:24 -0700 (PDT)
Date: Thu, 12 Oct 2017 15:33:23 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 3/8] mm, truncate: Remove all exceptional entries from
 pagevec under one lock
Message-ID: <20171012133323.GB29293@quack2.suse.cz>
References: <20171012093103.13412-1-mgorman@techsingularity.net>
 <20171012093103.13412-4-mgorman@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171012093103.13412-4-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Jan Kara <jack@suse.cz>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Dave Chinner <david@fromorbit.com>

On Thu 12-10-17 10:30:58, Mel Gorman wrote:
> During truncate each entry in a pagevec is checked to see if it is an
> exceptional entry and if so, the shadow entry is cleaned up.  This is
> potentially expensive as multiple entries for a mapping locks/unlocks the
> tree lock.  This batches the operation such that any exceptional entries
> removed from a pagevec only acquire the mapping tree lock once. The corner
> case where this is more expensive is where there is only one exceptional
> entry but this is unlikely due to temporal locality and how it affects
> LRU ordering. Note that for truncations of small files created recently,
> this patch should show no gain because it only batches the handling of
> exceptional entries.
> 
> sparsetruncate (large)
>                               4.14.0-rc4             4.14.0-rc4
>                          pickhelper-v1r1       batchshadow-v1r1
> Min          Time       38.00 (   0.00%)       27.00 (  28.95%)
> 1st-qrtle    Time       40.00 (   0.00%)       28.00 (  30.00%)
> 2nd-qrtle    Time       44.00 (   0.00%)       41.00 (   6.82%)
> 3rd-qrtle    Time      146.00 (   0.00%)      147.00 (  -0.68%)
> Max-90%      Time      153.00 (   0.00%)      153.00 (   0.00%)
> Max-95%      Time      155.00 (   0.00%)      156.00 (  -0.65%)
> Max-99%      Time      181.00 (   0.00%)      171.00 (   5.52%)
> Amean        Time       93.04 (   0.00%)       88.43 (   4.96%)
> Best99%Amean Time       92.08 (   0.00%)       86.13 (   6.46%)
> Best95%Amean Time       89.19 (   0.00%)       83.13 (   6.80%)
> Best90%Amean Time       85.60 (   0.00%)       79.15 (   7.53%)
> Best75%Amean Time       72.95 (   0.00%)       65.09 (  10.78%)
> Best50%Amean Time       39.86 (   0.00%)       28.20 (  29.25%)
> Best25%Amean Time       39.44 (   0.00%)       27.70 (  29.77%)
> 
> bonnie
>                                       4.14.0-rc4             4.14.0-rc4
>                                  pickhelper-v1r1       batchshadow-v1r1
> Hmean     SeqCreate ops         71.92 (   0.00%)       76.78 (   6.76%)
> Hmean     SeqCreate read        42.42 (   0.00%)       45.01 (   6.10%)
> Hmean     SeqCreate del      26519.88 (   0.00%)    27191.87 (   2.53%)
> Hmean     RandCreate ops        71.92 (   0.00%)       76.95 (   7.00%)
> Hmean     RandCreate read       44.44 (   0.00%)       49.23 (  10.78%)
> Hmean     RandCreate del     24948.62 (   0.00%)    24764.97 (  -0.74%)
> 
> Truncation of a large number of files shows a substantial gain with 99% of files
> being trruncated 6.46% faster. bonnie shows a modest gain of 2.53%
> 
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> ---
>  mm/truncate.c | 86 ++++++++++++++++++++++++++++++++++++++++++-----------------
>  1 file changed, 61 insertions(+), 25 deletions(-)
> 
> diff --git a/mm/truncate.c b/mm/truncate.c
> index 3dfa2d5e642e..af1eaa5b9450 100644
> --- a/mm/truncate.c
> +++ b/mm/truncate.c
> @@ -25,44 +25,77 @@
>  #include <linux/rmap.h>
>  #include "internal.h"
>  
> -static void clear_shadow_entry(struct address_space *mapping, pgoff_t index,
> -			       void *entry)
> +/*
> + * Regular page slots are stabilized by the page lock even without the tree
> + * itself locked.  These unlocked entries need verification under the tree
> + * lock.
> + */
> +static inline void __clear_shadow_entry(struct address_space *mapping,
> +				pgoff_t index, void *entry)
>  {
>  	struct radix_tree_node *node;
>  	void **slot;
>  
> -	spin_lock_irq(&mapping->tree_lock);
> -	/*
> -	 * Regular page slots are stabilized by the page lock even
> -	 * without the tree itself locked.  These unlocked entries
> -	 * need verification under the tree lock.
> -	 */
>  	if (!__radix_tree_lookup(&mapping->page_tree, index, &node, &slot))
> -		goto unlock;
> +		return;
>  	if (*slot != entry)
> -		goto unlock;
> +		return;
>  	__radix_tree_replace(&mapping->page_tree, node, slot, NULL,
>  			     workingset_update_node, mapping);
>  	mapping->nrexceptional--;
> -unlock:
> +}
> +
> +static void clear_shadow_entry(struct address_space *mapping, pgoff_t index,
> +			       void *entry)
> +{
> +	spin_lock_irq(&mapping->tree_lock);
> +	__clear_shadow_entry(mapping, index, entry);
>  	spin_unlock_irq(&mapping->tree_lock);
>  }
>  
>  /*
> - * Unconditionally remove exceptional entry. Usually called from truncate path.
> + * Unconditionally remove exceptional entries. Usually called from truncate
> + * path. Note that the pagevec may be altered by this function by removing
> + * exceptional entries similar to what pagevec_remove_exceptionals does.
>   */
> -static void truncate_exceptional_entry(struct address_space *mapping,
> -				       pgoff_t index, void *entry)
> +static void truncate_exceptional_pvec_entries(struct address_space *mapping,
> +				struct pagevec *pvec, pgoff_t *indices, int ei)
>  {
> +	int i, j;
> +	bool dax;
> +
> +	/* Return immediately if caller indicates there are no entries */
> +	if (ei == PAGEVEC_SIZE)
> +		return;
> +
>  	/* Handled by shmem itself */
>  	if (shmem_mapping(mapping))
>  		return;
>  
> -	if (dax_mapping(mapping)) {
> -		dax_delete_mapping_entry(mapping, index);
> -		return;
> +	dax = dax_mapping(mapping);
> +	if (!dax)
> +		spin_lock_irq(&mapping->tree_lock);
> +
> +	for (i = ei, j = ei; i < pagevec_count(pvec); i++) {
> +		struct page *page = pvec->pages[i];
> +		pgoff_t index = indices[i];
> +
> +		if (!radix_tree_exceptional_entry(page)) {
> +			pvec->pages[j++] = page;
> +			continue;
> +		}
> +
> +		if (unlikely(dax)) {
> +			dax_delete_mapping_entry(mapping, index);
> +			continue;
> +		}
> +
> +		__clear_shadow_entry(mapping, index, page);
>  	}
> -	clear_shadow_entry(mapping, index, entry);
> +
> +	if (!dax)
> +		spin_unlock_irq(&mapping->tree_lock);
> +	pvec->nr = j;
>  }

When I look at this I think could make things cleaner. I have the following
observations:

1) All truncate_inode_pages(), invalidate_mapping_pages(),
invalidate_inode_pages2_range() essentially do very similar thing and would
benefit from a similar kind of batching.

2) As you observed and measured, batching of radix tree operations makes
sense both when removing pages and shadow entries, I'm very confident it
would make sense for DAX exceptional entries as well.

3) In all cases (i.e., those three functions and for all entry types) the
workflow seems to be:
  * lockless lookup of entries
  * prepare entry for reclaim (or determine it is not elligible)
  * lock mapping->tree_lock
  * verify entry is still elligible for reclaim (otherwise bail)
  * clear radix tree entry
  * unlock mapping->tree_lock
  * final cleanup of the entry

So I'm wondering whether we cannot somehow refactor stuff so that batching
of radix tree operations could be shared and we wouldn't have to duplicate
it in all those cases.

But it would be rather large overhaul of the code so it may be a bit out of
scope for these improvements...

> @@ -409,8 +445,8 @@ void truncate_inode_pages_range(struct address_space *mapping,
>  			}
>  
>  			if (radix_tree_exceptional_entry(page)) {
> -				truncate_exceptional_entry(mapping, index,
> -							   page);
> +				if (ei != PAGEVEC_SIZE)
> +					ei = i;

This should be ei == PAGEVEC_SIZE I think.

Otherwise the patch looks good to me so feel free to add:

Reviewed-by: Jan Kara <jack@suse.cz>

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
