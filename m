Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 8F46D6B01DF
	for <linux-mm@kvack.org>; Thu, 14 May 2009 12:55:29 -0400 (EDT)
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e39.co.us.ibm.com (8.13.1/8.13.1) with ESMTP id n4EGqgU4031741
	for <linux-mm@kvack.org>; Thu, 14 May 2009 10:52:42 -0600
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n4EGuKkn188404
	for <linux-mm@kvack.org>; Thu, 14 May 2009 10:56:20 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n4EGuJvA028261
	for <linux-mm@kvack.org>; Thu, 14 May 2009 10:56:19 -0600
Date: Thu, 14 May 2009 22:26:17 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: mem_cgroup_lru_del_before_commit_swapcache() seems broken
Message-ID: <20090514165617.GB4451@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090514165045.GA4451@balbir.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090514165045.GA4451@balbir.in.ibm.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

* Balbir Singh <balbir@linux.vnet.ibm.com> [2009-05-14 22:20:45]:

> Hi, Kame,
> 
> mem_cgroup_lru_del_before_commit_swapcache() seems to be broken, here
> is why
> 
> 
> static void mem_cgroup_lru_del_before_commit_swapcache(struct page
> *page)
> {
>         unsigned long flags;
>         struct zone *zone = page_zone(page);
>         struct page_cgroup *pc = lookup_page_cgroup(page);
> 
>         spin_lock_irqsave(&zone->lru_lock, flags);
>         /*
>          * Forget old LRU when this page_cgroup is *not* used. This
>          * Used bit
>          * is guarded by lock_page() because the page is SwapCache.
>          */
>         if (!PageCgroupUsed(pc))
>                 mem_cgroup_del_lru_list(page, page_lru(page));
> 
> ...
> ...
> void mem_cgroup_del_lru_list(struct page *page, enum lru_list lru)
> {
>         struct page_cgroup *pc;
>         struct mem_cgroup *mem;
>         struct mem_cgroup_per_zone *mz;
> 
>         if (mem_cgroup_disabled())
>                 return;
>         pc = lookup_page_cgroup(page);
>         /* can happen while we handle swapcache. */
>         if (!PageCgroupUsed(pc))
>                 return;
> 
> 
> In mem_cgroup_lru_del_before_commit_swapcache() we say
>         if (!PageCgroupused(pc))
>                 mem_cgroup_del_lru_list()
> 
> in mem_cgroup_del_lru_list() we say
>         if (!PageCgroupUsed(pc))
>                 return;
> 
> So why call mem_cgroup_del_lru_list() at all? Am I missing something.
>

Please ignore, looks like a badly applied diff, let the change over in
my sources. Sorry for the noise 

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
