Return-Path: <SRS0=eSYi=V6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CC204C433FF
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 14:58:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 742E92087C
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 14:58:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="WwXCd/VQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 742E92087C
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 062906B000A; Fri,  2 Aug 2019 10:58:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F2DAA6B000D; Fri,  2 Aug 2019 10:58:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DCDA76B000E; Fri,  2 Aug 2019 10:58:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id B7A4F6B000A
	for <linux-mm@kvack.org>; Fri,  2 Aug 2019 10:58:12 -0400 (EDT)
Received: by mail-yw1-f70.google.com with SMTP id k21so55822951ywk.2
        for <linux-mm@kvack.org>; Fri, 02 Aug 2019 07:58:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=2t7kh32IlRdOx8sjdsjf2HQN2zHlz2OSPNUjrRGAcBA=;
        b=DOi+2t9AZSNJUhnwN3FZv/hxUOJs3lqK7biQg3mb0vGf+4CsnGMyrCGdk6/96dyTit
         2eb11Kp9Ix9nUQ769vMEm2kXq0iCOJPLcihtsU3+ndjyKGX16uI+ntx8p6X8jYyddrgY
         uWRQbTadVjc8WwRd7E0eUnnRI13PyDFzX9tNbH6ZaZmo0cyAhuA/vMQz0kZRZx3DZ9xY
         Lfe6w7R999Mf6565rGlfj1j7irqLLuvqzJd3vcQi7CytoQ75l8FfhW0Jx0G1hVeBojTg
         cwPfqOm5MqjMrx5rcb3UzgdLWoSzVZY3cy2Cuy9KDh6F51kw+/xizQInamrrSr14TmGx
         cseA==
X-Gm-Message-State: APjAAAV8y1Ps0ne8H1mxaeP3SuPposCFwGYo6558Mu2CfmhI7LPDea1P
	RJ2ZOyBVbprGzrY4IpiBTkdgtf4k/+bKkuEPzoAYJv7ryA72eLC5+bZifqOqdNKpbvyCWDDCLIb
	kHxEbUin+ZPnDvNbkuo8yE7wIwVlvoIrBNhrsthNksPkaJk4F3tH3ooPzFQtFNIOeYQ==
X-Received: by 2002:a25:598a:: with SMTP id n132mr82864014ybb.31.1564757892387;
        Fri, 02 Aug 2019 07:58:12 -0700 (PDT)
X-Received: by 2002:a25:598a:: with SMTP id n132mr82863993ybb.31.1564757891799;
        Fri, 02 Aug 2019 07:58:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564757891; cv=none;
        d=google.com; s=arc-20160816;
        b=nIA8XLg+LtROgYYBocfh4i9nFHAOhnGLfw1zX7VmNzpPJWSS1FBCYJlf1/nRDt+ddB
         bK1/aONyaQC/LtGNGQpGaNZNMp2uE4y9IIc6XvSCaQwIvtMaF6+QhK8nGl0Nlt2PKJ4D
         JmrIg7asuTee+4WL+uPHusjNSmNFgLRIsZZsDu8X6OU+Yljzi0J2jGlkZjsH9gH4rI9t
         yKs8pPH3Rb1IkWxWLjJETbF08dbrKD1KI8EZ812DXhgsqmlmvIbjjoD3Li84PULkRrsp
         36taX3k8m75Jfl3yGV33fj+5q2ITjZRaTtok3qkaS7QapNoac536FDd1kHbW65090UAu
         /SNA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=2t7kh32IlRdOx8sjdsjf2HQN2zHlz2OSPNUjrRGAcBA=;
        b=auQPYyXiLstKQ68NreAbqem+NSzJTCqlqNp0XRRtcI+raMV047JV+8fY4TvKA4XEb0
         3sXRhzjGPS9+0tamj14XIJxb7ZAaHyYTVuzquflH1oW7ixR7NJWS1v5VCZkaIHWsmP0H
         0arNxG6VrKowDinwe82ALUC2360uAXuLqCQIzHY0jj3AXN9ruXBbkiLD26gX8OKtBN45
         GxvBSPRgHqwOWA5pUYGD9D5lnD2ZXkLCKaT+FrlgPaNd98t7CsdxABM0XsChugxYwKi0
         GmDlDnma8M5cP9lykFJyks5BqOwIGdfGRjP50s1Ba4rSzYw+M7KaDzGOvs8ieyC1aiW4
         1SLA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="WwXCd/VQ";
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a8sor28853981ywh.64.2019.08.02.07.58.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 02 Aug 2019 07:58:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="WwXCd/VQ";
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=2t7kh32IlRdOx8sjdsjf2HQN2zHlz2OSPNUjrRGAcBA=;
        b=WwXCd/VQmyFg2yNmEMZgERJNaq7Y0Jobb+bFuDYPe2UfvjZBD9TSI62E4neWS7QEZT
         uHq9yMdYv3Z46RbWESTbN/WX90CrDR2Z5UpoDui5TtKW3MpOXr6BtwNKRVyV4OYPaMSR
         F8CDJ4IAWxZL9IDpZfdjsR2BexcPo3ebtA1e3dBhwimbwjtA5Buf0lmpFvIZb9QiglrY
         qMP2bv7tUizrHHhoJtnoXHnVxyd+j7ET7QCuCSv5fJv/LRzQc8LZto4amVBv5yiVfEAw
         Y3Vutaofi3fQpY79BtKP+tCuu6oFNAZ6Ewww+xwheDvMI+VfBoFlv6KYUZ178XFqRlCC
         YctA==
