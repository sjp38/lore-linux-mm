Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 160126B0092
	for <linux-mm@kvack.org>; Tue, 16 Mar 2010 21:26:42 -0400 (EDT)
Received: from spaceape8.eur.corp.google.com (spaceape8.eur.corp.google.com [172.28.16.142])
	by smtp-out.google.com with ESMTP id o2H1QbXk023115
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 02:26:38 +0100
Received: from pxi33 (pxi33.prod.google.com [10.243.27.33])
	by spaceape8.eur.corp.google.com with ESMTP id o2H1QYpS022924
	for <linux-mm@kvack.org>; Tue, 16 Mar 2010 18:26:36 -0700
Received: by pxi33 with SMTP id 33so369449pxi.12
        for <linux-mm@kvack.org>; Tue, 16 Mar 2010 18:26:34 -0700 (PDT)
Date: Tue, 16 Mar 2010 18:26:30 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 05/10 -mm v3] oom: badness heuristic rewrite
In-Reply-To: <20100312152048.e7dc8135.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1003161821400.14676@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1003100236510.30013@chino.kir.corp.google.com> <alpine.DEB.2.00.1003100239150.30013@chino.kir.corp.google.com> <20100312152048.e7dc8135.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Balbir Singh <balbir@linux.vnet.ibm.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 12 Mar 2010, KAMEZAWA Hiroyuki wrote:

> A small concern here.
> 
> +u64 mem_cgroup_get_limit(struct mem_cgroup *memcg)
> +{
> +       return res_counter_read_u64(&memcg->memsw, RES_LIMIT);
> +}
> 
> Because memory cgroup has 2 limit controls as "memory" and "memory+swap",
> a user may set only "memory" limitation. (Especially on swapless system.)
> Then, memcg->memsw limit can be infinite in some situation.
> 
> So, how about this ? (just an idea after breif thinking..)
> 
> u64 mem_cgroup_get_memsw_limit(struct mem_cgroup *memcg)
> {
> 	u64 memlimit, memswlimit;
> 
> 	memlimit = res_counter_read_u64(&memcg->res, RES_LIMIT);
> 	memswlimit = res_counter_read_u64(&memcg->memsw, RES_LIMIT);
> 	if (memlimit + total_swap_pages > memswlimit)
> 		return memswlimit;
> 	return memlimit + total_swap_pages;
> }
> 

I definitely trust your judgment when it comes to memcg, so this is how I 
implemented it for v4.

Is the memcg->memsw RES_LIMIT not initialized to zero for swapless systems 
or when users don't set a value?  In other words, is this the optimal way 
to determine how much resident memory and swap that current's memcg is 
allowed?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
