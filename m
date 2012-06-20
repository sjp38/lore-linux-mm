Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id 497F46B0062
	for <linux-mm@kvack.org>; Wed, 20 Jun 2012 03:19:58 -0400 (EDT)
Received: by ggm4 with SMTP id 4so6770072ggm.14
        for <linux-mm@kvack.org>; Wed, 20 Jun 2012 00:19:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1339176197-13270-3-git-send-email-js1304@gmail.com>
References: <1339176197-13270-1-git-send-email-js1304@gmail.com>
	<1339176197-13270-3-git-send-email-js1304@gmail.com>
Date: Wed, 20 Jun 2012 10:19:56 +0300
Message-ID: <CAOJsxLFwNs2frWBkF-ns0Wo8gZ3OeyNRV6ARo1ukXHRjvW9PMw@mail.gmail.com>
Subject: Re: [PATCH 3/4] slub: refactoring unfreeze_partials()
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

On Fri, Jun 8, 2012 at 8:23 PM, Joonsoo Kim <js1304@gmail.com> wrote:
> Current implementation of unfreeze_partials() is so complicated,
> but benefit from it is insignificant. In addition many code in
> do {} while loop have a bad influence to a fail rate of cmpxchg_double_sl=
ab.
> Under current implementation which test status of cpu partial slab
> and acquire list_lock in do {} while loop,
> we don't need to acquire a list_lock and gain a little benefit
> when front of the cpu partial slab is to be discarded, but this is a rare=
 case.
> In case that add_partial is performed and cmpxchg_double_slab is failed,
> remove_partial should be called case by case.
>
> I think that these are disadvantages of current implementation,
> so I do refactoring unfreeze_partials().
>
> Minimizing code in do {} while loop introduce a reduced fail rate
> of cmpxchg_double_slab. Below is output of 'slabinfo -r kmalloc-256'
> when './perf stat -r 33 hackbench 50 process 4000 > /dev/null' is done.
>
> ** before **
> Cmpxchg_double Looping
> ------------------------
> Locked Cmpxchg Double redos =A0 182685
> Unlocked Cmpxchg Double redos 0
>
> ** after **
> Cmpxchg_double Looping
> ------------------------
> Locked Cmpxchg Double redos =A0 177995
> Unlocked Cmpxchg Double redos 1
>
> We can see cmpxchg_double_slab fail rate is improved slightly.
>
> Bolow is output of './perf stat -r 30 hackbench 50 process 4000 > /dev/nu=
ll'.
>
> ** before **
> =A0Performance counter stats for './hackbench 50 process 4000' (30 runs):
>
> =A0 =A0 108517.190463 task-clock =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0# =A0 =A0=
7.926 CPUs utilized =A0 =A0 =A0 =A0 =A0 =A0( +- =A00.24% )
> =A0 =A0 =A0 =A0 2,919,550 context-switches =A0 =A0 =A0 =A0 =A0# =A0 =A00.=
027 M/sec =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0( +- =A03.07% )
> =A0 =A0 =A0 =A0 =A0 100,774 CPU-migrations =A0 =A0 =A0 =A0 =A0 =A0# =A0 =
=A00.929 K/sec =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0( +- =A04.72% )
> =A0 =A0 =A0 =A0 =A0 124,201 page-faults =A0 =A0 =A0 =A0 =A0 =A0 =A0 # =A0=
 =A00.001 M/sec =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0( +- =A00.15% )
> =A0 401,500,234,387 cycles =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0# =A0 =
=A03.700 GHz =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0( +- =A00.24% )
> =A0 <not supported> stalled-cycles-frontend
> =A0 <not supported> stalled-cycles-backend
> =A0 250,576,913,354 instructions =A0 =A0 =A0 =A0 =A0 =A0 =A0# =A0 =A00.62=
 =A0insns per cycle =A0 =A0 =A0 =A0 =A0( +- =A00.13% )
> =A0 =A045,934,956,860 branches =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0# =A042=
3.297 M/sec =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0( +- =A00.14% )
> =A0 =A0 =A0 188,219,787 branch-misses =A0 =A0 =A0 =A0 =A0 =A0 # =A0 =A00.=
41% of all branches =A0 =A0 =A0 =A0 =A0( +- =A00.56% )
>
> =A0 =A0 =A013.691837307 seconds time elapsed =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0( +- =A00.24% )
>
> ** after **
> =A0Performance counter stats for './hackbench 50 process 4000' (30 runs):
>
> =A0 =A0 107784.479767 task-clock =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0# =A0 =A0=
7.928 CPUs utilized =A0 =A0 =A0 =A0 =A0 =A0( +- =A00.22% )
> =A0 =A0 =A0 =A0 2,834,781 context-switches =A0 =A0 =A0 =A0 =A0# =A0 =A00.=
026 M/sec =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0( +- =A02.33% )
> =A0 =A0 =A0 =A0 =A0 =A093,083 CPU-migrations =A0 =A0 =A0 =A0 =A0 =A0# =A0=
 =A00.864 K/sec =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0( +- =A03.45% )
