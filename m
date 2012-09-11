Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 8C1356B00BA
	for <linux-mm@kvack.org>; Tue, 11 Sep 2012 07:05:39 -0400 (EDT)
Date: Tue, 11 Sep 2012 12:05:35 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 1/3 v2] mm: Batch unmapping of file mapped pages in
 shrink_page_list
Message-ID: <20120911110535.GO11157@csn.ul.ie>
References: <1347293965.9977.71.camel@schen9-DESK>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1347293965.9977.71.camel@schen9-DESK>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@suse.cz>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, Paul Gortmaker <paul.gortmaker@windriver.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>, Alex Shi <alex.shi@intel.com>, Matthew Wilcox <willy@linux.intel.com>, Fengguang Wu <fengguang.wu@intel.com>

On Mon, Sep 10, 2012 at 09:19:25AM -0700, Tim Chen wrote:
> We gather the pages that need to be unmapped in shrink_page_list.  We batch
> the unmap to reduce the frequency of acquisition of
> the tree lock protecting the mapping's radix tree. This is
> possible as successive pages likely share the same mapping in 
> __remove_mapping_batch routine.  This avoids excessive cache bouncing of
> the tree lock when page reclamations are occurring simultaneously.
> 

Ok, I get the intention of the patch at least. Based on the description
and without seeing the code I worry that this depends on pages belonging
to the same mapping being adjacent in the LRU list.

It would also be nice to get a better description of the workload in
your leader and ideally a perf reporting showing a reduced amount of time
acquiring the tree lock.

> Tim
> ---
> Signed-off-by: Tim Chen <tim.c.chen@linux.intel.com>

Patch formatting error. Your signed-off-by should be above the --- and
there is no need for your signature.

> --- 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index aac5672..d4ab646 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -600,6 +600,85 @@ cannot_free:
>  	return 0;
>  }
>  
> +/* Same as __remove_mapping, but batching operations to minimize locking */
> +/* Pages to be unmapped should be locked first */

/*
 * multi-line comments should
 * look like this
 */

> +static int __remove_mapping_batch(struct list_head *unmap_pages,
> +				  struct list_head *ret_pages,
> +				  struct list_head *free_pages)

The return values should be explained in the comments. What's in
ret_pages, what's in free_pages?

/*
 * When this function returns, unmap_pages will be empty. ret_pages
 * will contain ..... . free_pages will contain ...
 */

unmap_pages is a misleading name. In the context of vmscan.c "unmap"
means that the page is unmapped from the userspace page tables. Here you
are removing the pages from the address space radix tree.

