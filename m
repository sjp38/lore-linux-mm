Return-Path: <SRS0=FHqE=VM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EC91CC7618F
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 17:22:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A7ABE206B8
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 17:22:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="dCelnzTW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A7ABE206B8
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 42C9A6B000A; Mon, 15 Jul 2019 13:22:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3DCE16B000C; Mon, 15 Jul 2019 13:22:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2CA856B000E; Mon, 15 Jul 2019 13:22:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id 077456B000A
	for <linux-mm@kvack.org>; Mon, 15 Jul 2019 13:22:49 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id e12so13980929ywe.6
        for <linux-mm@kvack.org>; Mon, 15 Jul 2019 10:22:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=UscG4WxjnjQLRRcfnLMqxRe1yzGwBuLWPpq8Fn0xt8Q=;
        b=OVGId2YyBnW1d9DcKIYNj91K14C6Uost7uLsB/wEBNCcpZbCXzn9d7U8ChwS7FpFY2
         jFQUIaiUwF8uI4wJg3PV22MX2KVOAHJ/UQgl2P2snKK48YVy8XxPNjaUXwl8+rsPqz5k
         TYuCWYe/JMbM52TbO8RKUBrrJW25KDtEr0BOIXCzBmWKFI+GfTH4M2cFk6zEaU+w/Efi
         TX9t8PVbGIkolqUaCt8PL68aWCPq2Pb7sFf1hHitNv25LxaeaK5zU9ekPgCVTuL8GVSS
         z9CfzoicqX6+YcWDMSmzzeq8hIiCJfnnE4t71qA3LDdY/HGKQKFzH5ZYdHuBko/3lBh9
         EedQ==
X-Gm-Message-State: APjAAAUDSHuVmo3ikiPxCbXM7ewSVhuv0FRGspdIeXKvZ39xA7my1fY+
	JWdoT9koYA37t2dIV5ytoaK7ToRbvSLFwbQz34m8sBPKuU5nPedz89znZRIblYvEPtZ8LnVCjLi
	1OB1dQk3gUC4QeCQJppbgegOhe9iIu8jmwRy6Tmw5SS23UbpAiYe6FFex9/gpWcvzog==
X-Received: by 2002:a25:7911:: with SMTP id u17mr8247586ybc.155.1563211368723;
        Mon, 15 Jul 2019 10:22:48 -0700 (PDT)
X-Received: by 2002:a25:7911:: with SMTP id u17mr8247555ybc.155.1563211368112;
        Mon, 15 Jul 2019 10:22:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563211368; cv=none;
        d=google.com; s=arc-20160816;
        b=sDFsqQjWQ5YBVlSHbdLbSoi1L0wC3q4fYBIoiekR9vJe11Q6W8NxEqv2rz2/zj1AF/
         SkUOtWKuFewm/ktUDqhJlAD//weicilaul0JThe/GseFW/QRwfC1Kp7BmlYlZaBG4wDZ
         OAos3UN5PJxbyLoBhaSSLnm8deiSmZfSSVtoZqfQOxm7VB1Cg8qadRayXciPitFuOQ0M
         sgfda8uadeR3hhEUe6aV8RaTc6VTFv7GmAtghzpQU968dLyCLI7hnTXjw9xJHDbt9pen
         2C+B2Y1qQiRgAWQeoasjw/5VuwvRdpr8VuzKNQVp+Wz0u/85kh3FYzbPJP+yITH5JV0g
         YI2Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=UscG4WxjnjQLRRcfnLMqxRe1yzGwBuLWPpq8Fn0xt8Q=;
        b=GuxeLzGdcpIZdJO+youetkexIgLFyfwNbV2xPsEn0X1o1I3gZ46dRAyVyJmUNdH4Sm
         dAeOJtRco1iZIra6zXFjheuWi5jKYwiA35O+fY+5OQAhEwL+7n/7WeYDW6O63bl15fNH
         y4g3ZFeY2bWmeTyTKTg7qegPcn+lM8M5Q6WJBeYW+i528nhsSMxZNWx4dHaDhXwYtdS3
         2BB88Wm56GMXGAxy293Iw0oNxjOds4kfnR8S7csdd7utlLQ7dhq+c3M3cR0UUwu6Df2Q
         MoKQdeeNpuw1FLqZNDDxv+ZztziQ7XdU6mbqdFrjtvT1JAz8o66JLPzejxxrWXpFobq4
         5IJA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=dCelnzTW;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j15sor10445244ybg.91.2019.07.15.10.22.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 15 Jul 2019 10:22:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=dCelnzTW;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=UscG4WxjnjQLRRcfnLMqxRe1yzGwBuLWPpq8Fn0xt8Q=;
        b=dCelnzTW9yVty3d0zlRTYG3AJUta/BwdSagZLphy7SUDCPw0lYhayrZl5azIY8Po6K
         B6PcLuuOJVyIxwiflObjLQxgwM5LdzBm9j2APNC/1sPWiDeIVumlaaSR3cBownQl1gZ7
         cmNM24365G9Kw33r/XyMye07LnJCa0G4XuKu3nH+stcJAD3HS2uHdNOlq2NHdW329Kw2
         jEJCSCUJ5tFA21J/y5+gY4zuSpH9pE+SJy2MUjCxIUX/v4EZqtd+ycfE4D0VdA/uMj+1
         lQiPTa3FPre/OAiF6DLgOrahbWMjYOGi4K0cps9eFLAe/W937jrg8dyOuSOGvbo+fxxf
         TPWw==
