Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id E5EB06B009E
	for <linux-mm@kvack.org>; Sun,  5 Dec 2010 00:14:21 -0500 (EST)
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by e28smtp06.in.ibm.com (8.14.4/8.13.1) with ESMTP id oB55EGgv011776
	for <linux-mm@kvack.org>; Sun, 5 Dec 2010 10:44:16 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id oB55EFJA4087998
	for <linux-mm@kvack.org>; Sun, 5 Dec 2010 10:44:16 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id oB55EE7R022888
	for <linux-mm@kvack.org>; Sun, 5 Dec 2010 10:44:15 +0530
Date: Thu, 2 Dec 2010 20:11:32 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC][PATCH 0/4] memcg: per cgroup background reclaim
Message-ID: <20101202144132.GR2746@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <1291099785-5433-1-git-send-email-yinghan@google.com>
 <20101130155327.8313.A69D9226@jp.fujitsu.com>
 <AANLkTi=idNjuptkQuiaOF+GiUDjBaBC9kW370u-041sT@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <AANLkTi=idNjuptkQuiaOF+GiUDjBaBC9kW370u-041sT@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Ying Han <yinghan@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, Wu Fengguang <fengguang.wu@intel.com>, Andi Kleen <ak@linux.intel.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

* Ying Han <yinghan@google.com> [2010-11-29 23:03:31]:

> On Mon, Nov 29, 2010 at 10:54 PM, KOSAKI Motohiro
> <kosaki.motohiro@jp.fujitsu.com> wrote:
> >> The current implementation of memcg only supports direct reclaim and this
> >> patchset adds the support for background reclaim. Per cgroup background
> >> reclaim is needed which spreads out the memory pressure over longer period
> >> of time and smoothes out the system performance.
> >>
> >> The current implementation is not a stable version, and it crashes sometimes
> >> on my NUMA machine. Before going further for debugging, I would like to start
> >> the discussion and hear the feedbacks of the initial design.
> >
> > I haven't read your code at all. However I agree your claim that memcg
> > also need background reclaim.
> 
> Thanks for your comment.
> >
> > So if you post high level design memo, I'm happy.
> 
> My high level design is kind of spreading out into each patch, and
> here is the consolidated one. This is nothing more but cluing all the
> commits' messages for the following patches.
> 
> "
> The current implementation of memcg only supports direct reclaim and this
> patchset adds the support for background reclaim. Per cgroup background
> reclaim is needed which spreads out the memory pressure over longer period
> of time and smoothes out the system performance.
> 
> There is a kswapd kernel thread for each memory node. We add a different kswapd
> for each cgroup. The kswapd is sleeping in the wait queue headed at kswapd_wait
> field of a kswapd descriptor. The kswapd descriptor stores information of node
> or cgroup and it allows the global and per cgroup background reclaim to share
> common reclaim algorithms. The per cgroup kswapd is invoked at mem_cgroup_charge
> when the cgroup's memory usage above a threshold--low_wmark. Then the kswapd
> thread starts to reclaim pages in a priority loop similar to global algorithm.
> The kswapd is done if the usage below a threshold--high_wmark.
>

So the logic is per-node/per-zone/per-cgroup right?
 
> The per cgroup background reclaim is based on the per cgroup LRU and also adds
> per cgroup watermarks. There are two watermarks including "low_wmark" and
> "high_wmark", and they are calculated based on the limit_in_bytes(hard_limit)
> for each cgroup. Each time the hard_limit is change, the corresponding wmarks
> are re-calculated. Since memory controller charges only user pages, there is

What about memsw limits, do they impact anything, I presume not.

> no need for a "min_wmark". The current calculation of wmarks is a function of
> "memory.min_free_kbytes" which could be adjusted by writing different values
> into the new api. This is added mainly for debugging purpose.

When you say debugging, can you elaborate?

> 
> The kswapd() function now is shared between global and per cgroup kswapd thread.
> It is passed in with the kswapd descriptor which contains the information of
> either node or cgroup. Then the new function balance_mem_cgroup_pgdat is invoked
> if it is per cgroup kswapd thread. The balance_mem_cgroup_pgdat performs a
> priority loop similar to global reclaim. In each iteration it invokes
> balance_pgdat_node for all nodes on the system, which is a new function performs
> background reclaim per node. After reclaiming each node, it checks
> mem_cgroup_watermark_ok() and breaks the priority loop if returns true. A per
> memcg zone will be marked as "unreclaimable" if the scanning rate is much
> greater than the reclaiming rate on the per cgroup LRU. The bit is cleared when
> there is a page charged to the cgroup being freed. Kswapd breaks the priority
> loop if all the zones are marked as "unreclaimable".
> "
> 
> Also, I am happy to add more descriptions if anything not clear :)
>

Thanks for explaining this in detail, it makes the review easier. 

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