> +{
> +	struct address_space *mapping, *next;
> +	LIST_HEAD(swap_pages);
> +	swp_entry_t swap;
> +	struct page *page;
> +	int nr_reclaimed;
> +
> +	mapping = NULL;
> +	nr_reclaimed = 0;
> +	while (!list_empty(unmap_pages)) {
> +

unnecessary whitespace.

> +		page = lru_to_page(unmap_pages);
> +		BUG_ON(!PageLocked(page));
> +
> +		list_del(&page->lru);
> +		next = page_mapping(page);
> +		if (mapping != next) {
> +			if (mapping)
> +				spin_unlock_irq(&mapping->tree_lock);
> +			mapping = next;
> +			spin_lock_irq(&mapping->tree_lock);
> +		}

Ok, so for the batching to work the pages do need to be adjacent on the
LRU list. There is nothing wrong with this as such but this limitation
should be called out in the changelog.

> +
> +		if (!page_freeze_refs(page, 2))
> +			goto cannot_free;
> +		if (unlikely(PageDirty(page))) {
> +			page_unfreeze_refs(page, 2);
> +			goto cannot_free;
> +		}
> +
> +		if (PageSwapCache(page)) {
> +			__delete_from_swap_cache(page);
> +			/* swapcache_free need to be called without tree_lock */
> +			list_add(&page->lru, &swap_pages);
> +		} else {
> +			void (*freepage)(struct page *);
> +
> +			freepage = mapping->a_ops->freepage;
> +
> +			__delete_from_page_cache(page);
> +			mem_cgroup_uncharge_cache_page(page);
> +
> +			if (freepage != NULL)
> +				freepage(page);
> +
> +			unlock_page(page);

no longer using __clear_page_locked in the success path, why?

> +			nr_reclaimed++;
> +			list_add(&page->lru, free_pages);
> +		}
> +		continue;
> +cannot_free:
> +		unlock_page(page);
> +		list_add(&page->lru, ret_pages);
> +		VM_BUG_ON(PageLRU(page) || PageUnevictable(page));
> +
> +	}
> +
> +	if (mapping)
> +		spin_unlock_irq(&mapping->tree_lock);
> +
> +	while (!list_empty(&swap_pages)) {
> +		page = lru_to_page(&swap_pages);
> +		list_del(&page->lru);
> +
> +		swap.val = page_private(page);
> +		swapcache_free(swap, page);
> +
> +		unlock_page(page);
> +		nr_reclaimed++;
> +		list_add(&page->lru, free_pages);
> +	}
> +
> +	return nr_reclaimed;
> +}
>  /*
>   * Attempt to detach a locked page from its ->mapping.  If it is dirty or if
>   * someone else has a ref on the page, abort and return 0.  If it was
> @@ -771,6 +850,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>  {
>  	LIST_HEAD(ret_pages);
>  	LIST_HEAD(free_pages);
> +	LIST_HEAD(unmap_pages);
>  	int pgactivate = 0;
>  	unsigned long nr_dirty = 0;
>  	unsigned long nr_congested = 0;
> @@ -969,17 +1049,13 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>  			}
>  		}
>  
> -		if (!mapping || !__remove_mapping(mapping, page))
> +		if (!mapping)
>  			goto keep_locked;
>  
> -		/*
> -		 * At this point, we have no other references and there is
> -		 * no way to pick any more up (removed from LRU, removed
> -		 * from pagecache). Can use non-atomic bitops now (and
> -		 * we obviously don't have to worry about waking up a process
> -		 * waiting on the page lock, because there are no references.
> -		 */
> -		__clear_page_locked(page);
> +		/* remove pages from mapping in batch at end of loop */
> +		list_add(&page->lru, &unmap_pages);
> +		continue;
> +
>  free_it:
>  		nr_reclaimed++;
>  

One *massive* change here that is not called out in the changelog is that
the reclaim path now holds the page lock on multiple pages at the same
time waiting for them to be batch unlocked in __remove_mapping_batch.
This is suspicious for two reasons.

The first suspicion is that it is expected that there are filesystems
that lock multiple pages in page->index order and page reclaim tries to
lock pages in a random order.  You are "ok" because you trylock the pages
but there should be a comment explaining the situation and why you're
ok.

My *far* greater concern is that the hold time for a locked page is
now potentially much longer. You could lock a bunch of filesystem pages
and then call pageout() on an swapcache page that takes a long time to
write. This potentially causes a filesystem (or flusher threads etc)
to stall on lock_page and that could cause all sorts of latency trouble.
It will be hard to hit this bug and diagnose it but I believe it's
there.

That second risk *really* must be commented upon and ideally reviewed by
the filesystem people. However, I very strongly suspect that the outcome
of such a review will be a suggestion to unlock the pages and reacquire
the lock in __remove_mapping_batch(). Bear in mind that if you take this
approach that you *must* use trylock when reacquiring the page lock and
handle being unable to lock the page.


> @@ -1014,6 +1090,9 @@ keep_lumpy:
>  		VM_BUG_ON(PageLRU(page) || PageUnevictable(page));
>  	}
>  
> +	nr_reclaimed += __remove_mapping_batch(&unmap_pages, &ret_pages,
> +					       &free_pages);
> +
>  	/*
>  	 * Tag a zone as congested if all the dirty pages encountered were
>  	 * backed by a congested BDI. In this case, reclaimers should just
> 

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
