Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f42.google.com (mail-bk0-f42.google.com [209.85.214.42])
	by kanga.kvack.org (Postfix) with ESMTP id 55D3E6B0035
	for <linux-mm@kvack.org>; Tue, 17 Dec 2013 12:43:12 -0500 (EST)
Received: by mail-bk0-f42.google.com with SMTP id w11so3018052bkz.1
        for <linux-mm@kvack.org>; Tue, 17 Dec 2013 09:43:11 -0800 (PST)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id ko10si5562011bkb.340.2013.12.17.09.43.10
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 17 Dec 2013 09:43:11 -0800 (PST)
Date: Tue, 17 Dec 2013 12:43:02 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 5/7] mm: page_alloc: Make zone distribution page aging
 policy configurable
Message-ID: <20131217174302.GF21724@cmpxchg.org>
References: <1386943807-29601-1-git-send-email-mgorman@suse.de>
 <1386943807-29601-6-git-send-email-mgorman@suse.de>
 <20131216204215.GA21724@cmpxchg.org>
 <20131217152954.GA24067@suse.de>
 <20131217155435.GE21724@cmpxchg.org>
 <20131217161420.GG11295@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131217161420.GG11295@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Dec 17, 2013 at 04:14:20PM +0000, Mel Gorman wrote:
> On Tue, Dec 17, 2013 at 10:54:35AM -0500, Johannes Weiner wrote:
> > On Tue, Dec 17, 2013 at 03:29:54PM +0000, Mel Gorman wrote:
> > > On Mon, Dec 16, 2013 at 03:42:15PM -0500, Johannes Weiner wrote:
> > > > On Fri, Dec 13, 2013 at 02:10:05PM +0000, Mel Gorman wrote:
> > > > > Commit 81c0a2bb ("mm: page_alloc: fair zone allocator policy") solved a
> > > > > bug whereby new pages could be reclaimed before old pages because of
> > > > > how the page allocator and kswapd interacted on the per-zone LRU lists.
> > > > > Unfortunately it was missed during review that a consequence is that
> > > > > we also round-robin between NUMA nodes. This is bad for two reasons
> > > > > 
> > > > > 1. It alters the semantics of MPOL_LOCAL without telling anyone
> > > > > 2. It incurs an immediate remote memory performance hit in exchange
> > > > >    for a potential performance gain when memory needs to be reclaimed
> > > > >    later
> > > > > 
> > > > > No cookies for the reviewers on this one.
> > > > > 
> > > > > This patch makes the behaviour of the fair zone allocator policy
> > > > > configurable.  By default it will only distribute pages that are going
> > > > > to exist on the LRU between zones local to the allocating process. This
> > > > > preserves the historical semantics of MPOL_LOCAL.
> > > > > 
> > > > > By default, slab pages are not distributed between zones after this patch is
> > > > > applied. It can be argued that they should get similar treatment but they
> > > > > have different lifecycles to LRU pages, the shrinkers are not zone-aware
> > > > > and the interaction between the page allocator and kswapd is different
> > > > > for slabs. If it turns out to be an almost universal win, we can change
> > > > > the default.
> > > > > 
> > > > > Signed-off-by: Mel Gorman <mgorman@suse.de>
> > > > > ---
> > > > >  Documentation/sysctl/vm.txt |  32 ++++++++++++++
> > > > >  include/linux/mmzone.h      |   2 +
> > > > >  include/linux/swap.h        |   2 +
> > > > >  kernel/sysctl.c             |   8 ++++
> > > > >  mm/page_alloc.c             | 102 ++++++++++++++++++++++++++++++++++++++------
> > > > >  5 files changed, 134 insertions(+), 12 deletions(-)
> > > > > 
> > > > > diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
> > > > > index 1fbd4eb..8eaa562 100644
> > > > > --- a/Documentation/sysctl/vm.txt
> > > > > +++ b/Documentation/sysctl/vm.txt
> > > > > @@ -56,6 +56,7 @@ Currently, these files are in /proc/sys/vm:
> > > > >  - swappiness
> > > > >  - user_reserve_kbytes
> > > > >  - vfs_cache_pressure
> > > > > +- zone_distribute_mode
> > > > >  - zone_reclaim_mode
> > > > >  
> > > > >  ==============================================================
> > > > > @@ -724,6 +725,37 @@ causes the kernel to prefer to reclaim dentries and inodes.
> > > > >  
> > > > >  ==============================================================
> > > > >  
> > > > > +zone_distribute_mode
> > > > > +
> > > > > +Pages allocation and reclaim are managed on a per-zone basis. When the
> > > > > +system needs to reclaim memory, candidate pages are selected from these
> > > > > +per-zone lists.  Historically, a potential consequence was that recently
> > > > > +allocated pages were considered reclaim candidates. From a zone-local
> > > > > +perspective, page aging was preserved but from a system-wide perspective
> > > > > +there was an age inversion problem.
> > > > > +
> > > > > +A similar problem occurs on a node level where young pages may be reclaimed
> > > > > +from the local node instead of allocating remote memory. Unforuntately, the
> > > > > +cost of accessing remote nodes is higher so the system must choose by default
> > > > > +between favouring page aging or node locality. zone_distribute_mode controls
> > > > > +how the system will distribute page ages between zones.
> > > > > +
> > > > > +0	= Never round-robin based on age
> > > > 
> > > > I think we should be very conservative with the userspace interface we
> > > > export on a mechanism we are obviously just figuring out.
> > > > 
> > > 
> > > And we have a proposal on how to limit this. I'll be layering another
> > > patch on top and removes this interface again. That will allows us to
> > > rollback one patch and still have a usable interface if necessary.
> > > 
> > > > > +Otherwise the values are ORed together
> > > > > +
> > > > > +1	= Distribute anon pages between zones local to the allocating node
> > > > > +2	= Distribute file pages between zones local to the allocating node
> > > > > +4	= Distribute slab pages between zones local to the allocating node
> > > > 
> > > > Zone fairness within a node does not affect mempolicy or remote
> > > > reference costs.  Is there a reason to have this configurable?
> > > > 
> > > 
> > > Symmetry
> > > 
> > > > > +The following three flags effectively alter MPOL_DEFAULT, be careful.
> > > > > +
> > > > > +8	= Distribute anon pages between zones remote to the allocating node
> > > > > +16	= Distribute file pages between zones remote to the allocating node
> > > > > +32	= Distribute slab pages between zones remote to the allocating node
> > > > 
> > > > Yes, it's conceivable that somebody might want to disable remote
> > > > distribution because of the extra references.
> > > > 
> > > > But at this point, I'd much rather back out anon and slab distribution
> > > > entirely, it was a mistake to include them.
> > > > 
> > > > That would leave us with a single knob to disable remote page cache
> > > > placement.
> > > > 
> > > 
> > > When looking at this closer I found that sysv is a weird exception. It's
> > > file-backed as far as most of the VM is concerned but looks anonymous to
> > > most applications that care. That and MAP_SHARED anonymous pages should
> > > not be treated like files but we still want tmpfs to be treated as
> > > files. Details will be in the changelog of the next series.
> > 
> > In what sense is it seen as file-backed?
> 
> sysv and anonymous pages are backed by an internal shmem mount point. In
> lots of respects, it's looks like a file and quacks like a file but I expect
> developers think of it being anonmous and chunks of the VM treats it like
> it's anonymous. tmpfs uses the same paths and they get treated similar to
> the VM as anon but users may think that tmpfs should be subject to the
> fair allocation zone policy "because they're files." It's a sufficently
> weird case that any action we take there should be deliberate. It'll be
> a bit clearer when I post the patch that special cases this.

The line I see here is mostly derived from performance expectations.

People and programs expect anon, shmem/tmpfs etc. to be fast and avoid
their reclaim at great costs, so they size this part of their workload
according to memory size and locality.  Filesystem cache (on-disk) on
the other hand is expected to be slow on the first fault and after it
has been displaced by other data, but the kernel is mostly expected to
maximize the caching effects in a predictable manner.

The round-robin policy makes the displacement predictable (think of
the aging artifacts here where random pages do not get displaced
reliably because they ended up on remote nodes) and it avoids IO by
maximizing memory utilization.

I.e. it improves behavior associated with a cache, but I don't expect
shmem/tmpfs to be typically used as a disk cache.  I could be wrong
about that, but I figure if you need named shared memory that is
bigger than your memory capacity (the point where your tmpfs would
actually turn into a disk cache), you'd be better of using a more
efficient on-disk filesystem.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
