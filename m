Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 734C08D003B
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 00:07:01 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 19E523EE0C0
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 13:06:58 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id F069B45DE53
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 13:06:57 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id B596845DE50
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 13:06:57 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id A9A84E78005
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 13:06:57 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 5B5F31DB803F
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 13:06:57 +0900 (JST)
Date: Thu, 21 Apr 2011 13:00:16 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH V6 00/10] memcg: per cgroup background reclaim
Message-Id: <20110421130016.3333cb39.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110421025107.GG2333@cmpxchg.org>
References: <1303185466-2532-1-git-send-email-yinghan@google.com>
	<20110421025107.GG2333@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Ying Han <yinghan@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

On Thu, 21 Apr 2011 04:51:07 +0200
Johannes Weiner <hannes@cmpxchg.org> wrote:

> > If the cgroup is configured to use per cgroup background reclaim, a kswapd
> > thread is created which only scans the per-memcg LRU list.
> 
> We already have direct reclaim, direct reclaim on behalf of a memcg,
> and global kswapd-reclaim.  Please don't add yet another reclaim path
> that does its own thing and interacts unpredictably with the rest of
> them.
> 
> As discussed on LSF, we want to get rid of the global LRU.  So the
> goal is to have each reclaim entry end up at the same core part of
> reclaim that round-robin scans a subset of zones from a subset of
> memory control groups.
> 

It's not related to this set. And I think even if we remove global LRU,
global-kswapd and memcg-kswapd need to do independent work.

global-kswapd : works for zone/node balancing and making free pages,
                and compaction. select a memcg vicitm and ask it
                to reduce memory with regard to gfp_mask. Starts its work
                when zone/node is unbalanced.

memcg-kswapd  : works for reducing usage of memory, no interests on
                zone/nodes. Starts when high/low watermaks hits.

We can share 'recalim_memcg_this_zone()' code finally, but it can be
changed when we remove global LRU. 


> > Two watermarks ("high_wmark", "low_wmark") are added to trigger the
> > background reclaim and stop it. The watermarks are calculated based
> > on the cgroup's limit_in_bytes.
> 
> Which brings me to the next issue: making the watermarks configurable.
> 
> You argued that having them adjustable from userspace is required for
> overcommitting the hardlimits and per-memcg kswapd reclaim not kicking
> in in case of global memory pressure.  But that is only a problem
> because global kswapd reclaim is (apart from soft limit reclaim)
> unaware of memory control groups.
> 
> I think the much better solution is to make global kswapd memcg aware
> (with the above mentioned round-robin reclaim scheduler), compared to
> adding new (and final!) kernel ABI to avoid an internal shortcoming.
> 

I don't think its a good idea to kick kswapd even when free memory is enough.

If memcg-kswapd implemted, I'd like to add auto-cgroup for memcg-kswapd and
limit its cpu usage because it works even when memory is not in-short.


Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
