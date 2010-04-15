Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 221FC6B01E3
	for <linux-mm@kvack.org>; Wed, 14 Apr 2010 23:04:48 -0400 (EDT)
Received: from il27vts02.mot.com (il27vts02.cig.mot.com [10.17.196.86])
	by mdgate2.corp.mot.com (8.14.3/8.14.3) with SMTP id o3F34QEj022108
	for <linux-mm@kvack.org>; Wed, 14 Apr 2010 21:04:26 -0600 (MDT)
Received: from mail-gy0-f182.google.com (mail-gy0-f182.google.com [209.85.160.182])
	by mdgate2.corp.mot.com (8.14.3/8.14.3) with ESMTP id o3F2wvTR020617
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=OK)
	for <linux-mm@kvack.org>; Wed, 14 Apr 2010 21:04:26 -0600 (MDT)
Received: by mail-gy0-f182.google.com with SMTP id 20so470672gyh.27
        for <linux-mm@kvack.org>; Wed, 14 Apr 2010 20:04:38 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4BC601C5.5050404@cs.helsinki.fi>
References: <w2z4810ea571004112250x855fadd5uecbc813726ae3412@mail.gmail.com>
	 <4BC601C5.5050404@cs.helsinki.fi>
Date: Thu, 15 Apr 2010 11:04:38 +0800
Message-ID: <h2t5f4a33681004142004zf73f346cl467f0a56a47228cb@mail.gmail.com>
Subject: Re: [PATCH - V2] Fix missing of last user while dumping slab
	corruption log
From: TAO HU <tghk48@motorola.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: ShiYong LI <shi-yong.li@motorola.com>, linux-kernel@vger.kernel.org, cl@linux-foundation.org, mpm@selenic.com, linux-mm@kvack.org, dwmw2@infradead.org, TAO HU <taohu@motorola.com>
List-ID: <linux-mm.kvack.org>

Hi, Pekka Enberg

Thanks!
If we hadn't seen the last user info, we would not have fixed a
difficult bug in our system.
So very glad to know.

--=20
Best Regards
Hu Tao

On Thu, Apr 15, 2010 at 1:56 AM, Pekka Enberg <penberg@cs.helsinki.fi> wrot=
e:
> ShiYong LI wrote:
>>
>> Hi,
>>
>> Compared to previous version, add alignment checking to make sure
>> memory space storing redzone2 and last user tags is 8 byte alignment.
>>
>> From 949e8c29e8681a2359e23a8fbd8b9d4833f42344 Mon Sep 17 00:00:00 2001
>> From: Shiyong Li <shi-yong.li@motorola.com>
>> Date: Mon, 12 Apr 2010 13:48:21 +0800
>> Subject: [PATCH] Fix missing of last user info while getting
>> DEBUG_SLAB config enabled.
>>
>> Even with SLAB_RED_ZONE and SLAB_STORE_USER enabled, kernel would NOT
>> store redzone and last user data around allocated memory space if arch
>> cache line > sizeof(unsigned long long). As a result, last user
>> information
>> is unexpectedly MISSED while dumping slab corruption log.
>>
>> This fix makes sure that redzone and last user tags get stored unless
>> the required alignment breaks redzone's.
>>
>> Signed-off-by: Shiyong Li <shi-yong.li@motorola.com>
>
> OK, I added this to linux-next for testing. Thanks!
>
>> ---
>> =A0mm/slab.c | =A0 =A08 ++++----
>> =A01 files changed, 4 insertions(+), 4 deletions(-)
>>
>> diff --git a/mm/slab.c b/mm/slab.c
>> index a8a38ca..b97c57e 100644
>> --- a/mm/slab.c
>> +++ b/mm/slab.c
>> @@ -2267,8 +2267,8 @@ kmem_cache_create (const char *name, size_t
>> size, size_t align,
>> =A0 =A0 =A0 =A0if (ralign < align) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ralign =3D align;
>> =A0 =A0 =A0 =A0}
>> - =A0 =A0 =A0 /* disable debug if necessary */
>> - =A0 =A0 =A0 if (ralign > __alignof__(unsigned long long))
>> + =A0 =A0 =A0 /* disable debug if not aligning with REDZONE_ALIGN */
>> + =A0 =A0 =A0 if (ralign & (__alignof__(unsigned long long) - 1))
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0flags &=3D ~(SLAB_RED_ZONE | SLAB_STORE_U=
SER);
>> =A0 =A0 =A0 =A0/*
>> =A0 =A0 =A0 =A0 * 4) Store it.
>> @@ -2289,8 +2289,8 @@ kmem_cache_create (const char *name, size_t
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
