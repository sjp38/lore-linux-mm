Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id C5FD76B007E
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 01:44:08 -0500 (EST)
Date: Tue, 16 Feb 2010 17:44:02 +1100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch -mm 8/9 v2] oom: avoid oom killer for lowmem allocations
Message-ID: <20100216064402.GC5723@laptop>
References: <alpine.DEB.2.00.1002151416470.26927@chino.kir.corp.google.com>
 <alpine.DEB.2.00.1002151419260.26927@chino.kir.corp.google.com>
 <20100216085706.c7af93e1.kamezawa.hiroyu@jp.fujitsu.com>
 <alpine.DEB.2.00.1002151606320.14484@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1002151606320.14484@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Lubos Lunak <l.lunak@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 15, 2010 at 04:10:15PM -0800, David Rientjes wrote:
> On Tue, 16 Feb 2010, KAMEZAWA Hiroyuki wrote:
> 
> > > If memory has been depleted in lowmem zones even with the protection
> > > afforded to it by /proc/sys/vm/lowmem_reserve_ratio, it is unlikely that
> > > killing current users will help.  The memory is either reclaimable (or
> > > migratable) already, in which case we should not invoke the oom killer at
> > > all, or it is pinned by an application for I/O.  Killing such an
> > > application may leave the hardware in an unspecified state and there is
> > > no guarantee that it will be able to make a timely exit.
> > > 
> > > Lowmem allocations are now failed in oom conditions so that the task can
> > > perhaps recover or try again later.  Killing current is an unnecessary
> > > result for simply making a GFP_DMA or GFP_DMA32 page allocation and no
> > > lowmem allocations use the now-deprecated __GFP_NOFAIL bit so retrying is
> > > unnecessary.
> > > 
> > > Previously, the heuristic provided some protection for those tasks with 
> > > CAP_SYS_RAWIO, but this is no longer necessary since we will not be
> > > killing tasks for the purposes of ISA allocations.
> > > 
> > > high_zoneidx is gfp_zone(gfp_flags), meaning that ZONE_NORMAL will be the
> > > default for all allocations that are not __GFP_DMA, __GFP_DMA32,
> > > __GFP_HIGHMEM, and __GFP_MOVABLE on kernels configured to support those
> > > flags.  Testing for high_zoneidx being less than ZONE_NORMAL will only
> > > return true for allocations that have either __GFP_DMA or __GFP_DMA32.
> > > 
> > > Acked-by: Rik van Riel <riel@redhat.com>
> > > Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> > > Signed-off-by: David Rientjes <rientjes@google.com>
> > > ---
> > >  mm/page_alloc.c |    3 +++
> > >  1 files changed, 3 insertions(+), 0 deletions(-)
> > > 
> > > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > > --- a/mm/page_alloc.c
> > > +++ b/mm/page_alloc.c
> > > @@ -1914,6 +1914,9 @@ rebalance:
> > >  	 * running out of options and have to consider going OOM
> > >  	 */
> > >  	if (!did_some_progress) {
> > > +		/* The oom killer won't necessarily free lowmem */
> > > +		if (high_zoneidx < ZONE_NORMAL)
> > > +			goto nopage;
> > >  		if ((gfp_mask & __GFP_FS) && !(gfp_mask & __GFP_NORETRY)) {
> > >  			if (oom_killer_disabled)
> > >  				goto nopage;
> > 
> > WARN_ON((high_zoneidx < ZONE_NORMAL) && (gfp_mask & __GFP_NOFAIL))
> > plz.
> > 
> 
> As I already explained when you first brought this up, the possibility of 
> not invoking the oom killer is not unique to GFP_DMA, it is also possible 
> for GFP_NOFS.  Since __GFP_NOFAIL is deprecated and there are no current 
> users of GFP_DMA | __GFP_NOFAIL, that warning is completely unnecessary.  
> We're not adding any additional __GFP_NOFAIL allocations.

Completely agree with this request. Actually, I think even better you
should just add && !(gfp_mask & __GFP_NOFAIL). Deprecated doesn't mean
it is OK to break the API (callers *will* oops or corrupt memory if
__GFP_NOFAIL returns NULL).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
