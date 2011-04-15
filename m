Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 013A2900086
	for <linux-mm@kvack.org>; Thu, 14 Apr 2011 20:31:58 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 72FD83EE0BD
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 09:31:56 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 59AF945DE54
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 09:31:56 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 40C7B45DE4F
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 09:31:56 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3266F1DB803F
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 09:31:56 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id E67121DB8037
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 09:31:55 +0900 (JST)
Date: Fri, 15 Apr 2011 09:25:19 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH V4 03/10] New APIs to adjust per-memcg wmarks
Message-Id: <20110415092519.a164e8f3.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1302821669-29862-4-git-send-email-yinghan@google.com>
References: <1302821669-29862-1-git-send-email-yinghan@google.com>
	<1302821669-29862-4-git-send-email-yinghan@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

On Thu, 14 Apr 2011 15:54:22 -0700
Ying Han <yinghan@google.com> wrote:

> Add memory.low_wmark_distance, memory.high_wmark_distance and reclaim_wmarks
> APIs per-memcg. The first two adjust the internal low/high wmark calculation
> and the reclaim_wmarks exports the current value of watermarks.
> 
> By default, the low/high_wmark is calculated by subtracting the distance from
> the hard_limit(limit_in_bytes).
> 
> $ echo 500m >/dev/cgroup/A/memory.limit_in_bytes
> $ cat /dev/cgroup/A/memory.limit_in_bytes
> 524288000
> 
> $ echo 50m >/dev/cgroup/A/memory.high_wmark_distance
> $ echo 40m >/dev/cgroup/A/memory.low_wmark_distance
> 
> $ cat /dev/cgroup/A/memory.reclaim_wmarks
> low_wmark 482344960
> high_wmark 471859200
> 
> changelog v4..v3:
> 1. replace the "wmark_ratio" API with individual tunable for low/high_wmarks.
> 
> changelog v3..v2:
> 1. replace the "min_free_kbytes" api with "wmark_ratio". This is part of
> feedbacks
> 
> Signed-off-by: Ying Han <yinghan@google.com>

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

But please add a sanity check (see below.)



> ---
>  mm/memcontrol.c |   95 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
>  1 files changed, 95 insertions(+), 0 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 1ec4014..685645c 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -3974,6 +3974,72 @@ static int mem_cgroup_swappiness_write(struct cgroup *cgrp, struct cftype *cft,
>  	return 0;
>  }
>  
> +static u64 mem_cgroup_high_wmark_distance_read(struct cgroup *cgrp,
> +					       struct cftype *cft)
> +{
> +	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
> +
> +	return memcg->high_wmark_distance;
> +}
> +
> +static u64 mem_cgroup_low_wmark_distance_read(struct cgroup *cgrp,
> +					      struct cftype *cft)
> +{
> +	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
> +
> +	return memcg->low_wmark_distance;
> +}
> +
> +static int mem_cgroup_high_wmark_distance_write(struct cgroup *cont,
> +						struct cftype *cft,
> +						const char *buffer)
> +{
> +	struct mem_cgroup *memcg = mem_cgroup_from_cont(cont);
> +	u64 low_wmark_distance = memcg->low_wmark_distance;
> +	unsigned long long val;
> +	u64 limit;
> +	int ret;
> +
> +	ret = res_counter_memparse_write_strategy(buffer, &val);
> +	if (ret)
> +		return -EINVAL;
> +
> +	limit = res_counter_read_u64(&memcg->res, RES_LIMIT);
> +	if ((val >= limit) || (val < low_wmark_distance) ||
> +	   (low_wmark_distance && val == low_wmark_distance))
> +		return -EINVAL;
> +
> +	memcg->high_wmark_distance = val;
> +
> +	setup_per_memcg_wmarks(memcg);
> +	return 0;
> +}

IIUC, as limit_in_bytes, 'distance' should not be able to set against ROOT memcg
because it doesn't work.



> +
> +static int mem_cgroup_low_wmark_distance_write(struct cgroup *cont,
> +					       struct cftype *cft,
> +					       const char *buffer)
> +{
> +	struct mem_cgroup *memcg = mem_cgroup_from_cont(cont);
> +	u64 high_wmark_distance = memcg->high_wmark_distance;
> +	unsigned long long val;
> +	u64 limit;
> +	int ret;
> +
> +	ret = res_counter_memparse_write_strategy(buffer, &val);
> +	if (ret)
> +		return -EINVAL;
> +
> +	limit = res_counter_read_u64(&memcg->res, RES_LIMIT);
> +	if ((val >= limit) || (val > high_wmark_distance) ||
> +	    (high_wmark_distance && val == high_wmark_distance))
> +		return -EINVAL;
> +
> +	memcg->low_wmark_distance = val;
> +
> +	setup_per_memcg_wmarks(memcg);
> +	return 0;
> +}
> +

Here, too.

I wonder we should have a method to hide unnecessary interfaces in ROOT cgroup...

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