X-Google-Smtp-Source: APXvYqwD4/nxpkfvH9bQCh/AJuvk/pIr8m7HB8haGrUylB3B6/r9kLVpIkwVT3ZqE0R7QG11+C5RIC8Tuuc4Lid14w8=
X-Received: by 2002:a25:7c05:: with SMTP id x5mr16996019ybc.358.1563211367257;
 Mon, 15 Jul 2019 10:22:47 -0700 (PDT)
MIME-Version: 1.0
References: <20190715164705.220693-1-henryburns@google.com>
In-Reply-To: <20190715164705.220693-1-henryburns@google.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Mon, 15 Jul 2019 10:22:36 -0700
Message-ID: <CALvZod73xAMUT0-zEHZO+J5xRa7HLhKobaDzchpT-CxiPtKTRg@mail.gmail.com>
Subject: Re: [PATCH] mm/z3fold.c: Reinitialize zhdr structs after migration
To: Henry Burns <henryburns@google.com>
Cc: Vitaly Wool <vitalywool@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Vitaly Vul <vitaly.vul@sony.com>, Jonathan Adams <jwadams@google.com>, Linux MM <linux-mm@kvack.org>, 
	LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 15, 2019 at 9:47 AM Henry Burns <henryburns@google.com> wrote:
>
> z3fold_page_migration() calls memcpy(new_zhdr, zhdr, PAGE_SIZE).
> However, zhdr contains fields that can't be directly coppied over (ex:
> list_head, a circular linked list). We only need to initialize the
> linked lists in new_zhdr, as z3fold_isolate_page() already ensures
> that these lists are empty.
>
> Additionally it is possible that zhdr->work has been placed in a
> workqueue. In this case we shouldn't migrate the page, as zhdr->work
> references zhdr as opposed to new_zhdr.
>
> Fixes: bba4c5f96ce4 ("mm/z3fold.c: support page migration")
> Signed-off-by: Henry Burns <henryburns@google.com>

Reviewed-by: Shakeel Butt <shakeelb@google.com>

> ---
>  mm/z3fold.c | 10 ++++++++++
>  1 file changed, 10 insertions(+)
>
> diff --git a/mm/z3fold.c b/mm/z3fold.c
> index 42ef9955117c..9da471bcab93 100644
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
> +        * z3fold_page_isolate() ensures that this list is empty, so we only
> +        * have to reinitialize it.
> +        */
> +       INIT_LIST_HEAD(&new_zhdr->buddy);
>         new_mapping = page_mapping(page);
>         __ClearPageMovable(page);
>         ClearPagePrivate(page);
> --
> 2.22.0.510.g264f2c817a-goog
>

