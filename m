Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id DAC686B0044
	for <linux-mm@kvack.org>; Mon, 30 Apr 2012 15:54:37 -0400 (EDT)
Received: by qcsd16 with SMTP id d16so2049328qcs.14
        for <linux-mm@kvack.org>; Mon, 30 Apr 2012 12:54:37 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1335138820-26590-1-git-send-email-glommer@parallels.com>
References: <1334959051-18203-1-git-send-email-glommer@parallels.com>
	<1335138820-26590-1-git-send-email-glommer@parallels.com>
Date: Mon, 30 Apr 2012 12:54:36 -0700
Message-ID: <CABCjUKC9aY2DYcRJH3ZANxHdJFs_rTviKMt_P6ePJKuERWzpUQ@mail.gmail.com>
Subject: Re: [PATCH 12/23] slab: pass memcg parameter to kmem_cache_create
From: Suleiman Souhlal <suleiman@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@openvz.org, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, fweisbec@gmail.com, Greg Thelen <gthelen@google.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@cs.helsinki.fi>

On Sun, Apr 22, 2012 at 4:53 PM, Glauber Costa <glommer@parallels.com> wrot=
e:
> Allow a memcg parameter to be passed during cache creation.
>
> Default function is created as a wrapper, passing NULL
> to the memcg version. We only merge caches that belong
> to the same memcg.
>
> This code was mostly written by Suleiman Souhlal and
> only adapted to my patchset, plus a couple of simplifications
>
> Signed-off-by: Glauber Costa <glommer@parallels.com>
> CC: Christoph Lameter <cl@linux.com>
> CC: Pekka Enberg <penberg@cs.helsinki.fi>
> CC: Michal Hocko <mhocko@suse.cz>
> CC: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> CC: Johannes Weiner <hannes@cmpxchg.org>
> CC: Suleiman Souhlal <suleiman@google.com>
> ---
> =A0mm/slab.c | =A0 38 +++++++++++++++++++++++++++++---------
> =A01 files changed, 29 insertions(+), 9 deletions(-)
>
> diff --git a/mm/slab.c b/mm/slab.c
> index a0d51dd..362bb6e 100644
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -2287,14 +2287,15 @@ static int __init_refok setup_cpu_cache(struct km=
em_cache *cachep, gfp_t gfp)
> =A0* cacheline. =A0This can be beneficial if you're counting cycles as cl=
osely
> =A0* as davem.
> =A0*/
> -struct kmem_cache *
> -kmem_cache_create (const char *name, size_t size, size_t align,
> - =A0 =A0 =A0 unsigned long flags, void (*ctor)(void *))
> +static struct kmem_cache *
> +__kmem_cache_create(struct mem_cgroup *memcg, const char *name, size_t s=
ize,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 size_t align, unsigned long flags, =
void (*ctor)(void *))
> =A0{
> - =A0 =A0 =A0 size_t left_over, slab_size, ralign;
> + =A0 =A0 =A0 size_t left_over, orig_align, ralign, slab_size;
> =A0 =A0 =A0 =A0struct kmem_cache *cachep =3D NULL, *pc;
> =A0 =A0 =A0 =A0gfp_t gfp;
>
> + =A0 =A0 =A0 orig_align =3D align;
> =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 * Sanity checks... these are all serious usage bugs.
> =A0 =A0 =A0 =A0 */
> @@ -2311,7 +2312,6 @@ kmem_cache_create (const char *name, size_t size, s=
ize_t align,
> =A0 =A0 =A0 =A0 */
> =A0 =A0 =A0 =A0if (slab_is_available()) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0get_online_cpus();
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 mutex_lock(&cache_chain_mutex);
> =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0list_for_each_entry(pc, &cache_chain, next) {
> @@ -2331,9 +2331,9 @@ kmem_cache_create (const char *name, size_t size, s=
ize_t align,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0continue;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!strcmp(pc->name, name)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!strcmp(pc->name, name) && !memcg) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0printk(KERN_ERR
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0"kmem_cache_=
create: duplicate cache %s\n", name);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 "kmem_cache_create: duplica=
te cache %s\n", name);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dump_stack();
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto oops;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> @@ -2434,6 +2434,9 @@ kmem_cache_create (const char *name, size_t size, s=
ize_t align,
> =A0 =A0 =A0 =A0cachep->nodelists =3D (struct kmem_list3 **)&cachep->array=
[nr_cpu_ids];
>
> =A0 =A0 =A0 =A0set_obj_size(cachep, size);
> +#ifdef CONFIG_CGROUP_MEM_RES_CTLR_KMEM
> + =A0 =A0 =A0 cachep->memcg_params.orig_align =3D orig_align;
> +#endif
> =A0#if DEBUG
>
> =A0 =A0 =A0 =A0/*
> @@ -2541,7 +2544,12 @@ kmem_cache_create (const char *name, size_t size, =
size_t align,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0BUG_ON(ZERO_OR_NULL_PTR(cachep->slabp_cach=
e));
> =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0cachep->ctor =3D ctor;
> - =A0 =A0 =A0 cachep->name =3D name;
> + =A0 =A0 =A0 cachep->name =3D (char *)name;
> +
> +#ifdef CONFIG_CGROUP_MEM_RES_CTLR_KMEM
> + =A0 =A0 =A0 mem_cgroup_register_cache(memcg, cachep);
> + =A0 =A0 =A0 atomic_set(&cachep->memcg_params.refcnt, 1);
> +#endif

cache_cache probably doesn't get its id registered correctly. :-(
We might need to add a mem_cgroup_register_cache() call to kmem_cache_init(=
).

-- Suleiman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
