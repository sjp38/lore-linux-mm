Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f178.google.com (mail-ob0-f178.google.com [209.85.214.178])
	by kanga.kvack.org (Postfix) with ESMTP id 086156B006C
	for <linux-mm@kvack.org>; Sat, 31 Jan 2015 03:59:59 -0500 (EST)
Received: by mail-ob0-f178.google.com with SMTP id uz6so9827083obc.9
        for <linux-mm@kvack.org>; Sat, 31 Jan 2015 00:59:58 -0800 (PST)
Received: from mail-oi0-x232.google.com (mail-oi0-x232.google.com. [2607:f8b0:4003:c06::232])
        by mx.google.com with ESMTPS id p203si6379370oig.79.2015.01.31.00.59.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 31 Jan 2015 00:59:58 -0800 (PST)
Received: by mail-oi0-f50.google.com with SMTP id h136so38217373oig.9
        for <linux-mm@kvack.org>; Sat, 31 Jan 2015 00:59:58 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1422107403-10071-1-git-send-email-opensource.ganesh@gmail.com>
References: <1422107403-10071-1-git-send-email-opensource.ganesh@gmail.com>
Date: Sat, 31 Jan 2015 16:59:58 +0800
Message-ID: <CADAEsF_fVRNCY-mx1EoyO2KwREfz6753JKdHpHMgbJUXf2sdsQ@mail.gmail.com>
Subject: Re: [PATCH] mm/zsmalloc: avoid unnecessary iteration when freeing size_class
From: Ganesh Mahendran <opensource.ganesh@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Ganesh Mahendran <opensource.ganesh@gmail.com>

ping.

2015-01-24 21:50 GMT+08:00 Ganesh Mahendran <opensource.ganesh@gmail.com>:
> The pool->size_class[i] is assigned with the i from (zs_size_classes - 1) to 0.
> So if we failed in zs_create_pool(), we only need to iterate from (zs_size_classes - 1)
> to i, instead of from 0 to (zs_size_classes - 1)

No functionality has been changed. This patch just avoids some
necessary iteration.

Thanks.

>
> Signed-off-by: Ganesh Mahendran <opensource.ganesh@gmail.com>
> Cc: Nitin Gupta <ngupta@vflare.org>
> Cc: Minchan Kim <minchan@kernel.org>
> ---
>  mm/zsmalloc.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> index 16617e9..e6fa3da 100644
> --- a/mm/zsmalloc.c
> +++ b/mm/zsmalloc.c
> @@ -1433,12 +1433,12 @@ void zs_destroy_pool(struct zs_pool *pool)
>
>         zs_pool_stat_destroy(pool);
>
> -       for (i = 0; i < zs_size_classes; i++) {
> +       for (i = zs_size_classes - 1; i >= 0; i--) {
>                 int fg;
>                 struct size_class *class = pool->size_class[i];
>
>                 if (!class)
> -                       continue;
> +                       break;
>
>                 if (class->index != i)
>                         continue;
> --
> 1.7.9.5
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
