Return-Path: <SRS0=8Dof=TA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BD581C43219
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 21:57:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6D31E2087B
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 21:57:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="ApRLQsRW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6D31E2087B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0AA086B0003; Tue, 30 Apr 2019 17:57:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 033956B0005; Tue, 30 Apr 2019 17:57:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E637A6B0006; Tue, 30 Apr 2019 17:57:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f197.google.com (mail-vk1-f197.google.com [209.85.221.197])
	by kanga.kvack.org (Postfix) with ESMTP id BEA456B0003
	for <linux-mm@kvack.org>; Tue, 30 Apr 2019 17:57:50 -0400 (EDT)
Received: by mail-vk1-f197.google.com with SMTP id s139so3158067vkf.2
        for <linux-mm@kvack.org>; Tue, 30 Apr 2019 14:57:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=nrmJg5mJkdOB4HxRtlUftJxszIDcsroWGgIpxMUexwY=;
        b=cK3RC0g8MzbCVtLVQ352aox723yz61JgwLxs/kXP9ktkEvoy+xO6mP8FRLJZ7geoDZ
         lcRdFFkOwFk93R1p0qo2eQPSQObgm5N9nXEUM+zZ6gAHNGIYF6MAgM9tToNX8gZ1tLwD
         IIGV++dq8dzDxgedvLbaTvFwhGGi90RxXvtAJt1fShLIvWvfxOsQqc+WqzknwKfdNQdp
         l1rAvpTLjKhEmbXN3x2CyMAGrAyR1OwOjW4sFF3ly+P8Tt8R4TISEIXYVpFUuD5j8AhZ
         KRjwdo5tzgSqGcHj97ukVt2myn8/CQpWbtXr5Aj6AbCK7egddH4PsJGMyhkcFDnB30io
         ZhOA==
X-Gm-Message-State: APjAAAXR76x7rxWnzlJY7FjSwSk4LTkj/YziDKSiN4GwgioU/jxRLnZg
	X/kvgqtR+UyOpxDoHe4xkE/n9TBug07bxkgYIbouTDZSWokjYVhsRMuBMYCM481dY9T2deFegMt
	wmPOphWD951xaAek4LkKKfYbmZ6rfDe1ZHPq76jKFBIfYW+YxuuMp3wIRcs/nmhKo+w==
X-Received: by 2002:a1f:9991:: with SMTP id b139mr36572809vke.73.1556661470505;
        Tue, 30 Apr 2019 14:57:50 -0700 (PDT)
X-Received: by 2002:a1f:9991:: with SMTP id b139mr36572781vke.73.1556661469782;
        Tue, 30 Apr 2019 14:57:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556661469; cv=none;
        d=google.com; s=arc-20160816;
        b=XOtcjDs8xB3wOG/suaa/D3iSs97QhnJzR+aJtaCxldw19qZEycbwhG2c1nRc4nTzBD
         0RAF7wO7q4qhbQ/YP7mKc08C7d7ZOvVEH6G2ndRxi2NuVlI4jkoNJbFr+bHZYjwVAv44
         Szg8LfZjuMCXX5R02PZhRJZQ+8aNQDQZmNfU2kKosz2+X2aT5+pWbkjX2uxoYufS3MgG
         hLe/V4EPlXThGLzrKvMtuIvEAWqfTE4+t6gxtPv1QewmBt05c98782pMNPDdfwc65iyr
         IlMAnXTVpu43JI98oUolTLU0KThuDLV68AgfaAZUcyLXUBFACpSKw5fo5+Kr1CSSZ4Bv
         eOqQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=nrmJg5mJkdOB4HxRtlUftJxszIDcsroWGgIpxMUexwY=;
        b=G1f9QM9/02KnrOSm3J5ZRFtz3Dz1whmXDd7xPFpMqdaWAEcL1tnS/QLIk4fk5JdTj2
         fD24rXcWf1BgUonc7HDUJe4/XCxpgAEwTRqqeDdRvny4ZfXkiyxpw6Zen5JeXAyhLP3D
         TgwSYKQm3iBwFzXUtOCOTMgafVvcEPmlm5GS+xn5nDuFQcyeM1urFkmtslJnyGu3Tbgc
         LitrX9lJJklyZaoy8USJAXjwN8eRgKWwCX/TRWfSSzaJ7BS07921IbstJFH2VzsVXaDU
         DhSWhZtqc5IOh3WXlbI2FhKy281OUcnIXLPpK5G5eC07mwVulkCs43Im4T+IORN5NGj9
         3tQw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=ApRLQsRW;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b136sor12087556vke.41.2019.04.30.14.57.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 30 Apr 2019 14:57:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=ApRLQsRW;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=nrmJg5mJkdOB4HxRtlUftJxszIDcsroWGgIpxMUexwY=;
        b=ApRLQsRWLYDRB1zjywf8XpfE+dW75Bh0LDN3wBrHZvQM/bXYOhCwOGGI+1zXg59ILI
         0gnOtO2l5+pHTLyDMucFKFf69zIPwLIGs+etrKYFG0DV7GFQX3Amh06repKBlVkPOxCo
         nTYhV1brRDRIvMaLpnT8uySSjAIWhQTwI1dTs=
