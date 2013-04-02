Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id E726D6B0002
	for <linux-mm@kvack.org>; Tue,  2 Apr 2013 08:16:03 -0400 (EDT)
Date: Tue, 2 Apr 2013 14:16:00 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] memcg: don't do cleanup manually if
 mem_cgroup_css_online() fails
Message-ID: <20130402121600.GK24345@dhcp22.suse.cz>
References: <515A8A40.6020406@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <515A8A40.6020406@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizefan@huawei.com>
Cc: Glauber Costa <glommer@parallels.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, linux-mm@kvack.org

On Tue 02-04-13 15:35:28, Li Zefan wrote:
[...]
> @@ -6247,16 +6247,7 @@ mem_cgroup_css_online(struct cgroup *cont)
>  
>  	error = memcg_init_kmem(memcg, &mem_cgroup_subsys);
>  	mutex_unlock(&memcg_create_mutex);
> -	if (error) {
> -		/*
> -		 * We call put now because our (and parent's) refcnts
> -		 * are already in place. mem_cgroup_put() will internally
> -		 * call __mem_cgroup_free, so return directly
> -		 */
> -		mem_cgroup_put(memcg);
> -		if (parent->use_hierarchy)
> -			mem_cgroup_put(parent);
> -	}
> +
>  	return error;
>  }

The mem_cgroup_put(parent) part is incorrect because mem_cgroup_put goes
up the hierarchy already but I do not think mem_cgroup_put(memcg) should
go away as well. Who is going to free the last reference then?

Maybe I am missing something but we have:
cgroup_create
  css = ss->css_alloc(cgrp)
    mem_cgroup_css_alloc
      atomic_set(&memcg->refcnt, 1)
  online_css(ss, cgrp)
    mem_cgroup_css_online
      error = memcg_init_kmem		# fails
  goto err_destroy
err_destroy:
  cgroup_destroy_locked(cgrp)
    offline_css
      mem_cgroup_css_offline

no mem_cgroup_put on the way.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
