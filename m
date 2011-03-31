Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 31F858D0040
	for <linux-mm@kvack.org>; Wed, 30 Mar 2011 22:32:11 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 577033EE0BD
	for <linux-mm@kvack.org>; Thu, 31 Mar 2011 11:32:06 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3BB7645DE68
	for <linux-mm@kvack.org>; Thu, 31 Mar 2011 11:32:06 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2251C45DD73
	for <linux-mm@kvack.org>; Thu, 31 Mar 2011 11:32:06 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 146E9E08002
	for <linux-mm@kvack.org>; Thu, 31 Mar 2011 11:32:06 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id D24FE1DB8038
	for <linux-mm@kvack.org>; Thu, 31 Mar 2011 11:32:05 +0900 (JST)
Date: Thu, 31 Mar 2011 11:25:32 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] memcg: isolate pages in memcg lru from global lru
Message-Id: <20110331112532.82ed25ad.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1301532498-20309-1-git-send-email-yinghan@google.com>
References: <1301532498-20309-1-git-send-email-yinghan@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Li Zefan <lizf@cn.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Mel Gorman <mel@csn.ul.ie>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

On Wed, 30 Mar 2011 17:48:18 -0700
Ying Han <yinghan@google.com> wrote:

> In memory controller, we do both targeting reclaim and global reclaim. The
> later one walks through the global lru which links all the allocated pages
> on the system. It breaks the memory isolation since pages are evicted
> regardless of their memcg owners. This patch takes pages off global lru
> as long as they are added to per-memcg lru.
> 
> Memcg and cgroup together provide the solution of memory isolation where
> multiple cgroups run in parallel without interfering with each other. In
> vm, memory isolation requires changes in both page allocation and page
> reclaim. The current memcg provides good user page accounting, but need
> more work on the page reclaim.
> 
> In an over-committed machine w/ 32G ram, here is the configuration:
> 
> cgroup-A/  -- limit_in_bytes = 20G, soft_limit_in_bytes = 15G
> cgroup-B/  -- limit_in_bytes = 20G, soft_limit_in_bytes = 15G
> 
> 1) limit_in_bytes is the hard_limit where process will be throttled or OOM
> killed by going over the limit.
> 2) memory between soft_limit and limit_in_bytes are best-effort. soft_limit
> provides "guarantee" in some sense.
> 
> Then, it is easy to generate the following senario where:
> 
> cgroup-A/  -- usage_in_bytes = 20G
> cgroup-B/  -- usage_in_bytes = 12G
> 
> The global memory pressure triggers while cgroup-A keep allocating memory. At
> this point, pages belongs to cgroup-B can be evicted from global LRU.
> 
> We do have per-memcg targeting reclaim including per-memcg background reclaim
> and soft_limit reclaim. Both of them need some improvement, and regardless we
> still need this patch since it breaks isolation.
> 
> Besides, here is to-do list I have on memcg page reclaim and they are sorted.
> a) per-memcg background reclaim. to reclaim pages proactively
agree,

> b) skipping global lru reclaim if soft_limit reclaim does enough work. this is
> both for global background reclaim and global ttfp reclaim.

agree. but zone-balancing cannot be avoidalble for now. So, I think we need a
inter-zone-page-migration to balancing memory between zones...if necessary.


> c) improve the soft_limit reclaim to be efficient.

must be done.

> d) isolate pages in memcg from global list since it breaks memory isolation.
> 

I never agree this until about a),b),c) is fixed and we can go nowhere.

BTW, in other POV, for reducing size of page_cgroup, we must remove ->lru
on page_cgroup. If divide-and-conquer memory reclaim works enough,
we can do that. But this is a big global VM change, so we need enough
justification.



> I have some basic test on this patch and more tests definitely are needed:
> 

> Functional:
> two memcgs under root. cgroup-A is reading 20g file with 2g limit,
> cgroup-B is running random stuff with 500m limit. Check the counters for
> per-memcg lru and global lru, and they should add-up.
> 
> 1) total file pages
> $ cat /proc/meminfo | grep Cache
> Cached:          6032128 kB
> 
> 2) file lru on global lru
> $ cat /proc/vmstat | grep file
> nr_inactive_file 0
> nr_active_file 963131
> 
> 3) file lru on root cgroup
> $ cat /dev/cgroup/memory.stat | grep file
> inactive_file 0
> active_file 0
> 
> 4) file lru on cgroup-A
> $ cat /dev/cgroup/A/memory.stat | grep file
> inactive_file 2145759232
> active_file 0
> 
> 5) file lru on cgroup-B
> $ cat /dev/cgroup/B/memory.stat | grep file
> inactive_file 401408
> active_file 143360
> 
> Performance:
> run page fault test(pft) with 16 thread on faulting in 15G anon pages
> in 16G cgroup. There is no regression noticed on "flt/cpu/s"
> 

You need a fix for /proc/meminfo, /proc/vmstat to count memcg's ;)

Anyway, this seems too aggresive to me, for now. Please do a), b), c), at first.

IIUC, this patch itself can cause a livelock when softlimit is misconfigured.
What is the protection against wrong softlimit  ? 

If we do this kind of LRU isolation, we'll need some limitation of the sum of
limits of all memcg for avoiding wrong configuration. That may change UI, dramatically.
(As RT-class cpu limiting cgroup does.....)

Anyway, thank you for data.

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
