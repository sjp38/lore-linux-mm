Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id 105836B0044
	for <linux-mm@kvack.org>; Mon, 30 Apr 2012 16:56:48 -0400 (EDT)
Received: by qcsd16 with SMTP id d16so2087704qcs.14
        for <linux-mm@kvack.org>; Mon, 30 Apr 2012 13:56:47 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1335138820-26590-6-git-send-email-glommer@parallels.com>
References: <1334959051-18203-1-git-send-email-glommer@parallels.com>
	<1335138820-26590-6-git-send-email-glommer@parallels.com>
Date: Mon, 30 Apr 2012 13:56:46 -0700
Message-ID: <CABCjUKBk=RTCoH34XOQHxRsSp0G5iwtgeBKtdNEUeTE5kx07Vg@mail.gmail.com>
Subject: Re: [PATCH 17/23] kmem controller charge/uncharge infrastructure
From: Suleiman Souhlal <suleiman@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@openvz.org, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, fweisbec@gmail.com, Greg Thelen <gthelen@google.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@cs.helsinki.fi>

On Sun, Apr 22, 2012 at 4:53 PM, Glauber Costa <glommer@parallels.com> wrot=
e:
> With all the dependencies already in place, this patch introduces
> the charge/uncharge functions for the slab cache accounting in memcg.
>
> Before we can charge a cache, we need to select the right cache.
> This is done by using the function __mem_cgroup_get_kmem_cache().
>
> If we should use the root kmem cache, this function tries to detect
> that and return as early as possible.
>
> The charge and uncharge functions comes in two flavours:
> =A0* __mem_cgroup_(un)charge_slab(), that assumes the allocation is
> =A0 a slab page, and
> =A0* __mem_cgroup_(un)charge_kmem(), that does not. This later exists
> =A0 because the slub allocator draws the larger kmalloc allocations
> =A0 from the page allocator.
>
> In memcontrol.h those functions are wrapped in inline acessors.
> The idea is to later on, patch those with jump labels, so we don't
> incur any overhead when no mem cgroups are being used.
>
> Because the slub allocator tends to inline the allocations whenever
> it can, those functions need to be exported so modules can make use
> of it properly.
>
> I apologize in advance to the reviewers. This patch is quite big, but
> I was not able to split it any further due to all the dependencies
> between the code.
>
> This code is inspired by the code written by Suleiman Souhlal,
> but heavily changed.
>
> Signed-off-by: Glauber Costa <glommer@parallels.com>
> CC: Christoph Lameter <cl@linux.com>
> CC: Pekka Enberg <penberg@cs.helsinki.fi>
> CC: Michal Hocko <mhocko@suse.cz>
> CC: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> CC: Johannes Weiner <hannes@cmpxchg.org>
> CC: Suleiman Souhlal <suleiman@google.com>
> ---
> =A0include/linux/memcontrol.h | =A0 68 ++++++++
> =A0init/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A02 +-
> =A0mm/memcontrol.c =A0 =A0 =A0 =A0 =A0 =A0| =A0373 ++++++++++++++++++++++=
+++++++++++++++++++++-
> =A03 files changed, 441 insertions(+), 2 deletions(-)
>

> +
> +static struct kmem_cache *memcg_create_kmem_cache(struct mem_cgroup *mem=
cg,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 struct kmem_cache *cachep)
> +{
> + =A0 =A0 =A0 struct kmem_cache *new_cachep;
> + =A0 =A0 =A0 int idx;
> +
> + =A0 =A0 =A0 BUG_ON(!mem_cgroup_kmem_enabled(memcg));
> +
> + =A0 =A0 =A0 idx =3D cachep->memcg_params.id;
> +
> + =A0 =A0 =A0 mutex_lock(&memcg_cache_mutex);
> + =A0 =A0 =A0 new_cachep =3D memcg->slabs[idx];
> + =A0 =A0 =A0 if (new_cachep)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
> +
> + =A0 =A0 =A0 new_cachep =3D kmem_cache_dup(memcg, cachep);
> +
> + =A0 =A0 =A0 if (new_cachep =3D=3D NULL) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 new_cachep =3D cachep;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 mem_cgroup_get(memcg);
> + =A0 =A0 =A0 memcg->slabs[idx] =3D new_cachep;
> + =A0 =A0 =A0 new_cachep->memcg_params.memcg =3D memcg;
> +out:
> + =A0 =A0 =A0 mutex_unlock(&memcg_cache_mutex);
> + =A0 =A0 =A0 return new_cachep;
> +}
> +
> +struct create_work {
> + =A0 =A0 =A0 struct mem_cgroup *memcg;
> + =A0 =A0 =A0 struct kmem_cache *cachep;
> + =A0 =A0 =A0 struct list_head list;
> +};
> +
> +/* Use a single spinlock for destruction and creation, not a frequent op=
 */
