Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 0EFB16B0047
	for <linux-mm@kvack.org>; Tue, 17 Mar 2009 01:18:40 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2H5Ibcv004939
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 17 Mar 2009 14:18:38 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id B78AF45DD7E
	for <linux-mm@kvack.org>; Tue, 17 Mar 2009 14:18:37 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 96F4D45DD78
	for <linux-mm@kvack.org>; Tue, 17 Mar 2009 14:18:37 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 73AE11DB8040
	for <linux-mm@kvack.org>; Tue, 17 Mar 2009 14:18:37 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 200DD1DB803E
	for <linux-mm@kvack.org>; Tue, 17 Mar 2009 14:18:37 +0900 (JST)
Date: Tue, 17 Mar 2009 14:17:14 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 4/4] Memory controller soft limit reclaim on contention
 (v6)
Message-Id: <20090317141714.0899baec.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090317045850.GJ16897@balbir.in.ibm.com>
References: <20090316174943.53ec8196.kamezawa.hiroyu@jp.fujitsu.com>
	<20090316180308.6be6b8a2.kamezawa.hiroyu@jp.fujitsu.com>
	<20090316091024.GX16897@balbir.in.ibm.com>
	<2217159d612e4e4d3fcbd50354e53f5b.squirrel@webmail-b.css.fujitsu.com>
	<20090316113853.GA16897@balbir.in.ibm.com>
	<969730ee419be9fbe4aca3ec3249650e.squirrel@webmail-b.css.fujitsu.com>
	<20090316121915.GB16897@balbir.in.ibm.com>
	<20090317124740.d8356d01.kamezawa.hiroyu@jp.fujitsu.com>
	<20090317044016.GG16897@balbir.in.ibm.com>
	<20090317134727.62efc14e.kamezawa.hiroyu@jp.fujitsu.com>
	<20090317045850.GJ16897@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: linux-mm@kvack.org, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, 17 Mar 2009 10:28:50 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-03-17 13:47:27]:
> 
> > On Tue, 17 Mar 2009 10:10:16 +0530
> > Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > 
> > > >   - vm.softlimit_ratio
> > > > 
> > > > If vm.softlimit_ratio = 99%, 
> > > >   when sum of all usage of memcg is over 99% of system memory,
> > > >   softlimit runs and reclaim memory until the whole usage will be below 99%.
> > > >    (or some other trigger can be considered.)
> > > > 
> > > > Then,
> > > >  - We don't have to take care of misc. complicated aspects of memory reclaiming
> > > >    We reclaim memory based on our own logic, then, no influence to global LRU.
> > > > 
> > > > I think this approach will hide the all corner case and make merging softlimit 
> > > > to mainline much easier. If you use this approach, RB-tree is the best one
> > > > to go with (and we don't have to care zone's status.)
> > > 
> > > I like the idea in general, but I have concerns about
> > > 
> > > 1. Tracking all cgroup memory, it can quickly get expensive (tracking
> > > to check for vm.soft_limit_ratio and for usage)
> > 
> > Not so expensive because we already tracks them all by default cgroup.
> > Then, what we need is "fast" counter.
> > Maybe percpu coutner (lib/percpu_counter.c) gives us enough codes for counting.
> >
> > Checking value ratio is ...how about "once per 1000 increment per cpu" or some ?
> 
> That is not true..we don't track them to default cgroup unless
> memory.use_hiearchy is enabled in the root cgroup. 
What I want to say is "the task which is not attached to user's cgroup is
also under defaut cgroup, so we don't need additional hook"
Not talking about hierarchy.

> To do what you
> suggest, we have to iterate through all mem cgroups, which is not
> desirable at all.

I don't say percpu counter should be within struct mem_cgroup.
DEFINE_PERCPU(overall_usage);
is enough, for example. (just an example.)

Or we already have vmstat (see vmstat.h:: global_page_state())

== si_meminfo()==
 val->freeram = global_page_state(NR_FREE_PAGES);
==

It seems we have what we need already. (but usage from this includes usage comes
from slab, page table, etc...)


> > 
> > > 2. Finding a good default for the sysctl (might not be so hard)
> > > 
> > I think some parameter like high-low watermark is good and we can find
> > good value as
> >   - low watermak .... max_memory - (sum of all zone->high) * 16 of memory.
> >   - high watermark .... max_memory - (sum_of all zone->high) * 8
> > (just an example but not so bad.)
> >
> 
> OK..
> 
> [offtopic] I liked the per-mem cgroup watermark patches as well. I
> think we should look at them later on, after soft limits and some other items.
>  
I'm glad if we can reuse logics added by softlimit by per memcg watermarks.

> > > Even today our influence on global LRU is very limited, only when we
> > > come under reclaim, we do an additional step of seeing if we can get
> > > memory from soft limit groups first.
> > > 
> > > (1) is a real concern.
> > 
> > Maybe yes. But all memcg will call "charge" "uncharge" codes so, problem is
> > just "counter". I think percpu coutner works enough.
> >
> 
> This scheme adds more overhead due to (1), we'll need a global counter
> and need to protect it, which will serialize all res_counters. 
> 
It's not necessary. for example, reading vmstat doesn't need global lock.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
