Subject: dirty balancing deadlock
Message-Id: <E1HIqlm-0004iZ-00@dorka.pomaz.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Sun, 18 Feb 2007 19:28:18 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

I was testing the new fuse shared writable mmap support, and finding
that bash-shared-mapping deadlocks (which isn't so strange ;).  What
is more strange is that this is not an OOM situation at all, with
plenty of free and cached pages.

A little more investigation shows that a similar deadlock happens
reliably with bash-shared-mapping on a loopback mount, even if only
half the total memory is used.

The cause is slightly different in the two cases:

  - loopback mount: allocation by the underlying filesystem is stalled
    on throttle_vm_writeout()

  - fuse-loop: page dirtying on the underlying filesystem is stalled on
    balance_dirty_pages()

In both cases the underlying fs is totally innocent, with no
dirty/writback pages, yet it's waiting for the global dirty+writeback
to go below the threshold, which obviously won't, until the
allocation/dirtying succeeds.

I'm not quite sure what the solution is, and asking for thoughts.

Ideas:

  - per filesystem dirty counters.  If filesystem is clean (or dirty
    is below some minimum), then balance_dirty_pages() should no wait
    any more

  - throttle_vm_writeout() was meant to throttle swapping, no?  So in
    that case there should be a separate swap-writback counter

Thanks,
Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
