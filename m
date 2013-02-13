Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 57B466B0005
	for <linux-mm@kvack.org>; Wed, 13 Feb 2013 05:00:21 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 917203EE0BC
	for <linux-mm@kvack.org>; Wed, 13 Feb 2013 19:00:19 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7947145DE52
	for <linux-mm@kvack.org>; Wed, 13 Feb 2013 19:00:19 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 545DD45DE4F
	for <linux-mm@kvack.org>; Wed, 13 Feb 2013 19:00:19 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 418511DB8040
	for <linux-mm@kvack.org>; Wed, 13 Feb 2013 19:00:19 +0900 (JST)
Received: from m1000.s.css.fujitsu.com (m1000.s.css.fujitsu.com [10.240.81.136])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id E92411DB803B
	for <linux-mm@kvack.org>; Wed, 13 Feb 2013 19:00:18 +0900 (JST)
Message-ID: <511B6422.8030408@jp.fujitsu.com>
Date: Wed, 13 Feb 2013 19:00:02 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] memcg: fix kmemcg registration for late caches
References: <1360600797-27793-1-git-send-email-glommer@parallels.com>
In-Reply-To: <1360600797-27793-1-git-send-email-glommer@parallels.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, cgroups@vger.kernel.org

(2013/02/12 1:39), Glauber Costa wrote:
> The designed workflow for the caches in kmemcg is: register it with
> memcg_register_cache() if kmemcg is already available or later on when a
> new kmemcg appears at memcg_update_cache_sizes() which will handle all
> caches in the system. The caches created at boot time will be handled by
> the later, and the memcg-caches as well as any system caches that are
> registered later on by the former.
> 
> There is a bug, however, in memcg_register_cache: we correctly set up
> the array size, but do not mark the cache as a root cache. This means
> that allocations for any cache appearing late in the game will see
> memcg->memcg_params->is_root_cache == false, and in particular, trigger
> VM_BUG_ON(!cachep->memcg_params->is_root_cache) in
> __memcg_kmem_cache_get.
> 
> The obvious fix is to include the missing assignment.
> 
> Signed-off-by: Glauber Costa <glommer@parallels.com>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

> ---
>   mm/memcontrol.c | 4 +++-
>   1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 03ebf68..d4e83d0 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -3147,7 +3147,9 @@ int memcg_register_cache(struct mem_cgroup *memcg, struct kmem_cache *s,
>   	if (memcg) {
>   		s->memcg_params->memcg = memcg;
>   		s->memcg_params->root_cache = root_cache;
> -	}
> +	} else
> +		s->memcg_params->is_root_cache = true;
> +
>   	return 0;
>   }
>   
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
