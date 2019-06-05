Return-Path: <SRS0=9Pd6=UE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_MED,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A4D78C28CC5
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 19:56:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6EA7D206C3
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 19:56:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="ONPOG0cr"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6EA7D206C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0CFDC6B0266; Wed,  5 Jun 2019 15:56:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 059A86B0269; Wed,  5 Jun 2019 15:56:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E89A46B026A; Wed,  5 Jun 2019 15:56:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f199.google.com (mail-yb1-f199.google.com [209.85.219.199])
	by kanga.kvack.org (Postfix) with ESMTP id C2BE36B0266
	for <linux-mm@kvack.org>; Wed,  5 Jun 2019 15:56:48 -0400 (EDT)
Received: by mail-yb1-f199.google.com with SMTP id l184so84706ybl.3
        for <linux-mm@kvack.org>; Wed, 05 Jun 2019 12:56:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=9q4+At4yxP0TO9XKtv623886ZmeIrCw2KxtQ8rIVE+c=;
        b=H1h8g/4J3XrZPSX52i/yy2furBfbltd6ooJPPpmzieIbnmNi/EXQkf/mjhyBNdutQB
         hqPKEyj1VX+i9xic7IRlvYSzk0fwlaYRPN0mvzuRkV5J3N/rPnk4txbQoZlaiYGvVt5c
         h70vJnNZwEY3jTH0FylRiptT7ZTcDDKyx86h4U8d+8+igxVKyx9hy4iHe+IrAQoXgimN
         oeK10bIlrfFW9A3aLa5wc2wbUsnP/qk5mNMAn8W4pIS1ISsLc8e6pgm/DXlkN0x0mIhq
         kk2wYoZ5k3Hr4JTNeGdwLdFyVPfkbC7GpxGN6qJDSFAnO2Rfvj2TZAdFMXBypKLwuxfb
         hh2Q==
X-Gm-Message-State: APjAAAVRtNFJZjpWiZXylIXUOy0Wqh9mDxh8v+y4o4A1qeK6CrB6Ke/S
	qMiJ9huObRAozew6kg3yoprlIYK9YdOxEcxnJFVVVrK3fKy/k9MUfwL8QAvobR0LXPNCvHMdnz4
	2ZCls/qPfybC/lF398NRPB3F/fwvfbYMIhtYo5QCI3HAl/uytWNUFjlxxFrEBJ7QROw==
X-Received: by 2002:a25:55d7:: with SMTP id j206mr21355950ybb.234.1559764608517;
        Wed, 05 Jun 2019 12:56:48 -0700 (PDT)
X-Received: by 2002:a25:55d7:: with SMTP id j206mr21355926ybb.234.1559764607878;
        Wed, 05 Jun 2019 12:56:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559764607; cv=none;
        d=google.com; s=arc-20160816;
        b=Iy4zEb2NKV4tChlKviJZXKF6v3YxuDbkhITfk3gb/t0+i/l7RJYhjYWsWeHa4BwYCU
         Thi+iANP1m13M21adk74X24HqgxUmqTbiC7u7UDo2JTdVui/FbONK3uV/IUBcgwKuXI0
         3HaMiSGHFZ9vczuRSaWqj/PU3JatnYwVwCEKkcceKSZOzf+3XrGe4DlYZdx3rJ19ewds
         pwGBhe2JNKgUa0MAizbWiZRB3opJnjutKOuEMpFighHoIa7foX3PjGALeTZsXvm675VR
         RNr7ofFKo3LTIbnC6BV3iEIDKSCUeS6NK+YlNZUb5MHb1zNVhR1v7Fv/zG3O29nSDfVp
         lWjQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=9q4+At4yxP0TO9XKtv623886ZmeIrCw2KxtQ8rIVE+c=;
        b=fEU3xNH3pneZ1w3mvgVqK7XNeHFgi517aU/PZo9SdICyM1Ko83yDcH1tRupvgq9+u/
         EXyv+3D1+qKHJx9w8JHaAz1eHkQcoUu45biEwT8ro4qZT67rg9B31ADi98+8iMkUjzbM
         RTYzijjPQAUKHK3fHjg5UUJXvRe7e5Gs+aHVwcajva88cNqF9PLIxvLcP5FCyrd6fcwC
         sVX4nMMaN3JOuyCAhmgc0PkWw2Zpeq5xs81x/T8RDxyR1fLUZY97d4AZXYjKJ46afFy1
         7SBHsizir3BEz2igHEEox7z8w64WbI2tDfPAQ6rV6UWHavb8XwkFKovjpFDdVnX2VSBl
         3WIg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=ONPOG0cr;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f64sor10387706ywa.28.2019.06.05.12.56.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 05 Jun 2019 12:56:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=ONPOG0cr;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=9q4+At4yxP0TO9XKtv623886ZmeIrCw2KxtQ8rIVE+c=;
        b=ONPOG0criwRaERkMrKHfVu+FHkSVoaWJAe/3Qcz/W7LCrH5/GIScT4HA/6GrL0+9r8
         o6co8aqwlNSEl7NCQ5sS9tePoeHt4h9GPb68IhajREN/xrsWKcvK3qyMit8mTn0Syc/A
         7iA0JHtcd+FIK9ODp7RhnjbF13bEpwhQGYCei3mrBE/QI6K5gsvChkA/hORMbZ9/NFwj
         fOz5k6FisPTLo3cnO2KlMHYBKGSLayATbBhmtiVl0hlN7FVFEeyjwZxp9QJDFViYJ9Fr
         /8tGYfzZZKKv+lqP9TGaDdXxFpWTov0D05vVZG6KZ2JgmhFAjsoiImnW6hbJ2aiQ0DFz
         doOw==
