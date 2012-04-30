Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 6C3F86B0044
	for <linux-mm@kvack.org>; Mon, 30 Apr 2012 17:25:48 -0400 (EDT)
Received: by obbwd18 with SMTP id wd18so2301936obb.14
        for <linux-mm@kvack.org>; Mon, 30 Apr 2012 14:25:47 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1335138820-26590-8-git-send-email-glommer@parallels.com>
References: <1334959051-18203-1-git-send-email-glommer@parallels.com>
	<1335138820-26590-8-git-send-email-glommer@parallels.com>
Date: Mon, 30 Apr 2012 14:25:47 -0700
Message-ID: <CABCjUKCX6MvOaS5s_n6tYcmfyDCgW60aXTG8ZbznmZOAfS=joA@mail.gmail.com>
Subject: Re: [PATCH 19/23] slab: per-memcg accounting of slab caches
From: Suleiman Souhlal <suleiman@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@openvz.org, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, fweisbec@gmail.com, Greg Thelen <gthelen@google.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@cs.helsinki.fi>

On Sun, Apr 22, 2012 at 4:53 PM, Glauber Costa <glommer@parallels.com> wrot=
e:
> This patch charges allocation of a slab object to a particular
> memcg.
>
> The cache is selected with mem_cgroup_get_kmem_cache(),
> which is the biggest overhead we pay here, because
> it happens at all allocations. However, other than forcing
> a function call, this function is not very expensive, and
> try to return as soon as we realize we are not a memcg cache.
>
> The charge/uncharge functions are heavier, but are only called
> for new page allocations.
>
> Code is heavily inspired by Suleiman's, with adaptations to
> the patchset and minor simplifications by me.
>
> Signed-off-by: Glauber Costa <glommer@parallels.com>
> CC: Christoph Lameter <cl@linux.com>
> CC: Pekka Enberg <penberg@cs.helsinki.fi>
> CC: Michal Hocko <mhocko@suse.cz>
> CC: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> CC: Johannes Weiner <hannes@cmpxchg.org>
> CC: Suleiman Souhlal <suleiman@google.com>
> ---
> =A0include/linux/slab_def.h | =A0 66 ++++++++++++++++++++++++++++-
> =A0mm/slab.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0105 ++++++++++++++++++++=
++++++++++++++++++++++----
> =A02 files changed, 162 insertions(+), 9 deletions(-)
>
> diff --git a/include/linux/slab_def.h b/include/linux/slab_def.h
> index 54d25d7..c4f7e45 100644
> --- a/include/linux/slab_def.h
> +++ b/include/linux/slab_def.h
> @@ -51,7 +51,7 @@ struct kmem_cache {
> =A0 =A0 =A0 =A0void (*ctor)(void *obj);
>
> =A0/* 4) cache creation/removal */
> - =A0 =A0 =A0 const char *name;
> + =A0 =A0 =A0 char *name;
> =A0 =A0 =A0 =A0struct list_head next;
>
> =A0/* 5) statistics */
> @@ -219,4 +219,68 @@ found:
>
> =A0#endif /* CONFIG_NUMA */
>
> +#ifdef CONFIG_CGROUP_MEM_RES_CTLR_KMEM
> +
> +void kmem_cache_drop_ref(struct kmem_cache *cachep);
> +
> +static inline void
> +kmem_cache_get_ref(struct kmem_cache *cachep)
> +{
> + =A0 =A0 =A0 if (cachep->memcg_params.id =3D=3D -1 &&
> + =A0 =A0 =A0 =A0 =A0 unlikely(!atomic_add_unless(&cachep->memcg_params.r=
efcnt, 1, 0)))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 BUG();
> +}
> +
> +static inline void
> +mem_cgroup_put_kmem_cache(struct kmem_cache *cachep)
> +{
> + =A0 =A0 =A0 rcu_read_unlock();
> +}
> +
> +static inline void
> +mem_cgroup_kmem_cache_prepare_sleep(struct kmem_cache *cachep)
> +{
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* Make sure the cache doesn't get freed while we have in=
terrupts
> + =A0 =A0 =A0 =A0* enabled.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 kmem_cache_get_ref(cachep);
> + =A0 =A0 =A0 rcu_read_unlock();
> +}
> +
> +static inline void
> +mem_cgroup_kmem_cache_finish_sleep(struct kmem_cache *cachep)
> +{
> + =A0 =A0 =A0 rcu_read_lock();
> + =A0 =A0 =A0 kmem_cache_drop_ref(cachep);
> +}
> +
> +#else /* CONFIG_CGROUP_MEM_RES_CTLR_KMEM */
> +
> +static inline void
> +kmem_cache_get_ref(struct kmem_cache *cachep)
> +{
> +}
> +
> +static inline void
> +kmem_cache_drop_ref(struct kmem_cache *cachep)
> +{
> +}
> +
> +static inline void
> +mem_cgroup_put_kmem_cache(struct kmem_cache *cachep)
> +{
> +}
> +
> +static inline void
> +mem_cgroup_kmem_cache_prepare_sleep(struct kmem_cache *cachep)
> +{
> +}
> +
> +static inline void
> +mem_cgroup_kmem_cache_finish_sleep(struct kmem_cache *cachep)
> +{
> +}
> +#endif /* CONFIG_CGROUP_MEM_RES_CTLR_KMEM */
> +
> =A0#endif /* _LINUX_SLAB_DEF_H */
> diff --git a/mm/slab.c b/mm/slab.c
> index 13948c3..ac0916b 100644
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -1818,20 +1818,28 @@ static void *kmem_getpages(struct kmem_cache *cac=
hep, gfp_t flags, int nodeid)
> =A0 =A0 =A0 =A0if (cachep->flags & SLAB_RECLAIM_ACCOUNT)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0flags |=3D __GFP_RECLAIMABLE;
>
> + =A0 =A0 =A0 nr_pages =3D (1 << cachep->gfporder);
> + =A0 =A0 =A0 if (!mem_cgroup_charge_slab(cachep, flags, nr_pages * PAGE_=
SIZE))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NULL;
> +
> =A0 =A0 =A0 =A0page =3D alloc_pages_exact_node(nodeid, flags | __GFP_NOTR=
ACK, cachep->gfporder);
> =A0 =A0 =A0 =A0if (!page) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!(flags & __GFP_NOWARN) && printk_rate=
limit())
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0slab_out_of_memory(cachep,=
 flags, nodeid);
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_uncharge_slab(cachep, nr_pages *=
 PAGE_SIZE);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return NULL;
