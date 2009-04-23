Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 5C2986B0109
	for <linux-mm@kvack.org>; Wed, 22 Apr 2009 20:11:12 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n3N0BKfI019907
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 23 Apr 2009 09:11:20 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id EEEEA45DD82
	for <linux-mm@kvack.org>; Thu, 23 Apr 2009 09:11:19 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id B660E45DD80
	for <linux-mm@kvack.org>; Thu, 23 Apr 2009 09:11:19 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 958441DB803E
	for <linux-mm@kvack.org>; Thu, 23 Apr 2009 09:11:19 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 49DB51DB8037
	for <linux-mm@kvack.org>; Thu, 23 Apr 2009 09:11:19 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 16/22] Do not setup zonelist cache when there is only one node
In-Reply-To: <alpine.DEB.2.00.0904221333040.14558@chino.kir.corp.google.com>
References: <1240432339.22694.64.camel@lts-notebook> <alpine.DEB.2.00.0904221333040.14558@chino.kir.corp.google.com>
Message-Id: <20090423090704.F6E3.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 23 Apr 2009 09:11:18 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Mel Gorman <mel@csn.ul.ie>, Linux Memory Management List <linux-mm@kvack.org>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> On Wed, 22 Apr 2009, Lee Schermerhorn wrote:
> 
> > > > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > > > index 7f45de1..e59bb80 100644
> > > > --- a/mm/page_alloc.c
> > > > +++ b/mm/page_alloc.c
> > > > @@ -1467,8 +1467,11 @@ this_zone_full:
> > > >  		if (NUMA_BUILD)
> > > >  			zlc_mark_zone_full(zonelist, z);
> > > 
> > > If zonelist caching is never used for UMA machines, why should they ever 
> > > call zlc_mark_zone_full()?  It will always dereference 
> > > zonelist->zlcache_ptr and immediately return without doing anything.
> > > 
> > > Wouldn't it better to just add
> > > 
> > > 	if (num_online_nodes() == 1)
> > > 		continue;
> > > 
> > > right before this call to zlc_mark_zone_full()?  This should compile out 
> > > the remainder of the loop for !CONFIG_NUMA kernels anyway.
> > 
> > Shouldn't it already do that?  NUMA_BUILD is defined as 0 when
> > !CONFIG_NUMA to avoid #ifdef's in the code while still allowing compiler
> > error checking in the dead code.
> > 
> 
> Yeah, but adding the check on num_online_nodes() also prevents needlessly 
> calling zlc_mark_zone_full() on CONFIG_NUMA kernels when running on an UMA 
> machine.

I don't like this idea...

In UMA system, zlc_mark_zone_full() isn't so expensive. but In large system
one branch increasing is often costly.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
