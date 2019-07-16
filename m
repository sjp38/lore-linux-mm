Return-Path: <SRS0=rp0W=VN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EDEDCC7618F
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 21:20:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B17862173E
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 21:20:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="mzkioEkQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B17862173E
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2761D6B0003; Tue, 16 Jul 2019 17:20:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 228C86B0005; Tue, 16 Jul 2019 17:20:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 116F58E0001; Tue, 16 Jul 2019 17:20:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id E57956B0003
	for <linux-mm@kvack.org>; Tue, 16 Jul 2019 17:20:41 -0400 (EDT)
Received: by mail-yw1-f72.google.com with SMTP id h203so17157727ywb.9
        for <linux-mm@kvack.org>; Tue, 16 Jul 2019 14:20:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=JJ9YJBDa6TAoDZnqGKrJ33E8HHSw9cbft8xMZfhrH5o=;
        b=AlfJwLnha0YHM4JJtggRisVXwPlcSS9xfxM7Dx90bZTsQH6FYrN5D/V7zTlj+wOxG1
         Luja5y8S3HR5atEXydSU9hQu1siO5cYkbufAwntv4wHjHSSi+Zn2fyy/RM6kEUBYNQGF
         rREnXpU9LtXPojH+r72DaQDQI9GAiNLUueUr72xJOPNymeU2iVv9BaOzQyJC1U74i9Oj
         ba99ihwXJ3WjKlVc7i8kqV3O0+1jMx5fw88hT/PTtNfI8pE1ZqsQO3P8AciVva17MX/8
         AQT9FjHeyct++77BzgRrxWsad94YnQb9SZkU8gSuYgjngyJ2t47DkoGSDFIvKvmcMZMe
         KNFg==
X-Gm-Message-State: APjAAAWDtowJeMNpuSjAQBIc6f/kXy0LbJ01ypGlQy0gSPq2AZr2mOEf
	8lvU+mZmPW+0P+HJf6FTqPs20S0aQ108tewIO13BvdUOa/sOC4yF4m0XvXpNrN+of8FR+YuKqEr
	ICjOCZmK+Ud0Z4Po0e84FB7++Mq7odfVqZhGBjo7d84WUPD8WKDgJRGC9e9vT3Xkhrg==
X-Received: by 2002:a81:a155:: with SMTP id y82mr20924403ywg.80.1563312041522;
        Tue, 16 Jul 2019 14:20:41 -0700 (PDT)
X-Received: by 2002:a81:a155:: with SMTP id y82mr20924372ywg.80.1563312040935;
        Tue, 16 Jul 2019 14:20:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563312040; cv=none;
        d=google.com; s=arc-20160816;
        b=oY9/w8IFain++iJBj7mpNuibTQZLAQgAXhvAT6HYfR4JB/nY87b2isaSqZHt/IzyWP
         YjueAadqRFy0Q2qIir7TQZAHbFvsB884PKRbinc+x6TgGkXFJlCCpwRBuFuFDvWNacYQ
         jzLFpG2BkwV0smc9teKT9uLYUjhvR9AThEKakIsU5dQdfdrfOu7z34xM7SoNeNFEvo6c
         POfjr7B0EwcMeQcaexRGoLLZwwCAzHnGFwYpFgAswieWOylH5vP4sXtDygkh2seu2orI
         AjKUfMZAGEe9qVHY1kNgUg7A2hqEsK2kvj8yBjRF3Xj3+4SZ3Zlru7aqQYrV/YdEy6Fm
         37Tw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=JJ9YJBDa6TAoDZnqGKrJ33E8HHSw9cbft8xMZfhrH5o=;
        b=LVj/Ddk5v9Hf4bFLIo0tuHnAuX1Pfx6Kz/ZXM25K0vwSuikWpTPKHXz2M+hd+wx9cB
         3ogpZmRip/tc/CuvGfWC4zDXJgCraPZ3tGFt52l4XX3Hwl4WXrLasBJYbvUH8kGtznve
         7kzcJOuv9Z3FHtzm+MedJbLauCXCmk9WW5//7gHEkGSlcNHZUfK1lPWO32VM2L8edYw2
         y0Es9FqBp1BpmdP67FrIQv31gWxQ5MpMecZKmT+mKYNQ+yLndlqrNV++X9moVK8JnxBE
         220qyiz8bEeMStoEYs+zqlPrTTxXrB2iCIVM07F154xiTjp3VNPsTKxz5H7F3ZicETC/
         Huug==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=mzkioEkQ;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a8sor1007372ywh.64.2019.07.16.14.20.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 16 Jul 2019 14:20:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=mzkioEkQ;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=JJ9YJBDa6TAoDZnqGKrJ33E8HHSw9cbft8xMZfhrH5o=;
        b=mzkioEkQusJ5+fSK27pN+Vp0ac4Y/hSwdtz9EBb/CGG+fQfnQpfNVJ4Nrn//Qzq2Sm
         ylEq8N1PhAUCbcJRX7iDYz/lqELXX2RiXjjyA9ljx3qmwq0sONvfWl06a0Mn5ntJGU6S
         HM8qXNVmfSIdYce6w4BJPgEs8i9O3VairrVzwHC66pvik4T4SSVAO2jeohAOuANIq7P5
         cOsnhIMLJ526MbaDy6UjqAUEBr5hfXPe3Pucn/DrRLtbgSOnYK2+TE+ycQrWwf/kwoyM
         viQZLFx2ns8ebYgjZTz5eJCXtIgbh8+iMOJJfoPte0qOVJWIBE8ftoyCOtoXBRrl1p2k
         qiPw==