X-Google-Smtp-Source: APXvYqyViyXQpV4aqdDVq0y6/FpzewdwjjuFAh5WK2/t5RwnyR0F260cWZ2T2GKrFF0dJmmY+jDEmg==
X-Received: by 2002:a1f:a989:: with SMTP id s131mr2809501vke.76.1556661468754;
        Tue, 30 Apr 2019 14:57:48 -0700 (PDT)
Received: from mail-ua1-f46.google.com (mail-ua1-f46.google.com. [209.85.222.46])
        by smtp.gmail.com with ESMTPSA id s16sm5059889vks.39.2019.04.30.14.57.47
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Apr 2019 14:57:47 -0700 (PDT)
Received: by mail-ua1-f46.google.com with SMTP id l17so5321638uar.4
        for <linux-mm@kvack.org>; Tue, 30 Apr 2019 14:57:47 -0700 (PDT)
X-Received: by 2002:ab0:1646:: with SMTP id l6mr35938169uae.75.1556661467134;
 Tue, 30 Apr 2019 14:57:47 -0700 (PDT)
MIME-Version: 1.0
References: <20190430214724.66699-1-samitolvanen@google.com>
In-Reply-To: <20190430214724.66699-1-samitolvanen@google.com>
From: Kees Cook <keescook@chromium.org>
Date: Tue, 30 Apr 2019 14:57:35 -0700
X-Gmail-Original-Message-ID: <CAGXu5jLfLsiKJurVL_+zr5t6D1B6OMw2hPo5WZSjUhv1-4AONg@mail.gmail.com>
Message-ID: <CAGXu5jLfLsiKJurVL_+zr5t6D1B6OMw2hPo5WZSjUhv1-4AONg@mail.gmail.com>
Subject: Re: [PATCH] mm: fix filler_t callback type mismatch with readpage
To: Sami Tolvanen <samitolvanen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, 
	Nick Desaulniers <ndesaulniers@google.com>, LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 30, 2019 at 2:47 PM Sami Tolvanen <samitolvanen@google.com> wrote:
>
> Casting mapping->a_ops->readpage to filler_t causes an indirect call
> type mismatch with Control-Flow Integrity checking. This change fixes
> the mismatch in read_cache_page_gfp and read_mapping_page by adding a
> stub callback function with the correct type.
>
> As the kernel only has a couple of instances of read_cache_page(s)
> being called with a callback function that doesn't accept struct file*
> as the first parameter, Android kernels have previously fixed this by
> changing filler_t to int (*filler_t)(struct file *, struct page *):
>
>   https://android-review.googlesource.com/c/kernel/common/+/671260
>
> While this approach did fix most of the issues, the few remaining
> cases where unrelated private data are passed to the callback become
> rather awkward. Keeping filler_t unchanged and using a stub function
> for readpage instead solves this problem.
>
> Cc: Kees Cook <keescook@chromium.org>
> Signed-off-by: Sami Tolvanen <samitolvanen@google.com>

Reviewed-by: Kees Cook <keescook@chromium.org>

-Kees

> ---
>  include/linux/pagemap.h | 22 +++++++++++++++++++---
>  mm/filemap.c            |  7 +++++--
>  2 files changed, 24 insertions(+), 5 deletions(-)
>
> diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
> index bcf909d0de5f8..e5652a5ba1584 100644
> --- a/include/linux/pagemap.h
> +++ b/include/linux/pagemap.h
> @@ -383,11 +383,27 @@ extern struct page * read_cache_page_gfp(struct address_space *mapping,
>  extern int read_cache_pages(struct address_space *mapping,
>                 struct list_head *pages, filler_t *filler, void *data);
>
> +struct file_filler_data {
> +       int (*filler)(struct file *, struct page *);
> +       struct file *filp;
> +};
> +
> +static inline int __file_filler(void *data, struct page *page)
> +{
> +       struct file_filler_data *ffd = (struct file_filler_data *)data;
> +
> +       return ffd->filler(ffd->filp, page);
> +}
> +
>  static inline struct page *read_mapping_page(struct address_space *mapping,
> -                               pgoff_t index, void *data)
> +                               pgoff_t index, struct file *filp)
>  {
> -       filler_t *filler = (filler_t *)mapping->a_ops->readpage;
> -       return read_cache_page(mapping, index, filler, data);
> +       struct file_filler_data data = {
> +               .filler = mapping->a_ops->readpage,
> +               .filp   = filp
> +       };
> +
> +       return read_cache_page(mapping, index, __file_filler, &data);
>  }
>
>  /*
> diff --git a/mm/filemap.c b/mm/filemap.c
> index d78f577baef2a..6cc41c25ca3bf 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -2977,9 +2977,12 @@ struct page *read_cache_page_gfp(struct address_space *mapping,
>                                 pgoff_t index,
>                                 gfp_t gfp)
>  {
> -       filler_t *filler = (filler_t *)mapping->a_ops->readpage;
> +       struct file_filler_data data = {
> +               .filler = mapping->a_ops->readpage,
> +               .filp   = NULL
> +       };
>
> -       return do_read_cache_page(mapping, index, filler, NULL, gfp);
> +       return do_read_cache_page(mapping, index, __file_filler, &data, gfp);
>  }
>  EXPORT_SYMBOL(read_cache_page_gfp);
>
> --
> 2.21.0.593.g511ec345e18-goog
>


-- 
Kees Cook

