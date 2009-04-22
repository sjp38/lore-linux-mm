Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 154BA6B0105
	for <linux-mm@kvack.org>; Wed, 22 Apr 2009 16:34:03 -0400 (EDT)
Received: from zps19.corp.google.com (zps19.corp.google.com [172.25.146.19])
	by smtp-out.google.com with ESMTP id n3MKYTo3017106
	for <linux-mm@kvack.org>; Wed, 22 Apr 2009 21:34:30 +0100
Received: from rv-out-0708.google.com (rvfc5.prod.google.com [10.140.180.5])
	by zps19.corp.google.com with ESMTP id n3MKYR2e026724
	for <linux-mm@kvack.org>; Wed, 22 Apr 2009 13:34:28 -0700
Received: by rv-out-0708.google.com with SMTP id c5so139217rvf.14
        for <linux-mm@kvack.org>; Wed, 22 Apr 2009 13:34:27 -0700 (PDT)
Date: Wed, 22 Apr 2009 13:34:27 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 16/22] Do not setup zonelist cache when there is only
 one node
In-Reply-To: <1240432339.22694.64.camel@lts-notebook>
Message-ID: <alpine.DEB.2.00.0904221333040.14558@chino.kir.corp.google.com>
References: <1240408407-21848-1-git-send-email-mel@csn.ul.ie> <1240408407-21848-17-git-send-email-mel@csn.ul.ie> <alpine.DEB.2.00.0904221319120.14558@chino.kir.corp.google.com> <1240432339.22694.64.camel@lts-notebook>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Linux Memory Management List <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, 22 Apr 2009, Lee Schermerhorn wrote:

> > > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > > index 7f45de1..e59bb80 100644
> > > --- a/mm/page_alloc.c
> > > +++ b/mm/page_alloc.c
> > > @@ -1467,8 +1467,11 @@ this_zone_full:
> > >  		if (NUMA_BUILD)
> > >  			zlc_mark_zone_full(zonelist, z);
> > 
> > If zonelist caching is never used for UMA machines, why should they ever 
> > call zlc_mark_zone_full()?  It will always dereference 
> > zonelist->zlcache_ptr and immediately return without doing anything.
> > 
> > Wouldn't it better to just add
> > 
> > 	if (num_online_nodes() == 1)
> > 		continue;
> > 
> > right before this call to zlc_mark_zone_full()?  This should compile out 
> > the remainder of the loop for !CONFIG_NUMA kernels anyway.
> 
> Shouldn't it already do that?  NUMA_BUILD is defined as 0 when
> !CONFIG_NUMA to avoid #ifdef's in the code while still allowing compiler
> error checking in the dead code.
> 

Yeah, but adding the check on num_online_nodes() also prevents needlessly 
calling zlc_mark_zone_full() on CONFIG_NUMA kernels when running on an UMA 
machine.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
