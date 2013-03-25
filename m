Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id 55C3A6B006C
	for <linux-mm@kvack.org>; Mon, 25 Mar 2013 05:06:35 -0400 (EDT)
Date: Mon, 25 Mar 2013 10:06:29 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] memcg: fix memcg_cache_name() to use cgroup_name()
Message-ID: <20130325090629.GN2154@dhcp22.suse.cz>
References: <514A60CD.60208@huawei.com>
 <20130321090849.GF6094@dhcp22.suse.cz>
 <20130321102257.GH6094@dhcp22.suse.cz>
 <514BB23E.70908@huawei.com>
 <20130322080749.GB31457@dhcp22.suse.cz>
 <514C1388.6090909@huawei.com>
 <514C14BF.3050009@parallels.com>
 <20130322093141.GE31457@dhcp22.suse.cz>
 <514EAC41.5050700@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <514EAC41.5050700@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizefan@huawei.com>
Cc: Glauber Costa <glommer@parallels.com>, Tejun Heo <tj@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>

On Sun 24-03-13 15:33:21, Li Zefan wrote:
> >> Thanks for identifying and fixing this.
> >>
> >> Li is right. The cache name will live long, but this is because the
> >> slab/slub caches will strdup it internally. So the actual memcg
> >> allocation is short lived.
> > 
> > OK, I have totally missed that. Sorry about the confusion. Then all the
> > churn around the allocation is pointless, no?
> > What about:
> > ---
> >>From 7ed7f53bb597e8cb40d9ac91ce16142fb60f1e93 Mon Sep 17 00:00:00 2001
> > From: Michal Hocko <mhocko@suse.cz>
> > Date: Fri, 22 Mar 2013 10:22:54 +0100
> > Subject: [PATCH] memcg: fix memcg_cache_name() to use cgroup_name()
> > 
> > As cgroup supports rename, it's unsafe to dereference dentry->d_name
> > without proper vfs locks. Fix this by using cgroup_name() rather than
> > dentry directly.
> > 
> > Also open code memcg_cache_name because it is called only from
> > kmem_cache_dup which frees the returned name right after
> > kmem_cache_create_memcg makes a copy of it. Such a short-lived
> > allocation doesn't make too much sense. So replace it by a static
> > buffer as kmem_cache_dup is called with memcg_cache_mutex.
> > 
> 
> I doubt it's a win to add 4K to kernel text size instead of adding
> a few extra lines of code... but it's up to you.

I will leave the decision to Glauber. The updated version which uses
kmalloc for the static buffer is bellow.

> > Signed-off-by: Li Zefan <lizefan@huawei.com>
> > Signed-off-by: Michal Hocko <mhocko@suse.cz>
> > ---
> >  mm/memcontrol.c |   33 +++++++++++----------------------
> >  1 file changed, 11 insertions(+), 22 deletions(-)
> ...
> >  static struct kmem_cache *kmem_cache_dup(struct mem_cgroup *memcg,
> >  					 struct kmem_cache *s)
> >  {
> >  	char *name;
> >  	struct kmem_cache *new;
> > +	static char tmp_name[PAGE_SIZE];
> >  
> > -	name = memcg_cache_name(memcg, s);
> > -	if (!name)
> > -		return NULL;
> > +	lockdep_assert_held(&memcg_cache_mutex);
> > +
> > +	rcu_read_lock();
> > +	tmp_name = snprintf(tmp_name, sizeof(tmp_name), "%s(%d:%s)", s->name,
> > +			 memcg_cache_id(memcg), cgroup_name(memcg->css.cgroup));
> 
> I guess you didn't turn on CONFIG_MEMCG_KMEM?

dohh. Friday effect...

> snprintf() returns a int value.
[...]
---
