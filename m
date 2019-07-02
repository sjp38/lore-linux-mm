Return-Path: <SRS0=T9E7=U7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 64675C5B578
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 01:00:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 215C6206A2
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 01:00:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="S0GY9y8C"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 215C6206A2
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B16A36B0003; Mon,  1 Jul 2019 21:00:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AC5808E0003; Mon,  1 Jul 2019 21:00:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9B4AB8E0002; Mon,  1 Jul 2019 21:00:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f197.google.com (mail-yb1-f197.google.com [209.85.219.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7B6E66B0003
	for <linux-mm@kvack.org>; Mon,  1 Jul 2019 21:00:44 -0400 (EDT)
Received: by mail-yb1-f197.google.com with SMTP id z4so1512296ybo.4
        for <linux-mm@kvack.org>; Mon, 01 Jul 2019 18:00:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=YLKaclKnF/wxygehnw0ZhA/GQEsmphWVTGozX4zGxLc=;
        b=Sa2d/RHFRc/ZeSvBYBVqTW1RANvV1TryWzsn7cVX/KYxOMYgV1pIg1FDNRBVMe+9J9
         i9zNV2lecBIRNA59mDodIbgmGfB5SF3jiKpPAK6fksZYhEO+iolTXw83UkPQfJjr14Ku
         aCCX9GwxRXYHVh15CR8VCTMOxnY+azbCnxz+fgDQfxJ8EI6EkYSigGFGMV1Uks0644R0
         Lb4kLWtDhCviCe2DVf+7QVmFc6sUFpXcsW33DaqLGaz8A4Tcr6iuEgS2tiGoVVd5jykB
         u4bsmCo8sh3qluP3xUdS6Bk8PkvJXG0+GMreyU8S5eTSPMhv/05yFUWFcBeEsFF1OSJq
         xBfA==
X-Gm-Message-State: APjAAAULtSdlZBcuIyeyLsiJdF7BLNSaAVy/BpbbFeYnmed07L5M75Hl
	b4zO9z575r8fJeh6XDNIfVmwd4Lk/QZAdh4reFkiTK7i6Hn8/glmS888+/kpt3Woffq4xLZ2pWn
	MIQwN4/kMq43kwg+tfAG8nETOocTpBHAI9xgikjmPOlWkyTB1wVCS5touoheQbSklcg==
X-Received: by 2002:a81:2545:: with SMTP id l66mr15822357ywl.489.1562029244207;
        Mon, 01 Jul 2019 18:00:44 -0700 (PDT)
X-Received: by 2002:a81:2545:: with SMTP id l66mr15822315ywl.489.1562029243464;
        Mon, 01 Jul 2019 18:00:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562029243; cv=none;
        d=google.com; s=arc-20160816;
        b=Uz5RVpMqmpI01LzS5vItd1vYBmlfJpD/2t48b6bVkxn5ldyOhBboYSz64IVQHrm0tG
         g13oz3d8PeDNA/QtMbPAx3ym8dpgJi9LyZLc1iFzVMBezSgE7jYcQFoVGKhRYKvx5uhc
         eRZrXNVH7NokmmfWzjw66fpNqAppGZlVGjzXsFVjnMKwYbP2y0BuPgWRgvRbn6A5PeJW
         3Kr/C/HbB7Yw6udPq+4JLYMj4IAUUhIDs6agVanjzChqaef7YRUjeNC9sM3qFDAqg2YS
         eEkR0yCb5X1DPigW3eKPRPOcijrrdj7w909/S+C1TvJh6ZBvEy4C3eNDeO3bVKTFtWkX
         R37A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=YLKaclKnF/wxygehnw0ZhA/GQEsmphWVTGozX4zGxLc=;
        b=vQkg/wP3HW6AbQ3wGfZa3CzppbEp9r/KCj1KSWDvipMU2+DjWzdv3o3S9NNef2Sgmn
         6HiWCyGH9vOFPli0XXL24XpnC0EemUV1giQzmmsOteb0JDiHfvQguI3i+Fr3keiAvmdE
         eJwEpkT9cmbqciCTNQErAHbir8amDyKiJHZnlaiZKODMS/PzGqgMYTchl+xJmteGqHVb
         YIAagSzugkeEMm9drxWfgdpY/KRTb6sf3nLzW1RMxaXfnsXaqaG/tf52BiKzaok1okGZ
         7EzZpGY2dhvFV4SMc7/cxpJaTUzODb8LBo+JM0tPIZB8QZjrlSq3fpb4616nWQrtK+h+
         xwUg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=S0GY9y8C;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r18sor6765026ybg.91.2019.07.01.18.00.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 01 Jul 2019 18:00:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=S0GY9y8C;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=YLKaclKnF/wxygehnw0ZhA/GQEsmphWVTGozX4zGxLc=;
        b=S0GY9y8C/Fi0sdyS/zcdqZr9tVAkG5ce7/IOGJ3enKy5/OPj2sokEMJIsSjkOxTADB
         +PtoAyiTYcYXDCup7vpukfHspqp6SPItVVG7fCAF9A7iH/K7i3vvprAhA5I61pfwHIct
         o0ZHa1L67jnNDgQ7MUaWUBb2jJbsO1a1qzkko2H6PTDkLBNOFIUlXB1hdoYyLycvv5uN
         g7VyrmxhBLq94kxQgJ39x6KgRKFiBHeg9BQNXXjtYiTLC8ExSo86WvdKD6UrovqjrGFG
         VzdM3uYqXrjYPX/v6yBewSkqjx/4mfssMGnUzTKLgYPCc3fgIIBf3gUIRChLsfhcY2Yp
         Mutg==
X-Google-Smtp-Source: APXvYqzOaefDFiVFWymQi9oWxw+On0j/dhwOjHPPdiSEDz5QwOyBU1Adr/aXtUeEIa5jaD4wiTcCCpEQKsZhQTgq9tw=
X-Received: by 2002:a25:7c05:: with SMTP id x5mr17362245ybc.358.1562029242861;
 Mon, 01 Jul 2019 18:00:42 -0700 (PDT)
MIME-Version: 1.0
References: <20190702005122.41036-1-henryburns@google.com>
In-Reply-To: <20190702005122.41036-1-henryburns@google.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Mon, 1 Jul 2019 18:00:31 -0700
Message-ID: <CALvZod5Fb+2mR_KjKq06AHeRYyykZatA4woNt_K5QZNETvw4nw@mail.gmail.com>
Subject: Re: [PATCH v2] mm/z3fold.c: Lock z3fold page before __SetPageMovable()
To: Henry Burns <henryburns@google.com>
Cc: Vitaly Wool <vitalywool@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Vitaly Vul <vitaly.vul@sony.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, 
	Xidong Wang <wangxidong_97@163.com>, Jonathan Adams <jwadams@google.com>, 
	Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 1, 2019 at 5:51 PM Henry Burns <henryburns@google.com> wrote:
>
> __SetPageMovable() expects it's page to be locked, but z3fold.c doesn't
> lock the page. Following zsmalloc.c's example we call trylock_page() and
> unlock_page(). Also makes z3fold_page_migrate() assert that newpage is
> passed in locked, as documentation.
>
> Signed-off-by: Henry Burns <henryburns@google.com>
> Suggested-by: Vitaly Wool <vitalywool@gmail.com>
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

Can you please comment why lock_page() is not used here?

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

