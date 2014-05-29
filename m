Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id DA3796B0035
	for <linux-mm@kvack.org>; Thu, 29 May 2014 09:17:26 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id kx10so364620pab.0
        for <linux-mm@kvack.org>; Thu, 29 May 2014 06:17:26 -0700 (PDT)
Received: from smtp.gentoo.org (woodpecker.gentoo.org. [2001:470:ea4a:1:214:c2ff:fe64:b2d3])
        by mx.google.com with ESMTPS id ys3si968352pab.26.2014.05.29.06.17.25
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 May 2014 06:17:25 -0700 (PDT)
References: <1401344554-3596-1-git-send-email-iamjoonsoo.kim@lge.com>
Mime-Version: 1.0 (1.0)
In-Reply-To: <1401344554-3596-1-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain;
	charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Message-Id: <7534A26C-36BC-455C-94DE-CA1234CE1803@gentoo.org>
From: Richard Yao <ryao@gentoo.org>
Subject: Re: [PATCH] vmalloc: use rcu list iterator to reduce vmap_area_lock contention
Date: Thu, 29 May 2014 09:17:22 -0400
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Zhang Yanfei <zhangyanfei.yes@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Andi Kleen <andi@firstfloor.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

I do not have a way of tracing it. I meant to reply when I did, but that has=
 not changed. That being said, I like this patch.

On May 29, 2014, at 2:22 AM, Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:

> Richard Yao reported a month ago that his system have a trouble
> with vmap_area_lock contention during performance analysis
> by /proc/meminfo. Andrew asked why his analysis checks /proc/meminfo
> stressfully, but he didn't answer it.
>=20
> https://lkml.org/lkml/2014/4/10/416
>=20
> Although I'm not sure that this is right usage or not, there is a solution=

> reducing vmap_area_lock contention with no side-effect. That is just
> to use rcu list iterator in get_vmalloc_info(). This function only needs
> values on vmap_area structure, so we don't need to grab a spinlock.
>=20
> Reported-by: Richard Yao <ryao@gentoo.org>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>=20
> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> index f64632b..fdbb116 100644
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -2690,14 +2690,14 @@ void get_vmalloc_info(struct vmalloc_info *vmi)
>=20
>    prev_end =3D VMALLOC_START;
>=20
> -    spin_lock(&vmap_area_lock);
> +    rcu_read_lock();
>=20
>    if (list_empty(&vmap_area_list)) {
>        vmi->largest_chunk =3D VMALLOC_TOTAL;
>        goto out;
>    }
>=20
> -    list_for_each_entry(va, &vmap_area_list, list) {
> +    list_for_each_entry_rcu(va, &vmap_area_list, list) {
>        unsigned long addr =3D va->va_start;
>=20
>        /*
> @@ -2724,7 +2724,7 @@ void get_vmalloc_info(struct vmalloc_info *vmi)
>        vmi->largest_chunk =3D VMALLOC_END - prev_end;
>=20
> out:
> -    spin_unlock(&vmap_area_lock);
> +    rcu_read_unlock();
> }
> #endif
>=20
> --=20
> 1.7.9.5
>=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
