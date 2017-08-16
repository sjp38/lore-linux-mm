Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 82C796B0292
	for <linux-mm@kvack.org>; Wed, 16 Aug 2017 07:20:22 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id 83so57958391pgb.14
        for <linux-mm@kvack.org>; Wed, 16 Aug 2017 04:20:22 -0700 (PDT)
Received: from mail-pf0-x242.google.com (mail-pf0-x242.google.com. [2607:f8b0:400e:c00::242])
        by mx.google.com with ESMTPS id c2si427788pli.373.2017.08.16.04.20.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Aug 2017 04:20:21 -0700 (PDT)
Received: by mail-pf0-x242.google.com with SMTP id c65so1118925pfl.0
        for <linux-mm@kvack.org>; Wed, 16 Aug 2017 04:20:21 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <54351127-7222-c578-10f7-ee0dbf8f7879@users.sourceforge.net>
References: <0fec59a9-ac68-33f6-533a-adfb5fa3c380@users.sourceforge.net> <54351127-7222-c578-10f7-ee0dbf8f7879@users.sourceforge.net>
From: Dan Streetman <ddstreet@ieee.org>
Date: Wed, 16 Aug 2017 07:19:40 -0400
Message-ID: <CALZtONAL23OdgQauR28ToqVhvRz2yT9LhVq+8jm3C0g_WVMS6g@mail.gmail.com>
Subject: Re: [PATCH 2/2] zpool: Use common error handling code in zpool_create_pool()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: SF Markus Elfring <elfring@users.sourceforge.net>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, kernel-janitors@vger.kernel.org

On Mon, Aug 14, 2017 at 7:16 AM, SF Markus Elfring
<elfring@users.sourceforge.net> wrote:
> From: Markus Elfring <elfring@users.sourceforge.net>
> Date: Mon, 14 Aug 2017 13:04:33 +0200
>
> Add a jump target so that a bit of exception handling can be better reused
> in this function.
>
> Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>

Acked-by: Dan Streetman <ddstreet@ieee.org>

> ---
>  mm/zpool.c | 9 ++++-----
>  1 file changed, 4 insertions(+), 5 deletions(-)
>
> diff --git a/mm/zpool.c b/mm/zpool.c
> index fe1943f7d844..e4634edef86d 100644
> --- a/mm/zpool.c
> +++ b/mm/zpool.c
> @@ -171,10 +171,8 @@ struct zpool *zpool_create_pool(const char *type, const char *name, gfp_t gfp,
>         }
>
>         zpool = kmalloc(sizeof(*zpool), gfp);
> -       if (!zpool) {
> -               zpool_put_driver(driver);
> -               return NULL;
> -       }
> +       if (!zpool)
> +               goto put_driver;
>
>         zpool->driver = driver;
>         zpool->pool = driver->create(name, gfp, ops, zpool);
> @@ -182,8 +180,9 @@ struct zpool *zpool_create_pool(const char *type, const char *name, gfp_t gfp,
>
>         if (!zpool->pool) {
>                 pr_err("couldn't create %s pool\n", type);
> -               zpool_put_driver(driver);
>                 kfree(zpool);
> +put_driver:
> +               zpool_put_driver(driver);
>                 return NULL;
>         }
>
> --
> 2.14.0
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
