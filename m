Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id BE6058D003B
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 23:42:07 -0400 (EDT)
Message-ID: <4DB24A62.7060602@redhat.com>
Date: Fri, 22 Apr 2011 23:41:22 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH V6 00/10] memcg: per cgroup background reclaim
References: <1303185466-2532-1-git-send-email-yinghan@google.com>	<20110421025107.GG2333@cmpxchg.org>	<20110421130016.3333cb39.kamezawa.hiroyu@jp.fujitsu.com>	<20110421050851.GI2333@cmpxchg.org>	<BANLkTimUQjW_XVdzoLJJwwFDuFvm=Qg_FA@mail.gmail.com>	<20110423013534.GK2333@cmpxchg.org>	<BANLkTi=UgLihmoRwdA4E4MXmGc4BmqkqTg@mail.gmail.com>	<20110423023407.GN2333@cmpxchg.org> <BANLkTimwMcBwTvi8aNDPXkS_Vu+bxdciMg@mail.gmail.com>
In-Reply-To: <BANLkTimwMcBwTvi8aNDPXkS_Vu+bxdciMg@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

On 04/22/2011 11:33 PM, Ying Han wrote:

> Now we would like to launch another job C, since we know there are A(16G
> - 10G) + B(16G - 10G)  = 12G "cold" memory can be reclaimed (w/o
> impacting the A and B's performance). So what will happen
>
> 1. start running C on the host, which triggers global memory pressure
> right away. If the reclaim is fast, C start growing with the free pages
> from A and B.
>
> However, it might be possible that the reclaim can not catch-up with the
> job's page allocation. We end up with either OOM condition or
> performance spike on any of the running jobs.
>
> One way to improve it is to set a wmark on either A/B to be proactively
> reclaiming pages before launching C. The global memory pressure won't
> help much here since we won't trigger that.
>
>     min_free_kbytes more or less indirectly provides the same on a global
>     level, but I don't think anybody tunes it just for aggressiveness of
>     background reclaim.

This sounds like yet another reason to have a tunable that
can increase the gap between min_free_kbytes and low_free_kbytes
(automatically scaled to size in every zone).

The realtime people want this to reduce allocation latencies.

I want it for dynamic virtual machine resizing, without the
memory fragmentation inherent in balloons (which would destroy
the performance benefit of transparent hugepages).

Now Google wants it for job placement.

Is there any good reason we can't have a low watermark
equivalent to min_free_kbytes? :)

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
