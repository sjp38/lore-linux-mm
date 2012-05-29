Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id 6068C6B0073
	for <linux-mm@kvack.org>; Tue, 29 May 2012 11:58:43 -0400 (EDT)
Message-ID: <4FC4F1A7.2010206@parallels.com>
Date: Tue, 29 May 2012 19:56:23 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 13/28] slub: create duplicate cache
References: <1337951028-3427-1-git-send-email-glommer@parallels.com> <1337951028-3427-14-git-send-email-glommer@parallels.com> <alpine.DEB.2.00.1205290932530.4666@router.home>
In-Reply-To: <alpine.DEB.2.00.1205290932530.4666@router.home>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, Greg Thelen <gthelen@google.com>, Suleiman Souhlal <suleiman@google.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, devel@openvz.org, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>

On 05/29/2012 06:36 PM, Christoph Lameter wrote:
> On Fri, 25 May 2012, Glauber Costa wrote:
>
>> index dacd1fb..4689034 100644
>> --- a/mm/memcontrol.c
>> +++ b/mm/memcontrol.c
>> @@ -467,6 +467,23 @@ struct cg_proto *tcp_proto_cgroup(struct mem_cgroup *memcg)
>>   EXPORT_SYMBOL(tcp_proto_cgroup);
>>   #endif /* CONFIG_INET */
>>
>> +char *mem_cgroup_cache_name(struct mem_cgroup *memcg, struct kmem_cache *cachep)
>> +{
>> +	char *name;
>> +	struct dentry *dentry;
>> +
>> +	rcu_read_lock();
>> +	dentry = rcu_dereference(memcg->css.cgroup->dentry);
>> +	rcu_read_unlock();
>> +
>> +	BUG_ON(dentry == NULL);
>> +
>> +	name = kasprintf(GFP_KERNEL, "%s(%d:%s)",
>> +	    cachep->name, css_id(&memcg->css), dentry->d_name.name);
>> +
>> +	return name;
>> +}
>
> Function allocates a string that is supposed to be disposed of by the
> caller. That needs to be documented and maybe even the name needs to
> reflect that.

Okay, I can change it.

>> --- a/mm/slub.c
>> +++ b/mm/slub.c
>> @@ -4002,6 +4002,38 @@ struct kmem_cache *kmem_cache_create(const char *name, size_t size,
>>   }
>>   EXPORT_SYMBOL(kmem_cache_create);
>>
>> +#ifdef CONFIG_CGROUP_MEM_RES_CTLR_KMEM
>> +struct kmem_cache *kmem_cache_dup(struct mem_cgroup *memcg,
>> +				  struct kmem_cache *s)
>> +{
>> +	char *name;
>> +	struct kmem_cache *new;
>> +
>> +	name = mem_cgroup_cache_name(memcg, s);
>> +	if (!name)
>> +		return NULL;
>> +
>> +	new = kmem_cache_create_memcg(memcg, name, s->objsize, s->align,
>> +				      (s->allocflags&  ~SLAB_PANIC), s->ctor);
>
> Hmmm... A full duplicate of the slab cache? We may have many sparsely
> used portions of the per node and per cpu structure as a result.

I've already commented on patch 0, but I will repeat it here. This 
approach leads to more fragmentation, yes, but this is exactly to be 
less intrusive.

With a full copy, all I need to do is:

1) relay the allocation to the right cache.
2) account for a new page when it is needed.

How does the cache work from inside? I don't care.

Accounting pages seems just crazy to me. If new allocators come in the 
future, organizing the pages in a different way, instead of patching it 
here and there, we need to totally rewrite this.

If those allocators happen to depend on a specific placement for 
performance, then we're destroying this as well too.

>
>> +	 * prevent it from being deleted. If kmem_cache_destroy() is
>> +	 * called for the root cache before we call it for a child cache,
>> +	 * it will be queued for destruction when we finally drop the
>> +	 * reference on the child cache.
>> +	 */
>> +	if (new) {
>> +		down_write(&slub_lock);
>> +		s->refcount++;
>> +		up_write(&slub_lock);
>> +	}
>
> Why do you need to increase the refcount? You made a full copy right?

Yes, but I don't want this copy to go away while we have other caches 
around.

So, in the memcg internals, I used a different reference counter, to 
avoid messing with this one. I could use that, and leave the original 
refcnt alone. Would you prefer this?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
