Return-Path: <SRS0=eSYi=V6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 12D86C433FF
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 15:10:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BDC062173E
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 15:10:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="TCfHoybp"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BDC062173E
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 625976B000E; Fri,  2 Aug 2019 11:10:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5D5DD6B0010; Fri,  2 Aug 2019 11:10:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4C5E16B0266; Fri,  2 Aug 2019 11:10:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2D3B16B000E
	for <linux-mm@kvack.org>; Fri,  2 Aug 2019 11:10:18 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id l16so61452966qtq.16
        for <linux-mm@kvack.org>; Fri, 02 Aug 2019 08:10:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=sX2PNnPqRc1Vez9Gt0ymgNUdMb/B4mN+i8ZPfiL6UFc=;
        b=O3cFYJHTJi+whWo8ovw0OHD03PQrSWhYAdxEI4ubu5Mls78MSheBHnX2bZQhoeLZjt
         xUTccwmvFJ0s1zgyXweddwJADekhxTgvvg5KDlFeuHkKYBU35d+rcXnLREt5tCp0N/S0
         EdH0sLAYwecblGdYqerJjppHXfr86pHgVoRIlONxu/HJ0DMgEBmgkNlFPPq8wVdKW1VG
         pJnwl0BsK2SO+N8OxtUtTX2HmM9/POTeW7aQ8mp/6Z+xIITfzogQ5y1uicafhS1XPC51
         s/b0QchVtypRQEE40KkDOiBMUVpdAH1GfZ3bldwweyMMDVTPdDNrUJnAVzft77Wr9zDk
         OP4A==
X-Gm-Message-State: APjAAAV6XQRbjoDdCpWDQ3kIofOXC1y46IECYVBPLwuoQpv0+cm2GBP+
	QBTTkJsk8mRa77pG0OlPBiyZ/4sKdooPm2720MxJ7JAJGq/lFCAWbxJ2ujfzcRB76tyYAkb56Gt
	OZOOGOOYKDI/ZQezIuVVsyaAkGktv4ATRizolVx0uxsyWf8hFeusxAYcM9kPOWOxdWw==
X-Received: by 2002:a05:620a:1181:: with SMTP id b1mr94520715qkk.390.1564758617969;
        Fri, 02 Aug 2019 08:10:17 -0700 (PDT)
X-Received: by 2002:a05:620a:1181:: with SMTP id b1mr94520650qkk.390.1564758617312;
        Fri, 02 Aug 2019 08:10:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564758617; cv=none;
        d=google.com; s=arc-20160816;
        b=cNyi3zyC/ipbhwKnQLCXUZc068xbVMyU/bmoDb+9mYYwMAztPAxkH34WtlM8IqE0gN
         ky+QlfzfApIPPc/so0kApB9c/LCdCQ5qzDXNj5FoUe+g3wGmhDZsSt8VbY7YrwVi+Exm
         x0YY3A6H+ChmLAPwBo2WKrPxL/xVGad4jFszW/XW4CgA/+PnW9V8eshSEyX31aCQ54rb
         4SdRJRknJgxH/1TP/MTdCr80iYJ6XqQbV8lGGEVzrxHMeiRlwJ3AS5mZU6Ms+sCqmXc7
         V+lQCS7PKI06gvny37m0v0FHogjH6493XF4l/9eaGTox+KeejUlPUML2TEoN3TFds0S3
         bw3g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=sX2PNnPqRc1Vez9Gt0ymgNUdMb/B4mN+i8ZPfiL6UFc=;
        b=PBdr6W3sASIm+Uua3z/7MZsbx+JCJzT5anIah9NUU6ruxcL27B5v4TK10zYYX6c52c
         0ZoS6tGDGlfefAOfepT3VJcdRsbWqiOF3ewMNgDJNRJqeocZa99JeoMQYpihDGt/Q/jB
         KTGLM4rTBI/ox+iwhC4vUHhe6WQz6Hpr87tUxevilY2/SiYWQXHTcfeYGwpg82+DbrTL
         heQRIKY2HRMrsMR3OSY/XyUOTe9MUrLQ+5YuOcWlXtvAnit54Z4mdjPOHrKeV5H4mZPN
         yT2a7xSSj71WorsMcfLDwtR7oG7bxUGqgTMMi2fl226x2zM2RVHQE9oN688V4OIWdqGX
         jqVw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=TCfHoybp;
       spf=pass (google.com: domain of jwadams@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jwadams@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 8sor63086850qvi.5.2019.08.02.08.10.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 02 Aug 2019 08:10:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of jwadams@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=TCfHoybp;
       spf=pass (google.com: domain of jwadams@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jwadams@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=sX2PNnPqRc1Vez9Gt0ymgNUdMb/B4mN+i8ZPfiL6UFc=;
        b=TCfHoybpUYB0q57sGjslZY0Qzg2W5zqXK9GXEpT81w3xFylA5VAxbe7I2hDdBlAkOw
         vZQBSCELRIJW8I77+ptRAHLm9EnjBBqrgcnn2911JFtYKIFpJMbyRxF4xP7jQfNzmuA4
         Wl9Q2wfvPCIH2gL2kkaYx8aYF4kei6qLWvNFf0AJDgFtg5Utrhy7/oEPxz6cOpsjNb1G
         EPwdTu28JLG2EBx43Wln3+visWVuhE91Z/GQIQwQpHwKFxwy9BpHrECtjw+hKG/UNaiP
         FWMaVNBX9O2PAF7dPK4iEFIIilBFVP5mSpEwbINmhLQep6ln3P9Tn3TJjNohzzr7uDtB
         kN8w==
X-Google-Smtp-Source: APXvYqzD/POmLm2vKfx6D1RC+luKxBQ/NjM0j2hWAxzv3R2JplpeeTrEROmYPNGnrMsBM/LkS1BimmH9BbnLMwr4jBw=
X-Received: by 2002:a0c:b755:: with SMTP id q21mr95331996qve.92.1564758612071;
 Fri, 02 Aug 2019 08:10:12 -0700 (PDT)
MIME-Version: 1.0
References: <20190802015332.229322-1-henryburns@google.com>
In-Reply-To: <20190802015332.229322-1-henryburns@google.com>
From: Jonathan Adams <jwadams@google.com>
Date: Fri, 2 Aug 2019 08:09:35 -0700
Message-ID: <CA+VK+GN1hx1jh81JAKtL9L20L=014L-m3N3HtsDYa1ZqbMR0Cg@mail.gmail.com>
Subject: Re: [PATCH 1/2] mm/zsmalloc.c: Migration can leave pages in ZS_EMPTY indefinitely
To: Henry Burns <henryburns@google.com>
Cc: Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, 
	Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Shakeel Butt <shakeelb@google.com>, 
	Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000004, version=1.2.4
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

Reviewed-by: Jonathan Adams <jwadams@google.com>
>
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

