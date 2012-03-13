Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx154.postini.com [74.125.245.154])
	by kanga.kvack.org (Postfix) with SMTP id EF03B6B004A
	for <linux-mm@kvack.org>; Tue, 13 Mar 2012 18:50:02 -0400 (EDT)
Received: by yenm8 with SMTP id m8so1488686yen.14
        for <linux-mm@kvack.org>; Tue, 13 Mar 2012 15:50:02 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4F5C7D82.7030904@parallels.com>
References: <1331325556-16447-1-git-send-email-ssouhlal@FreeBSD.org>
	<1331325556-16447-8-git-send-email-ssouhlal@FreeBSD.org>
	<4F5C7D82.7030904@parallels.com>
Date: Tue, 13 Mar 2012 15:50:01 -0700
Message-ID: <CABCjUKDsYyg4ONGTEeh1oen-L=OuBrP53qRdpHAT8AYYQ-JqWA@mail.gmail.com>
Subject: Re: [PATCH v2 07/13] memcg: Slab accounting.
From: Suleiman Souhlal <suleiman@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Suleiman Souhlal <ssouhlal@freebsd.org>, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, cl@linux.com, yinghan@google.com, hughd@google.com, gthelen@google.com, peterz@infradead.org, dan.magenheimer@oracle.com, hannes@cmpxchg.org, mgorman@suse.de, James.Bottomley@hansenpartnership.com, linux-mm@kvack.org, devel@openvz.org, linux-kernel@vger.kernel.org, Pekka Enberg <penberg@kernel.org>

On Sun, Mar 11, 2012 at 3:25 AM, Glauber Costa <glommer@parallels.com> wrot=
e:
> On 03/10/2012 12:39 AM, Suleiman Souhlal wrote:
>> +static inline void
>> +mem_cgroup_kmem_cache_prepare_sleep(struct kmem_cache *cachep)
>> +{
>> + =A0 =A0 =A0 /*
>> + =A0 =A0 =A0 =A0* Make sure the cache doesn't get freed while we have i=
nterrupts
>> + =A0 =A0 =A0 =A0* enabled.
>> + =A0 =A0 =A0 =A0*/
>> + =A0 =A0 =A0 kmem_cache_get_ref(cachep);
>> + =A0 =A0 =A0 rcu_read_unlock();
>> +}
>
>
> Is this really needed ? After this function call in slab.c, the slab code
> itself accesses cachep a thousand times. If it could be freed, it would
> already explode today for other reasons?
> Am I missing something here?

We need this because once we drop the rcu_read_lock and go to sleep,
the memcg could get deleted, which could lead to the cachep from
getting deleted as well.

So, we need to grab a reference to the cache, to make sure that the
cache doesn't disappear from under us.

>> diff --git a/init/Kconfig b/init/Kconfig
>> index 3f42cd6..e7eb652 100644
>> --- a/init/Kconfig
>> +++ b/init/Kconfig
>> @@ -705,7 +705,7 @@ config CGROUP_MEM_RES_CTLR_SWAP_ENABLED
>> =A0 =A0 =A0 =A0 =A0then swapaccount=3D0 does the trick).
>> =A0config CGROUP_MEM_RES_CTLR_KMEM
>> =A0 =A0 =A0 =A0bool "Memory Resource Controller Kernel Memory accounting
>> (EXPERIMENTAL)"
>> - =A0 =A0 =A0 depends on CGROUP_MEM_RES_CTLR&& =A0EXPERIMENTAL
>> + =A0 =A0 =A0 depends on CGROUP_MEM_RES_CTLR&& =A0EXPERIMENTAL&& =A0!SLO=
B
>
> Orthogonal question: Will we ever want this (SLOB) ?

I honestly don't know why someone would want to use this and slob at
the same time.
It really doesn't seem like a required feature, in my opinion.
Especially at first.

