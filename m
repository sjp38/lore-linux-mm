Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f49.google.com (mail-yh0-f49.google.com [209.85.213.49])
	by kanga.kvack.org (Postfix) with ESMTP id CAAFF6B0031
	for <linux-mm@kvack.org>; Wed, 11 Dec 2013 20:08:01 -0500 (EST)
Received: by mail-yh0-f49.google.com with SMTP id z20so5738211yhz.8
        for <linux-mm@kvack.org>; Wed, 11 Dec 2013 17:08:01 -0800 (PST)
Received: from ipmail06.adl6.internode.on.net (ipmail06.adl6.internode.on.net. [2001:44b8:8060:ff02:300:1:6:6])
        by mx.google.com with ESMTP id r46si19804330yhm.22.2013.12.11.17.07.59
        for <linux-mm@kvack.org>;
        Wed, 11 Dec 2013 17:08:00 -0800 (PST)
Date: Thu, 12 Dec 2013 12:07:54 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [patch] mm, page_alloc: make __GFP_NOFAIL really not fail
Message-ID: <20131212010754.GE31386@dastard>
References: <alpine.DEB.2.02.1312091355360.11026@chino.kir.corp.google.com>
 <20131209152202.df3d4051d7dc61ada7c420a9@linux-foundation.org>
 <alpine.DEB.2.02.1312101504120.22701@chino.kir.corp.google.com>
 <20131210153909.8b4bfa1d643e5f8582eff7c9@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131210153909.8b4bfa1d643e5f8582eff7c9@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Dec 10, 2013 at 03:39:09PM -0800, Andrew Morton wrote:
> On Tue, 10 Dec 2013 15:20:17 -0800 (PST) David Rientjes <rientjes@google.com> wrote:
> 
> > On Mon, 9 Dec 2013, Andrew Morton wrote:
> > 
> > > > __GFP_NOFAIL specifies that the page allocator cannot fail to return
> > > > memory.  Allocators that call it may not even check for NULL upon
> > > > returning.
> > > > 
> > > > It turns out GFP_NOWAIT | __GFP_NOFAIL or GFP_ATOMIC | __GFP_NOFAIL can
> > > > actually return NULL.  More interestingly, processes that are doing
> > > > direct reclaim and have PF_MEMALLOC set may also return NULL for any
> > > > __GFP_NOFAIL allocation.
> > > 
> > > __GFP_NOFAIL is a nasty thing and making it pretend to work even better
> > > is heading in the wrong direction, surely?  It would be saner to just
> > > disallow these even-sillier combinations.  Can we fix up the current
> > > callers then stick a WARN_ON() in there?
> > > 
> > 
> > Heh, it's difficult to remove __GFP_NOFAIL when new users get added: 
> > 84235de394d9 ("fs: buffer: move allocation failure loop into the 
> > allocator") added a new user
> 
> That wasn't reeeeealy a new user - it was "convert an existing
> open-coded retry-for-ever loop".  Which is what __GFP_NOFAIL is for.
> 
> I don't think I've ever seen anyone actually fix one of these things
> (by teaching the caller to handle ENOMEM), so it obviously isn't
> working...

Right, because most of the loops are deep within filesystem
transaction code where the only thing to do with a memory allocation
failure is to abort the transaction, shutdown the filesystem and
deny user access (i.e. DOS the system) because the filesystem is
inconsistent in memory and the only way it can be recovered is
toosing everything in memory away and recovering the last valid
on disk state from the journal. i.e. umount, mount.

IOWs, the "fix" is far worse than current behaviour and so there is
absolutely no motivation for the people who own these __GFP_NOFAIL
allocations to fix them. Indeed, when you consider that the amount of
work to fix the filesystems to robustly handle ENOMEM is a *massive*
undertaking that adds significant overhead and complexity to each
filesystem, the cost/benefit analysis comes down so far on the side
of "just use __GFP_NOFAIL" that doing anything else is sheer lunacy.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
