Date: Sun, 4 Feb 2007 03:10:39 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 9/9] mm: fix pagecache write deadlocks
Message-Id: <20070204031039.46b56dbb.akpm@linux-foundation.org>
In-Reply-To: <Pine.LNX.4.64.0702041036420.24838@hermes-1.csi.cam.ac.uk>
References: <20070204063707.23659.20741.sendpatchset@linux.site>
	<20070204063833.23659.55105.sendpatchset@linux.site>
	<20070204014445.88e6c8c7.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0702041036420.24838@hermes-1.csi.cam.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Anton Altaparmakov <aia21@cam.ac.uk>
Cc: Nick Piggin <npiggin@suse.de>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux Filesystems <linux-fsdevel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sun, 4 Feb 2007 10:59:58 +0000 (GMT) Anton Altaparmakov <aia21@cam.ac.uk> wrote:

> On Sun, 4 Feb 2007, Andrew Morton wrote:
> > On Sun,  4 Feb 2007 09:51:07 +0100 (CET) Nick Piggin <npiggin@suse.de> wrote:
> > > 2.  If we find the destination page is non uptodate, unlock it (this could be
> > >     made slightly more optimal), then find and pin the source page with
> > >     get_user_pages. Relock the destination page and continue with the copy.
> > >     However, instead of a usercopy (which might take a fault), copy the data
> > >     via the kernel address space.
> > 
> > argh.  We just can't go adding all this gunk into the write() path. 
> > 
> > mmap_sem, a full pte-walk, taking of pte-page locks, etc.  For every page. 
> > Even single-process write() will suffer, let along multithreaded stuff,
> > where mmap_sem contention may be the bigger problem.
> > 
> > I was going to do some quick measurements of this, but the code oopses
> > on power4 (http://userweb.kernel.org/~akpm/s5000402.jpg)
> > 
> > We need to think different.
> 
> How about leaving the existing code with the following minor 
> modifications:
> 
> Instead of calling filemap_copy_from_user{,_iovec}() do only the atomic 
> bit with pagefaults disabled, i.e. instead of filemap_copy_from_user() we 
> would do (could of course move into a helper function of course):
> 
> pagefault_disable()
> kaddr = kmap_atomic(page, KM_USER0);
> left = __copy_from_user_inatomic_nocache(kaddr + offset, buf, bytes);
> kunmap_atomic(kaddr, KM_USER0);
> pagefault_enable()
> 
> if (unlikely(left)) {
> 	/* The user space page got unmapped before we got to copy it. */
> 	...
> }
> 
> Thus the 99.999% (or more!) of the time the code would just work as it 
> always has and there is no bug and no speed impact.  Only in the very rare 
> and hard to trigger race condition that the user space page after being 
> faulted in got thrown out again before we did the atomic memory copy do we 
> run into the above "..." code path.

Right.  And what I wanted to do here is to zero out the uncopied part of
the page (if it wasn't uptodate), then run commit_write(), then retry the
whole thing.

iirc, we ruled that out because those temporary zeroes are exposed to
userspace.  But the kernel used to do that anyway for a long time (years)
until someone noticed, and we'll only do it in your 0.0001% case anyway.

(Actually, perhaps we can prevent it by not marking the page uptodate in
this case.  But that'll cause a read()er to try to bring it uptodate...)

> I would propose to call out a different function altogether which could do 
> a multitude of things including drop the lock on the destination page 
> (maintaining a reference on the page!), allocate a temporary page, copy 
> from the user space page into the temporary page, then lock the 
> destination page again, and copy from the temporary page into the 
> destination page.

The problem with all these things is that as soon as we unlock the page,
it's visible to read().  And in fact, as soon as we mark it uptodate it's
visible to mmap, even if it's still locked.

> This would be slow but who cares given it would only happen incredibly 
> rarely and on majority of machines it would never happen at all.
> 
> The only potential problem I can see is that the destination page could be 
> truncated whilst it is unlocked.  I can see two possible solutions to 
> this:

truncate's OK: we're holding i_mutex.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
