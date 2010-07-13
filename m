Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id B8DFB6B02A4
	for <linux-mm@kvack.org>; Tue, 13 Jul 2010 16:33:27 -0400 (EDT)
Received: by bwz9 with SMTP id 9so4380480bwz.14
        for <linux-mm@kvack.org>; Tue, 13 Jul 2010 13:33:14 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100713101747.2835.45722.sendpatchset@danny.redhat>
References: <20100713101650.2835.15245.sendpatchset@danny.redhat>
	<20100713101747.2835.45722.sendpatchset@danny.redhat>
Date: Tue, 13 Jul 2010 23:33:14 +0300
Message-ID: <AANLkTilj5GrhbRJZfSsfXP1v9cQSRlARFmxpys1vUelr@mail.gmail.com>
Subject: Re: [PATCH -mmotm 05/30] mm: sl[au]b: add knowledge of reserve pages
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Xiaotian Feng <dfeng@redhat.com>
Cc: linux-mm@kvack.org, linux-nfs@vger.kernel.org, netdev@vger.kernel.org, riel@redhat.com, cl@linux-foundation.org, a.p.zijlstra@chello.nl, linux-kernel@vger.kernel.org, lwang@redhat.com, akpm@linux-foundation.org, davem@davemloft.net
List-ID: <linux-mm.kvack.org>

Hi Xiaotian!

I would actually prefer that the SLAB, SLOB, and SLUB changes were in
separate patches to make reviewing easier.

Looking at SLUB:

On Tue, Jul 13, 2010 at 1:17 PM, Xiaotian Feng <dfeng@redhat.com> wrote:
> diff --git a/mm/slub.c b/mm/slub.c
> index 7bb7940..7a5d6dc 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -27,6 +27,8 @@
> =A0#include <linux/memory.h>
> =A0#include <linux/math64.h>
> =A0#include <linux/fault-inject.h>
> +#include "internal.h"
> +
>
> =A0/*
> =A0* Lock order:
> @@ -1139,7 +1141,8 @@ static void setup_object(struct kmem_cache *s, stru=
ct page *page,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0s->ctor(object);
> =A0}
>
> -static struct page *new_slab(struct kmem_cache *s, gfp_t flags, int node=
)
> +static
> +struct page *new_slab(struct kmem_cache *s, gfp_t flags, int node, int *=
reserve)
> =A0{
> =A0 =A0 =A0 =A0struct page *page;
> =A0 =A0 =A0 =A0void *start;
> @@ -1153,6 +1156,8 @@ static struct page *new_slab(struct kmem_cache *s, =
gfp_t flags, int node)
> =A0 =A0 =A0 =A0if (!page)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out;
>
> + =A0 =A0 =A0 *reserve =3D page->reserve;
> +
> =A0 =A0 =A0 =A0inc_slabs_node(s, page_to_nid(page), page->objects);
> =A0 =A0 =A0 =A0page->slab =3D s;
> =A0 =A0 =A0 =A0page->flags |=3D 1 << PG_slab;
> @@ -1606,10 +1611,20 @@ static void *__slab_alloc(struct kmem_cache *s, g=
fp_t gfpflags, int node,
> =A0{
> =A0 =A0 =A0 =A0void **object;
> =A0 =A0 =A0 =A0struct page *new;
> + =A0 =A0 =A0 int reserve;
>
> =A0 =A0 =A0 =A0/* We handle __GFP_ZERO in the caller */
> =A0 =A0 =A0 =A0gfpflags &=3D ~__GFP_ZERO;
>
> + =A0 =A0 =A0 if (unlikely(c->reserve)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* If the current slab is a reserve slab =
and the current
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* allocation context does not allow acce=
ss to the reserves we
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* must force an allocation to test the c=
urrent levels.
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!(gfp_to_alloc_flags(gfpflags) & ALLOC_=
NO_WATERMARKS))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto grow_slab;

OK, so assume that:

  (1) c->reserve is set to one

  (2) GFP flags don't allow dipping into the reserves

  (3) we've managed to free enough pages so normal
       allocations are fine

  (4) the page from reserves is not yet empty

