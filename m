Date: Fri, 26 Oct 2007 12:26:08 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: msync(2) bug(?), returns AOP_WRITEPAGE_ACTIVATE to userland
In-Reply-To: <18209.19021.383347.160126@notabene.brown>
Message-ID: <Pine.LNX.4.64.0710261124000.19611@blonde.wat.veritas.com>
References: <Pine.LNX.4.64.0710142049000.13119@sbz-30.cs.Helsinki.FI>
 <200710142232.l9EMW8kK029572@agora.fsl.cs.sunysb.edu>
 <84144f020710150447o94b1babo8b6e6a647828465f@mail.gmail.com>
 <Pine.LNX.4.64.0710222101420.23513@blonde.wat.veritas.com>
 <84144f020710221348x297795c0qda61046ec69a7178@mail.gmail.com>
 <Pine.LNX.4.64.0710251556300.1521@blonde.wat.veritas.com>
 <18209.19021.383347.160126@notabene.brown>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Neil Brown <neilb@suse.de>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Erez Zadok <ezk@cs.sunysb.edu>, Ryan Finnie <ryan@finnie.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, cjwatson@ubuntu.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 26 Oct 2007, Neil Brown wrote:
> On Thursday October 25, hugh@veritas.com wrote:
> 
> The patch looks like it makes perfect sense to me.

Great, thanks a lot for looking at it, Neil and Pekka.

> Before the change, ->writepage could return AOP_WRITEPAGE_ACTIVATE
> without unlocking the page, and this has precisely the effect of:
>    ClearPageReclaim();  (if the call path was through pageout)
>    SetPageActive();  (if the call was through shrink_page_list)
>    unlock_page();
> 
> With the patch, the ->writepage method does the SetPageActive and the
> unlock_page, which on the whole seems cleaner.
> 
> We seem to have lost a call to ClearPageReclaim - I don't know if that
> is significant.

It doesn't show up in the diff at all, but pageout() already has
		if (!PageWriteback(page)) {
			/* synchronous write or broken a_ops? */
			ClearPageReclaim(page);
		}
which will clear it since we've never set PageWriteback.

I think no harm would come from leaving it set there, since it only
takes effect in end_page_writeback (its effect being to let the just
written page be moved to the end of the LRU, so that it will then
be soon reclaimed), and clear_page_dirty_for_io clears it before
coming down this way.  But I'd never argue for that: I hate having
leftover flags hanging around outside the scope of their relevance.

> > Special, hidden, undocumented, secret hack!  Then in 2.6.7 Andrew
> > stole his own secret and used it when concocting ramdisk_writepage.
> > Oh, and NFS made some kind of use of it in 2.6.6 only.  Then Neil
> > revealed the secret to the uninitiated in 2.6.17: now, what's the
> > appropriate punishment for that?
> 
> Surely the punishment should be for writing hidden undocumented hacks
> in the first place!  I vote we just make him maintainer for the whole
> kernel - that will keep him so busy that he will never have a chance
> to do it again :-)

That is a splendid retort, which has won you absolution.
But it makes me a little sad: that smiley should be a weepy.

> > --- 2.6.24-rc1/Documentation/filesystems/vfs.txt	2007-10-24 07:15:11.000000000 +0100
> > +++ linux/Documentation/filesystems/vfs.txt	2007-10-24 08:42:07.000000000 +0100
> > @@ -567,9 +567,7 @@ struct address_space_operations {
> >        If wbc->sync_mode is WB_SYNC_NONE, ->writepage doesn't have to
> >        try too hard if there are problems, and may choose to write out
> >        other pages from the mapping if that is easier (e.g. due to
> > -      internal dependencies).  If it chooses not to start writeout, it
> > -      should return AOP_WRITEPAGE_ACTIVATE so that the VM will not keep
> > -      calling ->writepage on that page.
> > +      internal dependencies).
> >  
> 
> It seems that the new requirement is that if the address_space
> chooses not to write out the page, it should now call SetPageActive().
> If that is the case, I think it should be explicit in the
> documentation - please?

No, it's not the case; but you're right that I should add something
there, to put an end to the idea.  It'll be something along the lines
of "You may notice shmem setting PageActive there, but please don't do
that; or if you insist, be sure never to do so in the !wbc->for_reclaim
case".

The PageActive thing is for when a filesystem regrets that it even
had a ->writepage (it replicates the behaviour of the writepage == NULL
case or the VM_LOCKED SWAP_FAIL case or the !add_to_swap case, delaying
the return of this page to writepage for as long as it can).  It's done
in shmem_writepage because shm_lock (equivalent to VM_LOCKED) is only
discovered within that writepage, and no-swap is discovered there too.

ramdisk does it too: I've not tried to understand ramdisk as Nick and
Eric have, but it used to have no writepage, and would prefer to have
no writepage, but appears to need one for some PageUptodate reasons.

It's fairly normal for a filesystem to find that for some reason it
cannot carry out a writepage on this page right now (in the reclaim
case: the sync case demands action, IIRC); so it then simply does
set_page_dirty and unlock_page and returns "success".

I'll try to condense this down for the Doc when finalizing the patch;
which I've still not yet tested properly - thanks for the eyes, but
I can't submit it until I've checked in detail that it really gets
to do what we think it does.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
