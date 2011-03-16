Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 24EB78D0039
	for <linux-mm@kvack.org>; Wed, 16 Mar 2011 02:32:31 -0400 (EDT)
Received: by gxk23 with SMTP id 23so710061gxk.14
        for <linux-mm@kvack.org>; Tue, 15 Mar 2011 23:32:29 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110316022805.27713.qmail@science.horizon.com>
References: <20110316022805.27713.qmail@science.horizon.com>
Date: Wed, 16 Mar 2011 08:32:28 +0200
Message-ID: <AANLkTi=asfrGTYL-vrG_xC--N+ddjj5aS2fG-i8ALvt1@mail.gmail.com>
Subject: Re: [PATCH 5/8] mm/slub: Factor out some common code.
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: George Spelvin <linux@horizon.com>
Cc: penberg@cs.helsinki.fi, herbert@gondor.apana.org.au, mpm@selenic.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux-foundation.org>, David Rientjes <rientjes@google.com>

On Tue, Mar 15, 2011 at 3:58 AM, George Spelvin <linux@horizon.com> wrote:
> For sysfs files that map a boolean to a flags bit.

Looks good to me. I'll cc Christoph and David too.

> ---
> =A0mm/slub.c | =A0 93 ++++++++++++++++++++++++++++-----------------------=
---------
> =A01 files changed, 43 insertions(+), 50 deletions(-)
>
> diff --git a/mm/slub.c b/mm/slub.c
> index e15aa7f..856246f 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -3982,38 +3982,61 @@ static ssize_t objects_partial_show(struct kmem_c=
ache *s, char *buf)
> =A0}
> =A0SLAB_ATTR_RO(objects_partial);
>
> +static ssize_t flag_show(struct kmem_cache *s, char *buf, unsigned flag)
> +{
> + =A0 =A0 =A0 return sprintf(buf, "%d\n", !!(s->flags & flag));
> +}
> +
> +static ssize_t flag_store(struct kmem_cache *s,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 const char =
*buf, size_t length, unsigned flag)
> +{
> + =A0 =A0 =A0 s->flags &=3D ~flag;
> + =A0 =A0 =A0 if (buf[0] =3D=3D '1')
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 s->flags |=3D flag;
> + =A0 =A0 =A0 return length;
> +}
> +
> +/* Like above, but changes allocation size; so only allowed on empty sla=
b */
> +static ssize_t flag_store_sizechange(struct kmem_cache *s,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 const char =
*buf, size_t length, unsigned flag)
> +{
> + =A0 =A0 =A0 if (any_slab_objects(s))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EBUSY;
> +
> + =A0 =A0 =A0 flag_store(s, buf, length, flag);
> + =A0 =A0 =A0 calculate_sizes(s, -1);
> + =A0 =A0 =A0 return length;
> +}
> +
> =A0static ssize_t reclaim_account_show(struct kmem_cache *s, char *buf)
> =A0{
> - =A0 =A0 =A0 return sprintf(buf, "%d\n", !!(s->flags & SLAB_RECLAIM_ACCO=
UNT));
> + =A0 =A0 =A0 return flag_show(s, buf, SLAB_RECLAIM_ACCOUNT);
> =A0}
>
> =A0static ssize_t reclaim_account_store(struct kmem_cache *s,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0const char=
 *buf, size_t length)
> =A0{
> - =A0 =A0 =A0 s->flags &=3D ~SLAB_RECLAIM_ACCOUNT;
> - =A0 =A0 =A0 if (buf[0] =3D=3D '1')
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 s->flags |=3D SLAB_RECLAIM_ACCOUNT;
> - =A0 =A0 =A0 return length;
> + =A0 =A0 =A0 return flag_store(s, buf, length, SLAB_RECLAIM_ACCOUNT);
> =A0}
> =A0SLAB_ATTR(reclaim_account);
>
> =A0static ssize_t hwcache_align_show(struct kmem_cache *s, char *buf)
> =A0{
> - =A0 =A0 =A0 return sprintf(buf, "%d\n", !!(s->flags & SLAB_HWCACHE_ALIG=
N));
> + =A0 =A0 =A0 return flag_show(s, buf, SLAB_HWCACHE_ALIGN);
> =A0}
> =A0SLAB_ATTR_RO(hwcache_align);
>
> =A0#ifdef CONFIG_ZONE_DMA
> =A0static ssize_t cache_dma_show(struct kmem_cache *s, char *buf)
> =A0{
> - =A0 =A0 =A0 return sprintf(buf, "%d\n", !!(s->flags & SLAB_CACHE_DMA));
> + =A0 =A0 =A0 return flag_show(s, buf, SLAB_CACHE_DMA);
> =A0}
> =A0SLAB_ATTR_RO(cache_dma);
> =A0#endif
>
> =A0static ssize_t destroy_by_rcu_show(struct kmem_cache *s, char *buf)
> =A0{
> - =A0 =A0 =A0 return sprintf(buf, "%d\n", !!(s->flags & SLAB_DESTROY_BY_R=
CU));
> + =A0 =A0 =A0 return flag_show(s, buf, SLAB_DESTROY_BY_RCU);
> =A0}
> =A0SLAB_ATTR_RO(destroy_by_rcu);
>
> @@ -4032,88 +4055,61 @@ SLAB_ATTR_RO(total_objects);
>
> =A0static ssize_t sanity_checks_show(struct kmem_cache *s, char *buf)
> =A0{
> - =A0 =A0 =A0 return sprintf(buf, "%d\n", !!(s->flags & SLAB_DEBUG_FREE))=
;
> + =A0 =A0 =A0 return flag_show(s, buf, SLAB_DEBUG_FREE);
> =A0}
>
> =A0static ssize_t sanity_checks_store(struct kmem_cache *s,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0const char=
 *buf, size_t length)
