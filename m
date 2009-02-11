Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 847FE6B003D
	for <linux-mm@kvack.org>; Wed, 11 Feb 2009 18:18:37 -0500 (EST)
Date: Wed, 11 Feb 2009 15:18:01 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/2] mm: update_page_reclaim_stat() is called form page
 fault path
Message-Id: <20090211151801.d9e8c84b.akpm@linux-foundation.org>
In-Reply-To: <20090211213340.C3CD.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20090211213201.C3CA.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	<20090211213340.C3CD.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, npiggin@suse.de, hugh@veritas.com, riel@redhat.com
List-ID: <linux-mm.kvack.org>

On Wed, 11 Feb 2009 21:35:07 +0900 (JST)
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> 
> Unfortunately, following two patch have a bit conflicted concept.
>   1. commit 9ff473b9a72942c5ac0ad35607cae28d8d59ed7a 
>      (vmscan: evict streaming IO first)
>   2. commit bf3f3bc5e734706730c12a323f9b2068052aa1f0
>      (mm: don't mark_page_accessed in fault path)
> 
> (1) require page fault update reclaim stat via mark_page_accessed(), but
> (2) removed mark_page_accessed() perfectly. 
> 
> However, (1) actually only need to update reclaim stat, but not activate page.
> Then, fault-path calling update_page_reclaim_stat() solve thsi confliction.
> 
> ...
>
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -1545,6 +1545,7 @@ retry_find:
>  	/*
>  	 * Found the page and have a reference on it.
>  	 */
> +	update_page_reclaim_stat(page);
>  	ra->prev_pos = (loff_t)page->index << PAGE_CACHE_SHIFT;
>  	vmf->page = page;
>  	return ret | VM_FAULT_LOCKED;

This is the minor fault hotpath.

> +void update_page_reclaim_stat(struct page *page)
> +{
> +	struct zone *zone = page_zone(page);
> +
> +	spin_lock_irq(&zone->lru_lock);
> +	/* if the page isn't reclaimable, it doesn't update reclaim stat */
> +	if (PageLRU(page) && !PageUnevictable(page)) {
> +		update_page_reclaim_stat_locked(zone, page,
> +					 !!page_is_file_cache(page), 1);
> +	}
> +	spin_unlock_irq(&zone->lru_lock);
> +}

And we just added a spin_lock_irq() and a bunch of other stuff to it.

Can we improve this?

Can we just omit it, even?

Can we update those stats locklessly and accomodate the resulting
inaccuracy over at the codesites where these statistics are actually
used?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
