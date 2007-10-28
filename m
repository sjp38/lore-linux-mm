Date: Sun, 28 Oct 2007 16:23:20 -0400
Message-Id: <200710282023.l9SKNKK0031790@agora.fsl.cs.sunysb.edu>
From: Erez Zadok <ezk@cs.sunysb.edu>
Subject: Re: msync(2) bug(?), returns AOP_WRITEPAGE_ACTIVATE to userland 
In-reply-to: Your message of "Thu, 25 Oct 2007 19:03:14 BST."
             <Pine.LNX.4.64.0710251743190.9834@blonde.wat.veritas.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Erez Zadok <ezk@cs.sunysb.edu>, Pekka Enberg <penberg@cs.helsinki.fi>, Ryan Finnie <ryan@finnie.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, cjwatson@ubuntu.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Huge,

I took your advise regarding ~(__GFP_FS|__GFP_IO), AOP_WRITEPAGE_ACTIVATE,
and such.  I revised my unionfs_writepage and unionfs_sync_page, and tested
it under memory pressure: I have a couple of live CDs that use tmpfs and can
deterministically reproduce the conditions resulting in A_W_A.  I also went
back to using grab_cache_page but with the gfp_mask suggestions you made.

I'm happy to report that it all works great now!  Below is the entirety of
the new unionfs_mmap and unionfs_sync_page code.  I'd appreciate if you and
others can look it over and see if you find any problems.

Thanks,
Erez.


static int unionfs_writepage(struct page *page, struct writeback_control *wbc)
{
	int err = -EIO;
	struct inode *inode;
	struct inode *lower_inode;
	struct page *lower_page;
	char *kaddr, *lower_kaddr;
	struct address_space *mapping; /* lower inode mapping */
	gfp_t old_gfp_mask;

	inode = page->mapping->host;
	lower_inode = unionfs_lower_inode(inode);
	mapping = lower_inode->i_mapping;

	/*
	 * find lower page (returns a locked page)
	 *
	 * We turn off __GFP_IO|__GFP_FS so as to prevent a deadlock under
	 * memory pressure conditions.  This is similar to how the loop
	 * driver behaves (see loop_set_fd in drivers/block/loop.c).
	 * If we can't find the lower page, we redirty our page and return
	 * "success" so that the VM will call us again in the (hopefully
	 * near) future.
	 */
	old_gfp_mask = mapping_gfp_mask(mapping);
	mapping_set_gfp_mask(mapping, old_gfp_mask & ~(__GFP_IO|__GFP_FS));

	lower_page = grab_cache_page(mapping, page->index);
	mapping_set_gfp_mask(mapping, old_gfp_mask);

	if (!lower_page) {
		err = 0;
		set_page_dirty(page);
		goto out;
	}

	/* get page address, and encode it */
	kaddr = kmap(page);
	lower_kaddr = kmap(lower_page);

	memcpy(lower_kaddr, kaddr, PAGE_CACHE_SIZE);

	kunmap(page);
	kunmap(lower_page);

	BUG_ON(!mapping->a_ops->writepage);

	/* call lower writepage (expects locked page) */
	clear_page_dirty_for_io(lower_page); /* emulate VFS behavior */
	err = mapping->a_ops->writepage(lower_page, wbc);

	/* b/c grab_cache_page locked it and ->writepage unlocks on success */
	if (err)
		unlock_page(lower_page);
	/* b/c grab_cache_page increased refcnt */
	page_cache_release(lower_page);

	if (err < 0) {
		ClearPageUptodate(page);
		goto out;
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
	 * don't return AOP_WRITEPAGE_ACTIVATE back to the VM (we consider
	 * this a success).
	 */
	if (err == AOP_WRITEPAGE_ACTIVATE)
		err = 0;

	/* all is well */
	SetPageUptodate(page);
	/* lower mtimes has changed: update ours */
	unionfs_copy_attr_times(inode);

	unlock_page(page);

out:
	return err;
}


static void unionfs_sync_page(struct page *page)
{
	struct inode *inode;
	struct inode *lower_inode;
	struct page *lower_page;
	struct address_space *mapping; /* lower inode mapping */
	gfp_t old_gfp_mask;

	inode = page->mapping->host;
	lower_inode = unionfs_lower_inode(inode);
	mapping = lower_inode->i_mapping;

	/*
	 * Find lower page (returns a locked page).
	 *
	 * We turn off __GFP_IO|__GFP_FS so as to prevent a deadlock under
	 * memory pressure conditions.  This is similar to how the loop
	 * driver behaves (see loop_set_fd in drivers/block/loop.c).
	 * If we can't find the lower page, we redirty our page and return
	 * "success" so that the VM will call us again in the (hopefully
	 * near) future.
	 */
	old_gfp_mask = mapping_gfp_mask(mapping);
	mapping_set_gfp_mask(mapping, old_gfp_mask & ~(__GFP_IO|__GFP_FS));

	lower_page = grab_cache_page(mapping, page->index);
	mapping_set_gfp_mask(mapping, old_gfp_mask);

	if (!lower_page) {
		printk(KERN_ERR "unionfs: grab_cache_page failed\n");
		goto out;
	}

	/* do the actual sync */

	/*
	 * XXX: can we optimize ala RAIF and set the lower page to be
	 * discarded after a successful sync_page?
	 */
	if (mapping && mapping->a_ops && mapping->a_ops->sync_page)
		mapping->a_ops->sync_page(lower_page);

	/* b/c grab_cache_page locked it */
	unlock_page(lower_page);
	/* b/c grab_cache_page increased refcnt */
	page_cache_release(lower_page);

out:
	return;
}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
