Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 0FC576B021D
	for <linux-mm@kvack.org>; Tue, 13 Apr 2010 03:05:04 -0400 (EDT)
Received: from il27vts03 (il27vts03.cig.mot.com [10.17.196.87])
	by mdgate2.corp.mot.com (8.14.3/8.14.3) with SMTP id o3D74nXY019724
	for <linux-mm@kvack.org>; Tue, 13 Apr 2010 01:04:49 -0600 (MDT)
Received: from mail-yw0-f184.google.com (mail-yw0-f184.google.com [209.85.211.184])
	by mdgate2.corp.mot.com (8.14.3/8.14.3) with ESMTP id o3D73T5Z019524
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=OK)
	for <linux-mm@kvack.org>; Tue, 13 Apr 2010 01:04:49 -0600 (MDT)
Received: by mail-yw0-f184.google.com with SMTP id 14so1955610ywh.25
        for <linux-mm@kvack.org>; Tue, 13 Apr 2010 00:05:01 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <w2z4810ea571004112250x855fadd5uecbc813726ae3412@mail.gmail.com>
References: <w2z4810ea571004112250x855fadd5uecbc813726ae3412@mail.gmail.com>
Date: Tue, 13 Apr 2010 15:05:00 +0800
Message-ID: <h2v5f4a33681004130005xc06eadf7jc94e9257c6af4350@mail.gmail.com>
Subject: Re: [PATCH - V2] Fix missing of last user while dumping slab
	corruption log
From: TAO HU <tghk48@motorola.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-kernel@vger.kernel.org, cl@linux-foundation.org, mpm@selenic.com, linux-mm@kvack.org, dwmw2@infradead.org, TAO HU <taohu@motorola.com>, ShiYong LI <shi-yong.li@motorola.com>
List-ID: <linux-mm.kvack.org>

Hi,  Pekka Enberg

Actually we greped "kmem_cache_create" in whole kernel souce tree
(2.6.29 and 2.6.32).

Either "align" equal to "0" or flag SLAB_HWCACHE_ALIGN is used when
calling kmem_cache_create().
Seems all of arch's cache-line-size is multiple of 64-bit/8-byte
(sizeof(long long)) except  arch-microblaze (4-byte).
The smallest (except arch-microblaze) cache-line-size is 2^4=3D 16-byte
as I can see.
So even considering possible sizeof(long long) =3D=3D 128-bit/16-byte, it
is still safe to apply Shiyong's original version.

Anyway, Shiyong's new patch check the weired situation that "align >
sizeof(long long) && align is NOT multiple of sizeof (long long)"
Let us know whether the new version address your concerns.

--=20
Best Regards
Hu Tao





On Mon, Apr 12, 2010 at 1:50 PM, ShiYong LI <shi-yong.li@motorola.com> wrot=
e:
> Hi,
>
> Compared to previous version, add alignment checking to make sure
> memory space storing redzone2 and last user tags is 8 byte alignment.
>
> From 949e8c29e8681a2359e23a8fbd8b9d4833f42344 Mon Sep 17 00:00:00 2001
> From: Shiyong Li <shi-yong.li@motorola.com>
> Date: Mon, 12 Apr 2010 13:48:21 +0800
> Subject: [PATCH] Fix missing of last user info while getting
> DEBUG_SLAB config enabled.
>
> Even with SLAB_RED_ZONE and SLAB_STORE_USER enabled, kernel would NOT
> store redzone and last user data around allocated memory space if arch
> cache line > sizeof(unsigned long long). As a result, last user informati=
on
> is unexpectedly MISSED while dumping slab corruption log.
>
> This fix makes sure that redzone and last user tags get stored unless
> the required alignment breaks redzone's.
>
> Signed-off-by: Shiyong Li <shi-yong.li@motorola.com>
> ---
> =A0mm/slab.c | =A0 =A08 ++++----
> =A01 files changed, 4 insertions(+), 4 deletions(-)
>
> diff --git a/mm/slab.c b/mm/slab.c
> index a8a38ca..b97c57e 100644
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -2267,8 +2267,8 @@ kmem_cache_create (const char *name, size_t
> size, size_t align,
> =A0 =A0 =A0 =A0if (ralign < align) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ralign =3D align;
> =A0 =A0 =A0 =A0}
> - =A0 =A0 =A0 /* disable debug if necessary */
> - =A0 =A0 =A0 if (ralign > __alignof__(unsigned long long))
> + =A0 =A0 =A0 /* disable debug if not aligning with REDZONE_ALIGN */
> + =A0 =A0 =A0 if (ralign & (__alignof__(unsigned long long) - 1))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0flags &=3D ~(SLAB_RED_ZONE | SLAB_STORE_US=
ER);
> =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 * 4) Store it.
> @@ -2289,8 +2289,8 @@ kmem_cache_create (const char *name, size_t
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
> --
> 1.6.0.4
>
>
>
>
>
> --
> Thanks & Best Regards
> Shiyong
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
