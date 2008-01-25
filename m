Date: Fri, 25 Jan 2008 13:35:55 -0600
From: Robin Holt <holt@sgi.com>
Subject: Re: [patch 1/4] mmu_notifier: Core code
Message-ID: <20080125193554.GP26420@sgi.com>
References: <20080125055606.102986685@sgi.com> <20080125055801.212744875@sgi.com> <20080125183934.GO26420@sgi.com> <Pine.LNX.4.64.0801251041040.672@schroedinger.engr.sgi.com> <20080125185646.GQ3058@sgi.com> <Pine.LNX.4.64.0801251058170.3198@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0801251058170.3198@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Robin Holt <holt@sgi.com>, Andrea Arcangeli <andrea@qumranet.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, Nick Piggin <npiggin@suse.de>, kvm-devel@lists.sourceforge.net, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Fri, Jan 25, 2008 at 11:03:07AM -0800, Christoph Lameter wrote:
> > > > Shouldn't this really be protected by the down_write(mmap_sem)?  Maybe:
> > > 
> > > Ok. We could switch this to mmap_sem protection for the mm_struct but the 
> > > rmap notifier is not associated with an mm_struct. So we would need to 
> > > keep it there. Since we already have a spinlock: Just use it for both to 
> > > avoid further complications.
> > 
> > But now you are putting a global lock in where it is inappropriate.
> 
> The lock is only used during register and unregister. Very low level 
> usage.

Seems to me that is the same argument used for lock_kernel.  I am saying
we have a perfectly reasonable way to seperate the protections down to
their smallest.  For the things hanging off the mm, mmap_sem, for the
other list, a list specific lock.

Keep in mind that on a 2048p SSI MPI job starting up, we have 2048 ranks
doing this at the same time 6 times withing their address range.  That
seems like a lock which could get hot fairly quickly.  It may be for a
short period during startup and shutdown, but it is there.


> 
> > > > XPMEM, would also benefit from a call early.  We could make all the
> > > > segments as being torn down and start the recalls.  We already have
> > > > this code in and working (have since it was first written 6 years ago).
> > > > In this case, all segments are torn down with a single message to each
> > > > of the importing partitions.  In contrast, the teardown code which would
> > > > happen now would be one set of messages for each vma.
> > > 
> > > So we need an additional global teardown call? Then we'd need to switch 
> > > off the vma based invalidate_range()?
> > 
> > No, EXACTLY what I originally was asking for, either move this call site
> > up, introduce an additional mmu_notifier op, or place this one in two
> > locations with a flag indicating which call is being made.
> 
> Add a new invalidate_all() call? Then on exit we do
> 
> 1. invalidate_all()

That will be fine as long as we can unregister the ops notifier and free
the structure.  Otherwise, we end up being called needlessly.

> 
> 2. invalidate_range() for each vma
> 
> 3. release()
> 
> We cannot simply move the call up because there will be future range 
> callbacks on vma invalidation.

I am not sure what this means.  Right now, if you were to notify XPMEM
the process is exiting, we would take care of all the recalling of pages
exported by this process, clearing those pages cache lines from cache,
and raising memory protections.  I would assume that moving the callout
earlier would expect the same of every driver.


Thanks,
Robin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
