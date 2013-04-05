Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id BE0286B0005
	for <linux-mm@kvack.org>; Fri,  5 Apr 2013 01:51:56 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 532A53EE0C1
	for <linux-mm@kvack.org>; Fri,  5 Apr 2013 14:51:54 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 2E8CF45DE58
	for <linux-mm@kvack.org>; Fri,  5 Apr 2013 14:51:54 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 1558845DE5A
	for <linux-mm@kvack.org>; Fri,  5 Apr 2013 14:51:54 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 05BFB1DB8055
	for <linux-mm@kvack.org>; Fri,  5 Apr 2013 14:51:54 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id AB09A1DB804F
	for <linux-mm@kvack.org>; Fri,  5 Apr 2013 14:51:53 +0900 (JST)
Message-ID: <515E664E.5060005@jp.fujitsu.com>
Date: Fri, 05 Apr 2013 14:51:10 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 2/7] memcg: don't use mem_cgroup_get() when creating
 a kmemcg cache
References: <515BF233.6070308@huawei.com> <515BF275.5080408@huawei.com>
In-Reply-To: <515BF275.5080408@huawei.com>
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizefan@huawei.com>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, Tejun Heo <tj@kernel.org>, Glauber Costa <glommer@parallels.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>

(2013/04/03 18:12), Li Zefan wrote:
> Use css_get()/css_put() instead of mem_cgroup_get()/mem_cgroup_put().
> 
> Signed-off-by: Li Zefan <lizefan@huawei.com>
> ---
>   mm/memcontrol.c | 10 +++++-----
>   1 file changed, 5 insertions(+), 5 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 43ca91d..dafacb8 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -3191,7 +3191,7 @@ void memcg_release_cache(struct kmem_cache *s)
>   	list_del(&s->memcg_params->list);
>   	mutex_unlock(&memcg->slab_caches_mutex);
>   
> -	mem_cgroup_put(memcg);
> +	css_put(&memcg->css);
>   out:
>   	kfree(s->memcg_params);
>   }
> @@ -3350,16 +3350,18 @@ static struct kmem_cache *memcg_create_kmem_cache(struct mem_cgroup *memcg,
>   
>   	mutex_lock(&memcg_cache_mutex);
>   	new_cachep = cachep->memcg_params->memcg_caches[idx];
> -	if (new_cachep)
> +	if (new_cachep) {
> +		css_put(&memcg->css);
>   		goto out;
> +	}

Where css_get() against this is done ?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
