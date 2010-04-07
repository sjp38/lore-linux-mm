Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id B1DF46B01E3
	for <linux-mm@kvack.org>; Wed,  7 Apr 2010 11:25:34 -0400 (EDT)
Received: by fxm4 with SMTP id 4so1258917fxm.6
        for <linux-mm@kvack.org>; Wed, 07 Apr 2010 08:25:32 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <k2s4810ea571004020021hade8123mb571b803b8472aef@mail.gmail.com>
References: <k2s4810ea571004020021hade8123mb571b803b8472aef@mail.gmail.com>
Date: Wed, 7 Apr 2010 18:25:31 +0300
Message-ID: <p2k84144f021004070825jd3530d04v9d339c8d50c4593d@mail.gmail.com>
Subject: Re: [PATCH] Fix missing of last user while dumping slab corruption
	log
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: ShiYong LI <a22381@motorola.com>
Cc: linux-kernel@vger.kernel.org, cl@linux-foundation.org, mpm@selenic.com, linux-mm@kvack.org, tghk48@motorola.com, dwmw2@infradead.org
List-ID: <linux-mm.kvack.org>

Hi,

(I'm cc'ing David who did some fixes in this area previously.)

On Fri, Apr 2, 2010 at 10:21 AM, ShiYong LI <a22381@motorola.com> wrote:
> Even with SLAB_RED_ZONE and SLAB_STORE_USER enabled, kernel would NOT
> store redzone and last user data around allocated memory space if arch
> cache line > sizeof(unsigned long long). As a result, last user informati=
on
> is unexpectedly MISSED while dumping slab corruption log.
>
> This patch makes sure that redzone and last user tags get stored whatever
> arch cache line.
>
> Compared to original codes, the change surely affects head redzone (redzo=
ne1).
> Actually, with SLAB_RED_ZONE and SLAB_STORE_USER enabled,
> allocated memory layout is as below:
>
> [ redzone1 ] =A0 <--------- Affected area.
> [ real object space ]
> [ redzone2 ]
> [ last user ]
> [ ... ]
>
> Let's do some analysis: (whatever SLAB_STORE_USER is).
>
> 1) With SLAB_RED_ZONE on, "align" >=3D sizeof(unsigned long long) accordi=
ng to
> =A0 =A0the following codes:
> =A0 =A0 =A0 =A0/* 2) arch mandated alignment */
> =A0 =A0 =A0 =A0if (ralign < ARCH_SLAB_MINALIGN) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ralign =3D ARCH_SLAB_MINALIGN;
> =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0/* 3) caller mandated alignment */
> =A0 =A0 =A0 =A0if (ralign < align) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ralign =3D align;
> =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0...
> =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 * 4) Store it.
> =A0 =A0 =A0 =A0 */
> =A0 =A0 =A0 =A0align =3D ralign;
>
> =A0 =A0That's to say, could guarantee that redzone1 does NOT get broken
> at all. Meanwhile,
> =A0 =A0Real object space could meet the need of cache line size by using
> "align" =A0argument.
>
> 2) With SLAB_RED_ZONE off, the change has no impact.
>
>
> From 03b28964311090533643acd267abe0cbc3c9b0a5 Mon Sep 17 00:00:00 2001
> From: Shiyong Li <shi-yong.li@motorola.com>
> Date: Fri, 2 Apr 2010 14:50:30 +0800
> Subject: [PATCH] Fix missing of last user info while getting
> DEBUG_SLAB config enabled.
>
> Even with SLAB_RED_ZONE and SLAB_STORE_USER enabled, kernel would NOT
> store redzone and last user data around allocated memory space if arch
> cache line > sizeof(unsigned long long). As a result, last user informati=
on
> is unexpectedly MISSED while dumping slab corruption log.
>
> This fix makes sure that redzone and last user tags get stored whatever
> cache line.
>
> Signed-off-by: Shiyong Li <shi-yong.li@motorola.com>
> ---
> =A0mm/slab.c | =A0 =A07 ++-----
> =A01 files changed, 2 insertions(+), 5 deletions(-)
>
> diff --git a/mm/slab.c b/mm/slab.c
> index a8a38ca..84af997 100644
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -2267,9 +2267,6 @@ kmem_cache_create (const char *name, size_t
> size, size_t align,
> =A0 =A0 =A0 =A0if (ralign < align) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ralign =3D align;
> =A0 =A0 =A0 =A0}
> - =A0 =A0 =A0 /* disable debug if necessary */
> - =A0 =A0 =A0 if (ralign > __alignof__(unsigned long long))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 flags &=3D ~(SLAB_RED_ZONE | SLAB_STORE_USE=
R);
> =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 * 4) Store it.
> =A0 =A0 =A0 =A0 */
> @@ -2289,8 +2286,8 @@ kmem_cache_create (const char *name, size_t
> size, size_t align,
> =A0 =A0 =A0 =A0 */
> =A0 =A0 =A0 =A0if (flags & SLAB_RED_ZONE) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* add space for red zone words */
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 cachep->obj_offset +=3D sizeof(unsigned lon=
g long);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 size +=3D 2 * sizeof(unsigned long long);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 cachep->obj_offset +=3D align;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 size +=3D align + sizeof(unsigned long long=
);
> =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0if (flags & SLAB_STORE_USER) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* user store requires one word storage be=
hind the end of

The problem I have with this patch is that I am unable to convince
myself that it's correct.

The code in question is pretty hard to follow and it can break on
architectures with strict alignment requirements. I'm not sure I fully
understand why we've been disabling debugging in the first place.

On which architectures have you verified this fix?

                        Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
