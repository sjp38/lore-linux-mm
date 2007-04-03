Date: Tue, 3 Apr 2007 12:59:03 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: missing madvise functionality
Message-Id: <20070403125903.3e8577f4.akpm@linux-foundation.org>
In-Reply-To: <20070403172841.GB23689@one.firstfloor.org>
References: <46128051.9000609@redhat.com>
	<p73648dz5oa.fsf@bingen.suse.de>
	<46128CC2.9090809@redhat.com>
	<20070403172841.GB23689@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Ulrich Drepper <drepper@redhat.com>, Rik van Riel <riel@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Jakub Jelinek <jakub@redhat.com>, linux-mm@kvack.org, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Tue, 3 Apr 2007 19:28:41 +0200
Andi Kleen <andi@firstfloor.org> wrote:

> On Tue, Apr 03, 2007 at 10:20:02AM -0700, Ulrich Drepper wrote:
> > Andi Kleen wrote:
> > > Why do you need a lock for that? I don't see any problem with
> > > two threads doing that in parallel. The kernel would
> > > serialize it internally and one would fail, but that shouldn't
> > > be a problem. 
> > 
> > There is no lock at all at userlevel.  I'm talking about locks in the
> > kernel.
> 
> mmap_sem? Your new operation wouldn't solve that neither.

It might, a bit.  Both mmap() and mprotect() currently take mmap_sem() for
writing.  If we're careful, we could probably arrange for MADV_ULRICH to
take it for reading, which will help a little bit, hopefully.

It's a little sad that mprotect() takes mmap_sem for writing, really.  I think
the only reason for doing that is because we might do a vma_merge() as a
result.  Perhaps this is on the wrong side of the speed/space tradeoff.

otoh, converting a down_write() to a down_read() may well not have much
effect.

Ulrich, could you suggest a little test app which would demonstrate this
behaviour?

> There were some proposals to fix mmap_sem (it's a big issue
> for futexes too) but they're are quite involved.

yup.

Question:

>   - if an access to a page in the range happens in the future it must
>     succeed.  The old page content can be provided or a new, empty page
>    can be provided

How important is this "use the old page if it is available" feature?  If we
were to simply implement a fast unconditional-free-the-page, so that
subsequent accesses always returned a new, zeroed page, do we expect that
this will be a 90%-good-enough thing, or will it be significantly
inefficient?


If we do implement this retain-the-old-page-if-possible feature, I'm
thinking that we can possibly reuse swapcache concepts.  Such a page is
very similar to a clean, unmapped swapcache page, only it doesn't actually
have a swap mapping (well, it might have a swap mapping, in which case we
don't need to do anything at all, except deactivate it).

So perhaps we can do something like chop swapper_space in half: the lower
50% represent offsets which have a swap mapping and the upper 50% are fake
swapcache pages which don't actually consume swapspace.  These pages are
unmapped from pagetables, marked clean, added to the fake part of
swapper_space and are deactivated.  Teach the low-level swap code to ignore
the request to free physical swapspace when these pages are released.

Or, if that's all too hacky, create a new address_space for these pages and
burn a new page flag.  But I suspect we'd end up duplicating so much
swapcache handling that this will end up looking silly.

This would all halve the maximum amount of swap which can be used.  iirc
i386 supports 27 bits of swapcache indexing, and 26 bits is 274GB, which
is hopefully enough..

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
