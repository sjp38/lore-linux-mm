Return-Path: <SRS0=tO+N=VH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 82772C74A36
	for <linux-mm@archiver.kernel.org>; Wed, 10 Jul 2019 21:40:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3E53B20838
	for <linux-mm@archiver.kernel.org>; Wed, 10 Jul 2019 21:40:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="ianG8POe"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3E53B20838
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CC4AE8E0098; Wed, 10 Jul 2019 17:40:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C75A88E0032; Wed, 10 Jul 2019 17:40:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B3E248E0098; Wed, 10 Jul 2019 17:40:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id 959C08E0032
	for <linux-mm@kvack.org>; Wed, 10 Jul 2019 17:40:08 -0400 (EDT)
Received: by mail-yw1-f70.google.com with SMTP id j144so2389852ywa.15
        for <linux-mm@kvack.org>; Wed, 10 Jul 2019 14:40:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=klmpTKMRhJk0PWQQA2dmLgLN6yYzHWA+paLC90wMAwo=;
        b=WTrYUkvPgbmUHqrk+IQ+HWzr4//jh65L8h0LR+10mXIHME7IWnGbyQxz9Hy+cvE5wJ
         nooX5nkgf10PddbPqNWUo+Bl0tcNiwCBINrojr8lZce99VmdeHtx+4Z5B+L9xcgl83Kg
         kLj9NvRDzYfSJ9Iq4lEqNbafObaaM6ni3SttOFBRwvnNQHlJ1OBH2Bzis5D8bVyEZpPS
         0DEzACKAQ7GA+/buUvlKK2gfOJ8oCb1MN8wWlECYZCz654eWO/VC9Cq+YB8nJziBCimJ
         zLQj57/WmyGj0vEmeFFmoNkTbxC8GzLXjJNxmFQ7DWEXTHAsALFX/mWp/AC8nxlSg+Zv
         K4GA==
X-Gm-Message-State: APjAAAUvMaRlCC4ekE/mGZi1cFaqr+Brofm43oJajtVxlaOElFCcZ5Qk
	AdSMny//WxoOJTAjv6dBkbI6xe7J5DpuzTEKKJ9jyRn8Y4UgZUd4nmK8/Qc3dndmub/nkp8THR9
	17T5hTOvvikPZffWJW1Nfr8ZFdaEHtmXDk3JQ4JtUEw7P2Rxgh61pm9McNSwkE8mfwg==
X-Received: by 2002:a0d:f805:: with SMTP id i5mr21026096ywf.449.1562794808328;
        Wed, 10 Jul 2019 14:40:08 -0700 (PDT)
X-Received: by 2002:a0d:f805:: with SMTP id i5mr21026075ywf.449.1562794807784;
        Wed, 10 Jul 2019 14:40:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562794807; cv=none;
        d=google.com; s=arc-20160816;
        b=c3YgHcpxq/wF6ISKisC6lVOopWofSG8NZOU5rdhj6H8km48XYHrCZA0An8QAXCxeRR
         wzYcUpDU83d+AiugNEJkC3m0BsUha9IgVOuxb51lqPFiQpK6nBKu/OhNUUAPR9eXxvKb
         IaYzBz5sij2csRRqB4RQbnzA56lPw8C0VoGs67VO10a/Ft9UiGERj6Brx/1w50W4zf3I
         q1VOLEdPj4DWnVEgujl65lJsLgaAS260b6p3L4GXto2drilOZDvgbHn5fHCxG3Vio+ef
         08dB3x1OvCWjOTI9JjBkYmBYq31E9IKVRRyTn5n/O1Wpw313ijOiA8S67KK280nYydtm
         CArQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=klmpTKMRhJk0PWQQA2dmLgLN6yYzHWA+paLC90wMAwo=;
        b=DZHBLjMdDMb/k4I6DplOfO9NsQVhwc06uw5k007DXUrVZi0SpHs232YxXyPitu+nxN
         ZfHYfTmUJq65Ht1JVXeKI8aRpKnkN7EVpa8vuGyqO042Jk3VY0/POiP4Bzcr3uPXz68t
         ZmGFOTa9Uyvxghty+yDDk0xNR1wkVDpPz5IdxdSdR/3tomdqFPGjcjy0eyg+AZ3I/BzO
         OodsA2aB01JUDfwR3Az3me3LY/ZywL6J0eLD+m0jrgijEamJYV21BgUplDrxlosfygGx
         +w1VXOME66oJ2zBRSBGKz1++v3ZDRjVCHOzAqDEl83zdUhW4TqWQaMV+3eGoVe6+9mBR
         OMnA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=ianG8POe;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x186sor2086123ybg.209.2019.07.10.14.40.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 10 Jul 2019 14:40:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=ianG8POe;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=klmpTKMRhJk0PWQQA2dmLgLN6yYzHWA+paLC90wMAwo=;
        b=ianG8POesm7I23H2706WLKaOHcIeSM/jbJvK3rX1MbMAkRdwmns8fy1bKZC7i9oc3k
         ohbiQFPpzrqOOrzzv+XhRdRFx+/2IAbaOBKTcRklRc+xSnIjtv158DtXLkElnFJIEZQM
         TzWEnN+zO218EByyOBpYZTflZ2HqTf6TV6LFwmZjK1voTtyFxX18k/9gYaEuUuk3J4k+
         K2qKaAYPaowUKNlcmGN4ToMAGbqL6DJO3BYiRM2quEj3iw0xeLuCN0mw/mYqFS+c4/GU
         Zq2v67KPnQzfEEFsI1vt0c2DxD+a+avQP8g97zcsXYKmfHt8Zml5XHrtaheM02XN5BnG
         PdBg==