> =A0{
> - =A0 =A0 =A0 s->flags &=3D ~SLAB_DEBUG_FREE;
> - =A0 =A0 =A0 if (buf[0] =3D=3D '1')
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 s->flags |=3D SLAB_DEBUG_FREE;
> - =A0 =A0 =A0 return length;
> + =A0 =A0 =A0 return flag_store(s, buf, length, SLAB_DEBUG_FREE);
> =A0}
> =A0SLAB_ATTR(sanity_checks);
>
> =A0static ssize_t trace_show(struct kmem_cache *s, char *buf)
> =A0{
> - =A0 =A0 =A0 return sprintf(buf, "%d\n", !!(s->flags & SLAB_TRACE));
> + =A0 =A0 =A0 return flag_show(s, buf, SLAB_TRACE);
> =A0}
>
> =A0static ssize_t trace_store(struct kmem_cache *s, const char *buf,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0size_t length)
> =A0{
> - =A0 =A0 =A0 s->flags &=3D ~SLAB_TRACE;
> - =A0 =A0 =A0 if (buf[0] =3D=3D '1')
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 s->flags |=3D SLAB_TRACE;
> - =A0 =A0 =A0 return length;
> + =A0 =A0 =A0 return flag_store(s, buf, length, SLAB_TRACE);
> =A0}
> =A0SLAB_ATTR(trace);
>
> =A0static ssize_t red_zone_show(struct kmem_cache *s, char *buf)
> =A0{
> - =A0 =A0 =A0 return sprintf(buf, "%d\n", !!(s->flags & SLAB_RED_ZONE));
> + =A0 =A0 =A0 return flag_show(s, buf, SLAB_RED_ZONE);
> =A0}
>
> =A0static ssize_t red_zone_store(struct kmem_cache *s,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0const char=
 *buf, size_t length)
> =A0{
> - =A0 =A0 =A0 if (any_slab_objects(s))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EBUSY;
> -
> - =A0 =A0 =A0 s->flags &=3D ~SLAB_RED_ZONE;
> - =A0 =A0 =A0 if (buf[0] =3D=3D '1')
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 s->flags |=3D SLAB_RED_ZONE;
> - =A0 =A0 =A0 calculate_sizes(s, -1);
> - =A0 =A0 =A0 return length;
> + =A0 =A0 =A0 return flag_store_sizechange(s, buf, length, SLAB_RED_ZONE)=
;
> =A0}
> =A0SLAB_ATTR(red_zone);
>
> =A0static ssize_t poison_show(struct kmem_cache *s, char *buf)
> =A0{
> - =A0 =A0 =A0 return sprintf(buf, "%d\n", !!(s->flags & SLAB_POISON));
> + =A0 =A0 =A0 return flag_show(s, buf, SLAB_POISON);
> =A0}
>
> =A0static ssize_t poison_store(struct kmem_cache *s,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0const char=
 *buf, size_t length)
> =A0{
> - =A0 =A0 =A0 if (any_slab_objects(s))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EBUSY;
> -
> - =A0 =A0 =A0 s->flags &=3D ~SLAB_POISON;
> - =A0 =A0 =A0 if (buf[0] =3D=3D '1')
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 s->flags |=3D SLAB_POISON;
> - =A0 =A0 =A0 calculate_sizes(s, -1);
> - =A0 =A0 =A0 return length;
> + =A0 =A0 =A0 return flag_store_sizechange(s, buf, length, SLAB_POISON);
> =A0}
> =A0SLAB_ATTR(poison);
>
> =A0static ssize_t store_user_show(struct kmem_cache *s, char *buf)
> =A0{
> - =A0 =A0 =A0 return sprintf(buf, "%d\n", !!(s->flags & SLAB_STORE_USER))=
;
> + =A0 =A0 =A0 return flag_show(s, buf, SLAB_STORE_USER);
> =A0}
>
> =A0static ssize_t store_user_store(struct kmem_cache *s,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0const char=
 *buf, size_t length)
> =A0{
> - =A0 =A0 =A0 if (any_slab_objects(s))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EBUSY;
> -
> - =A0 =A0 =A0 s->flags &=3D ~SLAB_STORE_USER;
> - =A0 =A0 =A0 if (buf[0] =3D=3D '1')
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 s->flags |=3D SLAB_STORE_USER;
> - =A0 =A0 =A0 calculate_sizes(s, -1);
> - =A0 =A0 =A0 return length;
> + =A0 =A0 =A0 return flag_store_sizechange(s, buf, length, SLAB_STORE_USE=
R);
> =A0}
> =A0SLAB_ATTR(store_user);
>
> @@ -4156,16 +4152,13 @@ SLAB_ATTR_RO(free_calls);
> =A0#ifdef CONFIG_FAILSLAB
> =A0static ssize_t failslab_show(struct kmem_cache *s, char *buf)
> =A0{
> - =A0 =A0 =A0 return sprintf(buf, "%d\n", !!(s->flags & SLAB_FAILSLAB));
> + =A0 =A0 =A0 return flag_show(s, buf, SLAB_FAILSLAB);
> =A0}
>
> =A0static ssize_t failslab_store(struct kmem_cache *s, const char *buf,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0size_t length)
> =A0{
> - =A0 =A0 =A0 s->flags &=3D ~SLAB_FAILSLAB;
> - =A0 =A0 =A0 if (buf[0] =3D=3D '1')
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 s->flags |=3D SLAB_FAILSLAB;
> - =A0 =A0 =A0 return length;
> + =A0 =A0 =A0 return flag_store(s, buf, length, SLAB_FAILSLAB);
> =A0}
> =A0SLAB_ATTR(failslab);
> =A0#endif
> --
> 1.7.4.1
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
