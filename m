Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 8E1136B006C
	for <linux-mm@kvack.org>; Mon, 14 Nov 2011 16:46:21 -0500 (EST)
Received: by vws16 with SMTP id 16so7414480vws.14
        for <linux-mm@kvack.org>; Mon, 14 Nov 2011 13:46:16 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20111111200729.024403984@linux.com>
References: <20111111200711.156817886@linux.com>
	<20111111200729.024403984@linux.com>
Date: Mon, 14 Nov 2011 23:46:16 +0200
Message-ID: <CAOJsxLFJqrTsySxtkVt2H9Drzji6ghx3aVkaM5ODTDp8g70WqA@mail.gmail.com>
Subject: Re: [rfc 06/18] slub: Use page variable instead of c->page.
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: David Rientjes <rientjes@google.com>, Andi Kleen <andi@firstfloor.org>, tj@kernel.org, Metathronius Galabant <m.galabant@googlemail.com>, Matt Mackall <mpm@selenic.com>, Eric Dumazet <eric.dumazet@gmail.com>, Adrian Drzewiecki <z@drze.net>, Shaohua Li <shaohua.li@intel.com>, Alex Shi <alex.shi@intel.com>, linux-mm@kvack.org

On Fri, Nov 11, 2011 at 10:07 PM, Christoph Lameter <cl@linux.com> wrote:
> The kmem_cache_cpu object pointed to by c will become
> volatile with the lockless patches later so extract
> the c->page pointer at certain times.
>
> Signed-off-by: Christoph Lameter <cl@linux.com>

I don't know what GCC does these days but this sort of thing used to
generate better asm in mm/slab.c. So it might be worth it to merge
this.

> ---
> =A0mm/slub.c | =A0 17 ++++++++++-------
> =A01 file changed, 10 insertions(+), 7 deletions(-)
>
> Index: linux-2.6/mm/slub.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linux-2.6.orig/mm/slub.c =A0 =A02011-11-09 11:11:25.881561697 -0600
> +++ linux-2.6/mm/slub.c 2011-11-09 11:11:32.231598204 -0600
> @@ -2160,6 +2160,7 @@ static void *__slab_alloc(struct kmem_ca
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned long addr, st=
ruct kmem_cache_cpu *c)
> =A0{
> =A0 =A0 =A0 =A0void *freelist;
> + =A0 =A0 =A0 struct page *page;
> =A0 =A0 =A0 =A0unsigned long flags;
>
> =A0 =A0 =A0 =A0local_irq_save(flags);
> @@ -2172,13 +2173,14 @@ static void *__slab_alloc(struct kmem_ca
> =A0 =A0 =A0 =A0c =3D this_cpu_ptr(s->cpu_slab);
> =A0#endif
>
> - =A0 =A0 =A0 if (!c->page)
> + =A0 =A0 =A0 page =3D c->page;
> + =A0 =A0 =A0 if (!page)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto new_slab;
> =A0redo:
>
> =A0 =A0 =A0 =A0if (unlikely(!node_match(c, node))) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0stat(s, ALLOC_NODE_MISMATCH);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 deactivate_slab(s, c->page, c->freelist);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 deactivate_slab(s, page, c->freelist);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0c->page =3D NULL;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0c->freelist =3D NULL;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto new_slab;
> @@ -2186,7 +2188,7 @@ redo:
>
> =A0 =A0 =A0 =A0stat(s, ALLOC_SLOWPATH);
>
> - =A0 =A0 =A0 freelist =3D get_freelist(s, c->page);
> + =A0 =A0 =A0 freelist =3D get_freelist(s, page);
>
> =A0 =A0 =A0 =A0if (unlikely(!freelist)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0c->page =3D NULL;
> @@ -2210,8 +2212,8 @@ load_freelist:
> =A0new_slab:
>
> =A0 =A0 =A0 =A0if (c->partial) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 c->page =3D c->partial;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 c->partial =3D c->page->next;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 page =3D c->page =3D c->partial;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 c->partial =3D page->next;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0stat(s, CPU_PARTIAL_ALLOC);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0c->freelist =3D NULL;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto redo;
> @@ -2231,13 +2233,14 @@ new_slab:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return NULL;
> =A0 =A0 =A0 =A0}
>
> + =A0 =A0 =A0 page =3D c->page;
> =A0 =A0 =A0 =A0if (likely(!kmem_cache_debug(s)))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto load_freelist;
>
> =A0 =A0 =A0 =A0/* Only entered in the debug case */
> - =A0 =A0 =A0 if (!alloc_debug_processing(s, c->page, freelist, addr))
> + =A0 =A0 =A0 if (!alloc_debug_processing(s, page, freelist, addr))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto new_slab; =A0/* Slab failed checks. N=
ext slab needed */
> - =A0 =A0 =A0 deactivate_slab(s, c->page, get_freepointer(s, freelist));
> + =A0 =A0 =A0 deactivate_slab(s, page, get_freepointer(s, freelist));
>
> =A0 =A0 =A0 =A0c->page =3D NULL;
> =A0 =A0 =A0 =A0c->freelist =3D NULL;
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
