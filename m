Date: Wed, 4 Apr 2007 11:04:06 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: missing madvise functionality
Message-Id: <20070404110406.c79b850d.akpm@linux-foundation.org>
In-Reply-To: <Pine.LNX.4.64.0704040949050.17341@blonde.wat.veritas.com>
References: <46128051.9000609@redhat.com>
	<p73648dz5oa.fsf@bingen.suse.de>
	<46128CC2.9090809@redhat.com>
	<20070403172841.GB23689@one.firstfloor.org>
	<20070403125903.3e8577f4.akpm@linux-foundation.org>
	<4612B645.7030902@redhat.com>
	<20070403202937.GE355@devserv.devel.redhat.com>
	<20070403144948.fe8eede6.akpm@linux-foundation.org>
	<20070403160231.33aa862d.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0704040949050.17341@blonde.wat.veritas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Jakub Jelinek <jakub@redhat.com>, Ulrich Drepper <drepper@redhat.com>, Andi Kleen <andi@firstfloor.org>, Rik van Riel <riel@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 4 Apr 2007 10:15:41 +0100 (BST) Hugh Dickins <hugh@veritas.com> wrote:

> On Tue, 3 Apr 2007, Andrew Morton wrote:
> > 
> > All of which indicates that if we can remove the down_write(mmap_sem) from
> > this glibc operation, things should get a lot better - there will be no
> > additional context switches at all.
> > 
> > And we can surely do that if all we're doing is looking up pageframes,
> > putting pages into fake-swapcache and moving them around on the page LRUs.
> > 
> > Hugh?  Sanity check?
> 
> Setting aside the fake-swapcache part, yes, Rik should be able to do what
> Ulrich wants (operating on ptes and pages) without down_write(mmap_sem):
> just needing down_read(mmap_sem) to keep the whole vma/pagetable structure
> stable, and page table lock (literal or per-page-table) for each contents.
> 
> (I didn't understand how Rik would achieve his point 5, _no_ lock
> contention while repeatedly re-marking these pages, but never mind.)
> 
> (Some mails in this thread overlook that we also use down_write(mmap_sem)
> to guard simple things like vma->vm_flags: of course that in itself could
> be manipulated with atomics, or spinlock; but like many of the vma fields,
> changing it goes hand in hand with the chance that we have to split vma,
> which does require the heavy-handed down_write(mmap_sem).  I expect that
> splitting those uses apart would be harder than first appears, and better
> to go for a more radical redesign - I don't know what.)
> 
> But you lose me with the fake-swapcache part of it: that came, I think,
> from your initial idea that it would be okay to refault on these ptes.
> Don't we all agree now that we'd prefer not to refault on those ptes,
> unless some memory pressure has actually decided to pull them out?
> (Hmm, yet more list balancing...)

The way in which we want to treat these pages is (I believe) to keep them
if there's not a lot of memory pressure, but to reclaim them "easily" if
there is some memory pressure.

A simple way to do that is to move them onto the inactive list.  But how do
we handle these pages when the vm scanner encounters them?

The treatment is identical to clean swapcache pages, with the sole
exception that they don't actually consume any swap space - hence the fake
swapcache entry thing.

There are other ways of doing it - I guess we could use a new page flag to
indicate that this is one-of-those-pages, and add new code to handle it in
all the right places.



One thing which we haven't sorted out with all this stuff: once the
application has marked an address range (and some pages) as
whatever-were-going-call-this-feature, how does the application undo that
change?  What effect will things like mremap, madvise and mlock have upon
these pages?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
