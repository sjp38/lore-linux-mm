Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id E1748900086
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 05:40:49 -0400 (EDT)
Date: Fri, 15 Apr 2011 11:40:40 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH V4 00/10] memcg: per cgroup background reclaim
Message-ID: <20110415094040.GC8828@tiehlicka.suse.cz>
References: <1302821669-29862-1-git-send-email-yinghan@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1302821669-29862-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

Hi Ying,
sorry that I am jumping into game that late but I was quite busy after
returning back from LSF and LFCS.

On Thu 14-04-11 15:54:19, Ying Han wrote:
> The current implementation of memcg supports targeting reclaim when the
> cgroup is reaching its hard_limit and we do direct reclaim per cgroup.
> Per cgroup background reclaim is needed which helps to spread out memory
> pressure over longer period of time and smoothes out the cgroup performance.
> 
> If the cgroup is configured to use per cgroup background reclaim, a kswapd
> thread is created which only scans the per-memcg LRU list. 

Hmm, I am wondering if this fits into the get-rid-of-the-global-LRU
strategy. If we make the background reclaim per-cgroup how do we balance
from the global/zone POV? We can end up with all groups over the high
limit while a memory zone is under this watermark. Or am I missing
something?
I thought that plans for the background reclaim were same as for direct
reclaim so that kswapd would just evict pages from groups in the
round-robin fashion (in first round just those that are under limit and
proportionally when it cannot reach high watermark after it got through
all groups).

> Two watermarks ("high_wmark", "low_wmark") are added to trigger the
> background reclaim and stop it. The watermarks are calculated based on
> the cgroup's limit_in_bytes.

I didn't have time to look at the patch how does the calculation work
yet but we should be careful to match the zone's watermark expectations.

> By default, the per-memcg kswapd threads are running under root cgroup. There
> is a per-memcg API which exports the pid of each kswapd thread, and userspace
> can configure cpu cgroup seperately.
> 
> I run through dd test on large file and then cat the file. Then I compared
> the reclaim related stats in memory.stat.
> 
> Step1: Create a cgroup with 500M memory_limit.
> $ mkdir /dev/cgroup/memory/A
> $ echo 500m >/dev/cgroup/memory/A/memory.limit_in_bytes
> $ echo $$ >/dev/cgroup/memory/A/tasks
> 
> Step2: Test and set the wmarks.
> $ cat /dev/cgroup/memory/A/memory.low_wmark_distance
> 0
> $ cat /dev/cgroup/memory/A/memory.high_wmark_distance
> 0

I remember that there was a resistance against exporting watermarks as
they are kernel internal thing.

> 
> $ cat /dev/cgroup/memory/A/memory.reclaim_wmarks
> low_wmark 524288000
> high_wmark 524288000
> 
> $ echo 50m >/dev/cgroup/memory/A/memory.high_wmark_distance
> $ echo 40m >/dev/cgroup/memory/A/memory.low_wmark_distance
> 
> $ cat /dev/cgroup/memory/A/memory.reclaim_wmarks
> low_wmark  482344960
> high_wmark 471859200

low_wmark is higher than high_wmark?

[...]
> Note:
> This is the first effort of enhancing the target reclaim into memcg. Here are
> the existing known issues and our plan:
> 
> 1. there are one kswapd thread per cgroup. the thread is created when the
> cgroup changes its limit_in_bytes and is deleted when the cgroup is being
> removed. In some enviroment when thousand of cgroups are being configured on
> a single host, we will have thousand of kswapd threads. The memory consumption
> would be 8k*100 = 8M. We don't see a big issue for now if the host can host
> that many of cgroups.

I think that zone background reclaim is much bigger issue than 8k per
kernel thread and too many threads... 
I am not sure how much orthogonal per-cgroup-per-thread vs. zone
approaches are, though.  Maybe it makes some sense to do both per-cgroup
and zone background reclaim.  Anyway I think that we should start with
the zone reclaim first.

[...]

> 4. no hierarchical reclaim support in this patchset. I would like to get to
> after the basic stuff are being accepted.

Just an idea.
If we did that from zone's POV then we could call mem_cgroup_hierarchical_reclaim,
right?

[...]

Thanks
-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
