Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 4E72B6B003D
	for <linux-mm@kvack.org>; Tue, 17 Mar 2009 00:48:54 -0400 (EDT)
Received: from mt1.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2H4mqFn030784
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 17 Mar 2009 13:48:52 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id B982945DE55
	for <linux-mm@kvack.org>; Tue, 17 Mar 2009 13:48:51 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7D00645DE4E
	for <linux-mm@kvack.org>; Tue, 17 Mar 2009 13:48:51 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3E6C6E08005
	for <linux-mm@kvack.org>; Tue, 17 Mar 2009 13:48:51 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id E576C1DB803C
	for <linux-mm@kvack.org>; Tue, 17 Mar 2009 13:48:50 +0900 (JST)
Date: Tue, 17 Mar 2009 13:47:27 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 4/4] Memory controller soft limit reclaim on contention
 (v6)
Message-Id: <20090317134727.62efc14e.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090317044016.GG16897@balbir.in.ibm.com>
References: <20090316095258.94ae559d.kamezawa.hiroyu@jp.fujitsu.com>
	<20090316083512.GV16897@balbir.in.ibm.com>
	<20090316174943.53ec8196.kamezawa.hiroyu@jp.fujitsu.com>
	<20090316180308.6be6b8a2.kamezawa.hiroyu@jp.fujitsu.com>
	<20090316091024.GX16897@balbir.in.ibm.com>
	<2217159d612e4e4d3fcbd50354e53f5b.squirrel@webmail-b.css.fujitsu.com>
	<20090316113853.GA16897@balbir.in.ibm.com>
	<969730ee419be9fbe4aca3ec3249650e.squirrel@webmail-b.css.fujitsu.com>
	<20090316121915.GB16897@balbir.in.ibm.com>
	<20090317124740.d8356d01.kamezawa.hiroyu@jp.fujitsu.com>
	<20090317044016.GG16897@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: linux-mm@kvack.org, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, 17 Mar 2009 10:10:16 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> >   - vm.softlimit_ratio
> > 
> > If vm.softlimit_ratio = 99%, 
> >   when sum of all usage of memcg is over 99% of system memory,
> >   softlimit runs and reclaim memory until the whole usage will be below 99%.
> >    (or some other trigger can be considered.)
> > 
> > Then,
> >  - We don't have to take care of misc. complicated aspects of memory reclaiming
> >    We reclaim memory based on our own logic, then, no influence to global LRU.
> > 
> > I think this approach will hide the all corner case and make merging softlimit 
> > to mainline much easier. If you use this approach, RB-tree is the best one
> > to go with (and we don't have to care zone's status.)
> 
> I like the idea in general, but I have concerns about
> 
> 1. Tracking all cgroup memory, it can quickly get expensive (tracking
> to check for vm.soft_limit_ratio and for usage)

Not so expensive because we already tracks them all by default cgroup.
Then, what we need is "fast" counter.
Maybe percpu coutner (lib/percpu_counter.c) gives us enough codes for counting.

Checking value ratio is ...how about "once per 1000 increment per cpu" or some ?

> 2. Finding a good default for the sysctl (might not be so hard)
> 
I think some parameter like high-low watermark is good and we can find
good value as
  - low watermak .... max_memory - (sum of all zone->high) * 16 of memory.
  - high watermark .... max_memory - (sum_of all zone->high) * 8
(just an example but not so bad.)

> Even today our influence on global LRU is very limited, only when we
> come under reclaim, we do an additional step of seeing if we can get
> memory from soft limit groups first.
> 
> (1) is a real concern.

Maybe yes. But all memcg will call "charge" "uncharge" codes so, problem is
just "counter". I think percpu coutner works enough.

Thanks,
-Kame 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
