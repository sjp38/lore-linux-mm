Return-Path: <SRS0=T9E7=U7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 22357C06510
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 09:54:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B55A720665
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 09:54:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="KDkySTJN"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B55A720665
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 234078E0005; Tue,  2 Jul 2019 05:54:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1E4958E0003; Tue,  2 Jul 2019 05:54:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0FBB38E0005; Tue,  2 Jul 2019 05:54:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id 99C3B8E0003
	for <linux-mm@kvack.org>; Tue,  2 Jul 2019 05:54:06 -0400 (EDT)
Received: by mail-lj1-f200.google.com with SMTP id e16so3327229lja.23
        for <linux-mm@kvack.org>; Tue, 02 Jul 2019 02:54:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=hjyKVTfGLIvonwBnPeklb1p3eTYs2YkOVqXlW7TXq5I=;
        b=dk0jtO+33ltBYkOI0Rl/en3NQQ7szrD71/7RjyG9eWwAqjHKLLxoRQPgrCihehgjYB
         XWKqPLYz38WJIfPPVPbHHygazOJtBEw2ed+IZToqiExoGITL7Muky45jD7qnIspMZtGC
         VRXgP8lvwgDkYzxESCE5sd1ApLbo369PYf+5xPwbgqLQ59kXW7/DM/IxgmL0SjVm476f
         AWSTjswftXMqwd1lPKsc7TgcNGgOs71TEHkRoUoIL/vN0MPEtnpWQLn8K5uOyU/ybFfD
         lJmv2KBESnw/aIMLY4XruLSXTp0TxoAWE2dwFESYuiZrJR/f1aAluaVLLSEVuSRajumC
         xDIA==
X-Gm-Message-State: APjAAAVphmqjgVsEIP9ayz0npXbJsWPnzKRQyd9wUlgWNGYtlMDLUHGT
	Eg1uKMhvh/3y7ZLSx6oUsMWuUL8e2KXdmB1BjifhrvHGwQmX3EShUJJ8CvJWfo62X4nWjsvcE1u
	Ummhk9tnJ0zGibA/ZDuwYTL67oIJNEn6APuwxalMPq+Wbt3TeSHAr/iioukFV4dIsvw==
X-Received: by 2002:ac2:42c7:: with SMTP id n7mr8658771lfl.65.1562061245754;
        Tue, 02 Jul 2019 02:54:05 -0700 (PDT)