>> +static struct kmem_cache *
>> +memcg_create_kmem_cache(struct mem_cgroup *memcg, struct kmem_cache
>> *cachep)
>> +{
>> + =A0 =A0 =A0 struct kmem_cache *new_cachep;
>> + =A0 =A0 =A0 struct dentry *dentry;
>> + =A0 =A0 =A0 char *name;
>> + =A0 =A0 =A0 int idx;
>> +
>> + =A0 =A0 =A0 idx =3D cachep->memcg_params.id;
>> +
>> + =A0 =A0 =A0 dentry =3D memcg->css.cgroup->dentry;
>> + =A0 =A0 =A0 BUG_ON(dentry =3D=3D NULL);
>> +
>> + =A0 =A0 =A0 /* Preallocate the space for "dead" at the end */
>> + =A0 =A0 =A0 name =3D kasprintf(GFP_KERNEL, "%s(%d:%s)dead",
>> + =A0 =A0 =A0 =A0 =A0 cachep->name, css_id(&memcg->css), dentry->d_name.=
name);
>> + =A0 =A0 =A0 if (name =3D=3D NULL)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return cachep;
>> + =A0 =A0 =A0 /* Remove "dead" */
>> + =A0 =A0 =A0 name[strlen(name) - 4] =3D '\0';
>> +
>> + =A0 =A0 =A0 new_cachep =3D kmem_cache_create_memcg(cachep, name);
>> +
>> + =A0 =A0 =A0 /*
>> + =A0 =A0 =A0 =A0* Another CPU is creating the same cache?
>> + =A0 =A0 =A0 =A0* We'll use it next time.
>> + =A0 =A0 =A0 =A0*/
>
> This comment is a bit misleading. Is it really the only reason
> it can fail?
>
> The impression I got is that it can also fail under the normal conditions=
 in
> which kmem_cache_create() fails.

kmem_cache_create() isn't expected to fail often.
I wasn't making an exhaustive lists of why this condition can happen,
just what I think is the most common one is.

>> +/*
>> + * Enqueue the creation of a per-memcg kmem_cache.
>> + * Called with rcu_read_lock.
>> + */
>> +static void
>> +memcg_create_cache_enqueue(struct mem_cgroup *memcg, struct kmem_cache
>> *cachep)
>> +{
>> + =A0 =A0 =A0 struct create_work *cw;
>> + =A0 =A0 =A0 unsigned long flags;
>> +
>> + =A0 =A0 =A0 spin_lock_irqsave(&create_queue_lock, flags);
>
> If we can sleep, why not just create the cache now?
>
> Maybe it would be better to split this in two, and create the cache if
> possible, and a worker if not possible. Then w

That's how I had it in my initial patch, but I was under the
impression that you preferred if we always kicked off the creation to
the workqueue?

Which way do you prefer?

>> @@ -1756,17 +1765,23 @@ static void *kmem_getpages(struct kmem_cache
>> *cachep, gfp_t flags, int nodeid)
>> =A0 =A0 =A0 =A0if (cachep->flags& =A0SLAB_RECLAIM_ACCOUNT)
>>
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0flags |=3D __GFP_RECLAIMABLE;
>>
>> + =A0 =A0 =A0 nr_pages =3D (1<< =A0cachep->gfporder);
>> + =A0 =A0 =A0 if (!mem_cgroup_charge_slab(cachep, flags, nr_pages * PAGE=
_SIZE))
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NULL;
>> +
>> =A0 =A0 =A0 =A0page =3D alloc_pages_exact_node(nodeid, flags | __GFP_NOT=
RACK,
>> cachep->gfporder);
>> - =A0 =A0 =A0 if (!page)
>> + =A0 =A0 =A0 if (!page) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_uncharge_slab(cachep, nr_pages =
* PAGE_SIZE);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return NULL;
>> + =A0 =A0 =A0 }
>
>
>
> Can't the following happen:
>
> =A0*) mem_cgroup_charge_slab() is the first one to touch the slab.
> =A0 =A0Therefore, this first one is billed to root.
> =A0*) A slab is queued for creation.
> =A0*) alloc_pages sleep.
> =A0*) our workers run, and create the cache, therefore filling
> =A0 =A0cachep->memcg_param.memcg
> =A0*) alloc_pages still can't allocate.
> =A0*) uncharge tries to uncharge from cachep->memcg_param.memcg,
> =A0 =A0which doesn't have any charges...
>
> Unless you have a strong oposition to this, to avoid this kind of
> corner cases, we could do what I was doing in the slub:
> Allocate the page first, and then account it.
> (freeing the page if it fails).
>
> I know it is not the way it is done for the user pages, but I believe it =
to
> be better suited for the slab.

I don't think the situation you're describing can happen, because the
memcg caches get created and selected at the beginning of the slab
allocation, in mem_cgroup_get_kmem_cache() and not in
mem_cgroup_charge_slab(), which is much later.

Once we are in mem_cgroup_charge_slab() we know that the allocation
will be charged to the cgroup.