we will call flush_slab() and put the "emergency page" on partial list
and clear c->reserve. This effectively means that now some other
allocation can fetch the partial page and start to use it. Is this OK?
Who makes sure the emergency reserves are large enough for the next
out-of-memory condition where we swap over NFS?

> + =A0 =A0 =A0 }
> =A0 =A0 =A0 =A0if (!c->page)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto new_slab;
>
> @@ -1623,8 +1638,8 @@ load_freelist:
> =A0 =A0 =A0 =A0object =3D c->page->freelist;
> =A0 =A0 =A0 =A0if (unlikely(!object))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto another_slab;
> - =A0 =A0 =A0 if (unlikely(SLABDEBUG && PageSlubDebug(c->page)))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto debug;
> + =A0 =A0 =A0 if (unlikely(SLABDEBUG && PageSlubDebug(c->page) || c->rese=
rve))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto slow_path;
>
> =A0 =A0 =A0 =A0c->freelist =3D get_freepointer(s, object);
> =A0 =A0 =A0 =A0c->page->inuse =3D c->page->objects;
> @@ -1646,16 +1661,18 @@ new_slab:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto load_freelist;
> =A0 =A0 =A0 =A0}
>
> +grow_slab:
> =A0 =A0 =A0 =A0if (gfpflags & __GFP_WAIT)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0local_irq_enable();
>
> - =A0 =A0 =A0 new =3D new_slab(s, gfpflags, node);
> + =A0 =A0 =A0 new =3D new_slab(s, gfpflags, node, &reserve);
>
> =A0 =A0 =A0 =A0if (gfpflags & __GFP_WAIT)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0local_irq_disable();
>
> =A0 =A0 =A0 =A0if (new) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0c =3D __this_cpu_ptr(s->cpu_slab);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 c->reserve =3D reserve;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0stat(s, ALLOC_SLAB);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (c->page)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0flush_slab(s, c);
> @@ -1667,10 +1684,20 @@ new_slab:
> =A0 =A0 =A0 =A0if (!(gfpflags & __GFP_NOWARN) && printk_ratelimit())
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0slab_out_of_memory(s, gfpflags, node);
> =A0 =A0 =A0 =A0return NULL;
> -debug:
> - =A0 =A0 =A0 if (!alloc_debug_processing(s, c->page, object, addr))
> +
> +slow_path:
> + =A0 =A0 =A0 if (!c->reserve && !alloc_debug_processing(s, c->page, obje=
ct, addr))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto another_slab;
>
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* Avoid the slub fast path in slab_alloc() by not settin=
g
> + =A0 =A0 =A0 =A0* c->freelist and the fast path in slab_free() by making
> + =A0 =A0 =A0 =A0* node_match() fail by setting c->node to -1.
> + =A0 =A0 =A0 =A0*
> + =A0 =A0 =A0 =A0* We use this for for debug and reserve checks which nee=
d
> + =A0 =A0 =A0 =A0* to be done for each allocation.
> + =A0 =A0 =A0 =A0*/
> +
> =A0 =A0 =A0 =A0c->page->inuse++;
> =A0 =A0 =A0 =A0c->page->freelist =3D get_freepointer(s, object);
> =A0 =A0 =A0 =A0c->node =3D -1;
> @@ -2095,10 +2122,11 @@ static void early_kmem_cache_node_alloc(gfp_t gfp=
flags, int node)
> =A0 =A0 =A0 =A0struct page *page;
> =A0 =A0 =A0 =A0struct kmem_cache_node *n;
> =A0 =A0 =A0 =A0unsigned long flags;
> + =A0 =A0 =A0 int reserve;
>
> =A0 =A0 =A0 =A0BUG_ON(kmalloc_caches->size < sizeof(struct kmem_cache_nod=
e));
>
> - =A0 =A0 =A0 page =3D new_slab(kmalloc_caches, gfpflags, node);
> + =A0 =A0 =A0 page =3D new_slab(kmalloc_caches, gfpflags, node, &reserve)=
;
>
> =A0 =A0 =A0 =A0BUG_ON(!page);
> =A0 =A0 =A0 =A0if (page_to_nid(page) !=3D node) {
> --
> 1.7.1.1
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
