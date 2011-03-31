Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id AAC868D0040
	for <linux-mm@kvack.org>; Thu, 31 Mar 2011 01:40:39 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id B8DAB3EE0BD
	for <linux-mm@kvack.org>; Thu, 31 Mar 2011 14:40:34 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 998F345DE55
	for <linux-mm@kvack.org>; Thu, 31 Mar 2011 14:40:34 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 7C42F45DE59
	for <linux-mm@kvack.org>; Thu, 31 Mar 2011 14:40:34 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6EA501DB803F
	for <linux-mm@kvack.org>; Thu, 31 Mar 2011 14:40:34 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 2EC6E1DB803C
	for <linux-mm@kvack.org>; Thu, 31 Mar 2011 14:40:34 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 0/3] Unmapped page cache control (v5)
In-Reply-To: <20110330052819.8212.1359.stgit@localhost6.localdomain6>
References: <20110330052819.8212.1359.stgit@localhost6.localdomain6>
Message-Id: <20110331144145.0ECA.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Date: Thu, 31 Mar 2011 14:40:33 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, akpm@linux-foundation.org, npiggin@kernel.dk, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, cl@linux.com, kamezawa.hiroyu@jp.fujitsu.com, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan.kim@gmail.com>

> 
> The following series implements page cache control,
> this is a split out version of patch 1 of version 3 of the
> page cache optimization patches posted earlier at
> Previous posting http://lwn.net/Articles/425851/ and analysis
> at http://lwn.net/Articles/419713/
> 
> Detailed Description
> ====================
> This patch implements unmapped page cache control via preferred
> page cache reclaim. The current patch hooks into kswapd and reclaims
> page cache if the user has requested for unmapped page control.
> This is useful in the following scenario
> - In a virtualized environment with cache=writethrough, we see
>   double caching - (one in the host and one in the guest). As
>   we try to scale guests, cache usage across the system grows.
>   The goal of this patch is to reclaim page cache when Linux is running
>   as a guest and get the host to hold the page cache and manage it.
>   There might be temporary duplication, but in the long run, memory
>   in the guests would be used for mapped pages.
>
> - The option is controlled via a boot option and the administrator
>   can selectively turn it on, on a need to use basis.
> 
> A lot of the code is borrowed from zone_reclaim_mode logic for
> __zone_reclaim(). One might argue that the with ballooning and
> KSM this feature is not very useful, but even with ballooning,
> we need extra logic to balloon multiple VM machines and it is hard
> to figure out the correct amount of memory to balloon. With these
> patches applied, each guest has a sufficient amount of free memory
> available, that can be easily seen and reclaimed by the balloon driver.
> The additional memory in the guest can be reused for additional
> applications or used to start additional guests/balance memory in
> the host.

If anyone think this series works, They are just crazy. This patch reintroduce
two old issues.

1) zone reclaim doesn't work if the system has multiple node and the
   workload is file cache oriented (eg file server, web server, mail server, et al). 
   because zone recliam make some much free pages than zone->pages_min and
   then new page cache request consume nearest node memory and then it
   bring next zone reclaim. Then, memory utilization is reduced and
   unnecessary LRU discard is increased dramatically.

   SGI folks added CPUSET specific solution in past. (cpuset.memory_spread_page)
   But global recliam still have its issue. zone recliam is HPC workload specific 
   feature and HPC folks has no motivation to don't use CPUSET.

2) Before 2.6.27, VM has only one LRU and calc_reclaim_mapped() is used to
   decide to filter out mapped pages. It made a lot of problems for DB servers
   and large application servers. Because, if the system has a lot of mapped
   pages, 1) LRU was churned and then reclaim algorithm become lotree one. 2)
   reclaim latency become terribly slow and hangup detectors misdetect its
   state and start to force reboot. That was big problem of RHEL5 based banking
   system.
   So, sc->may_unmap should be killed in future. Don't increase uses.

And, this patch introduce new allocator fast path overhead. I haven't seen
any justification for it.

In other words, you have to kill following three for getting ack 1) zone 
reclaim oriented reclaim 2) filter based LRU scanning (eg sc->may_unmap)
3) fastpath overhead. In other words, If you want a feature for vm guest,
Any hardcoded machine configration assumption and/or workload assumption 
are wrong.




But, I agree that now we have to concern slightly large VM change parhaps
(or parhaps not). Ok, it's good opportunity to fill out some thing.
Historically, Linux MM has "free memory are waste memory" policy, and It
worked completely fine. But now we have a few exceptions.

1) RT, embedded and finance systems. They really hope to avoid reclaim
   latency (ie avoid foreground reclaim completely) and they can accept 
   to make slightly much free pages before memory shortage.

2) VM guest
   VM host and VM guest naturally makes two level page cache model. and
   Linux page cache + two level don't work fine. It has two issues
   1) hard to visualize real memory consumption. That makes harder to 
      works baloon fine. And google want to visualize memory utilization
      to pack in more jobs.
   2) hard to make in kernel memory utilization improvement mechanism.


And, now we have four proposal of utilization related issues.

1) cleancache (from Oracle)
2) VirtFS (from IBM)
3) kstaled (from Google)
4) unmapped page reclaim (from you)

Probably, we can't merge all of them and we need to consolidate some 
requirement and implementations.


cleancache seems most straight forward two level cache handling for
virtalization. but it has soem xen specific mess and, currently, don't fit RT
usage. VirtFS has another interesting de-duplication idea. But filesystem based
implemenation naturally inherit some vfs interface limitations.
Google approach is more unique. memcg don't have double cache
issue, therefore they only want to visualize it.

Personally I think cleancache or other multi level page cache framework
looks promising. but another solution is also acceptable. Anyway, I hope 
to everyone back 1000feet bird eye at once and sorting out all requiremnt 
with all related person. 


> 
> KSM currently does not de-duplicate host and guest page cache. The goal
> of this patch is to help automatically balance unmapped page cache when
> instructed to do so.
>
> The sysctl for min_unmapped_ratio provides further control from
> within the guest on the amount of unmapped pages to reclaim, a similar
> max_unmapped_ratio sysctl is added and helps in the decision making
> process of when reclaim should occur. This is tunable and set by
> default to 16 (based on tradeoff's seen between aggressiveness in
> balancing versus size of unmapped pages). Distro's and administrators
> can further tweak this for desired control.
> 
> Data from the previous patchsets can be found at
> https://lkml.org/lkml/2010/11/30/79
> 
> ---
> 
> Balbir Singh (3):
>       Move zone_reclaim() outside of CONFIG_NUMA
>       Refactor zone_reclaim code
>       Provide control over unmapped pages
> 
> 
>  Documentation/kernel-parameters.txt |    8 ++
>  Documentation/sysctl/vm.txt         |   19 +++++
>  include/linux/mmzone.h              |   11 +++
>  include/linux/swap.h                |   25 ++++++-
>  init/Kconfig                        |   12 +++
>  kernel/sysctl.c                     |   29 ++++++--
>  mm/page_alloc.c                     |   35 +++++++++-
>  mm/vmscan.c                         |  123 +++++++++++++++++++++++++++++++----
>  8 files changed, 229 insertions(+), 33 deletions(-)




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
