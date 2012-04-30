Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id 37C646B0044
	for <linux-mm@kvack.org>; Mon, 30 Apr 2012 15:51:20 -0400 (EDT)
Received: by qcsd16 with SMTP id d16so2047059qcs.14
        for <linux-mm@kvack.org>; Mon, 30 Apr 2012 12:51:19 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1334959051-18203-12-git-send-email-glommer@parallels.com>
References: <1334959051-18203-1-git-send-email-glommer@parallels.com>
	<1334959051-18203-12-git-send-email-glommer@parallels.com>
Date: Mon, 30 Apr 2012 12:51:18 -0700
Message-ID: <CABCjUKCW+SS8R1pUarkE4D3fvy8AchOBtkDnqLzrkqervWe-Kg@mail.gmail.com>
Subject: Re: [PATCH 11/23] slub: consider a memcg parameter in kmem_create_cache
From: Suleiman Souhlal <suleiman@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@openvz.org, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Frederic Weisbecker <fweisbec@gmail.com>, Greg Thelen <gthelen@google.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@cs.helsinki.fi>

On Fri, Apr 20, 2012 at 2:57 PM, Glauber Costa <glommer@parallels.com> wrot=
e:
> Allow a memcg parameter to be passed during cache creation.
> The slub allocator will only merge caches that belong to
> the same memcg.
>
> Default function is created as a wrapper, passing NULL
> to the memcg version. We only merge caches that belong
> to the same memcg.
>
> From the memcontrol.c side, 3 helper functions are created:
>
> =A01) memcg_css_id: because slub needs a unique cache name
> =A0 =A0for sysfs. Since this is visible, but not the canonical
> =A0 =A0location for slab data, the cache name is not used, the
> =A0 =A0css_id should suffice.
>
> =A02) mem_cgroup_register_cache: is responsible for assigning
> =A0 =A0a unique index to each cache, and other general purpose
> =A0 =A0setup. The index is only assigned for the root caches. All
> =A0 =A0others are assigned index =3D=3D -1.
>
> =A03) mem_cgroup_release_cache: can be called from the root cache
> =A0 =A0destruction, and will release the index for other caches.
>
> This index mechanism was developed by Suleiman Souhlal.
>
> Signed-off-by: Glauber Costa <glommer@parallels.com>
> CC: Christoph Lameter <cl@linux.com>
> CC: Pekka Enberg <penberg@cs.helsinki.fi>
> CC: Michal Hocko <mhocko@suse.cz>
> CC: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> CC: Johannes Weiner <hannes@cmpxchg.org>
> CC: Suleiman Souhlal <suleiman@google.com>
> ---
> =A0include/linux/memcontrol.h | =A0 14 ++++++++++++++
> =A0include/linux/slab.h =A0 =A0 =A0 | =A0 =A06 ++++++
> =A0mm/memcontrol.c =A0 =A0 =A0 =A0 =A0 =A0| =A0 29 ++++++++++++++++++++++=
+++++++
> =A0mm/slub.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 31 ++++++++++++++++=
+++++++++++----
> =A04 files changed, 76 insertions(+), 4 deletions(-)
>
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index f94efd2..99e14b9 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -26,6 +26,7 @@ struct mem_cgroup;
> =A0struct page_cgroup;
> =A0struct page;
> =A0struct mm_struct;
> +struct kmem_cache;
>
> =A0/* Stats that can be updated by kernel. */
> =A0enum mem_cgroup_page_stat_item {
> @@ -440,7 +441,20 @@ struct sock;
> =A0#ifdef CONFIG_CGROUP_MEM_RES_CTLR_KMEM
> =A0void sock_update_memcg(struct sock *sk);
> =A0void sock_release_memcg(struct sock *sk);
> +int memcg_css_id(struct mem_cgroup *memcg);
> +void mem_cgroup_register_cache(struct mem_cgroup *memcg,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 struct kmem_cache *s);
> +void mem_cgroup_release_cache(struct kmem_cache *cachep);
> =A0#else
> +static inline void mem_cgroup_register_cache(struct mem_cgroup *memcg,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0struct kmem_cache *s)
> +{
> +}
> +
> +static inline void mem_cgroup_release_cache(struct kmem_cache *cachep)
> +{
> +}
> +
> =A0static inline void sock_update_memcg(struct sock *sk)
> =A0{
> =A0}
> diff --git a/include/linux/slab.h b/include/linux/slab.h
> index a5127e1..c7a7e05 100644
> --- a/include/linux/slab.h
> +++ b/include/linux/slab.h
> @@ -321,6 +321,12 @@ extern void *__kmalloc_track_caller(size_t, gfp_t, u=
nsigned long);
> =A0 =A0 =A0 =A0__kmalloc(size, flags)
> =A0#endif /* DEBUG_SLAB */
>
> +#ifdef CONFIG_CGROUP_MEM_RES_CTLR_KMEM
> +#define MAX_KMEM_CACHE_TYPES 400
> +#else
> +#define MAX_KMEM_CACHE_TYPES 0
> +#endif /* CONFIG_CGROUP_MEM_RES_CTLR_KMEM */
> +
> =A0#ifdef CONFIG_NUMA
> =A0/*
> =A0* kmalloc_node_track_caller is a special version of kmalloc_node that
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 36f1e6b..0015ed0 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -323,6 +323,11 @@ struct mem_cgroup {
> =A0#endif
> =A0};
>
> +int memcg_css_id(struct mem_cgroup *memcg)
> +{
> + =A0 =A0 =A0 return css_id(&memcg->css);
> +}
> +
> =A0/* Stuffs for move charges at task migration. */
> =A0/*
> =A0* Types of charges to be moved. "move_charge_at_immitgrate" is treated=
 as a
> @@ -461,6 +466,30 @@ struct cg_proto *tcp_proto_cgroup(struct mem_cgroup =
*memcg)
> =A0}
> =A0EXPORT_SYMBOL(tcp_proto_cgroup);
> =A0#endif /* CONFIG_INET */
> +
> +/* Bitmap used for allocating the cache id numbers. */
> +static DECLARE_BITMAP(cache_types, MAX_KMEM_CACHE_TYPES);
> +
> +void mem_cgroup_register_cache(struct mem_cgroup *memcg,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct kmem_=
cache *cachep)
> +{
> + =A0 =A0 =A0 int id =3D -1;
> +
> + =A0 =A0 =A0 cachep->memcg_params.memcg =3D memcg;
> +
> + =A0 =A0 =A0 if (!memcg) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 id =3D find_first_zero_bit(cache_types, MAX=
_KMEM_CACHE_TYPES);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 BUG_ON(id < 0 || id >=3D MAX_KMEM_CACHE_TYP=
ES);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 __set_bit(id, cache_types);
> + =A0 =A0 =A0 } else
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 INIT_LIST_HEAD(&cachep->memcg_params.destro=
yed_list);
> + =A0 =A0 =A0 cachep->memcg_params.id =3D id;
> +}
> +
> +void mem_cgroup_release_cache(struct kmem_cache *cachep)
> +{
> + =A0 =A0 =A0 __clear_bit(cachep->memcg_params.id, cache_types);
> +}
> =A0#endif /* CONFIG_CGROUP_MEM_RES_CTLR_KMEM */
>
> =A0static void drain_all_stock_async(struct mem_cgroup *memcg);
> diff --git a/mm/slub.c b/mm/slub.c
> index 2652e7c..86e40cc 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -32,6 +32,7 @@
> =A0#include <linux/prefetch.h>
>
> =A0#include <trace/events/kmem.h>
> +#include <linux/memcontrol.h>
>
> =A0/*
> =A0* Lock order:
> @@ -3880,7 +3881,7 @@ static int slab_unmergeable(struct kmem_cache *s)
> =A0 =A0 =A0 =A0return 0;
> =A0}
>
> -static struct kmem_cache *find_mergeable(size_t size,
> +static struct kmem_cache *find_mergeable(struct mem_cgroup *memcg, size_=
t size,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0size_t align, unsigned long flags, const c=
har *name,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0void (*ctor)(void *))
> =A0{
> @@ -3916,21 +3917,29 @@ static struct kmem_cache *find_mergeable(size_t s=
ize,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (s->size - size >=3D sizeof(void *))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0continue;
>
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (memcg && s->memcg_params.memcg !=3D mem=
cg)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
> +
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return s;
> =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0return NULL;
> =A0}
>
> -struct kmem_cache *kmem_cache_create(const char *name, size_t size,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 size_t align, unsigned long flags, void (*c=
tor)(void *))
> +struct kmem_cache *
> +kmem_cache_create_memcg(struct mem_cgroup *memcg, const char *name, size=
_t size,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 size_t align, unsigned long=
 flags, void (*ctor)(void *))
> =A0{
> =A0 =A0 =A0 =A0struct kmem_cache *s;
>
> =A0 =A0 =A0 =A0if (WARN_ON(!name))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return NULL;
>
> +#ifndef CONFIG_CGROUP_MEM_RES_CTLR_KMEM
> + =A0 =A0 =A0 WARN_ON(memcg !=3D NULL);
> +#endif
> +
> =A0 =A0 =A0 =A0down_write(&slub_lock);
> - =A0 =A0 =A0 s =3D find_mergeable(size, align, flags, name, ctor);
> + =A0 =A0 =A0 s =3D find_mergeable(memcg, size, align, flags, name, ctor)=
;
> =A0 =A0 =A0 =A0if (s) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0s->refcount++;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/*
> @@ -3954,12 +3963,15 @@ struct kmem_cache *kmem_cache_create(const char *=
name, size_t size,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0size, alig=
n, flags, ctor)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0list_add(&s->list, &slab_c=
aches);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0up_write(&slub_lock);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_register_cache(m=
emcg, s);

Do the kmalloc caches get their id registered correctly?

-- Suleiman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
