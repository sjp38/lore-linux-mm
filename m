In-reply-to: <20070218125307.4103c04a.akpm@linux-foundation.org> (message from
	Andrew Morton on Sun, 18 Feb 2007 12:53:07 -0800)
Subject: Re: dirty balancing deadlock
References: <E1HIqlm-0004iZ-00@dorka.pomaz.szeredi.hu> <20070218125307.4103c04a.akpm@linux-foundation.org>
Message-Id: <E1HIurG-0005Bw-00@dorka.pomaz.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Sun, 18 Feb 2007 23:50:14 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> > I was testing the new fuse shared writable mmap support, and finding
> > that bash-shared-mapping deadlocks (which isn't so strange ;).  What
> > is more strange is that this is not an OOM situation at all, with
> > plenty of free and cached pages.
> > 
> > A little more investigation shows that a similar deadlock happens
> > reliably with bash-shared-mapping on a loopback mount, even if only
> > half the total memory is used.
> > 
> > The cause is slightly different in the two cases:
> > 
> >   - loopback mount: allocation by the underlying filesystem is stalled
> >     on throttle_vm_writeout()
> > 
> >   - fuse-loop: page dirtying on the underlying filesystem is stalled on
> >     balance_dirty_pages()
> > 
> > In both cases the underlying fs is totally innocent, with no
> > dirty/writback pages, yet it's waiting for the global dirty+writeback
> > to go below the threshold, which obviously won't, until the
> > allocation/dirtying succeeds.
> > 
> > I'm not quite sure what the solution is, and asking for thoughts.
> 
> But....  these things don't just throttle.  They also perform large amounts
> of writeback, which causes the dirty levels to subside.
> 
> >From your description it appears that this writeback isn't happening, or
> isn't working.  How come?

 - filesystems A and B
 - write to A will end up as write to B
 - dirty pages in A manage to go over dirty_threshold
 - page writeback is started from A
 - this triggers writeback for a couple of pages in B
 - writeback finishes normally, but dirty+writeback pages are still
   over threshold
 - balance_dirty_pages in B gets stuck, nothing ever moves after this

At least this is my theory for what happens.

Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
