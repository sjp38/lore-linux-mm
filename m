Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 58EDA6B0078
	for <linux-mm@kvack.org>; Tue, 16 Mar 2010 23:30:21 -0400 (EDT)
Received: from hpaq2.eem.corp.google.com (hpaq2.eem.corp.google.com [10.3.21.2])
	by smtp-out.google.com with ESMTP id o2H3UHcH030216
	for <linux-mm@kvack.org>; Tue, 16 Mar 2010 20:30:18 -0700
Received: from pxi2 (pxi2.prod.google.com [10.243.27.2])
	by hpaq2.eem.corp.google.com with ESMTP id o2H3UE7Q026708
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 04:30:16 +0100
Received: by pxi2 with SMTP id 2so409870pxi.25
        for <linux-mm@kvack.org>; Tue, 16 Mar 2010 20:30:14 -0700 (PDT)
Date: Tue, 16 Mar 2010 20:30:10 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 05/10 -mm v3] oom: badness heuristic rewrite
In-Reply-To: <20100317104452.35732db9.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1003162029050.1023@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1003100236510.30013@chino.kir.corp.google.com> <alpine.DEB.2.00.1003100239150.30013@chino.kir.corp.google.com> <20100312152048.e7dc8135.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1003161821400.14676@chino.kir.corp.google.com>
 <20100317104452.35732db9.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Balbir Singh <balbir@linux.vnet.ibm.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 17 Mar 2010, KAMEZAWA Hiroyuki wrote:

> > > u64 mem_cgroup_get_memsw_limit(struct mem_cgroup *memcg)
> > > {
> > > 	u64 memlimit, memswlimit;
> > > 
> > > 	memlimit = res_counter_read_u64(&memcg->res, RES_LIMIT);
> > > 	memswlimit = res_counter_read_u64(&memcg->memsw, RES_LIMIT);
> > > 	if (memlimit + total_swap_pages > memswlimit)
> > > 		return memswlimit;
> > > 	return memlimit + total_swap_pages;
> > > }
> > > 
> > 
> > I definitely trust your judgment when it comes to memcg, so this is how I 
> > implemented it for v4.
> > 
> > Is the memcg->memsw RES_LIMIT not initialized to zero for swapless systems 
> > or when users don't set a value?  
> It's initalized to inifinite (-1UL).
> 

Ah, that makes sense.

> > In other words, is this the optimal way 
> > to determine how much resident memory and swap that current's memcg is 
> > allowed?
> > 
> I think so.
> 
> It's guaranteed that
> 	mem->res.limit <= mem->memsw.limit
> 
> Then, only when
> 	mem->res.limit + total_swap_pages > mem->memsw.limit
> memsw.limit works.
> 

Ok, I'll use your suggestion and then it can be maintained in 
mm/memcontrol.c for any future updates.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
