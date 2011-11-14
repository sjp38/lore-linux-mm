Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id A81596B002D
	for <linux-mm@kvack.org>; Mon, 14 Nov 2011 16:42:40 -0500 (EST)
Received: by vcbfo11 with SMTP id fo11so5947091vcb.14
        for <linux-mm@kvack.org>; Mon, 14 Nov 2011 13:42:38 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20111111200725.634567005@linux.com>
References: <20111111200711.156817886@linux.com>
	<20111111200725.634567005@linux.com>
Date: Mon, 14 Nov 2011 23:42:38 +0200
Message-ID: <CAOJsxLFM9W=NiGFwjt8-iwrTYrAZiJ2_Mw_EUYyXYE4TKPs9-A@mail.gmail.com>
Subject: Re: [rfc 01/18] slub: Get rid of the node field
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: David Rientjes <rientjes@google.com>, Andi Kleen <andi@firstfloor.org>, tj@kernel.org, Metathronius Galabant <m.galabant@googlemail.com>, Matt Mackall <mpm@selenic.com>, Eric Dumazet <eric.dumazet@gmail.com>, Adrian Drzewiecki <z@drze.net>, Shaohua Li <shaohua.li@intel.com>, Alex Shi <alex.shi@intel.com>, linux-mm@kvack.org

On Fri, Nov 11, 2011 at 10:07 PM, Christoph Lameter <cl@linux.com> wrote:
> The node field is always page_to_nid(c->page). So its rather easy to
> replace. Note that there will be additional overhead in various hot paths
> due to the need to mask a set of bits in page->flags and shift the
> result.
>
> Signed-off-by: Christoph Lameter <cl@linux.com>

This is a nice cleanup even if we never go irqless in the slowpaths.
Is page_to_nid() really that slow?

>
> ---
> =A0include/linux/slub_def.h | =A0 =A01 -
> =A0mm/slub.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 15 ++++++---------
> =A02 files changed, 6 insertions(+), 10 deletions(-)
>
> Index: linux-2.6/mm/slub.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linux-2.6.orig/mm/slub.c =A0 =A02011-11-08 09:53:04.043865616 -0600
> +++ linux-2.6/mm/slub.c 2011-11-09 11:10:46.111334466 -0600
> @@ -1551,7 +1551,6 @@ static void *get_partial_node(struct kme
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!object) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0c->page =3D page;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 c->node =3D page_to_nid(pag=
e);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0stat(s, ALLOC_FROM_PARTIAL=
);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0object =3D t;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0available =3D =A0page->obj=
ects - page->inuse;
> @@ -2016,7 +2015,7 @@ static void flush_all(struct kmem_cache
> =A0static inline int node_match(struct kmem_cache_cpu *c, int node)
> =A0{
> =A0#ifdef CONFIG_NUMA
> - =A0 =A0 =A0 if (node !=3D NUMA_NO_NODE && c->node !=3D node)
> + =A0 =A0 =A0 if (node !=3D NUMA_NO_NODE && page_to_nid(c->page) !=3D nod=
e)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return 0;
> =A0#endif
> =A0 =A0 =A0 =A0return 1;
> @@ -2105,7 +2104,6 @@ static inline void *new_slab_objects(str
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0page->freelist =3D NULL;
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0stat(s, ALLOC_SLAB);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 c->node =3D page_to_nid(page);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0c->page =3D page;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*pc =3D c;
> =A0 =A0 =A0 =A0} else
> @@ -2202,7 +2200,6 @@ new_slab:
> =A0 =A0 =A0 =A0if (c->partial) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0c->page =3D c->partial;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0c->partial =3D c->page->next;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 c->node =3D page_to_nid(c->page);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0stat(s, CPU_PARTIAL_ALLOC);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0c->freelist =3D NULL;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto redo;
> @@ -2233,7 +2230,6 @@ new_slab:
>
> =A0 =A0 =A0 =A0c->freelist =3D get_freepointer(s, object);
> =A0 =A0 =A0 =A0deactivate_slab(s, c);
> - =A0 =A0 =A0 c->node =3D NUMA_NO_NODE;
> =A0 =A0 =A0 =A0local_irq_restore(flags);
> =A0 =A0 =A0 =A0return object;
> =A0}
> @@ -4437,9 +4433,10 @@ static ssize_t show_slab_objects(struct
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct kmem_cache_cpu *c =
=3D per_cpu_ptr(s->cpu_slab, cpu);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct page *page;
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!c || c->node < 0)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!c || !c->page)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0continue;
>
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 node =3D page_to_nid(c->pag=
e);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (c->page) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0if (flags & SO_TOTAL)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0x =3D c->page->objects;
> @@ -4449,16 +4446,16 @@ static ssize_t show_slab_objects(struct
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0x =3D 1;
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0total +=3D=
 x;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 nodes[c->no=
de] +=3D x;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 nodes[node]=
 +=3D x;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0page =3D c->partial;
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (page) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0x =3D page=
->pobjects;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 total +=
=3D x;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0nodes[c-=
>node] +=3D x;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0nodes[no=
de] +=3D x;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 per_cpu[c->node]++;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 per_cpu[node]++;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0}
>
> Index: linux-2.6/include/linux/slub_def.h
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linux-2.6.orig/include/linux/slub_def.h =A0 =A0 2011-11-08 09:53:03.9=
79865196 -0600
> +++ linux-2.6/include/linux/slub_def.h =A02011-11-09 11:10:46.121334523 -=
0600
> @@ -45,7 +45,6 @@ struct kmem_cache_cpu {
> =A0 =A0 =A0 =A0unsigned long tid; =A0 =A0 =A0/* Globally unique transacti=
on id */
> =A0 =A0 =A0 =A0struct page *page; =A0 =A0 =A0/* The slab from which we ar=
e allocating */
> =A0 =A0 =A0 =A0struct page *partial; =A0 /* Partially allocated frozen sl=
abs */
> - =A0 =A0 =A0 int node; =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* The node of the pa=
ge (or -1 for debug) */
> =A0#ifdef CONFIG_SLUB_STATS
> =A0 =A0 =A0 =A0unsigned stat[NR_SLUB_STAT_ITEMS];
> =A0#endif
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter=
.ca/
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
