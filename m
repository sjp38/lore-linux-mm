Date: Tue, 3 Apr 2007 13:51:54 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: missing madvise functionality
Message-Id: <20070403135154.61e1b5f3.akpm@linux-foundation.org>
In-Reply-To: <4612B645.7030902@redhat.com>
References: <46128051.9000609@redhat.com>
	<p73648dz5oa.fsf@bingen.suse.de>
	<46128CC2.9090809@redhat.com>
	<20070403172841.GB23689@one.firstfloor.org>
	<20070403125903.3e8577f4.akpm@linux-foundation.org>
	<4612B645.7030902@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ulrich Drepper <drepper@redhat.com>
Cc: Andi Kleen <andi@firstfloor.org>, Rik van Riel <riel@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Jakub Jelinek <jakub@redhat.com>, linux-mm@kvack.org, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Tue, 03 Apr 2007 13:17:09 -0700
Ulrich Drepper <drepper@redhat.com> wrote:

> Andrew Morton wrote:
> > Ulrich, could you suggest a little test app which would demonstrate this
> > behaviour?
> 
> It's not really reliably possible to demonstrate this with a small
> program using malloc.  You'd need something like this mysql test case
> which Rik said is not hard to run by yourself.
> 
> If somebody adds a kernel interface I can easily produce a glibc patch
> so that the test can be run in the new environment.
> 
> But it's of course easy enough to simulate the specific problem in a
> micro benchmark.  If you want that let me know.
> 
> 
> > Question:
> > 
> >>   - if an access to a page in the range happens in the future it must
> >>     succeed.  The old page content can be provided or a new, empty page
> >>    can be provided
> > 
> > How important is this "use the old page if it is available" feature?  If we
> > were to simply implement a fast unconditional-free-the-page, so that
> > subsequent accesses always returned a new, zeroed page, do we expect that
> > this will be a 90%-good-enough thing, or will it be significantly
> > inefficient?
> 
> My guess is that the page fault you'd get for every single page is a
> huge part of the problem.  If you don't free the pages and just leave
> them in the process processes which quickly reuse the memory pool will
> experience no noticeable slowdown.  The only difference between not
> freeing the memory and and doing it is that one madvise() syscall.
> 
> If you unconditionally free the page you we have later mprotect() call
> (one mmap_sem lock saved).  But does every page fault then later
> requires the semaphore?  Even if not, the additional kernel entry is a
> killer.

Oh.  I was assuming that we'd want to unmap these pages from pagetables and
mark then super-easily-reclaimable.  So a later touch would incur a minor
fault.

But you think that we should leave them mapped into pagetables so no such
fault occurs.

I guess we can still do that - if we follow the "this is just like clean
swapcache" concept, things should just work.

Leaving the pages mapped into pagetables means that they are considerably
less likely to be reclaimed.

But whatever we do, with the current MM design we need to at least take the
mmap_sem for reading so we can descend the vma tree and locate the
pageframes.  And if that locking is the main problem then none of this is
likely to help.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
