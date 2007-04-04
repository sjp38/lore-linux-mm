Date: Wed, 4 Apr 2007 16:25:24 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: missing madvise functionality
In-Reply-To: <4613BC5D.2070404@redhat.com>
Message-ID: <Pine.LNX.4.64.0704041610320.19450@blonde.wat.veritas.com>
References: <46128051.9000609@redhat.com> <p73648dz5oa.fsf@bingen.suse.de>
 <46128CC2.9090809@redhat.com> <20070403172841.GB23689@one.firstfloor.org>
 <20070403125903.3e8577f4.akpm@linux-foundation.org> <4612B645.7030902@redhat.com>
 <20070403202937.GE355@devserv.devel.redhat.com> <20070403144948.fe8eede6.akpm@linux-foundation.org>
 <20070403160231.33aa862d.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0704040949050.17341@blonde.wat.veritas.com> <4613BC5D.2070404@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jakub Jelinek <jakub@redhat.com>, Ulrich Drepper <drepper@redhat.com>, Andi Kleen <andi@firstfloor.org>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 4 Apr 2007, Rik van Riel wrote:
> Hugh Dickins wrote:
> 
> > (I didn't understand how Rik would achieve his point 5, _no_ lock
> > contention while repeatedly re-marking these pages, but never mind.)
> 
> The CPU marks them accessed&dirty when they are reused.
> 
> The VM only moves the reused pages back to the active list
> on memory pressure.  This means that when the system is
> not under memory pressure, the same page can simply stay
> PG_lazyfree for multiple malloc/free rounds.

Sure, there's no need for repetitious locking at the LRU end of it;
but you said "if the system has lots of free memory, pages can go
through multiple free/malloc cycles while sitting on the dontneed
list, very lazily with no lock contention".  I took that to mean,
with userspace repeatedly madvising on the ranges they fall in,
which will involve mmap_sem and ptl each time - just in order
to check that no LRU movement is required each time.

(Of course, there's also the problem that we don't leave our
systems with lots of free memory: some LRU balancing decisions.)

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