X-Google-Smtp-Source: APXvYqziJBGMCJKD3omPwQE75QPtI6KDdt2k628cv9E1FLN7w8SIXTvJSwkub5MihjDofyGVsiLOfAZqkBTnN49l58U=
X-Received: by 2002:a81:ae0e:: with SMTP id m14mr86597121ywh.308.1564757891251;
 Fri, 02 Aug 2019 07:58:11 -0700 (PDT)
MIME-Version: 1.0
References: <20190802015332.229322-1-henryburns@google.com>
In-Reply-To: <20190802015332.229322-1-henryburns@google.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Fri, 2 Aug 2019 07:58:00 -0700
Message-ID: <CALvZod414sVwwKg0KAsHC2vhqdkrzLeQ+nV3wiAKvOoFyu8NAQ@mail.gmail.com>
Subject: Re: [PATCH 1/2] mm/zsmalloc.c: Migration can leave pages in ZS_EMPTY indefinitely
To: Henry Burns <henryburns@google.com>
Cc: Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, 
	Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Jonathan Adams <jwadams@google.com>, 
	Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 1, 2019 at 6:53 PM Henry Burns <henryburns@google.com> wrote:
>
> In zs_page_migrate() we call putback_zspage() after we have finished
> migrating all pages in this zspage. However, the return value is ignored.
> If a zs_free() races in between zs_page_isolate() and zs_page_migrate(),
> freeing the last object in the zspage, putback_zspage() will leave the page
> in ZS_EMPTY for potentially an unbounded amount of time.
>
> To fix this, we need to do the same thing as zs_page_putback() does:
> schedule free_work to occur.  To avoid duplicated code, move the
> sequence to a new putback_zspage_deferred() function which both
> zs_page_migrate() and zs_page_putback() call.
>
> Signed-off-by: Henry Burns <henryburns@google.com>

Reviewed-by: Shakeel Butt <shakeelb@google.com>

> ---
>  mm/zsmalloc.c | 30 ++++++++++++++++++++----------
>  1 file changed, 20 insertions(+), 10 deletions(-)
>
> diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> index 1cda3fe0c2d9..efa660a87787 100644
> --- a/mm/zsmalloc.c
> +++ b/mm/zsmalloc.c
> @@ -1901,6 +1901,22 @@ static void dec_zspage_isolation(struct zspage *zspage)
>         zspage->isolated--;
>  }
>
> +static void putback_zspage_deferred(struct zs_pool *pool,
> +                                   struct size_class *class,
> +                                   struct zspage *zspage)
> +{
> +       enum fullness_group fg;
> +
> +       fg = putback_zspage(class, zspage);
> +       /*
> +        * Due to page_lock, we cannot free zspage immediately
> +        * so let's defer.
> +        */
> +       if (fg == ZS_EMPTY)
> +               schedule_work(&pool->free_work);
> +
> +}
> +
>  static void replace_sub_page(struct size_class *class, struct zspage *zspage,
>                                 struct page *newpage, struct page *oldpage)
>  {
> @@ -2070,7 +2086,7 @@ static int zs_page_migrate(struct address_space *mapping, struct page *newpage,
>          * the list if @page is final isolated subpage in the zspage.
>          */
>         if (!is_zspage_isolated(zspage))
> -               putback_zspage(class, zspage);
> +               putback_zspage_deferred(pool, class, zspage);
>
>         reset_page(page);
>         put_page(page);
> @@ -2115,15 +2131,9 @@ static void zs_page_putback(struct page *page)
>
>         spin_lock(&class->lock);
>         dec_zspage_isolation(zspage);
> -       if (!is_zspage_isolated(zspage)) {
> -               fg = putback_zspage(class, zspage);
> -               /*
> -                * Due to page_lock, we cannot free zspage immediately
> -                * so let's defer.
> -                */
> -               if (fg == ZS_EMPTY)
> -                       schedule_work(&pool->free_work);
> -       }
> +       if (!is_zspage_isolated(zspage))
> +               putback_zspage_deferred(pool, class, zspage);
> +
>         spin_unlock(&class->lock);
>  }
>
> --
> 2.22.0.770.g0f2c4a37fd-goog
>

