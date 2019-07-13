Return-Path: <SRS0=cxLU=VK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7AA81C742A7
	for <linux-mm@archiver.kernel.org>; Sat, 13 Jul 2019 16:05:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1344720830
	for <linux-mm@archiver.kernel.org>; Sat, 13 Jul 2019 16:05:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="Ke7ejz/m"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1344720830
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 709CC6B0003; Sat, 13 Jul 2019 12:05:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6B9A98E0003; Sat, 13 Jul 2019 12:05:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5D3228E0002; Sat, 13 Jul 2019 12:05:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id 391B66B0003
	for <linux-mm@kvack.org>; Sat, 13 Jul 2019 12:05:40 -0400 (EDT)
Received: by mail-yb1-f198.google.com with SMTP id u9so10724568ybb.14
        for <linux-mm@kvack.org>; Sat, 13 Jul 2019 09:05:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=7mk75n+FUSNUhfgNLft7JljlbXBUa7UOYFFMLEx7Ozk=;
        b=h/F0rpVOHTXETfJdzY5v1csPBwS4FNxIqBTDZxF6h+y1B8RAnqJVn37+3hIWFtrnGp
         7Okp+T3Ols+r9wyjJph2sUGu36Dn6LHbmCDs2/4hBVwGZmYMvf6AWLJSozxiI9aOtbvQ
         O2iWV+lE9bn0mo7I61wMOM1aJ4Zb7ZzX85ob4OxVZ1ySbgWmwQ3rjk3GX9h9f9CpXlIq
         WrxuhyIAyGHVtJC/YjBFeqaPb5cUN+9V12Sc/BFzotBgEcOwU56iOlOA3MMKSLGEhiGX
         eAy+UbhQdDfGUxkm+5kdTSKJu63uLz9p3Kk3QIWemkOPwFxV9CnCwh+RaoHeH0sFi5Ob
         tIfA==
X-Gm-Message-State: APjAAAXT+0cBZnep3tqdqnsXNYnIY9YPKc+kljNkp5FXINukfDUVdmJR
	3al1a4fDEckAg59MWHdiYhTJYhaDe5WVQEmPucDa29XwjRM+edjVJXcu52ABZzn0Tbu7nLQaPgP
	kME9fIA7VoY8k7hYDUl+6VH0Qyk4l3mfFyP6d6rf8EDr+z3gW1O/qQUPEXWataAY3GA==
X-Received: by 2002:a5b:491:: with SMTP id n17mr10014146ybp.30.1563033939939;
        Sat, 13 Jul 2019 09:05:39 -0700 (PDT)
X-Received: by 2002:a5b:491:: with SMTP id n17mr10014116ybp.30.1563033939365;
        Sat, 13 Jul 2019 09:05:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563033939; cv=none;
        d=google.com; s=arc-20160816;
        b=QwO1erP+wvOoMEnSrTGdzhZ75chLEOq53uP9DOcN4QGyUKDtZgoQzRXjPaF4SlCOTw
         HT13JxYZfUZCk0qVD8hmg7D9r151pbmsjBgP3FtjfR8dw0FjYNAoPmBi0oaiU7/ePJ+4
         kaEqM9iGXQR7QmrWDw1OLc/TGlzr4MLSLEvg6yQIZiSfRG9cZEEPwXQk8t40rvw5KTI/
         0m8HUUeqUol4hnYynvRdeKeGWRnQ/1kPsEtgXSrMMzwsleUiU5nq+KIHON6/io5KIpQd
         st8ivoklitHhOuYN2qmBzLO7hZxL2z2epB9JVIa7QxHqK7RVmT8Toy5x+0HyrCqvnFj4
         Zjhg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=7mk75n+FUSNUhfgNLft7JljlbXBUa7UOYFFMLEx7Ozk=;
        b=gYFhGevjoqiX06ZGNhy+uDORFqEZFlQgCWyfoEtwD21FCrYMZu33DQSjUjXGkQl82L
         5cbgkNOGO30oJo6sOHMtfmBFiXgc+ErgVzQHNlCO6rpHFdJh7iF9CUcp81de11Ra99y8
         VcVEvdN1yAZMKpl6uHKxI03zsJ6RNu396w8GjhCkGq/VvJF9MnI+pCdBbnn0tDJ24iap
         Xo7jccX7OZYYOt9jQUaKKmMwijiNqASjKyviJQiHUSdHtMIpuNVf+5innc+5FXC3hgj5
         ZRkQJcAozGHhNln+cl2YjjbgTqslBACZtTc8zG+pR0TTfWiX44BLbCGWQol9ktRE0r8e
         R/yQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="Ke7ejz/m";
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n130sor6863442ywd.196.2019.07.13.09.05.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 13 Jul 2019 09:05:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="Ke7ejz/m";
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=7mk75n+FUSNUhfgNLft7JljlbXBUa7UOYFFMLEx7Ozk=;
        b=Ke7ejz/mT3GEgJN7v5rXdKwDCBjN3gI3AqIh2t3dAPhMi1tnB4DK9+xAh2bGEj87DO
         rxxRS3AJMRuw4LR41VnOligTxXk/T19Ijnvu09+BkEHY1n5xCxJvKJfzDH0BgVXcNZ6T
         mzcNez1i5WrwxW/9eeJgRRwyin8scGj1bIXKiZKcWXCKnld5Tqu37+Fs7ygYRKgHCoBf
         WZXUTvuYWLyojeuWyB4UpfZHfYEEiy7m2bFzcJh8VYB5MRdRpBhWqJcZqI8mvEwo4F2A
         ajjjKT58t0Mcrl6hEkZiWAnhtZoCuwscYs4FkPqbHOhSgFEB3O4Tyv6TlNA+7ewxGb0f
         RzWA==
