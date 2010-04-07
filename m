Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 8DF036B01E3
	for <linux-mm@kvack.org>; Wed,  7 Apr 2010 10:33:02 -0400 (EDT)
Received: from il06vts03.mot.com (il06vts03.mot.com [129.188.137.143])
	by mdgate1.mot.com (8.14.3/8.14.3) with SMTP id o37EXDtm001271
	for <linux-mm@kvack.org>; Wed, 7 Apr 2010 08:33:13 -0600 (MDT)
Received: from mail-iw0-f199.google.com (mail-iw0-f199.google.com [209.85.223.199])
	by mdgate1.mot.com (8.14.3/8.14.3) with ESMTP id o37EEsN1024819
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=OK)
	for <linux-mm@kvack.org>; Wed, 7 Apr 2010 08:33:13 -0600 (MDT)
Received: by mail-iw0-f199.google.com with SMTP id 37so307955iwn.15
        for <linux-mm@kvack.org>; Wed, 07 Apr 2010 07:32:55 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <u2i5f4a33681004051824n7c9e70f9pe532c260cb9c7fd2@mail.gmail.com>
References: <k2s4810ea571004020021hade8123mb571b803b8472aef@mail.gmail.com>
	 <u2i5f4a33681004051824n7c9e70f9pe532c260cb9c7fd2@mail.gmail.com>
Date: Wed, 7 Apr 2010 22:32:55 +0800
Message-ID: <y2g5f4a33681004070732pea50dd2cid6c1de95cbbac3c4@mail.gmail.com>
Subject: Re: [PATCH] Fix missing of last user while dumping slab corruption
	log
From: TAO HU <tghk48@motorola.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-kernel@vger.kernel.org, cl@linux-foundation.org, mpm@selenic.com, linux-mm@kvack.org, ShiYong LI <shi-yong.li@motorola.com>
List-ID: <linux-mm.kvack.org>

Hi, Pekka Enberg

Can we assume you have no objection for this patch? :)

--=20
Best Regards
Hu Tao

On Tue, Apr 6, 2010 at 9:24 AM, TAO HU <tghk48@motorola.com> wrote:
> Hi, Pekka Enberg
>
> This is the updated version with format fix and comments refinement.
> Let us know whether you still have comments.
>
> --
> Best Regards
> Hu Tao
>
> On Fri, Apr 2, 2010 at 3:21 PM, ShiYong LI <shi-yong.li@motorola.com> wro=
te:
>> Hi,
>>
>> Even with SLAB_RED_ZONE and SLAB_STORE_USER enabled, kernel would NOT
>> store redzone and last user data around allocated memory space if arch
>> cache line > sizeof(unsigned long long). As a result, last user informat=
ion
>> is unexpectedly MISSED while dumping slab corruption log.
>>
>> This patch makes sure that redzone and last user tags get stored whateve=
r
>> arch cache line.
>>
>> Compared to original codes, the change surely affects head redzone (redz=
one1).
>> Actually, with SLAB_RED_ZONE and SLAB_STORE_USER enabled,
>> allocated memory layout is as below:
>>
>> [ redzone1 ] =A0 <--------- Affected area.
>> [ real object space ]
>> [ redzone2 ]
>> [ last user ]
>> [ ... ]
>>
>> Let's do some analysis: (whatever SLAB_STORE_USER is).
>>
>> 1) With SLAB_RED_ZONE on, "align" >=3D sizeof(unsigned long long) accord=
ing to
>> =A0 =A0the following codes:
>> =A0 =A0 =A0 =A0/* 2) arch mandated alignment */
>> =A0 =A0 =A0 =A0if (ralign < ARCH_SLAB_MINALIGN) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ralign =3D ARCH_SLAB_MINALIGN;
>> =A0 =A0 =A0 =A0}
>> =A0 =A0 =A0 =A0/* 3) caller mandated alignment */
>> =A0 =A0 =A0 =A0if (ralign < align) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ralign =3D align;
>> =A0 =A0 =A0 =A0}
>> =A0 =A0 =A0 =A0...
>> =A0 =A0 =A0 =A0/*
>> =A0 =A0 =A0 =A0 * 4) Store it.
>> =A0 =A0 =A0 =A0 */
>> =A0 =A0 =A0 =A0align =3D ralign;
>>
>> =A0 =A0That's to say, could guarantee that redzone1 does NOT get broken
>> at all. Meanwhile,
>> =A0 =A0Real object space could meet the need of cache line size by using
>> "align" =A0argument.
>>
>> 2) With SLAB_RED_ZONE off, the change has no impact.
>>
>>
>> From 03b28964311090533643acd267abe0cbc3c9b0a5 Mon Sep 17 00:00:00 2001
>> From: Shiyong Li <shi-yong.li@motorola.com>
>> Date: Fri, 2 Apr 2010 14:50:30 +0800
>> Subject: [PATCH] Fix missing of last user info while getting
>> DEBUG_SLAB config enabled.
>>
>> Even with SLAB_RED_ZONE and SLAB_STORE_USER enabled, kernel would NOT
>> store redzone and last user data around allocated memory space if arch
>> cache line > sizeof(unsigned long long). As a result, last user informat=
ion
>> is unexpectedly MISSED while dumping slab corruption log.
>>
>> This fix makes sure that redzone and last user tags get stored whatever
>> cache line.
>>
>> Signed-off-by: Shiyong Li <shi-yong.li@motorola.com>
>> ---
>> =A0mm/slab.c | =A0 =A07 ++-----
>> =A01 files changed, 2 insertions(+), 5 deletions(-)
>>
>> diff --git a/mm/slab.c b/mm/slab.c
>> index a8a38ca..84af997 100644
>> --- a/mm/slab.c
>> +++ b/mm/slab.c
>> @@ -2267,9 +2267,6 @@ kmem_cache_create (const char *name, size_t
>> size, size_t align,
>> =A0 =A0 =A0 =A0if (ralign < align) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ralign =3D align;
>> =A0 =A0 =A0 =A0}
>> - =A0 =A0 =A0 /* disable debug if necessary */
>> - =A0 =A0 =A0 if (ralign > __alignof__(unsigned long long))
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 flags &=3D ~(SLAB_RED_ZONE | SLAB_STORE_US=
ER);
>> =A0 =A0 =A0 =A0/*
>> =A0 =A0 =A0 =A0 * 4) Store it.
>> =A0 =A0 =A0 =A0 */
>> @@ -2289,8 +2286,8 @@ kmem_cache_create (const char *name, size_t
>> size, size_t align,
>> =A0 =A0 =A0 =A0 */
>> =A0 =A0 =A0 =A0if (flags & SLAB_RED_ZONE) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* add space for red zone words */
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 cachep->obj_offset +=3D sizeof(unsigned lo=
ng long);
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 size +=3D 2 * sizeof(unsigned long long);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 cachep->obj_offset +=3D align;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 size +=3D align + sizeof(unsigned long lon=
g);
>> =A0 =A0 =A0 =A0}
>> =A0 =A0 =A0 =A0if (flags & SLAB_STORE_USER) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* user store requires one word storage b=
ehind the end of
>> --
>> 1.6.0.4
>>
>>
>> Thanks & Best Regards
>> Shiyong
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org. =A0For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
