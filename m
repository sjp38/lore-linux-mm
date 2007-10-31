Date: Wed, 31 Oct 2007 19:53:06 -0400
Message-Id: <200710312353.l9VNr67n013016@agora.fsl.cs.sunysb.edu>
From: Erez Zadok <ezk@cs.sunysb.edu>
Subject: Re: msync(2) bug(?), returns AOP_WRITEPAGE_ACTIVATE to userland 
In-reply-to: Your message of "Mon, 29 Oct 2007 20:33:45 -0000."
             <Pine.LNX.4.64.0710292027310.21528@blonde.wat.veritas.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Erez Zadok <ezk@cs.sunysb.edu>, Pekka Enberg <penberg@cs.helsinki.fi>, Ryan Finnie <ryan@finnie.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, cjwatson@ubuntu.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Hugh, I've addressed all of your concerns and am happy to report that the
newly revised unionfs_writepage works even better, including under my
memory-pressure conditions.  To summarize my changes since the last time:

- I'm only masking __GFP_FS, not __GFP_IO
- using find_or_create_page to avoid locking issues around mapping mask
- handle for_reclaim case more efficiently
- using copy_highpage so we handle KM_USER*
- un/locking upper/lower page as/when needed
- updated comments to clarify what/why
- unionfs_sync_page: gone (yes, vfs.txt did confuse me, plus ecryptfs used
  to have it)

Below is the newest version of unionfs_writepage.  Let me know what you
think.

I have to say that with these changes, unionfs appears visibly faster under
memory pressure.  I suspect the for_reclaim handling is probably the largest
contributor to this speedup.

Many thanks,
Erez.

//////////////////////////////////////////////////////////////////////////////

static int unionfs_writepage(struct page *page, struct writeback_control *wbc)
{
	int err = -EIO;
	struct inode *inode;
	struct inode *lower_inode;
	struct page *lower_page;
	struct address_space *lower_mapping; /* lower inode mapping */
	gfp_t mask;

	inode = page->mapping->host;
	lower_inode = unionfs_lower_inode(inode);
	lower_mapping = lower_inode->i_mapping;

	/*
	 * find lower page (returns a locked page)
	 *
	 * We turn off __GFP_FS while we look for or create a new lower
	 * page.  This prevents a recursion into the file system code, which
	 * under memory pressure conditions could lead to a deadlock.  This
	 * is similar to how the loop driver behaves (see loop_set_fd in
	 * drivers/block/loop.c).  If we can't find the lower page, we
	 * redirty our page and return "success" so that the VM will call us
	 * again in the (hopefully near) future.
	 */
	mask = mapping_gfp_mask(lower_mapping) & ~(__GFP_FS);
	lower_page = find_or_create_page(lower_mapping, page->index, mask);
	if (!lower_page) {
		err = 0;
		set_page_dirty(page);
		goto out;
	}

	/* copy page data from our upper page to the lower page */
	copy_highpage(lower_page, page);

	/*
	 * Call lower writepage (expects locked page).  However, if we are
	 * called with wbc->for_reclaim, then the VFS/VM just wants to
	 * reclaim our page.  Therefore, we don't need to call the lower
	 * ->writepage: just copy our data to the lower page (already done
	 * above), then mark the lower page dirty and unlock it, and return
	 * success.
	 */
	if (wbc->for_reclaim) {
		set_page_dirty(lower_page);
		unlock_page(lower_page);
		goto out_release;
	}
	BUG_ON(!lower_mapping->a_ops->writepage);
	clear_page_dirty_for_io(lower_page); /* emulate VFS behavior */
	err = lower_mapping->a_ops->writepage(lower_page, wbc);
	if (err < 0) {
		ClearPageUptodate(page);
		goto out_release;
	}

	/*
	 * Lower file systems such as ramfs and tmpfs, may return
	 * AOP_WRITEPAGE_ACTIVATE so that the VM won't try to (pointlessly)
	 * write the page again for a while.  But those lower file systems
	 * also set the page dirty bit back again.  Since we successfully
	 * copied our page data to the lower page, then the VM will come
	 * back to the lower page (directly) and try to flush it.  So we can
	 * save the VM the hassle of coming back to our page and trying to
	 * flush too.  Therefore, we don't re-dirty our own page, and we
	 * never return AOP_WRITEPAGE_ACTIVATE back to the VM (we consider
	 * this a success).
	 *
	 * We also unlock the lower page if the lower ->writepage returned
	 * AOP_WRITEPAGE_ACTIVATE.  (This "anomalous" behaviour may be
	 * addressed in future shmem/VM code.)
	 */
	if (err == AOP_WRITEPAGE_ACTIVATE) {
		err = 0;
		unlock_page(lower_page);
	}

	/* all is well */
	SetPageUptodate(page);
	/* lower mtimes have changed: update ours */
	unionfs_copy_attr_times(inode);

out_release:
	/* b/c find_or_create_page increased refcnt */
	page_cache_release(lower_page);
out:
	/*
	 * We unlock our page unconditionally, because we never return
	 * AOP_WRITEPAGE_ACTIVATE.
	 */
	unlock_page(page);
	return err;
}

//////////////////////////////////////////////////////////////////////////////

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
