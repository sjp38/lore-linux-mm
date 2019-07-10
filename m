Return-Path: <SRS0=tO+N=VH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A6A6BC74A35
	for <linux-mm@archiver.kernel.org>; Wed, 10 Jul 2019 20:51:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5104020844
	for <linux-mm@archiver.kernel.org>; Wed, 10 Jul 2019 20:51:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="un30DGda"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5104020844
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AD20F8E0097; Wed, 10 Jul 2019 16:51:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A76288E0032; Wed, 10 Jul 2019 16:51:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 93D458E0096; Wed, 10 Jul 2019 16:51:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f199.google.com (mail-yb1-f199.google.com [209.85.219.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6E4468E0032
	for <linux-mm@kvack.org>; Wed, 10 Jul 2019 16:51:01 -0400 (EDT)
Received: by mail-yb1-f199.google.com with SMTP id 192so2522277ybk.7
        for <linux-mm@kvack.org>; Wed, 10 Jul 2019 13:51:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=qtC5egLkr6FDak2iWiMiUha4yDwOlLCqb/iy6dvufbg=;
        b=O7GiDDaY2Jf16gkH0ZhTSBjz0FpRKE+FASI+r7tovjLUVQLVdZij2oPls/xbEIL7ts
         vtfoT0dB3no4/p8geigV0+wg4E0+y5Czv6Lr5fcnQokKrHunK1akcdIp8LP/kG1ByU7A
         LiyGwdhjtz8mrjnYjgqllh3OI1ySDo15Y10oIsTshwrDUg5ZBQ/yb0Lj+X/GTNwGr8Dw
         iBsUxC8UmN3sWuEDE+GUOyn9am4OzxSEEzPsjOjjIzWPvNJTeKBGYrVPGGdHPtfiW1ww
         TY4XKo3jUOV/7+7Kl4cV/Z+UuecK/WK5j7frQgWRhzUhXWdd06o+9KfQoHDMEwaIoswE
         cyvA==
X-Gm-Message-State: APjAAAUTDLAt9a4Kb3PtPvHheK2oDGrbrVLwGf+5Z3sTDETV6/Vr0GUm
	0LGgJo8Yf6zMnmFugu4yMA1TPnlAJzp44kG5QU5edHwkUPOqUl3tQCqz2jRck5mW9SiHID8jPb/
	LhA/FntJzFeW5OOu9b+qYywh170xfh5mbC3HH07kHF7SJSNXqrm0+foQR7UCC9zRa9A==
X-Received: by 2002:a25:d346:: with SMTP id e67mr17754936ybf.267.1562791861066;
        Wed, 10 Jul 2019 13:51:01 -0700 (PDT)
X-Received: by 2002:a25:d346:: with SMTP id e67mr17754924ybf.267.1562791860615;
        Wed, 10 Jul 2019 13:51:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562791860; cv=none;
        d=google.com; s=arc-20160816;
        b=WvdwU/r43Br6vR6iL8YdhZt/nrh7/tcLJuS0SyqTYntbCjhavFd2nr6aYwTuqzP179
         7/gMXzxy1Klzw22SmczwZ1lazsIqsIoc5O4G1PORLZsHpKhN2L8KsZGT18QLtViuopTw
         l8oUYCf7DrufQT0glsbSV0k8gSbd1FL1MnyUZ0u97vYSa534f2ctv8xYLWPnEJfKnVSu
         MDxPk8K0oJEE5MhrXPPkw62s0YE/MFdcy/lhK3T5IhzuJ+dp1gkHPupSce8R76WdBiUf
         NtXknSN8B2EdnfRXaL18D8b60zwbVqYPvsHqnCijPYW2z+D5KseBy7mFdhh2YKR7xYlJ
         FT1A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=qtC5egLkr6FDak2iWiMiUha4yDwOlLCqb/iy6dvufbg=;
        b=ScKF9SmuHuoC86+YgxwwTx9r5O+YfafVyMhNdgJEAm8kSeAvJQkWoBFhPAKUWYWP+I
         VWqczJNwLX+yXJXfhX2dJxVSYFQagNHSjUxs0WaFNJkbDf2LEReFqoc/PvY0v6S8S8M5
         I8z7n1IlSkfyEOJI4ZeLn1zAbK0oVUDW9h2NAWXpxK5gElaRGFAfzyI1s0knTBJRPrd9
         4I2kzlOFiHjxdpEmCJjE5I7DHg9jfjajB6toi6W3HUGGvRxFRdYCOx7eIXiZMcmJMkg1
         lJBEaeaIws2gpwqXxZf0eB95BvWhSpVDAvV09uY83KqfI8TpsjbnScporFLfcMnTl/6i
         hW/A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=un30DGda;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 80sor1734059ywv.101.2019.07.10.13.51.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 10 Jul 2019 13:51:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=un30DGda;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=qtC5egLkr6FDak2iWiMiUha4yDwOlLCqb/iy6dvufbg=;
        b=un30DGdaaLTQqc9ulK9wePQZNwiEhBjveMWrvXlg8hVi2xvd+N8P2TXZEoi0WRxMdO
         llLXQjc8o0YK/GKoMM6Mks5D9YzdX5CrXqHUuepOEt99nRpwRW2rjT+WTCSeOQeeYhNY
         HkQJ/viI0xOIijcFCm8BT6F198ZZtsZfO85NmX7p8L3RZpoZF05hYiP5r80MbRionfnI
         KWsMsDligc3KwH/zocEMYeQo0LG5TkO/fPLkkVqoP7ez4YTr4+pklJjpeAOmu3yBa4NT
         XJlnM40YCOwVJubuwzLuIBGosoCyia3oKOEQxKKrSm5FRr2HoaOvlNKs3gNAdhg2r2WH
         x7Tw==
X-Google-Smtp-Source: APXvYqxrw4tF1qH2dtA3sf+vEsBsubI1n/tNaDi+JHo5Z4S27DzhSyZT3l5HStwbMbR0DBnVdtBXrRSGebZ3IdMezPk=
X-Received: by 2002:a0d:c345:: with SMTP id f66mr19381788ywd.10.1562791859824;
 Wed, 10 Jul 2019 13:50:59 -0700 (PDT)
MIME-Version: 1.0
References: <20190708134808.e89f3bfadd9f6ffd7eff9ba9@gmail.com>
In-Reply-To: <20190708134808.e89f3bfadd9f6ffd7eff9ba9@gmail.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Wed, 10 Jul 2019 13:50:48 -0700
Message-ID: <CALvZod7Qfj+Jer1TK4P-HmoQ0now=w2JK7NNrfC6ae8R0cOLcA@mail.gmail.com>
Subject: Re: [PATCH] mm/z3fold.c: don't try to use buddy slots after free
To: Vitaly Wool <vitalywool@gmail.com>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, 
	Henry Burns <henryburns@google.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Jonathan Adams <jwadams@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 8, 2019 at 4:48 AM Vitaly Wool <vitalywool@gmail.com> wrote:
>
> From fd87fdc38ea195e5a694102a57bd4d59fc177433 Mon Sep 17 00:00:00 2001
> From: Vitaly Wool <vitalywool@gmail.com>
> Date: Mon, 8 Jul 2019 13:41:02 +0200
> [PATCH] mm/z3fold: don't try to use buddy slots after free
>
> As reported by Henry Burns:
>
> Running z3fold stress testing with address sanitization
> showed zhdr->slots was being used after it was freed.
>
> z3fold_free(z3fold_pool, handle)
>   free_handle(handle)
>     kmem_cache_free(pool->c_handle, zhdr->slots)
>   release_z3fold_page_locked_list(kref)
>     __release_z3fold_page(zhdr, true)
>       zhdr_to_pool(zhdr)
>         slots_to_pool(zhdr->slots)  *BOOM*
>
> To fix this, add pointer to the pool back to z3fold_header and modify
> zhdr_to_pool to return zhdr->pool.
>
> Fixes: 7c2b8baa61fe  ("mm/z3fold.c: add structure for buddy handles")
>
> Reported-by: Henry Burns <henryburns@google.com>
> Signed-off-by: Vitaly Wool <vitalywool@gmail.com>

Reviewed-by: Shakeel Butt <shakeelb@google.com>

> ---
>  mm/z3fold.c | 5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
>
> diff --git a/mm/z3fold.c b/mm/z3fold.c
> index 985732c8b025..e1686bf6d689 100644
> --- a/mm/z3fold.c
> +++ b/mm/z3fold.c
> @@ -101,6 +101,7 @@ struct z3fold_buddy_slots {
>   * @refcount:          reference count for the z3fold page
>   * @work:              work_struct for page layout optimization
>   * @slots:             pointer to the structure holding buddy slots
> + * @pool:              pointer to the containing pool
>   * @cpu:               CPU which this page "belongs" to
>   * @first_chunks:      the size of the first buddy in chunks, 0 if free
>   * @middle_chunks:     the size of the middle buddy in chunks, 0 if free
> @@ -114,6 +115,7 @@ struct z3fold_header {
>         struct kref refcount;
>         struct work_struct work;
>         struct z3fold_buddy_slots *slots;
> +       struct z3fold_pool *pool;
>         short cpu;
>         unsigned short first_chunks;
>         unsigned short middle_chunks;
> @@ -320,6 +322,7 @@ static struct z3fold_header *init_z3fold_page(struct page *page,
>         zhdr->start_middle = 0;
>         zhdr->cpu = -1;
>         zhdr->slots = slots;
> +       zhdr->pool = pool;
>         INIT_LIST_HEAD(&zhdr->buddy);
>         INIT_WORK(&zhdr->work, compact_page_work);
>         return zhdr;
> @@ -426,7 +429,7 @@ static enum buddy handle_to_buddy(unsigned long handle)
>
>  static inline struct z3fold_pool *zhdr_to_pool(struct z3fold_header *zhdr)
>  {
> -       return slots_to_pool(zhdr->slots);
> +       return zhdr->pool;
>  }
>
>  static void __release_z3fold_page(struct z3fold_header *zhdr, bool locked)
> --
> 2.17.1

