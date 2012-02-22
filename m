Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 2037D6B004A
	for <linux-mm@kvack.org>; Wed, 22 Feb 2012 08:17:24 -0500 (EST)
Received: by obbta7 with SMTP id ta7so38295obb.14
        for <linux-mm@kvack.org>; Wed, 22 Feb 2012 05:17:23 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20120222115320.GA3107@x61.redhat.com>
References: <20120222115320.GA3107@x61.redhat.com>
Date: Wed, 22 Feb 2012 15:17:23 +0200
Message-ID: <CAOJsxLGz4=2tFQdnnFmGLeFVVPq8pX5=0var7V-9+ddi=TPNVA@mail.gmail.com>
Subject: Re: [PATCH] oom: add sysctl to enable slab memory dump
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rafael Aquini <aquini@redhat.com>
Cc: linux-mm@kvack.org, Randy Dunlap <rdunlap@xenotime.net>, Christoph Lameter <cl@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, Rik van Riel <riel@redhat.com>, Josef Bacik <josef@redhat.com>, linux-kernel@vger.kernel.org

On Wed, Feb 22, 2012 at 1:53 PM, Rafael Aquini <aquini@redhat.com> wrote:
> Adds a new sysctl, 'oom_dump_slabs', that enables the kernel to produce a
> dump of all eligible system slab caches when performing an OOM-killing.
> Information includes per cache active objects, total objects, object size=
,
> cache name and cache size.
>
> The eligibility for being reported is given by an auxiliary sysctl,
> 'oom_dump_slabs_ratio', which express (in percentage) the memory committe=
d
> ratio between a particular cache size and the total slab size.
>
> This, alongside with all other data dumped in OOM events, is very helpful
> information in diagnosing why there was an OOM condition specially when
> kernel code is under investigation.
>
> Signed-off-by: Rafael Aquini <aquini@redhat.com>

Makes sense. Do you have an example how an out-of-memory slab cache
dump looks like?

> diff --git a/mm/slab.c b/mm/slab.c
> index f0bd785..c2b5d14 100644
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -4629,3 +4629,75 @@ size_t ksize(const void *objp)
> =A0 =A0 =A0 =A0return obj_size(virt_to_cache(objp));
> =A0}
> =A0EXPORT_SYMBOL(ksize);
> +
> +/**
> + * oom_dump_slabs - dump top slab cache users
> + * @ratio: memory committed ratio between a cache size and the total sla=
b size
> + *
> + * Dumps the current memory state of all eligible slab caches.
> + * State information includes cache's active objects, total objects,
> + * object size, cache name, and cache size.
> + */
> +void oom_dump_slabs(int ratio)
> +{
> + =A0 =A0 =A0 struct kmem_cache *cachep;
> + =A0 =A0 =A0 struct kmem_list3 *l3;
> + =A0 =A0 =A0 struct slab *slabp;
> + =A0 =A0 =A0 unsigned long active_objs, num_objs, free_objects, cache_si=
ze;
> + =A0 =A0 =A0 unsigned long active_slabs, num_slabs, slab_total_mem;
> + =A0 =A0 =A0 int node;

[snip]

> + =A0 =A0 =A0 list_for_each_entry(cachep, &cache_chain, next) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 num_objs =3D 0;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 num_slabs =3D 0;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 active_objs =3D 0;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 free_objects =3D 0;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 active_slabs =3D 0;

Minor style nit: just define the zeroed variables in this block.

> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 for_each_online_node(node) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 l3 =3D cachep->nodelists[no=
de];
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!l3)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
> +void oom_dump_slabs(int ratio)
> +{
> + =A0 =A0 =A0 unsigned long cache_size, slab_total_mem;
> + =A0 =A0 =A0 unsigned long nr_objs, nr_free, nr_inuse;
> + =A0 =A0 =A0 struct kmem_cache *cachep;
> + =A0 =A0 =A0 int node;
> +
> + =A0 =A0 =A0 slab_total_mem =3D (global_page_state(NR_SLAB_RECLAIMABLE) =
+
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 global_page_state(NR_SLAB_U=
NRECLAIMABLE)) << PAGE_SHIFT;
> +
> + =A0 =A0 =A0 if (ratio < 0)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ratio =3D 0;
> +
> + =A0 =A0 =A0 if (ratio > 100)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ratio =3D 100;
> +
> + =A0 =A0 =A0 pr_info("--- oom_dump_slabs:\n");
> + =A0 =A0 =A0 pr_info("<active_objs> =A0 =A0<num_objs> =A0 =A0 <objsize> =
=A0<cache_name>\n");
> + =A0 =A0 =A0 down_read(&slub_lock);
> + =A0 =A0 =A0 list_for_each_entry(cachep, &slab_caches, list) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 nr_objs =3D 0;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 nr_free =3D 0;

ditto.

> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 for_each_online_node(node) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct kmem_cache_node *n =
=3D get_node(cachep, node);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!n)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
> +

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
