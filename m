Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id 36C236B005C
	for <linux-mm@kvack.org>; Tue, 29 May 2012 12:33:22 -0400 (EDT)
Date: Tue, 29 May 2012 11:33:17 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v3 12/28] slab: pass memcg parameter to
 kmem_cache_create
In-Reply-To: <4FC4F04F.1070401@parallels.com>
Message-ID: <alpine.DEB.2.00.1205291131590.6723@router.home>
References: <1337951028-3427-1-git-send-email-glommer@parallels.com> <1337951028-3427-13-git-send-email-glommer@parallels.com> <alpine.DEB.2.00.1205290922340.4666@router.home> <4FC4F04F.1070401@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, Greg Thelen <gthelen@google.com>, Suleiman Souhlal <suleiman@google.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, devel@openvz.org, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>

On Tue, 29 May 2012, Glauber Costa wrote:

> > Ok this only duplicates the kmalloc arrays. Why not the others?
>
> It does duplicate the others.
>
> First it does a while look on the kmalloc caches, then a list_for_each_entry
> in the rest. You probably missed it.

There is no need to separately duplicate the kmalloc_caches. Those are
included on the cache_chain.

> > > @@ -2543,7 +2564,12 @@ kmem_cache_create (const char *name, size_t size,
> > > size_t align,
> > >   	cachep->ctor = ctor;
> > >   	cachep->name = name;
> > >
> > > +	if (g_cpucache_up>= FULL)
> > > +		mem_cgroup_register_cache(memcg, cachep);
> >
> > What happens if a cgroup was active during creation of slab xxy but
> > then a process running in a different cgroup uses that slab to allocate
> > memory? Is it charged to the first cgroup?
>
> I don't see this situation ever happening. kmem_cache_create, when called
> directly, will always create a global cache. It doesn't matter which cgroups
> are or aren't active at this time or any other. We create copies per-cgroup,
> but we create it lazily, when someone will touch it.

How do you detect that someone is touching it?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