> =A0 =A0 =A0 =A0 =A0 123,967 page-faults =A0 =A0 =A0 =A0 =A0 =A0 =A0 # =A0=
 =A00.001 M/sec =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0( +- =A00.15% )
> =A0 398,781,421,836 cycles =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0# =A0 =
=A03.700 GHz =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0( +- =A00.22% )
> =A0 <not supported> stalled-cycles-frontend
> =A0 <not supported> stalled-cycles-backend
> =A0 250,189,160,419 instructions =A0 =A0 =A0 =A0 =A0 =A0 =A0# =A0 =A00.63=
 =A0insns per cycle =A0 =A0 =A0 =A0 =A0( +- =A00.09% )
> =A0 =A045,855,370,128 branches =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0# =A042=
5.436 M/sec =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0( +- =A00.10% )
> =A0 =A0 =A0 169,881,248 branch-misses =A0 =A0 =A0 =A0 =A0 =A0 # =A0 =A00.=
37% of all branches =A0 =A0 =A0 =A0 =A0( +- =A00.43% )
>
> =A0 =A0 =A013.596272341 seconds time elapsed =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0( +- =A00.22% )
>
> No regression is found, but rather we can see slightly better result.
>
> Acked-by: Christoph Lameter <cl@linux.com>
> Signed-off-by: Joonsoo Kim <js1304@gmail.com>

Applied, thanks!

> diff --git a/mm/slub.c b/mm/slub.c
> index 686ed90..b5f2108 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -1886,18 +1886,24 @@ redo:
> =A0*/
> =A0static void unfreeze_partials(struct kmem_cache *s)
> =A0{
> - =A0 =A0 =A0 struct kmem_cache_node *n =3D NULL;
> + =A0 =A0 =A0 struct kmem_cache_node *n =3D NULL, *n2 =3D NULL;
> =A0 =A0 =A0 =A0struct kmem_cache_cpu *c =3D this_cpu_ptr(s->cpu_slab);
> =A0 =A0 =A0 =A0struct page *page, *discard_page =3D NULL;
>
> =A0 =A0 =A0 =A0while ((page =3D c->partial)) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 enum slab_modes { M_PARTIAL, M_FREE };
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 enum slab_modes l, m;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct page new;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct page old;
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0c->partial =3D page->next;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 l =3D M_FREE;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 n2 =3D get_node(s, page_to_nid(page));
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (n !=3D n2) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (n)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock=
(&n->list_lock);
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 n =3D n2;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_lock(&n->list_lock);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0do {
>
> @@ -1910,43 +1916,17 @@ static void unfreeze_partials(struct kmem_cache *=
s)
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0new.frozen =3D 0;
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!new.inuse && (!n || n-=
>nr_partial > s->min_partial))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 m =3D M_FRE=
E;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 else {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct kmem=
_cache_node *n2 =3D get_node(s,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 page_to_nid(page));
> -
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 m =3D M_PAR=
TIAL;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (n !=3D =
n2) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 if (n)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 spin_unlock(&n->list_lock);
> -
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 n =3D n2;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 spin_lock(&n->list_lock);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> -
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (l !=3D m) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (l =3D=
=3D M_PARTIAL) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 remove_partial(n, page);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 stat(s, FREE_REMOVE_PARTIAL);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 add_partial(n, page,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 DEACTIVATE_TO_TAIL);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 stat(s, FREE_ADD_PARTIAL);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> -
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 l =3D m;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> -
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0} while (!__cmpxchg_double_slab(s, page,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0old.freeli=
st, old.counters,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0new.freeli=
st, new.counters,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0"unfreezin=
g slab"));
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (m =3D=3D M_FREE) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (unlikely(!new.inuse && n->nr_partial > =
s->min_partial)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0page->next =3D discard_pag=
e;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0discard_page =3D page;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 add_partial(n, page, DEACTI=
VATE_TO_TAIL);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 stat(s, FREE_ADD_PARTIAL);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0}
>
> --
> 1.7.9.5
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
