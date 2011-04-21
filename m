Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 2E4588D003B
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 22:52:40 -0400 (EDT)
Date: Thu, 21 Apr 2011 04:51:07 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH V6 00/10] memcg: per cgroup background reclaim
Message-ID: <20110421025107.GG2333@cmpxchg.org>
References: <1303185466-2532-1-git-send-email-yinghan@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1303185466-2532-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

Hello Ying,

I'm sorry that I chime in so late, I was still traveling until Monday.

On Mon, Apr 18, 2011 at 08:57:36PM -0700, Ying Han wrote:
> The current implementation of memcg supports targeting reclaim when the
> cgroup is reaching its hard_limit and we do direct reclaim per cgroup.
> Per cgroup background reclaim is needed which helps to spread out memory
> pressure over longer period of time and smoothes out the cgroup performance.

Latency reduction makes perfect sense, the reasons kswapd exists apply
to memory control groups as well.  But I disagree with the design
choices you made.

> If the cgroup is configured to use per cgroup background reclaim, a kswapd
> thread is created which only scans the per-memcg LRU list.

We already have direct reclaim, direct reclaim on behalf of a memcg,
and global kswapd-reclaim.  Please don't add yet another reclaim path
that does its own thing and interacts unpredictably with the rest of
them.

As discussed on LSF, we want to get rid of the global LRU.  So the
goal is to have each reclaim entry end up at the same core part of
reclaim that round-robin scans a subset of zones from a subset of
memory control groups.

> Two watermarks ("high_wmark", "low_wmark") are added to trigger the
> background reclaim and stop it. The watermarks are calculated based
> on the cgroup's limit_in_bytes.

Which brings me to the next issue: making the watermarks configurable.

You argued that having them adjustable from userspace is required for
overcommitting the hardlimits and per-memcg kswapd reclaim not kicking
in in case of global memory pressure.  But that is only a problem
because global kswapd reclaim is (apart from soft limit reclaim)
unaware of memory control groups.

I think the much better solution is to make global kswapd memcg aware
(with the above mentioned round-robin reclaim scheduler), compared to
adding new (and final!) kernel ABI to avoid an internal shortcoming.

The whole excercise of asynchroneous background reclaim is to reduce
reclaim latency.  We already have a mechanism for global memory
pressure in place.  Per-memcg watermarks should only exist to avoid
direct reclaim due to hitting the hardlimit, nothing else.

So in summary, I think converting the reclaim core to this round-robin
scheduler solves all these problems at once: a single code path for
reclaim, breaking up of the global lru lock, fair soft limit reclaim,
and a mechanism for latency reduction that just DTRT without any
user-space configuration necessary.

	Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
