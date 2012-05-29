Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id 5F58E6B005D
	for <linux-mm@kvack.org>; Tue, 29 May 2012 10:37:00 -0400 (EDT)
Date: Tue, 29 May 2012 09:36:55 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v3 13/28] slub: create duplicate cache
In-Reply-To: <1337951028-3427-14-git-send-email-glommer@parallels.com>
Message-ID: <alpine.DEB.2.00.1205290932530.4666@router.home>
References: <1337951028-3427-1-git-send-email-glommer@parallels.com> <1337951028-3427-14-git-send-email-glommer@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, Greg Thelen <gthelen@google.com>, Suleiman Souhlal <suleiman@google.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, devel@openvz.org, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>

On Fri, 25 May 2012, Glauber Costa wrote:

> index dacd1fb..4689034 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -467,6 +467,23 @@ struct cg_proto *tcp_proto_cgroup(struct mem_cgroup *memcg)
>  EXPORT_SYMBOL(tcp_proto_cgroup);
>  #endif /* CONFIG_INET */
>
> +char *mem_cgroup_cache_name(struct mem_cgroup *memcg, struct kmem_cache *cachep)
> +{
> +	char *name;
> +	struct dentry *dentry;
> +
> +	rcu_read_lock();
> +	dentry = rcu_dereference(memcg->css.cgroup->dentry);
> +	rcu_read_unlock();
> +
> +	BUG_ON(dentry == NULL);
> +
> +	name = kasprintf(GFP_KERNEL, "%s(%d:%s)",
> +	    cachep->name, css_id(&memcg->css), dentry->d_name.name);
> +
> +	return name;
> +}

Function allocates a string that is supposed to be disposed of by the
caller. That needs to be documented and maybe even the name needs to
reflect that.

> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -4002,6 +4002,38 @@ struct kmem_cache *kmem_cache_create(const char *name, size_t size,
>  }
>  EXPORT_SYMBOL(kmem_cache_create);
>
> +#ifdef CONFIG_CGROUP_MEM_RES_CTLR_KMEM
> +struct kmem_cache *kmem_cache_dup(struct mem_cgroup *memcg,
> +				  struct kmem_cache *s)
> +{
> +	char *name;
> +	struct kmem_cache *new;
> +
> +	name = mem_cgroup_cache_name(memcg, s);
> +	if (!name)
> +		return NULL;
> +
> +	new = kmem_cache_create_memcg(memcg, name, s->objsize, s->align,
> +				      (s->allocflags & ~SLAB_PANIC), s->ctor);

Hmmm... A full duplicate of the slab cache? We may have many sparsely
used portions of the per node and per cpu structure as a result.

> +	 * prevent it from being deleted. If kmem_cache_destroy() is
> +	 * called for the root cache before we call it for a child cache,
> +	 * it will be queued for destruction when we finally drop the
> +	 * reference on the child cache.
> +	 */
> +	if (new) {
> +		down_write(&slub_lock);
> +		s->refcount++;
> +		up_write(&slub_lock);
> +	}

Why do you need to increase the refcount? You made a full copy right?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
