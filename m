Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id A46416B0002
	for <linux-mm@kvack.org>; Tue,  2 Apr 2013 09:32:30 -0400 (EDT)
Date: Tue, 2 Apr 2013 15:32:27 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] memcg: don't do cleanup manually if
 mem_cgroup_css_online() fails
Message-ID: <20130402133227.GM24345@dhcp22.suse.cz>
References: <515A8A40.6020406@huawei.com>
 <20130402121600.GK24345@dhcp22.suse.cz>
 <515ACD7F.3070009@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <515ACD7F.3070009@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, linux-mm@kvack.org

On Tue 02-04-13 16:22:23, Glauber Costa wrote:
> On 04/02/2013 04:16 PM, Michal Hocko wrote:
> > On Tue 02-04-13 15:35:28, Li Zefan wrote:
> > [...]
> >> @@ -6247,16 +6247,7 @@ mem_cgroup_css_online(struct cgroup *cont)
> >>  
> >>  	error = memcg_init_kmem(memcg, &mem_cgroup_subsys);
> >>  	mutex_unlock(&memcg_create_mutex);
> >> -	if (error) {
> >> -		/*
> >> -		 * We call put now because our (and parent's) refcnts
> >> -		 * are already in place. mem_cgroup_put() will internally
> >> -		 * call __mem_cgroup_free, so return directly
> >> -		 */
> >> -		mem_cgroup_put(memcg);
> >> -		if (parent->use_hierarchy)
> >> -			mem_cgroup_put(parent);
> >> -	}
> >> +
> >>  	return error;
> >>  }
> > 
> > The mem_cgroup_put(parent) part is incorrect because mem_cgroup_put goes
> > up the hierarchy already but I do not think mem_cgroup_put(memcg) should
> > go away as well. Who is going to free the last reference then?
> > 
> > Maybe I am missing something but we have:
> > cgroup_create
> >   css = ss->css_alloc(cgrp)
> >     mem_cgroup_css_alloc
> >       atomic_set(&memcg->refcnt, 1)
> >   online_css(ss, cgrp)
> >     mem_cgroup_css_online
> >       error = memcg_init_kmem		# fails
> >   goto err_destroy
> > err_destroy:
> >   cgroup_destroy_locked(cgrp)
> >     offline_css
> >       mem_cgroup_css_offline
> > 
> > no mem_cgroup_put on the way.
> > 
> 
> static void mem_cgroup_css_free(struct cgroup *cont)
> {
>         struct mem_cgroup *memcg = mem_cgroup_from_cont(cont);
> 
>         kmem_cgroup_destroy(memcg);
> 
>         mem_cgroup_put(memcg);
> }
> 
> kernel/cgroup.c:
> err_free_all:
>         for_each_subsys(root, ss) {
>                 if (cgrp->subsys[ss->subsys_id])
>                         ss->css_free(cgrp);
>         }

But we do not get to that path after online_css fails because that one
jumps to err_destroy. So this is not it. Maybe css_free gets called from
cgroup_diput but I got lost in the indirection.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
