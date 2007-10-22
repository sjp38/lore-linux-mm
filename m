Date: Mon, 22 Oct 2007 17:38:12 -0400
Message-Id: <200710222138.l9MLcChn003084@agora.fsl.cs.sunysb.edu>
From: Erez Zadok <ezk@cs.sunysb.edu>
Subject: Re: msync(2) bug(?), returns AOP_WRITEPAGE_ACTIVATE to userland 
In-reply-to: Your message of "Mon, 22 Oct 2007 20:42:20 BST."
             <Pine.LNX.4.64.0710222019020.23513@blonde.wat.veritas.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Erez Zadok <ezk@cs.sunysb.edu>, Pekka Enberg <penberg@cs.helsinki.fi>, Ryan Finnie <ryan@finnie.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, cjwatson@ubuntu.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

In message <Pine.LNX.4.64.0710222019020.23513@blonde.wat.veritas.com>, Hugh Dickins writes:
> Sorry for my delay, here are a few replies.
> 

> > In unionfs_writepage() I tried to emulate as best possible what the lower
> > f/s will have returned to the VFS.  Since tmpfs's ->writepage can return
> > AOP_WRITEPAGE_ACTIVATE and re-mark its page as dirty, I did the same in
> > unionfs: mark again my page as dirty, and return AOP_WRITEPAGE_ACTIVATE.
> 
> I think that's inappropriate.  Why should unionfs_writepage re-mark its
> page as dirty when the lower level does so?  Unionfs has successfully
> done its write to the lower level, what the lower level then gets up to
> (writing then or not) is its own business: needn't be propagated upwards.

What's the precise semantics of AOP_WRITEPAGE_ACTIVATE?  Is it considered an
error or not?  If it's an error, then I usually feel that it's important for
a stacked f/s to return that error indication upwards.

The unionfs page and the lower page are somewhat tied together, at least
logically.  For unionfs's page to be considered to have been written
successfully, the lower page has to be written successfully.  So again, if
the lower f/s returns AOP_WRITEPAGE_ACTIVATE, should I consider my unionfs
page to have been written successfully or not?  If I don't return
AOP_WRITEPAGE_ACTIVATE up, can there be any chance that some vital data may
never get flushed out?

Anyway, now that unionfs has ->writepages that won't bother calling ->write
for file systems with BDI_CAP_NO_WRITEBACK, the issue of
AOP_WRITEPAGE_ACTIVATE in ->writepage may be less important.

> unionfs_writepage also sets AOP_WRITEPAGE_ACTIVATE when it cannot
> find_lock_page: that case may be appropriate.  Though I don't really
> understand it: seems dangerous to be relying upon the lower level page
> just happening to be there already.  Isn't memory pressure then likely
> to clog up with lots of upper level dirty pages which cannot get
> written out to the lower level?

Based on vfs.txt (which perhaps should be revised :-), I was trying to do
the best I can to ensure that no data is lost if the current page cannot be
written out to the lower f/s.

I used to do grab_cache_page() before, but that caused problems: writepage
is not the right place to _increase_ memory pressure by allocating a new
page...

One solution I thought of is do what ecryptfs does: keep an open struct file
in my inode and call vfs_write(), but I don't see that as a significantly
cleaner/better solution.  (BTW, ecrypfts kinda had to go for vfs_write b/c
it changes the data size and content of what it writes below; unionfs is
simpler in that manner b/c it needs to write the same data to the lower file
at the same offset.)

Another idea we've experimented with before is "page pointer flipping."  In
writepage, we temporarily set the page->mapping->host to the lower_inode;
then we call the lower writepage with OUR page; then fix back the
page->mapping->host to the upper inode.  This had two benefits: first we can
guarantee that we always have a page to write below, and second we don't
need to keep both upper and lower pages (reduces memory pressure).  Before
we did this page pointer flipping, we verified that the page is locked so no
other user could be written the page->mapping->host in this transient state,
and we ensured that no lower f/s was somehow caching the temporarily changed
value of page->mapping->host for later use.  But, mucking with the pointers
in this manner is kinda ugly, to say the least.  Still, I'd love to find a
clean and simple way that two layers can share the same struct page and
cleanly pass the upper page to a lower f/s.

If you've got suggestions how I can handle unionfs_write more cleanly, or
comments on the above possibilities, I'd love to hear them.

> > Should I be doing something different when unionfs stacks on top of tmpfs?
> 
> I think not.
> 
> > (BTW, this is probably also relevant to ecryptfs.)
> 
> You're both agreed on that, but I don't see how: ecryptfs writes the
> lower level via vfs_write, it's not using the lower level's writepage,
> is it?

Yup.  ecryptfs no longer does that: it recently changed things and now it
stores and open struct file in its inode, so it can always pass the file to
vfs_write.  This nicely avoids calling the lower writepage, but one has to
keep an open file for every inode.  Neither the solutions employed currently
by unionfs and ecryptfs seem really satisfactory (clean and efficient).

> Hugh

Thanks,
Erez.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
