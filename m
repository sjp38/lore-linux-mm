Date: Sun, 14 Oct 2007 18:32:08 -0400
Message-Id: <200710142232.l9EMW8kK029572@agora.fsl.cs.sunysb.edu>
From: Erez Zadok <ezk@cs.sunysb.edu>
Subject: Re: msync(2) bug(?), returns AOP_WRITEPAGE_ACTIVATE to userland 
In-reply-to: Your message of "Sun, 14 Oct 2007 20:50:59 +0300."
             <Pine.LNX.4.64.0710142049000.13119@sbz-30.cs.Helsinki.FI>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka J Enberg <penberg@cs.helsinki.fi>
Cc: Erez Zadok <ezk@cs.sunysb.edu>, Hugh Dickins <hugh@veritas.com>, Ryan Finnie <ryan@finnie.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, cjwatson@ubuntu.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

In message <Pine.LNX.4.64.0710142049000.13119@sbz-30.cs.Helsinki.FI>, Pekka J Enberg writes:
> Hi Erez,
> 
> On Sun, 14 Oct 2007, Erez Zadok wrote:
> > In unionfs_writepage() I tried to emulate as best possible what the lower
> > f/s will have returned to the VFS.  Since tmpfs's ->writepage can return
> > AOP_WRITEPAGE_ACTIVATE and re-mark its page as dirty, I did the same in
> > unionfs: mark again my page as dirty, and return AOP_WRITEPAGE_ACTIVATE.
> > 
> > Should I be doing something different when unionfs stacks on top of tmpfs?
> > (BTW, this is probably also relevant to ecryptfs.)
> 
> Look at mm/filemap.c:__filemap_fdatawrite_range(). You shouldn't be 
> calling unionfs_writepage() _at all_ if the lower mapping has 
> BDI_CAP_NO_WRITEBACK capability set. Perhaps something like the totally 
> untested patch below?
> 
> 				Pekka
[...]

Pekka, with a small change to your patch (to handle time-based cache
coherency), your patch worked well and passed all my tests.  Thanks.

So now I wonder if we still need the patch to prevent AOP_WRITEPAGE_ACTIVATE
from being returned to userland.  I guess we still need it, b/c even with
your patch, generic_writepages() can return AOP_WRITEPAGE_ACTIVATE back to
the VFS and we need to ensure that doesn't "leak" outside the kernel.

Erez.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
