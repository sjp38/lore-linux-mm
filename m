Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 559716B0047
	for <linux-mm@kvack.org>; Tue, 23 Feb 2010 16:12:43 -0500 (EST)
Received: from kpbe13.cbf.corp.google.com (kpbe13.cbf.corp.google.com [172.25.105.77])
	by smtp-out.google.com with ESMTP id o1NLCeFW020190
	for <linux-mm@kvack.org>; Tue, 23 Feb 2010 13:12:40 -0800
Received: from fxm4 (fxm4.prod.google.com [10.184.13.4])
	by kpbe13.cbf.corp.google.com with ESMTP id o1NLCcrV025212
	for <linux-mm@kvack.org>; Tue, 23 Feb 2010 15:12:39 -0600
Received: by fxm4 with SMTP id 4so4365068fxm.20
        for <linux-mm@kvack.org>; Tue, 23 Feb 2010 13:12:37 -0800 (PST)
Date: Tue, 23 Feb 2010 13:12:29 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm 8/9 v2] oom: avoid oom killer for lowmem
 allocations
In-Reply-To: <20100223112431.GA8871@balbir.in.ibm.com>
Message-ID: <alpine.DEB.2.00.1002231310440.31815@chino.kir.corp.google.com>
References: <20100216085706.c7af93e1.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1002151606320.14484@chino.kir.corp.google.com> <20100216064402.GC5723@laptop> <alpine.DEB.2.00.1002152334260.7470@chino.kir.corp.google.com> <20100216075330.GJ5723@laptop>
 <alpine.DEB.2.00.1002160024370.15201@chino.kir.corp.google.com> <20100217084858.fd72ec4f.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1002161555170.11952@chino.kir.corp.google.com> <20100217090303.6bd64209.kamezawa.hiroyu@jp.fujitsu.com>
 <alpine.DEB.2.00.1002161609200.11952@chino.kir.corp.google.com> <20100223112431.GA8871@balbir.in.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Lubos Lunak <l.lunak@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 23 Feb 2010, Balbir Singh wrote:

> > out_of_memory() doesn't return a value to specify whether the page 
> > allocator should retry the allocation or just return NULL, all that policy 
> > is kept in mm/page_alloc.c.  For highzone_idx < ZONE_NORMAL, we want to 
> > fail the allocation when !(gfp_mask & __GFP_NOFAIL) and call the oom 
> > killer when it's __GFP_NOFAIL.
> > ---
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -1696,6 +1696,9 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
> >  		/* The OOM killer will not help higher order allocs */
> >  		if (order > PAGE_ALLOC_COSTLY_ORDER)
> >  			goto out;
> > +		/* The OOM killer does not needlessly kill tasks for lowmem */
> > +		if (high_zoneidx < ZONE_NORMAL)
> > +			goto out;
> 
> I am not sure if this is a good idea, ZONE_DMA could have a lot of
> memory on some architectures. IIUC, we return NULL for allocations
> from ZONE_DMA? What is the reason for the heuristic?
> 

As the patch description says, we would otherwise needlessly kill tasks 
that may not be consuming any lowmem since there is no way to determine 
its usage and typically the memory in lowmem will either be reclaimable 
(or migratable via memory compaction) if it is not pinned for I/O in which 
case we shouldn't kill for it anyway at this point.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
