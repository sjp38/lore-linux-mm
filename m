Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id 11EF26B00D0
	for <linux-mm@kvack.org>; Tue, 26 Mar 2013 04:43:51 -0400 (EDT)
Date: Tue, 26 Mar 2013 09:43:48 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] memcg: fix memcg_cache_name() to use cgroup_name()
Message-ID: <20130326084348.GJ2295@dhcp22.suse.cz>
References: <20130321090849.GF6094@dhcp22.suse.cz>
 <20130321102257.GH6094@dhcp22.suse.cz>
 <514BB23E.70908@huawei.com>
 <20130322080749.GB31457@dhcp22.suse.cz>
 <514C1388.6090909@huawei.com>
 <514C14BF.3050009@parallels.com>
 <20130322093141.GE31457@dhcp22.suse.cz>
 <514EAC41.5050700@huawei.com>
 <20130325090629.GN2154@dhcp22.suse.cz>
 <51515DEE.70105@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51515DEE.70105@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Li Zefan <lizefan@huawei.com>, Tejun Heo <tj@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>

On Tue 26-03-13 12:35:58, Glauber Costa wrote:
> >>
> >> I doubt it's a win to add 4K to kernel text size instead of adding
> >> a few extra lines of code... but it's up to you.
> > 
> > I will leave the decision to Glauber. The updated version which uses
> > kmalloc for the static buffer is bellow.
> > 
> I prefer to allocate dynamically here. But although I understand why we
> need to call cgroup_name, I don't understand what is wrong with
> kasprintf if we're going to allocate anyway. It will allocate a string
> just big enough. A PAGE_SIZE'd allocation is a lot more likely to fail.
> 
> Now, if we really want to be smart here, we can do something like what
> I've done for the slub attribute buffers, that can actually have very
> long values.
> 
> allocate a small buffer that will hold 80 % > of the allocations (256
> bytes should be enough for most cache names), and if the string is
> bigger than this, we allocate. Once we allocate, we save it in a static
> pointer and leave it there. The hope here is that we may be able to
> live without ever allocating in many systems.
> 
> > +
> > +	/*
> > +	 * kmem_cache_create_memcg duplicates the given name and
> > +	 * cgroup_name for this name requires RCU context.
> > +	 * This static temporary buffer is used to prevent from
> > +	 * pointless shortliving allocation.
> > +	 */
> The comment is also no longer true if you don't resort to a static buffer.

The buffer _is_ static (read global variable hidden with the function
scope).

> The following (untested) patch implements the idea I outlined above.
> 
> What do you guys think ?

I really do not care which way to fix this.

[...]
> +static struct kmem_cache *kmem_cache_dup(struct mem_cgroup *memcg,
> +					 struct kmem_cache *s)
>  {
> -	char *name;
> -	struct dentry *dentry;
> +	const char *cgname; /* actual cache name */
> +	char *name = NULL; /* actual cache name */
> +	char buf[256]; /* stack buffer for small allocations */
> +	int buf_len;
> +	static char *buf_name; /* pointer to a page, if we ever need */
> +	struct kmem_cache *new;
> +
> +	lockdep_assert_held(&memcg_cache_mutex);
>  
>  	rcu_read_lock();
> -	dentry = rcu_dereference(memcg->css.cgroup->dentry);
> +	cgname = cgroup_name(memcg->css.cgroup);
>  	rcu_read_unlock();

cgname is valid only within RCU read lock AFAIU.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
