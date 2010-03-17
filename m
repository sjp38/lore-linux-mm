Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 703876B0087
	for <linux-mm@kvack.org>; Tue, 16 Mar 2010 21:49:07 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o2H1n538031836
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 17 Mar 2010 10:49:05 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id E555545DE52
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 10:49:04 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id B64CE45DE4D
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 10:49:04 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 966D41DB8040
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 10:49:04 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 42A58E38002
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 10:49:04 +0900 (JST)
Date: Wed, 17 Mar 2010 10:44:52 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch 05/10 -mm v3] oom: badness heuristic rewrite
Message-Id: <20100317104452.35732db9.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.1003161821400.14676@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1003100236510.30013@chino.kir.corp.google.com>
	<alpine.DEB.2.00.1003100239150.30013@chino.kir.corp.google.com>
	<20100312152048.e7dc8135.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.1003161821400.14676@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Balbir Singh <balbir@linux.vnet.ibm.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 16 Mar 2010 18:26:30 -0700 (PDT)
David Rientjes <rientjes@google.com> wrote:

> On Fri, 12 Mar 2010, KAMEZAWA Hiroyuki wrote:
> 
> > A small concern here.
> > 
> > +u64 mem_cgroup_get_limit(struct mem_cgroup *memcg)
> > +{
> > +       return res_counter_read_u64(&memcg->memsw, RES_LIMIT);
> > +}
> > 
> > Because memory cgroup has 2 limit controls as "memory" and "memory+swap",
> > a user may set only "memory" limitation. (Especially on swapless system.)
> > Then, memcg->memsw limit can be infinite in some situation.
> > 
> > So, how about this ? (just an idea after breif thinking..)
> > 
> > u64 mem_cgroup_get_memsw_limit(struct mem_cgroup *memcg)
> > {
> > 	u64 memlimit, memswlimit;
> > 
> > 	memlimit = res_counter_read_u64(&memcg->res, RES_LIMIT);
> > 	memswlimit = res_counter_read_u64(&memcg->memsw, RES_LIMIT);
> > 	if (memlimit + total_swap_pages > memswlimit)
> > 		return memswlimit;
> > 	return memlimit + total_swap_pages;
> > }
> > 
> 
> I definitely trust your judgment when it comes to memcg, so this is how I 
> implemented it for v4.
> 
> Is the memcg->memsw RES_LIMIT not initialized to zero for swapless systems 
> or when users don't set a value?  
It's initalized to inifinite (-1UL).

> In other words, is this the optimal way 
> to determine how much resident memory and swap that current's memcg is 
> allowed?
> 
I think so.

It's guaranteed that
	mem->res.limit <= mem->memsw.limit

Then, only when
	mem->res.limit + total_swap_pages > mem->memsw.limit
memsw.limit works.

Thanks,
-Kame







--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
