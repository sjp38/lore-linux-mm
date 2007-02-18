Date: Sun, 18 Feb 2007 14:59:29 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: dirty balancing deadlock
Message-Id: <20070218145929.547c21c7.akpm@linux-foundation.org>
In-Reply-To: <E1HIurG-0005Bw-00@dorka.pomaz.szeredi.hu>
References: <E1HIqlm-0004iZ-00@dorka.pomaz.szeredi.hu>
	<20070218125307.4103c04a.akpm@linux-foundation.org>
	<E1HIurG-0005Bw-00@dorka.pomaz.szeredi.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 18 Feb 2007 23:50:14 +0100 Miklos Szeredi <miklos@szeredi.hu> wrote:

> > > I was testing the new fuse shared writable mmap support, and finding
> > > that bash-shared-mapping deadlocks (which isn't so strange ;).  What
> > > is more strange is that this is not an OOM situation at all, with
> > > plenty of free and cached pages.
> > > 
> > > A little more investigation shows that a similar deadlock happens
> > > reliably with bash-shared-mapping on a loopback mount, even if only
> > > half the total memory is used.
> > > 
> > > The cause is slightly different in the two cases:
> > > 
> > >   - loopback mount: allocation by the underlying filesystem is stalled
> > >     on throttle_vm_writeout()
> > > 
> > >   - fuse-loop: page dirtying on the underlying filesystem is stalled on
> > >     balance_dirty_pages()
> > > 
> > > In both cases the underlying fs is totally innocent, with no
> > > dirty/writback pages, yet it's waiting for the global dirty+writeback
> > > to go below the threshold, which obviously won't, until the
> > > allocation/dirtying succeeds.
> > > 
> > > I'm not quite sure what the solution is, and asking for thoughts.
> > 
> > But....  these things don't just throttle.  They also perform large amounts
> > of writeback, which causes the dirty levels to subside.
> > 
> > >From your description it appears that this writeback isn't happening, or
> > isn't working.  How come?
> 
>  - filesystems A and B
>  - write to A will end up as write to B
>  - dirty pages in A manage to go over dirty_threshold
>  - page writeback is started from A
>  - this triggers writeback for a couple of pages in B
>  - writeback finishes normally, but dirty+writeback pages are still
>    over threshold
>  - balance_dirty_pages in B gets stuck, nothing ever moves after this
> 
> At least this is my theory for what happens.
> 

Is B a real filesystem?  If so, writes to B will decrease the dirty memory
threshold.

The writeout code _should_ just sit there transferring dirtyiness from A to
B and cleaning pages via B, looping around, alternating between both.

What does sysrq-t say?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
