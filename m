Date: Wed, 22 Mar 2000 23:41:15 +0100
From: Jamie Lokier <jamie.lokier@cern.ch>
Subject: Re: MADV_DONTNEED
Message-ID: <20000322234115.B31795@pcep-jamie.cern.ch>
References: <20000322184357.C7271@pcep-jamie.cern.ch> <Pine.BSO.4.10.10003221641400.17378-100000@funky.monkey.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <Pine.BSO.4.10.10003221641400.17378-100000@funky.monkey.org>; from Chuck Lever on Wed, Mar 22, 2000 at 04:54:09PM -0500
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chuck Lever <cel@monkey.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Chuck Lever wrote:
> > If I knew what msync(MS_INVALIDATE) did I could think about this! :-)
> > But the msync documentation is unhelpful and possibly misleading.
> 
> well, the doc's accurate, as far as i can tell.  but my use of it is a
> side-effect of the behavior described in the man page.

	"MS_INVALIDATE asks to invalidate  other  mappings  of  the
       same file (so that they can be updated with the fresh val-
       ues just written)."

Oh I see.  It means the locally modified but in principle shared mapping
is copied back to the underlying object.  For a page aligned mapping
that shouldn't need to do anything.

Since the MS_INVALIDATE code doesn't modify other ptes, we must assume
the other mappings are all page aligned or they wouldn't see the
update.

So why does MS_INVALIDATE have any code? :-)

> > > function 2 (could be MADV_FREE; currently msync(MS_INVALIDATE)):
> > >   release pages, syncing dirty data.  if they are referenced again, the
> > >   process causes page faults to read in latest data.
> > 
> > Oh, I see, this is what msync(MS_INVALIDATE) does :-)
> 
> more or less.  it removes the mappings, but also schedules writes for any
> dirty pages it finds.

I think "schedules writes" is what MS_ASYNC and MS_SYNC do,
independently of MS_INVALIDATE.

> > > function 4 (for comparison; currently munmap):
> > >   release pages, syncing dirty data.  if they are referenced again, the
> > >   process causes invalid memory access faults.
> > 
> > > for MADV_DONTNEED, i re-used code.
> > 
> > From where?
> 
> you can find logic that invokes zap_page_range throughout the mm code, but
> especially in do_munmap.  if my implementation is broken in this regard,
> then i'd bet do_munmap is broken too.

do_munmap also calls vm_ops->unmap before the zap_page_range, which has
a potentially important side effects for files...  Like actually writing
the data :-)

That's not what, say, MADV_DISCARD would do, but it's what "release
pages, syncing dirty data" should do.

> > > i'm not convinced that it's correct, though, as i stated when i
> > > submitted the patch.  it may abandon swap cache pages, and there may
> > > be some undefined interaction between file truncation and
> > > MADV_DONTNEED.
> > 
> > Oh dear -- because it's in pre2.4 already :-)
> > Better work out what it's supposed to do and fix it :-)
> 
> it's not too serious, i hope, since madvise is not used by any existing
> Linux apps.  this area of the kernel has been changing so much in the past
> 6-9 months that it's been difficult to know what is the blessed way to get
> my implementation to work.

Quite.  I'm not so concerned about the implementation at this stage as
getting agreement on the right semantics!

-- Jamie
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
