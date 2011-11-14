Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 95B976B002D
	for <linux-mm@kvack.org>; Mon, 14 Nov 2011 16:43:48 -0500 (EST)
Received: by vcbfo11 with SMTP id fo11so5948415vcb.14
        for <linux-mm@kvack.org>; Mon, 14 Nov 2011 13:43:45 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20111111200726.995401746@linux.com>
References: <20111111200711.156817886@linux.com>
	<20111111200726.995401746@linux.com>
Date: Mon, 14 Nov 2011 23:43:45 +0200
Message-ID: <CAOJsxLGbWe_hND9B8UbQyg5UN2Ydaes3wcWYzXu4goD8V9F6_Q@mail.gmail.com>
Subject: Re: [rfc 03/18] slub: Extract get_freelist from __slab_alloc
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: David Rientjes <rientjes@google.com>, Andi Kleen <andi@firstfloor.org>, tj@kernel.org, Metathronius Galabant <m.galabant@googlemail.com>, Matt Mackall <mpm@selenic.com>, Eric Dumazet <eric.dumazet@gmail.com>, Adrian Drzewiecki <z@drze.net>, Shaohua Li <shaohua.li@intel.com>, Alex Shi <alex.shi@intel.com>, linux-mm@kvack.org

On Fri, Nov 11, 2011 at 10:07 PM, Christoph Lameter <cl@linux.com> wrote:
> get_freelist retrieves free objects from the page freelist (put there by =
remote
> frees) or deactivates a slab page if no more objects are available.
>
> Signed-off-by: Christoph Lameter <cl@linux.com>

This is a also a nice cleanup. Any reason I shouldn't apply this?

>
>
> ---
> =A0mm/slub.c | =A0 57 ++++++++++++++++++++++++++++++++-------------------=
------
> =A01 file changed, 32 insertions(+), 25 deletions(-)
>
> Index: linux-2.6/mm/slub.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linux-2.6.orig/mm/slub.c =A0 =A02011-11-09 11:10:55.671388657 -0600
> +++ linux-2.6/mm/slub.c 2011-11-09 11:11:13.471490305 -0600
> @@ -2110,6 +2110,37 @@ static inline void *new_slab_objects(str
> =A0}
>
> =A0/*
> + * Check the page->freelist of a page and either transfer the freelist t=
o the per cpu freelist
> + * or deactivate the page.
> + *
> + * The page is still frozen if the return value is not NULL.
> + *
> + * If this function returns NULL then the page has been unfrozen.
> + */
> +static inline void *get_freelist(struct kmem_cache *s, struct page *page=
)
> +{
> + =A0 =A0 =A0 struct page new;
> + =A0 =A0 =A0 unsigned long counters;
> + =A0 =A0 =A0 void *freelist;
> +
> + =A0 =A0 =A0 do {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 freelist =3D page->freelist;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 counters =3D page->counters;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 new.counters =3D counters;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 VM_BUG_ON(!new.frozen);
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 new.inuse =3D page->objects;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 new.frozen =3D freelist !=3D NULL;
> +
> + =A0 =A0 =A0 } while (!cmpxchg_double_slab(s, page,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 freelist, counters,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 NULL, new.counters,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 "get_freelist"));
> +
> + =A0 =A0 =A0 return freelist;
> +}
> +
> +/*
> =A0* Slow path. The lockless freelist is empty or we need to perform
> =A0* debugging duties.
> =A0*
> @@ -2130,8 +2161,6 @@ static void *__slab_alloc(struct kmem_ca
> =A0{
> =A0 =A0 =A0 =A0void **object;
> =A0 =A0 =A0 =A0unsigned long flags;
> - =A0 =A0 =A0 struct page new;
> - =A0 =A0 =A0 unsigned long counters;
>
> =A0 =A0 =A0 =A0local_irq_save(flags);
> =A0#ifdef CONFIG_PREEMPT
> @@ -2156,29 +2185,7 @@ redo:
>
> =A0 =A0 =A0 =A0stat(s, ALLOC_SLOWPATH);
>
> - =A0 =A0 =A0 do {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 object =3D c->page->freelist;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 counters =3D c->page->counters;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 new.counters =3D counters;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 VM_BUG_ON(!new.frozen);
> -
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* If there is no object left then we use=
 this loop to
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* deactivate the slab which is simple si=
nce no objects
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* are left in the slab and therefore we =
do not need to
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* put the page back onto the partial lis=
t.
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* If there are objects left then we retr=
ieve them
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* and use them to refill the per cpu que=
ue.
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> -
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 new.inuse =3D c->page->objects;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 new.frozen =3D object !=3D NULL;
> -
> - =A0 =A0 =A0 } while (!__cmpxchg_double_slab(s, c->page,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 object, counters,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 NULL, new.counters,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 "__slab_alloc"));
> + =A0 =A0 =A0 object =3D get_freelist(s, c->page);
>
> =A0 =A0 =A0 =A0if (!object) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0c->page =3D NULL;
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
