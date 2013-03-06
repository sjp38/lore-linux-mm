Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id 05D8D6B0008
	for <linux-mm@kvack.org>; Tue,  5 Mar 2013 20:08:43 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 8B3323EE0B6
	for <linux-mm@kvack.org>; Wed,  6 Mar 2013 10:08:42 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 70CC745DD6D
	for <linux-mm@kvack.org>; Wed,  6 Mar 2013 10:08:42 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5C8B745DD78
	for <linux-mm@kvack.org>; Wed,  6 Mar 2013 10:08:42 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 514521DB8038
	for <linux-mm@kvack.org>; Wed,  6 Mar 2013 10:08:42 +0900 (JST)
Received: from m1000.s.css.fujitsu.com (m1000.s.css.fujitsu.com [10.240.81.136])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id ED7D0E08004
	for <linux-mm@kvack.org>; Wed,  6 Mar 2013 10:08:41 +0900 (JST)
Message-ID: <513696FB.9080705@jp.fujitsu.com>
Date: Wed, 06 Mar 2013 10:08:11 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 5/5] memcg: do not walk all the way to the root for
 memcg
References: <1362489058-3455-1-git-send-email-glommer@parallels.com> <1362489058-3455-6-git-send-email-glommer@parallels.com>
In-Reply-To: <1362489058-3455-6-git-send-email-glommer@parallels.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, handai.szj@gmail.com, anton.vorontsov@linaro.org, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>

(2013/03/05 22:10), Glauber Costa wrote:
> Since the root is special anyway, and we always get its figures from
> global counters anyway, there is no make all cgroups its descendants,
> wrt res_counters. The sad effect of doing that is that we need to lock
> the root for all allocations, since it is a common ancestor of
> everybody.
> 
> Not having the root as a common ancestor should lead to better
> scalability for not-uncommon case of tasks in the cgroup being
> node-bound to different nodes in NUMA systems.
> 
> Signed-off-by: Glauber Costa <glommer@parallels.com>
> CC: Michal Hocko <mhocko@suse.cz>
> CC: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> CC: Johannes Weiner <hannes@cmpxchg.org>
> CC: Mel Gorman <mgorman@suse.de>
> CC: Andrew Morton <akpm@linux-foundation.org>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

> ---
>   mm/memcontrol.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 6019a32..252dc00 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -6464,7 +6464,7 @@ mem_cgroup_css_online(struct cgroup *cont)
>   	memcg->oom_kill_disable = parent->oom_kill_disable;
>   	memcg->swappiness = mem_cgroup_swappiness(parent);
>   
> -	if (parent->use_hierarchy) {
> +	if (parent && !mem_cgroup_is_root(parent) && parent->use_hierarchy) {
>   		res_counter_init(&memcg->res, &parent->res);
>   		res_counter_init(&memcg->memsw, &parent->memsw);
>   		res_counter_init(&memcg->kmem, &parent->kmem);
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
