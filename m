Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id 5FDEF6B0092
	for <linux-mm@kvack.org>; Thu,  8 Mar 2012 01:16:56 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id F0C8D3EE0C1
	for <linux-mm@kvack.org>; Thu,  8 Mar 2012 15:16:54 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id D720A45DEB3
	for <linux-mm@kvack.org>; Thu,  8 Mar 2012 15:16:54 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id BFE9D45DEAD
	for <linux-mm@kvack.org>; Thu,  8 Mar 2012 15:16:54 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id B3DA91DB803F
	for <linux-mm@kvack.org>; Thu,  8 Mar 2012 15:16:54 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6808B1DB803B
	for <linux-mm@kvack.org>; Thu,  8 Mar 2012 15:16:54 +0900 (JST)
Date: Thu, 8 Mar 2012 15:15:21 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch] mm, memcg: do not allow tasks to be attached with zero
 limit
Message-Id: <20120308151521.82187123.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.1203071914150.15244@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1203071914150.15244@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, cgroups@vger.kernel.org, linux-mm@kvack.org

On Wed, 7 Mar 2012 19:14:49 -0800 (PST)
David Rientjes <rientjes@google.com> wrote:

> This patch prevents tasks from being attached to a memcg if there is a
> hard limit of zero.  Additionally, the hard limit may not be changed to
> zero if there are tasks attached.
> 
> This is consistent with cpusets which do not allow tasks to be attached
> if there are no mems and prevents all mems from being removed if there
> are tasks attached.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>

I hope Documenation/cgroup/memory.txt should be updated and make this behavior as 'spec'.

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


> ---
>  mm/memcontrol.c |   13 +++++++++++--
>  1 file changed, 11 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -3868,9 +3868,14 @@ static int mem_cgroup_write(struct cgroup *cont, struct cftype *cft,
>  		ret = res_counter_memparse_write_strategy(buffer, &val);
>  		if (ret)
>  			break;
> -		if (type == _MEM)
> +		if (type == _MEM) {
> +			/* Don't allow zero limit with tasks attached */
> +			if (!val && cgroup_task_count(cont)) {
> +				ret = -ENOSPC;
> +				break;
> +			}
>  			ret = mem_cgroup_resize_limit(memcg, val);
> -		else
> +		} else
>  			ret = mem_cgroup_resize_memsw_limit(memcg, val);
>  		break;
>  	case RES_SOFT_LIMIT:
> @@ -5306,6 +5311,10 @@ static int mem_cgroup_can_attach(struct cgroup_subsys *ss,
>  	int ret = 0;
>  	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgroup);
>  
> +	/* Don't allow tasks attached with a zero limit */
> +	if (!res_counter_read_u64(&memcg->res, RES_LIMIT))
> +		return -ENOSPC;
> +
>  	if (memcg->move_charge_at_immigrate) {
>  		struct mm_struct *mm;
>  		struct mem_cgroup *from = mem_cgroup_from_task(p);
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
