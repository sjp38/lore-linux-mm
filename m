Date: Mon, 29 Oct 2007 20:33:45 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: msync(2) bug(?), returns AOP_WRITEPAGE_ACTIVATE to userland 
In-Reply-To: <200710282023.l9SKNKK0031790@agora.fsl.cs.sunysb.edu>
Message-ID: <Pine.LNX.4.64.0710292027310.21528@blonde.wat.veritas.com>
References: <200710282023.l9SKNKK0031790@agora.fsl.cs.sunysb.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Erez Zadok <ezk@cs.sunysb.edu>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Ryan Finnie <ryan@finnie.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, cjwatson@ubuntu.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 28 Oct 2007, Erez Zadok wrote:
> 
> I took your advise regarding ~(__GFP_FS|__GFP_IO), AOP_WRITEPAGE_ACTIVATE,
> and such.  I revised my unionfs_writepage and unionfs_sync_page, and tested
> it under memory pressure: I have a couple of live CDs that use tmpfs and can
> deterministically reproduce the conditions resulting in A_W_A.  I also went
> back to using grab_cache_page but with the gfp_mask suggestions you made.
> 
> I'm happy to report that it all works great now!

That's very encouraging...

> Below is the entirety of
> the new unionfs_mmap and unionfs_sync_page code.  I'd appreciate if you and
> others can look it over and see if you find any problems.

... but still a few problems, I'm afraid.

The greatest problem is a tmpfs one, that would be for me to solve.
But first...

