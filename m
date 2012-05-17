Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id 3CEEC6B0082
	for <linux-mm@kvack.org>; Thu, 17 May 2012 03:43:14 -0400 (EDT)
Date: Thu, 17 May 2012 17:43:08 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: Hole punching and mmap races
Message-ID: <20120517074308.GQ25351@dastard>
References: <20120515224805.GA25577@quack.suse.cz>
 <20120516021423.GO25351@dastard>
 <20120516130445.GA27661@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120516130445.GA27661@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-fsdevel@vger.kernel.org, xfs@oss.sgi.com, linux-ext4@vger.kernel.org, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org

On Wed, May 16, 2012 at 03:04:45PM +0200, Jan Kara wrote:
> On Wed 16-05-12 12:14:23, Dave Chinner wrote:
> > On Wed, May 16, 2012 at 12:48:05AM +0200, Jan Kara wrote:
> > > It's not easy to protect against these races. For truncate, i_size protects
> > > us against similar races but for hole punching we don't have any such
> > > mechanism. One way to avoid the race would be to hold mmap_sem while we are
> > > invalidating the page cache and punching hole but that sounds a bit ugly.
> > > Alternatively we could just have some special lock (rwsem?) held during
> > > page_mkwrite() (for reading) and during whole hole punching (for writing)
> > > to serialize these two operations.
> > 
> > What really needs to happen is that .page_mkwrite() can be made to
> > fail with -EAGAIN and retry the entire page fault from the start an
> > arbitrary number of times instead of just once as the current code
> > does with VM_FAULT_RETRY. That would allow us to try to take the
> > filesystem lock that provides IO exclusion for all other types of IO
> > and fail with EAGAIN if we can't get it without blocking. For XFS,
> > that is the i_iolock rwsem, for others it is the i_mutex, and some
> > other filesystems might take other locks.
>   Actually, I've been playing with VM_FAULT_RETRY recently (for freezing
> patches) and it's completely unhandled for .page_mkwrite() callbacks.

Yeah, it's a mess.

> Also
> only x86 really tries to handle it at all. Other architectures just don't
> allow it at all. Also there's a ton of callers of things like
> get_user_pages() which would need to handle VM_FAULT_RETRY and for some of
> them it would be actually non-trivial.

Seems kind of silly to me to have a generic retry capability in the
page fault handler and then not implement it in a useful manner for
*anyone*.

> But in this particular case, I don't think VM_FAULT_RETRY is strictly
> necessary. We can have a lock, which ranks below mmap_sem (and thus
> i_mutex / i_iolock) and above i_mmap_mutex (thus page lock), transaction
> start, etc. Such lock could be taken in page_mkwrite() before taking page
> lock, in truncate() and punch_hold() just after i_mutex, and direct IO
> paths could be tweaked to use it as well I think.

Which means we'd be adding another layer of mostly redundant locking
just to avoid i_mutex/mmap_sem inversion. But I don't see how it
solves the direct IO problem because we still need to grab the
mmap_sem inside the IO during get_user_pages_fast() while holding
i_mutex/i_iolock....

> > FWIW, I've been running at "use the IO lock in page_mkwrite" patch
> > for XFS for several months now, but I haven't posted it because
> > without the VM side being able to handle such locking failures
> > gracefully there's not much point in making the change. I did this
> > patch to reduce the incidence of mmap vs direct IO races that are
> > essentially identical in nature to rule them out of the cause of
> > stray delalloc blocks in files that fsstress has been producing on
> > XFS. FYI, this race condition hasn't been responsible for any of the
> > problems I've found recently....
>   Yeah, I've been trying to hit the race window for a while and I failed as
> well...

IIRC, it's a rare case (that I consider insane, BTW):  read from a
file with into a buffer that is a mmap()d region of the same file
that has not been faulted in yet.....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