> +static DEFINE_SPINLOCK(cache_queue_lock);
> +static LIST_HEAD(create_queue);
> +static LIST_HEAD(destroyed_caches);
> +
> +static void kmem_cache_destroy_work_func(struct work_struct *w)
> +{
> + =A0 =A0 =A0 struct kmem_cache *cachep;
> + =A0 =A0 =A0 char *name;
> +
> + =A0 =A0 =A0 spin_lock_irq(&cache_queue_lock);
> + =A0 =A0 =A0 while (!list_empty(&destroyed_caches)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 cachep =3D container_of(list_first_entry(&d=
estroyed_caches,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct mem_cgroup_cache_params, des=
troyed_list), struct
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 kmem_cache, memcg_params);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 name =3D (char *)cachep->name;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_del(&cachep->memcg_params.destroyed_li=
st);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock_irq(&cache_queue_lock);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 synchronize_rcu();

Is this synchronize_rcu() still needed, now that we don't use RCU to
protect memcgs from disappearing during allocation anymore?

Also, should we drop the memcg reference we got in
memcg_create_kmem_cache() here?

> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 kmem_cache_destroy(cachep);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 kfree(name);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_lock_irq(&cache_queue_lock);
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 spin_unlock_irq(&cache_queue_lock);
> +}
> +static DECLARE_WORK(kmem_cache_destroy_work, kmem_cache_destroy_work_fun=
c);
> +
> +void mem_cgroup_destroy_cache(struct kmem_cache *cachep)
> +{
> + =A0 =A0 =A0 unsigned long flags;
> +
> + =A0 =A0 =A0 BUG_ON(cachep->memcg_params.id !=3D -1);
> +
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* We have to defer the actual destroying to a workqueue,=
 because
> + =A0 =A0 =A0 =A0* we might currently be in a context that cannot sleep.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 spin_lock_irqsave(&cache_queue_lock, flags);
> + =A0 =A0 =A0 list_add(&cachep->memcg_params.destroyed_list, &destroyed_c=
aches);
> + =A0 =A0 =A0 spin_unlock_irqrestore(&cache_queue_lock, flags);
> +
> + =A0 =A0 =A0 schedule_work(&kmem_cache_destroy_work);
> +}
> +
> +
> +/*
> + * Flush the queue of kmem_caches to create, because we're creating a cg=
roup.
> + *
> + * We might end up flushing other cgroups' creation requests as well, bu=
t
> + * they will just get queued again next time someone tries to make a sla=
b
> + * allocation for them.
> + */
> +void mem_cgroup_flush_cache_create_queue(void)
> +{
> + =A0 =A0 =A0 struct create_work *cw, *tmp;
> + =A0 =A0 =A0 unsigned long flags;
> +
> + =A0 =A0 =A0 spin_lock_irqsave(&cache_queue_lock, flags);
> + =A0 =A0 =A0 list_for_each_entry_safe(cw, tmp, &create_queue, list) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_del(&cw->list);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 kfree(cw);
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 spin_unlock_irqrestore(&cache_queue_lock, flags);
> +}
> +
> +static void memcg_create_cache_work_func(struct work_struct *w)
> +{
> + =A0 =A0 =A0 struct kmem_cache *cachep;
> + =A0 =A0 =A0 struct create_work *cw;
> +
> + =A0 =A0 =A0 spin_lock_irq(&cache_queue_lock);
> + =A0 =A0 =A0 while (!list_empty(&create_queue)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 cw =3D list_first_entry(&create_queue, stru=
ct create_work, list);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_del(&cw->list);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock_irq(&cache_queue_lock);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 cachep =3D memcg_create_kmem_cache(cw->memc=
g, cw->cachep);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (cachep =3D=3D NULL)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_ALERT
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 "%s: Couldn't create memcg-=
cache for %s memcg %s\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __func__, cw->cachep->name,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 cw->memcg->css.cgroup->dent=
ry->d_name.name);

We might need rcu_dereference() here (and hold rcu_read_lock()).
Or we could just remove this message.

> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Drop the reference gotten when we enqueu=
ed. */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 css_put(&cw->memcg->css);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 kfree(cw);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_lock_irq(&cache_queue_lock);
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 spin_unlock_irq(&cache_queue_lock);
> +}
> +
> +static DECLARE_WORK(memcg_create_cache_work, memcg_create_cache_work_fun=
c);
> +
> +/*
> + * Enqueue the creation of a per-memcg kmem_cache.
> + * Called with rcu_read_lock.
> + */
> +static void memcg_create_cache_enqueue(struct mem_cgroup *memcg,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0struct kmem_cache *cachep)
> +{
> + =A0 =A0 =A0 struct create_work *cw;
> + =A0 =A0 =A0 unsigned long flags;
> +
> + =A0 =A0 =A0 spin_lock_irqsave(&cache_queue_lock, flags);
> + =A0 =A0 =A0 list_for_each_entry(cw, &create_queue, list) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (cw->memcg =3D=3D memcg && cw->cachep =
=3D=3D cachep) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock_irqrestore(&cac=
he_queue_lock, flags);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 spin_unlock_irqrestore(&cache_queue_lock, flags);
> +
> + =A0 =A0 =A0 /* The corresponding put will be done in the workqueue. */
> + =A0 =A0 =A0 if (!css_tryget(&memcg->css))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> +
> + =A0 =A0 =A0 cw =3D kmalloc_no_account(sizeof(struct create_work), GFP_N=
OWAIT);
> + =A0 =A0 =A0 if (cw =3D=3D NULL) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 css_put(&memcg->css);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 cw->memcg =3D memcg;
> + =A0 =A0 =A0 cw->cachep =3D cachep;
> + =A0 =A0 =A0 spin_lock_irqsave(&cache_queue_lock, flags);
> + =A0 =A0 =A0 list_add_tail(&cw->list, &create_queue);
> + =A0 =A0 =A0 spin_unlock_irqrestore(&cache_queue_lock, flags);
> +
> + =A0 =A0 =A0 schedule_work(&memcg_create_cache_work);
> +}
> +
> +/*
> + * Return the kmem_cache we're supposed to use for a slab allocation.
> + * If we are in interrupt context or otherwise have an allocation that
> + * can't fail, we return the original cache.
> + * Otherwise, we will try to use the current memcg's version of the cach=
e.
> + *
> + * If the cache does not exist yet, if we are the first user of it,
> + * we either create it immediately, if possible, or create it asynchrono=
usly
> + * in a workqueue.
> + * In the latter case, we will let the current allocation go through wit=
h
> + * the original cache.
> + *
> + * This function returns with rcu_read_lock() held.
> + */
> +struct kmem_cache *__mem_cgroup_get_kmem_cache(struct kmem_cache *cachep=
,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0gfp_t gfp)
> +{
> + =A0 =A0 =A0 struct mem_cgroup *memcg;
> + =A0 =A0 =A0 int idx;
> +
> + =A0 =A0 =A0 gfp |=3D =A0cachep->allocflags;
> +
> + =A0 =A0 =A0 if ((current->mm =3D=3D NULL))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return cachep;
> +
> + =A0 =A0 =A0 if (cachep->memcg_params.memcg)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return cachep;
> +
> + =A0 =A0 =A0 idx =3D cachep->memcg_params.id;
> + =A0 =A0 =A0 VM_BUG_ON(idx =3D=3D -1);
> +
> + =A0 =A0 =A0 memcg =3D mem_cgroup_from_task(current);
> + =A0 =A0 =A0 if (!mem_cgroup_kmem_enabled(memcg))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return cachep;
> +
> + =A0 =A0 =A0 if (rcu_access_pointer(memcg->slabs[idx]) =3D=3D NULL) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 memcg_create_cache_enqueue(memcg, cachep);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return cachep;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 return rcu_dereference(memcg->slabs[idx]);

Is it ok to call rcu_access_pointer() and rcu_dereference() without
holding rcu_read_lock()?

> +}
> +EXPORT_SYMBOL(__mem_cgroup_get_kmem_cache);
> +
> +void mem_cgroup_remove_child_kmem_cache(struct kmem_cache *cachep, int i=
d)
> +{
> + =A0 =A0 =A0 rcu_assign_pointer(cachep->memcg_params.memcg->slabs[id], N=
ULL);
> +}
> +
> +bool __mem_cgroup_charge_kmem(gfp_t gfp, size_t size)
> +{
> + =A0 =A0 =A0 struct mem_cgroup *memcg;
> + =A0 =A0 =A0 bool ret =3D true;
> +
> + =A0 =A0 =A0 rcu_read_lock();
> + =A0 =A0 =A0 memcg =3D mem_cgroup_from_task(current);
> +
> + =A0 =A0 =A0 if (!mem_cgroup_kmem_enabled(memcg))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
> +
> + =A0 =A0 =A0 mem_cgroup_get(memcg);

Why do we need to get a reference to the memcg for every charge?
How will this work when deleting a memcg?

> + =A0 =A0 =A0 ret =3D memcg_charge_kmem(memcg, gfp, size) =3D=3D 0;
> + =A0 =A0 =A0 if (ret)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_put(memcg);
> +out:
> + =A0 =A0 =A0 rcu_read_unlock();
> + =A0 =A0 =A0 return ret;
> +}
> +EXPORT_SYMBOL(__mem_cgroup_charge_kmem);
> +
> +void __mem_cgroup_uncharge_kmem(size_t size)
> +{
> + =A0 =A0 =A0 struct mem_cgroup *memcg;
> +
> + =A0 =A0 =A0 rcu_read_lock();
> + =A0 =A0 =A0 memcg =3D mem_cgroup_from_task(current);
> +
> + =A0 =A0 =A0 if (!mem_cgroup_kmem_enabled(memcg))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
> +
> + =A0 =A0 =A0 mem_cgroup_put(memcg);
> + =A0 =A0 =A0 memcg_uncharge_kmem(memcg, size);
> +out:
> + =A0 =A0 =A0 rcu_read_unlock();
> +}
> +EXPORT_SYMBOL(__mem_cgroup_uncharge_kmem);
> +
> +bool __mem_cgroup_charge_slab(struct kmem_cache *cachep, gfp_t gfp, size=
_t size)
> +{
> + =A0 =A0 =A0 struct mem_cgroup *memcg;
> + =A0 =A0 =A0 bool ret =3D true;
> +
> + =A0 =A0 =A0 rcu_read_lock();
> + =A0 =A0 =A0 memcg =3D cachep->memcg_params.memcg;
> + =A0 =A0 =A0 if (!mem_cgroup_kmem_enabled(memcg))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
> +
> + =A0 =A0 =A0 ret =3D memcg_charge_kmem(memcg, gfp, size) =3D=3D 0;
> +out:
> + =A0 =A0 =A0 rcu_read_unlock();
> + =A0 =A0 =A0 return ret;
> +}
> +EXPORT_SYMBOL(__mem_cgroup_charge_slab);
> +
> +void __mem_cgroup_uncharge_slab(struct kmem_cache *cachep, size_t size)
> +{
> + =A0 =A0 =A0 struct mem_cgroup *memcg;
> +
> + =A0 =A0 =A0 rcu_read_lock();
> + =A0 =A0 =A0 memcg =3D cachep->memcg_params.memcg;
> +
> + =A0 =A0 =A0 if (!mem_cgroup_kmem_enabled(memcg)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 rcu_read_unlock();
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 rcu_read_unlock();
> +
> + =A0 =A0 =A0 memcg_uncharge_kmem(memcg, size);
> +}
> +EXPORT_SYMBOL(__mem_cgroup_uncharge_slab);
> +
> +static void memcg_slab_init(struct mem_cgroup *memcg)
> +{
> + =A0 =A0 =A0 int i;
> +
> + =A0 =A0 =A0 for (i =3D 0; i < MAX_KMEM_CACHE_TYPES; i++)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 rcu_assign_pointer(memcg->slabs[i], NULL);
> +}
> =A0#endif /* CONFIG_CGROUP_MEM_RES_CTLR_KMEM */
>
> =A0static void drain_all_stock_async(struct mem_cgroup *memcg);
> @@ -4790,7 +5103,11 @@ static struct cftype kmem_cgroup_files[] =3D {
>
> =A0static int memcg_init_kmem(struct mem_cgroup *memcg, struct cgroup_sub=
sys *ss)
> =A0{
> - =A0 =A0 =A0 return mem_cgroup_sockets_init(memcg, ss);
> + =A0 =A0 =A0 int ret =3D mem_cgroup_sockets_init(memcg, ss);
> +
> + =A0 =A0 =A0 if (!ret)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 memcg_slab_init(memcg);
> + =A0 =A0 =A0 return ret;
> =A0};
>
> =A0static void kmem_cgroup_destroy(struct mem_cgroup *memcg)
> @@ -5805,3 +6122,57 @@ static int __init enable_swap_account(char *s)
> =A0__setup("swapaccount=3D", enable_swap_account);
>
> =A0#endif
> +
> +#ifdef CONFIG_CGROUP_MEM_RES_CTLR_KMEM
> +int memcg_charge_kmem(struct mem_cgroup *memcg, gfp_t gfp, s64 delta)
> +{
> + =A0 =A0 =A0 struct res_counter *fail_res;
> + =A0 =A0 =A0 struct mem_cgroup *_memcg;
> + =A0 =A0 =A0 int may_oom, ret;
> + =A0 =A0 =A0 bool nofail =3D false;
> +
> + =A0 =A0 =A0 may_oom =3D (gfp & __GFP_WAIT) && (gfp & __GFP_FS) &&
> + =A0 =A0 =A0 =A0 =A0 !(gfp & __GFP_NORETRY);
> +
> + =A0 =A0 =A0 ret =3D 0;
> +
> + =A0 =A0 =A0 if (!memcg)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return ret;
> +
> + =A0 =A0 =A0 _memcg =3D memcg;
> + =A0 =A0 =A0 ret =3D __mem_cgroup_try_charge(NULL, gfp, delta / PAGE_SIZ=
E,
> + =A0 =A0 =A0 =A0 =A0 &_memcg, may_oom);
> + =A0 =A0 =A0 if (ret =3D=3D -ENOMEM)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return ret;
> + =A0 =A0 =A0 else if ((ret =3D=3D -EINTR) || (ret && (gfp & __GFP_NOFAIL=
))) =A0{
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 nofail =3D true;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* __mem_cgroup_try_charge() chose to byp=
ass to root due
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* to OOM kill or fatal signal.
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Since our only options are to either f=
ail the
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* allocation or charge it to this cgroup=
, force the
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* change, going above the limit if neede=
d.
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 res_counter_charge_nofail(&memcg->res, delt=
a, &fail_res);

We might need to charge memsw here too.

> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 if (nofail)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 res_counter_charge_nofail(&memcg->kmem, del=
ta, &fail_res);
> + =A0 =A0 =A0 else
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D res_counter_charge(&memcg->kmem, de=
lta, &fail_res);
> +
> + =A0 =A0 =A0 if (ret)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 res_counter_uncharge(&memcg->res, delta);
> +
> + =A0 =A0 =A0 return ret;
> +}
> +
> +void memcg_uncharge_kmem(struct mem_cgroup *memcg, s64 delta)
> +{
> + =A0 =A0 =A0 if (!memcg)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> +
> + =A0 =A0 =A0 res_counter_uncharge(&memcg->kmem, delta);
> + =A0 =A0 =A0 res_counter_uncharge(&memcg->res, delta);

Might need to uncharge memsw.

> +}
> +#endif /* CONFIG_CGROUP_MEM_RES_CTLR_KMEM */
> --
> 1.7.7.6
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
