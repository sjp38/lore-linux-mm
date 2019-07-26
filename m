Return-Path: <SRS0=rceO=VX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 03F42C41517
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 22:53:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B6654218B0
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 22:53:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="S58mOK6k"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B6654218B0
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 616C48E0006; Fri, 26 Jul 2019 18:53:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5C6FC8E0002; Fri, 26 Jul 2019 18:53:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4B5268E0006; Fri, 26 Jul 2019 18:53:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id 25BE58E0002
	for <linux-mm@kvack.org>; Fri, 26 Jul 2019 18:53:30 -0400 (EDT)
Received: by mail-yw1-f71.google.com with SMTP id v3so40262835ywe.21
        for <linux-mm@kvack.org>; Fri, 26 Jul 2019 15:53:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=m8/4TDGoTP0YJOmmNh1QY5sjP7utSN3T4GKeg0uRKkI=;
        b=VQj7oD3Cim8X8limtjwIIYqMcdOGqMSQQGChpp/+Ep2i5qLOZWosdOg8was8hcxhli
         clyAa6SJD61FGigzIsx1wua7o+IKI4G2+ZFbG4mSb8ZPvz7tiAhVmg4Pzd7yjQpKWfBC
         iJP/7KYvnTceN5C5hwg/keGDnTder/u2tZ+d1qB82AuAAsfWK3/+EI+M5AlkD4jpnIPV
         NvGFfUzJ6fksLTYzgdlFDj1oDmc2UurwLxB0E626+GNaobC2k/Sn1p3dbv2tgu+LnffH
         h9Ia4BZoWU+QsC5B42y6NEsMVquQuo6JbaUpfNnJrrKpXbYvy/CMFP3rrO13Oxt9/QZf
         mwnA==
X-Gm-Message-State: APjAAAXm88ayQfahn4mD/MaU4TImVFKZgGRAlxSqGRyDiF0YKOD4kD1Z
	UZi5H9b+AXWmwHEOiR/qD7F/TyO0sRhSr1UZX7l/XcGvd4HKt0coU053jNmFmIlMHE36m0Zc3X3
	EMWVilBNqQvAyA6bDQ8p76brgcEgHTGi/8HjGW50/oySKGf3ylEVJ+EFbDfuXyoQ+yA==
X-Received: by 2002:a81:3d7:: with SMTP id 206mr55140105ywd.411.1564181609799;
        Fri, 26 Jul 2019 15:53:29 -0700 (PDT)
X-Received: by 2002:a81:3d7:: with SMTP id 206mr55140086ywd.411.1564181609340;
        Fri, 26 Jul 2019 15:53:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564181609; cv=none;
        d=google.com; s=arc-20160816;
        b=0RbozLoufK2xB+GPzfJ+ILaws/5F+HP38pyCfOhrOrJLShS/baq59g7/knCinBf9si
         lviaDDunLM6lQ3cLXnDyUCH01t6ayoxd7GkEktSTITKVgtl0csBXUMULPomExyQdw/lG
         P3gYFnN7TCL+ZNo4VtADZNKhbcTXJZ0jNFvSj5hF36CGwxdMl1lRcPg+JjskLP76uIyO
         7THLBG4hiCBWFyRqM6p7aYpQGXwxn9gKhYNdhkK3TTcft03n6lLSyvgJof9dZ01kx0kY
         ZMM9Ak4WcpPJOv3c7GYGiWvMbzEw6qjCZCU21q9HzzilcHBMNnkLMwkYqm1fTaO1ns/i
         57CA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=m8/4TDGoTP0YJOmmNh1QY5sjP7utSN3T4GKeg0uRKkI=;
        b=KctX2eDhBaj9CHccn50ljO46rh5ys8chUA6Tgd9SC6Fdw3RZ5aSOio190duvUwTlMA
         zur2dxO0UAZG9fZS1L/yLVX/a5Nf90Asljk05Z3mYm1EaQzoQWg2LyvW2Fs4oBRUevGA
         GAgTPsOmuxDcxHxZuqsr2Q1Bofet9oT8K2WBFBWaFAetCGPIKs4dvEFAgSsKhzfjWlj/
         8i+7r752MmbDeq5DgEvnEcqbBzLApntDY2NzD97b3HAgy89ygngd3FdvgezFtPaiC2BR
         IrbltYL7KLueNpMycs43GxGvvj3jyYI9NkRdQo1Fk6p+35Qc6PhMx7G6+4SvOlxpcWC1
         dPUQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=S58mOK6k;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u65sor18928993ywe.106.2019.07.26.15.53.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 26 Jul 2019 15:53:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=S58mOK6k;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=m8/4TDGoTP0YJOmmNh1QY5sjP7utSN3T4GKeg0uRKkI=;
        b=S58mOK6kmyfjaqk1fnTJ++/++kcxrVvJPN9KcacKz65Ijo+9nbPY62HM1CffSp86Gu
         /dPN5MfoF9x3qzmvRf4i/6AryZbuh86DENdsSJKo1zLveUuyHt3BmI5KngT42emGLpRg
         LfE5/fDELYjpJFgZ6/3aEWoIOYp7eIVl/VMYJO3P6dhqng+w41uZfFsmu2hMSxMur74E
         cjujptrMLPPTtmOt4Ya3Uv+rKDOFMywYfHOEFwqVFz7D2oHaFLDQNzYLJ324mImcBbId
         h3rDRv/vOKwwLN7nnncz9jasy9fPT3hIXPkkvg9QeXHJnJnt2ZVEQ6gEW6zaDfc0rSja
         EY0Q==
