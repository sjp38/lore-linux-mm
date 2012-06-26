Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id C45416B012F
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 02:02:15 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 4B42F3EE0C0
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 15:02:14 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 30C0645DE55
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 15:02:14 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id F09CB45DE51
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 15:02:13 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id DE0A7E08003
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 15:02:13 +0900 (JST)
Received: from m1001.s.css.fujitsu.com (m1001.s.css.fujitsu.com [10.240.81.139])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 912021DB8037
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 15:02:13 +0900 (JST)
Message-ID: <4FE94FDC.7070105@jp.fujitsu.com>
Date: Tue, 26 Jun 2012 14:59:56 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 10/11] memcg: allow a memcg with kmem charges to be destructed.
References: <1340633728-12785-1-git-send-email-glommer@parallels.com> <1340633728-12785-11-git-send-email-glommer@parallels.com>
In-Reply-To: <1340633728-12785-11-git-send-email-glommer@parallels.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Frederic Weisbecker <fweisbec@gmail.com>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, devel@openvz.org, Tejun Heo <tj@kernel.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Suleiman Souhlal <suleiman@google.com>

(2012/06/25 23:15), Glauber Costa wrote:
> Because the ultimate goal of the kmem tracking in memcg is to
> track slab pages as well, we can't guarantee that we'll always
> be able to point a page to a particular process, and migrate
> the charges along with it - since in the common case, a page
> will contain data belonging to multiple processes.
> 
> Because of that, when we destroy a memcg, we only make sure
> the destruction will succeed by discounting the kmem charges
> from the user charges when we try to empty the cgroup.
> 
> Signed-off-by: Glauber Costa <glommer@parallels.com>
> CC: Christoph Lameter <cl@linux.com>
> CC: Pekka Enberg <penberg@cs.helsinki.fi>
> CC: Michal Hocko <mhocko@suse.cz>
> CC: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> CC: Johannes Weiner <hannes@cmpxchg.org>
> CC: Suleiman Souhlal <suleiman@google.com>
> ---
>   mm/memcontrol.c |   10 +++++++++-
>   1 file changed, 9 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index a6a440b..bb9b6fe 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -598,6 +598,11 @@ static void disarm_kmem_keys(struct mem_cgroup *memcg)
>   {
>   	if (test_bit(KMEM_ACCOUNTED_THIS, &memcg->kmem_accounted))
>   		static_key_slow_dec(&mem_cgroup_kmem_enabled_key);
> +	/*
> +	 * This check can't live in kmem destruction function,
> +	 * since the charges will outlive the cgroup
> +	 */
> +	BUG_ON(res_counter_read_u64(&memcg->kmem, RES_USAGE) != 0);
>   }
>   #else
>   static void disarm_kmem_keys(struct mem_cgroup *memcg)
> @@ -3838,6 +3843,7 @@ static int mem_cgroup_force_empty(struct mem_cgroup *memcg, bool free_all)
>   	int node, zid, shrink;
>   	int nr_retries = MEM_CGROUP_RECLAIM_RETRIES;
>   	struct cgroup *cgrp = memcg->css.cgroup;
> +	u64 usage;
>   
>   	css_get(&memcg->css);
>   
> @@ -3877,8 +3883,10 @@ move_account:
>   		if (ret == -ENOMEM)
>   			goto try_to_free;
>   		cond_resched();
> +		usage = res_counter_read_u64(&memcg->res, RES_USAGE) -
> +			res_counter_read_u64(&memcg->kmem, RES_USAGE);
>   	/* "ret" should also be checked to ensure all lists are empty. */
> -	} while (res_counter_read_u64(&memcg->res, RES_USAGE) > 0 || ret);
> +	} while (usage > 0 || ret);
>   out:
>   	css_put(&memcg->css);
>   	return ret;
> 
Hm....maybe work enough. Could you add more comments on the code ?

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
