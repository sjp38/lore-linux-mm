From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [patch 2/6] mmu_notifier: Callbacks to invalidate address ranges
Date: Mon, 3 Mar 2008 16:11:09 +1100
References: <20080215064859.384203497@sgi.com> <200802201008.49933.nickpiggin@yahoo.com.au> <Pine.LNX.4.64.0802271424390.13186@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0802271424390.13186@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Disposition: inline
Message-Id: <200803031611.10275.nickpiggin@yahoo.com.au>
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@linux-foundation.org, Andrea Arcangeli <andrea@qumranet.com>, Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, general@lists.openfabrics.org, Steve Wise <swise@opengridcomputing.com>, Roland Dreier <rdreier@cisco.com>, Kanoj Sarcar <kanojsarcar@yahoo.com>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com
List-ID: <linux-mm.kvack.org>

On Thursday 28 February 2008 09:35, Christoph Lameter wrote:
> On Wed, 20 Feb 2008, Nick Piggin wrote:
> > On Friday 15 February 2008 17:49, Christoph Lameter wrote:

> > Also, what we are going to need here are not skeleton drivers
> > that just do all the *easy* bits (of registering their callbacks),
> > but actual fully working examples that do everything that any
> > real driver will need to do. If not for the sanity of the driver
> > writer, then for the sanity of the VM developers (I don't want
> > to have to understand xpmem or infiniband in order to understand
> > how the VM works).
>
> There are 3 different drivers that can already use it but the code is
> complex and not easy to review. Skeletons are easy to allow people to get
> started with it.

Your skeleton is just registering notifiers and saying

/* you fill the hard part in */

If somebody needs a skeleton in order just to register the notifiers,
then almost by definition they are unqualified to write the hard
part ;)


> > >  	lru_add_drain();
> > >  	tlb = tlb_gather_mmu(mm, 0);
> > >  	update_hiwater_rss(mm);
> > > +	mmu_notifier(invalidate_range_begin, mm, address, end, atomic);
> > >  	end = unmap_vmas(&tlb, vma, address, end, &nr_accounted, details);
> > >  	if (tlb)
> > >  		tlb_finish_mmu(tlb, address, end);
> > > +	mmu_notifier(invalidate_range_end, mm, address, end, atomic);
> > >  	return end;
> > >  }
> >
> > Where do you invalidate for munmap()?
>
> zap_page_range() called from unmap_vmas().

But it is not allowed to sleep. Where do you call the sleepable one
from?


> > Also, how to you resolve the case where you are not allowed to sleep?
> > I would have thought either you have to handle it, in which case nobody
> > needs to sleep; or you can't handle it, in which case the code is
> > broken.
>
> That can be done in a variety of ways:
>
> 1. Change VM locking
>
> 2. Not handle file backed mappings (XPmem could work mostly in such a
> config)
>
> 3. Keep the refcount elevated until pages are freed in another execution
> context.

OK, there are ways to solve it or hack around it. But this is exactly
why I think the implementations should be kept seperate. Andrea's
notifiers are coherent, work on all types of mappings, and will
hopefully match closely the regular TLB invalidation sequence in the
Linux VM (at the moment it is quite close, but I hope to make it a
bit closer) so that it requires almost no changes to the mm.

All the other things to try to make it sleep are either hacking holes
in it (eg by removing coherency). So I don't think it is reasonable to
require that any patch handle all cases. I actually think Andrea's
patch is quite nice and simple itself, wheras I am against the patches
that you posted.

What about a completely different approach... XPmem runs over NUMAlink,
right? Why not provide some non-sleeping way to basically IPI remote
nodes over the NUMAlink where they can process the invalidation? If you
intra-node cache coherency has to run over this link anyway, then
presumably it is capable.

Or another idea, why don't you LD_PRELOAD in the MPT library to also
intercept munmap, mprotect, mremap etc as well as just fork()? That
would give you similarly "good enough" coherency as the mmu notifier
patches except that you can't swap (which Robin said was not a big
problem).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
