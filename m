Message-ID: <3D2DE814.5F6F5E08@zip.com.au>
Date: Thu, 11 Jul 2002 13:18:28 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH] small rmap bugfix
References: <Pine.LNX.4.44L.0207111705480.14432-100000@imladris.surriel.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: William Lee Irwin III <wli@holomorphy.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
> 
> Hi,
> 
> I just ran into a bad piece of code in the rmap patch Andrew
> has been testing recently. It's possible for pages that were
> truncated to still have their bufferheads _and_ be mapped in
> the pagetables of processes.
> 
> In that case a piece of code in shrink_cache would remove
> that page from the LRU ... in effect making it unswappable.
> 

Right.  The page leaks until the process exits.  That's a bug
in mainline 2.4.  A small one though.

Seems I deleted all that stuff in pagemap_lru_lock punishment work
I did last week too.  I forget the reasoning ;)

Here's the shrink_cache() guts which I ended up with.


static /* inline */ int
shrink_list(struct list_head *page_list, int nr_pages,
		zone_t *classzone, unsigned int gfp_mask, int priority)
{
	struct address_space *mapping;
	LIST_HEAD(ret_pages);
	struct pagevec freed_pvec;

	pagevec_init(&freed_pvec);

	while (!list_empty(page_list)) {
		struct page *page;
		int may_enter_fs;

		page = list_entry(page_list->prev, struct page, lru);
		list_del(&page->lru);

		BUG_ON(PageLRU(page));

		if (!page_freeable(page, classzone))
			goto keep;

		may_enter_fs = (gfp_mask & __GFP_FS) ||
				(PageSwapCache(page) && (gfp_mask & __GFP_IO));

		if (PageWriteback(page) && may_enter_fs)
			wait_on_page_writeback(page);	/* throttling */

		if (TestSetPageLocked(page))
			goto keep;

		if (PageWriteback(page))		/* non-racy test */
			goto keep_locked;

		mapping = page->mapping;

		if (PageDirty(page) && is_page_cache_freeable(page) &&
				mapping && may_enter_fs) {
			/*
			 * It is not critical here to write it only if
			 * the page is unmapped beause any direct writer
			 * like O_DIRECT would set the page's dirty bitflag
			 * on the phisical page after having successfully
			 * pinned it and after the I/O to the page is finished,
			 * so the direct writes to the page cannot get lost.
			 */
			int (*writeback)(struct page *, int *);
			const int nr_pages = SWAP_CLUSTER_MAX;
			int nr_to_write = nr_pages;

			writeback = mapping->a_ops->vm_writeback;
			if (writeback == NULL)
				writeback = generic_vm_writeback;
			(*writeback)(page, &nr_to_write);
			goto keep;
		}

		/*
		 * If the page has buffers, try to free the buffer mappings
		 * associated with this page. If we succeed we try to free
		 * the page as well.
		 *
		 * We do this even if the page is PageDirty().
		 * try_to_release_page() does not perform I/O, but it is
		 * possible for a page to have PageDirty set, but it is actually
		 * clean (all its buffers are clean).  This happens if the
		 * buffers were written out directly, with submit_bh(). ext3
		 * will do this, as well as the blockdev mapping. 
		 * try_to_release_page() will discover that cleanness and will
		 * drop the buffers and mark the page clean - it can be freed.
		 *
		 * The !mapping case almost never happens. anon pages don't
		 * have buffers.  It is for the pages which were not freed by
		 * truncate_complete_page()'s do_invalidatepage().
		 */
		if (PagePrivate(page)) {
			if (!try_to_release_page(page, 0))
				goto keep_locked;
			if (!mapping)
				goto free_it;
		}

		if (!mapping)
			goto keep_locked;	/* truncate got there first */

		/*
		 * The non-racy check for busy page.  It is critical to check
		 * PageDirty _after_ making sure that the page is freeable and
		 * not in use by anybody.
		 */
		write_lock(&mapping->page_lock);

		if (page_count(page) != 2)	/* pagecache + us == 2 */
			goto keep_mapping_locked;

		if (PageDirty(page))
			goto keep_mapping_locked;

		if (PageSwapCache(page)) {
			swp_entry_t swap = { val: page->index };
			__delete_from_swap_cache(page);
			write_unlock(&mapping->page_lock);
			swap_free(swap);
		} else {
			__remove_inode_page(page);
			write_unlock(&mapping->page_lock);
		}
		page_cache_release(page);	/* The pagecache ref */
free_it:
		unlock_page(page);
		BUG_ON(page_count(page) != 1);
		nr_pages--;
		BUG_ON(!PageShrink(page));
		ClearPageShrink(page);
		if (!pagevec_add(&freed_pvec, page))
			__pagevec_release_nonlru(&freed_pvec);
		continue;

keep_mapping_locked:
		write_unlock(&mapping->page_lock);
keep_locked:
		unlock_page(page);
keep:
		list_add(&page->lru, &ret_pages);
		BUG_ON(PageLRU(page));
	}
	list_splice(&ret_pages, page_list);
	pagevec_release_nonlru(&freed_pvec);
	return nr_pages;
}
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