>> @@ -2269,10 +2288,12 @@ kmem_cache_create (const char *name, size_t size=
,
>> size_t align,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
>>
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!strcmp(pc->name, name)) {
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_ERR
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0"kmem_cache=
_create: duplicate cache %s\n",
>> name);
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dump_stack();
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto oops;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!memcg) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(KER=
N_ERR "kmem_cache_create:
>> duplicate"
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 " =
cache %s\n", name);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dump_stack=
();
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto oops;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>
> Why? Since we are apending the memcg name at the end anyway, duplicates
> still aren't expected.

Duplicates can happen if you have hierarchies, because we're only
appending the basename of the cgroup.

>> @@ -2703,12 +2787,74 @@ void kmem_cache_destroy(struct kmem_cache *cache=
p)
>> =A0 =A0 =A0 =A0if (unlikely(cachep->flags& =A0SLAB_DESTROY_BY_RCU))
>>
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0rcu_barrier();
>>
>> +#ifdef CONFIG_CGROUP_MEM_RES_CTLR_KMEM
>> + =A0 =A0 =A0 /* Not a memcg cache */
>> + =A0 =A0 =A0 if (cachep->memcg_params.id !=3D -1) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 __clear_bit(cachep->memcg_params.id, cache=
_types);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_flush_cache_create_queue();
>> + =A0 =A0 =A0 }
>> +#endif
>
>
> This will clear the id when a leaf cache is destroyed. It seems it is not
> what we want, right? We want this id to be cleared only when
> the parent cache is gone.

id !=3D -1, for parent caches (that's what the comment is trying to point o=
ut).
I will improve the comment.

>> +static void
>> +kmem_cache_destroy_work_func(struct work_struct *w)
>> +{
>> + =A0 =A0 =A0 struct kmem_cache *cachep;
>> + =A0 =A0 =A0 char *name;
>> +
>> + =A0 =A0 =A0 spin_lock_irq(&destroy_lock);
>> + =A0 =A0 =A0 while (!list_empty(&destroyed_caches)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 cachep =3D container_of(list_first_entry(&=
destroyed_caches,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct mem_cgroup_cache_params, de=
stroyed_list),
>> struct
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 kmem_cache, memcg_params);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 name =3D (char *)cachep->name;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_del(&cachep->memcg_params.destroyed_l=
ist);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock_irq(&destroy_lock);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 synchronize_rcu();
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 kmem_cache_destroy(cachep);
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0^^^^^^
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0will destroy the id.

See my previous comment.

>> @@ -3866,9 +4030,35 @@ void kmem_cache_free(struct kmem_cache *cachep,
>> void *objp)
>>
>> =A0 =A0 =A0 =A0local_irq_save(flags);
>> =A0 =A0 =A0 =A0debug_check_no_locks_freed(objp, obj_size(cachep));
>> +
>> +#ifdef CONFIG_CGROUP_MEM_RES_CTLR_KMEM
>> + =A0 =A0 =A0 {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct kmem_cache *actual_cachep;
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 actual_cachep =3D virt_to_cache(objp);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (actual_cachep !=3D cachep) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 VM_BUG_ON(actual_cachep->m=
emcg_params.id !=3D -1);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 VM_BUG_ON(actual_cachep->m=
emcg_params.orig_cache
>> !=3D
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 cachep);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 cachep =3D actual_cachep;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Grab a reference so that the cache is=
 guaranteed to
>> stay
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* around.
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* If we are freeing the last object of =
a dead memcg
>> cache,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* the kmem_cache_drop_ref() at the end =
of this function
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* will end up freeing the cache.
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 kmem_cache_get_ref(cachep);
>
> 1) Another obvious candidate to be wrapped by static_branch()...
> 2) I don't trully follow why we need those references here. Can you
> =A0 give us an example of a situation in which the cache can go away?
>
> Also note that we are making a function that used to operate mostly on
> local data now issue two atomic operations.

Yes, improving this is in my v3 TODO already.

The situation is very simple, and will happen every time we are
freeing the last object of a dead cache.
When we free the last object, kmem_freepages() will drop the last
reference, which will cause the kmem_cache to be destroyed right
there.
Grabbing an additional reference before freeing the page is just a
hack to avoid this situation.

It might be possible to just wrap the free path in rcu_read_lock(), or
if that isn't enough, to delay the destruction until the end. I still
have to think about this a bit more, to be sure.

Thanks for the detailed review,
-- Suleiman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
