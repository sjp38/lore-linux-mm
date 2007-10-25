Date: Thu, 25 Oct 2007 17:40:35 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: msync(2) bug(?), returns AOP_WRITEPAGE_ACTIVATE to userland 
In-Reply-To: <200710222104.l9ML4L1D002031@agora.fsl.cs.sunysb.edu>
Message-ID: <Pine.LNX.4.64.0710251649430.6433@blonde.wat.veritas.com>
References: <200710222104.l9ML4L1D002031@agora.fsl.cs.sunysb.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Erez Zadok <ezk@cs.sunysb.edu>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Ryan Finnie <ryan@finnie.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, cjwatson@ubuntu.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 22 Oct 2007, Erez Zadok wrote:
> In message <Pine.LNX.4.64.0710222101420.23513@blonde.wat.veritas.com>, Hugh Dickins writes:
> > 
> > Only ramdisk and shmem have been returning AOP_WRITEPAGE_ACTIVATE.
> > Both of those set BDI_CAP_NO_WRITEBACK.  ramdisk never returned it
> > if !wbc->for_reclaim.  I contend that shmem shouldn't either: it's
> > a special code to get the LRU rotation right, not useful elsewhere.
> > Though Documentation/filesystems/vfs.txt does imply wider use.
> 
> Yes, based on vfs.txt I figured unionfs should return
> AOP_WRITEPAGE_ACTIVATE.

unionfs_writepage returns it in two different cases: when it can't
find the underlying page; and when the underlying writepage returns
it.  I'd say it's wrong to return it in both cases.

In the first case, you don't really want your page put back to the head
of the active list, you want to come back to try it again quite soon
(I think): so you should just redirty and unlock and pretend success.

ramdisk uses A_W_A because none of its pages will ever become freeable
(and comment points out it'd be better if they weren't even on the
LRUs - I think several people have recently been putting forward
patches to keep such timewasters off the LRUs).

shmem uses A_W_A when there's no swap (left), or when the underlying
shm is marked as locked in memory: in each case, best to move on to
look for other pages to swap out.  (But I'm not quite convincing myself
that the temporarily out-of-swap case is different from yours above.)
It's about fixing some horrid busy loops where vmscan kept going
over the same hopeless pages repeatedly, instead of moving on to
better candidates.  Oh, there's a third case, when move_to_swap_cache
fails: that's rare, and I think I was just too lazy to separate them.

In your second case, I fail to see why the unionfs level should
mimic the lower level: you've successfully copied data and marked
the lower level pages as dirty, vmscan will come back to those in
due course, but it's just a waste of time for it to come back to
the unionfs pages again - isn't it?

> But, now that unionfs has ->writepages which won't
> even call the lower writepage if BDI_CAP_NO_WRITEBACK is on, then perhaps I
> no longer need unionfs_writepage to bother checking for
> AOP_WRITEPAGE_ACTIVATE, or even return it up?

unionfs_writepages handles the sync/msync/fsync leaking of A_W_A to
userspace issue, as does Pekka & Andrew's patch to write_cache_pages,
as does my patch to shmem_writepage.  And I'm contending that
unionfs_writepage should in no case return A_W_A up.

But so long as A_W_A is still defined, unionfs_writepage does
still need to check for it after calling the lower level ->writepage
(because it needs to do the missing unlock_page): unionfs_writepages
prevents unionfs_writepage being called on the normal writeout path,
but it's still getting called by vmscan under memory pressure.

(I'm in the habit of saying "vmscan" rather than naming the functions
in question, because every few months someone restructures that file
and changes their names.  I exaggerate, but it's happened often enough.)

> But, a future file system _could_ return AOP_WRITEPAGE_ACTIVATE w/o setting
> BDI_CAP_NO_WRITEBACK, right?  In that case, unionfs will still need to
> handle AOP_WRITEPAGE_ACTIVATE in ->writepage, right?

For so long as AOP_WRITEPAGE_ACTIVATE exists, unionfs_writepage needs to
check for it coming from the lower level ->writepage, as I said above.

But your/Pekka's unionfs_writepages doesn't need to worry about it
at all, because Andrew/Pekka's write_cache_pages fix prevents it
leaking up in the !reclaim case (as does my shmem_writepage fix):
please remove that AOP_WRITEPAGE_ACTIVATE comment from unionfs_writepages.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
