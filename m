Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 3F36E6B0038
	for <linux-mm@kvack.org>; Wed,  9 Sep 2015 05:02:09 -0400 (EDT)
Received: by wicfx3 with SMTP id fx3so148451448wic.1
        for <linux-mm@kvack.org>; Wed, 09 Sep 2015 02:02:08 -0700 (PDT)
Received: from eu-smtp-delivery-143.mimecast.com (eu-smtp-delivery-143.mimecast.com. [207.82.80.143])
        by mx.google.com with ESMTPS id lj8si3421211wic.16.2015.09.09.02.02.07
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 09 Sep 2015 02:02:07 -0700 (PDT)
Message-ID: <55EFF585.80603@arm.com>
Date: Wed, 09 Sep 2015 10:01:57 +0100
From: Vladimir Murzin <vladimir.murzin@arm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] kasan: Fix a type conversion error
References: <1441771180-206648-1-git-send-email-long.wanglong@huawei.com> <1441771180-206648-3-git-send-email-long.wanglong@huawei.com>
In-Reply-To: <1441771180-206648-3-git-send-email-long.wanglong@huawei.com>
Content-Type: text/plain; charset=WINDOWS-1252
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wang Long <long.wanglong@huawei.com>, "ryabinin.a.a@gmail.com" <ryabinin.a.a@gmail.com>, "adech.fo@gmail.com" <adech.fo@gmail.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "rusty@rustcorp.com.au" <rusty@rustcorp.com.au>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "wanglong@laoqinren.net" <wanglong@laoqinren.net>, "peifeiyue@huawei.com" <peifeiyue@huawei.com>, "morgan.wang@huawei.com" <morgan.wang@huawei.com>

On 09/09/15 04:59, Wang Long wrote:
> The current KASAN code can find the following out-of-bounds

Should it be "cannot"?

Vladimir

> bugs:
> =09char *ptr;
> =09ptr =3D kmalloc(8, GFP_KERNEL);
> =09memset(ptr+7, 0, 2);
>=20
> the cause of the problem is the type conversion error in
> *memory_is_poisoned_n* function. So this patch fix that.
>=20
> Signed-off-by: Wang Long <long.wanglong@huawei.com>
> ---
>  mm/kasan/kasan.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>=20
> diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
> index 7b28e9c..5d65d06 100644
> --- a/mm/kasan/kasan.c
> +++ b/mm/kasan/kasan.c
> @@ -204,7 +204,7 @@ static __always_inline bool memory_is_poisoned_n(unsi=
gned long addr,
>  =09=09s8 *last_shadow =3D (s8 *)kasan_mem_to_shadow((void *)last_byte);
> =20
>  =09=09if (unlikely(ret !=3D (unsigned long)last_shadow ||
> -=09=09=09((last_byte & KASAN_SHADOW_MASK) >=3D *last_shadow)))
> +=09=09=09((long)(last_byte & KASAN_SHADOW_MASK) >=3D *last_shadow)))
>  =09=09=09return true;
>  =09}
>  =09return false;
>=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
