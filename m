Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 868DD6B0169
	for <linux-mm@kvack.org>; Wed, 27 Jul 2011 16:14:06 -0400 (EDT)
Date: Wed, 27 Jul 2011 13:13:57 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v4 06/10] migration: introudce migrate_ilru_pages
Message-Id: <20110727131357.cc5a42ce.akpm@linux-foundation.org>
In-Reply-To: <132686a2ab204bb917bea5faa4eb5cb797940518.1309787991.git.minchan.kim@gmail.com>
References: <cover.1309787991.git.minchan.kim@gmail.com>
	<132686a2ab204bb917bea5faa4eb5cb797940518.1309787991.git.minchan.kim@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>

On Mon,  4 Jul 2011 23:04:39 +0900
Minchan Kim <minchan.kim@gmail.com> wrote:

> This patch defines new APIs to put back new page into old page's position as LRU order.
> for LRU churning of compaction.
> 
> The idea I suggested in LSF/MM is simple.
>
> ...
>
> +static bool same_lru(struct page *page, struct page *prev)
> +{
> +	bool ret = false;
> +	if (!prev || !PageLRU(prev))

Both parts of this test need explanations so readers can understand why
they are here.

> +		goto out;
> +
> +	if (unlikely(PageUnevictable(prev)))

As does this.

> +		goto out;
> +
> +	if (page_lru_base_type(page) != page_lru_base_type(prev))
> +		goto out;

This (and testing for PageLRU) is the only part of this function whcih
is sufficiently obvious to leave undocumented.

> +	ret = true;
> +out:
> +	return ret;
> +}
> +
> +void putback_ilru_pages(struct inorder_lru *l)
> +{
> +	struct zone *zone;
> +	struct page *page, *page2, *prev;
> +
> +	list_for_each_ilru_entry_safe(page, page2, l, ilru) {
> +		ilru_list_del(page, l);
> +		dec_zone_page_state(page, NR_ISOLATED_ANON +
> +				page_is_file_cache(page));
> +		zone = page_zone(page);
> +		spin_lock_irq(&zone->lru_lock);
> +		prev = page->ilru.prev_page;
> +		if (same_lru(page, prev)) {
> +			putback_page_to_lru(page, prev);
> +			spin_unlock_irq(&zone->lru_lock);
> +			put_page(page);
> +		} else {
> +			spin_unlock_irq(&zone->lru_lock);
> +			putback_lru_page(page);
> +		}
> +	}
> +}

This function takes lru_lock at lest once per page, up to twice per
page.  The spinlocking frequency here could be optimised tremendously.

The trick of hanging onto zone->lru_lock is the zone didn't change gets
hard if we want to do a put_page() inside the loop.

We have functions "putback_page_to_lru()" and "putback_lru_page()". 
Ugh.  Can we think of better naming?

Does this function even need to exist if CONFIG_MIGRATION=n?

> +/*
>   * Restore a potential migration pte to a working pte entry
>   */
>
> ...
>
> +void __put_ilru_pages(struct page *page, struct page *newpage,
> +		struct inorder_lru *prev_lru, struct inorder_lru *ihead)

The function name leaves me wondering where we put the pages, and
there's no documentation telling me.

> +{
> +	struct page *prev_page;
> +	struct zone *zone;
> +	prev_page = page->ilru.prev_page;
> +	/*
> +	 * A page that has been migrated has all references
> +	 * removed and will be freed. A page that has not been
> +	 * migrated will have kepts its references and be
> +	 * restored.
> +	 */
> +	ilru_list_del(page, prev_lru);
> +	dec_zone_page_state(page, NR_ISOLATED_ANON +
> +			page_is_file_cache(page));
> +
> +	/*
> +	 * Move the new page to the LRU. If migration was not successful
> +	 * then this will free the page.
> +	 */
> +	zone = page_zone(newpage);
> +	spin_lock_irq(&zone->lru_lock);
> +	if (same_lru(page, prev_page)) {
> +		putback_page_to_lru(newpage, prev_page);
> +		spin_unlock_irq(&zone->lru_lock);
> +		/*
> +		 * The newpage replaced LRU position of old page and
> +		 * old one would be freed. So let's adjust prev_page of pages
> +		 * remained in inorder_lru list.
> +		 */
> +		adjust_ilru_prev_page(ihead, page, newpage);
> +		put_page(newpage);
> +	} else {
> +		spin_unlock_irq(&zone->lru_lock);
> +		putback_lru_page(newpage);
> +	}

The same spinlocking frequency issue.

> +	putback_lru_page(page);
> +}
> +
>
> ...
>
> +int migrate_ilru_pages(struct inorder_lru *ihead, new_page_t get_new_page,
> +		unsigned long private, bool offlining, bool sync)
> +{
> +	int retry = 1;
> +	int nr_failed = 0;
> +	int pass = 0;
> +	struct page *page, *page2;
> +	struct inorder_lru *prev;
> +	int swapwrite = current->flags & PF_SWAPWRITE;
> +	int rc;
> +
> +	if (!swapwrite)
> +		current->flags |= PF_SWAPWRITE;
> +
> +	for (pass = 0; pass < 10 && retry; pass++) {

That ten-passes thing was too ugly to live, and now it's breeding.  Argh.

> +		retry = 0;
> +		prev = ihead;
> +		list_for_each_ilru_entry_safe(page, page2, ihead, ilru) {
> +			cond_resched();
> +
> +			rc = unmap_and_move_ilru(get_new_page, private,
> +					page, pass > 2, offlining,
> +					sync, prev, ihead);
> +
> +			switch (rc) {
> +			case -ENOMEM:
> +				goto out;
> +			case -EAGAIN:
> +				retry++;
> +				prev = &page->ilru;
> +				break;
> +			case 0:
> +				break;
> +			default:
> +				/* Permanent failure */
> +				nr_failed++;
> +				break;
> +			}
> +		}
> +	}
> +	rc = 0;
> +out:
> +	if (!swapwrite)
> +		current->flags &= ~PF_SWAPWRITE;
> +
> +	if (rc)
> +		return rc;
> +
> +	return nr_failed + retry;
> +}
> +
>
> ...
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