X-Google-Smtp-Source: APXvYqxIk0Kusbyfed606KNi4eGPzY+cdM8lYWMrMR8rMZ/4PdfezbgsydDu8UR4zXJIqhguZ5+jeBmCzF6RdAVtQ7s=
X-Received: by 2002:a0d:cb42:: with SMTP id n63mr21966936ywd.205.1563312039498;
 Tue, 16 Jul 2019 14:20:39 -0700 (PDT)
MIME-Version: 1.0
References: <20190716000520.230595-1-henryburns@google.com>
In-Reply-To: <20190716000520.230595-1-henryburns@google.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Tue, 16 Jul 2019 14:20:28 -0700
Message-ID: <CALvZod46LCSyCJEuBr_0yLjAbg_fJc+qr9-NNU5mbio8mqM1ag@mail.gmail.com>
Subject: Re: [PATCH v2] mm/z3fold.c: Reinitialize zhdr structs after migration
To: Henry Burns <henryburns@google.com>
Cc: Vitaly Vul <vitaly.vul@sony.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Jonathan Adams <jwadams@google.com>, Linux MM <linux-mm@kvack.org>, 
	LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 15, 2019 at 5:05 PM Henry Burns <henryburns@google.com> wrote:
>
> z3fold_page_migration() calls memcpy(new_zhdr, zhdr, PAGE_SIZE).
> However, zhdr contains fields that can't be directly coppied over (ex:
> list_head, a circular linked list). We only need to initialize the
> linked lists in new_zhdr, as z3fold_isolate_page() already ensures
> that these lists are empty
>
> Additionally it is possible that zhdr->work has been placed in a
> workqueue. In this case we shouldn't migrate the page, as zhdr->work
> references zhdr as opposed to new_zhdr.
>
> Fixes: bba4c5f96ce4 ("mm/z3fold.c: support page migration")
> Signed-off-by: Henry Burns <henryburns@google.com>

Reviewed-by: Shakeel Butt <shakeelb@google.com>

> ---
>  Changelog since v1:
>  - Made comments explicityly refer to new_zhdr->buddy.
>
>  mm/z3fold.c | 10 ++++++++++
>  1 file changed, 10 insertions(+)
>
> diff --git a/mm/z3fold.c b/mm/z3fold.c
> index 42ef9955117c..f4b2283b19a3 100644
> --- a/mm/z3fold.c
> +++ b/mm/z3fold.c
> @@ -1352,12 +1352,22 @@ static int z3fold_page_migrate(struct address_space *mapping, struct page *newpa
>                 z3fold_page_unlock(zhdr);
>                 return -EBUSY;
>         }
> +       if (work_pending(&zhdr->work)) {
> +               z3fold_page_unlock(zhdr);
> +               return -EAGAIN;
> +       }
>         new_zhdr = page_address(newpage);
>         memcpy(new_zhdr, zhdr, PAGE_SIZE);
>         newpage->private = page->private;
>         page->private = 0;
>         z3fold_page_unlock(zhdr);
>         spin_lock_init(&new_zhdr->page_lock);
> +       INIT_WORK(&new_zhdr->work, compact_page_work);
> +       /*
> +        * z3fold_page_isolate() ensures that new_zhdr->buddy is empty,
> +        * so we only have to reinitialize it.
> +        */
> +       INIT_LIST_HEAD(&new_zhdr->buddy);
>         new_mapping = page_mapping(page);
>         __ClearPageMovable(page);
>         ClearPagePrivate(page);
> --
> 2.22.0.510.g264f2c817a-goog
>