X-Google-Smtp-Source: APXvYqw4iXskw6yoB+U4UXJRAYJgfQB2zmNYQyo/PSJcnmTZ3tvplyN8EfCsh0Hao7Yc0XZMOxUHsuZHdRdZtD5D0sE=
X-Received: by 2002:a25:7c05:: with SMTP id x5mr20528ybc.358.1562794807061;
 Wed, 10 Jul 2019 14:40:07 -0700 (PDT)
MIME-Version: 1.0
References: <20190710213238.91835-1-henryburns@google.com>
In-Reply-To: <20190710213238.91835-1-henryburns@google.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Wed, 10 Jul 2019 14:39:55 -0700
Message-ID: <CALvZod7kMX5Xika8nqywyXHuBKqTfSPP7uZ1-OU2M4kmHLiuUw@mail.gmail.com>
Subject: Re: [PATCH] mm/z3fold.c: remove z3fold_migration trylock
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

On Wed, Jul 10, 2019 at 2:32 PM Henry Burns <henryburns@google.com> wrote:
>
> z3fold_page_migrate() will never succeed because it attempts to acquire a
> lock that has already been taken by migrate.c in __unmap_and_move().
>
> __unmap_and_move() migrate.c
>   trylock_page(oldpage)
>   move_to_new_page(oldpage_newpage)
>     a_ops->migrate_page(oldpage, newpage)
>       z3fold_page_migrate(oldpage, newpage)
>         trylock_page(oldpage)
>
>
> Signed-off-by: Henry Burns <henryburns@google.com>

Reviewed-by: Shakeel Butt <shakeelb@google.com>

Please add the Fixes tag as well.

> ---
>  mm/z3fold.c | 6 ------
>  1 file changed, 6 deletions(-)
>
> diff --git a/mm/z3fold.c b/mm/z3fold.c
> index 985732c8b025..9fe9330ab8ae 100644
> --- a/mm/z3fold.c
> +++ b/mm/z3fold.c
> @@ -1335,16 +1335,11 @@ static int z3fold_page_migrate(struct address_space *mapping, struct page *newpa
>         zhdr = page_address(page);
>         pool = zhdr_to_pool(zhdr);
>
> -       if (!trylock_page(page))
> -               return -EAGAIN;
> -
>         if (!z3fold_page_trylock(zhdr)) {
> -               unlock_page(page);
>                 return -EAGAIN;
>         }
>         if (zhdr->mapped_count != 0) {
>                 z3fold_page_unlock(zhdr);
> -               unlock_page(page);
>                 return -EBUSY;
>         }
>         new_zhdr = page_address(newpage);
> @@ -1376,7 +1371,6 @@ static int z3fold_page_migrate(struct address_space *mapping, struct page *newpa
>         queue_work_on(new_zhdr->cpu, pool->compact_wq, &new_zhdr->work);
>
>         page_mapcount_reset(page);
> -       unlock_page(page);
>         put_page(page);
>         return 0;
>  }
> --
> 2.22.0.410.gd8fdbe21b5-goog
>

