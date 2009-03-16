Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id B42966B003D
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 04:59:17 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2G8xFUV029377
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 16 Mar 2009 17:59:15 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id E85CF45DE51
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 17:59:14 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id C5A5145DE61
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 17:59:14 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9D1941DB8044
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 17:59:14 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 4EDBF1DB803B
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 17:59:14 +0900 (JST)
Date: Mon, 16 Mar 2009 17:57:52 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 3/4] Memory controller soft limit organize cgroups (v6)
Message-Id: <20090316175752.50403b00.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090316084734.GW16897@balbir.in.ibm.com>
References: <20090314173043.16591.18336.sendpatchset@localhost.localdomain>
	<20090314173102.16591.6823.sendpatchset@localhost.localdomain>
	<20090316092126.221d2c9b.kamezawa.hiroyu@jp.fujitsu.com>
	<20090316084734.GW16897@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: linux-mm@kvack.org, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, 16 Mar 2009 14:17:35 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-03-16 09:21:26]:

> > Maybe code like this is good.
> > ==
> >  if (need_softlimit_check(mem)) {
> >      softlimit_res = res_counter_check_under_softlimit(&mem->res);
> >      if (softlimit_res) {
> >         struct mem_cgroup *mem = mem_cgroup_from_cont(softlimit_res);
> >         update_tree()....      
> >      }
> >  }
> > ==
> 
> An additional if is the problem?
My point is "check condition but the result is not used always" is ugly.

> We do all the checks under a lock we
> already hold. I ran aim9, new_dbase, dbase, compute and shared tests
> to make sure that there is no degradation. I've not seen anything
> noticable so far.
> 
ya, maybe. How about unix-bench exec test ?
(it's one of the worst application for memcg ;)

> > 
> > *And* what is important here is "need_softlimit_check(mem)".
> > As Andrew said, there may be something reasonable rather than using tick.
> > So, adding "mem_cgroup_need_softlimit_check(mem)" and improving what it checks
> > makes sense for development.
> > 
> 
> OK, that is a good abstraction, but scanning as a metric does not guarantee
> anything. It is harder to come up with better heuristics with scan
> rate than to come up with something time based. I am open to
> suggestions for something reliable though.
> 
I think making this easy-to-be-modified will help people other than us.
The memory-management algorithm is very difficult but people tend to try
their own new logic to improve overall performance.

Refactoring to make "modification of algorithm" easy makes sense for Linux, OSS.
We're not only people to modify memcontrol.c

So, I think some abstraction is good.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
