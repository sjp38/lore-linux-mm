Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 3F6ED6B007D
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 00:32:22 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o1G5WJBH007520
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 16 Feb 2010 14:32:19 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 1753645DE5B
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 14:32:19 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id C12BA45DE51
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 14:32:18 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 9F8B3E18001
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 14:32:18 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 38A56E18003
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 14:32:18 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch -mm 8/9 v2] oom: avoid oom killer for lowmem allocations
In-Reply-To: <alpine.DEB.2.00.1002151606320.14484@chino.kir.corp.google.com>
References: <20100216085706.c7af93e1.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1002151606320.14484@chino.kir.corp.google.com>
Message-Id: <20100216142856.72F4.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 16 Feb 2010 14:32:17 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Lubos Lunak <l.lunak@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

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

No current user? I don't think so.

	int bio_integrity_prep(struct bio *bio)
	{
	(snip)
	        buf = kmalloc(len, GFP_NOIO | __GFP_NOFAIL | q->bounce_gfp);

and 

	void blk_queue_bounce_limit(struct request_queue *q, u64 dma_mask)
	{
	(snip)
	        if (dma) {
	                init_emergency_isa_pool();
	                q->bounce_gfp = GFP_NOIO | GFP_DMA;
	                q->limits.bounce_pfn = b_pfn;
	        }



I don't like rumor based discussion, I like fact based one.

Thanks.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