X-Google-Smtp-Source: APXvYqxMlQFJR0h8Qeriyc5l0gq+QA9nZ7IroV8xzvAcGnoKo6g6GsAEfb1wbrBSXDFB1s2MHWcP5eHRiALUf/y1g14=
X-Received: by 2002:a0d:c345:: with SMTP id f66mr9597066ywd.10.1563033938757;
 Sat, 13 Jul 2019 09:05:38 -0700 (PDT)
MIME-Version: 1.0
References: <20190712222118.108192-1-henryburns@google.com>
In-Reply-To: <20190712222118.108192-1-henryburns@google.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Sat, 13 Jul 2019 09:05:27 -0700
Message-ID: <CALvZod68Ktd3m7p4MFgLdpqku3UucwEGrTVHdMPgi4cOpUOk6A@mail.gmail.com>
Subject: Re: [PATCH] mm/z3fold.c: Allow __GFP_HIGHMEM in z3fold_alloc
To: Henry Burns <henryburns@google.com>
Cc: Vitaly Wool <vitalywool@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Vitaly Vul <vitaly.vul@sony.com>, Jonathan Adams <jwadams@google.com>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Snild Dolkow <snild@sony.com>, 
	Thomas Gleixner <tglx@linutronix.de>, Linux MM <linux-mm@kvack.org>, 
	LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jul 12, 2019 at 3:22 PM Henry Burns <henryburns@google.com> wrote:
>
> One of the gfp flags used to show that a page is movable is
> __GFP_HIGHMEM.  Currently z3fold_alloc() fails when __GFP_HIGHMEM is
> passed.  Now that z3fold pages are movable, we allow __GFP_HIGHMEM. We
> strip the movability related flags from the call to kmem_cache_alloc()
> for our slots since it is a kernel allocation.
>
> Signed-off-by: Henry Burns <henryburns@google.com>

Reviewed-by: Shakeel Butt <shakeelb@google.com>

> ---
>  mm/z3fold.c | 5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
>
> diff --git a/mm/z3fold.c b/mm/z3fold.c
> index e78f95284d7c..cb567ddf051c 100644
> --- a/mm/z3fold.c
> +++ b/mm/z3fold.c
> @@ -193,7 +193,8 @@ static inline struct z3fold_buddy_slots *alloc_slots(struct z3fold_pool *pool,
>                                                         gfp_t gfp)
>  {
>         struct z3fold_buddy_slots *slots = kmem_cache_alloc(pool->c_handle,
> -                                                           gfp);
> +                                                           (gfp & ~(__GFP_HIGHMEM
> +                                                                  | __GFP_MOVABLE)));
>
>         if (slots) {
>                 memset(slots->slot, 0, sizeof(slots->slot));
> @@ -844,7 +845,7 @@ static int z3fold_alloc(struct z3fold_pool *pool, size_t size, gfp_t gfp,
>         enum buddy bud;
>         bool can_sleep = gfpflags_allow_blocking(gfp);
>
> -       if (!size || (gfp & __GFP_HIGHMEM))
> +       if (!size)
>                 return -EINVAL;
>
>         if (size > PAGE_SIZE)
> --
> 2.22.0.510.g264f2c817a-goog
>