X-Google-Smtp-Source: APXvYqzNhimbC8mzTJcKYV0Wi6pTpAOpfQ/Ahx7/RLFgCd5sUCIjXXqqjCww0QbPgslVApm1LWoPGyUTAhbML+xsfXs=
X-Received: by 2002:a81:19c6:: with SMTP id 189mr57026739ywz.296.1564181608700;
 Fri, 26 Jul 2019 15:53:28 -0700 (PDT)
MIME-Version: 1.0
References: <20190726224810.79660-1-henryburns@google.com>
In-Reply-To: <20190726224810.79660-1-henryburns@google.com>
From: Shakeel Butt <shakeelb@google.com>
Date: Fri, 26 Jul 2019 15:53:17 -0700
Message-ID: <CALvZod7Q_86F=aH6zP0TRFZ_6N5e2oFnjoSTPv=mcAdi0HEg3A@mail.gmail.com>
Subject: Re: [PATCH] mm/z3fold.c: Fix z3fold_destroy_pool() ordering
To: Henry Burns <henryburns@google.com>
Cc: Vitaly Vul <vitaly.vul@sony.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Jonathan Adams <jwadams@google.com>, David Howells <dhowells@redhat.com>, 
	Thomas Gleixner <tglx@linutronix.de>, Al Viro <viro@zeniv.linux.org.uk>, 
	Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, 
	stable@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jul 26, 2019 at 3:48 PM Henry Burns <henryburns@google.com> wrote:
>
> The constraint from the zpool use of z3fold_destroy_pool() is there are no
> outstanding handles to memory (so no active allocations), but it is possible
> for there to be outstanding work on either of the two wqs in the pool.
>
> If there is work queued on pool->compact_workqueue when it is called,
> z3fold_destroy_pool() will do:
>
>    z3fold_destroy_pool()
>      destroy_workqueue(pool->release_wq)
>      destroy_workqueue(pool->compact_wq)
>        drain_workqueue(pool->compact_wq)
>          do_compact_page(zhdr)
>            kref_put(&zhdr->refcount)
>              __release_z3fold_page(zhdr, ...)
>                queue_work_on(pool->release_wq, &pool->work) *BOOM*
>
> So compact_wq needs to be destroyed before release_wq.
>
> Fixes: 5d03a6613957 ("mm/z3fold.c: use kref to prevent page free/compact race")
>
> Signed-off-by: Henry Burns <henryburns@google.com>

Reviewed-by: Shakeel Butt <shakeelb@google.com>

> Cc: <stable@vger.kernel.org>
> ---
>  mm/z3fold.c | 9 ++++++++-
>  1 file changed, 8 insertions(+), 1 deletion(-)
>
> diff --git a/mm/z3fold.c b/mm/z3fold.c
> index 1a029a7432ee..43de92f52961 100644
> --- a/mm/z3fold.c
> +++ b/mm/z3fold.c
> @@ -818,8 +818,15 @@ static void z3fold_destroy_pool(struct z3fold_pool *pool)
>  {
>         kmem_cache_destroy(pool->c_handle);
>         z3fold_unregister_migration(pool);
> -       destroy_workqueue(pool->release_wq);
> +
> +       /*
> +        * We need to destroy pool->compact_wq before pool->release_wq,
> +        * as any pending work on pool->compact_wq will call
> +        * queue_work(pool->release_wq, &pool->work).
> +        */
> +
>         destroy_workqueue(pool->compact_wq);
> +       destroy_workqueue(pool->release_wq);
>         kfree(pool);
>  }
>
> --
> 2.22.0.709.g102302147b-goog
>

