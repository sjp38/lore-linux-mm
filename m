Date: Thu, 25 Oct 2007 19:03:14 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: msync(2) bug(?), returns AOP_WRITEPAGE_ACTIVATE to userland 
In-Reply-To: <200710222138.l9MLcChn003084@agora.fsl.cs.sunysb.edu>
Message-ID: <Pine.LNX.4.64.0710251743190.9834@blonde.wat.veritas.com>
References: <200710222138.l9MLcChn003084@agora.fsl.cs.sunysb.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Erez Zadok <ezk@cs.sunysb.edu>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Ryan Finnie <ryan@finnie.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, cjwatson@ubuntu.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 22 Oct 2007, Erez Zadok wrote:
> 
> What's the precise semantics of AOP_WRITEPAGE_ACTIVATE?

Sigh - not at you, at it!  It's a secret that couldn't be kept secret,
a hack for tmpfs reclaim, let's just look forward to it going away.

> Is it considered an error or not?

No, it's definitely not an error.  It'a a private note from tmpfs
(or ramdisk) to vmscan, saying "don't waste your time coming back
to me with this page until you have to, please move on to another
more likely to be freeable".

> If it's an error, then I usually feel that it's important for
> a stacked f/s to return that error indication upwards.

Indeed, but this is not an error.  Remember, neither ramdisk nor
tmpfs is stable storage: okay, tmpfs can go out to disk by using
swap, but that's not stable storage - it's not reconstituted after
reboot.  (If there's an error in writing to swap, well, that's a
different issue; and there's few filesystems where such an I/O
error would be reported from ->writepage.)

> 
> The unionfs page and the lower page are somewhat tied together, at least
> logically.  For unionfs's page to be considered to have been written
> successfully, the lower page has to be written successfully.  So again, if
> the lower f/s returns AOP_WRITEPAGE_ACTIVATE, should I consider my unionfs
> page to have been written successfully or not?

Consider it written successfully.  (What does written mean with tmpfs?
it means a page can be freed, it doesn't mean the data is forever safe.)

> If I don't return
> AOP_WRITEPAGE_ACTIVATE up, can there be any chance that some vital data may
> never get flushed out?

Things should work better if you don't return AOP_WRITEPAGE_ACTIVATE.
If you mark your page as clean and successfully written, vmscan will
be able to free it.  If needed, we can get the data back from the
lower page on demand, but meanwhile a page has been freed, which
is what vmscan reclaim is all about.  (But of course, in the case
where you couldn't get hold of a page for the lower, you must redirty
yours before returning.)

> > unionfs_writepage also sets AOP_WRITEPAGE_ACTIVATE when it cannot
> > find_lock_page: that case may be appropriate.  Though I don't really
> > understand it: seems dangerous to be relying upon the lower level page
> > just happening to be there already.  Isn't memory pressure then likely
> > to clog up with lots of upper level dirty pages which cannot get
> > written out to the lower level?
> 
> Based on vfs.txt (which perhaps should be revised :-), I was trying to do
> the best I can to ensure that no data is lost if the current page cannot be
> written out to the lower f/s.
> 
> I used to do grab_cache_page() before, but that caused problems: writepage
> is not the right place to _increase_ memory pressure by allocating a new
> page...

Yes, but just hoping the lower page will be there, and doing nothing
to encourage it to become there, sounds an even poorer strategy to me.

It's not easy, I know.  Your position reminds me of the loop driver
(drivers/block/loop.c), which has long handled this situation (with
great success, though I doubt an absolute guarantee) by taking
__GFP_IO|__GFP_FS off the mapping_gfp_mask of the underlying file:
look for gfp_mask in loop_set_fd() (and I think ignore do_loop_switch(),
that's new to me and seems to be for a very special case).

I grepped for gfp in unionfs, and there seems to be nothing: I doubt
you can be robust under memory pressure without doing something about
that.  If you can take __GFP_IO|__GFP_FS off the lower mapping (just
while in unionfs_writepage, or longer term? what locking needed?),
then you should be able to go back to using grab_cache_page().

> 
> One solution I thought of is do what ecryptfs does: keep an open struct file
> in my inode and call vfs_write(), but I don't see that as a significantly
> cleaner/better solution.

I agree with you.

> (BTW, ecrypfts kinda had to go for vfs_write b/c
> it changes the data size and content of what it writes below; unionfs is
> simpler in that manner b/c it needs to write the same data to the lower file
> at the same offset.)

Ah, yes.

> 
> Another idea we've experimented with before is "page pointer flipping."  In
> writepage, we temporarily set the page->mapping->host to the lower_inode;
> then we call the lower writepage with OUR page; then fix back the
> page->mapping->host to the upper inode.  This had two benefits: first we can
> guarantee that we always have a page to write below, and second we don't
> need to keep both upper and lower pages (reduces memory pressure).  Before
> we did this page pointer flipping, we verified that the page is locked so no
> other user could be written the page->mapping->host in this transient state,
> and we ensured that no lower f/s was somehow caching the temporarily changed
> value of page->mapping->host for later use.  But, mucking with the pointers
> in this manner is kinda ugly, to say the least.  Still, I'd love to find a
> clean and simple way that two layers can share the same struct page and
> cleanly pass the upper page to a lower f/s.

I wouldn't call it ugly, but it is exceptional and dangerous and cannot
be sanctioned without a great deal of thought; would very probably need
subtle or wide changes in core vfs/mm.  shmem/tmpfs has given enough
trouble in the past with the way it switches page between filecache
and swapcache, and that imposes interesting limitations.  We'd need
strong reasons (not for unionfs alone) to go down your page pointer
flipping route, but I wouldn't say it's forever out of the question.

My guess is it shouldn't flip, but page->mapping indicate a list of
of different struct address_spaces.

The coherency benefit seems very appealing.

But more thought might prove it a nonsense.

> 
> If you've got suggestions how I can handle unionfs_write more cleanly, or
> comments on the above possibilities, I'd love to hear them.

For now I think you should pursue the ~(__GFP_FS|__GFP_IO) idea somehow.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
