Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 8E284900138
	for <linux-mm@kvack.org>; Wed, 17 Aug 2011 20:31:45 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 260013EE0AE
	for <linux-mm@kvack.org>; Thu, 18 Aug 2011 09:31:42 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0CBEF45DE50
	for <linux-mm@kvack.org>; Thu, 18 Aug 2011 09:31:42 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id DF28745DE4F
	for <linux-mm@kvack.org>; Thu, 18 Aug 2011 09:31:41 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id D0F551DB803E
	for <linux-mm@kvack.org>; Thu, 18 Aug 2011 09:31:41 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 8C0FE1DB802F
	for <linux-mm@kvack.org>; Thu, 18 Aug 2011 09:31:41 +0900 (JST)
Date: Thu, 18 Aug 2011 09:24:21 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [patch] memcg: pin execution to current cpu while draining
 stock
Message-Id: <20110818092421.856b74fe.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110817194927.GA10982@redhat.com>
References: <cover.1311338634.git.mhocko@suse.cz>
	<2f17df54db6661c39a05669d08a9e6257435b898.1311338634.git.mhocko@suse.cz>
	<20110725101657.21f85bf0.kamezawa.hiroyu@jp.fujitsu.com>
	<20110817194927.GA10982@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <jweiner@redhat.com>
Cc: Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Balbir Singh <bsingharora@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org

On Wed, 17 Aug 2011 21:49:27 +0200
Johannes Weiner <jweiner@redhat.com> wrote:

> Commit d1a05b6 'memcg: do not try to drain per-cpu caches without
> pages' added a drain_local_stock() call to a preemptible section.
> 
> The draining task looks up the cpu-local stock twice to set the
> draining-flag, then to drain the stock and clear the flag again.  If
> the task is migrated to a different CPU in between, noone will clear
> the flag on the first stock and it will be forever undrainable.  Its
> charge can not be recovered and the cgroup can not be deleted anymore.
> 
> Properly pin the task to the executing CPU while draining stocks.
> 
> Signed-off-by: Johannes Weiner <jweiner@redhat.com>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com
> Cc: Michal Hocko <mhocko@suse.cz>

Thanks. I think Shaoha Li reported this.

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com
==

http://www.spinics.net/lists/linux-mm/msg22635.html

I get below warning:
BUG: using smp_processor_id() in preemptible [00000000] code: bash/739
caller is drain_local_stock+0x1a/0x55
Pid: 739, comm: bash Tainted: G        W   3.0.0+ #255
Call Trace:
 [<ffffffff813435c6>] debug_smp_processor_id+0xc2/0xdc
 [<ffffffff8114ae9b>] drain_local_stock+0x1a/0x55
 [<ffffffff8114b076>] drain_all_stock+0x98/0x13a
 [<ffffffff8114f04c>] mem_cgroup_force_empty+0xa3/0x27a
 [<ffffffff8114ff1d>] ? sys_close+0x38/0x138
 [<ffffffff811a7631>] ? environ_read+0x1d/0x159
 [<ffffffff8114f253>] mem_cgroup_force_empty_write+0x17/0x19
 [<ffffffff810c72fb>] cgroup_file_write+0xa8/0xba
 [<ffffffff811522ce>] vfs_write+0xb3/0x138
 [<ffffffff81152416>] sys_write+0x4a/0x71
 [<ffffffff8114ffd5>] ? sys_close+0xf0/0x138
 [<ffffffff8176deab>] system_call_fastpath+0x16/0x1b

drain_local_stock() should be run with preempt disabled.
==

Andrew, could you pull this one , too ?
http://www.spinics.net/lists/linux-mm/msg22636.html

Thanks,
-Kame

> ---
>  mm/memcontrol.c |    9 ++-------
>  1 files changed, 2 insertions(+), 7 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 697a1d5..e9b1206 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2085,13 +2085,7 @@ static void drain_all_stock(struct mem_cgroup *root_mem, bool sync)
>  
>  	/* Notify other cpus that system-wide "drain" is running */
>  	get_online_cpus();
> -	/*
> -	 * Get a hint for avoiding draining charges on the current cpu,
> -	 * which must be exhausted by our charging.  It is not required that
> -	 * this be a precise check, so we use raw_smp_processor_id() instead of
> -	 * getcpu()/putcpu().
> -	 */
> -	curcpu = raw_smp_processor_id();
> +	curcpu = get_cpu();
>  	for_each_online_cpu(cpu) {
>  		struct memcg_stock_pcp *stock = &per_cpu(memcg_stock, cpu);
>  		struct mem_cgroup *mem;
> @@ -2108,6 +2102,7 @@ static void drain_all_stock(struct mem_cgroup *root_mem, bool sync)
>  				schedule_work_on(cpu, &stock->work);
>  		}
>  	}
> +	put_cpu();
>  
>  	if (!sync)
>  		goto out;
> -- 
> 1.7.6
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