X-Received: by 2002:ac2:42c7:: with SMTP id n7mr8658741lfl.65.1562061244810;
        Tue, 02 Jul 2019 02:54:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562061244; cv=none;
        d=google.com; s=arc-20160816;
        b=hD5MVWCkSDxWUS+js3hSFZUg21EfRUUyeB2XouZ2ufA1qgCsLNC5+J0XHFrlLY+rB6
         wmJGGw2NTuNovCK88XQExiQNWxRV3MAlv1E5MJ8vZx0fkBliPKEXxcfWXBueuJ6lhAcz
         gnokV8uaNAP7PyWZIq9vxocoP8QdzVRDXVriY3fRbGZLGJGszEcSR7GAwQlAXkb0mdkE
         EIvqYODzGZouL9ioys+uLwGTQk9JlPX0K8IUbuBa19fHzh+f0BZCsF3WYyWQHKvkmfzR
         2gxU1+YQGwTW31vNszk9Dgs/hCxHGXOeIG3xRVJsUaHmOFO/TLubWBImz9IgnaWGkIyc
         gHMg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=hjyKVTfGLIvonwBnPeklb1p3eTYs2YkOVqXlW7TXq5I=;
        b=Sjo9CWwpm08MCytTC9CajzPiJUf+yYUCbbzDEO3TxvggVmhnI4Ii51HyhXoFKq2q8U
         Q4qkfsDpJgD+Qrb3ZxH10Iv9VujzOixZcv3Y/o9NJsNTpWlPuN/6uqFGXFMiyt6OU7j1
         xsgAZ8/lxS/t6NAqumbQg/vQWVGKh1nbC1RXXfG01EWDAB3cr8AGmGrqnaHGWjgPTDNC
         YQlNWxTAjFjWM5MO9+89LCOzqXXscH2EZ4rKb3Dp1JC8steWaje/uH7utO4Z9o3n3szR
         +rUKTD3YnJxTA+Y/DBnzO1qTlXyY9FNS76z/ZSiHUIOD03EVGsggjNVuCD9gLBslQA7Y
         dCeg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=KDkySTJN;
       spf=pass (google.com: domain of vitalywool@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=vitalywool@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q130sor7093220ljb.16.2019.07.02.02.54.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 02 Jul 2019 02:54:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of vitalywool@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=KDkySTJN;
       spf=pass (google.com: domain of vitalywool@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=vitalywool@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=hjyKVTfGLIvonwBnPeklb1p3eTYs2YkOVqXlW7TXq5I=;
        b=KDkySTJNPi9xp2C9AbgqC60PF/XlLQ5EkZL2DorhyaDXAZWlT23yYIPfStjb1pELpb
         mCt6Dw0DoiVH9E0SF4LlIrX0Qg/iIO4boobYYGgAwfSUTcsn0iXNwkW0tj6VYZOQyIxJ
         /4JMcJsCj17lggg5m+gtFf24FOocdJjTtV1WH/HxcaH675SYrW59q555fZDLlfk5v1xz
         X/OxWEagVMcjk6FONjuM7VNPBOhVAULnNjBwbn6W7429kkDrpbgwYOw0LUYxZwLDEYen
         UqnqI9mCajyZkBl0t7/k3WXjxkERDDuwlXPAGc6Dp44e4YV59PKX2b9rkuqatb8B1oYO
         dQ4A==
X-Google-Smtp-Source: APXvYqzwuDK5paYci+EjBub1RottsQW8Z3v6j5P39yYdQ08dZkdClJyhBoe5GwYmEBPA5Rl/qWZ8LnknbwME5uslAZ4=
X-Received: by 2002:a2e:8ed2:: with SMTP id e18mr16909326ljl.235.1562061244143;
 Tue, 02 Jul 2019 02:54:04 -0700 (PDT)
MIME-Version: 1.0
References: <20190702005122.41036-1-henryburns@google.com>
In-Reply-To: <20190702005122.41036-1-henryburns@google.com>
From: Vitaly Wool <vitalywool@gmail.com>
Date: Tue, 2 Jul 2019 12:53:51 +0300
Message-ID: <CAMJBoFM0ciL81Tq5ZMRwwGHhxBwJ=2Wf31u=W_74AzmCbLubyA@mail.gmail.com>
Subject: Re: [PATCH v2] mm/z3fold.c: Lock z3fold page before __SetPageMovable()
To: Henry Burns <henryburns@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vitaly Vul <vitaly.vul@sony.com>, 
	Mike Rapoport <rppt@linux.vnet.ibm.com>, Xidong Wang <wangxidong_97@163.com>, 
	Shakeel Butt <shakeelb@google.com>, Jonathan Adams <jwadams@google.com>, Linux-MM <linux-mm@kvack.org>, 
	LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 2, 2019 at 3:51 AM Henry Burns <henryburns@google.com> wrote:
>
> __SetPageMovable() expects it's page to be locked, but z3fold.c doesn't
> lock the page. Following zsmalloc.c's example we call trylock_page() and
> unlock_page(). Also makes z3fold_page_migrate() assert that newpage is
> passed in locked, as documentation.
>
> Signed-off-by: Henry Burns <henryburns@google.com>
> Suggested-by: Vitaly Wool <vitalywool@gmail.com>

Acked-by: Vitaly Wool <vitalywool@gmail.com>

Thanks!

> ---
>  Changelog since v1:
>  - Added an if statement around WARN_ON(trylock_page(page)) to avoid
>    unlocking a page locked by a someone else.
>
>  mm/z3fold.c | 6 +++++-
>  1 file changed, 5 insertions(+), 1 deletion(-)
>
> diff --git a/mm/z3fold.c b/mm/z3fold.c
> index e174d1549734..6341435b9610 100644
> --- a/mm/z3fold.c
> +++ b/mm/z3fold.c
> @@ -918,7 +918,10 @@ static int z3fold_alloc(struct z3fold_pool *pool, size_t size, gfp_t gfp,
>                 set_bit(PAGE_HEADLESS, &page->private);
>                 goto headless;
>         }
> -       __SetPageMovable(page, pool->inode->i_mapping);
> +       if (!WARN_ON(!trylock_page(page))) {
> +               __SetPageMovable(page, pool->inode->i_mapping);
> +               unlock_page(page);
> +       }
>         z3fold_page_lock(zhdr);
>
>  found:
> @@ -1325,6 +1328,7 @@ static int z3fold_page_migrate(struct address_space *mapping, struct page *newpa
>
>         VM_BUG_ON_PAGE(!PageMovable(page), page);
>         VM_BUG_ON_PAGE(!PageIsolated(page), page);
> +       VM_BUG_ON_PAGE(!PageLocked(newpage), newpage);
>
>         zhdr = page_address(page);
>         pool = zhdr_to_pool(zhdr);
> --
> 2.22.0.410.gd8fdbe21b5-goog
>

