Date: Wed, 4 Apr 2007 19:39:07 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: missing madvise functionality
In-Reply-To: <20070404110406.c79b850d.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0704041917280.14635@blonde.wat.veritas.com>
References: <46128051.9000609@redhat.com> <p73648dz5oa.fsf@bingen.suse.de>
 <46128CC2.9090809@redhat.com> <20070403172841.GB23689@one.firstfloor.org>
 <20070403125903.3e8577f4.akpm@linux-foundation.org> <4612B645.7030902@redhat.com>
 <20070403202937.GE355@devserv.devel.redhat.com> <20070403144948.fe8eede6.akpm@linux-foundation.org>
 <20070403160231.33aa862d.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0704040949050.17341@blonde.wat.veritas.com>
 <20070404110406.c79b850d.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jakub Jelinek <jakub@redhat.com>, Ulrich Drepper <drepper@redhat.com>, Andi Kleen <andi@firstfloor.org>, Rik van Riel <riel@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 4 Apr 2007, Andrew Morton wrote:
> 
> The treatment is identical to clean swapcache pages, with the sole
> exception that they don't actually consume any swap space - hence the fake
> swapcache entry thing.

I see, sneaking through try_to_unmap's anon PageSwapCache assumptions
as simply as possible - thanks.

(Coincidentally, Andrea pointed to precisely the same issue in the
no PAGE_ZERO thread, when we were toying with writable but clean.)

> One thing which we haven't sorted out with all this stuff: once the
> application has marked an address range (and some pages) as
> whatever-were-going-call-this-feature, how does the application undo
> that change?

By re-referencing the pages.  (Hmm, so an incorrect app which accesses
"free"d areas, will undo it: well, okay, nothing terrible about that.)

> What effect will things like mremap, madvise and mlock have upon
> these pages?

mlock will undo the state in its make_pages_present: I guess that
should happen in or near follow_page's mark_page_accessed.

mremap?  Other madvises?  Nothing much at all: mremap can move
them around, and the madvises do whatever they do - I don't notice
any problem in that direction, but it'll be easier when we have an
implementation to poke at.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
