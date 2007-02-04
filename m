Date: Sun, 4 Feb 2007 17:40:35 +0000 (GMT)
From: Anton Altaparmakov <aia21@cam.ac.uk>
Subject: Re: [patch 9/9] mm: fix pagecache write deadlocks
In-Reply-To: <20070204031039.46b56dbb.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0702041737110.19190@hermes-1.csi.cam.ac.uk>
References: <20070204063707.23659.20741.sendpatchset@linux.site>
 <20070204063833.23659.55105.sendpatchset@linux.site>
 <20070204014445.88e6c8c7.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0702041036420.24838@hermes-1.csi.cam.ac.uk>
 <20070204031039.46b56dbb.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Nick Piggin <npiggin@suse.de>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux Filesystems <linux-fsdevel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sun, 4 Feb 2007, Andrew Morton wrote:
> On Sun, 4 Feb 2007 10:59:58 +0000 (GMT) Anton Altaparmakov <aia21@cam.ac.uk> wrote:
> > On Sun, 4 Feb 2007, Andrew Morton wrote:
> > > On Sun,  4 Feb 2007 09:51:07 +0100 (CET) Nick Piggin <npiggin@suse.de> wrote:
> > > > 2.  If we find the destination page is non uptodate, unlock it (this could be
> > > >     made slightly more optimal), then find and pin the source page with
> > > >     get_user_pages. Relock the destination page and continue with the copy.
> > > >     However, instead of a usercopy (which might take a fault), copy the data
> > > >     via the kernel address space.
> > > 
> > > argh.  We just can't go adding all this gunk into the write() path. 
> > > 
> > > mmap_sem, a full pte-walk, taking of pte-page locks, etc.  For every page. 
> > > Even single-process write() will suffer, let along multithreaded stuff,
> > > where mmap_sem contention may be the bigger problem.
> > > 
> > > I was going to do some quick measurements of this, but the code oopses
> > > on power4 (http://userweb.kernel.org/~akpm/s5000402.jpg)
> > > 
> > > We need to think different.
> > 
> > How about leaving the existing code with the following minor 
> > modifications:
> > 
> > Instead of calling filemap_copy_from_user{,_iovec}() do only the atomic 
> > bit with pagefaults disabled, i.e. instead of filemap_copy_from_user() we 
> > would do (could of course move into a helper function of course):
> > 
> > pagefault_disable()
> > kaddr = kmap_atomic(page, KM_USER0);
> > left = __copy_from_user_inatomic_nocache(kaddr + offset, buf, bytes);
> > kunmap_atomic(kaddr, KM_USER0);
> > pagefault_enable()
> > 
> > if (unlikely(left)) {
> > 	/* The user space page got unmapped before we got to copy it. */
> > 	...
> > }
> > 
> > Thus the 99.999% (or more!) of the time the code would just work as it 
> > always has and there is no bug and no speed impact.  Only in the very rare 
> > and hard to trigger race condition that the user space page after being 
> > faulted in got thrown out again before we did the atomic memory copy do we 
> > run into the above "..." code path.
> 
> Right.  And what I wanted to do here is to zero out the uncopied part of
> the page (if it wasn't uptodate), then run commit_write(), then retry the
> whole thing.
> 
> iirc, we ruled that out because those temporary zeroes are exposed to
> userspace.  But the kernel used to do that anyway for a long time (years)
> until someone noticed, and we'll only do it in your 0.0001% case anyway.
> 
> (Actually, perhaps we can prevent it by not marking the page uptodate in
> this case.  But that'll cause a read()er to try to bring it uptodate...)

My thinking was not marking the page uptodate.  But yes that causes the 
problem of a concurrent readpage reading uninitialized disk blocks that 
prepare_write allocated.

> > I would propose to call out a different function altogether which could do 
> > a multitude of things including drop the lock on the destination page 
> > (maintaining a reference on the page!), allocate a temporary page, copy 
> > from the user space page into the temporary page, then lock the 
> > destination page again, and copy from the temporary page into the 
> > destination page.
> 
> The problem with all these things is that as soon as we unlock the page,
> it's visible to read().  And in fact, as soon as we mark it uptodate it's
> visible to mmap, even if it's still locked.

Yes we definitely cannot mark it uptodate before it really is uptodate.
Either we have to not mark it uptodate or we have to zero it or we have to
think of some other magic...

> > This would be slow but who cares given it would only happen incredibly 
> > rarely and on majority of machines it would never happen at all.
> > 
> > The only potential problem I can see is that the destination page could be 
> > truncated whilst it is unlocked.  I can see two possible solutions to 
> > this:
> 
> truncate's OK: we're holding i_mutex.

How about excluding readpage() (in addition to truncate if Nick is right  
and some cases of truncate do not hold i_mutex) with an extra page flag as
I proposed for truncate exclusion?  Then it would not matter that
prepare_write might have allocated blocks and might expose stale data.    
It would go to sleep and wait on the bit to be cleared instead of trying  
to bring the page uptodate.  It can then lock the page and either find it 
uptodate (because commit_write did it) or not and then bring it uptodate.

Then we could safely fault in the page, copy from it into a temporary 
page, then lock the destination page again and copy into it.

This is getting more involved as a patch again...  )-:  But at least it   
does not affect the common case except for having to check the new page 
flag in every readpage() and truncate() call.  But at least the checks 
could be with an "if (unlikely(newpageflag()))" so should not be too bad.

Have I missed anything this time?

Best regards,

	Anton
-- 
Anton Altaparmakov <aia21 at cam.ac.uk> (replace at with @)
Unix Support, Computing Service, University of Cambridge, CB2 3QH, UK
Linux NTFS maintainer, http://www.linux-ntfs.org/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
