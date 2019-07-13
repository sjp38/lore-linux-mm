Return-Path: <SRS0=cxLU=VK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 538DAC742A7
	for <linux-mm@archiver.kernel.org>; Sat, 13 Jul 2019 08:25:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E728020838
	for <linux-mm@archiver.kernel.org>; Sat, 13 Jul 2019 08:25:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="VFMyJlnY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E728020838
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 15F3C8E0009; Sat, 13 Jul 2019 04:25:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 10F4E8E0003; Sat, 13 Jul 2019 04:25:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 024C88E0009; Sat, 13 Jul 2019 04:25:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f72.google.com (mail-lf1-f72.google.com [209.85.167.72])
	by kanga.kvack.org (Postfix) with ESMTP id 939668E0003
	for <linux-mm@kvack.org>; Sat, 13 Jul 2019 04:25:37 -0400 (EDT)
Received: by mail-lf1-f72.google.com with SMTP id f24so920133lfj.17
        for <linux-mm@kvack.org>; Sat, 13 Jul 2019 01:25:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=6QTd4eX3sc1qUhKub9n3hlO3YZ/+QH5MhW+wPUN67nI=;
        b=iYlgaP7wuKWAgB9wuxzoM7O276h22T6b7adLe1ku3c//mHlX72myot+enIyFveGY0n
         mW7tN8Tn04iRHyuwrpf+hHLhwQ4tuyHq+RSUHJgoMSmLgTo5y5U+6a4+TgVsCqBkZWuz
         QnELk6IzT/w5EwWKW8FfLAPgQdGf1vq2hdBSNaDYRGeWSJHkSZrQEKHdk4j9WrJfcUyM
         yZqpykVw2/FKDtEn8fMDH6ejfhcO8xOINBVnLP461HQlBNTIQMimulWtod1+z+qLzBNZ
         0VbzQW0QAeWBpnJpG23DA+o2cvzFeAWZAgViAuIuVADkGkFUFRMDf3eRVTF27ekyxfLK
         ubrg==
X-Gm-Message-State: APjAAAUYZihlPuVMirPct38eYCeBW0s1BXpMv0dS/QxoCxGKHh2/M1bb
	ojHjxyDQBTRsImY1aZOjV3LNZCuSFNeamFjt6ZEzOZXJtgs3aWM8jVBZJHDEV4Bwwl/axxCbfG2
	vraxwSdmYso1/Cv0YmBN0wm9ZNSgE+yjiJ4hE7vxmtddJweEwVrtHYn1QJDNvSHfChw==
X-Received: by 2002:a2e:9ad1:: with SMTP id p17mr8345197ljj.34.1563006336867;
        Sat, 13 Jul 2019 01:25:36 -0700 (PDT)
