Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id B6C966B01EE
	for <linux-mm@kvack.org>; Thu,  1 Apr 2010 03:09:17 -0400 (EDT)
Received: from il27vts02.mot.com (il27vts02.cig.mot.com [10.17.196.86])
	by mdgate2.corp.mot.com (8.14.3/8.14.3) with SMTP id o3178iDJ015486
	for <linux-mm@kvack.org>; Thu, 1 Apr 2010 01:08:44 -0600 (MDT)
Received: from mail-gy0-f182.google.com (mail-gy0-f182.google.com [209.85.160.182])
	by mdgate2.corp.mot.com (8.14.3/8.14.3) with ESMTP id o3178hm6015475
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=OK)
	for <linux-mm@kvack.org>; Thu, 1 Apr 2010 01:08:43 -0600 (MDT)
Received: by gyh3 with SMTP id 3so303562gyh.27
        for <linux-mm@kvack.org>; Thu, 01 Apr 2010 00:08:51 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4BB43D58.5030801@cs.helsinki.fi>
References: <l2g4810ea571003312024jb883f2eet5b48a7fbb9ec340f@mail.gmail.com>
	 <4BB43D58.5030801@cs.helsinki.fi>
Date: Thu, 1 Apr 2010 15:08:50 +0800
Message-ID: <i2h5f4a33681004010008rdda5bf16g7a9beb9d115da4fb@mail.gmail.com>
Subject: Re: [PATCH] Fix missing of last user info while getting DEBUG_SLAB
	config enabled
From: TAO HU <tghk48@motorola.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: ShiYong LI <shi-yong.li@motorola.com>, linux-kernel@vger.kernel.org, cl@linux-foundation.org, mpm@selenic.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi, Pekka

Thanks for your feedback.

The subject and comments are kind of misleading. Sorry about that.
It intends to make  both Red-Zone and LastUser are available even the
alignment is larger than sizeof(long long).
The idea is to reserve certain room ("align") to let the obj's offset
is aligned to cache-line-size to address requirement of kmalloc().

Regarding align is less than sizeof(unsigned long long), I thin it is
handled in previous code.
Or you still expect to explicitly let align is no less than
sizeof(unsigned long long)?
if (flags & SLAB_RED_ZONE) {
                ralign =3D REDZONE_ALIGN;
             ... ...
        }


--=20
Best Regards
Hu Tao

On Thu, Apr 1, 2010 at 2:29 PM, Pekka Enberg <penberg@cs.helsinki.fi> wrote=
:
> ShiYong LI kirjoitti:
>>
>> Hi all,
>> =A0For OMAP3430 chip, while getting DEBUG_SLAB config enabled, found a b=
ug
>> that last user information is missed in slab corruption log dumped by
>> kernel. Actually, It's caused by ignorance of redzone and last user tag
>> while calling kmem_cache_create() function if cache alignment > 16 bytes
>> (unsigned long long). =A0Here is a patch to fix this problem. Already ve=
rified
>> it on kernel 2.6.29.
>
> The patch is badly whitespace damaged.
>
>> =A0From 26a5a8ad2a1d7612929a91f6866cea9d1bea6077 Mon Sep 17 00:00:00 200=
1
>> From: Shiyong Li <shi-yong.li@motorola.com
>> <mailto:shi-yong.li@motorola.com>>
>> Date: Wed, 31 Mar 2010 10:09:35 +0800
>> Subject: [PATCH] Fix missing of last user info while getting DEBUG_SLAB
>> config enabled.
>> As OMAP3 cache line is 64 byte long, while calling kmem_cache_create()
>> funtion, some cases need 64 byte alignment of requested memory space.
>> But, if cache line > 16 bytes, current kernel ignore redzone
>> and last user debug head/trail tag to make sure this alignment is not
>> broken.
>> This fix removes codes that ignorance of redzone and last user tag.
>> Instead, use "align" argument value as object offset to guarantee the
>> alignment.
>> Signed-off-by: Shiyong Li <shi-yong.li@motorola.com
>> <mailto:shi-yong.li@motorola.com>>
>> ---
>> =A0mm/slab.c | =A0 =A07 ++-----
>> =A01 files changed, 2 insertions(+), 5 deletions(-)
>> diff --git a/mm/slab.c b/mm/slab.c
>> index a8a38ca..84af997 100644
>> --- a/mm/slab.c
>> +++ b/mm/slab.c
>> @@ -2267,9 +2267,6 @@ kmem_cache_create (const char *name, size_t size,
>> size_t align,
>> =A0if (ralign < align) {
>> =A0 ralign =3D align;
>> =A0}
>> - /* disable debug if necessary */
>> - if (ralign > __alignof__(unsigned long long))
>> - =A0flags &=3D ~(SLAB_RED_ZONE | SLAB_STORE_USER);
>> =A0/*
>> =A0 * 4) Store it.
>> =A0 */
>> @@ -2289,8 +2286,8 @@ kmem_cache_create (const char *name, size_t size,
>> size_t align,
>> =A0 */
>> =A0if (flags & SLAB_RED_ZONE) {
>> =A0 /* add space for red zone words */
>> - =A0cachep->obj_offset +=3D sizeof(unsigned long long);
>> - =A0size +=3D 2 * sizeof(unsigned long long);
>> + =A0cachep->obj_offset +=3D align;
>> + =A0size +=3D align + sizeof(unsigned long long);
>> =A0}
>
> I don't understand what you're trying to do here. What if align is less h=
an
> sizeof(unsigned long long)? What if SLAB_RED_ZONE is not enabled but
> =A0SLAB_STORE_USER is?
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0Pekka
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