> static int unionfs_writepage(struct page *page, struct writeback_control *wbc)
> {
> 	int err = -EIO;
> 	struct inode *inode;
> 	struct inode *lower_inode;
> 	struct page *lower_page;
> 	char *kaddr, *lower_kaddr;
> 	struct address_space *mapping; /* lower inode mapping */
> 	gfp_t old_gfp_mask;
> 
> 	inode = page->mapping->host;
> 	lower_inode = unionfs_lower_inode(inode);
> 	mapping = lower_inode->i_mapping;
> 
> 	/*
> 	 * find lower page (returns a locked page)
> 	 *
> 	 * We turn off __GFP_IO|__GFP_FS so as to prevent a deadlock under

On reflection, I think I went too far in asking you to mask off __GFP_IO.
Loop has to do so because it's a block device, down towards the IO layer;
but unionfs is a filesystem, so masking off __GFP_FS is enough to prevent
recursion into the FS layer with danger of deadlock, and leaving __GFP_IO
on gives a better chance of success.

> 	 * memory pressure conditions.  This is similar to how the loop
> 	 * driver behaves (see loop_set_fd in drivers/block/loop.c).
> 	 * If we can't find the lower page, we redirty our page and return
> 	 * "success" so that the VM will call us again in the (hopefully
> 	 * near) future.
> 	 */
> 	old_gfp_mask = mapping_gfp_mask(mapping);
> 	mapping_set_gfp_mask(mapping, old_gfp_mask & ~(__GFP_IO|__GFP_FS));
> 
> 	lower_page = grab_cache_page(mapping, page->index);
> 	mapping_set_gfp_mask(mapping, old_gfp_mask);

Hmm, several points on that.

When suggesting something like this, I did remark "what locking needed?".
You've got none: which is problematic if two stacked mounts are playing
with the same underlying file concurrently (yes, userspace would have
a data coherency problem in such a case, but the kernel still needs to
worry about its own internal integrity) - you'd be in danger of masking
(__GFP_IO|__GFP_FS) permanently off the underlying file; and furthermore,
losing error flags (AS_EIO, AS_ENOSPC) which share the same unsigned long.
Neither likely but both wrong.

See the comment on mapping_set_gfp_mask() in include/pagemap.h:
 * This is non-atomic.  Only to be used before the mapping is activated.
Strictly speaking, I guess loop was a little bit guilty even when just
loop_set_fd() did it: the underlying mapping might already be active.
It appears to be just as guilty as you in its do_loop_switch() case
(done at BIO completion time), but that's for a LOOP_CHANGE_FD ioctl
which would only be expected to be called once, during installation;
whereas you're using mapping_set_gfp_mask here with great frequency.

Another point on this is: loop masks __GFP_IO|__GFP_FS off the file
for the whole duration while it is looped, whereas you're flipping it
just in this preliminary section of unionfs_writepage.  I think you're
probably okay to be doing it only here within ->writepage: I think
loop covered every operation because it's at the block device level,
perhaps both reads and writes needed to serve reclaim at the higher
FS level; and also easier to do it once for all.

Are you wrong to be doing it only around the grab_cache_page,
leaving the lower level ->writepage further down unprotected?
Certainly doing it around the grab_cache_page is likely to be way
more important than around the ->writepage (but rather depends on
filesystem).  And on reflection, I think that the lower filesystem's
writepage should already be using GFP_NOFS to avoid deadlocks in
any of its allocations when wbc->for_reclaim, so you should be
okay just masking off around the grab_cache_page.

(Actually, in the wbc->for_reclaim case, I think you don't really
need to call the lower level writepage at all.  Just set_page_dirty
on the lower page, unlock it and return.  In due course that memory
pressure which has called unionfs_writepage, will come around to the
lower level page and do writepage upon it.  Whether that's a better
strategy or not, I'm do not know.)

There's an attractively simple answer to the mapping_set_gfp_mask
locking problem, if we're confident that it's only needed around
the grab_cache_page.  Look at the declaration of grab_cache_page
in linux/pagemap.h: it immediately extracts the gfp_mask from the
mapping and passes that down to find_or_create_page, which doesn't
use the mapping's gfp_mask at all.

So, stop flipping and use find_or_create_page directly yourself.

> 
> 	if (!lower_page) {
> 		err = 0;
> 		set_page_dirty(page);

You need to unlock_page, don't you?  Or move the "out" label up
before the unlock_page.  There seems to have been confusion about
this even in the current 2.6.23-mm1 unionfs_writepage: the only
case in which a writepage returns with its page still locked is
that AOP_WRITEPAGE_ACTIVATE case we're going to get rid of.

> 		goto out;
> 	}
> 
> 	/* get page address, and encode it */
> 	kaddr = kmap(page);
> 	lower_kaddr = kmap(lower_page);
> 
> 	memcpy(lower_kaddr, kaddr, PAGE_CACHE_SIZE);
> 
> 	kunmap(page);
> 	kunmap(lower_page);

Better to use kmap_atomic.  unionfs_writepage cannot get called
at interrupt time, I see no reason to avoid KM_USER0 and KM_USER1:
therefore simply use copy_highpage(lower_page, page) and let it do
all the kmapping and copying.

If PAGE_CACHE_SIZE ever diverges from PAGE_SIZE (e.g. Christoph
Lameter's variable page_cache_size patches), then yes, this
would need updating to a loop over several pages (or better,
linux/highmem.h should then provide a function to do it).

> 
> 	BUG_ON(!mapping->a_ops->writepage);
> 
> 	/* call lower writepage (expects locked page) */
> 	clear_page_dirty_for_io(lower_page); /* emulate VFS behavior */
> 	err = mapping->a_ops->writepage(lower_page, wbc);
> 
> 	/* b/c grab_cache_page locked it and ->writepage unlocks on success */
> 	if (err)
> 		unlock_page(lower_page);

Another instance of that confusion: lower_page is already unlocked,
on success or failure; it's only the anomalous AOP_WRITEPAGE_ACTIVATE
case that leaves it locked.

> 	/* b/c grab_cache_page increased refcnt */
> 	page_cache_release(lower_page);
> 
> 	if (err < 0) {
> 		ClearPageUptodate(page);

Page needs to be unlocked, whether here or at out.

> 		goto out;
> 	}
> 	/*
> 	 * Lower file systems such as ramfs and tmpfs, may return
> 	 * AOP_WRITEPAGE_ACTIVATE so that the VM won't try to (pointlessly)
> 	 * write the page again for a while.  But those lower file systems
> 	 * also set the page dirty bit back again.  Since we successfully
> 	 * copied our page data to the lower page, then the VM will come
> 	 * back to the lower page (directly) and try to flush it.  So we can
> 	 * save the VM the hassle of coming back to our page and trying to
> 	 * flush too.  Therefore, we don't re-dirty our own page, and we
> 	 * don't return AOP_WRITEPAGE_ACTIVATE back to the VM (we consider
> 	 * this a success).
> 	 */
> 	if (err == AOP_WRITEPAGE_ACTIVATE)
> 		err = 0;

Right (once you've got the locking right).

> 
> 	/* all is well */
> 	SetPageUptodate(page);
> 	/* lower mtimes has changed: update ours */
> 	unionfs_copy_attr_times(inode);
> 
> 	unlock_page(page);
> 
> out:
> 	return err;
> }
> 
> 
> static void unionfs_sync_page(struct page *page)
> {

I'm not going to comment much on your unionfs_sync_page: it looks
like a total misunderstanding of what sync_page does, assuming from
the name that it syncs the page in a fsync/msync/sync manner.

No, it would much better be named "unplug_page_io": please take a
look at sync_page() in mm/filemap.c, observe how it gets called
(via wait_on_page_bit) and what it ends up doing.  (Don't pay much
attention to what Documentation/filesystems says about it, either!)

It's an odd business; I think Nick did have a patch to get rid of
it completely, which would be nice; but changes to unplugging I/O
(kicking off the I/O after saving up several requests to do all
together) can be a hang-prone business.

Do you need a unionfs_sync_page at all?  I think not, since the
I/O, plugged or unplugged, is below your lower level filesystem.

But I started by mentioning a serious tmpfs problem.  Now I've
persuaded you to go back to grab_cache_page/find_or_create_page,
I realize a nasty problem for tmpfs.  Under memory pressure, you're
liable to be putting tmpfs file pages into the page cache at the
same time as they're already present but in disguise as swap cache
pages.  Perhaps the solution will be quite simple (since you're
overwriting the whole page), but I do need to think about it.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
