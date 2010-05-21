Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id D116B6B01B1
	for <linux-mm@kvack.org>; Fri, 21 May 2010 00:59:57 -0400 (EDT)
Received: by fxm9 with SMTP id 9so520428fxm.14
        for <linux-mm@kvack.org>; Thu, 20 May 2010 21:59:37 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100520234714.6633.75614.stgit@gitlad.jf.intel.com>
References: <20100520234714.6633.75614.stgit@gitlad.jf.intel.com>
Date: Fri, 21 May 2010 07:59:36 +0300
Message-ID: <AANLkTilfJh65QAkb9FPaqI3UEtbgwLuuoqSdaTtIsXWZ@mail.gmail.com>
Subject: Re: [PATCH] slub: move kmem_cache_node into it's own cacheline
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Alexander Duyck <alexander.h.duyck@intel.com>
Cc: cl@linux.com, linux-mm@kvack.org, Alex Shi <alex.shi@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>
List-ID: <linux-mm.kvack.org>

On Fri, May 21, 2010 at 2:47 AM, Alexander Duyck
<alexander.h.duyck@intel.com> wrote:
> This patch is meant to improve the performance of SLUB by moving the loca=
l
> kmem_cache_node lock into it's own cacheline separate from kmem_cache.
> This is accomplished by simply removing the local_node when NUMA is enabl=
ed.
>
> On my system with 2 nodes I saw around a 5% performance increase w/
> hackbench times dropping from 6.2 seconds to 5.9 seconds on average. =A0I
> suspect the performance gain would increase as the number of nodes
> increases, but I do not have the data to currently back that up.
>
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>

Yanmin, does this fix the hackbench regression for you?

> ---
>
> =A0include/linux/slub_def.h | =A0 11 ++++-------
> =A0mm/slub.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 33 +++++++++++---------=
-------------
> =A02 files changed, 15 insertions(+), 29 deletions(-)
>
> diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
> index 0249d41..e6217bb 100644
> --- a/include/linux/slub_def.h
> +++ b/include/linux/slub_def.h
> @@ -52,7 +52,7 @@ struct kmem_cache_node {
> =A0 =A0 =A0 =A0atomic_long_t total_objects;
> =A0 =A0 =A0 =A0struct list_head full;
> =A0#endif
> -};
> +} ____cacheline_internodealigned_in_smp;
>
> =A0/*
> =A0* Word size structure that can be atomically updated or read and that
> @@ -75,12 +75,6 @@ struct kmem_cache {
> =A0 =A0 =A0 =A0int offset; =A0 =A0 =A0 =A0 =A0 =A0 /* Free pointer offset=
. */
> =A0 =A0 =A0 =A0struct kmem_cache_order_objects oo;
>
> - =A0 =A0 =A0 /*
> - =A0 =A0 =A0 =A0* Avoid an extra cache line for UP, SMP and for the node=
 local to
> - =A0 =A0 =A0 =A0* struct kmem_cache.
> - =A0 =A0 =A0 =A0*/
> - =A0 =A0 =A0 struct kmem_cache_node local_node;
> -
> =A0 =A0 =A0 =A0/* Allocation and freeing of slabs */
> =A0 =A0 =A0 =A0struct kmem_cache_order_objects max;
> =A0 =A0 =A0 =A0struct kmem_cache_order_objects min;
> @@ -102,6 +96,9 @@ struct kmem_cache {
> =A0 =A0 =A0 =A0 */
> =A0 =A0 =A0 =A0int remote_node_defrag_ratio;
> =A0 =A0 =A0 =A0struct kmem_cache_node *node[MAX_NUMNODES];
> +#else
> + =A0 =A0 =A0 /* Avoid an extra cache line for UP */
> + =A0 =A0 =A0 struct kmem_cache_node local_node;
> =A0#endif
> =A0};
>
> diff --git a/mm/slub.c b/mm/slub.c
> index 461314b..8af03de 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -2141,7 +2141,7 @@ static void free_kmem_cache_nodes(struct kmem_cache=
 *s)
>
> =A0 =A0 =A0 =A0for_each_node_state(node, N_NORMAL_MEMORY) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct kmem_cache_node *n =3D s->node[node=
];
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (n && n !=3D &s->local_node)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (n)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0kmem_cache_free(kmalloc_ca=
ches, n);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0s->node[node] =3D NULL;
> =A0 =A0 =A0 =A0}
> @@ -2150,33 +2150,22 @@ static void free_kmem_cache_nodes(struct kmem_cac=
he *s)
> =A0static int init_kmem_cache_nodes(struct kmem_cache *s, gfp_t gfpflags)
> =A0{
> =A0 =A0 =A0 =A0int node;
> - =A0 =A0 =A0 int local_node;
> -
> - =A0 =A0 =A0 if (slab_state >=3D UP && (s < kmalloc_caches ||
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 s >=3D kmalloc_caches + KMA=
LLOC_CACHES))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 local_node =3D page_to_nid(virt_to_page(s))=
;
> - =A0 =A0 =A0 else
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 local_node =3D 0;
>
> =A0 =A0 =A0 =A0for_each_node_state(node, N_NORMAL_MEMORY) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct kmem_cache_node *n;
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (local_node =3D=3D node)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 n =3D &s->local_node;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 else {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (slab_state =3D=3D DOWN)=
 {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 early_kmem_=
cache_node_alloc(gfpflags, node);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 n =3D kmem_cache_alloc_node=
(kmalloc_caches,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 gfpflags, node);
> -
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!n) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 free_kmem_c=
ache_nodes(s);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (slab_state =3D=3D DOWN) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 early_kmem_cache_node_alloc=
(gfpflags, node);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 n =3D kmem_cache_alloc_node(kmalloc_caches,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 gfpflags, node);
>
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!n) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 free_kmem_cache_nodes(s);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> +
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0s->node[node] =3D n;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0init_kmem_cache_node(n, s);
> =A0 =A0 =A0 =A0}
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
