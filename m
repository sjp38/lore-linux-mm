Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 7CC726B002D
	for <linux-mm@kvack.org>; Mon, 14 Nov 2011 16:44:22 -0500 (EST)
Received: by vws16 with SMTP id 16so7412163vws.14
        for <linux-mm@kvack.org>; Mon, 14 Nov 2011 13:44:20 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20111111200727.668158433@linux.com>
References: <20111111200711.156817886@linux.com>
	<20111111200727.668158433@linux.com>
Date: Mon, 14 Nov 2011 23:44:19 +0200
Message-ID: <CAOJsxLGtWD=gojcASCH0s04qenARMj4xHFo3z8zSUKEzV-Mm9Q@mail.gmail.com>
Subject: Re: [rfc 04/18] slub: Use freelist instead of "object" in __slab_alloc
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: David Rientjes <rientjes@google.com>, Andi Kleen <andi@firstfloor.org>, tj@kernel.org, Metathronius Galabant <m.galabant@googlemail.com>, Matt Mackall <mpm@selenic.com>, Eric Dumazet <eric.dumazet@gmail.com>, Adrian Drzewiecki <z@drze.net>, Shaohua Li <shaohua.li@intel.com>, Alex Shi <alex.shi@intel.com>, linux-mm@kvack.org

On Fri, Nov 11, 2011 at 10:07 PM, Christoph Lameter <cl@linux.com> wrote:
> The variable "object" really refers to a list of objects that we
> are handling. Since the lockless allocator path will depend on it
> we rename the variable now.
>
> Signed-off-by: Christoph Lameter <cl@linux.com>

Also a reasonable cleanup.

> ---
> =A0mm/slub.c | =A0 40 ++++++++++++++++++++++------------------
> =A01 file changed, 22 insertions(+), 18 deletions(-)
>
> Index: linux-2.6/mm/slub.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linux-2.6.orig/mm/slub.c =A0 =A02011-11-09 11:11:13.471490305 -0600
> +++ linux-2.6/mm/slub.c 2011-11-09 11:11:22.381541568 -0600
> @@ -2084,7 +2084,7 @@ slab_out_of_memory(struct kmem_cache *s,
> =A0static inline void *new_slab_objects(struct kmem_cache *s, gfp_t flags=
,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0int node, struct kmem_cach=
e_cpu **pc)
> =A0{
> - =A0 =A0 =A0 void *object;
> + =A0 =A0 =A0 void *freelist;
> =A0 =A0 =A0 =A0struct kmem_cache_cpu *c;
> =A0 =A0 =A0 =A0struct page *page =3D new_slab(s, flags, node);
>
> @@ -2097,16 +2097,16 @@ static inline void *new_slab_objects(str
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * No other reference to the page yet so w=
e can
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * muck around with it freely without cmpx=
chg
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 */
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 object =3D page->freelist;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 freelist =3D page->freelist;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0page->freelist =3D NULL;
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0stat(s, ALLOC_SLAB);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0c->page =3D page;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*pc =3D c;
> =A0 =A0 =A0 =A0} else
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 object =3D NULL;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 freelist =3D NULL;
>
> - =A0 =A0 =A0 return object;
> + =A0 =A0 =A0 return freelist;
> =A0}
>
> =A0/*
> @@ -2159,7 +2159,7 @@ static inline void *get_freelist(struct
> =A0static void *__slab_alloc(struct kmem_cache *s, gfp_t gfpflags, int no=
de,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned long addr, st=
ruct kmem_cache_cpu *c)
> =A0{
> - =A0 =A0 =A0 void **object;
> + =A0 =A0 =A0 void *freelist;
> =A0 =A0 =A0 =A0unsigned long flags;
>
> =A0 =A0 =A0 =A0local_irq_save(flags);
> @@ -2175,6 +2175,7 @@ static void *__slab_alloc(struct kmem_ca
> =A0 =A0 =A0 =A0if (!c->page)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto new_slab;
> =A0redo:
> +
> =A0 =A0 =A0 =A0if (unlikely(!node_match(c, node))) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0stat(s, ALLOC_NODE_MISMATCH);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0deactivate_slab(s, c->page, c->freelist);
> @@ -2185,9 +2186,9 @@ redo:
>
> =A0 =A0 =A0 =A0stat(s, ALLOC_SLOWPATH);
>
> - =A0 =A0 =A0 object =3D get_freelist(s, c->page);
> + =A0 =A0 =A0 freelist =3D get_freelist(s, c->page);
>
> - =A0 =A0 =A0 if (!object) {
> + =A0 =A0 =A0 if (unlikely(!freelist)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0c->page =3D NULL;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0stat(s, DEACTIVATE_BYPASS);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto new_slab;
> @@ -2196,10 +2197,15 @@ redo:
> =A0 =A0 =A0 =A0stat(s, ALLOC_REFILL);
>
> =A0load_freelist:
> - =A0 =A0 =A0 c->freelist =3D get_freepointer(s, object);
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* freelist is pointing to the list of objects to be used=
.
> + =A0 =A0 =A0 =A0* page is pointing to the page from which the objects ar=
e obtained.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 VM_BUG_ON(!c->page->frozen);
> + =A0 =A0 =A0 c->freelist =3D get_freepointer(s, freelist);
> =A0 =A0 =A0 =A0c->tid =3D next_tid(c->tid);
> =A0 =A0 =A0 =A0local_irq_restore(flags);
> - =A0 =A0 =A0 return object;
> + =A0 =A0 =A0 return freelist;
>
> =A0new_slab:
>
> @@ -2211,14 +2217,12 @@ new_slab:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto redo;
> =A0 =A0 =A0 =A0}
>
> - =A0 =A0 =A0 /* Then do expensive stuff like retrieving pages from the p=
artial lists */
> - =A0 =A0 =A0 object =3D get_partial(s, gfpflags, node, c);
> + =A0 =A0 =A0 freelist =3D get_partial(s, gfpflags, node, c);
>
> - =A0 =A0 =A0 if (unlikely(!object)) {
> + =A0 =A0 =A0 if (unlikely(!freelist)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 freelist =3D new_slab_objects(s, gfpflags, =
node, &c);
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 object =3D new_slab_objects(s, gfpflags, no=
de, &c);
> -
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (unlikely(!object)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (unlikely(!freelist)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!(gfpflags & __GFP_NOW=
ARN) && printk_ratelimit())
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0slab_out_o=
f_memory(s, gfpflags, node);
>
> @@ -2231,14 +2235,14 @@ new_slab:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto load_freelist;
>
> =A0 =A0 =A0 =A0/* Only entered in the debug case */
> - =A0 =A0 =A0 if (!alloc_debug_processing(s, c->page, object, addr))
> + =A0 =A0 =A0 if (!alloc_debug_processing(s, c->page, freelist, addr))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto new_slab; =A0/* Slab failed checks. N=
ext slab needed */
> + =A0 =A0 =A0 deactivate_slab(s, c->page, get_freepointer(s, freelist));
>
> - =A0 =A0 =A0 deactivate_slab(s, c->page, get_freepointer(s, object));
> =A0 =A0 =A0 =A0c->page =3D NULL;
> =A0 =A0 =A0 =A0c->freelist =3D NULL;
> =A0 =A0 =A0 =A0local_irq_restore(flags);
> - =A0 =A0 =A0 return object;
> + =A0 =A0 =A0 return freelist;
> =A0}
>
> =A0/*
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
