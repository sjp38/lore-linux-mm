Return-Path: <SRS0=tO+N=VH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.3 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4A480C74A35
	for <linux-mm@archiver.kernel.org>; Wed, 10 Jul 2019 18:20:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0A4B6214AF
	for <linux-mm@archiver.kernel.org>; Wed, 10 Jul 2019 18:20:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="vh+2Jwx6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0A4B6214AF
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 93B078E0083; Wed, 10 Jul 2019 14:20:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8EA6B8E0032; Wed, 10 Jul 2019 14:20:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7D9AE8E0083; Wed, 10 Jul 2019 14:20:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f197.google.com (mail-yb1-f197.google.com [209.85.219.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5D9C58E0032
	for <linux-mm@kvack.org>; Wed, 10 Jul 2019 14:20:42 -0400 (EDT)
Received: by mail-yb1-f197.google.com with SMTP id q196so2195185ybg.8
        for <linux-mm@kvack.org>; Wed, 10 Jul 2019 11:20:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=i1+UD1I9LOzdxuTZsCLZbyXguKS89Lx3a1U1xfAOFks=;
        b=eyEWHz4G49VY4TNzjlpBk1Nk9rGITeCfN+/r3bnW0JDVqEK3Qxpuo47jgNQ84hmv3y
         ZD/N2qcsmApoDnfAjI2vK1MHe9KvjWCE7y1mR297o9TqgonhzChwrnFqZmGGUdHYzh7M
         bjTdoygjW/S1ZYQdzcrZpvXpEyW0Sw/MpoWCMPV1erB8sGxME3ATkmVSmBV/xnlSuGpT
         3LSXMLBAXQ8IUVlsgHRBOH+0bS1xljxaTMo6qtS4C/TasyrR3lQJwe0sLQcAvEFJXimR
         euZEWukjIYnuLOoED2Rcd/1UTDHQ3UFX9/VDjf4NGZBKpmZZ3A9jgHEzW+ImyaqQ4H3s
         1qxA==
X-Gm-Message-State: APjAAAUMLqyCzEo5UKj20BvRLZu8sKoYn6sxtmeRDFNVCwtFg8crOuPR
	TOfdEKStEJCIjeBn59YTV7LtSrhDBcaGl6ZAtVxbD34fbB0Znos6YGLC6GIyv0/pP4lnDOx6Dhb
	laYLfkhpd8LD1vz+JXK59C0YzLe1ZafKobj0YuSJyxNpNz7MkHknZiu98fAAAcszZJQ==
X-Received: by 2002:a81:70c2:: with SMTP id l185mr18653657ywc.100.1562782841982;
        Wed, 10 Jul 2019 11:20:41 -0700 (PDT)
X-Received: by 2002:a81:70c2:: with SMTP id l185mr18653626ywc.100.1562782841282;
        Wed, 10 Jul 2019 11:20:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562782841; cv=none;
        d=google.com; s=arc-20160816;
        b=UG6hiIDLeXiY6quD5i0Q+PqJVyIozO4wp8PLLavfRErxVGNgmheSBksKR3nBhW7k3A
         uoY4mPQpSfAn/ALHlXvQJiD28PiPO4iFSRH4KFYOclDfWXji7qYP21V3o/UW017cm8bX
         7lW9DFtRXET/Tkg9F/iYh18FRmKNtERiiA1MLkybY7HZEvNkJYVoOvAKFXRAjkF7eb/S
         VXHmRKF1V5ejv29qLL67WvIBzwrKF83G4tqeGLaFNb3WRL1Y4HJKPKM3ovZ5FPwN7YKD
         0KVH/U4Nl/FlhHrZUG3OrnkX6n89pjZYwvlsbMnLNJpjEq06Bjj74m97cF/TBpljeQHq
         KOCg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=i1+UD1I9LOzdxuTZsCLZbyXguKS89Lx3a1U1xfAOFks=;
        b=pKpJJ9vPIsKiy7R8s1XG5PgY0+NpGnGWZ/vXoj9mjVq3NPbYm3Pd3Byc7h7iVNFqR5
         eB+3uwpe3w+iQKJADUzc7gLRb/GuXpcZt3IRcb5NtuMYv4SniWzq2bryi893stiYtJbB
         lbhpahlyYLIy3Vf5oLuqSk3Lx39RthjjsNDRjj+iq6tO5LoacTnQlgiaUKFVd3ALexNm
         bqOZBNlbqNs+tjK1t21lopHVnyWPnuiiK30HMzn+QTg85wfcbovqBC6WaFLvv1Z3lfmP
         8ONmFb6cloUwIV41UxFEO4FakB39G/bfyAcI0bj6JDURzzBmvoCQxX65Wyg3NsdIvWjG
         SSQw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=vh+2Jwx6;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v129sor1518524yba.146.2019.07.10.11.20.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 10 Jul 2019 11:20:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=vh+2Jwx6;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=i1+UD1I9LOzdxuTZsCLZbyXguKS89Lx3a1U1xfAOFks=;
        b=vh+2Jwx6JrbYMXBMbxhjpIH/ZBTSBPT1Hq0fZUUo4CLxMXsgClXgdGZzdNqBizZYlo
         zhJQA0IIppOmWVwv8uuUvvj0iCesRd6XV0aDIIBVahEILoVe1T9AW8JfH7kgk94vMKro
         1YxRItIpCfOnxBTFOlWh1mbbG3KcV76/yGbOs9SLqSCmWNSxZ4bkBGFjYPPmm0214DZa
         m+/mGrDxki6GraUyhLKD0bMjRthpHkwNJDnmPQhgydiCPDItFS8Qkilhu9XkebC4izeV
         CqeOfzKf7aPgziSQVFITTVtf898bXqVaVQz+XlH3sFvlUn8jPh904YXhpaniInK4iLKF
         YEyA==
X-Google-Smtp-Source: APXvYqx+vlSRtb8++KxN6l3lI5xV7xySoJM2J9G54cgNHJ9R2fIXItQ5mVlTjT+IFK4RmuL4qyjo9+PWSQkFxsipuHY=
X-Received: by 2002:a25:d658:: with SMTP id n85mr19270594ybg.172.1562782840404;
 Wed, 10 Jul 2019 11:20:40 -0700 (PDT)
MIME-Version: 1.0
References: <20190605100630.13293-1-teawaterz@linux.alibaba.com>
In-Reply-To: <20190605100630.13293-1-teawaterz@linux.alibaba.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Wed, 10 Jul 2019 11:20:29 -0700
Message-ID: <CALvZod45JPt_89GRzpWyuxSJHtNQSiweR2-dh+hpbTBi1EbPWw@mail.gmail.com>
Subject: Re: [PATCH V3 1/2] zpool: Add malloc_support_movable to zpool_driver
To: Hui Zhu <teawaterz@linux.alibaba.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Dan Streetman <ddstreet@ieee.org>, Minchan Kim <minchan@kernel.org>, ngupta@vflare.org, 
	sergey.senozhatsky.work@gmail.com, Seth Jennings <sjenning@redhat.com>, 
	Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Cc: akpm@linux-foundation.org

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

I was wondering why this patch is not picked up by Andrew yet. You
forgot to CC Andrew.

Andrew, the thread starts at:

http://lkml.kernel.org/r/20190605100630.13293-1-teawaterz@linux.alibaba.com

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