> =A0 =A0 =A0 =A0}
>
> - =A0 =A0 =A0 nr_pages =3D (1 << cachep->gfporder);
> =A0 =A0 =A0 =A0if (cachep->flags & SLAB_RECLAIM_ACCOUNT)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0add_zone_page_state(page_zone(page),
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0NR_SLAB_RECLAIMABLE, nr_pa=
ges);
> =A0 =A0 =A0 =A0else
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0add_zone_page_state(page_zone(page),
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0NR_SLAB_UNRECLAIMABLE, nr_=
pages);
> +
> + =A0 =A0 =A0 kmem_cache_get_ref(cachep);
> +
> =A0 =A0 =A0 =A0for (i =3D 0; i < nr_pages; i++)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__SetPageSlab(page + i);
>
> @@ -1864,6 +1872,8 @@ static void kmem_freepages(struct kmem_cache *cache=
p, void *addr)
> =A0 =A0 =A0 =A0else
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sub_zone_page_state(page_zone(page),
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0NR_SLAB_UN=
RECLAIMABLE, nr_freed);
> + =A0 =A0 =A0 mem_cgroup_uncharge_slab(cachep, i * PAGE_SIZE);
> + =A0 =A0 =A0 kmem_cache_drop_ref(cachep);
> =A0 =A0 =A0 =A0while (i--) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0BUG_ON(!PageSlab(page));
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__ClearPageSlab(page);
> @@ -2823,12 +2833,28 @@ void kmem_cache_destroy(struct kmem_cache *cachep=
)
> =A0 =A0 =A0 =A0if (unlikely(cachep->flags & SLAB_DESTROY_BY_RCU))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0rcu_barrier();
>
> +#ifdef CONFIG_CGROUP_MEM_RES_CTLR_KMEM
> + =A0 =A0 =A0 /* Not a memcg cache */
> + =A0 =A0 =A0 if (cachep->memcg_params.id !=3D -1) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_release_cache(cachep);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_flush_cache_create_queue();
> + =A0 =A0 =A0 }
> +#endif
> =A0 =A0 =A0 =A0__kmem_cache_destroy(cachep);
> =A0 =A0 =A0 =A0mutex_unlock(&cache_chain_mutex);
> =A0 =A0 =A0 =A0put_online_cpus();
> =A0}
> =A0EXPORT_SYMBOL(kmem_cache_destroy);
>
> +#ifdef CONFIG_CGROUP_MEM_RES_CTLR_KMEM
> +void kmem_cache_drop_ref(struct kmem_cache *cachep)
> +{
> + =A0 =A0 =A0 if (cachep->memcg_params.id =3D=3D -1 &&
> + =A0 =A0 =A0 =A0 =A0 unlikely(atomic_dec_and_test(&cachep->memcg_params.=
refcnt)))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_destroy_cache(cachep);
> +}
> +#endif /* CONFIG_CGROUP_MEM_RES_CTLR_KMEM */
> +
> =A0/*
> =A0* Get the memory for a slab management obj.
> =A0* For a slab cache when the slab descriptor is off-slab, slab descript=
ors
> @@ -3028,8 +3054,10 @@ static int cache_grow(struct kmem_cache *cachep,
>
> =A0 =A0 =A0 =A0offset *=3D cachep->colour_off;
>
> - =A0 =A0 =A0 if (local_flags & __GFP_WAIT)
> + =A0 =A0 =A0 if (local_flags & __GFP_WAIT) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0local_irq_enable();
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_kmem_cache_prepare_sleep(cachep)=
;
> + =A0 =A0 =A0 }
>
> =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 * The test for missing atomic flag is performed here, rat=
her than
> @@ -3058,8 +3086,10 @@ static int cache_grow(struct kmem_cache *cachep,
>
> =A0 =A0 =A0 =A0cache_init_objs(cachep, slabp);
>
> - =A0 =A0 =A0 if (local_flags & __GFP_WAIT)
> + =A0 =A0 =A0 if (local_flags & __GFP_WAIT) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0local_irq_disable();
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_kmem_cache_finish_sleep(cachep);
> + =A0 =A0 =A0 }
> =A0 =A0 =A0 =A0check_irq_off();
> =A0 =A0 =A0 =A0spin_lock(&l3->list_lock);
>
> @@ -3072,8 +3102,10 @@ static int cache_grow(struct kmem_cache *cachep,
> =A0opps1:
> =A0 =A0 =A0 =A0kmem_freepages(cachep, objp);
> =A0failed:
> - =A0 =A0 =A0 if (local_flags & __GFP_WAIT)
> + =A0 =A0 =A0 if (local_flags & __GFP_WAIT) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0local_irq_disable();
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_kmem_cache_finish_sleep(cachep);
> + =A0 =A0 =A0 }
> =A0 =A0 =A0 =A0return 0;
> =A0}
>
> @@ -3834,11 +3866,15 @@ static inline void __cache_free(struct kmem_cache=
 *cachep, void *objp,
> =A0*/
> =A0void *kmem_cache_alloc(struct kmem_cache *cachep, gfp_t flags)
> =A0{
> - =A0 =A0 =A0 void *ret =3D __cache_alloc(cachep, flags, __builtin_return=
_address(0));
> + =A0 =A0 =A0 void *ret;
> +
> + =A0 =A0 =A0 rcu_read_lock();
> + =A0 =A0 =A0 cachep =3D mem_cgroup_get_kmem_cache(cachep, flags);
> + =A0 =A0 =A0 rcu_read_unlock();

Don't we need to check in_interrupt(), current, __GFP_NOFAIL every
time we call mem_cgroup_cgroup_get_kmem_cache()?

I would personally prefer if those checks were put inside
mem_cgroup_get_kmem_cache() instead of having to check for every
caller.

-- Suleiman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
