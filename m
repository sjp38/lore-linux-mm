Date: Tue, 19 Feb 2008 21:12:21 -0600
From: Robin Holt <holt@sgi.com>
Subject: Re: [patch 5/6] mmu_notifier: Support for drivers with revers maps
	(f.e. for XPmem)
Message-ID: <20080220031221.GE11391@sgi.com>
References: <20080215064859.384203497@sgi.com> <20080215064933.376635032@sgi.com> <200802201055.21343.nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200802201055.21343.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Christoph Lameter <clameter@sgi.com>, akpm@linux-foundation.org, Andrea Arcangeli <andrea@qumranet.com>, Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, general@lists.openfabrics.org, Steve Wise <swise@opengridcomputing.com>, Roland Dreier <rdreier@cisco.com>, Kanoj Sarcar <kanojsarcar@yahoo.com>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com
List-ID: <linux-mm.kvack.org>

On Wed, Feb 20, 2008 at 10:55:20AM +1100, Nick Piggin wrote:
> On Friday 15 February 2008 17:49, Christoph Lameter wrote:
> > These special additional callbacks are required because XPmem (and likely
> > other mechanisms) do use their own rmap (multiple processes on a series
> > of remote Linux instances may be accessing the memory of a process).
> > F.e. XPmem may have to send out notifications to remote Linux instances
> > and receive confirmation before a page can be freed.
> >
> > So we handle this like an additional Linux reverse map that is walked after
> > the existing rmaps have been walked. We leave the walking to the driver
> > that is then able to use something else than a spinlock to walk its reverse
> > maps. So we can actually call the driver without holding spinlocks while we
> > hold the Pagelock.
> 
> I don't know how this is supposed to solve anything. The sleeping
> problem happens I guess mostly in truncate. And all you are doing
> is putting these rmap callbacks in page_mkclean and try_to_unmap.
> 
> 
> > However, we cannot determine the mm_struct that a page belongs to at
> > that point. The mm_struct can only be determined from the rmaps by the
> > device driver.
> >
> > We add another pageflag (PageExternalRmap) that is set if a page has
> > been remotely mapped (f.e. by a process from another Linux instance).
> > We can then only perform the callbacks for pages that are actually in
> > remote use.
> >
> > Rmap notifiers need an extra page bit and are only available
> > on 64 bit platforms. This functionality is not available on 32 bit!
> >
> > A notifier that uses the reverse maps callbacks does not need to provide
> > the invalidate_page() method that is called when locks are held.
> 
> That doesn't seem right. To start with, the new callbacks aren't
> even called in the places where invalidate_page isn't allowed to
> sleep.
> 
> The problem is unmap_mapping_range, right? And unmap_mapping_range
> must walk the rmaps with the mmap lock held, which is why it can't
> sleep. And it can't hold any mmap_sem so it cannot prevent address
> space modifications of the processes in question between the time
> you unmap them from the linux ptes with unmap_mapping_range, and the
> time that you unmap them from your driver.
> 
> So in the meantime, you could have eg. a fault come in and set up a
> new page for one of the processes, and that page might even get
> exported via the same external driver. And now you have a totally
> inconsistent view.
> 
> Preventing new mappings from being set up until the old mapping is
> completely flushed is basically what we need to ensure for any sane
> TLB as far as I can tell. To do that, you'll need to make the mmap
> lock sleep, and either take mmap_sem inside it (which is a
> deadlock condition at the moment), or make ptl sleep as well. These
> are simply the locks we use to prevent that from happening, so I
> can't see how you can possibly hope to have a coherent TLB without
> invalidating inside those locks.

All of that is correct.  For XPMEM, we do not currently allow file backed
mapping pages from being exported so we should never reach this condition.
It has been an issue since day 1.  We have operated with that assumption
for 6 years and have not had issues with that assumption.  The user of
xpmem is MPT and it controls the communication buffers so it is reasonable
to expect this type of behavior.

Thanks,
Robin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
