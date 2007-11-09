Date: Fri, 9 Nov 2007 01:05:11 -0500
Message-Id: <200711090605.lA965B1S024066@agora.fsl.cs.sunysb.edu>
From: Erez Zadok <ezk@cs.sunysb.edu>
Subject: Re: msync(2) bug(?), returns AOP_WRITEPAGE_ACTIVATE to userland 
In-reply-to: Your message of "Mon, 05 Nov 2007 15:40:51 GMT."
             <Pine.LNX.4.64.0711051358440.7629@blonde.wat.veritas.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Erez Zadok <ezk@cs.sunysb.edu>, Dave Hansen <haveblue@us.ibm.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Ryan Finnie <ryan@finnie.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, cjwatson@ubuntu.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

In message <Pine.LNX.4.64.0711051358440.7629@blonde.wat.veritas.com>, Hugh Dickins writes:
> [Dave, I've Cc'ed you re handle_write_count_underflow, see below.]
> 
> On Wed, 31 Oct 2007, Erez Zadok wrote:
> > 
> > Hi Hugh, I've addressed all of your concerns and am happy to report that the
> > newly revised unionfs_writepage works even better, including under my
> > memory-pressure conditions.  To summarize my changes since the last time:
> > 
> > - I'm only masking __GFP_FS, not __GFP_IO
> > - using find_or_create_page to avoid locking issues around mapping mask
> > - handle for_reclaim case more efficiently
> > - using copy_highpage so we handle KM_USER*
> > - un/locking upper/lower page as/when needed
> > - updated comments to clarify what/why
> > - unionfs_sync_page: gone (yes, vfs.txt did confuse me, plus ecryptfs used
> >   to have it)
> > 
> > Below is the newest version of unionfs_writepage.  Let me know what you
> > think.
> > 
> > I have to say that with these changes, unionfs appears visibly faster under
> > memory pressure.  I suspect the for_reclaim handling is probably the largest
> > contributor to this speedup.
> 
> That's good news, and that unionfs_writepage looks good to me -
> with three reservations I've not observed before.
> 
> One, I think you would be safer to do a set_page_dirty(lower_page)
> before your clear_page_dirty_for_io(lower_page).  I know that sounds
> silly, but see Linus' "Yes, Virginia" comment in clear_page_dirty_for_io:
> there's a lot of subtlety hereabouts, and I think you'd be mimicing the
> usual path closer if you set_page_dirty first - there's nothing else
> doing it on that lower_page, is there?  I'm not certain that you need
> to, but I think you'd do well to look into it and make up your own mind.

Hugh, my code looks like:

	if (wbc->for_reclaim) {
		set_page_dirty(lower_page);
		unlock_page(lower_page);
		goto out_release;
	}
	BUG_ON(!lower_mapping->a_ops->writepage);
	clear_page_dirty_for_io(lower_page); /* emulate VFS behavior */
	err = lower_mapping->a_ops->writepage(lower_page, wbc);

Do you mean I should set_page_dirty(lower_page) unconditionally before
clear_page_dirty_for_io?  (I already do that in the 'if' statement above it.)

> Two, I'm unsure of the way you're clearing or setting PageUptodate on
> the upper page there.  The rules for PageUptodate are fairly obvious
> when reading, but when a write fails, it's not so obvious.  Again, I'm
> not saying what you've got is wrong (it may be unavoidable, to keep
> synch between lower and upper), but it deserves a second thought.

I looked at all mainline filesystems's ->writepage to see what, if any, they
do with their page's uptodate flag.  Most f/s don't touch the flag one way
or another.

cifs_writepage sets the uptodate flag unconditionally: why?

ecryptfs_writepage has a legit reason: if encrypting the page failed, it doesn't want
anyone to use it, so it clears its page's uptodate flag (else it sets it as
uptodate).

hostfs_writepage clears pageuptodate if it failed to write_file(), which I'm
not sure if it makes sense or not.

ntfs_writepage goes as far as doing BUG_ON(!PageUptodate(page)) which
indicates to me that the page passed to ->writepage should always be
uptodate.  Is that a fair statement?

smb_writepage pretty much unconditionally calls SetPageUptodate(page).  Why?

Is there a reason smbfs and cifs both do this unconditionally?  If so, then
why is ntfs calling BUG_ON if the page isn't uptodate?  Either that BUG_ON
in ntfs is redundant, or cifs/smbfs's SetPageUptodate is redundant, but they
can't both be right.

And finally, unionfs clears the uptodate flag on error from the lower
->writepage, and otherwise sets the flag on success from the lower
->writepage.  My gut feeling is that unionfs shouldn't change the page
uptodate flag at all: if the VFS passes unionfs_writepage a page which isn't
uptodate, then the VFS has a serious problem b/c it'd be asking a f/s to
write out a page which isn't up-to-date, right?  Otherwise, whether
unionfs_writepage manages to write the lower page or not, why should that
invalidate the state of the unionfs page itself?  Come to think of it, I
think clearing pageuptodate on error from ->writepage(lower_page) may be
bad.  Imagine if after such a failed unionfs_writepage, I get a
unionfs_readpage: that ->readpage will get data from the lower f/s page and
copy it *over* the unionfs page, even if the upper page's data was more
recent prior to the failed call to unionfs_writepage.  IOW, we could be
reverting a user-visible mmap'ed page to a previous on-disk version.  What
do you think: could this happen?  Anyway, I'll run some exhaustive testing
next and see what happens if I don't set/clear the uptodate flag in
unionfs_writepage.

> Three, I believe you need to add a flush_dcache_page(lower_page)
> after the copy_highpage(lower_page): some architectures will need
> that to see the new data if they have lower_page mapped (though I
> expect it's anyway shaky ground to be accessing through the lower
> mount at the same time as modifying through the upper).

OK.

> For now I'm doing repeated make -j20 kernel builds, pushing into
> swap, in a unionfs mount of just a single dir on tmpfs.  This has
> shown up several problems, two of which I've had to hack around to
> get further.
[...]

Thanks.  I'll look more closely into these issues and your patches, and post
my findings.

Erez.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