X-Google-Smtp-Source: APXvYqyT6u3oJyZE6NCw9GM4C6IEV7j7fkZPEOKpEM78DGOX/BwgTrn0eHFIXgvbs4TMZ9Ae/bo4AwJhPu/gx1keGo4=
X-Received: by 2002:a81:a6d5:: with SMTP id d204mr22361086ywh.205.1559764607325;
 Wed, 05 Jun 2019 12:56:47 -0700 (PDT)
MIME-Version: 1.0
References: <20190605100630.13293-1-teawaterz@linux.alibaba.com>
In-Reply-To: <20190605100630.13293-1-teawaterz@linux.alibaba.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Wed, 5 Jun 2019 12:56:36 -0700
Message-ID: <CALvZod7Ya=mPKryiCxKVguGV-hPEjXD_6gBOFs9zJWc_NQMMBQ@mail.gmail.com>
Subject: Re: [PATCH V3 1/2] zpool: Add malloc_support_movable to zpool_driver
To: Hui Zhu <teawaterz@linux.alibaba.com>
Cc: Dan Streetman <ddstreet@ieee.org>, Minchan Kim <minchan@kernel.org>, ngupta@vflare.org, 
	sergey.senozhatsky.work@gmail.com, Seth Jennings <sjenning@redhat.com>, 
	Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 5, 2019 at 3:06 AM Hui Zhu <teawaterz@linux.alibaba.com> wrote:
>
> As a zpool_driver, zsmalloc can allocate movable memory because it
> support migate pages.
> But zbud and z3fold cannot allocate movable memory.
>
> This commit adds malloc_support_movable to zpool_driver.
> If a zpool_driver support allocate movable memory, set it to true.
> And add zpool_malloc_support_movable check malloc_support_movable
> to make sure if a zpool support allocate movable memory.
>
> Signed-off-by: Hui Zhu <teawaterz@linux.alibaba.com>

Reviewed-by: Shakeel Butt <shakeelb@google.com>

IMHO no need to block this series on z3fold query.

> ---
>  include/linux/zpool.h |  3 +++
>  mm/zpool.c            | 16 ++++++++++++++++
>  mm/zsmalloc.c         | 19 ++++++++++---------
>  3 files changed, 29 insertions(+), 9 deletions(-)
>
> diff --git a/include/linux/zpool.h b/include/linux/zpool.h
> index 7238865e75b0..51bf43076165 100644
> --- a/include/linux/zpool.h
> +++ b/include/linux/zpool.h
> @@ -46,6 +46,8 @@ const char *zpool_get_type(struct zpool *pool);
>
>  void zpool_destroy_pool(struct zpool *pool);
>
> +bool zpool_malloc_support_movable(struct zpool *pool);
> +
>  int zpool_malloc(struct zpool *pool, size_t size, gfp_t gfp,
>                         unsigned long *handle);
>
> @@ -90,6 +92,7 @@ struct zpool_driver {
>                         struct zpool *zpool);
>         void (*destroy)(void *pool);
>
> +       bool malloc_support_movable;
>         int (*malloc)(void *pool, size_t size, gfp_t gfp,
>                                 unsigned long *handle);
>         void (*free)(void *pool, unsigned long handle);
> diff --git a/mm/zpool.c b/mm/zpool.c
> index a2dd9107857d..863669212070 100644
> --- a/mm/zpool.c
> +++ b/mm/zpool.c
> @@ -238,6 +238,22 @@ const char *zpool_get_type(struct zpool *zpool)
>         return zpool->driver->type;
>  }
>
> +/**
> + * zpool_malloc_support_movable() - Check if the zpool support
> + * allocate movable memory
> + * @zpool:     The zpool to check
> + *
> + * This returns if the zpool support allocate movable memory.
> + *
> + * Implementations must guarantee this to be thread-safe.
> + *
> + * Returns: true if if the zpool support allocate movable memory, false if not
> + */
> +bool zpool_malloc_support_movable(struct zpool *zpool)
> +{
> +       return zpool->driver->malloc_support_movable;
> +}
> +
>  /**
>   * zpool_malloc() - Allocate memory
>   * @zpool:     The zpool to allocate from.
> diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> index 0787d33b80d8..8f3d9a4d46f4 100644
> --- a/mm/zsmalloc.c
> +++ b/mm/zsmalloc.c
> @@ -437,15 +437,16 @@ static u64 zs_zpool_total_size(void *pool)
>  }
>
>  static struct zpool_driver zs_zpool_driver = {
> -       .type =         "zsmalloc",
> -       .owner =        THIS_MODULE,
> -       .create =       zs_zpool_create,
> -       .destroy =      zs_zpool_destroy,
> -       .malloc =       zs_zpool_malloc,
> -       .free =         zs_zpool_free,
> -       .map =          zs_zpool_map,
> -       .unmap =        zs_zpool_unmap,
> -       .total_size =   zs_zpool_total_size,
> +       .type =                   "zsmalloc",
> +       .owner =                  THIS_MODULE,
> +       .create =                 zs_zpool_create,
> +       .destroy =                zs_zpool_destroy,
> +       .malloc_support_movable = true,
> +       .malloc =                 zs_zpool_malloc,
> +       .free =                   zs_zpool_free,
> +       .map =                    zs_zpool_map,
> +       .unmap =                  zs_zpool_unmap,
> +       .total_size =             zs_zpool_total_size,
>  };
>
>  MODULE_ALIAS("zpool-zsmalloc");
> --
> 2.21.0 (Apple Git-120)
>