X-Received: by 2002:a2e:9ad1:: with SMTP id p17mr8345167ljj.34.1563006335894;
        Sat, 13 Jul 2019 01:25:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563006335; cv=none;
        d=google.com; s=arc-20160816;
        b=NvXc5/4HbSc7TKZbPL4Kh1IpFvSIM9mI3WcodPDo8aA4Ha0BQRa2Xmuq1IZafs7G9x
         OkmaE53r3SHPFQKttUb7npWUfWke7qsGb65o1a7X1MmLD1+Qp+lTGMq3CnRbihLnRJDV
         9TRCNU6+gQ1Zzmkb2+3QZKUEEefxrCLsA2TGW69ZDQJDIuGSnFnmQIK1w6ljArVnFJtA
         w3nPhVkrjc9OnmGOGqRDIywm9+Fw/usqQg02uPjMF2TIn4v2vpWc0o/IAEM9ZouyPtYj
         NgzOqKr5HoNlvpYZ0bRg4b2MxwP1/1qLfDl/miglaP6nuUqQXJu0veTUP/yYXuD6vues
         rkaw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=6QTd4eX3sc1qUhKub9n3hlO3YZ/+QH5MhW+wPUN67nI=;
        b=q5LrtxUJu4kR/ho29De1a9aITFP0iOVi586K0qydOoIIS10+rCtttHzSQdCAC82lw5
         sRxCz+rCrnHJNpFB1rECHQIFX3EVNTX8+9FF79QOt2OqfgplLa3dqI3hGFlrwtvgJ3Sf
         bKyAfw/8QKb3w5zcDq7BSHxkUr/XvPyRBSKBPUnsBQakmUWlrSeuKOfY9yU33Orglr8+
         CERY9hroN/IQ6yhW0WemPlZfTKZ2bf38f5etjqlXPpd3cCqctln8thLKinZA1juDXij9
         n12xat19kmeucEXpO/ESJweRg4nh5aDo1b9Zv9IxD/oc6tX+CRM+EGw4RmK5QsqZ+Gho
         dMqw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=VFMyJlnY;
       spf=pass (google.com: domain of vitalywool@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=vitalywool@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z27sor6597925ljb.11.2019.07.13.01.25.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 13 Jul 2019 01:25:35 -0700 (PDT)
Received-SPF: pass (google.com: domain of vitalywool@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=VFMyJlnY;
       spf=pass (google.com: domain of vitalywool@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=vitalywool@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=6QTd4eX3sc1qUhKub9n3hlO3YZ/+QH5MhW+wPUN67nI=;
        b=VFMyJlnY+HNmqN+/0XkHTCcE4XUlcWBudV8DdALA0mOHLcnTYnfBhIgHqG2Xia3xSO
         U+C7VUV0ICM2Hmaomy7KZ2TG1eODRaAmDL0dWsWvdt5A53muSbUu9XZkAGgJC5+LwetN
         lW8zno8kHgmXJnpTg0QCSv1xy5GT766oLuiTEqraYE9aijU6bOKyd61VOecp57itocUb
         uEaW5eY3ol9CwZOfno3tKtv/y4qBybA/MtM2HH/XVQgHgkbTRq+up5pN6UQN/lTs0L5h
         O7QG8D7CX18kqSuOrowDeVuMJ+jtN/IJaXZHniI7gtVawa9IIz+TkAy60/rj4ho1Fs03
         ZWJA==
X-Google-Smtp-Source: APXvYqwp76JJ/0WJFWcpBXbQNkvry0BV51hxWYJa9soCGBmQZQIk3fJZkjhExYfCppqBMazsYp4R4aCwpUGHoXRwkOM=
X-Received: by 2002:a2e:8ed2:: with SMTP id e18mr8207102ljl.235.1563006335346;
 Sat, 13 Jul 2019 01:25:35 -0700 (PDT)
MIME-Version: 1.0
References: <20190712222118.108192-1-henryburns@google.com>
In-Reply-To: <20190712222118.108192-1-henryburns@google.com>
From: Vitaly Wool <vitalywool@gmail.com>
Date: Sat, 13 Jul 2019 10:24:30 +0200
Message-ID: <CAMJBoFNvYP9J=LC2U1McMa2D4=C5szOStzebDd4e2MV6tbpBsw@mail.gmail.com>
Subject: Re: [PATCH] mm/z3fold.c: Allow __GFP_HIGHMEM in z3fold_alloc
To: Henry Burns <henryburns@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vitaly Vul <vitaly.vul@sony.com>, 
	Shakeel Butt <shakeelb@google.com>, Jonathan Adams <jwadams@google.com>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Snild Dolkow <snild@sony.com>, 
	Thomas Gleixner <tglx@linutronix.de>, Linux-MM <linux-mm@kvack.org>, 
	LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Jul 13, 2019 at 12:22 AM Henry Burns <henryburns@google.com> wrote:
>
> One of the gfp flags used to show that a page is movable is
> __GFP_HIGHMEM.  Currently z3fold_alloc() fails when __GFP_HIGHMEM is
> passed.  Now that z3fold pages are movable, we allow __GFP_HIGHMEM. We
> strip the movability related flags from the call to kmem_cache_alloc()
> for our slots since it is a kernel allocation.
>
> Signed-off-by: Henry Burns <henryburns@google.com>

Acked-by: Vitaly Wool <vitalywool@gmail.com>

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

