Date: Mon, 22 Oct 2007 17:04:21 -0400
Message-Id: <200710222104.l9ML4L1D002031@agora.fsl.cs.sunysb.edu>
From: Erez Zadok <ezk@cs.sunysb.edu>
Subject: Re: msync(2) bug(?), returns AOP_WRITEPAGE_ACTIVATE to userland 
In-reply-to: Your message of "Mon, 22 Oct 2007 21:16:17 BST."
             <Pine.LNX.4.64.0710222101420.23513@blonde.wat.veritas.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Erez Zadok <ezk@cs.sunysb.edu>, Ryan Finnie <ryan@finnie.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, cjwatson@ubuntu.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

In message <Pine.LNX.4.64.0710222101420.23513@blonde.wat.veritas.com>, Hugh Dickins writes:
> On Mon, 15 Oct 2007, Pekka Enberg wrote:
> > 
> > I wonder whether _not setting_ BDI_CAP_NO_WRITEBACK implies that
> > ->writepage() will never return AOP_WRITEPAGE_ACTIVATE for
> > !wbc->for_reclaim case which would explain why we haven't hit this bug
> > before. Hugh, Andrew?
> 
> Only ramdisk and shmem have been returning AOP_WRITEPAGE_ACTIVATE.
> Both of those set BDI_CAP_NO_WRITEBACK.  ramdisk never returned it
> if !wbc->for_reclaim.  I contend that shmem shouldn't either: it's
> a special code to get the LRU rotation right, not useful elsewhere.
> Though Documentation/filesystems/vfs.txt does imply wider use.

Yes, based on vfs.txt I figured unionfs should return
AOP_WRITEPAGE_ACTIVATE.  But, now that unionfs has ->writepages which won't
even call the lower writepage if BDI_CAP_NO_WRITEBACK is on, then perhaps I
no longer need unionfs_writepage to bother checking for
AOP_WRITEPAGE_ACTIVATE, or even return it up?

But, a future file system _could_ return AOP_WRITEPAGE_ACTIVATE w/o setting
BDI_CAP_NO_WRITEBACK, right?  In that case, unionfs will still need to
handle AOP_WRITEPAGE_ACTIVATE in ->writepage, right?

> I think this is where people use the phrase "go figure" ;)
> 
> Hugh

Erez.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
